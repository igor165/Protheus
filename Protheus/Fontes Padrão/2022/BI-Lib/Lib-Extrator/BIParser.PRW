#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIParseQuery
Parse da query da entidade, parseia  empresa e chaves.
 
@param cCompany, String, Empresa injetada.
@param cQuery, String, query a ser parseada.
@param nType, numérico, Identifica de onde veio a chamada, 
	sendo 1 = Fast Analytics e 2 = Extrator Carol.

@return cQuery, String, query parseada, exemplo: "SELECT * FROM SA1T10"

@author  Helio Leal
@since   04/10/2017
/*/
//-------------------------------------------------------------------
Function BIParseQuery( cQuery, cCompany, nType )
	Default cQuery   := ""
	Default cCompany := ""
	Default nType := 1

    cQuery := BIParseFilial( cQuery, cCompany, nType )

	If nType == 1
		cQuery := BIKeyCompany( cQuery, cCompany )
		cQuery := BIKeyFilial( cQuery, cCompany )
		cQuery := BIKeyMoeda( cQuery )
		cQuery := BIParseKey( cQuery )
	Else
		cQuery := BIParseTag( cQuery, cCompany, "<<CODE_LINE>>" )
		cQuery := BIParseTag( cQuery, cCompany, "<<CODE_COMPANY>>" )
		cQuery := BIParseTag( cQuery, cCompany, "<<EXTRACTION_DATE>>" )
		cQuery := BIParseTag( cQuery, cCompany, "<<TEST_QUERY>>" )
		cQuery := BIParseViewName( cQuery, cCompany )
	EndIf

	cQuery := BIParseTag( cQuery, cCompany, "<<CODE_INSTANCE>>" )
	cQuery := BIParseDate( cQuery )
	cQuery := BIParseValue( cQuery )
	cQuery := BIParseCompany( cQuery, cCompany )

	If nType <> 1
		cQuery := BIParseTag( cQuery, cCompany, "<<FUNCTION_DATE>>" )
	ENDIF

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} BIParseCompany
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
Function BIParseCompany( cQuery, cCompany )
	Local nCompEnd     := 0
	Local cCurrentComp := ""
	Local cTable := ""
	Local cTableFile := ""
	
	Default cQuery     := ""
	Default cCompany   := ""

	While ( At( "_COMPANY>>", cQuery ) > 0 )
		//---------------------------------------------
		// Pegar empresa corrente <<TABELA_COMPANY>>.
		//---------------------------------------------
		nCompEnd     := At( "_COMPANY>>", cQuery )
		cCurrentComp := SubStr( cQuery, nCompEnd - 5, 15 )

		//---------------------------------------------
		// Define as informações da tabela
		//---------------------------------------------
		cTable := Subs( cCurrentComp, 3, 3 )
		cTableFile := BIGetShare( cTable )

		//---------------------------------------------
		//  força a criação da estrutura da tabela
		//---------------------------------------------
		dbSelectArea(cTable)
		
		//-------------------------------------------------- 
		// Adicionar empresa transformada na query.
		//--------------------------------------------------
		cQuery := StrTran( cQuery, cCurrentComp, cTableFile )

	EndDo

Return cQuery

//------------------------------------------------------------------- 
/*/{Protheus.doc} BIParseKey 
Retorna a query com chaves no formato correto 

@param, cQuery, String, Query.

@author Helio Leal 
@author Andréia Lima 
@since 13/09/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BIParseKey( cQuery )
	Local cKey      := ""
	Local cAuxQuery := ""
	Local nKeyStart := 0
	Local nKeyEnd   := 0

	Default cQuery  := ""

	While ( At( "<<KEY_", cQuery ) > 0 )

		//------------------------------------------------------------------- 
		// Pega alcance da chave. Exemplo <<KEY_TBL_CAMPO1..CAMPO_N>>
		//-------------------------------------------------------------------
		nKeyStart := At( "<<KEY_", cQuery )		
		cAuxQuery := SubStr( cQuery, nKeyStart )				
		nKeyEnd   := At( ">>", cAuxQuery ) + 1
		cKey      := SubStr( cAuxQuery, 1, nKeyEnd )

		//------------------------------------------------------------------- 
		// Se a chave for válida a transforma no formato correto se não zera  
		// a query para que a mesma não seja gravada.
		//------------------------------------------------------------------- 		
		If BIValidKey( cKey )
			cQuery := StrTran( cQuery, cKey, BIBuildBK( cKey ) )
		Else
			cQuery := ""
		EndIf
	EndDo
Return cQuery

//------------------------------------------------------------------- 
/*/{Protheus.doc} BIBuildBK 
Retorna a Business Key no formato correto (pipeado) 

@param cKey, String, Key.

@author Helio Leal 
@author Andréia Lima 
@since 13/09/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BIBuildBK( cKey ) 
	Local cBK    := ""
	Local cFields := ""

	Default cKey := ""

	If ! ( Empty( cKey ) )
		
		cFields := SubStr(cKey, 11)
		cFields := StrTran( cFields, ">>", "" )
		
		cBk := "'" + BIPrefixBK( cKey )
		
		//--------------------------------------------------------------------------------------
		// Adiciona o + para concatenar com os demais campos da key
		//--------------------------------------------------------------------------------------
		cBK += "'+"
		
		cFields := BINullField(cFields)

		cBK += BIRTrimField (cFields)
		
		//--------------------------------------------------------------------------------------
		// Change query considera '||' para converter a 'concatenação' para os outros bancos.
		//--------------------------------------------------------------------------------------
		cBK := StrTran( cBK, "+", "||")
		cBK := StrTran( cBK, ">>", " " )
	EndIf	 

Return cBK


//------------------------------------------------------------------- 
/*/{Protheus.doc} BIPrefixBK
Prefixo da Business key.

@param  cKey, String, Key.
@Return cPrefixBK, String, Retorna o prefixo da Business key

@author Andréia Lima
@since 07/11/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BIPrefixBK( cKey )
	Local cPrefixBK := ""
	Local cTable    := ""
	
	Default cKey    := ""

	If ! ( Empty( cKey ) )

		cTable := BIGetTbName( cKey )

		cPrefixBK := "P " + "|" 
		
		If ( cTable <> '###' )
			cPrefixBK := cPrefixBK + BIInstance()  + "|"
		EndIf 
	
		cShare := BIGetShare( cTable )
	
		If ! ( Empty( cShare ) )
			cPrefixBK += cShare + "|"
		EndIf
	
	EndIf

Return cPrefixBK

//------------------------------------------------------------------- 
/*/{Protheus.doc} BIGetTbName
Obtém o nome da tabela.

@param  cKey, String, Key.
@Return cTable, String, Retorna o nome da tabela.

@author Helio Leal
@since 21/11/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BIGetTbName( cKey )
	Local cTable := ""
	
	Default cKey := ""
	
	If ! ( Empty( cKey ) )

	//------------------------------------------------------------------- 
	// Obtém tabela origem 
	//------------------------------------------------------------------- 
	cTable := SubStr( cKey, 7 , At( ">>", cKey ) )
	cTable := SubStr( cTable, 1 , At( "_", cTable ) -1 )
	
	EndIf
	
Return cTable

//------------------------------------------------------------------- 
/*/{Protheus.doc} BIKeyCompany
Parse na Business key de empresa.

@Return cQuery, String, Retorna a query com a Business key da empresa.

@author Andréia Lima
@since 06/11/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BIKeyCompany( cQuery, cCompany )
	Local cBK        := ""
	
	Default cQuery   := ""
	Default cCompany := ""
	
	If ( At( "<<KEY_COMPANY>>", cQuery ) > 0 )

		cBk := "'" + BIPrefixBK( "<<KEY_SM0_>>" ) + cCompany + "'" 

		cQuery := StrTran( cQuery, "<<KEY_COMPANY>>", cBK )

	EndIf		

Return cQuery

//------------------------------------------------------------------- 
/*/{Protheus.doc} BIKeyFilial
Parse na Business key de filial.

@Return cQuery, String, Retorna a query com a Business key da filial.

@author Andréia Lima
@since 06/11/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BIKeyFilial( cQuery, cCompany )
    Local cBk          := "" 
    Local cIndefinido  := ""
    Local cKeyFilial   := ""  
    Local cFieldFilial := ""
    Local nLenFilial   := FWSizeFilial()

    Default cQuery   := "" 
    Default cCompany := "" 

    While ( At( "<<KEY_FILIAL_", cQuery ) > 0 )
        cKeyFilial := SubStr( cQuery, At( "<<KEY_FILIAL_", cQuery ) ) 
        cKeyFilial := SubStr( cKeyFilial, 1, At( ">>", cKeyFilial ) + 1) 
        
        cBk := "'" + BIPrefixBK( "<<KEY_SM0_>>" ) + cCompany + "'||" 
        cIndefinido := "'" + BIPrefixBK( "<<KEY_SM0_>>" ) + "|'"
        
        //------------------------------------------------------------------- 
        // Nome do campo Filial 
        //-------------------------------------------------------------------
        cFieldFilial := SubStr( cKeyFilial, 14, At( ">>", cKeyFilial ) - 14 )
        
        //------------------------------------------------------------------- 
        // Completa o tamanho do campo filial com espaços em branco 
        //-------------------------------------------------------------------  
        cBk += " CAST(" + cFieldFilial + " AS CHAR (" + AllTrim( STR( nLenFilial ) ) + ") )" 
        
        //------------------------------------------------------------------- 
        // Quando o campo filial for nulo utilizar INDEFINIDO 
        //-------------------------------------------------------------------  
        cBk := " CASE WHEN " + cFieldFilial + " IS NULL THEN " + cIndefinido + " ELSE " + cBk + " END "  
        
        cQuery := StrTran( cQuery, cKeyFilial, cBk ) 
    EndDo 
Return cQuery

//------------------------------------------------------------------- 
/*/{Protheus.doc} BISubStrFil
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
Function BISubStrFil(cQuery, cCompany)
	Local cAuxQuery    := ""
	Local cSubStr      := ""
	Local cField       := ""
	Local cTable       := ""
	Local cStmt        := ""
	Local cMainTable   := ""
	Local cTagAlias    := ""
	Local cSuBIias    := ""
	Local nSubStart    := 0
	Local nSubEnd      := 0
	Local nAliasStart  := 0
	Local nAliasEnd    := 0

	Default cQuery   := ""	
	Default cCompany := ""

	While ( At( "<<SUBSTR_", cQuery ) > 0 ) 
		cSuBIias := ""
		cTagAlias := ""

	 	//------------------------------------------------------------------- 
		// Pega parâmetro do substr, ex: <<SUBSTR_TABLE_CAMPO_FILIAL>> 
		//-------------------------------------------------------------------
		nSubStart := At( "<<SUBSTR_", cQuery )		
		cAuxQuery := SubStr( cQuery, nSubStart )				
		nSubEnd   := At( ">>", cAuxQuery ) + 1
		cSubStr   := SubStr( cAuxQuery, 1, nSubEnd )
		
		//--------------------------------------------------------------------------------- 
		// Pega parâmetro alias e verifica sua existência, ex: <<ALIAS_ALIAS DA TABELA>> 
		//---------------------------------------------------------------------------------
		nAliasStart := At( "<<ALIAS_", cQuery )
		
		//-------------------------------------------------------------------
		// Verifica a existência de um alias Antes da tag <<SubStr_...>>
		//-------------------------------------------------------------------
		If ( nAliasStart > 0 )		
			If ( nAliasStart < nSubStart )
				cAuxQuery := SubStr( cQuery, nAliasStart )				
				nAliasEnd := At( ">>", cAuxQuery ) + 1
				cTagAlias := SubStr( cAuxQuery, 1, nAliasEnd )			
				cSuBIias := SubStr( cTagAlias, 9 )
				cSuBIias := StrTran(cSuBIias, ">>", "")
				cSuBIias += "."
			EndIf		
		EndIf

		//------------------------------------------------------------------- 
		// Obtém tabela origem 
		//------------------------------------------------------------------- 
		cTable := SubStr(cSubStr, 10, 3)

		//------------------------------------------------------------------- 
		// Recebe o campo filial.
		//------------------------------------------------------------------- 
		cField := SubStr(cSubStr, 14 )
		cField := StrTran(cField, ">>", "")
		
		//-------------------------------------------------------------------
		// Recebe a tabela fato a partir do campo filial.
		//-------------------------------------------------------------------
		cMainTable := GetTable(cField)
		
		//--------------------------------------------------------------------------------
		// Recebe o campo filial da tabela fato correto para ser comparado com a dimensão.
		//--------------------------------------------------------------------------------
		cStmt := BIRetSubFilial( cCompany, cTable, cMainTable, cField, cSuBIias )
		
		//-------------------------------------------------------------------------------
		// Efetua troca de <<SUBSTR...>> pela comparação com compartilhamento correto.
		//------------------------------------------------------------------------------- 
		If !Empty( cTagAlias )
			cQuery := StrTran( cQuery, cTagAlias, "")
		EndIf

		//-------------------------------------------------------------------------------
		// Efetua a troca apenas do item em questão para garantir que o motor avalie 
		// todas as tags
		//------------------------------------------------------------------------------- 
		cQuery := StrTran( cQuery, cSubStr, cStmt, 1, 1 )		
	EndDo
Return cQuery

//------------------------------------------------------------------- 
/*/{Protheus.doc} GetTable
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
Static Function GetTable(cField)
	Local cTable := ""
	Local nDivision := 0
	
	Default cField := ""
	
	nDivision := At( "_", cField )	
	cTable := SubStr(cField, 1, nDivision - 1) 

	If Len(cTable) == 2
		cTable := "S" + cTable
	EndIf
Return cTable

//------------------------------------------------------------------- 
/*/{Protheus.doc} BIRTrimField
Aplica RTRIM (string) para cada campo da chave composta BK

@param cFields, String, chave(BK) composta por campos.
@Return cTrimField, String, Retorna a chave(BK) composta com RTRIM nos campos.

@author Marcia Junko
@author Angelo Lee
@since 20/12/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BIRTrimField( cFields )
	Local aFields    := {}
	Local nField     := 0
	Local cTrimField := ""
	
	//----------------------------------------------------------------
	// Verifica se a chave é propositalmente vazia, ex: <<KEY_###_''>>  
	//----------------------------------------------------------------
	If ( cFields == " ISNULL('', '') " )
		cTrimField := "'|'"
	Else	
		aFields := StrTokArr( cFields, '+' )
		For nField := 1 to Len(aFields)
			cTrimField += 'RTRIM(' + aFields[nField] + ')+'
			If ( "FILIAL" $ aFields[nField] ) .Or. ( "_FILPRO" $ aFields[nField] ) 
				cTrimField += "'|'+"
			EndIf
		Next
		
		//-------------------------------------------------------------
		// Retira o '+' do último campo ( Evitar erro de query ).
		//-------------------------------------------------------------
		cTrimField := SubStr(cTrimField, 1, Len(cTrimField) - 1 )
		
		//-------------------------------------------------------------
		// Torna o  valor nulo se a chave for vazia para adicionar pipe
		//-------------------------------------------------------------
		cTrimField := " ISNULL(NULLIF( " + cTrimField + ", ''),'|') "
	EndIf	
	
Return cTrimField

//------------------------------------------------------------------- 
/*/{Protheus.doc} BINullField
Proteção caso o valor do campo chave da dimensão na fato esteja nulo

@param cFields, String, chave(BK) composta por campos.
@Return cNullField, String, Campos com a proteção ISNULL

@author Marcia Junko
@author Angelo Lee
@since 20/12/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BINullField(cFields)
	Local aFields    := {}
	Local nField     := 0
	Local cNullField := ""
	
	Default cFields  := ""
	
	If !Empty( cFields)
		
		aFields := StrTokArr( cFields, '+' )
		
		For nField := 1 to Len(aFields)
			cNullField += " ISNULL(" + aFields[nField] + ", '') +"
		Next
	
		cNullField := SubStr(cNullField, 1, Len(cNullField) - 1 )
	
	EndIf
	
Return cNullField

//------------------------------------------------------------------- 
/*/{Protheus.doc} BISubStr2Fil
Parse das Subtrings da query para o campo filial olhando uma tabela 
que não está na query
Exemplo: fato de auditoria - tabela da Fato O0H, mas deve olhar a
filial de processos NSZ que não está na query.

@param cQuery, string
@param cField, string, campo filial.
@param cTable, string, alias a ser verificado.
@param cCompany, string, empresa 
@Return cQuery, String, Retorna a query com o Substr correto para o banco utilizado.

@author Helio Leal
@since 14/11/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BISubStr2Fil(cQuery, cCompany)
	Local cAuxQuery    := ""
	Local cSubStr      := ""
	Local cField       := ""
	Local cTable       := ""
	Local cStmt        := ""
	Local cMainTable   := ""
	Local cTagAlias    := ""
	Local cSuBIias    := ""
	Local nSubStart    := 0
	Local nSubEnd      := 0
	Local nAliasStart  := 0
	Local nAliasEnd    := 0

	Default cQuery   := ""	
	Default cCompany := ""

	While ( At( "<<SUBSTR2_", cQuery ) > 0 )
		cSuBIias := ""
		cTagAlias := ""

	 	//------------------------------------------------------------------- 
		// Pega parâmetro do substr, ex: <<SUBSTR2_TABLE_CAMPO_FILIAL>> 
		//-------------------------------------------------------------------
		nSubStart := At( "<<SUBSTR2_", cQuery )		
		cAuxQuery := SubStr( cQuery, nSubStart )				
		nSubEnd   := At( ">>", cAuxQuery ) + 1
		cSubStr   := SubStr( cAuxQuery, 1, nSubEnd )

		//--------------------------------------------------------------------------------- 
		// Pega parâmetro alias e verifica sua existência, ex: <<ALIAS_ALIAS DA TABELA>> 
		//---------------------------------------------------------------------------------
		nAliasStart := At( "<<ALIAS_", cQuery )
		
		//-------------------------------------------------------------------
		// Verifica a existência de um alias Antes da tag <<SubStr_...>>
		//-------------------------------------------------------------------
		If ( nAliasStart > 0 )		
			If ( nAliasStart < nSubStart )
				cAuxQuery := SubStr( cQuery, nAliasStart )				
				nAliasEnd := At( ">>", cAuxQuery ) + 1
				cTagAlias := SubStr( cAuxQuery, 1, nAliasEnd )			
				cSuBIias := SubStr( cTagAlias, 9 )
				cSuBIias := StrTran(cSuBIias, ">>", "")
				cSuBIias += "."
			EndIf		
		EndIf

		//------------------------------------------------------------------- 
		// Obtém tabela origem 
		//------------------------------------------------------------------- 
		cTable := SubStr(cSubStr, 11, 3)
		
		//------------------------------------------------------------------- 
		// Obtém tabela principal 
		//------------------------------------------------------------------- 
		cMainTable := SubStr(cSubStr, 15, 3)
		
		//------------------------------------------------------------------- 
		// Recebe o campo filial.
		//------------------------------------------------------------------- 
		cField := SubStr(cSubStr, 19 )
		cField := StrTran(cField, ">>", "")
		
		//--------------------------------------------------------------------------------
		// Recebe o campo filial da tabela fato correto para ser comparado com a dimensão
		//--------------------------------------------------------------------------------
		cStmt := BIRetSubFilial( cCompany, cTable, cMainTable, cField, cSuBIias )
		
		//-------------------------------------------------------------------------------
		// Efetua troca de <<SUBSTR...>> pela comparação com compartilhamento correto.
		//------------------------------------------------------------------------------- 
		If !Empty( cTagAlias )
			cQuery := StrTran( cQuery, cTagAlias, "")
		EndIf
		
		//-------------------------------------------------------------------------------
		// Efetua a troca apenas do item em questão para garantir que o motor avalie 
		// todas as tags
		//------------------------------------------------------------------------------- 
		cQuery := StrTran( cQuery, cSubStr, cStmt, 1, 1 )
	EndDo
Return cQuery

//------------------------------------------------------------------- 
/*/{Protheus.doc} BIFilialLen
Retorna o tamanho do campo filial de uma determinada tabela baseado somente
nos compartilhamentos exclusivos.

@param cTable, string, alias a ser verificado.
@param cCompany, string, empresa 

@Return cQuery, String, Retorna a query com o Substr correto para o banco utilizado.

@author Helio Leal
@since 14/11/2017 
/*/ 
//-------------------------------------------------------------------- 
Function BIFilialLen(cTable, cCompany)
	Local cSM0Layout     := ""
	Local cOriginCompany := ""
	Local cOriginFilial  := ""
	Local cUnitBusiness  := ""
	Local nFilialLen     := 0

	Default cTable := ""
	Default cCompany := ""

	//-------------------------------------------------------------------
	// Armazena o layout do campo filial
	//-------------------------------------------------------------------
	cSM0Layout := FWSM0Layout()
	
	//-------------------------------------------------------------------
	// Modo de compartilhamento da empresa, unidade de negócio e filial.
	//-------------------------------------------------------------------
	cOriginCompany := FWModeAccess( cTable, 1, cCompany )
	cUnitBusiness  := FWModeAccess( cTable, 2, cCompany )
	cOriginFilial  := FWModeAccess( cTable, 3, cCompany )

	//-------------------------------------------------------------------------
	// Valida se o layout tem empresa e atribui tamanho a variável de retorno.
	//-------------------------------------------------------------------------
	If "E" $ cSM0Layout
		IIf( cOriginCompany == 'E', nFilialLen += Len( FWSM0Layout( ,1) ), )
	EndIf
	
	//--------------------------------------------------------------------------------------
	// Valida se o layout tem unidade de negócio e atribui tamanho a variável de retorno.
	//--------------------------------------------------------------------------------------
	If "U" $ cSM0Layout
		IIf( cUnitBusiness == 'E', nFilialLen += Len( FWSM0Layout( ,2) ), )
	EndIf
	
	//--------------------------------------------------------------------------------------
	// Valida se o layout tem filial e atribui tamanho a variável de retorno.
	//--------------------------------------------------------------------------------------
	If "F" $ cSM0Layout
		IIf( cOriginFilial == 'E', nFilialLen += Len( FWSM0Layout( ,3) ), )
	EndIf
Return nFilialLen

//------------------------------------------------------------------- 
/*/{Protheus.doc} BISubFilial
Retorna o comando substring tratado por banco.

@param cCompany, string, empresa 
@param cField, string, campo filial.
@param cDim, string, tabela dimensão a ser analisada.
@param lComplete, boolean, verifica se a tratativa da substring deve ser completa. É Considerado como completo 
o valor inteiro da substring, exemplo: fato D MG e dimensão D MG 01, com o lComplete a comparação é feita de forma
que o campo filial da dimensão complete o valor da fato, nesse exemplo ficaria Campo_Filial_Fato + SubStr( Campo_Filial_Dimensão, N, Y )
Nesse exemplo ficaria D MG da fato e 01 da dimensão.
@param cFact, string, tabela fato a ser analisada. ( Esse parâmetro deve ser informado se o lComplete for .T. )  
@param cAliasAux, caracter, Identificador da tabela caso ela utilize um Alias auxiliar.

@Return cStmt, String, Formato do campo filial.   

@author Andréia Lima
@since 02/03/2018 
/*/ 
//-------------------------------------------------------------------- 
Function BISubFilial( cCompany, cField, cDim, lComplete, cFact, cAliasAux )
	Local cDatabase  := Upper( TcGetDb() )
	Local cStmt      := ""
	Local nDimFilLen := 0
	Local nFacFilLen := 0
	Local cDimField  := ""
	
	Default cCompany  := IIf(cEmpAnt != Nil, cEmpAnt, "")
	Default cField    := ""	
	Default cDim      := ""
	Default lComplete := .F.
	Default cFact     := ""
	Default cAliasAux := ""

	//----------------------------------------------------------------
	// Recebe o tamanho da filial do sistema para a tabela dimensão.
	//----------------------------------------------------------------
	nDimFilLen := BIFilialLen(cDim, cCompany)

	If ( lComplete )
		nFacFilLen := BIFilialLen(cFact, cCompany)

		If ( ( nDimFilLen > 0 ) .And. ( nFacFilLen > 0 ) )
			If !Empty( cAliasAux )
				cDimField := cAliasAux
			EndIf 
			cDimField += PrefixoCpo( cDim ) + '_FILIAL'
							
			Do Case
				Case ( "ORACLE" $ cDatabase )
					cStmt := " CAST((SUBSTR(" + cField + ", 1, "+ ALLTRIM( Str( nFacFilLen ) ) +") || SUBSTR(" + cDimField + ", "+ ALLTRIM( Str( nFacFilLen + 1 ) ) +", " + ALLTRIM( STR( nDimFilLen ) ) + ")) AS CHAR(" + ALLTRIM( STR( nDimFilLen ) ) + ")) "
				Case ( "POSTGRES" $ cDatabase )
					cStmt := " SUBSTRING(" + cField + ", 1, "+ ALLTRIM( Str( nFacFilLen ) ) +") || SUBSTRING(" + cDimField + ", "+ ALLTRIM( Str(nFacFilLen + 1) ) +", "+ ALLTRIM( Str(nDimFilLen)) +") "
				OtherWise
					cStmt := " SUBSTRING(" + cField + ", 1, "+ ALLTRIM( Str( nFacFilLen ) ) +") + SUBSTRING(" + cDimField + ", "+ ALLTRIM( Str(nFacFilLen + 1) ) +", "+ ALLTRIM( Str(nDimFilLen)) +") "
			EndCase
		EndIf
	Else
		If (nDimFilLen > 0)
			Do Case
				Case ( "ORACLE" $ cDatabase )
					cStmt := " CAST((SUBSTR(" + cField + ", 1, "+ Str( nDimFilLen ) +")) AS CHAR(" + ALLTRIM( STR( nDimFilLen ) ) + ")) "
				Case ( "POSTGRES" $ cDatabase )
					cStmt := " TRIM(SUBSTRING(" + cField + ", 1, "+ ALLTRIM( Str( nDimFilLen ) ) +")) "
				OtherWise
					cStmt := " SUBSTRING(" + cField + ", 1, "+ ALLTRIM( Str( nDimFilLen ) ) +") "
			EndCase
		EndIf
	EndIf
Return cStmt

//------------------------------------------------------------------- 
/*/{Protheus.doc} BIRetSubFilial
Retorna a comparação do campo filial considerando os compartilhamentos da fato e da dimensão. 
Segue algumas informações:
 * Para ambientes com gestão:
 	- Caso o compartilhamento da dimensão e da fato forem iguais, há uma comparação direta da dimensão com a fato.
 	- Caso o compartilhamento da dimensão seja maior (mais exclusivo) que o da fato, há uma comparação do campo
 	filial da fato + final do campo filial da dimensão. Exemplo: dimensão D MG 01 e fato D MG, a comparação deve
 	ser substring(cpo_filial_fato, 1, 5) + substring(cpo_filial_dimensao, 6, 8).
 	- Caso o compartilhamento da fato seja maior (mais exclusivo), o campo filial da fato receberá um substr 
 	para ser comparado com a dimensão. Exemplo: Fato D MG 01, Dimensão D MG, então é feito o seguinte: 
 	substring(cpo_filial_fato, 1, 5).
 	- Se o compartilhamento da fato for maior que o da dimensão e o compartilhamento da dimensão for totalmente
 	compartilhado, o campo é comparado com vazio. 
 * Para ambiente sem gestão.
 	- Caso o compartilhamento da dimensão e da fato forem iguais, há uma comparação direta da dimensão com a fato.
 	- Caso o compartilhamento da dimensão não seja vazio e da fato seja vazio, compara a o campo filial com ela mesmo
 	nesse caso evitamos que a query não traga resultados.
 	- Caso o compartilmaneto da dimensão esteja vazio, comparamos ela com o tamanho da filial do sistema, através da
 	função FWSizeFilial.

@param cCompany, string, empresa 
@param cDim, string, alias a ser verificado, tabela origem.
@param cFact, String, tabela principal, fato.
@param cField, string, campo filial da fato.
@param pcAlias, string, alias utilizado na comparação.

@Return cQuery, String, Retorna o valor correto a ser comparado com o campo filial da dimensão.

@author Helio Leal
@since 15/03/2018
/*/ 
//-------------------------------------------------------------------- 
Function BIRetSubFilial(cCompany, cDim, cFact, cField, pcAlias)
	Local cSubstr      := ""
	Local cFactShare   := ""
	Local cDimShare    := ""
	Local cCpoFilOrig  := ""
	Local lFilOrig	   := .F.

	Default cCompany := ""
	Default cDim     := ""
	Default cFact    := ""
	Default cField   := ""
	Default pcAlias  := ""

	//-------------------------------------------------
	// Recebe compartilhamento da dimensão e da fato.
	//-------------------------------------------------
	cFactShare := xFilial( cFact )
	cDimShare  := xFilial( cDim )
	
	//-----------------------------------------------------------------------
	// Verifica a existência do campo _FILORI na tabela principal da fato
	//-----------------------------------------------------------------------
	cCpoFilOrig := Padr( PrefixoCpo( cFact ) + "_FILORIG", 10)
	lFilOrig := BIFindX3( cCpoFilOrig ) 
	
	//-------------------------------------------------------------------------------------------------------------
	// Caso o compartilhamento da dimensão seja o mesmo da fato, retorna o próprio campo da fato, sem tratamento.
	//-------------------------------------------------------------------------------------------------------------
	If ( cDimShare == cFactShare )
		cSubstr := cField
	Else
		If ( BIIsGestao( ) )
			//--------------------------------------------------------------
			// Verifica se a fato é maior que a dimensão ou vice-versa.
			//--------------------------------------------------------------
			If ( BICompShare( cFact, cDim, cCompany ) == 1 )
				//---------------------------------------------------------------------------------------
				// Se dimensão for toda compartilhada, campo é comparado com o tamanho da filial.
				//---------------------------------------------------------------------------------------
				If Empty( cDimShare )
					cSubstr := "'" + Space( FWSizeFilial() ) + "'"
				Else
					cSubstr := BISubFilial(cCompany, cField, cDim)
				EndIf
			Else
				//---------------------------------------------------------------------------------------
				// Se fato for toda compartilhada, campo filial da dimensão é comparada com 
				// campo _FILORIG ou ele mesmo.
				//---------------------------------------------------------------------------------------
				If Empty( cFactShare )
					If lFilOrig
						cSubstr := pcAlias + cCpoFilOrig
					Else
						cSubstr := pcAlias + PrefixoCpo( cDim )+'_FILIAL'
					EndIf
				Else
					cSubstr := BISubFilial(cCompany, cField, cDim, .T., cFact, pcAlias )
				EndIf				
			EndIf
		Else
		 	//-----------------------------------------------------------------------------------------
		 	// Se dimensão for exclusiva e fato compartilhada, considera o campo 
		 	// _FILORIG ou próprio campo da dimensão.
		 	//-----------------------------------------------------------------------------------------
			If ( !Empty( cDimShare ) .And. Empty( cFactShare ) )
				If lFilOrig
					cSubstr := pcAlias + cCpoFilOrig
				Else
					cSubstr := pcAlias + PrefixoCpo( cDim )+'_FILIAL'
				EndIf
			Else
				cSubstr := "'" + Space( FWSizeFilial() ) + "'"
			EndIf
		EndIf
	EndIf
Return cSubstr

//-------------------------------------------------------------------
/*/{Protheus.doc} BIParseFilial
Parse da filial da entidade

@param cQuery, String, query a ser parseada.
@param cCompany, String, Empresa injetada.
@param nType, numérico, Identifica de onde veio a chamada, 
	sendo 1 = Fast Analytics e 2 = Extrator Carol.

@return cQuery, String, query parseada, exemplo: "SELECT * FROM SA1T10"

@author  Andréia Lima
@since   13/04/2018
/*/
//-------------------------------------------------------------------
Function BIParseFilial( cQuery, cCompany, nType )
	Default cQuery   := ""
	Default cCompany := ""
	Default nType 	 := 1
	
 	//-----------------------------------------------------------------------------------------
 	// Se a instação for por filial, será utlizado o xFilial para os <<SUBSTR...>> das filiais 
 	//-----------------------------------------------------------------------------------------

	If BIGetFilialExec( nType )
		cQuery := BISubxFilial( cQuery, "<<SUBSTR_" )
		cQuery := BISubxFilial( cQuery, "<<SUBSTR2_" )
	Else
		cQuery := BISubStrFil( cQuery, cCompany )
		cQuery := BISubStr2Fil( cQuery, cCompany )
	EndIf
	
	cQuery := BIMacroFilial( cQuery, "<<AND_XFILIAL_" )
	cQuery := BIMacroFilial( cQuery, "<<WHERE_XFILIAL_" )
	
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} BISubxFilial
Parse do <<SUBSTR...>> por filial
@param cQuery, String, query a ser parseada.
@return cQuery, String, query parseada, exemplo: "SELECT * FROM SA1T10"

@author  Andréia Lima
@since   13/04/2018
/*/
//-------------------------------------------------------------------
Function BISubxFilial( cQuery, cMacro )
	Local cAuxQuery    := ""
	Local cSubStr      := ""
	Local cTable       := ""
	Local cTagAlias    := ""
	Local nSubStart    := 0
	Local nSubEnd      := 0
	Local nAliasStart  := 0
	Local nAliasEnd    := 0

	Default cQuery   := ""	

	While ( At( cMacro, cQuery ) > 0 ) 
		
		cTagAlias := ""

	 	//------------------------------------------------------------------- 
		// Pega parâmetro do substr, ex: <<SUBSTR_TABLE_CAMPO_FILIAL>> 
		//-------------------------------------------------------------------
		nSubStart := At( cMacro, cQuery )		
		cAuxQuery := SubStr( cQuery, nSubStart )				
		nSubEnd   := At( ">>", cAuxQuery ) + 1
		cSubStr   := SubStr( cAuxQuery, 1, nSubEnd )
		
		//------------------------------------------------------------------- 
		// Obtém tabela origem 
		//-------------------------------------------------------------------
		cTable := SubStr( cSubStr, Len( cMacro ) + 1, 3 )
		
		//------------------------------------------------------------------- 
		// Obtém a filial 
		//------------------------------------------------------------------- 
		cCodFilial := "'" + xFilial( cTable ) + "'"
		
		//--------------------------------------------------------------------------------- 
		// Pega parâmetro alias e verifica sua existência, ex: <<ALIAS_ALIAS DA TABELA>> 
		//---------------------------------------------------------------------------------
		nAliasStart := At( "<<ALIAS_", cQuery )
		
		//-------------------------------------------------------------------
		// Verifica a existência de um alias Antes da tag <<SubStr_...>>
		//-------------------------------------------------------------------
		If ( nAliasStart > 0 )		
			If ( nAliasStart < nSubStart )
				cAuxQuery := SubStr( cQuery, nAliasStart )				
				nAliasEnd := At( ">>", cAuxQuery ) + 1
				cTagAlias := SubStr( cAuxQuery, 1, nAliasEnd )			
			EndIf		
		EndIf

		//-------------------------------------------------------------------------------
		// Efetua troca de <<SUBSTR...>> pela filial 
		//------------------------------------------------------------------------------- 
		If !Empty( cTagAlias )
			cQuery := StrTran( cQuery, cTagAlias, "" )
		EndIf

		//-------------------------------------------------------------------------------
		// Efetua a troca apenas do item em questão para garantir que o motor avalie 
		// todas as tags 
		//------------------------------------------------------------------------------- 
		cQuery := StrTran( cQuery, cSubStr, cCodFilial, 1, 1 )		
	EndDo
	
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} BIMacroFilial
Substitui a macro de filial 
@param cQuery, String, query a ser parseada.
@param cMacro, String, macro a ser substituída.
@return cQuery, String, query parseada

@author  Andréia Lima
@since   23/04/2018
/*/
//-------------------------------------------------------------------
Function BIMacroFilial( cQuery, cMacro )
	Local cAuxQuery    := ""
	Local cSubAnd      := ""
	Local cTable       := ""
	Local cField       := ""
	Local cAndFilial   := ""
	Local cAliasField  := ""
	Local cClause      := ""
	Local nSubStart    := 0
	Local nSubEnd      := 0

	Default cQuery   := ""	

	While ( At( cMacro, cQuery ) > 0 ) 
		
	 	//---------------------------------------------------------------------- 
		// Pega parâmetro do xfilial, ex: <<AND_XFILIAL_CAMPO>> 
		//----------------------------------------------------------------------
		nSubStart := At( cMacro, cQuery )		
		cAuxQuery := SubStr( cQuery, nSubStart )				
		nSubEnd   := At( ">>", cAuxQuery ) + 1
		cSubAnd   := SubStr( cAuxQuery, 1, nSubEnd )
		
		If BIGetFilialExec()
			//-------------------------------------------------------------------
			// Verifica se é AND ou WHERE
			//-------------------------------------------------------------------
			IIF ( "<<AND_" $ cSubAnd, cClause := " AND ", cClause := " WHERE " )
			
			//------------------------------------------------------------------- 
			// Obtém nome do campo
			//-------------------------------------------------------------------
			cField := SubStr( cSubAnd, Len( cMacro ) + 1 )
			cField := StrTran( cField, ">>", "" )
			
			//------------------------------------------------------------------- 
			// Verifica se o campo tem alias 
			//-------------------------------------------------------------------
			cAliasField := BIExtractAlias( cField )
			
			cField := StrTran( cField, cAliasField, "" )
	
			cTable := GetTable( cField )
			
			//------------------------------------------------------------------- 
			// Monta a clausula AND FILIAL  
			//------------------------------------------------------------------- 
			cAndFilial := cClause + cAliasField + cField + " = " + "'" + xFilial( cTable ) + "' "
		EndIf
		
		//-----------------------------------------------------------------------
		// Se por empresa e usar where, troca por 1=1 para não refletir na query 
		//----------------------------------------------------------------------- 
		IF cClause == " WHERE " .And. Empty( cAndFilial )
			cAndFilial := cClause + " 1=1 "
		EndIf
			
		//-----------------------------------------------------------------------
		// Efetua troca de <<AND_XFILIAL...>> pela filial 
		//----------------------------------------------------------------------- 
		cQuery := StrTran( cQuery, cSubAnd, cAndFilial )		
	EndDo
	
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} BIParseValue
Formata campo de valor adicionando casas decimais
@param cQuery, String, query.
@return cQuery, String, query parseada
@author Andreia Lima
@since 04/12/2018
/*/
//-------------------------------------------------------------------
Function BIParseValue( cQuery )
	Local nValueStart  := 0
	Local nParentheses := 0
	Local cValue       := ""
	Local cAuxQuery    := ""

	Default cQuery   := ""
	
	While ( At( "<<FORMATVALUE(", cQuery ) > 0 )
		nValueStart  := At( "<<FORMATVALUE(", cQuery )
		cAuxQuery    := SubStr( cQuery, nValueStart )
		nParentheses := At( ")>>", cAuxQuery ) + 3
		cValue       := AllTrim( SubStr( cAuxQuery, 1, ( nParentheses ) ) )

		cQuery := StrTran( cQuery, cValue, BIFormatValue( cValue ) )
	EndDo	
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} BIFormatValue
Aplica casas decimais de acordo com o banco de dados 
@param cValue, String, campo de valor.
@return cField, String, campo com tratamento de decimal
@author Andreia Lima
@since 04/12/2018
/*/
//-------------------------------------------------------------------
Function BIFormatValue( cValue )
	Local cDatabase := Upper( TcGetDb() )
	Local cField    := ""
	Local cResult   := ""
	Local cMask     := ""
	Local cSize     := ""
	Local cDecimal  := ""
	Local nPosAux   := 0

	Default cValue  := ""
		
	cField := StrTran( cValue, "<<FORMATVALUE(", "" )
	cField := StrTran( cField, ")>>", "" )
	
	nPosAux  := RAt( ",", cField ) 
	
	//------------------------------------------------------------------------ 
	// Verifica se foi passada a quantidade de casas decimais para formatação.
	// Se sim, usa a formatação informada, caso contrário pega a quantidade
	// de casas estabelecida no próprio campo 
	//------------------------------------------------------------------------ 
	If ( nPosAux = 0 )
		cSize    := Str( TamSX3( cField )[1] )
		cDecimal := Str( TamSX3( cField )[2] )
	Else
		nPosAux  := nPosAux + 1
		cDecimal := SubStr( cField, nPosAux ) 
		cField   := StrTran( cField, SubStr( cField, nPosAux - 1 ), "" )
		nPosAux  := RAt( ",", cField ) + 1
		cSize    := SubStr( cField, nPosAux ) 
		cField   := StrTran( cField, SubStr( cField, nPosAux - 1 ), "" )
	EndIf	
	
	If ( "ORACLE" $ cDatabase )
	    cMask := trim( Replicate( "9", ( val( cSize ) - val( cDecimal ) - 1 ) ) ) + "0." + trim( Replicate( "9", ( val( cDecimal ) ) ) )
		cResult := " TRIM(TO_CHAR(ISNULL(" + cField + ",0),'" + cMask + "')) "		
	Else
		cResult := " CAST(ISNULL(" + cField + ",0) AS DECIMAL(" + cSize + "," + cDecimal + ")) "		
	EndIf
	
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} BIFormatValue
Efetua parse da query de acordo com a TAG informada

@param cQuery, String, Query.
@param cCompany, String, Empresa injetada.
@param cTagParser, String, Tag a ser substiuída.

@return cQuery, consulta com as empresas macro executadas. 

@obs: Recomenda-se a utilização desta função para execução de parser simples.

@author BA Team
@since 09/04/2019
/*/
//-------------------------------------------------------------------
Function BIParseTag( cQuery, cCompany, cTagParser )
	Local cTag      	:= ""
	Local cAuxQuery 	:= ""
	Local nTagEnd   	:= 0
	Local cNewContent	:= ""
	
	Default cQuery  := ""

	While ( At( cTagParser, cQuery ) > 0 )

		//------------------------------------------------------------------- 
		// Pega alcance da chave. 
		//-------------------------------------------------------------------
		nKeyStart := At( cTagParser, cQuery )		
		cAuxQuery := SubStr( cQuery, nKeyStart )				
		nTagEnd   := At( ">>", cAuxQuery ) + 1
		cTag      := Upper( SubStr( cAuxQuery, 1, nTagEnd ) )

		//------------------------------------------------------------------- 
		// Substitui o conteúdo da query de acordo com a tag informada
		//------------------------------------------------------------------- 		
		Do Case
			Case cTag == "<<CODE_LINE>>"
				cNewContent := Chr(39) + BIProdLine() + Chr(39)
				
			Case cTag == "<<CODE_INSTANCE>>"
				cNewContent := Chr(39) + BIInstance() + Chr(39)
			
			Case cTag == "<<CODE_COMPANY>>"
				cNewContent := Chr(39) + cCompany + Chr(39)
			
			Case cTag == "<<EXTRACTION_DATE>>"
				cNewContent :=  BIGetTagED(2)
				
			Case cTag == "<<FUNCTION_DATE>>"
				cNewContent :=  BIGetTagED(1)    

			Case cTag == "<<TEST_QUERY>>"
				cNewContent :=  " AND 1=2 "  
			
		EndCase

		If !Empty( cNewContent )
			cQuery := StrTran( cQuery, cTag,  cNewContent, 1, 1)
		EndIf
	EndDo
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} BIParseCompany
Ajusta o nome da view adicionando a empresa

@param cQuery, String, cQuery.
@param cCompany, String, Empresa injetada.

@return cNameView, nome da view com empresa. 

@author Andréia Lima
@since 14/08/2019 
/*/
//-------------------------------------------------------------------- 
Function BIParseViewName( cQuery, cCompany )
	Local nComp     := 0
	Local cView := ""
	Local cViewCompany := ""
	
	Default cQuery     := ""
	Default cCompany   := ""

	While ( At( "<<VIEW_COMPANY_", cQuery ) > 0 )
		nComp := At( "<<VIEW_COMPANY_", cQuery )
		cView := SubStr( cQuery, nComp )
		nComp := At( ">>", cView )
		cView := SubStr( cView, 0, nComp + 1 )
		cViewCompany := StrTran( cView, "<<VIEW_COMPANY_", "" )
		cViewCompany := StrTran( cViewCompany, ">>", "" )
		cViewCompany := cViewCompany + "_" + cCompany 
		cQuery := StrTran( cQuery, cView, cViewCompany )
	EndDo

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} BIKeyMoeda
Chave da moeda tratada
@param cField, String, campo moeda

@author Andreia Lima
@since 13/07/2020 
/*/
//-------------------------------------------------------------------
Function BIKeyMoeda( cQuery )
	Local nSubStart := 0
	Local nSubEnd   := 0
	Local cAuxQuery := ""
	Local cSubStr   := ""
	Local cField    := ""
	Local cBKMoeda  := ""
	Local cDatabase := Upper( SGDB() )
	
	Default cQuery := ""

	While ( At( "<<KEY_MOEDA_", cQuery ) > 0 ) 
		
		nSubStart := At( "<<KEY_MOEDA_", cQuery )		
		cAuxQuery := SubStr( cQuery, nSubStart )				
		nSubEnd   := At( ">>", cAuxQuery ) + 1
		cSubStr   := SubStr( cAuxQuery, 1, nSubEnd )
		
		cField := SubStr(cSubStr, 13 )
		cField := StrTran(cField, ">>", "")

		cBKMoeda := "'" + BIPrefixBK("<<KEY_SM2_" + cField + ">>") + "'"
		
		If ( "ORACLE" $ cDatabase )
			cBKMoeda += "|| COALESCE(LPAD(" + cField + ", 2, '0'),'|')"
		Else
			cBKMoeda += "|| COALESCE(RIGHT('00' || CAST(" + cField + " AS VARCHAR(2)),2),'|')"
		EndIf	
		cQuery := StrTran( cQuery, cSubStr, cBKMoeda, 1, 1 )		
	EndDo

Return cQuery
