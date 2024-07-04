#INCLUDE "Eictr300.ch"
#include "AVERAGE.CH"
//#include "FiveWin.ch"

#COMMAND E_RESET_AREA => If(SELECT("TRB") # 0,(TRB->(E_EraseArq(WorkFile)),TR300ApagaCtree()),);
                       ; SELECT(nOldArea)//DBSELECTAREA(nOldArea)

#DEFINE   Largura       132
#DEFINE   Comprime      .T.
#DEFINE   Quantidade   STR0001 //"Por Quantidade    "
#DEFINE   Valor        STR0002 //"Por Valor em Dolar"
#DEFINE   CCUS_ARQ      1
#DEFINE   FORN_ARQ      2
#DEFINE   DESP_ARQ      3
#DEFINE   COMP_ARQ      4
#DEFINE   AGEN_ARQ      5
#DEFINE   ITEM_ARQ      6
#DEFINE   CLIE_ARQ      7
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICTR300 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 20.02.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Tabela ABC                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR300()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//JWJ 14/08/06: EICTR300 atualizado para a versão 8.11 R4
*-----------------------*
Function EICTR300()      
*-----------------------*
Local lR4
lR4 := FindFunction("TRepInUse") .And. TRepInUse()
Return EICTR300R3(lR4)

*-----------------------*
Function EICTR300R3(xR4)
*-----------------------*
LOCAL WorkFile, nOldArea:=SELECT()

LOCAL T_DBF:= { {"WKCOD_I" , "C" ,  6 , 0 } ,;
                {"WKDES"   , "C" , 30 , 0 } ,;
                {"WKQTD"   , "N" , 13 , 3 } ,;
                {"WKVAL"   , "N" , 15 , 2 } ,;
                {"WKPARTIC", "N" ,  6 , 2 } }

LOCAL TB_Funcoes:={ {"-4", "Relatorio",    "F5" , STR0003 } ,; //"Relat¢rio"
                    {"-9",{||TR300Graf()}, "F10", STR0004  } } //"Gr fico"


//LOCAL aRCampos:={ {"TRAN(WKCOD_I,MPictItem)+' '+WKDES" ,"","C"}   ,;
//                  {"TRAN(WKQTD,MPictQt)"   ,STR0005,"C"} ,; //"Qtde"
//                  {"TRAN(WKVAL,'@E 999,999,999,999.99')"   ,STR0006,"C" } ,; //"Valor em US$"
//                  {"TRAN(WKPARTIC,'@E 999.99')",STR0007,"C"} } //"Part %"

LOCAL aRCampos:={ {"TRAN(WKCOD_I,MPictItem)",STR0037,"C"} ,; //"CODIGO"
                  {"TRAN(WKDES,'@!')"       ,STR0038,"C"} ,; //"DESCRICAO"
                  {"TRAN(WKQTD,MPictQt)"    ,STR0005,"C"} ,; //"Qtde"
                  {"TRAN(WKVAL,'@E 999,999,999,999.99')"   ,STR0006,"C" } ,; //"Valor em US$"
                  {"TRAN(WKPARTIC,'@E 999.99')",STR0007,"C"} } //"Part %"

LOCAL aDados :={"TRB",;
                STR0008,; //"Este relatorio ir  exibir a Tabela ABC"
                STR0009,; //"de acordo com a opcao escolhida."
                "",;
                "M",;
                 80,;
                "",;
                "",;
                "",;
                { STR0010, 1,STR0011, 2, 2, 1, "",1 },; //"Zebrado"###"Importa‡Æo"
                "EICTR300",;
                { {|| .T. } , {|| .T. }  }  }

/* ISS - 17/03/10 - Alteração no TB_Campos, usando ponteiros para os campos (TRB->) caso não tenha os ponteiros 
                    ocorrerá um erro ao reutilizar */

LOCAL TB_Campos:=;
{ {{||TRAN(TRB->WKCOD_I,MPictItem)}             ,"", STR0037      },; //Código
  {{||TRAN(TRB->WKDES,'@!')}                    ,"", STR0038      },; //"Descrição"
  {{||TRAN(TRB->WKQTD,MPictQt)}                 ,"", STR0005         },; //"Qtde"
  {{||TRAN(TRB->WKVAL,'@E 999,999,999,999.99')} ,"", STR0006 },; //"Valor em US$"
  {{||TRAN(TRB->WKPARTIC,'@E 999.99')}          ,"", STR0007       } } //"Part %"/
LOCAL cTitulo, oDlg, oGet, oPanel, nOpcA:=0, bMsg, oRad1, oRad2

LOCAL GETLIST:={}, L1:=5, indice, _mes ,;
      Mes_I, Mes_F, T_Fields:={}, MQtd, MVal, MDescAtu:=STR0012   ,; //"Atualizado ate "
      MGet_QV:=MGet_Arq:=.T., num_opc 

LOCAL b_gravaw:={|| AEVAL(T_Fields,;
                    {|pos| MQtd+=FIELDGET(pos[1]), MVal+=FIELDGET(pos[2])}),;
                    TR300Grava(TQual,@MQtd,@MVal)}

LOCAL b_condition:={||FIELDGET(pos_tipo)=MTipo .AND. FIELDGET(pos_ano)=TAno}

LOCAL MTipo, MDescMes, pos_ano, pos_tipo, dUlt_Atz:=EasyGParam("MV_ULT_ATZ")

Local aButtons := {}

//LOCAL lValidMes:=.F., lValidAno:=.F.

//LOCAL bValid:={||(lValidMes  .OR. TR300ValMes(TMes))  .AND. ;
//                 (lValidAno  .OR. TR300ValAno(TAno,MTipo)) }

DEFAULT xR4 := .F.
PRIVATE lR4 := xR4	//JWJ 14/08/2006
PRIVATE oReport, oSecao1, cRepTit

PRIVATE cMarca := GetMark(), lInverte := .F., TQual:=1, nOpc:=0 , WorkFile2 //TArq,

PRIVATE cCadastro := OemtoAnsi(STR0013) //"Tabela ABC"

PRIVATE aHeader[0], TCodigo

PRIVATE TMes, TAno

PRIVATE R_Dados:={NIL,Largura,Comprime,NIL}, R_Campos:={}, MQtdTot, MValTot ,;
        R_Funcoes:={ {|| .T. },{|| TR300Tot()} }, TArq:=1, MParTot, MDescArq   ,;
        T_Opcoes:={PadR(AVSX3("W0__CC",5),15)  ,;
                   STR0014 ,; //"Fornecedor     "
                   STR0015 ,; //"Despachante    "
                   STR0016 ,; //"Comprador      "
                   STR0017 ,; //"Agente         "
                   STR0018 ,; //"Item           "
                   STR0019 } , MPictQt, MPictItem //"Cliente        "

PRIVATE aArq:={{"SY3","Y3_DESC" },;
               {"SA2","A2_NOME" },;
               {"SY5","Y5_NOME" },;
               {"SY1","Y1_NOME" },;
               {"SY4","Y4_NOME" },;
               {"SB1","B1_DESC_P"},;
               {"SA1","A1_NOME"  } }

num_opc:=LEN(TB_Campos)

//TRP-18/03/08
//MFR 11/12/2019 OSSME-4083
//IF RealRDD() == "CTREE"   
   AADD(T_DBF,{"WK_ORD"  , "N" ,  5 , 0 })  // Campo de Ordem para impressão do relatorio pois o Ctree nao faz indice descending
//ENDIF

FOR indice=1  TO  num_opc
    AADD(R_Campos,{TB_Campos[indice,1],TB_Campos[indice,2],"D"})
NEXT
R_Campos[1,3]:="E"

num_opc:=LEN(T_Opcoes)

TMes:=MONTH(dUlt_Atz)
TAno:=Str(YEAR(dUlt_Atz),4,0)


lPadrao:=.T.
IF(EasyEntryPoint("EICTR300"),Execblock("EICTR300",.F.,.F.,"INIVAR"),)//chiba

WHILE .T.

  DBSELECTAREA("SWJ")
  ASIZE(T_Fields,0)
  MQtdTot:=MValTot:=MParTot:=0
  //lValidMes:=lValidAno:=.F.
  nOpc:= 0
  
  IF lPadrao//chiba
  DEFINE MSDIALOG oDlg FROM  9,10 TO 23,65 TITLE cCadastro OF oMainWnd

    @  6, 6   TO 100,  77 LABEL STR0020                   OF oDlg  PIXEL //"Seleção"

    @ 16, 10 RADIO oRad1 VAR TArq  ITEMS T_Opcoes[1],T_Opcoes[2],T_Opcoes[3],;
                                         T_Opcoes[4],T_Opcoes[5],T_Opcoes[6],;
                                         T_Opcoes[7] 3D SIZE 45,9 PIXEL     //;
                 //ON CHANGE TR_HistSet(TArq,@MTipo,@MPictQt,@MPictItem)

    @ 06,86 TO 55,169 LABEL STR0021 OF oDlg PIXEL //"Critério de Classificação"

    @ 18,90 RADIO oRad2 VAR TQual ITEMS Quantidade,Valor 3D SIZE 70,13 PIXEL

    @ 58, 86 TO 100, 175 LABEL STR0022            OF oDlg PIXEL //"Data Base"
    @ 75, 89 SAY STR0023            SIZE 40,10 OF oDlg PIXEL //"Mês / Ano : "
    @ 75,120 MSGET TMes Picture "99"       SIZE 20,10 OF oDlg PIXEL  
    //             Valid (lValidMes:=TR300ValMes(TMes))

    //@ 75,132 SAY " / "                     SIZE 10,10 OF oDlg PIXEL
    @ 75,140 MSGET TAno Picture "9999"     SIZE 32,10 OF oDlg PIXEL  
    //             Valid (lValidAno:=TR300ValAno(TAno,MTipo))

    DEFINE SBUTTON FROM 10,180 TYPE 1 ACTION (nOpc:=1,oDlg:End()) ENABLE OF oDlg PIXEL

    DEFINE SBUTTON FROM 35,180 TYPE 2 ACTION (nOpc:=0,oDlg:End()) ENABLE OF oDlg  PIXEL

     ACTIVATE MSDIALOG oDlg CENTERED
  
  ELSE 
     IF(EasyEntryPoint("EICTR300"),Execblock("EICTR300",.F.,.F.,"TELA_01"),) //chiba
  ENDIF
    
  If nOpc == 0
     E_RESET_AREA
     Return .F.
  Endif
  
  TR_HistSet(TArq,@MTipo,@MPictQt,@MPictItem)
  IF !TR300ValMes(TMes)  .OR.  !TR300ValAno(TAno,MTipo)
  	 LOOP
  ENDIF

  cTitulo:= T_Opcoes[TArq] + " - "+IF(TQual=1,Quantidade,Valor)

  IF TMes # 0
     Mes_I:=Mes_F:=TMes   ; MDescMes:=Nome_Mes(TMes)+"/"+TAno+" - "
  ELSE
     Mes_I:=1 ; Mes_F:=12 ; MDescMes:=STR0024+" - " //"Todos os meses"
  ENDIF

  TR_HistArq(TArq,@WorkFile,T_DBF,Mes_I,Mes_F,T_Fields,@pos_ano,@pos_tipo)

  TB_Campos[1,3]:= ( MDescArq:=ALLTRIM(T_Opcoes[TArq]) )
  aRCampos[1,2] := MDescArq
  R_Dados[1]    := ALLTRIM(cCadastro)+STR0025+MDescArq //" - Por "
  R_Dados[4]    := MDescMes+MDescAtu+DTOC(dUlt_Atz)
  aDados[9]     := cCadastro+" - "+OemToAnsi(cTitulo)

  IF lR4
     cRepTit := aDados[9]
     //oReport := ReportDef() //JWJ 14/08/2006
  ENDIF

  Processa({|| TR300Gera(WorkFile,T_Fields,MTipo,TAno,pos_ano,pos_tipo)} )

  IF TRB->(Easyreccount("TRB")) > 0

     oMainWnd:ReadClientCoors()
     DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+OemToAnsi(cTitulo);
            FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
                 OF oMainWnd PIXEL  
     @ 00,00 MsPanel oPanel Prompt "" Size 60,30 of oDlg //LRL 27/04/04
     @ 08,4 SAY MDescAtu    SIZE 40,10 of oPanel PIXEL
     @ 08,48 MSGET dUlt_Atz SIZE 40,10 WHEN .F. of oPanel PIXEL

     IF TQual = 1
        @ 08,120  SAY STR0026  SIZE 40,10 of oPanel PIXEL //"Qtde. Total "
        @ 08,160  MSGET MQtdTot PICTURE MPictQt SIZE 70,10 WHEN .F. of oPanel PIXEL
     ELSE
        @ 08,120  SAY STR0027 SIZE 60,10 of oPanel PIXEL //"Valor Total "
        @ 08,160  MSGET MValTot PICTURE '@E 999,999,999,999.99' SIZE 70,10 WHEN .F. of oPanel PIXEL
     ENDIF
    If aScan(abuttons,{|x| UPPER(x[1]) == "IMPRIMIR" }) == 0 //NCF - 08/08/2019
       aAdd(aButtons, {"IMPRIMIR", {|| IF(lR4,(oReport := ReportDef(),oReport:PrintDialog()),E_Report(aDados,aRCampos)) }, STR0043})
    EndIf
	 oPanel:Align:=CONTROL_ALIGN_TOP  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT    

     oMark:= MsSelect():New("TRB",,,TB_Campos,@lInverte,@cMarca,{40,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
     // GFP - 13/04/2012 - Align deve estar após a declaracao do MSSELECT
     oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
     ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},;
                                                     {||nOpca:=0,oDlg:End()},, aButtons)) //LRL 27/04/04//Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
     If nOpca = 0
        E_RESET_AREA
        Return .F.
     Endif

  ENDIF

  IF TRB->(EasyRecCount("TRB")) == 0
     Help(" ",1,"EICSEMREG")
  ENDIF

  If nOpcA==2
  // RELATORIO
  Endif

ENDDO

function av_graf()
return "z"  

*---------------------------------------------------------------------------
FUNCTION TR_HistSet(TArq,MTipo,MPictQt,MPictItem,MPictGet)
*---------------------------------------------------------------------------
cCampoF4:=RIGHT(aArq[TArq,1],2)+'_COD'
cDescCpo:=aArq[TArq,2]                                         

IF(EasyEntryPoint("EICTR300"),Execblock("EICTR300",.F.,.F.,"TR_HISTSET"),) //chiba

IF TArq # 6
   DBSELECTAREA("SWK")
   MTipo  :=STR(TArq,1,0)
   MPictQt:='@E 9,999'
   MPictItem:="@!"
   IF(MPictGet # NIL,IF(TArq==2,MPictGet:=E_Tran("A2_COD",,.T.),MPictGet:='@!'),)
ELSE
   DBSELECTAREA("SWJ")
   MTipo:='1'
   MPictQt:='@E 999,999,999.999'
   MPictItem:=ALLTRIM(X3Picture("B1_COD"))
   IF(MPictGet # NIL,MPictGet:=ALLTRIM(X3Picture("B1_COD")),)
ENDIF

*---------------------------------------------------------------------------
FUNCTION TR_HistArq(PArq,WorkFile,T_DBF,PIni,PFim,T_Fields,;
                    pos_ano,pos_tipo,pos_cod)
*---------------------------------------------------------------------------
LOCAL  MDesQt, MDesVl, MDesAno, MDesTipo, MDesCod:=' ', indice, _mes, MArea
LOCAL nTam 

PRIVATE aTam:={ AVSX3("Y3_COD",3),AVSX3("A2_COD",3),;
                AVSX3("Y5_COD",3),AVSX3("Y1_COD",3),;
                AVSX3("Y4_COD",3),AVSX3("W3_COD_I",3),AVSX3("A1_COD",3) }

IF(EasyEntryPoint("EICTR300"),Execblock("EICTR300",.F.,.F.,"TR_HISTARQ"),)//chiba

nTam:=aTam[PArq]

IF PArq # 6
   T_DBF[1]:={"WKCOD_I"   , "C" , nTam , 0 }
   MArea:="SWK"         ;  MDesQt:="WK_QT_PO"  ;  MDesVl:="WK_VL_US"
   MDesAno :="WK_ANO"   ;  MDesTipo:="WK_TIPO"
   IF(pos_cod # NIL,MDesCod:="WK_CODIGO",)
ELSE
   T_DBF[1]:={"WKCOD_I"   , "C" , nTam , 0 }
   MArea:="SWJ"        ;  MDesQt:="WJ_QTD_"   ;  MDesVl:="WJ_FOB_"
   MDesAno :="WJ_ANO"  ;  MDesTipo:="WJ_TIPO"
   IF(pos_cod # NIL,MDesCod:="WJ_CODIGO",)
ENDIF

IF SELECT("TRB") # 0
   TRB->(dbcloseAREA())
ENDIF

WorkFile := E_CriaTrab(,T_DBF,"TRB") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

DBSELECTAREA(MArea)

//TRP-18/03/08
//MFR 11/12/2019 OSSME-4083
//IF RealRDD() == "CTREE"   
   WorkFile2:=E_Create(,.F.)//APENAS GERA UM NOME PARA O INDICE 2
//ENDIF

FOR indice=PIni TO PFim
    _mes:=STRZERO(indice,2)
    AADD(T_Fields,{FIELDPOS(MDesQT+_mes),FIELDPOS(MDesVl+_mes)})
NEXT
pos_ano :=FIELDPOS(MDesAno)
pos_tipo:=FIELDPOS(MDesTipo)
pos_cod :=FIELDPOS(MDesCod)
RETURN NIL

*---------------------------------------------------------------------------
Function TR300Gera(WorkFile,T_Fields,MTipo,TAno,pos_ano,pos_tipo)
*---------------------------------------------------------------------------
LOCAL b_gravaw:={|| AEVAL(T_Fields,;
                    {|pos| MQtd+=FIELDGET(pos[1]), MVal+=FIELDGET(pos[2])}),;
                    TR300Grava(TQual,@MQtd,@MVal)}

LOCAL b_condition:={||FIELDGET(pos_tipo)=MTipo .AND. FIELDGET(pos_ano)=TAno}


LOCAL b_particip :={|| TRB->WKPARTIC:=100*IF(TQual=1,TRB->WKQTD/MQtdTot,;
                       TRB->WKVAL/MValTot), MParTot+=TRB->WKPARTIC }

LOCAL MQtd:=0, MVal:=0, nRec:=0, nTot:=1
LOCAL cAliasSel := ""

ProcRegua(Easyreccount("TRB"))

TRB->(avzap())

//EJA - 18/07/2019 //NCF - 08/08/2019 - Selecionar SWJ/SWK não usar a área da work TRB.
cAliasSel := If(TArq # 6,"SWK","SWJ")
DbSelectArea(cAliasSel)
(cAliasSel)->(dbSeek(xFilial(cAliasSel) + AvKey(MTipo,Substr(cAliasSel,2,2)+"_TIPO")))
DBEVAL({|| IncProc(STR0028), Eval(b_gravaw) },,b_condition) //"Pesquisando dados"

DbSelectArea("TRB") ; DbGoTop()

IF (nTot:=EasyRecCount("TRB")) == 0
   Return .T.
ENDIF

IF MQtdTot=0
   MQtdTot:=1
ENDIF
IF MValTot=0
   MValTot:=1
ENDIF

ProcRegua(nTot)

DBEVAL({|| IncProc(STR0029), Eval(b_particip) }) //"Classificando dados"

//MFR 11/12/2019 OSSME-4083
//IF RealRDD() == "CTREE"
	IF TQual = 1
	   INDEX ON WKQTD TO (WorkFile)
	   R_Dados[1]+=" e Qtde."
	ELSE
	   INDEX ON WKVAL TO (WorkFile)
	   R_Dados[1]+=" e Valor"
	ENDIF

   INDEX ON WK_ORD TO (WorkFile2)

   SET INDEX TO (WorkFile),(WorkFile2)
   
   TRB->(DBSETORDER(1))
   TRB->(DBGOTOP())
   nRecnoTrb:=TRB->(EasyRecCount("TRB"))
   DO WHILE TRB->(!EOF())
      TRB->WK_ORD:=nRecnoTrb//Alltrim(Str(nRecnoTrb))
      nRecnoTrb--
      TRB->(DBSKIP())
   ENDDO

   TRB->(DBSETORDER(2))
   TRB->(DBGOTOP())

/*ELSE
	IF TQual = 1
	   INDEX ON WKQTD TO (WorkFile) 
	   R_Dados[1]+=" e Qtde."
	ELSE
	   INDEX ON WKVAL TO (WorkFile) 
	   R_Dados[1]+=" e Valor"
	ENDIF
ENDIF
*/

Return .T.              

*---------------------------------------------------------------------------
FUNCTION TR300Grava(PQual,PQtd,PVal)
*---------------------------------------------------------------------------
LOCAL b_test:={ || IF(PQual=1,IF(PQtd#0,.T.,.F.),IF(PVal#0,.T.,.F.)) }
LOCAL cDesc, mDescr                                                      

PRIVATE bBusca:={|cod,alias,campo| (alias)->(dbsetorder(1)) ,;
                                 (alias)->(DbSeek(xFilial(alias)+cod)),;
                                 Eval(FieldWBlock(campo,Select(alias))) }

IF(EasyEntryPoint("EICTR300"),Execblock("EICTR300",.F.,.F.,"TR300GRAVA"),)//chiba

IF EVAL(b_test)
   TRB->( DBAPPEND() )
   TRB->WKCOD_I := IF(TArq # ITEM_ARQ,SWK->WK_CODIGO,SWJ->WJ_CODIGO)
   cDesc:=Eval(bBusca,TRB->WKCOD_I,aArq[TArq,1],aArq[TArq,2])
   mDescr:= MSMM(cDesc,30)
   TRB->WKDES   := IF(TArq # ITEM_ARQ,MEMOLINE(cDesc,30,1),MEMOLINE(mDescr,30,1))
   TRB->WKQTD   := PQtd
   TRB->WKVAL   := PVal
   MQtdTot+=PQtd ; MValTot+=PVal ; PQtd:=PVal:=0
ENDIF
RETURN NIL

*-------------------*
FUNCTION TR300Tot()
*-------------------*
LOCAL MLin:=PROW() + 1

// T_Len --> private array da funcao relatorio, que contem na coluna 1 o
//           tamanho do campo e na coluna 2 a coluna a ser impressa. Cada
//           ocorrencia se refere a um campo em conformidade com o especifi-
//           cado em R_Campos (vide inicio deste programa - MJBarros)

@ MLin,T_Len[2,2] SAY REPL("-",T_Len[2,1])
@ MLin,T_Len[3,2] SAY REPL("-",T_Len[3,1])
@ MLin,T_Len[4,2] SAY REPL("-",T_Len[4,1])
MLin++
@ MLin,T_Len[2,2] SAY TRAN(MQtdTot,MPictQt)
@ MLin,T_Len[3,2] SAY TRAN(MValTot,'@E 999,999,999,999.99')
@ MLin,T_Len[4,2] SAY TRAN(MParTot,'@E 999.99')
RETURN .T.    

*----------------------------------------------------------------------------
FUNCTION TR300Graf()
*----------------------------------------------------------------------------
// Para cada tipo de selecao e' determinado o tamanho maximo da tabela (nCols)
// e o tamanho do campo codigo a fim de evitar que seja gerada um tabela
// muito grande e ocasione problemas de memoria. Isto ocorreria no caso de
// haver mais de 4096 entradas. Quando o tamanho maximo e' antigido os
// registros restantes sao acumulados em uma unica entrada.
// Para qualquer alteracao no tamanho dos campos CCCOD, FBCOD, DECOD, COCOD,
// AGCOD E CICOD_I deve ser providenciada a alteracao na variavel nLenCod

LOCAL nOldRec:=RECNO(), cCod_I, nPartic, lEstourou:=.F., nItens:=0

LOCAL aABC:={}, aLegenda:={}, nCols, nLenCod


DO CASE
   CASE TArq == ITEM_ARQ
        nLenCod:= 5
        nCols  := 11

   CASE TArq == FORN_ARQ .OR. TArq == CLIE_ARQ .OR. TArq == CCUS_ARQ
        nLenCod:= 6
        nCols  :=09

   CASE TArq == DESP_ARQ .OR. TArq == COMP_ARQ .OR. TArq == AGEN_ARQ
        nLenCod:= 3
        nCols  :=18
ENDCASE

TRB->( DBGOTOP() )

WHILE ! TRB->( EOF() )

  IF ! lEstourou
     IF ++nItens > nCols
        lEstourou:=.T.
        nPartic:=0
        cCod_I:=PADC('...',nLenCod)
        AADD(aLegenda,cCod_I) //+' - "DEMAIS CODIGOS"')
        AADD(aLegenda,"DEMAIS CODIGOS")
     ELSEIF TArq # ITEM_ARQ
        cCod_I:=STRZERO(ALLTRIM(TRB->WKCOD_I),nLenCod) //PADL(ALLTRIM(TRB->WKCOD_I),nLenCod)
        AADD(aLegenda,cCod_I) //+' - '+TRB->WKDES)
        AADD(aLegenda,MEMOLINE(TRB->WKDES,30,1))
     ELSE
        cCod_I:=RIGHT(ALLTRIM(TRB->WKCOD_I),nLenCod)
        AADD(aLegenda,cCod_I) //+' - '+TRAN(WKCOD_I,MPictItem)+' '+TRB->WKDES)
        AADD(aLegenda,MEMOLINE(TRB->WKDES,30,1))
     ENDIF
  ENDIF

  IF   lEstourou
       nPartic+=TRB->WKPARTIC
  ELSE
       AADD(aABC,{TRB->WKPARTIC,cCod_I})
  ENDIF

  TRB->( DBSKIP() )
ENDDO

IF   lEstourou
     nPartic+=TRB->WKPARTIC
     AADD(aABC,{nPartic,cCod_I})
ENDIF



AV_GRAF(aABC,.F.,T_Opcoes[TArq],STR0030+; //"% Participacao "
        IF(TQual=1,Quantidade,Valor),STR0031,aLegenda) //"CURVA ABC"

TRB->( DBGOTO(nOldRec) )

*----------------------------------------------------------------------------
Function TR300ValMes(TMes)
*----------------------------------------------------------------------------
IF TMes > 12 .OR. TMes < 0
   Help("",1,"AVG0001017") //"Mês Inválido"###"Infomação"
   Return .F.
Endif

Return .T.   

*----------------------------------------------------------------------------
Function TR300ValAno(TAno,MTipo)
*----------------------------------------------------------------------------
//SWJ ou SWK
DbSetOrder(1)

IF Empty(Val(TAno))
   Help("",1,"AVG0001018") //"Ano não preenchido"###"Infomação"
   Return .F.
ElseIf !DbSeek(xFilial()+MTipo+TAno)
   Help("",1,"AVG0001019",,Space(1)+ALLTRIM(T_Opcoes[TArq])+" no ano de "+TAno,1,28) //MCF - 24/07/2015 //"Não existem registros para "###" no ano de "###"Infomação"
   Return .F.
Endif

Return .T.

*------------------*
Function TR300HLP()
*------------------*
LOCAL oDlg, oPanel, FileWork, Tb_Campos:={}, OldArea:=SELECT()
LOCAL aStru:={}, cArq:=aArq[Tarq,1], nOpcao:=0

DbSelectArea(cArq)

aStru:={ {"WK_COD" ,"C",LEN(FIELDGET(FIELDPOS(cCampoF4))),0} ,;
         {"WK_DESC","C",LEN(FIELDGET(FIELDPOS(cDescCpo))),0} }

IF(EasyEntryPoint("EICTR300"),Execblock("EICTR300",.F.,.F.,"TR300HLP"),)


IF cDescCpo == "B1_DESC_P"
   aStru[2,3]:=36
ENDIF

IF ReadVar() <> "TCODIGO"
   DbSelectArea(OldArea)
   RETURN .F.
ENDIF

AADD(Tb_Campos,{"WK_COD" ,,STR0037}) //"Codigo"
AADD(Tb_Campos,{"WK_DESC",,STR0038}) //"Descricao"

IF SELECT("WorkHP") <> 0
   WorkHP->(dbcloseAREA())
ENDIF

FileWork := E_CriaTrab(,aStru,"WorkHP") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

DBSELECTAREA(cArq)

(cArq)->(DBSEEK(xFilial(cArq)))
IF(EasyEntryPoint("EICTR300"),Execblock("EICTR300",.F.,.F.,"SEEKHLP"),)//chiba

Processa({|lEnd| TR300GRHP(cArq)},STR0039 ) //"Gerando Help"

DEFINE MSDIALOG oDlg TITLE STR0040+T_Opcoes[TArq]  FROM 4,3 TO 20,55 OF oMainWnd    //"Help "
        @00,00 MsPanel oPanel Prompt "" Size 50,60 //LRL 27/04/04
        DEFINE SBUTTON FROM 05,11 TYPE 1 ACTION (nOpcao:=1,oDlg:End()) ENABLE OF oPanel PIXEL
        DEFINE SBUTTON FROM 20,11 TYPE 2 ACTION (nOpcao:=0,oDlg:End()) ENABLE OF oPanel PIXEL

         dbSelectArea("WorkHP")
         dbGoTop()

         oMark:= MsSelect():New("WorkHP",,,TB_Campos,@lInverte,@cMarca,{20,6,100,160})
         oMark:bAval:={||nOpcao:=1,oDlg:End()}
		 oPanel:Align:=CONTROL_ALIGN_RIGHT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		 oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
ACTIVATE MSDIALOG oDlg //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   If nOpcao == 1
      TCodigo:=WorkHP->WK_COD
   EndIf
   WorkHP->(E_EraseArq(FileWork))   
   SELECT(OldArea)

RETURN .T.  

*----------------------*
Function TR300GRHP(cArq)
*----------------------*
LOCAL nRecno      :=RECNO(), cDesc
LOCAL bPrefixo    := {|| IF(Left(cArq,1) == "S", Right(cArq,2), cArq) }
LOCAL nCpoFilial  := (cArq)->(FieldPos(Eval(bPrefixo)+"_FILIAL"))
PRIVATE bFilter   := {||.T.}//chiba

ProcRegua(Easyreccount(cArq))

IF(EasyEntryPoint("EICTR300"),Execblock("EICTR300",.F.,.F.,"FILTER"),)//chiba

WHILE ! EOF() .AND. (cArq)->(FIELDGET(nCpoFilial)) == xFilial(cArq).AND. EVAL(bFilter)//chiba

  cDesc:=FIELDGET(FIELDPOS(cDescCpo))
  
  IF cDescCpo == "B1_DESC_P"    // 
     cDesc:=MSMM(SB1->B1_DESC_P,36,1)
  ENDIF
  
  WorkHP->(DBAPPEND())
  WorkHP->WK_COD := FIELDGET(FIELDPOS(cCampoF4))
  WorkHP->WK_DESC:= cDesc
  IncProc(STR0041+WorkHP->WK_COD+STR0042+ALIAS()) //"Gravando Codigo "###" do Arquivo "
  
  IF(EasyEntryPoint("EICTR300"),Execblock("EICTR300",.F.,.F.,"TR300GRHP"),)//chiba
  
  DBSKIP()
END
RETURN .T.             

*---------------------------*
FUNCTION TR300ApagaCtree()
*---------------------------*
//TRP-18/03/08
//MFR 11/12/2019 OSSME-4083
//IF RealRDD() == "CTREE"   
   FErase(WorkFile2+OrdBagExt())
//ENDIF

Return Nil

***************************
Static Function ReportDef()
***************************
Local oReport

aTabelas := {"SWK"}
aOrdem   := {}

//Parâmetros:            Relatório ,Titulo  ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EICTR300",cRepTit ,""       ,{|oReport| ReportPrint(oReport)}, STR0008 + " " + STR0009)
   
//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Estatísticas de Compra",aTabelas,aOrdem)

TRCell():New(oSecao1, 'WKCOD_I' , 'TRB', MDescArq, MPictItem               , LEN(TRB->WKCOD_I) , ,  )
TRCell():New(oSecao1, 'WKDES'   , 'TRB', STR0038 , '@!'                    , 30 , ,  )
TRCell():New(oSecao1, 'WKQTD'   , 'TRB', STR0005 , MPictQt                 , 13 , ,  )
TRCell():New(oSecao1, 'WKVAL'   , 'TRB', STR0006 , '@E 999,999,999,999.99' , 15 , ,  )
TRCell():New(oSecao1, 'WKPARTIC', 'TRB', STR0007 , '@E 999.99'             , 6  , ,  )

//TRP-17/10/2006 -Espaçamento entre as colunas
oReport:Section("Estatísticas de Compra"):Cell('WKCOD_I'   ):SetColSpace(7)
oReport:Section("Estatísticas de Compra"):Cell('WKDES'     ):SetColSpace(10)
oReport:Section("Estatísticas de Compra"):Cell('WKVAL'     ):SetColSpace(7)
oReport:Section("Estatísticas de Compra"):Cell('WKQTD'     ):SetColSpace(7)

oReport:Section("Estatísticas de Compra"):Cell('WKQTD'     ):SetHeaderAlign("RIGHT")
oReport:Section("Estatísticas de Compra"):Cell('WKVAL'     ):SetHeaderAlign("RIGHT")

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************

oReport:SetMeter (TRB->(EasyRecCount("TRB")))

TRB->(DBGOTOP())


oSecao1:Init()

Do While TRB->(!EOF()) .And. !oReport:Cancel()
   oSecao1:PrintLine()
   
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   TRB->(DBSKIP())
Enddo

oSecao1:Finish()
TRB->(DBGOTOP())

Return .T.


*----------------------------------------------------------------------------
*     FIM DO PROGRAMA TR300
*----------------------------------------------------------------------------
