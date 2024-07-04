#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA007.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA007
Tipos de Documentos.

@sample		GTPA007()

@author 		Inovação - Serviços
@since 			02/10/2014
@version 		P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA007()
	
Local oBrowse := Nil
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('GYA')
	oBrowse:SetDescription(STR0001)	//'Tipos de Documentos'
	oBrowse:Activate()
	
Return Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu

@sample		MenuDef()

@return		aRotina - Array de opções do menu

@author		Inovação - Serviços
@since			02/10/2014
@version		P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
	
Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.GTPA007' OPERATION 2 ACCESS 0	//'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.GTPA007' OPERATION 3 ACCESS 0	//'Incluir'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.GTPA007' OPERATION 4 ACCESS 0	//'Alterar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.GTPA007' OPERATION 5 ACCESS 0	//'Excluir'
	
Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo de dados.

@sample		ModelDef()

@return		oModel - Modelo de dados.

@author		Inovação - Serviços
@since			02/10/2014
@version		P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	
Local oModel	:= Nil
Local bPosValid	:= {|oModel|TP007TdOK(oModel)}
Local oStruGYA	:= FWFormStruct(1,'GYA')

oModel := MPFormModel():New('GTPA007',/*bPreValid*/,bPosValid,/*bCommit*/,/*bCancel*/)

oModel:AddFields('GYAMASTER',/*cOwner*/,oStruGYA)
oModel:SetDescription(STR0001)	//' Tipos de Documento'
oModel:GetModel('GYAMASTER'):SetDescription(STR0001)	//' Tipos de Documento'
oModel:SetPrimaryKey({"GYA_FILIAL","GYA_CODIGO"})
	
Return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface.
@sample		ViewDef()
@return		oView - Retorna a View
@author		Inovação - Serviços
@since			02/10/2014
@version		P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()
	
Local oModel	:= ModelDef()
Local oView		:= FWFormView():New()
Local oStruGYA	:= FWFormStruct(2, 'GYA')
	
oView:SetModel(oModel)
oView:SetDescription(STR0001)	//'Tipos de Documentos'

oView:AddField('VIEW_GYA' ,oStruGYA,'GYAMASTER')
oView:CreateHorizontalBox('TELA', 100)
oView:SetOwnerView('VIEW_GYA','TELA')
	
Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} TP007TdOK

Realiza validação se nao possui chave duplicada antes do commit

@param	oModel

@author Inovação
@since 11/04/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function TP007TdOK(oModel)
Local lRet 	:= .T.
Local oMdlGYA	:= oModel:GetModel('GYAMASTER')

// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oMdlGYA:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGYA:GetOperation() == MODEL_OPERATION_UPDATE)
	If (!ExistChav("GYA", oMdlGYA:GetValue("GYA_CODIGO")))
		Help( ,, 'Help',"TP007TdOK", STR0009, 1, 0 )//Chave duplicada!
       lRet := .F.
    EndIf
EndIf

Return (lRet)