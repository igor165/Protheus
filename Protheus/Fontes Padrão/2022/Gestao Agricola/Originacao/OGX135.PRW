#Include 'OGX135.ch'
#Include 'Protheus.ch'

/**{Protheus.doc} OGX135
Valida��o na Baixa de T�tulos a receber
Gerar titulos de comissao para a corretora
@param: 	Nil
@author: 	Jos� Leite de Barros Neto
@since: 	16/07/2013
@Uso: 		SIGAFIN - Financeiro
@Alterado Por: Marcelo R. Ferrari
Alterado em: 19/08/2014
**/
//Programa Original: ARMXPE18.PRW
Function OGX135()
	If FindFunction("OGXUTOG") //Encontra a fun��o
		If OGXUTOG()
			If FindFunction("OGX135A")
				OGX135A()
		   Endif
		Endif 
	EndIf
	
Return ( Nil )