#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA461.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA461
Cadastro MVC dos Países do banco central/SISCOMEX

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA461()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de País do banco central/SISCOMEX
oBrw:SetAlias( 'T5C')
oBrw:SetMenuDef( 'TAFA461' )
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
Return XFUNMnuTAF( "TAFA461" )
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
Local oStruT5C 	:= 	FWFormStruct( 1, 'T5C' )
Local oModel 	:= 	MPFormModel():New( 'TAFA461' )

oModel:AddFields('MODEL_T5C', /*cOwner*/, oStruT5C)

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA461' )
Local 	oStruT5C 	:= 	FWFormStruct( 2, 'T5C' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_T5C', oStruT5C, 'MODEL_T5C' )

oView:EnableTitleView( 'VIEW_T5C', STR0001 ) //Cadastro de Unidade de Medida ANP
oView:CreateHorizontalBox( 'FIELDST5C', 100 )
oView:SetOwnerView( 'VIEW_T5C', 'FIELDST5C' )

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
	aAdd( aHeader, "T5C_FILIAL" )
	aAdd( aHeader, "T5C_ID" )
	aAdd( aHeader, "T5C_CODIGO" )
	aAdd( aHeader, "T5C_CARACT" )
	aAdd( aHeader, "T5C_UNIMED" )
	aAdd( aHeader, "T5C_DATINI" )
	aAdd( aHeader, "T5C_DATFIN" )

	aAdd( aBody, { "", "82b532d3-f49d-c2ff-2c84-d9477bfc566f", "146", "Acidez"                                                                          , ""        	, "200611", "" } )
	aAdd( aBody, { "", "595b59a3-a3de-53ce-6c9e-d629dda14561", "44" , "Acidez total"                                                                    , "mg KOH/g"	, "200409", "" } )
	aAdd( aBody, { "", "677069d1-9147-5871-e76a-d029f95666a9", "32" , "Acidez total (como ácido acético)"                                               , "mg/L"    	, "200409", "" } )
	aAdd( aBody, { "", "f1d7f8f7-c2f7-7e3a-bae2-ee19dcf7a7a2", "19" , "Aditivos"                                                                        , ""        	, "200409", "" } )
	aAdd( aBody, { "", "a50c396f-3f3f-4018-7d2b-f281ff17bc7a", "31" , "Água e Sedimentos"                                                               , "%volume" 	, "200409", "" } )
	aAdd( aBody, { "", "5dbb6c3a-56c0-366d-6afc-fa1bf2965bc1", "81" , "Água Livre"                                                                      , ""        	, "200409", "" } )
	aAdd( aBody, { "", "7f467bc1-3f9c-8c4c-fa14-34dcabde784e", "3"  , "Álcool Etílico Anidro Combustível - AEAC"                                        , "%volume" 	, "200409", "" } )
	aAdd( aBody, { "", "dfc9c5d0-ca34-5b80-6809-f939d4a6cf15", "66" , "Antioxidante"                                                                    , "mg/L"    	, "200409", "" } )
	aAdd( aBody, { "", "5ff0f553-5a3b-653a-2131-1b251bab1d52", "20" , "Aromáticos"                                                                      , "%volume" 	, "200409", "" } )
	aAdd( aBody, { "", "25f5382c-712f-ade6-6b48-cb4abfc1ab72", "45" , "Aromáticos totais"                                                               , "%volume" 	, "200409", "" } )
	aAdd( aBody, { "", "7b5545cc-928c-64e0-b6b6-b69798a61503", "2"  , "Aspecto"                                                                         , ""        	, "200409", "" } )
	aAdd( aBody, { "", "2869fba3-750b-4aa4-766d-1784c8ecc99b", "141", "Aumento do ponto de amolecimento"                                                , "ºC"      	, "200611", "" } )
	aAdd( aBody, { "", "dcaca9f9-e344-abce-07bd-9cec4c14c29f", "17" , "Benzeno"                                                                         , "%volume" 	, "200409", "" } )
	aAdd( aBody, { "", "6a4e03cf-b5d0-0196-0534-d372510c5993", "95" , "Cálcio + Magnésio"                                                               , "mg/Kg"   	, "200501", "" } )
	aAdd( aBody, { "", "ea62e9a4-437b-78f5-c7d8-74e68b3d0dee", "118", "Carga de Partícula"                                                              , ""        	, "200611", "" } )
	aAdd( aBody, { "", "e29fdf3d-be6b-3f78-dc37-5633e5f453b1", "18" , "Chumbo"                                                                          , "g/L"     	, "200409", "" } )
	aAdd( aBody, { "", "b32a4167-2ba5-74b3-3c03-854f446c9807", "153", "Chumbo Tetraetila - CTE"                                                         , "mL/L"    	, "200611", "" } )
	aAdd( aBody, { "", "4abb4b89-d6e4-d1ff-0efc-eb888cf77528", "30" , "Cinzas"                                                                          , "%massa"  	, "200409", "" } )
	aAdd( aBody, { "", "75f9b14a-9c33-7ada-1f0a-2248223be84d", "93" , "Cinzas sulfatadas"                                                               , "%massa"  	, "200501", "" } )
	aAdd( aBody, { "", "bed979d8-6add-4f30-63b4-dabff2588f76", "43" , "Cobre"                                                                           , "mg/Kg"   	, "200409", "" } )
	aAdd( aBody, { "", "9c582faf-8441-a386-1c21-967a4b767f68", "33" , "Condutividade elétrica"                                                          , "mS/m"    	, "200409", "" } )
	aAdd( aBody, { "", "858ecc46-bcff-bcf3-60fc-21aa495aef4f", "149", "Condutividade Elétrica"                                                          , "pS/m"    	, "200611", "" } )
	aAdd( aBody, { "", "96e4bc13-4ae8-0c5c-9210-b979ed3507f1", "1"  , "Cor"                                                                             , ""        	, "200409", "" } )
	aAdd( aBody, { "", "fa7607cb-ecbe-6df2-045b-5e657f2d25d1", "83" , "Cor ASTM"                                                                        , ""        	, "200409", "" } )
	aAdd( aBody, { "", "b8607a4a-2339-67fa-baa9-257b643214b5", "143", "Cor Saybolt"                                                                     , ""        	, "200611", "" } )
	aAdd( aBody, { "", "388093a7-6620-69f9-632b-c4244c8d1190", "154", "Corante"                                                                         , "mg/L"    	, "200611", "" } )
	aAdd( aBody, { "", "b1e87e78-8208-c88d-9ee7-26aa8aa6c05b", "57" , "Corrosividade à prata"                                                           , ""        	, "200409", "" } )
	aAdd( aBody, { "", "ac09aec8-26ab-c0dd-10c3-61581bfa62d4", "77" , "Corrosividade ao Cobre a 37,8ºC 1 hora"                                          , ""        	, "200409", "" } )
	aAdd( aBody, { "", "91d5faf4-59ec-1fcf-eb75-be32650d409f", "15" , "Corrosividade ao Cobre a 50ºC, 3h"                                               , ""        	, "200409", "" } )
	aAdd( aBody, { "", "97f5c6b8-21ad-575f-3206-f24b214a883a", "58" , "Corrosividade ao cobre (2h a 100ºC)"                                             , ""        	, "200409", "" } )
	aAdd( aBody, { "", "dd12e4fe-9863-fbff-6efa-011f4f91bf7c", "89" , "Densidade 20/4ºC"                                                                , ""        	, "200409", "" } )
	aAdd( aBody, { "", "88b1178b-bbae-e63c-12d1-fb153b6dce65", "67" , "Desativador de metal"                                                            , "mg/L"    	, "200409", "" } )
	aAdd( aBody, { "", "e8bbb5db-81b1-1e89-9e61-55bbaf1bc339", "8"  , "Destilação - PFE"                                                                , "ºC"      	, "200409", "" } )
	aAdd( aBody, { "", "800a4269-eaa4-8f55-0720-ba874719ea12", "48" , "Destilação - PIE"                                                                , "ºC"      	, "200409", "" } )
	aAdd( aBody, { "", "977f1df0-f0f6-d2de-1a1c-0bc7b02fb0f9", "160", "Destilação - recuperado"                                                         , "%volume" 	, "200611", "" } )
	aAdd( aBody, { "", "b971bd84-abb1-83c5-f16b-2c856699290e", "9"  , "Destilação - Resíduo."                                                           , "%volume" 	, "200409", "" } )
	aAdd( aBody, { "", "6f3b872b-8834-d763-5d18-8f09f47ae964", "159", "Destilação - soma 10% evaporado + 50% evaporado"                                 , "ºC"      	, "200611", "" } )
	aAdd( aBody, { "", "0777b51a-4b4f-748d-cb4c-c755c406d0a3", "5"  , "Destilação - 10% evaporado"                                                      , "ºC"      	, "200409", "" } )
	aAdd( aBody, { "", "1fb37a40-4553-a420-86c0-b899217faa4d", "49" , "Destilação - 10% vol. Recuperado"                                                , "ºC"      	, "200409", "" } )
	aAdd( aBody, { "", "d6c2c9a6-3424-1f4c-709d-dbd1d91ba22a", "6"  , "Destilação - 50% evaporado"                                                      , "ºC"      	, "200409", "" } )
	aAdd( aBody, { "", "03f92c76-f173-2be2-4087-40587420e624", "23" , "Destilação - 50% vol., recuperado"                                               , "ºC"      	, "200409", "" } )
	aAdd( aBody, { "", "62b0aa82-9d97-0bf4-fa47-33a97985a19b", "147", "Destilação - 80% evaporado"                                                      , "ºC"      	, "200611", "" } )
	aAdd( aBody, { "", "bbda52b8-d2d1-9c30-c134-e40742c03cdb", "24" , "Destilação - 85 % vol., recuperado"                                              , "ºC"      	, "200409", "" } )
	aAdd( aBody, { "", "392c7d73-5eb7-1aaf-bf4b-db094fb250e3", "7"  , "Destilação - 90% evaporado"                                                      , "ºC"      	, "200409", "" } )
	aAdd( aBody, { "", "85ecb02f-facc-7bab-8fc0-e35b6d9e8888", "50" , "Destilação - 90% vol. Recuperado"                                                , "ºC"      	, "200409", "" } )
	aAdd( aBody, { "", "e80540f5-fce3-9bef-c55f-db63bade07d0", "157", "Destilação em 105ºC"                                                             , "%volume" 	, "200611", "" } )
	aAdd( aBody, { "", "6ee644c9-89f5-d1e8-a023-2a9cb69a97cd", "158", "Destilação em 135ºC"                                                             , "%volume" 	, "200611", "" } )
	aAdd( aBody, { "", "e61be5a6-a9b0-d2b7-201f-ffd6b120009d", "125", "Destilação em 190ºC"                                                             , "%volume" 	, "200611", "" } )
	aAdd( aBody, { "", "0a6e6e7f-6b3a-13ae-a7b8-eb1e591ececd", "126", "Destilação em 225ºC"                                                             , "%volume" 	, "200611", "" } )
	aAdd( aBody, { "", "f26f4a2f-25e7-890b-6cbe-9ea8ddfd2ee6", "127", "Destilação em 260ºC"                                                             , "%volume" 	, "200611", "" } )
	aAdd( aBody, { "", "27b983a2-d249-a6f1-b1ae-60f19eb9028c", "128", "Destilação em 316ºC"                                                             , "%volume" 	, "200611", "" } )
	aAdd( aBody, { "", "c60df7ab-326f-ce63-261e-207ee793402d", "130", "Destilação em 360ºC, resíduo por diferença"                                      , "%volume" 	, "200611", "" } )
	aAdd( aBody, { "", "34468aef-0b6b-3572-91d3-6a102c8cdb72", "156", "Destilação em 75ºC"                                                              , "%volume" 	, "200611", "" } )
	aAdd( aBody, { "", "97bd0cfb-335a-9e1b-e439-acdbdc7ff674", "120", "Destilação, resíduo"                                                             , "%massa"  	, "200611", "" } )
	aAdd( aBody, { "", "9e4830d7-64ac-f523-f5bf-b12afef9c256", "119", "Destilação, solvente destilado, %volume sobre o total da emulsão"                , "%volume" 	, "200611", "" } )
	aAdd( aBody, { "", "138682c1-7a53-b264-cee6-799df632d735", "70" , "Detetor de vazamentos"                                                           , "mg/Kg"   	, "200409", "" } )
	aAdd( aBody, { "", "14676cec-e1de-93eb-e46c-0f5fa8525c26", "101", "Diglicerídeos"                                                                   , "%massa"  	, "200501", "" } )
	aAdd( aBody, { "", "b3e05679-54d5-1640-69f2-c15c97853158", "68" , "Dissipador de cargas estáticas"                                                  , "mg/L"    	, "200409", "" } )
	aAdd( aBody, { "", "59c58ce6-28b7-e2c1-60a2-d6bb294edf35", "123", "Ductilidade a 25°C"                                                              , "cm"      	, "200611", "" } )
	aAdd( aBody, { "", "7d427eeb-4b5f-934b-1477-1fd30bf808ae", "111", "Efeito do calor e do ar a 163ºC (RTFOT ou TFOT) - Razão de Viscosidade"          , ""        	, "200611", "" } )
	aAdd( aBody, { "", "a9d007a5-2693-a20f-0e7c-81bf7207cd19", "112", "Efeito do calor e do ar a 163ºC (RTFOT ou TFOT) - Variação de Massa"             , "%massa"  	, "200611", "" } )
	aAdd( aBody, { "", "4c428fa2-392f-39b6-09c0-6b5b830858df", "84" , "Ensaio Doctor"                                                                   , ""        	, "200409", "" } )
	aAdd( aBody, { "", "7678da8c-d585-693f-3918-110677b15a34", "16" , "Enxofre"                                                                         , "%massa"  	, "200409", "" } )
	aAdd( aBody, { "", "96b7f34f-431b-f3fe-9db3-2b62ab99a8ef", "46" , "Enxofre mercaptídico"                                                            , "%massa"  	, "200409", "" } )
	aAdd( aBody, { "", "4b6b256b-bc80-1553-9c14-f63cf0503189", "22" , "Enxofre Total"                                                                   , "%massa"  	, "200409", "" } )
	aAdd( aBody, { "", "64f01f2a-c77a-8c63-d10d-136d60c548a3", "108", "Enxofre Total para GLP"                                                          , "mg/Kg"   	, "200501", "" } )
	aAdd( aBody, { "", "dcda76ce-fac8-6929-1324-78eb815fa187", "107", "Enxofre Total para GN"                                                           , "mg/m³"   	, "200501", "" } )
	aAdd( aBody, { "", "5e5aac6f-f03e-d5e9-8267-0f4fbb011e67", "105", "Estabilidade à oxidação a 110º C"                                                , "h"       	, "200501", "" } )
	aAdd( aBody, { "", "31ac9994-ea04-9dd1-3ef1-4abe6124b361", "163", "Estabilidade à oxidação (16h), chumbo precipitado"                               , "mg/100mL"	, "200611", "" } )
	aAdd( aBody, { "", "139b548f-0000-c21b-0160-155a8ce53bbb", "162", "Estabilidade à oxidação (16h), goma potencial"                                   , "mg/100mL"	, "200611", "" } )
	aAdd( aBody, { "", "5f9d3979-c314-7d6e-999e-1381170e1bae", "145", "Estabilidade térmica a 260ºC"                                                    , ""        	, "200611", "" } )
	aAdd( aBody, { "", "90b4e622-8837-47c5-3a7a-d1d97b61b951", "60" , "Estabilidade térmica a 260ºC - depósito no tubo (visual)"                        , ""        	, "200409", "" } )
	aAdd( aBody, { "", "dedb11cb-a7a2-c376-25a8-486c5f27e0af", "59" , "Estabilidade térmica a 260ºC - queda de pressão no filtro"                       , "mmHg"    	, "200409", "" } )
	aAdd( aBody, { "", "84c08a85-cfcd-1dec-e4ff-21deed0db36d", "41" , "Ferro"                                                                           , "mg/Kg"   	, "200409", "" } )
	aAdd( aBody, { "", "c268c817-a6c5-ea29-84a2-8302d3716346", "96" , "Fósforo"                                                                         , "mg/Kg"   	, "200501", "" } )
	aAdd( aBody, { "", "5742f916-2431-5193-ed2d-0497becafa08", "85" , "Fração hidroprocessada"                                                          , ""        	, "200409", "" } )
	aAdd( aBody, { "", "2c73bcbe-6621-507f-1c18-f2d8ca29a6d9", "47" , "Fração severamente hidroprocessada"                                              , "%volume" 	, "200409", "" } )
	aAdd( aBody, { "", "7909c92b-14d0-1865-f392-ced83b5c5cea", "98" , "Glicerina livre"                                                                 , "%massa"  	, "200501", "" } )
	aAdd( aBody, { "", "29942690-a4c1-ec0a-a9bd-e2b5f9d64147", "99" , "Glicerina total"                                                                 , "%massa"  	, "200501", "" } )
	aAdd( aBody, { "", "9462592e-e7a3-9497-09d2-3aadc2b38d27", "61" , "Goma atual"                                                                      , "mg/100mL"	, "200409", "" } )
	aAdd( aBody, { "", "16644f76-685d-e632-569d-ddcbfd4bac36", "13" , "Goma Atual Lavada"                                                               , "mg/100mL"	, "200409", "" } )
	aAdd( aBody, { "", "dd2a49c4-80fd-ca1a-de4f-e227bca3e689", "76" , "H2S"                                                                             , ""        	, "200409", "" } )
	aAdd( aBody, { "", "64d2ab48-d471-ef5c-f453-fe33ea838443", "11" , "Índice Antidetonante - IAD"                                                      , ""        	, "200409", "" } )
	aAdd( aBody, { "", "4dfc2984-8e76-354c-48df-e455db84891c", "97" , "Índice de acidez"                                                                , "mg KOH/g"	, "200501", "" } )
	aAdd( aBody, { "", "8ad6839f-df67-d561-7306-7b9002d4df53", "106", "Índice de Cetano"                                                                , ""        	, "200501", "" } )
	aAdd( aBody, { "", "da6c5956-8129-5f6b-26c9-50fc0ec0fb2d", "104", "Índice de iodo"                                                                  , ""        	, "200501", "" } )
	aAdd( aBody, { "", "b4ccf083-f294-954c-4838-ab606751b64b", "63" , "Índice de separação de água - Com dissipador de cargas estáticas"                , ""        	, "200409", "" } )
	aAdd( aBody, { "", "2badb5fc-4587-a0b3-50d9-5ab3c143a5a2", "64" , "Índice de separação de água - Sem dissipador de cargas estáticas"                , ""        	, "200409", "" } )
	aAdd( aBody, { "", "133f868d-2a64-7aa3-9984-ad60e44a1576", "138", "Índice de susceptibilidade térmica"                                              , ""        	, "200611", "" } )
	aAdd( aBody, { "", "45ac108a-d6b1-0157-4009-cb4e320bcf01", "69" , "Inibidor de formação de gelo"                                                    , "%volume" 	, "200409", "" } )
	aAdd( aBody, { "", "29211337-1bc4-7a13-682f-03c76d21c797", "38" , "Íon Cloreto"                                                                     , "mg/Kg"   	, "200409", "" } )
	aAdd( aBody, { "", "3c3e16d5-e263-cf49-d435-4f9d38df424c", "40" , "Íon Sulfato"                                                                     , "mg/Kg"   	, "200409", "" } )
	aAdd( aBody, { "", "b13d5a1b-cf54-9595-8ef2-f61a1aba5cb0", "65" , "Lubricidade, BOCLE"                                                              , "mm"      	, "200409", "" } )
	aAdd( aBody, { "", "bdfb9516-f55c-86f5-b0ed-ea8726de1ebb", "4"  , "Massa específica a 20ºC"                                                         , "Kg/m³"   	, "200409", "" } )
	aAdd( aBody, { "", "f83a7c5b-539b-b0f5-800a-8a3674370271", "86" , "Melhorador de Lubricidade"                                                       , ""        	, "200409", "" } )
	aAdd( aBody, { "", "1a83da86-c51f-995b-45ad-e5f4936d273e", "103", "Metanol ou Etanol"                                                               , "%massa"  	, "200501", "" } )
	aAdd( aBody, { "", "100ed790-fcdb-5889-c1db-c371120d73fe", "116", "Mistura com Cimento"                                                             , "%"       	, "200611", "" } )
	aAdd( aBody, { "", "18d0c5c8-29fa-5524-6077-c8108548ef46", "117", "Mistura com Filer Silícico"                                                      , ""        	, "200611", "" } )
	aAdd( aBody, { "", "5804e666-a2f1-bfaa-76e4-4a57dbdf0cb0", "100", "Monoglicerídeos"                                                                 , "%massa"  	, "200501", "" } )
	aAdd( aBody, { "", "6df82956-afd2-29d0-02c3-a3615982d142", "10" , "Nº de Octano Motor - MON."                                                       , ""        	, "200409", "" } )
	aAdd( aBody, { "", "b57365c7-0405-725f-ea05-66c00b70116b", "56" , "Naftalenos"                                                                      , "%volume" 	, "200409", "" } )
	aAdd( aBody, { "", "3e23f201-465c-35d9-c77c-e5e561c2eee7", "28" , "Número de Cetano"                                                                , ""        	, "200409", "" } )
	aAdd( aBody, { "", "b46b48c5-a12b-6fd5-b1da-e10f8483e2f6", "82" , "Odorização"                                                                      , ""        	, "200409", "" } )
	aAdd( aBody, { "", "6039a00e-774e-1359-7951-f542372d5f0a", "21" , "Olefínicos"                                                                      , "%volume" 	, "200409", "" } )
	aAdd( aBody, { "", "ded7a6d3-1744-0c82-3065-516845206cff", "144", "Partículas Contaminantes"                                                        , "mg/L"    	, "200611", "" } )
	aAdd( aBody, { "", "209e6e1a-c56e-1ebf-a833-b41b1c23024e", "115", "Peneiração (retido na peneira n° 20 - 0,84 mm)"                                  , "%"       	, "200611", "" } )
	aAdd( aBody, { "", "45e40878-cf9f-4dd9-1e62-0a4addd9f8cf", "142", "Penetração retida"                                                               , "%"       	, "200611", "" } )
	aAdd( aBody, { "", "d822289e-0ff8-b679-a687-7b5f659ffe08", "121", "Penetração (100g, 5s e 25°C)"                                                    , "0,1 mm"  	, "200611", "" } )
	aAdd( aBody, { "", "5332e933-29e1-d5a3-076b-922cd672e3af", "51" , "Perda"                                                                           , "%volume" 	, "200409", "" } )
	aAdd( aBody, { "", "660dc851-263f-2f3e-386d-253a76aee014", "14" , "Período de Indução a 100ºC"                                                      , "min"     	, "200409", "" } )
	aAdd( aBody, { "", "1b97aee8-8536-476a-81a9-08226acad7ae", "151", "Poder antidetonante, mistura pobre, método aviação, índice de desempenho"        , ""        	, "200611", "" } )
	aAdd( aBody, { "", "98eb70c7-e762-6112-3ed7-a2b978952955", "150", "Poder antidetonante, mistura pobre, método aviação, índice de octano"            , ""        	, "200611", "" } )
	aAdd( aBody, { "", "f347d7e9-4008-76c3-4ec8-bc1fc80f8d19", "152", "Poder antidetonante, mistura rica, método superalimentação, índice de desempenho", ""        	, "200611", "" } )
	aAdd( aBody, { "", "30652f70-8d66-219a-f785-f2f48f9eb64a", "54" , "Poder calorífico inferior"                                                       , "MJ/Kg"   	, "200409", "" } )
	aAdd( aBody, { "", "a7a46f63-4aff-6ede-4006-2f13f90e0a91", "131", "Ponto de amolecimentoºC"                                                         , "ºC"      	, "200611", "" } )
	aAdd( aBody, { "", "0bb2ff08-f35d-291e-a42f-41b9045c012b", "52" , "Ponto de Congelamento"                                                           , "ºC"      	, "200409", "" } )
	aAdd( aBody, { "", "cf805457-afc9-06e3-da1b-617985c72c7d", "27" , "Ponto de Entupimento de Filtro à Frio"                                           , "ºC"      	, "200409", "" } )
	aAdd( aBody, { "", "fad2fbea-987b-7648-7f64-f01afad3f484", "90" , "Ponto de Fluidez Superior"                                                       , "ºC"      	, "200409", "" } )
	aAdd( aBody, { "", "d62287bc-e6c1-ddab-743f-ef7a0c3446aa", "25" , "Ponto de Fulgor"                                                                 , "ºC"      	, "200409", "" } )
	aAdd( aBody, { "", "1eb0f1c6-54ec-6020-6938-c7a3dc06d957", "55" , "Ponto de fuligem"                                                                , "mm"      	, "200409", "" } )
	aAdd( aBody, { "", "19d4e4f1-79a5-7664-d3fe-88412385c343", "35" , "Potencial hidrogeniônico (pH)"                                                   , ""        	, "200409", "" } )
	aAdd( aBody, { "", "d00af124-0fd2-6a3c-77f5-84fd97bbda69", "12" , "Pressão de Vapor a 37,8 ºC"                                                      , "KPa"     	, "200409", "" } )
	aAdd( aBody, { "", "fcc8d678-9e8d-ebbc-f48e-3090552506b5", "161", "Pressão de vapor Reid"                                                           , "KPa"     	, "200611", "" } )
	aAdd( aBody, { "", "3b515154-96b9-d74b-7112-1ce0da7fba4c", "155", "Produto do Ponto de anilina x densidade"                                         , ""        	, "200611", "" } )
	aAdd( aBody, { "", "02b32eed-7c25-6999-d909-cdd3fd4d604a", "78" , "Propano"                                                                         , "%volume" 	, "200409", "" } )
	aAdd( aBody, { "", "a83974a9-596b-8bad-93ab-8050fb3d7134", "79" , "Propeno"                                                                         , "%volume" 	, "200409", "" } )
	aAdd( aBody, { "", "7a2b5f9b-ecd7-5287-9772-9b9097f147b4", "109", "Resíduo de carbono dos 100% destilados"                                          , "%massa"  	, "200501", "" } )
	aAdd( aBody, { "", "8a8f1c73-76fe-ba2a-a8a0-01fa2837ac67", "29" , "Resíduo de Carbono Ramsbottom no Resíduo dos 10% finais da Destilação"           , "%massa"  	, "200409", "" } )
	aAdd( aBody, { "", "1316c2ae-0c2e-6764-55ef-cf4e7a77a207", "36" , "Resíduo por evaporação"                                                          , "mg/100mL"	, "200409", "" } )
	aAdd( aBody, { "", "3aadb354-4c03-1ba1-8e3b-f69563c96700", "72" , "Resíduo volátil - Butanos e mais pesados"                                        , "%volume "	, "200409", "" } )
	aAdd( aBody, { "", "af32ae36-4e60-9c6a-269e-94df5a95e58f", "73" , "Resíduo volátil - Pentanos e mais pesados"                                       , "%volume "	, "200409", "" } )
	aAdd( aBody, { "", "c48f0e7d-5510-5008-97e0-6ba30f7f6322", "71" , "Resíduo volátil - Ponto de Ebulição 95% evaporados"                              , "ºC"      	, "200409", "" } )
	aAdd( aBody, { "", "381c1215-d00d-b8af-ba28-3c0485f3194d", "74" , "Resíduo, 100 ml evaporados"                                                      , "mL"      	, "200409", "" } )
	aAdd( aBody, { "", "1370321f-8580-1f93-edb2-fa6a9c42fe42", "114", "Sedimentação, 5 dias por diferença"                                              , "%"       	, "200611", "" } )
	aAdd( aBody, { "", "7ee4006d-44a3-fd0c-c887-552ab8fde94d", "42" , "Sódio"                                                                           , "mg/Kg"   	, "200409", "" } )
	aAdd( aBody, { "", "d252acbe-3ddb-676f-3e2a-5c18b797ec50", "94" , "Sódio + Potássio."                                                               , "mg/Kg"   	, "200501", "" } )
	aAdd( aBody, { "", "dc61eb91-ffed-ebbd-5df9-61d289c58b84", "139", "Solubilidade em tricoroetileno"                                                  , "%massa"  	, "200611", "" } )
	aAdd( aBody, { "", "9f91a741-6a2e-4558-4439-f102b13c56ee", "34" , "Teor alcoólico"                                                                  , "ºINPM"   	, "200409", "" } )
	aAdd( aBody, { "", "d02fcc02-9088-a701-eea9-fd5da4626421", "129", "Teor de água"                                                                    , "%volume" 	, "200611", "" } )
	aAdd( aBody, { "", "0f99d83c-6f62-44b4-3ed3-8ec921600030", "122", "Teor de Betume"                                                                  , "%massa"  	, "200611", "" } )
	aAdd( aBody, { "", "5cc7bb51-8234-afcd-bdea-7e7f368ff246", "92" , "Teor de éster"                                                                   , "%massa"  	, "200501", "" } )
	aAdd( aBody, { "", "342efb42-3f9b-a9c6-21a8-73492123015b", "39" , "Teor de etanol"                                                                  , "%volume" 	, "200409", "" } )
	aAdd( aBody, { "", "bd199744-9572-d575-85f5-4f40d5ecb72d", "37" , "Teor de hidrocarbonetos"                                                         , "%volume" 	, "200409", "" } )
	aAdd( aBody, { "", "e81dcfed-9768-b5c0-0ac3-c5f0432fc976", "110", "Teor de Saturados"                                                               , "%massa"  	, "200611", "" } )
	aAdd( aBody, { "", "ca117e52-38a7-7cd4-3b57-a3b850e8bebb", "75" , "Teste da Mancha"                                                                 , ""        	, "200409", "" } )
	aAdd( aBody, { "", "401741b6-9346-a293-668a-f14da184098e", "164", "Tolerância à água - condições de separação"                                      , ""        	, "200611", "" } )
	aAdd( aBody, { "", "0de95cff-4831-6995-4491-cd2f091e607d", "62" , "Tolerância à água - condições interfaciais, máx."                                , ""        	, "200409", "" } )
	aAdd( aBody, { "", "0d43b732-b6de-f13d-ff12-36b0714c170b", "165", "Tolerância à água - mudança de volume"                                           , "mL"      	, "200611", "" } )
	aAdd( aBody, { "", "dd4e6364-ad70-2c7a-b4a2-f937aac9e9a8", "102", "Triglicerídeos"                                                                  , "%massa"  	, "200501", "" } )
	aAdd( aBody, { "", "de4d9836-b15d-9557-ffbb-7c1ed0f45b01", "80" , "Umidade"                                                                         , ""        	, "200409", "" } )
	aAdd( aBody, { "", "2037fa2e-8209-80b1-28c8-236c872e8933", "91" , "Vanádio"                                                                         , "mg/Kg"   	, "200409", "" } )
	aAdd( aBody, { "", "9c95741c-cf65-cc78-41e6-51a58c2d5633", "140", "Variação em massa"                                                               , "%massa"  	, "200611", "" } )
	aAdd( aBody, { "", "5814341c-27bf-5c70-dbaf-cf1531b6df4a", "53" , "Viscosidade a -20ºC"                                                             , "(mm2/s)cst"	, "200409", "" } )
	aAdd( aBody, { "", "9ce028be-5f07-2ad9-fceb-cb9ed2c1c6dd", "148", "Viscosidade a 20ºC"                                                              , "(mm2/s)cst"	, "200611", "" } )
	aAdd( aBody, { "", "cb0f8ed9-4427-38db-25c6-0ddb03931c74", "26" , "Viscosidade a 40°C"                                                              , "(mm2/s)cst"	, "200409", "" } )
	aAdd( aBody, { "", "eb0c4395-2f50-8f8d-c82a-d58478e25954", "135", "Viscosidade Brookfield a 135ºC, SP 21"                                           , "cP"        	, "200611", "" } )
	aAdd( aBody, { "", "b24ac1ec-f04f-8763-e305-1942bb6af7a1", "136", "Viscosidade Brookfield a 150ºC, SP 21"                                           , "cP"        	, "200611", "" } )
	aAdd( aBody, { "", "0317f070-6c8f-63ae-ace6-8265280fe2ae", "137", "Viscosidade Brookfield a 177ºC, SP 21"                                           , "cP"        	, "200611", "" } )
	aAdd( aBody, { "", "cfd24c6a-c678-e5b3-1ef7-c33814b85987", "87" , "Viscosidade Cinemática a 60ºC"                                                   , "(mm2/s)cst"	, "200409", "" } )
	aAdd( aBody, { "", "6d7e3a35-1996-e0dd-d13d-d3db8bb35f31", "132", "Viscosidade Saybolt Furol a 135°C"                                               , "SSF"       	, "200611", "" } )
	aAdd( aBody, { "", "460f1cc0-7f54-1e8f-ac08-e768d3a2fc80", "133", "Viscosidade Saybolt Furol a 150°C"                                               , "SSF"       	, "200611", "" } )
	aAdd( aBody, { "", "2c1e84f8-dc99-0427-5430-bee70056afb3", "134", "Viscosidade Saybolt Furol a 177°C"                                               , "SSF"       	, "200611", "" } )
	aAdd( aBody, { "", "e6e20d81-8956-b857-9b1d-e8603dc133c2", "113", "Viscosidade Saybolt Furol a 25°C"                                                , "SSF"       	, "200611", "" } )
	aAdd( aBody, { "", "a64fa046-47db-b122-96c6-dae20c6b1a4e", "124", "Viscosidade Saybolt Furol a 60ºC"                                                , "%volume"   	, "200611", "" } )
	aAdd( aBody, { "", "57a2c79d-e6c8-e120-7a24-da94b127ea7e", "88" , "Viscosidade Saybolt Furola a 50ºC"                                               , "SSF"       	, "200409", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )