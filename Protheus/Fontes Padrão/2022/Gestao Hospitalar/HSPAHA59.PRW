#INCLUDE "HSPAHA59.ch"
#include "protheus.CH"
#include "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA59  º Autor ³ Daniel Peixoto     º Data ³  18/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Tipo de Acomodacao                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPAHA59()
 Private cCadastro := STR0001 //"Tipo de Acomodacao"
 Private aRotina   := {{OemToAnsi(STR0002), "axPesqui", 0, 1} ,;   //"Pesquisar"
                       {OemToAnsi(STR0003), "HS_A59"  , 0, 2} ,;   //"Visualizar"
                       {OemToAnsi(STR0004), "HS_A59"  , 0, 3} ,;   //"Incluir"
                       {OemToAnsi(STR0005), "HS_A59"  , 0, 4} ,;   //"Alterar"
                       {OemToAnsi(STR0006), "HS_A59"  , 0, 5} }   //"Excluir"

 DbSelectArea("G07")
 mBrowse(06, 01, 22, 75, "G07")

Return()            	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_A59    º Autor ³ Daniel Peixoto     º Data ³  18/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_A59(cAlias, nReg, nOpc)
 Local nGDOpc := IIf(aRotina[nOpc, 4] == 3 .or. aRotina[nOpc, 4] == 4, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 Local nOpcG  := aRotina[nOpc, 4]
 Local nOpcA  := 0 
 Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {} 
                
 Private aTela := {}, aGets := {}
 Private oG07
 
 RegToMemory("G07", nOpcG == 3)
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 100, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 nOpcA := 0 
 DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel
  oG07 := MsMGet():New("G07", nReg, nOpc	,,,,, aPObjs[1],, 2)
  oG07:oBox:Align := CONTROL_ALIGN_ALLCLIENT
  
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)}, ;
                                                  {|| nOpcA := 0, oDlg:End()} )

 If nOpcA == 1 
 	Begin Transaction
 	FS_GrvA59(nOpcG)
 	End Transaction
 Endif

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GrvA59 º Autor ³ Daniel Peixoto     º Data ³  18/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualizacao do cadastro                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GrvA59(nOpcG)
Local lEspelhar := GetNewPar("MV_INTACOM",.F.) // Parametro Integracao das Tabelas de Acomodaçoes PLS X GH
Local LNovBI4 	:= .T.
Local aArea := GetArea()

If nOpcG == 2     // Se for uma consulta
	Return(.T.)
Endif

DbselectArea("G07")
DbsetOrder(1)
lAchou := DbSeek(xFilial("G07") + M->G07_CODIGO)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Espelhamento G07 X BI4...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lEspelhar
	
	If  ! Empty(M->G07_CODIGO)
		DbSelectArea("BI4")
		BI4->(DbSetOrder(1))
		lNovBI4 := (BI4->(MsSeek(xFilial("BI4")+M->G07_CODIGO)))
	Endif
Else
	lNovBI4 := .T.
Endif



If nOpcG == 3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Acomodação ja existe Tabela PLS                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se deve criar Acomodação                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  ! LNovBI4
		DbSelectArea("BBL")
		BBL->(DbSetOrder(2))
		If 	BBL->(MsSeek(xFilial("BBL")+"HSPAHA59  "+"G07"+"BI4"))
			BI4->(RecLock("BI4",!lAchou))
			BI4->BI4_FILIAL := xFilial("BI4")
			PlsSinc("HSPAHA59","G07","BI4")
			BI4->(MsUnLock())
		Else
			If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi(STR0007)) //"Arquivo de sincronismo entre BI4 x G07 nao esta integro. Verifique!"
			Endif
		Endif
		
	Endif
	
	RecLock("G07", !lAchou)
	HS_GrvCpo("G07")
	G07->G07_FILIAL:=xFilial("G07")
	MsUnlock()
	
	
ElseIf nOpcG == 4	
	
	If lEspelhar
		
		DbSelectArea("BI4")
		BI4->(DbSetOrder(1))
		If BI4->(MsSeek(xFilial("BI4")+M->G07_CODIGO)) .OR. !lNovBI4
			DbSelectArea("BBL")
			BBL->(DbSetOrder(2))
			If BBL->(MsSeek(xFilial("BBL")+"HSPAHA59  "+"G07"+"BI4"))
				BI4->(RecLock("BI4", !lAchou))
				BI4->BI4_FILIAL := xFilial("BI4")
				PlsSinc("HSPAHA59","G07","BI4")
				BI4->(MsUnLock())
			Else
				If GetNewPar("MV_PLSMSGS","1") == "1"
					MsgAlert(OemtoAnsi(STR0007)) //"Arquivo de sincronismo entre BI4 x G07 nao esta integro. Verifique!"
				Endif
			Endif
		Endif
	Endif
	
	RecLock("G07", !lAchou)
	HS_GrvCpo("G07")
	G07->G07_FILIAL:=xFilial("G07")
	MsUnlock()
	
ElseIf nOpcG == 5
	
	If lEspelhar
		DbSelectArea("BI4")
		BI4->(DbSetOrder(1))
		If BI4->(MsSeek(xFilial("BI4")+M->G07_CODIGO)) .and. PLSA040Del(nOpcG)
			DbSelectArea("BBL")
			BBL->(DbSetOrder(2))
			If BBL->(MsSeek(xFilial("BBL")+"HSPAHA59  "+"G07"+"BI4"))
				RecLock("BI4", .F.)
				DbDelete()
				MsUnlock()
			Else
				If GetNewPar("MV_PLSMSGS","1") == "1"
					MsgAlert(OemtoAnsi(STR0007)) //"Arquivo de sincronismo entre BI4 x G07 nao esta integro. Verifique!"
				Endif
			Endif
		Endif
	Endif
	
	
	RecLock("G07", .F., .T.)
	DbDelete()
	MsUnlock()
	WriteSx2("G07")
	
Endif


RestArea(aArea)

Return(Nil)
