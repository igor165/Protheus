#Include "FINA920A.CH" 
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "DBSTRUCT.CH"

#DEFINE GRIDMAXLIN 10000

Static __cCpoSE1		As Character
Static __cCpoFJU		As Character
Static __cCpoFIF		As Character
Static __bVldSE1		As Codeblock
Static __bVldFJU		As Codeblock
Static __bVldFIF		As Codeblock
Static __lCheck01		As Logical
Static __lCheck02		As Logical
Static __lCheck03		As Logical
Static __lCheck07		As Logical
Static __nFldPar		As Numeric
Static __cAdmFin		As Character
Static __lSOFEX			As Logical
Static __lSmtHTML		As Logical
Static __oDescri		As Object
Static __cFilAnt		As Character 
Static __lOracle		As Logical
Static __lPostGre   	As Logical
Static __lSQL			As Logical
Static __cTamNSU		As Character
Static __cTamDoc		As Character
Static __nTamNSU 		As Numeric
Static __nTamDOC 		As Numeric
Static __nFIFFLD1   	As Numeric
Static __nFIFFLD2   	As Numeric
Static __NFIFFLD3		As Numeric
Static __nSE1FLD3   	As Numeric
Static __nSE1FLD4   	As Numeric
Static __nFIFFLD4   	As Numeric
Static __nFIFFLD5   	As Numeric
Static __nFIFFLD7   	As Numeric
Static __nTamBco		As Numeric
Static __nTamAge		As Numeric
Static __nTamCC			As Numeric
Static __nTRecOri		As Numeric
Static __nTRecPai		As Numeric	
Static __aSelFil		As Array
Static __lPontoF		As Logical
Static __nThreads		As Numeric 
Static __nLoteThr		As Numeric
Static __lPrcDocT 		As Logical
Static __lConoutR		As Logical
Static __aBancos		As Array 
Static __lDocTef		As Logical
Static __cVarComb   	As Character
Static __aVarComb   	As Array
Static __lMEP			As Logical
Static __lA6MSBLQ		As Logical

Static __oAba1 			As Object
Static __oAba2 			As Object
Static __oAba3 			As Object
Static __oAba4FIF 		As Object
Static __oAba4SE1 		As Object
Static __oAba5 			As Object
Static __oAba7 			As Object

Static __nSelFil		As Numeric
Static __cFilIni		As Character
Static __cFilFim		As Character
Static __dDtCredI		As Date			
Static __dDtCredF		As Date			
Static __cNsuIni		As Character
Static __cNsuIni1		As Character
Static __cNsuFim		As Character
Static __cNsuFim1		As Character
Static __nConcilia		As Numeric		//Tipos de Baixa: 1- Baixa individual / 2-Baixa por lote
Static __nTpProc		As Numeric
Static __nQtdDias		As Numeric		//O número de dias anteriores ao da data de crédito que será utilizada como referencia de pesquisa nos titulos	
Static __nMargem		As Numeric		
Static __cAdmIni		As Character	
Static __cAdmFim		As Character
Static __lFIFDtCr 		As Logical
Static __nNsuCons		As Numeric	
Static __nTpPagam		As Numeric
Static __lMsgTef		As Logical
Static __lFIFRcE1		As Logical
Static __lUsaMep    	As Logical	
Static __aRetThrd		As Array
Static __oF918ADM		AS Object	
Static __lLJGERTX		As Logical
Static __cFilSA6		As Character
Static __lParcFIF		As Logical
Static __lTef  	    	As Logical 		//Identifica se é conciliação TEF
Static __lPixDig    	As Logical 		//Identifica se é conciliação PIX/Carteiras Digitais
Static __lAPixTpd		As Logical 		//Identifica se o ambiente está atualizado p/ conciliação PIX/Carteiras Digitais

Static __bLoadF01 	As Codeblock
Static __bLoadF02 	As Codeblock
Static __bLoadF03 	As Codeblock
Static __bLoadF04 	As Codeblock
Static __bLoadF05 	As Codeblock
Static __bLoadF07 	As Codeblock

Static __bLoadS04 	As Codeblock
//---------------------------------------------------------------------------
/*/{Protheus.doc} FINA920A
Rotina que efetua a conciliacao entre os dados recebidos pelo arquivo do 
SITFEF e os dados do Contas a Receber

@type Function
@author Rafael Rosa da Silva
@since 05/08/2009
@version 12   
/*/
//---------------------------------------------------------------------------
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do Modelo de Dados

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static Function ModelDef() As Object
	Local bVldOk	As Codeblock
	Local bLoadTot	As Codeblock
	Local b920Just	As Codeblock
	Local bValid	As Codeblock
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
	Local oStrFIF07	As Object
	Local oStrFJU07	As Object
	Local cParcFif	As Character
	Local cTitulo   As Character

	oModel 		:= MPFormModel():New("FINA920A")
	oStHead		:= StrHead(1)
	oStrTot06	:= StrTot(1)

	// Bloco de codigo para o valid do campo FVX_CODIGO
	bValid		:= FWBuildFeature( STRUCT_FEATURE_VALID	, 'ExistCpo("FVX")'	) 
	cParcFif	:= ""
	b920Just 	:= { |oModel| F920Justif(oModel) }	
	cTitulo		:= IIf(__lTef, STR0043, STR0271)

	/*-------------------------------------------------------------------
		Cabeçalho - Tabela Virtual
	-------------------------------------------------------------------*/
	oModel:AddFields("TMPHEADER", NIL, oStHead, NIL, NIL, {|| {"1"}})
	oModel:SetPrimaryKey({"STATUS"})
	oModel:GetModel("TMPHEADER"):SetDescription(cTitulo)
	oModel:SetDescription(cTitulo)
	oModel:GetModel("TMPHEADER"):SetOnlyQuery(.T.)
	
	/*-------------------------------------------------------------------
			Folder 1 - Conciliados
	-------------------------------------------------------------------*/
	If __nFldPar == 0 .Or. __nFldPar == 1;
			.Or. (__nTpProc == 1  .And. __nFldPar == 4) // quando o tipo de processamento é por abas e for a aba 4 será necessário passar pela aba 1 pois no 4 é reaproveitado a tabela temporáriana função F920TMPABAS

		bVldOk 			:= { |oModGrid| F920Lock(oModGrid) }
		oStrFIF01		:= FWFormStruct(1, "FIF", __bVldFIF)
		oStrSE101		:= FWFormStruct(1, "SE1", __bVldSE1)
		
		__bLoadF01 := { |oStrFIF01| loadGrids(oStrFIF01, 1) }
		oModel:AddGrid("FIFFLD1", "TMPHEADER", oStrFIF01,,,,, __bLoadF01)
		oModel:SetRelation("FIFFLD1", {{"'1'", "TMPHEADER.STATUS"}}, FIF->(IndexKey(1)))
		
		AddField(1, oStrFIF01, bVldOk, 1)
						
		SetProp(oModel:GetModel("FIFFLD1"), 1, oStrFIF01, STR0007, 1, "FIF")

		oModel:AddGrid("SE1FLD1", "FIFFLD1", oStrSE101)

		If __lMEP .And. __lUsaMep
			cParcFIF := "FIFFLD1.XPARCEL"
		Else
			If __lParcFIF
				cParcFIF := "FIFFLD1.FIF_PARALF"
			Else
				cParcFIF := "FIFFLD1.FIF_PARCEL"
			EndIf
		EndIf
		
		If __lPixDig
			oModel:SetRelation("SE1FLD1",{{"E1_DOCTEF","FIFFLD1.FIF_NUCOMP" },{"E1_CARTAUT","FIFFLD1.FIF_CODAUT"},{"E1_EMISSAO","FIFFLD1.FIF_DTTEF"}}, SE1->(IndexKey(1)))
		ElseIf __lPrcDocT
			If __lOracle .Or. __lPostGre
				oModel:SetRelation("SE1FLD1",{{"E1_FILORIG","FIFFLD1.FIF_CODFIL"},{"LPAD(TRIM(E1_DOCTEF), " + __cTamDoc + ", '0')","FIFFLD1.XDOCTEF"},{"E1_PARCELA",cParcFIF},{"E1_EMISSAO","FIFFLD1.FIF_DTTEF"}}, SE1->(IndexKey(1)))
			Else
				oModel:SetRelation("SE1FLD1",{{"E1_FILORIG","FIFFLD1.FIF_CODFIL"},{"REPLICATE('0', " + __cTamDoc + " - LEN(E1_DOCTEF)) + RTrim(E1_DOCTEF)","FIFFLD1.XDOCTEF"},{"E1_PARCELA",cParcFIF},{"E1_EMISSAO","FIFFLD1.FIF_DTTEF"}}, SE1->(IndexKey(1)))
			EndIf
		ElseIf __lOracle .Or. __lPostGre
			oModel:SetRelation("SE1FLD1",{{"E1_FILORIG","FIFFLD1.FIF_CODFIL"},{"LPAD(TRIM(E1_NSUTEF), " + __cTamNSU + ", '0')","FIFFLD1.XNSUTEF"},{"E1_PARCELA",cParcFIF},{"E1_EMISSAO","FIFFLD1.FIF_DTTEF"}}, SE1->(IndexKey(1)))		
		Else 
			oModel:SetRelation("SE1FLD1",{{"E1_FILORIG","FIFFLD1.FIF_CODFIL"},{"REPLICATE('0', " + __cTamNSU + " - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF)","FIFFLD1.XNSUTEF"},{"E1_PARCELA",cParcFIF},{"E1_EMISSAO","FIFFLD1.FIF_DTTEF"}}, SE1->(IndexKey(1))) 
		EndIf

		SetProp(oModel:GetModel("SE1FLD1"), 1,, STR0007)
		
		AddField(1, oStrSE101,, 1)

	EndIf 

	/*-------------------------------------------------------------------
			Folder 2 - Conciliados Parcialmente
	-------------------------------------------------------------------*/
	If __nFldPar == 0 .Or. __nFldPar == 2;
			.Or. (__nTpProc == 1  .And. __nFldPar == 4) // quando o tipo de processamento é por abas e for a aba 4 será necessário passar pela aba 1 pois no 4 é reaproveitado a tabela temporáriana função F920TMPABAS
		bVldOk 		:= { |oModGrid| F920Lock(oModGrid) }
		oStrFIF02	:= FWFormStruct(1, "FIF", __bVldFIF)
		oStrSE102	:= FWFormStruct(1, "SE1", __bVldSE1)	
		
		__bLoadF02 := { |oStrFIF02| loadGrids(oStrFIF02, 2) }
		oModel:AddGrid("FIFFLD2", "TMPHEADER", oStrFIF02,,,,, __bLoadF02)
		oModel:SetRelation("FIFFLD2", {{"'1'", "TMPHEADER.STATUS"}}, FIF->(IndexKey(1)))
			
		AddField(1, oStrFIF02, bVldOk, 2)
	
		SetProp(oModel:GetModel("FIFFLD2"), 1, oStrFIF02, STR0002, 2, "FIF")
		
		oStrFIF02:SetProperty("FIF_PGJUST", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF02:SetProperty("FIF_PGDES1", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF02:SetProperty("FIF_PGDES2", MODEL_FIELD_WHEN, {|| .T. })		
		
		oStrFIF02:SetProperty("FIF_PGJUST", MODEL_FIELD_VALID, bValid)

		oStrFIF02:AddTrigger("FIF_PGJUST", "FIF_PGDES1", { || .T.}, b920Just)	

		oModel:AddGrid("SE1FLD2", "FIFFLD2", oStrSE102)
		
		If __lMEP .And. __lUsaMep
			cParcFIF := "FIFFLD2.XPARCEL"
		Else
			If __lParcFIF
				cParcFIF := "FIFFLD2.FIF_PARALF"
			Else
				cParcFIF := "FIFFLD2.FIF_PARCEL"
			EndIf
		EndIf

		If __lPixDig
			oModel:SetRelation("SE1FLD2",{{"E1_DOCTEF","FIFFLD2.FIF_NUCOMP"},{"E1_CARTAUT","FIFFLD2.FIF_CODAUT"},{"E1_EMISSAO","FIFFLD2.FIF_DTTEF"}}, SE1->(IndexKey(1)))
		ElseIf __lPrcDocT
			If __lOracle .Or. __lPostGre
				oModel:SetRelation("SE1FLD2",{{"E1_FILORIG","FIFFLD2.FIF_CODFIL"},{"LPAD(TRIM(E1_DOCTEF), " + __cTamDoc + ", '0')","FIFFLD2.XDOCTEF"},{"E1_PARCELA",cParcFIF},{"E1_EMISSAO", "FIFFLD2.FIF_DTTEF"}}, SE1->(IndexKey(1)))
			Else
				oModel:SetRelation("SE1FLD2",{{"E1_FILORIG","FIFFLD2.FIF_CODFIL"},{"REPLICATE('0', " + __cTamDoc + " - LEN(E1_DOCTEF)) + RTrim(E1_DOCTEF)","FIFFLD2.XDOCTEF"},{"E1_PARCELA",cParcFIF},{"E1_EMISSAO","FIFFLD2.FIF_DTTEF"}}, SE1->(IndexKey(1)))
			EndIf		
		ElseIf __lOracle .Or. __lPostGre
			oModel:SetRelation("SE1FLD2",{{"E1_FILORIG","FIFFLD2.FIF_CODFIL"},{"LPAD(TRIM(E1_NSUTEF), " + __cTamNSU + ", '0')","FIFFLD2.XNSUTEF"},{"E1_PARCELA",cParcFIF},{"E1_EMISSAO", "FIFFLD2.FIF_DTTEF"}}, SE1->(IndexKey(1)))
		Else 
			oModel:SetRelation("SE1FLD2",{{"E1_FILORIG","FIFFLD2.FIF_CODFIL"},{"REPLICATE('0', " + __cTamNSU + " - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF)","FIFFLD2.XNSUTEF"},{"E1_PARCELA",cParcFIF},{"E1_EMISSAO","FIFFLD2.FIF_DTTEF"}}, SE1->(IndexKey(1))) 
		EndIf

		SetProp(oModel:GetModel("SE1FLD2"), 1,, STR0002)

		AddField(1, oStrSE102,, 2) 		

	EndIf

	/*-------------------------------------------------------------------
			Folder 7 - Estornados
	-------------------------------------------------------------------*/
	If __lPixDig .And. (__nFldPar == 0 .Or. __nFldPar == 7)

		oStrFIF07 := FWFormStruct(1, "FIF", __bVldFIF)
		oStrFJU07 := FWFormStruct(1, "FJU", __bVldFJU)

		__bLoadF07 := { |oStrFIF07| loadGrids(oStrFIF07, 7) }
		oModel:AddGrid("FIFFLD7", "TMPHEADER", oStrFIF07,,,,, __bLoadF07)	
		oModel:SetRelation("FIFFLD7", {{"'1'", "TMPHEADER.STATUS"}}, FIF->(IndexKey(1)))

		AddField(1, oStrFIF07, bVldOk, 7)

		SetProp(oModel:GetModel("FIFFLD7"), 1, oStrFIF07, STR0272, 7, "FIF")

		oModel:AddGrid("FJUFLD7", "FIFFLD7", oStrFJU07)

		oModel:SetRelation("FJUFLD7", {{"FJU_DOCTEF","FIFFLD7.FIF_NUCOMP"},{"FJU_EMIS", "FIFFLD7.FIF_DTTEF"}}, FJU->(IndexKey(1)))

		SetProp(oModel:GetModel("FJUFLD7"), 1,, STR0272)

		AddField(1, oStrFJU07,, 7)			

	EndIf

	/*-------------------------------------------------------------------
			Folder 3 - Conciliados Manualmente
	-------------------------------------------------------------------*/
	If __nFldPar == 0 .Or. __nFldPar == 3
		oStrFIF03 := FWFormStruct(1, "FIF", __bVldFIF)
		oStrSE103 := FWFormStruct(1, "SE1", __bVldSE1)	

		__bLoadF03 := { |oStrFIF03| loadGrids(oStrFIF03, 3) }
		oModel:AddGrid("FIFFLD3", "TMPHEADER", oStrFIF03,,,,, __bLoadF03)
		oModel:SetRelation("FIFFLD3", {{"'1'", "TMPHEADER.STATUS"}}, FIF->(IndexKey(1)))

		AddField(1, oStrFIF03,, 3)

		SetProp(oModel:GetModel("FIFFLD3"), 1, oStrFIF03, STR0003, 3, "FIF")

		oStrFIF03:SetProperty("OK",			MODEL_FIELD_WHEN, {|| .F. })
		oStrFIF03:SetProperty("FIF_PGJUST", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF03:SetProperty("FIF_PGDES1", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF03:SetProperty("FIF_PGDES2", MODEL_FIELD_WHEN, {|| .T. })

		oStrFIF03:SetProperty("FIF_PGJUST", MODEL_FIELD_VALID, bValid)
		oStrFIF03:AddTrigger("FIF_PGJUST", "FIF_PGDES1", { || .T.}, b920Just)

		oModel:AddGrid("SE1FLD3", "FIFFLD3", oStrSE103)
		oModel:SetRelation("SE1FLD3",{{"E1_FILORIG","FIFFLD3.FIF_CODFIL"},{"E1_NUM","FIFFLD3.FIF_NUM"},{"E1_PARCELA","FIFFLD3.FIF_PARC"},{"E1_PREFIXO","FIFFLD3.FIF_PREFIX"}}, SE1->(IndexKey(1))) 

		SetProp(oModel:GetModel("SE1FLD3"), 1,, STR0003) 

		AddField(1, oStrSE103,, 3)

	EndIf

	/*-------------------------------------------------------------------
			Folder 4 - Não Conciliados
	-------------------------------------------------------------------*/
	If __nFldPar == 0 .Or. __nFldPar == 4
		oStrFIF04	:= FWFormStruct(1, "FIF", __bVldFIF)
		oStrSE104	:= FWFormStruct(1, "SE1", __bVldSE1)

		__bLoadF04 := { |oStrFIF04| loadGrids(oStrFIF04, 4) }
		oModel:AddGrid("FIFFLD4", "TMPHEADER", oStrFIF04,,,,, __bLoadF04)
		oModel:SetRelation("FIFFLD4", {{"'1'", "TMPHEADER.STATUS"}}, FIF->(IndexKey(1)))

		//Insere campo de Selecao do Registro nas Grids
		bVldOk 	:= { |oModGrid, cCampo, lValue| fVldOk(oModGrid, cCampo, lValue) .And. F920Lock(oModGrid, 1) }

		AddField(1, oStrFIF04, bVldOk, 4)

		SetProp(oModel:GetModel("FIFFLD4"), 1, oStrFIF04, STR0004, 4, "FIF")

		oStrFIF04:SetProperty("FIF_PGJUST", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF04:SetProperty("FIF_PGDES1", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF04:SetProperty("FIF_PGDES2", MODEL_FIELD_WHEN, {|| .T. })	

		oStrFIF04:SetProperty("FIF_PGJUST", MODEL_FIELD_VALID, bValid)
		oStrFIF04:AddTrigger("FIF_PGJUST", "FIF_PGDES1", { || .T.},  b920Just)

		__bLoadS04 := { |oStrSE104| loadGrids(oStrSE104, 4, "SE1") }
		oModel:AddGrid("SE1FLD4", "TMPHEADER", oStrSE104,,,,, __bLoadS04)	

		oModel:SetRelation("SE1FLD4", {{"'1'", "TMPHEADER.STATUS"}}, SE1->(IndexKey(1)))

		bVldOk 	:= { |oModGrid, cCampo, lValue| fVldOk(oModGrid, cCampo, lValue) .And. F920Lock(oModGrid, 2) }
		AddField(1, oStrSE104, bVldOk, 4)

		SetProp(oModel:GetModel("SE1FLD4"), 1, oStrSE104, STR0004, 4, "SE1")

	EndIf

	/*-------------------------------------------------------------------
			Folder 5 - Divergentes
	-------------------------------------------------------------------*/
	If __nFldPar == 0 .Or. __nFldPar == 5
		bVldOk 	  := { |oModGrid| F920Lock(oModGrid) }
		oStrFIF05 := FWFormStruct(1, "FIF", __bVldFIF)

		__bLoadF05 := { |oStrFIF05| loadGrids(oStrFIF05, 5) }
		oModel:AddGrid("FIFFLD5", "TMPHEADER", oStrFIF05,,,,, __bLoadF05)
		oModel:SetRelation("FIFFLD5", {{"'1'", "TMPHEADER.STATUS"}}, FIF->(IndexKey(1)))

		AddField(1, oStrFIF05, bVldOk)

		SetProp(oModel:GetModel("FIFFLD5"), 1, oStrFIF05, STR0166, 5, "FIF")

		oStrFIF05:SetProperty("FIF_PGJUST", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF05:SetProperty("FIF_PGDES1", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF05:SetProperty("FIF_PGDES2", MODEL_FIELD_WHEN, {|| .T. }) 

		oStrFIF05:SetProperty("FIF_PGJUST", MODEL_FIELD_VALID, bValid)
		oStrFIF05:AddTrigger("FIF_PGJUST", "FIF_PGDES1", { || .T.}, b920Just)	

	EndIf

	/*-------------------------------------------------------------------
		Folder 6 - Totais
	-------------------------------------------------------------------*/
	bLoadTot := { |oSubMod| fLoadTot(oSubMod) }

	oModel:AddGrid("TOTFLD6", "TMPHEADER", oStrTot06,,,,, bLoadTot)
	oModel:SetRelation("TOTFLD6", {{"'1'", "TMPHEADER.STATUS"}}, "DTOS(DTAVEND)")

	oModel:GetModel("TOTFLD6"):SetNoUpdateLine(.T.)
	oModel:GetModel("TOTFLD6"):SetUniqueLine({"DTAVEND"})

	SetProp(oModel:GetModel("TOTFLD6"), 1,, STR0005)

	If __nTpProc == 1
		If __nFldPar == 1
			oModel:SetActivate({ |oModel| __nFIFFLD1 := F920Cont(oModel, "FIFFLD1") })
		ElseIf __nFldPar == 2
			oModel:SetActivate({ |oModel| __nFIFFLD2 := F920Cont(oModel, "FIFFLD2") })	
		ElseIf __nFldPar == 3
			oModel:SetActivate({ |oModel| __nFIFFLD3 := F920Cont(oModel, "FIFFLD3") })	
		ElseIf __nFldPar == 4
			oModel:SetActivate({ |oModel| __nFIFFLD4 := F920Cont(oModel, "FIFFLD4") , __nSE1FLD4 := F920Cont(oModel,"SE1FLD4") })
		ElseIf __nFldPar == 5
			oModel:SetActivate( { |oModel| __nFIFFLD5 := F920Cont(oModel, "FIFFLD5") })	
		EndIf
	Else
		oModel:SetActivate({ |oModel|	__nFIFFLD1 := F920Cont(oModel,	"FIFFLD1"),;
										__nFIFFLD2 := F920Cont(oModel,	"FIFFLD2"),;
										__nFIFFLD3 := F920Cont(oModel,	"FIFFLD3"),;
										__nFIFFLD4 := F920Cont(oModel,	"FIFFLD4"),;
										__nSE1FLD4 := F920Cont(oModel,	"SE1FLD4"),;
										__nFIFFLD5 := F920Cont(oModel,	"FIFFLD5"),;
										IIf(__lPixDig, __nFIFFLD7 := F920Cont(oModel, "FIFFLD7"), 1)})
	EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao da View

@type function
@author Totvs
@since 7/12/2020

/*/
//-------------------------------------------------------------------
Static Function ViewDef() As Object
Local oModel	As Object
Local oView		As Object
Local oStHead	As Object
Local oStrFIF01	As Object
Local oStrFIF02	As Object
Local oStrFIF03 As Object
Local oStrFIF04	As Object
Local oStrFIF05	As Object
Local oStrFIF07	As Object
Local oStrSE101	As Object
Local oStrSE102	As Object
Local oStrSE103	As Object
Local oStrSE104	As Object
Local oStrTot06	As Object
Local oStrFJU07	As Object
Local cDescri	As Character
Local nY		As Numeric  
Local aFIFPix   As Array    
Local aSE1Pix   As Array 

ProcLogAtu(STR0138, STR0053)

oModel		:= FWLoadModel("FINA920A")
oView		:= FWFormView():New()
oStHead		:= StrHead(2)
oStrTot06	:= StrTot(2)

cDescri		:= ""

aFIFPix     := aClone(F920RemCpo("FIF")) 
aSE1Pix     := aClone(F920RemCpo("SE1"))

	oView:SetModel(oModel)
	oView:CreateHorizontalBox("HBINF01", 100)
	oView:CreateFolder("FOLGRIDS", "HBINF01")

	/*-------------------------------------------------------------------
				Sheet 01 - Conciliados
	-------------------------------------------------------------------*/
	If __nFldPar == 0 .Or. __nFldPar == 1
		oStrFIF01	:= FWFormStruct(2, "FIF", __bVldFIF)
		oStrSE101	:= FWFormStruct(2, "SE1", __bVldSE1)

		oView:AddSheet("FOLGRIDS", "SHT01", STR0007, {|| F920VTef(oView, 1) })
		oView:CreateHorizontalBox("HB01SHT01", 52, NIL, NIL, "FOLGRIDS", "SHT01")
		oView:CreateHorizontalBox("HB02SHT01",  6, NIL, NIL, "FOLGRIDS", "SHT01")
		oView:CreateHorizontalBox("HB03SHT01", 26, NIL, NIL, "FOLGRIDS", "SHT01")
		oView:CreateHorizontalBox("HB04SHT01", 16, NIL, NIL, "FOLGRIDS", "SHT01")
	
		oView:AddGrid("GRD01FIF01", oStrFIF01, "FIFFLD1")
		oView:SetOwnerView("GRD01FIF01", "HB01SHT01")
		oView:SetViewProperty("GRD01FIF01", "GRIDSEEK", {.T.})
	
		AddField(2, oStrFIF01)
	
		SetProp(oModel, 2, oStrFIF01,,,"FIF")

		oView:SetViewProperty("GRD01FIF01", "CHANGELINE", {{|| F920VTef(oView, 1)}})
		
		oStrFIF01:RemoveField("FIF_STATUS")
		oStrFIF01:RemoveField("FIF_PREFIX")
		oStrFIF01:RemoveField("FIF_NUCART")
		oStrFIF01:RemoveField("FIF_NUM")
		oStrFIF01:RemoveField("FIF_PARCEL")
		oStrFIF01:RemoveField("FIF_NSUARQ")
		
		If __lPrcDocT
			oStrFIF01:RemoveField("XDOCTEF")
		Else
			oStrFIF01:RemoveField("XNSUTEF")
		EndIf

		If __lPixDig
			For nY := 1 To Len(aFIFPix)				
				oStrFIF01:RemoveField(aFIFPix[nY])  
			Next nY			
		EndIf

		oView:AddOtherObject("chkEf01", { |oPanel| F920SelAll(oPanel, 1) })
		oView:SetOwnerView("chkEf01", "HB02SHT01")

		oView:AddGrid("GRD01SE101", oStrSE101, "SE1FLD1")
		oView:SetOwnerView("GRD01SE101", "HB03SHT01")
		oView:SetViewProperty("GRD01SE101", "GRIDCANGOTFOCUS", {.F.})
	
		oStrSE101:SetNoFolder()
	
		AddField(2, oStrSE101,, 1)
		
		oStrSE101:RemoveField('OK')

		If __lPixDig
			For nY := 1 To Len(aSE1Pix) 
				oStrSE101:RemoveField(aSE1Pix[nY]) 				
			Next nY	 	
		EndIf

		oStrSE101:SetProperty('Conciliar', MVC_VIEW_ORDEM, '01')

		SetProp(oModel, 2, oStrSE101,,, "SE1")

		oView:AddOtherObject("btnEf01", { |oPanel| F920Botao(oPanel, 1,, __nFIFFLD1 >= GRIDMAXLIN ) })
		oView:SetOwnerView("btnEf01", "HB04SHT01")
		
	EndIf

	/*-------------------------------------------------------------------
				Sheet 02 - Conciliados Parcialmente
	-------------------------------------------------------------------*/
	If __nFldPar == 0 .Or. __nFldPar == 2
		oStrFIF02	:= FWFormStruct(2, "FIF", __bVldFIF)
		oStrSE102	:= FWFormStruct(2, "SE1", __bVldSE1)

		oView:AddSheet("FOLGRIDS", "SHT02", STR0002,{|| F920VTef(oView, 2)})
		oView:CreateHorizontalBox("HB01SHT02", 52, NIL, NIL, "FOLGRIDS", "SHT02")
		oView:CreateHorizontalBox("HB02SHT02",  6, NIL, NIL, "FOLGRIDS", "SHT02")
		oView:CreateHorizontalBox("HB03SHT02", 26, NIL, NIL, "FOLGRIDS", "SHT02")
		oView:CreateHorizontalBox("HB04SHT02", 16, NIL, NIL, "FOLGRIDS", "SHT02")
	
		oView:AddGrid("GRD01FIF02", oStrFIF02, "FIFFLD2")
		oView:SetOwnerView("GRD01FIF02", "HB01SHT02")
		oView:SetViewProperty("GRD01FIF02", "GRIDSEEK", {.T.})
	
		AddField(2, oStrFIF02)
		
		SetProp(oModel, 2, oStrFIF02,,, "FIF")
		
		oView:SetViewProperty("GRD01FIF02", "CHANGELINE", {{ || F920VTef(oView, 2) }})
	
		oStrFIF02:RemoveField("FIF_STATUS")
		oStrFIF02:RemoveField("FIF_PREFIX")
		oStrFIF02:RemoveField("FIF_NUCART")
		oStrFIF02:RemoveField("FIF_NUM")
		oStrFIF02:RemoveField("FIF_PARCEL")
		oStrFIF02:RemoveField("FIF_NSUARQ")

		If __lPrcDocT
			oStrFIF02:RemoveField("XDOCTEF")
		Else
			oStrFIF02:RemoveField("XNSUTEF")
		EndIf
		
		If __lPixDig
			For nY := 1 To Len(aFIFPix)     		
				oStrFIF02:RemoveField(aFIFPix[nY])	
			Next nY
		EndIf

		oStrFIF02:SetProperty("FIF_PGJUST", 	MVC_VIEW_CANCHANGE, .T.)
		oStrFIF02:SetProperty("FIF_PGDES1", 	MVC_VIEW_CANCHANGE, .F.)
		oStrFIF02:SetProperty("FIF_PGDES2", 	MVC_VIEW_CANCHANGE, .T.)
		
		oView:AddOtherObject("chkEf02", { |oPanel| F920SelAll(oPanel,  2) })
		oView:SetOwnerView("chkEf02", "HB02SHT02")
		
		oView:AddGrid("GRD02SE102", oStrSE102, "SE1FLD2")
		oView:SetOwnerView("GRD02SE102", "HB03SHT02")
		
		AddField(2, oStrSE102,, 2)
		
		oStrSE102:RemoveField('OK')

		If __lPixDig
			For nY := 1 To Len(aSE1Pix) 
				oStrSE102:RemoveField(aSE1Pix[nY]) 
			Next nY
		EndIf

		oStrSE102:SetProperty('Conciliar', MVC_VIEW_ORDEM , '01')

		SetProp(oModel, 2, oStrSE102,,,"SE1")

		oView:AddOtherObject("btnEf02", { |oPanel| F920Botao(oPanel, 2,, __nFIFFLD2 >= GRIDMAXLIN ) })
		oView:SetOwnerView("btnEf02", "HB04SHT02")
				
	EndIf

	/*-------------------------------------------------------------------
				Sheet 07 - Estornados
	-------------------------------------------------------------------*/
	If __lPixDig .And. (__nFldPar == 0 .Or. __nFldPar == 7)	
		oStrFIF07	:= FWFormStruct(2, "FIF", __bVldFIF)
		oStrFJU07	:= FWFormStruct(2, "FJU", __bVldFJU)
		
		oView:AddSheet("FOLGRIDS", "SHT07", STR0272, { || F920VTef(oView, 7) })

		oView:CreateHorizontalBox("HB01SHT07", 52, NIL, NIL, "FOLGRIDS", "SHT07")
		oView:CreateHorizontalBox("HB02SHT07",  6, NIL, NIL, "FOLGRIDS", "SHT07")
		oView:CreateHorizontalBox("HB03SHT07", 26, NIL, NIL, "FOLGRIDS", "SHT07")
		oView:CreateHorizontalBox("HB04SHT07", 16, NIL, NIL, "FOLGRIDS", "SHT07")
	
		oView:AddGrid("GRD01FIF07", oStrFIF07, "FIFFLD7")
		oView:SetOwnerView("GRD01FIF07", "HB01SHT07")
		oView:SetViewProperty("GRD01FIF07", "GRIDSEEK", {.T.})
	
		AddField(2, oStrFIF07)
		
		SetProp(oModel, 2, oStrFIF07,,, "FIF")

		oView:SetViewProperty("GRD01FIF07", "CHANGELINE", {{ || F920VTef(oView, 7) }})

		oStrFIF07:RemoveField("FIF_STATUS")
		oStrFIF07:RemoveField("FIF_PREFIX")
		oStrFIF07:RemoveField("FIF_NUCART")
		oStrFIF07:RemoveField("FIF_NUM")
		oStrFIF07:RemoveField("FIF_NSUARQ")

		If __lPrcDocT
			oStrFIF07:RemoveField("XDOCTEF")
		Else
			oStrFIF07:RemoveField("XNSUTEF")
		EndIf

		If __lPixDig
			For nY := 1 To Len(aFIFPix)				
				oStrFIF07:RemoveField(aFIFPix[nY])  
			Next nY				
		EndIf
		
		oView:AddOtherObject("chkEf07", { |oPanel| F920SelAll(oPanel, 7) })
		oView:SetOwnerView("chkEf07", "HB02SHT07")
			
		oView:AddGrid("GRD01FJU07", oStrFJU07, "FJUFLD7")
		oView:SetOwnerView("GRD01FJU07", "HB03SHT07")
		oView:SetViewProperty("GRD01FJU07", "GRIDCANGOTFOCUS", {.F.})	

		oStrFJU07:SetNoFolder()

		AddField(2, oStrFJU07,, 7)		

		oStrFJU07:RemoveField('OK')	
		oStrFJU07:RemoveField('FJU_DOCTEF')	

		oStrFJU07:SetProperty('Conciliar', MVC_VIEW_ORDEM, '01')

		oView:AddOtherObject("btnEf07", { |oPanel| F920Botao(oPanel, 7, oView, __nFIFFLD7 >= GRIDMAXLIN) })
		oView:SetOwnerView("btnEf07", "HB04SHT07")
	EndIf

	/*-------------------------------------------------------------------
				Sheet 03 - Conciliados Manualmente
	-------------------------------------------------------------------*/
	If __nFldPar == 0 .Or. __nFldPar == 3
		oStrFIF03 := FWFormStruct(2, "FIF", __bVldFIF)
		oStrSE103 := FWFormStruct(2, "SE1", __bVldSE1)

		oView:AddSheet("FOLGRIDS", "SHT03", STR0003,{|| F920VTef(oView, 3)})
		oView:CreateHorizontalBox("HB01SHT03", 52, NIL, NIL, "FOLGRIDS", "SHT03")
		oView:CreateHorizontalBox("HB02SHT03",  6, NIL, NIL, "FOLGRIDS", "SHT03")
		oView:CreateHorizontalBox("HB03SHT03", 26, NIL, NIL, "FOLGRIDS", "SHT03")
		oView:CreateHorizontalBox("HB04SHT03", 16, NIL, NIL, "FOLGRIDS", "SHT03")

		oView:AddGrid("GRD01FIF03", oStrFIF03, "FIFFLD3")
		oView:SetOwnerView("GRD01FIF03", "HB01SHT03")
		oView:SetViewProperty("GRD01FIF03", "GRIDSEEK", {.T.})
	
		AddField(2, oStrFIF03)
	
		SetProp(oModel, 2, oStrFIF03,,,"FIF")

		oView:SetViewProperty("GRD01FIF03", "CHANGELINE", {{ || F920VTef(oView, 3) }})

		oStrFIF03:RemoveField("Conciliar")
		oStrFIF03:RemoveField("OK")
		oStrFIF03:RemoveField("FIF_STATUS")
		oStrFIF03:RemoveField("FIF_PREFIX")
		oStrFIF03:RemoveField("FIF_NUCART")
		oStrFIF03:RemoveField("FIF_NUM")
		oStrFIF03:RemoveField("XPARCEL")
		oStrFIF03:RemoveField("FIF_NSUARQ")
		
		If __lPrcDocT
			oStrFIF03:RemoveField("XDOCTEF")
		Else
			oStrFIF03:RemoveField("XNSUTEF")
		EndIf
		
		If __lPixDig
			For nY := 1 To Len(aFIFPix)					
				oStrFIF03:RemoveField(aFIFPix[nY])		
			Next nY			
		EndIf

		oStrFIF03:SetProperty("FIF_PGJUST", 	MVC_VIEW_CANCHANGE, .F.)
		oStrFIF03:SetProperty("FIF_PGDES1", 	MVC_VIEW_CANCHANGE, .F.)
		oStrFIF03:SetProperty("FIF_PGDES2", 	MVC_VIEW_CANCHANGE, .F.)				

		oView:AddGrid("GRD01SE103", oStrSE103, "SE1FLD3")
		oView:SetOwnerView("GRD01SE103", "HB03SHT03")
		oView:SetViewProperty("GRD01SE103", "GRIDCANGOTFOCUS", {.F.})
	
		oStrSE103:SetNoFolder()
	
		AddField(2, oStrSE103,, 3)

		SetProp(oModel, 2, oStrSE103,,, "SE1")
		
		oStrSE103:RemoveField("Conciliar")
		oStrSE103:RemoveField("OK")

		If __lPixDig
			For nY := 1 To Len(aSE1Pix) 
				oStrSE103:RemoveField(aSE1Pix[nY]) 
			Next nY
		EndIf

		oView:AddOtherObject("btnImpBrw", { |oPanel| F920Botao(oPanel, 3, oView) })
		oView:SetOwnerView("btnImpBrw", "HB04SHT03")
			
	EndIf

	/*-------------------------------------------------------------------
				Sheet 04 - Não Conciliadas
	-------------------------------------------------------------------*/
	If __nFldPar == 0 .Or. __nFldPar == 4
		oStrFIF04 := FWFormStruct(2, "FIF", __bVldFIF)
		oStrSE104 := FWFormStruct(2, "SE1", __bVldSE1)

		oView:AddSheet("FOLGRIDS", "SHT04", STR0004)
		oView:CreateHorizontalBox("HB01SHT04", 42, NIL, NIL, "FOLGRIDS", "SHT04")
		oView:CreateHorizontalBox("HB02SHT04", 42, NIL, NIL, "FOLGRIDS", "SHT04")
		oView:CreateHorizontalBox("HB03SHT04", 16, NIL, NIL, "FOLGRIDS", "SHT04")
	
		oView:AddGrid("GRD01FIF04", oStrFIF04, "FIFFLD4")
		oView:SetOwnerView("GRD01FIF04", "HB01SHT04")
		oView:SetViewProperty("GRD01FIF04", "GRIDSEEK", {.T.})
		oView:SetViewProperty("GRD01FIF04", "GRIDFILTER", {.T.}) 

		AddField(2, oStrFIF04)
	
		SetProp(oModel, 2, oStrFIF04,,, "FIF")

		oStrFIF04:RemoveField("FIF_NUCART")
		oStrFIF04:RemoveField("FIF_STATUS")
		oStrFIF04:RemoveField("FIF_PREFIX")
		oStrFIF04:RemoveField("FIF_NUCART")
		oStrFIF04:RemoveField("FIF_NUM")
		oStrFIF04:RemoveField("XPARCEL")
		oStrFIF04:RemoveField("FIF_NSUARQ")

		If __lPrcDocT
			oStrFIF04:RemoveField("XDOCTEF")
		Else
			oStrFIF04:RemoveField("XNSUTEF")
		EndIf
		
		If __lPixDig
			For nY := 1 To Len(aFIFPix)				
				oStrFIF04:RemoveField(aFIFPix[nY])	
			Next nY				
		EndIf

		oStrFIF04:SetProperty("FIF_PGJUST", 	MVC_VIEW_CANCHANGE, .T.)
		oStrFIF04:SetProperty("FIF_PGDES2", 	MVC_VIEW_CANCHANGE, .T.)
	
		oView:AddGrid("GRD01SE104", oStrSE104, "SE1FLD4")
		oView:SetOwnerView("GRD01SE104", "HB02SHT04")
		oView:SetViewProperty("GRD01SE104", "GRIDSEEK", {.T.})
		oView:SetViewProperty("GRD01SE104", "GRIDFILTER", {.T.}) 
	
		AddField(2, oStrSE104,, 4)

		oStrSE104:SetProperty('OK', MVC_VIEW_ORDEM , '01')
		
		SetProp(oModel, 2, oStrSE104,,, "SE1")
		oStrSE104:SetProperty("OK",	MVC_VIEW_CANCHANGE, .T.)

		oView:AddOtherObject("btnEf04", { |oPanel| F920Botao(oPanel, 4,, __nFIFFLD4 >= GRIDMAXLIN .Or. __nSE1FLD4 >= GRIDMAXLIN) })
		oView:SetOwnerView("btnEf04", "HB03SHT04")

	EndIf

	/*-------------------------------------------------------------------
				Sheet 05 - Divergentes
	-------------------------------------------------------------------*/
	If __nFldPar == 0 .Or. __nFldPar == 5
		oStrFIF05	:= FWFormStruct(2, "FIF", __bVldFIF)

		oView:AddSheet("FOLGRIDS", "SHT05", STR0166, {|| A920Msg(@cDescri), __oDescri:Refresh()})
		oView:CreateHorizontalBox("HB01SHT05", 56, NIL, NIL, "FOLGRIDS", "SHT05")
		oView:CreateHorizontalBox("HB02SHT05", 26, NIL, NIL, "FOLGRIDS", "SHT05")
		oView:CreateHorizontalBox("HB03SHT05", 16, NIL, NIL, "FOLGRIDS", "SHT05")
	
		oView:AddGrid("GRD01FIF05", oStrFIF05, "FIFFLD5")
		oView:SetOwnerView("GRD01FIF05", "HB01SHT05")
		oView:SetViewProperty("GRD01FIF05", "GRIDSEEK", {.T.})
		
		AddField(2, oStrFIF05)
	
		SetProp(oModel, 2, oStrFIF05,,,"FIF")		
	
		oStrFIF05:RemoveField("FIF_NSUTEF")
		oStrFIF05:RemoveField("FIF_PREFIX")
		oStrFIF05:RemoveField("FIF_NSUARQ")
		oStrFIF05:RemoveField("FIF_NUM")
		oStrFIF05:RemoveField("XPARCEL")
		oStrFIF05:RemoveField("FIF_NSUARQ")

		If __lPrcDocT
			oStrFIF05:RemoveField("XDOCTEF")
		Else
			oStrFIF05:RemoveField("XNSUTEF")
		EndIf
		
		If __lPixDig
			For nY := 1 To Len(aFIFPix)					
				oStrFIF05:RemoveField(aFIFPix[nY])		
			Next nY			
		EndIf

		oStrFIF05:SetProperty("FIF_PGJUST", MVC_VIEW_CANCHANGE, .T.)
		oStrFIF05:SetProperty("FIF_PGDES2", MVC_VIEW_CANCHANGE, .T.)
		
		oView:SetViewProperty("GRD01FIF05", "GRIDDOUBLECLICK", {{|| A920Msg(@cDescri)}})
		oView:SetViewProperty("GRD01FIF05", "CHANGELINE", {{|| A920Msg(@cDescri), __oDescri:Refresh()}})
		
		oView:AddOtherObject("OtherMsg", { |oPanel| F920Ms(oPanel, @cDescri) })
		oView:SetOwnerView("OtherMsg", "HB02SHT05")
	
		oView:AddOtherObject("btnEf05", { |oPanel| F920Botao(oPanel, 5,, __nFIFFLD5 >= GRIDMAXLIN) })
		oView:SetOwnerView("btnEf05", "HB03SHT05")

	EndIf

	/*-------------------------------------------------------------------
		Sheet 06 - Totais
	-------------------------------------------------------------------*/
	oView:AddSheet("FOLGRIDS", "SHT06", STR0005)

	oView:CreateHorizontalBox("HB01SHT06", 85, NIL, NIL, "FOLGRIDS", "SHT06")
	oView:CreateHorizontalBox("HB02SHT06", 15, NIL, NIL, "FOLGRIDS", "SHT06")

	oView:AddGrid("GRD01TOT06", oStrTot06, "TOTFLD6")
	oView:SetOwnerView("GRD01TOT06", "HB01SHT06")
	oView:SetViewProperty("GRD01TOT06", "GRIDSEEK", {.T.})

	oView:AddOtherObject("btnEf06", { |oPanel| F920Botao(oPanel, 6, oView) })
	oView:SetOwnerView("btnEf06", "HB02SHT06")

	oView:SetProgressBar(.T.)

	FwFreeArray(aFIFPix) 
	FwFreeArray(aSE1Pix)

	ProcLogAtu("FIM")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F920Botao
Inclusao de Botao de Efetivacao

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Function F920Botao(oPanel As Object, nSheet As Numeric, oView As Object, lMsg As Logical)
	Local oButton	As Object
	Local nColPrint As Numeric
	Local nLinPrint As Numeric
	Local nColGrv 	As Numeric
	Local nLinGrv 	As Numeric

	Default oPanel := Nil
	Default nSheet := 0
	Default oView  := FwViewActive()
	Default lMsg   := .F.

	nColPrint := 20
	nLinPrint := 10
	nColGrv   := 20
	nLinGrv   := 80

	If nSheet != 5
	    If nSheet == 6
			nColPrint := 8
			nLinPrint := 10
			@008, 080 BUTTON oButton PROMPT STR0143  SIZE 060, 020 FONT oPanel:oFont ACTION Processa({ || ProcLogView(,"FINA918") },STR0092,STR0047) OF oPanel PIXEL //"Visual. Log" / "Aguarde..."/ "Processando ..."
		ElseIf nSheet == 1 .Or. nSheet == 2 .Or. nSheet == 7
			nColPrint := 8
			nLinPrint := 10
			nColGrv   := 8
			nLinGrv   := 80
		ElseIf nSheet == 3
			nColPrint := 8
			nLinPrint := 10
		Else
			nColPrint := 17
			nLinPrint := 10
			nColGrv   := 17
			nLinGrv   := 80
		EndIf
	EndIf

	If oPanel != Nil
		@nColPrint, nLinPrint BUTTON oButton PROMPT STR0236  SIZE 060, 020 FONT oPanel:oFont ACTION Processa({ || F920Print(oView) },STR0092,STR0237) OF oPanel PIXEL
		If nSheet != 3 .And. nSheet != 6
			@nColGrv, nLinGrv BUTTON oButton PROMPT STR0171 SIZE 060, 020 FONT oPanel:oFont ACTION Processa({ || F920Grv(nSheet) },STR0092,STR0238) OF oPanel PIXEL
		EndIf	
	EndIf

	If lMsg
		Help(" ", 1, "GRIDMAXLIN",, STR0239, 1, 0,,,,,, { STR0290 })
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} StrHead
Retorna a Estrutura do Cabecalho

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static Function StrHead( nTipo As Numeric ) As Object
Local oStruct	As Object
Local nLenSt	As Numeric

Default nTipo := 0

	Do Case
	Case nTipo == 1
		oStruct	:= FWFormModelStruct():New()

		nLenSt := TamSX3("FIF_STATUS")[1]

		oStruct:AddTable("TMP" ,{STR0255}, STR0274)
		
		oStruct:AddField(	STR0255		,; 	// [01] C Titulo do campo
							STR0255		,; 	// [02] C ToolTip do campo "STATUS"
							STR0255		,; 	// [03] C identificador (ID) do Field "STATUS"
							"C" 		,; 	// [04] C Tipo do campo
							nLenSt		,; 	// [05] N Tamanho do campo
							0 			,; 	// [06] N Decimal do campo
							Nil 		,; 	// [07] B Code-block de validação do campo
							Nil			,; 	// [08] B Code-block de validação When do campo
							Nil 		,; 	// [09] A Lista de valores permitido do campo
					      	Nil 		,;	// [10] L Indica se o campo tem preenchimento obrigatÃ³rio
							Nil			,; 	// [11] B Code-block de inicializacao do campo
							Nil 		,;	// [12] L Indica se trata de um campo chave
							.F.		 	,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
							.F.			)	// [14] L Indica se o campo é virtual

	Case nTipo == 2
		oStruct	:= FWFormViewStruct():New()

		oStruct:AddField(	STR0255		,;	// [01]  C   Nome do Campo
							"01"		,;	// [02]  C   Ordem
							STR0255		,;	// [03]  C   Titulo do campo
							STR0255		,;	// [04]  C   Descricao do campo
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

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static Function StrTot(nTipo As Numeric) As Object
Local oStruct	As Object
Local cPicture	As Character
Local cOrdem	As Character
Local nLenVlr	As Numeric
Local nDecVlr	As Numeric
Local nLenQtd	As Numeric

Default nTipo := 0

cPicture	:= PesqPict("SE1", "E1_VALOR")
cOrdem		:= "00"
nLenVlr		:= TamSX3("E1_VALOR")[1]
nDecVlr		:= TamSX3("E1_VALOR")[2]
nLenQtd		:= 09

	Do Case
	Case nTipo == 1

		oStruct	:= FWFormModelStruct():New()

		oStruct:AddTable(STR0195 ,{"DTAVEND"}, STR0005)

		oStruct:AddField(STR0006, STR0006, "DTAVEND", "D", 8, 0, NIL, NIL, NIL, NIL, {|| dDatabase}, NIL, .F., .F.)

		If __nFldPar == 0 .Or. __nFldPar == 1
			oStruct:AddField(STR0007, STR0007,  "TOTFLD1", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Conciliados"
			oStruct:AddField(STR0008, STR0008,  "QTDFLD1", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Qtd.Conciliados"
		EndIf

		If __nFldPar == 0 .Or. __nFldPar == 2
			oStruct:AddField(STR0009, STR0009,  "TOTFLD2", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Conc. Parcial"
			oStruct:AddField(STR0010, STR0010,  "QTDFLD2", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//" Qtd.Conc.Parc."
		EndIf

		If __lPixDig .And. (__nFldPar == 0 .Or. __nFldPar == 7)
			oStruct:AddField(STR0272, STR0272,  "TOTFLD7", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Estornados"
			oStruct:AddField(STR0273, STR0273,  "QTDFLD7", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)			//"Qtd.Estornados"
		EndIf

		If __nFldPar == 0 .Or. __nFldPar == 3
			oStruct:AddField(STR0011,STR0011,  "TOTFLD3", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		  //"Conc. Manual"
			oStruct:AddField(STR0012, STR0012, "QTDFLD3", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)			//"Qtd.Conc.Man."
		EndIf

		If __nFldPar == 0 .Or. __nFldPar == 4
			oStruct:AddField(STR0013, STR0013,  "TOTFLD4", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Nao Conc."
			oStruct:AddField(STR0014, STR0014,  "QTDFLD4", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Qtd.Nao Conc."
		EndIf

		If __nFldPar == 0 .Or. __nFldPar == 5
			oStruct:AddField(STR0166, STR0166,  "TOTFLD5", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Divergentes"
			oStruct:AddField(STR0170, STR0170,  "QTDFLD5", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Qtd.Divergentes"
		EndIf
		
		oStruct:AddField(STR0015, STR0015,  "TOTTOT", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Total Geral"
		oStruct:AddField(STR0240, STR0240,  "QTDTOT", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Qtd. Total"

		//Indices
		oStruct:AddIndex(1, "01", "DTAVEND", STR0006, "", "", .T.)		//"Data Credito"

	Case nTipo == 2

		oStruct	:= FWFormViewStruct():New()

		oStruct:AddField("DTAVEND",fSoma1(@cOrdem),STR0006,STR0006,NIL,"D",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)		//"Data Credito"	

		If __nFldPar == 0 .Or. __nFldPar == 1
			oStruct:AddField("TOTFLD1",fSoma1(@cOrdem),STR0007,STR0007,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Conciliados"	
			oStruct:AddField("QTDFLD1",fSoma1(@cOrdem),STR0008,STR0008,NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qtd.Conciliados"	
		EndIf

		If __nFldPar == 0 .Or. __nFldPar == 2
			oStruct:AddField("TOTFLD2",fSoma1(@cOrdem),STR0009,STR0009,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)	//"Conc. Parcial"	
			oStruct:AddField("QTDFLD2",fSoma1(@cOrdem),STR0010,STR0010,NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)			//" Qtd.Conc.Parc."
		EndIf

		If __lPixDig .And. (__nFldPar == 0 .Or. __nFldPar == 7)
			oStruct:AddField("TOTFLD7",fSoma1(@cOrdem),STR0272,STR0272,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)	//"Estornados"	
			oStruct:AddField("QTDFLD7",fSoma1(@cOrdem),STR0273,STR0273,NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qtd.Estornados"	
		EndIf

		If __nFldPar == 0 .Or. __nFldPar == 3
			oStruct:AddField("TOTFLD3",fSoma1(@cOrdem),STR0011,STR0011,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Conc. Manual"		
			oStruct:AddField("QTDFLD3",fSoma1(@cOrdem),STR0012,STR0012,NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qtd.Conc.Man."
		EndIf

		If __nFldPar == 0 .Or. __nFldPar == 4
			oStruct:AddField("TOTFLD4",fSoma1(@cOrdem),STR0013,STR0013,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Nao Conc."
			oStruct:AddField("QTDFLD4",fSoma1(@cOrdem),STR0014,STR0014,NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qtd.Nao Conc."	
		EndIf

		If __nFldPar == 0 .Or. __nFldPar == 5
			oStruct:AddField("TOTFLD5",fSoma1(@cOrdem),STR0166,STR0166,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Divergentes"	
			oStruct:AddField("QTDFLD5",fSoma1(@cOrdem),STR0170,STR0170,NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qtd.Divergentes"
		EndIf

		oStruct:AddField("TOTTOT",fSoma1(@cOrdem),STR0015,STR0015,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Total Geral"	
		oStruct:AddField("QTDTOT",fSoma1(@cOrdem),STR0240,STR0240,NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qtd. Total"
	EndCase
						
Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} AddField
Inclusao dos Campos de Selecao dos Registros

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static Function AddField( nOpcao As Numeric, oStruct As Object, bValid As Codeblock, nFolder as Numeric )

	Local bBlock As Codeblock
	Local cCampoV As Character
	Local cCampoF As Character
	Local nTamCpo As Numeric

	Default nOpcao := 0
	Default oStruct := Nil
	Default bValid := NIL
	Default nFolder := 0


	If __lPrcDocT
		cCampoV := "XDOCTEF"
		nTamCpo	:= __nTamDoc
		cCampoF	:= AllTrim(RetTitle("FIF_NUCOMP"))
	Else
		cCampoV := "XNSUTEF"
		nTamCpo	:= __nTamNSU
		cCampoF	:= AllTrim(RetTitle("FIF_NSUTEF"))
	EndIf

	If __lPrcDocT
		bBlock := {||REPLICATE('0', __nTamDOC - LEN(Rtrim(FIF_NUCOMP))) + RTrim(FIF_NUCOMP)}
	Else
		bBlock := {||REPLICATE('0', __nTamNSU - LEN(Rtrim(FIF_NSUTEF))) + RTrim(FIF_NSUTEF)}
	EndIf
	
	Do Case
	Case nOpcao == 1	//Model
	
		oStruct:AddField(		STR0256						,;	//[01]  C   Titulo do campo		//"Conciliar"
								STR0256						,;	//[02]  C   ToolTip do campo	//"Conciliar"
							 	"OK"						,;	//[03]  C   Id do Field
							 	"L"							,;	//[04]  C   Tipo do campo
								1							,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								0							,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								bValid						,;	//[07]  B   Code-block de validação do campo
								NIL							,;	//[08]  B   Code-block de validação When do campo
								NIL							,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.							,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								IIf(nFolder == 3, {||.T.}, {||.F.})						,;	//[11]  B   Code-block de inicializacao do campo
								.F.							,;	//[12]  L   Indica se trata-se de um campo chave
								.F.							,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.F.							)	//[14]  L   Indica se o campo é virtual
		
		If Alltrim(oStruct:aTable[1]) == "FIF"

			oStruct:AddField(	STR0257							,;	//[01]  C   Titulo do campo //"Recno FIF"
								STR0257							,;	//[02]  C   ToolTip do campo
								"FIF_RECNO"						,;	//[03]  C   Id do Field
								"N"								,;	//[04]  C   Tipo do campo
								10		    					,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								0		    					,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatÃ³rio
								{|| RECNO }		    	,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.T.								)	//[14]  L   Indica se o campo é virtual

			oStruct:AddField(	"XPARCEL"						,;	//[01]  C   Titulo do campo "xPartef"
								"XPARCEL"						,;	//[02]  C   ToolTip do campo
								"XPARCEL"						,;	//[03]  C   Id do Field
								"C"								,;	//[04]  C   Tipo do campo
								3								,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								0								,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validaÃ§Ã£o do campo
								NIL								,;	//[08]  B   Code-block de validaÃ§Ã£o When do campo
								NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatÃ³rio
								{||}							,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operaÃ§Ã£o de update.
								.T.								)	//[14]  L   Indica se o campo Ã© virtual

			oStruct:AddField(	cCampoV							,;	//[01]  C   Titulo do campo 
								cCampoV							,;	//[02]  C   ToolTip do campo
								cCampoV							,;	//[03]  C   Id do Field
								"C"								,;	//[04]  C   Tipo do campo
								nTamCpo			    			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								0		    					,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validaÃ§Ã£o do campo
								NIL								,;	//[08]  B   Code-block de validaÃ§Ã£o When do campo
								NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatÃ³rio
								bBlock					    	,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operaÃ§Ã£o de update.
								.T.								)	//[14]  L   Indica se o campo Ã© virtual

		EndIf

		If nFolder != 5 .And. nFolder != 6 
			oStruct:AddField(AllTrim(RetTitle("E1_FILORIG"))	,;	//[01]  C   Titulo do campo
							AllTrim(RetTitle("E1_FILORIG"))		,;	//[02]  C   ToolTip do campo
							"E1_XFILORI"						,;	//[03]  C   Id do Field
							TAMSX3("E1_FILORIG")[3]				,;	//[04]  C   Tipo do campo
							TAMSX3("E1_FILORIG")[1]				,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
							TAMSX3("E1_FILORIG")[2]				,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
							Nil									,;	//[07]  B   Code-block de validação do campo
							Nil									,;	//[08]  B   Code-block de validação When do campo
							Nil									,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
							.F.									,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
							{ ||SE1->E1_FILORIG }				,;	//[11]  B   Code-block de inicializacao do campo
							.F.									,;	//[12]  L   Indica se trata-se de um campo chave
							.F.									,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
							.T.									)	//[14]  L   Indica se o campo é virtual

		EndIf
									
		If nFolder == 1 .Or. nFolder == 2 .Or. nFolder == 7
									
			oStruct:AddField(	STR0256							,;	//[01]  C   Titulo do campo "Conciliar"
								STR0256							,;	//[02]  C   ToolTip do campo
								STR0256							,;	//[03]  C   Id do Field
								"L"								,;	//[04]  C   Tipo do campo
								1								,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								0								,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatÃ³rio
								{||.T.}							,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.T.								)	//[14]  L   Indica se o campo é virtual	
										
		EndIf

	If __lPixDig .And. (nFolder == 7 .And. oStruct:aTable[1] == "FJU")

			oStruct:AddField(	"Prefixo"						,;	//[01]  C   Titulo do campo "Conciliar"
								"Prefixo"						,;	//[02]  C   ToolTip do campo
								"FJU_PREFIX"					,;	//[03]  C   Id do Field
								TAMSX3("FJU_PREFIX")[3]			,;	//[04]  C   Tipo do campo
								TAMSX3("FJU_PREFIX")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FJU_PREFIX")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil								,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.F.								)	//[14]  L   Indica se o campo é virtual	

			oStruct:AddField(	"Numero"						,;	//[01]  C   Titulo do campo "Conciliar"
								"Numero"						,;	//[02]  C   ToolTip do campo
								"FJU_NUM"						,;	//[03]  C   Id do Field
								TAMSX3("FJU_NUM")[3]			,;	//[04]  C   Tipo do campo
								TAMSX3("FJU_NUM")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FJU_NUM")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil								,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.F.								)	//[14]  L   Indica se o campo é virtual	

			oStruct:AddField(	"Parcela"						,;	//[01]  C   Titulo do campo "Conciliar"
								"Parcela"						,;	//[02]  C   ToolTip do campo
								"FJU_PARCEL"					,;	//[03]  C   Id do Field
								TAMSX3("FJU_PARCEL")[3]			,;	//[04]  C   Tipo do campo
								TAMSX3("FJU_PARCEL")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FJU_PARCEL")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil								,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.F.								)	//[14]  L   Indica se o campo é virtual	

			oStruct:AddField(	"Cli/For"						,;	//[01]  C   Titulo do campo "Conciliar"
								"Cli/For"						,;	//[02]  C   ToolTip do campo
								"FJU_CLIFOR"					,;	//[03]  C   Id do Field
								TAMSX3("FJU_CLIFOR")[3]			,;	//[04]  C   Tipo do campo
								TAMSX3("FJU_CLIFOR")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FJU_CLIFOR")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil								,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.F.								)	//[14]  L   Indica se o campo é virtual	

			oStruct:AddField(	"Loja"							,;	//[01]  C   Titulo do campo "Conciliar"
								"Loja"							,;	//[02]  C   ToolTip do campo
								"FJU_LOJA"						,;	//[03]  C   Id do Field
								TAMSX3("FJU_LOJA")[3]			,;	//[04]  C   Tipo do campo
								TAMSX3("FJU_LOJA")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FJU_LOJA")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil								,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.F.								)	//[14]  L   Indica se o campo é virtual	

			oStruct:AddField(	"Emissao"						,;	//[01]  C   Titulo do campo "Conciliar"
								"Emissao"						,;	//[02]  C   ToolTip do campo
								"FJU_EMIS"						,;	//[03]  C   Id do Field
								TAMSX3("FJU_EMIS")[3]			,;	//[04]  C   Tipo do campo
								TAMSX3("FJU_EMIS")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FJU_EMIS")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil								,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.F.								)	//[14]  L   Indica se o campo é virtual	

			oStruct:AddField(	"Valor"							,;	//[01]  C   Titulo do campo "Conciliar"
								"Valor"							,;	//[02]  C   ToolTip do campo
								"FJU_VALOR"						,;	//[03]  C   Id do Field
								TAMSX3("FJU_VALOR")[3]			,;	//[04]  C   Tipo do campo
								TAMSX3("FJU_VALOR")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FJU_VALOR")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil								,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.F.								)	//[14]  L   Indica se o campo é virtual	

			oStruct:AddField(	"Tipo"							,;	//[01]  C   Titulo do campo "Conciliar"
								"Tipo"							,;	//[02]  C   ToolTip do campo
								"FJU_TIPO"						,;	//[03]  C   Id do Field
								TAMSX3("FJU_TIPO")[3]			,;	//[04]  C   Tipo do campo
								TAMSX3("FJU_TIPO")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FJU_TIPO")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil								,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.F.								)	//[14]  L   Indica se o campo é virtual	

			oStruct:AddField(	"Vencto.Real"					,;	//[01]  C   Titulo do campo "Conciliar"
								"Vencto.Real"					,;	//[02]  C   ToolTip do campo
								"FJU_VENREA"					,;	//[03]  C   Id do Field
								TAMSX3("FJU_VENREA")[3]			,;	//[04]  C   Tipo do campo
								TAMSX3("FJU_VENREA")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FJU_VENREA")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil								,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.F.								)	//[14]  L   Indica se o campo é virtual	

			oStruct:AddField(	"Num. NSU"						,;	//[01]  C   Titulo do campo "Conciliar"
								"Num. NSU"						,;	//[02]  C   ToolTip do campo
								"FJU_DOCTEF"					,;	//[03]  C   Id do Field
								TAMSX3("FJU_DOCTEF")[3]			,;	//[04]  C   Tipo do campo
								TAMSX3("FJU_DOCTEF")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FJU_DOCTEF")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil								,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.F.								)	//[14]  L   Indica se o campo é virtual	

			oStruct:AddField(	"Carteira"						,;	//[01]  C   Titulo do campo "Conciliar"
								"Carteira"						,;	//[02]  C   ToolTip do campo
								"FJU_CART"						,;	//[03]  C   Id do Field
								TAMSX3("FJU_CART")[3]			,;	//[04]  C   Tipo do campo
								TAMSX3("FJU_CART")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FJU_CART")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil								,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.F.								)	//[14]  L   Indica se o campo é virtual	

			oStruct:AddField(	"Rec.Orig"						,;	//[01]  C   Titulo do campo "Conciliar"
								"Rec.Orig"						,;	//[02]  C   ToolTip do campo
								"FJU_RECORI"					,;	//[03]  C   Id do Field
								TAMSX3("FJU_RECORI")[3]			,;	//[04]  C   Tipo do campo
								TAMSX3("FJU_RECORI")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FJU_RECORI")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil								,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.F.								)	//[14]  L   Indica se o campo é virtual

			oStruct:AddField(	"Rec.Tit Pai"					,;	//[01]  C   Titulo do campo "Conciliar"
								"Rec.Tit Pai"					,;	//[02]  C   ToolTip do campo
								"FJU_RECPAI"					,;	//[03]  C   Id do Field
								TAMSX3("FJU_RECPAI")[3]			,;	//[04]  C   Tipo do campo
								TAMSX3("FJU_RECPAI")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FJU_RECPAI")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil								,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.F.								)	//[14]  L   Indica se o campo é virtual

			oStruct:AddField(	"Exclusao"						,;	//[01]  C   Titulo do campo "Conciliar"
								"Exclusao"						,;	//[02]  C   ToolTip do campo
								"FJU_DTEXCL"					,;	//[03]  C   Id do Field
								TAMSX3("FJU_DTEXCL")[3]			,;	//[04]  C   Tipo do campo
								TAMSX3("FJU_DTEXCL")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FJU_DTEXCL")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								Nil								,;	//[08]  B   Code-block de validação When do campo
								Nil								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil								,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.F.								)	//[14]  L   Indica se o campo é virtual	

		EndIf

	Case nOpcao == 2	//View

		oStruct:AddField(	"OK"							,;	// [01]  C   Nome do Campo
							"01"							,;	// [02]  C   Ordem
							STR0256							,;	// [03]  C   Titulo do campo		//"Conciliar"
							STR0256							,;	// [04]  C   Descricao do campo		//"Conciliar"
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
							NIL								)	// [18]  L   Indica pulo de linha após o
		
		If SubStr(Alltrim(oStruct:aFields[1,1]),1,3) == "FIF"		

			oStruct:AddField(	"FIF_RECNO"							,;	// [01]  C   Nome do Campo
								"20",								;	// [02]  C   Ordem
								STR0257								,;	// [03]  C   Titulo do campo //"Recno FIF"
								STR0257								,;	// [04]  C   Descricao do campo
								NIL									,;	// [05]  A   Array com Help
								"N"									,;	// [06]  C   Tipo do campo
								"9999999999"						,;	// [07]  C   Picture
								NIL									,;	// [08]  B   Bloco de Picture Var
								NIL									,;	// [09]  C   Consulta F3
								.F.									,;	// [10]  L   Indica se o campo é alteravel
								NIL									,;	// [11]  C   Pasta do campo
								NIL									,;	// [12]  C   Agrupamento do campo
								NIL									,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL									,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL									,;	// [15]  C   Inicializador de Browse
								.T.									,;	// [16]  L   Indica se o campo é virtual
								NIL									,;	// [17]  C   Picture Variavel
								NIL									)	// [18]  L   Indica pulo de linha após o campo 

			oStruct:AddField(	"XPARCEL"							,;	// [01]  C   Nome do Campo
								"11"								,;	// [02]  C   Ordem
								AllTrim(RetTitle("E1_PARCELA"))		,;	// [03]  C   Titulo do campo //"Recno FIF"
								AllTrim(RetTitle("E1_PARCELA"))		,;	// [04]  C   Descricao do campo
								NIL									,;	// [05]  A   Array com Help
								"C"									,;	// [06]  C   Tipo do campo
								NIL									,;	// [07]  C   Picture
								NIL									,;	// [08]  B   Bloco de Picture Var
								NIL									,;	// [09]  C   Consulta F3
								.F.									,;	// [10]  L   Indica se o campo Ã© alteravel
								NIL									,;	// [11]  C   Pasta do campo
								NIL									,;	// [12]  C   Agrupamento do campo
								NIL									,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL									,;	// [14]  N   Tamanho maximo da maior opÃ§Ã£o do combo
								NIL									,;	// [15]  C   Inicializador de Browse
								.T.									,;	// [16]  L   Indica se o campo Ã© virtual
								NIL									,;	// [17]  C   Picture Variavel
								NIL									)	// [18]  L   Indica pulo de linha apÃ³s o campo

			oStruct:AddField(	cCampoV								,;	// [01]  C   Nome do Campo
								"21"								,;	// [02]  C   Ordem
								cCampoF								,;	// [03]  C   Titulo do campo 
								cCampoF								,;	// [04]  C   Descricao do campo
								NIL									,;	// [05]  A   Array com Help
								"C"									,;	// [06]  C   Tipo do campo
								NIL									,;	// [07]  C   Picture
								NIL									,;	// [08]  B   Bloco de Picture Var
								NIL									,;	// [09]  C   Consulta F3
								.F.									,;	// [10]  L   Indica se o campo Ã© alteravel
								NIL									,;	// [11]  C   Pasta do campo
								NIL									,;	// [12]  C   Agrupamento do campo
								NIL									,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL									,;	// [14]  N   Tamanho maximo da maior opÃ§Ã£o do combo
								NIL									,;	// [15]  C   Inicializador de Browse
								.T.									,;	// [16]  L   Indica se o campo Ã© virtual
								NIL									,;	// [17]  C   Picture Variavel
								NIL									)	// [18]  L   Indica pulo de linha apÃ³s o campo 

		EndIf

		If nFolder != 5 .And. nFolder != 6 
			oStruct:AddField("E1_XFILORI"				,;	// [01]  C   Nome do Campo
			"18"										,;	// [02]  C   Ordem
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
		EndIf
		
		If nFolder == 1 .Or. nFolder == 2 .Or. nFolder == 7
		
			oStruct:AddField(	STR0256								,;	// [01]  C   Nome do Campo
								"01"								,;	// [02]  C   Ordem
								STR0256								,;	// [03]  C   Titulo do campo
								STR0256								,;	// [04]  C   Descricao do campo
								NIL									,;	// [05]  A   Array com Help
								"Check"								,;	// [06]  C   Tipo do campo
								NIL									,;	// [07]  C   Picture
								NIL									,;	// [08]  B   Bloco de Picture Var
								NIL									,;	// [09]  C   Consulta F3
								.F.									,;	// [10]  L   Indica se o campo é alteravel
								NIL									,;	// [11]  C   Pasta do campo
								NIL									,;	// [12]  C   Agrupamento do campo
								NIL									,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL									,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL									,;	// [15]  C   Inicializador de Browse
								.T.									,;	// [16]  L   Indica se o campo é virtual
								NIL									,;	// [17]  C   Picture Variavel
								NIL									)	// [18]  L   Indica pulo de linha após o campo
								
		EndIf

	If __lPixDig .And. (nFolder == 7 .And. SubStr(Alltrim(oStruct:aFields[1,1]),1,3) == "FJU")
					
			oStruct:AddField(	"FJU_PREFIX"								,;	// [01]  C   Nome do Campo
								"03"										,;	// [02]  C   Ordem
								"Prefixo"									,;	// [03]  C   Titulo do campo
								"Prefixo"									,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"				    						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.F.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"FJU_NUM"									,;	// [01]  C   Nome do Campo
								"04"										,;	// [02]  C   Ordem
								"Numero"									,;	// [03]  C   Titulo do campo
								"Numero"									,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"				    						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.F.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"FJU_PARCEL"								,;	// [01]  C   Nome do Campo
								"05"										,;	// [02]  C   Ordem
								"Parcela"									,;	// [03]  C   Titulo do campo
								"Parcela"									,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"				    						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.F.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"FJU_CLIFOR"								,;	// [01]  C   Nome do Campo
								"06"										,;	// [02]  C   Ordem
								"Cli/For"									,;	// [03]  C   Titulo do campo
								"Cli/For"									,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"				    						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.F.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"FJU_LOJA"									,;	// [01]  C   Nome do Campo
								"07"										,;	// [02]  C   Ordem
								"Loja"										,;	// [03]  C   Titulo do campo
								"Loja"										,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"				    						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.F.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"FJU_EMIS"									,;	// [01]  C   Nome do Campo
								"08"										,;	// [02]  C   Ordem
								"Emissao"									,;	// [03]  C   Titulo do campo
								"Emissao"									,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"D"				    						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.F.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"FJU_VALOR"									,;	// [01]  C   Nome do Campo
								"09"										,;	// [02]  C   Ordem
								"Valor"										,;	// [03]  C   Titulo do campo
								"Valor"										,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"N"				    						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.F.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"FJU_TIPO"									,;	// [01]  C   Nome do Campo
								"10"										,;	// [02]  C   Ordem
								"Tipo"										,;	// [03]  C   Titulo do campo
								"Tipo"										,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"				    						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.F.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"FJU_VENREA"								,;	// [01]  C   Nome do Campo
								"11"										,;	// [02]  C   Ordem
								"Vencto.Real"								,;	// [03]  C   Titulo do campo
								"Vencto.Real"								,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"D"				    						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.F.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"FJU_DOCTEF"								,;	// [01]  C   Nome do Campo
								"12"										,;	// [02]  C   Ordem
								"Id. Transação"								,;	// [03]  C   Titulo do campo
								"Id. Transação"								,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"				    						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.F.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"FJU_CART"									,;	// [01]  C   Nome do Campo
								"13"										,;	// [02]  C   Ordem
								"Carteira"									,;	// [03]  C   Titulo do campo
								"Carteira"									,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"				    						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.F.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"FJU_RECORI"								,;	// [01]  C   Nome do Campo
								"14"										,;	// [02]  C   Ordem
								"Rec.Orig"									,;	// [03]  C   Titulo do campo
								"Rec.Orig"									,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"N"				    						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.F.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
			
			oStruct:AddField(	"FJU_RECPAI"								,;	// [01]  C   Nome do Campo
								"15"										,;	// [02]  C   Ordem
								"Rec.Tit Pai"								,;	// [03]  C   Titulo do campo
								"Rec.Tit Pai"								,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"N"				    						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.F.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"FJU_DTEXCL"								,;	// [01]  C   Nome do Campo
								"16"										,;	// [02]  C   Ordem
								"Exclusao"									,;	// [03]  C   Titulo do campo
								"Exclusao"									,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"D"				    						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.F.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo

		EndIf	
	EndCase
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetProp
Ajuste nas Propriedades dos Campos da FIF, SE1 e FJU

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static Function SetProp(oModel As Object, nOpcao As Numeric, oStruct As Object, cDesc as Character, nFilter as Numeric, cAliasF as Character)

Default oModel  := NIL
Default nOpcao  := 0
Default oStruct := NIL
Default cDesc   := ""
Default nFilter := 0
Default cAliasF	:= "FIF"
	
	//Bloqueia alteracoes em todos os campos
	//da grid com excecao do campo de selecao
	Do Case
	Case nOpcao == 1	//Model
		If oModel != Nil
			oModel:SetDescription(cDesc)
			oModel:SetNoDeleteLine(.T.)
			oModel:SetNoInsertLine(.T.)
			oModel:SetOptional(.T.)
			oModel:SetOnlyQuery(.T.)
			// Define o numero maximo de linhas que o model poderao receber, de acordo com a define GRIDMAXLIN.
			oModel:SetMaxLine(GRIDMAXLIN)
		EndIf

		If oStruct != Nil
			oStruct:SetProperty("*",	MODEL_FIELD_OBRIGAT, 	.F.)
			oStruct:SetProperty("*", 	MODEL_FIELD_WHEN, 		{|| .F. })
			oStruct:SetProperty("OK",	MODEL_FIELD_WHEN, 		{|| .T. })
		EndIf	

	Case nOpcao == 2	//View
		oStruct:SetProperty("*", 	MVC_VIEW_CANCHANGE, .F.)

		If cAliasF == "FIF"
			oStruct:SetProperty("OK"		, MVC_VIEW_CANCHANGE, .T.)

			oStruct:SetProperty('OK'  	     , MVC_VIEW_ORDEM ,'01')
			oStruct:SetProperty('FIF_CODEST' , MVC_VIEW_ORDEM ,'02')
			oStruct:SetProperty('FIF_CODLOJ' , MVC_VIEW_ORDEM ,'03')
			oStruct:SetProperty('FIF_NUCOMP' , MVC_VIEW_ORDEM ,'04')	
			oStruct:SetProperty('FIF_NSUTEF' , MVC_VIEW_ORDEM ,'05')
			oStruct:SetProperty('FIF_DTTEF'  , MVC_VIEW_ORDEM ,'06')
			oStruct:SetProperty('FIF_DTCRED' , MVC_VIEW_ORDEM ,'07')	
			oStruct:SetProperty('FIF_VLBRUT' , MVC_VIEW_ORDEM ,'08')
			oStruct:SetProperty('FIF_VLLIQ'  , MVC_VIEW_ORDEM ,'09')			
			oStruct:SetProperty('FIF_PARCEL' , MVC_VIEW_ORDEM ,'10')
			oStruct:SetProperty('FIF_CODBCO' , MVC_VIEW_ORDEM ,'11')	
			oStruct:SetProperty('FIF_CODAGE' , MVC_VIEW_ORDEM ,'12')	
			oStruct:SetProperty('FIF_NUMCC'  , MVC_VIEW_ORDEM ,'13')	
			oStruct:SetProperty('FIF_CAPTUR' , MVC_VIEW_ORDEM ,'14')	
			oStruct:SetProperty('FIF_RECNO'  , MVC_VIEW_ORDEM ,'15')	
			oStruct:SetProperty('FIF_CODFIL' , MVC_VIEW_ORDEM ,'16')
			oStruct:SetProperty('FIF_CODADM' , MVC_VIEW_ORDEM ,'17')
			oStruct:SetProperty('FIF_CODMAJ' , MVC_VIEW_ORDEM ,'18')
			oStruct:SetProperty('FIF_CODAUT' , MVC_VIEW_ORDEM ,'19')
			oStruct:SetProperty('FIF_NSUARQ' , MVC_VIEW_ORDEM ,'20')
			oStruct:SetProperty('FIF_TPREG'  , MVC_VIEW_ORDEM ,'21')
			oStruct:SetProperty('FIF_NURESU' , MVC_VIEW_ORDEM ,'22')	
			oStruct:SetProperty('FIF_TPPROD' , MVC_VIEW_ORDEM ,'23')	
			oStruct:SetProperty('FIF_VLCOM'  , MVC_VIEW_ORDEM ,'24')	
			oStruct:SetProperty('FIF_TXSERV' , MVC_VIEW_ORDEM ,'25')	
			oStruct:SetProperty('FIF_PARALF' , MVC_VIEW_ORDEM ,'26')
			oStruct:SetProperty('FIF_CODBAN' , MVC_VIEW_ORDEM ,'27')
			oStruct:SetProperty('FIF_SEQFIF' , MVC_VIEW_ORDEM ,'28')
			oStruct:SetProperty('FIF_PARC'   , MVC_VIEW_ORDEM ,'29')	
			oStruct:SetProperty('FIF_PGJUST' , MVC_VIEW_ORDEM ,'30')	
			oStruct:SetProperty('FIF_PGDES1' , MVC_VIEW_ORDEM ,'31')	
			oStruct:SetProperty('FIF_PGDES2' , MVC_VIEW_ORDEM ,'32')	
			oStruct:SetProperty('FIF_TPPROD' , 13, F920RetCbx('FIF_TPPROD') )

			If __lTef
				oStruct:SetProperty('FIF_NUCOMP' , MVC_VIEW_TITULO  ,'DOCTEF')	
				oStruct:SetProperty('FIF_NSUTEF' , MVC_VIEW_TITULO  ,'NSUTEF')
			Else
				oStruct:SetProperty('FIF_NUCOMP' , MVC_VIEW_TITULO  , STR0262)
			EndIf	
			
		EndIf

		If cAliasF == "SE1"
			oStruct:SetProperty('E1_EMISSAO' 	, MVC_VIEW_ORDEM ,'02')
			oStruct:SetProperty('E1_VENCREA' 	, MVC_VIEW_ORDEM ,'03')
			oStruct:SetProperty('E1_VALOR'   	, MVC_VIEW_ORDEM ,'04')
			oStruct:SetProperty('E1_DOCTEF' 	, MVC_VIEW_ORDEM ,'05')	

			If __lTef
				oStruct:SetProperty('E1_NSUTEF' 	, MVC_VIEW_ORDEM ,'06')
			EndIf

			oStruct:SetProperty('E1_PREFIXO' 	, MVC_VIEW_ORDEM ,'07')
			oStruct:SetProperty('E1_NUM'     	, MVC_VIEW_ORDEM ,'08')
			oStruct:SetProperty('E1_PARCELA' 	, MVC_VIEW_ORDEM ,'09')
			oStruct:SetProperty('E1_CLIENTE' 	, MVC_VIEW_ORDEM ,'10')
			oStruct:SetProperty('E1_LOJA'    	, MVC_VIEW_ORDEM ,'11')
			oStruct:SetProperty('E1_NOMCLI'  	, MVC_VIEW_ORDEM ,'12')
			oStruct:SetProperty('E1_VENCTO'  	, MVC_VIEW_ORDEM ,'13')
			oStruct:SetProperty('E1_TIPO'    	, MVC_VIEW_ORDEM ,'14')
			oStruct:SetProperty('E1_NATUREZ' 	, MVC_VIEW_ORDEM ,'15')
			oStruct:SetProperty('E1_XFILORI' 	, MVC_VIEW_ORDEM ,'16')

			If __lTef
				oStruct:SetProperty('E1_DOCTEF' 	, MVC_VIEW_TITULO  ,'DOCTEF')	
				oStruct:SetProperty('E1_NSUTEF' 	, MVC_VIEW_TITULO  ,'NSUTEF')
			Else
				oStruct:SetProperty('E1_DOCTEF'     , MVC_VIEW_TITULO  ,STR0262)	// Id de Transação
			EndIf

		EndIf
	EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F920Ms
Painel com a descrição do motivo de rejeição na aba divergente

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Function F920Ms( oPanel As Object, cDescri As Character)

Default oPanel  := Nil
Default cDescri := ""

	If oPanel != Nil
		DEFINE FONT oFnt NAME "Arial" SIZE 11,20 
		@ 015, 010 SAY   STR0172 SIZE 050, 020 OF oPanel PIXEL FONT oFnt COLOR CLR_HBLUE //"Detalhes:"
		@ 030, 010 MSGET __oDescri VAR cDescri SIZE 200, 40  Of oPanel PIXEL When .F.
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A920Msg 
Inclui informaçao do motivo de rejeiçao na aba divergente

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static function A920Msg( cDescri As Character ) As Logical
Local lRet			As Logical
Local oModel		As Object 
Local oView			As Object 
Local oModelGrid	As Object
Local cCampo		As Character
Local cCodFil		As Character

Default cDescri := ""

lRet		:= .T.
oView  		:= FwViewActive()
oModel 		:= oView:GetModel()	
oModelGrid	:= oModel:GetModel('FIFFLD5')
cCampo		:= ""
cDescri		:= ""
cCodFil		:= ""
	
	If F920ChkMod("FVY") // Verifica se modo da tabela é exclusivo
		cCodFil := oModelGrid:GetValue("FIF_CODFIL")
	Else
		cCodFil := xFilial("FVY")
	EndIf

	DbSelectArea("FVY")
	FVY->(DbSetOrder(1))
	
	If FVY->(DbSeek(cCodFil + oModelGrid:GetValue("FIF_CODADM") + oModelGrid:GetValue("FIF_CODMAJ")))
		cDescri := Alltrim(FVY->FVY_DESCR)
	Else
		cDescri := " "
	EndIf			
		
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fLoadTot
Calculo dos Totais da Conciliacao

@type function
@author Totvs
@since 07/12/2020

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
	Local nVlrTotal As Numeric

	Default oSubMod := Nil

	aRetorno	:= {}
	aAux		:= {}
	aQry		:= {}
	nField		:= 0
	nX			:= 0
	cQuery		:= ""
	dData		:= CtoD("")
	nVlrTotal	:= 0

	If oSubMod != Nil
		aFields		:= oSubMod:GetStruct():GetFields()
	EndIf	

	If __nFldPar == 0 .Or. __nFldPar == 1
		cQuery := "SELECT	FIF.FIF_DTCRED			DATA"
		cQuery += ",		'1'						ABA"
		cQuery += ",		SUM(FIF.FIF_VLBRUT)		VALOR"
		cQuery += ",		SUM(FIF.FIF_VLLIQ)		VLLIQ"
		cQuery += ",		COUNT(FIF.FIF_DTCRED)	QUANT"
		cQuery += " FROM		" + __oAba1:GetRealName() + " FIF "
		cQuery += " WHERE	FIF.D_E_L_E_T_  = ' ' "
		cQuery += " GROUP BY FIF.FIF_DTCRED "
		cQuery += " ORDER BY DATA, ABA "
		aAdd(aQry, cQuery)
	EndIf

	If __nFldPar == 0 .Or. __nFldPar == 2
		cQuery := "SELECT	FIF.FIF_DTCRED			DATA"
		cQuery += ",		'2'						ABA"
		cQuery += ",		SUM(FIF.FIF_VLBRUT)		VALOR"
		cQuery += ",		SUM(FIF.FIF_VLLIQ)		VLLIQ"
		cQuery += ",		COUNT(FIF.FIF_DTCRED)	QUANT"
		cQuery += " FROM		" + __oAba2:GetRealName() + " FIF "
		cQuery += " WHERE	FIF.D_E_L_E_T_  = ' ' "
		cQuery += " GROUP BY FIF.FIF_DTCRED "
		cQuery += " ORDER BY DATA, ABA "
		aAdd(aQry, cQuery)
	EndIf

	If __nFldPar == 0 .Or. __nFldPar == 3
		cQuery := "SELECT	FIF.FIF_DTCRED			DATA"
		cQuery += ",		'3'						ABA"
		cQuery += ",		SUM(FIF.FIF_VLBRUT)		VALOR"
		cQuery += ",		SUM(FIF.FIF_VLLIQ)		VLLIQ"
		cQuery += ",		COUNT(FIF.FIF_DTCRED)	QUANT"
		cQuery += " FROM		" + __oAba3:GetRealName() + " FIF "
		cQuery += " WHERE	FIF.D_E_L_E_T_  = ' ' "
		cQuery += " GROUP BY FIF.FIF_DTCRED "
		cQuery += " ORDER BY DATA, ABA "
		aAdd(aQry, cQuery)
	EndIf

	If __nFldPar == 0 .Or. __nFldPar == 4
		cQuery := "SELECT	FIF.FIF_DTCRED			DATA"
		cQuery += ",		'4'						ABA"
		cQuery += ",		SUM(FIF.FIF_VLBRUT)		VALOR"
		cQuery += ",		SUM(FIF.FIF_VLLIQ)		VLLIQ"
		cQuery += ",		COUNT(FIF.FIF_DTCRED)	QUANT"
		cQuery += " FROM		" + __oAba4FIF:GetRealName() + " FIF "
		cQuery += " WHERE	FIF.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY FIF.FIF_DTCRED "
		cQuery += " ORDER BY DATA, ABA "
		aAdd(aQry, cQuery)
	EndIf

	If __nFldPar == 0 .Or. __nFldPar == 5
		cQuery := "SELECT	FIF.FIF_DTCRED			DATA"
		cQuery += ",		'5'						ABA"
		cQuery += ",		SUM(FIF.FIF_VLBRUT)		VALOR"
		cQuery += ",		SUM(FIF.FIF_VLLIQ)		VLLIQ"
		cQuery += ",		COUNT(FIF.FIF_DTCRED)	QUANT"
		cQuery += " FROM		" + __oAba5:GetRealName() + " FIF "
		cQuery += " WHERE	FIF.D_E_L_E_T_  = ' ' "
		cQuery += " GROUP BY FIF.FIF_DTCRED "
		cQuery += " ORDER BY DATA, ABA "
		aAdd(aQry, cQuery)
	EndIf

	If __lPixDig .And. (__nFldPar == 0 .Or. __nFldPar == 7)
		cQuery := "SELECT	FIF.FIF_DTCRED			DATA"
		cQuery += ",		'7'						ABA"
		cQuery += ",		SUM(FIF.FIF_VLBRUT)		VALOR"
		cQuery += ",		SUM(FIF.FIF_VLLIQ)		VLLIQ"
		cQuery += ",		COUNT(FIF.FIF_DTCRED)	QUANT"
		cQuery += " FROM		" + __oAba7:GetRealName() + " FIF "
		cQuery += " WHERE	FIF.D_E_L_E_T_  = ' ' "
		cQuery += " GROUP BY FIF.FIF_DTCRED "
		cQuery += " ORDER BY DATA, ABA "
		aAdd(aQry, cQuery)
	EndIf

	// Executa querys individualmente para evitar problemas com estouro de variÃ¡vel caso existam muitas filiais para serem filtradas (selecionadas no filtrar filiais "SIM")
	For nX := 1 To Len(aQry)

		cTabQry := GetNextAlias()

		cQuery := ChangeQuery(aQry[nX])

		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)

		While !(cTabQry)->(Eof())

			dData := SToD((cTabQry)->DATA)
			If (nPos := aScan(aRetorno, { |x| x[2][1] == dData })) > 0
				aAux := aClone(aRetorno[nPos][2])
			Else
				aAux := Array(Len(aFields))
				aAux[01] := dData
				For nField := 2 To Len(aAux)
					aAux[nField] := 0
				Next nField
			EndIf

			If __lLJGERTX .And. !__lPixDig
				nVlrTotal := (cTabQry)->VALOR
			Else
				nVlrTotal := (cTabQry)->VLLIQ
			EndIf

			Do Case
				Case (cTabQry)->ABA == "1"
					aAux[Ascan(aFields, { |x| x[03] == "TOTFLD1" })] += nVlrTotal
					aAux[Ascan(aFields, { |x| x[03] == "QTDFLD1" })] += (cTabQry)->QUANT
				Case (cTabQry)->ABA == "2"
					aAux[Ascan(aFields, { |x| x[03] == "TOTFLD2" })] += nVlrTotal
					aAux[Ascan(aFields, { |x| x[03] == "QTDFLD2" })] += (cTabQry)->QUANT
				Case (cTabQry)->ABA == "3"
					aAux[Ascan(aFields, { |x| x[03] == "TOTFLD3" })] += nVlrTotal
					aAux[Ascan(aFields, { |x| x[03] == "QTDFLD3" })] += (cTabQry)->QUANT
				Case (cTabQry)->ABA == "4"
					aAux[Ascan(aFields, { |x| x[03] == "TOTFLD4" })] += nVlrTotal
					aAux[Ascan(aFields, { |x| x[03] == "QTDFLD4" })] += (cTabQry)->QUANT
				Case (cTabQry)->ABA == "5"
					aAux[Ascan(aFields, { |x| x[03] == "TOTFLD5" })] += nVlrTotal
					aAux[Ascan(aFields, { |x| x[03] == "QTDFLD5" })] += (cTabQry)->QUANT
				Case __lPixDig .And. (cTabQry)->ABA == "7"
					aAux[Ascan(aFields, { |x| x[03] == "TOTFLD7" })] += nVlrTotal
					aAux[Ascan(aFields, { |x| x[03] == "QTDFLD7" })] += (cTabQry)->QUANT
			EndCase

			aAux[Ascan(aFields, { |x| x[03] == "TOTTOT" })] += nVlrTotal
			aAux[Ascan(aFields, { |x| x[03] == "QTDTOT" })] += (cTabQry)->QUANT

			If  nPos > 0
				aRetorno[nPos][2] := aClone(aAux)
			Else
				Aadd(aRetorno, { 0, aAux })
				aAux := {}
			EndIf

			(cTabQry)->(DbSkip())

		End

		(cTabQry)->(DbCloseArea())

	Next nX

	//Se não houver dados retorna um Array vazio
	If Len(aRetorno) == 0
		aAux := Array(Len(aFields))
		aAux[01] := dDatabase
	
		For nField := 2 To Len(aAux)
			aAux[nField] := 0
		Next nField
	
		Aadd(aRetorno, { 0, aAux })
	Else
		aRetorno := aSort(aRetorno,,,{ |x,y| x[2][1] < y[2][1] })
	EndIf

	aAux := {}
	aQry := {}
	aFields := {}

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldOk
Valida a Selecao do FIF x SE1

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static Function fVldOk(oModel As Object, cCampo As Character, lValue As Logical) As Logical
Local lRetorno	As Logical
Local nLinha	As Numeric
Local nLinBkp	As Numeric

Default oModel := FWModelActive()
Default cCampo := ""
Default lValue := .F.

lRetorno	:= .T.
nLinha		:= 0
nLinBkp		:= 0

	If lValue
		nLinBkp	:= oModel:GetLine()
		For nLinha := 1 To oModel:Length()
			oModel:GoLine(nLinha)
			If nLinha <> nLinBkp
				If oModel:GetValue("OK")
					lRetorno := .F.
					Help(NIL, NIL, "FVLDOK", NIL, STR0241, 1, 0)	//"Selecionar apenas um registro por vez para conciliação."
					Exit
				EndIf
			EndIf
		Next nLinha
		oModel:GoLine(nLinBkp)
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} F920Print
Função para impressão das grids da FIF e SE1 no excel para conferência manual

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static Function F920Print(oView As Object)
Local oModel 	 As Object
Local oModGrid1	 As Object
Local oModGrid2	 As Object
Local aPlanilha  As Array
Local aStructFIF As Array
Local aStructSE1 As Array
Local aStructFJU As Array
Local aColsFIF 	 As Array
Local aColsSE1 	 As Array
Local aColsFJU 	 As Array
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
Local cTitExcel  As Character 
Local lConcTotP  As Logical

Default oView  := FwViewActive()

oModel 		:= oView:GetModel()
oModGrid1	:= Nil
oModGrid2	:= Nil
nSheetAct	:= oView:GetFolderActive("FOLGRIDS", 2)[1]
cNameSheet	:= Alltrim(oView:GetFolderActive("FOLGRIDS", 2)[2])
cTitExcel 	:= IIf(__lTef, STR0230, STR0271) 
aPlanilha 	:= {}
aStructFIF 	:= {}
aStructSE1 	:= {}
aStructFJU 	:= {}
aColsFIF	:= {}
aColsSE1	:= {}
aColsFJU	:= {}
aAux		:= {}
nL			:= 0
nX			:= 0
nZ			:= 0
cGrid1 		:= ""
cGrid2 		:= ""
cConteudo	:= ""
cCpoCbx		:= "FIF_STATUS|FIF_TPREG" 
cCpoCbMvc   := "FIF_TPPROD"	
lConcTotP	:= .F.

	If __nFldPar == 0

		If nSheetAct == 1
			cGrid1 := "FIFFLD1"
			cGrid2 := "SE1FLD1"
		ElseIf nSheetAct == 2
			cGrid1 := "FIFFLD2"
			cGrid2 := "SE1FLD2"	
		ElseIf __lPixDig 
			If nSheetAct == 3
				cGrid1 := "FIFFLD7"
				cGrid2 := "FJUFLD7"
			ElseIf nSheetAct == 4
				cGrid1 := "SE1FLD3"
			ElseIf nSheetAct == 5
				cGrid1 := "FIFFLD4"
				cGrid2 := "SE1FLD4"
			ElseIf nSheetAct == 6
				cGrid1 := "FIFFLD5"
			ElseIf nSheetAct == 7
				cGrid1 := "TOTFLD6"		
			EndIf
		Else
			If nSheetAct == 3
				cGrid1 := "SE1FLD3"
			ElseIf nSheetAct == 4
				cGrid1 := "FIFFLD4"
				cGrid2 := "SE1FLD4"
			ElseIf nSheetAct == 5
				cGrid1 := "FIFFLD5"
			ElseIf nSheetAct == 6
				cGrid1 := "TOTFLD6"
			EndIf
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
		oModGrid1  := oModel:GetModel(cGrid1)
		aStructFIF := oModGrid1:GetStruct():GetFields()

		If __lPixDig .And. !Empty(cGrid2) .And. Alltrim(cGrid2) == "FJUFLD7"
			aColsFJU   := {}
			oModGrid2  := oModel:GetModel(cGrid2)
			aStructFJU := oModGrid2:GetStruct():GetFields()
		ElseIf lConcTotP .And. !Empty(cGrid2)
			aColsSE1   := {}
			oModGrid2  := oModel:GetModel(cGrid2)
			aStructSE1 := oModGrid2:GetStruct():GetFields()
		EndIf
		
		For nL := 1 To oModGrid1:Length()
			oModGrid1:GoLine(nL)
			aAux := {}
			For nX := 1 To Len(aStructFIF)
				If Alltrim(aStructFIF[nX][3]) $ cCpoCbx
					cConteudo := Alltrim(X3Combo(aStructFIF[nX][3], oModGrid1:GetValue(aStructFIF[nX][3])))
				ElseIf Alltrim(aStructFIF[nX][3]) $ cCpoCbMvc 
					cConteudo := F920GetCbx(Alltrim(aStructFIF[nX][3]), oModGrid1:GetValue(aStructFIF[nX][3])) 
				Else
					cConteudo := oModGrid1:GetValue(aStructFIF[nX][3])
				EndIf
				aAdd(aAux, cConteudo)
			Next nX
			aAdd(aColsFIF, aAux)

			If __lPixDig .And. !Empty(cGrid2) .And. Alltrim(cGrid2) == "FJUFLD7"				 
				For nZ := 1 To oModGrid2:Length()
					oModGrid2:GoLine(nZ)
					aAux := {}
					For nX := 1 To Len(aStructFJU)
						cConteudo := oModGrid2:GetValue(aStructFJU[nX][3])
						aAdd(aAux, cConteudo)
					Next nX
					aAdd(aColsFJU, aAux)
				Next nZ			
			ElseIf lConcTotP .And. !Empty(cGrid2)
				For nZ := 1 To oModGrid2:Length()
					oModGrid2:GoLine(nZ)
					aAux := {}
					For nX := 1 To Len(aStructSE1)
						cConteudo := oModGrid2:GetValue(aStructSE1[nX][3])
						aAdd(aAux, cConteudo)
					Next nX
					aAdd(aColsSE1, aAux)
				Next nZ
			EndIf

		Next nL

		aAdd(aPlanilha, { aStructFIF, aColsFIF })
		
		If __lPixDig .And. Len(aColsFJU) > 0 .And. Alltrim(cGrid2) == "FJUFLD7"		
			aAdd(aPlanilha, { aStructFJU, aColsFJU })		
		ElseIf Len(aColsSE1) > 0
			aAdd(aPlanilha, { aStructSE1, aColsSE1 })
		EndIf
	EndIf

	If !lConcTotP .And. !Empty(cGrid2) .And. Alltrim(cGrid2) != "FJUFLD7"
		aColsSE1 := {}
		oModGrid2  := oModel:GetModel(cGrid2)
		aStructSE1 := oModGrid2:GetStruct():GetFields()
		For nL := 1 To oModGrid2:Length()
			oModGrid2:GoLine(nL)
			aAux := {}
			For nX := 1 To Len(aStructSE1)				
				cConteudo := oModGrid2:GetValue(aStructSE1[nX][3])
				
				aAdd(aAux, cConteudo)
			Next nX
			aAdd(aColsSE1, aAux)
		Next nL
		aAdd(aPlanilha, { aStructSE1, aColsSE1 })
	EndIf

	// Imprime a Grid
	If Len(aPlanilha) > 0
		FWMsgRun(/*oComponent*/, { || F920Excel(aPlanilha, "FINA918", cTitExcel + " - " + cNameSheet) }, STR0230, STR0277)
	EndIf
 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F920Justif
Gatilho da descrição da justificativa

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static function F920Justif (oModel As Object) As Character 
Local cDesc	As Character
Local cCod 	As Character

Default oModel := FWModelActive()	

	cCod := oModel:GetValue("FIF_PGJUST")
	cDesc := Posicione("FVX",1,xFilial("FVX")+cCod,'FVX_DESCRI')
	
Return cDesc


//-------------------------------------------------------------------
/*/{Protheus.doc} F920ChkMod
Retorna se a tabela é exclusiva ou compartilhada

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Function F920ChkMod(cTabela As Character) As Logical
Local lExclusivo As Logical
Local cFilcomp 	 As Character

Default cTabela	:= ""

lExclusivo := .F.

	If !Empty(cTabela)
		cFilcomp := FWModeAccess(cTabela, 3)

		If cFilcomp == "E"
			lExclusivo := .T.
		EndIf
	EndIf	

Return lExclusivo

//-------------------------------------------------------------------
/*/{Protheus.doc} F920VTef
Pega o valor do FIF_VLLIQ e insere na grid da SE1 para confrontar os valores.

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static Function F920VTef(oView As Object, nOpc As Numeric)  
Local oModSE1 As Object
Local oModFJU As Object
Local oModFIF As Object
Local cSE1Painel As Character
Local cFJUPainel As Character
Local cFIFPainel As Character

Default oView 		:= FwViewActive()
Default nOpc		:= 1

	If nOpc == 1
		cSE1Painel	:= "SE1FLD1"
		cFIFPainel	:= "FIFFLD1"
	ElseIf nOpc == 2
		cSE1Painel	:= "SE1FLD2"
		cFIFPainel	:= "FIFFLD2"
	ElseIf nOpc == 3
		cSE1Painel	:= "SE1FLD3"
		cFIFPainel	:= "FIFFLD3"	
	ElseIf __lPixDig .And. nOpc == 7
		cFJUPainel	:= "FJUFLD7"
	 	cFIFPainel	:= "FIFFLD7"
	EndIf

	oModFIF := oView:GetModel(cFIFPainel)

	If __lPixDig .And. nOpc == 7		
		oModFJU := oView:GetModel(cFJUPainel)
		oModFJU:SetNoUpdateLine(.T.)

		oView:Refresh(cFJUPainel)
	Else
		oModSE1 := oView:GetModel(cSE1Painel)
		oModSE1:SetNoUpdateLine(.T.)

		oView:Refresh(cSE1Painel)
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} F920Excel
Exportaçao da GRID em arquivo XML

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Function F920Excel(aWorkSheet As Array, cOrigem As Character, cTitulo As Character, aTabDePara As Array) As Logical
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
cArqXml		:= cOrigem + '_' + DToS( dDataBase ) + '_' + StrTran( Time(), ':', '' ) +'.xml'
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

	aAdd(aTabDePara, { "FIF", "FIF" })
	aAdd(aTabDePara, { "E1", "SE1" })

	 //""Selecione o Diretório""
	IIf(__lSmtHTML, cArqXLS := GetTempPath(.T.), cArqXLS := cGetFile('',STR0242,0,,.F.,GETF_LOCALHARD+ GETF_RETDIRECTORY+GETF_NETWORKDRIVE))
	
	//Retira os campos fora do contexto PIX da planilha 
	If __lPixDig	
		cCpoExc += ArrTokStr(F920RemCpo("FIF", .T.),'/') 
		cCpoExc += ArrTokStr(F920RemCpo("SE1", .T.),'/') 
	Endif

	If !Empty(cArqXLS) .And. Len(aWorkSheet) > 0
	 	
		oExcel := FwMsExcel():New()

		For nX := 1 To Len(aWorkSheet)

			cNomeAlias 	:= ""
			aHeader 	:= aClone(aWorkSheet[nX][1])
			aCols 		:= aClone(aWorkSheet[nX][2])

			If Len(aHeader) > 0
				cAlias := SubStr(aHeader[1][3], 1, (At("_",aHeader[1][3])-1))
				If (nPos := aScan(aTabDePara, { |x| x[1] == cAlias })) > 0
					cAlias := aTabDePara[nPos][2]					
					If __lPixDig .And. cAlias == "FIF" 
						cModoPag := IIf(__nTpPagam == 1, STR0279, IIf(__nTpPagam == 2, STR0278, STR0264)) 
						cNomeAlias := STR0280 + cModoPag  
					Else 
						cNomeAlias := Lower(Alltrim(FWX2NOME(cAlias)))
						cNomeAlias := Upper(Left(cNomeAlias,1))+SubStr(cNomeAlias,2,Len(cNomeAlias)-1)
					EndIf
				Else
					cNomeAlias := cAlias
				EndIf

				cTable := cTitulo + IIf(Empty(cNomeAlias), "", " - " + cNomeAlias)
				cWorkSheet := cOrigem + IIf(Empty(cNomeAlias), "", " - " + cNomeAlias)

				oExcel:AddWorkSheet(cWorkSheet)
				oExcel:AddTable(cWorkSheet, cTable)

				For nH := 1 To Len(aHeader)

					cCampo := Alltrim(aHeader[nH][3])
					If !(cCampo $ cCpoExc)

						cNameCol := aHeader[nH][1]
						cTipo	 := aHeader[nH][4]
						nAlign	 := IIf(cTipo == 'N', 3, 1) //Alinhamento da coluna (1-Left,2-Center,3-Right)

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

				For nA := 1 To Len(aCols)
					aAux := {}
					For nH := 1 To Len(aHeader)
						cCampo := Alltrim(aHeader[nH][3])
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

		If (CpyS2T(cArqXml, cArqXLS, .T.))
			lRet := .T.
			MsgInfo(STR0243 + ' "' + cArqXml + '" ') //"Arquivo gerado com sucesso:"
		Else
			Alert(STR0186) //"Ocorreu um erro na gravacao do arquivo. Favor verificar"
		EndIf

		If File(cArqXml)
			FErase(cArqXml)
		EndIf
	
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F920Lock
Controle de concorrência para efetivação da conciliação - lock de seleção

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static Function F920Lock(oModGrid As Object, nGrid As Numeric) As Logical
Local lRet 		As Logical
Local lTravou 	As Logical
Local cQuery 	As Character
Local cTabQry 	As Character
Local cMsg 		As Character
Local nOpc 		As Numeric
Local nPos		As Numeric
Local cMSFIL	As Character
Local cFilSitef As Character
Local cMVParTef As Character
Local cAdmAtu	As Character
Local aParName	As Array
Local cCodFil	As Character

Default oModGrid 	:= Nil
Default nGrid		:= 1

aParName := IIf(__lTef, A920ParName(), {})
lRet 	 := .T.
lTravou  := .F.
cQuery 	 := ""
cTabQry	 := CriaTrab(Nil, .F.)
cMsg 	 := ""
nOpc 	 := 1
cCodFil  := ""

	If nGrid == 1
		FIF->(DbGoto(oModGrid:GetValue("FIF_RECNO")))
		If !oModGrid:GetValue("OK") // Se estiver selecionado e desmarcando efetua a liberação do lock de seleção
			FIF->(DbRUnlock(FIF->( Recno())))
		Else

			DbSelectArea("FIF")
			cCodFil := oModGrid:GetValue("FIF_CODFIL")
			If __lTef .And. cAdmAtu <> Alltrim(oModGrid:GetValue("FIF_CODADM"))
				cFilSitef := ""
				cMVParTef := ""

				cAdmAtu := Alltrim(oModGrid:GetValue("FIF_CODADM"))
				nPos := aScan(aParName, { |x| x[1] == cAdmAtu })
				If nPos > 0
					cMVParTef := aParName[nPos][2]
				EndIf

				cFilSitef := SuperGetMv(cMVParTef, .F.,, cCodFil)
				cMSFIL := cCodFil
				If Empty(cFilSitef) .And. __lMsgTef
					__lMsgTef:= MsgYesNo(STR0244 + cMVParTef + STR0245 + ': "' + Alltrim(oModGrid:GetValue("FIF_CODFIL")) + '"' + STR0163) // ""Não existe o parâmetro " MV_EMPTEF|MV_EMPTAME|MV_EMPTCIE|MV_EMPTRED para a Empresa/Filial " ## ". O movimento não será conciliado. Continua exibindo alerta?"   
				EndIf
			EndIf

			If __lTef
				cMsg :=  CRLF + " " + STR0006 +": " + DToC(FIF->FIF_DTCRED) + CRLF + " " + STR0033 + ": " + FIF->FIF_NSUTEF + CRLF + " " + STR0029 + ": " + FIF->FIF_PARCEL //" Data Venda: "/" NSU Tef"/ "Parc Tef""
			Else
				cMsg := CRLF + " " + STR0006 +": " + DToC(FIF->FIF_DTCRED) + CRLF + " " + STR0262 + ": " + FIF->FIF_NUCOMP //" Data Venda: "/" ID da Transação" 
			EndIf

			While !lTravou .And. nOpc == 1 
				//Verifica se o item ainda continua aberto para CONCILIAÇÃO, pode ter sido CONCILIADO em outra sessão
				If FIF->(DbRLock(FIF->(Recno())))
					lTravou := .T.
				Else
					nOpc := AVISO(STR0246, STR0247; //"Controle de Concorrência"###"Item em uso por outra sessão e não poderá ser selecionado."
												+ CRLF + STR0248 + CRLF + cMsg, ; //"O que deseja efetuar? "
												{ STR0249, STR0250}, 2)  //"Tentar Novamente?"###"Desconsiderar item"
				EndIf
			EndDo

			If nOpc == 2
				oModGrid:GetModel():SetErrorMessage(oModGrid:cID, 'OK', oModGrid:cID, 'OK', "F918VChk", STR0253) //"Seleção desconsiderada."
			EndIf

			lRet := lTravou

		EndIf
	
	Else

		SE1->(dbSetOrder(1)) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If SE1->(dbSeek(xFilial("SE1", oModGrid:GetValue("E1_FILORIG")) + oModGrid:GetValue("E1_PREFIXO") + oModGrid:GetValue("E1_NUM") + oModGrid:GetValue("E1_PARCELA") + oModGrid:GetValue("E1_TIPO"))) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

			If !oModGrid:GetValue("OK") // Se estiver selecionado e está desmarcando efetua a liberação do lock de seleção
				SE1->(DbRUnlock(SE1->(Recno())))
			Else
				cMsg :=  " " + STR0019 + ": " + SE1->E1_PREFIXO + CRLF + " " + STR0020 + ": " + SE1->E1_NUM + CRLF + " " + STR0022 + ": " + SE1->E1_PARCELA + CRLF + " " + STR0021 + ": " + SE1->E1_TIPO //"Prefixo" / "Titulo" / "Nro Parc" / "Tipo"
				
				While !lTravou .And. nOpc == 1 
					cQuery := " SELECT FIF_STATUS, R_E_C_N_O_ RECNO "
					cQuery += " FROM "+RetSqlName("FIF")
					cQuery += " WHERE FIF_DTTEF   = '" + DToS(SE1->E1_EMISSAO) +"' "
					
					If __lTef
						If __lPrcDocT
							cQuery += " AND FIF_NUCOMP = '" + PADL(ALLTRIM(SE1->E1_DOCTEF), __nTamDOC, "0")  + "' "
						Else							
							cQuery += " AND FIF_NSUTEF  = '" + PADL(ALLTRIM(SE1->E1_NSUTEF), __nTamNSU,"0")  +"' "
						EndIf

						If __lAPixTpd
							cQuery += " AND FIF_MODPAG IN (' ','1')"
						EndIf

						If __lParcFIF
							cQuery += " AND FIF_PARALF = '" + SE1->E1_PARCELA + "' "
						Else
							cQuery += " AND FIF_PARCEL = '" + SE1->E1_PARCELA + "' "
						EndIf

						cQuery += " AND FIF_CODFIL  = '" + SE1->E1_MSFIL +"' "								
					Else						
						cQuery += " AND FIF_NUCOMP = '" + PADL(ALLTRIM(SE1->E1_DOCTEF), __nTamDOC, "0") + "' AND FIF_MODPAG = '2' "
						cQuery += " AND FIF_CODFIL  = '" + SE1->E1_FILORIG +"' " 				
					EndIf
					
					cQuery += "   AND D_E_L_E_T_  = ' ' "
					cQuery := ChangeQuery(cQuery)

					If Select(cTabQry) > 0
						(cTabQry)->(DbCloseArea())
					EndIf

					DbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cTabQry, .F., .T.)
								
					If !(cTabQry)->(Eof()) .And. !Empty((cTabQry)->FIF_STATUS)
						DbSelectArea("FIF")
						FIF->(DbGoTo((cTabQry)->RECNO))

						//Verifica se o item ainda continua aberto para CONCILIAÇÃO, pode ter sido CONCILIADO em outra sessão
						If SE1->(DbRLock(SE1->(Recno())))
							lTravou := .T.
						Else
							nOpc := AVISO(STR0246, STR0247; //"Controle de Concorrência"###"Item em uso por outra sessão e não poderá ser selecionado."
														+ CRLF + STR0248 + CRLF + cMsg, ; //"O que deseja efetuar? "
														{ STR0249, STR0250}, 2)  //"Tentar Novamente?"###"Desconsiderar item"
						EndIf
					Else
						If SE1->(DbRLock(SE1->(Recno())))
							lTravou := .T.
						Else
							nOpc := AVISO(STR0246, STR0247; //"Controle de Concorrência"###"Item em uso por outra sessão e não poderá ser selecionado."
															+ CRLF + STR0248 + CRLF + cMsg, ; //"O que deseja efetuar? "
															{ STR0249, STR0250}, 2)  //"Tentar Novamente?"###"Desconsiderar item"
						EndIf
					EndIf
					(cTabQry)->( dbCloseArea() )
				EndDo

				If nOpc == 2
					oModGrid:GetModel():SetErrorMessage(oModGrid:cID, 'OK', oModGrid:cID, 'OK', "F918VChk", STR0253) //"Seleção desconsiderada."
				EndIf

				lRet := lTravou
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F920Cont
Função executada para contagem de registros nas grids.

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static Function F920Cont(oModel, cModel) As Numeric

Local oMaster As Object
Local oModelM As Object
Local nLinhas As Numeric

Default oModel := Nil
Default cModel := ""

nLinhas := 0

If oModel != Nil
	oMaster	:= oModel:GetModel()
	oModelM	:= oMaster:GetModel(cModel)

	nLinhas := oModelM:GetQtdLine()
EndIf

Return nLinhas

//-------------------------------------------------------------------
/*/{Protheus.doc} F920SelAll
Inclusao de Check para marcar todos

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static Function F920SelAll(oPanel As Object, nSheet As Numeric)
Local oCheck	As Object

Default oPanel := Nil
Default nSheet := 0

	Do Case
	Case nSheet == 1
		@003, 003 CHECKBOX oCheck VAR __lCheck01 Size 060, 020 PROMPT STR0254 ON Change(F920Check(__lCheck01, nSheet)) Of oPanel	//"Marca todos"
	Case nSheet == 2
		@003, 003 CHECKBOX oCheck VAR __lCheck02 Size 060, 020 PROMPT STR0254 ON Change(F920Check(__lCheck02, nSheet)) Of oPanel	//"Marca todos"
	Case nSheet == 3
		@003, 003 CHECKBOX oCheck VAR __lCheck03 Size 060, 020 PROMPT STR0254 ON Change(F920Check(__lCheck03, nSheet)) Of oPanel	//"Marca todos"
	Case __lPixDig .And. nSheet == 7
		@003, 003 CHECKBOX oCheck VAR __lCheck07 Size 060, 020 PROMPT STR0254 ON Change(F920Check(__lCheck07, nSheet)) Of oPanel	//"Marca todos"
	EndCase
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F920Check
Marca ou desmarca todos os Registros da Sheet ativa

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Function F920Check( lCheck As Logical, nSheet As Numeric)
Local nLinBkp	As Numeric
Local nLinFIF	As Numeric
Local nLinSE1	As Numeric
Local nLinFJU	As Numeric
Local oModel	As Object
Local oView		As Object

Default lCheck := .F.
Default nSheet := 0

nLinBkp	:= 0
nLinFIF	:= 0
nLinSE1	:= 0
nLinFJU	:= 0

oView 	:= FwViewActive()
oModel	:= oView:GetModel()

	Do Case
	Case nSheet == 1

		nLinBkp := oModel:GetModel("FIFFLD1"):GetLine()
	
		For nLinFIF := 1 To oModel:GetModel("FIFFLD1"):Length()
			oModel:GetModel("FIFFLD1"):GoLine(nLinFIF)
			
			oModel:SetValue("FIFFLD1", "OK", lCheck)
		Next nLinFIF

		oModel:GetModel("FIFFLD1"):GoLine(nLinBkp)

	Case nSheet == 2

		nLinBkp := oModel:GetModel("FIFFLD2"):GetLine()

		For nLinFIF := 1 To oModel:GetModel("FIFFLD2"):Length()

			oModel:GetModel("FIFFLD2"):GoLine(nLinFIF)
			oModel:SetValue("FIFFLD2", "OK", lCheck)

		Next nLinFIF

		oModel:GetModel("FIFFLD2"):GoLine(nLinBkp)

	Case nSheet == 3

		nLinBkp := oModel:GetModel("FIFFLD3"):GetLine()

		For nLinFIF := 1 To oModel:GetModel("FIFFLD3"):Length()
			oModel:GetModel("FIFFLD3"):GoLine(nLinFIF)
			If !Empty(oModel:GetModel("FIFFLD3"):GetValue("FIF_NSUTEF"))
				oModel:SetValue("FIFFLD3", "OK", lCheck)
			EndIf

		Next nLinFIF

		oModel:GetModel("FIFFLD3"):GoLine(nLinBkp)

	Case __lPixDig .And. nSheet == 7

		nLinBkp := oModel:GetModel("FIFFLD7"):GetLine()
	
		For nLinFIF := 1 To oModel:GetModel("FIFFLD7"):Length()
			oModel:GetModel("FIFFLD7"):GoLine(nLinFIF)			
			oModel:SetValue("FIFFLD7", "OK", lCheck)			
		Next nLinFIF

		oModel:GetModel("FIFFLD7"):GoLine(nLinBkp)

	EndCase

	oView:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F920Canc
Função executada no cancelamento da tela de conciliação

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static Function F920Canc() As Logical
Local lRet := .T.

	// Efetua a liberaação de todos os locks de seleção no cancelamento da tela
	FIF->(DbUnlockAll())
	SE1->(DbUnlockAll())

	If __lPixDig
		FJU->(DbUnlockAll())
	EndIf

Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} BuscarBanco
Busca os dados de banco, agencia e conta (Ponto de entrada), se nao existir, 
matem os parametros que foram passados para a função.                                                                                                          
Atualiza informacoes do SE1                                 

@type function
@author Totvs
@since 07/12/2020

/*/
//---------------------------------------------------------------------------
Static Function BuscarBanco(cBancoFIF As Character, cAgFIF As Character, cContaFIF As Character, nVlLiqFIF As Numeric) As Array
Local aDados	:= {}				//Dados do retorno banco/agencia/conta
Local aArea		:= GetArea()		//Salva area local
Local aAliasSE1	:= SE1->(GetArea()) //Salva area SE1
Local aAliasFIF	:= FIF->(GetArea()) //Salva area FIF
Local nACRESC	:= 0
Local nDECRESC	:= 0

Default cBancoFIF := ""
Default cAgFIF    := ""
Default cContaFIF := ""
Default nVlLiqFIF := 0

If !__lPontoF
	aDados := { cBancoFIF, cAgFIF, cContaFIF }
Else
	aDados := ExecBlock('FINA910F', .F., .F., { cBancoFIF, cAgFIF, cContaFIF })
	
	If !(ValType(aDados) == 'A' .And. Len(aDados) == 3)
		aDados := { cBancoFIF, cAgFIF, cContaFIF }
	EndIf
EndIf

If nVlLiqFIF > SE1->E1_SALDO
	nACRESC := nVlLiqFIF - SE1->E1_SALDO
EndIf

If nVlLiqFIF < SE1->E1_SALDO
	nDECRESC := (nVlLiqFIF - SE1->E1_SALDO) * (-1)
EndIf

RecLock("SE1", .F.)
		
SE1->E1_PORTADO	:= aDados[1]
SE1->E1_AGEDEP	:= aDados[2]
SE1->E1_CONTA	:= aDados[3]
	
If nAcresc <> 0
	SE1->E1_ACRESC	:= nAcresc
	SE1->E1_SDACRES	:= nAcresc
EndIf
	
If nDECRESC <> 0
	SE1->E1_DECRESC	:= nDECRESC
	SE1->E1_SDDECRE	:= nDECRESC
EndIf
	
SE1->(MsUnlock())

//Restaura areas
RestArea(aAliasSE1)
RestArea(aAliasFIF)
RestArea(aArea)

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} f920GetComb
Função para retornar o descritivo do combo

@type function
@author Totvs
@since 07/12/2020
/*/
//-------------------------------------------------------------------
Static Function f920GetComb(cCampo As Character, cConteudo As Character) As Character
Local aCombo 	:= {}
Local cCombo 	:= {}
Local aArea	 	:= GetArea()
Local aAreaSX3 	:= SX3->(GetArea())
Local nX		:= 0
Local cRet      := ""
Local nPos      := 0

Default cCampo    := ""
Default cConteudo := ""

If !Empty(Alltrim(cConteudo))
	If __cVarComb <> cCampo
		__cVarComb := cCampo
		__aVarComb := {}
		SX3->(DbSetOrder(2))
		If SX3->(MsSeek(cCampo))
			cCombo := SX3->(X3CBox())
			aCombo := StrTokArr(cCombo, ';')
			For nx := 1 To Len(aCombo)
				aAdd(__aVarComb, StrTokArr(aCombo[nX],'=')) 
			Next
		EndIf
		RestArea(aAreaSX3)
		RestArea(aArea)
	EndIf
	
	nPos := aScan(__aVarComb, { |x| x[1] == cConteudo })
	
	If nPos > 0
		cRet := __aVarComb[nPos][2]
	EndIf
EndIf

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A920ParName
Função para fazer o vinculo entre o parametro x cod. administradora 
que será utilizado na conciliação SITEF

@type function
@author Totvs
@since 07/12/2020
/*/
//-------------------------------------------------------------------
Static Function A920ParName() As Array
	
	Local cAliasQry	:= GetNextAlias()
	Local aRet		:= {}
	
	BeginSql Alias cAliasQry
		SELECT  MDE.MDE_CODIGO, MDE.MDE_DESC
		
		FROM %Table:MDE% MDE
		
		WHERE MDE.MDE_TIPO = %Exp:'RD'%
			AND	MDE.MDE_ARQIMP <> %Exp:' '% 
			AND MDE.MDE_DESC IN (%Exp:'REDE'%,%Exp:'REDECARD'%,%Exp:'AMEX'%,%Exp:'AMERICAN EXPRESS'%,%Exp:'CIELO'%,%Exp:'SOFTWARE EXPRESS'%,%Exp:'SOFTWAREEXPRESS'%)
			AND MDE.%NotDel%
	EndSql
	
	(cAliasQry)->(DbGoTop())
	If !(cAliasQry)->(Eof())

		While !(cAliasQry)->(Eof())
			If AllTrim((cAliasQry)->MDE_DESC) $ 'AMEX|AMERICAN EXPRESS'
				aAdd(aRet, { (cAliasQry)->MDE_CODIGO, "MV_EMPTAME" })
			
			ElseIf AllTrim((cAliasQry)->MDE_DESC) $ 'CIELO'
				aAdd(aRet, { (cAliasQry)->MDE_CODIGO, "MV_EMPTCIE" })
		
			ElseIf AllTrim((cAliasQry)->MDE_DESC) $ 'REDE|REDECARD'
				aAdd(aRet, { (cAliasQry)->MDE_CODIGO, "MV_EMPTRED" })
			
			ElseIf AllTrim((cAliasQry)->MDE_DESC) $ 'SOFTWAREEXPRESS|SOFTWARE EXPRESS'
				aAdd(aRet, { (cAliasQry)->MDE_CODIGO, "MV_EMPTEF" })
			EndIf

			(cAliasQry)->(DbSkip())
		EndDo

	EndIf
	
	(cAliasQry)->(DbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F920View
Acionamento da View

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Function F920View()

Local cTitulo		As Character		
Local cPrograma		As Character
Local aBtnView		As Array
Local nRet			As Numeric
Local nConc 		As Numeric
Local nNsuIni		As Numeric
Local nNsuFim		As Numeric
Local oModel		As Object
Local bCancel		As Codeblock
Local lContinua     As Logical
Local aArea   		As Array
Local oDlg 			As Object
Local oPanel 		As Object
Local oFont1		As Object
Local oFont2		As Object
Local oSayTop		As Object
Local oBtnSoft		As Object
Local oBtnDemais	As Object
Local oBtnPD		As Object
	
nConc := 4

	//Inicializa o log de processamento
	ProcLogIni({}, "FINA918")

	A920aInVar()

	aArea := GetArea()

	Define MsDialog oDlg TITLE STR0176 From 180, 180 TO 550, 900 Pixel // Conciliação

	oPanel  := TPanel():New(0,0,,oDlg,,,,,,350,350,.F.,.F.)
	oFont1 	:= TFont():New("Arial",, -20, .T., .T.,,,,, )
	oFont2 	:= TFont():New("Arial",, -15, .F., .F.,,,,, )

	oSayTop	:= TSay():New( 20, 50, { || STR0281 }, oPanel,, oFont1 ,,,, .T., CLR_BLUE, ) 

	oBtnSoft 	:= TButton():New( 50, 45, STR0179, oPanel,{ || nConc := 1, __lTef := .T., __lSOFEX := .T., __lPixDig := .F., oDlg:End()  }, 275, 30,, oFont1,.F.,.T.,.F.,,.F.,,,.F. )

	oBtnDemais 	:= TButton():New( 90, 45, STR0178, oPanel,{ || nConc := 2, __lTef := .T., __lSOFEX := .F., __lPixDig := .F., oDlg:End()  }, 275, 30,, oFont1,.F.,.T.,.F.,,.F.,,,.F. ) 
	
	oBtnPD 		:= TButton():New( 130, 45, STR0286, oPanel,{ || nConc := 3, __lTef := .F., __lSOFEX	:= .F., __lPixDig := .T., oDlg:End() }, 275, 30,, oFont1,.F.,.T.,.F.,,.F.,,,.F. ) 

	Activate MsDialog oDlg Centered

	RestArea(aArea)

	If nConc == 3
		If __lAPixTpd .And. cPaisLoc == "BRA"    
			lContinua := Pergunte("FINA918")		// PIX / Carteiras Digitais	
		Else
			//"Ambiente desatualizado para utilizar esse recurso."
			Help(" ", 1, "F918Desatu",, STR0268, 1, 0,,,,,, { STR0269 }) 
		EndIf
	ElseIf lContinua := F920VldAmb() .And. nConc != 4 //Avalia se o ambiente esta apto para prosseguir
		//Atualiza o log de processamento
		ProcLogAtu(STR0137)

		//Exibe o pergunte (SX1) de acordo com a opção selecionada
		If nConc == 1							
			lContinua := Pergunte("FINA910A") 		// Software Express
		ElseIf nConc == 2
			lContinua := Pergunte("FINA910A1")		// Demais operadoras	
		EndIf		
	EndIf	
			
	If lContinua
	
		If __lSOFEX

			__nSelFil 	:= 2 
			__cFilIni	:= MV_PAR01  // 1	Da Filial ?
			__cFilFim	:= MV_PAR02  // 2 	Ate Filial ?      
			__dDtCredI 	:= MV_PAR03  // 3	Data Crédito De ?             
			__dDtCredF 	:= IIf(Empty(MV_PAR04), MV_PAR03, MV_PAR04) //4	Data Credito Até ?           
			__cNsuIni1	:= Alltrim(MV_PAR05)
			__cNsuFim1	:= Alltrim(MV_PAR06)
			nNsuIni		:= Len(__cNsuIni1)
			nNsuFim		:= Len(__cNsuFim1)

			If __lPrcDocT
				__cNsuIni	:= PadR("", __nTamDOC - nNsuIni,IIf(Empty(MV_PAR05),' ','0')) + __cNsuIni1
				__cNsuFim	:= PadR("", __nTamDOC - nNsuFim,'0') + __cNsuFim1
			Else
				__cNsuIni	:= PadR("", __nTamNSU - nNsuIni,IIf(Empty(MV_PAR05),' ','0')) + __cNsuIni1
				__cNsuFim	:= PadR("", __nTamNSU - nNsuFim,'0') + __cNsuFim1
			EndIf              
			
			__nConcilia	:= MV_PAR07  // 7	Geração ?                     
			__nTpPagam 	:= MV_PAR08  // 8	Tipo ?                        
			__nQtdDias	:= MV_PAR09  // 9	Pesq Dias Ant ?               
			
			If Empty(MV_PAR10)
				//Não foi inserido percentual de tolerância para valor de TEF menor que o valor do título
				Help(" ", 1, "A918Margem",, STR0076, 1, 0)
				__nMargem := 0
			Else
				__nMargem := (100 - MV_PAR10) / 100          
			EndIf 
			
			__cAdmIni	:= IIf(Empty(Alltrim(MV_PAR11)), "", Alltrim(MV_PAR11)) // 11	De Financeira ?
			__cAdmFim 	:= IIf(Empty(Alltrim(MV_PAR12)), "", Alltrim(MV_PAR12)) // 12	Ate Financeira ?
			__lFIFDtCr	:= (MV_PAR13 == 2) // "Credito SITEF" // 13	Data Baixa ?                  
			__nNsuCons 	:= MV_PAR14 		 //14	Valida NSU p/ não Conc. ?   
			
			//Processa todas as Abas						
			__nTpProc := IIf(Empty(MV_PAR15), 2, MV_PAR15)
			__nFldPar := IIf(__nTpProc == 1, MV_PAR16, 0)						

		ElseIf __lTef

			__nSelFil	:= MV_PAR01
			__dDtCredI	:= MV_PAR02
			__dDtCredF	:= IIf(Empty(MV_PAR03), MV_PAR02, MV_PAR03)
			__cNsuIni1	:= Alltrim(MV_PAR04)
			__cNsuFim1	:= Alltrim(MV_PAR05)
			nNsuIni		:= Len(__cNsuIni1)
			nNsuFim		:= Len(__cNsuFim1)

			If __lPrcDocT
				__cNsuIni 	:= PadR("", __nTamDOC - nNsuIni,IIf(Empty(MV_PAR04),' ','0')) + __cNsuIni1
				__cNsuFim	:= PadR("", __nTamDOC - nNsuFim,'0') + __cNsuFim1
			Else
				__cNsuIni	:= PadR("", __nTamNSU - nNsuIni,IIf(Empty(MV_PAR04),' ','0')) + __cNsuIni1
				__cNsuFim	:= PadR("", __nTamNSU - nNsuFim,'0') + __cNsuFim1
			EndIf

			__nConcilia := MV_PAR06
			__nTpPagam 	:= MV_PAR07
			__nQtdDias	:= MV_PAR08

			If Empty(MV_PAR09)
				//Não foi inserido percentual de tolerância para valor de TEF menor que o valor do título
				Help(" ", 1, "A918Margem",, STR0076, 1, 0)
				__nMargem := 0
			Else
				__nMargem := (100 - MV_PAR09) / 100  
			EndIf

			__cAdmIni	:= IIf(Empty(Alltrim(MV_PAR10)), "", FormatIn(Alltrim(MV_PAR10), ";"))
			__lFIFDtCr	:= ( MV_PAR11 == 2 ) // "Credito SITEF"	
			__nNsuCons	:= MV_PAR12
			__nTpProc 	:= MV_PAR13
			__nFldPar 	:= IIf(__nTpProc == 1, MV_PAR14, 0)
						
		Else 

			//PIX - Pagamentos Digitais
			__nSelFil	:= MV_PAR01 //Seleciona Filiais ?
			__dDtCredI	:= MV_PAR02 //Data Crédito De ?    
			__dDtCredF	:= IIf(Empty(MV_PAR03), MV_PAR02, MV_PAR03) //Data Crédito Até ?
			__cNsuIni   := IIf(Empty(MV_PAR04),' ', Alltrim(MV_PAR04))
			__cNsuFim   := IIf(Empty(MV_PAR05),'Z', Alltrim(MV_PAR05))
			__nConcilia	:= MV_PAR06 //Geração ?
			__nTpPagam	:= MV_PAR07 //Tipo ? 1=PIX / 2=Carteira Digital / 3=Ambos
			__nQtdDias	:= MV_PAR08 //Pesq Dias Ant ?

			If Empty(MV_PAR09)
				//Não foi inserido percentual de tolerância para valor de TEF menor que o valor do título
				Help(" ", 1, "A918Margem",, STR0076, 1, 0)
				__nMargem := 0
			Else
				__nMargem := (100 - MV_PAR09) / 100  
			EndIf
			
			__lFIFDtCr	:= MV_PAR10 == 2 // Data Baixa ? 1=Database / 2= FIF_DTCRED           
			__nNsuCons	:= MV_PAR11 //Valida ID p/ não Conc. ?  
			__nTpProc	:= MV_PAR12 //Aba para Processamento ?  
			__nFldPar   := IIf(__nTpProc == 1, MV_PAR13, 0)
					
		EndIf

		cTitulo		:= STR0261
		cPrograma	:= "FINA920A"
		aBtnView    := {{.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.T., NIL}, {.F., NIL}, {.T., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}}
		nRet        := 0
		oModel      := NIL
		bCancel		:= {|| F920Canc() }
				
		If __nSelFil == 1
			//Gestão - Selecao das Filiais deve ser geral pois controle é feito através do MSFIL. 
			__aSelFil := AdmGetFil(.F., .T.,)
		EndIf
		
		If __nSelFil == 2 .Or. Len(__aSelFil) > 0 

			While nRet == 0
				oModel	:= FWLoadModel("FINA920A")
                               
				nRet	:= FWExecView(cTitulo, cPrograma, MODEL_OPERATION_UPDATE, /*oDlg*/, /*bCloseOnOk*/, /*bOk*/, /*nPercReducao*/, aBtnView, bCancel, /*cOperatId*/, /*cToolBar*/, oModel)
                
				oModel:Destroy()
			EndDo

		EndIf

	EndIf

	A920DelTmp()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F920Grv
Gravacao dos Dados Selecionados para Conciliacao

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Function F920Grv(nSheet As Numeric)
Local oModel	As Object
Local oView		As Object
Local oSubFIF	As Object
Local oSubSE1	As Object
Local cLog		As Character
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
Local lGestao   As Logical
Local aColsAux  As Array
Local aConc		As Array
Local aLotes	As Array
Local lRegMark	As Logical

Local lMenorSitef As Logical

Default nSheet := 0

lGestao   	:= FWSizeFilial() > 2
aColsAux  	:= {}
aConc		:= {}
aLotes		:= {}
lMenorSitef := .F.
cLog		:= ""
nLinFIF		:= 0
nLinSE1		:= 0
nCount		:= 0
lRegSE1		:= .F.
lRetorno	:= .F.
cQuery 		:= ""
cSeqFIF 	:= ""
cFilOrig 	:= ""
cParcSE1 	:= ""
cFIFAlias 	:= ""
lRegMark 	:= .F.

cFilBkp := cFilAnt
	
	oView		:= FwViewActive()
	oModel 		:= oView:GetModel()

	// Estornos (Somente PIX)
	If __lPixDig .And. nSheet == 7

		oSubFIF := oModel:GetModel("FIFFLD7")
		oSubFJU := oModel:GetModel("FJUFLD7")

		DbSelectArea("FJU")

		// FJU_FILIAL + FJU_CART + STR(FJU_RECORI) + STR(FJU_RECPAI) 
		FJU->(DbSetOrder(1))

		For nLinFIF := 1 To oSubFIF:Length()
			oSubFIF:GoLine(nLinFIF)

			If !oSubFIF:GetValue("OK")
				Loop
			EndIf

			If cFilAnt <> oSubFIF:GetValue("FIF_CODFIL")
				cFilAnt := oSubFIF:GetValue("FIF_CODFIL")
			EndIf	

			If FJU->(DbSeek(xFilial("FJU") + oSubFJU:GetValue("FJU_CART") + Str(oSubFJU:GetValue("FJU_RECORI"), __nTRecOri) + Str(oSubFJU:GetValue("FJU_RECPAI"), __nTRecPai)))	

				lRegMark := .T.

				DbSelectArea("FIF")
				DbSetOrder(2)
				If FIF->(DbSeek(xFilial("FIF") + DTOS(oSubFJU:GetValue("FJU_EMIS")) + oSubFJU:GetValue("FJU_DOCTEF")))
					RecLock("FIF", .F.)
						FIF->FIF_STATUS		:= "2"
						FIF->FIF_PREFIX		:= oSubFJU:GetValue("FJU_PREFIX")
						FIF->FIF_NUM		:= oSubFJU:GetValue("FJU_NUM")
						FIF->FIF_PARC		:= oSubFJU:GetValue("FJU_PARCEL")
						FIF->FIF_TIPO		:= oSubFJU:GetValue("FJU_TIPO")
						FIF->FIF_DTPAG		:= oSubFJU:GetValue("FJU_DTEXCL")
						FIF->FIF_USUPAG		:= RetCodUsr()
					FIF->(MsUnlock())
				EndIf

				FWAlertSuccess(STR0287) 

			EndIf			

		Next nLinFIF

		oModel:DeActivate()
		oModel:Activate()
		oView:Refresh('GRD01FIF07')
		oView:Refresh('GRD01FJU07')
		oView:Refresh('GRD01TOT06')	

	Else

		ProcLogAtu(STR0138,STR0054)

		Do Case
		Case nSheet == 1 .Or. nSheet == 2	
		//Conciliacao dos Folders Conciliadas e Conc. Parcialmente, tendo como funcionalidade baixar os titulos
		//do Contas a Receber e alterar o status do mesmo na tabela FIF 
			ProcLogAtu(STR0138,STR0144)
			If nSheet == 1
				oSubFIF := oModel:GetModel("FIFFLD1")
				oSubSE1 := oModel:GetModel("SE1FLD1")
			Else
				oSubFIF := oModel:GetModel("FIFFLD2")
				oSubSE1 := oModel:GetModel("SE1FLD2")
			EndIf 	
			
			DbSelectArea("SE1")
			SE1->(DbSetOrder(1))

			For nLinFIF := 1 To oSubFIF:Length()

				oSubFIF:GoLine(nLinFIF)

				If !oSubFIF:GetValue("OK")
					Loop
				EndIf

				If cFilAnt <> oSubFIF:GetValue("FIF_CODFIL")
					cFilAnt := oSubFIF:GetValue("FIF_CODFIL")
				EndIf		

				If !SE1->(DbSeek(xFilial("SE1") + oSubSE1:GetValue("E1_PREFIXO") + oSubSE1:GetValue("E1_NUM") + oSubSE1:GetValue("E1_PARCELA") + oSubSE1:GetValue("E1_TIPO")))
					
					Help(" ",1,"A918NoSelec",,STR0050 ,1,0,,,,,,{STR0222}) //"Título não encontrado no Financeiro" //"Selecione um título valido no Financeiro"
						
				Else
					lRegMark := .T.

					//Tratamento Valor Sitef deve ser maior ou igual ao Valor no Financeiro
					If !(If(__lLJGERTX .And. !__lPixDig, oSubFIF:GetValue("FIF_VLBRUT"), oSubFIF:GetValue("FIF_VLLIQ")) >= SE1->E1_SALDO * __nMargem) .And. nSheet == 1
						lMenorSitef := .T.
						Loop
					Else
						FIF->(DbGoTo(oSubFIF:GetValue("FIF_RECNO"))) 
						//Lote - prepara os dados para baixa dos titulos em lote
						//Baixa Individual - prepara e ja executa a baixa do titulo.
						lRetorno := .F.
			
						aDadoBanco := BuscarBanco(PadR(oSubFIF:GetValue("FIF_CODBCO"), __nTamBco), PadR(oSubFIF:GetValue("FIF_CODAGE"), __nTamAge), PadR(oSubFIF:GetValue("FIF_NUMCC"), __nTamCC), oSubFIF:GetValue("FIF_VLLIQ"))
						
						If !A920VLDBCO(aDadoBanco[1],aDadoBanco[2],aDadoBanco[3],cFilAnt)
							Exit
						EndIf

						If __nConcilia == 2		
						
							//Verifica se ja existe um lote para este Banco, Agencia, Conta e Data do Credito
							If Len(aLotes) > 0 .And. (nLote := AScan (aLotes, { |aX| aX[2] + aX[3] + aX[4] + DToS(aX[8]) == PadR(oSubFIF:GetValue("FIF_CODBCO"), __nTamBco) + PadR(oSubFIF:GetValue("FIF_CODAGE"), __nTamAge) + PadR(oSubFIF:GetValue("FIF_NUMCC"), __nTamCC) + DToS(IIf(__lFIFDtCr, oSubFIF:GetValue("FIF_DTCRED"),dDataBase)) })) > 0
							//Adiciona ao lote o recno de mais um titulo SE1
								AADD(aLotes[nLote ][9], SE1->(Recno()))
							Else

								cLote := BuscarLote()
						
								//Cria um lote com o titulo SE1
								AADD(aLotes, {cLote,;
												PadR(oSubFIF:GetValue("FIF_CODBCO"), __nTamBco),;
												PadR(oSubFIF:GetValue("FIF_CODAGE"), __nTamAge),;
												PadR(oSubFIF:GetValue("FIF_NUMCC"),  __nTamCC),;
												aDadoBanco[1],;
												aDadoBanco[2],;
												aDadoBanco[3],;
												IIf(__lFIFDtCr, oSubFIF:GetValue("FIF_DTCRED"), dDataBase), { SE1->(Recno()) };
									})

							EndIf

							aColsAux  	:= {}				
							aAdd(aColsAux, IIf(FIF->FIF_STATUS == "6", "7", "2"))					//1-Status oNSelec
							aAdd(aColsAux, FIF->FIF_CODEST)		//2-Codigo do Estabelecimento Sitef
							aAdd(aColsAux, FIF->FIF_CODLOJ)		//3-Codigo da Loja Sitef
							aAdd(aColsAux, SE1->E1_CLIENTE)		//4-Codigo do Cliente (Administradora)
							aAdd(aColsAux, SE1->E1_PREFIXO)		//5-Prefixo do titulo Protheus
							aAdd(aColsAux, SE1->E1_NUM)			//6-Numero do titulo Protheus
							aAdd(aColsAux, SE1->E1_TIPO)		//7-Tipo do titulo Protheus
							aAdd(aColsAux, SE1->E1_PARCELA)		//8-Numero da parcela Protheus
							aAdd(aColsAux, FIF->FIF_NUCOMP)		//9-Numero do Comprovante Sitef
							aAdd(aColsAux, FIF->FIF_DTTEF)		//10-Data da Venda Sitef
							aAdd(aColsAux, FIF->FIF_DTCRED)		//11-Data de Credito Sitef
							aAdd(aColsAux, SE1->E1_SALDO)		//12-Valor do titulo Protheus
							If __lLJGERTX .And. !__lPixDig
								aAdd(aColsAux, FIF->FIF_VLBRUT)	//13-Valor Bruto Sitef
							Else
								aAdd(aColsAux, FIF->FIF_VLLIQ)	//13-Valor liquido Sitef
							EndIf
							aAdd(aColsAux, FIF->FIF_NSUTEF)		//14-Numero NSU Sitef
							aAdd(aColsAux, FIF->FIF_PARCEL)		//15-Numero da parcela Sitef
							aAdd(aColsAux, SE1->E1_DOCTEF)		//16-Documento TEF Protheus
							aAdd(aColsAux, SE1->E1_NSUTEF)		//17-NSU Sitef Protheus
							aAdd(aColsAux, SE1->E1_VENCREA)		//18-Vencimento real do titulo
				
							If !__lPontoF
								aAdd(aColsAux, FIF->FIF_CODBCO + ' / ' + FIF->FIF_CODAGE + ' / ' + FIF->FIF_NUMCC)//19-banco/agencia/conta
								cCodBco := PadR(FIF->FIF_CODBCO, __nTamBco)
								cCodAge := PadR(FIF->FIF_CODAGE, __nTamAge)
								cNumCC  := PadR(FIF->FIF_NUMCC,	 __nTamCC)
							Else
								aAdd(aColsAux,aDadoBanco[1] +' / '+aDadoBanco[2]+' / '+aDadoBanco[3])//19-banco/agencia/conta
								cCodBco := aDadoBanco[1]
								cCodAge := aDadoBanco[2]
								cNumCC  := aDadoBanco[3]
							EndIF
				
							aAdd(aColsAux, "OK")       			//20-Informação de conta não cadastrada ou cadastrada
							aAdd(aColsAux, FIF->FIF_CAPTUR)		//21 - (0,2 ou 3 - Transação Sitef),(1 ou 4 - Outros/POS)
							aAdd(aColsAux, SE1->(recno()))		//22 - RECNO do SE1
							aAdd(aColsAux, FIF->(recno()))		//23 - RECNO do FIF
								
							If !__lPontoF
								aAdd(aColsAux, PadR(FIF->FIF_CODAGE, __nTamAge)) 	//24 - Agencia
								aAdd(aColsAux, PadR(FIF->FIF_NUMCC,	 __nTamCC))     //25 - Conta
								aAdd(aColsAux, PadR(FIF->FIF_CODBCO, __nTamBco))   	//26 - Banco
							Else
								aAdd(aColsAux, aDadoBanco[2] )	//24 - Agencia
								aAdd(aColsAux, aDadoBanco[3] )	//25 - Conta
								aAdd(aColsAux, aDadoBanco[1] )	//26 - Banco
							EndIf
				
							aAdd(aColsAux, SE1->E1_LOJA)		//27 - Codigo da Loja
							aAdd(aColsAux, FIF->FIF_CODFIL)		//28 - FILIAL    
							aAdd(aColsAux, FIF->FIF_PGJUST)		//29 - Codigo de Justificativa
							aAdd(aColsAux, FIF->FIF_PGDES1)		//30 - Descrição de Justificativa
							aAdd(aColsAux, FIF->FIF_PGDES2)		//31 - Justificativa
							aAdd(aColsAux, FIF->FIF_CODADM)		//32 - Codigo da Administradora
							aAdd(aColsAux, FIF->FIF_CODMAJ)		//33 - Codigo do Motivo
							aAdd(aColsAux, FIF->FIF_NSUARQ)		//34-  Numero NSU Sitef com formatação do arquivo
							aAdd(aColsAux, FIF->FIF_CODAUT)		//35-  Autorização
							aAdd(aColsAux, FIF->FIF_TPREG)		//36-  Tp Registro
							aAdd(aColsAux, FIF->FIF_NURESU)		//37-  Nr Resumo
							aAdd(aColsAux, FIF->FIF_TPPROD)		//38-  Tipo Produto
							aAdd(aColsAux, FIF->FIF_VLCOM)		//39-  Vlr Comissão
							aAdd(aColsAux, FIF->FIF_TXSERV)		//40-  Taxa Serv
							aAdd(aColsAux, FIF->FIF_PARALF)		//41-  Parc.Alfanum
							aAdd(aColsAux, f920GetComb('FIF_STVEND',FIF->FIF_STVEND))		    //42-  Status Venda
							aAdd(aColsAux, FIF->FIF_CODBAN)		//43-  Código Banco
							aAdd(aColsAux, FIF->FIF_SEQFIF)		//44-  Seq. Tab FIF
							aAdd(aColsAux, FIF->FIF_VLBRUT)		//45-  Vlr Venda
							aAdd(aColsAux, FIF->FIF_VLLIQ)		//46-  Vlr Liquido
							aAdd(aColsAux, FIF->FIF_FILIAL)		//47-  Filial
							aAdd(aColsAux, FIF->FIF_PARC)		//48-  Rastro Parcela SE1
								
							aAdd(aConc, aColsAux)
							lRetorno := .T.
						Else
						
							//Array com os dados do titulo para baixa individual
							aTitInd	:=	{;	
											{"E1_PREFIXO"		,oSubSE1:GetValue("E1_PREFIXO")	 							,NiL},;
											{"E1_NUM"			,oSubSE1:GetValue("E1_NUM")			 						,NiL},;
											{"E1_PARCELA"		,oSubSE1:GetValue("E1_PARCELA")    							,NiL},;
											{"E1_TIPO"			,oSubSE1:GetValue("E1_TIPO")   	 							,NiL},;
											{"E1_CLIENTE"		,oSubSE1:GetValue("E1_CLIENTE")  							,NiL},;
											{"E1_LOJA"			,oSubSE1:GetValue("E1_LOJA")      	 						,NiL},;
											{"AUTMOTBX"			,"NOR"					     			 					,Nil},;
											{"AUTBANCO"			,(PadR(aDadoBanco[1],Len(SE8->E8_BANCO)))   				,Nil},;
											{"AUTAGENCIA"		,(PadR(aDadoBanco[2],Len(SE8->E8_AGENCIA)))					,Nil},;
											{"AUTCONTA"			,IIf(__lPontoF,(PadR(aDadoBanco[3],Len(SE8->E8_CONTA))),(PadR(StrTran(aDadoBanco[3],"-",""),Len(SE8->E8_CONTA)))),Nil},;
											{"AUTDTBAIXA"		,IIf(__lFIFDtCr, oSubFIF:GetValue("FIF_DTCRED"), dDataBase)	,Nil},;
											{"AUTDTCREDITO"		,IIf(__lFIFDtCr, oSubFIF:GetValue("FIF_DTCRED"), dDataBase)	,Nil},;
											{"AUTHIST"			,STR0110         			 								,Nil},; //"Conciliador SITEF"
											{"AUTDESCONT"		,0					    	 			 					,Nil},; //Valores de desconto
											{"AUTACRESC"		,0					 	    			 					,Nil},; //Valores de acrescimo - deve estar cadastrado no titulo previamente
											{"AUTDECRESC"		,0					 		 			 					,Nil},; //Valore de decrescimo - deve estar cadastrado no titulo previamente
											{"AUTMULTA"			,0					 		 			 					,Nil},; //Valores de multa
											{"AUTJUROS"			,0					 				 	 					,Nil},; //Valores de Juros
											{"AUTVALREC"		,IIf(__lLJGERTX .And. !__lPixDig, oSubFIF:GetValue("FIF_VLBRUT"), oSubFIF:GetValue("FIF_VLLIQ")),Nil};
										}  //Valor recebido
							
							//Efetua baixa individual
							A920EfetuaBX(aTitInd, , @lRetorno)

							If lRetorno
								lRetorno := AtuModelFIF(oSubFIF, oSubSE1, "2")	
							EndIf

							If !lRetorno //Erro na Baixa do Título
								Help(NIL, NIL, "F918GvConc", NIL, STR0118 + Str(oSubFIF:GetValue("FIF_RECNO"),10), 1, 0) //"Erro ao atualizar a tabela FIF. Registro: "
								DisarmTransaction()
								Exit
							EndIf

							nCount++	
							cFilAnt := cFilBkp
						
						EndIf						
					EndIf				
				EndIf
			Next nLinFIF

			If lMenorSitef
				Conout(IIf(__lTef, STR0052, STR0270))	//"Valor menor que o Valor Protheus, necessário corrigir no Financeiro"
			EndIf		
		Case nSheet == 4	// Não Conciliados
			//Conciliacao dos Folders Não Conciliadas, tendo como funcionalidade baixar os titulos do Contas a  
			//Receber e alterar o status do mesmo na tabela FIF 
			ProcLogAtu(STR0138,STR0145)

			oSubFIF := oModel:GetModel("FIFFLD4")
			oSubSE1 := oModel:GetModel("SE1FLD4")
			
			DbSelectArea("SE1")
			SE1->(DbSetOrder(1))
	
			For nLinFIF := 1 To oSubFIF:Length()
				oSubFIF:GoLine(nLinFIF)

				If !oSubFIF:GetValue("OK")
					Loop
				EndIf

				lRegMark := .T.
		
				If cFilAnt<>oSubFIF:GetValue("FIF_CODFIL")
					cFilAnt := oSubFIF:GetValue("FIF_CODFIL")
				EndIf

				If !SE1->(DbSeek(xFilial("SE1",oSubSE1:GetValue("E1_FILORIG"))+oSubSE1:GetValue("E1_PREFIXO")+oSubSE1:GetValue("E1_NUM")+oSubSE1:GetValue("E1_PARCELA")+oSubSE1:GetValue("E1_TIPO")))
					Help(" ",1,"A918NoSelec",,STR0050 ,1,0,,,,,,{STR0222}) // "Arquivo não encontrado no Financeiro"
				Else
					lRetorno := .F.
					
					FIF->(DBGoto(oSubFIF:GetValue("FIF_RECNO")))

					If __lPrcDocT .Or. __lPixDig
						If Alltrim(oSubFIF:GetValue("FIF_NUCOMP")) <> PadL(Alltrim(oSubSE1:GetValue("E1_DOCTEF")), __nTamDOC, '0') .And. __nNsuCons == 1
							lRetorno := .F.
							Help(NIL, NIL, "F918GvDoc", NIL, STR0259, 1, 0)		//"Comprovante e Num. NSU selecionados estão divergentes"
							Exit
						EndIf
					ElseIf Alltrim(oSubFIF:GetValue("FIF_NSUTEF")) <> PadL(Alltrim(oSubSE1:GetValue("E1_NSUTEF")), __nTamNSU, '0') .And. __nNsuCons == 1
						lRetorno := .F.
						Help(NIL, NIL, "F918GvNSUDiv", NIL, STR0116, 1, 0)		//"NSU e Nº Comprovante selecionados estão divergentes"
						Exit
					EndIf
					
					If oSubFIF:GetValue("FIF_CODFIL") <> oSubSE1:GetValue("E1_FILORIG")
						lRetorno := .F.
						Help(NIL, NIL, "F918GvFil", NIL, STR0258, 1, 0)		//"Filiais selecionados estão divergentes"
						Exit
					EndIf

					aDadoBanco := BuscarBanco(PadR(oSubFIF:GetValue("FIF_CODBCO"), __nTamBco), PadR(oSubFIF:GetValue("FIF_CODAGE"), __nTamAge), PadR(oSubFIF:GetValue("FIF_NUMCC"), __nTamCC), oSubFIF:GetValue("FIF_VLLIQ"))
					
					If !A920VLDBCO(aDadoBanco[1],aDadoBanco[2],aDadoBanco[3],cFilAnt)
						Exit
					EndIf

					lRegMark := .T.

					If __nConcilia == 2
					
						cLote := BuscarLote()
					
						//Cria um lote com o titulo SE1
						AADD(aLotes, {cLote,;
								PadR(oSubFIF:GetValue("FIF_CODBCO"), __nTamBco),;
								PadR(oSubFIF:GetValue("FIF_CODAGE"), __nTamAge),;
								PadR(oSubFIF:GetValue("FIF_NUMCC"),  __nTamCC),;
								aDadoBanco[1],;
								aDadoBanco[2],;
								aDadoBanco[3],;
								IIf(__lFIFDtCr, oSubFIF:GetValue("FIF_DTCRED"), dDataBase), { SE1->(Recno()) };
							})													
						
						aColsAux := {}			
						aAdd(aColsAux, IIf(FIF->FIF_STATUS == "6","8","4"))					//1-Status oNSelec
						aAdd(aColsAux, FIF->FIF_CODEST)		//2-Codigo do Estabelecimento Sitef
						aAdd(aColsAux, FIF->FIF_CODLOJ)		//3-Codigo da Loja Sitef
						aAdd(aColsAux, SE1->E1_CLIENTE)		//4-Codigo do Cliente (Administradora)
						aAdd(aColsAux, SE1->E1_PREFIXO)		//5-Prefixo do titulo Protheus
						aAdd(aColsAux, SE1->E1_NUM)			//6-Numero do titulo Protheus
						aAdd(aColsAux, SE1->E1_TIPO)		//7-Tipo do titulo Protheus
						aAdd(aColsAux, SE1->E1_PARCELA)		//8-Numero da parcela Protheus
						aAdd(aColsAux, FIF->FIF_NUCOMP)		//9-Numero do Comprovante Sitef
						aAdd(aColsAux, FIF->FIF_DTTEF)		//10-Data da Venda Sitef
						aAdd(aColsAux, FIF->FIF_DTCRED)		//11-Data de Credito Sitef
						aAdd(aColsAux, SE1->E1_SALDO)		//12-Valor do titulo Protheus
						If __lLJGERTX .And. !__lPixDig 
							aAdd(aColsAux, FIF->FIF_VLBRUT)	//13-Valor Bruto Sitef
						Else
							aAdd(aColsAux, FIF->FIF_VLLIQ)	//13-Valor liquido Sitef
						EndIf
						aAdd(aColsAux, FIF->FIF_NSUTEF)		//14-Numero NSU Sitef
						aAdd(aColsAux, FIF->FIF_PARCEL)		//15-Numero da parcela Sitef
						aAdd(aColsAux, SE1->E1_DOCTEF)		//16-Documento TEF Protheus
						aAdd(aColsAux, SE1->E1_NSUTEF)		//17-NSU Sitef Protheus
						aAdd(aColsAux, SE1->E1_VENCREA)		//18-Vencimento real do titulo
						If !__lPontoF
							aAdd(aColsAux,FIF->FIF_CODBCO +' / '+FIF->FIF_CODAGE+' / '+FIF->FIF_NUMCC)//19-banco/agencia/conta
							cCodBco := PadR(FIF->FIF_CODBCO, __nTamBco) 
							cCodAge := PadR(FIF->FIF_CODAGE, __nTamAge)
							cNumCC  := PadR(FIF->FIF_NUMCC,  __nTamCC)
						Else
							aAdd(aColsAux,aDadoBanco[1] +' / '+aDadoBanco[2]+' / '+aDadoBanco[3])//19-banco/agencia/conta
							cCodBco := aDadoBanco[1]
							cCodAge := aDadoBanco[2]
							cNumCC  := aDadoBanco[3]
						EndIF
				
						aAdd(aColsAux, "OK")       			//20-Informação de conta não cadastrada ou cadastrada
						aAdd(aColsAux, FIF->FIF_CAPTUR)		//21 - (0,2 ou 3 - Transação Sitef),(1 ou 4 - Outros/POS)
						aAdd(aColsAux, SE1->(recno()))		//22 - RECNO do SE1
						aAdd(aColsAux, FIF->(recno()))		//23 - RECNO do FIF
							
						If !__lPontoF
							aAdd(aColsAux, PadR(FIF->FIF_CODAGE, __nTamAge))     //24 - Agencia
							aAdd(aColsAux, PadR(FIF->FIF_NUMCC,  __nTamCC))      //25 - Conta
							aAdd(aColsAux, PadR(FIF->FIF_CODBCO, __nTamBco))     //26 - Banco
						Else
							aAdd(aColsAux, aDadoBanco[2] )	//24 - Agencia
							aAdd(aColsAux, aDadoBanco[3] )	//25 - Conta
							aAdd(aColsAux, aDadoBanco[1] )	//26 - Banco
						EndIf
				
						aAdd(aColsAux, SE1->E1_LOJA)           	//27 - Codigo da Loja
						aAdd(aColsAux, FIF->FIF_CODFIL)			//28 - Filial    
						aAdd(aColsAux, FIF->FIF_PGJUST)        	//29 - Codigo de Justificativa
						aAdd(aColsAux, FIF->FIF_PGDES1)        	//30 - Descrição de Justificativa
						aAdd(aColsAux, FIF->FIF_PGDES2)        	//31 - Justificativa
						aAdd(aColsAux, FIF->FIF_CODADM)        	//32 - Codigo da Administradora
						aAdd(aColsAux, FIF->FIF_CODMAJ)        	//33 - Codigo do Motivo
						aAdd(aColsAux, FIF->FIF_NSUARQ)		    //34-  Numero NSU Sitef com formatação do arquivo
						aAdd(aColsAux, FIF->FIF_CODAUT)		    //35-  Autorização
						aAdd(aColsAux, FIF->FIF_TPREG)			//36-  Tp Registro
						aAdd(aColsAux, FIF->FIF_NURESU)		    //37-  Nr Resumo
						aAdd(aColsAux, FIF->FIF_TPPROD)		    //38-  Tipo Produto
						aAdd(aColsAux, FIF->FIF_VLCOM)			//39-  Vlr Comissão
						aAdd(aColsAux, FIF->FIF_TXSERV)		    //40-  Taxa Serv
						aAdd(aColsAux, FIF->FIF_PARALF)		    //41-  Parc.Alfanum
						aAdd(aColsAux, f920GetComb('FIF_STVEND',FIF->FIF_STVEND))		    //42-  Status Venda
						aAdd(aColsAux, FIF->FIF_CODBAN)		    //43-  Código Banco
						aAdd(aColsAux, FIF->FIF_SEQFIF)		    //44-  Seq. Tab FIF
						aAdd(aColsAux, FIF->FIF_VLBRUT)		    //45-  Vlr Venda
						aAdd(aColsAux, FIF->FIF_VLLIQ)			//46-  Vlr Liquido
						aAdd(aColsAux, FIF->FIF_FILIAL)		    //47-  Filial
						aAdd(aColsAux, FIF->FIF_PARC)			//48-  Rastro Parcela SE1
							
						aadd(aConc, aColsAux)

						lRetorno := .T.	
					Else
						//Array com os dados do titulo para baixa individual
						aTitInd	:=	{;
										{"E1_PREFIXO"		,oSubSE1:GetValue("E1_PREFIXO")	 							,NiL},;
										{"E1_NUM"			,oSubSE1:GetValue("E1_NUM")			 						,NiL},;
										{"E1_PARCELA"		,oSubSE1:GetValue("E1_PARCELA")    							,NiL},;
										{"E1_TIPO"			,oSubSE1:GetValue("E1_TIPO")   	 							,NiL},;
										{"E1_CLIENTE"		,oSubSE1:GetValue("E1_CLIENTE")  							,NiL},;
										{"E1_LOJA"			,oSubSE1:GetValue("E1_LOJA")      	 						,NiL},;
										{"AUTMOTBX"			,"NOR"					     			 					,Nil},;
										{"AUTBANCO"			,(PadR(aDadoBanco[1],Len(SE8->E8_BANCO)))   				,Nil},;
										{"AUTAGENCIA"		,(PadR(aDadoBanco[2],Len(SE8->E8_AGENCIA)))					,Nil},;
										{"AUTCONTA"			,IIf(__lPontoF, (PadR(aDadoBanco[3], Len(SE8->E8_CONTA))), (PadR(StrTran(aDadoBanco[3], "-", ""), Len(SE8->E8_CONTA)))) ,Nil},;
										{"AUTDTBAIXA"		,IIf(__lFIFDtCr, oSubFIF:GetValue("FIF_DTCRED"), dDataBase)	,Nil},;
										{"AUTDTCREDITO"		,IIf(__lFIFDtCr, oSubFIF:GetValue("FIF_DTCRED"), dDataBase)	,Nil},;
										{"AUTHIST"			,STR0230           			 								,Nil},; //"Conciliador SITEF"
										{"AUTDESCONT"		,0					    	 			 					,Nil},; //Valores de desconto
										{"AUTACRESC"		,0					 	    			 					,Nil},; //Valores de acrescimo - deve estar cadastrado no titulo previamente
										{"AUTDECRESC"		,0					 		 			 					,Nil},; //Valores de decrescimo - deve estar cadastrado no titulo previamente
										{"AUTMULTA"			,0					 		 			 					,Nil},; //Valores de multa
										{"AUTJUROS"			,0					 				 	 					,Nil},; //Valores de Juros
										{"AUTVALREC"		,If(__lLJGERTX .And. !__lPixDig, oSubFIF:GetValue("FIF_VLBRUT"), oSubFIF:GetValue("FIF_VLLIQ")), Nil};
									}  //Valor recebido
									
						//Efetua baixa individual
						A920EfetuaBX(aTitInd, , @lRetorno)

						If lRetorno
							lRetorno := AtuModelFIF(oSubFIF, oSubSE1, "4")	
						EndIf	

						If !lRetorno //Erro na Baixa do Título
							Help(NIL, NIL, "F918GvConcMan", NIL, STR0118 + Str(oSubFIF:GetValue("FIF_RECNO"),10), 1, 0) //"Erro ao atualizar a tabela FIF. Registro: "
							DisarmTransaction()
							Exit
						EndIf	

						nCount++
						cFilAnt := cFilBkp
						
					EndIf
				EndIf										
			Next nLinFIF

		Case nSheet == 5	//Divergentes
			ProcLogAtu(STR0138, STR0054)

			lRetorno := .T.
			// Valida se campos de justificativa estão preenchidos
			oSubFIF := oModel:GetModel("FIFFLD5")

			For nLinFIF := 1 To oSubFIF:Length()
				oSubFIF:GoLine(nLinFIF)

				If !oSubFIF:GetValue("OK")
					Loop
				EndIf

				lRegMark := .T.
				
				If Empty(oSubFIF:GetValue("FIF_PGJUST"))
					lRetorno := .F.
					cLog :=  CRLF + STR0025 + " - " + DtoC(oSubFIF:GetValue("FIF_DTCRED")) + CRLF + STR0028 + " - " + oSubFIF:GetValue("FIF_NSUTEF")  + CRLF + STR0029 + " - " + oSubFIF:GetValue("FIF_PARCEL") //"DT Credito"###"NSU"###"Parc Tef"
					lRetorno := .F.
					Help(NIL, NIL, "F918aJust", NIL, STR0190 + CRLF + cLog, 1, 0) //"Informe a Justificativa para a Conciliação."					
					Exit
				EndIf
				
			Next nLinFIF

			If lRetorno

				For nLinFIF := 1 To oSubFIF:Length()
					oSubFIF:GoLine(nLinFIF)

					If oSubFIF:GetValue("OK")
						lRetorno := AtuModelFIF(oSubFIF, , "3")

						If !lRetorno
							Help(NIL, NIL, "F918GvDiverg", NIL, STR0118 + Str(oSubFIF:GetValue("FIF_RECNO"),10), 1, 0) // "Erro ao atualizar a tabela FIF. Registro: "
							DisarmTransaction()
							Exit							
						EndIf
						nCount++
						cFilAnt := cFilBkp
					EndIf	
				Next nLinFIF
			EndIf
		EndCase

		If !lRegMark
			Help(" ", 1, "A918NoReg",, STR0115, 1, 0,,,,,,{ STR0291 })
			Return Nil
		EndIf

		//Efetua a baixa por lote
		If __nConcilia == 2 .And. lRetorno
			Processa({ || A920EfetuaBX(aLotes, aConc, @lRetorno) }, STR0106, STR0107) //"Aguarde..."#"Efetuando Baixa de Títulos Lote..."

			If !lRetorno
				ProcLogAtu(STR0149,STR0157)
			Else					
				Processa({ || F920AtuFIF(aConc, @lRetorno) }, STR0092, STR0108) //"Aguarde..."#"Atualizando Tabela FIF..."
				
				If lRetorno
					nCount++
				EndIf
			EndIf
			
			ProcLogAtu(STR0138, STR0151)

			//"Baixa efetuada com sucesso!!!"      //"Houve titulos não conciliados. Favor verificar"
			IIf(lRetorno, MsgInfo(STR0109, ProcName()), MsgInfo(STR0191, ProcName())) 

		EndIf

		If lRetorno .And. nCount > 0
			If nSheet == 5 
				FWMsgRun(, { || oView:ButtonOkAction(.F.) }, STR0047, STR0042 + " " + STR0092) //"Aguarde..." / "Processando ..." / "Gerando os totalizadores..."
			Else
				FWMsgRun(, { || oView:ButtonOkAction(.F.) }, STR0047, STR0091 + " " + STR0092) //"Aguarde..." / "Processando ..." / "Carrregando os Titulos..."
			EndIf	
		ElseIf lMenorSitef
			Help(NIL, NIL, "A918MenorSitef", NIL, STR0052, 1, 0) //"Valor menor que o Valor Protheus, necessário corrigir no Financeiro"
		EndIf

		ProcLogAtu(STR0138, STR0146)
		
	EndIf	
	
Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} BuscarLote
Busca o numero do proximo lote para baixa dos titulos

@type Function
@author Unknown
@since 28/04/2011
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function BuscarLote() As Character
Local aArea		:= GetArea()		//Salva area local
Local aOrdSE5 	:= SE5->(GetArea())	//Salva area SE5
Local cLoteFin	:= ''				//Numero do lote
Local lFind		:= .F.
	
cLoteFin := GetSxENum("SE5", "E5_LOTE", "E5_LOTE"  +cEmpAnt, 5)
	
DbSelectArea("SE5")
DbSetOrder(5)
	
While SE5->(MsSeek(xFilial("SE5") + cLoteFin))
	lFind := .T.
	If (__lSx8)
		ConfirmSX8()
	EndIf
			
	cLoteFin := GetSxENum("SE5","E5_LOTE","E5_LOTE"+cEmpAnt,5)
	
EndDo
	
If !lFind
	ConfirmSX8()
Else
	RollBackSX8()	
EndIf
	
//Restaura areas
RestArea(aArea)
RestArea(aOrdSE5)
	
Return cLoteFin

//---------------------------------------------------------------------------
/*/{Protheus.doc} A920EfetuaBX
Efetua a baixa do titulo por lote ou individual               

@type Function
@author Unknown
@since 29/04/2011
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A920EfetuaBX(aLotes As Array, aRegConc As Array, lRetorno As Logical) As Logical
Local aTitulosBx	:= {}
Local nCount		:= 0	

Private lMsErroAuto	:= .F.
Private nRandThread := 0

Default aLotes	 := {}
Default aRegConc := {}
Default lRetorno := .F.

	If __nConcilia == 2 //Baixa por lote
	
		If __nThreads > 1
			lRetorno := A920ThrLote(aLotes, aRegConc)
		Else
	
			For nCount := 1 To Len(aLotes)
					
				lRetorno	:= .F.            
				
				aTitulosBX := aLotes[nCount][9]
				
				IncProc(STR0106 + ", " + STR0111 + aLotes[nCount][1] + STR0112 + AllTrim( Str( Len( aTitulosBX ) ) ) + ")") //"Aguarde..."#(Lote: "#" / Qtde Títulos: "
				
				If FBxLotAut("SE1", aTitulosBX, aLotes[nCount][5], aLotes[nCount][6], aLotes[nCount][7],,aLotes[nCount][1],, aLotes[nCount][8])
					lRetorno := .T.
				Else 
					Help(" ", 1, "A918Incosit",, STR0056, 1, 0,,,,,,{ STR0057 })
					Exit
				EndIf

			Next nCount			
		EndIf
		
	Else  
		//Baixa individual
		GETEMPR(cEmpAnt + cFilAnt)
		
		aTitulosBX := aLotes
		
		MSExecAuto({ |x, y| FINA070(x, y) }, aTitulosBX, 3)
		
		//Verifica se ExecAuto deu erro
		lRetorno := !lMsErroAuto

		If !lRetorno
			MostraErro()
			DisarmTransaction()
		EndIf
	EndIf
	
	If !lRetorno
	   ProcLogAtu(STR0149,STR0056)
	EndIf

Return lRetorno

//---------------------------------------------------------------------------
/*/{Protheus.doc} A920ThrLote
Efetua o controle das threads da conciliação                              

@type Function
@author Unknown
@since 21/01/2014
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A920ThrLote(aLotes As Array, aRegConc As Array) As Logical
Local oModelBxR
Local oSubFKA
Local oSubFK5
Local aTitulosBX	:= {}
Local lOk			:= .T.
Local lFa110Tot		:= ExistBlock('FA110TOT')
Local nIx			:= 0
Local nJx			:= 0 
Local cLog			:= ''
Local cCamposE5		:= ''
Local cBco110		:= '' 
Local cAge110		:= ''
Local cCta110		:= ''
Local cLoteFin		:= ''
Local cCheque		:= ''
Local cNatureza     := Nil
Local lBaixaVenc    := __lFIFDtCr	//se deve gravar a data de credito na E1_BAIXA
Local cNatLote		:= FINNATMOV( 'R' )
Local cMyUId		:= 'F918_THREAD_ID' //Definição do nome da seção para controle de variáveis "globais"
Local cKeyId		:= 'F918_KEY_'		//Definição da chave para controle de variáveis "globais"
Local aValor		:= {}				//Array que armazenará os valores "globais"
Local aRet			:= {}
Local aRetAux		:= {}
Local nX			:= 0
Local nY			:= 0
Local lSpbInUse 	:= SpbInUse()
Local aRecnosAux	:= {}
Local aLoteAux		:= {}
Local aGrvTxt		:= {}
Local lGrvTxt		:= .F.
Local cEndGrvTx     := ""
Local cThreadId		:= ""

Private oThredSE1	:= Nil	//Objeto controlador de MultThreads
Private nValorTef	:= 0

Default aLotes   := {}
Default aRegConc := {}

For nIx := 1 TO Len(aLotes)

	lOk := A920VldLote(aLotes[nIx])

	If !lOk
		Exit	
	EndIf

Next nIx

If Len(aLotes) == 1
	If Len(aLotes[1][9]) <= 50
		For nIx := 1 To Len( aLotes[1,9] )
			aAdd(aRecnosAux, aLotes[1,9,nIx]) 
		Next nIx
		Pergunte( "FIN110", .F. )
		
		aLoteAux := {aRecnosAux,aLotes[1,5],aLotes[1,6],aLotes[1,7],cCheque,aLotes[1,1],cNatureza,aLotes[1,8],lBaixaVenc}
		lMsErroAuto := .F.
		FINA110( 3 , aLoteAux, .F., ,)
		lOk := !lMsErroAuto
 
		Return lOk
	EndIf
EndIf

If lOk
	
	For nJx := 1 TO Len(aLotes)
		__aRetThrd := {} 
		aRetAux    := {} 
		cThreadId  := SubStr('FA110_' + AllTrim(Str(GenRandThread())), 1, 15)

		//Defino a seção, disponibilizando variáveis globais que podem ser enxergadas nas threads que serão abertas
		VarSetUID(cMyUId+cThreadId)

		// Objeto controlador de Threads
		oThredSE1 := FWIPCWait():New(cThreadId, 10000)
		
		oThredSE1:SetThreads(__nThreads)
		
		oThredSE1:StopProcessOnError(.T.)
		
		oThredSE1:SetEnvironment(cEmpAnt,cFilAnt)
		
		oThredSE1:Start('A920ATHRBX')
		
		aTitulosBX := AClone(aLotes[nJx])
		
		If __lConoutR
			ConoutR(STR0106 + ', '+ STR0111 + aTitulosBX[1] + STR0112 + AllTrim(Str(Len(aTitulosBX[9]))) + ')')
		EndIf 
		
		IncProc(STR0106 + ', ' + STR0111 + aTitulosBX[1] + STR0112 + AllTrim(Str(Len( aTitulosBX[9]))) + ')') //"Aguarde..."#(Lote: "#" / Qtde Títulos: "

		ProcLogAtu(STR0138, StrZero(ThreadId(),10) + ' ' + STR0111 + aTitulosBX[1] + STR0112 + AllTrim(Str(Len(aTitulosBX[9]))) + ')')

		lOk := A920APreBx(oThredSE1, aTitulosBX, aRegConc, cThreadId)
		
		If !lOk
			Exit
			
			oThredSE1:Stop() //Metodo aguarda o encerramento de todas as threads antes de retornar o controle.			
		Else

			oThredSE1:Stop() //Metodo aguarda o encerramento de todas as threads antes de retornar o controle.

			cErro := oThredSE1:GetError()

			For nIx := 1 To Len(__aRetThrd)
				VarGetA(cMyUId+cThreadId, __aRetThrd[nIx][1], @aRet)
				If Len(aRet) > 0
					For nX := 1 To Len(aRet)
						If !aRet[nX][1][1]
							lGrvTxt := .T.
							aAdd(aGrvTxt, { aRet[nX][1][2] })
						EndIf
					Next nX
				Else
					lOk := .F.
					lGrvTxt := .T.
					For nY := 1 To Len(__aRetThrd[nIx][2])
						aAdd(aGrvTxt, { __aRetThrd[nIx][2][nY] })
					Next nY
				EndIf
				aAdd(aRetAux, aRet)
			Next nIx
			
			If Len(aRetAux) > 0
				For nIx := 1 To Len(aRetAux) 
					If Len(aRetAux[nIx]) > 0 .And. (Len(aRetAux[nIx]) - 1) == Len(__aRetThrd[nIx][2])
						Loop
					Else
						If Len(aRetAux[nIx]) > 0
							For nX := 1 To Len(__aRetThrd[nIx][2])
								If nX <= Len(aRetAux[nIx])
									Loop
								Else
									lOk 	:= .F.
									lGrvTxt := .T.
									aAdd(aGrvTxt, { __aRetThrd[nIx][2][nX] })
								EndIf
							Next nX
						EndIf
					EndIf
				Next nIx
			EndIf
	
			//Obtenho o array que foi alimentado pelas threads
			VarGetA( cMyUId+cThreadId, cKeyId, @aValor )

			If lOk
				// se conseguiu efetuar a baixa, atualizo o registro da FIF
				lOk := AtualizaFIF(aTitulosBX, aRegConc)
			EndIf
			
			//Varro o array atrás dos valores totais gravados pelas threads que foram executadas
			For nX := 1 To Len(aRetAux) 
				If Len(aRetAux[nX]) > 0
					nValorTef += aRetAux[nX][Len(aRetAux[nX])][1][2]
				EndIf
			Next nX
	
			If nValorTef > 0
				cBco110	 := PadR(aTitulosBX[5], __nTamBco)
				cAge110	 := PadR(aTitulosBX[6], __nTamAge)
				cCta110	 := PadR(aTitulosBX[7], __nTamCC)
				cLoteFin := aTitulosBX[1]
				dBaixa	 := aTitulosBX[8]
	
				SE1->( DbSetOrder(1) )
				SE1->( DbSeek( xFilial('SE1') + aTitulosBX[1] + aTitulosBX[2] + aTitulosBX[3] + aTitulosBX[4] + aTitulosBX[5] + aTitulosBX[7] ) )
				
				//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
				//Estrutura para o E5_CAMPOS: "{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}|{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}"
				cCamposE5 := "{"
			
			   	oModelBxR := FWLoadModel('FINM030')
				oModelBxR:SetOperation(MODEL_OPERATION_INSERT) //Inclusão
				oModelBxR:Activate()
				oModelBxR:SetValue('MASTER', 'E5_GRV'  , .T.) //Informa se vai gravar SE5 ou não 
				oModelBxR:SetValue('MASTER', 'NOVOPROC', .T.) //Informa que a inclusão será feita com um novo número de processo
				
				//Dados do Processo
				oSubFKA := oModelBxR:GetModel('FKADETAIL')
				oSubFKA:SetValue('FKA_IDORIG', FWUUIDV4())
				oSubFKA:SetValue('FKA_TABORI', 'FK5')
				
				//Informacoes do movimento
				oSubFK5 := oModelBxR:GetModel('FK5DETAIL')
				oSubFK5:SetValue('FK5_VALOR'	, nValorTef										)
				oSubFK5:SetValue('FK5_TPDOC'	, 'VL'											)
				oSubFK5:SetValue('FK5_BANCO'	, cBco110										)
				oSubFK5:SetValue('FK5_AGENCI'	, cAge110										)
				oSubFK5:SetValue('FK5_CONTA'	, cCta110										)
				oSubFK5:SetValue('FK5_RECPAG'	, 'R'											)
				oSubFK5:SetValue('FK5_HISTOR'	, STR0164 + " / " + STR0165 + ": " + cLoteFin	) // "Baixa Automatica / Lote: "	
				oSubFK5:SetValue('FK5_DTDISP'	, dBaixa										)
				oSubFK5:SetValue('FK5_FILORI'	, F918BxLote()									)
				oSubFK5:SetValue('FK5_ORIGEM'	, SubStr(FunName(),1,8)							)				
				oSubFK5:SetValue('FK5_LOTE'		, cLoteFin										)
				oSubFK5:SetValue('FK5_NATURE'	, cNatLote										) 
				oSubFK5:SetValue('FK5_MOEDA'	, StrZero( SE1->E1_MOEDA, 2 )					)
				oSubFK5:SetValue('FK5_DATA'		, dBaixa 										)

				cCamposE5 += '{"E5_DTDIGIT",STOD("' + DToS(dDataBase) + '")}'
				cCamposE5 += ',{"E5_DTDISPO",STOD("' + DToS(dBaixa) + '")}'
				
				If lSpbInUse
					cCamposE5 += ',{"E5_MODSPB","1"}'
				EndIf
								
				cCamposE5 += ',{"E5_LOTE","' + cLoteFin + '"}'
				cCamposE5 += '}'
				
				oModelBxR:SetValue('MASTER', 'E5_CAMPOS', cCamposE5) //Informa os campos da SE5 que serão gravados indepentes de FK5
			
				If oModelBxR:VldData()		
					oModelBxR:CommitData()
					SE5->(dbGoto(oModelBxR:GetValue('MASTER', 'E5_RECNO')))
				Else
					lOk := .F.
					cLog := cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
				    cLog += cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
				    cLog += cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_MESSAGE])        	
				    
				    Help(,, 'M030VALID',, cLog, 1, 0)	            
				EndIf
				
				oModelBxR:DeActivate()
				oModelBxR:Destroy()
				
				// PONTO DE ENTRADA FA110TOT
				// ExecBlock para gravar dados complementares ao registro totalizador
				If lFa110Tot
					Execblock('FA110TOT', .F., .F.)
				EndIf
			
				// Atualiza saldo bancario
				AtuSalBco(cBco110, cAge110, cCta110, SE5->E5_DATA, SE5->E5_VALOR, '+')
			EndIf	

			aValor := {}

			//Zero o valor da variável, evitando que ocorra somatória incorreta dos totais
			nValorTef := 0
					
		EndIf

		//Deleto a seção após sua utilização
		VarClean(cMyUId + cThreadId)
		FreeObj(oThredSE1)
	Next nJx 

	If lGrvTxt
		If Aviso(STR0183, STR0189, { STR0188, STR0187 }, 3) = 1 //"Existem titulos que não foram conciliados. Deseja gerar arquivo LOG para conferencia?."
			cEndGrvTx := FA920GrvTx(aGrvTxt)	
			Aviso(STR0183, STR0184 + STR0185 + cEndGrvTx, { STR0104 }, 3)  // "Atenção" # "Os titulos que não foram conciliados estão relacionados no arquivo, gravado em: "
		EndIf
	EndIf
	
	IncProc(STR0154)

	oThredSE1 := Nil

	//Deleto a seção após sua utilização
	VarClean(cMyUId)
EndIf

Return lOk


//---------------------------------------------------------------------------
/*/{Protheus.doc} A920VldLote
Efetua a valiação do lote de processamento dos lotes                              

@type Function
@author Unknown
@since 21/01/2014
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A920VldLote(aLotes As Array) As Logical
Local lOk		:= .T.
Local cBanco	:= PadR(aLotes[5], __nTamBco)
Local cAgencia	:= PadR(aLotes[6], __nTamAge)
Local cConta	:= PadR(aLotes[7], __nTamCC)

Default aLotes := {}

//Verifico informacoes para processo
If Empty(cBanco) .Or. Empty(cAgencia) .Or. Empty(cConta) 
	Help(" ", 1, "BXLTAUT1",, STR0049, 1, 0)		//"Informações incorretas não permitem a baixa automática em lote. Verifique as informações passadas para a função FBXLOTAUT()"
	lOk		:= .F.
ElseIf !CarregaSa6(@cBanco, @cAgencia, @cConta, .T.,, .F.)
	lOk		:= .F.
ElseIf Empty(aLotes[9])
	Help(" ", 1, "RECNO")
	lOk	:= .F.
EndIf

Return lOk

//---------------------------------------------------------------------------
/*/{Protheus.doc} GenRandThread
Controle de numeração das threads                              

@type Function
@author Pedro Pereira Lima
@since 30/10/2013
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function GenRandThread() As Numeric
Local nThreadId := nRandThread

While nRandThread == nThreadId .Or. nRandThread == 0
	nRandThread := Randomize(10000,29999)
EndDo

nThreadId := nRandThread

Return nThreadId

//---------------------------------------------------------------------------
/*/{Protheus.doc} A920APreBx
Inicia a preparação das baixas dos cartões                              

@type Function
@author Unknown
@since 21/01/2014
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A920APreBx(oThread As Object, aTitulosBX As Array, aRegConc As Array, cThreadId As Character) As Logical

Local aRecnosAux    As Array
Local cChave        As Character
Local cMyUId		As Character
Local cKeyId		As Character
Local cBanco        As Character
Local cAgencia      As Character
Local cConta        As Character
Local cCheque       As Character
Local cLoteFin      As Character
Local cNatureza     As Character
Local aRecnos       As Array
Local lOk           As Logical
Local lBaixaVenc    As Logical
Local nIx           As Numeric 
Local nCont         As Numeric
Local nContAux		As Numeric
Local nQtLote		As Numeric
Local nCtrlLote		As Numeric
Local aValor		As Array
Local aRetTHD		As Array
Local nQtdeRec		As Numeric
Local nTHDAux		As Numeric

Private dBaixa      As Date 

Default oThread	   := Nil
Default aTitulosBX := {}
Default aRegConc   := {}
Default cThreadId  := ""

aRecnosAux    := {}
cChave        := "FA110BXAUT_THRD"+cThreadId
cMyUId		  := 'F918_THREAD_ID' //Definição do nome da seção para controle de variáveis "globais"
cKeyId	      := ''		//Definição da chave para controle de variáveis "globais"'
cBanco        := PadR(aTitulosBX[5], __nTamBco)
cAgencia      := PadR(aTitulosBX[6], __nTamAge)
cConta        := PadR(aTitulosBX[7], __nTamCC)
cCheque       := ''
cLoteFin      := aTitulosBX[1]
cNatureza     := Nil
aRecnos       := aTitulosBX[9]
lOk           := .T.
lBaixaVenc    := __lFIFDtCr	//se deve gravar a data de credito na E1_BAIXA
nIx           := 0
nCont         := 0
nContAux	  := 0
nQtLote		  := 0
nCtrlLote	  := 0
aValor		  := {}
aRetTHD		  := {}
nQtdeRec	  := Int(Len(aRecnos) / __nLoteThr) + 1 
nTHDAux		  := __nThreads
dBaixa        := aTitulosBX[8]

//Priorizo quantidade de recno por lote 
If nQtdeRec <= nTHDAux
	nTHDAux := nQtdeRec
	nQtLote := Int(Len(aRecnos) / nTHDAux) + 1
Else
	//Priorizo o numero de Threads
	nQtLote := Int(Len(aRecnos) / __nThreads)
EndIf

If !LockByName(cChave, .F. , .F.)
	Help(" ", 1, cChave,, STR0155, 1, 0)
	lOk := .F.
Else
	// Abertura de Threads
	ProcRegua(Len(aRecnos))
					
	For nIx := 1 To Len(aRecnos)
		IncProc()
		nCont++
		nContAux++
		aAdd(aRecnosAux, aRecnos[nIx])
	
		If nCont == nQtLote .Or. nContAux == Len(aRecnos)
			
			nCtrlLote++
			cKeyId	:= 'F918_KEY_' + cLoteFin + StrZero(nCtrlLote,3)

			aAdd(__aRetThrd, { cKeyId, aRecnosAux })
			
			VarSetA( cMyUId+cThreadId, cKeyId, aRetTHD )

			// Chamada da função A920ATHRBX( aTitulos, aRegConc )
			oThread:Go( {aRecnosAux,cBanco,cAgencia,cConta,cCheque,cLoteFin,cNatureza,dBaixa,lBaixaVenc}, aRegConc, .T.,cKeyId,dDataBase,cMyUId+cThreadId)
	        Sleep(500)
		    aRecnosAux	:= {}
		    aValor		:= {}
            nCont		:= 0
		EndIf
	Next nIx

	// Fechamento das Threads   
	UnLockByName(cChave, .F. , .F.)
EndIf	

Return lOk

//---------------------------------------------------------------------------
/*/{Protheus.doc} FA920GrvTx
Grava arquivo texto com os daddos da SE1 que não foram conciliadas 

@type Function
@author Francisco Oliveira
@since 05/08/2018
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function FA920GrvTx(aGrvTxt As Array) As Character 
Local aAreaSE1	As Array
Local nI        As Numeric
Local nHdl		As Numeric
Local cEOL    	As Character 
Local cLin		As Character 
Local cExtens	As Character 
Local cMainPath	As Character 

aAreaSE1	:= SE1->(GetArea())

cEOL    	:= "CHR(13)+CHR(10)"
cLin		:= ""
cExtens		:= "Arquivo TXT | *.TXT"
cMainPath	:= "C:\N_Conc_01.TXT"
cFileOpen 	:= cGetFile(cExtens, STR0225,, cMainPath, .T.)
nHdl    	:= fCreate(cFileOpen)

Incproc(Len(aGrvTxt))

cLin := "FILIAL; FILORIG; PREFIXO; NUMERO; PARCELA; TIPO; VENCIMENTO; EMISSAO; DT BAIXA; SALDO"
cLin += &cEOL
cLin += &cEOL

If fWrite(nHdl, cLin, Len(cLin)) != Len(cLin)
	Aviso(STR0183, STR0186, { STR0104 }, 3) //"Atencao!" # "Ocorreu um erro na gravacao do arquivo. Favor verificar"
EndIf
	
For nI := 1 To Len(aGrvTxt)

	SE1->(DbGoTo(aGrvTxt[nI][1]))

	cLin	:= ""
	
	cLin := SE1->E1_FILIAL  		+ ";"
	cLin += SE1->E1_FILORIG 		+ ";"
	cLin += SE1->E1_PREFIXO 		+ ";" 
	cLin += SE1->E1_NUM     		+ ";" 
	cLin += SE1->E1_PARCELA 		+ ";" 
	cLin += SE1->E1_TIPO 			+ ";" 
	cLin += DTOC(SE1->E1_VENCTO)	+ ";" 
	cLin += DTOC(SE1->E1_EMISSAO)	+ ";" 
	cLin += DTOC(SE1->E1_BAIXA)		+ ";" 
	cLin += cValToChar(SE1->E1_SALDO)
	
	cLin += &cEOL
	
	If fWrite(nHdl, cLin, Len(cLin)) != Len(cLin)
		Aviso(STR0183, STR0186, { STR0104 }, 3) //"Atencao!" # "Ocorreu um erro na gravacao do arquivo. Favor verificar"
		Exit
	EndIf
	
Next nI

fClose(nHdl)

RestArea(aAreaSE1)

Return cFileOpen

//---------------------------------------------------------------------------
/*/{Protheus.doc} A920VLDBCO
Validação do banco                              

@type Function
@author Pedro Pereira Lima
@since 07/08/2013
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A920VLDBCO(cBanco As Character, cAgencia As Character, cConta As Character, cCodFil As Character) As Logical
Local lRet		:= .T.
Local nSubBco	:= IIf(Len(cBanco)   - __nTamBco <= 0, 1, (Len(cBanco)   - __nTamBco) + 1)
Local nSubAge	:= IIf(Len(cAgencia) - __nTamAge <= 0, 1, (Len(cAgencia) - __nTamAge) + 1)
Local nSubCC	:= IIf(Len(cConta)   - __nTamCC  <= 0, 1, (Len(cConta)   - __nTamCC) + 1)
Local nPos		:= 0
Local cFilSA6 	:= ""

lSA6Comp := !(F916ChkMod("SA6"))

If __cFilSA6 == Nil .Or. (xFilial( 'SA6' ) == cCodFil) .Or. lSA6Comp
	cFilSA6	:= xFilial( 'SA6' )
Else
	cFilSA6	:= cCodFil
EndIf

If __cFilSA6 == Nil .Or. __cFilSA6 != cFilSA6
	__cFilSA6 := cFilSA6
	// Efetua a carga dos bancos 
	LoadBanco(cFilSA6, lSA6Comp)
EndIf	

cBanco	 := PadR(SubStr(cBanco, nSubBco, __nTamBco), __nTamBco)
cAgencia := PadR(SubStr(cAgencia, nSubAge, __nTamAge), __nTamAge)
cConta	 := PadR(SubStr(cConta, nSubCC, __nTamCC), __nTamCC)

nPos := Ascan(__aBancos, { |x| x[1] == __cFilSA6 .And. x[2] == cBanco .And. x[3] == cAgencia .And. x[5] == cConta })
lRet := (nPos > 0) 

If lRet
	If __aBancos[nPos,7] == '1'
		lRet := .F.
	ElseIf !Empty(__aBancos[nPos,8]) .And. __aBancos[nPos,8] == '1'
		lRet := .F.
	EndIf 

	If !lRet
		Help(NIL, NIL, "F918GvBco", NIL, STR0132, 1, 0)		// "Banco/Conta bloqueado(a). Verificar o cadastro de bancos."
	EndIf
Else
	Help(NIL, NIL, "F918GvBco", NIL, STR0260, 1, 0)		// "Banco/Conta não cadastrada. Verificar o cadastro de bancos."
EndIf

Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} F920AtuFIF
Atualiza os dados da FIF apos a baixa dos titulos

@type Function
@author Unknown
@since 28/04/2011
@version 12   
/*/
//---------------------------------------------------------------------------
Function F920AtuFIF(aRegConc As Array, lRet As Logical) 

Local nCount	As Numeric
Local aArea		As Array
Local aAliasFIF	As Array

DEFAULT aRegConc := {}
DEFAULT lRet	 := .T.

nCount	  := 0				  //Utilizada para ler todos os registros baixados
aArea	  := GetArea()		  //Salva area local
aAliasFIF := FIF->(GetArea()) //Salva area FIF

ProcRegua(Len(aRegConc))
IncProc(STR0108) //"Atualizando tabela FIF..."
	
DbSelectArea("FIF")
DbSetOrder(5)
	
//FIF_FILIAL + FIF_DTTEF + FIF_NSUTEF + FIF_PARCEL
For nCount := 1 To Len(aRegConc)

	//Os registros que estiverem marcados como vermelho, são aqueles que foram conciliados e baixados

	If !Empty(aRegConc[nCount][23])
		FIF->( dbGoTo(aRegConc[nCount][23]) ) // Faz a busca pelo FIF.R_E_C_N_O_
		If FIF->( !Eof() ) .And. FIF->( Recno() ) == aRegConc[nCount][23]

			IncProc()
		
			RecLock("FIF", .F.)
		
			FIF->FIF_STATUS := aRegConc[nCount][1]		//'6' - Ant. Nao Processada / '7' - Antecipado
			FIF->FIF_PREFIX := aRegConc[nCount][5]		//Rastro Prefixo SE1
			FIF->FIF_NUM    := aRegConc[nCount][6]		//Rastro Num SE1
			FIF->FIF_PARC   := aRegConc[nCount][8]   	//Rastro Parcela SE1
			FIF->FIF_TIPO   := aRegConc[nCount][7]   	//Rastro Tipo SE1		
			FIF->FIF_PGJUST := aRegConc[nCount][29]		//Justificativa FVX
			FIF->FIF_PGDES1 := aRegConc[nCount][30]		//Justificativa FVX
			FIF->FIF_PGDES2 := aRegConc[nCount][31]		//Justificativa Manual
			FIF->FIF_USUPAG := RetCodUsr()				//Código do usuário
			FIF->FIF_DTPAG 	:= dDatabase				//database

			FIF->(MsUnlock())
		EndIf
	EndIf
	
	IncProc()
		
Next nCount

//Restaura areas
RestArea(aAliasFIF)
RestArea(aArea)
	
Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} A920DelTmp
Deleta as tabelas temporárias            

@type function
@author sidney.silva
@since 30/03/2022  
/*/
//---------------------------------------------------------------------------
Static Function A920DelTmp()

	If __oAba1 != Nil
		__oAba1:Delete()
		__oAba1 := Nil        
	EndIf

	If __oAba2 != Nil
		__oAba2:Delete()
		__oAba2 := Nil        
	EndIf

	If __oAba3 != Nil
		__oAba3:Delete()
		__oAba3 := Nil        
	EndIf

	If __oAba4FIF != Nil
		__oAba4FIF:Delete()
		__oAba4FIF := Nil        
	EndIf

	If __oAba4SE1 != Nil
		__oAba4SE1:Delete()
		__oAba4SE1 := Nil        
	EndIf

	If __oAba5 != Nil
		__oAba5:Delete()
		__oAba5 := Nil        
	EndIf

	If __oAba7 != Nil
		__oAba7:Delete()
		__oAba7 := Nil        
	EndIf

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} A920aInVar
Inicia as variaveis staticas utilizadas no fonte               

@type Function
@author Unknown
@since 21/01/2014
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A920aInVar()
Local cTipoBD As Character

cTipoBD := TcGetDb()

If __nThreads == Nil 
	__nThreads := SuperGetMv("MV_BLATHD", .T., 1)	// Limite de 20 Threads permitidas
EndIf

If __nLoteThr == Nil
	__nLoteThr := SuperGetMv("MV_BLALOT", .T., 50)	// Quantidade de registros por lote
EndIf

__nThreads := If((__nThreads > 20), 20, __nThreads)

If __lPrcDocT == Nil
    __lPrcDocT := SuperGetMv("MV_BLADOC", .T., .F.) // Verifica se irá processar pelo DOCTEF ou pelo NSUTEF. Padrão é pelo NSUTEF
EndIf

If __nTamBco == Nil
	__nTamBco := TAMSX3("A6_COD")[1]
EndIf

If __nTamAge == Nil 
	__nTamAge := TamSX3("A6_AGENCIA")[1]
EndIf

If __nTamCC == Nil
	__nTamCC := TAMSX3("A6_NUMCON")[1]
EndIf

If __aBancos == Nil
	__aBancos := {}
EndIf

If __lMEP == Nil 
	__lMEP := AliasInDic("MEP")
EndIf

If __lUsaMep == NIL
	__lUsaMep := SuperGetMv("MV_USAMEP",.T.,.F.)
EndIf	

If __lA6MSBLQ == Nil
	__lA6MSBLQ := (SA6->(FieldPos('A6_MSBLQL')) > 0)
EndIf

If __lFIFRcE1 == Nil
    __lFIFRcE1 := (FIF->(FieldPos('FIF_RECSE1')) > 0)
EndIf

If __cTamNSU == Nil
	__cTamNSU := Alltrim(Str(TamSX3("FIF_NSUTEF")[1]))
End

If __nTamNSU == Nil
	__nTamNSU := TamSX3("FIF_NSUTEF")[1]
End

If __cTamDoc == Nil
	__cTamDoc := Alltrim(Str(TamSX3("FIF_NUCOMP")[1]))
End

If __nTamDOC == Nil
	__nTamDOC := TamSX3("FIF_NUCOMP")[1]
End

If __lDocTef == Nil
	__lDocTef := FieldPos("FIF_NUCOMP") > 0
EndIf	

If __lConoutR == Nil
	__lConoutR := FindFunction("CONOUTR")
EndIf

__cCpoSE1 := "|OK|E1_FILIAL|E1_CLIENTE|E1_PREFIXO|E1_NUM|E1_TIPO|E1_PARCELA|E1_SALDO|E1_DOCTEF|E1_NSUTEF|E1_VENCREA|E1_VENCTO|E1_EMISSAO|E1_NATUREZ|E1_LOJA|E1_NOMCLI|E1_VALOR|E1_FILORIG|E1_VLRREAL|E1_CARTAUT"

__cCpoFIF := "|OK|FIF_CODEST|FIF_CODLOJ|FIF_NUCOMP|FIF_DTTEF|FIF_DTCRED|FIF_VLBRUT|FIF_VLLIQ|FIF_NSUTEF|FIF_PARCEL|FIF_CODBCO|FIF_CODAGE|FIF_NUMCC|FIF_CAPTUR|FIF_FILIAL|FIF_PARALF|FIF_NURESU|FIF_NUCART|FIF_TPPROD|FIF_VLCOM|FIF_TXSERV|FIF_CODAUT|FIF_CODBAN|FIF_STATUS|FIF_TPREG|FIF_SEQFIF|FIF_PGJUST|FIF_PGDES1|FIF_PGDES2|FIF_CODFIL|FIF_CODADM|FIF_CODMAJ|FIF_NSUARQ|FIF_NUM|FIF_PARC|FIF_PREFIX"

__bVldSE1	:= { |x| AllTrim(x) $ __cCpoSE1 }
__bVldFIF	:= { |x| AllTrim(x) $ __cCpoFIF }

__lCheck01	:= .F.
__lCheck02	:= .F.
__lCheck03	:= .F.

__nFldPar 	:= 0
__cAdmFin	:= ""
__lSOFEX	:= .F.

__oAba1 	:= Nil
__oAba2 	:= Nil
__oAba3 	:= Nil
__oAba4FIF 	:= Nil
__oAba4SE1 	:= Nil
__oAba5 	:= Nil
__oAba7 	:= Nil

If __lSmtHTML == Nil
	__lSmtHTML := (GetRemoteType() == 5)
EndIf	

__cFilAnt := cFilAnt

If __lOracle == Nil
	__lOracle := cTipoBD $ "INFORMIX*ORACLE"
EndIf	

If __lPostGre == Nil
	__lPostGre := cTipoBD $ "POSTGRES"
EndIf	

If __lSQL == Nil
	__lSQL := cTipoBD $ "MSSQL"
EndIf	

If __lLJGERTX == Nil
	__lLJGERTX := SuperGetMv("MV_LJGERTX", .T., .F.)
EndIf	

If __lPontoF == Nil
	__lPontoF := ExistBlock("FINA910F")
EndIf

If __lParcFIF == Nil
	__lParcFIF := SuperGETMV("MV_1DUP", .T., .F.) == "A"
EndIf

__nFIFFLD1   	:= 0
__nFIFFLD2   	:= 0
__nFIFFLD3 	 	:= 0
__nSE1FLD3   	:= 0
__nFIFFLD4   	:= 0
__nSE1FLD4   	:= 0
__nFIFFLD5   	:= 0
__aSelFil 	 	:= {}
__nSelFil		:= 2
__cFilIni		:= ""
__cFilFim		:= ""
__dDtCredI		:= CToD("")	
__dDtCredF		:= CToD("")	
__cNsuIni		:= ""
__cNsuFim		:= ""
__nConcilia		:= 1				
__nTpProc		:= 1
__nQtdDias		:= 0			
__nMargem		:= 0		
__cAdmIni		:= ""		
__cAdmFim		:= ""
__lFIFDtCr		:= .F.
__nNsuCons		:= 1		
__nTpPagam		:= 0
__lAPixTpd	    := Nil
__cVarComb   	:= ""
__aVarComb   	:= {}
__lMsgTef	 	:= .T. 
__aRetThrd 		:= {}
__cFilSA6    	:= Nil
__lTef       	:= .F.  //Identifica se é conciliação TEF
__lPixDig    	:= .F.  //Identifica se é conciliação PIX/Carteiras Digitais

If __lAPixTpd == Nil .And. FindFunction("F918AtuTPD") 
	__lAPixTpd := F918AtuTPD() //Valida se o ambiente está atualizado
EndIf

If __lAPixTpd
	If __nTRecOri == Nil
		__nTRecOri := TAMSX3("FJU_RECORI")[1]
	EndIf

	If __nTRecPai == Nil
		__nTRecPai := TAMSX3("FJU_RECPAI")[1]
	EndIf

	__cCpoFJU := "|OK|FJU_FILIAL|FJU_CLIFOR|FJU_LOJA|FJU_PREFIX|FJU_NUM|FJU_TIPO|FJU_PARCEL|FJU_VALOR|FJU_DOCTEF|FJU_VENREA|FJU_EMIS|FJU_CART|FJU_RECORI|FJU_RECPAI|FJU_DTEXCL"

	__bVldFJU := { |x| AllTrim(x) $ __cCpoFJU }

	__lCheck07 := .F.

	__nFIFFLD7 := 0
EndIf

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} A920ATHRBX
Rotina de controle das baixas. Inicializa uma trasação por thread. Caso 
caia, somente aquela thread é afetada.      

Incluido dData para que a Thread suba com a database da execução. 

@type Function
@author Unknown
@since 21/01/2014
@version 12   
/*/
//---------------------------------------------------------------------------

Function A920ATHRBX(aTitulos As Array, aRegConc As Array, lThread As Logical, cKeyId As Character, dData As Date, cMyUId As Character) As Logical

Local lOk As Logical

Default lThread := .T.
Default cKeyId  := ""
Default dData	:= Date()

lOk			:= .F.
dDatabase	:= dData
lMsErroAuto := .F.
Pergunte("FIN110", .F.)

If __lConoutR
	ConoutR(StrZero(ThreadId(),10) + STR0156)
EndIf

FINA110(3, aTitulos, lThread, cKeyId, aRegConc, cMyUId)

//Verifica se ExecAuto deu erro
lOk := !lMsErroAuto

If !lOk .And. __lConoutR
   ConoutR(StrZero(ThreadId(),10) + STR0157)
   /* Como aqui é um processo via Thread, não deveriamos ter processo de tela. 
	Outra solução é arrumar a passagem de parametro para gravar o arquivo do erro e posteriormente ler esse arquivo. 
   ConoutR( MostraErro() )*/
   DisarmTransaction()
EndIf

If __lConoutR
	ConoutR(StrZero(ThreadId(),10) + STR0158)
EndIf
Return lOk

//---------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaFIF 
Efetua a baixa dos registros da FIF. Estão na mesma transação da baixa por  
lote.                                          

@type Function
@author Unknown
@since 21/01/2014
@version 12   
/*/
//---------------------------------------------------------------------------

Static Function AtualizaFIF(aTitulos, aRegConc)
Local aArea		:= GetArea()
Local lOk		:= .T.
Local nIx		:= 0
Local nPosFIF	:= 0
Local aTitAux	:= aTitulos[9]

For nIx := 1 TO Len(aTitAux)

	nPosFIF := aScan(aRegConc, { |x| x[22] == aTitAux[nIx] })
	
	// se localizei o registro da FIF dentro do aTitulos e o recno da FIF nÃ£o estÃ¡ em branco
	If nPosFIF > 0 .And. !Empty(aRegConc[nPosFIF][23])
		DbSelectArea('FIF')
		FIF->(DbGoTo(aRegConc[nPosFIF][23]))
			
		If FIF->(!Eof()) .And. FIF->(Recno()) == aRegConc[nPosFIF][23]
			RecLock("FIF",.F.)
			
			FIF->FIF_STATUS := "2"				    	//Conciliado
			FIF->FIF_PREFIX := aRegConc[nPosFIF][5]   	//Rastro Prefixo SE1
			FIF->FIF_NUM    := aRegConc[nPosFIF][6]   	//Rastro Num SE1
			FIF->FIF_PARC	:= aRegConc[nPosFIF][8]		//Rastro Parcela SE1
			FIF->FIF_TIPO   := aRegConc[nPosFIF][7]   	//Rastro Tipo SE1
			FIF->FIF_PGJUST := aRegConc[nPosFIF][29]	//Justificativa FVX
			FIF->FIF_PGDES1 := aRegConc[nPosFIF][30]	//Justificativa FVX
			FIF->FIF_PGDES2 := aRegConc[nPosFIF][31]	//Justificativa Manual
			FIF->FIF_USUPAG := RetCodUsr()				//Código do usuário
			FIF->FIF_DTPAG 	:= dDatabase				//database

			If __lFIFRcE1
				FIF->FIF_RECSE1 := aRegConc[nPosFIF][22]    //Rastro Recno SE1
			EndIf			

			FIF->(MsUnlock())
		Else
			lOk := .F.
         
			ProcLogAtu(STR0149,STR0159 + Alltrim( Str( aRegConc[nPosFIF][23] ) ) + STR0160)         
		EndIf

	EndIf
Next nIx

RestArea( aArea )

Return lOk

//---------------------------------------------------------------------------
/*/{Protheus.doc} LoadBanco
Carrega todos os bancos utiliados na conciliação para a memoria. Evitando a  
busca repetida de dados no banco de dados

@type Function
@author Unknown
@since 21/01/2014
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function LoadBanco(cCodFil as Character, lSA6Comp as Logical) 
Local aArea			:= GetArea()
Local bCondWhile	:= {|| .T. }
Local cQuery 		:= ""
Local cAliasSA6		:= "SA6"
Local cFilSA6		:= ""
Default lSA6Comp 	:= .F.

If (xFilial('SA6') == cCodFil) .Or. lSA6Comp
	cFilSA6	:= xFilial('SA6')
Else 
	cFilSA6	:= cCodFil
EndIf

// garanto que a variavel está limpa para o carregamento
	__aBancos := {}

	cAliasSA6 := GetNextAlias()
	
	cQuery := "SELECT A6_FILIAL, A6_COD, A6_AGENCIA, A6_DVAGE, A6_NUMCON, A6_DVCTA, A6_BLOCKED"
	
	If __lA6MSBLQ
		cQuery += ", A6_MSBLQL"
	EndIf
	
	cQuery += " FROM " + RetSqlName("SA6") + " SA6"
	cQuery += " WHERE SA6.A6_FILIAL = '" + cFilSA6 + "'"
	cQuery += "   AND SA6.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)

	// verifica se temporario está aberto e tenta fechalo
	If Select(cAliasSA6) > 0
		DbSelectArea(cAliasSA6)
		(cAliasSA6)->(DbCloseArea())
	EndIf

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasSA6)

	If Select(cAliasSA6) > 0
		DbSelectArea(cAliasSA6)
		(cAliasSA6)->(DbGoTop())

		nCont := 0
		While (cAliasSA6)->(!Eof()) .And. Eval(bCondWhile)
			// adiciono os bancos a serem utilizados na busca, otimização do carregamento dos dados
			Aadd( __aBancos,{	(cAliasSA6)->A6_FILIAL;
							,	(cAliasSA6)->A6_COD;
						 	,	(cAliasSA6)->A6_AGENCIA;
							,	(cAliasSA6)->A6_DVAGE;
							,	(cAliasSA6)->A6_NUMCON;
							,	(cAliasSA6)->A6_DVCTA;
							,	(cAliasSA6)->A6_BLOCKED;
							,	IIf( __lA6MSBLQ, (cAliasSA6)->A6_MSBLQL, Nil );
							})
			(cAliasSA6)->(DbSkip())
		EndDo
	EndIf

	// verifica se temporario está aberto e tenta fechalo
	If Select(cAliasSA6) > 0
		DbSelectArea(cAliasSA6)
		(cAliasSA6)->(DbCloseArea())
	EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F910ADM
Consulta Especifica das Administradoras Financeiras - Conciliador
Sitef
 ** FUNÇÃO SE MANTEVE COMO F910ADM POIS É UTILIZADA NO DICIONARIO - SXB

@type function
@author Danilo Santos
@since 10/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function F910ADM() // verificar chamada pelo dicionario
Local aColumns	:= {}
Local aPesq		:= {}
Local aStruct	:= SX5->(DBStruct())

Local cMvPar	:= Alltrim(ReadVar())
Local bOk		:= {|| lRetorno := F920Sel(cArqTrb, cMvPar), IIf(lRetorno, oDlg:End(),Nil)}
Local bCancel	:= {|| oMrkBrw:Deactivate(), oDlg:End()}

Local cArqTrb	:= GetNextAlias()
Local cQuery	:= ""
Local nCampo	:= 0

Local lRetorno	:= .F.
Local oDlg		:= NIL
Local oMrkBrw	:= NIL

//Limpa a Variavel de Retorno
__cAdmFin := ""

	If __oF918ADM <> NIL
		__oF918ADM:Delete()
		__oF918ADM := NIL
	EndIf

	//Cria o Objeto do FwTemporaryTable
	__oF918ADM := FwTemporaryTable():New(cArqTrb)

	//Cria a estrutura do alias temporario
	aAdd(aStruct, { "X5_OK", "C", 1, 0 })	 //Adiciono o campo de marca
	__oF918ADM:SetFields(aStruct)

	__oF918ADM:AddIndex("1", { "X5_TABELA" })
	__oF918ADM:AddIndex("2", { "X5_CHAVE" })

	//Criando a Tabela Temporaria
	__oF918ADM:Create()

	//Selecao dos Dados da SX5 - G3
	cQuery += "SELECT	SX5.X5_CHAVE" 
	cQuery += ",		SX5.X5_DESCRI" 
	cQuery += " FROM		" + RetSqlName("SX5") + " SX5"
	cQuery += " WHERE	SX5.X5_FILIAL = '" + FWxFilial("SX5") + "'"
	cQuery += " AND SX5.X5_TABELA = 'G3' "
	cQuery += " AND		SX5.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY " + SqlOrder(SX5->(IndexKey()))

	cQuery := ChangeQuery(cQuery)

	//Cria arquivo temporario
	Processa({|| SqlToTrb(cQuery, aStruct, cArqTrb)})

	//Fica na ordem da query
 	DbSetOrder(0)

	//MarkBrowse
	For nCampo := 1 To Len(aStruct)
		If	aStruct[nCampo][1] $ "X5_CHAVE|X5_DESCRI"
			AAdd(aColumns, FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCampo][1] + "}") )
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nCampo][1])) 
			aColumns[Len(aColumns)]:SetSize(aStruct[nCampo][3]) 
			aColumns[Len(aColumns)]:SetDecimal(aStruct[nCampo][4])
			aColumns[Len(aColumns)]:SetPicture(PesqPict("X5", aStruct[nCampo][1])) 
		EndIf 	
	Next nX 
	
	//Regras para pesquisa na tela
	Aadd(aPesq, {AllTrim(RetTitle("X5_CHAVE")), {{"SX5", "C", TamSX3("X5_CHAVE")[1], 0, AllTrim(RetTitle("X5_CHAVE")), "@!"}}, 1})
	Aadd(aPesq, {AllTrim(RetTitle("X5_DESCRI")), {{"SX5", "C", TamSX3("X5_DESCRI")[1], 0, AllTrim(RetTitle("X5_DESCRI")), "@!"}}, 2})
	
	If !(cArqTrb)->(Eof())
		DEFINE MSDIALOG oDlg TITLE STR0059 From 300, 0 To 800,800 OF oMainWnd PIXEL //Administradoras
		oMrkBrw := FWMarkBrowse():New()
		oMrkBrw:oBrowse:SetEditCell(.T.)	
		oMrkBrw:SetFieldMark("X5_OK")
		oMrkBrw:SetOwner(oDlg)
		oMrkBrw:SetAlias(cArqTrb)
		oMrkBrw:SetSeek(.T., aPesq)
		oMrkBrw:SetMenuDef("FINA920A")
		oMrkBrw:AddButton(STR0058, bOk, NIL, 2) //Confirmar
		oMrkBrw:AddButton(STR0180, bCancel, NIL, 2) //Cancelar 
		oMrkBrw:bMark := {||}
		oMrkBrw:bAllMark := {|| F920MrkAll(oMrkBrw,cArqTrb)}
		oMrkBrw:SetMark("X", cArqTrb, "X5_OK")
		oMrkBrw:SetDescription("")
		oMrkBrw:SetColumns(aColumns)
		oMrkBrw:SetTemporary(.T.) 
		oMrkBrw:Activate()
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf

	If __oF918ADM <> NIL
		__oF918ADM:Delete()
		__oF918ADM := NIL
	EndIf

Return lRetorno
//-------------------------------------------------------------------
/*/{Protheus.doc} F916Sel
Grava em uma String as Administradoras Selecionadas

@type function
@author Guilherme Santos
@since 15/03/2018
@version 12.1.19
/*/
//-------------------------------------------------------------------
Static Function F920Sel(cArqTrb, cMvPar) 
Local lRet		:= .T.
Local nRecno	:= 0
Local nX		:= 0
Local aParLin	:= {}
Local nVarTam	:= 0
Local nTotTam	:= 0
Local nMaxTam	:= 60

Default cArqTrb := ""
Default cMvPar 	:= Alltrim(ReadVar())

	DbSelectArea(cArqTrb)
	nRecno := (cArqTrb)->(Recno())
	(cArqTrb)->(DbGoTop())
	
	__cAdmFin := ""
	While !(cArqTrb)->(Eof())
		If !Empty((cArqTrb)->X5_OK)
			__cAdmFin += If(nX > 0, ";" + Alltrim((cArqTrb)->X5_CHAVE), Alltrim((cArqTrb)->X5_CHAVE) )
			nX++
		EndIf
		(cArqTrb)->(DbSkip())
	End

	// Efetua a validação da quantidade de empresas selecionadas para evitar estouro no parâmetro e error.log na query
	aParLin  := StrToArray(Alltrim(__cAdmFin), ";")
	For nX := 1 To Len(aParLin)
		nVarTam := Len(Alltrim(aParLin[nX])) + 1
		If (nTotTam + nVarTam) <= nMaxTam
			nTotTam += nVarTam
		Else
			lRet := .F.
			Help(NIL, NIL, "F920Sel", NIL, STR0181, 1, 0) //"Limite de seleção de empresas excedido para o parâmetro da rotina (Max 60 Caracteres)."
			Exit
		EndIf
	Next nX

	(cArqTrb)->(DbGoTo(nRecno))

	If lRet
		lRet := IIf(Len(__cAdmFin) > 0, .T., .F.)
		&(cMvPar) := __cAdmFin
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F920MrkAll
Marca ou Desmarca todas as Administradoras

@type function
@author Guilherme Santos
@since 15/03/2018
@version 12.1.19
/*/
//-------------------------------------------------------------------
Function F920MrkAll(oMrkBrw, cArqTrb)
Local cMarca := oMrkBrw:Mark()
	
	DbSelectArea(cArqTrb)
	(cArqTrb)->(DbGoTop())
	
	While !(cArqTrb)->(Eof())
		
		RecLock(cArqTrb, .F.)
		
		If (cArqTrb)->X5_OK == cMarca
			(cArqTrb)->X5_OK := " "
		Else
			(cArqTrb)->X5_OK := cMarca
		EndIf
		
		MsUnlock()
		(cArqTrb)->(DbSkip())	
	End
	
	(cArqTrb)->(DbGoTop())
	oMrkBrw:oBrowse:Refresh(.T.)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F920aStVen
Função para retornar o FIF_STVEND (Status de Venda) correto no momento
do Conciliação e estorno do Pagamento

@type function
@author Marcelo Ferreira
@since 16/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function F920aStVen(cStVenb As Character, lEstorno As Logical) As Character 
Local cRet		As Character
Local nLin		As Numeric
Local nP		As Numeric
Local nR	 	As Numeric
Local aDePara   As Array

Default cStVenb	 := ""
Default lEstorno := .F.

cRet := ""
nLin := 0
nP 	 := 0
nP 	 := 0
aDePara := {}

aAdd(aDePara, {"1", "A"}) //"Não Processado"
aAdd(aDePara, {"2", "B"}) //"Conciliado Normal"
aAdd(aDePara, {"3", "C"}) //"Venda Conciliada Parcialmente"
aAdd(aDePara, {"4", "D"}) //"Divergente"
aAdd(aDePara, {"5", "E"}) //"Venda Conciliada com Critica"
aAdd(aDePara, {"6", "F"}) //"Titulo sem Registro de Venda"
aAdd(aDePara, {"7", "G"}) //"Registro de Venda sem Titulo"

If !Empty(cStVenb)
	If lEstorno
		nP := 2
		nR := 1
	Else
		nP := 1
		nR := 2
	EndIf
	nLin := aScan(aDePara, { |x| x[nP] == Alltrim(cStVenb) })
	If nLin > 0
		cRet := aDePara[nLin][nR]
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fSoma1
Soma da Ordem dos Campos

@type function
@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static Function fSoma1(cOrdem As Character) As Character

Default cOrdem := ""

	If !Empty(cOrdem)
		cOrdem := Soma1(cOrdem)
	EndIf

Return cOrdem


//-------------------------------------------------------------------
/*/{Protheus.doc} AtuModelFIF
Atualiza o model FIF após efetivar a baixa individual do título

@type function
@author Totvs
@since 22/12/2020

/*/
//-------------------------------------------------------------------
Static Function AtuModelFIF(oSubFIF as Object, oSubSE1 as object, cStatus as Character) As Logical
Local lRetorno 	as Logical

Default oSubFIF := Nil
Default oSubSE1 := Nil
Default cStatus := ""

lRetorno := .F.

If oSubFIF != Nil
	DbSelectArea("FIF")
	FIF->(DbGoTo(oSubFIF:GetValue("FIF_RECNO")))						
	If FIF->(!Eof())

		Reclock("FIF",.F.)
		FIF->FIF_STATUS := IIf(FIF->FIF_STATUS == '6', IIf(cStatus =="4","8","7"), cStatus)
		FIF->FIF_PGJUST := oSubFIF:GetValue("FIF_PGJUST")
		FIF->FIF_PGDES1 := oSubFIF:GetValue("FIF_PGDES1")
		FIF->FIF_PGDES2 := oSubFIF:GetValue("FIF_PGDES2")
		FIF->FIF_USUPAG := RetCodUsr()
		FIF->FIF_DTPAG  := dDatabase

		If oSubSE1 != Nil
			FIF->FIF_PREFIX := oSubSE1:GetValue("E1_PREFIXO")
			FIF->FIF_NUM 	:= oSubSE1:GetValue("E1_NUM")	
			FIF->FIF_PARC 	:= oSubSE1:GetValue("E1_PARCELA")	
			FIF->FIF_TIPO   := oSubSE1:GetValue("E1_TIPO")
		EndIf

		FIF->(MsUnlock())

		lRetorno := .T.
	EndIf	
EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} F920VldAmb
Verifica se o ambiente esta atualizado/configurado para utilizar o 
recurso solicitado

@type function
@author fabio.casagrande
@since 07/10/2021

/*/
//-------------------------------------------------------------------
Static Function F920VldAmb() As Logical

Local lRetorno As Logical

lRetorno := .T.

	//Verifica os pré-requisitos para utilização da conciliação
	If SE1->(Fieldpos("E1_MSFIL")) == 0 .Or. MEP->(Fieldpos("MEP_MSFIL")) == 0  
		// "Há campos necessários para execução dessa rotina que não foram localizados na base de dados"
		Help(" ",1,"A918NOFIELDS",,STR0266 ,1,0,,,,,,{STR0267}) 
		// "Avalie a documentação disponível no TDN para configurar o Conciliador SITEF (http://tdn.totvs.com/x/WAE_Cw)"
		lRetorno := .F.
	EndIf 	

	//Verifica o compartilhamento das tabelas SE1 e MEP
	If AliasInDic("MEP") .And. (xFilial("SE1") <> xFilial("MEP"))
		//"Compartilhamento incorreto entre as tabelas SE1 e MEP"
		Help(" ",1,"A918Compart",,STR0114 ,1,0,,,,,,)
		//"Para utilizar o Conciliador SiTEF múltiplos cartões, faz-se necessário que as tabelas SE1 e MEP possuam mesma forma de compartilhamento."    
		lRetorno := .F.
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} F920RemCpo
Retorna os campos do contexto TEF que devem ser removidos do
contexto PIX/Pagamentos Digitais.

@type function
@author fabio.casagrande
@since 24/11/2021

@param cTable   , character, escolhe qual tabela esta sendo avaliada (FIF ou SE1)
@param lPlanilha, logical  , Se verdadeiro retorna os campso para o contexto de planilha
@return array, lista contendo os campos
/*/
//-------------------------------------------------------------------
Static Function F920RemCpo(cTable As Character, lPlanilha As Logical) As Array
Local aRetCpo := {}

Default cTable    := "FIF"
Default lPlanilha := .F.

	If Alltrim(cTable) == "FIF"
		If lPlanilha			
			aRetCpo := {"FIF_NSUTEF","FIF_CODAUT","FIF_CODADM","FIF_NSUARQ","FIF_CODLOJ","FIF_CODBAN","FIF_INTRAN",;
							"FIF_NURESU","FIF_NUCART","FIF_TOTPAR","FIF_CAPTUR","FIF_CODRED","FIF_ARQVEN","FIF_SEQREG","FIF_VLCOM"}
		Else
			aRetCpo := {"FIF_NSUTEF","FIF_CODAUT","FIF_CODADM","FIF_NSUARQ","FIF_CODLOJ","FIF_CODBAN","FIF_NURESU","FIF_NUCART","FIF_VLCOM"}			
		Endif
	Elseif Alltrim(cTable) == "SE1"
		If lPlanilha
			aRetCpo := {"E1_NSUTEF","E1_CARTAUT"}
		Else
			aRetCpo := {"E1_NSUTEF","OK"}
		Endif
	Endif

Return aRetCpo

//-------------------------------------------------------------------
/*/{Protheus.doc} F920RetCbx
Retorna o combobox 'virtual' dos campos que nao possuem isso no dicionario,
porém foram setados direto no MVC

@type function
@author fabio.casagrande
@since 24/11/2021
@param cCampo, character, campo a ser considerado para retornar o combo
@return array, lista os combobox no memso formato de gravação do X3_CBOX

/*/
//-------------------------------------------------------------------
Static Function F920RetCbx(cCampo As Character) As Array
Local aRetCbx As Array

Default cCampo := ""

aRetCbx := {}

	If Alltrim(cCampo) == "FIF_TPPROD"
		If __lTef
			aRetCbx := { STR0282, STR0283 }
		Else
			aRetCbx := { STR0284, STR0285 }	
		Endif
	Endif

Return aRetCbx

//-------------------------------------------------------------------
/*/{Protheus.doc} F920GetCbx
Retorna o conteudo do combobox virtual que foi setado direto no MVC

@type function
@author fabio.casagrande
@since 24/11/2021
@param  cCampo    , character, campo a ser considerado para retornar o combo
@param  cConteudo , character, conteudo do campo para ser obtido sua descrição no combo
@return character, descrição do combobox

/*/
//-------------------------------------------------------------------
Static Function F920GetCbx(cCampo As Character, cConteudo As Character) As Character
Local cDescricao As Character

Default cCampo    := ""
Default cConteudo := ""

cDescricao := ""

	If Alltrim(cCampo) == "FIF_TPPROD"
		If __lTef
			cDescricao := If(Alltrim(cConteudo) == "C", "Credito", "Debito")
		Else
			cDescricao := If(Alltrim(cConteudo) == "X", "PIX", "Carteiras Digitais")
		Endif
	Endif

Return cDescricao

//-------------------------------------------------------------------
/*/{Protheus.doc} F920aFields
Retorna os campos que estarão presentes na tabela temporária.

@type       function
@author     Rafael Riego
@since      21/03/2022
@return     array, array dos campos que estarão presentes na tabela temporária.
/*/
//-------------------------------------------------------------------
Function F920aFields(cAlias As Character) As Array
	Local aFields   As Array
	Local aStruct   As Array

	Default cAlias := "FIF"

    aFields := {}

	If cAlias == "FIF"
		aStruct := FIF->(DbStruct())
		AEval(aStruct, { |campo| If(campo[DBS_NAME] $ __cCpoFIF, AAdd(aFields, AClone(campo)), Nil) })	
		
		AAdd(aFields, {"XPARCEL",	"C", 	3,		0} )
	Else
		aStruct := SE1->(DbStruct())
		AEval(aStruct, { |campo| If(campo[DBS_NAME] $ __cCpoSE1, AAdd(aFields, AClone(campo)), Nil) })
	EndIf	

	AAdd(aFields, {"RECNO", 	"N", 	10, 	0} )
	AAdd(aFields, {"ABA", 		"N", 	1, 		0} )

    FwFreeArray(aStruct)

Return aFields

//-------------------------------------------------------------------
/*/{Protheus.doc} F920TmpAbas
Efetua a criação da tabela temporária.

@type       function
@author     sidney.silva
@since      21/03/2022
@param  nFolder , numeric, campo contendo o código da aba que será filtrada
@param  cAlias , character, alias usado para filtrar as grids da aba 4 (Não Conciliados)
@return cAliasAbas , character, alias da tabela temporária 
/*/
//-------------------------------------------------------------------
Static Function F920TmpAbas(nFolder As Numeric, cAlias As Character) As Character
	Local cAliasAbas	As Character
	Local cInsert		As Character
	Local cValues		As Character
	Local aFields   	As Array

	Default nFolder := 0
	Default cAlias  := "FIF"

	cAliasAbas := ""
	
	If nFolder > 0
		Do Case
			Case nFolder == 1 // Conciliados

				__oAba1 := FwTemporaryTable():New()

				aFields := F920aFields("FIF")   

				__oAba1:SetFields(aFields)				

				__oAba1:Create()
				
				cAliasAbas  := __oAba1:GetAlias()

				cValues := StrTran(StrTran(__cCpoFIF,"|OK", ""), "|", ", ")

				cValues := SubStr(cValues, 2)	
				
				cInsert := " INSERT "

				If __lOracle
					cInsert += "/*+ APPEND */ "
				EndIf

				cInsert += " INTO " + __oAba1:GetRealName()  + " ( " + cValues

				If __lMEP .And. __lUsaMep .And. __lTef
					cInsert += ", XPARCEL "
				EndIf

				cInsert += ", RECNO, ABA) "

				cInsert += " SELECT " 
				
				If __lSQL
					cInsert += " TOP 10000 "
				EndIf

				cInsert +=  cValues 

				If __lMEP .And. __lUsaMep .And. __lTef
					cInsert += ", MEP_PARCEL XPARCEL"
				EndIf

				cInsert += ", FIF.R_E_C_N_O_ RECNO, 1 ABA "
				cInsert += " FROM " + RetSQLName("FIF") + " FIF "
				cInsert += " INNER JOIN " + RetSQLName("SE1") + " SE1 "
				cInsert += " ON SE1.D_E_L_E_T_ = ' ' "
				cInsert += " AND FIF_DTTEF = E1_EMISSAO "				
				cInsert += " AND (FIF_CODAUT = E1_CARTAUT OR FIF_CODAUT = '') "

				If __lOracle .Or. __lPostGre
					cInsert += " AND FIF_TPPROD = SUBSTR(E1_TIPO, 2, 1) "
				Else 
					cInsert += " AND FIF_TPPROD = SUBSTRING(E1_TIPO, 2, 1) "
				EndIf

				If __lTef
					cInsert += " AND FIF_CODFIL = E1_MSFIL "
				EndIf

				If __lPixDig
					cInsert += " AND FIF_CODFIL = E1_FILORIG "
					cInsert += " AND FIF_NUCOMP = E1_DOCTEF "
				ElseIf __lPrcDocT
					If __lOracle .Or. __lPostGre
						cInsert += " AND LPAD(TRIM(FIF_NUCOMP), " + __cTamDoc + ", '0') = LPAD(TRIM(E1_DOCTEF), " + __cTamDoc + ", '0') "
					Else
						cInsert += " AND REPLICATE('0', " + __cTamDoc + " - LEN(FIF_NUCOMP)) + RTrim(FIF_NUCOMP) = REPLICATE('0', " + __cTamDoc + " - LEN(E1_DOCTEF)) + RTrim(E1_DOCTEF) "
					EndIf	
				Else					
					If __lOracle .Or. __lPostGre
						cInsert += " AND LPAD(TRIM(FIF_NSUTEF), " + __cTamNSU + ", '0') = LPAD(TRIM(E1_NSUTEF), " + __cTamNSU + ", '0') "
					Else
						cInsert += " AND REPLICATE('0', " + __cTamNSU + " - LEN(FIF_NSUTEF)) + RTrim(FIF_NSUTEF) = REPLICATE('0', " + __cTamNSU + " - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) "
					EndIf
				EndIf

				If __lTef
					If __lMEP .And. __lUsaMep
						cInsert += " INNER JOIN " + RetSQLName("MEP") + " MEP " 
						cInsert += " ON E1_FILIAL = MEP_FILIAL "
						cInsert += " AND E1_PREFIXO = MEP_PREFIX "
						cInsert += " AND E1_NUM = MEP_NUM "
						cInsert += " AND E1_PARCELA = MEP_PARCEL "
						cInsert += " AND E1_TIPO = MEP_TIPO "			
						cInsert += " AND MEP.D_E_L_E_T_ = ' ' "
						cInsert += " AND FIF_PARCEL = MEP_PARTEF "
						
					Else
						If __lParcFIF
							cInsert += " AND FIF_PARALF = E1_PARCELA "
						Else
							cInsert += " AND FIF_PARCEL = E1_PARCELA "
						EndIf
					EndIf
				EndIf

				cInsert += " WHERE FIF.D_E_L_E_T_ = ' ' "
				cInsert += " AND SE1.D_E_L_E_T_ = ' ' "
				cInsert += " AND FIF_STATUS IN ('1','3','6') "

				If __lSOFEX
					cInsert += " AND FIF_CODFIL BETWEEN '" + __cFilIni + "' AND '" + __cFilFim + "' "
				Else
					If __nSelFil == 1 .And. Len(__aSelFil) > 0
						cInsert += " AND FIF_CODFIL " + GetRngFil( __aSelFil, 'FIF', .T.,, 20, .T. ) + " "
					Else
						cInsert += " AND FIF_CODFIL = '" + __cFilAnt + "' "
					EndIf
				EndIf

				If __lPixDig
					If __nTpPagam == 1  
						cInsert += " AND FIF_TPPROD = 'X' "
					ElseIf __nTpPagam == 2
						cInsert += " AND FIF_TPPROD = 'D' "
					Else
						cInsert += " AND FIF_TPPROD IN ('X','D') "
					EndIf

					cInsert += " AND FIF_TPREG <> '3' "
				Else
					If __nTpPagam == 1
						cInsert += " AND FIF_TPPROD = 'D' "
					ElseIf __nTpPagam == 2
						cInsert += " AND FIF_TPPROD = 'C' "
					Else
						cInsert += " AND FIF_TPPROD IN ('D','C') "
					EndIf						
				EndIf

				If __lPixDig
					cInsert += " AND E1_DOCTEF <> ' ' "
					cInsert += " AND (FIF_NUCOMP BETWEEN '" + __cNsuIni + "' AND '" + __cNsuFim + "') "
				ElseIf __lPrcDocT
					cInsert += " AND E1_DOCTEF <> ' ' "
					cInsert += " AND ((FIF_NUCOMP BETWEEN '" + __cNsuIni1 + "' AND '" + __cNsuFim1 + "') "
					cInsert += " OR (FIF_NUCOMP BETWEEN '" + __cNsuIni + "' AND '" + __cNsuFim + "')) "
				Else
					cInsert += " AND E1_NSUTEF <> ' ' "
					cInsert += " AND ((FIF_NSUTEF BETWEEN '" + __cNsuIni1 + "' AND '" + __cNsuFim1 + "') "
					cInsert += " OR (FIF_NSUTEF BETWEEN '" + __cNsuIni + "' AND '" + __cNsuFim + "')) "
				EndIf

				If !Empty(__cAdmIni)			
					If __lSOFEX
						cInsert += " AND FIF_CODRED >= '" + __cAdmIni + "' "
						If !Empty(__cAdmFim)
							cInsert += " AND FIF_CODRED <= '" + __cAdmFim + "' "
						EndIf
					Else
						cInsert += " AND FIF_CODADM IN " + __cAdmIni + " "		
					EndIf
				EndIf

				If __lTef .And. __lAPixTpd 
					cInsert += " AND FIF_MODPAG IN (' ','1') "
				ElseIf __lAPixTpd
					cInsert += " AND FIF_MODPAG = '2' "
				EndIf		

				cInsert += " AND E1_SALDO > 0 "

				cInsert += " AND FIF_DTCRED >= '" + DToS(__dDtCredI) + "' "
				cInsert += " AND FIF_DTCRED <= '" + DToS(__dDtCredF) + "' "

				If __lOracle 
					cInsert += " AND ROWNUM <= " + STR(GRIDMAXLIN) + " "
				EndIf

				cInsert += " AND FIF_VLLIQ >= (E1_SALDO * " + Alltrim(Str(__nMargem)) + ") "

				If __lPostGre
					cInsert += " LIMIT 10000"
				EndIf 

			Case nFolder == 2 // Conciliados Parcialmente

				__oAba2 := FwTemporaryTable():New()

				aFields := F920aFields("FIF")

				__oAba2:SetFields(aFields)				

				__oAba2:Create()
				
				cAliasAbas  := __oAba2:GetAlias()

				cValues := StrTran(StrTran(__cCpoFIF,"|OK", ""), "|", ", ")

				cValues := SubStr(cValues, 2)	
				
				cInsert := " INSERT "

				If __lOracle
					cInsert += " /*+ APPEND */ "
				EndIf

				cInsert += " INTO " + __oAba2:GetRealName() + " ( " + cValues

				If __lMEP .And. __lUsaMep .And. __lTef
					cInsert += ", XPARCEL"
				EndIf

				cInsert += ", RECNO, ABA) "

				cInsert += " SELECT "

				If __lSQL
					cInsert += " TOP 10000 "
				EndIf

				cInsert +=  cValues 

				If __lMEP .And. __lUsaMep .And. __lTef
					cInsert += ", MEP_PARCEL XPARCEL "
				EndIf

				cInsert += ", FIF.R_E_C_N_O_ RECNO, 2 ABA "
				cInsert += " FROM " + RetSQLName("FIF") + " FIF "
				cInsert += " INNER JOIN " + RetSQLName("SE1") + " SE1 "
				cInsert += " ON SE1.D_E_L_E_T_ = ' ' "
				cInsert += " AND FIF_DTTEF = E1_EMISSAO "				
				cInsert += " AND (FIF_CODAUT = E1_CARTAUT OR FIF_CODAUT = '') "

				If __lOracle .Or. __lPostGre
					cInsert += " AND FIF_TPPROD = SUBSTR(E1_TIPO, 2, 1) "
				Else 
					cInsert += " AND FIF_TPPROD = SUBSTRING(E1_TIPO, 2, 1) "
				EndIf

				If __lTef
					cInsert += " AND FIF_CODFIL = E1_MSFIL "
				EndIf

				If __lPixDig
					cInsert += " AND FIF_CODFIL = E1_FILORIG "
					cInsert += " AND FIF_NUCOMP = E1_DOCTEF "
				ElseIf __lPrcDocT
					cInsert += " AND E1_DOCTEF <> ' ' "
					If __lOracle .Or. __lPostGre
						cInsert += " AND LPAD(TRIM(FIF_NUCOMP), " + __cTamDoc + ", '0') = LPAD(TRIM(E1_DOCTEF), " + __cTamDoc + ", '0') "
					Else
						cInsert += " AND REPLICATE('0', " + __cTamDoc + " - LEN(FIF_NUCOMP)) + RTrim(FIF_NUCOMP) = REPLICATE('0', " + __cTamDoc + " - LEN(E1_DOCTEF)) + RTrim(E1_DOCTEF) "
					EndIf	
				Else	
					cInsert += " AND E1_NSUTEF <> ' ' "
					If __lOracle .Or. __lPostGre
						cInsert += " AND LPAD(TRIM(FIF_NSUTEF), " + __cTamNSU + ", '0') = LPAD(TRIM(E1_NSUTEF), " + __cTamNSU + ", '0') "
					Else
						cInsert += " AND REPLICATE('0', " + __cTamNSU + " - LEN(FIF_NSUTEF)) + RTrim(FIF_NSUTEF) = REPLICATE('0', " + __cTamNSU + " - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) "
					EndIf
				EndIf

				If __lTef
					If __lMEP .And. __lUsaMep
						cInsert += " INNER JOIN " + RetSQLName("MEP") + " MEP " 
						cInsert += " ON E1_FILIAL = MEP_FILIAL "
						cInsert += " AND E1_PREFIXO = MEP_PREFIX "
						cInsert += " AND E1_NUM = MEP_NUM "
						cInsert += " AND E1_PARCELA = MEP_PARCEL "
						cInsert += " AND E1_TIPO = MEP_TIPO "			
						cInsert += " AND MEP.D_E_L_E_T_ = ' ' "
						cInsert += " AND FIF_PARCEL = MEP_PARTEF "
						
					Else
						If __lParcFIF
							cInsert += " AND FIF_PARALF = E1_PARCELA "
						Else
							cInsert += " AND FIF_PARCEL = E1_PARCELA "
						EndIf
					EndIf	
				EndIf

				cInsert += " WHERE FIF.D_E_L_E_T_ = ' ' "
				cInsert += " AND SE1.D_E_L_E_T_ = ' ' "
				cInsert += " AND FIF_STATUS IN ('1','3','4','6') "

				If __lSOFEX
					cInsert += " AND FIF_CODFIL BETWEEN '" + __cFilIni + "' AND '" + __cFilFim + "' "
				Else
					If __nSelFil == 1 .And. Len(__aSelFil) > 0
						cInsert += " AND FIF_CODFIL " + GetRngFil( __aSelFil, 'FIF', .T.,, 20, .T. ) + " "
					Else
						cInsert += " AND FIF_CODFIL = '" + __cFilAnt + "' "
					EndIf
				EndIf

				If __lPixDig
					If __nTpPagam == 1  
						cInsert += " AND FIF_TPPROD = 'X' "
					ElseIf __nTpPagam == 2
						cInsert += " AND FIF_TPPROD = 'D' "
					Else
						cInsert += " AND FIF_TPPROD IN ('X','D') "
					EndIf

					cInsert += " AND FIF_TPREG <> '3' "
				Else
					If __nTpPagam == 1
						cInsert += " AND FIF_TPPROD = 'D' "
					ElseIf __nTpPagam == 2
						cInsert += " AND FIF_TPPROD = 'C' "
					Else
						cInsert += " AND FIF_TPPROD IN ('D','C') "
					EndIf						
				EndIf

				If __lPixDig
					cInsert += " AND E1_DOCTEF <> ' ' "
					cInsert += " AND (FIF_NUCOMP BETWEEN '" + __cNsuIni + "' AND '" + __cNsuFim + "') "
				ElseIf __lPrcDocT
					cInsert += " AND E1_DOCTEF <> ' ' "
					cInsert += " AND ((FIF_NUCOMP BETWEEN '" + __cNsuIni1 + "' AND '" + __cNsuFim1 + "') "
					cInsert += " OR (FIF_NUCOMP BETWEEN '" + __cNsuIni + "' AND '" + __cNsuFim + "')) "
				Else
					cInsert += " AND E1_NSUTEF <> ' ' "
					cInsert += " AND ((FIF_NSUTEF BETWEEN '" + __cNsuIni1 + "' AND '" + __cNsuFim1 + "') "
					cInsert += " OR (FIF_NSUTEF BETWEEN '" + __cNsuIni + "' AND '" + __cNsuFim + "')) "
				EndIf

				If !Empty(__cAdmIni)
					If __lSOFEX
						cInsert += " AND FIF_CODRED >= '" + __cAdmIni + "' "
						If !Empty(__cAdmFim)
							cInsert += " AND FIF_CODRED <= '" + __cAdmFim + "' "
						EndIf
					Else
						cInsert += " AND FIF_CODADM IN " + __cAdmIni + " "		
					EndIf
				EndIf

				If __lTef .And. __lAPixTpd 
					cInsert += " AND FIF_MODPAG IN (' ','1') "
				ElseIf __lAPixTpd
					cInsert += " AND FIF_MODPAG = '2' "
				EndIf

				cInsert += " AND E1_SALDO > 0 "

				cInsert += " AND FIF_DTCRED >= '" + DToS(__dDtCredI) + "' "
				cInsert += " AND FIF_DTCRED <= '" + DToS(__dDtCredF) + "' "

				If __lOracle 
					cInsert += " AND ROWNUM <= " + STR(GRIDMAXLIN) + " "
				EndIf				

				cInsert += " AND FIF_VLLIQ < (E1_SALDO) * " + Alltrim(Str(__nMargem)) + " "

				If __lPostGre
					cInsert += " LIMIT 10000"
				EndIf 

			Case nFolder == 3 // Conciliados Manualmente

				__oAba3 := FwTemporaryTable():New()

				aFields := F920aFields("FIF")

				__oAba3:SetFields(aFields)				

				__oAba3:Create()
				
				cAliasAbas  := __oAba3:GetAlias()

				cValues := StrTran(StrTran(__cCpoFIF,"|OK", ""), "|", ", ")
				cValues := SubStr(cValues, 2)	
				
				cInsert := " INSERT "

				If __lOracle
					cInsert += " /*+ APPEND */ "
				EndIf

				cInsert += " INTO " + __oAba3:GetRealName()  + " ( " + cValues
				cInsert += ", RECNO, ABA) "

				cInsert += " SELECT " 
				
				If __lSQL
					cInsert += " TOP 10000 "
				EndIf

				cInsert +=  cValues + ", FIF.R_E_C_N_O_ RECNO, 3 ABA "

				cInsert += "FROM " + RetSQLName("FIF") + " FIF "

				cInsert += "WHERE FIF.D_E_L_E_T_ = ' ' "
				
				If __lSOFEX
					cInsert += " AND FIF_CODFIL BETWEEN '" + __cFilIni + "' AND '" + __cFilFim + "' "
				Else
					If __nSelFil == 1 .And. Len( __aSelFil ) > 0
						cInsert += " AND FIF_CODFIL " + GetRngFil( __aSelFil, 'FIF', .T.,, 20, .T. ) + " "
					Else
						cInsert += " AND FIF_CODFIL = '" + __cFilAnt + "' "
					EndIf
				EndIf	

				cInsert += " AND FIF_DTCRED >= '" + DToS(__dDtCredI) + "' "
				cInsert += " AND FIF_DTCRED <= '" + DToS(__dDtCredF) + "' "				

				If __lPixDig
					cInsert += " AND (FIF_NUCOMP BETWEEN '" + __cNsuIni + "' AND '" + __cNsuFim + "') "
				ElseIf __lPrcDocT
					cInsert += " AND ((FIF_NUCOMP BETWEEN '" + __cNsuIni1 + "' AND '" + __cNsuFim1 + "') "
					cInsert += " OR (FIF_NUCOMP BETWEEN '" + __cNsuIni + "' AND '" + __cNsuFim + "')) "
				Else
					cInsert += " AND ((FIF_NSUTEF BETWEEN '" + __cNsuIni1 + "' AND '" + __cNsuFim1 + "') "
					cInsert += " OR (FIF_NSUTEF BETWEEN '" + __cNsuIni + "' AND '" + __cNsuFim + "')) "
				EndIf

				If __lPixDig
					If __nTpPagam == 1  
						cInsert += " AND FIF_TPPROD = 'X' "
					ElseIf __nTpPagam == 2
						cInsert += " AND FIF_TPPROD = 'D' "
					Else
						cInsert += " AND FIF_TPPROD IN ('X','D') "
					EndIf
				Else
					If __nTpPagam == 1
						cInsert += " AND FIF_TPPROD = 'D' "
					ElseIf __nTpPagam == 2
						cInsert += " AND FIF_TPPROD = 'C' "
					Else
						cInsert += " AND FIF_TPPROD IN ('D','C') "
					EndIf
				EndIf

				If !Empty(__cAdmIni) 
			
					If __lSOFEX
						cInsert += " AND FIF_CODRED >= '" + __cAdmIni + "' "
						If !Empty(__cAdmFim)
							cInsert += " AND FIF_CODRED <= '" + __cAdmFim + "' "
						EndIf
					Else
						cInsert += " AND FIF_CODADM IN " + __cAdmIni + " "		
					EndIf
				EndIf
				
				If __lOracle 
					cInsert += " AND ROWNUM <= " + STR(GRIDMAXLIN) + " "
				EndIf

				cInsert += " AND FIF_STATUS IN ('4','8') "

				If __lPostGre
					cInsert += " LIMIT 10000 "
				EndIf 

			Case nFolder == 4 // Não Conciliados

				Do Case
				Case cAlias == "FIF"

					__oAba4FIF := FwTemporaryTable():New()

					aFields := F920aFields("FIF")

					__oAba4FIF:SetFields(aFields)				

					__oAba4FIF:Create()
					
					cAliasAbas  := __oAba4FIF:GetAlias()

					cValues := StrTran(StrTran(__cCpoFIF, "|OK", ""), "|", ", ")
					
					cValues := SubStr(cValues, 2)	
					
					cInsert := " INSERT "

					If __lOracle
						cInsert += " /*+ APPEND */ "
					EndIf

					cInsert += " INTO " + __oAba4FIF:GetRealName()  + " ( " + cValues

					cInsert += ", RECNO, ABA) "

					cInsert += " SELECT " 
					
					If __lSQL
						cInsert += " TOP 10000 "
					EndIf

					cInsert +=  cValues 

					cInsert += ", FIF.R_E_C_N_O_ RECNO, 4 ABA "
					cInsert += " FROM " + RetSQLName("FIF") + " FIF "
					
					If __lPixDig
						cInsert += " LEFT JOIN " + RetSqlName("FJU") + " FJU "
						cInsert += " ON FIF_NUCOMP = FJU_DOCTEF "
						cInsert += " AND FIF_DTTEF = FJU_EMIS"
						cInsert += " AND FIF_CODFIL = FJU_FILIAL"
					EndIf

					cInsert += " WHERE FIF.D_E_L_E_T_ = ' ' "

					If __lSOFEX
						cInsert += " AND FIF_CODFIL BETWEEN '" + __cFilIni + "' AND '" + __cFilFim + "' "
					Else
						If __nSelFil == 1 .And. Len(__aSelFil) > 0
							cInsert += " AND FIF_CODFIL " + GetRngFil( __aSelFil, 'FIF', .T.,, 20, .T. ) + " "
						Else
							cInsert += " AND FIF_CODFIL = '" + __cFilAnt + "' "
						EndIf
					EndIf

					If !Empty(__cAdmIni) 			
						If __lSOFEX
							cInsert += " AND FIF_CODRED >= '" + __cAdmIni + "' "
							If !Empty(__cAdmFim)
								cInsert += " AND FIF_CODRED <= '" + __cAdmFim + "' "
							EndIf
						Else
							cInsert += " AND FIF_CODADM IN " + __cAdmIni + " "		
						EndIf
					EndIf

					cInsert += " AND FIF_DTCRED >= '" + DToS(__dDtCredI) + "' "
					cInsert += " AND FIF_DTCRED <= '" + DToS(__dDtCredF) + "' "	

					If __lPixDig
						cInsert += " AND (FIF_NUCOMP BETWEEN '" + __cNsuIni + "' AND '" + __cNsuFim + "') "
					ElseIf __lPrcDocT
						cInsert += " AND ((FIF_NUCOMP BETWEEN '" + __cNsuIni1 + "' AND '" + __cNsuFim1 + "') "
						cInsert += " OR (FIF_NUCOMP BETWEEN '" + __cNsuIni + "' AND '" + __cNsuFim + "')) "
					Else
						cInsert += " AND ((FIF_NSUTEF BETWEEN '" + __cNsuIni1 + "' AND '" + __cNsuFim1 + "') "
						cInsert += " OR (FIF_NSUTEF BETWEEN '" + __cNsuIni + "' AND '" + __cNsuFim + "')) "
					EndIf

					cInsert += " AND FIF_STATUS IN ('1','3','4','6') "

					If __lPixDig
						If __nTpPagam == 1  
							cInsert += " AND FIF_TPPROD = 'X' "
						ElseIf __nTpPagam == 2
							cInsert += " AND FIF_TPPROD = 'D' "
						Else
							cInsert += " AND FIF_TPPROD IN ('X','D') "
						EndIf
				
						cInsert += " AND FIF_TPREG <> '3' "
					Else
						If __nTpPagam == 1
							cInsert += " AND FIF_TPPROD = 'D' "
						ElseIf __nTpPagam == 2
							cInsert += " AND FIF_TPPROD = 'C' "
						Else
							cInsert += " AND FIF_TPPROD IN ('D','C') "
						EndIf				
					EndIf

					If __lTef .And. __lAPixTpd 
						cInsert += " AND FIF_MODPAG IN (' ','1') "
					ElseIf __lAPixTpd
						cInsert += " AND FIF_MODPAG = '2' "
					EndIf

					cInsert += " AND FIF.R_E_C_N_O_ NOT IN "
					cInsert += " ( SELECT RECNO "	
					cInsert += " FROM "	+ __oAba1:GetRealName() + ") "

					cInsert += " AND FIF.R_E_C_N_O_ NOT IN "
					cInsert += " ( SELECT RECNO "	
					cInsert += " FROM "	+ __oAba2:GetRealName() + ") "

					If __lOracle 
						cInsert += " AND ROWNUM <= " + STR(GRIDMAXLIN) + " "
					EndIf

					If __lPostGre
						cInsert += " LIMIT 10000 "
					EndIf 
								
				Case cAlias == "SE1"

					__oAba4SE1 := FwTemporaryTable():New()

					aFields := F920aFields("SE1")

					__oAba4SE1:SetFields(aFields)				

					__oAba4SE1:Create()
					
					cAliasAbas  := __oAba4SE1:GetAlias()

					cValues := StrTran(StrTran(__cCpoSE1, "|OK", ""), "|", ", ")
					
					cValues := SubStr(cValues, 2)	
					
					cInsert := " INSERT "

					If __lOracle
						cInsert += " /*+ APPEND */ "
					EndIf

					cInsert += " INTO " + __oAba4SE1:GetRealName()  + " ( " + cValues

					cInsert += ", RECNO, ABA) "
					cInsert += " SELECT "

					If __lSQL
						cInsert += " TOP 10000 "
					EndIf

					cInsert +=  cValues 

					cInsert += ", SE1.R_E_C_N_O_ RECNO, 4 ABA "
					cInsert += " FROM " + RetSQLName("SE1") + " SE1 "
					cInsert += " WHERE SE1.D_E_L_E_T_ = ' ' "

					If __lSOFEX
						cInsert += " AND E1_FILORIG BETWEEN '" + __cFilIni + "' AND '" + __cFilFim + "' "
					Else
						If __nSelFil == 1 .And. Len(__aSelFil) > 0
							cInsert += " AND E1_FILORIG " + GetRngFil( __aSelFil, 'SE1', .T.,, 20, .T. ) + " "
						EndIf
					EndIf

					cInsert += " AND E1_VENCREA >= '" + DToS(__dDtCredI - __nQtdDias) + "' " 
					cInsert += " AND E1_VENCREA <= '" + DToS(__dDtCredF) + "' " 

					If __lPixDig
						cInsert += " AND E1_DOCTEF >= '" + __cNsuIni + "' "
						cInsert += " AND E1_DOCTEF <= '" + __cNsuFim + "' "
					ElseIf __lPrcDocT
						If __lOracle .Or. __lPostGre
							cInsert += " AND LPAD(TRIM(E1_DOCTEF), " + __cTamDoc + ", '0') >= '" + __cNsuIni + "' "
							cInsert += " AND LPAD(TRIM(E1_DOCTEF), " + __cTamDoc + ", '0') <= '" + __cNsuFim + "' "
						Else
							cInsert += " AND REPLICATE('0', " + __cTamDoc + " - LEN(E1_DOCTEF)) + RTrim(E1_DOCTEF) >= '" + __cNsuIni + "' "
							cInsert += " AND REPLICATE('0', " + __cTamDoc + " - LEN(E1_DOCTEF)) + RTrim(E1_DOCTEF) <= '" + __cNsuFim + "' "
						EndIf	
					Else
						If __lOracle .Or. __lPostGre
							cInsert += " AND LPAD(TRIM(E1_NSUTEF), " + __cTamNSU + ", '0') >= '" + __cNsuIni + "' "
							cInsert += " AND LPAD(TRIM(E1_NSUTEF), " + __cTamNSU + ", '0') <= '" + __cNsuFim + "' "
						Else
							cInsert += " AND REPLICATE('0', " + __cTamNSU + " - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) >= '" + __cNsuIni + "' "
							cInsert += " AND REPLICATE('0', " + __cTamNSU + " - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) <= '" + __cNsuFim + "' "
						EndIf
					EndIf

					If __lPixDig
						If __nTpPagam == 1  
							cInsert += " AND E1_TIPO = 'PX' "
						ElseIf __nTpPagam == 2
							cInsert += " AND E1_TIPO = 'PD' "
						Else
							cInsert += " AND E1_TIPO IN ('PX','PD') "
						EndIf
					Else
						If __nTpPagam == 1
							cInsert += " AND E1_TIPO = 'CD' "
						ElseIf __nTpPagam == 2
							cInsert += " AND E1_TIPO = 'CC' "
						Else
							cInsert += " AND E1_TIPO IN ('CD','CC') "
						EndIf				
					EndIf

					cInsert += " AND SE1.E1_SALDO > 0 "

					If __lPixDig
						cInsert += " AND E1_DOCTEF NOT IN "

						cInsert += " ( SELECT FIF_NUCOMP "
					ElseIf __lPrcDocT
						If __lOracle .Or. __lPostGre
							cInsert += " AND LPAD(TRIM(E1_DOCTEF), " + __cTamDOC + ", '0')  NOT IN "
						Else
							cInsert += " AND REPLICATE('0', " + __cTamDOC + " - LEN(E1_DOCTEF)) + RTrim(E1_DOCTEF) NOT IN "
						EndIf

						cInsert += " ( SELECT FIF_NUCOMP "
					Else
						If __lOracle .Or. __lPostGre
							cInsert += " AND LPAD(TRIM(E1_NSUTEF), " + __cTamNSU + ", '0')  NOT IN "
						Else
							cInsert += " AND REPLICATE('0', " + __cTamNSU + " - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) NOT IN "
						EndIf

						cInsert += " ( SELECT FIF_NSUTEF "	
					EndIf


					cInsert += " FROM "	+ __oAba1:GetRealName() + ") "	

					If __lPixDig
						cInsert += " AND E1_DOCTEF NOT IN "

						cInsert += " ( SELECT FIF_NUCOMP "
					ElseIf __lPrcDocT
						If __lOracle .Or. __lPostGre
							cInsert += " AND LPAD(TRIM(E1_DOCTEF), " + __cTamDOC + ", '0')  NOT IN "
						Else
							cInsert += " AND REPLICATE('0', " + __cTamDOC + " - LEN(E1_DOCTEF)) + RTrim(E1_DOCTEF) NOT IN "
						EndIf

						cInsert += " ( SELECT FIF_NUCOMP "
					Else
						If __lOracle .Or. __lPostGre
							cInsert += " AND LPAD(TRIM(E1_NSUTEF), " + __cTamNSU + ", '0')  NOT IN "
						Else
							cInsert += " AND REPLICATE('0', " + __cTamNSU + " - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) NOT IN "
						EndIf

						cInsert += " ( SELECT FIF_NSUTEF "	
					EndIf


					cInsert += " FROM "	+ __oAba2:GetRealName() + ") "	

					If __lOracle 
						cInsert += " AND ROWNUM <= " + STR(GRIDMAXLIN) + " "
					EndIf

					If __lPostGre
						cInsert += " LIMIT 10000 "
					EndIf 

				EndCase

			Case nFolder == 5 // DIVERGENTES

				__oAba5 := FwTemporaryTable():New()

				aFields := F920aFields("FIF")

				__oAba5:SetFields(aFields)				

				__oAba5:Create()
				
				cAliasAbas  := __oAba5:GetAlias()

				cValues := StrTran(StrTran(__cCpoFIF,"|OK", ""), "|", ", ")
				
				cValues := SubStr(cValues, 2)	
				
				cInsert := " INSERT "

				If __lOracle
					cInsert += " /*+ APPEND */ "
				EndIf

				cInsert += " INTO " + __oAba5:GetRealName()  + " ( " + cValues + ", RECNO, ABA) "
				cInsert += " SELECT " + cValues + ", FIF.R_E_C_N_O_ RECNO, 5 ABA "
				cInsert += " FROM " + RetSQLName("FIF") + " FIF "
				cInsert += " WHERE FIF.D_E_L_E_T_ = ' ' "
				cInsert += " AND FIF_STATUS IN ('1','6') "
				cInsert += " AND FIF_TPREG = '3' "

				If __lPixDig
					If __nTpPagam == 1  
						cInsert += " AND FIF_TPPROD = 'X' "
					ElseIf __nTpPagam == 2
						cInsert += " AND FIF_TPPROD = 'D' "
					Else
						cInsert += " AND FIF_TPPROD IN ('X','D') "
					EndIf					
				Else
					If __nTpPagam == 1
						cInsert += " AND FIF_TPPROD = 'D' "
					ElseIf __nTpPagam == 2
						cInsert += " AND FIF_TPPROD = 'C' "
					Else
						cInsert += " AND FIF_TPPROD IN ('D','C') "
					EndIf
				EndIf

				If __lSOFEX
					cInsert += " AND FIF_CODFIL BETWEEN '" + __cFilIni + "' AND '" + __cFilFim + "' "
				Else
					If __nSelFil == 1 .And. Len( __aSelFil ) > 0
						cInsert += " AND FIF_CODFIL " + GetRngFil( __aSelFil, 'FIF', .T.,, 20, .T. ) + " "
					Else
						cInsert += " AND FIF_CODFIL = '" + __cFilAnt + "' "
					EndIf
				EndIf

				cInsert += " AND FIF_DTCRED >= '" + DToS(__dDtCredI) + "' "
				cInsert += " AND FIF_DTCRED <= '" + DToS(__dDtCredF) + "' "

				If __lPixDig
					cInsert += " AND (FIF_NUCOMP BETWEEN '" + __cNsuIni + "' AND '" + __cNsuFim + "') "
				ElseIf __lPrcDocT
					cInsert += " AND ((FIF_NUCOMP BETWEEN '" + __cNsuIni1 + "' AND '" + __cNsuFim1 + "') "
					cInsert += " OR (FIF_NUCOMP BETWEEN '" + __cNsuIni + "' AND '" + __cNsuFim + "')) "
				Else
					cInsert += " AND ((FIF_NSUTEF BETWEEN '" + __cNsuIni1 + "' AND '" + __cNsuFim1 + "') "
					cInsert += " OR (FIF_NSUTEF BETWEEN '" + __cNsuIni + "' AND '" + __cNsuFim + "')) "
				EndIf

				If !Empty(__cAdmIni) 			
					If __lSOFEX
						cInsert += " AND FIF_CODRED >= '" + __cAdmIni + "' "
						If !Empty(__cAdmFim)
							cInsert += " AND FIF_CODRED <= '" + __cAdmFim + "' "
						EndIf
					Else
						cInsert += " AND FIF_CODADM IN " + __cAdmIni + " "		
					EndIf
				EndIf

			Case __lPixDig .And. nFolder == 7 // ESTORNADOS

				__oAba7 := FwTemporaryTable():New()

				aFields := F920aFields("FIF")   

				__oAba7:SetFields(aFields)				

				__oAba7:Create()
				
				cAliasAbas  := __oAba7:GetAlias()

				cValues := StrTran(StrTran(__cCpoFIF,"|OK", ""), "|", ", ")

				cValues := SubStr(cValues, 2)	
				
				cInsert := " INSERT "

				If __lOracle
					cInsert += " /*+ APPEND */"
				EndIf

				cInsert += " INTO " + __oAba7:GetRealName()  + " ( " + cValues
				cInsert += ", RECNO, ABA) "

				cInsert += " SELECT " + cValues 
				cInsert += ", FIF.R_E_C_N_O_ RECNO, 7 ABA "
				cInsert += " FROM " + RetSQLName("FIF") + " FIF "
				cInsert += " INNER JOIN " + RetSQLName("FJU") + " FJU "
				cInsert += " ON FIF.FIF_NUCOMP = FJU.FJU_DOCTEF "
				cInsert += " AND FIF_DTTEF = FJU_EMIS "

				If __lOracle .Or. __lPostGre
					cInsert += " AND SUBSTR(FJU_TIPO, 2, 1) = FIF_TPPROD
				Else 
					cInsert += " AND SUBSTRING(FJU_TIPO, 2, 1) = FIF_TPPROD
				EndIf

				cInsert += " WHERE FIF.D_E_L_E_T_ = ' ' "
				cInsert += " AND FJU.D_E_L_E_T_ = ' ' "
				cInsert += " AND FIF_STATUS IN ('1','3','6') "
				cInsert += " AND FIF_TPREG <> '3' "
				cInsert += " AND FJU_VALOR > 0 "
				cInsert += " AND FJU_DOCTEF <> ' ' "
				cInsert += " AND FIF_MODPAG = '2' "

				If __nSelFil == 1 .And. Len(__aSelFil) > 0
					cInsert += " AND FJU_FILIAL "  + GetRngFil(__aSelFil, 'SE1', .T.,, 20, .T.)
				Else
					cInsert += " AND FJU_FILIAL = '"  +  __cFilAnt  + "' "
				EndIf

				cInsert += " AND FIF_DTCRED >= '" + DToS(__dDtCredI) + "' "
				cInsert += " AND FIF_DTCRED <= '" + DToS(__dDtCredF) + "' "
				cInsert += " AND FIF_NUCOMP >= '" + __cNsuIni + "' "
				cInsert += " AND FIF_NUCOMP <= '" + __cNsuFim + "' "
				cInsert += " AND FJU.FJU_TIPO IN ('PX','PD') "
				cInsert += " AND FJU.D_E_L_E_T_ = ' ' "	
		EndCase		

		If TCSQLExec(cInsert) < 0
			UserException( STR0292 + TcSqlError())
		EndIf

		FwFreeArray(aFields)	

	EndIf

Return cAliasAbas

//-------------------------------------------------------------------
/*/{Protheus.doc} loadGrids
 Faz o load da tabela

@type       function
@author     sidney.silva
@since      22/03/2022
@param oSubModel, Object, objeto do modelo
@param nFolder, Numeric, número da aba/folder da grid
@param cAlias, Character, se refere a grid da FIF ou SE1
@return     Array, retorna array para popular as grids
/*/
//-------------------------------------------------------------------
Static Function loadGrids(oSubModel As Object, nFolder As Numeric, cAlias As Character) As Array
	Local aLoad 		As Array
	Local cAliasAbas	As Array

	Default oSubModel 	:= ''
	Default nFolder		:= 0
	Default cAlias		:= "FIF"

	cAliasAbas := F920TmpAbas(nFolder, cAlias)	
	
	aLoad := FwLoadByAlias(oSubModel, cAliasAbas)

Return aLoad
