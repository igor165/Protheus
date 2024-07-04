#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA473.CH"

Static lLaySimplif	:= TafLayESoc("S_01_00_00")
 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA473
Cadastro de trabalhador autônomo

@author Rodrigo Aguilar
@since 15/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA473()

	Local oBrw	:=	FWmBrowse():New()

	If TafAtualizado()
	
		oBrw:SetDescription( "Cadastro de Trabalhador Autônomo (RPA) - Info. Folha de Pagamento (S-1200)" )
		oBrw:SetAlias( "C9V" )
		oBrw:SetMenuDef( "TAFA473" )
		oBrw:SetFilterDefault( "C9V_NOMEVE == 'TAUTO'" )
		oBrw:Activate()

	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Rodrigo Aguilar
@since 15/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return( xFunMnuTAF( "TAFA473" ) )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Rodrigo Aguilar
@since 15/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------     
Static Function ModelDef()

Local cCmpsC9V		:= ""
Local oStruC9V		:=	Nil
Local oStruCUP		:=	FWFormStruct( 1, "CUP", { |x| AllTrim( x ) $ "CUP_FILIAL|CUP_ID|CUP_VERSAO|CUP_CNPJEA|CUP_MATANT|CUP_DTINVI|CUP_OBSVIN|CUP_NOMEVE" } )
Local oModel		:=	MPFormModel():New( "TAFA473",,, { |oModel| SaveModel( oModel ) } ) 
Local lVldCNPJEA	:= .T.

If TafLayESoc("02_05_00")
	oStruCUP	:=	FWFormStruct( 1, "CUP", { |x| AllTrim( x ) $ "CUP_FILIAL|CUP_ID|CUP_VERSAO|CUP_INSANT|CUP_CNPJEA|CUP_MATANT|CUP_DTINVI|CUP_OBSVIN|CUP_NOMEVE" } )
Else
	oStruCUP	:=	FWFormStruct( 1, "CUP", { |x| AllTrim( x ) $ "CUP_FILIAL|CUP_ID|CUP_VERSAO|CUP_CNPJEA|CUP_MATANT|CUP_DTINVI|CUP_OBSVIN|CUP_NOMEVE" } )
	oStruCUP:SetProperty( "CUP_CNPJEA", MODEL_FIELD_VALID, {|| lVldCNPJEA })
EndIf

If !lLaySimplif
	cCmpsC9V := "C9V_FILIAL|C9V_ID|C9V_VERSAO|C9V_CPF|C9V_NIS|C9V_NOME|C9V_DTNASC|C9V_NOMEVE|C9V_MATRIC|C9V_ATIVO|C9V_LOGOPE"
Else
	cCmpsC9V := "C9V_FILIAL|C9V_ID|C9V_VERSAO|C9V_CPF|C9V_NOME|C9V_DTNASC|C9V_NOMEVE|C9V_MATRIC|C9V_ATIVO|C9V_LOGOPE"
EndIf


oStruC9V := FWFormStruct( 1, "C9V", { |x| AllTrim( x ) $ cCmpsC9V } )

If lLaySimplif
	oStruC9V:RemoveField("C9V_NIS")
Else
	oStruC9V:SetProperty( "C9V_NIS"		, MODEL_FIELD_OBRIGAT	, .F. )
EndIf

//------------------------------------------------------------------------------------
//Retirando a obrigatoriedade dos campos da tabela C9V que não são usados no cadastro
//------------------------------------------------------------------------------------
oStruC9V:SetProperty( "C9V_MATRIC"	, MODEL_FIELD_OBRIGAT	, .F. )
oStruC9V:SetProperty( "C9V_NOMEVE"	, MODEL_FIELD_INIT		, { || "TAUTO" } )
oStruC9V:SetProperty( "C9V_ATIVO"	, MODEL_FIELD_INIT		, { || "1" } )
oStruC9V:SetProperty( "C9V_FILIAL"	, MODEL_FIELD_INIT		, { || xFilial( "C9V" ) } )

oModel:AddFields( "MODEL_C9V", /*cOwner*/, oStruC9V )
oModel:GetModel ( "MODEL_C9V" ):SetPrimaryKey( { "C9V_CPF", "C9V_MATRIC", "C9V_NOMEVE" } )

//Vínculo
oModel:AddFields( "MODEL_CUP", "MODEL_C9V", oStruCUP )

//---------------------------------------------------------------
//A tabela CUP não é filha da tabela C9V, porém por questões de
//normalização as informações foram desmembradas em duas tabelas
//---------------------------------------------------------------
oModel:SetRelation( "MODEL_CUP",{ { "CUP_FILIAL", "xFilial( 'CUP' )" }, { "CUP_ID", "C9V_ID" }, { "CUP_VERSAO", "C9V_VERSAO" }, { "CUP_NOMEVE", "C9V_NOMEVE" } },CUP->( IndexKey( 4 ) ) )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View   

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 15/05/2017
@version 1.0                  
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local cCmpsC9V	:= ""
Local oStruC9V	:= Nil
Local oModel	:= FWLoadModel( "TAFA473" )
Local oStruCUP	:= FWFormStruct( 2, "CUP", { |x| AllTrim( x ) $ "CUP_CNPJEA|CUP_MATANT|CUP_DTINVI|CUP_OBSVIN" } )
Local oView		:= FWFormView():New()

If TafLayESoc("02_05_00")
	oStruCUP	:= FWFormStruct( 2, "CUP", { |x| AllTrim( x ) $ "CUP_INSANT|CUP_CNPJEA|CUP_MATANT|CUP_DTINVI|CUP_OBSVIN" } )
Else
	oStruCUP	:= FWFormStruct( 2, "CUP", { |x| AllTrim( x ) $ "CUP_CNPJEA|CUP_MATANT|CUP_DTINVI|CUP_OBSVIN" } )
EndIf

If !lLaySimplif
	cCmpsC9V := "C9V_ID|C9V_CPF|C9V_NIS|C9V_NOME|C9V_DTNASC|C9V_NOMEVE|C9V_MATRIC|C9V_LOGOPE"
Else
	cCmpsC9V := "C9V_ID|C9V_CPF|C9V_NOME|C9V_DTNASC|C9V_NOMEVE|C9V_MATRIC|C9V_LOGOPE"
EndIf

oStruC9V :=	FWFormStruct( 2, "C9V", { |x| AllTrim( x ) $ cCmpsC9V } )

oView:SetModel( oModel )

oView:AddField( "VIEW_C9V", oStruC9V, "MODEL_C9V" )
oView:EnableTitleView( "VIEW_C9V", "Cadastro de Trabalhador Autônomo" )

oView:AddField( "VIEW_CUP", oStruCUP, "MODEL_CUP" )
oView:EnableTitleView( "VIEW_CUP", "Informações da Sucessão de Vínculo Trabalhista" )

oView:CreateHorizontalBox( "C9V", 40 )
oView:CreateHorizontalBox( "CUP", 60 )

oView:SetOwnerView( "VIEW_C9V", "C9V" )
oView:SetOwnerView( "VIEW_CUP", "CUP" )

//------------------------------------------------------
//Removendo campos que precisam existir para tratamento
//de chave única mas não precisam ser exibidos na View
//------------------------------------------------------
oStruC9V:RemoveField( "C9V_MATRIC" )
oStruC9V:RemoveField( "C9V_NOMEVE" )

If TafColumnPos( "C9V_LOGOPE" )
	oStruC9V:RemoveField( "C9V_LOGOPE" )
EndIf

If TafLayESoc("02_05_00") .And. TafColumnPos( "CUP_INSANT" )
	oStruCUP:SetProperty( "CUP_INSANT"	, MVC_VIEW_ORDEM, "40" )
EndIf

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@author Rodrigo Aguilar
@since 15/05/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local cLogOpe		
Local cLogOpeAnt	

Local nOperation	:=	oModel:GetOperation()
Local oModelC9V		:=	oModel:GetModel( "MODEL_C9V" )
Local lRet			:=	.T.

cLogOpe    := ""
cLogOpeAnt := ""

If nOperation == MODEL_OPERATION_INSERT

	TafAjustID( "C9V", oModel)

	If Findfunction("TAFAltMan")
		TAFAltMan( 3 , 'Save' , oModel, 'MODEL_C9V', 'C9V_LOGOPE' , '2', '' )
	Endif

	C9V->( DBSetOrder( 4 ) )
	If C9V->( MsSeek( xFilial( "C9V" ) + oModelC9V:GetValue( "C9V_CPF" ) + "TAUTO1" ) )
		oModel:SetErrorMessage ( ,,,,, "Já existe esse mesmo CPF cadastrado para outro trabalhador autônomo", "Deve existir apenas um CPF cadastrado para cada trabalhador autônomo" )
		lRet := .F.
	Else
		oModel:LoadValue( "MODEL_C9V", "C9V_VERSAO", xFunGetVer() )
	EndIf

Elseif nOperation == MODEL_OPERATION_UPDATE

	If TafColumnPos( "C9V_LOGOPE" )
		cLogOpeAnt := oModelC9V:GetValue( "C9V_LOGOPE" )
	endif

	If Findfunction("TAFAltMan")
		TAFAltMan( 4 , 'Save' , oModel, 'MODEL_C9V', 'C9V_LOGOPE' , '' , cLogOpeAnt )
	EndIf
EndIf

If lRet
	FWFormCommit( oModel )
EndIf

Return( lRet )
