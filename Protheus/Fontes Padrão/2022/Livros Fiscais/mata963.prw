#INCLUDE "MATA963.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} MATA963 Relacionamento codigos de Servicos

@author Flavio Luiz Vicco
@since 15/12/2017
@version 1.00
/*/
//-------------------------------------------------------------------
Function MATA963()
Local oBrowse := FWMBrowse():New()

//Ajuste do dicionário de dados.
A963AtSx3()

oBrowse:SetAlias("CDN")
oBrowse:SetDescription(STR0001) //"Relacionamento códigos de serviço"
oBrowse:Activate()

Return .T. 

//--------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Retorna o Modelo de dados da rotina de Cadastro de processos referenciados

@author flavio.luiz
@since 15/12/2017
/*/
//--------------------------------------------------------------------------
Static Function ModelDef()
Local oStruCDN := FwFormStruct(1, "CDN")
Local oModel   := MpFormModel():New("MATA963", , {|oModel| A963TudoOk(oModel)})

oModel:AddFields("MATA963MOD", /*cOwner*/, oStruCDN)
oModel:SetPrimaryKey({"CDN_FILIAL","CDN_CODISS","CDN_PROD"})
oModel:SetDescription(STR0001) //"Relacionamento códigos de serviço"

Return oModel

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Retorna a View (tela) da rotina de Cadastro de processos referenciados

@author flavio.luiz
@since 15/12/2017
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oStruCDN := FwFormStruct(2, "CDN")
Local oModel   := FwLoadModel("MATA963")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_CDN", oStruCDN, "MATA963MOD")

oView:CreateHorizontalBox("SUPERIOR", 100)
oView:SetOwnerView("VIEW_CDN", "SUPERIOR")

Return oView

//----------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna o Menu da rotina de Cadastro de processos referenciados

@author flavio.luiz
@since 15/12/2017
/*/
//----------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0006 ACTION 'PesqBrw'    	  OPERATION 1 ACCESS 0 //Pesquisar
ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.MATA963" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.MATA963" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.MATA963" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.MATA963" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} A963TudoOk
Funcao utilizada na validacao do registro

@return lRet	->	Permite alteracao do registro
/*/
//-------------------------------------------------------------------
Static Function A963TudoOk( oModel )
Local lRet := .T.
Local nOperation := oModel:GetOperation()
Local cCodISS    := oModel:GetValue("MATA963MOD", "CDN_CODISS")
Local cCodProd   := oModel:GetValue("MATA963MOD", "CDN_PROD")
Local nRecno     := CDN->(Recno())
Local nRecnoVld  := 0

If (nOperation == MODEL_OPERATION_INSERT) .OR. (nOperation == MODEL_OPERATION_UPDATE)
	DbSetOrder(1)
	If CDN->(dbSeek(xFilial("CDN") + cCodISS + cCodProd))
		If nOperation == MODEL_OPERATION_UPDATE //Alteração
			nRecnoVld := CDN->(Recno())
			If nRecnoVld <> nRecno
				Help(" ", 1, "JAGRAVADO")
				lRet := .F.
			EndIf
		Else
			Help(" ", 1, "JAGRAVADO")
			lRet := .F.
		EndIf
		//Volta Recno posicionado na tela
		CDN->(DbGoTo(nRecno))
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A963AtSx3
 
Função que irá alterar o conteudo do campo X3_VALID.
 
@author Eduardo Vicente da Silva
@since 30/07/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

Static Function A963AtSx3()
Local aDados := {}

Aadd(aDados, {{'CDN_CODISS'}, {{'X3_VALID','',Nil}}})

If FindFunction("EngSX3117")
	EngSX3117(aDados)
EndIf

Return
