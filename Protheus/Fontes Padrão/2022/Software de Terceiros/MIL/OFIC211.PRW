#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIC211.CH"

/*/{Protheus.doc} OFIC211()
Consulta Peças Digitadas em Ordens de Serviço

@author Andre Luis Almeida
@since 25/03/2021
@return NIL
/*/
Function OFIC211()

Local cFiltro     := ""
Private cCadastro := STR0001 // Peças Digitadas em Ordens de Serviço com Status Em Aberto

cFiltro := "@ EXISTS ( "
cFiltro += "SELECT VO1.VO1_NUMOSV "
cFiltro += "  FROM "+ RetSqlName("VO1")+" VO1 "
cFiltro += " WHERE VO1.VO1_FILIAL = VSJ_FILIAL "
cFiltro += "   AND VO1.VO1_NUMOSV = VSJ_NUMOSV "
cFiltro += "   AND VO1.VO1_STATUS = 'A' "
cFiltro += "   AND VO1.D_E_L_E_T_ = ' ' "
cFiltro += ")"

oBrwVSJ := FWMBrowse():New()
oBrwVSJ:SetAlias("VSJ")
oBrwVSJ:SetDescription(STR0001) // Peças Digitadas em Ordens de Serviço com Status Em Aberto
oBrwVSJ:AddLegend( "VSJ_QTDREQ = 0"                      , "BR_VERDE"    , STR0002 ) // Todas as quantidades desta peça disponíveis para requisição
oBrwVSJ:AddLegend( "VSJ_QTDREQ > 0 .AND. VSJ_QTDITE > 0" , "BR_AMARELO"  , STR0003 ) // Uma ou mais quantidades desta peça disponíveis para requisição
oBrwVSJ:AddLegend( "VSJ_QTDREQ > 0 .AND. VSJ_QTDITE = 0" , "BR_VERMELHO" , STR0004 ) // Nenhuma quantidade desta peça disponível para requisição
oBrwVSJ:SetFilterDefault( cFiltro )
oBrwVSJ:ForceQuitButton(.T.)
oBrwVSJ:DisableDetails()
oBrwVSJ:Activate()

Return NIL

/*/{Protheus.doc} OC2110011_Visualizar
Visualizar VSJ posicionado

@author Andre
@since 25/03/2021
@type function
/*/
Function OC2110011_Visualizar()
	AxVisual("VSJ",VSJ->(RecNo()),2,)
Return

/*/{Protheus.doc} MenuDef
MenuDef - montagem do aRotina no Browse do VSJ

@author Andre
@since 25/03/2021
@type static function
/*/
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0005 ACTION 'OC2110011_Visualizar()' OPERATION 2 ACCESS 0 // Visualizar
Return aRotina