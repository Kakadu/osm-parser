open ExtLib
open Commons
open Parsercomb

let p_latlon name =
  p_str (name ^ "=\"") >>> p_float >>= fun f -> p_char '"' >>> return f

let low_letter c = c >= 'a' && c <='z' 

let p_param = 
  p_plus (p_pred low_letter) >>> p_str "=\"" >>> p_many (p_pred ((<>)'"')) >>> p_char '"' >>> return ()
  
let minlat = ref 1000.0  
let maxlat = ref (-1000.0)  
let minlon = ref 1000.0  
let maxlon = ref (-1000.0)  
  
let p_node_param =
      (p_latlon "lat" >>= fun lat -> minlat := min !minlat lat; maxlat := max !maxlat lat; return ())  
  ||| (p_latlon "lon" >>= fun lon -> minlon := min !minlon lon; maxlon := max !maxlon lon; return ())  
  ||| p_param

let p_ws = p_many (p_pred ((>=) ' '))
let p_endnode = (p_str "/>") ||| (p_all_until "</node>")  
let p_node = p_str "<node" >>>  p_many (p_ws >>> p_node_param) >>> p_endnode
let p_tag = p_char '<' >>> p_many (p_pred ((<>) '>')) >>> p_char '>'
let p_osm = p_many ((p_node ||| p_tag) >>> p_ws)
  
let process osm = 
  let chars = Prof.prof1 "explode" String.explode osm in
  match Prof.prof1 "p_osm" p_osm chars with
  | Parsed(_, s) -> Printf.printf "pc ok: lat=%f..%f lon=%f..%f\n" !minlat !maxlat !minlon !maxlon 
  | Failed -> Printf.printf "parse failed\n"       
