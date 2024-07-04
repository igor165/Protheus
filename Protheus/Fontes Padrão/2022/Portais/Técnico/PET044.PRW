User Function PET044()

Local cParam 	:= PARAMIXB[1]
Local aReturn 	:= {}         

Do Case
	Case cParam == 1 

	Case cParam == 2     
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aAdd( aReturn, "MANUFACTURERCODE" )
			aAdd( aReturn, "MANUFACTURERUNITCODE" )
			aAdd( aReturn, { "PRODUCTID", "D" } )
			aAdd( aReturn, { "SERIALNUMBER", "D" } )
			aAdd( aReturn, "QUANTITY" )
			aAdd( aReturn, "WAREHOUSE" )
			aAdd( aReturn, "WAREHOUSEADDRESS" )
			aAdd( aReturn, "SERVICE" )
			aAdd( aReturn, "PRIORMANUFACTURERCODE" )
			aAdd( aReturn, "PRIORMANUFACTURERUNITCODE" )
			aAdd( aReturn, "PRIORPRODUCTID" )
			aAdd( aReturn, "PRIORSERIALNUMBER" )
			aAdd( aReturn, "PRODUCTDESCRIPTION" )
			aAdd( aReturn, "REQUISITIONSEQUENCE" )
			aAdd( aReturn, "REQUISITIONITEM" )
			aAdd( aReturn, "LOT" )
			aAdd( aReturn, "SUBLOT" )

	Case cParam == 3 

	Case cParam == 4     
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		
		aAdd( aReturn, "MANUFACTURERCODE" )
		aAdd( aReturn, "MANUFACTURERUNITCODE" )
		aAdd( aReturn, { "PRODUCTID", "N", { "GETCATALOG", ;
																{ "CPRODUCTID", "CPRODUCTCODE" } ;
															}, ;
															{ "CPRODUCTCODE", "CDESCRIPTION" } } )
		aAdd( aReturn, "SERIALNUMBER" )
		aAdd( aReturn, "QUANTITY" )
		aAdd( aReturn, "WAREHOUSE" )
		aAdd( aReturn, "WAREHOUSEADDRESS" )
		aAdd( aReturn, "SERVICE" )
		aAdd( aReturn, "PRIORMANUFACTURERCODE" )
		aAdd( aReturn, "PRIORMANUFACTURERUNITCODE" )
		aAdd( aReturn, "PRIORPRODUCTID" )
		aAdd( aReturn, "PRIORSERIALNUMBER" )
		aAdd( aReturn, "PRODUCTDESCRIPTION" )
		aAdd( aReturn, "REQUISITIONSEQUENCE" )
		aAdd( aReturn, "REQUISITIONITEM" )
		aAdd( aReturn, "LOT" )
		aAdd( aReturn, "SUBLOT" )
EndCase
						
Return aReturn