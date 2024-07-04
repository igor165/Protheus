#include "PROTHEUS.CH"
#INCLUDE "OFIC100.CH"

/*/{Protheus.doc} OFIC100
Consulta - Conferencias de Entrada

@author Andre
@since 15/10/2019
@version undefined

@type function
/*/
Function OFIC100()

Local oDlgOC100
Local aSize       := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0001 // Consulta - Conferências de Nota Fiscal de Entrada
Private oBrwVM0

DbSelectArea("VM0")

oDlgOC100 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oBrwVM0:= FWMBrowse():New() 
oBrwVM0:SetOwner(oDlgOC100)
oBrwVM0:SetAlias("VM0")
oBrwVM0:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVM0:DisableLocate()
oBrwVM0:DisableDetails()
oBrwVM0:SetAmbiente(.F.)
oBrwVM0:SetWalkthru(.F.)
oBrwVM0:SetDescription(STR0001) // Consulta - Conferências de Nota Fiscal de Entrada
oBrwVM0:AddLegend( "VM0_STATUS=='1'" , "BR_BRANCO"   , STR0002 )	// Conferencias Pendentes
oBrwVM0:AddLegend( "VM0_STATUS=='2'" , "BR_AMARELO"  , STR0003 )	// Conferencias Parciais
oBrwVM0:AddLegend( "VM0_STATUS=='3'" , "BR_VERDE"    , STR0004 )	// Conferencias Finalizadas
oBrwVM0:AddLegend( "VM0_STATUS=='4'" , "BR_PRETO"    , STR0005 )	// Conferencias Aprovadas
oBrwVM0:AddLegend( "VM0_STATUS=='5'" , "BR_VERMELHO" , STR0006 )	// Conferencias Reprovadas
oBrwVM0:AddFilter(STR0014,"VM0_DIVERG=='0'",.f.,.f.,) // SEM Divergências
oBrwVM0:AddFilter(STR0015,"VM0_DIVERG=='1'",.f.,.f.,) // COM Divergências
oBrwVM0:SetInsert(.f.)
oBrwVM0:ForceQuitButton(.T.)
oBrwVM0:SetUseFilter()
oBrwVM0:lOptionReport := .f.
oBrwVM0:Activate()

VM0->(DbGoTop())

oDlgOC100:Activate( , , , , , , ) //ativa a janela

Return

/*/{Protheus.doc} OC1000011_VisualizarConferencia
Visualizar Conferencia

@author Andre
@since 15/10/2019
@version undefined

@type function
/*/
Function OC1000011_VisualizarConferencia(cAlias,nReg,nOpc)
Local cSlvCad := cCadastro // Salva cCadastro
cCadastro := STR0017+" - " // NF Entrada
Do Case
	Case VM0->VM0_STATUS == "1"
		cCadastro += STR0007 // Conferencia Pendente
	Case VM0->VM0_STATUS == "2"
		cCadastro += STR0008 // Conferido Parcialmente
	Case VM0->VM0_STATUS == "3"
		cCadastro += STR0009 // Conferencia Finalizada
	Case VM0->VM0_STATUS == "4"
		cCadastro += STR0010 // Conferencia Aprovada
	Case VM0->VM0_STATUS == "5"
		cCadastro += STR0011 // Conferencia Reprovada
EndCase
nOpc := 2 // Visualizar
OM3900065_TelaConferencia( VM0->VM0_CODIGO , .t. ) // Visualiza Conferencia
cCadastro := cSlvCad // Volta cCadastro
Return

/*/{Protheus.doc} MenuDef
MenuDef

@author Andre
@since 15/10/2019
@version undefined

@type function
/*/
Static Function MenuDef()
Local aRotina := {}
aAdd(aRotina,{STR0012,"AxPesqui",0,1})	// Pesquisar
aAdd(aRotina,{STR0013,"OC1000011_VisualizarConferencia",0,2})	// Visualizar
aAdd(aRotina,{STR0016,"OFIC120('1')",0,2})	// Eficiencia
Return aRotina