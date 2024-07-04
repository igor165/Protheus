#include "protheus.ch"
#include "fwmvcdef.ch"
#include "fweditpanel.ch"
#include "fina035.ch"

/*/{Protheus.doc} FINA035
Cadastro de Tipos de Valores Acessórios

@author Mauricio Pequim Jr
@since 01/08/2016
@version P12.1.8
/*/
Function FINA035()

	Local oBrowse

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("FKC")
	oBrowse:SetDescription( STR0001 ) //"Cadastro de Tipos de Valores Acessórios"
	oBrowse:AddLegend( "FKC_ATIVO == '1'", "GREEN", STR0007 ) //"Ativo"
	oBrowse:AddLegend( "FKC_ATIVO == '2'", "RED",   STR0008 ) //"Inativo"
	oBrowse:SetMenuDef( "FINA035" )
	oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Cadastro de Tipos de Valores Acessórios

@author Mauricio Pequim Jr
@since 01/08/2016
@since 13/10/2015
@version P12.1.8
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title STR0002 Action "VIEWDEF.FINA035" OPERATION 2 ACCESS 1 //"Visualizar"
	ADD OPTION aRotina Title STR0003 Action "VIEWDEF.FINA035" OPERATION 3 ACCESS 1 //"Incluir"
	ADD OPTION aRotina Title STR0004 Action "VIEWDEF.FINA035" OPERATION 4 ACCESS 1 //"Alterar"
	ADD OPTION aRotina Title STR0005 Action "VIEWDEF.FINA035" OPERATION 5 ACCESS 1 //"Excluir"

Return aRotina

/*/{Protheus.doc} ViewDef
Interface.

@author Totvs
@since 01/08/2016
@version 12
/*/
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel( "FINA035" )
	Local nOperation := oModel:GetOperation()
	Local oFKC       := FWFormStruct( 2, "FKC" )

	oView:SetModel( oModel )
	oView:AddField( "VIEWFKC", oFKC, "FKCMASTER" )
	oView:SetViewProperty( "VIEWFKC", "SETLAYOUT", {FF_LAYOUT_HORZ_DESCR_TOP, 1} )
	oView:CreateHorizontalBox( "BOXFKC", 100 )
	oView:SetOwnerView( "VIEWFKC", "BOXFKC" )

Return oView

/*/{Protheus.doc} ModelDef
Modelo de dados.

@author Totvs
@since 01/08/2016
@version 12
/*/
Static Function ModelDef()

	Local oModel := MPFormModel():New( "FINA035" )
	Local oFKC   := FWFormStruct( 1, "FKC" )

	oModel:SetVldActivate( {|oModel| ValidPre(oModel)} )
	oModel:AddFields( "FKCMASTER", /*cOwner*/, oFKC )
	oModel:SetPrimaryKey( {"FKC_CODIGO"} )

	oFKC:SetProperty( "FKC_CODIGO", MODEL_FIELD_WHEN, {|oModel, cFieldName, xValue| oModel:GetOperation() <> MODEL_OPERATION_UPDATE} )
	oFKC:SetProperty( "FKC_ACAO"  , MODEL_FIELD_WHEN, {|oModel, cFieldName, xValue| oModel:GetOperation() <> MODEL_OPERATION_UPDATE} )
	oFKC:SetProperty( "FKC_TPVAL" , MODEL_FIELD_WHEN, {|oModel, cFieldName, xValue| oModel:GetOperation() <> MODEL_OPERATION_UPDATE} )
	oFKC:SetProperty( "FKC_APLIC" , MODEL_FIELD_WHEN, {|oModel, cFieldName, xValue| oModel:GetOperation() <> MODEL_OPERATION_UPDATE} )
	oFKC:SetProperty( "FKC_PERIOD", MODEL_FIELD_WHEN, {|oModel, cFieldName, xValue| oModel:GetOperation() <> MODEL_OPERATION_UPDATE} )
	oFKC:SetProperty( "FKC_RECPAG", MODEL_FIELD_WHEN, {|oModel, cFieldName, xValue| oModel:GetOperation() <> MODEL_OPERATION_UPDATE} )

Return oModel

/*/{Protheus.doc} F035VldVar
Função para validar a variável contábil informada, não permitindo o uso da mesma variável
em dois registros de valores acessórios diferentes. Chamada do valid do campo FKC_VARCTB
e do adapter para validação de sequencial disponível

@Return lRet, Indica se a variável é válida

@author Pedro Alencar
@since 15/08/2016
@version 12
/*/
Function F035VldVar( cVarCTB )

	Local lRet       := .T.
	Local oModelVA   := Nil
	Local cAliasFKC  := ""
	Local cQuery     := ""
	Local aArea      := GetArea()

	//Se a variável não foi informada, então está sendo chamada do valid do campo, portanto pega-se o valor definido no model
	Default cVarCTB := ""
	If Empty( cVarCTB )
		oModelVA := FWModelActive()
		cVarCTB  := oModelVA:GetValue("FKCMASTER", "FKC_VARCTB")
		oModelVA := Nil
	Endif

	//Se o valor não estiver vazio, então verifica na tabela se essa variável já não foi utilizada para a filial logada
	If !Empty( cVarCTB )
		cAliasFKC := GetNextAlias()
		cQuery := "SELECT FKC_CODIGO " + CRLF
		cQuery += " FROM " + RetSqlName("FKC") + CRLF
		cQuery += " WHERE " + CRLF
		cQuery += " FKC_FILIAL = '" + FWxFilial("FKC") + "' AND " + CRLF
		cQuery += " FKC_VARCTB = '" + cVarCTB + "' AND " + CRLF
		cQuery += " D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasFKC, .T., .T. )

		//Se encontrou algum registro, então retorna .F.
		If ( cAliasFKC )->( ! EOF() )
			lRet := .F.
			Help( ,, "FKCVARCTB",, STR0009 + ( cAliasFKC )->FKC_CODIGO, 1, 0,,,,,, {STR0010} ) //"Essa variável já está em uso por outro valor acessório: ", "Defina outra variável contábil."
		Endif
		( cAliasFKC )->( dbCloseArea() )

		If lRet .And. Subs(cVarCTB,1,1) $ "0123456789"
			lRet := .F.
			Help( ,, "VARCTBIN1",, STR0014+Chr(13)+Chr(10)+STR0015, 1, 0,,,,,, {STR0016} ) //"Expressão inválida!"### "Esse campo será utilizado para criar uma variável dentro do Protheus, que poderá ser utilizada no processo de contabilização. Portanto, não é possível iniciá-lo com números."### "Digite uma expressão de acordo com as regra citada acima."
		Endif

		//Valida as variáveis reservadas do sistema
		If lRet .and. Alltrim(cVarCTB) $ "PIS|COFINS|CSLL|IRF|ISS|INSS|JUROS1|JUROS2|MULTA1|MULTA2|DESC1|DESC2|CMONET1|CMONET2|VALOR|VALOR1|VALOR2|VALOR3|VALOR4|VALOR5|VALOR6|VALOR7|JUROS3|FO1VADI"
			lRet := .F.
			Help( ,, "VARCTBIN2",, STR0012, 1, 0,,,,,, {STR0013} ) //"A expressão utilizada é reservada para uso interno no módulo Financeiro."###"Por favor, utilize outra expressão"
		Endif
	Endif

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} ValidPre

@author  Felipe Raposo
@version P12.1.17
@since   24/04/2018
/*/
Static Function ValidPre(oModel)

	Local lRet       := .T.
	Local nOperation := oModel:getOperation()

	If nOperation == MODEL_OPERATION_DELETE
		lRet := ValidDel()
	Endif

Return lRet

/*/{Protheus.doc} ValidDel

@author  Felipe Raposo
@version P12.1.17
@since   24/04/2018
/*/
Static Function ValidDel()

	Local lRet := .T.

	DbSelectArea("FKD")
	DbSetOrder(1)  // FKD_FILIAL, FKD_CODIGO, FKD_IDDOC.

	If FKD->(dbSeek(FWxFilial() + FKC->FKC_CODIGO, .F.))
		Help( ,, "FINA035EXC",, STR0006, 1, 0,,,,,, {STR0011}) // "Não é possível excluir esse valor acessório, pois o mesmo já está vinculado a um título.", "Altere o valor acessório para inativo."
		lRet := .F.
	Endif

Return lRet

/*/{Protheus.doc} IntegDef
Função para integração via Mensagem Única Totvs.

@author  Felipe Raposo
@version P12
@since   03/04/2018
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Return FINI035LST(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
