#INCLUDE "HSPAHA05.ch"
#include "protheus.CH"
#include "colors.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออออัอออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHA05           บ Autor ณ Luiz Pereira S. Jr.                             บ Data ณSJRP 22/11/01บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Empresa                                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑณ                               ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador    ณ Data   ณ BOPS ณ  Motivo da Alteracao                                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณL.Gustavo Caloiณ07/07/06ณ******ณFoi criado uma valida็ใo no CGC.                                              ณฑฑ
ฑฑณ               ณ        ณ      ณ                                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function HSPAHA05()

Private aRotina := MenuDef()


DbSelectArea("GAE")
DbSetOrder(1)


mBrowse(06, 01, 22, 75, "GAE")

Return

Function HS_A05(cAlias, nReg, nOpc)
Local nOpcA := 0

Private lGFQ := HS_LocTab("GFQ", .F.)

Private nOpcE := aRotina[nOpc, 4]
Private nGDOpc := IIf(StrZero(nOpcE,2) $ "03/04" , GD_INSERT + GD_UPDATE + GD_DELETE, 0  )
Private aTela 					:= {}
Private aGets      := {}
Private aHeader 			:= {}
Private aCols      := {}
Private nUsado     := 0
Private oGAE, oGetGFQ
Private lGDVazio := .F.
Private nCodPla  :=0

RegToMemory("GAE",(nOpcE == 3)) //Gera variavies de memoria para o GAE

If lGFQ
	HS_BDados("GFQ", @aHeader, @aCols,, 1,, IIf(!Empty(M->GAE_CODEMP), "GFQ->GFQ_CODEMP == '" + M->GAE_CODEMP + "'", Nil))
	nCodPla := aScan(aHeader, {| aVet | aVet[2] == "GFQ_CODPLA"})
EndIf

nOpcA := 0

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 030, .T., .T. } )
AAdd( aObjects, { 100, 070, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd  //"Cadastro de Empresa"

oGAE:= MsMGet():New(cAlias, nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
oGAE:oBox:align:= CONTROL_ALIGN_ALLCLIENT

If lGFQ
	oGetGFQ := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,"HS_DuplAC(oGetGFQ:oBrowse:nAt, oGetGFQ:aCols, {nCodPla})",,,,,,,,, oDlg, aHeader, aCols)
	oGetGFQ:oBrowse:align:= CONTROL_ALIGN_BOTTOM
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIf(nOpcE == 5, Fs_Exc05(), .T.), oDlg:End(), nOpcA == 0)}, ;
{|| nOpcA := 0, oDlg:End()})
If nOpcA == 0
	While __lSx8
		RollBackSxe()
	End
ElseIf nOpcA == 1 .And. nOpcE <> 2
	Begin Transaction
	FS_GrvA05(nReg)
	End Transaction
EndIf

Return()

Function FS_GrvA05(nReg)
Local aArea := GetArea()
Local nFor
Local lAchou :=.F.

DbSelectArea("GAE")

If nOpcE <> 3
	DbGoTo(nReg)
Endif

If nOpcE == 3 .Or. nOpcE == 4 //Inclusao e Alterar
	
	RecLock("GAE", (nOpcE == 3))
	HS_GrvCpo("GAE")
	GAE->GAE_FILIAL := xFilial("GAE")
	GAE->GAE_LOGARQ := HS_LogArq()
	MsUnlock()
 ConfirmSx8()

	//Gravar GetDados
	
	If lGFQ
		
		DbSelectArea("GFQ")
		DbSetOrder(1)//GFQ_FILIAL+GFQ_CODEMP+GFQ_CODPLA
		
		For nFor :=1 To Len(oGetGFQ:aCols)
			lAchou := DbSeek(xFilial("GFQ") + M->GAE_CODEMP + oGetGFQ:aCols[nFor, nCodPla])
			If oGetGFQ:aCols[nFor, Len(oGetGFQ:aHeader)+1 ]== .T.  // Se a linha esta deletada na get e achou o kra no banco
				If lAchou .And. nOpcE <> 3
					RecLock("GFQ", .F., .F. )
					DbDelete()
					MsUnlock()
					WriteSx2("GFQ")
				EndIf
			Else
				RecLock("GFQ", !lAchou )
				HS_GRVCPO("GFQ", oGetGFQ:aCols, oGetGFQ:aHeader, nFor)
				GFQ->GFQ_FILIAL := xFilial("GFQ")
				GFQ->GFQ_CODEMP := M->GAE_CODEMP
				GFQ->GFQ_LOGARQ := HS_LogArq()
				MsUnlock()
			EndIf
		Next
		
	EndIf
	
ElseIf nOpcE == 5 //Exclusao
	If lGFQ
		
		DbSelectArea("GFQ")
		DbSetOrder(1)//GFQ_FILIAL+GFQ_CODEMP+GFQ_CODPLA
		DbSeek(xFilial("GFQ") + M->GAE_CODEMP )
		While !Eof() .And. GFQ->GFQ_FILIAL = xFilial("GFQ") .And. GFQ->GFQ_CODEMP = M->GAE_CODEMP
			RecLock("GFQ", .F., .F. )
			DbDelete()
			MsUnlock()
			WriteSx2("GFQ")
			DbSkip()
		End
		
	EndIf
	
	RecLock("GAE", .F., .F. )
	DbDelete()
	MsUnlock()
	WriteSx2("GAE")
Endif

RestArea(aArea)

Return()

// Funcao de Exclusao
Function Fs_Exc05()
Local lRet := .T.

// Verifica relacionamento na GCY (Atendimento).
If HS_CountTB("GCY", "GCY_CODEMP  = '" + GAE->GAE_CODEMP + "'")  > 0
	HS_MsgInf(STR0007,STR0008,STR0006)  //"Existe(m) atendimento(s) cadastrado(s) para esta empresa. Exclusใo nใo permitida"###"Aten็ใo"###"Cadastro de Empresa"
	lRet := .F.
EndIf

// Verifica relacionamento na GBH (Paciente).
If lRet .And. GBH->(FieldPos("GBH_CODEMP")) > 0
	If HS_CountTB("GBH", "GBH_CODEMP  = '" + GAE->GAE_CODEMP + "'")  > 0
		HS_MsgInf(STR0009,STR0008,STR0006)  //"Existe(m) paciente(s) cadastrado(s) para esta empresa. Exclusใo nใo permitida"###"Aten็ใo"###"Cadastro de Empresa"
		lRet := .F.
	EndIf
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_Valid05บAutor  ณL. Gustavo M. Caloi บ Data ณ  05/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida CGC                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_Valid05()
Local lRet := .F.

If !Empty(M->GAE_CGCEMP)
	If Len(AllTrim(M->GAE_CGCEMP))==14
		If Cgc(M->GAE_CGCEMP)
			lRet := .T.
		Else
			lRet := .F.
		Endif
	Else
		lRet := .F.
		HS_MsgInf(STR0012, STR0008, STR0011)//"A Quantidade de N๚mero do CGC ้ Invแlido."###"Aten็ใo"###"Valida็ใo do CGC"
	EndIf
Else
	lRet := .T.
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 11/07/07 ณฑฑ
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
Local aRotina :=	{{OemtoAnsi(STR0001) , "axPesqui"	, 0, 1, 0, nil},; //"Pesquisar"
					 {OemtoAnsi(STR0002) , "HS_A05"		, 0, 2, 0, nil},; //"Visualizar"
					 {OemtoAnsi(STR0003) , "HS_A05"		, 0, 3, 0, nil},; //"Incluir"
					 {OemtoAnsi(STR0004) , "HS_A05"		, 0, 4, 0, nil},; //"Alterar"
					 {OemtoAnsi(STR0005) , "HS_A05"		, 0, 5, 0, nil}} //"Excluir"
                     
Return(aRotina)