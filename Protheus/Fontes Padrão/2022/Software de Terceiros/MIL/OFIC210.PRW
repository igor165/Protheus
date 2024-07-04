#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIC210.CH"

/*/{Protheus.doc} OFIC210()
Consulta Peças Pendentes da Ordem de Serviço

@author Andre Luis Almeida
@since 25/03/2021
@return NIL
/*/
Function OFIC210()
Local aSizeAut    := MsAdvSize(.f.)
Local cFiltInic   := "" // Filtro Inicial - Relacionar somente OS com VSJ
Private cNamVSJ   := RetSqlName("VSJ") // Utilizado no Filtro do Browse
Private cCadastro := STR0001 // Consulta Peças Pendentes da Ordem de Serviço

cFiltInic := "@ EXISTS ("
cFiltInic += "SELECT VSJ.VSJ_NUMOSV "
cFiltInic += "  FROM "+ RetSqlName("VSJ")+" VSJ "
cFiltInic += " WHERE VSJ.VSJ_FILIAL = VO1_FILIAL "
cFiltInic += "   AND VSJ.VSJ_NUMOSV = VO1_NUMOSV "
cFiltInic += "   AND VSJ.D_E_L_E_T_ = ' ' "
cFiltInic += ")"

oOFIC210 := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],STR0001,,,,128,,,,,.t.) // Consulta Peças Pendentes da Ordem de Serviço

oTPanVO1 := TPanel():New(0,0,"",oOFIC210,NIL,.T.,.F.,NIL,NIL,100,(oOFIC210:nClientHeight/4)-10,.F.,.F.)
oTPanVO1:Align := CONTROL_ALIGN_TOP

oTPanVSJ := TPanel():New(0,0,"",oOFIC210,NIL,.T.,.F.,NIL,NIL,100,(oOFIC210:nClientHeight/4)-10,.F.,.F.)
oTPanVSJ:Align := CONTROL_ALIGN_BOTTOM 

oBrwVO1 := FWMBrowse():New()
oBrwVO1:SetAlias("VO1")
oBrwVO1:SetOwner(oTPanVO1)
oBrwVO1:SetDescription(STR0002) // Ordens de Serviços com Status Em Aberto
oBrwVO1:AddFilter(STR0003,cFiltInic,.f.,.t.,) // Ordens de Serviço com Peças digitadas
oBrwVO1:AddLegend( "OC2100011_CorLegenda()='1'"  , "BR_VERDE"     , STR0005 ) // Todas as peças da OS disponíveis para requisição
oBrwVO1:AddLegend( "OC2100011_CorLegenda()='2'"  , "BR_AMARELO"   , STR0006 ) // Uma ou mais peças da OS disponíveis para requisição
oBrwVO1:AddLegend( "OC2100011_CorLegenda()='3'"  , "BR_VERMELHO"  , STR0007 ) // Nenhuma peça da OS disponível para requisição
oBrwVO1:AddLegend( "OC2100011_CorLegenda()='0'"  , "BR_BRANCO"    , STR0004 ) // Ordens de Serviço sem Peças digitadas
oBrwVO1:SetFilterDefault( "@ VO1_STATUS='A'" ) // Ordens de Serviços com Status Em Aberto
oBrwVO1:ForceQuitButton(.T.)
oBrwVO1:DisableDetails()
oBrwVO1:Activate()
oBrwVO1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oBrwVSJ := FWMBrowse():New()
oBrwVSJ:SetAlias("VSJ")
oBrwVSJ:SetOwner(oTPanVSJ)
oBrwVSJ:SetDescription(STR0008) // Peças digitadas na Ordem de Serviço
oBrwVSJ:SetMenuDef('OFIC211')
oBrwVSJ:AddLegend( "VSJ_QTDREQ = 0"                      , "BR_VERDE"    , STR0009 ) // Todas as quantidades desta peça disponíveis para requisição
oBrwVSJ:AddLegend( "VSJ_QTDREQ > 0 .AND. VSJ_QTDITE > 0" , "BR_AMARELO"  , STR0010 ) // Uma ou mais quantidades desta peça disponíveis para requisição
oBrwVSJ:AddLegend( "VSJ_QTDREQ > 0 .AND. VSJ_QTDITE = 0" , "BR_VERMELHO" , STR0011 ) // Nenhuma quantidade desta peça disponível para requisição
oBrwVSJ:ForceQuitButton(.T.)
oBrwVSJ:DisableDetails()
oBrwVSJ:Activate()
oBrwVSJ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oRelac:= FWBrwRelation():New()
oRelac:AddRelation( oBrwVO1 , oBrwVSJ , { { "VSJ_FILIAL" , "VO1_FILIAL" } , { "VSJ_NUMOSV" , "VO1_NUMOSV" } } )
oRelac:Activate()

oOFIC210:Activate()

Return NIL

/*/{Protheus.doc} OC2100011_CorLegenda
Cor Legenda Browse do VO1

@author Andre
@since 25/03/2021
@type function
/*/
Function OC2100011_CorLegenda()
Local cRet := "0" // Ordens de Serviço sem Peças digitadas
Local cAliasVSJ := "SQLVSJ"
Local cQuery    := ""
cQuery := "SELECT SUM(VSJ_QTDREQ) AS QTDREQ , SUM(VSJ_QTDITE) AS QTDITE FROM "+cNamVSJ
cQuery += " WHERE VSJ_FILIAL='"+VO1->VO1_FILIAL+"' AND VSJ_NUMOSV='"+VO1->VO1_NUMOSV+"' AND D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVSJ , .T., .T. )
If !( cAliasVSJ )->( Eof() ) .and. ( ( cAliasVSJ )->( QTDREQ )+( cAliasVSJ )->( QTDITE ) > 0 )
	If ( cAliasVSJ )->( QTDREQ ) == 0
		cRet := "1" // Todas as peças da OS disponíveis para requisição
	Else
		If ( cAliasVSJ )->( QTDITE ) > 0
			cRet := "2" // Uma ou mais peças da OS disponíveis para requisição
		Else
			cRet := "3" // Nenhuma peça da OS disponível para requisição
		EndIf
	EndIf
EndIf
( cAliasVSJ )->(dbCloseArea())
DbSelectArea("VO1")
Return cRet

/*/{Protheus.doc} OC2100021_Visualizar
Visualizar VO1 ( Consulta da OS )

@author Andre
@since 25/03/2021
@type function
/*/
Function OC2100021_Visualizar()
Private nOpc := 2 // variavel necessaria no OFIOC060
	OFIOC060(.t.)
Return

/*/{Protheus.doc} MenuDef
MenuDef - montagem do aRotina no Browse do VO1

@author Andre
@since 25/03/2021
@type static function
/*/
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0012 ACTION 'OC2100021_Visualizar()' OPERATION 2 ACCESS 0 // Visualizar OS
Return aRotina