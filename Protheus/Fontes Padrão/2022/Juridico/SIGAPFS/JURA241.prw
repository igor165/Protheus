#INCLUDE "JURA241.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'FWMVCDEF.CH'

Static _aRecLanCtb := {} // Variavel para controlar lançamentos estornados por alterações

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA241
Tela de Lançamentos (entre Naturezas).

@author bruno.ritter
@since 07/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA241()
Local oBrowse   := Nil
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0007) // "Lançamentos"
	oBrowse:SetAlias("OHB")
	Iif(cLojaAuto == "1", JurBrwRev(oBrowse, "OHB", {"OHB_CLOJD"}), )
	oBrowse:SetLocate()
	oBrowse:SetMenuDef("JURA241")
	JurSetLeg( oBrowse, "OHB")
	JurSetBSize(oBrowse)
	J241Filter(oBrowse) // Adiciona filtros padrões no browse

	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J241Filter
Adiciona filtros padrões no browse

@param  oBrowse, objeto, browse da rotina

@author Reginaldo Borges
@since  08/08/2022
/*/
//-------------------------------------------------------------------
Static Function J241Filter(oBrowse)
Local aFilOHB1 := {}
Local aFilOHB2 := {}
Local aFilOHB3 := {}
Local aFilOHB4 := {}
Local aFilOHB5 := {}
Local aFilOHB6 := {}
Local aFilOHB7 := {}

	SAddFilPar("OHB_NATORI", "$", "%OHB_NATORI0%", @aFilOHB1)
	oBrowse:AddFilter(STR0064, 'ALLTRIM(UPPER("%OHB_NATORI0%")) $ UPPER(OHB_NATORI)', .F., .F., , .T., aFilOHB1, STR0064) // "Natureza origem"

	SAddFilPar("OHB_NATDES", "==", "%OHB_NATDES0%", @aFilOHB2)
	oBrowse:AddFilter(STR0065, 'ALLTRIM(UPPER("%OHB_NATDES0%")) $ UPPER(OHB_NATDES)', .F., .F., , .T., aFilOHB2, STR0065) // "Natureza destino"

	SAddFilPar("OHB_DTINCL", ">=", "%OHB_DTINCL0%", @aFilOHB3)
	oBrowse:AddFilter(STR0066, 'OHB_DTINCL >= "%OHB_DTINCL0%"', .F., .F., , .T., aFilOHB3, STR0066) // "Data Maior ou Igual a"

	SAddFilPar("OHB_DTINCL", "<=", "%OHB_DTINCL0%", @aFilOHB4)
	oBrowse:AddFilter(STR0067, 'OHB_DTINCL <= "%OHB_DTINCL0%"', .F., .F., , .T., aFilOHB4, STR0067) // "Data Menor ou Igual a"
	
	SAddFilPar("OHB_ORIGEM", "==", "%OHB_ORIGEM0%", @aFilOHB5)
	oBrowse:AddFilter(STR0068, 'OHB_ORIGEM == "%OHB_ORIGEM0%"', .F., .F., , .T., aFilOHB5, STR0068) // "Origem"

	SAddFilPar("OHB_CPAGTO", "$", "%OHB_CPAGTO0%", @aFilOHB6)
	oBrowse:AddFilter(STR0069, 'ALLTRIM(UPPER("%OHB_CPAGTO0%")) $ UPPER(OHB_CPAGTO)', .F., .F., , .T., aFilOHB6, STR0069) // "Número do Contas a Pagar"

	SAddFilPar("OHB_CRECEB", "$", "%OHB_CRECEB0%", @aFilOHB7)
	oBrowse:AddFilter(STR0070, '"%OHB_CRECEB0%" $ OHB_CRECEB', .F., .F., , .T., aFilOHB7, STR0070) // "Número da Fatura (CR)"

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

@author bruno.ritter
@since 07/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA241", 0, 2, 0, Nil } ) // "Visualizar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA241", 0, 3, 0, Nil } ) // "Incluir"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA241", 0, 4, 0, Nil } ) // "Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA241", 0, 5, 0, Nil } ) // "Excluir"
	aAdd( aRotina, { STR0063, "CTBC662"        , 0, 7, 0, Nil } ) // "Tracker Contábil"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA241", 0, 8, 0, Nil } ) // "Imprimir"
	aAdd( aRotina, { STR0071, "J241ExecCp()"   , 0, 9, 0, Nil } ) // "Copiar Lançamento"
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Lançamentos

@author bruno.ritter
@since 07/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel( "JURA241" )
Local oStructOHB := FWFormStruct( 2, "OHB" )
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lUtProj    := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se será utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = Não)
Local lContOrc   := SuperGetMv("MV_JCONORC", .F., .F.) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)
Local lHasPrjDes := X3Uso(GetSx3Cache("OHB_CPROJD", 'X3_USADO')) .And. X3Uso(GetSx3Cache("OHB_CITPRD", 'X3_USADO'))

	oStructOHB:RemoveField("OHB_CPART")
	oStructOHB:RemoveField("OHB_CPARTO")
	oStructOHB:RemoveField("OHB_CPARTD")
	oStructOHB:RemoveField("OHB_CDESPO")
	oStructOHB:RemoveField("OHB_CDESPD")
	oStructOHB:RemoveField("OHB_FILORI")
	oStructOHB:RemoveField("OHB_CUSINC")
	oStructOHB:RemoveField("OHB_CUSALT")
	oStructOHB:RemoveField("OHB_ORIGEM")
	oStructOHB:RemoveField("OHB_CMOEC")

	If OHB->(ColumnPos("OHB_DURFAT")) > 0 // Proteção
		oStructOHB:RemoveField("OHB_DURFAT")
	EndIf

	If OHB->(ColumnPos("OHB_DURTEL")) > 0 // Proteção
		oStructOHB:RemoveField("OHB_DURTEL")
	EndIf

	If OHB->(ColumnPos("OHB_CRECEB")) > 0 // Proteção
		oStructOHB:RemoveField("OHB_CRECEB")
	EndIf

	If OHB->(ColumnPos("OHB_VLNAC")) > 0 // Proteção
		oStructOHB:RemoveField("OHB_VLNAC")
	EndIf

	If OHB->(ColumnPos("OHB_CPAGTO")) > 0 // Proteção
		oStructOHB:RemoveField("OHB_CPAGTO")
		oStructOHB:RemoveField("OHB_ITDES")
		oStructOHB:RemoveField("OHB_ITDPGT")
		oStructOHB:RemoveField("OHB_SE5SEQ")
	EndIf

	If(cLojaAuto == "1") // Loja Automática
		oStructOHB:RemoveField( "OHB_CLOJD" )
	EndIf

	If !lUtProj .And. !lContOrc .And. OHB->(ColumnPos("OHB_CPROJE")) > 0
		oStructOHB:RemoveField("OHB_CPROJE")
		oStructOHB:RemoveField("OHB_DPROJE")
		oStructOHB:RemoveField("OHB_CITPRJ")
		oStructOHB:RemoveField("OHB_DITPRJ")

		If (lHasPrjDes)
			oStructOHB:RemoveField("OHB_CPROJD")
			oStructOHB:RemoveField("OHB_DPROJD")
			oStructOHB:RemoveField("OHB_CITPRD")
			oStructOHB:RemoveField("OHB_DITPRD")
		EndIf
	EndIf

	If OHB->(ColumnPos("OHB_DTCONT")) > 0 // Proteção
		oStructOHB:RemoveField("OHB_DTCONT")
	EndIf

	If OHB->(FieldPos("OHB_CODLD")) > 0
		oStructOHB:RemoveField('OHB_CODLD')
	EndIf

	If OHB->(ColumnPos("OHB_SEQCON")) > 0 // Proteção
		oStructOHB:RemoveField("OHB_SEQCON")
	EndIf

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "JURA241_VIEW", oStructOHB, "OHBMASTER" )
	oView:CreateHorizontalBox( "FORMFIELD", 100 )
	oView:SetOwnerView( "JURA241_VIEW", "FORMFIELD" )
	oView:SetDescription( STR0007 ) // "Lançamentos"
	oView:EnableControlBar( .T. )

	If !IsBlind()
		oView:AddUserButton( STR0056, "CLIPS", { | oView | JURANEXDOC("OHB", "OHBMASTER", "", "OHB_CODIGO",,,,,,,,,, .T.) } ) // "Anexos"
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Lançamentos

@author bruno.ritter
@since 07/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel      := Nil
Local oStructOHB  := FWFormStruct( 1, "OHB" )
Local oEvent      := JA241Event():New()
Local bBlockFalse := FwBuildFeature( STRUCT_FEATURE_WHEN, ".F." )
Local lUtProj     := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se será utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = Não)
Local lContOrc    := SuperGetMv("MV_JCONORC", .F., .F.) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)
Local lIsRest     := FindFunction("JurIsRest") .And. JurIsRest()
Local bCommit     := {|oModel| J241Cmmt(oModel)}
Local lHasPrjDes := X3Uso(GetSx3Cache("OHB_CPROJD", 'X3_USADO')) .And. X3Uso(GetSx3Cache("OHB_CITPRD", 'X3_USADO'))

	If !lUtProj .And. !lContOrc .And. OHB->(ColumnPos("OHB_CPROJE")) > 0
		oStructOHB:SetProperty( 'OHB_CPROJE', MODEL_FIELD_WHEN, bBlockFalse)
		oStructOHB:SetProperty( 'OHB_CITPRJ', MODEL_FIELD_WHEN, bBlockFalse)

		If (lHasPrjDes)
			oStructOHB:SetProperty( 'OHB_CPROJD', MODEL_FIELD_WHEN, bBlockFalse)
			oStructOHB:SetProperty( 'OHB_CITPRD', MODEL_FIELD_WHEN, bBlockFalse)
		EndIf
	EndIf

	oStructOHB:SetProperty( 'OHB_CESCRO', MODEL_FIELD_WHEN, {|oMdl| J241VldNat(oMdl:GetValue("OHB_NATORI"), "OHB_NATORI", "1") } )
	oStructOHB:SetProperty( 'OHB_CCUSTO', MODEL_FIELD_WHEN, {|oMdl| J241VldNat(oMdl:GetValue("OHB_NATORI"), "OHB_NATORI", "2") } )
	oStructOHB:SetProperty( 'OHB_SIGLAO', MODEL_FIELD_WHEN, {|oMdl| J241VldNat(oMdl:GetValue("OHB_NATORI"), "OHB_NATORI", "3") } )
	oStructOHB:SetProperty( 'OHB_CTRATO', MODEL_FIELD_WHEN, {|oMdl| J241VldNat(oMdl:GetValue("OHB_NATORI"), "OHB_NATORI", "4") } )

	oStructOHB:SetProperty( 'OHB_CESCRD', MODEL_FIELD_WHEN, {|oMdl| J241VldNat(oMdl:GetValue("OHB_NATDES"), "OHB_NATDES", "1") } )
	oStructOHB:SetProperty( 'OHB_CCUSTD', MODEL_FIELD_WHEN, {|oMdl| J241VldNat(oMdl:GetValue("OHB_NATDES"), "OHB_NATDES", "2") } )
	oStructOHB:SetProperty( 'OHB_SIGLAD', MODEL_FIELD_WHEN, {|oMdl| J241VldNat(oMdl:GetValue("OHB_NATDES"), "OHB_NATDES", "3") } )
	oStructOHB:SetProperty( 'OHB_CTRATD', MODEL_FIELD_WHEN, {|oMdl| J241VldNat(oMdl:GetValue("OHB_NATDES"), "OHB_NATDES", "4") } )

	oModel:= MPFormModel():New( "JURA241", /*Pre-Validacao*/, /*Pos-Validacao*/, bCommit,/*Cancel*/)
	oModel:AddFields( "OHBMASTER", Nil, oStructOHB, /*Pre-Validacao*/, /*Pos-Validacao*/ )

	J235MAnexo(@oModel, "OHBMASTER", "OHB", "OHB_CODIGO") // Grid de Anexos

	oModel:SetDescription( STR0008 ) // "Modelo de Dados de Lançamentos"
	oModel:GetModel( "OHBMASTER" ):SetDescription( STR0009 ) // "Dados de Lançamentos"
	oModel:InstallEvent("JA241Event", /*cOwner*/, oEvent)
	oModel:SetVldActivate( { |oModel| IIF(lIsRest .And. oModel:GetOperation() != MODEL_OPERATION_DELETE, .T., J241VldAct( oModel )) } )
	JurSetRules( oModel, 'OHBMASTER',, 'OHB' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J241VldAct
Função de validação da ativação do modelo.

@author bruno.ritter
@since 14/09/2017
@obs    Função executada na ativação do modelo ou na Pré-Validação
        do modelo quando for via REST
/*/
//-------------------------------------------------------------------
Static Function J241VldAct(oModel)
	Local lJura241 := FunName() == "JURA241" .Or. (FindFunction("JIsRestID") .And. JIsRestID("JURA241"))
	Local nOpc     := oModel:GetOperation()
	Local lRet     := Iif(FindFunction("JurVldUxP"), JurVldUxP(oModel), .T.) // Valida o participante relacionado ao usuário logado()
	Local lIsRest  := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)
	Local lCpoLote := OHB->(ColumnPos("OHB_LOTE")) > 0

	If lRet .And. lJura241 .And. (nOpc == MODEL_OPERATION_UPDATE .Or. nOpc == MODEL_OPERATION_DELETE)

		If (!lIsRest .And. OHB->OHB_ORIGEM <> "5") .Or. (lIsRest .And. OHB->OHB_ORIGEM <> "4") // DIGITADA
			lRet := JurMsgErro(STR0047,, STR0061) // "Operação não permitida, pois o lançamento foi gerado a partir de outra rotina." # "Verifique a origem do lançamento."
		EndIf	
	EndIf
	
	If lRet .And. lCpoLote .And. nOpc == MODEL_OPERATION_DELETE .And. OHB->OHB_ORIGEM != "8" .And. !Empty(OHB->OHB_LOTE)
		lRet := JurMsgErro(STR0059, , STR0060)//"Lançamento com lote de fechamento gerado!" # "Cancele o lote de fechamento antes de excluir o lançamento."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241ClxCa()
Rotina para verificar se o cliente/loja pertece ao caso.
Utilizado para condição de gatilho

@Return - lRet  .T. quando o cliente PERTENCE ao caso informado OU
.F. quando o cliente NÃO pertence ao caso informado

@author bruno.ritter
@since 07/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241ClxCa()
	Local lRet      := .F.
	Local oModel    := FWModelActive()
	Local cClien    := ""
	Local cLoja     := ""
	Local cCaso     := ""

	cClien := oModel:GetValue("OHBMASTER", "OHB_CCLID")
	cLoja  := oModel:GetValue("OHBMASTER", "OHB_CLOJD")
	cCaso  := oModel:GetValue("OHBMASTER", "OHB_CCASOD")

	lRet := JurClxCa(cClien, cLoja, cCaso)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA241WHEN
When dos campos da OHB - Lançamentos entre Naturezas

Centro de Custo Jurídico (cCCNatOrig || cCCNatDest)
1 - Escritório
2 - Escritório e Centro de Custos
3 - Profissional
4 - Tabela de Rateio
5 - Despesa Cliente
6 - Transitória de Pagamentos

@author bruno.ritter
@since 07/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA241WHEN()
	Local lRet       := .T.
	Local cCampo     := Alltrim(StrTran(ReadVar(), 'M->', ''))
	Local cMoedaO    := ""
	Local cMoedaD    := ""
	Local cNatOrig   := ""
	Local cNatDest   := ""
	Local oModel     := Nil
	Local lCpoLote   := OHB->(ColumnPos("OHB_LOTE"))  > 0

	If M->OHB_ORIGEM != "6" // Quando for com origem na Solicitação de Despesas, grava o que for enviado pela JURA241

		//----------------------//
		//Grupo Natureza Origem //
		//----------------------//
		If cCampo $ 'OHB_CESCRO'
			lRet :=  JurWhNatCC("1", "OHBMASTER", "OHB_NATORI", "OHB_CESCRO", "OHB_CCUSTO", "OHB_SIGLAO", "OHB_CTRATO")	
	
		ElseIf cCampo $ 'OHB_CCUSTO'
			lRet := JurWhNatCC("2", "OHBMASTER", "OHB_NATORI", "OHB_CESCRO", "OHB_CCUSTO", "OHB_SIGLAO", "OHB_CTRATO")
	
		ElseIf cCampo $ 'OHB_SIGLAO|OHB_CPARTO'
			lRet := JurWhNatCC("3", "OHBMASTER", "OHB_NATORI", "OHB_CESCRO", "OHB_CCUSTO", "OHB_SIGLAO", "OHB_CTRATO")
	
		ElseIf cCampo $ 'OHB_CTRATO'
			lRet := JurWhNatCC("4", "OHBMASTER", "OHB_NATORI", "OHB_CESCRO", "OHB_CCUSTO", "OHB_SIGLAO", "OHB_CTRATO")
	
		//----------------------//
		//Grupo Natureza Destino//
		//----------------------//
		ElseIf cCampo $ 'OHB_CESCRD'
			lRet := JurWhNatCC("1", "OHBMASTER", "OHB_NATDES", "OHB_CESCRD", "OHB_CCUSTD", "OHB_SIGLAD", "OHB_CTRATD")
	
		ElseIf cCampo $ 'OHB_CCUSTD'
			lRet := JurWhNatCC("2", "OHBMASTER", "OHB_NATDES", "OHB_CESCRD", "OHB_CCUSTD", "OHB_SIGLAD", "OHB_CTRATD")
	
		ElseIf cCampo $ 'OHB_SIGLAD|OHB_CPARTD'
			lRet := JurWhNatCC("3", "OHBMASTER", "OHB_NATDES", "OHB_CESCRD", "OHB_CCUSTD", "OHB_SIGLAD", "OHB_CTRATD")
	
		ElseIf cCampo $ 'OHB_CTRATD'
			lRet := JurWhNatCC("4", "OHBMASTER", "OHB_NATDES", "OHB_CESCRD", "OHB_CCUSTD", "OHB_SIGLAD", "OHB_CTRATD")
	
		//--------------//
		//Grupo Despesa //
		//--------------//
		ElseIf cCampo $ 'OHB_CCLID|OHB_CLOJD|OHB_QTDDSD|OHB_COBRAD|OHB_DTDESP|OHB_CTPDPD'
			lRet := JurWhNatCC("5", "OHBMASTER", "OHB_NATORI", , , , , "OHB_CCLID", "OHB_CLOJD", "OHB_CCASOD") .OR.;
			JurWhNatCC("5", "OHBMASTER", "OHB_NATDES", , , , , "OHB_CCLID", "OHB_CLOJD", "OHB_CCASOD")
	
		ElseIf cCampo $ 'OHB_CCASOD'
			lRet := JurWhNatCC("6", "OHBMASTER", "OHB_NATORI", , , , , "OHB_CCLID", "OHB_CLOJD", "OHB_CCASOD") .OR.;
			JurWhNatCC("6", "OHBMASTER", "OHB_NATDES", , , , , "OHB_CCLID", "OHB_CLOJD", "OHB_CCASOD")
	
		//----------------------//
		//Grupo Valor Lançamento//
		//----------------------//
		ElseIf cCampo $ 'OHB_COTAC'
			oModel   := FWModelActive()
			cNatOrig := oModel:GetValue("OHBMASTER", "OHB_NATORI")
			cNatDest := oModel:GetValue("OHBMASTER", "OHB_NATDES")
			cMoedaO  := JurGetDados('SED', 1, xFilial('SED') + cNatOrig, 'ED_CMOEJUR')
			cMoedaD  := JurGetDados('SED', 1, xFilial('SED') + cNatDest, 'ED_CMOEJUR')
			lRet     := !Empty(cMoedaO) .And. !Empty(cMoedaD) .And. ( (cMoedaO != cMoedaD) .OR. oModel:GetValue("OHBMASTER", "OHB_ORIGEM") $ "1|2|7" )
		EndIf
	
	EndIf

	If lCpoLote .And. cCampo $ 'OHB_CEVENT|OHB_NATORI|OHB_NATDES|OHB_DTLANC|OHB_VALOR|OHB_CMOELC'
		oModel   := FWModelActive()
		lRet := Empty(oModel:GetValue("OHBMASTER", "OHB_LOTE"))
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA241DESC
Retorna a descrição do caso. Chamado pelo inicializador padrão dos campos
OHB_DCASOD e OHB_DCASOO.

@Param  - cCampo    Nome do campo para busca dos dados de Cliente e Loja

@Return - cRet      Descrição/Assunto do Caso

@author Cristina Cintra
@since 07/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA241DESC(cCampo)
	Local cRet     := ""
	Default cCampo := ""

	If !Empty(cCampo)
		If cCampo == 'OHB_DCASOD'
			cRet := POSICIONE('NVE', 1, xFilial('NVE') + OHB->OHB_CCLID + OHB->OHB_CLOJD + OHB->OHB_CCASOD, 'NVE_TITULO')
		EndIf
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241FCasF
Filtro Caso para tabela OHB

@author bruno.ritter
@since 07/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241FCasF()
	Local cRet      := "@#@#"
	Local oModel    := FWModelActive()
	Local cClien    := ""
	Local cLoja     := ""
	Local cCampo    := ReadVar()

	If cCampo $ 'M->OHB_CCASOD'
		cClien := oModel:GetValue("OHBMASTER", "OHB_CCLID")
		cLoja  := oModel:GetValue("OHBMASTER", "OHB_CLOJD")
	EndIf

	cRet := "@# .T."
	If !Empty(cClien)
		cRet += " .And. NVE->NVE_CCLIEN == '" + cClien + "'"
	EndIf

	If !Empty(cLoja)
		cRet += " .And. NVE->NVE_LCLIEN == '" + cLoja+ "'"
	EndIf

	cRet += "@#"

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241CTPDSP
Gatilho para preencher a descricao da despesa baseada no idioma do caso.
Campo que dispara esse gatilho: OHB_CTPDPD

@author bruno.ritter
@since 09/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241CTPDSP(lInicPadrao)
	Local cClient := ""
	Local cLoja   := ""
	Local cCaso   := ""
	Local cIdio   := ""
	Local cRet    := ""
	Local cCodDsp := ""
	Local cCampo  := ReadVar()

	Default lInicPadrao := .F.

	If cCampo $ 'M->OHB_DTPDPD'
		cClient  := OHB->OHB_CCLID
		cLoja    := OHB->OHB_CLOJD
		cCaso    := OHB->OHB_CCASOD
		cCodDsp  := OHB->OHB_CTPDPD
	EndIf

	cIdio := Posicione('NVE', 1, xFilial('NVE') + cClient + cLoja + cCaso, 'NVE_CIDIO')

	If !Empty(cIdio)
		cRet  := Posicione('NR4', 3, xFilial("NR4") + cCodDsp + cIdio, 'NR4_DESC')
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA241VldOb
Validação dos campos obrigatórios do Tudo Ok do model

Centro de Custo Jurídico (cCCNatOrig || cCCNatDest)
1 - Escritório
2 - Centro de Custos
3 - Profissional
4 - Tabela de Rateio
5 - Despesa Cliente
6 - Transitória de Pagamentos

@author bruno.ritter
@since 09/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA241VldOb(oModel)
Local lRet       := .T.
Local cSolucErro := ""
Local cCmpErrObr := ""
Local cNatOrig   := oModel:GetValue("OHBMASTER", "OHB_NATORI")
Local cCCNatOrig := JurGetDados("SED", 1, xFilial("SED") + cNatOrig, "ED_CCJURI")
Local cNatDest   := oModel:GetValue("OHBMASTER", "OHB_NATDES")
Local cCCNatDest := JurGetDados("SED", 1, xFilial("SED") + cNatDest, "ED_CCJURI")
Local lHasPrjDes := X3Uso(GetSx3Cache("OHB_CPROJD", 'X3_USADO')) .And. X3Uso(GetSx3Cache("OHB_CITPRD", 'X3_USADO'))
Local cPrjDest   := Iif(lHasPrjDes,"OHB_CPROJD","OHB_CPROJE")
Local cItePrjDst := Iif(lHasPrjDes,"OHB_CITPRD","OHB_CITPRJ")

	If cCCNatOrig == "5" .Or. cCCNatDest == "5"
		Iif(Empty(oModel:GetValue("OHBMASTER", "OHB_CCLID")) , cCmpErrObr += "'" + RetTitle("OHB_CCLID")  + "', ", )
		Iif(Empty(oModel:GetValue("OHBMASTER", "OHB_CLOJD")) , cCmpErrObr += "'" + RetTitle("OHB_CLOJD")  + "', ", )
		Iif(Empty(oModel:GetValue("OHBMASTER", "OHB_CCASOD")), cCmpErrObr += "'" + RetTitle("OHB_CCASOD") + "', ", )
		Iif(Empty(oModel:GetValue("OHBMASTER", "OHB_CTPDPD")), cCmpErrObr += "'" + RetTitle("OHB_CTPDPD") + "', ", )
		Iif(Empty(oModel:GetValue("OHBMASTER", "OHB_QTDDSD")), cCmpErrObr += "'" + RetTitle("OHB_QTDDSD") + "', ", )
		Iif(Empty(oModel:GetValue("OHBMASTER", "OHB_COBRAD")), cCmpErrObr += "'" + RetTitle("OHB_COBRAD") + "', ", )
		Iif(Empty(oModel:GetValue("OHBMASTER", "OHB_DTDESP")), cCmpErrObr += "'" + RetTitle("OHB_DTDESP") + "', ", )
	EndIf

	If Empty(oModel:GetValue("OHBMASTER", "OHB_CHISTP")) .And. SuperGetMv("MV_JHISPAD", .F., .F.)
		cCmpErrObr += "'" + RetTitle("OHB_CHISTP") + "', "
	EndIf

	If Empty(cCmpErrObr)
		If cCCNatOrig != "5"
			lRet := JurVldNCC(oModel, "OHBMASTER", "OHB_NATORI", "OHB_CESCRO", "OHB_CCUSTO", "OHB_CPARTO", "OHB_SIGLAO", "OHB_CTRATO",,,,,,,,,, "OHB_CPROJE", "OHB_CITPRJ")
		EndIf

		If lRet .And. cCCNatDest != "5"
			lRet := JurVldNCC(oModel, "OHBMASTER", "OHB_NATDES", "OHB_CESCRD", "OHB_CCUSTD", "OHB_CPARTD", "OHB_SIGLAD", "OHB_CTRATD",,,,,,,,,, cPrjDest, cItePrjDst)
		EndIf
	Else
		cSolucErro := STR0019 + CRLF//"Preencha o(s) campo(s) abaixo:"
		cSolucErro += SubStr(cCmpErrObr, 1, Len(cCmpErrObr) - 2) + "."
		lRet       := JurMsgErro(STR0018,, cSolucErro) //"Existem campos obrigatórios que não foram preenchidos"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241MOEDA()
Consulta especifica de moeda do lançamento.

@author Luciano Pereira dos Santos
@since 24/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241MOEDA()
	Local lRet    := .T.
	Local oModel  := FWModelActive()
	Local aCampos := {'CTO_MOEDA','CTO_SIMB','CTO_DESC'}
	Local cMoedaO := JurGetDados('SED', 1, xFilial('SED') + oModel:GetValue("OHBMASTER", "OHB_NATORI"), 'ED_CMOEJUR')
	Local cMoedaD := JurGetDados('SED', 1, xFilial('SED') + oModel:GetValue("OHBMASTER", "OHB_NATDES"), 'ED_CMOEJUR')
	Local cFiltro := "CTO->CTO_BLOQ=='2' .AND. (CTO->CTO_MOEDA=='" + cMoedaO + "' .OR. CTO->CTO_MOEDA=='" + cMoedaD + "')"

	// Função genérica para consultas especificas
	lRet := JURSXB("CTO", "CTOOHB", aCampos, .T., .F., cFiltro)

	JurFreeArr(@aCampos)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241VLDMOE()
Validação para o cadastro de moeda do lançamento e cotação.

@author Luciano Pereira dos Santos
@since 24/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241VLDMOE()
	Local lRet    := .T.
	Local oModel  := FWModelActive()
	Local cCampo  := Alltrim(StrTran(ReadVar(), 'M->', ''))
	Local cMoedaO := ''
	Local cMoedaD := ''
	Local cMoedaL := ''

	If cCampo $ 'OHB_CMOELC'
		cMoedaL := oModel:GetValue("OHBMASTER", "OHB_CMOELC")
	ElseIf cCampo $ 'OHB_CMOEC'
		cMoedaL := oModel:GetValue("OHBMASTER", "OHB_CMOEC")
	EndIf

	If !Empty(cMoedaL)
		cAtivo := JurGetDados('CTO', 1, xFilial('CTO') + cMoedaL, 'CTO_BLOQ')

		If Empty(cAtivo)
			lRet    := JurMsgErro(STR0022,, STR0017) //#"O código de moeda não é valido." ##"Informe um código válido."
		EndIf

		If lRet .And. cAtivo != '2'
			lRet    := JurMsgErro(STR0023,, STR0017) //#"O código de moeda esta inativo." ##"Informe um código válido."
		EndIf

		If lRet
			cMoedaO := JurGetDados('SED', 1, xFilial('SED') + oModel:GetValue("OHBMASTER", "OHB_NATORI"), 'ED_CMOEJUR')
			cMoedaD := JurGetDados('SED', 1, xFilial('SED') + oModel:GetValue("OHBMASTER", "OHB_NATDES"), 'ED_CMOEJUR')
			lRet    := (cMoedaL $ cMoedaO + '|' + cMoedaD) .Or. oModel:GetValue("OHBMASTER", "OHB_ORIGEM") $ "1|2|7" // Se NÃO for Contas a Pagar | Contas a Receber | Extrato

			If !lRet
				JurMsgErro(STR0022,, STR0024) //#"O código de moeda não é valido." ##"A moeda do lançamento deve ser a mesma utilizada na natureza de origem ou de destino."
			EndIf
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241MoeLac()
Rotina para verificar se a moeda/descrição do lançamento deve
ser alterada quando a natureza de destino for alterada.

@author Bruno Ritter
@since 22/12/2017
/*/
//-------------------------------------------------------------------
Function J241MoeLac()
	Local cRet    := ""
	Local oModel  := FWModelActive()
	Local cMoedaL := oModel:GetValue("OHBMASTER","OHB_CMOELC")
	Local cMoedaO := JurGetDados('SED', 1, xFilial('SED') + oModel:GetValue("OHBMASTER", "OHB_NATORI"), 'ED_CMOEJUR')
	Local cMoedaD := JurGetDados('SED', 1, xFilial('SED') + oModel:GetValue("OHBMASTER", "OHB_NATDES"), 'ED_CMOEJUR')

	cRet := Iif(cMoedaL == cMoedaO .Or. cMoedaL == cMoedaD, cMoedaL, cMoedaO)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241MoeCot()
Rotina para retornar a moeda da cotação.

@author Luciano Pereira dos Santos
@since 25/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241MoeCot()
	Local cRet    := ''
	Local oModel  := FWModelActive()
	Local cMoedaN := SuperGetMv('MV_JMOENAC',, '01')
	Local cMoedaL := oModel:GetValue("OHBMASTER", "OHB_CMOELC")
	Local cMoedaO := JurGetDados('SED', 1, xFilial('SED') + oModel:GetValue("OHBMASTER", "OHB_NATORI"), 'ED_CMOEJUR')
	Local cMoedaD := JurGetDados('SED', 1, xFilial('SED') + oModel:GetValue("OHBMASTER", "OHB_NATDES"), 'ED_CMOEJUR')

	If !Empty(cMoedaL)

		If cMoedaL == cMoedaN
			If cMoedaL == cMoedaO .And. cMoedaO != cMoedaD
				cRet := cMoedaD
			ElseIf cMoedaL == cMoedaD .And. cMoedaO != cMoedaD
				cRet := cMoedaO
			ElseIf cMoedaL <> cMoedaD 
				cRet := cMoedaD
			EndIf
		ElseIf cMoedaL == cMoedaO
			If cMoedaO != cMoedaD
				cRet := cMoedaD
			EndIf
		ElseIf cMoedaL == cMoedaD
			If cMoedaO != cMoedaD
				cRet := cMoedaO
			EndIf
		ElseIf cMoedaL <> cMoedaD 
			cRet := cMoedaD
		EndIf
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241ConvNC()
Rotina para retornar o valor do lançamento na moeda nacional

@Return nRet Valor convertido na moeda nacional

@author Bruno Ritter
@since 30/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241ConvNC()
	Local nRet      := 0
	Local oModel    := FWModelActive()
	Local cMoedaL   := oModel:GetValue("OHBMASTER", "OHB_CMOELC")
	Local nValorL   := oModel:GetValue("OHBMASTER", "OHB_VALOR")
	Local cMoedaC   := oModel:GetValue("OHBMASTER", "OHB_CMOEC")
	Local nValorC   := oModel:GetValue("OHBMASTER", "OHB_VALORC")
	Local dDataLanc := oModel:GetValue("OHBMASTER", "OHB_DTLANC")
	Local cMoedaNac := SuperGetMv('MV_JMOENAC',, '01' ) // Moeda Nacional
	Local nTaxa     := 0

	Do Case
		Case cMoedaL == cMoedaNac
			nRet := nValorL

		Case cMoedaC == cMoedaNac
			nRet := nValorC

		Otherwise
			nTaxa := J201FCotDia(cMoedaL, cMoedaNac, dDataLanc, xFilial("CTP"))[1]
			nRet  := IIF(nTaxa > 0, Round(nTaxa * nValorL, TamSX3('OHB_VLNAC')[2]), nValorL)
	EndCase

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241VlConv(cTipo)
Rotina para retornar o fator de conversão ou o valor convertido.

@Param cTipo Se '1' retona o fator; se '2' retorna o valor convertido.

@Return nRet Ver cTipo

@author Luciano Pereira dos Santos
@since 25/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241VlConv(cTipo)
	Local nRet      := 0
	Local oModel    := FWModelActive()
	Local cMoedaL   := oModel:GetValue("OHBMASTER", "OHB_CMOELC")
	Local cMoedaC   := oModel:GetValue("OHBMASTER", "OHB_CMOEC")
	Local nValorL   := oModel:GetValue("OHBMASTER", "OHB_VALOR")
	Local dDataLanc := oModel:GetValue("OHBMASTER", "OHB_DTLANC")
	Local nDecimal  := 0
	Local nCotac    := 0

	If cTipo == '1'
		nDecimal := TamSX3('OHB_COTAC')[2]
		nRet     := Val(cValToChar(DEC_RESCALE(JA201FConv(cMoedaC, cMoedaL, 10, '8', dDataLanc, , , , , , '2')[5], nDecimal, 0)))
	ElseIf cTipo == '2'
		nDecimal := TamSX3('OHB_VALORC')[2]
		If !Empty(cMoedaC) .And. cMoedaC != cMoedaL
			nCotac   := oModel:GetValue("OHBMASTER", "OHB_COTAC")
			nRet     := Round(nValorL * nCotac, nDecimal)
		EndIf
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241Event()
Rotina para retornar o fator de conversão ou o valor convertido.

@Return lRet Retorna .T. se o evento for válido.

@author Luciano Pereira dos Santos
@since 28/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241Event()
	Local lRet     := .T.
	Local oModel   := FWModelActive()
	Local cEvent   := oModel:GetValue("OHBMASTER", "OHB_CEVENT")
	Local cLanc    := JurGetDados('OHC', 1, xFilial('OHC') + cEvent, 'OHC_LANCAM')

	If Empty(cLanc)
		lRet := JurMsgErro(STR0025,, STR0017) //#"O código do evento não é valido." ##"Informe um código válido."
	EndIf

	If lRet .And. cLanc != '1'
		lRet := JurMsgErro(STR0025,, STR0026) //#"O código do evento não é valido." ##"Informe um evento que permita a inclusão de lançamentos."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241AtuSal
Função para retorna os parâmetros da função AtuSldNat() que inclui valores no saldo das Naturezas (contas)

@param oModel   => Modelo
@param lEstorno => Se a operação será um estorno

@obs Importatne, essa função deve ser executada antes do commit para o estorno e Depois do commit para quando não for estorno

@Return Parâmetros AtuSldNat(
cNatureza,; // 1 -> Codigo da natureza em que o saldo sera atualizado
dData,;     // 2 -> Data em que o saldo deve ser atualizado
cMoeda,;    // 3 -> Codigo da moeda do saldo
cTipoSld,;  // 4 -> Tipo de saldo (1=Orcado, 2=Previsto, 3=Realizado)
cCarteira,; // 5 -> Código da carteira (P=Pagar, R=Receber)
nValor,;    // 6 -> Valor que atualizara o saldo na moeda do saldo
nVlrCor,;   // 7 -> Valor que atualizara o saldo na moeda corrente
cSinal,;    // 8 > Sinal para atualização "+" ou "-"
cPeriodo,;  // 9 -> Saldo a ser atualizado (D = Diário, M = Mensal, NIL = Ambos (importante apenas no recalculo)
cOrigem,;   // 10 -> Rotina de Origem do movimento de fluxo de caixa. Ex. FUNNAME()
cAlias,;    // 11-> Alias onde ocorreu a movimentação de fluxo de caixa. Ex. SE2
nRecno,;    // 12 -> Número do registro no alias onde ocorreu a movimentação de fluxo de caixa.
nOpcRot,;   // 13 -> Opção de manipulação da rotina de origem da chamada da função AtuSldNat()
cTipoDoc,;  // 14 -> Tipo do documento E5_TIPODOC
nVlAbat)    // 15 -> Valor de abatimento E5_ABATI

@author bruno.ritter
@since 23/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J241AtuSal(oModel, lEstorno)
	Local aArea      := GetArea()
	Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01')
	Local cTpContO   := ""
	Local cMoedaO    := ""
	Local cTpContD   := ""
	Local cMoedaD    := ""

	Local cNaturezaO := "" // Código da natureza de origem
	Local cNaturezaD := "" // Código da natureza de destino

	Local cCodLanc   := oModel:GetValue("OHBMASTER", "OHB_CODIGO")
	Local cMoedaLanc := "" // OHB_CMOELC
	Local nValorLanc := 0  // OHB_VALOR
	Local nValorCot  := 0  // OHB_VALORC
	Local aRetNatO   := {} // Dados da Natureza de Origem
	Local aRetNatD   := {} // Dados da Natureza de Destino

	Local aRet       := {}
	Local aRetVerAtu := {}
	Local lAtuOrigem := .T.
	Local lAtuDestin := .T.
	Local lAtuSaldo  := .T.
	Local dDataLan   := Nil
	Local nRecno     := 0
	Local nOper      := oModel:GetOperation()

	Default lEstorno := .F.

	If nOper == MODEL_OPERATION_UPDATE
		aRetVerAtu := J241VerAtu(oModel) // Verifica se deve atualizar o saldo quando for alteração
		lAtuOrigem := aRetVerAtu[1]
		lAtuDestin := aRetVerAtu[2]
		lAtuSaldo  := lAtuOrigem .Or. lAtuDestin
	EndIf

	If lAtuSaldo
		OHB->(DbSetOrder(1)) // OHB_FILIAL+OHB_CODIGO
		OHB->(DbSeek(xFilial("OHB") + cCodLanc))

		If nOper == MODEL_OPERATION_UPDATE .Or. nOper == MODEL_OPERATION_DELETE
			nRecno := OHB->(Recno()) // Em operação de insert, esse parâmetro tem que ser preenchido dentro da transação (InTTS)
		EndIf

		If lEstorno
			cNaturezaO := OHB->OHB_NATORI
			cNaturezaD := OHB->OHB_NATDES
			cMoedaLanc := OHB->OHB_CMOELC
			nValorLanc := OHB->OHB_VALOR
			dDataLan   := OHB->OHB_DTLANC
			nValorCot  := OHB->OHB_VALORC
		Else
			cNaturezaO := oModel:GetValue("OHBMASTER", "OHB_NATORI")
			cNaturezaD := oModel:GetValue("OHBMASTER", "OHB_NATDES")
			cMoedaLanc := oModel:GetValue("OHBMASTER", "OHB_CMOELC")
			nValorLanc := oModel:GetValue("OHBMASTER", "OHB_VALOR")
			dDataLan   := oModel:GetValue("OHBMASTER", "OHB_DTLANC")
			nValorCot  := oModel:GetValue("OHBMASTER", "OHB_VALORC")
		EndIf

		If lAtuSaldo
			aRetNatO   := JurGetDados("SED", 1, xFilial("SED") + cNaturezaO, {"ED_TPCOJR", "ED_CMOEJUR"})
			aRetNatD   := JurGetDados("SED", 1, xFilial("SED") + cNaturezaD, {"ED_TPCOJR", "ED_CMOEJUR"})

			If Len(aRetNatO) == 2 .And. Len(aRetNatD) == 2
				cTpContO   := aRetNatO[1]
				cMoedaO    := aRetNatO[2]
				cTpContD   := aRetNatD[1]
				cMoedaD    := aRetNatD[2]

				aRet := J241Params(nOper, lEstorno, lAtuOrigem, cTpContO, cMoedaO, cNaturezaO, lAtuDestin, cTpContD, cMoedaD, cNaturezaD,;
				cMoedaLanc, cMoedaNac, nValorLanc, dDataLan, nValorCot, nRecno)
			EndIf

		EndIf
	EndIf

	RestArea(aArea)

	JurFreeArr(@aRetVerAtu)
	JurFreeArr(@aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241Params
Função para retorna os parâmetros da função AtuSldNat() que inclui valores no saldo das Naturezas (contas)

@param nOper      => Operação do modelo
@param lEstorno   => Se a operação será um estorno
@param lAtuO      => .T. - Atualiza origem
@param cTpContO   => Tipo conta natureza origem
@param cMoedaO    => Moeda natureza origem
@param cNatO      => Código natureza origem
@param lAtuD      => .T. - Atualiza destino
@param cTpContD   => Tipo conta Natureza destino
@param cMoedaD    => Moeda natureza destino
@param cNatD      => Código natureza destino
@param cMoedaLanc => Moeda do lançamento
@param cMoedaNac  => Moeda nacional
@param nValorLanc => Valor do lançamento
@param dDataLan   => Data do lançamento
@param nValorCot  => Valor Cotação
@param nRecno     => Recno tabela OHB

@obs Importatne, essa função deve ser executada antes do commit para o estorno e Depois do commit para quando não for estorno

@Return aRet[1] - Parametros para atualizar o saldo da natureza de origem
aRet[1][1] cNatureza,; // 1 -> Codigo da natureza em que o saldo sera atualizado
aRet[1][2] dData,;     // 2 -> Data em que o saldo deve ser atualizado
aRet[1][3] cMoeda,;    // 3 -> Codigo da moeda do saldo
aRet[1][4] cTipoSld,;  // 4 -> Tipo de saldo (1=Orcado, 2=Previsto, 3=Realizado)
aRet[1][5] cCarteira,; // 5 -> Código da carteira (P=Pagar, R=Receber)
aRet[1][6] nValor,;    // 6 -> Valor que atualizara o saldo na moeda do saldo
aRet[1][7] nVlrCor,;   // 7 -> Valor que atualizara o saldo na moeda corrente
aRet[1][8] cSinal,;    // 8 > Sinal para atualização "+" ou "-"
aRet[1][9] cPeriodo,;  // 9 -> Saldo a ser atualizado (D = Diário, M = Mensal, NIL = Ambos (importante apenas no recalculo)
aRet[1][10] cOrigem,;   // 10 -> Rotina de Origem do movimento de fluxo de caixa. Ex. FUNNAME()
aRet[1][11] cAlias,;    // 11-> Alias onde ocorreu a movimentação de fluxo de caixa. Ex. SE2
aRet[1][12] nRecno,;    // 12 -> Número do registro no alias onde ocorreu a movimentação de fluxo de caixa.
aRet[1][13] nOpcRot,;   // 13 -> Opção de manipulação da rotina de origem da chamada da função AtuSldNat()
aRet[1][14] cTipoDoc,;  // 14 -> Tipo do documento E5_TIPODOC
aRet[1][15] nVlAbat)    // 15 -> Valor de abatimento E5_ABATI

aRet[2] - Parametros para atualizar o saldo da natureza de destino
Idem Origem

@author abner.oliveira
@since 08/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241Params(nOper, lEstorno, lAtuO, cTpContO, cMoedaO, cNatO, lAtuD, cTpContD, cMoedaD, cNatD, cMoedaLanc, cMoedaNac, nValorLanc, dDataLan, nValorCot, nRecno)
	Local cSinal     := Iif(lEstorno, "-", "+") // ED_TPCOJR
	Local cCarteiraO := "" // Se o parâmetro cSinal for "+", considerar R=Receber, caso contrário considerar P=Pagar
	Local cCarteiraD := "" // Se o parâmetro cSinal for "+", considerar R=Receber, caso contrário considerar P=Pagar
	Local nValorO    := 0  // Valor na moeda da natureza de Origem (Se atentar a conversão)
	Local nValorD    := 0  // Valor na moeda da natureza de Destino (Se atentar a conversão)
	Local nVlrCor    := 0  // Valor na moeda nacional
	Local aRetParamO := ARRAY(15) // Parâmetros para a função AtuSldNat() da natureza de origem
	Local aRetParamD := ARRAY(15) // Parâmetros para a função AtuSldNat() da natureza de Destino
	Local oTpConta   := JURTPCONTA():New()
	Local nDecimal   := TamSX3('E5_TXMOEDA')[2]

	Default cMoedaO  := ''
	Default cMoedaD  := ''
	Default cTpContO := ''
	Default cTpContD := ''

	cCarteiraO := oTpConta:GetRecPag(cTpContO, "O")
	cCarteiraD := oTpConta:GetRecPag(cTpContD, "D")

	nVlrCor    := JA201FConv(cMoedaNac, cMoedaLanc, nValorLanc, "8", dDataLan, , , , , , "2", nDecimal )[1]
	nValorO    := Iif(cMoedaO == cMoedaLanc, nValorLanc, nValorCot)
	nValorD    := Iif(cMoedaD == cMoedaLanc, nValorLanc, nValorCot)

	If lAtuO
		aRetParamO[1]  := cNatO
		aRetParamO[2]  := dDataLan
		aRetParamO[3]  := cMoedaO
		aRetParamO[4]  := "3" // TipoSld, 3 = Realizado
		aRetParamO[5]  := cCarteiraO
		aRetParamO[6]  := nValorO
		aRetParamO[7]  := nVlrCor
		aRetParamO[8]  := cSinal
		aRetParamO[9]  := Nil // Periodo, NIL = Ambos
		aRetParamO[10] := "JURA241" // Nome do fonte que originou a movimentação.
		aRetParamO[11] := "OHB" // Alias
		aRetParamO[12] := nRecno // Recno pegar dentro da transação quando for insert
		aRetParamO[13] := nOper // Número da operação realizada na tela de lançamentos(Inclusão/Alteração/Exclusão)
		aRetParamO[14] := Nil
		aRetParamO[15] := Nil
	Else
		aRetParamO := {}
	EndIf

	If lAtuD
		aRetParamD[1]  := cNatD
		aRetParamD[2]  := dDataLan
		aRetParamD[3]  := cMoedaD
		aRetParamD[4]  := "3" // TipoSld, 3 = Realizado
		aRetParamD[5]  := cCarteiraD
		aRetParamD[6]  := nValorD
		aRetParamD[7]  := nVlrCor
		aRetParamD[8]  := cSinal
		aRetParamD[9]  := Nil // Periodo, NIL = Ambos
		aRetParamD[10] := "JURA241" //Nome do fonte que originou a movimentação.
		aRetParamD[11] := "OHB" // Alias
		aRetParamD[12] := nRecno // Recno pegar dentro da transação quando for insert
		aRetParamD[13] := nOper // Número da operação realizada na tela de lançamentos(Inclusão/Alteração/Exclusão)
		aRetParamD[14] := Nil
		aRetParamD[15] := Nil
	Else
		aRetParamD := {}
	EndIf

	aRet := {aRetParamO, aRetParamD}

	FreeObj(oTpConta)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241ExcAtu()
Função executar a função AtuSldNat() conforme os parâmetros gerados pelo método BeforeTTS da classe JA241CM

@param aPar => Parâmetros gerados pelo método BeforeTTS da classe JA241CM

@obs NÃO alterar o nome da função, pois a mesma está em um FwIsInCallStack no fonte FINXNAT

@author bruno.ritter
@since 24/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J241ExcAtu(oModel, aPar) // NÃO alterar o nome da função, pois a mesma está em um FwIsInCallStack no fonte FINXNAT
	Local aPNatO   := {}
	Local aPNatD   := {}
	Local nRecno   := 0
	Local nModelOp := oModel:GetOperation()
	Local cFilAtu  := cFilAnt
	Local cFilOri  := oModel:GetValue("OHBMASTER", "OHB_FILORI")

	ProcRegua( 0 )
	IncProc()
	IncProc()
	IncProc()

	If !Empty(aPar) .And. Len(aPar) == 2
		aPNatO := aPar[1]
		aPNatD := aPar[2]

		If nModelOp == MODEL_OPERATION_INSERT
			OHB->(DbSetOrder(1)) // OHB_FILIAL+OHB_CODIGO
			If OHB->(DbSeek(xFilial("OHB") + oModel:GetValue("OHBMASTER", "OHB_CODIGO")))
				nRecno := OHB->(Recno())
			EndIF
		EndIf

		If nModelOp != MODEL_OPERATION_INSERT .Or. !Empty(nRecno)
			cFilAnt := cFilOri

			If Len(aPNatO) == 15
				Iif (nModelOp == MODEL_OPERATION_INSERT, aPNatO[12] := nRecno, Nil)
				AtuSldNat( aPNatO[1], aPNatO[2], aPNatO[3], aPNatO[4], aPNatO[5],;
				aPNatO[6], aPNatO[7], aPNatO[8], aPNatO[9], aPNatO[10],;
				aPNatO[11], aPNatO[12], aPNatO[13], aPNatO[14], aPNatO[15])
			EndIf

			If Len(aPNatD) == 15
				Iif (nModelOp == MODEL_OPERATION_INSERT, aPNatD[12] := nRecno, Nil)
				AtuSldNat( aPNatD[1], aPNatD[2], aPNatD[3], aPNatD[4], aPNatD[5],;
				aPNatD[6], aPNatD[7], aPNatD[8], aPNatD[9], aPNatD[10],;
				aPNatD[11], aPNatD[12], aPNatD[13], aPNatD[14], aPNatD[15])
			EndIf

			cFilAnt := cFilAtu
		EndIf

	EndIf
	
	JurFreeArr(@aPNatO)
	JurFreeArr(@aPNatD)
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J241VerAtu(oModel)
Função para verificar se deve atualizar/estornar o saldo da natureza
em uma operação de alteração.

@author bruno.ritter
@since 25/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J241VerAtu(oModel)
	Local aArea      := GetArea()
	Local lAtuOrigem := .T.
	Local lAtuDestin := .T.
	Local aRet       := {}

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		OHB->(DbSetOrder(1)) // OHB_FILIAL+OHB_CODIGO
		If OHB->(DbSeek(xFilial("OHB") + oModel:GetValue("OHBMASTER", "OHB_CODIGO")))
			lAtuOrigem := OHB->OHB_NATORI != oModel:GetValue("OHBMASTER", "OHB_NATORI")
			lAtuDestin := OHB->OHB_NATDES != oModel:GetValue("OHBMASTER", "OHB_NATDES")

			If OHB->OHB_DTLANC  != oModel:GetValue("OHBMASTER", "OHB_DTLANC") .Or.;
			   OHB->OHB_CMOELC != oModel:GetValue("OHBMASTER", "OHB_CMOELC") .Or.;
			   OHB->OHB_VALOR  != oModel:GetValue("OHBMASTER", "OHB_VALOR") .Or.;
			   OHB->OHB_VALORC != oModel:GetValue("OHBMASTER", "OHB_VALORC")
				lAtuOrigem := .T.
				lAtuDestin := .T.
			EndIf
		EndIf
	EndIf

	aRet := {lAtuOrigem, lAtuDestin}
	RestArea(aArea)

	JurFreeArr(@aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241Saldo()
Rotina para retornar o saldo da natureza.

@param cNatureza - Natureza para retorno do saldo

@Return nRet Saldo no valor da moeda da natureza.

@author Luciano Pereira dos Santos
@since 01/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241Saldo(cNatureza)
Local nRet     := 0
Local cFilOrig := "" 
Local oModel   := FwModelActive()

	cFilOrig := IIf(ValType(oModel) == "U" .Or. oModel:GetOperation() <> MODEL_OPERATION_INSERT, OHB->OHB_FILORI, FwFldGet("OHB_FILORI"))

	nRet := JurSalNat(cNatureza, cFilOrig)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241ValNat(cCampo)
Função utilizada para validação no dicionário.
Verifica se a natureza de origem e destino são de despesa para cliente, o que não é permitido.

@param cCampo => Campo que originou a chamada.

@Return lRet Se a natureza é válida.

@author ricardo.neves/bruno.ritter
@since 06/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241ValNat(cCampo)
	Local lRet        := .T.
	Local cNatDes     := ""
	Local cNatOrig    := ""
	Local lPermBloq   := !(M->OHB_ORIGEM $ "4|5")

	lRet := JurValNat(cCampo, , , , , , , lPermBloq) // Valida se a natureza existe, se é analítica, não bloqueada, com a moeda preenchida

	If lRet
		cNatOrig   := M->OHB_NATORI
		cNatDes    := M->OHB_NATDES
		If cNatOrig == cNatDes
			If J241IsDesp(cNatOrig)
				lRet := JurMsgErro(STR0029,, STR0030) // "Natureza de despesa para cliente na origem e no destino." //"Selecione uma Natureza diferente na origem ou no destino."
			EndIf
		EndIf
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241OpDesp(oModel, nOperDesp)
Valida e prepara a despesa para inclusão, alteração ou exclusão de lançamento de despesa para cliente

@param oModel    => Modelo ativo
@param nOperDesp => Operacao para a Despesa (1=INSERT;2=UPDATE;3=DELETE)

@Return oModelNVY Retorna o modelo preparado da NVY para

@author ricardo.neves/bruno.ritter
@since 06/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J241OpDesp(oModel, nOperDesp)
Local aAreaNVY   := NVY->(GetArea())
Local oModelDesp := Nil
Local oModelNVY  := Nil
Local oModelOHB  := oModel:GetModel("OHBMASTER")
Local aErro      := {}
Local cTpNatOri  := ''
Local cCobraOld  := ''
Local cPartSigla := ''

	NVY->(DbSetOrder(1)) // NVY_FILIAL+NVY_COD
	If nOperDesp == MODEL_OPERATION_INSERT .Or. NVY->(DbSeek(xFilial("NVY") + oModelOHB:GetValue("OHB_CDESPD")))
		oModelDesp := FWLoadModel("JURA049")
		oModelDesp:SetOperation(nOperDesp)
		oModelDesp:Activate()

		If nOperDesp != MODEL_OPERATION_DELETE
			oModelNVY := oModelDesp:GetModel("NVYMASTER")
			oModelNVY:SetValue("NVY_CCLIEN", oModelOHB:GetValue("OHB_CCLID "))
			oModelNVY:SetValue("NVY_CLOJA" , oModelOHB:GetValue("OHB_CLOJD "))
			oModelNVY:SetValue("NVY_CCASO" , oModelOHB:GetValue("OHB_CCASOD"))
			oModelNVY:SetValue("NVY_DATA"  , oModelOHB:GetValue("OHB_DTDESP"))
			oModelNVY:SetValue("NVY_SIGLA" , oModelOHB:GetValue("OHB_SIGLA"))
			oModelNVY:SetValue("NVY_CTPDSP", oModelOHB:GetValue("OHB_CTPDPD"))
			oModelNVY:SetValue("NVY_QTD"   , oModelOHB:GetValue("OHB_QTDDSD"))
			oModelNVY:SetValue("NVY_COBRAR", oModelOHB:GetValue("OHB_COBRAD"))
			oModelNVY:SetValue("NVY_DESCRI", oModelOHB:GetValue("OHB_HISTOR"))
			oModelNVY:SetValue("NVY_CMOEDA", oModelOHB:GetValue("OHB_CMOELC"))
			oModelNVY:SetValue("NVY_CLANC" , oModelOHB:GetValue("OHB_CODIGO"))

			cPartSigla := AllTrim(JurGetDados("RD0", 1, xFilial("RD0") + JurUsuario(__CUSERID), "RD0_SIGLA"))
			If nOperDesp == MODEL_OPERATION_UPDATE
				cCobraOld := JurGetDados('OHB', 1, xFilial("OHB") + oModelOHB:GetValue('OHB_CODIGO'), 'OHB_COBRAD')
				If cCobraOld != oModelOHB:GetValue("OHB_COBRAD")
					If oModelOHB:GetValue("OHB_COBRAD") == "2"
						oModelNVY:SetValue("NVY_OBSCOB", I18n(STR0034, {cPartSigla})) // "Despesa gerada como não cobrável pela sigla do participante: '#1'."
						oModelNVY:SetValue("NVY_OBS"   , I18n(STR0034, {cPartSigla}) +  " - " + FWTimeStamp(2) + CRLF + NVY->NVY_OBS ) // "Despesa gerada como não cobrável pela sigla do participante: '#1'."
						oModelNVY:SetValue("NVY_USRNCB", cPartSigla)
					Else
						oModelNVY:SetValue("NVY_OBSCOB", "")
						oModelNVY:SetValue("NVY_OBS"   , I18n(STR0062, {cPartSigla}) +  " - " + FWTimeStamp(2) + CRLF + NVY->NVY_OBS ) // "Despesa gerada como cobrável pela sigla do participante: '#1'."
						oModelNVY:SetValue("NVY_USRNCB", "")
					EndIf
				EndIf
			Else //MODEL_OPERATION_INSERT
				If oModelOHB:GetValue("OHB_COBRAD") == "2"
					oModelNVY:SetValue("NVY_OBSCOB", I18n(STR0034, {cPartSigla})) // "Despesa gerada como não cobrável pela sigla do participante: '#1'."
					oModelNVY:SetValue("NVY_OBS"   , I18n(STR0034, {cPartSigla}) +  " - " + FWTimeStamp(2)) // "Despesa gerada como não cobrável pela sigla do participante: '#1'."
					oModelNVY:SetValue("NVY_USRNCB", cPartSigla)
				EndIf
			EndIf

			cTpNatOri := JurGetDados('SED', 1, xFilial('SED') + oModelOHB:GetValue("OHB_NATORI"), 'ED_CCJURI')
			If cTpNatOri == '5'
				oModelNVY:SetValue("NVY_VALOR", oModelOHB:GetValue("OHB_VALOR ") * -1)
			Else
				oModelNVY:SetValue("NVY_VALOR", oModelOHB:GetValue("OHB_VALOR "))
			EndIf
		EndIf

		If oModelDesp:HasErrorMessage()
			aErro := oModelDesp:GetErrorMessage()
			JurMsgErro(STR0031,, aErro[7]) //"Erro ao atualizar Despesa:"
			FreeObj(oModelDesp)

		ElseIf !oModelDesp:VldData()
			aErro := oModelDesp:GetErrorMessage()
			JurMsgErro(STR0031,, aErro[7]) //"Erro ao atualizar Despesa:"
			FreeObj(oModelDesp)
		EndIf
	EndIf

	RestArea(aAreaNVY)

	JurFreeArr(@aErro)
	JurFreeArr(@aAreaNVY)

Return oModelDesp

//-------------------------------------------------------------------
/*/{Protheus.doc} J241AcDesp(oModel)
Verifica se é necessário gerar um INSERT/UPDATE/DELETE de Despesa e retorna qual operação será executada.
Quando a origem for 1-Contas a Pagar, o retorno deverá ser 0.

@param oModel     => Modelo ativo

@Return nOperDesp => A operação que é necessário para atualizar a Despesa vinculada, retorna 0 quando a despesa não deve ser atualizada

@author bruno.ritter/ricardo.neves
@since 07/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J241AcDesp(oModel)
	Local nOperDesp  := 0
	Local nModelOp   := oModel:GetOperation()
	Local oModelOHB  := oModel:GetModel("OHBMASTER")
	Local dDespNew   := oModelOHB:GetValue("OHB_DTDESP") // Data da despesa do lançamento: sempre preenchido quando o lançamento tem uma natureza de despesa para cliente.
	Local dDespOld   := CtoD('')

	If !(oModelOHB:GetValue("OHB_ORIGEM") $ "1|2|7") // Se NÃO for Contas a Pagar | Contas a Receber | Extrato
		If nModelOp == MODEL_OPERATION_INSERT .Or. nModelOp == MODEL_OPERATION_DELETE
			If !Empty(dDespNew)
				nOperDesp := nModelOp
			EndIf

		Else //MODEL_OPERATION_UPDATE
			dDespOld := JurGetDados('OHB', 1, xFilial('OHB') + oModel:GetValue("OHBMASTER", "OHB_CODIGO"), 'OHB_DTDESP')
			If !Empty(dDespNew) .And. !Empty(dDespOld) //Se o lançamento era e continua sendo com despesa
				nOperDesp := MODEL_OPERATION_UPDATE

			ElseIf !Empty(dDespNew) //Se o lançamento NÃO era de Despesa e agora é de Despesa
				nOperDesp := MODEL_OPERATION_INSERT

			ElseIf !Empty(dDespOld) //Se o lançamento era de Despesa e agora NÃO é mais de Despesa
				nOperDesp := MODEL_OPERATION_DELETE

			EndIf
		EndIf
	EndIf

Return nOperDesp

//-------------------------------------------------------------------
/*/{Protheus.doc} J241IsDesp(cCodNat)
Verifica se a natureza tem o centro de custo de despesa para cliente.

@param cCodNat     => Código da Natureza

@Return lIsDespesa => Se o centro de custo é despesa para cliente

@author bruno.ritter/ricardo.neves
@since 08/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241IsDesp(cCodNat)
	Local oModel     := FWModelActive()
	Local oModelOHB  := oModel:GetModel("OHBMASTER")
	Local lIsDespesa := .F.
	Local cTpNatOri  := ''
	Local cTpNatDes  := ''

	Default cCodNat  := ''

	If Empty(cCodNat)
		cTpNatOri  := JurGetDados('SED', 1, xFilial('SED') + oModelOHB:GetValue('OHB_NATORI'), 'ED_CCJURI')
		cTpNatDes  := JurGetDados('SED', 1, xFilial('SED') + oModelOHB:GetValue('OHB_NATDES'), 'ED_CCJURI')
		lIsDespesa := cTpNatOri == '5' .Or. cTpNatDes == '5'
	Else
		lIsDespesa := JurGetDados('SED', 1, xFilial('SED') + cCodNat, 'ED_CCJURI') == '5'
	EndIf

Return lIsDespesa

//-------------------------------------------------------------------
/*/{Protheus.doc} J241CMDesp()
Efetua o commit da despesa.

@param oModelDesp     => Modelo da NVY(Despesa)

@author bruno.ritter/ricardo.neves
@since 11/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J241CMDesp(oModelDesp)
	ProcRegua( 0 )
	IncProc()
	IncProc()
	IncProc()

	If !Empty(oModelDesp)
		oModelDesp:CommitData()
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J241IniCBD()
Função do gatilho das naturezas para preencher o valor padrão "cobrar despesa?".

@Return cOpcao => Opção do campo cobrar despesa

@author bruno.ritter/ricardo.neves
@since 12/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241IniCBD()
	Local cOpcao := ''

	If J241IsDesp()
		If Empty(FwFldGet('OHB_COBRAD'))
			cOpcao := '1'
		Else
			cOpcao := FwFldGet('OHB_COBRAD')
		EndIf
	Else
		cOpcao := ''
	EndIf
	
Return cOpcao

//-------------------------------------------------------------------
/*/{Protheus.doc} J241VldHis(cHist)
Validação do historico padrão

@Param cHist  Código do histórico padrão

@author Cristina Cintra
@since 03/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241VldHis(cHist)
	Local lRet   := .T.

	lRet := ExistCpo('OHA', cHist, 1)

	If lRet .And. M->OHB_ORIGEM $ "4|5"
		lRet := JAVLDCAMPO('OHBMASTER', 'OHB_CHISTP', 'OHA', 'OHA_LANCAM', '1')
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA241VldMd(oModel)
Validação da moeda de natureza x a moeda do banco relacionado a natureza

@Param oModel  Modelo OHBMASTER

@author Bruno Ritter
@since 06/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA241VldMd(oModel)
	Local lRet       := .T.
	Local oModelOHB  := oModel:GetModel("OHBMASTER")
	Local cNatOrig   := oModelOHB:GetValue("OHB_NATORI")
	Local cNatDest   := oModelOHB:GetValue("OHB_NATDES")
	Local aRetNatO   := JurGetDados('SED', 1, xFilial('SED') + cNatOrig, {"ED_CMOEJUR", "ED_BANCJUR", "ED_CBANCO", "ED_CAGENC", "ED_CCONTA"})
	Local aRetNatD   := JurGetDados('SED', 1, xFilial('SED') + cNatDest, {"ED_CMOEJUR", "ED_BANCJUR", "ED_CBANCO", "ED_CAGENC", "ED_CCONTA"})
	Local cNatMoedaO := aRetNatO[1]
	Local cNatMoedaD := aRetNatD[1]
	Local cNatBancO  := aRetNatO[2]
	Local cNatBancD  := aRetNatD[2]
	Local cBancoOrg  := aRetNatO[3]
	Local cBancoDst  := aRetNatD[3]
	Local cAgengOrg  := aRetNatO[4]
	Local cAgengDst  := aRetNatD[4]
	Local cContaOrg  := aRetNatO[5]
	Local cContaDst  := aRetNatD[5]
	Local nMoedBancO := 0
	Local nMoedBancD := 0

	If cNatBancO == "1" //Banco = Sim
		nMoedBancO := JurGetDados("SA6", 1, xFilial("SA6") + cBancoOrg + cAgengOrg + cContaOrg, "A6_MOEDA")
		If nMoedBancO != Val(cNatMoedaO)
			lRet := JurMsgErro(STR0037,, i18n(STR0038, {cNatOrig})) //"A moeda da natureza está diferente da moeda banco",,"Verifique o cadastro da natureza '#1'."
		EndIf
	EndIf

	If lRet .And. cNatBancD == "1" //Banco = Sim
		nMoedBancD := JurGetDados("SA6", 1, xFilial("SA6") + cBancoDst + cAgengDst + cContaDst, "A6_MOEDA")
		If nMoedBancD != Val(cNatMoedaD)
			lRet := JurMsgErro(STR0037,, i18n(STR0038, {cNatDest})) //"A moeda da natureza está diferente da moeda banco",,"Verifique o cadastro da natureza '#1'."
		EndIf
	EndIf

	JurFreeArr(@aRetNatO)
	JurFreeArr(@aRetNatD)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241GerMBc()
Função para Gerar o Movimento Bancário a Pagar e Receber no Botão Ok 
na rotina de Lançamento (Modulo Juridico) via Rotina Automática FINA100.

@author Eduardo Augusto
@since 18/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J241GerMBc(oModel, nOperation, cLog)
Local aSaveLines := FWSaveRows()
Local lRet := .T.
	
	If nOperation == 3     // Inclusão
		Processa( {|| lRet := J241PrcMov(oModel, @cLog)}, STR0039, STR0040 ) // "Gravando..." #  "Incluindo Movimento Bancário"
	ElseIf nOperation == 4 // Alteração
		Processa( {|| lRet := J241PrcMov(oModel, @cLog)}, STR0041, STR0042 ) // "Atualizando..." # "Atualizando Movimento Bancário"
	ElseIf nOperation == 5 // Exclusão
		Processa( {|| lRet := J241PrcMov(oModel, @cLog)}, STR0043, STR0044 ) // "Excluindo..." # "Excluindo Movimento Bancário"
	EndIf

	FWRestRows( aSaveLines )
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241PrcMov(oModel)
Rotina para aglutinar o processamento do movimento

@Return Nil      - P=Pagar, R=Receber

@author Luciano.pereira
@since 26/07/2017
/*/
//-------------------------------------------------------------------
Static Function J241PrcMov(oModel, cLog)
Local nModelOp   := oModel:GetOperation()
Local aRetNatO   := {}
Local aRetNatD   := {}
Local cBancoNatO := ""
Local cBancoNatD := ""
Local cMoedaNatO := ""
Local cMoedaNatD := ""
Local nVlrLancO  := 0
Local nVlrLancD  := 0
Local cNatOrig   := oModel:GetValue("OHBMASTER", "OHB_NATORI")
Local cNatDest   := oModel:GetValue("OHBMASTER", "OHB_NATDES")
Local cOHBCod    := oModel:GetValue("OHBMASTER", "OHB_CODIGO")
Local cMoedaOHB  := oModel:GetValue("OHBMASTER", "OHB_CMOELC")
Local nValOHB    := oModel:GetValue("OHBMASTER", "OHB_VALOR")
Local nValConv   := oModel:GetValue("OHBMASTER", "OHB_VALORC")
Local dDataLanc  := oModel:GetValue("OHBMASTER", "OHB_DTLANC")
Local nCotacOrg  := 0
Local nCotacDst  := 0
Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01')
Local nDecimal   := TamSX3('E5_TXMOEDA')[2]
Local nCotacOHB  := oModel:GetValue("OHBMASTER", "OHB_COTAC")
Local aRetVerAtu := {}
Local lAtuOrigem := .T.
Local lAtuDestin := .T.
Local lAtuSaldo  := .T.
Local cExcNatExp := ""
Local lRet       := .T. //Retorno da Exclusão
Local aRetAuto   := {}
Local cOrigem    := "JURA241"

	ProcRegua( 0 )
	IncProc()
	IncProc()
	IncProc()

	If nModelOp == MODEL_OPERATION_UPDATE
		aRetVerAtu := J241VerAtu(oModel) // Verifica se deve atualizar o saldo quando for alteração
		lAtuOrigem := aRetVerAtu[1]
		lAtuDestin := aRetVerAtu[2]
		lAtuSaldo  := lAtuOrigem .Or. lAtuDestin

		//Verifica se precisa excluir apenas uma natureza
		If !lAtuOrigem .Or. !lAtuDestin
			cExcNatExp := Iif(lAtuOrigem, OHB->OHB_NATORI, OHB->OHB_NATDES)
		EndIf
	EndIf

	If lAtuSaldo
		aRetNatO   := JurGetDados('SED', 1, xFilial('SED') + cNatOrig, {"ED_BANCJUR", "ED_CMOEJUR"})
		aRetNatD   := JurGetDados('SED', 1, xFilial('SED') + cNatDest, {"ED_BANCJUR", "ED_CMOEJUR"})

		If Len(aRetNatO) == 2
			cBancoNatO := aRetNatO[1]
			cMoedaNatO := aRetNatO[2]
		EndIf

		If Len(aRetNatD) == 2
			cBancoNatD := aRetNatD[1]
			cMoedaNatD := aRetNatD[2]
		EndIf

		// Valor de Origem
		If cMoedaNatO == cMoedaOHB
			nVlrLancO := nValOHB
			nCotacOrg := GetCotacD(cMoedaNatO, dDataLanc)
		Else
			nVlrLancO := nValConv
			nCotacOrg := JA201FConv(cMoedaNac, cMoedaNatO, Round(nValConv/nCotacOHB, 2), "8", dDataLanc, , , , , , "2", nDecimal )[2]
		EndIf

		// Valor de Destino
		If cMoedaNatD == cMoedaOHB
			nVlrLancD := nValOHB
			nCotacDst := GetCotacD(cMoedaNatD, dDataLanc)
		Else
			nVlrLancD := nValConv
			nCotacDst := JA201FConv(cMoedaNac, cMoedaNatD, Round(nValConv/nCotacOHB, 2), "8", dDataLanc, , , , , , "2", nDecimal )[2]
		EndIf

		If nModelOp == MODEL_OPERATION_UPDATE .Or. nModelOp == MODEL_OPERATION_DELETE
			
			If FindFunction("GetParAuto") // Necessário, pois a SE5 gerada na inclusão da OHB via automação fica com origem RPC e não JURA241
				aRetAuto := GetParAuto("JURA241TestCase")

				If ValType(aRetAuto) == "A" .And. Len(aRetAuto) > 0 .And. aRetAuto[1][1] == "JUR241_059"
					cOrigem := aRetAuto[1][2]
				EndIf
			EndIf

			//Exclui o movimento bancario
			lRet := JurExcMov(cOHBCod, cOrigem, cExcNatExp, .F., @cLog)
			lRet := ValType(lRet) = "U" .Or. lRet
		EndIf

		If lRet
			If cBancoNatO == "1" .And. lAtuOrigem .And. (nModelOp == MODEL_OPERATION_UPDATE .Or. nModelOp == MODEL_OPERATION_INSERT)
			// Inclui o movimento bancario para natureza de origem
				lRet := JurIncMov(cNatOrig, 'O', cOHBCod, cMoedaNatO, nVlrLancO, dDataLanc, nCotacOrg, .F., @cLog)
				lRet := ValType(lRet) = "U" .Or. lRet
		EndIf

			If lRet .And. cBancoNatD == "1" .AND. lAtuDestin .And. (nModelOp == MODEL_OPERATION_UPDATE .Or. nModelOp == MODEL_OPERATION_INSERT)
			// Inclui o movimento bancario para natureza de destino
				lRet := JurIncMov(cNatDest, 'D', cOHBCod, cMoedaNatD, nVlrLancD, dDataLanc, nCotacDst, .F., @cLog)
				lRet := ValType(lRet) = "U" .Or. lRet
			EndIf
		EndIf
	EndIf
	
	JurFreeArr(@aRetNatO)
	JurFreeArr(@aRetNatD)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA241Event
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author bruno.ritter
@since 23/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA241Event FROM FWModelEvent
Data aParExtSld //Parâmetros que serão usados para a função atulização de saldo no estorno
Data aParAtuSld //Parâmetros que serão usados para a função atulização de saldo
Data oModelDesp //Model para inclusão de Despesa

Method New()
Method FieldPreVld()
Method ModelPosVld()
Method Before()
Method BeforeTTS()
Method InTTS()
Method Destroy()
End Class

//-------------------------------------------------------------------
/*/ { Protheus.doc } New()
New FWModelEvent
/*/
//-------------------------------------------------------------------
Method New() Class JA241Event
	Self:aParExtSld := {}
	Self:aParAtuSld := {}
	Self:oModelDesp := Nil
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
        para verificar se o cabeçalho "OHBMASTER" poderá ser editável
        e sempre permitir a alteração do GRID de anexos
/*/
//-------------------------------------------------------------------
Method FieldPreVld(oModel, cModelId, cAction, cId, xValue) Class JA241Event
	Local lMPreVld := .T.
	Local lIsRest  := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)
 
	If lIsRest .And. cAction == "SETVALUE"
		lMPreVld := J241VldAct(oModel)
	EndIf

Return (lMPreVld)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model

@param   oModel  , Objeto  , Modelo principal
@param   cModelId, Caracter, Id do submodelo
@return  lRet    , Logico  , Se .T. as validações foram efetuadas com sucesso

@author bruno.ritter
@since 07/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class JA241Event
	Local lRet       := .T.
	Local nOperDesp  := 0
	Local lIsRest    := FindFunction("JurIsRest") .And. JurIsRest()
	Local lIntFinanc := SuperGetMV("MV_JURXFIN",, .F.) //Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
	Local lOrigJu049 := FwIsInCallStack("J049RepLan") // Quando a origem da operação for da JURA049(Despesa)
	Local oModelOHB  := oModel:GetModel("OHBMASTER")
	Local cOrigem    := ""
	Local cOrigemB   := ""
	Local nOpc       := oModel:GetOperation()
	
	Self:oModelDesp  := Nil

	If lIsRest .And. FindFunction("JIsRestID") .And. JIsRestID("JURA241", "JLANCAMENTOS")
		cOrigem  := oModel:GetValue("OHBMASTER", "OHB_ORIGEM")
		cOrigemB := JurGetDados('OHB', 1, xFilial("OHB") + oModelOHB:GetValue('OHB_CODIGO'), 'OHB_ORIGEM')
		
		If nOpc == MODEL_OPERATION_DELETE .And. !Empty(cOrigem) .And. cOrigem != "4"
			lRet := JurMsgErro(STR0047, , I18N(STR0058, {JurInfBox("OHB_ORIGEM", "4", "3")})) // "Operação não permitida, pois o lançamento foi gerado a partir de outra rotina." ### "A origem do lançamento deve ser igual a: '#1'"
		ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !Empty(cOrigem)  .And. cOrigem  != "4")
			lRet := JurMsgErro(STR0057, , I18N(STR0058, {JurInfBox("OHB_ORIGEM", "4", "3")})) // "Origem do lançamento <OHB_ORIGEM> incorreta!" ### "A origem do lançamento deve ser igual a: '#1'"
		ElseIf (nOpc == MODEL_OPERATION_UPDATE .And. !Empty(cOrigemB))
			If cOrigemB != "4"
				lRet := JurMsgErro(STR0057, , I18N(STR0058, {JurInfBox("OHB_ORIGEM", "4", "3")})) // "Origem do lançamento <OHB_ORIGEM> incorreta!" ### "A origem do lançamento deve ser igual a: '#1'"
			ElseIf cOrigem != cOrigemB
				lRet := JurMsgErro(STR0047, , I18N(STR0058, {JurInfBox("OHB_ORIGEM", "4", "3")})) // "Origem do lançamento <OHB_ORIGEM> incorreta!" ### "A origem do lançamento deve ser igual a: '#1'"
			EndIf
		EndIf
	EndIf

	//Validacao cliente/loja igual os parametros:MV_JURTS5 e MV_JURTS6 ou MV_JURTS9 e MV_JURTS10
	If lRet .And. (nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE)
		lRet := JurCliLVld(oModel, oModelOHB:GetValue('OHB_CCLID'), oModelOHB:GetValue('OHB_CLOJD'))
	EndIf

	//Validação dos campos obrigatórios
	If lRet .And. !(oModel:GetValue("OHBMASTER", "OHB_ORIGEM") $ "1|2|7") // Se NÃO for Contas a Pagar | Contas a Receber | Extrato
		lRet := JA241VldOb(oModel)
	EndIf

	// Validação Calendário contábil x Lançamentos
	If lRet
		lRet := JA241VldCal(oModel)
	EndIf

	//Validação da moeda da natureza x Banco
	If lRet
		lRet := JA241VldMd(oModel)
	EndIf

	If lRet .And. lIntFinanc .And. !lOrigJu049
		//Verifica se deve atualizar despesa e qual o tipo da atualização (INSERT, UPDATE ou DELETE)
		nOperDesp := J241AcDesp(oModel)
		If nOperDesp > 0
			//Gera e valida modelo para INSERT/UPDATE/DELETE da Despesa
			Self:oModelDesp := J241OpDesp(oModel, nOperDesp)
			lRet := !Empty(Self:oModelDesp)
			oModel:Activate() // Ativa modelo da JURA241 novamente
		EndIf
	EndIf

	If lRet .And. nOpc == MODEL_OPERATION_INSERT .And. lIsRest .And. OHB->(FieldPos( "OHB_CODLD" )) > 0 .And. FindFunction("JurMsgCdLD")
		If !FwIsInCallStack("J247Lanc") // Não validar quando o lançamento for criado através do desdobramento pós pagamento (OHG)
			lRet := JurMsgCdLD(oModel:GetValue("OHBMASTER", "OHB_CODLD"))
		EndIf
	EndIf

	If lRet .And. FindFunction("J235Anexo") .And. !FWIsInCallStack("J247LANC") .And. (lIsRest .Or. nOpc == MODEL_OPERATION_DELETE)
		lRet := J235Anexo(oModel, "OHB", "OHBMASTER", "OHB_CODIGO")
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Before
Método que é chamado pelo MVC quando ocorrer as ações do commit antes 
da gravação de cada submodelo (field ou cada linha de uma grid)

@author Jonatas Martins
@since  12/11/2018
/*/
//-------------------------------------------------------------------
Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class JA241Event

	// Executa estorno de contabilização na alteração/exclusão do lançamento
	If !lNewRecord .And. cModelId == "OHBMASTER" .And. FindFunction("JURA265B") .And. FindFunction("J265LpFlag") .And. OHB->(ColumnPos("OHB_DTCONT")) > 0
		J241EstCtb(oSubModel)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BeforeTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação.

@author bruno.ritter
@since 24/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method BeforeTTS(oModel, cModelId) Class JA241Event
	Local nModelOp   := oModel:GetOperation()
	Local oModelOHB  := oModel:GetModel("OHBMASTER")

	If !Empty(Self:oModelDesp) .And. nModelOp != MODEL_OPERATION_DELETE
		If Self:oModelDesp:GetOperation() == MODEL_OPERATION_DELETE
			oModelOHB:LoadValue("OHB_CDESPD", "")

		Else //INSERT/UPDATE
			oModelOHB:LoadValue("OHB_CDESPD", Self:oModelDesp:GetValue("NVYMASTER", "NVY_COD"))

		EndIf
	EndIf

	If nModelOp == MODEL_OPERATION_INSERT
		oModelOHB:LoadValue("OHB_CUSINC", JURUSUARIO(__CUSERID))
		Self:aParAtuSld := J241AtuSal(oModel)

	ElseIf nModelOp == MODEL_OPERATION_UPDATE
		oModelOHB:LoadValue("OHB_DTALTE", Date())
		oModelOHB:LoadValue("OHB_CUSALT", JURUSUARIO(__CUSERID))
		Self:aParAtuSld := J241AtuSal(oModel)
		Self:aParExtSld := J241AtuSal(oModel, .T.)

	ElseIf nModelOp == MODEL_OPERATION_DELETE
		Self:aParExtSld := J241AtuSal(oModel, .T.)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém
antes do final da transação

@author bruno.ritter
@since 24/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method InTTS(oModel, cModelId) Class JA241Event
	Local nModelOp   := oModel:GetOperation()
	Local cCpoItem   := ""
	Local nCtb       := 0

	If nModelOp == MODEL_OPERATION_INSERT
		Processa( {|| J241ExcAtu(oModel, Self:aParAtuSld)}, STR0027, STR0028)// "Gravando." "Atualizando saldos das naturezas..."

	ElseIf nModelOp == MODEL_OPERATION_UPDATE
		Processa( {||J241ExcAtu(oModel, Self:aParExtSld),;
		J241ExcAtu(oModel, Self:aParAtuSld)}, STR0027, STR0028)// "Gravando." "Atualizando saldos das naturezas..."

	ElseIf nModelOp == MODEL_OPERATION_DELETE
		Processa( {||J241ExcAtu(oModel, Self:aParExtSld)}, STR0027, STR0028)// "Gravando." "Atualizando saldos das naturezas..."
		J241ExcAnx(oModel) // Exclui os anexos
	EndIf

	If !Empty(Self:oModelDesp)
		Processa( {||J241CMDesp(Self:oModelDesp)}, STR0027, STR0032)// "Gravando." "Atualizando Despesa..."
	EndIf

	// Replica anexos da solicitação de despesa quando vier da aprovação ou baixa de título
	If FindFunction("J235RepAnex") .And. FWIsInCallStack("J235APreApr") .Or. (FWIsInCallStack("JGrvBxPag") .And. oModel:GetOperation() != MODEL_OPERATION_DELETE)
		cCpoItem := IIF(FWIsInCallStack("J247CMTAux"), "OHB_ITDPGT", "OHB_ITDES")
		J235RepAnex("OHB", xFilial("OHB"), oModel:GetValue("OHBMASTER", "OHB_CODIGO"), oModel:GetValue("OHBMASTER", "OHB_CPAGTO"), oModel:GetValue("OHBMASTER", cCpoItem))
	EndIf

	// Executa contabilização lançamentos estornados por alterações
	If FindFunction("JURA265B")
		For nCtb := 1 To Len(_aRecLanCtb)
			JURA265B("942", _aRecLanCtb[nCtb]) // Contabilização de Lançamentos
		Next nCtb
	EndIf

	JurFreeArr(_aRecLanCtb)

	JFILASINC(oModel:GetModel(), "OHB", "OHBMASTER", "OHB_CODIGO") // Grava na Fila de Sincronização

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destrutor da classe

@author bruno.ritter
@since 24/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method Destroy() Class JA241Event

	Self:aParExtSld := Nil
	Self:aParExtSld := Nil
	Self:oModelDesp := Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA241VldCal
Validação Calendário Contábil x Lançamentos

@param oModel Modelo de dados de lançamentos

@author Jorge Luis Branco Martins Junior
@since 02/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA241VldCal(oModel)
	Local lRet      := .T.
	Local lCalBlock := .F.
	Local cFilAtu   := cFilAnt
	Local nI        := 1
	Local aStruct   := {}
	Local oModelOHB := oModel:GetModel("OHBMASTER")
	Local cCpoLiber := ""
	Local cCampo    := ""
	Local cTitulo   := ""
	Local oStruct   := Nil
	Local nOper     := oModel:GetOperation()

	cCpoLiber := "OHB_CESCRO|OHB_CCUSTO|OHB_SIGLAO|OHB_CPARTO|OHB_CTRATO|OHB_DCUSTO|OHB_SIGLAO|OHB_CPARTO|OHB_DPARTO|OHB_CTRATO|OHB_DTRATO|OHB_CESCRO|OHB_DESCRO|"+;
				"OHB_CESCRD|OHB_CCUSTD|OHB_SIGLAD|OHB_CPARTD|OHB_CTRATD|OHB_DCUSTD|OHB_SIGLAD|OHB_CPARTD|OHB_DPARTD|OHB_CTRATD|OHB_DTRATD|OHB_CESCRD|OHB_DESCRD|"+;
				"OHB_CCLID|OHB_CLOJD|OHB_DCLID|OHB_CCASOD|OHB_DCASOD|OHB_QTDDSD|OHB_CTPDPD|OHB_DTPDPD|OHB_COBRAD|OHB_DTDESP"

	cFilAnt := oModel:GetValue("OHBMASTER", "OHB_FILORI")

	lCalBlock := !(CtbValiDt(,oModel:GetValue("OHBMASTER", "OHB_DTLANC"), .F.,,, {"PFS001"},))

	If lCalBlock
		oStruct    := FwFormStruct(2, "OHB", {|cCampo| !(cCampo $ "OHB_CPROJD|OHB_DPROJD|OHB_CITPRD|OHB_DITPRD")} ) // Proteção para o Release 12.1.27 - Retirado uso dos campos de Projeto e Item de Destino
		aStruct    := oStruct:GetFields()
		nQtdStruct := Len(aStruct)
		If nOper == MODEL_OPERATION_DELETE
			lRet := .F.
		Else
			For nI := 1 To nQtdStruct
				cCampo  := aStruct[nI][1]
				If (cCampo == "OHB_SIGLA") .And. oModelOHB:IsFieldUpdated(cCampo, nI)
					lRet := .F.
					cTitulo := I18n(STR0053, {aStruct[nI][MODEL_FIELD_IDFIELD]}) //# "O Calendário Contáil esta bloqueado e o campo '#1' não pode ser alterado."
					Exit
				Else
					If !(cCampo $ cCpoLiber) .And. oModelOHB:IsFieldUpdated(cCampo, nI)
						lRet := .F.
						cTitulo := I18n(STR0053, {aStruct[nI][MODEL_FIELD_IDFIELD]}) //# "O Calendário Contábil esta bloqueado e o campo '#1' não pode ser alterado."
						Exit
					EndIf
				EndIf
			Next nI
		EndIf
	Else
		If FindFunction("JCriaCalend")
			JCriaCalend(oModelOHB:GetValue("OHB_DTLANC")) // Cria período em Calendário Contábil quando não existir
		EndIf
	EndIf

	If !lRet
		JurMsgErro(Iif(Empty(cTitulo), STR0045, cTitulo),, I18n(STR0046, {cFilAnt})) //"Calendário Contábil bloqueado." -- "Verifique o bloqueio do processo 'PFS001' no Calendário Contábil da filial '#1', para o período da data do lançamento."
	EndIf

	cFilAnt := cFilAtu

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241LancCR()
Cria os lançamentos (OHB) na baixa dos títulos a receber.

@param  nSE1Recno, numerico, Recno do registro SE1
@param  nSE5Recno, numerico, Recno do registro SE5
@param  nRegCmp  , numerico, Recno do Título que está sendo usado para compensar

@author Bruno Ritter
@since 21/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241LancCR(nRecnoSE1, nRecnoSE5, nRegCmp)
Local aAreas     := { SE1->(GetArea()), SE5->(GetArea()), SEV->(GetArea()), GetArea() }
Local cBcoLanc   := ""
Local cAgeLanc   := ""
Local cCtaLanc   := ""
Local cMoedaLanc := ""
Local cNatDest   := ""
Local cChaveSE1  := ""
Local cHistLanc  := ""
Local cMoedaNat  := ""
Local cDtBaixa   := StoD("  /  /  ")
Local cNatTrans  := JurBusNat("8") // Natureza cujo tipo é o 8-Transitória de Recebimento
Local cNatDespCl := JurBusNat("5") // Natureza cujo tipo é o 5-Despesa de Cliente
Local cNatHon    := ""

Local nTxLanc    := 0
Local nValorLiq  := 0
Local nNat       := 0
Local nLanc      := 0
Local nVlHon     := 0
Local nVlDesp    := 0
Local nAcresc    := 0
Local nTotAcres  := 0

Local aSetValue  := {}
Local aSetFields := {}
Local aModelLanc := {}
Local aNatTrans  := {} // Naturezas para Transitória de Recebimento {Natureza , Valor, Sequencia SE5, Histórico}
Local aTransNat  := {} // Transitória de Recebimento para Naturezas {Natureza , Valor, Sequencia SE5, Histórico}
Local aNaturezas := {} // Todas as naturezas para validações
Local aReceita   := {}
Local aLancDiv   := {}

Local lAplicaImp := .T.
Local lLancOk    := .T.
Local lCompensac := .F.
Local lMigrador  := IsInCallStack("U_MigCRExecAuto") .Or. IsInCallStack("U_MigFCNExecAuto")
Local nTamMoed   := TamSx3("OHB_CMOEC")[1] // Tamanho da Moeda
Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01' ) // Moeda Nacional
Local nDecimal   := TamSX3('OHB_VLNAC')[2] // Decimais do campo
Local nVlNac     := 0  // Valor Nacional
Local nValorOrc  := 0  // Valor do Orcamento
Local nTxDest    := 0  // Cotação Destino
Local cMoeDest   := 0  // Moeda Destino
Local cMoeNatTr  := "" // Moeda da Transferencia
Local nTxMoeNaTr := 0  // Taxa da Moeda de Transferencia
Local cMoedaTit  := "" // Moeda do título

	SE1->(DbGoto(nRecnoSE1))
	SE5->(DbGoto(nRecnoSE5))

	lCompensac := Empty(SE5->E5_BANCO) .And. nRegCmp > 0 // Compensação de RA
	
	If !lCompensac .And. Iif(FindFunction("JIsMovBco"), !JIsMovBco(SE5->E5_MOTBX), .F.) // Só cria o lançamento se o motivo movimentar banco
		lLancOk := .T.

	ElseIf SE1->E1_TIPO == MVRECANT .And. !Empty(SE5->E5_BANCO) // Baixa de RA
		lLancOk := J241EstorRA(nRecnoSE1, nRecnoSE5)

	ElseIf SE5->E5_MOTBX == 'CNF' // Cancelamento de Fatura
		lLancOk := .T.

	ElseIf SE1->E1_TIPO != MVRECANT
		cMoedaLanc := SE5->E5_MOEDA
		cMoedaTit  := StrZero(SE1->E1_MOEDA,nTamMoed) 
		nValorLiq  := SE5->E5_VALOR
		cDtBaixa   := SE5->E5_DATA
		cHistLanc  := J241HisOHB(SE1->E1_HIST, SE1->E1_JURFAT, SE1->E1_CLIENTE, SE1->E1_LOJA)
		cSeqSE5    := SE5->E5_SEQ
		If cMoedaLanc <> cMoedaNac .And. cMoedaLanc == cMoedaTit
			nTxLanc    := Iif(SE5->E5_TXMOEDA == 1 , RecMoeda(Date(), cMoedaLanc), SE5->E5_TXMOEDA)
		Else
			nTxLanc    := Iif(SE5->E5_TXMOEDA == 0 , RecMoeda(Date(), cMoedaLanc), SE5->E5_TXMOEDA)
		EndIf
		cChaveSE1  := SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO
		cNatHon    := SE1->E1_NATUREZ
		cSE1Pai    := cChaveSE1 + SE1->E1_CLIENTE + SE1->E1_LOJA
		aRetDivLan := JurLancDiv("2", nRecnoSE5)
		lLancOk    := aRetDivLan[1]
		aLancDiv   := aRetDivLan[2]
		
		cMoeNatTr    := JurGetDados('SED', 1, xFilial('SED') + cNatTrans, 'ED_CMOEJUR')
		If cMoeNatTr == cMoedaNac
			nTxMoeNaTr := nTxLanc
		Else
			nTxMoeNaTr := JA201FConv(cMoedaNac,cMoeNatTr , 1, "8", cDtBaixa, , , , , , "2", nDecimal )[1]
		EndIf

		If lLancOk
			For nLanc := 1 To Len(aLancDiv)
				// No CR não são contabilizados os descontos,
				// pois devemos apenas trabalhar com os valores efetivos (regime de caixa) e desconsiderar o valor projetado.
				If aLancDiv[nLanc][2] == cNatTrans
					Aadd(aNatTrans, {aLancDiv[nLanc][1], aLancDiv[nLanc][3], cSeqSE5, aLancDiv[nLanc][4], StrZero(SE1->E1_MOEDA,nTamMoed)} )
					Aadd(aNaturezas, aLancDiv[nLanc][1] )
					nAcresc += aLancDiv[nLanc][3]
				EndIf
			Next nLanc

			If !lCompensac
				cBcoLanc   := SE5->E5_BANCO
				cAgeLanc   := SE5->E5_AGENCIA
				cCtaLanc   := SE5->E5_CONTA
				cNatDest   := JurBusNat("", cBcoLanc, cAgeLanc, cCtaLanc)
			Else
				SE1->(DbGoto(nRegCmp))
				cNatDest := SE1->E1_NATUREZ

				SE1->(DbGoto(nRecnoSE1))
			EndIf
			
			If cMoedaLanc <> StrZero(SE1->E1_MOEDA,nTamMoed)
				nValorLiq := nValorLiq/nTxLanc
			EndIf
			Aadd(aTransNat, {cNatDest, nValorLiq, cSeqSE5, cHistLanc, StrZero(SE1->E1_MOEDA,nTamMoed)})
			Aadd(aNaturezas, cNatDest )

			// Verificar os impostos
			If SE1->E1_SALDO == 0
				SE1->(DbsetOrder(28)) // E1_FILIAL, E1_TITPAI
				SE1->( DbSeek(cSE1Pai) )

				While !SE1->( EOF() ) .And. AllTrim(cSE1Pai) == AllTrim((SE1->E1_FILIAL + SE1->E1_TITPAI))
					If SE1->E1_TIPO $ MVIRABT+"|"+MVINABT+"|"+MVCFABT+"|"+MVPIABT+"|"+MVCSABT+"|"+MVISS // IRRF, INSS, COFINS, PIS, CSLL, ISS
						// Sequencia é fixa, pois no cancelamento da baixa a sequencia não importa,
						//  qualquer cancelamento de baixa, os impostos voltam ficar em aberto.
						Aadd(aTransNat, {SE1->E1_NATUREZ, SE1->E1_VALOR, "00", cHistLanc, StrZero(SE1->E1_MOEDA,nTamMoed)} )
						Aadd(aNaturezas, SE1->E1_NATUREZ )
					EndIf
					SE1->(DbSkip())
				EndDo

				SE1->(DbGoto(nRecnoSE1))
			EndIf

			// Títulos gerados pelo PFS
			If !Empty(SE1->E1_JURFAT) .Or. JurIsJuTit(nRecnoSE1)
				aReceita := JGetReceit(cChaveSE1, cSeqSE5) //Retorna a moeda do título

				If !Empty(aReceita) .And. Len(aReceita) == 1 .And. Len(aReceita[1]) >= 2

					lAplicaImp := .F.
					nVlHon  := aReceita[1][1]
					nVlDesp := aReceita[1][2]

					If nVlHon < 0         // Caso o valor seja negativo (desconto maior que o valor de honorário)
						nVlDesp += nVlHon // abate a diferença no valor das despesas
						nVlHon  := 0
					EndIf

					If nVlHon > 0
						Aadd(aNatTrans, {cNatHon, nVlHon, cSeqSE5, cHistLanc, aReceita[1][3]} ) // Honorários
						Aadd(aNaturezas, cNatHon )
					EndIf

					If nVlDesp > 0
						Aadd(aNatTrans, {cNatDespCl, nVlDesp, cSeqSE5, cHistLanc, aReceita[1][3]} ) // Despesa
						Aadd(aNaturezas, cNatDespCl )
					Else
						// Necessário caso a baixa não tenha honorários e despesas (somente tenha valores de acréscimos) e exista algum desconto na baixa
						// Esse desconto será abatido diretamente dos acréscimos (juros, multa, taxas)
						If Len(aNatTrans) > 0
							aEval(aNatTrans, {|x| nTotAcres += x[2] }) // Total de Acréscimos
							For nLanc := 1 To Len(aNatTrans)
								aNatTrans[nLanc][2] += (aNatTrans[nLanc][2] / nTotAcres) * nVlDesp
							Next
						EndIf
					EndIf
				Else
					lLancOk := .F.
				EndIf

			Else
				nValorLiq := (SE5->E5_VALOR - nAcresc)
				If  cMoedaLanc <> StrZero(SE1->E1_MOEDA,nTamMoed)
					nValorLiq := nValorLiq/nTxLanc
				EndIf
				Aadd(aNatTrans, {SE5->E5_NATUREZ,nValorLiq, cSeqSE5, cHistLanc, StrZero(SE1->E1_MOEDA,nTamMoed) } )
				Aadd(aNaturezas, SE5->E5_NATUREZ )
			EndIf
		EndIf

		If lLancOk
			// Validações na natureza
			For nNat := 1 To Len(aNaturezas)
				cMoedaNat := JurGetDados("SED", 1, xFilial("SED") + aNaturezas[nNat], "ED_CMOEJUR" )
				If Empty(cMoedaNat)
					JurMsgErro(i18n(STR0048, {aNaturezas[nNat], RetTitle("ED_CMOEJUR")}), , STR0049) // "Natureza '#1' está com o campo '#2' vazio." , "Informe a moeda no cadastro da natureza para finalizar a baixa."
					lLancOk := .F.
					Exit
				EndIf
			Next nNat
		EndIf 

		If lLancOk
			nNat := 1
			For nNat := 1 To Len(aNatTrans)
				aAdd(aSetValue, {"OHB_ORIGEM", "2"                , .F.}) // 2=Contas a Receber
				aAdd(aSetValue, {"OHB_NATORI", aNatTrans[nNat][1] , .T.})
				aAdd(aSetValue, {"OHB_NATDES", cNatTrans          , .T.})
				aAdd(aSetValue, {"OHB_DTLANC", cDtBaixa           , .T.})
				aAdd(aSetValue, {"OHB_QTDDSD", 0                  , .F.})
				aAdd(aSetValue, {"OHB_COBRAD", ""                 , .F.})
				aAdd(aSetValue, {"OHB_DTDESP", CtoD('')           , .T.})
				aAdd(aSetValue, {"OHB_CMOELC", aNatTrans[nNat][5] , .T.})

				nValorOrc := aNatTrans[nNat][2]
				If  aNatTrans[nNat][5] <> cMoedaLanc 
					//Moeda Lançamento diferente moeda do título?
					//Grava os dados da conversao
					nValorOrc *= nTxLanc
					aAdd(aSetValue, {"OHB_COTAC",	nTxLanc 		,.T.})
					aAdd(aSetValue, {"OHB_CMOEC",	cMoedaLanc 		,.T.})
					aAdd(aSetValue, {"OHB_VALORC",	nValorOrc 		,.T.})
				ElseIf aNatTrans[nNat][5] <> cMoeNatTr  
					//Moeda Natureza destina difere da Moeda do título?
					nValorOrc *= nTxMoeNaTr
					aAdd(aSetValue, {"OHB_COTAC",	nTxMoeNaTr 	,.T.})
					aAdd(aSetValue, {"OHB_CMOEC",	cMoeNatTr 	,.T.})
					aAdd(aSetValue, {"OHB_VALORC", 	nValorOrc  	,.T.})				
				EndIf
				
				aAdd(aSetValue, {"OHB_VALOR", aNatTrans[nNat][2],.T.})

				If OHB->(ColumnPos("OHB_VLNAC")) > 0 // Proteção
					Do Case
						Case aNatTrans[nNat][5] == cMoedaNac
							nVlNac := aNatTrans[nNat][2]
						Case cMoeNatTr == cMoedaNac
							nVlNac :=  nValorOrc
						Otherwise
							If nTxLanc <> 0
								nVlNac := aNatTrans[nNat][2] * nTxLanc //utiliza a taxa da baixa //
							Else
								nVlNac := JA201FConv(cMoedaNac, aNatTrans[nNat][5] , aNatTrans[nNat][2], "8", cDtBaixa, , , , , , "2", nDecimal )[1]
							EndIf
					EndCase
					aAdd(aSetValue, {"OHB_VLNAC"  , nVlNac 	,.T.})
				EndIf
				aAdd(aSetValue, {"OHB_HISTOR" , aNatTrans[nNat][4] 	,.F.})
				aAdd(aSetValue, {"OHB_FILORI" , cFilAnt   			,.F.})
				aAdd(aSetValue, {"OHB_CRECEB" , cChaveSE1			,.F.})
				aAdd(aSetValue, {"OHB_SE5SEQ" , aNatTrans[nNat][3] 	,.F.})

				aAdd(aSetValue, {"OHB_CTRATO" , JGetTabRat(aNatTrans[nNat][1], "")  	,.F.})//gatilho do campo OHB_NATORI
  				aAdd(aSetValue, {"OHB_CTRATD" , JGetTabRat(cNatTrans, "") 				,.F.}) //gatilho do campo OHB_NATDES                                       

				// Se for execução do migrador, gera a OHB via RecLock na GrvOHBCR
				If lMigrador .And. ExistBlock("GrvOHBCR")
					U_GrvOHBCR(aSetValue)
				Else // Senão, gera via modelo
					aAdd(aSetFields, {"OHBMASTER", {} /*aSeekLine*/, AClone(aSetValue)})
					aAdd(aModelLanc, JurGrModel("JURA241", MODEL_OPERATION_INSERT, {}/*aSeek*/, AClone(aSetFields),,,.F.))
				EndIf

				JurFreeArr(@aSetValue)
				JurFreeArr(@aSetFields)

				// Se NÃO for execução do migrador valida se o modelo foi gerado
				If !lMigrador .And. aModelLanc[Len(aModelLanc)] == Nil
					lLancOk := .F.
					JurFreeArr(@aModelLanc)
					Exit
				EndIf
			Next nNat
		EndIf

		If lLancOk
			nNat := 1
			For nNat := 1 To Len(aTransNat)
				aAdd(aSetValue, {"OHB_ORIGEM" , "2"                ,.F.}) // 2=Contas a Receber
				aAdd(aSetValue, {"OHB_NATORI" , cNatTrans          ,.T.})
				aAdd(aSetValue, {"OHB_NATDES" , aTransNat[nNat][1] ,.T.})
				aAdd(aSetValue, {"OHB_DTLANC" , cDtBaixa           ,.T.})
				aAdd(aSetValue, {"OHB_QTDDSD" , 0                  ,.F.})
				aAdd(aSetValue, {"OHB_COBRAD" , ""                 ,.F.})
				aAdd(aSetValue, {"OHB_DTDESP" , CtoD('')           ,.T.})
				aAdd(aSetValue, {"OHB_CMOELC" , aTransNat[nNat][5] ,.T.})
				cMoeDest := JurGetDados('SED', 1, xFilial('SED') + aTransNat[nNat][1], 'ED_CMOEJUR')
				nValorOrc := aTransNat[nNat][2]
				If cMoeNatTr <> cMoedaLanc
					nValorOrc *= nTxMoeNaTr
					aAdd(aSetValue, {"OHB_COTAC",	nTxMoeNaTr	,.T.})
					aAdd(aSetValue, {"OHB_CMOEC",	cMoeNatTr	,.T.})
					aAdd(aSetValue, {"OHB_VALORC",	nValorOrc	,.T.})	
				ElseIf aTransNat[nNat][5] <> cMoeDest  //Moeda Natureza diferenta da moeda destino?
					If cMoeDest == cMoedaNac
						nTxDest := nTxLanc
					Else						
						nTxDest := JA201FConv(cMoedaNac,cMoeDest , 1, "8", cDtBaixa, , , , , , "2", nDecimal )[1]
					EndIf
					nValorOrc *= nTxDest
					aAdd(aSetValue, {"OHB_COTAC",	nTxDest		,.T.})
					aAdd(aSetValue, {"OHB_CMOEC",	cMoeDest 	,.T.})
					aAdd(aSetValue, {"OHB_VALORC",	nValorOrc	,.T.})						
				EndIf
					
				aAdd(aSetValue, {"OHB_VALOR",	aTransNat[nNat][2]	,.T.})

				If OHB->(ColumnPos("OHB_VLNAC")) > 0 // Proteção
					Do Case
					Case aTransNat[nNat][5] == cMoedaNac
						nVlNac := aTransNat[nNat][2] 
					Case cMoeDest == cMoedaNac
						nVlNac := nValorOrc 
					Otherwise					
						If nTxLanc <> 0
							nVlNac := aTransNat[nNat][2] * nTxLanc ////utiliza a taxa da baixa
						Else						
							nVlNac := JA201FConv(cMoedaNac, aTransNat[nNat][5], aTransNat[nNat][2], "8", cDtBaixa, , , , , , "2", nDecimal )[1]
						EndIf
					EndCase
					aAdd(aSetValue, {"OHB_VLNAC"  , nVlNac ,.T.})
				EndIf

				aAdd(aSetValue, {"OHB_HISTOR" , aTransNat[nNat][4] 	,.F.})
				aAdd(aSetValue, {"OHB_FILORI" , cFilAnt  			,.F. })
				aAdd(aSetValue, {"OHB_CRECEB" , cChaveSE1 			,.F.})
				aAdd(aSetValue, {"OHB_SE5SEQ" , aTransNat[nNat][3]	,.F. })

				aAdd(aSetValue, {"OHB_CTRATO" , JGetTabRat(cNatTrans, "")  			,.F.})//gatilho do campo OHB_NATORI
  				aAdd(aSetValue, {"OHB_CTRATD" , JGetTabRat(aTransNat[nNat][1] , "") ,.F.}) //gatilho do campo OHB_NATDES  

				// Se for execução do migrador, gera a OHB via RecLock na GrvOHBCR
				If lMigrador .And. ExistBlock("GrvOHBCR")
					U_GrvOHBCR(aSetValue)
				Else // Senão, gera via modelo
					aAdd(aSetFields, {"OHBMASTER", {} /*aSeekLine*/, AClone(aSetValue)})
					aAdd(aModelLanc, JurGrModel("JURA241", MODEL_OPERATION_INSERT, {}/*aSeek*/, AClone(aSetFields),,,.F.))
				EndIf

				JurFreeArr(@aSetValue)
				JurFreeArr(@aSetFields)

				// Se NÃO for execução do migrador valida se o modelo foi gerado
				If !lMigrador .And. aModelLanc[Len(aModelLanc)] == Nil
					lLancOk := .F.
					JurFreeArr(@aModelLanc)
					Exit
				EndIf
			Next nNat
		EndIf

		// Integração SIGAPFS x SIGAFIN - Criação de Lançamentos (OHB) no momento da baixa
		If lLancOk .And. !Empty(aModelLanc)
			For nLanc := 1 To Len(aModelLanc)
				lLancOk := aModelLanc[nLanc]:CommitData()

				If !lLancOk
					Exit
				EndIf
			Next
		EndIf
	EndIf

	Aeval( aAreas, {|aArea| RestArea( aArea ) } )

	JurFreeArr(@aNatTrans)
	JurFreeArr(@aTransNat)
	JurFreeArr(@aNaturezas)
	JurFreeArr(@aReceita)
	JurFreeArr(@aAreas)
	JurFreeArr(@aModelLanc)

Return lLancOk

//-------------------------------------------------------------------
/*/{Protheus.doc} J241EstorRA()
Utilizado na baixa do RA, para estornar o valor recebido debitando da conta do banco.

@author Bruno Ritter | Cris Cintra
@since 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241EstorRA(nRecnoSE1, nRecnoSE5)
	Local aAreas     := { SE1->(GetArea()), SE5->(GetArea()), GetArea() }
	Local cBcoLanc   := ""
	Local cAgeLanc   := ""
	Local cCtaLanc   := ""
	Local cMoedaLanc := ""
	Local cNatBanco  := ""
	Local cChaveSE1  := ""
	Local cHistLanc  := ""
	Local cMoedaNat  := ""
	Local cNatRA     := ""
	Local cNomeCli   := ""
	Local cDtBaixa   := StoD("  /  /  ")
	Local nTxLanc    := 0
	Local nValor     := 0
	Local nNat       := 0
	Local aSetValue  := {}
	Local aSetFields := {}
	Local aNaturezas := {} // Todas as naturezas para validações
	Local lLancOk    := .T.
	Local oModelLanc := Nil

	SE1->(DbGoto(nRecnoSE1))
	SE5->(DbGoto(nRecnoSE5))

	cNomeCli   := Capital(AllTrim(JurGetDados("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA, "A1_NOME")))
	cMoedaLanc := SE5->E5_MOEDA
	nValor     := SE5->E5_VALOR
	cDtBaixa   := SE5->E5_DATA
	cHistLanc  := STR0051 + " - " + SE1->E1_CLIENTE + "/" + SE1->E1_LOJA + " - " + cNomeCli // "Estorno RA"
	cHistLanc  += IIf(Empty(SE1->E1_HIST), "", " - " + Capital(AllTrim(SE1->E1_HIST)))
	cSeqSE5    := SE5->E5_SEQ
	nTxLanc    := Iif(SE5->E5_TXMOEDA == 0, RecMoeda(Date(), cMoedaLanc), SE5->E5_TXMOEDA)
	cChaveSE1  := SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO
	cBcoLanc   := SE5->E5_BANCO
	cAgeLanc   := SE5->E5_AGENCIA
	cCtaLanc   := SE5->E5_CONTA
	cNatBanco  := JurBusNat("", cBcoLanc, cAgeLanc, cCtaLanc)
	cNatRA     := SE5->E5_NATUREZ

	Aadd(aNaturezas, cNatBanco )
	Aadd(aNaturezas, cNatRA    )

	// Validações na natureza
	For nNat := 1 To Len(aNaturezas)
		cMoedaNat := JurGetDados("SED", 1, xFilial("SED") + aNaturezas[nNat], "ED_CMOEJUR")
		If Empty(cMoedaNat)
			lLancOk := JurMsgErro(i18n(STR0048, {aNaturezas[nNat], RetTitle("ED_CMOEJUR")}), , STR0049) // "Natureza '#1' está com o campo '#2' vazio." , "Informe a moeda no cadastro da natureza para finalizar a baixa."
			Exit
		EndIf
	Next nNat

	If lLancOk
		aAdd(aSetValue, {"OHB_ORIGEM" , "2"         }) // 2=Contas a Receber
		aAdd(aSetValue, {"OHB_NATORI" , cNatBanco   })
		aAdd(aSetValue, {"OHB_NATDES" , cNatRA      })
		aAdd(aSetValue, {"OHB_DTLANC" , cDtBaixa    })
		aAdd(aSetValue, {"OHB_CMOELC" , cMoedaLanc  })
		aAdd(aSetValue, {"OHB_VALOR"  , nValor      })
		If nTxLanc > 0
			aAdd(aSetValue, {"OHB_COTAC", nTxLanc })
		EndIf
		aAdd(aSetValue, {"OHB_HISTOR" , cHistLanc })
		aAdd(aSetValue, {"OHB_FILORI" , cFilAnt   })
		aAdd(aSetValue, {"OHB_CRECEB" , cChaveSE1 })
		aAdd(aSetValue, {"OHB_SE5SEQ" , cSeqSE5   })

		aAdd(aSetFields, {"OHBMASTER", {} /*aSeekLine*/, aSetValue})
		oModelLanc := JurGrModel("JURA241", MODEL_OPERATION_INSERT, {}/*aSeek*/, aSetFields)

		lLancOk := !Empty(oModelLanc) .And. oModelLanc:CommitData()
	EndIf

	Aeval( aAreas, {|aArea| RestArea( aArea ) } )

	JurFreeArr(@aSetValue)
	JurFreeArr(@aSetFields)
	JurFreeArr(@aNaturezas)
	JurFreeArr(@aAreas)

Return lLancOk

//-------------------------------------------------------------------
/*/{Protheus.doc} J241DelLan()
Deleta Lançamentos gerados pelo contas a Receber/Pagar

@author Bruno Ritter | Cris Cintra
@since 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241DelLan(nRecnoSE1, nRecnoSE5, cChaveSE1, nRecnoSE2)
	Local lRet        := .T.
	Local aModelLanc  := {}
	Local aModelImp   := {}
	Local cSeqSE5     := ""
	Local nLanc       := 0
	Local cChave      := ""
	Local cCarteira   := ""

	Default nRecnoSE1 := 0
	Default nRecnoSE5 := 0
	Default cChaveSE1 := ""
	Default nRecnoSE2 := 0

	Do Case
	Case !Empty(nRecnoSE1)
		SE1->(dbGoto(nRecnoSE1))
		cChave     := SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO
		cCarteira  := "R"

	Case !Empty(cChaveSE1)
		cChave     := cChaveSE1
		cCarteira  := "R"

	Case !Empty(nRecnoSE2)
		SE2->(dbGoto(nRecnoSE2))
		cChave     := SE2->E2_FILIAL +"|"+ SE2->E2_PREFIXO +"|"+ SE2->E2_NUM +"|"+ SE2->E2_PARCELA +"|"+ SE2->E2_TIPO +"|"+ SE2->E2_FORNECE +"|"+ SE2->E2_LOJA
		cCarteira  := "P"
	End Do

	If !Empty(nRecnoSE5) // Deleta quando for cancelmento de baixa
		SE5->(dbGoto(nRecnoSE5)) // JDelLanc Usa o Sequencia da SE5 posicionada.
		cSeqSE5 := SE5->E5_SEQ
		JurDelLanc(cChave, @aModelImp, cCarteira, "00") // Deletado os impostos

	Else // Deleta quando for exclusão de título RA
		cSeqSE5 := Space(TamSX3("E5_SEQ")[1])
	EndIf

	lRet := JurDelLanc(cChave, @aModelLanc, cCarteira, cSeqSE5)

	If !Empty(aModelLanc)
		For nLanc := 1 To Len(aModelLanc)
			lRet := aModelLanc[nLanc]:CommitData()

			If !lRet
				Exit
			EndIf
		Next
	EndIf

	If !Empty(aModelImp)
		nLanc := 1
		For nLanc := 1 To Len(aModelImp)
			lRet := aModelImp[nLanc]:CommitData()

			If !lRet
				Exit
			EndIf
		Next
	EndIf

	JurFreeArr(@aModelLanc)
	JurFreeArr(@aModelImp)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241InsAD
Cria os lançamentos (OHB) na inclusão de RA e PA

@author Bruno Ritter
@since 21/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241InsAD(nRecnoSE1, nRecnoSE2, nRecnoSE5)
	Local aAreas     := { SE1->(GetArea()), SE2->(GetArea()), SE5->(GetArea()), GetArea() }
	Local cBcoLanc   := ""
	Local cAgeLanc   := ""
	Local cCtaLanc   := ""
	Local cMoedaLanc := ""
	Local cNatBanco  := ""
	Local cChaveSE1  := ""
	Local cChaveSE2  := ""
	Local cHistLanc  := ""
	Local cMoedaNat  := ""
	Local cNatAdiant := ""
	Local cDtLanc    := ""
	Local nValor     := 0
	Local nNat       := 0
	Local nCotac     := 0
	Local nValorNac  := 0
	Local aSetValue  := {}
	Local aSetFields := {}
	Local aNaturezas := {} // Todas as naturezas para validações
	Local lLancOk    := .T.
	Local oModelLanc := Nil
	Local lAdiantam  := .F.
	Local cNatDest   := ""
	Local cNatOrig   := ""
	Local cOrigem    := ""
	Local cNatTranPg := ""
	Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01' ) // Moeda Nacional
	Local cMoeDest   := ""

	Default nRecnoSE1 := 0
	Default nRecnoSE2 := 0
	Default nRecnoSE5 := 0

	If nRecnoSE1 != 0
		SE1->(DbGoto(nRecnoSE1))
		cOrigem   := "2"
		lAdiantam := SE1->E1_TIPO == MVRECANT // Tipo = RA

		If lAdiantam
			cChaveSE1  := SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO

			cBcoLanc   := SE1->E1_PORTADO
			cAgeLanc   := SE1->E1_AGEDEP
			cCtaLanc   := SE1->E1_CONTA
			cMoedaLanc := StrZero(SE1->E1_MOEDA, 2)
			nValor     := SE1->E1_VALOR
			cDtLanc    := SE1->E1_EMISSAO
			cNatAdiant := SE1->E1_NATUREZ
			nCotac     := SE1->E1_TXMOEDA

			If FWIsInCallStack("JA069PFIN") // RA criado atráves do controle de adiantamento (NWF)
				cHistLanc := J241HisLanc(NWF->NWF_HIST)
			Else
				cHistLanc := STR0050 + " - " + SE1->E1_CLIENTE + "/" + SE1->E1_LOJA + " - " // "Recebimento Antecipado"
				cHistLanc += Capital(SE1->E1_NOMCLI)
				cHistLanc += Iif(!Empty(SE1->E1_HIST), " - " + Capital(AllTrim(SE1->E1_HIST)), "")
			EndIf

		EndIf
	EndIf

	If nRecnoSE2 != 0 .And. nRecnoSE5 != 0
		SE2->(DbGoto(nRecnoSE2))
		SE5->(DbGoto(nRecnoSE5))

		// Confere se o recno é válido, pois existe situações que a inclusão do PA não gera SE5
		If SE5->(!Eof())
			cOrigem    := "1"
			lAdiantam  := SE2->E2_TIPO $ MVPAGANT // Tipo = PA
			cNatTranPg := JurBusNat("7")
	
			If lAdiantam
				cChaveSE2  := SE2->E2_FILIAL +"|"+ SE2->E2_PREFIXO +"|"+ SE2->E2_NUM +"|"+ SE2->E2_PARCELA +"|"+ SE2->E2_TIPO +"|"+ SE2->E2_FORNECE +"|"+ SE2->E2_LOJA
	
				cBcoLanc   := SE5->E5_BANCO
				cAgeLanc   := SE5->E5_AGENCIA
				cCtaLanc   := SE5->E5_CONTA
				cMoedaLanc := SE5->E5_MOEDA
				nValor     := SE5->E5_VALOR
				cDtLanc    := SE5->E5_DATA
				cNatAdiant := cNatTranPg
	
				cHistLanc := STR0054 + " - " + AllTrim(SE2->E2_FORNECE) + "/" + AllTrim(SE2->E2_LOJA) + " - " // "Pagamento Antecipado"
				cHistLanc += Capital(AllTrim(JurGetDados("SA2", 1, xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA , "A2_NOME")))
				cHistLanc += Iif(!Empty(SE2->E2_HIST), " - " + Capital(AllTrim(SE2->E2_HIST)), "")

			EndIf
		EndIf
	EndIf

	If lAdiantam
		cNatBanco := JurBusNat("", cBcoLanc, cAgeLanc, cCtaLanc)
		Aadd(aNaturezas, cNatAdiant)
		Aadd(aNaturezas, cNatBanco )

		// Validações na natureza
		For nNat := 1 To Len(aNaturezas)
			cMoedaNat := JurGetDados("SED", 1, xFilial("SED") + aNaturezas[nNat], "ED_CMOEJUR" )
			If Empty(cMoedaNat)
				lLancOk := JurMsgErro(i18n(STR0048, {aNaturezas[nNat], RetTitle("ED_CMOEJUR")}), , STR0049) // "Natureza '#1' está com o campo '#2' vazio." , "Informe a moeda no cadastro da natureza para finalizar a baixa."
				Exit
			EndIf
		Next nNat

		If lLancOk
			If cOrigem == "1" // PA
				cNatOrig   := cNatBanco
				cNatDest   := cNatAdiant
			Else // RA
				cNatOrig   := cNatAdiant
				cNatDest   := cNatBanco
				cMoeDest   := cMoedaNat
			EndIf

			aAdd(aSetValue, {"OHB_ORIGEM", cOrigem   })
			aAdd(aSetValue, {"OHB_NATORI", cNatOrig  })
			aAdd(aSetValue, {"OHB_NATDES", cNatDest  })
			aAdd(aSetValue, {"OHB_DTLANC", cDtLanc   })
			aAdd(aSetValue, {"OHB_CMOELC", cMoedaLanc})
			aAdd(aSetValue, {"OHB_VALOR" , nValor    })
			
			If !Empty(cChaveSE1) .And. nCotac > 0
				aAdd(aSetValue, {"OHB_COTAC" , IIf(cMoedaLanc == cMoeDest , 0     , nCotac         )})
				aAdd(aSetValue, {"OHB_VALORC", IIf(cMoedaLanc == cMoeDest , 0     , nCotac * nValor)})
			
				If cMoeDest == cMoedaNac .Or. cMoedaLanc == cMoeDest
					nValorNac := nCotac * nValor
				Else
					nTaxa     := J201FCotDia(cMoedaLanc, cMoedaNac, cDtLanc, xFilial("CTP"))[1]
					nValorNac := IIF(nTaxa > 0, Round(nTaxa * nValor, TamSX3('OHB_VLNAC')[2]), nValor)
				EndIf

				aAdd(aSetValue, {"OHB_VLNAC" , nValorNac})
			EndIf

			aAdd(aSetValue, {"OHB_HISTOR", cHistLanc})
			aAdd(aSetValue, {"OHB_FILORI", cFilAnt  })
			If !Empty(cChaveSE1)
				aAdd(aSetValue, {"OHB_CRECEB", cChaveSE1})
			EndIf
			If !Empty(cChaveSE2)
				aAdd(aSetValue, {"OHB_CPAGTO", cChaveSE2})
			EndIf

			aAdd(aSetFields, {"OHBMASTER", {} /*aSeekLine*/, aSetValue})
			oModelLanc := JurGrModel("JURA241", MODEL_OPERATION_INSERT, {}/*aSeek*/, aSetFields)

			lLancOk := !Empty(oModelLanc) .And. oModelLanc:CommitData()
		EndIf

		oModelLanc := Nil
	EndIf

	Aeval( aAreas, {|aArea| RestArea( aArea ) } )

	JurFreeArr(@aSetValue)
	JurFreeArr(@aSetFields)
	JurFreeArr(@aNaturezas)
	JurFreeArr(@aAreas)

Return lLancOk

//-------------------------------------------------------------------
/*/{Protheus.doc} J241UpdRA()
Altera o lançamento (OHB) na alteração do RA

@author Bruno Ritter
@since 28/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241UpdRA(nRecnoSE1)
	Local aAreas     := { SE1->(GetArea()), GetArea() }
	Local aSetValue  := {}
	Local aSetFields := {}
	Local aSeek      := {}
	Local aCpoSeek   := {}
	Local aCodOHB    := {}
	Local lLancOk    := .T.
	Local oModelLanc := Nil

	SE1->(DbGoto(nRecnoSE1))
	If SE1->E1_TIPO == MVRECANT // Tipo = RA
		cChaveSE1  := SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO

		aAdd(aCpoSeek, {"OHB_SE5SEQ", Space(TamSX3("E5_SEQ")[1]) } )
		aAdd(aCpoSeek, {"OHB_CRECEB", cChaveSE1  } )

		aCodOHB := JGetInfOHB("OHB_CODIGO", aCpoSeek)

		If !Empty(aCodOHB) .And. Len(aCodOHB) == 1 .And. Len(aCodOHB[1]) == 1
			aAdd(aSeek, "OHB")
			aAdd(aSeek, 1)
			// Só pode existir um lançamento com vinculo ao título sem SE5SEQ,
			// pois é criado OHB com SE5SEQ vazio apenas na inclusão do RA
			aAdd(aSeek, xFilial("OHB") + aCodOHB[1][1])
		Else
			lLancOk := .F.
		EndIf

		oModelLanc := Nil
	EndIf

	Aeval( aAreas, {|aArea| RestArea( aArea ) } )

	JurFreeArr(@aSetValue)
	JurFreeArr(@aSetFields)
	JurFreeArr(@aSeek)
	JurFreeArr(@aCpoSeek)
	JurFreeArr(@aCodOHB)
	JurFreeArr(@aAreas)

Return lLancOk

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetReceit()
Rotina para retorna o valor recebido em uma baixa de um CR

@param cChaveSE1, Chave unica SE1
@param cSeqSE5, Número de sequencia de baixa da SE5

@author Bruno Ritter
@since 29/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JGetReceit(cChaveSE1, cSeqSE5)
	Local cQuery  := ""

	cQuery := " SELECT "
	cQuery +=     " SUM(OHI.OHI_VLHCAS - OHI.OHI_VLDESH) HON, "
	cQuery +=     " SUM(OHI.OHI_VLDCAS - OHI.OHI_VLDESD) DESPESA,  "
	cQuery +=     " OHI.OHI_CMOEDA MOEDA "
	cQuery += " FROM " + RetSqlName("OHI") + " OHI "
	cQuery += " WHERE OHI.OHI_FILIAL = '" + xFilial("OHI") + "' "
	cQuery +=     " AND OHI_CHVTIT = '" + cChaveSE1 + "' "
	cQuery +=     " AND OHI_SE5SEQ = '" + cSeqSE5 + "' "
	cQuery +=     " AND OHI.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY OHI.OHI_CMOEDA, OHI.OHI_SE5SEQ "

	cQuery := ChangeQuery(cQuery)
	aRet   := JurSQL(cQuery, {"HON", "DESPESA", "MOEDA"})

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241ExcAnx()
Exclui os anexos do lançamento que está sendo deletado

@param oModel, Modelo de dados da tabela OHB

@author Jorge Martins
@since  21/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J241ExcAnx(oModel)
Local oModelOHB  := oModel:GetModel("OHBMASTER")
Local cChave     := ""

	dbSelectArea( 'NUM' )
	NUM->( DbSetOrder(3) ) // NUM_FILIAL + NUM_ENTIDA + NUM_CENTID

	cChave := xFilial("NUM") + "OHB" + oModelOHB:GetValue("OHB_FILIAL") + oModelOHB:GetValue("OHB_CODIGO")

	While NUM->(DbSeek(cChave))
		Reclock("NUM", .F.)
		NUM->( DbDelete() )
		NUM->( MsUnLock() )
	EndDo

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J241VldPar()
Rotina de dicionário para validar o participante consideram se esta
bloqueado somente quando a origem for de 5-Digitação.

@Param cSigla  Código da Sigla do participante

@Return lRet   .T. Validação Ok.

@author Luciano Pereira dos Santos
@since 10/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241VldPar(cSigla)
	Local lRet    := .T.
	Local lValBlq := M->OHB_ORIGEM $ "4|5"

	lRet := ExistCpo("RD0", cSigla, 9, , , lValBlq)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241VldEsc()
Rotina de dicionário para validar o escritório considerando se esta
bloqueado, somente quando a origem for de 5-Digitação.

@Param cEscrit  Código do escritório

@Return lRet   .T. Validação Ok.

@author Luciano Pereira dos Santos
@since 10/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241VldEsc(cEscrit)
	Local lRet    := .T.
	Local lValBlq := M->OHB_ORIGEM $ "4|5"
	Local lValFat := .F.

	lRet := JAVLESCRIT(cEscrit, lValBlq, lValFat)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241VldCC()
Rotina de dicionário para validar o c. custo considerando se esta
bloqueado, somente quando a origem for de 5-Digitação.

@Param cOrigem  "O" Centro de custo origem, "D" Destino

@Return lRet   .T. Validação Ok.

@author Luciano Pereira dos Santos
@since 10/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241VldCC(cOrigem)
	Local lRet     := .T.
	Local lValBlq  := M->OHB_ORIGEM $ "4|5"
	Local cCpoEscr := ""
	Local cCpoCC   := ""

	If cOrigem == "O"
		cCpoEscr := "OHB_CESCRO"
		cCpoCC   := "OHB_CCUSTO"
	ElseIf cOrigem == "D"
		cCpoEscr := "OHB_CESCRD"
		cCpoCC   := "OHB_CCUSTD"
	EndIf

	lRet := JVldCTTNS7(cCpoEscr, cCpoCC, lValBlq)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241VldTpD()
Rotina de dicionário para validar o tipo de despesa considerando se esta
bloqueado, somente quando a origem for de 5-Digitação.

@Param cTpDesp  Código da Sigla do participante

@Return lRet   .T. Validação Ok.

@author Luciano Pereira dos Santos
@since 10/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241VldTpD(cTpDesp)
	Local lRet    := .T.
	Local lValBlq := M->OHB_ORIGEM $ "4|5"

	lRet := JurVlTpDp(cTpDesp, lValBlq)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241VldTpD(cOrigem, cTipo)
Rotina de dicionário para validar o cliente, loja, caso considerando
se esta bloqueado, somente quando a origem for de 5-Digitação.

@Param cOrigem  Direção "O" Cliente loja e caso de Origem, "D" Destino
@Param cTipo    Tipo de validação 'CLI' -Cliente, 'LOJ'- Loja, 'CAS' - Caso

@Return lRet .T. Validação Ok.

@author Luciano Pereira dos Santos
@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241VldCli(cOrigem, cTipo)
	Local lRet    := .T.
	Local lValBlq := M->OHB_ORIGEM $ "4|5"
	Local cClient := ""
	Local cLoja   := ""
	Local cCaso   := ""
	Local cLanc   := ""

	If cOrigem == "D"
		cClient := M->OHB_CCLID
		cLoja   := M->OHB_CLOJD
		cCaso   := M->OHB_CCASOD
		cLanc   := "NVE_LANDSP"
	EndIf

	lRet := JurVldCli("", cClient, cLoja, cCaso, cLanc, cTipo, , , , lValBlq)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241VldPro
Rotina de dicionário para validar o projeto, considerando
se esta bloqueado, somente quando a origem for de 5-Digitação.

@Param cProjeto codigo do projeto a ser validado

@author Luciano Pereira dos Santos
@since   14/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241VldPro(cProjeto)
	Local lRet    := .T.
	Local lValBlq := M->OHB_ORIGEM $ "4|5"

	lRet := JurVldProj(cProjeto, "2", lValBlq)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241VldRat
Rotina de dicionário para validar o projeto, considerando
se esta bloqueado, somente quando a origem for de 5-Digitação.

@Param cRateio codigo do Rateio a ser validado

@author Luciano Pereira dos Santos
@since   15/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J241VldRat(cRateio)
	Local lRet    := .T.
	Local lValBlq := M->OHB_ORIGEM $ "4|5"

	lRet := JURRAT(cRateio, lValBlq)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241HisOHB
Retorna o histório para o lançamento gerado a partir da baixa do CR.
 - Se o título está vinculado a uma fatura deverá informar:
   - Escritório/Fatura - Nome do Cliente - Histórico que veio do título SE1
 - Se o título NÃO está vinculado a uma fatura deverá informar:
   - Código/Loja do Cliente - Nome do Cliente - Histórico que veio do título SE1

@param cHistSE1, Histórico do título - SE1
@param cJurFat , Número Fatura (SIGAPFS) vinculada ao título
@param cCliSE1 , Cliente do título
@param cLojSE1 , Loja/Endereço do Cliente do título
@param cCompIni, Complemento para concatenação inicial
@param lJura069, Execução chamada através do controle de adiantamento JURA069

@return cHist  , Histórico da baixa

@author Jorge Martins
@since  03/07/2019
/*/
//-------------------------------------------------------------------
Function J241HisOHB(cHistSE1, cJurFat, cCliSE1, cLojSE1, cCompIni, lJura069)
	Local nTamFil  := 0
	Local nTamEsc  := 0
	Local nTamFat  := 0
	Local cFilNXA  := ""
	Local cEscrit  := ""
	Local cFatura  := ""
	Local cHist    := ""
	Local cNomCli  := ""
	Local aInfoNXA := {}

	Default cHistSE1 := ""
	Default cJurFat  := ""
	Default cCliSE1  := ""
	Default cLojSE1  := ""
	Default cCompIni := ""
	Default lJura069 := .F.

	If !Empty(cJurFat)
		cJurFat  := Strtran(cJurFat, "-", "")

		nTamFil  := TamSX3("NXA_FILIAL")[1]
		nTamEsc  := TamSX3("NXA_CESCR")[1]
		nTamFat  := TamSX3("NXA_COD")[1]
		cFilNXA  := Substr(cJurFat, 1, nTamFil)
		cEscrit  := Substr(cJurFat, nTamFil+1, nTamEsc)
		cFatura  := Substr(cJurFat, nTamFil+nTamEsc+1, nTamFat)

		aInfoNXA := JurGetDados("NXA", 1, cFilNXA + cEscrit + cFatura , {"NXA_CCLIEN","NXA_CLOJA"})
		cNomCli  := Capital(AllTrim(JurGetDados("SA1", 1, xFilial("SA1") + aInfoNXA[1] + aInfoNXA[2] , "A1_NOME")))
		cHist    := cEscrit + "/" + cFatura + " - " + aInfoNXA[1] + "/" + aInfoNXA[2] + " - " + cNomCli
	ElseIf lJura069
		cHist    := J241HisLanc(cHistSE1)
	Else
		cNomCli  := Capital(AllTrim(SE1->E1_NOMCLI))
		cHist    := cCompIni + cCliSE1 + "/" + cLojSE1 + " - " + cNomCli + IIf(Empty(cHistSE1), "", " - " + Capital(AllTrim(cHistSE1)))
	EndIf

	JurFreeArr(@aInfoNXA)

Return cHist

//-------------------------------------------------------------------
/*/{Protheus.doc} J241EstCtb
Função que chama o estorno da contabilização lançamento 
quando já contabilizado e houve alteração ou na exclusão.

@Param oMdlLanc, Objeto, Modelo de dados de lançamentos

@author Jonatas Martins
@since  14/10/2019
@Obs    Nesse ponto está posicionado na linha da OHF que sofreu modificação
/*/
//-------------------------------------------------------------------
Function J241EstCtb(oMdlLanc)
Local nRecLanc  := 0
Local lDeleted  := .F.
Local lModified := .F.
Local lReversal := .F.
Local cCpoFlag  := ""
Local cFilBkp   := ""
	
Default oMdlLanc := Nil

	cCpoFlag := J265LpFlag("942") // Busca campo de flag da contabilização
		
	If !Empty(oMdlLanc:GetValue(cCpoFlag)) // Verifica se o registro está contabilizado "947"
		cFilBkp   := cFilAnt
		cFilAnt   := OHB->OHB_FILIAL
		lDeleted  := oMdlLanc:GetOperation() == MODEL_OPERATION_DELETE
		lModified := lDeleted .Or. J241IsUpd(oMdlLanc)
		If lModified
			nRecLanc  := oMdlLanc:GetDataID()
			lReversal := JURA265B("956", nRecLanc) // Estorno da contabilização de Lançamentos
			If lReversal .And. !lDeleted
				AAdd(_aRecLanCtb, nRecLanc)
			EndIf
		EndIf
		cFilAnt := cFilBkp
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J241IsUpd
Avalia a alteração de dados de lançamento

@Param  oMdlDes  , Objeto, Modelo de dados de desdobramentos/desd. pós pagamento

@Return lModified, logico, Se .T. o desdobramento foi modificados

@author Jonatas Martins
@Obs    Não utilizado o método IsFieldUpdated pois há situações
        que o campo não foi alterado e o método retorna .T.
/*/
//-------------------------------------------------------------------
Static Function J241IsUpd(oMdlLanc)
	Local aFields    := {"OHB_NATORI", "OHB_NATDES", "OHB_CCLID", "OHB_CLOJD", "OHB_CDESPD", "OHB_CTPDPD", "OHB_VALOR"}
	Local aValues    := {}
	Local cValue     := ""
	Local nFld       := 0
	Local lModified  := .F.

	AEval(aFields, {|cField| xValue := oMdlLanc:GetValue(cField), AAdd(aValues, {xValue, ValType(xValue)})})

	cQuery := "SELECT OHB_CODIGO"
	cQuery +=  " FROM " + RetSqlName("OHB")
	cQuery += " WHERE OHB_FILIAL = '" + xFilial("OHB") + "' AND "
	For nFld := 1 To Len(aFields)
		cValue := J246ConvVal(aValues[nFld][1], aValues[nFld][2])
		cQuery += aFields[nFld] + " = " + cValue + " AND "
	Next nFld
	cQuery += "D_E_L_E_T_ = ' '"

	aRetSql := JurSQL(cQuery, "*")

	// Avalia se o registro permanece inalterado no banco de dados
	lModified := Empty(aRetSql)

Return (lModified)

//-------------------------------------------------------------------
/*/{Protheus.doc} J241Cmmt
Verifica se deve ser realizada a operação de commit do Modelo

@Param  oModel  , Objeto, Modelo de dados do Lançamento

@Return lRet    , logico, Se .T. o modelo foi saldo

@author fabiana.silva
/*/
//-------------------------------------------------------------------
Function J241Cmmt(oModel)
Local nModelOp   := oModel:GetOperation()
Local lRet       := .T.
Local cLog       := ""

	// Atualiza os saldos da conta bancária quando for um lançamento digitado ou de integração
	If oModel:GetValue("OHBMASTER", "OHB_ORIGEM") $ "4|5" //Integração e Digitada
		lRet := J241GerMBc(oModel, nModelOp, @cLog)
	EndIf

	If lRet
		FwFormCommit(oModel)
		
		If OHB->(ColumnPos("OHB_CODCF8")) > 0 // Proteção criado no release 12.1.37
			J241EFD(oModel, nModelOp) // Grava registros da EFD na CF
		EndIf
	Else	
		oModel:SetErrorMessage(,, oModel:GetId(),, "J241Cmmt", cLog,,)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J241HisLanc
Monta texto de histórico do lançamento (OHB) do título de adiantamento

@param  cHist    , Texto do histórico que será concatenado

@Return cHistLanc, Texto do histórico do lançamento

@author Jonatas Martins
@since  25/10/2021
@Obs    Função chamada no fonte JURA241 nas funções J241InsAD e J241HisOHB
/*/
//-------------------------------------------------------------------
Static Function J241HISLANC(cHist)
Local cHistLanc := ""
Local cNomeCli  := ""

Default cHist   := ""

	cNomeCli  := JurGetDados("SA1", 1, xFilial("SA1") + NWF->NWF_CCLIAD + NWF->NWF_CLOJAD, "A1_NOME")
	cHistLanc := STR0050 + " - " // "Recebimento Antecipado - "
	cHistLanc += AllTrim(NWF->NWF_CESCR) + "/" + NWF->NWF_COD + " - "
	cHistLanc += AllTrim(NWF->NWF_CCLIAD) + "/" + AllTrim(NWF->NWF_CLOJAD) + " - "
	cHistLanc += AllTrim(cNomeCli) + " - " + AllTrim(cHist)
	cHistLanc := LmpCpoHis(cHistLanc)

Return (cHistLanc)

//-------------------------------------------------------------------
/*/{Protheus.doc} J241EFD
Função para gravar tabela da CF8 referente a EFD

@param  oModel  , Objeto do modelo de dados do lançamento JURA241
@param  nModelOp, Número da operação do modelo de dados

@author Jonatas Martins
@since  04/11/2021
/*/
//-------------------------------------------------------------------
Static Function J241EFD(oModel, nModelOp)
Local cCodCF8   := oModel:GetValue("OHBMASTER", "OHB_CODCF8")
Local lInsert   := nModelOp == MODEL_OPERATION_INSERT
Local cNatureza := ""
Local lGravaCF8 := .F.

	If !lInsert .And. !Empty(cCodCF8) // Exclusão ou Alteração
		J241DelCF8(cCodCF8) // Deleta registro da CF8
	EndIf

	If nModelOp <> MODEL_OPERATION_DELETE .And. Existblock("J241EFD") // Inclusão ou Alteração
		cNatureza := J241NatEFD(oModel)

		If !Empty(cNatureza)
			lGravaCF8 := Execblock("J241EFD", .F., .F., {cNatureza})

			If ValType(lGravaCF8) == "L" .And. lGravaCF8
				J241GrvCF8(cNatureza, oModel)
			EndIf
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J241DelCF8
Exclui registro da EFD (CF8) vinculado ao lançamento (OHB)

@param  cCodCF8, Código do registro da EFD na tabela CF8

@author Jonatas Martins
@since  04/11/2021
/*/
//-------------------------------------------------------------------
Static Function J241DelCF8(cCodCF8)
Local aArea    := GetArea()
Local aAreaCF8 := CF8->(GetArea())

	CF8->(DbSetOrder(1)) // CF8_FILIAL + CF8_CODIGO
	If CF8->(DbSeek(xFilial("CF8") + cCodCF8))
		RecLock("CF8", .F.)
			CF8->(DbDelete())
		CF8->(MsUnlock())
	EndIf
	
	RestArea(aAreaCF8)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J241NatEFD
Avalia se as naturezas do lançamento (Origem ou Destino) apuram PIS ou COFINS
para utilizar na gravação da EFD.

@param  oModel   , Objeto do modelo de dados do lançamento JURA241

@return cNatureza, Natureza origem ou destino do lançamento (OHB)
                   que será utilizada na gravação da EFD (CF8)

@author Jonatas Martins
@since  04/11/2021
@obs    Apenas uma das naturezas do lançamento poderá ser utilizada na gravação.
/*/
//-------------------------------------------------------------------
Static Function J241NatEFD(oModel)
Local oModelOHB := oModel:GetModel("OHBMASTER")
Local cNatureza := oModelOHB:GetValue("OHB_NATORI") // Natureza de Origem
Local aDadosNat := JurGetDados("SED", 1, xFilial("SED") + cNatureza, {"ED_APURCOF", "ED_APURPIS"})

	If Empty(aDadosNat) .Or. (Empty(aDadosNat[1]) .And. Empty(aDadosNat[2])) // Não possui apuração de PIS ou COFINS
		cNatureza := oModelOHB:GetValue("OHB_NATDES") // Natureza de destino
		aDadosNat := JurGetDados("SED", 1, xFilial("SED") + cNatureza, {"ED_APURCOF", "ED_APURPIS"})

		If Empty(aDadosNat) .Or. (Empty(aDadosNat[1]) .And. Empty(aDadosNat[2])) // Não possui apuração de PIS ou COFINS
			cNatureza := ""
		EndIf
	EndIf

Return (cNatureza)

//-------------------------------------------------------------------
/*/{Protheus.doc} J241GrvCF8
Efetiva a gravação da EFD

@param cNatureza, Natureza origem ou destino do lançamento (OHB)
@param  oModel  , Objeto do modelo de dados do lançamento JURA241

@author Jonatas Martins
@since  04/11/2021
/*/
//-------------------------------------------------------------------
Static Function J241GrvCF8(cNatureza, oModel)
Local aArea      := GetArea()
Local aAreaSED   := SED->(GetArea())
Local cCodigo    := ""
Local cIndOri    := ""
Local cHistor    := ""
Local cTpRegime  := ""
Local dDataLanc  := Nil
Local nValorNac  := 0
Local nValBase   := 0
Local nValBasCof := 0
Local nValCof    := 0
Local nValBasPIS := 0
Local nValPIS    := 0

	If SED->(DbSeek(xFilial("SED") + cNatureza))
		cCodigo    := GetSXENum("CF8", "CF8_CODIGO")
		cIndOri    := Criavar("CF8_INDORI", .T.)
		cIndOri    := IIF(Empty(cIndOri), "0", cIndOri)
		oModelOHB  := oModel:GetModel("OHBMASTER")
		nValorNac  := oModelOHB:GetValue("OHB_VLNAC")
		nValBase   := nValorNac
		dDataLanc  := oModelOHB:GetValue("OHB_DTLANC")
		cHistor    := SubStr(AllTrim(StrTran(oModelOHB:GetValue("OHB_HISTOR"), CRLF, " ")), 1, TamSx3("CF8_DESCPR")[1])
		
		// SED - 1=Nao Cumulativo;2=Cumulativo
		// CF8 - 1=Cumulativo;2=Não Cumulativo
		If SED->ED_TPREG == "1"
			cTpRegime := "2"
		ElseIf SED->ED_TPREG == "2"
			cTpRegime := "1"
		EndIf

		// Calcula redução da base do PIS e COFINS
		If !Empty(SED->ED_REDPIS) .And. Empty(SED->ED_PERCPIS)
			nValBase *= SED->ED_REDPIS / 100
		ElseIf !Empty(SED->ED_REDCOF) .And. Empty(SED->ED_PERCCOF)
			nValBase *= SED->ED_REDCOF / 100
		EndIf

		// Base COFINS
		If !(SED->ED_CSTCOF $ "07_08_09_49")
			nValBasCof := nValBase
			
			// Valor COFINS
			If !Empty(SED->ED_APURCOF)
				nValCof := nValBasCof * SED->ED_PCAPCOF / 100
			EndIf
		EndIf
		
		// Base e valor PIS
		If !(SED->ED_CSTPIS $ "07_08_09_49")
			nValBasPIS := nValBase
			nValPIS    := nValBasPIS * SED->ED_PCAPPIS / 100
		EndIf

		RecLock("CF8", .T.)
			CF8->CF8_FILIAL := xFilial("CF8")
			CF8->CF8_CODIGO := cCodigo
			CF8->CF8_TPREG  := cTpRegime
			CF8->CF8_INDOPE := SED->ED_RECDAC
			CF8->CF8_DTOPER := dDataLanc
			CF8->CF8_VLOPER := nValorNac
			CF8->CF8_CSTCOF := SED->ED_CSTCOF
			CF8->CF8_ALQCOF := SED->ED_PCAPCOF
			CF8->CF8_BASCOF := nValBasCof
			CF8->CF8_VALCOF := nValCof
			CF8->CF8_CSTPIS := SED->ED_CSTPIS
			CF8->CF8_ALQPIS := SED->ED_PCAPPIS
			CF8->CF8_BASPIS := nValBasPIS
			CF8->CF8_VALPIS := nValPIS
			CF8->CF8_INDORI := cIndOri
			CF8->CF8_CODCTA := SED->ED_CONTA
			CF8->CF8_DESCPR := cHistor
		CF8->(MsUnLock())

		If __lSX8
			ConFirmSX8()
			
			RecLock("OHB", .F.)
				OHB->OHB_CODCF8 := cCodigo
			OHB->(MsUnLock())
		EndIf
	EndIf

	RestArea(aAreaSED)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J241VldNat( cNatu, cCampoNatu, cCampoWhen )
Valida se deve habilitar / bloquear os campos de detalhes de acordo
com o parâmetro MV_JDETDES

@Param  cNatu      - Código da natureza origem / destino selecionada
@Param  cCampoNatu - Campo da natureza de origem / destino
@Param  cCampoWhen - Valor no centro de custo jurídico na natureza
@Return lRet (.T. / .F.) - Permite alterar o campo?

@since 01/04/2022
/*/
//-------------------------------------------------------------------
Static Function J241VldNat( cNatu, cCampoNatu, cCampoWhen )

Local lRet       := .T.
Local cNatureza  := IIF( VALTYPE(cNatu) <> "U", cNatu, "" )
Local cClassNat  := ""

	If !Empty( cNatureza )
		cClassNat := JurGetDados("SED", 1, xFilial("SED") + cNatureza, "ED_CCJURI")

		If Empty( cClassNat )
			lRet := SuperGetMV('MV_JDETDES', .T., '1') == '1'
		EndIf
	EndIf

	If lRet
		// Campos da origem
		If cCampoNatu == "OHB_NATORI"
			lRet := JurWhNatCC(cCampoWhen, "OHBMASTER", cCampoNatu, "OHB_CESCRO", "OHB_CCUSTO", "OHB_SIGLAO", "OHB_CTRATO")
		EndIf

		// Campos da destino
		If cCampoNatu == "OHB_NATDES"
			lRet := JurWhNatCC(cCampoWhen, "OHBMASTER", cCampoNatu, "OHB_CESCRD", "OHB_CCUSTD", "OHB_SIGLAD", "OHB_CTRATD")
		EndIf
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J241ExecCp()
Abre a tela de Lançamento com os dados copiados

@param oModel    , modelo principal da JURA241

@author Carolina Neiva Ribeiro / Glória Maria Ribeiro
@since  19/08/2022

@return Nil
/*/
//-------------------------------------------------------------------
Function J241ExecCp()
Local oModel := FwLoadModel("JURA241")
	oModel := J241CpLan(oModel)
	FWExecView(STR0071,'JURA241', 3, , , , , , , ,, oModel)//"Copiar Lançamento"
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J241CpLan(oModel) 
Função para copiar um lançamento já existente

@param oModel    , modelo principal da JURA241

@author Carolina Neiva Ribeiro / Glória Maria Ribeiro
@since  19/08/2022
@return Nil

/*/
//-------------------------------------------------------------------
Function J241CpLan(oModel)
Local aNaoCopiar := {"OHB_CPART","OHB_CODIGO","OHB_DTINCL","OHB_CUSINC","OHB_SIGLAI","OHB_ORIGEM","OHB_CODCF8","OHB_LOTE","OHB_SEQCON","OHB_CODLD","OHB_DTCONT","OHB_CRECEB","OHB_ITDPGT","OHB_ITDES","OHB_CPAGTO","OHB_SE5SEQ","OHB_DTALTE","OHB_CUSALT","OHB_CDESPD"}
Local cCampo     := ""
Local nLine      := 0
Local dData      := DATE()
Local oModelOHB  := oModel:GetModel("OHBMASTER")
Local aFields    := oModelOHB:GetStruct():GetFields() 

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	For nLine := 1 To len(aFields) //PASSA POR TODOS OS CAMPOS DA OHB
		cCampo := AllTrim(aFields[nLine][3])
		If  ascan(aNaoCopiar,{|x| x==cCampo})>0
			If cCampo == "OHB_ORIGEM"
				oModelOHB:SetValue(cCampo, '5')
			ElseIf cCampo == "OHB_DTINCL"
				oModelOHB:SetValue(cCampo, dData)
			ElseIf cCampo == "OHB_CUSINC"
				oModelOHB:SetValue(cCampo, __cUserID)
			ElseIf cCampo == "OHB_SIGLAI"
				oModelOHB:SetValue(cCampo,;
				AllTrim(JurGetDados("RD0",1,xFilial("RD0")+JurUsuario(__cUserId), "RD0_SIGLA")))
			EndIf

		ElseIf oModelOHB:CanSetValue(cCampo) .And. !aFields[nLine][14] // Campo editável e NÃO é virtual
			If !(oModelOHB:SetValue(cCampo, OHB->&(cCampo)))
				If GetSx3Cache(cCampo, 'X3_TIPO') == "C"
					oModelOHB:SetValue(cCampo, "")
				EndIf
			EndIf	

		ElseIf oModelOHB:CanSetValue(cCampo) .And. cCampo == "OHB_SIGLA" 
			oModelOHB:SetValue(cCampo,;
				AllTrim(JurGetDados("RD0",1,xFilial("RD0")+OHB->OHB_CPART, "RD0_SIGLA")))

		ElseIf oModelOHB:CanSetValue(cCampo) .And. cCampo == "OHB_SIGLAO" 
			oModelOHB:SetValue(cCampo,;
				AllTrim(JurGetDados("RD0",1,xFilial("RD0")+OHB->OHB_CPARTO, "RD0_SIGLA")))	

		ElseIf oModelOHB:CanSetValue(cCampo) .And. cCampo == "OHB_SIGLAD" 
			oModelOHB:SetValue(cCampo,;
				AllTrim(JurGetDados("RD0",1,xFilial("RD0")+OHB->OHB_CPARTD, "RD0_SIGLA")))

		EndIf
	Next nLine
Return oModel
