#INCLUDE "TOTVS.CH"
#INCLUDE "LJVALIDSX6.CH"

/*/
{Protheus.doc} LJVALIDSX6
Fun��o macro responsavel por chamar a funcao especifica da validacao do Par�metro
@type		function
@return		lRet - indica se o conte�do � v�lido
@author  	michael.gabriel
@version 	P11.80
@since   	21/07/2017
/*/
Function  LJVALIDSX6()
Local lRet		:= .T.
//Retirado o Valid do SX6 da rotina, de acordo com nova diretiva do SONARQUBE, s� pode  fazer leitura do SX6 atrav�s das fun��es.
//o fonte se tornar� obsoleto a partir da vers�o 12.1.31
//sobre rotinas originais vide historico pelo TFS
Return lRet