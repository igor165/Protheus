#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEDITPANEL.CH'
#INCLUDE 'FINMRET.CH'

Static __cAlias := ''
Static __aImpos := {}
Static __aTit	:= {}
Static __nVlrRet := 0
Static __lEmissao := .F.

//-----------------------------------------------------------------------------
/*/{Protheus.doc}FINMRET
Model de manutenção de impostos calculados pelo Motor de retenção

@author Mauricio Pequim Jr
@since  22/11/2017
@version 12
/*/
//-----------------------------------------------------------------------------
Function FINMRET(aVetImp As Array, cAlias As Character, lBaixa As Logical, nTotRet As Numeric) As Numeric

	Local aEnableButtons As Array
	Local cSolucao As Character
	Local cOperacao As Character
	Local nOpc As Numeric

	DEFAULT aVetImp := {}
	DEFAULT cAlias  := ''
	DEFAULT lBaixa  := .F.

	aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
	cSolucao  := ''
	cOperacao := ''
	nOpc := 1 // 0 - Confirmar / 1 - Cancelar
	__lEmissao := !lBaixa

	If !(Empty(cAlias))
		__cAlias := cAlias

		cSolucao := STR0001		//'Por favor, verifique o cadastro da natureza e do '
		cSolucao += If( __cAlias == 'SE1',  STR0002, STR0003 )	//'cliente '###'fornecedor '
		cSolucao += STR0004		//'do título.'

		cOperacao := If(lBaixa, STR0005, STR0006 )	//'Baixa'###'Inclusão'

		If Empty(aVetImp)
			HELP(' ',1,"FINMRET_01" ,,STR0007,2,0,,,,,, {cSolucao})	//"Não foram encontradas retenções para este título"
		Else
			IF __cAlias == 'SE1'
				If lBaixa
					__aTit := {SE1->E1_NUM, SE1->E1_PARCELA ,SE1->E1_PREFIXO , SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_NOMCLI, SE1->E1_EMISSAO, SE1->E1_VENCREA, SE1->E1_NATUREZ}
				Else
					__aTit := {M->E1_NUM, M->E1_PARCELA ,M->E1_PREFIXO , M->E1_TIPO, M->E1_CLIENTE, M->E1_LOJA, M->E1_NOMCLI, M->E1_EMISSAO, M->E1_VENCREA, M->E1_NATUREZ}
				Endif
			Else
				If lBaixa
					__aTit := {SE2->E2_NUM, SE2->E2_PARCELA ,SE2->E2_PREFIXO , SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NOMFOR, SE2->E2_EMISSAO, SE2->E2_VENCREA, SE2->E2_NATUREZ}
				Else
					__aTit := {M->E2_NUM, M->E2_PARCELA ,M->E2_PREFIXO , M->E2_TIPO, M->E2_FORNECE, M->E2_LOJA, M->E2_NOMFOR, M->E2_EMISSAO, M->E2_VENCREA, M->E2_NATUREZ}
				Endif
			EndIf

			__aImpos := aClone(aVetImp)
			__nVlrRet := nTotRet

			nOpc := FWExecView( STR0008 + " - " + cOperacao ,"FINMRET", MODEL_OPERATION_INSERT,/**/,/**/,/**/,,aEnableButtons )	//'Retenção de Impostos por Título'
		Endif
	Endif

	aVetImP  := aClone(__aImpos)
	nTotRet  := __nVlrRet
	__cAlias := ''
	__aImpos := {}
	__aTit   := {}
	__nVlrRet := 0
	__lEmissao := .F.

Return nOpc


//-----------------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Interface.
@author Mauricio Pequim Jr
@since  22/11/2017
@version 12
/*/
//-----------------------------------------------------------------------------
Static Function ViewDef()

	Local oView As Object
	Local oModel As Object
	Local oIMP As Object
	Local oTIT As Object

	oView  := FWFormView():New()
	oModel := FWLoadModel("FINMRET")
	oTIT := FStructTIT(2, __cAlias)
	oIMP := FStructIMP(2)

	oTIT:SetNoFolder()
	If __cAlias == 'SE1'
		oTIT:SetProperty( 'E1_CLIENTE'	, MVC_VIEW_ORDEM,	'07')
		oTIT:SetProperty( 'E1_LOJA'		, MVC_VIEW_ORDEM,	'08')
		oTIT:SetProperty( 'E1_NOMCLI'	, MVC_VIEW_ORDEM,	'09')
		oTIT:SetProperty( 'E1_EMISSAO'	, MVC_VIEW_ORDEM,	'10')
		oTIT:SetProperty( 'E1_VENCREA'	, MVC_VIEW_ORDEM,	'11')
		oTIT:SetProperty( 'E1_NATUREZ'	, MVC_VIEW_ORDEM,	'12')
	Else
		oTIT:SetProperty( 'E2_FORNECE'	, MVC_VIEW_ORDEM,	'07')
		oTIT:SetProperty( 'E2_LOJA'		, MVC_VIEW_ORDEM,	'08')
		oTIT:SetProperty( 'E2_NOMFOR'	, MVC_VIEW_ORDEM,	'09')
		oTIT:SetProperty( 'E2_EMISSAO'	, MVC_VIEW_ORDEM,	'10')
		oTIT:SetProperty( 'E2_VENCREA'	, MVC_VIEW_ORDEM,	'11')
		oTIT:SetProperty( 'E2_NATUREZ'	, MVC_VIEW_ORDEM,	'12')
	Endif

	oView:SetModel( oModel )
	oView:AddField("VIEWTIT" ,oTIT , "TITMASTER" )
	oView:AddGrid("VIEWIMP"  ,oIMP , "IMPDETAIL" )

	oView:CreateHorizontalBox( 'BOXTIT', 030 )
	oView:CreateHorizontalBox( 'BOXIMP', 070 )
	//
	oView:SetOwnerView('VIEWTIT', 'BOXTIT')
	oView:SetOwnerView('VIEWIMP', 'BOXIMP')

	oView:EnableTitleView('VIEWIMP'  , STR0027 )	//"Retenções"

	oView:SetNoDeleteLine('VIEWIMP')

Return oView

//-----------------------------------------------------------------------------
/*/{Protheus.doc}ModelDef
Modelo de dados.
@author Mauricio Pequim Jr
@since  22/11/2017
@version 12
/*/
//-----------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel As Object
	Local oTIT As Object
	Local oIMP As Object

	oModel := MPFormModel():New('FINMRET',/*Pre*/,/*bPos*/,{|oModel| FINMRETGRV(oModel)}/*Commit*/)
	oTIT := FStructTIT(1, __cAlias)
	oIMP := FStructIMP(1)

	oModel:AddFields("TITMASTER",/*cOwner*/	, oTIT)
	oModel:AddGrid("IMPDETAIL"  ,"TITMASTER", oIMP, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, /*bLoadIMP*/ )

	oModel:GetModel( 'TITMASTER' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'IMPDETAIL' ):SetOptional( .T. )

	oTIT:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)
	oIMP:SetProperty('VALINFO' , MODEL_FIELD_WHEN , {|| FMRETWhen(oModel,'VALINFO') } )

	oModel:SetActivate( {|oModel| LoadIMP(oModel) } )

Return oModel


//-------------------------------------------------------------------
/*/ {Protheus.doc} LoadIMP
Funcao de carregamento das informacoes de baixas

@param oGridModel - Model que chamou o bLoad

@author Mauricio Pequim Jr
@since 22/11/2017

/*/
//-------------------------------------------------------------------
Static Function LoadIMP(oModel As Object)

	Local oView As Object
	Local oSubTIT As Object
	Local oSubIMP As Object
	Local nX As Numeric
	Local nTamCodRt As Numeric
	Local aAreaFKK As Array
	Local cDescFKK As Character
	Local cCodRetFKK As Character
	Local cDescRegi As Character
	Local nRecFKK   As Numeric

	oView := FWViewActive()
	oSubTIT := oModel:GetModel("TITMASTER")
	oSubIMP := oModel:GetModel("IMPDETAIL")
	nX := 0
	nTamCodRt := TamSx3("FKK_CODRET")[1]
	aAreaFKK := FKK->(GetArea())
	cDescFKK := ''
	cCodRetFKK := ''
	cDescRegi := ''
	nRecFKK    := 0

	//Carrego os dados do título em questão
	If __cAlias == 'SE1'

		oSubTIT:LoadValue("E1_NUM"      , __aTit[1]  )
		oSubTIT:LoadValue("E1_PARCELA"  , __aTit[2]  )
		oSubTIT:LoadValue("E1_PREFIXO"  , __aTit[3]  )
		oSubTIT:LoadValue("E1_TIPO"     , __aTit[4]  )
		oSubTIT:LoadValue("E1_CLIENTE"  , __aTit[5]  )
		oSubTIT:LoadValue("E1_LOJA"     , __aTit[6]  )
		oSubTIT:LoadValue("E1_NOMCLI"   , __aTit[7]  )
		oSubTIT:LoadValue("E1_EMISSAO"  , __aTit[8]  )
		oSubTIT:LoadValue("E1_VENCREA"  , __aTit[9]  )
		oSubTIT:LoadValue("E1_NATUREZ"  , __aTit[10] )
	Else
		oSubTIT:LoadValue("E2_NUM"      , __aTit[1]  )
		oSubTIT:LoadValue("E2_PARCELA"  , __aTit[2]  )
		oSubTIT:LoadValue("E2_PREFIXO"  , __aTit[3]  )
		oSubTIT:LoadValue("E2_TIPO"     , __aTit[4]  )
		oSubTIT:LoadValue("E2_FORNECE"  , __aTit[5]  )
		oSubTIT:LoadValue("E2_LOJA"     , __aTit[6]  )
		oSubTIT:LoadValue("E2_NOMFOR"   , __aTit[7]  )
		oSubTIT:LoadValue("E2_EMISSAO"  , __aTit[8]  )
		oSubTIT:LoadValue("E2_VENCREA"  , __aTit[9]  )
		oSubTIT:LoadValue("E2_NATUREZ"  , __aTit[10] )

	Endif
	oSubTIT:LoadValue("DESCNAT"     ,FINIniDesc()  )

	aSort( __aImpos, /*nInicio*/, /*nItens*/, {|x,y| x[9] < y[9]} )
	// Prepara estrutura de composicao do grid
	For nX := 1 to Len(__aImpos)

		If !oSubIMP:IsEmpty() .And. oSubIMP:CanInsertLine()
			//Inclui a quantidade de linhas necessárias
			oSubIMP:AddLine()
			//Vai para linha criada
			oSubIMP:GoLine( oSubIMP:Length() )
		Endif

    	nRecFKK := FinFKKVig(__aImpos[nX,1], dDataBase)
    	FKK->(DbGoto(nRecFKK))
		cDescFKK := FKK->FKK_DESCR
		cCodRetFKK := FKK->FKK_CODRET

		//Regime (1 = Competência ou 2 = Baixa)
		cDescRegi := If (__aImpos[nX,9] == '1', STR0009, STR0010 )		//'Competência'###'Caixa'

		oSubIMP:LoadValue("CODFKK"  ,__aImpos[nX,1])		//Código FKK
		oSubIMP:LoadValue("DESCFKK" ,cDescFKK      )		//Descrição da retenção
		oSubIMP:LoadValue("TIPOFOO" ,__aImpos[nX,8])		//Tipo do Imposto
		oSubIMP:LoadValue("CODRET"  ,cCodRetFKK    )		//Código de retenção
		oSubIMP:LoadValue("BASECALC",__aImpos[nX,2])		//Base Calculo
		oSubIMP:LoadValue("VALCALC" ,__aImpos[nX,3])		//Valor Cálculo
		oSubIMP:LoadValue("BASERET" ,__aImpos[nX,4])		//Base Retenção
		oSubIMP:LoadValue("VALINFO" ,__aImpos[nX,5])		//Valor Retenção
		oSubIMP:LoadValue("REGIRET" ,cDescRegi)				//Regime da retenção
		oSubIMP:LoadValue("IDRETFKN" ,FKK->FKK_IDFKN)		//Id de Retenção FKN
	Next nX

	oView:SetOnlyView( 'VIEWTIT' )
	oView:SetNoInsertLine('VIEWIMP')

	FKK->(RestArea(aAreaFKK))

	oModel:lModify := .F.

Return


//-------------------------------------------------------------------
/*/ {Protheus.doc} FINIniDesc
Funcao de retorno do inicializador padrão dos campos de descrição
adicionados ao Model

@author Mauricio Pequim Jr
@since 22/11/2017

@return Descrição da natureza (SED)
/*/
//-------------------------------------------------------------------
Function FINIniDesc()

	Local cDescric As Character

	//Descrição da Natureza
	cDescric := Posicione('SED',1,xFilial('SED') + __aTit[10] ,'ED_DESCRIC')

Return cDescric


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelIMPStr()
Retorna estrutura do tipo FWformModelStruct.

@author pequim

@since 05/12/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static function FStructIMP(nStruc As Numeric)

Local oStruct As Object
Local nTamDFKK As Numeric
Local nTamCodRt As Numeric
Local cPictVal As Character

oStruct := NIL
nTamDFKK := TamSx3("FKK_DESCR")[1]
nTamCodRt := TamSx3("FKK_CODRET")[1]
cPictVal := PesqPict("FK4","FK4_BASIMP")

If nStruc == 1		//Model

	oStruct := FWFormModelStruct():New()
	oStruct:AddTable('FK0',,STR0011)		//'Impostos'
	oStruct:AddField( STR0012 ,STR0013 , 'CODFKK'  , 'C',        6, 0, ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".F.") , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	//'Código'###'Código do Tipo de Retenção'
	oStruct:AddField( STR0014 ,STR0015 , 'DESCFKK' , 'C', nTamDFKK, 0, ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".F.") , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	//'Descrição'###'Descrição do tipo de retenção'
	oStruct:AddField( STR0016 ,STR0016 , 'TIPOFOO' , 'C',        6, 0, ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".F.") , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	//'Tipo Imposto'###'Tipo do Imposto'
	oStruct:AddField( STR0017 ,STR0018 , 'CODRET'  , 'C',nTamCodRt, 0, ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".F.") , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	//'Cód. Retenção'###'Código de Retenção'
	oStruct:AddField( STR0019 ,STR0020 , 'BASECALC', 'N',       16, 2, ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".F.") , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	//'Vlr. Base Cálculo'###'Base de Imposto'
	oStruct:AddField( STR0021 ,STR0021 , 'VALCALC' , 'N',       16, 2, ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".F.") , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	//'Valor Calculado'###'Valor de imposto calculado'
	oStruct:AddField( STR0022 ,STR0022 , 'BASERET' , 'N',       16, 2, ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".F.") , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	//'Vlr. Base Retenção'
	oStruct:AddField( STR0023 ,STR0024 , 'VALINFO' , 'N',       16, 2, ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".T.") , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	//'Valor a Reter'###'Valor de imposto a reter'
	oStruct:AddField( STR0025 ,STR0025 , 'REGIRET' , 'C',       15, 0, ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".F.") , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	//'Regime de Retenção'###'Momento da Retenção'
	oStruct:AddField( STR0028, STR0028 , 'IDRETFKN', 'C',       32, 0, ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".F.") , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	//'Id Retençao'

ElseIf nStruc == 2		//View
	oStruct := FWFormViewStruct():New()
	oStruct:AddField( "CODFKK"  ,"01", STR0012 , STR0013 , NIL, "G",     "@!" ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)
	oStruct:AddField( "DESCFKK" ,"02", STR0014 , STR0015 , NIL, "G",     "@!" ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)
	oStruct:AddField( "TIPOFOO" ,"03", STR0016 , STR0016 , NIL, "G",     "@!" ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)
	oStruct:AddField( "CODRET"  ,"04", STR0017 , STR0018 , NIL, "G",     "@!" ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)
	oStruct:AddField( "BASECALC","05", STR0019 , STR0020 , NIL, "G", cPictVal ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)
	oStruct:AddField( "VALCALC" ,"06", STR0021 , STR0021 , NIL, "G", cPictVal ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)
	oStruct:AddField( "BASERET" ,"07", STR0022 , STR0022 , NIL, "G", cPictVal ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)
	oStruct:AddField( "VALINFO" ,"08", STR0023 , STR0024 , NIL, "G", cPictVal ,/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/)
	oStruct:AddField( "REGIRET" ,"09", STR0025 , STR0025 , NIL, "G",     "@!" ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)

Endif

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} FStructTIT()
Retorna estrutura do tipo FWformModelStruct.

@author pequim

@since 05/12/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FStructTIT(nStruc As Numeric, cAlias As Character)

	Local oStruct As Object
	Local nTamDNat As Numeric

	DEFAULT nStruc := 0
	DEFAULT cAlias := ""

	oStruct := NIL
	nTamDNat := TamSx3("ED_DESCRIC")[1]

	If nStruc == 1		//Model

		oStruct		:= FWFormStruct( 1, cAlias , /*bAvalCampo*/,/*lViewUsado*/ )

		oStruct:AddField(			;
		STR0026					, ;	// [01] Titulo do campo		//"Descrição da Natureza"
		STR0026					, ;	// [02] ToolTip do campo 	//"Descrição da Natureza"
		"DESCNAT"				, ;	// [03] Id do Field
		"C"						, ;	// [04] Tipo do campo
		nTamDNat				, ;	// [05] Tamanho do campo
		0						, ;	// [06] Decimal do campo
		{ || .T. }				, ;	// [07] Code-block de validação do campo
		{ || .F. }				, ;	// [08] Code-block de validação When do campo
								, ;	// [09] Lista de valores permitido do campo
		.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDesc()") ,,,;// [11] Inicializador Padrão do campo
		.T.)							//[14] Virtual

	ElseIf  nStruc == 2		//vIEW

		If __cAlias == 'SE1'
			oStruct := FWFormStruct(2,'SE1', { |x| ALLTRIM(x) $ 'E1_NUM, E1_PARCELA, E1_PREFIXO, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_NATUREZ' } )
		Else
			oStruct := FWFormStruct(2,'SE2', { |x| ALLTRIM(x) $ 'E2_NUM, E2_PARCELA, E2_PREFIXO, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_VENCREA, E2_NATUREZ' } )
		Endif

		oStruct:AddField( "DESCNAT","13", STR0026, STR0026, {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição da Natureza"
	Endif

Return oStruct


//-------------------------------------------------------------------
/*/{Protheus.doc} FMRETWhen
Permissão de edição de campos (When)

@param oModel - Model que chamou a validação
@param cCampo - Campo a ser validada permissão de edição

@author Mauricio Pequim Jr
@since 07/12/2017

@return Logico com permissão ou não de edição do campo
/*/
//-------------------------------------------------------------------
Function FMRETWhen(oModel As Object, cCampo As Character) As Logical

	Local lRet As Logical
	Local nBaseRet As Numeric
	Local cIdRetFKK As Character
	Local cDescRegi As Character
	Local lRegCaixa As Logical

	DEFAULT oModel := NIL
	DEFAULT cCampo := ""

	lRet := .T.
	nBaseRet := 0
	cIdRetFKK := ''
	cDescRegi := ""
	lRegCaixa := .F.

	If cCampo == "VALINFO"
		nBaseRet := oModel:GetValue("IMPDETAIL","BASERET")

		//Pega a descrição do regime, para tratar e não permitir alteração, a partir da inclusão de um título, de impostos configurados na baixa
		cDescRegi := AllTrim( oModel:GetValue( "IMPDETAIL", "REGIRET" ) )
		lRegCaixa := cDescRegi == AllTrim( STR0010 ) //'Caixa'

		If nBaseRet == 0 .Or. ( lRegCaixa .And. __lEmissao .And. !(__aTit[4] $ MVPAGANT) )
			lRet := .F.
		Else
			cIdRetFKK := (xFilial("FKN") + oModel:GetValue("IMPDETAIL","IDRETFKN"))

			If !Empty(cIdRetFKK)
				lRet := (Posicione("FKN", 1, cIdRetFKK, "FKN_EDTCAL") == '1')
			Endif
		EndIf
	Endif

Return lRet


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FINMRETGRV
Gravação do modelo de dados.

@author Mauricio Pequim Jr
@since  07/12/2017
@version 12
/*/
//-----------------------------------------------------------------------------
Function FINMRETGRV()

	Local oModel As Object
	Local oSubIMP As Object
	Local nX As Numeric
	Local nValInfo As Numeric
	Local nPosImp As Numeric
	Local cCodFKK As Character

	oModel := FWModelActive()
	oSubIMP := oModel:GetModel("IMPDETAIL")
	nX := 0
	nValInfo := 0
	nPosImp := 0
	cCodFKK := ''

	__nVlrRet	:= 0

	For nX := 1 To oSubIMP:Length()

		cCodFKK := oSubIMP:GetValue("CODFKK", nX ) 		//Código FKK
		nValInfo := oSubIMP:GetValue("VALINFO", nX )	//Valor Retenção
		__nVlrRet	+= nValInfo

		nPosImp := ascan(__aImpos, {|x| x[1] == cCodFKK })
		//Valor Retenção ajustado no array de impostos
		If nPosImp > 0
			__aImpos[nPosImp,5] := nValInfo
		Endif

	Next nX

Return .T.
