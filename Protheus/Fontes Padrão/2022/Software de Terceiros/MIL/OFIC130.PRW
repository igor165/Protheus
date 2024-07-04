#include "PROTHEUS.CH"
#INCLUDE "OFIC130.CH"

/*/{Protheus.doc} OFIC130
Consulta - Conferencias de Orçamento

@author Andre
@since 20/11/2019
@version undefined

@type function
/*/
Function OFIC130()

Local oDlgOC130
Local aSize       := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0001 // Conferências de Orçamento
Private oBrwVM5

DbSelectArea("VM5")

oDlgOC130 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oBrwVM5:= FWMBrowse():New() 
oBrwVM5:SetOwner(oDlgOC130)
oBrwVM5:SetAlias("VM5")
oBrwVM5:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVM5:DisableLocate()
oBrwVM5:DisableDetails()
oBrwVM5:SetAmbiente(.F.)
oBrwVM5:SetWalkthru(.F.)
oBrwVM5:SetDescription(STR0001) // Conferências de Orçamento
oBrwVM5:AddLegend( "VM5_STATUS=='1'" , "BR_BRANCO"   , STR0002 ) // Conferencias Pendentes
oBrwVM5:AddLegend( "VM5_STATUS=='2'" , "BR_AMARELO"  , STR0003 ) // Conferencias Parciais
oBrwVM5:AddLegend( "VM5_STATUS=='3'" , "BR_VERDE"    , STR0004 ) // Conferencias Finalizadas
oBrwVM5:AddLegend( "VM5_STATUS=='4'" , "BR_PRETO"    , STR0005 ) // Conferencias Aprovadas
oBrwVM5:AddLegend( "VM5_STATUS=='5'" , "BR_VERMELHO" , STR0006 ) // Conferencias Reprovadas
oBrwVM5:AddFilter(STR0007,"VM5_DIVERG=='0'",.f.,.f.,) // SEM Divergências
oBrwVM5:AddFilter(STR0008,"VM5_DIVERG=='1'",.f.,.f.,) // COM Divergências
oBrwVM5:SetInsert(.f.)
oBrwVM5:ForceQuitButton(.T.)
oBrwVM5:SetUseFilter()
oBrwVM5:lOptionReport := .f.
oBrwVM5:Activate()

VM5->(DbGoTop())

oDlgOC130:Activate( , , , , , , ) //ativa a janela

Return

/*/{Protheus.doc} OC1300011_VisualizarConferencia
Visualizar Conferencia

@author Andre
@since 20/11/2019
@version undefined

@type function
/*/
Function OC1300011_VisualizarConferencia(cAlias,nReg,nOpc)
Local cSlvCad := cCadastro // Salva cCadastro
cCadastro := STR0009+" - " // Orçamento
Do Case
	Case VM5->VM5_STATUS == "1"
		cCadastro += STR0010 // Conferencia Pendente
	Case VM5->VM5_STATUS == "2"
		cCadastro += STR0011 // Conferido Parcialmente
	Case VM5->VM5_STATUS == "3"
		cCadastro += STR0012 // Conferencia Finalizada
	Case VM5->VM5_STATUS == "4"
		cCadastro += STR0013 // Conferencia Aprovada
	Case VM5->VM5_STATUS == "5"
		cCadastro += STR0014 // Conferencia Reprovada
EndCase
nOpc := 2 // Visualizar
OX0020011_TelaConferencia( VM5->VM5_CODIGO , .t. )
cCadastro := cSlvCad // Volta cCadastro
Return

/*/{Protheus.doc} MenuDef
MenuDef

@author Andre
@since 20/11/2019
@version undefined

@type function
/*/
Static Function MenuDef()
Local aRotina := {}
aAdd(aRotina,{STR0015,"AxPesqui"	,0,1})	// Pesquisar
aAdd(aRotina,{STR0016,"OC1300011_VisualizarConferencia",0,2})	// Visualizar
aAdd(aRotina,{STR0017,"OFIC120('3')",0,2})	// Eficiencia
Return aRotina