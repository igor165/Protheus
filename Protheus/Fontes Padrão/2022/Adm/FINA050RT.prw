#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'FWEDITPANEL.CH'
#Include 'FINA050RT.CH'

Static cIdORig	:= ""

//-----------------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Consulta Rateio Multiplas Naturezas.
@author Mauricio Pequim Jr
@since  20/08/2015
@version 12
/*/	
//-----------------------------------------------------------------------------
Function FINA050RT(cChaveFK7)
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

Default cChaveFK7 := "" 
	
If !(Empty(cChaveFK7))	
	cIdORig := cChaveFK7
	
	FWExecView( STR0001 + " - " + STR0002,"FINA050RT", MODEL_OPERATION_VIEW,/**/,/**/,/**/,,aEnableButtons )	//"Consulta Rateio Múltiplas Naturezas"###"Visualizar"
	
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
Local oModel := FWLoadModel("FINA050RT")
Local oFK7	:= FWFormStruct(2,'FK7')
Local oFK2	:= FWFormStruct(2,'FK2')
Local oSE2	:= FWFormStruct(2,'SE2', { |x| ALLTRIM(x) $ 'E2_NUM, E2_PARCELA, E2_PREFIXO, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_VENCREA, E2_SALDO, E2_VALOR, E2_NATUREZ' } )
Local oSEV	:= FWFormStruct(2,'SEV')
Local oSEV1 := FWFormStruct(2,'SEV')
Local oSEZ	:= FWFormStruct(2,'SEZ')
Local oSEZ1 := FWFormStruct(2,'SEZ')

	oView:CreateHorizontalBox( 'BOXSE2', 17 )
	oView:CreateHorizontalBox( 'INFERIOR', 83 )

	oView:CreateFolder("PRINCIPAL", "INFERIOR")
	oView:AddSheet( 'PRINCIPAL'    , 'RAT_EMIS' , STR0011 )  // "Emissao"
	oView:AddSheet( 'PRINCIPAL'    , 'RAT_BX'   , STR0012 )  // "Baixas"

	oSE2:AddField("E2_DESCNAT", "13", STR0003, STR0003 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição da Natureza"
	oSEV:AddField("EV_DESCNAT", "07", STR0003, STR0003 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição da Natureza"
	oSEV1:AddField("EV_DESCNAT", "07", STR0003, STR0003 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição da Natureza"
	oSEZ:AddField("EZ_DESCCC" , "07", STR0004, STR0004 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição Centro de Custo"
	oSEZ1:AddField("EZ_DESCCC" , "07", STR0004, STR0004 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição Centro de Custo"

	oFK2:RemoveField('FK2_IDFK2')
	oFK2:RemoveField('FK2_RECPAG')
	oFK2:RemoveField('FK2_ORDREC')
	oFK2:RemoveField('FK2_ARCNAB')
	oFK2:RemoveField('FK2_CNABOC')
	oFK2:RemoveField('FK2_SERREC')
	oFK2:RemoveField('FK2_MULNAT')
	oFK2:RemoveField('FK2_AUTBCO')
	oFK2:RemoveField('FK2_NODIA')
	oFK2:RemoveField('FK2_LA')
	oFK2:RemoveField('FK2_IDDOC')
	oFK2:RemoveField('FK2_IDPROC')
	oFK2:RemoveField('FK2_IDCOMP')

	oSEV:RemoveField('EV_IDDOC')
	oSEV1:RemoveField('EV_IDDOC')

	oSEZ:RemoveField('EZ_TIPO')
	oSEZ:RemoveField('EZ_IDDOC')
	oSEZ1:RemoveField('EZ_TIPO')
	oSEZ1:RemoveField('EZ_IDDOC')

	oSE2:SetProperty( 'E2_VALOR'	, MVC_VIEW_ORDEM,	'06')
	oSE2:SetProperty( 'E2_FORNECE'	, MVC_VIEW_ORDEM,	'07')
	oSE2:SetProperty( 'E2_LOJA'		, MVC_VIEW_ORDEM,	'08')
	oSE2:SetProperty( 'E2_NOMFOR'	, MVC_VIEW_ORDEM,	'09')
	oSE2:SetProperty( 'E2_EMISSAO'	, MVC_VIEW_ORDEM,	'10')
	oSE2:SetProperty( 'E2_VENCREA'	, MVC_VIEW_ORDEM,	'11')
	oSE2:SetProperty( 'E2_NATUREZ'	, MVC_VIEW_ORDEM,	'12')

	oFK2:SetProperty( 'FK2_FILORI'	, MVC_VIEW_ORDEM,	'01')
	oFK2:SetProperty( 'FK2_DATA'	, MVC_VIEW_ORDEM,	'02')
	oFK2:SetProperty( 'FK2_NATURE'	, MVC_VIEW_ORDEM,	'03')
	oFK2:SetProperty( 'FK2_MOEDA'	, MVC_VIEW_ORDEM,	'04')
	oFK2:SetProperty( 'FK2_VALOR'	, MVC_VIEW_ORDEM,	'05')
	oFK2:SetProperty( 'FK2_VLMOE2'	, MVC_VIEW_ORDEM,	'06')
	oFK2:SetProperty( 'FK2_TXMOED'	, MVC_VIEW_ORDEM,	'07')
	oFK2:SetProperty( 'FK2_VENCTO'	, MVC_VIEW_ORDEM,	'08')

	oSE2:SetNoFolder()
	
	oSEV:SetProperty( 'EV_NATUREZ'	, MVC_VIEW_ORDEM,	'06')
	oSEV:SetProperty( 'EV_PERC'		, MVC_VIEW_ORDEM,	'08')
	oSEV:SetProperty( 'EV_VALOR'	, MVC_VIEW_ORDEM,	'09')

	oSEV1:SetProperty( 'EV_NATUREZ'	, MVC_VIEW_ORDEM,	'06')
	oSEV1:SetProperty( 'EV_PERC'	, MVC_VIEW_ORDEM,	'08')
	oSEV1:SetProperty( 'EV_VALOR'	, MVC_VIEW_ORDEM,	'09')
	
	oSEZ:SetProperty( 'EZ_CCUSTO'	, MVC_VIEW_ORDEM,	'06')
	oSEZ:SetProperty( 'EZ_PERC'		, MVC_VIEW_ORDEM,	'08')
	oSEZ:SetProperty( 'EZ_VALOR'	, MVC_VIEW_ORDEM,	'09')
	oSEZ:SetProperty( 'EZ_ITEMCTA'	, MVC_VIEW_ORDEM,	'11')
	oSEZ:SetProperty( 'EZ_CLVL'		, MVC_VIEW_ORDEM,	'12')

	oSEZ1:SetProperty( 'EZ_CCUSTO'	, MVC_VIEW_ORDEM,	'06')
	oSEZ1:SetProperty( 'EZ_PERC'	, MVC_VIEW_ORDEM,	'08')
	oSEZ1:SetProperty( 'EZ_VALOR'	, MVC_VIEW_ORDEM,	'09')
	oSEZ1:SetProperty( 'EZ_ITEMCTA'	, MVC_VIEW_ORDEM,	'11')
	oSEZ1:SetProperty( 'EZ_CLVL'	, MVC_VIEW_ORDEM,	'12')

	oSEV:SetProperty('*'			,MVC_VIEW_CANCHANGE ,.F. )
	oSEZ:SetProperty('*'			,MVC_VIEW_CANCHANGE ,.F. )	
	//
	oView:SetModel( oModel )			
	oView:AddField("VIEWSE2",oSE2,"SE2MASTER")
	oView:AddGrid("VIEWFK2",oFK2,"FK2DETAIL")
	oView:AddGrid("VIEWSEV" ,oSEV,"SEVDETAIL")
	oView:AddGrid("VIEWSEV1" ,oSEV1,"SEV1DETAIL")
	oView:AddGrid("VIEWSEZ" ,oSEZ,"SEZDETAIL")
	oView:AddGrid("VIEWSEZ1" ,oSEZ1,"SEZ1DETAIL")	
	//
	oView:CreateHorizontalBox( 'BOXSEV', 50,,, 'PRINCIPAL', 'RAT_EMIS' )
	oView:CreateHorizontalBox( 'BOXSEZ', 50,,, 'PRINCIPAL', 'RAT_EMIS' )
	
	oView:CreateHorizontalBox( 'BOXFK2' , 34,,, 'PRINCIPAL', 'RAT_BX' )
	oView:CreateHorizontalBox( 'BOXSEV1', 33,,, 'PRINCIPAL', 'RAT_BX' )
	oView:CreateHorizontalBox( 'BOXSEZ1', 33,,, 'PRINCIPAL', 'RAT_BX' )	
	//
	oView:SetOwnerView('VIEWSE2', 'BOXSE2') 
	oView:SetOwnerView('VIEWFK2', 'BOXFK2')
	oView:SetOwnerView('VIEWSEV', 'BOXSEV')
	oView:SetOwnerView('VIEWSEV1', 'BOXSEV1')
	oView:SetOwnerView('VIEWSEZ', 'BOXSEZ')	
	oView:SetOwnerView('VIEWSEZ1', 'BOXSEZ1')
	//
	oView:EnableTitleView('VIEWSE2' , STR0005 )	//'Contas a Pagar' 
	oView:EnableTitleView('VIEWFK2' , STR0013 )	//'Informacoes de Baixas'
	oView:EnableTitleView('VIEWSEV' , STR0006 )	//'Rateio Multinaturezas' 
	oView:EnableTitleView('VIEWSEV1' , STR0006 )	//'Rateio Multinaturezas' 
	oView:EnableTitleView('VIEWSEZ' , STR0007 )	//'Rateio Multinaturezas por Centros de Custo'	
	oView:EnableTitleView('VIEWSEZ1' , STR0007 )	//'Rateio Multinaturezas por Centros de Custo'

	oView:SetOnlyView( 'VIEWSE2' )

Return oView

//-----------------------------------------------------------------------------
/*/{Protheus.doc}ModelDef
Modelo de dados.
@author Mauricio Pequim Jr	
@since  04/08/2016
@version 12
/*/	
//-----------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= MPFormModel():New('FINA050RT',/*Pre*/,/*Pos*/,/*Commit*/)
Local oSE2		:= FWFormStruct(1, 'SE2')
Local oSEV 		:= FWFormStruct(1, 'SEV')
Local oSEV1		:= FWFormStruct(1, 'SEV')
Local oSEZ 		:= FWFormStruct(1, 'SEZ')
Local oSEZ1		:= FWFormStruct(1, 'SEZ')
Local oFK7		:= FWFormStruct(1, 'FK7')
Local oFK2		:= FWFormStruct(1, 'FK2')
Local aAuxFK2	:= {}
Local aAuxFK7	:= {}
Local aAuxSEV	:= {}
Local aAuxSEZ	:= {}
Local aAuxSEV1	:= {}
Local aAuxSEZ1	:= {}
Local nTamDNat 	:= TamSx3("ED_DESCRIC")[1]
Local nTamDCC 	:= TamSx3("CTT_DESC01")[1]
Local bLoadFK2	:=  {|oGridModel, lCopia| LoadFK2(oGridModel, lCopia)}
Local nIndEV5	:= Iif(FWSIXUtil():ExistIndex('SEV' , '5'), 5,1)
Local nIndEZ4	:= Iif(FWSIXUtil():ExistIndex('SEZ' , '8'), 8,1)

	oSE2:AddField(			  ;
	"Descrição da Natureza"	, ;	// [01] Titulo do campo	//"Descrição da Natureza"
	"Descrição da Natureza"	, ;	// [02] ToolTip do campo 	//"Descrição da Natureza"
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

	oSEV:AddField(			  ;
	"Descrição da Natureza"	, ;	// [01] Titulo do campo	//"Descrição da Natureza"
	"Descrição da Natureza"	, ;	// [02] ToolTip do campo 	//"Descrição da Natureza"
	"EV_DESCNAT"				, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDNat					, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('SED',1,xFilial('SED')+SEV->EV_NATUREZ,'ED_DESCRIC')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual

	oSEZ:AddField(			  ;
	"Descrição Centro Custo", ;	// [01] Titulo do campo	//"Descrição da Natureza"
	"Descrição Centro Custo", ;	// [02] ToolTip do campo 	//"Descrição da Natureza"
	"EZ_DESCCC"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDCC					, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('CTT',1,xFilial('CTT')+SEZ->EZ_CCUSTO,'CTT_DESC01')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual

	oSEV1:AddField(			  ;
	"Descrição da Natureza"	, ;	// [01] Titulo do campo	//"Descrição da Natureza"
	"Descrição da Natureza"	, ;	// [02] ToolTip do campo 	//"Descrição da Natureza"
	"EV_DESCNAT"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDNat				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('SED',1,xFilial('SED')+SEV->EV_NATUREZ,'ED_DESCRIC')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual

	oSEZ1:AddField(			  ;
	"Descrição Centro Custo", ;	// [01] Titulo do campo	//"Descrição da Natureza"
	"Descrição Centro Custo", ;	// [02] ToolTip do campo 	//"Descrição da Natureza"
	"EZ_DESCCC"				, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDCC					, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('CTT',1,xFilial('CTT')+SEZ->EZ_CCUSTO,'CTT_DESC01')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual

	oSE2:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)
	oFK2:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)
	oFK7:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)

	// Emissao
	oModel:AddFields("SE2MASTER",/*cOwner*/	, oSE2)
	oModel:AddGrid("FK7DETAIL"  ,"SE2MASTER", oFK7)
	oModel:AddGrid("SEVDETAIL"  ,"FK7DETAIL", oSEV)
	oModel:AddGrid("SEZDETAIL"  ,"SEVDETAIL", oSEZ)
	// Baixa
	oModel:AddGrid("FK2DETAIL"  ,"FK7DETAIL", oFK2, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, bLoadFK2)
	oModel:AddGrid("SEV1DETAIL" ,"FK2DETAIL", oSEV1)
	oModel:AddGrid("SEZ1DETAIL" ,"SEV1DETAIL", oSEZ1)
	//
	oModel:SetPrimaryKey({'E2_FILIAL','E2_PREFIXO','E2_NUM','E2_PARCELA','E2_TIPO','E2_FORNECE','E2_LOJA'})

	// Emissao
	aAdd( aAuxFK7, {"FK7_FILIAL","xFilial('FK7')"} )
	aAdd( aAuxFK7, {"FK7_ALIAS","'SE2'"})
	aAdd( aAuxFK7, {"FK7_CHAVE","SE2->E2_FILIAL + '|' + SE2->E2_PREFIXO + '|' + SE2->E2_NUM + '|' + SE2->E2_PARCELA + '|' + SE2->E2_TIPO + '|' + SE2->E2_FORNECE + '|' + SE2->E2_LOJA"})
	oModel:SetRelation("FK7DETAIL", aAuxFK7 , FK7->(IndexKey(2) ) ) 
	//
	aAdd(aAuxSEV, {"EV_FILIAL", "xFilial('SEV')"})
	aAdd(aAuxSEV, {"EV_IDDOC",  "FK7_IDDOC"})
    oModel:SetRelation("SEVDETAIL", aAuxSEV , SEV->(IndexKey(nIndEV5) ) )
	//
	aAdd(aAuxSEZ, {"EZ_FILIAL" , "xFilial('SEZ')"})
	aAdd(aAuxSEZ, {"EZ_IDDOC"  , "FK7_IDDOC"})
	aAdd(aAuxSEZ, {"EZ_NATUREZ", "SEVDETAIL.EV_NATUREZ"})
    oModel:SetRelation("SEZDETAIL", aAuxSEZ , SEZ->(IndexKey(nIndEZ4) ) )

	// Baixa
	aAdd( aAuxFK2, {"FK2_FILIAL","xFilial('FK2')"} )
	aAdd( aAuxFK2, {"FK2_IDDOC","FK7_IDDOC"})
	oModel:SetRelation("FK2DETAIL", aAuxFK2 , FK2->(IndexKey(2) ) )
	//
	aAdd(aAuxSEV1, {"EV_FILIAL", "xFilial('SEV')"})
	aAdd(aAuxSEV1, {"EV_IDDOC",  "FK2_IDFK2"})
    oModel:SetRelation("SEV1DETAIL", aAuxSEV1 , SEV->(IndexKey(nIndEV5) ) )
	//
	aAdd(aAuxSEZ1, {"EZ_FILIAL" , "xFilial('SEZ')"})
	aAdd(aAuxSEZ1, {"EZ_IDDOC"  , "FK2_IDFK2"})
	aAdd(aAuxSEZ1, {"EZ_NATUREZ", "SEV1DETAIL.EV_NATUREZ"})	
    oModel:SetRelation("SEZ1DETAIL", aAuxSEZ1 , SEZ->(IndexKey(nIndEZ4) ) )

	//
	oModel:GetModel( 'FK7DETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'FK2DETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'SEVDETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'SEV1DETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'SEZDETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'SEZ1DETAIL' ):SetOptional( .T. )

	oModel:GetModel( 'FK7DETAIL' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'FK2DETAIL' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'SE2MASTER' ):SetOnlyQuery( .T. )
	//
	//Se o model for chamado via adapter de baixas.
	oModel:GetModel( 'FK2DETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'SEVDETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'SEV1DETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'SEZDETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'SEZ1DETAIL' ):SetNoInsertLine(.T.)

	oModel:GetModel( "FK2DETAIL" ):SetNoDeleteLine(.T.)
	oModel:GetModel( "SEVDETAIL" ):SetNoDeleteLine(.T.)
	oModel:GetModel( "SEV1DETAIL" ):SetNoDeleteLine(.T.)
	oModel:GetModel( "SEZDETAIL" ):SetNoDeleteLine(.T.)
	oModel:GetModel( "SEZ1DETAIL" ):SetNoDeleteLine(.T.)

	// Filtra rateio sem baixa que nao foi migrado
	oModel:GetModel( 'SEV1DETAIL' ):SetLoadFilter( { { 'EV_IDDOC', "' '", MVC_LOADFILTER_NOT_EQUAL } } )
	oModel:GetModel( 'SEZ1DETAIL' ):SetLoadFilter( { { 'EZ_IDDOC', "' '", MVC_LOADFILTER_NOT_EQUAL } } )

Return oModel

//-------------------------------------------------------------------
/*/ {Protheus.doc} F050CMNT
Função de consulta do rateio multinatureza - Emissão

@sample F050CMNT()
@author Mauricio Pequim Jr
@since 03/04/2017
@version 1.0

@return lRet	se o valor é valido ou não
/*/
//-------------------------------------------------------------------
Function F050CMNT()

Local cChaveTit	:= ""
Local cChaveFK2	:= ""
Local cChaveFK7	:= ""
Local cChaveSEV	:= ""
Local cChaveSEZ	:= ""
Local aArea		:= GetArea()
Local lMultNatBx  := .F.

cChaveTit := xFilial("SE2",SE2->E2_FILORIG) + "|" +;
			SE2->E2_PREFIXO	+ "|" +;
			SE2->E2_NUM		+ "|" +;
			SE2->E2_PARCELA	+ "|" +;
			SE2->E2_TIPO	+ "|" +;
			SE2->E2_FORNECE	+ "|" +;
			SE2->E2_LOJA
	
cChaveFK7 := FINGRVFK7("SE2",cChaveTit)
cChaveFK2 := FindBxKey("SE2",cChaveTit)

// Verifica se a baixa foi rateada em multiplas naturezas
If !Empty(cChaveFK2)
	dbSelectArea("FK2")
	FK2->(dbSetOrder(1))
	If FK2->(dbSeek(xFilial("FK2") + cChaveFK2 ))
		lMultNatBx := FK2->FK2_MULNAT == "1"
	EndIf
EndIf

//Verifico se o rateio multinatureza está ativado
If MV_MULNATP .and. ( SE2->E2_MULTNAT == "1" .or. lMultNatBx )

	//Verifico se esse titulo teve rateio multinatureza
	dbSelectArea("SEV")
	SEV->(dbSetOrder(4)) //EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_RECPAG+EV_IDENT+EV_SEQ+EV_NATUREZ
	SEV->(MSSeek(xFilial("SEV",SE2->E2_FILORIG) + SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA) +"P"))

	cChaveSEV := SEV->(EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA)+"P"
		
	While !(SEV->(EOF())) .AND. xFilial("SEV")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA)+"P" == cChaveSEV

			If Empty(SEV->EV_IDDOC)
				RecLock("SEV")
				SEV->EV_IDDOC := If(Empty(cChaveFK2), cChaveFK7, cChaveFK2)
				MsUnlock()

				//Verifico se esse titulo teve rateio multinatureza por centro de custo
				If SEV->EV_RATEICC == '1'
					dbSelectArea("SEZ")			
					SEZ->(dbSetOrder(5))	//EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_RECPAG+EZ_IDENT+EZ_SEQ+EZ_CCUSTO
					SEZ->(MSSeek(xFilial("SEZ",SE2->E2_FILORIG) + SEV->(EV_PREFIXO + EV_NUM + EV_PARCELA + EV_TIPO + EV_CLIFOR + EV_LOJA + EV_NATUREZ) +"P"))
					cChaveSEZ := SEZ->(EZ_FILIAL + EZ_PREFIXO + EZ_NUM + EZ_PARCELA + EZ_TIPO + EZ_CLIFOR + EZ_LOJA + EZ_NATUREZ) +"P"

					While !(SEZ->(EOF())) .AND. xFilial("SEZ",SE2->E2_FILORIG)+SEZ->(EZ_PREFIXO + EZ_NUM + EZ_PARCELA + EZ_TIPO + EZ_CLIFOR + EZ_LOJA + EZ_NATUREZ) +"P" == cChaveSEZ
							If Empty(SEZ->EZ_IDDOC)
								RecLock("SEZ")
								SEZ->EZ_IDDOC := Iif(Empty(cChaveFK2), cChaveFK7, cChaveFK2)
								MsUnlock()
							EndIf
						SEZ->(DBSKIP())
					EndDo
				Endif
			EndIf
			
			dbSelectArea("SEV")
			SEV->(DBSKIP())
	EndDo
	
	//Consulta Rateio MultiNatureza
	FINA050RT(cChaveFK7)

ElseIf !MV_MULNATP
	Help( ,, "F050CMNT1",, STR0008, 1, 0,,,,,, {STR0009} )	//"Rateio por múltiplas naturezas não está habilitado no seu sistema."###"Por favor, Verifique o paramêtro MV_MULNATP"

ElseIf SE2->E2_MULTNAT != "1"
	Help( ,, "F050CMNT2",, STR0010, 1, 0 )		//"Este título não possui rateio por múltiplas naturezas."
Endif

RestArea(aArea)

Return .t.

//-------------------------------------------------------------------
/*/ {Protheus.doc} LoadFK2
Funcao de carregamento das informacoes de baixas

@param oGridModel - Model que chamou o bLoad
@param lCopia - Se uma operacao de copia

@author Igor Sousa do Nascimento
@since 22/05/2017

@return Array com informacoes para composicao do grid
/*/
//-------------------------------------------------------------------
Static Function LoadFK2(oGridModel AS Object, lCopia AS Logical) AS Array
	Local aBaixas		AS Array
	Local aFK2Stru		AS Array
	Local aCampos  		AS Array
	Local aAux     		AS Array
	Local cAliasBxs		AS Character
	Local cSelect		AS Character
	Local cQry			AS Character
	Local cKeySE2		AS Character
	Local nX			AS Numeric

	aBaixas  	:= {}
	aFK2Stru 	:= FK2->(dbStruct())
	aCampos  	:= {}
	aAux     	:= {}
	cAliasBxs	:= GetNextAlias()
	cSelect  	:= ""
	cQry	   	:= ""
	cKeySE2  	:= xFilial("SE2",SE2->E2_FILORIG) + "|" +;
						SE2->E2_PREFIXO	+ "|" +;
						SE2->E2_NUM		+ "|" +;
						SE2->E2_PARCELA	+ "|" +;
						SE2->E2_TIPO	+ "|" +;
						SE2->E2_FORNECE	+ "|" +;
						SE2->E2_LOJA
	nX 			:= 0

	// Prepara estrutura de campos para temporaria (aCampos)
	For nX := 1 to Len(aFK2Stru) //   Tipo,			  Tamanho,		  Decimal
		aAdd(aCampos,{aFK2Stru[nX][1], aFK2Stru[nX][2],aFK2Stru[nX][3],aFK2Stru[nX][4]})
		// Prepara Select
		cSelect += aFK2Stru[nX][1] + ", "
	Next nX

	// Filtra baixas
	cQry += " SELECT " + cSelect + " FK2.R_E_C_N_O_ RECNO FROM " + RetSqlName("FK2") + " FK2"
	cQry += " 	INNER JOIN " + RetSqlName("FK7") + " FK7 "
	cQry += " 	ON FK7.FK7_FILIAL = FK2.FK2_FILORI "
	cQry += " 	AND FK7.FK7_IDDOC = FK2.FK2_IDDOC "
	cQry += " WHERE "
	cQry += " FK2.FK2_FILIAL = '" + xFilial("FK2") + "'"
	cQry += " AND NOT EXISTS( "
	cQry += " 	SELECT FK2EST.FK2_IDDOC FROM " + RetSqlName("FK2") +" FK2EST"
	cQry += " 	WHERE FK2EST.FK2_FILIAL = FK2.FK2_FILIAL"
	cQry += " 	AND FK2EST.FK2_IDDOC = FK2.FK2_IDDOC "
	cQry += " 	AND FK2EST.FK2_SEQ = FK2.FK2_SEQ "
	cQry += " 	AND FK2EST.FK2_TPDOC = 'ES' "
	cQry += " 	AND FK2EST.D_E_L_E_T_ = ' ') "
	cQry += " AND FK2.D_E_L_E_T_ = ' ' "
	cQry += " AND FK7.FK7_CHAVE = '" + cKeySE2 + "'"
	cQry += " AND FK7.D_E_L_E_T_ = ' ' "
	cQry := ChangeQuery(cQry)
	MPSysOpenQuery(cQry, cAliasBxs)

	dbSelectArea(cAliasBxs)
	(cAliasBxs)->(dbGoTop())

	// Prepara estrutura de composicao do grid
	While !(cAliasBxs)->(EoF())
		// Formata estrutura do bLoad
		For nX := 1 to Len(aCampos)	// 		Formata data ( / / )
			aAdd( aAux, If( aCampos[nX][2] == "D", StoD((cAliasBxs)->&(aCampos[nX][1])), (cAliasBxs)->&(aCampos[nX][1]) ) )
		Next nX

		aAdd(aBaixas,{(cAliasBxs)->RECNO, aAux})
		dbSkip()
		aAux := {}
	EndDo

	(cAliasBxs)->(DbCloseArea())

Return aBaixas
