#INCLUDE "PGPR010.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE CRLF				Chr( 13 )

//зддддддддддддддддддддддд©
//ЁAlinhamento da MensagemЁ
//юддддддддддддддддддддддды
#DEFINE ESQUERDA			"left"			//Alinhamento a esquerda
#DEFINE MEIO				"middle"		//Alinhamento ao meio
#DEFINE DIREITA			"right"			//Alinhamento a direita

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммямммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPGPR010   ╨Autor  ЁLuiz Felipe Couto    ╨ Data Ё  02/03/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммомммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Retorna a pesquisa no formato HTML.                         ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ParametrosЁ                                                             ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁSIGAGPR     						                           ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╨Analista  Ё Data/Bops/Ver ЁManutencao Efetuada                      	   ╨╠╠
╠╠лммммммммммьммммммммяммммммьммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Michel M. |08/05/07|8.11  |Bops:125285 - Adiciona uma linha entre cada  ╨╠╠
╠╠╨          |        |      |grupo/subgrupo.                              ╨╠╠
╠╠хммммммммммоммммммммоммммммоммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Web Function PGPR010()

Local cHtml 		:= ""				//Pagina WEB
Local cHtmlPesq		:= ""				//String contendo a pesquisa para ser inserida na pagina
Local cHtmlQst		:= ""				//String contendo o questionario para ser inserida na pagina
Local cHtmlGrupo	:= ""				//String contendo o grupo para ser inserida na pagina
Local cHtmlSubGrupo	:= ""				//String contendo o subgrupo para ser inserida na pagina
Local cHtmlPerg		:= ""				//String contendo a pergunta para ser inserida na pagina
Local cNumPerg 		:= ""				//Numero da pergunta
Local cEnumera		:= ""				//Enumera Questionario
Local cPesquisa		:= ""				//String contendo todos os dados da pesquisa
Local cCodPesq		:= ""				//Codigo da Pesquisa
Local cCodQuest		:= ""				//Codigo do Questionario
Local cCodGrupo		:= ""				//Codigo do Grupo
Local cCodSubGrupo	:= ""				//Codigo do SubGrupo
Local cCodPerg		:= ""				//Codigo da Pergunta
Local cTipo			:= ""				//Tipo de apresentacao
Local cPreview		:= ""				//Preview
Local cObjetivo		:= ""				//Objetivo - Utilizado pelo entrevistador
Local cErro			:= ""				//Erro Verificacao Ativacao, Data de Vigencia Inicial e Final

Local nI 			:= 0				//Variavel de apoio
Local nJ 			:= 0				//Variavel de apoio
Local nK 			:= 0				//Variavel de apoio
Local nL 			:= 0				//Variavel de apoio
Local nQst 			:= 0				//Numero de Questoes
Local nQstGrupo 	:= 0				//Numero de Questoes por Grupo
Local nQstSubGrupo 	:= 0				//Numero de Questoes por SubGrupo

Local oObj								//Obejto WS - WSGPRRESEARCH
Local oPergTmp							//Objeto WS - GPRRESEARCH_QUESTIONVIEW
Local oAltTmp							//Objeto WS - GPRRESEARCH_ALTERNATIVEVIEW

WEB EXTENDED INIT cHtml

//здддддддддддддддддддддддддддддддддддддддддд©
//ЁSe for Preview o parametro cId vem por GetЁ
//ЁCaso contrario vem por Post               Ё
//юдддддддддддддддддддддддддддддддддддддддддды
If Empty( HttpPost->cId ) .AND. !Empty( HttpGet->cId )
	HttpPost->cId := HttpGet->cId
EndIf

//здддддддддддддддддддддддддд©
//ЁVerifica integridade do IdЁ
//юдддддддддддддддддддддддддды
If !Empty( HttpPost->cId )
	//здддддддддддддддддддддддддддддддддддддд©
	//ЁVerifica intergridade do parametro cIdЁ
	//юдддддддддддддддддддддддддддддддддддддды
	If fURL2Pesq( HttpPost->cId, @cPesquisa )
		//зддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁExemplo de string contendo os dados da PesquisaЁ
		//Ё000001000001000001000001000001111xxx           Ё
		//Ё1     2     3     4     5     6789             Ё
		//Ё1 - Pesquisa                                   Ё
		//Ё2 - Questionario                               Ё
		//Ё3 - Grupo                                      Ё
		//Ё4 - SubGrupo                                   Ё
		//Ё5 - Questao                                    Ё
		//Ё6 - Tipo                                       Ё
		//Ё7 - Preview                                    Ё
		//Ё8 - Objetivo                                   Ё
		//Ё9 - Chave do Respondente                       Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддды
		cCodPesq		:= SubStr( cPesquisa, 1, 6 )
		cCodQuest		:= SubStr( cPesquisa, 7, 6 )
		cCodGrupo 		:= SubStr( cPesquisa, 13, 6 )
		cCodSubGrupo	:= SubStr( cPesquisa, 19, 6 )
		cCodPerg		:= SubStr( cPesquisa, 25, 6 )
		cTipo			:= SubStr( cPesquisa, 31, 1 )
		cPreview		:= SubStr( cPesquisa, 32, 1 )
		cObjetivo		:= SubStr( cPesquisa, 33, 1 )
		
		//зддддддддддддд©
		//ЁTipo invalidoЁ
		//юддддддддддддды
		If cTipo == "0"
			Return fHtmlAlert( STR0001, STR0002 ) //"AtenГЦo"###"O ID nЦo И vАlido. <br>Favor entrar em contato com os responsАveis tИcnicos da Pesquisa, ou com a Microsiga Software S/A. "
		EndIf
		
		//здддддддддддддддддддддддддддддддд©
		//ЁSession de apoio utlizada no APHЁ
		//юдддддддддддддддддддддддддддддддды
		HttpSession->PGPR010APH := { "W_PGPR011.APW" }				//Action do Post (HTML)
		
		//зддддддддддддддддддддддддд©
		//ЁExibe objetivo da QuestaoЁ
		//юддддддддддддддддддддддддды
		HttpSession->PGPR010OBJ := cObjetivo
		
		//зддддддддддддддддддддд©
		//ЁQuestoes ObrigatoriasЁ
		//юддддддддддддддддддддды
		HttpSession->PGPRXFUNOBRIGAT := {}

		Do Case
			//здддддддддддддд©
			//ЁMonta PesquisaЁ
			//юдддддддддддддды
			Case cTipo == "1"
				//здддддддддддддддддддддддддддддддддддддд©
				//ЁInicializa o objeto WS - WSGPRRESEARCHЁ
				//юдддддддддддддддддддддддддддддддддддддды
				oObj := WSGPRRESEARCH():New()
				WsChgURL( @oObj, "GPRRESEARCH.APW" )
	
				//здддддддддддддддддддддддддддддддд©
				//ЁParametros do metodo GETRESEARCHЁ
				//юдддддддддддддддддддддддддддддддды
				oObj:cUSERCODE		:= "MSALPHA"
				oObj:cRESEARCHCODE	:= cCodPesq
				
				//cUSERCODE,cRESEARCHCODE,cQUERYADDWHERE
				If oObj:GETRESEARCH()
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁVerificacao da Ativacao, Data de Vigencia Inicial e FinalЁ
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If cPreview == "0"
						If !fChkPesq( oObj:oWSGETRESEARCHRESULT:cSTATUS, oObj:oWSGETRESEARCHRESULT:dINITIALDATE, ;
										oObj:oWSGETRESEARCHRESULT:cINITIALHOUR, oObj:oWSGETRESEARCHRESULT:dFINALDATE, ;
										oObj:oWSGETRESEARCHRESULT:cFINALHOUR, oObj:oWSGETRESEARCHRESULT:cDESCRIPTION, ;
										@cErro )
						
							Return fHtmlAlert( STR0001, cErro ) //"AtenГЦo"
						EndIf
					EndIf

					//здддддддддддддддддддддддддддд©
					//ЁMontagem do Topo da PesquisaЁ
					//юдддддддддддддддддддддддддддды
					cHtmlPesq += fHtmlTopo()
					
					//здддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁMontagem da tabela (HTML) dinamica da pesquisaЁ
					//юдддддддддддддддддддддддддддддддддддддддддддддды
					cHtmlPesq += '<!-- PESQUISA -->' + CRLF
					cHtmlPesq += '<tbody>' + CRLF
					cHtmlPesq += '  <tr>' + CRLF
					cHtmlPesq += '    <td class="texto" colSpan="5">&nbsp;</td>' + CRLF
					cHtmlPesq += '  </tr>' + CRLF
					cHtmlPesq += '  <tr class="FundotrPesquisa">' + CRLF
					cHtmlPesq += '    <td class="TextoGrupo" align="middle" colSpan="5">' + CRLF
					cHtmlPesq += '      <strong>' + oObj:oWSGETRESEARCHRESULT:cDESCRIPTION + '</strong>' + CRLF
					cHtmlPesq += '    </td>' + CRLF
					cHtmlPesq += '  </tr>' + CRLF
					cHtmlPesq += '  <tr>' + CRLF
					cHtmlPesq += '    <td colSpan="5">&nbsp;</td>' + CRLF
					cHtmlPesq += '  </tr>' + CRLF
	
					//здддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁObejtivo da Questao - Utilizada pelo EntrevistadorЁ
					//юдддддддддддддддддддддддддддддддддддддддддддддддддды
					If !Empty( oObj:oWSGETRESEARCHRESULT:cOBJECTIVEDESCRIPTION )
						cHtmlPesq += '  <tr>' + CRLF
						cHtmlPesq += '    <td class="TextoDescricao" colSpan="5">' + oObj:oWSGETRESEARCHRESULT:cOBJECTIVEDESCRIPTION + '</td>' + CRLF
						cHtmlPesq += '  </tr>' + CRLF
					EndIf
					
					cHtmlPesq += '  <tr>' + CRLF
					cHtmlPesq += '    <td colSpan="5">&nbsp;</td>' + CRLF
					cHtmlPesq += '  </tr>' + CRLF
					cHtmlPesq += '</tbody>' + CRLF
				
					//здддддддддддддддддддддддддд©
					//ЁMontagem dos QuestionariosЁ
					//юдддддддддддддддддддддддддды
					For nI := 1 To Len( oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW )
						cHtmlPesq += '<!-- QUESTIONаRIO -->' + CRLF
						cHtmlPesq += '<tbody>' + CRLF
						cHtmlPesq += '  <!-- DESCRIгцO DO QUESTIONаRIO -->' + CRLF
						cHtmlPesq += '  <tr class="FundotrQuest">' + CRLF
						cHtmlPesq += '    <td class="TextoGrupo" align="middle" colSpan="5">.::&nbsp;' + oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:cDESCRIPTION + '&nbsp;::.</td>' + CRLF
						cHtmlPesq += '  </tr>' + CRLF
						cHtmlPesq += '  <tr>' + CRLF
						cHtmlPesq += '    <td class="TextoGrupo" align="middle" colSpan="5">&nbsp;</td>' + CRLF
						cHtmlPesq += '  </tr>' + CRLF
						cHtmlPesq += '</tbody>' + CRLF
						
						//зддддддддддддддддддддд©
						//ЁItens do QuestionarioЁ
						//юддддддддддддддддддддды
						For nJ := 1 To Len( oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFITEM:cSTRING )
							If !Empty( oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
								nPos := aScan( oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFQUESTION:oWSQUESTIONVIEW, { |x| x:cITEM == oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFITEM:cSTRING[nJ] } )
							
								If nPos > 0
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//ЁMontagem das Questoes independentes do Grupo e SubGrupoЁ
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									oPergTmp 		:= oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nPos]
									oAltTmp 		:= oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nPos]:oWSLISTOFALTERNATIVE:oWSALTERNATIVEVIEW
									cCodQuest		:= oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:cCODE
									cCodPerg		:= oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nPos]:cCODE
									
									cHtmlPesq += fHtmlPerg( oPergTmp, oAltTmp,, oObj:oWSGETRESEARCHRESULT:cCODE, cCodQuest,,, cCodPerg )
									
									If nJ < Len( oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFITEM:cSTRING )
										//здддддддддддддддддд©
										//ЁLinha de SeparacaoЁ
										//юдддддддддддддддддды
										cHtmlPesq += '<tr>' + CRLF
										cHtmlPesq += '  <td colspan="5"><hr color="#CCCCCC" noshade></td>' + CRLF
										cHtmlPesq += '</tr>' + CRLF
									EndIf
	
									Loop
								EndIf
							EndIf
					
							nPos := aScan( oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW, { |x| x:cITEM == oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFITEM:cSTRING[nJ] } )
							
							If nPos > 0
								If !Empty( oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
									//зддддддддддддддддддддддддддддддддддддддддддддддд©
									//ЁMontagem das Questoes independentes do SubGrupoЁ
									//юддддддддддддддддддддддддддддддддддддддддддддддды
									For nK := 1 To Len( oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
										If nK == 1
											cHtmlPesq += '<tr class="FundotrGrupo">' + CRLF
											cHtmlPesq += '  <td class="TextoGrupo" align="left" colSpan="5">&gt;&gt;&nbsp;' + oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:cDESCRIPTION + '</td>' + CRLF
											cHtmlPesq += '</tr>' + CRLF
										EndIf
					
										oPergTmp 		:= oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nK]
										oAltTmp 		:= oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nK]:oWSLISTOFALTERNATIVE:oWSALTERNATIVEVIEW
										cCodQuest		:= oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:cCODE
										cCodGrupo 		:= oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:cCODE
										cCodPerg		:= oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nK]:cCODE
										
										cHtmlPesq += fHtmlPerg( oPergTmp, oAltTmp,, oObj:oWSGETRESEARCHRESULT:cCODE, cCodQuest, cCodGrupo,, cCodPerg )
									Next nK
								EndIf
								
								//здддддддддддддддддддддд©
								//ЁMontagem dos SubGruposЁ
								//юдддддддддддддддддддддды
								For nK := 1 To Len( oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW )
									If !Empty( oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nK]:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
										//здддддддддддддддддддддддддддддддддддддддддд©
										//ЁMontagem das Questoes por Grupo e SubGrupoЁ
										//юдддддддддддддддддддддддддддддддддддддддддды
										For nL := 1 To Len( oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nK]:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
											If nL == 1
												cHtmlPesq += '<tr class="FundotrGrupo">' + CRLF
												cHtmlPesq += '  <td class="TextoGrupo" align="left" colSpan="5">&gt;&gt;&nbsp;' + oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nK]:cDESCRIPTION + '</td>' + CRLF
												cHtmlPesq += '</tr>' + CRLF
											EndIf
					
											oPergTmp 		:= oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nK]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nL]
											oAltTmp 		:= oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nK]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nL]:oWSLISTOFALTERNATIVE:oWSALTERNATIVEVIEW
											cCodQuest		:= oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:cCODE
											cCodGrupo 		:= oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:cCODE
											cCodSubGrupo 	:= oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nK]:cCODE
											cCodPerg		:= oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nK]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nL]:cCODE
				
											cHtmlPesq += fHtmlPerg( oPergTmp, oAltTmp,, oObj:oWSGETRESEARCHRESULT:cCODE, cCodQuest, cCodGrupo, cCodSubGrupo, cCodPerg )
										Next nL 
										If nL >= Len( oObj:oWSGETRESEARCHRESULT:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nI]:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nK]:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
											//здддддддддддддддддд©
											//ЁLinha de SeparacaoЁ
											//юдддддддддддддддддды
											cHtmlPesq += '<tr>' + CRLF
											cHtmlPesq += '  <td colspan="5"><hr color="#CCCCCC" noshade></td>' + CRLF
											cHtmlPesq += '</tr>' + CRLF
										EndIf										
									EndIf
								Next nK
						
								Loop
							EndIf
						Next nJ
				
						cHtmlPesq += '<!-- FINALIZA QUESTIONаRIO -->' + CRLF
					Next nI
				
					//здддддддддддддддддддддддддддддд©
					//ЁMontagem do Rodape da PesquisaЁ
					//юдддддддддддддддддддддддддддддды
					cHtmlPesq += fHtmlRod( cPreview )
					
					//здддддддддддддддддддддддддддддддддддд©
					//ЁSession com a tabela (HTML) dinamicaЁ
					//юдддддддддддддддддддддддддддддддддддды
					HttpSession->PGPR010INFO := cHtmlPesq
				Else
					Return fHtmlAlert( STR0001, "" ) //"AtenГЦo"
				EndIf
	
			//здддддддддддддддддд©
			//ЁMonta QuestionarioЁ
			//юдддддддддддддддддды
			Case cTipo == "2"
				//здддддддддддддддддддддддддддддддддддддд©
				//ЁInicializa o objeto WS - WSGPRRESEARCHЁ
				//юдддддддддддддддддддддддддддддддддддддды
				oObj := WSGPRQUESTIONARY():New()
				WsChgURL( @oObj, "GPRQUESTIONARY.APW" )
	
				//зддддддддддддддддддддддддддддддддддд©
				//ЁParametros do metodo GETQUESTIONARYЁ
				//юддддддддддддддддддддддддддддддддддды
				oObj:cUSERCODE			:= "MSALPHA"
				oObj:cQUESTIONARYCODE	:= cCodQuest
				
				//cUSERCODE,cQUESTIONARYCODE,cQUERYADDWHERE
				If oObj:GETQUESTIONARY()
					//здддддддддддддддддддддддддддд©
					//ЁMontagem do Topo da PesquisaЁ
					//юдддддддддддддддддддддддддддды
					cHtmlQst += fHtmlTopo()
			
					//здддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁMontagem da tabela (HTML) dinamica do questionarioЁ
					//юдддддддддддддддддддддддддддддддддддддддддддддддддды
					cHtmlQst += '<!-- QUESTIONаRIO -->' + CRLF
					cHtmlQst += '<tbody>' + CRLF
					cHtmlQst += '  <!-- DESCRIгцO DO QUESTIONаRIO -->' + CRLF
					cHtmlQst += '  <tr class="FundotrQuest">' + CRLF
					cHtmlQst += '    <td class="TextoGrupo" align="middle" colSpan="5">.::&nbsp;' + oObj:oWSGETQUESTIONARYRESULT:cDESCRIPTION + '&nbsp;::.</td>' + CRLF
					cHtmlQst += '  </tr>' + CRLF
					cHtmlQst += '  <tr>' + CRLF
					cHtmlQst += '    <td class="TextoGrupo" align="middle" colSpan="5">&nbsp;</td>' + CRLF
					cHtmlQst += '  </tr>' + CRLF
					cHtmlQst += '</tbody>' + CRLF
					
					//зддддддддддддддддддддд©
					//ЁItens do QuestionarioЁ
					//юддддддддддддддддддддды
					For nI := 1 To Len( oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFITEM:cSTRING )
						If !Empty( oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
							nPos := aScan( oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFQUESTION:oWSQUESTIONVIEW, { |x| x:cITEM == oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFITEM:cSTRING[nI] } )
						
							If nPos > 0
								//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//ЁMontagem das Questoes independentes do Grupo e SubGrupo|
								//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								oPergTmp 		:= oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nPos]
								oAltTmp 		:= oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nPos]:oWSLISTOFALTERNATIVE:oWSALTERNATIVEVIEW
								cCodQuest		:= oObj:oWSGETQUESTIONARYRESULT:cCODE
								cCodPerg		:= oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nPos]:cCODE
			
								cHtmlQst += fHtmlPerg( oPergTmp, oAltTmp,,, cCodQuest,,, cCodPerg )
			
								If nI < Len( oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFITEM:cSTRING )
									//здддддддддддддддддд©
									//ЁLinha de SeparacaoЁ
									//юдддддддддддддддддды
									cHtmlQst += '<tr>' + CRLF
									cHtmlQst += '  <td colspan="5"><hr color="#CCCCCC" noshade></td>' + CRLF
									cHtmlQst += '</tr>' + CRLF
								EndIf
								
								Loop
							EndIf
						EndIf
				
						nPos := aScan( oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW, { |x| x:cITEM == oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFITEM:cSTRING[nI] } )
						
						If nPos > 0
							If !Empty( oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
								//зддддддддддддддддддддддддддддддддддддддддддддддд©
								//ЁMontagem das Questoes independentes do SubGrupoЁ
								//юддддддддддддддддддддддддддддддддддддддддддддддды
								For nJ := 1 To Len( oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
									If nJ == 1
										cHtmlQst += '<tr class="FundotrGrupo">' + CRLF
										cHtmlQst += '  <td class="TextoGrupo" align="left" colSpan="5">&gt;&gt;&nbsp;' + oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:cDESCRIPTION + '</td>' + CRLF
										cHtmlQst += '</tr>' + CRLF
									EndIf
				
									oPergTmp 		:= oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nJ]
									oAltTmp 		:= oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nJ]:oWSLISTOFALTERNATIVE:oWSALTERNATIVEVIEW
									cCodQuest		:= oObj:oWSGETQUESTIONARYRESULT:cCODE
									cCodGrupo 		:= oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:cCODE
									cCodPerg		:= oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nJ]:cCODE
				
									cHtmlQst += fHtmlPerg( oPergTmp, oAltTmp,,, cCodQuest, cCodGrupo,, cCodPerg )
								Next nJ
							EndIf
								
							//здддддддддддддддддддддд©
							//ЁMontagem dos SubGruposЁ
							//юдддддддддддддддддддддды
							For nJ := 1 To Len( oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW )
								If !Empty( oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nJ]:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
									//здддддддддддддддддддддддддддддддддддддддддд©
									//ЁMontagem das Questoes por Grupo e SubGrupoЁ
									//юдддддддддддддддддддддддддддддддддддддддддды
									For nK := 1 To Len( oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nJ]:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
										If nK == 1
											cHtmlQst += '<tr class="FundotrGrupo">' + CRLF
											cHtmlQst += '  <td class="TextoGrupo" align="left" colSpan="5">&gt;&gt;&nbsp;' + oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nJ]:cDESCRIPTION + '</td>' + CRLF
											cHtmlQst += '</tr>' + CRLF
										EndIf
				
										oPergTmp 		:= oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nJ]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nK]
										oAltTmp 		:= oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nJ]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nK]:oWSLISTOFALTERNATIVE:oWSALTERNATIVEVIEW
										cCodQuest		:= oObj:oWSGETQUESTIONARYRESULT:cCODE
										cCodGrupo 		:= oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:cCODE
										cCodSubGrupo 	:= oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nJ]:cCODE
										cCodPerg		:= oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nJ]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nK]:cCODE
			
										cHtmlQst += fHtmlPerg( oPergTmp, oAltTmp,,, cCodQuest, cCodGrupo, cCodSubGrupo, cCodPerg )
									Next nK
									If nK >= Len( oObj:oWSGETQUESTIONARYRESULT:oWSLISTOFGROUP:oWSGROUPVIEW[nPos]:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nJ]:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
										//здддддддддддддддддд©
										//ЁLinha de SeparacaoЁ
										//юдддддддддддддддддды
										cHtmlQst += '<tr>' + CRLF
										cHtmlQst += '  <td colspan="5"><hr color="#CCCCCC" noshade></td>' + CRLF
										cHtmlQst += '</tr>' + CRLF
									EndIf									
								EndIf								
							Next nJ	
							Loop
						EndIf
					Next nI
			
					cHtmlQst += '<!-- FINALIZA QUESTIONаRIO -->' + CRLF
				
					//здддддддддддддддддддддддддддддд©
					//ЁMontagem do Rodape da PesquisaЁ
					//юдддддддддддддддддддддддддддддды
					cHtmlQst += fHtmlRod( cPreview )
	
					//здддддддддддддддддддддддддддддддддддд©
					//ЁSession com a tabela (HTML) dinamicaЁ
					//юдддддддддддддддддддддддддддддддддддды
					HttpSession->PGPR010INFO := cHtmlQst
				Else
					Return fHtmlAlert( STR0001, "" ) //"AtenГЦo"
				EndIf
	
			//здддддддддддд©
			//ЁMonta GruposЁ
			//юдддддддддддды
			Case cTipo == "3"
				//зддддддддддддддддддддддддддддддддддд©
				//ЁInicializa o objeto WS - WSGPRGROUPЁ
				//юддддддддддддддддддддддддддддддддддды
				oObj := WSGPRGROUP():New()
				WsChgURL( @oObj, "GPRGROUP.APW" )
	
				//зддддддддддддддддддддддддддддд©
				//ЁParametros do metodo GETGROUPЁ
				//юддддддддддддддддддддддддддддды
				oObj:cUSERCODE	:= "MSALPHA"
				oObj:cGROUPCODE	:= cCodGrupo
				
				//cUSERCODE,cGROUPCODE,cQUERYADDWHERE
				If oObj:GETGROUP()
					//здддддддддддддддддддддддддддд©
					//ЁMontagem do Topo da PesquisaЁ
					//юдддддддддддддддддддддддддддды
					cHtmlGrupo += fHtmlTopo()
	
					//зддддддддддддддддддддддддддддддддддддддддддд©
					//ЁMontagem da tabela (HTML) dinamica do grupoЁ
					//юддддддддддддддддддддддддддддддддддддддддддды
					cHtmlGrupo += '<!-- INмCIO GRUPO -->' + CRLF
	
					If !Empty( oObj:oWSGETGROUPRESULT:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
						//зддддддддддддддддддддддддддддддддддддддддддддддд©
						//ЁMontagem das Questoes independentes do SubGrupoЁ
						//юддддддддддддддддддддддддддддддддддддддддддддддды
						For nI := 1 To Len( oObj:oWSGETGROUPRESULT:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
							If nI == 1
								cHtmlGrupo += '<tr class="FundotrGrupo">' + CRLF
								cHtmlGrupo += '  <td class="TextoGrupo" align="left" colSpan="5">&gt;&gt;&nbsp;' + oObj:oWSGETGROUPRESULT:cDESCRIPTION + '</td>' + CRLF
								cHtmlGrupo += '</tr>' + CRLF
							EndIf
		
							oPergTmp 		:= oObj:oWSGETGROUPRESULT:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nI]
							oAltTmp 		:= oObj:oWSGETGROUPRESULT:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nI]:oWSLISTOFALTERNATIVE:oWSALTERNATIVEVIEW
							cCodGrupo 		:= oObj:oWSGETGROUPRESULT:cCODE
							cCodPerg		:= oObj:oWSGETGROUPRESULT:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nI]:cCODE
		
							cHtmlGrupo += fHtmlPerg( oPergTmp, oAltTmp,,,, cCodGrupo,, cCodPerg )
						Next nI
					EndIf
						
					//здддддддддддддддддддддд©
					//ЁMontagem dos SubGruposЁ
					//юдддддддддддддддддддддды
					For nI := 1 To Len( oObj:oWSGETGROUPRESULT:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW )
						If !Empty( oObj:oWSGETGROUPRESULT:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nI]:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
							//здддддддддддддддддддддддддддддддддддддддддд©
							//ЁMontagem das Questoes por Grupo e SubGrupoЁ
							//юдддддддддддддддддддддддддддддддддддддддддды
							For nJ := 1 To Len( oObj:oWSGETGROUPRESULT:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nI]:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
								If nJ == 1
									cHtmlGrupo += '<tr class="FundotrGrupo">' + CRLF
									cHtmlGrupo += '  <td class="TextoGrupo" align="left" colSpan="5">&gt;&gt;&nbsp;' + oObj:oWSGETGROUPRESULT:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nI]:cDESCRIPTION + '</td>' + CRLF
									cHtmlGrupo += '</tr>' + CRLF
								EndIf
		
								oPergTmp 		:= oObj:oWSGETGROUPRESULT:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nI]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nJ]
								oAltTmp 		:= oObj:oWSGETGROUPRESULT:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nI]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nJ]:oWSLISTOFALTERNATIVE:oWSALTERNATIVEVIEW
								cCodGrupo 		:= oObj:oWSGETGROUPRESULT:cCODE
								cCodSubGrupo 	:= oObj:oWSGETGROUPRESULT:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nI]:cCODE
								cCodPerg		:= oObj:oWSGETGROUPRESULT:oWSLISTOFSUBGROUP:oWSSUBGROUPVIEW[nI]:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nJ]:cCODE
	
								cHtmlGrupo 		+= fHtmlPerg( oPergTmp, oAltTmp,,,, cCodGrupo, cCodSubGrupo, cCodPerg )
							Next nJ
						EndIf
					Next nI
			
					cHtmlGrupo += '<!-- FINALIZA GRUPO -->' + CRLF
				
					//здддддддддддддддддддддддддддддд©
					//ЁMontagem do Rodape da PesquisaЁ
					//юдддддддддддддддддддддддддддддды
					cHtmlGrupo += fHtmlRod( cPreview )
	
					//здддддддддддддддддддддддддддддддддддд©
					//ЁSession com a tabela (HTML) dinamicaЁ
					//юдддддддддддддддддддддддддддддддддддды
					HttpSession->PGPR010INFO := cHtmlGrupo
				Else
					Return fHtmlAlert( STR0001, "" ) //"AtenГЦo"
				EndIf
	
			//зддддддддддддддд©
			//ЁMonta SubGruposЁ
			//юддддддддддддддды
			Case cTipo == "4"
				//здддддддддддддддддддддддддддддддддддддд©
				//ЁInicializa o objeto WS - WSGPRSUBGROUPЁ
				//юдддддддддддддддддддддддддддддддддддддды
				oObj := WSGPRSUBGROUP():New()
				WsChgURL( @oObj, "GPRSUBGROUP.APW" )
	
				//здддддддддддддддддддддддддддддддд©
				//ЁParametros do metodo GETSUBGROUPЁ
				//юдддддддддддддддддддддддддддддддды
				oObj:cUSERCODE		:= "MSALPHA"
				oObj:cGROUPCODE		:= cCodGrupo
				oObj:cSUBGROUPCODE	:= cCodSubGrupo
				
				//cUSERCODE,cGROUPCODE,cSUBGROUPCODE,cQUERYADDWHERE
				If oObj:GETSUBGROUP()
					//здддддддддддддддддддддддддддд©
					//ЁMontagem do Topo da PesquisaЁ
					//юдддддддддддддддддддддддддддды
					cHtmlSubGrupo += fHtmlTopo()
	
					//здддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁMontagem da tabela (HTML) dinamica do subgrupoЁ
					//юдддддддддддддддддддддддддддддддддддддддддддддды
					cHtmlSubGrupo += '<!-- INмCIO SUBGRUPO -->' + CRLF
	
					//здддддддддддддддддддддд©
					//ЁMontagem dos SubGruposЁ
					//юдддддддддддддддддддддды
					If !Empty( oObj:oWSGETSUBGROUPRESULT:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
						//здддддддддддддддддддддддддддддддддддддддддд©
						//ЁMontagem das Questoes por Grupo e SubGrupoЁ
						//юдддддддддддддддддддддддддддддддддддддддддды
						For nI := 1 To Len( oObj:oWSGETSUBGROUPRESULT:oWSLISTOFQUESTION:oWSQUESTIONVIEW )
							If nI == 1
								cHtmlSubGrupo += '<tr class="FundotrGrupo">' + CRLF
								cHtmlSubGrupo += '  <td class="TextoGrupo" align="left" colSpan="5">&gt;&gt;&nbsp;' + oObj:oWSGETSUBGROUPRESULT:cDESCRIPTION + '</td>' + CRLF
								cHtmlSubGrupo += '</tr>' + CRLF
							EndIf
	
							oPergTmp 		:= oObj:oWSGETSUBGROUPRESULT:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nI]
							oAltTmp 		:= oObj:oWSGETSUBGROUPRESULT:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nI]:oWSLISTOFALTERNATIVE:oWSALTERNATIVEVIEW
							cCodSubGrupo 	:= oObj:oWSGETSUBGROUPRESULT:cCODE
							cCodPerg		:= oObj:oWSGETSUBGROUPRESULT:oWSLISTOFQUESTION:oWSQUESTIONVIEW[nI]:cCODE
	
							cHtmlSubGrupo 		+= fHtmlPerg( oPergTmp, oAltTmp,,,,, cCodSubGrupo, cCodPerg )
						Next nI
					EndIf
			
					cHtmlSubGrupo += '<!-- FINALIZA SUBGRUPO -->' + CRLF
				
					//здддддддддддддддддддддддддддддд©
					//ЁMontagem do Rodape da PesquisaЁ
					//юдддддддддддддддддддддддддддддды
					cHtmlSubGrupo += fHtmlRod( cPreview )
	
					//здддддддддддддддддддддддддддддддддддд©
					//ЁSession com a tabela (HTML) dinamicaЁ
					//юдддддддддддддддддддддддддддддддддддды
					HttpSession->PGPR010INFO := cHtmlSubGrupo
				Else
					Return fHtmlAlert( STR0001, "" ) //"AtenГЦo"
				EndIf
	
			//зддддддддддддддд©
			//ЁMonta PerguntasЁ
			//юддддддддддддддды
			Case cTipo == "5"
				//здддддддддддддддддддддддддддддддддддддд©
				//ЁInicializa o objeto WS - WSGPRSUBGROUPЁ
				//юдддддддддддддддддддддддддддддддддддддды
				oObj := WSGPRQUESTION():New()
				WsChgURL( @oObj, "GPRQUESTION.APW" )
	
				//здддддддддддддддддддддддддддддддд©
				//ЁParametros do metodo GETSUBGROUPЁ
				//юдддддддддддддддддддддддддддддддды
				oObj:cUSERCODE		:= "MSALPHA"
				oObj:cQUESTIONCODE	:= cCodPerg
				
				//cUSERCODE,cQUESTIONCODE,cQUERYADDWHERE
				If oObj:GETQUESTION()
					//здддддддддддддддддддддддддддд©
					//ЁMontagem do Topo da PesquisaЁ
					//юдддддддддддддддддддддддддддды
					cHtmlPerg += fHtmlTopo()
	
					//здддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁMontagem da tabela (HTML) dinamica do subgrupoЁ
					//юдддддддддддддддддддддддддддддддддддддддддддддды
					cHtmlPerg += '<!-- INмCIO PERGUNTA -->' + CRLF
	
					//зддддддддддддддддддддд©
					//ЁMontagem das QuestoesЁ
					//юддддддддддддддддддддды
					oPergTmp 		:= oObj:oWSGETQUESTIONRESULT
					oAltTmp 		:= oObj:oWSGETQUESTIONRESULT:oWSLISTOFALTERNATIVE:oWSALTERNATIVEVIEW
					cCodPerg		:= oObj:oWSGETQUESTIONRESULT:cCODE
	
					cHtmlPerg 		+= fHtmlPerg( oPergTmp, oAltTmp,,,,,, cCodPerg )
			
					cHtmlPerg += '<!-- FINALIZA SUBGRUPO -->' + CRLF
				
					//здддддддддддддддддддддддддддддд©
					//ЁMontagem do Rodape da PesquisaЁ
					//юдддддддддддддддддддддддддддддды
					cHtmlPerg += fHtmlRod( cPreview )
	
					//здддддддддддддддддддддддддддддддддддд©
					//ЁSession com a tabela (HTML) dinamicaЁ
					//юдддддддддддддддддддддддддддддддддддды
					HttpSession->PGPR010INFO := cHtmlPerg
				Else
					Return fHtmlAlert( STR0001, "" ) //"AtenГЦo"
				EndIf
		EndCase		
		
		cHtml += ExecInPage( "PGPR010" )
	Else
		Return fHtmlAlert( STR0001, STR0002 ) //"AtenГЦo"###"O ID nЦo И vАlido. <br>Favor entrar em contato com os responsАveis tИcnicos da Pesquisa, ou com a Microsiga Software S/A. "
	EndIf
Else
	Return fHtmlAlert( STR0001, STR0003 ) //"AtenГЦo"###"ID nЦo encontrado. <br>Favor entrar em contato com os responsАveis tИcnicos da Pesquisa, ou com a Microsiga Software S/A. "
EndIf

WEB EXTENDED END

Return cHtml

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммямммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPGPR011   ╨Autor  ЁLuiz Felipe Couto    ╨ Data Ё  16/03/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммомммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Grava os resultados da Pesquisa.                            ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ParametrosЁ                                                             ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁSIGAGPR     						                           ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╨Analista  Ё Data/Bops/Ver ЁManutencao Efetuada                      	   ╨╠╠
╠╠лммммммммммьммммммммяммммммьммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠хммммммммммоммммммммоммммммоммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Web Function PGPR011()

Local cHtml 		:= ""				//Pagina WEB
Local cPesquisa		:= ""				//String contendo todos os dados da pesquisa
Local cCodPesq		:= ""				//Codigo da Pesquisa
Local cCodQuest		:= ""				//Codigo do Questionario
Local cCodGrupo		:= ""				//Codigo do Grupo
Local cCodSubGrupo	:= ""				//Codigo do SubGrupo
Local cCodPerg		:= ""				//Codigo da Pergunta
Local cTipo			:= ""				//Tipo de apresentacao
Local cPreview		:= ""				//Preview
Local cObjetivo		:= ""				//Objetivo - Utilizado pelo entrevistador
Local cCodResp		:= ""				//Respondente
Local cDataIni		:= ""				//Data de Inicio da Pesquisa
Local cHoraIni		:= ""				//Hora de Inicio da Pesquisa
Local cErro			:= ""				//Mensagem de Erro

Local nI 			:= 0				//Variavel de apoio
Local nJ 			:= 0				//Variavel de apoio
Local nK 			:= 0				//Variavel de apoio
Local nL 			:= 0				//Variavel de apoio
Local nPosAlt 		:= 0				//Posicao da Alternativa dentro do array de respostas
Local nPosResp		:= 0				//Posicao das Questoes Respondidas dentro do array de Questoes Obrigatorias

Local lObrigat		:= .F.				//Questao obrigatoria nao respondida

Local aPesquisa 	:= {}				//Array de apoio para gravacao da Pesquisa

Local oObj								//Objeto WS - WSGPRRESEARCH

WEB EXTENDED INIT cHtml

//здддддддддддддддддддддддддд©
//ЁVerifica integridade do IdЁ
//юдддддддддддддддддддддддддды
If !Empty( HttpPost->cId )
	//здддддддддддддддддддддддддддддддддддддд©
	//ЁVerifica intergridade do parametro cIdЁ
	//юдддддддддддддддддддддддддддддддддддддды
	If fURL2Pesq( HttpPost->cId, @cPesquisa )
		//зддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁExemplo de string contendo os dados da PesquisaЁ
		//Ё000001000001000001000001000001111xxx           Ё
		//Ё1     2     3     4     5     6789             Ё
		//Ё1 - Pesquisa                                   Ё
		//Ё2 - Questionario                               Ё
		//Ё3 - Grupo                                      Ё
		//Ё4 - SubGrupo                                   Ё
		//Ё5 - Questao                                    Ё
		//Ё6 - Tipo                                       Ё
		//Ё7 - Preview                                    Ё
		//Ё8 - Objetivo                                   Ё
		//Ё9 - Chave do Respondente                       Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддды
		cCodPesq		:= SubStr( cPesquisa, 1, 6 )
		cCodQuest		:= SubStr( cPesquisa, 7, 6 )
		cCodGrupo 		:= SubStr( cPesquisa, 13, 6 )
		cCodSubGrupo	:= SubStr( cPesquisa, 19, 6 )
		cCodPerg		:= SubStr( cPesquisa, 25, 6 )
		cTipo			:= SubStr( cPesquisa, 31, 1 )
		cPreview		:= SubStr( cPesquisa, 32, 1 )
		cObjetivo		:= SubStr( cPesquisa, 33, 1 )
		cCodResp		:= SubStr( cPesquisa, 34, ( Len( cPesquisa ) - 33 ) - 15 )
		cDataIni		:= SubStr( Right( cPesquisa, 15 ), 1, 10 )
		cHoraIni		:= SubStr( Right( cPesquisa, 15 ), 11 )

		//здддддддддддддддддддд©
		//ЁQuestoes RespondidasЁ
		//юдддддддддддддддддддды
		HttpSession->PGPRXFUNRESP := {}

		//здддддддддддддддддддддддддддддддддддддд©
		//ЁInicializa o objeto WS - WSGPRRESEARCHЁ
		//юдддддддддддддддддддддддддддддддддддддды
		oObj := WSGPRRESEARCH():New()
		WsChgURL( @oObj, "GPRRESEARCH.APW" )
		
		//здддддддддддддддддддддддддддддддд©
		//ЁParametros do metodo GETRESEARCHЁ
		//юдддддддддддддддддддддддддддддддды
		oObj:cUSERCODE		:= "MSALPHA"
		oObj:cRESEARCHCODE	:= cCodPesq
		
		//cUSERCODE,cRESEARCHCODE,cQUERYADDWHERE
		If oObj:GETRESEARCH()
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁVerificacao da Ativacao, Data de Vigencia Inicial e FinalЁ
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If cPreview == "0"
				If !fChkPesq( oObj:oWSGETRESEARCHRESULT:cSTATUS, oObj:oWSGETRESEARCHRESULT:dINITIALDATE, ;
								oObj:oWSGETRESEARCHRESULT:cINITIALHOUR, oObj:oWSGETRESEARCHRESULT:dFINALDATE, ;
								oObj:oWSGETRESEARCHRESULT:cFINALHOUR, oObj:oWSGETRESEARCHRESULT:cDESCRIPTION, ;
								@cErro )
				
					Return fHtmlAlert( STR0001, cErro ) //"AtenГЦo"
				EndIf
			EndIf
		Else
			Return fHtmlAlert( STR0001, "" ) //"AtenГЦo"
		EndIf

		//здддддддддддддддддддддддддддд©
		//ЁVarre todos os itens do PostЁ
		//юдддддддддддддддддддддддддддды
		For nI := 1 To Len( HttpPost->aPost )
			If SubStr( HttpPost->aPost[nI], 1, 4 ) == "UES_" .OR. 	SubStr( HttpPost->aPost[nI], 1, 4 ) == "UESC" .OR. ;
				SubStr( HttpPost->aPost[nI], 1, 4 ) == "UEL_" .OR. SubStr( HttpPost->aPost[nI], 1, 4 ) == "MES_" .OR. ;
				SubStr( HttpPost->aPost[nI], 1, 4 ) == "MESC" .OR. SubStr( HttpPost->aPost[nI], 1, 4 ) == "MEL_" .OR. ;
				SubStr( HttpPost->aPost[nI], 1, 4 ) == "MEC_" .OR. SubStr( HttpPost->aPost[nI], 1, 4 ) == "D___" .OR. ;
				SubStr( HttpPost->aPost[nI], 1, 4 ) == "UESO" .OR. SubStr( HttpPost->aPost[nI], 1, 4 ) == "UELO" .OR. ;
				SubStr( HttpPost->aPost[nI], 1, 4 ) == "MESO" .OR. SubStr( HttpPost->aPost[nI], 1, 4 ) == "MELO" .OR. ;
				SubStr( HttpPost->aPost[nI], 1, 4 ) == "MECO"
				
				//здддддддддддддддддддддддддддддддддддддд©
				//ЁQuestao em branco nao pode ser gravadaЁ
				//юдддддддддддддддддддддддддддддддддддддды
				If !Empty( &( "HttpPost->" + HttpPost->aPost[nI] ) )
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//ЁParse do nome da Questao para preenchimento do array de respostasЁ
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					fHtmlParser( aPesquisa, HttpPost->aPost[nI], &( "HttpPost->" + HttpPost->aPost[nI] ) )
				EndIf
			EndIf
		Next nI
		
		//здддддддддддддддддддддддддддддддддддддд©
		//ЁParametros do Metodo PUTRESEARCHRESULTЁ
		//юдддддддддддддддддддддддддддддддддддддды
		oObj:cUSERCODE		:= "MSALPHA"
		oObj:oWSRESEARCH	:= GPRRESEARCH_RESEARCHVIEW():New()
		
		//зддддддддддддддддд©
		//ЁArray de PesquisaЁ
		//юддддддддддддддддды
		For nI := 1 To Len( aPesquisa )
			oObj:oWSRESEARCH:cCODE						:= aPesquisa[nI][1]	
			oObj:oWSRESEARCH:oWSRESULT					:= GPRRESEARCH_RESULTVIEW():New()
			oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY 		:= GPRRESEARCH_ARRAYOFQUESTIONARYVIEW():New()
			oObj:oWSRESEARCH:oWSRESULT:cRESEARCHEDKEY	:= cCodResp
			oObj:oWSRESEARCH:oWSRESULT:dINITIALDATE		:= CToD( cDataIni )
			oObj:oWSRESEARCH:oWSRESULT:cINITIALHOUR		:= cHoraIni
		
			//зддддддддддддддддддддддддддд©
			//ЁFinalizacao do QuestionarioЁ
			//юддддддддддддддддддддддддддды
			If HttpPost->cFim == "1"
				oObj:oWSRESEARCH:oWSRESULT:dFINALDATE 	:= Date()
				oObj:oWSRESEARCH:oWSRESULT:cFINALHOUR	:= Substr( Time(), 1, 5 )
			EndIf
			
			//здддддддддддддддддддддд©
			//ЁArray de QuestionariosЁ
			//юдддддддддддддддддддддды
			For nJ := 1 To Len( aPesquisa[nI][2] )
				aAdd( oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW, GPRRESEARCH_QUESTIONARYVIEW():New() )
		
				oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:cCODE				:= aPesquisa[nI][2][nJ][1]
				oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER	:= GPRRESEARCH_ARRAYOFANSWERVIEW():New()
				
				//здддддддддддддддддд©
				//ЁArray de RespostasЁ
				//юдддддддддддддддддды
				For nK := 1 To Len( aPesquisa[nI][2][nJ][2] )
					aAdd( oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW, GPRRESEARCH_ANSWERVIEW():New() )
		
					oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSANSWERHEADER		:= GPRRESEARCH_ANSWERHEADERVIEW():New()
					oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM	:= GPRRESEARCH_ARRAYOFANSWERITEMVIEW():New()
		
					oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSANSWERHEADER:cQUESTIONCODE := aPesquisa[nI][2][nJ][2][nK][3]
					
					//здддддддддддддддддддддддддд©
					//ЁArray de Itens da RespostaЁ
					//юдддддддддддддддддддддддддды
					For nL := 1 To Len( aPesquisa[nI][2][nJ][2][nK][4] )
						Do Case
							//здддддддддддддддддддддддд©
							//ЁUnica Escolha SequencialЁ
							//ЁUnica Escolha em Linhas Ё
							//юдддддддддддддддддддддддды
							Case aPesquisa[nI][2][nJ][2][nK][4][nL][1] == "UES_" .OR. ;
								aPesquisa[nI][2][nJ][2][nK][4][nL][1] == "UEL_"
								
								nPosAlt := aScan( oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW, { |x| x:cALTERNATIVECODE == aPesquisa[nI][2][nJ][2][nK][4][nL][4] } )
								
								If nPosAlt == 0
									aAdd( oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW, GPRRESEARCH_ANSWERITEMVIEW():New() )
		
									nPosAlt := Len( oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW )
								EndIf
		
								//зддддддддддддддддддддддддддддддддддддд©
								//ЁGrava somente o Codigo da AlternativaЁ
								//юддддддддддддддддддддддддддддддддддддды
								oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW[nPosAlt]:cALTERNATIVECODE := aPesquisa[nI][2][nJ][2][nK][4][nL][4]
		
							//зддддддддддддддддддддддддддд©
							//ЁMultipla Escolha SequencialЁ
							//ЁMultipla Escolha em Linhas Ё
							//ЁMultipla Escolha em ColunasЁ
							//юддддддддддддддддддддддддддды
							Case aPesquisa[nI][2][nJ][2][nK][4][nL][1] == "MES_" .OR. ;
								aPesquisa[nI][2][nJ][2][nK][4][nL][1] == "MEL_" .OR. ;
								aPesquisa[nI][2][nJ][2][nK][4][nL][1] == "MEC_"
		
								nPosAlt := aScan( oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW, { |x| x:cALTERNATIVECODE == aPesquisa[nI][2][nJ][2][nK][4][nL][2] } )
								
								If nPosAlt == 0
									aAdd( oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW, GPRRESEARCH_ANSWERITEMVIEW():New() )
		
									nPosAlt := Len( oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW )
								EndIf
		
								//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//ЁGrava o Codigo da Alternativa e a Codigo da Linha ou ColunaЁ
								//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW[nPosAlt]:cALTERNATIVECODE := aPesquisa[nI][2][nJ][2][nK][4][nL][2]
								oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW[nPosAlt]:cCOLUMNCODE := aPesquisa[nI][2][nJ][2][nK][4][nL][3]
		
							//здддддддддддддддддддддддддддддддддддддддддд©
							//ЁComplemento da Unica Escolha Sequencial   Ё
							//ЁComplemento da Multipla Escolha SequencialЁ
							//юдддддддддддддддддддддддддддддддддддддддддды
							Case aPesquisa[nI][2][nJ][2][nK][4][nL][1] == "UESC" .OR. ;
								aPesquisa[nI][2][nJ][2][nK][4][nL][1] == "MESC"
								
								nPosAlt := aScan( oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW, { |x| x:cALTERNATIVECODE == aPesquisa[nI][2][nJ][2][nK][4][nL][2] } )
								
								If nPosAlt == 0
									aAdd( oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW, GPRRESEARCH_ANSWERITEMVIEW():New() )
		
									nPosAlt := Len( oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW )
								EndIf
		
								//зддддддддддддддддддддддддддддддддддддддддддддд©
								//ЁGrava o Codigo da Alternativa e o ComplementoЁ
								//юддддддддддддддддддддддддддддддддддддддддддддды
								oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW[nPosAlt]:cALTERNATIVECODE := aPesquisa[nI][2][nJ][2][nK][4][nL][2]
								oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW[nPosAlt]:cCOMPLEMENT := aPesquisa[nI][2][nJ][2][nK][4][nL][4]
					
							//здддддддддддд©
							//ЁDissertativaЁ
							//юдддддддддддды
							Case aPesquisa[nI][2][nJ][2][nK][4][nL][1] == "D___" .OR. ;
								aPesquisa[nI][2][nJ][2][nK][4][nL][1] == "UESO" .OR. ;
								aPesquisa[nI][2][nJ][2][nK][4][nL][1] == "UELO" .OR. ;
								aPesquisa[nI][2][nJ][2][nK][4][nL][1] == "MESO" .OR. ;
								aPesquisa[nI][2][nJ][2][nK][4][nL][1] == "MECO" .OR. ;
								aPesquisa[nI][2][nJ][2][nK][4][nL][1] == "MELO"

								aAdd( oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW, GPRRESEARCH_ANSWERITEMVIEW():New() )
								
								nPosAlt := Len( oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW )
		
								//зддддддддддддддддддддддддддддддддддддддд©
								//ЁGrava os dados da resposta DissertativaЁ
								//юддддддддддддддддддддддддддддддддддддддды
								oObj:oWSRESEARCH:oWSLISTOFQUESTIONARY:oWSQUESTIONARYVIEW[nJ]:oWSLISTOFANSWER:oWSANSWERVIEW[nK]:oWSLISTOFANSWERITEM:oWSANSWERITEMVIEW[nPosAlt]:cOPENQUESTION := aPesquisa[nI][2][nJ][2][nK][4][nL][4]
					
						EndCase
					Next nL
				Next nK
			Next nJ
		Next nI
		
		//здддддддддддддддддддддддддддддд©
		//ЁArray de Questoes ObrigatoriasЁ
		//юдддддддддддддддддддддддддддддды
		If !Empty( HttpSession->PGPRXFUNOBRIGAT )
			//здддддддддддддддддддддддддддддддд©
			//ЁExistem Questoes nao respondidasЁ
			//юдддддддддддддддддддддддддддддддды
			cErro += STR0004 //"As seguintes questУes nЦo foram respondidas:<br><br>"

			For nI := 1 To Len( HttpSession->PGPRXFUNOBRIGAT )
				nPosResp := aScan( HttpSession->PGPRXFUNRESP, { |x| x == HttpSession->PGPRXFUNOBRIGAT[nI][1] } )
				
				If nPosResp == 0
					cErro += "- " + IIf( Len( AllTrim( HttpSession->PGPRXFUNOBRIGAT[nI][2] ) ) > 60, SubStr( AllTrim( HttpSession->PGPRXFUNOBRIGAT[nI][2] ), 1, 60 ) + "...?", AllTrim( HttpSession->PGPRXFUNOBRIGAT[nI][2] ) ) + "<br>"
					lObrigat := .T.
				EndIf
			Next nI
			
			If lObrigat
				Return fHtmlAlert( STR0001, cErro, "1", ESQUERDA ) //"AtenГЦo"
			EndIf
		EndIf
		
		//cUSERCODE,oWSRESULT
		If oObj:PUTRESEARCHRESULT()
			Return fHtmlAlert( STR0001, STR0005 ) //"AtenГЦo"###"Pesquisa finalizada com SUCESSO!"
		Else
			Return fHtmlAlert( STR0001, "" ) //"AtenГЦo"
		EndIf
	Else
		Return fHtmlAlert( STR0001, STR0002 ) //"AtenГЦo"###"O ID nЦo И vАlido. <br>Favor entrar em contato com os responsАveis tИcnicos da Pesquisa, ou com a Microsiga Software S/A. "
	EndIf
Else
	Return fHtmlAlert( STR0001, STR0003 ) //"AtenГЦo"###"ID nЦo encontrado. <br>Favor entrar em contato com os responsАveis tИcnicos da Pesquisa, ou com a Microsiga Software S/A. "
EndIf

WEB EXTENDED END

Return cHtml