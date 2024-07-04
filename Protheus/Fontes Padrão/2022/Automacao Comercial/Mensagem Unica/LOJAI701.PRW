#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "LOJAI701.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOJAI701
Envia as numerações de Notas Fiscais de Saída para inutilização junto a Sefaz/Prefeitura

@author Vendas Cliente
@since 30/05/2016
@version P12.1.7

@param cXml, XML recebido pelo EAI Protheus
@param nType, Tipo de transação ("0" = TRANS_RECEIVE, "1" = TRANS_SEND)
@param cTypeMsg, Tipo da mensagem do EAI ("20" = EAI_MESSAGE_BUSINESS, "21" = EAI_MESSAGE_RESPONSE
        "22" = EAI_MESSAGE_RECEIPT, "23" = EAI_MESSAGE_WHOIS)
@param cVersion, Versão da Mensagem Única TOTVS

@return  Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
          aRet[1] - (boolean) Indica o resultado da execução da função
          aRet[2] - (caractere) Mensagem Xml para envio
          aRet[3] - (caractere) Nome da mensagem para retorno no WHOIS
/*/
//-------------------------------------------------------------------------------------------------

Function LOJAI701(cXml, nType, cTypeMsg, cVersion)
	
Local aArea 		:= GetArea()
Local lRet 		:= .T.
Local cXmlRet 	:= ""
Local cError 	  	:= ""  //Erros no XML
Local cWarning  	:= ""  //Avisos no XML
Local oXml			:= Nil
	
If (nType == TRANS_RECEIVE)
	oXml := xmlParser(cXml, "_", @cError, @cWarning)
	
	If oXml <> Nil .And. Empty(cError) .And. Empty(cWarning)
		If (cTypeMsg == EAI_MESSAGE_WHOIS)		
			cXMLRet := "1.000"
		ElseIf (cTypeMsg == EAI_MESSAGE_BUSINESS)			
			//Valida se versao foi implementada
			If StrTokArr(cVersion, ".")[1] == "1"
				v1000(oXml, @cXmlRet, @lRet)
			Else
				lRet 	 := .F.
				cXmlRet := STR0001 //#"A versao da mensagem informada nao foi implementada!"	
			EndIf											
		EndIf
	Else
		lRet 	 := .F.
		cXmlRet := STR0002 //#"Erro no parser!"  
	EndIf	
EndIf
	
cXmlRet := EncodeUTF8(cXmlRet)
	
RestArea(aArea)

Return {lRet, cXmlRet, "DOCUMENTNUMBERINGNULLIFICATION"}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v1000
Função para tratar o XML recebido na mensagem de Business

@param cXml, XML recebido
@param cXMLRet, Variável com a mensagem de resposta. Passada por referência. 
@return lRet, Indica se processou a mensagem recebida com sucesso

@author Vendas Cliente
@since 30/05/2016
@version P12.1.7				
/*/	
//-------------------------------------------------------------------------------------------------
	
Static Function v1000(oXml, cXMLRet, lRet)

Local oXmlContent	:= Nil //Objeto Xml com o conteudo da BusinessContent apenas
Local cDataInut	:= "" //Data da Inutilizacao
Local cTimeInut	:= "" //Horario da Inutilizacao
Local cSerie		:= "" //Serie dos Documentos
Local nDocIni		:= 0  //Numeracao Inicial 
Local nDocFim		:= 0  //Numeracao Final
Local cMarca		:= "" //Marca da Integracao
Local cProtInut	:= "" //Protocolo de Inutilizacao
Local cRetorno	:= "" //Retorno da transmissao
Local aAutoExec  	:= {} //Array com informacoes rotina automatica
Local aErroAuto	:= {} //Logs de erro do ExecAuto
Local nI			:= 0  //Contador
Local nTam 		:= TAMSX3('F2_DOC')[1] //Tamanho do Documento
Local lTransmitido := .F. //Flag transmissao TSS
Local dDataBkp	:= dDataBase //Backup de Database

Private lMsHelpAuto 		:= .T. //Variavel de controle interno do ExecAuto
Private lMsErroAuto 		:= .F. //Variavel que informa a ocorrência de erros no ExecAuto
Private lAutoErrNoFile 	:= .T. //força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário
		

If FindFunction("CFGA070INT")				
	//Marca
	If oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text <> Nil .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
		cMarca := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text				
	Else
		lRet    := .F.
		cXMLRet := STR0003 + " " + STR0004 //#"LOJAI701Marca:" ##"Marca nao informada."
	EndIf
	
	If lRet
		oXmlContent := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent //Armazena BusinessContent
		
		lTransmitido := AllTrim(Upper(LjiVldTag(oXmlContent, "_ISTRANSMITTED"))) == "TRUE" //Verifica se inutilizacao transmitida
		
		//Validacoes de tags obrigatorias
		If Empty(LjiVldTag(oXmlContent, "_NUMBERINGNULLIFICATIONPROTOCOL"))			
			lRet 	 := .F. 
			cXmlRet := STR0005 + " " + STR0006 //#"LOJAI701Protocolo:" ##"Protocolo nao informado."
		ElseIf Empty(LjiVldTag(oXmlContent, "_DOCUMENTSERIE"))			
			lRet 	 := .F. 
			cXmlRet := STR0007 + " " + STR0008 //#"LOJAI701Serie:" ##"Serie nao informada."
		ElseIf Empty(LjiVldTag(oXmlContent, "_INITIALDOCUMENTNUMBER"))			
			lRet 	 := .F. 
			cXmlRet := STR0009 + " " + STR0010 //#"LOJAI701DocumentoInicial:" ##"Numeracao inicial nao informada."
		ElseIf Empty(LjiVldTag(oXmlContent, "_FINALDOCUMENTNUMBER"))			
			lRet 	 := .F. 
			cXmlRet := STR0011 + " " + STR0012 //#"LOJAI701DocumentoFinal:" ##"Numeracao final nao informada."			
		ElseIf Empty(LjiVldTag(oXmlContent, "_NULLIFICATIONDATETIME"))			
			lRet 	 := .F.
			cXmlRet := STR0013 + " " + STR0014 //#"LOJAI701Data:" ##"Data da inutilizacao nao informada."			
		ElseIf lTransmitido .And. Empty(LjiVldTag(oXmlContent, "_TRANSMISSIONRETURNEDCODE"))			
			lRet 	 := .F.
			cXmlRet := STR0015 + " " + STR0016 //#"LOJAI701Retorno:" ##"Retorno nao informado."				
		EndIf						
																			
		If lRet							
			cProtInut 	:= LjiVldTag(oXmlContent, "_NUMBERINGNULLIFICATIONPROTOCOL") //Protocolo de inutilizacao
			cRetorno  	:= LjiVldTag(oXmlContent, "_TRANSMISSIONRETURNEDCODE") //Retorno da Sefaz
			cSerie 	:= LjiVldTag(oXmlContent, "_DOCUMENTSERIE") //Serie										
			nDocIni 	:= Val(LjiVldTag(oXmlContent, "_INITIALDOCUMENTNUMBER", "N")) //Numeracao Inicial									
			nDocFim 	:= Val(LjiVldTag(oXmlContent, "_FINALDOCUMENTNUMBER", "N"))   //Numeracao Final																													
			cDataInut 	:= LjiVldTag(oXmlContent, "_NULLIFICATIONDATETIME", "D") //Data Inutilizacao					
			cTimeInut 	:= LjiVldTag(oXmlContent, "_NULLIFICATIONDATETIME", "T") //Horario inutilizacao	
			
			//Verifica se Inutilizacao ja realizada											
			If LjPesqInut(cProtInut, cRetorno)
		       lRet 	 := .F.									
				cXmlRet := STR0017 + " " + AllTrim(cProtInut) + " " + STR0018 //#"Inutilizacao:" ##" ja integrada ao Protheus"  					
		  	EndIf
		EndIf
			
		If lRet															 																						
			aAutoExec := {cSerie,;
			          		PadR(StrZero(nDocIni, nTam),TamSx3("F2_DOC")[1]),;
			          		PadR(StrZero(nDocFim, nTam),TamSx3("F2_DOC")[1]),;
			          		"NFC-e",;
			          		"LOJA701",;
			          		lTransmitido,;
			          		cProtInut,;
			          		SToD(cDataInut),;
			          		cTimeInut,;
			          		cRetorno}
				
			Begin Transaction	
				dDataBkp  := dDataBase //Salva data atual
				dDataBase := StoD(cDataInut) //Altera Database
							
				MSExecAuto({|a,b,c,d,e| SpedNFeInut(a,b,c,d,e)}, "SF2",, 1,, aAutoExec)
																
				If lMsErroAuto					
					aErroAuto := GetAutoGrLog()
														             	
		    	  	//Armazena mensagens de erro
		         	cXmlRet := "<![CDATA["
                 	For nI := 1 To Len(aErroAuto)
                 		cXmlRet += aErroAuto[nI] + Chr(10)
               	Next nI
                	cXmlRet += "]]>"
																	
	          		//Monta XML de Erro de execução da rotina automatica
	              lRet := .F.
		              
	              DisarmTransaction()		              		              		              
                	MsUnLockAll()	
				Else																					
					cXmlRet := "<ProtocolId>" + AllTrim(cProtInut) + "</ProtocolId>"																																							
				EndIf
				
				dDataBase := dDataBkp //Restaura Database
			End Transaction
		EndIf
	EndIf		
Else
	lRet    := .F.
  	cXmlRet := STR0019 //#"Atualize EAI"                                                        
EndIf 												
	
Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjPesqInut
Pesquisa se Protocolo de inutilizacao ja utilizado          

@param Protocolo de inutilizacao
@return Se encontrou registro utilizando protocolo
@author Vendas Cliente
@since 03/06/2016
@version P12.1.7				
/*/	
//-------------------------------------------------------------------------------------------------

Static Function LjPesqInut(cProtInut, cRetorno)

Local cWhere 		:= "" //Condicao da query
Local cAliasTmp 	:= GetNextAlias() //Alias temporario
Local lRet 		:= .F. //Retorno da funcao

//Condicional para a query		
cWhere := "%"
cWhere += " F3_FILIAL = '" + xFilial("SF3") + "'"
cWhere += " AND F3_PROTOC = '" + cProtInut + "'"
cWhere += " AND F3_CODRSEF = '" + cRetorno + "'" 
cWhere += " AND D_E_L_E_T_ = ''"   		   			
cWhere += "%"

//Executa a query
BeginSql alias cAliasTmp
	SELECT 
		F3_PROTOC 
	FROM %table:SF3%							
	WHERE %exp:cWhere% 			
EndSql

(cAliasTmp)->(dbGoTop()) //Posiciona no inicio do arquivo temporario

//Busca informacoes da Inutilizacoes
If (cAliasTmp)->(!EOF())
	lRet := .T.
EndIf

//Fecha arquivo temporario
If (Select(cAliasTmp) > 0)
	(cAliasTmp)->(dbCloseArea())	
EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Função para chamada do adapter ao receber/enviar uma mensagem única

@param cXml, XML recebido pelo EAI Protheus
@param nType, Tipo de transação ("0" = TRANS_RECEIVE, "1" = TRANS_SEND)
@param cTypeMsg, Tipo da mensagem do EAI ("20" = EAI_MESSAGE_BUSINESS, "21" = EAI_MESSAGE_RESPONSE
                   "22" = EAI_MESSAGE_RECEIPT, "23" = EAI_MESSAGE_WHOIS)
@param cVersion, Versão da Mensagem Única TOTVS

@author Vendas Cliente
@since 30/05/2016	
@version P12.1.7
/*/
//-------------------------------------------------------------------------------------------------

Static Function IntegDef(cXml, nType, cTypeMsg, cVersion)  

Local aRet := {}
	
aRet := LOJAI701(cXml, nType, cTypeMsg, cVersion)

Return aRet