User Function PET031()

Local cParam 	:= PARAMIXB[1]
Local aReturn 	:= {}         

Do Case
	Case cParam == 1
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
			aAdd( aReturn, { "CUSTOMERCODE", "N", { "BRWCUSTOMER", ;
																{ "CCUSTOMERCODE", "CCODE" }, ;
																{ "CUNITCUSTOMERCODE", "CUNIT" } ;
															}, ;
															{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
			aAdd( aReturn, "UNITCUSTOMERCODE" ) 

	Case cParam == 2
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aAdd( aReturn, { "PRODUCTCODE", "N", { "GETCATALOG", ;
																{ "CPRODUCTCODE", "CPRODUCTCODE" };
															}, ;
															{ "CPRODUCTCODE", "CDESCRIPTION" } } )
															
	Case cParam == 3
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aAdd( aReturn, "CUSTOMERCODE" )
			aAdd( aReturn, "UNITCUSTOMERCODE" )
			aAdd( aReturn, "PRODUCTCODE" )
			aAdd( aReturn, "SERIALNUMBER" )
			aAdd( aReturn, "MANUFACTURERCODE" )
			aAdd( aReturn, "UNITMANUFACTURERCODE" )
		
EndCase
						
Return aReturn