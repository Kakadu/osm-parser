OCAMLC=ocamlfind  ocamlc -package extlib

SOURCES1=cb_base.cmo commons.cmo prof.cmo parsercomb.cmo 

SOURCES2=fsm_parsing.cmo  bounds_fsm.cmo osm_lexer.cmo\
	 bounds_yacc.cmo osm_parser.cmo \
	 prof.cmo bounds_pc.cmo parsercomb.cmo main.cmo

.SUFFIXES: .ml .mly .mli .cmo .cmi

all: stage1 yacc stage2 
	$(OCAMLC) -o main -linkpkg $(SOURCES1) osm_parser.cmo $(SOURCES2) 

cpp:
	g++ -c perf.c

stage1: $(SOURCES1)

yacc:
	ocamlyacc osm_parser.mly
	$(OCAMLC) -i osm_parser.ml > osm_parser.mli
	$(OCAMLC) -c osm_parser.mli
	$(OCAMLC) -c osm_parser.ml	

stage2: $(SOURCES2)

.ml.cmo:
	$(OCAMLC) -c $<

.mli.cmi:
	$(OCAMLC) -c $<

clean:
	rm -f *.cm[iox] osm_parser.ml

