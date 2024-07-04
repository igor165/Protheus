User Function PET063()

Local cParam 	:= PARAMIXB[1]
Local aReturn 	:= {}         

Do Case
    Case cParam == 1    
   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos a serem mostrados             									³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
		   	aAdd( aReturn, "SERVICEORDERID" )
			aAdd( aReturn, "INITIALDATE" )
			aAdd( aReturn, "INITIALTIME" )
			aAdd( aReturn, "FINALDATE" )
			aAdd( aReturn, "FINALTIME" )
			aAdd( aReturn, "CONFIRMED" )
			aAdd( aReturn, "ATTENDED" )
			aAdd( aReturn, "SERVED" )
			aAdd( aReturn, "NOTE" )
    
	Case cParam == 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos a serem mostrados             									³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd( aReturn, "SERVICEORDERID" )
			aAdd( aReturn, "INITIALDATE" )
			aAdd( aReturn, "INITIALTIME" )
			aAdd( aReturn, "FINALDATE" )
			aAdd( aReturn, "FINALTIME" )
			aAdd( aReturn, "CONFIRMED" )
			aAdd( aReturn, "ATTENDED" )
			aAdd( aReturn, "SERVED" )
			aAdd( aReturn, "NOTE" )
								
    Case cParam == 3
    
EndCase
						
Return aReturn