%{
let parse_error s =
  Printf.printf "Parse error: %s\n" s;
  flush stdout
   
open Cb_base

module Parser(Geo : Callbacks) = struct
%}

%token Leof Llbracket Lrbracket Lslash Leq Lquestion Losm Lnode Lway Lrelation Lid Lnd Lmember Lref Ltype Llat Llon
%token<string> Lident
%token<string> Lstring 
%start osmfile 
%type <unit> osmfile
%%
osmfile       : xmlhead osmtag {  };
xmlhead       : Llbracket Lquestion Lident otherparams Lquestion Lrbracket {  };

otherparams   : {  }
              | otherparams otherparam  {  };
                
otherparam    : Lident Leq Lstring {  };              
              
osmtag        :  osmbegin maintags Llbracket Lslash Losm Lrbracket {};
osmbegin      : Llbracket Losm otherparams Lrbracket {  }; 

maintags      : {}
              | maintags maintag  {  };              

maintag       : node {  }
              | way {  }
              | relation {  }
              | othertag {  };
                
othertag      : Llbracket Lident otherparams Lslash Lrbracket {  };

othertags     : { }
              | othertags othertag {  };

node          : Llbracket Lnode nodeparams nodeend { Geo.node $3 }

nodeend       : Lrbracket othertags Llbracket Lslash Lnode Lrbracket {  } 
              | Lslash Lrbracket {  }
              ;

nodeparams    : nodeparam { [$1] }
              | nodeparams nodeparam { $2 :: $1 }
              ;

nodeparam     : idparam { $1 }
              | Llat Leq Lstring { Lat $3 }
              | Llon Leq Lstring { Lon $3 }
              | otherparam { OtherParam  }
              ;
              
idparam       : Lid Leq Lstring { Id  };

way           :  Llbracket Lway wayparams wayend {  };
wayend        : Lrbracket waytags Llbracket Lslash Lway Lrbracket {  }
              | Lslash Lrbracket { }
              ;        

wayparams     : wayparam {  }
              | wayparams wayparam { }
              ;

wayparam      : idparam {  }
              | otherparam {  }
              ;
                                  
waytags       : { }
              | waytags waytag {  }
              ;
              
waytag        : ndtag {  }
              | othertag {  }
              ;

ndtag         : Llbracket Lnd Lref Leq Lstring Lslash Lrbracket {  };              

relation      : Llbracket Lrelation wayparams relend { };
relend        : Lrbracket reltags Llbracket Lslash Lrelation Lrbracket {  }
              | Lslash Lrbracket {  }
              ;
              
reltags       : {}
              | reltags reltag {  }
              ;

reltag        : membertag {  }
              | othertag {  }
              ;
              
membertag     : Llbracket Lmember memparams Lslash Lrbracket {  }
              ;

memparams     : memparam { }
              | memparams memparam {  }
              ;
              
memparam      : Ltype Leq Lstring { }
              | Lref Leq Lstring { }
              | otherparam {  }
              ;

%%
end (* of module *)
let osmfile lexer buf = ()