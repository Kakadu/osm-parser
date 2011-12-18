type token =
    Leof
  | Llbracket
  | Lrbracket
  | Lslash
  | Leq
  | Lquestion
  | Losm
  | Lnode
  | Lway
  | Lrelation
  | Lid
  | Lnd
  | Lmember
  | Lref
  | Ltype
  | Llat
  | Llon
  | Lident of string
  | Lstring of string
val parse_error : string -> unit
module Parser :
  functor (Geo : Cb_base.Callbacks) ->
    sig
      val yytransl_const : int array
      val yytransl_block : int array
      val yylhs : string
      val yylen : string
      val yydefred : string
      val yydgoto : string
      val yysindex : string
      val yyrindex : string
      val yygindex : string
      val yytablesize : int
      val yytable : string
      val yycheck : string
      val yynames_const : string
      val yynames_block : string
      val yyact : (Parsing.parser_env -> Obj.t) array
      val yytables : Parsing.parse_tables
      val osmfile : (Lexing.lexbuf -> token) -> Lexing.lexbuf -> unit
    end
val osmfile : 'a -> 'b -> unit
