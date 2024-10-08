#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "LOJA2503.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA2503  �Autor  �Protheus            � Data �  02/28/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��o para identificacao no repositorio e cadastro do EAI  ���
���          �na habilitacao da Integracao com Financial Service          ���
�������������������������������������������������������������������������͹��
���Uso       � SIAGALOJA                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOJA2503()

	EvalTrigger()

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IntegDef  �Autor  �Protheus            � Data �  02/28/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para receber o XML da integracao por EAI            ���
���          � produtos: Financial Service x Protheus 11.5                ���
���          � Mesa de Credito >> Alteracao do Status do Orcamento        ���
�������������������������������������������������������������������������͹��
���Sintaxe   � Integdef ( ExpC1, ExpN2, ExpC3 )                           ���
�������������������������������������������������������������������������͹��
���Retorno   � Array sendo: 1 = logico e 2 = caracter (XML retorno)       ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 - Xml Recebido da integracao                          ���
���          �ExpN2 - momento da chamada, da INTEGDEF tem para auxilio as ���
���          � defines: TRANS_SEND                                        ���
���          �    - TRANS_RECEIVE -> para receber                         ���
���          �    - TRANS_SEND -> para enviar                             ���
���          �ExpC3 - tipo de operacao da INTEGDEF, possui as defines:    ���
���          �    - EAI_MESSAGE_BUSINESS                                  ���
���          �    - EAI_MESSAGE_RESPONSE                                  ���
���          �    - EAI_MESSAGE_WHOIS                                     ���
���          �                                                            ���
���          �Obs.: as defines informadas estao em FWADAPTEREAI.CH        ���
�������������������������������������������������������������������������͹��
���Uso       � LOJA2503                                                   ���
���          �  Chamada realizada internamento pela rotina do EAI.        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Integdef (cXml, nTpTrans, cTpMsg )

	Local lRet     := .F.       //Retorno da IntegDef
	Local cXmlRet  := " "       //XML de Retorno da IntegDef
	Local oXmlRec  := NIL       //Objeto XML recebido
	Local cErroXml := ""       	//Erro do XML
	Local cWarnXml := ""        //Warnning do XML
	
	//����������������������������������������������������������������������Ŀ
	//�Objeto do Tipo LJCIFSRecMesa, realiza todo o tratamento para gravacao �
	//������������������������������������������������������������������������
	Local oRecOrc := NIL  
		
	CONOUT("LOJA 2503 INTEGDEF - " + cValtochar(ntptrans) + " tipo msg " + ctpmsg + "  - " + FunName())
	
	// verifica��o do tipo de transa��o recebimento ou envio
	// rotina trata somente o recebimento das transa��es de resposta da Mesa de Cr�dito
	If ( nTpTrans == TRANS_RECEIVE )
		
		Do Case 
			//EAI_MESSAGE_WHOIS == retorno da vers�o para o solicitante, elemento tratado pelo FRAME
			Case ( cTpMsg == EAI_MESSAGE_WHOIS )  
			
				cXmlRet := STR0001		// "1.000" = vers�o da mensagem �nica desenvolvida
	
			//EAI_MESSAGE_BUSINESS == trata a REQUEST de resposta sobre a analise do orcamento
			Case ( cTpMsg == EAI_MESSAGE_BUSINESS )

				oXmlRec := XmlParser( EncodeUTF8(cXml), "_", @cErroXml, @cWarnXml )
				
				If ( Valtype(oXmlRec)=="U" .OR. !Empty(cErroXml) .OR. !Empty(cWarnXml) )
					
					lRet := .F.
					cXmlRet := EncodeUTF8(STR0002)   // "Arquivo com constru��o incorreta"
					
				Else
					If ( XmlChildEx(oXmlRec, "_TOTVSMESSAGE") <> NIL)
						
						If ( XmlChildEx(oXmlRec:_TOTVSMESSAGE, "_BUSINESSMESSAGE")<> NIL )
							
							oRecOrc := LJCIFSRecMesa():New( oXmlRec )
							
							//����������������������������������������������������������������������������Ŀ
							//�  A classe LJCIFSRecMesa possui tratamento interno para as inconsistencias: �
							//�		- Orcamento nao existente                                             �
							//�		- Periodo de validade ultrapassado                                    �
							//�		- Orcamento ja aprovado/reprovado                                     �
							//� Essas validacoes sao executadas pelos metodos                              �
							//� ValidOrc e Gravar da classe LJCIFSRecMesa e ficam disponiveis              �
							//� em atributos da propria classe.                                            �
							//������������������������������������������������������������������������������
							
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

