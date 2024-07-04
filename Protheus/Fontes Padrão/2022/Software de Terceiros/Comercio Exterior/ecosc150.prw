#INCLUDE "ECOSC150.ch"
#INCLUDE "Average.ch"
#INCLUDE "TOPCONN.CH"

#xTranslate :COURIER_10         => \[1\]
#xTranslate :COURIER_10_NEGRITO => \[2\]
#xTranslate :COURIER_12_NEGRITO => \[3\]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ ECOSC150 ³ Autor ³ Thomaz               ³ Data ³ 07.11.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Relatório de Saldo de Clientes                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observação³ Uso - Customização - Taurus                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//AAF - 09/08/04 - 
//Criado opção de relatório enviado ao Excel ou em arquivo DBF/TXT. 
*/

*----------------------*
Function ECOSC150()
*----------------------*
Local nOpca:= 1, lRet := .F.
Local bOk:={||(nOpca:=1, oDlg:End())}
Local bCancel:={||(nOpca:=0,oDlg:End())}
dbselectarea("EEC")
Private ExisInvExp:= .F.
Private dDtIni, dDtFim, cCli:=Space(Len("A1_COD")), lTop
Private cFilECF:= xFilial("ECF"), cFilSA1:= xFilial("SA1"), cPictInv
Private cFilECA:= xFilial("ECA"), cFilEF3:= xFilial("EF3"), oProcess
Private cFilEEQ:= xFilial("EEQ"), cFilEC6:= xFilial("EC6")
Private aHeader[0], cPictDtEmb:= AVSX3("EEC_DTEMBA", 06)
Private FileWork, nPgtAnt:=nPgtAntUs:= 0, cFilSX5:= xFilial("SX5"), cFilEEC:=xFilial("EEC")
Private cPictVl:= AVSX3("ECF_VALOR", 06), cPictCont:= AVSX3("EF3_CONTRA", 06), cFilEF1  := xFilial("EF1")
Private nPgto:= nVariacao:= nTransf:= nDescont:=0, lProc
Private nPgtoUs:= nVariacaoUs:= nTransfUs:= nDescoUs:= 0, nTotECA:=0, nTotECF:=0
Private InvQuery, InvQuery1, FileWork1
private cTPMODU := ""
private lTemTPMODU
PRIVATE lTemEF1PRA := .F.
private bTPMODUECF
Private lECFTPFORN := IF (ECF->( FieldPos("ECF_TP_FOR") ) > 0, .T. , .F.)     //LRL 28/09/04
Private lECATPFORN := IF (ECA->( FieldPos("ECA_TP_FOR") ) > 0, .T. , .F.)     //LRL 28/09/04
SX3->(DbSetOrder(2))
lExisInvExp:= SX3->(DbSeek("ECA_INVEXP")) .And. SX3->(DbSeek("ECF_INVEXP"))
lTemTPMODU := SX3->(DbSeek("ECF_TPMODU"))
lTemEF1PRA := SX3->(DbSeek("EF1_PRACA"))
Private lVerOut := Posicione("SX2",1,"ECF","X2_MODO") == "E" .AND. VerSenha(115) //AAF - 17/12/04 - Indica se o usuário pode ver outras filiais.
SX3->(DbSetOrder(1))

EEQ->(DbSetOrder(4) ) //Alcir Alves - 11-05-05
 
If lTemTPMODU
   cTPMODU:='EXPORT'
   bTPMODUECF := {|| ECF->ECF_TPMODU <> 'IMPORT' }
Else
   bTPMODUECF := {|| .T. }
EndIf

If(lExisInvExp, cPictInv:= AVSX3("ECF_INVEXP", 06), cPictInv:= AVSX3("ECF_INVOIC", 06))

#IFDEF TOP
   lTop := .T.
#ElSE
   lTop := .F.
#ENDIF

//ASK 12/02/07 17:48 - Incluso no AtuSx do P9R1 
//SC150_ACDIC()

While .T.
   dbselectarea("ECF") //Alcir Alves - correção do erro na geração para excel ou texto no inicio do loop - 15-04-05
   Private cFiliais := "'"
   Private aFiliais := AvgSelectFil(.T.,"ECF")
   Private lFilOri:=iif(len(aFiliais)==1 .and. aFiliais[1]=="",.f.,.t.)   
   if aFiliais[1]#"WND_CLOSE" //Alcir Alves - 15-03-05 - validação do retorno da função de seleção de multifilial
      aEval(aFiliais,{|x,y| cFiliais += x + iIF(y == Len(aFiliais),"'","','")})
      dbSelectArea("ECF")
      If !Pergunte("ECOSC1",.T.)
         Return .F.
      EndIf
      cCli   := mv_par01
      cGrpCli:= mv_par02
      dDtIni := mv_par03
      dDtFim := mv_par04
      nTipRel:= mv_par05

      If !E_PERIODO_OK(@dDtIni,@dDtFim)
         Loop
      Endif

      If nOpca == 1
         ECOSC150GERA()
      Else
         Loop
      Endif
   
      If Select("Work") <> 0
         Work->(dbCloseArea())
      Endif
   
      ECF->(dbSetOrder(1))
      ECA->(dbSetOrder(1))
      EF3->(dbSetOrder(1))
   ELSE
      RETURN .F.
   ENDIF
EndDo

Return

*-----------------------------*
Static Function ECOSC150GERA()
*-----------------------------*
Private cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatório "
Private cDesc2         := STR0002 //"de Saldo de Clientes."
Private cDesc3         := ""
Private cPict          := ""
Private imprime        := .T.

Private titulo       := STR0003+dtoc(dDtIni)+STR0011+dtoc(dDtFim) //"Relatório de Saldo de Clientes - (Período de "###" até "
Private nLin         := 80
Private Cabec1       := ""
Private Cabec2       := ""
Private cString      := "SA1"
Private CbTxt        := ""
//Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "ECOSC150"
Private nTipo        := 18
Private aReturn      := { STR0004, 1, STR0005, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
//Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "ECOSC150" // Coloque aqui o nome do arquivo usado para impressao em disco
Private nPagina      := 0
Private TituloRel, lImprime:= .F.

SC150CriaWork()

WorkECA->(DbCloseArea())
Erase(FileWork1+TEOrdBagExt())

Return .T.

*-------------------------------*
Static Function SC150CriaWork()
*-------------------------------*
aEstru := {}
AADD(aEstru,{"FILIAL"  , AVSX3("ECF_FILIAL", 02), AVSX3("ECF_FILIAL", 03), AVSX3("ECF_FILIAL", 04)})//AAF 17/12/04
AADD(aEstru,{"COD_CLI" , AVSX3("A1_COD", 02)    , AVSX3("A1_COD", 03)    , AVSX3("A1_COD", 04)})
AADD(aEstru,{"NOM_CLI" , AVSX3("A1_NOME", 02)   , AVSX3("A1_NOME", 03)   , AVSX3("A1_NOME", 04)})
AADD(aEstru,{"MOEDA"   , AVSX3("ECF_MOEDA", 02) , AVSX3("ECF_MOEDA", 03) , AVSX3("ECF_MOEDA", 04)})
If lExisInvExp
   AADD(aEstru,{"INVOICE" , AVSX3("ECF_INVEXP", 02), AVSX3("ECF_INVEXP", 03), AVSX3("ECF_INVEXP", 04)})
Else
   AADD(aEstru,{"INVOICE" , AVSX3("ECF_INVOIC", 02), AVSX3("ECF_INVOIC", 03), AVSX3("ECF_INVOIC", 04)})
Endif   
AADD(aEstru,{"SLD_ANT" , AVSX3("ECF_VALOR", 02) , AVSX3("ECF_VALOR", 03) , AVSX3("ECF_VALOR", 04)})
AADD(aEstru,{"PGTO"    , AVSX3("ECF_VALOR", 02) , AVSX3("ECF_VALOR", 03) , AVSX3("ECF_VALOR", 04)})
AADD(aEstru,{"VARIACAO", AVSX3("ECF_VALOR", 02) , AVSX3("ECF_VALOR", 03) , AVSX3("ECF_VALOR", 04)})
AADD(aEstru,{"TRANSF"  , AVSX3("ECF_VALOR", 02) , AVSX3("ECF_VALOR", 03) , AVSX3("ECF_VALOR", 04)})
AADD(aEstru,{"SLD_ATU" , AVSX3("ECF_VALOR", 02) , AVSX3("ECF_VALOR", 03) , AVSX3("ECF_VALOR", 04)})
AADD(aEstru,{"SLDAN_US", AVSX3("ECF_VL_MOE", 02), AVSX3("ECF_VL_MOE", 03), AVSX3("ECF_VL_MOE", 04)})
AADD(aEstru,{"PGT_US"  , AVSX3("ECF_VL_MOE", 02), AVSX3("ECF_VL_MOE", 03), AVSX3("ECF_VL_MOE", 04)})
AADD(aEstru,{"TRANS_US", AVSX3("ECF_VL_MOE", 02), AVSX3("ECF_VL_MOE", 03), AVSX3("ECF_VL_MOE", 04)})
AADD(aEstru,{"SLD_US"  , AVSX3("ECF_VL_MOE", 02), AVSX3("ECF_VL_MOE", 03), AVSX3("ECF_VL_MOE", 04)})
AADD(aEstru,{"CONTRA"  , "C", 100, 0})
AADD(aEstru,{"TIPO"    , AVSX3("EF3_TP_EVE", 02), AVSX3("EF3_TP_EVE", 03), AVSX3("EF3_TP_EVE", 04)})
AADD(aEstru,{"DTEMB"   , AVSX3("EEC_DTEMBA", 02), AVSX3("EEC_DTEMBA", 03), AVSX3("EEC_DTEMBA", 04)})

If lFilOri
   AADD(aEstru,{"FILORI"  , AVSX3("ECF_FILORI", 02), AVSX3("ECF_FILORI", 03), AVSX3("ECF_FILORI", 04)})//AAF 17/12/04
Endif

aEstru1 := {}
AADD(aEstru1,{"ECA_FILIAL" , AVSX3("ECA_FILIAL", 02), AVSX3("ECA_FILIAL", 03), AVSX3("ECA_FILIAL", 04)})
AADD(aEstru1,{"ECA_TPMODU" , AVSX3("ECA_TPMODU", 02), AVSX3("ECA_TPMODU", 03), AVSX3("ECA_TPMODU", 04)})
AADD(aEstru1,{"ECA_PREEMB" , AVSX3("ECA_PREEMB", 02), AVSX3("ECA_PREEMB", 03), AVSX3("ECA_PREEMB", 04)})
If lExisInvExp
   AADD(aEstru1,{"ECA_INVEXP" , AVSX3("ECA_INVEXP", 02), AVSX3("ECA_INVEXP", 03), AVSX3("ECA_INVEXP", 04)})
Else
   AADD(aEstru1,{"ECA_INVOIC" , AVSX3("ECA_INVOIC", 02), AVSX3("ECA_INVOIC", 03), AVSX3("ECA_INVOIC", 04)})
Endif
AADD(aEstru1,{"ECA_FORN"   , AVSX3("ECA_FORN", 02)  , AVSX3("ECA_FORN", 03)  , AVSX3("ECA_FORN", 04)})
AADD(aEstru1,{"ECA_DT_CON" , AVSX3("ECA_DT_CON", 02), AVSX3("ECA_DT_CON", 03), AVSX3("ECA_DT_CON", 04)})
AADD(aEstru1,{"ECA_ID_CAM" , AVSX3("ECA_ID_CAM", 02), AVSX3("ECA_ID_CAM", 03), AVSX3("ECA_ID_CAM", 04)})
AADD(aEstru1,{"ECA_VALOR"  , AVSX3("ECA_VALOR", 02) , AVSX3("ECA_VALOR", 03) , AVSX3("ECA_VALOR", 04)})
AADD(aEstru1,{"ECA_VL_MOE" , AVSX3("ECA_VL_MOE", 02), AVSX3("ECA_VL_MOE", 03), AVSX3("ECA_VL_MOE", 04)})
AADD(aEstru1,{"ECA_MOEDA"  , AVSX3("ECA_MOEDA", 02) , AVSX3("ECA_MOEDA", 03) , 0})
AADD(aEstru1,{"ECA_CONTRA" , AVSX3("ECA_CONTRA", 02), AVSX3("ECA_CONTRA", 03), 0})
AADD(aEstru1,{"ECA_SEQ" , AVSX3("ECA_SEQ", 02), AVSX3("ECA_SEQ", 03), 0})
AADD(aEstru1,{"ECA_TX_USD" , AVSX3("ECA_TX_USD", 02), AVSX3("ECA_TX_USD", 03), AVSX3("ECA_TX_USD", 04)})
If lFilOri
   AADD(aEstru1,{"ECA_FILORI" , AVSX3("ECA_FILORI", 02), AVSX3("ECA_FILORI", 03), 0})
Endif

//** AAF - 27/09/04 - Inclusão do campo ECA_TP_FOR que indica se o campo FORN guarda o fornecedor ou cliente/importador
If lECATPFORN
   AADD(aEstru1,{"ECA_TP_FOR", AVSX3("ECA_TP_FOR", 02), AVSX3("ECA_TP_FOR", 03), 0})
Endif
//**

FileWork:=E_CriaTrab(,aEstru,"Work")
IndRegua("Work",FileWork+TEOrdBagExt(),"FILIAL+COD_CLI+INVOICE")

FileWork1:=E_CriaTrab(,aEstru1,"WorkECA")
IndRegua("WorkECA",FileWork1+TEOrdBagExt(),"ECA_FILIAL+ECA_TPMODU+ECA_PREEMB+ECA_INVEXP+ECA_FORN")

If lTop
   GeraQuery()
Else
   Processa({|| SC150GrvWork()},STR0014) //"Aguarde... Gravando Dados"
Endif

Return .T.

*--------------------------------*
Static Function SC150GrvWork()
*--------------------------------*
Local nFil
InvTot:= "ECFTMP"
InvTot1:= "ECATMP"
InvQuery:= "ECF"
InvQuery1:= "ECAQuery"
SA1->(DbSetOrder(1))

lProc:= .F.
cContra:= ""
lInicio:= .T.
ECA->(dbSetOrder(13))
ECF->(dbSetOrder(1))
EF1->(dbSetOrder(1))
EEC->(dbSetOrder(1))

//** AAF 18/12/04 - Alterações para tratamentos em multifiliais.
For nFil := 1 To Len(aFiliais)
   ECA->(dbSeek(aFiliais[nFil]+cTPMODU,.T.))
   Do While !ECA->(EOF()) .and. ECA->ECA_FILIAL == aFiliais[nFil]  .and. ECA->ECA_TPMODU <> "IMPORT"
      /*LRL 08/01/04-------------------------------------------------------------------------------------------------------
      If (ECA->ECA_ID_CAM $('107/580/581') .or. Empty(ECA->ECA_PREEMB) .or.;
      (!ECA->ECA_ID_CAM $('500/501') .and. ECA->ECA_TPMODU = "FIEX01") .Or. ( lECATPFORN .AND. ECA->ECA_TP_FOR != '1'))*/
      If (!ECA->ECA_ID_CAM $('101/582/583/584/585/586/587/607/630/801/802/700/116/112/115') .or. Empty(ECA->ECA_PREEMB) .or.;
      (!ECA->ECA_ID_CAM $('500/501') .and. ECA->ECA_TPMODU = "FIEX01") .Or. ( lECATPFORN .AND. ECA->ECA_TP_FOR != '1'))
      //-------------------------------------------------------------------------------------------------------LRL 08/01/04
         ECA->(dbSkip())
         Loop
      EndIf
      WorkECA->(dbAppend())
      WorkECA->ECA_FILIAL := aFiliais[nFil]
      WorkECA->ECA_TPMODU := ECA->ECA_TPMODU
      WorkECA->ECA_PREEMB := ECA->ECA_PREEMB
   If lExisInvExp
      WorkECA->ECA_INVEXP := ECA->ECA_INVEXP
   Else
      WorkECA->ECA_INVOIC := ECA->ECA_INVOIC
   EndIf
      WorkECA->ECA_FORN   := ECA->ECA_FORN
   WorkECA->ECA_SEQ   := ECA->ECA_SEQ
      //** AAF 27/09/04 - Guarda o Tipo do Campo FORN ( 1 = Importador/Cliente, 2 = Fornecedor )
      If lECATPFORN
         WorkECA->ECA_TP_FOR := ECA->ECA_TP_FOR
      Endif
      //**
      WorkECA->ECA_DT_CON := ECA->ECA_DT_CON
      WorkECA->ECA_ID_CAM := ECA->ECA_ID_CAM
      WorkECA->ECA_VALOR  := ECA->ECA_VALOR
      WorkECA->ECA_VL_MOE := ECA->ECA_VL_MOE
      WorkECA->ECA_MOEDA  := ECA->ECA_MOEDA
      WorkECA->ECA_CONTRA := ECA->ECA_CONTRA
   WorkECA->ECA_TX_USD := ECA->ECA_TX_USD
      // AAF 18/12/04 - Conceito Multifilial
      If lFilOri
         WorkECA->ECA_FILORI := ECA->ECA_FILORI
      Endif
        
      ECA->(dbSkip())
   EndDo
Next nFil
//**

nTotECF := (InvQuery)->(EasyRecCount())
(InvQuery)->(dbSeek(aFiliais[1]))// AAF 18/12/04 - Conceito Multifilial

oProcess := MsNewProcess():New({|lEnd| CalculaInv(@lEnd)},STR0018,STR0019,.T.) //"Contábil"###"Gerando Realtório"
oProcess:Activate()

Return .T.

*------------------------------*
Static Function GeraQuery(lEnd)
*------------------------------*
Local cQuery, cQuery1, cCondDel:="AND ECF.D_E_L_E_T_ <> '*'", cCondDel1:= "AND ECA.D_E_L_E_T_ <> '*'"
Local cOrigem1:= "EX", cOrigem2:= "CO", cTpModu:= "IMPORT", i
Local cWhere:='', cWhere1:='', cQueryTot, cQueryTo1

InvTot:= "ECFTMP"
InvTot1:= "ECATMP"
InvQuery:= "ECFQuery"
InvQuery1:= "ECAQuery"

cWhere += " ECF.ECF_FILIAL IN("+cFiliais+") AND ((ECF.ECF_INVEXP <> '' OR ECF.ECF_INVEXP <> ' ')"
cWhere += " AND ECF.ECF_TPMODU <> '"+cTpModu+"' "

cWhere += " AND (ECF.ECF_ID_CAM NOT IN('107','580','581'))"

cWhere += " AND (ECF.ECF_ORIGEM = '"+cOrigem1+"' Or (ECF.ECF_ORIGEM = '"+cOrigem2+"' "
cWhere += " AND (ECF.ECF_PREEMB <> '' OR ECF.ECF_PREEMB <> ' '))) OR (ECF.ECF_ID_CAM IN('500','501') AND ECF.ECF_TPMODU = 'FIEX01')) "
If lECFTPFORN
  cWhere += " AND ECF.ECF_TP_FOR = '1' "
Endif
cWhere += If(TcSrvType()<>"AS/400",cCondDel,"")

cQueryTot := " SELECT DISTINCT COUNT(*) TOTALREG FROM "+ RetSqlName('ECF')+ " ECF WHERE "+cWhere

cWhere +=" ORDER BY "+If(lExisInvExp, "ECF.ECF_INVEXP", "ECF.ECF_INVOIC")
cQuery := " SELECT DISTINCT ECF.* FROM "+ RetSqlName('ECF')+ " ECF WHERE "+cWhere

cQuery:=ChangeQuery(cQuery)
TcQuery cQuery ALIAS (InvQuery) NEW

TcSetField(InvQuery,"ECF_DTCONT","D")
TcSetField(InvQuery,"ECF_DTCONV","D")
TcSetField(InvQuery,"ECF_PARIDA","N", AVSX3("ECF_PARIDA",3), AVSX3("ECF_PARIDA",4))
TcSetField(InvQuery,"ECF_FLUTUA","N", AVSX3("ECF_FLUTUA",3), AVSX3("ECF_FLUTUA",4))
TcSetField(InvQuery,"ECF_VL_MOE","N", AVSX3("ECF_VL_MOE",3), AVSX3("ECF_VL_MOE",4))
TcSetField(InvQuery,"ECF_VALOR","N", AVSX3("ECF_VALOR",3), AVSX3("ECF_VALOR",4))

cQueryTot:=ChangeQuery(cQueryTot)
TcQuery cQueryTot ALIAS (InvTot) NEW

If Select(InvTot) > 0
   nTotECF := (InvTot)->TOTALREG
   (InvTot)->(DbCloseArea())
Else
   nTotECF := 0
Endif
cWhere1 := " ECA.ECA_FILIAL IN("+cFiliais+") AND ECA.ECA_TPMODU <> '"+cTpModu+"' AND NOT (ECA.ECA_ID_CAM NOT IN('101','582','583','584','585','586','587','607','630','801','802','700','116','112','115') "
cWhere1 += " OR (ECA.ECA_PREEMB = '' OR ECA.ECA_PREEMB = '"+Space(Avsx3("ECA_PREEMB",3))+"') "
cWhere1 += " OR (ECA.ECA_ID_CAM NOT IN('500/501') AND ECA.ECA_TPMODU = 'FIEX01')) "
If lECATPFORN
  cWhere1 += " AND ECA.ECA_TP_FOR = '1' "
Endif
cWhere1 += If(TcSrvType()<>"AS/400",cCondDel1,"")

cQueryTo1 := " SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECA")+" ECA WHERE "+cWhere1

cWhere1 +=" ORDER BY ECA.ECA_FILIAL, ECA.ECA_TPMODU, ECA.ECA_PREEMB, ECA.ECA_INVEXP, ECA.ECA_FORN"

cQuery1 := " SELECT ECA.ECA_FILIAL, ECA.ECA_TPMODU, ECA.ECA_PREEMB, ECA.ECA_INVEXP, "
cQuery1 += " ECA.ECA_FORN, ECA.ECA_DT_CON, ECA.ECA_ID_CAM, ECA.ECA_VALOR, ECA.ECA_VL_MOE, ECA.ECA_MOEDA, ECA.ECA_CONTRA "
//** AAF 27/09/04 - Guarda o Tipo do Campo FORN ( 1 = Importador/Cliente, 2 = Fornecedor )
If lECATPFORN
   cQuery1 += " , ECA.ECA_TP_FOR "
Endif
cQuery1 += " FROM "+RetSqlName("ECA")+" ECA WHERE "+cWhere1

cQuery1:=ChangeQuery(cQuery1)
TcQuery cQuery1 ALIAS (InvQuery1) NEW

TcSetField(InvQuery1,"ECA_DT_CON","D")
TcSetField(InvQuery1,"ECA_VL_MOE","N", AVSX3("ECA_VL_MOE",3), AVSX3("ECA_VL_MOE",4))
TcSetField(InvQuery1,"ECA_VALOR" ,"N", AVSX3("ECA_VALOR" ,3), AVSX3("ECA_VALOR" ,4))

dbSelectArea(InvQuery1)
Do While !(InvQuery1)->(EOF())
   WorkECA->(RecLock("WorkECA",.T.))
   FOR i := 1 TO FCount()
      WorkECA->&(FIELDNAME(i)) := FieldGet(i)
   NEXT i
   WorkECA->(msUnlock())
   (InvQuery1)->(dbSkip())
EndDo

(InvQuery1)->(dbCloseArea())

cQueryTo1:=ChangeQuery(cQueryTo1)
TcQuery cQueryTo1 ALIAS (InvTot1) NEW

If Select(InvTot1) > 0
   nTotECA := (InvTot1)->TOTALREG
   (InvTot1)->(DbCloseArea())
Else
   nTotECA := 0
Endif

oProcess := MsNewProcess():New({|lEnd| CALCULAINV(@lEnd)},STR0018,STR0019,.T.) //"Contábil"###"Gerando Realtório"
oProcess:Activate()

Return .T.

*--------------------------------*
Static Function CALCULAINV(lEnd)
*--------------------------------*
Local cInvAtu:= Space(Len(ECF->ECF_INVEXP))
Local lProc:= .F., cContra:= ""
Local aContratos:={}
Local nFil

oProcess:SetRegua1(2)
oProcess:IncRegua1(STR0020) //"Lendo Arquivos 1 / 2 Eventos do Pagto Antec./Adiant."

oProcess:SetRegua2(nTotECF)

SA1->( DbSetOrder(1) )//AAF

//AAF 21/12/04 - Calcula para cada filial selecionada.
For nFil := 1 To Len(aFiliais)
   If !lTop
      (InvQuery)->( dbSeek(aFiliais[nFil]) )
   Endif
   Do While !(InvQuery)->(EOF()) .And. aFiliais[nFil] == (InvQuery)->ECF_FILIAL

      If lEnd
         If lEnd:=MsgYesNo(STR0023, STR0024) //"Tem certeza que deseja cancelar?"###"Atenção"
            if Select(InvQuery) > 0
               (InvQuery)->( dbCloseArea() )
            endif
            if Select(InvQuery1) > 0
               (InvQuery1)->( dbCloseArea() )
            endif
            lAbortPrint:= .T.
            MS_FLUSH()
            Return .F.
         EndIf
      EndIf

      oProcess:IncRegua2(STR0021+Alltrim((InvQuery)->ECF_INVEXP)) //"1 / 1  Invoice: "
   
      If !lTop
/*LRL 08/01/04--------------------------------------------------------------------------------------------------
       If !((ECF->ECF_FORN == cCli .or. Empty(cCli)) .and. Eval(bTPMODUECF) .and.;
          (ECF->ECF_ORIGEM == "EX" .Or. (ECF->ECF_ORIGEM == "CO") .And. !Empty(ECF->ECF_PREEMB)) .and.;
          !Empty(ECF->ECF_INVEXP) .and. (!ECF->ECF_ID_CAM $('107/580/581') .OR.;
          Empty(ECF->ECF_NR_CON)) .or. (ECF->ECF_ID_CAM $('500/501') .and. ECF->ECF_TPMODU = "FIEX01"))*/                
         If !((ECF->ECF_FORN == cCli .or. Empty(cCli)) .and. Eval(bTPMODUECF) .and.;
            (ECF->ECF_ORIGEM == "EX" .Or. (ECF->ECF_ORIGEM == "CO") .And. !Empty(ECF->ECF_PREEMB)) .and.;
            !Empty(ECF->ECF_INVEXP) .and. (ECF->ECF_ID_CAM $('101/582/583/584/585/586/587/607/630/801/802/700/116/112/115') .OR.;
            Empty(ECF->ECF_NR_CON)) .or. (ECF->ECF_ID_CAM $('500/501') .and. ECF->ECF_TPMODU = "FIEX01"))
//--------------------------------------------------------------------------------------------------LRL 08/01/04         
            (InvQuery)->(dbSkip())
            Loop
         EndIf
      
      EndIf
           
      // AAF - 27/09/04 - Pega somente o que for cliente
      If !lTop .And. lECFTPFORN .AND. (InvQuery)->ECF_TP_FOR <> '1'
         (InvQuery)->( dbSkip() )
         LOOP
      Endif
      // AAF - 16/08/04 - Filtro por Cliente
      If !Empty(cCli)
         If (InvQuery)->ECF_FORN <> cCli
            (InvQuery)->(dbSkip())
            LOOP         
         Endif
      Endif
   
      // AAF - 16/08/04 - Filtro por Grupo de Cliente
      If !Empty(cGrpCli)
         If SA1->( dbSeek(aFiliais[nFil]+AVKey((InvQuery)->ECF_FORN, "A1_COD")) )// AAF 18/12/04 - Conceito Multifilial
            If SA1->A1_GRPVEN <> cGrpCli
               (InvQuery)->(dbSkip())
               Loop
            Endif
         Else
           (InvQuery)->(dbSkip())
            Loop
         Endif
      Endif
   
      cContra:= aFiliais[nFil]+(InvQuery)->ECF_CONTRA
   
      EEC->(dbSeek(iIF(lFilOri,(InvQuery)->ECF_FILORI,aFiliais[nFil])+(InvQuery)->ECF_PREEMB))//AAF 17/12/04 - Conceito Multifilial
      
      If Empty((InvQuery)->ECF_CONTRA)
         If EEC->EEC_COBCAM $ cNao .OR. (EEC->EEC_STATUS == '*' .AND. !Empty(EEC->EEC_FIM_PE) .AND. EEC->EEC_FIM_EPE < dDtIni);
            .OR. ((EEC->EEC_STATUS == '*' .AND. !Empty(EEC->EEC_FIM_PE) .AND. EEC->EEC_FIM_PE >= dDtIni .AND. EEC->EEC_FIM_PE <= dDtFim))//.and. !ECF->(DbSeek(cFilECF+cTPMODU+'EX'+EEQ->EEQ_PREEMB))
            (InvQuery)->(dbSkip())
            Loop
         EndIf
      Else
      	 EF1->(dbSeek(iIF(lFilOri,ECF->ECF_FILORI,aFiliais[nFil])+ECF->ECF_CONTRA))// AAF 17/12/04 - Conceito Multifilial
         If !Empty(EF1->EF1_DT_ENCE) .and. EF1->EF1_DT_ENCE < dDtIni
            (InvQuery)->(dbSkip())
            Loop
         Endif
      EndIf
   
      //CONSIDERAR OS EVENTOS 101, 582, 583, -607, -116, -112
   
      IF (InvQuery)->ECF_DTCONT >= dDtIni .And. (InvQuery)->ECF_DTCONT <= dDtFim
         If (InvQuery)->ECF_ID_CAM $ "115/112/801"
            nTransf  += (InvQuery)->ECF_VALOR
            nTransfUs+= (InvQuery)->ECF_VL_MOE
         ElseIf (InvQuery)->ECF_ID_CAM $ "500/501" .and. (InvQuery)->ECF_TP_EVE # '01'
            nVariacao += (InvQuery)->ECF_VALOR
         ElseIf (InvQuery)->ECF_ID_CAM $ "582/583"
            nVariacao += (InvQuery)->ECF_VALOR
         ElseIf (InvQuery)->ECF_ID_CAM $ "101"
            nPgtAnt  += (InvQuery)->ECF_VALOR
            nPgtAntUs+= (InvQuery)->ECF_VL_MOE
         ElseIf (InvQuery)->ECF_ID_CAM $ "607/630"
            nPgto  += (InvQuery)->ECF_VALOR
            nPgtoUs+= (InvQuery)->ECF_VL_MOE
         Else
            (InvQuery)->(dbSkip())
            Loop
         Endif
         lProc:= .T.
      ElseIf (InvQuery)->ECF_DTCONT <= dDtIni
         If Left((InvQuery)->ECF_ID_CAM, 1) $ "5" .Or. (InvQuery)->ECF_ID_CAM  $ "115/112/607"
            If Left((InvQuery)->ECF_ID_CAM, 1) == "5"
               nPgtAnt  += (InvQuery)->ECF_VALOR
               nPgtAntUs+= (InvQuery)->ECF_VL_MOE
            Else
               nPgtAnt  -= (InvQuery)->ECF_VALOR
               nPgtAntUs-= (InvQuery)->ECF_VL_MOE
            Endif
            lProc:= .T.
         Endif
      Endif

      If lProc

         If !Work->(dbSeek(aFiliais[nFil]+AVKey( (InvQuery)->ECF_FORN, "A1_COD" )+(InvQuery)->ECF_INVEXP))// AAF 17/12/04 - Conceito Multifilial
            Work->(DBAPPEND())
         
            SA1->(dbSeek(aFiliais[nFil]+(InvQuery)->ECF_FORN))// AAF 17/12/04 - Conceito Multifilial
            
            // AAF 17/12/04 - Conceito Multifilial
            Work->FILIAL   := aFiliais[nFil]
            Work->COD_CLI  := (InvQuery)->ECF_FORN
            Work->NOM_CLI  := SA1->A1_NOME
            Work->MOEDA    := (InvQuery)->ECF_MOEDA
            Work->INVOICE  := (InvQuery)->ECF_INVEXP
            Work->DTEMB    := EEC->EEC_DTEMBA
            Work->CONTRA   := cContra
            If !Empty(cContra)
               aAdd(aContratos,{aFiliais[nFil], (InvQuery)->ECF_PREEMB, Work->INVOICE, cContra})// AAF 17/12/04 - Conceito Multifilial
            EndIf
            
            //em Reais
            Work->PGTO     := nPgto
            Work->SLD_ANT  := nPgtAnt
            Work->VARIACAO := nVariacao
            Work->TRANSF   := nTransf
            Work->SLD_ATU  := If(ABS((nPgtAnt-nPgto+nVariacao-nTransf)) <= 0.05, 0, (nPgtAnt-nPgto+nVariacao-nTransf))

            //na Moeda
            Work->PGT_US   := nPgtoUs
            Work->SLDAN_US := nPgtAntUs
            Work->TRANS_US := nTransfUs
            Work->SLD_US   := If(ABS((nPgtAntUs-nPgtoUs-nTransfUs)) <= 0.05, 0, (nPgtAntUs-nPgtoUs-nTransfUs))         
         Else
            Work->(RecLock("Work",.F.))

            //em Reais
            Work->PGTO     += nPgto
            Work->SLD_ANT  += nPgtAnt
            Work->VARIACAO += nVariacao
            Work->TRANSF   += nTransf
            Work->SLD_ATU  += If(ABS((nPgtAnt-nPgto+nVariacao-nTransf)) <= 0.05, 0, (nPgtAnt-nPgto+nVariacao-nTransf))

            //na Moeda
            Work->PGT_US   += nPgtoUs
            Work->SLDAN_US += nPgtAntUs
            Work->TRANS_US += nTransfUs
            Work->SLD_US   += If(ABS((nPgtAntUs-nPgtoUs-nTransfUs)) <= 0.05, 0, (nPgtAntUs-nPgtoUs-nTransfUs))

            If !Empty(cContra) .and. aScan(aContratos,{|x| x[1] == aFiliais[nFil] .AND. x[2]==(InvQuery)->ECF_PREEMB .and. x[3]==Work->INVOICE .and. x[4]==cContra})=0
               Work->CONTRA := Alltrim(Work->CONTRA) + If(!Empty(Work->CONTRA),  ", "+cContra, cContra)
               aAdd(aContratos,{aFiliais[nFil], (InvQuery)->ECF_PREEMB, Work->INVOICE, cContra})
            Endif
            
         Endif
         
      Endif
      
      nPgto:= nVariacao:= nTransf:= nPgtAnt:= 0
      nPgtoUs:=nTransfUs:= nPgtAntUs:= 0
      cContra:= ""
      lProc:= .F.
   
      (InvQuery)->(dbSkip())
   EndDo
Next

//
WorkECA->(dbGoTop())
Do While !WorkECA->(EOF())

   If lEnd
      If lEnd:=MsgYesNo(STR0023, STR0024) //"Tem certeza que deseja cancelar?"###"Atenção"
         If Select(InvQuery) <> 0
            (InvQuery)->(dbCloseArea())
         Endif
         If Select(InvQuery1) <> 0
            (InvQuery1)->(dbCloseArea())
         Endif
         MS_FLUSH()
         Return .F.
      EndIf
   EndIf

   //LRL 28/09/04
   If !lTop .AND. lECATPFORN .AND. WorkECA->ECA_TP_FOR <> '1'
      WorkECA->( dbSkip() )
      Loop
   Endif
   // AAF - 16/08/04 - Filtro por Cliente
   If !Empty(cCli)
      If WorkECA->ECA_FORN <> cCli
         WorkECA->(dbSkip())
         Loop
      Endif
   Endif

   // AAF - 16/08/04 - Filtro por Grupo de Cliente
   If !Empty(cGrpCli)
      If SA1->( dbSeek(WorkECA->ECA_FIL+AVKey(WorkECA->ECA_FORN, "A1_COD")) )
         If SA1->A1_GRPVEN <> cGrpCli
            WorkECA->(dbSkip())
            Loop
         Endif
      Else
         WorkECA->(dbSkip())
         Loop
      Endif
   Endif

   cContra := WorkECA->ECA_FILIAL+WorkECA->ECA_CONTRA
   EEC->(dbSeek(iIF(lFilOri,WorkECA->ECA_FILORI,cFilEEC)+WorkECA->ECA_PREEMB))

   //oProcess:IncRegua2(STR0021+Alltrim(WorkECA->ECA_INVOIC)) //"1 / 1 Invoice: "
   
   IF WorkECA->ECA_DT_CON >= dDtIni .And. WorkECA->ECA_DT_CON <= dDtFim
      If WorkECA->ECA_ID_CAM $ "115/112/801"
         nTransf  += WorkECA->ECA_VALOR
         nTransfUs+= WorkECA->ECA_VL_MOE
      ElseIf WorkECA->ECA_ID_CAM $ "582/583"
         nVariacao  += WorkECA->ECA_VALOR
      ElseIf WorkECA->ECA_ID_CAM $ "500/501" .and. WorkECA->ECA_TPMODU # 'FIEX01'
         nVariacao  += WorkECA->ECA_VALOR
      ElseIf WorkECA->ECA_ID_CAM == "101"
         nPgtAnt  += WorkECA->ECA_VALOR
         nPgtAntUs+= WorkECA->ECA_VL_MOE 
      ElseIf WorkECA->ECA_ID_CAM $ "630/607"
         nPgto  += WorkECA->ECA_VALOR
         nPgtoUs+= WorkECA->ECA_VL_MOE
      Else
         WorkECA->(dbSkip())
         Loop
      Endif
      lProc:= .T.
   ElseIf WorkECA->ECA_DT_CON <= dDtIni
      If Left(WorkECA->ECA_ID_CAM, 1) $ "5" .Or. WorkECA->ECA_ID_CAM  $ "115/112/607"
         If Left(WorkECA->ECA_ID_CAM, 1) == "5"
            nPgtAnt  += WorkECA->ECA_VALOR
            nPgtAntUs+= WorkECA->ECA_VL_MOE
         Else
            nPgtAnt  -= WorkECA->ECA_VALOR
            nPgtAntUs-= WorkECA->ECA_VL_MOE
         Endif
      Endif
      lProc:= .T.
   Endif
   
   If lProc

      if !Work->(dbSeek(WorkECA->ECA_FILIAL+AVKey(WorkECA->ECA_FORN,"A1_COD")+WorkECA->ECA_INVEXP))// AAF 18/12/04 - Conceito Multifilial

         Work->(DBAPPEND())         
         SA1->(dbSeek(WorkECA->ECA_FILIAL+WorkECA->ECA_FORN))
         
         //AAF 18/12/04 - Gravamento da filial de origem.
         //IF lFilOri
         //   Work->FILORI := WorkECA->ECA_FILORI
         //Endif
         
         Work->FILIAL   := WorkECA->ECA_FILIAL
         Work->COD_CLI  := WorkECA->ECA_FORN
         Work->NOM_CLI  := SA1->A1_NOME
         Work->MOEDA    := WorkECA->ECA_MOEDA
         Work->INVOICE  := WorkECA->ECA_INVEXP
         Work->DTEMB    := EEC->EEC_DTEMBA
         Work->CONTRA   := cContra

         If !Empty(cContra)
            aAdd(aContratos,{WorkECA->ECA_FILIAL,WorkECA->ECA_PREEMB, Work->INVOICE, cContra})
         EndIf

         //em Reais
         Work->PGTO     := nPgto
         Work->SLD_ANT  := nPgtAnt
         Work->VARIACAO := nVariacao
         Work->TRANSF   := nTransf
         Work->SLD_ATU  := If(ABS((nPgtAnt-nPgto+nVariacao-nTransf)) <= 0.05, 0, (nPgtAnt-nPgto+nVariacao-nTransf))

         //na Moeda
         Work->PGT_US   := nPgtoUs
         Work->SLDAN_US := nPgtAntUs
         Work->TRANS_US := nTransfUs
         Work->SLD_US   := If(ABS((nPgtAntUs-nPgtoUs-nTransfUs)) <= 0.05, 0, (nPgtAntUs-nPgtoUs-nTransfUs))         
      Else
         Work->(RecLock("Work",.F.))

         //em Reais
         Work->PGTO     += nPgto
         Work->SLD_ANT  += nPgtAnt
         Work->VARIACAO += nVariacao
         Work->TRANSF   += nTransf
         Work->SLD_ATU  += If(ABS((nPgtAnt-nPgto+nVariacao-nTransf)) <= 0.05, 0, (nPgtAnt-nPgto+nVariacao-nTransf))

         //na Moeda
         Work->PGT_US   += nPgtoUs
         Work->SLDAN_US += nPgtAntUs
         Work->TRANS_US += nTransfUs
         Work->SLD_US   += If(ABS((nPgtAntUs-nPgtoUs-nTransfUs)) <= 0.05, 0, (nPgtAntUs-nPgtoUs-nTransfUs))

         If !Empty(cContra) .and. aScan(aContratos,{|x| x[1] == WorkECA->ECA_FILIAL .AND. x[2]== WorkECA->ECA_PREEMB .and. x[3]== Work->INVOICE .and. x[4]==cContra})=0
            Work->CONTRA := Alltrim(Work->CONTRA) + If(!Empty(Work->CONTRA),  ", "+cContra, cContra)
            aAdd(aContratos,{WorkECA->ECA_FILIAL,WorkECA->ECA_PREEMB, Work->INVOICE, cContra})
         Endif
         
         Work->(msUnlock())
         
      Endif

   Endif
   
   nPgto:= nVariacao:= nTransf:= nPgtAnt:= 0
   nPgtoUs:=nTransfUs:= nPgtAntUs:= 0
   cContra:= ""
   lProc:= .F.
   
   WorkECA->(dbSkip())
Enddo

//

If lAbortPrint
   If Select(InvQuery) <> 0
      (InvQuery)->(DbCloseArea())
   Endif
   If Select(InvQuery1) <> 0
      (InvQuery1)->(DbCloseArea())
   Endif
   Return .F.
Endif

//AAF - 09/08/04
if nTipRel == 1
   wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)
   if VALTYPE(aReturn[6]) <> "C"
      If Select(InvQuery) <> 0
         (InvQuery)->(DbCloseArea())
      Endif
      If Select(InvQuery1) <> 0
         (InvQuery1)->(DbCloseArea())
      Endif
      Return .F.
   endif
   SetDefault(aReturn,cString)
   nTipo := If(aReturn[4]==1,15,18)
endif

If Work->(EasyRecCount()) <> 0
   if nTipRel == 1
      Imprime(lEnd)
   else
      //Chama funcão geradora de DBF
      //Caso tipo 3 envia ao Excel
      SC150DBFImpr(if(nTipRel == 3,.T.,.F.) )
   endif
   //Processa({|lEnd| Imprime(wnRel,cString)}, STR0015 ) //"Gerando Dados do Relatório"
Else
   Help(" ",1,"AVG0005112") //"Não ha dados para a Impressao!
Endif

If Select(InvQuery) <> 0
   (InvQuery)->(DbCloseArea())
Endif
If Select(InvQuery1) <> 0
   (InvQuery1)->(DbCloseArea())
Endif

If nLastKey = 27
   Return
Endif

//AAF - 09/08/04
if nTipRel == 1
   MS_FLUSH()
endif

Work->(avzap())

Return .T.
                               
//ASK 12/02/07 17:48 - Incluso no AtuSx do P9R1 
/*
Função..: SC150_ACDIC
Autor...: Alessandro Alves Ferreira - AAF
Data....: 09/08/04
Objetivo: Acerta dicionario SX1

*---------------------------*
Static Function SC150_ACDIC()
*---------------------------*
lAppend:= .F.

lAppend:= If(!SX1->(dbSeek("ECOSC1"+"01")),.T.,.F.)

SX1->(RecLock("SX1",lAppend)) 
SX1->X1_GRUPO   := "ECOSC1"
SX1->X1_ORDEM   := "01"
SX1->X1_VARIAVL := "mv_ch1"
SX1->X1_VAR01   := "mv_par01"
SX1->X1_PERGUNT := "Cliente ?"
SX1->X1_TIPO    := "C"
SX1->X1_TAMANHO :=  6
SX1->X1_GSC     := "G"
SX1->X1_VALID   := 'IF(!EMPTY(mv_par01),ExistCpo("SA1",mv_par01),.T.)'
SX1->X1_F3      := "CLI"
SX1->(msUnlock())

lAppend:= If(!SX1->(dbSeek("ECOSC1"+"02")),.T.,.F.)

SX1->(RecLock("SX1",lAppend)) 
SX1->X1_GRUPO   := "ECOSC1"
SX1->X1_ORDEM   := "02"
SX1->X1_VARIAVL := "mv_ch2"
SX1->X1_VAR01   := "mv_par02"
SX1->X1_PERGUNT := "Grupo de Cliente ?"
SX1->X1_TIPO    := "C"
SX1->X1_TAMANHO :=  6
SX1->X1_GSC     := "G"
SX1->X1_VALID   := 'IF(!EMPTY(mv_par02),ExistCpo("ACY",mv_par02),.T.)'
SX1->X1_F3      := "ACY"
SX1->(msUnlock())     

lAppend:= If(!SX1->(dbSeek("ECOSC1"+"03")),.T.,.F.)

SX1->(RecLock("SX1",lAppend)) 
SX1->X1_GRUPO   := "ECOSC1"
SX1->X1_ORDEM   := "03"
SX1->X1_VARIAVL := "mv_ch3"
SX1->X1_VAR01   := "mv_par03"
SX1->X1_PERGUNT := "Data Inic. Contab. ?"
SX1->X1_TIPO    := "D"
SX1->X1_TAMANHO :=  8
SX1->X1_GSC     := "G"
SX1->X1_VALID   := 'NaoVazio()'
SX1->(msUnlock())
                            
lAppend:= If(!SX1->(dbSeek("ECOSC1"+"04")),.T.,.F.)

SX1->(RecLock("SX1",lAppend)) 
SX1->X1_GRUPO   := "ECOSC1"
SX1->X1_ORDEM   := "04"
SX1->X1_VARIAVL := "mv_ch4"
SX1->X1_VAR01   := "mv_par04"
SX1->X1_PERGUNT := "Data Final Contab. ?"
SX1->X1_TIPO    := "D"
SX1->X1_TAMANHO :=  8
SX1->X1_GSC     := "G"
SX1->X1_VALID   := 'NaoVazio()'
SX1->(msUnlock())
                            
lAppend:= If(!SX1->(dbSeek("ECOSC1"+"05")),.T.,.F.)

SX1->(RecLock("SX1",lAppend)) 
SX1->X1_GRUPO   := "ECOSC1"
SX1->X1_ORDEM   := "05"
SX1->X1_VARIAVL := "mv_ch5"
SX1->X1_VAR01   := "mv_par05"
SX1->X1_PERGUNT := "Tipo de relatório ?"
SX1->X1_TIPO    := "N"
SX1->X1_TAMANHO :=  1
SX1->X1_GSC     := "C"
SX1->X1_DEF01   := "Impressão"
SX1->X1_DEF02   := "em Arquivo"
SX1->X1_DEF03   := "no MsExcel"
SX1->(msUnlock())

Return .T.
*/
*------------------------------------------*
Static Function Imprime(lEnd)//wnrel,cString)
*------------------------------------------*
Local nTam:= Len(Transform(0,cPictVl))
Local nCol1:=00, nCol2:=nCol1+AVSX3("ECF_INVEXP",3), nCol3:=nCol2+10, nCol4:=nCol3+nTam,nCol5:=nCol4+nTam
Local nCol6:=nCol5+nTam, nCol7:=nCol6+nTam+5, nCol8:=nCol7+5+nTam, nCol9:=nCol8+nTam+5
Local nCol10:=nCol9+nTam, nCol11:=nCol10+nTam, nCol12:=nCol11+nTam+10
Local nCalcPgt:= nSld_Ant:= nCalcVar:= nCalcTran:= nSld_Atu:= 0
Local nSld_AntUs:=nCalcPgtUs:=nCalcTranUs:=nSld_AtuUs:=0
Local nTotSd_Ant:= nTotPgto:= nTotVaria:= nTotTransf:= nTotSd_Atu:= 0
Local nTotSd_AuS:=nTotPgtoUs:=nTotTranUs:=nTotSdAtUs:=0
Local cMoeda := ""
Local aMoedas:= {}
Local nPosMoeda:= 0
Local lPLin:= .F., i
Local cFilAtu, nFilToT

Private cColMoe := "   "+SubStr(Replicate("-",Len(cPictVl)-3),4)
Private nLin:= 99

cabec1 := STR0006 //"Invoice              Dt. Emb.  Saldo Ant./Lanç. Inicial                 Pagamentos                   Variação no Período             Transferência                          Saldo Atual "
cabec2 := STR0012 //"                                R$                Moeda             R$                Moeda                   R$                   R$                Moeda               R$                Moeda"

//ProcRegua(Work->(EasyRecCount()))

Work->(dbGotop())
cCliente:= Work->COD_CLI
If lVerOut
   cFilAtu := Work->FILIAL
   aFilToT := {}
   lPrimFil:= .T.
Endif
lPrim   := .T.
oProcess:IncRegua1(STR0025) //"Lendo Arquivos 3 / 3 Gerando Relatório"

oProcess:SetRegua2(Work->(EasyRecCount()))

Do While !Work->(EOF())
   
   oProcess:IncRegua2(STR0026+Alltrim(Work->COD_CLI)+STR0027+Alltrim(Work->INVOICE)) //"1 / 1 Cliente "###" Invoice "
   
   If ABS(Work->PGTO+Work->VARIACAO+Work->TRANSF+Work->SLD_ANT) == 0
      Work->(dbSkip())
      Loop
   Endif
   
   //IncProc(STR0016+Alltrim(Work->INVOICE)) //"Lendo Invoice 

   If nLin >= 55
      Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
      nLin:= 08
   Endif
   
   //AAF 18/12/04 - Quebra por filial.
   If lVerOut .AND. lPrimFil
      nLin++
      @ nlin,nCol1 PSAY STR0037+AllTrim(cFilAtu)+"- "+Alltrim(AvgFilName( {cFilAtu} )[1]) //"Filial: "
      lPrimFil := .F.
      nLin++
      nLin++
      @ nlin,00 PSAY __PrtThinline()
   Endif  
  
   If lPrim
      nLin++
      @ nlin,nCol1 PSAY STR0007+Alltrim(Work->COD_CLI)+"- "+Alltrim(Work->NOM_CLI) //"Cliente: "
      lPrim:= .F.
      nLin++
   Endif
   
   //AAF - 17/08/04 - Verifica moeda para totalização
   If WORK->MOEDA <> cMoeda
      nPosMoeda:= aScan(aMoedas,{|aVal| aVal[1] == WORK->MOEDA })
      If nPosMoeda == 0
         aAdd(aMoedas,{WORK->MOEDA,0,0,0,0,0,0,0,0,0} )
         nPosMoeda:= Len(aMoedas)
      Endif
   Endif
   
   @ nLin,nCol1  PSAY Transf(Work->INVOICE, cPictInv)
   @ nLin,nCol2  PSAY Transf(Work->DTEMB, cPictDtEmb)
   @ nLin,nCol3  PSAY Transf(Work->SLD_ANT, cPictVl)
   @ nLin,nCol4  PSAY Transf(Work->SLDAN_US, cPictVl)
   @ nLin,nCol5  PSAY Transf(Work->PGTO, cPictVl)
   @ nlin,nCol6  PSAY Transf(Work->PGT_US, cPictVl)
   @ nlin,nCol7  Psay Transf(Work->VARIACAO, cPictVl)
   If Work->TRANSF <> 0 .Or. Work->TRANS_US <> 0
      @ nlin,nCol8 PSAY " A/D"+Transf(Work->TRANSF, cPictVl)
   Else
      @ nlin,nCol8 PSAY "    "+Transf(Work->TRANSF, cPictVl)
   Endif
   @ nlin,nCol9  Psay Transf(Work->TRANS_US, cPictVl)
   @ nlin,nCol10 Psay If(ABS(Work->SLD_ATU) <= 0.05, Transf(0, cPictVl), Transf(Work->SLD_ATU, cPictVl))
   @ nlin,nCol11 Psay If(ABS(Work->SLD_US) <= 0.05, Transf(0, cPictVl),  Transf(Work->SLD_US, cPictVl))
   @ nlin,nCol12 PSAY Alltrim(Work->MOEDA)
   
   //AAF - 17/08/04 - Imprime Contratos
   EF3->( dbSetOrder(2) )
   If EF3->( dbSeek(iIF(lFilOri,Work->FILORI,cFilEF3)+'600'+WORK->INVOICE) )
      // Imprime todas as Parcelas
      Do While !EF3->( EoF() ) .AND. EF3->EF3_FILIAL == iIF(lFilOri,Work->FILORI,cFilEF3) .AND. EF3->EF3_INVOIC == WORK->INVOICE
         nLin++
         @ nLin, nCol6+5 PSAY STR0013+EF3->EF3_CONTRA+STR0029+;//" Valor Vinculado: "
            Transf(EF3->EF3_VL_MOE, cPictVl)+STR0030+EF3->EF3_MOE_IN+;//" Moeda: "
            STR0031+DTOC(EF3->EF3_DT_EVE)+;//" Vinculação: "
            if(EF3->EF3_VL_MOE <> EF3->EF3_VL_INV,;
            STR0032+EF3->EF3_MOE_IN+" "+Transf(EF3->EF3_VL_INV, cPictVl ),;//" - O valor da invoice é " - Exibe caso valor da invoice seja diferente
            "")
         EF3->( DbSkip() )
      Enddo
   Endif
   
   //** AAF - 17/08/04 - IMPRESSAO DE COMISSOES
   //ORDENA PARA PROCURA DE COMISSOES
   EEQ->( dbSetOrder(5) )
   EC6->( dbSetOrder(1) )         

   //120 - Comissão A Remeter
   //121 - Comissão Conta Gráfica
   //122 - Comissão A Deduzir da Fatura
   If EEQ->( dbSeek(iIF(lFilOri,Work->FILORI,cFilEEQ)+WORK->INVOICE) )
      Do While !EEQ->( EoF() ) .AND. EEQ->EEQ_FILIAL == iIF(lFilOri,Work->FILORI,cFilEEQ) .AND. EEQ->EEQ_NRINVO == WORK->INVOICE 
         If EEQ->EEQ_EVENT $ '120/121/122'        
            nLin++
            EC6->( dbSeek(EEQ->EEQ_FILIAL+'EXPORT'+EEQ->EEQ_EVENT) )
            If EEQ->( FieldPos("EEQ_MOEDA") ) > 0 .AND. !Empty(EEQ->EEQ_MOEDA)
               cMoeda := EEQ->EEQ_MOEDA
            Else
               cMoeda := WORK->MOEDA
            Endif
            @ nLin, nCol2 PSAY EEQ->EEQ_EVENT+" "+EC6->EC6_DESC+" "+cMoeda+Transf(EEQ->EEQ_VL, cPictVl)+;
               STR0033+DtoC(EEQ->EEQ_VCT)+;//" Vencimento: "
               if( !Empty(EEQ->EEQ_PGT), STR0034+DtoC(EEQ->EEQ_PGT), "")
         Endif
         EEQ->( dbSkip() )         
      Enddo                                  
   Endif
   //** 
 
   nSld_Ant   += Work->SLD_ANT
   nSld_AntUs += Work->SLDAN_US
   nCalcPgt   += Work->PGTO
   nCalcPgtUs += Work->PGT_US
   nCalcVar   += Work->VARIACAO
   nCalcTran  += Work->TRANSF
   nCalcTranUs+= Work->TRANS_US
   nSld_Atu   += If(ABS(Work->SLD_ATU) <= 0.05, 0, Work->SLD_ATU)
   nSld_AtuUs += If(ABS(Work->SLD_US) <= 0.05, 0, Work->SLD_US)

   nTotSd_Ant += Work->SLD_ANT
   //nTotSd_AuS += Work->SLDAN_US
   nTotPgto   += Work->PGTO
   //nTotPgtoUs += Work->PGT_US
   nTotVaria  += Work->VARIACAO
   nTotTransf += Work->TRANSF
   //nTotTranUs += Work->TRANS_US
   nTotSd_Atu += If(ABS(Work->SLD_ATU) <= 0.05, 0, Work->SLD_ATU)
   //nTotSdAtUs += If(ABS(Work->SLD_US) <= 0.05, 0, Work->SLD_US)

   //AAF - 17/08/04 - Totalização por Moeda
   cMoeda:= WORK->MOEDA
   aMoedas[nPosMoeda][2]+= Work->SLD_ANT
   aMoedas[nPosMoeda][3]+= Work->SLDAN_US
   aMoedas[nPosMoeda][4]+= Work->PGTO
   aMoedas[nPosMoeda][5]+= Work->PGT_US
   aMoedas[nPosMoeda][6]+= Work->VARIACAO
   aMoedas[nPosMoeda][7]+= Work->TRANSF
   aMoedas[nPosMoeda][8]+= Work->TRANS_US
   aMoedas[nPosMoeda][9]+= If(ABS(Work->SLD_ATU) <= 0.05, 0, Work->SLD_ATU)
   aMoedas[nPosMoeda][10]+= If(ABS(Work->SLD_US) <= 0.05, 0, Work->SLD_US)

   //AAF - 29/12/04 - Totalização de Filial por Moeda
   If lVerOut
      nPosFil := aScan(aFilToT,{|x| x[1] == WORK->MOEDA})
      If nPosFil == 0
         aAdd(aFilToT,{WORK->MOEDA, 0, 0, 0, 0, 0, 0, 0, 0, 0})
         nPosFil := Len(aFilToT)
      Endif
     
      aFilToT[nPosFil][2]  += nSld_Ant
      aFilToT[nPosFil][3]  += nSld_AntUs
      aFilToT[nPosFil][4]  += nCalcPgt
      aFilToT[nPosFil][5]  += nCalcPgtUs      
      aFilToT[nPosFil][6]  += nCalcVar
      aFilToT[nPosFil][7]  += nCalcTran
      aFilToT[nPosFil][8]  += nCalcTranUs
      aFilToT[nPosFil][9]  += nSld_Atu
      aFilToT[nPosFil][10] += nSld_AtuUs
   Endif
   
   nLin+=2     
   Work->(dbSkip())

   If (cCliente <> Work->COD_CLI .OR. (lVerOut .AND. cFilAtu <> Work->FILIAL)) .AND. !lPrim
      @ nLin,nCol1  PSAY STR0009 //"Total do Cliente"
      
      @ nLin,nCol3  PSAY Transf(nSld_Ant, cPictVl)
      @ nlin,nCol4  Psay Transf(nSld_AntUs, cPictVl)
      @ nlin,nCol5  Psay Transf(nCalcPgt, cPictVl)
      @ nlin,nCol6  Psay Transf(nCalcPgtUs, cPictVl)
      @ nlin,nCol7  Psay Transf(nCalcVar, cPictVl)
      @ nlin,nCol8  Psay "    "+Transf(nCalcTran, cPictVl)
      @ nlin,nCol9  Psay Transf(nCalcTranUs, cPictVl)
      @ nlin,nCol10 Psay Transf(nSld_Atu, cPictVl)
      @ nlin,nCol11 Psay Transf(nSld_AtuUs, cPictVl)
      nLin++
      @ nlin,000 PSAY __PrtThinline()
      nlin+=2
      cCliente:= Work->COD_CLI
      lPrim:= .T.
      nCalcPgt:= nSld_Ant:= nCalcVar:= nCalcTran:= nSld_Atu:= 0
      nSld_AntUs:=nCalcPgtUs:=nCalcTranUs:=nSld_AtuUs:= 0
   Endif
   
   If lVerOut .AND. cFilAtu <> Work->FILIAL
      aAdd(aFilToT,{"R$ ",0,cColMoe,0,cColMoe,0,0,cColMoe,0,cColMoe})
      For nFilToT := 1 To Len(aFilToT) - 1
         @ nLin,nCol1  PSAY STR0036+" - "+cFilAtu+" - "+aFilToT[nFilToT][1] //"Total da Filial"
         @ nLin,nCol3  PSAY Transf(aFilToT[nFilToT][2], cPictVl)
         @ nlin,nCol4  Psay Transf(aFilToT[nFilToT][3], cPictVl)
         @ nlin,nCol5  Psay Transf(aFilToT[nFilToT][4], cPictVl)
         @ nlin,nCol6  Psay Transf(aFilToT[nFilToT][5], cPictVl)
         @ nlin,nCol7  Psay Transf(aFilToT[nFilToT][6], cPictVl)
         @ nlin,nCol8  Psay "    "+Transf(aFilToT[nFilToT][7], cPictVl)
         @ nlin,nCol9  Psay Transf(aFilToT[nFilToT][8], cPictVl)
         @ nlin,nCol10 Psay Transf(aFilToT[nFilToT][9], cPictVl)
         @ nlin,nCol11 Psay Transf(aFilToT[nFilToT][10], cPictVl)
         nLin++
         @ nlin,000 PSAY __PrtThinline()
         nlin++
         aFilToT[Len(aFilToT)][2] += aFilToT[nFilToT][2]
         aFilToT[Len(aFilToT)][4] += aFilToT[nFilToT][4]
         aFilToT[Len(aFilToT)][6] += aFilToT[nFilToT][6]
         aFilToT[Len(aFilToT)][7] += aFilToT[nFilToT][7]
         aFilToT[Len(aFilToT)][9] += aFilToT[nFilToT][9]
      Next nFilToT
      If Len(aFilToT) > 2
         @ nLin,nCol1  PSAY STR0036+" - "+cFilAtu+" - "+aFilToT[nFilToT][1] //"Total da Filial"
         @ nLin,nCol3  PSAY Transf(aFilToT[nFilToT][2], cPictVl)
         @ nlin,nCol4  Psay aFilToT[nFilToT][3]
         @ nlin,nCol5  Psay Transf(aFilToT[nFilToT][4], cPictVl)
         @ nlin,nCol6  Psay aFilToT[nFilToT][5]
         @ nlin,nCol7  Psay Transf(aFilToT[nFilToT][6], cPictVl)
         @ nlin,nCol8  Psay "    "+Transf(aFilToT[nFilToT][7], cPictVl)
         @ nlin,nCol9  Psay aFilToT[nFilToT][8]
         @ nlin,nCol10 Psay Transf(aFilToT[nFilToT][9], cPictVl)
         @ nlin,nCol11 Psay aFilToT[nFilToT][10]
         nLin++
         @ nlin,000 PSAY __PrtThinline()
         nlin++
      Endif
      aFilToT := {}
      lPrimFil:= .T.
      cFilAtu := Work->FILIAL
   Endif
EndDo

//AAF - 17/08/04 - TOTAL POR MOEDA
For i:= 1 to Len(aMoedas)
   If i == 1
      @ nLin,100 PSAY STR0035//"Total Geral por Moeda"
      nLin++
      @ nlin,000 PSAY __PrtThinline()
      nLin++
   Endif
   If nLin >= 55
      Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
      nLin:= 09
   Endif
   
   @ nLin,nCol1  PSAY STR0035+" - "+aMoedas[i][1]//"Total Geral por Moeda"
   
   @ nLin,nCol3  PSAY Transf(aMoedas[i][2], cPictVl)
   @ nlin,nCol4  PSAY Transf(aMoedas[i][3], cPictVl)
   @ nlin,nCol5  PSAY Transf(aMoedas[i][4], cPictVl)
   @ nlin,nCol6  PSAY Transf(aMoedas[i][5], cPictVl)
   @ nlin,nCol7  PSAY Transf(aMoedas[i][6], cPictVl)
   @ nlin,nCol8  PSAY "    "+Transf(aMoedas[i][7], cPictVl)
   @ nlin,nCol9  PSAY Transf(aMoedas[i][8], cPictVl)
   @ nlin,nCol10 PSAY Transf(aMoedas[i][9], cPictVl)
   @ nlin,nCol11 PSAY Transf(aMoedas[i][10], cPictVl)
   nLin++
   @ nlin,000 PSAY __PrtThinline()
   nLin++
Next

If !(Work->(BoF()) .And. Work->(EoF())) .AND. nLin < 99
   @ nLin,105 PSAY STR0010 //"Total Geral"
   nLin++
   @ nlin,000 PSAY __PrtThinline()
   nLin++
   
   @ nLin,nCol1  PSAY STR0010 //"Total Geral"
 
   @ nLin,nCol3  PSAY Transf(nTotSd_Ant, cPictVl)
   @ nlin,nCol4  PSAY cColMoe
   @ nlin,nCol5  PSAY Transf(nTotPgto, cPictVl)
   @ nlin,nCol6  PSAY cColMoe
   @ nlin,nCol7  PSAY Transf(nTotVaria, cPictVl)
   @ nlin,nCol8  PSAY "    "+Transf(nTotTransf, cPictVl)
   @ nlin,nCol9  PSAY cColMoe
   @ nlin,nCol10 PSAY Transf(nTotSd_Atu, cPictVl)
   @ nlin,nCol11 PSAY cColMoe
   nLin++
   @ nlin,000 PSAY __PrtThinline()

   nTotSd_Ant:= nTotPgto:= nTotVaria:= nTotTransf:= nTotSd_Atu:= 0
   nTotSd_AuS:= nTotPgtoUs:=nTotTranUs:= nTotSdAtUs:= 0
Endif
If nTipRel == 1
   If aReturn[5] = 1
      Set Printer To
      Commit
      Ourspool(wnrel)
   Else
      Help(" ",1,"AVG0005112")//"Não há Dados para Impressão!"
   Endif
Endif
 
Return .T.

/*
Função..: SC150DBFImpr
Autor...: Alessandro Alves Ferreira - AAF
Data....: 09/08/04
Objetivo: Gera work com o relatório para exportar ao Excel
          ou salvar arquivo DBF/TXT
*/
*------------------------------------------*
Static Function SC150DBFImpr(lExcel)
*------------------------------------------*
Local cArquivo := CriaTrab(,.F.)
Local oExcelApp
cDirDocs := MsDocPath()
cPath	:= AllTrim(GetTempPath())

aEstru:= {}
If lVerOut
   AADD(aEstru,{"FILIAL" , AVSX3("ECF_FILORI", 02), AVSX3("ECF_FILORI", 03), AVSX3("ECF_FILORI", 04)})
Endif
AADD(aEstru,{"INVOICE" , AVSX3("ECF_INVEXP", 02), AVSX3("ECF_INVEXP", 03), AVSX3("ECF_INVEXP", 04)})
AADD(aEstru,{"DT_EMBARQ"   , AVSX3("EEC_DTEMBA", 02), AVSX3("EEC_DTEMBA", 03), AVSX3("EEC_DTEMBA", 04)})
AADD(aEstru,{"SLDANT_RS" , AVSX3("ECF_VALOR", 02) , AVSX3("ECF_VALOR", 03) , AVSX3("ECF_VALOR", 04)})
AADD(aEstru,{"SLDANT_US", AVSX3("ECF_VL_MOE", 02), AVSX3("ECF_VL_MOE", 03), AVSX3("ECF_VL_MOE", 04)})
AADD(aEstru,{"PGTO_RS"    , AVSX3("ECF_VALOR", 02) , AVSX3("ECF_VALOR", 03) , AVSX3("ECF_VALOR", 04)})
AADD(aEstru,{"PGTO_US"  , AVSX3("ECF_VL_MOE", 02), AVSX3("ECF_VL_MOE", 03), AVSX3("ECF_VL_MOE", 04)})
AADD(aEstru,{"VARIACAO", AVSX3("ECF_VALOR", 02) , AVSX3("ECF_VALOR", 03) , AVSX3("ECF_VALOR", 04)})
AADD(aEstru,{"TRANSF_RS"  , AVSX3("ECF_VALOR", 02) , AVSX3("ECF_VALOR", 03) , AVSX3("ECF_VALOR", 04)})
AADD(aEstru,{"TRANSF_US", AVSX3("ECF_VL_MOE", 02), AVSX3("ECF_VL_MOE", 03), AVSX3("ECF_VL_MOE", 04)})
AADD(aEstru,{"SLD_RS" , AVSX3("ECF_VALOR", 02) , AVSX3("ECF_VALOR", 03) , AVSX3("ECF_VALOR", 04)})
AADD(aEstru,{"SLD_US"  , AVSX3("ECF_VL_MOE", 02), AVSX3("ECF_VL_MOE", 03), AVSX3("ECF_VL_MOE", 04)})
AADD(aEstru,{"MOEDA"   , AVSX3("ECF_MOEDA", 02) , AVSX3("ECF_MOEDA", 03) , AVSX3("ECF_MOEDA", 04)})

cDirDocs := E_CriaTrab(, aEstru, cArquivo)

Work->(dbGotop())

oProcess:IncRegua1(STR0025) //"Lendo Arquivos 3 / 3 Gerando Relatório"
oProcess:SetRegua2(Work->(EasyRecCount()))

Do While !Work->(EOF())   
   oProcess:IncRegua2(STR0026+Alltrim(Work->COD_CLI)+STR0027+Alltrim(Work->INVOICE)) //"1 / 1 Cliente "###" Invoice "
   If ABS(Work->PGTO+Work->VARIACAO+Work->TRANSF+Work->SLD_ANT) == 0
      Work->(dbSkip()) 
      Loop
   Endif
   
   nField := 1
   
   (cArquivo)->( dbAppend() )
   If lVerOut
      (cArquivo)->( FieldPut(nField++,WORK->FILIAL) )
   Endif
   (cArquivo)->( FieldPut(nField++,WORK->INVOICE) )
   (cArquivo)->( FieldPut(nField++,WORK->DTEMB) )
   (cArquivo)->( FieldPut(nField++,WORK->SLD_ANT) )
   (cArquivo)->( FieldPut(nField++,WORK->SLDAN_US) )
   (cArquivo)->( FieldPut(nField++,WORK->PGTO) )
   (cArquivo)->( FieldPut(nField++,WORK->PGT_US) )
   (cArquivo)->( FieldPut(nField++,WORK->VARIACAO) )
   (cArquivo)->( FieldPut(nField++,WORK->TRANSF) )
   (cArquivo)->( FieldPut(nField++,WORK->TRANS_US) )
   (cArquivo)->( FieldPut(nField++,WORK->SLD_ATU) )
   (cArquivo)->( FieldPut(nField++,WORK->SLD_US) )
   (cArquivo)->( FieldPut(nField++,WORK->MOEDA) )
   Work->(dbSkip())
   
EndDo

dbSelectArea(cArquivo)

If lExcel
   (cArquivo)->( dbCloseArea() )   
   CpyS2T( cDirDocs+"\"+cArquivo+".DBF" , cPath, .T. )

   //Envia ao Excel
   If ! ApOleClient( 'MsExcel' )
      Msgstop(STR0028)//"MsExcel não instalado."
      RETURN .F.
   Else     
      oExcelApp:= MsExcel():New()
      oExcelApp:WorkBooks:Open( cPath+cArquivo+".dbf" ) // Abre uma planilha
      oExcelApp:SetVisible(.T.)
   EndIf
Else
  //Abre para criacao do arquivo. 
  TR350ARQUIVO(cArquivo)
  (cArquivo)->( dbCloseArea() )     
Endif

Return .T.
