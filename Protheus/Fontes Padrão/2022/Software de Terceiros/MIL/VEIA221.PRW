#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA220.CH"

/*/{Protheus.doc} VEIA221
	Chamada da Impressão dos Dados das Propriedades Agricolas

	@author Andre Luis Almeida
	@since 11/01/2021
/*/
Function VEIA221()

oBrwVJX := FWMBrowse():New()
oBrwVJX:SetAlias('VJY')
oBrwVJX:SetDescription(STR0001) // Propriedades Agricolas
oBrwVJX:DisableDetails()
oBrwVJX:SetAmbiente(.F.)
oBrwVJX:SetWalkthru(.F.)
oBrwVJX:SetUseFilter()
oBrwVJX:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0017 ACTION 'VIEWDEF.VEIA220' OPERATION 8 ACCESS 0 // Imprimir Dados das Prop.Agricolas

Return aRotina