#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "VEIC120.CH"

/*/{Protheus.doc} VEIC120
	Consulta por Regiao, Municipio e UF

	@author Andre Luis Almeida
	@since 22/01/2021
/*/
Function VEIC120()

Local oVEIC120
Local aSize     := FWGetDialogSize( oMainWnd )
Local cTitulo   := STR0001 // Consulta por Regiao, Municipio e UF
Local aColSX5 := {}
Local aColVAM := {}
AAdd(aColSX5,"X5_CHAVE")
AAdd(aColSX5,"X5_DESCRI")
AAdd(aColVAM,"VAM_IBGE")
AAdd(aColVAM,"VAM_DESCID")
AAdd(aColVAM,"VAM_ESTADO")

oVEIC120 := MSDIALOG() :New(aSize[1],aSize[2],aSize[3],aSize[4],cTitulo,,,,128,,,,,.t.)

	oTPanRegiao := TPanel():New(0,0,"",oVEIC120,NIL,.T.,.F.,NIL,NIL,120,(oVEIC120:nClientHeight/4)-10,.F.,.F.)
	oTPanRegiao:Align := CONTROL_ALIGN_TOP

	oTPanMunic := TPanel():New(0,0,"",oVEIC120,NIL,.T.,.F.,NIL,NIL,120,(oVEIC120:nClientHeight/4)-10,.F.,.F.)
	oTPanMunic:Align := CONTROL_ALIGN_BOTTOM 

	oBrwSX5 := FWMBrowse():New()
	oBrwSX5:SetAlias('SX5')
	oBrwSX5:SetOwner(oTPanRegiao)
	oBrwSX5:SetDescription(STR0002) // Regiao
	oBrwSX5:DisableDetails()
	oBrwSX5:SetOnlyFields( aColSX5 )
	oBrwSX5:ForceQuitButton()
	oBrwSX5:SetAmbiente(.F.)
	oBrwSX5:SetWalkthru(.F.)
	oBrwSX5:SetMenuDef("VEIC121")
	oBrwSX5:SetFilterDefault("@ X5_TABELA='A2'")
	oBrwSX5:Activate()

	oBrwVAM := FWMBrowse():New()
	oBrwVAM:SetAlias('VAM')
	oBrwVAM:SetOwner(oTPanMunic)
	oBrwVAM:SetDescription(STR0003) // Municipio UF
	oBrwVAM:SetOnlyFields( aColVAM )
	oBrwVAM:DisableDetails()
	oBrwVAM:lOptionReport := .f.
	oBrwVAM:ForceQuitButton()
	oBrwVAM:SetAmbiente(.F.)
	oBrwVAM:SetWalkthru(.F.)
	oBrwVAM:SetMenuDef("VEIC122")
	oBrwVAM:Activate()

oVEIC120:Activate()

Return

/*/{Protheus.doc} VC1200011_ClickOpcao
	Chamada da Opção selecionada

	@author Andre Luis Almeida
	@since 22/01/2021
/*/
Function VC1200011_ClickOpcao( nOpcBot )

Local nOpcFil  := 0
Local aAreaSX5 := sGetArea(,"SX5")
Local aAreaVAM := sGetArea(,"VAM")
Local cTitPerg := ""

If nOpcBot >= 51 .and. nOpcBot <= 60

	Do Case 
		Case nOpcBot == 51
			cTitPerg := STR0004 // Dados dos Clientes/Lojas
		Case nOpcBot == 52
			cTitPerg := STR0005 // Prop.Agricolas Individualizadas
		Case nOpcBot == 53
			cTitPerg := STR0006 // Prop.Agricolas Agrupadas
		Case nOpcBot == 54
			cTitPerg := STR0007 // Frota Individualizada
		Case nOpcBot == 55
			cTitPerg := STR0008 // Frotas Agrupadas
	EndCase
	nOpcFil := AVISO(STR0009,cTitPerg, { Alltrim(VAM->VAM_DESCID)+" - "+VAM->VAM_ESTADO , STR0010+": "+VAM->VAM_ESTADO } , 2) // Visualizar Cadastro / UF

ElseIf nOpcBot >= 71 .and. nOpcBot <= 80

	Do Case 
		Case nOpcBot == 71
			cTitPerg := STR0011 // Analitico por Prop.Agricolas
		Case nOpcBot == 72
			cTitPerg := STR0012 // Resumido das Prop.Agricolas
		Case nOpcBot == 73
			cTitPerg := STR0013 // Analitico por Frotas
		Case nOpcBot == 74
			cTitPerg := STR0014 // Resumido das Frotas
	EndCase
	nOpcFil := AVISO(STR0015,cTitPerg, { Alltrim(VAM->VAM_DESCID)+" - "+VAM->VAM_ESTADO , STR0010+": "+VAM->VAM_ESTADO } , 2) // Impressao / UF

EndIf

Do Case

	Case nOpcBot == 01 // Dados dos Clientes/Lojas da Regiao
		VEIC110( "" , "" , "" , SX5->X5_CHAVE , "" , "" , "" )
	Case nOpcBot == 02 // Prop.Agricolas Individualizadas por Cliente/Loja da Regiao
		VEIA220( .f. , "" , "" , "" , SX5->X5_CHAVE , "" , "" )
	Case nOpcBot == 03 // Prop.Agricolas Agrupadas dos Clientes/Lojas da Regiao
		VEIA220( .t. , "" , "" , "" , SX5->X5_CHAVE , "" , "" )
	Case nOpcBot == 04 // Frota Individualizada por Cliente/Loja da Regiao
		VEIC090( .f. , "" , "" , "" , SX5->X5_CHAVE , "" , "" )
	Case nOpcBot == 05 // Frotas Agrupadas dos Clientes/Lojas da Regiao
		VEIC090( .t. , "" , "" , "" , SX5->X5_CHAVE , "" , "" )

	Case nOpcBot == 11 // Relatório por Prop.Agricolas dos Clientes/Lojas da Regiao
		VEIR000( "" , "" , "" , SX5->X5_CHAVE , "" , "" , "" )
	Case nOpcBot == 12 // Relatório Resumido das Prop.Agricolas dos Clientes/Lojas da Regiao
		VEIR001( "" , "" , "" , SX5->X5_CHAVE , "" , "" , "" )
	Case nOpcBot == 13 // Relatório por Frotas dos Clientes/Lojas da Regiao
		VEIR010( "" , "" , "" , SX5->X5_CHAVE , "" , "" )
	Case nOpcBot == 14 // Relatório Resumido das Frotas dos Clientes/Lojas da Regiao
		VEIR011( "" , "" , "" , SX5->X5_CHAVE , "" , "" )

	Case nOpcBot == 51 // Dados dos Clientes
		If nOpcFil == 1 // Pelo Municipio
			VEIC110( "" , "" , "" , "" , VAM->VAM_IBGE , "" , "" )
		ElseIf nOpcFil == 2 // Pela UF
			VEIC110( "" , "" , "" , "" , "" , VAM->VAM_ESTADO , "" )
		EndIf
	Case nOpcBot == 52 // Prop.Agricolas Individualizadas
		If nOpcFil == 1 // Pelo Municipio
			VEIA220( .f. , "" , "" , "" , "" , VAM->VAM_IBGE , "" )
		ElseIf nOpcFil == 2 // Pela UF
			VEIA220( .f. , "" , "" , "" , "" , "" , VAM->VAM_ESTADO )
		EndIf
	Case nOpcBot == 53 // Prop.Agricolas Agrupadas
		If nOpcFil == 1 // Pelo Municipio
			VEIA220( .t. , "" , "" , "" , "" , VAM->VAM_IBGE , "" )
		ElseIf nOpcFil == 2 // Pela UF
			VEIA220( .t. , "" , "" , "" , "" , "" , VAM->VAM_ESTADO )
		EndIf
	Case nOpcBot == 54 // Frota Individualizada
		If nOpcFil == 1 // Pelo Municipio
			VEIC090( .f. , "" , "" , "" , "" , VAM->VAM_IBGE , "" )
		ElseIf nOpcFil == 2 // Pela UF
			VEIC090( .f. , "" , "" , "" , "" , "" , VAM->VAM_ESTADO )
		EndIf
	Case nOpcBot == 55 // Frotas Agrupadas
		If nOpcFil == 1 // Pelo Municipio
			VEIC090( .t. , "" , "" , "" , "" , VAM->VAM_IBGE , "" )
		ElseIf nOpcFil == 2 // Pela UF
			VEIC090( .t. , "" , "" , "" , "" , "" , VAM->VAM_ESTADO )
		EndIf

	Case nOpcBot == 71 // Relatório por Prop.Agricolas
		If nOpcFil == 1 // Loja Posicionada
			VEIR000( "" , "" , "" , "" , VAM->VAM_IBGE , "" , "" )
		ElseIf nOpcFil == 2 // Todas as Lojas
			VEIR000( "" , "" , "" , "" , "" , VAM->VAM_ESTADO , "" )
		EndIf
	Case nOpcBot == 72 // Relatório Resumido das Prop.Agricolas
		If nOpcFil == 1 // Pelo Municipio
			VEIR001( "" , "" , "" , "" , VAM->VAM_IBGE , "" , "" )
		ElseIf nOpcFil == 2 // Pela UF
			VEIR001( "" , "" , "" , "" , "" , VAM->VAM_ESTADO , "" )
		EndIf
	Case nOpcBot == 73 // Relatório por Frotas
		If nOpcFil == 1 // Loja Posicionada
			VEIR010( "" , "" , "" , "" , VAM->VAM_IBGE , "" )
		ElseIf nOpcFil == 2 // Todas as Lojas
			VEIR010( "" , "" , "" , "" , "" , VAM->VAM_ESTADO )
		EndIf
	Case nOpcBot == 74 // Relatório Resumido das Frotas
		If nOpcFil == 1 // Pelo Municipio
			VEIR011( "" , "" , "" , "" , VAM->VAM_IBGE , "" )
		ElseIf nOpcFil == 2 // Pela UF
			VEIR011( "" , "" , "" , "" , "" , VAM->VAM_ESTADO )
		EndIf

EndCase

sRestArea(aAreaSX5)
sRestArea(aAreaVAM)

Return