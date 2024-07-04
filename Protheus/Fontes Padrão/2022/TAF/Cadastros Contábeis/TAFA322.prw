#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA322.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA322 
Identificação dos Períodos e Formas de Apuração do IRPJ e-Lalur / e-Lacs

@author Anderson Costa
@since 24/06/2014
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA322()

Local oBrw	:=	FWmBrowse():New()
Local aGetSX2	:=	SX2->(getarea())

Private cQualif	:=	""
Private cPerIni	:=	""
Private cPerFin	:=	""

oBrw:SetDescription( STR0001 ) //"Identificação dos Períodos e Formas de Apuração do IRPJ e da CSLL no Ano-Calendário"
oBrw:SetCacheView( .F. )
oBrw:SetAlias( "CEN" )
oBrw:SetMenuDef( "TAFA322" )

//Define ordenação
CEN->( DBSetOrder( 2 ) )

dbSelectArea("CET")
If Alltrim(POSICIONE('SX2',1,'CET','X2_UNICO')) == "CET_FILIAL+CET_ID+CET_IDCTA+CET_IDLCTO+CET_IDCTAC+CET_CODTRI"
	RestArea(aGetSX2)
	oBrw:Activate()
Else
	RestArea(aGetSX2)
	MsgInfo(STR0026)//O dicionário de dados do TAF está desatualizado em relação a última liberação disponível no portal do cliente para o ECF. Para o correto funcionamento desta rotina, é necessário baixar o último SDFBRA disponível no portal do cliente, executar o UPDDISTR e UPDTAF
EndIf
Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 24/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf322Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA322" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 24/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCEN	:=	FWFormStruct( 1, "CEN" )
Local oStruCEO	:=	FWFormStruct( 1, "CEO" )
Local oStruCEP	:=	FWFormStruct( 1, "CEP" )
Local oStruCEQ	:=	FWFormStruct( 1, "CEQ" )
Local oStruCER	:=	FWFormStruct( 1, "CER" )
Local oStruCES	:=	FWFormStruct( 1, "CES" )
Local oStruCET	:=	FWFormStruct( 1, "CET" )
Local oStruCEU	:=	FWFormStruct( 1, "CEU" )
Local oStruCEV	:=	FWFormStruct( 1, "CEV" )
Local oStruCHR	:=	FWFormStruct( 1, "CHR" )
Local oStruCHS	:=	FWFormStruct( 1, "CHS" )
Local oStruCHT	:=	FWFormStruct( 1, "CHT" )
Local oStruCHU	:=	FWFormStruct( 1, "CHU" )
Local oStruCHV	:=	FWFormStruct( 1, "CHV" )
Local oModel	:=	MPFormModel():New( "TAFA322",, { |oModel| ValidModel( oModel ) }, { |oModel| SaveModel( oModel ) }, { |oModel| ExitModel( oModel ) } )
Local bValid	:=	{ |oModel| ValidActivate( oModel ) }

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruCEN:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
EndIf

oStruCEN:SetProperty( "CEN_DTINI", MODEL_FIELD_VALID, { || ValidDate( oModel, "CEN_DTINI" ) } )
oStruCEN:SetProperty( "CEN_DTFIN", MODEL_FIELD_VALID, { || ValidDate( oModel, "CEN_DTFIN" ) } )

oStruCEO:SetProperty( "CEO_CODLAN", MODEL_FIELD_WHEN, { || .F. } )
oStruCEO:SetProperty( "CEO_TIPORL", MODEL_FIELD_WHEN, { || Iif( FWFldGet( "CEO_TPLANC" ) == "R", .F., .T. ) } )
oStruCEO:SetProperty( "CEO_VLRLC", MODEL_FIELD_WHEN, { || Iif( FWFldGet( "CEO_TPLANC" ) == "R" .or. FWFldGet( "CEO_TIPORL" ) == "1" .Or. FWFldGet( "CEO_TIPORL" ) == "2", .F., .T. ) } )
oStruCEO:SetProperty( "CEO_HISTLC", MODEL_FIELD_WHEN, { || Iif( FWFldGet( "CEO_TPLANC" ) == "R", .F., .T. ) } )

oStruCHR:SetProperty( "CHR_CODLAN", MODEL_FIELD_WHEN, { || .F. } )
oStruCHR:SetProperty( "CHR_TIPORL", MODEL_FIELD_WHEN, { || Iif( FWFldGet( "CHR_TPLANC" ) == "R", .F., .T. ) } )
oStruCHR:SetProperty( "CHR_VLRLC", MODEL_FIELD_WHEN, { || Iif( FWFldGet( "CHR_TPLANC" ) == "R" .or. FWFldGet( "CHR_TIPORL" ) == "1" .Or. FWFldGet( "CHR_TIPORL" ) == "2", .F., .T. ) } )
oStruCHR:SetProperty( "CHR_HISTLC", MODEL_FIELD_WHEN, { || Iif( FWFldGet( "CHR_TPLANC" ) == "R", .F., .T. ) } )

//Tratamento para que os campos referentes a descrição do lançamento fiquem menores falicitando a manutenção 
//pelo usuário
oStruCEO:SetProperty( "CEO_DCODLA", MODEL_FIELD_TAMANHO, 80 )
oStruCHR:SetProperty( "CHR_DCODLA", MODEL_FIELD_TAMANHO, 80 )

/*--------------------------------------------------------------------------------------------*/

oModel:AddFields('MODEL_CEN', /*cOwner*/, oStruCEN )

If FunName() <> "TAFA444" .and. !IsInCallStack('TAF444_010') .and. !IsInCallStack('TAF444_011') .and. !IsInCallStack('TAF444_012') .and. !IsInCallStack('TAF444_013') .and. !IsInCallStack('TAF444_019')
	oModel:AddGrid( "MODEL_CEO", "MODEL_CEN", oStruCEO, { |oModelGrid, nLine, cAction, cField, xValNew, xValOld| FVlLcLalur( cField, cAction, xValNew, "CEO" ) },/*{ |oModel, nLinha| VldHistCEO( oModel, nLinha ) }*/,,, { |oModel| LoadModel( oModel, "ADDGRIDCEO" ) } )
	oModel:AddGrid( "MODEL_CHR", "MODEL_CEN", oStruCHR, { |oModelGrid, nLine, cAction, cField, xValNew, xValOld| FVlLcLacs( cField, cAction, xValNew, "CHR" ) },,,, { |oModel| LoadModel( oModel, "ADDGRIDCHR" ) } )
	oModel:AddGrid( "MODEL_CEP", "MODEL_CEO", oStruCEP, { |oModelGrid, nLine, cAction, cField, xValNew, xValOld| FVlLcLalur( cField, cAction, xValNew, "CEP" ) } )
	oModel:AddGrid( "MODEL_CHS", "MODEL_CHR", oStruCHS, { |oModelGrid, nLine, cAction, cField, xValNew, xValOld| FVlLcLacs( cField, cAction, xValNew, "CHS" ) } )
Else
	oModel:AddGrid( "MODEL_CEO", "MODEL_CEN", oStruCEO )
	oModel:AddGrid( "MODEL_CHR", "MODEL_CEN", oStruCHR )
	oModel:AddGrid( "MODEL_CEP", "MODEL_CEO", oStruCEP )
	oModel:AddGrid( "MODEL_CHS", "MODEL_CHR", oStruCHS )
EndIf

oModel:GetModel( "MODEL_CEO" ):SetUniqueLine( { "CEO_IDCODL" } ) //lalur
oModel:GetModel( "MODEL_CHR" ):SetUniqueLine( { "CHR_IDCODL" } ) //elacs

oModel:GetModel( "MODEL_CEP" ):SetOptional( .T. )
oModel:GetModel( "MODEL_CEP" ):SetUniqueLine( { "CEP_IDCTA" } )

oModel:GetModel( "MODEL_CHS" ):SetOptional( .T. )
oModel:GetModel( "MODEL_CHS" ):SetUniqueLine( { "CHS_IDCTA" } )

oModel:AddGrid("MODEL_CEQ","MODEL_CEO",oStruCEQ, { |oModelGrid , nLine , cAction , cField , xValNew , xValOld| FVlLcLalur( cField, cAction, xValNew, 'CEQ' ) } )
oModel:GetModel("MODEL_CEQ"):SetOptional(.T.)
oModel:GetModel("MODEL_CEQ"):SetUniqueLine({"CEQ_CTA","CEQ_CODCUS"})

oModel:AddGrid("MODEL_CER","MODEL_CEQ",oStruCER)
oModel:GetModel("MODEL_CER"):SetOptional(.T.)                                        
oModel:GetModel("MODEL_CER"):SetUniqueLine({"CER_IDNUML"})

oModel:AddGrid("MODEL_CHT","MODEL_CHR",oStruCHT,  { |oModelGrid , nLine , cAction , cField , xValNew , xValOld| FVlLcLacs( cField, cAction, xValNew, 'CHT' )})
oModel:GetModel("MODEL_CHT"):SetOptional(.T.)
oModel:GetModel("MODEL_CHT"):SetUniqueLine({"CHT_CTA","CHT_CODCUS"})

oModel:AddGrid("MODEL_CHU","MODEL_CHT",oStruCHU)
oModel:GetModel("MODEL_CHU"):SetOptional(.T.)                                          
oModel:GetModel("MODEL_CHU"):SetUniqueLine({"CHU_IDNUML"})

oModel:AddGrid("MODEL_CES","MODEL_CEO",oStruCES)
oModel:GetModel("MODEL_CES"):SetOptional(.T.)
oModel:GetModel("MODEL_CES"):SetUniqueLine({"CES_IDPROC"})
//oModel:GetModel("MODEL_CES"):SetNoInsertLine(.T.) //A partir de 2015 é permitido ter mais de uma linha

oModel:AddGrid("MODEL_CHV","MODEL_CHR",oStruCHV)
oModel:GetModel("MODEL_CHV"):SetOptional(.T.)
oModel:GetModel("MODEL_CHV"):SetUniqueLine({"CHV_IDPROC"})
//oModel:GetModel("MODEL_CHV"):SetNoInsertLine(.T.) //A partir de 2015 é permitido ter mais de uma linha

oModel:AddGrid("MODEL_CET","MODEL_CEN",oStruCET)
oModel:GetModel("MODEL_CET"):SetOptional(.T.)

oModel:GetModel("MODEL_CET"):SetUniqueLine({"CET_IDCTA","CET_IDLCTO","CET_IDCTAC","CET_CODTRI"})
	
oModel:AddGrid("MODEL_CEU","MODEL_CET",oStruCEU)
oModel:GetModel("MODEL_CEU"):SetOptional(.T.)
oModel:GetModel("MODEL_CEU"):SetUniqueLine({"CEU_IDPROC"})
//oModel:GetModel("MODEL_CEU"):SetNoInsertLine(.T.) //A partir de 2015 é permitido ter mais de uma linha

oModel:AddGrid("MODEL_CEV","MODEL_CEN",oStruCEV)
oModel:GetModel("MODEL_CEV"):SetOptional(.T.)
oModel:GetModel("MODEL_CEV"):SetUniqueLine({"CEV_IDCTA","CEV_CODTRI"})

oModel:GetModel('MODEL_CEN'):SetPrimaryKey({"CEN_DTINI", "CEN_DTFIN", "CEN_IDPERA"})

oModel:SetRelation("MODEL_CEO",{ {"CEO_FILIAL","xFilial('CEO')"}, {"CEO_ID","CEN_ID"}},CEO->(IndexKey(1)) )
oModel:SetRelation("MODEL_CHR",{ {"CHR_FILIAL","xFilial('CHR')"}, {"CHR_ID","CEN_ID"}},CHR->(IndexKey(1)) )
oModel:SetRelation("MODEL_CEP",{ {"CEP_FILIAL","xFilial('CEP')"}, {"CEP_ID","CEN_ID"},{"CEP_IDCODL","CEO_IDCODL"} },CEP->(IndexKey(1)) )
oModel:SetRelation("MODEL_CHS",{ {"CHS_FILIAL","xFilial('CHS')"}, {"CHS_ID","CEN_ID"},{"CHS_IDCODL","CHR_IDCODL"} },CHS->(IndexKey(1)) )
oModel:SetRelation("MODEL_CEQ",{ {"CEQ_FILIAL","xFilial('CEQ')"}, {"CEQ_ID","CEN_ID"},{"CEQ_IDCODL","CEO_IDCODL"} },CEQ->(IndexKey(1)) )
oModel:SetRelation("MODEL_CER",{ {"CER_FILIAL","xFilial('CER')"}, {"CER_ID","CEN_ID"},{"CER_IDCODL","CEO_IDCODL"},{"CER_CTA","CEQ_CTA"},{"CER_CODCUS","CEQ_CODCUS"} },CER->(IndexKey(1)) )
oModel:SetRelation("MODEL_CHT",{ {"CHT_FILIAL","xFilial('CHT')"}, {"CHT_ID","CEN_ID"},{"CHT_IDCODL","CHR_IDCODL"} },CHT->(IndexKey(1)) )
oModel:SetRelation("MODEL_CHU",{ {"CHU_FILIAL","xFilial('CHU')"}, {"CHU_ID","CEN_ID"},{"CHU_IDCODL","CHR_IDCODL"},{"CHU_CTA","CHT_CTA"},{"CHU_CODCUS","CHT_CODCUS"} },CHU->(IndexKey(1)) )
oModel:SetRelation("MODEL_CES",{ {"CES_FILIAL","xFilial('CES')"}, {"CES_ID","CEN_ID"},{"CES_IDCODL","CEO_IDCODL"} },CES->(IndexKey(1)) )
oModel:SetRelation("MODEL_CHV",{ {"CHV_FILIAL","xFilial('CHV')"}, {"CHV_ID","CEN_ID"},{"CHV_IDCODL","CHR_IDCODL"} },CHV->(IndexKey(1)) )
oModel:SetRelation("MODEL_CET",{ {"CET_FILIAL","xFilial('CET')"}, {"CET_ID","CEN_ID"}},CET->(IndexKey(1)) )
oModel:SetRelation("MODEL_CEU",{ {"CEU_FILIAL","xFilial('CEU')"}, {"CEU_ID","CEN_ID"},{"CEU_CTA","CET_IDCTA"}, {"CEU_IDLCTO","CET_IDLCTO"}, {"CEU_CTACP","CET_IDCTAC"} },CEU->(IndexKey(1)) )
oModel:SetRelation("MODEL_CEV",{ {"CEV_FILIAL","xFilial('CEV')"}, {"CEV_ID","CEN_ID"}},CEV->(IndexKey(1)) )

oModel:SetOnDemand(.t.)
oModel:SetVldActivate( bValid )
oModel:SetActivate( { |oModel| LoadModel( oModel, "SETACTIVATE" ) } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 24/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:=	FWLoadModel( "TAFA322" )
Local oStruCEN	:=	FWFormStruct( 2, "CEN" )
Local oStruCEO	:=	FWFormStruct( 2, "CEO" )
Local oStruCHR	:=	FWFormStruct( 2, "CHR" )
Local oStruCEP	:=	FWFormStruct( 2, "CEP" )
Local oStruCHS	:=	FWFormStruct( 2, "CHS" )
Local oStruCEQ	:=	FWFormStruct( 2, "CEQ" )
Local oStruCHT	:=	FWFormStruct( 2, "CHT" )
Local oStruCER	:=	FWFormStruct( 2, "CER" )
Local oStruCHU	:=	FWFormStruct( 2, "CHU" )
Local oStruCES	:=	FWFormStruct( 2, "CES" )
Local oStruCHV	:=	FWFormStruct( 2, "CHV" )
Local oStruCET	:=	FWFormStruct( 2, "CET" )
Local oStruCEU	:=	FWFormStruct( 2, "CEU" )
Local oStruCEV	:=	FWFormStruct( 2, "CEV" )
Local oView		:=	FWFormView():New()

/*--------------------------------------------------------------------------------------------
Esrutura da View
---------------------------------------------------------------------------------------------*/
oView:SetModel( oModel )
oView:SetContinuousForm( .T. )

oStruCEO:SetProperty( "CEO_REGECF"	, MVC_VIEW_ORDEM, "03" )
oStruCEO:SetProperty( "CEO_CODLAN"	, MVC_VIEW_ORDEM, "04" )
oStruCEO:SetProperty( "CEO_DCODLA"	, MVC_VIEW_ORDEM, "05" )
oStruCEO:SetProperty( "CEO_TPLANC"	, MVC_VIEW_ORDEM, "06" )
oStruCEO:SetProperty( "CEO_IDCODL"	, MVC_VIEW_ORDEM, "07" )
oStruCEO:SetProperty( "CEO_TIPORL"	, MVC_VIEW_ORDEM, "08" )
oStruCEO:SetProperty( "CEO_VLRLC"	, MVC_VIEW_ORDEM, "09" )
oStruCEO:SetProperty( "CEO_HISTLC"	, MVC_VIEW_ORDEM, "10" )

oStruCHR:SetProperty( "CHR_REGECF"	, MVC_VIEW_ORDEM, "03" )
oStruCHR:SetProperty( "CHR_CODLAN"	, MVC_VIEW_ORDEM, "04" )
oStruCHR:SetProperty( "CHR_DCODLA"	, MVC_VIEW_ORDEM, "05" )
oStruCHR:SetProperty( "CHR_TPLANC"	, MVC_VIEW_ORDEM, "06" )
oStruCHR:SetProperty( "CHR_IDCODL"	, MVC_VIEW_ORDEM, "07" )
oStruCHR:SetProperty( "CHR_TIPORL"	, MVC_VIEW_ORDEM, "08" )
oStruCHR:SetProperty( "CHR_VLRLC"	, MVC_VIEW_ORDEM, "09" )
oStruCHR:SetProperty( "CHR_HISTLC"	, MVC_VIEW_ORDEM, "10" )

oStruCHS:SetProperty( "CHS_CTA"	, MVC_VIEW_ORDEM, "01" )

oView:AddField("VIEW_CEN",oStruCEN,"MODEL_CEN")

oView:AddGrid("VIEW_CEO",oStruCEO,"MODEL_CEO")
oView:EnableTitleView("VIEW_CEO",STR0003) //"Lançamentos da Parte A do e-Lalur"

oView:AddGrid("VIEW_CHR",oStruCHR,"MODEL_CHR")
oView:EnableTitleView("VIEW_CHR",STR0011) //"Lançamentos da Parte A do e-Lacs"

oView:AddGrid("VIEW_CEP",oStruCEP,"MODEL_CEP")
oView:EnableTitleView("VIEW_CEP",STR0004) //"Conta da Parte B do e-Lalur"

oView:AddGrid("VIEW_CHS",oStruCHS,"MODEL_CHS")
oView:EnableTitleView("VIEW_CHS",STR0012) //"Conta da Parte B do e-Lacs"

oView:AddGrid("VIEW_CEQ",oStruCEQ,"MODEL_CEQ")
oView:EnableTitleView("VIEW_CEQ",STR0005) //"Contas Contábeis Relac. Lançam. Parte A do e-Lalur"

oView:AddGrid("VIEW_CHT",oStruCHT,"MODEL_CHT")
oView:EnableTitleView("VIEW_CHT",STR0013) //"Contas Contábeis Relac. Lançam. Parte A do e-Lacs"

oView:AddGrid("VIEW_CER",oStruCER,"MODEL_CER")
oView:EnableTitleView("VIEW_CER",STR0006) //"Números Lançam. Relac. Conta Contábil"

oView:AddGrid("VIEW_CHU",oStruCHU,"MODEL_CHU")
oView:EnableTitleView("VIEW_CHU",STR0006) //"Números Lançam. Relac. Conta Contábil"

oView:AddGrid("VIEW_CES",oStruCES,"MODEL_CES")
oView:EnableTitleView("VIEW_CES",STR0007) //"Processos Judic. Admin. Refer. Lançamento"

oView:AddGrid("VIEW_CHV",oStruCHV,"MODEL_CHV")
oView:EnableTitleView("VIEW_CHV",STR0007) //"Processos Judic. Admin. Refer. Lançamento"

oView:AddGrid("VIEW_CET",oStruCET,"MODEL_CET")
oView:EnableTitleView("VIEW_CET",STR0008) //"Lanç. Conta Parte B e-Lalur/e-Lacs sem Reflexo Parte A"

oView:AddGrid("VIEW_CEU",oStruCEU,"MODEL_CEU")
oView:EnableTitleView("VIEW_CEU",STR0009) //"Ident. Proc. Judiciais e Administrativos Refer. Lançamento"

oView:AddGrid("VIEW_CEV",oStruCEV,"MODEL_CEV")
oView:EnableTitleView("VIEW_CEV",STR0010) //"Contr. Saldos Contas da Parte B do e-Lalur/ e-Lacs"

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
// ----- PAINEL SUPERIOR -----
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",16)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") 

oView:AddSheet("FOLDER_PRINCIPAL","ABA01",STR0002) //"Identificação dos Períodos e Formas de Apuração do IRPJ e da CSLL das Empresas e-Lalur / e-Lacs"
oView:CreateHorizontalBox("PAINEL_CEN",100,,,"FOLDER_PRINCIPAL","ABA01") //CEN

// ----- PAINEL INFERIOR -----
oView:CreateHorizontalBox("PAINEL_INFERIOR",84)
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR")  

//ABACEO
oView:AddSheet("FOLDER_INFERIOR","ABACEO",STR0003) //"Lançamentos da Parte A do e-Lalur"
oView:CreateHorizontalBox("PAINEL_CEO",45,,,"FOLDER_INFERIOR","ABACEO") //CEO
oView:CreateHorizontalBox("PAINEL_INFERIOR_CEO",55,,,"FOLDER_INFERIOR","ABACEO")

oView:CreateFolder("FOLDER_CEO","PAINEL_INFERIOR_CEO")

oView:AddSheet("FOLDER_CEO","ABA_CEP",STR0004) //"Conta da Parte B do e-Lalur"
oView:CreateHorizontalBox("PAINEL_CEP",100,,,"FOLDER_CEO","ABA_CEP") //CEP

oView:AddSheet("FOLDER_CEO","ABA_CEQ",STR0005) //"Contas Contábeis Relac. Lançam. Parte A do e-Lalur"
oView:CreateHorizontalBox("PAINEL_CEQ",50,,,"FOLDER_CEO","ABA_CEQ") //CEQ
oView:CreateHorizontalBox("PAINEL_CER",50,,,"FOLDER_CEO","ABA_CEQ") //CER

oView:AddSheet("FOLDER_CEO","ABA_CES",STR0007) //"Processos Judic. Admin. Refer. Lançamento"
oView:CreateHorizontalBox("PAINEL_CES",100,,,"FOLDER_CEO","ABA_CES") //CES

//ABACHR
oView:AddSheet("FOLDER_INFERIOR","ABACHR",STR0011) //"Lançamentos da Parte A do E-Lacs"
oView:CreateHorizontalBox("PAINEL_CHR",45,,,"FOLDER_INFERIOR","ABACHR") //CHR
oView:CreateHorizontalBox("PAINEL_INFERIOR_CHR",55,,,"FOLDER_INFERIOR","ABACHR")

oView:CreateFolder("FOLDER_CHR","PAINEL_INFERIOR_CHR")

oView:AddSheet("FOLDER_CHR","ABA_CHS",STR0012) //"Conta da Parte B do e-Lacs"
oView:CreateHorizontalBox("PAINEL_CHS",100,,,"FOLDER_CHR","ABA_CHS") //CHS

oView:AddSheet("FOLDER_CHR","ABA_CHT",STR0013) //"Contas Contábeis Relac. Lançam. Parte A do e-Lacs"
oView:CreateHorizontalBox("PAINEL_CHT",50,,,"FOLDER_CHR","ABA_CHT") //CHT
oView:CreateHorizontalBox("PAINEL_CHU",50,,,"FOLDER_CHR","ABA_CHT") //CHU

oView:AddSheet("FOLDER_CHR","ABA_CHV",STR0007) //"Processos Judic. Admin. Refer. Lançamento"
oView:CreateHorizontalBox("PAINEL_CHV",100,,,"FOLDER_CHR","ABA_CHV") //CHV

// ABA 02
oView:AddSheet("FOLDER_INFERIOR","ABA02",STR0008) //"Lanç. Conta Parte B e-Lalur/e-Lacs sem Reflexo Parte A"
oView:CreateHorizontalBox("PAINEL_CET",60,,,"FOLDER_INFERIOR","ABA02") //CET
oView:CreateHorizontalBox("PAINEL_CEU",40,,,"FOLDER_INFERIOR","ABA02") //CEU

// ABA 03
oView:AddSheet("FOLDER_INFERIOR","ABA03",STR0010) //"Contr. Saldos Contas da Parte B do e-Lalur/ e-Lacs"
oView:CreateHorizontalBox("PAINEL_CEV",100,,,"FOLDER_INFERIOR","ABA03") //CEV

If TamSX3("CEQ_CTA")[1] == 36
	oStruCEQ:RemoveField( "CEQ_CTA")
	oStruCEQ:SetProperty( "CEQ_CTACTB", MVC_VIEW_ORDEM, "04" )
EndIf

If TamSX3("CHT_CTA")[1] == 36
	oStruCHT:RemoveField( "CHT_CTA" )
	oStruCHT:SetProperty( "CHT_CTACTB", MVC_VIEW_ORDEM, "04" )	
EndIf
/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CEN', 'PAINEL_CEN' )   
oView:SetOwnerView( 'VIEW_CEO', 'PAINEL_CEO' ) 
oView:SetOwnerView( 'VIEW_CHR', 'PAINEL_CHR' ) 
oView:SetOwnerView( 'VIEW_CEP', 'PAINEL_CEP' ) 
oView:SetOwnerView( 'VIEW_CHS', 'PAINEL_CHS' ) 
oView:SetOwnerView( 'VIEW_CEQ', 'PAINEL_CEQ' ) 
oView:SetOwnerView( 'VIEW_CHT', 'PAINEL_CHT' ) 
oView:SetOwnerView( 'VIEW_CER', 'PAINEL_CER' ) 
oView:SetOwnerView( 'VIEW_CHU', 'PAINEL_CHU' ) 
oView:SetOwnerView( 'VIEW_CES', 'PAINEL_CES' ) 
oView:SetOwnerView( 'VIEW_CHV', 'PAINEL_CHV' ) 
oView:SetOwnerView( 'VIEW_CET', 'PAINEL_CET' ) 
oView:SetOwnerView( 'VIEW_CEU', 'PAINEL_CEU' ) 
oView:SetOwnerView( 'VIEW_CEV', 'PAINEL_CEV' ) 

/*-----------------------------------------------------------------------------------
Esconde campos de controle interno
-------------------------------------------------------------------------------------*/
oStruCEN:RemoveField( "CEN_ID" )
oStruCEN:RemoveField( "CEN_IDPERA" )
oStruCEO:RemoveField( "CEO_IDCODL" )
oStruCEO:RemoveField( "CEO_REGECF" )
oStruCEP:RemoveField( "CEP_IDCTA" )
oStruCER:RemoveField( "CER_IDNUML" )
oStruCHR:RemoveField( "CHR_IDCODL" )
oStruCHR:RemoveField( "CHR_REGECF" )
oStruCHS:RemoveField( "CHS_IDCTA" )
oStruCHU:RemoveField( "CHU_IDNUML" )
oStruCET:RemoveField( "CET_IDCTA" )
oStruCET:RemoveField( "CET_IDCTAC" )
oStruCEV:RemoveField( "CEV_IDCTA" )

If TAFColumnPos( "CEO_ORIGEM" )
	oStruCEO:RemoveField( "CEO_ORIGEM" )
EndIf

If TAFColumnPos( "CHR_ORIGEM" )
	oStruCHR:RemoveField( "CHR_ORIGEM" )
EndIf

If TAFColumnPos( "CET_ORIGEM" )
	oStruCET:RemoveField( "CET_ORIGEM" )
EndIf

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Anderson Costa
@Since 24/06/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation	:=	oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE

		//Função responsável por setar o Status do registro para Branco
		TAFAltStat( "CEN", " " )

	EndIf

	If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE
		Processa( { || ClearModel( oModel ) }, STR0014 ) //"Gravando Informações"
	EndIf

	FwFormCommit( oModel )

End Transaction

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidModel

Validação dos dados, executado no momento da confirmação do modelo.

@Param		oModel	- Modelo de dados

@Return		lRet	- Indica se todas as condições foram respeitadas

@Author		Felipe C. Seolin
@Since		10/03/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidModel( oModel )

Local oModelCEO		as object
Local oModelCHR		as object
Local oModelCET		as object
Local nOperation	as numeric
Local nI			as numeric
Local aAreaCEO		as array
Local aAreaCHR		as array
Local aAreaCET		as array
Local lAuto			as logical
Local lManual		as logical
Local lRet			as logical

oModelCEO	:=	oModel:GetModel( "MODEL_CEO" )
oModelCHR	:=	oModel:GetModel( "MODEL_CHR" )
oModelCET	:=	oModel:GetModel( "MODEL_CET" )
nOperation	:=	oModel:GetOperation()
nI			:=	0
aAreaCEO	:=	CEO->( GetArea() )
aAreaCHR	:=	CHR->( GetArea() )
aAreaCET	:=	CET->( GetArea() )
lAuto		:=	.F.
lManual		:=	.F.
lRet		:=	.T.

If nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE

	For nI := 1 to oModelCEO:Length()
		oModelCEO:GoLine( nI )

		If AllTrim( oModelCEO:GetValue( "CEO_ORIGEM", nI ) ) == "M"
			lManual := .T.
		ElseIf AllTrim( oModelCEO:GetValue( "CEO_ORIGEM", nI ) ) == "A"
			lAuto := .T.
		EndIf

		If lManual .and. lAuto
			lRet := .F.
			Help( ,, "HELP",, STR0025, 1, 0 ) //"Não é permitido edição de um registro calculado pela apuração."
			Exit
		EndIf
	Next nI

	If lRet
		For nI := 1 to oModelCHR:Length()
			oModelCHR:GoLine( nI )

			If AllTrim( oModelCHR:GetValue( "CHR_ORIGEM", nI ) ) == "M"
				lManual := .T.
			ElseIf AllTrim( oModelCHR:GetValue( "CHR_ORIGEM", nI ) ) == "A"
				lAuto := .T.
			EndIf

			If lManual .and. lAuto
				lRet := .F.
				Help( ,, "HELP",, STR0025, 1, 0 ) //"Não é permitido edição de um registro calculado pela apuração."
				Exit
			EndIf
		Next nI
	EndIf

	If lRet
		For nI := 1 to oModelCET:Length()
			oModelCET:GoLine( nI )

			If AllTrim( oModelCET:GetValue( "CET_ORIGEM", nI ) ) == "M"
				lManual := .T.
			ElseIf AllTrim( oModelCET:GetValue( "CET_ORIGEM", nI ) ) == "A"
				lAuto := .T.
			EndIf

			If lManual .and. lAuto
				lRet := .F.
				Help( ,, "HELP",, STR0025, 1, 0 ) //"Não é permitido edição de um registro calculado pela apuração."
				Exit
			EndIf
		Next nI
	EndIf

	oModelCEO:GoLine( 1 )
	oModelCHR:GoLine( 1 )
	oModelCET:GoLine( 1 )
EndIf

RestArea( aAreaCEO )
RestArea( aAreaCHR )
RestArea( aAreaCET )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} ExitModel

Função de cancelamento da operação.

@Param		oModel	-	Modelo de dados

@Return		.T.

@Author		Felipe C. Seolin
@Since		27/08/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ExitModel( oModel )

cQualif	:=	""
cPerIni	:=	""
cPerFin	:=	""

FWFormCancel( oModel )

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} ClearModel

Remove do modelo as informações desnecessárias.

@Param		oModel	-	Modelo de dados

@Return		Nil

@Author		Felipe C. Seolin
@Since		24/08/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ClearModel( oModel )

Local oModelCEO	:=	oModel:GetModel( "MODEL_CEO" )
Local oModelCHR	:=	oModel:GetModel( "MODEL_CHR" )
Local nI		:=	0
Local aAreaCEO	:=	CEO->( GetArea() )
Local aAreaCHR	:=	CHR->( GetArea() )

ProcRegua( oModelCEO:Length() + oModelCHR:Length() )

For nI := 1 to oModelCEO:Length()

	oModelCEO:GoLine( nI )

	IncProc( STR0015 + AllTrim( oModelCEO:GetValue( "CEO_CODLAN", nI ) ) ) //"Gravando registro Lalur: "

	If Empty( oModelCEO:GetValue( "CEO_TIPORL", nI ) ) .and. Empty( oModelCEO:GetValue( "CEO_VLRLC", nI ) ) .and. Empty( oModelCEO:GetValue( "CEO_HISTLC", nI ) )
		oModelCEO:DeleteLine()
	Else
		oModelCEO:LoadValue( "CEO_REGECF", oModelCEO:GetValue( "CEO_REGECF", nI ) )
		oModelCEO:LoadValue( "CEO_IDCODL", oModelCEO:GetValue( "CEO_IDCODL", nI ) )
		oModelCEO:LoadValue( "CEO_ORIGEM", oModelCEO:GetValue( "CEO_ORIGEM", nI ) )
	EndIf

Next nI

For nI := 1 to oModelCHR:Length()

	oModelCHR:GoLine( nI )

	IncProc( STR0016 + AllTrim( oModelCHR:GetValue( "CHR_CODLAN", nI ) ) ) //"Gravando registro Lacs: "

	If Empty( oModelCHR:GetValue( "CHR_TIPORL", nI ) ) .and. Empty( oModelCHR:GetValue( "CHR_VLRLC", nI ) ) .and. Empty( oModelCHR:GetValue( "CHR_HISTLC", nI ) )
		oModelCHR:DeleteLine()
	Else
		oModelCHR:LoadValue( "CHR_REGECF", oModelCHR:GetValue( "CHR_REGECF", nI ) )
		oModelCHR:LoadValue( "CHR_IDCODL", oModelCHR:GetValue( "CHR_IDCODL", nI ) )
		oModelCHR:LoadValue( "CHR_ORIGEM", oModelCHR:GetValue( "CHR_ORIGEM", nI ) )
	EndIf

Next nI

oModelCEO:GoLine( 1 )
oModelCHR:GoLine( 1 )

RestArea( aAreaCEO )
RestArea( aAreaCHR )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidDate

Executa validação das datas de acordo com o Período de Escrituração.

@Param		oModel	-	Modelo de dados
			cCampo	-	Campo posicionado

@Return		lRet	-	Indica se o prenchimento do campo está correto

@Author		Felipe C. Seolin
@Since		24/08/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidDate( oModel, cCampo )

Local oModelCEN	:=	oModel:GetModel( "MODEL_CEN" )
Local lRet		:=	.T.

If !Empty( oModelCEN:GetValue( cCampo ) )
	If DToS( oModelCEN:GetValue( cCampo ) ) < cPerIni .or. DToS( oModelCEN:GetValue( cCampo ) ) > cPerFin
		lRet := .F.
	EndIf
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf322Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacos 
caso seja necessario gerar um XML

@Param		lJob - Informa se foi chamado por Job

@return		.T.

@Author		Anderson Costa
@Since		24/06/2014
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf322Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cStatus	:= ""
Local cChave	:= ""
Local lValida	:= .F.

Local cCEOKey	:= ""
Local cCEPKey	:= ""
Local cCEQKey	:= ""
Local cCERKey	:= ""
Local cCESKey	:= ""
Local cCETKey	:= ""
Local cCEUKey	:= ""
Local cCEVKey	:= ""

Local nVLRPTB	:= 0
Local nVLRCTA	:= 0
Local cTpLanc	:= ""
                 
Default lJob	:= .F. 

//Garanto que o Recno seja da tabela referente ao CEOastro principal
nRecno := CEN->( Recno() )

lValida := ( CEN->CEN_STATUS $ ( " |1" ) )

If lValida

	//VALIDA_PERIODO
	xVldECFReg( cAlias,"VALIDA_PERIODO", @aLogErro,{CEN->CEN_DTINI,CEN->CEN_DTFIN,CEN->CEN_IDPERA})
	
	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(CEN->CEN_DTINI)
		AADD(aLogErro,{"CEN_DTINI","000003","CEN",nRecno}) //STR0003 - "Data inconsistente ou vazia."
	EndIf
	
	If Empty(CEN->CEN_DTFIN)
		Aadd(aLogErro,{"CEN_DTFIN","000003","CEN",nRecno}) //STR0003 - "Data inconsistente ou vazia."
	EndIf

	If Empty(CEN->CEN_IDPERA)
		Aadd(aLogErro,{"CEN_IDPERA","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
	EndIf
	
	//------------------
	// Consultas padrão
	//------------------
	If !Empty(CEN->CEN_IDPERA)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CEN->CEN_IDPERA
		xVldECFTab("CAH",cChave,1,,@aLogErro,{ "CEN", "CEN_PERAPU", nRecno })
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO CEO³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	CEO->( DBSetOrder(1) )
	
	cCEOKey := CEN->CEN_ID
	If CEO->( MsSeek( xFilial("CEO") + cCEOKey ) )

		Do While !CEO->( Eof() ) .And. cCEOKey == CEO->CEO_ID
							
			nVLRCTA	:=	0
			nVLRPTB	:=	0
				
			//--------
			// Combos
			//--------	
			If Empty(CEO->CEO_REGECF)
				AADD(aLogErro,{"CEO_REGECF","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			Else
				If !CEO->CEO_REGECF $ ("1|2|3|")
					AADD(aLogErro,{"CEO_REGECF","000031", "CEN",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
				EndIf
			EndIf
			
			//------------------
			// Consultas padrão
			//------------------			
			If Empty(CEO->CEO_IDCODL)
				Aadd(aLogErro,{"CEO_","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			Else
			//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CEO->CEO_IDCODL
				xVldECFTab("CH8",cChave,1,,@aLogErro,{ "CEN","CEO_CODLAN", nRecno })
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO CEP³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			CEP->( DBSetOrder(1) )
			
			cCEPKey := CEO->(CEO_ID + CEO_IDCODL)
			If CEP->( MsSeek( xFilial("CEP") + cCEPKey ) )

				Do While !CEP->( Eof() ) .And. cCEPKey == CEP->(CEP_ID + CEP_IDCODL)
		
					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(CEP->CEP_VLRLC)
						AADD(aLogErro,{"CEP_VLRLC","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
					EndIf
					
					//------------------
					// Consultas padrão
					//------------------
					If !Empty(CEP->CEP_IDCTA)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := CEP->CEP_IDCTA
						xVldECFTab("CFR",cChave,1,,@aLogErro,{ "CEN", "CEP_IDCTA", nRecno })
					EndIf
					
					//------------
					// Combobox
					//------------
					If Empty(CEP->CEP_INDLC)
						AADD(aLogErro,{"CEP_INDLC","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
					Else
						If !CEP->CEP_INDLC $ ("1|2")
							AADD(aLogErro,{"CEP_INDLC","000002","CEN",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
						EndIf
					EndIf
					
					//Somatório do valor do Valor Total dos Lançamentos
					//Se situação do saldo final for devedor, subtrai. Senão, soma.
					If CEP->CEP_INDLC == '1'
						nVLRPTB :=	nVLRPTB - CEP->CEP_VLRLC
					Else
						nVLRPTB := nVLRPTB + CEP->CEP_VLRLC
					EndIf
														
					CEP->( DbSkip() )
					
				EndDo			

				If CEO->CEO_TIPORL $ ( "2|4" )
					aAdd( aLogErro, { "CEO_TIPORL", "000220", "CEN", nRecno } ) //STR0220 - "Não deve haver um registro de lançamento da Parte B quando Indicador de Relacionamento do Lançamento da Parte A for igual a '2' ou '4'."
				EndIf

			ElseIf CEO->CEO_TIPORL $ ( "1|3" )
				aAdd( aLogErro, { "CEO_TIPORL", "000053", "CEN", nRecno } ) //STR0053 - "Deve haver ao menos um registro de lançamento da Parte B quando Indicador de Relacionamento do Lançamento da Parte A for igual a '1' ou '3'."
			EndIf

			//ÚÄÄÄÄÄÄÄ¿
			//³FIM CEP³
			//ÀÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO CEQ³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			CEQ->( DBSetOrder(1) )
			
			cCEQKey := CEO->(CEO_ID + CEO_IDCODL)
			If CEQ->( MsSeek( xFilial("CEQ") + cCEQKey ) )
		
				Do While !CEQ->( Eof() ) .And. cCEQKey == CEQ->(CEQ_ID + CEQ_IDCODL)
		
					//------------------
					// Consultas padrão
					//------------------
					If !Empty(CEQ->CEQ_CTA)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := CEQ->CEQ_CTA
						xVldECFTab("C1O",cChave,3,,@aLogErro,{ "CEN", "CEQ_CTA", nRecno })
					EndIf

					If !Empty(CEQ->CEQ_CODCUS)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := CEQ->CEQ_CODCUS
						xVldECFTab("C1P",cChave,3,,@aLogErro,{ "CEN", "CEQ_CODCUS", nRecno })
					EndIf
					
					//Somatório do Valor da Conta	
					//Se situação do saldo final for devedor, subtrai. Senão, soma.
					If CEQ->CEQ_INDVLR == 'D'
						nVLRCTA:=	nVLRCTA - CEQ->CEQ_VLRLC
					Else
						nVLRCTA:=	nVLRCTA + CEQ->CEQ_VLRLC
					EndIf
									
					//ÚÄÄÄÄÄÄÄÄÄÄ¿
					//³INICIO CER³
					//ÀÄÄÄÄÄÄÄÄÄÄÙ
					CER->( DBSetOrder(1) )
			
					cCERKey := CEQ->(CEQ_ID + CEQ_IDCODL + CEQ_CTA + CEQ_CODCUS)
					If CER->( MsSeek( xFilial("CER") + cCERKey ) )
		
						Do While !CER->( Eof() ) .And. cCERKey == CER->(CER_ID + CER_IDCODL + CER_CTA + CER_CODCUS)
							//---------------------
							// Campos obrigatórios
							//---------------------
							If Empty(CER->CER_IDNUML)
								AADD(aLogErro,{"CER_IDNUML","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
							Else
								//Chave de busca na tabela FILHO ou Consulta padrao
								cChave := CER->CER_IDNUML
								xVldECFTab("CFS",cChave,1,,@aLogErro,{ "CEN","CER_NUMLCT", nRecno })
							EndIf
		
							CER->( DbSkip() )
						EndDo
					EndIf
					//ÚÄÄÄÄÄÄÄ¿
					//³FIM CER³
					//ÀÄÄÄÄÄÄÄÙ
					
					CEQ->( DbSkip() )
					
				EndDo

				If CEO->CEO_TIPORL $ ( "1|4" )
					aAdd( aLogErro, { "CEO_TIPORL", "000221", "CEN", nRecno } ) //STR0221 - "Não deve haver registro de conta contábil da Parte A quando Indicador de Relacionamento do Lançamento da Parte A for igual a '1' ou '4'."
				EndIf

			ElseIf CEO->CEO_TIPORL $ ( "2|3" )
				aAdd( aLogErro, { "CEO_TIPORL", "000054", "CEN", nRecno } ) //STR0054 - "Deve haver ao menos um registro de conta contábil da Parte A quando Indicador de Relacionamento do Lançamento da Parte A for igual a '2' ou '3'."
			EndIf

			//ÚÄÄÄÄÄÄÄ¿
			//³FIM CEQ³
			//ÀÄÄÄÄÄÄÄÙ


			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO CES³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			CES->( DBSetOrder(1) )
			
			cCESKey := CEO->(CEO_ID + CEO_IDCODL)
			If CES->( MsSeek( xFilial("CES") + cCESKey ) )
		
				Do While !CES->( Eof() ) .And. cCESKey == CES->(CES_ID + CES_IDCODL)
		
					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(CES->CES_IDPROC)
						AADD(aLogErro,{"CES_IDPROC","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
					EndIf

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(CES->CES_IDPROC)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := CES->CES_IDPROC
						xVldECFTab("C1G",cChave,3,,@aLogErro,{ "CEN", "CES_IDPROC", nRecno })
					EndIf
		
					CES->( DbSkip() )
				EndDo
			EndIf

			//ÚÄÄÄÄÄÄÄ¿
			//³FIM CES³
			//ÀÄÄÄÄÄÄÄÙ
			
			//REGRA_VALOR_DETALHADO 
			If CEO->CEO_TIPORL $ ("1")
			
				If CEO->CEO_VLRLC < nVLRPTB
					AADD(aLogErro,{"CEO_VLRLC","000148","CEN",nRecno}) //STR0148 - "Se o tipo de relacionamento for igual a "1" (com conta da parte B), o Valor deve ser menor que o Valor Total dos Lançamentos da Conta da Parte B."
				EndIf

			ElseIf CEO->CEO_TIPORL $ ("2")
					
				If CEO->CEO_VLRLC < nVLRCTA
					AADD(aLogErro,{"CEO_VLRLC","000149","CEN",nRecno}) //STR0149 - "Se o tipo de relacionamento for igual a "2" (com conta contábil), o Valor deve ser menor que o somatório do Valor da Conta."
				EndIf
				
			ElseIf CEO->CEO_TIPORL $ ("3")
					
				If (CEO->CEO_VLRLC < nVLRCTA) .or. (CEO->CEO_VLRLC < nVLRPTB)
					AADD(aLogErro,{"CEO_VLRLC","000150","CEN",nRecno}) //STR0150 - "Se o tipo de relacionamento for igual a "3" (com conta da parte B e conta contábil), o Valor deve ser menor que o Valor Total dos Lançamentos e menor que o somatório do Valor da Conta."
				EndIf
		
			EndIf
		
			//Busca o tipo na tabela de códigos de lançamento
			CH8->(DbSetOrder(1))
			If CH8->(DbSeek(xFilial("CH8")+CEO->CEO_IDCODL) )
				cTpLanc:=	CH8->CH8_TPLANC
			EndIF

			//REGRA_IND_RELACAO
			If cTpLanc == "P" .and. CEO->CEO_TIPORL <> "1"
				aAdd( aLogErro, { "CEO_TIPORL", "000151", "CEN", nRecno } ) //STR0151 - "Se o Tipo do Lançamento for igual a 'P'(compensação de prejuízo), o Tipo de Relacionamento deve ser igual a '1'(com conta da parte B)."
			EndIf
								
			//REGRA_NAO_PREENCHER_TIPO_DIFERENTE_E 
			If cTpLanc <> "E"
				If ! Empty(CEO->CEO_HISTLC)
					aAdd( aLogErro, { "CEO_HISTLC", "000228", "CEN", nRecno } ) //STR0228 - "O campo 'Hist Lcto' deve ser preenchido somente quando o Código do Lançamento do e-Lalur possuir o 'Tipo de Lançamento' igual a 'E'-Exclusão."
				EndIf
			EndIf

			CEO->( DbSkip() )
		EndDo
				
	EndIf
	
	//ÚÄÄÄÄÄÄÄ¿
	//³FIM CEO³
	//ÀÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO CHR³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	CHR->( DBSetOrder(1) )
	
	cCHRKey := CEN->CEN_ID
	If CHR->( MsSeek( xFilial("CHR") + cCHRKey ) )

		Do While !CHR->( Eof() ) .And. cCHRKey == CHR->CHR_ID
							
			nVLRCTA	:=	0
			nVLRPTB	:=	0
				
			//--------
			// Combos
			//--------		
			If Empty(CHR->CHR_REGECF)
				AADD(aLogErro,{"CHR_REGECF","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			Else
				If !CHR->CHR_REGECF $ ("4|5|6|")
					AADD(aLogErro,{"CHR_REGECF","000031", "CEN",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
				EndIf
			EndIf
			
			//------------------
			// Consultas padrão
			//------------------			
			If Empty(CHR->CHR_IDCODL)
				Aadd(aLogErro,{"CHR_","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			Else
			//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CHR->CHR_IDCODL
				xVldECFTab("CH8",cChave,1,,@aLogErro,{ "CEN","CHR_CODLAN", nRecno })
			EndIf
			
			//REGRA_NAO_PREENCHER_TIPO_DIFERENTE_E 
			If cTpLanc <> "E" .And. CHR->CHR_TIPORL <> "4" 
				If ! Empty(CHR->CHR_HISTLC)
					aAdd( aLogErro, { "CHR_HISTLC", "000233", "CEN", nRecno } ) //STR0235 - "O campo 'Hist Lcto' deve ser preenchido somente quando o Código do Lançamento do e-Lalur possuir o 'Tipo de Lançamento' igual a 'E'-Exclusão."
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO CHS³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			CHS->( DBSetOrder(1) )
			
			cCHSKey := CHR->(CHR_ID + CHR_IDCODL)
			If CHS->( MsSeek( xFilial("CHS") + cCHSKey ) )
			
				Do While !CHS->( Eof() ) .And. cCHSKey == CHS->(CHS_ID + CHS_IDCODL)
		
					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(CHS->CHS_VLRLC)
						AADD(aLogErro,{"CHS_VLRLC","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
					EndIf
					
					//------------------
					// Consultas padrão
					//------------------
					If !Empty(CHS->CHS_IDCTA)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := CHS->CHS_IDCTA
						xVldECFTab("CFR",cChave,1,,@aLogErro,{ "CEN", "CHS_IDCTA", nRecno })
					EndIf
					
					//------------
					// Combobox
					//------------
					If Empty(CHS->CHS_INDLC)
						AADD(aLogErro,{"CHS_INDLC","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
					Else
						If !CHS->CHS_INDLC $ ("1|2")
							AADD(aLogErro,{"CHS_INDLC","000002","CEN",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
						EndIf
					EndIf
					
					//Somatório do valor do Valor Total dos Lançamentos
					//Se situação do saldo final for devedor, subtrai. Senão, soma.
					If CHS->CHS_INDLC == '1'
						nVLRPTB := nVLRPTB - CHS->CHS_VLRLC
					Else
						nVLRPTB := nVLRPTB + CHS->CHS_VLRLC
					EndIf
					
					//REGRA_SALDO_DISPONIVEL_PARTE_B 			
					/*Regra de campo retirada pois possui interpretação duvidosa e o PVA não efetua verificação.
					CET->(DbSetOrder(1))
			
					cCtaKey:= CHS->(CHS_ID+CHS_IDCTA)      			
					If CET->( MsSeek( xFilial("CET") + cCtaKey) )		
					
						nSLDPTB := 0
						nVLRLC  := 0
						
						Do While ! CET->( Eof() ) .And.	 cCtaKey == CET->(CET_ID+CET_IDCTA)    
			
							//Somatório do Valor Total dos Lançamentos
							//Se o Indicador do Lançamento for igual a crédito, soma. Senão, subtrai.
							If CET->CET_IDLCTO == '1'
								nSLDPTB :=	nSLDPTB + CET->CET_VLRLC
							Else
								nSLDPTB := nSLDPTB - CET->CET_VLRLC
							EndIf
				
							CET->( DbSkip() )	
				
						EndDo							
					EndIf	
					
					//Verifica se o Vlr do Lançamento é Negativo (Prejuízo) ou Positivo(Lucro).
					If CHS->CHS_INDLC == '1'
						nVLRLC := CHS->CHS_VLRLC * -1
					Else
						nVLRLC := CHS->CHS_VLRLC
					EndIf
					
					//Verifica se o Vlr do Lançamento é menor ou igual ao saldo disponível da conta na parte B 
					If nVLRLC > nSLDPTB
						AADD(aLogErro,{"CHS_VLRLC","000232","CEN",nRecno }) //STR0232 - "O campo 'Vlr Tot Lcto' do registro M355 deve ser menor ou igual ao saldo disponível (Soma do campo 'Vl. Lançam.' referente a mesma Cta Lançam.) do mesmo período de apuração informada no registro M410."
					EndIf
					*/							
					CHS->( DbSkip() )
					
				EndDo			

				If CHR->CHR_TIPORL $ ( "2|4" )
					aAdd( aLogErro, { "CHR_TIPORL", "000220", "CEN", nRecno } ) //STR0220 - "Não deve haver um registro de lançamento da Parte B quando Indicador de Relacionamento do Lançamento da Parte A for igual a '2' ou '4'."
				EndIf

			ElseIf CHR->CHR_TIPORL $ ( "1|3" )
				aAdd( aLogErro, { "CHR_TIPORL", "000053", "CEN", nRecno } ) //STR0053 - "Deve haver ao menos um registro de lançamento da Parte B quando Indicador de Relacionamento do Lançamento da Parte A for igual a '1' ou '3'."
			EndIf

			//ÚÄÄÄÄÄÄÄ¿
			//³FIM CHS³
			//ÀÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO CHT³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			CHT->( DBSetOrder(1) )
			
			cCHTKey := CHR->(CHR_ID + CHR_IDCODL)
			If CHT->( MsSeek( xFilial("CHT") + cCHTKey ) )
		
				Do While !CHT->( Eof() ) .And. cCHTKey == CHT->(CHT_ID + CHT_IDCODL)
		
					//------------------
					// Consultas padrão
					//------------------
					If !Empty(CHT->CHT_CTA)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := CHT->CHT_CTA
						xVldECFTab("C1O",cChave,3,,@aLogErro,{ "CEN", "CHT_CTA", nRecno })
					EndIf

					If !Empty(CHT->CHT_CODCUS)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := CHT->CHT_CODCUS
						xVldECFTab("C1P",cChave,3,,@aLogErro,{ "CEN", "CHT_CODCUS", nRecno })
					EndIf
					
					//Somatório do Valor da Conta	
					//Se situação do saldo final for devedor, subtrai. Senão, soma.
					If CHT->CHT_INDVLR == 'D'
						nVLRCTA:=	nVLRCTA - CHT->CHT_VLRLC
					Else
						nVLRCTA:=	nVLRCTA + CHT->CHT_VLRLC
					EndIf
									
					//ÚÄÄÄÄÄÄÄÄÄÄ¿
					//³INICIO CHU³
					//ÀÄÄÄÄÄÄÄÄÄÄÙ
					CHU->( DBSetOrder(1) )
			
					cCHUKey := CHT->(CHT_ID+CHT_IDCODL+CHT_CTA+CHT_CODCUS )
					If CHU->( MsSeek( xFilial("CHU") + cCHUKey ) )
		
						Do While !CHU->( Eof() ) .And. cCHUKey == CHU->(CHU_ID+CHU_IDCODL+CHU_CTA+CHU_CODCUS)
							//---------------------
							// Campos obrigatórios
							//---------------------
							If Empty(CHU->CHU_IDNUML)
								AADD(aLogErro,{"CHU_IDNUML","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
							Else
								//Chave de busca na tabela FILHO ou Consulta padrao
								cChave := CHU->CHU_IDNUML
								xVldECFTab("CFS",cChave,1,,@aLogErro,{ "CEN","CHU_NUMLCT", nRecno })
							EndIf
		
							CHU->( DbSkip() )
						EndDo
					EndIf
					//ÚÄÄÄÄÄÄÄ¿
					//³FIM CHU³
					//ÀÄÄÄÄÄÄÄÙ
					
					CHT->( DbSkip() )
					
				EndDo

				If CHR->CHR_TIPORL $ ( "1|4" )
					aAdd( aLogErro, { "CHR_TIPORL", "000221", "CEN", nRecno } ) //STR0221 - "Não deve haver registro de conta contábil da Parte A quando Indicador de Relacionamento do Lançamento da Parte A for igual a '1' ou '4'."
				EndIf

			ElseIf CHR->CHR_TIPORL $ ( "2|3" )
				aAdd( aLogErro, { "CHR_TIPORL", "000054", "CEN", nRecno } ) //STR0054 - "Deve haver ao menos um registro de conta contábil da Parte A quando Indicador de Relacionamento do Lançamento da Parte A for igual a '2' ou '3'."
			EndIf

			//ÚÄÄÄÄÄÄÄ¿
			//³FIM CHT³
			//ÀÄÄÄÄÄÄÄÙ


			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO CHV³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			CHV->( DBSetOrder(1) )
			
			cCHVKey := CHR->(CHR_ID + CHR_IDCODL)
			If CHV->( MsSeek( xFilial("CHV") + cCHVKey ) )
		
				Do While !CHV->( Eof() ) .And. cCHVKey == CHV->(CHV_ID + CHV_IDCODL)
		
					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(CHV->CHV_IDPROC)
						AADD(aLogErro,{"CHV_IDPROC","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
					EndIf

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(CHV->CHV_IDPROC)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := CHV->CHV_IDPROC
						xVldECFTab("C1G",cChave,3,,@aLogErro,{ "CEN", "CHV_IDPROC", nRecno })
					EndIf
		
					CHV->( DbSkip() )
				EndDo
			EndIf

			//ÚÄÄÄÄÄÄÄ¿
			//³FIM CHV³
			//ÀÄÄÄÄÄÄÄÙ
			
			//REGRA_VALOR_DETALHADO 
			If CHR->CHR_TIPORL $ ("1")
			
				If CHR->CHR_VLRLC < nVLRPTB
					AADD(aLogErro,{"CHR_VLRLC","000148","CEN",nRecno}) //STR0148 - "Se o tipo de relacionamento for igual a "1" (com conta da parte B), o Valor deve ser menor que o Valor Total dos Lançamentos da Conta da Parte B."
				EndIf

			ElseIf CHR->CHR_TIPORL $ ("2")
					
				If CHR->CHR_VLRLC < nVLRCTA
					AADD(aLogErro,{"CHR_VLRLC","000149","CEN",nRecno}) //STR0149 - "Se o tipo de relacionamento for igual a "2" (com conta contábil), o Valor deve ser menor que o somatório do Valor da Conta."
				EndIf
				
			ElseIf CHR->CHR_TIPORL $ ("3")
					
				If (CHR->CHR_VLRLC < nVLRCTA) .or. (CHR->CHR_VLRLC < nVLRPTB)
					AADD(aLogErro,{"CHR_VLRLC","000150","CEN",nRecno}) //STR0150 - "Se o tipo de relacionamento for igual a "3" (com conta da parte B e conta contábil), o Valor deve ser menor que o Valor Total dos Lançamentos e menor que o somatório do Valor da Conta."
				EndIf
		
			EndIf
		
			//Busca o tipo na tabela de códigos de lançamento
			CH8->(DbSetOrder(1))
			If CH8->(DbSeek(xFilial("CH8")+CHR->CHR_IDCODL) )
				cTpLanc:=	CH8->CH8_TPLANC
			EndIF

			//REGRA_IND_RELACAO
			If cTpLanc == "P" .and. CHR->CHR_TIPORL <> "1"
				aAdd( aLogErro, { "CHR_TIPORL", "000151", "CEN", nRecno } ) //STR0151 - "Se o Tipo do Lançamento for igual a 'P'(compensação de prejuízo), o Tipo de Relacionamento deve ser igual a '1'(com conta da parte B)."
			EndIf

			CHR->( DbSkip() )
		EndDo
				
	EndIf
	
	//ÚÄÄÄÄÄÄÄ¿
	//³FIM CHR³
	//ÀÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO CET³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	CET->( DBSetOrder(1) )
	
	cCETKey := CEN->CEN_ID
	If CET->( MsSeek( xFilial("CET") + cCETKey ) )

		Do While !CET->( Eof() ) .And. cCETKey == CET->CET_ID

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(CET->CET_IDCTA)
				AADD(aLogErro,{"CET_IDCTA","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf

			If Empty(CET->CET_VLRLC)
				AADD(aLogErro,{"CET_VLRLC","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf
			
			If Empty(CET->CET_IDLCTO)
				AADD(aLogErro,{"CET_IDLCTO","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf
			
			If Empty(CET->CET_HISTLC)
				AADD(aLogErro,{"CET_HISTLC","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf
			
			If Empty(CET->CET_TRIDIF)
				AADD(aLogErro,{"CET_TRIDIF","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf
			
			//------------------
			// Consultas padrão
			//------------------
			If !Empty(CET->CET_IDCTA)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CET->CET_IDCTA
				xVldECFTab("CFR",cChave,1,,@aLogErro,{ "CEN", "CET_IDCTA", nRecno })
			EndIf

			If !Empty(CET->CET_IDCTAC)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CET->CET_IDCTAC
				xVldECFTab("CFR",cChave,1,,@aLogErro,{ "CEN", "CET_IDCTAC", nRecno })
			EndIf

			//--------
			// Combos
			//--------
			If !CET->CET_IDLCTO $ (" |1|2|3|4")
				AADD(aLogErro,{"CET_IDLCTO","000002", "CEN",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
			EndIf

			If !CET->CET_TRIDIF $ (" |1|2")
				AADD(aLogErro,{"CET_TRIDIF","000002", "CEN",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO CEU³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			CEU->( DBSetOrder(1) )
			
			cCEUKey := CET->(CET_ID + CET_IDCTA + CET_IDLCTO + CET_IDCTAC)
			If CEU->( MsSeek( xFilial("CEU") + cCEUKey ) )
		
				Do While !CEU->( Eof() ) .And. cCEUKey == CEU->(CEU_ID + CEU_CTA + CEU_IDLCTO + CEU_CTACP)
		
					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(CEU->CEU_IDPROC)
						AADD(aLogErro,{"CEU_IDPROC","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
					EndIf
					
					//------------------
					// Consultas padrão
					//------------------
					If !Empty(CEU->CEU_IDPROC)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := CEU->CEU_IDPROC
						xVldECFTab("C1G",cChave,3,,@aLogErro,{ "CEN", "CEU_IDPROC", nRecno })
					EndIf
		
					CEU->( DbSkip() )
				EndDo
			EndIf

			//ÚÄÄÄÄÄÄÄ¿
			//³FIM CEU³
			//ÀÄÄÄÄÄÄÄÙ

			CET->( DbSkip() )
		EndDo
	EndIf

	//ÚÄÄÄÄÄÄÄ¿
	//³FIM CET³
	//ÀÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO CEV³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	CEV->( DBSetOrder(1) )
	
	cCEVKey := CEN->CEN_ID
	If CEV->( MsSeek( xFilial("CEV") + cCEVKey ) )

		Do While !CEV->( Eof() ) .And. cCEVKey == CEV->CEV_ID

			//---------------------
			// Campos obrigatórios
		/*	//---------------------
			If Empty(CEV->CEV_VLRSLI)
				AADD(aLogErro,{"CEV_VLRSLI","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf*/

			If Empty(CEV->CEV_SITSLI)
				AADD(aLogErro,{"CEV_SITSLI","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf
		/*	
			If Empty(CEV->CEV_VLRPTA)
				AADD(aLogErro,{"CEV_VLRPTA","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf*/
			
			If Empty(CEV->CEV_STVLPA)
				AADD(aLogErro,{"CEV_STVLPA","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf
			
		/*	If Empty(CEV->CEV_VLRPTB)
				AADD(aLogErro,{"CEV_VLRPTB","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf*/
			
			If Empty(CEV->CEV_STVLPB)
				AADD(aLogErro,{"CEV_STVLPB","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf
			
/*			If Empty(CEV->CEV_VLRFIN)
				AADD(aLogErro,{"CEV_VLRFIN","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf*/
			
			If Empty(CEV->CEV_SITFIN)
				AADD(aLogErro,{"CEV_SITFIN","000001","CEN",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			EndIf
			
			//------------------
			// Consultas padrão
			//------------------
			If !Empty(CEV->CEV_IDCTA)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CEV->CEV_IDCTA
				xVldECFTab("CFR",cChave,1,,@aLogErro,{ "CEN", "CEV_IDCTA", nRecno })
			EndIf

			//--------
			// Combos
			//--------
			If !CEV->CEV_SITSLI $ (" |1|2")
				AADD(aLogErro,{"CEV_SITSLI","000002", "CEN",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
			EndIf

			If !CEV->CEV_STVLPA $ (" |1|2")
				AADD(aLogErro,{"CEV_STVLPA","000002", "CEN",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
			EndIf

			If !CEV->CEV_STVLPB $ (" |1|2")
				AADD(aLogErro,{"CEV_STVLPB","000002", "CEN",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
			EndIf

			If !CEV->CEV_SITFIN $ (" |1|2")
				AADD(aLogErro,{"CEV_SITFIN","000002", "CEN",nRecno }) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
			EndIf

			CEV->( DbSkip() )
		EndDo
	EndIf

	//ÚÄÄÄÄÄÄÄ¿
	//³FIM CEV³
	//ÀÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "CEN", cStatus )

Else
	AADD(aLogErro,{"CEN_ID","000017", "CEN", nRecno }) //STR0017 - "Registro já validado."
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidActivate

Executa validação para verificar se as informações necessárias
para o carregamento do modelo estão consistentes.

@Param		oModel	- Modelo de dados

@Return		lOk		- Indica se o modelo está apto a ser preenchido

@Author		Felipe C. Seolin
@Since		25/08/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function ValidActivate( oModel )

Local nOperation	:=	oModel:GetOperation()
Local aButtons		:=	{}
Local lOk			:=	.T.
Local lClose		:=	.T.
Local lCancel		:=	.F.
Local lAutomato		:= Iif(IsBlind(),.T.,.F.)

cQualif := Iif( Type( "cQualif" ) == "U", "", cQualif )

If Empty( cQualif ) .And. !lAutomato .and. FunName() != "TAFA444"

	If nOperation == MODEL_OPERATION_INSERT

		aAdd( aButtons, { 1, .T., { |x| lClose := .F., x:oWnd:End() } } )
		aAdd( aButtons, { 2, .T., { |x| lClose := .F., lCancel := .T., x:oWnd:End() } } )

		lOk := PergTAF( "TAFA322", STR0017, { STR0018 }, aButtons, { || .T. },,, .F. ) //##"Parâmetros..." ##"Período de Escrituração"

		If lCancel .or. lClose
			lOk := .F.
			Help( ,, "HELP",, STR0019, 1, 0 ) //"É necessário informar o Período de Escrituração para definição da Qualificação da Pessoa Jurídica. Sem esta informação, os códigos de lançamentos do Lalur e Lacs não serão gerados para o cadastro."
		EndIf

	EndIf

	If lOk
		GetQualif( nOperation )

		If Empty( cQualif )

			cQualif	:=	""
			cPerIni	:=	""
			cPerFin	:=	""

			lOk := .F.
			Help( ,, "HELP",, STR0020, 1, 0 ) //"Período de Escrituração informado não possui Qualificação da Pessoa Jurídica definida. Acesse o cadastro Movimentos ECF - Bloco 0 - Abertura - Parâmetros de Abertura ECF ( TAFA372 ) e informe o campo 'Qualif. PJ'. Em situações onde a Qualificação da Pessoa Jurídica não é informada, os códigos de lançamentos do Lalur e Lacs não serão gerados para o cadastro."
		EndIf
	EndIf
EndIf



Return( lOk )

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadModel

Rotina que organiza o carregamento de informações no Grid de Lalur e Lacs.

@Param		oModel		-	Modelo de dados
			cOperation	-	Indica o bloco de código em execução

@Return		xRet		-	Em caso de execução do bloco de código de Load
							do método AddGrid, retorna um array com as
							informações a serem carregadas no Grid

@Author		Felipe C. Seolin
@Since		21/08/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function LoadModel( oModel, cOperation )

Local cAliasQry		:=	""
Local nOperation	:=	oModel:GetOperation()
Local aAreaCEO		:=	CEO->( GetArea() )
Local aAreaCHR		:=	CHR->( GetArea() )
Local xRet			:=	Nil

If nOperation == MODEL_OPERATION_INSERT

	If cOperation == "SETACTIVATE"

		cAliasQry := GetQuery( "CEO", nOperation )
		Processa( { || LoadInfo( oModel:GetModel( "MODEL_CEO" ), nOperation, cAliasQry, "CEO" ) }, STR0021 ) //"Carregando Informações Lalur"
		( cAliasQry )->( DBCloseArea() )

		cAliasQry := GetQuery( "CHR", nOperation )
		Processa( { || LoadInfo( oModel:GetModel( "MODEL_CHR" ), nOperation, cAliasQry, "CHR" ) }, STR0022 ) //"Carregando Informações Lacs"
		( cAliasQry )->( DBCloseArea() )

	EndIf

Else

	If cOperation == "ADDGRIDCEO"

		cAliasQry := GetQuery( "CEO", nOperation )
		Processa( { || xRet := LoadInfo( oModel:GetModel( "MODEL_CEO" ), nOperation, cAliasQry, "CEO" ) }, STR0021 ) //"Carregando Informações Lalur"
		( cAliasQry )->( DBCloseArea() )

	ElseIf cOperation == "ADDGRIDCHR"

		cAliasQry := GetQuery( "CHR", nOperation )
		Processa( { || xRet := LoadInfo( oModel:GetModel( "MODEL_CHR" ), nOperation, cAliasQry, "CHR" ) }, STR0022 ) //"Carregando Informações Lacs"
		( cAliasQry )->( DBCloseArea() )

		//Tratamento para limpar a Qualificação da pessoa Jurídica
		//Visualização -> Não executa o bloco de código ao cancelar a operação
		//Excluir -> Comportamento de fechar a tela quando confirma a operação
		If nOperation == MODEL_OPERATION_VIEW .or. nOperation == MODEL_OPERATION_DELETE
			cQualif	:=	""
			cPerIni	:=	""
			cPerFin	:=	""
		EndIf

	EndIf

EndIf

RestArea( aAreaCEO )
RestArea( aAreaCHR )

Return( xRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQualif

Busca o Código da Qualificação da Pessoa Jurídica, de acordo com o
Período de Escrituração, para carregar os códigos de lançamentos
do Lalur e do Lacs.

@Param		nOperation	-	Indica a operação em execução

@Return		Nil

@Author		Felipe C. Seolin
@Since		17/08/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function GetQualif( nOperation )

Local aAreaCHD	:=	CHD->( GetArea() )
Local cPerAber	:= MV_PAR01

If nOperation == MODEL_OPERATION_INSERT

	CHD->( DBSetOrder( 1 ) )

	If Empty(MV_PAR01) .and. FunName() == "TAFA444"
		cPerAber := TAFSeekPer( DToS( CWV->CWV_INIPER ), DToS( CWV->CWV_FIMPER ) )
	EndIf	

	If CHD->( MsSeek( xFilial( "CHD" ) + PadR( cPerAber, TamSX3( "CHD_ID" )[1] ) ) )
		cQualif	:=	CHD->CHD_CODQUA
		cPerIni	:=	DToS( CHD->CHD_PERINI )
		cPerFin	:=	DToS( CHD->CHD_PERFIN )
	EndIf

Else

	If TAFSeekPer( DToS( CEN->CEN_DTINI ), DToS( CEN->CEN_DTFIN ) )
		cQualif	:=	CHD->CHD_CODQUA
		cPerIni	:=	DToS( CHD->CHD_PERINI )
		cPerFin	:=	DToS( CHD->CHD_PERFIN )
	EndIf

EndIf

RestArea( aAreaCHD )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GetQuery

Monta a consulta ao banco de dados a ser executado para buscar os códigos
de lançamento do Lalur e do Lacs para carregamento na interface.

@Param		cAlias		-	Alias da tabela para consulta ao banco de dados

@Return		cAliasQry	-	Query a ser executada

@Author		Felipe C. Seolin
@Since		21/08/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function GetQuery( cAlias, nOperation )

Local cSelect	:=	""
Local cFrom		:=	""
Local cWhere	:=	""
Local cOrderBy	:=	""
Local cCodReg	:=	""
Local cNickName	:=	RetSqlName( "CH8" )
Local cAliasQry	:=	GetNextAlias()

cQualif := Iif( Type( "cQualif" ) == "U", "", cQualif )

If FunName() $ "TAFTICKET"
	TAFSeekPer( DToS( CEN->CEN_DTINI ), DToS( CEN->CEN_DTFIN ) )
	GetQualif( nOperation )
EndIf

If cAlias == "CEO"

	If cQualif == "01"
		cCodReg := "M300A"
	ElseIf cQualif == "02"
		cCodReg := "M300B"
	ElseIf cQualif == "03"
		cCodReg := "M300C"
	EndIf

ElseIf cAlias == "CHR"

	If cQualif == "01"
		cCodReg := "M350A"
	ElseIf cQualif == "02"
		cCodReg := "M350B"
	ElseIf cQualif == "03"
		cCodReg := "M350C"
	EndIf

EndIf

cSelect := cNickName + ".CH8_ID "
cSelect += ", " + cNickName + ".CH8_CODIGO "
cSelect += ", " + cNickName + ".CH8_DESCRI "
cSelect += ", " + cNickName + ".CH8_TPLANC "

cFrom := cNickName + " " + cNickName

cWhere :=          cNickName + ".CH8_FILIAL = '" + xFilial( "CH8" ) + "' "
cWhere += "AND " + cNickName + ".CH8_CODREG = '" + cCodReg + "' "
cWhere += "AND (" + cNickName + ".CH8_DTFIN > '" + DToS( dDataBase ) + "' OR " + cNickName + ".CH8_DTFIN = '' ) "
cWhere += "AND " + cNickName + ".D_E_L_E_T_ = '' "

cOrderBy := cNickName + ".R_E_C_N_O_ "

cSelect	:=	"%" + cSelect  + "%"
cFrom		:=	"%" + cFrom    + "%"
cWhere		:=	"%" + cWhere   + "%"
cOrderBy	:=	"%" + cOrderBy + "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	ORDER BY
		%Exp:cOrderBy%

EndSql

Return( cAliasQry )

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadInfo

Carrega informações para Lalur ou Lacs de acordo com operação executada.

@Param		oModel		-	Modelo de dados
			nOperation	-	Indica a operação em execução
			cAliasQry	-	Alias da consulta ao banco de dados executada
			cAlias		-	Alias da tabela para manipulação dos dados

@Return		aLoad		-	Array com as informações do Lalur ou Lacs

@Author		Felipe C. Seolin
@Since		21/08/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function LoadInfo( oModel, nOperation, cAliasQry, cAlias )

Local cCH8Seq	:=	""
Local cRegECF	:=	""
Local cTipo		:=	""
Local cHist		:=	""
Local cOrigem	:=	""
Local nValor	:=	0
Local nI		:=	0
Local nTamCH8	:=	TamSX3( "CH8_CODIGO" )[1] + 3
Local nTam		:=	TamSX3( cAlias + "_TIPORL" )[1]
Local nCount	:=	0
Local nRecno	:=	0
Local nFILIAL	:=	oModel:GetIdField( cAlias + "_FILIAL" )
Local nREGECF	:=	oModel:GetIdField( cAlias + "_REGECF" )
Local nCODLAN	:=	oModel:GetIdField( cAlias + "_CODLAN" )
Local nDCODLA	:=	oModel:GetIdField( cAlias + "_DCODLA" )
Local nIDCODL	:=	oModel:GetIdField( cAlias + "_IDCODL" )
Local nTIPORL	:=	oModel:GetIdField( cAlias + "_TIPORL" )
Local nVLRLC	:=	oModel:GetIdField( cAlias + "_VLRLC" )
Local nHISTLC	:=	oModel:GetIdField( cAlias + "_HISTLC" )
Local nTPLANC	:=	oModel:GetIdField( cAlias + "_TPLANC" )
Local nORIGEM	:=	0
Local aValues	:=	{}
Local aLoad		:=	{}
Local aCH8		:=	{}
Local oStruct	:=	FWFormStruct( 1, cAlias )

cQualif := Iif( Type( "cQualif" ) == "U", "", cQualif )

If FunName() $ "TAFTICKET"
	TAFSeekPer( DToS( CEN->CEN_DTINI ), DToS( CEN->CEN_DTFIN ) )
	GetQualif( nOperation )
EndIf

If cAlias $ "CEO|CHR|" .and. TAFColumnPos( cAlias + "_ORIGEM" )
	nORIGEM := oModel:GetIdField( cAlias + "_ORIGEM" )
EndIf

( cAlias )->( DBSetOrder( 1 ) )

If cAlias == "CEO"

	If cQualif == "01"
		cRegECF := "1"
	ElseIf cQualif == "02"
		cRegECF := "2"
	ElseIf cQualif == "03"
		cRegECF := "3"
	EndIf

ElseIf cAlias == "CHR"

	If cQualif == "01"
		cRegECF := "4"
	ElseIf cQualif == "02"
		cRegECF := "5"
	ElseIf cQualif == "03"
		cRegECF := "6"
	EndIf

EndIf

While ( cAliasQry )->( !Eof() )

	cCH8Seq := AllTrim( ( cAliasQry )->CH8_CODIGO )

	If At( ".", cCH8Seq ) == 0
		cCH8Seq += ".00"
	Else
		
	EndIf

	cCH8Seq := StrZero( Val( cCH8Seq ), nTamCH8, 2 )

	aAdd( aCH8, { ( cAliasQry )->CH8_ID, ( cAliasQry )->CH8_CODIGO, ( cAliasQry )->CH8_DESCRI, ( cAliasQry )->CH8_TPLANC, cCH8Seq } )

	nCount += 1

	( cAliasQry )->( DBSkip() )
EndDo

ProcRegua( nCount )

If !Empty( aCH8 )

	aSort( aCH8,,, { |x,y| x[5] < y[5] } )

	If nOperation == MODEL_OPERATION_INSERT

		oModel:lInsertLine := .T.
			
		For nI := 1 to Len( aCH8 )

			If nI > 1
				oModel:AddLine()
			EndIf

			oModel:LoadValue( cAlias + "_FILIAL"	,	xFilial( cAlias ) )
			oModel:LoadValue( cAlias + "_REGECF"	,	cRegECF )
			oModel:LoadValue( cAlias + "_CODLAN"	,	aCH8[nI,2] )
			oModel:LoadValue( cAlias + "_DCODLA"	,	left( aCH8[nI,3], 80 ) )
			oModel:LoadValue( cAlias + "_IDCODL"	,	aCH8[nI,1] )
			oModel:LoadValue( cAlias + "_TIPORL"	,	"" )
			oModel:LoadValue( cAlias + "_VLRLC"		,	0 )
			oModel:LoadValue( cAlias + "_HISTLC"	,	"" )
			oModel:LoadValue( cAlias + "_TPLANC"	,	aCH8[nI,4] )

			If cAlias $ "CEO|CHR|" .and. TAFColumnPos( cAlias + "_ORIGEM" )
				oModel:LoadValue( cAlias + "_ORIGEM", "M" ) //Manual
			EndIf

			IncProc( STR0023 + AllTrim( aCH8[nI,2] ) ) //"Carregando registro: "

		Next nI

		oModel:lInsertLine := .F.

		oModel:GoLine( 1 )

	Else

		For nI := 1 to Len( aCH8 )

			If ( cAlias )->( MsSeek( xFilial( cAlias ) + CEN->CEN_ID + aCH8[nI,1] ) )

				nRecno	:=	( cAlias )->( Recno() )
				cTipo	:=	( cAlias )->&( cAlias + "_TIPORL" )
				nValor	:=	( cAlias )->&( cAlias + "_VLRLC" )
				cHist	:=	( cAlias )->&( cAlias + "_HISTLC" )

				If cAlias $ "CEO|CHR|" .and. TAFColumnPos( cAlias + "_ORIGEM" )
					cOrigem := ( cAlias )->&( cAlias + "_ORIGEM" )
				EndIf

			Else

				nRecno	:=	0
				cTipo	:=	Space( nTam )
				nValor	:=	0
				cHist	:=	""
				cOrigem	:=	"M" //Manual

			EndIf
			//Caso o cliente use controle de alterações e crie mais campos nas tabelas, gerava error log devido a diferença de quantidade dos campos do MVC com a base de dados.
			//Inserido a mesma função para obter a quantidade de campos assim não gerando mais o errorlog. Assim não determinando um valor fixo (10 ou 9).
			/*If cAlias $ "CEO|CHR|" .and. TAFColumnPos( cAlias + "_ORIGEM" )
				aValues := Array(10)
			Else
				aValues := Array(9)
			EndIf*/
			aValues := Array( Len( oStruct:aFields ) )

			aValues[nFILIAL]	:=	xFilial( cAlias )
			aValues[nREGECF]	:=	cRegECF
			aValues[nCODLAN]	:=	aCH8[nI,2]
			aValues[nDCODLA]	:=	aCH8[nI,3]
			aValues[nIDCODL]	:=	aCH8[nI,1]
			aValues[nTIPORL]	:=	cTipo
			aValues[nVLRLC]	    :=	nValor
			aValues[nHISTLC]	:=	cHist
			aValues[nTPLANC]	:=	aCH8[nI,4]

			If cAlias $ "CEO|CHR|" .and. TAFColumnPos( cAlias + "_ORIGEM" )
				aValues[nORIGEM]	:=	cOrigem
			EndIf

			aAdd( aLoad, { nRecno, aValues } )

			IncProc( STR0023 + AllTrim( aCH8[nI,2] ) ) //"Carregando registro: "

		Next nI

	EndIf

EndIf
oStruct := NIL
Return( aLoad )

//-------------------------------------------------------------------
/*/{Protheus.doc} VldHistCEO
Função utilizada para validar o preenchimento manual do campo CEO_HISTLC

@Param		oModel - Objeto de modelo do FormGrid(FWFormGridModel) 
 
@Return		cRet - Retorna .T. se o CEO_TPLANC for Exclusão

@Author		Henrique Pereira 
@Since		03/11/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
/*
Function VldHistCEO(oModel, nLinha)
Local lRet := .T.

   If oModel:GetValue("CEO_TPLANC") <> "E" .And. !Empty(oModel:GetValue("CEO_HISTLC"))
         lRet := .F.
         Help( ,,"TAFVLDHISTLC",,STR0024, 5, 0 )       
         
   EndIf

Return lRet
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} FVlLcLalur
Função utilizada para realizar a soma do campo referente ao total do
valor de lançamento do Lançamento da Parte A do e-Lalur

@Param		cField  - Campo referente a chamada da função
			cAction - Operação que esta sendo realizada na chamada da função
			xValNew - Valor novo incluído pelo usuário em tempo de execução na tela
			cAlsOri - Nome do Alias de onde originou-se a chamada do Valid
 
@Return		.T. 

@Author		Rodrigo Aguilar 
@Since		19/04/2016
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function FVlLcLalur( cField, cAction, xValNew, cAlsOri )

local cTipoRl     := ''
local nTotVlrLcto := 0

local aChgWhen1   := {}
local aChgWhen2   := {}

local oModel      := FWModelActive()  //Recuperando o model ativo da interface
local oView       := FWViewActive()	//Recuperando a view ativa da interface	

local lExecVld    := .F.

local oModelCEO   := oModel:GetModel( 'MODEL_CEO' )
local oModelCEP   := oModel:GetModel( 'MODEL_CEP' )
local oModelCEQ   := oModel:GetModel( 'MODEL_CEQ' )

local lAutomato	:= Iif(IsBlind(),.T.,.F.)

default cField    := ''
default cAction   := ''
default xValNew   := '' 

//Validação para que quando seja chamado o SAVEMODEL não sejam aplicadas as regras de validação desenvolvidas abaixo
lExecVld := ( procname(5) <> "CLEARMODEL" )

//Como a chamada da função é executada para todos os campos do modelo eu verifico se a origem veio de um
//dos campos que tem que realizar o cálculo do valor total de lançamento 	
if lExecVld .and. cAction <> 'CANSETVALUE' .and. ( cField + '|' $ 'CEO_TIPORL|CEP_INDLC|CEP_VLRLC|CEQ_CTA|CEQ_VLRLC|CEQ_INDVLR|' .or. cAction == 'DELETE' .or. cAction == 'UNDELETE' )

	//Quando a chamada for por alteração no campo tipo de lançamento atualizamos com o valor inputado pelo usuário,
	//caso contrário temos que apurar AUTOMATICAMENTE o valor do campo CEO_TIPORL
	if cField <> 'CEO_TIPORL'
		cTipoRl := FExsLalur( oModelCEP, oModelCEQ, cAlsOri, cAction )
	else
		cTipoRl := xValNew
	endif		
		
	//Se Tipo Lancamento = “A” (Adição) ou “L” (Lucro)
	if FWFldGet( 'CEO_TPLANC' ) == 'A' .or. FWFldGet('CEO_TPLANC' ) == 'L'
		
		if cTipoRl == '1' .or. cTipoRl == '3'
			//Atualizando o total de lançamentos com os valores do registro M305
			FAtuVlM305( oModelCEP, @nTotVlrLcto, 'AL', cAction, cAlsOri )
			  
		endif
		
		if cTipoRl == '2' .or. cTipoRl == '3'
			//Atualizando o total de lançamentos com os valores do registro M310					
			FAtuVlM310( oModelCEQ, @nTotVlrLcto, 'AL', cAction, cField, xValNew, cAlsOri )
			
		endif
		
	//Se Tipo Lancamento  = “E” (Exclusão) ou “P” (Prejuízo) 	
	elseif FWFldGet( 'CEO_TPLANC' ) == 'E' .or. FWFldGet('CEO_TPLANC' ) == 'P'
	
		if cTipoRl == '1' .or. cTipoRl == '3'
			//Atualizando o total de lançamentos com os valores do registro M305
			FAtuVlM305( oModelCEP, @nTotVlrLcto, 'EP', cAction, cAlsOri )
			
		endif
					 
		if cTipoRl == '2' .or. cTipoRl == '3'
			//Atualizando o total de lançamentos com os valores do registro M310
			FAtuVlM310( oModelCEQ, @nTotVlrLcto, 'EP', cAction, cField, xValNew, cAlsOri )
			
		endif
	endif											

	//Preciso alterar manualmente a propriedade de When do campo CEO_VLRLC para que consiga gravar
	//o novo valor		
	aChgWhen1 := FRmvWhen( @oModelCEO, "CEO_VLRLC" )
				
	//Atualizo o valor total do lançamento
	oModelCEO:SetValue( 'CEO_VLRLC' , nTotVlrLcto )
	
	//Volto a propriedade de When do campo barrando a inclusão manual do lançamento contábil
	oModelCEO:oFormModelStruct:aFields[aChgWhen1[2],MODEL_FIELD_WHEN] := aChgWhen1[1]
	
	if cField <> 'CEO_TIPORL'
		
		//Preciso alterar manualmente a propriedade de When do campo CEO_TIPORL para que consiga gravar
		//o novo valor				
		aChgWhen2 := FRmvWhen( @oModelCEO, "CEO_TIPORL" )
		
		//Atualizo o tipo de relacionamento 
		oModelCEO:SetValue( 'CEO_TIPORL', cTipoRl )
		
		//Volto a propriedade de When do campo barrando a inclusão manual do lançamento contábil
		oModelCEO:oFormModelStruct:aFields[aChgWhen2[2],MODEL_FIELD_WHEN] := aChgWhen2[1]
	endif
			
	//Atualizo a Browse para que o campo tenha seu valor atualizado
	If !lAutomato
		oview:Refresh( 'VIEW_CEO' )
	EndIf

endif
			
Return AllwaysTrue()

//-------------------------------------------------------------------
/*/{Protheus.doc} FVlLcLacs
Função utilizada para realizar a soma do campo referente ao total do
valor de lançamento do Lançamento da Parte A do e-Lacs

@Param		cField  - Campo referente a chamada da função
			cAction - Operação que esta sendo realizada na chamada da função
			xValNew - Valor novo incluído pelo usuário em tempo de execução na tela
			cAlsOri - Nome do Alias de onde originou-se a chamada do Valid
 
@Return		.T. 

@Author		Rodrigo Aguilar 
@Since		19/04/2016
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function FVlLcLacs( cField, cAction, xValNew, cAlsOri )

local cTipoRl     := ''

local nTotVlrLcto := 0

local aChgWhen1   := {}
local aChgWhen2   := {}

local oModel      := FWModelActive()  //Recuperando o model ativo da interface
local oView       := FWViewActive()	//Recuperando a view ativa da interface	

local lExecVld    := .F.

local oModelCHR   := oModel:GetModel( 'MODEL_CHR' )
local oModelCHS   := oModel:GetModel( 'MODEL_CHS' )
local oModelCHT   := oModel:GetModel( 'MODEL_CHT' )

local lAutomato	:= Iif(IsBlind(),.T.,.F.)

default cField    := ''
default cAction   := ''
default xValNew   := '' 

//Validação para que quando seja chamado o SAVEMODEL não sejam aplicadas as regras de validação desenvolvidas abaixo
lExecVld := ( procname(5) <> "CLEARMODEL" )

//Como a chamada da função é executada para todos os campos do modelo eu verifico se a origem veio de um
//dos campos que tem que realizar o cálculo do valor total de lançamento 	
if lExecVld .and. cAction <> 'CANSETVALUE' .and. ( cField + '|' $ 'CHR_TIPORL|CHS_INDLC|CHS_VLRLC|CHT_CTA|CHT_VLRLC|CHT_INDVLR|' .or. cAction == 'DELETE' .or. cAction == 'UNDELETE' )

	//Quando a chamada for por alteração no campo tipo de lançamento atualizamos com o valor inputado pelo usuário,
	//caso contrário temos que apurar AUTOMATICAMENTE o valor do campo CEO_TIPORL
	if cField <> 'CHR_TIPORL'
		cTipoRl := FExsLacs( oModelCHS, oModelCHT, cAlsOri, cAction )
	else
		cTipoRl := xValNew
	endif
			
	//Se Tipo Lancamento = “A” (Adição) ou “L” (Lucro)
	if FWFldGet( 'CHR_TPLANC' ) == 'A' .or. FWFldGet('CHR_TPLANC' ) == 'L'
		
		if cTipoRl == '1' .or. cTipoRl == '3'
			//Atualizando o total de lançamentos com os valores do registro M305
			FAtuVlM355( oModelCHS, @nTotVlrLcto, 'AL', cAction, cAlsOri )
			  
		endif
		
		if cTipoRl == '2' .or. cTipoRl == '3'
			//Atualizando o total de lançamentos com os valores do registro M310					
			FAtuVlM360( oModelCHT, @nTotVlrLcto, 'AL', cAction, cField, xValNew, cAlsOri )
			
		endif
		
	//Se Tipo Lancamento  = “E” (Exclusão) ou “P” (Prejuízo) 	
	elseif FWFldGet( 'CHR_TPLANC' ) == 'E' .or. FWFldGet('CHR_TPLANC' ) == 'P'
	
		if cTipoRl == '1' .or. cTipoRl == '3'
			//Atualizando o total de lançamentos com os valores do registro M305
			FAtuVlM355( oModelCHS, @nTotVlrLcto, 'EP', cAction, cAlsOri )
			  
		endif
		
		if cTipoRl == '2' .or. cTipoRl == '3'
			//Atualizando o total de lançamentos com os valores do registro M310
			FAtuVlM360( oModelCHT, @nTotVlrLcto, 'EP', cAction, cField, xValNew, cAlsOri )
			
		endif
		
	endif									

	//Preciso alterar manualmente a propriedade de When do campo CHR_VLRLC para que consiga gravar
	//o novo valor		
	aChgWhen1 := FRmvWhen( @oModelCHR, "CHR_VLRLC" )
			
	//Atualizo o valor total do lançamento
	oModelCHR:SetValue( 'CHR_VLRLC' , nTotVlrLcto )
	
	//Volto a propriedade de When do campo barrando a inclusão manual do lançamento contábil
	oModelCHR:oFormModelStruct:aFields[aChgWhen1[2],MODEL_FIELD_WHEN] := aChgWhen1[1]
	
	//Atualizo a Browse para que o campo tenha seu valor atualizado
	If !lAutomato
		oview:Refresh( 'VIEW_CHR' )
	EndIf
	
	if cField <> 'CHR_TIPORL'
		
		//Preciso alterar manualmente a propriedade de When do campo CEO_TIPORL para que consiga gravar
		//o novo valor				
		aChgWhen2 := FRmvWhen( @oModelCHR, "CHR_TIPORL" )
		
		//Atualizo o tipo de relacionamento 
		oModelCHR:SetValue( 'CHR_TIPORL', cTipoRl )
		
		//Volto a propriedade de When do campo barrando a inclusão manual do lançamento contábil
		oModelCHR:oFormModelStruct:aFields[aChgWhen2[2],MODEL_FIELD_WHEN] := aChgWhen2[1]
	endif
			
	//Atualizo a Browse para que o campo tenha seu valor atualizado
	If !lAutomato
		oview:Refresh( 'VIEW_CEO' )	
	EndIf

endif
			
Return AllwaysTrue()

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuVlM305

Realiza a totalização do registro M305 de acordo com as regras previstas
no layout da ECF

@Param		oModelCEP   - Model da tabela CEP
			nTotVlrLcto - Variável que será populada com o valor total do registro M310
			cTipoLanc   - Tipo do Lançamento definido pelo usuário em tela
			cAction     - Ação que originou a execução do Valid
			cAlsOri     - Nome do Alias de onde originou-se a chamada do Valid

@Author		Rodrigo Aguilar
@Since		27/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FAtuVlM305( oModelCEP, nTotVlrLcto, cTipoLanc, cAction, cAlsOri )

local cIndLanc	:=	''

local nI		:=	0
local nvlrLanc	:=	0

local nLineCEP	:=	oModelCEP:GetLine()

for nI := 1 to oModelCEP:Length()			
	
	//Quando se tratar de uma linha que está sendo deletada não devo considerar o valor no processamento, porém como a função é utilizada para mais de um model preciso
	//identificar dequal tabela(alias) o DELETE se originou, devido a isso a utilização do cAlsOri
	if nI == nLineCEP .and. cAlsOri == 'CEP' .and. cAction == 'DELETE' 
		Loop
	endif
		 
	//Posiciono na linha que vou verificar
	oModelCEP:GoLine( nI )

	//Verifico se a linha não está deletada ou se é a linha que esta sendo deletada pelo usuário, pois nesse caso 
	//o valor deve ser considerado no cálculo do valor total
	if !oModelCEP:IsDeleted() .Or. 	( cAction == 'UNDELETE' .and. cAlsOri == 'CEP' .and. nI == nLineCEP )	
			
		//Tratamento pois o valor que está sendo inserido não existe no retorno da função FWFldGet, o segundo parâmetro
		//que indica a linha não está retornando o valor correto conforme exemplo do TDN
		if nI <> nLineCEP
			cIndLanc := oModelCEP:GetValue( 'CEP_INDLC' )
			nvlrLanc := oModelCEP:GetValue( 'CEP_VLRLC' )
		else
			cIndLanc := FWFldGet( 'CEP_INDLC' )
			nvlrLanc := FWFldGet( 'CEP_VLRLC' )
		endif
							
		//Se o indicador de valor da conta for igual a Débito somo o valor
		if cIndLanc == '1'
						
			//Adição ou Lucro
			if cTipoLanc == 'AL'
				nTotVlrLcto += nvlrLanc
			
			//Exclusão ou Prejuizo
			else
				nTotVlrLcto -= nvlrLanc
				
			endif 
		
		//Se o indicador de valor da conta for igual a Crédito subtrai o valor 
		elseif cIndLanc == '2'

			//Adição ou Lucro
			if cTipoLanc == 'AL'		
				nTotVlrLcto -= nvlrLanc
				
			//Exclusão ou Prejuizo
			else
				nTotVlrLcto += nvlrLanc
			endif				 
			
		endif	
	endif
	
next

//Restauro a linha de origem da Grid
oModelCEP:GoLine( nLineCEP )
			
Return (nil)

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuVlM310

Realiza a totalização do registro M310 de acordo com as regras previstas
no layout da ECF

@Param		oModelCEQ   - Model da tabela CEQ
			nTotVlrLcto - Variável que será populada com o valor total do registro M310
			cTipoLanc   - Tipo do Lançamento definido pelo usuário em tela
			cAction     - Ação que originou a execução do Valid
			cField      - Nome do campo que chamou o valid
			xValNew     - Valor novo incluído pelo usuário em tempo de execução na tela
			cAlsOri     - Nome do Alias de onde originou-se a chamada do Valid

@Author		Rodrigo Aguilar
@Since		27/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FAtuVlM310( oModelCEQ, nTotVlrLcto, cTipoLanc, cAction, cField, xValNew, cAlsOri )

local cContaC	:=	''
local cIndVlr	:=	''

local nvlrLanc	:=	0
local nI		:=	0

local nLineCEQ	:=	oModelCEQ:GetLine()
 
//Setando alias e indices que precisarei usar no meu processamento
dbSelectArea( 'C1O' )
C1O->( dbsetOrder(3))

dbSelectArea( 'C2R' )
C2R->( dbsetOrder(3))

for nI := 1 to oModelCEQ:Length()

	//Quando se tratar de uma linha que está sendo deletada não devo considerar o valor no processamento, porém como a função é utilizada para mais de um model preciso
	//identificar dequal tabela(alias) o DELETE se originou, devido a isso a utilização do cAlsOri
	if nI == nLineCEQ .and. cAlsOri == 'CEQ' .and. cAction == 'DELETE' 
		Loop
	endif
	
	//Posiciono na linha que vou verificar
	oModelCEQ:GoLine( nI )

	//Verifico se a linha não está deletada ou se é a linha que esta sendo deletada pelo usuário, pois nesse caso 
	//o valor deve ser considerado no cálculo do valor total
	if !oModelCEQ:IsDeleted() .Or. 	( cAction == 'UNDELETE' .and. cAlsOri == 'CEQ' .and. nI == nLineCEQ )

		//No caso da conta contábil, por possuir gatilho não tenho no momento da validação o novo valor do campo
		//sendo assim pego pelo valor passado por parâmetro default quando o valid for do próprio campo
		if cField == 'CEQ_CTA' .and. valtype(xValNew) <> 'U'  
			cContaC  := xValNew
		else
			cContaC  := oModelCEQ:GetValue( 'CEQ_CTA' )
		endif
		
		//Tratamento pois o valor que está sendo inserido não existe no retorno da função FWFldGet, o segundo parâmetro
		//que indica a linha não está retornando o valor correto conforme exemplo do TDN
		if nI <> nLineCEQ
			cIndVlr  := oModelCEQ:GetValue( 'CEQ_INDVLR' )
			nvlrLanc := oModelCEQ:GetValue( 'CEQ_VLRLC' )
		else
			cIndVlr  := FWFldGet( 'CEQ_INDVLR' )
			nvlrLanc := FWFldGet( 'CEQ_VLRLC' )
		endif
			
		//Posiciono na conta contábil utilizada no M310 
		if C1O->( msSeek( xfilial( 'C1O' ) + cContaC ) )
							
			//Posiciono na natureza da conta
			if C2R->( msSeek( xfilial( 'C2R' ) + C1O->C1O_CODNAT ) )
				
				//Verifico se a conta possui uma natureza que deve ser considerado na totalização do lançamento
				if C2R->C2R_CODIGO $ ( "01|02|03|04" )
					
					//Se a natureza for de Conta de Resultado
					if C2R->C2R_CODIGO == '04'
						
						//Se o indicador for igual a Débito soma o valor
						if cIndVlr == 'D'
						
							//Adição ou Lucro
							if cTipoLanc == 'AL'								
								nTotVlrLcto += nvlrLanc

							//Exclusão ou Prejuizo
							else
								nTotVlrLcto -= nvlrLanc
								
							endif
							
						elseif cIndVlr == 'C'
						
							//Adição ou Lucro
							if cTipoLanc == 'AL'
								nTotVlrLcto -= nvlrLanc
							
							//Exclusão ou Prejuizo
							else
								nTotVlrLcto += nvlrLanc
								
							endif
							
						endif
											
					//Quando a natureza for 01|02|03
					else
						
						//Se o indicador for igual a Débito soma o valor
						if cIndVlr == 'D'
							
							//Adição ou Lucro
							if cTipoLanc == 'AL'						
								nTotVlrLcto -= nvlrLanc
							
							//Exclusão ou Prejuizo
							else
								nTotVlrLcto += nvlrLanc
								
							endif
						
						elseif cIndVlr == 'C'
						
							//Adição ou Lucro
							if cTipoLanc == 'AL'								
								nTotVlrLcto += nvlrLanc
							
							else
								nTotVlrLcto -= nvlrLanc
								
							endif							
						endif															
					endif					
				endif									
			endif				
		endif		 				
	endif			
next
			
//Restauro a linha de origem da Grid
oModelCEQ:GoLine( nLineCEQ )

Return ( nil ) 

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuVlM355

Realiza a totalização do registro M355 de acordo com as regras previstas
no layout da ECF

@Param		oModelCHS   - Model da tabela CHS
			nTotVlrLcto - Variável que será populada com o valor total do registro M310
			cTipoLanc   - Tipo do Lançamento definido pelo usuário em tela
			cAction     - Ação que originou a execução do Valid
			cAlsOri     - Nome do Alias de onde originou-se a chamada do Valid

@Author		Rodrigo Aguilar
@Since		27/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FAtuVlM355( oModelCHS, nTotVlrLcto, cTipoLanc, cAction, cAlsOri )

local cIndLanc	:=	''

local nI		:=	0
local nvlrLanc	:=	0

local nLineCHS	:=	oModelCHS:GetLine()

for nI := 1 to oModelCHS:Length()			
	
	//Quando se tratar de uma linha que está sendo deletada não devo considerar o valor no processamento, porém como a função é utilizada para mais de um model preciso
	//identificar dequal tabela(alias) o DELETE se originou, devido a isso a utilização do cAlsOri
	if nI == nLineCHS .and. cAlsOri == 'CHS' .and. cAction == 'DELETE' 
		Loop
	endif
		 
	//Posiciono na linha que vou verificar
	oModelCHS:GoLine( nI )

	//Verifico se a linha não está deletada ou se é a linha que esta sendo deletada pelo usuário, pois nesse caso 
	//o valor deve ser considerado no cálculo do valor total
	if !oModelCHS:IsDeleted() .Or. 	( cAction == 'UNDELETE' .and. cAlsOri == 'CHS' .and. nI == nLineCHS )	
			
		//Tratamento pois o valor que está sendo inserido não existe no retorno da função FWFldGet, o segundo parâmetro
		//que indica a linha não está retornando o valor correto conforme exemplo do TDN
		if nI <> nLineCHS
			cIndLanc := oModelCHS:GetValue( 'CHS_INDLC' )
			nvlrLanc := oModelCHS:GetValue( 'CHS_VLRLC' )
		else
			cIndLanc := FWFldGet( 'CHS_INDLC' )
			nvlrLanc := FWFldGet( 'CHS_VLRLC' )
		endif
							
		//Se o indicador de valor da conta for igual a Débito somo o valor
		if cIndLanc == '1'
						
			//Adição ou Lucro
			if cTipoLanc == 'AL'
				nTotVlrLcto += nvlrLanc
			
			//Exclusão ou Prejuizo
			else
				nTotVlrLcto -= nvlrLanc
				
			endif 
		
		//Se o indicador de valor da conta for igual a Crédito subtrai o valor 
		elseif cIndLanc == '2'

			//Adição ou Lucro
			if cTipoLanc == 'AL'		
				nTotVlrLcto -= nvlrLanc
				
			//Exclusão ou Prejuizo
			else
				nTotVlrLcto += nvlrLanc
			endif				 
			
		endif	
	endif
	
next

//Restauro a linha de origem da Grid
oModelCHS:GoLine( nLineCHS )
			
Return (nil)

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuVlM360

Realiza a totalização do registro M360 de acordo com as regras previstas
no layout da ECF

@Param		oModelCHT   - Model da tabela CHT
			nTotVlrLcto - Variável que será populada com o valor total do registro M310
			cTipoLanc   - Tipo do Lançamento definido pelo usuário em tela
			cAction     - Ação que originou a execução do Valid
			cField      - Nome do campo que chamou o valid
			xValNew     - Valor novo incluído pelo usuário em tempo de execução na tela
			cAlsOri     - Nome do Alias de onde originou-se a chamada do Valid

@Author		Rodrigo Aguilar
@Since		27/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FAtuVlM360( oModelCHT, nTotVlrLcto, cTipoLanc, cAction, cField, xValNew, cAlsOri )

local cContaC	:=	''
local cIndVlr	:=	''

local nvlrLanc	:=	0
local nI		:=	0

local nLineCHT	:=	oModelCHT:GetLine()
 
//Setando alias e indices que precisarei usar no meu processamento
dbSelectArea( 'C1O' )
C1O->( dbsetOrder(3))

dbSelectArea( 'C2R' )
C2R->( dbsetOrder(3))

for nI := 1 to oModelCHT:Length()

	//Quando se tratar de uma linha que está sendo deletada não devo considerar o valor no processamento, porém como a função é utilizada para mais de um model preciso
	//identificar dequal tabela(alias) o DELETE se originou, devido a isso a utilização do cAlsOri
	if nI == nLineCHT .and. cAlsOri == 'CHT' .and. cAction == 'DELETE' 
		Loop
	endif
	
	//Posiciono na linha que vou verificar
	oModelCHT:GoLine( nI )

	//Verifico se a linha não está deletada ou se é a linha que esta sendo deletada pelo usuário, pois nesse caso 
	//o valor deve ser considerado no cálculo do valor total
	if !oModelCHT:IsDeleted() .Or. 	( cAction == 'UNDELETE' .and. cAlsOri == 'CHT' .and. nI == nLineCHT )

		//No caso da conta contábil, por possuir gatilho não tenho no momento da validação o novo valor do campo
		//sendo assim pego pelo valor passado por parâmetro default quando o valid for do próprio campo
		if cField == 'CHT_CTA' .and. valtype(xValNew) <> 'U'  
			cContaC  := xValNew
		else
			cContaC  := oModelCHT:GetValue( 'CHT_CTA' )
		endif
		
		//Tratamento pois o valor que está sendo inserido não existe no retorno da função FWFldGet, o segundo parâmetro
		//que indica a linha não está retornando o valor correto conforme exemplo do TDN
		if nI <> nLineCHT
			cIndVlr  := oModelCHT:GetValue( 'CHT_INDVLR' )
			nvlrLanc := oModelCHT:GetValue( 'CHT_VLRLC' )
		else
			cIndVlr  := FWFldGet( 'CHT_INDVLR' )
			nvlrLanc := FWFldGet( 'CHT_VLRLC' )
		endif
			
		//Posiciono na conta contábil utilizada no M310 
		if C1O->( msSeek( xfilial( 'C1O' ) + cContaC ) )
							
			//Posiciono na natureza da conta
			if C2R->( msSeek( xfilial( 'C2R' ) + C1O->C1O_CODNAT ) )
				
				//Verifico se a conta possui uma natureza que deve ser considerado na totalização do lançamento
				if C2R->C2R_CODIGO $ ( "01|02|03|04" )
					
					//Se a natureza for de Conta de Resultado
					if C2R->C2R_CODIGO == '04'
						
						//Se o indicador for igual a Débito soma o valor
						if cIndVlr == 'D'
						
							//Adição ou Lucro
							if cTipoLanc == 'AL'								
								nTotVlrLcto += nvlrLanc

							//Exclusão ou Prejuizo
							else
								nTotVlrLcto -= nvlrLanc
								
							endif
							
						elseif cIndVlr == 'C'
						
							//Adição ou Lucro
							if cTipoLanc == 'AL'
								nTotVlrLcto -= nvlrLanc
							
							//Exclusão ou Prejuizo
							else
								nTotVlrLcto += nvlrLanc
								
							endif
							
						endif
											
					//Quando a natureza for 01|02|03
					else
						
						//Se o indicador for igual a Débito soma o valor
						if cIndVlr == 'D'
							
							//Adição ou Lucro
							if cTipoLanc == 'AL'						
								nTotVlrLcto -= nvlrLanc
							
							//Exclusão ou Prejuizo
							else
								nTotVlrLcto += nvlrLanc
								
							endif
						
						elseif cIndVlr == 'C'
						
							//Adição ou Lucro
							if cTipoLanc == 'AL'								
								nTotVlrLcto += nvlrLanc
							
							else
								nTotVlrLcto -= nvlrLanc
								
							endif							
						endif															
					endif					
				endif									
			endif				
		endif		 				
	endif			
next
			
//Restauro a linha de origem da Grid
oModelCHT:GoLine( nLineCHT )

Return ( nil ) 

//---------------------------------------------------------------------
/*/{Protheus.doc} FExsLalur

Função respnsável por verificar Automaticamente o tipo de relacionamento do registro M300 com
as informações das grids M305 e M310

@Param		oModelCEP   - Model da tabela CEP
			oModelCEQ   - Model da tabela CEQ
			cAlsOri     - Nome do Alias de onde originou-se a chamada do Valid
			cAction     - Ação que originou a execução do Valid	

@Author		Rodrigo Aguilar
@Since		29/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FExsLalur( oModelCEP, oModelCEQ, cAlsOri, cAction )

local cRet	:=	''

local nI	:=	0

local nLine	:=	oModelCEP:GetLine()

//Verificando o registro M305	
for nI := 1 to oModelCEP:Length()
	
	if nI == nLine .and. cAction == 'DELETE' .and. cAlsOri == 'CEP'
		Loop
	endif
	
	oModelCEP:GoLine( nI )

	if ( !oModelCEP:IsDeleted() .and. !oModelCEP:IsEmpty() ) .Or. ( cAction == 'UNDELETE' .and. nI == nLine .and. cAlsOri == 'CEP' )
		cRet := '1'
		exit
	endif
next
oModelCEP:GoLine( nLine )

//Verificando o registro M310
nLine := oModelCEQ:GetLine()
for nI := 1 to oModelCEQ:Length()

	if nI == nLine .and. cAction == 'DELETE' .and. cAlsOri == 'CEQ'
		Loop
	endif
	
	oModelCEQ:GoLine( nI )

	if ( !oModelCEQ:IsDeleted() .and. !oModelCEQ:IsEmpty() )  .Or. ( cAction == 'UNDELETE' .and. nI == nLine .and. cAlsOri == 'CEQ' )
		if empty( cRet )
			cRet := '2'
		else
			cRet := '3'
		endif
		
		exit
	endif
next
oModelCEQ:GoLine( nLine )

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} FExsLacs

Função respnsável por verificar Automaticamente o tipo de relacionamento do registro M300 com
as informações das grids M305 e M310

@Param		oModelCHS   - Model da tabela CHS
			oModelCHT   - Model da tabela CHT
			cAlsOri     - Nome do Alias de onde originou-se a chamada do Valid
			cAction     - Ação que originou a execução do Valid	

@Author		Rodrigo Aguilar
@Since		29/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FExsLacs( oModelCHS, oModelCHT, cAlsOri, cAction )

local cRet	:=	''

local nI	:=	0

local nLine	:=	oModelCHS:GetLine()
	
//Verificando o registro M355	
for nI := 1 to oModelCHS:Length()
	
	if nI == nLine .and. cAction == 'DELETE' .and. cAlsOri == 'CHS'
		Loop
	endif
	
	oModelCHS:GoLine( nI )

	if ( !oModelCHS:IsDeleted() .and. !oModelCHS:IsEmpty() ) .Or. ( cAction == 'UNDELETE' .and. nI == nLine .and. cAlsOri == 'CHS' )
		cRet := '1'
		exit
	endif
next
oModelCHS:GoLine( nLine )

//Verificando o registro M360
nLine := oModelCHT:GetLine()
for nI := 1 to oModelCHT:Length()

	if nI == nLine .and. cAction == 'DELETE' .and. cAlsOri == 'CHT'
		Loop
	endif
	
	oModelCHT:GoLine( nI )

	if ( !oModelCHT:IsDeleted() .and. !oModelCHT:IsEmpty() )  .Or. ( cAction == 'UNDELETE' .and. nI == nLine .and. cAlsOri == 'CHT' )
		if empty( cRet )
			cRet := '2'
		else
			cRet := '3'
		endif
		
		exit
	endif
next
oModelCHT:GoLine( nLine )

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} FRmvWhen

Utilizado para remover o conteudo do When do campo para permitir que
sejam inseridos valores calculados automaticamente pelo sistema em tempo
de execução

@Param		oObj - Objeto onde se encontra o campo a ser manipulado
			cCmp - Campo a ser manipulado

@Return		aRet - Array com o conteudo a ser reposto no objeto:
					[1] - Conteudo do When do campo manipulado
					[2] - Identificador do campo na estrutura do objeto

@Author		Rodrigo Aguilar
@Since		15/04/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FRmvWhen( oObj, cCmp )

Local aStruct	:=	{}
Local aRet		:=	{}
Local bWhen		:=	Nil
Local nIdField	:=	0

aStruct := oObj:oFormModelStruct:GetFields()
nIdField := aScan( aStruct, { |x| AllTrim( x[MODEL_FIELD_IDFIELD] ) == cCmp } )
bWhen := oObj:oFormModelStruct:aFields[nIdField,MODEL_FIELD_WHEN]
oObj:oFormModelStruct:aFields[nIdField,MODEL_FIELD_WHEN] := Nil

aRet := { bWhen, nIdField }

Return( aRet )
