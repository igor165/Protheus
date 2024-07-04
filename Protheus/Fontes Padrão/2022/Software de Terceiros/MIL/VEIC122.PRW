#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIC120.CH"

/*/{Protheus.doc} VEIC122
	Consulta por Municipios UF

	@author Andre Luis Almeida
	@since 03/02/2021
/*/
Function VEIC122()
Local aColVAM := {}
AAdd(aColVAM,"VAM_IBGE")
AAdd(aColVAM,"VAM_DESCID")
AAdd(aColVAM,"VAM_ESTADO")

oBrwVAM := FWMBrowse():New()
oBrwVAM:SetAlias('VAM')
oBrwVAM:SetDescription(STR0003) // Municipio UF
oBrwVAM:SetOnlyFields( aColVAM )
oBrwVAM:DisableDetails()
oBrwVAM:SetAmbiente(.F.)
oBrwVAM:SetWalkthru(.F.)
oBrwVAM:SetUseFilter()
oBrwVAM:Activate()

Return

Static Function MenuDef()

Local aRotina := {}
Local aAuxCon := {}
Local aAuxRel := {}

aAuxCon := {	{ STR0005, "VC1200011_ClickOpcao(52)" , 0 , 2 },;   // Prop.Agricolas Individualizadas
				{ STR0006, "VC1200011_ClickOpcao(53)" , 0 , 2 },; // Prop.Agricolas Agrupadas
				{ STR0007, "VC1200011_ClickOpcao(54)" , 0 , 2 },; // Frota Individualizada
				{ STR0008, "VC1200011_ClickOpcao(55)" , 0 , 2 }}  // Frotas Agrupadas
aAuxRel := {	{ STR0011, "VC1200011_ClickOpcao(71)" , 0 , 2 },;   // Analitico por Prop.Agricolas
				{ STR0012, "VC1200011_ClickOpcao(72)" , 0 , 2 },; // Resumido das Prop.Agricolas
				{ STR0013, "VC1200011_ClickOpcao(73)" , 0 , 2 },; // Analitico por Frotas
				{ STR0014, "VC1200011_ClickOpcao(74)" , 0 , 2 }}  // Resumido das Frotas
aAdd( aRotina,	{ STR0004, "VC1200011_ClickOpcao(51)", 0 , 2}) // Dados dos Clientes/Lojas
aAdd( aRotina,	{ STR0017,aAuxCon, 0 , 6}) // Consultas
aAdd( aRotina,	{ STR0022,aAuxRel, 0 , 6}) // Relatórios

Return aRotina