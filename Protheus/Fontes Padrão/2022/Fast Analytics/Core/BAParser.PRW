#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} BAParseQuery
Parse da query da entidade, parseia empresa e chaves.

@param cCompany, String, Empresa injetada.
@param cQuery, String, query a ser parseada.

@return cQuery, String, query parseada, exemplo: "SELECT * FROM SA1T10"

@author  Helio Leal
@since   04/10/2017
/*/
//-------------------------------------------------------------------
Function BAParseQuery( cQuery, cCompany )

Return BIParseQuery( cQuery, cCompany )

//-------------------------------------------------------------------
/*/{Protheus.doc} BAParseCompany
Efetua parse da query por empresa no formato <<Table_COMPANY>> para TableEMPRESA
Exemplo:
<<SA1_COMPANY>>, se transforma em: SA1T10 ou SA1010.

@param cQuery, String, Query.
@param cCompany, String, Empresa injetada.

@return cQuery, consulta com as empresas macro executadas. 

@author Helio Leal
@since 04/10/2017 
/*/
//-------------------------------------------------------------------- 
Function BAParseCompany( cQuery, cCompany )

Return BIParseCompany( cQuery, cCompany )

//------------------------------------------------------------------- 
/*/{Protheus.doc} BAParseKey 
Retorna a query com chaves no formato correto 

@param, cQuery, String, Query.

@author Helio Leal 
@author Andr�ia Lima 
@since 13/09/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BAParseKey( cQuery )

Return BIParseKey( cQuery )

//------------------------------------------------------------------- 
/*/{Protheus.doc} BABuildBK 
Retorna a Business Key no formato correto (pipeado) 

@param cKey, String, Key.

@author Helio Leal 
@author Andr�ia Lima 
@since 13/09/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BABuildBK( cKey ) 

Return BIBuildBK( cKey )


//------------------------------------------------------------------- 
/*/{Protheus.doc} BAPrefixBK
Prefixo da Business key.

@param  cKey, String, Key.
@Return cPrefixBK, String, Retorna o prefixo da Business key

@author Andr�ia Lima
@since 07/11/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BAPrefixBK( cKey )

Return BIPrefixBK( cKey )

//------------------------------------------------------------------- 
/*/{Protheus.doc} BAGetTbName
Obt�m o nome da tabela.

@param  cKey, String, Key.
@Return cTable, String, Retorna o nome da tabela.

@author Helio Leal
@since 21/11/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BAGetTbName( cKey )
	
Return BIGetTbName( cKey )

//------------------------------------------------------------------- 
/*/{Protheus.doc} BAKeyCompany
Parse na Business key de empresa.

@Return cQuery, String, Retorna a query com a Business key da empresa.

@author Andr�ia Lima
@since 06/11/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BAKeyCompany( cQuery, cCompany )

Return BIKeyCompany( cQuery, cCompany )

//------------------------------------------------------------------- 
/*/{Protheus.doc} BAKeyFilial
Parse na Business key de filial.

@Return cQuery, String, Retorna a query com a Business key da filial.

@author Andr�ia Lima
@since 06/11/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BAKeyFilial( cQuery, cCompany )

Return BIKeyFilial( cQuery, cCompany )

//------------------------------------------------------------------- 
/*/{Protheus.doc} BASubStrFil
Parse das Subtrings da query para o campo filial.

@param cQuery, string
@param cField, string, campo filial.
@param cTable, string, alias a ser verificado.
@param cCompany, string, empresa 
@Return cQuery, String, Retorna a query com o Substr correto para o banco utilizado.

@author Helio Leal
@since 14/11/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BASubStrFil(cQuery, cCompany)

Return BISubStrFil(cQuery, cCompany)

//------------------------------------------------------------------- 
/*/{Protheus.doc} BARTrimField
Aplica RTRIM (string) para cada campo da chave composta BK

@param cFields, String, chave(BK) composta por campos.
@Return cTrimField, String, Retorna a chave(BK) composta com RTRIM nos campos.

@author Marcia Junko
@author Angelo Lee
@since 20/12/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BARTrimField( cFields )
	
Return BIRTrimField( cFields )

//------------------------------------------------------------------- 
/*/{Protheus.doc} BANullField
Protecao caso o valor do campo chave da dimensao na fato esteja nulo

@param cFields, String, chave(BK) composta por campos.
@Return cNullField, String, Campos com a protecao ISNULL

@author Marcia Junko
@author Angelo Lee
@since 20/12/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BANullField( cFields )
	
Return BINullField(cFields)

//------------------------------------------------------------------- 
/*/{Protheus.doc} BASubStr2Fil
Parse das Subtrings da query para o campo filial olhando uma tabela 
que nao esta na query
Exemplo: fato de auditoria - tabela da Fato O0H, mas deve olhar a
filial de processos NSZ que nao esta na query.

@param cQuery, string
@param cField, string, campo filial.
@param cTable, string, alias a ser verificado.
@param cCompany, string, empresa 
@Return cQuery, String, Retorna a query com o Substr correto para o banco utilizado.

@author Helio Leal
@since 14/11/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BASubStr2Fil(cQuery, cCompany)

Return BISubStr2Fil(cQuery, cCompany)

//------------------------------------------------------------------- 
/*/{Protheus.doc} BAFilialLen
Retorna o tamanho do campo filial de uma determinada tabela baseado somente
nos compartilhamentos exclusivos.

@param cTable, string, alias a ser verificado.
@param cCompany, string, empresa 

@Return cQuery, String, Retorna a query com o Substr correto para o banco utilizado.

@author Helio Leal
@since 14/11/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BAFilialLen(cTable, cCompany)

Return BIFilialLen(cTable, cCompany)

//------------------------------------------------------------------- 
/*/{Protheus.doc} BASubFilial
Retorna o comando substring tratado por banco.

@param cCompany, string, empresa 
@param cField, string, campo filial.
@param cDim, string, tabela dimens�o a ser analisada.
@param cFact, string, tabela fato a ser analisada. ( Esse parametro deve ser informado se o lComplete for .T. )  
@param lComplete, boolean, verifica se a tratativa da substring deve ser completa. E considerado como completo 
o valor inteiro da substring, exemplo: fato D MG e dimensao D MG 01, com o lComplete a comparacao e feita de forma
que o campo filial da dimensao complete o valor da fato, nesse exemplo ficaria Campo_Filial_Fato + SubStr( Campo_Filial_Dimens�o, N, Y )
Nesse exemplo ficaria D MG da fato e 01 da dimensao.

@Return cStmt, String, Formato do campo filial.

@author Andreia Lima
@since 02/03/2018 
/*/ 
//-------------------------------------------------------------------- 
Function BASubFilial( cCompany, cField, cDim, lComplete, cFact )

Return BISubFilial( cCompany, cField, cDim, lComplete, cFact )

//------------------------------------------------------------------- 
/*/{Protheus.doc} BARetSubFilial
Retorna a comparacao do campo filial considerando os compartilhamentos da fato e da dimensao. 
Segue algumas informacoes:
 * Para ambientes com gestao:
 	- Caso o compartilhamento da dimensao e da fato forem iguais, ha uma comparacao direta da dimensao com a fato.
 	- Caso o compartilhamento da dimensao seja maior (mais exclusivo) que o da fato, ha uma comparacao do campo
 	filial da fato + final do campo filial da dimensao. Exemplo: dimensao D MG 01 e fato D MG, a comparacao deve
 	ser substring(cpo_filial_fato, 1, 5) + substring(cpo_filial_dimensao, 6, 8).
 	- Caso o compartilhamento da fato seja maior (mais exclusivo), o campo filial da fato recebera um substr 
 	para ser comparado com a dimensao. Exemplo: Fato D MG 01, Dimensao D MG, entao e feito o seguinte: 
 	substring(cpo_filial_fato, 1, 5).
 	- Se o compartilhamento da fato for maior que o da dimensao e o compartilhamento da dimensao for totalmente
 	compartilhado, o campo e comparado com vazio. 
 * Para ambiente sem gestao.
 	- Caso o compartilhamento da dimensao e da fato forem iguais, ha uma comparacao direta da dimensao com a fato.
 	- Caso o compartilhamento da dimensao nao seja vazio e da fato seja vazio, compara a o campo filial com ela mesmo
 	nesse caso evitamos que a query nao traga resultados.
 	- Caso o compartilmaneto da dimensao esteja vazio, comparamos ela com o tamanho da filial do sistema, atraves da
 	funcao FWSizeFilial.

@param cCompany, string, empresa 
@param cDim, string, alias a ser verificado, tabela origem.
@param cFact, String, tabela principal, fato.
@param cField, string, campo filial da fato.
@param pcAlias, string, alias utilizado na comparacao.

@Return cQuery, String, Retorna o valor correto a ser comparado com o campo filial da dimensao.

@author Helio Leal
@since 15/03/2018
/*/ 
//-------------------------------------------------------------------- 
Function BARetSubFilial(cCompany, cDim, cFact, cField, pcAlias)

Return BIRetSubFilial(cCompany, cDim, cFact, cField, pcAlias)

//-------------------------------------------------------------------
/*/{Protheus.doc} BAParseFilial
Parse da filial da entidade

@param cCompany, String, Empresa injetada.
@param cQuery, String, query a ser parseada.

@return cQuery, String, query parseada, exemplo: "SELECT * FROM SA1T10"

@author  Andreia Lima
@since   13/04/2018
/*/
//-------------------------------------------------------------------
Function BAParseFilial( cQuery, cCompany )
	
Return BIParseFilial( cQuery, cCompany )

//-------------------------------------------------------------------
/*/{Protheus.doc} BASubxFilial
Parse do <<SUBSTR...>> por filial
@param cQuery, String, query a ser parseada.
@return cQuery, String, query parseada, exemplo: "SELECT * FROM SA1T10"

@author  Andreia Lima
@since   13/04/2018
/*/
//-------------------------------------------------------------------
Function BASubxFilial( cQuery, cMacro )
	
Return BISubxFilial( cQuery, cMacro )

//-------------------------------------------------------------------
/*/{Protheus.doc} BAMacroFilial
Substitui a macro de filial 
@param cQuery, String, query a ser parseada.
@param cMacro, String, macro a ser substituida.
@return cQuery, String, query parseada

@author  Andreia Lima
@since   23/04/2018
/*/
//-------------------------------------------------------------------
Function BAMacroFilial( cQuery, cMacro )
	
Return BIMacroFilial( cQuery, cMacro )

//-------------------------------------------------------------------
/*/{Protheus.doc} BAParseValue
Formata campo de valor adicionando casas decimais
@param cQuery, String, query.
@return cQuery, String, query parseada
@author Andreia Lima
@since 04/12/2018
/*/
//-------------------------------------------------------------------
Function BAParseValue( cQuery )

Return BIParseValue( cQuery )

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFormatValue
Aplica casas decimais de acordo com o banco de dados 
@param cValue, String, campo de valor.
@return cField, String, campo com tratamento de decimal
@author Andreia Lima
@since 04/12/2018
/*/
//-------------------------------------------------------------------
Function BAFormatValue( cValue )
	
Return BIFormatValue( cValue )

