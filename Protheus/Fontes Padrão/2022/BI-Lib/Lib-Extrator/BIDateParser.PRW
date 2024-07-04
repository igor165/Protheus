#INCLUDE "PROTHEUS.CH"
#INCLUDE "BIDATEPARSER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIParseDate
Responsável pela chamada das funções para efetuar parse  das datas.

@param cQuery, String, query com as datas a serem parseadas.

@return cQuery, String, query parseada, exemplo: "SELECT * FROM SA1T10"

@author  Helio Leal
@since   06/03/2018
/*/
//-------------------------------------------------------------------
Function BIParseDate(cQuery)
	Default cQuery := ""

	cQuery := BIDateDiff( cQuery )
	cQuery := BIQryGetLF( cQuery )
	cQuery := BIQryGetLF( cQuery, "<<FIRSTDAY(" )
	cQuery := BIQryGetLF( cQuery, "<<LASTDAY_PR_MONTH(" )
	cQuery := BIQryGetLF( cQuery, "<<HISTORIC_PERIOD(" )
	
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} BIDateDiff
Retorna a diferença entre duas datas em dias, meses ou anos.
(Depende do segundo parâmetro do parser:
 	Dias:  <<DATEDIFF_DD_Campo1-Campo2>>
 	Meses: <<DATEDIFF_MM_Campo1-Campo2>>
 	Anos:  <<DATEDIFF_YY_Campo1-Campo2>>

@param cQuery, String, query com as datas a serem parseadas.

@return cQuery, String, query parseada, exemplo: "SELECT * FROM SA1T10"

@author  Helio Leal
@since   06/03/2018
/*/
//-------------------------------------------------------------------
Function BIDateDiff( cQuery )
	Local nDateStart   := 0
	Local nDateEnd     := 0
	Local nParentheses := 0
	Local cDateDiff    := ""
	Local cAuxQuery    := ""

	Default cQuery   := ""
	
	While ( At( "<<DATEDIFF(", cQuery ) > 0 )
		//----------------------------------------------------------------------------------- 
		// Pega alcance do dateDiff. Exemplo: <<DATEDIFF(TIPODERETORNO,CAMPO1,CAMPO2)>>
		//-----------------------------------------------------------------------------------
		nDateStart   := At( "<<DATEDIFF(", cQuery )
		cAuxQuery    := SubStr( cQuery, nDateStart )
		nParentheses := At( ")", cAuxQuery ) + 1
		nDateEnd     := At( ">>", SubStr( cAuxQuery, nParentheses ) )		
		cDateDiff    := AllTrim( SubStr( cAuxQuery, 1, ( nParentheses + nDateEnd ) ) )

		If BIVldDateDiff( cDateDiff )
			cQuery := StrTran( cQuery, cDateDiff, BIParseDtDiff( cDateDiff ), 1, 1 )
		Else
			Conout(I18n( "BIDateDiff: #1 #2 #3", { STR0001, AllTrim( cDateDiff ), STR0002 } ))
			Break
		EndIf
	EndDo	
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} BIVldDateDiff
Valida se o DateDiff está no formato correto
Função deve estar no formato <<DATEDIFF(DD, C1, C2)>>

@param cDateDiff, String, parâmetro datediff vindo da query.

@return lValid, Boolean, verifica se o comando datediff está correto.

@author  Helio Leal
@since   06/03/2018
/*/
//-------------------------------------------------------------------
Function BIVldDateDiff( cDateDiff )
	Local lValid   := .F.
	Local cAuxDate := ""
	Local aAuxDate := { }

	Default cDateDiff := ""

	//--------------------------------------------------
	// Valida início da expressão do DateDiff
	//--------------------------------------------------
	lValid := ( SubStr( cDateDiff, 1, 11 ) == '<<DATEDIFF(' )

	If ( lValid )
		//--------------------------------------------------
		// Valida fim da expressão do DateDiff
		//--------------------------------------------------
		lValid := ( AllTrim( SubStr( cDateDiff, Len(cDateDiff) - 2 ) ) == ')>>' ) .Or. ( AllTrim( SubStr( cDateDiff, Len(cDateDiff) - 3 ) ) == ') >>' )

		If( lValid )
			//--------------------------------------------------
			// Recebe os parâmetros do DateDiff em um array.
			//--------------------------------------------------
			cAuxDate := SubStr( cDateDiff, 12 )
			cAuxDate := AllTrim( SubStr( cAuxDate, 1, RAt(")", cAuxDate ) -1 ) )			
			aAuxDate := StrTokArr(cAuxDate, ",")
			
			//--------------------------------------------------
			// Valida a quantidade de parâmetros do datediff
			//--------------------------------------------------
			If( Len( aAuxDate ) == 3 )
				//----------------------------------------------------------------------
				// Valida se os parâmetros 1, 2 e 3 são válido e não estão vazios.
				//----------------------------------------------------------------------
				lValid := Upper(aAuxDate[1]) $ 'DD|MM|YY'
			
				If ( lValid )
					lValid := ! Empty( aAuxDate[2] ) .And. ! Empty( aAuxDate[3] ) 
				EndIf
			Else
				lValid := .F.
			EndIf
		EndIf
	EndIf
Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} BIParseDtDiff
Retorna a diferença entre duas datas em dias, meses ou anos 
(Depende do segundo parâmetro do parser:
Dias:  <<DATEDIFF_DD_Campo1-Campo2>>
Meses: <<DATEDIFF_MM_Campo1-Campo2>>
Anos:  <<DATEDIFF_YY_Campo1-Campo2>>

@param cDateDiff, String, parâmetro datediff vindo da query.

@return lValid, Boolean, verifica se o comando datediff está correto.

@author  henrique.cesar
@since   07/03/2018
/*/
//-------------------------------------------------------------------
Function BIParseDtDiff( cDateDiff )
	Local cDatabase  := Upper( TcGetDb() )
	Local cType      := ""
	Local cRetDate   := ""
	Local aParameter := { }

	Default cDateDiff := ""

	aParameter := BIGetDateParameters( cDateDiff )

	If ( Len( aParameter ) > 0 )
		cType  := aParameter[1]
		cDate1 := aParameter[2]
		cDate2 := aParameter[3]

		If ( "ORACLE" $ cDatabase )

			Do Case
				Case ( cType == 'DD' )
					cRetDate := " TO_DATE(" + cDate2 + ", 'YYYYMMDD') - TO_DATE(" + cDate1 + ", 'YYYYMMDD') "
				Case ( cType == 'MM' )
					cRetDate := " MONTHS_BETWEEN(TO_DATE(" + cDate2 + ", 'YYYYMMDD'), TO_DATE(" + cDate1 + ", 'YYYYMMDD')) "
				Case ( cType == 'YY' )
					cRetDate := " EXTRACT (YEAR FROM TO_DATE (" + cDate2 + ", 'YYYYMMDD')) - EXTRACT (YEAR FROM TO_DATE (" + cDate1 + ", 'YYYYMMDD')) "
			EndCase
		ElseIf ( "POSTGRES" $ cDatabase )
			Do Case
				Case ( cType == 'DD' )
					cRetDate := " TO_DATE(" + cDate2 + ", 'YYYYMMDD') - TO_DATE(" + cDate1 + ", 'YYYYMMDD')  "
				Case ( cType == 'MM' )
					cRetDate := " (DATE_PART('year', TO_DATE(" + cDate2 + ", 'YYYYMMDD')) - DATE_PART('year', TO_DATE(" + cDate1 + ", 'YYYYMMDD')) ) * 12  + " + ;
						"(DATE_PART('month', TO_DATE(" + cDate2 + ", 'YYYYMMDD')) - DATE_PART( 'month' , TO_DATE (" + cDate1 + ", 'YYYYMMDD'))) "
				Case ( cType == 'YY' )
					cRetDate := " DATE_PART('year', TO_DATE(" + cDate2 + ", 'YYYYMMDD')) - DATE_PART('year', TO_DATE(" + cDate1 + ", 'YYYYMMDD')) "
			EndCase
		ElseIf ( "MSSQL" $ cDatabase )

			cRetDate := " DATEDIFF(" + cType + ", " + cDate1 + ", " + cDate2 + ") "
		EndIf	
	EndIf
Return cRetDate

//-------------------------------------------------------------------
/*/{Protheus.doc} BIGetDateParameters
Retorna os parâmetros no formato de array.

@param cDateDiff, String, parâmetro datediff vindo da query.

@return aParameters, Array, Parâmetros do Datediff {DD, C1, C2}

@author  Helio Leal
@since   07/03/2018
/*/
//-------------------------------------------------------------------
Static Function BIGetDateParameters( cDateDiff )
	Local cAuxDate := ""

	Default cDateDiff := ""

	//--------------------------------------------------
	// Recebe os parâmetros do DateDiff em um array.
	//--------------------------------------------------
	cAuxDate := SubStr( cDateDiff, 12 )
	cAuxDate := AllTrim( SubStr( cAuxDate, 1, RAt(")", cAuxDate ) -1 ) )
Return StrTokArr(cAuxDate, ",")

//-------------------------------------------------------------------
/*/{Protheus.doc} BIQryGetLF (BIQueryGetLastFirstDay)
Efetua parse na query para último ou primeiro dia do mês.

@param cQuery, String, query com as datas a serem parseadas.
@param cTag, String, tag a ser parseada, exemplo <<LASTDAY( ou <<FIRSTDAY(
@return cQuery, String, query parseada para o primeiro/último dia do mês.

@author  Helio Leal
@since   02/04/2018
/*/
//-------------------------------------------------------------------
Function BIQryGetLF( cQuery, cTag )
	Local nTagStart    := 0
	Local nTagEnd      := 0
	Local nParentheses := 0
	Local cQueryTag    := ""
	Local cAuxQuery    := ""

	Default cQuery := ""
	Default cTag   := "<<LASTDAY("

	While ( At( cTag, cQuery ) > 0 )
		//----------------------------------------------------------------------------------- 
		// Pega alcance da tag. Exemplo: <<LASTDAY(CAMPO DATA)>>
		//-----------------------------------------------------------------------------------
		nTagStart    := At( cTag, cQuery )
		cAuxQuery    := SubStr( cQuery, nTagStart )
		nParentheses := At( ")", cAuxQuery ) + 1
		nTagEnd      := At( ">>", SubStr( cAuxQuery, nParentheses ) )		
		cQueryTag    := AllTrim( SubStr( cAuxQuery, 1, ( nParentheses + nTagEnd ) ) )

		If BIVldTag( cQueryTag, cTag )
			cQuery := StrTran( cQuery, cQueryTag, BIGetTagLF( cQueryTag, cTag ) )
		Else
			Conout(I18n( "BIQryGetLF: #1 #2 #3", { "Comando ", AllTrim( cQueryTag ), " Inválido!" } ))
			Break
		EndIf
	EndDo
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} BIGetTagLF (BIGetTagLastFirstDay)
Função para gerar comando que pega último dia do mês de um determinado campo de data.
exemplo: se data  03/04/2018, retorna 30/04/2018.

@param cQueryTag, String, tag da query a ser parseada, exemplo <<LASTDAY(NSZ_DTINCL>> ou <<FIRSTDAY(NSZ_DTINCL>>
@param cTag, String, tag a ser parseada, exemplo <<LASTDAY( ou <<FIRSTDAY(
@return cCommand, String, comando SQL para pegar último/primeiro dia de uma data ( Por banco: SQL ou ORACLE)

Lista de Tags disponíveis:

LASTDAY - Último dia do mês conforme a data passada
FIRSTDAY - Primeiro dia do mês conforme a data passada
LASTDAY_PR_MONTH - Último dia do mês anterior conforme a data passada
HISTORIC_PERIOD - Primeiro dia do ano - nYears, de acordo com a data atual. (Ex: hoje: 20191003, nYears: 4, Retorno: 20150101) 

Em implementação
DATE_PRV_YEAR - Data do ano anterior conforme a data passada
LASTDAY_PRV_MONTH_YEAR - Último dia do mês e ano anterior conforme a data passada

@author  Helio Leal
@since   03/04/2018
/*/
//-------------------------------------------------------------------
Function BIGetTagLF( cQueryTag, cTag )
	Local cDatabase := Upper( TcGetDb() )
	Local cCommand  := ""
	Local cField    := ""

	Default cQueryTag := ""
	Default cTag      := "<<LASTDAY("

	If !Empty( cQueryTag )
		cField := StrTran( cQueryTag, cTag, "" )
		cField := StrTran( cField, ")>>", "" )
		cField := StrTran( cField, ") >>", "" )

		//--------------------------------------------------------------------
		// Verifica se é para pegar o comando para o último dia ou primeiro.
		//--------------------------------------------------------------------
		If ( "<<LASTDAY(" $ cTag )
			Do Case
				Case ( "ORACLE" $ cDatabase )
					cCommand := "To_Char(LAST_DAY(TRUNC(to_date("+ cField +", 'yyyymmdd'), 'MONTH')), 'yyyyMMdd') "
				Case ( "POSTGRES" $ cDatabase )
					cCommand := "To_Char( date_trunc('month', to_date("+ cField +", 'yyyymmdd')) + INTERVAL '1 month' - INTERVAL '1 day', 'yyyyMMdd') "
				OtherWise // SQL SERVER.
					cCommand := "CONVERT(VARCHAR,DATEADD(dd,-1,DATEADD(mm,DATEDIFF(mm,0," + cField + ")+ 1,0)),112) "
			EndCase
		ElseIf ( "<<FIRSTDAY(" $ cTag )
			Do Case
				Case ( "ORACLE" $ cDatabase )
					cCommand := "To_Char(TRUNC(to_date("+ cField +", 'yyyymmdd'), 'MONTH'), 'yyyyMMdd') "
				Case ( "POSTGRES" $ cDatabase )
					cCommand := "To_Char( date_trunc('month', to_date("+ cField +", 'yyyymmdd')), 'yyyyMMdd') "
				OtherWise // SQL SERVER.
					cCommand := "CONVERT(VARCHAR,DATEADD(mm,-1,DATEADD(mm, DATEDIFF(mm, 0," + cField + ")+ 1,0)),112) "
			EndCase
		ElseIf ( "<<LASTDAY_PR_MONTH(" $ cTag )
			Do Case
				Case ( "ORACLE" $ cDatabase )
					cCommand := "To_Char(LAST_DAY(ADD_MONTHS(TO_DATE("+ cField +", 'yyyymmdd'), -1)), 'yyyyMMdd') "
				Case ( "POSTGRES" $ cDatabase )
					cCommand := "To_Char( date_trunc('month', to_date("+ cField +", 'yyyymmdd')) - INTERVAL '1 day', 'yyyyMMdd') "
				OtherWise // SQL SERVER.
					cCommand := "CONVERT(VARCHAR, dateadd(dd, - day("+ cField +"), "+ cField +"), 112) "
			EndCase
		ElseIf ( "<<HISTORIC_PERIOD(" $ cTag )
			Do Case
				Case ( "ORACLE" $ cDatabase )
					cCommand := "CONCAT(EXTRACT(YEAR FROM SYSDATE) - " + cField + ", '0101') "
				Case ( "POSTGRES" $ cDatabase )
					cCommand := "concat(date_part('year', current_date - interval '" + cField + " years'), '0101') "
				OtherWise // SQL SERVER.
					cCommand := "CONCAT(DATEPART(YEAR, DATEADD(yy, - " + cField + ", GetDate())), '0101') "
			EndCase
		
/*		
		ElseIf ( "<<DATE_PRV_YEAR(" $ cTag )
			Do Case
				Case ( "ORACLE" $ cDatabase )
					cCommand := "To_Char(ADD_MONTHS(TO_DATE("+ cField +", 'yyyymmdd'), -12), 'yyyyMMdd') "
				Case ( "POSTGRES" $ cDatabase )
					cCommand := "To_Char( to_date("+ cField +", 'yyyymmdd') - INTERVAL '12 month', 'yyyyMMdd') "
				OtherWise // SQL SERVER.
					cCommand := "CONVERT(VARCHAR, DATEADD(YY, -1,  "+ cField +" ), 112) "
			EndCase
		ElseIf ( "<<LASTDAY_PRV_MONTH_YEAR(" $ cTag )
			Do Case
				Case ( "ORACLE" $ cDatabase )
					cCommand := "To_Char(LAST_DAY(ADD_MONTHS(TO_DATE("+ cField +", 'yyyymmdd'), -12)), 'yyyyMMdd') "
				Case ( "POSTGRES" $ cDatabase )
					cCommand := "To_Char( date_trunc('month', to_date("+ cField +", 'yyyymmdd')) - INTERVAL '1 year' + INTERVAL '1 month' - INTERVAL '1 day', 'yyyyMMdd') "
				OtherWise // SQL SERVER.
					//cCommand := "CONVERT(VARCHAR, dateadd(dd, - day("+ cField +"), "+ cField +"), 112) "
					cCommand := "CONVERT(VARCHAR, dateadd(yy, -1,  DATEADD(dd,-1,DATEADD(mm,DATEDIFF(mm,0,"+ cField +")+ 1,0)) ), 112) "
			EndCase*/
		EndIf
	EndIf
Return cCommand

//-------------------------------------------------------------------
/*/{Protheus.doc} BIGetTagED (BIGetTagExtractionDate)
Função para gerar comando que pega o dia atual no banco.

@return cCommand, String, comando SQL para pegar o dia atual de uma data ( Por banco: SQL ou ORACLE)

@author  Rodrigo Soares
@since   03/04/2018
/*/
//-------------------------------------------------------------------
Function BIGetTagED(nTipo, bTipo)
	Local cDatabase := Upper( TcGetDb() )
	Local cCommand  := ""
	
	Default nTipo = 1
	Default btipo := .f.

	//--------------------------------------------------------------------
	// Verifica se é para pegar o comando para o último dia ou primeiro.
	//--------------------------------------------------------------------
	IF (nTipo = 1 .and. bTipo)
	
		Do Case
			Case ( "ORACLE" $ cDatabase )
				cCommand := "SYSDATE"
			OtherWise // SQL SERVER.
				cCommand := "GETDATE()"
		EndCase
		
	ELSEIF (nTipo = 1 .and. !bTipo)
	
		Do Case
			Case ( "ORACLE" $ cDatabase )
				cCommand := "TO_CHAR(TRUNC(SYSDATE),'YYYYMMDD')"
			OtherWise // SQL SERVER.
				cCommand := "GETDATE()"
		EndCase
	
	ELSE
	
		Do Case
			Case ( "ORACLE" $ cDatabase )
				cCommand := "TO_CHAR(TRUNC(SYSDATE),'YYYYMMDD')"
			OtherWise // SQL SERVER.
				cCommand := "CONVERT(VARCHAR,GETDATE(),112)"
		EndCase
	
	ENDIF
	
	

Return cCommand

//-------------------------------------------------------------------
/*/{Protheus.doc} BIVldTag
Valida se a Tag está no formato correto.
Função deve estar no formato <<LASTDAY(CAMPO>> ou <<FISTDAY_CAMPO>>

@param cQueryTag, String, tag da query a ser parseada, exemplo <<LASTDAY(NSZ_DTINCL>> ou <<FIRSTDAY(NSZ_DTINCL>>
@param cTag, String, tag a ser parseada, exemplo <<LASTDAY( ou <<FIRSTDAY(

@return lValid, Boolean, verifica se o comando está correto.

@author  Helio Leal
@since   04/04/2018
/*/
//-------------------------------------------------------------------
Function BIVldTag( cQueryTag, cTag )
	Local lValid   := .F.
	Local cAuxDate := ""
	Local aAuxDate := { }

	Default cQueryTag := ""
	Default cTag      := "<<LASTDAY("

	//----------------------------------------------------------------------------------
	// Valida início da expressão da tag ( se inicia com <<LASTDAY( ou <<FIRSTDAY( ou <<LASTDAY_PR_MONTH( )
	//----------------------------------------------------------------------------------
	lValid := ( cTag $ ( SubStr( cQueryTag, 1, 11 ) ) ) .Or. ( cTag $ ( SubStr( cQueryTag, 1, 19 ) ) )

	If ( lValid )
		//----------------------------------------------------------------------------------
		// Valida fim da expressão do da tag ( se inicia com <<LASTDAY( ou <<FIRSTDAY( )
		//----------------------------------------------------------------------------------
		cQueryTag := AllTrim( cQueryTag )
		lValid := ( AllTrim( SubStr( cQueryTag, Len(cQueryTag) - 2 ) ) == ')>>' ) .Or. ( AllTrim( SubStr( cQueryTag, Len(cQueryTag) - 3 ) ) == ') >>' )

		If( lValid )
			cQueryTag := StrTran( cQueryTag, cTag, "" )
			cQueryTag := StrTran( cQueryTag, ")>>", "" )
			cQueryTag := StrTran( cQueryTag, ") >>", "" )

			//------------------------------------------------------------------
			// Valida o miolo da expressão:
			// 		* Não pode ter espaços, vírgulas
			// 		* Os carateres da String tem que ser válidos (0 a 9)(A a Z).
			//------------------------------------------------------------------
			lValid := ! ( ( " " $ cQueryTag ) .Or. ( "," $ cQueryTag ) )

			If lValid
				cQueryTag := StrTran( cQueryTag, ".", "" ) // Tira ponto da expressão.
				cQueryTag := StrTran( cQueryTag, "_", "" ) // Tira underscore da expressão.
				cQueryTag := StrTran( cQueryTag, "<<", "" ) // Tira tag da expressão.
				cQueryTag := StrTran( cQueryTag, ">>", "" ) // Tira tag da expressão.
				lValid := BICheckChr( cQueryTag )
			EndIf
		EndIf
	EndIf
Return lValid
