User Function PET070()

Local cParam 	:= PARAMIXB[1]
Local aReturn 	:= {}         

Do Case
    Case cParam == 1    
   		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    
			aAdd( aReturn, "PRODUCTCODE" )
			aAdd( aReturn, "DESCRIPTION" )
			aAdd( aReturn, { "GROUPOFPRODUCT", "N", { "GETGROUPOFPRODUCT", ;
																{ "CGROUPOFPRODUCT", "CGROUPCODE" };
															}, ;
															{ "CGROUPCODE", "CDESCRIPTION" } } )
			aAdd( aReturn, { "TYPEOFPRODUCT", "N", { "GETTYPEOFPRODUCT", ;
																{ "CTYPEOFPRODUCT", "CCODE" };
															}, ;
															{ "CCODE", "CDESCRIPTION" } } )
    
	Case cParam == 2
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aAdd( aReturn, "CODE" )
			aAdd( aReturn, "DESCRIPTION" )

								
    Case cParam == 3
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aadd( aReturn, "PRODUCTCODE" )
			aadd( aReturn, "DESCRIPTION" )
	    
EndCase
						
Return aReturn