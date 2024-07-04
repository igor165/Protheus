#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'CTBA018.CH'
//
Function CTBA018() 
Local oBrowse  

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("CVR")                                          
oBrowse:SetDescription( STR0001 )  //"Cadastro de Auditores"
oBrowse:SetOnlyFields({'CVR_FILIAL', 'CVR_CODCVM', 'CVR_NOMAUD', 'CVR_DTINI', 'CVR_DTFIM'} )
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author pauloc

@since 17/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel
Local oStr1:= FWFormStruct(1,'CVR') 

oModel := MPFormModel():New('CTBA018',/*PreValidacao*/,{ |oModel|CTB18OK(oModel)}/*PosValidacao*/)
oModel:SetDescription( STR0001 )  //"Cadastro de Auditores"


oModel:addFields('ModelCVR',,oStr1)
oModel:SetPrimaryKey({ 'CVR_FILIAL', 'CVR_CODCVM' })

oModel:getModel('ModelCVR'):SetOnlyQuery(.F.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author pauloc

@since 17/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2,'CVR') 

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('Master_CVR' , oStr1,'ModelCVR' )

oView:EnableTitleView('Master_CVR' , STR0001 )  //"Cadastro de Auditores"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF()
Função para criar do menu 

@author guilherme.pimentel
@since 29/08/2013
@version 1.0
@return aRotina 
/*/
//-------------------------------------------------------------------

Static Function MenuDef()  
Local aRotina := {} //Array utilizado para controlar opcao selecionada

ADD OPTION aRotina TITLE STR0002 	ACTION "VIEWDEF.CTBA018"	OPERATION 2	ACCESS 0      //"Visualizar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.CTBA018"	OPERATION 3  	ACCESS 0      //"Incluir"     
ADD OPTION aRotina TITLE STR0004	ACTION "VIEWDEF.CTBA018"	OPERATION 4 	ACCESS 0      //"Alterar"     
ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.CTBA018"	OPERATION 5  	ACCESS 3 	   //"Excluir"	 
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.CTBA018" OPERATION 8 	ACCESS 0 	   //"Imprimir"	

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} CTB18OK()
Função para validar se o codigo CVM já existe

@author TOTVS
@since 04/06/2016
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------
Static Function CTB18OK(oModel)
Local lRet := .T.
Local nOpc		:= oModel:GetOperation()
Local aArea	:= Getarea()
Local aAreaCVR	:= CVR->(Getarea())
Local oMdlCVR			:= oModel:GetModel('ModelCVR')

Default oModel := Nil

If (nOpc == 3 ) .And. CVR->(dbSeek(xFilial("CVR")+oMdlCVR:GetValue('CVR_CODCVM')))
	lRet := .F.
	Help(" ",1,"CTB18OK","",STR0007,1,0) //"Código CVM já cadastrado"  
EndIf

If nOpc == 4 
 iF oMdlCVR:GetValue('CVR_CODCVM') != CVR->CVR_CODCVM .and.  CVR->(dbSeek(xFilial("CVR")+oMdlCVR:GetValue('CVR_CODCVM')))
	lRet := .F.
	Help(" ",1,"CTB18OK","",STR0007,1,0) //"Código CVM já cadastrado"  
 EndIf
Endif 
RestArea( aAreaCVR )
RestArea( aArea )

Return lRet

