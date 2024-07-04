User Function PET023()

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
		aAdd( aReturn, "ISSUEDATE" )
		aAdd( aReturn, "ATTENDANT" )
		aAdd( aReturn, { "PAYMENTPLANCODE", "N", { "BRWPAYMENTPLAN", ;
															{ "CPAYMENTPLANCODE", "CPAYMENTPLANCODE" } ;
														}, ;
														{ "CPAYMENTPLANCODE", "CDESCRIPTIONPAYMENTPLAN" } } )
		aAdd( aReturn, "DISCOUNT1" )
		aAdd( aReturn, "DISCOUNT2" )
		aAdd( aReturn, "DISCOUNT3" )
		aAdd( aReturn, "DISCOUNT4" )
		aAdd( aReturn, "PRICELISTCODE" )
		aAdd( aReturn, "INSTALLMENT1" )
		aAdd( aReturn, "INSTALLMENT2" )
		aAdd( aReturn, "INSTALLMENT3" )
		aAdd( aReturn, "INSTALLMENT4" )
		aAdd( aReturn, "DUEDATE1" )
		aAdd( aReturn, "DUEDATE2" )
		aAdd( aReturn, "DUEDATE3" )
		aAdd( aReturn, "DUEDATE4" )
		aAdd( aReturn, "SERVICEORDERTIME" )
		aAdd( aReturn, "MESSAGE" )
		aAdd( aReturn, "CURRENCY" )
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
		aAdd( aReturn, "ISSUEDATE" )
		aAdd( aReturn, "ATTENDANT" )
		aAdd( aReturn, { "PAYMENTPLANCODE", "N", { "BRWPAYMENTPLAN", ;
															{ "CPAYMENTPLANCODE", "CPAYMENTPLANCODE" } ;
														}, ;
														{ "CPAYMENTPLANCODE", "CDESCRIPTIONPAYMENTPLAN" } } )
		aAdd( aReturn, "DISCOUNT1" )
		aAdd( aReturn, "DISCOUNT2" )
		aAdd( aReturn, "DISCOUNT3" )
		aAdd( aReturn, "DISCOUNT4" )
		aAdd( aReturn, "PRICELISTCODE" )
		aAdd( aReturn, "INSTALLMENT1" )
		aAdd( aReturn, "INSTALLMENT2" )
		aAdd( aReturn, "INSTALLMENT3" )
		aAdd( aReturn, "INSTALLMENT4" )
		aAdd( aReturn, "DUEDATE1" )
		aAdd( aReturn, "DUEDATE2" )
		aAdd( aReturn, "DUEDATE3" )
		aAdd( aReturn, "DUEDATE4" )
		aAdd( aReturn, "SERVICEORDERTIME" )
		aAdd( aReturn, "MESSAGE" )
		aAdd( aReturn, "CURRENCY" )
EndCase
						
Return aReturn