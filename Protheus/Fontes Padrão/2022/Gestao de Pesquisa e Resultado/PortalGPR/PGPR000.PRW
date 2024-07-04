#INCLUDE "PGPR000.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE CRLF					Chr( 13 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campo Tipo Combobox - Utilizado como Logico³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE SIM					"1"		//Sim
#DEFINE NAO					"2"		//Nao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PGPR000   ºAutor  ³Luiz Felipe Couto    º Data ³  02/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra as regras da pesquisa.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPR     						                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Michel M. |19/04/07³912   ³Bops 124570 - Atualizacao de layout do MP10  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PGPR000()

Local cHtml 		:= ""					//Pagina WEB
Local cHtmlRegra	:= ""					//Tabela (HTML) dinamica das regras da pesquisa
Local cPesquisa		:= ""					//String contendo os dados da Pesquisa
Local cCodPesq		:= ""					//Codigo da Pesquisa
Local cCodQuest		:= ""					//Codigo do Questionario
Local cCodGrupo		:= ""					//Codigo do Grupo
Local cCodSubGrupo	:= ""					//Codigo do SubGrupo
Local cCodPerg		:= ""					//Codigo da Questao
Local cTipo			:= ""					//Tipo de apresentacao
Local cPreview		:= ""					//Preview
Local cObjetivo		:= ""					//Objetivo - Entrevistador
Local cErro			:= ""					//Mensagem de Erro

Local nI			:= 0					//Variavel de apoio

Local oObj									//Objeto WS - WSGPRRESEARCH

WEB EXTENDED INIT cHtml

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica integridade do Id³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( HttpGet->cId )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica intergridade do parametro cId³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If fURL2Pesq( HttpGet->cId, @cPesquisa )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exemplo de string contendo os dados da Pesquisa³
		//³000001000001000001000001000001111xxx           ³
		//³1     2     3     4     5     6789             ³
		//³1 - Pesquisa                                   ³
		//³2 - Questionario                               ³
		//³3 - Grupo                                      ³
		//³4 - SubGrupo                                   ³
		//³5 - Questao                                    ³
		//³6 - Tipo                                       ³
		//³7 - Preview                                    ³
		//³8 - Objetivo                                   ³
		//³9 - Chave do Respondente                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodPesq		:= SubStr( cPesquisa, 1, 6 )
		cCodQuest		:= SubStr( cPesquisa, 7, 6 )
		cCodGrupo 		:= SubStr( cPesquisa, 13, 6 )
		cCodSubGrupo	:= SubStr( cPesquisa, 19, 6 )
		cCodPerg		:= SubStr( cPesquisa, 25, 6 )
		cTipo			:= SubStr( cPesquisa, 31, 1 )
		cPreview		:= SubStr( cPesquisa, 32, 1 )
		cObjetivo		:= SubStr( cPesquisa, 33, 1 )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa o objeto WS - WSGPRRESEARCH³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj := WSGPRRESEARCH():New()
		WsChgURL( @oObj, "GPRRESEARCH.APW" )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETRESEARCH³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj:cUSERCODE		:= "MSALPHA"
		oObj:cRESEARCHCODE	:= cCodPesq
		
		//cUSERCODE,cRESEARCHCODE,cQUERYADDWHERE
		If oObj:GETRESEARCH()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Resultado do Metodo GETRESEARCH³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PGPR000RESULT := { oObj:oWSGETRESEARCHRESULT }

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verificacao da Ativacao, Data de Vigencia Inicial e Final³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPreview == "0"
				If !fChkPesq( oObj:oWSGETRESEARCHRESULT:cSTATUS, oObj:oWSGETRESEARCHRESULT:dINITIALDATE, ;
								oObj:oWSGETRESEARCHRESULT:cINITIALHOUR, oObj:oWSGETRESEARCHRESULT:dFINALDATE, ;
								oObj:oWSGETRESEARCHRESULT:cFINALHOUR, oObj:oWSGETRESEARCHRESULT:cDESCRIPTION, ;
								@cErro )
				
					Return fHtmlAlert( STR0001, '<td align="middle">' + cErro + '</td>' ) //"Atenção"
				EndIf
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Montagem da tabela (HTML) dinamica das regras da pesuisa³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cHtmlRegra += '<table width="260" border="0" align="right" cellpadding="0" cellspacing="0" bordercolor="#E5E5E5">' + CRLF
			cHtmlRegra += '  <tr>' + CRLF
			cHtmlRegra += '    <td bordercolor="#FFFFFF" class="titulo" valign="top">' + CRLF
			cHtmlRegra += '      <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">' + CRLF
			cHtmlRegra += '        <tr>' + CRLF
			cHtmlRegra += '          <td height="32" class="titulo">&nbsp;&nbsp;&nbsp;&nbsp;<span class="tituloLoginGde">' + STR0010 + '</span></td>' + CRLF
			cHtmlRegra += '        </tr>' + CRLF
			cHtmlRegra += '        <tr>' + CRLF
			cHtmlRegra += '          <td class="FundoPontilhado"><img src="../imagens/Por/transparente.gif" width="5" height="5"></td>' + CRLF
			cHtmlRegra += '        </tr>' + CRLF
			cHtmlRegra += '      </table>' + CRLF
			cHtmlRegra += '      <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0">' + CRLF
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Array com as Regras da Pesquisa³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nI := 1 To Len( oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW )
				cHtmlRegra += '        <tr>' + CRLF
				cHtmlRegra += '          <td width="50%" class="textopeq"><span class="TituloLogin">' + oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW[nI]:cWEBTEXT + ':</span></td>' + CRLF
				cHtmlRegra += '          <td width="50%" class="titulo"><input name="R' + oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW[nI]:cITEM + '" type="text" class="combo" value="" maxlength="40"></td>' + CRLF
				cHtmlRegra += '        </tr>' + CRLF
			Next nI
	
			cHtmlRegra += '        <tr>' + CRLF
			cHtmlRegra += '          <td height="33" class="TituloMenor">&nbsp;</td>' + CRLF
			cHtmlRegra += '          <td valign="bottom" class="titulo">' + CRLF
			cHtmlRegra += '            <input name="Button" type="button" class="Botoes" value="' + STR0002 + '" onClick="document.forms[0].submit()">' + CRLF //"enviar"
			cHtmlRegra += '            <input name="Submit2" type="reset" class="Botoes" value="' + STR0003 + '">' + CRLF //"limpar"
			cHtmlRegra += '          </td>' + CRLF
			cHtmlRegra += '        </tr>' + CRLF
			cHtmlRegra += '        <tr>' + CRLF
			cHtmlRegra += '          <td colspan="2">&nbsp;</td>' + CRLF
			cHtmlRegra += '        </tr>' + CRLF
			cHtmlRegra += '      </table>' + CRLF
			cHtmlRegra += '    </td>' + CRLF
			cHtmlRegra += '  </tr>' + CRLF
			cHtmlRegra += '</table>' + CRLF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Session com a tabela (HTML) dinamica³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PGPR000INFO := cHtmlRegra
		Else
			Return fHtmlAlert( STR0001, "" ) //"Atenção"
		EndIf
		
		cHtml += ExecInPage( "PGPR000" )
	Else
		Return fHtmlAlert( STR0001, STR0004 ) //"Atenção"###"O ID não é válido. <br>Favor entrar em contato com os responsáveis técnicos da Pesquisa, ou com a Microsiga Software S/A."
	EndIf
Else
	Return fHtmlAlert( STR0001, STR0005 ) //"Atenção"###"O ID não encontrado. <br>Favor entrar em contato com os responsáveis técnicos da Pesquisa, ou com a Microsiga Software S/A.</td>"
EndIf

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PGPR001   ºAutor  ³Luiz Felipe Couto    º Data ³  02/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida Regras da Pesquisa.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPR     						                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PGPR001()

Local cHtml 		:= ""						//Pagina WEB
Local cFunction		:= ""						//Funcao de validacao
Local cPesquisa		:= ""						//String contendo os dados da Pesquisa
Local cCodPesq		:= ""						//Codigo da Pesquisa
Local cCodQuest		:= ""						//Codigo do Questionario
Local cCodGrupo		:= ""						//Codigo do Grupo
Local cCodSubGrupo	:= ""						//Codigo do SubGrupo
Local cCodPerg		:= ""						//Codigo da Questao
Local cTipo			:= ""						//Tipo de apresentacao
Local cPreview		:= ""						//Preview
Local cObjetivo		:= ""						//Objetivo - Entrevistador
Local cCodResp		:= ""						//Chave do Respondente
Local cErro			:= ""						//Mensagem de Erro

Local nI			:= 0						//Variavel de apoio

Local lRet			:= .T.						//Retorno da Validacao

Local oObj										//Objeto WS - WSGPRRESEARCH

WEB EXTENDED INIT cHtml

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica integridade do Id³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( HttpPost->cId )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica intergridade do parametro cId³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If fURL2Pesq( HttpPost->cId, @cPesquisa )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exemplo de string contendo os dados da Pesquisa³
		//³000001000001000001000001000001111xxx           ³
		//³1     2     3     4     5     6789             ³
		//³1 - Pesquisa                                   ³
		//³2 - Questionario                               ³
		//³3 - Grupo                                      ³
		//³4 - SubGrupo                                   ³
		//³5 - Questao                                    ³
		//³6 - Tipo                                       ³
		//³7 - Preview                                    ³
		//³8 - Objetivo                                   ³
		//³9 - Chave do Respondente                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodPesq		:= SubStr( cPesquisa, 1, 6 )
		cCodQuest		:= SubStr( cPesquisa, 7, 6 )
		cCodGrupo 		:= SubStr( cPesquisa, 13, 6 )
		cCodSubGrupo	:= SubStr( cPesquisa, 19, 6 )
		cCodPerg		:= SubStr( cPesquisa, 25, 6 )
		cTipo			:= SubStr( cPesquisa, 31, 1 )
		cPreview		:= SubStr( cPesquisa, 32, 1 )
		cObjetivo		:= SubStr( cPesquisa, 33, 1 )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa o objeto WS - WSGPRRESEARCH³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj := WSGPRRESEARCH():New()
		WsChgURL( @oObj, "GPRRESEARCH.APW" )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETRESEARCH³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj:cUSERCODE		:= "MSALPHA"
		oObj:cRESEARCHCODE	:= cCodPesq
		
		//cUSERCODE,cRESEARCHCODE,cQUERYADDWHERE
		If oObj:GETRESEARCH()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verificacao da Ativacao, Data de Vigencia Inicial e Final³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPreview == "0"
				If !fChkPesq( oObj:oWSGETRESEARCHRESULT:cSTATUS, oObj:oWSGETRESEARCHRESULT:dINITIALDATE, ;
								oObj:oWSGETRESEARCHRESULT:cINITIALHOUR, oObj:oWSGETRESEARCHRESULT:dFINALDATE, ;
								oObj:oWSGETRESEARCHRESULT:cFINALHOUR, oObj:oWSGETRESEARCHRESULT:cDESCRIPTION, ;
								@cErro )
				
					Return fHtmlAlert( STR0001, '<td align="middle">' + cErro + '</td>' ) //"Atenção"
				EndIf
			EndIf
		Else
			Return fHtmlAlert( STR0001, "" ) //"Atenção"
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca todos os campos do Post³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI := 1 To Len( HttpPost->aPost )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nome do Campo contendo o item da Regra da Pesquisa³
			//³RXXXXXX                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SubStr( HttpPost->aPost[nI], 1, 1 ) == "R"
				nPos := aScan( oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW, { |x| x:cITEM == SubStr( HttpPost->aPost[nI], 2, Len( HttpPost->aPost[nI] ) ) } )
				
				If nPos > 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Nome da Funcao sem os parenteses³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cFunction := SubStr( oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW[nPos]:oWSVALIDATION:cVALFUNCTION, 1, At( "(", oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW[nPos]:oWSVALIDATION:cVALFUNCTION ) - 1 )
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Executa a Funcao de Validacao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If &( cFunction + "( '" + &( "HttpPost->" + HttpPost->aPost[nI] ) + "' )" )
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Utiliza campo como Chave do Respondente³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty( oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW[nPos]:cRESEARCHEDKEY ) .OR. ;
							oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW[nPos]:cRESEARCHEDKEY == SIM
							
							cCodResp += &( "HttpPost->" + HttpPost->aPost[nI] )
						EndIf
						
						lRet := .T.
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Validacao invalida³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						HttpPost->cErro := STR0006 + oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW[nPos]:oWSVALIDATION:cDESCRIPTION + STR0007 //"Validação <b>"###"</b> não efetuada."
						
						lRet := .F.
						
						Exit
					EndIf
				EndIf
			EndIf
		Next nI
	Else
		Return fHtmlAlert( STR0001, STR0008 ) //"Atenção"###"O ID não é válido. <br>Favor entrar em contato com os responsáveis técnicos da Pesquisa, ou com a Microsiga Software S/A.</td>"
	EndIf
	
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Novo Id para Realizacao da Pesquisa contendo a chave do Respondente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		HttpPost->cId := fPesq2URL( cCodPesq + cCodQuest + 	cCodGrupo + cCodSubGrupo + ;
										cCodPerg + cTipo + cPreview + cObjetivo + ;
				  						cCodResp + DToC( Date() ) + SubStr( Time(), 1, 5 ) )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorna a Pesquisa³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHtml := W_PGPR010()
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametro cId vem por Post, mas ao voltar para a tela³
		//³de Regra de Pesquisa manter como Get                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		HttpGet->cId := HttpPost->cId
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorna a Regra de Pesquisa com a Mensagem de Erro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHtml := W_PGPR000()
	EndIf
Else
	Return fHtmlAlert( STR0001, STR0005 ) //"Atenção"###"O ID não encontrado. <br>Favor entrar em contato com os responsáveis técnicos da Pesquisa, ou com a Microsiga Software S/A.</td>"
EndIf

WEB EXTENDED END

Return cHtml