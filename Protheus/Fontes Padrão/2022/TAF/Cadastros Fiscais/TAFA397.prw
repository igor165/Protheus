#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA397.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA397
Sped Fiscal Bloco K - Controle da producao e estoque

@author Vitor Henrique
@since 01/08/2015
@version 1.0

/*/
//------------------------------------------------------------------
Function TAFA397()
	Local oBrw := FWmBrowse():New()

	If TAFAlsInDic( "T18" ) .and. TAFAlsInDic( "LER" )
		oBrw:SetDescription(STR0001) //"Sped Fiscal Bloco K - Controle da producao e estoque"
		oBrw:SetAlias('T18')
		oBrw:SetMenuDef( 'TAFA397' )
		oBrw:Activate()
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Vitor Henrique
@since 01/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aFuncao := {}
	Local aRotina := {}

	Aadd( aFuncao, { "" , "Taf397Vld" , "2" } )

	aRotina	:=	xFunMnuTAF( "TAFA397" , , aFuncao)
Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Vitor Henrique
@since 01/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruT18 	:= FWFormStruct( 1, 'T18' )
	Local oStruT19 	:= FWFormStruct( 1, 'T19' )
	Local oStruT20 	:= FWFormStruct( 1, 'T20' )
	Local oStruT21 	:= FWFormStruct( 1, 'T21' )
	Local oStruT22 	:= FWFormStruct( 1, 'T22' )
	Local oStruT23 	:= FWFormStruct( 1, 'T23' )
	Local oStruT24 	:= FWFormStruct( 1, 'T24' )
	Local oStruLER 	:= FWFormStruct( 1, 'LER' )
	Local oStruLES 	:= FWFormStruct( 1, 'LES' )
	Local oStruLET 	:= FWFormStruct( 1, 'LET' )
	Local oStruLEU 	:= FWFormStruct( 1, 'LEU' )
	Local oStruLEV 	:= FWFormStruct( 1, 'LEV' )
	Local oStruLEX 	:= FWFormStruct( 1, 'LEX' )
	Local oStruLEY 	:= FWFormStruct( 1, 'LEY' )
	Local oModel 		:= MPFormModel():New( 'TAFA397' , , , {|oModel| SaveModel(oModel)})

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruT18:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	oModel:AddFields('MODEL_T18', /*cOwner*/, oStruT18)

	/*------------------------------------------------------------------------------------------
	Estoque Escriturado
	------------------------------------------------------------------------------------------*/
	oModel:AddGrid("MODEL_T19","MODEL_T18",oStruT19)
	oModel:GetModel("MODEL_T19"):SetOptional(.T.)
	oModel:GetModel("MODEL_T19"):SetUniqueLine({"T19_DTEST","T19_CODITE","T19_INDEST","T19_CODPAR"})

	/*------------------------------------------------------------------------------------------
	Outras Movimentacoes Internas entre Mercadorias
	------------------------------------------------------------------------------------------*/
	oModel:AddGrid("MODEL_T20","MODEL_T18",oStruT20)
	oModel:GetModel("MODEL_T20"):SetOptional(.T.)
	oModel:GetModel("MODEL_T20"):SetUniqueLine({"T20_DTMOV", "T20_CODITO","T20_CODITD"})

	/*------------------------------------------------------------------------------------------
	Itens Produzidos e Consumidos - Itens Produzidos
	------------------------------------------------------------------------------------------*/
	oModel:AddGrid("MODEL_T21","MODEL_T18",oStruT21)
	oModel:GetModel("MODEL_T21"):SetOptional(.T.)
	oModel:GetModel("MODEL_T21"):SetUniqueLine({"T21_CODOP","T21_CODITE"})

	/*------------------------------------------------------------------------------------------
	Itens Produzidos e Consumidos - Insumos Consumidos
	------------------------------------------------------------------------------------------*/
	oModel:AddGrid("MODEL_T22","MODEL_T21",oStruT22)
	oModel:GetModel("MODEL_T22"):SetOptional(.T.)
	oModel:GetModel("MODEL_T22"):SetUniqueLine( {"T22_DTSAID","T22_CODINS"})

	/*------------------------------------------------------------------------------------------
	Insdustrializado em Terceiros - Itens produzidos
	------------------------------------------------------------------------------------------*/
	oModel:AddGrid("MODEL_T23","MODEL_T18",oStruT23)
	oModel:GetModel("MODEL_T23"):SetOptional(.T.)
	oModel:GetModel("MODEL_T23"):SetUniqueLine({"T23_DTPROD", "T23_CODITE"})

	/*------------------------------------------------------------------------------------------
	Insdustrializado em Terceiros - Itens Consumidos
	------------------------------------------------------------------------------------------*/
	oModel:AddGrid("MODEL_T24","MODEL_T23",oStruT24)
	oModel:GetModel("MODEL_T24"):SetOptional(.T.)
	oModel:GetModel("MODEL_T24"):SetUniqueLine({"T24_DTCONS", "T24_ITECON"})

	/*------------------------------------------------------------------------------------------
	Desmontagem - Item Origem
	------------------------------------------------------------------------------------------*/
	oModel:AddGrid("MODEL_LER","MODEL_T18",oStruLER)
	oModel:GetModel("MODEL_LER"):SetOptional(.T.)
	oModel:GetModel("MODEL_LER"):SetUniqueLine({"LER_CODOS", "LER_CODITE"})

	/*------------------------------------------------------------------------------------------
	Desmontagem - Itens Destino
	------------------------------------------------------------------------------------------*/
	oModel:AddGrid("MODEL_LES","MODEL_LER",oStruLES)
	oModel:GetModel("MODEL_LES"):SetOptional(.T.)
	oModel:GetModel("MODEL_LES"):SetUniqueLine({"LES_CODITD"})

	/*------------------------------------------------------------------------------------------
	Processamento de Produto
	------------------------------------------------------------------------------------------*/
	oModel:AddGrid("MODEL_LET","MODEL_T18",oStruLET)
	oModel:GetModel("MODEL_LET"):SetOptional(.T.)
	oModel:GetModel("MODEL_LET"):SetUniqueLine({"LET_CODOSP", "LET_CODITE"})

	/*------------------------------------------------------------------------------------------
	Reproc. Mercadorias Consumidas
	------------------------------------------------------------------------------------------*/
	oModel:AddGrid("MODEL_LEU","MODEL_LET",oStruLEU)
	oModel:GetModel("MODEL_LEU"):SetOptional(.T.)
	oModel:GetModel("MODEL_LEU"):SetUniqueLine({"LEU_CODMER"})

	/*------------------------------------------------------------------------------------------
	Correção de Apontamento
	------------------------------------------------------------------------------------------*/
	oModel:AddGrid("MODEL_LEV","MODEL_T18",oStruLEV)
	oModel:GetModel("MODEL_LEV"):SetOptional(.T.)
	oModel:GetModel("MODEL_LEV"):SetUniqueLine({"LEV_DTINIA", "LEV_DTFINA", "LEV_CODOSP", "LEV_CODITE"})

	/*------------------------------------------------------------------------------------------
	Correção e Retorno de Insumos
	------------------------------------------------------------------------------------------*/
	oModel:AddGrid("MODEL_LEX","MODEL_LEV",oStruLEX)
	oModel:GetModel("MODEL_LEX"):SetOptional(.T.)
	oModel:GetModel("MODEL_LEX"):SetUniqueLine({"LEX_CODMER"})

	/*------------------------------------------------------------------------------------------
	Correcao de Apontamento - Estoque Escriturado
	------------------------------------------------------------------------------------------*/
	oModel:AddGrid("MODEL_LEY","MODEL_T18",oStruLEY)
	oModel:GetModel("MODEL_LEY"):SetOptional(.T.)
	oModel:GetModel("MODEL_LEY"):SetUniqueLine({"LEY_DTEST", "LEY_CODITE", "LEY_INDEST", "LEY_CODPAR"})

	oModel:GetModel('MODEL_T18'):SetPrimaryKey({"T18_DTINI", "T18_DTFIN"})

	oModel:SetRelation("MODEL_T19",{ {"T19_FILIAL","xFilial('T19')"}, {"T19_ID","T18_ID"} },T19->(IndexKey(1)) )
	oModel:SetRelation("MODEL_T20",{ {"T20_FILIAL","xFilial('T20')"}, {"T20_ID","T18_ID"} },T20->(IndexKey(1)) )
	oModel:SetRelation("MODEL_T21",{ {"T21_FILIAL","xFilial('T21')"}, {"T21_ID","T18_ID"} },T21->(IndexKey(1)) )
	oModel:SetRelation("MODEL_T22",{ {"T22_FILIAL","xFilial('T22')"}, {"T22_ID","T18_ID"}, {"T22_CODOP","T21_CODOP"},{"T22_CODITE","T21_CODITE"} },T22->(IndexKey(1)) )
	oModel:SetRelation("MODEL_T23",{ {"T23_FILIAL","xFilial('T23')"}, {"T23_ID","T18_ID"} },T23->(IndexKey(1)) )
	oModel:SetRelation("MODEL_T24",{ {"T24_FILIAL","xFilial('T24')"}, {"T24_ID","T18_ID"}, {"T24_DTPROD","T23_DTPROD"},{"T24_CODITE","T23_CODITE"} },T24->(IndexKey(1)) )
	oModel:SetRelation("MODEL_LER",{ {"LER_FILIAL","xFilial('LER')"}, {"LER_ID","T18_ID"}  },LER->(IndexKey(1)) )
	oModel:SetRelation("MODEL_LES",{ {"LES_FILIAL","xFilial('LES')"}, {"LES_ID","T18_ID"}, {"LES_CODOS","LER_CODOS"}, {"LES_CODITE","LER_CODITE"}  },LES->(IndexKey(1)) )
	oModel:SetRelation("MODEL_LET",{ {"LET_FILIAL","xFilial('LET')"}, {"LET_ID","T18_ID"}  },LET->(IndexKey(1)) )
	oModel:SetRelation("MODEL_LEU",{ {"LEU_FILIAL","xFilial('LEU')"}, {"LEU_ID","T18_ID"}, {"LEU_CODOSP","LET_CODOSP"}, {"LEU_CODITE","LET_CODITE"}  },LEU->(IndexKey(1)) )
	oModel:SetRelation("MODEL_LEV",{ {"LEV_FILIAL","xFilial('LEV')"}, {"LEV_ID","T18_ID"}  },LEV->(IndexKey(1)) )
	oModel:SetRelation("MODEL_LEX",{ {"LEX_FILIAL","xFilial('LEX')"}, {"LEX_ID","T18_ID"}, {"LEX_DTINIA","LEV_DTINIA"}, {"LEX_DTFINA","LEV_DTFINA"}, {"LEX_CODOSP","LEV_CODOSP"}, {"LEX_CODITE","LEV_CODITE"}  },LEX->(IndexKey(1)) )
	oModel:SetRelation("MODEL_LEY",{ {"LEY_FILIAL","xFilial('LEY')"}, {"LEY_ID","T18_ID"} },LEY->(IndexKey(1)) )
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Vitor Henrique
@since 01/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'TAFA397' )
	Local oStruT18 := FWFormStruct( 2, 'T18' )
	Local oStruT19 := FWFormStruct( 2, 'T19' )
	Local oStruT20 := FWFormStruct( 2, 'T20' )
	Local oStruT21 := FWFormStruct( 2, 'T21' )
	Local oStruT22 := FWFormStruct( 2, 'T22' )
	Local oStruT23 := FWFormStruct( 2, 'T23' )
	Local oStruT24 := FWFormStruct( 2, 'T24' )
	Local oStruLER := FWFormStruct( 2, 'LER' )
	Local oStruLES := FWFormStruct( 2, 'LES' )
	Local oStruLET := FWFormStruct( 2, 'LET' )
	Local oStruLEU := FWFormStruct( 2, 'LEU' )
	Local oStruLEV := FWFormStruct( 2, 'LEV' )
	Local oStruLEX := FWFormStruct( 2, 'LEX' )
	Local oStruLEY := FWFormStruct( 2, 'LEY' )
	Local oView    := FWFormView():New()

	/*----------------------------------------------------------------------------------
	Esrutura da View
	-------------------------------------------------------------------------------------*/
	oView:SetModel( oModel )


	oView:AddField("VIEW_T18",oStruT18,"MODEL_T18")
	oView:EnableTitleView("VIEW_T18",STR0002) //"K100 - Período de Apuração do ICMS/IPI"

	oView:AddGrid("VIEW_T19",oStruT19,"MODEL_T19")
	oView:EnableTitleView("VIEW_T19",STR0003) //"K200 - Estoque Escriturado""

	oView:AddGrid("VIEW_T20",oStruT20,"MODEL_T20")
	oView:EnableTitleView("VIEW_T20",STR0004) //"K220 - Outras Movimentações Internas entre Mercadorias"

	oView:AddGrid("VIEW_T21",oStruT21,"MODEL_T21")
	oView:EnableTitleView("VIEW_T21",STR0005) //"K230 - Itens Produzidos"

	oView:AddGrid("VIEW_T22",oStruT22,"MODEL_T22")
	oView:EnableTitleView("VIEW_T22",STR0006) //"K235 - Insumos Consumidos"

	oView:AddGrid("VIEW_T23",oStruT23,"MODEL_T23")
	oView:EnableTitleView("VIEW_T23",STR0007) //"K250 - Indust. Efetuada por Terceiros - Itens Produzidos"

	oView:AddGrid("VIEW_T24",oStruT24,"MODEL_T24")
	oView:EnableTitleView("VIEW_T24",STR0008) //"K255 - Indust.em Terceiros - Insumos Consumidos"

	oView:AddGrid("VIEW_LER",oStruLER,"MODEL_LER")
	oView:EnableTitleView("VIEW_LER",STR0011) //"K210 - Desmontagem - Item Origem"

	oView:AddGrid("VIEW_LES",oStruLES,"MODEL_LES")
	oView:EnableTitleView("VIEW_LES",STR0012) //"K215 - Desmontagem - Itens Destino"

	oView:AddGrid("VIEW_LET",oStruLET,"MODEL_LET")
	oView:EnableTitleView("VIEW_LET",STR0013) //"K260 - Reprocessamento de Produto"

	oView:AddGrid("VIEW_LEU",oStruLEU,"MODEL_LEU")
	oView:EnableTitleView("VIEW_LEU",STR0014) //"K265 - Reproc. Mercadorias Consumidas"

	oView:AddGrid("VIEW_LEV",oStruLEV,"MODEL_LEV")
	oView:EnableTitleView("VIEW_LEV",STR0015) //"K270 - Correção de Apontamento"

	oView:AddGrid("VIEW_LEX",oStruLEX,"MODEL_LEX")
	oView:EnableTitleView("VIEW_LEX",STR0016) //"K275 - Correção e Retorno de Insumos"

	oView:AddGrid("VIEW_LEY",oStruLEY,"MODEL_LEY")
	oView:EnableTitleView("VIEW_LEY",STR0017) //"K280 - Correção Apontamento Estoque Escriturado"

	/*-----------------------------------------------------------------------------------
	Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox("PAINEL_PRINCIPAL",28)
	oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") //T18

	oView:CreateHorizontalBox("PAINEL_INFERIOR",72)
	oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR")

	oView:AddSheet("FOLDER_INFERIOR","ABA01",STR0003)
	oView:CreateHorizontalBox("PAINEL_T19",100,,,"FOLDER_INFERIOR","ABA01") //T19
	oView:AddSheet("FOLDER_INFERIOR","ABA02",STR0004)
	oView:CreateHorizontalBox("PAINEL_T20",100,,,"FOLDER_INFERIOR","ABA02") //T20

	oView:AddSheet("FOLDER_INFERIOR","ABA03",STR0009)
	oView:CreateHorizontalBox("PAINEL_T21",50,,,"FOLDER_INFERIOR","ABA03") //T21
	oView:CreateHorizontalBox("PAINEL_T22",50,,,"FOLDER_INFERIOR","ABA03") //T22

	oView:AddSheet("FOLDER_INFERIOR","ABA04",STR0010)
	oView:CreateHorizontalBox("PAINEL_T23",50,,,"FOLDER_INFERIOR","ABA04") //T23
	oView:CreateHorizontalBox("PAINEL_T24",50,,,"FOLDER_INFERIOR","ABA04") //T24

	oView:AddSheet("FOLDER_INFERIOR","ABA05",STR0018)
	oView:CreateHorizontalBox("PAINEL_LER",50,,,"FOLDER_INFERIOR","ABA05") //LER
	oView:CreateHorizontalBox("PAINEL_LES",50,,,"FOLDER_INFERIOR","ABA05") //LES

	oView:AddSheet("FOLDER_INFERIOR","ABA06",STR0019)
	oView:CreateHorizontalBox("PAINEL_LET",50,,,"FOLDER_INFERIOR","ABA06") //LET
	oView:CreateHorizontalBox("PAINEL_LEU",50,,,"FOLDER_INFERIOR","ABA06") //LEU

	oView:AddSheet("FOLDER_INFERIOR","ABA07",STR0020)
	oView:CreateHorizontalBox("PAINEL_LEV",50,,,"FOLDER_INFERIOR","ABA07") //LEV
	oView:CreateHorizontalBox("PAINEL_LEX",50,,,"FOLDER_INFERIOR","ABA07") //LEX

	oView:AddSheet("FOLDER_INFERIOR","ABA08",STR0017)
	oView:CreateHorizontalBox("PAINEL_LEY",100,,,"FOLDER_INFERIOR","ABA08") //LEY

	/*-----------------------------------------------------------------------------------
	Amarração para exibição das informações
	-------------------------------------------------------------------------------------*/
	oView:SetOwnerView( 'VIEW_T18', 'PAINEL_PRINCIPAL' )
	oView:SetOwnerView( 'VIEW_T19', 'PAINEL_T19' )
	oView:SetOwnerView( 'VIEW_T20', 'PAINEL_T20' )
	oView:SetOwnerView( 'VIEW_T21', 'PAINEL_T21' )
	oView:SetOwnerView( 'VIEW_T22', 'PAINEL_T22' )
	oView:SetOwnerView( 'VIEW_T23', 'PAINEL_T23' )
	oView:SetOwnerView( 'VIEW_T24', 'PAINEL_T24' )
	oView:SetOwnerView( 'VIEW_LER', 'PAINEL_LER' )
	oView:SetOwnerView( 'VIEW_LES', 'PAINEL_LES' )
	oView:SetOwnerView( 'VIEW_LET', 'PAINEL_LET' )
	oView:SetOwnerView( 'VIEW_LEU', 'PAINEL_LEU' )
	oView:SetOwnerView( 'VIEW_LEV', 'PAINEL_LEV' )
	oView:SetOwnerView( 'VIEW_LEX', 'PAINEL_LEX' )
	oView:SetOwnerView( 'VIEW_LEY', 'PAINEL_LEY' )


	/*-----------------------------------------------------------------------------------
	Esconde campos de controle interno
	-------------------------------------------------------------------------------------*/
	oStruT18:RemoveField( "T18_ID" )
	oStruT19:RemoveField( "T19_ID" )
	oStruT20:RemoveField( "T20_ID" )
	oStruT21:RemoveField( "T21_ID" )
	oStruT22:RemoveField( "T22_ID" )
	oStruT22:RemoveField( "T22_CODOP" )
	oStruT22:RemoveField( "T22_CODITE" )
	oStruT23:RemoveField( "T23_ID" )
	oStruT24:RemoveField( "T24_ID" )
	oStruT24:RemoveField( "T24_DTPROD" )
	oStruT24:RemoveField( "T24_CODITE")
	If TamSX3("LEY_CODPAR")[1] == 36
		oStruLEY:SetProperty("LEY_CPARTI", MVC_VIEW_ORDEM, "08" )
		oStruLEY:RemoveField("LEY_CODPAR")
	EndIf
	
	If TamSX3("T19_CODPAR")[1] == 36
		oStruT19:SetProperty("T19_CPARTI", MVC_VIEW_ORDEM, "08" )
		oStruT19:RemoveField("T19_CODPAR")
	EndIf
	If TamSX3("T19_CODITE")[1] == 36
		oStruT19:SetProperty("T19_ITEM", MVC_VIEW_ORDEM, "04" )
		oStruT19:RemoveField("T19_CODITE")
	EndIf
	
	If TamSX3("T20_CODITO")[1] == 36
		oStruT20:SetProperty("T20_ITORIG", MVC_VIEW_ORDEM, "04" )
		oStruT20:RemoveField("T20_CODITO")
	EndIf
	
	If TamSX3("T20_CODITD")[1] == 36
		oStruT20:SetProperty("T20_ITDEST", MVC_VIEW_ORDEM, "07" )
		oStruT20:RemoveField("T20_CODITD")
	EndIf
	
	If TamSX3("T21_CODITE")[1] == 36
		oStruT21:SetProperty("T21_ITEM", MVC_VIEW_ORDEM, "06" )
		oStruT21:RemoveField("T21_CODITE")
	EndIf
	
	If TamSX3("T22_CODINS")[1] == 36
		oStruT22:SetProperty("T22_ITINSU", MVC_VIEW_ORDEM, "06" )
		oStruT22:RemoveField("T22_CODINS")
	EndIf
	
	If TamSX3("T22_INSSUB")[1] == 36
		oStruT22:SetProperty("T22_ITSUBS", MVC_VIEW_ORDEM, "09" )
		oStruT22:RemoveField("T22_INSSUB")
	EndIf
	
	If TamSX3("T23_CODITE")[1] == 36
		oStruT23:SetProperty("T23_ITEM", MVC_VIEW_ORDEM, "04" )
		oStruT23:RemoveField("T23_CODITE")
	EndIf
	
	If TamSX3("T24_ITECON")[1] == 36
		oStruT24:SetProperty("T24_ITINSU", MVC_VIEW_ORDEM, "06" )
		oStruT24:RemoveField("T24_ITECON")
	EndIf
	
	If TamSX3("T24_INSSUB")[1] == 36
		oStruT24:SetProperty("T24_ITSUBS", MVC_VIEW_ORDEM, "10" )
		oStruT24:RemoveField("T24_INSSUB")
	EndIf
	
	If TamSX3("LER_CODITE")[1] == 36
		oStruLER:SetProperty("LER_ITEM", MVC_VIEW_ORDEM, "06" )
		oStruLER:RemoveField("LER_CODITE")
	EndIf
	
	If TamSX3("LES_CODITD")[1] == 36
		oStruLES:SetProperty("LES_ITDEST", MVC_VIEW_ORDEM, "05" )
		oStruLES:RemoveField("LES_CODITD")
	EndIf
	
	If TamSX3("LET_CODITE")[1] == 36
		oStruLET:SetProperty("LET_ITEM", MVC_VIEW_ORDEM, "04" )
		oStruLET:RemoveField("LET_CODITE")
	EndIf
	
	If TamSX3("LEU_CODMER")[1] == 36
		oStruLEU:SetProperty("LEU_ITMERC", MVC_VIEW_ORDEM, "04" )
		oStruLEU:RemoveField("LEU_CODMER")
	EndIf
	
	If TamSX3("LEV_CODITE")[1] == 36
		oStruLEV:SetProperty("LEV_ITEM", MVC_VIEW_ORDEM, "06" )
		oStruLEV:RemoveField("LEV_CODITE")
	EndIf
	
	If TamSX3("LEX_CODMER")[1] == 36
		oStruLEX:SetProperty("LEX_ITMERC", MVC_VIEW_ORDEM, "07" )
		oStruLEX:RemoveField("LEX_CODMER")
	EndIf
	
	If TamSX3("LEX_CODINS")[1] == 36
		oStruLEX:SetProperty("LEX_ITINSU", MVC_VIEW_ORDEM, "11" )
		oStruLEX:RemoveField("LEX_CODINS")
	EndIf
	
	If TamSX3("LEY_CODITE")[1] == 36
		oStruLEY:SetProperty("LEY_ITEM", MVC_VIEW_ORDEM, "04" )
		oStruLEY:RemoveField("LEY_CODITE")
	EndIf
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Vitor Henrique
@Since 01/08/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
	Local nOperation := oModel:GetOperation()

	Begin Transaction

		If nOperation == MODEL_OPERATION_UPDATE

			/*-----------------------------------------------------------------------------------
			Funcao responsavel por setar o Status do registro para Branco
			-----------------------------------------------------------------------------------*/
			TAFAltStat( "T18", " " )

		EndIf

		FwFormCommit( oModel )

	End Transaction
Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf397Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Vitor Henrique
@since 01/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Taf397Vld(cAlias,nRecno,nOpc,lJob)
	Local aLogErro		:= {}
	Local cStatus			:= ""
	Local cChave			:= ""
	Local cIdTipo       	:= ""
	Local cCodTipo      	:= ""
	Local cUniItemD  		:= ""
	Local cUniItemO		:= ""
	Local lFound			:= .F.

	Default lJob 			:= .F.

	/*-----------------------------------------------------------------------------------
	Validações do Registro K200
	-----------------------------------------------------------------------------------*/
	("T19")->( DbSetOrder( 1 ) )
	If ("T19")->( DbSeek ( xFilial("T19") + T18->T18_ID) )

		While T19->(!Eof()) .And. (Alltrim(xFilial("T19") + T19->T19_ID) == Alltrim(xFilial("T18") + T18->T18_ID))

			If T18->T18_DTFIN <> T19->T19_DTEST
				AADD(aLogErro,{"T19_DTEST","000676","T18",nRecno}) //STR0676 - "A data do estoque deve ser igual à data final do período de apuração."
			EndIf

			If !Empty(T19->T19_CODITE)

				cIdTipo  := POSICIONE("C1L",3, xFilial("C1L") + T19->T19_CODITE ,"C1L_TIPITE")
				cCodTipo := POSICIONE("C2M",3, xFilial("C2M") + cIdTipo ,"C2M_CODIGO")

				If !(cCodTipo $ '00|01|02|03|04|05|06|10|')
					AADD(aLogErro,{"T19_CODITE","000677","T18",nRecno}) //STR0677 - "Somente podem ser informados nesse campo itens cujos seus tipos sejam iguais a 00, 01, 02, 03, 04, 05, 06 e 10."
				EndIf
			EndIf

			If T19->T19_INDEST <> '0' .AND. Empty(T19->T19_CODPAR)
				AADD(aLogErro,{"T19_INDEST","000678","T18",nRecno}) //STR0678 - "Se preenchido com valor ‘1’ (posse de terceiros) ou ‘2’ (propriedade de terceiros), o campo COD_PART será obrigatório."
			EndIf

			T19->( dbSkip() )
		EndDo
	EndIf

	/*-----------------------------------------------------------------------------------
	Validações do Registro K210
	-----------------------------------------------------------------------------------*/
	("LER")->( DbSetOrder( 1 ) )
	If ("LER")->( DbSeek ( xFilial("LER")+T18->T18_ID) )

		While LER->(!Eof()) .And. (Alltrim(xFilial("LER")+LER->LER_ID) == Alltrim(xFilial("T18")+T18->T18_ID))

			If Empty(LER->LER_DTINIO) .AND. (!Empty(LER->LER_DTFINO) .OR. !Empty(LER->LER_CODOS))
				If Empty(LER->LER_DTINIO)
					AADD(aLogErro,{"LER_DTFINO","000010","T18",nRecno}) //STR0010 - "Campo Inconsistente ou Vazio"
				EndIf
			EndIf

			If !Empty(LER->LER_DTINIO)
				If Empty(LER->LER_CODOS)
					AADD(aLogErro,{"LER_CODOS","000010","T18",nRecno})  //STR0010 - "Campo Inconsistente ou Vazio"
				EndIf
			EndIf

			If !Empty(LER->LER_DTINIO)
				If LER->LER_DTINIO > T18->T18_DTFIN
					AADD(aLogErro,{"LER_DTINIO","000901","T18",nRecno}) //STR0901 - "A data informada deve ser menor ou igual a DT_FIN do registro K100."
				EndIf
			EndIf

			If !Empty(LER->LER_DTFINO)
				If !(LER->LER_DTINIO >= T18->T18_DTINI .AND. LER->LER_DTINIO <= T18->T18_DTFIN)
					AADD(aLogErro,{"LER_DTFINO","000681","T18",nRecno}) //STR0681 - "A data deve estar compreendida dentre o período de apuração do registro K100"
				EndIf
			EndIf


			/*-----------------------------------------------------------------------------------
			Validações do Registro K215
			-----------------------------------------------------------------------------------*/
			("LES")->( DbSetOrder( 1 ) )
			If ("LES")->( DbSeek (xFilial("LES")+LER->(LER_ID+LER_CODOS+LER_CODITE) ) )

				While LES->(!Eof()) .And. (Alltrim(xFilial("LES")+LES->(LES_ID+LES_CODOS+ LES_CODITE)) == Alltrim(xFilial("LER")+LER->(LER_ID+LER_CODOS+LER_CODITE)))

					If LER->LER_CODITE == LES->LES_CODITD
						AADD(aLogErro,{"LES_CODITD","000902","T18",nRecno}) //STR0681 - "A data deve estar compreendida dentre o período de apuração do registro K100"
					EndIf

					LES->( dbSkip() )
				EndDo
			EndIf

			LER->( dbSkip() )
		EndDo
	EndIf

	/*-----------------------------------------------------------------------------------
	Validações do Registro K220
	-----------------------------------------------------------------------------------*/
	("T20")->( DbSetOrder( 1 ) )
	If ("T20")->( DbSeek ( xFilial("T20") + T18->T18_ID) )

		While T20->(!Eof()) .And. (Alltrim(xFilial("T20") + T20->T20_ID) == Alltrim(xFilial("T18") + T18->T18_ID))

			If  !(T20->T20_DTMOV >= T18->T18_DTINI .AND. T20->T20_DTMOV <= T18->T18_DTFIN)
				AADD(aLogErro,{"T20_DTMOV","000679","T18",nRecno}) //STR0679 - "A data deve estar compreendida no período informado nos campos DT_INI e DT_FIN do Registro K100."
			EndIf

			If T20->T20_CODITO == T20->T20_CODITD
				AADD(aLogErro,{"T20_CODITD","000680","T18",nRecno}) //STR0680 - "O valor informado deve ser diferente do ID. Item Ori."
			EndIf

			T20->( dbSkip() )
		EndDo
	EndIf

	/*-----------------------------------------------------------------------------------
	Validações do Registro K230
	-----------------------------------------------------------------------------------*/
	("T21")->( DbSetOrder( 1 ) )
	If ("T21")->( DbSeek ( xFilial("T21") + T18->T18_ID) )

		While T21->(!Eof()) .And. (Alltrim(xFilial("T21") + T21->T21_ID) == Alltrim(xFilial("T18") + T18->T18_ID))

			If Empty(T21->T21_DTINIO) .AND. (!Empty(T21->T21_DTFINO) .OR. !Empty(T21->T21_CODOP))
				If Empty(T21->T21_DTINIO)
					AADD(aLogErro,{"T21_DTINIO","000010","T18",nRecno}) //STR0010 - "Campo Inconsistente ou Vazio"
				EndIf
			EndIf

			If !Empty(T21->T21_DTINIO)
				If T21->T21_DTINIO > T18->T18_DTFIN
					AADD(aLogErro,{"T21_DTINIO","000901","T18",nRecno}) //STR0901 - "A data informada deve ser menor ou igual a DT_FIN do registro K100."
				EndIf
			EndIf

			If !Empty(T21->T21_DTFINO)
				If !(T21->T21_DTFINO >= T18->T18_DTINI .AND. T21->T21_DTFINO <= T18->T18_DTFIN)
					AADD(aLogErro,{"T21_DTFINO","000681","T18",nRecno}) //STR0681 - "A data deve estar compreendida dentre o período de apuração do registro K100"
				EndIf
			EndIf

			If !Empty(T21->T21_DTINIO)
				If Empty(T21->T21_CODOP)
					AADD(aLogErro,{"T21_CODOP","000010","T18",nRecno})  //STR0010 - "Campo Inconsistente ou Vazio"
				EndIf
	 		EndIf


			/*-----------------------------------------------------------------------------------
			Validações do Registro K235
			-----------------------------------------------------------------------------------*/
			("T22")->( DbSetOrder( 1 ) )
			If ("T22")->( DbSeek ( xFilial("T22") + T21->T21_ID + T21->T21_CODOP + T21->T21_CODITE ) )

				While T22->(!Eof()) .And. (Alltrim(xFilial("T22") + T22->T22_ID + T22->T22_CODOP + T22->T22_CODITE) == Alltrim(xFilial("T21") + T21->T21_ID + T21->T21_CODOP + T21->T21_CODITE))

					If !(T22->T22_DTSAID >= T18->T18_DTINI .AND. T22->T22_DTSAID <= T18->T18_DTFIN)
						AADD(aLogErro,{"T22_DTSAID","000681","T18",nRecno}) //STR0681 - "A data deve estar compreendida dentre o período de apuração do registro K100"
					EndIf

					If T22->T22_CODINS == T21->T21_CODITE
						AADD(aLogErro,{"T22_CODINS","000682","T18",nRecno}) //STR0682 - "O código do item componente/insumo deve ser diferente do código do produto resultante no Registro K230"
					EndIf

					cIdTipo  := POSICIONE("C1L",3, xFilial("C1L") + T22->T22_CODINS ,"C1L_TIPITE")
					cCodTipo := POSICIONE("C2M",3, xFilial("C2M") + cIdTipo ,"C2M_CODIGO")

					If !(cCodTipo $ '00|01|02|03|04|05|10')
						AADD(aLogErro,{"T22_CODINS","000677","T18",nRecno}) //STR0677 - "Somente podem ser informados nesse campo itens cujos seus tipos sejam iguais a 00, 01, 02, 03, 04, 05, 06 e 10."
					EndIf

					T22->( dbSkip() )
				EndDo
			EndIf
			T21->( dbSkip() )
		EndDo
	EndIf

	/*-----------------------------------------------------------------------------------
	Validações do Registro K250
	-----------------------------------------------------------------------------------*/
	("T23")->( DbSetOrder( 1 ) )
	If ("T23")->( DbSeek ( xFilial("T23") + T18->T18_ID) )

		While T23->(!Eof()) .And. (Alltrim(xFilial("T23") + T23->T23_ID) == Alltrim(xFilial("T18") + T18->T18_ID))

			If !(T23->T23_DTPROD >= T18->T18_DTINI .AND. T23->T23_DTPROD <= T18->T18_DTFIN)
				AADD(aLogErro,{"T23_DTPROD","000681","T18",nRecno}) //STR0681 - "A data deve estar compreendida dentre o período de apuração do registro K100"
			EndIf

			cIdTipo  := POSICIONE("C1L",3, xFilial("C1L") + T23->T23_CODITE ,"C1L_TIPITE")
			cCodTipo := POSICIONE("C2M",3, xFilial("C2M") + cIdTipo ,"C2M_CODIGO")

			If cCodTipo <> '03' .AND. cCodTipo <> '04'
				AADD(aLogErro,{"T23_CODITE","000683","T18",nRecno}) //STR0683 - "Somente podem ser informados nesse campo itens cujos seus tipos sejam iguais a 03(Produto em Processo) ou 04(Produto Acabado)."
			EndIf


			/*-----------------------------------------------------------------------------------
			Validações do Registro K255
			-----------------------------------------------------------------------------------*/
			("T24")->( DbSetOrder( 1 ) )
			If ("T24")->( DbSeek ( xFilial("T24") + T23->T23_ID + DTOS(T23->T23_DTPROD) + T23->T23_CODITE ) )

				While T24->(!Eof()) .And. (Alltrim(xFilial("T23") + T23->T23_ID + DTOS(T23->T23_DTPROD) + T23->T23_CODITE) == Alltrim(xFilial("T24") + T24->T24_ID + DTOS(T24->T24_DTPROD) + T24->T24_CODITE))

					If !(T24->T24_DTCONS >= T18->T18_DTINI .AND. T24->T24_DTCONS <= T18->T18_DTFIN)
						AADD(aLogErro,{"T24_DTCONS","000681","T18",nRecno}) //STR0681 - "A data deve estar compreendida dentre o período de apuração do registro K100"
					EndIf

					If T24->T24_ITECON == T23->T23_CODITE
						AADD(aLogErro,{"T24_ITECON","000684","T18",nRecno}) //STR0684 - "O código do item componente/insumo deve ser diferente do código do produto resultante no Registro K250"
					EndIf

					cIdTipo  := POSICIONE("C1L",3, xFilial("C1L") + T24->T24_CODITE ,"C1L_TIPITE")
					cCodTipo := POSICIONE("C2M",3, xFilial("C2M") + cIdTipo ,"C2M_CODIGO")

					If !(cCodTipo $ ('00|01|02|03|04|05|10'))
						AADD(aLogErro,{"T24_CODITE","000677","T18",nRecno}) //STR0677 - "Somente podem ser informados nesse campo itens cujos seus tipos sejam iguais a 00, 01, 02, 03, 04, 05, 06 e 10."
					EndIf

					T24->( dbSkip() )
				EndDo
			EndIf
			T23->( dbSkip() )
		EndDo
	EndIf

	/*----------------------------------------------------------
	Validações do Registro K260
	----------------------------------------------------------*/
	("LET")->( DbSetOrder( 1 ) )
	If ("LET")->( DbSeek ( xFilial("LET")+T18->T18_ID) )

		While ("LET")->(!Eof()) .And. (Alltrim(xFilial("LET")+("LET")->LET_ID) == Alltrim(xFilial("T18")+T18->T18_ID))

			If Empty(("LET")->LET_CODOSP)

				If  Empty(("LET")->LET_DTRETO) .AND. (("LET")->LET_DTSAID >= T18->T18_DTINI .AND. ("LET")->LET_DTSAID <= T18->T18_DTFIN)
					AADD(aLogErro,{"LET_CODOSP","000010","T18",nRecno}) //STR0010 - "Campo Inconsistente ou Vazio"
				EndIf
			EndIf

			If !Empty(("LET")->LET_DTSAID)
				If ("LET")->LET_DTSAID > T18->T18_DTFIN
					AADD(aLogErro,{"LET_DTSAID","000901","T18",nRecno}) //STR0901 - "A data informada deve ser menor ou igual a DT_FIN do registro K100."
				EndIf
			EndIf

			If !Empty(("LET")->LET_DTRETO)
				If !((("LET")->LET_DTRETO >= T18->T18_DTINI .AND. ("LET")->LET_DTRETO <= T18->T18_DTFIN)  .OR. (("LET")->LET_DTRETO <= ("LET")->LET_DTSAID))
					AADD(aLogErro,{"LET_DTRETO","000903","T18",nRecno}) //STR0903 - "A data deve estar compreendida no período de apuração – K100 e ser maior que DT_SAÍDA."
				EndIf
			EndIf

			If Empty(("LET")->LET_QTDRET).AND. !Empty(("LET")->LET_DTRETO)
				AADD(aLogErro,{"LET_QTDRET","000010","T18",nRecno}) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			/*----------------------------------------------------------
			Validações do Registro K265
			----------------------------------------------------------*/
			("LEU")->( DbSetOrder( 1 ) )
			If ("LEU")->( DbSeek ( xFilial("LEU")+("LET")->(LET_ID+LET_CODOSP+LET_CODITE) ) )

				While LEU->(!Eof()) .And. (Alltrim(xFilial("LET")+("LET")->(LET_ID+LET_CODOSP+LET_CODITE)) == Alltrim(xFilial("LEU")+LEU->(LEU_ID+LEU_CODOSP+LEU_CODITE)))

					If LEU->LEU_CODMER == ("LET")->LET_CODITE
						AADD(aLogErro,{"LEU_CODMER","000904","T18",nRecno}) //STR0904 - "O código da mercadoria deve ser diferente do código do produto/insumo reprocessado/ reparado (COD_ITEM do Registro K260)."
					EndIf

					cIdTipo  := POSICIONE("C1L",3, xFilial("C1L")+LEU->LEU_CODMER ,"C1L_TIPITE")
					cCodTipo := POSICIONE("C2M",3, xFilial("C2M")+cIdTipo ,"C2M_CODIGO")

					If !(cCodTipo $ ('00|01|02|03|04|05|10'))
						AADD(aLogErro,{"LEU_CODMER","000677","T18",nRecno}) //STR0677 - "Somente podem ser informados nesse campo itens cujos seus tipos sejam iguais a 00, 01, 02, 03, 04, 05 e 10."
					EndIf

					If Empty(LEU->LEU_QTDCON) .AND. Empty(LEU->LEU_QTDRET)
						If Empty(LEU->LEU_QTDCON)
							AADD(aLogErro,{"LEU_QTDCON","000010","T18",nRecno}) //STR0010 - "Campo Inconsistente ou Vazio"
						EndIf
						If Empty(LEU->LEU_QTDRET)
							AADD(aLogErro,{"LEU_QTDRET","000010","T18",nRecno}) //STR0010 - "Campo Inconsistente ou Vazio"
						EndIf
					EndIf

					LEU->( dbSkip() )
				EndDo
			EndIf

			("LET")->( dbSkip() )
		EndDo
	EndIf

	/*----------------------------------------------------------
		Validações do Registro K270
	----------------------------------------------------------*/
	("LEV")->( DbSetOrder( 1 ) )
	If ("LEV")->( DbSeek ( xFilial("LEV")+T18->T18_ID) )

		While LEV->(!Eof()) .And. (Alltrim(xFilial("LEV")+LEV->LEV_ID) == Alltrim(xFilial("T18")+T18->T18_ID))

			If !Empty(LEV->LEV_QTDCPO) .AND. !Empty(LEV->LEV_QTDCNE)
				AADD(aLogErro,{"LEV_QTDCPO","000905","T18",nRecno}) //STR0905 - "Os campos QTD_COR_POS e QTD_COR_NEG não podem ser preenchidos consecutivamente."
			EndIf

			/*----------------------------------------------------------
			Validações do Registro K275
			----------------------------------------------------------*/
			("LEX")->( DbSetOrder( 1 ) )
			If ("LEX")->( DbSeek ( xFilial("LEX")+LEV->(LEV_ID+DTOS(LEV_DTINIA)+DTOS(LEV_DTFINA)+LEV_CODOSP+LEV_CODITE) ) )

				While LEX->(!Eof()) .And. (Alltrim(xFilial("LEV")+ LEV->(LEV_ID+DTOS(LEV_DTINIA)+DTOS(LEV_DTFINA)+LEV_CODOSP+LEV_CODITE)) == Alltrim(xFilial("LEX")+LEX->(LEX_ID+DTOS(LEX_DTINIA)+DTOS(LEX_DTFINA)+LEX_CODOSP+LEX_CODITE)))

					If !Empty(LEX->LEX_QTDCPO) .AND. !Empty(LEX->LEX_QTDCNE)
						AADD(aLogErro,{"LEX_QTDCPO","000905","T18",nRecno}) //STR0905 - "Os campos QTD_COR_POS e QTD_COR_NEG não podem ser preenchidos consecutivamente."
					EndIf

					cIdTipo  := POSICIONE("C1L",3, xFilial("C1L")+LEX->LEX_CODMER ,"C1L_TIPITE")
					cCodTipo := POSICIONE("C2M",3, xFilial("C2M")+cIdTipo ,"C2M_CODIGO")

					If !(cCodTipo $ ('00|01|02|03|04|05|10'))
						AADD(aLogErro,{"LEX_CODMER","000677","T18",nRecno}) //STR0677 - "Somente podem ser informados nesse campo itens cujos seus tipos sejam iguais a 00, 01, 02, 03, 04, 05 e 10."
					EndIf

					If !Empty(LEX->LEX_CODINS)
						 If !LEV->LEV_ORIGEM $ ("1|2")
						 	AADD(aLogErro,{"LEX_CODINS","000906","T18",nRecno}) //STR0906 - "Este campo somente pode existir quando a origem da correção de apontamento for dos tipos 1 ou 2 (campo ORIGEM do Registro K270)."
						 EndIf
					EndIf

					LEX->( dbSkip() )
				EndDo
			EndIf

			LEV->( dbSkip() )
		EndDo
	EndIf


	/*----------------------------------------------------------
	Validações do Registro K280
	----------------------------------------------------------*/
	("LEY")->( DbSetOrder( 1 ) )
	If ("LEY")->( DbSeek ( xFilial("LEY")+T18->T18_ID) )

		While LEY->(!Eof()) .And. (Alltrim(xFilial("LEY")+LEY->LEY_ID) == Alltrim(xFilial("T18")+T18->T18_ID))

			If !(LEY->LEY_DTEST <= T18->T18_DTFIN)
				AADD(aLogErro,{"LEY_DTEST","000907","T18",nRecno}) //STR0907 - "A data do estoque deve ser anterior à data inicial do período de apuração – campo DT_FIN do Registro K100."
			EndIf

			cIdTipo  := POSICIONE("C1L",3, xFilial("C1L")+LEY->LEY_CODITE ,"C1L_TIPITE")
			cCodTipo := POSICIONE("C2M",3, xFilial("C2M")+cIdTipo ,"C2M_CODIGO")

			If !(cCodTipo $ ('00|01|02|03|04|05|06|10'))
				AADD(aLogErro,{"LEY_CODITE","000908","T18",nRecno}) //STR0908 - "Somente podem ser informados nesse campo itens cujos seus tipos sejam iguais a 00, 01, 02, 03, 04, 05, 06 e 10."
			EndIf

			If !Empty(LEY->LEY_QTDCPO) .AND. !Empty(LEY->LEY_QTDCNE)
				AADD(aLogErro,{"LEY_QTDCPO","000905","T18",nRecno}) //STR0905 - "Os campos QTD_COR_POS e QTD_COR_NEG não podem ser preenchidos consecutivamente."
			EndIf

			If !Empty(LEY->LEY_INDEST) .AND. Empty(LEY->LEY_CODPAR)
				AADD(aLogErro,{"LEY_CODPAR","000010","T18",nRecno}) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			LEY->( dbSkip() )
		EndDo
	EndIf

	/*-----------------------------------------------------------------------------------
	Atualizo o Status do registro
	-----------------------------------------------------------------------------------*/
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "T18", cStatus )

	/*-----------------------------------------------------------------------------------
	Não apresento o alert quando utilizo o JOB para validar
	-----------------------------------------------------------------------------------*/
	If !lJob
		xValLogEr(aLogErro)
	EndIf

Return(aLogErro)