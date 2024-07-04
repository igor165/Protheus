#include 'protheus.ch'
#include 'parmtype.ch'

user function EXECCOL()
	
	COLAUTOREAD()
	
	SCHEDCOMCOL()
	
	Alert("Execução concluída")
	
return Nil