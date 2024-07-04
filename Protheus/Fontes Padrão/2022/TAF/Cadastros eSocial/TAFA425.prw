#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA425.CH"
#INCLUDE "TOPCONN.CH"

Static cLayNmSpac  := ''
Static lLaySimplif := TAFLayESoc(, .T.)
Static lSimplBeta  := TAFLayESoc("S_01_01_00", .T., .T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA425
Cadastro MVC dos  Informações das Contribuições Sociais Consolidadas por Contribuinte - S-5011

@author Daniel Schimidt
@since 01/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA425()

	Private oBrw := FwMBrowse():New()

	oBrw:SetCacheView(.F.)

	//Função que indica se o ambiente é válido para o eSocial 2.3
	If TafAtualizado()

		oBrw:SetDescription( STR0001 )	//"Contribuições Sociais Consolidadas por Contribuinte"
		oBrw:SetAlias( 'T2V')
		oBrw:SetMenuDef( 'TAFA425' )

		If FindFunction('TAFSetFilter')
			oBrw:SetFilterDefault(TAFBrwSetFilter("T2V","TAFA425","S-5011"))
		Else
			oBrw:SetFilterDefault( "T2V_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
		EndIf

		oBrw:AddLegend( "T2V_EVENTO == 'I' ", "GREEN" , STR0019 ) //"Registro Incluído"
		oBrw:AddLegend( "T2V_EVENTO == 'A' ", "YELLOW", STR0007 ) //"Registro Alterado"
		oBrw:AddLegend( "T2V_EVENTO == 'E' ", "RED"   , STR0020 ) //"Registro Excluído"

		oBrw:Activate()

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Daniel Schimidt
@since 01/03/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao as array
	Local aRotina as array

	aFuncao := {}
	aRotina := {}

	Aadd( aFuncao, { "" , "TAF425Xml" , "1" } )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'T2V', 'S-5011' , 'evtCS' , 'TAF425Xml' , , oBrw)" , "5" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.TAFA425' OPERATION 2 ACCESS 0 //"Visualizar"
	Else
		aRotina	:=	xFunMnuTAF( "TAFA425" , , aFuncao)
	EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Daniel Schimidt
@since 01/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruT2V as object
	Local oStruT2X as object
	Local oStruT70 as object
	Local oStruT2Y as object
	Local oStruT2Z as object
	Local oStruT0A as object
	Local oStruT0B as object
	Local oStruT0C as object
	Local oStruT0D as object
	Local oStruT0E as object
	Local oStruV79 as object
	Local oModel   as object

	oStruT2V := FwFormStruct( 1, 'T2V' )
	oStruT2X := FWFormStruct( 1, 'T2X' )
	oStruT70 := FWFormStruct( 1, 'T70' )
	oStruT2Y := FWFormStruct( 1, 'T2Y' )
	oStruT2Z := FWFormStruct( 1, 'T2Z' )
	oStruT0A := FWFormStruct( 1, 'T0A' )
	oStruT0B := FWFormStruct( 1, 'T0B' )
	oStruT0C := FWFormStruct( 1, 'T0C' )
	oStruT0D := FWFormStruct( 1, 'T0D' )
	oStruT0E := FWFormStruct( 1, 'T0E' )
	oStruV79 := Nil
	oModel   := MPFormModel():New("TAFA425", , , {|oModel| SaveModel(oModel)})

	SetLayout()	
	
	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lLaySimplif
		oStruT2Y:RemoveField( "T2Y_VRBCFG" )
	EndIf

	If !TAFNT0421(lLaySimplif) .And. TafColumnPos("T2V_PERCTR")
		oStruT2V:RemoveField("T2V_PERCTR")
		oStruT2X:RemoveField("T2X_CNPJRE")
	EndIf

	// V79 - Info. RAT e FAP de referência 
	If TAFColumnPos("V79_TPINSE")
		oStruV79 := FWFormStruct(1, "V79")
	EndIf

	If lVldModel
		oStruT2V:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT2X:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT70:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT2Y:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT2Z:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT0A:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT0B:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT0C:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT0D:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		oStruT0E:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })

		If TAFColumnPos("V79_TPINSE")

			oStruV79:SetProperty("*", MODEL_FIELD_VALID, {|| lVldModel})

		EndIf
	EndIf

	oModel:AddFields('MODEL_T2V', /*cOwner*/, oStruT2V)
	oModel:GetModel ('MODEL_T2V'):SetPrimaryKey({'T2V_FILIAL', 'T2V_ID', 'T2V_VERSAO'})

	//T0D - Informações consolidadas das contribuições sociais devidas à Previdência Social e Outras Entidades e Fundos
	oModel:AddGrid ("MODEL_T0D","MODEL_T2V",oStruT0D)
	oModel:GetModel("MODEL_T0D"):SetOptional(.T.)

	If TAFColumnPos("T0D_CODREC")
		oModel:GetModel("MODEL_T0D"):SetUniqueLine({"T0D_IDCODR","T0D_CODREC"})
	Else
		oModel:GetModel("MODEL_T0D"):SetUniqueLine({"T0D_IDCODR"})
	EndIf

	//T2X - Informações de Identificação do Estabelecimento ou Obra de Construção Civil.
	oModel:AddGrid ("MODEL_T2X","MODEL_T2V",oStruT2X)
	oModel:GetModel("MODEL_T2X"):SetOptional(.T.)
	oModel:GetModel("MODEL_T2X"):SetUniqueLine({"T2X_TPINSE","T2X_NRINSE"})

	// V79 - Info. RAT e FAP de referência  
	If TAFColumnPos("V79_TPINSE")

		oModel:AddFields("MODEL_V79", "MODEL_T2X", oStruV79)
		oModel:GetModel("MODEL_V79"):SetOptional(.T.)

	EndIf
		
	//T70 - Informações sobre aquisição rural
	oModel:AddGrid ("MODEL_T70","MODEL_T2X",oStruT70)
	oModel:GetModel("MODEL_T70"):SetOptional(.T.)
	oModel:GetModel("MODEL_T70"):SetUniqueLine({"T70_INDAQU"})

	//T0B - Informações de bases de cálculo relativas à comercialização da  produção rural da Pessoa Física.
	oModel:AddGrid ("MODEL_T0B","MODEL_T2X",oStruT0B)
	oModel:GetModel("MODEL_T0B"):SetOptional(.T.)
	oModel:GetModel("MODEL_T0B"):SetUniqueLine({"T0B_INDCOM"})

	//T0C - Informações das contribuições sociais devidas à Previdência  Social e Outras Entidades e Fundos
	oModel:AddGrid ("MODEL_T0C","MODEL_T2X",oStruT0C)
	oModel:GetModel("MODEL_T0C"):SetOptional(.T.)
	If TAFColumnPos("T0C_CODREC")
		oModel:GetModel("MODEL_T0C"):SetUniqueLine({"T0C_IDCODR","T0C_CODREC"})
	else
		oModel:GetModel("MODEL_T0C"):SetUniqueLine({"T0C_IDCODR"})
	EndIf
	oModel:GetModel('MODEL_T0C'):SetMaxLine(99)

	//T2Y - Identificação da lotação tributária.
	oModel:AddGrid ("MODEL_T2Y","MODEL_T2X",oStruT2Y)
	oModel:GetModel("MODEL_T2Y"):SetOptional(.T.)
	oModel:GetModel("MODEL_T2Y"):SetUniqueLine({"T2Y_LOTTRB","T2Y_CODLOR"})

	//T2Z - Bases de Cálculo da Contribuição Previdenciária Incidente sobre Remunerações
	oModel:AddGrid ("MODEL_T2Z","MODEL_T2Y",oStruT2Z)
	oModel:GetModel("MODEL_T2Z"):SetOptional(.T.)
	oModel:GetModel("MODEL_T2Z"):SetUniqueLine({"T2Z_INDINC","T2Z_CODCAT","T2Z_DCODCR"})

	//T0A - Informação Substituição Patronal dos Operadores Portuários
	oModel:AddGrid ("MODEL_T0A","MODEL_T2Y",oStruT0A)
	oModel:GetModel("MODEL_T0A"):SetOptional(.T.)
	oModel:GetModel("MODEL_T0A"):SetUniqueLine({"T0A_CNPJOP"})

	//T0E - Informações de suspensão de contribuições destinadas a Outra Entidades e Fundos (Terceiros).
	oModel:AddGrid ("MODEL_T0E","MODEL_T2Y",oStruT0E)
	oModel:GetModel("MODEL_T0E"):SetOptional(.T.)
	oModel:GetModel("MODEL_T0E"):SetUniqueLine({"T0E_CODTER"})
	oModel:GetModel('MODEL_T0E'):SetMaxLine(15)

	// RELATIONS
	//T0D_FILIAL+T0D_ID+T0D_VERSAO+T0D_IDCODR
	oModel:SetRelation("MODEL_T0D", {{"T0D_FILIAL","xFilial('T0D')"}, {"T0D_ID","T2V_ID"}, {"T0D_VERSAO","T2V_VERSAO"}},T0D->(IndexKey(1)) )
	//T2X_FILIAL+T2X_ID+T2X_VERSAO+T2X_TPINSE+T2X_NRINSE
	oModel:SetRelation("MODEL_T2X", {{"T2X_FILIAL","xFilial('T2X')"}, {"T2X_ID","T2V_ID"}, {"T2X_VERSAO","T2V_VERSAO"}},T2X->(IndexKey(1)) )
	//T70_FILIAL+T70_ID+T70_VERSAO+T70_TPINSE+T70_NRINSE+T70_INDAQU
	oModel:SetRelation("MODEL_T70", {{"T70_FILIAL","xFilial('T70')"}, {"T70_ID","T2V_ID"}, {"T70_VERSAO","T2V_VERSAO"}, {"T70_TPINSE","T2X_TPINSE"}, {"T70_NRINSE","T2X_NRINSE"} },T70->(IndexKey(1)) )
	//T0B_FILIAL+T0B_ID+T0B_VERSAO+T0B_TPINSE+T0B_NRINSE+T0B_INDCOM
	oModel:SetRelation("MODEL_T0B", {{"T0B_FILIAL","xFilial('T0B')"}, {"T0B_ID","T2V_ID"}, {"T0B_VERSAO","T2V_VERSAO"}, {"T0B_TPINSE","T2X_TPINSE"}, {"T0B_NRINSE","T2X_NRINSE"} },T0B->(IndexKey(1)) )
	//T0C_FILIAL+T0C_ID+T0C_VERSAO+T0C_TPINSE+T0C_NRINSE+T0C_IDCODR
	oModel:SetRelation("MODEL_T0C", {{"T0C_FILIAL","xFilial('T0C')"}, {"T0C_ID","T2V_ID"}, {"T0C_VERSAO","T2V_VERSAO"}, {"T0C_TPINSE","T2X_TPINSE"}, {"T0C_NRINSE","T2X_NRINSE"} },T0C->(IndexKey(1)) )
	//T2Y_FILIAL+T2Y_ID+T2Y_VERSAO+T2Y_TPINSE+T2Y_NRINSE+T2Y_LOTTRB
	oModel:SetRelation("MODEL_T2Y", {{"T2Y_FILIAL","xFilial('T2Y')"}, {"T2Y_ID","T2V_ID"}, {"T2Y_VERSAO","T2V_VERSAO"}, {"T2Y_TPINSE","T2X_TPINSE"}, {"T2Y_NRINSE","T2X_NRINSE"} },T2Y->(IndexKey(1)) )
	//T2Z_FILIAL+T2Z_ID+T2Z_VERSAO+T2Z_TPINSE+T2Z_NRINSE+T2Z_LOTTRB+T2Z_INDINC+T2Z_CODCAT
	oModel:SetRelation("MODEL_T2Z", {{"T2Z_FILIAL","xFilial('T2Z')"}, {"T2Z_ID","T2V_ID"}, {"T2Z_VERSAO","T2V_VERSAO"}, {"T2Z_TPINSE","T2X_TPINSE"}, {"T2Z_NRINSE","T2X_NRINSE"}, {"T2Z_LOTTRB","T2Y_LOTTRB"}},T2Z->(IndexKey(1)) )
	//T0A_FILIAL+T0A_ID+T0A_VERSAO+T0A_TPINSE+T0A_NRINSE+T0A_LOTTRB+T0A_CNPJOP
	oModel:SetRelation("MODEL_T0A", {{"T0A_FILIAL","xFilial('T0A')"}, {"T0A_ID","T2V_ID"}, {"T0A_VERSAO","T2V_VERSAO"}, {"T0A_TPINSE","T2X_TPINSE"}, {"T0A_NRINSE","T2X_NRINSE"}, {"T0A_LOTTRB","T2Y_LOTTRB"}},T0A->(IndexKey(1)) )
	//T0E_FILIAL+T0E_ID+T0E_VERSAO+T0E_TPINSE+T0E_NRINSE+T0E_LOTTRB+T0E_CODTER
	oModel:SetRelation("MODEL_T0E", {{"T0E_FILIAL","xFilial('T0E')"}, {"T0E_ID","T2V_ID"}, {"T0E_VERSAO","T2V_VERSAO"}, {"T0E_TPINSE","T2X_TPINSE"}, {"T0E_NRINSE","T2X_NRINSE"}, {"T0E_LOTTRB","T2Y_LOTTRB"}},T0E->(IndexKey(1)) )

	// V79 - Info. RAT e FAP de referência 
	If TAFColumnPos("V79_TPINSE")

		oModel:SetRelation("MODEL_V79", {{"V79_FILIAL", "xFilial('V79')"}, {"V79_ID", "T2V_ID"}, {"V79_VERSAO", "T2V_VERSAO"}, {"V79_TPINSE", "T2X_TPINSE"}, {"V79_NRINSE", "T2X_NRINSE"}}, V79->(IndexKey(1)))

	EndIf
	                                                                                                     
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Daniel Schimidt
@since 01/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel    as object
	Local oStruT2Va as object
	Local oStruT2Vb as object
	Local oStruT2X  as object
	Local oStruT70  as object
	Local oStruT2Y  as object
	Local oStruT2Z  as object
	Local oStruT0A  as object
	Local oStruT0B  as object
	Local oStruT0C  as object
	Local oStruT0D  as object
	Local oStruT0E  as object
	Local oStruV79  as object
	Local oView     as object
	Local cCmpFil   as character
	Local cGrp1     as character
	Local cGrp2     as character
	Local cGrp3     as character
	Local cGrp4     as character
	Local cGrp5     as character
	Local cGrp7     as character
	Local nI        as numeric

	oModel    := FWLoadModel( 'TAFA425' )
	oStruT2Va := FWFormStruct( 2, 'T2V' )
	oStruT2Vb := FWFormStruct( 2, 'T2V' )
	oStruT2X  := FWFormStruct( 2, 'T2X' )
	oStruT70  := FWFormStruct( 2, 'T70' )
	oStruT2Y  := Nil
	oStruT2Z  := Nil
	oStruT0A  := FWFormStruct( 2, 'T0A' )
	oStruT0B  := Nil
	oStruT0C  := Nil
	oStruT0D  := Nil
	oStruT0E  := Nil
	oStruV79  := Nil
	oView     := FWFormView():New()
	cCmpFil   := ""
	cGrp1     := ""
	cGrp2     := ""
	cGrp3     := ""
	cGrp4     := ""
	cGrp5     := ""
	cGrp7     := ""
	nI        := 0

	oView:SetModel( oModel )
	oView:SetContinuousForm(.T.)

	cGrp1     	:= 'T2V_ID|T2V_INDAPU|T2V_PERAPU|'
	cGrp2     	:= 'T2V_IDARQB|T2V_INDEXI|'
	cGrp7     	:= 'T2V_VRDESC|T2V_VRCPSE|'

	cCmpFil   	:= cGrp1 + cGrp2 + cGrp7
	oStruT2Va 	:= FwFormStruct( 2, 'T2V', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	cGrp3 		:= 'T2V_IDCLAS|' + Iif(dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")), 'T2V_DCLASR|', 'T2V_DCLASS|')
	cGrp4 		:= 'T2V_INDCOO|T2V_INDCON|T2V_INDPAT|T2V_PERCON|'

	If lSimplBeta .and. TafColumnPos("T2V_INDPIS")
		cGrp4 += "T2V_PERCTR|T2V_INDPIS|"
	ElseIf lLaySimplif
		cGrp4 += "T2V_PERCTR|"
	EndIf

	If !TAFNT0421(lLaySimplif) .And. TafColumnPos("T2X_CNPJRE")
		oStruT2X:RemoveField("T2X_CNPJRE")
	EndIf
	
	cGrp5 		:= 'T2V_FATMES|T2V_FATDEC|'

	cCmpFil 	:= cGrp3 + cGrp4 + cGrp5
	oStruT2Vb 	:= FwFormStruct( 2, 'T2V', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	cGrp6		:= 'T2V_PROTUL|'
	cCmpFil 	:= cGrp6
	oStruT2Vc 	:= FwFormStruct( 2, 'T2V', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruT2Vc,"T2V")
	EndIf

	/*-----------------------------------------------------------------------------------
								Grupo 1 e 2
	-------------------------------------------------------------------------------------*/
	oStruT2Va:AddGroup( "GRP_01", STR0002, "", 1 ) //"Informação de Apuração"
	oStruT2Va:AddGroup( "GRP_02", STR0003, "", 1 ) //"Informações relativas às Contribuições Sociais"
	oStruT2Va:AddGroup( "GRP_07", STR0030, "", 1 ) //"Informações de contribuição previdenciária do Segurado"

	aCmpGrp := StrToKArr(cGrp1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT2Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_01")
	Next nI

	aCmpGrp := StrToKArr(cGrp2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT2Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_02")
	Next nI

	aCmpGrp := StrToKArr(cGrp7,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT2Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_07")
	Next nI

	/*-----------------------------------------------------------------------------------
								Grupo 3, 4 e 5
	-------------------------------------------------------------------------------------*/
	oStruT2Vb:AddGroup( "GRP_03", STR0004, "", 1 ) //"Informações Gerais do Contribuinte"
	oStruT2Vb:AddGroup( "GRP_04", STR0005, "", 1 ) //"Informações Complementares para PJ"
	oStruT2Vb:AddGroup( "GRP_05", STR0006, "", 1 ) //"Informações no Regime de Tributação Simples Nacional"

	aCmpGrp := StrToKArr(cGrp3,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT2Vb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_03")
	Next nI

	aCmpGrp := StrToKArr(cGrp4,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT2Vb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_04")
	Next nI

	aCmpGrp := StrToKArr(cGrp5,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT2Vb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_05")
	Next nI

	/*--------------------------------------------------------------------------------------------
										Esrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( 'VIEW_T2Va', oStruT2Va, 'MODEL_T2V' )
	oView:AddField( 'VIEW_T2Vb', oStruT2Vb, 'MODEL_T2V' )
	oView:AddField( 'VIEW_T2Vc', oStruT2Vc, 'MODEL_T2V' )

	If FindFunction("TafNmFolder")
		oView:EnableTitleView( 'VIEW_T2Vc', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"
	EndIf

	oView:AddGrid( 'VIEW_T2X',   oStruT2X,  'MODEL_T2X' )
	oView:EnableTitleView("VIEW_T2X",STR0011) //"Identificação"

	oView:AddGrid( 'VIEW_T70',   oStruT70,  'MODEL_T70' )
	oView:EnableTitleView("VIEW_T2X",STR0011) //"Identificação"

	If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
		cCmpFil := "T0D_DCODRE|"
	Else
		cCmpFil := "T0D_DCODRR|"
	EndIf

	oStruT0D	:= FWFormStruct( 2, 'T0D', {|x| !(AllTrim( x ) + "|" $ cCmpFil) } )
	oView:AddGrid( 'VIEW_T0D',   oStruT0D,  'MODEL_T0D' )

	If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
		cCmpFil := "T2Y_CODLOT|T2Y_DFPAS|T2Y_CODTER|"
	Else
		cCmpFil := "T2Y_CODLOR|T2Y_DFPASR|T2Y_CODTRR|"
	EndIf

	oStruT2Y := FWFormStruct( 2, 'T2Y', {|x| !(AllTrim( x ) + "|" $ cCmpFil) } )
	oView:AddGrid( 'VIEW_T2Y',   oStruT2Y,  'MODEL_T2Y' )

	If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
		cCmpFil := "T0C_DCODRE|T0C_CODLOT|"
	Else
		cCmpFil := "T0C_DCODRR|T0C_CODLOR|"
	EndIf

	oStruT0C := FWFormStruct( 2, 'T0C', {|x| !(AllTrim( x ) + "|" $ cCmpFil) } )
	oView:AddGrid( 'VIEW_T0C',   oStruT0C,  'MODEL_T0C' )

	If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
		cCmpFil := "T0B_DINDCO|"
	Else
		cCmpFil := "T0B_DINDCR|"
	EndIf

	oStruT0B := FWFormStruct( 2, 'T0B', {|x| !(AllTrim( x ) + "|" $ cCmpFil) } )
	oView:AddGrid( 'VIEW_T0B',   oStruT0B,  'MODEL_T0B' )
	oView:AddGrid( 'VIEW_T0A',   oStruT0A,  'MODEL_T0A' )

	If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
		cCmpFil := "T0E_DTERC|"
	Else
		cCmpFil := "T0E_DTERR|"
	EndIf

	oStruT0E := FWFormStruct( 2, 'T0E', {|x| !(AllTrim( x ) + "|" $ cCmpFil) } )
	oView:AddGrid( 'VIEW_T0E',   oStruT0E,  'MODEL_T0E' )

	If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
		cCmpFil := "T2Z_DCODCA|"
	Else
		cCmpFil := "T2Z_DCODCR|"
	EndIf

	oStruT2Z	:= FWFormStruct( 2, 'T2Z', {|x| !(AllTrim( x ) + "|" $ cCmpFil) } )
	oView:AddGrid( 'VIEW_T2Z',   oStruT2Z,  'MODEL_T2Z' )

	//V79 - Info. RAT e FAP de referência 
	If TAFColumnPos("V79_TPINSE")
		oStruV79 := FWFormStruct(2, "V79")
		oView:AddField("VIEW_V79", oStruV79, "MODEL_V79")
	EndIf

	/*-----------------------------------------------------------------------------------
									Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )
	oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0001 )   //"Contribuições Sociais Consolidadas por Contribuinte"

	If FindFunction("TafNmFolder")
		oView:AddSheet('FOLDER_SUPERIOR', "ABA02", TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0007 )   //"Protocolo de Transmissão"
	EndIf

	oView:CreateHorizontalBox( 'T2Vc',  100,,, 'FOLDER_SUPERIOR', 'ABA02' )

	oView:CreateHorizontalBox("PAINEL_GRPs",100,,,"FOLDER_SUPERIOR","ABA01")

	oView:CreateFolder("GRPs","PAINEL_GRPs")

	oView:AddSheet("GRPs", "ABA01", STR0008) //"Inf. Rel. à Prev. Social e a Out. Ent. e Fundos"
	oView:CreateHorizontalBox("T2Va",100,,,"GRPs","ABA01")

	oView:AddSheet("GRPs", "ABA02", STR0009) //"Inf. Gerais do Contribuinte"
	oView:CreateHorizontalBox("T2Vb",100,,,"GRPs","ABA02")

	oView:AddSheet("GRPs", "ABA03", STR0010) //"Inf. Identif. do Estab ou Obra de Const. Civil"
	oView:CreateHorizontalBox("T2X",030,,,"GRPs","ABA03")

	oView:AddSheet("GRPs", "ABA04", STR0012) //"Inf. das Contrib. Sociais por Código de Receita - CR"
	oView:CreateHorizontalBox("T0D",100,,,"GRPs","ABA04")

	oView:CreateHorizontalBox("PAINEL_EST", 070,,,"GRPs","ABA03")

	oView:CreateFolder("ESTAB","PAINEL_EST")

	oView:AddSheet("ESTAB", "ABA01", STR0013) //"Identificação da Lotação Tributária"
	oView:CreateHorizontalBox("T2Y",050,,,"ESTAB","ABA01")

	oView:CreateHorizontalBox("PAINEL_LOT", 050,,,"ESTAB","ABA01")
	oView:CreateFolder("LOTACAO","PAINEL_LOT")

	oView:AddSheet("LOTACAO", "ABA01", STR0016) //"Inf. Susp. de Contrib. a Outras Entid. e Fundos (Terceiros)"
	oView:CreateHorizontalBox("T0E",100,,,"LOTACAO","ABA01")

	oView:AddSheet("LOTACAO", "ABA02", STR0017) //"Bases de Cál. da Contrib. Prev. sobre Remunerações"
	oView:CreateHorizontalBox("T2Z",100,,,"LOTACAO","ABA02")

	oView:AddSheet("LOTACAO", "ABA03", STR0018) //"Inf. Exclus. pelo OGMO a Operadores Portuários"
	oView:CreateHorizontalBox("T0A",100,,,"LOTACAO","ABA03")

	oView:AddSheet("ESTAB", "ABA02", STR0023) //"Inf. Exclus. pelo OGMO a Operadores Portuários"
	oView:CreateHorizontalBox("T70",100,,,"ESTAB","ABA02")

	oView:AddSheet("ESTAB", "ABA03", STR0015) //"Inf. Bases de Cál. Relativas à Comerc. Prod. Rural da PF"
	oView:CreateHorizontalBox("T0B",100,,,"ESTAB","ABA03")

	oView:AddSheet("ESTAB", "ABA04", STR0014) //"Inf. Contrib. Sociais por Estab. e por Código de Receita - CR"
	oView:CreateHorizontalBox("T0C",100,,,"ESTAB","ABA04")

	//V79 - Info. RAT e FAP de referência 
	If TAFColumnPos("V79_TPINSE")
		oView:AddSheet("ESTAB", "ABA05", STR0031) // "Info. RAT e FAP de referência"
		oView:CreateHorizontalBox("V79", 100,,, "ESTAB", "ABA05")
	EndIf

	oView:SetOwnerView('VIEW_T2Va', 'T2Va' )
	oView:SetOwnerView('VIEW_T2Vb', 'T2Vb' )
	oView:SetOwnerView('VIEW_T2Vc', 'T2Vc' )
	oView:SetOwnerView('VIEW_T2X' , 'T2X'  )
	oView:SetOwnerView('VIEW_T70' , 'T70'  )
	oView:SetOwnerView('VIEW_T0D' , 'T0D'  )
	oView:SetOwnerView('VIEW_T0C' , 'T0C'  )
	oView:SetOwnerView('VIEW_T0B' , 'T0B'  )
	oView:SetOwnerView('VIEW_T2Y' , 'T2Y'  )
	oView:SetOwnerView('VIEW_T0E' , 'T0E'  )
	oView:SetOwnerView('VIEW_T0A' , 'T0A'  )
	oView:SetOwnerView('VIEW_T2Z' , 'T2Z'  )

	//V79 - Info. RAT e FAP de referência 
	If TAFColumnPos("V79_TPINSE")
		oView:SetOwnerView("VIEW_V79", "V79")
	EndIf

	If TAFColumnPos("T0C_CODREC")
		//Ordem dos campos na tela
		oStruT0C:SetProperty("T0C_CODREC", MVC_VIEW_ORDEM, "01"	)
		oStruT0C:SetProperty("T0C_IDCODR", MVC_VIEW_ORDEM, "02"	)

		If !(dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
			oStruT0C:SetProperty("T0C_DCODRE", MVC_VIEW_ORDEM, "03"	)
		EndIf

	EndIf

	If TAFColumnPos("T0D_CODREC")
		//Ordem dos campos na tela
		oStruT0D:SetProperty("T0D_CODREC", MVC_VIEW_ORDEM, "01"	)
		oStruT0D:SetProperty("T0D_IDCODR", MVC_VIEW_ORDEM, "02"	)

		If !(dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
			oStruT0D:SetProperty("T0D_DCODRE", MVC_VIEW_ORDEM, "03"	)
		EndIf

	EndIf

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr(@oStruT2Va, 'T2V')
	EndIf

	If lLaySimplif

		oStruT2Y:RemoveField( "T2Y_VRBCFG" )

	EndIf

Return oView

///-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@author Daniel Schimidt
@since 01/03/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

	Local cLogOpeAnt as character
	Local lRetorno   as logical
	Local nOperation as numeric

	Default oModel := Nil

	cLogOpeAnt     := ""
	lRetorno       := .T.
	nOperation     := oModel:GetOperation()

	Begin Transaction

		If nOperation == MODEL_OPERATION_DELETE

			oModel:DeActivate()
			oModel:SetOperation( 5 )
			oModel:Activate()

			FwFormCommit( oModel )

		EndIf

	End Transaction

Return( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF425Xml

Funcao de geracao do XML para atender o registro S-2400
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias - Alias da Tabela
nRecno - Recno do Registro corrente
nOpc   - Operacao a ser realizada
lJob   - Informa se foi chamado por Job

@Return:
cXml - Estrutura do Xml do Layout S-2400

@author denis.oliveira
@since 06/08/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF425Xml(cAlias as character, nRecno as numeric, nOpc as numeric, lJob as logical)

	Local cXml       	as character
	Local cXmlCRCont 	as character
	Local cXmlObra   	as character
	Local cXmlInfoE  	as character
	Local cXmlEstab  	as character
	Local cXmlBasAvN 	as character
	Local cXmlOpPort 	as character
	Local cXmlTercs  	as character
	Local cXmlEmpr   	as character
	Local cXmlLotac  	as character
	Local cXmlBasCP  	as character
	Local cXmlBaseR  	as character
	Local cXmlSubsP  	as character
	Local cXmlBaseA  	as character
	Local cXmlBaseC  	as character
	Local cXmlCREst  	as character
	Local cXmlAtConc 	as character
	Local cXmlPJ     	as character
	Local cXmlCtrb   	as character
	Local cXmlCPSeg  	as character
	Local cInEsRef		as character
	Local cLayout    	as character
	Local cReg       	as character
	Local cEsocial		as character
	Local aMensal    	as array
	Local aInfoPJ		as array
	Local aInfoEst		as array
	Local lXmlVLd    	as logical

	Default cAlias   	:= ""
	Default nRecno   	:= 0
	Default nOpc     	:= 0
	Default lJob     	:= .F.

	cXml       	:= ""
	cXmlCRCont 	:= ""
	cXmlObra   	:= ""
	cXmlInfoE  	:= ""
	cXmlEstab  	:= ""
	cXmlBasAvN 	:= ""
	cXmlOpPort 	:= ""
	cXmlTercs  	:= ""
	cXmlEmpr   	:= ""
	cXmlLotac  	:= ""
	cXmlBasCP  	:= ""
	cXmlBaseR  	:= ""
	cXmlSubsP  	:= ""
	cXmlBaseA  	:= ""
	cXmlBaseC  	:= ""
	cXmlCREst  	:= ""
	cXmlAtConc 	:= ""
	cXmlPJ     	:= ""
	cXmlCtrb   	:= ""
	cXmlCPSeg  	:= ""
	cInEsRef		:= ""
	cLayout    	:= "5011"
	cReg       	:= "CS"
	cEsocial    := SuperGetMV("MV_TAFVLES")
	aMensal    	:= {}
	aInfoPJ		:= {}
	aInfoEst		:= {}
	lXmlVLd    	:= IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF425XML' ),.T.)

	If lXmlVLd

		If TAFColumnPos("T92_LAYOUT") .And. !Empty(AllTrim(T92->T92_LAYOUT))
			cEsocial := AllTrim(T92->T92_LAYOUT)
		EndIf

		SetLayout()

		//*******************
		//-- ideEstab
		//*******************
		T2X->(DbSetOrder(1))

		If T2X->( MsSeek( xFilial( "T2X" ) + T2V->( T2V_ID+T2V_VERSAO ) ) )

			While T2X->(!Eof()) .And. T2X->( T2X_FILIAL+T2X_ID+T2X_VERSAO ) == xFilial( "T2V" ) + T2V->( T2V_ID+T2V_VERSAO )
				
				If TafColumnPos("V79_ALIRAT")
					
					V79->(DbSetOrder(1))

					If V79->(MsSeek(xFilial("V79") + T2X->(T2X_ID + T2X_VERSAO + T2X_TPINSE + T2X_NRINSE)))

						xTafTagGroup("infoEstabRef"	, {	{ "aliqRat"			, V79->V79_ALIRAT	,								, .F. }		;	// CRIAR CAMPO
													, 	{ "fap"				, V79->V79_FAP   	, PesqPict("V79","V79_FAP")		, .T. }		;	// CRIAR CAMPO
													, 	{ "aliqRatAjust"	, V79->V79_ALIAJU	, PesqPict("V79","V79_ALIAJU")	, .T. }	}	;	// CRIAR CAMPO
													, @cInEsRef) 
					
					EndIf
					
				EndIf

				xTafTagGroup("infoComplObra", {{"indSubstPatrObra", T2X->T2X_INDPAT,, .F.}}, @cXmlObra)

				AAdd(aInfoEst, {"cnaePrep", T2X->T2X_CNAEPR,, .F.})

				If TAFNT0421(lLaySimplif) .And. TafColumnPos("T2X_CNPJRE")
					AAdd(aInfoEst, {"cnpjResp", T2X->T2X_CNPJRE,, .F.})
				EndIf

				AAdd(aInfoEst, {"aliqRat"		, T2X->T2X_ALIRAT	,							 	, .F.})
				AAdd(aInfoEst, {"fap"			, T2X->T2X_FAP		, PesqPict("T2X","T2X_FAP")	 	, .T.})
				AAdd(aInfoEst, {"aliqRatAjust"	, T2X->T2X_ALIAJU	, PesqPict("T2X","T2X_ALIAJU")	, .T.})

				xTafTagGroup("infoEstab", aInfoEst, @cXmlInfoE, {{"infoEstabRef", cInEsRef, 0}, {"infoComplObra", cXmlObra, 0}}, .F., .T.)

				//*******************
				//-- ideLotacao
				//*******************
				T2Y->(DbSetOrder(1))

				If T2Y->( MsSeek( xFilial( "T2Y" ) + T2X->(T2X_ID+T2X_VERSAO+T2X_TPINSE+T2X_NRINSE) ) )

					While T2Y->(!Eof()) .And. T2Y->( T2Y_FILIAL+T2Y_ID+T2Y_VERSAO+T2Y_TPINSE+T2Y_NRINSE ) == xFilial( "T2X" ) + T2X->(T2X_ID+T2X_VERSAO+T2X_TPINSE+T2X_NRINSE )

						//-- infoTercSusp
						If T0E->( MsSeek( xFilial( "T0E" ) + T2Y->( T2Y_ID+T2Y_VERSAO+T2Y_TPINSE+T2Y_NRINSE+T2Y_LOTTRB ) ) )
							While T0E->(!Eof()) .And. T0E->( T0E_FILIAL+T0E_ID+T0E_VERSAO+T0E_TPINSE+T0E_NRINSE+T0E_LOTTRB ) == xFilial( "T2Y" ) + T2Y->( T2Y_ID+T2Y_VERSAO+T2Y_TPINSE+T2Y_NRINSE+T2Y_LOTTRB )

								xTafTagGroup("infoTercSusp"		,{{ "codTerc"	,	POSICIONE("C8A",1, xFilial("C8A")+T0E->T0E_CODTER ,"C8A_CODTER"),,.F. }};
									, @cXmlTercS)

								T0E->(DbSkip())
							EndDo

						EndIf

						//*******************
						//-- basesRemun
						//*******************
						T2Z->(DbSetOrder(1))

						If T2Z->( MsSeek( xFilial( "T2Z" ) + T2Y->( T2Y_ID+T2Y_VERSAO+T2Y_TPINSE+T2Y_NRINSE+T2Y_LOTTRB ) ) )
							While T2Z->(!Eof()) .And. T2Z->( T2Z_FILIAL+T2Z_ID+T2Z_VERSAO+T2Z_TPINSE+T2Z_NRINSE+T2Z_LOTTRB ) == xFilial( "T2Y" ) + T2Y->( T2Y_ID+T2Y_VERSAO+T2Y_TPINSE+T2Y_NRINSE+T2Y_LOTTRB )

								cXmlBasCP	:= ""

								//-- basesCp
								If !TafColumnPos("T2Z_BC00VA")

									xTafTagGroup("basesCp";			
										,{{ "vrBcCp00"			,T2Z->T2Z_VLBCCP			,PesqPict("T2Z","T2Z_VLBCCP"),.F. };
										, {	"vrBcCp15"			,T2Z->T2Z_VLBCAQ			,PesqPict("T2Z","T2Z_VLBCAQ"),.F. };
										, {	"vrBcCp20"			,T2Z->T2Z_VLBCAV			,PesqPict("T2Z","T2Z_VLBCAV"),.F. };
										, {	"vrBcCp25"			,T2Z->T2Z_VLBCVC			,PesqPict("T2Z","T2Z_VLBCVC"),.F. };
										, {	"vrSuspBcCp00"		,T2Z->T2Z_VLSUBC			,PesqPict("T2Z","T2Z_VLSUBC"),.F. };
										, {	"vrSuspBcCp15"		,T2Z->T2Z_VLSUBQ			,PesqPict("T2Z","T2Z_VLSUBQ"),.F. };
										, {	"vrSuspBcCp20"		,T2Z->T2Z_VLSUBV			,PesqPict("T2Z","T2Z_VLSUBV"),.F. };
										, {	"vrSuspBcCp25"		,T2Z->T2Z_VLSUVC			,PesqPict("T2Z","T2Z_VLSUVC"),.F. };
										, {	"vrDescSest"		,T2Z->T2Z_VLDESE			,PesqPict("T2Z","T2Z_VLDESE"),.F. };
										, {	"vrCalcSest"		,T2Z->T2Z_VLCASE			,PesqPict("T2Z","T2Z_VLCASE"),.F. };
										, {	"vrDescSenat"		,T2Z->T2Z_VLDESN			,PesqPict("T2Z","T2Z_VLDESN"),.F. };
										, {	"vrCalcSenat"		,T2Z->T2Z_VLCASN			,PesqPict("T2Z","T2Z_VLCASN"),.F. };
										, {	"vrSalFam"			,T2Z->T2Z_VLSAFA			,PesqPict("T2Z","T2Z_VLSAFA"),.F. };
										, {	"vrSalMat"			,T2Z->T2Z_VLSAMA			,PesqPict("T2Z","T2Z_VLSAMA"),.F. }};
										, @cXmlBasCP)

								Else

									xTafTagGroup("basesCp";			
										,{{ "vrBcCp00"			,T2Z->T2Z_VLBCCP			,PesqPict("T2Z","T2Z_VLBCCP"),.F. };
										, {	"vrBcCp15"			,T2Z->T2Z_VLBCAQ			,PesqPict("T2Z","T2Z_VLBCAQ"),.F. };
										, {	"vrBcCp20"			,T2Z->T2Z_VLBCAV			,PesqPict("T2Z","T2Z_VLBCAV"),.F. };
										, {	"vrBcCp25"			,T2Z->T2Z_VLBCVC			,PesqPict("T2Z","T2Z_VLBCVC"),.F. };
										, {	"vrSuspBcCp00"		,T2Z->T2Z_VLSUBC			,PesqPict("T2Z","T2Z_VLSUBC"),.F. };
										, {	"vrSuspBcCp15"		,T2Z->T2Z_VLSUBQ			,PesqPict("T2Z","T2Z_VLSUBQ"),.F. };
										, {	"vrSuspBcCp20"		,T2Z->T2Z_VLSUBV			,PesqPict("T2Z","T2Z_VLSUBV"),.F. };
										, {	"vrSuspBcCp25"		,T2Z->T2Z_VLSUVC			,PesqPict("T2Z","T2Z_VLSUVC"),.F. };
										, {	"vrDescSest"		,T2Z->T2Z_VLDESE			,PesqPict("T2Z","T2Z_VLDESE"),.F. };
										, {	"vrCalcSest"		,T2Z->T2Z_VLCASE			,PesqPict("T2Z","T2Z_VLCASE"),.F. };
										, {	"vrDescSenat"		,T2Z->T2Z_VLDESN			,PesqPict("T2Z","T2Z_VLDESN"),.F. };
										, {	"vrCalcSenat"		,T2Z->T2Z_VLCASN			,PesqPict("T2Z","T2Z_VLCASN"),.F. };
										, {	"vrSalFam"			,T2Z->T2Z_VLSAFA			,PesqPict("T2Z","T2Z_VLSAFA"),.F. };
										, {	"vrSalMat"			,T2Z->T2Z_VLSAMA			,PesqPict("T2Z","T2Z_VLSAMA"),.F. };
										, { "vrBcCp00VA"		,T2Z->T2Z_BC00VA			,PesqPict("T2Z","T2Z_BC00VA"),.F. };
										, {	"vrBcCp15VA"		,T2Z->T2Z_BC15VA			,PesqPict("T2Z","T2Z_BC15VA"),.F. };
										, {	"vrBcCp20VA"		,T2Z->T2Z_BC20VA			,PesqPict("T2Z","T2Z_BC20VA"),.F. };
										, {	"vrBcCp25VA"		,T2Z->T2Z_BC25VA			,PesqPict("T2Z","T2Z_BC25VA"),.F. };
										, {	"vrSuspBcCp00VA"	,T2Z->T2Z_SB00VA			,PesqPict("T2Z","T2Z_SB00VA"),.F. };
										, {	"vrSuspBcCp15VA"	,T2Z->T2Z_SB15VA			,PesqPict("T2Z","T2Z_SB15VA"),.F. };
										, {	"vrSuspBcCp20VA"	,T2Z->T2Z_SB20VA			,PesqPict("T2Z","T2Z_SB20VA"),.F. };
										, {	"vrSuspBcCp25VA"	,T2Z->T2Z_SB25VA			,PesqPict("T2Z","T2Z_SB25VA"),.F. }};
										, @cXmlBasCP)

								EndIf

								//-- basesRemun
								xTafTagGroup("basesRemun"		,{{ "indIncid"		,T2Z->T2Z_INDINC			,,.F. };
									, { "codCateg"		,POSICIONE("C87", 1, xFilial("C87")+T2Z->T2Z_CODCAT,"C87_CODIGO")	,,.F. }};
									, @cXmlBaseR, {{"basesCp", cXmlBasCP, 0}} )

								T2Z->(DbSkip())
							EndDo

						EndIf

						//************************
						//-- infoSubstPatrOpPort
						//************************
						T0A->(DbSetOrder(1))

						If T0A->( MsSeek( xFilial( "T0A" ) + T2X->( T2X_ID+T2X_VERSAO+T2X_TPINSE+T2X_NRINSE ) ) )

							While T0A->(!Eof()) .And. T0A->( T0A_FILIAL+T0A_ID+T0A_VERSAO+T0A_TPINSE+T0A_NRINSE ) == xFilial( "T2X" ) + T2X->( T2X_ID+T2X_VERSAO+T2X_TPINSE+T2X_NRINSE )

								xTafTagGroup("infoSubstPatrOpPort";		
									,{{ "cnpjOpPortuario"	,T0A->T0A_CNPJOP			,,.F. }};
									, @cXmlSubsP)

								T0A->(DbSkip())
							EndDo

						EndIf

						//-- infoEmprParcial

						If TafLayESoc("02_05_00") .AND. TafColumnPos("T2Y_NRCNO")
							xTafTagGroup("infoEmprParcial";	
								,{{ "tpInscContrat"	,T2Y->T2Y_TPINCO	,,.F. };
								, { "nrInscContrat"	,T2Y->T2Y_NRINCO	,,.F. };
								, { "tpInscProp"	,T2Y->T2Y_TPINPR	,,.F. };
								, { "nrInscProp"	,T2Y->T2Y_NRINPR	,,.F. };
								, { "cnoObra"		,T2Y->T2Y_NRCNO		,,.F. }};
								, @cXmlEmpr)
						Else
							xTafTagGroup("infoEmprParcial";	
								,{{ "tpInscContrat"	,T2Y->T2Y_TPINCO	,,.F. };
								, { "nrInscContrat"	,T2Y->T2Y_NRINCO	,,.F. };
								, { "tpInscProp"	,T2Y->T2Y_TPINPR	,,.F. };
								, { "nrInscProp"	,T2Y->T2Y_NRINPR	,,.F. }};
								,@cXmlEmpr)
						EndIf

						//-- dadosOpPort
						xTafTagGroup("dadosOpPort";		
							,{{ "cnpjOpPortuario"	,T2Y->T2Y_CNPJOP			,								,.F. };
							, { "aliqRat"			,T2Y->T2Y_ALIRAT			,								,.F. };
							, { "fap"				,T2Y->T2Y_FAP				,PesqPict("T2Y","T2Y_FAP")		,.F. };
							, { "aliqRatAjust"		,T2Y->T2Y_ALRATF			,PesqPict("T2Y","T2Y_ALRATF")	,.F. }};
							, @cXmlOpPort)	

						If !lLaySimplif
							//-- basesAvNPort
							xTafTagGroup("basesAvNPort";		
								,{{ "vrBcCp00"		,T2Y->T2Y_VRBCCP			,PesqPict("T2Y","T2Y_VRBCCP"),.F. };
								, { "vrBcCp15"		,T2Y->T2Y_VRBCCQ			,PesqPict("T2Y","T2Y_VRBCCQ"),.F. };
								, { "vrBcCp20"		,T2Y->T2Y_VRBCCV			,PesqPict("T2Y","T2Y_VRBCCV"),.F. };
								, { "vrBcCp25"		,T2Y->T2Y_VRBCVQ			,PesqPict("T2Y","T2Y_VRBCVQ"),.F. };
								, { "vrBcCp13"		,T2Y->T2Y_VRBCCT			,PesqPict("T2Y","T2Y_VRBCCT"),.F. };
								, { "vrBcFgts"		,T2Y->T2Y_VRBCFG			,PesqPict("T2Y","T2Y_VRBCFG"),.F. };
								, { "vrDescCP"		,T2Y->T2Y_VRDESC			,PesqPict("T2Y","T2Y_VRDESC"),.F. }};
								, @cXmlBasAvN)
						Else
							//-- basesAvNPort
							xTafTagGroup("basesAvNPort";		
								,{{ "vrBcCp00"		,T2Y->T2Y_VRBCCP			,PesqPict("T2Y","T2Y_VRBCCP"),.F. };
								, { "vrBcCp15"		,T2Y->T2Y_VRBCCQ			,PesqPict("T2Y","T2Y_VRBCCQ"),.F. };
								, { "vrBcCp20"		,T2Y->T2Y_VRBCCV			,PesqPict("T2Y","T2Y_VRBCCV"),.F. };
								, { "vrBcCp25"		,T2Y->T2Y_VRBCVQ			,PesqPict("T2Y","T2Y_VRBCVQ"),.F. };
								, { "vrBcCp13"		,T2Y->T2Y_VRBCCT			,PesqPict("T2Y","T2Y_VRBCCT"),.F. };
								, { "vrDescCP"		,T2Y->T2Y_VRDESC			,PesqPict("T2Y","T2Y_VRDESC"),.F. }};
								, @cXmlBasAvN)
						EndIf

						//-- ideLotacao
						xTafTagGroup("ideLotacao";		
							,{{ "codLotacao"	,Posicione("C99",4,xFilial("C99")+T2Y->T2Y_LOTTRB + '1'	,"C99_CODIGO")	,,.F. };
							, {	"fpas"			,Posicione("C8A",1,xFilial("C8A")+T2Y->T2Y_FPAS 		,"C8A_CDFPAS")	,,.F. };
							, {	"codTercs"		,Posicione("C8A",1,xFilial("C8A")+T2Y->T2Y_FPAS 		,"C8A_CODTER")	,,.F. };
							, {	"codTercsSusp"	,T2Y->T2Y_TERSUS										,				,.T. }};
							,@cXmlLotac;
							,{{"infoTercSusp"		, cXmlTercS	, 0 };
							, {"infoEmprParcial"	, cXmlEmpr  , 0 };
							, {"dadosOpPort"    	, cXmlOpPort, 0 };
							, {"basesRemun"  		, cXmlBaseR	, 0 };
							, {"basesAvNPort"   	, cXmlBasAvN, 0 };
							, {"infoSubstPatrOpPort", cXmlSubsP , 0 }})

						//-- Limpo as variáveis
						cXmlTercS	:= ""
						cXmlEmpr	:= ""
						cXmlOpPort	:= ""
						cXmlBaseR	:= ""
						cXmlBasAvN	:= ""
						cXmlSubsP	:= ""

						T2Y->(DbSkip())

					EndDo

				EndIf

				//************************
				//-- basesAquis
				//************************
				T70->(DbSetOrder(1))

				If T70->( MsSeek( xFilial( "T70" ) + T2X->( T2X_ID+T2X_VERSAO+T2X_TPINSE+T2X_NRINSE ) ) )
					While T70->(!Eof()) .And. T70->( T70_FILIAL+T70_ID+T70_VERSAO+T70_TPINSE+T70_NRINSE ) == xFilial( "T2X" ) + T2X->( T2X_ID+T2X_VERSAO+T2X_TPINSE+T2X_NRINSE )

						xTafTagGroup("basesAquis"	,{{ "indAquis"				,T70->T70_INDAQU			,,.F. };
							, {	"vlrAquis"			,T70->T70_VLAQUI			,PesqPict("T70","T70_VLAQUI"),.F. };
							, {	"vrCPDescPR"		,T70->T70_VLCPPR			,PesqPict("T70","T70_VLCPPR"),.F. };
							, {	"vrCPNRet"			,T70->T70_VLCPRE			,PesqPict("T70","T70_VLCPRE"),.F. };
							, {	"vrRatNRet"			,T70->T70_VLRATN			,PesqPict("T70","T70_VLRATN"),.F. };
							, {	"vrSenarNRet"		,T70->T70_VLSENR			,PesqPict("T70","T70_VLSENR"),.F. };
							, {	"vrCPCalcPR"		,T70->T70_VLCPCA			,PesqPict("T70","T70_VLCPCA"),.F. };
							, {	"vrRatDescPR"		,T70->T70_VLRAPR			,PesqPict("T70","T70_VLRAPR"),.F. };
							, {	"vrRatCalcPR"		,T70->T70_VLRACA			,PesqPict("T70","T70_VLRACA"),.F. };
							, {	"vrSenarDesc"		,T70->T70_VLSEDE			,PesqPict("T70","T70_VLSEDE"),.F. };
							, {	"vrSenarCalc"		,T70->T70_VLSECA			,PesqPict("T70","T70_VLSECA"),.F. }};
							, @cXmlBaseA)

						T70->(DbSkip())
					EndDo

				EndIf

				//************************
				//-- basesComerc
				//************************
				T0B->(DbSetOrder(1))

				If T0B->( MsSeek( xFilial( "T0B" ) + T2X->( T2X_ID+T2X_VERSAO+T2X_TPINSE+T2X_NRINSE ) ) )
					While T0B->(!Eof()) .And. T0B->( T0B_FILIAL+T0B_ID+T0B_VERSAO+T0B_TPINSE+T0B_NRINSE ) == xFilial( "T2X" ) + T2X->( T2X_ID+T2X_VERSAO+T2X_TPINSE+T2X_NRINSE )

						xTafTagGroup("basesComerc"	,{{ "indComerc"			,Posicione("T1T",1,xFilial("T1T")+T0B->T0B_INDCOM, "T1T_CODIGO")	,,.F. };
							, {	"vrBcComPR"		,T0B->T0B_VLBCCO			,PesqPict("T0B","T0B_VLBCCO"),.F. };
							, {	"vrCPSusp"		,T0B->T0B_VLCPSU			,PesqPict("T0B","T0B_VLCPSU"),.T. };
							, {	"vrRatSusp"		,T0B->T0B_VLRASU			,PesqPict("T0B","T0B_VLRASU"),.T. };
							, {	"vrSenarSusp"	,T0B->T0B_VLSESU			,PesqPict("T0B","T0B_VLSESU"),.T. }};
							, @cXmlBaseC)

						T0B->(DbSkip())
					EndDo

				EndIf

				//************************
				//-- infoCREstab
				//************************
				T0C->(DbSetOrder(1))

				If T0C->( MsSeek( xFilial( "T0C" ) + T2X->( T2X_ID+T2X_VERSAO+T2X_TPINSE+T2X_NRINSE ) ) )
					While T0C->(!Eof()) .And. T0C->( T0C_FILIAL+T0C_ID+T0C_VERSAO+T0C_TPINSE+T0C_NRINSE ) == xFilial( "T2X" ) + T2X->( T2X_ID+T2X_VERSAO+T2X_TPINSE+T2X_NRINSE )

						If TAFColumnPos("T0C_CODREC")
							xTafTagGroup("infoCREstab"	,{{ "tpCR"				,T0C->T0C_CODREC			,PesqPict("T0C","T0C_CODREC"),.F. };
								, {	"vrCR"			,T0C->T0C_VLCOCR			,PesqPict("T0C","T0C_VLCOCR"),.F. };
								, {	"vrSuspCR"		,T0C->T0C_VLSUCR			,PesqPict("T0C","T0C_VLSUCR"),.F. };
								, {	"codLotacao"	,Posicione("C99",4,xFilial("C99")+T0C->T0C_LOTACA+"1","C99_CODIGO"),,.T. }};
								, @cXmlCREst)
						else
							xTafTagGroup("infoCREstab"	,{{ "tpCR"				,Posicione("C6R",3, xFilial("C6R")+T0C->T0C_IDCODR,"C6R_CODIGO"),,.F. };
								, {	"vrCR"			,T0C->T0C_VLCOCR			,PesqPict("T0C","T0C_VLCOCR"),.F. };
								, {	"vrSuspCR"		,T0C->T0C_VLSUCR			,PesqPict("T0C","T0C_VLSUCR"),.F. };
								, {	"codLotacao"	,Posicione("C99",4,xFilial("C99")+T0C->T0C_LOTACA+"1","C99_CODIGO"),,.T. }};
								, @cXmlCREst)
						EndIf


						T0C->(DbSkip())
					EndDo

				EndIf

				//-- ideEstab
				xTafTagGroup("ideEstab";				
					,{{ "tpInsc"		,T2X->T2X_TPINSE			,,.F. };
					, { "nrInsc"		,Alltrim(T2X->T2X_NRINSE)	,,.F. }};
					,@cXmlEstab;
					,{{"infoEstab" , cXmlInfoE, 0 };
					,{"ideLotacao" 	, cXmlLotac, 0 };
					,{"infoCREstab"	, cXmlCREst, 0 };
					,{"basesAquis"	, cXmlBaseA, 0 };
					,{"basesComerc"	, cXmlBaseC, 0 }})

				//-- Limpo as variáveis
				cXmlInfoE 	:= ""
				cInEsRef	:= ""
				cXmlLotac	:= ""
				cXmlCREst	:= ""
				cXmlBaseA	:= ""
				cXmlBaseC	:= ""

				T2X->(DbSkip())
			EndDo

		EndIf

		//********************
		//-- infoCRContrib
		//********************
		T0D->(DbSetOrder(1))

		If T0D->( MsSeek( xFilial( "T0D" ) + T2V->(T2V_ID+T2V_VERSAO) ) )
			While T0D->(!Eof()) .And. T0D->( T0D_FILIAL+T0D_ID+T0D_VERSAO ) == xFilial( "T2V" ) + T2V->(T2V_ID+T2V_VERSAO)

				If TAFColumnPos("T0D_CODREC")
					xTafTagGroup("infoCRContrib",{{ "tpCR"			,T0D->T0D_CODREC			,PesqPict("T0D","T0D_CODREC"),.F. };
						, {	"vrCR"		,T0D->T0D_VRCOCR			,PesqPict("T0D","T0D_VRCOCR"),.F. };
						, {	"vrCRSusp"	,T0D->T0D_VRCRSU			,PesqPict("T0D","T0D_VRCRSU"),.T. }};
						, @cXmlCRCont)
				else
					xTafTagGroup("infoCRContrib",{{ "tpCR"			,Posicione("C6R",3, xFilial("C6R")+T0D->T0D_IDCODR,"C6R_CODIGO")	,,.F. };
						, {	"vrCR"		,T0D->T0D_VRCOCR			,PesqPict("T0D","T0D_VRCOCR"),.F. };
						, {	"vrCRSusp"	,T0D->T0D_VRCRSU			,PesqPict("T0D","T0D_VRCRSU"),.T. }};
						, @cXmlCRCont)
				EndIf

				T0D->(DbSkip())
			EndDo

		EndIf

		//*******************
		//-- infoAtConc
		//*******************
		xTafTagGroup("infoAtConc", {{"fatorMes", T2V->T2V_FATMES, PesqPict("T2V","T2V_FATMES"), .F.},;
									{"fator13", T2V->T2V_FATDEC, PesqPict("T2V","T2V_FATDEC"), .F.}},;
									@cXmlAtConc)

		//*******************
		//-- infoPJ - 
		//*******************
		Aadd(aInfoPJ, {"indCoop"			, T2V->T2V_INDCOO,								, .T.})
		Aadd(aInfoPJ, {"indConstr"			, T2V->T2V_INDCON,								, .F.})
		Aadd(aInfoPJ, {"indSubstPatr"		, T2V->T2V_INDPAT,								, .T.})
		Aadd(aInfoPJ, {"percRedContrib"		, T2V->T2V_PERCON, PesqPict("T2V","T2V_PERCON")	, .T.})

		If TAFNT0421(lLaySimplif) .And. TafColumnPos("T2V_PERCTR")
			Aadd(aInfoPJ, {"percTransf", T2V->T2V_PERCTR, PesqPict("T2V", "T2V_PERCTR"), .T.})
		EndIf

		If lSimplBeta .and. TafColumnPos("T2V_INDPIS")
			Aadd(aInfoPJ, {"indTribFolhaPisCofins", T2V->T2V_INDPIS, PesqPict("T2V", "T2V_INDPIS"), .T.})
		EndIf

		xTafTagGroup("infoPJ", aInfoPJ, @cXmlPJ, {{"infoAtConc", cXmlAtConc, 0}}, .F., .T.)

		//*******************
		//-- infoContrib
		//*******************
		xTafTagGroup("infoContrib", {{"classTrib", Posicione("C8D", 1, xFilial("C8D") + T2V->T2V_IDCLAS, "C8D_CODIGO"),, .F.}},;
									 @cXmlCtrb, {{"infoPJ", cXmlPJ, 0}}, .T., .T.)

		//*******************
		//-- infoCPSeg
		//*******************
		xTafTagGroup("infoCPSeg", {{"vrDescCP", T2V->T2V_VRDESC, PesqPict("T2V","T2V_VRDESC"), .F.},;
									{"vrCpSeg", T2V->T2V_VRCPSE, PesqPict("T2V","T2V_VRCPSE"), .F.}},;
									@cXmlCPSeg)

		//*******************
		//-- infoCS
		//*******************
		xTafTagGroup("infoCS", {{"nrRecArqBase", T2V->T2V_IDARQB,, .F.},;
								{"indExistInfo", T2V->T2V_INDEXI,, .F.}},;
								@cXml, {{"infoCPSeg", cXmlCPSeg, 0}, {"infoContrib", cXmlCtrb, 1},;
										{"ideEstab", cXmlEstab, 0}, {"infoCRContrib", cXmlCRCont, 0}}, .T., .T.)

		//-- Gravo no array o indicativo e o período de apuração
		If T2V->T2V_INDAPU == '1' //Mensal

			aAdd(aMensal,T2V->T2V_INDAPU)
			aAdd(aMensal,Substr(T2V->T2V_PERAPU, 1, 4) + '-' + Substr(T2V->T2V_PERAPU, 5, 2) )

		ElseIf T2V->T2V_INDAPU == '2' //Anual

			aAdd(aMensal,T2V->T2V_INDAPU)
			aAdd(aMensal,Alltrim(T2V->T2V_PERAPU))

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura do cabecalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TAFColumnPos("T2V_LAYOUT")
			cXml := xTafCabXml( cXml, "T2V", cLayout, cReg, aMensal,,, lLaySimplif, cEsocial )
		Else
			cXml := xTafCabXml( cXml, "T2V", cLayout, cReg, aMensal )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa gravacao do registro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf

	EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF425Grv
Funcao de gravacao para atender o registro S-5011

@Param:
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
           alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
           tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oDados -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
		   informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao

@author Felipe C. Seolin
@since 29/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF425Grv( cLayout as Character, nOpc as Numeric, cFilEv as Character, oXML as Object, cOwner as Character,;
 					cFilTran as Character, cPredeces as Character, nTafRecno as Numeric, cComplem as Character, cGrpTran as Character,;
 					cEmpOriGrp as Character, cFilOriGrp as Character, cXmlID as Character, cEvtOri as character, lMigrador as logical,;
 					lDepGPE as logical, cKey as character, cMatrC9V as character, lLaySmpTot as logical, lExclCMJ as logical,;
					oTransf as object, cXML as character)

	Local cLogOpeAnt  as character
	Local cCmpsNoUpd  as character
	Local cCabec      as character
	Local cT2XPath    as character
	Local cT70Path    as character
	Local cT2YPath    as character
	Local cT2ZPath    as character
	Local cT0APath    as character
	Local cT0BPath    as character
	Local cT0CPath    as character
	Local cT0DPath    as character
	Local cT0EPath    as character
	Local cInconMsg   as character
	Local nI          as numeric
	Local nX          as numeric
	Local nT2X        as numeric
	Local nT70        as numeric
	Local nT2Y        as numeric
	Local nT2Z        as numeric
	Local nT0A        as numeric
	Local nT0B        as numeric
	Local nT0C        as numeric
	Local nT0D        as numeric
	Local nT0E        as numeric
	Local nSeqErrGrv  as numeric
	Local nErro       as numeric
	Local lRet        as logical
	Local aIncons     as array
	Local aRules      as array
	Local aChave      as array
	Local oModel      as object
	Local cIdLotac    as character
	Local cIdFpas     as character
	Local cDescFpas   as character
	Local cIdTerc     as character
	Local cCodTer     as character
	Local aCondicao   as array
	Local cIdCat      as character
	Local cDescCat    as character
	Local cIdComer    as character
	Local cDescCom    as character
	Local cIdCR       as character
	Local cDescCR     as character

	Private lVldModel as logical
	Private oDados    as object

	Default cLayout    := ""
	Default nOpc       := 1
	Default cFilEv     := ""
	Default oXML       := Nil
	Default cOwner     := ""
	Default cFilTran   := ""
	Default cPredeces  := ""
	Default nTafRecno  := 0
	Default cComplem   := ""
	Default cGrpTran   := ""
	Default cEmpOriGrp := ""
	Default cFilOriGrp := ""
	Default cXmlID     := ""
	Default cEvtOri    := ""
	Default lMigrador  := ""
	Default lDepGPE    := ""
	Default cKey       := ""
	Default cMatrC9V   := ""
	Default lLaySmpTot := ""
	Default lExclCMJ   := ""
	Default oTransf    := ""
	Default cXML       := ""

	cLogOpeAnt         := ""
	cCmpsNoUpd         := "|T2G_FILIAL|T2G_ID|T2G_VERSAO|T2G_VERANT|T2G_PROTUL|T2G_PROTPN|T2G_EVENTO|T2G_STATUS|T2G_ATIVO|"
	cCabec             := "/eSocial/evtCS/"
	cT2XPath           := ""
	cT70Path           := ""
	cT2YPath           := ""
	cT2ZPath           := ""
	cT0APath           := ""
	cT0BPath           := ""
	cT0CPath           := ""
	cT0DPath           := ""
	cT0EPath           := ""
	cInconMsg          := ""
	nI                 := 0
	nX                 := 0
	nT2X               := 0
	nT70               := 0
	nT2Y               := 0
	nT2Z               := 0
	nT0A               := 0
	nT0B               := 0
	nT0C               := 0
	nT0D               := 0
	nT0E               := 0
	nSeqErrGrv         := 0
	nErro              := 0
	lRet               := .F.
	aIncons            := {}
	aRules             := {}
	aChave             := {}
	oModel             := Nil
	cIdLotac           := ""
	cIdFpas            := ""
	cDescFpas          := ""
	cIdTerc            := ""
	cCodTer            := ""
	aCondicao          := {}
	cIdCat             := ""
	cDescCat           := ""
	cIdComer           := ""
	cDescCom           := ""
	cIdCR              := ""
	cDescCR            := ""

	lVldModel          := .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	oDados             := {}

	oDados := oXML

	Begin Transaction

		If Findfunction("TafNameEspace")
			cLayNmSpac := TafNameEspace(cXML)
		EndIf

		Aadd( aChave, {"C", "T2V_INDAPU", FTafGetVal( cCabec + "ideEvento/indApuracao", "C", .F., @aIncons, .F. )  , .T.} )

		//Chave do Registro
		cPeriodo	:= FTafGetVal( cCabec + "ideEvento/perApur", "C", .F., @aIncons, .F. )

		If At("-", cPeriodo) > 0
			Aadd( aChave, {"C", "T2V_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
		Else
			Aadd( aChave, {"C", "T2V_PERAPU", cPeriodo  , .T.} )
		EndIf

		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( 'T2V', 2, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA425', cCmpsNoUpd )

			If TafColumnPos( "T2V_LOGOPE" )
				cLogOpeAnt := T2V->T2V_LOGOPE
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrego array com os campos De/Para de gravacao das informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aRules := TAF425Rul()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5

				oModel:LoadValue( "MODEL_T2V", "T2V_FILIAL", T2V->T2V_FILIAL )

				If TAFColumnPos( "T2V_LAYOUT" )
					oModel:LoadValue( "MODEL_T2V", "T2V_LAYOUT", cLayNmSpac)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nI := 1 to Len( aRules )
					oModel:LoadValue( "MODEL_T2V", aRules[ nI, 01 ], FTafGetVal( aRules[ nI, 02 ], aRules[nI, 03], aRules[nI, 04], @aIncons, .F. ) )
				Next nI

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T2V', 'T2V_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T2V', 'T2V_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando se trata de uma alteracao, deleto todas as linhas do Grid³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				//*******************************************
				//eSocial/evtCS/infoCS/ideEstab
				//*******************************************
				nT2X := 1
				cT2XPath := cCabec + "infoCS/ideEstab[" + AllTrim(Str(nT2X)) + "]"
				If nOpc == 4 .and. oDados:XPathHasNode( cT2XPath )
					For nX := 1 to oModel:GetModel( "MODEL_T2X" ):Length()
						oModel:GetModel( "MODEL_T2X" ):GoLine(nX)
						oModel:GetModel( "MODEL_T2X" ):DeleteLine()
					Next nX
				EndIf

				//Rodo o XML parseado para gravar as novas informacoes no GRID
				nT2X := 1
				While oDados:XPathHasNode(cT2XPath)

					If nOpc == 4 .Or. nT2X > 1
						oModel:GetModel( "MODEL_T2X" ):lValid:= .T.
						oModel:GetModel( "MODEL_T2X" ):AddLine()
					EndIf

					oModel:LoadValue( "MODEL_T2X", "T2X_TPINSE"	, FTafGetVal( cT2XPath + "/tpInsc" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2X", "T2X_NRINSE"	, FTafGetVal( cT2XPath + "/nrInsc" , "C", .F., @aIncons, .F. ) )

					//****************************************
					//eSocial/evtCS/infoCS/ideEstab/infoEstab
					//****************************************
					oModel:LoadValue( "MODEL_T2X", "T2X_CNAEPR"	, FTafGetVal( cT2XPath + "/infoEstab/cnaePrep"		, "C", .F., @aIncons, .F. ) )
					
					If TAFNT0421(lLaySimplif) .And. TafColumnPos("T2X_CNPJRE")
						oModel:LoadValue("MODEL_T2X", "T2X_CNPJRE", FTafGetVal(cT2XPath + "/infoEstab/cnpjResp", "C", .F., @aIncons, .F.))
					EndIf

					oModel:LoadValue( "MODEL_T2X", "T2X_ALIRAT"	, FTafGetVal( cT2XPath + "/infoEstab/aliqRat"		, "N", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2X", "T2X_FAP"	, FTafGetVal( cT2XPath + "/infoEstab/fap" 			, "N", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2X", "T2X_ALIAJU"	, FTafGetVal( cT2XPath + "/infoEstab/aliqRatAjust"	, "N", .F., @aIncons, .F. ) )

					If TAFColumnPos("V79_ALIRAT")

						oModel:LoadValue("MODEL_V79", "V79_ALIRAT"	, FTafGetVal(cT2XPath + "/infoEstab/infoEstabRef/aliqRat"		, "N", .F., @aIncons, .F.))
						oModel:LoadValue("MODEL_V79", "V79_FAP"		, FTafGetVal(cT2XPath + "/infoEstab/infoEstabRef/fap" 			, "N", .F., @aIncons, .F.))
						oModel:LoadValue("MODEL_V79", "V79_ALIAJU"	, FTafGetVal(cT2XPath + "/infoEstab/infoEstabRef/aliqRatAjust"	, "N", .F., @aIncons, .F.))
					
					EndIf

					//******************************************************
					//eSocial/evtCS/infoCS/ideEstab/infoEstab/infoComplObra
					//******************************************************
					oModel:LoadValue( "MODEL_T2X", "T2X_INDPAT"	, FTafGetVal( cT2XPath + "/infoEstab/infoComplObra/indSubstPatrObra"	, "C", .F., @aIncons, .F. ) )

					//**************************************************
					//eSocial/evtCS/infoCS/ideEstab/ideLotacao
					//**************************************************
					nT2Y := 1
					cT2YPath := cT2XPath + "/ideLotacao[" + AllTrim(Str(nT2Y)) + "]"

					If nOpc == 4 .and. oDados:XPathHasNode( cT2YPath )
						For nX := 1 to oModel:GetModel( "MODEL_T2Y" ):Length()
							oModel:GetModel( "MODEL_T2Y" ):GoLine(nX)
							oModel:GetModel( "MODEL_T2Y" ):DeleteLine()
						Next nX
					EndIf

					//Rodo o XML parseado para gravar as novas informacoes no GRID
					nT2Y := 1
					While oDados:XPathHasNode(cT2YPath)

						If nOpc == 4 .Or. nT2Y > 1
							oModel:GetModel( "MODEL_T2Y" ):lValid:= .T.
							oModel:GetModel( "MODEL_T2Y" ):AddLine()
						EndIf

						//T2Y_LOTTRB, T2Y_FPAS
						//T2Y_CODLOT, T2Y_DFPAS, T2Y_CODTER
						If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
							aCondicao := {}
							aAdd(aCondicao, "C99_CODIGO = '" + FTafGetVal( cT2YPath + "/codLotacao", "C", .F., @aIncons, .F. ) + "'")

							cIdLotac := TAF425Ret("C99", "C99_ID", aCondicao)
							If ValType(cIdLotac) <> "U"
								oModel:LoadValue( "MODEL_T2Y", "T2Y_LOTTRB"	, cIdLotac )
								oModel:LoadValue( "MODEL_T2Y", "T2Y_CODLOR"	, SubStr(AllTrim(cIdLotac) + " - " + FTafGetVal( cT2YPath + "/codLotacao", "C", .F., @aIncons, .F. ), 1, TamSX3("T2Y_CODLOR")[1]) )
							Else
								nErro++
								oModel:LoadValue( "MODEL_T2Y", "T2Y_LOTTRB"	, "ERR" + StrZero(nErro) )
								oModel:LoadValue( "MODEL_T2Y", "T2Y_CODLOR"	, "ERR" + StrZero(nErro) + " - Id da Lotação " + FTafGetVal( cT2YPath + "/codLotacao", "C", .F., @aIncons, .F. ) + " não encontrado." )
							EndIf

							aCondicao := {}
							aAdd(aCondicao, "C8A_CDFPAS = '" + FTafGetVal( cT2YPath + "/fpas", "C", .F., @aIncons, .F. ) + "'")
							aAdd(aCondicao, "C8A_CODTER = '" + FTafGetVal( cT2YPath + "/codTercs", "C", .F., @aIncons, .F. ) + "'")

							cIdFpas := TAF425Ret("C8A", "C8A_ID", aCondicao)
							If ValType(cIdFpas) <> "U"
								oModel:LoadValue( "MODEL_T2Y", "T2Y_FPAS"	, cIdFpas )
							EndIf

							cDescFpas := TAF425Ret("C8A", "C8A_SITCTB", aCondicao)
							If ValType(cDescFpas) <> "U"
								oModel:LoadValue( "MODEL_T2Y", "T2Y_DFPASR"	, SubStr(AllTrim(FTafGetVal( cT2YPath + "/fpas", "C", .F., @aIncons, .F. )) + " - " + cDescFpas, 1, TamSX3("T2Y_DFPASR")[1]) )
							EndIf

							cCodTer := TAF425Ret("C8A", "C8A_CODTER", aCondicao)
							If ValType(cCodTer) <> "U"
								oModel:LoadValue( "MODEL_T2Y", "T2Y_CODTRR"	, SubStr(cCodTer, 1, TamSX3("T2Y_CODTRR")[1]) )
							EndIf
						Else
							oModel:LoadValue( "MODEL_T2Y", "T2Y_LOTTRB"	, FGetIdInt( "codLotacao", "", cT2YPath + "/codLotacao",,,,@cInconMsg, @nSeqErrGrv) 	)
							oModel:LoadValue( "MODEL_T2Y", "T2Y_FPAS"	, FGetIdInt( "codTerc",, cT2YPath + "/codTercs" ,,,,@cInconMsg, @nSeqErrGrv))
						EndIf
						oModel:LoadValue( "MODEL_T2Y", "T2Y_TERSUS"	, FTafGetVal( cT2YPath + "/codTercsSusp" , "C", .F., @aIncons, .F. ) )

						//******************************************************
						//eSocial/evtCS/infoCS/ideEstab/ideLotacao/infoTercSusp
						//******************************************************
						nT0E := 1
						cT0EPath := cT2YPath + "/infoTercSusp[" + AllTrim(Str(nT0E)) + "]"

						If nOpc == 4 .and. oDados:XPathHasNode( cT0EPath )
							For nX := 1 to oModel:GetModel( "MODEL_T0E" ):Length()
								oModel:GetModel( "MODEL_T0E" ):GoLine(nX)
								oModel:GetModel( "MODEL_T0E" ):DeleteLine()
							Next nX
						EndIf

						//Rodo o XML parseado para gravar as novas informacoes no GRID
						nT0E := 1
						While oDados:XPathHasNode(cT0EPath)

							If nOpc == 4 .Or. nT0E > 1
								oModel:GetModel( "MODEL_T0E" ):lValid:= .T.
								oModel:GetModel( "MODEL_T0E" ):AddLine()
							EndIf

							//codTerc
							If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))

								aCondicao := {}
								aAdd(aCondicao, "C8A_CODTER = '" + FTafGetVal( cT0EPath + "/codTerc", "C", .F., @aIncons, .F. ) + "'")
								cIdTerc := TAF425Ret("C8A", "C8A_ID", aCondicao)

								If ValType(cIdTerc) <> "U"
									oModel:LoadValue( "MODEL_T0E", "T0E_CODTER", cIdTerc )
								EndIf

								//cCodTer := TAF425Ret("C8A", "C8A_CODTER", aCondicao)
								cCodTer := FTafGetVal( cT0EPath + "/codTerc", "C", .F., @aIncons, .F. )
								oModel:LoadValue( "MODEL_T0E", "T0E_DTERR", cCodTer )

							Else

								oModel:LoadValue( "MODEL_T0E", "T0E_CODTER", FGetIdInt("codTerc",, cT0EPath + "/codTerc" ,,,,@cInconMsg, @nSeqErrGrv)	)

							EndIf

							nT0E++
							cT0EPath := cT2YPath + "/infoTercSusp[" + AllTrim(Str(nT0E)) + "]"

						EndDo

						//*********************************************************
						//eSocial/evtCS/infoCS/ideEstab/ideLotacao/infoEmprParcial
						//*********************************************************
						oModel:LoadValue( "MODEL_T2Y", "T2Y_TPINCO"	, FTafGetVal( cT2YPath + "/infoEmprParcial/tpInscContrat" 	, "C", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T2Y", "T2Y_NRINCO"	, FTafGetVal( cT2YPath + "/infoEmprParcial/nrInscContrat" 	, "C", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T2Y", "T2Y_TPINPR"	, FTafGetVal( cT2YPath + "/infoEmprParcial/tpInscProp" 		, "C", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T2Y", "T2Y_NRINPR"	, FTafGetVal( cT2YPath + "/infoEmprParcial/nrInscProp" 		, "C", .F., @aIncons, .F. ) )

						If TafLayESoc("02_05_00") .AND. TafColumnPos("T2Y_NRCNO")
							oModel:LoadValue( "MODEL_T2Y", "T2Y_NRCNO"	, FTafGetVal( cT2YPath + "/infoEmprParcial/cnoObra" 		, "C", .F., @aIncons, .F. ) )
						EndIf

						//*****************************************************
						//eSocial/evtCS/infoCS/ideEstab/ideLotacao/dadosOpPort
						//*****************************************************
						oModel:LoadValue( "MODEL_T2Y", "T2Y_CNPJOP"	, FTafGetVal( cT2YPath + "/dadosOpPort/cnpjOpPortuario" , "C", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T2Y", "T2Y_ALIRAT"	, FTafGetVal( cT2YPath + "/dadosOpPort/aliqRat" 			, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T2Y", "T2Y_FAP"		, FTafGetVal( cT2YPath + "/dadosOpPort/fap" 				, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T2Y", "T2Y_ALRATF"	, FTafGetVal( cT2YPath + "/dadosOpPort/aliqRatAjust" 	, "N", .F., @aIncons, .F. ) )

						//****************************************************
						//eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun
						//****************************************************
						nT2Z := 1
						cT2ZPath := cT2YPath + "/basesRemun[" + AllTrim(Str(nT2Z)) + "]"

						If nOpc == 4 .and. oDados:XPathHasNode( cT2ZPath )

							For nX := 1 to oModel:GetModel( "MODEL_T2Z" ):Length()
								oModel:GetModel( "MODEL_T2Z" ):GoLine(nX)
								oModel:GetModel( "MODEL_T2Z" ):DeleteLine()
							Next nX
							
						EndIf

						//Rodo o XML parseado para gravar as novas informacoes no GRID
						nT2Z := 1
						While oDados:XPathHasNode(cT2ZPath)

							If nOpc == 4 .Or. nT2Z > 1
								oModel:GetModel( "MODEL_T2Z" ):lValid:= .T.
								oModel:GetModel( "MODEL_T2Z" ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_T2Z", "T2Z_INDINC", FTafGetVal( cT2ZPath	+ "/indIncid", "C", .F., @aIncons, .F. ) )
							If  dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231"))

								aCondicao := {}
								aAdd(aCondicao, "C87_CODIGO = '" + FTafGetVal( cT2ZPath + "/codCateg", "C", .F., @aIncons, .F. ) + "'")
								cIdCat := TAF425Ret("C87", "C87_ID", aCondicao)
								If ValType(cIdCat) <> "U"
									oModel:LoadValue( "MODEL_T2Z", "T2Z_CODCAT", cIdCat )
								EndIf

								cDescCat := TAF425Ret("C87", "C87_DESCRI", aCondicao)
								If ValType(cDescCat) <> "U"
									oModel:LoadValue("MODEL_T2Z", "T2Z_DCODCR", SubStr((AllTrim(FTafGetVal(cT2ZPath + "/codCateg", "C", .F., @aIncons, .F. )) + " - " + AllTrim(cDescCat)), 1, TamSX3("T2Z_DCODCR")[1]))
								EndIf

							Else
								oModel:LoadValue( "MODEL_T2Z", "T2Z_CODCAT", FGetIdInt("codCateg",, cT2ZPath + "/codCateg" ,,,,@cInconMsg, @nSeqErrGrv)	)
							EndIf

							//************************************************************
							//eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesRemun/basesCp
							//************************************************************
							oModel:LoadValue( "MODEL_T2Z", "T2Z_VLBCCP",	FTafGetVal( cT2ZPath + "/basesCp/vrBcCp00" 		, "N", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_T2Z", "T2Z_VLBCAQ",	FTafGetVal( cT2ZPath + "/basesCp/vrBcCp15" 		, "N", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_T2Z", "T2Z_VLBCAV",	FTafGetVal( cT2ZPath + "/basesCp/vrBcCp20" 		, "N", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_T2Z", "T2Z_VLBCVC",	FTafGetVal( cT2ZPath + "/basesCp/vrBcCp25" 		, "N", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_T2Z", "T2Z_VLSUBC",	FTafGetVal( cT2ZPath + "/basesCp/vrSuspBcCp00" 	, "N", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_T2Z", "T2Z_VLSUBQ",	FTafGetVal( cT2ZPath + "/basesCp/vrSuspBcCp15" 	, "N", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_T2Z", "T2Z_VLSUBV",	FTafGetVal( cT2ZPath + "/basesCp/vrSuspBcCp20" 	, "N", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_T2Z", "T2Z_VLSUVC",	FTafGetVal( cT2ZPath + "/basesCp/vrSuspBcCp25" 	, "N", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_T2Z", "T2Z_VLDESE",	FTafGetVal( cT2ZPath + "/basesCp/vrDescSest"	, "N", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_T2Z", "T2Z_VLCASE",	FTafGetVal( cT2ZPath + "/basesCp/vrCalcSest" 	, "N", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_T2Z", "T2Z_VLDESN",	FTafGetVal( cT2ZPath + "/basesCp/vrDescSenat"	, "N", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_T2Z", "T2Z_VLCASN",	FTafGetVal( cT2ZPath + "/basesCp/vrCalcSenat"	, "N", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_T2Z", "T2Z_VLSAFA",	FTafGetVal( cT2ZPath + "/basesCp/vrSalFam" 		, "N", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_T2Z", "T2Z_VLSAMA",	FTafGetVal( cT2ZPath + "/basesCp/vrSalMat" 		, "N", .F., @aIncons, .F. ) )

							If TafColumnPos("T2Z_BC00VA")

								oModel:LoadValue( "MODEL_T2Z", "T2Z_BC00VA",	FTafGetVal( cT2ZPath + "/basesCp/vrBcCp00VA" 		, "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_T2Z", "T2Z_BC15VA",	FTafGetVal( cT2ZPath + "/basesCp/vrBcCp15VA" 		, "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_T2Z", "T2Z_BC20VA",	FTafGetVal( cT2ZPath + "/basesCp/vrBcCp20VA" 		, "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_T2Z", "T2Z_BC25VA",	FTafGetVal( cT2ZPath + "/basesCp/vrBcCp25VA" 		, "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_T2Z", "T2Z_SB00VA",	FTafGetVal( cT2ZPath + "/basesCp/vrSuspBcCp00VA" 	, "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_T2Z", "T2Z_SB15VA",	FTafGetVal( cT2ZPath + "/basesCp/vrSuspBcCp15VA" 	, "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_T2Z", "T2Z_SB20VA",	FTafGetVal( cT2ZPath + "/basesCp/vrSuspBcCp20VA" 	, "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_T2Z", "T2Z_SB25VA",	FTafGetVal( cT2ZPath + "/basesCp/vrSuspBcCp25VA" 	, "N", .F., @aIncons, .F. ) )

							EndIf

							nT2Z++
							cT2ZPath := cT2YPath + "/basesRemun[" + AllTrim(Str(nT2Z)) + "]"

						EndDo

						//******************************************************
						//eSocial/evtCS/infoCS/ideEstab/ideLotacao/basesAvNPort
						//******************************************************
						oModel:LoadValue( "MODEL_T2Y", "T2Y_VRBCCP",	FTafGetVal( cT2YPath + "/basesAvNPort/vrBcCp00" , "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T2Y", "T2Y_VRBCCQ",	FTafGetVal( cT2YPath + "/basesAvNPort/vrBcCp15" , "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T2Y", "T2Y_VRBCCV",	FTafGetVal( cT2YPath + "/basesAvNPort/vrBcCp20" , "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T2Y", "T2Y_VRBCVQ",	FTafGetVal( cT2YPath + "/basesAvNPort/vrBcCp25" , "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T2Y", "T2Y_VRBCCT",	FTafGetVal( cT2YPath + "/basesAvNPort/vrBcCp13" , "N", .F., @aIncons, .F. ) )

						If !lLaySimplif
							oModel:LoadValue( "MODEL_T2Y", "T2Y_VRBCFG",	FTafGetVal( cT2YPath + "/basesAvNPort/vrBcFgts" , "N", .F., @aIncons, .F. ) )
						EndIf

						oModel:LoadValue( "MODEL_T2Y", "T2Y_VRDESC",	FTafGetVal( cT2YPath + "/basesAvNPort/vrDescCP" , "N", .F., @aIncons, .F. ) )

						//*************************************************************
						//eSocial/evtCS/infoCS/ideEstab/ideLotacao/infoSubstPatrOpPort
						//*************************************************************
						nT0A := 1
						cT0APath := cT2YPath + "/infoSubstPatrOpPort[" + AllTrim(Str(nT0A)) + "]"

						If nOpc == 4 .and. oDados:XPathHasNode( cT0APath )
							For nX := 1 to oModel:GetModel( "MODEL_T0A" ):Length()
								oModel:GetModel( "MODEL_T0A" ):GoLine(nX)
								oModel:GetModel( "MODEL_T0A" ):DeleteLine()
							Next nX
						EndIf

						//Rodo o XML parseado para gravar as novas informacoes no GRID
						nT0A := 1
						While oDados:XPathHasNode(cT0APath)

							If nOpc == 4 .Or. nT0A > 1
								oModel:GetModel( "MODEL_T0A" ):lValid:= .T.
								oModel:GetModel( "MODEL_T0A" ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_T0A", "T0A_CNPJOP", FTafGetVal( cT0APath + "/cnpjOpPortuario" , "C", .F., @aIncons, .F. ) )

							nT0A++
							cT0APath := cT2YPath + "/infoSubstPatrOpPort[" + AllTrim(Str(nT0A)) + "]"
						EndDo

						nT2Y++
						cT2YPath := cT2XPath + "/ideLotacao[" + AllTrim(Str(nT2Y)) + "]"

					EndDo

					//******************************************
					//eSocial/evtCS/infoCS/ideEstab/basesAquis
					//******************************************
					nT70 := 1
					cT70Path := cT2XPath + "/basesAquis[" + AllTrim(Str(nT70)) + "]"

					If nOpc == 4 .and. oDados:XPathHasNode( cT70Path )
						For nX := 1 to oModel:GetModel( "MODEL_T70" ):Length()
							oModel:GetModel( "MODEL_T70" ):GoLine(nX)
							oModel:GetModel( "MODEL_T70" ):DeleteLine()
						Next nX
					EndIf

					//Rodo o XML parseado para gravar as novas informacoes no GRID
					nT70 := 1
					While oDados:XPathHasNode(cT70Path)

						If nOpc == 4 .Or. nT70 > 1
							oModel:GetModel( "MODEL_T70" ):lValid:= .T.
							oModel:GetModel( "MODEL_T70" ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_T70", "T70_INDAQU", FTafGetVal( cT70Path + "/indAquis" 		 	, "C", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T70", "T70_VLAQUI", FTafGetVal( cT70Path + "/vlrAquis" 		  	, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T70", "T70_VLCPPR", FTafGetVal( cT70Path + "/vrCPDescPR" 		, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T70", "T70_VLCPRE", FTafGetVal( cT70Path + "/vrCPNRet" 		 	, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T70", "T70_VLRATN", FTafGetVal( cT70Path + "/vrRatNRet" 		, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T70", "T70_VLSENR", FTafGetVal( cT70Path + "/vrSenarNRet" 		, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T70", "T70_VLCPCA", FTafGetVal( cT70Path + "/vrCPCalcPR" 		, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T70", "T70_VLRAPR", FTafGetVal( cT70Path + "/vrRatDescPR" 		, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T70", "T70_VLRACA", FTafGetVal( cT70Path + "/vrRatCalcPR" 		, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T70", "T70_VLSEDE", FTafGetVal( cT70Path + "/vrSenarDesc" 		, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T70", "T70_VLSECA", FTafGetVal( cT70Path + "/vrSenarCalc" 		, "N", .F., @aIncons, .F. ) )

						nT70++
						cT70Path := cT2XPath + "/basesAquis[" + AllTrim(Str(nT70)) + "]"

					EndDo

					//**************************************************
					//eSocial/evtCS/infoCS/ideEstab/basesComerc
					//**************************************************
					nT0B := 1
					cT0BPath := cT2XPath + "/basesComerc[" + AllTrim(Str(nT0B)) + "]"

					If nOpc == 4 .and. oDados:XPathHasNode( cT0BPath )
						For nX := 1 to oModel:GetModel( "MODEL_T0B" ):Length()
							oModel:GetModel( "MODEL_T0B" ):GoLine(nX)
							oModel:GetModel( "MODEL_T0B" ):DeleteLine()
						Next nX
					EndIf

					//Rodo o XML parseado para gravar as novas informacoes no GRID
					nT0B := 1
					While oDados:XPathHasNode(cT0BPath)

						If nOpc == 4 .Or. nT0B > 1
							oModel:GetModel( "MODEL_T0B" ):lValid:= .T.
							oModel:GetModel( "MODEL_T0B" ):AddLine()
						EndIf

						If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))

							aCondicao := {}
							aAdd(aCondicao, "T1T_CODIGO = '" + FTafGetVal( cT0BPath + "/indComerc", "C", .F., @aIncons, .F. ) + "'")
							cIdComer := TAF425Ret("T1T", "T1T_ID", aCondicao)
							If ValType(cIdComer) <> "U"
								oModel:LoadValue( "MODEL_T0B", "T0B_INDCOM", cIdComer )
							EndIf

							cDescCom := TAF425Ret("T1T", "T1T_DESCRI", aCondicao)
							If ValType(cDescCom) <> "U"
								oModel:LoadValue( "MODEL_T0B", "T0B_DINDCR", SubStr(AllTrim(FTafGetVal( cT0BPath + "/indComerc", "C", .F., @aIncons, .F. )) + " - " + cDescCom, 1, TamSX3("T0B_DINDCR")[1]) )
							EndIf

						Else

							oModel:LoadValue( "MODEL_T0B", "T0B_INDCOM", FGetIdInt("indComerc","",cT0BPath + "/indComerc",,,,@cInconMsg, @nSeqErrGrv) )

						EndIf

						oModel:LoadValue( "MODEL_T0B", "T0B_VLBCCO", FTafGetVal( cT0BPath + "/vrBcComPR"	 	, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T0B", "T0B_VLCPSU", FTafGetVal( cT0BPath + "/vrCPSusp"	  	, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T0B", "T0B_VLRASU", FTafGetVal( cT0BPath + "/vrRatSusp"		, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T0B", "T0B_VLSESU", FTafGetVal( cT0BPath + "/vrSenarSusp" 	, "N", .F., @aIncons, .F. ) )

						nT0B++
						cT0BPath := cT2XPath + "/basesComerc[" + AllTrim(Str(nT0B)) + "]"

					EndDo

					//**************************************************
					//eSocial/evtCS/infoCS/ideEstab/infoCREstab
					//**************************************************
					nT0C := 1
					cT0CPath := cT2XPath + "/infoCREstab[" + AllTrim(Str(nT0C)) + "]"

					If nOpc == 4 .and. oDados:XPathHasNode( cT0CPath )
						For nX := 1 to oModel:GetModel( "MODEL_T0C" ):Length()
							oModel:GetModel( "MODEL_T0C" ):GoLine425ret(nX)
							oModel:GetModel( "MODEL_T0C" ):DeleteLine()
						Next nX
					EndIf

					//Rodo o XML parseado para gravar as novas informacoes no GRID
					nT0C := 1
					While oDados:XPathHasNode(cT0CPath)

						If nOpc == 4 .Or. nT0C > 1
							oModel:GetModel( "MODEL_T0C" ):lValid:= .T.
							oModel:GetModel( "MODEL_T0C" ):AddLine()
						EndIf

						If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))

							aCondicao := {}
							aAdd(aCondicao, "C6R_CODIGO = '" + FTafGetVal( cT0CPath + "/tpCR", "C", .F., @aIncons, .F. ) + "'")
							cIdCR := TAF425Ret("C6R", "C6R_ID", aCondicao)

							If TAFColumnPos("T0C_CODREC")
								oModel:LoadValue( "MODEL_T0C", "T0C_IDCODR", "999999" ) //mantem fixo devido x2_unico legado
								oModel:LoadValue( "MODEL_T0C", "T0C_CODREC", FTafGetVal( cT0CPath + "/tpCR", "C", .F., @aIncons , .F. ) )
							Else
								If ValType(cIdCR) <> "U"
									oModel:LoadValue( "MODEL_T0C", "T0C_IDCODR", cIdCR )
								EndIf
							EndIf

							cDescCR := TAF425Ret("C6R", "C6R_DESCRI", aCondicao)
							If ValType(cDescCR) <> "U"
								oModel:LoadValue( "MODEL_T0C", "T0C_DCODRR", SubStr(AllTrim(cIdCR) + " - " + cDescCR, 1, TamSX3("T0C_DCODRE")[1]) )
							EndIf

							If oDados:XPathHasNode( cT0CPath + "/codLotacao")

								aCondicao := {}
								aAdd(aCondicao, "C99_CODIGO = '" + FTafGetVal( cT0CPath + "/codLotacao", "C", .F., @aIncons, .F. ) + "'")

								cIdLotac := TAF425Ret("C99", "C99_ID", aCondicao)

								If ValType(cIdLotac) <> "U"
									oModel:LoadValue( "MODEL_T0C", "T0C_LOTACA", cIdLotac )
									oModel:LoadValue( "MODEL_T0C", "T0C_CODLOR", SubStr(cIdLotac + " - " + FTafGetVal( cT0CPath + "/codLotacao", "C", .F., @aIncons, .F. ), 1, TamSX3("T0C_CODLOR")[1]) )
								EndIf

							EndIf

						Else

							If TAFColumnPos("T0C_CODREC")
								oModel:LoadValue( "MODEL_T0C", "T0C_IDCODR", "999999" ) //mantem fixo devido x2_unico legado
								oModel:LoadValue( "MODEL_T0C", "T0C_CODREC", FTafGetVal( cT0CPath + "/tpCR", "C", .F., @aIncons , .F. ) )
							Else
								oModel:LoadValue( "MODEL_T0C", "T0C_IDCODR", FGetIdInt("tpCR","",cT0CPath + "/tpCR",,,,@cInconMsg, @nSeqErrGrv)	)
							EndIf

							oModel:LoadValue( "MODEL_T0C", "T0C_LOTACA", FGetIdInt( "codLotacao", "", cT0CPath + "/codLotacao",,,,@cInconMsg, @nSeqErrGrv) )
						EndIf

						oModel:LoadValue( "MODEL_T0C", "T0C_VLCOCR", FTafGetVal( cT0CPath + "/vrCR" 		, "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T0C", "T0C_VLSUCR", FTafGetVal( cT0CPath + "/vrSuspCR" 	, "N", .F., @aIncons, .F. ) )

						nT0C++
						cT0CPath := cT2XPath + "/infoCREstab[" + AllTrim(Str(nT0C)) + "]"

					EndDo

					nT2X++
					cT2XPath := cCabec + "infoCS/ideEstab[" + AllTrim(Str(nT2X)) + "]"

				EndDo

				//**************************************************
				//eSocial/evtCS/infoCS/infoCRContrib
				//**************************************************
				nT0D := 1
				cT0DPath := cCabec + "infoCS/infoCRContrib[" + AllTrim(Str(nT0D)) + "]"

				If nOpc == 4 .and. oDados:XPathHasNode( cT0DPath )
					For nX := 1 to oModel:GetModel( "MODEL_T0D" ):Length()
						oModel:GetModel( "MODEL_T0D" ):GoLine(nX)
						oModel:GetModel( "MODEL_T0D" ):DeleteLine()
					Next nX
				EndIf

				//Rodo o XML parseado para gravar as novas informacoes no GRID
				nT0D := 1
				While oDados:XPathHasNode(cT0DPath)

					If nOpc == 4 .Or. nT0D > 1
						oModel:GetModel( "MODEL_T0D" ):lValid:= .T.
						oModel:GetModel( "MODEL_T0D" ):AddLine()
					EndIf

					If (dDataBase >= GetNewPar("MV_TOTEXDT", SToD("20991231")))
						aCondicao := {}
						//aAdd(aCondicao, "C6R_ID = '" + FTafGetVal( cT0DPath + "/tpCR", "C", .F., @aIncons, .F. ) + "'")
						aAdd(aCondicao, "C6R_CODIGO = '" + FTafGetVal( cT0DPath + "/tpCR", "C", .F., @aIncons, .F. ) + "'")
						cIdCR := TAF425Ret("C6R", "C6R_ID", aCondicao)
						If TAFColumnPos("T0D_CODREC")
							oModel:LoadValue( "MODEL_T0D", "T0D_IDCODR", "999999" ) //mantem fixo devido x2_unico legado
							oModel:LoadValue( "MODEL_T0D", "T0D_CODREC", FTafGetVal( cT0DPath + "/tpCR", "C", .F., @aIncons, .F. ) )
						Else
							If ValType(cIdCR) <> "U"
								oModel:LoadValue( "MODEL_T0D", "T0D_IDCODR", cIdCR )
							EndIf
						EndIf

						cDescCR := TAF425Ret("C6R", "C6R_DESCRI", aCondicao)
						If ValType(cDescCR) <> "U"
							oModel:LoadValue( "MODEL_T0D", "T0D_DCODRR", SubStr(cIdCR + " - " + cDescCR, 1, TamSX3("T0D_DCODRR")[1]) )
						EndIf
					Else
						If TAFColumnPos("T0D_CODREC")
							oModel:LoadValue( "MODEL_T0D", "T0D_IDCODR", "999999" ) //mantem fixo devido x2_unico legado
							oModel:LoadValue( "MODEL_T0D", "T0D_CODREC", FTafGetVal( cT0DPath + "/tpCR", "C", .F., @aIncons, .F. ) )
						Else
							oModel:LoadValue( "MODEL_T0D", "T0D_IDCODR", FGetIdInt("tpCR","",cT0DPath + "/tpCR",,,,@cInconMsg, @nSeqErrGrv)	)
						EndIf
					EndIf

					oModel:LoadValue( "MODEL_T0D", "T0D_VRCOCR", FTafGetVal( cT0DPath + "/vrCR" 		, "N", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T0D", "T0D_VRCRSU", FTafGetVal( cT0DPath + "/vrCRSusp"	, "N", .F., @aIncons, .F. ) )

					nT0D++
					cT0DPath := cCabec + "infoCS/infoCRContrib[" + AllTrim(Str(nT0D)) + "]""
				EndDo

			EndIf

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetiva a operacao desejada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cInconMsg)
			If TafFormCommit( oModel )
				Aadd(aIncons, "ERRO19")
			Else
				lRet := .T.
			EndIf
		Else
			Aadd(aIncons, cInconMsg)
		EndIf

		oModel:DeActivate()

	End Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zerando os arrays e os Objetos utilizados no processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF425Rul
Regras para gravacao dos Imposto de Renda Retido na Fonte S-5002 do E-Social

@Param

@Return
aRull - Regras para a gravacao das informacoes

@author Mick William da Silva
@since 05/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF425Rul()

	Local aRull      := {}
	Local cCabec     := "/eSocial/evtCS/"
	Local cPeriodo   := FTafGetVal(cCabec + "/ideEvento/perApur", "C", .F.,, .F. )
	Local cInconMsg  := ""
	Local nSeqErrGrv := 0

	//*******************************************************
	//eSocial/evtCS/ideEvento
	//*******************************************************
	If oDados:XPathHasNode(cCabec + "ideEvento/indApuracao")
		aAdd( aRull, { "T2V_INDAPU", cCabec + "ideEvento/indApuracao"	, 		"C", .F. } )		//indApuracao
	EndIf

	If oDados:XPathHasNode(cCabec + "ideEvento/perApur")
		If At("-", cPeriodo) > 0
			aAdd( aRull, {"T2V_PERAPU", StrTran(cPeriodo, "-", "" ) ,"C",.T.} )
		Else
			aAdd( aRull, {"T2V_PERAPU", cPeriodo ,"C", .T.} )
		EndIf
	EndIf

	//*******************************************************
	//eSocial/evtCS/infoCS
	//*******************************************************
	If oDados:XPathHasNode(cCabec + "infoCS/nrRecArqBase")
		aAdd( aRull, {"T2V_IDARQB", cCabec + "infoCS/nrRecArqBase"					, "C", .F. } )
	EndIf
	If oDados:XPathHasNode(cCabec + "infoCS/indExistInfo")
		aAdd( aRull, {"T2V_INDEXI", cCabec + "infoCS/indExistInfo"					, "C", .F. } )
	EndIf

	//*******************************************************
	//eSocial/evtCS/infoCS/infoCPSeg
	//*******************************************************
	If oDados:XPathHasNode(cCabec + "infoCS/infoCPSeg/vrDescCP")
		aAdd( aRull, {"T2V_VRDESC", cCabec + "infoCS/infoCPSeg/vrDescCP"   		, "N", .F. } )
	EndIf
	If oDados:XPathHasNode(cCabec + "infoCS/infoCPSeg/vrCpSeg")
		aAdd( aRull, {"T2V_VRCPSE", cCabec + "infoCS/infoCPSeg/vrCpSeg"    		, "N", .F. } )
	EndIf

	//*******************************************************
	//eSocial/evtCS/infoCS/infoContrib/
	//*******************************************************
	If oDados:XPathHasNode(cCabec + "infoCS/infoContrib/classTrib")
		Aadd( aRull, {"T2V_IDCLAS", FGetIdInt( "classTrib",	"", cCabec + "infoCS/infoContrib/classTrib" ,,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
	EndIf

	//*******************************************************
	//eSocial/evtCS/infoCS/infoContrib/infoPJ
	//*******************************************************
	If oDados:XPathHasNode(cCabec + "infoCS/infoContrib/infoPJ/indCoop")
		aAdd( aRull, {"T2V_INDCOO", cCabec + "infoCS/infoContrib/infoPJ/indCoop"   		, "C", .F. } )
	EndIf
	If oDados:XPathHasNode(cCabec + "infoCS/infoContrib/infoPJ/indConstr")
		aAdd( aRull, {"T2V_INDCON", cCabec + "infoCS/infoContrib/infoPJ/indConstr"   	, "C", .F. } )
	EndIf
	If oDados:XPathHasNode(cCabec + "infoCS/infoContrib/infoPJ/indSubstPatr")
		aAdd( aRull, {"T2V_INDPAT", cCabec + "infoCS/infoContrib/infoPJ/indSubstPatr"  	, "C", .F. } )
	EndIf
	If oDados:XPathHasNode(cCabec + "infoCS/infoContrib/infoPJ/percRedContrib")
		aAdd( aRull, {"T2V_PERCON", cCabec + "infoCS/infoContrib/infoPJ/percRedContrib" 	, "N", .F. } )
	EndIf

	If TAFNT0421(lLaySimplif) .And. TafColumnPos("T2V_PERCTR")
		If oDados:XPathHasNode(cCabec + "infoCS/infoContrib/infoPJ/percTransf")
			aAdd(aRull, {"T2V_PERCTR", cCabec + "infoCS/infoContrib/infoPJ/percTransf", "C", .F.})
		EndIf
	EndIf

	If lSimplBeta .and. TafColumnPos("T2V_INDPIS")
		If oDados:XPathHasNode(cCabec + "infoCS/infoContrib/infoPJ/indTribFolhaPisCofins")
			aAdd(aRull, {"T2V_INDPIS", cCabec + "infoCS/infoContrib/infoPJ/indTribFolhaPisCofins", "C", .F.})
		EndIf
	EndIf

	//*******************************************************
	//eSocial/evtCS/infoCS/infoContrib/infoAtConc
	//*******************************************************
	If oDados:XPathHasNode(cCabec + "infoCS/infoContrib/infoPJ/infoAtConc/fatorMes")
		aAdd( aRull, {"T2V_FATMES", cCabec + "infoCS/infoContrib/infoPJ/infoAtConc/fatorMes"   , "N", .F.} )
	EndIf
	If oDados:XPathHasNode(cCabec + "infoCS/infoContrib/infoPJ/infoAtConc/fator13")
		aAdd( aRull, {"T2V_FATDEC", cCabec + "infoCS/infoContrib/infoPJ/infoAtConc/fator13"    , "N", .F.} )
	EndIf

Return( aRull )

Static Function TAF425Ret(cTabela, cRetorno, aCondicao)

	Local xRet        := Nil
	Local cQry        := ""
	Local cTab        := ""
	Local nI          := 1
	Local cBaseCnpj   := ""
	Local aBaseFil    := {}
	Local nPosFil     := 0
	Local nPosIni     := 0
	Local cFilBkp     := ""
	Local nX          := 0
	Local cTabAux     := ""

	Default cTabela   := ""
	Default cRetorno  := ""
	Default aCondicao := {}

	cQry := "SELECT " + cRetorno + CRLF
	cQry += "FROM " + RetSQLName((cTabela)) + CRLF
	cQry += "WHERE " + cTabela + "_FILIAL = '" + xFilial((cTabela)) + "'" + CRLF

	For nI := 1 To Len(aCondicao)
		cQry += "	AND " + aCondicao[nI] + CRLF
	Next nI

	If FindFunction("tafIsTabeSocial")
		If tafIsTabeSocial(cTabela)
			cQry += "	AND " + cTabela + "_ATIVO = '1'" + CRLF
		EndIf
	EndIf

	cQry += "	AND D_E_L_E_T_ = ' '"
	cQry := ChangeQuery(cQry)

	cTab := MPSysOpenQuery(cQry)

	If ((cTab)->(!Eof()))

		xRet := (cTab)->&(cRetorno)

	Else

		aBaseFil := FwLoadSM0()
		nPosFil := aScan(aBaseFil, {|x| x[2] == cFilAnt})
		cBaseCnpj := SubStr(aBaseFil[nPosFil][18], 1, 9)
		aSort(aBaseFil, , , {|x,y|x[18] < y[18]})
		nPosIni := aScan(aBaseFil, {|x| SubStr(x[18], 1, 9) == cBaseCnpj})
		cFilBkp := cFilAnt

		If !(Empty(nPosIni))
			nI := nPosIni

			While ((nI <= Len(aBaseFil)) .And. (SubStr(aBaseFil[nI][18], 1, 9) == cBaseCnpj))

				cFilAnt := aBaseFil[nI][2]

				cQry := "SELECT " + cRetorno + CRLF
				cQry += "FROM " + RetSQLName((cTabela)) + CRLF
				cQry += "WHERE " + cTabela + "_FILIAL = '" + xFilial((cTabela)) + "'" + CRLF

				For nX := 1 To Len(aCondicao)
					cQry += "	AND " + aCondicao[nX] + CRLF
				Next nX

				If FindFunction("tafIsTabeSocial")
					If tafIsTabeSocial(cTabela)
						cQry += "	AND " + cTabela + "_ATIVO = '1'" + CRLF
					EndIf
				EndIf

				cQry += "	AND D_E_L_E_T_ = ' '"
				cQry := ChangeQuery(cQry)

				cTabAux := MPSysOpenQuery(cQry)


				If ((cTabAux)->(!Eof()))

					xRet := (cTabAux)->&(cRetorno)
					Exit

				Else
					nI++
				EndIf

				(cTabAux)->(DbCloseArea())
			Enddo

		EndIf

		cFilAnt := cFilBkp
	EndIf

	cQry := Nil

	(cTab)->(DbCloseArea())

Return xRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF425Cbox
@type			function
@description	Construtor de combobox para casos onde o tamanho das
@description	opções ultrapassa o limite permitido no AtuSX.
@author			Felipe C. Seolin
@since			27/09/2018
@version		1.0
@param			cCampo	-	Campo para referência do combobox
@return			cString	-	String formatada no padrão do combobox
/*/
//---------------------------------------------------------------------
Function TAF425Cbox( cCampo )

	Local cString	:=	""

	//If cCampo == "T70_INDAQU"
	cString := "1=" + STR0024 + ";"	//"Aquisição da produção de produtor rural pessoa física ou segurado especial em geral"
	cString += "2=" + STR0025 + ";"	//"Aquisição da produção de produtor rural pessoa física ou segurado especial em geral por Entidade do PAA"
	cString += "3=" + STR0026 + ";"	//"Aquisição da produção de produtor rural pessoa jurídica por Entidade do PAA. Evento de origem (S-1250)"
	cString += "4=" + STR0027 + ";"	//"Aquisição da produção de produtor rural pessoa física ou segurado especial em geral - Produção Isenta (Lei 13.606/2018)"
	cString += "5=" + STR0028 + ";"	//"Aquisição da produção de produtor rural pessoa física ou segurado especial em geral por Entidade do PAA - Produção Isenta (Lei 13.606/2018)"
	cString += "6=" + STR0029		//"Aquisição da produção de produtor rural pessoa jurídica por Entidade do PAA - Produção Isenta (Lei 13.606/2018)"
	//EndIf

Return cString

//---------------------------------------------------------------------
/*/{Protheus.doc} SetLayout

@description	Função para alterar variaveis staticas de controle
				de Layout.
@author			Silas Gomes
@since			23/09/2022
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function SetLayout()

	Local cEsocial   as character
	Local lOperation as logical
	Local lTAF425Xml as logical
	Local lTAF425GRV as logical
	Local lXTAFVEXC  as logical

	cEsocial   := ""
	lOperation := .F.
	lTAF425Xml := FWIsInCallStack("TAF425Xml")
	lTAF425GRV := FWIsInCallStack("TAF425GRV")
	lXTAFVEXC  := FWIsInCallStack("XTAFVEXC")

	If lTAF425GRV
		cEsocial := cLayNmSpac
	Else
		If Type("INCLUI") != "U" .And. Type("ALTERA") != "U"
			lOperation := !INCLUI .And. !ALTERA
		EndIf

		If lTAF425Xml .Or. lOperation .Or. lXTAFVEXC
			If TAFColumnPos("T2V_LAYOUT")		
				cEsocial := T2V->T2V_LAYOUT
			Else
				lLaySimplif  := TAFLayESoc(, .T.)
				lSimplBeta   := TAFLayESoc("S_01_01_00", .T., .T.)			
			EndIf
		EndIf
	EndIf

	If !Empty(cEsocial)
		If Findfunction("TAFIsSimpl")
			lLaySimplif := TAFIsSimpl(AllTrim(cEsocial))
		EndIf

		If AllTrim(cEsocial) == "S_01_01_00"
			lSimplBeta  := .T.
		Else
			lSimplBeta  := .F.
		EndIf
	EndIf
	
Return
