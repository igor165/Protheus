#Include "Protheus.ch"
#include "TopConn.ch"
#include "RwMake.ch"
#include "TbIconn.ch"
#Include "FwAdapterEAI.ch"

#Define OK 1
#Define ERROR 2




/*/{Protheus.doc} INTIATU01 INTEGRAÇÃO
Mensagem única responsável pela criação do de/para utilizado pela Mensagem Única TOTVS.

@description
O adapter recebe o código utilizado na integração sem mensagem única, valida se
o registro existe na base, em caso afirmativo retorna um InternalID para o registro
e caso contrário retorna a mensagem de erro.

@author Mateus Gustavo de Freitas e Silva
@since 18/02/2014
@version P11 R9

@param cXML, caracter, XML da mensagem única para envio/recebimento
@param nTypeTrans, numerico, Tipo de transacao. (0-Recebimento, 1-Envio)
@param cTypeMessage, numerico, Tipo de transação da Mensagem. (20-Business, 21-Response, 22-Receipt)

@return array, Array de duas posições sendo a primeira o resultado do processamento e a segunda o texto de resposta.
/*/
Function INTIATU01(cXml, nTypeTrans, cTypeMessage, cAdpVersao)

Local lRet			:= .T.
Local cXmlRet		:= ""
Local cError		:= ""
Local cWarning	:= ""
Local nEntity		:= 0
Local nLoad		:= 0
Local nI			:= 0
Local nJ			:= 0
Local cChaveProt	:= ""
Local cInternalID	:= ""
Local aAux			:= {}

Private oXml			:= Nil
Private oXmlEntity  	:= Nil
Private oXmlIntID   	:= Nil
Private aReturnMsg  	:= {}
Private aSalvaLog		:= {}
Private cProduct    	:= ""
Private nIdent      	:= 0
Private cUUID       	:= ""
Private cEntity     	:= ""

   If nTypeTrans == TRANS_RECEIVE

      If cTypeMessage == EAI_MESSAGE_BUSINESS
	
         // Faz o parse do xml em um objeto
         oXml := XmlParser(cXml, "_", @cError, @cWarning)

         // Se não houve erros no parser
         If oXml <> Nil .And. Empty(cError) .And. Empty(cWarning)
            // Verifica se a marca foi informada
            If Type("oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
               cProduct :=  oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
            Else
               lRet    := .F.
               cXmlRet := "O produto é obrigatório!"
            EndIf

			If lRet
				// Altera para a filial enviada na mensagem
				AlteraEmpresaFilial(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_CompanyId:Text, oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_BranchId:Text)
			Endif

            // Verifica se o UUID foi informada
			If lRet .And. Type("oXml:_TotvsMessage:_MessageInformation:_UUID:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_UUID:Text)
               cUUID :=  oXml:_TotvsMessage:_MessageInformation:_UUID:Text
			Elseif lRet
               lRet    := .F.
               cXmlRet := "O UUID é obrigatório!"
            EndIf

            // Armazena o ID de execução (ExecutionIdentifier)
			If lRet .And. Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ExecutionIdentifier:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ExecutionIdentifier:Text)
               nIdent :=  Val(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ExecutionIdentifier:Text)
			Elseif lRet
               nIdent := 0
            EndIf

			If lRet .And. Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfEntity:_Entity") != "U"
				// Se não for array, converte em array
				If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfEntity:_Entity") != "A"
              	XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfEntity:_Entity, "_Entity")
            	EndIf

            	nEntity := Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfEntity:_Entity)
            	
				//Para cada entidade (Entity)
            	For nI := 1 To nEntity
					oXmlEntity := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfEntity:_Entity[nI]

					// Verifica se o nome da Entidade (EntityName) foi informado
					If Type("oXmlEntity:_EntityName:Text") != "U" .And. !Empty(oXmlEntity:_EntityName:Text)
						cEntity := oXmlEntity:_EntityName:Text
					Else
						lRet    := .F.
						cXmlRet := "O EntityName é obrigatório!"
					EndIf
					
					If lRet .And. Type("oXmlEntity:_ListOfInternalIdLoad:_InternalIdLoad") != "U"
						// Se não for array, converte em array
               		If Type("oXmlEntity:_ListOfInternalIdLoad:_InternalIdLoad") != "A"
                  		XmlNode2Arr(oXmlEntity:_ListOfInternalIdLoad:_InternalIdLoad, "_InternalIdLoad")
               		EndIf

               		nLoad := Len(oXmlEntity:_ListOfInternalIdLoad:_InternalIdLoad)

               		//Para cada registro (InternalIdLoad)
               		For nJ := 1 To nLoad
                  		oXmlIntID := oXmlEntity:_ListOfInternalIdLoad:_InternalIdLoad[nJ]

                  		//Verifica se a tag NewIntegrationId foi informada
                  		If Type("oXmlIntID:_NewIntegrationId:Text") != "U" .And. !Empty(oXmlIntID:_NewIntegrationId:Text)
                     		cInternalID := oXmlIntID:_NewIntegrationId:Text
                  		Else
                     		aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "NewIntegrationId não informado."})
                     		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "NewIntegrationId não informado.",1)
                     		Loop
                  		EndIf
                  	
                  		//Verifica se a tag IntegrationId foi informada
                  		If Type("oXmlIntID:_IntegrationId:Text") != "U" .And. !Empty(oXmlIntID:_IntegrationId:Text)
                     		cChaveProt := oXmlIntID:_IntegrationId:Text
                  		Else
                     		aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "IntegrationId não informado."})
                     		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "IntegrationId não informado.",1)
                     		Loop
                  		EndIf

                  		Do Case
                     		Case Upper(cEntity) == "BRANCH"
                        			//Filial
                        			Filial(cInternalID, cChaveProt)
                     		Case Upper(cEntity) == "WAREHOUSE"
                        			//Local de Estoque
                        			LocalEstoque(cInternalID, cChaveProt)
                     		Case Upper(cEntity) == "UNITOFMEASURE"
                        			//Unidade de Medida
                        			UnidadeMedida(cInternalID, cChaveProt)
                     		Case Upper(cEntity) == "COSTCENTER"
                        			//Centro de Custo
                        			CentroCusto(cInternalID, cChaveProt)
                     		Case Upper(cEntity) == "ITEM"
                        			//Produto
                        			Produto(cInternalID, cChaveProt)
                     		Case Upper(cEntity) == "CURRENCY"
                        			//Moeda
                        			Moeda(cInternalID, cChaveProt)
                     		Case Upper(cEntity) == "CURRENCYQUOTATION"
                        			//Cotação de Moeda
                        			CotacaoMoeda(cInternalID, cChaveProt)
                     		Case Upper(cEntity) == "CUSTOMERVENDOR"
                        			aAux = Separa(cChaveProt, ";")

                        			If Len(aAux) == 2
                           			If SubStr(aAux[2], 1, 1) == 'C'
                              			//Cliente
                              			aAux[2] := SubStr(aAux[2], 2)
                              			Cliente(cInternalID, cChaveProt, aAux)
                           			ElseIf SubStr(aAux[2], 1, 1) == 'F'
                              			//Fornecedor
                              			aAux[2] := SubStr(aAux[2], 2)
                              			Fornecedor(cInternalID, cChaveProt, aAux)
                           			Else
                              			aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Mascara do cliente/fornecedor inválida. Ela deve ser: L;TC, sendo L Loja, T Tipo (C=Cliente/F=Fornecedor) e C Código"})
											SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Mascara do cliente/fornecedor inválida. Ela deve ser: L;TC, sendo L Loja, T Tipo (C=Cliente/F=Fornecedor) e C Código",1)
                           			EndIf
                        			Else
                           			aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Mascara do cliente/fornecedor inválida. Ela deve ser: L;TC, sendo L Loja, T Tipo (C=Cliente/F=Fornecedor) e C Código"})
                           			SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Mascara do cliente/fornecedor inválida. Ela deve ser: L;TC, sendo L Loja, T Tipo (C=Cliente/F=Fornecedor) e C Código",1)
                        			EndIf
                     		Case Upper(cEntity) == "PAYMENTCONDITION"
                        			//Condição de Pagameto
                        			CondicaoPagamento(cInternalID, cChaveProt)
                     		Case Upper(cEntity) == "PROJECT"
                        			//Projeto
                        			Projeto(cInternalID, cChaveProt)
                     		Case Upper(cEntity) == "SUBPROJECT"
                        			//Obra
                        			Obra(cInternalID, cChaveProt)
                     		Case Upper(cEntity) == "STEPPROJECT"
                        			//Etapa
                        			Etapa(cInternalID, cChaveProt)
                     		Case Upper(cEntity) == "TASKPROJECT"
                        			//Tarefa
                        			Tarefa(cInternalID, cChaveProt)
                     		Case Upper(cEntity) == "ACCOUNTPAYABLEDOCUMENT"
                        			aAux = Separa(cChaveProt, ";")

                        			If Len(aAux) == 6
                           			//aChave [1]Numero, [2]Parcela, [3]Prefixo, [4]Tipo, [5]Loja, [6]Tipo Cli/For, [7]Codigo Cli/For
                           			aAux := {aAux[1], aAux[2], aAux[3], aAux[4], aAux[5], SubStr(aAux[6], 1, 1), SubStr(aAux[6], 2)}
                           			
                           			//Titulo a Pagar
                           			TituloPagar(cInternalID, cChaveProt, aAux)
                        			Else
                           			aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Mascara do titulo a pagar invalida. Ela deve ser: N;P;F;TT;LF;TF;CF, sendo N Numero, P Parcela, F Prefixo, TT Tipo Titulo, LF Loja Fornecedor, TF Tipo Fornecedor e CF Codigo Fornecedor"})
                           			SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Mascara do titulo a pagar invalida. Ela deve ser: N;P;F;TT;LF;TF;CF, sendo N Numero, P Parcela, F Prefixo, TT Tipo Titulo, LF Loja Fornecedor, TF Tipo Fornecedor e CF Codigo Fornecedor",1)
                        			EndIf
                     		Case Upper(cEntity) == "ACCOUNTRECEIVABLEDOCUMENT"
                        			aAux = Separa(cChaveProt, ";")

                        			If Len(aAux) == 6
                           			//aChave [1]Numero, [2]Parcela, [3]Prefixo, [4]Tipo, [5]Loja, [6]Tipo Cli/For, [7]Codigo Cli/For
                           			aAux := {aAux[1], aAux[2], aAux[3], aAux[4], aAux[5], SubStr(aAux[6], 1, 1), SubStr(aAux[6], 2)}
                           			
                           			//Titulo a Receber
                           			TituloReceber(cInternalID, cChaveProt, aAux)
                        			Else
                           			aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Mascara do titulo a receber invalida. Ela deve ser: N;P;F;TT;LC;TC;CC, sendo N Numero, P Parcela, F Prefixo, TT Tipo Titulo, LC Loja Cliente, TC Tipo Cliente e CC Codigo Cliente"})
                           			SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Mascara do titulo a receber invalida. Ela deve ser: N;P;F;TT;LC;TC;CC, sendo N Numero, P Parcela, F Prefixo, TT Tipo Titulo, LC Loja Cliente, TC Tipo Cliente e CC Codigo Cliente",1)
                        			EndIf
                     		Otherwise
                        			aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Entidade " + cEntity + " não implementada."})
                        			SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Entidade " + cEntity + " não implementada.",1)
                  		EndCase
               		Next nJ
               	Endif
            	Next nI
            	
				//Monta a resposta
				nJ := Len(aReturnMsg)
				cEntity := ""
				
				cXMLRet += '<ExecutionIdentifier>' + cValToChar(nIdent) + '</ExecutionIdentifier>'
				cXMLRet += '	<ListOfEntityReturn>'
				
				For nI := 1 To nJ
					If cEntity != aReturnMsg[nI][1]
						cEntity := aReturnMsg[nI][1]

						If nI != 1
							cXMLRet +=    '</ListOfInternalIdLoadReturn>'
							cXMLRet +=    '</EntityReturn>'
						EndIf

						cXMLRet += '<EntityReturn>'
						cXMLRet +=    '<EntityName>' + cEntity + '</EntityName>'
						cXMLRet +=    '<ListOfInternalIdLoadReturn>'
					EndIf

					cXMLRet +=          '<InternalIdLoadReturn>'
					cXMLRet +=             '<OriginInternalId>' + aReturnMsg[nI][2] + '</OriginInternalId>'
					
					If Empty(aReturnMsg[nI][3])
						cXMLRet +=          '<DestinationInternalId/>'
					Else
						cXMLRet +=          '<DestinationInternalId>' + aReturnMsg[nI][3] + '</DestinationInternalId>'
					EndIf
					
					cXMLRet +=             '<Status>' + If(aReturnMsg[nI][4] == OK, "OK", "ERROR") + '</Status>'
					
					If Empty(aReturnMsg[nI][5])
						cXMLRet +=          '<StatusMessage/>'
					Else
						cXMLRet +=          '<StatusMessage>' + aReturnMsg[nI][5] + '</StatusMessage>'
					EndIf
					
					cXMLRet +=          '</InternalIdLoadReturn>'
				Next nI
				
				cXMLRet +=          '</ListOfInternalIdLoadReturn>'
				cXMLRet +=       '</EntityReturn>'
				cXMLRet +=    '</ListOfEntityReturn>'
			Endif
		Endif
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		lRet    := .F.
		cXmlRet := "ResponseMessage não implementado."
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := "1.000"
	Endif
ElseIf nTypeTrans == TRANS_SEND
	lRet    := .F.
	cXmlRet := "Envio de BusinessMessage não implementado."
Endif

If lRet 
	SalvaLog(,,,,,,,,2)
Endif
            
Return {lRet, cXmlRet}

/*/{Protheus.doc} AlteraEmpresaFilial
Função responsável por alterar a filial de contexto do Protheus para a filial dos
registros recebidos na mensagem única.

@author Mateus Gustavo de Freitas e Silva
@since 19/02/2014
@version P11 R9

@param cColigada, caracter, coligada recebida
@param cFilialRM, caracter, filial recebida

@return array, lResult informa se houve erros nos dados recebidos, cMessage mensagem de erro.
/*/

Static Function AlteraEmpresaFilial(cColigada,cFilialRM)

Local aEmpresa := {}

// Não precisa alterar caso o registro seja compartilhado ou global (coligada 0)
If !Empty(cColigada) .And. !Empty(cFilialRM) .And. cColigada != "0"
	//Consulta o de/para
	aEmpresa := fwEAIEmpFil(cColigada, cFilialRM, cProduct)

	If Len(aEmpresa) == 2
		//Troca a filial ativa do Protheus
		cFilAnt := aEmpresa[2]
	EndIf
EndIf

Return

/*/{Protheus.doc} SalvaLog
Função responsável em gravar o log do processamento do registro na tabela de log.

@author Mateus Gustavo de Freitas e Silva
@since 18/02/2014
@version P11 R9

@param nIdent, número, Código da sincronização enviada pelo RM
@param cEntity, caracter, Entidade sincronizada
@param cIntID, caracter, Chave para localizaçãodo registro no Protheus
@param cIntIDRM, caracter, InternalID do RM
@param cINTIDPR, caracter, InternalID do Protheus
@param cUUID, caracter, UUID da mensagem recebida
@param nStatus, número, Status do processamento do registro
@param cMessage, caracter, Mensagem de erro ou de alerta

@return lógico, .T.
/*/

Static Function SalvaLog(nIdent, cEntity, cIntID, cIntIDRM, cINTIDPR, cUUID, nStatus, cMessage, nOpc)

Local nLogRM		:= 0
Local nI			:= 0
Local nHdl			:= 0
Local nK			:= 0
Local cDirLog		:= ""
Local cArqLog		:= ""
Local cNomArq		:= ""
Local cId			:= "1"
Local cAux			:= ""
Local aDirLog		:= {}
Local lOk			:= .F.
Local lErro		:= .F.
Local lTodos		:= .F.
Local lArq			:= .T.

If nOpc == 1
	aAdd(aSalvaLog,{nIdent, cEntity, cIntID, cIntIDRM, cINTIDPR, cUUID, nStatus, cMessage})
Elseif nOpc == 2
	cDirLog	:= SuperGetMv("MV_DIRLOG",,"")
	nLogRM		:= SuperGetMv("MV_OLOGRM",,3)
	
	If nLogRM <> 0
		//Verifica onde sera gerado o arquivo de log
		If Empty(cDirLog)
			cDirLog := GetSrvProfString("StartPath", "\undefined")+"logs\CargaSolum"
		Endif
		
		aDirLog := Separa(cDirLog,"\")

		For nI := 1 To Len(aDirLog)
			If nI == 1
				cDirLog := '\' + aDirLog[nI]
			Else
				cDirLog += '\' + aDirLog[nI]
			EndIf

			If !ExistDir(cDirLog)
				MakeDir(cDirLog)
			Endif
		Next nI
		
		If SubStr(cDirLog,Len(AllTrim(cDirLog)),1) <> "\"
			cDirLog	+= "\"
		Endif
		
		cDirLog 	:= StrTran(cDirLog,"\\","\")
		
		If nLOGRM == 1 //Apenas OK
			lOk := .T.
		Elseif nLOGRM == 2 //Apenas ERRO
			lErro := .T.
		Elseif nLOGRM == 3 //Todos
			lTodos := .T.
		Endif
		
		cNomArq	:= Iif(Empty(cUUID),"LOGRM",cUUID)+"_"+DtoS(MsDate())
		
		//Arquivo
		cArqLog	:= cDirLog + cNomArq+".txt"
		
		If File(cArqLog)
			While lArq
				cAux		:= cNomArq + "_" + cId
				cArqLog	:= cDirLog + cAux+".txt"
				
				If !File(cArqLog)
					lArq := .F.
				Else
					cId := Soma1(cId)
				Endif
			Enddo
		Endif
		
		nHdl := FCreate(cArqLog)
		
		If nHdl > 0
			For nI := 1 To Len(aSalvaLog)
				FWrite(nHdl,CONVREG(nI))
				FWrite(nHdl,";" + CONVREG(MsDate()))
				FWrite(nHdl,";" + CONVREG(Time()))
				FWrite(nHdl,";" + CONVREG(cEmpAnt))
				FWrite(nHdl,";" + CONVREG(cFilAnt))
				
				For nK := 1 To Len(aSalvaLog[nI])
					If lOk
						If aSalvaLog[nI,7] == 1
							FWrite(nHdl,";" + CONVREG(aSalvaLog[nI,nK]))
						Endif
					Elseif lErro
						If aSalvaLog[nI,7] == 2
							FWrite(nHdl,";" + CONVREG(aSalvaLog[nI,nK]))
						Endif
					Elseif lTodos
						FWrite(nHdl,";" + CONVREG(aSalvaLog[nI,nK]))
					Endif
				Next nK
				
				FWrite(nHdl,CRLF)
			Next nI
			
			FClose(nHdl)
		Endif
	Endif
Endif

Return .T.

Function CONVREG(xTexto)

Local xRet	:= Nil

If ValType(xTexto) == "C"
	xRet	:= AllTrim(xTexto)
Elseif ValType(xTexto) == "N"
	xRet	:= AllTrim(Str(xTexto))
Elseif ValType(xTexto) == "D"
	xRet	:= DtoC(xTexto)
Elseif ValType(xTexto) == "U"
	xRet	:= ""
Endif

Return xRet

/*/{Protheus.doc} EmpValid
Função que recebe um código de empresa (Grupo de empresa) e verifica se ele existe no Protheus.

@author Mateus Gustavo de Freitas e Silva
@since 22/02/2014
@version P11 R9

@param cEmpresa, caracter, Código da empresa

@return lógico, bResult informa se a empresa existe no Protheus
/*/

Static Function EmpValid(cEmpresa)
   Local bResult := .F.
   Local aEmpresas := FWAllGrpCompany()

   If aScan(aEmpresas, {|x| x == cEmpresa}) > 0
      bResult := .T.
   EndIf
Return bResult

/*/{Protheus.doc} EmpFilValid
Função que recebe um código de filial e verifica se ela existe no Protheus.

@author Mateus Gustavo de Freitas e Silva
@since 22/02/2014
@version P11 R9

@param cEmpresa, caracter, Código da empresa
@param cFilialPR, caracter, Código da filial

@return lógico, bResult informa se a filial existe no Protheus
/*/

Static Function EmpFilValid(cEmpresa, cFilialPR)
   Local bResult := .F.
   Local aFiliais := FWAllFilial(Nil, NIl, cEmpresa, .F.)

   If aScan(aFiliais, {|x| AllTrim(x) == AllTrim(cFilialPR)}) > 0
      bResult := .T.
   EndIf
Return bResult

//-------------------------------------------------------------------------------------

/*/{Protheus.doc} Filial
Função para processar os registros de filiais

@author Mateus Gustavo de Freitas e Silva
@since 19/02/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (Grupo de Empresa/Empresa|Filial)

@return lógico, .T.
/*/

Static Function Filial(cInternalID, cChaveProt)

Local cColigada   := ""
Local cFilialRM   := ""
Local cEmpresa    := ""
Local cFilialPR   := ""
Local aEmpresa    := {}
Local cAlias      := "XXD"
Local aAreaAnt    := GetArea()
Local lRet        := .T.

If Len(Separa(cChaveProt, '|')) < 2
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "IntegrationId " + cChaveProt + " invalida. Ela deva ser no formato Empresa|Filial."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "IntegrationId " + cChaveProt + " invalida. Ela deva ser no formato Empresa|Filial.",1)
	lRet := .F.
EndIf

If lRet 
	//Recupera os valores de Coligada e Filial do RM
   	cColigada := Separa(cInternalID, '|')[1]
   	cFilialRM := Separa(cInternalID, '|')[2]

   	//Recupera os valores de Empresa e Filial do Protheus
   	cEmpresa := Separa(cChaveProt, '|')[1]
   	cFilialPR := Separa(cChaveProt, '|')[2]

   	//Consulta o de/para
   	aEmpresa := fwEAIEmpFil(cColigada, cFilialRM, cProduct)

   	If Len(aEmpresa) == 2
		//Se a empresa for encontrada o de/para ja existe
		If AllTrim(aEmpresa[1]) == AllTrim(cEmpresa) .And. AllTrim(aEmpresa[2]) == AllTrim(cFilialPR)
			aAdd(aReturnMsg, {cEntity, cInternalID, cChaveProt, OK, "Coligada/Filial " + cInternalID + " ja se encontram no de/para."})
         	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cChaveProt, cUUID, OK, "Coligada/Filial " + cInternalID + " ja se encontram no de/para.",1)
         	lRet := .T.
      	Else
         	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Coligada/Filial " + cColigada + "/" + cFilialRM + " do RM ja cadastradas para Empresa/Filial " + aEmpresa[1] + "/" + aEmpresa[2] + " do Protheus."})
         	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Coligada/Filial " + cColigada + "/" + cFilialRM + " do RM ja cadastradas para Empresa/Filial " + cEmpresa + "/" + cFilialPR + " do Protheus.",1)
         	lRet := .F.
      	EndIf
   	Else
      	//Valida Empresa
      	If !EmpValid(cEmpresa)
         	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Empresa " + cEmpresa + " não encontrada no Protheus."})
         	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Empresa " + cEmpresa + " não encontrada no Protheus.",1)
         	lRet := .F.
      	EndIf

      	//Valida FIlial
      	If !EmpFilValid(cEmpresa, cFilialPR)
         	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Filial " + cFilialPR + " não encontrada no Protheus."})
         	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Filial " + cFilialPR + " não encontrada no Protheus.",1)
         	lRet := .F.
      	EndIf
	Endif
	
	If lRet	
      RecLock(cAlias, .T.)

      XXD->XXD_REFER  := cProduct
      XXD->XXD_COMPA  := cColigada
      XXD->XXD_BRANCH := cFilialRM
      XXD->XXD_EMPPRO := cEmpresa
      XXD->XXD_FILPRO := cFilialPR

      MsUnLock()

      aAdd(aReturnMsg, {cEntity, cInternalID, cChaveProt, OK, Nil})
      SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cChaveProt, cUUID, OK, Nil,1)
   EndIf
Endif

RestArea(aAreaAnt)

Return lRet

/*/{Protheus.doc} LocalEstoque
Função para processar os registros de locais de estoque

@author Mateus Gustavo de Freitas e Silva
@since 22/02/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (Código do Local)

@return lógico, .T.
/*/

Static Function LocalEstoque(cInternalID, cChaveProt)

Local cValInt       := ""
Local cValExt       := {}
Local cAlias        := "NNR"
Local cField        := "NNR_CODIGO"
Local aAreaAnt      := GetArea()
Local cVersao       := RTrim(PmsMsgUVer('WAREHOUSE', 'AGRA045')) //Versão do Local de Estoque

dbSelectArea(cAlias)
dbSetOrder(1) //NNR_FILIAL+NNR_CODIGO

//Verifica se o local de estoque existe na base
If dbSeek(xFilial(cAlias) + cChaveProt)
	cValInt := IntLocExt(/*cEmpresa*/, /*cFilial*/, cChaveProt, cVersao)[2]
	cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

	//Verifica se o local de estoque existe no de/para
	If Empty(cValExt)
		CFGA070Mnt(cProduct, cAlias, cField, cInternalID, cValInt, .F., 1)
		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, Nil})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, Nil,1)
 	Else
     	aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, "Local de Estoque " + cInternalID + " ja se encontra no de/para."})
      	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, "Local de Estoque " + cInternalID + " ja se encontra no de/para.",1)
	EndIf
Else
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Local de Estoque " + cChaveProt + " não encontrado no Protheus."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Local de Estoque " + cChaveProt + " não encontrado no Protheus.",1)
EndIf

RestArea(aAreaAnt)

Return .T.

/*/{Protheus.doc} UnidadeMedida
Função para processar os registros de unidades de medida

@author Mateus Gustavo de Freitas e Silva
@since 22/02/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (Código da Unidade)

@return lógico, .T.
/*/

Static Function UnidadeMedida(cInternalID, cChaveProt)

Local cValInt       := ""
Local cValExt       := {}
Local cAlias        := "SAH"
Local cField        := "AH_UNIMED"
Local aAreaAnt      := GetArea()
Local cVersao       := RTrim(PmsMsgUVer('UNITOFMEASURE', 'QIEA030')) //Versão da Unidade de Medida
Local nTamUnid      := TamSX3("AH_UNIMED")[1]

dbSelectArea(cAlias)
dbSetOrder(1) //AH_FILIAL+AH_UNIMED

//Tratamento para verificar se Ã© uma unidade exclusiva do Solum Tamanho > 2)
If Len(cChaveProt) > nTamUnid
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Unidade de Medida " + cChaveProt + " não encontrada no Protheus. Código fora do tamanho do Protheus (" + cValToChar(nTamUnid) + ")."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Unidade de Medida " + cChaveProt + " não encontrada no Protheus. Código fora do tamanho do Protheus (" + cValToChar(nTamUnid) + ").",1)
Else
	cChaveProt := PadR(cChaveProt, nTamUnid)

	//Verifica se a unidade de medida existe na base
	If dbSeek(xFilial(cAlias) + cChaveProt)
		cValInt := IntUndExt(/*cEmpresa*/, /*cFilial*/, cChaveProt, cVersao)[2]
		cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

		//Verifica se a unidade de medida existe no de/para
		If Empty(cValExt)
			CFGA070Mnt(cProduct, cAlias, cField, cInternalID, cValInt, .F., 1)

			aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, Nil})
			SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, Nil,1)
		Else
			aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, "Unidade de Medida " + cInternalID + " ja se encontra no de/para."})
			SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, "Unidade de Medida " + cInternalID + " ja se encontra no de/para.",1)
		EndIf
	Else
		aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Unidade de Medida " + cChaveProt + " não encontrada no Protheus."})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Unidade de Medida " + cChaveProt + " não encontrada no Protheus.",1)
	EndIf
EndIf

RestArea(aAreaAnt)

Return .T.

/*/{Protheus.doc} CentroCusto
Função para processar os registros de centros de custo

@author Mateus Gustavo de Freitas e Silva
@since 22/02/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (Código do Centro de Custo)

@return lógico, .T.
/*/

Static Function CentroCusto(cInternalID, cChaveProt)

Local cValInt       := ""
Local cValExt       := {}
Local cAlias        := "CTT"
Local cField        := "CTT_CUSTO"
Local aAreaAnt      := GetArea()
Local cVersao       := RTrim(PmsMsgUVer('COSTCENTER', 'CTBA030')) //Versão do Centro de Custo

dbSelectArea(cAlias)
dbSetOrder(1) //AH_FILIAL+AH_UNIMED

//Verifica se o centro de custo existe na base
If dbSeek(xFilial(cAlias) + cChaveProt)
	cValInt := IntCusExt(/*cEmpresa*/, /*cFilial*/, cChaveProt, cVersao)[2]
	cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

	//Verifica se o centro de custo existe no de/para
	If Empty(cValExt)
		CFGA070Mnt(cProduct, cAlias, cField, cInternalID, cValInt, .F., 1)

		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, Nil})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, Nil,1)
	Else
		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, "Centro de Custo " + cInternalID + " ja se encontra no de/para."})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, "Centro de Custo " + cInternalID + " ja se encontra no de/para.",1)
	EndIf
Else
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Centro de Custo " + cChaveProt + " não encontrado no Protheus."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Centro de Custo " + cChaveProt + " não encontrado no Protheus.",1)
EndIf

RestArea(aAreaAnt)

Return .T.

/*/{Protheus.doc} Produto
Função para processar os registros de produtos

@author Mateus Gustavo de Freitas e Silva
@since 24/02/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (Código do Produto)

@return lógico, .T.
/*/

Static Function Produto(cInternalID, cChaveProt)

Local cValInt       := ""
Local cValExt       := {}
Local cAlias        := "SB1"
Local cField        := "B1_COD"
Local aAreaAnt      := GetArea()
Local cVersao       := RTrim(PmsMsgUVer('ITEM', 'MATA010')) //Versão do Produto

dbSelectArea(cAlias)
dbSetOrder(1) //B1_FILIAL+B1_COD

//Verifica se o produto existe na base
If dbSeek(xFilial(cAlias) + cChaveProt)
	cValInt := IntProExt(/*cEmpresa*/, /*cFilial*/, cChaveProt, cVersao)[2]
	cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

	//Verifica se o produto existe no de/para
	If Empty(cValExt)
		CFGA070Mnt(cProduct, cAlias, cField, cInternalID, cValInt, .F., 1)

		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, Nil})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, Nil,1)
	Else
		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, "Produto " + cInternalID + " ja se encontra no de/para."})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, "Produto " + cInternalID + " ja se encontra no de/para.",1)
	EndIf
Else
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Produto " + cChaveProt + " não encontrado no Protheus."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Produto " + cChaveProt + " não encontrado no Protheus.",1)
EndIf

RestArea(aAreaAnt)

Return .T.

/*/{Protheus.doc} Moeda
Função para processar os registros de moedas

@author Mateus Gustavo de Freitas e Silva
@since 24/02/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (Símbolo da Moeda)

@return lógico, .T.
/*/

Static Function Moeda(cInternalID, cChaveProt)

Local cValInt       := ""
Local cValExt       := {}
Local cAlias        := "CTO"
Local cField        := "CTO_MOEDA"
Local aAreaAnt      := GetArea()
Local cVersao       := RTrim(PmsMsgUVer('CURRENCY', 'CTBA140')) //Versão da Moeda

dbSelectArea(cAlias)
dbSetOrder(1) //CTO_FILIAL+CTO_MOEDA

cChaveProt := SimboloMoeda(cChaveProt)

If cChaveProt == "0"
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Não foram encontradas moedas com o simbolo " + cInternalID + " no Protheus."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Não foram encontradas moedas com o simbolo " + cInternalID + " no Protheus.",1)
ElseIf cChaveProt == "-1"
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Encontrada mais de uma moeda com o simbolo " + cInternalID + " no Protheus."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Encontrada mais de uma moeda com o simbolo " + cInternalID + " no Protheus.",1)
Else
	//Verifica se a moeda existe na base
	If dbSeek(xFilial(cAlias) + cChaveProt)
		cValInt := IntMoeExt(/*cEmpresa*/, /*cFilial*/, cChaveProt, cVersao)[2]
		cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

		//Verifica se a moeda existe no de/para
		If Empty(cValExt)
			CFGA070Mnt(cProduct, cAlias, cField, cInternalID, cValInt, .F., 1)

			aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, Nil})
			SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, Nil,1)
		Else
			aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, "Moeda " + cInternalID + " ja se encontra no de/para."})
			SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, "Moeda " + cInternalID + " ja se encontra no de/para.",1)
		EndIf
	Else
		aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Moeda " + cInternalID + " não encontrada no Protheus."})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Moeda " + cChaveProt + " não encontrada no Protheus.",1)
	EndIf
EndIf

RestArea(aAreaAnt)

Return .T.

/*/{Protheus.doc} SimboloMoeda
Função que recebe o símbolo da moeda e retorna o seu código

@author Mateus Gustavo de Freitas e Silva
@since 24/02/2014
@version P11 R9

@param cSimbolo, caracter, simbolo da moeda

@return caracter, Retorna o código da moeda caso encontrada ou 0 caso não encontrada ou -1 caso encontr mais de uma correspondência para o símbolo.
/*/

Static Function SimboloMoeda(cSimbolo)

Local cSQL     := ""
Local cCodigo  := ""
Local nQuant   := 0
Local aAreaAnt := GetArea()

cSimbolo := PadR(cSimbolo, TamSX3("CTO_SIMB")[1], " ")

cSQL := "    SELECT CTO_MOEDA"
cSQL += "      FROM " + RetSQLName("CTO")
cSQL += "     WHERE CTO_SIMB = '" + cSimbolo + "'"

dbUseArea(.T., "TopConn", TCGenQry(, , cSQL), "_CTO", .F., .F.)

While _CTO->(!EoF())
	cCodigo := _CTO->CTO_MOEDA
	nQuant ++

	_CTO->(dbSkip())
EndDo

If nQuant == 0
	cCodigo := "0"
ElseIf nQuant > 1
	cCodigo := "-1"
EndIf

_CTO->(dbCloseArea())

RestArea(aAreaAnt)

Return cCodigo

/*/{Protheus.doc} CotacaoMoeda
Função para processar os registros de cotações de moedas

@author Mateus Gustavo de Freitas e Silva
@since 24/02/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (Símbolo da Moeda|Data da Cotação)

@return lógico, .T.
/*/

Static Function CotacaoMoeda(cInternalID, cChaveProt)

Local cValInt       := ""
Local cValExt       := {}
Local cAlias        := "CTP"
Local cField        := "CTP_DATA"
Local aAreaAnt      := GetArea()
Local cVersao       := RTrim(PmsMsgUVer('CURRENCYQUOTATION', 'CTBA150')) //Versão da Cotação de Moeda
Local aAux          := {}

dbSelectArea(cAlias)
dbSetOrder(1) //CTP_FILIAL+DTOS(CTP_DATA)+CTP_MOEDA

aAux := Separa(cChaveProt, "|")
aAux[1] := SimboloMoeda(aAux[1])

If Len(aAux) < 2
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Chave " + cChaveProt + " invalida. Ele deve ser no formato Moeda|Data."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Chave " + cChaveProt + " invalida. Ele deve ser no formato Moeda|Data.",1)
ElseIf aAux[1] == "0"
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Não foram encontradas moedas com o simbolo " + Separa(cChaveProt, "|")[1] + " no Protheus."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Não foram encontradas moedas com o simbolo " + Separa(cChaveProt, "|")[1] + " no Protheus.",1)
ElseIf aAux[1] == "-1"
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Encontrada mais de uma moeda com o simbolo " + Separa(cChaveProt, "|")[1] + " no Protheus."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Encontrada mais de uma moeda com o simbolo " + Separa(cChaveProt, "|")[1] + " no Protheus.",1)
Else
	//Formata moeda do formato YYYY-MM-DD para DD/MM/YYYY
	aAux[2] := Separa(aAux[2], '-')[3] + '/' + Separa(aAux[2], '-')[2] + '/' + Separa(aAux[2], '-')[1]

	//Verifica se a cotação da moeda existe na base
	If dbSeek(xFilial(cAlias) + DTOS(CTOD(aAux[2])) + aAux[1])
		cValInt := IntCotExt(/*cEmpresa*/, /*cFilial*/, aAux[1], aAux[2], cVersao)[2]
		cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

		//Verifica se a cotação da moeda existe no de/para
		If Empty(cValExt)
			CFGA070Mnt(cProduct, cAlias, cField, cInternalID, cValInt, .F., 1)

			aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, Nil})
			SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, Nil,1)
		Else
			aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, "Cotação da Moeda " + cInternalID + " ja se encontra no de/para."})
			SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, "Cotação da Moeda " + cInternalID + " ja se encontra no de/para.",1)
		EndIf
	Else
		aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Cotação da Moeda " + cChaveProt + " não encontrada no Protheus."})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Cotação da Moeda " + cChaveProt + " não encontrada no Protheus.",1)
	EndIf
EndIf

RestArea(aAreaAnt)

Return .T.

/*/{Protheus.doc} Cliente
Função para processar os registros de clientes

@author Mateus Gustavo de Freitas e Silva
@since 25/02/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (Loja do Cliente;Tipo do ClienteCódigo do Cliente)
@param aChave, array, Loja do Cliente e Código do Cliente

@return lógico, .T.
/*/

Static Function Cliente(cInternalID, cChaveProt, aChave)

Local cValInt       := ""
Local cValExt       := {}
Local cAlias        := "SA1"
Local cField        := "A1_COD"
Local aAreaAnt      := GetArea()
Local cVersao       := RTrim(PmsMsgUVer('CUSTOMERVENDOR', 'MATA030')) //Versão do Cliente

dbSelectArea(cAlias)
dbSetOrder(1) //A1_FILIAL+A1_COD+A1_LOJA

//Verifica se o cliente existe na base
If dbSeek(xFilial(cAlias) + PadR(aChave[2], TamSX3("A1_COD")[1]) + aChave[1])
	cValInt := IntCliExt(/*cEmpresa*/, /*cFilial*/, aChave[2], aChave[1], cVersao)[2]
	cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

	//Verifica se o cliente existe no de/para
	If Empty(cValExt)
		CFGA070Mnt(cProduct, cAlias, cField, cInternalID, cValInt, .F., 1)

		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, Nil})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, Nil,1)
	Else
		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, "Cliente " + cInternalID + " ja se encontra no de/para."})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, "Cliente " + cInternalID + " ja se encontra no de/para.",1)
	EndIf
Else
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Cliente " + cChaveProt + " não encontrado no Protheus."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Cliente " + cChaveProt + " não encontrado no Protheus.",1)
EndIf

RestArea(aAreaAnt)

Return .T.

/*/{Protheus.doc} Fornecedor
Função para processar os registros de fornecedores

@author Mateus Gustavo de Freitas e Silva
@since 25/02/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (Loja do Fornecedor;Tipo do FornecedorCódigo do Fornecedor)
@param aChave, array, Loja do Fornecedor e Código do Fornecedor

@return lógico, .T.
/*/

Static Function Fornecedor(cInternalID, cChaveProt, aChave)

Local cValInt       := ""
Local cValExt       := {}
Local cAlias        := "SA2"
Local cField        := "A2_COD"
Local aAreaAnt      := GetArea()
Local cVersao       := RTrim(PmsMsgUVer('CUSTOMERVENDOR', 'MATA020')) //Versão do Fornecedor

dbSelectArea(cAlias)
dbSetOrder(1) //A2_FILIAL+A2_COD+A2_LOJA

//Verifica se o fornecedor existe na base
If dbSeek(xFilial(cAlias) + PadR(aChave[2], TamSX3("A2_COD")[1]) + aChave[1])
	cValInt := IntForExt(/*cEmpresa*/, /*cFilial*/, aChave[2], aChave[1], cVersao)[2]
	cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

	//Verifica se o fornecedor existe no de/para
	If Empty(cValExt)
		CFGA070Mnt(cProduct, cAlias, cField, cInternalID, cValInt, .F., 1)

		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, Nil})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, Nil,1)
	Else
		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, "Fornecedor " + cInternalID + " ja se encontra no de/para."})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, "Fornecedor " + cInternalID + " ja se encontra no de/para.",1)
	EndIf
Else
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Fornecedor " + cChaveProt + " não encontrado no Protheus."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Fornecedor " + cChaveProt + " não encontrado no Protheus.",1)
EndIf

RestArea(aAreaAnt)

Return .T.

/*/{Protheus.doc} CondicaoPagamento
Função para processar os registros de condições de pagamento

@author Mateus Gustavo de Freitas e Silva
@since 25/02/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (Código da Condição)

@return lógico, .T.
/*/

Static Function CondicaoPagamento(cInternalID, cChaveProt)

Local cValInt       := ""
Local cValExt       := {}
Local cAlias        := "SE4"
Local cField        := "E4_CODIGO"
Local aAreaAnt      := GetArea()
Local cVersao       := RTrim(PmsMsgUVer('PAYMENTCONDITION', 'MATA360')) //Versão da Condição de Pagamento

dbSelectArea(cAlias)
dbSetOrder(1) //E4_FILIAL+E4_CODIGO

//Verifica se a condição de pagamento existe na base
If dbSeek(xFilial(cAlias) + cChaveProt)
	cValInt := IntConExt(/*cEmpresa*/, /*cFilial*/, cChaveProt, cVersao)[2]
	cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

	//Verifica se a condição de pagamento existe no de/para
	If Empty(cValExt)
		CFGA070Mnt(cProduct, cAlias, cField, cInternalID, cValInt, .F., 1)

		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, Nil})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, Nil,1)
	Else
		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, "Condição de Pagamento " + cInternalID + " ja se encontra no de/para."})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, "Condição de Pagamento " + cInternalID + " ja se encontra no de/para.",1)
	EndIf
Else
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Condição de Pagamento " + cChaveProt + " não encontrada no Protheus."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Condição de Pagamento " + cChaveProt + " não encontrada no Protheus.",1)
EndIf

RestArea(aAreaAnt)

Return .T.

/*/{Protheus.doc} Projeto
Função para processar os registros de projetos

@author Mateus Gustavo de Freitas e Silva
@since 25/02/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (Código do projeto)

@return lógico, .T.
/*/

Static Function Projeto(cInternalID, cChaveProt)

Local cValInt       := ""
Local cValExt       := {}
Local cAlias        := "AF8"
Local cField        := "AF8_PROJET"
Local aAreaAnt      := GetArea()
Local cVersao       := RTrim(PmsMsgUVer('PROJECT', 'PMSA200')) //Versão do Projeto

dbSelectArea(cAlias)
dbSetOrder(1) //AF8_FILIAL+AF8_PROJET

//Verifica se o projeto existe na base
If dbSeek(xFilial(cAlias) + cChaveProt)
	cValInt := IntPrjExt(/*cEmpresa*/, /*cFilial*/, cChaveProt, cVersao)[2]
	cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

		//Verifica se o projeto existe no de/para
	If !Empty(cValExt)
		CFGA070Mnt(cProduct, cAlias, cField, , cValInt, .T.)
	Endif

	CFGA070Mnt(cProduct, cAlias, cField, cInternalID, cValInt, .F., 1)

	aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, Nil})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, Nil,1)
	
Else
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Projeto " + cChaveProt + " não encontrado no Protheus."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Projeto " + cChaveProt + " não encontrado no Protheus.",1)
EndIf

RestArea(aAreaAnt)

Return .T.

/*/{Protheus.doc} Obra
Função para processar os registros de obras

@author Mateus Gustavo de Freitas e Silva
@since 25/02/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (Código do Projeto|Código da Obra)

@return lógico, .T.
/*/

Static Function Obra(cInternalID, cChaveProt)

Local cValInt       := ""
Local cValExt       := {}
Local cAlias        := "AFC"
Local cField        := "AFC_PROJET"
Local aAreaAnt      := GetArea()
Local cVersao       := RTrim(PmsMsgUVer('SUBPROJECT', 'PMSA201')) //Versão da Obra
Local aAux          := {}

dbSelectArea(cAlias)
dbSetOrder(1) //AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDT+AFC_ORDEM

aAux := Separa(cChaveProt, "|")

If Len(aAux) != 2
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Chave informada (" + cChaveProt + ") esta em um formato invalido. A chave deve ser Projeto|Obra."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Chave informada (" + cChaveProt + ") esta em um formato invalido. A chave deve ser Projeto|Obra.",1)
Else
	//Verifica se a obra existe na base
	If dbSeek(xFilial(cAlias) + PadR(aAux[1], TamSX3("AFC_PROJET")[1]) + PadL("1", TamSX3("AFC_REVISA")[1], "0") + aAux[2])
		cValInt := IntEDTExt(/*cEmpresa*/, /*cFilial*/, aAux[1], /*cRevisao*/, aAux[2], cVersao)[2]
		cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)
	
		//Verifica se a obra existe no de/para
		If !Empty(cValExt)
			CFGA070Mnt(cProduct, cAlias, cField, , cValInt, .T.)
		Endif
		
		CFGA070Mnt(cProduct, cAlias, cField, cInternalID, cValInt, .F., 1)
	
		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, Nil})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, Nil,1)
		
	Else
		aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Obra " + cChaveProt + " não encontrada no Protheus."})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Obra " + cChaveProt + " não encontrada no Protheus.",1)
	EndIf
Endif

RestArea(aAreaAnt)

Return .T.

/*/{Protheus.doc} Etapa
Função para processar os registros de etapas

@author Mateus Gustavo de Freitas e Silva
@since 25/02/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (Código do Projeto|Código da Etapa)

@return lógico, .T.
/*/

Static Function Etapa(cInternalID, cChaveProt)

Local cValInt       := ""
Local cValExt       := {}
Local cAlias        := "AFC"
Local cField        := "AFC_EDT"
Local aAreaAnt      := GetArea()
Local cVersao       := RTrim(PmsMsgUVer('STEPPROJECT', 'PMSA201A')) //Versão da Etapa
Local aAux          := {}

dbSelectArea(cAlias)
dbSetOrder(1) //AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDT+AFC_ORDEM

aAux := Separa(cChaveProt, "|")

If Len(aAux) != 2
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Chave informada (" + cChaveProt + ") esta em um formato invalido. A chave deve ser Projeto|Etapa."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Chave informada (" + cChaveProt + ") esta em um formato invalido. A chave deve ser Projeto|Etapa.",1)
Else
	//Verifica se a etapa existe na base
	If dbSeek(xFilial(cAlias) + PadR(aAux[1], TamSX3("AFC_PROJET")[1]) + PadL("1", TamSX3("AFC_REVISA")[1], "0") + aAux[2])
		cValInt := IntEDTExt(/*cEmpresa*/, /*cFilial*/, aAux[1], /*cRevisao*/, aAux[2], cVersao)[2]
		cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

      	//Verifica se a Etapa existe no de/para
		If !Empty(cValExt)
			CFGA070Mnt(cProduct, cAlias, cField, , cValInt, .T.)
		Endif
		
		CFGA070Mnt(cProduct, cAlias, cField, cInternalID, cValInt, .F., 1)

		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, Nil})
     	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, Nil,1)
      	
	Else
		aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Etapa " + cChaveProt + " não encontrada no Protheus."})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Etapa " + cChaveProt + " não encontrada no Protheus.",1)
	EndIf
EndIf

RestArea(aAreaAnt)

Return .T.

/*/{Protheus.doc} Tarefa
Função para processar os registros de tarefas

@author Mateus Gustavo de Freitas e Silva
@since 25/02/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (Código do Projeto|Código da Tarefa)

@return lógico, .T.
/*/

Static Function Tarefa(cInternalID, cChaveProt)

Local cValInt       := ""
Local cValExt       := {}
Local cAlias        := "AF9"
Local cField        := "AF9_TAREFA"
Local aAreaAnt      := GetArea()
Local cVersao       := RTrim(PmsMsgUVer('TASKPROJECT', 'PMSA203')) //Versão da Tarefa
Local aAux          := {}

dbSelectArea(cAlias)
dbSetOrder(1) //AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA+AF9_ORDEM

aAux := Separa(cChaveProt, "|")

If Len(aAux) != 2
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Chave informada (" + cChaveProt + ") esta em um formato invalido. A chave deve ser Projeto|Tarefa."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Chave informada (" + cChaveProt + ") esta em um formato invalido. A chave deve ser Projeto|Tarefa.",1)
Else
	//Verifica se a tarefa existe na base
	If dbSeek(xFilial(cAlias) + PadR(aAux[1], TamSX3("AF9_PROJET")[1]) + PadL("1", TamSX3("AF9_REVISA")[1], "0") + aAux[2])
		cValInt := IntTrfExt(/*cEmpresa*/, /*cFilial*/, aAux[1], /*cRevisao*/, aAux[2], cVersao)[2]
		cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

		//Verifica se a tarefa existe no de/para
		If !Empty(cValExt)
			CFGA070Mnt(cProduct, cAlias, cField, , cValInt, .T.)
		Endif
		
		CFGA070Mnt(cProduct, cAlias, cField, cInternalID, cValInt, .F., 1)

		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, Nil})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, Nil,1)
		
	Else
		aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Tarefa " + cChaveProt + " não encontrada no Protheus."})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Tarefa " + cChaveProt + " não encontrada no Protheus.",1)
	EndIf
EndIf

RestArea(aAreaAnt)

Return .T.

/*/{Protheus.doc} TituloPagar
Função para processar os registros de títulos a pagar

@author Mateus Gustavo de Freitas e Silva
@since 03/03/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (N;P;F;TT;LF;TF;CF, sendo N Número, P Parcela, F Prefixo, TT Tipo Título, LF Loja Fornecedor, TF Tipo Fornecedor e CF Código Fornecedor)
@param cChaveProt, caracter, Chave do título ([1]Número, [2]Parcela, [3]Prefixo, [4]Tipo, [5]Loja, [6]Tipo Cli/For, [7]Código Cli/For)

@return lógico, .T.
/*/

Static Function TituloPagar(cInternalID, cChaveProt, aChave)

Local cValInt       := ""
Local cValExt       := {}
Local cAlias        := "SE2"
Local cField        := "E2_NUM"
Local aAreaAnt      := GetArea()
Local cVersao       := RTrim(PmsMsgUVer('ACCOUNTPAYABLEDOCUMENT', 'FINA050')) //Versão do Titulo a Pagar

dbSelectArea(cAlias)
dbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
//aChave [1]Numero, [2]Parcela, [3]Prefixo, [4]Tipo, [5]Loja, [6]Tipo Cli/For, [7]Codigo Cli/For

//Verifica se o Titulo existe na base
If dbSeek(xFilial(cAlias) + PadR(aChave[3], TamSX3("E2_PREFIXO")[1]) + PadR(aChave[1], TamSX3("E2_NUM")[1]) + PadR(aChave[2], TamSX3("E2_PARCELA")[1]) + PadR(aChave[4], TamSX3("E2_TIPO")[1]) + PadR(aChave[7], TamSX3("E2_FORNECE")[1]) + PadR(aChave[5], TamSX3("E2_LOJA")[1]))
	cValInt := IntTPgExt(/*cEmpresa*/, /*cFilial*/, aChave[3], aChave[1], aChave[2], aChave[4], aChave[7], aChave[5], cVersao)[2]
	cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

	//Verifica se o titulo existe no de/para
	If Empty(cValExt)
		CFGA070Mnt(cProduct, cAlias, cField, cInternalID, cValInt, .F., 1)

		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, Nil})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, Nil,1)
	Else
		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, "Titulo a Pagar " + cInternalID + " ja se encontra no de/para."})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, "Titulo a Pagar " + cInternalID + " ja se encontra no de/para.",1)
	EndIf
Else
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Titulo a Pagar " + cChaveProt + " não encontrado no Protheus."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Titulo a Pagar " + cChaveProt + " não encontrado no Protheus.",1)
EndIf

RestArea(aAreaAnt)

Return .T.

/*/{Protheus.doc} TituloReceber
Função para processar os registros de títulos a receber

@author Mateus Gustavo de Freitas e Silva
@since 03/03/2014
@version P11 R9

@param cInternalID, caracter, InternalID externo
@param cChaveProt, caracter, Chave Protheus (N;P;F;TT;LC;TC;CC, sendo N Número, P Parcela, F Prefixo, TT Tipo Título, LC Loja Cliente, TC Tipo Cliente e CC Código Cliente)
@param cChaveProt, caracter, Chave do título ([1]Número, [2]Parcela, [3]Prefixo, [4]Tipo, [5]Loja, [6]Tipo Cli/For, [7]Código Cli/For)

@return lógico, .T.
/*/

Static Function TituloReceber(cInternalID, cChaveProt, aChave)

Local cValInt       := ""
Local cValExt       := {}
Local cAlias        := "SE1"
Local cField        := "E1_NUM"
Local aAreaAnt      := GetArea()
Local cVersao       := RTrim(PmsMsgUVer('ACCOUNTRECEIVABLEDOCUMENT', 'FINA040')) //Versão do Titulo a Receber

dbSelectArea(cAlias)
dbSetOrder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
//aChave [1]Numero, [2]Parcela, [3]Prefixo, [4]Tipo, [5]Loja, [6]Tipo Cli/For, [7]Codigo Cli/For

//Verifica se o Titulo existe na base
If dbSeek(xFilial(cAlias) + PadR(aChave[7], TamSX3("E1_CLIENTE")[1]) + PadR(aChave[5], TamSX3("E1_LOJA")[1]) + PadR(aChave[3], TamSX3("E1_PREFIXO")[1]) + PadR(aChave[1], TamSX3("E1_NUM")[1]) + PadR(aChave[2], TamSX3("E1_PARCELA")[1]) + PadR(aChave[4], TamSX3("E1_TIPO")[1]))
	cValInt := IntTRcExt(/*cEmpresa*/, /*cFilial*/, aChave[3], aChave[1], aChave[2], aChave[4], cVersao)[2]
	cValExt := CFGA070Ext(cProduct, cAlias, cField, cValInt)

	//Verifica se o titulo existe no de/para
	If Empty(cValExt)
		CFGA070Mnt(cProduct, cAlias, cField, cInternalID, cValInt, .F., 1)

		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, Nil})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, Nil,1)
	Else
		aAdd(aReturnMsg, {cEntity, cInternalID, cValInt, OK, "Titulo a Receber " + cInternalID + " ja se encontra no de/para."})
		SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, cValInt, cUUID, OK, "Titulo a Receber " + cInternalID + " ja se encontra no de/para.",1)
	EndIf
Else
	aAdd(aReturnMsg, {cEntity, cInternalID, Nil, ERROR, "Titulo a Receber " + cChaveProt + " não encontrado no Protheus."})
	SalvaLog(nIdent, cEntity, cChaveProt, cInternalID, Nil, cUUID, ERROR, "Titulo a Receber " + cChaveProt + " não encontrado no Protheus.")
EndIf

RestArea(aAreaAnt)

Return .T.
