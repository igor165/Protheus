#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA001.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA001()
Cadastro de Localidades
 
@sample	GTPA001()
 
@return	oBrowse	Retorna o Cadastro de Localidades
 
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA001()

Local oBrowse		:= Nil	

Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias('GI1')
oBrowse:SetDescription(STR0001)	//Cadastro de Localidades
oBrowse:Activate()

Return ( oBrowse )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= nil
Local oStruGI1	:= FWFormStruct(1,'GI1')
Local bPosValid	:= {|oModel|TP001TdOK(oModel)}
oModel := MPFormModel():New('GTPA001', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('GI1MASTER',/*cOwner*/,oStruGI1)
oModel:SetDescription(STR0001)
oModel:GetModel('GI1MASTER'):SetDescription(STR0002)	//Dados da Localidade
oModel:SetPrimaryKey({"GI1_FILIAL","GI1_COD"})

Return ( oModel )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
 
@sample	ViewDef()
 
@return	oView  Retorna a View
 
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= ModelDef() 
Local oView		:= FWFormView():New()
Local oStruGI1	:= FWFormStruct(2, 'GI1')

oView:SetModel(oModel)
oView:SetDescription(STR0001) 
oView:AddField('VIEW_GI1' ,oStruGI1,'GI1MASTER')
oView:CreateHorizontalBox('TELA', 100)
oView:SetOwnerView('VIEW_GI1','TELA')

Return ( oView )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Retorna as opções do Menu
 
@author	Lucas Brustolin -  Inovação
@since		09/10/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.GTPA001' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA001' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA001' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.GTPA001' OPERATION 5 ACCESS 0 // Excluir

Return ( aRotina )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Função responsável por acionar a integração via mensagem única do cadastro de Localidades.

Nome da mensagem: Locality
Fonte da Mensagem: GTPI001 

@sample	IntegDef( cXML, nTypeTrans, cTypeMessage, cVersionRec )
 
@param		cXml			Texto da mensagem no formato XML.
@param		nTypeTrans		Código do tipo de transação que está sendo executada.
@param		cTypeMessage	Código com o tipo de Mensagem. (DELETE ou UPSERT)
@param		cVersionRec	Versão da mensagem.

@return	aRet  			Array contendo as informações dos parâmetros para o Adapter.
 
@author	Danilo Dias
@since		16/02/2016
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage, cVersionRec )

	Local aRet := {}

	aRet :=  GTPI001( cXML, nTypeTrans, cTypeMessage, cVersionRec )

Return aRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP001TdOK()
Definição do Menu
 
@sample	TP001TdOK()
 
@return	lRet - verifica se validação está ok
 
@author	Inovação
@since		11/04/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TP001TdOK(oModel)
Local lRet	:= .T.
Local oMdlGI1	:= oModel:GetModel('GI1MASTER')
// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oMdlGI1:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGI1:GetOperation() == MODEL_OPERATION_UPDATE)
	If (!ExistChav("GI1", oMdlGI1:GetValue("GI1_COD")))
		Help( ,, 'Help',"TP001TdOK", STR0008, 1, 0 )//Chave duplicada!
       lRet := .F.
    EndIf
EndIf

Return (lRet)

