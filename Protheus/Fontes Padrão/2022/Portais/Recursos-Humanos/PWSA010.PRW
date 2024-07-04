#INCLUDE "PWSA010PRW.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "AP5MAIL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSA010   บAutor 	ณEquipe RH           			?Data ? 21/06/05   บฑ?
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ?Manutencao das Avaliacao atraves do Portal do APD         			 บฑ?
ฑฑ?         ?                                                  		             บฑ?
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametros?                                     			                     บฑ?
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal APD                                        			         บฑ?
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ?Data   ?FNC  		   ? Motivo da Alteracao                        บฑ?
ฑฑฬออออออออออุออออออออัออออออออออออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบMauricioMR?5/06/09?0000013557/2009ณRecuperacao das Alternativas escolhidas ou daบฑ?
ฑฑ?         ?       ?			   ณresposta dissertativa informada pelo usuario.บฑ?
ฑฑ?         ?       ?               ?                                            บฑ?
ฑฑบMauricioMR?5/09/09?0000020740/2009ณEnvio de email para o subordinado somente no บฑ?
ฑฑ?         ?       ?			   ณcaso de avaliacao de consenso.				 บฑ?
ฑฑ?         ?       ?               ?                                            บฑ?
ฑฑบAllyson M.?3/12/09?0000027122/2009ณAjuste para receber o valor do parametro     บฑ?
ฑฑ?         ?       ?			   ณMV_APDINCB em PWSA012A().					 บฑ?
ฑฑ?         ?       ?               ?                                            บฑ?
ฑฑบAllyson M.?5/02/10?0000000460/2010ณAjuste para receber o valor do parametro     บฑ?
ฑฑ?         ?       ?			   ณMV_APDINCB em PWSA015A().					 บฑ?
ฑฑ?         ?       ?               ?                                            บฑ?
ฑฑบAllyson M.?9/09/10?0000022212/2010ณAjuste para ordenar as avaliacoes conforme   บฑ?
ฑฑ?         ?       ?			   ณprojeto+descricao+nome avaliado.	 		 บฑ?
ฑฑ?         ?       ?               ?                                            บฑ?
ฑฑบAllyson M.?0/07/11?0000017809/2011ณTransferencia da funcionalidade de envio ao  บฑ?
ฑฑ?         ?       ?			   ณfinalizar consenso p/ rotina WSAPD010.		 บฑ?
ฑฑบLeandro Dr?1/11/11?0000030134/2011ณAjuste para considerar o parametro MV_APDINCBบฑ?
ฑฑ?         ?       ?			   ณna impressao da auto-avaliacao.       		 บฑ?
ฑฑศออออออออออฯออออออออฯออออออออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

#DEFINE CODUSUARIO "MSALPHA"

/*******************************************************************/
/* Autor...: Aline Correa do Vale              Data: Julho de 2004 */
/* Objetivo: Browse de Avaliacoes Pendentes - Portal RH            */
/*******************************************************************/
Web Function PWSA010()
	Local cHtml := ""
	Local nX	:= 0
	Local oObj
	Local oParam
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
		WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")
		oParam := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oParam,"CFGDICTIONARY.APW")
				
		If oParam:GETPARAM( CODUSUARIO, "MV_APDRLV" )
			HttpSession->cCpoRelev := AllTrim( oParam:cGETPARAMRESULT )
		EndIf
		
		//Verifica se Busca Descricao da Rede
		If oParam:GETPARAM( CODUSUARIO, "MV_APDREDE" )
			HttpSession->lDescRede := oParam:cGETPARAMRESULT
		EndIf     
		
		//Verifica os campos que serao apresentados no cabe็alho da avalia็ใo
		HttpSession->cCposCabec := ""
		If oParam:GETPARAM( CODUSUARIO, "MV_CPOSCAB" )
			If !Empty(oParam:cGETPARAMRESULT)  .AND. oParam:cGETPARAMRESULT != ".F."
				HttpSession->cCposCabec := oParam:cGETPARAMRESULT
			EndIf
		EndIf                                      
		//Se nใo existir o parโmetro ou nใo foi informado nenhum campo, 
		// assumir todos os campos para apresenta็ใo
		If Empty(HttpSession->cCposCabec)
			HttpSession->cCposCabec := "123456789A"
		EndIf
		
		/********************************************************************
		NIVEIS DOS AVALIADORES
		 - SEXTO PARAMETRO DO METODO BRWMYEVALUATED
		 METODO USADO PARA VERIFICAR AVALIACOES DE SUBORDINADOS, PARCEIROS
		 E SUPERIORES DO PARTICIPANTE LOGADO
		----------------------------------------------------------------------
		 1 = AVALIADOR ESTA NO MESMO NIVEL DO AVALIADO
		 2 = AVALIADOR ESTA EM NIVEL ACIMA DO AVALIADO
		 3 = AVALIADOR ESTA EM NIVEL ABAIXO DO AVALIADO
		**********************************************************************/
		
		HttpSession->aSuperior := {}
		HttpSession->BRWMYEVALUATES := {}
		HttpSession->BRWMYEVALUATED := {}
		HttpSession->aPares := {}
		HttpSession->GETPEVALUATE := NIL
		HttpSession->GETPEVALUATE := {}
		//HttpSession->cTipoAv:= "1"
		
		//SE STATUS = 1 - ALTERACAO
		//SE STATUS = 2 - CONSULTA FINALIZADOS
		If !Empty(HttpGet->cStatus)
			HttpSession->cStatus := HttpGet->cStatus
		EndIf
		
		If !Empty(HttpGet->cTpAval)
			HttpSession->cTpAval := HttpGet->cTpAval
		EndIf

		If !Empty( HttpSession->cParticipantID )
			//CONSULTA SE EXISTEM AVALIACOES DE SUBORDINADOS PARA O PARTICIPANTE LOGADO
			oObj:cStatusEvaluate := HttpSession->cStatus
			oObj:cNetLevel := "2"
		
			If oObj:BRWMYEVALUATED( CODUSUARIO, HttpSession->cParticipantID, HttpSession->cTpAval )
				HttpSession->BRWMYEVALUATED := {oObj:oWSBRWMYEVALUATEDRESULT:oWSEVALUATELIST}
		
				//Separa itens por rede
				cRede := "X"
				HttpSession->aNewSubor := {}
				Asort( HttpSession->BRWMYEVALUATED[1],,,{ |x,y| x:cNet+x:cDescription+x:cEvaluatedName < y:cNet+y:cDescription+y:cEvaluatedName } )
		
				For nX := 1 To Len(HttpSession->BRWMYEVALUATED[1])
					If cRede != HttpSession->BRWMYEVALUATED[1][nX]:cNetDescription
						If cRede == "X" .Or. HttpSession->lDescRede == ".T."
							Aadd(HttpSession->aNewSubor, {})
						EndIf
		
						cRede := HttpSession->BRWMYEVALUATED[1][nX]:cNetDescription
					EndIf
		
					Aadd( HttpSession->aNewSubor[Len(HttpSession->aNewSubor)], HttpSession->BRWMYEVALUATED[1][nX] )
				Next nX
		
			Else
				HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA001.APW" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf
		
			//CONSULTA SE EXISTEM AUTO-AVALIACOES DO PARTICIPANTE LOGADO
			oObj:cStatusEvaluate := HttpSession->cStatus
		
			If oObj:BRWMYEVALUATES( CODUSUARIO, HttpSession->cParticipantID, HttpSession->cTpAval )
				HttpSession->BRWMYEVALUATES := {oObj:oWSBRWMYEVALUATESRESULT:oWSEVALUATELIST}
		
		 		//Separa itens por rede
				cRede := "X"
				HttpSession->aNewAuto := {}
		
				Asort( HttpSession->BRWMYEVALUATES[1],,,{ |x,y| x:cNet+x:cDescription+x:cEvaluatedName < y:cNet+y:cDescription+y:cEvaluatedName } )
				For nX := 1 To Len(HttpSession->BRWMYEVALUATES[1])
					If cRede != HttpSession->BRWMYEVALUATES[1][nX]:cNetDescription
						If cRede == "X" .Or. HttpSession->lDescRede == ".T."
							Aadd(HttpSession->aNewAuto, {})
						EndIf
						cRede := HttpSession->BRWMYEVALUATES[1][nX]:cNetDescription
					EndIf
		
					Aadd( HttpSession->aNewAuto[Len(HttpSession->aNewAuto)], HttpSession->BRWMYEVALUATES[1][nX] )
				Next nX
		
		
			Else
				HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA001.APW"}//"W_PWSA001.APW" }			//"Erro"
				Return ExecInPage("PWSAMSG")
			EndIf
		
			//CONSULTA SE EXISTEM AVALIACOES DO SUPERIOR PARA O PARTICIPANTE LOGADO
			oObj:cStatusEvaluate := HttpSession->cStatus
			oObj:cNetLevel := "3"
			If oObj:BRWMYEVALUATED( CODUSUARIO, HttpSession->cParticipantID, HttpSession->cTpAval )
				HttpSession->aSuperior := {oObj:oWSBRWMYEVALUATEDRESULT:oWSEVALUATELIST}
		
				//Separa itens por rede
				cRede := "X"
				HttpSession->aNewSuper := {}
				Asort( HttpSession->aSuperior[1],,,{ |x,y| x:cNet+x:cDescription+x:cEvaluatedName < y:cNet+y:cDescription+y:cEvaluatedName } )
				For nX := 1 To Len(HttpSession->aSuperior[1])
					If cRede != HttpSession->aSuperior[1][nX]:cNetDescription
						If cRede == "X" .Or. HttpSession->lDescRede == ".T."
							Aadd(HttpSession->aNewSuper, {})
						EndIf
		
						cRede := HttpSession->aSuperior[1][nX]:cNetDescription
					EndIf
					Aadd( HttpSession->aNewSuper[Len(HttpSession->aNewSuper)], HttpSession->aSuperior[1][nX] )
				Next nX
		
			Else
				HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA001.APW"}//"W_PWSA001.APW" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf
		
		
			//CONSULTA SE EXISTEM AVALIACOES DE PARES PARA O PARTICIPANTE LOGADO
			oObj:cStatusEvaluate := HttpSession->cStatus
			oObj:cNetLevel := "1"
		
			If oObj:BRWMYEVALUATED( CODUSUARIO, HttpSession->cParticipantID, HttpSession->cTpAval )
				HttpSession->aPares := {oObj:oWSBRWMYEVALUATEDRESULT:oWSEVALUATELIST}
		
				//Separa itens por rede
				cRede := "X"
				HttpSession->aNewPares := {}
				Asort( HttpSession->aPares[1],,,{ |x,y| x:cNet+x:cDescription+x:cEvaluatedName < y:cNet+y:cDescription+y:cEvaluatedName } )
				For nX := 1 To Len(HttpSession->aPares[1])
					If cRede != HttpSession->aPares[1][nX]:cNetDescription
						If cRede == "X" .Or. HttpSession->lDescRede == ".T."
							Aadd(HttpSession->aNewPares, {})
						EndIf
		
						cRede := HttpSession->aPares[1][nX]:cNetDescription
					EndIf
		
					Aadd( HttpSession->aNewPares[Len(HttpSession->aNewPares)], HttpSession->aPares[1][nX] )
				Next nX
		
			Else
				HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA001.APW"}//"W_PWSA001.APW" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf
		Else
			HttpSession->_HTMLERRO := { STR0001, STR0002, "W_PWSA001.APW"}//"W_PWSA001.APW" }	//"Erro"##"Participante nใo encontrado"
			Return ExecInPage("PWSAMSG" )
		EndIf

		If Len(HttpSession->aNewAuto) == 0 .AND.;
		   Len(HttpSession->aNewSuper) == 0 .AND.;
		   Len(HttpSession->aNewSubor) == 0 .AND.;
		   Len(HttpSession->aNewPares) == 0
			HttpSession->_HTMLERRO := {IIf(HttpSession->cTpAval == "3", STR0018, STR0004) + " - " + IIf(HttpSession->cStatus == "1", STR0019, STR0020), STR0011, "W_PWSA001.APW" }//"W_PWSA001.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf
		
		cHtml += ExecInPage( "PWSA010" )
	WEB EXTENDED END
Return cHtml

/*******************************************************************/
/* Autor...: 	Aline Correa do Vale			Data: Maio de 2004 */
/* Alterado...: Juliana Barros Mariano          Data: Set  de 2004 */
/* Objetivo: Responde a Auto avaliacao - Portal RH                 */
/*******************************************************************/

Web Function PWSA011()

Local cHtml := ""
Local oObj
Local cPEvaluateID 	:= If(!Empty(HttpGet->cPEvaluateID), HttpGet->cPEvaluateID, If(!Empty(HttpSession->cPEvaluateID),HttpSession->cPEvaluateID,""))
Local cProject 		:= If(!Empty(HttpGet->cProject), HttpGet->cProject, If(!Empty(HttpSession->cProject),HttpSession->cProject,""))

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")

If !Empty( HttpSession->cParticipantID ) .And. !Empty( cPEvaluateID )

		HttpSession->cDateFrom 	:= If(!Empty(HttpGet->cDateFrom), HttpGet->cDateFrom, HttpSession->cDateFrom)
		If oObj:GETPEVALUATE( CODUSUARIO, HttpSession->cParticipantID, cPEvaluateID,,,,,,, CToD(HttpSession->cDateFrom), cProject )
			HttpSession->GETPEVALUATE := oObj:oWSGETPEVALUATERESULT:oWSEVALUATELIST
			HttpSession->cReply		  := HttpSession->GETPEVALUATE[1]:cReply 
			If len(HttpSession->GETPEVALUATE[1]:oWsListOfCompetence:oWsCompetences) == 0
				HttpSession->_HTMLERRO := { STR0001, STR0003, "W_PWSA010.APW" }			//"Erro"##Nใo existem quest๕es cadastradas para a avalia็ใo atual."
				Return ExecInPage("PWSAMSG" )
			EndIf
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA010.APW" }			//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
	EndIf

HttpSession->cTipo := "2" //Auto-Avalia็ใo

cHtml += ExecInPage( "PWSA011" )

WEB EXTENDED END

Return cHtml


/*******************************************************************/
/* Autor...: 	Juliana Barros Mariano			Data: 21/02/2005   */
/* Objetivo: Impressao da avaliacao					               */
/*******************************************************************/

Web Function PIMP011()

Local cHtml := ""
Local oParam   := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())

Private cParam := ""

WEB EXTENDED INIT cHtml START "InSite"

WsChgURL(@oParam,"CFGDICTIONARY.APW")
If oParam:GETPARAM( CODUSUARIO, "MV_APDINCB" )
	cParam := AllTrim( oParam:cGETPARAMRESULT )
EndIf

//--Se o parametro nao estiver preenchido exibe, como padrao, somente o codigo
If Empty( cParam )
	cParam := "1"
EndIf

cHtml += ExecInPage( "PIMP011" )

WEB EXTENDED END

Return cHtml

/*******************************************************************/
/* Autor...: 	Tatiane Vieira Matias			Data: 28/02/2005      */
/* Objetivo: Avaliacao de Desempenho - Questoes	- Avaliado         */
/*******************************************************************/

Web Function PWSA011A()
Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSA011A" )

WEB EXTENDED END
Return cHtml

/******************************************************************/
/* Autor...: Aline Correa do Vale              Data: Maio de 2004 */
/* Objetivo: Responder Avaliador com Seus Avaliados / Sua Equipe  */
/******************************************************************/

Web Function PWSA012()
Local cHtml := ""
Local oObj
Local cPEvaluateID := If(!Empty(HttpGet->cPEvaluateID), HttpGet->cPEvaluateID, If(!Empty(HttpSession->cPEvaluateID)  ,HttpSession->cPEvaluateID  ,""))
Local cEvaluatedID := If(!Empty(HttpGet->cEvaluatedID), HttpGet->cEvaluatedID, If(!Empty(HttpSession->cEvaluatedID)  ,HttpSession->cEvaluatedID  ,""))
Local cTipoAv      := If(!Empty(HttpGet->cTipoAv)     , HttpGet->cTipoAv     , If(!Empty(HttpSession->cTipoAv)       ,HttpSession->cTipoAv       ,""))
Local cProject     := If(!Empty(HttpGet->cProject)    , HttpGet->cProject    , If(!Empty(HttpSession->cProject)      ,HttpSession->cProject      ,""))
Local cEvaluatorID := If(!Empty(HttpGet->cEvaluatorID), HttpGet->cEvaluatorID, If(!Empty(HttpSession->cParticipantId),HttpSession->cParticipantId,""))

WEB EXTENDED INIT cHtml START "InSite"
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")

If !Empty( cEvaluatedID ) .And. !Empty( cPEvaluateID ) .And. !Empty( cTipoAv )
		HttpSession->cDateFrom 	:= If(!Empty(HttpGet->cDateFrom), HttpGet->cDateFrom, HttpSession->cDateFrom)

		If oObj:GETPEVALUATE(CODUSUARIO, cEvaluatedID, cPEvaluateID, cEvaluatorID, cTipoAv,,,,, CToD(HttpSession->cDateFrom), cProject )
			HttpSession->GETPEVALUATE := oObj:oWSGETPEVALUATERESULT:oWSEVALUATELIST
			HttpSession->cReply		  := HttpSession->GETPEVALUATE[1]:cReply 
			If len(HttpSession->GETPEVALUATE[1]:oWsListOfCompetence:oWsCompetences) == 0
				HttpSession->_HTMLERRO := { STR0001, STR0003, "W_PWSA010.APW" }			//"Erro"##Nใo existem quest๕es cadastradas para a avalia็ใo atual."
				Return ExecInPage("PWSAMSG" )
			EndIf
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA010.APW" }			//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
EndIf

HttpSession->cTipo := "1" //Avaliador
cHtml += ExecInPage( "PWSA012" )

WEB EXTENDED END
Return cHtml

/*******************************************************************/
/* Autor...: 	Tatiane Vieira Matias			Data: 29/02/2005      */
/* Objetivo: Avaliacao de Desempenho - Questoes - Avaliador        */
/*******************************************************************/

Web Function PWSA012A()

Local cHtml 	:= ""
Local oParam   	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
Private cParam  := ""

WEB EXTENDED INIT cHtml START "InSite"
WsChgURL(@oParam,"CFGDICTIONARY.APW")
If oParam:GETPARAM( CODUSUARIO, "MV_APDINCB" )
	cParam := AllTrim( oParam:cGETPARAMRESULT )
EndIf

//--Se o parametro nao estiver preenchido exibe, como padrao, somente o codigo
If Empty( cParam )
	cParam := "1"
EndIf
If Valtype(HttpSession->GetPEvaluate) == "A"
	If Len(HttpSession->GetPEvaluate) > 0
		cHtml += ExecInPage( "PWSA012A" )
	Else
		HttpSession->_HTMLERRO := { STR0001, STR0011, "W_PWSA001.APW" }	
		Return ExecInPage("PWSAMSG" )
	EndIf
Else
	HttpSession->_HTMLERRO := { STR0001, STR0011, "W_PWSA001.APW" }
	Return ExecInPage("PWSAMSG" )	
EndIf
WEB EXTENDED END

Return cHtml


/******************************************************************/
/* Autor...: Juliana Barros Mariano              Data: 21/02/2005 */
/* Objetivo: Impressao de avaliacao da equipe					  */
/******************************************************************/

Web Function PIMP012()

Local cHtml := ""


WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PIMP012" )

WEB EXTENDED END

Return cHtml





//-----------------------------------------------------------------------------
//<summary>
//	Grava as respostas da Avaliacao
//</summary>
//<remarks></remarks>
//<history>	 
// 	<change date="01/05/2004" developer="Aline Correa do Vale">Criacao</change>
// 	<change date="24/11/2005" developer="Juliana Barros Mariano">Alteracao</change>
// 	<change date="08/07/2008" developer="Rogerio Ribeiro da Cruz">Isolamento da rotina de gravacao para a function 'PWSA013Grava()'</change>
//</history>
//-----------------------------------------------------------------------------
Web Function PWSA013()
	Local cHtml := If(HttpSession->cTipo=="1","W_PWSA012.APW",if(HttpSession->cTipo=="2","W_PWSA011.APW","W_PWSA015.APW"))
	
	WEB EXTENDED INIT cHtml START "InSite"

	If Valtype(HttpSession->GetPEvaluate) == "A"
		If Len(HttpSession->GetPEvaluate) > 0
			cHtml+= "?cPEvaluateID=" + HttpSession->GetPEvaluate[1]:cEvaluateID
			cHtml+= "&cEvaluatedID=" + HttpSession->GetPEvaluate[1]:cEvaluatedID
			cHtml+= "&cTipoAv=" + HttpPost->cTipoAV
			cHtml+= "&cDateFrom=" + DTOC(HttpSession->GetPEvaluate[1]:dInitialDate)
			cHtml+= "&cProject=" + HttpSession->GetPEvaluate[1]:cProject
			cHtml+= "&cEvaluatorID=" + HttpSession->GetPEvaluate[1]:cEvaluatorID
			
			If PWSA013Grava(HttpSession->GetPEvaluate[1])
				HttpSession->_HTMLERRO := {Iif(HttpSession->cTpAval == "3" ,STR0018,STR0004), STR0005, cHtml }	//"Avalia็ใo de Desempenho em Projeto"###"Avalia็ใo de Desempenho"##"Respostas gravadas com SUCESSO!"
				Return ExecInPage("PWSAMSG")
			Else
				HttpSession->_HTMLERRO := { STR0001, STR0006, cHtml }	//"Erro"##"Falha na grava็ใo"
				Return ExecInPage("PWSAMSG")
			EndIf
		Else
			HttpSession->_HTMLERRO := { STR0001, STR0051, cHtml }	//"Erro"##"Falha na grava็ใo dos dados. Timeout"
			Return ExecInPage("PWSAMSG")
		ENDIF
	Else
		HttpSession->_HTMLERRO := { STR0001,STR0051, cHtml }	//"Erro"##"Falha na grava็ใo dos dados. Timeout"
		Return ExecInPage("PWSAMSG")
	ENDIF

	WEB EXTENDED END
RETURN	


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSA010   บAutor  ณEquipe RH            ?Data ?8/07/2008   บฑ?
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ?Gravacao das respostas da Avaliacao                         บฑ?
ฑฑ?         ?                                                            บฑ?
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametros?                                                            บฑ?
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑ?
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//-----------------------------------------------------------------------------
//<summary>
//	Rotina de grava็ใo dos dados da respostas da avaliacao
//</summary>
//<remarks></remarks>
//<history>	 
// 	<change date="08/07/2008" developer="Rogerio Ribeiro da Cruz">Criacao</change>
//</history>
//-----------------------------------------------------------------------------
STATIC FUNCTION PWSA013Grava(oEvaluate)
	Local ni := 0
	Local nc := 1
	Local nz := 0
	Local nT := 0
	Local nCont, nCont1 := 0
	Local nRelevPadrao	:=0  
	Local nRelevSelec	:=0
	Local aAlternEsc	:= {} 
    Local cDisserTxt   	:= ""
	Local cJustif		:= "" 	
	Local oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
	WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")
		
	oObj:oWSEVALUATE 					:= RHPERFORMANCEEVALUATE_EVALUATES():New()
	oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:= RHPERFORMANCEEVALUATE_ARRAYOFCOMPETENCES():New()
	
	oObj:oWSEVALUATE:cEvaluateId  		:= oEvaluate:cEvaluateID
	oObj:oWSEVALUATE:cEvaluatedId 		:= oEvaluate:cEvaluatedID
	oObj:oWSEVALUATE:cEvaluatorId 		:= oEvaluate:cEvaluatorID
	oObj:oWSEVALUATE:cProject     		:= oEvaluate:cProject
	oObj:oWSEVALUATE:cNet         		:= oEvaluate:cNet
	oObj:oWSEVALUATE:cLevel       		:= oEvaluate:cLevel
	oObj:oWSEVALUATE:cVision      		:= oEvaluate:cVision
	oObj:oWSEVALUATE:cEvaluateType		:= oEvaluate:cEvaluateType
	oObj:oWSEVALUATE:dInitialDate 		:= oEvaluate:dInitialDate
	oObj:oWSEVALUATE:dFinalDate			:= oEvaluate:dFinalDate
	oObj:oWSEVALUATE:dAnswerFinalDate	:= oEvaluate:dAnswerFinalDate
	oObj:oWSEVALUATE:cSelfEvaluate		:= oEvaluate:cSelfEvaluate
	oObj:oWSEVALUATE:cModel       		:= oEvaluate:cModel
	oObj:oWSEVALUATE:cCompetence  		:= oEvaluate:cCompetence
	
	For nT := 1 to Len(oEvaluate:oWsListOfCompetence:oWsCompetences)
		nz := 1
		aAdd(oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES, RHPERFORMANCEEVALUATE_COMPETENCES():New() )
		oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nT]:oWSLISTOFQUESTION := RHPERFORMANCEEVALUATE_ARRAYOFQUESTIONS():New()
		oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nT]:cCompetenceItem := oEvaluate:oWsListOfCompetence:oWsCompetences[nT]:cCompetenceItem
	
		for nz := 1 to Len(oEvaluate:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions)
			If (oEvaluate:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cObjectType == "3" .And.;
				!Empty(Alltrim(&("HttpPost->TX"+StrZero(nT,2)+StrZero(nz,3))))) .Or.;
				(oEvaluate:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cObjectType != "3";
				.And. !EMPTY(ALLTRIM(&("HttpPost->RSP"+StrZero(nT,2)+StrZero(nz,3))))) 
	
				aAdd( oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nT]:oWSLISTOFQUESTION:oWSQUESTIONS, RHPERFORMANCEEVALUATE_QUESTIONS():New() )
				nCont := len(oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nT]:oWSLISTOFQUESTION:oWSQUESTIONS)
				oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nT]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cQuestionID := oEvaluate:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nz]:cQuestionID
				oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nT]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cObjectType := oEvaluate:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cObjectType
				oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nT]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cScale      := oEvaluate:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cScale
				nRelevPadrao := oEvaluate:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cScaleItem
	
				//Item de Relevancia 
				nRelevSelec	:= &("HttpPost->REL"+StrZero(nT,2)+StrZero(nz,3))   
				IF (nRelevSelec == NIL) .or. Empty(nRelevSelec)
					nRelevSelec:= nRelevPadrao
				Endif

				oObj:oWSEVALUATE:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nCont]:cScaleItemDescription := ""
				oObj:oWSEVALUATE:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nCont]:cScaleItem := nRelevSelec
				oEvaluate:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cScaleItem := nRelevSelec
	
				If oEvaluate:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cObjectType == "3" //dissertativa   
					//Texto Resposta dissertativa
					cDisserTxt	:= Alltrim(&("HttpPost->TX"+StrZero(nT,2)+StrZero(nz,3)))
					IF (cDisserTxt == NIL) .or. Empty(cDisserTxt)
						cDisserTxt:= oEvaluate:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cAnswerDescription 
				   	Endif
					oObj:oWSEVALUATE:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nCont]:cAnswerDescription := cDisserTxt
					oEvaluate:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cAnswerDescription :=           cDisserTxt
				Else
					//Alternativa Escolhida
					aAlternEsc	:= StrTokArr(&("HttpPost->RSP"+StrZero(nT,2)+StrZero(nz,3)), ", ")
					IF (aAlternEsc == NIL) .or. Empty(aAlternEsc)
						aAlternEsc:= oEvaluate:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nz]:oWSAlternativeChoice 
					Endif						
					oObj:oWSEVALUATE:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nCont]:oWSAlternativeChoice := RHPERFORMANCEEVALUATE_ARRAYOFRESPOSTAS():new()
					oEvaluate:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:oWSAlternativeChoice := RHPERFORMANCEEVALUATE_ARRAYOFRESPOSTAS():new()
					For nCont1 := 1 To Len(aAlternEsc)
							Aadd(oObj:oWSEVALUATE:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nCont]:oWSAlternativeChoice:oWSRESPOSTAS,RHPERFORMANCEEVALUATE_RESPOSTAS():New())
							oObj:oWSEVALUATE:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nCont]:oWSAlternativeChoice:oWSRESPOSTAS[nCont1]:cAlternativa := aAlternEsc[nCont1]
							
							Aadd(oEvaluate:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:oWSAlternativeChoice:oWSRESPOSTAS,RHPERFORMANCEEVALUATE_RESPOSTAS():New())
							oEvaluate:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:oWSAlternativeChoice:oWSRESPOSTAS[nCont1]:cAlternativa := aAlternEsc[nCont1]
							
					Next
					
					//Justificativa 
					cJustif	:= &("HttpPost->JUS"+StrZero(nT,2)+StrZero(nz,3))
					IF (cJustif == NIL) .or. Empty(cJustif)
						cJustif:= oEvaluate:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nz]:cJustification 
					Else
						cJustif := strtran(cJustif, CHR(9), "") 
					Endif
					If !Empty(cJustif)
						oObj:oWSEVALUATE:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nCont]:cJustification := Alltrim(cJustif)
						oEvaluate:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cJustification := AllTrim(cJustif)
					EndIf
				EndIf
			EndIf
		Next nz		
	Next nT
	
	HttpSession->cPEvaluateID 	:= HttpPost->cPEvaluateID
	HttpSession->cEvaluatedID 	:= HttpPost->cEvaluatedID
	HttpSession->cEvaluatorID	:= HttpPost->cEvaluatorID
	HttpSession->cTipoAV 		:= HttpPost->cTipoAV
	HttpSession->cProject 		:= HttpPost->cProject
	
	lReturn := oObj:PUTPEVALUATE( CODUSUARIO, oObj:oWsEvaluate )
RETURN lReturn



//-----------------------------------------------------------------------------
//<summary>
//	Grava os dados da respostas da avaliacao (Avaliado) e avan็a para a proxima pagina
//</summary>
//<remarks></remarks>
//<history>	 
// 	<change date="08/07/2008" developer="Rogerio Ribeiro da Cruz">Criacao</change>
//</history>
//-----------------------------------------------------------------------------
WEB FUNCTION PWSA013A()
	Local cHtml
	
	WEB EXTENDED INIT cHtml START "InSite"
	If Valtype(HttpSession->GetPEvaluate) == "A"
		If Len(HttpSession->GetPEvaluate) > 0
			If PWSA013Grava(HttpSession->GetPEvaluate[1])
				Return W_PWSA011A()
			Else
				HttpSession->_HTMLERRO := { STR0001, STR0006, "javascript:history.go(-1);" }	//"Erro"##"Falha na grava็ใo"
				Return ExecInPage("PWSAMSG")
			EndIf
		Else
			HttpSession->_HTMLERRO := { STR0001,STR0051, cHtml }	//"Erro"##"Falha na grava็ใo dos dados. Timeout"
			Return ExecInPage("PWSAMSG")
		ENDIF
	Else
		HttpSession->_HTMLERRO := { STR0001,STR0051, cHtml }	//"Erro"##"Falha na grava็ใo dos dados. Timeout"
		Return ExecInPage("PWSAMSG")
	ENDIF

	WEB EXTENDED END
RETURN



//-----------------------------------------------------------------------------
//<summary>
//	Grava os dados da respostas da avaliacao (Avaliador) e avan็a para a proxima pagina
//</summary>
//<remarks></remarks>
//<history>	 
// 	<change date="08/07/2008" developer="Rogerio Ribeiro da Cruz">Criacao</change>
//</history>
//-----------------------------------------------------------------------------
WEB FUNCTION PWSA013B()
	Local cHtml
	
	WEB EXTENDED INIT cHtml START "InSite"
	If Valtype(HttpSession->GetPEvaluate) == "A"
		If Len(HttpSession->GetPEvaluate) > 0
			If PWSA013Grava(HttpSession->GetPEvaluate[1])
				Return W_PWSA012A()
			Else
				HttpSession->_HTMLERRO := { STR0001, STR0006, "javascript:history.go(-1);" }	//"Erro"##"Falha na grava็ใo"
				Return ExecInPage("PWSAMSG")
			EndIf
		Else
			HttpSession->_HTMLERRO := { STR0001,STR0051, cHtml }	//"Erro"##"Falha na grava็ใo dos dados. Timeout"
			Return ExecInPage("PWSAMSG")
		ENDIF
	Else
		HttpSession->_HTMLERRO := { STR0001,STR0051, cHtml }	//"Erro"##"Falha na grava็ใo dos dados. Timeout"
		Return ExecInPage("PWSAMSG")
	ENDIF
	WEB EXTENDED END
RETURN



//-----------------------------------------------------------------------------
//<summary>
//	Grava os dados da respostas da avaliacao (Consenso) e avan็a para a proxima pagina
//</summary>
//<remarks></remarks>
//<history>	 
// 	<change date="08/07/2008" developer="Rogerio Ribeiro da Cruz">Criacao</change>
//</history>
//-----------------------------------------------------------------------------
WEB FUNCTION PWSA013C()
	Local cHtml
	
	WEB EXTENDED INIT cHtml START "InSite"
	If Valtype(HttpSession->GetPEvaluate) == "A"
		If Len(HttpSession->GetPEvaluate) > 0
			If PWSA013Grava(HttpSession->GetPEvaluate[1])
				Return W_PWSA015A()
			Else
				HttpSession->_HTMLERRO := { STR0001, STR0006, "javascript:history.go(-1);" }	//"Erro"##"Falha na grava็ใo"
				Return ExecInPage("PWSAMSG")
			EndIf
		Else
			HttpSession->_HTMLERRO := { STR0001,STR0051, cHtml }	//"Erro"##"Falha na grava็ใo dos dados. Timeout"
			Return ExecInPage("PWSAMSG")
		ENDIF
	Else
		HttpSession->_HTMLERRO := { STR0001,STR0051, cHtml }	//"Erro"##"Falha na grava็ใo dos dados. Timeout"
		Return ExecInPage("PWSAMSG")
	ENDIF	
	WEB EXTENDED END
RETURN



//-----------------------------------------------------------------------------
//<summary>
//	Grava os dados da respostas da avaliacao (Avaliado) e finaliza a avaliacao.
//</summary>
//<remarks></remarks>
//<history>	 
// 	<change date="08/07/2008" developer="Rogerio Ribeiro da Cruz">Criacao</change>
//</history>
//-----------------------------------------------------------------------------
WEB FUNCTION PWSA013D()
	Local cHtml
	
	WEB EXTENDED INIT cHtml START "InSite"
		If Valtype(HttpSession->GetPEvaluate) == "A"
			If Len(HttpSession->GetPEvaluate) > 0
				If PWSA013Grava(HttpSession->GetPEvaluate[1])
					Return W_PWSA014()
				Else
					HttpSession->_HTMLERRO := { STR0001, STR0006, "javascript:history.go(-1);" }	//"Erro"##"Falha na grava็ใo"
					Return ExecInPage("PWSAMSG")
				EndIf
			Else
				HttpSession->_HTMLERRO := { STR0001,STR0051, cHtml }	//"Erro"##"Falha na grava็ใo dos dados. Timeout"
				Return ExecInPage("PWSAMSG")
			ENDIF
		Else
			HttpSession->_HTMLERRO := { STR0001,STR0051, cHtml }	//"Erro"##"Falha na grava็ใo dos dados. Timeout"
			Return ExecInPage("PWSAMSG")
		ENDIF
	WEB EXTENDED END
RETURN



//****************************************************************************/
/* Autor...: Aline Correa do Vale                         Data: Maio de 2004 */
/* Alterado: Juliana Barros Mariano			   			  Data: 24.11.2005	  */
/* Objetivo: Gravar e Finalizar as respostas da Avaliacao || botao Finalizar */
//****************************************************************************/
Web Function PWSA014()
	Local cMsg		:= ""
	Local cBody 	:= ""
	Local cServer	:= ""
	Local oParam	:= ""
	Local oMsg		:= ""
	Local oObj		:= ""
	Local oEmail 	:= ""
	Local nT 		:= 0
	Local nZ 		:= 0
	Local nPos		:= 0
	Local nCont 	:= 0
	Local lCompleto	:= .T.
	Local cFinishOk	:= IIF(HttpSession->cTpAval=="3", "W_PWSA090.APW", "W_PWSA010.APW")
	Local cHtml 	:= IIF(HttpSession->cTipo=="1","W_PWSA012.APW",if(HttpSession->cTipo=="2","W_PWSA011.APW","W_PWSA015.APW"))
	cHtml+= "?cPEvaluateID=" + HttpSession->GetPEvaluate[1]:cEvaluateID
	cHtml+= "&cEvaluatedID=" + HttpSession->GetPEvaluate[1]:cEvaluatedID
	cHtml+= "&cTipoAv=" + HttpPost->cTipoAV
	cHtml+= "&cDateFrom=" + DTOC(HttpSession->GetPEvaluate[1]:dInitialDate)
	cHtml+= "&cProject=" + HttpSession->GetPEvaluate[1]:cProject
	cHtml+= "&cEvaluatorID=" + HttpSession->GetPEvaluate[1]:cEvaluatorID

	WEB EXTENDED INIT cHtml START "InSite"
		oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		oMsg	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
		oEmail	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
		oObj 	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
		WsChgURL(@oParam,"CFGDICTIONARY.APW")
		WsChgURL(@oMsg,"RHPERSONALDESENVPLAN.APW")
		WsChgURL(@oEmail,"RHCURRICULUM.APW")
		WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")
		
		oObj:oWSEVALUATE := RHPERFORMANCEEVALUATE_EVALUATES():New()
		oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE := RHPERFORMANCEEVALUATE_ARRAYOFCOMPETENCES():New()
		
		oObj:oWSEVALUATE:cEvaluateId  := HttpSession->GetPEvaluate[1]:cEvaluateID
		oObj:oWSEVALUATE:cEvaluatedId := HttpSession->GetPEvaluate[1]:cEvaluatedID
		oObj:oWSEVALUATE:cEvaluatorId := HttpSession->GetPEvaluate[1]:cEvaluatorID
		oObj:oWSEVALUATE:cProject     := HttpSession->GetPEvaluate[1]:cProject
		oObj:oWSEVALUATE:cNet         := HttpSession->GetPEvaluate[1]:cNet
		oObj:oWSEVALUATE:cLevel       := HttpSession->GetPEvaluate[1]:cLevel
		oObj:oWSEVALUATE:cVision      := HttpSession->GetPEvaluate[1]:cVision
		oObj:oWSEVALUATE:cEvaluateType:= HttpSession->GetPEvaluate[1]:cEvaluateType
		oObj:oWSEVALUATE:dInitialDate := HttpSession->GetPEvaluate[1]:dInitialDate
		oObj:oWSEVALUATE:dFinalDate   := HttpSession->GetPEvaluate[1]:dFinalDate
		oObj:oWSEVALUATE:dAnswerFinalDate:= HttpSession->GetPEvaluate[1]:dAnswerFinalDate
		oObj:oWSEVALUATE:cSelfEvaluate:= HttpSession->GetPEvaluate[1]:cSelfEvaluate //HttpSession->cTipo
		oObj:oWSEVALUATE:cModel       := HttpSession->GetPEvaluate[1]:cModel
		oObj:oWSEVALUATE:cCompetence  := HttpSession->GetPEvaluate[1]:cCompetence
		
		
		For nT := 1 to Len(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences)
			aAdd( oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES, RHPERFORMANCEEVALUATE_COMPETENCES():New() )
			oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nT]:oWSLISTOFQUESTION := RHPERFORMANCEEVALUATE_ARRAYOFQUESTIONS():New()
			oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nT]:cCompetenceItem := HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[nT]:cCompetenceItem
			for nz := 1 to Len(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions)
				If (HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cObjectType == "3" .And.;
					 !Empty(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:OWSCOMPETENCES[nT]:oWsListOfQuestion:OWSQUESTIONS[nz]:cAnswerDescription)) .Or.;
					(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cObjectType != "3" .And.;
					 ( ! Empty(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:OWSCOMPETENCES[nT]:oWsListOfQuestion:OWSQUESTIONS[nz]:oWSAlternativeChoice).And.;
					 	If(Len(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nz]:oWSAlternativeChoice:OWSRESPOSTAS)>0,HttpSession->GetPEvaluate[1]:oWsListOfCompetence:OWSCOMPETENCES[nT]:oWsListOfQuestion:OWSQUESTIONS[nz]:oWSAlternativeChoice:OWSRESPOSTAS[1]:CALTERNATIVA !='__',.F.) ))
						
					aAdd( oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nT]:oWSLISTOFQUESTION:oWSQUESTIONS, RHPERFORMANCEEVALUATE_QUESTIONS():New() )
					nCont := len(oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nT]:oWSLISTOFQUESTION:oWSQUESTIONS)
					oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nT]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cQuestionID 	:= HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nz]:cQuestionID
					oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nT]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cObjectType 	:= HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cObjectType
					oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nT]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cScale      	:= HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cScale
					oObj:oWSEVALUATE:oWSLISTOFCOMPETENCE:oWSCOMPETENCES[nT]:oWSLISTOFQUESTION:oWSQUESTIONS[nCont]:cEdit		:= HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cEdit
		
					//Item de Relevancia
					oObj:oWSEVALUATE:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nCont]:cScaleItemDescription := ""
					oObj:oWSEVALUATE:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nCont]:cScaleItem := &("HttpPost->REL"+StrZero(nT,2)+StrZero(nz,3))
					HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cScaleItem := &("HttpPost->REL"+StrZero(nT,2)+StrZero(nz,3))
		
					If HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cObjectType == "3" //dissertativa
						oObj:oWSEVALUATE:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nCont]:cAnswerDescription := HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cAnswerDescription
					Else
						oObj:oWSEVALUATE:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nCont]:oWSAlternativeChoice := HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:oWSAlternativeChoice
						If ! Empty(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cJustification)
							oObj:oWSEVALUATE:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nCont]:cJustification     := Alltrim(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWSCOMPETENCES[nT]:oWsListOfQuestion:oWSQUESTIONS[nz]:cJustification)
						EndIf
					EndIf
				Else
					If (HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nz]:cEdit == "1" .and.;
						 HttpSession->cTipo == "2") .or.;
						(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nz]:cEdit == "2" .and.;
						 HttpSession->cTipo == "1") .or.;
						(HttpSession->GetPEvaluate[1]:oWsListOfCompetence:oWsCompetences[nT]:oWsListOfQuestion:oWsQuestions[nz]:cEdit == "3")
							lCompleto := .F.
					EndIf
				EndIf
			next nz
		
		Next nT
		
		HttpSession->cPEvaluateID 	:= HttpPost->cPEvaluateID
		HttpSession->cEvaluatedID 	:= HttpPost->cEvaluatedID
		HttpSession->cEvaluatorID	:= HttpPost->cEvaluatorID
		HttpSession->cTipoAV 		:= HttpPost->cTipoAV
		HttpSession->cProject 		:= HttpPost->cProject
		
		If oObj:PUTPEVALUATE( CODUSUARIO, oObj:oWsEvaluate, lCompleto, HttpSession->cTpAval)
			If lCompleto 
				//-- Funcionalidade de envio de email foi transferido para o metodo PUTPEVALUATE na rotina WSAPD010.
				HttpSession->_HTMLERRO := {Iif(HttpSession->cTpAval == "3" ,STR0018,STR0004) , STR0007, cFinishOk}	//"Avalia็ใo de Desempenho"##"Respostas gravadas e avalia็ใo finalizada com SUCESSO!"
			Else
				HttpSession->_HTMLERRO := {Iif(HttpSession->cTpAval == "3" ,STR0018+STR0008, STR0004+STR0008), STR0009, cHtml }	//"Avalia็ใo de Desempenho - Incompleta"##"Avalia็ใo gravada e nใo finalizada por existirem quest๕es sem resposta!"
			EndIf
		Else
			HttpSession->_HTMLERRO := { STR0001, "", cHtml }	//"Erro"
		EndIf
		
		cHtml := ExecInPage( "PWSAMSG" )
	WEB EXTENDED END
	
Return cHtml

/******************************************************************/
/* Autor...: Aline Correa do Vale              Data: Maio de 2004 */
/* Alterado...: Juliana Barros Mariano         Data: Nov  de 2005 */
/* Objetivo: Consenso visualizando respostas Avaliado e Avaliador */
// ****************************************************************/
Web Function PWSA015()

	Local cHtml := ""
	Local oObj
	Local cPEvaluateID := If(!Empty(HttpGet->cPEvaluateID), HttpGet->cPEvaluateID, If(!Empty(HttpSession->cPEvaluateID),HttpSession->cPEvaluateID,""))
	Local cEvaluatedID := If(!Empty(HttpGet->cEvaluatedID), HttpGet->cEvaluatedID, If(!Empty(HttpSession->cEvaluatedID),HttpSession->cEvaluatedID,""))
	Local cEvaluatorID := If(!Empty(HttpGet->cEvaluatorID), HttpGet->cEvaluatorID, If(!Empty(HttpSession->cEvaluatorID),HttpSession->cEvaluatorID,""))
	Local cTipoAv 	   := If(!Empty(HttpGet->cTipoAv)     , HttpGet->cTipoAv     , If(!Empty(HttpSession->cTipoAv)     ,HttpSession->cTipoAv,""))
	Local cProject     := If(!Empty(HttpGet->cProject)    , HttpGet->cProject    , If(!Empty(HttpSession->cProject)    ,HttpSession->cProject,""))	
	
	WEB EXTENDED INIT cHtml START "InSite"
	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
	WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")
	
	If !Empty( cEvaluatedID ) .And. !Empty( cPEvaluateID )
		HttpSession->cDateFrom 	:= If(!Empty(HttpGet->cDateFrom), HttpGet->cDateFrom, HttpSession->cDateFrom)

		If oObj:GETPEVALUATE( CODUSUARIO, cEvaluatedID, cPEvaluateID, IIF(Empty(cEvaluatorID),HttpSession->cParticipantID,cEvaluatorID), cTipoAv,,,,, CToD(HttpSession->cDateFrom), cProject )
			HttpSession->GETPEVALUATE := oObj:oWSGETPEVALUATERESULT:oWSEVALUATELIST
			HttpSession->cReply		  := HttpSession->GETPEVALUATE[1]:cReply 
			If len(HttpSession->GETPEVALUATE[1]:oWsListOfCompetence:oWsCompetences) == 0
				HttpSession->_HTMLERRO := { STR0001, STR0003, "W_PWSA010.APW" }			//"Erro"##Nใo existem quest๕es cadastradas para a avalia็ใo atual."
				Return ExecInPage("PWSAMSG" )
			EndIf
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA010.APW" }			//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
	EndIf
	
	HttpSession->cTipo := "3" //Consenso
	cHtml += ExecInPage( "PWSA015" )
	
	WEB EXTENDED END
	
Return cHtml

/*******************************************************************/
/* Autor...: 	Tatiane Vieira Matias			Data: 29/02/2005      */
/* Objetivo: Avaliacao de Desempenho - Questoes - Consenso         */
/*******************************************************************/

Web Function PWSA015A()

Local cHtml 	:= ""
Local oParam   	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
Private cParam  := ""

WEB EXTENDED INIT cHtml START "InSite"
WsChgURL(@oParam,"CFGDICTIONARY.APW")
If oParam:GETPARAM( CODUSUARIO, "MV_APDINCB" )
	cParam := AllTrim( oParam:cGETPARAMRESULT )
EndIf
HttpSession->cReply	:= HttpGet->cReply
//--Se o parametro nao estiver preenchido exibe, como padrao, somente o codigo
If Empty( cParam )
	cParam := "1"
EndIf

cHtml += ExecInPage( "PWSA015A" )

WEB EXTENDED END

Return cHtml

/******************************************************************/
/* Autor...: Juliana Barros Mariano				Data: 21/02/2005  */
/* Objetivo: Consenso Impressao									  */
// ****************************************************************/
Web Function PIMP015()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PIMP015" )

WEB EXTENDED END

Return cHtml


/******************************************************************/
/* Autor...: Juliana Barros Mariano              Data: Outubro de 2004 */
/* Objetivo: Consulta avaliacoes do participante logado				*/
// ****************************************************************/
Web Function PWSA016()

Local cHtml := ""
Local oAval := {}

WEB EXTENDED INIT cHtml START "InSite"

oAval := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
WsChgURL(@oAval,"RHPERFORMANCEEVALUATE.APW")

If oAval:BRWEVALUATE( CODUSUARIO, HttpSession->cParticipantID )
	HttpSession->aAval := oAval:oWSBRWEVALUATERESULT:oWSEVALUATEDEVALUATE

	If len(HttpSession->aAval) > 0
		cHtml := ExecInPage("PWSA016")
	Else
		HttpSession->_HTMLERRO := { STR0010, STR0011, "W_PWSA001.APW"}//"W_PWSA001.APW" }		//"Avalia็ใo de Performance Web - Inclusใo"##"Nใo existem avalia็๕es para o participante logado"
		cHtml := ExecInPage("PWSAMSG" )
	EndIf
Else
	HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA001.APW"}//"W_PWSA001.APW" }			//"Erro"
	cHtml := ExecInPage("PWSAMSG" )
EndIf

WEB EXTENDED END

Return cHtml


/******************************************************************
* Autor...: Juliana Barros Mariano
* Data: 	Outubro de 2004
* Objetivo: Inclusao de novo avaliador e projeto para participante logado
*******************************************************************/
Web Function PWSA017()

Local cHtml := ""
Local oObj
Local nCont

WEB EXTENDED INIT cHtml START "InSite"

	/*
		HttpSession->aNewAval (linhas)

		1 - Codigo da Avaliacao
		2 - Nome da avaliacao
		3 - Codigo do Avaliador
		4 - Nome do Avaliador
		5 - Codigo do Projeto
		6 - Nome do Projeto
		7 - Codigo do Cliente
		8 - Nome do Cliente
		9 - Dt Inicial do Periodo
		10- Dt Final do Periodo
		11- Codigo do Tipo de Avaliacao
		12- Codigo da Rede
		13- Nivel da Rede
	*/

	If HttpGet->cPopUp != "2" .And. HttpGet->cPopUp != "3"

		//SESSION COM OS DADOS DA AVALIACAO SELECIONADA
		If ( ValType(HttpSession->aNewAval) == "U" )
			HttpSession->aNewAval := array(14)
		EndIf
		
		
		//Se existir apenas uma avaliacao, ja preencher o campo com esta avaliacao
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
		WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")

		If oObj:BrwGenEvaluate( CODUSUARIO, "3", "" ) //Tipo 3=Projetos

			HttpPost->aAvaliacoes := oObj:oWSBRWGENEVALUATERESULT:oWSEVALUATEGEN
			For nCont:= 1 to len(HttpPost->aAvaliacoes)                
				If HttpPost->aAvaliacoes[nCont]:cStatus == "1"
					HttpSession->aNewAval[1] := HttpPost->aAvaliacoes[nCont]:cEvaluateID		    //Cod.Avaliacao
					HttpSession->aNewAval[2] := HttpPost->aAvaliacoes[nCont]:cEvaluateDescription 	//Desc. Avaliacao
					HttpSession->aNewAval[11]:= HttpPost->aAvaliacoes[nCont]:cTypeEvaluate			//Tipo Avaliacao
					HttpSession->aNewAval[12]:= HttpPost->aAvaliacoes[nCont]:cNet  			 		//Rede
					HttpSession->aNewAval[13]:= HttpPost->aAvaliacoes[nCont]:cLevel 				//Nivel
			   		Exit
				EndIf
			Next nCont	  		
		EndIf

	ElseIf HttpGet->cPopUp == "2"

		//Inclusao de Periodo
		HttpSession->aNewAval[9] 	:= HttpGet->cPeriodoDe
		HttpSession->aNewAval[10] 	:= HttpGet->cPeriodoAte
	EndIf

	cHtml := ExecInPage("PWSA017")

WEB EXTENDED END

Return cHtml


/******************************************************************
* Autor...: Juliana Barros Mariano
* Data: 	Outubro de 2004
* Objetivo: Consulta de Projetos
* Obs:		Tela de PopUp
*******************************************************************/
Web Function PWSA017A()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

	//SE DADOS ESTIVEREM VINDO DA TELA DE POP UP ENCAMINHA PARA A TELA DE BAIXO
	//VEM DA TELA DE CONSULTA DE AVALIADOR
	//SE VEM DA TELA DE VISUALIZACAO DOS DADOS PARA ABRIR POPUP
	//CONSULTA DE AVALIADOR
	If HttpGet->cPopProd == "1"
		//SIGNIFICA QUE OS DADOS ESTAO VINDO DA TELA DE COMPETENCIAS COMPORTAMENTAIS
		HttpPost->cTela := "CC"

		cHtml := W_PWSA028()
	Else
  		HttpSession->aNewAval[3] := HttpGet->cCodAvaliador
		HttpSession->aNewAval[4] := HttpGet->cNomeAvaliador

		cHtml := ExecInPage("PWSA017")
	EndIf

WEB EXTENDED END

Return cHtml


/******************************************************************
* Autor...: Juliana Barros Mariano
* Data: 	Outubro de 2004
* Objetivo: Consulta todos os projetos em tela de popup
*******************************************************************/
Web Function PWSAPopProj()

Local cHtml := ""
Local oAval := {}

WEB EXTENDED INIT cHtml START "InSite"

//SE FOR CONSULTA NA POPUP
If HttpGet->cPopUp == "1"
	HttpSession->aNewAval[5] := HttpGet->cCodProjeto
	HttpSession->aNewAval[6] := HttpGet->cDescProjeto
	cHtml := ExecInPage("PWSA017" )
Else
	HttpPost->aProjetos := {}

	//CONSULTA NA POPUP DE PROJETOS
	If HttpGet->cPopProd != "5" .and. HttpSession->cPopProd != "5"

 		If Empty(HttpPost->cNome)
 			HttpSession->cPopProd  := "5"
			HttpSession->_HTMLERRO := { STR0001, STR0017, "W_PWSAPopProj.APW" } //"Erro" "Informe o filtro para pesquisa"
			cHtml := ExecInPage("PWSAMSG" )
 		Else
 			HttpSession->cPopProd  := ""

			oAval := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
			WsChgURL(@oAval,"RHPERFORMANCEEVALUATE.APW")


			If oAval:BrwProjects( CODUSUARIO, HttpPost->cNome, HttpSession->aNewAval[7], HttpSession->aNewAval[14])
			//If oAval:BrwCFP( 		CODUSUARIO, HttpPost->cNome, HttpSession->aNewAval[7] )

				//PARA NAO MOSTRAR MENSAGEM DE DIGITAR NOME PARA CONSULTA
				HttpPost->cScript := "<script language=javascript>Tablemsg.style.display = 'none';</script>"

				HttpPost->aProjetos := oAval:oWSBRWPROJECTSRESULT:oWSPROJECTS
				//HttpPost->aProjetos := oAval:oWSBRWCFPRESULT:oWSPROJECTS

				cHtml := ExecInPage("PWSAPopProj")
			Else
				HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA001.APW"}//"W_PWSA001.APW" }			//"Erro"
				cHtml := ExecInPage("PWSAMSG" )
			EndIf
		EndIf
	Else
		HttpSession->cPopProd  := ""
		cHtml := ExecInPage("PWSAPopProj")
	EndIf
EndIf

WEB EXTENDED END

Return cHtml


/******************************************************************
* Autor...: Emerson Grassi Rocha
* Data: 	Mar/2006
* Objetivo: Consulta de Avaliados em tela de popup
*******************************************************************/
Web Function PWSAdoPop()

Local cHtml := ""
Local oObj := {}

WEB EXTENDED INIT cHtml START "InSite"

//SE FOR CONSULTA NA POPUP
If HttpGet->cPopUp == "1"
	HttpSession->aNewAval[3] := HttpGet->cAdoCod
	HttpSession->aNewAval[4] := HttpGet->cAdoNome
	cHtml := ExecInPage("PWSA017" )
Else
	HttpPost->aAvaliados := {}

	//CONSULTA NA POPUP DE AVALIADOS
	If HttpGet->cPopProd != "3" .and. HttpSession->cPopProd != "3"

 		If Empty(HttpPost->cNome)
 			HttpSession->cPopProd  := "3"
			HttpSession->_HTMLERRO := { STR0001, STR0017, "W_PWSAdoPop.APW" } //"Erro" "Informe o filtro para pesquisa"
			cHtml := ExecInPage("PWSAMSG" )
 		Else
 			HttpSession->cPopProd  := ""

			oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
			WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")

			If oObj:brwEvaluator( CODUSUARIO, HttpPost->cNome )
				//PARA NAO MOSTRAR MENSAGEM DE DIGITAR NOME PARA CONSULTA
				HttpPost->cScript := "<script language=javascript>Tablemsg.style.display = 'none';</script>"

				httpPost->aAvaliados 	:= 	oObj:oWSBRWEVALUATORRESULT:OWSEVALUATORS
				cHtml := ExecInPage("PWSAdoPop")
			Else
				HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA001.APW"}//"W_PWSA001.APW" }			//"Erro"
				cHtml := ExecInPage("PWSAMSG" )
			EndIf
		EndIf
	Else
		HttpSession->cPopProd  := ""
		cHtml := ExecInPage("PWSAdoPop")
	EndIf
EndIf

WEB EXTENDED END

Return cHtml

/******************************************************************
* Autor...: Emerson Grassi Rocha
* Data: 	Mar/2006
* Objetivo: Consulta todos os projetos PMS em tela de popup
*******************************************************************/
Web Function PWSAPmsPop()

Local cHtml 	:= ""
Local oObj 		:= {}
Local dDtIni	:= IIf( Empty(HttpSession->aNewAval[9]), Ctod(""), Ctod(HttpSession->aNewAval[9]) )
Local dDtFim	:= IIf( Empty(HttpSession->aNewAval[10]), Ctod(""), Ctod(HttpSession->aNewAval[10]) )

WEB EXTENDED INIT cHtml START "InSite"

//SE FOR CONSULTA NA POPUP
If HttpGet->cPopUp == "1"
	HttpSession->aNewAval[5] := HttpGet->cCodProjeto
	HttpSession->aNewAval[6] := HttpGet->cDescProjeto
	cHtml := ExecInPage("PWSA017" )
Else
	HttpPost->aProjetos := {}

	//CONSULTA NA POPUP DE PROJETOS PMS
	If HttpGet->cPopProd != "6" .and. HttpSession->cPopProd != "6"

 		If Empty(HttpPost->cNome)
 			HttpSession->cPopProd  := "6"
			HttpSession->_HTMLERRO := { STR0001, STR0017, "W_PWSAPmsPop.APW" } //"Erro" "Informe o filtro para pesquisa"
			cHtml := ExecInPage("PWSAMSG" )
 		Else
 			HttpSession->cPopProd  := ""

			oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSPMSREPORT"), WSPMSREPORT():New())
			WsChgURL(@oObj,"PMSREPORT.APW")

			//GetProjectList WSRECEIVE UserCode, ProtheusUserCode, DateInitial, DateFinal, ProjectInitial, ProjectFinal,PageLen,PageFirst,QryAdd,IndexKey WSSEND ProjectList WSSERVICE PmsReport
			If oObj:GetProjectList( CODUSUARIO, CODUSUARIO , dDtIni ,dDtFim , HttpPost->cNome  ,"zzzzz" )

				//PARA NAO MOSTRAR MENSAGEM DE DIGITAR NOME PARA CONSULTA
				HttpPost->cScript := "<script language=javascript>Tablemsg.style.display = 'none';</script>"

				HttpPost->aProjetos := oObj:oWSGetProjectListRESULT:oWSProjectListView

				cHtml := ExecInPage("PWSAPmsPop")
			Else
				HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA001.APW"}//"W_PWSA001.APW" }			//"Erro"
				cHtml := ExecInPage("PWSAMSG" )
			EndIf
   	EndIf
	Else
		HttpSession->cPopProd  := ""
		cHtml := ExecInPage("PWSAPmsPop")
	EndIf
EndIf

WEB EXTENDED END

Return cHtml

/******************************************************************
* Autor...: Emerson Grassi Rocha
* Data: 	Mar/2006
* Objetivo: Pagina de Inclusao de Projeto
*******************************************************************/
Web Function PWSAProjInc()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

	cHtml := ExecInPage("PWSAProjInc")

WEB EXTENDED END

Return cHtml

/******************************************************************
* Autor...: Emerson Grassi Rocha
* Data: 	Mar/2006
* Objetivo: Consulta Avaliacoes em tela de popup
*******************************************************************/
Web Function PWSAvalPop()

Local cHtml := ""
Local oObj := {}

WEB EXTENDED INIT cHtml START "InSite"

//SE FOR CONSULTA NA POPUP
If HttpGet->cPopUp == "1"
	HttpSession->aNewAval[1] := HttpGet->cCodAvaliacao
	HttpSession->aNewAval[2] := HttpGet->cDescAvaliacao
	cHtml := ExecInPage("PWSA017" )
Else
	HttpPost->aAvaliacoes := {}

	//CONSULTA NA POPUP DE AVALIACOES
	If HttpGet->cPopProd != "1" .and. HttpSession->cPopProd != "1"

		HttpSession->cPopProd  := ""
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
		WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")

		If oObj:BrwGenEvaluate( CODUSUARIO, "3", HttpPost->cNome ) //Tipo 3=Projetos

			//PARA NAO MOSTRAR MENSAGEM DE DIGITAR NOME PARA CONSULTA
			HttpPost->cScript := "<script language=javascript>Tablemsg.style.display = 'none';</script>"

			HttpPost->aAvaliacoes := oObj:oWSBRWGENEVALUATERESULT:oWSEVALUATEGEN

			If Len(HttpPost->aAvaliacoes) > 0
				HttpSession->aNewAval[11] := HttpPost->aAvaliacoes[1]:cTypeEvaluate	//Tipo Avaliacao
				HttpSession->aNewAval[12] := HttpPost->aAvaliacoes[1]:cNet  			//Rede
				HttpSession->aNewAval[13] := HttpPost->aAvaliacoes[1]:cLevel 			//Nivel
			EndIf

			cHtml := ExecInPage("PWSAvalPop")
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSAvalPop.APW" }			//"Erro"
			cHtml := ExecInPage("PWSAMSG" )
		EndIf

	Else
		HttpSession->cPopProd  := ""
		cHtml := ExecInPage("PWSAvalPop")
	EndIf
EndIf

WEB EXTENDED END

Return cHtml


/******************************************************************
* Autor...: Emerson Grassi Rocha
* Data: 	Mar/2006
* Objetivo: Consulta Clientes em tela de popup
*******************************************************************/
Web Function PwsaCliPop()
	Local cHtml := ""
	Local oObj := {}
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	//SE FOR CONSULTA NA POPUP
	If HttpGet->cPopUp == "1"
		HttpSession->aNewAval[7] := HttpGet->cCodCliente
		HttpSession->aNewAval[8] := HttpGet->cDescCliente
		HttpSession->aNewAval[14] := HttpGet->cLojaCliente
		
		cHtml := ExecInPage("PWSA017" )
	Else
		HttpPost->aCliente := {}
	
		//CONSULTA NA POPUP DE CLIENTES
		If HttpGet->cPopProd != "2" .and. HttpSession->cPopProd != "2"
	
	 		If Empty(HttpPost->cNome)
	 			HttpSession->cPopProd  := "2"
				HttpSession->_HTMLERRO := { STR0001, STR0017, "W_PwsaCliPop.APW" } //"Erro" "Informe o filtro para pesquisa"
				cHtml := ExecInPage("PWSAMSG" )
	 		Else
	 			HttpSession->cPopProd  := ""
	
				oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSYSTEMCUSTOMER"), WSMTSYSTEMCUSTOMER():New())
				WsChgURL(@oObj,"MTSYSTEMCUSTOMER.APW")
	
	//			If oObj:BrwCustomer( CODUSUARIO, , , ,HttpPost->cNome ) //Nome Reduzido
				If oObj:BrwCustomer( CODUSUARIO, , , HttpPost->cNome ) //Nome (Razao Social)
	
					//PARA NAO MOSTRAR MENSAGEM DE DIGITAR NOME PARA CONSULTA
					HttpPost->cScript := "<script language=javascript>Tablemsg.style.display = 'none';</script>"
	
					HttpPost->aCliente := oObj:oWSBRWCUSTOMERRESULT:oWSGENERICVIEW2
	
					cHtml := ExecInPage("PWSACliPop")
				Else
					HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA001.APW"}//"W_PWSA001.APW" }			//"Erro"
					cHtml := ExecInPage("PWSAMSG" )
				EndIf
			EndIf
		Else
			HttpSession->cPopProd  := ""
			cHtml := ExecInPage("PWSACliPop")
		EndIf
	EndIf
	
	WEB EXTENDED END
	
Return cHtml

/******************************************************************
* Autor...: Emerson Grassi Rocha
* Data: 	Mar/2006
* Objetivo: Consulta Periodos em tela de popup
*******************************************************************/
Web Function PWSAPerPop()

Local cHtml := ""
Local oObj := {}

WEB EXTENDED INIT cHtml START "InSite"

//SE FOR CONSULTA NA POPUP
If HttpGet->cPopUp == "1"
	HttpSession->aNewAval[9] := HttpGet->cPeriodoDe
	HttpSession->aNewAval[10]:= HttpGet->cPeriodoAte
	cHtml := ExecInPage("PWSA017" )
Else
	HttpPost->aPeriodo := {}

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
	WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")

	If oObj:BrwPeriod( CODUSUARIO, HttpSession->aNewAval[3], HttpSession->aNewAval[1], HttpSession->cParticipantID)
		HttpPost->aPeriodo := oObj:oWSBRWPERIODRESULT:oWSEVALUATELIST

		cHtml += ExecInPage("PWSAPerPop")
	Else
		HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA001.APW"}//"W_PWSA001.APW" }			//"Erro"
		cHtml := ExecInPage("PWSAMSG" )
	EndIf

EndIf

WEB EXTENDED END

Return cHtml

/******************************************************************
* Autor...: Emerson Grassi Rocha
* Data: 	Mar/2006
* Objetivo: Pagina de Inclusao de Periodo
*******************************************************************/
Web Function PWSAPerInc()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

	cHtml := ExecInPage("PWSAPerInc")

WEB EXTENDED END

Return cHtml

/******************************************************************
* Autor...: Juliana Barros Mariano
* Data: 	Outubro de 2004
* Objetivo: Inclusao de avaliacao
*******************************************************************/
Web Function PWSA018()
	Local cHtml 	:= ""
	Local oIncAval 	:= {}
	Local oAval     := {}
	
	WEB EXTENDED INIT cHtml START "InSite"	
		oIncAval := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
		WsChgURL(@oIncAval,"RHPERFORMANCEEVALUATE.APW")
		
		//O AVALIADOR NAO PODE SER O MESMO QUE O AVALIADO
		If HttpSession->aNewAval[3] == HttpSession->cParticipantID
			HttpSession->_HTMLERRO := { STR0012, STR0013, "W_PWSA017.APW" }	//"Inclusใo - Erro"##"O avaliador deve ser diferente do avaliado."
			Return ExecInPage("PWSAMSG" )
		EndIf
		
		oIncAval:oWSPROJECTEVALUATE:oWSLISTOFEVALUATE := WsClassNew("RHPERFORMANCEEVALUATE_ARRAYOFEVALUATELIST")
		oIncAval:oWSPROJECTEVALUATE:oWSLISTOFEVALUATE:oWSEVALUATELIST := {}
	
		oAval := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHPERFORMANCEEVALUATE_EVALUATELIST"), RHPERFORMANCEEVALUATE_EVALUATELIST():New())
	
		oAval:cEVALUATEDID 		:= HttpSession->aNewAval[3]
		oAval:cEVALUATEDNAME 	:= HttpSession->aNewAval[2]
		oAval:cEVALUATEID 		:= HttpSession->aNewAval[1]
		oAval:cEVALUATETYPE 	:= HttpSession->aNewAval[11]
		oAval:cEVALUATORNAME	:= HttpSession->cParticipantName
		oAval:cEVALUATORID 		:= HttpSession->cParticipantId
		oAval:dINITIALDATE 		:= CTOD(HttpSession->aNewAval[9])
		oAval:dFINALDATE 		:= CTOD(HttpSession->aNewAval[10])
		oAval:cLEVEL 			:= HttpSession->aNewAval[13]
		oAval:cNET 				:= HttpSession->aNewAval[12]		
		oAval:cSELFEVALUATE 	:= "1"
			
		If ExistBlock("MSGETPROJECT")
			oAval:cPROJECT 		:= HttpSession->aNewAval[7] + HttpSession->aNewAval[14] + HttpSession->aNewAval[5]  
		Else
			oAval:cPROJECT 		:= HttpSession->aNewAval[5]
		End
		
		aadd( oIncAval:oWSPROJECTEVALUATE:oWSLISTOFEVALUATE:oWSEVALUATELIST, oAval )
	
		//INCLUSAO DE AVALIACAO
		If oIncAval:PutEvaluate( CODUSUARIO, oIncAval:oWSPROJECTEVALUATE )	
			HttpSession->_HTMLERRO := { STR0014, STR0015, "javascript:history.go(-2);"}//"W_PWSA001.APW" }		//"Inclusใo"##"Inclusใo efetuada com sucesso."
			cHtml := ExecInPage("PWSAMSG" )
		Else
			HttpSession->_HTMLERRO := { STR0012, PWSGetWSError(), "javascript:history.go(-1);"}//"W_PWSA001.APW" }		//"Inclusใo - Erro"
			cHtml := ExecInPage("PWSAMSG" )
		EndIf
	WEB EXTENDED END
	
Return cHtml



/******************************************************************
* Autor...: Emerson Grassi Rocha
* Data: 	Mar/2006
* Objetivo: Inclusao de Projeto
*******************************************************************/
Web Function PWSA019()

Local cHtml 	:= ""
Local oObj 		:= {}
Local oProj		:= {}

WEB EXTENDED INIT cHtml START "InSite"

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
	WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")
	oObj:oWSPUTPROJECT:oWSLISTOFPROJECT := WsClassNew("RHPERFORMANCEEVALUATE_ARRAYOFPROJECTS")
	oObj:oWSPUTPROJECT:oWSLISTOFPROJECT:oWsProjects := {}

	oProj := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHPERFORMANCEEVALUATE_PROJECTS"), RHPERFORMANCEEVALUATE_PROJECTS():New())

	oProj:cProjectId			:= "xxxxx"
	oProj:cProjectDescription	:= HttpGet->cProjPmsDesc
	oProj:dDateFrom				:= Ctod(HttpGet->cPerDe)
	oProj:dDateTo				:= Ctod(HttpGet->cPerAte)
	oProj:cMemoCode				:= HttpGet->cDescObs
	oProj:cClientId				:= HttpGet->cCliente
	oProj:cPmsCode				:= HttpGet->cProjPms

	aadd( oObj:oWSPUTPROJECT:oWSLISTOFPROJECT:oWsProjects, oProj )

	//INCLUSAO DE AVALIACAO
	If oObj:PutProjects( CODUSUARIO, oObj:oWSPUTPROJECT )

		HttpSession->aNewAval[5]:= oObj:cPutProjectsResult
		HttpSession->aNewAval[6]:= HttpGet->cProjPmsDesc

		HttpSession->_HTMLERRO := { STR0014, STR0015, "W_PWSA017.APW?cPopUp=3" }		//"Inclusใo"##"Inclusใo efetuada com sucesso."
		cHtml := ExecInPage("PWSAMSG" )
	Else
		HttpSession->_HTMLERRO := { STR0012, PWSGetWSError(), "W_PWSAProjInc.APW" }		//"Inclusใo - Erro"
		cHtml := ExecInPage("PWSAMSG" )
	EndIf

WEB EXTENDED END

Return cHtml



/******************************************************************
* Autor...: Marcelo Faria
* Data    : Jun/2016
* Objetivo: Cria cabe็alho dinโmico da avalia็ใo e padroniza
*           para todos os formulแrios envolvidos
*******************************************************************/
Function ProcHeaderAval(cTipo)
Local oObj 
Local cHtml := ""
Local nPos  := 0
Local cFil  := ''	
Local cMat  := ''

//Se existir httpGet->CEVALUATEDID significa que trata-se de avaliacao de alguem da equipe
//Nessa caso passa @@ para a Filial e o codigo RD0 para matricula, para que no ponto de entrada
//pgchHeader possa identificar se e matricula ou codigo da pessoa
if type("httpGet->CEVALUATEDID")<>'U'
	cFil := '@@'
	cMat := httpGet->CEVALUATEDID
Else
	cFil := HTTPSESSION->AUSER[2]
	cMat := HTTPSESSION->AUSER[3]
EndIf		

  //montagem do header padrใo das avalia็๕es de desempenho, correspondente aos fontes:
  // cTipo='auto-aval'     (Auto-Avalia็ใo         : pwsa011.aph; pwsa011A.aph;)
  // cTipo='imp-auto-aval' (Auto-Avalia็ใo         : pimp11.aph;)
  // cTipo='aval'          (Avalia็ใo              : pwsa012.aph; pwsa012A.aph;)
  // cTipo='imp-aval'      (Avalia็ใo              : pimp12.aph;)
  // cTipo='consenso'      (Consenso               : pwsa015.aph; pwsa015A.aph;)
  // cTipo='imp-consenso'  (Consenso               : pimp15.aph;)
  // cTipo='plano'         (Plano Desenv/Metas     : pwsa043.aph;)
  // cTipo='item-plano'    (Item Plano Desenv/Metas: pwsa041.aph; pwsa041a.aph; pwsa041b.aph; pwsa041c.aph; pwsa041d.aph;)
  // cTipo='radar'         (Radar de Compet๊ncias  : pwsa351.aph;)
  // cTipo='cons-cad'      (Cons. Dados Cadastrais : pwsa260.prw;)
  // Outros tipos variam de acordo com os tipos de solicita็๕es (PWSA102A.APH;)
   
  IF cTipo != 'cons-cad'
	  HttpSession->aHeader := {}
  EndIf	  

  If cTipo == 'auto-aval' .or. cTipo == 'imp-auto-aval' .or. ;
     cTipo == 'aval'      .or. cTipo == 'imp-aval'      .or. ;
     cTipo == 'consenso'  .or. cTipo == 'imp-consenso'      

	  If "1" $ HttpSession->cCposCabec .AND. !Empty(HttpSession->GetPEvaluate[1]:cEvaluatedName)
	      aAdd( HttpSession->aHeader , { STR0021 , HttpSession->GetPEvaluate[1]:cEvaluatedName } ) //Nome do Avaliado
	  EndIf
	  If "2" $ HttpSession->cCposCabec .AND. !Empty(HttpSession->GetPEvaluate[1]:cCoachName)
	      aAdd( HttpSession->aHeader , { STR0022 , HttpSession->GetPEvaluate[1]:cCoachName } ) //Mentor
	  EndIf
	  If "3" $ HttpSession->cCposCabec .AND. !Empty(HttpSession->GetPEvaluate[1]:cEvaluatorName)
	      aAdd( HttpSession->aHeader , { STR0023 , HttpSession->GetPEvaluate[1]:cEvaluatorName } ) //Nome do Avaliador
	  EndIf
	  If "4" $ HttpSession->cCposCabec .AND. !Empty(HttpSession->GetPEvaluate[1]:cPartLeader)
	      aAdd( HttpSession->aHeader , { STR0024 , HttpSession->GetPEvaluate[1]:cPartLeader } ) //Lider Hierarquico
	  EndIf
	  If "5" $ HttpSession->cCposCabec .AND. !Empty(HttpSession->GetPEvaluate[1]:cHierarqLevel)
	      aAdd( HttpSession->aHeader , { STR0025 , HttpSession->GetPEvaluate[1]:cHierarqLevel } ) //Nivel de Carreira
	  EndIf
	  If "6" $ HttpSession->cCposCabec .AND. !Empty(HttpSession->GetPEvaluate[1]:cCostCenterDescription)
	      aAdd( HttpSession->aHeader , { STR0026 , HttpSession->GetPEvaluate[1]:cCostCenterDescription } ) //Centro de Custo
	  EndIf
	  If "7" $ HttpSession->cCposCabec .AND. !Empty(HttpSession->GetPEvaluate[1]:dInitialDate)
	      aAdd( HttpSession->aHeader , { STR0027 , dtoc(HttpSession->GetPEvaluate[1]:dInitialDate) +' - ' +dtoc(HttpSession->GetPEvaluate[1]:dFinalDate) } ) //Periodo avaliado 
	  EndIf
	  If "8" $ HttpSession->cCposCabec .AND. !Empty(HttpSession->GetPEvaluate[1]:dAnswerFinalDate)
	      aAdd( HttpSession->aHeader , { STR0028 , dtoc(HttpSession->GetPEvaluate[1]:dAnswerFinalDate) } ) //Data limite para termino 
	  EndIf
	  If "9" $ HttpSession->cCposCabec .AND. !Empty(HttpSession->GetPEvaluate[1]:cProjectDescription)
	      aAdd( HttpSession->aHeader , { STR0029 , HttpSession->GetPEvaluate[1]:cProjectDescription } ) //Projeto
	  EndIf
	
	  If ExistBlock("MSGETPROJECT")   //Avalia PE para tratamento do cliente  
		  nPos := IIF(Len(HttpSession->GetPEvaluate[1]:oWsListOfProject:oWsProjects) > 0, 1, 0)
	  Else
		  nPos := ascan(HttpSession->GetPEvaluate[1]:oWsListOfProject:oWsProjects, { |x| (x:cProjectId == HttpSession->GetPEvaluate[1]:cProject) }) 							
	  EndIf
	  If nPos > 0 .AND. ("A" $ HttpSession->cCposCabec)
	      aAdd( HttpSession->aHeader , { STR0030 , HttpSession->GetPEvaluate[1]:oWsListOfProject:oWsProjects[nPos]:cClientDescription } ) //Cliente
	  EndIf
	
	  If cTipo == 'imp-auto-aval' .or. cTipo == 'imp-aval' .or. cTipo == 'imp-consenso'
	      aAdd( HttpSession->aHeader , { STR0031 , HttpSession->GetPEvaluate[1]:cEvaluateStatusDescription } ) //Status da Avalia็ใo
	  EndIf

  ElseIF cTipo == 'plano'
         aAdd( HttpSession->aHeader , { STR0032 , HttpSession->ParticipantName } )           //Nome

         If HttpSession->LeaderName != "NOFIELD"
            aAdd( HttpSession->aHeader , { STR0034 , HttpSession->LeaderName } )             //Lider Hierarquico
         EndIf

         aAdd( HttpSession->aHeader , { STR0025 , HttpSession->HierarqLevel } )              //Nivel de carreira
         aAdd( HttpSession->aHeader , { STR0035 , HttpSession->Area } )                      //Area
        
         aAdd( HttpSession->aHeader , { STR0036 +'/' +STR0037 , HttpSession->DescrObjective +' - ' +Httpsession->PeriodDescr } ) // Plano/Perํodo
         aAdd( HttpSession->aHeader , { STR0038 , dtoc(HttpPost->UltAlteracao) } )           //Ultima Atualizacao

         If ( HttpSession->cTipoPlano == "PDP" .And. HttpSession->cAprvPdp != "1" ) .Or. ( HttpSession->cTipoPlano == "PM" .And. HttpSession->cAprvPm != "1" )
            aAdd( HttpSession->aHeader , { STR0039 , dtoc(HttpPost->UltAprovacao) } )        //Ultima Aprovacao        
         EndIf

  ElseIF cTipo == 'item-plano'
         aAdd( HttpSession->aHeader , { STR0036 +'/' +STR0037 , HttpSession->DescrObjective +' - ' +Httpsession->PeriodDescr } ) // Plano/Perํodo
         aAdd( HttpSession->aHeader , { STR0032 , HttpSession->ParticipantName } )           //Nome
         If HttpSession->LeaderName != "NOFIELD"
            aAdd( HttpSession->aHeader , { STR0034 , HttpSession->LeaderName } )             //Lider Hierarquico
         EndIf
         aAdd( HttpSession->aHeader , { STR0022 , HttpSession->EvaluatorName } )             //Mentor

  ElseIF cTipo == 'radar'
       aAdd( HttpSession->aHeader , { STR0041 , httpSession->DadosFunc:cRegistration } )         //Matrํcula
       aAdd( HttpSession->aHeader , { STR0032 , httpSession->DadosFunc:cName } )                 //Nome
       aAdd( HttpSession->aHeader , { STR0042 , httpSession->DadosFunc:cPositionID +' - ' +httpSession->DadosFunc:cPosition } ) //Cargo Atual

  ElseIF cTipo == 'cons-cad'
       cFil := httpSession->DadosFunc:cEmployeeFilial	 
       cMat := httpSession->DadosFunc:cRegistration       
  Else 
       //Carrega headers dos outros tipos
       aAdd( HttpSession->aHeader , { STR0041 , httpSession->DadosFunc:cRegistration } )         //Matrํcula
       aAdd( HttpSession->aHeader , { STR0032 , httpSession->DadosFunc:cName } )                 //Nome
       aAdd( HttpSession->aHeader , { STR0043 , httpSession->DadosFunc:cAdmissionDate } )        //Admissใo
       aAdd( HttpSession->aHeader , { STR0044 , httpSession->DadosFunc:cNameSup } )              //Superior
       aAdd( HttpSession->aHeader , { STR0045 , httpSession->DadosFunc:cFunctionDesc } )         //Fun็ใo
       aAdd( HttpSession->aHeader , { STR0046 , httpSession->DadosFunc:cPosition } )             //Cargo
		If HttpSession->lGSP
          aAdd( HttpSession->aHeader , { STR0047 , httpSession->DadosFunc:cDescrDepartment } )   //Lota็ใo
      	Else              
          aAdd( HttpSession->aHeader , { STR0048 , httpSession->DadosFunc:cDescrDepartment } )   //Departamento
       EndIf
       aAdd( HttpSession->aHeader , { STR0049 , httpSession->DadosFunc:cCost } )                 //Centro de Custo

       If HttpSession->cTypeRequest $ "7|X"
           aAdd( HttpSession->aHeader , { STR0050 , Alltrim(Transform(httpSession->DadosFunc:nSalary, '@E 999,999,999.99')) } ) //Salแrio
       EndIf
       
       cFil := httpSession->DadosFunc:cEmployeeFilial	 
       cMat := httpSession->DadosFunc:cRegistration       
  EndIf

  // O PE para customiza็ใo do header ser?acionado dentro do m้todo UpdHeader
  // para o usuแrio possa ter acesso ao environment carregado, podendo acessar
  // outras tabelas, realizar outras pesquisas, etc...
  If ExistBlock("PGCHHEADER")
     oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMENU"), WSMENU():New())
     WsChgURL(@oObj,"MENU.APW")

	 oObj:cTypeReq	:= cTipo
	 oObj:cBranch   	:= cFil
     oObj:cHeadUser  := cMat	  
     oObj:oWSInputHeader:oWSListOfInput := wsClassNew('MENU_ARRAYOFTOPIC')
     oObj:oWSInputHeader:oWSListOfInput:oWsTopic := {}

     For nPos := 1 to Len(HttpSession->aHeader)
         aAdd(oObj:oWSInputHeader:oWSListOfInput:oWsTopic, wsClassNew('MENU_TOPIC')) 
    	  oObj:oWSInputHeader:oWSListOfInput:oWsTopic[nPos]:cTitleHead := HttpSession->aHeader[nPos][1]
	     oObj:oWSInputHeader:oWSListOfInput:oWsTopic[nPos]:cContent   := HttpSession->aHeader[nPos][2]
	  Next nPos
	  			
     If oObj:UPDHEADER()
    	  //Recarrega o header com as possํveis modifica็๕es do PE
         HttpSession->aHeader := {}
         For nPos := 1 to Len(oObj:oWSUPDHEADERRESULT:OWSTOPIC)
             aAdd( HttpSession->aHeader , { oObj:oWSUPDHEADERRESULT:OWSTOPIC[nPos]:cTITLEHEAD , oObj:oWSUPDHEADERRESULT:OWSTOPIC[nPos]:cCONTENT } )
	     Next nPos
     EndIf
  EndIf

  // monta header final para carregamento nas pแginas,
  // caso nใo exista o PE, o header do produto padrใo ?carregado
  cHtml := ''
  For nPos := 1 to Len(HttpSession->aHeader)
        If empty(HttpSession->aHeader[nPos][1]) .AND. empty(HttpSession->aHeader[nPos][2])
           cHtml += '</br>'
        Else   
           cHtml += '<div class="container-cabec">'
           cHtml += '<div class="div-titulo">'   +HttpSession->aHeader[nPos][1] +'</div>'
           cHtml += '<div class="div-conteudo">' +HttpSession->aHeader[nPos][2] +'</div>'
           cHtml += '</div>'
        EndIf   
	Next nPos

Return cHtml
