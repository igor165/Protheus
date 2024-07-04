#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA475.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA475
	Monitor de Remitos para Pre-factura de EUA.

	@type Function
	@author Thiago Berna
	@since 11/01/2019
	@version 1.0
	@example
	MATA475()
	@return Nil
	@see (links_or_references)
	/*/
//-------------------------------------------------------------------
Function MATA475()

	Local oProcess
	Local cPerg			:= 'MATA475'
	Local aSF2			:= {}
	Local aDescSF2		:= {}
	Local aInd			:= {}
	Local aPesquisa		:= {}
	Local aFilSF2		:= {}
	Local nA			:= 0
	Local nTamF2Ser		:= GetSx3Cache("F2_SERIE", "X3_TAMANHO")
	Local aFields 		:= {}

	Private aCols		:= {}
	Private cCadastro 	:= OemToAnsi(STR0001) //"Maintenance of Remittance"
	Private cAliasBR	:= GetNextAlias()		
	Private cSerRem		:= ''
	Private cSerNF		:= ''
	Private cPV			:= ''
	Private cCondAnt	:= ''
	Private oBrowse
	Private aDuplFin	:= {}

	Private aPe			:= {}
	Private _aRecNFs	:= {}
	Private lPedidos    := .F.
	Private lInverte	:= .F.
	Private lConsig		:= .F.
	Private cEspecie	:= 'NF  '
	Private _cFunName	:= Upper(Alltrim(ProcName()))
	Private lMSAuto	    := .F. //Variable paraser utilizada en MATA468N
	Private oTmpTable	:= NIL

	Setkey(VK_F12,{|| Pergunte(cPerg,.T.)})
	
	If cPaisLoc != "EUA"
		MsgInfo(STR0032, STR0033)//"Attention" - "Routine of United States."
		Return
	EndIf

	Pergunte(cPerg, .F.) //Carga preguntas de la rutina

	cSerRem	:= Padr(Alltrim(MV_PAR01),nTamF2Ser)
	cSerNF	:= Padr(Alltrim(MV_PAR02),nTamF2Ser)

	//Arreglo con campos para el Browse
	aFields := {"F2_STATUSR"	, ;
				"F2_EMISSAO"	, ;
				"F2_DOC"		, ;
				"F2_SERIE"		, ;
				"F2_CLIENTE"	, ;
				"F2_LOJA"		, ;
				"F2_COND"		, ;
				"F2_FRETE"		, ;
				"F2_DESPESA"	, ;
				"F2_SEGURO"		, ;
				"F2_TXMOEDA"	, ;
				"F2_FILIAL"}

	For nA := 1 to Len(aFields)
		If !Empty(FWSX3Util():GetFieldType(aFields[nA]))
			AAdd(aSF2, {aFields[nA], GetSx3Cache(aFields[nA], "X3_TIPO"), GetSx3Cache(aFields[nA], "X3_TAMANHO"), GetSx3Cache(aFields[nA], "X3_DECIMAL")})
		EndIf
	Next nA

	For nA := 1 to Len(aSF2)

		If !Empty(FWSX3Util():GetFieldType(aSF2[nA][1])) .And. aSF2[nA][1] != "F2_STATUSR" //Valida que exista el campo y descarta F2_STATUSR
			
			aAdd(aDescSF2, {AllTrim(FWX3Titulo(aSF2[nA][1])), ; //Título del campo
							aSF2[nA][1], ; //Nombre del campo
							AllTrim(GetSx3Cache(aSF2[nA][1], "X3_TIPO")), ; //Tipo de Campo
							GetSx3Cache(aSF2[nA][1], "X3_TAMANHO"), ; //Tamaño
							GetSx3Cache(aSF2[nA][1], "X3_DECIMAL"),  ; //Decimales
							AllTrim(GetSx3Cache(aSF2[nA][1], "X3_PICTURE")) } ) //Formato

			AAdd(aFilSF2, {aSF2[nA][1], ;
							AllTrim(FWX3Titulo(aSF2[nA][1])), ;
							aSF2[nA][2], ;
							aSF2[nA][3], ;
							aSF2[nA][4], ;
							AllTrim(GetSx3Cache(aSF2[nA][1], "X3_PICTURE"))}) //Formato
		EndIf

	Next nA

	If Select(cAliasBR) > 0
		DbSelectArea(cAliasBR)
		(cAliasBR)->(DbCloseArea())
	EndIf

	aInd := {"F2_FILIAL", "F2_DOC", "F2_SERIE", "F2_CLIENTE", "F2_LOJA"}

	oTmpTable := FWTemporaryTable():New(cAliasBR)
	oTmpTable:SetFields(aSF2)
	oTmpTable:AddIndex("I1", aInd)
	oTmpTable:Create()

	DbSelectArea(cAliasBR)

	oProcess := MsNewProcess():New({|lEnd| GeraDados(@oProcess,@lEnd,'MATA475',cAliasBR)},OemToAnsi(STR0003),OemToAnsi(STR0004),.T.) //"Records" - "Reading Records..." 
	oProcess:Activate()

	aPesquisa := aClone( MontaPesq(aDescSF2) )

	oBrowse := FWMarkBrowse():New()
	oBrowse:SetDescription(OemToAnsi(STR0009)) //"Monitor"
	oBrowse:AddLegend( cAliasBR+"->F2_STATUSR == '0' .Or. " + cAliasBR +"->F2_STATUSR == ' '", "YELLOW", OemToAnsi(STR0005) ) //"REMIT - Waiting Validation"
	oBrowse:AddLegend( cAliasBR+"->F2_STATUSR == '3'", "GRAY" , OemToAnsi(STR0028) ) //"REMIT - Canceled"
	oBrowse:AddLegend( cAliasBR+"->F2_STATUSR == '1'", "ORANGE"  , OemToAnsi(STR0006) ) //"Invoice - Waiting gener
	oBrowse:AddLegend( cAliasBR+"->F2_STATUSR == '2'", "RED"  , OemToAnsi(STR0007) ) //"Invoice - Generated"
	oBrowse:SetAlias(cAliasBR)
	oBrowse:SetFields(aDescSF2)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetSeek(.T. , aPesquisa)
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetDBFFilter(.T.)
	oBrowse:SetFilterDefault('')
	oBrowse:Activate()

	If Select(cAliasBR) > 0
		DbSelectArea(cAliasBR)
		(cAliasBR)->(DbCloseArea())
	EndIf

Return (Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA475EF
FWMarkBrowse para selecionar documentos que serao faturados

@author Thiago Berna

@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function MATA475EF()

	Local oBrowEF
	Local oProcess 
	Local oDlgEF
	Local oSize
	Local oPanel1
	Local aSF2			:= {}
	Local aDescSF2		:= {}
	Local aInd			:= {}
	Local aPesquisa		:= {}
	Local aFilSF2		:= {}
	Local aButtons		:= {}
	Local aPosPan1 		:= {}
	Local nA			:= 0 
	Local lMarcar    	:= .F.
	Local aFields 		:= {}

	Private aCols		:= {}
	Private cCadastro 	:= OemToAnsi(STR0008) //"Validation - CONFIR
	Private cAliasEF	:= GetNextAlias()
	Private cMarca		:= ''
	Private oProcesB	:= Nil

	//Arreglo con campos para el Browse
	aFields := {"F2_STATUSR"	, ;
				"F2_EMISSAO"	, ;
				"F2_DOC"		, ;
				"F2_SERIE"		, ;
				"F2_CLIENTE"	, ;
				"F2_LOJA"		, ;
				"F2_COND"		, ;
				"F2_FRETE"		, ;
				"F2_DESPESA"	, ;
				"F2_SEGURO"		, ;
				"F2_TXMOEDA"	, ;
				"F2_FILIAL"		, ;
				"F2_OK"}

	For nA := 1 to Len(aFields)
		If !Empty(FWSX3Util():GetFieldType(aFields[nA]))
			AAdd(aSF2, {aFields[nA], GetSx3Cache(aFields[nA], "X3_TIPO"), GetSx3Cache(aFields[nA], "X3_TAMANHO"), GetSx3Cache(aFields[nA], "X3_DECIMAL")})
		EndIf
	Next nA

	For nA := 1 to Len(aSF2)

		If !Empty(FWSX3Util():GetFieldType(aSF2[nA][1])) .And. aSF2[nA][1] != "F2_STATUSR" .And.  aSF2[nA][1] != "F2_OK"//Valida que exista el campo y descarta F2_STATUSR/F2_OK
			
			aAdd(aDescSF2, {AllTrim(FWX3Titulo(aSF2[nA][1])), ; //Título del campo
							aSF2[nA][1], ; //Nombre del campo
							AllTrim(GetSx3Cache(aSF2[nA][1], "X3_TIPO")), ; //Tipo de Campo
							GetSx3Cache(aSF2[nA][1], "X3_TAMANHO"), ; //Tamaño
							GetSx3Cache(aSF2[nA][1], "X3_DECIMAL"),  ; //Decimales
							AllTrim(GetSx3Cache(aSF2[nA][1], "X3_PICTURE")) } ) //Formato

			AAdd(aFilSF2, {aSF2[nA][1], ;
							AllTrim(FWX3Titulo(aSF2[nA][1])), ;
							aSF2[nA][2], ;
							aSF2[nA][3], ;
							aSF2[nA][4], ;
							AllTrim(GetSx3Cache(aSF2[nA][1], "X3_PICTURE"))}) //Formato
		EndIf

	Next nA

	If Select(cAliasEF) > 0
		DbSelectArea(cAliasEF)
		(cAliasEF)->(DbCloseArea())
	EndIf

	aInd := {"F2_FILIAL", "F2_DOC", "F2_SERIE", "F2_CLIENTE", "F2_LOJA"}

	oTmpTable := FWTemporaryTable():New(cAliasEF)
	oTmpTable:SetFields(aSF2)
	oTmpTable:AddIndex("I1", aInd)
	oTmpTable:Create()

	DbSelectArea(cAliasEF)

	cMarca := GetMark(,cAliasEF,"F2_OK")

	oProcess := MsNewProcess():New({|lEnd| GeraDados(@oProcess,@lEnd,'MATA475EF',cAliasEF)},OemToAnsi(STR0003),OemToAnsi(STR0004),.T.) //"Records" - "Reading Records..." 
	oProcess :Activate()

	aPesquisa := aClone(MontaPesq(aDescSF2))

	oSize := FwDefSize():New( .T. ,,,)
	oSize:AddObject("GETDADOS",100,100,.T.,.T.)
	oSize:lProp 	:= .T.
	oSize:Process()

	aPosPan1 := { oSize:GetDimension("GETDADOS","LININI"), oSize:GetDimension("GETDADOS","COLINI"), oSize:GetDimension("GETDADOS","LINEND"),; 
	oSize:GetDimension("GETDADOS","COLEND"), oSize:GetDimension("GETDADOS","XSIZE"), oSize:GetDimension("GETDADOS","YSIZE") }

	oDlgEF := TDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],cCadastro,,,,,,,,oMainWnd,.T.)

	oPanel1:= tPanel():New(aPosPan1[1],aPosPan1[2],,oDlgEF,,.T.,,,,aPosPan1[5],aPosPan1[6],.F.)

	oBrowEF := FWMarkBrowse():New()
	oBrowEF:SetDescription(OemToAnsi(STR0009)) //"Monitor"
	oBrowEF:AddLegend( cAliasEF+"->F2_STATUSR == '0' .Or. " + cAliasEF +"->F2_STATUSR == ' '", "YELLOW", OemToAnsi(STR0005) ) //"REMIT - Waiting Validation"
	oBrowEF:AddLegend( cAliasEF+"->F2_STATUSR == '3'", "GRAY"  , OemToAnsi(STR0028) ) //"REMIT - Canceled"
	oBrowEF:AddLegend( cAliasEF+"->F2_STATUSR == '1'", "ORANGE"  , OemToAnsi(STR0006) ) //"Invoice - Waiting gener
	oBrowEF:AddLegend( cAliasEF+"->F2_STATUSR == '2'", "RED"  , OemToAnsi(STR0007) ) //"Invoice - Generated"
	oBrowEF:SetAlias(cAliasEF)
	oBrowEF:SetFields(aDescSF2)
	oBrowEF:SetTemporary(.T.)
	oBrowEF:SetMark(cMarca, cAliasEF , "TM_OK" )
	oBrowEF:bAllMark := { || SetMarkAll(oBrowEF:Mark(),lMarcar := !lMarcar,cAliasEF ), oBrowEF:Refresh(.T.)  }
	oBrowEF:SetFieldMark( "F2_OK" )
	oBrowEF:SetSeek(.T. , aPesquisa)
	oBrowEF:SetUseFilter(.T.)
	oBrowEF:SetDBFFilter(.T.)
	oBrowEF:SetFilterDefault('')
	oBrowEF:SetOwner(oPanel1)
	oBrowEF:SetMenuDef('')
	oBrowEF:DisableReport()
	oBrowEF:SetValid({|| Valmark()})
	oBrowEF:Activate()  

	oDlgEF:Activate(,,,,,,{||EnchoiceBar(oDlgEF,{|| oProcesB := MsNewProcess():New({|lEnd| MATA475P2(oBrowEF,,cMarca,cSerNF,cPV)},OemToAnsi(STR0003),OemToAnsi(STR0004),.T.), oProcesB:Activate(), oDlgEF:End() },{||oDlgEF:End()},,aButtons)}) //"Records" - "Reading Records..." 

	If Select(cAliasEF) > 0
		DbSelectArea(cAliasEF)
		(cAliasEF)->(DbCloseArea())
	EndIf

Return(nil) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author Thiago Berna

@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStrSF2	:= FWFormStruct(1, 'SF2')
	Local oStrSD2	:= FWFormStruct(1, 'SD2') 

	oModel := MPFormModel():New('MVCSF2')
	oModel:addFields('MASTERSF2',,oStrSF2)
	oModel:AddGrid('DETAILSSD2', 'MASTERSF2', oStrSD2)
	oModel:SetRelation('DETAILSSD2', { { 'D2_FILIAL', 'F2_FILIAL' }, { 'D2_DOC', 'F2_DOC' }, { 'D2_SERIE', 'F2_SERIE' },;
										{ 'D2_CLIENTE', 'F2_CLIENTE' }, { 'D2_LOJA', 'F2_LOJA' } }, SD2->(IndexKey(1)) )
	oModel:SetDescription('REMITOS')
	oModel:getModel('MASTERSF2'):SetDescription('CABECALHO')
	oModel:getModel('DETAILSSD2'):SetDescription('ITENS')
	oModel:getModel('DETAILSSD2'):SetOptional(.T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author Thiago Berna

@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView
	Local oModel	:= ModelDef()
	Local oStrSF2	:= FWFormStruct(2, 'SF2')
	Local oStrSD2	:= FWFormStruct(2, 'SD2')

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('CABECALHO' , oStrSF2,'MASTERSF2' )
	oView:AddGrid('VIEW_FILHO1' , oStrSD2,'DETAILSSD2')
	oView:CreateHorizontalBox( 'BOXFORM1', 30 )
	oView:CreateHorizontalBox( 'BOXFORM2', 70 )           
	oView:CreateFolder('Folder01', 'BOXFORM2')
	oView:AddSheet('Folder01', 'ABA_FILHO01', '')
	oView:CreateHorizontalBox('ITENS_FILHO01', 100,,, 'Folder01', 'ABA_FILHO01' )
	oView:CreateVerticalBox( 'ENCHOICE'	  , 100, 'BOXFORM1' )                      
	oView:SetOwnerView( 'CABECALHO', 'ENCHOICE'  )
	oView:SetOwnerView('VIEW_FILHO1', 'ITENS_FILHO01')
	oView:EnableTitleView('CABECALHO' , '' )                                             	

Return oView                                                                             

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author Thiago Berna

@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef() 

	Local aRotina := {} 
	ADD OPTION aRotina TITLE OemToAnsi(STR0010) 	ACTION 'MATA475ED(2)'			OPERATION 2 ACCESS 0  //"View"
	ADD OPTION aRotina TITLE OemToAnsi(STR0011)    	ACTION 'MATA475ED(4)' 			OPERATION 4 ACCESS 0 //"Edit"
	//Removido temporáriamente.
	//ADD OPTION aRotina TITLE OemToAnsi(STR0012)    	ACTION 'MATA475EF' 				OPERATION 2 ACCESS 0 //"Perform"
	ADD OPTION aRotina TITLE OemToAnsi(STR0013)     ACTION 'MATA475LE' 				OPERATION 2 ACCESS 0 //"Caption"
	ADD OPTION aRotina TITLE OemToAnsi(STR0014)   	ACTION "Pergunte('MATA475',.T.)"OPERATION 2 ACCESS 0 //"Parameter

Return aRotina          

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA475LE
Legendas

@author Thiago Berna

@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function MATA475LE()

	BrwLegenda('',OemToAnsi(STR0013),{	{"BR_AMARELO"	, OemToAnsi(STR0005)},; //"Caption" - "REMIT - Waiting Validation"
										{"BR_CINZA"		, OemToAnsi(STR0028)},; //"REMIT - Canceled"
										{"BR_LARANJA"	, OemToAnsi(STR0006)},; //"Invoice - Waiting gener
										{"BR_VERMELHO"	, OemToAnsi(STR0007)}} ) //"Invoice - Generated"

Return(.T.)      

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA475ED
Edicao de documentos antes de faturar ou gerar devolucao

@author Thiago Berna

@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function MATA475ED(nOpc)

	Local oDlgED
	Local oSize
	Local oPanel1
	Local oPanel2
	Local oEnchoice
	Local aPosPan1 		:= {}
	Local aPosPan2 		:= {}
	Local aButtons		:= {}
	Local aFields       := {}
	Local aColsOri		:= {}
	Local aSF2			:= {}
	Local nCount		:= 1
	Local nI			:= 1
	Local cQuery 		:= ''
	Local cAliasED 		:= GetNextAlias()
	Local cFieldOk    	:= "MATA475FL()"
	Local aListFld		:= {}
	Local cFieldBox		:= "X3_CBOX"

	Private oGetD
	Private aHeader		:= {}
	Private aCols		:= {}

	Default nOpc		:= 4 

	AAdd( aButtons, {OemToAnsi(STR0015), {|| aDuplFin := MATA476(nOpc,.F.,,oGetd:aCols)}, OemToAnsi(STR0015), OemToAnsi(STR0015) , {|| .T.}} ) //"Sheet"

	If (nOpc == 4 .And. ((cAliasBR)->F2_STATUSR == '0' .Or. (cAliasBR)->F2_STATUSR == ' ')) .Or. nOpc == 2

		DbSelectArea('SF2')
		SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		SF2->(DbSeek((cAliasBR)->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))

		aListFld := {"D2_ITEM", ;
					"D2_COD", ;
					"D2_QUANT", ;
					"D2_QTDEDEV", ;
					"D1_TES", ;
					"D2_PRCVEN", ;
					"D2_DESCON", ;
					"D2_TOTAL", ;
					"D2_TES", ;
					"D2_LOCAL", ;
					"D2_CLASFIS", ;
					"D2_PEDIDO", ;
					"D2_ITEMPV", ;
					"D2_NUMLOTE", ;
					"D2_DTVALID", ;
					"D2_LOTECTL", ;
					"D2_PRUNIT", ;
					"D2_CF", ;
					"D2_FILIAL"}

		For nI := 1 to Len(aListFld)
			If !Empty(FWSX3Util():GetFieldType(aListFld[nI]))
				AAdd(aFields, {aListFld[nI], GetSx3Cache(aListFld[nI], "X3_TIPO"), GetSx3Cache(aListFld[nI], "X3_TAMANHO"), GetSx3Cache(aListFld[nI], "X3_DECIMAL")})
			EndIf
		Next nI

		AAdd(aSF2,"F2_EMISSAO")
		AAdd(aSF2,"F2_DOC")
		AAdd(aSF2,"F2_SERIE")
		AAdd(aSF2,"F2_CLIENTE")
		AAdd(aSF2,"F2_LOJA")
		AAdd(aSF2,"F2_COND")
		AAdd(aSF2,"F2_FRETE")
		AAdd(aSF2,"F2_DESPESA")
		AAdd(aSF2,"F2_SEGURO")
		AAdd(aSF2,"F2_VALMERC")		
		Aadd(aSF2, "NOUSER")

		cQuery := " SELECT SD2.D2_FILIAL, SD2.D2_LOCAL, SD2.D2_PRCVEN AS D2_PRUNIT, SD2.D2_CLASFIS, SD2.D2_NUMLOTE, SD2.D2_PEDIDO, SD2.D2_ITEMPV, "
		cQuery += " SD2.D2_LOTECTL, SD2.D2_DTVALID, SD2.D2_CF, SD2.D2_ITEM, SD2.D2_COD, SD2.D2_QTDAFAT - SD2.D2_QTDEDEV AS D2_QUANT, 0 AS D2_QTDEDEV, SD2.D2_PRCVEN, "
		cQuery += " (SD2.D2_QTDAFAT - SD2.D2_QTDEDEV) * SD2.D2_PRCVEN AS D2_TOTAL, SD2.D2_DESCON, SD2.D2_TES, '   ' as D1_TES "
		cQuery += " FROM " + RetSqlTab("SD2") + " (NOLOCK)"
		cQuery += " WHERE SD2.D2_FILIAL = '" + xFilial('SD2') + "' "
		cQuery += " AND SD2.D2_DOC = '" + (cAliasBR)->F2_DOC + "' "
		cQuery += " AND SD2.D2_SERIE = '" + (cAliasBR)->F2_SERIE + "' "
		cQuery += " AND SD2.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)

		If Select(cAliasED) > 0
			DbSelectArea(cAliasED)
			(cAliasED)->(DbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasED, .F., .T.)

		If Upper(FwRetIdiom()) == "ES"
			cFieldBox := "X3_CBOXSPA"
		ElseIf Upper(FwRetIdiom()) == "EN"
			cFieldBox := "X3_CBOXENG"
		EndIf

		For nCount := 1 to Len(aFields) 
			If !Empty(FWSX3Util():GetFieldType(aFields[nCount][1])) //Valida que exista el campo
				
				AAdd(aHeader,{	AllTrim(FWX3Titulo(aFields[nCount][1])),; //Título del campo
								aFields[nCount][1],; //Nombre del Campo
								GetSx3Cache(aFields[nCount][1], "X3_PICTURE"),;
								GetSx3Cache(aFields[nCount][1], "X3_TAMANHO"),;
								GetSx3Cache(aFields[nCount][1], "X3_DECIMAL"),;
								GetSx3Cache(aFields[nCount][1], "X3_VALID"),;
								GetSx3Cache(aFields[nCount][1], "X3_USADO"),;
								GetSx3Cache(aFields[nCount][1], "X3_TIPO"),;
								GetSx3Cache(aFields[nCount][1], "X3_F3"),;
								GetSx3Cache(aFields[nCount][1], "X3_CONTEXT"),;
								GetSx3Cache(aFields[nCount][1], cFieldBox),;
								GetSx3Cache(aFields[nCount][1], "X3_RELACAO"),;
								GetSx3Cache(aFields[nCount][1], "X3_WHEN"),;
								GetSx3Cache(aFields[nCount][1], "X3_VISUAL"),;
								GetSx3Cache(aFields[nCount][1], "X3_VLDUSER"),;
								GetSx3Cache(aFields[nCount][1], "X3_PICTVAR"),;
								GetSx3Cache(aFields[nCount][1], "X3_OBRIGAT")})
			Endif

		Next nCount

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta os itens no acols                           						³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea(cAliasED)
		(cAliasED)->(DBGoTop())

		While !EOF()
			AAdd(aCols,Array(Len(aHeader)+1))
			For nI := 1 To Len(aHeader)
				If AllTrim(aHeader[nI,10]) <> "V"
					If AllTrim(aHeader[nI][2]) == 'D1_TES'
						aCols[Len(aCols)][nI] := Posicione('SB1',1,xFIlial('SB1')+(cAliasED)->(D2_COD),'B1_TE')
					ElseIf AllTrim(aHeader[nI][2]) == 'D2_DTVALID'
						aCols[Len(aCols)][nI] := STOD((cAliasED)->&(aHeader[nI][2]))
					Else
						aCols[Len(aCols)][nI]	:= (cAliasED)->&(aHeader[nI][2])
					EndIf
				Else
					aCols[Len(aCols)][nI]	:= Criavar(aHeader[nI][2])
				EndIf
			Next nI
			aCols[Len(aCols)][Len(aHeader)+1] := .F.

			DbSelectArea(cAliasED)
			DbSkip()
		Enddo

		aColsOri := aClone(aCols)

		oSize := FwDefSize():New( .T. ,,,)
		oSize:AddObject( "ENCHOICE"  , 100, 030, .T. , .T. )
		oSize:AddObject( "GETDADOS" ,  100, 070, .T. , .T. )
		oSize:lProp 	:= .T.
		oSize:Process()

		aPosPan1 := { oSize:GetDimension("ENCHOICE","LININI"), oSize:GetDimension("ENCHOICE","COLINI"), oSize:GetDimension("ENCHOICE","LINEND"),;
						oSize:GetDimension("ENCHOICE","COLEND") , oSize:GetDimension("ENCHOICE","XSIZE"), oSize:GetDimension("ENCHOICE","YSIZE") }

		aPosPan2 := { oSize:GetDimension("GETDADOS","LININI"), oSize:GetDimension("GETDADOS","COLINI"), oSize:GetDimension("GETDADOS","LINEND"),; 
						oSize:GetDimension("GETDADOS","COLEND"), oSize:GetDimension("GETDADOS","XSIZE"), oSize:GetDimension("GETDADOS","YSIZE") }

		oDlgED := TDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],cCadastro,,,,,,,,oMainWnd,.T.)

		oPanel1 := tPanel():New(aPosPan1[1]          ,aPosPan1[2]  ,,oDlgED,,.T.,,,,aPosPan1[5],aPosPan1[6]		,.F.)
		oPanel2 := tPanel():New(aPosPan2[1]          ,aPosPan2[2]  ,,oDlgED,,.T.,,,,aPosPan2[5],aPosPan2[6]		,.F.)

		RegToMemory('SF2', .F.)

		If Empty(M->F2_COND) 
			M->F2_COND := Posicione('SA1',1,xFilial('SA1') + (cAliasBR)->F2_CLIENTE + (cAliasBR)->F2_LOJA,'A1_COND')
		EndIf

		cCondAnt := M->F2_COND

		oEnchoice := MSMGet():New( "SF2", , nOpc, , , ,aSF2, {0,0,aPosPan1[6],aPosPan1[5]},;
									{'F2_COND','F2_FRETE','F2_DESPESA','F2_SEGURO'},3,,,,oPanel1,,,.T.,,,,)

		oGetD := MsNewGetDados():New(0,0,aPosPan2[6],aPosPan2[5],IIF(nOpc == 4,GD_UPDATE,),,,,;
										{'D2_QTDEDEV','D2_PRCVEN','D2_DESCON','D2_TES','D1_TES'},,9999,cFieldOk,,,oPanel2,@aHeader,@aCols)
		oDlgED:Activate(,,,,,,{||EnchoiceBar(oDlgED,{|| IIF(nOpc == 4,MATA475P1(oEnChoice,oGetD,aColsOri,aHeader,nOpc,oDlgED),;
		oDlgED:End()) },{||oDlgED:End()},,aButtons)})
	Else

		MsgInfo (OemToAnsi(STR0017), OemToAnsi(STR0016) ) //"Notice" - "Operation not allowed, check status."

	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA475P1
Função – Processa
Processa ajustes para emitir o documento de devolucao e a NF

@author Thiago Berna

@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MATA475P1(oEnChoice,oGetD,aColsOri,aHeader,nOpc,oDlgED)

	Local aCabDev 		:= {}
	Local aItsDev		:= {}
	Local aItDev		:= {}
	Local aCabNF 		:= {}
	Local aItsNF		:= {}
	Local aItNF			:= {}
	Local aItsNFDev 	:= {}
	Local aItNFDev		:= {}
	Local aTitulo		:= {}
	Local aCols 		:= oGetD:aCols
	Local nCountA		:= 0
	Local nCountB	 	:= 0
	Local nValUnit	 	:= 0
	Local nTotal		:= 0
	Local lDif			:= .F.
	Local lOk			:= .T.
	Local lRetDev		:= .T.
	Local lRetNF		:= .T.
	Local cChave		:= ''
	Local _aAreaSF2R 	:= {}
	//Local _aRecNFs  := {}

	Private lMSErroAuto := .F.

	For nCountA := 1 to Len(aCols)
		nTotal += aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TOTAL"})]
	Next nCountA

	If Len(aDuplFin) == 0 
		If nTotal > 0
			aDuplFin := MATA476(nOpc,.F.,,oGetd:aCols)
		EndIf
	EndIf

	If Empty(M->F2_COND)
		lOk := .F.
		Help(" ",1,"F2_COND",,,1,0)
	EndIf

	For nCountA := 1 to Len(aCols)
		If aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})] > 0 .And.; 
		Empty(aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})]) 
			lOk := .F.
			Help(" ",1,"D1_TES",,,1,0)
			Exit
		EndIf
	Next nCountA 

	If lOk
		//Verifica se houve alteracao no acols
		For nCountA := 1 to Len(aCols)

			nValUnit	:= aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRCVEN"})] 

			//Verifica se houve alteracao no acols
			For nCountB := 1 to Len(aCols[nCountA])
				If aCols[nCountA,nCountB] != aColsOri[nCountA,nCountB]
					lDif := .T.
				EndIf
			Next nCountB

			//Verifica se existe quantidade devolvida
			If aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})] != aColsOri[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]
				AAdd(aItDev,{"D1_COD"		,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_COD"})]			,Nil})
				AAdd(aItDev,{"D1_QUANT"		,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]		,Nil})
				AAdd(aItDev,{"D1_VUNIT"		,nValUnit																,Nil})
				AAdd(aItDev,{"D1_TOTAL"		,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})] *;
				nValUnit																							,Nil})
				AAdd(aItDev,{"D1_TES"		,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})]			,Nil})
				AAdd(aItDev,{"D1_NFORI"		,SF2->F2_DOC															,Nil})
				AAdd(aItDev,{"D1_SERIORI"	,SF2->F2_SERIE															,Nil})
				AAdd(aItDev,{"D1_ITEMORI"	,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEM"})]			,Nil})
				AAdd(aItDev,{"D1_FORNECE"	,SF2->F2_CLIENTE														,Nil})
				AAdd(aItDev,{"D1_LOJA"		,SF2->F2_LOJA															,Nil})
				AAdd(aItDev,{"D1_QTACLA"	,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]		,Nil})
				AAdd(aItDev,{"D1_NUMLOTE"	,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_NUMLOTE"})]		,Nil})
				AAdd(aItDev,{"D1_DTVALID"	,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_DTVALID"})]		,Nil})				
				AAdd(aItDev,{"D1_LOTECTL"	,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_LOTECTL"})]		,Nil})
				AAdd(aItsDev,aItDev)

				aItDev := {}

				//Cria cabecalho devolucao
				If Len(aCabDev) == 0
					AAdd(aCabDev,{"F1_TIPO"  	,'D'								,Nil})
					AAdd(aCabDev,{"F1_FORNECE"  ,SF2->F2_CLIENTE					,Nil})
					AAdd(aCabDev,{"F1_LOJA" 	,SF2->F2_LOJA						,Nil})
					AAdd(aCabDev,{"F1_SERIE" 	,cSerRem							,Nil})
					AAdd(aCabDev,{"F1_DOC" 		,NxtSx5Nota( cSerRem,.T.,'1',.T. )	,Nil})
					AAdd(aCabDev,{"F1_TXMOEDA" 	,SF2->F2_TXMOEDA					,Nil})
					AAdd(aCabDev,{"F1_NFORIG" 	,SF2->F2_DOC						,Nil})
					AAdd(aCabDev,{"F1_SERORIG" 	,SF2->F2_SERIE						,Nil})
				EndIf

			EndIf

			//Cria cabecalho NF
			If Len(aCabNF) == 0
				AAdd(aCabNF,{"F2_CLIENTE"  	,SF2->F2_CLIENTE					,Nil})
				AAdd(aCabNF,{"F2_LOJA" 		,SF2->F2_LOJA						,Nil})
				AAdd(aCabNF,{"F2_SERIE" 	,cSerNF								,Nil})
				AAdd(aCabNF,{"F2_DOC" 		,NxtSx5Nota( cSerNF,.T.,'1',.T. )	,Nil})	
				AAdd(aCabNF,{"F2_EMISSAO"	,DDataBase							,Nil})
				AAdd(aCabNF,{"F2_TXMOEDA" 	,SF2->F2_TXMOEDA					,Nil})
				AAdd(aCabNF,{"F2_COND" 		,M->F2_COND							,Nil})
				AAdd(aCabNF,{"F2_FRETE" 	,M->F2_FRETE						,Nil})
				AAdd(aCabNF,{"F2_DESPESA" 	,M->F2_DESPESA						,Nil})
				AAdd(aCabNF,{"F2_SEGURO" 	,M->F2_SEGURO						,Nil})
				AAdd(aCabNF,{"F2_TPVENT" 	,'1'								,Nil})
				AAdd(aCabNF,{"F2_SDOC" 		,cSerNF								,Nil})
			EndIf

			//Cria array com Itens 100% devolvidos para cancelar a NF de saida emitida
			If aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] - ;
				aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})] == 0
				AAdd(aItNFDev,{"D2_COD"			,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_COD"})]			,Nil})
				AAdd(aItNFDev,{"D2_QUANT"		,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] 		,Nil})
				AAdd(aItNFDev,{"D2_PRCVEN"		,nValUnit																,Nil})
				AAdd(aItNFDev,{"D2_PRUNIT"		,nValUnit																,Nil})
				AAdd(aItNFDev,{"D2_TOTAL"		,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] * nValUnit,Nil})
				AAdd(aItNFDev,{"D2_TES"			,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TES"})]			,Nil})
				AAdd(aItNFDev,{"D2_PEDIDO"		,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PEDIDO"})]		,Nil})
				AAdd(aItNFDev,{"D2_ITEMPV"     ,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEMPV"})]		,Nil})
				AAdd(aItNFDev,{"D2_SDOC"		,cSerNF																	,Nil})
				AAdd(aItNFDev,{"D2_NFORI"		,SF2->F2_DOC															,Nil})
				AAdd(aItNFDev,{"D2_SERIORI"		,SF2->F2_SERIE															,Nil})
				AAdd(aItNFDev,{"D2_ITEMORI"		,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEM"})]			,Nil})
				AAdd(aItNFDev,{"D2_NUMLOTE"    ,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_NUMLOTE"})]		,Nil})
				AAdd(aItNFDev,{"D2_DTVALID"    ,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_DTVALID"})]		,Nil})													
				AAdd(aItNFDev,{"D2_LOTECTL"    ,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_LOTECTL"})]		,Nil})		

			Else
				//Cria itens NF			
				AAdd(aItNF,{"D2_COD"		,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_COD"})]			,Nil})
				AAdd(aItNF,{"D2_QUANT"		,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] - ;
					aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]								,Nil})
				AAdd(aItNF,{"D2_PRCVEN"		,nValUnit																,Nil})
				AAdd(aItNF,{"D2_PRUNIT"		,nValUnit																,Nil})
				AAdd(aItNF,{"D2_TOTAL"		,(aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] -;
				aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})]) * nValUnit						,Nil})
				AAdd(aItNF,{"D2_TES"		,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TES"})]			,Nil})
				AAdd(aItNF,{"D2_PEDIDO"		,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PEDIDO"})]		,Nil})
				AAdd(aItNF,{"D2_ITEMPV"     ,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEMPV"})]		,Nil})
				AAdd(aItNF,{"D2_SDOC"		,cSerNF																	,Nil})
				AAdd(aItNF,{"D2_NFORI"		,SF2->F2_DOC															,Nil})
				AAdd(aItNF,{"D2_SERIORI"	,SF2->F2_SERIE															,Nil})
				AAdd(aItNF,{"D2_ITEMORI"	,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEM"})]			,Nil})
				AAdd(aItNF,{"D2_NUMLOTE"    ,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_NUMLOTE"})]		,Nil})
				AAdd(aItNF,{"D2_DTVALID"    ,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_DTVALID"})]		,Nil})								
				AAdd(aItNF,{"D2_LOTECTL"    ,aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_LOTECTL"})]		,Nil})		

				DbSelectArea('SD2')
				SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				iF DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+;
					   		aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_COD"})]+;					   
					   		aCols[nCountA,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEM"})])

					AADD(_aRecNFs,SD2->(RECNO()))

				Endif
			EndIf
			
			If Len(aItNF) > 0
				AAdd(aItsNF,aItNF)
			EndIf
			
			If Len(aItNFDev) > 0
				AAdd(aItsNFDev,aItNFDev)
			EndIf

			aItNF 	:= {}
			aItNFDev:= {}

		Next nCountA

		DbSelectArea('SD2')
		SD2->(DbSetOrder(1)) //D2_FILIAL+D2_COD+D2_LOCAL+D2_NUMSEQ
		
		//Verifica se o Cabecalho foi alterado
		If !lDif
			If cCondAnt	!= M->F2_COND .Or. ;
				SF2->F2_FRETE	!= M->F2_FRETE .Or. ;
				SF2->F2_DESPESA	!= M->F2_DESPESA .Or. ;
				SF2->F2_SEGURO	!= M->F2_SEGURO

				lDif := .T.

			EndIf
		EndIf

		If lDif

			If MsgYesNo(OemToAnsi(STR0018),OemToAnsi(STR0019)) //"Do you wish to continue?" - "Changed data, mandatory Invoice generation!"

				//Atualizacao Status do Remito
				RecLock('SF2',.F.)
				SF2->F2_STATUSR := '1'
				SF2->(MsUnlock())

				DbSelectArea('SD2')
				SD2->(DbSetOrder(1)) //D2_FILIAL+D2_COD+D2_LOCAL+D2_NUMSEQ

				If Len(aItsDev) > 0 .And. Len(aItsNFDev) != Len(aCols)

					//Emite NF Devolucao
					MSExecAuto({|v,w,x,y,z| LOCXNF(v,w,x,y,z)},51,aCabDev,aItsDev,3,'MATA462DN')
				
					// Verifica se tem erro
					If lMSErroAuto
						lRetDev	:= .F.
						MostraErro()
					Else
						lRetDev := .T.
						//Ajuste Remito devido a quantidade a faturar
						DbSelectArea('SD2')
						SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
						While SD2->(!EOF()) .And. SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA == SD2->D2_FILIAL+;
								SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
							RecLock('SD2',.F.)
							SD2->D2_QTDAFAT := SD2->D2_QUANT-(SD2->D2_QTDEFAT+SD2->D2_QTDEDEV) 
							SD2->(MsUnlock())
							SD2->(DbSkip())
						EndDo													
					EndIf                       
					If lRetDev 
						
						If nTotal == 0
							//Atualizacao Status do Remito
							RecLock('SF2',.F.)
							SF2->F2_STATUSR := '2'
							SF2->(MsUnlock())

							RecLock(cAliasBR,.F.)
							(cAliasBR)->F2_STATUSR := '2'
							(cAliasBR)->(MsUnlock())
							//Exclui o financeiro provisorio
							aTitulo := { { "E1_PREFIXO"	, SF2->F2_SERIE		, NIL },;
										{ "E1_NUM"      , SF2->F2_DOC       , NIL },;
										{ "E1_TIPO"     , 'PRE'       	    , NIL },;
										{ "E1_CLIENTE"  , SF2->F2_CLIENTE	, NIL },;
										{ "E1_LOJA" 	, SF2->F2_LOJA		, NIL },;
										{ "E1_EMISSAO"  , SF2->F2_EMISSAO	, NIL },;
										{ "E1_ORIGEM"   , 'MATA462N'		, NIL } }

							MsExecAuto( { |x,y| FINA040(x,y)} , aTitulo,5 )  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
						EndIf
					Else
						DisarmTransaction()
					EndIf
					
					aItsDev	:= {}
					aCabDev := {}

				EndIf
				
				_aAreaSF2R := SF2->(GetArea())

				//#MF ALTERAR AQUI
				DbSelectArea('SD2')
				SD2->(DbSetOrder(1)) //D2_FILIAL+D2_COD+D2_LOCAL+D2_NUMSEQ

				//Emite NF Saida
				If (Len(aItsNF) > 0 .And. lRetDev) .Or. (Len(aItsNFDev) > 0 .And. lRetDev .And. Len(aCols) == Len(aItsNFDev))

					If Len(aCols) == Len(aItsNFDev)

						MSExecAuto({|v,w,x,y,z| LOCXNF(v,w,x,y,z)},1,aCabNF,aItsNFDev,3,'MATA468N')

						// Verifica se tem erro
						If lMSErroAuto
							lRetNF	:= .F.
							MostraErro()
						Else
							lRetNF := .T.
							//Ajuste Remito devido a quantidade a faturar
							DbSelectArea('SD2')
							SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
							While SD2->(!EOF()) .And. SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA == SD2->D2_FILIAL+;
								SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
								RecLock('SD2',.F.)
								SD2->D2_QTDAFAT := SD2->D2_QUANT-(SD2->D2_QTDEFAT+SD2->D2_QTDEDEV)
								SD2->(MsUnlock())
								SD2->(DbSkip())
							EndDo														
						EndIf                       
					
					Else

						DbSelectArea('SD2')
						SD2->(DbSetOrder(1)) //D2_FILIAL+D2_COD+D2_LOCAL+D2_NUMSEQ
						
						aParams	:=	{	SPACE(Len(SD2->D2_DOC))	,Replicate('z',Len(SD2->D2_DOC)),; 	//Pedido de - ate
										SPACE(Len(SA1->A1_COD))		,Replicate('z',Len(SA1->A1_COD))   ,; 	//Cliente de - ate
										SPACE(Len(SA1->A1_LOJA))	,Replicate('z',Len(SA1->A1_LOJA))  ,; 	//Loja de - ate
										SPACE(Len(SB1->B1_GRUPO))	,Replicate('z',Len(SB1->B1_GRUPO)) ,; 	//Grupo de - ate
										SPACE(Len(SA1->A1_AGREG))	,Replicate('z',Len(SA1->A1_AGREG)) ,;  //Agregador de - ate
										2 /*mv_par01*/	,       2 /*mv_par02*/,                         2 /*mv_par03*/  ,; 	//lDigita # lAglutina # lGeraLanc
										2			,                                                    ; 	//Trazer pedidos marcados ? 1 - Sim;2 - Nao
										2 /*mv_par04*/    ,                                                    ;  //Atualiza vinculo  ? 1 - Sim;2 - Nao                
										1           ,                                                    ;  //Aglutina por  ? 1 - Pedido;2 - Grupo;3 - Agregador;4 - Cliente;5 - Nao aglutina
										0			,  	                                                 ;  //Valor Minimo 
										2           ,                                                    ;  //Fatura Proforma  ?   1 - Sim;2 - Nao
										SPACE(Len(SC5->C5_TRANSP))	,Replicate('z',Len(SC5->C5_TRANSP)),;	//Transportadora de - ate
										2			, 													 ;  //Reajusta na mesma nota  ?   1 - Sim;2 - Nao
										1           ,                                                    ;  //Fatura Pedido pela ?   1 - Moeda do pedido;2 - Moeda selecionada     
										1           ,                                                    ;  //Fatura pela Moeda  ?   1 - Moeda 1;2 - Moeda 2;3 - Moeda 3;4 - Moeda 4;5 - Moeda 5     
										1           ,													 ;	//Contabiliza por ?   1 - Nota;2 - Total das Notas         
										1           }	

						lInverte	:=	(aParams[14] == 1)
						lConsig		:=	(aParams[18] == 1)							

						DbSelectArea('SD2')
						SD2->(DbSetOrder(1)) //D2_FILIAL+D2_COD+D2_LOCAL+D2_NUMSEQ

						aNotaGera := {}

						MsAguarde({|| aNotas	:=	A468nFatura("SD2",aParams,@_aRecNFs,,.F.,.T.,@aNotaGera,.T.,cSerNF,SF2->F2_DOC )}, STR0034,STR0035,.F.) // "Preparing" - 	"Generating Invoices"		

						//Limpando o titulo
						_aRecNFs 		:= {}

						If lMSErroAuto
							lRetNF	:= .F.
							MostraErro()
						Else
							lRetNF := .T.
						EndIf
						aItsNF	:= {}
					EndIf
					
					If !lRetNF
						DisarmTransaction()
					EndIf
					
					//Ajuste NF
					DbSelectArea('SD2')
					SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
					cChave := SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
					SD2->(MSSeek(cChave))

					If Found()

						While SD2->(!EOF()) .And. cChave == SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
							RecLock('SD2',.F.)
							SD2->D2_REMITO 	:= SD2->D2_NFORI
							SD2->D2_SERIREM := SD2->D2_SERIORI 
							SD2->D2_ITEMREM := SD2->D2_ITEMORI
							SD2->D2_NFORI	:= ''				
							SD2->D2_SERIORI	:= ''
							SD2->D2_ITEMORI	:= ''
							SD2->(MsUnlock())
							SD2->(DbSkip())
						EndDo
						//Restaurando área do REMITO
						RestArea(_aAreaSF2R)

						DbSelectArea('SD2')
						SD2->(DbSetOrder(1)) //D2_FILIAL+D2_COD+D2_LOCAL+D2_NUMSEQ

						If lRetNF

							//Atualizacao Status do Remito
							RecLock('SF2',.F.)
							SF2->F2_STATUSR := '2'
							SF2->(MsUnlock())

							RecLock(cAliasBR,.F.)
							(cAliasBR)->F2_STATUSR := '2'
							(cAliasBR)->(MsUnlock())

							//Exclui o financeiro provisorio
							aTitulo := { { "E1_PREFIXO"	, SF2->F2_SERIE		, NIL },;
										{ "E1_NUM"      , SF2->F2_DOC		, NIL },;
										{ "E1_TIPO"     , 'PRE'				, NIL },;
										{ "E1_CLIENTE"  , SF2->F2_CLIENTE	, NIL },;
										{ "E1_LOJA" 	, SF2->F2_LOJA		, NIL },;
										{ "E1_EMISSAO"  , SF2->F2_EMISSAO	, NIL },;
										{ "E1_ORIGEM"   , 'MATA462N'		, NIL } }

							MsExecAuto( { |x,y| FINA040(x,y)} , aTitulo,5 )  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

						Else
							DisarmTransaction()
						EndIf
					EndIf

				EndIf

				//Cancela quando todos os itens forem devolvidos
				If Len(aItsNFDev) > 0 .And. lRetDev .And. Len(aCols) == Len(aItsDev)

					MSExecAuto({|v,w,x,y,z| LOCXNF(v,w,x,y,z)},1,aCabNF,aItsNFDev,6,'MATA468N')//MATA467N

					If lMSErroAuto
						lRetNF	:= .F.
						MostraErro()
					Else
						lRetNF := .T.
					EndIf                       
					
					aItsNFDev	:= {}
				
					If lRetNf
						DbSelectArea('SD2')
						SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
						If DbSeek(xFilial('SD2')+SF2->F2_NFORI+SF2->F2_SERIORI+SF2->F2_CLIENTE+SF2->F2_LOJA)
							While SD2->(!EOF()) .And. SF2->F2_NFORI+SF2->F2_SERIORI+SF2->F2_CLIENTE+SF2->F2_LOJA == SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
								SD2->(RecLock('SD2',.F.))
								SD2->D2_QTDEFAT := SD2->D2_QUANT
								SD2->D2_QTDAFAT	:= 0
								SD2->(MsUnlock())
								SD2->(DbSkip())
							EndDo
						
							DbSelectArea('SF2')
							SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
							If SF2->(DbSeek(xFilial('SF2')+SF2->F2_NFORI+SF2->F2_SERIORI+SF2->F2_CLIENTE+SF2->F2_LOJA))
								SF2->(RecLock('SF2',.F.))
								SF2->F2_STATUSR := '3'
								SF2->(MsUnlock())

								RecLock(cAliasBR,.F.)
								(cAliasBR)->F2_STATUSR := '3'
								(cAliasBR)->(MsUnlock())
							EndIf

							//Exclui o financeiro provisorio
							aTitulo := { 	{ "E1_PREFIXO"  , SF2->F2_SERIE								, NIL },;
											{ "E1_NUM"      , SF2->F2_DOC           					, NIL },;
											{ "E1_TIPO"     , 'PRE'       	       						, NIL },;
											{ "E1_CLIENTE"  , SF2->F2_CLIENTE          					, NIL },;
											{ "E1_LOJA" 	, SF2->F2_LOJA          					, NIL },;
											{ "E1_EMISSAO"  , SF2->F2_EMISSAO							, NIL },;
											{ "E1_ORIGEM"   , 'MATA462N'								, NIL } }

							MsExecAuto( { |x,y| FINA040(x,y)} , aTitulo,5 )  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
						
						EndIf
						DbSelectArea('SD2')
						SD2->(DbSetOrder(1)) //D2_FILIAL+D2_COD+D2_LOCAL+D2_NUMSEQ
					Else
						DisarmTransaction()
					EndIf
				
				EndIf

			Else
				MsgInfo(OemToAnsi(STR0020),OemToAnsi(STR0021)) //"Process Canceled." - "Canceled"
			EndIf

		ElseIf Len(aItsNF) > 0

			Begin Transaction

			If MsgYesNo(OemToAnsi(STR0022),OemToAnsi(STR0023)) //"Do you want to generate the invoice now?" - "Invoice gerneration"

				MSExecAuto({|v,w,x,y,z| LOCXNF(v,w,x,y,z)},1,aCabNF,aItsNF,3,'MATA468N')
				
				// Verifica se tem erro
				If lMSErroAuto
					lRetNF	:= .F.
					MostraErro()
				Else
					lRetNF := .T.
				EndIf                       
					
				aItsNF	:= {}

				If lRetNf

					//Ajuste Itens NF
					DbSelectArea('SD2')
					SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
					cChave := SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
					SD2->(DbSeek(cChave))

					If Found()

						While SD2->(!EOF()) .And. SF2->F2_FILIAL+aCabNF[aScan(aCabNF,{|x| AllTrim(x[1]) == "F2_DOC"}),2];
								+PADR(aCabNF[aScan(aCabNF,{|x| AllTrim(x[1]) == "F2_SERIE"}),2],3)+SF2->F2_CLIENTE+SF2->F2_LOJA == SD2->D2_FILIAL+;
								SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA

							RecLock('SD2',.F.)
							SD2->D2_REMITO 	:= SD2->D2_NFORI
							SD2->D2_SERIREM := SD2->D2_SERIORI 
							SD2->D2_ITEMREM := SD2->D2_ITEMORI
							SD2->D2_NFORI	:= ''				
							SD2->D2_SERIORI	:= ''
							SD2->D2_ITEMORI	:= ''
							SD2->(MsUnlock())
							SD2->(DbSkip())
						EndDo

						//Ajuste Cabecalho Remito
						RecLock('SF2',.F.)
						SF2->F2_STATUSR := '2'
						SF2->(MsUnlock())

						RecLock(cAliasBR,.F.)
						(cAliasBR)->F2_STATUSR := '2'
						(cAliasBR)->(MsUnlock())

						//Exclui o financeiro provisorio
						aTitulo := { 	{ "E1_PREFIXO"  , SF2->F2_SERIE								, NIL },;
										{ "E1_NUM"      , SF2->F2_DOC           					, NIL },;
										{ "E1_TIPO"     , 'PRE'       	       						, NIL },;
										{ "E1_CLIENTE"  , SF2->F2_CLIENTE          					, NIL },;
										{ "E1_LOJA" 	, SF2->F2_LOJA          					, NIL },;
										{ "E1_EMISSAO"  , SF2->F2_EMISSAO							, NIL },;
										{ "E1_ORIGEM"   , 'MATA462N'								, NIL } }

						MsExecAuto( { |x,y| FINA040(x,y)} , aTitulo,5 )  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

						//Ajuste Itens Remito
						DbSelectArea('SD2')
						SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
						SD2->(DbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

						While SD2->(!EOF()) .And. SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA == SD2->D2_FILIAL+;
								SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA

							RecLock('SD2',.F.)
							SD2->D2_QTDEFAT := SD2->D2_QTDAFAT - SD2->D2_QTDEDEV
							SD2->D2_QTDAFAT := 0 						
							SD2->(MsUnlock())
							SD2->(DbSkip())
						EndDo

					EndIf
					DbSelectArea('SD2')
					SD2->(DbSetOrder(1)) //D2_FILIAL+D2_COD+D2_LOCAL+D2_NUMSEQ
				Else
					DisarmTransaction()
				EndIf
			Else

				//Ajuste Cabecalho Remito
				RecLock('SF2',.F.)
				SF2->F2_STATUSR := '1'
				SF2->(MsUnlock())

				RecLock(cAliasBR,.F.)
				(cAliasBR)->F2_STATUSR := '1'
				(cAliasBR)->(MsUnlock())

			EndIf

			End Transaction

		EndIf

		oDlgED:End()
		oBrowse:GoTop(.T.)
		oBrowse:Refresh()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA475P2
Gera faturamento dos documentos selecionados ou recebidos pela variavel aDocs

@author Thiago Berna

@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MATA475P2(oBrowEF,aDocs,cMarca,cSerNF,cPV)

	Local aNFS		:= {}
	Local aCabNF 	:= {}
	Local aItsNF	:= {}
	Local aItNF		:= {}
	Local nCount	:= 0
	Local lRetNF	:= .T.
	Local cChave	:= ''

	Private aHeader := {}
	Private aCols	:= {}
	Private aDuplFin:= {}
	Private nOpc	:= 3
	Private lMSErroAuto	:= .F.

	Default oBrowEF	:= Nil
	Default aDocs	:= {}
	Default cMarca 	:= {}
	Default cSerNF	:= ''

	Default cPV		:= ''

	//limpa array com recnos para geração da nota
	_aRecNFs 		:= {}

	If !Empty(aDocs)
		aNFS := aClone(aDocs)
	EndIf

	//Carrega aDocs
	If !IsBlind()

		DbSelectArea(cAliasEF)
		(cAliasEF)->(DbGoTop())

		While (cAliasEF)->(!EOF())
			If (cAliasEF)->(F2_OK) == cMarca
				AAdd(aNFS,{(cAliasEF)->(F2_DOC),;
				(cAliasEF)->(F2_SERIE),;
				(cAliasEF)->(F2_CLIENTE),;
				(cAliasEF)->(F2_LOJA),;
				IIF(!Empty((cAliasEF)->(F2_COND)),(cAliasEF)->(F2_COND),Posicione('SA1',1,xFilial('SA1')+(cAliasEF)->(F2_CLIENTE)+(cAliasEF)->(F2_LOJA),'A1_COND')),;
				(cAliasEF)->(F2_FRETE),;
				(cAliasEF)->(F2_DESPESA),;
				(cAliasEF)->(F2_SEGURO),;
				(cAliasEF)->(F2_FILIAL),;
				(cAliasEF)->(F2_TXMOEDA)})
			EndIf
			(cAliasEF)->(DbSkip())
		EndDo

		oProcesB:SetRegua1(1)
		oProcesB:SetRegua2(Len(aNFS)) 

	EndIf

	If Len(aNFS) > 0
		For nCount := 1 to Len(aNFS)
			
			If Len(aCabNF) == 0
				cNumero := aNFS[nCount,1]
				AAdd(aCabNF,{"F2_CLIENTE"  	,aNFS[nCount,3]						,Nil})
				AAdd(aCabNF,{"F2_LOJA" 		,aNFS[nCount,4]						,Nil})
				AAdd(aCabNF,{"F2_SERIE" 	,cSerNF								,Nil})
				AAdd(aCabNF,{"F2_DOC" 		,cNumero							,Nil})				
				AAdd(aCabNF,{"F2_EMISSAO"	,DDataBase							,Nil})
				AAdd(aCabNF,{"F2_TXMOEDA" 	,aNFS[nCount,10]					,Nil})
				AAdd(aCabNF,{"F2_COND" 		,aNFS[nCount,5]						,Nil})
				AAdd(aCabNF,{"F2_FRETE" 	,aNFS[nCount,6]						,Nil})
				AAdd(aCabNF,{"F2_DESPESA" 	,aNFS[nCount,7]						,Nil})
				AAdd(aCabNF,{"F2_SEGURO" 	,aNFS[nCount,8]						,Nil})
				AAdd(aCabNF,{"F2_TPVENT" 	,'1'								,Nil})
				AAdd(aCabNF,{"F2_SDOC" 		,cSerNF								,Nil})
			EndIf

			DbSelectArea('SD2')
			SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			SD2->(DbSeek(aNFS[nCount,9]+aNFS[nCount,1]+aNFS[nCount,2]+aNFS[nCount,3]+aNFS[nCount,4]))

			While SD2->(!EOF()) .And. aNFS[nCount,9]+aNFS[nCount,1]+aNFS[nCount,2]+aNFS[nCount,3]+aNFS[nCount,4] == SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)

				//Cria itens NF
				AAdd(aItNF,{"D2_COD"		,SD2->D2_COD						,Nil})
				AAdd(aItNF,{"D2_QUANT"		,SD2->D2_QTDAFAT - SD2->D2_QTDEDEV  ,Nil})
				AAdd(aItNF,{"D2_PRCVEN"		,SD2->D2_PRCVEN						,Nil})
				AAdd(aItNF,{"D2_PRUNIT"		,SD2->D2_PRUNIT						,Nil})
				AAdd(aItNF,{"D2_TOTAL"		,(SD2->D2_QTDAFAT - SD2->D2_QTDEDEV) * SD2->D2_PRCVEN	,Nil})
				AAdd(aItNF,{"D2_TES"		,SD2->D2_TES						,Nil})
				AAdd(aItNF,{"D2_PEDIDO"		,SD2->D2_PEDIDO						,Nil})
				AAdd(aItNF,{"D2_ITEMPV"     ,SD2->D2_ITEMPV						,Nil})				
				AAdd(aItNF,{"D2_SDOC"		,cSerNF								,Nil})
				AAdd(aItNF,{"D2_NFORI"		,SD2->D2_DOC						,Nil})
				AAdd(aItNF,{"D2_SERIORI"	,SD2->D2_SERIE						,Nil})
				AAdd(aItNF,{"D2_ITEMORI"	,SD2->D2_ITEM						,Nil})
				AAdd(aItNF,{"D2_NUMLOTE"    ,SD2->D2_NUMLOTE					,Nil})
				AAdd(aItNF,{"D2_DTVALID"    ,SD2->D2_DTVALID					,Nil})					
				AAdd(aItNF,{"D2_LOTECTL"    ,SD2->D2_LOTECTL					,Nil})
					
				If aItNF[aScan(aItNF,{|x| AllTrim(x[1]) == "D2_QUANT"}),2] > 0
					AAdd(aItsNF,aItNF)
				EndIf
				AADD(_aRecNFs,SD2->(RECNO()))
				aItNF := {}
				SD2->(DbSkip())

			EndDo

			Begin Transaction 
			
			aParams	:=	{	SPACE(Len(SD2->D2_DOC))	,Replicate('z',Len(SD2->D2_DOC)),; 	//Pedido de - ate
							SPACE(Len(SA1->A1_COD))		,Replicate('z',Len(SA1->A1_COD))   ,; 	//Cliente de - ate
							SPACE(Len(SA1->A1_LOJA))	,Replicate('z',Len(SA1->A1_LOJA))  ,; 	//Loja de - ate
							SPACE(Len(SB1->B1_GRUPO))	,Replicate('z',Len(SB1->B1_GRUPO)) ,; 	//Grupo de - ate
							SPACE(Len(SA1->A1_AGREG))	,Replicate('z',Len(SA1->A1_AGREG)) ,;  //Agregador de - ate
							2 /*mv_par01*/	,       2 /*mv_par02*/,                         2 /*mv_par03*/  ,; 	//lDigita # lAglutina # lGeraLanc
							2			,                                                    ; 	//Trazer pedidos marcados ? 1 - Sim;2 - Nao
							2 /*mv_par04*/    ,                                                    ;  //Atualiza vinculo  ? 1 - Sim;2 - Nao                
							1           ,                                                    ;  //Aglutina por  ? 1 - Pedido;2 - Grupo;3 - Agregador;4 - Cliente;5 - Nao aglutina
							0			,  	                                                 ;  //Valor Minimo 
							2           ,                                                    ;  //Fatura Proforma  ?   1 - Sim;2 - Nao
							SPACE(Len(SC5->C5_TRANSP))	,Replicate('z',Len(SC5->C5_TRANSP)),;	//Transportadora de - ate
							2			, 													 ;  //Reajusta na mesma nota  ?   1 - Sim;2 - Nao
							1           ,                                                    ;  //Fatura Pedido pela ?   1 - Moeda do pedido;2 - Moeda selecionada     
							1           ,                                                    ;  //Fatura pela Moeda  ?   1 - Moeda 1;2 - Moeda 2;3 - Moeda 3;4 - Moeda 4;5 - Moeda 5     
							1           ,													 ;	//Contabiliza por ?   1 - Nota;2 - Total das Notas         
							1           }														//Tipo Pedido ?   1 - Normal;2 - Beneficiamento     

	 		lInverte	:=	(aParams[14] == 1)
	 		lConsig		:=	(aParams[18] == 1)							

			DbSelectArea('SD2')
			SD2->(DbSetOrder(1)) //D2_FILIAL+D2_COD+D2_LOCAL+D2_NUMSEQ

			aNotaGera := {}
			MsAguarde({|| aNotas :=	A468nFatura("SD2",aParams,@_aRecNFs,,.F.,.T.,@aNotaGera,.T.,cSerNF,cNumero)},STR0034,STR0035,.F.)	// "Preparing" - 	"Generating Invoices"	

			//Limpando o titulo
			_aRecNFs := {}

			// Verifica se tem erro
			If lMSErroAuto
				lRetNF	:= .F.
				MostraErro()
			EndIf                       
				
			If lRetNf

				//Ajuste Itens NF
				DbSelectArea('SD2')
				SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				cChave := SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
				SD2->(DbSeek(cChave))

				If Found()

					//Ajuste Cabecalho Remito
					DbSelectArea('SF2')
					SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
					SF2->(DbSeek(aNFS[nCount,9]+aNFS[nCount,1]+aNFS[nCount,2]+aNFS[nCount,3]+aNFS[nCount,4]))

					If Found()
						RecLock('SF2',.F.)
						SF2->F2_STATUSR := '2'
						SF2->(MsUnlock())
					EndIf

					//Ajuste Cabecalho Remito - Browse
					If !IsBlind()
						DbSelectArea(cAliasBR)
						(cAliasBR)->(DbSetOrder(1))
						(cAliasBR)->(DbSeek(aNFS[nCount,9]+aNFS[nCount,1]+aNFS[nCount,2]+aNFS[nCount,3]+aNFS[nCount,4]))

						If Found()
							RecLock(cAliasBR,.F.)
							(cAliasBR)->F2_STATUSR := '2'
							(cAliasBR)->(MsUnlock())
						EndIf
					EndIf

					//Ajuste Itens Remito
					DbSelectArea('SD2')
					SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
					SD2->(DbSeek(aNFS[nCount,9]+aNFS[nCount,1]+aNFS[nCount,2]+aNFS[nCount,3]+aNFS[nCount,4]))

					If Found()
						While SD2->(!EOF()) .And. aNFS[nCount,9]+aNFS[nCount,1]+aNFS[nCount,2]+aNFS[nCount,3]+aNFS[nCount,4] == SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
							RecLock('SD2',.F.)
							SD2->D2_QTDEFAT := SD2->D2_QTDAFAT
							SD2->D2_QTDAFAT := 0 
							SD2->(MsUnlock())
							SD2->(DbSkip())
						EndDo
					EndIf

				EndIf
				DbSelectArea('SD2')
				SD2->(DbSetOrder(1)) //D2_FILIAL+D2_COD+D2_LOCAL+D2_NUMSEQ
			Else
				DisarmTransaction()		
			EndIf

			End Transaction
			aItsNF	:= {}
			aCabNF 	:= {}

			If !IsBlind()
				oProcesB:IncRegua2() 
			EndIf

		Next nCount
	EndIf

	If !IsBlind()
		oProcesB:IncRegua1() 	
		oBrowEF:GoTop(.T.)
		oBrowEF:Refresh()
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraDados
Gera dados nas tabelas temporarias

@author Thiago Berna

@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraDados(oProcess,lEnd,cFunc,cAliasED)

	Local cQry			:= ''
	Local cAliasGD		:= GetNextAlias()	

	Default cFunc		:= ''
	Default cAliasED	:= GetNextAlias()	

	cQry := " SELECT * "
	cQry += " FROM " + RetSqlTab("SF2") + " (NOLOCK)"
	cQry += " WHERE SF2.F2_FILIAL = '" + xFilial('SF2') + "' "	
	cQry += " AND SF2.F2_TIPODOC =  '50' "

	If cFunc == 'MATA475EF'
		cQry += " AND SF2.F2_STATUSR in (' ','0','1') "
		//temporario		
		cQry += " AND SF2.F2_DOC = '"+ (cAliasBR)->F2_DOC + "' "
	EndIf

	cQry += " AND SF2.D_E_L_E_T_ = ' ' "

	cQry := ChangeQuery(cQry)

	If Select(cAliasGD) > 0
		DbSelectArea(cAliasGD)
		(cAliasGD)->(DbCloseArea())
	EndIf

	MsAguarde({|| DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry),cAliasGD, .F., .T.)}, OemToAnsi(STR0029)) //"Selecting Data..."

	DbSelectArea(cAliasGD)
	(cAliasGD)->(DBGoTop())

	While (cAliasGD)->(!Eof())
		RecLock(cAliasED,.T.)
		(cAliasED)->F2_FILIAL		:= (cAliasGD)->F2_FILIAL
		(cAliasED)->F2_EMISSAO		:= STOD((cAliasGD)->F2_EMISSAO)
		(cAliasED)->F2_DOC			:= (cAliasGD)->F2_DOC
		(cAliasED)->F2_SERIE		:= (cAliasGD)->F2_SERIE
		(cAliasED)->F2_CLIENTE		:= (cAliasGD)->F2_CLIENTE
		(cAliasED)->F2_LOJA			:= (cAliasGD)->F2_LOJA
		(cAliasED)->F2_COND			:= (cAliasGD)->F2_COND
		(cAliasED)->F2_FRETE		:= (cAliasGD)->F2_FRETE
		(cAliasED)->F2_DESPESA		:= (cAliasGD)->F2_DESPESA
		(cAliasED)->F2_SEGURO		:= (cAliasGD)->F2_SEGURO	
		(cAliasED)->F2_STATUSR		:= (cAliasGD)->F2_STATUSR
		(cAliasED)->F2_TXMOEDA		:= (cAliasGD)->F2_TXMOEDA

		//teste-MF
		//criar parametro
		MV_PAR04 := 0

		If cFunc == 'MATA475EF'
			//temporario
			
			If ((dDataBase - STOD((cAliasGD)->F2_EMISSAO)) >= MV_PAR04) .Or. (cAliasGD)->F2_STATUSR == '1'
				(cAliasED)->F2_OK := cMarca
			EndIf
		EndIf

		(cAliasED)->(MsUnlock())
		(cAliasGD)->(DbSkip())
	Enddo

	If Select(cAliasGD) > 0
		DbSelectArea(cAliasGD)
		(cAliasGD)->(DbCloseArea())
	EndIf

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaPesq
Array de pesquisa das tabelas temporarias

@author Thiago Berna

@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MontaPesq(aCampos)

	Local aVetInfo	:= {}
	Local aAux			:= {}
	Local nPosArr		:= 0

	/*
	Estrutura do array
	[n,1] Título da pesquisa
	[n,2,1] LookUp
	[n,2,2] Tipo de dados
	[n,2,3] Tamanho
	[n,2,4] Decimal
	[n,2,5] Título do campo
	[n,2,6] Máscara
	*/

	//Indice 1 - Documento+Serie+Cliente+Loja
	If ( nPosArr := aScan(aCampos , {|x| x[2] == "F2_DOC" } ) ) > 0
		AAdd(aAux, { aCampos[nPosArr,2] , aCampos[nPosArr,3] , aCampos[nPosArr,4] , aCampos[nPosArr,5] , aCampos[nPosArr,1] , aCampos[nPosArr, 6] } )
	EndIf
	If ( nPosArr := aScan(aCampos , {|x| x[2] == "F2_SERIE" } ) ) > 0
		AAdd(aAux, { aCampos[nPosArr,2] , aCampos[nPosArr,3] , aCampos[nPosArr,4] , aCampos[nPosArr,5] , aCampos[nPosArr,1] , aCampos[nPosArr, 6] } )
	EndIf
	If ( nPosArr := aScan(aCampos , {|x| x[2] == "F2_CLIENTE" } ) ) > 0
		AAdd(aAux, { aCampos[nPosArr,2] , aCampos[nPosArr,3] , aCampos[nPosArr,4] , aCampos[nPosArr,5] , aCampos[nPosArr,1] , aCampos[nPosArr, 6] } )
	EndIf
	If ( nPosArr := aScan(aCampos , {|x| x[2] == "F2_LOJA" } ) ) > 0
		AAdd(aAux, { aCampos[nPosArr,2] , aCampos[nPosArr,3] , aCampos[nPosArr,4] , aCampos[nPosArr,5] , aCampos[nPosArr,1] , aCampos[nPosArr, 6] } )
	EndIf

	AAdd(aVetInfo , { OemToAnsi(STR0024) , aClone( aAux ) } ) //"Invoice+Series+Customer+Unit"
	aSize(aAux , 0)

Return aVetInfo

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA475FL
Validacao de campos do GetDados

@author Thiago Berna

@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function MATA475FL()

	Local lRet 			:= .T.
	Local cFieldEdit	:= SubStr(ReadVar(),4,Len(ReadVar()))
	Local nPos			:= oGetd:nAT

	If Altera
		//Verifica se o usuario tem permissao de alteracao.
		If cFieldEdit $ "D2_DESCON"
			If &(ReadVar()) >= aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRUNIT"})]
				Help(" ",1,"D2_DESCON",,,1,0)
				lRet := .F.
			Else
				aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRCVEN"})]	:= ((aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRUNIT"})] -;
				&(ReadVar())))
				aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TOTAL"})] 	:= ((aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] -;
				aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})])) * ((aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRCVEN"})] ))				
			EndIf
		EndIf

		If cFieldEdit $ "D2_QTDEDEV"
			If &(ReadVar()) > aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})]
				Help(" ",1,"D2_QTDEDEV",,,1,0)
				lRet := .F.
			Else
				aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TOTAL"})] := ((aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] -;
				&(ReadVar()))) * (    aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRCVEN"})] )
			EndIf
		EndIf

		If cFieldEdit $ "D2_PRCVEN"
			If &(ReadVar()) <= 0 
				Help(" ",1,"D2_PRCVEN",,,1,0)
				lRet := .F.
			Else
				aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TOTAL"})] := ((aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})] -;
				aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QTDEDEV"})])) * (&(ReadVar()))
				aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_DESCON"})] := aCols[nPos,aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRUNIT"})] -;
				&(ReadVar())
			EndIf
		EndIf

		aDuplFin := {}

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMarkAll
Controle de marcacao de todos os itens no FWMarkBrowse

@author Thiago Berna

@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetMarkAll(cMarca,lMarcar,cAliasBR )

	Local aAreaMark  := (cAliasBR)->( GetArea() )

	dbSelectArea(cAliasBR)
	(cAliasBR)->( dbGoTop() )

	While !(cAliasBR)->( Eof() )
		//temporario
		If (cAliasEF)->F2_DOC == (cAliasBR)->F2_DOC
			If (lMarcar == .T. .And. ValMark((cAliasBR)->F2_DOC)) .Or. lMarcar == .F.
				RecLock( (cAliasBR), .F. )
				(cAliasBR)->F2_OK := IIf( lMarcar, cMarca, '  ' )
				MsUnLock()
			EndIf
		EndIF
		(cAliasBR)->( dbSkip() )
	EndDo

	RestArea( aAreaMark )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ValMArk
Validacao de Marcacao de itens no FWMarkBrowse

@author Thiago Berna

@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValMArk(cDoc)

	Local lRet := .T.
	Default cDoc	:= ''

	If Empty(cDoc)
		cDoc := (cAliasEF)->F2_DOC
	EndIf

	//Alteração temporária para acerto da rotina.
	If Alltrim((cAliasEF)->F2_OK) == '' .And. cDoc == (cAliasBR)->F2_DOC
		If ((dDataBase - (cAliasEF)->F2_EMISSAO) >= MV_PAR04) .Or. (cAliasEF)->F2_STATUSR == '1'
			lRet := .T.
		ElseIf MV_PAR05 == 1
			lRet := MsgYesNo(OemToAnsi(STR0025),OemToAnsi(STR0026) + ' ' + AllTrim(cDoc) + ' ' + OemToAnsi(STR0027)) //"Do you want to select? - "Document" - "Out of time!"
		Else
			lRet := .T.
		EndIf

		If Empty((cAliasEF)->(F2_COND))
			If Empty(Posicione('SA1',1,xFilial('SA1')+(cAliasEF)->(F2_CLIENTE)+(cAliasEF)->(F2_LOJA),'A1_COND'))
				Help(" ",1,"F2_COND",,,1,0)
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MATA475DP
Ponto de entrada para permitir ajuste nos titulos financeiros

@author Thiago Berna

@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
User Function MATA475DP

	Local aDup		:= {}
	Local aDuplOri 	:= PARAMIXB[1]
	Local aArea		:= GetArea()
	Local nCount
	Local cParcela	:= 'A'
	Local dEmiOri	:= STOD('')

	If isInCallStack("MATA475P2")

		dEmiOri		:= Posicione('SF2',1,xFilial('SF2')+SF2->F2_NFORI+SF2->F2_SERIORI+SF2->F2_CLIENTE+SF2->F2_LOJA,'F2_EMISSAO')
		aDuplFin 	:= Condicao(MaFisRet(,"NF_VALMERC"),cCondicao,0.00,dEmiOri,0.00)

	EndIf

	If Len(aDuplFin) > 0
		For nCount := 1 to Len(aDuplFin)
			AADD(aDup,SubStr(aDuplOri[1],1,18)+cParcela+' ³'+DTOC(aDuplFin[nCount,1])+'³ '+IIF(isInCallStack("MATA475P2"),Transform(aDuplFin[nCount,2],PesqPict("SD2","D2_TOTAL")),aDuplFin[nCount,2]))
			cParcela := Soma1(cParcela)

		Next nCount
	Else
		aDup := aClone(aDuplOri)
	EndIf

	RestArea(aArea)

Return aDup

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA475SC
Permite a execucao da rotina de efetivacao via Schedule ou Job

@author Thiago Berna

@since 11/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function MATA475SC(aEmp)

	Local cQry			:= ''
	Local cAliasSC		:= GetNextAlias()	
	Local cSerRem		:= ''
	Local cSerNF		:= ''
	Local cPV			:= ''
	Local cPrepare		:= ''
	Local cPerg			:= 'MATA475'
	Local aNFS			:= {}

	Default aEmp 		:= {}

	cPrepare := GetJobProfString("PREPAREIN" , "(UNDEFINED)" )

	If cPrepare != '' .And. Len(aEmp) == 0
		AaDD(aEmp,SubStr(cPrepare,1,2))
		AaDD(aEmp,SubStr(cPrepare,4,2))
	EndIf

	RPCSetType(3)
	RPCSetEnv(aEmp[1],aEmp[2],,,'FAT',getEnvServer(), {"SA1","SF2"} )

	Pergunte(cPerg, .F.) //Carga preguntas M

	cSerRem	:= Alltrim(MV_PAR01)
	cSerNF	:= Alltrim(MV_PAR02)

	cQry := " SELECT * "
	cQry += " FROM " + RetSqlTab("SF2") + " (NOLOCK)"
	cQry += " WHERE SF2.F2_FILIAL = '" + xFilial('SF2') + "' "	
	cQry += " AND SF2.F2_TIPODOC =  '50' "
	cQry += " AND SF2.F2_STATUSR in (' ','0','1') "
	cQry += " AND SF2.D_E_L_E_T_ = ' ' "

	cQry := ChangeQuery(cQry)

	ConOut(cQry)

	If Select(cAliasSC) > 0
		DbSelectArea(cAliasSC)
		(cAliasSC)->(DbCloseArea())
	EndIf

	MsAguarde({|| DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry),cAliasSC, .F., .T.)}, OemToAnsi(STR0029)) //"Selecting Data..."

	DbSelectArea(cAliasSC)
	(cAliasSC)->(DBGoTop())

	While (cAliasSC)->(!Eof())

		If ((dDataBase - STOD((cAliasSC)->F2_EMISSAO)) >= MV_PAR04) .Or. (cAliasSC)->F2_STATUSR == '1'

			AAdd(aNFS,{(cAliasSC)->(F2_DOC),;
						(cAliasSC)->(F2_SERIE),;
						(cAliasSC)->(F2_CLIENTE),;
						(cAliasSC)->(F2_LOJA),;
						IIF(!Empty((cAliasSC)->(F2_COND)),(cAliasSC)->(F2_COND),Posicione('SA1',1,xFilial('SA1')+(cAliasSC)->(F2_CLIENTE)+(cAliasSC)->(F2_LOJA),'A1_COND')),;
						(cAliasSC)->(F2_FRETE),;
						(cAliasSC)->(F2_DESPESA),;
						(cAliasSC)->(F2_SEGURO),;
						(cAliasSC)->(F2_FILIAL),;
						(cAliasSC)->(F2_TXMOEDA)})
			
			(cAliasSC)->(DbSkip())

		EndIf

	Enddo

	If Select(cAliasSC) > 0
		DbSelectArea(cAliasSC)
		(cAliasSC)->(DbCloseArea())
	EndIf

	MATA475P2(,aNFS,,cSerNF,cPV)

	RpcClearEnv()

Return

/*/{Protheus.doc} MATA475CHK
	(Função para verificar se algum título foi baixado do intervalo para geração de Invoice.)
	@type  Function
	@author Marcos Furtado 
	@since 15/12/2020
	@version version
	@param aParams
	@return lRet

	/*/
Function MATA475CHK(aParams)

	Local cAliaSE1R	:= GetNextAlias()
	Local cQuery    := ""
	Local _cNumTitR := ""

	cQuery := " SELECT E1_FILIAL, E1_NUM, E1_VALOR, E1_SALDO "
	cQuery += " FROM " + RetSqlTab("SE1") + " (NOLOCK)"
	cQuery += " WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
	cQuery += " AND SE1.E1_NUM BETWEEN '"+aParams[01]+"' AND '"+aParams[02]+"'"
	cQuery += " AND SE1.E1_PREFIXO = 'R' "
	cQuery += " AND SE1.E1_SALDO <> SE1.E1_VALOR "
	cQuery += " AND SE1.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)

	If Select(cAliaSE1R) > 0
		DbSelectArea(cAliaSE1R)
		(cAliaSE1R)->(DbCloseArea())
	EndIf

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliaSE1R, .F., .T.)

	While !Eof()
		If (cAliaSE1R)->E1_VALOR <> (cAliaSE1R)->E1_SALDO
			_cNumTitR += (cAliaSE1R)->E1_NUM +", "
		EndIF
		DbSkip()
	End
	DbSelectArea(cAliaSE1R)
	(cAliaSE1R)->(DbCloseArea())

	If !Empty(_cNumTitR)
		_cNumTitR := SubStr(_cNumTitR,1,LEn(_cNumTitR)-2)
		cMsg := OemToAnsi(STR0030) + _cNumTitR +Chr(13)+Chr(10) //"There are posted for provisional Invoices: "
		cMsg += OemToAnsi(STR0031) //"Delete the posted to proceed."
		MsgStop( cMsg )
		Return .F.					
	EndIf

Return .T.
