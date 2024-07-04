#INCLUDE "TURA005.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURA005()

CADASTRO DE TIPO DE ENTIDADE - SIGATUR

@sample 	TURA005()
@return   	.T.                          
@author  	Fanny Mieko Suzuki
@since   	25/02/2015
@version  	P12
/*/
//------------------------------------------------------------------------------------------
Function TURA005()

Local oBrowse	:= FWMBrowse():New()

// criando o registro padrão 01 - CENTRO DE CUSTO

Processa({|| TURA005G3E()}) 
oBrowse:SetAlias('G3E')
oBrowse:SetDescription(STR0001) // "Cadastro de Tipo de Entidade"
oBrowse:Activate()

Return(.T.)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

CADASTRO DE TIPO DE ENTIDADE - DEFINE MODELO DE DADOS (MVC) 

@sample 	TURA005()
@return  	oModel                       
@author  	Fanny Mieko Suzuki
@since   	25/02/2015
@version  	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStruG3E := FWFormStruct(1,'G3E',/*bAvalCampo*/,/*lViewUsado*/)

oModel:= MPFormModel():New('TURA005',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('G3EMASTER',/*cOwner*/,oStruG3E,/*Criptog()/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetPrimaryKey({})
oModel:SetDescription(STR0001) // "Cadastro de Tipo de Entidade"

oModel:SetActivate()
oModel:SetVldActivate({|oModel| TURA005VLD(oModel)})

Return(oModel)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

CADASTRO DE TIPO DE ENTIDADE - DEFINE A INTERFACE DO CADASTRO (MVC) 

@sample 	TURA005()
@return   	oView                       
@author  	Fanny Mieko Suzuki
@since   	25/02/2015
@version  	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel('TURA005')
Local oStruG3E := FWFormStruct(2,'G3E')

oView:= FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_G3E', oStruG3E,'G3EMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_G3E','TELA')

Return(oView)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

CADASTRO DE TIPO DE ENTIDADE - DEFINE AROTINA (MVC) 

@sample 	TURA005()
@return  	aRotina                       
@author  	Fanny Mieko Suzuki
@since   	25/02/2015
@version  	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TURA005'	OPERATION 2	ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TURA005'	OPERATION 3	ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TURA005'	OPERATION 4	ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.TURA005'	OPERATION 5	ACCESS 0 // "Excluir"

Return(aRotina)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TURA005VLD(oModel)

VALIDA EXCLUSÃO / ALTERAÇÃO DA ENTIDADE CENTRO DE CUSTO

@sample 	TURA005()
@return  	aRotina                       
@author  	Fanny Mieko Suzuki
@since   	25/02/2015
@version  	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TURA005VLD(oModel)

Local lRet 		:= .T.
Local nOperation	:= oModel:GetOperation()

// VERIFICA SE É INCLUSÃO OU ATUALIZAÇÃO
IF (nOperation == MODEL_OPERATION_DELETE .OR. nOperation == MODEL_OPERATION_UPDATE) .and. !IsInCallSt("IpcCfg020A") 
	IF G3E->G3E_CODIGO == "01" 
		Help("TURA005VLD", 1, STR0007, , STR0008, 1, 0) // "Atenção" - "Entidade 01 Centro de Custo Padrão - Não é possivel Excluir /  Alterar o Registro"
		lRet := .F.
	ENDIF
ENDIF

Return lRet

//------------------------------------------------------------------------------------------
/*{Protheus.doc} TURA005G3E()

INSERE O REGISTRO DE CENTRO DE CUSTO

@sample 	TURA005G3E()
@return  	lRet                       
@author  	Thiago Tavares
@since   	12/11/2015
@version  	P12.1.8
*/
//------------------------------------------------------------------------------------------
Function TURA005G3E()

Local lRet      := .T.
Local aArea     := GetArea()
Local oModel

G3E->(DbSetOrder(1))
If !G3E->(DbSeek(xFilial('G3E')+StrZero(1,TamSx3('G3E_CODIGO')[1])))
	oModel := FwLoadModel('TURA005')

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	If oModel:Activate()
		oModel:GetModel('G3EMASTER'):SetValue('G3E_CODIGO' , StrZero(1,TamSx3('G3E_CODIGO')[1]))
		oModel:GetModel('G3EMASTER'):SetValue('G3E_DESCR' ,STR0011)
		If oModel:VldData() 
			oModel:CommitData()
		Endif
	Endif
	oModel:Deactivate()

EndIf

RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Função para chamar o Adapter para integração via Mensagem Única 

@sample 	IntegDef( cXML, nTypeTrans, cTypeMessage )
@param		cXml – O XML recebido pelo EAI Protheus
			cType – Tipo de transação
				'0'- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				'1'- para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage – Tipo da mensagem do EAI
				'20' – Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				'21' – Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				'22' – Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				'23' - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
@return  	aRet[1] – Variável lógica, indicando se o processamento foi executado com sucesso (.T.) ou não (.F.)
			aRet[2] – String contendo informações sobre o processamento
			aRet[3] – String com o nome da mensagem única deste cadastro                        
@author  	Thiago Tavares
@since   	02/09/2015
@version  	P12.1.8
/*/
//------------------------------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

Local aRet := {}

aRet:= TURI005( cXml, nTypeTrans, cTypeMessage )

Return aRet

