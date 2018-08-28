comment $
cmacros - assembly macros for interfacing to hhls
(C)Copyright Microsoft Corp. 1984-1993
$

.xcref
??CM_Paste macro arg1:req, arg2:req
exitm <arg1&arg2>
endm

;	??_out	- output given message to the console unless ?QUIET has
;	been specified.
;
;	usage:
;		??_out	<t>
;
;	where:
;		<t> is the message to output
.xcref ??_out
??_out macro t
ifndef ?QUIET
%out t
endif
endm

;	outif - output msg if name is non-zero.  if name is undefined,
;	set name = 0, else set name to the default value.
;
;	usage:
;		outif	name,defval,onmsg,offmsg
;	where:
;		name	name of symbol
;		defval	default value to give symbol if not defined
;			if blank, then 0 will be used
;		onmsg	text to display if symbol is non-zero
;		offmsg	test to be displayed if symbol is zero

outif macro name,defval,onmsg,offmsg
ifndef name
ifb <defval>
name=0
else
name=defval
endif
endif
if name
name=1
ifnb <onmsg>
??_out <! onmsg>
endif
else
ifnb <offmsg>
??_out <! offmsg>
endif
endif
endm

;	??error - output msg and generate an assembly time error
;
;	usage:
;		??error <t>
;	where:
;		t	is the text to be output

.xcref ??error
??error macro msg
%out e r r o r ----- msg
.err e r r o r ----- msg
endm
.xcref ASMpass
.xcref memS,memM,memL,memC,memH,memMOD,sizec,sized
ASMpass=1
ifdef ?SMALL
memS=1
endif
ifdef ?MEDIUM
memM=1
endif
ifdef ?COMPACT
memC=1
endif
ifdef ?LARGE
memL=1
endif
ifdef ?HUGE
memH=1
endif
??_out <cMacros Version 5.32 - Copyright (c) Microsoft Corp. 1984-1993>
outif memS,0,<Small Model>
outif memM,0,<Medium Model>
outif memL,0,<Large Model>
outif memC,0,<Compact Model>
outif memH,0,<Huge Model>
memMOD= memS + memM + memL + memC + memH
if memMOD ne 1
if memMOD eq 0
memS = 1
outif memS,0,<Small Model>
else
??error <more than 1 memory model selected>
endif
endif
sizec= memM + memL + memH
sized= memL + memC + (memH*2)
outif ?DF,0,<No segments or groups will be defined>
outif ?TF,0,<Epilog sequences assume valid SP>
outif ?WIN,1,<Windows support>
if ?WIN eq 1
outif ?PLM,1,<>
else
outif ?PLM,1,<PL/M calling convention>
endif
ifndef ?NODATA
?nodata1=0
else
?nodata1=1
??_out <! NODATA module>
endif
ifndef ?CHKSTK
?chkstk1=0
else
?chkstk1=1
ifdef ?CHKSTKPROC
??_out <! Private stack checking enabled>
else
??_out <! Stack checking enabled>
endif
endif
ifndef DOS5
?DOS5=0
else
?DOS5=1
??_out <! DOS5 module>
endif
ifdef ?PROFILE
??_out <! Native profiling enabled>
endif
;;	Initialize all symbols used in the macros.  Theses symbols will not be
;;      included in any cross reference listing.
.xcref ?n,?ax,?ah,?al,?bx,?bh
.xcref ?bl,?cx,?ch,?cl,?dx,?dh
.xcref ?dl,?si,?di,?es,?ds,?bp
.xcref ?sp,?ss,?cs
.xcref ?rsl,?cpd,?argl,?argc,?ba
.xcref ?acb,???,?po
.xcref ?pas,?pc
.xcref uconcat,mpush,mpop
.xcref ?ri,?pp,?pp1,?al1
.xcref ?ad,?ap,?atal,?dd,?dd1,?dd2
.xcref ?pg,?pg1,?aloc,?cs1,?cs2
.xcref ?DF,?TF,?ff,?PLM,?WIN,?ia,?pu,?adj
.xcref ?uf,?rp,?nx,?nd,?nodata1,?chkstk1,?DOS5
.xcref ?wfp,arg,cCall,cProc,assumes,?cs3,?cs2,?cs1
.xcref defgrp,addseg,createSeg
.xcref save,outif,errnz,errn$,errnz1
.xcref ?PLMPrevParm,?gcc
.xcref ?cCall1,?pcc
?rsl    =       0           ;;0 = no register to save
?cpd    =       0           ;;<> 0 if in a procedure definition
?argl   =       0           ;;length of arguments pushed on stack
?argc   =       0           ;;# of arguments so far
?ba     =       0           ;;<>0 if in a procedure (xbegin)
?acb    =       0           ;;number of arguments to a call
???     =       0           ;;byte count of local storage
?po     =       0           ;;byte count of parameters
?pas    =       0           ;;autosave value for procedure
?pc     =       0           ;;class of a procedure (near/far)
?ia     =       0           ;;no adjustment
?pu     =       0           ;;public flag for some macros
?adj    =       0           ;;initial define for .xcref
?rp     =       0           ;;count of register parameters
?uf     =       0           ;;user's frame code specified
?nd	    =	    0			;;NODATA keyword specified
?nx	    =	    0			;;ATOMIC keyword specified
?wfp    =       0           ;;window far procedure
?ff     =       0           ;;forceframe keyword specified
?dd2	=	    0			;;used for globalx and staticx
?cCall1 =	    0			;;used for cCalls
?pcc	=	    ?PLM		;;procedure calling convention
?PLMPrevParm =	0			;;Used in parameter processing
.xcref ?casen
if1
?casen = 0
endif
?n = 0000000000000000b
?ax = 0000000000000011b
?ah = 0000000000000001b
?al = 0000000000000010b
?bx = 0000000000001100b
?bh = 0000000000000100b
?bl = 0000000000001000b
?cx = 0000000000110000b
?ch = 0000000000010000b
?cl = 0000000000100000b
?dx = 0000000011000000b
?dh = 0000000001000000b
?dl = 0000000010000000b
?si = 0000000100000000b
?di = 0000001000000000b
?es = 0000010000000000b
?ds = 0000100000000000b
?bp = 0001000000000000b
?sp = 0010000000000000b
?ss = 0100000000000000b
?cs = 1000000000000000b
.cref

;;      uconcat - unconditionally generate a statement from a field
;;      of given parameters
;;
;;      usage:
;;		uconcat  a,b,c,d,e,f,g
;;
;;      where:
;;              a,b   are concatenated for field 1
;;              c,d   are concatenated for field 2
;;		e,f,g are concatenated for field 3

uconcat macro a,b,c,d,e,f,g
a&b c&d e&f&g
endm

;;      mpush pushes multiple registers onto the stack according to
;;      a register specification.
;;
;;      format:
;;              mpush   r
;;
;;      where:
;;              r       is a numeric expression returned from ?ri
;;                      or any other valid register expression

mpush macro r
irp x,<ax,bx,cx,dx,si,di,es,ds,bp,sp,ss,cs>
%if (r and ??CM_Paste(?,x))
push	x
endif
endm
endm

;;      mpop pops multiple registers from the stack according to
;;      a register specification.
;;
;;      format:
;;              mpop    r
;;
;;      where:
;;              r       is a numeric expression returned from ?ri
;;                      or any other valid register expression

mpop macro r
irp x,<cs,ss,sp,bp,ds,es,di,si,dx,cx,bx,ax>
%if (r and ??CM_Paste(?,x))
pop	x
endif
endm
endm

;;      save - flag that the indicated registers are to be saved/restored
;;
;;	A flag is created which indicates which registers are to be saved
;;	when the cCall macro is invoked, and then restored after the call.
;;
;;      usage:
;;              save    <r>
;;
;;      where  r  is the list of registers to save, which may be:
;;
;;		register     saves
;;		   AX	      AX
;;		   AH	      AX
;;		   AL	      AX
;;		   BX	      BX
;;		   BH	      BX
;;		   BL	      BX
;;		   CX	      CX
;;		   CH	      CX
;;		   CL	      CX
;;		   DX	      DX
;;		   DH	      DX
;;		   DL	      DX
;;		   SI	      SI
;;		   DI	      DI
;;		   ES	      ES
;;		   DS	      DS
;;		   BP	      BP
;;
;;		  none	    nothing
;;
;;      the macro generates a value for the variable ?rsl

save macro r
?rsl=0
?ri ?rsl,<r>
endm

;;      ?ri - or register indexes to variable
;;
;;      ?ri is a macro that examines the passed argument list and computes
;;      a register index variable.
;;
;;	The values ORed with the variable are:
;;
;;              ?n       equ     0000000000000000b;
;;		?AX	 equ	 0000000000000011b;
;;		?AH	 equ	 0000000000000001b;
;;		?AL	 equ	 0000000000000010b;
;;		?BX	 equ	 0000000000001100b;
;;		?BH	 equ	 0000000000000100b;
;;		?BL	 equ	 0000000000001000b;
;;		?CX	 equ	 0000000000110000b;
;;		?CH	 equ	 0000000000010000b;
;;		?CL	 equ	 0000000000100000b;
;;		?DX	 equ	 0000000011000000b;
;;		?DH	 equ	 0000000001000000b;
;;		?DL	 equ	 0000000010000000b;
;;		?SI	 equ	 0000000100000000b;
;;		?DI	 equ	 0000001000000000b;
;;		?ES	 equ	 0000010000000000b;
;;		?DS	 equ	 0000100000000000b;
;;		?BP	 equ	 0001000000000000b;
;;		?SP	 equ	 0010000000000000b;
;;		?SS	 equ	 0100000000000000b;
;;		?CS	 equ	 1000000000000000b;
;;      usage:
;;              ?ri n,<r>
;;      where:
;;              n       is the variable to contain the new index value
;;              r       is the register list

?ri macro n,r
irp x,<r>
%ifdef ??CM_Paste(?,x)
%n=n or ??CM_Paste(?,x)
endif
endm
endm

;;      parmx - generate reference to parameter(s) on the stack
;;
;;	An equate is generated for addressing a paramter(s)
;;      on the stack for the current procedural frame.
;;
;;	An error message is generated if there isn't a current frame.
;;
;;      usage:
;;              parmx   n
;;      where:
;;              x       is the type of the argument(s)  b=byte, w=word, d=dword
;;              n       is the name(s) to be given the parameter(s).
;;
;;	Bytes are considered to be two bytes long for alignment.
;;
;;	The parmd form of the macro generates three equates:
;;
;;              name       -    for accessing the parameter as a double word
;;              off_name   -    for accessing the offset  (lsw) of the parameter
;;              seg_name   -    for accessing the segment (msw) of the parameter

.xcref
.xcref parmB,parmW,parmD,parmQ,parmT,parmCP,parmDP,parmH
.cref
parmB macro n
?pp <n>,<byte>,2,1
endm
parmW macro n
?pp <n>,<word>,2,2
endm
parmD macro n
ife ?pcc
irp x,<n>
?pp <&&x>,<dword>,0,4
?pp <off_&&x>,<word>,2,2
?pp <seg_&&x>,<word>,2,2
endm
else
irp x,<n>
?pp <seg_&&x>,<word>,2,2
?pp <off_&&x>,<word>,2,2
?pp <&&x>,<dword>,0,4
endm
endif
endm
parmH macro n
?pp <n>,<word>,4,2
endm
parmQ macro n
?pp <n>,<qword>,8,8
endm
parmT macro n
?pp <n>,<tbyte>,10,10
endm
if sizec
parmCP macro n
parmD <n>
endm
else
parmCP macro n
parmW <n>
endm
endif
if sized
parmDP macro n
parmD <n>
endm
else
parmDP macro n
parmW <n>
endm
endif

;;      ?pp is the generalized parameter definition macro
;;
;;      usage:
;;              ?pp m,t,l,s
;;
;;      where:
;;              n       is the name(s) of the parameters
;;              t       is the type (word, dword)
;;              l       is the length to update parameter byte count by
;;              s       is the internal typing size

?pp macro n,t,l,s
if ?cpd
.xcref
irp x,<n>
%.xcref ??CM_Paste(?t_,x)
%??CM_Paste(?t_,x)=s
ife ?pcc
?pp1 x,<t>,,,%(?po+?adj)
?po=?po+l
else
?PLMPrevParm=?PLMPrevParm+1
?po=?po+l
?pp1 x,<t>,%?po,%?adj,,%?PLMPrevParm,%(?PLMPrevParm-1)
endif
endm
.cref
else
??error <parm(s) "&n" declared outside proc def>
endif
endm

;;	?pp1 is the macro that generates the text equate for the
;;	parameter.  Two options exist, one for the C calling
;;      convention where the last parameter was the first pushed onto
;;	the stack ('C' convention), and one for the PL/M calling
;;      convention where the first parameter was the first
;;      pushed (also the same as ms-pascal).
;;
;;	The text generated will be of one of two forms:
;;
;;		name equ (type ptr [bp+(adj+offset)]) for C
;;           or
;;		name equ (type ptr [bp+adj+?po-offset]) for PL/M
;;
;;
;;	For C, since parameters are pushed first last, the offset
;;      plus the adjust will point to the correct parameter.
;;
;;	For PL/M, since parameters are pushed first first, the offset
;;	of a parameter is much more complicated.  A known portion of
;;      the offset can be computed when the text equate is generated.
;;
;;	What is known is the number of garbage bytes between BP and
;;      the nearest parameter (in this case the last parameter), and
;;      also how many bytes of parameters have preceeded this parameter.
;;
;;	What is unknown is how many total bytes of parameters there will
;;      be, which affects all the generated text equates since the offset
;;      from bp must be determined at some point.
;;
;;	Well, the offset from BP can be computed with one variable if
;;      the following is remembered:
;;
;;          the offset of any parameter from the first parameter is always
;;          the current parameter offset (?po).
;;
;;	With this in mind, you just have to figure out where the first
;;      parameter is, which is:
;;
;;              bp + garbage adjustment + distance to first parameter
;;         or
;;              bp + ?adj + ?po
;;
;;	This implies that any parameter can be defined as:
;;
;;              bp + ?adj + ?po -%?po
;;
;;	Make any sense?
;;
;;	For PL/M, a chain of self-purging macros will be generated
;;	which will pass the evaluated ?po to any previous incarnation
;;	of the macro.  This will allow the text equate to be generated
;;	with the actual offset instead of the symbolic ?po.
;;
;;
;;      usage:
;;		?pp1	n,t,o,a,b,cpc,ppc
;;
;;      where:
;;              n    is the name to be given the equate
;;              t    is the type (byte, word, dword)
;;              o    is the offset from the first parameter
;;              a    is the adjustment
;;              b    is the adjustment plus the offset from the first parameter
;;		cpc  is the number of parameters so far
;;		ppc  is cpc - 1

?pp1 macro n,t,o,a,b,cpc,ppc
ife ?pcc
n equ (t ptr [bp][+b])
else
.xcref
.xcref ?PLMParm&cpc
.cref
?PLMParm&cpc macro po
uconcat <n>,,<equ>,,<(t ptr [bp][+>,%(a+po-o),<])>
?PLMParm&ppc po
purge ?PLMParm&cpc
endm
endif
endm

;;	parmR - register parameter
;;
;;	parmR is the macro used for generating register parameters.
;;	The space allocated for the register parameters will be
;;      the ?ia (interface adjust) area which is between the  old
;;	BP and the first parameter.  Normally this is empty (?ia=0),
;;      or has the saved ds for a windows far procedure.
;;
;;	Byte and dword register parameters will be allowed.
;;
;;      usage:
;;		parmR	n,r,r2
;;      where:
;;              n       is the name of the parameter
;;              r       is the register it is in
;;              r2      is the offset register if a dword

ifndef ?NOPARMR
.xcref
.xcref ?pr,parmR
.cref
parmR macro n,r,r2
?pr n,r,r2,%?rp,%(?ia+2)
endm

  ;;	?pr - register parameter
  ;;
  ;;	?pr is the actual macro for generating the equates for
  ;;	register parameters.
  ;;
  ;;	usage:
  ;;		parmR	n,r,r2,i,o
  ;;	where:
  ;;		n	is the name of the parameter
  ;;		r	is the register it is in
  ;;		r2	is the offset register if a dword
  ;;		i	is the index of the ?rp to generate
  ;;		o	is the offset from bp where the parm will be

?pr macro n,r,r2,i,o
.xcref
ifnb <r2>
parmR seg_&n,r
parmR off_&n,r2
n equ (dword ptr [bp][-o-2])
.xcref ?t_&n
?t_&n=4
else
.xcref ?rp&i
?rp&i=0
ifdef ?&r
?rp&i=?&r
endif
if ??? or (?cpd eq 0) or (?rp&i eq 0)
??error <invalid parmR encountered: &n,&r>
exitm
endif
n equ (word ptr [bp][-o])
.xcref ?t_&n
?t_&n=2
irp x,<bh,ch,dh,bl,cl,dl,ah,al>
%if ??CM_Paste(?,x) eq ??CM_Paste(?,r)
n equ (byte ptr [bp][-o])
%??CM_Paste(?t_,n)=1
exitm
endif
endm
?ia=?ia+2
?rp=?rp+1
endif
.cref
endm
endif

;;      localx - generate reference to a local variable on the stack
;;
;;	An equate is generated for addressing a local variable
;;      on the stack for the current procedural frame.
;;
;;      usage:
;;              localx    n
;;      where:
;;              x       is the type b=byte, w=word, d=dword, v=variable size
;;              n       is the name(s) to be given the variable(s).
;;
;;	Bytes are considered to be two bytes long for alignment reasons
;;
;;	The locald form of the macro generates three equates:
;;
;;              name       -    for accessing the variable as a double word
;;              off_name   -    for accessing the offset  (lsw) of the variable
;;              seg_name   -    for accessing the segment (msw) of the variable

.xcref
.xcref localB,localW,localD,localQ,localT,localCP,localDP,localV
.cref
localB macro n
?aloc <n>,<byte ptr>,1,1,0
endm
localW macro n
?aloc <n>,<word ptr>,2,2,1
endm
localD macro n
irp x,<n>
?aloc <seg_&&x>,<word ptr>,2,2,1
?aloc <off_&&x>,<word ptr>,2,2,1
?aloc <&&x>,<dword ptr>,0,4,1
endm
endm
localQ macro n
?aloc <n>,<qword ptr>,8,8,1
endm
localT macro n
?aloc <n>,<tbyte ptr>,10,10,1
endm
if sizec
localCP macro n
localD <n>
endm
else
localCP macro n
localW <n>
endm
endif
if sized
localDP macro n
localD <n>
endm
else
localDP macro n
localW <n>
endm
endif
localV macro n,a
?aloc <n>,,%(a),0,1
endm

;;      ?aloc is the macro that actually allocates local storage.
;;      it is only invoked by the localx macros.
;;
;;      usage:
;;              ?aloc  n,t,l,s,a
;;      where:
;;              n      is a list of names of local variable of the
;;                      given type.
;;              t       is the text string for the given variable
;;                      and is one of:
;;                          word  ptr
;;                          dword ptr
;;                          byte  ptr
;;                      or alternatively left blank for variable size
;;                      allocations (no implicit type).
;;              l       is the size of the variable in bytes
;;              s       is the internal type flag (size), and is one of:
;;                              word     - 2
;;                              dword    - 4
;;                              byte     - 1
;;                              variable - 0
;;              a       is a flag indicating that word alignment is to be
;;                      forced for this type of item.
;;
;;	NOTE:	It is assumed that the stack is already aligned on a word
;;		boundary when the cProc is invoked.  The macros will guarantee
;;		to allocate an even number of bytes on the stack to maintain
;;              word alignment.

?aloc macro n,t,l,s,a
if ?cpd
.xcref
irp x,<n>
???=???+l
if a
???=((??? + 1) and 0fffeh)
endif
?al1 x,<t>,%(???+?ia)
%.xcref ??CM_Paste(?t_,x)
%??CM_Paste(?t_,x)=s
endm
.cref
else
??error <locals "&n" declared outside procedure def>
endif
endm

;;      ?al1 - allocate local, continued.
;;
;;      ?al1 actually generates the text equate for the local variable.
;;	The form of the text equate generated is more or less:
;;
;;		name equ (type ptr [bp-?ia-nn])
;;          or
;;		name equ ([bp-?ia-nn])
;;
;;      where:
;;              ?ia   is defined to be either zero, or is defined to be
;;		      the number of bytes between the saved BP and the first
;;		      local.  ?ia is only applicable if the current cProc is
;;		      a windows far procedure or if parmRs have been
;;		      encountered.  If not, the ?ia will be zero.  since ?ia
;;		      is determinable prior to invoking this macro, it will be
;;		      added into the  offset ("nn") passed to this macro
;;
;;      usage:
;;              ?al1 n,t,o
;;      where:
;;              n    is the name for the text equate
;;              t    is the type of the equate
;;              o    is the offset of the equate

?al1 macro n,t,o
n equ (t [bp][-o])
endm

;;	?gcc - get calling convention
;;
;;	?gcv sets the given symbol to the calling convention
;;	to be used.
;;
;;	usage:
;;		?gcc s,i,cc
;;
;;	where:
;;		s  is the symbol to return the convention in
;;		   s = 0 if 'C' calling convention
;;		   s = 1 if PL/M (PASCAL) calling convention
;;		i  is the initial value for s
;;		cc is the calling convention override, and may be one of
;;		   C	  use 'C' convention
;;		   PLM	  use PL/M calling convention
;;		   PASCAL use PL/M calling convention

?gcc macro s,i,cc
s = i
ifnb <cc>
ifidn <cc>,<C>
s=0
endif
ifidn <cc>,<PLM>
s=1
endif
ifidn <cc>,<PASCAL>
s=1
endif
endif
endm
ifndef ?NOGLOBAL
.xcref
.xcref globalB,globalW,globalD,globalQ,globalT,globalCP,globalDP

  ;;	globalx - define global data of type x
  ;;
  ;;	usage:
  ;;		globalx n,i,s,c
  ;;	where:
  ;;		x	is the type of the variable  b=byte, w=word, d=dword
  ;;			q=quad word, t=tenbytes, cp=code pointer, dp=data pointer
  ;;		n	is the name to be given the variable.
  ;;		i	is the initial value of the variable.
  ;;		s	is the duplication factor
  ;;		c	is the convention, C for C, PLM or PASCAL for PL/M.
  ;;			The default (?PLM flag) will be used if not specified.
  ;;
  ;;	The D form will generate two extra equates of the form off_n and seg_n.

.cref
globalB macro n,i,s,c
?ad <n>,1
?dd n,1,<byte>,<db>,<i>,<s>,<c>
endm
globalW macro n,i,s,c
?ad <n>,2
?dd n,1,<word>,<dw>,<i>,<s>,<c>
endm
globalD macro n,i,s,c
?ad <n>,4
?dd n,1,<dword>,<dd>,<i>,<s>,<c>
off_&n equ word ptr n[0]
seg_&n equ word ptr n[2]
endm
globalQ macro n,i,s,c
?ad <n>,8
?dd n,1,<qword>,<dq>,<i>,<s>,<c>
endm
globalT macro n,i,s,c
?ad <n>,10
?dd n,1,<tbyte>,<dt>,<i>,<s>,<c>
endm
if sizec
globalCP macro n,i,s,c
globalD n,<i>,<s>,<c>
endm
else
globalCP macro n,i,s,c
globalW n,<i>,<s>,<c>
endm
endif
if sized
globalDP macro n,i,s,c
globalD n,<i>,<s>,<c>
endm
else
globalDP macro n,i,s,c
globalW n,<i>,<s>,<c>
endm
endif
endif
ifndef ?NOSTATIC
.xcref
.xcref staticB,staticW,staticD,staticQ,staticT,staticCP,staticDP

  ;;	staticx - define static data of type x
  ;;
  ;;	usage:
  ;;		staticx n,i,s
  ;;	where:
  ;;		x	is the type of the variable  b=byte, w=word, d=dword
  ;;			q=quad word, t=tenbytes, cp=code pointer, dp=data pointer
  ;;		n	is the name to be given the variable.
  ;;		i	is the initial value of the variable.
  ;;		s	is the duplication factor
  ;;
  ;;	statics do not generate an underscored version of the symbol
  ;;	since they are intended to be internal symbols.  If they are
  ;;	required to be public, use globlax.

.cref
staticB macro n,i,s
?ad <n>,1
?dd n,0,<byte>,<db>,<i>,<s>,<PLM>
endm
staticW macro n,i,s
?ad <n>,2
?dd n,0,<word>,<dw>,<i>,<s>,<PLM>
endm
staticD macro n,i,s
?ad <n>,4
?dd n,0,<dword>,<dd>,<i>,<s>,<PLM>
endm
staticQ macro n,i,s
?ad <n>,8
?dd n,0,<qword>,<dq>,<i>,<s>,<PLM>
endm
staticT macro n,i,s
?ad <n>,10
?dd n,0,<tbyte>,<dt>,<i>,<s>,<PLM>
endm
if sizec
staticCP macro n,i,s
staticD n,<i>,<s>
endm
else
staticCP macro n,i,s
staticW n,<i>,<s>
endm
endif
if sized
staticDP macro n,i,s
staticD n,<i>,<s>
endm
else
staticDP macro n,i,s
staticW n,<i>,<s>
endm
endif
endif

  ;;	staticx - define static data of type x
  ;;
  ;;	usage:
  ;;		staticx n,i,s
  ;;	where:
  ;;		x	is the type of the variable  b=byte, w=word, d=dword
  ;;			q=quad word, t=tenbytes, cp=code pointer, dp=data pointer
  ;;		n	is the name to be given the variable.
  ;;		i	is the initial value of the variable.
  ;;		s	is the duplication factor
  ;;
  ;;	statics do not generate an underscored version of the symbol
  ;;	since they are intended to be internal symbols.  If they are
  ;;	required to be public, use globlax.

?dd macro n,p,t,d,i,s,c
?gcc ?dd2,%?PLM,<c>
ife ?dd2
n label t
?dd1 _&n,p,<d>,<i>,<s>
else
?dd1 n,p,<d>,<i>,<s>
endif
endm

;;      ?dd1 is the generalized data definition macro.
;;
;;      format:
;;              ?dd1 n,p,d,i,s
;;      where:
;;              n       is the name of the procedure
;;              p       is the public flag
;;              d       is the assembler directive (db,dw or dd)
;;              i       is the initial value
;;              s       is a duplication factor

?dd1 macro n,p,d,i,s
if p
public n
endif
ifb <s>
n d i
else
ifb <i>
n d s dup (?)
else
n d s dup (i)
endif
endif
endm
ifndef ?NOEXTERN
.xcref
.xcref ?ex1,?ex2,externB,externW,externD,externQ,externT
.xcref externNP,externFP,externP,externCP,externDP,externA
.cref
?ex2 = 0

  ;;	externx - define external data of type x
  ;;
  ;;	usage:
  ;;		externx n,c
  ;;	where:
  ;;		x	is the type of the variable  b=byte, w=word, d=dword
  ;;			q=quad word, t=tenbytes, cp=code pointer
  ;;			dp=data pointer,  a=absolute
  ;;		n	is a list of names to define
  ;;		c	is the convention, C for C, PLM or PSACAL forPL/M.
  ;;			The default (?PLM flag) will be used if not specified.

externA macro n,c
?ex1 <n>,40h,<abs>,<c>,<>
endm
externB macro n,c
?ex1 <n>,1,<byte>,<c>,<>
endm
externW macro n,c
?ex1 <n>,2,<word>,<c>,<>
endm
externD macro n,c
?ex1 <n>,4,<dword>,<c>,<>
endm
externQ macro n,c
?ex1 <n>,8,<qword>,<c>,<>
endm
externT macro n,c
?ex1 <n>,10,<tbyte>,<c>,<>
endm
externNP macro n,c
?ex1 <n>,2,<near>,<c>,<cc>
endm
externFP macro n,c
?ex1 <n>,4,<far>,<c>,<cc>
endm
if sizec
externP macro n,c
?ex1 <n>,4,<far>,<c>,<cc>
endm
else
externP macro n,c
?ex1 <n>,2,<near>,<c>,<cc>
endm
endif
if sizec
externCP macro n,c
?ex1 <n>,4,<dword>,<c>,<>
endm
else
externCP macro n,c
?ex1 <n>,2,<word>,<c>,<>
endm
endif
if sized
externDP macro n,c
?ex1 <n>,4,<dword>,<c>,<>
endm
else
externDP macro n,c
?ex1 <n>,2,<word>,<c>,<>
endm
endif

  ;;	?ex1 is the generalized external definition macro
  ;;
  ;;	format:
  ;;		?ex1 n,s,d,c,scv
  ;;	where:
  ;;		n	is are the names of the externals
  ;;		s	is the size in bytes (used for typing)
  ;;		d	is the type
  ;;		c	is the convention, C for C, PLM or PSACAL for PL/M.
  ;;			The default (?PLM flag) will be used if not specified.
  ;;		scv	save calling convention.  If this field is "cc", then
  ;;			the calling convention will be saved in a ?CCn equ.

?ex1 macro n,s,d,c,scv
?gcc ?ex2,%?PLM,<c>
irp x,<n>
.xcref
%.xcref ??CM_Paste(?t_,x)
.cref
%??CM_Paste(?t_,x)=s
ife ?ex2
%extrn ??CM_Paste(_,x):&d
%x equ ??CM_Paste(_,x)
else
extrn x:&d
endif
ifidn <scv>,<cc>
.xcref
%.xcref ??CM_Paste(?CC,x)
.cref
%??CM_Paste(?CC,x)=?ex2
endif
endm
endm
endif
ifndef ?NOLABEL
.xcref
.xcref ?lb1,?lblpu,?lb2
.xcref labelB,labelW,labelD,labelQ,labelT
.xcref labelNP,labelFP,labelP,labelCP,labelDP
.cref
?lblpu = 0
?lb2 = 0

  ;;	  labelx - define label of data type x
  ;;
  ;;	  usage:
  ;;		  labelx n,c
  ;;	  where:
  ;;		x	is the type of the variable  b=byte, w=word, d=dword
  ;;			q=quad word, t=tenbytes, cp=code pointer, dp=data pointer
  ;;		n	is a list of names to define, the first of which can
  ;;			be the keyword public
  ;;		c	is the convention, C for C, PLM or PSACAL for PL/M.
  ;;			The default (?PLM flag) will be used if not specified.

labelB macro n,c
?lb1 <n>,1,<byte>,<c>
endm
labelW macro n,c
?lb1 <n>,2,<word>,<c>
endm
labelD macro n,c
?lb1 <n>,4,<dword>,<c>
endm
labelQ macro n,c
?lb1 <n>,8,<qword>,<c>
endm
labelT macro n,c
?lb1 <n>,10,<tbyte>,<c>
endm
labelNP macro n,c
?lb1 <n>,2,<near>,<c>
endm
labelFP macro n,c
?lb1 <n>,4,<far>,<c>
endm
if sizec
labelP macro n,c
?lb1 <n>,4,<far>,<c>
endm
else
labelP macro n,c
?lb1 <n>,2,<near>,<c>
endm
endif
if sizec
labelCP macro n,c
?lb1 <n>,4,<dword>,<c>
endm
else
labelCP macro n,c
?lb1 <n>,2,<word>,<c>
endm
endif
if sized
labelDP macro n,c
?lb1 <n>,4,<dword>,<c>
endm
else
labelDP macro n,c
?lb1 <n>,2,<word>,<c>
endm
endif

  ;;	?lb1 is the generalized label definition macro
  ;;
  ;;	format:
  ;;		?lb1 n,s,d
  ;;	where:
  ;;		n	are the names of the labels
  ;;		s	is the size in bytes (used for typing)
  ;;		d	is the type
  ;;		c	is the convention, C for C, PLM or PSACAL for PL/M.
  ;;			The default (?PLM flag) will be used if not specified.

?lb1 macro n,s,d,c
?gcc ?lb2,%?PLM,<c>
?lblpu=0
irp x,<n>
ifidn <x>,<PUBLIC>
?lblpu=1
else
.xcref
%.xcref ??CM_Paste(?t_,x)
.cref
%??CM_Paste(?t_,x)=s
ife ?lb2
if ?lblpu
%public ??CM_Paste(_,x)
endif
%??CM_Paste(_,x) label &d
%x equ ??CM_Paste(_,x)
else
if ?lblpu
public x
endif
x label &d
endif
endif
endm
endm
endif
ifndef ?NODEF
.xcref
.xcref defB,defW,defD,defQ,defT,defCP,defDP
.cref

  ;;	defx - inform macros that name is of type x
  ;;
  ;;	The given name(s) is flaged to be of the given type.  This macro
  ;;	is intended for giving types to variables that were not generated
  ;;	by the macros (i.e., static storage).  There must be a type definition
  ;;	for all parameters in a call list.
  ;;
  ;;	usage:
  ;;		defx	n
  ;;	where:
  ;;		x	is the type of the variable  b=byte, w=word, d=dword
  ;;		n      is the name(s) to be given the variable(s).
  ;;
  ;;	Bytes are considered to be two bytes long for alignment reasons

defB macro n
?ad <n>,1
endm
defW macro n
?ad <n>,2
endm
defD macro n
?ad <n>,4
endm
defQ macro n
?ad <n>,8
endm
defT macro n
?ad <n>,10
endm
if sizec
defCP macro n
defD <n>
endm
else
defCP macro n
defW <n>
endm
endif
if sized
defDP macro n
defD <n>
endm
else
defDP macro n
defW <n>
endm
endif
endif

;	?ad is the macro which creates a definition for the given
;	symbol
;
;	usage:
;		?ad <n>,s
;	where:
;		n is a list of names to define
;		s is the size info (1,2,4,8,10)

?ad macro n,s
irp x,<n>
.xcref
%.xcref ??CM_Paste(?t_,x)
.cref
%??CM_Paste(?t_,x)=s
endm
endm
ifndef ?NOPTR
.xcref
.xcref regPtr,farPtr
.cref

  ;;	regPtr generates information allowing a 32-bit pointer currently
  ;;	in a register to be pushed as a parameter to a subroutine using
  ;;	the cCall macro.
  ;;
  ;;	usage:
  ;;		regptr	n,s,o
  ;;	where:
  ;;		n	is the name the argument will be known as
  ;;		s	is the register containing the segment portion
  ;;			of the pointer
  ;;		o	is the register containing the offset portion
  ;;			of the pointer
  ;;
  ;;	2/14/85 - made obsolete with farptr

regPtr macro n,s,o
farPtr n,s,o
endm

  ;;	farPtr generates information allowing a 32-bit pointer to be
  ;;	pushed as a parameter to a subroutine using the cCall macro.
  ;;
  ;;	usage:
  ;;		farptr	n,s,o
  ;;	where:
  ;;		n	is the name the argument will be known as
  ;;		s	is the segment portion of the pointer
  ;;		o	is the offset portion of the pointer
  ;;
  ;;	Note that any cast must have been made in the argument itself
  ;;	(i.e. regptr ptr1,ds,<word ptr 3[si]>)

farPtr macro n,s,o
.xcref
.xcref ?t_&n
.cref
n macro
	push	s
	push	o
endm
?t_&n=80h
endm
endif

;;      arg - declare argument
;;
;;	The given argument(s) is added to the argument list structure
;;
;;      format:
;;              arg     a
;;
;;      where:
;;              a       is any valid argument to push.
;;
;;	If any element in arglist has not been defined or isn't a 16-bit
;;      register, then a complete specification must have been given in a
;;      text equate and a defx also given (if not, you'll pay the penalty!)

arg macro a
irp x,<a>
?argc=?argc+1
?atal <x>,%?argc
endm
endm

;;      ?atal (add to argument list) generates a macro that will cause
;;	the given argument to be processed when invoked.  It is used by
;;      the arg macro only.

?atal macro n,i
.xcref
.xcref ?ali&i
.cref
?ali&i macro
?ap <n>
endm
endm

;;      ?ap - process arguments and place onto stack
;;
;;	The given argument is processed (type checking) and place on
;;	the stack for a pending call.  There must be a type definition
;;	for all arguments (except words).  This can be done by using
;;      text equates and the defx macro.
;;
;;      format:
;;              ?ap n
;;      where:
;;              n       is the name of the argument to be pushed
;;
;;	The variable  ?argl  is updated by the length of the arguments
;;      pushed so that the stack can be cleaned up after the call.

?ap macro n
?argl=?argl+2
ifdef ?t_&n
ife ?t_&n-1
	push	word ptr (n)
exitm
endif
ife ?t_&n-2
	push	n
exitm
endif
ife ?t_&n-4
	push	word ptr (n)[2]
	push	word ptr (n)
?argl=?argl+2
exitm
endif
ife ?t_&n-8
	push	word ptr (n)[6]
	push	word ptr (n)[4]
	push	word ptr (n)[2]
	push	word ptr (n)
?argl=?argl+6
exitm
endif
if ?t_&n and 80h
n
?argl=?argl+2
exitm
endif
ife ?t_&n
	push	word ptr (n)
exitm
endif
endif
	push	n
endm

;;	cCall - call a 'c' language procedure
;;
;;	The given procedure is called with the given parameters.
;;	If the calling convention is C, the arguments are pushed
;;      in reverse order, and removed after the called procedure
;;	returns.  If the calling conventing is PL/M, the arguments
;;      are pushed as they were encountered, and the called procedure
;;      is assumed to have removed them from the stack.
;;
;;	The calling convention priority will be:
;;	   1)	that specified on the cCall if present
;;	   2)	that defined by the target
;;	   3)	the default (?PLM flag)
;;
;;      format:
;;		ccall n,<a>,c
;;
;;      where:
;;              n       is the name of the procedure to call
;;              a       are arguments to be pushed (optional, may be
;;                      specified with the "arg" macro.
;;		c	is the convention, C for C, PLM or PSACAL for PL/M.
;;			The default (?PLM flag) will be used if not specified.

cCall macro n,a,c
ifnb <a>
arg <a>
endif
mpush %?rsl
ifdef ?CC&n
?cCall1=?CC&n
else
?cCall1=?PLM
endif
ifnb <c>
?gcc ?cCall1,%?cCall1,<c>
endif
?argl=0
ife ?cCall1
?acb=?argc
else
?acb=1
endif
rept ?argc
uconcat <?ali>,%?acb
uconcat <purge>,,<?ali>,%?acb
ife ?cCall1
?acb=?acb-1
else
?acb=?acb+1
endif
endm
	call	n
if ((?cCall1 eq 0) and (?argl ne 0))
	add	sp,?argl
endif
mpop %?rsl
?rsl=0
?argc= 0
?argl= 0
endm

;;	cProc - define a 'c' procedure
;;
;;	cProc is the procedure definition for procedures.
;;
;;      format:
;;		cProc n,cf,a
;;      where:
;;              n       is the name of the procedure
;;
;;		cf	controls certain definitions, and may be:
;;			    NEAR       proc is to be a near label
;;			    FAR        proc is to be a far  label
;;			    PUBLIC     proc is to be defined as public
;;			    SMALL      call makeframe procedure
;;			    NODATA     dont create prolog code to setup DS
;;			    ATOMIC     don't link stack if not needed
;;				       NODATA must be specified for ATOMIC
;;			    FORCEFRAME Force generation of a frame
;;			    C	       proc is to be a C    procedure
;;			    PLM        proc is to be a PL/M procedure
;;			    PASCAL     proc is to be a PL/M procedure
;;			    WIN        proc is to be a windows procedure
;;			    NONWIN     proc isn't to be a windows procedure
;;
;;              a       is a list of registers that are to be saved whenever
;;                      the procedure is invoked.
;;
;;			makeframe procedure:   If small is specified, then
;;                      the "makeframe procedure" is invoked instead of
;;                      generating normal prologues/epilogues
;;
;;			A call is performed to the makeframe procedure.  The
;;                      call is followed by two bytes.  the first byte is the
;;                      number of locals to allocate for the frame, the second
;;			is the number of bytes of parameters.  The makeframe
;;			procedure will in turn call the cProc routine at the
;;			address following the data bytes.  When the cProc is
;;                      finished, it will do a near return to the makeframe
;;                      procedure to clean up the frame and exit.
;;
;;			Note that register parameters and makeframe are
;;                      incompatible and cannot be used together.
;;
;;			The makeframe procedure will save SI, DI, and also
;;			DS if a far procedure.	These registers will be
;;                      removed from the autosave list if specified.

cProc macro n,cf,a
if ?cpd
?utpe
endif
?cpd=1
???=0
?argc=0
?ba=0
?po=0
?pu=0
?ia=0
?adj=4
?rp=0
?uf=0
?wfp=?WIN
?ff=0
?pas=0
?pcc=?PLM
ifnb <a>
?ri ?pas,<a>
endif
?pc=sizec
?nd=?nodata1
?nx=0
irp x,<cf>
ifidn <x>,<FAR>
?pc=1
endif
ifidn <x>,<NEAR>
?pc=0
endif
ifidn <x>,<PUBLIC>
?pu=1
endif
ifidn <x>,<SMALL>
?uf=1
endif
ifidn <x>,<DATA>
?nd=0
endif
ifidn <x>,<NODATA>
?nd=1
endif
ifidn <x>,<ATOMIC>
?nx=1
endif
ifidn <x>,<FORCEFRAME>
?ff=1
endif
ifidn <x>,<C>
?pcc=0
endif
ifidn <x>,<PLM>
?pcc=1
endif
ifidn <x>,<PASCAL>
?pcc=1
endif
ifidn <x>,<WIN>
?wfp=1
endif
ifidn <x>,<NONWIN>
?wfp=0
endif
endm
if ?pcc
?PLMPrevParm=0
.xcref
.xcref ?PLMParm0
.cref
?PLMParm0 macro arg
purge ?PLMParm0
endm
endif
.xcref
.xcref ?CC&n
.cref
?CC&n=?pcc
if (?nx eq 1) and (?nd eq 0)
?nx = 0
??error <ATOMIC specified without NODATA - ATOMIC ignored>
endif
if ?pc
if ?wfp
ife ?nx
?ia=2
?pas = ?pas and (not ?ds)
endif
endif
?adj=?adj+2
else
?wfp=0
endif
?pas = ?pas and (not (?sp+?cs+?ss))
if ?uf
?pas = ?pas and (not (?bp+?si+?di))
endif
ife ?pcc
?pg <_&n>,%?pu,%?pc,%?pas,%?wfp,<n>,%?pcc
else
?pg <n>,%?pu,%?pc,%?pas,%?wfp,<n>,%?pcc
endif
endm

;;      ?pg - generate begin and nested macros for current procedure
;;
;;      format:
;;		?pg n,p,c,a,w,nnu,cc
;;      where:
;;              n       is the name of the procedure
;;              p       is the public flag
;;              c       is the class definition for the procedure
;;              a       is an enumerated list of registers to save
;;                      at entry and restore at exit
;;              w       true if a far windows procedure
;;		nnu	procedure name without any underscore
;;		cc	calling convention (C or PL/M)
;;
;;
;;      local stack allocation will be forced to an even byte count to
;;      maintain stack word alignment.

?pg macro n,p,c,a,w,nnu,cc
.xcref
if ?uf
if ?nd
??error <NODATA encountered in &n - user frame ignored>
?uf=0
endif
endif
.xcref cBegin
cBegin macro g
.xcref
if cc
uconcat <?PLMParm>,%?PLMPrevParm,%?po
endif
if ?uf
if ?rp
??error <parmR encountered in &n - user frame ignored>
?uf=0
endif
endif
?pg1 <n>,c,a,%?po,w,%?uf,%?nd,%?rp,cc
?cpd=0
?argc=0
?ba=1
???=(???+1) and 0fffeh
if p
public n
endif
ife c
n proc near
else
n proc far
endif
ife cc
nnu equ n
endif
ifidn <g>,<nogen>
if ???+?po+a+?rp
??_out <cBegin - possible invalid use of nogen>
endif
else
if ?uf
?mf c,%???,%?po
mpush a
else
if w
ife ?nd
	mov	ax,ds
	nop
endif
ife ?nx
ife ?DOS5
	inc	bp
endif
	push	bp
	mov	bp,sp
	push	ds
else
if ?ff+???+?po+?rp
	push	bp
	mov	bp,sp
endif
endif
ife ?nd
	mov	ds,ax
endif
else
if ?ff+???+?po+?rp
	push	bp
	mov	bp,sp
endif
endif
if ?rp
?uf=0
rept ?rp
uconcat mpush,,?rp,%?uf
?uf=?uf+1
endm
endif
if ???
if ?chkstk1
ifdef ?CHKSTKPROC
?CHKSTKPROC %???
else
	mov	ax,???
ife cc
	call	_chkstk
else
	call	chkstk
endif
endif
else
	sub	sp,???
endif
endif
mpush a
endif
ifdef ?PROFILE
if c
	call	StartNMeas
endif
endif
endif
.cref
purge cBegin
endm
.xcref ?utpe
?utpe macro
??error <unterminated procedure definition: "&n">
endm
.cref
endm

;;      ?pg1 - generate end macro for current procedure
;;
;;      format:
;;		?pg1 n,c,a,o,w,f,d,r,cc
;;      where:
;;              n       is the name of the procedure
;;              c       is the class definition for the procedure
;;              a       is an enumerated list of registers to save
;;                      at entry and restore at exit
;;              o       is the number of bytes of paramteres to remove at exit
;;              w       true if a far windows procedure
;;              f       is 1 if to use the user's makeframe procedure
;;		d	is 1 if NODATA procedure
;;              r       number of register parameters
;;		cc	calling convention (C or PL/M)

?pg1 macro n,c,a,o,w,f,d,r,cc
.xcref
.xcref cEnd
cEnd macro g
.xcref
?ba=0
ifidn <g>,<nogen>
if o+a+r
??_out <cEnd - possible invalid use of nogen>
endif
else
ifdef ?PROFILE
if c
call StopNMeas
endif
endif
mpop a
if f
	db	0c3h
else
if w
ife ?nx
if (?TF eq 0) or (???+?rp)
	lea	sp,(-2)[bp]
endif
	pop	ds
	pop	bp
ife ?DOS5
	dec	bp
endif
else
if (?TF eq 0) or (???+?rp)
	mov	sp,bp
endif
if ???+?po+?rp
	pop	bp
endif
endif
else
if ?ff+???+?po+?rp
if (?TF eq 0) or (???+?rp)
	mov	sp,bp
endif
	pop	bp
endif
endif
ife cc
	ret
else
	ret	o
endif
endif
endif
n endp
.cref
purge cEnd
endm
.cref
endm

;	assumes is a macro that will set up the assumes for a segment
;	or group created with the createSeg macro.  If the assumed
;	value passed in isn't known, then a normal assume is made.
;
;       usage:
;               assumes s,g
;
;       where:
;               s       is the register to make the assumption about
;               g       is the value to assume is in it

assumes macro s,ln
ifdef MS_STARTUP
ifidn <code>,<ln>
assume s&:_TEXT
exitm
elseifidn <CODE>,<ln>
assume s&:_TEXT
exitm
elseifidn <data>,<ln>
assume s&:dgroup
exitm
elseifidn <DATA>,<ln>
assume s&:dgroup
exitm
endif
endif
ifndef ln&_assumes
assume s:ln
else
ln&_assumes s
endif
endm

;	createSeg is a macro that sets up a segment definition and
;	a logical name for that segment.  The logical name can be
;       used to enter the segment, but it cannot be used for anything
;       else.
;
;       usage:
;		createSeg n,ln,a,co,cl,grp
;       where:
;               n       is the physical name of the segment
;               ln      is the name it is to be invoked by
;               a       is the alignment, and is optional
;               co      is the combine type, and is optional
;               cl      is the class, and is optional
;               grp     is the name of the group that contains this segment

createSeg macro n,ln,a,co,cl,grp
ifnb <cl>
n segment a co '&cl'
else
n segment a co
endif
n ends
?cs1 <ln>,<n>
ifnb <grp>
grp group n
?cs3 <ln>,<grp>
ln&OFFSET equ <offset grp:>
ln&BASE equ <grp>
else
?cs3 <ln>,<n>
ln&OFFSET equ <offset>
ln&BASE equ <n>
endif
endm
addseg macro grp,seg
.xcref
.xcref grp&_add
.cref
grp&_add macro s
grp&_in <seg>,s
endm
.xcref
.xcref grp&_in
.cref
grp&_in macro sl,s
ifb <s>
grp group sl
else
grp&_add macro ns
grp&_in <sl,s>,ns
endm
endif
endm
endm
defgrp macro grp,ln
endm
?cs1 macro ln,n
.xcref
.xcref ln&_sbegin
.cref
ln&_sbegin macro
?cs2 <ln>,<n>
n segment
.xcref
.xcref ?mf
.cref
?mf macro c,l,p
if c
	extrn	n&_FARFRAME:near
	call	n&_FARFRAME
else
	extrn	n&_NEARFRAME:near
	call	n&_NEARFRAME
endif
	db	l shr 1
	db	p shr 1
endm
endm
endm
?cs2 macro ln,n
.xcref
.xcref sEnd
.cref
sEnd macro arg
n ends
purge ?mf
purge sEnd
endm
endm
?cs3 macro ln,n
.xcref
.xcref ln&_assumes
.cref
ln&_assumes macro s
assume s:&n
endm
endm
.xcref
.xcref sBegin
.cref

;	sBegin is the macro that opens up the definition of a segment.
;	The segment must have already been defined with the createSeg
;       macro.
;
;       usage:
;		sBegin ln
;
;       where:
;               ln      is the logical name given to the segment when
;                       it was declared.

sBegin macro ln
ln&_sbegin
endm

  ;	Define all segments that will be used.	This will allow the
  ;	assume and groups to be set up at one given place, and also
  ;	allow quick changes to be made
  ;
  ;	createSeg name,logname,align,combine,class,group

ife ?DF
createSeg _TEXT,Code,word,public,CODE
ife ?nodata1
createSeg _DATA,Data,word,public,DATA,DGROUP
defgrp DGROUP,Data
endif
if ?chkstk1
ifndef ?CHKSTKPROC
externp <chkstk>
endif
endif
endif

;       errnz exp - generate error message if expression isn't zero
;
;	The errnz will generate an error message if the expression "exp"
;	does not evaluate to zero.  This macro is very useful for testing
;       relationships between items, labels, and data that was coded into
;       an application.
;
;                  errnz   <offset $ - offset label>   ;error if not at "label"
;                  errnz   <eofflag and 00000001b>     ;eofflag must be bit 0
;
;	For expressions involving more than one token, the angle brackets
;       must be used.
;
;	The macro is only evaluated on pass 2, so forward references may be
;       used in the expression.

errnz macro x
ifnb <x>
.errnz (x),<x>
endif
endm
errnz1 macro x1,x2
= *errnz* x1 = x2
.err
endm

;       errn$ label,exp - generate error message if label (exp) <> $
;
;	The errnz will generate an error message if the label and "exp"
;       does not evaluate to the current value of the location counter.
;	This macro is very useful for testing relationships between
;       labels and the location counter that was coded into an application.
;
;       examples:  errn$   label        ;error if not at "label"
;                  errn$   label,+3     ;error if not three bytes from "label"
;                  errn$   label,-3     ;error if not three bytes past "label"
;
;	If no "exp" is given, it is the same as specifying 0
;
;	The macro is only evaluated on pass 2, so forward references may be
;       used in the expression.

errn$ macro l,x
errnz <offset $ - offset l x>
endm

;;	If profile has been specified, declare the profile routines
;;	to be external and far.  It would be best if this could be done
;;	when the call is actually made, but then the fix-up would be
;;	generated as segment-relative.

ifdef ?PROFILE
externFP <StartNMeas,StopNMeas>
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Extra macros for the c-runtime package
;
; Macro for calling another run-time-library function.
; Does a PUSH CS/CALL NEAR in compact/large models, except
; for QuickC.		

callcrt MACRO funcname
ifdef _QC2
call funcname
else
if sizeC
push cs
call near ptr (funcname)
else
call funcname
endif
endif
ENDM
.cref
