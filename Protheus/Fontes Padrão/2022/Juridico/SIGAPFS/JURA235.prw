#INCLUDE "JURA235.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA235
Solicitação de Despesa

@author Jorge Luis Branco Martins Junior
@since 20/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA235()
Local oBrowse   := Nil
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0007) // "Solicitação de Despesa"
	oBrowse:SetAlias("NZQ")
	oBrowse:SetLocate()
	Iif(cLojaAuto == "1", JurBrwRev(oBrowse, "NZQ", {"NZQ_CLOJA"}), )
	oBrowse:SetFilterDefault("NZQ_CPART == '" + JURUSUARIO(__CUSERID) + "'")

	oBrowse:AddLegend("NZQ_SITUAC == '1'", "GREEN", JurInfBox('NZQ_SITUAC', '1')) // "Pendente"
	oBrowse:AddLegend("NZQ_SITUAC == '2'", "BLUE" , JurInfBox('NZQ_SITUAC', '2')) // "Aprovada"
	oBrowse:AddLegend("NZQ_SITUAC == '3'", "RED"  , JurInfBox('NZQ_SITUAC', '3')) // "Reprovada"

	JurSetLeg(oBrowse, "NZQ")
	JurSetBSize(oBrowse)
	J235Filter(oBrowse, cLojaAuto) // Adiciona filtros padrões no browse

	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J235Filter
Adiciona filtros padrões no browse

@param  oBrowse, objeto, browse da rotina

@author Reginaldo Borges / Cristina Cintra
@since  08/08/2022
/*/
//-------------------------------------------------------------------
Static Function J235Filter(oBrowse, cLojaAuto)
Local aFilNZQ1 := {}
Local aFilNZQ2 := {}
Local aFilNZQ3 := {}
Local aFilNZQ4 := {}
Local aFilNZQ5 := {}
Local aFilNZQ6 := {}
Local aFilNZQ7 := {}

	If cLojaAuto == "2"
		SAddFilPar("NZQ_CCLIEN", "==", "%NZQ_CCLIEN0%", @aFilNZQ1)
		SAddFilPar("NZQ_CLOJA", "==", "%NZQ_CLOJA0%", @aFilNZQ1)
		oBrowse:AddFilter(STR0049, 'NZQ_CCLIEN == "%NZQ_CCLIEN0%" .AND. NZQ_CLOJA == "%NZQ_CLOJA0%"', .F., .F., , .T., aFilNZQ1, STR0049) // "Cliente"
	Else
		SAddFilPar("NZQ_CCLIEN", "==", "%NZQ_CCLIEN0%", @aFilNZQ1)
		oBrowse:AddFilter(STR0049, 'NZQ_CCLIEN == "%NZQ_CCLIEN0%"', .F., .F., , .T., aFilNZQ1, STR0049) // "Cliente"
	EndIf

	SAddFilPar("NZQ_CCASO", "==", "%NZQ_CCASO0%", @aFilNZQ2)
	oBrowse:AddFilter(STR0051, 'NZQ_CCASO == "%NZQ_CCASO0%"', .F., .F., , .T., aFilNZQ2, STR0051) // "Caso"

	SAddFilPar("NZQ_CPART", "==", "%NZQ_CPART0%", @aFilNZQ3)
	oBrowse:AddFilter(STR0052, 'NZQ_CPART == "%NZQ_CPART0%"', .F., .F., , .T., aFilNZQ3, STR0052) // "Solicitante"

	SAddFilPar("NZQ_SITUAC", "==", "%NZQ_SITUAC0%", @aFilNZQ4)
	oBrowse:AddFilter(STR0053, 'NZQ_SITUAC == "%NZQ_SITUAC0%"', .F., .F., , .T., aFilNZQ4, STR0053) // "Situação"

	SAddFilPar("NZQ_DESPES", "==", "%NZQ_DESPES0%", @aFilNZQ5)
	oBrowse:AddFilter(STR0054, 'NZQ_DESPES == "%NZQ_DESPES0%"', .F., .F., , .T., aFilNZQ5, STR0054) // "Tipo"

	SAddFilPar("NZQ_DTINCL", ">=", "%NZQ_DTINCL0%", @aFilNZQ6)
	oBrowse:AddFilter(STR0055, 'NZQ_DTINCL >= "%NZQ_DTINCL0%"', .F., .F., , .T., aFilNZQ6, STR0055) // "Data Maior ou Igual a"

	SAddFilPar("NZQ_DTINCL", "<=", "%NZQ_DTINCL0%", @aFilNZQ7)
	oBrowse:AddFilter(STR0056, 'NZQ_DTINCL <= "%NZQ_DTINCL0%"', .F., .F., , .T., aFilNZQ7, STR0056) // "Data Menor ou Igual a"

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Jorge Luis Branco Martins Junior
@since 20/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA235", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA235", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA235", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA235", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA235", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Solicitação de Despesa

@author Jorge Luis Branco Martins Junior
@since 20/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView     := Nil
Local oModel    := FWLoadModel( "JURA235" )
Local oStruct   := FWFormStruct( 2, "NZQ" )
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lUtProj   := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se será utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = Não)
Local lContOrc  := SuperGetMv( "MV_JCONORC", .F., .F., ) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)

oStruct:RemoveField( "NZQ_CPART" )
oStruct:RemoveField( "NZQ_CODPRO" )
oStruct:RemoveField( "NZQ_CODRES" )
oStruct:RemoveField( "NZQ_DTAPRV" )
oStruct:RemoveField( "NZQ_APROVA" )
oStruct:RemoveField( "NZQ_DTEMSO" )
oStruct:RemoveField( "NZQ_DTEMCA" )
oStruct:RemoveField( "NZQ_DTEMAP" )
oStruct:RemoveField( "NZQ_EMSOLI" )
oStruct:RemoveField( "NZQ_EMCANC" )
oStruct:RemoveField( "NZQ_EMAPRO" )
oStruct:RemoveField( "NZQ_CTADES" )
oStruct:RemoveField( "NZQ_DCTADE" )
oStruct:RemoveField( "NZQ_SIGPRO" )
oStruct:RemoveField( "NZQ_NOMPRO" )
oStruct:RemoveField( "NZQ_CRATEI" )
oStruct:RemoveField( "NZQ_DRATEI" )
oStruct:RemoveField( "NZQ_FILLAN" )
oStruct:RemoveField( "NZQ_CLANC" )
oStruct:RemoveField( "NZQ_CPAGTO" )
oStruct:RemoveField( "NZQ_ITDES" )
oStruct:RemoveField( "NZQ_ITDPGT" )
If !lUtProj .And. !lContOrc .And. NZQ->(ColumnPos("NZQ_CPROJE")) > 0
	oStruct:RemoveField("NZQ_CPROJE")
	oStruct:RemoveField("NZQ_DPROJE")
	oStruct:RemoveField("NZQ_CITPRJ")
	oStruct:RemoveField("NZQ_DITPRJ")
EndIf

If NZQ->(FieldPos("NZQ_CODLD")) > 0
	oStruct:RemoveField('NZQ_CODLD')
EndIf

Iif(cLojaAuto == "1", oStruct:RemoveField( "NZQ_CLOJA" ), )

JurSetAgrp( 'NZQ',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA235_VIEW", oStruct, "NZQMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA235_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Solicitação de Despesa"
oView:EnableControlBar( .T. )

If !IsBlind()
	oView:AddUserButton( STR0040, "CLIPS", { | oView | JURANEXDOC("NZQ", "NZQMASTER", "", "NZQ_COD",,,,,,,,,, .T.) } ) // "Anexos"
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Solicitação de Despesa

@author Jorge Luis Branco Martins Junior
@since 20/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel      := NIL
Local oStructNZQ  := FWFormStruct( 1, "NZQ" )
Local oCommit     := JA235COMMIT():New()
Local bBlockFalse := FwBuildFeature( STRUCT_FEATURE_WHEN, ".F." )
Local lUtProj     := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se será utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = Não)
Local lContOrc    := SuperGetMv( "MV_JCONORC", .F., .F., ) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)
Local lIsRest     := (Iif(FindFunction("JurIsRest"), JurIsRest(), .F.))

If !lIsRest
	oStructNZQ:SetProperty( 'NZQ_REVISA', MODEL_FIELD_WHEN, bBlockFalse)
EndIf
If !lContOrc // Deve habilitar o ajuste via REST apenas se utilizado o Controle Orçamentário
	oStructNZQ:SetProperty( 'NZQ_CTADES', MODEL_FIELD_WHEN, bBlockFalse)
EndIf
oStructNZQ:SetProperty( 'NZQ_SIGPRO', MODEL_FIELD_WHEN, bBlockFalse)
oStructNZQ:SetProperty( 'NZQ_CRATEI', MODEL_FIELD_WHEN, bBlockFalse)
oStructNZQ:SetProperty( 'NZQ_MOTREP', MODEL_FIELD_WHEN, bBlockFalse)
If !lUtProj .And. !lContOrc .And. NZQ->(ColumnPos("NZQ_CPROJE")) > 0
	oStructNZQ:SetProperty( 'NZQ_CPROJE', MODEL_FIELD_WHEN, bBlockFalse)
	oStructNZQ:SetProperty( 'NZQ_CITPRJ', MODEL_FIELD_WHEN, bBlockFalse)
EndIf

oModel:= MPFormModel():New( "JURA235", /*Pre-Validacao*/, { |oModel| Jur235TOk(oModel, .F.) } /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NZQMASTER", NIL, oStructNZQ, /*Pre-Validacao*/, /*Pos-Validacao*/ )

J235MAnexo(@oModel, "NZQMASTER", "NZQ", "NZQ_COD") // Grid de Anexos

oModel:InstallEvent("JA235COMMIT", /*cOwner*/, oCommit)
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Solicitação de Despesa"
oModel:GetModel( "NZQMASTER" ):SetDescription( STR0009 ) //"Dados de Solicitação de Despesa"

JurSetRules( oModel, 'NZQMASTER',, 'NZQ' )
oModel:SetVldActivate( { |oModel| IIf(lIsRest .And. oModel:GetOperation() != MODEL_OPERATION_DELETE, .T., J235VldACT( oModel )) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J235MAnexo
Cria um grid para guardar os anexos quando a integração Rest estiver habilitada

@param oModel   , objeto    , Objeto do modelo
@param cIdOwner , caractere , Id do submodel
@param cEntidade, caractere , Alias da tabela do modelo master "NZQ"
@param cCampo   , caractere , Campo para criar o relation com a NUM

@author Jonatas Martins | Abner Fogaça
@since 05/07/2019
/*/
//-------------------------------------------------------------------
Function J235MAnexo(oModel, cIdOwner, cEntidade, cCampo)
	Local oStructNUM  := FWFormStruct(1, "NUM")
	Local bBlockFalse := FwBuildFeature(STRUCT_FEATURE_WHEN, ".F.")
	Local bBlockValid := FwBuildFeature(STRUCT_FEATURE_VALID, "J235VldAnx()")
	Local lJurClass   := FindFunction("JurHasClas") .And. JurHasClas()
	Local lWorkSite   := AllTrim(SuperGetMv("MV_JDOCUME", , "1")) == "1"

	Default oModel    := Nil
	Default cEntidade := ""
	
	oStructNUM:SetProperty("NUM_ENTIDA", MODEL_FIELD_OBRIGAT, .F.)
	If NUM->(ColumnPos("NUM_FILENT")) > 0
		oStructNUM:SetProperty("NUM_FILENT", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "xFilial('" + cEntidade + "')"))
		oStructNUM:SetProperty("NUM_FILENT", MODEL_FIELD_WHEN, bBlockFalse)
	EndIf
	oStructNUM:SetProperty("NUM_CENTID", MODEL_FIELD_OBRIGAT, .F.)
	oStructNUM:SetProperty("NUM_NUMERO", MODEL_FIELD_INIT   , FwBuildFeature(STRUCT_FEATURE_INIPAD, "CriaVar('ACB_CODOBJ', .T.)"))
	oStructNUM:SetProperty("NUM_DOC"   , MODEL_FIELD_VALID  , bBlockValid)
	oStructNUM:SetProperty("NUM_EXTEN" , MODEL_FIELD_VALID  , bBlockValid)
	oStructNUM:SetProperty("NUM_COD"   , MODEL_FIELD_WHEN   , bBlockFalse)
	oStructNUM:SetProperty("NUM_ENTIDA", MODEL_FIELD_WHEN   , bBlockFalse)
	oStructNUM:SetProperty("NUM_CENTID", MODEL_FIELD_WHEN   , bBlockFalse)
	oStructNUM:SetProperty("NUM_NUMERO", MODEL_FIELD_WHEN   , bBlockFalse)
	oStructNUM:SetProperty("NUM_MARK"  , MODEL_FIELD_WHEN   , bBlockFalse)
	
	oModel:AddGrid("NUMDETAIL", cIdOwner, oStructNUM, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/)
	
	If lJurClass .Or. lWorkSite
		oModel:SetRelation("NUMDETAIL", {{"NUM_FILIAL", "xFilial( 'NUM' )"}, {"NUM_ENTIDA", "'" + cEntidade + "'"}, {"NUM_FILENT", "xFilial('" + cEntidade + "')"}, {"NUM_CENTID", cCampo}}, NUM->(IndexKey(5)))
	Else
		oModel:SetRelation("NUMDETAIL", {{"NUM_FILIAL", "xFilial( 'NUM' )"}, {"NUM_ENTIDA", "'" + cEntidade + "'"}, {"NUM_CENTID", "xFilial('" + cEntidade + "') + " + cCampo}}, NUM->(IndexKey(3)))
	EndIf
	
	oModel:SetOptional("NUMDETAIL", .T.)
	oModel:GetModel("NUMDETAIL"):SetOnlyQuery(.T.) //Não efetua gravação do modelo

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J235VldAnx
Rotina para validar a linhas de anexos do submodelo 'NUM'

@Return lVldAnx, logico, Se .T. a validação está correta.

@author Jonatas Martins
@since 05/07/2019
/*/
//-------------------------------------------------------------------
Function J235VldAnx()
	Local oModel     := FWModelActive()
	Local oModelNUM  := oModel:GetModel("NUMDETAIL")
	Local lVldAnx    := .T.

	If oModelNUM:IsUpDated() .And. oModelNUM:GetDataID() > 0
		lVldAnx := .F.
		JurMsgErro(STR0033,, STR0034) // "O nome do arquivo e a extensão não podem ser alterados." "Caso necessário exclua o anexo e insira um novo."
	EndIf
	
Return (lVldAnx)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235Desc
Inicializador padrão do campo NZQ_DCASO

@Param cCampo Nome do campo que deve ter sua descrição retornada

@Return cRet Descrição do campo informado como parâmetro 

@author Jorge Luis Branco Martins Junior
@since 20/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235Desc(cCampo)
Local cRet   := ""

If cCampo == "NZQ_DCASO"
	cRet := Posicione('NVE', 1, xFilial('NVE') + NZQ->NZQ_CCLIEN + NZQ->NZQ_CLOJA + NZQ->NZQ_CCASO, 'NVE_TITULO')
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235VldCli
Validação dos campos de cliente, loja e caso.

@Return lRet Indica se os valores nos campos estão corretos (.T.) ou não (.F.)

@author Jorge Luis Branco Martins Junior
@since 20/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235VldCli()
Local lRet    := .T.
Local oModel  := FWModelActive()
Local cClien  := ''
Local cLoja   := ''
Local cCaso   := ''
Local cCampo  := AllTrim(__ReadVar)

	cClien  := oModel:GetValue("NZQMASTER", "NZQ_CCLIEN")
	cLoja   := oModel:GetValue("NZQMASTER", "NZQ_CLOJA")
	cCaso   := oModel:GetValue("NZQMASTER", "NZQ_CCASO")

	If (cCampo == "M->NZQ_CCLIEN")
		lRet := JurVldCli(, cClien, cLoja,,, "CLI")

	ElseIf (cCampo == "M->NZQ_CLOJA")
		lRet := JurVldCli(, cClien, cLoja,,, "LOJ")

	ElseIf(cCampo == "M->NZQ_CCASO")
		lRet := JurVldCli(, cClien, cLoja, cCaso, , "CAS")
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235NVEF3
Rotina para pesquisa de Caso

@Return cRet Expressão para filtro do caso

@author Jorge Luis Branco Martins Junior
@since 28/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235NVEF3()
Local cRet     := "@#@#"
Local cCliente := M->NZQ_CCLIEN
Local cLoja    := M->NZQ_CLOJA

If !Empty(cCliente) .And. !Empty(cLoja)
	cRet := "@#NVE->NVE_CCLIEN == '" + cCliente + "' .And. NVE->NVE_LCLIEN == '" + cLoja + "' @#"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235LmpCpo
Realiza a limpeza do conteúdo dos campos dos agrupamentos de 
cliente e escritório conforme a opção selecionada no campo NZQ_DESPES

@author Jorge Luis Branco Martins Junior
@since 02/05/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235LmpCpo()
Local oModelAct := FWModelActive()
Local oModel    := oModelAct:GetModel("NZQMASTER")

	If oModel:GetValue('NZQ_DESPES') == '1'
		oModel:ClearField("NZQ_CESCR")
		oModel:ClearField("NZQ_DESCR")
		oModel:ClearField("NZQ_GRPJUR")
		oModel:ClearField("NZQ_DGRJUR")
		oModel:ClearField("NZQ_CTADES")
		oModel:ClearField("NZQ_DCTADE")
		oModel:ClearField("NZQ_SIGPRO")
		oModel:ClearField("NZQ_CODPRO")
		oModel:ClearField("NZQ_NOMPRO")
		oModel:ClearField("NZQ_CRATEI")
		oModel:ClearField("NZQ_DRATEI")

	ElseIf oModel:GetValue('NZQ_DESPES') == '2'
		oModel:ClearField("NZQ_CCLIEN")
		oModel:ClearField("NZQ_CLOJA")
		oModel:ClearField("NZQ_DCLIEN")
		oModel:ClearField("NZQ_CCASO")
		oModel:ClearField("NZQ_DCASO")
		oModel:ClearField("NZQ_CTPDSP")
		oModel:ClearField("NZQ_DTPDSP")
		oModel:ClearField("NZQ_CLOCAL")
		oModel:ClearField("NZQ_DLOCAL")
		oModel:ClearField("NZQ_COBRAR")
		oModel:ClearField("NZQ_QTD")
		oModel:ClearField("NZQ_KM")

	Else
		oModel:ClearField("NZQ_CTPCTA")
		oModel:ClearField("NZQ_DTPCTA")
		oModel:ClearField("NZQ_CESCR")
		oModel:ClearField("NZQ_DESCR")
		oModel:ClearField("NZQ_GRPJUR")
		oModel:ClearField("NZQ_DGRJUR")
		oModel:ClearField("NZQ_CTADES")
		oModel:ClearField("NZQ_DCTADE")
		oModel:ClearField("NZQ_SIGPRO")
		oModel:ClearField("NZQ_CODPRO")
		oModel:ClearField("NZQ_NOMPRO")
		oModel:ClearField("NZQ_CCLIEN")
		oModel:ClearField("NZQ_CLOJA")
		oModel:ClearField("NZQ_DCLIEN")
		oModel:ClearField("NZQ_CCASO")
		oModel:ClearField("NZQ_DCASO")
		oModel:ClearField("NZQ_CTPDSP")
		oModel:ClearField("NZQ_DTPDSP")
		oModel:ClearField("NZQ_CLOCAL")
		oModel:ClearField("NZQ_DLOCAL")
		oModel:ClearField("NZQ_COBRAR")
		oModel:ClearField("NZQ_QTD")
		oModel:ClearField("NZQ_CRATEI")
		oModel:ClearField("NZQ_DRATEI")
		oModel:ClearField("NZQ_KM")
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur235TOk
Validação na gravação do modelo.
Verifica o preenchimento do Escritório e do Centro de Custo quando a 
despesa for do tipo Escritório.

@param  oModel  , objeto, Modelo de dados da Solcitação/Aprovação de Despesas
@param  lAprDesp, logico, Se .T. Indica que a rotina foi chamada na tela de 
	    aprovação de despesas.

@return lRet    , logico, Se .T. os dados são consistentes

@author Cristina Cintra Santos
@since  27/09/2017
/*/
//-------------------------------------------------------------------
Function Jur235TOk(oModel, lAprDesp)
Local lRet       := .T.
Local cSolucao   := ""
Local cProblema  := ""
Local cCampo     := ""
Local cTpConta   := ""
Local lContOrc   := SuperGetMv( "MV_JCONORC", .F., .F., ) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)

Local lIsRest    := (Iif(FindFunction("JurIsRest"), JurIsRest(), .F.))

Default lAprDesp := .F.

If oModel:GetOperation() != 5
	If oModel:GetValue("NZQMASTER", "NZQ_DESPES") == "1" // Despesa de Cliente
		If Empty(oModel:GetValue("NZQMASTER", "NZQ_CCLIEN"))
			cProblema := I18N(STR0026, {AllTrim(RetTitle('NZQ_CCLIEN'))}) + CRLF   // "O campo '#1' não foi preenchido."
		EndIf
		If Empty(oModel:GetValue("NZQMASTER", "NZQ_CLOJA"))
			cProblema += I18N(STR0026, {AllTrim(RetTitle('NZQ_CLOJA'))}) + CRLF   // "O campo '#1' não foi preenchido."
		EndIf
		If Empty(oModel:GetValue("NZQMASTER", "NZQ_CCASO"))
			cProblema += I18N(STR0026, {AllTrim(RetTitle('NZQ_CCASO'))}) + CRLF   // "O campo '#1' não foi preenchido."
		EndIf
		If Empty(oModel:GetValue("NZQMASTER", "NZQ_CTPDSP"))
			cProblema += I18N(STR0026, {AllTrim(RetTitle('NZQ_CTPDSP'))}) + CRLF   // "O campo '#1' não foi preenchido."
		EndIf
		If Empty(oModel:GetValue("NZQMASTER", "NZQ_COBRAR"))
			cProblema += I18N(STR0026, {AllTrim(RetTitle('NZQ_COBRAR'))}) + CRLF   // "O campo '#1' não foi preenchido."
		EndIf
		If Empty(oModel:GetValue("NZQMASTER", "NZQ_QTD"))
			cProblema += I18N(STR0026, {AllTrim(RetTitle('NZQ_QTD'))}) // "O campo '#1' não foi preenchido."
		EndIf

	ElseIf oModel:GetValue("NZQMASTER", "NZQ_DESPES") == "2" // Despesa de Escritório
		cProblema += J235VldTOk(oModel, lAprDesp)
	EndIf

	If Empty(oModel:GetValue("NZQMASTER", "NZQ_CPART"))
		cCampo    := IIf(IsBlind(), "NZQ_CPART", "NZQ_SIGLA") // Caso seja chamado via REST indica o campo de Código e não o de Sigla
		cProblema += I18N(STR0026, {AllTrim(RetTitle(cCampo))}) + CRLF // "O campo '#1' não foi preenchido."
	EndIf

	If lContOrc .And. NZQ->(ColumnPos("NZQ_CPROJE")) > 0 .And. !Empty(oModel:GetValue("NZQMASTER", "NZQ_CTADES"))
		cTpConta := JurGetDados("SED", 1, xFilial("SED") + oModel:GetValue("NZQMASTER", "NZQ_CTADES"), "ED_TPCOJR")
		If cTpConta $ "4|8"
			If Empty(oModel:GetValue("NZQMASTER", "NZQ_CPROJE"))
				cProblema += I18N(STR0026, {AllTrim(RetTitle('NZQ_CPROJE'))}) + CRLF   // "O campo '#1' não foi preenchido."
			EndIf
			If Empty(oModel:GetValue("NZQMASTER", "NZQ_CITPRJ"))
				cProblema += I18N(STR0026, {AllTrim(RetTitle('NZQ_CITPRJ'))}) + CRLF   // "O campo '#1' não foi preenchido."
			EndIf
		EndIf
	EndIf
	
	If Empty(cProblema) .And. oModel:GetOperation() == 3 .And. lIsRest .And. NZQ->(FieldPos( "NZQ_CODLD" )) > 0 .And. FindFunction("JurMsgCdLD")
		lRet := JurMsgCdLD(oModel:GetValue("NZQMASTER", "NZQ_CODLD"))
	EndIf
	
	If !Empty(cProblema)
		cSolucao  := STR0025 // "Preencha o(s) campo(s) citado(s) acima."
		JurMsgErro(cProblema,, cSolucao)
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235VldTOk
Valida dados dos campos relacionados a natureza

@param  oModel  , objeto, Modelo de dados da Solcitação/Aprovação de Despesas
@param  lAprDesp, logico, Se .T. Indica que a rotina foi chamada na tela de 
	    aprovação de despesas.

@return cMsgErro, caractere, Mensagem de erro caso exista

@author Jonatas Martins
@since  25/09/2019
/*/
//-------------------------------------------------------------------
Static Function J235VldTOk(oModel, lAprDesp)
	Local oModelNZQ  := oModel:GetModel("NZQMASTER")
	Local cNatureza  := oModelNZQ:GetValue("NZQ_CTADES")
	Local cTpConta   := JurGetDados("SED", 1, xFilial("SED") + cNatureza, "ED_TPCOJR")
	Local cCCJuriNat := ""
	Local cMsgErro   := ""
	
	If cTpConta != "1" // 1-Banco/Caixa
		cCCJuriNat := JurGetDados("SED", 1, xFilial("SED") + cNatureza, "ED_CCJURI")

		Do Case
			Case !lAprDesp .And. (Empty(oModelNZQ:GetValue("NZQ_CESCR")) .Or. Empty(oModelNZQ:GetValue("NZQ_GRPJUR"))) // Tela de solicitação de despesa JURA235
				cMsgErro := STR0042 // "Escritório ou centro de custo não preenchido! Preencha o escritório e centro de custo."

			Case !Empty(cCCJuriNat) .And. cCCJuriNat == "1" .And. Empty(oModelNZQ:GetValue("NZQ_CESCR")) //1=Escritório
				cMsgErro := STR0043 // "Escritório não preenchido! Preencha o escritório."

			Case !Empty(cCCJuriNat) .And. cCCJuriNat == "2" .And. (Empty(oModelNZQ:GetValue("NZQ_CESCR")) .Or. Empty(oModelNZQ:GetValue("NZQ_GRPJUR"))) //2=Escritório e C.C. Jurídico
				cMsgErro := STR0042 // "Escritório ou centro de custo não preenchido! Preencha o escritório e o centro de custo."

			Case !Empty(cCCJuriNat) .And. cCCJuriNat == "3" .And. Empty(oModelNZQ:GetValue("NZQ_SIGPRO")) //3=Profissional
				cMsgErro := STR0044 // "Profissional não preenchido! Preencha o profissional." // 

			Case !Empty(cCCJuriNat) .And. cCCJuriNat == "4" .And. Empty(oModelNZQ:GetValue("NZQ_CRATEI")) //4=Tabela de Rateio
				cMsgErro := STR0045 // "Tabela de rateio não preenchida! Preencha a tabela de rateio."
		End Case
	EndIf
	
Return (cMsgErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur235Valid
Função utilizada no Valid dos campos da NZQ.

@param  cCampo  Nome do campo que deve ter o when executado  

@author Jorge Luis Branco Martins Junior
@since 13/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function Jur235Valid(cCampo)
Local lRet       := .T.
Local cCliente   := ""
Local cLoja      := ""
Local cSituac    := ""
Local cRevisa    := ""
Local dDataRevis := CToD("")
Local lRestModel := .F.

Do Case
Case cCampo == "NZQ_CLOCAL"

	cCliente := FwFldGet("NZQ_CCLIEN")
	cLoja    := FwFldGet("NZQ_CLOJA")

	aCposNTP := JurGetDados("NTP", 1, xFilial("NTP") + FwFldGet("NZQ_CLOCAL"), {"NTP_CCLIEN", "NTP_CLOJA"})

	If Empty(aCposNTP)
		lRet := .F.
		JurMsgErro(STR0027,, STR0028) // #"Localidade não encontrada." ##"Informe um código de localidade válido."
	Else

		cCliNTP  := aCposNTP[1]
		cLojaNTP := aCposNTP[2]
		
		If !Empty(cCliNTP) .And. !Empty(cLojaNTP)
			If !(cCliente == cCliNTP .And. cLoja == cLojaNTP)
				lRet := .F.
				JurMsgErro(STR0029,, I18N(STR0030, {cCliente + "/" + cLoja})) // #"Localidade não pertence ao cliente/loja selecionado." ##"Informe uma localidade correspondente ao cliente/loja '#1'."
			EndIf
		EndIf
	
	EndIf

Case cCampo == "NZQ_SITUAC"

	cSituac    := FwFldGet("NZQ_SITUAC")
	lRestModel := FindFunction("JIsRestID") .And. JIsRestID("JURA235")

	If (!FwIsInCallStack("J235AUpdNZQ") .And. !Empty(cSituac) .And. cSituac != "1" ) .Or. lRestModel
		lRet := .F.
		JurMsgErro(STR0038,, STR0039) // #"Não é permitida a alteração da situação da solicitação de despesa." ## "Utilize as opções de aprovação e reprovação para alterar a situação da solicitação."
	EndIf

Case cCampo == "NZQ_DTREVI"

	dDataRevis := FwFldGet("NZQ_DTREVI")
	cRevisa    := FwFldGet("NZQ_REVISA")
	If (cRevisa == "1" .And. Empty(dDataRevis)) .Or. (dDataRevis > Date())
		lRet := .F.
		JurMsgErro(STR0047,, STR0048) // "Para lançamentos revisados, o preenchimento da data de revisão é obrigatório e não pode ser superior a data atual." # "Verifique o preenchimento da data de revisão da solicitação de despesa."
	EndIf

EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur235When
Função utilizada na condição When de campos (NZQ_CLOCAL e NZQ_KM) 
para verificar se o Tipo de Despesa utiliza Localidade.

@Param  Campo que está fazendo a chamada do When

@author Cristina Cintra Santos
@since 13/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function Jur235When(cCampo)
Local lRet      := .T.
Local oModel    := FWModelActive()
Local oModelNZQ := oModel:GetModel("NZQMASTER")
Local cCdTpDsp  := Alltrim(oModelNZQ:GetValue("NZQ_CTPDSP"))

If cCampo $ 'NZQ_CLOCAL|NZQ_KM'
	lRet := !Empty(oModelNZQ:GetValue("NZQ_CCLIEN")) .And. !Empty(oModelNZQ:GetValue("NZQ_CLOJA")) 
	
	If lRet .And. !Empty(cCdTpDsp)
		lRet := JurGetDados("NRH", 1, xFILIAL("NRH") + cCdTpDsp, "NRH_LOCALI") == "1"
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235CTPDSP
Gatilho para preencher a descricao da despesa baseada no idioma do caso.
Campo que dispara esse gatilho: NZQ_CTPDPD

@author Cristina Cintra
@since 13/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235CTPDSP()
Local oModel   := FWModelActive()
Local cClient  := oModel:GetValue("NZQMASTER", "NZQ_CCLIEN")
Local cLoja    := oModel:GetValue("NZQMASTER", "NZQ_CLOJA")
Local cCaso    := oModel:GetValue("NZQMASTER", "NZQ_CCASO")
Local cCodDsp  := oModel:GetValue("NZQMASTER", "NZQ_CTPDSP")
Local cIdio    := ""
Local cRet     := ""

cIdio := Posicione('NVE', 1, xFilial('NVE') + cClient + cLoja + cCaso, 'NVE_CIDIO')

If !Empty(cIdio)
	cRet := AllTrim(Posicione('NR4', 3, xFilial("NR4") + cCodDsp + cIdio, 'NR4_DESC'))
	If NR4->(ColumnPos('NR4_TXTPAD')) > 0 .And. !Empty(NR4->NR4_TXTPAD) // Proteção
		cRet := NR4->NR4_TXTPAD
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur235Valor
Função para cálculo do valor da despesa quando preenchida a quilometragem.
Usado em gatilhos dos campos NZQ_KM e NZQ_QTD.

@author Cristina Cintra
@since 13/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function Jur235Valor()
Local nValor    := 0
Local oModel    := FWModelActive()
Local nQtd      := 0
Local nKM       := 0
Local cCdTpDsp  := ""
Local nVlrUnit  := 0

If !Empty(oModel:GetValue("NZQMASTER", "NZQ_CLOCAL"))
	nQtd     := oModel:GetValue("NZQMASTER", "NZQ_QTD")
	nKM      := oModel:GetValue("NZQMASTER", "NZQ_KM")
	cCdTpDsp := oModel:GetValue("NZQMASTER", "NZQ_CTPDSP")
	nVlrUnit := JurGetDados("NRH", 1, xFILIAL("NRH") + cCdTpDsp, "NRH_VALORU")

	nValor   := nQtd * nKM * nVlrUnit
Else
	nValor   := oModel:GetValue("NZQMASTER", "NZQ_VALOR")
EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} J235NTPF3
Rotina para pesquisa de Localidades

@Return cRet Expressão para filtro do caso

@author Jorge Luis Branco Martins Junior
@since 13/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235NTPF3()
Local cRet     := "@#@#"
Local cCliente := M->NZQ_CCLIEN
Local cLoja    := M->NZQ_CLOJA

If !Empty(cCliente) .And. !Empty(cLoja)
	cRet := "@# ( NTP->NTP_CCLIEN == '" + cCliente + "' .And. NTP->NTP_CLOJA == '" + cLoja + "' ) .Or. "
	cRet +=   " ( Empty(NTP->NTP_CCLIEN) .And. Empty(NTP->NTP_CLOJA)) @#" 
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235VldAct()
Função de validação da ativação do modelo.

@param oModel  , Modelo de dados
@param lVldRest, Valida quando a execução é via REST
@param lAprova , Indica se a chamada é a partir da tela de Aprovação

@author bruno.ritter
@since 17/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235VldAct(oModel, lVldRest, lAprova)
Local lRet       := Iif(FindFunction("JurVldUxP"), JurVldUxP(oModel), .T.)
Local nOper      := oModel:GetOperation()
Local lIsRest    := FindFunction("JurIsRest") .And. JurIsRest()

Default lVldRest := !lIsRest .Or. nOper == MODEL_OPERATION_DELETE
Default lAprova  := .F.

If lRet .And. lVldRest
	If nOper == MODEL_OPERATION_UPDATE .Or. nOper == MODEL_OPERATION_DELETE
		If ( NZQ->NZQ_SITUAC != "1" .Or. ( NZQ->NZQ_REVISA == "1" .And. !lIsRest .And. !lAprova ) ) .And. !FwIsInCallStack("J235AtuDesd") //Solicitações aprovadas/reprovadas ou que já foram revisadas e não é LD nem tela de Aprovação, sendo alterada fora da 235
			lRet := .F.
			JurMsgErro(STR0031;    // "Não foi possível executar a operação para esta solicitação." 
			           ,, STR0032) // "Só é permitida esta operação para solicitações pendentes e não revisadas."
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235ClxCa()
Rotina para verificar se o cliente/loja pertece ao caso.
Utilizado para condição de gatilho

@Return - lRet  .T. quando o cliente PERTENCE ao caso informado OU
                .F. quando o cliente NÃO pertence ao caso informado

@author bruno.ritter
@since 18/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235ClxCa()
Local lRet      := .F.
Local oModel    := FWModelActive()
Local cClien    := ""
Local cLoja     := ""
Local cCaso     := ""

cClien := oModel:GetValue("NZQMASTER", "NZQ_CCLIEN")
cLoja  := oModel:GetValue("NZQMASTER", "NZQ_CLOJA")
cCaso  := oModel:GetValue("NZQMASTER", "NZQ_CCASO")

lRet := JurClxCa(cClien, cLoja, cCaso)

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA235COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Jorge Martins
@since 27/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA235COMMIT FROM FWModelEvent
	Method New()
	Method FieldPreVld()
	Method ModelPosVld()
    Method InTTS()
End Class

//-------------------------------------------------------------------
Method New() Class JA235COMMIT
Return

//-------------------------------------------------------------------
/*/ { Protheus.doc } FieldPreVld
Método que é chamado pelo MVC quando ocorrer as ações de pre validação 
do Model. Esse evento ocorre uma vez no contexto do modelo principal.

@param oModel  , Objeto   , Modelo principal
@param cModelId, Caractere, Id do submodelo
@param cAction , Caractere, Ação que foi executada no modelo (DELETE, SETVALUE)
@param cId     , Caractere, Campo que está sendo pré validado
@param xValue  , Aleatório, Novo valor para o campo

@author Abner Fogaça / Jonatas Martins
@since  26/06/2019
@Obs    Executa a função de validação ativação nesse momento somente quando for REST
        para verificar se o cabeçalho "NZQMASTER" poderá ser editável
        e sempre permitir a alteração do GRID de anexos
/*/
//-------------------------------------------------------------------
Method FieldPreVld(oModel, cModelId, cAction, cId, xValue) Class JA235COMMIT
	Local lMPreVld := .T.
	Local lVldRest := .F.
	Local lIsRest  := FindFunction("JurIsRest") .And. JurIsRest()
 
	If lIsRest .And. cAction == "SETVALUE"
		lVldRest := cModelId == "NZQMASTER" .Or. oModel:GetOperation() == MODEL_OPERATION_DELETE
		lMPreVld := J235VldACT(oModel, lVldRest)
	EndIf

Return (lMPreVld)

//-------------------------------------------------------------------
/*/ { Protheus.doc } ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model

@param  oSubModel, Objeto   , Sub-modelo que está sendo validado
@param  cModelId , Caractere, Id do submodelo

@author Abner Fogaça / Jonatas Martins
@since  26/06/2019
@Obs    Executa a função de validação ativação nesse momento somente quando for REST
        para verificar se o cabeçalho "NZQMASTER" poderá ser editável
        e sempre permitir a alteração do GRID de anexos
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oSubModel, cModelId) Class JA235COMMIT
	Local lIsRest  := FindFunction("JurIsRest") .And. JurIsRest()
	Local lMPosVld := .T.
	
	// Deve ser sempre a última função a ser executada
	If lIsRest .Or. oSubModel:GetOperation() == MODEL_OPERATION_DELETE // Não grava anexo quando vier da aprovação despesa
		lMPosVld := J235Anexo(oSubModel:GetModel(), "NZQ", "NZQMASTER", "NZQ_COD")
	EndIf

Return (lMPosVld)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações do commit. Após as gravações porém 
antes do final da transação.

@param  oSubModel, Objeto   , Sub-modelo que está sendo validado
@param  cModelId , Caractere, Id do submodelo

@author Abner Fogaça / Jonatas Martins
@since  26/06/2019
@Obs    Esse evento ocorre uma vez no contexto do modelo principal.
/*/
//-------------------------------------------------------------------
Method InTTS(oSubModel, cModelId) Class JA235COMMIT
	JFILASINC(oSubModel:GetModel(), "NZQ", "NZQMASTER", "NZQ_COD") // Fila de sincronização
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} J235Anexo
Percorre o submodelo de anexos 'NUM' chamar as funções de validação e gravação do anexo, dentro de uma transação.

@param oModel   , Objeto  , Objeto do modelo de dados
@param cEntidade, caractere, Alias da tabela
@param cIdModel , Caractere, Id do submodelo
@param cCampo   , caractere, Id do modelo
@param cComp    , caractere, Código do item do desdobramento ou campo complementar
@param cMsgAnexo, caractere, Mensagem de erro para o usuário

@Return lAnexo, logico, Se .T. conseguiu efetivar a gravação.

@author Jonatas Martins | Abner Fogaça
@since 02/07/19
/*/
//-------------------------------------------------------------------
Function J235Anexo(oModel, cEntidade, cIdModel, cCampo, cComp, cMsgAnexo)
	Local oSubModel   := oModel:GetModel(cIdModel)
	Local lGrid       := oSubModel:ClassName() == "FWFORMGRID"
	Local lAnexo      := .T.
	Local lIncluiDes  := Empty(oSubModel:GetValue(cCampo)) .And. (cEntidade == "OHF" .Or. cEntidade == "OHG")
	Local oModelNUM   := Nil
	Local cCodEnt     := ""
	Local cChave      := ""
	Local cIdDoc      := ""
	Local nOperation  := 0
	Local nLine       := 0

	Default cMsgAnexo := ""

	If lGrid
		If !oSubModel:IsEmpty()
			Begin Transaction
				For nLine := 1 To oSubModel:Length()
					oSubModel:GoLine(nLine) // Linha do Desdobramento/Desd.-Pós
					oModelNUM := oModel:GetModel("NUMDETAIL")
					If !oModelNUM:IsEmpty()
						lAnexo := J235VldNat(oSubModel:GetValue(cEntidade + "_CNATUR"), @cMsgAnexo) // Validação do Centro de custo jurídico da natureza
						If lAnexo
							nOperation := IIF(oSubModel:IsDeleted(), MODEL_OPERATION_DELETE, 0)
							
							If lIncluiDes // Gera Iddoc da OHF quando for POST
								cChave := SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA
								cIdDoc := FINGRVFK7('SE2', cChave)
							EndIf
							cCodEnt    := IIF(lIncluiDes, cIdDoc, oSubModel:GetValue(cCampo)) + IIF(Empty(cComp), "", AllTrim(oSubModel:GetValue(cComp)))
							lAnexo     := J235Anx(oModelNUM, cEntidade, cCodEnt, nOperation, @cMsgAnexo)
							If !lAnexo
								DisarmTransaction()
								Exit
							EndIf
						Else
							DisarmTransaction()
							Exit
						EndIf
					EndIf
				Next nLine
			End Transaction
		EndIf
	Else
		oModelNUM := oModel:GetModel("NUMDETAIL")
		If !oModelNUM:IsEmpty()
			nOperation := oModel:GetOperation()
			cCodEnt    := oModel:GetValue(cIdModel, cCampo) + IIF(Empty(cComp), "", AllTrim(oModel:GetValue(cIdModel, cComp)))
			lAnexo     := J235Anx(oModelNUM, cEntidade, cCodEnt, nOperation)
		EndIf
	EndIf

Return (lAnexo)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235VldNat
Bloqueia o anexo para desdobramentos onde o tipo da natureza é transitória

@param cNatureza, caractere, Código da natureza do desdobramento
@param cMsgAnexo, caractere, Mensagem de erro para o usuário

@Return lNatur, logico, Se .T. natureza não é transitória

@author Jonatas Martins | Abner Fogaça
@since 02/07/19
/*/
//-------------------------------------------------------------------
Static Function J235VldNat(cNatureza, cMsgAnexo)
	Local cCCJuri     := ""
	Local lNatur      := .T.

	Default cMsgAnexo := ""
	
	cCCJuri := JurGetDados("SED", 1, xFilial("SED") + cNatureza, "ED_CCJURI")

	If cCCJuri $ '6|7' // Centros de custos transitórios (pagamento ou pós pagamento)
		lNatur    := .F.
		cMsgAnexo := I18N(STR0036, {cNatureza}) // "Verifique a natureza : '#1' do desdobramento. Não é permitida a inclusão de anexo(s) para desdobramentos com naturezas transitórias de pagamento ou transitórias pós pagamento."
		JurMsgErro(STR0035, , cMsgAnexo) // "Não é possível anexar documentos neste desdobramento."
	EndIf

Return (lNatur)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235Anx
Efetiva a importação ou deleção dos anexos

@param oModelNUM , objeto   , Objeto do submodelo 'NUM'
@param cEntidade , caractere, Alias da tabela
@param cCodEnt   , caractere, Código da tabela (Solitação de despesa, lançamento ou desdobramento)
@param nOperation, numerico , Indica a operacao da linha do anexo
@param cMsgAnexo , caractere, Se exibe mensagem de erro

@Return lGrvAnex, logico, Se .T. efetivou a gravação do anexo

@author Jonatas Martins | Abner Fogaça
@since 03/07/19
/*/
//-------------------------------------------------------------------
Static Function J235Anx(oModelNUM, cEntidade, cCodEnt, nOperation, cMsgAnexo)
	Local lJurClass := FindFunction("JurHasClas") .And. JurHasClas()
	Local cParam    := AllTrim( SuperGetMv("MV_JDOCUME", , "1"))
	Local lWorkSite := cParam == "1"
	Local cFolder   := IIF(lJurClass, MsDocPath(), "") + "\"
	Local cFile     := ""
	Local cFilEnt   := ""
	Local cCodNUM   := ""
	Local cCodObj   := ""
	Local nLine     := 0
	Local aRetGrv   := {}
	Local lDelete   := .F.
	Local lGrvAnex  := .T.

	Default cMsgAnexo := ""
	
	lDelete := nOperation == MODEL_OPERATION_DELETE
	
	For nLine := 1 To oModelNUM:Length()
		oModelNUM:GoLine(nLine)

		cFile   := cFolder + Alltrim(oModelNUM:GetValue("NUM_DOC")) + Alltrim(oModelNUM:GetValue("NUM_EXTEN"))
		cFilEnt := xFilial(cEntidade)
			If oModelNUM:IsDeleted() .Or. lDelete // Não grava anexo quando vier da aprovação despesa
				cCodNUM  := oModelNUM:GetValue("NUM_COD")
				cCodObj  := oModelNUM:GetValue("NUM_NUMERO")
				aRetGrv  := J235DelAnx(cEntidade, cFilEnt, cCodEnt, cCodNUM, cCodObj)
				lGrvAnex := aRetGrv[1]
			
			// Entrará nesse trecho de inclusão somente quando for via LegalDesk
			ElseIf oModelNUM:IsInSerted() .Or. oModelNUM:GetDataID() == 0
				If lWorkSite
					cNomArq   := oModelNUM:GetValue("NUM_DOC")
					cExtencao := oModelNUM:GetValue("NUM_EXTEN")
					cDescArq  := oModelNUM:GetValue("NUM_DESC")
					aRetGrv   := J235GrvAnx(cEntidade, cFilEnt, cCodEnt, cNomArq, cExtencao, cDescArq, cParam)
					lGrvAnex  := aRetGrv[1]
				Else
					aRetGrv  := J026Anexar(cEntidade, cFilEnt, cCodEnt, "", cFile, .T.)
					lGrvAnex := aRetGrv[1]
				EndIf
			EndIf

			If !lGrvAnex
				If lWorkSite
					cMsgAnexo := AllTrim(aRetGrv[2])
				Else
					cMsgAnexo := AllTrim(aRetGrv[2]) + STR0037 + cFile // " - Falha ao copiar o arquivo: "
				EndIf
				JurMsgErro(cMsgAnexo)
				Exit
			EndIf
		
	Next nLine

Return (lGrvAnex)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235RepAnex
Replica os anexos no momento da aprovação da solicitação de despesas ou da baixa do título

@param cEntidade , caractere, Alias da tabela
@param cFilEnt   , caractere, Filial da tabela de origem
@param cCodEnt   , caractere, Código da tabela (Solitação de despesa, lançamento ou desdobramento)
@param cTitDes   , caractere, Chave do título SE2 (Origem do IDDOC)
@param cItemDes  , caractere, Código do item do desdobramento

@Return lReplica, logico, Se .T. efetivou as réplicas dos anexos

@author Jonatas Martins | Abner Fogaça
@since 03/07/19
/*/
//-------------------------------------------------------------------
Function J235RepAnex(cEntidade, cFilEnt, cCodEnt, cTitDes, cItemDes)
	Local aAreaNUM  := NUM->(GetArea())
	Local lJurClass := FindFunction("JurHasClas") .And. JurHasClas()
	Local lBaixaTit := FWIsInCallStack("JGrvBxPag")
	Local lDesPosPg := FWIsInCallStack("J247CMTAux")
	Local lRestDes  := FWIsInCallStack("J247OpLanc")
	Local aDados    := {}
	Local nArq      := 0
	Local lReplica  := .T.
	Local cQuery    := ""
	Local cIdDoc    := ""
	Local cArquivo  := ""
	Local cNomArq   := ""
	Local cExtencao := ""
	Local cDescArq  := ""
	Local cParam    := AllTrim( SuperGetMv("MV_JDOCUME", , "1"))
	Local lWorkSite := cParam == "1"

	Default cTitDes  := ""
	Default cItemDes := ""

	cQuery := "SELECT NUM.NUM_NUMERO, NUM.NUM_DOC, NUM.NUM_EXTEN, NUM.NUM_DESC"
	cQuery += "  FROM " + RetSqlName("NUM") + " NUM "
	If lBaixaTit // Gera lançamento na baixa
		cIdDoc := FINGRVFK7('SE2', cTitDes)

		cQuery += " INNER JOIN " + RetSqlName("OHF") + " OHF "
		cQuery +=    " ON OHF.OHF_FILIAL = '" + xFilial("OHF") + "'"
		cQuery +=   " AND OHF.OHF_IDDOC = '"  + cIdDoc + "'"
		cQuery +=   " AND OHF.OHF_CITEM = '"  + cItemDes + "'"

		cQuery += " WHERE NUM.NUM_FILIAL = '" + xFilial("NUM") + "'"
		cQuery += "   AND NUM.NUM_FILENT = '" + xFilial("OHF") + "'"
		cQuery +=   " AND NUM.NUM_ENTIDA = 'OHF'"
		If lJurClass .Or. lWorkSite
			cQuery +=   " AND NUM.NUM_CENTID = '" + cIdDoc + "' || '" + cItemDes + "'"
		Else
			cQuery +=   " AND NUM.NUM_CENTID = '" + xFilial("OHF") + "' || '" +  cIdDoc + "' || '" + cItemDes + "'"
		EndIf
		cQuery +=   " AND NUM.D_E_L_E_T_ = ' '"
		cQuery +=   " AND OHF.D_E_L_E_T_ = ' '"
	ElseIf lRestDes
		cIdDoc := FINGRVFK7('SE2', cTitDes)
		
		cQuery += " WHERE NUM.NUM_FILIAL = '" + xFilial("NUM") + "'"
		cQuery += "   AND NUM.NUM_FILENT = '" + xFilial("OHG") + "'"
		cQuery +=   " AND NUM.NUM_ENTIDA = 'OHG'"
		If lJurClass .Or. lWorkSite
			cQuery +=   " AND NUM.NUM_CENTID = '" + cIdDoc + "' || '" + cItemDes + "'"
		Else
			cQuery +=   " AND NUM.NUM_CENTID = '" + xFilial("OHG") + "' || '" +  cIdDoc + "' || '" + cItemDes + "'"
		EndIf
		cQuery +=   " AND NOT EXISTS "
		cQuery +=   "               (SELECT NUMB.R_E_C_N_O_ FROM " + RetSqlName("NUM") + " NUMB "
		cQuery +=   "                 WHERE NUMB.NUM_FILIAL = '" + xFilial("NUM") + "' "
		cQuery +=   "                   AND NUMB.NUM_FILENT = '" + cFilEnt + "' "
		cQuery +=   "                   AND NUMB.NUM_ENTIDA = '" + cEntidade + "' "
		cQuery +=   "                   AND NUMB.NUM_DOC    = NUM.NUM_DOC "
		cQuery +=   "                   AND NUMB.NUM_EXTEN  = NUM.NUM_EXTEN "
		If lJurClass .Or. lWorkSite
			cQuery +=   "               AND NUMB.NUM_CENTID = '" + cCodEnt + "' "
		Else
			cQuery +=   "               AND NUMB.NUM_CENTID = '" + cFilEnt + cCodEnt + "' "
		EndIf
		cQuery +=   "                   AND NUMB.D_E_L_E_T_ = ' ') "
		cQuery +=   " AND NUM.D_E_L_E_T_ = ' '
	Else 
		cQuery += " INNER JOIN " + RetSqlName("NZQ") + " NZQ "
		cQuery +=    " ON NZQ.NZQ_FILIAL = '" + xFilial("NZQ") + "'"
		cQuery +=   " AND NZQ.NZQ_FILLAN = '" + cFilEnt + "'"
		If cEntidade == "OHB" .And. !lDesPosPg // Lançamento
			cQuery +=   " AND NZQ.NZQ_CLANC = '" + cCodEnt + "'"
		ElseIf cEntidade == "OHF" // Desdobramento
			cQuery +=   " AND NZQ.NZQ_CPAGTO = '" + cTitDes + "'"
			cQuery +=   " AND NZQ.NZQ_ITDES = '" + cItemDes + "'"
		ElseIf cEntidade == "OHG" .Or. lDesPosPg // Desdobramento Pós
			cQuery +=   " AND NZQ.NZQ_CPAGTO = '" + cTitDes + "'"
			cQuery +=   " AND NZQ.NZQ_ITDPGT = '" + cItemDes + "'"
		EndIf
		cQuery += " WHERE NUM.NUM_FILIAL = '" + xFilial("NUM") + "'"
		cQuery += "   AND NUM.NUM_FILENT = '" + xFilial("NZQ") + "'"
		cQuery +=   " AND NUM.NUM_ENTIDA = 'NZQ'"
		If lJurClass .Or. lWorkSite
			cQuery +=   " AND NUM.NUM_CENTID = NZQ.NZQ_COD"
		Else
			cQuery +=   " AND NUM.NUM_CENTID = '" + xFilial("NZQ") + "' || NZQ.NZQ_COD "
		EndIf
		cQuery +=   " AND NUM.D_E_L_E_T_ = ' '"
		cQuery +=   " AND NZQ.D_E_L_E_T_ = ' '"
	EndIf
	
	aDados := JurSQL(cQuery, {"NUM_NUMERO", "NUM_DOC", "NUM_EXTEN", "NUM_DESC"})
	
	If !Empty(aDados)

		For nArq := 1 To Len(aDados)
			
			cNomArq   := AllTrim(aDados[nArq][2])
			cDescArq  := AllTrim(aDados[nArq][4])
			cExtencao := AllTrim(aDados[nArq][3])

			If lWorkSite
				lReplica := J235GrvAnx(cEntidade, cFilEnt, cCodEnt, cNomArq, cExtencao, cDescArq, cParam)[1]
				If !lReplica
					Exit
				EndIf
			Else
				cArquivo := IIF(lJurClass, MsDocPath(), "") + "\" + Alltrim(aDados[nArq][1])
				
				If J026Anexar(cEntidade, cFilEnt, cCodEnt, "", cArquivo, .T.)[1]
					lReplica := J235GrvAnx(cEntidade, cFilEnt, cCodEnt, cNomArq, cExtencao, cDescArq, cParam)[1]
				Endif
				
				If !lReplica
					Exit
				EndIf
			EndIf
		Next nArq

	EndIf

	RestArea(aAreaNUM)

Return (lReplica)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235DelAnx
Deleta todos os anexos vinculado a aprovação da solicitação de despesas ou da baixa do título

@param cEntidade , caractere, Alias da tabela
@param cFilEnt   , caractere, Filial da tabela de origem
@param cCodEnt   , caractere, Código da tabela (Solitação de despesa, lançamento ou desdobramento)
@param cCodNUM   , caractere, Código da tabela NUM
@param cCodObj   , caractere, Código gerado a partir da tabela NUM que relaciona com as tabelas ACB e AC9

@Return aRetDel, array, [1] Se .T. efetivou a exclusão dos anexos
                        [2] Mensage de erro ao deletar o arquivo

@author Jonatas Martins | Abner Fogaça
@since 03/07/19
/*/
//-------------------------------------------------------------------
Static Function J235DelAnx(cEntidade, cFilEnt, cCodEnt, cCodNUM, cCodObj)
	Local aAreaNUM  := NUM->(GetArea())
	Local aAreaACB  := ACB->(GetArea())
	Local aAreaAC9  := AC9->(GetArea())
	Local cParam    := AllTrim( SuperGetMv("MV_JDOCUME", , "1"))
	Local aRetDel   := {.T., ""}
	Local lRet      := .T.

	If cParam == "1" .Or. cParam == "2"// WorkSite ou Base de conhecimento
		NUM->(DbSetOrder(1)) // NUM_FILIAL+NUM_COD
		If NUM->(DbSeek(xFilial("NUM") + cCodNUM))
			RecLock("NUM", .F.)
			NUM->(DbDelete())
			NUM->(MsUnLock())
			lRet := NUM->(Deleted())
		EndIf
	EndIf

	If lRet .And. cParam == "2" // Base de conhecimento
		AC9->(DbSetOrder(1)) // AC9_FILIAL+AC9_CODOBJ+AC9_ENTIDA+AC9_FILENT+AC9_CODENT
		If AC9->(DbSeek(xFilial("AC9") + cCodObj + cEntidade + cFilEnt))
			RecLock("AC9", .F.)
			AC9->(DbDelete())
			AC9->(MsUnLock())
			lRet := AC9->(Deleted())
		EndIf

		If lRet
			ACB->(DbSetOrder(1)) // ACB_FILIAL+ACB_CODOBJ
			If ACB->(DbSeek(xFilial("ACB") + cCodObj))
				RecLock("ACB", .F.)
				ACB->(DbDelete())
				ACB->(MsUnLock())
				lRet := ACB->(Deleted())
			EndIf
		EndIf

		If lRet // Exclui o arquivo
			FErase(MsDocPath() + "\" + cCodObj)
		EndIf
	EndIf

	If lRet
		If FindFunction("JGrAnxFila") .And. JGrAnxFila(cEntidade) // Verifica se os anexos dessa entidade serão gravados na fila
			J170GRAVA("NUM", xFilial("NUM") + cCodNUM, "5") // Exclui registro de anexo na fila
		EndIf
	Else
		aRetDel := {.F., STR0046} // "Falha na exclusão do anexo"
	EndIf

	RestArea(aAreaAC9)
	RestArea(aAreaACB)
	RestArea(aAreaNUM)

Return (aRetDel)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235GrvAnx
Efetiva o relacionamento dos documentos contidos no Worksite com o registro do protheus.

@param cEntidade , caractere, Alias da tabela
@param cFilEnt   , caractere, Filial da tabela de origem
@param cCodEnt   , caractere, Código da tabela (Solitação de despesa, lançamento ou desdobramento)
@param cNomArq   , caractere, ID do arquivo gerado pelo WorkSite
@param cExtencao , caractere, Extensão do arquivo anexado
@param cDescArq  , caractere, Descrição do arquivo
@param cParam    , caractere, Identifica se é Worksite ou Base de conhecimento

@author  Abner Fogaça
@since   24/07/2019
/*/
//-------------------------------------------------------------------
Function J235GrvAnx(cEntidade, cFilEnt, cCodEnt, cNomArq, cExtencao, cDescArq, cParam)
	Local aAreaNUM  := NUM->( GetArea())
	Local aDados    := {.T., ""}
	Local cCodNUM   := ""
	Local cNumero   := ""
	Local nNewRecno := 0

	If cParam == "1" //WorkSite
		NUM->(DbSetOrder(4)) //NUM_FILIAL + NUM_DOC + NUM_ENTIDA + NUM_CENTID
		If !NUM->(DbSeek(xFilial('NUM') + PadR(cNomArq, TamSX3('NUM_DOC')[1]) + cEntidade + cCodEnt))
			cCodNUM := GetSXENum("NUM", "NUM_COD")
			cNumero := SubStr(cNomArq, At("document:", cNomArq) + 9, At(",", cNomArq) - (At("document:", cNomArq) + 9))
			
			RecLock( 'NUM', .T. )
			NUM->NUM_FILIAL := xFilial('NUM')
			NUM->NUM_COD    := cCodNUM
			NUM->NUM_FILENT := cFilEnt
			NUM->NUM_ENTIDA := cEntidade
			NUM->NUM_CENTID := cCodEnt
			NUM->NUM_DOC    := cNomArq
			NUM->NUM_NUMERO := cNumero
			NUM->NUM_DESC   := cDescArq
			NUM->NUM_EXTEN  := cExtencao

			NUM->(MsUnLock())
			aDados[1] := .T.
		Else
			aDados[1] := .F.
			aDados[2] := I18n(STR0041, {Alltrim(cDescArq)}) //"Erro ao anexar documento #1 ao Worksite"
		EndIf
	ElseIf cParam == "2" //Base de conhecimento
		nNewRecno := NUM->(LastRec())
		NUM->(DbGoTo(nNewRecno))
		cCodNUM := NUM->NUM_COD
		RecLock("NUM", .F.)
		NUM->NUM_DOC   := cNomArq
		NUM->NUM_EXTEN := cExtencao
		NUM->NUM_DESC  := cDescArq
		NUM->(MsUnLock())
	EndIf

	If aDados[1] .And. SuperGetMV("MV_JFSINC", .F., '2') == '1' .And. !FwIsInCallStack("J235Anx")
		If FindFunction("JGrAnxFila") .And. JGrAnxFila(cEntidade) // Verifica se os anexos dessa entidade serão gravados na fila
			// Fila de sincronização ativada e não for uma inclusão de anexo via LegalDesk
			J170GRAVA("NUM", xFilial("NUM") + cCodNUM, "3") // Grava registro de anexo na fila
		EndIf
	EndIf
	
	RestArea(aAreaNUM)

Return aDados
