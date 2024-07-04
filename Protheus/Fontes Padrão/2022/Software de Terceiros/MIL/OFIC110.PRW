#include "PROTHEUS.CH"
#INCLUDE "OFIC110.CH"

/*/{Protheus.doc} OFIC110
Consulta - Conferencias de OS - Oficina

@author Andre
@since 12/11/2019
@version undefined

@type function
/*/
Function OFIC110()

Local oDlgOC110
Local aSize       := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0001 // Conferências de OS - Oficina
Private oBrwVM3

DbSelectArea("VM3")

oDlgOC110 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oBrwVM3:= FWMBrowse():New() 
oBrwVM3:SetOwner(oDlgOC110)
oBrwVM3:SetAlias("VM3")
oBrwVM3:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVM3:DisableLocate()
oBrwVM3:DisableDetails()
oBrwVM3:SetAmbiente(.F.)
oBrwVM3:SetWalkthru(.F.)
oBrwVM3:SetDescription(STR0001) // Conferências de OS - Oficina
oBrwVM3:AddLegend( "VM3_STATUS=='1'" , "BR_BRANCO"   , STR0002 )	// Conferencias Pendentes
oBrwVM3:AddLegend( "VM3_STATUS=='2'" , "BR_AMARELO"  , STR0003 )	// Conferencias Parciais
oBrwVM3:AddLegend( "VM3_STATUS=='3'" , "BR_VERDE"    , STR0004 )	// Conferencias Finalizadas
oBrwVM3:AddLegend( "VM3_STATUS=='4'" , "BR_PRETO"    , STR0005 )	// Conferencias Aprovadas
oBrwVM3:AddLegend( "VM3_STATUS=='5'" , "BR_VERMELHO" , STR0006 )	// Conferencias Reprovadas
oBrwVM3:AddFilter(STR0007,"VM3_DIVERG=='0'",.f.,.f.,) // SEM Divergências
oBrwVM3:AddFilter(STR0008,"VM3_DIVERG=='1'",.f.,.f.,) // COM Divergências
oBrwVM3:SetInsert(.f.)
oBrwVM3:ForceQuitButton(.T.)
oBrwVM3:SetUseFilter()
oBrwVM3:lOptionReport := .f.
oBrwVM3:Activate()

VM3->(DbGoTop())

oDlgOC110:Activate( , , , , , , ) //ativa a janela

Return

/*/{Protheus.doc} OC1100011_VisualizarConferencia
Visualizar Conferencia

@author Andre
@since 12/11/2019
@version undefined

@type function
/*/
Function OC1100011_VisualizarConferencia(cAlias,nReg,nOpc)
Local cSlvCad := cCadastro // Salva cCadastro
cCadastro := STR0009+" - " // OS
Do Case
	Case VM3->VM3_STATUS == "1"
		cCadastro += STR0010 // Conferencia Pendente
	Case VM3->VM3_STATUS == "2"
		cCadastro += STR0011 // Conferido Parcialmente
	Case VM3->VM3_STATUS == "3"
		cCadastro += STR0012 // Conferencia Finalizada
	Case VM3->VM3_STATUS == "4"
		cCadastro += STR0013 // Conferencia Aprovada
	Case VM3->VM3_STATUS == "5"
		cCadastro += STR0014 // Conferencia Reprovada
EndCase
nOpc := 2 // Visualizar
OA2120045_TelaConferencia( VM3->VM3_CODIGO , .t. )
cCadastro := cSlvCad // Volta cCadastro
Return

/*/{Protheus.doc} MenuDef
MenuDef

@author Andre
@since 12/11/2019
@version undefined

@type function
/*/
Static Function MenuDef()
Local aRotina := {}
aAdd(aRotina,{STR0015,"AxPesqui"	,0,1})	// Pesquisar
aAdd(aRotina,{STR0016,"OC1100011_VisualizarConferencia",0,2})	// Visualizar
aAdd(aRotina,{STR0017,"OFIC120('2')",0,2})	// Eficiencia
Return aRotina