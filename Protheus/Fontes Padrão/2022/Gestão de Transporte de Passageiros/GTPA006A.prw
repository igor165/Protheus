#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA006A.CH'

/*/{Protheus.doc} GTPA006A
    Programa em MVC para o cadastro de Configuração DARUMA da Agência
    @type  Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 
    @return nil,null, sem retorno
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPA006A()

GZ0->(DbSetOrder(1))

If ( GZ0->(DbSeek(XFilial("GZ0")+GI6->GI6_CODIGO)) )
	FWExecView(STR0001,"VIEWDEF.GTPA006A",MODEL_OPERATION_UPDATE,,{|| .T.})	//"Configuração de Agência (DARUMA)"
Else
	FWExecView(STR0001,"VIEWDEF.GTPA006A",MODEL_OPERATION_INSERT,,{|| .T.})	//"Configuração de Agência (DARUMA)"
EndIf

Return()

/*/{Protheus.doc} ModelDef
    Função que define o modelo de dados para o cadastro de Configuração DARUMA da Agência
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()

Local oModel	:= nil
Local oStrGZ0	:= FWFormStruct( 1, "GZ0",,.F. )	//Tabela de Espécie de Animais
Local oStrGZ1	:= FWFormStruct( 1, "GZ1",,.F. )	//Tabela de Espécie de Animais

Local aGatilho	:= {}
Local aRelation	:= {}

Local bLinePre	:= { |oSubMdl,cAct,cFld,xVl| GA006AVld(oSubMdl,cAct,cFld,xVl) }

//Definição de Gatilhos - Início
aGatilho := FwStruTrigger("GZ0_CODGI6", "GZ0_DESCAG", 'Posicione("GI6",1,XFilial("GI6")+FwFldGet("GZ0_CODGI6"),"GI6_DESCRI")')
oStrGZ0:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])

aGatilho := FwStruTrigger("GZ1_LINHA", "GZ1_LINDES", 'TPNOMELINH(FwFldGet("GZ1_LINHA"))')
oStrGZ1:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])
//Definição de Gatilhos - Fim

oModel := MPFormModel():New("GTPA006A")//, /*bPreValidacao*/, {|oMdl| TA39FVld(oMdl)}/*bPosValidacao*/,/*bCommit*/, /*bCancel*/ )

oModel:AddFields("GZ0MASTER", /*cOwner*/, oStrGZ0,bLinePre)

oModel:AddGrid("GZ1DETAIL", "GZ0MASTER", oStrGZ1)

//Relacionamentos
aRelation := {	{ "GZ1_FILIAL", "XFilial('GZ1')" },; 
				{ "GZ1_CODGI6", "GZ0_CODGI6" }}
				
oModel:SetRelation( "GZ1DETAIL", aRelation, GZ1->(IndexKey(1)) )	//GZ1_FILIAL+GZ1_CODGI6+GZ1_LINHA

oModel:SetDescription(STR0002) // "Configuração DARUMA"
oModel:GetModel("GZ0MASTER"):SetDescription(STR0003) // "Informações da Agência"
oModel:GetModel("GZ1DETAIL"):SetDescription(STR0004) // "Linhas"

//Regra de Integridade de Itens
oModel:GetModel("GZ1DETAIL"):SetUniqueLine( {"GZ1_LINHA"} )

oModel:SetActivate({|oMdl| GA006ALoad(oMdl)})

Return(oModel)

/*/{Protheus.doc} ViewDef
    Função que define a View para o cadastro de Configuração DARUMA da Agência
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 
    @return oView, objeto, instância da Classe FWFormView
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()

Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA006A")
Local oStrGZ0	:= FWFormStruct( 2, "GZ0",,.F. )	//Tabela de Espécie de Animais
Local oStrGZ1	:= FWFormStruct( 2, "GZ1",,.F. )	//Tabela de Espécie de Animais

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Remove Campos desnecessários - Início
If ( oStrGZ0:HasField("GZ0_FILIAL") )
	oStrGZ0:RemoveField("GZ0_FILIAL")
EndIf

If ( oStrGZ1:HasField("GZ1_FILIAL") )
	oStrGZ1:RemoveField("GZ1_FILIAL")
EndIf

oStrGZ1:RemoveField("GZ1_CODGI6")
//Remove Campos desnecessários - Fim

oView:AddField("VIEW_GZ0", oStrGZ0, "GZ0MASTER" )
oView:AddGrid("VIEW_GZ1", oStrGZ1, "GZ1DETAIL")

// Divisão Horizontal
oView:CreateHorizontalBox("HEADER",30)
oView:CreateHorizontalBox("BODY",70)

oView:SetOwnerView("VIEW_GZ0", "HEADER")
oView:SetOwnerView("VIEW_GZ1", "BODY")

//Habitila os títulos dos modelos para serem apresentados na tela
oView:EnableTitleView("VIEW_GZ0")
oView:EnableTitleView("VIEW_GZ1")

Return(oView)

/*/{Protheus.doc} GA006AVld
    Função que define a View para o cadastro de Configuração DARUMA da Agência
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 	oSubModel, objeto, instância da Classe FWFormFieldsModel
			cAction, caractere, Ação executada na validação (ex: "SETVALUE")
			cField, caractere, Campo que será validado
			xValue, qualquer, valor a ser validado
    @return lRet, lógico, .t. - validado com sucesso
    @example
    lRet := GA006AVld(oSubModel,cAction,cField,xValue)
    @see (links_or_references)
/*/
Static Function GA006AVld(oSubModel,cAction,cField,xValue)

Local lRet	:= .t.

Return(lRet)

/*/{Protheus.doc} GA006ALoad
    Função para a carga do cabeçalho do modelo de dados. A função é chamada no momento
    da ativação do modelo.
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 	oModel, objeto, instância da Classe FWFormModel
    @return .t., lógico, .t. - validado com sucesso
    @example
    GA006ALoad(oModel)
    @see (links_or_references)
/*/

Static Function GA006ALoad(oModel)

oModel:GetModel("GZ0MASTER"):LoadValue("GZ0_CODGI6",GI6->GI6_CODIGO)
oModel:GetModel("GZ0MASTER"):LoadValue("GZ0_DESCAG",GI6->GI6_DESCRI)

Return(.t.)