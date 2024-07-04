#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA006A.CH'

/*/{Protheus.doc} GTPA006A
    Programa em MVC para o cadastro de Configura��o DARUMA da Ag�ncia
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
	FWExecView(STR0001,"VIEWDEF.GTPA006A",MODEL_OPERATION_UPDATE,,{|| .T.})	//"Configura��o de Ag�ncia (DARUMA)"
Else
	FWExecView(STR0001,"VIEWDEF.GTPA006A",MODEL_OPERATION_INSERT,,{|| .T.})	//"Configura��o de Ag�ncia (DARUMA)"
EndIf

Return()

/*/{Protheus.doc} ModelDef
    Fun��o que define o modelo de dados para o cadastro de Configura��o DARUMA da Ag�ncia
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 
    @return oModel, objeto, inst�ncia da classe FwFormModel
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()

Local oModel	:= nil
Local oStrGZ0	:= FWFormStruct( 1, "GZ0",,.F. )	//Tabela de Esp�cie de Animais
Local oStrGZ1	:= FWFormStruct( 1, "GZ1",,.F. )	//Tabela de Esp�cie de Animais

Local aGatilho	:= {}
Local aRelation	:= {}

Local bLinePre	:= { |oSubMdl,cAct,cFld,xVl| GA006AVld(oSubMdl,cAct,cFld,xVl) }

//Defini��o de Gatilhos - In�cio
aGatilho := FwStruTrigger("GZ0_CODGI6", "GZ0_DESCAG", 'Posicione("GI6",1,XFilial("GI6")+FwFldGet("GZ0_CODGI6"),"GI6_DESCRI")')
oStrGZ0:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])

aGatilho := FwStruTrigger("GZ1_LINHA", "GZ1_LINDES", 'TPNOMELINH(FwFldGet("GZ1_LINHA"))')
oStrGZ1:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])
//Defini��o de Gatilhos - Fim

oModel := MPFormModel():New("GTPA006A")//, /*bPreValidacao*/, {|oMdl| TA39FVld(oMdl)}/*bPosValidacao*/,/*bCommit*/, /*bCancel*/ )

oModel:AddFields("GZ0MASTER", /*cOwner*/, oStrGZ0,bLinePre)

oModel:AddGrid("GZ1DETAIL", "GZ0MASTER", oStrGZ1)

//Relacionamentos
aRelation := {	{ "GZ1_FILIAL", "XFilial('GZ1')" },; 
				{ "GZ1_CODGI6", "GZ0_CODGI6" }}
				
oModel:SetRelation( "GZ1DETAIL", aRelation, GZ1->(IndexKey(1)) )	//GZ1_FILIAL+GZ1_CODGI6+GZ1_LINHA

oModel:SetDescription(STR0002) // "Configura��o DARUMA"
oModel:GetModel("GZ0MASTER"):SetDescription(STR0003) // "Informa��es da Ag�ncia"
oModel:GetModel("GZ1DETAIL"):SetDescription(STR0004) // "Linhas"

//Regra de Integridade de Itens
oModel:GetModel("GZ1DETAIL"):SetUniqueLine( {"GZ1_LINHA"} )

oModel:SetActivate({|oMdl| GA006ALoad(oMdl)})

Return(oModel)

/*/{Protheus.doc} ViewDef
    Fun��o que define a View para o cadastro de Configura��o DARUMA da Ag�ncia
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 
    @return oView, objeto, inst�ncia da Classe FWFormView
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()

Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA006A")
Local oStrGZ0	:= FWFormStruct( 2, "GZ0",,.F. )	//Tabela de Esp�cie de Animais
Local oStrGZ1	:= FWFormStruct( 2, "GZ1",,.F. )	//Tabela de Esp�cie de Animais

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

//Remove Campos desnecess�rios - In�cio
If ( oStrGZ0:HasField("GZ0_FILIAL") )
	oStrGZ0:RemoveField("GZ0_FILIAL")
EndIf

If ( oStrGZ1:HasField("GZ1_FILIAL") )
	oStrGZ1:RemoveField("GZ1_FILIAL")
EndIf

oStrGZ1:RemoveField("GZ1_CODGI6")
//Remove Campos desnecess�rios - Fim

oView:AddField("VIEW_GZ0", oStrGZ0, "GZ0MASTER" )
oView:AddGrid("VIEW_GZ1", oStrGZ1, "GZ1DETAIL")

// Divis�o Horizontal
oView:CreateHorizontalBox("HEADER",30)
oView:CreateHorizontalBox("BODY",70)

oView:SetOwnerView("VIEW_GZ0", "HEADER")
oView:SetOwnerView("VIEW_GZ1", "BODY")

//Habitila os t�tulos dos modelos para serem apresentados na tela
oView:EnableTitleView("VIEW_GZ0")
oView:EnableTitleView("VIEW_GZ1")

Return(oView)

/*/{Protheus.doc} GA006AVld
    Fun��o que define a View para o cadastro de Configura��o DARUMA da Ag�ncia
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 	oSubModel, objeto, inst�ncia da Classe FWFormFieldsModel
			cAction, caractere, A��o executada na valida��o (ex: "SETVALUE")
			cField, caractere, Campo que ser� validado
			xValue, qualquer, valor a ser validado
    @return lRet, l�gico, .t. - validado com sucesso
    @example
    lRet := GA006AVld(oSubModel,cAction,cField,xValue)
    @see (links_or_references)
/*/
Static Function GA006AVld(oSubModel,cAction,cField,xValue)

Local lRet	:= .t.

Return(lRet)

/*/{Protheus.doc} GA006ALoad
    Fun��o para a carga do cabe�alho do modelo de dados. A fun��o � chamada no momento
    da ativa��o do modelo.
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 	oModel, objeto, inst�ncia da Classe FWFormModel
    @return .t., l�gico, .t. - validado com sucesso
    @example
    GA006ALoad(oModel)
    @see (links_or_references)
/*/

Static Function GA006ALoad(oModel)

oModel:GetModel("GZ0MASTER"):LoadValue("GZ0_CODGI6",GI6->GI6_CODIGO)
oModel:GetModel("GZ0MASTER"):LoadValue("GZ0_DESCAG",GI6->GI6_DESCRI)

Return(.t.)