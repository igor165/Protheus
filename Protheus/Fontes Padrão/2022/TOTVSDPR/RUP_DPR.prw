
/*
@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada Ex: 005 
@param  cLocaliz   - Localização (país). Ex: BRA 
*/

Function RUP_DPR(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

	If cVersion >= "12"

		If cMode == "2"

			AjustaSX9()

		EndIf
	EndIf

Return Nil

Static Function AjustaSX9()

dbSelectArea('SX9')
SX9->(dbSetOrder(2))
if SX9->(dbSeek('DG0'+'DG1'))
	RecLock('SX9',.F.)
	SX9->(dbDelete())
	SX9->(MsUnLock())
Endif        

Return  