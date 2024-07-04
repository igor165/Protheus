#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "VEIC100.CH"

/*/{Protheus.doc} VEIC100
	Consulta por Grupo de Negócios e Clientes

	@author Andre Luis Almeida
	@since 12/01/2021
/*/
Function VEIC100()

Local oVEIC100
Local aSize     := FWGetDialogSize( oMainWnd )
Local cTitulo   := STR0001 // Consulta por Grupos de Negócios e Clientes

oVEIC100 := MSDIALOG() :New(aSize[1],aSize[2],aSize[3],aSize[4],cTitulo,,,,128,,,,,.t.)

	oTPanGrpNeg := TPanel():New(0,0,"",oVEIC100,NIL,.T.,.F.,NIL,NIL,100,(oVEIC100:nClientHeight/4)-10,.F.,.F.)
	oTPanGrpNeg:Align := CONTROL_ALIGN_TOP

	oTPanClient := TPanel():New(0,0,"",oVEIC100,NIL,.T.,.F.,NIL,NIL,100,(oVEIC100:nClientHeight/4)-10,.F.,.F.)
	oTPanClient:Align := CONTROL_ALIGN_BOTTOM 

	oBrwVJW := FWMBrowse():New()
	oBrwVJW:SetAlias('VJW')
	oBrwVJW:SetOwner(oTPanGrpNeg)
	oBrwVJW:SetDescription(STR0002) // Grupo de Negocios
	oBrwVJW:DisableDetails()
	oBrwVJW:lOptionReport := .f.
	oBrwVJW:ForceQuitButton()
	oBrwVJW:SetAmbiente(.F.)
	oBrwVJW:SetWalkthru(.F.)
	oBrwVJW:SetMenuDef("VEIC101")
	oBrwVJW:Activate()

	oBrwSA1 := FWMBrowse():New()
	oBrwSA1:SetAlias('SA1')
	oBrwSA1:SetOwner(oTPanClient)
	oBrwSA1:SetDescription(STR0003) // Clientes
	oBrwSA1:DisableDetails()
	oBrwSA1:lOptionReport := .f.
	oBrwSA1:ForceQuitButton()
	oBrwSA1:SetAmbiente(.F.)
	oBrwSA1:SetWalkthru(.F.)
	oBrwSA1:SetMenuDef("VEIC102")
	oBrwSA1:Activate()

oVEIC100:Activate()

Return

/*/{Protheus.doc} VC1000011_ClickOpcao
	Chamada da Opção selecionada

	@author Andre Luis Almeida
	@since 12/01/2021
/*/
Function VC1000011_ClickOpcao( nOpcBot )

Local nOpcFil  := 0
Local aAreaVJW := sGetArea(,"VJW")
Local aAreaSA1 := sGetArea(,"SA1")
Local cTitPerg := ""

If nOpcBot >= 51 .and. nOpcBot <= 60

	Do Case 
		Case nOpcBot == 51
			cTitPerg := STR0004 // Dados do Cliente
		Case nOpcBot == 52
			cTitPerg := STR0005 // Prop.Agricolas Individualizadas por Cliente
		Case nOpcBot == 53
			cTitPerg := STR0006 // Prop.Agricolas Agrupadas do Cliente
		Case nOpcBot == 54
			cTitPerg := STR0007 // Frota Individualizada do Cliente
	EndCase
	nOpcFil := AVISO(STR0008,cTitPerg, { STR0009+": "+SA1->A1_LOJA , STR0010 } , 2) // Visualizar Cadastro / Loja / Todas as Lojas

ElseIf nOpcBot >= 71 .and. nOpcBot <= 80

	Do Case 
		Case nOpcBot == 71
			cTitPerg := STR0011 // Analitico por Prop.Agricolas do Cliente
		Case nOpcBot == 72
			cTitPerg := STR0012 // Resumido das Prop.Agricolas do Cliente
		Case nOpcBot == 73
			cTitPerg := STR0013 // Analitico por Frotas do Cliente
		Case nOpcBot == 74
			cTitPerg := STR0014 // Resumido das Frotas do Cliente
	EndCase
	nOpcFil := AVISO(STR0015,cTitPerg, { STR0009+": "+SA1->A1_LOJA , STR0010 } , 2) // Impressao / Loja / Todas as Lojas

EndIf

Do Case

	Case nOpcBot == 01 // Cadastro do Grupo de Negócio
		oExecView := FWViewExec():New()
		oExecView:SetTitle(STR0016) // Cadastro do Grupo de Negócio
		oExecView:SetSource("VEIA210")
		oExecView:SetOperation(MODEL_OPERATION_VIEW)
		oExecView:OpenView(.T.)
	Case nOpcBot == 02 // Dados dos Clientes/Lojas do Grupo de Negócio
		VEIC110( VJW->VJW_CODIGO , "" , "" , "" , "" , "" , "" )
	Case nOpcBot == 03 // Prop.Agricolas Individualizadas por Cliente/Loja do Grupo de Negócio
		VEIA220( .f. , VJW->VJW_CODIGO , "" , "" , "" , "" , "" )
	Case nOpcBot == 04 // Prop.Agricolas Agrupadas dos Clientes/Lojas do Grupo de Negócio
		VEIA220( .t. , VJW->VJW_CODIGO , "" , "" , "" , "" , "" )
	Case nOpcBot == 05 // Frota Individualizada por Cliente/Loja do Grupo de Negócio
		VEIC090( .f. , VJW->VJW_CODIGO , "" , "" , "" , "" , "" )
	Case nOpcBot == 06 // Frotas Agrupadas dos Clientes/Lojas do Grupo de Negócio
		VEIC090( .t. , VJW->VJW_CODIGO , "" , "" , "" , "" , "" )

	Case nOpcBot == 11 // Relatório por Prop.Agricolas dos Clientes/Lojas do Grupo de Negócio
		VEIR000( VJW->VJW_CODIGO , "" , "" , "" , "" , "" , "" )
	Case nOpcBot == 12 // Relatório Resumido das Prop.Agricolas dos Clientes/Lojas do Grupo de Negócio
		VEIR001( VJW->VJW_CODIGO , "" , "" , "" , "" , "" , "" )
	Case nOpcBot == 13 // Relatório por Frotas dos Clientes/Lojas do Grupo de Negócio
		VEIR010( VJW->VJW_CODIGO , "" , "" , "" , "" , "" )
	Case nOpcBot == 14 // Relatório Resumido das Frotas dos Clientes/Lojas do Grupo de Negócio
		VEIR011( VJW->VJW_CODIGO , "" , "" , "" , "" , "" )

	Case nOpcBot == 51 // Dados do Cliente
		If nOpcFil == 1 // Loja Posicionada
			VEIC110( "" , SA1->A1_COD , SA1->A1_LOJA , "" , "" , "" , "" )
		ElseIf nOpcFil == 2 // Todas as Lojas
			VEIC110( "" , SA1->A1_COD , "" , "" , "" , "" , "" )
		EndIf
	Case nOpcBot == 52 // Prop.Agricolas Individualizadas por Cliente
		If nOpcFil == 1 // Loja Posicionada
			VEIA220( .f. , "" , SA1->A1_COD , SA1->A1_LOJA , "", "" , "" )
		ElseIf nOpcFil == 2 // Todas as Lojas
			VEIA220( .f. , "" , SA1->A1_COD , "" , "", "" , "" )
		EndIf
	Case nOpcBot == 53 // Prop.Agricolas Agrupadas do Cliente
		If nOpcFil == 1 // Loja Posicionada
			VEIA220( .t. , "" , SA1->A1_COD , SA1->A1_LOJA , "", "" , "" )
		ElseIf nOpcFil == 2 // Todas as Lojas
			VEIA220( .t. , "" , SA1->A1_COD , "" , "", "" , "" )
		EndIf
	Case nOpcBot == 54 // Frota Individualizada do Cliente
		If nOpcFil == 1 // Loja Posicionada
			VEIC090( .f. , "" , SA1->A1_COD , SA1->A1_LOJA , "", "" , "" )
		ElseIf nOpcFil == 2 // Todas as Lojas
			VEIC090( .f. , "" , SA1->A1_COD , "" , "", "" , "" )
		EndIf

	Case nOpcBot == 61 // Frotas Agrupadas do Cliente
		VEIC090( .t. , "" , SA1->A1_COD , "" , "", "" , "" )

	Case nOpcBot == 71 // Relatório por Prop.Agricolas do Cliente
		If nOpcFil == 1 // Loja Posicionada
			VEIR000( "" , SA1->A1_COD , SA1->A1_LOJA , "" , "" , "" , "" )
		ElseIf nOpcFil == 2 // Todas as Lojas
			VEIR000( "" , SA1->A1_COD , "" , "" , "" , "" , "" )
		EndIf
	Case nOpcBot == 72 // Relatório Resumido das Prop.Agricolas do Cliente
		If nOpcFil == 1 // Loja Posicionada
			VEIR001( "" , SA1->A1_COD , SA1->A1_LOJA , "" , "" , "" , "" )
		ElseIf nOpcFil == 2 // Todas as Lojas
			VEIR001( "" , SA1->A1_COD , "" , "" , "" , "" , "" )
		EndIf
	Case nOpcBot == 73 // Relatório por Frotas do Cliente
		If nOpcFil == 1 // Loja Posicionada
			VEIR010( "" , SA1->A1_COD , SA1->A1_LOJA , "" , "" , "" )
		ElseIf nOpcFil == 2 // Todas as Lojas
			VEIR010( "" , SA1->A1_COD , "" , "" , "" , "" )
		EndIf
	Case nOpcBot == 74 // Relatório Resumido das Frotas do Cliente
		If nOpcFil == 1 // Loja Posicionada
			VEIR011( "" , SA1->A1_COD , SA1->A1_LOJA , "" , "" , "" )
		ElseIf nOpcFil == 2 // Todas as Lojas
			VEIR011( "" , SA1->A1_COD , "" , "" , "" , "" )
		EndIf

EndCase

sRestArea(aAreaVJW)
sRestArea(aAreaSA1)

Return