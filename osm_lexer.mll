{
  open Osm_parser;;
}

rule lexer = parse
 [' ' '\t' '\n']     { lexer lexbuf }
 | '<'               { Llbracket }
 | '>'               { Lrbracket }
 | '='               { Leq }
 | '/'               { Lslash }
 | '?'               { Lquestion }
 | "osm"             { Losm }
 | "node"            { Lnode }
 | "way"             { Lway }
 | "relation"        { Lrelation }
 | "nd"              { Lnd }
 | "id"              { Lid }
 | "type"            { Ltype }
 | "member"          { Lmember }   
 | "lat"             { Llat }
 | "lon"             { Llon }
 | "ref"             { Lref }   
 | '"' [^ '"']* '"'      { Lstring (Lexing.lexeme lexbuf) }
 | '\'' [^ '\'']* '\''   { Lstring (Lexing.lexeme lexbuf) }  
 | ['A'-'Z' 'a'-'z'] ['A'-'Z' 'a'-'z' '0'-'9' '_']*            { Lident (Lexing.lexeme lexbuf) }
 | eof               { Leof }