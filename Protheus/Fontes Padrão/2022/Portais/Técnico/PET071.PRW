User Function PET071()

Local cParam 	:= PARAMIXB[1]
Local aReturn 	:= {}         

Do Case
    Case cParam == 1    
   		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aadd( aReturn, "PRODUCTCODE" )
			aadd( aReturn, "DESCRIPTION" )
			aadd( aReturn, "SCIENCEDESCRIPTION" )
			aadd( aReturn, "DESCRIPTIONMEASUREUNIT" )
			aadd( aReturn, "DESCRIPTIONSECONDMEASUREUNIT" )
			aadd( aReturn, "DESCRIPTIONTYPEOFPRODUCT" )
			aadd( aReturn, "DESCRIPTIONGROUPOFPRODUCT" )
			aadd( aReturn, "NCM" )
			aadd( aReturn, "QUANTITYPERPACKAGE" )
			aadd( aReturn, "ORDERPOINT" )
			aadd( aReturn, "NETWEIGHT" )
			aadd( aReturn, "GROSSWEIGHT" )
			aadd( aReturn, "LEADTIME" )
			aadd( aReturn, "TYPEOFLEADTIME" )
			aadd( aReturn, "ECONOMICLOT" )
			aadd( aReturn, "MINIMUMLOT" )
			aadd( aReturn, "MINIMUMGRADE" )
			aadd( aReturn, "TERMOFVALIDATY" )
			aadd( aReturn, "BARCODE" )
			aadd( aReturn, "STORAGELENGHT" )
			aadd( aReturn, "STORAGEWIDTH" )
			aadd( aReturn, "STORAGEHEIGHT" )
			aadd( aReturn, "STORAGEMAXIMUMPILING" )
			aadd( aReturn, "STANDARDWAREHOUSE" )
    
	Case cParam == 2
								
    Case cParam == 3
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aadd( aReturn, "PRODUCTCODE" )
			aadd( aReturn, "QUANTITY" )
			aadd( aReturn, "CURRENCY" )
			aadd( aReturn, "CURRENCYSIMBOL" )
			aadd( aReturn, "TYPEOFBALANCE" )
			aadd( aReturn, "DESCRIPTIONTYPEOFBALANCE" )
			aadd( aReturn, "WAREHOUSE" )
	    
EndCase
						
Return aReturn