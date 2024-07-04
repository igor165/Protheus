#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "LOJA2503.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA2503  บAutor  ณProtheus            บ Data ณ  02/28/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para identificacao no repositorio e cadastro do EAI  บฑฑ
ฑฑบ          ณna habilitacao da Integracao com Financial Service          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIAGALOJA                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJA2503()

	EvalTrigger()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIntegDef  บAutor  ณProtheus            บ Data ณ  02/28/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para receber o XML da integracao por EAI            บฑฑ
ฑฑบ          ณ produtos: Financial Service x Protheus 11.5                บฑฑ
ฑฑบ          ณ Mesa de Credito >> Alteracao do Status do Orcamento        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ Integdef ( ExpC1, ExpN2, ExpC3 )                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Array sendo: 1 = logico e 2 = caracter (XML retorno)       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Xml Recebido da integracao                          บฑฑ
ฑฑบ          ณExpN2 - momento da chamada, da INTEGDEF tem para auxilio as บฑฑ
ฑฑบ          ณ defines: TRANS_SEND                                        บฑฑ
ฑฑบ          ณ    - TRANS_RECEIVE -> para receber                         บฑฑ
ฑฑบ          ณ    - TRANS_SEND -> para enviar                             บฑฑ
ฑฑบ          ณExpC3 - tipo de operacao da INTEGDEF, possui as defines:    บฑฑ
ฑฑบ          ณ    - EAI_MESSAGE_BUSINESS                                  บฑฑ
ฑฑบ          ณ    - EAI_MESSAGE_RESPONSE                                  บฑฑ
ฑฑบ          ณ    - EAI_MESSAGE_WHOIS                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณObs.: as defines informadas estao em FWADAPTEREAI.CH        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA2503                                                   บฑฑ
ฑฑบ          ณ  Chamada realizada internamento pela rotina do EAI.        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Integdef (cXml, nTpTrans, cTpMsg )

	Local lRet     := .F.       //Retorno da IntegDef
	Local cXmlRet  := " "       //XML de Retorno da IntegDef
	Local oXmlRec  := NIL       //Objeto XML recebido
	Local cErroXml := ""       	//Erro do XML
	Local cWarnXml := ""        //Warnning do XML
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณObjeto do Tipo LJCIFSRecMesa, realiza todo o tratamento para gravacao ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oRecOrc := NIL  
		
	CONOUT("LOJA 2503 INTEGDEF - " + cValtochar(ntptrans) + " tipo msg " + ctpmsg + "  - " + FunName())
	
	// verifica็ใo do tipo de transa็ใo recebimento ou envio
	// rotina trata somente o recebimento das transa็๕es de resposta da Mesa de Cr้dito
	If ( nTpTrans == TRANS_RECEIVE )
		
		Do Case 
			//EAI_MESSAGE_WHOIS == retorno da versใo para o solicitante, elemento tratado pelo FRAME
			Case ( cTpMsg == EAI_MESSAGE_WHOIS )  
			
				cXmlRet := STR0001		// "1.000" = versใo da mensagem ๚nica desenvolvida
	
			//EAI_MESSAGE_BUSINESS == trata a REQUEST de resposta sobre a analise do orcamento
			Case ( cTpMsg == EAI_MESSAGE_BUSINESS )

				oXmlRec := XmlParser( EncodeUTF8(cXml), "_", @cErroXml, @cWarnXml )
				
				If ( Valtype(oXmlRec)=="U" .OR. !Empty(cErroXml) .OR. !Empty(cWarnXml) )
					
					lRet := .F.
					cXmlRet := EncodeUTF8(STR0002)   // "Arquivo com constru็ใo incorreta"
					
				Else
					If ( XmlChildEx(oXmlRec, "_TOTVSMESSAGE") <> NIL)
						
						If ( XmlChildEx(oXmlRec:_TOTVSMESSAGE, "_BUSINESSMESSAGE")<> NIL )
							
							oRecOrc := LJCIFSRecMesa():New( oXmlRec )
							
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ  A classe LJCIFSRecMesa possui tratamento interno para as inconsistencias: ณ
							//ณ		- Orcamento nao existente                                             ณ
							//ณ		- Periodo de validade ultrapassado                                    ณ
							//ณ		- Orcamento ja aprovado/reprovado                                     ณ
							//ณ Essas validacoes sao executadas pelos metodos                              ณ
							//ณ ValidOrc e Gravar da classe LJCIFSRecMesa e ficam disponiveis              ณ
							//ณ em atributos da propria classe.                                            ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							
							If ValType(oRecOrc) == "O"
								lRet := oRecOrc:ValidaOrc() .AND. oRecOrc:Gravar()
								
								cXmlRet :=   "<ReturnAnalysisStatus> " +;
												"<Contract>"+ oRecOrc:getContrat() + "</Contract>" +;
												"<Return>" + cValToChar(oRecOrc:GetNumRet()) + "</Return>" +;
												EncodeUTF8( "<Message>" + oRecOrc:GetMsgRet() + "</Message>" ) +;
											"</ReturnAnalysisStatus>"
								
								oRecOrc:Destruct()
								FreeObj( oRecOrc )
								oRecOrc := NIL 
								
								lRet := .T. 
							Else 
								lRet := .F.
								cXmlRet := EncodeUTF8( oRecOrc:GetMsgRet()  )
							
							EndIf
						
						EndIf
					
					EndIf
				
				EndIf
		
		End Case	
	
	EndIf     
	

	CONOUT("LOJA 2503 INTEGDEF - " + cValtochar(ntptrans) + " tipo msg " + ctpmsg + "  - " + FunName() + " Retorno " + cvaltochar(lret) + Chr(13) + Chr(10) + cXmlRet )

Return { lRet, cXmlRet }

