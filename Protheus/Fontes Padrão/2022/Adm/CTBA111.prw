#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CTBA111.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA111
Montagem da modelo e interface

@author Thiago Murakami
@since 12/06/2015
@version 12.1.6
/*/
//--------------------------------------------------------------------
Function CTBA111()
Local oBrowse
Local lRet 		:= .T.

If lRet
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'CQJ' )
	oBrowse:SetDescription( STR0006 ) //Cadastro de Eventos
	oBrowse:Activate()
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição de Menu da Rotina de Importação regra de rateio

@author Thiago Murakami
@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0001	Action 'PesqBrw'        	OPERATION 1 ACCESS 0 //Pesquisar
ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.CTBA111'	OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.CTBA111'	OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina Title STR0004	Action 'VIEWDEF.CTBA111'	OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina Title STR0005	Action 'VIEWDEF.CTBA111'	OPERATION 5 ACCESS 0 //Excluir

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados da rotina Importação regra de rateio

@author Thiago Murakami
@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------

Static Function ModelDef
Local oStruCQJ := FWFormStruct( 1, 'CQJ', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruCQK := FWFormStruct( 1, 'CQK', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

oModel := MPFormModel():New( 'CTBA111' , /*bPreValidacao*/,/*bPosValidacao*/,{ |oModel| CTB111GRV( oModel ) }/*Commit*/,/*bCancel*/,/*bLoad*/ )

oModel:AddFields( 'CQJMASTER', /*cOwner*/, oStruCQJ ,/*bPreVld*/, /*bPost*/ ,) 
oModel:AddGrid( 'CQKDETAIL', 'CQJMASTER', oStruCQK, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,/*bLoad*/)

oModel:SetRelation( 'CQKDETAIL', { { 'CQK_FILIAL', 'xFilial( "CQK" )' }, { 'CQK_CODEVE' , 'CQJ_CODEVE'  } },)

oModel:SetDescription( STR0006 ) //Cadastro de Evento

oModel:GetModel( 'CQJMASTER' ):SetDescription( STR0006 )//Cadastro de Eventos
oModel:GetModel( 'CQKDETAIL' ):SetDescription( STR0009 ) //Item do Rateio

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface da rotina de Importação regra de rateio

@author Thiago.Murakami
@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruCQJ := FWFormStruct( 2, 'CQJ' )
Local oStruCQK := FWFormStruct( 2, 'CQK' )
Local oModel   := FWLoadModel( 'CTBA111' )
Local oView

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( 'VIEW_CQJ', oStruCQJ, 'CQJMASTER' )
oView:AddGrid(  'VIEW_CQK', oStruCQK, 'CQKDETAIL' )

oView:AddIncrementField( 'VIEW_CQK', 'CQK_ITEM' )

oView:CreateHorizontalBox( STR0007, 15 ) //EMCIMA
oView:CreateHorizontalBox( STR0008, 85 ) //EMBAIXO

oView:SetOwnerView( 'VIEW_CQJ', STR0007 ) //EMCIMA
oView:SetOwnerView( 'VIEW_CQK', STR0008 ) //EMBAIXO

oView:SetPrimarykey

oView:EnableTitleView( 'VIEW_CQJ' )
oView:EnableTitleView( 'VIEW_CQK' )

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} CTB111GRV
Comitt do modelo 

@author Thiago.Murakami
@since 12/06/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function CTB111GRV( oModel ) 
Local cItem		:= STRZERO(0,TamSX3('CQK_ITEM')[1])
Local oStruCQJ	:= oModel:GetModel("CQJMASTER")
Local cEvento 	:= oStruCQJ:GetValue("CQJ_CODEVE")  

FWFormCommit( oModel )

dbSelectArea("CQK")
CQK->(dbSetOrder(1)) //CQK_FILIAL + CQK_CODEVE + CQK_ITEM

If CQK->(dbSeek(xFilial("CQK") + cEvento ) )
	
	While CQK->(!Eof()) .And. CQK->(CQK_FILIAL + CQK_CODEVE) == xFilial("CQK") + cEvento
		
		cItem	:= Soma1(cItem)
		RecLock("CQK",.F.)
		CQK->CQK_ITEM := cItem
		CQK->(MsUnlock())
		
		CQK->(DbSkip())
	EndDo
	
EndIf
Return .T.