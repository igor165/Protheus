#INCLUDE "HSPAHP40.CH"
#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP40  º Autor ³ MARCELO JOSE       º Data ³  01/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ UNIFICACAO DE REGISTROS                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP40()

Local oSay0, oSay1, oSay2 
Local aArea := GetArea()

Private cNomeF := space(40), cNomeS := space(40)
Private cRegGerS := space(6), cRegGerF := space(6), aTodos := {}
Private oDlg, oSay3, oList, nList := 1, oBut1, oGet1,oGet2, oGet3, oGet4

HS_DtvFilt("GSA") /* desativa filtro */

DEFINE MSDIALOG oDlg FROM 0,0 TO 200,500 PIXEL TITLE STR0001 //"Unificar Prontuários"


oList:=tListBox():New(20,170,{|u|if(Pcount()>0,nList:=u,nList)},aTodos,80,80,,oDlg,,,,.T.)

oSay1:= tSay():New(20,10,{||STR0002},oDlg,,,,,,.T.,CLR_BLUE,,150,10) //"Prontuário que irá permanecer: "
oGet1:= tGet():New(20,120,{|u| if(PCount()>0, cRegGerF:=u,cRegGerF)}, oDlg, 15,10,"@!",{||FS_Busca(cRegGerF,1)},,,,,,.T.,,,,,,,,,"GBH","cRegGerF")
oGet1:SetFocus()
oGet2:= tGet():New(33,10,{|u| if(PCount()>0, cNomeF  :=u,cNomeF  )}, oDlg, 150,10,"@!",,,,,,,.T.,,,,,,,.T.,,,  "cNomeF")
oGet2:bGotFocus := {|| oGet3:SetFocus()}

oSay2:= tSay():New(50,10,{||STR0003},oDlg,,,,,,.T.,CLR_BLUE,,150,10) //"Prontuário que será excluído   : "
oGet3:= tGet():New(50,120,{|u| if(PCount()>0, cRegGerS:=u,cRegGerS)}, oDlg, 15,10,"@!",{||FS_Busca(cRegGerS,2)},,,,,,.T.,,,,,,,,,"GBH","cRegGerS")
oGet4:= tGet():New(63,10,{|u| if(PCount()>0, cNomeS  :=u,cNomeS  )}, oDlg, 150,10,"@!",,,,,,,.T.,,,,,,,.T.,,,  "cNomeS")
oGet4:bGotFocus := {|| oGet1:SetFocus()}

oBut1:=tButton():New(80,10,STR0004,oDlg,{|| FS_Proc1()  },40,15,,,,.T.) //"Confirma"

ACTIVATE MSDIALOG oDlg CENTERED //ON INIT EnchoiceBar(oDlg, {||oDlg:End()  }, {|| oDlg:End() })

DbSelectArea("GSA")
DbSetOrder(2) // GSA_FILIAL + GSA_OK + GSA_DATSOL + GSA_HORSOL + GSA_NOMPAC
HS_AtvFilt("GSA", "GSA->GSA_OK = ' ' ")

RestArea(aArea)

Return(Nil)
/*****************************************************************************************************************/
Static Function FS_Busca(cVemCod,cVemOp)
lRet := .F.
If cVemOp == 1
	cNomeF := HS_IniPadr("GBH", 1, cVemCod, "GBH_NOME",,.F.)
	If !Empty(cNomeF)
		lRet := .T.
	EndIf
Else
	cNomeS := HS_IniPadr("GBH", 1, cVemCod, "GBH_NOME",,.F.)
	If !Empty(cNomeS)
		lRet := .T.
	EndIf
EndIf
Return(lRet)
/*****************************************************************************************************************/
Static Function FS_Proc1()

If Empty(cRegGerF) .Or. Empty(cRegGerS)
	HS_MsgInf(STR0005, STR0025, STR0001)   //"O código do registro não pode ficar vazio..."###"Atenção"###"Unificar Prontuários"
	Return(Nil)
EndIf

If cRegGerF == cRegGerS
	HS_MsgInf(STR0006, STR0025, STR0001)   //"Os códigos não podem ser iguais..."###"Atenção"###"Unificar Prontuários"
	Return(Nil)
EndIf

Begin Transaction

DbSelectArea("GCY")
DbSetOrder(2) // GCY_FILIAL + GCY_REGGER + GCY_TPALTA
oList:Add(STR0007 + cRegGerS, oList:len() + 1) //"ATUALIZANDO O "
oList:Add(STR0008 + cRegGerF + " ........................................", oList:len() + 1) //"para "
oList:Add(STR0013, oList:len() + 1) //"GCY Atualizado..."
While DbSeek(xFilial("GCY") +  cRegGerS) .and. GCY->GCY_FILIAL == xFilial("GCY")
	
	FS_LOGUNI( "GCY" , GCY->GCY_FILIAL+GCY->GCY_REGATE , "1" ) /* GRAVA LOG DA MOVIMENTACAO */
	
	RecLock("GCY", .F.)
	GCY->GCY_REGGER := cRegGerF
	GCY->GCY_NOME   := cNomeF
	MsUnLock()
Enddo
oList:Refresh()

FS_Proc2() 	// GSA - SOLICITACOES DE PRONTUARIOS                FILIAL + GSA_CODSOL
FS_Proc3() 	// GSB - RELACIONAMENTO PRONTUARIO x ENDERECOS     *FILIAL + GSB_REGGER + GSB_CODEND
FS_Proc4() 	// GAV - CADASTRO DE LEITOS                         FILIAL + GAV_CODLOC + GAV_QUARTO + GAV_LEITO
FS_Proc5() 	// GCZ - GUIAS DE ATENDIMENTO                       FILIAL + GCZ_NRSEQG
FS_Proc6() 	// GD4 - RELACIONAMENTO PACIENTE x PLANO           *FILIAL + GD4_REGGER + GD4_CODPLA
FS_Proc7() 	// GM8 - AGENDA AMBULATORIAL                        FILIAL + GM8_CODAGE
FS_Proc8() 	// GM9 - AGENDAMENTOS CANCELADOS                    FILIAL + GM9_CODAGE
FS_Proc9() 	// GMA - AENDAMENTOS TRANSFERIDOS                   FILIAL + GMA_CODAGE
FS_Proc10()	// GMJ - RESERVAS CIRURGICA                         FILIAL + GMJ_CODAGE
FS_Proc11()	// GML - RESERVAS CANCELADAS                        FILIAL + GML_CODAGE
FS_Proc12()	// GMM - RESERVA TRANSFERIDAS                       FILIAL + GMM_CODAGE
FS_Proc13()	// GSE - NAO CONFORMIDADES DO SAME - SPP            FILIAL + GSE_CODNAO
FS_Proc14()	// GB4 - AGENDA CIRURGICA                           FILIAL + GB4_CODAGD
FS_Proc15()	// GBH - DADOS ADICIONAIS DE PACIENTE               FILIAL + GBH_REGGER

End Transaction

Return Nil
/******************************************************************************************************************/
Static Function FS_Proc2()
DbSelectArea("GSA")
DbSetOrder(1) // GSA_FILIAL + GSA_OK + GSA_REGGER + GSA_DATSOL
oList:Add(STR0009, oList:len() + 1) //"SPP Movimento(GSA)"
While DbSeek(xFilial("GSA") + " " + cRegGerS ) .And. GSA->GSA_FILIAL == xFilial("GSA")
	FS_LOGUNI( "GSA" , GSA->GSA_FILIAL+GSA->GSA_CODSOL , "4" ) /* GRAVA LOG DA MOVIMENTACAO */
	RecLock("GSA", .F.)
	GSA->GSA_REGGER := cRegGerF
	GSA->GSA_NOMPAC := cNomeF
	MsUnLock()
EndDo
oList:Refresh()
Return(Nil)
/******************************************************************************************************************/
Static Function FS_Proc3()
Local cEndAnt := ""
DbSelectArea("GSB")
DbSetOrder(1) // GSB_FILIAL + GSB_REGGER + GSB_CODEND
oList:Add(STR0010, oList:len() + 1) //"Relacionamento SPP(GSB)"
DbSeek(xFilial("GSB") +  cRegGerS)
While (GSB->GSB_FILIAL == xFilial("GSB")) .AND. (GSB->GSB_REGGER == cRegGerS) .AND. !EOF()
	
	If cEndAnt # GSB->GSB_CODEND
		cEndAnt := GSB->GSB_CODEND
	Else
		DbSkip()
		Loop
	EndIf
	
	IF !DbSeek(xFilial("GSB") +  cRegGerF + cEndAnt )
		DbSeek(xFilial("GSB") +  cRegGerS + cEndAnt )
		FS_LOGUNI( "GSB" , GSB->GSB_FILIAL+GSB->GSB_REGGER+GSB->GSB_CODEND , "1" ) /* GRAVA LOG DA MOVIMENTACAO */
		RecLock("GSB", .F.)
		GSB->GSB_REGGER := cRegGerF
		MsUnLock()
	ENDIF
	
EndDo

oList:Refresh()
Return(Nil)
/******************************************************************************************************************/
Static Function FS_Proc4()
DbSelectArea("GAV")
DbSetOrder(5) // GAV_FILIAL + GAV_REGGER
oList:Add(STR0014, oList:len() + 1) //"GAV Atualizado..."
While DbSeek(xFilial("GAV") +  cRegGerS) .and. GAV->GAV_FILIAL == xFilial("GAV")
	FS_LOGUNI( "GAV" , GAV->GAV_FILIAL+GAV->GAV_CODLOC+GAV->GAV_QUARTO+GAV->GAV_LEITO , "1" ) /* GRAVA LOG DA MOVIMENTACAO */
	RecLock("GAV", .F.)
	GAV->GAV_REGGER := cRegGerF
	GAV->GAV_NOME   := cNomeF
	MsUnLock()
Enddo
oList:Refresh()
Return Nil
/******************************************************************************************************************/
Static Function FS_Proc5()
DbSelectArea("GCZ")
DbSetOrder(11) // GCZ_FILIAL + GCZ_REGGER
oList:Add(STR0015, oList:len() + 1) //"GCZ Atualizado..."
While DbSeek(xFilial("GCZ") +  cRegGerS) .and. GCZ->GCZ_FILIAL == xFilial("GCZ")
	FS_LOGUNI( "GCZ" , GCZ->GCZ_FILIAL+GCZ->GCZ_NRSEQG  , "1" ) /* GRAVA LOG DA MOVIMENTACAO */
	RecLock("GCZ", .F.)
	GCZ->GCZ_REGGER := cRegGerF
	GCZ->GCZ_NOME   := cNomeF
	MsUnLock()
Enddo
oList:Refresh()
Return Nil
/******************************************************************************************************************/
Static Function FS_Proc6()
Local aPlano   := {}
Local nPlan    := 0

DbSelectArea("GD4")
DbSetOrder(1) // GD4_FILIAL + GD4_REGGER + GD4_CODPLA
oList:Add(STR0016, oList:len() + 1) //"GD4 Atualizado..."
DbSeek(xFilial("GD4") +  cRegGerS )
While (GD4->GD4_FILIAL == xFilial("GD4")) .And. (GD4->GD4_REGGER == cRegGers) .And. !Eof()
	
	AADD(aPlano,{GD4->GD4_REGGER, GD4->GD4_CODPLA})
	
	DbSkip()
EndDo

For  nPlan := 1 to Len(aPlano)
	
	IF !DbSeek(xFilial("GD4") +  cRegGerF + aPlano[nPlan,2])
		DbSeek(xFilial("GD4") +  cRegGerS + aPlano[nPlan,2])
		FS_LOGUNI( "GD4" , GD4->GD4_FILIAL+GD4->GD4_REGGER+GD4->GD4_CODPLA  , "1" ) /* GRAVA LOG DA MOVIMENTACAO */
		RecLock("GD4", .F.)
		GD4->GD4_REGGER := cRegGerF
		GD4->GD4_IDPADR := "0"
		MsUnLock()
	EndIf
	
Next nPlan
oList:Refresh()
Return Nil
/******************************************************************************************************************/
Static Function FS_Proc7()
DbSelectArea("GM8")
DbSetOrder(10)  // GM8_FILIAL + GM8_REGGER + GM8_CODPRO + GM8_DATAGE + GM8_STATUS
oList:Add(STR0017, oList:len() + 1) //"GM8 Atualizado..."
While DbSeek(xFilial("GM8") +  cRegGerS) .and. GM8->GM8_FILIAL == xFilial("GM8")
	FS_LOGUNI( "GM8" , GM8->GM8_FILIAL+GM8->GM8_CODAGE  , "1" ) /* GRAVA LOG DA MOVIMENTACAO */
	RecLock("GM8", .F.)
	GM8->GM8_REGGER := cRegGerF
	GM8->GM8_NOMPAC := cNomeF
	MsUnLock()
Enddo
oList:Refresh()
Return Nil
/******************************************************************************************************************/
Static Function FS_Proc8()
Local cCageSReg := ""
Local cIAgeSReg := ""
DbSelectArea("GM9")
DbSetOrder(3) // GM9_FILIAL + GM9_REGGER

oList:Add(STR0018, oList:len() + 1) //"GM9 Atualizado..."

While DbSeek(xFilial("GM9") +  cRegGerS) .and. GM9->GM9_FILIAL == xFilial("GM9")
	If GM9->(FieldPos("GM9_SEQREG")) > 0    // Checar se existe campo _SEQREG (release 3/4) (AGENDAMENTOS CANCELADOS)
		cCageSreg:=GM9->GM9_SEQREG
		cIageSreg:="4"
	Else
		cCageSreg:=GM9->GM9_CODAGE
		cIageSreg:="1"		
	EndIf
	FS_LOGUNI( "GM9", GM9->GM9_FILIAL + cCageSreg  ,cIAgeSReg ) /* GRAVA LOG DA MOVIMENTACAO */
	RecLock("GM9", .F.)
	GM9->GM9_REGGER := cRegGerF
	GM9->GM9_NOMPAC := cNomeF
	MsUnLock()
Enddo
oList:Refresh()
Return Nil
/******************************************************************************************************************/
Static Function FS_Proc9()
Local cCageSReg := ""
Local cIAgeSReg := ""
DbSelectArea("GMA")
DbSetOrder(3) // GMA_FILIAL + GMA_REGGER
oList:Add(STR0019, oList:len() + 1) //"GMA Atualizado..."

While DbSeek(xFilial("GMA") +  cRegGerS) .and. GMA->GMA_FILIAL == xFilial("GMA")
	
	If GMA->(FieldPos("GMA_SEQREG")) > 0    // Checar se existe campo _SEQREG (release 3/4) (AGENDAMENTOS TRANSFERIDOS)
		cCageSreg:=GMA->GMA_SEQREG
		cIageSreg:="4"		
	Else
		cCageSreg:=GMA->GMA_CODAGE
		cIageSreg:="1"
	EndIf
	
	FS_LOGUNI( "GMA" , GMA->GMA_FILIAL+ cCageSreg, cIAgeSReg ) /* GRAVA LOG DA MOVIMENTACAO */
	RecLock("GMA", .F.)
	GMA->GMA_REGGER := cRegGerF
	GMA->GMA_NOMPAC := cNomeF
	MsUnLock()
Enddo
oList:Refresh()
Return Nil
/******************************************************************************************************************/
Static Function FS_Proc10()
DbSelectArea("GMJ")
DbSetOrder(5)  // GMJ_FILIAL + GMJ_REGGER + GMJ_DATAGE + GMJ_CODPRO
oList:Add(STR0020, oList:len() + 1) //"GMJ Atualizado..."
While DbSeek(xFilial("GMJ") +  cRegGerS) .and. GMJ->GMJ_FILIAL == xFilial("GMJ")
	FS_LOGUNI( "GMJ" , GMJ->GMJ_FILIAL+GMJ->GMJ_CODAGE  , "1" ) /* GRAVA LOG DA MOVIMENTACAO */
	RecLock("GMJ", .F.)
	GMJ->GMJ_REGGER := cRegGerF
	GMJ->GMJ_NOMPAC := cNomeF
	MsUnLock()
Enddo
oList:Refresh()
Return Nil
/******************************************************************************************************************/
Static Function FS_Proc11()
Local cCageSReg := ""
Local cIAgeSReg := ""
DbSelectArea("GML")
DbSetOrder(3) // GML_FILIAL + GML_REGGER
oList:Add(STR0021, oList:len() + 1) //"GML Atualizado..."
While DbSeek(xFilial("GML") +  cRegGerS) .and. GML->GML_FILIAL == xFilial("GML")
	
	If GML->(FieldPos("GML_SEQREG")) > 0    // Checar se existe campo _SEQREG (release 3/4) (RESERVAS CANCELADAS)
		cCageSreg:=GML->GML_SEQREG
		cIageSreg:="4"				
	Else
		cCageSreg:=GML->GML_CODAGE
		cIageSreg:="1"				
	EndIf
	
	FS_LOGUNI( "GML" , GML->GML_FILIAL + cCageSreg, cIAgeSReg ) /* GRAVA LOG DA MOVIMENTACAO */
	RecLock("GML", .F.)
	GML->GML_REGGER := cRegGerF
	GML->GML_NOMPAC := cNomeF
	MsUnLock()
Enddo
oList:Refresh()
Return Nil
/******************************************************************************************************************/
Static Function FS_Proc12()
Local cCageSReg := ""
Local cIAgeSReg := ""
DbSelectArea("GMM")
DbSetOrder(3) // GMM_FILIAL + GMM_REGGER
oList:Add(STR0022, oList:len() + 1) //"GMM Atualizado..."
While DbSeek(xFilial("GMM") +  cRegGerS) .and. GMM->GMM_FILIAL == xFilial("GMM")
	
	If GMM->(FieldPos("GMM_SEQREG")) > 0    // Checar se existe campo _SEQREG (release 3/4) (RESERVAS TRANSFERIDAS)
		cCageSreg:=GMM->GMM_SEQREG
		cIageSreg:="4"				
	Else
		cCageSreg:=GMM->GMM_CODAGE
		cIageSreg:="1"				
	EndIf
	
	FS_LOGUNI( "GMM" , GMM->GMM_FILIAL + cCageSreg, cIAgeSReg ) /* GRAVA LOG DA MOVIMENTACAO */
	RecLock("GMM", .F.)
	GMM->GMM_REGGER := cRegGerF
	GMM->GMM_NOMPAC := cNomeF
	MsUnLock()
Enddo
oList:Refresh()
Return Nil
/******************************************************************************************************************/
Static Function FS_Proc13()
DbSelectArea("GSE")
DbSetOrder(2) // GSE_FILIAL + GSE_REGGER + GSE_CODEND
oList:Add(STR0023, oList:len() + 1) //"GSE Atualizado..."
While DbSeek(xFilial("GSE") +  cRegGerS) .and. GSE->GSE_FILIAL == xFilial("GSE")
	FS_LOGUNI( "GSE" , GSE->GSE_FILIAL+GSE->GSE_CODNAO  , "1" ) /* GRAVA LOG DA MOVIMENTACAO */
	RecLock("GSE", .F.)
	GSE->GSE_REGGER := cRegGerF
	GSE->GSE_NOMPAC := cNomeF
	MsUnLock()
Enddo
oList:Refresh()
Return Nil
/******************************************************************************************************************/
Static Function FS_Proc14()
DbSelectArea("GB4")
DbSetOrder(2) // GB4_FILIAL + GB4_CODCRM
oList:Add(STR0024, oList:len() + 1) //"GB4 Atualizado..."
While DbSeek(xFilial("GB4") +  cRegGerS) .and. GB4->GB4_FILIAL == xFilial("GB4")
	FS_LOGUNI( "GB4" , GB4->GB4_FILIAL+GB4->GB4_CODAGD  , "5" ) /* GRAVA LOG DA MOVIMENTACAO */
	RecLock("GB4", .F.)
	GB4->GB4_REGGER := cRegGerF
	GB4->GB4_NOME   := cNomeF
	MsUnLock()
Enddo
oList:Refresh()
Return Nil
/******************************************************************************************************************/
Static Function FS_Proc15()
DbSelectArea("GBH")
DbSetOrder(1) // GBH_FILIAL + GBH_CODPAC
oList:Add(STR0011, oList:len() + 1) //"Cadastro de Pacientes(GBH)"
If DbSeek(xFilial("GBH") +  cRegGerS )
	FS_LOGUNI( "GBH" , GBH->GBH_FILIAL+GBH->GBH_CODPAC  , "1" ) /* GRAVA LOG DA MOVIMENTACAO */
	RecLock("GBH", .F.)
	DBDELETE()
	MsUnLock()
Endif
oList:Add(STR0012, oList:len() + 1) //"............TERMINOU."
oList:Refresh()
oBut1:Disable()
Return(Nil)
/******************************************************************************************************************/
STATIC FUNCTION FS_LOGUNI(cTabUni,cChaUni,cOrdUni)
Local aArea := GetArea()

DbSelectArea("GSH")
DbSetOrder(1) // GSH_FILIAL + GSH_CODIGO
M->GSH_CODIGO := CriaVar("GSH_CODIGO")
M->GSH_CODIGO := HS_VSxeNum("GSH", "M->GSH_CODIGO", 1)
RecLock("GSH", .T.)
GSH->GSH_FILIAL := xFilial("GSH")
GSH->GSH_CODIGO := M->GSH_CODIGO
GSH->GSH_TABELA := cTabUni
GSH->GSH_CHAVE  := cChaUni
GSH->GSH_ORDEM  := cOrdUni
GSH->GSH_ANTIGO := cRegGerS
GSH->GSH_NOVO   := cRegGerF
GSH->GSH_LOGARQ := HS_LOGARQ()
MsUnLock()

RestArea(aArea)
RETURN(NIL)
