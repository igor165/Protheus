#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'
#INCLUDE 'FWEDITPANEL.CH'
#INCLUDE 'FINC050VA.CH'

STATIC dDataBx := .F.
Static cIdORig	:= ""

//-----------------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Detalhamento dos valores acessórios.
@author Marcos Gomes
@since  08/08/2015
@version 12
/*/	
//-----------------------------------------------------------------------------
Function FINC050VA( cIdBaixa, dDtBaixa )
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
Local nOK				:= 0

Default cIdBaixa := "" 
Default dDtBaixa := CTOD("//")
	
If !(Empty(cIdBaixa)) .and. !Empty(dDtBaixa)	
	cIdORig := cIdBaixa
	dDataBx := dDtBaixa

	//Titulos gerados via integração RM Classis não sofrem alteração dos valores acessórios  
	FWExecView( STR0002 + " - " + STR0004,"FINC050VA", MODEL_OPERATION_VIEW,/**/,/**/,/**/,,aEnableButtons )	//"Visualizar"
	
Endif


Return 

//-----------------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Interface.
@author Mauricio Pequim Jr	
@since  04/08/2016
@version 12
/*/	
Static Function ViewDef()
Local oView	:= FWFormView():New()
Local oModel	:= FWLoadModel("FINC050VA")
Local oFK7	:= FWFormStruct(2,'FK7')
Local oSE2	:= FWFormStruct(2,'SE2', { |x| ALLTRIM(x) $ 'E2_NUM, E2_PARCELA, E2_PREFIXO, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_VENCREA, E2_SALDO, E2_VALOR, E2_NATUREZ' } )
Local oFKD	:= FWFormStruct(2,'FKD', { |x| ALLTRIM(x) $ 'FKD_CODIGO, FKD_DESC, FKD_TPVAL,FKD_VALOR,FKD_VLCALC,FKD_VLINFO,FKD_DTBAIX,FKD_ACAO' })

	oSE2:AddField("E2_DESCNAT", "10", STR0003, STR0003, {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição da Natureza"

	oSE2:SetProperty( 'E2_FORNECE'	, MVC_VIEW_ORDEM,	'06')
	oSE2:SetProperty( 'E2_LOJA'		, MVC_VIEW_ORDEM,	'07')
	oSE2:SetProperty( 'E2_NOMFOR'	, MVC_VIEW_ORDEM,	'08')
	oSE2:SetProperty( 'E2_NATUREZ'	, MVC_VIEW_ORDEM,	'09')
	oSE2:SetProperty( 'E2_DESCNAT'	, MVC_VIEW_ORDEM,	'10')

	oSE2:SetNoFolder()

	oFKD:SetProperty('*'			,MVC_VIEW_CANCHANGE ,.F. )
	oFKD:SetProperty( 'FKD_VLINFO'	,MVC_VIEW_CANCHANGE ,.T. )
	oFKD:SetProperty( 'FKD_ACAO'	,MVC_VIEW_ORDEM,	'20')	
	
	//
	oView:SetModel( oModel )			
	oView:AddField("VIEWSE2",oSE2,"SE2MASTER")
	oView:AddGrid("VIEWFKD" ,oFKD,"FKDDETAIL")
	//
	oView:SetViewProperty("VIEWSE2","SETLAYOUT",{FF_LAYOUT_HORZ_DESCR_TOP ,1})  
	//
	oView:CreateHorizontalBox( 'BOXSE2', 027 )
	oView:CreateHorizontalBox( 'BOXFKD', 073 )
	//
	oView:SetOwnerView('VIEWSE2', 'BOXSE2') 
	oView:SetOwnerView('VIEWFKD', 'BOXFKD')
	//
	oView:EnableTitleView('VIEWSE2' , STR0001 /*'Contas a Receber'*/ ) 
	oView:EnableTitleView('VIEWFKD' , STR0002 /*'Valores Acessórios'*/ ) 
	oView:SetOnlyView( 'VIEWSE2' )

Return oView

//-----------------------------------------------------------------------------
/*/{Protheus.doc}ModelDef
Modelo de dados.
@author Marcos Gomes	
@since  08/08/2016
@version 12
/*/	
//-----------------------------------------------------------------------------
Static Function ModelDef()
Local oModel		:= MPFormModel():New('FINC050VA',/*Pre*/,/*Pos*/,/*Commit*/)
Local oSE2		:= FWFormStruct(1, 'SE2')
Local oFKD		:= FWFormStruct(1, 'FKD')
Local oFK7		:= FWFormStruct(1, 'FK7')
Local aAuxFK7		:= {}
Local aAuxFKD		:= {}
Local aTamVal		:= TamSx3("FKD_VLCALC")
Local nTamDNat 	:= TamSx3("ED_DESCRIC")[1]

Local bInitDesc	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_DESC"),"")')
Local bInitVal	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_TPVAL"),"")')
Local bInitAcao	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_ACAO"),"")')

	oSE2:AddField(			  ;
	STR0003					, ;	// [01] Titulo do campo	//"Descrição da Natureza"
	STR0003					, ;	// [02] ToolTip do campo 	//"Descrição da Natureza"
	"E2_DESCNAT"				, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDNat					, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('SED',1,xFilial('SED')+SE2->E2_NATUREZ,'ED_DESCRIC')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual

	oSE2:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)
	oFK7:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)

	oFKD:SetProperty('FKD_DESC'		, MODEL_FIELD_INIT, bInitDesc 		)    
	oFKD:SetProperty('FKD_TPVAL'	, MODEL_FIELD_INIT, bInitVal 		)  
	oFKD:SetProperty('FKD_ACAO'		, MODEL_FIELD_INIT, bInitAcao )
	oFKD:SetProperty('FKD_VLCALC'	, MODEL_FIELD_OBRIGAT, .F.)
	//
	oModel:AddFields("SE2MASTER",/*cOwner*/	, oSE2)
	oModel:AddGrid("FK7DETAIL","SE2MASTER"  , oFK7)
	oModel:AddGrid("FKDDETAIL" ,"SE2MASTER" , oFKD)
	//
	oModel:SetPrimaryKey({'E2_FILIAL','E2_PREFIXO','E2_NUM','E2_PARCELA','E2_TIPO','E2_FORNECE','E2_LOJA'})
	//
	oModel:GetModel( 'FKDDETAIL' ):SetUniqueLine( { 'FKD_CODIGO' } )
	aAdd( aAuxFK7, {"FK7_FILIAL","xFilial('FK7')"} )
	aAdd( aAuxFK7, {"FK7_ALIAS","'SE2'"})
	aAdd( aAuxFK7, {"FK7_CHAVE","SE2->E2_FILIAL + '|' + SE2->E2_PREFIXO + '|' + SE2->E2_NUM + '|' + SE2->E2_PARCELA + '|' + SE2->E2_TIPO + '|' + SE2->E2_FORNECE + '|' + SE2->E2_LOJA"})
	oModel:SetRelation("FK7DETAIL", aAuxFK7 , FK7->(IndexKey(2) ) ) 
	//
	aAdd(aAuxFKD, {"FKD_FILIAL", "xFilial('FKD')"})
	aAdd(aAuxFKD, {"FKD_IDDOC", "FK7_IDDOC"})
	oModel:SetRelation("FKDDETAIL", aAuxFKD , FKD->(IndexKey(1) ) ) 
	//
	oModel:GetModel( 'FKDDETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'FK7DETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'FK7DETAIL' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'SE2MASTER' ):SetOnlyQuery( .T. )
	//
	//Se o model for chamado via adapter de baixas.
	oModel:GetModel( 'FKDDETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( "FKDDETAIL" ):SetNoDeleteLine(.T.)
	
	oModel:SetActivate( {|oModel| FC050VAInfo(oModel) } )
	
Return oModel

//-----------------------------------------------------------------------------
/*/{Protheus.doc}FC050VAInfo
Busca valor dos VAs no load do Model da Baixa CR
@author Marcos Gomes	
@since  08/08/2016
@version 12
/*/	
//-----------------------------------------------------------------------------
Function FC050VAInfo(oModel)

Local oSubFKD := oModel:GetModel("FKDDETAIL")
Local nTamFKD := oSUBFKD:Length()
Local nX		:= 0
Local nVlAces := 0
Local lRet	:= .T.
Local aArea	:= GetArea()
Local cCodVA	:= oSubFKD:GetValue("FKD_CODIGO")

//Consulta de Apenas uma Baixa
If !Empty(cIdORig)	

	For nX := 1 to nTamFKD
		oSubFKD:GoLine( nX )	
		oSubFKD:LoadValue("FKD_VLCALC", 0)
		oSubFKD:LoadValue("FKD_VLINFO", 0)
		oSubFKD:LoadValue("FKD_DTBAIX", dDataBx )			
	Next

	FK6->(dbSetorder(2))	//FK6_FILIAL+FK6_IDORIG+FK6_TABORI+FK6_IDFK6
	If FK6->(DbSeek(xFilial("FK6") + cIdORig + "FK1" ))
		cChaveFK6 := xFilial("FK6") + cIdORig + "FK1" 
		While !(FK6->(EOF())) .AND. FK6->(FK6_FILIAL+FK6_IDORIG+FK6_TABORI) == cChaveFK6
			If FK6->FK6_TPDOC == "VA"
	 			If oSubFKD:SeekLine( { {"FKD_CODIGO", FK6->FK6_CODVAL}})
					oSubFKD:LoadValue("FKD_VLCALC",FK6->FK6_VALCAL)
					oSubFKD:LoadValue("FKD_VLINFO",FK6->FK6_VALMOV)
				Endif
			Endif
			FK6->(DBSKIP())
		EndDo
	Endif
Endif	
	
RestArea( aArea )

Return lRet



