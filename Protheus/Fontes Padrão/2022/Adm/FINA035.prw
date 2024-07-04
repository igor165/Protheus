#include "protheus.ch"
#include "fwmvcdef.ch"
#include "fweditpanel.ch"
#include "fina035.ch"

/*/{Protheus.doc} FINA035
Cadastro de Tipos de Valores Acess�rios

@author Mauricio Pequim Jr
@since�01/08/2016
@version P12.1.8
/*/
Function FINA035()

	Local oBrowse

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("FKC")
	oBrowse:SetDescription( STR0001 ) //"Cadastro de Tipos de Valores Acess�rios"
	oBrowse:AddLegend( "FKC_ATIVO == '1'", "GREEN", STR0007 ) //"Ativo"
	oBrowse:AddLegend( "FKC_ATIVO == '2'", "RED",   STR0008 ) //"Inativo"
	oBrowse:SetMenuDef( "FINA035" )
	oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Cadastro de Tipos de Valores Acess�rios

@author Mauricio Pequim Jr
@since�01/08/2016
@since�13/10/2015
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
Fun��o para validar a vari�vel cont�bil informada, n�o permitindo o uso da mesma vari�vel
em dois registros de valores acess�rios diferentes. Chamada do valid do campo FKC_VARCTB
e do adapter para valida��o de sequencial dispon�vel

@Return lRet, Indica se a vari�vel � v�lida

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

	//Se a vari�vel n�o foi informada, ent�o est� sendo chamada do valid do campo, portanto pega-se o valor definido no model
	Default cVarCTB := ""
	If Empty( cVarCTB )
		oModelVA := FWModelActive()
		cVarCTB  := oModelVA:GetValue("FKCMASTER", "FKC_VARCTB")
		oModelVA := Nil
	Endif

	//Se o valor n�o estiver vazio, ent�o verifica na tabela se essa vari�vel j� n�o foi utilizada para a filial logada
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

		//Se encontrou algum registro, ent�o retorna .F.
		If ( cAliasFKC )->( ! EOF() )
			lRet := .F.
			Help( ,, "FKCVARCTB",, STR0009 + ( cAliasFKC )->FKC_CODIGO, 1, 0,,,,,, {STR0010} ) //"Essa vari�vel j� est� em uso por outro valor acess�rio: ", "Defina outra vari�vel cont�bil."
		Endif
		( cAliasFKC )->( dbCloseArea() )

		If lRet .And. Subs(cVarCTB,1,1) $ "0123456789"
			lRet := .F.
			Help( ,, "VARCTBIN1",, STR0014+Chr(13)+Chr(10)+STR0015, 1, 0,,,,,, {STR0016} ) //"Express�o inv�lida!"### "Esse campo ser� utilizado para criar uma vari�vel dentro do Protheus, que poder� ser utilizada no processo de contabiliza��o. Portanto, n�o � poss�vel inici�-lo com n�meros."### "Digite uma express�o de acordo com as regra citada acima."
		Endif

		//Valida as vari�veis reservadas do sistema
		If lRet .and. Alltrim(cVarCTB) $ "PIS|COFINS|CSLL|IRF|ISS|INSS|JUROS1|JUROS2|MULTA1|MULTA2|DESC1|DESC2|CMONET1|CMONET2|VALOR|VALOR1|VALOR2|VALOR3|VALOR4|VALOR5|VALOR6|VALOR7|JUROS3|FO1VADI"
			lRet := .F.
			Help( ,, "VARCTBIN2",, STR0012, 1, 0,,,,,, {STR0013} ) //"A express�o utilizada � reservada para uso interno no m�dulo Financeiro."###"Por favor, utilize outra express�o"
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
		Help( ,, "FINA035EXC",, STR0006, 1, 0,,,,,, {STR0011}) // "N�o � poss�vel excluir esse valor acess�rio, pois o mesmo j� est� vinculado a um t�tulo.", "Altere o valor acess�rio para inativo."
		lRet := .F.
	Endif

Return lRet

/*/{Protheus.doc} IntegDef
Fun��o para integra��o via Mensagem �nica Totvs.

@author  Felipe Raposo
@version P12
@since   03/04/2018
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Return FINI035LST(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
