#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA118.CH'

/*/{Protheus.doc} GTPA118
Cadastro de Categoria de Bilhetes
@type function
@author jacomo.fernandes
@since 21/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPA118()

Local oBrowse		:= oBrowse := FWMBrowse():New()

oBrowse:SetAlias('G9B')
oBrowse:SetDescription(STR0001)	//Cadastro de Categoria de Bilhetes
oBrowse:Activate()

Return ( oBrowse )


/*/{Protheus.doc} ModelDef
Função responsavel pela montagem do modelo de dados
@type function
@author jacomo.fernandes
@since 21/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()

Local oModel	:=  MPFormModel():New('GTPA118')
Local oStruG9B	:= FWFormStruct(1,'G9B')
Local bPosValid	:= {|oModel|TP118TdOK(oModel)}


oModel:AddFields('G9BMASTER',/*cOwner*/,oStruG9B)

oModel:SetPost(bPosValid)

//oModel:SetPrimaryKey({"G9B_FILIAL","G9B_CODIGO"})

oModel:SetDescription(STR0001)//Cadastro de Categoria de Bilhetes
oModel:GetModel('G9BMASTER'):SetDescription(STR0002)	//Dados da Categoria


Return ( oModel )

/*/{Protheus.doc} ViewDef
Função responsavel pela montagem da interface
@type function
@author jacomo.fernandes
@since 21/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA118') 
Local oStruG9B	:= FWFormStruct(2, 'G9B')

oView:SetModel(oModel)
oView:SetDescription(STR0001) //Cadastro de Categoria de Bilhetes
oView:AddField('VIEW_G9B' ,oStruG9B,'G9BMASTER')
oView:CreateHorizontalBox('TELA', 100)
oView:SetOwnerView('VIEW_G9B','TELA')

Return ( oView )

/*/{Protheus.doc} MenuDef
Função responsavel pela montagem do menu do browse
@type function
@author jacomo.fernandes
@since 21/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.GTPA118' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA118' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA118' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.GTPA118' OPERATION 5 ACCESS 0 // Excluir

Return ( aRotina )

/*/{Protheus.doc} IntegDef
Função responsável por acionar a integração via mensagem única do cadastro de Categoria.
@type function
@author jacomo.fernandes
@since 21/09/2018
@version 1.0
@param cXML, character, Texto da mensagem no formato XML.
@param nTypeTrans, numérico, Código do tipo de transação que está sendo executada.
@param cTypeMessage, character, Código com o tipo de Mensagem. (DELETE ou UPSERT)
@param cVersionRec, character, Versão da mensagem.
@return aRet, Array contendo as informações dos parâmetros para o Adapter.
@example
(examples)
@see (links_or_references)
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage, cVersionRec )
Return GTPI118( cXML, nTypeTrans, cTypeMessage, cVersionRec )

/*/{Protheus.doc} TP118TdOK
Função responsavel pela validação do código informado no sistema
@type function
@author jacomo.fernandes
@since 21/09/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function TP118TdOK(oModel)
Local lRet	:= .T.
Local oMdlG9B	:= oModel:GetModel('G9BMASTER')
// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oMdlG9B:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlG9B:GetOperation() == MODEL_OPERATION_UPDATE)
	If (!ExistChav("G9B", oMdlG9B:GetValue("G9B_CODIGO")))
		Help( ,, 'Help',"TP118TdOK", STR0007, 1, 0 )//Chave duplicada!
       lRet := .F.
    EndIf
EndIf

Return (lRet)

