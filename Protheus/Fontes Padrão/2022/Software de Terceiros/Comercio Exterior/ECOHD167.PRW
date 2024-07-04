#INCLUDE "Ecohd167.ch"
#include "AVERAGE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOIN100 ³ Autor ³ VICTOR IOTTI          ³ Data ³ 20.12.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Encerramento de DI's                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------*
Function ECOHD167
*----------------*
LOCAL cOldAlias:=ALIAS()
PRIVATE cCadastro := STR0001 //"Encerramento de D.I.'S"
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))
PRIVATE aDBF_Stru := {{"WKDES_CAMP","C",24,0},{"WKDT_PGTO","C",10,0},;
                      {"WKVL_CAMP" ,"N",15,2},{"WKNR_CONT","N",4,0},;
                      {"WKORIGEM"  ,"C",1,0}}

Private aCampoBrow:=;
   {{{||Work->WKDES_CAMP}                              , "", STR0002},; //"Descricao do Campo"
    {{||Work->WKDT_PGTO}                               , "", STR0003              },; //"Data"
    {{||TRANS(Work->WKVL_CAMP,'@E 999,999,999,999.99')}, "", STR0004             },; //"Valor"
    {{||STRZERO(Work->WKNR_CONT,4)}                    , "", STR0005              },; //"Cont"
    {{||SUBSTR(BuscaOrigem(Work->WKORIGEM),1,3)}       , "", STR0006            }} //"Origem"

PRIVATE nNro_DI,cStatus,dDtDI,cLote,cTxDI,cFobDI,cNF,cNF_C,cHAWB, cIdentc,cDescCC
Private cFilEC2:=xFilial("EC2"), cFilEC4:=xFilial("EC4"), cFilEC5:=xFilial("EC5")
Private cFilEC6:=xFilial("EC6"), cFilEC8:=xFilial("EC8"), cFilECC:=xFilial("ECC")
Private aHeader[0]//E_CriaTrab utiliza
Private cMarca := GetMark(), lInverte := .F., oOBJ, oDlgHD, nOpca
Private cMoeda := '',nFobDI:=0,lVer_Cont:=.F.

PRIVATE aRotina := MenuDef()

//TRP - 05/02/07 - Campos do WalkThru
AADD(aDBF_Stru,{"TRB_ALI_WT","C",03,0})
AADD(aDBF_Stru,{"TRB_REC_WT","N",10,0})


cNomArq := E_CriaTrab(, aDBF_Stru, "Work")

IF ! USED()
   E_Msg(STR0009,20) //"N„o ha area disponivel para abertura do arquivo temporario."
   RETURN .F.
ENDIF

EC4->(DBSETORDER(1))
EC8->(DBSETORDER(1))
EC5->(DBSETORDER(1))
EC6->(DBSETORDER(1))

DbSelectArea("EC2")

mBrowse( 6, 1,22,75,"EC2")

EC2->(DBSETORDER(1))
Work->(E_EraseArq(cNomArq))
DBSELECTAREA(cOldAlias)

Return .T.         


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 01/02/07 - 14:46
*/
Static Function MenuDef()
Local aRotAdic := {} 
Local aRotina  := { { STR0007  ,"AxPesqui", 0 , 1},; //"Pesquisar"
                    { STR0008  ,"HD167MAN", 0 , 6,21}} //"Encerrar" 
                     
// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("CHD167MNU")
	aRotAdic := ExecBlock("CHD167MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

*----------------*
Function HD167MAN
*----------------*
Private aButtons := {}  // GFP - 18/11/2011 - Alteração para EnchoiceBar

nNro_DI := EC2->EC2_DI_NUM
cIdentc := EC2->EC2_IDENTC

cStatus:=cLote:=cTxDI:=cFobDI:=cNF:=cNF_C:=cHAWB:=' '
cDescCC:= SPACE(30)
dDtDI:=AVCTOD('  /  /  ')
Work->(avzap())
lVer_Cont:=.F.

EC2->(DBSETORDER(2))

cStatus := If(EC2->EC2_FIM_CT#'1',STR0010,STR0011) //"Em Aberto"###"Encerrado"
cHAWB   := EC2->EC2_HAWB
cDescCC := ECC->ECC_DESCR
dDtDI   := EC2->EC2_DT
cLote   := EC2->EC2_LOTE
cTxDI   := TRANS(EC2->EC2_TX_DI,'@E 999,999.999999')
cFobDI  := TRANS(EC2->EC2_FOB_DI,'@E 999,999,999,999.99')
cNF     := EC2->EC2_NF_ENT
cNF_C   := EC2->EC2_NF_COM

Processa({||HD167G_Work()},STR0012) //"Gerando Arq. Tempor rio..."

Work->(DBGOTOP())

nColS1:= 0.3  ;  nColS2:=  7.6  ;  nColS3:= 19.5  ;  nColS4:= 33.0
nColG1:= 2.8  ;  nColG2:= 10.6  ;  nColG3:= 22.5  ;  nColG4:= 36.0

//GFP - 18/11/2011 - Alteração para EnchoiceBar
aAdd(aButtons,{"S4WB008N",{||Calculadora()},STR0029})  //"Calculadora"
aAdd(aButtons,{"S4WB016N",{||HelProg()},STR0030})  //"Help de Programa"

WHILE .T.

   nOpca:=0

   DEFINE MSDIALOG oDlgHD TITLE STR0001 FROM 9,0 TO 28,82 OF oMainWnd  //"Encerramento de D.I.'S"

      nLin  := 1.3

      @ nLin  ,nColS1 SAY STR0013 //"No. DI"
      @ nLin  ,10.5   SAY STR0014 //"B.U./Unid.Req."
      @ nLin++,22.0   SAY STR0015 //"Descr."
      @ nLin  ,nColS1 SAY STR0016 //"Data DI"
      @ nLin  ,nColS2 SAY STR0017 //"Processo"
      @ nLin  ,nColS3 SAY STR0018 //"Taxa DI"
      @ nLin++,nColS4 SAY STR0019 //"Lote"
      @ nLin  ,nColS1 SAY STR0020 //"Status"
      @ nLin  ,nColS2 SAY STR0021 //"Fob"
      @ nLin  ,nColS3 SAY STR0022 //"NF.Ent."
      @ nLin  ,nColS4 SAY STR0023 //"NF.Comp."
      nLin  := 1.3
      @ nLin  ,nColG1 MSGET nNro_DI WHEN .F. SIZE 50 ,08 OF oDlgHD
      @ nLin  ,15.5   MSGET cIdentc WHEN .F. SIZE 35 ,08 OF oDlgHD
      @ nLin++,24.5   MSGET cDescCC WHEN .F. SIZE 115,08 OF oDlgHD

      @ nLin  ,nColG1 MSGET dDtDI   WHEN .F. SIZE 35 ,08 OF oDlgHD
      @ nLin  ,nColG2 MSGET cHAWB   WHEN .F. SIZE 70 ,08 OF oDlgHD
      @ nLin  ,nColG3 MSGET cTxDI   WHEN .F. SIZE 80 ,08 OF oDlgHD
      @ nLin++,nColG4 MSGET cLote   WHEN .F. SIZE 25 ,08 OF oDlgHD

      @ nLin  ,nColG1 MSGET cStatus WHEN .F. SIZE 35 ,08 OF oDlgHD
      @ nLin  ,nColG2 MSGET cFobDI  WHEN .F. SIZE 70 ,08 OF oDlgHD
      @ nLin  ,nColG3 MSGET cNF     WHEN .F. SIZE 80 ,08 OF oDlgHD
      @ nLin  ,nColG4 MSGET cNF_C   WHEN .F. SIZE 25 ,08 OF oDlgHD

      aPos := PosDlg(oDlgHD)
      oObj:= MsSelect():New("Work",,,aCampoBrow,@lInverte,@cMarca,{58,aPos[2],aPos[3],aPos[4]},,,oDlgHD)   
//   oObj:=MsSelect():New("Work",,,aCampoBrow,@lInverte,@cMarca,{58,1,iif(SetMDIChild(),143,143),325})
      oObj:bAval:={||.T.}
      oObj:oBrowse:bwhen:={||(dbSelectArea("Work"),.t.)}

   ACTIVATE MSDIALOG oDlgHD ON INIT EnchoiceBar(oDlgHD,{||(HD167_Conf(),nOpca:=1,oDlgHD:End())},{||nOpca:=0,oDlgHD:End()},,aButtons) CENTERED
// ACTIVATE MSDIALOG oDlgHD ON INIT ;
//                   HD167BAR(0,oDlgHD,{||nOpca:=1,oDlgHD:End()},;
//                                     {||nOpca:=0,oDlgHD:End()}) Centered

   Exit

ENDDO
EC2->(DBSETORDER(1))
Return .T.

*-------------------*
FUNCTION HD167G_Work
*-------------------*

ProcRegua(3)
IncProc(STR0024) //"Gravando ..."

Work->(avzap())

HD167_DDI000()
IncProc()
HD167_FPO000()
IncProc()

RETURN ""

*-------------------*
FUNCTION HD167_DDI000
*-------------------*
cFilEC4:=xFilial("EC4") //LRL 10/12/04 - Coceito Matriz
EC4->(DBSEEK(cFilEC4+EC2->EC2_HAWB+EC2->EC2_FORN+EC2->EC2_MOEDA+EC2->EC2_IDENTC))

DO WHILE ! EC4->(EOF()) .AND. EC4->EC4_HAWB=EC2->EC2_HAWB .AND. EC4->EC4_FILIAL=cFilEC4 .AND. EC2->EC2_IDENTC=EC4->EC4_IDENTC .AND. EC2->EC2_FORN=EC4->EC4_FORN .AND. EC2->EC2_MOEDA=EC4->EC4_MOEDA
   IF VAL(EC4->EC4_NR_CON) = 0
      lVer_Cont = .T.
   ENDIF

   EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+EC4->EC4_ID_CAM))

   Work->(DBAPPEND())
   Work->WKDES_CAMP := EC4->EC4_ID_CAM +'-'+ EC6->EC6_DESC
   Work->WKDT_PGTO  := DTOC(EC4->EC4_DT_PGT)
   Work->WKVL_CAMP  := EC4->EC4_VL_CAM
   Work->WKNR_CONT  := VAL(EC4->EC4_NR_CON)
   Work->WKORIGEM   := EC4->EC4_SIS_OR
   Work->TRB_ALI_WT := "EC4"
   Work->TRB_REC_WT := EC4->(Recno())
   EC4->(DBSKIP())
ENDDO

RETURN .T.


*-------------------*
FUNCTION HD167_FPO000
*-------------------*
cFilEC8 := xFilial("EC8")
EC8->(DBSEEK(cFilEC8+EC2->EC2_HAWB+EC2->EC2_FORN+EC2->EC2_MOEDA+EC2->EC2_IDENTC))

DO WHILE ! EC8->(EOF()) .AND. EC8->EC8_HAWB=EC2->EC2_HAWB .AND. EC8->EC8_FORN=EC2->EC2_FORN .AND. EC8->EC8_MOEDA=EC2->EC2_MOEDA .AND. EC8->EC8_FILIAL=cFilEC8 .AND. EC2->EC2_IDENTC=EC8->EC8_IDENTC

   EC5->(DBSEEK(xFilial("EC5")+EC8->EC8_FORN+EC8->EC8_INVOIC))

   Work->(DBAPPEND())
   Work->WKDES_CAMP := "PO-"+TRANS(EC8->EC8_PO_NUM,_PictPo) + EC5->EC5_INVOIC
   Work->WKDT_PGTO  := "FOB" + "-" + EC5->EC5_MOE_FO
   Work->WKVL_CAMP  := EC8->EC8_FOB_PO
   Work->TRB_ALI_WT := "EC8"
   Work->TRB_REC_WT := EC8->(Recno())
   EC8->(DBSKIP())
ENDDO

RETURN .T.

*------------------*
FUNCTION HD167_Conf
*------------------*
If (Work->(EOF()).AND.Work->(BOF()))
   cStatus := If(EC2->EC2_FIM_CT#'1',STR0010,STR0011) //"Em Aberto"###"Encerrado"
   cHAWB   := EC2->EC2_HAWB
   cDescCC := ECC->ECC_DESCR
   dDtDI   := EC2->EC2_DT
   cLote   := EC2->EC2_LOTE
   cTxDI   := TRANS(EC2->EC2_TX_DI,'@E 999,999.999999')
   cFobDI  := TRANS(EC2->EC2_FOB_DI,'@E 999,999,999,999.99')
   cNF     := EC2->EC2_NF_ENT
   cNF_C   := EC2->EC2_NF_COM

   Processa({||HD167G_Work()},STR0012) //"Gerando Arq. Tempor rio..."

   Work->(DBGOTOP())

   lRefresh:=.t.

   oObj:oBrowse:Refresh()
EndIf

cStatus:=SimNao(STR0025,STR0026,,,,STR0026) //"(sim) Encerramento / (não) Em Aberto"###"Questao ?"###"Questao ?"   // GFP - 22/11/2011

IF cStatus = "S"
   IF lVer_Cont
      E_Msg(STR0027,1) //"Esta D.I. n„o pode ser encerrada, existem valores n„o contabilizados"
      Return .F.
   ELSE
      cConf:=SimNao( STR0028,STR0026,,,,STR0026) //"Confirma o encerramento ?"###"Questao ?"###"Questao ?"    // GFP - 22/11/2011
      If cConf#'S'
         Return .F.
      EndIf
   ENDIF
ENDIF

Reclock("EC2",.F.)
EC2->EC2_FIM_CT := If(cStatus="S","1","2")
EC2->(MSUNLOCK())
Return .T.