#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA270.CH"
//--------------------------------- ----------------------------------
/*/{Protheus.doc} JURA270
Verbas por Pedidos

@author Willian.Kazahaya
@since 07/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA270(cProcesso, cFilFiltro)
	Local aArea     := GetArea()
	Local aAreaNSZ  := NSZ->( GetArea() )

	Default cFilFiltro := xFilial("O0W")

	NSZ->(DbSetOrder(1))
	NSZ->(DbSeek(cFilFiltro + cProcesso))

	nRet := FWExecView(STR0001, "JURA270", 4, , , , , , , , , )

	RestArea(aAreaNSZ)
	RestArea(aArea)
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados da Solicitação de documentos

@author Willian.Kazahaya
@since 05/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oModel  	:= FWLoadModel( "JURA270" )
	Local oStructNSZ := Nil
	Local oStructO0W := Nil
	Local oStructNSY := Nil
	Local aNSZ := {}
	Local aO0W := {'O0W_FILIAL','O0W_DATPED','O0W_CTPPED','O0W_DTPPED','O0W_PROGNO',;
		'O0W_CFRCOR','O0W_DFRCOR','O0W_VPEDID','O0W_VPROVA','O0W_VPOSSI',;
		'O0W_VREMOT','O0W_VINCON','O0W_VATPED','O0W_VATPRO','O0W_VATPOS',;
		'O0W_VATREM','O0W_VATINC','O0W_DTJURO','O0W_PERMUL','O0W_CODWF'}
	Local aNSY := { 'NSY_FILIAL','NSY_CAJURI','NSY_COD'   ,'NSY_DPEVLR','NSY_DPROG' ,;
		'NSY_VLCONT','NSY_VLCONA','NSY_DTJURC','NSY_DTMULC','NSY_PERMUC',;
		'NSY_CFCOR1','NSY_V1VLR' ,'NSY_CCORP1','NSY_CJURP1','NSY_MULAT1',; //1ª instância
	'NSY_V1VLRA',;
		'NSY_CFCOR2','NSY_V2VLR' ,'NSY_CCORP2','NSY_CJURP2','NSY_MULAT2',; //2ª instância
	'NSY_V2VLRA','NSY_CFMUL2','NSY_VLRMU2','NSY_CCORM2','NSY_CJURM2',;
		'NSY_MUATU2',;
		'NSY_CFCORT','NSY_TRVLR' ,'NSY_CCORPT','NSY_CJURPT','NSY_VLRMUT',; //Tribunal
	'NSY_TRVLRA','NSY_VLRMT' ,'NSY_CCORMT','NSY_CJURMT','NSY_MUATT' }

//-- Campos Valores Tributarios
	DbSelectAre("O0W")

	If ColumnPos('O0W_MULTRI') > 0
		aAdd( aO0W, 'O0W_MULTRI' )
	EndIf

	If ColumnPos('O0W_CFCMUL') > 0
		aAdd( aO0W, 'O0W_CFCMUL' )
	EndIf

	If ColumnPos('O0W_PERENC') > 0
		aAdd( aO0W, 'O0W_PERENC' )
	EndIf

	If ColumnPos('O0W_PERHON') > 0
		aAdd( aO0W, 'O0W_PERHON' )
	EndIf

	If ColumnPos('O0W_DTMULT') > 0
		aAdd( aO0W, 'O0W_DTMULT' )
	EndIf

	If ColumnPos('O0W_DETALH') > 0
		aAdd( aO0W, 'O0W_DETALH' )
	EndIf

	If ColumnPos('O0W_REDUT') > 0
		aAdd( aO0W, 'O0W_REDUT' )
		aAdd( aO0W, 'O0W_VLREDU' )
	EndIf
	oStructNSZ := FWFormStruct( 2, "NSZ", {|x| aScan(aNSZ,AllTrim(x))> 0 } )
	oStructO0W := FWFormStruct( 2, "O0W", {|x| aScan(aO0W,AllTrim(x))> 0 } )
	oStructNSY := FWFormStruct( 2, "NSY", {|x| aScan(aNSY,AllTrim(x))> 0 } )

	oView := FWFormView():New()

	oView:SetModel( oModel )

	oView:AddField( "NSZMASTER" , oStructNSZ, "NSZMASTER"  )
	oView:AddGrid(  "O0WDETAIL" , oStructO0W, "O0WDETAIL" )
	oView:AddGrid(  "NSYDETAIL" , oStructNSY, "NSYDETAIL" )

	oView:CreateHorizontalBox( "FORMRESUM" , 30 )
	oView:CreateHorizontalBox( "GRIDVALOR" , 35 )
	oView:CreateHorizontalBox( "GRIDOBJET" , 35 )

	oView:SetOwnerView( "NSZMASTER" , "FORMRESUM" )
	oView:SetOwnerView( "O0WDETAIL" , "GRIDVALOR" )
	oView:SetOwnerView( "NSYDETAIL" , "GRIDOBJET" )

	oView:SetUseCursor( .T. )
	oView:EnableControlBar( .T. )
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da Solicitação de documentos

@author Willian.Kazahaya
@since 05/02/2018
@version 1.0

@obs O0MMASTER - Dados da Solicitação de documentos
@obs O0NDETAIL - Documentos da Solicitação
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNSZ := NIL
Local oStructO0W := NIL
Local oStructNSY := NIL
Local cFldsNSZ   := 'NSZ_FILIAL|NSZ_COD|NSZ_TIPOAS|'
Local cFldsO0W   := 'O0W_FILIAL|O0W_COD|O0W_DATPED|O0W_CTPPED|O0W_DTPPED|'+;
					'O0W_PROGNO|O0W_CFRCOR|O0W_DFRCOR|O0W_VPEDID|O0W_VPROVA|'+;
					'O0W_VPOSSI|O0W_VREMOT|O0W_VINCON|O0W_VATPED|O0W_VATPRO|'+;
					'O0W_VATPOS|O0W_VATREM|O0W_VATINC|O0W_DTJURO|O0W_DTMULT|'+;
					'O0W_PERMUL|O0W_CODWF|O0W_REDUT|O0W_VLREDU|O0W_CAJURI|'
Local cFldsNSY   := 'NSY_FILIAL|NSY_CAJURI|NSY_COD|NSY_CPEVLR|NSY_DPEVLR|'+;//Detalhe
					'NSY_CPROG|NSY_DPROG|NSY_CINSTA|NSY_PEINVL|'+;
					'NSY_CCOMON|NSY_PEDATA|NSY_DTJURO|NSY_CMOPED|NSY_PEVLR|' +; //Objeto
					'NSY_DTMULT|NSY_PERMUL|NSY_TOPEAT|'+;
					'NSY_CFCORC|NSY_DTCONT|NSY_DTJURC|NSY_INECON|NSY_CMOCON|'+; //Contingência
					'NSY_DTMULC|NSY_PERMUC|NSY_VLCONT|NSY_CCORPC|NSY_CJURPC|'+;
					'NSY_PEVLRA|NSY_MULATU|NSY_CJURPE|NSY_TOPEAT|NSY_CCORPE|'+;
					'NSY_MULATC|NSY_VLCONA|NSY_TOTATC|'+;
					'NSY_CFCOR1|NSY_V1DATA|NSY_DTJUR1|NSY_CMOIN1|NSY_DTMUL1|NSY_PERMU1|'+; //1ª instância
					'NSY_V1INVL|NSY_V1VLR|NSY_CCORP1|NSY_CJURP1|NSY_MULAT1|NSY_V1VLRA|'+;
					'NSY_CFCOR2|NSY_V2DATA|NSY_CMOIN2|NSY_DTMUL2|NSY_PERMU2|'+; //2ª instância
					'NSY_CFMUL2|NSY_CMOEM2|NSY_VLRMU2|NSY_DTMUT2|NSY_DTINC2|'+;
					'NSY_CCORP2|NSY_CJURP2|NSY_MULAT2|NSY_V2VLRA|NSY_CCORM2|'+;
					'NSY_CJURM2|NSY_MUATU2|NSY_V2INVL|NSY_DTJUR2|NSY_V2VLR|' +;
					'NSY_CFCORT|NSY_TRDATA|NSY_CMOTRI|NSY_DTMUTR|NSY_PERMUT|'+; //Tribunal
					'NSY_CFMULT|NSY_CMOEMT|NSY_VLRMT|NSY_DTMUTT|NSY_DTINCT|'+;
					'NSY_CCORPT|NSY_CJURPT|NSY_VLRMUT|NSY_TRVLRA|'+;
					'NSY_CCORMT|NSY_CJURMT|NSY_MUATT|NSY_TRINVL|'+;
					'NSY_DTJURT|NSY_TRVLR|NSY_CVERBA|NSY_REDUT|' //Outros

	//-- Campos Valores Tributários
	DbSelectAre("O0W")

	If ColumnPos('O0W_MULTRI') > 0
		cFldsO0W += 'O0W_MULTRI|'
	EndIf

	If ColumnPos('O0W_CFCMUL') > 0
		cFldsO0W += 'O0W_CFCMUL|'
	EndIf

	If ColumnPos('O0W_PERENC') > 0
		cFldsO0W +=  'O0W_PERENC|'
	EndIf

	If ColumnPos('O0W_PERHON') > 0
		cFldsO0W += 'O0W_PERHON|'
	EndIf

	If ColumnPos('O0W_DTMULT') > 0
		cFldsO0W += 'O0W_DTMULT|' 
	EndIf

	If ColumnPos('O0W_DETALH') > 0
		cFldsO0W += 'O0W_DETALH|'
	EndIf

	//-------------------------------------------------------------------------
	//Monta a estrutura do formulário com base no dicionário de dados usando
	//somente os campos dos Arrays
	//-------------------------------------------------------------------------
	oStructNSZ  := FWFormStruct( 1, "NSZ", {|x| AllTrim(x) +'|' $ cFldsNSZ },,.F. )
	oStructO0W  := FWFormStruct( 1, "O0W", {|x| AllTrim(x) +'|' $ cFldsO0W },,.F. )
	oStructNSY  := FWFormStruct( 1, "NSY", {|x| AllTrim(x) +'|' $ cFldsNSY },,.F. )

	addFldStruct(oStructO0W,"O0W_DTPPED")

	// Inclui as validações nos campos. Não está no Dicionário pois usa elementos do Modelo
	oStructO0W:SetProperty('O0W_CTPPED',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| ExistCpo('NSP', FwFldGet("O0W_CTPPED"),1).AND.JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt)})
	oStructO0W:SetProperty('O0W_DATPED',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt)})
	oStructO0W:SetProperty('O0W_DTJURO',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt)})
	oStructO0W:SetProperty('O0W_DTMULT',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt)})
	oStructO0W:SetProperty('O0W_PERMUL',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt)})
	oStructO0W:SetProperty('O0W_CFRCOR',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt)})
	oStructO0W:SetProperty('O0W_VPEDID',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt), JUpdTotal('00',oModel,       ,      , oModelAtu)})
	oStructO0W:SetProperty('O0W_VPROVA',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt), JUpdTotal('01',oModel,nValAtu,nLinha, oModelAtu)})
	oStructO0W:SetProperty('O0W_VPOSSI',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt), JUpdTotal('02',oModel,nValAtu,nLinha, oModelAtu)})
	oStructO0W:SetProperty('O0W_VREMOT',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt), JUpdTotal('03',oModel,nValAtu,nLinha, oModelAtu)})
	oStructO0W:SetProperty('O0W_VINCON',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt), JUpdTotal('04',oModel,nValAtu,nLinha, oModelAtu)})

	//-- Campos Valores Tributários
	DbSelectArea("O0W")
	If ColumnPos('O0W_MULTRI') > 0
		oStructO0W:SetProperty('O0W_MULTRI',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt)})
	EndIf

	If ColumnPos('O0W_CFCMUL') > 0
		oStructO0W:SetProperty('O0W_CFCMUL',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| (Vazio().OR.ExistCpo('NW7', FwFldGet("O0W_CFCMUL"),1)).AND.JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt)})
	EndIf

	If ColumnPos('O0W_PERENC') > 0
		oStructO0W:SetProperty('O0W_PERENC',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt)})
	EndIf

	If ColumnPos('O0W_PERHON') > 0
		oStructO0W:SetProperty('O0W_PERHON',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt)})
	EndIf

	If ColumnPos('O0W_REDUT') > 0
		oStructO0W:SetProperty('O0W_REDUT',MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt)})
	EndIf


	oStructO0W:SetProperty('O0W_VPOSSI',MODEL_FIELD_WHEN, {|| .F.})
	oStructO0W:SetProperty('O0W_VATPED',MODEL_FIELD_WHEN, {|| .F.})
	oStructO0W:SetProperty('O0W_VATPOS',MODEL_FIELD_WHEN, {|| .F.})
	oStructO0W:SetProperty('O0W_VATPRO',MODEL_FIELD_WHEN, {|| .F.})
	oStructO0W:SetProperty('O0W_VATREM',MODEL_FIELD_WHEN, {|| .F.})
	oStructO0W:SetProperty('O0W_VATINC',MODEL_FIELD_WHEN, {|| .F.})

	// Remoção das Validações pois estão centralizadas nos Modelos padrão
	oStructNSY:SetProperty('NSY_CPEVLR',MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty('NSY_CINSTA',MODEL_FIELD_VALID,{|| .T. })
	
	oStructNSY:SetProperty('NSY_CMOCON',MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty('NSY_DTJURC',MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty('NSY_DTMULC',MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty('NSY_PERMUC',MODEL_FIELD_VALID,{|| .T. })

	oStructNSY:SetProperty("NSY_CFCOR1",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_V1DATA",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_CMOIN1",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_DTMUL1",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_PERMU1",MODEL_FIELD_VALID,{|| .T. })

	oStructNSY:SetProperty("NSY_CFCOR2",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_V2DATA",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_CMOIN2",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_DTMUL2",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_PERMU2",MODEL_FIELD_VALID,{|| .T. })

	oStructNSY:SetProperty("NSY_CFCORT",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_TRDATA",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_CMOTRI",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_DTMUTR",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_PERMUT",MODEL_FIELD_VALID,{|| .T. })

	oStructNSY:SetProperty("NSY_CFMUL2",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_CFMULT",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_CMOEM2",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_CMOEMT",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_VLRMU2",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_VLRMT" ,MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_DTMUT2",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_DTMUTT",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_DTINC2",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty("NSY_DTINCT",MODEL_FIELD_VALID,{|| .T. })
	oStructNSY:SetProperty('NSY_REDUT' ,MODEL_FIELD_VALID,{|| .T. })

	oStructNSY:SetProperty('NSY_CFMUL2',MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty('NSY_CMOEM2',MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty('NSY_VLRMU2',MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty('NSY_DTMUT2',MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty('NSY_DTINC2',MODEL_FIELD_WHEN, {|| .T.})

	oStructNSY:SetProperty('NSY_CFMULT',MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty('NSY_CMOEMT',MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty('NSY_VLRMT' ,MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty('NSY_DTMUTT',MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty('NSY_DTINCT',MODEL_FIELD_WHEN, {|| .T.})

	oStructO0W:RemoveField( "NSY_CAJURI" )
	oStructNSY:RemoveField( "NSY_CVERBA" )

	//-------------------------------------------------------------------------
	//Monta o modelo do formulário
	//-------------------------------------------------------------------------
	// Parte do resumo
	oModel:= MPFormModel():New( "JURA270", /*Pre-Validacao*/, {|oModel| J270TOK(oModel)}/*Pos-Validacao*/, {|oModel| J270Commit(oModel)}/*Commit*/, /*Cancel*/)
	oModel:SetDescription( STR0001 )
	oModel:AddFields( "NSZMASTER", /*cOwner*/, oStructNSZ, /*bPre-Pre-Validacao*/,/*Pos-Validacao*/, /*Carregamento*/)

	// Grid da Verba
	oModel:AddGrid( "O0WDETAIL", "NSZMASTER" /*cOwner*/, oStructO0W, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/)
	oModel:GetModel( 'O0WDETAIL' ):SetUniqueLine({"O0W_COD"})
	oModel:SetRelation( "O0WDETAIL", { { "O0W_FILIAL", "xFilial('O0W')" }, { "O0W_CAJURI", "NSZ_COD" } }, O0W->( IndexKey( 1 ) ) )
	oModel:SetOptional( 'O0WDETAIL' , .T. )

	// Grid dos valores
	oModel:AddGrid( "NSYDETAIL", "O0WDETAIL" /*cOwner*/, oStructNSY, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	oModel:GetModel( 'NSYDETAIL' ):SetUniqueLine({"NSY_COD"})
	oModel:SetRelation( "NSYDETAIL", { { "NSY_FILIAL", "xFilial('O0W')" }, { "NSY_CVERBA", "O0W_COD"}, { "NSY_CAJURI", "NSZ_COD"} }, NSY->( IndexKey( 1 ) ) )
	oModel:GetModel( 'NSYDETAIL' ):SetDelAllLine( .F. )
	oModel:GetModel( 'NSYDETAIL' ):SetNoInsertLine(.F.)
	oModel:SetOptional( 'NSYDETAIL' , .F. )

	oModel:GetModel( "NSZMASTER" ):SetDescription( 'Objetos e Valores' )
	oModel:GetModel( "O0WDETAIL" ):SetDescription( 'Verbas' )
	oModel:GetModel( "NSYDETAIL" ):SetDescription( 'Valores' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J270Commit
Valida informações Commit

@param  oModel Model a ser verificado
@Return lRet   .T./.F. As informações são válidas ou não
@author Willian.Kazahaya
@since 05/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J270Commit(oModel)

Local aArea      := GetArea()
Local aAreaNSZ   := NSZ->( GetArea() )
Local cFilProc   := xFilial("NSZ")
Local cProcesso  := oModel:GetValue("NSZMASTER", "NSZ_COD")
Local cPrognost  := ""
Local nVlrPro    := 0
Local nVlrProAtu := 0
Local aVlEnvolvi := {}
Local dData      := Date()
//Código da moeda utilizada nos valores envolvidos\provisão no processo quando estes valores vierem dos objetos
Local cMoeCod    := SuperGetMv("MV_JCMOPRO", .F., "01")
Local oMdl95     := Nil
Local lRet       := .F.
Local aVlrPro    := {}
Local nVCProAtu  := 0
Local nVJProAtu  := 0
Local oModelO0W  := oModel:GetModel("O0WDETAIL")
Local lAtuRedut  := .F.
Local nLinhaO0W  := oModelO0W:getQtdLine()
Local nI         := 0
Local cVerba     := ''

	DbSelectArea("O0W")
	If ColumnPos('O0W_REDUT') > 0
		lAtuRedut := .T.
	EndIf
	O0W->(DbCloseArea())

	Private cTipoAsJ   := oModel:GetValue("NSZMASTER", "NSZ_TIPOAS")
	Private C162TipoAs := cTipoAsJ

	//Realiza a Gravação do Model
	Begin Transaction

		// Ajusta a correção e juros na NV3 
		JurHisCont(cProcesso,, Date(), 0 , '2', '1', 'NSZ',3)
		JurHisCont(cProcesso,, Date(), 0 , '3', '1', 'NSZ',3)

		lRet := FwFormCommit( oModel )

		If lRet
			// Pega a linha da O0W que foi alterada para a atualização de valores
			for nI := 1 to nLinhaO0W
				If !oModelO0W:IsDeleted(nI)
					If oModelO0W:isFieldUpdate("O0W_VPEDID",nI) .Or. oModelO0W:isFieldUpdate("O0W_VPROVA",nI) .Or.;
							oModelO0W:isFieldUpdate("O0W_VINCON",nI) .Or. oModelO0W:isFieldUpdate("O0W_VREMOT",nI) .Or.;
							oModelO0W:isFieldUpdate("O0W_CFRCOR",nI) .Or. oModelO0W:isFieldUpdate("O0W_DATPED",nI)

						cVerba := oModelO0W:getValue("O0W_COD",nI)
					EndIf

					//Atualiza Valores
					JURCORVLRS('NSY', cProcesso, , , , .T., cVerba)
				EndIf
			next nI

			JAtuValO0W(cProcesso)
			If lAtuRedut
				J270AtuRed(oModelO0W)
			EndIf

			//Busca prognóstico dos objetos
			cPrognost  := J94ProgObj(cFilProc, cProcesso)

			//Busca valor provavel
			nVlrPro    := JA094VlDis(cProcesso, "1", .F.)

			//Busca valor provavel atualizado
			aVlrPro := JA094VlDis(cProcesso, "1", .T.,,.T.)
			nVlrProAtu := aVlrPro[1][1] // Valor atualizado
			nVCProAtu  := aVlrPro[1][2] // Valor de correção Atualizado
			nVJProAtu  := aVlrPro[1][3] // Valor de Juros Atualizado

			oMdl95 := FWLoadModel("JURA095")
			oMdl95:SetOperation(4)
			oMdl95:Activate()

			DbSelectArea("NSZ")
			NSZ->( DbSetOrder(1) )  //-- NSZ_FILIAL + NSZ_COD

			//-- Atualiza as informações nos campos do processo - NSZ
			If NSZ->( DbSeek(cFilProc + cProcesso) )
				//Busca valores envolvidos
				aVlEnvolvi := JA094VlEnv(cProcesso, cFilProc)

				If !Empty(cPrognost)
					oMdl95:LoadValue("NSZMASTER", "NSZ_CPROGN", cPrognost)
				EndIf

				oMdl95:LoadValue("NSZMASTER", "NSZ_VLPROV", nVlrPro   )
				oMdl95:LoadValue("NSZMASTER", "NSZ_VAPROV", nVlrProAtu )
				oMdl95:LoadValue("NSZMASTER", "NSZ_VCPROV", nVCProAtu   )
				oMdl95:LoadValue("NSZMASTER", "NSZ_VJPROV", nVJProAtu   )

				If (nVlrPro ) > 0
					oMdl95:LoadValue("NSZMASTER", "NSZ_DTPROV", dData    )
					oMdl95:LoadValue("NSZMASTER", "NSZ_CMOPRO", cMoeCod  )
				Else
					oMdl95:LoadValue("NSZMASTER", "NSZ_DTPROV", CtoD("") )
					oMdl95:LoadValue("NSZMASTER", "NSZ_CMOPRO", "" )
				EndIf

				oMdl95:LoadValue("NSZMASTER", "NSZ_VLENVO", aVlEnvolvi[1][1] )
				oMdl95:LoadValue("NSZMASTER", "NSZ_VAENVO", aVlEnvolvi[1][2] )
				oMdl95:LoadValue("NSZMASTER", "NSZ_VCENVO", aVlEnvolvi[1][3] )
				oMdl95:LoadValue("NSZMASTER", "NSZ_VJENVO", aVlEnvolvi[1][4] )

				If aVlEnvolvi[1][1] > 0
					oMdl95:LoadValue("NSZMASTER", "NSZ_DTENVO", dData     )
					oMdl95:LoadValue("NSZMASTER", "NSZ_CMOENV", cMoeCod   )
				Else
					oMdl95:LoadValue("NSZMASTER", "NSZ_DTENVO", CtoD("")  )
					oMdl95:LoadValue("NSZMASTER", "NSZ_CMOENV", "" )
				EndIf
			EndIf

			lRet := oMdl95:VldData()

			If lRet
				lRet := oMdl95:CommitData()
			EndIf

			If !lRet
				oModel:aErrorMessage := oMdl95:aErrorMessage
				JurMsgErro(oModel:aErrorMessage[6],STR0015,oModel:aErrorMessage[7])
				DisarmTransaction()
			EndIf
		EndIf
	End Transaction

	If FWAliasInDic("O13")
		GravaHistPed(oModel) // Faz a gravação do histórico de alterações de pedidos
	EndIf

	RestArea(aAreaNSZ)
	RestArea(aArea)
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JAtuValO0W(cCajuri)
Atualização de Valores na O0W

@param  cCajuri - Assunto Juridico

@Return lRet    - .T./.F. As informações são válidas ou não

@author Willian.Kazahaya
@since 20/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAtuValO0W(cCajuri)
Local aArea      := GetArea()
Local aAreaO0W   := O0W->(GetArea())
Local cQuery     := ""
Local cQrySel    := ""
Local cQryFrm    := ""
Local cQryWhr    := ""
Local cQryOrd    := ""
Local cAlias     := ""
Local cChaveAnt  := ""
Local cChaveAtu  := ""
Local nValorAtu  := 0
Local aValores   := {}
Local nX         := 0
Local nAtuPro    := 0
Local nAtuPos    := 0
Local nAtuRem    := 0
Local nAtuInc    := 0
Local nAtuPed    := 0
Local lGrava     := .F.
Local lGuardaVlr := .F.

	cQrySel += "SELECT NSY.NSY_COD, "
	cQrySel +=        "NSY.NSY_CVERBA, "
	cQrySel +=        "NSY.NSY_CPEVLR, "
	cQrySel +=        "NSY.NSY_CPROG, "
	cQrySel +=        "NSY.NSY_CFCORC, "
	cQrySel +=        "NSY.NSY_VLCONT, "
	cQrySel +=        "NSY.NSY_DTCONT, "
	cQrySel +=        "NSY.NSY_VLCONA, "
	cQrySel +=        "NSP.NSP_DESC, "
	cQrySel +=        "NSP.NSP_TIPO, "
	cQrySel +=        "NQ7.NQ7_TIPO, "
	cQrySel +=        "NSY.NSY_TRVLRA, " // Honorários Atualizados
	cQrySel +=        "NSY.NSY_TRVLR, "  // Honorários
	cQrySel +=        "NSY.NSY_MUATT, "  // Honorários sobre a Multa Atualizada
	cQrySel +=        "NSY.NSY_VLRMT, "  // Honorários sobre a Multa
	cQrySel +=        "NSY.NSY_V2VLRA, " // Encargos Atualizados
	cQrySel +=        "NSY.NSY_V2VLR, "  // Encargos
	cQrySel +=        "NSY.NSY_MUATU2, " // Encargos sobre a Multa Atualizada
	cQrySel +=        "NSY.NSY_VLRMU2, " // Encargos sobre a Multa
	cQrySel +=        "NSY.NSY_V1VLRA, " // Multa Atualizada
	cQrySel +=        "NSY.NSY_V1VLR "   // Multa
	cQryFrm += "FROM " + RetSqlName("NSY") + " NSY "
	cQryFrm += "INNER JOIN " + RetSqlName("NSP") + " NSP "
	cQryFrm +=       "ON (NSP.NSP_COD = NSY.NSY_CPEVLR "
	cQryFrm +=       "AND NSP.D_E_L_E_T_ = ' ') "
	cQryFrm += "INNER JOIN " + RetSqlName("NQ7") + " NQ7 "
	cQryFrm +=       "ON (NQ7.NQ7_COD = NSY.NSY_CPROG "
	cQryFrm +=       "AND NQ7.D_E_L_E_T_ = ' ') "
	cQryWhr += "WHERE NSY_CAJURI = '" + cCajuri + "' "
	cQryWhr +=  " AND NSY_FILIAL = '" + xFilial("NSY") + "' "
	cQryWhr +=  " AND NSY_CVERBA <> ' ' "
	cQryWhr +=  " AND NSY.D_E_L_E_T_ = ' ' "
	cQryOrd += "ORDER BY NSY.NSY_CVERBA, NSY.NSY_CPROG"

	cQuery := ChangeQuery(cQrySel + cQryFrm + cQryWhr + cQryOrd)

	cAlias := GetNextAlias()
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	If (cAlias)->(!Eof())

		While (cAlias)->(!Eof())
			// Atualiza a chave atual
			cChaveAtu :=  cCajuri + (cAlias)->NSY_CVERBA + (cAlias)->NSY_CPEVLR
			nValorAtu := (cAlias)->NSY_VLCONA
			// Honorários
			nValorAtu += Iif((cAlias)->NSY_TRVLRA > 0, (cAlias)->NSY_TRVLRA, (cAlias)->NSY_TRVLR)
			// Honorários sobre a Multa
			nValorAtu += Iif((cAlias)->NSY_MUATT > 0, (cAlias)->NSY_MUATT, (cAlias)->NSY_VLRMT)
			// Encargos
			nValorAtu += Iif((cAlias)->NSY_V2VLRA > 0, (cAlias)->NSY_V2VLRA, (cAlias)->NSY_V2VLR)
			// Encargos sobre a Multa
			nValorAtu += Iif((cAlias)->NSY_MUATU2 > 0, (cAlias)->NSY_MUATU2, (cAlias)->NSY_VLRMU2)
			// Multa
			nValorAtu += Iif((cAlias)->NSY_V1VLRA > 0, (cAlias)->NSY_V1VLRA, (cAlias)->NSY_V1VLR)

			aAdd(aValores,{cChaveAtu, (cAlias)->NQ7_TIPO, nValorAtu})

			(cAlias)->(dbSkip())
		EndDo

		If Len(aValores) > 0
			DBSelectArea("O0W")
			O0W->( DbSetOrder(3) ) //O0W_FILIAL + O0W_CAJURI + O0W_COD + O0W_CTPPED
			For nX := 1 To Len(aValores)
				If nX == 1 .Or. aValores[nX][1] == cChaveAnt
					lGuardaVlr := .T.
					//Se for o útimo valor, grava
					If nX == Len(aValores)
						Do Case
							Case aValores[nX][2] == '1'
								nAtuPro := aValores[nX][3]
							Case aValores[nX][2] == '2'
								nAtuPos := aValores[nX][3]
							Case aValores[nX][2] == '3'
								nAtuRem := aValores[nX][3]
							OtherWise
								nAtuInc := aValores[nX][3]
						End Case
						lGrava := .T.
					EndIf
				Else
					lGrava := .T.
					lGuardaVlr := .T.
				EndIf

				If lGrava
					If O0W->( DbSeek(xFilial("O0W") + cChaveAnt))
						//somatória dos prognósticos atualizados
						nAtuPed := nAtuPro + nAtuPos + nAtuRem + nAtuInc
						RecLock("O0W", .F.)
						// Atualiza os campos de valores atualizados
						O0W->O0W_VATPRO := nAtuPro
						O0W->O0W_VATPOS := nAtuPos
						O0W->O0W_VATREM := nAtuRem
						O0W->O0W_VATINC := nAtuInc
						O0W->O0W_VATPED := nAtuPed

						O0W->( MsUnLock() )
					EndIf
					lGrava := .F.
				EndIf

				If lGuardaVlr
					Do Case
						Case aValores[nX][2] == '1'
							nAtuPro := aValores[nX][3]
						Case aValores[nX][2] == '2'
							nAtuPos := aValores[nX][3]
						Case aValores[nX][2] == '3'
							nAtuRem := aValores[nX][3]
						OtherWise
							nAtuInc := aValores[nX][3]
					End Case
					lGuardaVlr := .F.
				EndIf

				cChaveAnt := aValores[nX][1]

			Next nX
			O0W->(DbCloseArea())
		EndIf
	EndIf

	(cAlias)->(DbCloseArea())
	RestArea(aAreaO0W)
	RestArea(aArea)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} JA270CAJUR()
Busca o Cajuri posicionado

@Return cCajuri - Cód. do Assunto Jurí­dico

@author Willian.Kazahaya
@since 05/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA270CAJUR()
	Local cCajuri := ''

	If  !( Empty(NSZ->NSZ_COD) )
		cCajuri := NSZ->NSZ_COD
	Else
		cCajuri := M->NSZ_COD
	EndIf

Return cCajuri

//-------------------------------------------------------------------
/*/{Protheus.doc} J270WhenCJ()
When do Cód. de Assunto Juridico

@Return lRet - Se o campo está habilitado ou não

@author Willian.Kazahaya
@since 05/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J270WhenCJ()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J270WnTpPd()
When do Cód. do Tipo de Pedido

@Return lRet - Se o campo está habilitado ou não

@author Willian.Kazahaya
@since 05/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J270WnTpPd()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J270ConNSP()
Consulta padrão do Tipo de Pedido

@author Willian.Kazahaya
@since 05/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J270ConNSP(cCajuri)
	Local cQuery     := ""
	Local lRet       := .F.
	Local nResult    := 0
	Local oModel     := FwModelActive()
	Local aPesq      := {"NSP_COD","NSP_DESC"}

	If Empty(cCajuri)
		cCajuri := oModel:GetValue("NSZMASTER","NSZ_COD")
	EndIf

	cQuery += " SELECT NSP_COD, NSP_DESC, NSP.R_E_C_N_O_ NSPRECNO "
	cQuery += " FROM "+RetSqlName("NSP")+" NSP"
	cQuery += " WHERE NSP_FILIAL = '"+xFilial("NSP")+"'"
	cQuery += " AND NSP.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery, .F.)

	nResult := JurF3SXB("NSP", aPesq,, .F., .F.,, cQuery)
	lRet := nResult > 0

	If lRet
		DbSelectArea("NSP")
		NSP->(dbgoTo(nResult))
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUpdTotal()
Atualiza os valores dos Campos Virtuais

@Param cTipo - Campo a ser atualizado
@Param cTipPedido - Tipo de Pedido

@Return cAvalCaso - Avaliação do Caso

@author Willian.Kazahaya
@since 05/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUpdTotal(cTipo,oModel, nValAtu, nLinAtu, oModelLin)

	If oModelLin == NIL
		oModelLin := oModel:GetModel("O0WDETAIL")
	EndIf

	//Seta o prognostico da verba alterada
	oModelLin:SetValue("O0W_PROGNO",GetAvlCaso(oModelLin:GetValue("O0W_VPROVA"),;
		oModelLin:GetValue("O0W_VPOSSI"),;
		oModelLin:GetValue("O0W_VREMOT"),;
		oModelLin:GetValue("O0W_VINCON")))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAvlCaso()
Tratamento para calcular o Prognóstico do Caso

@Param nValProvav - Valor Provavel
@Param nValPossiv - Valor Possí­vel
@Param nValRemoto - Valor Remoto
@Param nValIncont - Valor Incontroverso

@Return cProgno - Prognóstico a ser retornado

@author Willian.Kazahaya
@since 05/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetAvlCaso(nValProvav, nValPossiv, nValRemoto, nValIncont)
	Local aTipoAval := {STR0004, STR0005, STR0007, STR0006, STR0008}
	// "Provavel", "Possível", "Incontroverso", "Remoto", "Sem Prognóstico"
	Local cProgno := aTipoAval[5]

	Do Case
	Case (nValProvav > 0 )// Provável
		cProgno := aTipoAval[1]
	Case (nValPossiv > 0 )// Possível
		cProgno := aTipoAval[2]
	Case (nValIncont > 0) // Incontroverso
		cProgno := aTipoAval[3]
	Case (nValRemoto > 0) // Remoto
		cProgno := aTipoAval[4]
	OtherWise // Sem Prognóstico
		cProgno := aTipoAval[5]
	End Case

Return cProgno

//-------------------------------------------------------------------
/*/{Protheus.doc} JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt)()
Criar e atualizar o NSYDETAIL com os dados inputados na O0W

@Param oModel - Modelo atual
@Param cField - Nome do Campo Alterado
@Param nLinha - Numero da Linha alterada
@Param nValAtu - Valor Atual
@Param nValAnt - Valor anterior

@Return cProgno - Prognóstico a ser retornado

@author Willian.Kazahaya
@since 05/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JCallJ094(oModel,cField,nLinha,nValAtu,nValAnt)
Local oModelO0W  := oModel:GetModel("O0WDETAIL")
Local oModelNSY  := oModel:GetModel("NSYDETAIL")
Local cTipoPed   := oModelO0W:GetValue("O0W_CTPPED")
Local cCajuri    := oModel:GetValue("NSZMASTER", "NSZ_COD")
Local cDatPed    := oModelO0W:GetValue("O0W_DATPED")
Local cInstan    := JurGetDados('NUQ', 2, xFilial('NSZ') + cCajuri + '1',{"NUQ_COD"})
Local aTipProg   := {'1','2','3','4'}
Local cMoeda     := SuperGetMv("MV_JCMOPRO", .F., "01")
Local nValTotPed := 0
Local nValorPed  := 0
Local nI         := 0
Local nLinePoss  := 0
Local nCount     := 0
Local lRet       := .T.
Local lAdicionar := .F.
Local cCodNSY    := ""
Local cTipoProg  := ""
Local nGridNsy   := 0
Local lCposTrib  := .F.
Local lAtuRedut  := .F.

	//-- Valida se possui os campos da O0W para valores tributários
	DbSelectArea("O0W")
	If ColumnPos('O0W_MULTRI') > 0 ;         //-- Percentual de multa tribu
		.AND. ColumnPos('O0W_CFCMUL') > 0 ;  //-- Forma de correcao multa
		.AND. ColumnPos('O0W_PERENC') > 0 ;  //-- Percentual de encargos
		.AND. ColumnPos('O0W_PERHON') > 0 ;  //-- Percentual de honorario

		lCposTrib := .T.
	EndIf
	If ColumnPos('O0W_REDUT') > 0
		lAtuRedut := .T.
	EndIf

	If !IsInCallStack("JUpdValO0W")
		// Se a Data estiver vazia, coloca a data de hoje
		If Empty(cDatPed)
			oModelO0W:SetValue("O0W_DATPED",Date())
			cDatPed := oModelO0W:GetValue("O0W_DATPED")
		EndIf

		// Verifica qual o Tipo de Prognóstico a ser atualizado
		Do Case
		Case (cField == "O0W_VPROVA")
			cTipoProg := "1"
		Case (cField == "O0W_VPOSSI")
			cTipoProg := "2"
		Case (cField == "O0W_VREMOT")
			cTipoProg := "3"
		Case (cField == "O0W_VINCON")
			cTipoProg := "4"
		OtherWise
			cTipoProg := "0"
		End Case

		// Valor de Pedido
		nValTotPed := oModelO0W:GetValue("O0W_VPEDID")

		// Verifica se é uma inclusão de uma nova Verba
		lAdicionar := oModelNSY:Length(.T.) == 1
		oModelNSY:SetNoInsertLine(.F.)

		If lAdicionar
			nCount := Len(aTipProg)
		Else
			nCount := oModelNSY:Length()
		EndIf

		nGridNsy := oModelNSY:GetLine()

		For nI := 1 To nCount
			// Se for a inclusão, Seta os valores dos objetos
			If lAdicionar
				// Somente irá jogar o valor no Progn. Possivel, caso contrário é Zero
				If aTipProg[nI] == '2'
					nValorPed := nValTotPed
				Else
					nValorPed := 0
				EndIf

				cCodNSY := GetSXENum("NSY","NSY_COD",xFilial("NSY")+ cCajuri ,1)

				oModelNSY:SetValue("NSY_FILIAL", xFilial("NSY")                  )
				oModelNSY:SetValue("NSY_COD"   , cCodNSY                         )
				oModelNSY:LoadValue("NSY_CAJURI", cCajuri                        )
				oModelNSY:SetValue("NSY_CPEVLR", cTipoPed                        )
				oModelNSY:SetValue("NSY_CPROG" , JGetProgn(aTipProg[nI])[1]      )
				oModelNSY:SetValue("NSY_CINSTA", cInstan                         )
				oModelNSY:SetValue("NSY_INECON", "2"                             )
				oModelNSY:SetValue("NSY_DTCONT", cDatPed                         )
				oModelNSY:SetValue("NSY_VLCONT", nValorPed                       )
				oModelNSY:SetValue("NSY_CMOCON", cMoeda                          )
				oModelNSY:SetValue("NSY_CFCORC", oModelO0W:GetValue("O0W_CFRCOR"))
				

				// Se ainda houver outro, adiciona uma nova linha
				If nI < Len(aTipProg)
					oModelNSY:AddLine()
				EndIf
				ConfirmSX8()
			Else
				// Caso haja mais de 1 linha, é considerado alteração.
				oModelNSY:GoLine(nI)
				cCodTipPrg := JGetProgn(,oModelNSY:GetValue("NSY_CPROG"))[2]

				If !oModelNSY:IsDeleted()
					// Verifica se o Prognóstico é do tipo "Possível" para ser Atualizado depois
					If cCodTipPrg == '2'
						nLinePoss := nI
						// Verifica se a linha é do Tipo que está validando
					ElseIf cCodTipPrg == cTipoProg
						oModelNSY:SetValue("NSY_VLCONT", nValAtu)
						If nValAtu == 0
							oModelNSY:LoadValue("NSY_CJURPC", 0)
							oModelNSY:LoadValue("NSY_CCORPC", 0)
							oModelNSY:LoadValue("NSY_VLCONA", 0)
						EndIf

						nValTotPed := nValTotPed - nValAtu
					Else
						nValTotPed := nValTotPed - oModelNSY:GetValue("NSY_VLCONT")
					EndIf
					oModelNSY:LoadValue("NSY_DTCONT",cDatPed)
				EndIf
			EndIf
			If lAtuRedut
				oModelNSY:SetValue("NSY_REDUT" , oModelO0W:GetValue("O0W_REDUT"))
			EndIf
		Next

		// Caso não seja a inclusão, pega o valor calculado e atualiza na linha do Possivel
		If !lAdicionar
			oModelNSY:GoLine(nLinePoss)
			oModelNSY:LoadValue("NSY_PEVLR" , oModelO0W:GetValue("O0W_VPEDID"))
			oModelNSY:SetValue("NSY_CCOMON",oModelO0W:GetValue("O0W_CFRCOR"))
			oModelNSY:LoadValue("NSY_PEINVL",'2')
			oModelNSY:LoadValue("NSY_CMOPED",cMoeda)
			oModelNSY:LoadValue("NSY_PEDATA",cDatPed)
			oModelNSY:LoadValue("NSY_DTJURO",oModelO0W:GetValue("O0W_DTJURO"))
			oModelNSY:LoadValue("NSY_DTCONT",cDatPed)
			oModelNSY:LoadValue("NSY_VLCONA",nValTotPed)
			lRet := oModelNSY:LoadValue("NSY_VLCONT", nValTotPed)
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetProgn(cTipProg, cCodProg)
Criar e atualizar o NSYDETAIL com os dados inputados na O0W

@Param cTipProg - Tipo do Prognóstico
@Param cCodProg - Código do Prognóstico

@Return aRet[1] - Código do Prognóstico
			[2] - Tipo do Prognóstico

@author Willian.Kazahaya
@since 05/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JGetProgn(cTipProg, cCodProg)
	Local cAlias  := ""
	Local cQrySel := ""
	Local cQryFrm := ""
	Local cQryWhr := ""

	Default cCodProg := ""
	Default cTipProg := ""

	cQrySel := " SELECT NQ7_COD "
	cQrySel +=        ",NQ7_DESC "
	cQrySel +=        ",NQ7_TIPO "

	cQryFrm := " FROM " + RetSqlName("NQ7") + " NQ7 "
	cQryWhr := " WHERE D_E_L_E_T_ = ' ' "
	cQryWhr +=  " AND NQ7_FILIAL = '" + xFilial("NQ7") + "' "

	If !Empty(cTipProg)
		cQryWhr += " AND NQ7_TIPO = '" + cTipProg + "'"
	EndIf

	If !Empty(cCodProg)
		cQryWhr += " AND NQ7_COD = '" + cCodProg + "'"
	EndIf

	cQuery := ChangeQuery(cQrySel + cQryFrm + cQryWhr)

	cAlias := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

	If (cAlias)->(!Eof())
		cCodProg := (cAlias)->NQ7_COD
		cTipProg := (cAlias)->NQ7_TIPO
	End

	(cAlias)->( DbCloseArea() )

Return {cCodProg, cTipProg}

//-------------------------------------------------------------------
/*/{Protheus.doc} VldProgno()
(Valida se temos progósticos cadastrados para os 4 tipos "Provável", "Possível", 
"Remoto" e "Incontroverso" )
@type  Static Function
@author Ronaldo.Goncalves
@since 03/01/2020
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function VldProgno()
	Local aArea     := GetArea()
	Local cAliasNQ7 := GetNextAlias()
	Local cQuery    := ''
	Local nI        := 1
	Local lRet      := .T.

	cQuery := "SELECT NQ7_TIPO "
	cQuery +=  " FROM " + RetSqlName("NQ7") + " NQ7 "
	cQuery += " WHERE NQ7.NQ7_FILIAL = '" + xFilial("NQ7") + "' "
	cQuery +=   " AND  D_E_L_E_T_ = ' ' "
	cQuery +=" GROUP BY NQ7_TIPO "
	cQuery +=" ORDER BY NQ7_TIPO "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNQ7,.F.,.F.)

	While lRet .And. (!(cAliasNQ7)->(EoF()))

		If ((cAliasNQ7)-> NQ7_TIPO) != cValToChar(nI)
			lRet := .F.
		EndIf

		(cAliasNQ7)->(DbSkip())
		nI++
	EndDo

	If nI < 5
		JurMsgErro(STR0014,STR0015,STR0016) //Erro: Não foi possí­vel cadastrar o pedido, pois, o cadastro de prognósticos está incompleto.
		lRet := .F.
	EndIf

	(cAliasNQ7)->(DbCloseArea())
	RestArea(aArea)

Return lret

//-------------------------------------------------------------------
/*/{Protheus.doc} J270TOK(oModel)
Pré-validação do modelo

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Willian.Kazahaya
@since 02/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J270TOK(oModel)
	Local lRet         := .F.
	Local oModelO0W    := oModel:GetModel("O0WDETAIL")
	Local nJ270Opc     := 4
	Local nI           := 0
	Local aArea        := GetArea()
	Local aAreaO0W     := O0W->(GetArea())
	Local cFluig       := SuperGetMV('MV_JFLUIGA',,'2')
	Local lFluig       := .F.

	// Atualiza os dados na NSY e O0W
	J270SetData(oModel)

	lRet := JUpdTotal("00",oModel)
	//Valida cadastro de prognósticos
	If lRet
		lRet := VldProgno()
	EndIf

	If lRet
		DbSelectArea("O0W")
		O0W->( DbSetOrder(1) )	//O0W_FILIAL+O0W_COD
		For nI := 1 to oModelO0W:Length()
			oModelO0W:GoLine(nI)
			//Posiciona na verba
			O0W->(DbSeek(xFilial("O0W")+oModelO0W:GetValue('O0W_COD'),.T.))
			//Seta a operação da O0W (Inc, Alt ou Exc)
			If oModelO0W:IsDeleted(nI)
				nJ270Opc := 5
			Else
				//Se existem Objetos com o código da verba, trata-se como Alteração (4)
				nJ270Opc := J270OpcVerba(oModelO0W:GetValue('O0W_COD'))
			EndIf
			If cFluig == '1'
				If NQS->( FieldPos('NQS_TAPROV') ) > 0
					//Verifica se o Tipo de aprovação é 6 - Objeto
					lFluig := !Empty(Posicione("NQS", 3, xFilial("NQS") + "6", "NQS_COD" )) .And. ;
						Posicione("NQS", 3, xFilial("NQS") + "6", "NQS_FLUIG" ) == "1" //NQS_FILIAL + NQS_TAPROV
				Else
					lFluig = .T.
				EndIf
			EndIf
			//Aprovação de Objeto
			If lFluig .And. !IsInCallStack("JA106ConfNZK") .And. O0W->( FieldPos("O0W_CODWF") ) > 0
				If !J270FFluig(oModel, oModelO0W, nJ270Opc)
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf

	RestArea(aAreaO0W)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J270FFluig
Valida as alterações nos campos de valor para ajustar o histórico 
conforme necessidade.

@param 	oModel   Modelo de dados
@param 	cTabela  Tabela que está sendo alterada

@since 08/01/2020
/*/
//-------------------------------------------------------------------
Function J270FFluig(oModel, oModelO0W, nJ270Opc)

Local lRet       := .T.
Local lNZKInDic  := FWAliasInDic("NZK") //Verifica se existe a tabela NZK no Dicionário
Local aDadFwApv  := {}
Local cTipFwApv  := "6"
Local cCodWf     := oModelO0W:GetValue("O0W_CODWF")
Local nValorDif  := ""
Local lFCorr     := .F.
Local lDtMulta   := .F.
Local lPeMulta   := .F.

	//*******************************************************************************
	// Gera follow-up e tarefas de follow-up para aprovacao no fluig quando nao for
	// uma aprovacao do fluig
	//*******************************************************************************
	If lNZKInDic .And. (nJ270Opc == MODEL_OPERATION_DELETE .Or. ;
			oModelO0W:IsFieldUpdated("O0W_VPEDID") .Or. ;
			oModelO0W:IsFieldUpdated("O0W_VPROVA") .Or. ;
			oModelO0W:IsFieldUpdated("O0W_VINCON") .Or. ;
			oModelO0W:IsFieldUpdated("O0W_CFRCOR") .Or. ;
			oModelO0W:IsFieldUpdated("O0W_DATPED") .Or. ;
			oModelO0W:IsFieldUpdated("O0W_DTJURO") .Or. ;
			oModelO0W:IsFieldUpdated("O0W_DTMULT") .Or. ;
			oModelO0W:IsFieldUpdated("O0W_PERMUL") )

		//Verifica se ja existe tarefa de follow-up em aprovacao
		If !Empty(cCodWf) .And. J94FTarFw(xFilial("O0W"), cCodWf, "1|5|6", "4")
			JurMsgErro(	STR0017 ) //"Já existe follow-up para aprovação pendente. Não será possí­vel prosseguir com a alteração."
			lRet := .F.
		Else
			lFCorr   := !Empty(O0W->O0W_CFRCOR) .Or. !Empty(oModelO0W:GetValue("O0W_CFRCOR"))
			lDtMulta := !Empty(O0W->O0W_DTMULT) .Or. !Empty(oModelO0W:GetValue("O0W_DTMULT"))
			lPeMulta := !Empty(O0W->O0W_PERMUL) .Or. !Empty(oModelO0W:GetValue("O0W_PERMUL"))
			//Verifica se alterou valor da provisao
			If oModelO0W:GetValue("O0W_VPEDID") <> O0W->O0W_VPEDID  .Or. ;
					oModelO0W:GetValue("O0W_VPROVA") <> O0W->O0W_VPROVA .Or. ;
					oModelO0W:GetValue("O0W_CFRCOR") <> O0W->O0W_CFRCOR .Or. ;
					(oModelO0W:GetValue("O0W_DATPED") <> O0W->O0W_DATPED .And. lFCorr) .Or. ;
					(oModelO0W:GetValue("O0W_DTJURO") <> O0W->O0W_DTJURO .And. lFCorr) .Or. ;
					(oModelO0W:GetValue("O0W_DTMULT") <> O0W->O0W_DTMULT .And. lFCorr .And. lPeMulta) .Or. ;
					(oModelO0W:GetValue("O0W_PERMUL") <> O0W->O0W_PERMUL .And. lFCorr .And. lDtMulta)

				//Verifica se existe algum resultado de follow-up com o tipo 4=Em Aprovacao
				If lRet .And. Empty( JurGetDados("NQN", 3, xFilial("NQN") + "4", "NQN_COD") ) //NQN_FILIAL + NQN_TIPO
					JurMsgErro( STR0018 ) //"Não existe resultado de follow-up com o tipo 4=Em Aprovacao cadastrado. Verifique o cadastro de resultados do follow-up!"
					lRet := .F.
				EndIf

				If lRet .And. (nJ270Opc == MODEL_OPERATION_UPDATE .OR. ;
						nJ270Opc == MODEL_OPERATION_INSERT)

					//Carrega as alterações que serão feitas quando for aprovada
					//a alteracao do objeto

					Aadd( aDadFwApv, {"O0W_PROGNO" , oModelO0W:GetValue("O0W_PROGNO") } )
					Aadd( aDadFwApv, {"O0W_VPEDID",  oModelO0W:GetValue("O0W_VPEDID") } )
					Aadd( aDadFwApv, {"O0W_VPROVA",  oModelO0W:GetValue("O0W_VPROVA") } )
					Aadd( aDadFwApv, {"O0W_VPOSSI",  oModelO0W:GetValue("O0W_VPOSSI") } )
					Aadd( aDadFwApv, {"O0W_VREMOT",  oModelO0W:GetValue("O0W_VREMOT") } )
					Aadd( aDadFwApv, {"O0W_VINCON" , oModelO0W:GetValue("O0W_VINCON") } )
					Aadd( aDadFwApv, {"O0W_CFRCOR" , oModelO0W:GetValue("O0W_CFRCOR") } )
					Aadd( aDadFwApv, {"O0W_DATPED" , oModelO0W:GetValue("O0W_DATPED") } )
					Aadd( aDadFwApv, {"O0W_DTJURO" , oModelO0W:GetValue("O0W_DTJURO") } )
					Aadd( aDadFwApv, {"O0W_DTMULT" , oModelO0W:GetValue("O0W_DTMULT") } )
					Aadd( aDadFwApv, {"O0W_PERMUL" , oModelO0W:GetValue("O0W_PERMUL") } )

					If nJ270Opc == MODEL_OPERATION_INSERT
						nValorDif := oModelO0W:GetValue("O0W_VPEDID")
					Else
						nValorDif := oModelO0W:GetValue("O0W_VPEDID") - O0W->O0W_VPEDID
					EndIf
					//Diferença de valor que será aprovada
					Aadd( aDadFwApv, {"PROV_O0W", nValorDif} )

					//Volta os dados da verba antes de alterar
					If nJ270Opc == MODEL_OPERATION_UPDATE
						oModelO0W:SetValue( "O0W_VPEDID", O0W->O0W_VPEDID )
						oModelO0W:SetValue( "O0W_VPROVA", O0W->O0W_VPROVA )
						oModelO0W:SetValue( "O0W_VREMOT", O0W->O0W_VREMOT )
						oModelO0W:SetValue( "O0W_VINCON", O0W->O0W_VINCON )
						oModelO0W:SetValue( "O0W_CFRCOR", O0W->O0W_CFRCOR )
						oModelO0W:SetValue( "O0W_DATPED", O0W->O0W_DATPED )
						oModelO0W:SetValue( "O0W_DTJURO", O0W->O0W_DTJURO )
						oModelO0W:SetValue( "O0W_DTMULT", O0W->O0W_DTMULT )
						oModelO0W:SetValue( "O0W_PERMUL", O0W->O0W_PERMUL )
					Else //Limpa os dados da verba antes de incluir
						oModelO0W:SetValue( "O0W_VPEDID" , 0 )
						oModelO0W:SetValue( "O0W_VPROVA" , 0 )
						oModelO0W:SetValue( "O0W_VREMOT" , 0 )
						oModelO0W:SetValue( "O0W_VINCON" , 0 )
						oModelO0W:LoadValue("O0W_CFRCOR", "")
						oModelO0W:LoadValue(  "O0W_DATPED" , Date() )
						oModelO0W:ClearField( "O0W_DTJURO")
						oModelO0W:ClearField( "O0W_DTMULT")
						oModelO0W:ClearField( "O0W_PERMUL")
					EndIf

					//Gera follow-up de aprovacao de Valor de Provisao
					Processa( {| | lRet := J270FFwApv(oModel:GetValue("NSZMASTER", "NSZ_COD"), ;
						aDadFwApv, cTipFwApv, oModel, oModelO0W, ;
						nJ270Opc)},;
						STR0019, "")	//"Gerando aprovação no Fluig"
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J270FFwApv
Gera follow-up de aprovacao
Uso geral.

@param 	cProcesso     Código do processo
@param 	aCampos       Campos e valores a serem aprovados
@param 	cTipoFwApr    Tipo de Fup de aprovação
@param 	oModel        Modelo de dados NSZMASTER
@param 	oModelO0W     Modelo de dados O0WDETAIL
@param 	nJ270Opc      Operação 3 = Inclusão, 4 = Alteração, 5 = Exclusão

@return	aCampos - Campos que seram gravados na NZK
@since 08/01/2020
/*/
//-------------------------------------------------------------------
Function J270FFwApv(cProcesso, aCampos, cTipoFwApr, oModel, oModelO0W, nJ270Opc)

	Local aArea      := GetArea()
	Local aAreaNTA   := NTA->( GetArea() )
	Local lRet       := .T.
	Local oModelFw   := Nil
	Local aTipoFw    := JurGetDados("NQS", 3, xFilial("NQS") + cTipoFwApr, {"NQS_COD", "NQS_DPRAZO"} )	//NQS_FILIAL + NQS_TAPROV	1=Alteracao Valor Provisao 2=Aprovacao de despesas 3=Aprovacao de Garantias 4=Aprovacao de Levantamento 5=Encerramento
	Local cTipoFw    := ""
	Local nDiaPrazo  := 0
	Local cResultFw  := JurGetDados("NQN", 3, xFilial("NQN") + "4", "NQN_COD") //NQN_FILIAL + NQN_TIPO		4=Em Aprovacao
	Local cPart      := JurUsuario(__cUserId)
	Local cSigla     := JurGetDados("RD0", 1, xFilial("RD0") + cPart, "RD0_SIGLA") //RD0_FILIAL + RD0_CODIGO
	Local aNTA       := {}
	Local aNTE       := {}
	Local aNZK       := {}
	Local aNZM       := {}
	Local aAux       := {}
	Local nCont      := 0
	Local nReg       := 0
	Local cConteudo  := ""
	Local aErroNTA   := {}
	Local cNQNTipoF  := ""  //Variável que vai guardar o tipo do resultado após incluir o WF no FLUIG
	Local cCodWF     := oModelO0W:GetValue("O0W_CODWF")
	Local lPendente  := !Empty(cCodWf) .And. J94FTarFw(xFilial("O0W"), cCodWf, "6", "1")
	Local nOpcFw     := 3
	Local cDesc      := ""
	Local nPosValO0W := Ascan(aCampos,{|x| x[1] == "PROV_O0W"})
	Local nValorO0W  := aCampos[nPosValO0W][2] //Valor que será enviado para aprovação
	Local cProgAtual := ""
	Local nPosProgAp := Ascan(aCampos, {|x| x[1] == "O0W_PROGNO"})
	Local cProgAprov := AllTrim(aCampos[nPosProgAp][2]) //Descrição do grupo de aprovação
	Local nVlrPedAtu := 0 //Valor atual do pedido
	Local nPosPedApr := Ascan(aCampos, {|x| x[1] == "O0W_VPEDID"})
	Local nVlrPedApr := aCampos[nPosPedApr][2]//Valor a aprovar do pedido
	Local nVlrPrvAtu := 0 //Valor atual provável
	Local nPosPrvApr := Ascan(aCampos, {|x| x[1] == "O0W_VPROVA"})
	Local nVlrPrvApr := aCampos[nPosPrvApr][2]//Valor a aprovar provável
	Local nVlrPssAtu := 0 //Valor atual possível
	Local nPosPssApr := Ascan(aCampos, {|x| x[1] == "O0W_VPOSSI"})
	Local nVlrPssApr := aCampos[nPosPssApr][2]//Valor a aprovar possível
	Local nVlrRemAtu := 0 //Valor atual remoto
	Local nPosRemApr := Ascan(aCampos, {|x| x[1] == "O0W_VREMOT"})
	Local nVlrRemApr := aCampos[nPosRemApr][2]//Valor a aprovar remoto
	Local nVlrIncAtu := 0 //Valor atual incontroverso
	Local nPosIncApr := Ascan(aCampos, {|x| x[1] == "O0W_VINCON"})
	Local nVlrIncApr := aCampos[nPosIncApr][2]//Valor a aprovar incontroverso
	Local dDtPedAtu := "" //Data atual do pedido
	Local nDtPedApr := Ascan(aCampos, {|x| x[1] == "O0W_DATPED"})
	Local dDtPedApr := aCampos[nDtPedApr][2]//Data a aprovar do pedido
	Local dDtJuroAtu := "" //Data atual de juros
	Local nDtJuroApr := Ascan(aCampos, {|x| x[1] == "O0W_DTJURO"})
	Local dDtJuroApr := aCampos[nDtJuroApr][2]//Data a aprovar  de juros
	Local cForCorAtu := "" //Forma de correção atual

	Local nDtMultaApr := Ascan(aCampos, {|x| x[1] == "O0W_DTMULT"})
	Local dDtMultaApr := aCampos[nDtMultaApr][2]//Data a aprovar  de multa
	Local dDtMultaAtu := "" //Data atual de multa
	Local nPercMulApr := Ascan(aCampos, {|x| x[1] == "O0W_PERMUL"})
	Local cPercMulApr := aCampos[nPercMulApr][2]//Porcentagem a aprovar de multa
	Local cPercMulAtu := "" //Porcentagem de multa atual

	Local nForCorApr := Ascan(aCampos, {|x| x[1] == "O0W_CFRCOR"})
	Local cForCorApr := cValToChar(aCampos[nForCorApr][2])//Forma de correção a aprovar
	Local dDataFup   := DataValida(Date(),.T.)

	ProcRegua(0)
	IncProc()
	IncProc()

	//Carerga follow-up
	If !Empty(aTipoFw)
		cTipoFw		:= aTipoFw[1]
		nDiaPrazo	:= Val( aTipoFw[2] ) //Verificar se o campo NQS_DPRAZO sera mesmo caracter
	EndIf

	//Carrega campos atuais
	If nJ270Opc == MODEL_OPERATION_UPDATE
		cProgAtual  := O0W->O0W_PROGNO
		nVlrPedAtu  := O0W->O0W_VPEDID
		nVlrPrvAtu  := O0W->O0W_VPROVA
		nVlrPssAtu  := O0W->O0W_VPOSSI
		nVlrRemAtu  := O0W->O0W_VREMOT
		nVlrIncAtu  := O0W->O0W_VINCON
		dDtPedAtu   := O0W->O0W_DATPED
		dDtJuroAtu  := O0W->O0W_DTJURO
		cForCorAtu  := O0W->O0W_CFRCOR
		dDtMultaAtu := O0W->O0W_DTMULT
		cPercMulAtu := O0W->O0W_PERMUL
	EndIf

	cDesc := STR0020 + JurGetDados("NSP", 1, xFilial("NSP") + oModelO0W:GetValue("O0W_CTPPED"), "NSP_DESC") //"Aprovação de Alteração no Pedido: "

	cDesc += CRLF + STR0021 + AllTrim( Transform(nValorO0W , "@E 99,999,999,999.99") ) //"Valor para aprovação: "

	cDesc += CRLF + STR0022 + cProgAtual //"Prognóstico atual: "
	cDesc += CRLF + STR0023 + cProgAprov //"Prognóstico após aprovação: "

	cDesc += CRLF + STR0037 + if(!Empty(dDtPedAtu),DToC(dDtPedAtu),"") //"Data atual do pedido: "
	cDesc += CRLF + STR0038 + DToC(dDtPedApr) //"Data do pedido após aprovação: "

	cDesc += CRLF + STR0039 + JurGetDados("NW7", 1, xFilial("NW7") + cForCorAtu, "NW7_DESC") //"Forma de correção atual: "
	cDesc += CRLF + STR0040 + JurGetDados("NW7", 1, xFilial("NW7") + cForCorApr, "NW7_DESC") //"Forma de correção após aprovação: "

	cDesc += CRLF + STR0024 + AllTrim( Transform(nVlrPedAtu, "@E 99,999,999,999.99") )       //"Valor do pedido atual: "
	cDesc += CRLF + STR0025 + AllTrim( Transform(nVlrPedApr, "@E 99,999,999,999.99") )       //"Valor do pedido após aprovação: "

	cDesc += CRLF + STR0026 + AllTrim( Transform(nVlrPrvAtu, "@E 99,999,999,999.99") )       //"Valor provável atual: "
	cDesc += CRLF + STR0027 + AllTrim( Transform(nVlrPrvApr, "@E 99,999,999,999.99") )       //"Valor provável após aprovação: "

	cDesc += CRLF + STR0028 + AllTrim( Transform(nVlrPssAtu, "@E 99,999,999,999.99") )       //"Valor possível atual: "
	cDesc += CRLF + STR0029 + AllTrim( Transform(nVlrPssApr, "@E 99,999,999,999.99") )       //"Valor possível após aprovação: "

	cDesc += CRLF + STR0030 + AllTrim( Transform(nVlrRemAtu, "@E 99,999,999,999.99") )       //"Valor remoto atual: "
	cDesc += CRLF + STR0031 + AllTrim( Transform(nVlrRemApr, "@E 99,999,999,999.99") )       //"Valor remoto após aprovação: "

	cDesc += CRLF + STR0032 + AllTrim( Transform(nVlrIncAtu, "@E 99,999,999,999.99") )       //"Valor incontroverso atual: "
	cDesc += CRLF + STR0033 + AllTrim( Transform(nVlrIncApr, "@E 99,999,999,999.99") )       //"Valor incontroverso após aprovação: "

	cDesc += CRLF + STR0041 + if(!Empty(dDtJuroAtu),DToC(dDtJuroAtu),"")                     //"Data de juros atual: "
	cDesc += CRLF + STR0042 + if(!Empty(dDtJuroApr),DToC(dDtJuroApr),"")                     //"Data de juros após aprovação: "
	
	cDesc += CRLF + STR0045 + if(!Empty(dDtMultaAtu),DToC(dDtMultaAtu),"")                   //"Data de multa atual: "
	cDesc += CRLF + STR0046 + if(!Empty(dDtMultaApr),DToC(dDtMultaApr),"")                   //"Data de multa após aprovação: "
	
	cDesc += CRLF + STR0047 + AllTrim(cPercMulAtu) + Iif(!Empty(cPercMulAtu), "%", "")       //"Porcentagem de multa atual: "
	cDesc += CRLF + STR0048 + AllTrim(cPercMulApr) + Iif(!Empty(cPercMulApr), "%", "")       //"Porcentagem de multa após aprovação: "

	//Ja existe follow-up pendente e já esta posicionado
	If lPendente
		nOpcFw    := 4
		cResultFw := JurGetDados("NQN", 3, xFilial("NQN") + "2", "NQN_COD") //NQN_FILIAL + NQN_TIPO 2=Concluido
		cDesc     := AllTrim(cDesc) + CRLF + Replicate("-", 5) + CRLF + AllTrim(NTA->NTA_DESC)

		aAdd(aNZM, {"NZM_CODWF"	, AllTrim(NTA->NTA_CODWF)} )
		aAdd(aNZM, {"NZM_CAMPO"	, "sObsExecutor"         } )
		aAdd(aNZM, {"NZM_CSTEP"	, "16"                   } )
		aAdd(aNZM, {"NZM_STATUS", "2"                    } )
	EndIf

	Aadd(aNTA, {"NTA_CAJURI", cProcesso         } )
	Aadd(aNTA, {"NTA_CTIPO" , cTipoFw           } )
	Aadd(aNTA, {"NTA_DTFLWP", dDataFup          } )
	Aadd(aNTA, {"NTA_CRESUL", cResultFw         } )
	Aadd(aNTA, {"NTA__VALOR", Abs( nValorO0W )  } )
	Aadd(aNTA, {"NTA_DESC"  , cDesc             } )

	//Carerga participante
	Aadd(aNTE, {"NTE_SIGLA", cSigla} )
	Aadd(aNTE, {"NTE_CPART", cPart } )

	//Carrega Tarefas do Follow-up
	For nCont := 1 To Len( aCampos )

		If !aCampos[nCont][1] $ "PROV_O0W/O0W_VPOSSI/O0W_PROGNO" // não é possí­vel atualizar o valor possível

			Do Case
			Case ValType( aCampos[nCont][2] ) == "D"
				cConteudo := DtoS( aCampos[nCont][2] )
			Case ValType( aCampos[nCont][2] ) == "N"
				cConteudo := cValToChar( aCampos[nCont][2] )
			OtherWise
				cConteudo := aCampos[nCont][2]
			End Case

			aAux := {}
			Aadd(aAux, {"NZK_STATUS", "1"               } ) //1=Em Aprovacao
			Aadd(aAux, {"NZK_FONTE"	, "JURA270"         } )
			Aadd(aAux, {"NZK_MODELO", "O0WDETAIL"       } )
			Aadd(aAux, {"NZK_CAMPO" , aCampos[nCont][1] } )
			Aadd(aAux, {"NZK_VALOR" , cConteudo         } )
			Aadd(aAux, {"NZK_CHAVE" , xFilial("O0W") + ;
				oModelO0W:GetValue("O0W_COD") } ) //O0W_FILIAL+O0W_COD

			Aadd( aNZK, aAux )
		EndIf
	Next nCont

	//Prepara follow-up para inclusao
	oModelFw := FWLoadModel("JURA106")
	oModelFw:SetOperation(nOpcFw)
	oModelFw:Activate()

	//Atualiza follow-up
	For nCont:=1 To Len( aNTA )

		If aNTA[nCont][1] == "NTA_CAJURI"

			If nOpcFw == 3
				oModelFw:LoadValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2])
			EndIf

			Loop
		EndIf

		If aNTA[nCont][1] == "NTA_CRESUL"

			If nOpcFw == 4
				oModelFw:LoadValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2])
			Else
				If !( oModelFw:SetValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2]) )
					lRet := .F.
					Exit
				EndIf
			EndIf
		Else
			If !( oModelFw:SetValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2]) )
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nCont

	If lRet

		If nOpcFw == 3 //Somente se for uma inclusão
			//Atualiza participante
			For nCont:=1 To Len( aNTE )
				If !( oModelFw:SetValue("NTEDETAIL", aNTE[nCont][1], aNTE[nCont][2]) )
					lRet := .F.
					Exit
				EndIf
			Next nCont
		EndIf

		If nOpcFw == 4 //Somente se for uma alteração
			//Atualiza participante
			For nCont:=1 To Len( aNZM )
				If !( oModelFw:SetValue("NZMDETAIL", aNZM[nCont][1], aNZM[nCont][2]) )
					lRet := .F.
					Exit
				EndIf
			Next nCont
		EndIf

		If lRet

			//Atualiza tarefas do follow-up
			For nReg:=1 To Len( aNZK )

				If nReg > 1
					oModelFw:GetModel("NZKDETAIL"):AddLine()
				EndIf

				For nCont:=1 To Len( aNZK[nReg] )
					If !( oModelFw:SetValue("NZKDETAIL", aNZK[nReg][nCont][1], aNZK[nReg][nCont][2]) )
						lRet := .F.
						Exit
					EndIf
				Next nCont
			Next nReg

			//Inclui follow-up
			If lRet
				If ( lRet := oModelFw:VldData() )
					lRet := oModelFw:CommitData()
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet

		cCodWF := oModelFw:GetValue("NTAMASTER", "NTA_CODWF")

		//valida se o follow-up está concluído ou em aprovação
		cNQNTipoF := JurGetDados('NQN',1,xFilial('NQN')+oModelFw:GetValue("NTAMASTER","NTA_CRESUL"),"NQN_TIPO")

		if (cNQNTipoF == "2")
			//Volta os valores (bkp) pois o FW foi concluí­do.
			For nCont := 1 to Len(aCampos)
				If aCampos[nCont][1] != "PROV_O0W"
					oModelO0W:SetValue(aCampos[nCont][1],aCampos[nCont][2])
				Endif
			Next
		Else
			oModelO0W:LoadValue("O0W_PROGNO", GetAvlCaso(0, 0, 0, 0))  // Tratamento para calcular o Prognóstico do Caso
			oModelO0W:LoadValue("O0W_VPOSSI", 0)

			//Exibe mensagem de aprovação
			ApMsgInfo(	STR0034 + CRLF + CRLF +; //"Aprovação enviada para o FLUIG."
			STR0035 , ProcName(0) ) //"Os dados alterados serão atualizados quando a aprovação for concluída."
		EndIf

	Else
		aErroNTA := oModelFw:GetErrorMessage()
	EndIf

	oModelFw:DeActivate()
	oModelFw:Destroy()

	FWModelActive( oModel )
	oModel:Activate()

	If lRet
		oModelO0W:LoadValue("O0W_CODWF", cCodWF)
	Else
		//Seta erro no modelo atual para retornar mensagem
		If Len(aErroNTA) > 0
			oModel:SetErrorMessage(aErroNTA[1], aErroNTA[2], aErroNTA[3], aErroNTA[4] , aErroNTA[5],;
				STR0036 + CRLF + ; //"Não foi possí­vel inclui­r o follow-up de aprovação. Verifique!"
			aErroNTA[6], aErroNTA[7], /*xValue*/ , /*xOldValue*/ )
		EndIf
	EndIf

	RestArea(aAreaNTA)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J270OpcVerba(cVerba)
Verifica se existem objetos para a verba.

@param 	cVerba      Código da verba
@Return lRet        .T./.F. Existe ou não objetos para a verba

@since 10/01/2020
/*/
//-------------------------------------------------------------------
Static Function J270OpcVerba(cVerba)
	Local nRet       := 3
	Local cQuery     := ""
	Local cAlias     := ""

	cQuery += "SELECT 1 FROM " + RetSqlName("NSY")
	cQuery += "WHERE NSY_CVERBA = '" + cVerba + "' "
	cQuery += "AND NSY_FILIAL = '" + xFilial("NSY") + "' "
	cQuery += "AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	cAlias := GetNextAlias()
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	//Se existirem Objetos para a verba
	If (cAlias)->(!Eof())
		nRet := 4 //Alteração
	EndIf

	(cAlias)->(DbCloseArea())

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JA270VlrMu
Retorna a soma do valor de multa, encargo e honorario de todos os objetos vinculado ao processo, de um prognóstico e uma 
verba especifica

@param cProcesso - Numero do processo

@return nMultaTot - total da soma de multa, encargos e honorários

@since 03/02/2020
/*/
//-------------------------------------------------------------------
Function JA270VlrMu(cProcesso)

	Local aArea     := GetArea()
	Local cLista    := GetNextAlias()
	Local nMultaTot := 0
	Local cQuery    := ""
	Local aMultas   := {}

	cQuery += "SELECT ISNULL(SUM(( CASE "
	cQuery +=                       "WHEN NSY_TRVLRA > 0 THEN NSY_TRVLRA "
	cQuery +=                       "ELSE NSY_TRVLR "
	cQuery +=                     "END )), 0) HONORARIO, "
	cQuery +=        "ISNULL(SUM(( CASE "
	cQuery +=                       "WHEN NSY_MUATT > 0 THEN NSY_MUATT "
	cQuery +=                       "ELSE NSY_VLRMT "
	cQuery +=                     "END )), 0) MULTA_HONORARIO, "
	cQuery +=        "ISNULL(SUM(( CASE "
	cQuery +=                       "WHEN NSY_V2VLRA > 0 THEN NSY_V2VLRA "
	cQuery +=                       "ELSE NSY_V2VLR "
	cQuery +=                     "END )), 0) ENCARGO, "
	cQuery +=        "ISNULL(SUM(( CASE "
	cQuery +=                       "WHEN NSY_MUATU2 > 0 THEN NSY_MUATU2 "
	cQuery +=                       "ELSE NSY_VLRMU2 "
	cQuery +=                     "END )), 0) MULTA_ENCARGO, "
	cQuery +=        "ISNULL(SUM(( CASE "
	cQuery +=                       "WHEN NSY_V1VLRA > 0 THEN NSY_V1VLRA "
	cQuery +=                       "ELSE NSY_V1VLR "
	cQuery +=                     "END )), 0) MULTA, "
	cQuery +=        "NQ7_TIPO"
	cQuery += "FROM "+RetSqlname('NSY')+" NSY "
	cQuery += "INNER JOIN "+RetSqlname('NQ7')+" NQ7 "
	cQuery +=       "ON NQ7_FILIAL = '" + xFilial('NQ7') + "' "
	cQuery +=       "AND NSY_CPROG = NQ7_COD "
	cQuery += "WHERE  NSY_FILIAL = '" + xFilial('NSY') + "' "
	cQuery +=    "AND NSY_CAJURI = '" + cProcesso + "' "
	cQuery +=    "AND NSY_CVERBA <> ' ' "
	cQuery +=    "AND NSY.D_E_L_E_T_ = ' ' "
	cQuery +=    "AND NQ7.D_E_L_E_T_ = ' ' "
	cQuery +=    " GROUP BY NQ7_TIPO "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ), cLista,.T.,.T.)

	If (cLista)->(!Eof())
		While (cLista)->(!Eof())
			nMultaTot += (cLista)->HONORARIO + (cLista)->MULTA_HONORARIO
			nMultaTot += (cLista)->ENCARGO + (cLista)->MULTA_ENCARGO
			nMultaTot += (cLista)->MULTA
			aAdd(aMultas,{(cLista)->NQ7_TIPO, nMultaTot})
			nMultaTot := 0
			(cLista)->(dbSkip())
		EndDo
	EndIf

	(cLista)->( dbcloseArea() )
	RestArea( aArea )

Return aMultas

//-------------------------------------------------------------------
/*/{Protheus.doc} J270UrlWF(cCodWf)
Monta a URL de acesso ao Workflow no fluig.

@param 	cCodWf      Código do Workflow

@Return cUrlRet     URL do workflow

@since 14/01/2020
/*/
//-------------------------------------------------------------------
Function J270UrlWF(cCodWf)
	Local cUrlRet    := ""
	Local cUrl       := StrTran(AllTrim(JFlgUrl()), '/webdesk/', '')
	Local cEmpresa   := AllTrim(SuperGetMV('MV_ECMEMP' ,,""))

	If Empty(cEmpresa)
		cEmpresa := AllTrim(SuperGetMV('MV_ECMEMP2' ,,""))
	EndIf

	If !Empty(cUrl) .And. !Empty(cCodWf) .And. !Empty(cEmpresa)
		cUrlRet := cUrl
		cUrlRet += '/portal/p/'
		cUrlRet += cEmpresa
		cUrlRet += '/pageworkflowview?app_ecm_workflowview_detailsProcessInstanceID='
		cUrlRet += cCodWf
	EndIf

Return cUrlRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J270AtuRed(oModelO0W)
Atualiza o campo de valor de redutor de acordo com o prognostico de cada linha da o0w

@param oModelO0W      Modelo detailO0w
@Return Nil
@since 17/08/2020
/*/
//-------------------------------------------------------------------

Static Function J270AtuRed(oModelO0W)
	Local aArea    := GetArea()
	Local aAreaO0W := O0W->(GetArea())
	Local cAlias   := ""
	Local cProgno  := ""
	Local cVerba   := ""
	Local cCajuri  := oModelO0W:GetValue("O0W_CAJURI")
	Local cQuery   := ""
	Local nI       := 0
	Local aProg    := {}
	Local nPosProg := 0

	aAdd( aProg, {STR0004, '1'} ) // "Provável"
	aAdd( aProg, {STR0005, '2'} ) // "Possível"
	aAdd( aProg, {STR0006, '3'} ) // "Remoto"
	aAdd( aProg, {STR0007, '4'} ) // "Incontroverso"

	DbSelectArea("O0W")
	For nI := 1 to oModelO0W:Length()
		if !oModelO0W:isDeleted(nI)

			nPosProg := aScan(aProg, {|x| x[1] == AllTrim(oModelO0W:GetValue("O0W_PROGNO",nI))})
			If nPosProg > 0
				cProgno  := JGetProgn(aProg[nPosProg][2])[1]
				cVerba   := oModelO0W:GetValue("O0W_COD",nI)

				cQuery := " SELECT NSY_VLREDU FROM "+ RetSQLName('NSY')
				cQuery += " WHERE NSY_CVERBA = '"+ cVerba +"'"
				cQuery +=       " AND NSY_CAJURI = '" + cCajuri + "'"
				cQuery +=       " AND NSY_CPROG = '" + cProgno + "'"
				cQuery +=       " AND D_E_L_E_T_ = ''"

				cQuery := ChangeQuery(cQuery)
				cAlias := GetNextAlias()

				DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

				If (cAlias)->(!Eof())
					O0W->( DbSetOrder(3) ) // O0W_FILIAL+O0W_CAJURI+O0W_COD+O0W_CTPPED
					If O0W->( DbSeek(xFilial("O0W") + cCajuri + cVerba))
						RecLock("O0W", .F.)
						// Atualiza o campo de valor de redutor
						O0W->O0W_VLREDU := (cAlias)->NSY_VLREDU
						O0W->( MsUnLock() )
					EndIf
				EndIf
				(cAlias)->(DbCloseArea())
			EndIf
		Endif
	Next
	O0W->(DbCloseArea())

	RestArea(aArea)
	RestArea(aAreaO0W)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaHistPed(oModel)
Grava o histórico de alterações dos pedidos

@param oModel      Modelo detailO0w
@Return lRet       Lógico - Valida se gravou o histórico de pedidos
@since 25/08/2020
/*/
//-------------------------------------------------------------------
Static Function GravaHistPed(oModel)

Local aArea      := GetArea()
Local aAreaO13   := O13->(GetArea())
Local oModelO0W  := oModel:GetModel("O0WDETAIL")
Local oModel282  := Nil
Local cQuery     := ""
Local cCodO0W    := ""
Local nI         := 1
Local nLine      := 0
Local lRet       := .T.
Local aAliasO0W  := {}
Local aChangLine := {}

	aChangLine := oModelO0W:GetLinesChanged()

	If Len(aChangLine) > 0 .AND. oModelO0W:IsModified()
		oModel282 := FWLoadModel("JURA282")
		oModel282:SetOperation(3) //Inclusão

		For nI := 1 To Len(aChangLine)
			nLine := aChangLine[nI]
			oModelO0W:GoLine(nLine)

			If !oModelO0W:isDeleted(nLine)

				oModel282:Activate()

				cCodO0W := oModelO0W:GetValue("O0W_COD"   , nLine)
				oModel282:SetValue( "O13MASTER", "O13_CPEDID", cCodO0W                                 )
				oModel282:SetValue( "O13MASTER", "O13_USUALT", USRRETNAME(__CUSERID)                   )
				oModel282:SetValue( "O13MASTER", "O13_PROGNO", oModelO0W:GetValue("O0W_PROGNO", nLine) )
				oModel282:SetValue( "O13MASTER", "O13_VPEDID", oModelO0W:GetValue("O0W_VPEDID", nLine) )
				oModel282:SetValue( "O13MASTER", "O13_VPOSSI", oModelO0W:GetValue("O0W_VPOSSI", nLine) )
				oModel282:SetValue( "O13MASTER", "O13_VPROVA", oModelO0W:GetValue("O0W_VPROVA", nLine) )
				oModel282:SetValue( "O13MASTER", "O13_VREMOT", oModelO0W:GetValue("O0W_VREMOT", nLine) )
				oModel282:SetValue( "O13MASTER", "O13_VINCON", oModelO0W:GetValue("O0W_VINCON", nLine) )
				oModel282:SetValue( "O13MASTER", "O13_CFRCOR", oModelO0W:GetValue("O0W_CFRCOR", nLine) )

				aAliasO0W := GetNextAlias()

				// Busca os valores corrigidos
				cQuery := " SELECT O0W_VATPED, "
				cQuery +=        " O0W_VATPOS, "
				cQuery +=        " O0W_VATPRO, "
				cQuery +=        " O0W_VATREM, "
				cQuery +=        " O0W_VATINC  "
				cQuery += " FROM " +  RetSqlName("O0W")  + " O0W "
				cQuery += " WHERE O0W.O0W_FILIAL = '" +  xFilial("O0W") +  "' "
				cQuery += "   AND O0W.O0W_COD = '" + cCodO0W + "' "
				cQuery += "   AND O0W.D_E_L_E_T_ = ' ' "

				cQuery := ChangeQuery(cQuery)
				DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), aAliasO0W, .F., .F. )

				If !(aAliasO0W)->(EOF())
					oModel282:SetValue( "O13MASTER", "O13_VATPED", (aAliasO0W)->O0W_VATPED )
					oModel282:SetValue( "O13MASTER", "O13_VATPOS", (aAliasO0W)->O0W_VATPOS )
					oModel282:SetValue( "O13MASTER", "O13_VATPRO", (aAliasO0W)->O0W_VATPRO )
					oModel282:SetValue( "O13MASTER", "O13_VATREM", (aAliasO0W)->O0W_VATREM )
					oModel282:SetValue( "O13MASTER", "O13_VATINC", (aAliasO0W)->O0W_VATINC )
				EndIf

				If ( lRet := oModel282:VldData() )
					lRet := oModel282:CommitData()
				EndIf

				If !lRet
					JurMsgErro(oModel282:aErrorMessage[6],STR0044,oModel282:aErrorMessage[7]) //"Não foi possível incluir o histórico do pedido. Verifique."
					DisarmTransaction()
				EndIf

				(aAliasO0W)->(DbCloseArea())

				// Desativa e destroi o modelo de historico
				oModel282:DeActivate()
			EndIf
		Next nI

		oModel282:Destroy()
		oModel282 := Nil
	EndIf

	RestArea(aAreaO13)
	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J270_PROV(cCajuri)
Traz os valores de provisão

@param cIdProcesso Caractere - Id do processo "cajuri"
@Return aProv      Array     - Array com os valores de provisão
		{
			[1] = O0W_VPROVA
			[2] = O0W_VATPRO
			[3] = O0W_VPOSSI
			[4] = O0W_VATPOS
			[5] = O0W_VREMOT
			[6] = O0W_VATREM
			[7] = O0W_VINCON
			[8] = O0W_VATINC 
		}
@since 08/12/2021
/*/
//-------------------------------------------------------------------
Function J270_PROV(cCajuri)
Local cQuery := ""
Local aProv := {}

	cQuery := "SELECT SUM(COALESCE(O0W_VPROVA,0)) O0W_VPROVA, "
	cQuery +=       " SUM(COALESCE(O0W_VATPRO,0)) O0W_VATPRO, "
	cQuery +=       " SUM(COALESCE(O0W_VPOSSI,0)) O0W_VPOSSI, "
	cQuery +=       " SUM(COALESCE(O0W_VATPOS,0)) O0W_VATPOS, "
	cQuery +=       " SUM(COALESCE(O0W_VREMOT,0)) O0W_VREMOT, "
	cQuery +=       " SUM(COALESCE(O0W_VLREDU,0)) O0W_VLREDU, "
	cQuery +=       " SUM(COALESCE(O0W_VATREM,0)) O0W_VATREM, "
	cQuery +=       " SUM(COALESCE(O0W_VINCON,0)) O0W_VINCON, "
	cQuery +=       " SUM(COALESCE(O0W_VATINC,0)) O0W_VATINC "
	cQuery += "  FROM " + RetSqlName("O0W")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery +=   " AND O0W_FILIAL = '" + xFilial("O0W")+ "'"
	cQuery +=   " AND O0W_CAJURI = '" + cCajuri +"'"

	aProv := JurSql(cQuery ,{"O0W_VPROVA","O0W_VATPRO","O0W_VPOSSI","O0W_VATPOS","O0W_VREMOT","O0W_VLREDU","O0W_VATREM","O0W_VINCON","O0W_VATINC"})
    
Return aProv 

//------------------------------------------------------------------------------
/* /{Protheus.doc} addFldStruct()
Função responsável por setar os campos na estrutura
@type Static Function
@author 
@since 04/03/2022
@version 1.0
@param oStruct, object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function addFldStruct(oStruct,cField)
	oStruct:AddField(;
		FWX3Titulo(cField)                                                      , ; // [01] C Titulo do campo
		""                                                                      , ; // [02] C ToolTip do campo
		cField                                                                  , ; // [03] C identificador (ID) do Field
		TamSx3(cField)[3]                                                       , ; // [04] C Tipo do campo
		TamSx3(cField)[1]                                                       , ; // [05] N Tamanho do campo
		TamSx3(cField)[2]                                                       , ; // [06] N Decimal do campo
		FwBuildFeature(STRUCT_FEATURE_VALID,GetSx3Cache(cField,"X3_VALID") )    , ; // [07] B Code-block de validação do campo
		NIL                                                                     , ; // [08] B Code-block de validação When do campoz
		NIL                                                                     , ; // [09] A Lista de valores permitido do campo
		.F.                                                                     , ; // [10] L Indica se o campo tem preenchimento obrigatório
		FwBuildFeature(STRUCT_FEATURE_INIPAD,GetSx3Cache(cField,"X3_RELACAO") ) , ; // [11] B Code-block de inicializacao do campo
		.F.                                                                     , ; // [12] L Indica se trata de um campo chave
		.F.                                                                     , ; // [13] L Indica se o campo pode receber valor em uma operação de update.
		.T.                                                                     ;   // [14] L Indica se o campo é virtual
	)
Return 


//------------------------------------------------------------------------------
/* /{Protheus.doc} J270SetData(oModel)
Função responsável por atualizar os dados nas tabelas NSY e O0W

@param  oModel - Modelo de dados da JURA270
@return 
@since 06/09/2022
/*/
//------------------------------------------------------------------------------
Static Function J270SetData(oModel)

Local nI         := 0
Local nX         := 0
Local nGridNsy   := 1
Local oModelO0W  := oModel:GetModel("O0WDETAIL")
Local oModelNSY  := oModel:GetModel("NSYDETAIL")
Local cMoeda     := ""
Local nValProvav := 0
Local nValPossiv := 0
Local nValRemoto := 0
Local nValIncont := 0
Local nMulta     := 0
Local nEncargo   := 0
Local nMultaEnc  := 0
Local nHonorario := 0
Local nMultaHon  := 0
Local lCposTrib  := .F.
Local lRedut     := .F.

	//-- Valida se possui os campos da O0W para valores tributários
	DbSelectArea("O0W")
	If ColumnPos('O0W_MULTRI') > 0 ;         //-- Percentual de multa tribu
		.AND. ColumnPos('O0W_CFCMUL') > 0 ;  //-- Forma de correcao multa
		.AND. ColumnPos('O0W_PERENC') > 0 ;  //-- Percentual de encargos
		.AND. ColumnPos('O0W_PERHON') > 0 ;  //-- Percentual de honorario

		lCposTrib := .T.
		cMoeda    := SuperGetMv("MV_JCMOPRO", .F., "01")
	EndIf

	lRedut := ColumnPos('O0W_REDUT') > 0

	oModelO0W:GoLine(1)

	For nX := 1 To oModelO0W:Length()

		If !oModelO0W:IsDeleted(nX) .AND. oModelO0W:IsUpdated(nX)

			oModelO0W:GoLine(nX)
			nGridNsy := oModelNSY:GetLine()

			For nI := 1 To oModelNSY:Length()
				oModelNSY:GoLine(nI)
				If !oModelNSY:IsDeleted()
					cCodTipPrg := JGetProgn(,oModelNSY:GetValue("NSY_CPROG"))[2]

					Do Case
					Case cCodTipPrg == "1"    // Provável
						nValProvav :=  oModelNSY:GetValue("NSY_VLCONT")
					Case cCodTipPrg == "2"    // Possível
						nValPossiv :=  oModelNSY:GetValue("NSY_VLCONT") //Valor do pedido?
					Case cCodTipPrg == "3"    // Remoto
						nValRemoto :=  oModelNSY:GetValue("NSY_VLCONT")
					Case cCodTipPrg == "4"    // Incontroverso
						nValIncont :=  oModelNSY:GetValue("NSY_VLCONT")
					End Case

					oModelNSY:SetValue("NSY_CPEVLR" , oModelO0W:GetValue("O0W_CTPPED"))

					oModelNSY:LoadValue("NSY_CFCORC" , oModelO0W:GetValue("O0W_CFRCOR"))
					JurValNW7(oModelO0W:GetValue("O0W_CFRCOR")) // Limpa os campos atualizados pela correção monetária

					oModelNSY:SetValue("NSY_DTJURC" , oModelO0W:GetValue("O0W_DTJURO"))
					oModelNSY:LoadValue("NSY_DTMULC", oModelO0W:GetValue("O0W_DTMULT"))
					oModelNSY:LoadValue("NSY_PERMUC", oModelO0W:GetValue("O0W_PERMUL"))

					//-- Valida se possui os campos da O0W para valores tributários, para atualizar os campos necessarios da NSY
					If lCposTrib

						If oModelO0W:isFieldUpdate("O0W_CFCMUL")//se alterar o campo de forma de correção, limpa os totalizadores da nsy
							oModelNSY:ClearField("NSY_CCORP1")
							oModelNSY:ClearField("NSY_CJURP1")
							oModelNSY:ClearField("NSY_MULAT1")
							oModelNSY:ClearField("NSY_V1VLRA")
						EndIf

						If Empty(oModelO0W:GetValue("O0W_MULTRI"))
							oModelNSY:ClearField("NSY_CFCOR1")
							oModelNSY:ClearField("NSY_V1DATA")
							oModelNSY:ClearField("NSY_DTJUR1")
							oModelNSY:ClearField("NSY_CMOIN1")
							oModelNSY:ClearField("NSY_DTMUL1")
							oModelNSY:ClearField("NSY_PERMU1")
							oModelNSY:ClearField("NSY_CCORP1")
							oModelNSY:ClearField("NSY_CJURP1")
							oModelNSY:ClearField("NSY_MULAT1")
							oModelNSY:ClearField("NSY_V1VLRA")
							oModelNSY:ClearField("NSY_V1VLR")
						Else
							//1ª instância
							oModelNSY:SetValue("NSY_CFCOR1", oModelO0W:GetValue("O0W_CFCMUL"))
							oModelNSY:SetValue("NSY_V1DATA", oModelO0W:GetValue("O0W_DATPED"))
							oModelNSY:SetValue("NSY_DTJUR1", oModelO0W:GetValue("O0W_DATPED"))
							oModelNSY:SetValue("NSY_CMOIN1", cMoeda)
							If JA094VlMult(oModelNSY:GetValue('NSY_CFCOR1'))
								oModelNSY:SetValue("NSY_DTMUL1", oModelO0W:GetValue("O0W_DATPED"))
								oModelNSY:SetValue("NSY_PERMU1", "0")
							EndIf

							nMulta := oModelNSY:GetValue("NSY_VLCONT") * oModelO0W:GetValue("O0W_MULTRI")/100

							oModelNSY:LoadValue("NSY_V1VLR", nMulta)

							// Limpa os valores valores preenchidos pela correção
							oModelNSY:ClearField("NSY_CCORP1", nMulta)
							oModelNSY:ClearField("NSY_CJURP1", nMulta)
							oModelNSY:ClearField("NSY_MULAT1", nMulta)
							oModelNSY:ClearField("NSY_V1VLRA", nMulta)

						EndIf
						//2ª instancia
						If Empty(oModelO0W:GetValue("O0W_PERENC"))
							oModelNSY:ClearField("NSY_CFCOR2")
							oModelNSY:ClearField("NSY_V2DATA")
							oModelNSY:ClearField("NSY_DTJUR2")
							oModelNSY:ClearField("NSY_CMOIN2")
							oModelNSY:ClearField("NSY_DTMUL2")
							oModelNSY:ClearField("NSY_PERMU2")
							oModelNSY:ClearField("NSY_V2VLR")
							oModelNSY:ClearField("NSY_CCORP2")
							oModelNSY:ClearField("NSY_CJURP2")
							oModelNSY:ClearField("NSY_MULAT2")
							oModelNSY:ClearField("NSY_V2VLRA")
							oModelNSY:ClearField("NSY_CFMUL2")
							oModelNSY:ClearField("NSY_DTMUT2")
							oModelNSY:ClearField("NSY_DTINC2")
							oModelNSY:ClearField("NSY_CMOEM2")
							oModelNSY:ClearField("NSY_VLRMU2")
							oModelNSY:ClearField("NSY_CCORM2")
							oModelNSY:ClearField("NSY_CJURM2")
							oModelNSY:ClearField("NSY_MUATU2")
						Else
							oModelNSY:SetValue("NSY_CFCOR2", oModelO0W:GetValue("O0W_CFRCOR"))
							oModelNSY:SetValue("NSY_V2DATA", oModelO0W:GetValue("O0W_DATPED"))
							oModelNSY:SetValue("NSY_DTJUR2", oModelO0W:GetValue("O0W_DATPED"))
							oModelNSY:SetValue("NSY_CMOIN2", cMoeda)
							If JA094VlMult(oModelNSY:GetValue('NSY_CFCOR2'))
								oModelNSY:SetValue("NSY_DTMUL2", oModelO0W:GetValue("O0W_DATPED"))
								oModelNSY:SetValue("NSY_PERMU2", "0")
							EndIf

							nEncargo := oModelNSY:GetValue("NSY_VLCONT") * oModelO0W:GetValue("O0W_PERENC")/100

							oModelNSY:SetValue("NSY_V2VLR", nEncargo)

							// Limpa os valores valores preenchidos pela correção
							oModelNSY:ClearField("NSY_CCORP2", nEncargo)
							oModelNSY:ClearField("NSY_CJURP2", nEncargo)
							oModelNSY:ClearField("NSY_MULAT2", nEncargo)
							oModelNSY:ClearField("NSY_V2VLRA", nEncargo)

							oModelNSY:SetValue("NSY_CFMUL2", oModelO0W:GetValue("O0W_CFCMUL"))
							oModelNSY:SetValue("NSY_DTMUT2", oModelO0W:GetValue("O0W_DATPED"))//Data Multa
							oModelNSY:SetValue("NSY_DTINC2", oModelO0W:GetValue("O0W_DATPED"))//Data Incidencia
							oModelNSY:SetValue("NSY_CMOEM2", cMoeda)

							nMultaEnc := oModelNSY:GetValue("NSY_V1VLR") * oModelO0W:GetValue("O0W_PERENC")/100

							oModelNSY:SetValue("NSY_VLRMU2", nMultaEnc)

							// Limpa os valores valores preenchidos pela correção
							oModelNSY:ClearField("NSY_CCORM2", nMultaEnc)
							oModelNSY:ClearField("NSY_CJURM2", nMultaEnc)
							oModelNSY:ClearField("NSY_MUATU2", nMultaEnc)
						EndIf
						//Tribunal Superior
						If Empty(oModelO0W:GetValue("O0W_PERHON"))
							oModelNSY:ClearField("NSY_CFCORT")
							oModelNSY:ClearField("NSY_TRDATA")
							oModelNSY:ClearField("NSY_DTJURT")
							oModelNSY:ClearField("NSY_CMOTRI")
							oModelNSY:ClearField("NSY_DTMUTR")
							oModelNSY:ClearField("NSY_PERMUT")
							oModelNSY:ClearField("NSY_TRVLR")
							oModelNSY:ClearField("NSY_CCORPT")
							oModelNSY:ClearField("NSY_CJURPT")
							oModelNSY:ClearField("NSY_VLRMUT")
							oModelNSY:ClearField("NSY_TRVLRA")
							oModelNSY:ClearField("NSY_CFMULT")
							oModelNSY:ClearField("NSY_DTMUTT")
							oModelNSY:ClearField("NSY_DTINCT")
							oModelNSY:ClearField("NSY_CMOEMT")
							oModelNSY:ClearField("NSY_VLRMT")
							oModelNSY:ClearField("NSY_CCORMT")
							oModelNSY:ClearField("NSY_CJURMT")
							oModelNSY:ClearField("NSY_MUATT")
						Else
							oModelNSY:SetValue("NSY_CFCORT", oModelO0W:GetValue("O0W_CFRCOR"))
							oModelNSY:SetValue("NSY_TRDATA", oModelO0W:GetValue("O0W_DATPED"))
							oModelNSY:SetValue("NSY_DTJURT", oModelO0W:GetValue("O0W_DATPED"))
							oModelNSY:SetValue("NSY_CMOTRI", cMoeda)
							If JA094VlMult(oModelNSY:GetValue('NSY_CFCORT'))
								oModelNSY:SetValue("NSY_DTMUTR", oModelO0W:GetValue("O0W_DATPED"))
								oModelNSY:SetValue("NSY_PERMUT", "0")
							EndIf

							nHonorario := oModelNSY:GetValue("NSY_VLCONT") * oModelO0W:GetValue("O0W_PERHON")/100

							oModelNSY:SetValue("NSY_TRVLR", nHonorario)

							// Limpa os valores valores preenchidos pela correção
							oModelNSY:ClearField("NSY_CCORPT", nHonorario)
							oModelNSY:ClearField("NSY_CJURPT", nHonorario)
							oModelNSY:ClearField("NSY_VLRMUT", nHonorario)
							oModelNSY:ClearField("NSY_TRVLRA", nHonorario)

							oModelNSY:SetValue("NSY_CFMULT", oModelO0W:GetValue("O0W_CFCMUL"))
							oModelNSY:SetValue("NSY_DTMUTT", oModelO0W:GetValue("O0W_DATPED"))//Data Multa
							oModelNSY:SetValue("NSY_DTINCT", oModelO0W:GetValue("O0W_DATPED"))//Data Incidencia
							oModelNSY:SetValue("NSY_CMOEMT", cMoeda)
							nMultaHon := oModelNSY:GetValue("NSY_V1VLR") * oModelO0W:GetValue("O0W_PERHON")/100
							oModelNSY:SetValue("NSY_VLRMT" , nMultaHon)

							// Limpa os valores valores preenchidos pela correção
							oModelNSY:ClearField("NSY_CCORMT", nMultaHon)
							oModelNSY:ClearField("NSY_CJURMT", nMultaHon)
							oModelNSY:ClearField("NSY_MUATT" , nMultaHon)
						EndIf
						oModelNSY:SetValue("NSY_V1INVL", '2')
						oModelNSY:SetValue("NSY_V2INVL", '2')
						oModelNSY:SetValue("NSY_TRINVL", '2')
					EndIf
				EndIf

				// Redutor
				If lRedut
					oModelNSY:SetValue("NSY_REDUT" , oModelO0W:GetValue("O0W_REDUT"))
				EndIf
			Next nI

			oModelO0W:LoadValue("O0W_VPROVA",nValProvav)
			oModelO0W:LoadValue("O0W_VPOSSI",nValPossiv)
			oModelO0W:LoadValue("O0W_VREMOT",nValRemoto)
			oModelO0W:LoadValue("O0W_VINCON",nValIncont)
		EndIf
	Next nX

	oModelNSY:SetNoInsertLine(.T.)
	oModelNSY:GoLine(nGridNsy)

Return .T.
