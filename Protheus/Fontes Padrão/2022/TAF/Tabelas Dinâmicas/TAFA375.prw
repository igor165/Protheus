#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA375.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA375
Cadastro MVC de Unidade de Medida ECF

@author Evandro dos Santos Oliveira	
@since 19/01/2015
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA375()

Local	oBrw := FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Cadastro de Unidade de Medida ECF" 
oBrw:SetAlias( 'CHJ')
oBrw:SetMenuDef( 'TAFA375' )
CHJ->(dbSetOrder(2))
oBrw:Activate()

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Evandro dos Santos Oliveira	
@since 19/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA375" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Evandro dos Santos Oliveira	
@since 19/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCHJ 	:= 	FWFormStruct( 1, 'CHJ' )
Local oModel 	:= 	MPFormModel():New( 'TAFA375' )

oModel:AddFields('MODEL_CHJ', /*cOwner*/, oStruCHJ)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Evandro dos Santos Oliveira	
@since 19/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local 	oModel 	:= 	FWLoadModel( 'TAFA375' )
Local 	oStruCHJ 	:= 	FWFormStruct( 2, 'CHJ' )
Local 	oView 		:= 	FWFormView():New()


oStruCHJ:RemoveField('CHJ_ID') //Remove o campo da view
oView:SetModel( oModel )
oView:AddField( 'VIEW_CHJ', oStruCHJ, 'MODEL_CHJ' )

oView:EnableTitleView( 'VIEW_CHJ', STR0001 )	//"Cadastro de Unidade de Medida ECF"
oView:CreateHorizontalBox( 'FIELDSCHJ', 100 )
oView:SetOwnerView( 'VIEW_CHJ', 'FIELDSCHJ' )

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

nVerAtu := 1007.08

If nVerEmp < nVerAtu
	aAdd( aHeader, "CHJ_FILIAL" )
	aAdd( aHeader, "CHJ_ID" )
	aAdd( aHeader, "CHJ_CODIGO" )
	aAdd( aHeader, "CHJ_DESCRI" )
	aAdd( aHeader, "CHJ_DTINI" )
	aAdd( aHeader, "CHJ_DTFIN" )

	aAdd( aBody, { "", "eca7b8e6-321c-cc8c-499b-850d0fdd0105", "01", "BILHÃO DE UNIDADE INTERNACIONAL", "20130101", "" } )
	aAdd( aBody, { "", "08a0c9b9-0cdc-b295-5db5-2a82998bf265", "02", "DÚZIA", "20130101", "" } )
	aAdd( aBody, { "", "2e614cca-c33a-f91e-8b0f-818fcf03584e", "03", "GRAMA", "20130101", "" } )
	aAdd( aBody, { "", "4b65b406-4aaf-dc3a-c31a-43e6dba92397", "04", "LITRO", "20130101", "" } )
	aAdd( aBody, { "", "5721d60e-ad85-94a9-3acd-a7bdbc8065bf", "05", "MEGAWATT HORA", "20130101", "" } )
	aAdd( aBody, { "", "b40388ae-39f7-6265-1e37-56120a0d2721", "06", "METRO", "20130101", "" } )
	aAdd( aBody, { "", "dc295a3c-1335-ca8d-9da6-017b93447d2b", "07", "METRO CÚBICO", "20130101", "" } )
	aAdd( aBody, { "", "aa6b01ab-6474-3ca6-2c1b-0d4e7132c4a4", "08", "METRO QUADRADO", "20130101", "" } )
	aAdd( aBody, { "", "adf71e1e-516e-0ec1-c4ee-3a0ac5e434b4", "09", "MIL UNIDADES", "20130101", "" } )
	aAdd( aBody, { "", "b80d9268-ebf6-8d85-277c-b9f5ace55da2", "10", "PARES", "20130101", "" } )
	aAdd( aBody, { "", "76f176e2-4034-20c9-d1c5-2dc6e74cbeaa", "11", "QUILATE", "20130101", "" } )
	aAdd( aBody, { "", "049bc839-2f64-475b-13e4-43befbb60231", "12", "QUILOGRAMA BRUTO", "20130101", "" } )
	aAdd( aBody, { "", "2befe8c8-3fdf-6c8e-656a-d5bcfcea17fd", "13", "QUILOGRAMA LÍQUIDO", "20130101", "" } )
	aAdd( aBody, { "", "96ca2aaa-dc80-5cf4-731e-b450deda3551", "14", "TONELADA MÉTRICA LÍQUIDA", "20130101", "" } )
	aAdd( aBody, { "", "ae3baf73-48f3-fce0-b27a-18cd14078e9a", "15", "UNIDADE", "20130101", "" } )
	aAdd( aBody, { "", "a57c7a9e-4016-a9b9-cd87-edbc86434af9", "16", "TAMBOR", "20150101", "" } )
	aAdd( aBody, { "", "f2652c8f-fa0f-4886-cbf8-9e8af893e7a4", "17", "CAIXA", "20150101", "" } )
	aAdd( aBody, { "", "60923e15-6db8-2a59-a755-586f25a53180", "18", "MILÍMETRO", "20150101", "" } )
	aAdd( aBody, { "", "b31a28a7-7a62-0a33-c2a1-bb7d32bdd65b", "19", "MILILITRO", "20150101", "" } )
	aAdd( aBody, { "", "3b7067d0-6af5-cda8-0539-c73b278effda", "20", "GALÃO", "20150101", "" } )
	aAdd( aBody, { "", "e02fe3c8-bec1-2717-59a3-8e59967bd523", "21", "BOBINA", "20150101", "" } )
	aAdd( aBody, { "", "4897b710-3c29-f186-f084-2118ef6d306a", "22", "BALDE", "20150101", "" } )
	aAdd( aBody, { "", "7e6139b3-3e59-7e29-623f-2239e9e54e36", "23", "DEZENA", "20150101", "" } )
	aAdd( aBody, { "", "7d45b0cf-1e93-192a-ebc9-336ffb697287", "24", "SACO", "20150101", "" } )
	aAdd( aBody, { "", "81f30ee4-d844-0929-5b10-8d27b012570c", "25", "FARDO", "20150101", "" } )
	aAdd( aBody, { "", "c602f46a-ba40-ba27-984c-5913a0d1e9cb", "26", "BARRICA", "20150101", "" } )
	aAdd( aBody, { "", "50eac5fe-21b5-d2db-d672-0df55bae4f6b", "27", "PACOTE", "20150101", "" } )
	aAdd( aBody, { "", "b08b6f1d-731b-37db-20f2-ae61dca81e04", "28", "LATA", "20150101", "" } )
	aAdd( aBody, { "", "5078b1cf-f414-002d-c259-73a9ed1fbd61", "29", "CARTELA", "20150101", "" } )
	aAdd( aBody, { "", "2dd30353-ae65-7cb8-a698-8b7b160d427b", "30", "CENTO", "20150101", "" } )
	aAdd( aBody, { "", "705e67ad-b36e-9fa2-45e7-70db21f541d1", "31", "JOGO", "20150101", "" } )
	aAdd( aBody, { "", "c38e061d-525e-4b6b-3a11-916c888c227e", "32", "CABEÇA", "20150101", "" } )
	aAdd( aBody, { "", "b6d054dc-cf2a-e5a8-430c-7839e4c634d5", "33", "PEÇAS", "20150101", "" } )
	aAdd( aBody, { "", "3d181259-b682-b5b5-5453-38ab5177a953", "34", "BANDEJA", "20150101", "" } )
	aAdd( aBody, { "", "2c04f28a-b0ed-4a79-81e2-3aebebce47f9", "35", "LIBRAS", "20150101", "" } )
	aAdd( aBody, { "", "85777fa7-3943-61a8-f62c-7db9a8b11614", "36", "GROZA", "20150101", "" } )
	aAdd( aBody, { "", "ab2ca275-d9a6-0980-2ffd-3575813f8453", "37", "CONTAINER", "20150101", "" } )
	aAdd( aBody, { "", "d4b31446-7cb2-f8d3-65b5-0db27762cdf1", "39", "PLACA", "20150101", "" } )
	aAdd( aBody, { "", "70ed7f28-e4ed-f490-79bd-b56d15d260eb", "40", "ROLO", "20150101", "" } )
	aAdd( aBody, { "", "01ce06c8-4eb3-b256-40fc-65499d573241", "41", "PÉS", "20150101", "" } )
	aAdd( aBody, { "", "39210f3c-9704-fa32-61e1-db4689192ac1", "42", "BLOCO", "20150101", "" } )
	aAdd( aBody, { "", "bd91766e-f883-f00f-54b9-9a8b87f41ae0", "43", "FRASCO", "20150101", "" } )
	aAdd( aBody, { "", "35109282-80e0-3538-3347-aff9a6ea5ea8", "44", "GRANEL", "20150101", "" } )
	aAdd( aBody, { "", "8cbdbfbe-8f86-a826-fcf3-6cf8b5ca3e60", "45", "TUBO", "20150101", "" } )
	aAdd( aBody, { "", "5a1f3b74-41b0-d4a5-c1e9-89933cf66fa0", "46", "GRAMAS POR LITRO", "20150101", "" } )
	aAdd( aBody, { "", "df1eff2e-8fb3-a6a0-ff5b-315862883b92", "47", "KIT", "20150101", "" } )
	aAdd( aBody, { "", "c400bf24-f0fd-1831-4203-9f74a8799743", "48", "MAÇO", "20150101", "" } )
	aAdd( aBody, { "", "45e8390c-7543-3471-6143-fc7909225d1a", "49", "ESTIVADO", "20150101", "" } )
	aAdd( aBody, { "", "e630b591-6577-b9c1-ccf2-18ef154f41fa", "50", "RESMA", "20150101", "" } )
	aAdd( aBody, { "", "c6d01fe0-e948-783e-b12a-d84cf2078b4c", "51", "VARA", "20150101", "" } )
	aAdd( aBody, { "", "7d047366-9355-d5c0-06be-dc2d762a77cf", "52", "FOLHA", "20150101", "" } )
	aAdd( aBody, { "", "8604c38a-c136-62f7-f2e8-1f6e723f7fee", "53", "CONE", "20150101", "" } )
	aAdd( aBody, { "", "ce4b13f9-e0f0-be77-ad35-95009d736132", "54", "CONJUNTO", "20150101", "" } )
	aAdd( aBody, { "", "f03dd140-57e3-a1a0-02b5-4d17b546bfb5", "55", "BARRA", "20150101", "" } )
	aAdd( aBody, { "", "8e9fa2b7-8a75-7315-41b0-caff09eb7dc2", "56", "BAR", "20150101", "" } )
	aAdd( aBody, { "", "4edd89d4-872f-7a47-bd3c-08e684afae48", "57", "POTE", "20150101", "" } )
	aAdd( aBody, { "", "826472d4-8c46-f762-3937-953b0f2548e5", "58", "GARRAFA", "20150101", "" } )
	aAdd( aBody, { "", "d5deda2d-91ea-d3aa-ca73-4f52025125a8", "59", "PEDAÇO", "20150101", "" } )
	aAdd( aBody, { "", "86f4110c-74f8-2d8c-f644-a56b1fd7698c", "60", "TABLETE", "20150101", "" } )
	aAdd( aBody, { "", "b6bb3eb6-4f93-9a97-0d48-b1d17f989f41", "61", "TAÇA", "20150101", "" } )
	aAdd( aBody, { "", "d3c50c36-015b-74df-81fb-591db5243365", "62", "QUILÔMETRO", "20150101", "" } )
	aAdd( aBody, { "", "65b28698-e425-43bb-aa1f-b734aef5849b", "63", "VOLUME", "20150101", "" } )
	aAdd( aBody, { "", "176d9bc0-884a-fb6b-7b95-9f3d1d81170a", "64", "HECTARES", "20150101", "" } )
	aAdd( aBody, { "", "5f19e1ec-567c-9fab-2f32-eb165a710ac6", "65", "MILIGRAMA", "20150101", "" } )
	aAdd( aBody, { "", "a77d5ba3-3c28-1016-ff94-69c21a26ba71", "66", "MILIVOLT", "20150101", "" } )
	aAdd( aBody, { "", "ab438854-eb3f-4c4f-c748-2730ddc85c87", "67", "MILIWATT", "20150101", "" } )
	aAdd( aBody, { "", "cd3bf6e7-6086-5428-74d0-d6211b5d1239", "68", "QUILOVOLT", "20150101", "" } )
	aAdd( aBody, { "", "83293fe7-e6bc-3ac1-9fef-d16456e0e6a6", "69", "VOLT", "20150101", "" } )
	aAdd( aBody, { "", "4d522b32-362a-7424-b3b0-82d9baa2f26f", "70", "WATT", "20150101", "" } )
	aAdd( aBody, { "", "030f66bf-4d91-a4d7-45c9-2bfe12e48081", "71", "AMPERES", "20150101", "" } )
	aAdd( aBody, { "", "bdf7eb1c-e9d2-5edb-ad7d-5c449dcbe06c", "72", "JARDAS", "20150101", "" } )
	aAdd( aBody, { "", "dba0ec41-6e52-5f24-99f4-e66df3fd8ae7", "73", "DOSE", "20150101", "" } )		
	aAdd( aBody, { "", "cb2fe6bd-8a1a-766e-26ac-3fccf067d791", "74", "OUTRAS", "20130101", "" } )
	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )