User Function PET054()

Local cParam 	:= PARAMIXB[1]
Local aReturn 	:= {}         

Do Case
	Case cParam == 1

	Case cParam == 2
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aAdd( aReturn, { "PRODUCTID", "D" } )
		aAdd( aReturn, "QUANTITY" )
		aAdd( aReturn, { "MEASUREUNIT", "D" } )
		aAdd( aReturn, "SERVICECODE" )
		aAdd( aReturn, "SECONDMEASUREUNITQUANTITY" )
		aAdd( aReturn, "SECONDMEASUREUNIT" )
		aAdd( aReturn, "TECHNICIANCODE" )
		aAdd( aReturn, "SEQUENCE" )
	Case cParam == 3

	Case cParam == 4
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aAdd( aReturn, { "PRODUCTID", "N", { "GETCATALOG", ;
																	{ "CPRODUCTID", "CPRODUCTCODE" } ;
																}, ;
																{ "CPRODUCTCODE", "CDESCRIPTION" } } )
			aAdd( aReturn, "QUANTITY" )
			aAdd( aReturn, { "MEASUREUNIT", "D" } )
			aAdd( aReturn, "SERVICECODE" )
			aAdd( aReturn, "SECONDMEASUREUNITQUANTITY" )
			aAdd( aReturn, "SECONDMEASUREUNIT" )
			aAdd( aReturn, "TECHNICIANCODE" )
			aAdd( aReturn, "SEQUENCE" )        								
	
EndCase
						
Return aReturn