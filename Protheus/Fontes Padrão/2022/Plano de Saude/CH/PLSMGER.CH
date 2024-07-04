#IFDEF SPANISH
      #define STRPL01  "Buscar"
      #define STRPL02  "Visualizar"
      #define STRPL03  "Incluir"
      #define STRPL04  "Modificar"
      #define STRPL05  "Borrar"
      #define STRPL06  "A rayas"
      #define STRPL07  "Administracion"
      #define STRPL08  "Espere. Procesando..."
      #define STRPL09  "Imprimiendo Pagina..."
      #define STRPL10  "ADMINISTRADORES"
#ELSE
   #IFDEF ENGLISH
      #define STRPL01  "Search"
      #define STRPL02  "View"
      #define STRPL03  "Insert"
      #define STRPL04  "Edit"
      #define STRPL05  "Delete"
      #define STRPL06  "Z.Form"
      #define STRPL07  "Administration"
      #define STRPL08  "Wait please, Processing..."
      #define STRPL09  "Printing page..."
      #define STRPL10  "ADMINISTRATORS"
   #ELSE
      #define STRPL01  "Pesquisar"
      #define STRPL02  "Visualizar"
      #define STRPL03  "Incluir"
      #define STRPL04  "Alterar"
      #define STRPL05  "Excluir"
      #define STRPL06  "Zebrado"
      #define STRPL07  "Administracao"
      #define STRPL08  "Aguarde. Processando..."
      #define STRPL09  "Imprimindo Pagina..."
      #define STRPL10  "ADMINISTRADORES"
   #ENDIF
#ENDIF


#define  __aNotCampos         { "BE4_FILIAL","BE4_CODOPE","BE4_DTALTA","BE4_HRALTA","BE4_TIPALT","BE4_DESALT",;
                                 "BE4_CIDREA","BE4_DESREA","BE4_TIPPAR","BE4_DSTPAR","BE4_TIPNAS","BE4_DSTNAS",;
                                 "BE4_DATPRO", "BE4_HORPRO","BE4_DTINCR", "BE4_HRINCR", "BE4_DTFICR", "BE4_HRFICR","BE4_PODRFS" }
#define PLPMONEY_P             "@E 999,999.99"
#define PLPMONEY_M             "@E 999,999,999.99"
#define K_Pesquisar            1   //   Pesquisar
#define K_Visualizar           2   //   Visualizar
#define K_Incluir              3   //   Incluir
#define K_Alterar              4   //   Alterar
#define K_Excluir              5   //   Excluir
#define K_OK                   1   //   Ok
#define K_Cancelar             2   //   Cancelar
#define K_aHeadFunc            6   //   aHeader Function
#define K_MsgDel               .F. //   EnchoiceBar
#define cPLTipoIR              "TX"
#define cPLLojaIR              "00"
#define nCHPrec                 17
#define nCHDeci                 4
#define nVlPrec                 17
#define nPlOrdSE1               14
#define nPlOrdSE2               10
#define nVlDec                  2 
#define PLSTR0001					OemToAnsi("Buscando dados no servidor...")
#define PLSTR0002               OemToAnsi("ABORTADO PELO OPERADOR...")
#define aPLFaixa               { {0,17} , {18,29} , {30,39} , {40,49} , {50,59} , {60,69} , {70,999} }


#define __PLSFLOGX If(FindFunction("PLSFILEPOS"),PlsFilePos(),"PLSXMOV.LOG")
#define __PLSFLOGC "PLSXCOB.LOG"
#define __PLSFL500 "PLSX500.LOG"


#define ndLinIni  008.0
#define ndColIni  010.3
#define ndLinFin  034.4
#define ndColFin  100.3
#define ntCodOpe  4
#define atCodOpe  {01,04}
#define atCodEmp  {05,04}    
#define atMatric  {09,06}
#define atTipReg  {15,02}    
#define atDigito  {17,01}    
#define __cPictUsr "@R !.!!!.!!!!.!!!!!!-!!"
#define __cPictFam "@R !.!!!.!!!!.!!!!!!"
#define __cNameBAU "Rede de Atendimento"
#define __cPictOpe "@R !.!!!"
#define __cPrefFot "F"
#define __aTipCri  { {"1","Contratual"},{"2","Financeira"} }
#define __cMsgAban "Abandona o registro ?"
#define __cMsgLOG   "Visualizar LOG"
#define __cBotLog "ANALITICO"
#define __aKeys    {{"F8",119},{"F9",120},{"F10",121},{"F11",122}}

#define __cPLSArqs "SX5BA0SI1SI7CTOBX4BQCBA1BA3BG9BI3BCTBT5BT6SE1BB8BAUBAWBAXBAQBB6BDTBJ4BAABR8BA9BR4BFGBFEBFCBT8BT7BG8BE2BF3BRWBBMBC0BBNBBFBHEBHDBB2BVMBVFBHGBGDBCWBHJBHCBEABIQBCIBCLBCMBCSBCQBD5BD6BD7BGYBD4BD3BZBBMEBMGBMCBC6BC5BMFBMDBMBBFMBASBC1DE0DE1BB0BSVBEDBF4SA1BE4BBKBVXBX1BFOBFJBA6BANBDLBBIBGHBH0BE9BRVBXEBXFBXGBCABG3BG7BEGBL0BAGBCKBS9BS0BG6BPIBF5BP8BARBNXBLWBLXBGLBGSBSWBD1BSOBSNBSABFNBDHBWWBIDBFDBMTBMQBGIBSXBC3BG1BYKBG2BF8BERBTSBSMBHIBDXBMIBMHBMMBML"
               
#command STORE HEADER <cA> TO <aH> [FOR <for>];
      => SX3->(dbSetOrder(1));SX3->(MsSeek(<cA>));<aH>:={};
         ;SX3->(DBEval({|| AaDd(<aH>,{trim(X3TITULO()),SX3->X3_CAMPO,;
          SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
          SX3->X3_TIPO,nil,SX3->X3_CONTEXT})},{ || PLSCHKNIV(<for>) },{|| SX3->X3_ARQUIVO==Upper(<cA>)},,,.F.))

#command STORE HEADER NOUSER <cA> TO <aH> [FOR <for>];
      => SX3->(dbSetOrder(1));SX3->(MsSeek(<cA>));<aH>:={};
         ;SX3->(DBEval({|| AaDd(<aH>,{trim(X3TITULO()),SX3->X3_CAMPO,;
          SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
          SX3->X3_TIPO,nil,SX3->X3_CONTEXT})},{ || PLSCHKNI2(<for>) },{|| SX3->X3_ARQUIVO==Upper(<cA>)},,,.F.))

#command STORE COLSNAME <cA> TO <aH> [FOR <for>];
      => SX3->(dbSetOrder(1));SX3->(MsSeek(<cA>));<aH>:={};
       ; SX3->(DBEval({|| AaDd(<aH>,{trim(X3TITULO()),SX3->X3_CAMPO,trim(SX3->X3_PICTURE),SX3->X3_CONTEXT})},<{for}>,{|| SX3->X3_ARQUIVO==Upper(<cA>)},,,.F.))

#command CREATE FIELDS TO <aC> FROM <aH> [WITH <flag:FLAG>]             ;
      => <aC>:={};aEval(<aH>,{|eH| AaDd(<aC>,{eH\[2\],eH\[8\],          ;
                                              eH\[4\],eH\[5\]})})       ;
      ;  Eval({|| Iif(<.flag.>,AaDd(<aC>,{"FLAG","L",1,0}),Nil)})

#command STORE COLS <cA> TO <aC>	FROM <aH>	[VETTRAB <aVet>]   		;
         [FOR <for>]                                                    ;
         [WHILE <while>]                                                ;
         [NEXT <next>]                                                  ;
         [RECORD <rec>]                                                 ;
         [<rest:REST>]                                                  ;
         [ALL]                                                          ;
      => cAO:=Alias();DbSelectArea(<cA>);<aC>:={}                       ;
      ;  DBEval({|| AaDd(<aC>,{}),aEval(<aH>,{|eH|                      ;
                    AaDd(<aC>\[len(<aC>)\],If(Empty(FieldPos(AllTrim(eH\[2\]))),CriaVar(AllTrim(eH\[2\])),FieldGet(FieldPos(AllTrim(eH\[2\])))))}),;
                    AaDd(<aC>\[len(<aC>)\],.f.), If(ValType(<aVet>)=="A",aadd(<aVet>,Recno()),nil) },;
                <{for}>, <{while}>, <next>, <rec>, <.rest.>);
		;	If(!Empty(cAO),DbSelectArea(cAO),DbSelectArea(<cA>))

#command STORE COLS TOPCONN <cA> TO <aC>	FROM <aH> VETTRAB <aVet> WHILE <cWhile> 	;
      => <aC>:={};PLSSQLCols(<aH>,<aC>,<cA>,<cWhile>,<aVet>)

#command STORE COLS AREA TO <aC>	FROM <aH> => Eval({|| AaDd(<aC>,{}),aEval(<aH>,{|eH|                        ;
                    AaDd(<aC>\[len(<aC>)\],If(Empty(FieldPos(AllTrim(eH\[2\]))),CriaVar(AllTrim(eH\[2\])),FieldGet(FieldPos(AllTrim(eH\[2\])))))}),;
                    AaDd(<aC>\[len(<aC>)\],.f.)})

/*/
#command STORE COLS BLANK <cA> TO <aC>	FROM <aH>										;
      => <aC>:={{}}                     													;
      ;  _nInd := 0 ;
      ;  aEval(<aH>,{|eH| AaDd(<aC>\[len(<aC>)\],CriaVar(AllTrim(eH\[2\])))})	;
      ;  AaDd(<aC>\[len(<aC>)\],.f.)
/*/
#command STORE COLS BLANK <cA> TO <aC>	FROM <aH>										;
      => <aC>:=PLSCOLSBL(<cA>,<aH>,<aC>)

#command STORE FIELDS <cA> TO <aH> [FOR <for>];
      => SX3->(dbSetOrder(1));SX3->(MsSeek(<cA>));<aH>:={};
       ; SX3->(DBEval({|| AaDd(<aH>,SX3->X3_CAMPO)},<{for}>,{|| SX3->X3_ARQUIVO==Upper(<cA>)},,,.F.))

#command COPY <cAC> TO MEMORY [<bl:BLANK>] => cAO:=Alias();DbSelectArea(<cAC>);
     ;For I__f:=1 To FCount();
     ;    M->&(Eval({|nCPO| Field(nCPO)},I__f)):=If(<.bl.>,CriaVar(Eval({|nCPO| Field(nCPO)},I__f),.T.),FieldGet(I__f));
     ;Next;
     ;If(!Empty(cAO),DbSelectArea(cAO),.t.);SX3->(DbSetOrder(1));SX3->(MsSeek(<cAC>));
	  ;SX3->(DBEval({|| M->&(Trim(SX3->X3_CAMPO)):=CriaVar(Trim(SX3->X3_CAMPO),.T.)},{|| SX3->X3_CONTEXT == "V"},{|| SX3->X3_ARQUIVO == <cAC>}))

#command SAVE <cAC> FROM MEMORY => cAO:=Alias();DbSelectArea(<cAC>);
     ;cCMD:=ScriptUpDate();
     ;TCSqlExec(cCMD);
     ;DbCommitAll();
     ;DbSelectArea(cAO)

#command STANDARD <oFlD> FONT <oFNT> => aEval(<oFlD>:aDialogs,{|eFolder| eFolder:oFont := <oFNT>})

#Translate BA8_CODAMB  => BA8_CODPRO   
#Translate TPLSBrw()  => TBRWPLS()

#command STORE COLSAUT <cA> TO <aC> FROM <aH>	[VETTRAB <aVet>] ;
         [Condicao <cCond>]                                      ;
         [Chave <ckey>]                                          ;
         [Forc <cfor>]                                           ;
      => cAO:=Alias();DbSelectArea(<cA>);<aC>:={}             ;
         ; PrepareCols(<aH>,<aC>,<cA>,<cCond>,<ckey>,<cfor>,<aVet>)  ;
		 ; DbSelectArea(cAO)         
		 
		 
//
