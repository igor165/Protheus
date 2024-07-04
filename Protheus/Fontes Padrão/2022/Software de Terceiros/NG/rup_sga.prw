#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} RUP_MDT
Fun��o exemplo de compatibiliza��o do release incremental. Esta fun��o � relativa ao m�dulo Medicina e Seguran�a do Trabalho.
Ser�o chamadas todas as fun��es compiladas referentes aos m�dulos cadastrados do Protheus
Ser� sempre considerado prefixo "RUP_" acrescido do nome padr�o do m�dulo sem o prefixo SIGA.
Ex: para o m�dulo SIGAMDT criar a fun��o RUP_MDT

@param  cVersion 	Caracter Vers�o do Protheus
@param  cMode 		Caracter Modo de execu��o. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart 	Caracter Release de partida Ex: 002
@param  cRelFinish 	Caracter Release de chegada Ex: 005
@param  cLocaliz 	Caracter Localiza��o (pa�s) Ex: BRA

@Author Bruno Lobo de Souza
@since 27/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Function RUP_SGA(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

	//Trativa para quando executado ambiente TOTVS PDV
	#IFDEF TOP
		If ( cVersion == "12" )//Executa somente para vers�o 7
			//Altera��es definidas para o Release 007 ou superiores
			If cRelFinish >= "007"
				If cMode == "1" //Executa para cada Grupo de Empresa
					fValueDef("TAF", "TAF_ETAPA" , "2")
					fValueDef("TCK", "TCK_STATUS", "1")
					fValueDef("TAX", "TAX_TPGERA", "1")
					fValueDef("TCO", "TCO_PRIORI", "3")
					fValueDef("TAA", "TAA_TPMETA", "1")
					fValueDef("TCQ", "TCQ_RETMTR", "2")
					fValueDef("TB6", "TB6_STATUS", "1")
				EndIf
			EndIf
			//Altera��es definidas para o Release 017 ou superiores
			If cRelFinish >= "017"
				If cMode == "1"//Executa para cada Grupo de Empresa
					fValueDef("TCS", "TCS_PERIGO" , "1")
				EndIf
			EndIf
		EndIf
	#ENDIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValueDef
Atribui valor default dos campos
@type  Static Function
@author Bruno Lobo de Souza
@since 27/11/2017
@version P12
@param cTblAlias, Caracter, Alias da tabela cujo campo receber� um valor default
@param cTblField, Caracter, Campo que receber� um valor default
@param cValueDef, Caracter, Valor default a ser atribuido ao campo
@param cCondition, Caracter, Condi��o para atribui��o do valor default ao campo
@return Nil
@example
fValueDef("TLD", "TLD_RECEBI", "1", "TLD_RECEBI = '' AND TLD_SITUAC = '2'")

/*/
//-------------------------------------------------------------------
Static Function fValueDef(cTblAlias, cTblField, cValueDef, cCondition)

	Local cQuery
	Default cCondition := cTblField + " = ''"

	cQuery := "UPDATE "
	cQuery += RetSqlName( cTblAlias )
	cQuery += " SET " + cTblField + " = " + ValToSql(cValueDef)
	cQuery += " WHERE " + cCondition
	TcSqlExec( cQuery )

Return