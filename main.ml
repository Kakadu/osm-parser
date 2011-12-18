open ExtLib

let show_usage () = 
  print_endline "usage: bnd osmfile command\ncommands:";
  print_endline " pc - classic parser combinators\n yacc - ocamlyacc\n fsm - optimizing parsers"

let main fname cmd =  
  let text = Std.input_file fname in
  (match cmd with
  | "pc" -> Prof.prof1 "parser_comb" Bounds_pc.process text
  | "yacc" -> Prof.prof1 "yacc" Bounds_yacc.process text
  | "fsm" -> Prof.prof1 "fsm" Bounds_fsm.process text
  | _ -> show_usage ());  
  Prof.show_prof ();;

if Array.length Sys.argv < 3 then show_usage () 
else main Sys.argv.(1) Sys.argv.(2)
  