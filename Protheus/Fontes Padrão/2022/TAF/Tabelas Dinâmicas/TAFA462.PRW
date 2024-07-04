#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA462.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA462
Cadastro MVC dos Países do banco central/SISCOMEX

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA462()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de País do banco central/SISCOMEX
oBrw:SetAlias( 'T5D')
oBrw:SetMenuDef( 'TAFA462' )
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
Return XFUNMnuTAF( "TAFA462" )
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
Local oStruT5D 	:= 	FWFormStruct( 1, 'T5D' )
Local oModel 	:= 	MPFormModel():New( 'TAFA462' )

oModel:AddFields('MODEL_T5D', /*cOwner*/, oStruT5D)

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA462' )
Local 	oStruT5D 	:= 	FWFormStruct( 2, 'T5D' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_T5D', oStruT5D, 'MODEL_T5D' )

oView:EnableTitleView( 'VIEW_T5D', STR0001 ) //Cadastro de Capacidade Não Mensurável ANP
oView:CreateHorizontalBox( 'FIELDST5D', 100 )
oView:SetOwnerView( 'VIEW_T5D', 'FIELDST5D' )

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
	aAdd( aHeader, "T5D_FILIAL" )
	aAdd( aHeader, "T5D_ID" )
	aAdd( aHeader, "T5D_CODIGO" )
	aAdd( aHeader, "T5D_CARACT" )
	aAdd( aHeader, "T5D_DTINI" )
	aAdd( aHeader, "T5D_DATFIN" )

	aAdd( aBody, { "", "174621cd-a73c-fab7-8acc-1b45cb43a977", "07", "Amarelo"            			, "200409", "" 		 } )
	aAdd( aBody, { "", "10360aee-13be-3edd-2b90-0d142adf0d16", "06", "Ausente"            			, "200409", "" 		 } )
	aAdd( aBody, { "", "13b8bfa4-8817-96df-3482-d3a9eedb68b9", "11", "Azul"            				, "200409", "" 		 } )
	aAdd( aBody, { "", "a47342ff-9f4c-0941-e4ab-43c22b30bac5", "03", "Incolor"            			, "200409", "" 		 } )
	aAdd( aBody, { "", "ec3fe3ee-ebd1-5edc-c530-83eb29649359", "54", "Laranja"            			, "200501", "" 		 } )
	aAdd( aBody, { "", "0a2e1d70-9edb-42e3-21d4-0312f303cff5", "04", "Levemente Amarelada"          , "200409", "" 		 } )
	aAdd( aBody, { "", "f5285946-b5d6-7afb-c8b1-716a1bdd362c", "12", "Límpido com Impurezas"        , "200409", "" 		 } )
	aAdd( aBody, { "", "54e27b0a-948c-8e2c-fd7f-ccab915c02f2", "01", "Límpido e isento de Impurezas", "200409", "" 		 } )
	aAdd( aBody, { "", "2492d012-4168-5e27-8649-e7c9b8c0056e", "35", "Não Passa"        			, "200409", "" 		 } )
	aAdd( aBody, { "", "64b05b57-5bd2-af59-401c-0c989b80676f", "53", "Negativo"         			, "200409", "" 		 } )
	aAdd( aBody, { "", "86a54da8-e1ab-9e1e-3745-4ef0fef8d3c0", "34", "Passa"            			, "200409", "" 		 } )
	aAdd( aBody, { "", "a2fa656d-2079-2fc5-6cee-cf6b2743a128", "52", "Positivo"         			, "200409", "" 		 } )
	aAdd( aBody, { "", "e8fba164-056a-f2c2-0ac6-88dcdae97a03", "05", "Presente"         			, "200409", "" 		 } )
	aAdd( aBody, { "", "c455220b-10b4-2b2a-1894-e01927911385", "02", "Turvo"            			, "200409", "200501" } )
	aAdd( aBody, { "", "1fd458dd-4295-e150-d5d4-f55df11ddafa", "14", "Turvo com Impurezas"          , "200409", "" 		 } )
	aAdd( aBody, { "", "76da7d95-cd06-6a72-2917-980f0696d905", "13", "Turvo Isento de Impurezas"    , "200409", "" 		 } )
	aAdd( aBody, { "", "2d1077cf-d669-a6d3-fad1-54523d6f9faf", "10", "Verde"       				    , "200409", "" 		 } )
	aAdd( aBody, { "", "28492baa-a333-8cb5-5aa7-7c80d75cc862", "09", "Vermelho"    				    , "200409", "" 		 } )
	aAdd( aBody, { "", "60e40e43-f0fd-aa75-3e72-a697780d8650", "59", "<0,001"      				    , "200501", "" 		 } )
	aAdd( aBody, { "", "ca209227-0540-92b6-8c12-03b3e400a2c5", "60", "<0,005"      				    , "200501", "" 		 } )
	aAdd( aBody, { "", "af734fb5-f40b-e1b3-74d5-6e44193c594b", "61", "<0,01"       				    , "200501", "" 		 } )
	aAdd( aBody, { "", "c441027e-607b-1939-20a6-1c8110707e5e", "62", "<0,05"       				    , "200501", "" 		 } )
	aAdd( aBody, { "", "fd5d1957-20c3-62d2-222b-730fb66b12cf", "63", "<0,1"        				    , "200501", "" 		 } )
	aAdd( aBody, { "", "dde6864c-73ad-99ce-1506-908a0a78d4d2", "36", "<0,5"        				    , "200409", "" 		 } )
	aAdd( aBody, { "", "d31be4c4-810b-294f-214e-f79a27ba246d", "55", "1"           				  	, "200611", "" 		 } )
	aAdd( aBody, { "", "b6048c43-267b-c5e2-e7f3-f4a65728612f", "15", "1A"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "bd97ca0d-fd57-bf8c-042c-d5a121de9b9d", "16", "1B"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "fe9f3aa6-611f-9a7d-c58e-d0ebfe57b321", "27", "1P"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "9d2a187b-d49e-4191-6a82-43989e6221fb", "37", "<1,0"        				    , "200409", "" 		 } )
	aAdd( aBody, { "", "8a92f1fe-85d8-c39b-7bef-b112de4186cf", "38", "<1,5"        				    , "200409", "" 		 } )
	aAdd( aBody, { "", "abcb6a10-8153-c408-4f97-cb97ab461727", "28", "<2"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "d7135cae-80ff-0e4a-ee21-a7ee9d2cb713", "56", "2"           				  	, "200611", "" 		 } )
	aAdd( aBody, { "", "25b492be-531f-4ad4-85e4-8e6a0ab7e975", "17", "2A"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "5866a219-03b0-ea1c-8835-f3fe38b2683d", "18", "2B"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "e6cf6319-2000-b7bd-da5a-9e1cecba34a1", "19", "2C"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "d3a590e4-720b-6ef6-77af-b8c9754655ef", "20", "2D"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "023a17a5-e2a9-25bf-b38e-d544a143e07c", "21", "2E"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "51c4235d-062f-a901-cb51-b61dfbaf02d6", "29", "2P"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "05e79f25-318d-0372-50c2-939c13a80d79", "39", "<2,0"        				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "8595a07f-f0cd-5a32-b86c-15e3d2a09734", "40", "<2,5"        				    , "200409", "" 		 } )
	aAdd( aBody, { "", "21874321-378a-226e-539e-5029291fd3fb", "30", "<3"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "2e699acf-ea51-13ea-2ec8-dff1dea77bb9", "57", "3"           				  	, "200611", "" 		 } )
	aAdd( aBody, { "", "75938e37-a63a-2984-e0a3-f16ea8dbd0c8", "22", "3A"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "2706b583-deb4-5e6b-d7a1-a7d28c0b1904", "23", "3B"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "d4a6c8df-a50a-f3bb-70f7-cfa66b63ed1c", "31", "3P"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "5de7ada7-9c20-78b7-c874-54db45e808ee", "41", "<3,0"        				    , "200409", "" 		 } )
	aAdd( aBody, { "", "9d53e989-20d8-5e08-7741-6a905b402c09", "42", "<3,5"        				    , "200409", "" 		 } )
	aAdd( aBody, { "", "2849924e-c6ed-e3a2-b8bb-562fa47fba93", "32", "<4"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "257770aa-3ca0-00ad-931a-83086871626a", "58", "4"           				 	, "200611", "" 		 } )
	aAdd( aBody, { "", "f7f8839b-7cf9-3d46-d0bc-a593df3edec8", "24", "4A"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "4929b8ac-f47e-9472-fa38-a0ab0d1c8e0a", "25", "4B"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "b2e63173-8c76-c2a3-5d19-71323df47fa8", "26", "4C"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "b5ba58fb-bbfd-1be9-126c-c24b9a7d1186", "33", "4P"          				  	, "200409", "" 		 } )
	aAdd( aBody, { "", "83588056-0b9a-09e8-fdb0-52ba7327b0c2", "43", "<4.0"        				    , "200409", "" 		 } )
	aAdd( aBody, { "", "b89db718-fc69-7a34-55f5-9ba07b165468", "44", "<4,5"        				    , "200409", "" 		 } )
	aAdd( aBody, { "", "da54ca26-8ed5-30ca-2d8c-8c7bf01c89c4", "45", "<5,0"        				    , "200409", "" 		 } )
	aAdd( aBody, { "", "2986431f-c9e4-f883-6ff7-47b4c7c32cf5", "46", "<5,5"        				    , "200409", "" 		 } )
	aAdd( aBody, { "", "c6e4176c-6e0f-58f9-af0a-b9449fb0bbf1", "47", "<6,0"        				    , "200409", "" 		 } )
	aAdd( aBody, { "", "8ea1d821-b257-ba2c-d745-e3ce9e8430aa", "48", "<6,5"        				    , "200409", "" 		 } )
	aAdd( aBody, { "", "23e25e65-bce3-288f-432d-e24ef2856965", "49", "<7,0"        				    , "200409", "" 		 } )
	aAdd( aBody, { "", "666ccdc8-f19f-eea8-a4b2-dcfa485ab1d1", "50", "<7,5"        				    , "200409", "" 		 } )
	aAdd( aBody, { "", "b8a11e3f-ed9a-9662-43bd-6e37524cca17", "51", "<8,0"        				    , "200409", "" 		 } )
	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )