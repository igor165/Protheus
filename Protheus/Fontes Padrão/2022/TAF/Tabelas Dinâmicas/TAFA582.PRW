#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA582.CH"

//#DEFINE STR0001 "Fontes de Cotação ECF"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA582

Cadastro MVC de Códigos da fonte da cotação utilizada para a o cálculo do preço parâmetro.

@Author Wesley Silva Matos
@Since 16/04/2021
@Version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA582()
Local oBrw := FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Cadastro de Código de Conta Referencial"
oBrw:SetAlias( 'V6U' )
oBrw:SetMenuDef( 'TAFA582' )
V6U->( DBSetOrder( 2 ) )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@Author Wesley Silva Matos
@Since 16/04/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return xFunMnuTAF( "TAFA582",,,, .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@Return oModel - Objeto do Modelo MVC

@Author Wesley Silva Matos
@Since 16/04/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruV6U := FwFormStruct( 1, "V6U" )
Local oModel   := MpFormModel():New( "TAFA582" )

oModel:AddFields( "MODEL_V6U", /*cOwner*/, oStruV6U )
oModel:GetModel( "MODEL_V6U" ):SetPrimaryKey( { "V6U_FILIAL", "V6U_ID" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@Return oView - Objeto da View MVC

@Author Wesley Silva Matos
@Since 16/04/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel( "TAFA582" )
Local oStruV6U := FwFormStruct( 2, "V6U" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_V6U", oStruV6U, "MODEL_V6U" )
oView:EnableTitleView( "VIEW_V6U", STR0001 ) //"Cadastro de Código de Conta Referencial"
oView:CreateHorizontalBox( "FIELDSV6U", 100 )
oView:SetOwnerView( "VIEW_V6U", "FIELDSV6U" )

oStruV6U:RemoveField( "V6U_ID" )


Return( oView ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Wesley Silva Matos
@Since		16/04/2021
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu ) 

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1032.00

If nVerEmp < nVerAtu
	aAdd( aHeader, "V6U_FILIAL" )
	aAdd( aHeader, "V6U_ID" )
    aAdd( aHeader, "V6U_REGECF" )
	aAdd( aHeader, "V6U_CODFCO")
	aAdd( aHeader, "V6U_DESCRI")
	aAdd( aHeader, "V6U_DTINI" )
	aAdd( aHeader, "V6U_DTFIN" )


	aAdd( aBody, { "", "f78b6439-3cf6-3caa-e0fe-fbc026a841bc","X300", "101", "ChicagoBoard of Trade (CBOT) - Chicago - EUA", "20210101", "" } )
	aAdd( aBody, { "", "13e70312-b6ad-f8e4-40ce-eb1071672ddd","X300", "102", "Chicago Mercantile Exchange (CME) - Chicago - EUA", "20210101", "" } )
    aAdd( aBody, { "", "bcc02719-d8b2-2cd9-f8d8-49e73fb089c6","X300", "103", "New York Mercantile Exchange (NYMEX) - Nova York - EUA", "20210101", "" } )
    aAdd( aBody, { "", "54047179-3095-7ce4-a36b-48d4d51d4603","X300", "104", "Commodity Exchange (COMEX) - Nova York - EUA", "20210101", "" } )
    aAdd( aBody, { "", "02004c02-0b8b-c6c8-66a5-881363172069","X300", "105", "Intercontinental Exchange (ICE US) - Atlanta - EUA", "20210101", "" } )
    aAdd( aBody, { "", "9b8a2513-fedf-77cf-f462-00cc96f76d56","X300", "106", "Bolsa de Mercadorias & Futuros (BM&F) - São Paulo - Brasil", "20210101", "" } )
    aAdd( aBody, { "", "23491a8a-956a-0adb-7350-4b9577609f75","X300", "107", "Life NYSE Euronext (LIFFE) - Londres - Reino Unido", "20210101", "" } )
    aAdd( aBody, { "", "7ad3aae7-ee1a-0319-ae3e-ccc9aca86a21","X300", "108", "London Metal Exchange (LME) - Londres - Reino Unido", "20210101", "" } )
    aAdd( aBody, { "", "9daa01ea-0e42-b31d-0b8b-ddd7d58fe2ea","X300", "109", "Intercontinental Exchange (ICE Europe) - Londres - Reino Unido;", "20210101", "" } )
    aAdd( aBody, { "", "c7eab618-63b7-1ac4-9409-fb500bd9e7a0","X300", "110", "Tokio Commodity Exchange (TOCOM) - Tóquio - Japão", "20210101", "" } )
    aAdd( aBody, { "", "a4668346-fa8f-db87-adbb-93d8f774dccb","X300", "111", "Tokio Grain Exchange (TGE) - Tóquio - Japão", "20210101", "" } )
    aAdd( aBody, { "", "92966121-fffd-b889-5f92-ba8f1b13b197","X300", "112", "Singapore Commodity Exchange (SICOM) - Cidade de Cingapura - Cingapura", "20210101", "" } )
    aAdd( aBody, { "", "c38fb816-586e-140c-36b9-f83d6e29341b","X300", "113", "Hong Kong Commodity Exchange (HKE) - Hong Kong – China", "20210101", "" } )
    aAdd( aBody, { "", "b2e98375-a847-c62e-26d8-b9dc485c6d4f","X300", "114", "Multi Commodity Exchange (MCX) - Bombain - Índia", "20210101", "" } )
    aAdd( aBody, { "", "757f4939-433f-691b-0fa3-daf01b6f55a2","X300", "115", "National Commodity & Derivatives Exchange Limited (NCDEX) - Bombain - Índia", "20210101", "" } )
    aAdd( aBody, { "", "693c93af-3f24-0b79-faa0-32cdc10faf1e","X300", "116", "Agricultural Futures Exchange of Thailand (AFET) - Bangkok - Tailândia", "20210101", "" } )
    aAdd( aBody, { "", "f83d0b06-69b6-ff6b-7141-30a2dc502640","X300", "117", "Australian Securities Exchange (ASX) - Sidney - Austrália", "20210101", "" } )
    aAdd( aBody, { "", "ba059f8c-5011-0418-8d72-d18d55a5234e","X300", "118", "JSE Safex APD (SAFEX) – Johannesburg - África do Sul;", "20210101", "" } )
    aAdd( aBody, { "", "a5092f8b-56cf-289c-6796-a5b7ede8b9f0","X300", "119", "Korea Exchange (KRX) - Busan - Coréia do Sul", "20210101", "" } )
    aAdd( aBody, { "", "7a2fe0fc-59a9-3057-8d4f-eba59f8ff108","X300", "120", "China Beijing International Mining Exchange, (CBMX);", "20210101", "" } )
    aAdd( aBody, { "", "c85e774b-7b7b-6f3c-500b-58c35cb5e2b8","X300", "121", "GlobalORE;", "20210101", "" } )
    aAdd( aBody, { "", "45320a7c-361e-71df-4a53-62e934eb84c1","X300", "122", "London Bullion Market Association (LBMA)", "20210101", "" } )
    aAdd( aBody, { "", "e2041ca8-e695-58b7-413b-ffbab4fff52d","X300", "123", "Beijing Iron Ore Trading Center Corporation (COREX). (Incluído pela IN RFB nº 1.870/2019)", "20210101", "" } )
    aAdd( aBody, { "", "bd3ab713-c71f-a77a-1f35-550be1443914","X300", "201", "PLATTS", "20210101", "" } )
    aAdd( aBody, { "", "283d7d46-72ed-5ed0-e823-4f84ed6f3c31","X300", "202", "ARGUS", "20210101", "" } )
    aAdd( aBody, { "", "06c8111f-b54d-d579-1a21-6524533b9b29","X300", "203", "CMA", "20210101", "" } )
    aAdd( aBody, { "", "d169a2e0-852a-cb28-55be-05bad3a89e06","X300", "204", "ESALQ", "20210101", "" } )
    aAdd( aBody, { "", "918f39e2-822d-bdfa-5723-34bace6ed3b6","X300", "205", "TSI", "20210101", "" } )
    aAdd( aBody, { "", "f945a224-767a-0c6a-5261-e4ce7990699f","X300", "206", "THE METAL BULLETIN", "20210101", "" } )
    aAdd( aBody, { "", "257fca3b-1e6c-0ceb-fd37-b7033a5120af","X300", "207", "CRU MONITOR", "20210101", "" } )
    aAdd( aBody, { "", "c498f77a-e0cd-b588-6f52-c42424c7a0de","X300", "208", "CIS; (Incluído pela IN RFB nº 1.395, de 13/09/2013)", "20210101", "" } )
    aAdd( aBody, { "", "29cc37f1-8c59-e326-b8f8-3d385236fb6d","X300", "209", "CMAI; (Incluído pela IN RFB nº 1.395, de 13/09/2013)", "20210101", "" } )
    aAdd( aBody, { "", "f4adabc2-2b77-fb13-b684-7f6ddf64c502","X300", "210", "POTEN&PARTNERS; (Incluído pela IN RFB nº 1.395, de 13/09/2013)", "20210101", "" } )
    aAdd( aBody, { "", "99141919-a3f0-0266-77cf-20c723397a4c","X300", "211", "BLOOMBERG; (Incluído pela IN RFB nº 1.395, de 13/09/2013)", "20210101", "" } )
    aAdd( aBody, { "", "8034e85c-6b12-8518-a487-a22123df4497","X300", "212", "ICIS HEREN; (Incluído pela IN RFB nº 1.395, de 13/09/2013)", "20210101", "" } )
    aAdd( aBody, { "", "0a447f12-2228-9867-9c0b-73b29cece472","X300", "213", "U.S. Energy Information Administration (EIA). (Incluído pela IN RFB nº 1.395, de 13/09/2013)", "20210101", "" } )
    
    //X320
    aAdd( aBody, { "", "016b7e9c-c6d7-9921-2bbe-538e0a2682c8","X320", "101", "ChicagoBoard of Trade (CBOT) - Chicago - EUA", "20210101", "" } )
    aAdd( aBody, { "", "99c2dd8f-3163-f005-53d4-a018087f1e45","X320", "102", "Chicago Mercantile Exchange (CME) - Chicago - EUA", "20210101", "" } )
    aAdd( aBody, { "", "b0406945-f2f6-cbf3-786d-c0e777feaa70","X320", "103", "New York Mercantile Exchange (NYMEX) - Nova York - EUA", "20210101", "" } )
    aAdd( aBody, { "", "157da4e8-c5be-5bf0-a783-044c9d80374b","X320", "104", "Commodity Exchange (COMEX) - Nova York - EUA", "20210101", "" } )
    aAdd( aBody, { "", "df21e741-0538-e5dd-0642-c1380596ef3b","X320", "105", "Intercontinental Exchange (ICE US) - Atlanta - EUA", "20210101", "" } )
    aAdd( aBody, { "", "a7c770b2-63c6-2f5f-822e-bd080c1c0090","X320", "106", "Bolsa de Mercadorias & Futuros (BM&F) - São Paulo - Brasil", "20210101", "" } )
    aAdd( aBody, { "", "57a0584a-1e80-5291-6379-f5157075dcea","X320", "107", "Life NYSE Euronext (LIFFE) - Londres - Reino Unido", "20210101", "" } )
    aAdd( aBody, { "", "b9511bc2-3300-934b-496f-07c04a0fc158","X320", "108", "London Metal Exchange (LME) - Londres - Reino Unido", "20210101", "" } )
    aAdd( aBody, { "", "5a1a5b62-91a8-4e80-d737-393f09ff230b","X320", "109", "Intercontinental Exchange (ICE Europe) - Londres - Reino Unido;", "20210101", "" } )
    aAdd( aBody, { "", "17edf799-8aae-88aa-fb62-118fda986f7b","X320", "110", "Tokio Commodity Exchange (TOCOM) - Tóquio - Japão", "20210101", "" } )
    aAdd( aBody, { "", "8680d13f-afed-325f-c90c-696762980754","X320", "111", "Tokio Grain Exchange (TGE) - Tóquio - Japão", "20210101", "" } )
    aAdd( aBody, { "", "a339bb01-4021-fea6-cf3c-6eedb1de8d40","X320", "112", "Singapore Commodity Exchange (SICOM) - Cidade de Cingapura - Cingapura", "20210101", "" } )
    aAdd( aBody, { "", "430958aa-e236-4168-5163-4fc8cb356711","X320", "113", "Hong Kong Commodity Exchange (HKE) - Hong Kong – China", "20210101", "" } )
    aAdd( aBody, { "", "a3828fdc-a186-a80c-706e-217e528423ed","X320", "114", "Multi Commodity Exchange (MCX) - Bombain - Índia", "20210101", "" } )
    aAdd( aBody, { "", "b61ac98e-89b7-2f20-4de5-953ca5da94ab","X320", "115", "National Commodity & Derivatives Exchange Limited (NCDEX) - Bombain - Índia", "20210101", "" } )
    aAdd( aBody, { "", "5e3cb5cd-9510-4d5b-e7ba-868c6b71b352","X320", "116", "Agricultural Futures Exchange of Thailand (AFET) - Bangkok - Tailândia", "20210101", "" } )
    aAdd( aBody, { "", "b367bea5-ec7c-8244-ba79-14004db7f349","X320", "117", "Australian Securities Exchange (ASX) - Sidney - Austrália", "20210101", "" } )
    aAdd( aBody, { "", "b1605bb8-9d55-0494-345b-24e39b5df3b4","X320", "118", "JSE Safex APD (SAFEX) – Johannesburg - África do Sul;", "20210101", "" } )
    aAdd( aBody, { "", "d76b0d57-4833-b7fe-4a66-670271ed4153","X320", "119", "Korea Exchange (KRX) - Busan - Coréia do Sul", "20210101", "" } )
    aAdd( aBody, { "", "1ea91c53-0213-157f-1272-77d48d7bf6b0","X320", "120", "China Beijing International Mining Exchange, (CBMX);", "20210101", "" } )
    aAdd( aBody, { "", "5a9ad720-08fb-1488-7c28-5db003d3a679","X320", "121", "GlobalORE;", "20210101", "" } )
    aAdd( aBody, { "", "b6c35aa7-df4f-aa17-b523-e7517f7a631d","X320", "122", "London Bullion Market Association (LBMA)", "20210101", "" } )
    aAdd( aBody, { "", "6cc1bbc4-bff3-2549-f503-f2ddffe8d753","X320", "123", "Beijing Iron Ore Trading Center Corporation (COREX). (Incluído pela IN RFB nº 1.870/2019)", "20210101", "" } )
    aAdd( aBody, { "", "3444e022-113a-3f1e-5b5c-3532619bab05","X320", "201", "PLATTS", "20210101", "" } )
    aAdd( aBody, { "", "79465368-68c6-362e-aad1-79998a2758c2","X320", "202", "ARGUS", "20210101", "" } )
    aAdd( aBody, { "", "73e8a246-a91c-5425-8296-91fc5668db65","X320", "203", "CMA", "20210101", "" } )
    aAdd( aBody, { "", "48e54692-d3ce-e979-e532-e73224866b2f","X320", "204", "ESALQ", "20210101", "" } )
    aAdd( aBody, { "", "998f3ef8-a71c-db68-6fe6-67689e6b6e6e","X320", "205", "TSI", "20210101", "" } )
    aAdd( aBody, { "", "37afba05-e567-5119-a9d3-2f38580cbb5d","X320", "206", "THE METAL BULLETIN", "20210101", "" } )   
    aAdd( aBody, { "", "8cba12cc-29c7-ac77-1a0c-0bf96c432179","X320", "207", "CRU MONITOR", "20210101", "" } )
    aAdd( aBody, { "", "1ef14646-071b-9369-19e9-4dd6d958609b","X320", "208", "CIS; (Incluído pela IN RFB nº 1.395, de 13/09/2013)", "20210101", "" } )
    aAdd( aBody, { "", "2a6b215a-6061-962f-a99a-ffdacf3a1d35","X320", "209", "CMAI; (Incluído pela IN RFB nº 1.395, de 13/09/2013)", "20210101", "" } )
    aAdd( aBody, { "", "ef7ae17d-3c45-433f-7580-bccfa3a91989","X320", "210", "POTEN&PARTNERS; (Incluído pela IN RFB nº 1.395, de 13/09/2013)", "20210101", "" } )
    aAdd( aBody, { "", "a865efa0-c555-c1f2-8da6-dd07c99113a8","X320", "211", "BLOOMBERG; (Incluído pela IN RFB nº 1.395, de 13/09/2013)", "20210101", "" } )
    aAdd( aBody, { "", "921b881e-3b7f-7ebd-aa73-32a6702f996a","X320", "212", "ICIS HEREN; (Incluído pela IN RFB nº 1.395, de 13/09/2013)", "20210101", "" } )
    aAdd( aBody, { "", "4d213e4e-4032-ec7b-34cc-0fe0534be0cc","X320", "213", "U.S. Energy Information Administration (EIA). (Incluído pela IN RFB nº 1.395, de 13/09/2013)", "20210101", "" } )
    aAdd( aBody, { "", "ebb48c02-aa3e-9650-1b61-1b0e76b4a3e9","X320", "999", "Agências ou órgãos reguladores (art. 36, inciso II)", "20210101", "" } )
	
    aAdd( aRet, { aHeader, aBody } )
EndIf


Return( aRet )
