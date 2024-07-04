#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA386
Cadastro de Tipo de Moeda(ECF)

@author Evandro dos Santos Oliveira
@since 06/05/2015
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA386()
Local   oBrw  :=  FWmBrowse():New()

oBrw:SetDescription("Cadastro de Tipo de Moeda")    //"Cadastro de Tipo de Moeda"
oBrw:SetAlias( 'CZU')
oBrw:SetMenuDef( 'TAFA386' )
CZU->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Evandro dos Santos Oliveira	
@since 06/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA386" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Evandro dos Santos Oliveira
@since 06/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCZU  :=  FWFormStruct( 1, 'CZU' )
Local oModel    :=  MPFormModel():New( 'TAFA386' )

oModel:AddFields('MODEL_CZU', /*cOwner*/, oStruCZU)
oModel:GetModel('MODEL_CZU'):SetPrimaryKey({'CZU_FILIAL','CZU_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Evandro dos Santos Oliveira 
@since 06/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA386' )
Local   oStruCZU    :=  FWFormStruct( 2, 'CZU' )
Local   oView       :=  FWFormView():New()


oView:SetModel( oModel )
oView:AddField( 'VIEW_CZU', oStruCZU, 'MODEL_CZU' )

oView:EnableTitleView( 'VIEW_CZU',"Cadastro de Tipo de Moeda")    //"Cadastro de Tipo de Moeda"
oView:CreateHorizontalBox( 'FIELDSCZU', 100 )
oView:SetOwnerView( 'VIEW_CZU', 'FIELDSCZU' )

oStruCZU:RemoveField( "CZU_ID" )

Return oView 



//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1032.00

If nVerEmp < nVerAtu
	aAdd( aHeader, "CZU_FILIAL" )
	aAdd( aHeader, "CZU_ID" )
	aAdd( aHeader, "CZU_CODIGO" )
	aAdd( aHeader, "CZU_DESCRI" )
	aAdd( aHeader, "CZU_DTINI" )
	aAdd( aHeader, "CZU_DTFIN" )
	aAdd( aHeader, "CZU_SIGLAM" )

	aAdd( aBody, { "", "131af7ed-d842-0924-b8b0-3b13a8379980", "5"	, "AFEGANE AFEGANIST"		, "20130101", "", "AFN" } )
	aAdd( aBody, { "", "ac4e4044-7c6a-084e-f38f-e623300ec54c", "406", "ARIARY MADAGASCAR"		, "20130101", "", "MGA" } )
	aAdd( aBody, { "", "35f0ccde-d9c6-e3f5-9ecb-266d6823519a", "10"	, "AUSTRAL"					, "20130101", "", "" } )
	aAdd( aBody, { "", "b4b98eec-89cd-113b-84ab-aecc349e1423", "20"	, "BALBOA/PANAMA"			, "20130101", "", "PAB" } )
	aAdd( aBody, { "", "99dcd377-4052-3e8f-f52e-9f07ba13e55c", "15"	, "BATH/TAILANDIA"			, "20130101", "", "THB" } )
	aAdd( aBody, { "", "f0bd380f-283e-b91b-5d67-47e36622b466", "8"	, "BIRR"					, "20130101", "", "" } )
	aAdd( aBody, { "", "a662b12f-5eef-98c0-0bf1-53560defaef0", "9"	, "BIRR/ETIOPIA"			, "20130101", "", "ETB" } )
	aAdd( aBody, { "", "c793d4a1-cc2c-456a-2e8b-cbf531fe303b", "26"	, "BOLIVAR VEN"				, "20130101", "", "VEF" } )
	aAdd( aBody, { "", "e2fe1d0c-70b6-05a2-b150-7b0d49b270b4", "25"	, "BOLIVAR/VENZUELA"		, "20130101", "", "" } )
	aAdd( aBody, { "", "c13d1105-0bbc-2759-12fe-8ef186422698", "30"	, "BOLIVIANO/BOLIVIA"		, "20130101", "", "BOB" } )
	aAdd( aBody, { "", "dca8c79f-8f78-5244-3c3c-c9bfe7ced12b", "995", "BUA"						, "20130101", "", "" } )
	aAdd( aBody, { "", "6b276aab-d2cf-4628-a0c5-c9b6622a006a", "35"	, "CEDI GANA"				, "20130101", "", "GHS" } )
	aAdd( aBody, { "", "cd68a153-7461-1f08-a609-836ee135547d", "40"	, "COLON/COSTA RICA"		, "20130101", "", "CRC" } )
	aAdd( aBody, { "", "cc65f55a-34e0-46ca-73e2-b3b399b900ef", "45"	, "COLON/EL SALVADOR"		, "20130101", "", "SVC" } )
	aAdd( aBody, { "", "62e77066-14a1-6508-342e-e4e0d36b9d39", "51"	, "CORDOBA OURO"			, "20130101", "", "NIO" } )
	aAdd( aBody, { "", "297aea78-9ad3-4287-4dff-142998bf0be3", "50"	, "CORDOBA/NICARAGUA"		, "20130101", "", "NIO" } )
	aAdd( aBody, { "", "faa5dc3e-19a3-2c63-ef68-a63fc9efff2f", "55"	, "COROA DINAM/DINAM"		, "20130101", "", "DKK" } )
	aAdd( aBody, { "", "4f8590e0-d396-81ae-1f98-f9c7abc064dd", "58"	, "COROA ESLOVACA"			, "20130101", "", "" } )
	aAdd( aBody, { "", "d8cc9863-a3cc-dbc7-b742-11fcfb57e0a2", "57"	, "COROA ESTONIA"			, "20130101", "", "" } )
	aAdd( aBody, { "", "5f9deff3-5ea4-829e-cf00-4d153cf2590a", "60"	, "COROA ISLND/ISLAN"		, "20130101", "", "ISK" } )
	aAdd( aBody, { "", "1d5d547c-a11c-bbbf-a268-783b323ef53c", "65"	, "COROA NORUE/NORUE"		, "20130101", "", "NOK" } )
	aAdd( aBody, { "", "bfabdb3c-981e-a496-1e4c-07e826337971", "70"	, "COROA SUECA/SUECI"		, "20130101", "", "SEK" } )
	aAdd( aBody, { "", "fc60f5ae-fc3a-1966-817a-59535b0f8c6b", "75"	, "COROA TCHECA"			, "20130101", "", "CZK" } )
	aAdd( aBody, { "", "dbddbb26-0fcf-8227-4833-ab70c84e4ecc", "79"	, "CRUZADO"					, "20130101", "", "" } )
	aAdd( aBody, { "", "63117d75-a23a-a372-13ad-6a4beec0d770", "78"	, "CRUZADO NOVO"			, "20130101", "", "" } )
	aAdd( aBody, { "", "c19d34a2-5510-a6ee-7016-6ad7ddc8a7aa", "80"	, "CRUZEIRO"				, "20130101", "", "" } )
	aAdd( aBody, { "", "a3ac897f-e2d2-4917-473f-73a51821be58", "83"	, "CRUZEIRO"				, "20130101", "", "" } )
	aAdd( aBody, { "", "5034b077-beba-b45e-b690-c23edf74aef5", "85"	, "CRUZEIRO REAL"			, "20130101", "", "" } )
	aAdd( aBody, { "", "fc179cc5-a452-e1b9-a772-45806ae77ac1", "88"	, "CUPON GEORGIANO"			, "20130101", "", "" } )
	aAdd( aBody, { "", "66b954c1-a620-4208-a4f5-7c2275cb2242", "90"	, "DALASI/GAMBIA"			, "20130101", "", "GMD" } )
	aAdd( aBody, { "", "d7a08828-1b2f-299a-7660-f9beae2565c4", "95"	, "DINAR ARGELINO"			, "20130101", "", "DZD" } )
	aAdd( aBody, { "", "ad469290-f8cf-94b6-898b-249c8702c235", "110", "DINAR IEMENITA"			, "20130101", "", "" } )
	aAdd( aBody, { "", "eee6ada2-5db6-3cf3-5041-76286698e07a", "120", "DINAR IUGOSLAVO"			, "20130101", "", "" } )
	aAdd( aBody, { "", "c19c060f-82c4-5b35-3d10-e833e6940f36", "133", "DINAR SERVIO SERV"		, "20130101", "", "RSD" } )
	aAdd( aBody, { "", "9f8192ee-d729-f3a4-c191-a5b4007521b7", "105", "DINAR/BAHREIN"			, "20130101", "", "BHD" } )
	aAdd( aBody, { "", "55248278-4335-72f6-5059-41c63e864dd0", "115", "DINAR/IRAQUE"			, "20130101", "", "IQD" } )
	aAdd( aBody, { "", "ff05d501-e51f-5855-5294-3b21b0c79c12", "125", "DINAR/JORDANIA"			, "20130101", "", "JOD" } )
	aAdd( aBody, { "", "e666099e-add5-114e-37bf-2a1186ff58f0", "100", "DINAR/KWAIT"				, "20130101", "", "KWD" } )
	aAdd( aBody, { "", "bc69c6f7-31c5-8a4a-6f28-72d9ffd8b1ae", "130", "DINAR/LIBIA"				, "20130101", "", "LYD" } )
	aAdd( aBody, { "", "66acd2ea-b27b-9964-3013-36164c9f8d61", "132", "DINAR/MACEDONIA"			, "20130101", "", "MKD" } )
	aAdd( aBody, { "", "60dc0516-8cff-6d82-32f1-95b47d0cb4a2", "135", "DINAR/TUNISIA"			, "20130101", "", "TND" } )
	aAdd( aBody, { "", "b27b8a63-6747-ca8f-f46d-1f1b4fb80e60", "138", "DIREITO ESPECIAL"		, "20130101", "", "SDR" } )
	aAdd( aBody, { "", "8eb0a6fe-71b4-93c6-2730-0dcc7e6ac4b7", "145", "DIRHAM/EMIR.ARABE"		, "20130101", "", "AED" } )
	aAdd( aBody, { "", "20fb751a-c491-2678-862a-ebf0fc535b9f", "139", "DIRHAM/MARROCOS"			, "20130101", "", "MAD" } )
	aAdd( aBody, { "", "8493d16a-9e45-4e09-fa00-3c0fcf7a0e04", "148", "DOBRA S TOME PRIN"		, "20130101", "", "STD" } )
	aAdd( aBody, { "", "aa431a4b-9a58-f263-39b1-df03bb48420b", "150", "DOLAR AUSTRALIANO"		, "20130101", "", "AUD" } )
	aAdd( aBody, { "", "2f7fc624-f67e-31b1-5413-3fed82836795", "185", "DOLAR BRUNEI"			, "20130101", "", "BND" } )
	aAdd( aBody, { "", "f65acac7-d559-a176-e7d4-503353d8c828", "165", "DOLAR CANADENSE"			, "20130101", "", "CAD" } )
	aAdd( aBody, { "", "4923852f-800d-a14d-789e-c3c6e65c8ce6", "215", "DOLAR CARIBE ORIE"		, "20130101", "", "XCD" } )
	aAdd( aBody, { "", "2f38d51a-2531-6433-4547-036c1b7e54dc", "195", "DOLAR CINGAPURA"			, "20130101", "", "SGD" } )
	aAdd( aBody, { "", "6c304170-0981-4f4e-6d0a-39a4d5c600b6", "170", "DOLAR DA GUIANA"			, "20130101", "", "GYD" } )
	aAdd( aBody, { "", "90f0c7ec-e44b-3e34-2c05-c600115534a7", "173", "DOLAR DA NAMIBIA"		, "20130101", "", "NAD" } )
	aAdd( aBody, { "", "d8c5de8c-aadb-ca47-1ec8-0da4bea97879", "220", "DOLAR DOS EUA"			, "20130101", "", "USD" } )
	aAdd( aBody, { "", "974296d5-ca85-10c8-4a76-23dfc2acef12", "200", "DOLAR FIJI"				, "20130101", "", "FJD" } )
	aAdd( aBody, { "", "10669672-0e04-f710-9e08-b5067e34d17a", "205", "DOLAR HONG KONG"			, "20130101", "", "HKD" } )
	aAdd( aBody, { "", "b5d3bcc4-fe25-fac7-0888-86145698afcb", "250", "DOLAR IL SALOMAO"		, "20130101", "", "SBD" } )
	aAdd( aBody, { "", "97de021f-0d54-bdbb-b0a5-87daa6e0b7a7", "235", "DOLAR LIBERIA"			, "20130101", "", "LRD" } )
	aAdd( aBody, { "", "d69f76cd-0372-61a1-be8c-e1d95a395967", "240", "DOLAR MALAIO"			, "20130101", "", "" } )
	aAdd( aBody, { "", "5bbe6ee6-2bcf-ee0a-0f82-0446bf4d9443", "998", "DOLAR OURO"				, "20130101", "", "XAU" } )
	aAdd( aBody, { "", "93638ebd-7f99-445f-d289-33b67b4596ff", "217", "DOLAR ZIMBABUE"			, "20130101", "", "ZWL" } )
	aAdd( aBody, { "", "71877b56-1708-488c-1031-9a96ab3e1370", "155", "DOLAR/BAHAMAS"			, "20130101", "", "BSD" } )
	aAdd( aBody, { "", "91b34fc2-cd5a-8bbd-608b-257b34b9be20", "175", "DOLAR/BARBADOS"			, "20130101", "", "BBD" } )
	aAdd( aBody, { "", "da985fca-5a5f-f224-01d6-a924dab01794", "180", "DOLAR/BELIZE"			, "20130101", "", "BZD" } )
	aAdd( aBody, { "", "da6c5e78-3589-1f2e-0574-b0b028ef6e22", "160", "DOLAR/BERMUDAS"			, "20130101", "", "BMD" } )
	aAdd( aBody, { "", "c7400430-6d36-e186-1ecd-79d1f8694177", "190", "DOLAR/CAYMAN" 			, "20130101", "", "KYD" } )
	aAdd( aBody, { "", "3c93e1e7-394b-edda-2d2e-32bea7bce90b", "225", "DOLAR/ETIOPIA"			, "20130101", "", "" } )
	aAdd( aBody, { "", "4a9aed88-4e60-68de-b3a3-e8b12e3783c8", "230", "DOLAR/JAMAICA"			, "20130101", "", "JMD" } )
	aAdd( aBody, { "", "57e32b9a-f179-9511-1a7d-7789346330c8", "245", "DOLAR/NOVA ZELAND"		, "20130101", "", "NZD" } )
	aAdd( aBody, { "", "8e5fb6c9-b92c-a009-0843-b861ec182e76", "255", "DOLAR/SURINAME"			, "20130101", "", "SRD" } )
	aAdd( aBody, { "", "57c1eade-62f8-51e4-a99f-54d95d8d6d9a", "333", "DOLAR/SURINAME"			, "20130101", "", "SRD" } )
	aAdd( aBody, { "", "19713fc9-f286-1aa7-d5df-eefe0d18d502", "210", "DOLAR/TRIN. TOBAG"		, "20130101", "", "TTD" } )
	aAdd( aBody, { "", "4ef84b03-c00d-4db7-a82a-87578d45f6a2", "982", "DOLAR-BULGARIA"			, "20130101", "", "" } )
	aAdd( aBody, { "", "c4288bee-970c-67cc-ee7e-96d2d0296f02", "980", "DOLAR-EX-ALEM.ORI"		, "20130101", "", "" } )
	aAdd( aBody, { "", "74750ca2-be96-d2d1-babf-4fe03cb57ab6", "983", "DOLAR-GRECIA" 			, "20130101", "", "" } )
	aAdd( aBody, { "", "b04fbf2a-b990-2101-e1a9-fd49363f5329", "984", "DOLAR-HUNGRIA"			, "20130101", "", "" } )
	aAdd( aBody, { "", "014b558d-509b-ae42-965e-664d2b2bb0f4", "986", "DOLAR-ISRAEL"			, "20130101", "", "" } )
	aAdd( aBody, { "", "28ee2efe-9d1a-dca3-4f3b-eafb66c084cc", "988", "DOLAR-IUGOSLAVIA"		, "20130101", "", "" } )
	aAdd( aBody, { "", "3c500439-d916-b131-21af-1816d78e4f4c", "990", "DOLAR-POLONIA"			, "20130101", "", "" } )
	aAdd( aBody, { "", "ef46377b-4a38-fd07-d784-e52c02f46acf", "992", "DOLAR-ROMENIA"			, "20130101", "", "" } )
	aAdd( aBody, { "", "3fc37927-b21e-04f5-2e1f-00680d69a4ad", "260", "DONGUE/VIETNAN"			, "20130101", "", "VND" } )
	aAdd( aBody, { "", "09521815-ba8d-d94d-6a1d-017a6aa5c96b", "270", "DRACMA/GRECIA" 			, "20130101", "", "" } )
	aAdd( aBody, { "", "4b57e2ed-8ac8-c742-5607-dd5e50f39a53", "275", "DRAM ARMENIA REP"		, "20130101", "", "AMD" } )
	aAdd( aBody, { "", "595b086e-211f-7598-7845-31747744d8a3", "295", "ESCUDO CABO VERDE"		, "20130101", "", "CVE" } )
	aAdd( aBody, { "", "8ae0301c-e217-e1eb-93fd-4eca9e325052", "315", "ESCUDO PORTUGUES"		, "20130101", "", "" } )
	aAdd( aBody, { "", "33e7e40e-3bcb-63d6-a2f8-2a487f803e09", "320", "ESCUDO TIMOR LEST"		, "20130101", "", "" } )
	aAdd( aBody, { "", "c5e7ab71-9e34-ead2-028d-8b9238a4e964", "978", "EURO"					, "20130101", "", "EUR" } )
	aAdd( aBody, { "", "b3877b9b-d1fb-c4a7-a960-ec659b804a80", "335", "FLORIM HOLANDES"			, "20130101", "", "" } )
	aAdd( aBody, { "", "4b7b3ead-fa0d-3e07-615a-7115562d701d", "328", "FLORIM/ARUBA"			, "20130101", "", "" } )
	aAdd( aBody, { "", "8b63fba0-bdab-f2f2-54f2-b40e241a2e7f", "330", "FLORIM/SURINAME"			, "20130101", "", "" } )
	aAdd( aBody, { "", "6d20c4d8-ea91-44f5-d6f7-a2a74af2122b", "345", "FORINT/HUNGRIA"			, "20130101", "", "HUF" } )
	aAdd( aBody, { "", "5cbbcc3d-649b-e42f-68f0-51c1e0587d41", "361", "FRANCO BELGA FINA"		, "20130101", "", "" } )
	aAdd( aBody, { "", "081f2375-3925-f6b6-bc3b-0ac06e0f892e", "360", "FRANCO BELGA/BELG"		, "20130101", "", "" } )
	aAdd( aBody, { "", "168cf4e3-854e-8a29-259e-f08d75192ceb", "372", "FRANCO CFA BCEAO" 		, "20130101", "", "XOF" } )
	aAdd( aBody, { "", "1f966fd5-764a-9472-10bb-5b8af1b77aef", "370", "FRANCO CFA BEAC"			, "20130101", "", "XAF" } )
	aAdd( aBody, { "", "6234e3dd-9fb3-dd42-b323-001437331df6", "380", "FRANCO CFP"				, "20130101", "", "XPF" } )
	aAdd( aBody, { "", "ee805e14-f32c-2a70-d758-625a5a8f46c9", "363", "FRANCO CONGOLES"			, "20130101", "", "CDF" } )
	aAdd( aBody, { "", "6a63c77c-fd2b-74ba-4658-77d7e75d1718", "395", "FRANCO FRANCES"			, "20130101", "", "" } )
	aAdd( aBody, { "", "0a6c1273-4c2d-1fac-2be6-e3fcbfaffe76", "400", "FRANCO LUXEMBURGO"		, "20130101", "", "" } )
	aAdd( aBody, { "", "70f085df-706d-ad78-e65d-2a1158fe1f99", "405", "FRANCO MALGAXE MA"		, "20130101", "", "" } )
	aAdd( aBody, { "", "f9cc7785-273a-06fd-d7be-bb8b3c6656dc", "410", "FRANCO MALI"				, "20130101", "", "" } )
	aAdd( aBody, { "", "dcf0e70d-f01b-7345-95bc-42741bc17bd0", "425", "FRANCO SUICO"			, "20130101", "", "CHF" } )
	aAdd( aBody, { "", "b50e77c9-b758-27fa-a70a-c83806ccd163", "365", "FRANCO/BURUNDI"			, "20130101", "", "BIF" } )
	aAdd( aBody, { "", "cd051357-3e46-c61d-eede-374d91ec5376", "385", "FRANCO/BURUNDI"			, "20130101", "", "" } )
	aAdd( aBody, { "", "b9090e36-56c1-95bb-59e9-dde7b873d941", "368", "FRANCO/COMORES"			, "20130101", "", "KMF" } )
	aAdd( aBody, { "", "c6cde482-903a-9845-c7d6-134531338103", "390", "FRANCO/DJIBUTI"			, "20130101", "", "DJF" } )
	aAdd( aBody, { "", "f451885d-bdc6-bb99-d122-c59aea19547e", "398", "FRANCO/GUINE"  			, "20130101", "", "GNF" } )
	aAdd( aBody, { "", "99298b5c-bbd2-a475-6f52-a39a8a3db7b0", "420", "FRANCO/RUANDA"			,"20130101", "", "RWF" } )
	aAdd( aBody, { "", "843e878d-4175-ca74-4ae6-98b4bc8d42bf", "996", "FUA"						, "20130101", "", "" } )
	aAdd( aBody, { "", "30ed09fb-c634-0f82-0914-84616072553b", "440", "GOURDE/HAITI"			, "20130101", "", "HTG" } )
	aAdd( aBody, { "", "88377a5a-f4c4-aa41-1031-800a62e30677", "450", "GUARANI/PARAGUAI"		, "20130101", "", "PYG" } )
	aAdd( aBody, { "", "7b7e053b-2348-aeaf-cde7-4538f0609265", "325", "GUILDER ANTILHAS"		, "20130101", "", "ANG" } )
	aAdd( aBody, { "", "364b44d1-8491-a2da-57db-e57ca9dd6488", "460", "HRYVNIA UCRANIA"			, "20130101", "", "UAH" } )
	aAdd( aBody, { "", "c849ce86-0074-abd7-3bb0-dd030071b5b4", "470", "IENE"					, "20130101", "", "JPY" } ) //? Acredito ser IENE, pois, ZIENE não existe 
	aAdd( aBody, { "", "96bf6834-785b-3505-81f0-aada42a2fa7f", "480", "INTI PERUANO"			, "20130101", "", "" } )
	aAdd( aBody, { "", "5014129c-83a0-d76e-9a6e-f47b2f1bb8ac", "776", "KARBOVANETS"				, "20130101", "", "" } )
	aAdd( aBody, { "", "d17b256a-8c19-674d-948a-95445bb2f655", "778", "KINA/PAPUA N GUIN"		, "20130101", "", "PGK" } )
	aAdd( aBody, { "", "be7e4377-203c-3682-9bca-946ddf64f810", "779", "KUNA/CROACIA" 			, "20130101", "", "HRK" } )
	aAdd( aBody, { "", "dbc11ec8-1ba4-454f-aba7-9a5be7405868", "635", "KWANZA/ANGOLA"			, "20130101", "", "AOA" } )
	aAdd( aBody, { "", "d0a1c6cb-f721-355e-c69e-a9b2b0fd93d6", "482", "LARI GEORGIA" 			, "20130101", "", "GEL" } )
	aAdd( aBody, { "", "097e2cf1-fcac-9a23-0b17-68c0dc356676", "485", "LAT/LETONIA, REP"		, "20130101", "", "" } )
	aAdd( aBody, { "", "f8216445-bff3-91a6-abe4-3f27657bfdfa", "490", "LEK ALBANIA REP" 		, "20130101", "", "ALL" } )
	aAdd( aBody, { "", "7cc3b071-32a9-da46-fcf5-8c1edc6f3797", "495", "LEMPIRA/HONDURAS"		, "20130101", "", "HNL" } )
	aAdd( aBody, { "", "e6d857a7-292a-754c-7fd5-525b148fff62", "500", "LEONE/SERRA LEOA"		, "20130101", "", "SLL" } )
	aAdd( aBody, { "", "ddfb5f88-e5e1-f87c-7c48-77115231181f", "503", "LEU/MOLDAVIA, REP"		, "20130101", "", "MDL" } )
	aAdd( aBody, { "", "daf79a13-781f-fac7-c6c4-22d3a2341ba6", "505", "LEU/ROMENIA"				, "20130101", "", "" } )
	aAdd( aBody, { "", "23504813-1f0b-7146-bbca-c95d623ee451", "510", "LEV/BULGARIA, REP"		, "20130101", "", "BGN" } )
	aAdd( aBody, { "", "b2b97f76-b11e-7862-4d4a-e258d60c7ceb", "520", "LIBRA CIP/CHIPRE"		, "20130101", "", "" } )
	aAdd( aBody, { "", "cf450188-c99c-c094-8801-b745140fb088", "540", "LIBRA ESTERLINA" 		, "20130101", "", "GBP" } )
	aAdd( aBody, { "", "4d7008f1-5bdd-cfca-ff14-37f1ccdff18a", "555", "LIBRA ISRAELENSE"		, "20130101", "", "" } )
	aAdd( aBody, { "", "c404f41a-b754-3231-5354-613d30894708", "580", "LIBRA SUDANESA"  		, "20130101", "", "SSP" } )
	aAdd( aBody, { "", "52f8f7d9-4d10-071b-bb9f-aacef3d33806", "535", "LIBRA/EGITO"     		, "20130101", "", "EGP" } )
	aAdd( aBody, { "", "bd8af65d-b43f-8aea-588e-ef8b548a37a2", "545", "LIBRA/FALKLAND"  		, "20130101", "", "FKP" } )
	aAdd( aBody, { "", "a009bbb6-7d6e-49e3-c788-97f49fb29bc0", "530", "LIBRA/GIBRALTAR" 		, "20130101", "", "GIP" } )
	aAdd( aBody, { "", "cb56fb08-d3eb-f9d4-961b-89d4aa5d34c1", "550", "LIBRA/IRLANDA"			, "20130101", "", "" } )
	aAdd( aBody, { "", "6f42c93f-978f-6b21-11db-dbd28b00793a", "560", "LIBRA/LIBANO" 			, "20130101", "", "LBP" } )
	aAdd( aBody, { "", "52078f1e-a5d7-acc0-b49d-b3af4d8cdecd", "575", "LIBRA/SIRIA, REP"		, "20130101", "", "" } )
	aAdd( aBody, { "", "a87d529b-4fb0-dffd-8433-331df4b6a921", "570", "LIBRA/STA HELENA"		, "20130101", "", "SHP" } )
	aAdd( aBody, { "", "7f162ac7-4e42-a3c2-1ca5-6b7d7979e8c1", "585", "LILANGENI/SUAZIL"		, "20130101", "", "SZL" } )
	aAdd( aBody, { "", "34d0f0be-a904-1f22-8ab1-6c101c989650", "595", "LIRA ITALIANA"			, "20130101", "", "" } )
	aAdd( aBody, { "", "03c8d480-9c66-d797-fc85-e3ad6f95a364", "565", "LIRA/MALTA"	 			, "20130101", "", "" } )
	aAdd( aBody, { "", "6928f3a9-3997-f16b-f5a7-8cd1d93350fa", "600", "LIRA/TURQUIA" 			, "20130101", "", "TRY" } )
	aAdd( aBody, { "", "102ac656-d27f-054c-615a-d97176976ae5", "601", "LITA/LITUANIA"			, "20130101", "", "" } )
	aAdd( aBody, { "", "43efe1ca-24c9-fa24-533c-0f74a5fc87cb", "603", "LOTI/LESOTO"  			, "20130101", "", "LSL" } )
	aAdd( aBody, { "", "6cfa21e1-929a-f724-f675-5a187ae1e353", "607", "MANAT ARZEBAIJAO"		, "20130101", "", "" } )
	aAdd( aBody, { "", "2a2f323b-3646-2670-c943-b476ee1698ba", "605", "MARCO"					, "20130101", "", "" } )
	aAdd( aBody, { "", "ae0b5813-6238-01ae-4138-770a8aba6cfa", "610", "MARCO ALEMAO"			, "20130101", "", "" } )
	aAdd( aBody, { "", "05510f28-5e53-9557-8ec2-dc9931e73d3f", "612", "MARCO CONV BOSNIA"		, "20130101", "", "BAM" } )
	aAdd( aBody, { "", "b359c772-72a8-bb00-78de-33c729453847", "615", "MARCO FINLANDES"			, "20130101", "", "" } )
	aAdd( aBody, { "", "6edc8aa9-b620-a69c-c83a-9d82069450bb", "620", "METICAL MOCAMBIQ"		, "20130101", "", "" } )
	aAdd( aBody, { "", "485f280e-ab6c-99ac-0c4e-a9848d40103c", "630", "NAIRA/NIGERIA" 			, "20130101", "", "NGN" } )
	aAdd( aBody, { "", "4c897cec-8b6f-0d77-8d59-2034e1a4800c", "625", "NAKFA ERITREIA"			, "20130101", "", "ERN" } )
	aAdd( aBody, { "", "58503ea9-8512-b2e8-6b95-43587917160e", "665", "NGULTRUM/BUTAO"			, "20130101", "", "BTN" } )
	aAdd( aBody, { "", "108e3c04-e55b-fb4a-dfe4-78097606d6c9", "134", "NOVA LIBRA SUDANE"		, "20130101", "", "SDG" } )
	aAdd( aBody, { "", "8688f1af-f94e-8231-7a19-d19b44233fbb", "642", "NOVA LIRA/TURQUIA"		, "20130101", "", "" } )
	aAdd( aBody, { "", "03f7709d-842a-e412-a17f-e34a4c0bde33", "622", "NOVA METICAL/MOCA"		, "20130101", "", "MZN" } )
	aAdd( aBody, { "", "46eaa182-2eb9-0439-4266-d00524c9a6fe", "637", "NOVO DINAR IUGOSL"		, "20130101", "", "" } )
	aAdd( aBody, { "", "f627bfe4-919b-3983-d72d-68b8b2b88a08", "640", "NOVO DOLAR/TAIWAN"		, "20130101", "", "TWD" } )
	aAdd( aBody, { "", "29d2ce7c-4062-bd08-a0a1-b935f786a549", "506", "NOVO LEU/ROMENIA" 		, "20130101", "", "RON" } )
	aAdd( aBody, { "", "d847cafb-1429-ab11-8881-1c1eb38ff72f", "608", "NOVO MANAT TURCOM"		, "20130101", "", "TMT" } )
	aAdd( aBody, { "", "965b42ea-77b6-429a-3da7-c363bea97dfc", "650", "NOVO PESO URUGUAI"		, "20130101", "", "" } )
	aAdd( aBody, { "", "da8089be-13c7-c316-f24d-4ef51af29b36", "651", "NOVO PESO URUGUAI"		, "20130101", "", "" } )
	aAdd( aBody, { "", "e452d27c-de5f-dea5-910f-51edb0e0a8b8", "645", "NOVO PESO/MEXICO"		, "20130101", "", "" } )
	aAdd( aBody, { "", "9b919fa5-aec8-fd81-3e34-a73d13752fd8", "646", "NOVO PESO/MEXICO"		, "20130101", "", "" } )
	aAdd( aBody, { "", "de2f65f5-cefb-8c9c-3657-c2eb335c9800", "660", "NOVO SOL/PERU"			, "20130101", "", "PEN" } )
	aAdd( aBody, { "", "a545afe5-1d30-cf18-0b0b-3d2e229249b6", "970", "NOVO ZAIRE ZAIRE"		, "20130101", "", "" } )
	aAdd( aBody, { "", "92c7c801-1218-72da-b15c-42a2369c2d8d", "971", "NOVO ZAIRE/ZAIRE"		, "20130101", "", "" } )
	aAdd( aBody, { "", "3691544d-803e-0cd7-14bc-01b690ad71a7", "663", "NOVO ZAIRE/ZAIRE"		, "20130101", "", "" } )
	aAdd( aBody, { "", "712bade8-4e9c-78ca-78ed-5e1dc8383f55", "680", "PAANGA/TONGA"			, "20130101", "", "TOP" } )
	aAdd( aBody, { "", "ed7c7c09-81fb-d926-c5fc-7b143a415b6d", "993", "PALADIO"					, "20130101", "", "" } )
	aAdd( aBody, { "", "dfcf48e1-03e5-4655-b0fb-dfaa84ba00e6", "685", "PATACA/MACAU"			, "20130101", "", "MOP" } )
	aAdd( aBody, { "", "6ef9eda8-5541-ab99-aae2-2baab38e63ff", "700", "PESETA ESPANHOLA"		, "20130101", "", "" } )
	aAdd( aBody, { "", "68640202-5d75-2de5-3270-6be70eaabfb2", "690", "PESETA/ANDORA" 			, "20130101", "", "" } )
	aAdd( aBody, { "", "ef680486-8616-7b31-1a67-de0a4058beeb", "705", "PESO ARGENTINO"			, "20130101", "", "ARS" } )
	aAdd( aBody, { "", "2b68dbd6-546c-a327-8916-5aabfa1d7dd5", "710", "PESO BOLIVIANO"			, "20130101", "", "" } )
	aAdd( aBody, { "", "a80dd378-6895-6e8f-d653-6394448ca94f", "715", "PESO CHILE"				, "20130101", "", "CLP" } )
	aAdd( aBody, { "", "105c831b-d297-0938-6457-0a8dbff96351", "740", "PESO MEXICANO" 			, "20130101", "", "" } )
	aAdd( aBody, { "", "3955251f-c64b-2d7e-07d6-7bd7735252d0", "706", "PESO/ARGENTINA"			, "20130101", "", "" } )
	aAdd( aBody, { "", "3331e9a6-670d-2393-5dd7-b62ae2f0316b", "720", "PESO/COLOMBIA" 			, "20130101", "", "COP" } )
	aAdd( aBody, { "", "448977f2-080e-8407-d2d7-42e48070cd9a", "725", "PESO/CUBA"				, "20130101", "", "CUP" } )
	aAdd( aBody, { "", "44f74bc3-035a-602e-31aa-9314a647e9d2", "735", "PESO/FILIPINAS"			, "20130101", "", "PHP" } )
	aAdd( aBody, { "", "54c06825-32b7-4f49-e63c-20ca21ae6bb4", "738", "PESO/GUINE BISSAU"		, "20130101", "", "GWP" } )
	aAdd( aBody, { "", "ff3cbcbe-0d69-0ebe-582d-c41be6e76d90", "741", "PESO/MEXICO"				, "20130101", "", "MXN" } )
	aAdd( aBody, { "", "7dd11a0a-65b1-6802-ee5c-a4f3475219d3", "730", "PESO/REP. DOMINIC"		, "20130101", "", "DOP" } )
	aAdd( aBody, { "", "0049a83d-e37e-54ed-b746-61f378db6949", "745", "PESO/URUGUAIO"			, "20130101", "", "UYU" } )
	aAdd( aBody, { "", "40c5e01a-b2b1-76a1-f24e-b99c67ee8326", "994", "PLATINA"					, "20130101", "", "" } )
	aAdd( aBody, { "", "b01884b5-fe87-25c5-27b4-ee1858609388", "991", "PRATA-DEAFI"				, "20130101", "", "" } )
	aAdd( aBody, { "", "69bc1356-5a2c-b604-41d7-a5b5d6f748b6", "755", "PULA/BOTSWANA"			, "20130101", "", "BWP" } )
	aAdd( aBody, { "", "d3cab2e5-45a3-38a5-9587-f61cbdb257c1", "765", "QUACHA ZAMBIA"			, "20130101", "", "ZMW" } )
	aAdd( aBody, { "", "f10159ab-bed4-ceaa-fb7d-35823b3d211f", "766", "QUACHA ZAMBIA"			, "20130101", "", "ZMW" } )
	aAdd( aBody, { "", "6777bf6f-3956-0e6c-9dc5-dabe1b062e4f", "760", "QUACHA/MALAVI"			, "20130101", "", "MWK" } )
	aAdd( aBody, { "", "73020fca-eb38-6b57-f83b-e45748fce4ee", "770", "QUETZAL/GUATEMALA"		, "20130101", "", "GTQ" } )
	aAdd( aBody, { "", "ed3cf90b-1a2f-abc8-f607-31af64fa963a", "775", "QUIATE/BIRMANIA"			, "20130101", "", "MMK" } )
	aAdd( aBody, { "", "af5cd1b1-d675-1315-ad1b-82ff88ad24b6", "780", "QUIPE/LAOS, REP"			, "20130101", "", "LAK" } )
	aAdd( aBody, { "", "b30bc221-cd19-1699-b459-19b6136c1b6a", "785", "RANDE/AFRICA SUL"		, "20130101", "", "ZAR" } )
	aAdd( aBody, { "", "428b6f96-ce36-ebf5-dacd-1ecf03b4404c", "790", "REAL BRASIL"				, "20130101", "", "BRL" } )
	aAdd( aBody, { "", "4a118a18-ba21-bfb3-c6be-bc748af9b864", "795", "RENMIMBI IUAN"			, "20130101", "", "CNY" } )
	aAdd( aBody, { "", "87efd884-b868-8c25-967d-926c154a40a3", "796", "RENMINBI HONG KON"		, "20130101", "", "CNH" } )
	aAdd( aBody, { "", "f8a0012a-c323-172c-08a1-a4e986ef039b", "820", "RIAL/ARAB SAUDITA"		, "20130101", "", "SAR" } )
	aAdd( aBody, { "", "ae96006f-af69-8da9-83b6-1e1c37a71c37", "800", "RIAL/CATAR"				, "20130101", "", "QAR" } )
	aAdd( aBody, { "", "1ed22414-c050-62e2-f757-7e5e326b5adf", "810", "RIAL/IEMEN"				, "20130101", "", "YER" } )
	aAdd( aBody, { "", "ece59a95-1862-e538-404f-35a3e4ccb317", "815", "RIAL/IRAN, REP"			, "20130101", "", "IRR" } )
	aAdd( aBody, { "", "5ff971e6-38ee-8386-838e-ea6507fbff8c", "805", "RIAL/OMA"				, "20130101", "", "OMR" } )
	aAdd( aBody, { "", "8436d147-610d-e41c-ec48-cb54498999d5", "825", "RIEL/CAMBOJA"			, "20130101", "", "KHR" } )
	aAdd( aBody, { "", "cbb81e60-a647-bdc4-67a9-7d5ae9497d90", "828", "RINGGIT/MALASIA"			, "20130101", "", "MYR" } )
	aAdd( aBody, { "", "497b698d-0bc2-1b7c-04cc-c94ac8aa3b79", "829", "RUBLO BELARUS"  			, "20130101", "", "" } )
	aAdd( aBody, { "", "08cf3175-2b0f-8382-7622-52f4ae6df715", "830", "RUBLO/RUSSIA"   			, "20130101", "", "RUB" } )
	aAdd( aBody, { "", "390625bb-e953-ec95-8f13-ed2834f7002d", "870", "RUFIA/MALDIVAS" 			, "20130101", "", "MVR" } )
	aAdd( aBody, { "", "1ae9cd05-f6bb-de6b-77f3-4e3006426775", "860", "RUPIA/INDIA"	   			, "20130101", "", "INR" } )
	aAdd( aBody, { "", "9c557920-6367-d7e9-2f7a-2bf268cb6d44", "865", "RUPIA/INDONESIA"			, "20130101", "", "IDR" } )
	aAdd( aBody, { "", "5801dd6f-f5cc-307c-f1be-080d4a6fb577", "840", "RUPIA/MAURICIO" 			, "20130101", "", "MUR" } )
	aAdd( aBody, { "", "f06142c5-a276-61e5-11d9-9d744405ba04", "845", "RUPIA/NEPAL"    			, "20130101", "", "NPR" } )
	aAdd( aBody, { "", "5bf7b6da-2c0a-0f47-12bf-c923a4a13ebd", "875", "RUPIA/PAQUISTAO"			, "20130101", "", "PKR" } )
	aAdd( aBody, { "", "3f0aff7a-3c2a-ae37-aed4-e995081d0ca7", "850", "RUPIA/SEYCHELES"			, "20130101", "", "SCR" } )
	aAdd( aBody, { "", "38c8d534-cd2f-0120-afae-39e5230a918e", "855", "RUPIA/SRI LANKA"			, "20130101", "", "LKR" } )
	aAdd( aBody, { "", "a0c44f82-43ea-9cdf-3e06-e61ce1e543a2", "880", "SHEKEL/ISRAEL"			, "20130101", "", "ILS" } )
	aAdd( aBody, { "", "855d7b8a-606a-9641-02d2-819fe31a7ab1", "890", "SOL PERUANO"				, "20130101", "", "" } )
	aAdd( aBody, { "", "5141a992-3ed8-aec3-6d10-94fc744125d1", "892", "SOM QUIRGUISTAO"			, "20130101", "", "KGS" } )
	aAdd( aBody, { "", "8a070acc-c01a-b530-41b2-51c85ab7f670", "893", "SOM UZBEQUISTAO"  		, "20130101", "", "UZS" } )
	aAdd( aBody, { "", "f31079fc-f2ff-c3b5-f436-33b2d2019e44", "835", "SOMONI TADJIQUIST"		, "20130101", "", "TJS" } )
	aAdd( aBody, { "", "135f369b-d1f0-8d88-c2ce-40e492a1d26b", "895", "SUCRE EQUADOR"    		, "20130101", "", "" } )
	aAdd( aBody, { "", "ee49fe52-b2e8-1a18-310a-f7a1e8e0ed18", "905", "TACA/BANGLADESH"  		, "20130101", "", "" } )
	aAdd( aBody, { "", "0e2e23d6-db4b-7ddf-473c-135a926e2755", "910", "TALA"					, "20130101", "", "" } )
	aAdd( aBody, { "", "a6ee5562-cd76-dac7-8c14-e24cd73bfcfa", "911", "TALA SAMOA OC"    		, "20130101", "", "WST" } )
	aAdd( aBody, { "", "b2452bb1-28ef-fa4f-941c-cb7568c5609d", "913", "TENGE CAZAQUISTAO"		, "20130101", "", "KZT" } )
	aAdd( aBody, { "", "844487a6-69e7-5010-f84f-cd466853fb2b", "914", "TOLAR/ESLOVENIA"  		, "20130101", "", "" } )
	aAdd( aBody, { "", "2d12a5e5-9322-9854-012e-22c7595cbcc4", "915", "TUGRIK/MONGOLIA"  		, "20130101", "", "MNT" } )
	aAdd( aBody, { "", "e030415c-d80b-063f-c19b-03b66d904bf8", "670", "UGUIA MAURITANIA" 		, "20130101", "", "MRO" } )
	aAdd( aBody, { "", "e52d21a6-faa7-8902-9b3e-d75f7a39c351", "916", "UNID FOMENTO CHIL"		, "20130101", "", "CLF" } )
	aAdd( aBody, { "", "5e0271b9-d74f-6024-f56a-c277b5ca8009", "918", "UNID.MONET.EUROP."		, "20130101", "", "XEU" } )
	aAdd( aBody, { "", "90c3779e-53bd-8877-9b25-e3379ae52782", "920", "VATU VANUATU"			, "20130101", "", "VUV" } )
	aAdd( aBody, { "", "3cb5283e-c126-4f53-539c-b27ea4d6ac20", "930", "WON COREIA SUL"			, "20130101", "", "KRW" } )
	aAdd( aBody, { "", "bffc3ac9-ebb7-fcfa-8f9b-1440e3f38f02", "925", "WON/COREIA NORTE"		, "20130101", "", "KPW" } )
	aAdd( aBody, { "", "36ee5c8f-3704-5916-306f-000a3ecfcea3", "940", "XELIM AUSTRIACO"			, "20130101", "", "" } )
	aAdd( aBody, { "", "fd6a6365-e613-6238-a77a-c6b6d23f8cc9", "945", "XELIM DA TANZANIA"		, "20130101", "", "" } )
	aAdd( aBody, { "", "def1bbaf-d56d-9132-e412-0716886555ac", "950", "XELIM/QUENIA"			, "20130101", "", "KES" } )
	aAdd( aBody, { "", "e1147301-bc80-cb20-a9eb-360358d9729b", "960", "XELIM/SOMALIA"			, "20130101", "", "SOS" } )
	aAdd( aBody, { "", "5736b01c-811d-05b4-0f31-cd788bef1931", "946", "XELIM/TANZANIA"  		, "20130101", "", "TZS" } )
	aAdd( aBody, { "", "a72bf790-c8ce-d4ca-41af-67970bd8291e", "955", "XELIM/UGANDA"    		, "20130101", "", "UGX" } )
	aAdd( aBody, { "", "ff83d9ae-6ce9-02fc-44de-be04c4a36913", "975", "ZLOTY/POLONIA"   		, "20130101", "", "PLN" } )
	aAdd( aBody, { "", "578fb083-8c03-be89-bd48-a140ee84e48d", ""	, "NOVA LIBRA SUDANESA"		, "20140101", "", "SDG" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
