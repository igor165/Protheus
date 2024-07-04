User Function PET114()

Local cParam 	:= PARAMIXB[1]
Local aReturn 	:= {}         

Do Case
	Case cParam == 1
	
    Case cParam == 2    
   		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
			aAdd( aReturn, "SERVICESTATUS" )
			aAdd( aReturn, { "PRODUCTID", "N", { "GETCATALOG", ;
															{ "CPRODUCTID", "CPRODUCTCODE" } ;
														}, ;
														{ "CPRODUCTCODE", "CDESCRIPTION" } } )
			aAdd( aReturn, "SERIALNUMBER" )
			aAdd( aReturn, "FAILURE" )
			aAdd( aReturn, "NOTES" )
			aAdd( aReturn, "SERVICEORDERID" )
			aAdd( aReturn, "SERVICECALLID" )
    
	Case cParam == 3
	Case cParam == 4
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aAdd( aReturn, "SERVICESTATUS" )
			aAdd( aReturn, { "PRODUCTID", "N", { "GETCATALOG", ;
															{ "CPRODUCTID", "CPRODUCTCODE" } ;
														}, ;
														{ "CPRODUCTCODE", "CDESCRIPTION" } } )
			aAdd( aReturn, "SERIALNUMBER" )
			aAdd( aReturn, "FAILURE" )
			aAdd( aReturn, "NOTES" )
			aAdd( aReturn, "SERVICEORDERID" )
			aAdd( aReturn, "SERVICECALLID" )
								

    
EndCase
						
Return aReturn