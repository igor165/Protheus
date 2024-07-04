#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA464.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA464
Cadastro MVC dos Países do banco central/SISCOMEX

@author Marcos.Vecki	
@since 24/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA464()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Aferição ANP
oBrw:SetAlias( 'T5F')
oBrw:SetMenuDef( 'TAFA464' )
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
Return XFUNMnuTAF( "TAFA464" )
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
Local oStruT5F 	:= 	FWFormStruct( 1, 'T5F' )
Local oModel 	:= 	MPFormModel():New( 'TAFA464' )

oModel:AddFields('MODEL_T5F', /*cOwner*/, oStruT5F)

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA464' )
Local 	oStruT5F 	:= 	FWFormStruct( 2, 'T5F' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_T5F', oStruT5F, 'MODEL_T5F' )

oView:EnableTitleView( 'VIEW_T5F', STR0001 ) //Cadastro de Aferição ANP
oView:CreateHorizontalBox( 'FIELDST5F', 100 )
oView:SetOwnerView( 'VIEW_T5F', 'FIELDST5F' )

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
	aAdd( aHeader, "T5F_FILIAL" )
	aAdd( aHeader, "T5F_ID" )
	aAdd( aHeader, "T5F_CODIGO" )
	aAdd( aHeader, "T5F_METODO" )
	aAdd( aHeader, "T5F_DATINI" )
	aAdd( aHeader, "T5F_DATFIN" )

	aAdd( aBody, { "", "53cb456e-cc06-2828-acd6-4ca8f6a48e9c", "215", "ABNT/MB 104"	  	, "200611", "" 			} )
	aAdd( aBody, { "", "3f642898-3eb7-2634-725a-ded7cafd91e0", "230", "ABNT/MB 162"   	, "200611", "" 			} )
	aAdd( aBody, { "", "47777728-7406-b91a-387d-d43889b6ef12", "114", "ABNT/MB 205"   	, "200409", "" 			} )
	aAdd( aBody, { "", "b7b6f114-69bb-0972-cdf0-d63654b3a538", "233", "ABNT/MB 237"   	, "200611", "" 			} )
	aAdd( aBody, { "", "95ea59f7-7baa-3c7b-cacb-c8304352c7a5", "116", "ABNT/MB 281"   	, "200409", "" 			} )
	aAdd( aBody, { "", "885d638a-cf73-995a-bc03-b6d7cd5ea7e3", "118", "ABNT/MB 282"   	, "200409", "" 			} )
	aAdd( aBody, { "", "481e3d12-3be9-6712-6492-61d6bbe592e0", "115", "ABNT/MB 285"   	, "200409", "" 			} )
	aAdd( aBody, { "", "72018fc4-da98-0091-ee60-13b4101be9d5", "214", "ABNT/MB 287"   	, "200611", "" 			} )
	aAdd( aBody, { "", "89f37ab5-9ac1-f912-f186-2e1e68bdd161", "234", "ABNT/MB 289"   	, "200611", "" 			} )
	aAdd( aBody, { "", "e6d01a90-371e-021f-ec14-2481538a04ad", "219", "ABNT/MB 293"   	, "200611", "" 			} )
	aAdd( aBody, { "", "84e11460-6ddc-df55-6df4-fb5d549e534f", "127", "ABNT/MB 294"   	, "200409", "" 			} )
	aAdd( aBody, { "", "7e33591a-842b-9c1e-721b-3e73a64fcf7e", "218", "ABNT/MB 295"   	, "200611", "" 			} )
	aAdd( aBody, { "", "8763be98-304e-039d-b230-e08ccf07cf19", "213", "ABNT/MB 296"   	, "200611", "" 			} )
	aAdd( aBody, { "", "3af60442-1fcb-0395-f04e-ae2a1c145ba0", "229", "ABNT/MB 299"   	, "200611", "" 			} )
	aAdd( aBody, { "", "38abe918-358a-a474-5e95-96485de376bf", "124", "ABNT/MB 326"   	, "200409", "" 			} )
	aAdd( aBody, { "", "99bcec42-3673-6210-bf08-939f4e8b537c", "220", "ABNT/MB 327"   	, "200611", "" 			} )
	aAdd( aBody, { "", "0e682130-7d55-7074-a9f5-4b769b641f94", "126", "ABNT/MB 37"    	, "200409", "" 			} )
	aAdd( aBody, { "", "63c994a8-4971-6607-b7ad-09cadf38dce4", "217", "ABNT/MB 42"    	, "200611", "" 			} )
	aAdd( aBody, { "", "84e1094d-370d-3f24-3e2c-84df19e5f3a0", "84" , "ABNT/MB 424"   	, "200409", "" 			} )
	aAdd( aBody, { "", "46b47722-ac6e-f753-3c99-9e43872e45da", "170", "ABNT/MB 425"   	, "200611", "" 			} )
	aAdd( aBody, { "", "94c32952-09d0-7df0-e508-02ecf9280e19", "190", "ABNT/MB 43"    	, "200611", "" 			} )
	aAdd( aBody, { "", "62e1935e-c52c-1f44-b90f-958d4af71f47", "216", "ABNT/MB 45"    	, "200611", "" 			} )
	aAdd( aBody, { "", "e0cf4752-2630-1c2e-ac69-9324b67e6fab", "235", "ABNT/MB 452"   	, "200611", "" 			} )
	aAdd( aBody, { "", "0c086e6c-b438-d607-7673-cf446e957740", "76" , "ABNT/MB 457"   	, "200409", "" 			} )
	aAdd( aBody, { "", "6230d86f-08b4-454d-2185-96ba104226d2", "128", "ABNT/MB 48"    	, "200409", "" 			} )
	aAdd( aBody, { "", "8c7a5dcd-5518-1963-f4e9-504aaacbb794", "169", "ABNT/MB 826"   	, "200611", "" 			} )
	aAdd( aBody, { "", "227a3572-d74f-a653-c9b1-87f72c3a3874", "125", "ABNT/MB 902"   	, "200409", "" 			} )
	aAdd( aBody, { "", "d3b62b97-bb63-47b9-ac23-05695e2a7ae8", "117", "ABNT/MB 903"   	, "200409", "" 			} )
	aAdd( aBody, { "", "e2180397-3ff8-56b4-fa05-b0c74a0becdd", "104", "ABNT/NBR 10422"	, "200409", "" 			} )
	aAdd( aBody, { "", "c007a15c-bf47-aa1b-23fa-642a7a49b225", "89" , "ABNT/NBR 10441"	, "200409", "" 			} )
	aAdd( aBody, { "", "fbcb3e5c-45b3-8221-95e5-4faa26adc8a3", "95" , "ABNT/NBR 10547"	, "200409", "" 			} )
	aAdd( aBody, { "", "88c3c1c0-c1b8-3c4e-1ab5-2bdf43714b93", "97" , "ABNT/NBR 10891"	, "200409", "" 			} )
	aAdd( aBody, { "", "b8c57b7a-b6c5-a95f-c9a6-62db8d733360", "105", "ABNT/NBR 10893"	, "200409", "" 			} )
	aAdd( aBody, { "", "ae2665de-c491-d558-c0cc-a0101ece6d4a", "100", "ABNT/NBR 10894"	, "200409", "" 			} )
	aAdd( aBody, { "", "ba61f273-83b8-9280-d370-1b21edffc588", "101", "ABNT/NBR 10895"	, "200409", "" 			} )
	aAdd( aBody, { "", "cbae2115-cb87-0812-e8f7-69ac1e5a54a9", "111", "ABNT/NBR 1109" 	, "200409", "" 			} )
	aAdd( aBody, { "", "d72610ce-28ea-c7c5-4452-18a75a3f92a9", "103", "ABNT/NBR 11331"	, "200409", "" 			} )
	aAdd( aBody, { "", "ff2615d8-c6ea-d433-6e4b-88d346f0bd07", "171", "ABNT/NBR 11341"	, "200611", "" 			} )
	aAdd( aBody, { "", "78b4db4b-5944-8664-88ac-5a2a18e03504", "129", "ABNT/NBR 11349"	, "200409", "" 			} )
	aAdd( aBody, { "", "97880c72-4f8f-9c63-5ff8-672bec97a3d7", "110", "ABNT/NBR 11909"	, "200409", "" 			} )
	aAdd( aBody, { "", "a79437c8-edba-4d4d-661f-d4f1a69b3d61", "102", "ABNT/NBR 12120"	, "200409", "" 			} )
	aAdd( aBody, { "", "1cd127ae-cb87-c871-273f-487fb5deebac", "72" , "ABNT/NBR 13992"	, "200409", "" 			} )
	aAdd( aBody, { "", "684d935e-a634-100d-1af3-ed31aa613f5a", "99" , "ABNT/NBR 13993"	, "200409", "" 			} )
	aAdd( aBody, { "", "0f041260-4203-dcd1-7215-8d6f4073948b", "74" , "ABNT/NBR 14065"	, "200409", "" 			} )
	aAdd( aBody, { "", "c43bf484-25a9-70d0-7af7-0aa5f95804a1", "78" , "ABNT/NBR 14156"	, "200409", "" 			} )
	aAdd( aBody, { "", "57d0fbfc-205f-1dbb-e936-ba5fe1b34f43", "81" , "ABNT/NBR 14359"	, "200409", "" 			} )
	aAdd( aBody, { "", "3b511803-13d6-12f2-9cd9-67cb5a931485", "139", "ABNT/NBR 14448"	, "200501", "" 			} )
	aAdd( aBody, { "", "e0578f2e-4c96-400e-4cc2-0cb4b1673177", "80" , "ABNT/NBR 14478"	, "200409", "" 			} )
	aAdd( aBody, { "", "28c8a70f-4f8a-016a-d889-e3ce8399fb89", "85" , "ABNT/NBR 14483"	, "200409", "" 			} )
	aAdd( aBody, { "", "dff8e844-8966-9aba-daf5-29e4d80625bf", "112", "ABNT/NBR 1452" 	, "200409", "" 			} )
	aAdd( aBody, { "", "604a2a08-59e1-b2da-4250-f0fbea1c348d", "79" , "ABNT/NBR 14525"	, "200409", "" 			} )
	aAdd( aBody, { "", "e5dc2231-7812-f9c3-f701-0657456d7329", "83" , "ABNT/NBR 14533"	, "200409", "" 			} )
	aAdd( aBody, { "", "d6125032-b7fa-d046-a9b0-90441b3f79fe", "88" , "ABNT/NBR 14598"	, "200409", "" 			} )
	aAdd( aBody, { "", "74db6561-18b8-373e-c1a6-7390d4f62e81", "108", "ABNT/NBR 14642"	, "200409", "" 			} )
	aAdd( aBody, { "", "ebe99c8f-fbe6-5261-c4b2-2f340db89ae4", "93" , "ABNT/NBR 14647"	, "200409", "" 			} )
	aAdd( aBody, { "", "44f77478-ab10-d2d6-4172-7b23e3d6aab1", "90" , "ABNT/NBR 14747"	, "200409", "" 			} )
	aAdd( aBody, { "", "dfcbeff5-2fba-9b1c-efed-3d2ffaa3be7a", "201", "ABNT/NBR 14855"	, "200611", "" 			} )
	aAdd( aBody, { "", "1cf9c7a7-d97f-1d4f-7bc9-74f42dc5dbe1", "106", "ABNT/NBR 14875"	, "200409", "" 			} )
	aAdd( aBody, { "", "a91850bf-a1b4-48fe-938e-b54e93893a2f", "206", "ABNT/NBR 14921"	, "200611", "" 			} )
	aAdd( aBody, { "", "8e793f67-4a61-9278-5971-b00a9ebdc7f4", "210", "ABNT/NBR 14932"	, "200611", "" 			} )
	aAdd( aBody, { "", "0e1ec0fb-7908-54f8-d4ae-55571fc1c6cf", "199", "ABNT/NBR 14950"	, "200611", "" 			} )
	aAdd( aBody, { "", "bb2b332f-7687-cec7-8711-5f1713b2d322", "200", "ABNT/NBR 15184"	, "200611", "" 			} )
	aAdd( aBody, { "", "7cd61b34-e106-c464-21a5-6f65bd119d45", "77" , "ABNT/NBR 4149" 	, "200409", "" 			} )
	aAdd( aBody, { "", "046a905d-e11d-fa93-0146-1116f0c73a26", "189", "ABNT/NBR 5765" 	, "200611", "" 			} )
	aAdd( aBody, { "", "bbfe3e21-fc0c-3907-f6f8-5b1cd38bc4f6", "123", "ABNT/NBR 5847" 	, "200409", "" 			} )
	aAdd( aBody, { "", "661f1675-f9c5-ff3d-1afd-2908e71df024", "191", "ABNT/NBR 5847" 	, "200611", "" 			} )
	aAdd( aBody, { "", "90383638-6cf5-e058-f611-9338997bc716", "96" , "ABNT/NBR 5992" 	, "200409", "" 			} )
	aAdd( aBody, { "", "621338c1-79a4-1001-233b-b3d2218cc0a2", "192", "ABNT/NBR 6293" 	, "200611", "" 			} )
	aAdd( aBody, { "", "96e132fc-13fc-a8ed-4e7e-a9f228dbf29f", "172", "ABNT/NBR 6296" 	, "200611", "" 			} )
	aAdd( aBody, { "", "1e6e2191-0534-91e2-1e7e-b1f76cbd30e2", "107", "ABNT/NBR 6298" 	, "200409", "" 			} )
	aAdd( aBody, { "", "5b8e306c-6fbb-d61f-8d15-295aaf86f910", "198", "ABNT/NBR 6560" 	, "200611", "" 			} )
	aAdd( aBody, { "", "991e49a2-0fdc-9f60-a55c-c651e56ef816", "82" , "ABNT/NBR 6563" 	, "200409", "" 			} )
	aAdd( aBody, { "", "a2197083-cd4f-6ef6-f305-957c500cd931", "197", "ABNT/NBR 6576" 	, "200611", "" 			} )
	aAdd( aBody, { "", "ab34f53a-2a14-2f98-32a8-f1c549876bb8", "113", "ABNT/NBR 6577" 	, "200409", "" 			} )
	aAdd( aBody, { "", "20ffa735-911d-cfdb-bd6b-5f6fd5db2d8e", "73" , "ABNT/NBR 7148" 	, "200409", "" 			} )
	aAdd( aBody, { "", "a6811815-0ac2-9efe-f597-11ac4afcc773", "87" , "ABNT/NBR 7974" 	, "200409", "" 			} )
	aAdd( aBody, { "", "b81f8117-c7e2-7229-602e-ceab9248283a", "109", "ABNT/NBR 7975" 	, "200409", "" 			} )
	aAdd( aBody, { "", "4606003b-9c11-4b13-41bc-1cc8fb62954f", "98" , "ABNT/NBR 8644" 	, "200409", "" 			} )
	aAdd( aBody, { "", "eae66a12-b612-5764-8e80-699ab90af433", "75" , "ABNT/NBR 9619" 	, "200409", "" 			} )
	aAdd( aBody, { "", "f7e698fa-ef6a-ddcb-2e1b-40ce533b5138", "92" , "ABNT/NBR 9842" 	, "200409", "" 			} )
	aAdd( aBody, { "", "4ddde2fc-b724-2449-9e92-388bf32fab09", "94" , "ABNT/NBR 9866" 	, "200409", "" 			} )
	aAdd( aBody, { "", "04ff442a-4a50-acc7-3c13-8e4d8a3d21ab", "91" , "ABNT/NBR14318" 	, "200409", "" 			} )
	aAdd( aBody, { "", "d106df06-a5ca-60e1-dff8-2ffc5ad490d1", "86" , "ABNT/NBR14533" 	, "200409", "" 			} )
	aAdd( aBody, { "", "e3e1ca61-288c-e3bf-6536-8b4a017e8c05", "55" , "ASTM/D 1094"   	, "200409", "" 			} )
	aAdd( aBody, { "", "f6c9aab5-32bc-d41c-02ff-09c65e40a6c0", "37" , "ASTM/D 1125"   	, "200409", "" 			} )
	aAdd( aBody, { "", "e07042bb-2095-26e9-6307-4558edcb3849", "196", "ASTM/D 113"    	, "200611", "" 			} )
	aAdd( aBody, { "", "14cae0b5-4ed8-ece6-ce86-c873fea2cf48", "157", "ASTM/D 1160"   	, "200501", "" 			} )
	aAdd( aBody, { "", "a060ceff-4f69-60d1-1fbf-d8a2ae0d87df", "14" , "ASTM/D 1266"   	, "200409", "" 			} )
	aAdd( aBody, { "", "8cfa16d1-aafe-1022-c3f3-ea33e9613469", "58" , "ASTM/D 1267"   	, "200409", "" 			} )
	aAdd( aBody, { "", "d2f694a2-b419-7217-0e44-363748bd37cb", "2"  , "ASTM/D 1298"   	, "200409", "" 			} )
	aAdd( aBody, { "", "77430eb8-d21b-6dfc-bf5e-aa870ff8872b", "13" , "ASTM/D 130"    	, "200409", "" 			} )
	aAdd( aBody, { "", "421ae916-e7b5-2f14-fef1-3c095e7c6705", "23" , "ASTM/D 1319"   	, "200409", "" 			} )
	aAdd( aBody, { "", "1a10db6d-7026-999b-a860-39017cd3eca7", "42" , "ASTM/D 1319"   	, "200409", "200506" 	} )
	aAdd( aBody, { "", "110949f8-c49e-0c60-c944-e835f46a6ce6", "52" , "ASTM/D 1322"   	, "200409", "" 		} )
	aAdd( aBody, { "", "fe57eb1c-c185-aeaf-0fb1-1945f3ce3778", "226", "ASTM/D 1405"   	, "200611", "" 		} )
	aAdd( aBody, { "", "34013db6-0256-5394-dbb7-24c687049b22", "24" , "ASTM/D 1500"   	, "200409", "" 		} )
	aAdd( aBody, { "", "5d5e3e81-5fcb-e1ae-e04b-5945ee0a1eaf", "25" , "ASTM/D 1552"   	, "200409", "" 		} )
	aAdd( aBody, { "", "0735b23e-9bec-cb31-941c-6a2011399a84", "207", "ASTM/D 156"    	, "200611", "" 		} )
	aAdd( aBody, { "", "79368899-50ee-273f-cf61-e39714728b54", "36" , "ASTM/D 1613"   	, "200409", "" 		} )
	aAdd( aBody, { "", "2a2987cd-3a16-f04f-6587-d94307e6fca7", "168", "ASTM/D 1657"   	, "200501", "" 		} )
	aAdd( aBody, { "", "9006b920-90cc-b2f3-16b9-186b10feb2fb", "177", "ASTM/D 1754"   	, "200611", "" 		} )
	aAdd( aBody, { "", "6ccc1e86-0f7f-9616-0836-e72ba3655ac9", "35" , "ASTM/D 1796"   	, "200409", "" 		} )
	aAdd( aBody, { "", "396ea89d-df82-0781-955c-b239fe632641", "60" , "ASTM/D 1837"   	, "200409", "" 		} )
	aAdd( aBody, { "", "7a3d93ec-9485-f26d-7ff2-488e8a346f79", "70" , "ASTM/D 1838"   	, "200409", "" 		} )
	aAdd( aBody, { "", "bb23eada-900c-cf5f-c792-e1768c133cdf", "53" , "ASTM/D 1840"   	, "200409", "" 		} )
	aAdd( aBody, { "", "4c549620-8075-85d8-5206-343d3fccdfa0", "159", "ASTM/D 189"    	, "200501", "" 		} )
	aAdd( aBody, { "", "9c6e75b9-3484-26a9-f10b-f8af0aea70f0", "175", "ASTM/D 2007"   	, "200611", "" 		} )
	aAdd( aBody, { "", "b08d25e7-d577-fe48-dc46-383ac29e6870", "195", "ASTM/D 2042"   	, "200611", "" 		} )
	aAdd( aBody, { "", "aee81de7-3f56-7986-f4e2-3127cac7970c", "62" , "ASTM/D 2158"   	, "200409", "" 		} )
	aAdd( aBody, { "", "c188d8f2-9589-1054-3ba9-c34dc8d7f5b3", "61" , "ASTM/D 2163"   	, "200409", "" 		} )
	aAdd( aBody, { "", "88d6687e-20fe-f4b6-fdd4-ecc60957eaac", "173", "ASTM/D 2170"   	, "200611", "" 		} )
	aAdd( aBody, { "", "487234e3-3d7d-30c9-4fa0-846490492347", "130", "ASTM/D 2171"   	, "200409", "" 		} )
	aAdd( aBody, { "", "e36552fd-f3ee-418c-1cea-0f524119ee9a", "228", "ASTM/D 2382"   	, "200611", "" 		} )
	aAdd( aBody, { "", "7180a798-eec6-8c29-5b0c-8a74d7e8cb17", "47" , "ASTM/D 2386"   	, "200409", "" 		} )
	aAdd( aBody, { "", "84145cd9-b413-0856-82d9-1e4ed0bc091f", "225", "ASTM/D 2392"   	, "200611", "" 		} )
	aAdd( aBody, { "", "deae5656-83a6-6755-3500-8b80eec01604", "69" , "ASTM/D 2420"   	, "200409", "" 		} )
	aAdd( aBody, { "", "0a9c3448-7f7b-4cf1-fdea-3a0d46bbabfc", "223", "ASTM/D 2547"   	, "200611", "" 		} )
	aAdd( aBody, { "", "c2062497-a22a-ce04-1015-a73fe5210057", "232", "ASTM/D 2551"   	, "200611", "" 		} )
	aAdd( aBody, { "", "6add2181-70df-9e30-a63a-23313e32cb01", "59" , "ASTM/D 2598"   	, "200409", "" 		} )
	aAdd( aBody, { "", "2276cb1e-be0c-7418-adb4-f00c294fa571", "224", "ASTM/D 2599"   	, "200611", "" 		} )
	aAdd( aBody, { "", "4fbcc398-f08d-1a35-8ad8-ccde65737802", "15" , "ASTM/D 2622"   	, "200409", "" 		} )
	aAdd( aBody, { "", "d6509996-3002-3367-0cf5-b8973282af7f", "56" , "ASTM/D 2624"   	, "200409", "" 		} )
	aAdd( aBody, { "", "78bce477-aec2-77cf-b944-696957d9ef62", "6"  , "ASTM/D 2699"   	, "200409", "" 		} )
	aAdd( aBody, { "", "1489a674-71ec-bf7d-a33c-96b6c31c3a8d", "5"  , "ASTM/D 2700"   	, "200409", "" 		} )
	aAdd( aBody, { "", "606be5bf-c1e6-b267-8d0d-5eff7f7c0abf", "140", "ASTM/D 2709"   	, "200501", "" 		} )
	aAdd( aBody, { "", "c468523d-686f-adc8-b94f-6199d3c2bbe1", "71" , "ASTM/D 2713"   	, "200409", "" 		} )
	aAdd( aBody, { "", "cb71b176-0426-2fda-0e66-56b184627da3", "63" , "ASTM/D 2784"   	, "200409", "" 		} )
	aAdd( aBody, { "", "d78b1a35-f2c9-c3b6-ce58-e4764e58fe27", "176", "ASTM/D 2872"   	, "200611", "" 		} )
	aAdd( aBody, { "", "a04017ff-f6c5-2fd1-a92b-eabcc06d8c47", "16" , "ASTM/D 3120"   	, "200409", "" 		} )
	aAdd( aBody, { "", "c22ad98a-cf3d-049f-a054-5f01fedf83a3", "193", "ASTM/D 3143"   	, "200611", "" 		} )
	aAdd( aBody, { "", "86bf418d-fafb-4ae4-c40d-634aaed24017", "45" , "ASTM/D 3227"   	, "200409", "" 		} )
	aAdd( aBody, { "", "411aea45-ea1d-09f5-866d-9ce5a010bd44", "231", "ASTM/D 323"    	, "200611", "" 		} )
	aAdd( aBody, { "", "62049467-d7b2-473c-5439-91d71bffd1cf", "22" , "ASTM/D 3237"   	, "200409", "" 		} )
	aAdd( aBody, { "", "b477f133-cecd-d845-8860-b6aec711a1cd", "54" , "ASTM/D 3241"   	, "200409", "" 		} )
	aAdd( aBody, { "", "3cc3a4d0-27a3-00ff-aeb6-f528a35691f1", "41" , "ASTM/D 3242"   	, "200409", "" 		} )
	aAdd( aBody, { "", "f0820273-0478-b2f9-6f9e-f520e4630a2a", "64" , "ASTM/D 3246"   	, "200409", "" 		} )
	aAdd( aBody, { "", "f02b8258-c9ce-e4f0-da83-8c57d517fc91", "50" , "ASTM/D 3338"   	, "200409", "" 		} )
	aAdd( aBody, { "", "805af7a8-f4fb-7b6d-ffd6-cee0756c08ca", "222", "ASTM/D 3341"   	, "200611", "" 		} )
	aAdd( aBody, { "", "b5606a9d-3c2c-2b25-35ec-9a29262e1310", "203", "ASTM/D 36"     	, "200611", "" 		} )
	aAdd( aBody, { "", "13d4949f-7794-5bf0-8662-ba9439cd9f15", "19" , "ASTM/D 3606"   	, "200409", "" 		} )
	aAdd( aBody, { "", "7a506891-9da9-f581-5a04-54a44fa97522", "11" , "ASTM/D 381"    	, "200409", "" 		} )
	aAdd( aBody, { "", "2b5f9724-c64c-5ef8-2e9a-13027f512c4f", "29" , "ASTM/D 3828"   	, "200409", "" 		} )
	aAdd( aBody, { "", "f06c3e0a-6e27-d369-bf2f-b8f27388f60a", "121", "ASTM/D 3948"   	, "200409", "" 		} )
	aAdd( aBody, { "", "a091e009-92a8-1658-ef25-5c3538cb767f", "194", "ASTM/D 402"    	, "200611", "" 		} )
	aAdd( aBody, { "", "57050d94-34f4-7cf3-0cf8-05f022e10b3e", "26" , "ASTM/D 4052"   	, "200409", "" 		} )
	aAdd( aBody, { "", "e6324caf-e2c5-1565-dcfa-0160739cca1e", "40" , "ASTM/D 4176"   	, "200409", "" 		} )
	aAdd( aBody, { "", "7d1eac46-156b-4b79-1bb3-1651339708be", "44" , "ASTM/D 4249"   	, "200409", "" 		} )
	aAdd( aBody, { "", "8db59645-b501-a472-dd2b-3366419da9d8", "17" , "ASTM/D 4294"   	, "200409", "" 		} )
	aAdd( aBody, { "", "1c7b69f0-c3f8-238b-12a5-d7c5c5309bf2", "30" , "ASTM/D 445"    	, "200409", "" 		} )
	aAdd( aBody, { "", "982f4689-02d8-752c-665d-fbfc448de860", "65" , "ASTM/D 4468"   	, "200409", "" 		} )
	aAdd( aBody, { "", "6cc09de5-b901-5359-f2a8-6992f8d1e9f9", "158", "ASTM/D 4530"   	, "200501", "" 		} )
	aAdd( aBody, { "", "a440faf9-b450-1ca5-1dc8-d5b31d8c0af8", "133", "ASTM/D 473"    	, "200409", "" 		} )
	aAdd( aBody, { "", "f19150d1-e387-3bad-d1db-0ab5cbd71f18", "120", "ASTM/D 4737"   	, "200409", "" 		} )
	aAdd( aBody, { "", "4586fabd-81d9-f294-c37e-48c1320885c7", "51" , "ASTM/D 4809"   	, "200409", "" 		} )
	aAdd( aBody, { "", "54d03d1c-2cff-4678-8373-f27bbceec871", "34" , "ASTM/D 482"    	, "200409", "" 		} )
	aAdd( aBody, { "", "96a74084-f07e-8fad-2757-f5d23fbdd0b0", "142", "ASTM/D 4951"   	, "200501", "" 		} )
	aAdd( aBody, { "", "eb9abe14-0e36-ad1b-d682-70b7e60b4900", "46" , "ASTM/D 4952"   	, "200409", "" 		} )
	aAdd( aBody, { "", "87fe9a58-45b8-cd6a-a50f-abc4bf3c5f0c", "7"  , "ASTM/D 4953"   	, "200409", "" 		} )
	aAdd( aBody, { "", "548f7245-c551-711a-3f78-40e2c3ac61f9", "202", "ASTM/D 5"      	, "200611", "" 		} )
	aAdd( aBody, { "", "607e39b6-f14c-363b-8d46-df8e7fd0fc1f", "57" , "ASTM/D 5001"   	, "200409", "" 		} )
	aAdd( aBody, { "", "2fe42ac9-0e5d-85b7-eb95-238819f11d21", "3"  , "ASTM/D 5042"   	, "200409", "" 		} )
	aAdd( aBody, { "", "7e7a6d14-c3e5-5912-2c63-eb7de02de63a", "38" , "ASTM/D 512"    	, "200409", "" 		} )
	aAdd( aBody, { "", "0dacd0e2-c3b4-8fbc-48eb-eef144407a56", "8"  , "ASTM/D 5190"   	, "200409", "" 		} )
	aAdd( aBody, { "", "c870700a-8ac1-4f55-2eee-ff3076564644", "9"  , "ASTM/D 5191"   	, "200409", "" 		} )
	aAdd( aBody, { "", "658cfd0b-d30e-fb20-a050-0ab5534a036b", "33" , "ASTM/D 524"    	, "200409", "" 		} )
	aAdd( aBody, { "", "5495b6c6-0d16-c385-f212-c887eaaecc08", "12" , "ASTM/D 525"    	, "200409", "" 		} )
	aAdd( aBody, { "", "643b3cd8-19b2-bd89-ab10-5d6fd71ef2bd", "20" , "ASTM/D 5443"   	, "200409", "" 		} )
	aAdd( aBody, { "", "d5562a33-b854-bd5f-94f9-517d3ee2496a", "209", "ASTM/D 5452"   	, "200611", "" 		} )
	aAdd( aBody, { "", "6a1560d8-8669-70f6-00c5-adc4039feded", "18" , "ASTM/D 5453"   	, "200409", "" 		} )
	aAdd( aBody, { "", "9a107483-a03c-e0ac-40b2-1bcf87010e54", "10" , "ASTM/D 5482"   	, "200409", "" 		} )
	aAdd( aBody, { "", "7628eb30-3d6d-bdf1-b98b-524bd1b7f760", "39" , "ASTM/D 5501"   	, "200409", "" 		} )
	aAdd( aBody, { "", "8df68d6b-eeab-709e-32d0-48dc3322667c", "66" , "ASTM/D 5504"   	, "200409", "" 		} )
	aAdd( aBody, { "", "1ac830df-1db0-b806-45bb-de758517c835", "27" , "ASTM/D 56"     	, "200409", "" 		} )
	aAdd( aBody, { "", "c4ae5271-a036-a5eb-6fc2-12e2474f0adc", "67" , "ASTM/D 5623"   	, "200409", "" 		} )
	aAdd( aBody, { "", "1c318e05-2f14-406c-09db-fe9451c9f17f", "137", "ASTM/D 5708"   	, "200409", "" 		} )
	aAdd( aBody, { "", "8c67be5d-1384-c87a-9486-e28c268dc356", "136", "ASTM/D 5863"   	, "200409", "" 		} )
	aAdd( aBody, { "", "c902f148-fe7e-9f5d-691a-30e43b922fe2", "48" , "ASTM/D 5972"   	, "200409", "" 		} )
	aAdd( aBody, { "", "5042672b-a561-a7a6-bbad-2def5688d615", "208", "ASTM/D 6045"   	, "200611", "" 		} )
	aAdd( aBody, { "", "39c5fe8b-c970-a921-a62a-8fc6fb47dba8", "227", "ASTM/D 611"    	, "200611", "" 		} )
	aAdd( aBody, { "", "91a4922d-f453-d0cd-577d-17d67635f5c0", "32" , "ASTM/D 613"    	, "200409", "" 		} )
	aAdd( aBody, { "", "e29b07c2-2498-a9cc-bf9c-fef452e27ed0", "21" , "ASTM/D 6277"   	, "200409", "" 		} )
	aAdd( aBody, { "", "e8a0f81e-2220-46d6-0450-5613d9dddddd", "31" , "ASTM/D 6371"   	, "200409", "" 		} )
	aAdd( aBody, { "", "dfd6accf-49da-9e19-2fa1-4c2bcf9f7c9a", "43" , "ASTM/D 6379"   	, "200409", "" 		} )
	aAdd( aBody, { "", "9a5fce13-68c5-c58e-5c49-3e870498e3dd", "144", "ASTM/D 6584"   	, "200501", "" 		} )
	aAdd( aBody, { "", "a3e5ad75-2e65-b9d3-5ed5-f73f3825aa92", "143", "ASTM/D 664"    	, "200501", "" 		} )
	aAdd( aBody, { "", "76425d92-3470-7a06-0bae-397d898f371a", "68" , "ASTM/D 6667"   	, "200409", "" 		} )
	aAdd( aBody, { "", "eb69d418-f975-b13f-b970-ba774d7baf61", "178", "ASTM/D 70"     	, "200611", "" 		} )
	aAdd( aBody, { "", "bb722b7d-7ffc-9eb7-31f0-989bc50a1b50", "211", "ASTM/D 7153"   	, "200611", "" 		} )
	aAdd( aBody, { "", "505b93f6-51ee-8c5b-db68-7a1db544b0c2", "212", "ASTM/D 7154"   	, "200611", "" 		} )
	aAdd( aBody, { "", "f7769224-767d-b04f-9211-1526bd875f19", "4"  , "ASTM/D 86"     	, "200409", "" 		} )
	aAdd( aBody, { "", "1d8c0ed5-b1fb-5db5-79dc-85334a432291", "236", "ASTM/D 873"    	, "200611", "" 		} )
	aAdd( aBody, { "", "2cc84ac6-fb45-ef7c-cad0-083071b6cc89", "141", "ASTM/D 874"    	, "200501", "" 		} )
	aAdd( aBody, { "", "47462bd2-f0a5-0ed8-22de-01d6a142c309", "131", "ASTM/D 88"     	, "200409", "" 		} )
	aAdd( aBody, { "", "108ecc8d-ab99-75a3-8087-5289f0d7af93", "221", "ASTM/D 910"    	, "200611", "" 		} )
	aAdd( aBody, { "", "ca95a69a-aedb-3a97-b5f4-668b08a8498b", "174", "ASTM/D 92"     	, "200611", "" 		} )
	aAdd( aBody, { "", "acd54257-17d1-eec2-ec4f-c6b6feb12c9e", "28" , "ASTM/D 93"     	, "200409", "" 		} )
	aAdd( aBody, { "", "b530af84-eb22-f911-18a9-a9b540d25bba", "132", "ASTM/D 95"     	, "200409", "" 		} )
	aAdd( aBody, { "", "d5bae380-6405-184c-3e79-e7cdf4b897b8", "135", "ASTM/D 97"     	, "200409", "" 		} )
	aAdd( aBody, { "", "c7224d87-92ca-bf82-f248-c46f018cbab3", "49" , "ASTM/D4529"    	, "200409", "" 		} )
	aAdd( aBody, { "", "994a9e7b-1dbf-e448-c167-e61685054ce5", "204", "ASTM/E 102"    	, "200611", "" 		} )
	aAdd( aBody, { "", "0732de3c-efa0-43d3-1a71-098fca12ce98", "205", "ASTM/E 4402"   	, "200611", "" 		} )
	aAdd( aBody, { "", "575c8ddf-7976-3464-6dd5-e0f60c172ce3", "145", "EN 14103"      	, "200501", "" 		} )
	aAdd( aBody, { "", "277256e1-2e5f-2ea7-3b58-f3bd0378aee9", "151", "EN 14104"      	, "200501", "" 		} )
	aAdd( aBody, { "", "85d4256c-fa29-47b1-e3a0-2fdc9254d7c4", "152", "EN 14105"      	, "200501", "" 		} )
	aAdd( aBody, { "", "6367939f-0f5b-206d-27f4-50d6eaefb9b4", "153", "EN 14106"      	, "200501", "" 		} )
	aAdd( aBody, { "", "e2e305e8-e014-e4c6-249e-c52efb64a219", "150", "EN 14107"      	, "200501", "" 		} )
	aAdd( aBody, { "", "17f2a1a7-54a0-f280-c060-4d12b00c7d39", "147", "EN 14108"      	, "200501", "" 		} )
	aAdd( aBody, { "", "4e6a69e6-74b5-fcc8-1eea-c97357ff4f88", "148", "EN 14109"      	, "200501", "" 		} )
	aAdd( aBody, { "", "e64e009c-d61c-b962-722a-69d2468685c5", "154", "EN 14110"      	, "200501", "" 		} )
	aAdd( aBody, { "", "c300530a-5045-9da9-b99c-be26b2ef62a7", "155", "EN 14111"      	, "200501", "" 		} )
	aAdd( aBody, { "", "d72b89be-cb3b-20de-5c0e-9f4ab66ac5f9", "156", "EN 14112"      	, "200501", "" 		} )
	aAdd( aBody, { "", "271d1323-7e50-b97e-756c-e9036d09d0ca", "149", "EN 14538"      	, "200501", "" 		} )
	aAdd( aBody, { "", "ae9c35d1-1cec-8281-6ab2-0283c286b5a2", "164", "EN/ISO 10370"  	, "200501", "" 		} )
	aAdd( aBody, { "", "54ac9dee-c696-5bd2-1285-333eaf03fa4e", "162", "EN/ISO 12662"  	, "200501", "" 		} )
	aAdd( aBody, { "", "4b8791fc-de81-da97-74a7-6c5877904536", "161", "EN/ISO 12937"  	, "200501", "" 		} )
	aAdd( aBody, { "", "ba1f297f-7dab-9599-7fcd-451e841ed30f", "165", "EN/ISO 14569"  	, "200501", "" 		} )
	aAdd( aBody, { "", "99012d65-112a-1b3a-cfaf-0d93241a608a", "166", "EN/ISO 2160"   	, "200501", "" 		} )
	aAdd( aBody, { "", "4528bad5-7dda-41bb-1c1b-ce239ef60328", "160", "EN/ISO 3104"   	, "200501", "" 		} )
	aAdd( aBody, { "", "8ebcc892-ec23-8045-1fc7-c4d484820e08", "163", "EN/ISO 3679"   	, "200501", "" 		} )
	aAdd( aBody, { "", "3748a6de-4dae-cbe8-50a3-e47d83bfba37", "167", "EN/ISO 5165"   	, "200501", "" 		} )
	aAdd( aBody, { "", "c805f6d6-5146-20a6-c62f-1e388da9d17f", "122", "IP 227"        	, "200409", "" 		} )
	aAdd( aBody, { "", "9178984a-d6f8-2a3a-c81e-37aca68968f9", "146", "ISO 3987"      	, "200501", "" 		} )
	aAdd( aBody, { "", "9a712547-c133-2d32-c480-e037cdc04875", "138", "Não Aplicável" 	, "200409", "" 		} )
	aAdd( aBody, { "", "a29ccac2-bbc6-6ce6-6af1-7d3714a8c693", "119", "NFPA58"        	, "200409", "" 		} )
	aAdd( aBody, { "", "44aa82b5-3ccf-2c38-c72b-44707db80593", "186", "P-MB-107"      	, "200611", "" 		} )
	aAdd( aBody, { "", "d7efe0d3-126a-e2bb-dbd0-1b9ff2a5738e", "187", "P-MB-166"      	, "200611", "" 		} )
	aAdd( aBody, { "", "a0035055-fb7d-7dbc-16e1-6a81bdbae167", "188", "P-MB-167"      	, "200611", "" 		} )
	aAdd( aBody, { "", "c1b53a27-05cf-4369-1615-f7365b417cfa", "182", "P-MB-496"      	, "200611", "" 		} )
	aAdd( aBody, { "", "dc63d4db-f43b-8045-a0cf-d96befdc7509", "184", "P-MB-563"      	, "200611", "" 		} )
	aAdd( aBody, { "", "0e5064a0-9b73-daf5-e08c-5e71144e1117", "179", "P-MB-581"      	, "200611", "" 		} )
	aAdd( aBody, { "", "35d162ec-12f2-0946-9370-5c1e0dabbc6e", "185", "P-MB-586"      	, "200611", "" 		} )
	aAdd( aBody, { "", "e86bc355-2352-6b66-7815-219ab158bd30", "181", "P-MB-609"      	, "200611", "" 		} )
	aAdd( aBody, { "", "40cdcc1c-f8ac-00d5-cc96-036f8e9979cd", "180", "P-MB-722"      	, "200611", "" 		} )
	aAdd( aBody, { "", "8afcbebe-7988-71e6-a0ea-39908f1d392f", "183", "P-MB-795"      	, "200611", "" 		} )
	aAdd( aBody, { "", "1208cb27-978c-52da-5460-1b2b7023124a", "1"  , "VISUAL"        	, "200409", "" 		} )
	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )