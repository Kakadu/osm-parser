How to build:
1. Install ExtLib
2. Set path to it in Makefile and mkmli.bat
3. run "make nc"
4. if first attempt fails, run mkmli.bat
5. run "make nc" again

The trick with mkmli.bat is caused by ocamlyacc generating a bit different 
interface file than required.

thedeemon
------------------------------------

December 2011
Rewrited makefile for autocompilation 
Profiler windows-only functionality has lost

Kakadu.
