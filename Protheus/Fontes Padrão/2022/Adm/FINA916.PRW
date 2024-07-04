#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINA916.CH"
#INCLUDE "SHELL.CH"

#DEFINE GRIDMAXLIN 10000

//Definição de variáveis Static
Static __aSelFil	As Array
Static __cCpoSE1	As Character
Static __cCpoFIF	As Character
Static __bVldSE1	As Codeblock
Static __bVldFIF	As Codeblock
Static __lCheck01	As Logical
Static __lCheck02	As Logical
Static __lCheck03	As Logical
Static __nFldPar	As Numeric
Static __oF916ADM	As Object
Static __cAdmFin	As Character
Static __cSM0Lay	As Character
Static __lSOFEX		As Logical
Static __lSmtHTML	As Logical
Static __oDescri	As Object
Static __cFilAnt	As Character
Static __lOracle	As Logical 
Static __lPostGre   As Logical 
Static __cTamNSU	As Character
Static __cTamDOC	As Character
Static __lTodFil    As Logical
Static __nFIFFLD1   As Numeric
Static __nFIFFLD2   As Numeric
Static __nSE1FLD3   As Numeric
Static __nFIFFLD4   As Numeric
Static __nSE1FLD4   As Numeric
Static __nFIFFLD5   As Numeric
Static __lUsaMep    As Logical 
Static __lDocTEF 	As Logical 
Static __nMargem 	As Numeric
Static __nX 		As Numeric
Static __aRetFIF 	As Array
Static __aRetSE1 	As Array
Static __aParcMep 	As Array
Static __nTamNSU 	As Numeric
Static __nTamDOC 	As Numeric
Static cNsuInicial	As Character
Static cNsuFinal	As Character
Static __lParcFIF	As Logical

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA916
Conciliacao de Vendas

@author Guilherme Santos
@since 08/02/2018
@version 12.1.19
/*/
//-------------------------------------------------------------------
Function FINA916()
	Local oBrowse as Object

	//Inicialização de variáveis Static
	__aSelFil	:= {}
	__cCpoSE1	:= "|OK|E1_FILIAL|E1_PREFIXO|E1_NUM|E1_PARCELA|E1_TIPO|E1_NATUREZ|E1_CLIENTE|E1_LOJA|E1_NOMCLI|E1_EMISSAO|E1_VENCTO|E1_VENCREA|E1_VALOR|E1_SALDO|E1_NSUTEF|E1_FILORIG|E1_VLRREAL|CONCILIAR|E1_CARTAUT|E1_DOCTEF| "
	__cCpoFIF	:= "|OK|FIF_FILIAL|FIF_NSUTEF|FIF_PARALF|FIF_CODEST|FIF_DTTEF|FIF_NURESU|FIF_NUCOMP|FIF_NUCART|FIF_VLBRUT|FIF_VLLIQ|FIF_TPPROD|FIF_CODBCO|FIF_CODAGE|FIF_NUMCC|FIF_VLCOM|FIF_TXSERV|FIF_CODAUT|FIF_CODBAN|FIF_STVEND|FIF_TPREG|FIF_PARCEL|FIF_CODLOJ|FIF_DTCRED|FIF_SEQFIF|FIF_CODJUS|FIF_DESJUS|FIF_DESJUT|FIF_CODFIL|FIF_CODADM|FIF_CODMAJ|FIF_CODUSER|FIF_NSUARQ| "

	__bVldSE1	:= {|x| AllTrim(x) $ __cCpoSE1}
	__bVldFIF	:= {|x| AllTrim(x) $ __cCpoFIF}
	__lCheck01	:= .F.
	__lCheck02	:= .F.
	__lCheck03	:= .F.
	__nFldPar	:= 0
	__oF916ADM	:= NIL
	__cAdmFin	:= ""
	__cSM0Lay	:= ALLTRIM(FWSM0Layout())
	__lSOFEX	:= .T.
	__lSmtHTML	:= (GetRemoteType() == 5)
	__cFilAnt	:= cFilAnt
	__lOracle	:= TcGetDb() $ "INFORMIX*ORACLE" 	
	__lPostGre  := tcGetdb() == "POSTGRES"
	__nFIFFLD1  := 0
	__nFIFFLD2  := 0
	__nSE1FLD3  := 0
	__nFIFFLD4  := 0
	__nSE1FLD4  := 0
	__nFIFFLD5  := 0
	__aRetFIF 	:= {}
	__aRetSE1 	:= {}
	__aParcMep 	:= {}
	__nX 		:= 1  

	If __cTamNSU == Nil
		__cTamNSU		:= Alltrim(Str(TamSX3( "FIF_NSUTEF" )[1]))
	Endif

	If __cTamDOC == Nil
		__cTamDOC := Alltrim(Str(TamSX3( "FIF_NUCOMP" )[1]))
	EndIf

	If __lDocTEF == Nil
    	__lDocTEF := SuperGetMv( "MV_BLADOC" , .T. , .F. ) // Verifica se irá processar pelo DOCTEF ou pelo NSUTEF. Padrão é pelo NSUTEF
	Endif

	If __nTamNSU == Nil
		__nTamNSU		:= TamSX3( "FIF_NSUTEF" )[1]
	EndIf

	If __nTamDOC == Nil
		__nTamDOC		:= TamSX3( "FIF_NUCOMP" )[1]
	EndIf

	If __lParcFIF == Nil
		__lParcFIF := SuperGETMV("MV_1DUP", .T., .F.) == "A"
	EndIf
 
	__lUsaMep   := SuperGetMv("MV_USAMEP",.T.,.F.)

	SetKey(019, {||}) //Desabilita CTRL+S para prevenir error.log

	oBrowse := BrowseDef()

	oBrowse:Activate()

	Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} BrowseDef
	Definicoes do Browse

	@author Guilherme Santos
	@since 08/02/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function BrowseDef() As Object
	Local oBrowse As Object

	oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("FIF")

	oBrowse:SetDescription(STR0001)		//"Conciliação Vendas"
	/*
	-------------------------------------------------------------------
	Legendas
	-------------------------------------------------------------------
	*/
	oBrowse:AddLegend("FIF_STVEND $ '1/A'", "GREEN"	, STR0002)		//"Não Processado"
	oBrowse:AddLegend("FIF_STVEND $ '2/B'", "RED"	, STR0003)		//"Conciliado Normal"
	oBrowse:AddLegend("FIF_STVEND $ '3/C'", "GRAY"	, STR0004)		//"Venda Conciliada Parcialmente"
	oBrowse:AddLegend("FIF_STVEND $ '4/D'", "YELLOW", STR0005)		//"Divergente"
	oBrowse:AddLegend("FIF_STVEND $ '5/E'", "BLUE"	, STR0006)		//"Venda Conciliada com Critica"
	oBrowse:AddLegend("FIF_STVEND $ '6/F'", "BROWN"	, STR0007)		//"Titulo sem Registro de Venda"
	oBrowse:AddLegend("FIF_STVEND $ '7/G'", "BLACK"	, STR0008)		//"Registro de Venda sem Titulo"

	// Botões
	oBrowse:AddButton(STR0010, {|| F916View(), oBrowse:Refresh() }) //"Conciliar"
	oBrowse:AddButton(STR0039, {|| F916Desfaz(), oBrowse:Refresh() }) //"Desfazer Conciliação"

	oBrowse:SetFilterDefault(GetFilter(0, "FIF"))

	Return oBrowse

	//-------------------------------------------------------------------
	/*/{Protheus.doc} MenuDef
	Definicoes de Menu

	@author Guilherme Santos
	@since 08/02/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function MenuDef() As Array
	Local aRotina As Array

	aRotina := {}

	ADD OPTION aRotina TITLE STR0009	ACTION "VIEWDEF.FINA916A"	OPERATION MODEL_OPERATION_VIEW   ACCESS 0		//"Visualizar"

	Return aRotina

	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916View
	Acionamento da View

	@author Guilherme Santos
	@since 28/02/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Function F916View()
	Local cTitulo		As Character
	Local cPrograma		As Character
	Local aBtnView		As Array
	Local nRet			As Numeric
	Local oModel		As Object
	Local bCancel		As Codeblock
	Local lContinua     As Logical 
	
	lContinua := .T. 

	If __lUsaMep
		If !MEP->(Fieldpos("MEP_MSFIL")) > 0 
			// "Há campos necessários para execução dessa rotina que não foram localizados na base de dados"
			Help(" ",1,"A916NOFIELDS",,STR0096 ,1,0,,,,,,{STR0097})
			// "Avalie a documentação disponível no TDN para configurar o Conciliador TEF (http://tdn.totvs.com/x/WAE_Cw)"
			lContinua := .F. 
		EndIf 
	Endif 

	If lContinua .and. F916Perg()

		cTitulo		:= STR0001		//"Conciliação Vendas"
		cPrograma	:= "FINA916"
		aBtnView    := {{.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.T., NIL}, {.F., NIL}, {.T., STR0095 }, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}}	//"Fechar"
		nRet        := 0
		oModel      := NIL
		bCancel		:= {|| F916Cancel() }
		__lTodFil   := .F.

		If MV_PAR01 == 1
			//Gestão - Selecao das Filiais
			__aSelFil := AdmGetFil(@__lTodFil, .T.)
		EndIf

		__nMargem := MV_PAR07

		If !__lDocTef
			cNsuInicial  := PADR("", __nTamNSU - len(Alltrim(cNsuInicial)),Iif(!Empty(cNsuInicial),'0',' ')) + Alltrim(cNsuInicial)
			cNsuFinal    := PADR("", __nTamNSU - len(Alltrim(cNsuFinal)),Iif(!Empty(cNsuFinal),'0','Z')) + Alltrim(cNsuFinal)
		Else
			cNsuInicial  := PADR("", __nTamDOC - len(Alltrim(cNsuInicial)),Iif(!Empty(cNsuInicial),'0',' ')) + Alltrim(cNsuInicial)
			cNsuFinal    := PADR("", __nTamDOC - len(Alltrim(cNsuFinal)),Iif(!Empty(cNsuFinal),'0','Z')) + Alltrim(cNsuFinal)
		EndIf

		If MV_PAR01 == 2 .Or. Len(__aSelFil) > 0

			//Processamento por Aba
			If MV_PAR09 == 1
				//Aba para Processamento
				__nFldPar := MV_PAR10
			Else
				__nFldPar := 0
			Endif

			While nRet == 0
				nRet := FWExecView(cTitulo, cPrograma, MODEL_OPERATION_UPDATE, /*oDlg*/, /*bCloseOnOk*/, /*bOk*/, /*nPercReducao*/, aBtnView, {|| F916Fechar() } /*bCancel*/, /*cOperatId*/, /*cToolBar*/, /*oModel*/)
			EndDo

		EndIf

	EndIf

	Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} ModelDef
	Definicao do Modelo de Dados

	@author Guilherme Santos
	@since 09/02/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function ModelDef() As Object
	Local bVldOk	As Codeblock
	Local bLoadTot	As Codeblock
	Local oModel	As Object
	Local oStHead	As Object
	Local oStrFIF01	As Object
	Local oStrSE101	As Object
	Local oStrFIF02	As Object
	Local oStrSE102	As Object
	Local oStrSE103	As Object
	Local oStrFIF04	As Object
	Local oStrSE104	As Object
	Local oStrFIF05	As Object
	Local oStrTot06	As Object
	Local bValid	As Codeblock
	Local bLoadFIF  As Codeblock
	Local bLoadSE1  As Codeblock
	Local cParcFIF  As Character

	oModel 		:= MPFormModel():New("FINA916")
	oStHead		:= StrHead(1)
	oStrTot06	:= StrTot(1)
	bValid		:= FWBuildFeature( STRUCT_FEATURE_VALID	, 'ExistCpo("FVX")'	) //Bloco de código para o valid do campo FVX_CODIGO

	/*
	-------------------------------------------------------------------
	Cabeçalho - Tabela Virtual
	-------------------------------------------------------------------
	*/
	oModel:AddFields("TMPHEADER", NIL, oStHead, NIL, NIL, {|| {"1"}})
	oModel:SetPrimaryKey({"STATUS"})
	oModel:GetModel("TMPHEADER"):SetDescription(STR0001)		//"Conciliação Vendas"
	oModel:SetDescription(STR0001)		//"Conciliação Vendas"
	oModel:GetModel("TMPHEADER"):SetOnlyQuery(.T.)

	If __nFldPar == 0 .OR. __nFldPar == 1
		bVldOk 			:= {|oModGrid| F916Lock(oModGrid)}
		oStrFIF01		:= FWFormStruct(1, "FIF", __bVldFIF)
		oStrSE101		:= FWFormStruct(1, "SE1", __bVldSE1)
		/*
		-------------------------------------------------------------------
		Folder 1 - Conciliados
		-------------------------------------------------------------------
		*/
		//FIF - Registros de Vendas
		If __lUsaMep
			bLoadFIF    := {|oMdl| F916MEP(oMdl,1) }
			oModel:AddGrid("FIFFLD1"  ,"TMPHEADER", oStrFIF01  ,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,bLoadFIF)

			bLoadSE1    := {|oMdlSE1| F916CONC(oMdlSE1,1) }
			oModel:AddGrid("SE1FLD1"  ,"FIFFLD1", oStrSE101  ,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,bLoadSE1)
		else
			oModel:AddGrid("FIFFLD1", "TMPHEADER", oStrFIF01)
		Endif

		oModel:SetRelation("FIFFLD1", {{"FIF_STVEND", "TMPHEADER.STATUS"}}, FIF->(IndexKey(1)))
		oModel:GetModel("FIFFLD1"):SetDescription(STR0011)		//"Conciliados"
		
		If !__lUsaMep
			oModel:GetModel("FIFFLD1"):SetLoadFilter(NIL, GetFilter(1, "FIF"))
		Endif
		oModel:GetModel("FIFFLD1"):SetNoDeleteLine(.T.)
		oModel:GetModel("FIFFLD1"):SetNoInsertLine(.T.)
		oModel:GetModel("FIFFLD1"):SetOptional(.T.)
		oModel:GetModel("FIFFLD1"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("FIFFLD1"):SetMaxLine(GRIDMAXLIN)

		//Insere campo de Selecao do Registro nas Grids
		AddField(1, oStrFIF01, bVldOk,1)

		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 1, oStrFIF01)

		//SE1 - Titulos a Receber
		If !__lUsaMep
			oModel:AddGrid("SE1FLD1", "FIFFLD1", oStrSE101)

			If __lParcFIF
				cParcFIF := "FIFFLD1.FIF_PARALF"
			Else
				cParcFIF := "FIFFLD1.FIF_PARCEL"
			EndIf

			If __lDocTEF
				If __lOracle .Or. __lPostGre
					oModel:SetRelation("SE1FLD1", {{"E1_FILORIG", "FIFFLD1.FIF_CODFIL"}, {"LPAD(TRIM(E1_DOCTEF), "+__cTamDOC+", '0')", "FIFFLD1.FIF_NUCOMP" }, {"E1_PARCELA", cParcFIF}, {"E1_EMISSAO", "FIFFLD1.FIF_DTTEF"}}, SE1->(IndexKey(1)))
				Else
					oModel:SetRelation("SE1FLD1", {{"E1_FILORIG", "FIFFLD1.FIF_CODFIL"}, {"REPLICATE('0', "+__cTamDOC+" - LEN(E1_DOCTEF)) + RTrim(E1_DOCTEF)", "FIFFLD1.FIF_NUCOMP"}, {"E1_PARCELA", cParcFIF}, {"E1_EMISSAO", "FIFFLD1.FIF_DTTEF"}}, SE1->(IndexKey(1)))
				EndIf
			Else
				If __lOracle .Or. __lPostGre
					oModel:SetRelation("SE1FLD1", {{"E1_FILORIG", "FIFFLD1.FIF_CODFIL"}, {"LPAD(TRIM(E1_NSUTEF), "+__cTamNSU+", '0')", "FIFFLD1.XNSUTEF" }, {"E1_PARCELA", cParcFIF}, {"E1_EMISSAO", "FIFFLD1.FIF_DTTEF"}}, SE1->(IndexKey(1)))
				Else
					oModel:SetRelation("SE1FLD1", {{"E1_FILORIG", "FIFFLD1.FIF_CODFIL"}, {"REPLICATE('0', "+__cTamNSU+" - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF)", "FIFFLD1.XNSUTEF"}, {"E1_PARCELA", cParcFIF}, {"E1_EMISSAO", "FIFFLD1.FIF_DTTEF"}}, SE1->(IndexKey(1)))
				EndIf
			EndIf
		EndIf	

		oModel:GetModel("SE1FLD1"):SetDescription(STR0011)		//"Conciliados"
		oModel:GetModel("SE1FLD1"):SetNoDeleteLine(.T.)
		oModel:GetModel("SE1FLD1"):SetNoInsertLine(.T.)
		oModel:GetModel("SE1FLD1"):SetNoUpdateLine(.T.)
		oModel:GetModel("SE1FLD1"):SetOptional(.T.)
		oModel:GetModel("SE1FLD1"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("SE1FLD1"):SetMaxLine(GRIDMAXLIN)

		//Insere campo VlrTEF na grid
		AddField(1, oStrSE101,, 1)

	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 2
		bVldOk 		:= {|oModGrid| F916Lock(oModGrid)}
		oStrFIF02		:= FWFormStruct(1, "FIF", __bVldFIF)
		oStrSE102		:= FWFormStruct(1, "SE1", __bVldSE1)
		/*
		-------------------------------------------------------------------
		Folder 2 - Conciliados Parcialmente
		-------------------------------------------------------------------
		*/
		//FIF - Registros de Vendas
		If __lUsaMep
			bLoadFIF    := {|oMdl| F916MEP(oMdl,2) }
			oModel:AddGrid("FIFFLD2"  ,"TMPHEADER", oStrFIF02  ,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,bLoadFIF)

			bLoadSE1    := {|oMdlSE1| F916CONC(oMdlSE1,2) }
			oModel:AddGrid("SE1FLD2"  ,"FIFFLD2", oStrSE102  ,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,bLoadSE1)
		else
			oModel:AddGrid("FIFFLD2", "TMPHEADER", oStrFIF02)
		Endif

		oModel:SetRelation("FIFFLD2", {{"FIF_STVEND", "TMPHEADER.STATUS"}}, FIF->(IndexKey(1)))
		oModel:GetModel("FIFFLD2"):SetDescription(STR0012)		//"Conciliados Parcialmente"

		If !__lUsaMep
			oModel:GetModel("FIFFLD2"):SetLoadFilter(NIL, GetFilter(2, "FIF"))
		Endif

		oModel:GetModel("FIFFLD2"):SetNoDeleteLine(.T.)
		oModel:GetModel("FIFFLD2"):SetNoInsertLine(.T.)
		oModel:GetModel("FIFFLD2"):SetOptional(.T.)
		oModel:GetModel("FIFFLD2"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("FIFFLD2"):SetMaxLine(GRIDMAXLIN)

		//Insere campo de Selecao do Registro nas Grids
		AddField(1, oStrFIF02, bVldOk,2)

		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 1, oStrFIF02)

		oStrFIF02:SetProperty("FIF_CODJUS", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF02:SetProperty("FIF_DESJUS", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF02:SetProperty("FIF_DESJUT", MODEL_FIELD_WHEN, {|| .T. })

		oStrFIF02:SetProperty("FIF_CODJUS", MODEL_FIELD_VALID,bValid)
		oStrFIF02:AddTrigger("FIF_CODJUS", "FIF_DESJUS", { || .T.},  { |oModel| F916Just(oModel)})

		//SE1 - Titulos a Receber
		If !__lUsaMep
			oModel:AddGrid("SE1FLD2", "FIFFLD2", oStrSE102)

			If __lParcFIF
				cParcFIF := "FIFFLD2.FIF_PARALF"
			Else
				cParcFIF := "FIFFLD2.FIF_PARCEL"
			EndIf

			If __lDocTEF
				If __lOracle .Or. __lPostGre
					oModel:SetRelation("SE1FLD2", {{"E1_FILORIG", "FIFFLD2.FIF_CODFIL"}, {"LPAD(TRIM(E1_DOCTEF), "+__cTamDOC+", '0')", "FIFFLD2.FIF_NUCOMP"}, {"E1_PARCELA", cParcFIF}, {"E1_EMISSAO", "FIFFLD2.FIF_DTTEF"}}, SE1->(IndexKey(1)))
				Else
					oModel:SetRelation("SE1FLD2", {{"E1_FILORIG", "FIFFLD2.FIF_CODFIL"}, {"REPLICATE('0', "+__cTamDOC+" - LEN(E1_DOCTEF)) + RTrim(E1_NSUTEF)", "FIFFLD2.FIF_NUCOMP"} ,{"E1_PARCELA", cParcFIF}, {"E1_EMISSAO", "FIFFLD2.FIF_DTTEF"}}, SE1->(IndexKey(1)))
				EndIf
			Else
				If __lOracle .Or. __lPostGre
					oModel:SetRelation("SE1FLD2", {{"E1_FILORIG", "FIFFLD2.FIF_CODFIL"}, {"LPAD(TRIM(E1_NSUTEF), "+__cTamNSU+", '0')", "FIFFLD2.XNSUTEF"}, {"E1_PARCELA", cParcFIF}, {"E1_EMISSAO", "FIFFLD2.FIF_DTTEF"}}, SE1->(IndexKey(1)))
				Else
					oModel:SetRelation("SE1FLD2", {{"E1_FILORIG", "FIFFLD2.FIF_CODFIL"}, {"REPLICATE('0', "+__cTamNSU+" - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF)", "FIFFLD2.XNSUTEF"}, {"E1_PARCELA", cParcFIF}, {"E1_EMISSAO", "FIFFLD2.FIF_DTTEF"}}, SE1->(IndexKey(1)))
				EndIf
			EndIf
		EndIf

		oModel:GetModel("SE1FLD2"):SetDescription(STR0012) 		//"Conciliados Parcialmente"
		oModel:GetModel("SE1FLD2"):SetNoDeleteLine(.T.)
		oModel:GetModel("SE1FLD2"):SetNoInsertLine(.T.)
		oModel:GetModel("SE1FLD2"):SetNoUpdateLine(.T.)
		oModel:GetModel("SE1FLD2"):SetOptional(.T.)
		oModel:GetModel("SE1FLD2"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("SE1FLD2"):SetMaxLine(GRIDMAXLIN)

		//Insere campo de Selecao do Registro nas Grids
		AddField(1, oStrSE102,, 2)

	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 3
		bVldOk 		:= {|oModGrid| F916VldChk(oModGrid) .And. F916Lock(oModGrid, 2)}
		oStrSE103		:= FWFormStruct(1, "SE1", __bVldSE1)
		/*
		-------------------------------------------------------------------
		Folder 3 - Titulos sem Vendas
		-------------------------------------------------------------------
		*/
		//SE1 - Titulos a Receber
		oModel:AddGrid("SE1FLD3", "TMPHEADER", oStrSE103)
		oModel:SetRelation("SE1FLD3", {{"'1'", "TMPHEADER.STATUS"}}, SE1->(IndexKey(1)))
		oModel:GetModel("SE1FLD3"):SetDescription(STR0013)		//"Titulos sem Vendas"
		oModel:GetModel("SE1FLD3"):SetLoadFilter(NIL, GetFilter(3, "SE1"))
		oModel:GetModel("SE1FLD3"):SetNoDeleteLine(.T.)
		oModel:GetModel("SE1FLD3"):SetNoInsertLine(.T.)
		oModel:GetModel("SE1FLD3"):SetOptional(.T.)
		oModel:GetModel("SE1FLD3"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("SE1FLD3"):SetMaxLine(GRIDMAXLIN)

		//Insere campo de Selecao do Registro nas Grids
		AddField(1, oStrSE103, bVldOk, 3)

		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 1, oStrSE103)

		oStrSE103:SetProperty("FIF_XCODJU", MODEL_FIELD_WHEN, {|| .T. })
		oStrSE103:SetProperty("FIF_XDESJU", MODEL_FIELD_WHEN, {|| .T. })
		oStrSE103:SetProperty("FIF_XDESJT", MODEL_FIELD_WHEN, {|| .T. })

		oStrSE103:SetProperty("FIF_XCODJU", MODEL_FIELD_VALID,bValid)
		oStrSE103:AddTrigger("FIF_XCODJU", "FIF_XDESJU", { || .T.},  { |oModel| F916JustX(oModel)})

	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 4
		oStrFIF04	:= FWFormStruct(1, "FIF", __bVldFIF)
		oStrSE104	:= FWFormStruct(1, "SE1", __bVldSE1)
		/*
		-------------------------------------------------------------------
		Folder 4 - Vendas sem Titulos
		-------------------------------------------------------------------
		*/
		//FIF - Registros de Vendas
		oModel:AddGrid("FIFFLD4", "TMPHEADER", oStrFIF04)
		oModel:SetRelation("FIFFLD4", {{"FIF_STVEND", "TMPHEADER.STATUS"}}, FIF->(IndexKey(1)))
		oModel:GetModel("FIFFLD4"):SetDescription(STR0015)		//"Vendas sem Titulos"
		oModel:GetModel("FIFFLD4"):SetLoadFilter(NIL, GetFilter(4, "FIF"))
		oModel:GetModel("FIFFLD4"):SetNoDeleteLine(.T.)
		oModel:GetModel("FIFFLD4"):SetNoInsertLine(.T.)
		oModel:GetModel("FIFFLD4"):SetOptional(.T.)
		oModel:GetModel("FIFFLD4"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("FIFFLD4"):SetMaxLine(GRIDMAXLIN)

		//Insere campo de Selecao do Registro nas Grids
		bVldOk 	:= {|oModGrid, cCampo, lValue, lOldVal| fVldOk(oModGrid, cCampo, lValue, lOldVal) .And. F916Lock(oModGrid, 1)}
		AddField(1, oStrFIF04, bVldOk)

		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 1, oStrFIF04)

		oStrFIF04:SetProperty("FIF_CODJUS", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF04:SetProperty("FIF_DESJUS", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF04:SetProperty("FIF_DESJUT", MODEL_FIELD_WHEN, {|| .T. })

		oStrFIF04:SetProperty("FIF_CODJUS", MODEL_FIELD_VALID,bValid)
		oStrFIF04:AddTrigger("FIF_CODJUS", "FIF_DESJUS", { || .T.},  { |oModel| F916Just(oModel)})

		//SE1 - Titulos a Receber
		oModel:AddGrid("SE1FLD4", "TMPHEADER", oStrSE104)
		oModel:SetRelation("SE1FLD4", {{"'1'", "TMPHEADER.STATUS"}}, SE1->(IndexKey(1)))
		oModel:GetModel("SE1FLD4"):SetDescription(STR0013)		//"Titulos sem Vendas"
		oModel:GetModel("SE1FLD4"):SetLoadFilter(NIL, GetFilter(4, "SE1"))
		oModel:GetModel("SE1FLD4"):SetNoDeleteLine(.T.)
		oModel:GetModel("SE1FLD4"):SetNoInsertLine(.T.)
		oModel:GetModel("SE1FLD4"):SetOptional(.T.)
		oModel:GetModel("SE1FLD4"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("SE1FLD4"):SetMaxLine(GRIDMAXLIN)

		//Insere campo de Selecao do Registro nas Grids
		bVldOk 	:= {|oModGrid, cCampo, lValue, lOldVal| fVldOk(oModGrid, cCampo, lValue, lOldVal) .And. F916Lock(oModGrid, 2)}
		AddField(1, oStrSE104, bVldOk, 4)

		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 1, oStrSE104)

	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 5
		bVldOk 	:= {|oModGrid| F916Lock(oModGrid)}
		oStrFIF05		:= FWFormStruct(1, "FIF", __bVldFIF)
		/*
		-------------------------------------------------------------------
		Folder 5 - Divergentes
		-------------------------------------------------------------------
		*/
		//FIF - Registros de Vendas
		oModel:AddGrid("FIFFLD5", "TMPHEADER", oStrFIF05)
		oModel:SetRelation("FIFFLD5", {{"FIF_STVEND", "TMPHEADER.STATUS"}}, FIF->(IndexKey(1)))
		oModel:GetModel("FIFFLD5"):SetDescription(STR0014)		//"Divergentes"
		oModel:GetModel("FIFFLD5"):SetLoadFilter(NIL, GetFilter(5, "FIF"))
		oModel:GetModel("FIFFLD5"):SetNoDeleteLine(.T.)
		oModel:GetModel("FIFFLD5"):SetNoInsertLine(.T.)
		oModel:GetModel("FIFFLD5"):SetOptional(.T.)
		oModel:GetModel("FIFFLD5"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("FIFFLD5"):SetMaxLine(GRIDMAXLIN)

		//Insere campo de Selecao do Registro nas Grids
		AddField(1, oStrFIF05, bVldOk)

		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 1, oStrFIF05)

		oStrFIF05:SetProperty("FIF_CODJUS", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF05:SetProperty("FIF_DESJUS", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF05:SetProperty("FIF_DESJUT", MODEL_FIELD_WHEN, {|| .T. })

		oStrFIF05:SetProperty("FIF_CODJUS", MODEL_FIELD_VALID,bValid)
		oStrFIF05:AddTrigger("FIF_CODJUS", "FIF_DESJUS", { || .T.},  { |oModel| F916Just(oModel)})

	EndIf

	/*
	-------------------------------------------------------------------
	Folder 6 - Totais
	-------------------------------------------------------------------
	*/
	bLoadTot := {|oSubMod| fLoadTot(oSubMod)}

	oModel:AddGrid("TOTFLD6", "TMPHEADER", oStrTot06, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, bLoadTot)
	oModel:SetRelation("TOTFLD6", {{"'1'", "TMPHEADER.STATUS"}}, "DTOS(DTAVEND)")
	oModel:GetModel("TOTFLD6"):SetDescription(STR0016)		//"Totais"
	oModel:GetModel("TOTFLD6"):SetOptional(.T.)
	oModel:GetModel("TOTFLD6"):SetNoDeleteLine(.T.)
	oModel:GetModel("TOTFLD6"):SetNoInsertLine(.T.)
	oModel:GetModel("TOTFLD6"):SetNoUpdateLine(.T.)
	oModel:GetModel("TOTFLD6"):SetOnlyQuery(.T.)
	oModel:GetModel("TOTFLD6"):SetUniqueLine({"DTAVEND"})

	// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
	oModel:GetModel("TOTFLD6"):SetMaxLine(GRIDMAXLIN)

	If MV_PAR09 == 1
		If __nFldPar == 1
			oModel:SetActivate( { |oModel| __nFIFFLD1 := F916Cont( oModel,"FIFFLD1" ) } )
		ElseIf __nFldPar == 2
			oModel:SetActivate( { |oModel| __nFIFFLD2 := F916Cont( oModel,"FIFFLD2" ) } )
		ElseIf __nFldPar == 3
			oModel:SetActivate( { |oModel| __nSE1FLD3 := F916Cont( oModel,"SE1FLD3" ) } )
		ElseIf __nFldPar == 4
			oModel:SetActivate( { |oModel| __nFIFFLD4 := F916Cont( oModel,"FIFFLD4" ) , __nSE1FLD4 := F916Cont( oModel,"SE1FLD4" ) } )
		ElseIf __nFldPar == 5
			oModel:SetActivate( { |oModel| __nFIFFLD5 := F916Cont( oModel,"FIFFLD5" ) } )
		EndIf
	Else
		oModel:SetActivate( { |oModel| 	__nFIFFLD1 := F916Cont( oModel,"FIFFLD1" ),;
			__nFIFFLD2 := F916Cont( oModel,"FIFFLD2" ),;
			__nSE1FLD3 := F916Cont( oModel,"SE1FLD3" ),;
			__nFIFFLD4 := F916Cont( oModel,"FIFFLD4" ),;
			__nSE1FLD4 := F916Cont( oModel,"SE1FLD4" ),;
			__nFIFFLD5 := F916Cont( oModel,"FIFFLD5" ) } )
	EndIf

	Return oModel

	//-------------------------------------------------------------------
	/*/{Protheus.doc} ViewDef
	Definicao da View

	@author Guilherme Santos
	@since 09/02/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function ViewDef() As Object
	Local oModel	As Object
	Local oView		As Object
	Local oStHead	As Object
	Local oStrFIF01	As Object
	Local oStrFIF02	As Object
	Local oStrFIF04	As Object
	Local oStrFIF05	As Object
	Local oStrSE101	As Object
	Local oStrSE102	As Object
	Local oStrSE103	As Object
	Local oStrSE104	As Object
	Local oStrTot06	As Object
	Local cDescri	As Character

	oModel		:= FWLoadModel("FINA916")
	oView		:= FWFormView():New()
	oStHead		:= StrHead(2)
	oStrFIF01	:= FWFormStruct(2, "FIF", __bVldFIF)
	oStrFIF02	:= FWFormStruct(2, "FIF", __bVldFIF)
	oStrFIF04	:= FWFormStruct(2, "FIF", __bVldFIF)
	oStrFIF05	:= FWFormStruct(2, "FIF", __bVldFIF)
	oStrSE101	:= FWFormStruct(2, "SE1", __bVldSE1)
	oStrSE102	:= FWFormStruct(2, "SE1", __bVldSE1)
	oStrSE103	:= FWFormStruct(2, "SE1", __bVldSE1)
	oStrSE104	:= FWFormStruct(2, "SE1", __bVldSE1)
	oStrTot06	:= StrTot(2)
	cDescri		:= ""

	__lCheck01 := .F.
	__lCheck02 := .F.
	__lCheck03 := .F.

	oView:SetModel(oModel)

	//Box para as Grids
	oView:CreateHorizontalBox("HBINF01", 100)

	//Folder com as Planinhas
	oView:CreateFolder("FOLGRIDS", "HBINF01")

	If __nFldPar == 0 .OR. __nFldPar == 1
		/*
		-------------------------------------------------------------------
		Sheet 01 - Conciliados
		-------------------------------------------------------------------
		*/
		oView:AddSheet("FOLGRIDS", "SHT01", STR0011,{|| F916VlrTef(oView, 1)})		//"Conciliados"
		oView:CreateHorizontalBox("HB01SHT01", 52, NIL, NIL, "FOLGRIDS", "SHT01")
		oView:CreateHorizontalBox("HB02SHT01",  6, NIL, NIL, "FOLGRIDS", "SHT01")
		oView:CreateHorizontalBox("HB03SHT01", 26, NIL, NIL, "FOLGRIDS", "SHT01")
		oView:CreateHorizontalBox("HB04SHT01", 16, NIL, NIL, "FOLGRIDS", "SHT01")


		//Grid Superior - Conciliados - FIF
		oView:AddGrid("GRD01FIF01", oStrFIF01, "FIFFLD1")
		oView:SetOwnerView("GRD01FIF01", "HB01SHT01")
		oView:SetViewProperty("GRD01FIF01", "GRIDSEEK", {.T.})

		//Insere campo de Selecao do Registro na Grid
		AddField(2, oStrFIF01)

		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 2, oStrFIF01)

		oView:SetViewProperty("GRD01FIF01", "CHANGELINE", {{|| F916VlrTef(oView, 1)}})

		oStrFIF01:RemoveField("FIF_CODJUS")
		oStrFIF01:RemoveField("FIF_DESJUS")
		oStrFIF01:RemoveField("FIF_DESJUT")
		oStrFIF01:RemoveField("FIF_CODMAJ")
		oStrFIF01:RemoveField("FIF_NSUTEF")

		//Trava os Campos
		//		oStrFIF01:SetProperty("FIF_CODJUS", 	MVC_VIEW_CANCHANGE, .F.)
		//		oStrFIF01:SetProperty("FIF_DESJUS", 	MVC_VIEW_CANCHANGE, .F.)

		oStrFIF01:SetProperty('OK'  	   , MVC_VIEW_ORDEM ,'01')
		oStrFIF01:SetProperty('FIF_DTTEF'  , MVC_VIEW_ORDEM ,'02')
		oStrFIF01:SetProperty('FIF_CODFIL' , MVC_VIEW_ORDEM ,'03')
		oStrFIF01:SetProperty('FIF_VLBRUT' , MVC_VIEW_ORDEM ,'04')
		oStrFIF01:SetProperty('FIF_VLLIQ'  , MVC_VIEW_ORDEM ,'05')
		oStrFIF01:SetProperty('FIF_NSUARQ' , MVC_VIEW_ORDEM ,'06')
		oStrFIF01:SetProperty('FIF_CODAUT' , MVC_VIEW_ORDEM ,'07')
		oStrFIF01:SetProperty('FIF_CODLOJ' , MVC_VIEW_ORDEM ,'08')
		oStrFIF01:SetProperty('FIF_CODEST' , MVC_VIEW_ORDEM ,'09')
		oStrFIF01:SetProperty('FIF_DTCRED' , MVC_VIEW_ORDEM ,'10')
		oStrFIF01:SetProperty('FIF_TPREG'  , MVC_VIEW_ORDEM ,'11')
		oStrFIF01:SetProperty('FIF_NURESU' , MVC_VIEW_ORDEM ,'12')
		oStrFIF01:SetProperty('FIF_NUCOMP' , MVC_VIEW_ORDEM ,'13')
		oStrFIF01:SetProperty('FIF_TPPROD' , MVC_VIEW_ORDEM ,'14')
		oStrFIF01:SetProperty('FIF_CODBCO' , MVC_VIEW_ORDEM ,'15')
		oStrFIF01:SetProperty('FIF_CODAGE' , MVC_VIEW_ORDEM ,'16')
		oStrFIF01:SetProperty('FIF_NUMCC'  , MVC_VIEW_ORDEM ,'17')
		oStrFIF01:SetProperty('FIF_VLCOM'  , MVC_VIEW_ORDEM ,'18')
		oStrFIF01:SetProperty('FIF_TXSERV' , MVC_VIEW_ORDEM ,'19')
		oStrFIF01:SetProperty('FIF_NUM'    , MVC_VIEW_ORDEM ,'20')
		oStrFIF01:SetProperty('FIF_PARCEL' , MVC_VIEW_ORDEM ,'21')
		oStrFIF01:SetProperty('FIF_PARALF' , MVC_VIEW_ORDEM ,'22')
		oStrFIF01:SetProperty('FIF_PARC'   , MVC_VIEW_ORDEM ,'23')
		oStrFIF01:SetProperty('FIF_STVEND' , MVC_VIEW_ORDEM ,'24')
		oStrFIF01:SetProperty('FIF_CODBAN' , MVC_VIEW_ORDEM ,'25')
		oStrFIF01:SetProperty('FIF_CODADM' , MVC_VIEW_ORDEM ,'26')
		oStrFIF01:SetProperty('FIF_SEQFIF' , MVC_VIEW_ORDEM ,'27')

		//Check Marcar Todos
		oView:AddOtherObject("chkEf01", {|oPanel| F916Marc(oPanel, 1)})
		oView:SetOwnerView("chkEf01", "HB02SHT01")

		//Grid Inferior - Conciliados Parcialmente - SE1
		oView:AddGrid("GRD01SE101", oStrSE101, "SE1FLD1")
		oView:SetOwnerView("GRD01SE101", "HB03SHT01")
		//		oView:SetViewProperty("GRD01SE101", "ENABLEDGRIDDETAIL", {100})

		oStrSE101:SetNoFolder()

		//Insere campo VlrTEF na grid
		AddField(2, oStrSE101, ,1)

		//Retiro este campo de flag das abas inferiores correspondente a SE1 pois os registros são conciliados.
		oStrSE101:RemoveField('OK')

		oStrSE101:SetProperty('Conciliar'  	, MVC_VIEW_ORDEM ,'01')
		oStrSE101:SetProperty('E1_EMISSAO' 	, MVC_VIEW_ORDEM ,'02')
		oStrSE101:SetProperty('E1_XFILORI' 	, MVC_VIEW_ORDEM ,'03')
		oStrSE101:SetProperty('E1_XVLRREAL' , MVC_VIEW_ORDEM ,'04')
		oStrSE101:SetProperty('E1_VALOR'   	, MVC_VIEW_ORDEM ,'05')
		oStrSE101:SetProperty('E1_XVLRTEF' 	, MVC_VIEW_ORDEM ,'06')
		oStrSE101:SetProperty('E1_XSALDO'  	, MVC_VIEW_ORDEM ,'07')
		oStrSE101:SetProperty('E1_NSUTEF'  	, MVC_VIEW_ORDEM ,'08')
		oStrSE101:SetProperty('E1_XCARTAUT' , MVC_VIEW_ORDEM ,'09')
		oStrSE101:SetProperty('E1_CLIENTE' 	, MVC_VIEW_ORDEM ,'10')
		oStrSE101:SetProperty('E1_LOJA'    	, MVC_VIEW_ORDEM ,'11')
		oStrSE101:SetProperty('E1_NOMCLI'  	, MVC_VIEW_ORDEM ,'12')
		oStrSE101:SetProperty('E1_VENCTO'  	, MVC_VIEW_ORDEM ,'13')
		oStrSE101:SetProperty('E1_VENCREA' 	, MVC_VIEW_ORDEM ,'14')
		oStrSE101:SetProperty('E1_PREFIXO' 	, MVC_VIEW_ORDEM ,'15')
		oStrSE101:SetProperty('E1_NUM'     	, MVC_VIEW_ORDEM ,'16')
		oStrSE101:SetProperty('E1_PARCELA' 	, MVC_VIEW_ORDEM ,'17')
		oStrSE101:SetProperty('E1_TIPO'    	, MVC_VIEW_ORDEM ,'18')
		oStrSE101:SetProperty('E1_NATUREZ' 	, MVC_VIEW_ORDEM ,'19')

		//Botao Efetivar
		oView:AddOtherObject("btnEf01", {|oPanel| F916Botao(oPanel, 1,,__nFIFFLD1 = GRIDMAXLIN )})
		oView:SetOwnerView("btnEf01", "HB04SHT01")
		//Imprimir Browser
		oView:AddOtherObject("btnEf06", {|oPanel| F916Botao(oPanel, 8 ,oView)})
	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 2
		/*
		-------------------------------------------------------------------
		Sheet 02 - Conciliados Parcialmente
		-------------------------------------------------------------------
		*/
		oView:AddSheet("FOLGRIDS", "SHT02", STR0012,{|| F916VlrTef(oView, 2)})		//"Conciliados Parcialmente"
		oView:CreateHorizontalBox("HB01SHT02", 52, NIL, NIL, "FOLGRIDS", "SHT02")
		oView:CreateHorizontalBox("HB04SHT02",  6, NIL, NIL, "FOLGRIDS", "SHT02")
		oView:CreateHorizontalBox("HB02SHT02", 26, NIL, NIL, "FOLGRIDS", "SHT02")
		oView:CreateHorizontalBox("HB03SHT02", 16, NIL, NIL, "FOLGRIDS", "SHT02")


		//Grid Superior - Conciliados Parcialmente - FIF
		oView:AddGrid("GRD01FIF02", oStrFIF02, "FIFFLD2")
		oView:SetOwnerView("GRD01FIF02", "HB01SHT02")
		oView:SetViewProperty("GRD01FIF02", "GRIDSEEK", {.T.})

		//Insere campo de Selecao do Registro na Grid
		AddField(2, oStrFIF02)

		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 2, oStrFIF02)

		oView:SetViewProperty("GRD01FIF02", "CHANGELINE", {{|| F916VlrTef(oView, 2)}})

		oStrFIF02:RemoveField("FIF_CODMAJ")
		oStrFIF02:RemoveField("FIF_NSUTEF")

		oStrFIF02:SetProperty("FIF_CODJUS", 	MVC_VIEW_CANCHANGE, .T.)
		oStrFIF02:SetProperty("FIF_DESJUS", 	MVC_VIEW_CANCHANGE, .F.)
		oStrFIF02:SetProperty("FIF_DESJUT", 	MVC_VIEW_CANCHANGE, .T.)

		oStrFIF02:SetProperty('OK'  	   , MVC_VIEW_ORDEM ,'01')
		oStrFIF02:SetProperty('FIF_DTTEF'  , MVC_VIEW_ORDEM ,'02')
		oStrFIF02:SetProperty('FIF_CODFIL' , MVC_VIEW_ORDEM ,'03')
		oStrFIF02:SetProperty('FIF_VLBRUT' , MVC_VIEW_ORDEM ,'04')
		oStrFIF02:SetProperty('FIF_VLLIQ'  , MVC_VIEW_ORDEM ,'05')
		oStrFIF02:SetProperty('FIF_NSUARQ' , MVC_VIEW_ORDEM ,'06')
		oStrFIF02:SetProperty('FIF_CODAUT' , MVC_VIEW_ORDEM ,'07')
		oStrFIF02:SetProperty('FIF_CODLOJ' , MVC_VIEW_ORDEM ,'08')
		oStrFIF02:SetProperty('FIF_CODEST' , MVC_VIEW_ORDEM ,'09')
		oStrFIF02:SetProperty('FIF_DTCRED' , MVC_VIEW_ORDEM ,'10')
		oStrFIF02:SetProperty('FIF_TPREG'  , MVC_VIEW_ORDEM ,'11')
		oStrFIF02:SetProperty('FIF_NURESU' , MVC_VIEW_ORDEM ,'12')
		oStrFIF02:SetProperty('FIF_NUCOMP' , MVC_VIEW_ORDEM ,'13')
		oStrFIF02:SetProperty('FIF_TPPROD' , MVC_VIEW_ORDEM ,'14')
		oStrFIF02:SetProperty('FIF_CODBCO' , MVC_VIEW_ORDEM ,'15')
		oStrFIF02:SetProperty('FIF_CODAGE' , MVC_VIEW_ORDEM ,'16')
		oStrFIF02:SetProperty('FIF_NUMCC'  , MVC_VIEW_ORDEM ,'17')
		oStrFIF02:SetProperty('FIF_VLCOM'  , MVC_VIEW_ORDEM ,'18')
		oStrFIF02:SetProperty('FIF_TXSERV' , MVC_VIEW_ORDEM ,'19')
		oStrFIF02:SetProperty('FIF_NUM'    , MVC_VIEW_ORDEM ,'20')
		oStrFIF02:SetProperty('FIF_PARCEL' , MVC_VIEW_ORDEM ,'21')
		oStrFIF02:SetProperty('FIF_PARALF' , MVC_VIEW_ORDEM ,'22')
		oStrFIF02:SetProperty('FIF_PARC'   , MVC_VIEW_ORDEM ,'23')
		oStrFIF02:SetProperty('FIF_STVEND' , MVC_VIEW_ORDEM ,'24')
		oStrFIF02:SetProperty('FIF_CODBAN' , MVC_VIEW_ORDEM ,'25')
		oStrFIF02:SetProperty('FIF_CODADM' , MVC_VIEW_ORDEM ,'26')
		oStrFIF02:SetProperty('FIF_SEQFIF' , MVC_VIEW_ORDEM ,'27')

		//Check Marcar Todos
		oView:AddOtherObject("chkEf02", {|oPanel| F916Marc(oPanel, 2)})
		oView:SetOwnerView("chkEf02", "HB04SHT02")

		//Grid Inferior - Conciliados Parcialmente - SE1
		oView:AddGrid("GRD02SE102", oStrSE102, "SE1FLD2")
		oView:SetOwnerView("GRD02SE102", "HB02SHT02")

		//Insere campo de Selecao do Registro na Grid
		AddField(2, oStrSE102, ,2)

		//Retiro este campo de flag das abas inferiores correspondente a SE1 pois os registros são conciliados.
		oStrSE102:RemoveField('OK')

		oStrSE102:SetProperty('Conciliar' 	, MVC_VIEW_ORDEM ,'01')
		oStrSE102:SetProperty('E1_EMISSAO' 	, MVC_VIEW_ORDEM ,'02')
		oStrSE102:SetProperty('E1_XFILORI' 	, MVC_VIEW_ORDEM ,'03')
		oStrSE102:SetProperty('E1_XVLRREAL' , MVC_VIEW_ORDEM ,'04')
		oStrSE102:SetProperty('E1_VALOR'   	, MVC_VIEW_ORDEM ,'05')
		oStrSE102:SetProperty('E1_XVLRTEF' 	, MVC_VIEW_ORDEM ,'06')
		oStrSE102:SetProperty('E1_XSALDO'  	, MVC_VIEW_ORDEM ,'07')
		oStrSE102:SetProperty('E1_NSUTEF'  	, MVC_VIEW_ORDEM ,'08')
		oStrSE102:SetProperty('E1_XCARTAUT' , MVC_VIEW_ORDEM ,'09')
		oStrSE102:SetProperty('E1_CLIENTE' 	, MVC_VIEW_ORDEM ,'10')
		oStrSE102:SetProperty('E1_LOJA'    	, MVC_VIEW_ORDEM ,'11')
		oStrSE102:SetProperty('E1_NOMCLI'  	, MVC_VIEW_ORDEM ,'12')
		oStrSE102:SetProperty('E1_VENCTO'  	, MVC_VIEW_ORDEM ,'13')
		oStrSE102:SetProperty('E1_VENCREA' 	, MVC_VIEW_ORDEM ,'14')
		oStrSE102:SetProperty('E1_PREFIXO' 	, MVC_VIEW_ORDEM ,'15')
		oStrSE102:SetProperty('E1_NUM'     	, MVC_VIEW_ORDEM ,'16')
		oStrSE102:SetProperty('E1_PARCELA' 	, MVC_VIEW_ORDEM ,'17')
		oStrSE102:SetProperty('E1_TIPO'    	, MVC_VIEW_ORDEM ,'18')
		oStrSE102:SetProperty('E1_NATUREZ' 	, MVC_VIEW_ORDEM ,'19')

		//Botao Efetivar
		oView:AddOtherObject("btnEf02", {|oPanel| F916Botao(oPanel, 2,,__nFIFFLD2 = GRIDMAXLIN )})
		oView:SetOwnerView("btnEf02", "HB03SHT02")
		//Imprimir Browser
		oView:AddOtherObject("btnEf06", {|oPanel| F916Botao(oPanel, 8 ,oView)})

	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 3
		/*
		-------------------------------------------------------------------
		Sheet 03 - Titulos sem Vendas
		-------------------------------------------------------------------
		*/
		oStrSE103:RemoveField("FIF_DTCRED")

		oView:AddSheet("FOLGRIDS", "SHT03", STR0013)		//"Titulos sem Vendas"
		oView:CreateHorizontalBox("HB01SHT03", 84, NIL, NIL, "FOLGRIDS", "SHT03")
		oView:CreateHorizontalBox("HB02SHT03", 16, NIL, NIL, "FOLGRIDS", "SHT03")

		//Grid - Titulos sem Vendas - SE1
		oView:AddGrid("GRD01SE103", oStrSE103, "SE1FLD3")
		oView:SetOwnerView("GRD01SE103", "HB01SHT03")
		oView:SetViewProperty("GRD01SE103", "GRIDSEEK", {.T.})

		//Insere campo de Selecao do Registro nas Grids
		AddField(2, oStrSE103, , 3)

		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 2, oStrSE103)

		oStrSE103:SetProperty('OK'  	  	, MVC_VIEW_ORDEM ,'01')
		oStrSE103:SetProperty('E1_EMISSAO' 	, MVC_VIEW_ORDEM ,'02')
		oStrSE103:SetProperty('E1_XFILORI' 	, MVC_VIEW_ORDEM ,'03')
		oStrSE103:SetProperty('E1_XVLRREAL' , MVC_VIEW_ORDEM ,'04')
		oStrSE103:SetProperty('E1_VALOR'   	, MVC_VIEW_ORDEM ,'05')
		oStrSE103:SetProperty('E1_XSALDO'  	, MVC_VIEW_ORDEM ,'06')
		oStrSE103:SetProperty('E1_NSUTEF'  	, MVC_VIEW_ORDEM ,'07')
		oStrSE103:SetProperty('E1_XCARTAUT' , MVC_VIEW_ORDEM ,'08')
		oStrSE103:SetProperty('E1_CLIENTE' 	, MVC_VIEW_ORDEM ,'09')
		oStrSE103:SetProperty('E1_LOJA'    	, MVC_VIEW_ORDEM ,'10')
		oStrSE103:SetProperty('E1_NOMCLI'  	, MVC_VIEW_ORDEM ,'11')
		oStrSE103:SetProperty('E1_VENCTO'  	, MVC_VIEW_ORDEM ,'12')
		oStrSE103:SetProperty('E1_VENCREA' 	, MVC_VIEW_ORDEM ,'13')
		oStrSE103:SetProperty('E1_PREFIXO' 	, MVC_VIEW_ORDEM ,'14')
		oStrSE103:SetProperty('E1_NUM'     	, MVC_VIEW_ORDEM ,'15')
		oStrSE103:SetProperty('E1_PARCELA' 	, MVC_VIEW_ORDEM ,'16')
		oStrSE103:SetProperty('E1_TIPO'    	, MVC_VIEW_ORDEM ,'17')
		oStrSE103:SetProperty('E1_NATUREZ' 	, MVC_VIEW_ORDEM ,'18')
		oStrSE103:SetProperty('E1_XVALLIQ' 	, MVC_VIEW_ORDEM ,'19')

		//Botao Efetivar
		oView:AddOtherObject("btnEf03", {|oPanel| F916Botao(oPanel, 3,,__nSE1FLD3 = GRIDMAXLIN )})
		oView:SetOwnerView("btnEf03", "HB02SHT03")

		//Check Marcar Todos
		oView:AddOtherObject("chkEf03", {|oPanel| F916Marc(oPanel, 3)})
		oView:SetOwnerView("chkEf03", "HB02SHT03")

		//Imprimir Browser
		oView:AddOtherObject("btnEf06", {|oPanel| F916Botao(oPanel, 8 ,oView)})

		oStrSE103:SetProperty("FIF_XCODJU", 	MVC_VIEW_CANCHANGE, .T.)
		oStrSE103:SetProperty("FIF_XDESJU", 	MVC_VIEW_CANCHANGE, .F.)
		oStrSE103:SetProperty("FIF_XDESJT", 	MVC_VIEW_CANCHANGE, .T.)

	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 4
		/*
		-------------------------------------------------------------------
		Sheet 04 - Vendas sem Titulos
		-------------------------------------------------------------------
		*/
		oView:AddSheet("FOLGRIDS", "SHT04", STR0015)		//"Vendas sem Titulos"
		oView:CreateHorizontalBox("HB01SHT04", 40, NIL, NIL, "FOLGRIDS", "SHT04")
		oView:CreateHorizontalBox("HB02SHT04", 40, NIL, NIL, "FOLGRIDS", "SHT04")
		oView:CreateHorizontalBox("HB03SHT04", 18, NIL, NIL, "FOLGRIDS", "SHT04")

		//Grid - Vendas sem Titulos - FIF
		oView:AddGrid("GRD01FIF04", oStrFIF04, "FIFFLD4")
		oView:SetOwnerView("GRD01FIF04", "HB01SHT04")
		oView:SetViewProperty("GRD01FIF04", "GRIDSEEK", {.T.})
		oView:SetViewProperty("GRD01FIF04", "GRIDFILTER", {.T.})


		//Insere campo de Selecao do Registro na Grid
		AddField(2, oStrFIF04)

		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 2, oStrFIF04)

		oStrFIF04:RemoveField("FIF_NSUTEF")

		oStrFIF04:SetProperty("FIF_CODJUS", 	MVC_VIEW_CANCHANGE, .T.)
		oStrFIF04:SetProperty("FIF_DESJUT", 	MVC_VIEW_CANCHANGE, .T.)

		oStrFIF04:SetProperty('OK'  	   , MVC_VIEW_ORDEM ,'01')
		oStrFIF04:SetProperty('FIF_DTTEF'  , MVC_VIEW_ORDEM ,'02')
		oStrFIF04:SetProperty('FIF_CODFIL' , MVC_VIEW_ORDEM ,'03')
		oStrFIF04:SetProperty('FIF_VLBRUT' , MVC_VIEW_ORDEM ,'04')
		oStrFIF04:SetProperty('FIF_VLLIQ'  , MVC_VIEW_ORDEM ,'05')
		oStrFIF04:SetProperty('FIF_NSUARQ' , MVC_VIEW_ORDEM ,'06')
		oStrFIF04:SetProperty('FIF_CODAUT' , MVC_VIEW_ORDEM ,'07')
		oStrFIF04:SetProperty('FIF_CODLOJ' , MVC_VIEW_ORDEM ,'08')
		oStrFIF04:SetProperty('FIF_CODEST' , MVC_VIEW_ORDEM ,'09')
		oStrFIF04:SetProperty('FIF_DTCRED' , MVC_VIEW_ORDEM ,'10')
		oStrFIF04:SetProperty('FIF_TPREG'  , MVC_VIEW_ORDEM ,'11')
		oStrFIF04:SetProperty('FIF_NURESU' , MVC_VIEW_ORDEM ,'12')
		oStrFIF04:SetProperty('FIF_NUCOMP' , MVC_VIEW_ORDEM ,'13')
		oStrFIF04:SetProperty('FIF_TPPROD' , MVC_VIEW_ORDEM ,'14')
		oStrFIF04:SetProperty('FIF_CODBCO' , MVC_VIEW_ORDEM ,'15')
		oStrFIF04:SetProperty('FIF_CODAGE' , MVC_VIEW_ORDEM ,'16')
		oStrFIF04:SetProperty('FIF_NUMCC'  , MVC_VIEW_ORDEM ,'17')
		oStrFIF04:SetProperty('FIF_VLCOM'  , MVC_VIEW_ORDEM ,'18')
		oStrFIF04:SetProperty('FIF_TXSERV' , MVC_VIEW_ORDEM ,'19')
		oStrFIF04:SetProperty('FIF_NUM'    , MVC_VIEW_ORDEM ,'20')
		oStrFIF04:SetProperty('FIF_PARCEL' , MVC_VIEW_ORDEM ,'21')
		oStrFIF04:SetProperty('FIF_PARALF' , MVC_VIEW_ORDEM ,'22')
		oStrFIF04:SetProperty('FIF_PARC'   , MVC_VIEW_ORDEM ,'23')
		oStrFIF04:SetProperty('FIF_STVEND' , MVC_VIEW_ORDEM ,'24')
		oStrFIF04:SetProperty('FIF_CODBAN' , MVC_VIEW_ORDEM ,'25')
		oStrFIF04:SetProperty('FIF_CODADM' , MVC_VIEW_ORDEM ,'26')
		oStrFIF04:SetProperty('FIF_SEQFIF' , MVC_VIEW_ORDEM ,'27')

		oStrFIF04:RemoveField("FIF_CODMAJ")

		//Grid - Titulos sem Vendas - SE1
		oView:AddGrid("GRD01SE104", oStrSE104, "SE1FLD4")
		oView:SetOwnerView("GRD01SE104", "HB02SHT04")
		oView:SetViewProperty("GRD01SE104", "GRIDSEEK", {.T.})
		oView:SetViewProperty("GRD01SE104", "GRIDFILTER", {.T.})

		//Insere campo de Selecao do Registro na Grid
		AddField(2, oStrSE104, ,4)

		oStrSE104:SetProperty('OK'  	   	, MVC_VIEW_ORDEM ,'01')
		oStrSE104:SetProperty('E1_EMISSAO' 	, MVC_VIEW_ORDEM ,'02')
		oStrSE104:SetProperty('E1_XFILORI' 	, MVC_VIEW_ORDEM ,'03')
		oStrSE104:SetProperty('E1_XVLRREAL' , MVC_VIEW_ORDEM ,'04')
		oStrSE104:SetProperty('E1_VALOR'   	, MVC_VIEW_ORDEM ,'05')
		oStrSE104:SetProperty('E1_XSALDO'  	, MVC_VIEW_ORDEM ,'06')
		oStrSE104:SetProperty('E1_NSUTEF'  	, MVC_VIEW_ORDEM ,'07')
		oStrSE104:SetProperty('E1_XCARTAUT' , MVC_VIEW_ORDEM ,'08')
		oStrSE104:SetProperty('E1_CLIENTE' 	, MVC_VIEW_ORDEM ,'09')
		oStrSE104:SetProperty('E1_LOJA'    	, MVC_VIEW_ORDEM ,'10')
		oStrSE104:SetProperty('E1_NOMCLI'  	, MVC_VIEW_ORDEM ,'11')
		oStrSE104:SetProperty('E1_VENCTO'  	, MVC_VIEW_ORDEM ,'12')
		oStrSE104:SetProperty('E1_VENCREA' 	, MVC_VIEW_ORDEM ,'13')
		oStrSE104:SetProperty('E1_PREFIXO' 	, MVC_VIEW_ORDEM ,'14')
		oStrSE104:SetProperty('E1_NUM'     	, MVC_VIEW_ORDEM ,'15')
		oStrSE104:SetProperty('E1_PARCELA' 	, MVC_VIEW_ORDEM ,'16')
		oStrSE104:SetProperty('E1_TIPO'    	, MVC_VIEW_ORDEM ,'17')
		oStrSE104:SetProperty('E1_NATUREZ' 	, MVC_VIEW_ORDEM ,'18')
		oStrSE104:SetProperty('E1_XVALLIQ' 	, MVC_VIEW_ORDEM ,'19')

		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 2, oStrSE104)

		//Botao Efetivar
		oView:AddOtherObject("btnEf04", {|oPanel| F916Botao(oPanel, 4,, __nFIFFLD4 = GRIDMAXLIN .OR. __nSE1FLD4 = GRIDMAXLIN)})
		oView:SetOwnerView("btnEf04", "HB03SHT04")
		//Imprimir Browser
		oView:AddOtherObject("btnEf06", {|oPanel| F916Botao(oPanel, 8 ,oView)})
	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 5
		/*
		-------------------------------------------------------------------
		Sheet 05 - Divergentes
		-------------------------------------------------------------------
		*/

		oStrFIF05:RemoveField("FIF_DTCRED")

		oView:AddSheet("FOLGRIDS", "SHT05", STR0014, {|oForm,cFieldName,nLineGrid,nLineModel| fLinDbFVY(oForm,cFieldName,nLineGrid,nLineModel,@cDescri), __oDescri:Refresh()})	//"Divergentes"
		//		oView:CreateHorizontalBox("HB01SHT05", 84, NIL, NIL, "FOLGRIDS", "SHT05")
		oView:CreateHorizontalBox("HB01SHT05", 56, NIL, NIL, "FOLGRIDS", "SHT05")
		oView:CreateHorizontalBox("HB03SHT05", 26, NIL, NIL, "FOLGRIDS", "SHT05")
		oView:CreateHorizontalBox("HB02SHT05", 16, NIL, NIL, "FOLGRIDS", "SHT05")

		//Grid - Divergentes - FIF
		oView:AddGrid("GRD01FIF05", oStrFIF05, "FIFFLD5")
		oView:SetOwnerView("GRD01FIF05", "HB01SHT05")
		oView:SetViewProperty("GRD01FIF05", "GRIDSEEK", {.T.})

		//Insere campo de Selecao do Registro nas Grids
		AddField(2, oStrFIF05)

		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 2, oStrFIF05)

		oStrFIF05:RemoveField("FIF_NSUTEF")

		oStrFIF05:SetProperty("FIF_CODJUS", MVC_VIEW_CANCHANGE, .T.)
		oStrFIF05:SetProperty("FIF_DESJUT", MVC_VIEW_CANCHANGE, .T.)

		oStrFIF05:SetProperty('OK'  	   , MVC_VIEW_ORDEM ,'01')
		oStrFIF05:SetProperty('FIF_DTTEF'  , MVC_VIEW_ORDEM ,'02')
		oStrFIF05:SetProperty('FIF_CODFIL' , MVC_VIEW_ORDEM ,'03')
		oStrFIF05:SetProperty('FIF_VLBRUT' , MVC_VIEW_ORDEM ,'04')
		oStrFIF05:SetProperty('FIF_VLLIQ'  , MVC_VIEW_ORDEM ,'05')
		oStrFIF05:SetProperty('FIF_NSUARQ' , MVC_VIEW_ORDEM ,'06')
		oStrFIF05:SetProperty('FIF_CODAUT' , MVC_VIEW_ORDEM ,'07')
		oStrFIF05:SetProperty('FIF_CODEST' , MVC_VIEW_ORDEM ,'08')
		oStrFIF05:SetProperty('FIF_TPREG'  , MVC_VIEW_ORDEM ,'09')
		oStrFIF05:SetProperty('FIF_TPREG'  , MVC_VIEW_ORDEM ,'10')
		oStrFIF05:SetProperty('FIF_CODLOJ' , MVC_VIEW_ORDEM ,'11')
		oStrFIF05:SetProperty('FIF_NURESU' , MVC_VIEW_ORDEM ,'12')
		oStrFIF05:SetProperty('FIF_NUCOMP' , MVC_VIEW_ORDEM ,'13')
		oStrFIF05:SetProperty('FIF_TPPROD' , MVC_VIEW_ORDEM ,'14')
		oStrFIF05:SetProperty('FIF_CODBCO' , MVC_VIEW_ORDEM ,'15')
		oStrFIF05:SetProperty('FIF_CODAGE' , MVC_VIEW_ORDEM ,'16')
		oStrFIF05:SetProperty('FIF_NUMCC'  , MVC_VIEW_ORDEM ,'17')
		oStrFIF05:SetProperty('FIF_VLCOM'  , MVC_VIEW_ORDEM ,'18')
		oStrFIF05:SetProperty('FIF_TXSERV' , MVC_VIEW_ORDEM ,'19')
		oStrFIF05:SetProperty('FIF_NUM'    , MVC_VIEW_ORDEM ,'20')
		oStrFIF05:SetProperty('FIF_PARCEL' , MVC_VIEW_ORDEM ,'21')
		oStrFIF05:SetProperty('FIF_PARALF' , MVC_VIEW_ORDEM ,'22')
		oStrFIF05:SetProperty('FIF_PARC'   , MVC_VIEW_ORDEM ,'23')
		oStrFIF05:SetProperty('FIF_STVEND' , MVC_VIEW_ORDEM ,'24')
		oStrFIF05:SetProperty('FIF_CODBAN' , MVC_VIEW_ORDEM ,'25')
		oStrFIF05:SetProperty('FIF_CODADM' , MVC_VIEW_ORDEM ,'26')
		oStrFIF05:SetProperty('FIF_SEQFIF' , MVC_VIEW_ORDEM ,'27')

		oView:SetViewProperty("GRD01FIF05", "GRIDDOUBLECLICK", {{|oForm,cFieldName,nLineGrid,nLineModel| fLinDbFVY(oForm,cFieldName,nLineGrid,nLineModel,@cDescri)}})
		oView:SetViewProperty("GRD01FIF05", "CHANGELINE", {{|oForm,cFieldName,nLineGrid,nLineModel| fLinDbFVY(oForm,cFieldName,nLineGrid,nLineModel,@cDescri), __oDescri:Refresh()}})

		oView:AddOtherObject("OtherMsg", {|oPanel| F916Msg(oPanel, @cDescri)})
		oView:SetOwnerView("OtherMsg", "HB03SHT05")

		//Botao Efetivar
		oView:AddOtherObject("btnEf05", {|oPanel| F916Botao(oPanel, 5,,__nFIFFLD5 = GRIDMAXLIN )})
		oView:SetOwnerView("btnEf05", "HB02SHT05")
		//Imprimir Browser
		oView:AddOtherObject("btnEf06", {|oPanel| F916Botao(oPanel, 8 ,oView)})
	EndIf

	/*
	-------------------------------------------------------------------
	Sheet 06 - Totais
	-------------------------------------------------------------------
	*/
	oView:AddSheet("FOLGRIDS", "SHT06", STR0016)		//"Totais"
	oView:CreateHorizontalBox("HB01SHT06", 100, NIL, NIL, "FOLGRIDS", "SHT06")
	oView:AddGrid("GRD01TOT06", oStrTot06, "TOTFLD6")
	oView:SetOwnerView("GRD01TOT06", "HB01SHT06")
	oView:SetViewProperty("GRD01TOT06", "GRIDSEEK", {.T.})

	oView:SetProgressBar(.T.)
	oView:setUpdateMessage(STR0044,STR0093) // Conciliação # Processo realizado com sucesso.
	Return oView

	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916Botao
	Inclusao de Botao de Efetivacao

	@author Guilherme Santos
	@since 27/02/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Function F916Botao( oPanel As Object, nSheet As Numeric, oView As Object, lMsg As Logical )
	Local oButton	As Object
	Local oSay      As Object
	Default lMsg := .F.

	If nSheet != 5
		If nSheet == 8
			@018, 000 BUTTON oButton PROMPT STR0050  SIZE 070, 020 FONT oPanel:oFont ACTION F916Print(oView) OF oPanel PIXEL		//"Imprimir Browser"
		Else
			@020, 010 BUTTON oButton PROMPT STR0018 SIZE 060, 020 FONT oPanel:oFont ACTION F916Grava(nSheet) OF oPanel PIXEL		//"Efetivar"
		Endif
	Else
		@020, 010 BUTTON oButton PROMPT STR0034 SIZE 060, 020 FONT oPanel:oFont ACTION F916Grava(nSheet) OF oPanel PIXEL		//"Gravar"
	EndIf

	If lMsg
		If nSheet == 1 .OR. nSheet == 2
			@020, 100 Say oSay PROMPT STR0087  SIZE 400, 020 FONT  OF oPanel PIXEL		//"A quantidade de registros de vendas execedeu o limite máximo de 10.000(dez mil). Após concluir a conciliação repita o processamento da rotina com a mesma parametrização para conciliar o restante dos registros."
		ElseIf nSheet == 3
			@020, 100 Say oSay PROMPT STR0088  SIZE 400, 020 FONT  OF oPanel PIXEL		//"A quantidade de registros de títulos execedeu o limite máximo de 10.000(dez mil). Após concluir a conciliação repita o processamento da rotina com a mesma parametrização para conciliar o restante dos registros."
		ElseIf nSheet == 4
			If __nFIFFLD4 = GRIDMAXLIN .And. __nSE1FLD4 = GRIDMAXLIN
				@020, 100 Say oSay PROMPT STR0089  SIZE 400, 020 FONT  OF oPanel PIXEL		//"A quantidade de registros de vendas e títulos execederam o limite máximo de 10.000(dez mil). Após concluir a conciliação repita o processamento da rotina com a mesma parametrização para conciliar o restante dos registros."
			ElseIf __nFIFFLD4 = GRIDMAXLIN
				@020, 100 Say oSay PROMPT STR0087  SIZE 400, 020 FONT  OF oPanel PIXEL		//"A quantidade de registros de vendas execedeu o limite máximo de 10.000(dez mil). Após concluir a conciliação repita o processamento da rotina com a mesma parametrização para conciliar o restante dos registros."
			ElseIf __nSE1FLD4 = GRIDMAXLIN
				@020, 100 Say oSay PROMPT STR0088  SIZE 400, 020 FONT  OF oPanel PIXEL		//"A quantidade de registros de títulos execedeu o limite máximo de 10.000(dez mil). Após concluir a conciliação repita o processamento da rotina com a mesma parametrização para conciliar o restante dos registros."
			EndIf
		ElseIf nSheet == 5
			@020, 100 Say oSay PROMPT STR0090  SIZE 400, 020 FONT  OF oPanel PIXEL		//"A quantidade de registros de divergencias execedeu o limite máximo de 10.000(dez mil). Após concluir a conciliação repita o processamento da rotina com a mesma parametrização para conciliar o restante dos registros."
		EndIf
	EndIf

	Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916Botao
	Inclusao de Check para marcar todos

	@author Igor Fricks
	@since 14/06/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Function F916Marc( oPanel As Object, nSheet As Numeric )
	Local oCheck	As Object
	Do Case
	Case nSheet == 1
		__lCheck01 := .T.
		@003, 003 CHECKBOX oCheck VAR __lCheck01 Size 060, 020 PROMPT STR0017 ON Change(F916Check(__lCheck01, "FIFFLD1")) Of oPanel	//"Marca todos"
	Case nSheet == 2
		__lCheck02 := .T.
		@003, 003 CHECKBOX oCheck VAR __lCheck02 Size 060, 020 PROMPT STR0017 ON Change(F916Check(__lCheck02, "FIFFLD2")) Of oPanel	//"Marca todos"
	Case nSheet == 3
		@003, 003 CHECKBOX oCheck VAR __lCheck03 Size 060, 020 PROMPT STR0017 ON Change(F916Check(__lCheck03, "SE1FLD3" )) Of oPanel	//"Marca todos"
	EndCase
	Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916Check
	Marca ou desmarca todos os Registros da Sheet ativa

	@author Guilherme Santos
	@since 27/02/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Function F916Check( lCheck As Logical, cSheet As Character )
	Local nLinBkp	As Numeric
	Local nLin	As Numeric
	Local oModel	As Object
	Local oView		As Object


	nLinBkp	:= 0
	nLinSE1	:= 0

	oModel	:= FWModelActive()
	oView 	:= FwViewActive()

	If !Empty(cSheet)
		nLinBkp := oModel:GetModel(cSheet):GetLine()

		For nLin := 1 to oModel:GetModel(cSheet):Length()
			oModel:GetModel(cSheet):GoLine(nLin)

			oModel:SetValue(cSheet, "OK", lCheck)
		Next nLin

		oModel:GetModel(cSheet):GoLine(nLinBkp)
		oView:Refresh(cSheet)
	EndIf

	Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916Msg
	Painel com a descrição do motivo de rejeição na aba divergente
	@author Danilo Santos
	@param		oPanel - objeto Painel, cDescri - Campo descrição
	@return		NIl
	@since 08/05/2018
	@version P12
	/*/
	//-------------------------------------------------------------------
Function F916Msg( oPanel As Object, cDescri As Character )

	DEFINE FONT oFnt NAME "Arial" SIZE 11,20
	@ 015, 010 SAY   STR0035 SIZE 050, 020 OF oPanel PIXEL FONT oFnt COLOR CLR_HBLUE
	@ 030, 010 MSGET __oDescri VAR cDescri SIZE 200, 40  Of oPanel PIXEL When .F.

	Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} fLinDbFVY
	Inclui informação do motivo de rejeição na aba divergente
	@author Danilo Santos
	@param		oForm - objeto Grid, cFieldName - nome do campo, nLineGrid - linha Grid, nLineModel - Linha do modelo
	@return		boolean
	@since 08/05/2018
	@version P12
	/*/
	//-------------------------------------------------------------------
Static function fLinDbFVY( oForm As Object, cFieldName As Character, nLineGrid As Numeric, nLineModel As Numeric, cDescri As Character ) As Logical
	Local lRet			As Logical
	Local oModel		As Object
	Local oModelGrid	As Object
	Local cCampo		As Character
	Local cCodFil		As Character

	lRet		:= .T.
	oModel		:= FWModelActivate()
	oModelGrid	:= oModel:GetModel('FIFFLD5')
	cCampo		:= ""
	cDescri		:= ""
	cCodFil		:= ""

	If F916ChkMod("FVY") // Verifica se modo da tabela é exclusivo
		cCodFil := oModelGrid:GetValue("FIF_CODFIL")
	Else
		cCodFil := xFilial("FVY")
	EndIf

	DbSelectArea("FVY")
	FVY->(DbSetOrder(1))

	If FVY->(DbSeek(cCodFil + oModelGrid:GetValue("FIF_CODADM") + oModelGrid:GetValue("FIF_CODMAJ") ))
		cDescri := Alltrim(FVY->FVY_DESCR)
	Else
		cDescri := " "
	Endif

	Return lRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916Grava
	Gravacao dos Dados Selecionados para Conciliacao

	@author Guilherme Santos
	@since 27/02/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Function F916Grava( nSheet As Numeric )
	Local oModel	As Object
	Local oView		As Object
	Local oModNew	As Object
	Local oSubFIF	As Object
	Local oSubSE1	As Object
	Local cLog		As Character
	Local cCodUser  As Character
	Local nLinFIF	As Numeric
	Local nLinSE1	As Numeric
	Local nCount	As Numeric
	Local lRegSE1	As Logical
	Local lRetorno	As Logical
	Local cQuery	As Character
	Local cSeqFIF	As Character
	Local cFilOrig	As Character
	Local cParcSE1	As Character
	Local cFIFAlias	As Character

	oModel		:= FWModelActive()
	oView		:= FwViewActive()
	cLog		:= ""
	cCodUser	:= RetCodUsr() //R
	nLinFIF		:= 0
	nLinSE1		:= 0
	nCount		:= 0
	lRegSE1		:= .F.
	lRetorno	:= .T.
	cQuery 		:= ""
	cSeqFIF 	:= ""
	cFilOrig 	:= ""
	cParcSE1 	:= ""
	cFIFAlias 	:= ""

	cQuery := " SELECT MAX(FIF_SEQFIF) MAXFIF FROM " + RetSqlName("FIF")

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB" )

	If TRB->( !Eof() )
		cSeqFIF := Soma1( TRB->MAXFIF )
	Else
		cSeqFIF := Soma1( "000000" )
	EndIf

	TRB->(DbCloseArea())

	Do Case
	Case nSheet == 1	//Conciliado Normal - FIF_STVEND := "2"
		oSubFIF := oModel:GetModel("FIFFLD1")

		For nLinFIF := 1 to oSubFIF:Length()
			oSubFIF:GoLine(nLinFIF)

			If oSubFIF:GetValue("OK")
				DbSelectArea("FIF")
				DbSetOrder(5)	//FIF_FILIAL, FIF_DTTEF, FIF_NSUTEF, FIF_PARCEL, FIF_CODLOJ, FIF_DTCRED, FIF_SEQFIF

				If FIF->(DbSeek(oSubFIF:GetValue("FIF_FILIAL") + DtoS(oSubFIF:GetValue("FIF_DTTEF")) + oSubFIF:GetValue("FIF_NSUTEF") + oSubFIF:GetValue("FIF_PARCEL") + oSubFIF:GetValue("FIF_CODLOJ") + DtoS(oSubFIF:GetValue("FIF_DTCRED")) + oSubFIF:GetValue("FIF_SEQFIF")))

					oModNew := FWLoadModel("FINA916A")
					oModNew:SetOperation(MODEL_OPERATION_UPDATE)	//Alteração
					oModNew:Activate()
					oModNew:GetModel("HEADER"):SetValue("FIF_STVEND", "2")
					oModNew:GetModel("HEADER"):SetValue("FIF_DTCONV", dDatabase)
					oModNew:GetModel("HEADER"):SetValue("FIF_CODJUS", oSubFIF:GetValue("FIF_CODJUS"))
					oModNew:GetModel("HEADER"):SetValue("FIF_DESJUS", oSubFIF:GetValue("FIF_DESJUS"))
					oModNew:GetModel("HEADER"):SetValue("FIF_DESJUT", oSubFIF:GetValue("FIF_DESJUT"))
					oModNew:GetModel("HEADER"):SetValue("FIF_USUVEN", cCodUser)
					oModNew:GetModel("HEADER"):SetValue("FIF_DTVEN", dDatabase)

					If oModNew:VldData()
						oModNew:CommitData()
						nCount++
					Else
						lRetorno := .F.
						cLog := cValToChar(oModNew:GetErrorMessage()[4]) + ' - '
						cLog += cValToChar(oModNew:GetErrorMessage()[5]) + ' - '
						cLog += cValToChar(oModNew:GetErrorMessage()[6])

						Help(NIL, NIL, "F916Grava", NIL, cLog, 1, 0)
						Exit
					EndIf
					oModNew:DeActivate()
					oModNew:Destroy()
					oModNew:=NIL
				EndIf
			EndIf
		Next nLinFIF
	Case nSheet == 2	//Conciliado Parcialmente - FIF_STVEND := "3"
		oSubFIF := oModel:GetModel("FIFFLD2")

		For nLinFIF := 1 to oSubFIF:Length()
			oSubFIF:GoLine(nLinFIF)

			If oSubFIF:GetValue("OK")

				If Empty(oSubFIF:GetValue("FIF_CODJUS"))
					lRetorno := .F.
					Help(NIL, NIL, "F916Grava", NIL, STR0019, 1, 0)		//"Informe a Justificativa para a Conciliação."
					Exit
				EndIf

				DbSelectArea("FIF")
				DbSetOrder(5)	//FIF_FILIAL, FIF_DTTEF, FIF_NSUTEF, FIF_PARCEL, FIF_CODLOJ, FIF_DTCRED, FIF_SEQFIF

				If FIF->(DbSeek(oSubFIF:GetValue("FIF_FILIAL") + DtoS(oSubFIF:GetValue("FIF_DTTEF")) + oSubFIF:GetValue("FIF_NSUTEF") + oSubFIF:GetValue("FIF_PARCEL") + oSubFIF:GetValue("FIF_CODLOJ") + DtoS(oSubFIF:GetValue("FIF_DTCRED")) + oSubFIF:GetValue("FIF_SEQFIF")))

					oModNew := FWLoadModel("FINA916A")
					oModNew:SetOperation(MODEL_OPERATION_UPDATE)	//Alteração
					oModNew:Activate()
					oModNew:GetModel("HEADER"):SetValue("FIF_STVEND", "3")
					oModNew:GetModel("HEADER"):SetValue("FIF_DTCONV", dDatabase)
					oModNew:GetModel("HEADER"):SetValue("FIF_CODJUS", oSubFIF:GetValue("FIF_CODJUS"))
					oModNew:GetModel("HEADER"):SetValue("FIF_DESJUS", oSubFIF:GetValue("FIF_DESJUS"))
					oModNew:GetModel("HEADER"):SetValue("FIF_DESJUT", oSubFIF:GetValue("FIF_DESJUT"))
					oModNew:GetModel("HEADER"):SetValue("FIF_USUVEN", cCodUser)
					oModNew:GetModel("HEADER"):SetValue("FIF_DTVEN", dDatabase)

					If oModNew:VldData()
						oModNew:CommitData()
						nCount++
					Else
						lRetorno := .F.
						cLog := cValToChar(oModNew:GetErrorMessage()[4]) + ' - '
						cLog += cValToChar(oModNew:GetErrorMessage()[5]) + ' - '
						cLog += cValToChar(oModNew:GetErrorMessage()[6])

						Help(NIL, NIL, "F916Grava", NIL, cLog, 1, 0)
						Exit
					EndIf
					oModNew:DeActivate()
					oModNew:Destroy()
					oModNew:=NIL
				EndIf
			EndIf
		Next nLinFIF
	Case nSheet == 3	//Titulos sem Vendas
		//Nenhuma acao ou incluir FIF com os Titulos Selecionados?
		//Se incluir FIF gravar FIF_STVEND como "6"
		oSubSE1 := oModel:GetModel("SE1FLD3")

		For nLinSE1 := 1 to oSubSE1:Length()
			oSubSE1:GoLine(nLinSE1)
			If oSubSE1:GetValue("OK") .And. !Empty(oSubSE1:GetValue("E1_NUM")) .And. !Empty(oSubSE1:GetValue("E1_NSUTEF"))

				If Empty(oSubSE1:GetValue("FIF_XCODJU"))
					lRetorno := .F.
					Help(NIL, NIL, "F916Grava", NIL, STR0019, 1, 0)		//"Informe a Justificativa para a Conciliação."
					Exit
				EndIf

				cFIFAlias	:= GetNextAlias()
				cQuery := " SELECT COUNT(1) CONTADOR " + CRLF
				cQuery += " FROM "+RetSqlName("FIF") + CRLF
				cQuery += " WHERE FIF_DTTEF  = '" + DtoS(oSubSE1:GetValue("E1_EMISSAO")) + "' " + CRLF
				If __lOracle .or. __lPostGre
					cQuery += "   AND LPAD(TRIM(FIF_NSUTEF), "+__cTamNSU+", '0') = '" + PADL(ALLTRIM(oSubSE1:GetValue("E1_NSUTEF")),VAL(__cTamNSU),"0") + "' " + CRLF
				Else
					cQuery += "   AND  REPLICATE('0', "+__cTamNSU+" - LEN(FIF_NSUTEF)) + RTrim(FIF_NSUTEF)  = '" + PADL(ALLTRIM(oSubSE1:GetValue("E1_NSUTEF")),VAL(__cTamNSU),"0") + "' " + CRLF
				Endif	
				cQuery += "   AND FIF_PARCEL = '" + oSubSE1:GetValue("E1_PARCELA") + "' " + CRLF
				cQuery += "   AND FIF_CODFIL = '" + oSubSE1:GetValue("E1_FILORIG") + "' " + CRLF
				cQuery += "   AND FIF_DTCRED = '" + Dtos(oSubSE1:GetValue("E1_VENCREA")) + "' " + CRLF
				cQuery += "   AND D_E_L_E_T_ = ' ' " + CRLF
				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cFIFAlias,.F.,.T.)

				If !(cFIFAlias)->(Eof()) .And. (cFIFAlias)->CONTADOR == 0

					oModNew := FWLoadModel("FINA916A")
					oModNew:SetOperation(MODEL_OPERATION_INSERT)	//Inclusão
					oModNew:Activate()

					oModNew:GetModel("HEADER"):SetValue("FIF_NSUTEF", PADL(ALLTRIM(oSubSE1:GetValue("E1_NSUTEF")),VAL(__cTamNSU),"0"))
					oModNew:GetModel("HEADER"):SetValue("FIF_NURESU", "")
					oModNew:GetModel("HEADER"):SetValue("FIF_NUCOMP", "")
					oModNew:GetModel("HEADER"):SetValue("FIF_TPREG", "1")
					oModNew:GetModel("HEADER"):SetValue("FIF_INTRAN", "0")
					oModNew:GetModel("HEADER"):SetValue("FIF_DTTEF", oSubSE1:GetValue("E1_EMISSAO"))
					oModNew:GetModel("HEADER"):SetValue("FIF_VLBRUT", oSubSE1:GetValue("E1_VLRREAL"))
					oModNew:GetModel("HEADER"):SetValue("FIF_VLLIQ", oSubSE1:GetValue("E1_VALOR"))
					oModNew:GetModel("HEADER"):SetValue("FIF_TOTPAR", "01")
					oModNew:GetModel("HEADER"):SetValue("FIF_DTCRED", oSubSE1:GetValue("E1_VENCREA"))
					oModNew:GetModel("HEADER"):SetValue("FIF_PARCEL", oSubSE1:GetValue("E1_PARCELA"))
					oModNew:GetModel("HEADER"):SetValue("FIF_CODFIL", oSubSE1:GetValue("E1_FILORIG"))
					oModNew:GetModel("HEADER"):SetValue("FIF_USUVEN", cCodUser)
					oModNew:GetModel("HEADER"):SetValue("FIF_DTVEN", dDatabase)

					If Alltrim(oSubSE1:GetValue("E1_TIPO")) == "CD"
						oModNew:GetModel("HEADER"):SetValue("FIF_TPPROD", "D")
					ElseIf Alltrim(oSubSE1:GetValue("E1_TIPO")) == "CC"
						oModNew:GetModel("HEADER"):SetValue("FIF_TPPROD", "C")
					EndIf

					oModNew:GetModel("HEADER"):SetValue("FIF_STVEND", "6")
					oModNew:GetModel("HEADER"):SetValue("FIF_PREFIX", oSubSE1:GetValue("E1_PREFIXO"))
					oModNew:GetModel("HEADER"):SetValue("FIF_NUM", oSubSE1:GetValue("E1_NUM"))
					oModNew:GetModel("HEADER"):SetValue("FIF_PARC", oSubSE1:GetValue("E1_PARCELA"))
					oModNew:GetModel("HEADER"):SetValue("FIF_TIPO", oSubSE1:GetValue("E1_TIPO"))
					oModNew:GetModel("HEADER"):SetValue("FIF_PARALF", oSubSE1:GetValue("E1_PARCELA"))
					oModNew:GetModel("HEADER"):SetValue("FIF_DTCONV", dDatabase)
					oModNew:GetModel("HEADER"):SetValue("FIF_USUVEN", cCodUser)
					oModNew:GetModel("HEADER"):SetValue("FIF_DTVEN", dDatabase)
					oModNew:GetModel("HEADER"):SetValue("FIF_SEQFIF", cSeqFIF)

					oModNew:GetModel("HEADER"):SetValue("FIF_CODJUS", oSubSE1:GetValue("FIF_XCODJU"))
					oModNew:GetModel("HEADER"):SetValue("FIF_DESJUS", oSubSE1:GetValue("FIF_XDESJU"))
					oModNew:GetModel("HEADER"):SetValue("FIF_DESJUT", oSubSE1:GetValue("FIF_XDESJT"))

					If oModNew:VldData()
						oModNew:CommitData()
						nCount++
						cSeqFIF := Soma1( cSeqFIF )
					Else
						lRetorno := .F.
						cLog := cValToChar(oModNew:GetErrorMessage()[4]) + ' - '
						cLog += cValToChar(oModNew:GetErrorMessage()[5]) + ' - '
						cLog += cValToChar(oModNew:GetErrorMessage()[6])

						Help(NIL, NIL, "F916Grava", NIL, cLog, 1, 0)
						Exit
					EndIf
					oModNew:DeActivate()
					oModNew:Destroy()
					oModNew:=NIL
				EndIf
				(cFIFAlias)->( dbCloseArea() )
			EndIf
		Next nLinSE1
	Case nSheet == 4	//Vendas sem Titulos
		oSubFIF := oModel:GetModel("FIFFLD4")
		oSubSE1 := oModel:GetModel("SE1FLD4")
		lRegSE1	:= .F.

		For nLinFIF := 1 to oSubFIF:Length()
			oSubFIF:GoLine(nLinFIF)

			If oSubFIF:GetValue("OK")
				For nLinSE1 := 1 to oSubSE1:Length()
					oSubSE1:GoLine(nLinSE1)

					If oSubSE1:GetValue("OK")
						cFilOrig := oSubSE1:GetValue("E1_FILORIG")
						cParcSE1 := oSubSE1:GetValue("E1_PARCELA")
						lRegSE1	:= .T.
						//Sai do Loop
						Exit
					EndIf
				Next nLinSE1

				If lRegSE1 .And. oSubFIF:GetValue("FIF_CODFIL") <> cFilOrig
					Help(NIL, NIL, "F916Grava_Fil", NIL, STR0059+CRLF+CRLF+; //"A filial do registro de vendas está diferente da filial do título selecionado. Por favor, verifique! "
					STR0060 +' "'+Alltrim(cFilOrig)+'" '+CRLF+;//"Filial Venda (FIF):"
					STR0061 +' "'+Alltrim(oSubFIF:GetValue("FIF_CODFIL"))+'" ' , 1, 0) //"Filial Título (SE1):"
					lRetorno := .F.
					Exit
				EndIf

				If lRegSE1 .And. oSubFIF:GetValue("FIF_PARALF") <> cParcSE1
					Help(NIL, NIL, "F916Grava_Parc", NIL, STR0070+CRLF+CRLF+; //"Não será possível efetuar o vínculo entre venda e título com parcelas distintas. Por favor, verifique! "
					STR0068 +' "'+Alltrim(cParcSE1)+'" '+CRLF+;//"Parcela Venda (FIF):"
					STR0069 +' "'+Alltrim(oSubFIF:GetValue("FIF_PARALF"))+'" ' , 1, 0) //"Parcela Título (SE1):"
					lRetorno := .F.
					Exit
				EndIf

				If Empty(oSubFIF:GetValue("FIF_CODJUS"))
					lRetorno := .F.
					Help(NIL, NIL, "F916Grava", NIL, STR0019, 1, 0)		//"Informe a Justificativa para a Conciliação."
					Exit
				EndIf

				DbSelectArea("FIF")
				DbSetOrder(5)	//FIF_FILIAL, FIF_DTTEF, FIF_NSUTEF, FIF_PARCEL, FIF_CODLOJ, FIF_DTCRED, FIF_SEQFIF

				If FIF->(DbSeek(oSubFIF:GetValue("FIF_FILIAL") + DtoS(oSubFIF:GetValue("FIF_DTTEF")) + oSubFIF:GetValue("FIF_NSUTEF") + oSubFIF:GetValue("FIF_PARCEL") + oSubFIF:GetValue("FIF_CODLOJ") + DtoS(oSubFIF:GetValue("FIF_DTCRED")) + oSubFIF:GetValue("FIF_SEQFIF")))

					oModNew := FWLoadModel("FINA916A")

					oModNew:SetOperation(MODEL_OPERATION_UPDATE)	//Alteração
					oModNew:Activate()
					//Com Titulo amarrado: FIF_STVEND == "5"
					//Sem Titulo amarrado: FIF_STVEND == "7"
					oModNew:GetModel("HEADER"):SetValue("FIF_STVEND", If(lRegSE1, "5", "7"))
					oModNew:GetModel("HEADER"):SetValue("FIF_DTCONV", dDatabase)
					oModNew:GetModel("HEADER"):SetValue("FIF_CODJUS", oSubFIF:GetValue("FIF_CODJUS"))
					oModNew:GetModel("HEADER"):SetValue("FIF_DESJUS", oSubFIF:GetValue("FIF_DESJUS"))
					oModNew:GetModel("HEADER"):SetValue("FIF_DESJUT", oSubFIF:GetValue("FIF_DESJUT"))
					oModNew:GetModel("HEADER"):SetValue("FIF_USUVEN", cCodUser)
					oModNew:GetModel("HEADER"):SetValue("FIF_DTVEN", dDatabase)

					If lRegSE1
						oModNew:GetModel("HEADER"):SetValue("FIF_PARALF", oSubSE1:GetValue("E1_PARCELA"))
						oModNew:GetModel("HEADER"):SetValue("FIF_DTTEF", oSubSE1:GetValue("E1_EMISSAO"))
						oModNew:GetModel("HEADER"):SetValue("FIF_DTCRED", oSubSE1:GetValue("E1_VENCREA"))
						oModNew:GetModel("HEADER"):SetValue("FIF_CODFIL", oSubSE1:GetValue("E1_FILORIG"))
						oModNew:GetModel("HEADER"):SetValue("FIF_PREFIX", oSubSE1:GetValue("E1_PREFIXO"))
						oModNew:GetModel("HEADER"):SetValue("FIF_NUM", oSubSE1:GetValue("E1_NUM"))
						oModNew:GetModel("HEADER"):SetValue("FIF_PARC", oSubSE1:GetValue("E1_PARCELA"))
						oModNew:GetModel("HEADER"):SetValue("FIF_TIPO", oSubSE1:GetValue("E1_TIPO"))
					EndIf

					If oModNew:VldData()
						oModNew:CommitData()
						nCount++

						If lRegSE1
							DbSelectArea("SE1")
							DbSetOrder(1)		//E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO

							If SE1->(DbSeek(oSubSE1:GetValue("E1_FILIAL") + oSubSE1:GetValue("E1_PREFIXO") + oSubSE1:GetValue("E1_NUM") + oSubSE1:GetValue("E1_PARCELA") + oSubSE1:GetValue("E1_TIPO")))
								RecLock("SE1", .F.)
								SE1->E1_NSUTEF := oSubFIF:GetValue("FIF_NSUTEF")
								MsUnlock()
							Else
								lRetorno := .F.
								Help(NIL, NIL, "F916Grava", NIL, STR0020, 1, 0)		//"Titulo não localizado."
								Exit
							EndIf
						EndIf
					Else
						lRetorno := .F.
						cLog := cValToChar(oModNew:GetErrorMessage()[4]) + ' - '
						cLog += cValToChar(oModNew:GetErrorMessage()[5]) + ' - '
						cLog += cValToChar(oModNew:GetErrorMessage()[6])

						Help(NIL, NIL, "F916Grava", NIL, cLog, 1, 0)
						Exit
					EndIf
					oModNew:DeActivate()
					oModNew:Destroy()
					oModNew:=NIL
				EndIf
			EndIf
		Next nLinFIF
	Case nSheet == 5	//Divergentes

		// Valida se campos de justificativa estão preenchidos
		oSubFIF := oModel:GetModel("FIFFLD5")
		For nLinFIF := 1 to oSubFIF:Length()
			oSubFIF:GoLine(nLinFIF)
			If oSubFIF:GetValue("OK")
				If Empty(oSubFIF:GetValue("FIF_CODJUS"))
					lRetorno := .F.
					Help(NIL, NIL, "F916Grava", NIL, STR0019 + CRLF + ;
						CRLF + STR0041 + DtoC(oSubFIF:GetValue("FIF_DTTEF")) + CRLF + STR0042 + oSubFIF:GetValue("FIF_NSUTEF") + CRLF + STR0043 + oSubFIF:GetValue("FIF_PARCEL"), 1, 0)		//"Informe a Justificativa para a Conciliação."###" Data Venda: "###"NSU Sitef: "###"Parcela: "
					Exit
				EndIf
			EndIf
		Next nLinFIF

		If lRetorno

			For nLinFIF := 1 to oSubFIF:Length()
				oSubFIF:GoLine(nLinFIF)

				If oSubFIF:GetValue("OK")

					If Empty(oSubFIF:GetValue("FIF_CODJUS"))
						lRetorno := .F.
						Help(NIL, NIL, "F916Grava", NIL, STR0019, 1, 0)		//"Informe a Justificativa para a Conciliação."
						Exit
					EndIf

					DbSelectArea("FIF")
					DbSetOrder(5)	//FIF_FILIAL, FIF_DTTEF, FIF_NSUTEF, FIF_PARCEL, FIF_CODLOJ, FIF_DTCRED, FIF_SEQFIF

					If FIF->(DbSeek(oSubFIF:GetValue("FIF_FILIAL") + DtoS(oSubFIF:GetValue("FIF_DTTEF")) + oSubFIF:GetValue("FIF_NSUTEF") + oSubFIF:GetValue("FIF_PARCEL") + oSubFIF:GetValue("FIF_CODLOJ") + DtoS(oSubFIF:GetValue("FIF_DTCRED")) + oSubFIF:GetValue("FIF_SEQFIF")))

						oModNew := FWLoadModel("FINA916A")
						oModNew:SetOperation(MODEL_OPERATION_UPDATE)	//Alteração
						oModNew:Activate()
						oModNew:GetModel("HEADER"):SetValue("FIF_STVEND", "4")
						oModNew:GetModel("HEADER"):SetValue("FIF_DTCONV", dDatabase)
						oModNew:GetModel("HEADER"):SetValue("FIF_CODJUS", oSubFIF:GetValue("FIF_CODJUS"))
						oModNew:GetModel("HEADER"):SetValue("FIF_DESJUS", oSubFIF:GetValue("FIF_DESJUS"))
						oModNew:GetModel("HEADER"):SetValue("FIF_DESJUT", oSubFIF:GetValue("FIF_DESJUT"))
						oModNew:GetModel("HEADER"):SetValue("FIF_USUVEN", cCodUser)
						oModNew:GetModel("HEADER"):SetValue("FIF_DTVEN", dDatabase)

						If oModNew:VldData()
							oModNew:CommitData()
							nCount++
						Else
							lRetorno := .F.
							cLog := cValToChar(oModNew:GetErrorMessage()[4]) + ' - '
							cLog += cValToChar(oModNew:GetErrorMessage()[5]) + ' - '
							cLog += cValToChar(oModNew:GetErrorMessage()[6])

							Help(NIL, NIL, "F916Grava", NIL, cLog, 1, 0)
							Exit
						EndIf
						oModNew:DeActivate()
						oModNew:Destroy()
						oModNew:=NIL
					EndIf
				EndIf
			Next nLinFIF
		EndIf
	EndCase

	If lRetorno .AND. nCount > 0
		FWMsgRun(, {|| oView:ButtonOkAction(.F.) }, STR0091, STR0091 + STR0092)
	ElseIf lRetorno .AND. nCount == 0
		Help(NIL, NIL, "F916Grava", NIL, STR0021, 1, 0)		//"Nenhum registro selecionado para Conciliação."
	EndIf

	Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} GetFilter
	Retorna o Filtro do Browse de Conciliacao

	@author Guilherme.Santos
	@since 16/02/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function GetFilter( nFolder As Numeric, cAlias As Character ) As Character
	Local cFiltro	As Character
	Local cFilAdm	As Character
	Local cAuxLay	As Character
	Local nAuxLay	As Numeric
	Local nAuxFil	As Numeric
	Local nY		As Numeric

	Default cAlias	:= "FIF"
	Default nFolder	:= 0

	cFiltro	:= ""
	cFilAdm	:= ""
	cAuxLay	:= __cSM0Lay
	nAuxLay	:= 0
	nAuxFil	:= 0
	nY		:= 0
	lFilFif	:= !Empty(FWFilial("FIF"))

	If cAlias == "FIF"
		//Filtro do Browse
		If nFolder == 0
			cFiltro += "@FIF_STVEND <> ' ' ""
		Else

			cFiltro += " FIF_DTTEF >= '" + DtoS(MV_PAR02) + "' "
			cFiltro += "AND FIF_DTTEF <= '" + DtoS(MV_PAR03) + "' "

			If __lOracle .or. __lPostGre
				cFiltro += "AND LPAD(TRIM(FIF_NSUTEF), "+__cTamNSU+", '0')  >= '" + cNsuInicial + "' "
				cFiltro += "AND LPAD(TRIM(FIF_NSUTEF), "+__cTamNSU+", '0')  <= '" + cNsuFinal + "' "
			Else
				cFiltro += "AND REPLICATE('0', "+__cTamNSU+" - LEN(FIF_NSUTEF)) + RTrim(FIF_NSUTEF) >= '" + cNsuInicial + "' "
				cFiltro += "AND REPLICATE('0', "+__cTamNSU+" - LEN(FIF_NSUTEF)) + RTrim(FIF_NSUTEF) <= '" + cNsuFinal + "' "
			Endif	

			If MV_PAR01 == 1
				If Len( __aSelFil ) <= 0
					cFiltro += "AND FIF_CODFIL = '" + Iif( lFilFif, xFilial("FIF", __cFilAnt), __cFilAnt) + "' "
				Else
					If !__lTodFil
						cFiltro += "AND FIF_CODFIL " + GetRngFil( __aSelFil, 'FIF', .T.,, 20, .T. ) + " "
					EndIf
				EndIf
			Else
				cFiltro += "AND FIF_CODFIL = '" + Iif( lFilFif, xFilial("FIF", __cFilAnt), __cFilAnt) + "' "
			EndIf

			Do Case
			Case MV_PAR06 == 1
				cFiltro += "AND FIF_TPPROD = 'D' "
			Case MV_PAR06 == 2
				cFiltro += "AND FIF_TPPROD = 'C' "
			Case MV_PAR06 == 3
				cFiltro += "AND FIF_TPPROD IN ('C','D') "
			EndCase

			If !Empty(MV_PAR08)
				cFilAdm := FormatIn(Alltrim(MV_PAR08), ";")
				If __lSOFEX
					cFiltro += "AND FIF_CODRED IN " + cFilAdm + " "
				Else
					cFiltro += "AND FIF_CODADM IN " + cFilAdm + " "
				EndIf
			EndIf

			If __lOracle
				cFiltro += " AND ROWNUM <= " + STR(GRIDMAXLIN) + " "
			EndIf
		EndIf

	EndIf

	If cAlias == "SE1"
		cFiltro += " E1_EMISSAO >= '" + DtoS(MV_PAR02) + "' "
		cFiltro += "AND E1_EMISSAO <= '" + DtoS(MV_PAR03) + "' "

		If MV_PAR01 == 1
			If Len( __aSelFil ) <= 0
				cFiltro += " AND E1_FILORIG = '" + Iif( lFilFif, xFilial("FIF", __cFilAnt), __cFilAnt)  + "' "
			Else
				If !__lTodFil
					cFiltro += " AND E1_FILORIG " + GetRngFil( __aSelFil, 'SE1', .T.,, 20, .T. ) + " "
				EndIf
			EndIf
		Else
			cFiltro += " AND E1_FILORIG = '" + Iif( lFilFif, xFilial("FIF", __cFilAnt), __cFilAnt)  + "' "
		EndIf

		If mv_par06 == 1
			cFiltro += "AND SE1.E1_TIPO = 'CD' "
		ElseIf mv_par06 == 2
			cFiltro += "AND SE1.E1_TIPO = 'CC' "
		ElseIf mv_par06 == 3
			cFiltro += "AND SE1.E1_TIPO IN ('CC','CD') "
		EndIf

		If __lOracle
			cFiltro += " AND ROWNUM <= " + STR(GRIDMAXLIN) + " "
		EndIf
	EndIf

	If nFolder > 0
		Do Case
		Case nFolder == 1		//Conciliados
			cFiltro += "AND FIF_STVEND = '1' "
			cFiltro += "AND EXISTS ( "
			cFiltro += "SELECT E1_NSUTEF, E1_PARCELA "
			cFiltro += "FROM " + RetSqlName("SE1") + " "

			If __lDocTEF
				If __lOracle .Or. __lPostGre
					cFiltro += "WHERE LPAD(TRIM(FIF_NUCOMP), " + __cTamDOC + ", '0') = LPAD(TRIM(E1_DOCTEF), " + __cTamDOC + ", '0') "
				Else
					cFiltro += "WHERE REPLICATE('0', " + __cTamDOC + " - LEN(FIF_NUCOMP)) + RTrim(FIF_NUCOMP) = REPLICATE('0', " + __cTamDOC + " - LEN(E1_DOCTEF)) + RTrim(E1_DOCTEF) "
				EndIf
			Else
				If __lOracle .Or. __lPostGre
					cFiltro += "WHERE LPAD(TRIM(FIF_NSUTEF), " + __cTamNSU + ", '0')  = LPAD(TRIM(E1_NSUTEF), " + __cTamNSU + ", '0') "
				Else
					cFiltro += "WHERE REPLICATE('0', " + __cTamNSU + " - LEN(FIF_NSUTEF)) + RTrim(FIF_NSUTEF) =  REPLICATE('0', " + __cTamNSU + " - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) "
				EndIf
			EndIf	

			cFiltro += "AND E1_FILIAL >= ' ' "
			cFiltro += "AND FIF_DTTEF = E1_EMISSAO "

			If __lParcFIF
				cFiltro += "AND FIF_PARALF = E1_PARCELA "
			Else
				cFiltro += "AND FIF_PARCEL = E1_PARCELA "
			EndIf

			cFiltro += "AND	FIF_CODFIL = E1_FILORIG "
			cFiltro += "AND (FIF_CODAUT = E1_CARTAUT OR FIF_CODAUT = ' ') "
			cFiltro += "AND FIF_TPREG <> '3' " // 3-Ajustes
			cFiltro += "AND FIF_VLLIQ >= (E1_SALDO)  - ((E1_SALDO)  * " + AllTrim(Str(__nMargem)) + " / 100) "
			
			If __lOracle .or. __lPostGre
				cFiltro += "AND SUBSTR(E1_TIPO,2,1) = FIF_TPPROD "
			Else
				cFiltro += "AND SUBSTRING(E1_TIPO,2,1) = FIF_TPPROD "
			EndIf

			cFiltro += "AND " + RetSqlName("SE1") + ".D_E_L_E_T_ = ' '"
			cFiltro += ") "

		Case nFolder == 2		//Conciliados Parcialmente
			cFiltro += "AND FIF_STVEND = '1' "
			cFiltro += "AND EXISTS ( "
			cFiltro += "SELECT E1_NSUTEF, E1_PARCELA "
			cFiltro += "FROM " + RetSqlName("SE1") + " "

			If __lDocTEF
				If __lOracle .Or. __lPostGre
					cFiltro += "WHERE LPAD(TRIM(FIF_NUCOMP), " + __cTamDOC + ", '0') = LPAD(TRIM(E1_DOCTEF), " + __cTamDOC + ", '0') "
				Else
					cFiltro += "WHERE REPLICATE('0', " + __cTamDOC + " - LEN(FIF_NUCOMP)) + RTrim(FIF_NUCOMP) = REPLICATE('0', " + __cTamDOC + " - LEN(E1_DOCTEF)) + RTrim(E1_DOCTEF) "
				EndIf
			Else
				If __lOracle .Or. __lPostGre
					cFiltro += "WHERE LPAD(TRIM(FIF_NSUTEF), " + __cTamNSU + ", '0')  = LPAD(TRIM(E1_NSUTEF), " + __cTamNSU + ", '0') "
				Else
					cFiltro += "WHERE REPLICATE('0', " + __cTamNSU + " - LEN(FIF_NSUTEF)) + RTrim(FIF_NSUTEF) =  REPLICATE('0', " + __cTamNSU + " - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) "
				EndIf
			EndIf

			cFiltro += "AND E1_FILIAL >= ' ' "
			cFiltro += "AND FIF_DTTEF = E1_EMISSAO "

			If __lParcFIF
				cFiltro += "AND FIF_PARALF = E1_PARCELA "
			Else
				cFiltro += "AND FIF_PARCEL = E1_PARCELA "
			EndIf

			cFiltro += "AND	FIF_CODFIL = E1_FILORIG "
			cFiltro += "AND (FIF_CODAUT = E1_CARTAUT OR FIF_CODAUT = ' ') "
			cFiltro += "AND FIF_TPREG <> '3' " // 3-Ajustes
			cFiltro += "AND FIF_VLLIQ < E1_SALDO - (E1_SALDO * " + AllTrim(Str(__nMargem)) + " / 100) "
			
			If __lOracle .or. __lPostGre
				cFiltro += "AND SUBSTR(E1_TIPO,2,1) = FIF_TPPROD "
			Else
				cFiltro += "AND SUBSTRING(E1_TIPO,2,1) = FIF_TPPROD "
			EndIF
			
			cFiltro += "AND " + RetSqlName("SE1") + ".D_E_L_E_T_ = ' '"
			cFiltro += ") "

		Case nFolder == 3		//Titulos sem Vendas (SE1)
			cFiltro += "AND NOT EXISTS ( "
			cFiltro += "SELECT FIF_NSUTEF, FIF_PARALF "
			cFiltro += "FROM " + RetSqlName("FIF") + " "

			If __lUsaMep
				cFiltro += ", " + RetSqlName("MEP") + " MEP "
			EndIf 

			If __lDocTEF
				If __lOracle .Or. __lPostGre
					cFiltro += "WHERE LPAD(TRIM(FIF_NUCOMP), " + __cTamDOC + ", '0') = LPAD(TRIM(E1_DOCTEF), " + __cTamDOC + ", '0') "
				Else
					cFiltro += "WHERE REPLICATE('0', " + __cTamDOC + " - LEN(FIF_NUCOMP)) + RTrim(FIF_NUCOMP) = REPLICATE('0', " + __cTamDOC + " - LEN(E1_DOCTEF)) + RTrim(E1_DOCTEF) "
				EndIf
			Else
				If __lOracle .Or. __lPostGre
					cFiltro += "WHERE LPAD(TRIM(FIF_NSUTEF), " + __cTamNSU + ", '0')  = LPAD(TRIM(E1_NSUTEF), " + __cTamNSU + ", '0') "
				Else
					cFiltro += "WHERE REPLICATE('0', " + __cTamNSU + " - LEN(FIF_NSUTEF)) + RTrim(FIF_NSUTEF) =  REPLICATE('0', " + __cTamNSU + " - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) "
				EndIf
			EndIf	

			cFiltro += "AND E1_FILIAL >= ' ' "
			cFiltro += "AND FIF_DTTEF = E1_EMISSAO "
			cFiltro += "AND	FIF_CODFIL = E1_FILORIG "
			cFiltro += "AND (FIF_CODAUT = E1_CARTAUT OR FIF_CODAUT = ' ') "

			If __lUsaMep
				cFiltro += "AND MEP.MEP_MSFIL  = E1_FILORIG "
				cFiltro += "AND MEP.MEP_PREFIX = E1_PREFIXO "
				cFiltro += "AND MEP.MEP_NUM    = E1_NUM "
				cFiltro += "AND MEP.MEP_PARCEL = E1_PARCELA "
				cFiltro += "AND MEP.MEP_TIPO   = E1_TIPO "
				cFiltro += "AND MEP.D_E_L_E_T_ = ' ' "
				cFiltro += "AND MEP.MEP_PARTEF = " + RetSqlName("FIF") + ".FIF_PARCEL "
			Else
				cFiltro += "AND FIF_PARALF = E1_PARCELA "
			Endif

			cFiltro += "AND FIF_TPREG <> '3' " // 3-Ajustes
			If !Empty(MV_PAR08)
				cFilAdm := FormatIn(Alltrim(MV_PAR08), ";")
				If __lSOFEX
					cFiltro += "AND FIF_CODRED IN " + cFilAdm + " "
				Else
					cFiltro += "AND (FIF_CODADM IN " + cFilAdm + " OR FIF_CODADM = ' ') "
				EndIf
			EndIf
			cFiltro += "AND	" + RetSqlName("FIF") + ".D_E_L_E_T_ = ' ') "
			// Rertira os registros conciliados manualmente
			cFiltro += "AND NOT EXISTS ( SELECT 'TOTVS' FROM " + RetSqlName("FIF") + " AUX "
			If __lUsaMep
				cFiltro += ", " + RetSqlName("MEP") + " MEPAUX "
			EndIf
			cFiltro += " WHERE FIF_DTTEF = E1_EMISSAO "

			If __lUsaMep
				cFiltro += "AND MEPAUX.MEP_MSFIL  = E1_FILORIG "
				cFiltro += "AND MEPAUX.MEP_PREFIX = E1_PREFIXO "
				cFiltro += "AND MEPAUX.MEP_NUM    = E1_NUM "
				cFiltro += "AND MEPAUX.MEP_PARCEL = E1_PARCELA "
				cFiltro += "AND MEPAUX.MEP_TIPO   = E1_TIPO "
				cFiltro += "AND MEPAUX.D_E_L_E_T_ = ' ' "
				cFiltro += "AND MEPAUX.MEP_PARTEF = AUX.FIF_PARCEL "
			Else
				cFiltro += " AND FIF_PARALF = E1_PARCELA "
			Endif		
			cFiltro += " AND FIF_CODFIL = E1_FILORIG "
			cFiltro += " AND FIF_PREFIX = E1_PREFIXO "
			cFiltro += " AND FIF_NUM = E1_NUM "
			cFiltro += " AND FIF_PARC = E1_PARCELA "
			cFiltro += " AND FIF_TIPO = E1_TIPO "
			cFiltro += " AND FIF_STVEND IN ('5','7') "
			cFiltro += " AND AUX.D_E_L_E_T_ = ' ') "

		Case nFolder == 4		//Vendas sem Titulos (FIF)
			Do Case
			Case cAlias == "FIF"
				cFiltro += "AND FIF_STVEND = '1' "
				cFiltro += "AND FIF_TPREG <> '3' " // 3-Ajustes
				cFiltro += "AND NOT EXISTS ( "
				cFiltro += "SELECT E1_NSUTEF, E1_PARCELA "
				
				cFiltro += "FROM " + RetSqlName("SE1") + " "
				If __lUsaMep
					cFiltro += ", " + RetSqlName("MEP") + " MEP "
				Endif

				If __lDocTEF
					If __lOracle .Or. __lPostGre
						cFiltro += "WHERE LPAD(TRIM(FIF_NUCOMP), " + __cTamDOC + ", '0') = LPAD(TRIM(E1_DOCTEF), " + __cTamDOC + ", '0') "
					Else
						cFiltro += "WHERE REPLICATE('0', " + __cTamDOC + " - LEN(FIF_NUCOMP)) + RTrim(FIF_NUCOMP) = REPLICATE('0', " + __cTamDOC + " - LEN(E1_DOCTEF)) + RTrim(E1_DOCTEF) "
					EndIf
				Else
					If __lOracle .Or. __lPostGre
						cFiltro += "WHERE LPAD(TRIM(FIF_NSUTEF), " + __cTamNSU + ", '0')  = LPAD(TRIM(E1_NSUTEF), " + __cTamNSU + ", '0') "
					Else
						cFiltro += "WHERE REPLICATE('0', " + __cTamNSU + " - LEN(FIF_NSUTEF)) + RTrim(FIF_NSUTEF) =  REPLICATE('0', " + __cTamNSU + " - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) "
					EndIf
				EndIf	

				cFiltro += "AND E1_FILIAL >= ' ' "  // Para melhoria de performance em oracle (força o uso de índice)
				cFiltro += "AND E1_EMISSAO = FIF_DTTEF "
				cFiltro += "AND	E1_FILORIG = FIF_CODFIL "
				cFiltro += "AND (FIF_CODAUT = E1_CARTAUT OR FIF_CODAUT = ' ') "

				If __lUsaMep
					cFiltro += "AND MEP_PARCEL = E1_PARCELA "
					cFiltro += "AND MEP_MSFIL  = E1_FILORIG "
					cFiltro += "AND MEP_PREFIX = E1_PREFIXO "
					cFiltro += "AND MEP_NUM    = E1_NUM "
					cFiltro += "AND MEP_TIPO   = E1_TIPO "
					cFiltro += "AND MEP_PARTEF = FIF_PARCEL "
					cFiltro += "AND MEP.D_E_L_E_T_ = ' ' "
				Else
					cFiltro += "AND E1_PARCELA = FIF_PARALF "		
				Endif	

				cFiltro += "AND	" + RetSqlName("SE1") + ".D_E_L_E_T_  = ' ') "

			Case cAlias == "SE1"
				cFiltro += "AND E1_SALDO > 0 "
				cFiltro += "AND NOT EXISTS ( "
				cFiltro += "SELECT FIF_NSUTEF, FIF_PARALF "
				cFiltro += "FROM " + RetSqlName("FIF") + " "

				If __lUsaMep
					cFiltro += ", " + RetSqlName("MEP") + " MEP "
				Endif

				If __lDocTEF
					If __lOracle .Or. __lPostGre
						cFiltro += "WHERE LPAD(TRIM(FIF_NUCOMP), " + __cTamDOC + ", '0') = LPAD(TRIM(E1_DOCTEF), " + __cTamDOC + ", '0') "
					Else
						cFiltro += "WHERE REPLICATE('0', " + __cTamDOC + " - LEN(FIF_NUCOMP)) + RTrim(FIF_NUCOMP) = REPLICATE('0', " + __cTamDOC + " - LEN(E1_DOCTEF)) + RTrim(E1_DOCTEF) "
					EndIf
				Else
					If __lOracle .Or. __lPostGre
						cFiltro += "WHERE LPAD(TRIM(FIF_NSUTEF), " + __cTamNSU + ", '0')  = LPAD(TRIM(E1_NSUTEF), " + __cTamNSU + ", '0') "
					Else
						cFiltro += "WHERE REPLICATE('0', " + __cTamNSU + " - LEN(FIF_NSUTEF)) + RTrim(FIF_NSUTEF) =  REPLICATE('0', " + __cTamNSU + " - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) "
					EndIf
				EndIf		

				cFiltro += "AND E1_FILIAL >= ' ' "
				cFiltro += "AND FIF_DTTEF = E1_EMISSAO "
				cFiltro += "AND	FIF_CODFIL = E1_FILORIG "
				cFiltro += "AND (FIF_CODAUT = E1_CARTAUT OR FIF_CODAUT = ' ') "
				cFiltro += "AND FIF_TPREG <> '3' " // 3-Ajustes

				If __lUsaMep
					cFiltro += "AND MEP_PARCEL = E1_PARCELA "
					cFiltro += "AND MEP_MSFIL  = E1_FILORIG "
					cFiltro += "AND MEP_PREFIX = E1_PREFIXO "
					cFiltro += "AND MEP_NUM    = E1_NUM "
					cFiltro += "AND MEP_PARCEL = E1_PARCELA "
					cFiltro += "AND MEP_TIPO   = E1_TIPO "
					cFiltro += "AND MEP.D_E_L_E_T_ = ' ' "
					cFiltro += "AND MEP.MEP_PARTEF = " + RetSqlName("FIF") + ".FIF_PARCEL "
				Else
					cFiltro += "AND FIF_PARALF = E1_PARCELA "
				Endif	

				If !Empty(MV_PAR08)
					cFilAdm := FormatIn(Alltrim(MV_PAR08), ";")
					If __lSOFEX
						cFiltro += "AND FIF_CODRED IN " + cFilAdm + " "
					Else
						cFiltro += "AND (FIF_CODADM IN " + cFilAdm + " OR FIF_CODADM = ' ') "
					EndIf
				EndIf
				cFiltro += "AND	" + RetSqlName("FIF") + ".D_E_L_E_T_ = ' ') "
				// Rertira os registros conciliados manualmente
				cFiltro += "AND NOT EXISTS ( SELECT 'TOTVS' FROM " + RetSqlName("FIF") + " AUX"
				If __lUsaMep
					cFiltro += ", " + RetSqlName("MEP") + " MEPAUX "
				EndIf

				cFiltro += " WHERE FIF_DTTEF = E1_EMISSAO "

				If __lUsaMep
					cFiltro += "AND MEPAUX.MEP_MSFIL  = E1_FILORIG "
					cFiltro += "AND MEPAUX.MEP_PREFIX = E1_PREFIXO "
					cFiltro += "AND MEPAUX.MEP_NUM    = E1_NUM "
					cFiltro += "AND MEPAUX.MEP_PARCEL = E1_PARCELA "
					cFiltro += "AND MEPAUX.MEP_TIPO   = E1_TIPO "
					cFiltro += "AND MEPAUX.D_E_L_E_T_ = ' ' "
					cFiltro += "AND MEPAUX.MEP_PARTEF = AUX.FIF_PARCEL "
				Else
					cFiltro += " AND FIF_PARALF = E1_PARCELA "
				Endif		
				cFiltro += " AND FIF_CODFIL = E1_FILORIG "
				cFiltro += " AND FIF_PREFIX = E1_PREFIXO "
				cFiltro += " AND FIF_NUM = E1_NUM "
				cFiltro += " AND FIF_PARC = E1_PARCELA "
				cFiltro += " AND FIF_TIPO = E1_TIPO "
				cFiltro += " AND FIF_STVEND IN ('5','7') "
				cFiltro += " AND AUX.D_E_L_E_T_ = ' ') "

			EndCase

		Case nFolder == 5		//Divergentes
			cFiltro += "AND FIF_STVEND = '1' "
			cFiltro += "AND ( FIF_TPREG = '3' OR ( "
			cFiltro += "EXISTS ( "
			cFiltro += "SELECT E1_NSUTEF, E1_PARCELA "
			cFiltro += "FROM " + RetSqlName("SE1") + " "
			If __lUsaMep
				cFiltro += ", " + RetSqlName("MEP") + " MEP "
			EndIf

			If __lDocTEF
				If __lOracle .Or. __lPostGre
					cFiltro += "WHERE LPAD(TRIM(FIF_NUCOMP), " + __cTamDOC + ", '0') = LPAD(TRIM(E1_DOCTEF), " + __cTamDOC + ", '0') "
				Else
					cFiltro += "WHERE REPLICATE('0', " + __cTamDOC + " - LEN(FIF_NUCOMP)) + RTrim(FIF_NUCOMP) = REPLICATE('0', " + __cTamDOC + " - LEN(E1_DOCTEF)) + RTrim(E1_DOCTEF) "
				EndIf
			Else
				If __lOracle .Or. __lPostGre
					cFiltro += "WHERE LPAD(TRIM(FIF_NSUTEF), " + __cTamNSU + ", '0')  = LPAD(TRIM(E1_NSUTEF), " + __cTamNSU + ", '0') "
				Else
					cFiltro += "WHERE REPLICATE('0', " + __cTamNSU + " - LEN(FIF_NSUTEF)) + RTrim(FIF_NSUTEF) =  REPLICATE('0', " + __cTamNSU + " - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) "
				EndIf
			Endif	

			cFiltro += "AND E1_FILIAL >= ' ' "
			cFiltro += "  AND E1_EMISSAO = FIF_DTTEF "

			If __lUsaMep
				cFiltro += "AND MEP_PARCEL = E1_PARCELA "
				cFiltro += "AND MEP_MSFIL  = E1_FILORIG "
				cFiltro += "AND MEP_PREFIX = E1_PREFIXO "
				cFiltro += "AND MEP_NUM    = E1_NUM "
				cFiltro += "AND MEP_PARCEL = E1_PARCELA "
				cFiltro += "AND MEP_TIPO   = E1_TIPO "
				cFiltro += "AND MEP.D_E_L_E_T_ = ' ' "
				cFiltro += "AND MEP.MEP_PARTEF = FIF_PARCEL "
			Else
				cFiltro += "  AND E1_PARCELA = FIF_PARALF "
			Endif

			cFiltro += "  AND E1_FILORIG = FIF_CODFIL "
			If __lOracle .or. __lPostGre
				cFiltro += "AND SUBSTR(E1_TIPO,2,1) <> FIF_TPPROD "
			Else
				cFiltro += "AND SUBSTRING(E1_TIPO,2,1) <> FIF_TPPROD "
			EndIF
			cFiltro += " AND	" + RetSqlName("SE1") + ".D_E_L_E_T_  = ' ') ) )  "
			cFiltro += " AND 1 = 1 " // Instrução colocada para prevenção de error.log do Frame na chamada SetLoadFilter
		EndCase
	EndIf

	Return cFiltro


	//-------------------------------------------------------------------
	/*/{Protheus.doc} StrHead
	Retorna a Estrutura do Cabecalho

	@author Guilherme Santos
	@since 09/02/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function StrHead( nTipo As Numeric ) As Object
	Local oStruct	As Object
	Local nLenSt	As Numeric

	Do Case
	Case nTipo == 1
		oStruct	:= FWFormModelStruct():New()

		nLenSt := TamSX3("FIF_STVEND")[1]

		//Tabela
		oStruct:AddTable("TMP" ,{"STATUS"}, "Cabecalho")	//Campos do cabeçalho do TMP

		//Campos
		oStruct:AddField(	"STATUS"	,; 	// [01] C Titulo do campo
		"STATUS"	,; 	// [02] C ToolTip do campo
		"STATUS"	,; 	// [03] C identificador (ID) do Field
		"C" 		,; 	// [04] C Tipo do campo
		nLenSt		,; 	// [05] N Tamanho do campo
		0 			,; 	// [06] N Decimal do campo
		Nil 		,; 	// [07] B Code-block de validação do campo
		Nil			,; 	// [08] B Code-block de validação When do campo
		Nil 		,; 	// [09] A Lista de valores permitido do campo
		Nil 		,;	// [10] L Indica se o campo tem preenchimento obrigatório
		Nil			,; 	// [11] B Code-block de inicializacao do campo
		Nil 		,;	// [12] L Indica se trata de um campo chave
		.F.		 	,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
		.F.			)	// [14] L Indica se o campo é virtual

	Case nTipo == 2
		oStruct	:= FWFormViewStruct():New()

		oStruct:AddField(	"STATUS"	,;	// [01]  C   Nome do Campo
		"01"		,;	// [02]  C   Ordem
		"STATUS"	,;	// [03]  C   Titulo do campo
		"STATUS"	,;	// [04]  C   Descricao do campo
		NIL			,;	// [05]  A   Array com Help
		"C"			,;	// [06]  C   Tipo do campo
		NIL			,;	// [07]  C   Picture
		NIL			,;	// [08]  B   Bloco de Picture Var
		NIL			,;	// [09]  C   Consulta F3
		.F.			,;	// [10]  L   Indica se o campo é alteravel
		NIL			,;	// [11]  C   Pasta do campo
		NIL			,;	// [12]  C   Agrupamento do campo
		NIL			,;	// [13]  A   Lista de valores permitido do campo (Combo)
		NIL			,;	// [14]  N   Tamanho maximo da maior opção do combo
		NIL			,;	// [15]  C   Inicializador de Browse
		.F.			,;	// [16]  L   Indica se o campo é virtual
		NIL			,;	// [17]  C   Picture Variavel
		NIL			)	// [18]  L   Indica pulo de linha após o campo
	EndCase

	Return oStruct

	//-------------------------------------------------------------------
	/*/{Protheus.doc} StrTot
	Retorna a Estrutura do Cabecalho

	@author Guilherme Santos
	@since 01/03/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function StrTot( nTipo As Numeric ) As Object
	Local oStruct	As Object
	Local cPicture	As Character
	Local cOrdem	As Character
	Local nLenVlr	As Numeric
	Local nDecVlr	As Numeric
	Local nLenQtd	As Numeric

	cPicture	:= PesqPict("SE1", "E1_VALOR")
	cOrdem		:= "00"
	nLenVlr		:= TamSX3("E1_VALOR")[1]
	nDecVlr		:= TamSX3("E1_VALOR")[2]
	nLenQtd		:= 09

	Do Case
	Case nTipo == 1
		oStruct	:= FWFormModelStruct():New()

		//Tabela
		oStruct:AddTable("TOTAIS" ,{"DTAVEND"}, STR0016)	//Campos do cabeçalho do TMP	//"Totais"

		//Campos
		oStruct:AddField(STR0022, STR0022, "DTAVEND", "D", 8, 0, NIL, NIL, NIL, NIL, {|| dDatabase}, NIL, .F., .F.)	//"Data Venda"
		If __nFldPar == 0 .OR. __nFldPar == 1
			oStruct:AddField(STR0023, STR0023,  "TOTFLD1", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Tot. Conc."
			oStruct:AddField(STR0054, STR0054,  "LIQFLD1", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Tot. Liq. Conc."
			oStruct:AddField(STR0024, STR0024,  "QTDFLD1", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Qt.Conc."
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 2
			oStruct:AddField(STR0025, STR0025,  "TOTFLD2", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Tot. Parcial"
			oStruct:AddField(STR0055, STR0055,  "LIQFLD2", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Tot. Liq. Parcial"
			oStruct:AddField(STR0026, STR0026,  "QTDFLD2", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Qt. Parcial"
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 3
			oStruct:AddField(STR0027, STR0027,  "TOTFLD3", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Tot. sem Venda"
			oStruct:AddField(STR0056, STR0056,  "LIQFLD3", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Tot. Liq. sem Venda"
			oStruct:AddField(STR0028, STR0028,  "QTDFLD3", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Qt. sem Venda"
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 4
			oStruct:AddField(STR0029, STR0029,  "TOTFLD4", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Tot. sem Tit."
			oStruct:AddField(STR0057, STR0057,  "LIQFLD4", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Tot. Liq. sem Tit."
			oStruct:AddField(STR0030, STR0030,  "QTDFLD4", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Qt. sem Tit."
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 5
			oStruct:AddField(STR0031, STR0031,  "TOTFLD5", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Tot. Diverg."
			oStruct:AddField(STR0058, STR0058,  "LIQFLD5", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Tot. Liq. Diverg."
			oStruct:AddField(STR0032, STR0032,  "QTDFLD5", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Qt.  Diverg."
		EndIf

		//Indices
		oStruct:AddIndex(1, "01", "DTAVEND", STR0022, "", "", .T.)		//"Data Venda"
	Case nTipo == 2
		oStruct	:= FWFormViewStruct():New()

		oStruct:AddField("DTAVEND",fSoma1(@cOrdem),STR0022,STR0022,NIL,"D",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)		//"Data Venda"
		If __nFldPar == 0 .OR. __nFldPar == 1
			oStruct:AddField("TOTFLD1",fSoma1(@cOrdem),STR0023,STR0023,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Tot. Conc."
			oStruct:AddField("LIQFLD1",fSoma1(@cOrdem),STR0054,STR0054,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Tot. Liq. Conc."
			oStruct:AddField("QTDFLD1",fSoma1(@cOrdem),STR0024,STR0024,NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qt. Conc."
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 2
			oStruct:AddField("TOTFLD2",fSoma1(@cOrdem),STR0025,STR0025,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)	//"Tot. Parcial"
			oStruct:AddField("LIQFLD2",fSoma1(@cOrdem),STR0055,STR0055,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)	//"Tot. Liq. Parcial"
			oStruct:AddField("QTDFLD2",fSoma1(@cOrdem),STR0026,STR0026,NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)			//"Qt. Parcial"
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 3
			oStruct:AddField("TOTFLD3",fSoma1(@cOrdem),STR0027,STR0027,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Tot. sem Venda"
			oStruct:AddField("LIQFLD3",fSoma1(@cOrdem),STR0056,STR0056,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Tot. Liq. sem Venda"
			oStruct:AddField("QTDFLD3",fSoma1(@cOrdem),STR0028,STR0028,NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qt. sem Venda"
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 4
			oStruct:AddField("TOTFLD4",fSoma1(@cOrdem),STR0029,STR0029,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Tot. sem Tit."
			oStruct:AddField("LIQFLD4",fSoma1(@cOrdem),STR0057,STR0057,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Tot. Liq. sem Tit."
			oStruct:AddField("QTDFLD4",fSoma1(@cOrdem),STR0030,STR0030,NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qt. sem Tit."
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 5
			oStruct:AddField("TOTFLD5",fSoma1(@cOrdem),STR0031,STR0031,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Tot. Diverg."
			oStruct:AddField("LIQFLD5",fSoma1(@cOrdem),STR0058,STR0058,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Tot. Liq. Diverg."
			oStruct:AddField("QTDFLD5",fSoma1(@cOrdem),STR0032,STR0032,NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qt. Diverg."
		EndIf
	EndCase

	Return oStruct

	//-------------------------------------------------------------------
	/*/{Protheus.doc} fSoma1
	Soma da Ordem dos Campos

	@author Guilherme Santos
	@since 02/03/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function fSoma1( cOrdem As Character ) As Character
	cOrdem := Soma1( cOrdem )
	Return cOrdem

	//-------------------------------------------------------------------
	/*/{Protheus.doc} AddField
	Inclusao dos Campos de Selecao dos Registros

	@author Guilherme Santos
	@since 09/02/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function AddField( nOpcao As Numeric, oStruct As Object, bValid As Codeblock, nFolder as Numeric )
	Local bBlock As Codeblock
	
	Default bValid 	:= NIL
	Default nFolder := 0

	bBlock := {||REPLICATE('0', __nTamNSU - LEN(Rtrim(FIF->FIF_NSUTEF))) + RTrim(FIF->FIF_NSUTEF)}

	Do Case
	Case nOpcao == 1	//Model
		If nFolder == 1 .OR. nFolder == 2
			oStruct:AddField(		STR0010						,;	//[01]  C   Titulo do campo		//"Conciliar"
			STR0010						,;	//[02]  C   ToolTip do campo	//"Conciliar"
			"OK"						,;	//[03]  C   Id do Field
			"L"							,;	//[04]  C   Tipo do campo
			1							,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
			0							,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
			bValid						,;	//[07]  B   Code-block de validação do campo
			NIL							,;	//[08]  B   Code-block de validação When do campo
			NIL							,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
			.F.							,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
			{||.T.}						,;	//[11]  B   Code-block de inicializacao do campo
			.F.							,;	//[12]  L   Indica se trata-se de um campo chave
			.F.							,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
			.F.							)	//[14]  L   Indica se o campo é virtual
		Else
			oStruct:AddField(		STR0010						,;	//[01]  C   Titulo do campo		//"Conciliar"
			STR0010						,;	//[02]  C   ToolTip do campo	//"Conciliar"
			"OK"						,;	//[03]  C   Id do Field
			"L"							,;	//[04]  C   Tipo do campo
			1							,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
			0							,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
			bValid						,;	//[07]  B   Code-block de validação do campo
			NIL							,;	//[08]  B   Code-block de validação When do campo
			NIL							,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
			.F.							,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
			NIL							,;	//[11]  B   Code-block de inicializacao do campo
			.F.							,;	//[12]  L   Indica se trata-se de um campo chave
			.F.							,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
			.F.							)	//[14]  L   Indica se o campo é virtual
		EndIf

		If nFolder == 1 .Or. nFolder == 2
			oStruct:AddField(	STR0067							,;	//[01]  C   Titulo do campo
			STR0067							,;	//[02]  C   ToolTip do campo
			"E1_XVLRTEF"					,;	//[03]  C   Id do Field
			"N"								,;	//[04]  C   Tipo do campo
			TAMSX3("FIF_VLLIQ")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
			TAMSX3("FIF_VLLIQ")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
			Nil								,;	//[07]  B   Code-block de validação do campo
			NIL								,;	//[08]  B   Code-block de validação When do campo
			NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
			.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
			{||FIF->FIF_VLLIQ}			    ,;	//[11]  B   Code-block de inicializacao do campo
			.F.								,;	//[12]  L   Indica se trata-se de um campo chave
			.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
			.T.								)	//[14]  L   Indica se o campo é virtual

			oStruct:AddField(	AllTrim(RetTitle("E1_FILORIG"))	,;	//[01]  C   Titulo do campo
			AllTrim(RetTitle("E1_FILORIG"))	,;	//[02]  C   ToolTip do campo
			"E1_XFILORI"					,;	//[03]  C   Id do Field
			TAMSX3("E1_FILORIG")[3]			,;	//[04]  C   Tipo do campo
			TAMSX3("E1_FILORIG")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
			TAMSX3("E1_FILORIG")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
			Nil								,;	//[07]  B   Code-block de validação do campo
			NIL								,;	//[08]  B   Code-block de validação When do campo
			NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
			.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
			{||SE1->E1_FILORIG}				,;	//[11]  B   Code-block de inicializacao do campo
			.F.								,;	//[12]  L   Indica se trata-se de um campo chave
			.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
			.T.								)	//[14]  L   Indica se o campo é virtual

			oStruct:AddField(	STR0010							,;	//[01]  C   Titulo do campo
			STR0010							,;	//[02]  C   ToolTip do campo
			"Conciliar"						,;	//[03]  C   Id do Field
			TAMSX3("E1_LOJA")[3]			,;	//[04]  C   Tipo do campo
			TAMSX3("E1_LOJA")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
			TAMSX3("E1_LOJA")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
			Nil								,;	//[07]  B   Code-block de validação do campo
			NIL								,;	//[08]  B   Code-block de validação When do campo
			NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
			.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
			NIL								,;	//[11]  B   Code-block de inicializacao do campo
			.F.								,;	//[12]  L   Indica se trata-se de um campo chave
			.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
			.T.								)	//[14]  L   Indica se o campo é virtual

			oStruct:AddField(	AllTrim(RetTitle("E1_SALDO"))	,;	//[01]  C   Titulo do campo
			AllTrim(RetTitle("E1_SALDO"))	,;	//[02]  C   ToolTip do campo
			"E1_XSALDO"						,;	//[03]  C   Id do Field
			"N"								,;	//[04]  C   Tipo do campo
			TAMSX3("E1_SALDO")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
			TAMSX3("E1_SALDO")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
			Nil								,;	//[07]  B   Code-block de validação do campo
			NIL								,;	//[08]  B   Code-block de validação When do campo
			NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
			.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
			{||SE1->E1_SALDO}			    ,;	//[11]  B   Code-block de inicializacao do campo
			.F.								,;	//[12]  L   Indica se trata-se de um campo chave
			.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
			.T.								)

			If __lUsaMep
				oStruct:AddField(	AllTrim(RetTitle("MEP_PARCEL"))	,;	//[01]  C   Titulo do campo
				AllTrim(RetTitle("MEP_PARCEL"))	,;	//[02]  C   ToolTip do campo
				"MEP_XPARCEL"					,;	//[03]  C   Id do Field
				"C"								,;	//[04]  C   Tipo do campo
				TAMSX3("MEP_PARCEL")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
				TAMSX3("MEP_PARCEL")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
				Nil								,;	//[07]  B   Code-block de validação do campo
				NIL								,;	//[08]  B   Code-block de validação When do campo
				NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
				.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
				{||MEP_PARCEL}			    	,;	//[11]  B   Code-block de inicializacao do campo
				.F.								,;	//[12]  L   Indica se trata-se de um campo chave
				.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
				.T.								)
			Endif

			oStruct:AddField(	AllTrim(RetTitle("E1_VLRREAL"))	,;	//[01]  C   Titulo do campo
			AllTrim(RetTitle("E1_VLRREAL"))	,;	//[02]  C   ToolTip do campo
			"E1_XVLRREAL"					,;	//[03]  C   Id do Field
			"N"								,;	//[04]  C   Tipo do campo
			TAMSX3("E1_VLRREAL")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
			TAMSX3("E1_VLRREAL")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
			Nil								,;	//[07]  B   Code-block de validação do campo
			NIL								,;	//[08]  B   Code-block de validação When do campo
			NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
			.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
			{||SE1->E1_VLRREAL}			    ,;	//[11]  B   Code-block de inicializacao do campo
			.F.								,;	//[12]  L   Indica se trata-se de um campo chave
			.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
			.T.								)

			oStruct:AddField(	AllTrim(RetTitle("E1_CARTAUT"))	,;	//[01]  C   Titulo do campo
			AllTrim(RetTitle("E1_CARTAUT"))	,;	//[02]  C   ToolTip do campo
			"E1_XCARTAUT"					,;	//[03]  C   Id do Field
			"C"								,;	//[04]  C   Tipo do campo
			TAMSX3("E1_CARTAUT")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
			TAMSX3("E1_CARTAUT")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
			Nil								,;	//[07]  B   Code-block de validação do campo
			NIL								,;	//[08]  B   Code-block de validação When do campo
			NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
			.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
			{||SE1->E1_CARTAUT}			    ,;	//[11]  B   Code-block de inicializacao do campo
			.F.								,;	//[12]  L   Indica se trata-se de um campo chave
			.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
			.T.								)

			oStruct:AddField(	AllTrim(RetTitle("XNSUTEF"))	,;	//[01]  C   Titulo do campo
			AllTrim(RetTitle("XNSUTEF"))	,;	//[02]  C   ToolTip do campo
			"XNSUTEF"						,;	//[03]  C   Id do Field
			"C"								,;	//[04]  C   Tipo do campo
			__nTamNSU		    			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
			__nTamNSU	    				,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
			Nil								,;	//[07]  B   Code-block de validação do campo
			NIL								,;	//[08]  B   Code-block de validação When do campo
			NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
			.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
			bBlock						    ,;	//[11]  B   Code-block de inicializacao do campo
			.F.								,;	//[12]  L   Indica se trata-se de um campo chave
			.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
			.T.								)	

		Elseif nFolder == 3 .Or. nFolder == 4
			oStruct:AddField(		STR0040						,;	//[01]  C   Titulo do campo //"Vlr Liquido"
			STR0040						,;	//[02]  C   ToolTip do campo "Vlr Liquido"
			"E1_XVALLIQ"				,;	//[03]  C   Id do Field
			"N"							,;	//[04]  C   Tipo do campo
			TAMSX3("E1_SALDO")[1]		,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
			TAMSX3("E1_SALDO")[2]		,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
			Nil							,;	//[07]  B   Code-block de validação do campo
			NIL							,;	//[08]  B   Code-block de validação When do campo
			NIL							,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
			.F.							,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
			{||SE1->E1_SALDO}			,;	//[11]  B   Code-block de inicializacao do campo
			.F.							,;	//[12]  L   Indica se trata-se de um campo chave
			.F.							,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
			.T.							)	//[14]  L   Indica se o campo é virtual

			oStruct:AddField(		AllTrim(RetTitle("E1_FILORIG"))	,;	//[01]  C   Titulo do campo
			AllTrim(RetTitle("E1_FILORIG"))	,;	//[02]  C   ToolTip do campo
			"E1_XFILORI"					,;	//[03]  C   Id do Field
			TAMSX3("E1_FILORIG")[3]			,;	//[04]  C   Tipo do campo
			TAMSX3("E1_FILORIG")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
			TAMSX3("E1_FILORIG")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
			Nil								,;	//[07]  B   Code-block de validação do campo
			NIL								,;	//[08]  B   Code-block de validação When do campo
			NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
			.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
			{||SE1->E1_FILORIG}				,;	//[11]  B   Code-block de inicializacao do campo
			.F.								,;	//[12]  L   Indica se trata-se de um campo chave
			.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
			.T.								)	//[14]  L   Indica se o campo é virtual

			oStruct:AddField(	AllTrim(RetTitle("E1_SALDO"))	,;	//[01]  C   Titulo do campo
			AllTrim(RetTitle("E1_SALDO"))	,;	//[02]  C   ToolTip do campo
			"E1_XSALDO"						,;	//[03]  C   Id do Field
			"N"								,;	//[04]  C   Tipo do campo
			TAMSX3("E1_SALDO")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
			TAMSX3("E1_SALDO")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
			Nil								,;	//[07]  B   Code-block de validação do campo
			NIL								,;	//[08]  B   Code-block de validação When do campo
			NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
			.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
			{||SE1->E1_SALDO}			    ,;	//[11]  B   Code-block de inicializacao do campo
			.F.								,;	//[12]  L   Indica se trata-se de um campo chave
			.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
			.T.								)

			oStruct:AddField(	AllTrim(RetTitle("E1_VLRREAL"))	,;	//[01]  C   Titulo do campo
			AllTrim(RetTitle("E1_VLRREAL"))	,;	//[02]  C   ToolTip do campo
			"E1_XVLRREAL"						,;	//[03]  C   Id do Field
			"N"								,;	//[04]  C   Tipo do campo
			TAMSX3("E1_VLRREAL")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
			TAMSX3("E1_VLRREAL")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
			Nil								,;	//[07]  B   Code-block de validação do campo
			NIL								,;	//[08]  B   Code-block de validação When do campo
			NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
			.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
			{||SE1->E1_VLRREAL}			    ,;	//[11]  B   Code-block de inicializacao do campo
			.F.								,;	//[12]  L   Indica se trata-se de um campo chave
			.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
			.T.								)

			oStruct:AddField(	AllTrim(RetTitle("E1_CARTAUT"))	,;	//[01]  C   Titulo do campo
			AllTrim(RetTitle("E1_CARTAUT"))	,;	//[02]  C   ToolTip do campo
			"E1_XCARTAUT"					,;	//[03]  C   Id do Field
			"C"								,;	//[04]  C   Tipo do campo
			TAMSX3("E1_CARTAUT")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
			TAMSX3("E1_CARTAUT")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
			Nil								,;	//[07]  B   Code-block de validação do campo
			NIL								,;	//[08]  B   Code-block de validação When do campo
			NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
			.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
			{||SE1->E1_CARTAUT}			    ,;	//[11]  B   Code-block de inicializacao do campo
			.F.								,;	//[12]  L   Indica se trata-se de um campo chave
			.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
			.T.								)

			If nFolder == 3
				oStruct:AddField(	AllTrim(RetTitle("FIF_CODJUS"))	,;	//[01]  C   Titulo do campo
				AllTrim(RetTitle("FIF_CODJUS"))	,;	//[02]  C   ToolTip do campo
				"FIF_XCODJU"					,;	//[03]  C   Id do Field
				TAMSX3("FIF_CODJUS")[3]			,;	//[04]  C   Tipo do campo
				TAMSX3("FIF_CODJUS")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
				TAMSX3("FIF_CODJUS")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
				NIL								,;	//[07]  B   Code-block de validação do campo
				NIL								,;	//[08]  B   Code-block de validação When do campo
				NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
				.T.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
				NIL								,;	//[11]  B   Code-block de inicializacao do campo
				.F.								,;	//[12]  L   Indica se trata-se de um campo chave
				.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
				.F.								)	//[14]  L   Indica se o campo é virtual

				oStruct:AddField(	AllTrim(RetTitle("FIF_DESJUS"))	,;	//[01]  C   Titulo do campo
				AllTrim(RetTitle("FIF_DESJUS"))	,;	//[02]  C   ToolTip do campo
				"FIF_XDESJU"					,;	//[03]  C   Id do Field
				TAMSX3("FIF_DESJUS")[3]			,;	//[04]  C   Tipo do campo
				TAMSX3("FIF_DESJUS")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
				TAMSX3("FIF_DESJUS")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
				NIL								,;	//[07]  B   Code-block de validação do campo
				NIL								,;	//[08]  B   Code-block de validação When do campo
				NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
				.T.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
				NIL								,;	//[11]  B   Code-block de inicializacao do campo
				.F.								,;	//[12]  L   Indica se trata-se de um campo chave
				.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
				.F.								)	//[14]  L   Indica se o campo é virtual

				oStruct:AddField(	AllTrim(RetTitle("FIF_DESJUT"))	,;	//[01]  C   Titulo do campo
				AllTrim(RetTitle("FIF_DESJUT"))	,;	//[02]  C   ToolTip do campo
				"FIF_XDESJT"					,;	//[03]  C   Id do Field
				TAMSX3("FIF_DESJUT")[3]			,;	//[04]  C   Tipo do campo
				TAMSX3("FIF_DESJUT")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
				TAMSX3("FIF_DESJUT")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
				NIL								,;	//[07]  B   Code-block de validação do campo
				NIL								,;	//[08]  B   Code-block de validação When do campo
				NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
				.T.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
				NIL								,;	//[11]  B   Code-block de inicializacao do campo
				.F.								,;	//[12]  L   Indica se trata-se de um campo chave
				.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
				.F.								)	//[14]  L   Indica se o campo é virtual


			EndIf
		EndIf

	Case nOpcao == 2	//View
		oStruct:AddField(	"OK"							,;	// [01]  C   Nome do Campo
		"01"							,;	// [02]  C   Ordem
		STR0010							,;	// [03]  C   Titulo do campo		//"Conciliar"
		STR0010							,;	// [04]  C   Descricao do campo		//"Conciliar"
		NIL								,;	// [05]  A   Array com Help
		"Check"							,;	// [06]  C   Tipo do campo
		NIL								,;	// [07]  C   Picture
		NIL								,;	// [08]  B   Bloco de Picture Var
		NIL								,;	// [09]  C   Consulta F3
		NIL								,;	// [10]  L   Indica se o campo é alteravel
		NIL								,;	// [11]  C   Pasta do campo
		NIL								,;	// [12]  C   Agrupamento do campo
		NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
		NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
		NIL								,;	// [15]  C   Inicializador de Browse
		NIL								,;	// [16]  L   Indica se o campo é virtual
		NIL								,;	// [17]  C   Picture Variavel
		NIL								)	// [18]  L   Indica pulo de linha após o campo

		If nFolder == 1 .Or. nFolder == 2
			oStruct:AddField(	"E1_XVLRTEF"								,;	// [01]  C   Nome do Campo
			Alltrim(Str(SE1->(FieldPos("E1_NSUTEF"))+1)),;	// [02]  C   Ordem
			STR0067 									,;	// [03]  C   Titulo do campo
			STR0067 									,;	// [04]  C   Descricao do campo
			NIL											,;	// [05]  A   Array com Help
			"N"											,;	// [06]  C   Tipo do campo
			PesqPict("FIF", "FIF_VLLIQ")					,;	// [07]  C   Picture
			NIL											,;	// [08]  B   Bloco de Picture Var
			NIL											,;	// [09]  C   Consulta F3
			.F.											,;	// [10]  L   Indica se o campo é alteravel
			NIL											,;	// [11]  C   Pasta do campo
			NIL											,;	// [12]  C   Agrupamento do campo
			NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
			NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL											,;	// [15]  C   Inicializador de Browse
			.T.											,;	// [16]  L   Indica se o campo é virtual
			NIL											,;	// [17]  C   Picture Variavel
			NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"E1_XFILORI"								,;	// [01]  C   Nome do Campo
			Alltrim(Str(SE1->(FieldPos("E1_NSUTEF"))+1)),;	// [02]  C   Ordem
			AllTrim(RetTitle("E1_FILORIG"))				,;	// [03]  C   Titulo do campo
			AllTrim(RetTitle("E1_FILORIG"))				,;	// [04]  C   Descricao do campo
			NIL											,;	// [05]  A   Array com Help
			TAMSX3("E1_FILORIG")[3]						,;	// [06]  C   Tipo do campo
			NIL											,;	// [07]  C   Picture
			NIL											,;	// [08]  B   Bloco de Picture Var
			NIL											,;	// [09]  C   Consulta F3
			.F.											,;	// [10]  L   Indica se o campo é alteravel
			NIL											,;	// [11]  C   Pasta do campo
			NIL											,;	// [12]  C   Agrupamento do campo
			NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
			NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL											,;	// [15]  C   Inicializador de Browse
			.T.											,;	// [16]  L   Indica se o campo é virtual
			NIL											,;	// [17]  C   Picture Variavel
			NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"E1_XSALDO"				,;	// [01]  C   Nome do Campo
			Alltrim(Str(SE1->(FieldPos("E1_SALDO"))+1)),;	// [02]  C   Ordem
			AllTrim(RetTitle("E1_SALDO"))				,;	// [03]  C   Titulo do campo
			AllTrim(RetTitle("E1_SALDO"))				,;	// [04]  C   Descricao do campo
			NIL											,;	// [05]  A   Array com Help
			"N"											,;	// [06]  C   Tipo do campo
			PesqPict("SE1", "E1_SALDO")					,;	// [07]  C   Picture
			NIL											,;	// [08]  B   Bloco de Picture Var
			NIL											,;	// [09]  C   Consulta F3
			.F.											,;	// [10]  L   Indica se o campo é alteravel
			NIL											,;	// [11]  C   Pasta do campo
			NIL											,;	// [12]  C   Agrupamento do campo
			NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
			NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL											,;	// [15]  C   Inicializador de Browse
			.T.											,;	// [16]  L   Indica se o campo é virtual
			NIL											,;	// [17]  C   Picture Variavel
			NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"XNSUTEF"				,;	// [01]  C   Nome do Campo
			Alltrim(Str(SE1->(FieldPos("FIF_NSUTEF"))+1)),;	// [02]  C   Ordem
			AllTrim(RetTitle("FIF_NSUTEF"))				,;	// [03]  C   Titulo do campo
			AllTrim(RetTitle("FIF_NSUTEF"))				,;	// [04]  C   Descricao do campo
			NIL											,;	// [05]  A   Array com Help
			"C"											,;	// [06]  C   Tipo do campo
			NIL											,;	// [07]  C   Picture
			NIL											,;	// [08]  B   Bloco de Picture Var
			NIL											,;	// [09]  C   Consulta F3
			.F.											,;	// [10]  L   Indica se o campo é alteravel
			NIL											,;	// [11]  C   Pasta do campo
			NIL											,;	// [12]  C   Agrupamento do campo
			NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
			NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL											,;	// [15]  C   Inicializador de Browse
			.T.											,;	// [16]  L   Indica se o campo é virtual
			NIL											,;	// [17]  C   Picture Variavel
			NIL											)	// [18]  L   Indica pulo de linha após o campo

			If __lUsaMep	
				oStruct:AddField(	"MEP_XPARCEL"			,;	// [01]  C   Nome do Campo
				Alltrim(Str(MEP->(FieldPos("MEP_PARCEL"))+1)),;	// [02]  C   Ordem
				AllTrim(RetTitle("MEP_PARCEL"))				,;	// [03]  C   Titulo do campo
				AllTrim(RetTitle("MEP_PARCEL"))				,;	// [04]  C   Descricao do campo
				NIL											,;	// [05]  A   Array com Help
				"C"											,;	// [06]  C   Tipo do campo
				PesqPict("MEP", "MEP_PARCEL")				,;	// [07]  C   Picture
				NIL											,;	// [08]  B   Bloco de Picture Var
				NIL											,;	// [09]  C   Consulta F3
				.F.											,;	// [10]  L   Indica se o campo é alteravel
				NIL											,;	// [11]  C   Pasta do campo
				NIL											,;	// [12]  C   Agrupamento do campo
				NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL											,;	// [15]  C   Inicializador de Browse
				.T.											,;	// [16]  L   Indica se o campo é virtual
				NIL											,;	// [17]  C   Picture Variavel
				NIL											)	// [18]  L   Indica pulo de linha após o campo
			Endif	

			oStruct:AddField(	"E1_XVLRREAL"				,;	// [01]  C   Nome do Campo
			Alltrim(Str(SE1->(FieldPos("E1_VLRREAL"))+1)),;	// [02]  C   Ordem
			AllTrim(RetTitle("E1_VLRREAL"))				,;	// [03]  C   Titulo do campo
			AllTrim(RetTitle("E1_VLRREAL"))				,;	// [04]  C   Descricao do campo
			NIL											,;	// [05]  A   Array com Help
			"N"											,;	// [06]  C   Tipo do campo
			PesqPict("SE1", "E1_SALDO")					,;	// [07]  C   Picture
			NIL											,;	// [08]  B   Bloco de Picture Var
			NIL											,;	// [09]  C   Consulta F3
			.F.											,;	// [10]  L   Indica se o campo é alteravel
			NIL											,;	// [11]  C   Pasta do campo
			NIL											,;	// [12]  C   Agrupamento do campo
			NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
			NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL											,;	// [15]  C   Inicializador de Browse
			.T.											,;	// [16]  L   Indica se o campo é virtual
			NIL											,;	// [17]  C   Picture Variavel
			NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"Conciliar"									,;	// [01]  C   Nome do Campo
			"01"										,;	// [02]  C   Ordem
			STR0010 									,;	// [03]  C   Titulo do campo
			STR0010										,;	// [04]  C   Descricao do campo
			NIL											,;	// [05]  A   Array com Help
			TAMSX3("E1_LOJA")[3]						,;	// [06]  C   Tipo do campo
			NIL											,;	// [07]  C   Picture
			NIL											,;	// [08]  B   Bloco de Picture Var
			NIL											,;	// [09]  C   Consulta F3
			.F.											,;	// [10]  L   Indica se o campo é alteravel
			NIL											,;	// [11]  C   Pasta do campo
			NIL											,;	// [12]  C   Agrupamento do campo
			NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
			NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL											,;	// [15]  C   Inicializador de Browse
			.T.											,;	// [16]  L   Indica se o campo é virtual
			NIL											,;	// [17]  C   Picture Variavel
			NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"E1_XCARTAUT"								,;	// [01]  C   Nome do Campo
			Alltrim(Str(SE1->(FieldPos("E1_CARTAUT"))+1)),;	// [02]  C   Ordem
			AllTrim(RetTitle("E1_CARTAUT"))				,;	// [03]  C   Titulo do campo
			AllTrim(RetTitle("E1_CARTAUT"))				,;	// [04]  C   Descricao do campo
			NIL											,;	// [05]  A   Array com Help
			"C"											,;	// [06]  C   Tipo do campo
			PesqPict("SE1", "E1_CARTAUT")				,;	// [07]  C   Picture
			NIL											,;	// [08]  B   Bloco de Picture Var
			NIL											,;	// [09]  C   Consulta F3
			.F.											,;	// [10]  L   Indica se o campo é alteravel
			NIL											,;	// [11]  C   Pasta do campo
			NIL											,;	// [12]  C   Agrupamento do campo
			NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
			NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL											,;	// [15]  C   Inicializador de Browse
			.T.											,;	// [16]  L   Indica se o campo é virtual
			NIL											,;	// [17]  C   Picture Variavel
			NIL											)	// [18]  L   Indica pulo de linha após o campo


		Elseif nFolder == 3 .Or. nFolder == 4
			oStruct:AddField(	"E1_XVALLIQ"								,;	// [01]  C   Nome do Campo
			Alltrim(Str(SE1->(FieldPos("E1_VALOR"))+1))	,;	// [02]  C   Ordem
			STR0040										,;	// [03]  C   Titulo do campo //"Vlr Liquido"
			STR0040										,;	// [04]  C   Descricao do campo //"Vlr Liquido"
			NIL											,;	// [05]  A   Array com Help
			"N"											,;	// [06]  C   Tipo do campo
			PesqPict("SE1", "E1_SALDO")					,;	// [07]  C   Picture
			NIL											,;	// [08]  B   Bloco de Picture Var
			NIL											,;	// [09]  C   Consulta F3
			.F.											,;	// [10]  L   Indica se o campo é alteravel
			NIL											,;	// [11]  C   Pasta do campo
			NIL											,;	// [12]  C   Agrupamento do campo
			NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
			NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL											,;	// [15]  C   Inicializador de Browse
			.T.											,;	// [16]  L   Indica se o campo é virtual
			NIL											,;	// [17]  C   Picture Variavel
			NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"E1_XFILORI"								,;	// [01]  C   Nome do Campo
			Alltrim(Str(SE1->(FieldPos("E1_NSUTEF"))+1)),;	// [02]  C   Ordem
			AllTrim(RetTitle("E1_FILORIG"))				,;	// [03]  C   Titulo do campo
			AllTrim(RetTitle("E1_FILORIG"))				,;	// [04]  C   Descricao do campo
			NIL											,;	// [05]  A   Array com Help
			TAMSX3("E1_FILORIG")[3]						,;	// [06]  C   Tipo do campo
			NIL											,;	// [07]  C   Picture
			NIL											,;	// [08]  B   Bloco de Picture Var
			NIL											,;	// [09]  C   Consulta F3
			.F.											,;	// [10]  L   Indica se o campo é alteravel
			NIL											,;	// [11]  C   Pasta do campo
			NIL											,;	// [12]  C   Agrupamento do campo
			NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
			NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL											,;	// [15]  C   Inicializador de Browse
			.T.											,;	// [16]  L   Indica se o campo é virtual
			NIL											,;	// [17]  C   Picture Variavel
			NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"E1_XSALDO"				,;	// [01]  C   Nome do Campo
			Alltrim(Str(SE1->(FieldPos("E1_SALDO"))+1)),;	// [02]  C   Ordem
			AllTrim(RetTitle("E1_SALDO"))				,;	// [03]  C   Titulo do campo
			AllTrim(RetTitle("E1_SALDO"))				,;	// [04]  C   Descricao do campo
			NIL											,;	// [05]  A   Array com Help
			"N"											,;	// [06]  C   Tipo do campo
			PesqPict("SE1", "E1_SALDO")					,;	// [07]  C   Picture
			NIL											,;	// [08]  B   Bloco de Picture Var
			NIL											,;	// [09]  C   Consulta F3
			.F.											,;	// [10]  L   Indica se o campo é alteravel
			NIL											,;	// [11]  C   Pasta do campo
			NIL											,;	// [12]  C   Agrupamento do campo
			NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
			NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL											,;	// [15]  C   Inicializador de Browse
			.T.											,;	// [16]  L   Indica se o campo é virtual
			NIL											,;	// [17]  C   Picture Variavel
			NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"E1_XVLRREAL"				,;	// [01]  C   Nome do Campo
			Alltrim(Str(SE1->(FieldPos("E1_VLRREAL"))+1)),;	// [02]  C   Ordem
			AllTrim(RetTitle("E1_VLRREAL"))				,;	// [03]  C   Titulo do campo
			AllTrim(RetTitle("E1_VLRREAL"))				,;	// [04]  C   Descricao do campo
			NIL											,;	// [05]  A   Array com Help
			"N"											,;	// [06]  C   Tipo do campo
			PesqPict("SE1", "E1_SALDO")					,;	// [07]  C   Picture
			NIL											,;	// [08]  B   Bloco de Picture Var
			NIL											,;	// [09]  C   Consulta F3
			.F.											,;	// [10]  L   Indica se o campo é alteravel
			NIL											,;	// [11]  C   Pasta do campo
			NIL											,;	// [12]  C   Agrupamento do campo
			NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
			NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL											,;	// [15]  C   Inicializador de Browse
			.T.											,;	// [16]  L   Indica se o campo é virtual
			NIL											,;	// [17]  C   Picture Variavel
			NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"E1_XCARTAUT"								,;	// [01]  C   Nome do Campo
			Alltrim(Str(SE1->(FieldPos("E1_CARTAUT"))+1)),;	// [02]  C   Ordem
			AllTrim(RetTitle("E1_CARTAUT"))				,;	// [03]  C   Titulo do campo
			AllTrim(RetTitle("E1_CARTAUT"))				,;	// [04]  C   Descricao do campo
			NIL											,;	// [05]  A   Array com Help
			"C"											,;	// [06]  C   Tipo do campo
			PesqPict("SE1", "E1_CARTAUT")					,;	// [07]  C   Picture
			NIL											,;	// [08]  B   Bloco de Picture Var
			NIL											,;	// [09]  C   Consulta F3
			.F.											,;	// [10]  L   Indica se o campo é alteravel
			NIL											,;	// [11]  C   Pasta do campo
			NIL											,;	// [12]  C   Agrupamento do campo
			NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
			NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
			NIL											,;	// [15]  C   Inicializador de Browse
			.T.											,;	// [16]  L   Indica se o campo é virtual
			NIL											,;	// [17]  C   Picture Variavel
			NIL											)	// [18]  L   Indica pulo de linha após o campo

			If nFolder == 3
				oStruct:AddField(	"FIF_XCODJU"								,;	// [01]  C   Nome do Campo
				Alltrim(Str(SE1->(FieldPos("E1_NSUTEF"))+2)),;	// [02]  C   Ordem
				AllTrim(RetTitle("FIF_CODJUS"))				,;	// [03]  C   Titulo do campo
				AllTrim(RetTitle("FIF_CODJUS"))				,;	// [04]  C   Descricao do campo
				NIL											,;	// [05]  A   Array com Help
				TAMSX3("FIF_CODJUS")[3]						,;	// [06]  C   Tipo do campo
				NIL											,;	// [07]  C   Picture
				NIL											,;	// [08]  B   Bloco de Picture Var
				"FVX"										,;	// [09]  C   Consulta F3
				.T.											,;	// [10]  L   Indica se o campo é alteravel
				NIL											,;	// [11]  C   Pasta do campo
				NIL											,;	// [12]  C   Agrupamento do campo
				NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL											,;	// [15]  C   Inicializador de Browse
				.F.											,;	// [16]  L   Indica se o campo é virtual
				NIL											,;	// [17]  C   Picture Variavel
				NIL											)	// [18]  L   Indica pulo de linha após o campo

				oStruct:AddField(	"FIF_XDESJU"								,;	// [01]  C   Nome do Campo
				Alltrim(Str(SE1->(FieldPos("E1_NSUTEF"))+3)),;	// [02]  C   Ordem
				AllTrim(RetTitle("FIF_DESJUS"))				,;	// [03]  C   Titulo do campo
				AllTrim(RetTitle("FIF_DESJUS"))				,;	// [04]  C   Descricao do campo
				NIL											,;	// [05]  A   Array com Help
				TAMSX3("FIF_DESJUS")[3]						,;	// [06]  C   Tipo do campo
				NIL											,;	// [07]  C   Picture
				NIL											,;	// [08]  B   Bloco de Picture Var
				NIL											,;	// [09]  C   Consulta F3
				.T.											,;	// [10]  L   Indica se o campo é alteravel
				NIL											,;	// [11]  C   Pasta do campo
				NIL											,;	// [12]  C   Agrupamento do campo
				NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL											,;	// [15]  C   Inicializador de Browse
				.F.											,;	// [16]  L   Indica se o campo é virtual
				NIL											,;	// [17]  C   Picture Variavel
				NIL											)	// [18]  L   Indica pulo de linha após o campo

				oStruct:AddField(	"FIF_XDESJT"								,;	// [01]  C   Nome do Campo
				Alltrim(Str(SE1->(FieldPos("E1_NSUTEF"))+4)),;	// [02]  C   Ordem
				AllTrim(RetTitle("FIF_DESJUT"))				,;	// [03]  C   Titulo do campo
				AllTrim(RetTitle("FIF_DESJUT"))				,;	// [04]  C   Descricao do campo
				NIL											,;	// [05]  A   Array com Help
				TAMSX3("FIF_DESJUT")[3]						,;	// [06]  C   Tipo do campo
				NIL											,;	// [07]  C   Picture
				NIL											,;	// [08]  B   Bloco de Picture Var
				NIL											,;	// [09]  C   Consulta F3
				.T.											,;	// [10]  L   Indica se o campo é alteravel
				NIL											,;	// [11]  C   Pasta do campo
				NIL											,;	// [12]  C   Agrupamento do campo
				NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL											,;	// [15]  C   Inicializador de Browse
				.F.											,;	// [16]  L   Indica se o campo é virtual
				NIL											,;	// [17]  C   Picture Variavel
				NIL											)	// [18]  L   Indica pulo de linha após o campo

			EndIf

		EndIf

	EndCase

	Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} SetProp
	Ajuste nas Propriedades dos Campos da FIF

	@author Guilherme Santos
	@since 09/02/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function SetProp( oModel As Object, nOpcao As Numeric, oStruct As Object )
	//Bloqueia alteracoes em todos os campos
	//da grid com excecao do campo de selecao
	Do Case
	Case nOpcao == 1	//Model
		oStruct:SetProperty("*",	MODEL_FIELD_OBRIGAT, 	.F.)
		oStruct:SetProperty("*", 	MODEL_FIELD_WHEN, 		{|| .F. })
		oStruct:SetProperty("OK",	MODEL_FIELD_WHEN, 		{|| .T. })
	Case nOpcao == 2	//View
		oStruct:SetProperty("*", 	MVC_VIEW_CANCHANGE, .F.)
		oStruct:SetProperty("OK", 	MVC_VIEW_CANCHANGE, .T.)
	EndCase

	Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} fLoadTot
	Calculo dos Totais da Conciliacao

	@author Guilherme Santos
	@since 01/03/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function fLoadTot( oSubMod As Object ) As Array
	Local aRetorno	As Array
	Local aFields	As Array
	Local aAux		As Array
	Local aQry		As Array
	Local nField	As Numeric
	Local nX		As Numeric
	Local cTabQry	As Character
	Local cQuery	As Character
	Local dData		As Date

	aRetorno	:= {}
	aFields		:= oSubMod:GetStruct():GetFields()
	aAux		:= {}
	aQry		:= {}
	nField		:= 0
	nX			:= 0
	cQuery		:= ""
	dData		:= CtoD("")

	If __nFldPar == 0 .OR. __nFldPar == 1
		//Conciliado Normal
		If !__lUsaMep
			cQuery := "SELECT	FIF.FIF_DTTEF			DATA" +  CRLF
			cQuery += ",		'1'						ABA" + 	 CRLF
			cQuery += ",		SUM(FIF.FIF_VLBRUT)		VALOR" + CRLF
			cQuery += ",		SUM(FIF.FIF_VLLIQ)		VLLIQ" + CRLF
			cQuery += ",		COUNT(FIF.FIF_DTTEF)	QUANT" + CRLF
			cQuery += "FROM		" + RetSqlName("FIF") + " FIF" + CRLF
			cQuery += "WHERE	FIF.D_E_L_E_T_  = ' '" + CRLF
			cQuery += "AND " + GetFilter(1, "FIF") + CRLF
			cQuery += "GROUP BY FIF.FIF_DTTEF" + CRLF
			cQuery += "ORDER BY DATA, ABA" + CRLF
		else
			F916MEP( , 1, @cQuery ,.T.)
		Endif	
		aAdd(aQry, cQuery)
	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 2
		//--Conciliado parcialmente
		If !__lUsaMep
			cQuery := "SELECT	FIF.FIF_DTTEF			DATA" +  CRLF
			cQuery += ",		'2'						ABA" +   CRLF
			cQuery += ",		SUM(FIF.FIF_VLBRUT)		VALOR" + CRLF
			cQuery += ",		SUM(FIF.FIF_VLLIQ)		VLLIQ" + CRLF
			cQuery += ",		COUNT(FIF.FIF_DTTEF)	QUANT" + CRLF
			cQuery += "FROM		" + RetSqlName("FIF") + " FIF" + CRLF
			cQuery += "WHERE	FIF.D_E_L_E_T_  = ' '" + CRLF
			cQuery += "AND " + GetFilter(2, "FIF") + CRLF
			cQuery += "GROUP BY FIF.FIF_DTTEF" + CRLF
			cQuery += "ORDER BY DATA, ABA" + CRLF
		Else
			F916MEP( , 2, @cQuery ,.T.)
		Endif	
		aAdd(aQry, cQuery)
	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 3
		//--Titulos sem Venda
		cQuery := "SELECT	SE1.E1_EMISSAO			DATA" +  CRLF
		cQuery += ",		'3'						ABA" +   CRLF
		cQuery += ",		SUM(SE1.E1_VALOR)		VALOR" + CRLF
		cQuery += ",		SUM(SE1.E1_SALDO)		VLLIQ" + CRLF
		cQuery += ",		COUNT(SE1.E1_EMISSAO)	QUANT" + CRLF
		cQuery += "FROM		" + RetSqlName("SE1") + " SE1" + CRLF
		cQuery += "WHERE	SE1.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "AND " + GetFilter(3, "SE1") + CRLF
		cQuery += "GROUP BY SE1.E1_EMISSAO" + CRLF
		cQuery += "ORDER BY DATA, ABA" + CRLF
		aAdd(aQry, cQuery)
	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 4
		//--Vendas sem Titulos
		cQuery := "SELECT	FIF.FIF_DTTEF			DATA" +  CRLF
		cQuery += ",		'4'						ABA" +   CRLF
		cQuery += ",		SUM(FIF.FIF_VLBRUT)		VALOR" + CRLF
		cQuery += ",		SUM(FIF.FIF_VLLIQ)		VLLIQ" + CRLF
		cQuery += ",		COUNT(FIF.FIF_DTTEF)	QUANT" + CRLF
		cQuery += "FROM		" + RetSqlName("FIF") + " FIF" + CRLF
		cQuery += "WHERE	FIF.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "AND " + GetFilter(4, "FIF") + CRLF
		cQuery += "GROUP BY FIF.FIF_DTTEF" + CRLF
		cQuery += "ORDER BY DATA, ABA" + CRLF
		aAdd(aQry, cQuery)
	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 5
		//--Divergentes
		cQuery := "SELECT	FIF.FIF_DTTEF			DATA" +  CRLF
		cQuery += ",		'5'						ABA" +   CRLF
		cQuery += ",		SUM(FIF.FIF_VLBRUT)		VALOR" + CRLF
		cQuery += ",		SUM(FIF.FIF_VLLIQ)		VLLIQ" + CRLF
		cQuery += ",		COUNT(FIF.FIF_DTTEF)	QUANT" + CRLF
		cQuery += "FROM		" + RetSqlName("FIF") + " FIF" + CRLF
		cQuery += "WHERE	FIF.D_E_L_E_T_  = ' '" + CRLF
		cQuery += "AND " + GetFilter(5, "FIF") + CRLF
		cQuery += "GROUP BY FIF.FIF_DTTEF" + CRLF
		cQuery += "ORDER BY DATA, ABA" + CRLF
		aAdd(aQry, cQuery)
	EndIf

	// Executa querys individualmente para evitar problemas com estouro de variável caso existam muitas filiais para serem filtradas (selecionadas no filtrar filiais "SIM")
	For nX := 1 to Len(aQry)

		cTabQry		:= GetNextAlias()
		If Select(cTabQry) > 0
			(cTabQry)->(DbCloseArea())
		EndIf

		cQuery := ChangeQuery(aQry[nX])

		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)

		While !(cTabQry)->(Eof())

			dData 		:= StoD((cTabQry)->DATA)
			If ( nPos:= aScan(aRetorno, {|x| x[2][1] == dData}) ) > 0
				aAux := aClone(aRetorno[nPos][2])
			Else
				aAux 		:= Array(Len(aFields))
				aAux[01]	:= dData
				For nField := 2 to Len(aAux)
					aAux[nField] := 0
				Next nField
			EndIf

			Do Case
			Case (cTabQry)->ABA == "1"
				aAux[Ascan(aFields, {|x| x[03] == "TOTFLD1"})] += (cTabQry)->VALOR
				aAux[Ascan(aFields, {|x| x[03] == "LIQFLD1"})] += (cTabQry)->VLLIQ
				aAux[Ascan(aFields, {|x| x[03] == "QTDFLD1"})] += (cTabQry)->QUANT
			Case (cTabQry)->ABA == "2"
				aAux[Ascan(aFields, {|x| x[03] == "TOTFLD2"})] += (cTabQry)->VALOR
				aAux[Ascan(aFields, {|x| x[03] == "LIQFLD2"})] += (cTabQry)->VLLIQ
				aAux[Ascan(aFields, {|x| x[03] == "QTDFLD2"})] += (cTabQry)->QUANT
			Case (cTabQry)->ABA == "3"
				aAux[Ascan(aFields, {|x| x[03] == "TOTFLD3"})] += (cTabQry)->VALOR
				aAux[Ascan(aFields, {|x| x[03] == "LIQFLD3"})] += (cTabQry)->VLLIQ
				aAux[Ascan(aFields, {|x| x[03] == "QTDFLD3"})] += (cTabQry)->QUANT
			Case (cTabQry)->ABA == "4"
				aAux[Ascan(aFields, {|x| x[03] == "TOTFLD4"})] += (cTabQry)->VALOR
				aAux[Ascan(aFields, {|x| x[03] == "LIQFLD4"})] += (cTabQry)->VLLIQ
				aAux[Ascan(aFields, {|x| x[03] == "QTDFLD4"})] += (cTabQry)->QUANT
			Case (cTabQry)->ABA == "5"
				aAux[Ascan(aFields, {|x| x[03] == "TOTFLD5"})] += (cTabQry)->VALOR
				aAux[Ascan(aFields, {|x| x[03] == "LIQFLD5"})] += (cTabQry)->VLLIQ
				aAux[Ascan(aFields, {|x| x[03] == "QTDFLD5"})] += (cTabQry)->QUANT
			EndCase

			If  nPos > 0
				aRetorno[nPos][2] := aClone(aAux)
			Else
				Aadd(aRetorno, {0 ,aAux})
				aAux	:= {}
			EndIf

			(cTabQry)->(dbSkip())

		End

		If Select(cTabQry) > 0
			(cTabQry)->(DbCloseArea())
		EndIf

	Next nX

	//Se não houver dados retorna um Array vazio
	If Len(aRetorno) == 0
		aAux 		:= Array(Len(aFields))
		aAux[01]	:= dDatabase

		For nField := 2 to Len(aAux)
			aAux[nField] := 0
		Next nField

		Aadd(aRetorno, {0 ,aAux})
	Else
		aRetorno := aSort(aRetorno,,,{|x,y| x[2][1] < y[2][1] })
	EndIf

	aAux		:= {}
	aQry        := {}
	aFields     := {}
	Return aRetorno

	//-------------------------------------------------------------------
	/*/{Protheus.doc} fVldOk
	Valida a Selecao do FIF x SE1

	@author Guilherme Santos
	@since 05/03/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function fVldOk( oModel As Object, cCampo As Character, lValue As Logical, lOldVal As Logical ) As Logical
	Local lRetorno	As Logical
	Local nLinha	As Numeric
	Local nLinBkp	As Numeric

	lRetorno	:= .T.
	nLinha		:= 0
	nLinBkp		:= 0

	If lValue
		nLinBkp	:= oModel:GetLine()
		For nLinha := 1 to oModel:Length()
			oModel:GoLine(nLinha)
			If nLinha <> nLinBkp
				If oModel:GetValue("OK")
					lRetorno := .F.
					Help(NIL, NIL, "FVLDOK", NIL, STR0033, 1, 0)	//"Selecionar apenas um registro por vez para conciliação."
				EndIf
			EndIf
		Next nLinha
		oModel:GoLine(nLinBkp)
	EndIf

	Return lRetorno

	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916ADM
	Consulta Especifica das Administradoras Financeiras

	@author Guilherme Santos
	@since 15/03/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Function F916ADM() As Logical
	Local aColumns	As Array
	Local aPesq		As Array
	Local aStruct	As Array
	Local bOk		As Codeblock
	Local bCancel	As Codeblock
	Local cArqTrb	As Character
	Local cQuery	As Character
	Local cMvPar	As Character
	Local nCampo	As Numeric
	Local lRetorno	As Logical
	Local oDlg		As Object
	Local oMrkBrw	As Object

	aColumns	:= {}
	aPesq		:= {}
	aStruct		:= MDE->(DBStruct())
	cMvPar		:= Alltrim(ReadVar())
	bOk			:= {|| lRetorno := F916Sel(cArqTrb, cMvPar), oDlg:End()}
	bCancel		:= {|| oMrkBrw:Deactivate(), oDlg:End()}
	cArqTrb		:= GetNextAlias()
	cQuery		:= ""
	nCampo		:= 0
	lRetorno	:= .F.

	//Limpa a Variavel de Retorno
	__cAdmFin := ""
	If !Empty(cMvPar)
		If __oF916ADM <> NIL
			__oF916ADM:Delete()
			__oF916ADM := NIL
		EndIf

		//Cria o Objeto do FwTemporaryTable
		__oF916ADM := FwTemporaryTable():New(cArqTrb)

		//Cria a estrutura do alias temporario
		Aadd(aStruct, {"MDE_OK", "C", 1, 0})	 //Adiciono o campo de marca
		__oF916ADM:SetFields(aStruct)

		__oF916ADM:AddIndex("1", {"MDE_CODIGO"})
		__oF916ADM:AddIndex("2", {"MDE_DESC"})

		//Criando a Tabela Temporaria
		__oF916ADM:Create()

		//Selecao dos Dados da MDE
		cQuery += "SELECT	MDE.MDE_CODIGO" + CRLF
		cQuery += ",		MDE.MDE_DESC" + CRLF
		cQuery += ",		MDE.MDE_CODSIT" + CRLF
		cQuery += ",		MDE.MDE_TIPO" + CRLF
		cQuery += " FROM		" + RetSqlName("MDE") + " MDE" + CRLF
		cQuery += " WHERE	MDE.MDE_FILIAL = '" + FWxFilial("MDE") + "'" + CRLF
		cQuery += " AND MDE.MDE_TIPO = 'RD' "
		cQuery += " AND (MDE.MDE_ARQIMP <> ' ' AND MDE.MDE_ARQPRO <> ' ' AND MDE.MDE_ARQINC <> ' ') "
		cQuery += " AND		MDE.D_E_L_E_T_ = ' '" + CRLF
		cQuery += " ORDER BY " + SqlOrder(MDE->(IndexKey())) + CRLF

		cQuery := ChangeQuery(cQuery)

		//Cria arquivo temporario
		Processa({|| SqlToTrb(cQuery, aStruct, cArqTrb)})

		(cArqTrb)->(DbGotop())
		// Marca os registro já selecionados.
		While !(cArqTrb)->(Eof())
			If (cArqTrb)->MDE_CODIGO $ &cMvPar
				Reclock(cArqTrb,.F.)
				(cArqTrb)->MDE_OK := "X"
				MsUnlock()
			EndIf
			(cArqTrb)->(DbSkip())
		End

		(cArqTrb)->(DbGotop())
		//Fica na ordem da query
		DbSetOrder(0)

		//MarkBrowse
		For nCampo := 1 To Len( aStruct )
			If	aStruct[nCampo][1] $ "MDE_CODIGO|MDE_DESC|MDE_CODSIT|MDE_TIPO"
				AAdd(aColumns, FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCampo][1] + "}") )
				aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nCampo][1]))
				aColumns[Len(aColumns)]:SetSize(aStruct[nCampo][3])
				aColumns[Len(aColumns)]:SetDecimal(aStruct[nCampo][4])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("MDE", aStruct[nCampo][1]))
			EndIf
		Next nCampo

		//Regras para pesquisa na tela
		Aadd(aPesq, {AllTrim(RetTitle("MDE_CODIGO")), {{"MDE", "C", TamSX3("MDE_CODIGO")[1], 0, AllTrim(RetTitle("MDE_CODIGO")), "@!"}}, 1})
		Aadd(aPesq, {AllTrim(RetTitle("MDE_DESC")), {{"MDE", "C", TamSX3("MDE_DESC")[1], 0, AllTrim(RetTitle("MDE_DESC")), "@!"}}, 2})

		If !(cArqTrb)->(Eof())
			DEFINE MSDIALOG oDlg TITLE STR0094 From 300, 0 to 800,800 OF oMainWnd PIXEL //Administradoras
			oMrkBrw := FWMarkBrowse():New()
			oMrkBrw:oBrowse:SetEditCell(.T.)
			oMrkBrw:SetIgnoreARotina(.T.)
			oMrkBrw:SetFieldMark("MDE_OK")
			oMrkBrw:SetOwner(oDlg)
			oMrkBrw:SetAlias(cArqTrb)
			oMrkBrw:SetSeek(.T., aPesq)
			oMrkBrw:SetMenuDef("")
			oMrkBrw:AddButton("Confirmar", bOk, NIL, 2) //Confirmar
			oMrkBrw:AddButton("Cancelar", bCancel, NIL, 2) //Cancelar
			oMrkBrw:bMark	:= {||}
			oMrkBrw:bAllMark	:= {|| F916MrkAll(oMrkBrw, cArqTrb)}
			oMrkBrw:SetMark( "X", cArqTrb, "MDE_OK" )
			oMrkBrw:SetDescription("")
			oMrkBrw:SetColumns(aColumns)
			oMrkBrw:SetTemporary(.T.)
			oMrkBrw:Activate()
			ACTIVATE MSDIALOG oDlg CENTERED
		EndIf
	EndIf 
	GETDREFRESH()
	If __oF916ADM <> NIL
		__oF916ADM:Delete()
		__oF916ADM := NIL
	EndIf

	Return lRetorno

	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916GetAdm
	Retorna as Administradoras Financeiras Selecionadas

	@author Guilherme Santos
	@since 15/03/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Function F916GetAdm() As Character
	Return __cAdmFin

	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916Sel
	Grava em uma String as Administradoras Selecionadas

	@author Guilherme Santos
	@since 15/03/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function F916Sel( cArqTrb As Character, cMvPar As Character ) As Logical
	Local lRet		As Logical
	Local nRecno	As Numeric
	Local nX		As Numeric
	Local nTam		As Numeric
	Local nVarTam	As Numeric
	Local nTotTam	As Numeric
	Local nMaxTam	As Numeric
	Local aParLin	As Array

	Default cArqTrb := ""
	Default cMvPar 	:= Alltrim(ReadVar())

	lRet	:= .T.
	nRecno	:= 0
	nX		:= 0
	nTam	:= 0
	nVarTam	:= 0
	nTotTam	:= 0
	nMaxTam	:= 60
	aParLin	:= {}

	dbSelectArea(cArqTrb)
	nRecno := (cArqTrb)->(RecNo())
	(cArqTrb)->(DbGoTop())

	__cAdmFin 	:= ""
	While !(cArqTrb)->(Eof())
		If !Empty((cArqTrb)->MDE_OK)
			__cAdmFin += If(nX > 0, ";" + (cArqTrb)->MDE_CODIGO, (cArqTrb)->MDE_CODIGO )
			nX++
		EndIf
		(cArqTrb)->(DbSkip())
	EndDo

	// Efetua a validação da quantidade de empresas selecionadas para evitar estouro no parâmetro e error.log na query
	aParLin  := StrToArray( Alltrim(__cAdmFin) ,";")
	For nX := 1 to Len(aParLin)
		nVarTam := Len(Alltrim(aParLin[nX])) + 1
		If ( nTotTam + nVarTam ) <= nMaxTam
			nTotTam += nVarTam
		Else
			lRet := .F.
			Help(NIL, NIL, "F916Sel", NIL, STR0049, 1, 0) //"Limite de seleção de empresas excedido para o parâmetro  da rotina (Max 60 Caracteres)."
			Exit
		EndIf
	Next nX

	(cArqTrb)->(DbGoTo(nRecno))

	If lRet
		lRet := Iif(Len(__cAdmFin) > 0, .T., .F.)
		&(cMvPar) := __cAdmFin
	EndIf

	Return lRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916MrkAll
	Marca ou Desmarca todas as Administradoras

	@author Guilherme Santos
	@since 15/03/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Function F916MrkAll( oMrkBrw As Object, cArqTrb As Character ) As Logical
	Local cMarca As Character

	cMarca := oMrkBrw:Mark()

	DbSelectArea( cArqTrb )
	(cArqTrb)->( DbGoTop() )

	While !(cArqTrb)->( Eof() )

		RecLock( cArqTrb, .F. )

		If (cArqTrb)->MDE_OK == cMarca
			(cArqTrb)->MDE_OK := " "
		Else
			(cArqTrb)->MDE_OK := cMarca
		EndIf

		MsUnlock()
		(cArqTrb)->(DbSkip())
	EndDo

	(cArqTrb)->(DbGoTop())
	oMrkBrw:oBrowse:Refresh(.T.)

	Return .T.

	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916Desfaz
	Desfaz Conciliação - Volta status para "1=Não Processado"

	@author Marcelo Ferreira
	@since 04/06/2018
	@version 12.1.19
	/*/
	//-------------------------------------------------------------------
Static Function F916Desfaz()
	Local aArea 	As Array
	Local cMsg 		As Character
	Local cFilSE1 	As Character
	Local cNsuTef	As Character

	aArea 	:= GetArea()
	cMsg 	:= ""
	cFilSE1	:= ""
	cNsuTef := ""

	If !FIF->( EOF() )

		If !Empty(Alltrim(SUBSTR(FIF->FIF_NSUTEF,40)))
			cNsuTef := SUBSTR(FIF->FIF_NSUTEF,10)
		Else
			cNsuTef := Alltrim(FIF->FIF_NSUTEF)
		Endif

		cMsg :=  CRLF + STR0041 + DtoC(FIF->FIF_DTTEF) + CRLF + " | "+ STR0042 + cNsuTef + CRLF + " | " + STR0043 + FIF->FIF_PARCEL //" Data Venda: "###"NSU Sitef: "###"Parcela: "

		If !(FIF->FIF_STVEND $ "1/A/B/C/D/E/F/G")

			If ApMsgYesNo( STR0036 + cMsg , STR0037 ) //"Deseja desfazer a conciliação para o registro: "###"Desfazer Conciliação"

				If FIF->FIF_STVEND $ '2/3/4' // Conciliado / Conc.Parcialmente / Divergente

					FIF->( RecLock("FIF", .F.) )
					FIF->FIF_STVEND := "1" //1="Não Processado"
					FIF->FIF_DTCONV := Ctod("  /  /  ")
					FIF->FIF_CODJUS := ""
					FIF->FIF_DESJUS := ""
					FIF->FIF_DESJUT := ""
					FIF->FIF_USUVEN := ""
					FIF->FIF_DTVEN  := Ctod("  /  /  ")
					FIF->( MsUnlock() )

				ElseIf FIF->FIF_STVEND $ '5/7' //Venda Conciliada com Critica / Registro de Venda sem Titulo

					If ApMsgYesNo( STR0062 , STR0063 ) // "Deseja limpar o campo 'NSU SITEF' (E1_NSUTEF) do título para desvincular do registro de venda?"###"Atenção"
						cFilSE1 := Iif(!Empty(xFilial("SE1")), FIF->FIF_CODFIL, xFilial("SE1"))
						SE1->( dbSetOrder(1) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
						If SE1->( dbSeek(cFilSE1 + FIF->FIF_PREFIX + FIF->FIF_NUM + FIF->FIF_PARC + FIF->FIF_TIPO  ) )
							SE1->( RecLock("SE1", .F.) )
							SE1->E1_NSUTEF := " "
							SE1->( MsUnlock() )
						EndIf
					EndIf

					FIF->( RecLock("FIF", .F.) )
					FIF->FIF_STVEND := "1" //1="Não Processado"
					FIF->FIF_DTCONV := Ctod("  /  /  ")
					FIF->FIF_CODJUS := ""
					FIF->FIF_DESJUS := ""
					FIF->FIF_DESJUT := ""
					FIF->FIF_USUVEN := ""
					FIF->FIF_DTVEN  := Ctod("  /  /  ")
					FIF->FIF_PREFIX := ""
					FIF->FIF_NUM 	:= ""
					FIF->FIF_PARC 	:= ""
					FIF->FIF_TIPO 	:= ""
					FIF->FIF_DTCRED := Ctod("  /  /  ")
					FIF->( MsUnlock() )

				ElseIf FIF->FIF_STVEND == '6' // Titulo sem Registro de Venda

					FIF->( RecLock("FIF", .F.) )
					FIF->( dbDelete() )
					FIF->( MsUnlock() )

				Endif

			EndIf

		Else

			If FIF->FIF_STVEND == "1"
				Help(NIL, NIL, "F916Desfaz01", NIL, STR0038 + cMsg, 1, 0) //"Ação não será necessária, pois registro não foi conciliado: "
			Else
				Help(NIL, NIL, "F916Desfaz02", NIL, STR0053 + cMsg, 1, 0)  //"Pagamento Conciliado, ação não será permitida: "
			EndIf

		EndIf

	EndIf

	RestArea(aArea)

	Return
	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916Perg
	Pergunte da tela de conciliação de vendas

	@author Marcelo Ferreira
	@since 10/06/2018
	@version 12.1.17
	/*/
	//-------------------------------------------------------------------
Static Function F916Perg() As Logical
	Local lRet As Logical
	Local lCancel As Logical
	Local cConc	As Numeric
	Local cPerg	As Character

	lRet	:= .T.
	lCancel	:= .T.
	cConc	:= 0
	cPerg	:= ""

	// Define qual operadora para a conciliação
	nConc	:= Aviso(STR0044, STR0045, { STR0046, STR0047, STR0048 }, 2, ) //"Conciliação"###"Por favor, definir operadora para a conciliação: "###"Demais"###"Software Express"###"Cancelar"
	__lSOFEX	:= ( nConc == 2 )
	lCancel	:= ( nConc == 3 )

	If !lCancel

		If __lSOFEX
			cPerg := "FINA916" // Software Express
		Else
			cPerg := "FINA9161"  // Demais operadoras
		EndIf

		lRet := Pergunte(cPerg, .T.)

	Else
		lRet := .F.
	EndIf

	Return lRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916Print
	Pergunte da tela de conciliação de vendas

	@author Jose.Gavetti
	@since 12/06/2018
	@version 12.1.17
	/*/
	//-------------------------------------------------------------------
Static Function F916Print(oView As Object)
	Local oModel 	 As Object
	Local oModGrid1	 As Object
	Local oModGrid2	 As Object
	Local aPlanilha  As Array
	Local aStructFIF As Array
	Local aStructSE1 As Array
	Local aColsFIF 	 As Array
	Local aColsSE1 	 As Array
	Local aAux	 	 As Array
	Local nL		 As Numeric
	Local nX		 As Numeric
	Local nZ		 As Numeric
	Local nSheetAct  As Numeric
	Local cNameSheet As Character
	Local cGrid1  	 As Character
	Local cGrid2	 As Character
	Local cConteudo	 As Character
	Local cCpoCbx	 As Character
	Local lConcTotP  As Logical

	Default oView  := FwViewActive()

	oModel 		:= oView:GetModel()
	oModGrid1	:= Nil
	oModGrid2	:= Nil
	nSheetAct	:= oView:GetFolderActive("FOLGRIDS", 2)[1]
	cNameSheet	:= Alltrim(oView:GetFolderActive("FOLGRIDS", 2)[2])
	aPlanilha 	:= {}
	aStructFIF 	:= {}
	aStructSE1 	:= {}
	aColsFIF	:= {}
	aColsSE1	:= {}
	aAux		:= {}
	nL			:= 0
	nX			:= 0
	nZ			:= 0
	cGrid1 		:= ""
	cGrid2 		:= ""
	cConteudo	:= ""
	cCpoCbx		:= "FIF_STVEND/FIF_STATUS"
	lConcTotP	:= .F.

	If __nFldPar == 0

		If nSheetAct == 1
			cGrid1 := "FIFFLD1"
			cGrid2 := "SE1FLD1"
		ElseIf nSheetAct == 2
			cGrid1 := "FIFFLD2"
			cGrid2 := "SE1FLD2"
		ElseIf nSheetAct == 3
			cGrid1 := "SE1FLD3"
		ElseIf nSheetAct == 4
			cGrid1 := "FIFFLD4"
			cGrid2 := "SE1FLD4"
		ElseIf nSheetAct == 5
			cGrid1 := "FIFFLD5"
		ElseIf nSheetAct == 6
			cGrid1 := "TOTFLD6"
		EndIf

		lConcTotP := nSheetAct == 1 .Or. nSheetAct == 2

	Else

		If nSheetAct == 2
			cGrid1 := "TOTFLD6"
		ElseIf __nFldPar == 1
			cGrid1 := "FIFFLD1"
			cGrid2 := "SE1FLD1"
			lConcTotP := .T.
		ElseIf __nFldPar == 2
			cGrid1 := "FIFFLD2"
			cGrid2 := "SE1FLD2"
			lConcTotP := .T.
		ElseIf __nFldPar == 3
			cGrid1 := "SE1FLD3"
		ElseIf __nFldPar == 4
			cGrid1 := "FIFFLD4"
			cGrid2 := "SE1FLD4"
		ElseIf __nFldPar == 5
			cGrid1 := "FIFFLD5"
		EndIf

	EndIf

	If !Empty(cGrid1)

		aColsFIF := {}
		oModGrid1 	:= oModel:GetModel(cGrid1)
		aStructFIF 	:= oModGrid1:GetStruct():GetFields()
		If nSheetAct < 6
			aStructFIF  := OrderToPrt(aStructFIF,nSheetAct,1,cGrid1)
		EndIf
		If lConcTotP .And. !Empty(cGrid2)
			aColsSE1 := {}
			oModGrid2 := oModel:GetModel(cGrid2)
			aStructSE1 	:= oModGrid2:GetStruct():GetFields()
			aStructSE1  := OrderToPrt(aStructSE1,nSheetAct,,cGrid2)
		EndIf

		For nL := 1 to oModGrid1:Length()
			oModGrid1:GoLine(nL)
			aAux 	 := {}
			For nX := 1 to Len(aStructFIF)
				If Alltrim(aStructFIF[nX][3]) $ cCpoCbx
					cConteudo := Alltrim(X3Combo(aStructFIF[nX][3], oModGrid1:GetValue(aStructFIF[nX][3])))
				Else
					cConteudo := oModGrid1:GetValue(aStructFIF[nX][3])
				EndIf
				aAdd(aAux, cConteudo)
			Next nX
			aAdd(aColsFIF, aAux)

			If lConcTotP .And. !Empty(cGrid2)
				For nZ := 1 to oModGrid2:Length()
					oModGrid2:GoLine(nZ)
					aAux 	 := {}
					For nX := 1 to Len(aStructSE1)
						If Alltrim(aStructSE1[nX][3]) $ cCpoCbx
							cConteudo := Alltrim(X3Combo(aStructSE1[nX][3], oModGrid2:GetValue(aStructSE1[nX][3])))
						Else
							cConteudo := oModGrid2:GetValue(aStructSE1[nX][3])
						EndIf
						aAdd(aAux, cConteudo)
					Next nX
					aAdd(aColsSE1, aAux)
				Next nZ
			EndIf

		Next nL
		aAdd(aPlanilha, {aStructFIF, aColsFIF} )
		If Len(aColsSE1) > 0
			aAdd(aPlanilha, {aStructSE1, aColsSE1} )
		EndIf
	Endif

	If !lConcTotP .And. !Empty(cGrid2)
		aColsSE1 	:= {}
		oModGrid2	:= oModel:GetModel(cGrid2)
		aStructSE1 	:= oModGrid2:GetStruct():GetFields()
		aStructSE1  := OrderToPrt(aStructSE1,nSheetAct,,cGrid2)

		For nL := 1 to oModGrid2:Length()
			oModGrid2:GoLine(nL)
			aAux 	 := {}
			For nX := 1 to Len(aStructSE1)
				If Alltrim(aStructSE1[nX][3]) $ cCpoCbx
					cConteudo := Alltrim(X3Combo(aStructSE1[nX][3], oModGrid2:GetValue(aStructSE1[nX][3])))
				Else
					cConteudo := oModGrid2:GetValue(aStructSE1[nX][3])
				EndIf
				aAdd(aAux, cConteudo)
			Next nX
			aAdd(aColsSE1, aAux)
		Next nL
		aAdd(aPlanilha, {aStructSE1, aColsSE1} )
	EndIf

	// Imprime a Grid
	If Len(aPlanilha) > 0
		FWMsgRun(/*oComponent*/,{|| F916Excel(aPlanilha, "FINA916", STR0001 + " - " + cNameSheet) }, STR0001, STR0074 )  //"Conciliação Vendas"###"Por favor, aguarde. Imprimindo..."
	EndIf

	Return


	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916Just
	Gatilho da descrição da justificativa

	@author ana.nascimento
	@since 14/06/2018
	@version 12.1.17
	/*/
	//-------------------------------------------------------------------
Static function F916Just (oModel As Object) As Character
	Local cDesc	As Character
	Local cCod 	As Character

	cCod := oModel:GetValue("FIF_CODJUS")
	cDesc := Posicione("FVX",1,xFilial("FVX")+cCod,'FVX_DESCRI')

	Return cDesc


	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916Just
	Gatilho da descrição da justificativa

	@author Igor Fricks
	@since 22/10/2018
	@version 12.1.17
	/*/
	//-------------------------------------------------------------------
Static function F916JustX (oModel As Object) As Character
	Local cDesc	As Character
	Local cCod 	As Character

	cCod := oModel:GetValue("FIF_XCODJU")
	cDesc := Posicione("FVX",1,xFilial("FVX")+cCod,'FVX_DESCRI')

	Return cDesc


	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916ChkMod
	Retorna se tabela é exclusiva ou compartilhada

	@author Marcelo Ferreira
	@since 27/06/2018
	@version 12.1.17
	/*/
	//-------------------------------------------------------------------
Function F916ChkMod(cTabela As Character) As Logical
	Local lExclusivo As Logical
	Local cEmpComp 	 As Character
	Local cUnNegComp As Character
	Local cFilcomp 	 As Character

	Default cTabela	:= ""

	lExclusivo 	:= .F.
	If !Empty(cTabela)
		cEmpComp 	:= FWModeAccess(cTabela,1)
		cUnNegComp 	:= FWModeAccess(cTabela,2)
		cFilcomp 	:= FWModeAccess(cTabela,3)

		If cEmpComp == "E" .And. cUnNegComp == "E" .And. cFilcomp == "E"
			lExclusivo := .T.
		EndIf
	EndIf

	Return lExclusivo


	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916VldChk
	Valida a marcacao de registros na tela Tit. S/ Venda para não permitir
	selecionar registros com NSU Branco

	@author Marcelo Ferreira
	@since 10/07/2018
	@version 12.1.17
	/*/
	//-------------------------------------------------------------------
Static Function F916VldChk(oModGrid As Object) As Logical
	Local lRet As Logical

	lRet	:= .T.

	If Empty(oModGrid:GetValue("E1_NSUTEF"))
		lRet := .F.
		oModGrid:GetModel():SetErrorMessage('SE1FLD3', 'OK' , 'SE1FLD3' , 'OK' , "F916VldChk", ;
			STR0064 + CRLF + CRLF +;
			STR0065 + AllTrim(RetTitle("E1_NSUTEF")) + CRLF +;
			STR0066 + STR0013 ) //'Não é permitido marcar/efetivar títulos sem preenchimento para o campo abaixo: '###"Campo: "###'Aba: '###"Titulos sem Vendas"
	EndIf

	Return lRet


	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916VlrTef
	Pega o valor do FIF_VLLIQ e insere na grid da SE1 para confrontar os valores.

	@author Jose.Gavetti
	@since 12/07/2018
	@version 12.1.17
	/*/
	//-------------------------------------------------------------------
Static Function F916VlrTef(oView As Object, nOpc As Numeric)
	Local oModel As Object
	Local oModSE1 As Object
	Local oModFIF As Object
	Local cSE1Painel As Character
	Local cFIFPainel As Character

	Default oView 		:= FwViewActive()
	Default nOpc		:= 1

	If nOpc == 1
		cSE1Painel	:= "SE1FLD1"
		cFIFPainel	:= "FIFFLD1"
	ElseIf nOpc == 2
		cSE1Painel	:= "SE1FLD2"
		cFIFPainel	:= "FIFFLD2"
	EndIf

	oModel	:= FWModelActivate()
	oModSE1:= oModel:GetModel(cSE1Painel)
	oModFIF := oModel:GetModel(cFIFPainel)

	oModSE1:SetNoUpdateLine(.F.)
	oModSE1:SetValue("E1_XVLRTEF",oModFIF:GetValue('FIF_VLLIQ'))
	oModSE1:SetNoUpdateLine(.T.)

	oView:Refresh(cSE1Painel)

	Return


	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916Excel
	Exportação da GRID em arquivo XML

	@author Marcelo Ferreira
	@since 05/09/2018
	@version 12.1.17
	/*/
	//-------------------------------------------------------------------
Function F916Excel(aWorkSheet As Array, cOrigem As Character, cTitulo As Character, aTabDePara As Array) As Logical
	Local cWorkSheet	As Character
	Local cTable		As Character
	Local cArqXml		As Character
	Local cArqXLS		As Character
	Local cAlias		As Character
	Local cNomeAlias	As Character
	Local cNameCol 		As Character
	Local cCampo 		As Character
	Local cTipo		 	As Character
	Local cCpoExc	 	As Character
	Local oExcel		As Object
	Local nA			As Numeric
	Local nH			As Numeric
	Local nX			As Numeric
	Local nAlign	 	As Numeric
	Local nFormat		As Numeric
	Local lRet			AS Logical
	Local aAux			AS Array

	Default aWorkSheet	:= {}
	Default cOrigem		:= ""
	Default cTitulo		:= ""
	Default aTabDePara	:= {}

	cWorkSheet	:= ""
	cTable		:= ""
	cArqXml		:= cOrigem + '_' + Dtos( dDataBase ) + '_' + StrTran( Time(), ':', '' ) +'.xml'
	If __lSmtHTML
		cArqXLS 	:= GetTempPath( .T. )
	Else
		cArqXLS 	:= cGetFile('',STR0071,0,,.F.,GETF_LOCALHARD+ GETF_RETDIRECTORY+GETF_NETWORKDRIVE) //"Selecione o Diretório"
	EndIf
	cAlias		:= ""
	cNomeAlias	:= ""
	cNameCol	:= ""
	cCampo 		:= ""
	cTipo		:= ""
	oExcel		:= Nil
	nA 			:= 0
	nH 			:= 0
	nX 			:= 0
	nAlign	 	:= 0
	nFormat		:= 0
	lRet		:= .F.
	aAux		:= {}
	cCpoExc 	:= "FIF_FILIAL/E1_FILIAL/E1_FILORIG/E1_SALDO/OK"
	aAdd(aTabDePara, {"FIF", "FIF"})
	aAdd(aTabDePara, {"E1", "SE1"})

	If !Empty(cArqXLS) .And. Len(aWorkSheet) > 0

		oExcel := FwMsExcel():New()

		For nX := 1 to Len(aWorkSheet)

			cNomeAlias 	:= ""
			aHeader 	:= aClone(aWorkSheet[nX][1])
			aCols 		:= aClone(aWorkSheet[nX][2])

			If Len(aHeader) > 0
				cAlias := SubStr(aHeader[1][3], 1, (At("_",aHeader[1][3])-1))
				If ( nPos := aScan(aTabDePara, {|x| x[1] == cAlias}) ) > 0
					cAlias := aTabDePara[nPos][2]
					cNomeAlias := Lower(Alltrim(FWX2NOME(cAlias)))
					cNomeAlias := Upper(LEFT(cNomeAlias,1))+Substr(cNomeAlias,2,Len(cNomeAlias)-1)
				Else
					cNomeAlias := cAlias
				EndIf
				cTable := cTitulo + Iif(!Empty(cNomeAlias), " - " + cNomeAlias, "")
				cWorkSheet	:= cOrigem + Iif(!Empty(cNomeAlias), " - " + cNomeAlias, "")

				oExcel:AddWorkSheet( cWorkSheet )
				oExcel:AddTable( cWorkSheet, cTable )

				For nH := 1 to Len(aHeader)

					cCampo 	 := Alltrim(aHeader[nH][3])
					If !(cCampo $ cCpoExc )

						cNameCol := aHeader[nH][1]
						cTipo	 := aHeader[nH][4]
						nAlign	 := IIf( cTipo == 'N', 3, 1 ) //Alinhamento da coluna ( 1-Left,2-Center,3-Right )

						//Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
						If cTipo == 'C'
							nFormat	 := 1
						ElseIf cTipo == 'D'
							nFormat	 := 4
						Else
							nFormat	 := 2
						EndIf

						oExcel:AddColumn( cWorkSheet, cTable, cNameCol, nAlign, nFormat, .F. )

					EndIf

				Next nH

				For nA := 1 to Len(aCols)
					aAux := {}
					For nH := 1 to Len(aHeader)
						cCampo 	 := Alltrim(aHeader[nH][3])
						If !(cCampo $ cCpoExc )
							Aadd( aAux, aCols[nA][nH] )
						EndIf
					Next nH
					oExcel:AddRow( cWorkSheet, cTable, aAux )
				Next nA
			EndIf

		Next nX

		oExcel:Activate()
		oExcel:GetXMLFile( cArqXml )

		If ( CpyS2T ( cArqXml, cArqXLS, .T. ) )
			lRet := .T.
			MsgInfo(STR0072+' "' + cArqXml + '" ') //"Arquivo gerado com sucesso:"
		Else
			Alert(STR0073) //"Não foi possível gravar o arquivo!"
		EndIf

		If File( cArqXml )
			FErase( cArqXml )
		EndIf

	EndIf

	Return lRet


	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916Lock
	Controle de concorrência para efetivação da conciliação - lock de seleção

	@author Marcelo Ferreira
	@since 08/12/2018
	@version 12.1.17
	/*/
	//-------------------------------------------------------------------
Static Function F916Lock(oModGrid As Object, nGrid As Numeric) As Logical
	Local lRet 		As Logical
	Local lTravou 	As Logical
	Local cQuery 	As Character
	Local cTabQry 	As Character
	Local cMsg 		As Character
	Local nOpc 		As Numeric

	Default oModGrid 	:= Nil
	Default nGrid		:= 1

	lRet 	:= .T.
	lTravou := .F.
	cQuery 	:= ""
	cTabQry	:= CriaTrab(Nil, .F.)
	cMsg 	:= ""
	nOpc 	:= 1

	If nGrid == 1

		cQuery := " SELECT R_E_C_N_O_ RECNO " + CRLF
		cQuery += " FROM "+RetSqlName("FIF") + CRLF
		cQuery += " WHERE FIF_DTCRED  = '" + DtoS(oModGrid:GetValue("FIF_DTCRED")) +"' " + CRLF
		cQuery += "   AND FIF_NSUTEF  = '" + oModGrid:GetValue("FIF_NSUTEF") +"' " + CRLF
		cQuery += "   AND FIF_PARCEL  = '" + oModGrid:GetValue("FIF_PARCEL") +"' " + CRLF
		cQuery += "   AND FIF_CODFIL  = '" + oModGrid:GetValue("FIF_CODFIL") +"' " + CRLF
		cQuery += "   AND FIF_DTTEF   = '" + DtoS(oModGrid:GetValue("FIF_DTTEF"))  +"' " + CRLF
		cQuery += "   AND D_E_L_E_T_  = ' ' " + CRLF
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTabQry,.F.,.T.)

		If !(cTabQry)->( Eof() ) .And. (cTabQry)->RECNO > 0
			dbSelectArea("FIF")
			FIF->( dbGoTo( (cTabQry)->RECNO) )

			If !oModGrid:GetValue("OK") // Se estiver selecionado e está desmarcando efetua a liberação do lock de seleção
				FIF->( dbRUnlock( FIF->( Recno() ) ) )
			Else
				cMsg :=  CRLF + STR0041 + DtoC(FIF->FIF_DTTEF) + CRLF + " " + STR0042 + FIF->FIF_NSUTEF + CRLF + " " + STR0043 + FIF->FIF_PARCEL //" Data Venda: "###"NSU Sitef: "###"Parcela: "
				While !lTravou .And. nOpc == 1
					//Verifica se o item ainda continua aberto para CONCILIAÇÃO, pode ter sido CONCILIADO em outra sessão
					If FIF->FIF_STVEND == '1' // 1-Nao Processado
						If FIF->( dbRLock( FIF->( Recno() ) ) )
							lTravou := .T.
						Else
							nOpc := AVISO(STR0075, STR0076; //"Controle de Concorrência"###"Item em uso por outra sessão e não poderá ser selecionado."
							+ CRLF + STR0077 + CRLF + cMsg, ; //"O que deseja efetuar? "
							{ STR0078, STR0079}, 2)  //"Tentar Novamente?"###"Desconsiderar item"
						EndIf
					Else
						Help(,,"F916Lock",,STR0080,1,0,,,,,,{STR0081}) //"Outro processo utilizou o item enquanto este não estava marcado, não será permitido conciliar este item."###"Item não liberado para seleção."
						nOpc := 3
					EndIf
				EndDo

				If nOpc == 2
					oModGrid:GetModel():SetErrorMessage(oModGrid:cID, 'OK', oModGrid:cID, 'OK', "F916VldChk", STR0082) //"Seleção desconsiderada."
				EndIf

				lRet := lTravou

			EndIf

		EndIf

		(cTabQry)->( dbCloseArea() )

	Else

		SE1->( dbSetOrder(1) ) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If SE1->( dbSeek( xFilial("SE1", oModGrid:GetValue("E1_XFILORI") ) + oModGrid:GetValue("E1_PREFIXO") + oModGrid:GetValue("E1_NUM") + oModGrid:GetValue("E1_PARCELA") + oModGrid:GetValue("E1_TIPO") ) ) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

			If !oModGrid:GetValue("OK") // Se estiver selecionado e está desmarcando efetua a liberação do lock de seleção
				SE1->( dbRUnlock( SE1->( Recno() ) ) )
			Else
				cMsg :=  " " + STR0083 + SE1->E1_PREFIXO + CRLF + " " + STR0084 + SE1->E1_NUM + CRLF + " " + STR0085 + SE1->E1_PARCELA + CRLF + " " + STR0086 + SE1->E1_TIPO //"Prefixo: " "###"Num. Título: "###"Parcela: "###"Tipo: ""
				While !lTravou .And. nOpc == 1
					cQuery := " SELECT FIF_STVEND, R_E_C_N_O_ RECNO " + CRLF
					cQuery += " FROM "+RetSqlName("FIF") + CRLF
					cQuery += " WHERE FIF_DTTEF   = '" + DtoS(SE1->E1_EMISSAO) +"' " + CRLF
					If __lOracle .or. __lPostGre
						cQuery += "   AND LPAD(TRIM(FIF_NSUTEF), "+__cTamNSU+", '0')   = '" + PADL(ALLTRIM(SE1->E1_NSUTEF),VAL(__cTamNSU),"0")  +"' " + CRLF
					Else
						cQuery += "   AND  REPLICATE('0', "+__cTamNSU+" - LEN(FIF_NSUTEF)) + RTrim(FIF_NSUTEF)   = '" + PADL(ALLTRIM(SE1->E1_NSUTEF),VAL(__cTamNSU),"0")  +"' " + CRLF
					Endif	
					cQuery += "   AND FIF_PARALF  = '" + SE1->E1_PARCELA +"' " + CRLF
					cQuery += "   AND FIF_CODFIL  = '" + SE1->E1_FILORIG +"' " + CRLF
					cQuery += "   AND D_E_L_E_T_  = ' ' " + CRLF
					cQuery := ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTabQry,.F.,.T.)

					If !(cTabQry)->( Eof() ) .And. !Empty( (cTabQry)->FIF_STVEND )
						dbSelectArea("FIF")
						FIF->( dbGoTo( (cTabQry)->RECNO) )

						//Verifica se o item ainda continua aberto para CONCILIAÇÃO, pode ter sido CONCILIADO em outra sessão
						If (cTabQry)->FIF_STVEND == '1' // 1-Nao Processado
							If SE1->( dbRLock( SE1->( Recno() ) ) )
								lTravou := .T.
							Else
								nOpc := AVISO(STR0075, STR0076; //"Controle de Concorrência"###"Item em uso por outra sessão e não poderá ser selecionado."
								+ CRLF + STR0077 + CRLF + cMsg, ; //"O que deseja efetuar? "
								{ STR0078, STR0079}, 2)  //"Tentar Novamente?"###"Desconsiderar item"
							EndIf
						Else
							Help(,,"F916Lock",,STR0080,1,0,,,,,,{STR0081}) //"Outro processo utilizou o item enquanto este não estava marcado, não será permitido conciliar este item."###"Item não liberado para seleção."
							nOpc := 3
						EndIf
					Else
						If SE1->( dbRLock( SE1->( Recno() ) ) )
							lTravou := .T.
						Else
							nOpc := AVISO(STR0075, STR0076; //"Controle de Concorrência"###"Item em uso por outra sessão e não poderá ser selecionado."
							+ CRLF + STR0077 + CRLF + cMsg, ; //"O que deseja efetuar? "
							{ STR0078, STR0079}, 2)  //"Tentar Novamente?"###"Desconsiderar item"
						EndIf
					EndIf
					(cTabQry)->( dbCloseArea() )
				EndDo

				If nOpc == 2
					oModGrid:GetModel():SetErrorMessage(oModGrid:cID, 'OK', oModGrid:cID, 'OK', "F916VldChk", STR0082) //"Seleção desconsiderada."
				EndIf

				lRet := lTravou

			EndIf

		EndIf

	EndIf

	Return lRet


	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916Cancel
	Função executada no cancelamento da tela de conciliação.

	@author Marcelo Ferreira
	@since 08/12/2018
	@version 12.1.17
	/*/
	//-------------------------------------------------------------------
Static Function F916Cancel() As Logical
	Local lRet := .T.

	// Efetua a liberação de todos os locks de seleção no cancelamento da tela
	FIF->( dBUnlockAll() )
	SE1->( dBUnlockAll() )

	Return lRet


	//-------------------------------------------------------------------
	/*/{Protheus.doc} F916Cont
	Função executada para contagem de registros nas grids.

	@author Igor Fricks
	@since 27/02/2019
	@version 12.1.17
	/*/
	//-------------------------------------------------------------------
Static Function F916Cont(oModel,cModel) As Numeric
	Local oMaster	:= oModel:GetModel()
	Local oModelM	:= oMaster:GetModel(cModel)
	Local nLinhas := 0

	nLinhas := oModelM:GetQtdLine()

	Return nLinhas

	/*/{Protheus.doc} OrderToPrt
	Reordena o Array do model para que a impressão no excel saia igual ao View
	@type  Function
	@author santos.renato
	@since 06/06/2019
	@version version
	@param aOrdStruct As Arrays
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OrderToPrt(aOrdStruct As Array, nSheet As Numeric, ntable As Numeric, cGrid As Character) As Array

	Local nL			As Numeric

	Local aChave 		As Array
	Local aNewStruct 	As Array
	Local aNewHash 		As Array

	Default cGrid		:= ""
	Default aOrdStruct	:= {}
	Default nSheet		:= 0
	Default ntable 		:= 0

	nL			:= 0
	lOrdem		:= .F.
	aRet		:= {}
	aChave		:= {}
	aNewStruct 	:= {}
	aNewHash	:= {}


	If nSheet == 1
		If  nTable == 1
			aChave := {'FIF_FILIAL','FIF_DTTEF','FIF_CODFIL','FIF_VLBRUT','FIF_VLLIQ','FIF_NSUARQ','FIF_CODAUT','FIF_CODLOJ','FIF_CODEST','FIF_DTCRED','FIF_TPREG','FIF_NURESU','FIF_NUCOMP','FIF_TPPROD','FIF_CODBCO','FIF_CODAGE','FIF_NUMCC','FIF_VLCOM','FIF_TXSERV','FIF_NUM','FIF_PARCEL','FIF_PARALF','FIF_PARC','FIF_STVEND','FIF_CODBAN','FIF_CODADM','FIF_SEQFIF'}
		Else
			aChave := {'E1_FILIAL','E1_EMISSAO','E1_XFILORI','E1_VLRREAL','E1_VALOR','E1_XVLRTEF','E1_XSALDO','E1_NSUTEF','E1_XCARTAUT','E1_CLIENTE','E1_LOJA','E1_NOMCLI','E1_VENCTO','E1_VENCREA','E1_PREFIXO','E1_NUM','E1_PARCELA','E1_TIPO','E1_NATUREZ'}
		EndIf
	ElseIf  nSheet == 2
		If nTable == 1
			aChave := {'FIF_FILIAL','FIF_DTTEF','FIF_CODFIL','FIF_VLBRUT','FIF_VLLIQ','FIF_NSUARQ','FIF_CODAUT','FIF_CODLOJ','FIF_CODEST','FIF_DTCRED','FIF_TPREG','FIF_NURESU','FIF_NUCOMP','FIF_TPPROD','FIF_CODBCO','FIF_CODAGE','FIF_NUMCC','FIF_VLCOM','FIF_TXSERV','FIF_NUM','FIF_PARCEL','FIF_PARALF','FIF_PARC','FIF_STVEND','FIF_CODBAN','FIF_CODADM','FIF_SEQFIF','FIF_CODJUS','FIF_DESJUS','FIF_DESJUT'}
		Else
			aChave := {'E1_FILIAL','E1_EMISSAO','E1_XFILORI','E1_VLRREAL','E1_VALOR','E1_XVLRTEF','E1_XSALDO','E1_NSUTEF','E1_XCARTAUT','E1_CLIENTE','E1_LOJA','E1_NOMCLI','E1_VENCTO','E1_VENCREA','E1_PREFIXO','E1_NUM','E1_PARCELA','E1_TIPO','E1_NATUREZ'}
		EndIf
	ElseIf nSheet == 3
		aChave := {'E1_FILIAL','E1_EMISSAO','E1_XFILORI','E1_VLRREAL','E1_VALOR','E1_XSALDO','E1_NSUTEF','E1_XCARTAUT','E1_CLIENTE','E1_LOJA','E1_NOMCLI','E1_VENCTO','E1_VENCREA','E1_PREFIXO','E1_NUM','E1_PARCELA','E1_TIPO','E1_NATUREZ','E1_XVALLIQ',"FIF_XCODJU","FIF_XDESJU","FIF_XDESJT"}
	ElseIf nSheet == 4
		If nTable == 1
			aChave := {'FIF_FILIAL','FIF_DTTEF','FIF_CODFIL','FIF_VLBRUT','FIF_VLLIQ','FIF_NSUARQ','FIF_CODAUT','FIF_CODLOJ','FIF_CODEST','FIF_DTCRED','FIF_TPREG','FIF_NURESU','FIF_NUCOMP','FIF_TPPROD','FIF_CODBCO','FIF_CODAGE','FIF_NUMCC','FIF_VLCOM','FIF_TXSERV','FIF_NUM','FIF_PARCEL','FIF_PARALF','FIF_PARC','FIF_STVEND','FIF_CODBAN','FIF_CODADM','FIF_SEQFIF','FIF_CODJUS','FIF_DESJUS','FIF_DESJUT'}
		Else
			aChave := {'E1_FILIAL','E1_EMISSAO','E1_XFILORI','E1_VLRREAL','E1_VALOR','E1_XSALDO','E1_NSUTEF','E1_XCARTAUT','E1_CLIENTE','E1_LOJA','E1_NOMCLI','E1_VENCTO','E1_VENCREA','E1_PREFIXO','E1_NUM','E1_PARCELA','E1_TIPO','E1_NATUREZ','E1_XVALLIQ'}
		EndIf
	ElseIf nSheet == 5
		aChave := {'FIF_FILIAL','FIF_DTTEF','FIF_CODFIL','FIF_VLBRUT','FIF_VLLIQ','FIF_NSUARQ','FIF_CODAUT','FIF_CODEST','FIF_TPREG','FIF_CODLOJ','FIF_NURESU','FIF_NUCOMP','FIF_TPPROD','FIF_CODBCO','FIF_CODAGE','FIF_NUMCC','FIF_VLCOM','FIF_TXSERV','FIF_NUM','FIF_PARCEL','FIF_PARALF','FIF_PARC','FIF_STVEND','FIF_CODBAN','FIF_CODADM','FIF_SEQFIF','FIF_CODMAJ','FIF_CODJUS','FIF_DESJUS','FIF_DESJUT'}
	EndIf

	oHash := AToHM(aOrdStruct,3)
	For nL := 1 to Len(aChave)
		HMGet(oHash, aChave[nL], aNewHash)
		AADD(aNewStruct, aNewHash[1])
	Next nL
	ASIZE( aNewHash, 0 )
	ASIZE( aChave, 0 )
	HMClean(oHash)
	FreeObj(oHash)

	Return aNewStruct

//------------------------------------------------------------------------------
/*/{Protheus.doc} F916Fechar

Função executada através do bloco de Cancelamento da Tela. Configura a View
como se não tivesse sido alterada.

@type 		Function
@author 	renato.ito
@param		Nenhum
@since		15/10/2019
@version	P12
@return 	True
/*/
//------------------------------------------------------------------------------
Static Function F916Fechar() As Logical

	Local oView	:= FwViewActive()

	oView:SetModified(.F.)

Return(.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} F916MEP
Retorna as informações para conciliação utilizando a tabela Mep.
@type 		Function
@author 	Jose.Gavetti
@since		26/12/2019
@version	P12
@return 	True
/*/
//------------------------------------------------------------------------------
Static Function F916MEP(oMdl As Object, nOpc As Numeric, cQuery As Character , lTotal As Logical ) As Array

	Local lExclusivo	As Logical
	Local lExclusMEP	As Logical
	Local lFilFif 		As Logical
	Local cFilAdm		As Character
	Local aArea 		As Array
	Local cAliasFIF		As Character   
	Local cQry 			As Character

	Default oMdl   := Nil
	Default nOpc   := 1
	Default cQuery := ""
	Default lTotal := .F.

	cFilAdm		:= ""
	lFilFif		:= F916ChkMod("FIF") 
	lExclusivo	:= F916ChkMod("SE1")
	lExclusMEP	:= F916ChkMod("MEP")
	cAliasFIF	:= GetNextAlias()    
	aArea 		:= GetArea()
	cQry 		:= ''

	//Restauro o valor padrão das variáveis staticas.
	__aParcMep := {}
	__nX := 1

	If !lTotal
		cQry := "SELECT FIF.FIF_CODEST,FIF.FIF_CODLOJ,FIF.FIF_NUCOMP,FIF.FIF_DTTEF,FIF.FIF_VLLIQ,FIF.FIF_NSUTEF,FIF.FIF_NSUARQ,FIF.FIF_PARCEL,FIF.FIF_DTCRED, "
		cQry += "FIF.FIF_CODFIL,FIF.FIF_STATUS,FIF.FIF_PREFIX,FIF.FIF_NUM,FIF.FIF_CODRED,FIF.FIF_PARC,FIF_NUCART,FIF.FIF_TIPO,FIF.FIF_PARALF,FIF.FIF_CODBCO, "
		cQry += "FIF.FIF_CODAGE, FIF.FIF_CODMAJ,FIF.FIF_NUMCC,FIF.FIF_CAPTUR,FIF.R_E_C_N_O_ RECNO_FIF,FIF.FIF_FILIAL, FIF.FIF_CODAUT, FIF.FIF_TPREG, FIF.FIF_NURESU, "
		cQry += "FIF.FIF_TPPROD,FIF.FIF_TXSERV,FIF.FIF_STVEND, FIF.FIF_CODBAN, FIF.FIF_SEQFIF,FIF.FIF_VLCOM,FIF.FIF_VLBRUT, FIF.FIF_PGJUST, FIF.FIF_PGDES1, "
		cQry += "FIF.FIF_PGDES2, FIF.FIF_TPREG, FIF.FIF_CODADM,SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO,SE1.E1_CLIENTE,SE1.E1_LOJA,SE1.E1_VALOR, "  
		cQry += "SE1.E1_SALDO, E1_CARTAUT,SE1.E1_EMISSAO,SE1.E1_VENCREA,SE1.E1_DOCTEF, SE1.E1_NSUTEF,SE1.E1_MSFIL,SE1.E1_FILORIG, SE1.E1_CARTAO,"
		cQry += "SE1.R_E_C_N_O_ RECNO_SE1,MEP.MEP_PARTEF, MEP.MEP_PARCEL "
	Else
		cQry := "SELECT	FIF.FIF_DTTEF	DATA"  
		If nOpc == 1
			cQry += ",'1'				ABA"  
		else
			cQry += ",'2'				ABA"  
		Endif		
		cQry += ",SUM(FIF.FIF_VLBRUT)	VALOR" 
		cQry += ",SUM(FIF.FIF_VLLIQ)	VLLIQ" 
		cQry += ",COUNT(FIF.FIF_DTTEF)	QUANT"
		cQry += ",FIF.FIF_NUCOMP,FIF.FIF_NSUTEF,"
		cQry += "FIF.FIF_PARCEL,FIF.FIF_DTCRED,FIF.FIF_STATUS,FIF.FIF_CODRED,FIF.FIF_PARC,FIF.FIF_TIPO,FIF.FIF_PARALF,FIF.R_E_C_N_O_ RECNO_FIF,FIF.FIF_TIPO,"
		cQry += "FIF.R_E_C_N_O_ RECNO_FIF,FIF.FIF_FILIAL, FIF.FIF_CODAUT, FIF.FIF_TPPROD, FIF.FIF_STVEND, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA,"
		cQry += "SE1.E1_TIPO, SE1.E1_SALDO, SE1.E1_CARTAUT, SE1.E1_EMISSAO, SE1.E1_DOCTEF, SE1.E1_NSUTEF,SE1.E1_FILORIG,SE1.R_E_C_N_O_ RECNO_SE1,"
		cQry += "MEP.MEP_PARTEF, MEP.MEP_PARCEL, FIF.FIF_CODADM, FIF.FIF_CODMAJ, FIF.FIF_CODFIL "
	Endif
	
	cQry += " FROM " + RetSqlName("SE1") + " SE1 JOIN " + RetSqlName("FIF") + " FIF ON "

	If !__lDocTEF
		If __lOracle .OR. __lPostGre
			cQry += " LPAD(TRIM(SE1.E1_NSUTEF), "+__cTamNSU+", '0') = LPAD(TRIM(FIF.FIF_NSUTEF), "+__cTamNSU+", '0') "
		Else
			cQry += " REPLICATE('0', "+__cTamNSU+" - LEN(SE1.E1_NSUTEF)) + RTrim(SE1.E1_NSUTEF) =  REPLICATE('0', "+__cTamNSU+" - LEN(FIF.FIF_NSUTEF)) + RTrim(FIF.FIF_NSUTEF) "
		Endif	                                                    
	ElseIf __lDocTEF
		cQry += " CAST(E1_DOCTEF AS INT) = CAST(FIF_NUCOMP AS INT) "
	Endif

	cQry += " AND  SE1.E1_EMISSAO = FIF.FIF_DTTEF "
	cQry += " AND  SE1.E1_FILORIG = FIF.FIF_CODFIL "
	cQry += " AND  (SE1.E1_CARTAUT = FIF.FIF_CODAUT OR FIF.FIF_CODAUT = ' ') "

	cQry += " JOIN " + RetSqlName("MEP") + " MEP ON "
	cQry += " SE1.E1_FILIAL = MEP.MEP_FILIAL "
	cQry += " AND SE1.E1_PREFIXO = MEP.MEP_PREFIX "
	cQry += " AND SE1.E1_NUM = MEP.MEP_NUM "
	cQry += " AND SE1.E1_PARCELA = MEP.MEP_PARCEL "
	cQry += " AND SE1.E1_TIPO = MEP.MEP_TIPO "
	cQry += " AND SE1.E1_FILORIG = MEP.MEP_MSFIL "
		
	cQry += " WHERE "

	If MV_PAR01 == 1
		If Len( __aSelFil ) <= 0
			cQry += "FIF_CODFIL = '" + Iif( lFilFif, xFilial("FIF", __cFilAnt), __cFilAnt) + "' AND "
		Else
			If !__lTodFil
				cQry += "FIF_CODFIL " + GetRngFil( __aSelFil, 'FIF', .T.,, 20, .T. ) + " AND "
			EndIf
		EndIf
	Else
		cQry += "FIF_CODFIL = '" + Iif( lFilFif, xFilial("FIF", __cFilAnt), __cFilAnt) + "' AND "
	EndIf

	If MV_PAR06 == 1
		cQry += " SE1.E1_TIPO = 'CD' "
	ElseIf	MV_PAR06 == 2
		cQry += " SE1.E1_TIPO = 'CC' "
	Else
		cQry += " SE1.E1_TIPO IN ('CD','CC') "
	EndIf

	cQry += " AND SE1.E1_SALDO > 0 "
	
	If MV_PAR01 == 1 .and. Len( __aSelFil ) > 0
		If  lExclusivo	
			cQry += "AND SE1.E1_FILIAL " + GetRngFil( __aSelFil, 'SE1', .T.,, 20, .F. )
		Else 
			cQry += "AND SE1.E1_FILIAL = '" + xFilial("SE1", __cFilAnt) + "' " 	
			cQry += "AND SE1.E1_FILORIG " + GetRngFil( __aSelFil, 'SE1', .T.,, 20, .T. )
		EndIf
	Else
		cQry += " AND SE1.E1_FILIAL = '" + xFilial("SE1", __cFilAnt) + "' " 
		cQry += " AND SE1.E1_FILORIG = '" + __cFilAnt + "' "
	EndIf

	cQry += " AND SE1.D_E_L_E_T_ = ' ' "

	If MV_PAR01 == 1 .and. lExclusMEP
		If Len( __aSelFil ) <= 0
			cQry += "AND MEP.MEP_FILIAL = '" + xFilial("MEP", __cFilAnt) + "' " 
		Else
			cQry += "AND MEP.MEP_FILIAL " + GetRngFil( __aSelFil, 'MEP', .T.,, 20, .F. )
		EndIf	
		cQry += " AND MEP.MEP_FILIAL = FIF.FIF_CODFIL "
	Else
		cQry += " AND MEP.MEP_FILIAL = '" + xFilial("MEP", __cFilAnt) + "' "
	EndIf

	cQry += " AND MEP.MEP_MSFIL = FIF.FIF_CODFIL "
	cQry += " AND FIF.FIF_PARCEL = MEP.MEP_PARTEF "
	cQry += " AND FIF.FIF_DTTEF BETWEEN '" + dTos(MV_PAR02) + "' AND '" + dTos(MV_PAR03) + "' "

	If !__lDocTEF .And. (__lOracle .OR. __lPostGre)
		cQry += " AND LPAD(TRIM(FIF.FIF_NSUTEF), " + __cTamNSU + ", '0') BETWEEN '" + cNsuInicial + "' AND '" + cNsuFinal + "' "
	ElseIf !__lDocTEF 
		cQry += " AND REPLICATE('0', " + __cTamNSU + " - LEN(FIF.FIF_NSUTEF)) + RTrim(FIF.FIF_NSUTEF) BETWEEN '" + cNsuInicial + "' AND '" + cNsuFinal + "' "
	ElseIf __lDocTEF .And. (__lOracle .OR. __lPostGre)
		cQry += " AND LPAD(TRIM(FIF.FIF_NUCOMP), " + __cTamDOC + ", '0') BETWEEN '" + cNsuInicial + "' AND '" + cNsuFinal + "' "
	Else
		cQry += " AND REPLICATE('0', " + __cTamDOC + " - LEN(FIF.FIF_NUCOMP)) + RTrim(FIF.FIF_NUCOMP) BETWEEN '" + cNsuInicial + "' AND '" + cNsuFinal + "' "
	Endif
	
	cQry += "AND  FIF_STVEND = '1' "
	cQry += "AND  FIF_TPREG <> '3' " // 3-Ajustes
		
	If !Empty(MV_PAR08)
		cFilAdm := FormatIn(Alltrim(MV_PAR08), ";")
		If __lSOFEX
			cQry += "AND FIF_CODRED IN " + cFilAdm + " "
		Else
			cQry += "AND FIF_CODADM IN " + cFilAdm + " "
		EndIf
	EndIf

	If nOpc == 1
		cQry += " AND FIF_VLLIQ >= (SE1.E1_SALDO)  - ((SE1.E1_SALDO)  * " + AllTrim(Str(__nMargem)) + " / 100) "
	else
		cQry += " AND FIF_VLLIQ < (SE1.E1_SALDO)  - ((SE1.E1_SALDO)  * " + AllTrim(Str(__nMargem)) + " / 100) "
	EndIf	
				
	If MV_PAR06 == 1
		cQry += " AND FIF.FIF_TPPROD IN ('D','V') "
	ElseiF	MV_PAR06 == 2
		cQry += " AND FIF.FIF_TPPROD = 'C' "
	Else
		cQry += " AND FIF.FIF_TPPROD IN ('D','V','C') "
	EndIf

	If __lOracle .or. __lPostGre
		cQry += "AND SUBSTR(E1_TIPO,2,1) = FIF_TPPROD "
	Else
		cQry += "AND SUBSTRING(E1_TIPO,2,1) = FIF_TPPROD "
	EndIF

	cQry += "AND MEP.D_E_L_E_T_ = ' ' "
	cQry += "AND FIF.D_E_L_E_T_ = ' ' "
	
	If !lTotal
		If __lOracle 
			cQry += " AND ROWNUM <= " + STR(GRIDMAXLIN) + " "
		EndIf
		cQry += " ORDER BY "
		cQry += " RECNO_SE1 "
	Else	
		cQry += "GROUP BY FIF.FIF_DTTEF, FIF.FIF_NUCOMP,FIF.FIF_NSUTEF,FIF.FIF_PARCEL,FIF.FIF_DTCRED,FIF.FIF_STATUS,FIF.FIF_CODRED,FIF.FIF_PARC,FIF.FIF_CODMAJ,
		cQry += "FIF.FIF_TIPO,FIF.FIF_PARALF,FIF.R_E_C_N_O_,FIF.FIF_FILIAL,FIF.FIF_CODAUT,FIF.FIF_TPPROD,FIF.FIF_STVEND,SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO,
		cQry += "SE1.E1_SALDO,SE1.E1_CARTAUT,SE1.E1_EMISSAO,SE1.E1_DOCTEF,SE1.E1_NSUTEF,SE1.E1_FILORIG,SE1.R_E_C_N_O_,MEP.MEP_PARTEF,MEP.MEP_PARCEL,FIF.FIF_CODADM,FIF.FIF_CODFIL "
		cQry += "ORDER BY DATA, ABA "
	Endif	

	cQry := ChangeQuery(cQry)

	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQry), cAliasFIF, .T., .T.)

	TcSetField(cAliasFIF,"FIF_DTTEF","D", 8)
	TcSetField(cAliasFIF,"FIF_DTCRED","D", 8)

	cQuery := cQry

	If oMdl <> Nil
		__aRetFIF := FWLoadByAlias( oMdl, cAliasFIF,,,,.T.) // Como tem o campo R_E_C_N_O_ na query, nao é preciso informar qual o campo contem o Recno() real
	Endif	

	(cAliasFIF)->( dbCloseArea() )

	RestArea( aArea )

Return __aRetFIF

//------------------------------------------------------------------------------
/*/{Protheus.doc} F916CONC
Retorna a relação entre as tabelas FIF x SE1
@type 		Function
@author 	Jose.Gavetti
@since		03/01/2020
@version	P12
@return 	True
/*/
//------------------------------------------------------------------------------
Static Function F916CONC(oMdlSE1 As Object, nOpc As Numeric) As Array

	Local oModel 		As Object
	Local oMdlFif  		As Object
	Local cParcMep   	As Character
	Local cAliasSE1 	As Character
	Local cQuery 		As Character
	Local __aRetSE1 	As Array
	Local aArea 		As Array

	Default oMdlSE1 := Nil
	Default nOpc 	:= 1

	 oModel 		:= Nil
	 oMdlFif  		:= Nil
	 cParcMep   	:= ''
	 cAliasSE1 		:= ''
	 __aRetSE1 		:= {}
	 aArea 			:= GetArea()

	oModel  := oMdlSE1:GetModel()
	If nOpc = 1
		oMdlFIF := oModel:GetModel('FIFFLD1')
	else
		oMdlFIF := oModel:GetModel('FIFFLD2')	
	Endif	

	cAliasSE1 := GetNextAlias()

	cQuery := " SELECT SE1.E1_FILIAL, SE1.E1_FILORIG, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_NATUREZ, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NOMCLI,
	cQuery += " SE1.E1_NSUTEF, SE1.E1_EMISSAO, SE1.E1_VENCTO, SE1.E1_VENCREA, SE1.E1_VALOR, SE1.E1_SALDO, SE1.E1_VLRREAL, SE1.E1_CARTAUT , SE1.E1_CARTAO, SE1.R_E_C_N_O_ RECNO_SE1, 
	cQuery += " SE1.R_E_C_N_O_, MEP.MEP_PARTEF, MEP.MEP_PARCEL, MEP.MEP_FILIAL, MEP.MEP_PREFIX, MEP.MEP_NUM, MEP.MEP_TIPO, MEP.MEP_MSFIL"
	cQuery += " FROM " + RetSqlName("SE1") + " SE1"
	cQuery += " JOIN " + RetSqlName("MEP") + " MEP ON "
	cQuery += " SE1.E1_FILIAL 	= MEP.MEP_FILIAL AND "
	cQuery += " SE1.E1_PREFIXO 	= MEP.MEP_PREFIX AND "
	cQuery += " SE1.E1_NUM 		= MEP.MEP_NUM 	 AND "
	cQuery += " SE1.E1_PARCELA 	= MEP.MEP_PARCEL AND "
	cQuery += " SE1.E1_TIPO 	= MEP.MEP_TIPO 	 AND "
	cQuery += " SE1.E1_FILORIG 	= MEP.MEP_MSFIL "
	cQuery += " WHERE SE1.E1_FILIAL = '" + oMdlFIF:GetValue('FIF_CODFIL') 	+ "'"
	
	If __lDocTEF
		If __lOracle .Or. __lPostGre
			cQuery += " AND LPAD(TRIM(SE1.E1_DOCTEF), " + __cTamDOC + ", '0') =  '" + PADL(ALLTRIM(oMdlFIF:GetValue("FIF_NUCOMP")), VAL(__cTamDOC),"0") + "'"
		Else
			cQuery += " AND REPLICATE('0', " + __cTamDOC + " - LEN(SE1.E1_DOCTEF)) + RTrim(SE1.E1_DOCTEF) 	= '" + PADL(ALLTRIM(oMdlFIF:GetValue("FIF_NUCOMP")), VAL(__cTamDOC),"0") + "'"
		EndIf
	Else
		If __lOracle .Or. __lPostGre
			cQuery += " AND LPAD(TRIM(SE1.E1_NSUTEF), " + __cTamNSU + ", '0') =  '" + PADL(ALLTRIM(oMdlFIF:GetValue("FIF_NSUTEF")), VAL(__cTamNSU),"0") + "'"
		Else
			cQuery += " AND REPLICATE('0', " + __cTamNSU + " - LEN(SE1.E1_NSUTEF)) + RTrim(SE1.E1_NSUTEF) 	= '" + PADL(ALLTRIM(oMdlFIF:GetValue("FIF_NSUTEF")), VAL(__cTamNSU),"0") + "'"
		EndIf
	EndIf

	cQuery += " AND SE1.E1_EMISSAO 	= '" + DtoS(oMdlFIF:GetValue("FIF_DTTEF")) 	+ "'"

	If !Empty(oMdlFIF:GetValue('FIF_CODAUT'))
		cQuery += " AND SE1.E1_CARTAUT = '" + oMdlFIF:GetValue('FIF_CODAUT') + "'"
	EndIf

	cQuery += " AND SE1.E1_PARCELA 	= '" + oMdlFIF:GetValue('MEP_XPARCEL') 	+ "'"
	cQuery += " AND SE1.D_E_L_E_T_ 	= ' '"
	cQuery += " ORDER BY "
	cQuery += " RECNO_SE1 "
	
	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSE1,.F.,.T.)

	TcSetField(cAliasSE1,"E1_EMISSAO","D", 8)
	TcSetField(cAliasSE1,"E1_VENCTO","D", 8)
	TcSetField(cAliasSE1,"E1_VENCREA","D", 8)

	__aRetSE1 := FWLoadByAlias( oMdlSE1, cAliasSE1) // Como tem o campo R_E_C_N_O_ na query, nao é preciso informar qual o campo contem o Recno() real

	(cAliasSE1)->( dbCloseArea() )

	RestArea( aArea )

Return __aRetSE1
