#INCLUDE "PROTHEUS.CH"
#INCLUDE "RUP_AGR.CH"

/*{Protheus.doc}
Função de compatibilização do release incremental.
Serão chamadas todas as funções compiladas referentes aos módulos cadastrados do Protheus
Será sempre considerado prefixo "RUP_" acrescido do nome padrão do módulo sem o prefixo SIGA.

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA*/

Function RUP_AGR( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
	
	If cMode == '1' 
		// A decisão, no entanto, cabe ao desenvolvedor
		// A decisão de executar ou não pode estar condicionada a outros fatores
		
		If  cVersion == '12' 
			If cRelStart ==  '017' .and. cRelFinish = "023" //Ajustes para 12.1.23
				
				//Chamada para ajustes da SQUAD Beneficiamento - UBA e UBS
				RUP_UBS()
				
				//Chamada para ajustes da SQUAD Exportacao
				RUP_EXP()
				
				//Chamada para ajustes da SQUAD Comercial
				RUP_CMC()		
			EndIf   			
		
		
			If cRelStart >=  '023' .AND. cRelFinish <= "027"

				RUP_CMC25()	  //Contem alteraç?es das releases 12.1.25 e 12.1.27
				
			EndIf

			If (cRelStart >=  '025' .AND. cRelFinish <= "030") 
				
				RUP_CMC30()	  //Contem alteraç?es das releases 12.1.27 e 12.1.30
				
			EndIf

			If (cRelStart >=  '027' .AND. cRelFinish <= "033") 
				
				RUP_CMC33()	  //Contem alteraç?es das releases 12.1.33
				
			EndIf

			If (cRelStart >=  '033' .AND. cRelFinish <= "037") 				
				RUP_UBS37()	//Contem alteracoes das releases 12.1.37
			EndIf

		EndIf
		
	Endif
Return  Nil
