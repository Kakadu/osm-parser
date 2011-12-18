open ExtLib
open Commons
open Cb_base

let minlat = ref 1000.0  
let maxlat = ref (-1000.0)  
let minlon = ref 1000.0  
let maxlon = ref (-1000.0)  

let strip s = String.sub s 1 ((String.length s)-2) 

module CB = struct
  let node params  =
    List.iter (function 
      | Id  | OtherParam  -> () 
      | Lon s -> let lon = float_of_string (strip s) in minlon := min !minlon lon; maxlon := max !maxlon lon
      | Lat s -> let lat = float_of_string (strip s) in minlat := min !minlat lat; maxlat := max !maxlat lat) params
end

module P = Osm_parser.Parser(CB)

let process osm = 
  let lexbuf = Lexing.from_string osm in
  P.osmfile Osm_lexer.lexer lexbuf;
  Printf.printf "yacc ok: lat=%f..%f lon=%f..%f\n" !minlat !maxlat !minlon !maxlon 
