
/*
@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada Ex: 005 
@param  cLocaliz   - Localização (país). Ex: BRA 
*/

Function RUP_SFC(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

	If cVersion >= "12" 
	
		If cMode == "2"

			If cRelStart <= "007" .And. cRelFinish >= "007"
	
				AjustaSX3()
	
			ElseIf cRelStart <= "014" .And. cRelFinish >= "015"
				AjSX3_1_15()
			Endif
		EndIf
	EndIf

Return Nil

Static Function AjustaSX3()

dbSelectArea('SX3')
SX3->(dbSetOrder(2))
if SX3->(dbSeek('CYV_DSMQ'))
	RecLock('SX3',.F.)
	SX3->X3_RELACAO := 'IF(!INCLUI,POSICIONE("CYB",1,XFILIAL("CYB")+CYV->CYV_CDMQ,"CYB_DSMQ"),"")'
	SX3->(MsUnLock())
Endif      

Return

Static Function AjSX3_1_15()  

If SX3->(dbSeek("CYY_DSAC"))
   RecLock("SX3",.F.)
   SX3->X3_INIBRW  := 'Posicione("CZ3", 1, XFILIAL("CZ3")+CYY->CYY_CDAC, "CZ3_DSAC" )'
   SX3->X3_RELACAO := 'IF(!INCLUI,Posicione("CZ3", 1, XFILIAL("CZ3")+CYY->CYY_CDAC, "CZ3_DSAC" ),"")'
   SX3->( MsUnlock() )
EndIf

Return  