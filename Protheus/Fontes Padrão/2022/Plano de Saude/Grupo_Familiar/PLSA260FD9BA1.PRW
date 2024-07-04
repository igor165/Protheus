#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260FD9BA1
Tela com campos para o preenchimento do Folder Dados do Plano BA1
@author Roberto Barbosa
@since 05/08/19
@version P12
/*/
//-------------------------------------------------------------------



Function PLSA260FD9BA1(lAutomato)
Local oBrowse
Default lAutomato := .F.

PRIVATE cCodPla := ""
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260FD9BA1' )
	iF(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260FD9BA1 
@author  Roberto Barbosa
@version P12
@since   05/08/2019
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}
Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao do modelo MVC PLSA260FD9BA1 
@author  Roberto Barbosa
@version P12
@since   05/08/2019
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local oStruBA1 := FWFormStruct( 1,'BA1', { |cCampo| PLS260CAMPOS(cCampo, 'BA1','Plano') })	
	
	BI3->(DBSelectArea("BI3"))
	//Posiciono a BA3, pois necessito do CODPLA da familia
	BA3->(DbSetOrder(1))
	BA3->(DbSeek(xFilial('BA3')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))

    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260FD9BA1')	
	oModel:addFields('BA1MASTER' , ,oStruBA1) 								
    oModel:SetDescription( FunDesc() )	
	oModel:GetModel( 'BA1MASTER' ):SetDescription( 'Dados do Plano do Beneficiario' )
	oModel:SetPrimaryKey({})
	oStruBA1:setProperty('BA1_CODPLA', MODEL_FIELD_VALID, { || PLSABA3MVC(oModel,2) .AND. RegBA3Mem(oModel)})
	oStruBA1:setProperty('BA1_VERSAO', MODEL_FIELD_VALID, { || Empty(M->BA1_VERSAO) .OR. BIL->(EXISTCPO("BIL",BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)))})
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  Roberto Barbosa
@version P12
@since   05/08/2019
/*/
//-------------------------------------------------------------------
Static Function ViewDef()  
Local oStruBA1 := FWFormStruct( 2,'BA1', { |cCampo| PLS260CAMPOS(cCampo, 'BA1','Plano') })
Local oModel   := FWLoadModel( 'PLSA260FD9BA1' )
Local oView

	oView := FWFormView():New()

	oView:SetModel(oModel )
    oView:AddField('VIEW_BA1', oStruBA1, 'BA1MASTER')

    oStruBA1:SetNoFolder()
	oView:CreateHorizontalBox( 'SUPERIOR' 	, 100) 
	oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
	oView:EnableTitleView('VIEW_BA1','Dados do Plano do Beneficiario')
	//Não permito alteração nos campos
	oStruBA1:SetProperty( 'BA1_DATINC', MVC_VIEW_CANCHANGE,.F.)
	oStruBA1:setProperty( 'BA1_VERSAO', MVC_VIEW_LOOKUP, 'BJ6MVC')
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} RegBA3Mem
Carrega campos para a memória, para a consulta padrão BJ6PLS 
@author  Roberto Barbosa
@version P12
@since   13/09/2019
/*/
//-------------------------------------------------------------------

Function RegBA3Mem(oModel)

oModel:LoadValue( 'BA1MASTER','BA1_DESPLA',Substr(BI3->BI3_DESCRI,1,TAMSX3("BA1_DESPLA")[1]) )

Return .T.