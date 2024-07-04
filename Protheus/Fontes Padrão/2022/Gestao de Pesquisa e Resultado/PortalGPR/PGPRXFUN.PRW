#INCLUDE "PGPRXFUN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTipos de Questaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE UNICA_ESCOLHA 		"1"			//Unica Escolha
#DEFINE MULTIPLA_ESCOLHA 	"2"			//Multipla Escolha
#DEFINE DISSERTATIVA 		"3"			//Dissertativa

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTipos de exibicao da alternativaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE SEQUENCIAL 		"1"			//Sequencial
#DEFINE COLUNAS 			"2"			//Colunas
#DEFINE LINHAS 			"3"			//Linhas

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCampo Tipo Combobox - Utilizado como Logicoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE SIM				"1"			//Sim
#DEFINE NAO				"2"			//Nao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtivacao da Pesquisaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE ATIVA				"1"			//Pesquisa Ativa
#DEFINE INATIVA			"2"			//Pesquisa Inativa

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAlinhamento da Mensagemณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#DEFINE ESQUERDA			"left"		//Alinhamento a esquerda
#DEFINE MEIO				"middle"	//Alinhamento ao meio
#DEFINE DIREITA			"right"		//Alinhamento a direita

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPGPRXFUN  บAutor  ณLuiz Felipe Couto    บ Data ณ  02/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Este fonte possui uma biblioteca utilizada para a exibicao  บฑฑ
ฑฑบ          ณ das perguntas, alternativas e linhas ou colunas da pesquisa บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfHtmlPerg บAutor  ณLuiz Felipe Couto    บ Data ณ  02/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a pergunta no formato HTML.                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpO1 : Objeto WS contendo as perguntas                     บฑฑ
ฑฑบ          ณ ExpO2 : Objeto WS contendo as alternativas                  บฑฑ
ฑฑบ          ณ ExpC3 : Numero da Pergunta                                  บฑฑ
ฑฑบ          ณ ExpN4 : Codigo do Questionario (HTML)                       บฑฑ
ฑฑบ          ณ ExpN5 : Codigo do Grupo (HTML)                              บฑฑ
ฑฑบ          ณ ExpN6 : Codigo do SubGrupo (HTML)                           บฑฑ
ฑฑบ          ณ ExpN7 : Codigo da Pergunta (HTML)                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fHtmlPerg( oObjPerg, oObjAlt, cNumPerg, cCodPesq, cCodQuest, cCodGrupo, cCodSubGrupo, cCodPerg )

Local cHtml 			:= ""				//String HTML
Local cColor 			:= ""				//Cor da Linha
Local cName 			:= ""				//Nome do campo HTML

Local nAlt				:= 0				//Variavel de apoio - Alternativa
Local nOption			:= 0				//Variavel de apoio - Linha ou Coluna
Local nColor 			:= 0				//Variavel de apoio - Cor da Linha
Local nPosComp			:= 0				//Posicao do Complemento

DEFAULT cNumPerg 		:= ""				//Numero da Pergunta
DEFAULT cCodPesq		:= "000000"			//Codigo da Pesquisa
DEFAULT cCodQuest		:= "000000"			//Codigo do Questionario
DEFAULT cCodGrupo		:= "000000"			//Codigo do Grupo
DEFAULT cCodSubGrupo	:= "000000"			//Codigo do SubGrupo
DEFAULT cCodPerg		:= "000000"			//Codigo da Questao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Se a Questao for Obrigatoria, adiciona no array de Questoes Obrigatorias      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If oObjPerg:cOBLIGATION == SIM
	aAdd( HttpSession->PGPRXFUNOBRIGAT, { oObjPerg:cCODE, oObjPerg:cDESCRIPTION } )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณNome do campo HTMLณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cName := cCodPesq + cCodQuest + cCodGrupo + cCodSubGrupo + cCodPerg   
cName := StrTran(cName, " ", "_")

Do Case
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPergunta Unica Escolhaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case oObjPerg:cTYPE == UNICA_ESCOLHA
		cHtml += '<!-- PERGUNTA ฺNICA ESCOLHA -->' + CRLF
	
		Do Case
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPergunta Unica Escolha Sequencialณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Case oObjPerg:cEXHIBITIONTYPE == SEQUENCIAL
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณMontagem da pergunta dinamica (HTML)ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cHtml += '<!-- PERGUNTA ฺNICA ESCOLHA SEQUENCIAL -->' + CRLF
				cHtml += '<tbody>' + CRLF
				cHtml += '  <tr>' + CRLF
				cHtml += '    <td align="left" colSpan="5">' + CRLF
				cHtml += '      <strong>' + cNumPerg + '&nbsp;' + oObjPerg:cDESCRIPTION + '</strong>' + CRLF
				cHtml += '    </td>' + CRLF
				cHtml += '  </tr>' + CRLF
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณObjetivo da Questaoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cHtml += fHtmlObj( HttpSession->PGPR010OBJ, oObjPerg:cOBJECTIVEDESCRIPTION )

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCor da Linha HTMLณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nColor := 0
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณBusca Alternativa que possui Complementoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nPosComp := aScan( oObjAlt, { |x| x:cCOMPLEMENT == SIM } )
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณArray de Alternativasณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				For nAlt := 1 To Len( oObjAlt )
					If nColor == 0
						nColor := 1
						cColor := "#f2f2f2"
					Else
						nColor := 0
						cColor := "#ffffff"
					EndIf

					cHtml += fHtmlAlt( 	oObjAlt[nAlt]:cDESCRIPTION	, UNICA_ESCOLHA				,;
										SEQUENCIAL					, oObjAlt[nAlt]:cCOMPLEMENT	,;
										cName						, cColor					,;
																	, oObjAlt[nAlt]:cCODE		,;
										IIf( nPosComp > 0, oObjAlt[nPosComp]:cCODE, )			,;
										IIf( nPosComp > 0, oObjPerg:nCOMPLEMENTMAXLENGTH, )	 )
				Next nAlt
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณObservacao da Questaoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !Empty( oObjPerg:cNOTE )
					cHtml += fHtmlObs( 	UNICA_ESCOLHA	, SEQUENCIAL		,;
										cName			, oObjPerg:cNOTE	,;
										oObjPerg:nMAXLENGTH )
				EndIf

				cHtml += '</tbody>' + CRLF
				cHtml += '<tr>' + CRLF
				cHtml += '  <td class="TextoGrupo" align="middle" colSpan="5">&nbsp;</td>' + CRLF
				cHtml += '</tr>' + CRLF

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPergunta Unica Escolha em Linhasณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Case oObjPerg:cEXHIBITIONTYPE == LINHAS
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณMontagem da pergunta dinamica (HTML)ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cHtml += '<!-- PERGUNTA ฺNICA ESCOLHA EM LINHAS -->' + CRLF
				cHtml += '<tbody>' + CRLF
				cHtml += '  <tr>' + CRLF
				cHtml += '    <td align="left" colSpan="5">' + CRLF
				cHtml += '      <strong>' + cNumPerg + '&nbsp;' + oObjPerg:cDESCRIPTION + '</strong>' + CRLF
				cHtml += '    </td>' + CRLF
				cHtml += '  </tr>' + CRLF

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณObjetivo da Questaoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cHtml += fHtmlObj( HttpSession->PGPR010OBJ, oObjPerg:cOBJECTIVEDESCRIPTION )

				cHtml += '  <tr bgColor="#f2f2f2">' + CRLF
				cHtml += '    <td align="left" colSpan="5">' + CRLF
				cHtml += '      <select name="UEL_' + cName + '" class="comboselect">' + CRLF

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณArray de Alternativasณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				For nAlt := 1 To Len( oObjAlt )
					cHtml += fHtmlOption( LINHAS, oObjAlt[nAlt]:cCODE, oObjAlt[nAlt]:cDESCRIPTION )
				Next nAlt

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณObservacao da Questaoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !Empty( oObjPerg:cNOTE )
					cHtml += fHtmlObs( UNICA_ESCOLHA, LINHAS, cName, oObjPerg:cNOTE, oObjPerg:nMAXLENGTH )
				EndIf

				cHtml += '      </select>' + CRLF
				cHtml += '    </td>' + CRLF
				cHtml += '  </tr>' + CRLF
				cHtml += '</tbody>' + CRLF
				cHtml += '<tr>' + CRLF
				cHtml += '  <td class="TextoGrupo" align="middle" colSpan="5">&nbsp;</td>' + CRLF
				cHtml += '</tr>' + CRLF
			
		EndCase
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPergunta Multipla Escolhaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case oObjPerg:cTYPE == MULTIPLA_ESCOLHA
		cHtml += '<!-- PERGUNTA MÜLTIPLA ESCOLHA -->' + CRLF
		
		Do Case
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPergunta Multipla Escolha Sequencialณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Case oObjPerg:cEXHIBITIONTYPE == SEQUENCIAL
				cHtml += '<!-- PERGUNTA MฺLTIPLA ESCOLHA SEQUENCIAL -->' + CRLF
				cHtml += '<tbody>' + CRLF
				cHtml += '  <tr>' + CRLF
				cHtml += '    <td align="left" colSpan="5">' + CRLF
				cHtml += '      <strong>' + cNumPerg + '&nbsp;' + oObjPerg:cDESCRIPTION + '</strong>' + CRLF
				cHtml += '    </td>' + CRLF
				cHtml += '  </tr>' + CRLF
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณObjetivo da Questaoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cHtml += fHtmlObj( HttpSession->PGPR010OBJ, oObjPerg:cOBJECTIVEDESCRIPTION )

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCor da Linha HTMLณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nColor := 0

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณBusca Alternativa que possui Complementoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nPosComp := aScan( oObjAlt, { |x| x:cCOMPLEMENT == SIM } )

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณArray de Alternativasณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				For nAlt := 1 To Len( oObjAlt )
					If nColor == 0
						nColor := 1
						cColor := "#f2f2f2"
					Else
						nColor := 0
						cColor := "#ffffff"
					EndIf

					cHtml += fHtmlAlt( 	oObjAlt[nAlt]:cDESCRIPTION	, MULTIPLA_ESCOLHA			,;
										SEQUENCIAL					, oObjAlt[nAlt]:cCOMPLEMENT	,;
										cName + oObjAlt[nAlt]:cCODE, cColor						,;
																	, oObjAlt[nAlt]:cCODE		,;
										IIf( nPosComp > 0, oObjAlt[nPosComp]:cCODE, )			,;
										IIf( nPosComp > 0, oObjPerg:nCOMPLEMENTMAXLENGTH, )		,;
										oObjPerg:nSELECTIONLIMIT )
				Next nAlt

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณObservacao da Questaoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !Empty( oObjPerg:cNOTE )
					cHtml += fHtmlObs( MULTIPLA_ESCOLHA, SEQUENCIAL, cName, oObjPerg:cNOTE, oObjPerg:nMAXLENGTH )
				EndIf

				cHtml += '</tbody>' + CRLF
				cHtml += '<tr>' + CRLF
				cHtml += '  <td class="TextoGrupo" align="middle" colSpan="5">&nbsp;</td>' + CRLF
				cHtml += '</tr>' + CRLF
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPergunta Multipla Escolha em Linhasณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Case oObjPerg:cEXHIBITIONTYPE == LINHAS
				cHtml += '<!-- PERGUNTA MฺLTIPLA ESCOLHA EM LINHAS -->' + CRLF
				cHtml += '<tbody>' + CRLF
				cHtml += '  <tr>' + CRLF
				cHtml += '    <td align="left" colSpan="5">' + CRLF
				cHtml += '      <strong>' + cNumPerg + '&nbsp;' + oObjPerg:cDESCRIPTION + '</strong>' + CRLF
				cHtml += '    </td>' + CRLF
				cHtml += '  </tr>' + CRLF

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณObjetivo da Questaoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cHtml += fHtmlObj( HttpSession->PGPR010OBJ, oObjPerg:cOBJECTIVEDESCRIPTION )

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCor da Linha HTMLณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nColor := 0

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณArray de Alternativasณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				For nAlt := 1 To Len( oObjAlt )
					If nColor == 0
						nColor := 1
						cColor := "#f2f2f2"
					Else
						nColor := 0
						cColor := "#ffffff"
					EndIf

					cHtml += fHtmlAlt( 	oObjAlt[nAlt]:cDESCRIPTION	, MULTIPLA_ESCOLHA	,;
										LINHAS						,					,;
										cName + oObjAlt[nAlt]:cCODE	, cColor			,;
										oObjPerg:oWSLISTOFOPTION:oWSOPTIONVIEW )
				Next nAlt

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณObservacao da Questaoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !Empty( oObjPerg:cNOTE )
					cHtml += fHtmlObs( MULTIPLA_ESCOLHA, LINHAS, cName, oObjPerg:cNOTE, oObjPerg:nMAXLENGTH )
				EndIf

				cHtml += '</tbody>' + CRLF
				cHtml += '<tr>' + CRLF
				cHtml += '  <td class="TextoGrupo" align="middle" colSpan="5">&nbsp;</td>' + CRLF
				cHtml += '</tr>' + CRLF
		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPergunta Multipla Escolha em Colunasณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Case oObjPerg:cEXHIBITIONTYPE == COLUNAS
				cHtml += '<!-- PERGUNTA MฺLTIPLA ESCOLHA EM COLUNAS -->' + CRLF
				cHtml += '<tbody>' + CRLF
				cHtml += '  <tr>' + CRLF
				cHtml += '    <td align="left" colSpan="5">' + CRLF
				cHtml += '      <strong>' + cNumPerg + '&nbsp;' + oObjPerg:cDESCRIPTION + '</strong>' + CRLF
				cHtml += '    </td>' + CRLF
				cHtml += '  </tr>' + CRLF

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณObjetivo da Questaoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cHtml += fHtmlObj( HttpSession->PGPR010OBJ, oObjPerg:cOBJECTIVEDESCRIPTION )

				cHtml += '  <tr>' + CRLF
				cHtml += '    <td align="left" colSpan="5">' + CRLF
				cHtml += '      <table class="texto" cellSpacing="0" cellPadding="2" width="100%" border=0>' + CRLF
				cHtml += '        <!-- COLUNAS -->' + CRLF
				cHtml += '        <tr>' + CRLF
				cHtml += '          <td align="left" width="10%">&nbsp;</td>' + CRLF
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณArray de Linhas ou Colunasณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				For nOption := 1 To Len( oObjPerg:oWSLISTOFOPTION:oWSOPTIONVIEW )
					cHtml += fHtmlOption( 	COLUNAS															,;
											oObjPerg:oWSLISTOFOPTION:oWSOPTIONVIEW[nOption]:cCODE			,;
											oObjPerg:oWSLISTOFOPTION:oWSOPTIONVIEW[nOption]:cDESCRIPTION )
				Next nOption

				cHtml += '        </tr>' + CRLF
				cHtml += '        <!-- LINHAS -->' + CRLF

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCor da Linha HTMLณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nColor := 0

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณArray de Alternativasณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				For nAlt := 1 To Len( oObjAlt )
					If nColor == 0
						nColor := 1
						cColor := "#f2f2f2"
					Else
						nColor := 0
						cColor := "#ffffff"
					EndIf

					cHtml += fHtmlAlt( 	oObjAlt[nAlt]:cDESCRIPTION	, MULTIPLA_ESCOLHA	,;
										COLUNAS						,					,;
										cName + oObjAlt[nAlt]:cCODE	, cColor			,;
										oObjPerg:oWSLISTOFOPTION:oWSOPTIONVIEW )
				Next nAlt

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณObservacao da Questaoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !Empty( oObjPerg:cNOTE )
					cHtml += fHtmlObs( MULTIPLA_ESCOLHA, COLUNAS, cName, oObjPerg:cNOTE, oObjPerg:nMAXLENGTH )
				EndIf

				cHtml += '      </table>' + CRLF
				cHtml += '    </td>' + CRLF
				cHtml += '  </tr>' + CRLF
				cHtml += '</tbody>' + CRLF
				cHtml += '<tr>' + CRLF
				cHtml += '  <td class="TextoGrupo" align="middle" colSpan="5">&nbsp;</td>' + CRLF
				cHtml += '</tr>' + CRLF

		EndCase

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPergunta Dissertativaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case oObjPerg:cTYPE == DISSERTATIVA
		cHtml += '<!-- PERGUNTA DISSERTATIVA -->' + CRLF
		cHtml += '<tbody>' + CRLF
		cHtml += '  <tr>' + CRLF
		cHtml += '    <td align="left" colSpan="5">' + CRLF
		cHtml += '      <strong>' + cNumPerg + '&nbsp;' + oObjPerg:cDESCRIPTION + '</strong>' + CRLF
		cHtml += '    </td>' + CRLF
		cHtml += '  </tr>' + CRLF

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณObjetivo da Questaoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cHtml += fHtmlObj( HttpSession->PGPR010OBJ, oObjPerg:cOBJECTIVEDESCRIPTION )

		cHtml += '  <tr>' + CRLF
		cHtml += '    <td align="left" colSpan="5">' + CRLF
		cHtml += '      <textarea name="D___' + cName + '" rows="4" cols="123" maxlength="' + AllTrim( Str( oObjPerg:nMAXLENGTH ) ) + '" class="comboselect" onKeyUp="fLimCampo( this, document.forms[0].D___COUNTER' + cName + ', this.maxlength )" onKeyDown="fLimCampo( this, document.forms[0].D___COUNTER' + cName + ', this.maxlength )"></textarea><br>' + CRLF
		cHtml += '        <font size="1">' + CRLF
		cHtml += '          <span class="TextoLimite">' + STR0001 + '&nbsp;:&nbsp;</span>' + CRLF //"Limite Caracter"
		cHtml += '          <input name="D___COUNTER' + cName + '" size="3" class="comboselect" value="' + AllTrim( Str( oObjPerg:nMAXLENGTH ) ) + '" disabled>' + CRLF
		cHtml += '        </font>' + CRLF
		cHtml += '    </td>' + CRLF
		cHtml += '  </tr>' + CRLF
		cHtml += '</tbody>' + CRLF
		cHtml += '<tr>' + CRLF
		cHtml += '  <td class="TextoGrupo" align="middle" colSpan="5">&nbsp;</td>' + CRLF
		cHtml += '</tr>' + CRLF

EndCase

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfHtmlAlt  บAutor  ณLuiz Felipe Couto    บ Data ณ  02/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a alternativa no formato HTML.                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 : Descricao da Alternativa                            บฑฑ
ฑฑบ          ณ ExpC2 : Tipo de Pergunta                                    บฑฑ
ฑฑบ          ณ ExpC3 : Tipo de Alternativa                                 บฑฑ
ฑฑบ          ณ ExpC4 : Complemento da Alternativa                          บฑฑ
ฑฑบ          ณ ExpC5 : Nome da alternativa (HTML)                          บฑฑ
ฑฑบ          ณ ExpC6 : Cor da linha da alternativa (HTML)                  บฑฑ
ฑฑบ          ณ ExpC7 : Objeto com as linhas ou colunas da alternativa      บฑฑ
ฑฑบ          ณ ExpC8 : Iterm da Alternativa                                บฑฑ
ฑฑบ          ณ ExpC9 : Alternativa que possui Complemento                  บฑฑ
ฑฑบ          ณ ExpN10: Tamanho Maximo do Campo Complemento                 บฑฑ
ฑฑบ          ณ ExpN11: Numero maximo de selecoes por pergunta              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fHtmlAlt( 	cDescAlt, cTipoPerg	, cTipoAlt		, cCompAlt,;
					cNameAlt, cColor	, oObjOption	, cAltItem,;
					cAltComp, nTamComp	, nNumMaxSel )

Local cHtml 		:= ""					//String HTML

Local nOption		:= 0					//Variavel de apoio - Linhas ou Colunas

DEFAULT cDescAlt	:= ""					//Descricao da Alternativa
DEFAULT cTipoPerg	:= ""					//Tipo de Questao
DEFAULT cTipoAlt	:= ""					//Tipo de Alternativa
DEFAULT cCompAlt	:= ""					//Complemento da Alternativa
DEFAULT cNameAlt	:= ""					//Nome da Alternativa
DEFAULT cColor		:= ""					//Cor
DEFAULT oObjOption	:= {}					//Objeto WS - GPRRESEARCH_OPTIONVIEW
DEFAULT cAltItem	:= ""					//Item da Alternativa
DEFAULT cAltComp	:= ""					//Codigo da Alternativa que possui Complemento
DEFAULT nTamComp	:= 0					//Tamanho maximo do Complemento
DEFAULT nNumMaxSel	:= 0					//Numero maximo de selecoes por pergunta

Do Case
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPergunta Unica Escolhaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case cTipoPerg == UNICA_ESCOLHA
		Do Case
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPergunta Unica Escolha Sequencialณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Case cTipoAlt == SEQUENCIAL
				cHtml += '<tr bgColor="' + cColor + '">' + CRLF
				cHtml += '  <td align="left" colSpan="5">' + CRLF
				cHtml += '    <input type="radio" name="UES_' + cNameAlt + '" value="' + cAltItem + '" ' + 'onClick="' + IIf( !Empty( cAltComp ), fHtmlJSComp( UNICA_ESCOLHA, cNameAlt + cAltComp, cAltComp, cAltItem ), '' ) + '">' + cDescAlt + '&nbsp; ' + CRLF
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณPossui Complementoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If cCompAlt == SIM
					cHtml += '   <input type="text" class="comboselect" value="" name="UESC' + cNameAlt + cAltItem + '" maxlength="' + AllTrim( Str( nTamComp ) ) + '" disabled>' + CRLF
				EndIf
				
				cHtml += '  </td>' + CRLF
				cHtml += '</tr>' + CRLF

		EndCase

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPergunta Multipla Escolhaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case cTipoPerg == MULTIPLA_ESCOLHA
		Do Case
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPergunta Multipla Escolha Sequencialณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Case cTipoAlt == SEQUENCIAL
				cHtml += '<tr bgColor="' + cColor + '">' + CRLF
				cHtml += '  <td align="left" colSpan="5">' + CRLF
				cHtml += '    <input type="checkbox" name="MES_' + cNameAlt + '" value="' + cAltItem + '" onClick="'

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณPossui Complementoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If cCompAlt == SIM
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณJavascript de controle da habilitacao do campo Complementoณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					cHtml += fHtmlJSComp( MULTIPLA_ESCOLHA, cNameAlt, cAltComp, cAltItem, nNumMaxSel ) + '"> ' + cDescAlt + '&nbsp; ' + CRLF
					cHtml += '    <input type="text" class="comboselect" value="" name="MESC' + cNameAlt + '"  maxlength="' + AllTrim( Str( nTamComp ) ) + '" disabled>' + CRLF
				Else
					cHtml += ' fChkMaxSel( this, ' + AllTrim( Str( nNumMaxSel ) ) + ' );"> ' + cDescAlt + '&nbsp; ' + CRLF
				EndIf

				cHtml += '  </td>' + CRLF
				cHtml += '</tr>' + CRLF

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPergunta Multipla Escolha em Linhasณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Case cTipoAlt == LINHAS
				cHtml += '<tr bgColor="' + cColor + '">' + CRLF
				cHtml += '  <td align="left">&nbsp;' + cDescAlt + '</td>' + CRLF
				cHtml += '  <td align="middle" colspan="4">' + CRLF
				cHtml += '    <select name="MEL_' + cNameAlt + '" class="comboselect">' + CRLF
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณArray de Linhas ou Colunasณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				For nOption := 1 To Len( oObjOption )
					cHtml += fHtmlOption( LINHAS, oObjOption[nOption]:cCODE, oObjOption[nOption]:cDESCRIPTION )
				Next nOption

				cHtml += '    </select>' + CRLF
				cHtml += '  </td>' + CRLF
				cHtml += '</tr>' + CRLF

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPergunta Multipla Escolha em Colunasณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Case cTipoAlt == COLUNAS
				cHtml += '<tr bgColor="' + cColor + '">' + CRLF
				cHtml += '  <td align="left" width="10%">' + cDescAlt + '</td>' + CRLF

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณArray de Linhas ou Colunasณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				For nOption := 1 To Len( oObjOption )
					cHtml += '  <td align="middle" width="5%">' + CRLF
					cHtml += '    <input type="radio" name="MEC_' + cNameAlt + '" value="' + oObjOption[nOption]:cCODE + '">' + CRLF
					cHtml += '  </td>' + CRLF
				Next nOption

				cHtml += '</tr>' + CRLF

		EndCase
EndCase

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfHtmlOptioบAutor  ณLuiz Felipe Couto    บ Data ณ  02/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a linha ou coluna da alternativa.                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 : Tipo de Alternativa                                 บฑฑ
ฑฑบ          ณ ExpC2 : Valor da Linha ou Coluna (HTML)                     บฑฑ
ฑฑบ          ณ ExpC3 : Descricao da Linha ou Coluna                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fHtmlOption( cTipoAlt, cValOption, cDescOption )

Local cHtml 		:= ""					//String HTML

DEFAULT cTipoAlt	:= ""					//Tipo da Alternativa
DEFAULT cValOption	:= ""					//Valor da Linha ou Coluna
DEFAULT cDescOption	:= ""					//Descricao da Linha ou Coluna

Do Case
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPergunta em Linhasณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case cTipoAlt == LINHAS
		cHtml += '<option value="' + cValOption + '">' + cDescOption + '</option>' + CRLF

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPergunta em Colunasณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case cTipoAlt == COLUNAS
		cHtml += '<td class="FundoTitulo" align="middle" width="5%"><strong>' + cDescOption + '</strong></td>' + CRLF
EndCase

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfHtmlJSComบAutor  ณLuiz Felipe Couto    บ Data ณ  14/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna os codigos Javscript em formato HTML para habilita- บฑฑ
ฑฑบ          ณ cao do campo de complemento                                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 : Tipo da Questao                                     บฑฑ
ฑฑบ          ณ ExpC2 : Nome da Questao (HTML)                              บฑฑ
ฑฑบ          ณ ExpC3 : Alternativa que Possui Complemento                  บฑฑ
ฑฑบ          ณ ExpC4 : Item da Alternativa                                 บฑฑ
ฑฑบ          ณ ExpN5 : Numero maximo de selecoes                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fHtmlJSComp( cTipoPerg, cNomePerg, cAltComp, cAltItem, nNumMaxSel )

Local cHtml := ""

Do Case
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPergunta Unica Escolhaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case cTipoPerg == UNICA_ESCOLHA
		If cAltComp == cAltItem
			cHtml += "fHabCampo( " + cTipoPerg + ", null, document.forms[0].UESC" + cNomePerg + ", true );"
		Else
			cHtml += "fHabCampo( " + cTipoPerg + ", null, document.forms[0].UESC" + cNomePerg + ", false );"
		EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPergunta Multipla Escolhaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case cTipoPerg == MULTIPLA_ESCOLHA
		cHtml += "fHabCampo( " + cTipoPerg + ", document.forms[0].MES_" + cNomePerg + ", document.forms[0].MESC" + cNomePerg + ", null, " + AllTrim( Str( nNumMaxSel ) ) + " );"

EndCase

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfHtmlTopo บAutor  ณLuiz Felipe Couto    บ Data ณ  07/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o topo das pesquisas em formato HTML.               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fHtmlTopo()

Local cHtml 			:= ""				//String HTML

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem do Topo da Pesquisaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cHtml += '<!-- TOPO PESQUISA -->' + CRLF
cHtml += '<table cellSpacing="0" cellPadding="0" width="70%" align="center" border="0">' + CRLF
cHtml += '  <tr>' + CRLF
cHtml += '    <td vAlign="top" align="middle" width="351">' + CRLF
cHtml += '      <table cellSpacing="0" cellPadding="0" width="681" align="center" border="0">' + CRLF
cHtml += '        <tr>' + CRLF
cHtml += '          <td align=left width="22"><img height="19" src="imagens/Por/tabela_topo-esq.gif" width="22"></td>' + CRLF
cHtml += '          <td width="659" background="imagens/Por/tabela_meio-topo.gif">&nbsp;</td>' + CRLF
cHtml += '          <td width="10"><img height="19" src="imagens/Por/tabela_topo-dir.gif" width="19"></td>' + CRLF
cHtml += '		  </tr>' + CRLF
cHtml += '        <tr>' + CRLF
cHtml += '          <td width="22" background="imagens/Por/tabela_meio-esq.jpg">' + CRLF
cHtml += '		      <img height="15" src="imagens/Por/tabela_meio-esq-1.gif" width="22">' + CRLF
cHtml += '          </td>' + CRLF
cHtml += '          <td class="FundoTabela" align="middle" width="659">' + CRLF
cHtml += '            <table class=texto cellSpacing=0 cellPadding=2 width="100%" border="0">' + CRLF

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfHtmlRod  บAutor  ณLuiz Felipe Couto    บ Data ณ  07/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o rodape das pesquisas em formato HTML.             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 : Preview da Questao                                  บฑฑ
ฑฑบ          ณ         1 - Preview                                         บฑฑ
ฑฑบ          ณ         0 - Pesquisa                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fHtmlRod( cPreview )

Local cHtml 			:= ""				//String HTML

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem da finalizacao da Pesquisaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBotao de finalizao da Pesquisaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cPreview == "0"
	cHtml += '              <tr>' + CRLF
	cHtml += '                <td align="middle" colSpan="5">' + CRLF
	cHtml += '                  <table width="250">' + CRLF
	cHtml += '                    <tr>' + CRLF
	cHtml += '                      <td align="middle" colSpan="5">' + CRLF
	cHtml += '                        <a class="links" onclick="fEnviar()" href="#">Finalizar</a>' + CRLF
	cHtml += '                      </td>' + CRLF
	cHtml += '                    </tr>' + CRLF
	cHtml += '                  </table>' + CRLF
	cHtml += '                </td>' + CRLF
	cHtml += '              </tr>' + CRLF
EndIf

cHtml += '            </table>' + CRLF
cHtml += '          </td>' + CRLF
cHtml += '          <td width="10" background="imagens/Por/tabela_meio-dir.jpg">' + CRLF
cHtml += '            <img height="17" src="imagens/Por/tabela_meio-dir-1.gif" width="19">' + CRLF
cHtml += '          </td>' + CRLF
cHtml += '        </tr>' + CRLF
cHtml += '        <tr>' + CRLF
cHtml += '          <td align="left" width="22"><img height="20" src="imagens/Por/tabela_baixo-esq.gif" width="22"></td>' + CRLF
cHtml += '          <td width="659" background="imagens/Por/tabela_meio-baixo.jpg">&nbsp;</td>' + CRLF
cHtml += '          <td width="10"><img height="20" src="imagens/Por/tabela_baixo-dir.gif" width="19"></td>' + CRLF
cHtml += '        </tr>' + CRLF
cHtml += '      </table>' + CRLF
cHtml += '    </td>' + CRLF
cHtml += '  </tr>' + CRLF
cHtml += '  <tr>' + CRLF
cHtml += '    <td colSpan="5">&nbsp;</td>' + CRLF
cHtml += '  </tr>' + CRLF
cHtml += '</table>' + CRLF

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfHtmlObj  บAutor  ณLuiz Felipe Couto    บ Data ณ  07/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o objetivo da questao em formato HTML.              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 : Objetivo da questao                                 บฑฑ
ฑฑบ          ณ         1 - Mostra                                          บฑฑ
ฑฑบ          ณ         0 - Nao mostra                                      บฑฑ
ฑฑบ          ณ ExpC2 : Descricao do objetivo                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fHtmlObj( cObjetivo, cDescObj )

Local cHtml 			:= ""				//String HTML

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObjetivo da Questaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cObjetivo == "1"
	If !Empty( cDescObj )
		cHtml += '  <tr>' + CRLF
		cHtml += '    <td align="left" colSpan="5">' + CRLF
		cHtml += '      <font class="TextoObjetivo"><i>' + cDescObj + '</i></font>' + CRLF
		cHtml += '    </td>' + CRLF
		cHtml += '  </tr>' + CRLF
	EndIf
EndIf

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfHtmlObs  บAutor  ณLuiz Felipe Couto    บ Data ณ  16/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a observacao da questao em formato HTML.            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 : Tipo de Questao                                     บฑฑ
ฑฑบ          ณ ExpC2 : Tipo de Alternativa                                 บฑฑ
ฑฑบ          ณ ExpC3 : Nome do Campo (HTML)                                บฑฑ
ฑฑบ          ณ ExpC4 : Descricao da Observacao (HTML)                      บฑฑ
ฑฑบ          ณ ExpC5 : Tamanho maximo do Campo                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fHtmlObs( cTipoPerg, cTipoAlt, cNameObs, cDescObs, nTamObs )

Local cHtml 			:= ""				//String HTML

cHtml += '<tbody>' + CRLF
cHtml += '  <tr>' + CRLF
cHtml += '    <td align="left" colSpan="5">' + CRLF
cHtml += '      <strong>&nbsp;' + AllTrim( cDescObs ) + ':</strong>' + CRLF
cHtml += '    </td>' + CRLF
cHtml += '  </tr>' + CRLF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObservacao da Questaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPergunta Tipo Unica Escolhaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case cTipoPerg == UNICA_ESCOLHA
		Do Case
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAlternativa Tipo Sequencialณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Case cTipoAlt == SEQUENCIAL
				cHtml += '  <tr>' + CRLF
				cHtml += '    <td align="left" colSpan="5">' + CRLF
				cHtml += '      <textarea name="UESO' + cNameObs + '" rows="4" cols="123" maxlength="' + AllTrim( Str( nTamObs ) ) + '" class="comboselect" onKeyUp="fLimCampo( this, document.forms[0].UESOCOUNTER' + cNameObs + ', this.maxlength )" onKeyDown="fLimCampo( this, document.forms[0].UESOCOUNTER' + cNameObs + ', this.maxlength )"></textarea><br>' + CRLF
				cHtml += '        <font size="1">' + CRLF
				cHtml += '          <span class="TextoLimite">' + STR0001 + '&nbsp;:&nbsp;</span>' + CRLF //"Limite Caracter"
				cHtml += '          <input name="UESOCOUNTER' + cNameObs + '" size="3" class="comboselect" value="' + AllTrim( Str( nTamObs ) ) + '" disabled>' + CRLF
				cHtml += '        </font>' + CRLF
				cHtml += '    </td>' + CRLF
				cHtml += '  </tr>' + CRLF
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAlternativa Tipo Linhaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Case cTipoAlt == LINHAS
				cHtml += '  <tr>' + CRLF
				cHtml += '    <td align="left" colSpan="5">' + CRLF
				cHtml += '      <textarea name="UELO' + cNameObs + '" rows="4" cols="123" maxlength="' + AllTrim( Str( nTamObs ) ) + '" class="comboselect" onKeyUp="fLimCampo( this, document.forms[0].UELOCOUNTER' + cNameObs + ', this.maxlength )" onKeyDown="fLimCampo( this, document.forms[0].UELOCOUNTER' + cNameObs + ', this.maxlength )"></textarea><br>' + CRLF
				cHtml += '        <font size="1">' + CRLF
				cHtml += '          <span class="TextoLimite">' + STR0001 + '&nbsp;:&nbsp;</span>' + CRLF //"Limite Caracter"
				cHtml += '          <input name="UELOCOUNTER' + cNameObs + '" size="3" class="comboselect" value="' + AllTrim( Str( nTamObs ) ) + '" disabled>' + CRLF
				cHtml += '        </font>' + CRLF
				cHtml += '    </td>' + CRLF
				cHtml += '  </tr>' + CRLF
		EndCase

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPergunta Tipo Multipla Escolhaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case cTipoPerg == MULTIPLA_ESCOLHA
		Do Case
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAlternativa Tipo Sequencialณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Case cTipoAlt == SEQUENCIAL
				cHtml += '  <tr>' + CRLF
				cHtml += '    <td align="left" colSpan="5">' + CRLF
				cHtml += '      <textarea name="MESO' + cNameObs + '" rows="4" cols="123" maxlength="' + AllTrim( Str( nTamObs ) ) + '" class="comboselect" onKeyUp="fLimCampo( this, document.forms[0].MESOCOUNTER' + cNameObs + ', this.maxlength )" onKeyDown="fLimCampo( this, document.forms[0].MESOCOUNTER' + cNameObs + ', this.maxlength )"></textarea><br>' + CRLF
				cHtml += '        <font size="1">' + CRLF
				cHtml += '          <span class="TextoLimite">' + STR0001 + '&nbsp;:&nbsp;</span>' + CRLF //"Limite Caracter"
				cHtml += '          <input name="MESOCOUNTER' + cNameObs + '" size="3" class="comboselect" value="' + AllTrim( Str( nTamObs ) ) + '" disabled>' + CRLF
				cHtml += '        </font>' + CRLF
				cHtml += '    </td>' + CRLF
				cHtml += '  </tr>' + CRLF
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAlternativa Tipo Colunaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Case cTipoAlt == COLUNAS
				cHtml += '  <tr>' + CRLF
				cHtml += '    <td align="left" colSpan="5">' + CRLF
				cHtml += '      <textarea name="MECO' + cNameObs + '" rows="4" cols="123" maxlength="' + AllTrim( Str( nTamObs ) ) + '" class="comboselect" onKeyUp="fLimCampo( this, document.forms[0].MECOCOUNTER' + cNameObs + ', this.maxlength )" onKeyDown="fLimCampo( this, document.forms[0].MECOCOUNTER' + cNameObs + ', this.maxlength )"></textarea><br>' + CRLF
				cHtml += '        <font size="1">' + CRLF
				cHtml += '          <span class="TextoLimite">' + STR0001 + '&nbsp;:&nbsp;</span>' + CRLF //"Limite Caracter"
				cHtml += '          <input name="MECOCOUNTER' + cNameObs + '" size="3" class="comboselect" value="' + AllTrim( Str( nTamObs ) ) + '" disabled>' + CRLF
				cHtml += '        </font>' + CRLF
				cHtml += '    </td>' + CRLF
				cHtml += '  </tr>' + CRLF
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAlternativa Tipo Linhaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Case cTipoAlt == LINHAS
				cHtml += '  <tr>' + CRLF
				cHtml += '    <td align="left" colSpan="5">' + CRLF
				cHtml += '      <textarea name="MELO' + cNameObs + '" rows="4" cols="123" maxlength="' + AllTrim( Str( nTamObs ) ) + '" class="comboselect" onKeyUp="fLimCampo( this, document.forms[0].MELOCOUNTER' + cNameObs + ', this.maxlength )" onKeyDown="fLimCampo( this, document.forms[0].MELOCOUNTER' + cNameObs + ', this.maxlength )"></textarea><br>' + CRLF
				cHtml += '        <font size="1">' + CRLF
				cHtml += '          <span class="TextoLimite">' + STR0001 + '&nbsp;:&nbsp;</span>' + CRLF //"Limite Caracter"
				cHtml += '          <input name="MELOCOUNTER' + cNameObs + '" size="3" class="comboselect" value="' + AllTrim( Str( nTamObs ) ) + '" disabled>' + CRLF
				cHtml += '        </font>' + CRLF
				cHtml += '    </td>' + CRLF
				cHtml += '  </tr>' + CRLF
		EndCase
EndCase

cHtml += "</tbody>"

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfHtmlParseบAutor  ณLuiz Felipe Couto    บ Data ณ  14/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Parse para o nome da questao da Pesquisa.                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpA1 : Array com as perguntas da Pesquisa                  บฑฑ
ฑฑบ          ณ ExpC2 : Nome da Questao                                     บฑฑ
ฑฑบ          ณ ExpC3 : Valor da Questao                                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fHtmlParser( aPesquisa, cNamePerg, cValPerg )

Local cHtml 	:= ""					//String HTML

Local nI 		:= 0					//Variavel de apoio
Local nPos		:= 1					//Variavel de apoio - Layout
Local nPosPesq	:= 0					//Variavel de apoio - Posicao da Pesquisa
Local nPosQuest	:= 0					//Variavel de apoio - Posicao do Questionario
Local nPosPerg 	:= 0					//Variavel de apoio - Posicao da Questao
Local nLenAlt	:= 0					//Tamanho do Array de Alternativas

Local aResult 	:= {}					//Layout de apoio para preenchimento dos dados da Pesquisa

aAdd( aResult, { "TIPO QUESTAO", 	4, "X", "" } )
aAdd( aResult, { "PESQUISA", 		6, "X", "" } )
aAdd( aResult, { "QUESTIONARIO", 	6, "X", "" } )
aAdd( aResult, { "GRUPO", 			6, "X", "" } )
aAdd( aResult, { "SUBGRUPO", 		6, "X", "" } )
aAdd( aResult, { "QUESTAO", 		6, "X", "" } )
aAdd( aResult, { "ALTERNATIVA", 	2, "X", "" } )
aAdd( aResult, { "LINHA / COLUNA", 	2, "X", "" } )
aAdd( aResult, { "VALOR", 			2, "X", "" } )

aEval( aResult, { |x| x[4] := Substr( cNamePerg, nPos, x[2] ), nPos += x[2] } )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArray de Pesquisa                    ณ
//ณ[1] - Pesquisa                       ณ
//ณ[2]                                  ณ
//ณ  [2][1] - Questionario              ณ
//ณ  [2][2]                             ณ
//ณ    [2][2][1] - Grupo                ณ
//ณ    [2][2][2] - SubGrupo             ณ
//ณ    [2][2][3] - Questao              ณ
//ณ    [2][2][4]                        ณ
//ณ      [2][2][4][1] - Tipo da Questao ณ
//ณ      [2][2][4][2] - Alternativa     ณ
//ณ      [2][2][4][3] - Linha ou Coluna ณ
//ณ      [2][2][4][4] - Valor da Questaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDados da Pesquisaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPosPesq := aScan( aPesquisa, { |x| x[1] == aResult[2][4] } )

If nPosPesq == 0
	aAdd( aPesquisa, {} )

	nPosPesq := Len( aPesquisa )
	
	aAdd( aPesquisa[nPosPesq], aResult[2][4] )
	aAdd( aPesquisa[nPosPesq], {} )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDados do Questionarioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPosQuest := aScan( aPesquisa[nPosPesq][2], { |x| x[1] == aResult[3][4] } )

If nPosQuest == 0
	aAdd( aPesquisa[nPosPesq][2], {} )

	nPosQuest := Len( aPesquisa[nPosPesq][2] )

	aAdd( aPesquisa[nPosPesq][2][nPosQuest], aResult[3][4] )
	aAdd( aPesquisa[nPosPesq][2][nPosQuest], {} )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDados da Questaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPosPerg := aScan( aPesquisa[nPosPesq][2][nPosQuest][2], { |x| x[3] == aResult[6][4] } )

If nPosPerg == 0
	aAdd( HttpSession->PGPRXFUNRESP, aResult[6][4] )
	
	aAdd( aPesquisa[nPosPesq][2][nPosQuest][2], {} )
	
	nPosPerg := Len( aPesquisa[nPosPesq][2][nPosQuest][2] )

	aAdd( aPesquisa[nPosPesq][2][nPosQuest][2][nPosPerg], aResult[4][4] )
	aAdd( aPesquisa[nPosPesq][2][nPosQuest][2][nPosPerg], aResult[5][4] )
	aAdd( aPesquisa[nPosPesq][2][nPosQuest][2][nPosPerg], aResult[6][4] )
	aAdd( aPesquisa[nPosPesq][2][nPosQuest][2][nPosPerg], {} )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDados da Alternativaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd( aPesquisa[nPosPesq][2][nPosQuest][2][nPosPerg][4], {} )
nLenAlt := Len( aPesquisa[nPosPesq][2][nPosQuest][2][nPosPerg][4] )

aAdd( aPesquisa[nPosPesq][2][nPosQuest][2][nPosPerg][4][nLenAlt], aResult[1][4] )
aAdd( aPesquisa[nPosPesq][2][nPosQuest][2][nPosPerg][4][nLenAlt], aResult[7][4] )
aAdd( aPesquisa[nPosPesq][2][nPosQuest][2][nPosPerg][4][nLenAlt], aResult[8][4] )
aAdd( aPesquisa[nPosPesq][2][nPosQuest][2][nPosPerg][4][nLenAlt], aResult[9][4] )

If !Empty( cValPerg )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPergunta Tipo Multipla Escolha em Linhas ou Colunasณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If aResult[1][4] == "MEL_" .OR. ;
		aResult[1][4] == "MEC_"
		
		aPesquisa[nPosPesq][2][nPosQuest][2][nPosPerg][4][nLenAlt][3] := cValPerg
	Else
		aPesquisa[nPosPesq][2][nPosQuest][2][nPosPerg][4][nLenAlt][4] := cValPerg
	EndIf
EndIf

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfPesq2URL บAutor  ณLuiz Felipe Couto    บ Data ณ  16/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Encripta os dados da pesquisa.                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 : String contendo os dados da Pesquisa                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fPesq2URL( cPesquisa )

Local cPesqEnc		:= ""			//Dados da Pesquisa Encriptado
Local cPesqCRCEnc	:= ""			//CRC da Pesquisa Encriptado
Local cIdURL		:= ""			//Id da URL Encriptado

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEncripta os dados da Pesquisa e tranforma para base64ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cPesqEnc 		:= Encode64( WebEncript( cPesquisa ) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTransforma o CRC da Pesquisa para Hexadecimalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cPesqCRCHexa	:= NToC( fGenCRC( cPesqEnc ), 16, 9 )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEncripta o CRC da Pesquisa e tranforma para base64ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cPesqCRCEnc		:= Encode64( WebEncript( cPesqCRCHexa ) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta o ID da URL como sendo a encriptacao da Pesquisa|
//ณmais a encriptacao do CRC da Pesquisa                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cIdURL 			:= cPesqEnc + cPesqCRCEnc

Return cIdURL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGenCRC   บAutor  ณLuiz Felipe Couto    บ Data ณ  16/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera o CRC (Cyclic Redundancy Check - checksum) de uma      บฑฑ
ฑฑบ          ณ sequencia passada como parametro                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 : Sequencia a ser gerada o CRC                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fGenCRC( cSeq )

Local nRet := 0						//CheckSum
Local nTam := 0						//Tamanho da Sequencia

nTam := Len( cSeq )

While nTam > 0
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณArmazena no nRet o ASC de cada bit da sequencia mais oณ
	//ณtamanho da sequencia, da direira para a esquerda      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nRet += Asc( Substr( cSeq, nTam, 1 ) )
	nRet += nTam
	nTam--
EndDo

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfURL2Pesq บAutor  ณLuiz Felipe Couto    บ Data ณ  16/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tranforma o ID da Url para os dados originais da Pesquisa.  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 : Id da URL                                           บฑฑ
ฑฑบ          ณ ExpC2 : Dados originas da Pesquisa passado como Referencia  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fURL2Pesq( cIdURL, cPesquisa )

Local cPesqEnc		:= ""				//Dados da Pesquisa Encriptado
Local cPesqCRCEnc	:= ""				//CRC da Pesquisa Encriptado
Local cPesqDec		:= ""				//Dados da Pesquisa Decriptado
Local cPesqCRCHexa	:= ""				//CRC da Pesquisa em Hexadecimal

Local nTam 			:= 0				//Tamanho do ID da URL

Local lRetorno		:= .T.				//Retorno da Funcao

nTam 				:= Len( cIdURL )

If nTam < 56
	Return .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOs dados da Pesquisa Encriptado sao os caracteres  ณ
//ณa esquerda do ID da URL ate os utimos 12 caracteresณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cPesqEnc			:= Left( cIdURL, nTam - 12 )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณO CRC da Pesquisa sao os 12 caracteres a direita do ID da URLณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cPesqCRCEnc			:= Right( cIdURL, 12 )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDecriptacao dos dados da Pesquisaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cPesqDec			:= WebEncript( Decode64( cPesqEnc ), .T. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCRC Decriptado em Hexadecimalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cPesqCRCHexa		:= WebEncript( Decode64( cPesqCRCEnc ), .T. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica Integridade do ID da URLณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !( cPesqCRCHexa == NToC( fGenCRC( cPesqEnc ), 16, 9 ) )
	Return .F.
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOs dados da Pesquisa sao os dados da pesquisa Decriptados do ID da URLณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cPesquisa := cPesqDec

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGetWSErroบAutor  ณLuiz Felipe Couto    บ Data ณ  16/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de recuperacao de erro de execucao de WebService     บฑฑ
ฑฑบ          ณ Client. Verifica se foi um soap fault, e se for, retorna a  บฑฑ
ฑฑบ          ณ msg original. Caso contrario e um erro interno. Retorna msg บฑฑ
ฑฑบ          ณ default ao usuแrio.                                         บฑฑ
ฑฑบ          ณ ('ERRO INTERNO DE EXECUวรO - WEBSERVICES CLIENT')           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fGetWSError()

Local cMsgError := ""				//Erro do WebService

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArmazena Erro Interno do Servidorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMsgError := GetWscError( 3 )

If Empty( cMsgError )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณArmazena erro do Clientณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cMsgError := GetWscError( 1 )
Endif

Return cMsgError

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGetWSErroบAutor  ณLuiz Felipe Couto    บ Data ณ  16/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa a Tela de Erro com uma mensagem passada como        บฑฑ
ฑฑบ          ณ parametro ou com o erro do WS Client.                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 : Mensagem do Topo da Tela de Erro                    บฑฑ
ฑฑบ          ณ ExpC2 : Mensagem de Erro ou Informacao                      บฑฑ
ฑฑบ          ณ ExpC3 : Pagina de Volta (HTML)                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fHtmlAlert( cTopo, cMsg, cPagVolta, cAlign )

Local cHtml 		:= ""				//Pagina WEB
Local cMsgError 	:= ""				//Erro do WebService Client

DEFAULT cPagVolta 	:= ""				//Pagina de volta (HTML)
DEFAULT cAlign		:= MEIO				//Alinhamento da mensagem

WEB EXTENDED INIT cHtml

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArmazena erro do WS Clientณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMsgError := fGetWSError()

If Empty( HttpSession->_HTMLERRO )
	HttpSession->_HTMLERRO := { NIL, NIL, NIL, NIL }
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe for erro de WS Client mostra o soap fault, caso  ณ
//ณcontrario mostra uma mensagem passada como parametroณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty( cMsgError )
	cMsg := cMsgError
EndIf

HttpSession->_HTMLERRO[1] := cTopo
HttpSession->_HTMLERRO[2] := cMsg
HttpSession->_HTMLERRO[3] := cPagVolta
HttpSession->_HTMLERRO[4] := cAlign

cHtml += ExecInPage( "PGPRALERT" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfChkPesq  บAutor  ณLuiz Felipe Couto    บ Data ณ  16/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica Atiavacao, Data de Vigencia Inicial e Final.       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 : Status da Pesquisa                                  บฑฑ
ฑฑบ          ณ ExpD2 : Data Inicial da Pesquisa                            บฑฑ
ฑฑบ          ณ ExpC3 : Hora Inicial da Pesquisa                            บฑฑ
ฑฑบ          ณ ExpD4 : Data Final da Pesquisa                              บฑฑ
ฑฑบ          ณ ExpC5 : Hora Final da Pesquisa                              บฑฑ
ฑฑบ          ณ ExpC6 : Descricao da Pesquisa                               บฑฑ
ฑฑบ          ณ ExpC7 : Descricao do Erro                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fChkPesq( cStatus, dDataIni, cHoraIni, dDataFinal, cHoraFinal, cDescPesq, cErro )

Local lRetorno := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtivacao da Pesquisaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cStatus == INATIVA
	lRetorno := .F.
EndIf

If !lRetorno
	cErro := STR0002 + cDescPesq + STR0003 //'A Pesquisa "<i>'###'</i>" nใo estแ disponํvel no momento.'
	
	Return lRetorno
EndIf

Do Case
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณData de Vigencia Inicialณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case dDataIni > Date()
		lRetorno := .F.

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณData Incial igual a Data Atualณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case dDataIni == Date()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณHora de Vigencia Inicialณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If cHoraIni > SubStr( Time(), 1, 5 )
			lRetorno := .F.
		EndIf

EndCase

If !lRetorno
	cErro := STR0002 + cDescPesq + STR0004 + DToC( dDataIni ) + STR0005 + cHoraIni + STR0006 //'A Pesquisa "<i>'###'</i>" estarแ disponํvel dia '###' เs '###'h.'
	
	Return lRetorno
EndIf

Do Case
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณData de Vigencia Finalณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case dDataFinal < Date()
		lRetorno := .F.

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณData Incial igual a Data Atualณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case dDataIni == Date()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณHora de Vigencia Finalณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If cHoraFinal < SubStr( Time(), 1, 5 )
			lRetorno := .F.
		EndIf

EndCase

If !lRetorno
	cErro := STR0002 + cDescPesq + STR0007 + DToC( dDataFinal ) + STR0005 + cHoraFinal + STR0006 //'A Pesquisa "<i>'###'</i>" foi encerrada em '###' เs '###'h.'
	
	Return lRetorno
EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSigaGPRStaบAutor  ณLuiz Felipe Couto    บ Data ณ  08/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de Inicializa็ใo adicional de Ambiente WEB ( START ) บฑฑ
ฑฑบ          ณ da Working Thread. Executada no momento do START da Working บฑฑ
ฑฑบ          ณ Thread                                                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SigaGPRStart()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSigaGPRConบAutor  ณLuiz Felipe Couto    บ Data ณ  08/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo executada antes do processamento de qualquer         บฑฑ
ฑฑบDesc.     ณ link .apw                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SigaGPRConnect( cFnMain )
	
HeadNoCache()

Return ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHeadNoCachบAutor  ณLuiz Felipe Couto    บ Data ณ  08/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para a nao armazenagem de CACHE.                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function HeadNoCache()
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
//ณHeader HTTPณ
//ภฤฤฤฤฤฤฤฤฤฤฤู
HttpHeadOut->Expires 		:= 'Mon, 26 Jul 1997 05:00:00 GMT '
HttpHeadOut->Last_Modified 	:= TransData()
HttpHeadOut->Cache_Control 	:= 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0;'
HttpHeadOut->pragma 		:= 'no-cache'

Return ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTransData บAutor  ณLuiz Felipe Couto    บ Data ณ  08/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para a construcao da data para armazenar no CACHE.   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPR     						                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TransData()

Local cData 	:= DToC( Date() )
Local cHora 	:= AllTrim( Str( Val( Substr( Time(), 1, 2 ) ) - 3 ) ) + ":" + Substr( Time(), 4, 2 ) + ":" + Substr( Time(), 7, 2 )
Local nDiaSem 	:= Dow( CToD( cData ) )
Local cDiaSem 	:= ""

Local cDia 		:= Substr( cData, 1, 2 )
Local cMes 		:= Substr( cData, 4, 2 )
Local cAno 		:= Substr( cData, 7, 4 )

Do Case
	Case cMes == "01"
		cMes := "Jan"
	Case cMes == "02"
		cMes := "Feb"
	Case cMes == "03"
		cMes := "Mar"
	Case cMes == "04"
		cMes := "Apr"
	Case cMes == "05"
		cMes := "May"
	Case cMes == "06"
		cMes := "Jun"
	Case cMes == "07"
		cMes := "Jul"
	Case cMes == "08"
		cMes := "Aug"
	Case cMes == "09"
		cMes := "Sep"
	Case cMes == "10"
		cMes := "Oct"
	Case cMes == "11"
		cMes := "Nov"
	Case cMes == "12"
		cMes := "Dec"
EndCase

Do Case
	Case nDiaSem == 1
		cDiaSem := "Sun"
	Case nDiaSem == 2
		cDiaSem := "Mon"
	Case nDiaSem == 3
		cDiaSem := "Tue"
	Case nDiaSem == 4
		cDiaSem := "Wed"
	Case nDiaSem == 5
		cDiaSem := "Thu"
	Case nDiaSem == 6
		cDiaSem := "Fri"
	Case nDiaSem == 7
		cDiaSem := "Sat"
EndCase		

cData := cDiaSem + ", " + cDia + " " + cMes + " " + cAno + " " + cHora + " GMT"

Return cData