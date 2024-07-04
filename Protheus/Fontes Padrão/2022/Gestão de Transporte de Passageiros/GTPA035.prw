#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA035.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA035()
Cadastro de Tipo de Localidades
 
@sample	GTPA035()
 
@return	oBrowse  Retorna o Cadastro de Tipo de Localidade
 
@author	Yuki Shiroma -  Inovação
@since		23/01/2017
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA035()

Local oBrowse 	:= Nil

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("G9V")
oBrowse:SetDescription(STR0001) // Cadastro de Tipo de Localidade
oBrowse:Activate()

Return ( oBrowse )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Array com opções do Menu
 
@author	Yuki Shiroma -  Inovação
@since		23/01/2017
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0008 ACTION 'PesqBrw' 		  OPERATION 1 ACCESS 0 // #Pesquisar
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.GTPA035' OPERATION 2 ACCESS 0 // #Visualizar
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.GTPA035' OPERATION 3 ACCESS 0 // #Incluir
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.GTPA035' OPERATION 4 ACCESS 0 // #Alterar
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.GTPA035' OPERATION 5 ACCESS 0 // #Excluir

Return ( aRotina )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	Yuki Shiroma -  Inovação
@since		23/01/2017
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel   
Local oStruG9V := FWFormStruct(1,'G9V')
Local bPosValid	:= {|oModel|TP035TdOK(oModel)}
oModel := MPFormModel():New('GTPA035',/*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/)

oModel:AddFields('G9VMASTER',/*cOwner*/,oStruG9V)
oModel:SetDescription(STR0002)
oModel:GetModel('G9VMASTER'):SetDescription(STR0001)	// #Dados do Tipo de Localidade
oModel:SetPrimaryKey({"G9V_FILIAL","G9V_CODIGO"})

Return ( oModel )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da Interface
 
@sample	ViewDef()
 
@return	oView - Objeto da Interface
 
@author	Yuki Shiroma -  Inovação
@since		23/01/2017
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()
	
Local oModel   := ModelDef()
Local oView    := FWFormView():New()
Local oStruG9V := FWFormStruct(2,'G9V')
	
oView:SetModel(oModel)
oView:SetDescription(STR0002)// #Dados do Tipo de Localidade
oView:AddField('VIEW_G9V',oStruG9V,'G9VMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_G9V','TELA')

Return ( oView )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Funcao para chamar o Adapter para integracao via Mensagem Unica 

@sample 	IntegDef( cXML, nTypeTrans, cTypeMessage )
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				'0'- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				'1'- para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				'20' - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				'21' - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				'22' - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				'23' - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return  	aRet[1] - Variavel logica, indicando se o processamento foi executado com sucesso (.T.) ou nao (.F.)
			aRet[2] - String contendo informacoes sobre o processamento
			aRet[3] - String com o nome da mensagem Unica deste cadastro                        
@author  	Jacomo Lisa
@since   	15/02/2017
@version  	P12.1.8
/*/
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local aRet := {}
aRet:= GTPI035( cXml, nTypeTrans, cTypeMessage )
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TP035TdOK

Realiza validação se nao possui chave duplicada antes do commit

@param	oModel

@author Inovação
@since 11/04/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function TP035TdOK(oModel)
Local lRet 	:= .T.
Local oMdlG9V	:= oModel:GetModel('G9VMASTER')

// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oMdlG9V:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlG9V:GetOperation() == MODEL_OPERATION_UPDATE)
	If (!ExistChav("G9V", oMdlG9V:GetValue("G9V_CODIGO")))
		Help( ,, 'Help',"TP035TdOK", STR0009, 1, 0 )//Chave duplicada!
       lRet := .F.
    EndIf
EndIf

Return (lRet)