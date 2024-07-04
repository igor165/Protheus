#INCLUDE "TOTVS.CH"
#INCLUDE "MDTM006.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTM006
Rotina de Envio de Eventos - Exclus�o de Eventos (S-3000)
Realiza a composi��o do Xml a ser enviado ao Governo

@return cRet, Caracter, Xml com a estrutura do evento de exclus�o

@sample MDTM006( 'S-2210' , '000000001' , , '20170101 , { cEmpAnt, cFilAnt } )

@param	cEvento, Caracter, Indica o evento a ser exclu�do
@param	cNumMat, Caracter, Matr�cula do Funcion�rio
@param	cChave, Caracter, Chave �nica de busca
	S-2210 - DTOS( TNC->TNC_DTACID ) + TNC->TNC_HRACID + TNC->TNC_TIPCAT
	S-2220 - TMY->TMY_DTEMIS
	S-2240 - TN0->TN0_DTRECO

@author	Luis Fellipy Bett
@since	16/03/2021
/*/
//---------------------------------------------------------------------
Function MDTM006( cEvento, cNumMat, cChave )

	Local cRet	  := ""
	Local aDadFun := MDTDadFun( cNumMat, .T. ) //Array de Informa��es do Funcion�rio

	//Vari�veis private para composi��o do Xml
	Private cRecibo	 := "" //Recibo do registro que ser� exclu�do
	Private cCpfTrab := aDadFun[ 3 ] //CPF do Funcion�rio (RA_CIC)

	//Busca da informa��o a ser enviada na tag <nrRecEvt>
	cRecibo := fGetRcb( cEvento, aDadFun, cChave )

	//Carrega o Xml para retorno
	cRet := fCarrExc( cEvento, cChave )

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCarrExc
Monta o Xml do evento de exclus�o para envio ao Governo

@return	cXml, Caracter, Estrutura XML a ser enviada para o SIGATAF/Middleware

@sample	fCarrExc( "S2210", "" )

@param	cEvento, Caracter, Evento para que ser� gerado o evento de exclus�o
@param	cChave, Caracter, Chave do registro que ser� exclu�do

@author	Luis Fellipy Bett
@since	16/03/2021
/*/
//---------------------------------------------------------------------
Static Function fCarrExc( cEvento, cChave )

	//Vari�vel de composi��o e retorno do Xml
	Local cXml	  := ""
	Local cEvtAux := "S-" + Right( cEvento, 4 )

	//Cria o cabe�alho do Xml com o ID, informa��es do Evento e Empregador
	MDTGerCabc( @cXml, cEvento, "3", cChave, .T. )

	cXml += 		'<infoExclusao>'
	cXml += 			'<tpEvento>'	+ cEvtAux + '</tpEvento>'
	cXml += 			'<nrRecEvt>'	+ cRecibo + '</nrRecEvt>'
	cXml += 			'<ideTrabalhador>'
	cXml += 				'<cpfTrab>'	+ cCpfTrab + '</cpfTrab>'
	cXml += 			'</ideTrabalhador>'
	cXml += 		'</infoExclusao>'
	cXml += 	'</evtExclusao>'
	cXml += '</eSocial>'

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetRcb
Busca o recibo do Xml enviado de acordo com a chave passada por par�metro

@return	cRecibo, Caracter, Recibo do Xml enviado para o evento da chave passada como par�metro

@param	cEvento, Caracter, Evento para que ser� buscado o recibo do Xml
@param	nIndEsp, Num�rico, �ndice a ser considerado na busca do recibo

@sample	fGetRcb()

@author	Luis Fellipy Bett
@since	07/04/2021
/*/
//-------------------------------------------------------------------
Static Function fGetRcb( cEvento, aDadFun, cChave )

	Local aArea	   := GetArea() //Salva a �rea
	Local cCodTrab := ""
	Local cRecibo  := ""
	Local cTabela  := ""

	If lMiddleware
		cRecibo := MDTVerStat( , cEvento, cChave )[ 5 ]
	Else
		//Pega a tabela do TAF de acordo com o evento
		If "2210" $ cEvento
			cTabela := "CM0"
			nIndEsp := 4
		ElseIf "2220" $ cEvento
			cTabela := "C8B"
			nIndEsp := 2
		ElseIf "2240" $ cEvento
			cTabela := "CM9"
			nIndEsp := 5
		EndIf

		//Busca o c�digo do funcion�rio no SIGATAF
		cCodTrab := MDTGetIdFun( aDadFun[ 1 ] )

		//Posiciona na tabela com o �ndice e chave para buscar o valor do campo "XXX_PROTUL"
		dbSelectArea( cTabela )
		dbSetOrder( nIndEsp )
		If dbSeek( xFilial( cTabela ) + cCodTrab + cChave )
			cRecibo := &( cTabela + "->" + cTabela + "_PROTUL" )

			If Empty( cRecibo )
				cRecibo := aDadFun[ 3 ] + aDadFun[ 4 ] + cChave
			EndIf
		EndIf
	EndIf

	RestArea( aArea ) //Retorna a �rea

Return cRecibo
