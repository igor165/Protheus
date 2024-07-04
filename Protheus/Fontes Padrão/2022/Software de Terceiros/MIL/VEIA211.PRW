#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA211.CH"

/*/{Protheus.doc} VEIA211
	Chamadas das Consultas por Cliente

	@author Andre Luis Almeida
	@since 11/01/2021
/*/
Function VEIA211()

oBrwVJX := FWMBrowse():New()
oBrwVJX:SetAlias('VJX')
oBrwVJX:SetDescription(STR0001) // Clientes
oBrwVJX:DisableDetails()
oBrwVJX:SetAmbiente(.F.)
oBrwVJX:SetWalkthru(.F.)
oBrwVJX:SetUseFilter()
oBrwVJX:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'VEIC110( "" , VJX->VJX_CODCLI , VJX->VJX_LOJCLI , "" , "" , "" , "" )'		OPERATION 2 ACCESS 0 // Dados do Cliente/Loja
	ADD OPTION aRotina TITLE STR0003 ACTION 'VEIC110( "" , VJX->VJX_CODCLI , "" , "" , "" , "" , "" )'					OPERATION 2 ACCESS 0 // Dados do Cliente (todas Lojas)
	ADD OPTION aRotina TITLE STR0004 ACTION 'VEIA220( .f. , "" , VJX->VJX_CODCLI , VJX->VJX_LOJCLI , "" , "" , "" )'	OPERATION 2 ACCESS 0 // Prop.Agricolas Individualizadas por Cliente/Loja
	ADD OPTION aRotina TITLE STR0005 ACTION 'VEIA220( .f. , "" , VJX->VJX_CODCLI , "" , "" , "" , "" )'					OPERATION 2 ACCESS 0 // Prop.Agricolas Individualizadas por Cliente (todas Lojas)
	ADD OPTION aRotina TITLE STR0006 ACTION 'VEIA220( .t. , "" , VJX->VJX_CODCLI , VJX->VJX_LOJCLI , "" , "" , "" )'	OPERATION 2 ACCESS 0 // Prop.Agricolas Agrupadas do Cliente/Loja
	ADD OPTION aRotina TITLE STR0007 ACTION 'VEIA220( .t. , "" , VJX->VJX_CODCLI , "" , "" , "" , "" )'					OPERATION 2 ACCESS 0 // Prop.Agricolas Agrupadas do Cliente (todas Lojas)
	ADD OPTION aRotina TITLE STR0008 ACTION 'VEIC090( .f. , "" , VJX->VJX_CODCLI , VJX->VJX_LOJCLI , "" , "" , "" )'	OPERATION 2 ACCESS 0 // Frota do Cliente/Loja
	ADD OPTION aRotina TITLE STR0009 ACTION 'VEIC090( .f. , "" , VJX->VJX_CODCLI , "" , "" , "" , "" )'					OPERATION 2 ACCESS 0 // Frotas Individualizadas por Cliente (todas Lojas)
	ADD OPTION aRotina TITLE STR0010 ACTION 'VEIC090( .t. , "" , VJX->VJX_CODCLI , "" , "" , "" , "" )'					OPERATION 2 ACCESS 0 // Consulta Frotas Agrupadas do Cliente (todas Lojas)
	ADD OPTION aRotina TITLE STR0011 ACTION 'VEIR000( "" , VJX->VJX_CODCLI , VJX->VJX_LOJCLI , "" , "" , "" , "" )'		OPERATION 8 ACCESS 0 // Relatório por Prop.Agricolas do Cliente/Loja
	ADD OPTION aRotina TITLE STR0012 ACTION 'VEIR000( "" , VJX->VJX_CODCLI , "" , "" , "" , "" , "" )'					OPERATION 8 ACCESS 0 // Relatório por Prop.Agricolas do Cliente (todas Lojas)
	ADD OPTION aRotina TITLE STR0013 ACTION 'VEIR001( "" , VJX->VJX_CODCLI , VJX->VJX_LOJCLI , "" , "" , "" , "" )'		OPERATION 8 ACCESS 0 // Relatório Resumido das Prop.Agricolas do Cliente/Loja
	ADD OPTION aRotina TITLE STR0014 ACTION 'VEIR001( "" , VJX->VJX_CODCLI , "" , "" , "" , "" , "" )'					OPERATION 8 ACCESS 0 // Relatório Resumido das Prop.Agricolas do Cliente (todas Lojas)
	ADD OPTION aRotina TITLE STR0015 ACTION 'VEIR010( "" , VJX->VJX_CODCLI , VJX->VJX_LOJCLI , "" , "" , "" )'			OPERATION 8 ACCESS 0 // Relatório por Frotas do Cliente/Loja
	ADD OPTION aRotina TITLE STR0016 ACTION 'VEIR010( "" , VJX->VJX_CODCLI , "" , "" , "" , "" )'						OPERATION 8 ACCESS 0 // Relatório por Frotas do Cliente (todas Lojas)
	ADD OPTION aRotina TITLE STR0017 ACTION 'VEIR011( "" , VJX->VJX_CODCLI , VJX->VJX_LOJCLI , "" , "" , "" )'			OPERATION 8 ACCESS 0 // Relatório Resumido das Frotas do Cliente/Loja
	ADD OPTION aRotina TITLE STR0018 ACTION 'VEIR011( "" , VJX->VJX_CODCLI , "" , "" , "" , "" )'						OPERATION 8 ACCESS 0 // Relatório Resumido das Frotas do Cliente (todas Lojas)

Return aRotina