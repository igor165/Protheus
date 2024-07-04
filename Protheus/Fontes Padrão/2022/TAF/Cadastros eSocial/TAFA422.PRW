#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TAFA422.CH"

Static lVersao12 	:= GetVersao(.F.) >= '12'
Static lLaySimplif	:= TafLayESoc("S_01_00_00")

//----------------------------------------------------------------------
/*/{Protheus.doc} TAFA422

Imposto de Renda Retido na Fonte - Evento S-5002


@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//---------------------------------------------------------------------
Function TAFA422()

	Local oDialog		as Object
	Local oLayer		as Object
	Local oPanel01		as Object
	Local oPanel02		as Object
	Local oBtFil		as Object
	Local nTop			as Numeric
	Local nHeight		as Numeric
	Local nWidth		as Numeric
	Local aSize			as Array
	Local lFreeze		as Logical
	Local bFiltro		as CodeBlock
	Local bExcReg		as CodeBlock
	Local bGerXml		as CodeBlock
	Local bXmlLote		as CodeBlock
	Local bClose		as CodeBlock

	Private oBrw := FwMBrowse():New()

	oDialog  := Nil
	oLayer   := Nil
	oPanel01 := Nil
	oPanel02 := Nil
	oBtFil   := Nil
	nTop     := 0
	nHeight  := 0
	nWidth   := 0
	aSize    := FWGetDialogSize()
	lFreeze  := .T.
	bFiltro  := {|| FilCpfNome(oBrw, "T2G", "S-5002", 1, 'T2G_PERAPU' )}
	bExcReg  := {|| TAFVExcEsocial( 'T2G' )                                              , oBrw:Refresh(.T.)}
	bGerXml  := {|| TAF422Xml()                                                          , oBrw:Refresh(.T.)}
	bXmlLote := {|| TAFXmlLote( 'T2G' , 'S-5002' , 'evtIrrfBenef' , 'TAF422Xml' , ,oBrw ), oBrw:Refresh(.T.)}
	bClose   := {|| oDialog:End() }
	oBrw     := FwMBrowse():New()
	
	If FindFunction("FilCpfNome") .And. GetSx3Cache("T2G_CPFV","X3_CONTEXT") == "V"

		/*----------------------------
		Construção do Painel Principal
		----------------------------*/

		oDialog := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], "Cadastro de Imposto de Renda Retido na Fonte",,,,,,,,, .T.,,,, .F. )

		oLayer := FWLayer():New()

		oLayer:Init( oDialog, .F. )

		oLayer:AddLine( "LINE01", 100 )

		oLayer:AddCollumn( "BOX01",88,, "LINE01" )
		oLayer:AddCollumn( "BOX02",12,, "LINE01" )

		oLayer:AddWindow( "BOX01", "PANEL01", "Cadastro de Imposto de Renda Retido na Fonte", 100, .F.,,, "LINE01" )
		oLayer:AddWindow( "BOX02", "PANEL02", "Outras Ações"            , 100, .F.,,, "LINE01" )

		oPanel01 := oLayer:GetWinPanel( "BOX01", "PANEL01", "LINE01" )
		oPanel02 := oLayer:GetWinPanel( "BOX02", "PANEL02", "LINE01" )

		/*----------------------------------------------------------------
		Construção do Painel 01 - Browse do Cadastro De Imposto de Renda Retido na Fonte
		----------------------------------------------------------------*/

		// Função que indica se o ambiente é válido para o eSocial 2.4
		If TafAtualizado()
			
			oBrw:SetDescription(STR0019) //"Imposto de Renda Retido na Fonte"
			oBrw:SetAlias("T2G")
			oBrw:SetMenuDef("TAFA422")
			oBrw:SetOwner( oPanel01 )
			oBrw:SetIniWindow(DbSetOrder(2))
			
			If FindFunction('TAFSetFilter')
				oBrw:SetFilterDefault(TAFBrwSetFilter("T2G","TAFA422","S-5002"))
			Else
				oBrw:SetFilterDefault( "T2G_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
			EndIf

			oBrw:AddLegend( "T2G_EVENTO == 'I' ", "GREEN" , STR0020 ) //"Registro Incluído"
			oBrw:AddLegend( "T2G_EVENTO == 'E' ", "RED"   , STR0021 ) //"Registro Excluído"

		EndIf

		/*------------------------------------
		Construção do Painel 02 - Outras Ações
		------------------------------------*/

		nWidth := ( oPanel02:nClientWidth / 2 ) - 3
		nHeight := Int( ( oPanel02:nClientHeight / 2 ) / 10 ) - 5

		nTop := 5
		oBtFil := TButton():New( 005, 002, "Filtro CPF/Nome", oPanel02, bFiltro, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )
		oBtFil:SetCSS(SetCssButton("11","#FFFFFF","#1DA2C3","#1DA2C3"))

		nTop += nHeight + 5
		TButton():New( nTop, 002, "Excluir Registro"    , oPanel02, bExcReg , nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

		nTop += nHeight + 5
		TButton():New( nTop, 002, "Gerar Xml e-Social"  , oPanel02, bGerXml , nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

		nTop += nHeight + 5
		TButton():New( nTop, 002, "Gerar XML em Lote"   , oPanel02, bXmlLote, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

		nTop += nHeight + 5
		TButton():New( nTop, 002, "Fechar"              , oPanel02, bClose  , nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

		/*-------------------
		Ativação da Interface
		-------------------*/

		oBrw:Activate()
		oDialog:Activate()

	Else

		// Função que indica se o ambiente é válido para o eSocial 2.4
		If TafAtualizado()
			oBrw:SetDescription(STR0019) //"Imposto de Renda Retido na Fonte"
			oBrw:SetAlias("T2G")
			oBrw:SetMenuDef("TAFA422")

			If FindFunction('TAFSetFilter')
				oBrw:SetFilterDefault(TAFBrwSetFilter("T2G","TAFA422","S-5002"))
			Else
				oBrw:SetFilterDefault( "T2G_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
			EndIf

			oBrw:AddLegend( "T2G_EVENTO == 'I' ", "GREEN" , STR0020 ) //"Registro Incluído"
			oBrw:AddLegend( "T2G_EVENTO == 'E' ", "RED"   , STR0021 ) //"Registro Excluído"

			oBrw:Activate()
		EndIf

	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Daniel Schmidt
@since 29/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	If FindFunction("FilCpfNome") .And. GetSx3Cache("T2G_CPFV","X3_CONTEXT") == "V"

		ADD OPTION aRotina TITLE "Visualizar" ACTION "VldLayReg(.T.,T2G->T2G_CPFTRA,'TAFA422')" OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION 'VIEWDEF.TAFA422'			 OPERATION 8 ACCESS 0 //'Imprimir'
		
	Else

		Aadd( aFuncao, { "" , "TAF422Xml" , "1" } )
		Aadd( aFuncao, { "" , "xFunHisAlt( 'T2G' , 'TAFA422' )", "3" } )
		Aadd( aFuncao, { "" , "TAFXmlLote( 'T2G', 'S-5002' , 'evtIrrfBenef' , 'TAF422Xml', , oBrw )" , "5" } )
		Aadd( aFuncao, { "" , "xFunAltRec( 'T2G' )" , "10" } )

		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If lMenuDif
			ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA422' OPERATION 2 ACCESS 0 //"Visualizar"
		Else
			aRotina	:=	xFunMnuTAF( "TAFA422" , , aFuncao)

			nPosDel	:=	aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Exibir Histórico de Alterações" } )
			If nPosDel > 0
				aDel( aRotina , nPosDel )
				aSize( aRotina , Len( aRotina ) - 1 )
			EndIf

		EndIf
	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Daniel Schmidt
@since 29/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oModel   	as Object
	Local oStruT2G	as Object
	Local oStruT2I	as Object
	Local oStruT2H	as Object
	Local oStruT2J	as Object
	Local oStruV6J	as Object
	Local oStruV7M	as Object
	Local oStruV7N	as Object
	Local cCmpFil	as Character
	Local nX		as Numeric

	oModel   := MpFormModel():New("TAFA422", , , {|oModel| SaveModel(oModel)}) // Modelo de dados que será construído
	oStruT2G := FwFormStruct(1,"T2G")
	oStruT2I := FwFormStruct(1,"T2I")
	oStruT2H := Nil
	oStruT2J := Nil
	oStruV6J := Nil
	oStruV7M := Nil
	oStruV7N := Nil
	cCmpFil  := ""
	nX       := 0

	If FWIsInCallStack("VldLayReg")
		lLaySimplif := Iif(Type("lLaySimV") == "U", lLaySimplif, lLaySimV)
	EndIf
	
	// Tratamento para simplificação do e-Social
	If !lLaySimplif

		oStruT2H := FwFormStruct(1,"T2H")
		oStruT2J := FwFormStruct(1,"T2J")

		// Remove campos da Model	
		cCmpFil := "T2G_INDDEV|T2G_TPPAG|T2G_DTPAG|T2G_CODCAT|T2G_DCODCA|T2G_CPFBEN|T2G_PERREF"
		aCmpFil := StrTokArr2(cCmpFil, "|")
		
		For nX := 1 To Len(aCmpFil)
			oStruT2G:RemoveField(aCmpFil[nX])
		Next

		// Adiciona ao modelo um componente de formulário
		lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

		If lVldModel
			oStruT2G:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		EndIf

		oModel:AddFields("MODEL_T2G",/*cOwner*/,oStruT2G)
	
		//Informações relativas ao Imposto de Renda Retido na Fonte do Trabalhador e suas bases de cálculo.
		oModel:AddGrid("MODEL_T2H", "MODEL_T2G", oStruT2H)
		oModel:GetModel( "MODEL_T2H" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_T2H" ):SetUniqueLine( { "T2H_CODCAT" } )
		oModel:GetModel('MODEL_T2H'):SetUniqueLine({'T2H_SEQUEN', 'T2H_CODCAT', 'T2H_INDRES'})
		oModel:GetModel('MODEL_T2H'):SetMaxLine(9)

		//Bases, deduções, isenções e retenções do IRRF
		oModel:AddGrid("MODEL_T2I", "MODEL_T2H", oStruT2I)
		oModel:GetModel( "MODEL_T2I" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_T2I" ):SetUniqueLine( { "T2I_CTPVAL" } )
		oModel:GetModel('MODEL_T2I'):SetMaxLine(99) //Informa quantida maxima de linhas na Grid

		//Informações relativas ao Imposto de Renda Retido na Fonte
		oModel:AddGrid("MODEL_T2J", "MODEL_T2H", oStruT2J)
		oModel:GetModel( "MODEL_T2J" ):SetOptional( .T. )

		If TAFColumnPos("T2J_CODREC")
			oModel:GetModel( "MODEL_T2J" ):SetUniqueLine({"T2J_CODREC", "T2J_CTPCR"})
		Else
			oModel:GetModel( "MODEL_T2J" ):SetUniqueLine({"T2J_CTPCR"})
		EndIf

		oModel:GetModel('MODEL_T2J'):SetMaxLine(20) //Informa quantida maxima de linhas na  ) )

		oModel:SetRelation("MODEL_T2H",{ {"T2H_FILIAL","xFilial('T2H')"}, {"T2H_ID","T2G_ID"}, {"T2H_VERSAO","T2G_VERSAO"} },T2H->(IndexKey(1)) )
		oModel:SetRelation("MODEL_T2I",{ {"T2I_FILIAL","xFilial('T2I')"}, {"T2I_ID","T2G_ID"}, {"T2I_VERSAO","T2G_VERSAO"},	{"T2I_SEQUEN","T2H_SEQUEN"} ,{"T2I_CODCAT","T2H_CODCAT"},{"T2I_INDRES","T2H_INDRES"} },T2I->(IndexKey(1)) )
		oModel:SetRelation("MODEL_T2J",{ {"T2J_FILIAL","xFilial('T2J')"}, {"T2J_ID","T2G_ID"}, {"T2J_VERSAO","T2G_VERSAO"},	{"T2J_SEQUEN","T2H_SEQUEN"} ,{"T2J_CODCAT","T2H_CODCAT"},{"T2J_INDRES","T2H_INDRES"} },T2J->(IndexKey(1)) )

		oModel:GetModel("MODEL_T2G"):SetPrimaryKey({"T2G_PERAPU","T2G_CPFTRA"})

	Else
		
		oStruV6J := FwFormStruct(1,"V6J")
		
		If TafColumnPos("V7N_PERDIA")
			oStruV7M := FwFormStruct(1,"V7M")
			oStruV7N := FwFormStruct(1,"V7N")
		EndIf

		// Remove campos da Model	
		cCmpFil := "T2G_VRDEDD|T2G_CPFTRA|"
		aCmpFil := StrTokArr2(cCmpFil, "|")
		
		For nX := 1 To Len(aCmpFil)
			oStruT2G:RemoveField(aCmpFil[nX])
		Next

		// Adiciona ao modelo um componente de formulário
		lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

		If lVldModel
			oStruT2G:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		EndIf

		oModel:AddFields("MODEL_T2G",/*cOwner*/,oStruT2G)

		// 	Informações do demonstrativo de valores devidos
		oModel:AddGrid("MODEL_V6J", "MODEL_T2G",oStruV6J)

		//Bases, deduções, isenções e retenções do IRRF
		oModel:AddGrid("MODEL_T2I", "MODEL_V6J", oStruT2I)

		If TafColumnPos("V7N_PERDIA")
			//totApurMen
			oModel:AddGrid("MODEL_V7M", "MODEL_V6J", oStruV7M)
			oModel:GetModel( "MODEL_V7M" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V7M" ):SetUniqueLine( { "V7M_CRMEN" } )
			oModel:GetModel('MODEL_V7M'):SetMaxLine(50)

			//totApurDia
			oModel:AddGrid("MODEL_V7N", "MODEL_V6J", oStruV7N)
			oModel:GetModel( "MODEL_V7N" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V7N" ):SetUniqueLine( { "V7N_PERDIA", "V7N_CRDIA" } )
			oModel:GetModel('MODEL_V7N'):SetMaxLine(350)
		EndIf

		oModel:GetModel("MODEL_T2G"):SetPrimaryKey( { "T2G_PERAPU", "T2G_CPFBEN" } )

		oModel:GetModel( "MODEL_V6J" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V6J" ):SetUniqueLine( { "V6J_SEQUEN", "V6J_PERREF", "V6J_INDDEV", "V6J_TPPAG" } )
		
		oModel:GetModel( "MODEL_T2I" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_T2I" ):SetUniqueLine( { "T2I_CTPVAL" } )
		oModel:GetModel( "MODEL_T2I" ):SetMaxLine(999) //Informa quantida maxima de linhas na Grid
		
		oStruT2I:SetProperty( "T2I_DTPVAL", MODEL_FIELD_INIT, {|| Iif(!Empty(T2I->T2I_CTPVAL), Posicione("C8U", 1, xFilial("C8U")+T2I->T2I_CTPVAL, "AllTrim(C8U_CODIGO) + ' - ' + AllTrim(C8U_DESCRI)"), "")} )

		oModel:SetRelation( "MODEL_V6J", { { "V6J_FILIAL", "xFilial('V6J')" }, { "V6J_ID", "T2G_ID" }, { "V6J_VERSAO", "T2G_VERSAO" } }, V6J->( IndexKey( 1 ) ) )
		oModel:SetRelation( "MODEL_T2I", { { "T2I_FILIAL", "xFilial('T2I')" }, { "T2I_ID", "T2G_ID" }, { "T2I_VERSAO", "T2G_VERSAO" }, { "T2I_SEQUEN", "V6J_SEQUEN" },;
											{ "T2I_PERREF", "V6J_PERREF" }, { "T2I_INDDEV", "V6J_INDDEV" }, { "T2I_TPPAG", "V6J_TPPAG" }  }, T2I->( IndexKey( 2 ) ) )

		If TafColumnPos("V7N_PERDIA")
			oModel:SetRelation( "MODEL_V7M", { { "V7M_FILIAL", "xFilial('V7M')" }, { "V7M_ID", "T2G_ID" }, { "V7M_VERSAO", "T2G_VERSAO" }, { "V7M_SEQUEN", "V6J_SEQUEN" }, { "V7M_PERREF", "V6J_PERREF" }, { "V7M_INDDEV", "V6J_INDDEV" }, { "V7M_TPPAG", "V6J_TPPAG" } }, V7M->( IndexKey( 1 ) ) )
			oModel:SetRelation( "MODEL_V7N", { { "V7N_FILIAL", "xFilial('V7N')" }, { "V7N_ID", "T2G_ID" }, { "V7N_VERSAO", "T2G_VERSAO" }, { "V7N_SEQUEN", "V6J_SEQUEN" }, { "V7N_PERREF", "V6J_PERREF" }, { "V7N_INDDEV", "V6J_INDDEV" }, { "V7N_TPPAG", "V6J_TPPAG" } }, V7N->( IndexKey( 1 ) ) )
		EndIf
		
	EndIf

Return oModel


//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Daniel Schmidt
@since 29/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   	as Object
	Local oView		as Object
	Local oStruT2I 	as Object
	Local oStruT2H 	as Object
	Local oStruT2J 	as Object
	Local oStruT2Ga	as Object
	Local oStruT2Gb	as Object
	Local oStruT2Gc	as Objects
	Local oStruT2Gd	as Object
	Local oStruV6J	as Object
	Local oStruV7M	as Object
	Local oStruV7N	as Object
	Local cCmpFil	as Character

	oModel    := FWLoadModel( 'TAFA422' )
	oView     := FWFormView():New()
	oStruT2I  := FWFormStruct(2, 'T2I' )
	oStruT2H  := Nil
	oStruT2J  := Nil
	oStruT2Ga := Nil
	oStruT2Gb := Nil
	oStruT2Gc := Nil
	oStruT2Gd := Nil
	oStruV6J  := Nil
	oStruV7M  := Nil
	oStruV7N  := Nil
	cCmpFil   := ""

	If FWIsInCallStack("VldLayReg")
		lLaySimplif := Iif(Type("lLaySimV") == "U", lLaySimplif, lLaySimV)
	EndIf
	
	oView:SetModel(oModel)
	oView:SetContinuousForm(.T.)

	// Tratamento para simplificação do e-Social
	If !lLaySimplif

		oStruT2I 	:= FWFormStruct(2,'T2I' )
		oStruT2H 	:= FWFormStruct(2,'T2H' )
		oStruT2J 	:= FWFormStruct(2,'T2J' )

		//Campos do folder Identificação do evento de retorno
		cCmpFil	:= "T2G_ID|T2G_VERSAO|T2G_RECBAS|T2G_PERAPU|"
		oStruT2Ga	:= FwFormStruct(2,"T2G",{|x| AllTrim(x) + "|" $ cCmpFil })

		//Campos do folder Identificação do trabalhador
		cCmpFil 	:= "T2G_CPFTRA|"
		oStruT2Gb	:= FwFormStruct(2,"T2G",{|x| AllTrim(x) + "|" $ cCmpFil })

		//Campos do folder Identificação do trabalhador
		cCmpFil 	:= "T2G_VRDEDD|"
		oStruT2Gc	:= FwFormStruct(2,"T2G",{|x| AllTrim(x) + "|" $ cCmpFil })

		// Campos do folder do número do ultimo protocolo
		cCmpFil	:= "T2G_PROTUL|"
		oStruT2Gd	:= FwFormStruct( 2, 'T2G', {|x| AllTrim( x ) + "|" $ cCmpFil } )

		If FindFunction("TafAjustRecibo")
			TafAjustRecibo(oStruT2Gd,"T2G")
		EndIf

		/*--------------------------------------------------------------------------------------------
											Esrutura da View
		---------------------------------------------------------------------------------------------*/
		oView:AddField( 'VIEW_T2Ga' , oStruT2Ga, 'MODEL_T2G' )
		oView:EnableTitleView("VIEW_T2Ga",STR0004) //Id. do Evento de Retorno

		oView:AddField( 'VIEW_T2Gb' , oStruT2Gb, 'MODEL_T2G' )
		oView:EnableTitleView("VIEW_T2Gb",STR0005) //Id. do Trabalhador

		oView:AddField( 'VIEW_T2Gc', oStruT2Gc, 'MODEL_T2G' )
		oView:EnableTitleView( 'VIEW_T2Gc', STR0022 ) // "Inf. Dependentes do Beneficiário do Pagamento."

		oView:AddField( 'VIEW_T2Gd', oStruT2Gd, 'MODEL_T2G' )

		oView:EnableTitleView( 'VIEW_T2Gd', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"

		oView:AddGrid ( 'VIEW_T2H' , oStruT2H, 'MODEL_T2H' )
		oView:EnableTitleView( 'VIEW_T2H', STR0023 ) // "Inf. IRRF do Trabalhador e Complementares do Benef. Resid. Ext."
		oView:AddIncrementField( 'VIEW_T2H', 'T2H_SEQUEN' ) 

		oView:AddGrid ( 'VIEW_T2I' , oStruT2I, 'MODEL_T2I' )
		oView:EnableTitleView( 'VIEW_T2I', STR0017 ) // "Bases, deduções, isenções e retenções do IRRF"

		oView:AddGrid ( 'VIEW_T2J' , oStruT2J, 'MODEL_T2J' )
		oView:EnableTitleView( 'VIEW_T2J', STR0015 ) // "Inf. Relativas ao Imposto de Renda Retido na Fonte"

		/*-----------------------------------------------------------------------------------
										Estrutura do Folder
		-------------------------------------------------------------------------------------*/
		oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )

		oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0024 ) //"Imp. de Renda Retido do Benef. do Rendimento"

		oView:CreateHorizontalBox( 'T2Ga', 012,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'T2Gb', 012,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'T2Gc', 012,,, 'FOLDER_SUPERIOR', 'ABA01' )

		oView:CreateHorizontalBox("PAINEL_INFERIOR",064,,,"FOLDER_SUPERIOR","ABA01")
		oView:CreateFolder( 'FOLDER_IRRF', 'PAINEL_INFERIOR' )

		oView:AddSheet( 'FOLDER_IRRF', 'ABA01', STR0025) //"Inf. do IRRF"

		oView:CreateHorizontalBox( 'T2H', 50,,, 'FOLDER_IRRF', 'ABA01' )

		oView:CreateHorizontalBox  ( 'PAINEL_INFO_IRRF', 50,,, 'FOLDER_IRRF', 'ABA01' )
		oView:CreateFolder( 'FOLDER_INFO_IRRF', 'PAINEL_INFO_IRRF' )

		oView:AddSheet( 'FOLDER_INFO_IRRF', 'ABA01', STR0026) //"Bases do IRRF"
		oView:CreateHorizontalBox( 'T2I', 100,,, 'FOLDER_INFO_IRRF', 'ABA01' )

		oView:AddSheet( 'FOLDER_INFO_IRRF', 'ABA02', STR0027) //"IRRF"
		oView:CreateHorizontalBox( 'T2J', 100,,, 'FOLDER_INFO_IRRF', 'ABA02' )

		oView:AddSheet('FOLDER_SUPERIOR', "ABA02", TafNmFolder("recibo") )   //"Numero do Recibo"
		
		oView:CreateHorizontalBox( 'T2Gd', 100,,, 'FOLDER_SUPERIOR', 'ABA02' )

		oView:SetOwnerView( 'VIEW_T2Ga' , 'T2Ga')
		oView:SetOwnerView( 'VIEW_T2Gb' , 'T2Gb')
		oView:SetOwnerView( 'VIEW_T2Gc' , 'T2Gc')
		oView:SetOwnerView( 'VIEW_T2Gd' , 'T2Gd')
		oView:SetOwnerView( 'VIEW_T2H'  , 'T2H' )
		oView:SetOwnerView( 'VIEW_T2I'  , 'T2I' )
		oView:SetOwnerView( 'VIEW_T2J'  , 'T2J' )

		///Tratamento para que alguns campos de controle interno não sejam exibidos na tela
		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If !lMenuDif
			xFunRmFStr(@oStruT2Ga,"T2G")
			xFunRmFStr(@oStruT2Gb,"T2G")
			xFunRmFStr(@oStruT2Gc,"T2G")
			xFunRmFStr(@oStruT2Gd,"T2G")
			xFunRmFStr(@oStruT2H,"T2H")
			xFunRmFStr(@oStruT2I,"T2I")
			xFunRmFStr(@oStruT2J,"T2J")

			oStruT2H:RemoveField('T2H_ID')
			oStruT2I:RemoveField('T2I_ID')
			oStruT2J:RemoveField('T2J_ID')

			oStruT2I:RemoveField("T2I_CODCAT")
			oStruT2J:RemoveField("T2J_CODCAT")

			If TAFColumnPos("T2J_CODREC")
				//Ordem dos campos na tela
				oStruT2J:SetProperty("T2J_CODREC"	, MVC_VIEW_ORDEM, "01"	)
				oStruT2J:SetProperty("T2J_CTPCR"	, MVC_VIEW_ORDEM, "02"	)
				oStruT2J:SetProperty("T2J_DTPCR"	, MVC_VIEW_ORDEM, "03"	)
			EndIf
		EndIf

	Else

		// Campos do folder Identificação do evento de retorno
		cCmpFil		:= "T2G_ID|T2G_VERSAO|T2G_RECBAS|T2G_PERAPU|"
		oStruT2Ga	:= FwFormStruct( 2, "T2G", { |x| AllTrim( x ) + "|" $ cCmpFil } )

		//Campos do folder Identificação do trabalhador
		cCmpFil 	:= "T2G_CPFBEN|"
		oStruT2Gb	:= FwFormStruct(2,"T2G",{|x| AllTrim(x) + "|" $ cCmpFil })

		// Campos do folder do número do ultimo protocolo
		cCmpFil 	:= 'T2G_PROTUL|' 
		oStruT2Gc 	:= FwFormStruct( 2, 'T2G', {|x| AllTrim( x ) + "|" $ cCmpFil } )

		cCmpFil 	:= "V6J_PERREF|V6J_INDDEV|V6J_TPPAG|V6J_DTPAG|V6J_CODCAT|V6J_DCODCA|"
		oStruV6J	:= FwFormStruct( 2, "V6J", { |x| AllTrim( x ) + "|" $ cCmpFil } )

		If TafColumnPos("V7M_CRMEN")
			cCmpFil 	:= "V7M_CRMEN|V7M_VLSUSP|V7M_VLMEN|"
			oStruV7M	:= FwFormStruct( 2, "V7M", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V7N_PERDIA|V7N_CRDIA|V7N_VLCRD|V7N_VLCRD|V7N_VLSUS|"
			oStruV7N	:= FwFormStruct( 2, "V7N", { |x| AllTrim( x ) + "|" $ cCmpFil } )
		EndIf

		TafAjustRecibo(oStruT2Gc, "T2G")
		
		oView:AddField( 'VIEW_T2Ga', oStruT2Ga, 'MODEL_T2G' )
		oView:EnableTitleView( "VIEW_T2Ga", STR0004 ) // "Id. do Evento de Retorno"

		oView:AddField( 'VIEW_T2Gb', oStruT2Gb, 'MODEL_T2G' )
		oView:EnableTitleView("VIEW_T2Gb", STR0005) // "Id. do Trabalhador"

		oView:AddGrid ( 'VIEW_V6J' , oStruV6J, 'MODEL_V6J' )
		oView:EnableTitleView( 'VIEW_V6J', STR0028 ) // "Informações do demonstrativo de valores devidos"

		If TafColumnPos("V7N_PERDIA")
			oView:AddGrid ( 'VIEW_V7M' , oStruV7M, 'MODEL_V7M' )
			oView:EnableTitleView( 'VIEW_V7M', STR0028 ) // "Informações do demonstrativo de valores devidos"

			oView:AddGrid ( 'VIEW_V7N' , oStruV7N, 'MODEL_V7N' )
			oView:EnableTitleView( 'VIEW_V7N', STR0028 ) // "Informações do demonstrativo de valores devidos"*/
		EndIf	

		oView:AddGrid ( 'VIEW_T2I' , oStruT2I, 'MODEL_T2I' )
		oView:EnableTitleView( 'VIEW_T2I', STR0017 ) // "Bases, deduções, isenções e retenções do IRRF"

		oView:AddField( 'VIEW_T2Gc', oStruT2Gc, 'MODEL_T2G' )

		oView:EnableTitleView( 'VIEW_T2Gc', TafNmFolder( "recibo", 1 ) ) // "Recibo da última Transmissão"
		
		oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )
	
		oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0024 ) // "Imp. de Renda Retido do Benef. do Rendimento"

		oView:CreateHorizontalBox( 'T2Ga', 012,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'T2Gb', 012,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'V6J',  038,,, 'FOLDER_SUPERIOR', 'ABA01' )

		oView:CreateHorizontalBox( "PAINEL_INFERIOR" ,038,,, "FOLDER_SUPERIOR", "ABA01" )
	
		oView:CreateFolder( 'FOLDER_INFERIOR', 'PAINEL_INFERIOR' )

		If !TafColumnPos("V7M_FILIAL")
			oView:AddSheet( 'FOLDER_INFERIOR', 'ABA01', STR0017 ) // "Bases, deduções, isenções e retenções do IRRF"

			oView:CreateHorizontalBox( 'T2I', 100,,, 'FOLDER_INFERIOR', 'ABA01' )
		Else
			oView:AddSheet( 'FOLDER_INFERIOR', 'ABA01', STR0017 ) // "Bases, deduções, isenções e retenções do IRRF"
			oView:AddSheet( 'FOLDER_INFERIOR', 'ABA02', STR0035)
			oView:AddSheet( 'FOLDER_INFERIOR', 'ABA03', STR0036) 

			oView:CreateHorizontalBox( 'T2I',  33,,, 'FOLDER_INFERIOR', 'ABA01' )
			oView:CreateHorizontalBox( 'V7M',  33,,, 'FOLDER_INFERIOR', 'ABA02' )
			oView:CreateHorizontalBox( 'V7N',  33,,, 'FOLDER_INFERIOR', 'ABA03' )
		EndIf

		oView:AddSheet('FOLDER_SUPERIOR', "ABA02", TafNmFolder( "recibo" ) )   // "Numero do Recibo"
		
		oView:CreateHorizontalBox( 'T2Gc', 100,,, 'FOLDER_SUPERIOR', 'ABA02' )

		oView:SetOwnerView( 'VIEW_T2Ga' , 'T2Ga')
		oView:SetOwnerView( 'VIEW_T2Gb' , 'T2Gb')
		oView:SetOwnerView( 'VIEW_T2Gc' , 'T2Gc')
		oView:SetOwnerView( 'VIEW_V6J'  , 'V6J' )

		If TafColumnPos("V7M_FILIAL")
			oView:SetOwnerView( 'VIEW_V7M'  , 'V7M' )
			oView:SetOwnerView( 'VIEW_V7N'  , 'V7N' )
		EndIf

		oView:SetOwnerView( 'VIEW_T2I'  , 'T2I' )
		
		oStruT2I:SetProperty( "T2I_CTPVAL", MVC_VIEW_LOOKUP, "C8U" )

		///Tratamento para que alguns campos de controle interno não sejam exibidos na tela
		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If !lMenuDif
			xFunRmFStr(@oStruT2Ga, "T2G")
			xFunRmFStr(@oStruT2Gb, "T2G")
			xFunRmFStr(@oStruV6J,  "V6J")

			If TafColumnPos("V7M_FILIAL")
				xFunRmFStr(@oStruV7M,  "V7M")
				xFunRmFStr(@oStruV7N,  "V7N")
			EndIf

			xFunRmFStr(@oStruT2I,  "T2I")

			oStruV6J:RemoveField( "V6J_ID" 		)
			oStruT2I:RemoveField( "T2I_ID" 		)
			oStruT2I:RemoveField( "T2I_CODCAT" 	)	
			oStruT2I:RemoveField( "T2I_PERREF" 	)	
			oStruT2I:RemoveField( "T2I_INDDEV" 	)	
			oStruT2I:RemoveField( "T2I_TPPAG" 	)	
		EndIf

	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param oModel -> Modelo de dados

@Return .T.

@author Daniel Schmidt
@since 29/05/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local nOperation := oModel:GetOperation()
	Local lRetorno   := .T.

	Begin Transaction

		If nOperation == MODEL_OPERATION_DELETE
			oModel:DeActivate()
			oModel:SetOperation( 5 )
			oModel:Activate()

			FwFormCommit( oModel )
		EndIf

	End Transaction

Return ( lRetorno )


//-------------------------------------------------------------------
/*/{Protheus.doc} TAF422Grv

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

@author Daniel Schmidt
@since 29/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF422Grv( cLayout as Character, nOpc as Numeric, cFilEv as Character, oXML as Object)

	Local cCmpsNoUpd  as Character
	Local cCabec      as Character
	Local cV6JPath    as Character
	Local cT2IPath    as Character
	Local cV7MPath    as Character
	Local cV7NPath    as Character
	Local cPeriodo    as Character
	Local cInconMsg   as Character
	Local cTpValor    as Character
	Local cIdTpValor  as Character
	Local cLogOpeAnt  as Character
	Local cPerRef     as Character
	Local nI          as Numeric
	Local nSeqErrGrv  as Numeric
	Local nT2H        as Numeric
	Local nT2I        as Numeric
	Local nV6J        as Numeric
	Local nV7M        as Numeric
	Local nV7N        as Numeric
	Local nIndChv     as Numeric
	Local lRet        as Logical
	Local aIncons     as Array
	Local aRules      as Array
	Local aChave      as Array
	Local oModel      as Object

	Private lVldModel as Logical //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	Private oDados    as Array

	Default cLayout   := ""
	Default nOpc      := 1
	Default cFilEv    := ""
	Default oXML      := Nil

	cCmpsNoUpd := "|T2G_FILIAL|T2G_ID|T2G_VERSAO|T2G_VERANT|T2G_PROTUL|T2G_PROTPN|T2G_EVENTO|T2G_STATUS|T2G_ATIVO|"
	cCabec     := "/eSocial/evtIrrfBenef/"
	cV6JPath   := ""
	cT2IPath   := ""
	cV7MPath   := ""
	cV7NPath   := ""
	cPeriodo   := ""
	cInconMsg  := ""
	cTpValor   := ""
	cIdTpValor := ""
	cLogOpeAnt := ""
	cPerRef    := ""
	nI         := 0
	nSeqErrGrv := 0
	nT2H       := 0
	nT2I       := 0
	nV6J       := 0
	nV7M       := 0
	nV7N       := 0
	nIndChv    := 2
	lRet       := .F.
	aIncons    := {}
	aRules     := {}
	aChave     := {}
	oModel     := Nil
	lVldModel  := .T.
	oDados     := oXML

	cPeriodo  := FTafGetVal(  cCabec + "ideEvento/perApur", "C", .F., @aIncons, .F. )

	If At("-", cPeriodo) > 0
		Aadd( aChave, {"C", "T2G_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
	Else
		Aadd( aChave, {"C", "T2G_PERAPU", cPeriodo  , .T.} )
	EndIf

	If !lLaySimplif
		Aadd( aChave, { "C", "T2G_CPFTRA", FTafGetVal( cCabec + "ideTrabalhador/cpfTrab" , "C", .F., @aIncons, .F. ), .T. } )
	Else
		Aadd( aChave, { "C", "T2G_CPFBEN", FTafGetVal( cCabec + "ideTrabalhador/cpfBenef" , "C", .F., @aIncons, .F. ), .T. } )
		nIndChv := 3
	EndIf
	
	Begin Transaction

		If FTafVldOpe( 'T2G', nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA422', cCmpsNoUpd )

			cLogOpeAnt := T2G->T2G_LOGOPE
			aRules := TAF422Rul()

			oModel:LoadValue( "MODEL_T2G", "T2G_FILIAL", T2G->T2G_FILIAL )

			For nI := 1 to Len( aRules )
				oModel:LoadValue( "MODEL_T2G", aRules[ nI, 01 ], FTafGetVal( aRules[ nI, 02 ], aRules[nI, 03], aRules[nI, 04], @aIncons, .F. ) )
			Next nI

			TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T2G', 'T2G_LOGOPE' , '1', '' )
	
			If !lLaySimplif

				nT2H := 1
				cT2HPath := cCabec + "infoIrrf[" + AllTrim(Str(nT2H)) + "]"

				While oDados:XPathHasNode(cT2HPath)

					oModel:GetModel( "MODEL_T2H" ):lValid:= .T.

					If nT2H > 1
						oModel:GetModel( "MODEL_T2H" ):AddLine()
					EndIf

					oModel:LoadValue( "MODEL_T2H", "T2H_SEQUEN", STRZERO(nT2H,3) )
					oModel:LoadValue( "MODEL_T2H", "T2H_CODCAT", FGetIdInt( "codCateg", "", cT2HPath + "/codCateg",,,,@cInconMsg, @nSeqErrGrv))
					oModel:LoadValue( "MODEL_T2H", "T2H_INDRES", FTafGetVal( cT2HPath + "/indResBr" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_IDPAIS", FGetIdInt( "codPais", "",  cT2HPath + "/idePgtoExt/idePais/codPais" ,,,,@cInconMsg, @nSeqErrGrv))
					oModel:LoadValue( "MODEL_T2H", "T2H_INDNIF", FTafGetVal( cT2HPath + "/idePgtoExt/idePais/indNIF" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_NIFBEN", FTafGetVal( cT2HPath + "/idePgtoExt/idePais/nifBenef" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_DLOUGR", FTafGetVal( cT2HPath + "/idePgtoExt/endExt/dscLograd" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_NUMLOG", FTafGetVal( cT2HPath + "/idePgtoExt/endExt/nrLograd" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_COMPLE", FTafGetVal( cT2HPath + "/idePgtoExt/endExt/complem" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_BAIRRO", FTafGetVal( cT2HPath + "/idePgtoExt/endExt/bairro" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_CIDADE", FTafGetVal( cT2HPath + "/idePgtoExt/endExt/nmCid" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_CEP",    FTafGetVal( cT2HPath + "/idePgtoExt/endExt/codPostal" , "C", .F., @aIncons, .F. ) )
					
					nT2I := 1
					cT2IPath := cT2HPath + "/basesIrrf[" + AllTrim(Str(nT2I)) + "]"

					While oDados:XPathHasNode(cT2IPath)

						oModel:GetModel( "MODEL_T2I" ):lValid:= .T.

						If nT2I > 1
							oModel:GetModel( "MODEL_T2I" ):AddLine()
						EndIf

						cTpValor  := FTafGetVal(cT2IPath + "/tpValor", "C", .F.,, .F. )

						If Len(cTpValor) < 2
							cTpValor := '0' + cTpValor
						EndIf

						cIdTpValor :=	Posicione("C8U", 2, xFilial("C8U") + cTpValor ,"C8U_ID")

						oModel:LoadValue( "MODEL_T2I", "T2I_CTPVAL", cIdTpValor)
						oModel:LoadValue( "MODEL_T2I", "T2I_VLIRRF", FTafGetVal( cT2IPath + "/valor" , "N", .F., @aIncons, .F. ) )

						nT2I++
						cT2IPath := cT2HPath + "/basesIrrf[" + AllTrim(Str(nT2I)) + "]"
					EndDo

					nT2J := 1
					cT2JPath := cT2HPath + "/irrf[" + AllTrim(Str(nT2J)) + "]"

					While oDados:XPathHasNode(cT2JPath)

						oModel:GetModel( "MODEL_T2J" ):lValid:= .T.

						If nT2J > 1
							oModel:GetModel( "MODEL_T2J" ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_T2J", "T2J_CTPCR", "999999" )
						oModel:LoadValue( "MODEL_T2J", "T2J_CODREC", FTafGetVal( cT2JPath + "/tpCR", "C", .F., @aIncons , .F. ) )
						oModel:LoadValue( "MODEL_T2J", "T2J_VLDESC", FTafGetVal( cT2JPath + "/vrIrrfDesc" , "N", .F., @aIncons, .F. ) )

						nT2J++
						cT2JPath := cT2HPath + "/irrf[" + AllTrim(Str(nT2J)) + "]"
					EndDo

					nT2H++
					cT2HPath := cCabec + "infoIrrf[" + AllTrim(Str(nT2H)) + "]"
				EndDo

			Else

				nV6J := 1
				cV6JPath := cCabec + "ideTrabalhador/dmDev[" + AllTrim(Str(nV6J)) + "]"
				
				While oDados:XPathHasNode(cV6JPath)

					oModel:GetModel( "MODEL_V6J" ):lValid := .T.

					If nV6J > 1
						oModel:GetModel( "MODEL_V6J" ):AddLine()
					EndIf
					
					oModel:LoadValue( "MODEL_V6J", "V6J_SEQUEN", STRZERO( nV6J, 3 ) )

					cPerRef := FTafGetVal( cV6JPath + "/perRef", "C", .F.,, .F. )

					If At("-", cPerRef) > 0
						oModel:LoadValue( "MODEL_V6J", "V6J_PERREF", StrTran(cPerRef, "-", "" ) )
					Else
						oModel:LoadValue( "MODEL_V6J", "V6J_PERREF", cPerRef, "-", "" ) 
					EndIf
					
					oModel:LoadValue( "MODEL_V6J", "V6J_INDDEV", FTafGetVal( cV6JPath + "/ideDmDev" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_V6J", "V6J_TPPAG" , FTafGetVal( cV6JPath + "/tpPgto"	, "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_V6J", "V6J_DTPAG" , FTafGetVal( cV6JPath + "/dtPgto" 	, "D", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_V6J", "V6J_CODCAT", FGetIdInt( "codCateg", "", cV6JPath + "/codCateg",,,, @cInconMsg, @nSeqErrGrv ) )

					nT2I 		:= 1
					cT2IPath	:= cV6JPath + "/infoIR[" + AllTrim(Str(nT2I)) + "]"

					While oDados:XPathHasNode(cT2IPath)

						oModel:GetModel( "MODEL_T2I" ):lValid := .T.

						If nT2I > 1

							oModel:GetModel( "MODEL_T2I" ):AddLine()

						EndIf

						cTpValor  := FTafGetVal(cT2IPath + "/tpInfoIR", "C", .F.,, .F. )

						If Len(cTpValor) < 2
							cTpValor := '0' + cTpValor
						EndIf

						cIdTpValor :=	Posicione("C8U", 2, xFilial("C8U") + cTpValor ,"C8U_ID")

						oModel:LoadValue( "MODEL_T2I", "T2I_CTPVAL", cIdTpValor)
						oModel:LoadValue( "MODEL_T2I", "T2I_VLIRRF", FTafGetVal( cT2IPath + "/valor" , "N", .F., @aIncons, .F. ) )

						nT2I++
						cT2IPath := cV6JPath + "/infoIR[" + AllTrim(Str(nT2I)) + "]"

					EndDo

					If TafColumnPos("V7M_CRMEN")
					
						nV7M 		:= 1
						cV7MPath	:= cV6JPath + "/totApurMen[" + AllTrim(Str(nV7M)) + "]"

						While oDados:XPathHasNode(cV7MPath)

							oModel:GetModel( "MODEL_V7M" ):lValid := .T.

							If nV7M > 1

								oModel:GetModel( "MODEL_V7M" ):AddLine()

							EndIf

							oModel:LoadValue( "MODEL_V7M", "V7M_CRMEN",  FTafGetVal( cV7MPath + "/CRMen" , "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V7M", "V7M_VLSUSP", FTafGetVal( cV7MPath + "/vlrCRMen" , "N", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V7M", "V7M_VLMEN",  FTafGetVal( cV7MPath + "/vlrCRMenSusp" , "N", .F., @aIncons, .F. ) )
							
							nV7M++

							cV7MPath := cV6JPath + "/totApurMen[" + AllTrim(Str(nV7M)) + "]"

						EndDo

						nV7N 		:= 1
						cV7NPath	:= cV6JPath + "/totApurDia[" + AllTrim(Str(nV7N)) + "]"

						While oDados:XPathHasNode(cV7NPath)

							oModel:GetModel( "MODEL_V7N" ):lValid := .T.

							If nV7N > 1

								oModel:GetModel( "MODEL_V7N" ):AddLine()

							EndIf

							oModel:LoadValue( "MODEL_V7N", "V7N_PERDIA", FTafGetVal( cV7NPath + "/perApurDia" , "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V7N", "V7N_CRDIA", FTafGetVal( cV7NPath + "/CRDia" , "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V7N", "V7N_VLCRD", FTafGetVal( cV7NPath + "/vlrCRDia" , "N", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V7N", "V7N_VLSUS", FTafGetVal( cV7NPath + "/vlrCRDiaSusp" , "N", .F., @aIncons, .F. ) )
							
							nV7N++
							cV7NPath := cV6JPath + "/totApurDia[" + AllTrim(Str(nV7N)) + "]"

						EndDo
					EndIf

					nV6J++
					cV6JPath 	:= cCabec + "ideTrabalhador/dmDev[" + AllTrim(Str(nV6J)) + "]"

				EndDo

			EndIf

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

		Endif

	End Transaction

	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

	oModel := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF422Rul

Regras para gravacao dos Imposto de Renda Retido na Fonte S-5002 do E-Social

@Param

@Return
aRull - Regras para a gravacao das informacoes

@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF422Rul()

	Local aRull		:= {}
	Local cCabec	:= "/eSocial/evtIrrfBenef/"
	Local cPeriodo	:= FTafGetVal(  cCabec + "ideEvento/perApur", "C", .F.,, .F. )

	aAdd( aRull, {"T2G_RECBAS", FTafGetVal(cCabec + "ideEvento/nrRecArqBase"	, "C", .F.,, .F. ) 		, "C", .T.} )

	If At("-", cPeriodo) > 0
		aAdd( aRull, {"T2G_PERAPU",  StrTran(cPeriodo, "-", "" ), "C", .T.} )
	Else
		aAdd( aRull, {"T2G_PERAPU",  cPeriodo						, "C", .T.} )
	EndIf

	If !lLaySimplif
		aAdd( aRull, {"T2G_CPFTRA",  FTafGetVal(cCabec + "ideTrabalhador/cpfTrab"			, "C", .F.,, .F. ), "C", .T. } )
		aAdd( aRull, {"T2G_VRDEDD",  FTafGetVal(cCabec + "infoDep/vrDedDep"					, "N", .F.,, .F. ), "N", .T. } )
	Else
		aAdd( aRull, {"T2G_CPFBEN",  FTafGetVal(cCabec + "ideTrabalhador/cpfBenef"			, "C", .F.,, .F. ), "C", .T. } )
	EndIf

Return aRull

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF422Xml
Funcao de geracao do XML para atender o registro S-5002
Quando a rotina for chamada o registro deve estar posicionado

@Param:

@Return:
cXml - Estrutura do Xml do Layout S-5002

@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF422Xml(cAlias as Character, nRecno as Numeric, nOpc as Numeric, lJob as Logical)

	Local cXml        as Character
	Local cLayout     as Character
	Local cReg        as Character
	Local cPerRef     as Character
	Local cXmlendExt  as Character
	Local cXmlidePais as Character
	Local cXmlidePgE  as Character
	Local cFilBkp     as Character
	Local lXmlVLd     as Logical
	Local lTroca      as Logical
	Local aMensal     as Array

	Default cAlias    := "T2G"

	cXml        := ""
	cLayout     := "5002"
	cReg        := "IrrfBenef"
	aMensal     := {}
	cPerRef     := ""
	cXmlendExt  := ""
	cXmlidePais := ""
	cXmlidePgE  := ""
	lXmlVLd     := IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF422XML' ),.T.)
	lTroca      := .F.
	cFilBkp     := cFilAnt

	cFilAnt := T2G->T2G_FILIAL

	lTroca := VldLayReg(.F., T2G->T2G_CPFTRA, 'TAFA422', @lLaySimplif)

	If lXmlVLd
		
		AADD(aMensal,T2G->T2G_RECBAS)

		If Len(Alltrim(T2G->T2G_PERAPU)) <= 4
			AADD(aMensal,T2G->T2G_PERAPU)
		Else
			AADD(aMensal,substr(T2G->T2G_PERAPU, 1, 4) + '-' + substr(T2G->T2G_PERAPU, 5, 2) )
		EndIf

		cXml +=	"<ideTrabalhador>"

		If !lLaySimplif
			cXml +=		xTafTag("cpfTrab",T2G->T2G_CPFTRA)
		Else
			
			DBSelectArea("V6J")
			V6J->( DbSetOrder( 1 ) )
			V6J->( DbGoTop() )

			DBSelectArea("T2I")
			T2I->( DbSetOrder( 2 ) )
			T2I->( DbGoTop() )

			cXml += xTafTag("cpfBenef",T2G->T2G_CPFBEN)

			If V6J->( MsSeek( xFilial("V6J")+T2G->(T2G_ID+T2G_VERSAO) ) )

				While !V6J->(Eof()) .AND. AllTrim(V6J->(V6J_ID+V6J_VERSAO)) == AllTrim(T2G->(T2G_ID+T2G_VERSAO))

					cXml +=	"<dmDev>"

					If Len(Alltrim(V6J->V6J_PERREF)) <= 4
						cPerRef := V6J->V6J_PERREF
					Else
						cPerRef := SubStr(V6J->V6J_PERREF, 1, 4) + '-' + SubStr(V6J->V6J_PERREF, 5, 2)
					EndIf
					
					cXml +=		xTafTag("perRef"	,cPerRef)
					cXml +=		xTafTag("ideDmDev"	,V6J->V6J_INDDEV)
					cXml +=		xTafTag("tpPgto"	,V6J->V6J_TPPAG	)
					cXml +=		xTafTag("dtPgto"	,V6J->V6J_DTPAG	)
					cXml +=	    xTafTag("codCateg"  ,POSICIONE("C87",1, xFilial("C87")+V6J->V6J_CODCAT,"C87_CODIGO"),, .T.)
			
					If T2I->( MsSeek( xFilial("T2I")+V6J->(V6J_ID+V6J_VERSAO+V6J_SEQUEN+V6J_PERREF+V6J_INDDEV+V6J_TPPAG) ) )
						
						While !T2I->(Eof()) .And. AllTrim(T2I->(T2I_ID+T2I_VERSAO+T2I_SEQUEN+T2I_PERREF+T2I_INDDEV+T2I_TPPAG)) == AllTrim(V6J->(V6J_ID+V6J_VERSAO+V6J_SEQUEN+V6J_PERREF+V6J_INDDEV+V6J_TPPAG))

							cXml +=	"<infoIR>"
							cXml +=		xTafTag("tpInfoIR",POSICIONE("C8U",1, xFilial("C8U")+T2I->T2I_CTPVAL,"C8U_CODIGO"))
							cXml +=		xTafTag("valor",T2I->T2I_VLIRRF,PesqPict("T2I","T2I_VLIRRF"),,, .T.)
							cXml +=	"</infoIR>"

							T2I->(DbSkip())

						EndDo

					EndIf

					If TafColumnPos("V7M_CRMEN")

						DBSelectArea("V7M")
						V7M->( DbSetOrder( 1 ) )
						V7M->( DbGoTop() )

						If V7M->( MsSeek( xFilial("V7M")+V6J->(V6J_ID+V6J_VERSAO+V6J_SEQUEN+V6J_PERREF+V6J_INDDEV+V6J_TPPAG) ) )
							
							While !V7M->(Eof()) .And. AllTrim(V7M->(V7M_ID+V7M_VERSAO+V7M_SEQUEN+V7M_PERREF+V7M_INDDEV+V7M_TPPAG)) == AllTrim(V6J->(V6J_ID+V6J_VERSAO+V6J_SEQUEN+V6J_PERREF+V6J_INDDEV+V6J_TPPAG))

								cXml +=	"<totApurMen>"
									cXml +=		xTafTag("CRMen"	,V7M->V7M_CRMEN )
									cXml +=		xTafTag("vlrCRMen" ,V7M->V7M_VLMEN )
									cXml +=		xTafTag("vlrCRMenSusp"	,V7M->V7M_VLSUSP )
								cXml +=	"</totApurMen>"

								V7M->(DbSkip())
							EndDo

						EndIf

						DBSelectArea("V7N")
						V7N->( DbSetOrder( 1 ) )
						V7N->( DbGoTop() )

						If V7N->( MsSeek( xFilial("V7N")+V6J->(V6J_ID+V6J_VERSAO+V6J_SEQUEN+V6J_PERREF+V6J_INDDEV+V6J_TPPAG) ) )
							
							While !V7N->(Eof()) .And. AllTrim(V7N->(V7N_ID+V7N_VERSAO+V7N_SEQUEN+V7N_PERREF+V7N_INDDEV+V7N_TPPAG)) == AllTrim(V6J->(V6J_ID+V6J_VERSAO+V6J_SEQUEN+V6J_PERREF+V6J_INDDEV+V6J_TPPAG))

								cXml +=	"<totApurDia>"
									cXml +=		xTafTag("perApurDia"	,V7N->V7N_PERDIA )
									cXml +=		xTafTag("CRDia" ,V7N->V7N_CRDIA )
									cXml +=		xTafTag("vlrCRDia"	,V7N->V7N_VLCRD )
									CxML +=     xTafTag("vlrCRDiaSusp"	,V7N->V7N_VLSUS )
								cXml +=	"</totApurDia>"

								V7N->(DbSkip())
							EndDo

						EndIf
					EndIf

					cXml +=	"</dmDev>"

					V6J->(DbSkip())

				EndDo

			EndIf

			V6J->(DbCloseArea())
			T2I->(DbCloseArea())

		EndIf

		cXml +=	"</ideTrabalhador>"

		// Tratamento para simplificação do e-Social
		If !lLaySimplif

			DBSelectArea("T2H")
			T2H->(DbSetOrder(1))

			DBSelectArea("T2I")
			T2I->( DbSetOrder( 1 ) )

			DBSelectArea("T2J")
			T2J->( DbSetOrder( 1 ) )

			xTafTagGroup("infoDep"	,{	{ "vrDedDep", T2G->T2G_VRDEDD,,.F.} };
										,	@cXml)
		
			If T2H->( MsSeek( xFilial("T2H")+T2G->(T2G_ID+T2G_VERSAO) ) )
				While !T2H->(Eof()) .And. AllTrim(T2H->(T2H_ID+T2H_VERSAO)) == AllTrim(T2G->(T2G_ID+T2G_VERSAO))

					cXml +=	"<infoIrrf>"
					cXml += 		xTafTag("codCateg",POSICIONE("C87",1, xFilial("C87")+T2H->T2H_CODCAT,"C87_CODIGO"),, .T.)
					cXml +=		xTafTag("indResBr",T2H->T2H_INDRES)

					If T2I->( MsSeek( xFilial("T2I")+T2H->(T2H_ID+T2H_VERSAO+T2H_SEQUEN+T2H_CODCAT+T2H_INDRES) ) )
						While !T2I->(Eof()) .And. AllTrim(T2I->(T2I_ID+T2I_VERSAO+T2I_SEQUEN+T2I_CODCAT+T2I_INDRES)) == AllTrim(T2H->(T2H_ID+T2H_VERSAO+T2H_SEQUEN+T2H_CODCAT+T2H_INDRES))

							cXml +=	"<basesIrrf>"
							cXml +=		xTafTag("tpValor",POSICIONE("C8U",1, xFilial("C8U")+T2I->T2I_CTPVAL,"C8U_CODIGO"))
							cXml +=		xTafTag("valor",T2I->T2I_VLIRRF,PesqPict("T2I","T2I_VLIRRF"))
							cXml +=	"</basesIrrf>"

							T2I->(DbSkip())
						EndDo
					EndIf

					If T2J->( MsSeek( xFilial("T2J")+T2H->(T2H_ID+T2H_VERSAO+T2H_SEQUEN+T2H_CODCAT+T2H_INDRES) ) )
						While !T2J->(Eof()) .And. AllTrim(T2J->(T2J_ID+T2J_VERSAO+T2J_SEQUEN+T2J_CODCAT+T2J_INDRES)) == AllTrim(T2H->(T2H_ID+T2H_VERSAO+T2H_SEQUEN+T2H_CODCAT+T2H_INDRES))

							cXml += "<irrf>"

							if TAFColumnPos("T2J_CODREC")
								cXml += xTafTag("tpCR", T2J->T2J_CODREC)
							else
								cXml += xTafTag("tpCR",POSICIONE("C6R",3, xFilial("C6R")+T2J->T2J_CTPCR ,"C6R_CODIGO"))
							endif

							cXml += xTafTag("vrIrrfDesc",T2J->T2J_VLDESC, PesqPict("T2J","T2J_VLDESC"))
							cXml += "</irrf>"

							T2J->(DbSkip())
						EndDo
					EndIf

					xTafTagGroup("endExt"	,{	{ "dscLograd", T2H->T2H_DLOUGR,,.F.};
												, 	{ "nrLograd",	 T2H->T2H_NUMLOG,,.T.};
												, 	{ "complem",	 T2H->T2H_COMPLE,,.T.};
												, 	{ "bairro", 	 T2H->T2H_BAIRRO,,.T.};
												, 	{ "nmCid", 	 T2H->T2H_CIDADE,,.F.};
												, 	{ "codPostal", T2H->T2H_CEP   ,,.T.}};
												,	@cXmlendExt )

				xTafTagGroup("idePais"	,{	{ "codPais", 	 Posicione("C08",3,xFilial("C08")+T2H->T2H_IDPAIS,"C08_PAISSX"),,.F.};
											,	{ "indNIF", 	 T2H->T2H_INDNIF,,.F.};
											,	{ "nifBenef",	 T2H->T2H_NIFBEN,,.T.}};
												,	@cXmlidePais )

				cXmlidePgE := cXmlidePais + cXmlendExt

					If !Empty(cXmlidePais)
						cXml += "<idePgtoExt>"
						cXml += cXmlidePgE
						cXml += "</idePgtoExt>"
					EndIf

					cXmlidePgE		:= ""
					cXmlendExt		:= ""
					cXmlidePais	:= ""

				cXml +=	"</infoIrrf>"

					T2H->(DbSkip())
				EndDo
			EndIf

			T2J->(DbCloseArea())
			T2I->(DbCloseArea())
			T2H->(DbCloseArea())

		EndIf
		
		cXml := xTafCabXml(cXml,"T2G",cLayout,cReg,aMensal,,,lLaySimplif)

		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf
	EndIf

	If lTroca
		lLaySimplif := !lLaySimplif
	EndIf

	If !( Empty( cFilBkp ) )
		cFilAnt := cFilBkp
	EndIf

Return(cXml) 

//--------------------------------------------------------------------
/*/{Protheus.doc} SetCssButton

Cria objeto TButton utilizando CSS

@author Eduardo Sukeda
@since 09/04/2019
@version 1.0

@param cTamFonte - Tamanho da Fonte
@param cFontColor - Cor da Fonte
@param cBackColor - Cor de Fundo do Botão
@param cBorderColor - Cor da Borda

@return cCss
/*/
//--------------------------------------------------------------------
Static Function SetCssButton(cTamFonte,cFontColor,cBackColor,cBorderColor)

	Local cCSS := ""

	cCSS := "QPushButton{ background-color: " + cBackColor + "; "
	cCSS += "border: none; "
	cCSS += "font: bold; "
	cCSS += "color: " + cFontColor + ";" 
	cCSS += "padding: 2px 5px;" 
	cCSS += "text-align: center; "
	cCSS += "text-decoration: none; "
	cCSS += "display: inline-block; "
	cCSS += "font-size: " + cTamFonte + "px; "
	cCSS += "border: 1px solid " + cBorderColor + "; "
	cCSS += "border-radius: 3px "
	cCSS += "}"

Return cCSS

//---------------------------------------------------------------------
/*/{Protheus.doc} PreXmlLote
Função que chama a TAFXmlLote e limpa slRubERPPad

@author brunno.costa
@since 01/10/2018
@version 1.0
/*/
//---------------------------------------------------------------------

Static Function PreXmlLote()

    TAFXmlLote( 'T2G', 'S-5002' , 'evtIrrfBenef' , 'TAF422Xml', ,oBrw )
    slRubERPPad := Nil  //Limpa variável no final do processo em lote

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} VldLayReg

Valida a versão do layout que está no parâmetro MV_TAFVLES com o 
registro posicionado

@author Bruno de Oliveira
@since 02/05/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Function VldLayReg(lExecV, cValCampo, cTafFonte, lLaySimplif)

	Local cLayParam 	:= SuperGetMV("MV_TAFVLES")
	Local lTroca		:= .F.

	Private lLaySimV 	:= .F.

	If cTafFonte == 'TAFA521'
		If Empty(cValCampo)
			cValCampo := "2.5"
		Else
			cValCampo := ""	
		EndIf
	EndIf

	If cLayParam == "S_01_00_00" 
		If !Empty(cValCampo)
			If MsgYesNo(STR0030 + cLayParam + STR0032, STR0033) //"Versão do registro (02_05_00) diferente da versão do parâmetro MV_TAFVLES ("#"). Deseja continuar com a versão do registro?"#"Atenção"
				lLaySimplif := .F.
				lTroca 		:= .T.
			Else
				lLaySimplif := .T.
			EndIf
		EndIf
	Else
		If Empty(cValCampo)
			If MsgYesNo(STR0031 + cLayParam + STR0032, STR0033) //"Versão do registro (S_01_00_00) diferente da versão do parâmetro MV_TAFVLES ("#"). Deseja continuar com a versão do registro?"#"Atenção"
				lLaySimplif := .T.
				lTroca 		:= .T.
			Else
				lLaySimplif := .F.
			EndIf
		EndIf
	EndIf

	If lExecV
		lLaySimV := lLaySimplif

		FWExecView(STR0034, cTafFonte, 1) //"Visualizar"
		
		If lTroca
			lLaySimplif := !lLaySimplif
		EndIf
	EndIf

Return lTroca
