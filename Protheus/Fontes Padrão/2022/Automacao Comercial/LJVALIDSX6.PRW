#INCLUDE "TOTVS.CH"
#INCLUDE "LJVALIDSX6.CH"

/*/
{Protheus.doc} LJVALIDSX6
Função macro responsavel por chamar a funcao especifica da validacao do Parâmetro
@type		function
@return		lRet - indica se o conteúdo é válido
@author  	michael.gabriel
@version 	P11.80
@since   	21/07/2017
/*/
Function  LJVALIDSX6()
Local lRet		:= .T.
//Retirado o Valid do SX6 da rotina, de acordo com nova diretiva do SONARQUBE, só pode  fazer leitura do SX6 através das funções.
//o fonte se tornará obsoleto a partir da versão 12.1.31
//sobre rotinas originais vide historico pelo TFS
Return lRet