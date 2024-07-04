#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE "TMSAD10.Ch"

//===========================================================================================================
/* Cadastro de Documentos Exigidos
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Function TMSAD10()

Local oMBrowse 		:= Nil

Private aRotina   := MenuDef()

oMBrowse:= FWMBrowse():New()	
oMBrowse:SetAlias( "DD0" )
oMBrowse:SetDescription( STR0001 )
oMBrowse:Activate()

Return()

//===========================================================================================================
/* ModelDef 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Static Function ModelDef()

Local oModel 	:= NIL
Local oStruDD0 	:= Nil
Local bPosValid	:= { |oMdl| PosVldMdl(oMdl) }

oStruDD0 := FwFormStruct( 1, "DD0" ) 

oModel := MPFormModel():New ( "TMSAD10",/*bPreValid*/, bPosValid,, /*bCancel*/ )

oModel:SetDescription(STR0001)

oModel:AddFields( 'MdFieldDD0',	, oStruDD0, /*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/,/* bLoad*/)	

oModel:GetModel ( 'MdFieldDD0' )
oModel:SetPrimaryKey( { "DD0_FILIAL","DD0_CODDOC" } )

Return( oModel )

//===========================================================================================================
/* ViewDef 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Static Function ViewDef()

Local oView 	:= NIL
Local oModel   	:= NIL 
Local oStruDD0 	:= Nil

oModel   := FwLoadModel( "TMSAD10" )
oStruDD0 := FwFormStruct( 2, "DD0" ) 

oView := FwFormView():New()
oView:SetModel(oModel)	

oView:AddField( 'VwFieldDD0', oStruDD0 , 'MdFieldDD0' )

oView:CreateHorizontalBox( 'TOPO'   , 100 )

oView:SetOwnerView( 'VwFieldDD0' , 'TOPO' )

Return( oView )

//===========================================================================================================
/* MenuDef.
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	aRotina - Array com as opçoes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()
Local aArea		:= GetArea() 

Private	aRotina	:= {}

aAdd( aRotina, { STR0002	, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0003	, "VIEWDEF.TMSAD10"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0004	, "VIEWDEF.TMSAD10"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0005	, "VIEWDEF.TMSAD10"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0006	, "VIEWDEF.TMSAD10"  , 0, 5, 3, Nil } ) // Excluir	

RestArea( aArea )

Return(aRotina)

//===========================================================================================================
/* PosVldMdl 
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Static Function PosVldMdl(oModel)
Local lRet		:= .T.

Default oModel    := FwModelActive()

If oModel:GetOperation() == MODEL_OPERATION_DELETE
	lRet := VldExcl()
EndIf

Return( lRet )

//===========================================================================================================
/* VldExcl - Valida a exclusão dos registros
@author  	Jefferson Tomaz
@version 	P12 R12.1.30
@since 		18/05/2020
@return 	*/
//===========================================================================================================
Static Function VldExcl()

Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := ""

If DD0->DD0_OBRIGA == "1" .Or. DD0->DD0_OBRIGA == "3" //Documento de Fornecedor ou Ambos
	cAliasQry  := GetNextAlias()
	cQuery := "SELECT COUNT(*) NTOTAL "
	cQuery += "FROM " + RetSQLName('DD3') + " DD3 "
	cQuery += "WHERE DD3.DD3_FILIAL = '" + xFilial('DD3') + "' "
	cQuery += " AND DD3.DD3_CODDOC = '" + DD0->DD0_CODDOC + "' "
	cQuery += " AND DD3.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

	If (cAliasQry)->NTOTAL > 0
		Help("",1,"TMSAD1002") //--"Nao e permitido excluir um documento ja relacionado a um Fornecedor"
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
EndIf

If lRet
	If DD0->DD0_OBRIGA == "2" .Or. DD0->DD0_OBRIGA == "3" //Documento de Motorista ou Ambos
		cAliasQry  := GetNextAlias()
		cQuery := "SELECT COUNT(*) NTOTAL "
		cQuery += "FROM " + RetSQLName('DD4') + " DD4 "
		cQuery += "WHERE DD4.DD4_FILIAL = '" + xFilial('DD4') + "' "
		cQuery += " AND DD4.DD4_CODDOC = '" + DD0->DD0_CODDOC + "' "
		cQuery += " AND DD4.D_E_L_E_T_ = ' '"
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	
		If (cAliasQry)->NTOTAL > 0
			Help("",1,"TMSAD1003") //--"Nao e permitido excluir um documento ja relacionado a um Motorista"
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
EndIf

If lRet 
	cAliasQry  := GetNextAlias()
	cQuery := "SELECT COUNT(*) NTOTAL "
	cQuery += "FROM " + RetSQLName('DJ0') + " DJ0 "
	cQuery += "WHERE DJ0.DJ0_FILIAL = '" + xFilial('DJ0') + "' "
	cQuery += " AND DJ0.DJ0_CODDOC = '" + DD0->DD0_CODDOC + "' "
	cQuery += " AND DJ0.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	
	If (cAliasQry)->NTOTAL > 0
		Help("",1,"TMSAD1004") //--"Nao e permitido excluir um documento ja relacionado a uma Caracteristica de RRE"
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAD10Fil ³ Autor ³ Vitor Raspa          ³ Data ³ 11.Set.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtro na Consulta Padrao DD0 (SXB)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAD20Fil()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAD10Fil()
Local lRet := .T.

If AllTrim(FunName()) == 'TMSAD20' //-- Manut. Doctos. Exigidos X Fornecedores
	If !Empty(M->DD1_PESSOA)	
		If DD0->DD0_PESSOA == M->DD1_PESSOA .Or. DD0->DD0_PESSOA == 'N'
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. ( DD0->DD0_OBRIGA == '1' .Or. DD0->DD0_OBRIGA == '3' )
		lRet := .T.
	Else
		lRet := .F.
	EndIf

ElseIf AllTrim(FunName()) == 'TMSAD30' //-- Manut. Doctos. Exigidos X Motoristas
	If DD0->DD0_OBRIGA == '2' .Or. DD0->DD0_OBRIGA == '3'
		lRet := .T.
	Else
		lRet := .F.
	EndIf	

EndIf
	
Return(lRet)