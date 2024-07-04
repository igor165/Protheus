#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIC100.CH"

/*/{Protheus.doc} VEIC102
	Consulta por Clientes

	@author Andre Luis Almeida
	@since 03/02/2021
/*/
Function VEIC102()

oBrwSA1 := FWMBrowse():New()
oBrwSA1:SetAlias('SA1')
oBrwSA1:SetDescription(STR0003) // Clientes
oBrwSA1:DisableDetails()
oBrwSA1:SetAmbiente(.F.)
oBrwSA1:SetWalkthru(.F.)
oBrwSA1:SetUseFilter()
oBrwSA1:Activate()

Return

Static Function MenuDef()

Local aRotina := {}
Local aAuxCon := {}
Local aAuxRel := {}

aAuxCon := {	{ STR0005, "VC1000011_ClickOpcao(52)" , 0 , 2 },;   // Prop.Agricolas Individualizadas por Cliente
				{ STR0006, "VC1000011_ClickOpcao(53)" , 0 , 2 },; // Prop.Agricolas Agrupadas do Cliente
				{ STR0007, "VC1000011_ClickOpcao(54)" , 0 , 2 },; // Frota Individualizada do Cliente
				{ STR0029, "VC1000011_ClickOpcao(61)" , 0 , 2 }}  // Frotas Agrupadas do Cliente (todas Lojas)
aAuxRel := {	{ STR0011, "VC1000011_ClickOpcao(71)" , 0 , 2 },;   // Analitico por Prop.Agricolas do Cliente
				{ STR0012, "VC1000011_ClickOpcao(72)" , 0 , 2 },; // Resumido das Prop.Agricolas do Cliente
				{ STR0013, "VC1000011_ClickOpcao(73)" , 0 , 2 },; // Analitico por Frotas do Cliente
				{ STR0014, "VC1000011_ClickOpcao(74)" , 0 , 2 }}  // Resumido das Frotas do Cliente
aAdd( aRotina,	{ STR0004, "VC1000011_ClickOpcao(51)", 0 , 2}) // Dados do Cliente
aAdd( aRotina,	{ STR0019,aAuxCon, 0 , 6}) // Consultas
aAdd( aRotina,	{ STR0024,aAuxRel, 0 , 6}) // Relatórios

Return aRotina