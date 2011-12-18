open ExtHashtbl
open ExtArray
(*
external get_perf_counter : unit -> int64 = "get_perf_counter"
external get_perf_frequency : unit -> int64 = "get_perf_frequency"
*)
let tbl: (string, int64) Hashtbl.t = Hashtbl.create 20

let rmmbr name dt =
  let sumt = try Hashtbl.find tbl name with Not_found-> 0L in Hashtbl.replace tbl name (Int64.add sumt dt)

let show_prof () = 
(*  let fr = Int64.to_float (get_perf_frequency ()) in *)
  let a = Array.of_enum (Hashtbl.enum tbl) in
  Array.sort (fun (n1,t1) (n2,t2)-> compare t2 t1) a; print_string "\nprofiling:\n"
(*  ;
  Array.iter (fun (name, t) -> Printf.printf "%s\t%f\n" name (Int64.to_float t /. fr)) a *)

let prof1 name f x1 =
  let res = f x1 in
  rmmbr name (Int64.zero); res

let prof2 name f x1 x2 =
  let res = f x1 x2 in
  rmmbr name (Int64.zero); res

let prof3 name f x1 x2 x3 =
  let res = f x1 x2 x3 in
  rmmbr name (Int64.zero); res
