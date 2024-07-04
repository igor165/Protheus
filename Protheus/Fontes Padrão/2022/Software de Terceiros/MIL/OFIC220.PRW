#include "PROTHEUS.CH"
#INCLUDE "OFIC220.CH"

/*/{Protheus.doc} OFIC220
Consulta - Conferencias de Volume de Entrada

@author Andre
@since 24/08/2021
@version undefined

@type function
/*/
Function OFIC220()

Local oDlgOC220
Local aSize       := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0001 // Consulta - Conferências de Volume de Entrada
Private oBrwVM7

DbSelectArea("VM7")

oDlgOC220 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oBrwVM7:= FWMBrowse():New() 
oBrwVM7:SetOwner(oDlgOC220)
oBrwVM7:SetAlias("VM7")
oBrwVM7:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVM7:DisableLocate()
oBrwVM7:DisableDetails()
oBrwVM7:SetAmbiente(.F.)
oBrwVM7:SetWalkthru(.F.)
oBrwVM7:SetDescription(STR0001) // Consulta - Conferências de Volume de Entrada
oBrwVM7:AddLegend( "VM7_STATUS=='1'" , "BR_BRANCO"   , STR0002 )	// Conferencias Pendentes
oBrwVM7:AddLegend( "VM7_STATUS=='2'" , "BR_AMARELO"  , STR0003 )	// Conferencias Parciais
oBrwVM7:AddLegend( "VM7_STATUS=='3'" , "BR_VERDE"    , STR0004 )	// Conferencias Finalizadas
oBrwVM7:AddLegend( "VM7_STATUS=='4'" , "BR_PRETO"    , STR0005 )	// Conferencias Aprovadas
oBrwVM7:AddLegend( "VM7_STATUS=='5'" , "BR_VERMELHO" , STR0006 )	// Conferencias Reprovadas
oBrwVM7:AddFilter(STR0007,"VM7_DIVERG=='0'",.f.,.f.,) // SEM Divergências
oBrwVM7:AddFilter(STR0008,"VM7_DIVERG=='1'",.f.,.f.,) // COM Divergências
oBrwVM7:SetInsert(.f.)
oBrwVM7:ForceQuitButton(.T.)
oBrwVM7:SetUseFilter()
oBrwVM7:lOptionReport := .f.
oBrwVM7:Activate()

VM7->(DbGoTop())

oDlgOC220:Activate( , , , , , , ) //ativa a janela

Return

/*/{Protheus.doc} OC2200011_VisualizarConferencia
Visualizar Conferencia

@author Andre
@since 24/08/2021
@version undefined

@type function
/*/
Function OC2200011_VisualizarConferencia(cAlias,nReg,nOpc)
Local cSlvCad := cCadastro // Salva cCadastro
cCadastro := STR0009+" - " // Volume de Entrada
Do Case
	Case VM7->VM7_STATUS == "1"
		cCadastro += STR0010 // Conferencia Pendente
	Case VM7->VM7_STATUS == "2"
		cCadastro += STR0011 // Conferido Parcialmente
	Case VM7->VM7_STATUS == "3"
		cCadastro += STR0012 // Conferencia Finalizada
	Case VM7->VM7_STATUS == "4"
		cCadastro += STR0013 // Conferencia Aprovada
	Case VM7->VM7_STATUS == "5"
		cCadastro += STR0014 // Conferencia Reprovada
EndCase
nOpc := 2 // Visualizar
OA3400061_TelaConferencia( VM7->VM7_CODIGO , .t. ) // Visualiza Conferencia
cCadastro := cSlvCad // Volta cCadastro
Return

/*/{Protheus.doc} MenuDef
MenuDef

@author Andre
@since 24/08/2021
@version undefined

@type function
/*/
Static Function MenuDef()
Local aRotina := {}
aAdd(aRotina,{STR0015,"AxPesqui",0,1})	// Pesquisar
aAdd(aRotina,{STR0016,"OC2200011_VisualizarConferencia",0,2})	// Visualizar
aAdd(aRotina,{STR0017,"OFIC120('4')",0,2})	// Eficiencia
Return aRotina