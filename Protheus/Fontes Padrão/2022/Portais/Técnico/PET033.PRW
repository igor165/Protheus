User Function PET033()

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
			aAdd( aReturn, { "PRODUCTCODE", "N", { "GETCATALOG", ;
																{ "CPRODUCTCODE", "CPRODUCTCODE" } ;
															}, ;
															{ "CPRODUCTCODE", "CDESCRIPTION" } } )
			aAdd( aReturn, "SERIALNUMBER" )
			aAdd( aReturn, "MANUFACTURERCODE" )
			aAdd( aReturn, "UNITMANUFACTURERCODE" )
			aAdd( aReturn, "SUPPLIERCODE" )
			aAdd( aReturn, "UNITSUPPLIERCODE" )
			aAdd( aReturn, "SALESDATE" )
			aAdd( aReturn, "INSTALLATIONDATE" )
			aAdd( aReturn, "WARRANTYDATE" )
			aAdd( aReturn, "INSTALLATIONTECHNICIAN" )
			aAdd( aReturn, "INVOICENUMBER" )
			aAdd( aReturn, "NOTE" )
			aAdd( aReturn, "CONTRACTNUMBER" )
			aAdd( aReturn, "PREVENTIVENUMBER" )
			aAdd( aReturn, "MODEL" )
			aAdd( aReturn, "ACCUMULATOR" )
			aAdd( aReturn, "MTBF" )
			aAdd( aReturn, "MTTR" )

	Case cParam == 2
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aAdd( aReturn, { "CUSTOMERCODE", "N", { "BRWCUSTOMER", ;
																{ "CCUSTOMERCODE", "CCODE" }, ;
																{ "CUNITCUSTOMERCODE", "CUNIT" } ;
															}, ;
															{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
			aAdd( aReturn, "UNITCUSTOMERCODE" )
			aAdd( aReturn, { "PRODUCTCODE", "N", { "GETCATALOG", ;
																{ "CPRODUCTCODE", "CPRODUCTCODE" } ;
															}, ;
															{ "CPRODUCTCODE", "CDESCRIPTION" } } )
			aAdd( aReturn, "SERIALNUMBER" )
			aAdd( aReturn, "MANUFACTURERCODE" )
			aAdd( aReturn, "UNITMANUFACTURERCODE" )
			aAdd( aReturn, "SUPPLIERCODE" )
			aAdd( aReturn, "UNITSUPPLIERCODE" )
			aAdd( aReturn, "SALESDATE" )
			aAdd( aReturn, "INSTALLATIONDATE" )
			aAdd( aReturn, "WARRANTYDATE" )
			aAdd( aReturn, "INSTALLATIONTECHNICIAN" )
			aAdd( aReturn, "INVOICENUMBER" )
			aAdd( aReturn, "NOTE" )
			aAdd( aReturn, "CONTRACTNUMBER" )
			aAdd( aReturn, "PREVENTIVENUMBER" )
			aAdd( aReturn, "MODEL" )
			aAdd( aReturn, "ACCUMULATOR" )
			aAdd( aReturn, "MTBF" )
			aAdd( aReturn, "MTTR" )
								
	
EndCase
						
Return aReturn