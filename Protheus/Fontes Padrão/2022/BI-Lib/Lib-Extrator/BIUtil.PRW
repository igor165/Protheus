#INCLUDE "PROTHEUS.CH"
#INCLUDE "BIUTIL.CH"

Static __lFilialExec
Static __aCompany
Static __cInstance

//------------------------------------------------------------------- 
/*/{Protheus.doc} BICheckChr 
Verifica se a string contém apenas  os caracteres [0..9][A..Z] 

@param, cText, String, Texto a ser analisado.
@Return lValidKey, Boolean, Retorna se o texto é valido. 

@author Andréia Lima 
@since 28/09/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BICheckChr( cText ) 
	Local lChr  := .T.
	Local cChar	:= ""
	Local nChar	:= 0
	Local nAsc	:= 0

	Default cText := ""
	
	cText := AllTrim( Upper( cText ) )
	
	For nChar := 1 To Len( cText ) 
		cChar	:= SubStr( cText, nChar, 1 ) 
		nAsc 	:= Asc( cChar )
		
		//-------------------------------------------------------------------
		// Verifica se não está no range 48 à 57 [0..9] ou 65 à 90 [A..Z]
		//-------------------------------------------------------------------
		If ( ! ( ( nAsc >= 48  .And. nAsc <= 57 ) .Or. ( nAsc >= 65 .And. nAsc <= 90 ) ) )
			lChr  := .F.
			EXIT
		EndIf
		 
  	Next nChar	

Return lChr

//-------------------------------------------------------------------
/*/{Protheus.doc} BIGetShare
Define a tabela de origem dos dados no Protheus.

@param, cTable, String, Tabela Origem.

@Return cShare, Retorna o nome da origem da entidade.

@author  Helio Leal
@since   12/09/2017
/*/
//-------------------------------------------------------------------
Function BIGetShare( cTable )  
	Local cShare   := ""

	Default cTable := ""

    //------------------------------------------------------------------- 
    // Identifica se a tabela de origem da entidade está no dicionário. 
    //------------------------------------------------------------------- 
    If ( ! Empty( cTable ) ) .And. ( AliasInDic( cTable ) ) 
    	cShare := Alltrim ( FWSX2Util():GetFile( cTable ) )
    EndIf 
Return cShare

//-------------------------------------------------------------------
/*/{Protheus.doc} BIClass
Instância uma classe.

@param cSource, caracter, Fonte da entidade. 
@return oObject, Instância da classe. 

@author Andréia Lima  
@since   11/09/2017
/*/
//-------------------------------------------------------------------
Function BIClass( cSource )
	Local bErro   := nil
	Local oObject := nil
	
	Default cSource	:= ""
	
	bErro := ErrorBlock( { | e | conout(I18n( "BIClass (#1),(#2): (#3)", {cEmpAnt, AllTrim( cFilAnt ), e:ErrorStack} )) } )
	
	//-------------------------------------------------------------------
	// Instancia a classe informada.
	//-------------------------------------------------------------------
	BEGIN SEQUENCE
		oObject	:= &( SubStr( cSource, 1, At(".", cSource ) - 1 ) + "():Setup()" ) 
	END SEQUENCE 

	ErrorBlock( bErro )
Return oObject

//-------------------------------------------------------------------
/*/{Protheus.doc} BIInstance
Retorna a instância da instalação atual do Protheus.

@return string, instância atual do Protheus.

@author Helio Leal  
@since   27/09/2017
/*/
//-------------------------------------------------------------------
Function BIInstance()
	Local nInstance := 0

	If( Empty( __cInstance ) )
		__cInstance	:= "01"
		nInstance 	:= nBIVal( GetSrvProfString( "BIINSTANCE", "01" ) )
	
		If ( nInstance >= 1 .And. nInstance <= 99 )
			__cInstance := StrZero( nInstance, 2 )
		EndIf
	EndIf 

Return __cInstance

//------------------------------------------------------------------- 
/*/{Protheus.doc} BIValidKey 
Verifica se a key está no formato esperado, exemplo <<KEY_SA1_FIELD>> 

@param, cKey, String, Key.
@Return lValidKey, Boolean, Retorna se a Key é valida 

@author Andréia Lima 
@since 28/09/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BIValidKey( cKey ) 
	Local lValidKey := .F.
	Local cOrigin   := ""
	
	Default cKey    := ""
	
	cKey := UPPER( cKey )
	
    //------------------------------------------------------------------- 
    // Verifica se a chave começa com <<KEY_ e termina em >> 
    //------------------------------------------------------------------- 
	If ( '<<KEY_' == SubStr( cKey, 1, 6 ) ) .And. ( '>>' == SubStr( cKey, -2 , 2 )  )
	
		cOrigin := SubStr ( cKey, 7, 3)
		
		//--------------------------------------------------------------------------- 
		// Verifica se a origem começa com letra e se não contém caracteres especiais 
		//---------------------------------------------------------------------------
		If ( cOrigin == '###' )  .Or. ( IsAlpha ( cOrigin ) .And. ( BICheckChr ( cOrigin ) ) ) 
			
			//--------------------------------------------------------------------------- 
			// Verifica se após a origem existe um underline 
			//---------------------------------------------------------------------------
			If ( '_' == Substr( cKey, 10, 1) )
				lValidKey := .T.
			EndIf
				
		EndIf
	 
	EndIf

	If ! lValidKey
		conout(I18n( "BIValidKey: #1 #2. #3", {STR0001, cKey, STR0002} ) ) // Chave inválida: #1. A chave deve estar no formato: <<KEY_ORIGIN_FIELD>> ou <<KEY_ORIGIN_FIELD1+FIELD2>>
	EndIf

Return lValidKey

//------------------------------------------------------------------- 
/*/{Protheus.doc} BICrypt
Criptografa a string passada para a função.

@param, cText, String, variável que receberá o texto que será criptografado.
@param, nType, Number, se 1 = criptografia, 2 = descriptografia.
@Return cText, String, Retorna o texto criptografado caso o parâmetro não seja vazio.

@author Helio Leal
@author Angelo Lee
@since 11/10/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BICrypt( cText, nType  )
	Local cCryptKey := "rasgolkiebploisl"

	Default cText := ""
	Default nType := 1

	cText := AllTrim( cText )

	If ! Empty( cText )
		If nType == 1
			cText := rc4crypt( cText, cCryptKey, .T.)		
		Else
			cText := rc4crypt( cText , cCryptKey, .F., .T.)
		EndIf
	EndIf
Return cText 

//------------------------------------------------------------------- 
/*/{Protheus.doc} BIIsGestao
Verifica se o ambiente utiliza gestão de empresas.

@Return boolean, Retorna se o ambiente é gestão de empresas.

@author Helio Leal
@since 16/03/2018 
/*/ 
//-------------------------------------------------------------------- 
Function BIIsGestao( )
Return ( "E" $ FWSM0Layout() .Or. "U" $ FWSM0Layout() )

//------------------------------------------------------------------- 
/*/{Protheus.doc} BICompShare
Compara o compartilhamento de duas tabelas.
É considerada maior a tabela que tiver os níveis de compartilhamentos
exclusivos maiores.
	Exemplo: se tabela 1 tiver o compartilhamento EEE e a 2 EEC, a 1 é 
maior que a 2.

@param cTable1, String, tabela 1.
@param cTable2, String, tabela 2.
@Return int, 0 = se forem iguais, 1 = se tabela 1 for maior que a tabela 2, -1 = se a tabela 2 for maior que a tabela 1 

@author Helio Leal
@since 16/03/2018 
/*/ 
//-------------------------------------------------------------------- 
Function BICompShare( cTable1, cTable2, cCompany )
	Local nComp      := 0
	Local nTable1    := 0
	Local nTable2    := 0 
	Local cSM0Layout := ""
	
	Default cTable1  := ""
	Default cTable2  := ""
	Default cCompany := IIf(cEmpAnt != Nil, cEmpAnt, "")
	
	//-------------------------------------------------------------------
	// Armazena o layout do campo filial
	//-------------------------------------------------------------------
	cSM0Layout := FWSM0Layout()

	//-------------------------------------------------------------------
	// Valida se o layout tem empresa e se é exclusiva.
	//-------------------------------------------------------------------
	If "E" $ cSM0Layout
		IIf( FWModeAccess( cTable1, 1, cCompany ) == 'E', nTable1++, )
		IIf( FWModeAccess( cTable2, 1, cCompany ) == 'E', nTable2++, )
	EndIf
	
	//-------------------------------------------------------------------
	// Valida se o layout tem unidade de negócio e se é exclusiva.
	//-------------------------------------------------------------------
	If "U" $ cSM0Layout 
		IIf( FWModeAccess( cTable1, 2, cCompany ) == 'E', nTable1++, )
		IIf( FWModeAccess( cTable2, 2, cCompany ) == 'E', nTable2++, )
	EndIf

	//-------------------------------------------------------------------
	// Valida se o layout tem filial e se é exclusiva.
	//-------------------------------------------------------------------
	If "F" $ cSM0Layout
		IIf( FWModeAccess( cTable1, 3, cCompany ) == 'E', nTable1++, )
		IIf( FWModeAccess( cTable2, 3, cCompany ) == 'E', nTable2++, )
	EndIf

	//------------------------------------------------------------------
	// Compara compartilhamento das tabela para verificar qual é maior.
	//------------------------------------------------------------------
	Do Case
		Case nTable1 > nTable2 
			nComp := 1
		Case nTable1 < nTable2
			nComp := -1
		OtherWise
			nComp := 0
	EndCase
Return nComp

//------------------------------------------------------------------- 
/*/{Protheus.doc} BIGetFilialExec
Recebe o tipo de execução do arquivo Appserver.ini (por empresa ou filial)

@param nType, numérico, Identifica de onde veio a chamada, 
	sendo 1 = Fast Analytics e 2 = Extrator Carol.
@Return boolean, true = execução por filial, false = execução por empresa.

@author Helio Leal
@since 12/04/2018 
/*/ 
//--------------------------------------------------------------------
Function BIGetFilialExec( nType )

	Default nType := 1
	
    If ( __lFilialExec == Nil )
    	If nType == 1
	        //--------------------------------------------------
	        // Verifica a existência do BAFILIALEXEC no gerenal.
	        //--------------------------------------------------
	        __lFilialExec := iif( Val( GetPvProfString( "GENERAL", "BAFILIALEXEC", "0", GetAdv97() ) ) == 0, .F., .T. )
	        
	        //-----------------------------------------------------------------------------
	        // Caso não existe a BAFILIALEXEC no gerenal, procura no ambiente corrente.
	        //-----------------------------------------------------------------------------
	        If !( __lFilialExec )
	            __lFilialExec := iif( Val( GetSrvProfString("BAFILIALEXEC ", "0") ) == 0, .F., .T. )
	        EndIf
	    Else
	    	__lFilialExec := .F.
	    EndIf
    EndIf
Return __lFilialExec

//------------------------------------------------------------------- 
/*/{Protheus.doc} BIExtractAlias
Extrai o Alias de um campo

@Return string, cAliasField, Alias do campo

@author Andréia Lima
@since 24/04/2018 
/*/ 
//--------------------------------------------------------------------
Function BIExtractAlias( cField )
	Local nAliasStart := 0
	Local cAliasField := ""  
	
	Default cField := ""
	
	nAliasStart := At( ".", cField )
	
	IF ( nAliasStart > 0 )		
		cAliasField := SubStr( cField, 1, nAliasStart )
	EndIf
	
Return cAliasField

//-------------------------------------------------------------------
/*/{Protheus.doc} BIFindX3
Verifica se o campo está cadastrado no SX3.

@param cCampo, caracter, Nome do campo a ser pesquisado
@return lFind, Retorna .T. se o campo for encontrado no SX3.

@author  Márcia Junko
@since   05/11/2018
/*/
//-------------------------------------------------------------------
function BIFindX3(cCampo)
	Local aArea := SX3->(GetArea())
	Local lFind	:= .F.
	
	DBSelectArea("SX3")
	
	SX3->( DBSetOrder( 2 ) )
	
	If ( SX3->( DBSeek( cCampo ) ) )
		lFind := .T.
	EndIf
	
	RestArea(aArea)
return lFind


//-------------------------------------------------------------------
/*/{Protheus.doc} BIProdLine
Retorna a linha de produto (Protheus).

@return caracter, código da linha de produto.

@author  Márcia Junko
@since   05/11/2018
/*/
//-------------------------------------------------------------------
function BIProdLine()
Return "P"

//------------------------------------------------------------------- 
/*/{Protheus.doc} BICompanySelected
Empresas selecionadas para instalação

@Return array, empresas.

@author Andréia Lima
@since 25/06/2019 
/*/ 
//--------------------------------------------------------------------
Function BICompanySelected( aCompany )
	Local nCompany := 0
	Default aCompany := {}

	If ( __aCompany == Nil )
		
		__aCompany := {}
		
		For nCompany := 1 To Len( aCompany )
			If aCompany[nCompany][1]
				AADD( __aCompany, aCompany[nCompany][2] )
			EndIf	
		Next nCompany
		
    EndIf
    
Return __aCompany


//------------------------------------------------------------------- 
/*/{Protheus.doc} BITestDDL
Testa uma instrução dw banco.

@author  Marcia Junko
@since   13/09/2019
/*/ 
//-------------------------------------------------------------------- 
Function BITestDDL( cDDL )
	Local lSucess := .T.
	
	If ! ( TCSQLExec( cDDL ) == 0 )
		ConOut( "BITestDDL: " + TCSQLError() )
		lSucess := .F.
	EndIf
	

Return lSucess

//-------------------------------------------------------------------
/*/{Protheus.doc} BISX5Title
Retorna o campo de descrição do SX5, para ser utilizad de acordo com o pais.

@return cField, Campo de descrição do SX5. 

@author  Marcia Junko
@since   18/12/2019
/*/
//-------------------------------------------------------------------
Function BISX5Title( )
	Local cField := "" 
	Local cLang := FWRetIdiom()

	If cLang == "es"
		cField := "X5_DESCSPA X5_DESCRI"
	Else
		If cLang == "en"
			cField := "X5_DESCENG X5_DESCRI"
		Else
	   		cField := "X5_DESCRI"
		EndIf
	EndIf
Return cField
