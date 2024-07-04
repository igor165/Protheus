User Function PET053()

Local cParam 	:= PARAMIXB[1]
Local aReturn 	:= {}         

Do Case
	Case cParam == 1

	Case cParam == 2
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Campos a serem mostrados             									Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aAdd( aReturn, "ISSUEDATE" )
			aAdd( aReturn, "SERVICEORDERITEM" )
			aAdd( aReturn, "REQUISITIONSEQUENCE" )
			aAdd( aReturn, "TECHNICIANCODE" )
			aAdd( aReturn, "PETITIONER" )
								
	
EndCase
						
Return aReturn