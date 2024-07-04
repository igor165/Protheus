#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA458.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA458
Cadastro MVC dos Países do banco central/SISCOMEX

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA458()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de País do banco central/SISCOMEX
oBrw:SetAlias( 'T59')
oBrw:SetMenuDef( 'TAFA458' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA458" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT59 	:= 	FWFormStruct( 1, 'T59' )
Local oModel 	:= 	MPFormModel():New( 'TAFA458' )

oModel:AddFields('MODEL_T59', /*cOwner*/, oStruT59)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA458' )
Local 	oStruT59 	:= 	FWFormStruct( 2, 'T59' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_T59', oStruT59, 'MODEL_T59' )

oView:EnableTitleView( 'VIEW_T59', STR0001 ) //Cadastro de Unidade de Medida ANP
oView:CreateHorizontalBox( 'FIELDST59', 100 )
oView:SetOwnerView( 'VIEW_T59', 'FIELDST59' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1012

If nVerEmp < nVerAtu
	aAdd( aHeader, "T59_FILIAL" )
	aAdd( aHeader, "T59_ID" )
	aAdd( aHeader, "T59_CODIGO" )
	aAdd( aHeader, "T59_UNMEDI" )
	aAdd( aHeader, "T59_DINIVA" )
	aAdd( aHeader, "T59_DFINVA" )

	aAdd( aBody, { "", "abf65d58-6e20-5819-ff60-6d4ea4b1f780", "27", "%"            , "200611", "" } )
	aAdd( aBody, { "", "2d9c530e-6379-3d05-72fa-6a729cdb0cef", "03", "ºC"           , "200409", "" } )
	aAdd( aBody, { "", "e9626a14-7a31-3cce-5fcd-9872447aa78a", "29", "cm"           , "200611", "" } )
	aAdd( aBody, { "", "e98a7105-2896-ce95-22c1-54479a6c2ada", "32", "cP"           , "200611", "" } )
	aAdd( aBody, { "", "c008a71e-192a-cff0-87ec-c0721dbf3bdc", "08", "g/L"          , "200409", "" } )
	aAdd( aBody, { "", "2a8b19ef-bddf-e096-8a14-9ea77583efdc", "24", "h"            , "200409", "" } )
	aAdd( aBody, { "", "2c4e3651-6f6f-e40b-e0db-1a765ecc1a15", "12", "ºINPM"        , "200409", "" } )
	aAdd( aBody, { "", "0b8c876a-30d7-6b4e-f28a-64be675df6d6", "33", "Kg/L"         , "200611", "" } )
	aAdd( aBody, { "", "fb314947-276f-900d-2a71-016cb132f140", "02", "Kg/m³"        , "200409", "" } )
	aAdd( aBody, { "", "9790f2b3-d0bf-26d0-f3f3-45492dcc27cb", "04", "KPa"          , "200409", "" } )
	aAdd( aBody, { "", "3cd43648-b34c-21e1-722b-582156a344b1", "07", "%massa"       , "200409", "" } )
	aAdd( aBody, { "", "3fbe070d-0372-656f-7f26-3529a3ae9262", "14", "mg KOH/g"     , "200409", "" } )
	aAdd( aBody, { "", "15fcb5ae-056d-0bcb-a2a4-280db84832ed", "13", "mg/Kg"        , "200409", "" } )
	aAdd( aBody, { "", "2a3d83d5-7c9f-cd4b-96d6-aa62f5033496", "10", "mg/L"         , "200409", "" } )
	aAdd( aBody, { "", "b9851204-cf68-3f9a-78e2-ae6bf9345ac7", "25", "mg/m³"        , "200606", "" } )
	aAdd( aBody, { "", "9768640c-8e1c-ae68-7e3c-c5c3b021f5f4", "05", "mg/100mL"     , "200409", "" } )
	aAdd( aBody, { "", "e267e09c-9cba-b60a-b00a-e36cddd67233", "06", "min"          , "200409", "" } )
	aAdd( aBody, { "", "70f94323-3f98-02ad-b760-1f322d171eda", "15", "MJ/Kg"        , "200409", "" } )
	aAdd( aBody, { "", "a4b040bb-f209-a60b-8a59-7f7f37de405c", "19", "mL"           , "200409", "" } )
	aAdd( aBody, { "", "2761ad59-6269-271a-86ac-f24a6f2307b2", "34", "mL/L"         , "200611", "" } )
	aAdd( aBody, { "", "9213f9bc-ef20-608c-1d2b-c75da80d32f7", "16", "mm"           , "200409", "" } )
	aAdd( aBody, { "", "a8c6bfea-788b-73b9-fcec-85c1b0058b25", "17", "mmHg"         , "200409", "" } )
	aAdd( aBody, { "", "9feb4777-a73a-4334-b923-c01d7de1fded", "09", "(mm2/s)cst"   , "200409", "" } )
	aAdd( aBody, { "", "cae76605-aa77-096f-942a-6fc5138ec540", "11", "mS/m"         , "200409", "" } )
	aAdd( aBody, { "", "db736513-f348-d69d-3fe4-70747a6342ae", "22", "Não se Aplica", "200409", "" } )
	aAdd( aBody, { "", "d4c92787-6898-0360-3015-58c2c0718131", "31", "Poise"        , "200611", "" } )
	aAdd( aBody, { "", "87b1b847-4096-fa69-a012-64e72a43f8e6", "23", "ppm"          , "200409", "" } )
	aAdd( aBody, { "", "205503f5-cb14-8b80-733c-a890ef63c3d2", "18", "pS/m"         , "200409", "" } )
	aAdd( aBody, { "", "b77b579c-f76a-be34-5110-74c2ce4c014f", "28", "s"            , "200611", "" } )
	aAdd( aBody, { "", "23d507dd-c02f-0748-cc2f-8c8ffc2d5d87", "26", "SSF"          , "200611", "" } )
	aAdd( aBody, { "", "ffc9e336-fbd8-7db2-775e-52592bf3789e", "01", "%volume"      , "200409", "" } )
	aAdd( aBody, { "", "665e683a-10d1-2db6-91c4-af5eae9fbc6d", "30", "0,1 mm"       , "200611", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )