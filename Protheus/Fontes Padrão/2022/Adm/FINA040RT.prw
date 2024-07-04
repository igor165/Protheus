#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'FWEDITPANEL.CH'
#Include 'FINA040RT.CH'

Static cIdORig	:= ""

//-----------------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Consulta Rateio Multiplas Naturezas.
@author Mauricio Pequim Jr
@since  20/08/2015
@version 12
/*/	
//-----------------------------------------------------------------------------
Function FINA040RT(cChaveFK7)
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

Default cChaveFK7 := "" 
	
If !(Empty(cChaveFK7))	
	cIdORig := cChaveFK7

	FWExecView( STR0001 + " - " + STR0002,"FINA040RT", MODEL_OPERATION_VIEW,/**/,/**/,/**/,,aEnableButtons )	//"Consulta Rateio Múltiplas Naturezas"###"Visualizar"	
	
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
Local oModel := FWLoadModel("FINA040RT")
Local oFK7	:= FWFormStruct(2,'FK7')
Local oFK1	:= FWFormStruct(2,'FK1')
Local oSE1	:= FWFormStruct(2,'SE1', { |x| ALLTRIM(x) $ 'E1_NUM, E1_PARCELA, E1_PREFIXO, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_SALDO, E1_VALOR, E1_NATUREZ' } )
Local oSEV	:= FWFormStruct(2,'SEV')
Local oSEV1 := FWFormStruct(2,'SEV')
Local oSEZ	:= FWFormStruct(2,'SEZ')
Local oSEZ1 := FWFormStruct(2,'SEZ')

	oView:CreateHorizontalBox( 'BOXSE1', 17 )
	oView:CreateHorizontalBox( 'INFERIOR', 83 )

	oView:CreateFolder("PRINCIPAL", "INFERIOR")
	oView:AddSheet( 'PRINCIPAL'    , 'RAT_EMIS' , STR0011 )  // "Emissao"
	oView:AddSheet( 'PRINCIPAL'    , 'RAT_BX'   , STR0012 )  // "Baixas"
	
	oSE1:AddField("E1_DESCNAT", "13", STR0003, STR0003 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição da Natureza"
	oSEV:AddField("EV_DESCNAT", "07", STR0003, STR0003 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição da Natureza"
	oSEV1:AddField("EV_DESCNAT", "07", STR0003, STR0003 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição da Natureza"
	oSEZ:AddField("EZ_DESCCC" , "07", STR0004, STR0004 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição Centro de Custo"
	oSEZ1:AddField("EZ_DESCCC" , "07", STR0004, STR0004 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição Centro de Custo"

	oFK1:RemoveField('FK1_IDFK1')
	oFK1:RemoveField('FK1_RECPAG')
	oFK1:RemoveField('FK1_ORDREC')
	oFK1:RemoveField('FK1_ARCNAB')
	oFK1:RemoveField('FK1_CNABOC')
	oFK1:RemoveField('FK1_SERREC')
	oFK1:RemoveField('FK1_MULNAT')
	oFK1:RemoveField('FK1_AUTBCO')
	oFK1:RemoveField('FK1_NODIA')
	oFK1:RemoveField('FK1_LA')
	oFK1:RemoveField('FK1_IDDOC')
	oFK1:RemoveField('FK1_IDPROC')
	oFK1:RemoveField('FK1_IDCOMP')

	oSEV:RemoveField('EV_IDDOC')

	oSEV1:RemoveField('EV_IDDOC')

	oSEZ:RemoveField('EZ_TIPO')
	oSEZ:RemoveField('EZ_IDDOC')

	oSEZ1:RemoveField('EZ_TIPO')
	oSEZ1:RemoveField('EZ_IDDOC')

	oSE1:SetProperty( 'E1_VALOR'	, MVC_VIEW_ORDEM,	'06')
	oSE1:SetProperty( 'E1_CLIENTE'	, MVC_VIEW_ORDEM,	'07')
	oSE1:SetProperty( 'E1_LOJA'		, MVC_VIEW_ORDEM,	'08')
	oSE1:SetProperty( 'E1_NOMCLI'	, MVC_VIEW_ORDEM,	'09')
	oSE1:SetProperty( 'E1_EMISSAO'	, MVC_VIEW_ORDEM,	'10')
	oSE1:SetProperty( 'E1_VENCREA'	, MVC_VIEW_ORDEM,	'11')
	oSE1:SetProperty( 'E1_NATUREZ'	, MVC_VIEW_ORDEM,	'12')

	oFK1:SetProperty( 'FK1_FILORI'	, MVC_VIEW_ORDEM,	'01')
	oFK1:SetProperty( 'FK1_DATA'	, MVC_VIEW_ORDEM,	'02')
	oFK1:SetProperty( 'FK1_NATURE'	, MVC_VIEW_ORDEM,	'03')
	oFK1:SetProperty( 'FK1_MOEDA'	, MVC_VIEW_ORDEM,	'04')
	oFK1:SetProperty( 'FK1_VALOR'	, MVC_VIEW_ORDEM,	'05')
	oFK1:SetProperty( 'FK1_VLMOE2'	, MVC_VIEW_ORDEM,	'06')
	oFK1:SetProperty( 'FK1_TXMOED'	, MVC_VIEW_ORDEM,	'07')
	oFK1:SetProperty( 'FK1_VENCTO'	, MVC_VIEW_ORDEM,	'08')
	
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
	oSEZ1:SetProperty( 'EZ_PERC'		, MVC_VIEW_ORDEM,	'08')
	oSEZ1:SetProperty( 'EZ_VALOR'	, MVC_VIEW_ORDEM,	'09')
	oSEZ1:SetProperty( 'EZ_ITEMCTA'	, MVC_VIEW_ORDEM,	'11')
	oSEZ1:SetProperty( 'EZ_CLVL'		, MVC_VIEW_ORDEM,	'12')
	
	oSE1:SetNoFolder()

	oSEV:SetProperty('*'			,MVC_VIEW_CANCHANGE ,.F. )
	oSEZ:SetProperty('*'			,MVC_VIEW_CANCHANGE ,.F. )	
	//
	oView:SetModel( oModel )			
	oView:AddField("VIEWSE1",oSE1,"SE1MASTER")
	oView:AddGrid("VIEWFK1",oFK1,"FK1DETAIL")
	oView:AddGrid("VIEWSEV" ,oSEV,"SEVDETAIL")
	oView:AddGrid("VIEWSEV1" ,oSEV1,"SEV1DETAIL")
	oView:AddGrid("VIEWSEZ" ,oSEZ,"SEZDETAIL")	
	oView:AddGrid("VIEWSEZ1" ,oSEZ1,"SEZ1DETAIL")
	//
	oView:CreateHorizontalBox( 'BOXSEV', 50,,, 'PRINCIPAL', 'RAT_EMIS' )
	oView:CreateHorizontalBox( 'BOXSEZ', 50,,, 'PRINCIPAL', 'RAT_EMIS' )
	
	oView:CreateHorizontalBox( 'BOXFK1' , 34,,, 'PRINCIPAL', 'RAT_BX' )
	oView:CreateHorizontalBox( 'BOXSEV1', 33,,, 'PRINCIPAL', 'RAT_BX' )
	oView:CreateHorizontalBox( 'BOXSEZ1', 33,,, 'PRINCIPAL', 'RAT_BX' )	
	//
	oView:SetOwnerView('VIEWSE1', 'BOXSE1')
	oView:SetOwnerView('VIEWFK1', 'BOXFK1') 
	oView:SetOwnerView('VIEWSEV', 'BOXSEV')
	oView:SetOwnerView('VIEWSEV1', 'BOXSEV1')
	oView:SetOwnerView('VIEWSEZ', 'BOXSEZ')	
	oView:SetOwnerView('VIEWSEZ1', 'BOXSEZ1')
	//
	oView:EnableTitleView('VIEWSE1' , STR0005 )	//'Contas a Receber' 
	oView:EnableTitleView('VIEWFK1' , STR0013 )	//'Informacoes de Baixas'
	oView:EnableTitleView('VIEWSEV' , STR0006 )	//'Rateio Multinaturezas' 
	oView:EnableTitleView('VIEWSEV1' , STR0006 )	//'Rateio Multinaturezas' 
	oView:EnableTitleView('VIEWSEZ' , STR0007 )	//'Rateio Multinaturezas por Centros de Custo'	
	oView:EnableTitleView('VIEWSEZ1' , STR0007 )	//'Rateio Multinaturezas por Centros de Custo'

	oView:SetOnlyView( 'VIEWSE1' )

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
Local oModel	:= MPFormModel():New('FINA040RT',/*Pre*/,/*Pos*/,/*Commit*/)
Local oSE1		:= FWFormStruct(1, 'SE1')
Local oSEV 		:= FWFormStruct(1, 'SEV')
Local oSEV1		:= FWFormStruct(1, 'SEV')
Local oSEZ 		:= FWFormStruct(1, 'SEZ')
Local oSEZ1		:= FWFormStruct(1, 'SEZ')
Local oFK7		:= FWFormStruct(1, 'FK7')
Local oFK1		:= FWFormStruct(1, 'FK1')
Local aAuxFK7	:= {}
Local aAuxFK1	:= {}
Local aAuxSEV	:= {}
Local aAuxSEV1	:= {}
Local aAuxSEZ	:= {}
Local aAuxSEZ1	:= {}
Local nTamDNat 	:= TamSx3("ED_DESCRIC")[1]
Local nTamDCC 	:= TamSx3("CTT_DESC01")[1]
Local bLoadFK1	:=  {|oGridModel, lCopia| LoadFK1(oGridModel, lCopia)}
Local nIndEV5	:= Iif(FWSIXUtil():ExistIndex('SEV' , '5'), 5,1)
Local nIndEZ4	:= Iif(FWSIXUtil():ExistIndex('SEZ' , '8'), 8,1)

	oSE1:AddField(			;
	STR0003					, ;	// [01] Titulo do campo	//"Descrição da Natureza"
	STR0003					, ;	// [02] ToolTip do campo 	//"Descrição da Natureza"
	"E1_DESCNAT"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDNat				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('SED',1,xFilial('SED')+SE1->E1_NATUREZ,'ED_DESCRIC')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual

	oSEV:AddField(			;
	STR0003					, ;	// [01] Titulo do campo	//"Descrição da Natureza"
	STR0003					, ;	// [02] ToolTip do campo 	//"Descrição da Natureza"
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

	oSEV1:AddField(			;
	STR0003					, ;	// [01] Titulo do campo	//"Descrição da Natureza"
	STR0003					, ;	// [02] ToolTip do campo 	//"Descrição da Natureza"
	"EV_DESCNAT"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDNat				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('SED',1,xFilial('SED')+SEV->EV_NATUREZ,'ED_DESCRIC')") ,,,;// [11] Inicializador Padrão do campo
	.T.)

	oSEZ:AddField(			;
	STR0004					, ;	// [01] Titulo do campo	//"Descrição Centro Custo"
	STR0004					, ;	// [02] ToolTip do campo 	//"Descrição Centro Custo"
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

	oSEZ1:AddField(			;
	STR0004					, ;	// [01] Titulo do campo	//"Descrição Centro Custo"
	STR0004					, ;	// [02] ToolTip do campo 	//"Descrição Centro Custo"
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


	oSE1:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)
	oFK1:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)
	oFK7:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)

	oModel:AddFields("SE1MASTER",/*cOwner*/	, oSE1)
	// Emissao
	oModel:AddGrid("FK7DETAIL"  ,"SE1MASTER", oFK7)
	oModel:AddGrid("SEVDETAIL" ,"FK7DETAIL"	, oSEV)
	oModel:AddGrid("SEZDETAIL" ,"SEVDETAIL"	, oSEZ)
	// Baixa
	oModel:AddGrid("FK1DETAIL"  ,"FK7DETAIL", oFK1, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, bLoadFK1)
	oModel:AddGrid("SEV1DETAIL" ,"FK1DETAIL", oSEV1)
	oModel:AddGrid("SEZ1DETAIL" ,"SEV1DETAIL", oSEZ1)
	//
	oModel:SetPrimaryKey({'E1_FILIAL','E1_PREFIXO','E1_NUM','E1_PARCELA','E1_TIPO','E1_CLIENTE','E1_LOJA'})

	// Emissao
	aAdd( aAuxFK7, {"FK7_FILIAL","xFilial('FK7')"} )
	aAdd( aAuxFK7, {"FK7_ALIAS","'SE1'"})
	aAdd( aAuxFK7, {"FK7_CHAVE","SE1->E1_FILIAL + '|' + SE1->E1_PREFIXO + '|' + SE1->E1_NUM + '|' + SE1->E1_PARCELA + '|' + SE1->E1_TIPO + '|' + SE1->E1_CLIENTE + '|' + SE1->E1_LOJA"})
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
	aAdd( aAuxFK1, {"FK1_FILIAL","xFilial('FK1')"} )
	aAdd( aAuxFK1, {"FK1_IDDOC","FK7_IDDOC"})
	oModel:SetRelation("FK1DETAIL", aAuxFK1 , FK1->(IndexKey(2) ) )
	//
	aAdd(aAuxSEV1, {"EV_FILIAL", "xFilial('SEV')"})
	aAdd(aAuxSEV1, {"EV_IDDOC",  "FK1_IDFK1"})
    oModel:SetRelation("SEV1DETAIL", aAuxSEV1 , SEV->(IndexKey(nIndEV5) ) )
	//
	aAdd(aAuxSEZ1, {"EZ_FILIAL" , "xFilial('SEZ')"})
	aAdd(aAuxSEZ1, {"EZ_IDDOC"  , "FK1_IDFK1"})
	aAdd(aAuxSEZ1, {"EZ_NATUREZ", "SEV1DETAIL.EV_NATUREZ"})
    oModel:SetRelation("SEZ1DETAIL", aAuxSEZ1 , SEZ->(IndexKey(nIndEZ4) ) )

	//
	oModel:GetModel( 'FK7DETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'FK1DETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'SEVDETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'SEV1DETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'SEZDETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'SEZ1DETAIL' ):SetOptional( .T. )

	oModel:GetModel( 'FK7DETAIL' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'FK1DETAIL' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'SE1MASTER' ):SetOnlyQuery( .T. )
	//
	//Se o model for chamado via adapter de baixas.
	oModel:GetModel( 'FK1DETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'SEVDETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'SEV1DETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'SEZDETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'SEZ1DETAIL' ):SetNoInsertLine(.T.)

	oModel:GetModel( "FK1DETAIL" ):SetNoDeleteLine(.T.)
	oModel:GetModel( "SEVDETAIL" ):SetNoDeleteLine(.T.)
	oModel:GetModel( "SEV1DETAIL" ):SetNoDeleteLine(.T.)
	oModel:GetModel( "SEZDETAIL" ):SetNoDeleteLine(.T.)
	oModel:GetModel( "SEZ1DETAIL" ):SetNoDeleteLine(.T.)

	// Filtra rateio sem baixa que nao foi migrado
	oModel:GetModel( 'SEV1DETAIL' ):SetLoadFilter( { { 'EV_IDDOC', "' '", MVC_LOADFILTER_NOT_EQUAL } } )
	oModel:GetModel( 'SEZ1DETAIL' ):SetLoadFilter( { { 'EZ_IDDOC', "' '", MVC_LOADFILTER_NOT_EQUAL } } )

Return oModel

//-------------------------------------------------------------------
/*/ {Protheus.doc} F040CMNT
Função de consulta do rateio multinatureza - Emissão

@sample F040CMNT()
@author Mauricio Pequim Jr
@since 03/04/2017
@version 1.0

@return lRet	se o valor é valido ou não
/*/
//-------------------------------------------------------------------
Function F040CMNT()

Local cChaveTit	:= ""
Local cChaveFK7	:= ""
Local cChaveFK1	:= ""
Local cChaveSEV	:= ""
Local cChaveSEZ	:= ""
Local aArea		:= GetArea()
Local lMultNatBx  := .F.

cChaveTit := xFilial("SE1",SE1->E1_FILORIG) + "|" +;
				SE1->E1_PREFIXO	+ "|" +;
				SE1->E1_NUM		+ "|" +;
				SE1->E1_PARCELA	+ "|" +;
				SE1->E1_TIPO	+ "|" +;
				SE1->E1_CLIENTE	+ "|" +;
				SE1->E1_LOJA
	
cChaveFK7 := FINGRVFK7("SE1",cChaveTit)
cChaveFK1 := FindBxKey("SE1",cChaveTit)

// Verifica se a baixa foi rateada em multiplas naturezas
If !Empty(cChaveFK1)
	dbSelectArea("FK1")
	FK1->(dbSetOrder(1))
	If FK1->(dbSeek(xFilial("FK1") + cChaveFK1 ))
		lMultNatBx := FK1->FK1_MULNAT == "1"
	EndIf
EndIf

//Verifico se o rateio multinatureza está ativado
If MV_MULNATR .and. ( SE1->E1_MULTNAT == "1" .or. lMultNatBx )

	//Verifico se esse titulo teve rateio multinatureza
	dbSelectArea("SEV")
	SEV->(dbSetOrder(4)) //EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_RECPAG+EV_IDENT+EV_SEQ+EV_NATUREZ
	SEV->(MSSeek(xFilial("SEV",SE1->E1_FILORIG) + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA) +"R"))
	cChaveSEV := SEV->(EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA)+"R"
		
	While !(SEV->(EOF())) .AND. xFilial("SEV")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA)+"R" == cChaveSEV

			If Empty(SEV->EV_IDDOC)
				RecLock("SEV")
				SEV->EV_IDDOC := If(SEV->EV_IDENT == '1', cChaveFK7, cChaveFK1)
				MsUnlock()

				//Verifico se esse titulo teve rateio multinatureza por centro de custo
				If SEV->EV_RATEICC == '1'
					dbSelectArea("SEZ")			
					SEZ->(dbSetOrder(5))	//EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_RECPAG+EZ_IDENT+EZ_SEQ+EZ_CCUSTO
					SEZ->(MSSeek(xFilial("SEZ",SE1->E1_FILORIG) + SEV->(EV_PREFIXO + EV_NUM + EV_PARCELA + EV_TIPO + EV_CLIFOR + EV_LOJA + EV_NATUREZ) +"R"))
					cChaveSEZ := SEZ->(EZ_FILIAL + EZ_PREFIXO + EZ_NUM + EZ_PARCELA + EZ_TIPO + EZ_CLIFOR + EZ_LOJA + EZ_NATUREZ) +"R"

					While !(SEZ->(EOF())) .AND. xFilial("SEZ",SE1->E1_FILORIG)+SEZ->(EZ_PREFIXO + EZ_NUM + EZ_PARCELA + EZ_TIPO + EZ_CLIFOR + EZ_LOJA + EZ_NATUREZ) +"R" == cChaveSEZ
							If Empty(SEZ->EZ_IDDOC)
									RecLock("SEZ")
									SEZ->EZ_IDDOC := If(SEZ->EZ_IDENT == '1', cChaveFK7, cChaveFK1)
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
	FINA040RT(cChaveFK7)

ElseIf !MV_MULNATR
	Help( ,, "F040CMNT1",, STR0008, 1, 0,,,,,, {STR0009} )	//"Rateio por múltiplas naturezas não está habilitado no seu sistema."###"Por favor, Verifique o paramêtro MV_MULNATP"
ElseIf SE1->E1_MULTNAT != "1"
	Help( ,, "F040CMNT2",, STR0010, 1, 0 )		//"Este título não possui rateio por múltiplas naturezas."
Endif

RestArea(aArea)

Return .t.

//-------------------------------------------------------------------
/*/ {Protheus.doc} LoadFK1
Funcao de carregamento das informacoes de baixas

@param oGridModel - Model que chamou o bLoad
@param lCopia - Se uma operacao de copia

@author Igor Sousa do Nascimento
@since 24/05/2017

@return Array com informacoes para composicao do grid
/*/
//-------------------------------------------------------------------
Static Function LoadFK1(oGridModel AS Object, lCopia AS Logical) AS Array
	Local aBaixas		AS Array
	Local aFK1Stru		AS Array
	Local aCampos		AS Array
	Local aAux 			AS Array
	Local cAliasBxs		AS Character
	Local cSelect		AS Character
	Local cQry			AS Character
	Local cKeySE1  		AS Character
	Local nX 			AS Numeric

	aBaixas  	:= {}
	aFK1Stru 	:= FK1->(dbStruct())
	aCampos  	:= {}
	aAux     	:= {}
	cAliasBxs	:= GetNextAlias()
	cSelect  	:= ""
	cQry	 	:= ""
	cKeySE1  	:= xFilial("SE1",SE1->E1_FILORIG) + "|" +;
						SE1->E1_PREFIXO	+ "|" +;
						SE1->E1_NUM		+ "|" +;
						SE1->E1_PARCELA	+ "|" +;
						SE1->E1_TIPO	+ "|" +;
						SE1->E1_CLIENTE	+ "|" +;
						SE1->E1_LOJA
	nX			:= 0

	// Prepara estrutura de campos para temporaria (aCampos)
	For nX := 1 to Len(aFK1Stru) //   Tipo,			  Tamanho,		  Decimal
		aAdd(aCampos,{aFK1Stru[nX][1], aFK1Stru[nX][2],aFK1Stru[nX][3],aFK1Stru[nX][4]})
		// Prepara Select
		cSelect += aFK1Stru[nX][1] + ", "
	Next nX

	// Filtra baixas
	cQry += " SELECT " + cSelect + " FK1.R_E_C_N_O_ RECNO FROM " + RetSqlName("FK1") + " FK1"
	cQry += " 	INNER JOIN " + RetSqlName("FK7") + " FK7 "
	cQry += " 	ON FK7.FK7_FILIAL = FK1.FK1_FILIAL "
	cQry += " 	AND FK7.FK7_IDDOC = FK1.FK1_IDDOC "
	cQry += " WHERE "
	cQry += " FK1.FK1_FILIAL = '" + xFilial("FK1") + "'"
	cQry += " AND NOT EXISTS( "
	cQry += " 	SELECT FK1EST.FK1_IDDOC FROM " + RetSqlName("FK1") +" FK1EST"
	cQry += " 	WHERE FK1EST.FK1_FILIAL = FK1.FK1_FILIAL"
	cQry += " 	AND FK1EST.FK1_IDDOC = FK1.FK1_IDDOC "
	cQry += " 	AND FK1EST.FK1_SEQ = FK1.FK1_SEQ "
	cQry += " 	AND FK1EST.FK1_TPDOC = 'ES' "
	cQry += " 	AND FK1EST.D_E_L_E_T_ = ' ') "
	cQry += " AND FK1.D_E_L_E_T_ = ' ' "
	cQry += " AND FK7.FK7_CHAVE = '" + cKeySE1 + "'"
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

	(cAliasBxs)->(dbCloseArea())

Return aBaixas
