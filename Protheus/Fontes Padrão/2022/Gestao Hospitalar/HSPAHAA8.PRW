#INCLUDE "HSPAHAA8.ch"
#include "protheus.CH"
#include "colors.CH"
#INCLUDE "TopConn.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHAA8  บ Autor ณ Marcelo Jos้       บ Data ณ  06/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ LANCAMENTOS AUTOMATICOS                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHAA8()
 Private aRotina := {}, cCadastro := STR0001 //"Cadastro de Lancamentos Automaticos"
                       
 aRotina := MenuDef()

 DbSelectArea("GDC")
 DbSetOrder(1)
                   
 mBrowse(06, 01, 22, 75, "GDC")
 
Return(Nil)
                                      
Function HS_MntAA8(nOpc)
 Local nOpcA := 0, nGDOpc := IIf(nOpc == 2 .Or. nOpc == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
 Local bCampo   := { |nCPO| Field(nCPO) }
 Local nCntFor := 1, aCpoEnc := {}
 Local cCampo := Space(100), oCbx, aCbx := {}, aSix := {}, cOrd := "", oBigGet       
                 
 Private aTela := {}, aGets := {}, nOpcE := 0, nOpcG := 0
 Private oEscolhe
 Private aCGDD	:= {}, aHGDD := {}, nUGDD := 0, nLGDD := 0, oGDD

 Private oFolder, pForACols := 0

 If     nOpc == 3 /*INCLUIR*/
  nOpcE := 3 
  nOpcG := 3
 ElseIf nOpc == 4 /* Alterar */
  nOpcE := 4
  nOpcG := 3
 ElseIf nOpc == 2 /* Visualizar */
  nOpcE := 2
  nOpcG := 2
 Else             /* Excluir */
  nOpcE := 5
  nOpcG := 5
 EndIf

 DbSelectArea("SX3")
 DbSetOrder(1)
 DbSeek("GDC")
 While !Eof() .And. (SX3->X3_ARQUIVO == "GDC")
  If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL 
   aAdd(aCpoEnc, SX3->X3_CAMPO)
  Endif
  
  &("M->" + SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
  DbSkip()
 End                                                
 
 If nOpc # 3
  DbSelectArea("GDC")
  For nCntFor := 1 TO FCount()
   M->&(EVAL(bCampo, nCntFor)) := FieldGet(nCntFor)
  Next
 
 EndIf

 HS_BDados("GDD", @aHGDD, @aCGDD, @nUGDD, 1, M->GDC_CODPLA+M->GDC_MODELO, IIf(nOpc # 3, "GDD->GDD_CODPLA == '" + M->GDC_CODPLA + "' .And. GDD_MODELO == '" + M->GDC_MODELO + "'", Nil))
 nGdd_Codtxd := aScan(aHGDD, {| aVet | aVet[2] == "GDD_CODTXD"})
 nGdd_Desc   := aScan(aHGDD, {| aVet | aVet[2] == "GDD_DESC  "})
 nGdd_Qtde   := aScan(aHGDD, {| aVet | aVet[2] == "GDD_QTDE  "})
  
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 030, .T., .T. } )	
 AAdd( aObjects, { 100, 070, .T., .T. } )	
 
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )
 
 DbSelectArea("GDC")
 nOpcA := 0  
     
 DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd
 
  oEncGdc := MsMGet():New("GDC", aCpoEnc, nOpcE,,,,, aPObjs[1],, 2,,,, oDlg) 
  oEncGdc:oBox:Align := CONTROL_ALIGN_TOP 
 
  oGDD := MsNewGetDados():New(aPObjs[2, 1],aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,,,,,,,,,,oDlg, aHGDD, aCGDD)  
  oGDD:oBrowse:align := CONTROL_ALIGN_ALLCLIENT    
   
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(oGDD:TudoOk() .And. Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)}, ;
                                                            {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1
  Begin Transaction 
   FS_GrvAA8()
  End Transaction
 EndIf
 
Return(Nil)
/*****************************************************************************************************************/
Static Function FS_GrvAA8()
 Local lAchou := .F.
 Private pForaCols := 0

 If nOpcG # 2 /* nao for consulta */
  DbSelectArea("GDC")  
  DbsetOrder(1)
  lAchou := DbSeek(xFilial("GDC") + M->GDC_CODPLA + M->GDC_MODELO)
  If Inclui .Or. Altera
   RecLock("GDC", If(lAchou, .F., .T.))
    HS_GRVCPO("GDC")
    GDC->GDC_FILIAL := xFilial("GDC")
		 MsUnLock() 
  Else  /* exclusao */
   RecLock("GDC", .F., .T.)
    dbdelete()
   MsUnlock()
   WriteSx2("GDC")
  EndIf
                  
  FS_GrvRel("GDD", 1, "M->GDC_CODPLA + M->GDC_MODELO + oGDD:aCols[pForaCols, nGdd_Codtxd]", oGDD ,nGdd_Codtxd)                 
 EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvRel บ Autor ณ Marcelo Jose       บ Data ณ  06/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava arquivos de relacionamento                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvRel(cAlias, nOrd, cChave, oGrv,nPos)
 Local nItem 				:= 0, cPref := cAlias + "->" + PrefixoCpo(cAlias)
 Local cAliasOld := Alias()

 For nItem := 1 To Len(oGrv:aCols)
  pForaCols := nItem
  DbSelectArea(cAlias)
  DbSetOrder(nOrd)
  lAchou := DbSeek(xFilial(cAlias) + &(cChave) )
  If ((!Inclui .And. !Altera) .Or. oGrv:aCols[nItem, Len(oGrv:aCols[nItem])]) .And. lAchou /* exclusao */
   FS_DelDF(M->GDC_MODELO, oGDD:aCols[nItem, nGdd_Codtxd])
   RecLock(cAlias, .F., .T.)
   DbDelete()
   MsUnlock()
   WriteSx2(cAlias)
  Else                             
   If Inclui .Or. Altera
    If !oGrv:aCols[nItem, Len(oGrv:aCols[nItem])]
     RecLock(cAlias, !lAchou)
     HS_GRVCPO(cAlias, oGrv:aCols, oGrv:aHeader, nItem)
     &(cPref + "_FILIAL") := xFilial(cAlias)
     &(cPref + "_CODPLA") := M->GDC_CODPLA
     &(cPref + "_MODELO") := M->GDC_MODELO
     &(cPref + "_LOGARQ") := HS_LogArq()
     MsUnlock()                  
    Endif 
   Endif
  EndIf 
 Next
 
 DbSelectArea(cAliasOld)
Return() 
/************************************************************************************************************/
Function FS_ValAA8()
 Local lRet := .T., cAliasOld := Alias(), nPosTD := 0
 
 If !(lRet := !((nPosTD := aScan(oGDD:aCols, {| aVet | aVet[1] == M->GDD_CODTXD})) > 0 .And. nPosTD # oGDD:nAt))
  Help("Atencao", 1, "HAA8TAXREP",, "A Tax/Dia informada ja foi lancada", 1)
 Else
  DbSelectarea("GAA")
  DbSetOrder(1)
  IF !(lRet := DbSeek(xFilial("GAA") + M->GDD_CODTXD))
   Help("Atencao", 1, "HAA8TAXREP",, "A Tax/Dia informada nใo cadastrada (GAA)", 1)
  Else
   oGDD:aCols[oGDD:oBrowse:nAt, nGdd_Desc] := GAA->GAA_DESC
  EndIf
 EndIf 
 DbselectArea(cAliasOld)
Return(lRet)  
               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 06/06/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Gera arquivo TXT para exportacao                      ณ
//ณ    4 - Recebe arquivo TXT                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui"    , 0, 1, 0, nil},;  //"Pesquisar"
		             {OemToAnsi(STR0003), "HS_MntAA8(2)", 0, 2, 0, nil},;  //"Visualizar"
		             {OemToAnsi(STR0004), 'HS_MntAA8(3)', 0, 3, 0, nil},;  //"Incluir"
		             {OemToAnsi(STR0005), 'HS_MntAA8(4)', 0, 4, 2, nil},;  //"Alterar"
		             {OemToAnsi(STR0006), 'HS_MntAA8(5)', 0, 5, 1, nil}}   //"Excluir"
Return(aRotina)             

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DelDF  บ Autor ณ HEIMDALL           บ Data ณ  07/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Deleta as despesas fixas das guias dos pacientes           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/           
               
Static Function FS_DelDF(cTpAcom, cCodTxd)

Local cSQL := ""

cSQL := "SELECT GAV_REGATE REGATE, GDD_CODTXD CODTXD FROM " + RetSqlName("GAV") + " GAV JOIN " + RetSqlName("GDD") + " GDD ON GDD.GDD_FILIAL = '" + xFilial("GDD") + "' AND GAV_MODELO = GDD_MODELO AND GDD.D_E_L_E_T_ <> '*' WHERE GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV_REGATE <> '' AND GAV_MODELO = '" + cTpAcom + "' AND GDD_CODTXD = '" + cCodTxd + "' AND GAV.D_E_L_E_T_ <> '*'"

cSQL :=  ChangeQuery(cSql)

TCQUERY cSQL NEW ALIAS "QRYSQL"

DbSelectArea("QRYSQL")
DbGoTop()   

DbSelectArea("GB5")
DbSetOrder(1)

While !QRYSQL->(EOF())
 If GB5->(DbSeek(xFilial("GB5") + QRYSQL->REGATE + QRYSQL->CODTXD))
 	RecLock("GB5", .F.)
		 DbDelete()
		MsUnLock()
	EndIf
	QRYSQL->(DBSkip())
EndDo


GB5->(DBCloseArea())
QRYSQL->(DbCloseArea())

Return(Nil)