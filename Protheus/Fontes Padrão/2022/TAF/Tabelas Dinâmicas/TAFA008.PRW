#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA008.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA008
Tabela 06 - Países

@author Marcio Nunes
@since 03/07/2012
@version 1.0
    
/*/
//-------------------------------------------------------------------
Function TAFA008()

	Local oBrw := FWmBrowse():New()

	oBrw:SetDescription( STR0001 ) //Cadastro de País do banco central/SISCOMEX
	oBrw:SetAlias( 'C08')
	oBrw:SetMenuDef( 'TAFA008' )
	oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 03/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA008" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 03/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruC08 := FWFormStruct( 1, 'C08' )
	Local oModel   := MPFormModel():New('TAFA008' )

	oModel:AddFields('MODEL_C08', /*cOwner*/, oStruC08)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 03/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FWLoadModel( 'TAFA008' )
	Local oStruC08 := FWFormStruct( 2, 'C08' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_C08', oStruC08, 'MODEL_C08' )

	oView:EnableTitleView( 'VIEW_C08', STR0001 ) //Cadastro de País do banco central/SISCOMEX
	oView:CreateHorizontalBox( 'FIELDSC08', 100 )
	oView:SetOwnerView( 'VIEW_C08', 'FIELDSC08' )

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
Static Function FAtuCont( nVerEmp as Numeric, nVerAtu as Numeric)

	Local aHeader as Array
	Local aBody   as Array
	Local aRet    as Array

	aHeader := {}
	aBody   := {}
	aRet    := {}

	nVerAtu := 1032.08

	If nVerEmp < nVerAtu

		aAdd( aHeader, "C08_FILIAL" )
		aAdd( aHeader, "C08_ID" )
		aAdd( aHeader, "C08_CODIGO" )
		aAdd( aHeader, "C08_DESCRI" )
		aAdd( aHeader, "C08_PAISSX" )
		aAdd( aHeader, "C08_CODANP" )
		aAdd( aHeader, "C08_SIGLA2" )
		aAdd( aHeader, "C08_JURIDI" )
		aAdd( aHeader, "C08_CREINF" )

		aAdd( aBody, { "", "000252", ""		, "A DESIGNAR"										, "994", ""	   , ""  ,  "" , ""     }  )
		aAdd( aBody, { "", "000002", "00132", "AFEGANISTAO"										, "013", "116" , "AF", "AF", "013"  }  )
		aAdd( aBody, { "", "000213", "07560", "AFRICA DO SUL"									, "756", "167" , "ZA", "ZA", "756"  }  )
		aAdd( aBody, { "", "000003", "00175", "ALBANIA, REPUBLICA DA"							, "017", "272" , "AL", "AL", "017"  }  )
		aAdd( aBody, { "", "000004", "00230", "ALEMANHA"						 				, "023", "9904", "DE", "DE", "023"  }  )
		aAdd( aBody, { "", "000006", "00370", "ANDORRA"											, "037", "493" , "AD", "AD", "037"  }  )
		aAdd( aBody, { "", "000007", "00400", "ANGOLA"											, "040", "558" , "AO", "AO", "040"  }  )
		aAdd( aBody, { "", "000008", "00418", "ANGUILLA"										, "041", "9905", "AI", "AI", "041"  }  )
		aAdd( aBody, { "", "000009", "00434", "ANTIGUA E BARBUDA"								, "043", "9906", "AG", "AG", "043"  }  )
		aAdd( aBody, { "", "000010", "00477", "ANTILHAS HOLANDESAS"								, "047", "574" , "AN", "AN", "047"  }  )
		aAdd( aBody, { "", "000011", "00531", "ARABIA SAUDITA"									, "053", "604" , "SA", "SA", "053"  }  )
		aAdd( aBody, { "", "000012", "00590", "ARGELIA"											, "059", "655" , "DZ", "DZ", "059"  }  )
		aAdd( aBody, { "", "000013", "00639", "ARGENTINA"										, "063", "728" , "AR", "AR", "063"  }  )
		aAdd( aBody, { "", "000014", "00647", "ARMENIA, REPUBLICA DA"							, "064", "779" , "AM", "AM", "064"  }  )
		aAdd( aBody, { "", "000015", "00655", "ARUBA"											, "065", "9907", "AW", "AW", "065"  }  )
		aAdd( aBody, { "", "000016", "00698", "AUSTRALIA"										, "069", "825" , "AU", "AU", "069"  }  )
		aAdd( aBody, { "", "000017", "00728", "AUSTRIA"											, "072", "884" , "AT", "AT", "072"  }  )
		aAdd( aBody, { "", "000018", "00736", "AZERBAIJAO, REPUBLICA DO"						, "073", "930" , "AZ", "AZ", "073"  }  )
		aAdd( aBody, { "", "000019", "00779", "BAHAMAS, ILHAS"									, "077", "981" , "BS", "BS", "077"  }  )
		aAdd( aBody, { "", "000020", "00809", "BAHREIN, ILHAS"									, "080", "1058", "BH", "BH", "080"  }  )
		aAdd( aBody, { "", "000021", "00817", "BANGLADESH"										, "081", "1104", "BD", "BD", "081"  }  )
		aAdd( aBody, { "", "000022", "00833", "BARBADOS"										, "083", "1155", "BB", "BB", "083"  }  )
		aAdd( aBody, { "", "000023", "00850", "BELARUS, REPUBLICA DA"							, "085", "9908", "BY", "BY", "085"  }  )
		aAdd( aBody, { "", "000024", "00876", "BELGICA"											, "087", "1228", "BE", "BE", "087"  }  )
		aAdd( aBody, { "", "000025", "00884", "BELIZE" 											, "088", "9909", "BZ", "BZ", "088"  }  )
		aAdd( aBody, { "", "000061", "02291", "BENIN"											, "229", "1279", "BJ", "BJ", "229"  }  )
		aAdd( aBody, { "", "000026", "00906", "BERMUDAS"										, "090", "1295", "BM", "BM", "090"  }  )
		aAdd( aBody, { "", "000028", "00973", "BOLIVIA"											, "097", "1430", "BO", "BO", "097"  }  )
		aAdd( aBody, { "", "000029", "00981", "BOSNIA-HERZEGOVINA (REPUBLICA DA)"				, "098", "9910", "BA", "BA", "098"  }  )
		aAdd( aBody, { "", "000030", "01015", "BOTSUANA"										, "101", "1481", "BW", "BW", "101"  }  )
		aAdd( aBody, { "", "000001", "01058", "BRASIL"											, "105", "1554", "BR", "BR", "001"  }  )
		aAdd( aBody, { "", "000031", "01082", "BRUNEI"											, "108", "1589", "BN", "BN", "108"  }  )
		aAdd( aBody, { "", "000032", "01112", "BULGARIA, REPUBLICA DA"							, "111", "1600", "BG", "BG", "111"  }  )
		aAdd( aBody, { "", "000005", "00310", "BURKINA FASO"									, "031", "9911", "BF", "BF", "031"  }  )
		aAdd( aBody, { "", "000033", "01155", "BURUNDI"											, "115", "1651", "BI", "BI", "115"  }  )
		aAdd( aBody, { "", "000034", "01198", "BUTAO"											, "119", "1716", "BT", "BT", "119"  }  )
		aAdd( aBody, { "", "000249", ""		, "BANCOS CENTRAIS"									, "995", ""	   , ""  , ""	, ""    }  )
		aAdd( aBody, { "", "000035", "01279", "CABO VERDE, REPUBLICA DE"						, "127", "1767", "CV", "CV", "127"  }  )
		aAdd( aBody, { "", "000036", "01376", "CAYMAN, ILHAS"									, "137", "1996", "KY", "KY", "137"  }  )
		aAdd( aBody, { "", "000037", "01414", "CAMBOJA" 										, "141", "1872", "KH", "KH", "141"  }  )
		aAdd( aBody, { "", "000038", "01457", "CAMAROES"										, "145", "1813", "CM", "CM", "145"  }  )
		aAdd( aBody, { "", "000039", "01490", "CANADA"											, "149", "1929", "CA", "CA", "149"  }  )
		aAdd( aBody, { "", "000042", "01511", "CANARIAS, ILHAS"									, "151", "9912", "IC", "IC", "151"  }  )
		aAdd( aBody, { "", "000043", "01538", "CAZAQUISTAO,REPUBLICA DO"						, "153", "1988", "KZ", "KZ", "153"  }  )
		aAdd( aBody, { "", "000044", "01546", "CATAR"											, "154", "9913", "QA", "QA", "154"  }  )
		aAdd( aBody, { "", "000045", "01589", "CHILE"											, "158", "2097", "CL", "CL", "158"  }  )
		aAdd( aBody, { "", "000046", "01600", "CHINA, REPUBLICA POPULAR"						, "160", "2143", "CN", "CN", "160"  }  )
		aAdd( aBody, { "", "000048", "01635", "CHIPRE"											, "163", "2208", "CY", "CY", "163"  }  )
		aAdd( aBody, { "", "000049", "01651", "COCOS(KEELING),ILHAS"							, "165", "9915", "CC", "CC", "165"  }  )
		aAdd( aBody, { "", "000050", "01694", "COLOMBIA"										, "169", "2305", "CO", "CO", "169"  }  )
		aAdd( aBody, { "", "000052", ""		, "CONGO"											, "177", "2364", "CG", "CG", "177"  }  )
		aAdd( aBody, { "", "000253", "01775", "CONGO, REPUBLICA DO"								, ""   , "9917", ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000247", "08885", "CONGO, REPUBLICA DEMOCRATICA DO"					, "888", "9916", "CD", "CD", "888"  }  )
		aAdd( aBody, { "", "000053", "01830", "COOK, ILHAS"										, "183", "9918", "CK", "CK", "183"  }  )
		aAdd( aBody, { "", "000054", "01872", "COREIA, REP.POP.DEMOCRATICA"						, "187", "9919", "KP", "KP", "187"  }  )
		aAdd( aBody, { "", "000055", "01902", "COREIA, REPUBLICA DA"							, "190", "9920", "KR", "KR", "190"  }  )
		aAdd( aBody, { "", "000056", "01937", "COSTA DO MARFIM"									, "193", "2534", "CI", "CI", "193"  }  )
		aAdd( aBody, { "", "000057", "01953", "CROACIA (REPUBLICA DA)"							, "195", "9922", "HR", "HR", "195"  }  )
		aAdd( aBody, { "", "000058", "01961", "COSTA RICA"										, "196", "2585", "CR", "CR", "196"  }  )
		aAdd( aBody, { "", "000059", "01988", "KUWAIT"											, "198", "9921", "KW", "KW", "198"  }  )
		aAdd( aBody, { "", "000060", "01996", "CUBA"											, "199", "2631", "CU", "CU", "199"  }  )
		aAdd( aBody, { "", "000155", "05118", "CHRISTMAS,ILHA (NAVIDAD)"						, "511", "9914", "CX", "CX", "511"  }  )
		aAdd( aBody, { "", "000208", "07412", "SINGAPURA"										, "741", "2259", "SG", "SG", "741"  }  )
		aAdd( aBody, { "", "000223", "07889", "CHADE"											, "788", "2046", "TD", "TD", "788"  }  )
		aAdd( aBody, { "", "000062", "02321", "DINAMARCA"	 									, "232", "2690", "DK", "DK", "232"  }  )
		aAdd( aBody, { "", "000063", "02356", "DOMINICA,ILHA"									, "235", "2801", "DM", "DM", "235"  }  )
		aAdd( aBody, { "", "000222", "07838", "DJIBUTI"											, "783", "2747", "DJ", "DJ", "783"  }  )
		aAdd( aBody, { "", "000064", ""		, "DUBAI"		 									, "237", ""	   , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000251", ""		, "DELEGACAO ESPECIAL DA PALESTINA"					, "998", ""	   , ""  , ""  , "998"  }  )
		aAdd( aBody, { "", "000065", "02399", "EQUADOR"											, "239", "3034", "EC", "EC", "239"  }  )
		aAdd( aBody, { "", "000066", "02402", "EGITO"											, "240", "2917", "EG", "EG", "240"  }  )
		aAdd( aBody, { "", "000067", "02437", "ERITREIA"										, "243", "9924", "ER", "ER", "243"  }  )
		aAdd( aBody, { "", "000068", "02445", "EMIRADOS ARABES UNIDOS"							, "244", "9923", "AE", "AE", "244"  }  )
		aAdd( aBody, { "", "000069", "02453", "ESPANHA"											, "245", "3131", "ES", "ES", "245"  }  )
		aAdd( aBody, { "", "000071", "02470", "ESLOVACA, REPUBLICA"								, "247", "9925", "SK", "SK", "247"  }  )
		aAdd( aBody, { "", "000070", "02461", "ESLOVENIA, REPUBLICA DA"							, "246", "9926", "SI", "SI", "246"  }  )
		aAdd( aBody, { "", "000072", "02496", "ESTADOS UNIDOS"									, "249", "3190", "US", "US", "249"  }  )
		aAdd( aBody, { "", "000073", "02518", "ESTONIA, REPUBLICA DA"							, "251", "3247", "EE", "EE", "251"  }  )
		aAdd( aBody, { "", "000074", "02534", "ETIOPIA"											, "253", "3301", "ET", "ET", "253"  }  )
		aAdd( aBody, { "", "000195", "06874", "EL SALVADOR"										, "687", "2976", "SV", "SV", "687"  }  )
		aAdd( aBody, { "", "000075", "02550", "FALKLAND (ILHAS MALVINAS)"						, "255", "9927", "FK", "FK", "255"  }  )
		aAdd( aBody, { "", "000047", "01619", "FORMOSA (TAIWAN)"								, "161", "3522", "TW", "TW", "161"  }  )
		aAdd( aBody, { "", "000076", "02593", "FEROE, ILHAS"									, "259", "9928", "FO", "FO", "259"  }  )
		aAdd( aBody, { "", "000077", ""		, "FEZZAN"											, "263", ""	   , ""  , ""	, ""    }  )
		aAdd( aBody, { "", "000078", "02674", "FILIPINAS"										, "267", "3417", "PH", "PH", "267"  }  )
		aAdd( aBody, { "", "000079", "02712", "FINLANDIA"										, "271", "3476", "FI", "FI", "271"  }  )
		aAdd( aBody, { "", "000080", "02755", "FRANCA"											, "275", "3646", "FR", "FR", "275"  }  )
		aAdd( aBody, { "", "000244", "08702", "FIJI"											, "870", "3360", "FJ", "FJ", "870"  }  )
		aAdd( aBody, { "", "000081", "02810", "GABAO" 											, "281", "3697", "GA", "GA", "281"  }  )
		aAdd( aBody, { "", "000082", "02852", "GAMBIA"											, "285", "3743", "GM", "GM", "285"  }  )
		aAdd( aBody, { "", "000083", "02895", "GANA"  											, "289", "3808", "GH", "GH", "289"  }  )
		aAdd( aBody, { "", "000084", "02917", "GEORGIA, REPUBLICA DA"							, "291", "3859", "GE", "GE", "291"  }  )
		aAdd( aBody, { "", "000085", "02933", "GIBRALTAR"										, "293", "9929", "GI", "GI", "293"  }  )
		aAdd( aBody, { "", "000086", "02976", "GRANADA"											, "297", "3905", "GD", "GD", "297"  }  )
		aAdd( aBody, { "", "000087", "03018", "GRECIA"											, "301", "3964", "GR", "GR", "301"  }  )
		aAdd( aBody, { "", "000088", "03050", "GROENLANDIA" 									, "305", "9930", "GL", "GL", "305"  }  )
		aAdd( aBody, { "", "000089", "03093", "GUADALUPE"										, "309", "9931", "GP", "GP", "309"  }  )
		aAdd( aBody, { "", "000090", "03131", "GUAM"											, "313", "9932", "GU", "GU", "313"  }  )
		aAdd( aBody, { "", "000091", "03174", "GUATEMALA"										, "317", "4014", "GT", "GT", "317"  }  )
		aAdd( aBody, { "", "000040", "01504", "GUERNSEY, ILHA DO CANAL (INCLUI ALDERNEY E SARK)", "150", "9933", "GG", "GG", ""     }  )
		aAdd( aBody, { "", "000096", "03379", "GUIANA"											, "337", "4065", "GY", "GY", "337"  }  )
		aAdd( aBody, { "", "000092", "03255", "GUIANA FRANCESA" 								, "325", "9934", "GF", "GF", "325"  }  )
		aAdd( aBody, { "", "000093", "03298", "GUINE"											, "329", "4138", "GN", "GN", "329"  }  )
		aAdd( aBody, { "", "000095", "03344", "GUINE-BISSAU"									, "334", "4189", "GW", "GW", "334"  }  )
		aAdd( aBody, { "", "000094", "03310", "GUINE-EQUATORIAL"								, "331", "4235", "GQ", "GQ", "331"  }  )
		aAdd( aBody, { "", "000097", "03417", "HAITI"											, "341", "4294", "HT", "HT", "341"  }  )
		aAdd( aBody, { "", "000098", "03450", "HONDURAS"										, "345", "4391", "HN", "HN", "345"  }  )
		aAdd( aBody, { "", "000099", "03514", "HONG KONG"										, "351", "4405", "HK", "HK", "351"  }  )
		aAdd( aBody, { "", "000100", "03557", "HUNGRIA, REPUBLICA DA"							, "355", "4456", "HU", "HU", "355"  }  )
		aAdd( aBody, { "", "000101", "03573", "IEMEN"											, "357", "4502", "YE", "YE", "357"  }  )
		aAdd( aBody, { "", "000051", "01732", "ILHAS COMORES"									, "173", "4626", "KM", "KM", "173"  }  )
		aAdd( aBody, { "", "000135", "04618", "ILHAS MALDIVAS"									, "461", "4677", "MV", "MV", "461"  }  )
		aAdd( aBody, { "", "000192", "06777", "ILHAS SALOMAO"									, "677", "4723", "SB", "SB", "677"  }  )
		aAdd( aBody, { "", "000103", "03611", "INDIA"											, "361", "4782", "IN", "IN", "361"  }  )
		aAdd( aBody, { "", "000104", "03654", "INDONESIA"										, "365", "4839", "ID", "ID", "365"  }  )
		aAdd( aBody, { "", "000105", "06289", "INGLATERRA"										, "367", ""	   , "UK", "UK", ""     }  )
		aAdd( aBody, { "", "000107", "03727", "IRA, REPUBLICA ISLAMICA DO"						, "372", "4952", "IR", "IR", "372"  }  )
		aAdd( aBody, { "", "000106", "03697", "IRAQUE"											, "369", "5002", "IQ", "IQ", "369"  }  )
		aAdd( aBody, { "", "000108", "03751", "IRLANDA"											, "375", "5053", "IE", "IE", "375"  }  )
		aAdd( aBody, { "", "000109", "03794", "ISLANDIA"										, "379", "5177", "IS", "IS", "379"  }  )
		aAdd( aBody, { "", "000110", "03832", "ISRAEL"											, "383", "5223", "IL", "IL", "383"  }  )
		aAdd( aBody, { "", "000111", "03867", "ITALIA"											, "386", "5282", "IT", "IT", "386"  }  )
		aAdd( aBody, { "", "000112", ""		, "IUGOSLAVIA, REP.FED.DA"							, "388", "5339", "YU", "YU", ""     }  )
		aAdd( aBody, { "", "000113", "03913", "JAMAICA"											, "391", "5398", "JM", "JM", "391"  }  )
		aAdd( aBody, { "", "000115", "03999", "JAPAO"											, "399", "5452", "JP", "JP", "399"  }  )
		aAdd( aBody, { "", "000041", "01508", "JERSEY, ILHA DO CANAL"							, "150", "9935", "JE", "JE", "150"  }  )
		aAdd( aBody, { "", "000114", "03964", "JOHNSTON, ILHAS"									, "396", "9936", ""  , ""  , "396"  }  )
		aAdd( aBody, { "", "000116", "04030", "JORDANIA"										, "403", "5509", "JO", "JO", "403"  }  )
		aAdd( aBody, { "", "000117", "04111", "KIRIBATI"										, "411", "5568", "KI", "KI", "411"  }  )
		aAdd( aBody, { "", "000254", ""		, "KUWAIT"											, ""   , "5614", "KW", "KW", ""     }  )
		aAdd( aBody, { "", "000118", "04200", "LAOS, REP.POP.DEMOCR.DO"							, "420", "5665", "LA", "LA", "420"  }  )
		aAdd( aBody, { "", "000120", "04235", "LEBUAN,ILHAS"									, "423", "9937", ""  , ""  , "423"  }  )
		aAdd( aBody, { "", "000121", "04260", "LESOTO"											, "426", "5738", "LS", "LS", "426"  }  )
		aAdd( aBody, { "", "000122", "04278", "LETONIA, REPUBLICA DA"							, "427", "5789", "LV", "LV", "427"  }  )
		aAdd( aBody, { "", "000123", "04316", "LIBANO"											, "431", "5835", "LB", "LB", "431"  }  )
		aAdd( aBody, { "", "000124", "04340", "LIBERIA"											, "434", "5894", "LR", "LR", "434"  }  )
		aAdd( aBody, { "", "000125", "04383", "LIBIA"											, "438", "5940", "LY", "LY", "438"  }  )
		aAdd( aBody, { "", "000126", "04405", "LIECHTENSTEIN"									, "440", "5991", "LI", "LI", "440"  }  )
		aAdd( aBody, { "", "000127", "04421", "LITUANIA, REPUBLICA DA"							, "442", "6041", "LT", "LT", "442"  }  )
		aAdd( aBody, { "", "000128", "04456", "LUXEMBURGO"										, "445", "6106", "LU", "LU", "445"  }  )
		aAdd( aBody, { "", "000129", "04472", "MACAU"											, "447", "9938", "MO", "MO", "447"  }  )
		aAdd( aBody, { "", "000130", "04499", "MACEDONIA DO NORTE"								, "449", "9939", "MK", "MK", "449"  }  )
		aAdd( aBody, { "", "000131", "04502", "MADAGASCAR"										, "450", "6157", "MG", "MG", "450"  }  )
		aAdd( aBody, { "", "000132", "04525", "MADEIRA, ILHA DA"								, "452", ""    , ""  , ""  , "452"  }  )
		aAdd( aBody, { "", "000133", "04553", "MALASIA"											, "455", "6211", "MY", "MY", "455"  }  )
		aAdd( aBody, { "", "000134", "04588", "MALAVI"											, "458", "6270", "MW", "MW", "458"  }  )
		aAdd( aBody, { "", "000136", "04642", "MALI"											, "464", "6327", "ML", "ML", "464"  }  )
		aAdd( aBody, { "", "000137", "04677", "MALTA"											, "467", "6386", "MT", "MT", "467"  }  )
		aAdd( aBody, { "", "000102", "03595", "MAN, ILHA DE"									, "359", "9940", "IM", "IM", "359"  }  )
		aAdd( aBody, { "", "000138", "04723", "MARIANAS DO NORTE"								, "472", "9941", "MP", "MP", "472"  }  )
		aAdd( aBody, { "", "000139", "04740", "MARROCOS"										, "474", "6432", "MA", "MA", "474"  }  )
		aAdd( aBody, { "", "000140", "04766", "MARSHALL,ILHAS"									, "476", "9942", "MH", "MH", "476"  }  )
		aAdd( aBody, { "", "000141", "04774", "MARTINICA"										, "477", "9943", "MQ", "MQ", "477"  }  )
		aAdd( aBody, { "", "000142", "04855", "MAURICIO"										, "485", "6483", "MU", "MU", "485"  }  )
		aAdd( aBody, { "", "000143", "04880", "MAURITANIA"										, "488", "6548", "MR", "MR", "488"  }  )
		aAdd( aBody, { "", "000145", "04936", "MEXICO"											, "493", "6599", "MX", "MX", "493"  }  )
		aAdd( aBody, { "", "000027", "00930", "MIANMAR (BIRMANIA)"								, "093", "9944", "MM", "MM", "093"  }  )
		aAdd( aBody, { "", "000150", "04995", "MICRONESIA"										, "499", "9945", "FM", "FM", "499"  }  )
		aAdd( aBody, { "", "000144", "04901", "MIDWAY, ILHAS"									, "490", "9946", ""  , ""  , "490"  }  )
		aAdd( aBody, { "", "000152", "05053", "MOCAMBIQUE"										, "505", "6645", "MZ", "MZ", "505"  }  )
		aAdd( aBody, { "", "000146", "04944", "MOLDAVIA, REPUBLICA DA"							, "494", "6718", "MD", "MD", "494"  }  )
		aAdd( aBody, { "", "000147", "04952", "MONACO"											, "495", "6769", "MC", "MC", "495"  }  )
		aAdd( aBody, { "", "000148", "04979", "MONGOLIA"										, "497", "6815", "MN", "MN", "497"  }  )
		aAdd( aBody, { "", "000149", "04985", "MONTENEGRO"										, "498", ""	   , "ME", "ME", "498"  }  )
		aAdd( aBody, { "", "000151", "05010", "MONTSERRAT,ILHAS"								, "501", "9947", "MS", "MS", "501"  }  )
		aAdd( aBody, { "", "000153", "05070", "NAMIBIA"											, "507", "9948", "NA", "NA", "507"  }  )
		aAdd( aBody, { "", "000154", "05088", "NAURU"											, "508", "6874", "NR", "NR", "508"  }  )
		aAdd( aBody, { "", "000156", "05177", "NEPAL"											, "517", "6920", "NP", "NP", "517"  }  )
		aAdd( aBody, { "", "000157", "05215", "NICARAGUA"										, "521", "6971", "NI", "NI", "521"  }  )
		aAdd( aBody, { "", "000158", "05258", "NIGER"											, "525", "7048", "NE", "NE", "525"  }  )
		aAdd( aBody, { "", "000159", "05282", "NIGERIA"											, "528", "7099", "NG", "NG", "528"  }  )
		aAdd( aBody, { "", "000160", "05312", "NIUE,ILHA"										, "531", "9949", "NU", "NU", "531"  }  )
		aAdd( aBody, { "", "000161", "05355", "NORFOLK,ILHA"									, "535", "9950", "NF", "NF", "535"  }  )
		aAdd( aBody, { "", "000162", "05380", "NORUEGA"											, "538", "7145", "NO", "NO", "538"  }  )
		aAdd( aBody, { "", "000163", "05428", "NOVA CALEDONIA"									, "542", "9951", "NC", "NC", "542"  }  )
		aAdd( aBody, { "", "000165", "05487", "NOVA ZELANDIA"									, "548", "7218", "NZ", "NZ", "548"  }  )
		aAdd( aBody, { "", "000167", "05568", "OMA"												, "556", "7269", "OM", "OM", "556"  }  )
		aAdd( aBody, { "", "000250", ""		, "ORGANIZACOES INTERNACIONAIS"						, "997", ""	   , ""  , ""  , ""	    }  )
		aAdd( aBody, { "", "000168", ""		, "PACIFICO, ILHAS DO (ADMINIST. DOS EUA)"			, "563", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000169", "05665", "PACIFICO, ILHAS DO (POSSESSAO DOS EUA)"			, "566", "9978", ""  , ""  , "566"  }  )
		aAdd( aBody, { "", "000170", "05738", "PAISES BAIXOS (HOLANDA)"							, "573", "9952", "NL", "NL", "573"  }  )
		aAdd( aBody, { "", "000171", "05754", "PALAU"											, "575", "9953", "PW", "PW", "575"  }  )
		aAdd( aBody, { "", "000173", "05800", "PANAMA"											, "580", "7374", "PA", "PA", "580"  }  )
		aAdd( aBody, { "", "000164", "05452", "PAPUA NOVA GUINE"								, "545", "7420", "PG", "PG", "545"  }  )
		aAdd( aBody, { "", "000172", "05762", "PAQUISTAO"										, "576", "7471", "PK", "PK", "576"  }  )
		aAdd( aBody, { "", "000174", "05860", "PARAGUAI"										, "586", "7544", "PY", "PY", "586"  }  )
		aAdd( aBody, { "", "000175", "05894", "PERU"											, "589", "7595", "PE", "PE", "589"  }  )
		aAdd( aBody, { "", "000176", "05932", "PITCAIRN,ILHA"									, "593", "9955", "PN", "PN", "593"  }  )
		aAdd( aBody, { "", "000177", "05991", "POLINESIA FRANCESA"								, "599", "9956", "PF", "PF", "599"  }  )
		aAdd( aBody, { "", "000178", "06033", "POLONIA, REPUBLICA DA"							, "603", "7641", "PL", "PL", "603"  }  )
		aAdd( aBody, { "", "000180", "06114", "PORTO RICO"										, "611", "7650", "PR", "PR", "611"  }  )
		aAdd( aBody, { "", "000179", "06076", "PORTUGAL"										, "607", "7706", "PT", "PT", "607"  }  )
		aAdd( aBody, { "", "000186", ""		, "PROVISAO DE NAVIOS E AERONAVES"					, "990", ""    , ""  , ""  , ""	    }  )
		aAdd( aBody, { "", "000181", "06238", "QUENIA"											, "623", "7811", "KE", "KE", "623"  }  )
		aAdd( aBody, { "", "000182", "06254", "QUIRGUIZ, REPUBLICA"								, "625", "7870", "KG", "KG", "625"  }  )
		aAdd( aBody, { "", "000255", ""		, "QATAR"											, ""   , "7757", "QA", "QA", ""     }  )
		aAdd( aBody, { "", "000183", "06289", "REINO UNIDO"										, "628", "7986", "GB", "GB", "628"  }  )
		aAdd( aBody, { "", "000184", "06408", "REPUBLICA CENTRO-AFRICANA"						, "640", "8044", "CF", "CF", "640"  }  )
		aAdd( aBody, { "", "000185", "06475", "REPUBLICA DOMINICANA"							, "647", "8095", "DO", "DO", "647"  }  )
		aAdd( aBody, { "", "000187", "06602", "REUNIAO, ILHA"									, "660", "9957", "RE", "RE", "660"  }  )
		aAdd( aBody, { "", "000189", "06700", "ROMENIA"											, "670", "8192", "RO", "RO", "670"  }  )
		aAdd( aBody, { "", "000190", "06750", "RUANDA"											, "675", "8230", "RW", "RW", "675"  }  )
		aAdd( aBody, { "", "000191", "06769", "RUSSIA, FEDERACAO DA"							, "676", "8273", "RU", "RU", "676"  }  )
		aAdd( aBody, { "", "000194", "06858", "SAARA OCIDENTAL"									, "685", "9958", "EH", "EH", "685"  }  )
		aAdd( aBody, { "", "000193", "06781", "SAINT KITTS E NEVIS"								, "678", "9959", "KN", "KN", "678"  }  )
		aAdd( aBody, { "", "000197", "06912", "SAMOA AMERICANA"									, "691", "9961", "AS", "AS", "691"  }  )
		aAdd( aBody, { "", "000196", "06904", "SAMOA"											, "690", ""	   , "WS", "WS", "690"  }  )
		aAdd( aBody, { "", "000199", "06971", "SAN MARINO"										, "697", "8370", "SM", "SM", "697"  }  )
		aAdd( aBody, { "", "000202", "07102", "SANTA HELENA"									, "710", "9962", "SH", "SH", "710"  }  )
		aAdd( aBody, { "", "000203", "07153", "SANTA LUCIA"										, "715", "8419", "LC", "LC", "715"  }  )
		aAdd( aBody, { "", "000198", "06955", "SAO CRISTOVAO E NEVES,ILHAS"						, "695", "9963", "KN", "KN", "695"  }  )
		aAdd( aBody, { "", "000200", "07005", "SAO PEDRO E MIQUELON"							, "700", "9964", "PM", "PM", "700"  }  )
		aAdd( aBody, { "", "000201", "07056", "SAO VICENTE E GRANADINAS"						, "705", "9965", "VC", "VC", "705"  }  )
		aAdd( aBody, { "", "000204", "07285", "SENEGAL"											, "728", "8508", "SN", "SN", "728"  }  )
		aAdd( aBody, { "", "000206", "07358", "SERRA LEOA"										, "735", "8540", "SL", "SL", "735"  }  )
		aAdd( aBody, { "", "000207", "07370", "SERVIA"											, "737", ""	   , "RS", "RS", "737"  }  )
		aAdd( aBody, { "", "000205", "07315", "SEYCHELLES"										, "731", "8583", "SC", "SC", "731"  }  )
		aAdd( aBody, { "", "000209", "07447", "SIRIA, REPUBLICA ARABE DA"						, "744", "8672", "SY", "SY", "744"  }  )
		aAdd( aBody, { "", "000210", "07480", "SOMALIA"											, "748", "8710", "SO", "SO", "748"  }  )
		aAdd( aBody, { "", "000211", "07501", "SRI LANKA"										, "750", "8753", "LK", "LK", "750"  }  )
		aAdd( aBody, { "", "000212", "07544", "ESWATINI (ESSUATINI, SUAZILANDIA)"				, "754", "8818", "SZ", "SZ", "754"  }  )
		aAdd( aBody, { "", "000214", "07595", "SUDAO"											, "759", "8850", "SD", "SD", "759"  }  )
		aAdd( aBody, { "", "000215", "07641", "SUECIA"											, "764", "8893", "SE", "SE", "764"  }  )
		aAdd( aBody, { "", "000216", "07676", "SUICA"											, "767", "8931", "CH", "CH", "767"  }  )
		aAdd( aBody, { "", "000217", "07706", "SURINAME"										, "770", "8982", "SR", "SR", "770"  }  )
		aAdd( aBody, { "", "000218", "07722", "TADJIQUISTAO, REPUBLICA DO"						, "772", "9024", "TJ", "TJ", "772"  }  )
		aAdd( aBody, { "", "000219", "07765", "TAILANDIA"										, "776", "9067", "TH", "TH", "776"  }  )
		aAdd( aBody, { "", "000220", "07803", "TANZANIA, REP.UNIDA DA"							, "780", "9105", "TZ", "TZ", "780"  }  )
		aAdd( aBody, { "", "000224", "07919", "TCHECA, REPUBLICA"								, "791", "9966", "CZ", "CZ", "791"  }  )
		aAdd( aBody, { "", "000221", "07820", "TERRITORIO BRIT.OC.INDICO"						, "782", "9967", "IO", "IO", "782"  }  )
		aAdd( aBody, { "", "000225", "07951", "TIMOR LESTE"										, "795", "9968", "TP", "TP", "795"  }  )
		aAdd( aBody, { "", "000226", "08001", "TOGO"											, "800", "9199", "TG", "TG", "800"  }  )
		aAdd( aBody, { "", "000228", "08109", "TONGA"											, "810", "9237", "TO", "TO", "810"  }  )
		aAdd( aBody, { "", "000227", "08052", "TOQUELAU,ILHAS"									, "805", "9969", "TK", "TK", "805"  }  )
		aAdd( aBody, { "", "000229", "08150", "TRINIDAD E TOBAGO"								, "815", "9288", "TT", "TT", "815"  }  )
		aAdd( aBody, { "", "000230", "08206", "TUNISIA"											, "820", "9334", "TN", "TN", "820"  }  )
		aAdd( aBody, { "", "000231", "08230", "TURCAS E CAICOS,ILHAS"							, "823", "9979", "TC", "TC", "823"  }  )
		aAdd( aBody, { "", "000232", "08249", "TURCOMENISTAO, REPUBLICA DO"						, "824", "9970", "TM", "TM", "824"  }  )
		aAdd( aBody, { "", "000233", "08273", "TURQUIA"											, "827", "9415", "TR", "TR", "827"  }  )
		aAdd( aBody, { "", "000234", "08281", "TUVALU"											, "828", "9971", "TV", "TV", "828"  }  )
		aAdd( aBody, { "", "000235", "08311", "UCRANIA"											, "831", "9466", "UA", "UA", "831"  }  )
		aAdd( aBody, { "", "000236", "08338", "UGANDA"											, "833", "9504", "UG", "UG", "833"  }  )
		aAdd( aBody, { "", "000237", "08451", "URUGUAI"											, "845", "9687", "UY", "UY", "845"  }  )
		aAdd( aBody, { "", "000238", "08478", "UZBEQUISTAO, REPUBLICA DO"						, "847", "9725", "UZ", "UZ", "847"  }  )
		aAdd( aBody, { "", "000166", "05517", "VANUATU"											, "551", "9972", "VU", "VU", "551"  }  )
		aAdd( aBody, { "", "000239", "08486", "VATICANO, EST.DA CIDADE DO"						, "848", "9776", "VA", "VA", "848"  }  )
		aAdd( aBody, { "", "000240", "08508", "VENEZUELA"										, "850", "9814", "VE", "VE", "850"  }  )
		aAdd( aBody, { "", "000241", "08583", "VIETNA"											, "858", "9857", "VN", "VN", "858"  }  )
		aAdd( aBody, { "", "000242", "08630", "VIRGENS,ILHAS (BRITANICAS)"						, "863", "9973", "VN", "VN", "863"  }  )
		aAdd( aBody, { "", "000243", "08664", "VIRGENS,ILHAS (E.U.A.)"							, "866", "9974", "VI", "VI", "866"  }  )
		aAdd( aBody, { "", "000245", "08737", "WAKE, ILHA"										, "873", "9975", "UM", "UM", "873"  }  )
		aAdd( aBody, { "", "000246", "08753", "WALLIS E FUTUNA, ILHAS"							, "875", "9980", "WF", "WF", "875"  }  )
		aAdd( aBody, { "", "000248", "08907", "ZAMBIA"											, "890", "9954", "ZM", "ZM", "890"  }  )
		aAdd( aBody, { "", "000188", "06653", "ZIMBABUE"										, "665", "9976", "ZW", "ZW", "665"  }  )
		aAdd( aBody, { "", "000256", "8958"	, "ZONA DO CANAL DO PANAMÁ"							, "895", "9977", "PA", "PA", ""     }  )
		aAdd( aBody, { "", "000257", ""	    , "ALAND, ILHAS"									, "015", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000258", ""	    , "ANTARTICA"										, "042", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000259", ""	    , "BONAIRE, SAINT EUSTATIUS E SABA"					, "099", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000260", ""	    , "BOUVET, ILHA"									, "102", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000261", "2003", "CURACAO"											, "200", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000262", ""	    , "GEORGIA DO SUL E SANDWICH DO SUL, ILHAS"			, "292", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000263", ""	    , "GUERNSEY"										, "321", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000264", ""	    , "HEARD E ILHAS MCDONALD, ILHA"					, "343", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000265", ""	    , "JERSEY"											, "393", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000266", ""	    , "MAYOTTE"											, "489", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000267", ""	    , "SAO BARTOLOMEU"									, "693", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000268", ""	    , "SAO MARTINHO, ILHA DE (PARTE FRANCESA)"			, "698", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000269", ""	    , "SAO MARTINHO, ILHA DE (PARTE HOLANDESA)"			, "699", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000270", ""	    , "SVALBARD E JAN MAYEN"							, "755", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000271", ""	    , "SUDAO DO SUL"									, "760", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000272", ""	    , "TERRAS AUSTRAIS FRANCESAS"						, "781", ""    , ""  , ""  , ""     }  )
		aAdd( aBody, { "", "000273", ""		, "PALESTINA"										, "578", ""    , "PS", "PS", "578"  }  )
		aAdd( aBody, { "", "000274", ""		, "SAO TOME E PRINCIPE, ILHAS"						, "720", "7200", "ST", "ST", "720"  }  )
		aAdd( aBody, { "", "000275", "07200", "SAO TOME E PRINCIPE"								, "720", "8451", "ST", "ST", "720"  }  )

		aAdd( aRet, { aHeader, aBody } )

	EndIf

Return( aRet )
