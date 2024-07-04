#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIC120.CH"

/*/{Protheus.doc} VEIC121
	Consulta por Região

	@author Andre Luis Almeida
	@since 03/02/2021
/*/
Function VEIC121()
Local aColSX5 := {}
AAdd(aColSX5,"X5_CHAVE")
AAdd(aColSX5,"X5_DESCRI")

oBrwSX5 := FWMBrowse():New()
oBrwSX5:SetAlias('SX5')
oBrwSX5:SetDescription(STR0002) // Regiao
oBrwSX5:SetOnlyFields( aColSX5 )
oBrwSX5:DisableDetails()
oBrwSX5:SetAmbiente(.F.)
oBrwSX5:SetWalkthru(.F.)
oBrwSX5:SetFilterDefault("@ X5_TABELA='A2'")
oBrwSX5:SetUseFilter()
oBrwSX5:Activate()

Return

Static Function MenuDef()

Local aRotina := {}
Local aAuxCon := {}
Local aAuxRel := {}

aAuxCon := {	{ STR0018, "VC1200011_ClickOpcao(02)" , 0 , 2 },;   // Prop.Agricolas Individualizadas por Cliente/Loja da Região
				{ STR0019, "VC1200011_ClickOpcao(03)" , 0 , 2 },; // Prop.Agricolas Agrupadas dos Clientes/Lojas da Região
				{ STR0020, "VC1200011_ClickOpcao(04)" , 0 , 2 },; // Frota Individualizada por Cliente/Loja da Região
				{ STR0021, "VC1200011_ClickOpcao(05)" , 0 , 2 }}  // Frotas Agrupadas dos Clientes/Lojas da Região
aAuxRel := {	{ STR0023, "VC1200011_ClickOpcao(11)" , 0 , 2 },;   // Analitico por Prop.Agricolas dos Clientes/Lojas da Região
				{ STR0024, "VC1200011_ClickOpcao(12)" , 0 , 2 },; // Resumido das Prop.Agricolas dos Clientes/Lojas da Região
				{ STR0025, "VC1200011_ClickOpcao(13)" , 0 , 2 },; // Analitico por Frotas dos Clientes/Lojas da Região
				{ STR0026, "VC1200011_ClickOpcao(14)" , 0 , 2 }}  // Resumido das Frotas dos Clientes/Lojas da Região
aAdd( aRotina,	{ STR0016, "VC1200011_ClickOpcao(01)", 0 , 2}) // Dados dos Clientes/Lojas da Região
aAdd( aRotina,	{ STR0017,aAuxCon, 0 , 6}) // Consultas
aAdd( aRotina,	{ STR0022,aAuxRel, 0 , 6}) // Relatórios

Return aRotina