#INCLUDE "Eicrd152.ch"
//#INCLUDE "FiveWin.ch"
#include "AVERAGE.CH"
#INCLUDE "AvPrint.ch"
#COMMAND E_RESET_AREA => SW6->(DBSETORDER(1)) ; SY9->(DBSETORDER(1)) ;
                       ; Work->(E_EraseArq(FileWork)) ;
                       ; DBSELECTAREA(nOldArea) ; Return .F.
#COMMAND  SKIPLOOP => DBSKIP() ; LOOP
#DEFINE  Desembaraco    "1"
#DEFINE  Embarque       "2"
#DEFINE  OUTRA_MOEDA  TRANS(MFob_Moe,'@E 999,999,999.99')      
#DEFINE  DESP_OUT_MOE  TRANS(MTotOutDesp,'@E 999,999,999.99')      
/*

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICRD150 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 24.10.96 ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rela‡Æo de Desembara‡os                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICRD150()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                 
Function EICRD150
RETURN RD152(Desembaraco,STR0001) //"Relacao de Desembaracos"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICRD151 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 29.09.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rela‡Æo de Embarques                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICRD151()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICRD151
RETURN RD152(Embarque,STR0002) //"Relacao de Embarques"

*-----------------------------*
FUNCTION RD152(MPARA,cCADASTRO)
*-----------------------------*
LOCAL nOldArea:=SELECT()

LOCAL cTitulo, oGet, MTamanho:=0, lValid, nPos:=0

LOCAL aValid:={"Imp","Con","Desp","Local","Dt"}
LOCAL _LIT_R_CC := IF(EMPTY(EasyGParam("MV_LITRCC")),(AVSX3("W0__CC")[5]), ALLTRIM(EasyGParam("MV_LITRCC")))
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL oPanel
Local aButtons  := {}
 
LOCAL bValid:={||lValid:=.T.,;
                 AEval(aValid,{|campo| If(lValid,lValid:=RD152Val(campo),)}),;
                 lValid}
PRIVATE oDlg
PRIVATE TB_Campos:={}
PRIVATE cTitulos //LRS - 6/11/2013 - titulo excel
PRIVATE T_DBF:= { {"WKPO_NUM","C",AvSx3("W2_PO_NUM", AV_TAMANHO),0}   , {"WKCOD_I" ,"C",AVSX3("W3_COD_I",3),0} ,;
                {"WKFABR","C",AVSX3("A2_COD",3)/*6*/,0}, {"WKFORN","C",AVSX3("A2_COD",3)/*6*/,0}    ,;    // GFP - 22/10/2012
                {"WKPRECO","N",15,2}    , {"WKHAWB","C",AVSX3("W7_HAWB",AV_TAMANHO),0}   ,;
                {"WKDT_CHEG","D",8,0}   , {"WKAGENTE","C",AVSX3("W6_AGENTE",AV_TAMANHO),0}  ,;
                {"WKDTRECDOC","D",8,0}  , {"WKDESP","C", AVSX3("W6_DESP",AV_TAMANHO),0}    ,;
                {"WKDIDT","D",8,0}      , {"WKNF_ENT","C",20,0} ,;
                {"WKNUM_DI",AVSX3("W6_DI_NUM",2),AVSX3("W6_DI_NUM",3),0}    , {"WKDT_ENTR","D",8,0} ,;
                {"WKDT_DESEN","D",8,0}  , {"WKMOEDA","C",3,0}   ,;
                {"WKPRECO_US","N",15,2} , {"WKDT_EMB","D",8,0}  ,;
                {"WKCONSIG","C",2,0}    , {"WKIMPORT","C",2,0}  ,;
                {"WKLOCAL","C",3,0}     , {"WKCC","C",5,0}      ,; 
                {"WKOUTDESP","N",15,2 } , {"WKOUTBDESP","N",15,2} }   // 18/05/2000 Sidney - Inclusao do campo WKOUTDESP- Outras Despesas    
                
PRIVATE aTitulos := {{"Nr. P.O.","C","",""}   	   		,{"Item","C","",""}				,;
					{"Fabr.","C","",""}		  			,{"Forn.","C","",""}			,;
					{"Valor na Moeda","N","",""}  		,{"Nr. Processo","C","",""}		,;
					{"Atracado","D","",""}		  		,{"Agente.","C","",""}			,;
					{"Recb. Doc.","D","",""}	   		,{"Despachante","C","",""}		,;
					{"Pagto.","D","",""}		   		,{"Nr. Nota Fiscal","C","",""}	,;
					{"Nr. da D.I.","C","",""} 	   		,{"Entrega","D","",""}			,;
					{"Desembaraço","D","",""} 			,{"Moeda","C","",""}			,;
					{"Valor US$ no Incoterm","N","",""}	,{"Embarque","D","",""}			,;
					{"Con.","C","",""} 					,{"Imp.","C","",""}				,;
					{"Local","C","",""}					,{_LIT_R_CC,"C","",""}			,;
					{"Outras Despesas","N","",""}		,{"Outras Despesas B","N","",""}  				}  //LRS - 6/11/2013 - Titulos colonas Excel

If EICLOJA() .And. (nPos := aScan(T_DBF, {|x| x[1] == "WKFABR" })) > 0
   aAdd(T_DBF, Nil)
   aAdd(aTitulos,Nil)// LRS
   aIns(T_DBF, nPos + 1)
   aIns(aTitulos, nPos +1) //LRS
   T_DBF[nPos+1] := {"WKFABLOJ", "C", AvSx3("W7_FABLOJ", AV_TAMANHO),0}
   aTitulos[nPos+1] := {"Loja Fabr.","C","",""}//LRS
EndIf

If EICLOJA() .And. (nPos := aScan(T_DBF, {|x| x[1] == "WKFORN" })) > 0
   aAdd(T_DBF, Nil)
   aAdd(aTitulos,Nil)  //LRS
   aIns(T_DBF, nPos + 1)
   aIns(aTitulos, nPos +1)//LRS
   T_DBF[nPos+1] := {"WKFORLOJ", "C", AvSx3("W7_FORLOJ", AV_TAMANHO),0}
   aTitulos[nPos+1] :={"Forn. Fabr.","C","",""}//LRS
EndIf

If EasyEntryPoint("EICRD152")
    ExecBlock("EICRD152", .F., .F., "STRU_WORK")
EndIf

lEmail:= .F.
//ConOut(TYPE("__cInternet"))
IF TYPE("__cInternet") # "U" .AND. __cInternet # NIL
   //ConOut(__cInternet) Vem escrito AUTOMATICO
   lEmail:= .T.
   E_Init()
ENDIF

PRIVATE aHeader[0],nUsado:=0, MPos,cPARA:=MPara
//PRIVATE cArqF3SY5:="SY5"
//PRIVATE cArqF3SY9:="EY9"
//PRIVATE cArqF3SYT:="SYT"

PRIVATE nPIC := LEN(STRTRAN(ALLTRIM(TRANS("",AVSX3("W6_DI_NUM",6)))," ",""))//ASR 27/01/2006 - GUARDA O TAMANHO DA PICTURE SEM OS ESPEÇOS EM BRANCO
PRIVATE TImport:=SPACE(02), TConsig:=SPACE(02)
PRIVATE TDesp  :=SPACE(03), TClass :=0, TLocal :=SPACE(LEN(SW6->W6_LOCAL))
PRIVATE TDTI   :=dDataBase, TDTF   :=dDataBase, nOpcA:=0
PRIVATE nCol01 := 001
PRIVATE nCol02 := IF(CPAISLOC="BRA",AVSX3("W6_DI_NUM",3)+nPIC,AVSX3("W6_DI_NUM",3))  //ASR 27/01/2006 - BUSCO DO DICIONARIO PORQUE ESTE CAMPO DIFERE SEU TAMANHO (BRASIL/ARGENTINA) - PRIVATE nCol02 := 014
PRIVATE nCol03 := 027
PRIVATE nCol04 := 038
PRIVATE nCol05 := 049
PRIVATE nCol06 := 066
PRIVATE nCol07 := 070
PRIVATE nCol08 := 081
PRIVATE nCol09 := 093
PRIVATE nCol10 := 107
PRIVATE nCol11 := 124
PRIVATE nCol12 := 141
PRIVATE nCol13 := 158 //128+MTamanho+10
PRIVATE nCol14 := 175 //128+MTamanho+33
PRIVATE nCol15 := 192 //128+MTamanho+48
PRIVATE nCol16 := 198 //128+MTamanho+56
PRIVATE nCol17 := 214 //128+MTamanho+75
PRIVATE nCol18 := 219 //128+MTamanho+79
PRIVATE cMoeDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")
Private _PictPrUn := ALLTRIM(X3Picture("W3_PRECO")), _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))
Private _FirstYear:= Right(Padl(Set(_SET_EPOCH),4,"0"),2)

FileWork := E_CriaTrab(,T_DBF,"Work") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

IF ! USED()
   Help("", 1, "AVG0000451")//"NÆo h   rea dispon¡vel para abertura do Cadastro de Work"###"Atenção"
   Return .F.
ENDIF

IF (MTamanho:=LEN(Work->WKPO_NUM)) < 8
   MTamanho:=8
ENDIF

IF MPara == Desembaraco
   IndRegua("Work",FileWork+TEOrdBagExt(),"DTOS(WKDT_DESEN)+WKHAWB+WKPO_NUM")
   DBSELECTAREA("SW6")
   DBSETORDER(2)
ELSE
   IndRegua("Work",FileWork+TEOrdBagExt(),"DTOS(WKDT_EMB) + WKHAWB + WKPO_NUM")
   DBSELECTAREA("SW6")
   DBSETORDER(3)
ENDIF

MPos:=FIELDPOS(IF(MPara==Desembaraco,"W6_DT_DESE","W6_DT_EMB"))

SY9->(DBSETORDER(2))

IF MPara==Desembaraco     
   AADD(TB_Campos,{"WKDT_DESEN","",STR0008}) //"Desembaraco"
   cTitulos := "Impressão EXCEL - Desembaraço"//LRS
Else                                                          
   AADD(TB_Campos,{"WKDT_EMB"  ,"",STR0009}) //"Embarque"
   cTitulos := "Impressão EXCEL - Embarque"//LRS
Endif

AADD(TB_Campos,{"WKPO_NUM"  ,"", STR0010,_PictPo}) //"Nr. P.O."
AADD(TB_Campos,{"WKCOD_I"   ,"", STR0011,_PictItem}) //"Item"
AADD(TB_Campos,{"WKFABR"    ,"", STR0012}) //"Fabr."

If EICLoja()
   AADD(TB_Campos,{"WKFABLOJ"    ,"", "Loja Fabr."})
EndIf
AADD(TB_Campos,{"WKFORN"    ,"", STR0013}) //"Forn." 
If EICLoja()
   AADD(TB_Campos,{"WKFORLOJ"    ,"", "Loja Forn."})
EndIf
AADD(TB_Campos,{"WKMOEDA"   ,"", STR0014}) //"Moeda"
AADD(TB_Campos,{"WKPRECO"   ,"", STR0015,_PictPrUn}) //"Valor na Moeda"
AADD(TB_Campos,{"WKPRECO_US","", STR0016,_PictPrUn}) //28/10/08 - CCH - Valor US$ no Incoterm (Antigo = //"Valor FOB US$")
AADD(TB_Campos,{"WKHAWB"    ,"", STR0017}) //"Nr. Processo"              
AADD(TB_Campos,{"WKDT_CHEG" ,"", STR0018}) //"Atracado"
AADD(TB_Campos,{{||WKAGENTE+' '+BuscaAgente(WKAGENTE)},"",STR0019}) //"Agente"
AADD(TB_Campos,{"WKDTRECDOC","", STR0020}) //"Recb. Doc."
AADD(TB_Campos,{{||WKDESP+' '+BuscaDesp(WKDESP)},"", STR0021}) //"Despachante"
AADD(TB_Campos,{"WKDIDT"    ,"", STR0022}) //"Pagto."
AADD(TB_Campos,{"WKNF_ENT"  ,"",STR0023}) //"Nr. Nota Fiscal"
AADD(TB_Campos,{"WKNUM_DI"  ,"",STR0024,E_Tran("W6_DI_NUM",,.T.)}) //"Nr. da D.I."   

IF MPara==Embarque
   AADD(TB_Campos,{"WKDT_EMB","",STR0009}) //"Embarque"
Else   
   AADD(TB_Campos,{"WKDT_DESEN","",STR0008}) //"Desembaraco"
Endif   

AADD(TB_Campos,{"WKDT_ENTR" ,"", STR0025}) //"Entrega"
AADD(TB_Campos,{"WKLOCAL"   ,"", STR0026}) //"Local"
AADD(TB_Campos,{"WKIMPORT"  ,"", STR0027}) //"Imp."
AADD(TB_Campos,{"WKCONSIG"  ,"", STR0028}) //"Con."
AADD(TB_Campos,{"WKCC"      ,"", _LIT_R_CC})

If EasyEntryPoint("EICPRD01")
    ExecBlock("EICPRD01", .F., .F., "CRIAR_CAMPO")
EndIf

If EasyEntryPoint("EICRD152")
    ExecBlock("EICRD152", .F., .F., "CRIAR_CAMPO")
EndIf

aCamposTRB:=E_CriaRCampos(Tb_Campos)
aCamposTRB[11,1]:="WKAGENTE+' '+BuscaAgente(WKAGENTE)"
aCamposTRB[13,1]:="WKDESP+' '+BuscaDesp(WKDESP)"

wnrel  := "EICRD152"
aReturn:= { "Zebrado", 1,"Importacao", 2, 2, 1, "",0 }
cDesc1 := "Impressao do Relatorio "+cCadastro

DO WHILE .T.
  IF MPara == Desembaraco
     IF !Pergunte("EIC152",IF(lEmail,.F.,.T.),cCadastro) .AND. !lEmail// AWR 
        E_RESET_AREA
     ENDIF
     cCadastro := STR0001+space(2)+"-"+space(2)+IF( mv_par01 == 2,ALLTRIM(STR0086),ALLTRIM(STR0089) )//"Relação de " ###"Não Desembaraçados"###"Desembaraçados"    //NCF-12/05/09 - Separação de títulos
//   If !Pergunte("EIC152")
//      E_RESET_AREA
//   Endif
     IF lEMail      //AWR
        wnrel  := SetPrint("WORK",wnrel,"EIC152",cCadastro,cDesc1,"","",.F.,,.T.,"G")
     ENDIF
     TClass :=mv_par01
     TImport:=mv_par02
     TConsig:=mv_par03
     TDesp  :=mv_par04
     TLocal :=mv_par05
     TDTI   :=mv_par06
     TDTF   :=mv_par07
     IF !RD152Val("DATA152")        
        IF lEmail
           E_RESET_AREA
        ENDIF   
        LOOP 
     ENDIF
  Else
     TClass := 1
     IF !Pergunte("EICR51",IF(lEmail,.F.,.T.),cCadastro) .AND. !lEmail// AWR 
        E_RESET_AREA
     ENDIF
     IF lEMail      //AWR
        wnrel  := SetPrint("WORK",wnrel,"EIC152",cCadastro,cDesc1,"","",.F.,,.T.,"G")
     ENDIF
  
     TImport:=mv_par01
     TConsig:=mv_par02
     TDTI   :=mv_par03
     TDTF   :=mv_par04
     IF !RD152Val("DATAR51")
        IF lEmail
           E_RESET_AREA
        ENDIF   
        LOOP 
     ENDIF
  ENDIF
 
  DBSELECTAREA("SW6")

  nOpca:=0  
/*
  DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 23,40 OF oMAINWND

   nLin:=1.4 ; nColS:=0.8 ; nColG:=6.0
   
   @ nLin++,nColS SAY STR0029 //"Importador"
   @ nLin++,nColS SAY OemToAnsi(STR0030) //"Consignat rio"

   IF MPara == Desembaraco
      @ nLin++,nColS SAY STR0021 //"Despachante"
      @ nLin++,nColS SAY STR0026 //"Local"
   ENDIF

   IF TClass = 1
      @ nLin++,nColS SAY STR0031 //"Data Inicial"
      @ nLin++,nColS SAY STR0032 //"Data Final"
   ELSE
      SW6->(DBSEEK(xFilial()))
   ENDIF

   nLin:=1.4
   
   @ nLin++,nColG MSGET TImport F3 cArqF3SYT VALID RD152Val("Imp")
   @ nLin++,nColG MSGET TConsig F3 cArqF3SYT VALID RD152Val("Con")

   IF MPara == Desembaraco
      @ nLin++,nColG MSGET TDesp  F3 cArqF3SY5 VALID RD152Val("Desp") 
      @ nLin++,nColG MSGET TLocal F3 cArqF3SY9 VALID RD152Val("Local")
   ENDIF

   IF TClass = 1
      @ nLin++,nColG MSGET TDTI
      @ nLin  ,nColG MSGET TDTF   VALID RD152Val("Dt")
   ENDIF
   
   If EasyEntryPoint("EICPRD01")
      ExecBlock("EICPRD01", .F., .F., "PARAMETROS")
   EndIf
   If EasyEntryPoint("EICRD152")
      ExecBlock("EICRD152", .F., .F., "PARAMETROS")
   EndIf

  ACTIVATE MSDIALOG oDlg ON INIT ;
           EnchoiceBar(oDlg,{||nOpca:=1,If(EVAL(bValid),oDlg:End(),)},;
                            {||nOpca:=0,oDlg:End()}) CENTERED
  If nOpca = 0
     IF MPara == Embarque
        E_RESET_AREA
     ENDIF
     LOOP
  Endif
*/
  lInterrompe:=.T.

  IF lEmail
     RD152Grava(MPARA)
  ELSE
     Processa({|| RD152Grava(MPARA)},STR0033)//"Pesquisa de Embarques/Desembara‡os"
  ENDIF

  IF Work->(Easyreccount("Work")) > 0

     IF lEmail
        RD152Print(cCADASTRO,MPARA)
        E_RESET_AREA
     ENDIF
     
     nOpca:=0  
     oMainWnd:ReadClientCoors()

     AAdd(aButtons, {"Imprimir"  ,{|| Processa({|| RD152Print(cCADASTRO,MPARA)},STR0091)}, "Imprimir", "Imprimir"}) //"Imprimir" //"Processando"       
     AAdd(aButtons, {"Excel"  , {|| Processa({|| TR350Arquivo("WORK",,aTitulos,cTitulos)},STR0090)}, "Excel", "Excel"}) ////"Excel" //"Exportar para Excel" 

     DEFINE MSDIALOG oDlg TITLE cCadastro ;
        FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;     
  	    OF oMainWnd PIXEL  
  	   
  	   @ 00,00 MSPanel oPanel Size 20,45 of oDlg
  	    
       IF(EasyEntryPoint("EICRD152"),ExecBlock("EICRD152",.F.,.F.,"DENTRO_JANELA"),) 

       oMark:= MsSelect():New("Work",,,TB_Campos,.F.,"",{34,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
	         
	   oPanel:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT 
       oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      oDlg:lMaximized := .T.
     ACTIVATE MSDIALOG oDlg ON INIT ;
             ( EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()}, ,aButtons)) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
     If nOpca = 0
        E_RESET_AREA
     Endif

  ENDIF

ENDDO
*----------------------------------------------------------------------------
FUNCTION RD152Val(cQual)   
*----------------------------------------------------------------------------
LOCAL cCampo:=READVAR()
Do Case
   Case cQual="Imp"
        TImport:=&(cCampo)
        IF EMPTY( TImport )
           Return .T.
        ENDIF
          
        IF ! EMPTY(TImport) .And. ! SYT->(DBSEEK(xFilial()+TImport))
           Help("", 1, "AVG0000455")//"Importador não cadastrado"###"Informação"
           Return .F.
        ElseIf SYT->YT_IMP_CON # "1"
           Help("", 1, "AVG0000513")//"C¢digo nÆo se refere a Importador"###"Informação"
           Return .F.
        Endif
        
   Case cQual="Con"
        TConsig:=&(cCampo)
        IF EMPTY( TConsig )
           Return .T.
        ENDIF
        IF ! EMPTY(TConsig) .And. ! SYT->(DBSEEK(xFilial()+TConsig))
           Help("", 1, "AVG0000514")//"Consignat rio nÆo cadastrado"###"Informação"
           Return .F.
        Endif
                 
        IF SYT->YT_IMP_CON # "2"
           Help("", 1, "AVG0000515")//"C¢digo nÆo se refere a Consignat rio"###"Informação"
           Return .F.
        Endif
/*      
   Case cQual = "Desp"
   
        IF ! EMPTY(TDesp) .And. ! SY5->(DBSEEK(xFilial()+TDesp))
           Help("", 1, "AVG0000516")//"Despachante não cadastrado"###"Informação"
           Return .F.
        Endif

   Case cQual = "Local"

        SY9->(DBSETORDER(2))
        IF ! EMPTY(TLocal) .And. !SY9->(DBSEEK(xFilial()+ALLTRIM(TLocal)))
           Help("", 1, "AVG0000517")//"Local não cadastrado"###"Informação"
           Return .F.
        Endif
*/
   Case cQual = "DATAR51"
        IF !Empty(MV_PAR03) .AND. MV_PAR04 < MV_PAR03
           IF lEMail
              ConOut("EICRD152: Datas Invalidas no Relatorio: "+cCADASTRO)
           ELSE
               Help("", 1, "AVG0000518")//"Data Final menor que a inicial"###"Atenção"
           ENDIF
           Return .F.
        Endif

       //MPara==Desembaraco,"W6_DT_DESE","W6_DT_EMB"))
 
        SW6->(DBSETORDER(3))
        SW6->(DBSEEK(xFilial()+DTOS(IF(EMPTY(MV_PAR03),AVCTOD("01/01/"+_FirstYear),MV_PAR03)),.T.))
   
        IF SW6->(EOF()) .OR. (!EMPTY(MV_PAR04) .AND. SW6->W6_DT_EMB > MV_PAR04)
           IF lEMail
              ConOut("EICRD152: Nao possui Registros, Relatorio: "+cCADASTRO)
           ELSE
              Help("", 1, "AVG0000519")//MsgInfo(STR0046,STR0006)
           ENDIF
        Endif
   
   Case cQual = "DATA152" .AND. MV_PAR01 = 1
        IF !Empty(MV_PAR06) .AND. MV_PAR07 < MV_PAR06
           IF lEMail
              ConOut("EICRD152: Datas Invalidas no Relatorio: "+cCADASTRO)
           ELSE
              Help("", 1, "AVG0000518")//"Data Final menor que a inicial"###"Atenção"
           ENDIF
           Return .F.
        Endif

       //MPara==Desembaraco,"W6_DT_DESE","W6_DT_EMB"))
 
        SW6->(DBSETORDER(2))
        SW6->(DBSEEK(xFilial()+DTOS(IF(EMPTY(MV_PAR06),AVCTOD("01/01/"+_FirstYear),MV_PAR06)),.T.))
   
        IF SW6->(EOF()) .OR. (!EMPTY(MV_PAR07) .AND. SW6->W6_DT_DESE > MV_PAR07)
           IF lEMail
              ConOut("EICRD152: Nao possui Registros, Relatorio: "+cCADASTRO)
           ELSE
              Help("", 1, "AVG0000519")//MsgInfo(STR0046,STR0006)
           ENDIF
        Endif

EndCase                          
                          
Return .T.
*----------------------------------------------------------------------------
FUNCTION RD152Grava(MPARA)
*----------------------------------------------------------------------------
local nPrecoTot:=0
local nCont:=0

Private nTot_Desp_SW8 := 0 // JBS - 13/07/2004
Private nTx_Fob_SW9   := 0 // JBS - 13/07/2004

IF !lEmail
   ProcRegua(20)
ENDIF

SW7->(DBSETORDER(1))

DBSELECTAREA("Work")
AvZap()
DBSELECTAREA("SW6")
IF MPara==Desembaraco
   SW6->(DBSETORDER(2))
ELSE
   SW6->(DBSETORDER(3))
ENDIF

IF TClass = 1
   SW6->(DBSEEK(xFilial()+DTOS(IF(EMPTY(TDtI),AVCTOD("01/01/"+_FirstYear),TDtI)),.T.))
ELSE
   SW6->(DBSEEK(xFilial()))
ENDIF

// BAK - Alteração apontando para a alias SW6 - 02/08/2011
DO WHILE SW6->(!EOF() .AND. W6_FILIAL = xFilial("SW6"))

   IF !lEmail
      IncProc(STR0043+ALLTRIM(SW6->W6_HAWB)) //"Pesquisando Processo: "
      nCont++
      IF nCont > 20
         ProcRegua(20)
      ENDIF
   ENDIF

   IF TClass = 1
   
      IF !EMPTY(TDTF) .AND. FIELDGET(MPos) > TDTF
         EXIT
      ENDIF
   ELSE
      IF !EMPTY(FIELDGET(MPos))
         EXIT
      ENDIF
   ENDIF

   IF ! EMPTY(TLocal) .AND. SW6->W6_LOCAL # TLocal
      SKIPLOOP
   ENDIF

   IF ! EMPTY(TDesp) .AND. SW6->W6_DESP # TDesp
      SKIPLOOP
   ENDIF

   IF !SW7->(DBSEEK(XFILIAL("SW7")+SW6->W6_HAWB))
      Help("", 1, "AVG0000520",,SW6->W6_HAWB+STR0045,1,14)//"Nr. Processo "###" sem itens no arquivo (SW7)"###"Atenção"
      SKIPLOOP
   ENDIF

   DO WHILE ! SW7->(EOF()) .AND. W6_HAWB == SW7->W7_HAWB .AND.;
                       xFilial("SW7") == SW7->W7_FILIAL
      IF MPara == Desembaraco
         IF SW7->W7_FLUXO = "4"
            SW7->(DBSKIP()) ; LOOP
         ENDIF
      ELSE
         IF SW7->W7_FLUXO = "5"
            SW7->(DBSKIP()) ; LOOP
         ENDIF
      ENDIF

      IF ! SW2->(DBSEEK(XFILIAL()+SW7->W7_PO_NUM))
         Help("", 1, "AVG0000521",,SW7->W7_PO_NUM,1,26)//"ATEN€ÇO Arquivo de Pedidos (SW2) desbalanceado - PO. No. "###" "Atenção"
         SW7->(DBSKIP()) ; LOOP
      ENDIF

      IF ! EMPTY(TImport) .AND. SW2->W2_IMPORT # TImport 
         SW7->( DBSKIP() ) ; LOOP
      ENDIF

      IF ! EMPTY(TConsig) .AND. SW2->W2_CONSIG # TConsig 
         SW7->( DBSKIP() ) ; LOOP
      ENDIF

      MFob_US:= SW7->W7_PRECO  * SW7->W7_QTDE
      
      nTot_Desp_SW8 := 0  // JBS - 13/07/2004 - Inicio
      RD152SomaPO()       // Busca o Valor das despesas no SW8 e a Tx da Moeda no SW9  
      mTotDp_US  := nTot_Desp_SW8 

      If nTx_Fob_SW9 == 0
         If MPara==Desembaraco
            nTx_Fob_SW9 := BuscaTaxa(SW2->W2_MOEDA,SW6->W6_DT_DESE,.T.,.F.,.T.)
         Else
            nTx_Fob_SW9 := BuscaTaxa(SW2->W2_MOEDA,SW6->W6_DT_EMB,.T.,.F.,.T.)            
         EndIf
      EndIF // JBS 13/07/2004 - Fim

      IF SW2->W2_MOEDA <> cMoeDolar
         IF SW2->W2_MOEDA # "R$"
            nPrecoTot := (SW7->W7_PRECO * SW7->W7_QTDE) * nTx_Fob_SW9 // JBS - 13/07/2004  -> Usando a Tx Retornada do W9_TX_FOB
            nTDp      := mTotDp_US * nTx_Fob_SW9                      //                   -> Se ñ estiver preenchido no SW9 traz do
                                                                      //                   -> Buscataxa.
         ELSE
            nPrecoTot := (SW7->W7_PRECO * SW7->W7_QTDE)
            nTDp      := mTotDp_US
         ENDIF   
         IF !EMPTY(SW6->W6_TX_US_D)
            MFob_Us:= (nPrecoTot / SW6->W6_TX_US_D)
            MTotDp_US:=(nTDp     / SW6->W6_TX_US_D)
         ELSE
            MFob_Us:= CalcFob_Us(SW7->W7_PRECO,SW7->W7_QTDE)
            MTotDp_US:=CalcFob_Us(mTotDp_US,1)
         ENDIF   
      ENDIF

      Work->(DBAPPEND())
      Work->WKPO_NUM    :=  SW7->W7_PO_NUM
      Work->WKCOD_I     :=  SW7->W7_COD_I
      Work->WKCC        :=  SW7->W7_CC
      Work->WKFABR      :=  SW7->W7_FABR
      Work->WKFORN      :=  SW7->W7_FORN
      Work->WKPRECO     :=  SW7->W7_PRECO  * SW7->W7_QTDE
      Work->WKPRECO_US  :=  MFob_Us
      Work->WKNUM_DI    :=  SW6->W6_DI_NUM
      Work->WKDT_ENTR   :=  SW6->W6_DT_ENTR
      Work->WKHAWB      :=  SW6->W6_HAWB
      Work->WKDT_CHEG   :=  SW6->W6_CHEG
      Work->WKAGENTE    :=  SW6->W6_AGENTE
//      Work->WKDTRECDOC  :=  SW6->W6_DTRECDOC
      Work->WKDTRECDOC  :=  SW6->W6_DTRECDO  // BAK - Correção do campo - 02/08/2011
      Work->WKDESP      :=  SW6->W6_DESP
      Work->WKDIDT      :=  SW6->W6_DT
      Work->WKNF_ENT    :=  SW6->W6_NF_ENT
      Work->WKMOEDA     :=  SW2->W2_MOEDA
      Work->WKIMPORT    :=  SW2->W2_IMPORT 
      Work->WKCONSIG    :=  SW2->W2_CONSIG 
//      Work->WKDT_DESEN  :=  SW6->W6_DT_DESEM
      Work->WKDT_DESEN  :=  SW6->W6_DT_DESE // BAK - Correção do campo - 02/08/2011
      Work->WKDT_EMB    :=  SW6->W6_DT_EMB
      Work->WKLOCAL     :=  SW6->W6_LOCAL
      
      If EICLoja()
         Work->WKFABLOJ:= SW7->W7_FABLOJ
         Work->WKFORLOJ:= SW7->W7_FORLOJ
      EndIf
      
      ** / Outras despesas // 18/05/2000 Sidney
      Work->WKOUTDESP   := nTot_Desp_SW8 // JBS - 08/07/2004
      Work->WKOUTBDESP  := mTotDp_US
      
      If EasyEntryPoint("EICPRD01")
          ExecBlock("EICPRD01", .F., .F., "GRAVA_CAMPO")
      EndIf
      

      If EasyEntryPoint("EICRD152")
          ExecBlock("EICRD152", .F., .F., "GRAVA_CAMPO")
      EndIf

      SW7->(DBSKIP())
   ENDDO

   DBSKIP()
END

DBSELECTAREA("Work")

DBGOTOP()

IF EOF() .AND. BOF()
   IF lEMail
      ConOut("EICRD152: Nao possui Registros, Relatorio: "+cCADASTRO)
   ELSE
      Help("", 1, "AVG0000522")//"Não existem registros a serem processados"###"Informação"
   ENDIF
   Return .F.
ENDIF

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RD152Print ³ Autor ³ ROBSON/AVERAGE        ³ Data ³ 30.06.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Impressao                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
FUNCTION RD152Print(cCADASTRO,MPARA)
LOCAL cDesc2   := " "
LOCAL cDesc3   := " "
LOCAL cString  := "Work"
LOCAL cRegAnt  := Recno()

PRIVATE tamanho :="G"
PRIVATE limite  :=220
PRIVATE Titulo  :=cCadastro
PRIVATE nomeprog:="EICRD152",nLastKey := 0,nBegin:=0,aLinha:={ }
PRIVATE aDriver :=ReadDriver()
PRIVATE cPerg   :=NIL

IF !lEMail
   wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)
ENDIF

If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Set Filter to
   Return
Endif

RptStatus({|lEnd| RelRD152(@lEnd,wnRel,cString,tamanho,limite,MPARA)},Titulo)

Return

*--------------------------------------------------------------------*
FUNCTION RelRD152(lEnd,wnRel,cString,tamanho,limite,MPARA)
*--------------------------------------------------------------------*

LOCAL OldRecno := Work->(RECNO())
LOCAL nEspaco  := 01    // JBS - 08/07/2004

PRIVATE nCol01 := 001  // JBS - 08/07/2004
PRIVATE nCol02 := nCol01 + nEspaco + 08  // JBS - 08/07/2004
PRIVATE nCol03 := nCol02 + nEspaco + IF(CPAISLOC="BRA",AVSX3("W6_DI_NUM",3)+nPIC,AVSX3("W6_DI_NUM",3))  // JBS - 08/07/2004 //ASR 27/01/2006 - BUSCO DO DICIONARIO PORQUE ESTE CAMPO DIFERE SEU TAMANHO (BRASIL/ARGENTINA) - PRIVATE nCol03 := nCol02 + nEspaco + 12
PRIVATE nCol04 := nCol03 + nEspaco + 08  // JBS - 08/07/2004
PRIVATE nCol05 := nCol04 + nEspaco + 08  // JBS - 08/07/2004
PRIVATE nCol06 := nCol05 + nEspaco + 15  // JBS - 08/07/2004
PRIVATE nCol07 := nCol06 + nEspaco + 05  // JBS - 08/07/2004 //NCF - 12/05/09 - Aumento da coluna de "03" para "05"
PRIVATE nCol08 := nCol07 + nEspaco + 08  // JBS - 08/07/2004
PRIVATE nCol09 := nCol08 + nEspaco + 08  // JBS - 08/07/2004
PRIVATE nCol10 := nCol09 + nEspaco + 10  // JBS - 08/07/2004
PRIVATE nCol11 := nCol10 + nEspaco + 18  // JBS - 08/07/2004
PRIVATE nCol12 := nCol11 + nEspaco + 15  // JBS - 08/07/2004
PRIVATE nCol13 := nCol12 + nEspaco + 17  // JBS - 08/07/2004
PRIVATE nCol14 := nCol13 + nEspaco + 15  // JBS - 08/07/2004
PRIVATE nCol15 := nCol14 + nEspaco + 17  // JBS - 08/07/2004
PRIVATE nCol16 := nCol15 + nEspaco + 05  // JBS - 08/07/2004
PRIVATE nCol19 := nCol16 + nEspaco + 16  // JBS - 08/07/2004
PRIVATE nCol17 := nCol19 + nEspaco + 14  // JBS - 08/07/2004
PRIVATE nCol18 := nCol17 + nEspaco + 05  // JBS - 08/07/2004

Work->(DBGOTOP())

M_Pag:=1
limite := 130;li:= 80

MLin     := 99
MPag     := 00
MTot_Us  := 00
MTot_Moe := 00
MTot_Ger_Fob := 00
MTot_Ger_Desp:= 00
MTot_Ger := 00
MConta   := 0

SetRegua(Work->(Easyreccount("Work")))
            
DO WHILE !Work->(EOF())

   IF MLin > 55
      RD152Cab(MPARA)
   ENDIF
   
   MHawb       := Work->WKHAWB
   MTotHawb_US := 0
   MTotHawb_Moe:= 0

   MTotOutDesp := 0 // Outras Despesas
   MTotOutbDesp := 0

   MFob_USD:= 0
   MFob_Moe:= 0
   MNro_PO := Work->WKPO_NUM
   MNro_Fo := Work->WKFORN + EICRetLoja("Work","WKFORLOJ")
   MPri    := .T.
   
   MLin ++
   @ Mlin,1 PSAY STR0051+Work->WKHAWB    //Processo:
   MLin ++
   RD152Det(MPARA)


   MMoeda := Work->WKMOEDA    
   MImport:= Work->WKIMPORT
   MConsig:= Work->WKCONSIG
   MConta ++

   DO WHILE !Work->(EOF()) .AND. Work->WKHAWB == MHawb  

      IF MLin > 55 .AND. !MPri
         RD152Cab(MPARA)
         MLin += 1
      ENDIF
      
	  IF Work->WKPO_NUM <> MNro_PO

         MPri:= .F.
         @ Mlin,nCol12   PSAY TRANS(MNro_PO,_PictPO)
         @ MLin,nCol13   PSAY LEFT(BuscaFabr_Forn(MNro_Fo),15)
         @ MLin,nCol14   PSAY TRAN(MFob_USD,'@E 999,999,999.99')

         MNro_PO := Work->WKPO_NUM
         MNro_Fo := Work->WKFORN + EICRetLoja("Work","WKFORLOJ")

         @ Mlin,nCol15   PSAY MMoeda
         @ Mlin,nCol16   PSAY OUTRA_MOEDA   //Vide diretiva define
         @ Mlin,nCol19   PSAY DESP_OUT_MOE  //Vide diretiva define
         @ MLin,nCol17   PSAY MIMPORT       
         @ MLin,nCol18   PSAY MCONSIG       
         MTotOutDesp := 0
      
         MTot_Ger_Fob += MFob_USD 
         MTot_Ger     += MFob_USD 

         MFob_USD    := 0 
         MFob_Moe    := 0
         MLin += 1
      ENDIF   
      
      MFob_USD += Work->WKPRECO_US
      MFob_Moe += Work->WKPRECO

      // 18/05/200 - Sidney 
      MTotOutDesp   += Work->WKOUTDESP
//      MTotOutbDesp  := Work->WKOUTBDESP
      MTotOutbDesp  += Work->WKOUTBDESP
      MTotHawb_US   += Work->WKPRECO_US 
      MTotHawb_Moe  += Work->WKPRECO  
      MMoeda  := Work->WKMOEDA // BHF - 21/10/08 - Consolidação de moeda no embarque.         

      IncRegua()
      Work->(DbSkip()) 

   ENDDO 

   MTotHawb_US   += MTotOutbDesp
   MTotHawb_Moe  += MTotOutDesp 

   MTot_Ger_Fob += MFob_USD 
   MTot_Ger_Desp+= MTotOutBDesp
   MTot_Ger     += (MFob_USD + MTotOutBDesp )

   IF MPri
      @ Mlin,nCol12   PSAY TRANS(MNro_PO,_PictPO)
      @ MLin,nCol13   PSAY LEFT(BuscaFabr_Forn(MNro_Fo),15)
      @ MLin,nCol14   PSAY TRAN(MFob_USD,'@E 999,999,999.99')

      @ Mlin,nCol15   PSAY MMoeda
      @ Mlin,nCol16   PSAY OUTRA_MOEDA   //Vide diretiva define
      @ Mlin,nCol19   PSAY DESP_OUT_MOE  //Vide diretiva define
      @ MLin,nCol17   PSAY MIMPORT
      @ MLin,nCol18   PSAY MCONSIG

      //Imprime Outras Despesas
      MLin += 1
      @ MLin,nCol13+5 PSAY STR0076 //'DESPESAS '
      @ MLin,nCol14   PSAY TRAN(MTotOutBDesp,'@E 999,999,999.99')//-1

      MLin += 1
      @ MLin,nCol13+5 PSAY STR0052 //'TOTAL => '
      @ MLin,nCol14   PSAY TRAN(MTotHawb_US,'@E 999,999,999.99')//-1
      MLin += 1

   ELSE
      @ Mlin,nCol12 PSAY TRANS(MNro_PO,_PictPO)
      @ MLin,nCol13 PSAY LEFT(BuscaFabr_Forn(MNro_Fo),15)
      @ MLin,nCol14 PSAY TRAN(MFob_USD,'@E 999,999,999.99')//-1
      @ Mlin,nCol15 PSAY MMoeda
      @ Mlin,nCol16 PSAY OUTRA_MOEDA  //Vide diretiva define
      @ Mlin,nCol19 PSAY DESP_OUT_MOE //Vide diretiva define
      @ MLin,nCol17 PSAY MIMPORT//-6 
      @ MLin,nCol18 PSAY MCONSIG//-6 
      MLin += 1

      //Imprime Outras Despesas
      @ MLin,nCol13+5 PSAY STR0076 //'DESPESAS '
      @ MLin,nCol14   PSAY TRAN(MTotOutBDesp,'@E 999,999,999.99')//-1
      MLin += 1
      
      @ MLin,nCol13+5 PSAY STR0052 //'TOTAL  => '
      @ MLin,nCol14   PSAY TRAN(MTotHawb_US,'@E 999,999,999.99')//-1

      If EasyEntryPoint("EICPRD01")
         ExecBlock("EICPRD01", .F., .F., "IMPRIME")
      EndIf
      If EasyEntryPoint("EICRD152")
         ExecBlock("EICRD152", .F., .F., "IMPRIME")
      EndIf

//    MTot_Ger+= MTotHawb_US
   ENDIF
ENDDO

IF MPag > 0
   MLin += 2
   @MLin,0 PSAY __PRTTHINLINE()
   MLin += 1
   @MLin,nCol12    PSAY ALLTRIM(STR0074) //'TOTAL FOB => '
   @MLin,nCol14    PSAY Alltrim(TRANS(MTot_Ger_Fob   , '@E 999,999,999.99'))
  
   MLin += 1
   @MLin,nCol12    PSAY Alltrim(STR0075) //'TOTAL DESPESAS => '
   @MLin,nCol14    PSAY Alltrim(TRANS(MTot_Ger_Desp  , '@E 999,999,999.99'))
  
   MLin += 1
   @MLin,nCol12    PSAY Alltrim(STR0053) //'TOTAL GERAL => '
   @MLin,nCol14    PSAY Alltrim(TRANS(MTot_Ger       , '@E 999,999,999.99'))
   @MLin,nCol16    PSAY Alltrim(TRANS(MConta, '9999')) + STR0054 //" Registros"
   
   If EasyEntryPoint("EICPRD01")
      ExecBlock("EICPRD01", .F., .F., "IMPRIME_TOTAL")
   EndIf
   If EasyEntryPoint("EICRD152")
      ExecBlock("EICRD152", .F., .F., "IMPRIME_TOTAL")
   EndIf
   
   MLin += 1   
   @MLin,0 PSAY __PRTTHINLINE()
ENDIF
Set Device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
   Set Printer TO 
   Commit
   OurSpool(wnrel)
Endif
MS_FLUSH()
DBGOTO(OldRecno)
RETURN .T.

*---------------------*
FUNCTION RD152Cab(MPARA)
*---------------------*
LOCAL MTamanho:=LEN(TRANS(Work->WKPO_NUM,_PictPO))
MPag := MPag + 1
//MLin := 1

IF MTamanho < 8
   MTamanho:=8
ENDIF

IF TClass = 1
   IF EMPTY(TDtI) .AND. EMPTY(TDtF)
      cabec1:= STR0055 //" Geral"
   ELSE
      cabec1:= STR0056+ TRANSFORM(TDTI,"@D")+STR0057+ TRANSFORM(TDTF,"@D") //" De "###" ate "
   ENDIF
ELSE
   cabec1:= STR0086//"Não Desembaraçados"
ENDIF
MLIN := Cabec(titulo,cabec1,"",nomeprog,tamanho,EasyGParam("MV_COMP"))

MLIN += 1

@ MLin,nCol01 PSAY STR0058 //"Data"
@ MLin,nCol02 PSAY STR0059 //"Nro."
@ MLin,nCol03 PSAY STR0058 //"Data"
@ MLin,nCol04 PSAY STR0022 //"Pagto."
@ MLin,nCol05 PSAY STR0023 //"Nr. Nota Fiscal"
@ MLin,nCol06 PSAY STR0060 //"LOC"
@ MLin,nCol07 PSAY STR0058 //"Data"
@ MLin,nCol08 PSAY STR0058 //"Data"
@ MLin,nCol09 PSAY STR0058 //"Data"
@ MLin,nCol10 PSAY STR0019 //"Agente"
@ MLin,nCol11 PSAY STR0021 //"Despachante"
@ MLin,nCol12 PSAY STR0061 //"No. P.O."
@ MLin,nCol13 PSAY STR0062 //"Fornecedor"
@ MLin,nCol14 PSAY STR0063 //"Valor"
@ MLin,nCol15 PSAY STR0064 //"Moe"       
@ MLin,nCol16 PSAY STR0065 //"Valor na" 
@ MLin,nCol19 PSAY STR0087 //"Despesas" // JBS - 08/07/2004
MLin++

IF MPara == Desembaraco
   @ MLin,nCol01 PSAY STR0066 //"Desemb."
ELSE
   @ MLin,nCol01 PSAY STR0009 //"Embarque"
ENDIF

@ MLin,nCol02 PSAY STR0067 //"D.I."
@ MLin,nCol03 PSAY STR0068 //"Recb.Doc."
@ MLin,nCol04 PSAY STR0069 //"Impostos"

IF MPara == Embarque
   @ MLin,nCol07 PSAY STR0066 //"Desemb."
ELSE                                            
   @ MLin,nCol07 PSAY STR0009 //"Embarque"
ENDIF

@ MLin,nCol08 PSAY STR0070 //"Atrac."
@ MLin,nCol09 PSAY STR0025 //"Entrega"
@ MLin,nCol14 PSAY STR0071 //"FOB US$"
@ MLin,nCol16 PSAY STR0014 //"Moeda"
@ MLin,nCol19 PSAY STR0088 //"Valor na Moeda" // JBS - 08/07/2004
@ MLin,nCol17 PSAY STR0072 //"Imp"
@ MLin,nCol18 PSAY STR0073 //"Con"
If EasyEntryPoint("EICPRD01")
   ExecBlock("EICPRD01", .F., .F., "CABEC1")
EndIf
If EasyEntryPoint("EICRD152")
   ExecBlock("EICRD152", .F., .F., "CABEC1")
EndIf

MLin++

@ MLin,nCol01 PSAY Replicate("-",08) //"----------"
@ MLin,nCol02 PSAY Replicate("-",IF(CPAISLOC="BRA",AVSX3("W6_DI_NUM",3)+nPIC,AVSX3("W6_DI_NUM",3))) //"------------"//ASR 27/01/2006 - BUSCO DO DICIONARIO PORQUE ESTE CAMPO DIFERE SEU TAMANHO (BRASIL/ARGENTINA) - @ MLin,nCol02 PSAY Replicate("-",12)
@ MLin,nCol03 PSAY Replicate("-",08) //"----------"
@ MLin,nCol04 PSAY Replicate("-",08) //"----------"
@ MLin,nCol05 PSAY Replicate("-",15) //"---------------"
@ MLin,nCol06 PSAY Replicate("-",05) //"-----" // NCF - 12/05/09 Aumento de 03 para 05
@ MLin,nCol07 PSAY Replicate("-",08) //"----------"
@ MLin,nCol08 PSAY Replicate("-",08) //"----------"
@ MLin,nCol09 PSAY Replicate("-",08) //"------------"
@ MLin,nCol10 PSAY Replicate("-",16) //"---------------"
@ MLin,nCol11 PSAY Replicate("-",15) //"---------------"
@ MLin,nCol12 PSAY Replicate("-",15)
@ MLin,nCol13 PSAY Replicate("-",15) //"---------------"
@ MLin,nCol14 PSAY Replicate("-",15) //"--------------"
@ MLin,nCol15 PSAY Replicate("-",03) //"---"
@ MLin,nCol16 PSAY Replicate("-",14) //"--------------"
@ MLin,nCol19 PSAY Replicate("-",14) //"--------------" // JBS - 08/07/2004
@ MLin,nCol17 PSAY Replicate("-",03) //"---"
@ MLin,nCol18 PSAY Replicate("-",03) //"---"

If EasyEntryPoint("EICPRD01")
   ExecBlock("EICPRD01", .F., .F., "CABEC2")
EndIf
If EasyEntryPoint("EICRD152")
   ExecBlock("EICRD152", .F., .F., "CABEC2")
EndIf

RETURN

*------------------------*
FUNCTION RD152Det(MPARA)
*------------------------*
// BAK - Tratamento para os campos tipo data - 02/08/2011
@ Mlin,nCol01 PSAY IF(MPara==Desembaraco,AcertaData(Work->WKDT_DESEN),AcertaData(Work->WKDT_EMB))
@ Mlin,nCol02 PSAY Work->WKNUM_DI PICTURE AVSX3("W6_DI_NUM",06)//E_Tran("W6_DI_NUM",,.T.)
@ Mlin,nCol03 PSAY AcertaData(Work->WKDTRECDOC)
@ Mlin,nCol04 PSAY AcertaData(Work->WKDIDT)
@ Mlin,nCol05 PSAY SUBSTR(Work->WKNF_ENT,1,15)
@ MLin,nCol06 PSAY Work->WKLOCAL
@ MLin,nCol07 PSAY IF(MPara==Embarque,AcertaData(Work->WKDT_DESEN),AcertaData(Work->WKDT_EMB))
@ Mlin,nCol08 PSAY AcertaData(Work->WKDT_CHEG)
@ Mlin,nCol09 PSAY AcertaData(Work->WKDT_ENTR)
@ MLin,nCol10 PSAY SUBSTR(BuscaAgente(Work->WKAGENTE),1,20)
@ MLin,nCol11 PSAY SUBSTR(BuscaDesp(Work->WKDESP),1,15)

If EasyEntryPoint("EICPRD01")
   ExecBlock("EICPRD01", .F., .F., "DETALHE")
EndIf
If EasyEntryPoint("EICRD152")
   ExecBlock("EICRD152", .F., .F., "DETALHE")
EndIf

RETURN .T.//""

// BAK - Tratamento para os campos tipo data - 02/08/2011
Static Function AcertaData(dData)
Local cRet  := "  /  /  "
Local cData := ""
Local cAno  := ""
Local nAno  := 0

Begin Sequence

   If Empty(dData)
      Break
   EndIf

   If Valtype(dData) == "D"
      cData := DToC(dData)
   EndIf

   If Empty(cData)
      Break
   EndIf

   nAno := Rat("/",cData)
   If nAno > 0
      cAno := SubStr(cData,nAno+1,4)
   EndIf
   
   If !Empty(cAno)
      cAno := SubStr(cAno,3,2)
      cRet := SubStr(cData,1,nAno) + cAno
   Endif

End Sequence

Return cRet

*-----------------------------*
FUNCTION EICRD153()
*-----------------------------*
LOCAL nOldArea:=SELECT(), TB_Campos:={}
LOCAL dDtIni, dDtFim, cPais, cForn, oDlg, oGet,cLoja:="",nPos:=0
LOCAL cPictVal := AVSX3("W9_FOB_TOT",6)
LOCAL aWK_DBF:= { {"WKPAIS"   ,"C",                3 ,0},;
                  {"WKPAISD"  ,"C",               25 ,0},;
                  {"WKHAWB"   ,"C",AVSX3("W6_HAWB",3),0},;
                  {"WKDT_HAWB","D",                8 ,0},;
                  {"WKFORN"   ,"C",AVSX3("A2_COD" ,3),0},;
                  {"WKMOEDA"  ,"C",                3 ,0},;
                  {"WKTIPODES","C",                2 ,0},;
                  {"WKIMPORT" ,"C",                2 ,0},;
                  {"WKDT_EMB" ,"D",                8 ,0},;
                  {"WKDT_CHEG","D",                8 ,0},;
                  {"WKDT_DESE","D",                8 ,0},;
                  {"WKDI_NUM" ,"C",AVSX3("W6_DI_NUM",3),0},;
                  {"WKVIA_TRA","C",                2 ,0},;
                  {"WKORIGEM" ,"C",                3 ,0},;
                  {"WKDEST"   ,"C",                3 ,0},;
                  {"WKAGENTE" ,"C",AVSX3("W6_AGENTE",AV_TAMANHO) ,0},;
                  {"WKTOTMOE" ,"N",               15 ,2},;
                  {"WKTOTUS"  ,"N",               15 ,2},;
                  {"WKTOTREAL","N",               15 ,2} }

LOCAL aTitulos153 := {{"Pais","C","",""},;
				      {"Processo","C","",""}		,;
				      {"Data","D","",""}    		,;
				      {"Forn.","C","",""}			,;
				      {"Moeda","C","",""}  			,;
				      {"Tipo Des.","C","",""}		,;
				      {"Importador","C","",""}		,;
				      {"Embarque","D","",""}   		,;
				      {"Atracado","D","",""}		,;
				      {"Desembarque","D","",""}		,;
				      {"Num. DI","C","",""}			,;
				      {"Via - Orig/Dest","C","","" },;
				      {"Origem","C","",""}			,;
				      {"Destino","C","",""}			,;
				      {"Agente","C","",""}			,;
				      {"Total na Moeda","N","",""}	,;
				      {"Total em US$","N","",""}	,;
				      {"Total em R$","N","",""}		}// //LRS - 6/11/2013 - Titulos colunas Excel

Local cTitulos153 := "Impressão EXCEL - Avaliação Paises"                 
LOCAL oPanel    
Local aButtons    := {}              
PRIVATE aHeader[0],nUsado:=0, MPos
PRIVATE nOpcA:=0
PRIVATE nCol01 := 001
PRIVATE nCol02 := 019
PRIVATE nCol03 := 028
PRIVATE nCol04 := 049
PRIVATE nCol05 := 080
PRIVATE nCol06 := 089
PRIVATE nCol07 := 098
PRIVATE nCol08 := 107
PRIVATE nCol09 := 119
PRIVATE nCol10 := 138
PRIVATE nCol11 := 154
PRIVATE nCol12 := 160
PRIVATE nCol13 := 179
PRIVATE nCol14 := 198
PRIVATE limite  :=220
PRIVATE Titulo  :=STR0077
PRIVATE aReturn := { "Zebrado", 1,"Importa‡Æo", 2, 2, 1, "",0 }
Private _FirstYear := Right(Padl(Set(_SET_EPOCH),4,"0"),2)

If EICLOJA() .And. (nPos := aScan(aWK_DBF, {|x| x[1] == "WKFORN" })) > 0
   aAdd(aWK_DBF, Nil)
   aAdd(aTitulos153, Nil)
   aIns(aWK_DBF, nPos + 1)
   aIns(aTitulos153, nPos + 1)
   aWK_DBF[nPos+1] := {"WKFORLOJ", "C", AvSx3("W1_FORLOJ", AV_TAMANHO),0}
   aTitulos153[nPos+1] := {"Forn. Fabr.","C","",""}//LRS
EndIf

wnrel  := "EICRD152"
cDesc1 := STR0050 + "- " + STR0077 //"Impressao do relatorio - Avaliacao de Paises

lEmail:= .F.
IF TYPE("__cInternet") # "U" .AND. __cInternet # NIL
   lEmail:= .T.
   E_Init()
ENDIF

FileWork := E_CriaTrab(,aWK_DBF,"Work") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

IF ! USED()
   Help("", 1, "AVG0000451")//"NÆo h   rea dispon¡vel para abertura do Cadastro de Work"###"Atenção"
   Return .F.
ENDIF

IndRegua("Work",FileWork+TEOrdBagExt(),"WKHAWB",;
         "AllwaysTrue()", "AllwaysTrue()", STR0007) //"Processando Arquivo Temporario..."
         
WorkNTX2:= E_Create(aWK_DBF,.F.)

If EICLoja()
   IndRegua("Work",WorkNTX2+TEOrdBagExt(),"WKPAIS+WKFORN+WKFORLOJ+WKMOEDA",;
            "AllwaysTrue()", "AllwaysTrue()", STR0007) //"Processando Arquivo Temporario..." 
Else
   IndRegua("Work",WorkNTX2+TEOrdBagExt(),"WKPAIS+WKFORN+WKMOEDA",;
            "AllwaysTrue()", "AllwaysTrue()", STR0007) //"Processando Arquivo Temporario..." 

EndIf

SET INDEX TO (FileWork+TEOrdBagExt()),(WorkNTX2+TEOrdBagExt())         
                                  
AADD(TB_Campos,{{||IIF(SYA->(dbSeek(xFilial()+Work->WKPAIS)), LEFT(SYA->YA_DESCR,20), Work->WKPAIS )}, "", STR0078}) //"Pais:"
AADD(TB_Campos,{"WKHAWB"   ,"", STR0051}) //"Processo"
AADD(TB_Campos,{"WKDT_HAWB","", STR0058}) //"Data"
AADD(TB_Campos,{{||IIF(SYT->(dbSeek(xFilial()+Work->WKIMPORT)), LEFT(SYT->YT_NOME,20), Work->WKIMPORT )},"", AVSX3('W6_IMPORT',5) }) //"Importador"
AADD(TB_Campos,{{||IIF(SA2->(dbSeek(xFilial()+Work->WKFORN+EICRetLoja("Work","WKFORLOJ"))), LEFT(SA2->A2_NOME,20), Work->WKFORN )},"", STR0013}) //"Fornecedor" 
AADD(TB_Campos,{"WKDT_EMB" ,"", STR0009}) //"Embarque"              
AADD(TB_Campos,{"WKDT_CHEG","", STR0018}) //"Atracado"
AADD(TB_Campos,{"WKDT_DESE","", STR0066}) //"Desemb."
AADD(TB_Campos,{"WKDI_NUM" ,"", STR0024}) //"Nr. da D.I."                     
AADD(TB_Campos,{{||IIF(SYQ->(dbSeek(xFilial()+Work->WKVIA_TRA)),;
                       ALLTRIM(SUBSTR(SYQ->YQ_COD_DI,3,10)) +" "+ Work->WKORIGEM + "/" + Work->WKDEST,;
                       Work->WKVIA_TRA +" "+Work->WKORIGEM + "/" + Work->WKDEST)},"", STR0079}) //"Via - Orig/Dest"
AADD(TB_Campos,{{||IIF(SY4->(dbSeek(xFilial()+Work->WKAGENTE)), LEFT(SY4->Y4_NOME,20), Work->WKAGENTE )},"",STR0019}) //"Agente"
AADD(TB_Campos,{"WKMOEDA", "", STR0014}) //"Moeda"
AADD(TB_Campos,{{||TRANS(WKTOTMOE, cPictVal)},"", STR0080}) //"Total na Moeda"
AADD(TB_Campos,{{||TRANS(WKTOTUS , cPictVal)},"", STR0081}) //"Total em US$"
AADD(TB_Campos,{{||TRANS(WKTOTREAL,cPictVal)},"", STR0082}) //"Total em R$"   

DO WHILE .T.
   If !Pergunte("EIC153", IF(!lEmail,.T.,.F.))
      EXIT
   Endif    
   IF lEmail
      wnrel:=SetPrint("Work",wnrel,,@Titulo,cDesc1,"","",.F.,,.T.,"G")
   ENDIF
   
   dDtIni := mv_par01
   dDtFim := mv_par02
   cPais  := mv_par03
   cForn  := mv_par04                    
   If EICLoja()
      cLoja:= mv_par05
   EndIf

  lInterrompe:=.T.
  IF lEmail
     RD153Grava(dDtIni, dDtFim, cPais, cForn,cLoja)
     IF Work->(Easyreccount("Work")) > 0
        RD153Print()
     ENDIF
     EXIT
  ELSE
     Processa({||RD153Grava(dDtIni, dDtFim, cPais, cForn,cLoja)},;
                 STR0084,; //"Pesquisa de Processos"
                 STR0034) //"Em processamento - aguarde..."

     IF Work->(Easyreccount("Work")) == 0
        Help("", 1, "AVG0000522")//"Não existem registros a serem processados"###"Informação"
     ELSE
        Work->(dbGoTop())
        nOpca:=0  
        oMainWnd:ReadClientCoors()

        AAdd(aButtons, {"Imprimir"  , {|| Processa({||RD153Print()},"Processando")}, "Imprimir", "Imprimir"}) //"Imprimir"                      
        AAdd(aButtons, {"Excel"  , {|| Processa({|| TR350Arquivo("Work",,aTitulos153,cTitulos153,{"WKPAIS"})},"STR0090")}, "Excel", "Excel"}) ////"Excel"

        DEFINE MSDIALOG oDlg TITLE STR0077 FROM ;
               oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;     
               OF oMainWnd PIXEL  
               
           @00,00 MSPanel oPanel Size 20,45 of oDlg    
           
           oMark:= MsSelect():New("Work",,,TB_Campos,.F.,"",{34,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
		   
		   oPanel:Align := CONTROL_ALIGN_TOP
           oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

         oDlg:lMaximized := .T.
        ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()}, ,aButtons))
        If nOpca = 0
            EXIT
        Endif
     ENDIF
   ENDIF
ENDDO       
E_RESET_AREA
RETURN NIL 
   
*----------------------------------------------------------------------------
FUNCTION RD153Grava(dDtIni, dDtFim, cPais, cForn,cLoja)
*----------------------------------------------------------------------------
IF !lEmail
   ProcRegua(SW6->(Easyreccount("SW6")))
ENDIF   

DBSELECTAREA("Work")
AvZap()

SW6->(DBSETORDER(2))
SW9->(DBSETORDER(3)) 
SYA->(DBSETORDER(1))

SW6->(DBSEEK(xFilial()+DTOS(IF(EMPTY(dDtIni),AVCTOD("01/01/"+_FirstYear),dDtIni)),.T.))
DO WHILE !SW6->(eof()) .AND. IIF(EMPTY(dDtFim), .T., SW6->W6_DT_DESE <= dDtFim )
   IF !lEmail
      IncProc(STR0043+SW6->W6_HAWB) //"Pesquisando Processo: "
   ENDIF
                   
   SW9->(DBSEEK(xFilial()+SW6->W6_HAWB))
   DO WHILE !SW9->(eof()) .AND. SW9->W9_FILIAL = xFilial("SW9") ;
                          .AND. SW9->W9_HAWB   = SW6->W6_HAWB
                       
      SA2->(dbSeek(xFilial()+SW9->W9_FORN+EICRetLoja("SW9","W9_FORLOJ")))
      IF !EMPTY(cPais) .AND. SA2->A2_PAIS <> cPais
         SW9->(dbSkip())
         LOOP
      ENDIF
      
      IF (!EMPTY(cForn) .And. IIF(EICLoja(),!EMPTY(cLoja),.T.)) .AND. (SW9->W9_FORN <> cForn .And. IIF(EICLoja(),SW9->W9_FORLOJ <> cLoja,.T.))
         SW9->(dbSkip())
         LOOP
      ENDIF
   
      Work->(DBAPPEND())                                    
      Work->WKPAIS    := SA2->A2_PAIS             
      Work->WKPAISD   := IIF(SYA->(dbSeek(xFilial("SYA")+SA2->A2_PAIS)), LEFT(SYA->YA_DESCR,25), SA2->A2_PAIS )        
      Work->WKHAWB    := SW6->W6_HAWB
      Work->WKDT_HAWB := SW6->W6_DT_HAWB
      Work->WKFORN    := SW9->W9_FORN
      Work->WKMOEDA   := SW9->W9_MOE_FOB
      Work->WKTIPODES := SW6->W6_TIPODES
      Work->WKIMPORT  := SW6->W6_IMPORT
      Work->WKDT_EMB  := SW6->W6_DT_EMB
      Work->WKDT_CHEG := SW6->W6_CHEG
      Work->WKDT_DESE := SW6->W6_DT_DESE
      Work->WKDI_NUM  := SW6->W6_DI_NUM
      Work->WKVIA_TRA := SW6->W6_VIA_TRA
      Work->WKORIGEM  := SW6->W6_ORIGEM
      Work->WKDEST    := SW6->W6_DEST
      Work->WKAGENTE  := SW6->W6_AGENTE
      Work->WKTOTMOE  := SW9->W9_FOB_TOT
      Work->WKTOTUS   := (SW9->W9_FOB_TOT * SW9->W9_TX_FOB)/ SW6->W6_TX_US_D
      Work->WKTOTREAL := SW9->W9_FOB_TOT * SW9->W9_TX_FOB
      If EICLoja()
         Work->WKFORLOJ    := SW9->W9_FORLOJ
      EndIf 
      
      SW9->(dbSkip())
   ENDDO
   SW6->(dbSkip())
ENDDO
SW9->(DBSETORDER(1))
RETURN NIL

*-------------------------------------------------------------
FUNCTION RD153Print()
*-------------------------------------------------------------

PRIVATE limite  :=220
PRIVATE Titulo  :=STR0077
PRIVATE aReturn := { "Zebrado", 1,"Importa‡Æo", 2, 2, 1, "",0 }
PRIVATE nomeprog:="EICRD152",nLastKey := 0
PRIVATE aDriver :=ReadDriver()

wnrel:=SetPrint("Work",wnrel,,@Titulo,cDesc1,"","",.F.,,.T.,"G")
If nLastKey == 27
   Return
Endif

SetDefault(aReturn,"Work")
If nLastKey == 27
   Set Filter to
   Return
Endif

RptStatus({|lEnd| RelRD153(@lEnd,wnRel,"Work","G",limite)},Titulo)

Return

*--------------------------------------------------------------------*
FUNCTION RelRD153(lEnd,wnRel,cString,tamanho,limite)
*--------------------------------------------------------------------*
LOCAL OldRecno := Work->(RECNO()),cPais
LOCAL cPictVal := AVSX3("W9_FOB_TOT",6)
LOCAL cForLoj  := ""

M_Pag  :=1
limite := 130;li:= 80
MLin := 99
MPag := 00

Work->(DBSETORDER(2))
Work->(DBGOTOP())
SetRegua(Work->(Easyreccount("Work")))
cPais := Work->WKPAIS
cForn := Work->WKFORN
If EICLoja()
   cForLoj:= Work->WKFORLOJ
EndIf
nTotMoePais := 0
nTotUSPais  := 0 
nTotRSPais  := 0    
nTotMoeForn := 0
nTotUsForn  := 0
nTotRsForn  := 0
nTotMoeGer  := 0
nTotUSGer   := 0 
nTotRSGer   := 0
DO WHILE !Work->(EOF())
   IF MLin > 55
      RD153Cab()
   ENDIF     
   @ Mlin,nCol01 PSAY Work->WKHAWB 
   // BAK - Tratamento para os campos tipo data - 02/08/2011
   @ Mlin,nCol02 PSAY AcertaData(Work->WKDT_HAWB)
   @ MLin,nCol03 PSAY IIF(SYT->(dbSeek(xFilial()+Work->WKIMPORT)), LEFT(SYT->YT_NOME,20), Work->WKIMPORT )
   @ MLin,nCol04 PSAY IIF(SJB->(dbSeek(xFilial()+Work->WKTIPODES)), LEFT(SJB->JB_DESCR,30), Work->WKTIPODES )
   @ Mlin,nCol05 PSAY AcertaData(Work->WKDT_EMB) 
   @ Mlin,nCol06 PSAY AcertaData(Work->WKDT_CHEG)     
   @ MLin,nCol07 PSAY AcertaData(Work->WKDT_DESE)
   @ MLin,nCol08 PSAY LEFT(Work->WKDI_NUM,11)
   @ Mlin,nCol09 PSAY IIF(SYQ->(dbSeek(xFilial()+Work->WKVIA_TRA)),;
                         ALLTRIM(SUBSTR(SYQ->YQ_COD_DI,3,10)), Work->WKVIA_TRA ) + " " +;
                         Work->WKORIGEM + "/" + Work->WKDEST
   @ Mlin,nCol10 PSAY IIF(SY4->(dbSeek(xFilial()+Work->WKAGENTE)), LEFT(SY4->Y4_NOME,15), Work->WKAGENTE )
   @ MLin,nCol11 PSAY Work->WKMOEDA
   @ MLin,nCol12 PSAY TRANS(Work->WKTOTMOE, cPictVal)      
   @ MLin,nCol13 PSAY TRANS(Work->WKTOTUS, cPictVal)
   @ MLin,nCol14 PSAY TRANS(Work->WKTOTREAL, cPictVal)
   MLin++
   
   nTotMoeForn += Work->WKTOTMOE
   nTotUSForn  += Work->WKTOTUS 
   nTotRSForn  += Work->WKTOTREAL
   
   nTotMoePais += Work->WKTOTMOE
   nTotUSPais  += Work->WKTOTUS 
   nTotRSPais  += Work->WKTOTREAL
   
   nTotMoeGer += Work->WKTOTMOE
   nTotUSGer  += Work->WKTOTUS 
   nTotRSGer  += Work->WKTOTREAL   
   
   Work->(dbSkip())   
   IF !Work->(Eof()) .AND. (cForn <> Work->WKFORN .AND. IIF(EICLoja(),cForLoj<> Work->WKFORLOJ,.T.))
      @ MLin,nCol10 PSAY "Total do Fornecedor:"
      @ MLin,nCol12 PSAY TRANS(nTotMoeForn, cPictVal)      
      @ MLin,nCol13 PSAY TRANS(nTotUSForn, cPictVal)
      @ MLin,nCol14 PSAY TRANS(nTotRSForn, cPictVal)
      MLin++
      
      nTotMoeForn := 0
      nTotUsForn  := 0
      nTotRsForn  := 0
      cForn := Work->WKFORN
      If EICLoja()
         cForLoj := Work->WKFORLOJ
      EndIf
      
      IF MLin > 55
         RD153Cab()
      ELSEIF cPais == Work->WKPAIS
         MLin++
         @ MLin,nCol01 PSAY STR0062 + ": " + Work->WKFORN + "  " + ; //"Fornecedor"
                            IIF(SA2->(dbSeek(xFilial()+Work->WKFORN + EICRetLoja("Work","WKFORLOJ"))), SA2->A2_NOME, SPACE(20) )
         MLin+=2                            
      ENDIF
   ENDIF
   IF !Work->(Eof()) .AND. cPais <> Work->WKPAIS
      MLin++
      @ mLin,nCol10 PSAY "Total do Pais:"
      @ MLin,nCol12 PSAY TRANS(nTotMoePais, cPictVal)      
      @ MLin,nCol13 PSAY TRANS(nTotUSPais, cPictVal)
      @ MLin,nCol14 PSAY TRANS(nTotRSPais, cPictVal)
      MLin+=2
      nTotMoePais  := 0
      nTotUsForPais := 0
      nTotRsForPais := 0
      cPais := Work->WKPAIS
      
      IF MLin > 55
         RD153Cab()
      ELSE
         MLin++    
         @ MLin,nCol01 PSAY STR0078 + Work->WKPAIS + "  " + ;  //"Pais: "
                            IIF(SYA->(dbSeek(xFilial()+Work->WKPAIS)), SYA->YA_DESCR, SPACE(20) )   
                   
         MLin+=2 
         @ MLin,nCol01 PSAY STR0062 + ": " + Work->WKFORN + "  " + ; //"Fornecedor"
                            IIF(SA2->(dbSeek(xFilial()+Work->WKFORN+EICRetLoja("Work","WKFORLOJ"))), SA2->A2_NOME, SPACE(20) )
         MLin+=2                    
      ENDIF
   ENDIF   

   IncRegua()
ENDDO
IF nTotMoeFor > 0
   @ MLin,nCol10 PSAY "Total do Fornecedor:"
   @ MLin,nCol12 PSAY TRANS(nTotMoeForn, cPictVal)      
   @ MLin,nCol13 PSAY TRANS(nTotUSForn, cPictVal)
   @ MLin,nCol14 PSAY TRANS(nTotRSForn, cPictVal)
   mLin+=2
ENDIF
IF nTotMoePais > 0
   @ mLin,nCol10 PSAY "Total do Pais:"
   @ MLin,nCol12 PSAY TRANS(nTotMoePais, cPictVal)      
   @ MLin,nCol13 PSAY TRANS(nTotUSPais, cPictVal)
   @ MLin,nCol14 PSAY TRANS(nTotRSPais, cPictVal)
   mLin+=3
ENDIF                   
@ MLin,nCol10 PSAY "Total Geral:"   
@ MLin,nCol12 PSAY TRANS(nTotMoeGer, cPictVal)      
@ MLin,nCol13 PSAY TRANS(nTotUSGer, cPictVal)
@ MLin,nCol14 PSAY TRANS(nTotRSGer, cPictVal)   
Set Device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
   Set Printer TO 
   Commit
   OurSpool(wnrel)
Endif
MS_FLUSH()
DBGOTO(OldRecno)
RETURN .T.

*---------------------*
FUNCTION RD153Cab()
*---------------------*
MPag := MPag + 1
cabec1:= ""

MLIN := Cabec(titulo,cabec1,"",nomeprog,"G",EasyGParam("MV_COMP"))

MLin += 1    
@ MLin,nCol01 PSAY STR0078 + Work->WKPAIS + "  " + ;  //"Pais: "
                   IIF(SYA->(dbSeek(xFilial()+Work->WKPAIS)), SYA->YA_DESCR, SPACE(20) )   
     
MLin += 2                   
@ MLin,nCol01 PSAY STR0062 + ": " + Work->WKFORN + "  " + ; //"Fornecedor"
                   IIF(SA2->(dbSeek(xFilial()+Work->WKFORN+EICRetLoja("Work","WKFORLOJ"))), SA2->A2_NOME, SPACE(20) )
                   
MLin += 2
@ MLin,nCol01 PSAY STR0051 //"Processo: "
@ MLin,nCol02 PSAY STR0058 //"Data"
@ MLin,nCol03 PSAY STR0029 //"Importador"
@ MLin,nCol04 PSAY STR0083 //"Tipo de Declaracao:"
@ MLin,nCol05 PSAY STR0009 //"Embarque"
@ MLin,nCol06 PSAY STR0018 //"Atracado"
@ MLin,nCol07 PSAY STR0066 //"Desemb."
@ MLin,nCol08 PSAY STR0024 //"Nr. da D.I."
@ MLin,nCol09 PSAY STR0079 //"Via - Orig/Dest"
@ MLin,nCol10 PSAY STR0019 //"Agente"
@ MLin,nCol11 PSAY LEFT(STR0014,3) //"Moeda
@ MLin,nCol12 PSAY STR0080 //"Total na Moeda"
@ MLin,nCol13 PSAY STR0081 //"Total em US$" 
@ MLin,nCol14 PSAY STR0082 //"Total em R$"

MLin += 1
@ MLin,nCol01 PSAY Replicate("-",17) //"-----------------"
@ MLin,nCol02 PSAY Replicate("-",08) //"--------"
@ MLin,nCol03 PSAY Replicate("-",20) //"--------------------"
@ MLin,nCol04 PSAY Replicate("-",30) //"------------------------------"
@ MLin,nCol05 PSAY Replicate("-",08) //"--------"
@ MLin,nCol06 PSAY Replicate("-",08) //"--------"
@ MLin,nCol07 PSAY Replicate("-",08) //"--------"
@ MLin,nCol08 PSAY Replicate("-",11) //"-----------"
@ Mlin,nCol09 PSAY Replicate("-",18) //"------------------"
@ Mlin,nCol10 PSAY Replicate("-",15) //"---------------"
@ MLin,nCol11 PSAY Replicate("-",03) //"-----"
@ MLin,nCol12 PSAY Replicate("-",18) //"------------------"
@ MLin,nCol13 PSAY Replicate("-",18) //"------------------"
@ MLin,nCol14 PSAY Replicate("-",18) //"------------------"
MLin += 1
RETURN NIL


*----------------------------------------------------------------------------*
FUNCTION RD152SomaPO()  // JBS - 08/07/2004                        
// Posiciona o SW8 e Rotorna (Despesas): Frete int + Packing + Inland - desconto
// de Um Processo + PO + COD_I. A Partir do SW7 Posicionado
*---------------------------------------------*
Local nORdSW8 := SW8->(indexOrd())
Local nOrdSW9 := SW9->(indexOrd())
Local cFilSW8 := xFilial("SW8")
Local cFilSW9 := xFilial("SW9")
Local cAliasAtu:= Alias()
Local nTx_Fob := 0

dbSelectArea("SW8")

SW8->(dbSetOrder(3))
SW9->(dbSetOrder(1))                                                                          
SW8->(DBSEEK(cFilSW8+SW7->(W7_HAWB+W7_PGI_NUM+W7_PO_NUM+W7_SI_NUM+AvKey(W7_CC,"W8_CC")+W7_COD_I))) //RRV - 23/08/2012 - Ajuste para correção do Seek na SW8. Incluido AvKey no campo de Centro de Custo da SW7.

Do While SW8->(!EOF()).and. SW8->W8_FILIAL == cFilSW8        .and.;
         SW8->W8_HAWB    == SW7->W7_HAWB                     .and.;
         SW8->W8_PGI_NUM == SW7->W7_PGI_NUM                  .and.;
         SW8->W8_PO_NUM  == SW7->W7_PO_NUM                   .and.;
         SW8->W8_SI_NUM  == SW7->W7_SI_NUM                   .and.;
         SW8->W8_CC      == AvKey(SW7->W7_CC,"W8_CC")        .and.; //RRV - 23/08/2012 - Ajuste para correção do Seek na SW8. Incluido AvKey no campo de Centro de Custo da SW7.
         SW8->W8_COD_I   == SW7->W7_COD_I
         
   If SW7->W7_POSICAO == SW8->W8_POSICAO                                                                               
      SW9->(dbSeek(cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")+SW8->W8_HAWB)) // RRV - 18/09/2012 - Ajuste para posicionar a SW9 antes da chamada do DI500RetVal()
      nTot_Desp_SW8 += DI500RetVal("ITEM_INV,SEM_FOB", "TAB", .T.)  // EOB - 14/07/08 - Chamada da função DI500RetVal
      
      //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
      If nTx_Fob=0 .and. SW9->(dbSeek(cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")+SW8->W8_HAWB))
         nTx_Fob:= SW9->W9_TX_FOB
      EndIf
      
   EndIf   
         
   SW8->(dbSkip())      
   
EndDo

nTx_Fob_SW9 := nTx_Fob

SW9->(dbSetOrder(nORdSW9))
SW8->(dbSetOrder(nORdSW8))
dbSelectArea(cAliasAtu)

RETURN(.T.) 

*----------------------------------------------------------------------------*
*     FIM DO PROGRAMA RD152.prg                                              *
*----------------------------------------------------------------------------*
