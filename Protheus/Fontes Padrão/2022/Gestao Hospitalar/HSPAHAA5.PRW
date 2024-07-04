#INCLUDE "HSPAHAA5.ch"
#include "protheus.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHAA5  º Autor ³ José Orfeu         º Data ³  07/12/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Origem do paciente                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION HSPAHAA5()
Private aRotina		:= MenuDef()
Private cCadastro	:= STR0001		//"Cadastro de origem do paciente"

DbSelectArea("GD0")
DbSetOrder(1)

mBrowse( 6,1,22,75, "GD0")

Return(Nil)

Function HS_AA5(cAlias, nReg, nOpc)
Local nOpcA := 0
Local cDesRot := ""
Private cDelFunc := "HS_VEAA5()"
Private nOpcE    := aRotina[nOpc, 4]
Private aTela    := {}
Private aGets    := {}
Private aHeader  := {}
Private aCols    := {}
Private nUsado   := 0
Private oGD0
Private lGDVazio := .F.

RegToMemory("GD0",(nOpcE == 3)) //Gera variavies de memoria para o GD0

nOpcA := 0

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

If nOpc == 3    
    cDesRot := STR0001+" - "+STR0004
ElseIf nOpc == 4       
    cDesRot := STR0001+" - "+STR0005
ElseIf nOpc == 5     
    cDesRot := STR0001+" - "+STR0006
EndIf
    
DEFINE MSDIALOG oDlg TITLE OemToAnsi(cDesRot) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Cadastro de CID"

oGD0 := MsMGet():New("GD0", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
oGD0:oBox:align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIf(nOpcE == 5, HS_VEAA5(), .T.), oDlg:End(), nOpcA == 0)}, ;
{|| nOpcA := 0, oDlg:End()})

If nOpcA == 1 .And. nOpcE <> 2
	Begin Transaction
	FS_GrvAA5(nReg)
	End Transaction
EndIf

Return()

Function FS_GrvAA5()

Local aArea := GetArea()
Local lEspelhar := GetNewPar("MV_INTADMP",.F.)
Local lNovBDR 	:= .T.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Espelhamento GD0 X BDR...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcE == 3   //Inclusao
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Origem ja existe Tabela PLS                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lEspelhar
		
		If  ! Empty(M->GD0_ORIPAC)
			DbSelectArea("BDR")
			BDR->(DbSetOrder(3))
			lNovBDR := (BDR->(MsSeek(xFilial("BDR")+M->GD0_ORIPAC)))
		Endif
	Else
		lNovBDR := .T.
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se deve criar Origem AnO pLANO DE sAUDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  ! LNovBDR
		DbSelectArea("BBL")
		BBL->(DbSetOrder(2))
		If 	BBL->(MsSeek(xFilial("BBL")+"HSPAHAA5  "+"GD0"+"BDR"))
			BDR->(RecLock("BDR",(nOpcE == 3)))
			BDR->BDR_FILIAL := xFilial("BDR")
			IF GD0->(FieldPos("GD0_CODINT"))>0 
				BDR->BDR_CODOPE := M->GD0_CODINT 
				BDR->BDR_CARINT := M->GD0_CARINT 
			Endif
			PlsSinc("HSPAHAA5","GD0","BDR")
			BDR->(MsUnLock())
		Else
			If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi(STR0008)) //"Arquivo de sincronismo entre BDR x GD0 nao esta integro. Verifique!"
			Endif
		Endif
		
	Endif
	
	RecLock("GD0", (nOpcE == 3))
	HS_GrvCpo("GD0")
	GD0->GD0_FILIAL:=xFilial("GD0")
	GD0->GD0_LOGARQ := HS_LOGARQ()
	MsUnlock()
	
	
ElseIf nOpcE == 4
	If lEspelhar
		DbSelectArea("BDR")
		BDR->(DbSetOrder(3))
		If BDR->(MsSeek(xFilial("BDR")+M->GD0_ORIPAC))
			DbSelectArea("BBL")
			BBL->(DbSetOrder(2))
			If BBL->(MsSeek(xFilial("BBL")+"HSPAHAA5  "+"GD0"+"BDR"))
				BDR->(RecLock("BDR",.F.))
				BDR->BDR_FILIAL := xFilial("BDR")
				IF BDR->(FieldPos("GD0_CODINT"))>0 
					If !Empty(M->GD0_CODINT)
						BDR->BDR_CODOPE := M->GD0_CODINT 
					Endif
					If !Empty(M->GD0_CARINT)
						BDR->BDR_CARINT := M->GD0_CARINT 
					Endif	
				Endif			
				PlsSinc("HSPAHAA5","GD0","BDR")
				BDR->(MsUnLock())
			Else
				If GetNewPar("MV_PLSMSGS","1") == "1"
					MsgAlert(OemtoAnsi(STR0008)) //"Arquivo de sincronismo entre BDR x GD0 nao esta integro. Verifique!"
				Endif
			Endif
		Endif
	Endif
	
	RecLock("GD0", .F.)
	HS_GrvCpo("GD0")
	GD0->GD0_FILIAL:=xFilial("GD0")
	GD0->GD0_LOGARQ := HS_LOGARQ()
	MsUnlock()
	
ElseIf nOpcE == 5
	
	If lEspelhar
		DbSelectArea("BDR")
		BDR->(DbSetOrder(3))
		If BDR->(MsSeek(xFilial("BDR")+M->GD0_ORIPAC))
			DbSelectArea("BBL")
			BBL->(DbSetOrder(2))
			If BBL->(MsSeek(xFilial("BBL")+"HSPAHAA5  "+"GD0"+"BDR"))
				RecLock("BDR", .F.)
				DbDelete()
				MsUnlock()
			Else
				If GetNewPar("MV_PLSMSGS","1") == "1"
					MsgAlert(OemtoAnsi(STR0008)) //"Arquivo de sincronismo entre BDR x GD0 nao esta integro. Verifique!"
				Endif
			Endif
		Endif
	Endif
	
	RecLock("GD0", .F.)
	DbDelete()
	MsUnlock()
	
Endif

RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ 				        ³ Data ³ 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Função de Verificação de Exclusão/Sincronismo Tabela PLS   ³±±
±±³Verifica no Atendimento se existe informações lançadas para 			  ³±±
±±³origem de Paciente													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_VEAA5()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_VEAA5()
Local lRet := .T., cAliasOld := Alias()

DbSelectArea("GCY")
DbSetOrder(5)

If !(lRet := !DBSeek(xFilial("GCY") + GD0->GD0_ORIPAC))
	If FunName() # "PLSA163"
		Help(" ", 1, "HAA5RELGCY",, STR0007, 1) //"Registro encontrado no atendimento e não pode ser excluido"
	else
		HS_MsgInf(STR0009, STR0010, STR0011) //"Registro encontrado no atendimento.", "Sincronismo  não Efetuado na Tabela do SIGAHSP", "Validação de Sincronismo no Modulo SIGAHSP"
	Endif
EndIf
DbSelectArea(cAliasOld)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 11/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina := {	{STR0002, "AxPesqui", 0, 1, 0, nil},; //"Pesquisar"
					{STR0003, "AxVisual", 0, 2, 0, nil},; //"Visualizar"
					{STR0004, "HS_AA5"  , 0, 3, 0, nil},; //"Incluir"
					{STR0005, "HS_AA5"  , 0, 4, 0, nil},; //"Alterar"
					{STR0006, "HS_AA5"  , 0, 5, 0, nil}}  //"Excluir"





	
    	aadd(aRotina, {"Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('GD0',GD0->GD0_ORIPAC, 1)})", 0 ,})
		aadd(aRotina, {"Excluir Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('GD0',GD0->GD0_ORIPAC, 0)})", 0 ,})                  

								
					
Return(aRotina)
