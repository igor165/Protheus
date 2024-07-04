#Include "Protheus.ch"
#Include "FWMVCDEF.ch"
#Include "FINA031.ch"

Static _lTemLCDPR	:= Nil

#DEFINE	ENTER		Chr(13) + Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA031
Cadastro da Pessoa

@author  Rodrigo Oliveira
@since 14/10/2019
@version 12
/*/
//-------------------------------------------------------------------
Function FINA031()

	Local oBrowse As Object

	If _lTemLCDPR == Nil
		_lTemLCDPR	:= ExistFunc("TemLCDPR")
	EndIf

	If _lTemLCDPR
		If TemLCDPR()
			If !GetHlpLGPD({'FVU_NOME','FVU_CNPJ'})
				oBrowse := BrowseDef()
				oBrowse:Activate()
			EndIf
		EndIf
	Else
		Help(' ',1,STR0027,,STR0028,2,0,,,,,,)	//  'Função não encontrada' ## 'Fonte FINA820 não está compilado no repositório'
	EndIf

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef()
Define o browse padrão para o cadastro de Pessoa

@type Function

@author Rodrigo Oliveira
@since 14/10/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function BrowseDef() As Object
	Local oBrowse As Object

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( 'FVU' )
	oBrowse:AddLegend( "FVU_TIPCAD=='1'", "GREEN"	, STR0031 ) // "Proprietário (Declarante)"
	oBrowse:AddLegend( "FVU_TIPCAD=='2'", "RED"		, STR0032 ) // "Terceiro"
	oBrowse:SetDescription(STR0004) // 'Cadastro de Pessoa'

Return oBrowse

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Define o ModelDef padrão para o cadastro de Pessoa

@type Function

@author Rodrigo Oliveira
@since 14/10/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ModelDef() As Object

	Local oStruFVU 	As Object
	Local oModel	As Object

	oStruFVU	:= FWFormStruct( 1, 'FVU' )

	oStruFVU:AddField( 		  ; // Ord. Tipo Desc.
		STR0005				, ;	// [01] Titulo do campo	//'Município'
		STR0005				, ;	// [02] ToolTip do campo 	//'Município'
		"FVU_MUNIC"			, ;	// [03] Id do Field
		"C"					, ;	// [04] Tipo do campo
		60					, ;	// [05] Tamanho do campo
		0					, ;	// [06] Decimal do campo
		{ || .T. }			, ;	// [07] Code-block de validação do campo
		{ || .T. }			, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
		.F.					, ;	// [10] Indica se o campo tem preenchimento obrigatório
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "F031INI('FVU_MUNIC')") ,,,;// [11] Inicializador Padrão do campo
		.T.)					//[14] Virtual

	oStruFVU:AddField( 		  ; // Ord. Tipo Desc.
		STR0033				, ;	// [01] Titulo do campo	//'Fil Origem'
		STR0033				, ;	// [02] ToolTip do campo 	//'Fil Origem'
		"FVU_FILORI"		, ;	// [03] Id do Field
		"C"					, ;	// [04] Tipo do campo
		8					, ;	// [05] Tamanho do campo
		0					, ;	// [06] Decimal do campo
		{ || .T. }			, ;	// [07] Code-block de validação do campo
		{ || .T. }			, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
		.T.					, ;	// [10] Indica se o campo tem preenchimento obrigatório
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "GRVFILORIG()") ,,,;// [11] Inicializador Padrão do campo
		.F.)					//[14] Virtual

	oStruFVU:AddTrigger("FVU_CODMUN", "FVU_MUNIC"	, { || .T.}, { || F031INI('FVU_MUNIC') })
	oStruFVU:AddTrigger("FVU_TIPCAD", "FVU_TPPES"	, { || .T.}, { || F031INI('FVU_TPPES') })
	oStruFVU:SetProperty("FVU_TPPES", MODEL_FIELD_WHEN	, { || M->FVU_TIPCAD != "1"} )

	oModel := MPFormModel():New('FINA031', /* bPre */, {|| ValidCpos() }, /* bCommit */, /* bCancel */ )
	oModel:AddFields( 'FVUMASTER', /*cOwner*/, oStruFVU)

	oModel:SetDescription( STR0007 )
	oModel:GetModel( 'FVUMASTER' ):SetDescription( STR0006 )

Return oModel

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Define o MenuDef padrão para o cadastro de Pessoa

@type Function

@author Rodrigo Oliveira
@since 14/10/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MenuDef() As Array
	Local aRotina As Array

	aRotina := {}

	ADD OPTION aRotina Title STR0008 	Action 'VIEWDEF.FINA031' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title STR0009	Action 'VIEWDEF.FINA031' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title STR0010	Action 'VIEWDEF.FINA031' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title STR0011	Action 'VIEWDEF.FINA031' OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title STR0012	Action 'VIEWDEF.FINA031' OPERATION 8 ACCESS 0

Return aRotina

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Define a ViewDef padrão para o cadastro de Pessoa

@type Function

@author Rodrigo Oliveira
@since 14/10/2019
@version P12.1.27

/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ViewDef() As Object
	Local oModel 	As Object
	Local oStruFVU 	As Object
	Local oView		As Object

	oModel 		:= FWLoadModel( 'FINA031' )
	oStruFVU 	:= FWFormStruct( 2, 'FVU' )

	oStruFVU:AddField("FVU_MUNIC" , "13", STR0005, STR0013, {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)	//"Nome do Município"

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_FVU', oStruFVU, 'FVUMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_FVU', 'TELA' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F031INI()
Inicializador padrão do Código / Nome do Município

@author Rodrigo Oliveira
@since	14/10/2019
@version 12
/*/
//-------------------------------------------------------------------
Function F031INI(cCampo As Character) As Character

	Local cRet 		As Character
	Local cCodigo 	As Character
	Local cEst		As Character
	Local oModel 	As Object
	Local oFVU 		As Object
	Local nTamCC2	As Numeric

	DEFAULT cCampo := ""

	oModel		:= FWModelActive()
	oFVU 		:= oModel:GetModel("FVUMASTER")
	cRet		:= ""
	cCodigo		:= ""

	If !Empty(cCampo)
		If cCampo = "FVU_TPPES"
			cCodigo	:= oModel:GetValue("FVUMASTER","FVU_TIPCAD")
			If cCodigo == '1'
				cRet := "1"
			EndIf
		Else
			nTamCC2		:= TamSX3('CC2_MUN')[1]
			cCodigo		:= oModel:GetValue("FVUMASTER","FVU_CODMUN")
			cEst		:= oModel:GetValue("FVUMASTER","FVU_EST")

			If !Empty(cCodigo)
				CC2->(MsSeek(xFilial("CC2") + cEst + cCodigo ))
				cRet :=  PADR(CC2->CC2_MUN, nTamCC2)
			EndIf
		EndIf
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN031FVU()
Pos Validacao de preenchimento do código do Município

@author Rodrigo Oliveira
@since	14/10/2019
@version 12
/*/
//-------------------------------------------------------------------
Function FIN031FVU() As Logical

	Local lRet 		As Logical
	Local oModel 	As Object
	Local oFVU	 	As Object
	Local cCodigo 	As Character
	Local cEst		As Character
	Local aArea 	As Array

	lRet 	:= .T.
	aArea 	:= GetArea()
	oModel 	:= FWModelActive()
	oFVU	:= oModel:GetModel( 'FVUMASTER' )
	cCodigo := FWFldGet("FVU_CODMUN")
	cEst 	:= FWFldGet("FVU_EST")

	If !Empty(cCodigo)
		DBSelectArea('CC2')
		CC2->(DbSetOrder(1))
		If CC2->(DbSeek(xFilial('CC2') + cEst + cCodigo))
			If oFVU <> Nil // Quando Incluir pela consulta padrão não está vindo o Getmodel()
				oModel:LoadValue('FVUMASTER','FVU_MUNIC', CC2->CC2_MUN)
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

//---------------------------------
/*/{Protheus.doc} F031CODFVU()
Pos Validacao de preenchimento do
código/ cpf do registro da pessoa

@author Rodrigo Oliveira
@since 14/10/2019
@version 12
/*/
//---------------------------------
Function F031CODFVU() As Logical
	Local lRet    	As Logical
	Local oModel  	As Object
	Local cCodigo 	As Character
	Local lAchou  	As Logical
	Local cCab    	As Character
	Local cDes    	As Character
	Local cSol    	As Character
	Local aArea	  	As Array

	//Inicializa variáveis
	oModel  := FWModelActive()
	cCodigo := FWFldGet("FVU_CODIGO")
	cCab	:= ""
	cDes	:= ""
	cSol	:= ""

	lRet   := .F.
	lAchou := .F.

	If !Empty(cCodigo)
		aArea  := FVU->(GetArea())
		FVU->(DbSetOrder(1))
		If FVU->(MSSeek(xFilial("FVU") + cCodigo))
			lAchou := .T.
		EndIf
		FVU->(RestArea(aArea))
	EndIf

	If !FreeForUse("FVU", "FVU_CODIGO" + xFilial("FVU") + cCodigo)
		cCab := STR0017	//Código
		cDes := STR0018 + cCodigo + " " + STR0019	//O código ## encontra - se em uso
		cSol := STR0021	//Entre com um outro código para continuar.
	ElseIf lAchou
		cCab := STR0017 //Código
		cDes := STR0018 + cCodigo + " " + STR0020	//O código ## já se encontra cadastrado
		cSol := STR0022	//Digite um novo código
	Else
		lRet := .T.
	EndIf

	If !Empty(cCab+cDes+cSol)
		HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
	EndIf
Return lRet

//---------------------------------
/*/{Protheus.doc} ValidCpos()
Pos Validacao de preenchimento do
cadastro do contribuinte (TudoOk)

@author Rodrigo Oliveira
@since 14/10/2019
@version 12
/*/
//---------------------------------
Static Function ValidCpos() As Logical
	Local lRet 		As Logical
	Local cTpCad	As Character
	Local cCab		As Character
	Local cDes		As Character
	Local cSol		As Character
	Local nPos		As Numeric
	Local aFVU		As Array
	Local oModel	As Object

	lRet	:= .T.
	cCab	:= ""
	cDes	:= ""
	cSol	:= ""
	nPos	:= 0
	aFVU	:= {}
	oModel	:= FWModelActive()

	cTpCad	:= oModel:GetValue('FVUMASTER', "FVU_TIPCAD")
	aFVU	:= oModel:GetModel("FVUMASTER"):oFormModelStruct:GetFields()

	If cTpCad	== '1'
		cDes	:= ENTER + ENTER
		If Empty(oModel:GetValue('FVUMASTER', "FVU_END"))
			If ( nPos := aScan(aFVU, {|x| x[3] == "FVU_END" }) ) > 0
				cDes += aFVU[nPos][1] + ENTER
			EndIf
			lRet	:= .F.
		EndIf		
		If Empty(oModel:GetValue('FVUMASTER', "FVU_BAIRRO"))
			If ( nPos := aScan(aFVU, {|x| x[3] == "FVU_BAIRRO" }) ) > 0
				cDes += aFVU[nPos][1] + ENTER
			EndIf
			lRet	:= .F.
		EndIf
		If Empty(oModel:GetValue('FVUMASTER', "FVU_EST"))
			If ( nPos := aScan(aFVU, {|x| x[3] == "FVU_EST" }) ) > 0
				cDes += aFVU[nPos][1] + ENTER
			EndIf
			lRet	:= .F.
		EndIf
		If Empty(oModel:GetValue('FVUMASTER', "FVU_CODMUN"))
			If ( nPos := aScan(aFVU, {|x| x[3] == "FVU_CODMUN" }) ) > 0
				cDes += aFVU[nPos][1] + ENTER
			EndIf
			lRet	:= .F.
		EndIf
		If Empty(oModel:GetValue('FVUMASTER', "FVU_CEP"))
			If ( nPos := aScan(aFVU, {|x| x[3] == "FVU_CEP" }) ) > 0
				cDes += aFVU[nPos][1] + ENTER
			EndIf
			lRet	:= .F.
		EndIf
		If Empty(oModel:GetValue('FVUMASTER', "FVU_EMAIL"))
			If ( nPos := aScan(aFVU, {|x| x[3] == "FVU_EMAIL" }) ) > 0
				cDes += aFVU[nPos][1] + ENTER
			EndIf
			lRet	:= .F.
		EndIf
	EndIf

	If !Empty(oModel:GetValue('FVUMASTER', "FVU_EMAIL")) .And. !("@" $ oModel:GetValue('FVUMASTER', "FVU_EMAIL"))
		If Empty(cDes)
			cDes	+= ENTER + ENTER
		EndIf
		If ( nPos := aScan(aFVU, {|x| x[3] == "FVU_EMAIL" }) ) > 0
			cDes += aFVU[nPos][1] + STR0029 + ENTER // " (Email inválido)"
		EndIf
		lRet	:= .F.
	EndIf
	If !Empty(oModel:GetValue('FVUMASTER', "FVU_CEP")) .And. Len(AllTrim(oModel:GetValue('FVUMASTER', "FVU_CEP"))) < 8
		If Empty(cDes)
			cDes	+= ENTER + ENTER
		EndIf
		If ( nPos := aScan(aFVU, {|x| x[3] == "FVU_CEP" }) ) > 0
			cDes += aFVU[nPos][1] + STR0030 + ENTER // " (Cep Inválido.)"
		EndIf
		lRet	:= .F.
	EndIf

	If !lRet
		cCab	:= STR0023 //"OBRIGAT"
		cSol	:= STR0024 + ENTER //"Preencha os campos obrigatórios do cadastro de Contribuinte"
		cSol	+= STR0025 //"antes de prosseguir com o cadastro."
	Else
		cDes := ""
	EndIf

	If !Empty(cCab+cDes+cSol)
		HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
	EndIf

Return lRet

//---------------------------------
/*/{Protheus.doc} GrvFilOrig()
Inicializador padrão do campo
FVU_FILORI

@author Rodrigo Oliveira
@since 22/11/2019
@version 12
/*/
//---------------------------------
Function GrvFilOrig() As Character
	Local cFilRet	As Character
	Local oModel	As Object
	Local nOper		As Numeric

	oModel	:= FWModelActive()

	nOper	:= oModel:GetOperation()

	If nOper == MODEL_OPERATION_INSERT
		cFilRet	:= cFilAnt
	Else
		cFilRet	:= FWFldGet("FVU_FILORI")
	EndIf
Return cFilRet
