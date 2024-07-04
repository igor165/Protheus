#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA005.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA005()
Cadastro de Vias
 
@sample	GTPA005()
 
@return	oBrowse  Retorna o Cadastro de Vias
 
@author	Yuki Shiroma -  Inovação
@since		23/01/2017
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA005()

Local oBrowse 	:= Nil

Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("G9U")
oBrowse:SetDescription(STR0001) // Cadastro de Vias
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

ADD OPTION aRotina TITLE STR0008 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 // #Pesquisar
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.GTPA005' OPERATION 2 ACCESS 0 // #Visualizar
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.GTPA005' OPERATION 3 ACCESS 0 // #Incluir
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.GTPA005' OPERATION 4 ACCESS 0 // #Alterar
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.GTPA005' OPERATION 5 ACCESS 0 // #Excluir

Return ( aRotina )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	Yuki Shiroma -  Inovação
@since		32/01/2017
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel   
Local oStruG9U	:= FWFormStruct(1,'G9U')
Local bPosValid	:= {|oModel|TP005TdOK(oModel)}				
oModel := MPFormModel():New('GTPA005', /*bPreValid*/,bPosValid, /*bCommit*/, /*bCancel*/)

oModel:AddFields('G9UMASTER',/*cOwner*/,oStruG9U)
oModel:SetDescription(STR0002) // Dados da Via
oModel:GetModel('G9UMASTER'):SetDescription(STR0002)	// #Dados da Via

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

Local oModel	:= FWLoadModel('GTPA005')	
Local oView		:= FWFormView():New()
Local oStruG9U	:= FWFormStruct(2,'G9U')
	
oView:SetModel(oModel)
oView:SetDescription(STR0002) //Dados da Via
oView:AddField('VIEW_G9U',oStruG9U,'G9UMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_G9U','TELA')

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
aRet:= GTPI005( cXml, nTypeTrans, cTypeMessage )
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TP005TdOK

Realiza validação se nao possui chave duplicada antes do commit

@param	oModel

@author Inovação
@since 11/04/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function TP005TdOK(oModel)
Local lRet 	:= .T.
Local oMdlG9U	:= oModel:GetModel('G9UMASTER')

// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oMdlG9U:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlG9U:GetOperation() == MODEL_OPERATION_UPDATE)
	If (!ExistChav("G9U", oMdlG9U:GetValue("G9U_CODIGO")))
		Help( ,, 'Help',"TP005TdOK", STR0010, 1, 0 )//Chave duplicada!
       lRet := .F.
    EndIf
EndIf

Return (lRet)