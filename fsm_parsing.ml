open ExtLib
open Commons

type pos_oper = Push | Pop | Rollback | No

type move_kind = 
  | Symb of char * char * (int -> unit) option * int * pos_oper 
  | Else of (unit -> unit) option * int * pos_oper
  | Goto of (unit -> unit) option * int * pos_oper

let op_s = function
  | Push -> "push" | Pop -> "pop" | Rollback -> "rollback" | No -> "no"

let move_s = function
  | Symb(c1, c2, f, idx, op) -> Printf.sprintf "Symb(%c,%c, %s, %d, %s)" c1 c2 (Option.map_default (fun _ -> "A") "N" f) idx (op_s op)
  | Else(f, idx, op) -> Printf.sprintf "Else(%s, %d, %s)" (Option.map_default (fun _ -> "A") "N" f) idx (op_s op)
  | Goto(f, idx, op) -> Printf.sprintf "Goto(%s, %d, %s)" (Option.map_default (fun _ -> "A") "N" f) idx (op_s op)

let ok = 1
let fail = 2

let p_range c1 c2 = [| [| Symb(c1,c2, None, ok, No); Else(None, fail, No) |]; [||]; [||] |]
let p_char c = p_range c c
let f_range c1 c2 f = [| [| Symb(c1,c2, Some f, ok, No); Else(None, fail, No) |]; [||]; [||] |]
let f_char c f = f_range c c f
let frame in_move = [| [| in_move |]; [||]; [||] |]

let show_graph g =
  Array.to_list g |> List.mapi (fun i n -> 
    Printf.sprintf "State %d: %s" i (Array.to_list n |> List.map move_s |> String.concat " ")) 
  |> String.concat "\n"

let echo_graph g = print_endline (show_graph g); g

let relocate p delta = 
  Array.map (Array.map (function
    | Symb(c1, c2, f, idx, op) -> Symb(c1, c2, f, idx + delta, op)
    | Else(f, idx, op) -> Else(f, idx + delta, op)
    | Goto(f, idx, op) -> Goto(f, idx + delta, op))) p

let connect p delta ok_move fail_move = 
  let res = relocate p delta in 
  res.(ok)   <- [| ok_move |]; 
  res.(fail) <- [| fail_move |]; 
  res

let norb p = 
  let pushes = function Goto(_, _, Push) -> true | _ -> false in
  if not (pushes p.(0).(0)) then p else
  let bad_exit = function 
    | Goto(_, 1, Pop) 
    | Goto(_, 2, Rollback) -> false
    | Goto(_, 1, _)  
    | Goto(_, 2, _) -> true
    | _ -> false in
  let bad = Array.enum p |> Enum.map Array.enum |> Enum.concat |> Enum.filter bad_exit |> (Enum.is_empty >> not) in
  if bad then p else
  let change0 = function Goto(f, st, Push) -> Goto(f, st, No) | x -> x in
  let change = function
    | Goto(f, 1, Pop) -> Goto(f, 1, No) 
    | Goto(f, 2, Rollback) -> Goto(f, 2, No)
    | move -> move in
  let p' = Array.map (Array.map change) p in
  (p'.(0).(0) <- change0 p'.(0).(0); p')  

let (>>>) a b = 
  let b_start = 3 + Array.length a in
  Array.concat [frame (Goto(None, 3, Push)); 
    connect (norb a) 3 (Goto(None, b_start, No)) (Goto(None, fail, Rollback)); 
    connect (norb b) b_start (Goto(None, ok, Pop)) (Goto(None, fail, Rollback))]

let (>>>>) a b = 
  let b_start = 3 + Array.length a in
  Array.concat [frame (Goto(None, 3, No)); 
    connect a 3 (Goto(None, b_start, No)) (Goto(None, fail, No)); 
    connect b b_start (Goto(None, ok, No)) (Goto(None, fail, No))]

let p_opt a = 
  Array.append (frame (Goto(None, 3, No))) 
    (connect a 3 (Goto(None, ok, No)) (Goto(None, ok, No)))

let f_opt a f = 
  Array.append (frame (Goto(None, 3, No))) 
    (connect a 3 (Goto(None, ok, No)) (Goto(Some f, ok, No)))

let (|||) a b = 
  let b_start = 3 + Array.length a in
  Array.concat [frame (Goto(None, 3, No)); 
    connect a 3 (Goto(None, ok, No)) (Goto(None, b_start, No));
    connect b (b_start) (Goto(None, ok, No)) (Goto(None, fail, No))]

let p_many a = 
  Array.append (frame (Goto(None, 3, No))) 
    (connect a 3 (Goto(None, 0, No)) (Goto(None, ok, No)))

let f_many initf a = 
  Array.concat [frame (Goto(Some initf, 3, No));
    connect a 3 (Goto(None, 3, No)) (Goto(None, ok, No))]

let p_plus p = p >>> p_many p

let (>>=) p f = 
  Array.append (frame (Goto(None, 3, No))) 
    (connect p 3 (Goto(Some f, ok, No)) (Goto(None, fail, No))) 
  
let p_pred p =
  let node1 = Enum.init 256 (fun i -> char_of_int i) |> Enum.filter p 
    |> Enum.map (fun c-> Symb(c,c, None, ok, No))  |> Array.of_enum 
    |> Array.append [| Else(None, fail, No) |] in
  [| node1; [||]; [||] |]   

let p_str str =   
 let graph = String.fold_left (fun p c -> p >>>> p_char c)
  (p_char str.[0]) (String.sub str 1 (String.length str - 1)) in
 Array.append (frame (Goto(None, 3, Push)))
  (connect graph 3 (Goto(None, ok, Pop)) (Goto(None, fail, Rollback))) 
  
let p_all_until str =
  let not_s0 = p_pred ((<>) str.[0]) in
  let many_not_s0 = Array.append (frame (Goto(None, 3, No))) 
    (connect not_s0 3 (Goto(None, 3, No)) (Goto(None, ok, No))) in
  let pstr = p_str str in
  let p_s0 = p_char str.[0] in
  let p_skipnretry = Array.append (frame (Goto(None, 3, No)))
    (connect p_s0 3 (Goto(None, 12345, No)) (Goto(None, fail, No))) in
  let gr = many_not_s0 >>>> (pstr ||| p_skipnretry) in
  let graph = Array.map (Array.map (function 
    | Goto(None, idx, op) when idx > 10000 -> Goto(None, 0, op)
    | move -> move)) gr in
 Array.append (frame (Goto(None, 3, Push)))
  (connect graph 3 (Goto(None, ok, Pop)) (Goto(None, fail, Rollback))) 

let sign = ref 0.0
let ivalue = ref 0
let fr = ref 0.0
let fv = ref 0.0
let float_res = ref 0.0          
          
let p_float = 
  f_opt (f_char '-' (fun _->sign:=-1.0)) (fun _->sign:=1.0) >>> 
  f_many (fun _->ivalue:=0) (f_range '0' '9' (fun c->ivalue:=!ivalue*10+c-48)) >>> 
  p_char '.' >>> 
  f_many (fun _->fv:=0.0; fr:=0.1) (f_range '0' '9' 
       (fun c-> fv:=!fv +. (float_of_int (c-48)) *. !fr; fr := !fr *. 0.1)) 
  >>= fun () -> float_res := !sign *. (float_of_int !ivalue +. !fv)      

let rec simplify p =
 let skip_first e = Enum.junk e; e in  
 Array.enum p |> skip_first |> Enum.mapi (fun srcn node ->
  Array.enum node |> Enum.filter_map (function Goto(None, dstn, No)-> Some(srcn+1, dstn)| _->None)) 
  |> Enum.concat |> Enum.get |> Option.map_default (fun (srcn, dstn) ->
    let dstn' = if dstn < srcn then dstn else dstn-1 in
    let adjust_idx idx = 
     if idx < srcn then idx else 
     if idx = srcn then dstn' else idx-1 in
    let adjust_move = function
     | Symb(c1, c2, f, idx, op) -> Symb(c1, c2, f, adjust_idx idx, op)
     | Else(f, idx, op) -> Else(f, adjust_idx idx, op)
     | Goto(f, idx, op) -> Goto(f, adjust_idx idx, op) in          
    let p' = Array.enum p |> Enum.mapi (fun i node-> (i,node)) 
      |> Enum.filter_map (fun (i,node) ->  if i = srcn then None else Some(Array.map adjust_move node)) 
      |> Array.of_enum in
    simplify p') p

type move_action = 
  | Consume | Keep 
  | ConsumeA of (int -> unit) | KeepA of (unit -> unit)

let tabulate p =
  p |> Array.map (fun node->
    let tmp = Array.make 257 (Keep, -1, No) in
    let default_move = Array.fold_left (fun def kind ->
      match kind with
      | Symb(c1, c2, fo, idx, op) -> 
          let action = Option.map_default (fun f -> ConsumeA f) Consume fo in
          let m = (action, idx, op) in 
          for i = int_of_char c1 to int_of_char c2 do tmp.(i)<-m  done; 
          def
      | Else(fo, idx, op) 
      | Goto(fo, idx, op) -> 
          Option.map_default (fun f -> KeepA f) Keep fo, idx, op
      ) (Keep, fail, No) node  in
    tmp |> Array.map (fun ((k, idx, op) as x) -> if idx >=0 then x else default_move))

let optimize tbl = 
  let rec optimove ch move = 
    match move with
    | _, 1, _
    | _, 2, _ -> move 
    | Keep, next_state, No -> optimove ch tbl.(next_state).(ch)
    | Keep, next_state, (Push as op)
    | Keep, next_state, (Pop as op) ->
        (match optimove ch tbl.(next_state).(ch) with
        | Consume, nxt2, No -> Consume, nxt2, op
        | _ -> move)
    | KeepA f, next_state, No ->
        (match optimove ch tbl.(next_state).(ch) with
        | Keep, nxt2, op -> KeepA f, nxt2, op
        | KeepA f2, nxt2, op -> KeepA (f >> f2), nxt2, op
        | _ -> move)
    | _ -> move in 
  Array.mapi (fun state tab -> 
    if state!=1 && state!=2 then Array.mapi optimove tab else tab) tbl

let ops = ref 0

let execute success fail tbl str =
 let len = String.length str in
 let stack = Array.make (Array.length tbl) 2 in  
 let rec run state i sp =
  match state with
  | 1 -> success () 
  | 2 -> fail ()
  | _ -> 
   let ch = if i<len then int_of_char str.[i] else 256 in 
   match tbl.(state).(ch) with
   | Consume, next_state, No -> run next_state (i+1) sp 
   | Consume, next_state, Push -> stack.(sp)<-i; run next_state (i+1) (sp+1) 
   | Consume, next_state, Pop -> run next_state (i+1) (sp-1) 
   | Keep, next_state, Push -> stack.(sp)<-i; run next_state i (sp+1) 
   | Keep, next_state, Pop -> run next_state i (sp-1)   
   | Keep, next_state, Rollback -> run next_state stack.(sp-1) (sp-1)  
   | ConsumeA f, next_state, No -> f ch; run next_state (i+1) sp
   | KeepA f, next_state, No -> f (); run next_state i sp   
   | KeepA f, next_state, Push -> f (); stack.(sp)<-i; run next_state i (sp+1) 
   | KeepA f, next_state, Pop -> f (); run next_state i (sp-1)   
   | KeepA f, next_state, Rollback -> f (); run next_state stack.(sp-1) (sp-1)
   | _ -> failwith "unexpected move" in  
 run 0 0 0
    
let prepare success fail p =
  p |> simplify |> tabulate |> optimize |> execute success fail
