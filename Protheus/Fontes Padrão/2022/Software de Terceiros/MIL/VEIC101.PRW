#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIC100.CH"

/*/{Protheus.doc} VEIC101
	Consulta por Grupo de Negocios

	@author Andre Luis Almeida
	@since 03/02/2021
/*/
Function VEIC101()

oBrwVJW := FWMBrowse():New()
oBrwVJW:SetAlias('VJW')
oBrwVJW:SetDescription(STR0002) // Grupo de Negócios
oBrwVJW:DisableDetails()
oBrwVJW:SetAmbiente(.F.)
oBrwVJW:SetWalkthru(.F.)
oBrwVJW:SetUseFilter()
oBrwVJW:Activate()

Return

Static Function MenuDef()

Local aRotina := {}
Local aAuxCon := {}
Local aAuxRel := {}

aAuxCon := {	{ STR0020, "VC1000011_ClickOpcao(03)" , 0 , 2 },;   // Prop.Agricolas Individualizadas por Cliente/Loja do Grupo de Negócios
				{ STR0021, "VC1000011_ClickOpcao(04)" , 0 , 2 },; // Prop.Agricolas Agrupadas dos Clientes/Lojas do Grupo de Negócios
				{ STR0022, "VC1000011_ClickOpcao(05)" , 0 , 2 },; // Frota Individualizada por Cliente/Loja do Grupo de Negócios
				{ STR0023, "VC1000011_ClickOpcao(06)" , 0 , 2 }}  // Frotas Agrupadas dos Clientes/Lojas do Grupo de Negócios
aAuxRel := {	{ STR0025, "VC1000011_ClickOpcao(11)" , 0 , 2 },;   // Analitico por Prop.Agricolas dos Clientes/Lojas do Grupo de Negócios
				{ STR0026, "VC1000011_ClickOpcao(12)" , 0 , 2 },; // Resumido das Prop.Agricolas dos Clientes/Lojas do Grupo de Negócios
				{ STR0027, "VC1000011_ClickOpcao(13)" , 0 , 2 },; // Analitico por Frotas dos Clientes/Lojas do Grupo de Negócios
				{ STR0028, "VC1000011_ClickOpcao(14)" , 0 , 2 }}  // Resumido das Frotas dos Clientes/Lojas do Grupo de Negócios
aAdd( aRotina,	{ STR0017, "VC1000011_ClickOpcao(01)", 0 , 2}) // Dados do Grupo de Negócios
aAdd( aRotina,	{ STR0018, "VC1000011_ClickOpcao(02)", 0 , 2}) // Dados dos Clientes/Lojas do Grupo de Negócios
aAdd( aRotina,	{ STR0019,aAuxCon, 0 , 6}) // Consultas
aAdd( aRotina,	{ STR0024,aAuxRel, 0 , 6}) // Relatórios

Return aRotina