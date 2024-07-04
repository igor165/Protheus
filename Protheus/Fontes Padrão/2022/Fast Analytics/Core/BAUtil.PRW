#INCLUDE "PROTHEUS.CH"
//------------------------------------------------------------------- 
/*/{Protheus.doc} BACheckChr 
Verifica se a string contem apenas os caracteres [0..9][A..Z] 

@param, cText, String, Texto a ser analisado.
@Return lValidKey, Boolean, Retorna se o texto e valido. 

@author Andreia Lima 
@since 28/09/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BACheckChr( cText ) 

Return BICheckChr( cText )

//-------------------------------------------------------------------
/*/{Protheus.doc} BAGetShare
Define a tabela de origem dos dados no Protheus.

@param, cTable, String, Tabela Origem.

@Return cShare, Retorna o nome da origem da entidade.

@author  Helio Leal
@since   12/09/2017
/*/
//-------------------------------------------------------------------
Function BAGetShare( cTable )  

Return BIGetShare( cTable )

//-------------------------------------------------------------------
/*/{Protheus.doc} BAClass
Instancia uma classe.

@param cSource, caracter, Fonte da entidade. 
@return oObject, Instancia da classe. 

@author Andreia Lima  
@since   11/09/2017
/*/
//-------------------------------------------------------------------
Function BAClass( cSource )

Return BIClass( cSource )

//-------------------------------------------------------------------
/*/{Protheus.doc} BAInstance
Retorna a instancia da instalacao atual do Protheus.

@return string, instancia atual do Protheus.

@author Helio Leal  
@since   27/09/2017
/*/
//-------------------------------------------------------------------
Function BAInstance()
Return BIInstance()

//------------------------------------------------------------------- 
/*/{Protheus.doc} BAValidKey 
Verifica se a key esta no formato esperado, exemplo <<KEY_SA1_FIELD>> 

@param, cKey, String, Key.
@Return lValidKey, Boolean, Retorna se a Key e valida 

@author Andreia Lima 
@since 28/09/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BAValidKey( cKey ) 

Return BIValidKey( cKey )

//------------------------------------------------------------------- 
/*/{Protheus.doc} BACrypt
Criptografa a string passada para a funcao.

@param, cText, String, variavel que receberao o texto que sera criptografado.
@Return cText, String, Retorna o texto criptografado caso o parametro nao seja vazio.

@author Helio Leal
@author Angelo Lee
@since 11/10/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BACrypt( cText )

Return BICrypt( cText ) 

//------------------------------------------------------------------- 
/*/{Protheus.doc} BAIsGestao
Verifica se o ambiente utiliza gestao de empresas.

@Return boolean, Retorna se o ambiente e gestao de empresas.

@author Helio Leal
@since 16/03/2018 
/*/ 
//-------------------------------------------------------------------- 
Function BAIsGestao( )
Return BIIsGestao( )

//------------------------------------------------------------------- 
/*/{Protheus.doc} BACompShare
Compara o compartilhamento de duas tabelas.
E considerada maior a tabela que tiver os niveis de compartilhamentos
exclusivos maiores.
	Exemplo: se tabela 1 tiver o compartilhamento EEE e a 2 EEC, a 1 e 
maior que a 2.

@param cTable1, String, tabela 1.
@param cTable2, String, tabela 2.
@Return int, 0 = se forem iguais, 1 = se tabela 1 for maior que a tabela 2, -1 = se a tabela 2 for maior que a tabela 1 

@author Helio Leal
@since 16/03/2018 
/*/ 
//-------------------------------------------------------------------- 
Function BACompShare( cTable1, cTable2, cCompany )

Return BICompShare( cTable1, cTable2, cCompany )

//------------------------------------------------------------------- 
/*/{Protheus.doc} BAGetFilialExec
Recebe o tipo de execucao do arquivo Appserver.ini (por empresa ou filial)

@Return boolean, true = execucao por filial, false = execucao por empresa.

@author Helio Leal
@since 12/04/2018 
/*/ 
//--------------------------------------------------------------------
Function BAGetFilialExec()

Return BIGetFilialExec()

//------------------------------------------------------------------- 
/*/{Protheus.doc} BAExtractAlias
Extrai o Alias de um campo

@Return string, cAliasField, Alias do campo

@author Andreia Lima
@since 24/04/2018 
/*/ 
//--------------------------------------------------------------------
Function BAExtractAlias( cField )
	
Return BIExtractAlias( cField )

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFindX3
Verifica se o campo esta cadastrado no SX3.

@param cCampo, caracter, Nome do campo a ser pesquisado
@return lFind, Retorna .T. se o campo for encontrado no SX3.

@author  Marcia Junko
@since   05/11/2018
/*/
//-------------------------------------------------------------------
function BAFindX3( cCampo )

return BIFindX3(cCampo)

//-------------------------------------------------------------------
/*/{Protheus.doc} BALoadMoeda
Retorna a quantidade de moedas utilizadas pelo sistema

@return aMoeda, Array de Moedas do sistema

@author  Andreia Lima
@since   16/06/2020
/*/
//-------------------------------------------------------------------
function BALoadMoeda()
  	Local aMoeda	:= {}
  	Local aFinMoeda	:= BADescMoeda()
  	Local nCount   	:= 0
     
  	For nCount := 1 To Len(aFinMoeda)
  		If !Empty( AllTrim( SubStr( aFinMoeda[ nCount ], 3, Len( aFinMoeda[ nCount ] ) - 2 ) ) )
    		Aadd( aMoeda,{ Alltrim(str(val(left( aFinMoeda[nCount], 2)))), Alltrim( substr( aFinMoeda[nCount], 3, len( aFinMoeda[nCount] ) - 2))})
    	EndIf
  	Next nCount   	
Return aMoeda

//-------------------------------------------------------------------
/*/{Protheus.doc} BADescMoeda
Retorna moeda e descricao

@return aMoedaFin Moedas 

@author  Andreia Lima
@since   16/06/2020
/*/
//-------------------------------------------------------------------
function BADescMoeda()
	Local cParamMoeda := ""
	Local cFilSX6     := ""
	Local aMoedaFin   := {} 

	//-------------------------------------------------------------------
	// Inicializa array com as moedas existentes
	//-------------------------------------------------------------------
	aMoedaFin := {}
	DbSelectArea( "SX6" )
	
	Getmv( "MV_MOEDA1" )
	
	cFilSX6 := SX6->X6_FIL
	
	While Substr( SX6->X6_VAR,1,8 ) == "MV_MOEDA" .And. SX6->( ! Eof() ) .And. ( SX6->X6_FIL == cFilSx6 )
		If Substr( SX6->X6_VAR,9,1 ) != "P" .And. Substr( SX6->X6_VAR,9,2 ) != "CM" // Desconsiderar plural e MV_MOEDACM
		    cParamMoeda := SX6->X6_VAR
			Aadd( aMoedaFin, StrZero( Val( Substr ( SX6->X6_VAR,9,2 ) ),2 ) + " " + GetMv( cParamMoeda ) )
		EndIf
		DbSkip()
	EndDo

	ASort( aMoedaFin )

Return ( aMoedaFin )

