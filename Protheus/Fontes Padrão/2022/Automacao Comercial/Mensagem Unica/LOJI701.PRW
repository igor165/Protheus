#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJI701.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TBICONN.CH" 
#INCLUDE "TbiCode.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

Static __lCancVen := .F. //Flag venda cancelada

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOJI701

Funcao de integracao com o adapter EAI para envio/recebimento de Vendas Varejo utilizando o conceito
Mensagem Unica.

@param   cXml        	Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans  	Tipo de transação. (Envio/Recebimento)
@param   cTypeMsg  	Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Vendas Cliente      
@version P12
@since   05/01/2016
@return  lRet - (boolean)  Indica o resultado da execução da função
          cXmlRet - (caracter) Mensagem XML para envio
          Nome do Adapter EAI
/*/
//-------------------------------------------------------------------------------------------------
Function LOJI701(cXml, nTypeTrans, cTypeMsg, lObjEai)

	Local cError    := ""         //Erros no XML
	Local cWarning  := ""         //Avisos no XML
	Local cVersao   := ""         //Versao da Mensagem
	Local cXmlRet   := ""         //Mensagem de retorno da integracao
	Local cMarca    := ""         //Armazena a Marca que enviou o XML
	Local cValExt   := ""         //Codigo externo utilizada no De/Para de codigos - Tabela XXF
	Local cValInt   := ""         //Codigo interno utilizada no De/Para de codigos - Tabela XXF
	Local cAlias    := "SL1"      //Tabela De-Para
	Local cCampo    := "L1_DOC"   //Campo De-Para
	Local nCount    := 0          //Contador
	Local lRet      := .T.        //Retorno da integracao
	Local oXmlL701  := Nil
	Local lCancVen  := .F.        //Flag cancelamento de venda

	Default lObjEai := .F.

    //Desvio Objeto EAI
	If lObjEai
		Return LOJI701O(cXml, nTypeTrans, cTypeMsg)
	EndIf

    //Verifica tipo da mensagem
	If cTypeMsg == EAI_MESSAGE_BUSINESS
        
        //Mensagem de Recebimento
		If nTypeTrans == TRANS_RECEIVE
			oXmlL701 := xmlParser(cXml, "_", @cError, @cWarning) //Objeto XML
					
		    //Validacoes de erro no XML
			If oXmlL701 <> Nil .And. Empty(cError) .And. Empty(cWarning)

			    //Validacao se versao foi informada		
				If !Empty(LjiVldTag(oXmlL701:_TOTVSMessage:_MessageInformation, "_VERSION"))
					cVersao := oXmlL701:_TOTVSMessage:_MessageInformation:_version:Text //Versao da mensagem
		
				    //Valida se versao foi implementada
					If StrTokArr(cVersao, ".")[1] == "1"
						v1000(oXmlL701, nTypeTrans, @lRet, @cXmlRet, cVersao)
					Elseif StrTokArr(cVersao, ".")[1] == "2"
						v2000(oXmlL701, nTypeTrans, @lRet, @cXmlRet, cVersao)
					Else
						lRet 	 := .F.
						cXmlRet := STR0001 //#"A versao da mensagem informada nao foi implementada!"
					EndIf
				Else
					lRet 	 := .F.
					cXmlRet := STR0002 //#"Versao da mensagem nao informada!"
				EndIf
			Else
				lRet 	 := .F.
				cXmlRet := STR0003 //#"Erro no parser!"
			EndIf
        
        //Mensagem de Envio
		ElseIf nTypeTrans == TRANS_SEND
            
            cVersao := StrTokArr( RTrim( PmsMsgUVer('RETAILSALES', 'LOJA701') ), ".")[1]

            If cVersao == "1"
			    v1000(oXmlL701, nTypeTrans, @lRet, @cXmlRet, cVersao)
            ElseIf cVersao == "2"
                v2000(oXmlL701, nTypeTrans, @lRet, @cXmlRet, cVersao)
            Else
                lRet    := .F.
				cXmlRet := STR0001 //#"A versao da mensagem informada nao foi implementada!"
            EndIf

		EndIf

	ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
	    //Gravacao do De/Para Codigo Interno X Codigo Externo  	
		oXmlL701 := xmlParser(cXml, "_", @cError, @cWarning) //Objeto XML

	    //Validacoes de erro no XML
		If oXmlL701 <> Nil .And. Empty(cError) .And. Empty(cWarning)
			If Upper(oXmlL701:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
				If oXmlL701:_TotvsMessage:_MessageInformation:_Product:_Name:Text <> Nil .And.;
				   !Empty(oXmlL701:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
				
					cMarca := oXmlL701:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				EndIf
			   	
				If oXmlL701:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text <> Nil .And.;
				   !Empty(oXmlL701:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text <> Nil)

                    cValInt := oXmlL701:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
				EndIf
			   	
				If oXmlL701:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text <> Nil .And.;
				   !Empty(oXmlL701:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text <> Nil)
				
					cValExt := oXmlL701:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
				EndIf
		   	
		   	    //Altera informacoes para cancelamento		   	
				lCancVen := LjiVendCanc()
	
			    //Inclusao de Venda ativa
				If !lCancVen
					cAlias	:= "SL1"    //Tabela De-Para
					cCampo	:= "L1_DOC" //Campo De-Para

                //Inclusao Venda cancelada                    
				Else
					cAlias := "SLX"      //Tabela De-Para
					cCampo := "LX_CUPOM" //Campo De-Para
				EndIf
		   	  
				If !Empty(cValExt) .And. !Empty(cValInt)
					If CFGA070Mnt(cMarca, cAlias, cCampo, cValExt, cValInt)
						lRet := .T.
					EndIf
				Else
					lRet := .F.
				EndIf
            
            //Erro                
			Else
				If oXmlL701:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message <> Nil

       		        //Se não for array
					If ValType(oXmlL701:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) <> "A"
              	        //Transforma em array
						XmlNode2Arr(oXmlL701:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
					EndIf
	
	          	    //Percorre o array para obter os erros gerados
					For nCount := 1 To Len(oXmlL701:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
						cError := oXmlL701:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + CRLF
					Next nCount
	
					lRet 	 := .F.
					cXmlRet := cError
				EndIf
			EndIf
		EndIf

	ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
		cXmlRet := "1.000|1.001|1.002|2.000|2.001|2.002|2.003|2.004|2.005|2.006|2.007|2.009"
	EndIf

//Limpar os objetos após à execução do adapter
freeobj(oXmlL701)
																	   						   		   			  																										 															
Return {lRet, cXmlRet, "RETAILSALES"}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v1000

Rotina para processar a mensagem tipo RECEIVE e BUSINESS 
Efetua a gravacao de Vendas Varejo.            

@param   oXmlL701	Objeto contendo a mensagem (XML) 
@param   nTypeTrans	Tipo da Transacao (Envio ou Recebimento)
@param   lRet  		Indica o resultado da execução da função
@param   cXmlRet  		Mensagem Xml para envio
@param   cVersao   	Versao da mensagem

@author  Vendas Cliente      
@version P12
@since   05/01/2016
@return  Nil

/*/
//-------------------------------------------------------------------------------------------------
Static Function v1000(oXmlL701, nTypeTrans, lRet, cXmlRet, cVersao)

	Local cSerie		:= "" //Serie do cupom fiscal
	Local cDoc			:= "" //Numero do cumpo fiscal ajustado
	Local cTimeEmis	:= "" //Hora de emissao do cupom fiscal
	Local cMarca		:= "" //Armazena a Marca que enviou o XML
	Local cValExt		:= "" //Codigo externo utilizada no De/Para de codigos - Tabela XXF
	Local cValInt		:= "" //Codigo interno utilizada no De/Para de codigos - Tabela XXF
	Local cCodCli		:= "" //Codigo de Cliente
	Local cLojCli		:= "" //Loja do Cliente
	Local cEstac		:= "" //Codigo da Estacao
	Local cPdv			:= "" //Codigo do PDV
	Local cOperador	:= "" //Codigo do Operador
	Local cProduto	:= "" //Codigo do Produto
	Local cIdVendF100	:= "" //InternalId da venda para verificacao do Bloco F100
	Local cDtVendF100	:= "" //Data da venda para verificacao do Bloco F100
	Local lLjMvBf100 	:= SuperGetMV("MV_LJBF100",, .F.) //Ativa verificação bloco F100
	Local cFormaPg	:= "" //Forma de Pagamento
	Local cAdmFin		:= "" //Administradora Financeira
	Local cIdExt		:= "" //Identificacao externa do registro
	Local cTesPrd		:= "" //Tes para o produto
	Local cTpOpera	:= "" //Tipo de operacao Tes inteligente
	Local cVendedor 	:= "" //Vendedor
	Local cItem		:= "" //Item de Venda
	Local cCfop		:= "" // Campo Cfop
	Local cDataPgto  	:= "" //Data do Pagamento
	Local cTipoOrc	:= "" //Tipo do Orcamento
	Local cTipoVen	:= "V" //Tipo da Venda
	Local cSitua		:= "" //Situacao do Orcamento
	Local cSituaOrc	:= "" //Controle do Orcamento
	Local cIntIdRA	:= "" //InternalID do RA a ser compensado
	Local cL1VendTef	:= "N" //Venda Tef SL1
	Local cL1DataTef	:= "" //Data Tef SL1
	Local cL1HoraTef	:= "" //Hora Tef SL1
	Local cL1DocTef	:= "" //Documento Tef SL1
	Local cL1Autoriz	:= "" //Autorizacao Tef SL1
	Local cL1DocCanc	:= "" //Documento de Cancelamento Tef SL1
	Local cL1DatCanc	:= "" //Data de Cancelamento Tef SL1
	Local cL1HorCanc	:= "" //Hora Cancelamento Tef SL1
	Local cL1Institu	:= "" //Instituro Tef SL1
	Local cL1NsuTef	:= "" //Nsu Tef SL1
	Local cL4DataTef	:= "" //Data Tef SL4
	Local cL4DatCanc	:= "" //Data de Cancelamento Tef SL4
	Local cL4HoraTef	:= "" //Hora Tef SL4
	Local cL4HrCanTef	:= "" //Hora cancelamento Tef SL4
	Local cCpfCli		:= "" //CPF do Cliente
	Local cEvent   	:= "" //Evento
	Local cCliInt	   	:= "" //InternalId do Cliente
	Local cProdInt	:= "" //InternalId do Produto
	Local cVendInt	:= "" //InternalId do Vendedor
	Local cEstInt		:= "" //InternalId da Estacao de Trabalho
	Local cUMInt		:= "" //InternalId da Unidade de Medida
	Local cPgtoInt	:= "" //InternalId da Forma de Pagamento
	Local cLocInt		:= "" //InternalId do Local de Estoque
	Local cEmissao	:= "" //Data e hora de Emissao
	Local cDtPagto	:= "" //Data e hora do Pagamento
	Local cUniMed		:= "" //Unidade de Medida
	Local cWhere		:= "" //Condicional da query
	Local cSerSat		:= "" //Numero de Serie SAT
	Local cTpVenda	:= "" //Tipo da venda
	Local cRecRa		:= "" //Recno Titulo RA - Adiantamento hospede
	Local cTribut		:= "" //Codigo da tributacao ECF
	Local cReserva	:= "" //Codigo da Reserva do Cliente Hotel
	Local cCondPg		:= SuperGetMv("MV_CONDPAD",, "001") //Condicao de Pagamento padrao
	Local cAliasTmp 	:= GetNextAlias() //Alias temporario
	Local nI			:= 0 //Contador
	Local nX			:= 0 //Contador
	Local nMoeda		:= 0 //Moeda da Venda
	Local nOpcX		:= 0 //Opcao da integracao
	Local nVlrTot		:= 0 //Valor Total
	Local nBaseIcm	:= 0 //Valor Base ICMS
	Local nBaseIss	:= 0 //Valor Base ISS
	Local nAliqIcm 	:= 0 //Aliquota ICMS
	Local nAliqIss	:= 0 //Aliquota ISS
	Local nValDesTot 	:= 0 //Valor de Desconto no Total da Venda
	Local nPerDesTot	:= 0 //Percentua de Desconto no Total da Venda
	Local nQuant   	:= 0 //Quantidade do item
	Local nVlrUnit 	:= 0 //Valor unitario do produto
	Local nVlrItem	:= 0 //Valor Total do item
	Local nDescPro	:= 0 //Valor de Desconto Proporcional do Item
	Local nVlrLiq		:= 0 //Valor Total Liquido da Venda
	Local nSL1Icms	:= 0 //Valor de ICMS na SL1
	Local nSL1Iss		:= 0 //Valor de ISS na SL1
	Local nSL1Pis		:= 0 //Valor de PIS na SL1
	Local nSL1Cof		:= 0 //Valor de COFINS na SL1
	Local nSL2Icms	:= 0 //Valor de ICMS na SL2
	Local nSL2Iss		:= 0 //Valor de ISS na SL2
	Local nBasPisRet	:= 0 //Base Pis Retencao
	Local nAlqPisRet	:= 0 //Aliquota Pis Retencao
	Local nSL2PisRet	:= 0 //Valor PIS Retencao
	Local nBasPisApu	:= 0 //Base Pis Apuracao
	Local nAlqPisApu	:= 0 //Aliquota Pis Apuracao
	Local nSL2PisApu 	:= 0 //Valor de PIS na SL2
	Local nBasCofRet	:= 0 //Base Cofins Retencao
	Local nAlqCofRet	:= 0 //Aliquota Cofins Retencao
	Local nSL2CofRet	:= 0 //Valor Cofins Retencao
	Local nBasCofApu	:= 0 //Base Cofins Apuracao
	Local nAlqCofApu	:= 0 //Aliquota Cofins Apuracao
	Local nSL2CofApu 	:= 0 //Valor de Cofins na Apuracao
	Local nItemTef	:= 0 //Numero parcela Tef
	Local nPerComis	:= 0 //Percentual da Comissao do Vendedor
	Local nValComis	:= 0 //Valor da Comissao do Vendedor
	Local nPerItDesc	:= 0 //Percentual de Desconto no Item
	Local nVlAcrsIt	:= 0 //Valor de Acrescimo no Item
	Local nValItDesc 	:= 0 //Valor de Desconto no Item
	Local nAliqRed	:= 0 //Aliquota reducao ICMS
	Local dDataBkp	:= dDataBase //Backup de Database
	Local aArea 		:= GetArea() //Salva a area atual
	Local aAreas		:= {} //Array com areas das tabelas
	Local aCab   		:= {} //Array do Cabeçalho da Venda
	Local aItem  		:= {} //Array dos Itens da Venda
	Local aParcela	:= {} //Array das Parcelas da Venda
	Local aErroAuto	:= {} //Logs de erro do ExecAuto
	Local aAux			:= {} //Array Auxiliar para armazenar Internald
	Local aInternal	:= {} //Array Auxiliar para armazenas InternalId gerado no Protheus
	Local aItensCanc	:= {} //Array contendo os itens cancelados
	Local oXmlContent	:= Nil //Objeto Xml com o conteudo da BusinessContent apenas
	Local lRps 		:= .F. //Flag RPS
	Local lNfce		:= .F. //Flag NFCe
	Local lTef			:= .F. //Flag Tef
	Local lCupCancel 	:= .F. //Flag de Venda cancelada
	Local lItCancel 	:= .F. //Flag de Item cancelado
	Local lCancVen   	:= .F. //Flag cancelamento de venda
	Local dDataPagto	:= dDataBase //Data de Pagamento
	Local cCancItem	:= ""   //Trata gravacao de itens cancelados
	Local cCancVen	:= ""   //Trata gravacao de venda cancelada
	Local lCancItem  	:= .F.  //Trata gravacao de itens cancelados
	Local aCancItem	:= {}	//Trata gravacao de itens cancelados
	Local nS			:= 0	//Trata gravacao de itens cancelados
	Local nSL2CSLL	:= 0	//Trata CSLL Retencao
	Local nBaseCSLL	:= 0	//Trata CSLL Retencao
	Local nAliqCSLL 	:= 0	//Trata CSLL Retencao
	Local nSL2IRRF	:= 0	//Trata valor IRRF
	Local nBaseIRRF	:= 0	//Trata base IRRF
	Local nAliqIRRF 	:= 0	//Trata aliquota IRRF
	Local nSL1CSLL	:= 0	//Trata CSLL
	Local nSL1IRRF	:= 0	//Trata IRRF
	Local nTroco		:= 0 	//Valor de troco
	Local nVlrItTot 	:= 0 	//Acumulado valor item
	Local nPosDescPro	:= 0 	//Posicao do campo Desconto Proporcional
	Local nVlMercTot	:= 0	//Valor Total das Mercadorias
	Local nVlrMercIt	:= 0 	//Valor Total das Mercadorias somadas nos itens
	Local nImpFed 	:= 0	//Imposto Federal
	Local nImpEst 	:= 0	//Imposto Estadual
	Local nImpMun 	:= 0 	//Imposto Municipal
	Local nImpFedSL1 	:= 0	//Imposto Federal	SL1
	Local nImpEstSL1 	:= 0	//Imposto Estadual SL1
	Local nImpMunSL1 	:= 0	//Imposto Municipal SL1
	Local cTaxSource 	:= ""	//Fonte do Imposto
	Local lReserva   	:= .F.
	Local cDataIn    	:= ""
	Local cTipoUH 	:= ""
	Local cNumUH 		:= ""
	Local cHospede 	:= ""
	Local cOutrosHsp 	:= ""
	Local cGrupoRsv 	:= ""
	Local cEventoRsv 	:= ""
	Local cLanctos 	:= ""
	Local aItemMh4 	:= {}  //Itens reserva
	Local lNfe		 	:= .F. //Flag NFE
	Local lNfm			:= .F. //Flag NFM
	Local cTipoNF  	:= SuperGetMV("MV_TPNRNFS",, "1") //Tipo numeracao Nota Fiscal
	Local cFormaId 	:= "" //Id Forma Pagamento CC
	Local cNsu		 	:= "" //Codigo NSU
	Local nPosNsu	 	:= 0 //Posicao campo NSU
	Local nFormaId 	:= 0 //Numero Forma de Pagamento
	Local cChaveNFCe 	:= "" //Chave NFCe
	Local cProtoNFCe 	:= "" //Protocolo NFCe
	Local cRateio 	:= "" //Rateio de servicos
	Local cCCusto		:= SuperGetMv("MV_HTLCCRT",, "") //Centro de Custo
	Local cEntidade 	:= "" //Entidade
	Local cPercent	:= "" //Percentual rateio
	Local nPercent	:= 0 //Percentual numerico rateio
	Local lMultiNat 	:= SuperGetMV("MV_MULNATR",, .F.) //Ativa funcionalidade de MultiNatureza
	Local cArmazem	:= "" //Armazem Padrao
	Local cIdLoja		:= "" //Identificacao da loja
	Local cLjClvl 	:= "" //Classe Valor
	Local cLjItemCC  	:= "" //Item Centro de Custo
	Local cLjCCusto  	:= "" //Centro de Custo
	Local cSerieSat	:= "" //Codigo Serie Sat
	Local lIntegHtl	:= SuperGetMv("MV_INTHTL",, .F.) //Integracao Hotelaria
	Local aCaixa		:= {} //Codigo do Caixa Protheus
	
	Private lMsHelpAuto 		:= .T. //Variavel de controle interno do ExecAuto
	Private lMsErroAuto 		:= .F. //Variavel que informa a ocorrência de erros no ExecAuto
	Private lAutoErrNoFile 	:= .T. //força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário
	Private Inclui 			:= .T. //Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
	Private Altera 			:= .F. //Variavel necessária para o ExecAuto identificar que se trata de uma inclusão

    //Armazena areas das Tabelas
	aAdd(aAreas, SA1->(GetArea()))
	aAdd(aAreas, SAE->(GetArea()))
	aAdd(aAreas, SB0->(GetArea()))
	aAdd(aAreas, SB1->(GetArea()))
	aAdd(aAreas, SLF->(GetArea()))
	aAdd(aAreas, SLG->(GetArea()))
	aAdd(aAreas, SL1->(GetArea()))
	aAdd(aAreas, SL2->(GetArea()))
	aAdd(aAreas, SL4->(GetArea()))
	aAdd(aAreas, SLX->(GetArea()))

	SL2->(dbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
	SL4->(dbSetOrder(1)) //L4_FILIAL+L4_NUM+L4_ORIGEM
	SLX->(dbSetOrder(1)) //LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM+LX_HORA

    LjGrvLog(" LOJI701 ", "Inicio do processamento da função: V1000 " + FwTimeStamp(2))

    //Mensagem de Recebimento
	If nTypeTrans == TRANS_RECEIVE
	//------------------------------------------------------------
	//Tratamento utilizando a tabela XXF com um De/Para de codigos
	//------------------------------------------------------------                   		   		                                                           		
		If FindFunction("CFGA070INT")
   		//Valida Estado de Cobranca da filial
			If Empty(SM0->M0_ESTCOB)
				lRet    := .F.
				cXMLRet := STR0059 + Chr(10) + STR0060 //#"Foi detectado que o campo referente ao estado de cobranca(M0_ESTCOB) nao esta configurado." ##"Efetue a inclusao no cadastro de filiais no Protheus."
			EndIf
   		
			If lRet
			//Marca
				If oXmlL701:_TotvsMessage:_MessageInformation:_Product:_Name:Text <> Nil .And. !Empty(oXmlL701:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
					cMarca := oXmlL701:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				EndIf
			
				If Empty(cMarca)
					lRet    := .F.
					cXMLRet := STR0004 //#"Marca nao integrada ao Protheus, verificar a marca da integracao"
				EndIf
			EndIf
			
			If lRet
				If oXmlL701:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text <> Nil .And. !Empty(oXmlL701:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
					If AllTrim(Upper(oXmlL701:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)) == "DELETE"
						lRet    := .F.
						cXMLRet := STR0081 //#"Evento incorreto, para exclusao utilize a integracao de Cancelamento de Venda."
					EndIf
				Else
					lRet    := .F.
					cXMLRet := STR0082 //#"Evento nao informado!"
				EndIf
			EndIf
			
			If lRet
			//Gera objeto para carga de Vendas    	
				oXmlContent := oXmlL701:_TOTVSMessage:_BusinessMessage:_BusinessContent
			
			//Armazena chave externa
				cIdExt := LjiVldTag(oXmlContent, "_INTERNALID")
			
				If Empty(cIdExt)
					lRet	 := .F.
					cXmlRet := STR0021 //#"Campo obrigatorio nao informado: Id Interno, verifique a tag: InternalId."
				EndIf
			EndIf
		
			If lRet
			//Verifica evento inclusao ou alteracao
				aAux := IntVendInt(cIdExt, cMarca)
          		
          	//Se encontrou o cupom no de-para
				If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
					nOpcX := 2 //Alteracao
				Else
					nOpcX := 3 //Inclusao
				EndIf
									
			//Evento Inclusao
				If 	nOpcX == 3
					cCancVen := LjiVldTag(oXmlContent, "_ISCANCELED") //Trata gravacao de venda cancelada
					lCancVen := IIf(cCancVen == "true",.T.,.F.) //Trata gravacao de venda cancelada
				
				//Para venda cancelada, altera controle de orcamento para que venda seja cancelada apos ser processada
					If lCancVen
						cSituaOrc := "E"
					EndIf
														
					cTpVenda := AllTrim(Upper(LjiVldTag(oXmlContent, "_KINDOFDOCUMENT"))) //Tipo do documento
				
					If Empty(cTpVenda)
						lRet 	 := .F.
						cXmlRet := STR0097 //#"Tipo de venda nao informada, verifique a tag: KindOfDocument"
					Else
						If cTpVenda == "NFCE"
							lNfce := .T.
						ElseIf cTpVenda == "NFM"
							lNfm := .T.
						ElseIf cTpVenda == "NFE"
							lNfe := .T.
						ElseIf cTpVenda == "RPS"
							lRps := .T.
						EndIf
					
					//Nota Fiscal Manual, NFe ou RPS, obrigatorio informar Serie
						If lNfm .Or. lNfe .Or. lRps
						//Armazena a Serie informada na integracao			
							cSerie := Padr(LjiVldTag(oXmlContent, "_SERIECODE"), TamSx3("L1_SERIE")[1])
						
						//Validacao da Serie
							If Empty(cSerie)
								lRet 	 := .F.
								cXmlRet := STR0076 //"Serie nao informada na integracao, informacao obrigatoria para Nota Manual ou NFE, verifique a tag: SerieCode"
							EndIf
						EndIf
					EndIf
			
					If lRet
						If lNfe .AND. Empty(AllTrim(Upper(LjiVldTag(oXmlContent, "_KEYACESSNFE")))) //Gera Numeracao quando nao existir Chave
							If AllTrim(cTipoNF) == "3"
								cDoc := MA461NumNf(.T., cSerie)
							Else
								cDoc := NxtSX5Nota(cSerie, .T., cTipoNF)
							EndIf
						Else
							cDoc := Padr(LjiVldTag(oXmlContent, "_DOCUMENTCODE"), TamSx3("L1_DOC")[1])
						EndIf
					
					//Validacao da Doc							
						If Empty(cDoc)
							lRet 	 := .F.
							cXmlRet := STR0006 //#"Cupom nao informado, verificar a tag: DocumentCode"
						Else
						//Tratamento tamanho Doc
							If lRps .Or. lNfce .Or. lNfe
								cDoc := StrZero(Val(cDoc), TamSx3("LQ_DOC")[1])
							Else
								cDoc := StrZero(Val(cDoc), 6)
							EndIf
							
							cDoc := Padr(cDoc, TamSx3("LQ_DOC")[1])
						EndIf
					EndIf
         
					If lRet
						If lRps .Or. lNfe .Or. lNfm	//Rps/Nfe/Nota Manual
							cTipoOrc  	:= ""
							cTipoVen  	:= "V"
							cPdv 		:= "001"
							
							If !Empty(AllTrim(Upper(LjiVldTag(oXmlContent, "_KEYACESSNFE"))))
								cChaveNFCe := LjiVldTag(oXmlContent, "_KEYACESSNFE") //Chave NFCe
								cProtoNFCe := LjiVldTag(oXmlContent, "_NFCEPROTOCOL") //Protocolo NFCe
							Endif
						Else //Cupom/NFCe/Sat
						//Armazena Estacao																					
							cEstac := Padr(LjiVldTag(oXmlContent, "_STATIONCODE"), TamSx3("LG_CODIGO")[1])
										
						//Valida Estacao
							If Empty(cEstac)
								lRet 	 := .F.
								cXmlRet := STR0005 //#"Estacao nao informada na integracao, verifique a Tag StationCode"
							Else
							//Posiciona na Estacao do Protheus
								SLG->(dbSetOrder(1))
					
								If !SLG->(dbSeek(xFilial("SLG") + cEstac))
									lRet 	 := .F.
									cXmlRet := STR0011 + " " + cEstac + " " + STR0026 //#"Estacao:" ##"nao encontrada no Protheus, verificar o cadastro ou integracao de Estacao."
								Else
								//Armazena Estacao
									cEstacao := cEstac
							
								//Inicializa a Serie
									cSerie	:= SLG->LG_SERIE
														
								//Pdv
									cPdv := SLG->LG_PDV
																								
									If lNfce
										cTipoOrc  := "E"
										cTipoVen  := ""
									
										cChaveNFCe := LjiVldTag(oXmlContent, "_KEYACESSNFE") //Chave NFCe
										cProtoNFCe := LjiVldTag(oXmlContent, "_NFCEPROTOCOL") //Protocolo NFCe
									Else
										cTipoOrc  := ""
										cTipoVen  := "V"
									EndIf
								
								//Validacoes
									If Empty(cSerie)
										lRet 	 := .F.
										cXmlRet := STR0077 //"Serie nao cadastrada, verifique o campo Serie do Cadastro de Estacoes no Protheus"
									ElseIf lNfce .And. Empty(cChaveNFCe)
										lRet 	 := .F.
										cXmlRet := STR0094 //#"Chave NFCe nao enviada, informacao obrigatoria para venda NFCe, verifique a tag KeyAcessNfe"
									ElseIf lNfce .And. Empty(cProtoNFCe)
										lRet 	 := .F.
										cXmlRet := STR0095 //#"Protocolo NFCe nao enviado, informacao obrigatoria para venda NFCe, verifique a tag NfceProtocol"
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
								         		
					If lRet
					//De-Para Cliente
						cValExt := LjiVldTag(oXmlContent, "_CUSTOMERVENDORINTERNALID")
			
						If !Empty(cValExt)
							aAux := IntCliInt(cValExt, cMarca)
		          		
		          		//Se encontrou o cliente no de-para
							If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
								cCodCli := PadR(aAux[2][3], TamSX3("A1_COD")[1])
								cLojCli := PadR(aAux[2][4], TamSX3("A1_LOJA")[1])
							Else
								lRet := .F.
								cXmlRet := STR0007 + " " + AllTrim(cValExt) + " " + STR0008 //#"Cliente: " ##"nao integrado ao Protheus, verificar integracao de clientes"
							EndIf
						Else //Utiliza cliente padrao
							cCodCli := Padr(SuperGetMv("MV_CLIPAD",, "000001"), TamSX3("A1_COD")[1])
							cLojCli := Padr(SuperGetMv("MV_LOJAPAD",, "01"), TamSX3("A1_LOJA")[1])
						EndIf
					EndIf
     	          	
					If lRet
		          	//Posiciona no cliente do Protheus
						SA1->(dbSetOrder(1))
		          	
						If !SA1->(dbSeek(xFilial("SA1") + cCodCli + cLojCli))
							lRet := .F.
							cXmlRet := STR0007 + " " + AllTrim(cCodCli) + "/" + STR0017 + " " + cLojCli + " " + STR0019 //#"Cliente:" ##"Loja:"###"nao cadastrado no Protheus, verifique o cadastro de clientes."
						EndIf
					
						If lRet
						//Verifica se Cliente esta bloqueado
							If SA1->A1_MSBLQL == "1"
								lRet := .F.
								cXmlRet := STR0007 + " " + AllTrim(cCodCli) + "/" + STR0017 + " " + cLojCli + " " + STR0075 //#"Cliente:" ##"Loja:"###"bloqueado, verifique o Cadastro de Clientes no Protheus."
							EndIf
						
							If lRet
								//Cpf do Cliente, utilizado caso deseja CPF na Nota			
								cCpfCli := LjiVldTag(oXmlContent, "_PERSONALIDENTIFICATION")
							
								//Armazena Operador
								cOperador := LjiVldTag(oXmlContent, "_OPERATORCODE")
								
								//Valida Operador	
								If Empty(cOperador)
									lRet 	 := .F.
									cXmlRet := STR0018 //#"Operador nao informado na integracao, verifique a Tag OperatorCode"
								EndIf
							
							//------------------------------------------------------------
							//Tratamento utilizando a tabela XXF com um De/Para de codigos
							//Necessário enquanto não for concluído o Adapter para Msg
							//Unica para cadastro dos caixas. 
							//------------------------------------------------------------ 			
								aCaixa := Separa(CFGA070Int(cMarca, "SLF", "LF_COD", cOperador),"|")
		
								If lRet .and. Len(aCaixa) > 0
									cOperador := aCaixa[3]
									//Posiciona no Operador do Protheus
									SLF->(dbSetOrder(1))
									
									If !SLF->(dbSeek(xFilial("SLF") + cOperador))
										lRet 	 := .F.
										cXmlRet := STR0009 + " " + cOperador + " " + STR0010 + " " + STR0121//#"Operador:" ##"nao integrado ao Protheus, verificar integracao de operador " verificar se o operador esta cadastrado na filial destino correta.
									EndIf
								Else
									lRet 	 := .F.
									cXmlRet := STR0009 + " " + cOperador + STR0120 + CFGA070Int(cMarca, "SLF", "LF_COD", cOperador) + ". " + STR0121  //#"Operador:" ##"nao encontrado no De/Para " " verificar se o operador esta cadastrado na filial destino correta.
								
								EndIf
							EndIf
						EndIf
					EndIf

					If lRet
					//Data de Emissao
						cEmissao := LjiVldTag(oXmlContent, "_ISSUEDATEDOCUMENT", "D")
					
						If Empty(cEmissao)
							lRet 	 := .F.
							cXmlRet := STR0020 //#"Campo obrigatorio nao informado: Data de Emissao, verifique a tag: IssueDateDocument."
						EndIf
					
						If lRet
							cTimeEmis := LjiVldTag(oXmlContent, "_ISSUEDATEDOCUMENT", "T")
																										
						//Validacoes de campos obrigatorios															
							If XmlChildEx(oXmlContent, "_TOTALPRICE") == Nil .Or. Empty(oXmlContent:_TotalPrice:Text)
								lRet 	 := .F.
								cXmlRet := STR0027 //#"Campo obrigatorio nao informado: Valor Total da Venda, verifique a tag: TotalPrice."
							ElseIf XmlChildEx(oXmlContent, "_NETPRICE") == Nil .Or. Empty(oXmlContent:_NetPrice:Text)
								lRet 	 := .F.
								cXmlRet := STR0028 //#"Campo obrigatorio nao informado: Valor Liquido da Venda, verifique a tag: NetPrice."
							ElseIf XmlChildEx(oXmlContent, "_GROSSPRICE") == Nil .Or. Empty(oXmlContent:_GrossPrice:Text)
								lRet 	 := .F.
								cXmlRet := STR0029 //#"Campo obrigatorio nao informado: Valor Bruto da Venda, verifique a tag: GrossPrice."
							EndIf
						
							If lRet
								If lIntegHtl //Hotelaria
								//Grava informações de reserva que serão utilizadas para as descrições de serviços na NFS-e (Integração com hotelaria)
									If XmlChildEx(oXmlContent, "_BOOKINGINFORMATION") <> Nil
										lReserva 	:= .T.
										cReserva 	:= LjiVldTag( oXmlContent:_BookingInformation, "_HOTELACCOUNTCODE", "C" ) //Numero da Reserva
										cDataIn  	:= LjiVldTag( oXmlContent:_BookingInformation, "_CHECKINDATE", "D" ) //Data de checkin da reserva
										cTipoUH  	:= LjiVldTag( oXmlContent:_BookingInformation, "_HABITATIONALUNITTYPE", "C" ) //Tipo de unidade habitacional
										cNumUH   	:= LjiVldTag( oXmlContent:_BookingInformation, "_HABITATIONALUNITNUMBER", "C" ) //Número da unidade habitacional
										cHospede 	:= LjiVldTag( oXmlContent:_BookingInformation, "_MAINGUESTNAME", "C" ) //Nome do hóspede principal
										cOutrosHsp	:= LjiVldTag( oXmlContent:_BookingInformation, "_ADDITIONALGUESTNAME", "C" ) //Nome dos demais hóspedes
										cGrupoRsv 	:= LjiVldTag( oXmlContent:_BookingInformation, "_GROUPNAME", "C" ) //Nome do grupo da reserva
										cEventoRsv	:= LjiVldTag( oXmlContent:_BookingInformation, "_EVENTNAME", "C" ) //Nome do evento da reserva
									EndIf
								EndIf
																									
							//Valor de Comissao do Vendedor
								nPerComis := Val(LjiVldTag(oXmlContent, "_COMMISSIONPERCENT", "N"))
						
							//De-Para Fornecedor
								cValExt := LjiVldTag(oXmlContent, "_SELLERINTERNALID")
										
								If !Empty(cValExt)
									cVendedor := CFGA070INT(cMarca, "SA3", "A3_COD", cValExt)
								
								//Separa o retorno 
									aAux := Separa(cVendedor, "|")
								
								//Verifica se encontrou vendedor no De/Para
									If ValType(aAux) == "A" .And. Len(aAux) >= 3
										cVendedor := PadR(aAux[3], TamSX3("A3_COD")[1])
									Else
										lRet 	 := .F.
										cXmlRet :=  STR0079 + " " + AllTrim(cValExt) + " " + STR0080 //#"Vendedor:" ##"nao integrado no Protheus, verifique a integracao de Vendedores."
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
							
					If lRet
					//Validacao do Vendedor				          		          		          		          		          		          		          		
						If Empty(cVendedor)
						//Se venda possui comissao, deve informar o vendedor          	 
							If nPerComis > 0
								lRet := .F.
								cXmlRet := STR0078 //#"Vendedor nao informado, obrigatorio para venda com comissao, verifique a tag: SellerInternalId."
							Else
								cVendedor := SuperGetMv("MV_VENDPAD",, "000001")
							EndIf
						EndIf
		          	 
						If lRet
						//Armazena Valor Total da Venda
							nVlrTot    := Val(StrTran(oXmlContent:_TotalPrice:Text, ",", "."))
							nVlrLiq    := Val(StrTran(oXmlContent:_NetPrice:Text, ",", "."))
							nVlMercTot := Val(LjiVldTag(oXmlContent, "_COMMODITYPRICE", "N"))
						
						//Armazena Desconto no Total da Venda
							nValDesTot := Val(LjiVldTag(oXmlContent, "_DISCOUNTVALUE", "N"))
							nPerDesTot := Val(LjiVldTag(oXmlContent, "_DISCOUNTPERCENT", "N"))
						
							If lIntegHtl //Hotelaria
							//Armazena informacoes de rateio						
								cRateio  := "" //Inicializa variavel de rateio
								nPercent := 0 //Inicializa percentual de rateio
							
								If	XmlChildEx(oXmlContent, "_LISTOFFINANCIALNATUREAPPORTIONMENT") <> Nil .And.;
										XmlChildEx(oXmlContent:_ListOfFinancialNatureApportionment, "_FINANCIALNATUREAPPORTIONMENT") <> Nil
									If lRps
										If lMultiNat
										//Monta Array com Rateio	            					
											If ValType(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment) <> "A"
												XmlNode2Arr(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment, "_FinancialNatureApportionment")
											EndIf
									
											For nI := 1 To Len(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment)
												If	XmlChildEx(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI], "_LISTOFCOSTCENTERAPPORTIONMENT") <> Nil .And.;
														XmlChildEx(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment, "_COSTCENTERAPPORTIONMENT") <> Nil
												
												//Monta array com Entidades de rateio
													If ValType(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment) <> "A"
														XmlNode2Arr(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment, "_CostCenterApportionment")
													EndIf
												
													For nX := 1 To Len(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment)
														If lRet
														//Centro de Custo										 														  																																																														
															If Empty(cCCusto)
																lRet 	 := .F.
																cXmlRet := STR0101 //#"Centro de Custo nao informado, obrigatorio quando utilizado rateio, verifique no Protheus o parametro: MV_HTLCCRT"
																Exit
															EndIf
														
														//Entidade
															cValExt := LjiVldTag(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment[nX], "_GENERICENTITYINTERNALID")
															aAux := IntGerInt(cValExt, cMarca,  "1.000")
														
															cEntidade := "" //Inicializa entidade
														
															If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
																cEntidade := PadR(aAux[2][4], TamSX3("EZ_EC05DB")[1])
															EndIf
														
															If Empty(cEntidade)
																lRet 	 := .F.
																cXmlRet := STR0098 //#"Entidade nao informada ou nao integrada ao Protheus para rateio, verifique a lista: ListOfFinancialNatureApportionment, tag: GenericEntityInternalId."
																Exit
															EndIf
														
															cPercent := LjiVldTag(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment[nX], "_PERCENTAGE", "N")
													
														//Valida se percentual foi enviado
															If Empty(cPercent)
																lRet 	 := .F.
																cXmlRet := STR0099 //#"Percentual de rateio nao informado no rateio, verifique a lista: ListOfFinancialNatureApportionment, tag: Percentage."
																Exit
															EndIf
													
															cRateio += "#"
															cRateio += "*" + cCCusto //Centro de Custo
															cRateio += "*" + cEntidade //Entidade
															cRateio += "*" + cPercent //Percentual
													
															nPercent += Val(cPercent)
														EndIf
													Next nX
												EndIf
											Next nI
										Else
											lRet 	 := .F.
											cXmlRet := STR0102 + "," + STR0103 //#"Para utilizar informacoes de rateio tag: ListOfFinancialNatureApportionment" ##"é necessário habilitar o parametro MV_MULNATR no Protheus."
										EndIf
									Else
										lRet 	 := .F.
										cXmlRet := STR0104 + "," + STR0105 //#"Esta mensagem possui informacoes de rateio tag: ListOfFinancialNatureApportionment mas nao é uma RPS"##"verifique a tag: KindOfDocument."
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
												
					If lRet
					//Armazena impostos do Cabecalho da Venda
						If	XmlChildEx(oXmlContent, "_LISTOFTAXES") <> Nil .And.;
								XmlChildEx(oXmlContent:_ListOfTaxes, "_TAX") <> Nil
						
						//Monta Array com Impostos	            					
							If ValType(oXmlContent:_ListOfTaxes:_Tax) <> "A"
								XmlNode2Arr(oXmlContent:_ListOfTaxes:_Tax, "_Tax")
							EndIf
						
							For nI := 1 To Len(oXmlContent:_ListOfTaxes:_Tax)
								Do Case
								Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) == "ICM" //Icms
									nSL1Icms += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
								Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) == "ISS" //Iss
									nSL1Iss += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
								Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) == "PIS" //Pis
									nSL1Pis += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
								Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) == "COFINS" //Cofins
									nSL1Cof += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
								Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) == "CSLL" //CSLL
									nSL1CSLL += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
								Case "IRRF" $ AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) //IRRF
									nSL1IRRF += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
								EndCase
							Next nI
						EndIf
					EndIf
															
					If lRet
						nTroco := Val(LjiVldTag(oXmlContent, "_CHANGE", "N")) //Armazena valor de troco
	
					//Lei de Transparencia 
						If	XmlChildEx(oXmlContent, "_STATETAXBURDEN") <> Nil
							nImpEstSL1 := Val(LjiVldTag(oXmlContent,  "_STATETAXBURDEN", "N"))
						EndIf
						If	XmlChildEx(oXmlContent, "_MUNICIPALTAXBURDEN") <> Nil
							nImpMunSL1 := Val(LjiVldTag(oXmlContent,  "_MUNICIPALTAXBURDEN", "N"))
						EndIf
						If	XmlChildEx(oXmlContent, "_FEDERALTAXBURDEN") <> Nil
							nImpFedSL1 := Val(LjiVldTag(oXmlContent,  "_FEDERALTAXBURDEN", "N"))
						EndIf
						If	XmlChildEx(oXmlContent, "_TAXSOURCE") <> Nil
							cTaxSource := LjiVldTag(oXmlContent,  "_TAXSOURCE", "C")
						EndIf
										
						cSerieSat  := LjiVldTag(oXmlContent, "_SERIALNUMBERSATEQUIPAMENT") //Serie Sat
															
						/* Efetua a carga das tabela SLQ */
											
					//Alimenta array cabeçalho da venda											   				   				   				   		   		           	                 
						aCab := {	{"LQ_VEND"  	, cVendedor														, Nil},;
							{"LQ_COMIS" 	, nPerComis														, Nil},;
							{"LQ_VALCOMI" , 0																	, Nil},;
							{"LQ_CLIENTE" , cCodCli	    													, Nil},;
							{"LQ_LOJA"  	, cLojCli		   													, Nil},;
							{"LQ_TIPOCLI" , SA1->A1_TIPO						          					, Nil},;
							{"LQ_VLRTOT"  , nVlrTot															, Nil},;
							{"LQ_DESCONT" , nValDesTot														, Nil},;
							{"LQ_VLRLIQ"  , nVlrLiq															, Nil},;
							{"LQ_DTLIM"  	, dDatabase 														, Nil},;
							{"LQ_DINHEIR" , Val(LjiVldTag(oXmlContent, "_CASHVALUE", "N"))				, Nil},;
							{"LQ_CHEQUES"	, Val(LjiVldTag(oXmlContent, "_CHECKSVALUE", "N"))			, Nil},;
							{"LQ_CARTAO"	, Val(LjiVldTag(oXmlContent, "_CARDSVALUE", "N"))			, Nil},;
							{"LQ_VLRDEBI"	, Val(LjiVldTag(oXmlContent, "_DEBITVALUE", "N"))			, Nil},;
							{"LQ_CONVENI"	, Val(LjiVldTag(oXmlContent, "_COVENANTVALUE", "N"))			, Nil},;
							{"LQ_VALES"	, Val(LjiVldTag(oXmlContent, "_VOUCHERSVALUE", "N"))			, Nil},;
							{"LQ_FINANC"	, Val(LjiVldTag(oXmlContent, "_FINANCEDVALUE", "N"))			, Nil},;
							{"LQ_OUTROS"	, Val(LjiVldTag(oXmlContent, "_OTHERSVALUE", "N"))			, Nil},;
							{"LQ_ENTRADA"	, Val(LjiVldTag(oXmlContent, "_INPUTVALUE", "N"))			, Nil},;
							{"LQ_EMISSAO" , SToD(cEmissao)   												, Nil},;
							{"LQ_NUMCFIS" , IIF(lRps, "", cDoc)											, Nil},;
							{"LQ_HORA"  	, cTimeEmis														, Nil},;
							{"LQ_DOC"		, cDoc																, Nil},;
							{"LQ_SERIE"	, cSerie  															, Nil},;
							{"LQ_PDV"		, cPdv																, Nil},;
							{"LQ_EMISNF"	, SToD(cEmissao)													, Nil},;
							{"LQ_VALBRUT"	, Val(StrTran(oXmlContent:_GrossPrice:Text, ",", "."))  	, Nil},;
							{"LQ_VALMERC"	, IIF(nVlMercTot > 0, nVlMercTot, nVlrTot)					, Nil},;
							{"LQ_TIPO"		, cTipoVen															, Nil},;
							{"LQ_TIPORC"	, cTipoOrc															, Nil},;
							{"LQ_DESCNF"	, nPerDesTot														, Nil},;
							{"LQ_OPERADO"	, cOperador  														, Nil},;
							{"LQ_SITUA"	, cSitua   														, Nil},;
							{"LQ_STORC"	, cSituaOrc  														, Nil},;
							{"LQ_VALICM"	, nSL1Icms															, Nil},;
							{"LQ_VALISS"	, nSL1Iss															, Nil},;
							{"LQ_TXMOEDA"	, Val(LjiVldTag(oXmlContent, "_CURRENCYRATE", "N"))			, Nil},;
							{"LQ_MOEDA"	, nMoeda								   							, Nil},;
							{"LQ_TROCO1"	, nTroco															, Nil},;
							{"LQ_ESTACAO"	, cEstac   														, Nil},;
							{"LQ_DOCRPS"	, IIF(lRps, cDoc, "")											, Nil},;
							{"LQ_SERRPS"	, IIF(lRps, cSerie, "")											, Nil},;
							{"LQ_DOCPED"	, ""   															, Nil},;
							{"LQ_SERPED"	, ""   															, Nil},;
							{"LQ_CONDPG"	, cCondPg   														, Nil},;
							{"LQ_ESPECIE"	, cTpVenda															, Nil},;
							{"LQ_DESCFIN"	, Val(LjiVldTag(oXmlContent, "_DISCOUNTPAYMENTTERM", "N"))	, Nil},;
							{"LQ_ICMSRET"	, Val(LjiVldTag(oXmlContent, "_ICMSRETAINED", "N"))			, Nil},;
							{"LQ_CREDITO"	, Val(LjiVldTag(oXmlContent, "_CREDITVALUE", "N"))			, Nil},;
							{"LQ_ORIGEM"	, "N"																, Nil},;
							{"LQ_VENDTEF"	, ""																, Nil},;
							{"LQ_DATATEF"	, ""																, Nil},;
							{"LQ_HORATEF"	, ""																, Nil},;
							{"LQ_DOCTEF"	, ""																, Nil},;
							{"LQ_AUTORIZ"	, ""																, Nil},;
							{"LQ_DOCCANC"	, ""																, Nil},;
							{"LQ_DATCANC"	, ""																, Nil},;
							{"LQ_HORCANC"	, ""																, Nil},;
							{"LQ_INSTITU"	, ""																, Nil},;
							{"LQ_NSUTEF"	, ""																, Nil},;
							{"LQ_VALPIS"	, nSL1Pis															, Nil},;
							{"LQ_VALCOFI"	, nSL1Cof															, Nil},;
							{"LQ_VALCSLL"	, nSL1CSLL															, Nil},;
							{"LQ_CGCCLI"	, cCpfCli															, Nil},;
							{"LQ_DESPESA"	, Val(LjiVldTag(oXmlContent, "_INCREASEVALUE", "N"))				, Nil},;
							{"LQ_FRETE"		, Val(LjiVldTag(oXmlContent, "_FREIGHTVALUE", "N"))					, Nil},;
							{"LQ_KEYNFCE"	, cChaveNFCe														, Nil},;
							{"LQ_RESEHTL"	, cReserva							  								, Nil},;
							{"LQ_TOTFED"	, nImpFedSL1														, Nil},;
							{"LQ_TOTEST"	, nImpEstSL1														, Nil},;
							{"LQ_TOTMUN"	, nImpMunSL1														, Nil},;
							{"LQ_LTRAN"	, cTaxSource														, Nil},;
							{"LQ_VALIRRF"	, nSL1IRRF															, Nil},;
							{"LQ_RECISS"	, IIF(!Empty(SA1->A1_RECISS), SA1->A1_RECISS, "2")			, Nil},;
							{"LQ_PRONFCE"	, cProtoNFCe														, Nil},;
							{"LQ_SERSAT"	, cSerieSat														, Nil}}
					
					EndIf

					If lRet
					    //Valida se produtos foram enviados
						If	XmlChildEx(oXmlContent:_ListOfSaleItem, "_SALEITEM") == Nil
							lRet 	 := .F.
							cXmlRet := STR0030 //#"Lista de produtos vazia, verifique a lista SaleItem."
						EndIf
					
						If lRet
						//Monta Array com Itens da Venda	            					
							If ValType(oXmlContent:_ListOfSaleItem:_SaleItem) <> "A"
								XmlNode2Arr(oXmlContent:_ListOfSaleItem:_SaleItem, "_SaleItem")
							EndIf
		 			
			 			//Valida se lista esta vazia
							If Len(oXmlContent:_ListOfSaleItem:_SaleItem) == 0
								lRet 	 := .F.
								cXmlRet := STR0030 //#"Lista de produtos vazia, verifique a lista SaleItem."
							EndIf
						EndIf
					EndIf
 		
					If lRet
		 			//Monta itens da venda
						For nI := 1 To Len(oXmlContent:_ListOfSaleItem:_SaleItem)
						//De-Para Produtos
							cValExt := LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_ITEMINTERNALID")
						
							cCancItem := LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_ISCANCELED") //Trata gravacao de itens cancelados
							lCancItem := Iif(cCancItem == "true",.T.,.F.) //Trata gravacao de itens cancelados
						
							If !Empty(cValExt)
								aAux := IntProInt(cValExt, cMarca)
		          		
			          		//Se encontrou o produto no de/para
								If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
									cProduto := PadR(aAux[2][3], TamSX3("B1_COD")[1])
								Else
									lRet 	 := .F.
									cXmlRet := STR0013 + " " + AllTrim(cValExt) + " " + STR0014 //#"Produto:" ##"nao integrado ao Protheus, verificar integracao de Produto"
									Exit
								EndIf
							Else
								cProduto := Padr(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_ITEMCODE"), TamSx3("B1_COD")[1])
													
								If Empty(cProduto)
									lRet 	 := .F.
									cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0032 //#"Inconsistencia no item" ##"produto nao informado na integracao, verifique a Tag ItemCode."
									Exit
								EndIf
							EndIf
																										
						//Posiciona no produto
							SB1->(dbSetOrder(1))
						
							If !SB1->(dbSeek(xFilial("SB1") + cProduto))
								lRet 	 := .F.
								cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0033 + " " + AllTrim(cProduto) + " " + STR0034 //#"Inconsistencia no item" ##"produto:" ###"nao cadastrado no Protheus, verifique a tag: ItemCode"
								Exit
							EndIf
																																				
						//Validacoes de campos obrigatorios						
							If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_ITEMORDER") == Nil .Or.;
									Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ItemOrder:Text)
								lRet 	 := .F.
								cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0035 //#"Inconsistencia no item" ##"campo obrigatorio nao informado: Item, verifique a tag: ItemOrder."
								Exit
							ElseIf XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_QUANTITY") == Nil .Or.;
									Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_Quantity:Text)
								lRet 	 := .F.
								cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0036 //#"Inconsistencia no item" ##"campo obrigatorio nao informado: Quantidade, verifique a tag: Quantity."
								Exit
							ElseIf XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_UNITPRICE") == Nil .Or.;
									Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_UnitPrice:Text)
								lRet 	 := .F.
								cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0037 //#"Inconsistencia no item" ##"campo obrigatorio nao informado: Preco Unitario, verifique a tag: UnitPrice."
								Exit
							ElseIf XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_OPERATIONCODE") == Nil .Or.;
									Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_OperationCode:Text)
								lRet 	 := .F.
								cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0039 //#"Inconsistencia no item" ##"campo obrigatorio nao informado: CFOP, verifique a tag: OperationCode."
								Exit
							EndIf
						
							If lIntegHtl //Hotelaria
							//Validacao para impedir vendas mistas (produtos e servicos)										
								If lRps .And. !SB1->B1_TIPO $ "GE|GG|MO|SV"
									lRet 	 := .F.
									cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0090 //#"Inconsistencia no item" ##"enviado produto do tipo mercadoria em uma RPS, verifique o campo B1_TIPO no Protheus"
									Exit
								ElseIf !lRps .And. SB1->B1_TIPO $ "GE|GG|MO|SV"
									lRet 	 := .F.
									cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0091 //#"Inconsistencia no item" ##"enviado produto do tipo servico em um Cupom, verifique o campo B1_TIPO no Protheus"
									Exit
								EndIf
							
								If lReserva //Se achou o produto e é pra gravar informações de Reserva (hotelaria), então guarda a descrição dos produtos e valores para gravar o campo de lançamentos (MH3_LANCTOS)
									cLanctos += AllTrim( SB1->B1_DESC ) + " " + AllTrim( oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_UnitPrice:Text ) + "|"
								EndIf
							EndIf
													
							SX5->(dbSetOrder(1))
																		
						//Variaveis dos Itens de Venda
							cItem := StrZero(Val(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ItemOrder:Text), TamSx3("LR_ITEM")[1])
						
						//Armazena valores dos produtos
							nQuant   := Val(StrTran(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_Quantity:Text, ",", "."))
							nVlrUnit := Val(StrTran(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_UnitPrice:Text, ",", "."))
																										
						//Armazena valor do item
							nVlrItem := nVlrUnit * nQuant
																		
							If !lCancItem //Tratamento para recebimento de itens cancelados
							//Verifica se houve desconto no total da venda e efetua o rateio nos itens
								nDescPro := 0
											
								If nPerDesTot > 0 .Or. nValDesTot > 0
								//Calcula o Percentual do Desconto no Total da venda
									If nPerDesTot == 0
										nPerDesTot := (nValDesTot * 100) / nVlMercTot
									EndIf
								
									nDescPro := (nVlrItem / 100) * 	nPerDesTot
								EndIf
							EndIf
												
						//Verifica se item diaria para calcular comissao
							If nPerComis > 0
								If AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_LODGING"))) == "S"
									nValComis += (nVlrItem / 100) * nPerComis
								EndIf
							EndIf
						
							If	XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_LISTOFTAXES") <> Nil .And.;
									XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes, "_TAX") <> Nil
							
							//Monta Array com Impostos	            					
								If ValType(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax) <> "A"
									XmlNode2Arr(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax, "_Tax")
								EndIf
							
								For nX := 1 To Len(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax)
									Do Case
									Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) == "ICM" //ICMS
										nSL2Icms := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
										nBaseIcm := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
										nAliqIcm := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
										nAliqRed := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_REDUCTIONBASEPERCENT", "N")) //Aliquota Reducao de Base ICMS
										
										If nAliqRed > 0
											nAliqRed := Round(100 - nAliqRed, TamSx3("L2_PREDIC")[2]) //Base Reducao ICMS
										EndIf
										
										//Gera Codigo de Tributacao, sempre sera enviado quando tributado
										cTribut := "T" + PadL(CValToChar(nAliqIcm * 100), 4, "0")
									Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) == "ISS" //ISS
										nSL2Iss  := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
										nBaseIss := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
										nAliqIss := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
																		
										//Gera Codigo de Tributacao, sempre sera enviado quando tributado
										cTribut := "S" + PadL(CValToChar(nAliqIss * 100), 4, "0")
									Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) == "PIS" //PIS
										If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_WITHHOLDINGTAX") <> Nil .And.;
												AllTrim(Upper(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX]:_WithHoldingTax:Text)) == "TRUE" //Retencao
											
											nSL2PisRet  	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
											nBasPisRet 	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
											nAlqPisRet 	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
										Else //Apuracao
											nSL2PisApu  	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
											nBasPisApu 	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
											nAlqPisApu 	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
										EndIf
									Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) == "COFINS" //COFINS
										If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_WITHHOLDINGTAX") <> Nil .And.;
												AllTrim(Upper(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX]:_WithHoldingTax:Text)) == "TRUE" //Retencao
											
											nSL2CofRet  	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
											nBasCofRet 	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
											nAlqCofRet 	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
										Else //Apuracao
											nSL2CofApu  	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
											nBasCofApu		:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
											nAlqCofApu		:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
										EndIf
									Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) == "CSLL" //CSLL
										nSL2CSLL  := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
										nBaseCSLL := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
										nAliqCSLL := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
									Case "IRRF" $ AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) //IRRF
										nSL2IRRF  := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
										nBaseIRRF := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
										nAliqIRRF := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
									EndCase
								Next nX
							EndIf
						
						//Descontos no item
							nPerItDesc	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_DISCOUNTPERCENTAGE", "N"))
							nValItDesc := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_DISCOUNTAMOUNT", "N"))
						
						//Se existir desconto no item e nao enviadas as duas tags, efetua o calculo
							If nValItDesc > 0
								nPerItDesc := Round((nValItDesc * 100) / nVlrItem, TamSx3("L2_DESC")[2]) //Calcula o Percentual do Desconto no Item
							ElseIf nPerItDesc > 0
								nValItDesc := (nVlrItem / 100) * nPerItDesc //Calcula o Valor do Desconto no Item
							EndIf
																		
						//Valor de acrescimo no item
							nVlAcrsIt := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_INCREASE", "N"))
						
						//Armazem padrao
							cValExt := LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_WAREHOUSEINTERNALID")
																		
							If !Empty(cValExt)
								aAux := IntLocInt(cValExt, cMarca)
		          		
			          		//Se encontrou o cliente no de-para
								If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
									cArmazem := PadR(aAux[2][3], TamSX3("B1_LOCPAD")[1])
								Else
									lRet 	 := .F.
									cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0106 + " " + AllTrim(cValExt) + " " + STR0107 //"Inconsistencia no item" #"Armazem: " ##"nao integrado ao Protheus, verificar integracao de armazens"
									Exit
								EndIf
							Else //Utiliza armazem padrao
								cArmazem := SB1->B1_LOCPAD
							EndIf
												
							If lIntegHtl //Hotelaria
							//Tratamento Centro de Custo consumo
								cLjCCusto 	:= "" //Centro de Custo
								cLjItemCC 	:= "" //Item Centro de Custo
								cLjClvl 	:= "" //Classe Valor
			          		
								cIdLoja := Padr(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_STOREIDENTIFICATIONCODE"), TamSX3("LJ_CODIGO")[1])
			          		
			          		//Se enviado identificacao de loja, valida se existe o cadastro
								If !Empty(cIdLoja)
									SLJ->(dbSetOrder(1)) //LJ_FILIAL+LJ_CODIGO
			          			
									If SLJ->(dbSeek(xFilial("SLJ") + cIdLoja))
										cLjCCusto 	:= SLJ->LJ_CCUSTO  //Centro de Custo
										cLjItemCC 	:= SLJ->LJ_ITEMCC  //Item Centro de Custo
										cLjClvl 	:= SLJ->LJ_CLVL    //Classe Valor
										cArmazem  	:= SLJ->LJ_LOCAL	 //Armazem
									Else
										lRet 	 := .F.
										cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0108 + " " + AllTrim(cIdLoja) + " " + STR0109 //"Inconsistencia no item" #"Codigo de Identificacao de loja" ##"nao cadastrado no Protheus"
										Exit
									EndIf
								EndIf
							EndIf
										 												
							If !lCancItem .Or. lCancVen //Tratamento para recebimento de itens cancelados
							//Quando venda ativa, adiciona apenas itens ativos
							//Se venda cancelada, sempre adiciona, itens serao excluidos no processo de
							//exclusao da venda 
								nVlrItTot  += nVlrItem - Round(nDescPro, TamSx3("L2_DESCPRO")[2])
								nVlrMercIt += A410Arred(nVlrItem, "F2_VALMERC")
							
							//Lei de Transparencia
								If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_STATETAXBURDEN") <> Nil
									nImpEst := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_STATETAXBURDEN", "N"))
								EndIf
								If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_MUNICIPALTAXBURDEN") <> Nil
									nImpMun := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_MUNICIPALTAXBURDEN", "N"))
								EndIf
								If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_FEDERALTAXBURDEN") <> Nil
									nImpFed := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_FEDERALTAXBURDEN", "N"))
								EndIf
							
								cTpOpera := "01" //Inicializa tipo de operacao para Tes Inteligente
							
								If lIntegHtl //Hotelaria
								//Armazena venda que reteve impostos Pis/Cofins do item - Bloco F100
									If lLjMvBf100
										cIdVendF100 := LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_INTERNALID")
									EndIf
								
								//Informacoes de Pensao - Hotelaria										
									If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_BOARDBASISINFORMATION") <> Nil
										cDtVendF100 := ""
									
									//Se produto referenciado em outra venda, verifica data para Bloco F100
										If lLjMvBf100 .And. !Empty(cIdVendF100)
											cDtVendF100 := LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_BoardBasisInformation, "_DATEOFMOVEMENT", "D")
																			
											If Empty(cDtVendF100)
												lRet 	 := .F.
												cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0114 + "," + STR0115 + "," + STR0116 //"Inconsistencia no item" #"nao informada a data para verificacao do Bloco F100" ##"esta informacao é obrigatoria quando informada a venda origem Bloco F100" ###"verifique a tag: DateOfMovement localizada na lista BoardBasisInformation"
												Exit
											Else
											//Verifica se zera base Pis/Cofins, tratamento Bloco F100										
												If Month(StoD(cDtVendF100)) <> Month(SToD(cEmissao))
													nBasPisApu := 0
													nSL2PisApu := 0
													nBasCofApu := 0
													nSL2CofApu := 0
												
													cTpOpera := SuperGetMV("MV_LJOPTES",, "") //Altera o tipo de operacao para Tes Inteligente
												EndIf
											EndIf
										EndIf
									
										If !Empty(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_BoardBasisInformation, "_BOARDBASISTYPE")) .Or.;
												!Empty(cDtVendF100)
									
											aAdd(aItemMh4, { 	cSerie,;
												cDoc,;
												cItem,;
												LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_BoardBasisInformation, "_BOARDBASISTYPE"),;
												Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_BoardBasisInformation, "_BOARDBASISVALUE", "N")),;
												Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_BoardBasisInformation, "_BREAKFASTVALUE", "N")),;
												cIdVendF100,;
												StoD(cDtVendF100)})
										EndIf
									Else
										If lLjMvBf100 .And. !Empty(cIdVendF100)
											lRet 	 := .F.
											cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0117 + "," + STR0115 + "," + STR0119 //"Inconsistencia no item" #"nao informada a lista BoardBasisInformation" ##"esta informacao é obrigatoria quando informada a venda origem Bloco F100" ###"verifique a tag InternalId na lista ListOfSaleItem"
											Exit
										EndIf
									EndIf
								EndIf
							
							//Armazena TES
								cTesPrd := MaTesInt(2, cTpOpera, cCodCli, cLojCli, "C", SB1->B1_COD)
						
							//Se nao encontrou Tes Inteligente continua a busca
								If Empty(cTesPrd)
									SBZ->(dbSetOrder(1))
												
									If AllTrim(SuperGetMv("MV_ARQPROD",, "SB1")) == "SBZ" .And.;
											SBZ->(dbSeek(xFilial("SBZ") + cProduto)) .And. !Empty(SBZ->BZ_TS) //Busca Tes na SBZ
									
										cTesPrd := SBZ->BZ_TS
									ElseIf !Empty(SB1->B1_TS) //Busca Tes na SB1
										cTesPrd := SB1->B1_TS
									Else //Busca Tes no parametro
										If lRps
											cTesPrd := SuperGetMv("MV_TESSERV") //Tes para Servico
										Else
											cTesPrd := SuperGetMv("MV_TESVEND") //Tes para Venda
										EndIf
									EndIf
								EndIf
							
							//Validacao TES
								If Empty(cTesPrd)
									lRet 	 := .F.
									cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0040 //#"Inconsistencia no item" ##"TES nao informada, verifique o Cadastro de Produto no Protheus campo B1_TS e/ou De-Para de TES(XXF) e/ou as configurações para TES Inteligente(DHJ e SFM) e/ou parametros MV_TESSERV e MV_TESVEND."
									Exit
								EndIf
							/*
							//Valida CFOP
								cCfop := Padr(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_OperationCode:Text, TamSx3("LR_CF")[1])
								
								If !SX5->(dbSeek(xFilial("SX5") + "13"  + cCfop))
									lRet 	 := .F.
									cXmlRet := STR0031 +  " " + CValToChar(nI) + "," + STR0063 + AllTrim(cCfop) + "," + STR0064 //#"Inconsistencia no item" ##"CFOP invalida:" ###"verifique o cadastro de CFOP"
									Exit
								EndIf
							*/															
								/* Efetua a carga das tabela SLR */
							
							//Alimenta Array com Itens da Venda																							 						 									
								aAdd(aItem, {	{"LR_PRODUTO"	, cProduto			, Nil},;
									{"LR_ITEM"		, cItem			, Nil},;
									{"LR_QUANT"  	, nQuant			, Nil},;
									{"LR_VRUNIT"	, nVlrUnit			, Nil},;
									{"LR_VLRITEM"	, nVlrItem			, Nil},;
									{"LR_LOCAL"	, cArmazem			, Nil},;
									{"LR_UM"		, SB1->B1_UM		, Nil},;
									{"LR_DESC"		, nPerItDesc		, Nil},;
									{"LR_VALDESC"	, nValItDesc		, Nil},;
									{"LR_DESCPRO"	, nDescPro			, Nil},;
									{"LR_TES"		, cTesPrd			, Nil},;
									{"LR_CF"		, cCfop   			, Nil},;
									{"LR_VENDIDO"	, "V"				, Nil},;
									{"LR_DOC"		, cDoc				, Nil},;
									{"LR_SERIE"	, cSerie  			, Nil},;
									{"LR_NUMCFIS"	, ""				, Nil},;
									{"LR_PDV"		, cPdv				, Nil},;
									{"LR_VALICM"	, nSL2Icms			, Nil},;
									{"LR_BASEICM"	, nBaseIcm			, Nil},;
									{"LR_PICM"		, nAliqIcm			, Nil},;
									{"LR_VALISS"	, nSL2Iss			, Nil},;
									{"LR_BASEISS"	, nBaseIss			, Nil},;
									{"LR_ALIQISS"	, nAliqIss			, Nil},;
									{"LR_ENTREGA"	, "2"   			, Nil},;
									{"LR_EMISSAO"	, SToD(cEmissao)	, Nil},;
									{"LR_VEND"		, cVendedor		, Nil},;
									{"LR_VALACRS"	, nVlAcrsIt		, Nil},;
									{"LR_VALPS2"	, nSL2PisApu		, Nil},;
									{"LR_BASEPS2"	, nBasPisApu		, Nil},;
									{"LR_ALIQPS2"	, nAlqPisApu		, Nil},;
									{"LR_VALCF2"	, nSL2CofApu		, Nil},;
									{"LR_BASECF2"	, nBasCofApu		, Nil},;
									{"LR_ALIQCF2"	, nAlqCofApu		, Nil},;
									{"LR_VALPIS"	, nSL2PisRet		, Nil},;
									{"LR_ALIQPIS"	, nAlqPisRet		, Nil},;
									{"LR_BASEPIS"	, nBasPisRet		, Nil},;
									{"LR_VALCOFI"	, nSL2CofRet		, Nil},;
									{"LR_ALIQCOF"	, nAlqCofRet		, Nil},;
									{"LR_BASECOF"	, nBasCofRet		, Nil},;
									{"LR_BASCSLL"	, nBaseCSLL		, Nil},;
									{"LR_ALQCSLL"	, nAliqCSLL		, Nil},;
									{"LR_VALCSLL"	, nSL2CSLL			, Nil},;
									{"LR_SITTRIB"	, cTribut			, Nil},;
									{"LR_PRCTAB"	, nVlrUnit			, Nil},;
									{"LR_TOTFED"	, nImpFed			, Nil},;
									{"LR_TOTEST"	, nImpEst			, Nil},;
									{"LR_TOTMUN"	, nImpMun			, Nil},;
									{"LR_VALIRRF"	, nSL2IRRF			, Nil},;
									{"LR_BASIRRF" , nBaseIRRF		, Nil},;
									{"LR_ALQIRRF" , nAliqIRRF		, Nil},;
									{"LR_PREDIC"  , nAliqRed			, Nil},;
									{"LR_CCUSTO"  , cLjCCusto		, Nil},;
									{"LR_ITEMCC"  , cLjItemCC		, Nil},;
									{"LR_CLVL"  	, cLjClvl			, Nil}})
							Else
							//Trata gravacao de itens cancelados																																																
								aAdd(aCancItem, { {"LX_FILIAL"	, xFilial("SL1")},;
									{"LX_OPERADO" , cOperador	},;
									{"LX_DTMOVTO" , dDataBase	},;
									{"LX_CUPOM" 	, cDoc			},;
									{"LX_SERIE"	, cSerie		},;
									{"LX_HORA" 	, Time()		},;
									{"LX_PDV"		, cPdv			},;
									{"LX_ITEM"		, cItem		},;
									{"LX_TPCANC"	, "I"			},;
									{"LX_VALOR"  	, nVlrItem		},;
									{"LX_PRODUTO"	, cProduto		},;
									{"LX_QTDE"		, nQuant		},;
									{"LX_DESCON"	, nValItDesc	},;
									{"LX_ALIQICM"	, nAliqIss		},;
									{"LX_SUPERVI"	, "PDV BEMATECH"},;
									{"LX_SITUACA"	, "00"			}})
							EndIf
					
						//Limpa as informacoes de impostos e tributacao
							nSL2Icms 		:= 0
							nSL2Iss  		:= 0
							nSL2PisApu  	:= 0
							nSL2CofApu		:= 0
							nBaseIcm 		:= 0
							nBaseIss 		:= 0
							nAliqIcm 		:= 0
							nAliqIss 		:= 0
							nSL2PisRet 	:= 0
							nBasPisRet		:= 0
							nAlqPisRet		:= 0
							nSL2PisApu		:= 0
							nBasPisApu		:= 0
							nAlqPisApu		:= 0
							nSL2CofRet 	:= 0
							nBasCofRet		:= 0
							nAlqCofRet		:= 0
							nSL2CofApu		:= 0
							nBasCofApu		:= 0
							nAlqCofApu		:= 0
							nSL2CSLL 		:= 0
							nBaseCSLL		:= 0
							nAliqCSLL		:= 0
							nSL1CSLL		:= 0
							nSL2IRRF		:= 0
							nAliqIRRF		:= 0
							nBaseIRRF		:= 0
							nAliqRed		:= 0
							cTribut  		:= "" //Inicializa codigo da tributacao
						Next nI
					EndIf
							
				//Verifica se continua a gravacao da venda
					If lRet
					//Tratamento para arredondamento dos itens quando existe desconto no total
						If nValDesTot > 0
							nPosDescPro := aScan(aItem[1], {|x| AllTrim(x[1]) == "LR_DESCPRO"})
						
							If nPosDescPro > 0
							//Se Total da Venda maior que acumulado dos itens, cuidando que seja apenas 1 centavo 
							//ajusta desconto devido diferenca de arredondamento no desconto proporcional
								If nVlrTot > nVlrItTot .And. nVlrTot - nVlrItTot == 0.01
									aItem[Len(aItem)][nPosDescPro][2] -= 0.01
								ElseIf nVlrTot < nVlrItTot .And. nVlrItTot - nVlrTot == 0.01
								//Se Total da Venda menor que acumulado dos itens, cuidando que seja apenas 1 centavo 
								//ajusta desconto devido diferenca de arredondamento no desconto proporcional
									aItem[Len(aItem)][nPosDescPro][2] += 0.01
								EndIf
							EndIf
						EndIf
					
						//PROCESSOS SÓ DEVEM ACONTECER CASO GEREM FINANCEIRO
						//If lGeraFin						
							//Valida se forma de pagamentos foram enviados
						If	XmlChildEx(oXmlContent:_ListOfSaleCondition, "_SALECONDITION") == Nil
							lRet 	 := .F.
							cXmlRet := STR0043 //#"Lista de Forma de Pagamentos vazia, verifique a lista SaleCondition."
						EndIf
					
						If lRet
							//Monta Condicoes de Pagamento (aPagtos)
							If ValType(oXmlContent:_ListOfSaleCondition:_SaleCondition) <> "A"
								XmlNode2Arr(oXmlContent:_ListOfSaleCondition:_SaleCondition, "_SaleCondition")
							EndIf
							
							//Valida se lista esta vazia
							If Len(oXmlContent:_ListOfSaleCondition:_SaleCondition) == 0
								lRet 	 := .F.
								cXmlRet := STR0043 //#"Lista de Forma de Pagamentos vazia, verifique a lista SaleCondition."
							EndIf
						EndIf
					
						If lRet
							For nI := 1 To Len(oXmlContent:_ListOfSaleCondition:_SaleCondition)
									//Armazena Forma de Pagamento
								cFormaPg := LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_PAYMENTMETHODCODE")
																					
								If Empty(cFormaPg)
									lRet 	 := .F.
									cXmlRet := STR0044 + " " + CValToChar(nI) + "," + STR0045 + Chr(10) //#"Inconsistencia na forma de pagamento" ##"Forma de Pagamento nao informado na integracao."
									cXmlRet += STR0046 //#"Verifique as tags: PaymentMethodCode"
									Exit
								EndIf
									
									//Posiciona na Forma de Pagamento do Protheus
								SX5->(dbSetOrder(1))
									
								If Empty(cFormaPg) .Or. !SX5->(dbSeek(xFilial("SX5") + "24"  + cFormaPg))
									lRet 	 := .F.
									cXmlRet := STR0044 +  " " + CValToChar(nI) + "," + STR0047 + AllTrim(cFormaPg) + " " + STR0048 + Chr(10) //#"Inconsistencia na forma de pagamento" ##"Forma de Pagamento:" ###"nao encontrado no Protheus."
									cXmlRet += STR0049 //#"Verifique o cadastro de Forma de Pagamento."
									Exit
								EndIf
									
									//Armazena Administradora Financeira																				
								cAdmFin := Padr(LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_FINANCIALMANAGERCODE"), TamSx3("AE_COD")[1])
													
									//Posiciona na Administradora do Protheus
								SAE->(dbSetOrder(1))
									
								If !Empty(cAdmFin) .And. SAE->(dbSeek(xFilial("SAE") + cAdmFin))
									cAdmFin := SAE->AE_COD + "-" + AllTrim(SAE->AE_DESC)
								Else
									If AllTrim(cFormaPg) $ "CC|CD"
										lRet 	 := .F.
										cXmlRet := STR0044 + " " + CValToChar(nI) + "," + STR0050 + Chr(10) //#"Inconsistencia na forma de pagamento" ##"Administradora Financeira invalida ou nao encontrada no dePara no Protheus." 
										cXmlRet += STR0051 //#"Esta informacao e obrigatoria para pagamentos em cartao, verifique a tag: FinancialManagerCode."
										Exit
									EndIf
								EndIf
									
									//Inicializa InternalId do RA a ser compensado
								cIntIdRA := ""
									
									//Validacoes de campos obrigatorios
								If XmlChildEx(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_PAYMENTVALUE") == Nil .Or.;
										Empty(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI]:_PaymentValue:Text) .Or.;
										Val(StrTran(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI]:_PaymentValue:Text, ",", ".")) <= 0
									lRet 	 := .F.
									cXmlRet := STR0044 + " " + CValToChar(nI) + "," + STR0052 //#"Inconsistencia na forma de pagamento" ##"Valor do Pagamento nao informado na integracao, verifique a tag: PaymentValue."
									Exit
								ElseIf lIntegHtl .And. AllTrim(cFormaPg) == "RA" //Informacoes compensacao titulo hotelaria
									cIntIdRA := LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_ACCOUNTRECEIVABLEDOCUMENTINTERNALID")
										
									If Empty(cIntIdRA)
										lRet 	 := .F.
										cXmlRet := STR0044 + " " + CValToChar(nI) + "," + STR0066 + Chr(10) //#"Inconsistencia na forma de pagamento" ##"InternalId do RA nao informado"
										cXmlRet += STR0067 //#"Esta informacao e obrigatoria para pagamentos RA, verifique a tag: AccountReceivableDocumentInternalId"
										Exit
									Else
										aAux := IntTRcInt(cIntIdRA, cMarca) //Resgatando os dados do título pelo InternalId
											
											//Armazena informacoes do adiantamento
										If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
											SE1->(dbSetOrder(1))
												
												//Posiciona no Titulo RA	
											If SE1->(dbSeek(xFilial("SE1") + PadR(aAux[2][3],TamSX3("E1_PREFIXO")[1]) + PadR(aAux[2][4],TamSX3("E1_NUM")[1]) +;
													PadR(aAux[2][5],TamSX3("E1_PARCELA")[1]) + PadR(aAux[2][6],TamSX3("E1_TIPO")[1])))
													
													//Valida se titulo foi compensado manualmente
												If SE1->E1_SALDO > 0
													cRecRa := CValToChar(SE1->(Recno()))
												Else
													lRet 	 := .F.
													cXmlRet := STR0044 + " " + CValToChar(nI) + "," + STR0086 + ":" + AllTrim(cIntIdRA) + " " + STR0092 + Chr(10) ////#"Inconsistencia na forma de pagamento" ##"O titulo de adiantamento" ###"encontra-se baixado"
													cXmlRet += STR0093 //#"Necessário desfazer a compensação no financeiro."
												EndIf
											Else
												lRet 	 := .F.
												cXmlRet := STR0044 + " " + CValToChar(nI) + "," + STR0086 + ":" + AllTrim(cIntIdRA) + " " + STR0089 + Chr(10) //#"Inconsistencia na forma de pagamento" ##"O titulo de adiantamento" ###"nao foi encontrado na base de dados Protheus"
												cXmlRet += STR0087 //#"Verifique a tag: AccountReceivableDocumentInternalId"
											EndIf
										Else
											lRet 	 := .F.
											cXmlRet := STR0044 + " " + CValToChar(nI) + "," + STR0086 + ":" + AllTrim(cIntIdRA) + " " + STR0088 + Chr(10) //#"Inconsistencia na forma de pagamento" ##"O titulo de adiantamento" ###"nao foi integrado ao Protheus"
											cXmlRet += STR0087 //#"Verifique a tag: AccountReceivableDocumentInternalId"
										EndIf
									EndIf
								EndIf
									
									//Armazena Data do Pagamento
								cDataPgto := LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_DATEOFPAYMENT", "D")
									
								If Empty(cDataPgto)
									cDataPgto := cEmissao
								EndIf
									
									//Armazena Data de Pagamento
								dDataPagto	 := SToD(cDataPgto)
									
									//Informacoes TEF	
												
								cL4HoraTef 	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTDATE", "T")	//Hora Tef SL4
								cL4HoraTef	 	:= AllTrim(StrTran(cL4HoraTef, ":", ""))
									
								cL4HrCanTef	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTCANCELLATIONDATE", "T") //Data de Cancelamento Tef SL4
								cL4HrCanTef	:= AllTrim(StrTran(cL4HrCanTef, ":", ""))
														
									//Verifica utilizacao de Tef
								lTef := !Empty(LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTDATE", "D"))
									
									//Incrementa Item Tef
								If lTef
									nItemTef ++
								EndIf
									
								If lTef
										//Esta validacao eh necessaria pois SL1 grava apenas a parcela 1 do Tef
									If	nItemTef == 1
											//Armazena informacoes Tef para SL1
										cL1VendTef	:= "S" //Venda Tef SL1
										cL1DataTef	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTDATE", "D") //Data Tef SL1
										cL1HoraTef	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTDATE", "T") //Hora Tef Sl1
										cL1HoraTef := AllTrim(StrTran(cL1HoraTef, ":", ""))
										cL1DocTef	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTDOCUMENT") //Documento Tef Sl1
										cL1Autoriz	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTAUTORIZATION") //Autorizacao Tef SL1
										cL1DocCanc	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTCANCELLATIONDOCUMENT") //Documento de Cancelamento Tef SL1
										cL1DatCanc	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTCANCELLATIONDATE", "D") //Data de Cancelamento Tef SL1
										cL1HorCanc	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTCANCELLATIONDATE", "T") //Hora Cancelamento Tef SL1
										cL1HorCanc := AllTrim(StrTran(cL1HorCanc, ":", ""))
										cL1Institu	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTINSTITUTE") //Instituro Tef SL1
										cL1NsuTef	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_UNIQUESERIALNUMBER") //Nsu Tef SL1
									EndIf
								EndIf
																							
								cFormaId := ""
								cNsu	  := LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_UNIQUESERIALNUMBER")
									
								If AllTrim(cFormaPg) $ "CC|CD"
									dDataPagto := SToD(cEmissao) //Tef sempre envia a data de emissao pois o GravaBatch calcula com base na Administradora Financeira - SAE
																		
										//Tratamento FormaId para multiplos cartoes
									If Len(aParcela) == 0
										nFormaId ++
									Else
										nPosNsu := aScan(aParcela[1], {|x| AllTrim(x[1]) == "L4_NSUTEF"})
											
										If aScan(aParcela, {|x| AllTrim(x[nPosNsu][2]) == AllTrim(cNsu)}) == 0 //Se nao encontrou NSU, incrementa ID	 pois é MultiTef
											nFormaId ++
										EndIf
									EndIf
										
									cFormaId := CValToChar(nFormaId)
								EndIf
																			
								/* Efetua a carga das tabela SL4 */
									
									//Alimenta array de Pagamentos								       		   		      		      							
								aAdd(aParcela, {	{"L4_DATA"    , dDataPagto																									  	, Nil},;
									{"L4_VALOR"  	, Val(StrTran(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI]:_PaymentValue:Text, ",", "."))		, Nil},;
									{"L4_FORMA"  	, cFormaPg																											, Nil},;
									{"L4_ADMINIS"	, cAdmFin	 																										, Nil},;
									{"L4_NUMCART"	, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_CARDNUMBER")							, Nil},;
									{"L4_SERCHQ"  , LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_SERIECHECK") 							, Nil},;
									{"L4_AGENCIA"	, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_AGENCYCHECK")  						, Nil},;
									{"L4_CONTA"	, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_ACCOUNTCHECK")  						, Nil},;
									{"L4_RG"		, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_DOCUMENTOFIDENTIFICATION")			, Nil},;
									{"L4_TELEFON"	, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_PHONENUMBER") 						, Nil},;
									{"L4_TERCEIR"	, "F"      																										, Nil},;
									{"L4_FORMAID" , cFormaId       																									, Nil},;
									{"L4_DATATEF"	, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTDATE", "D")						, Nil},;
									{"L4_HORATEF"	, cL4HoraTef																				 						, Nil},;
									{"L4_DOCTEF" 	, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTDOCUMENT")							, Nil},;
									{"L4_AUTORIZ"	, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTAUTORIZATION")					, Nil},;
									{"L4_DATCANC" , LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTCANCELLATIONDATE", "D")			, Nil},;
									{"L4_HORCANC"	, cL4HrCanTef																										, Nil},;
									{"L4_DOCCANC" , LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTCANCELLATIONDOCUMENT")			, Nil},;
									{"L4_INSTITU" , LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTINSTITUTE")						, Nil},;
									{"L4_NSUTEF"  , cNsu																												, Nil},;
									{"L4_MOEDA"  	, nMoeda																											, Nil},;
									{"L4_PARCTEF" , LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTPARCEL")							, Nil},;
									{"L4_VENDTEF" , IIF(lTef, "S", "N")																							, Nil},;
									{"L4_CONHTL" 	, cRecRa																											, Nil}})
							Next nI
						EndIf
					EndIf
						//Endif								
				//Verifica se continua a gravacao da venda
					If lRet
					//Comissao do Vendedor
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_VALCOMI"})][2] := nValComis
																	
					//Adiciona informacoes Tef
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_VENDTEF"})][2] := cL1VendTef	 //Venda Tef Sl1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_DATATEF"})][2] := cL1DataTef	 //Data Tef SL1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_HORATEF"})][2] := cL1HoraTef	 //Hora Tef Sl1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_DOCTEF"})][2]  := cL1DocTef	 //Documento Tef Sl1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_AUTORIZ"})][2] := cL1Autoriz	 //Autorizacao Tef SL1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_DOCCANC"})][2] := cL1DocCanc	 //Documento de Cancelamento Tef SL1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_DATCANC"})][2] := cL1DatCanc	 //Data de Cancelamento Tef SL1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_HORCANC"})][2] := cL1HorCanc	 //Hora Cancelamento Tef SL1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_INSTITU"})][2] := cL1Institu	 //Instituro Tef SL1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_NSUTEF"})][2]  := cL1NsuTef	 //Nsu Tef SL1
																
					//Atualiza Valor Total Mercadoria se necessario
						If nVlMercTot < nVlrMercIt
							aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_VALMERC"})][2] := nVlrMercIt
						EndIf
						
						dDataBkp  := dDataBase //Salva data atual
						dDataBase := StoD(cEmissao) //Altera Database
																																																								
					//Efetua a gravacao da venda
						Begin Transaction
							lMsErroAuto := .F.
							SetFunName("LOJA701")
							MSExecAuto({|a,b,c,d,e,f,g,h| Loja701(a,b,c,d,e,f,g,h)}, .F., nOpcX, "", "", {}, aCab, aItem, aParcela)
																						 		 																								
						//Verifica se encontrou erros na gravacao da venda			
							If lMsErroAuto
								aErroAuto := GetAutoGrLog()
																             	
			             	//Armazena mensagens de erro	             	
								cXMLRet := "<![CDATA["
								For nI := 1 To Len(aErroAuto)
									cXMLRet += aErroAuto[nI] + Chr(10)
								Next nI
								cXMLRet += "]]>"
							
								If Len(aErroAuto) == 0
									cXMLRet := STR0025 + " " + AllTrim(cIdExt) //#"Erro na gravacao da venda: "
								EndIf
							
			          		//Monta XML de Erro de execução da rotina automatica
								lRet := .F.
				
			             	//Desfaz a transacao
								DisarmTransaction()
							
							//Libera sequencial 
								RollBackSx8()
								MsUnLockAll()
							Else
							
							//Armazena InternalId do Protheus
								aInternal := IntVendExt(cEmpAnt, SL1->L1_FILIAL, SL1->L1_SERIE, SL1->L1_DOC, SL1->L1_PDV)
																		
							//Valida se gerou a venda
								If Len(aInternal) > 0
									If aInternal[1]
										cValInt := aInternal[2]
																																																																				
									//Adiciona item no De/Para - XXF								
										If CFGA070Mnt(cMarca, "SL1", "L1_DOC", cIdExt, cValInt, .F.)
					                	//Monta o XML de Retorno
											cXmlRet := "<ListOfInternalId>"
											cXmlRet +=    "<InternalId>"
											cXmlRet +=       "<Name>RetailSalesInternalId</Name>"
											cXmlRet +=       "<Origin>" + cIdExt + "</Origin>"
											cXmlRet +=       "<Destination>" + cValInt + "</Destination>"
											cXmlRet +=    "</InternalId>"
											cXmlRet += "</ListOfInternalId>"
										EndIf
						   			
						   			//Verifica se foi efetuado cancelamento da venda anteriormente
										If ExistFunc("Lj140DelSLX")
											Lj140DelSLX(cMarca)
										Endif
						   			
							   		//Trata gravacao de itens cancelados
										If Len(aCancItem) > 0
											For nS := 1 To Len(aCancItem)
												Lj7GeraSL("SLX", aCancItem[nS], .T.)
											Next nS
										EndIf
									
										If lIntegHtl //Hotelaria
											If lRps .And. (lReserva .Or. !Empty(cRateio))
												RecLock( "MH3", .T. )
												MH3->MH3_FILIAL := FWxFilial( "MH3" )
												MH3->MH3_SERRPS := cSerie
												MH3->MH3_DOCRPS := cDoc
												MH3->MH3_DTIN   := SToD( cDataIn )
												MH3->MH3_DTOUT  := SToD( cEmissao )
												MH3->MH3_RESERV := cReserva
												MH3->MH3_TIPOUH := cTipoUH
												MH3->MH3_NUMUH  := cNumUH
												MH3->MH3_HOSPRI := cHospede
												MH3->MH3_HOSPED := cOutrosHsp
												MH3->MH3_GRUPO  := cGrupoRsv
												MH3->MH3_EVENTO := cEventoRsv
												MH3->MH3_LANC   := cLanctos
												MH3->MH3_RATEIO := cRateio
												MH3->( MsUnlock() )
											EndIf
																																		
										//Gravacao dos itens de pensao
											For nI := 1 To Len(aItemMh4)
												RecLock( "MH4", .T. )
												MH4->MH4_FILIAL := FWxFilial( "MH4" )
												MH4->MH4_SERRPS := aItemMh4[nI][1]
												MH4->MH4_DOCRPS := aItemMh4[nI][2]
												MH4->MH4_ITEM   := aItemMh4[nI][3]
												MH4->MH4_TIPPEN := aItemMh4[nI][4]
												MH4->MH4_VLRPEN := aItemMh4[nI][5]
												MH4->MH4_VLRCAF := aItemMh4[nI][6]
												MH4->MH4_IDF100 := aItemMh4[nI][7]
												MH4->MH4_DTF100 := aItemMh4[nI][8]
												MH4->( MsUnlock() )
											Next nI
										EndIf
									
										ConfirmSx8()
						         	
										RecLock("SL1", .F.)
										SL1->L1_SITUA := "RX"
										SL1->(MsUnLock())

										IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit(), NIL)
									Else
										lRet 	 := .F.
										cXmlRet := STR0025 + " " + AllTrim(cIdExt) //#"Erro na gravacao da venda: "
									EndIf
								Else
									lRet 	 := .F.
									cXmlRet := STR0025 + " " + AllTrim(cIdExt) //#"Erro na gravacao da venda: "
								EndIf
							EndIf
						End Transaction
					
						dDataBase := dDataBkp //Restaura Database
					EndIf
				ElseIf nOpcX == 2 //Evento de Atualizacao
					If lIntegHtl //Hotelaria
					//Armazena codigo da reserva que sera alterado
						If XmlChildEx(oXmlContent, "_BOOKINGINFORMATION") <> Nil
							cReserva := LjiVldTag(oXmlContent:_BookingInformation, "_HOTELACCOUNTCODE", "C") //Numero da Reserva
						EndIf
												
						cSerie := Padr(aAux[2][3], TamSx3("L1_SERIE")[1])
						cDoc 	:= Padr(aAux[2][4], TamSx3("LQ_DOC")[1])
						cPdv 	:= Padr(aAux[2][5], TamSx3("LQ_PDV")[1])
						
						SL1->(dbSetOrder(2))
						SL1->(dbSeek(xFilial("SL1") + cSerie + cDoc + cPdv))
													
						SL1->(RecLock("SL1", .F.))
						SL1->L1_RESEHTL := cReserva
						SL1->(MsUnLock())
											
					//Armazena InternalId do Protheus
						cValInt := IntVendExt(cEmpAnt, SL1->L1_FILIAL, SL1->L1_SERIE, SL1->L1_DOC, SL1->L1_PDV)[2]
					
					//Monta o XML de Retorno
						cXmlRet := "<ListOfInternalId>"
						cXmlRet +=    "<InternalId>"
						cXmlRet +=       "<Name>RetailSalesInternalId</Name>"
						cXmlRet +=       "<Origin>" + cIdExt + "</Origin>"
						cXmlRet +=       "<Destination>" + cValInt + "</Destination>"
						cXmlRet +=    "</InternalId>"
						cXmlRet += "</ListOfInternalId>"
					Else
						lRet    := .F.
						cXmlRet := STR0022 + " " + AllTrim(cIdExt) + " " + STR0023 //#"Cupom:" ##" ja integrado no Protheus"
					EndIf
				EndIf
			EndIf
		Else
			lRet    := .F.
			cXmlRet := STR0024 //#"Atualize EAI"
		EndIf
	
		//Tratamento para evitar retorno incorreto
		If Empty(cXMLRet)
			lRet 	:= .F.
			cXmlRet := STR0025 + " " + AllTrim(cIdExt) //#"Erro na gravacao da venda:"
		EndIf
	ElseIf nTypeTrans == TRANS_SEND
		cEvent   := "upsert" //Evento
	
	//Verifica flag de cancelamento da venda
		lCancVen := LjiVendCanc()
	
	//Inclusao de Venda ativa
		If !lCancVen
		//InternalId da Venda	
			aAux := IntVendExt(/*Empresa*/, /*Filial*/, SL1->L1_SERIE, SL1->L1_DOC, SL1->L1_PDV, /*Versão*/)

            LjGrvLog(" LOJI701 ", "DE/Para de venda da função IntVendExt ",aAux )
		
			If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
				cValInt := aAux[2]
			Else
				cValInt := ""
			EndIf
		
		//InternalId do Cliente
			aAux := IntCliExt(/*Empresa*/, /*Filial*/, SL1->L1_CLIENTE, SL1->L1_LOJA, /*Versão*/)

            LjGrvLog(" LOJI701 ", "DE/Para de cliente da função IntCliExt ",aAux )
		
			If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
				cCliInt := aAux[2]
			Else
				cCliInt := ""
			EndIf
		
		//InternalId do Vendedor
			aAux := IntVenExt(/*Empresa*/, /*Filial*/, SL1->L1_VEND, /*Versão*/)

            LjGrvLog(" LOJI701 ", "DE/Para de vendedor da função IntVenExt ",aAux )
		
			If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
				cVendInt := aAux[2]
			Else
				cVendInt := ""
			EndIf
	
		//InternalId da Estacao de Trabalho
			aAux := IntEstacExt(/*Empresa*/, /*Filial*/, SL1->L1_ESTACAO, /*Versão*/)

            LjGrvLog(" LOJI701 ", "DE/Para de estação da função IntEstacExt ",aAux )
		
			If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
				cEstInt := aAux[2]
			Else
				cEstInt := ""
			EndIf
	
		//Data de Emissao
			If !Empty(SL1->L1_EMISSAO)
				cEmissao := SubStr(DToS(SL1->L1_EMISSAO), 1, 4) + '-' + SubStr(DToS(SL1->L1_EMISSAO), 5, 2) + '-' + SubStr(DToS(SL1->L1_EMISSAO), 7, 2)
		
			//Hora de Emissao	
				cEmissao += "T"
				cEmissao += RTrim(SL1->L1_HORA)
			EndIf
	
			cXmlRet := '<BusinessEvent>'
			cXmlRet +=     '<Entity>RETAILSALES</Entity>'
			cXmlRet +=     '<Event>' + cEvent + '</Event>'
			cXmlRet +=     '<Identification>'
			cXmlRet +=         '<key name="InternalId">' + cValInt + '</key>'
			cXmlRet +=     '</Identification>'
			cXmlRet += '</BusinessEvent>'
		
			cXmlRet += '<BusinessContent>'
	
		//Cabecalho da Venda
			cXmlRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
			cXmlRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
			cXmlRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
			cXmlRet +=    '<InternalId>' + cValInt + '</InternalId>'
			cXmlRet +=    '<SellerInternalId>' + cVendInt + '</SellerInternalId>'
			cXmlRet +=    '<ComissionPercent>' + CValToChar(SL1->L1_COMIS) + '</ComissionPercent>'
			cXmlRet +=    '<CustomerVendorInternalId>' + cCliInt + '</CustomerVendorInternalId>'
			cXmlRet +=    '<TotalPrice>' + CValToChar(SL1->L1_VLRTOT) + '</TotalPrice>'
			cXmlRet +=    '<DiscountValue>' + CValToChar(SL1->L1_DESCONT) + '</DiscountValue>'
			cXmlRet +=    '<IncreaseValue>' + CValToChar(SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA) + '</IncreaseValue>'
			cXmlRet +=    '<NetPrice>' + CValToChar(SL1->L1_VLRLIQ) + '</NetPrice>'
			cXmlRet +=    '<CashValue>' + CValToChar(SL1->L1_DINHEIR) + '</CashValue>'
			cXmlRet +=    '<ChecksValue>' + CValToChar(SL1->L1_CHEQUES) + '</ChecksValue>'
			cXmlRet +=    '<CardsValue>' + CValToChar(SL1->L1_CHEQUES) + '</CardsValue>'
			cXmlRet +=    '<DebitValue>' + CValToChar(SL1->L1_VLRDEBI) + '</DebitValue>'
			cXmlRet +=    '<CovenantValue>' + CValToChar(SL1->L1_CONVENI) + '</CovenantValue>'
			cXmlRet +=    '<VouchersValue>' + CValToChar(SL1->L1_VALES) + '</VouchersValue>'
			cXmlRet +=    '<FinancedValue>' + CValToChar(SL1->L1_FINANC) + '</FinancedValue>'
			cXmlRet +=    '<OthersValue>' + CValToChar(SL1->L1_OUTROS) + '</OthersValue>'
			cXmlRet +=    '<InputValue>' + CValToChar(SL1->L1_ENTRADA) + '</InputValue>'
			cXmlRet +=    '<IssueDateDocument>' + cEmissao + '</IssueDateDocument>'
			cXmlRet +=    '<DocumentCode>' + RTrim(SL1->L1_DOC) + '</DocumentCode>'
			cXmlRet +=    '<SerieCode>' + RTrim(SL1->L1_SERIE) + '</SerieCode>'
			cXmlRet +=    '<GrossPrice>' + CValToChar(SL1->L1_VALBRUT) + '</GrossPrice>'
			cXmlRet +=    '<CommodityPrice>' + CValToChar(SL1->L1_VALMERC) + '</CommodityPrice>'
			cXmlRet +=    '<DiscountPercent>' + CValToChar(SL1->L1_DESCNF) + '</DiscountPercent>'
			cXmlRet +=    '<OperatorCode>' + RTrim(SL1->L1_OPERADO) + '</OperatorCode>'
			cXmlRet +=    '<CurrencyRate>' + CValToChar(SL1->L1_TXMOEDA) + '</CurrencyRate>'
			cXmlRet +=    '<Change>' + CValToChar(SL1->L1_TROCO1) + '</Change>'
			cXmlRet +=    '<StationCode>' + RTrim(SL1->L1_PDV) + '</StationCode>'
			cXmlRet +=    '<DiscountPaymentTerm>' + CValToChar(SL1->L1_DESCFIN) + '</DiscountPaymentTerm>'
			cXmlRet +=    '<CreditValue>' + CValToChar(SL1->L1_CREDITO) + '</CreditValue>'
			cXmlRet +=    '<KindOfDocument>' + RTrim(SL1->L1_ESPECIE) + '</KindOfDocument>'
			cXmlRet +=    '<Md5>' + RTrim(SL1->L1_PAFMD5) + '</Md5>'
			cXmlRet +=    '<PersonalIdentification>' + RTrim(SL1->L1_CGCCLI) + '</PersonalIdentification>'
			cXmlRet +=    '<IsCanceled>' + IIF(lCupCancel, "true", "false") + '</IsCanceled>'
			cXmlRet +=    '<StationSalePointCode>' + RTrim(SL1->L1_ESTACAO) + '</StationSalePointCode>'
			cXmlRet +=    '<StationSalePointInternalId>' + cEstInt + '</StationSalePointInternalId>'
			cXmlRet +=    '<SerialNumberSATEquipament>' + RTrim(SL1->L1_SERSAT) + '</SerialNumberSATEquipament>'
			cXmlRet +=    '<SaleType>' + IIF(Empty(SL1->L1_SERSAT), "V", "S") + '</SaleType>'
			cXmlRet +=    '<KeyAcessNFe>' + RTrim(SL1->L1_KEYNFCE) + '</KeyAcessNFe>'
	
		//Lista de Impostos da venda
			cXmlRet += 	'<ListOfTaxes>'
			cXmlRet += 		'<Tax>'
			cXmlRet +=    		'<Taxe>COFINS</Taxe>'
			cXmlRet +=    		'<Value>' + CValToChar(SL1->L1_VALCOFI) + '</Value>'
			cXmlRet += 		'</Tax>'
			cXmlRet += 		'<Tax>'
			cXmlRet +=    		'<Taxe>CSLL</Taxe>'
			cXmlRet +=    		'<Value>' + CValToChar(SL1->L1_VALCSLL) + '</Value>'
			cXmlRet += 		'</Tax>'
			cXmlRet += 		'<Tax>'
			cXmlRet +=    		'<Taxe>ISS</Taxe>'
			cXmlRet +=    		'<Value>' + CValToChar(SL1->L1_VALISS) + '</Value>'
			cXmlRet += 		'</Tax>'
			cXmlRet += 		'<Tax>'
			cXmlRet +=    		'<Taxe>PIS</Taxe>'
			cXmlRet +=    		'<Value>' + CValToChar(SL1->L1_VALPIS) + '</Value>'
			cXmlRet += 		'</Tax>'
			cXmlRet += 		'<Tax>'
			cXmlRet +=    		'<Taxe>IPI</Taxe>'
			cXmlRet +=    		'<Value>' + CValToChar(SL1->L1_VALIPI) + '</Value>'
			cXmlRet += 		'</Tax>'
			cXmlRet += 		'<Tax>'
			cXmlRet +=    		'<Taxe>ICM</Taxe>'
			cXmlRet +=    		'<Value>' + CValToChar(SL1->L1_VALICM) + '</Value>'
			cXmlRet += 		'</Tax>'
			cXmlRet += 	'</ListOfTaxes>'
	
		//Itens ativados e cancelados da Venda
			cXmlRet += 	'<ListOfSaleItem>'

            LjGrvLog(" LOJI701 ", "Execução do primeiro bloco de montagem do xml ",cXmlRet )
	
		//Itens ativados
			SL2->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))

            LjGrvLog(" LOJI701 ", "Começo da busca de itens do orçamento: ",SL1->L1_NUM )
			
			While SL2->(!EOF()) .And. SL2->L2_FILIAL == SL1->L1_FILIAL .And. SL2->L2_NUM == SL1->L1_NUM
				lItCancel := .F. //Flag de item ativado
			
			//InternalId do Produto				
				aAux := IntProExt(/*Empresa*/, /*Filial*/, SL2->L2_PRODUTO, /*Versão*/)

                LjGrvLog(" LOJI701 ", "De/Para de produto da função  IntProExt", aAux )
			
				If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
					cProdInt := aAux[2]
				Else
					cProdInt := ""
				EndIf
			
			//Unidade de Medida
				cUniMed  := RTrim(Posicione("SB1", 1, xFilial("SB1") + SL2->L2_PRODUTO, "B1_UM"))
			
			//InternalId da Unidade de Medida				
				aAux := IntUndExt(/*Empresa*/, /*Filial*/, cUniMed, /*Versão*/)

                LjGrvLog(" LOJI701 ", "De/Para de unidade de medida da função IntUndExt", aAux )
			
				If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
					cUMInt := aAux[2]
				Else
					cUMInt := ""
				EndIf
		
			//InternalId do Local de Estoque				
				aAux := IntLocExt(/*Empresa*/, /*Filial*/, SL2->L2_LOCAL, /*Versão*/)

                LjGrvLog(" LOJI701 ", "De/Para de local de estoque da função IntLocExt", aAux )
			
				If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
					cLocInt := aAux[2]
				Else
					cLocInt := ""
				EndIf
		
				cXmlRet += 	'<SaleItem>'
				cXmlRet +=    	'<InternalId>' + cValInt + '</InternalId>'
				cXmlRet +=    	'<ItemInternalId>' + cProdInt + '</ItemInternalId>'
				cXmlRet +=    	'<ItemCode>' + RTrim(SL2->L2_PRODUTO) + '</ItemCode>'
				cXmlRet +=    	'<ItemOrder>' + RTrim(SL2->L2_ITEM) + '</ItemOrder>'
				cXmlRet +=    	'<Quantity>' + CValToChar(SL2->L2_QUANT) + '</Quantity>'
                cXmlRet +=    	'<UnitPrice>' + CValToChar(SL2->L2_VRUNIT) + '</UnitPrice>'
				cXmlRet +=    	'<ItemPrice>' + CValToChar(SL2->L2_VLRITEM) + '</ItemPrice>'
				cXmlRet +=    	'<DiscountPercentage>' + CValToChar(SL2->L2_DESC) + '</DiscountPercentage>'
				cXmlRet +=    	'<DiscountAmount>' + CValToChar(SL2->L2_VALDESC) + '</DiscountAmount>'
				cXmlRet +=    	'<OperationCode>' + RTrim(SL2->L2_CF) + '</OperationCode>'
				cXmlRet +=    	'<Increase>0</Increase>'
				cXmlRet +=    	'<IsCanceled>' + IIF(lItCancel, "true", "false") + '</IsCanceled>'
				cXmlRet +=    	'<UnitOfMeasureCode>' + cUniMed + '</UnitOfMeasureCode>'
				cXmlRet +=    	'<UnitOfMeasureInternalId>' + cUMInt + '</UnitOfMeasureInternalId>'
				cXmlRet +=    	'<WarehouseCode>' + RTrim(SL2->L2_LOCAL) + '</WarehouseCode>'
				cXmlRet +=    	'<WarehouseInternalId>' + cLocInt + '</WarehouseInternalId>'
		
			//Lista de Impostos do item
				cXmlRet += 		'<ListOfTaxes>'
				cXmlRet += 			'<Tax>'
				cXmlRet +=    			'<Taxe>COFINS</Taxe>'
				cXmlRet +=    			'<Value>' + CValToChar(SL2->L2_VALCOFI) + '</Value>'
				cXmlRet += 			'</Tax>'
				cXmlRet += 			'<Tax>'
				cXmlRet +=    			'<Taxe>CSLL</Taxe>'
				cXmlRet +=    			'<Value>' + CValToChar(SL2->L2_VALCSLL) + '</Value>'
				cXmlRet += 			'</Tax>'
				cXmlRet += 			'<Tax>'
				cXmlRet +=    			'<Taxe>ISS</Taxe>'
				cXmlRet +=    			'<Value>' + CValToChar(SL2->L2_VALISS) + '</Value>'
				cXmlRet += 			'</Tax>'
				cXmlRet += 			'<Tax>'
				cXmlRet +=    			'<Taxe>PIS</Taxe>'
				cXmlRet +=    			'<Value>' + CValToChar(SL2->L2_VALPIS) + '</Value>'
				cXmlRet += 			'</Tax>'
				cXmlRet += 			'<Tax>'
				cXmlRet +=    			'<Taxe>ICM</Taxe>'
				cXmlRet +=    			'<Value>' + CValToChar(SL2->L2_VALICM) + '</Value>'
				cXmlRet +=    			'<CalculationBasis>' + CValToChar(SL2->L2_BASEICM) + '</CalculationBasis>'
				cXmlRet += 			'</Tax>'
				cXmlRet += 		'</ListOfTaxes>'
				cXmlRet += 	'</SaleItem>'
		
				SL2->(dbSkip())
			EndDo
	
             LjGrvLog(" LOJI701 ", "Execução do segundo bloco de montagem do xml ",cXmlRet )    
		//Itens cancelados
			SLX->(dbSeek(SL1->L1_FILIAL + SL1->L1_PDV + SL1->L1_DOC + SL1->L1_SERIE))
		
			While SLX->(!EOF()) .And. SLX->LX_FILIAL == SL1->L1_FILIAL .And. SLX->LX_PDV == SL1->L1_PDV .And.;
					SLX->LX_CUPOM == SL1->L1_DOC .And. SLX->LX_SERIE == SL1->L1_SERIE
			
			//Verifica se cancelamento por item
				If SLX->LX_TPCANC == "I"
					lItCancel := .T. //Flag de item cancelado
				
				//InternalId do Produto				
					aAux := IntProExt(/*Empresa*/, /*Filial*/, SLX->LX_PRODUTO, /*Versão*/)

                    LjGrvLog(" LOJI701 ", "De/Para de produto no cancelamento de item da função IntProExt", aAux )
				
					If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
						cProdInt := aAux[2]
					Else
						cProdInt := ""
					EndIf
			
				//Unidade de Medida
					cUniMed  := RTrim(Posicione("SB1", 1, xFilial("SB1") + SLX->LX_PRODUTO, "B1_UM"))
				
				//InternalId da Unidade de Medida				
					aAux := IntUndExt(/*Empresa*/, /*Filial*/, cUniMed, /*Versão*/)

                    LjGrvLog(" LOJI701 ", "De/Para de unidade de medida no cancelamento de item da função IntUndExt", aAux )
				
					If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
						cUMInt := aAux[2]
					Else
						cUMInt := ""
					EndIf
																
					cXmlRet += 	'<SaleItem>'
					cXmlRet +=    	'<InternalId>' + cValInt + '</InternalId>'
					cXmlRet +=    	'<ItemInternalId>' + cProdInt + '</ItemInternalId>'
					cXmlRet +=    	'<ItemCode>' + RTrim(SLX->LX_PRODUTO) + '</ItemCode>'
					cXmlRet +=    	'<ItemOrder>' + RTrim(SLX->LX_ITEM) + '</ItemOrder>'
					cXmlRet +=    	'<Quantity>' + CValToChar(SLX->LX_QTDE) + '</Quantity>'
					cXmlRet +=    	'<UnitPrice>' + CValToChar(SLX->LX_VRUNIT) + '</UnitPrice>'
					cXmlRet +=    	'<ItemPrice>' + CValToChar(SLX->LX_VALOR) + '</ItemPrice>'
					cXmlRet +=    	'<DiscountPercentage>' + CValToChar((SLX->LX_DESCON / SLX->LX_VALOR) * 100) + '</DiscountPercentage>'
					cXmlRet +=    	'<DiscountAmount>' + CValToChar(SLX->LX_DESCON) + '</DiscountAmount>'
					cXmlRet +=    	'<IsCanceled>' + IIF(lItCancel, "true", "false") + '</IsCanceled>'
					cXmlRet +=    	'<UnitOfMeasureCode>' + cUniMed + '</UnitOfMeasureCode>'
					cXmlRet +=    	'<UnitOfMeasureInternalId>' + cUMInt + '</UnitOfMeasureInternalId>'
					cXmlRet += 	'</SaleItem>'
				EndIf
		
				SLX->(dbSkip())
			EndDo
	
            LjGrvLog(" LOJI701 ", "Execução do terceiro bloco de montagem do xml ",cXmlRet )    
			cXmlRet += 	'</ListOfSaleItem>'
	
		//Formas de Pagamento da Venda
			cXmlRet += 	'<ListOfSaleCondition>'
	
			SL4->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))
		
			While SL4->(!EOF()) .And. SL4->L4_FILIAL == SL1->L1_FILIAL .And. SL4->L4_NUM == SL1->L1_NUM
				cFormaPg := SL4->L4_FORMA //Armazena Forma de Pagamento
			
			//Verificacao dos parametros opcionais para as Formas de Pagamento Dinheiro, Cheque e Financiado
			//Necessaio pois RM pode ter mais de um codigo para essas formas
				If AllTrim(cFormaPg) == "R$" .And. !Empty(GetNewPar("MV_LJMUDIN", ""))
					cFormaPg := RTrim(GETMV("MV_LJMUDIN"))
				ElseIf AllTrim(cFormaPg) == "CH" .And. !Empty(GetNewPar("MV_LJMUCH", ""))
					cFormaPg := RTrim(GETMV("MV_LJMUCH"))
				ElseIf AllTrim(cFormaPg) == "FI" .And. !Empty(GetNewPar("MV_LJMUFI", ""))
					cFormaPg := RTrim(GETMV("MV_LJMUFI"))
				EndIf
			
			//InternalId da Forma de Pagamento				
				aAux := IntFmPgtExt(/*Empresa*/, /*Filial*/, cFormaPg, /*Versão*/)

                LjGrvLog(" LOJI701 ", "De/Para de forma de pagamento da função IntFmPgtExt", aAux )
			
				If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
					cPgtoInt := aAux[2]
				Else
					cPgtoInt := ""
				EndIf
		
			//Data de Pagamento
				If !Empty(SL4->L4_DATA)
					cDtPagto := SubStr(DToS(SL4->L4_DATA), 1, 4) + '-' + SubStr(DToS(SL4->L4_DATA), 5, 2) + '-' + SubStr(DToS(SL4->L4_DATA), 7, 2)
			
				//Hora de Pagamento
					cDtPagto += "T"
					cDtPagto += RTrim(SL1->L1_HORA)
				EndIf
				
			//Data Tef
				cL4DataTef := ""
			
				If !Empty(SL4->L4_DATATEF)
					cL4DataTef := SubStr(SL4->L4_DATATEF, 1, 4) + '-' + SubStr(SL4->L4_DATATEF, 5, 2) + '-' + SubStr(SL4->L4_DATATEF, 7, 2)
				
				//Hora Tef
					If !Empty(SL4->L4_HORATEF)
						cL4DataTef += "T"
						cL4DataTef += SubStr(SL4->L4_HORATEF, 1, 2) + ":" + SubStr(SL4->L4_HORATEF, 3, 2) + ":" + SubStr(SL4->L4_HORATEF, 5, 2)
					EndIf
				EndIf
		
			//Data cancelamento Tef	
				cL4DatCanc := ""
			
				If !Empty(SL4->L4_DATCANC)
					cL4DatCanc := SubStr(SL4->L4_DATCANC, 7, 4) + '-' + SubStr(SL4->L4_DATCANC, 4, 2) + '-' + SubStr(SL4->L4_DATCANC, 1, 2)
				
				//Hora Cancelamento Tef
					If !Empty(SL4->L4_HORCANC)
						cL4DatCanc += "T"
						cL4DatCanc += SubStr(SL4->L4_HORCANC, 1, 2) + ":" + SubStr(SL4->L4_HORCANC, 3, 2) + ":" + SubStr(SL4->L4_HORCANC, 5, 2)
					EndIf
				EndIf
	
				cXmlRet += 	'<SaleCondition>'
				cXmlRet +=    	'<DateOfPayment>' + cDtPagto + '</DateOfPayment>'
				cXmlRet +=    	'<PaymentValue>' + CValToChar(SL4->L4_VALOR - SL4->L4_TROCO) + '</PaymentValue>'
				cXmlRet +=    	'<PaymentMethodCode>' + RTrim(cFormaPg) + '</PaymentMethodCode>'
				cXmlRet +=    	'<PaymentMethodInternalId>' + cPgtoInt + '</PaymentMethodInternalId>'
		
			//Busca Administradora Financeira, é enviado o Código Externo que está vinculado a Forma de Pagamento
				cXmlRet +=    	'<FinancialManagerCode>' + IIF(!Empty(SL4->L4_ADMINIS),RTrim(Posicione("SAE", 1, xFilial("SAE") + SL4->L4_ADMINIS, "AE_CODEXT")), "") + '</FinancialManagerCode>'
				cXmlRet +=    	'<CardNumber>' + RTrim(SL4->L4_NUMCART) + '</CardNumber>'
				cXmlRet +=    	'<SerieCheck>' + RTrim(SL4->L4_SERCHQ) + '</SerieCheck>'
				cXmlRet +=    	'<BankCheck>' + IIF(AllTrim(cFormaPg) == "CH" .Or. AllTrim(cFormaPg) == AllTrim(GETMV("MV_LJMUCH")), RTrim(SL4->L4_ADMINIS), "") + '</BankCheck>'
				cXmlRet +=    	'<AgencyCheck>' + RTrim(SL4->L4_AGENCIA) + '</AgencyCheck>'
				cXmlRet +=    	'<AccountCheck>' + RTrim(SL4->L4_CONTA) + '</AccountCheck>'
				cXmlRet +=    	'<DocumentOfIdentification>' + RTrim(SL4->L4_RG) + '</DocumentOfIdentification>'
				cXmlRet +=    	'<PhoneNumber>' + RTrim(SL4->L4_TELEFON) + '</PhoneNumber>'
				cXmlRet +=    	'<EftDate>' + cL4DataTef + '</EftDate>'
				cXmlRet +=    	'<EftDocument>' + RTrim(SL4->L4_DOCTEF) + '</EftDocument>'
				cXmlRet +=    	'<EftAutorization>' + RTrim(SL4->L4_AUTORIZ) + '</EftAutorization>'
				cXmlRet +=    	'<EftCancellationDate>' + cL4DatCanc + '</EftCancellationDate>'
				cXmlRet +=    	'<EftCancellationDocument>' + RTrim(SL4->L4_DOCCANC) + '</EftCancellationDocument>'
				cXmlRet +=    	'<EftInstitute>' + RTrim(SL4->L4_INSTITU) + '</EftInstitute>'
				cXmlRet +=    	'<UniqueSerialNumber>' + RTrim(SL4->L4_NSUTEF) + '</UniqueSerialNumber>'
				cXmlRet +=    	'<EftParcel>' + RTrim(SL4->L4_PARCTEF) + '</EftParcel>'
				cXmlRet += 	'</SaleCondition>'
		
				SL4->(dbSkip())
			EndDo
	
			cXmlRet += 	'</ListOfSaleCondition>'
	
			cXmlRet += '</BusinessContent>'

            LjGrvLog(" LOJI701 ", "Execução do quarto bloco de montagem do xml ",cXmlRet )    
		Else //Inclusao de Venda cancelada
		//Cancelamento de venda nao integrada, quando cancelada antes da finalizacao.
		//Neste caso sao enviadas as informacoes da venda completa pois nao existe
		//a venda original, ou seja, inclusao do cancelamento.
		
            LjGrvLog(" LOJI701 ", "Inicio do processo de cancelamento, posicionando SLX " )
		//Posiciona no primeiro item do cupom cancelado
			SLX->(dbSetOrder(1))
			SLX->(dbSeek(SLX->LX_FILIAL + SLX->LX_PDV + SLX->LX_CUPOM + SLX->LX_SERIE))
		
		//InternalId do cancelamento de venda
			aAux := IntCancExt(/*Empresa*/, /*Filial*/, SLX->LX_SERIE, SLX->LX_CUPOM, SLX->LX_PDV, /*Versão*/)

            LjGrvLog(" LOJI701 ", "De/Para de cancelamento de venda da função IntCancExt", aAux )
		 	
			If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
				cValInt := aAux[2]
			Else
				cValInt := ""
			EndIf
		
		//Armazena informacoes do cupom	 cancelado	
			cPdv	:= SLX->LX_PDV 	//Pdv do cupom fiscal cancelado
			cDoc	:= SLX->LX_CUPOM //Numero do cumpo fiscal cancelado
			cSerie	:= SLX->LX_SERIE //Serie do cupom fiscal cancelado
		
		//Condicional para a query		
			cWhere := "%"
			cWhere += " LG_FILIAL = '" + xFilial("SLG") + "'"
			cWhere += " AND LG_PDV = '" + SLX->LX_PDV + "'"
			cWhere += " AND D_E_L_E_T_ = ''"
			cWhere += "%"
		
		//Executa a query
			BeginSql alias cAliasTmp
				SELECT
				LG_CODIGO, LG_SERSAT
				FROM %table:SLG%
				WHERE %exp:cWhere%
			EndSql
		
			(cAliasTmp)->(dbGoTop()) //Posiciona no inicio do arquivo temporario
		
		//Busca informacoes da Estacao de Trabalho
			If (cAliasTmp)->(!EOF())
				cEstac  := (cAliasTmp)->LG_CODIGO
				cSerSat := (cAliasTmp)->LG_SERSAT
			EndIf
		
		//Fecha arquivo temporario
			If (Select(cAliasTmp) > 0)
				(cAliasTmp)->(dbCloseArea())
			EndIf
		
		//InternalId da Estacao de Trabalho
			aAux := IntEstacExt(/*Empresa*/, /*Filial*/, cEstac, /*Versão*/)

            LjGrvLog(" LOJI701 ", "De/Para de estacao de trabalho função IntEstacExt", aAux )
		
			If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
				cEstInt := aAux[2]
			Else
				cEstInt := ""
			EndIf
		
		//Data do cancelamento
			If !Empty(SLX->LX_DTMOVTO)
				cEmissao := SubStr(DToS(SLX->LX_DTMOVTO), 1, 4) + '-' + SubStr(DToS(SLX->LX_DTMOVTO), 5, 2) + '-' + SubStr(DToS(SLX->LX_DTMOVTO), 7, 2)
		
			//Hora de Emissao	
				cEmissao += "T"
				cEmissao += RTrim(SLX->LX_HORA)
			EndIf
		
			cOperador := SLX->LX_OPERADO //Operador
						
		//Loop na SLX para armazenar informacoes da venda
			While SLX->(!Eof()) .And. SLX->LX_FILIAL == xFilial("SLX") .And. SLX->LX_PDV == cPdv .And.;
					SLX->LX_CUPOM == cDoc .And. SLX->LX_SERIE == cSerie
			
				If SLX->LX_TPCANC <> "I"
					//Armazena totalizadores da venda cancelada
					nVlrTot  	+= SLX->LX_VALOR
					nValDesTot	+= SLX->LX_DESCON
				EndIf
				
				//Armazena informacoes dos itens cancelados em array
				aAdd(aItensCanc, {	SLX->LX_PRODUTO,;
					SLX->LX_ITEM,;
					SLX->LX_QTDE,;
					SLX->LX_VRUNIT,;
					SLX->LX_VALOR,;
					SLX->LX_DESCON,;
					SLX->LX_TPCANC})
				SLX->(dbSkip())
			EndDo
							
			cXmlRet := '<BusinessEvent>'
			cXmlRet +=     '<Entity>RETAILSALES</Entity>'
			cXmlRet +=     '<Event>' + cEvent + '</Event>'
			cXmlRet +=     '<Identification>'
			cXmlRet +=         '<key name="InternalId">' + cValInt + '</key>'
			cXmlRet +=     '</Identification>'
			cXmlRet += '</BusinessEvent>'
		
			cXmlRet += '<BusinessContent>'
		
		//Cabecalho da Venda
			cXmlRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
			cXmlRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
			cXmlRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
			cXmlRet +=    '<InternalId>' + cValInt + '</InternalId>'
			cXmlRet +=    '<TotalPrice>' + CValToChar(nVlrTot) + '</TotalPrice>'
			cXmlRet +=    '<DiscountValue>0</DiscountValue>'
			cXmlRet +=    '<NetPrice>' + CValToChar(nVlrTot) + '</NetPrice>'
			cXmlRet +=    '<IssueDateDocument>' + cEmissao + '</IssueDateDocument>'
			cXmlRet +=    '<DocumentCode>' + RTrim(cDoc) + '</DocumentCode>'
			cXmlRet +=    '<SerieCode>' + RTrim(cSerie) + '</SerieCode>'
			cXmlRet +=    '<GrossPrice>' + CValToChar(nVlrTot) + '</GrossPrice>'
			cXmlRet +=    '<CommodityPrice>' + CValToChar(nVlrTot) + '</CommodityPrice>'
			cXmlRet +=    '<DiscountPercent>0</DiscountPercent>'
			cXmlRet +=    '<OperatorCode>' + RTrim(cOperador) + '</OperatorCode>'
			cXmlRet +=    '<StationCode>' + RTrim(cPdv) + '</StationCode>'
			cXmlRet +=    '<Increase>0</Increase>'
			cXmlRet +=    '<IsCanceled>true</IsCanceled>'
			cXmlRet +=    '<StationSalePointCode>' + RTrim(cEstac) + '</StationSalePointCode>'
			cXmlRet +=    '<StationSalePointInternalId>' + cEstInt + '</StationSalePointInternalId>'
			cXmlRet +=    '<SaleType>' + IIF(Empty(cSerSat), "V", "S") + '</SaleType>'
		
		//Itens
			cXmlRet += 	'<ListOfSaleItem>'

            LjGrvLog(" LOJI701 ", "Execução do bloco de cancelamento da montagem do xml ",cXmlRet )
		
			For nI := 1 To Len(aItensCanc)
			//InternalId do Produto				
				aAux := IntProExt(/*Empresa*/, /*Filial*/, aItensCanc[nI][1], /*Versão*/)

                LjGrvLog(" LOJI701 ", "De/Para de produto da função IntProExt", aAux )
		
				If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
					cProdInt := aAux[2]
				Else
					cProdInt := ""
				EndIf
			
			//Unidade de Medida
				cUniMed  := RTrim(Posicione("SB1", 1, xFilial("SB1") + aItensCanc[nI][1], "B1_UM"))
			
			//InternalId da Unidade de Medida				
				aAux := IntUndExt(/*Empresa*/, /*Filial*/, cUniMed, /*Versão*/)

                LjGrvLog(" LOJI701 ", "De/Para de unidade de medida da função IntUndExt", aAux )
			
				If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
					cUMInt := aAux[2]
				Else
					cUMInt := ""
				EndIf
		
				cXmlRet += 	'<SaleItem>'
				cXmlRet +=    	'<InternalId>' + cValInt + '</InternalId>'
				cXmlRet +=    	'<ItemInternalId>' + cProdInt + '</ItemInternalId>'
				cXmlRet +=    	'<ItemCode>' + RTrim(aItensCanc[nI][1]) + '</ItemCode>'
				cXmlRet +=    	'<ItemOrder>' + RTrim(aItensCanc[nI][2]) + '</ItemOrder>'
				cXmlRet +=    	'<Quantity>' + CValToChar(aItensCanc[nI][3]) + '</Quantity>'
				cXmlRet +=    	'<UnitPrice>' + CValToChar(aItensCanc[nI][4]) + '</UnitPrice>'
				cXmlRet +=    	'<ItemPrice>' + CValToChar(aItensCanc[nI][5]) + '</ItemPrice>'
				cXmlRet +=    	'<DiscountAmount>0</DiscountAmount>'
				cXmlRet +=    	'<Increase>0</Increase>'
				cXmlRet +=    	'<IsCanceled>' + IIF(aItensCanc[nI][7] == "I", "true", "false") + '</IsCanceled>'
				cXmlRet +=    	'<UnitOfMeasureCode>' + cUniMed + '</UnitOfMeasureCode>'
				cXmlRet +=    	'<UnitOfMeasureInternalId>' + cUMInt + '</UnitOfMeasureInternalId>'
				cXmlRet += 	'</SaleItem>'
			Next nI
		
			cXmlRet += 	'</ListOfSaleItem>'
			cXmlRet += '</BusinessContent>'

            LjGrvLog(" LOJI701 ", "Execução do bloco final de cancelamento da montagem do xml ",cXmlRet )
		EndIf
	EndIf

   //Restaura areas
	For nI := 1 To Len(aAreas)
		RestArea(aAreas[nI])
	Next nI

	RestArea(aArea)

    LjGrvLog(" LOJI701 ", "Fim do processamento da função: V1000 " + FwTimeStamp(2))

Return Nil


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v2000

Rotina para processar a mensagem tipo RECEIVE e BUSINESS 
Efetua a gravacao de Vendas Varejo.            

@param   oXmlL701	Objeto contendo a mensagem (XML) 
@param   nTypeTrans	Tipo da Transacao (Envio ou Recebimento)
@param   lRet  		Indica o resultado da execução da função
@param   cXmlRet  		Mensagem Xml para envio
@param   cVersao   	Versao da mensagem

@author  Vendas Cliente      
@version P12
@since   05/01/2016
@return  Nil

/*/
//-------------------------------------------------------------------------------------------------
Static Function v2000(oXmlL701, nTypeTrans, lRet, cXmlRet, cVersao)

	Local cSerie		:= "" //Serie do cupom fiscal
	Local cDoc			:= "" //Numero do cumpo fiscal ajustado
	Local cTimeEmis		:= "" //Hora de emissao do cupom fiscal
	Local cMarca		:= "" //Armazena a Marca que enviou o XML
	Local cValExt		:= "" //Codigo externo utilizada no De/Para de codigos - Tabela XXF
	Local cValInt		:= "" //Codigo interno utilizada no De/Para de codigos - Tabela XXF
	Local cCodCli		:= "" //Codigo de Cliente
	Local cLojCli		:= "" //Loja do Cliente
	Local cEstac		:= "" //Codigo da Estacao
	Local cPdv			:= "" //Codigo do PDV
	Local cOperador		:= "" //Codigo do Operador
	Local cProduto		:= "" //Codigo do Produto
	Local cIdVendF100	:= "" //InternalId da venda para verificacao do Bloco F100
	Local cDtVendF100	:= "" //Data da venda para verificacao do Bloco F100
	Local lLjMvBf100 	:= SuperGetMV("MV_LJBF100",, .F.) //Ativa verificação bloco F100
	Local cFormaPg		:= "" //Forma de Pagamento
	Local cAdmFin		:= "" //Administradora Financeira
	Local cBanck		:= "" //Banco
	Local cIdExt		:= "" //Identificacao externa do registro
	Local cTesPrd		:= "" //Tes para o produto
	Local cTpOpera		:= "" //Tipo de operacao Tes inteligente
	Local cVendedor 	:= "" //Vendedor
	Local cItem			:= "" //Item de Venda
	Local cCfop			:= "" // Campo Cfop
	Local cDataPgto  	:= "" //Data do Pagamento
	Local cTipoOrc		:= "" //Tipo do Orcamento
	Local cTipoVen		:= "V" //Tipo da Venda
	Local cSitua		:= "" //Situacao do Orcamento
	Local cSituaOrc		:= "" //Controle do Orcamento
	Local cIntIdRA		:= "" //InternalID do RA a ser compensado
	Local cL1VendTef	:= "N" //Venda Tef SL1
	Local cL1DataTef	:= "" //Data Tef SL1
	Local cL1HoraTef	:= "" //Hora Tef SL1
	Local cL1DocTef		:= "" //Documento Tef SL1
	Local cL1Autoriz	:= "" //Autorizacao Tef SL1
	Local cL1DocCanc	:= "" //Documento de Cancelamento Tef SL1
	Local cL1DatCanc	:= "" //Data de Cancelamento Tef SL1
	Local cL1HorCanc	:= "" //Hora Cancelamento Tef SL1
	Local cL1Institu	:= "" //Instituro Tef SL1
	Local cL1NsuTef		:= "" //Nsu Tef SL1
	Local cL4DataTef	:= "" //Data Tef SL4
	Local cL4DatCanc	:= "" //Data de Cancelamento Tef SL4
	Local cL4HoraTef	:= "" //Hora Tef SL4
	Local cL4HrCanTef	:= "" //Hora cancelamento Tef SL4
	Local cCpfCli		:= "" //CPF do Cliente
	Local cEvent   		:= "" //Evento
	Local cCliInt	   	:= "" //InternalId do Cliente
	Local cProdInt		:= "" //InternalId do Produto
	Local cVendInt		:= "" //InternalId do Vendedor
	Local cEstInt		:= "" //InternalId da Estacao de Trabalho
	Local cUMInt		:= "" //InternalId da Unidade de Medida
	Local cPgtoInt		:= "" //InternalId da Forma de Pagamento
	Local cLocInt		:= "" //InternalId do Local de Estoque
	Local cEmissao		:= "" //Data e hora de Emissao
	Local cDtPagto		:= "" //Data e hora do Pagamento
	Local cUniMed		:= "" //Unidade de Medida
	Local cWhere		:= "" //Condicional da query
	Local cSerSat		:= "" //Numero de Serie SAT
	Local cTpVenda		:= "" //Tipo da venda
	Local cRecRa		:= "" //Recno Titulo RA - Adiantamento hospede
	Local cTribut		:= "" //Codigo da tributacao ECF
	Local cReserva		:= "" //Codigo da Reserva do Cliente Hotel
	Local cMenNota      := "" //Mensagem da Nota Fiscal
	Local cCondPg		:= SuperGetMv("MV_CONDPAD",, "001") //Condicao de Pagamento padrao
	Local cAliasTmp 	:= GetNextAlias() //Alias temporario	
	Local nI			:= 0 //Contador
	Local nX			:= 0 //Contador
	Local nMoeda		:= 0 //Moeda da Venda
	Local nOpcX			:= 0 //Opcao da integracao
	Local nVlrTot		:= 0 //Valor Total
	Local nBaseIcm		:= 0 //Valor Base ICMS
	Local nBaseIss		:= 0 //Valor Base ISS
	Local nAliqIcm 		:= 0 //Aliquota ICMS
	Local nAliqIss		:= 0 //Aliquota ISS
	Local nValDesTot 	:= 0 //Valor de Desconto no Total da Venda
	Local nPerDesTot	:= 0 //Percentua de Desconto no Total da Venda
	Local nQuant   		:= 0 //Quantidade do item
	Local nVlrUnit 		:= 0 //Valor unitario do produto
	Local nVlrItem		:= 0 //Valor Total do item
	Local nDescPro		:= 0 //Valor de Desconto Proporcional do Item
	Local nVlrLiq		:= 0 //Valor Total Liquido da Venda
	Local nSL1Icms		:= 0 //Valor de ICMS na SL1
	Local nSL1Iss		:= 0 //Valor de ISS na SL1
	Local nSL1Pis		:= 0 //Valor de PIS na SL1
	Local nSL1Cof		:= 0 //Valor de COFINS na SL1
	Local nSL2Icms		:= 0 //Valor de ICMS na SL2
	Local nSL2Iss		:= 0 //Valor de ISS na SL2
	Local nBasPisRet	:= 0 //Base Pis Retencao
	Local nAlqPisRet	:= 0 //Aliquota Pis Retencao
	Local nSL2PisRet	:= 0 //Valor PIS Retencao
	Local nBasPisApu	:= 0 //Base Pis Apuracao
	Local nAlqPisApu	:= 0 //Aliquota Pis Apuracao
	Local nSL2PisApu 	:= 0 //Valor de PIS na SL2
	Local nBasCofRet	:= 0 //Base Cofins Retencao
	Local nAlqCofRet	:= 0 //Aliquota Cofins Retencao
	Local nSL2CofRet	:= 0 //Valor Cofins Retencao
	Local nBasCofApu	:= 0 //Base Cofins Apuracao
	Local nAlqCofApu	:= 0 //Aliquota Cofins Apuracao
	Local nSL2CofApu 	:= 0 //Valor de Cofins na Apuracao
	Local nItemTef		:= 0 //Numero parcela Tef
	Local nPerComis		:= 0 //Percentual da Comissao do Vendedor
	Local nValComis		:= 0 //Valor da Comissao do Vendedor
	Local nPerItDesc	:= 0 //Percentual de Desconto no Item
	Local nVlAcrsIt		:= 0 //Valor de Acrescimo no Item
	Local nValItDesc 	:= 0 //Valor de Desconto no Item
	Local nAliqRed		:= 0 //Aliquota reducao ICMS
	Local nSlx			:= 1 //Contador Array SLX
	Local dDataBkp		:= dDataBase //Backup de Database
	Local aArea 		:= GetArea() //Salva a area atual
	Local aAreas		:= {} //Array com areas das tabelas
	Local aCab   		:= {} //Array do Cabeçalho da Venda
	Local aItem  		:= {} //Array dos Itens da Venda
	Local aParcela		:= {} //Array das Parcelas da Venda
	Local aErroAuto		:= {} //Logs de erro do ExecAuto
	Local aAux			:= {} //Array Auxiliar para armazenar Internald
	Local aInternal		:= {} //Array Auxiliar para armazenas InternalId gerado no Protheus
	Local aItensCanc	:= {} //Array contendo os itens cancelados
	Local oXmlContent	:= Nil //Objeto Xml com o conteudo da BusinessContent apenas
	Local lRps 			:= .F. //Flag RPS
	Local lNfce			:= .F. //Flag NFCe
	Local lTef			:= .F. //Flag Tef
	Local lCupCancel 	:= .F. //Flag de Venda cancelada
	Local lItCancel 	:= .F. //Flag de Item cancelado
	Local lCancVen   	:= .F. //Flag cancelamento de venda
	Local dDataPagto	:= dDataBase //Data de Pagamento
	Local cCancItem		:= ""   //Trata gravacao de itens cancelados
	Local cCancVen		:= ""   //Trata gravacao de venda cancelada
	Local lCancItem  	:= .F.  //Trata gravacao de itens cancelados
	Local aCancItem		:= {}	//Trata gravacao de itens cancelados
	Local nS			:= 0	//Trata gravacao de itens cancelados
	Local nSL2CSLL		:= 0	//Trata CSLL Retencao
	Local nBaseCSLL		:= 0	//Trata CSLL Retencao
	Local nAliqCSLL 	:= 0	//Trata CSLL Retencao
	Local nSL2IRRF		:= 0	//Trata valor IRRF
	Local nBaseIRRF		:= 0	//Trata base IRRF
	Local nAliqIRRF 	:= 0	//Trata aliquota IRRF
	Local nSL1CSLL		:= 0	//Trata CSLL
	Local nSL1IRRF		:= 0	//Trata IRRF
	Local nTroco		:= 0 	//Valor de troco
	Local nVlrItTot 	:= 0 	//Acumulado valor item
	Local nPosDescPro	:= 0 	//Posicao do campo Desconto Proporcional
	Local nVlMercTot	:= 0	//Valor Total das Mercadorias
	Local nVlrMercIt	:= 0 	//Valor Total das Mercadorias somadas nos itens
								//A partir da versão 2.004 criamos a TAG para separar o valor do Frete, caso o cliente
								//queira enviar o valor separado para o Protheus, na 2.003 o valor é enviado junto com a Despesa.
	Local nVlrItFrete   := 0    //Valor Proporcionalizado do Item 
	Local nVlrItDesp    := 0    //Valor Proporcionalizado das Despesas Acessórias
	Local nImpFed	 	:= 0	//Imposto Federal
	Local nImpEst 		:= 0	//Imposto Estadual
	Local nImpMun	 	:= 0 	//Imposto Municipal
	Local nImpFedSL1 	:= 0	//Imposto Federal	SL1
	Local nImpEstSL1 	:= 0	//Imposto Estadual SL1
	Local nImpMunSL1 	:= 0	//Imposto Municipal SL1
	Local cTaxSource 	:= ""	//Fonte do Imposto
	Local lReserva   	:= .F.
	Local cDataIn    	:= ""
	Local cTipoUH	 	:= ""
	Local cNumUH 		:= ""
	Local cHospede 		:= ""
	Local cOutrosHsp 	:= ""
	Local cGrupoRsv 	:= ""
	Local cEventoRsv 	:= ""
	Local cLanctos	 	:= ""
	Local aItemMh4	 	:= {}  //Itens reserva
	Local lNfe		 	:= .F. //Flag NFE
	Local lNfm			:= .F. //Flag NFM
	Local cTipoNF 	 	:= SuperGetMV("MV_TPNRNFS",, "1") //Tipo numeracao Nota Fiscal
	Local cFormaId 		:= "" //Id Forma Pagamento CC
	Local cNsu		 	:= "" //Codigo NSU
	Local cAutoriz	 	:= "" //Codigo AUTORIZACAO
	Local nPosNsu	 	:= 0 //Posicao campo NSU
	Local nPosAutoriz 	:= 0 //Posicao campo Autoriz
	Local nFormaId 		:= 0 //Numero Forma de Pagamento
	Local cChaveNFCe 	:= "" //Chave NFCe
	Local cProtoNFCe 	:= "" //Protocolo NFCe
	Local cRateio 		:= "" //Rateio de servicos
	Local cCCusto		:= SuperGetMv("MV_HTLCCRT",, "") //Centro de Custo
	Local cEntidade 	:= "" //Entidade
	Local cPercent		:= "" //Percentual rateio
	Local nPercent		:= 0 //Percentual numerico rateio
	Local lMultiNat 	:= SuperGetMV("MV_MULNATR",, .F.) //Ativa funcionalidade de MultiNatureza
	Local cArmazem		:= "" //Armazem Padrao
	Local cIdLoja		:= "" //Identificacao da loja
	Local cLjClvl	 	:= "" //Classe Valor
	Local cLjItemCC  	:= "" //Item Centro de Custo
	Local cLjCCusto  	:= "" //Centro de Custo
	Local cSerieSat		:= "" //Codigo Serie Sat
	Local lIntegHtl		:= SuperGetMv("MV_INTHTL",, .F.) //Integracao Hotelaria
	Local cCodResIt		:= "" //Codigo da Reserva do Item	
	Local cTpEntrega	:= "2" //Tipo da Entrega
	Local cFilRes		:= "" //Filial da Reserva
	Local aReserva		:= {}
	Local lPedVen		:= .F.
	Local cLoteItem		:= ""
	Local cSubLoteItem	:= ""
	Local cAddresItem	:= ""
	Local cSerieItem	:= ""
	Local nTotDesPro	:= 0 //Valor Acumulado do Desconto Total Proporcionalizado nos Itens 
	Local cUUID			:= ""//Guarda UUID na venda para facilitar a busca
	Local cNumMov		:= ""//Numero do movimento do caixa
	Local lSat 			:= .F.
	Local cDataEntr     := ""
	Local aIdLoja		:= {}
	Local cTimeIni		:= Time()
	Local cTimeFim		:= Time()
	Local nValFECP	  	:= 0 //Valor FECP
	Local nAlqFECP	  	:= 0 //Aliquota FECP
	Local nBasFECP 		:= 0 //Base FECP	
	Local nValFECPST  	:= 0 //Valor FECP_ST
	Local nAlqFECPST 	:= 0 //Aliquota FECP_ST	
	Local nBasFECPST 	:= 0 //Base FECP_ST		
	Local lL2FECP		:= SL2->(ColumnPos("L2_ALQFECP") > 0 .AND. ColumnPos("L2_VALFECP") > 0)
	Local lL2FECPST     := SL2->(ColumnPos("L2_ALQFCST") > 0 .AND. ColumnPos("L2_VFECPST") > 0)
	Local lL2BASFECPST  := SL2->(ColumnPos("L2_BSFCPST") > 0)
	Local lL1FECP		:= SL1->(ColumnPos("L1_VALFECP") > 0 .AND. ColumnPos("L1_BASFECP") > 0) .And. SLQ->(ColumnPos("LQ_VALFECP") > 0 .AND. ColumnPos("LQ_BASFECP") > 0)
	Local lL1FECPST     := SL1->(ColumnPos("L1_VFECPST") > 0 .AND. ColumnPos("L1_BSFCPST") > 0) .And. SLQ->(ColumnPos("LQ_VFECPST") > 0 .AND. ColumnPos("LQ_BSFCPST") > 0)
	Local nL1VlFECP 	:= 0 //Valor FECP
	Local nL1BsFECP 	:= 0 //Base FECP
	Local nL1VlFCPST 	:= 0 //Valor FECP_ST
	Local nL1BsFCPST 	:= 0 //Base FECP_ST
	
	
	Local lBaseIPI  	:= SL1->(ColumnPos("L1_BASEIPI")) > 0 .And. SL2->(ColumnPos("L2_BASEIPI")) > 0
	Local lAliqIPI  	:= SL2->(ColumnPos("L2_IPI")) > 0
	Local nSL1ValIpi	:= 0 //Valor de IPI na SL1
	Local nSL1BasIpi	:= 0 //Base de IPI na SL1
	Local nSL2ValIpi	:= 0 //Valor de IPI na SL2
	Local nSL2BasIpi	:= 0 //Base de IPI na SL2
	Local nSL2AlqIpi	:= 0 //Aliquota de IPI na SL2
	Local lAliqSOL  	:= SL2->(ColumnPos("L2_ALIQSOL")) > 0
	Local nSL1ValSol	:= 0 //Valor de ICMS Solidario na SL1
	Local nSL1BasSol	:= 0 //Base de ICMS Solidario na SL1
	Local nSL2ValSol	:= 0 //Valor de ICMS Solidario na SL2
	Local nSL2BasSol	:= 0 //Base de ICMS Solidario na SL2
	Local nSL2AlqSol	:= 0 //Aliquota de ICMS Solidario na SL2
	Local nVlrTab       := 0 //Valor da Tabela de Preço do Item
	Local cTransp		:= ""//Código da transportadora
    Local cAux          := ""
    Local cDocCanc      := ""
    Local aDoc          := {}
	
	Local cDtUlmes		:= SuperGetMV("MV_ULMES")
	Local cDtDblqMov	:= SuperGetMV("MV_DBLQMOV")
    Local cCSTPis       := ""   
    Local cCSTCof       := ""
    Local cCSTIcm       := ""
    Local lCSTIcm 		:= SLR->(ColumnPos("LR_CLASFIS")) > 0
    Local lCSTPIS 		:= SLR->(ColumnPos("LR_CSTPIS")) > 0  
    Local lCSTCOF 		:= SLR->(ColumnPos("LR_CSTCOF")) > 0 
    Local nTamDocNFD    := TamSx3("D1_DOC")[1]   // Tamanho do Doc na NF de devolução
    Local nTamSerNFD    := TamSx3("D1_SERIE")[1] // Tamanho da serie na NF de devolução
    Local nTamItNFD     := TamSx3("D1_ITEM")[1]  // Tamanho do item na NF de devolução
	Local cCodFor		:= "" //Codigo de fornecedor 
	Local cLojFor		:= "" //Loja do fornecedor   
	Local cKdOfDoc		:= "" //Guarda a especie da venda para posteriormente preencher a TAG KindOfDocument
	Local aItens		:= {} // -- Array que armazena os itens que ja foram para ao XML 

	Private lMsHelpAuto 	:= .T. //Variavel de controle interno do ExecAuto
	Private lMsErroAuto 	:= .F. //Variavel que informa a ocorrência de erros no ExecAuto
	Private lAutoErrNoFile 	:= .T. //força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário
	Private Inclui 			:= .T. //Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
	Private Altera 			:= .F. //Variavel necessária para o ExecAuto identificar que se trata de uma inclusão

	//Armazena areas das Tabelas
	aAdd(aAreas, SA1->(GetArea()))
	aAdd(aAreas, SAE->(GetArea()))
	aAdd(aAreas, SB0->(GetArea()))
	aAdd(aAreas, SB1->(GetArea()))
	aAdd(aAreas, SLF->(GetArea()))
	aAdd(aAreas, SLG->(GetArea()))
	aAdd(aAreas, SL1->(GetArea()))
	aAdd(aAreas, SL2->(GetArea()))
	aAdd(aAreas, SL4->(GetArea()))
	aAdd(aAreas, SLX->(GetArea()))
	aAdd(aAreas, SLJ->(GetArea()))
	aAdd(aAreas, SC0->(GetArea()))

	SL2->(dbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
	SL4->(dbSetOrder(1)) //L4_FILIAL+L4_NUM+L4_ORIGEM
	SLX->(dbSetOrder(1)) //LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM+LX_HORA

	cTimeIni := Time()

	LjGrvLog("LOJI701","INICIO DO PROCESSO: "+cTimeIni)

	//Mensagem de Recebimento
	If nTypeTrans == TRANS_RECEIVE
	
		LjGrvLog("LOJI701","INICIO RECEBIMENTO: "+Time())

		//------------------------------------------------------------
		//Tratamento utilizando a tabela XXF com um De/Para de codigos
		//------------------------------------------------------------                   		   		                                                           		
		If FindFunction("CFGA070INT")

   			//Valida Estado de Cobranca da filial
			If Empty(SM0->M0_ESTCOB)
				lRet    := .F.
				cXMLRet := STR0059 + Chr(10) + STR0060 //#"Foi detectado que o campo referente ao estado de cobranca(M0_ESTCOB) nao esta configurado." ##"Efetue a inclusao no cadastro de filiais no Protheus."
			EndIf
   		
			If lRet

				//Marca
				If oXmlL701:_TotvsMessage:_MessageInformation:_Product:_Name:Text <> Nil .And. !Empty(oXmlL701:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
					cMarca := oXmlL701:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				EndIf
			
				If Empty(cMarca)
					lRet    := .F.
					cXMLRet := STR0004 //#"Marca nao integrada ao Protheus, verificar a marca da integracao"
				EndIf
			EndIf
			
			If lRet
				If oXmlL701:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text <> Nil .And. !Empty(oXmlL701:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
					If AllTrim(Upper(oXmlL701:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)) == "DELETE"
						lRet    := .F.
						cXMLRet := STR0081 //#"Evento incorreto, para exclusao utilize a integracao de Cancelamento de Venda."
					EndIf
				Else
					lRet    := .F.
					cXMLRet := STR0082 //#"Evento nao informado!"
				EndIf
			EndIf
			
			If lRet
				
				//Gera objeto para carga de Vendas
				oXmlContent := oXmlL701:_TOTVSMessage:_BusinessMessage:_BusinessContent
				LjGrvLog("LOJI701","GEROU OBJETO DE CARGA DE VENDAS: "+Time())

				//Armazena chave externa
				cIdExt := LjiVldTag(oXmlContent, "_INTERNALID")
			
				If Empty(cIdExt)
					lRet	 := .F.
					cXmlRet := STR0021 //#"Campo obrigatorio nao informado: Id Interno, verifique a tag: InternalId."
				EndIf
			EndIf
		
			If lRet
				
				//Verifica evento inclusao ou alteracao
				aAux := IntVendInt(cIdExt, cMarca)
          		
          		//Se encontrou o cupom no de-para
				If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
					nOpcX := 2 //Alteracao
				Else
					nOpcX := 3 //Inclusao
				EndIf
									
				//Evento Inclusao
				If 	nOpcX == 3
					cCancVen := LjiVldTag(oXmlContent, "_ISCANCELED") //Trata gravacao de venda cancelada
					lCancVen := IIf(cCancVen == "true",.T.,.F.) //Trata gravacao de venda cancelada
				
					//Para venda cancelada, altera controle de orcamento para que venda seja cancelada apos ser processada
					If lCancVen
						cSituaOrc := "E"
					EndIf
														
					cTpVenda := AllTrim(Upper(LjiVldTag(oXmlContent, "_KINDOFDOCUMENT"))) //Tipo do documento
					cMenNota := Padr(LjiVldTag(oXmlContent, "_INVOICEMESSAGES"), TamSx3("L1_MENNOTA")[1]) //Mensagem da Nota Fiscal	
										
					cUUID 	:= Padr(oXmlL701:_TotvsMessage:_MessageInformation:_Uuid:Text, TamSx3("L1_UMOV")[1])					
					cNumMov := Padr(LjiVldTag(oXmlContent, "_MOVEMENTNUMBER"), TamSx3("L1_NUMMOV")[1])
					cNumMov := IIF(!Empty(cNumMov),STRZERO(Val(cNumMov),TamSx3("L1_NUMMOV")[1]),"")

                    LjGrvLog("LOJI701","UUID: " + cUUID)
					
					If Empty(cTpVenda)
						lRet 	 := .F.
						cXmlRet := STR0097 //#"Tipo de venda nao informada, verifique a tag: KindOfDocument"
					Else
						If cTpVenda == "NFCE"
							lNfce := .T.
						ElseIf cTpVenda == "NFM"
							lNfm := .T.
						ElseIf cTpVenda == "NFE"
							lNfe 		:= .T.
							cTpVenda	:= "SPED" //quando venda tem como origem a integração a rotina LjGrvSF2() considera a especie do campo L1_ESPECIE, no Protheus a especie para para NF-e eh "SPED"
						ElseIf cTpVenda == "RPS"
							lRps := .T.
						ElseIf cTpVenda == "SATCE"
							lSat := .T.
						EndIf
					
                        //Tratamento para nota sobre Cupom
                        If !XmlChildEx(oXmlContent, "_SALETYPE") == NIL .And. !Empty(oXmlContent:_SaleType:Text)
                            cTipoVen := AllTrim(UPPER(oXmlContent:_SaleType:Text))

                            If ExistFunc("LjI130NSC") .And. cTipoVen == "R" //R - Nota sobre Cupom                                
                                lRet := LjI130NSC(oXmlContent, @cXmlRet,cMarca)
                                Return lRet 
                            EndIf

                        Endif 


						//Nota Fiscal Manual, NFe ou RPS, obrigatorio informar Serie
						If lNfm .Or. lNfe .Or. lRps

							//Armazena a Serie informada na integracao			
							cSerie := Padr(LjiVldTag(oXmlContent, "_SERIECODE"), TamSx3("L1_SERIE")[1])
						
							//Validacao da Serie
							If Empty(cSerie)
								lRet 	 := .F.
								cXmlRet := STR0076 //"Serie nao informada na integracao, informacao obrigatoria para Nota Manual ou NFE, verifique a tag: SerieCode"
							EndIf
						EndIf
					EndIf
			
					If lRet
						If lNfe .AND. Empty(AllTrim(Upper(LjiVldTag(oXmlContent, "_KEYACESSNFE")))) //Gera Numeracao quando nao existir Chave
							If AllTrim(cTipoNF) == "3"
								cDoc := MA461NumNf(.T., cSerie)
							Else
								cDoc := NxtSX5Nota(cSerie, .T., cTipoNF)
							EndIf
                        Else
                            aDoc := STRTOKARR( LjiVldTag(oXmlContent, "_DOCUMENTCODE"), "|" )
                        
                            If lCancVen .and. len(aDoc) > 1                            
                                cDocCanc := aDoc[2]
                            EndIf

                            cDoc     := Padr(aDoc[1], TamSx3("L1_DOC")[1])					
						EndIf
                        
						//Validacao da Doc							
						If Empty(cDoc)
							lRet 	 := .F.
							cXmlRet := STR0006 //#"Cupom nao informado, verificar a tag: DocumentCode"
						Else
							If Val(cDoc) == 0
								lRet	:= .F.
								cXmlRet := STR0126 //#"Número do cupom inválido, , verificar a tag: DocumentCode" 
							Else
								//Tratamento tamanho Doc
								cDoc := Padr(cDoc, TamSx3("LQ_DOC")[1])
							EndIf
						EndIf
					EndIf
         
					If lRet
						
						//Rps/Nfe/Nota Manual
						If lRps .Or. lNfe .Or. lNfm
							cTipoOrc  	:= ""
							cTipoVen  	:= "V"
							cPdv 		:= "001"
							
							If !Empty(AllTrim(Upper(LjiVldTag(oXmlContent, "_KEYACESSNFE"))))
								cChaveNFCe := LjiVldTag(oXmlContent, "_KEYACESSNFE") 	//Chave NFCe
								cProtoNFCe := LjiVldTag(oXmlContent, "_NFCEPROTOCOL") 	//Protocolo NFCe
							Endif
						
						//Cupom/NFCe/Sat							
						Else

							//Carrega a estação
							aAux := LjI701Esta(cMarca, LjiVldTag(oXmlContent, "_STATIONSALEPOINTCODE"), LjiVldTag(oXmlContent, "_STATIONSALEPOINTINTERNALID"), LjiVldTag(oXmlContent, "_STATIONCODE") )

							If !aAux[1]
								lRet	:= .F.
								cXmlRet := aAux[2]

							Else

								cEstac := aAux[2]

								//Posiciona na Estacao do Protheus
								SLG->(dbSetOrder(1))
					
								If !SLG->(dbSeek(xFilial("SLG") + cEstac))
									lRet 	 := .F.
									cXmlRet := STR0011 + " " + cEstac + " " + STR0026 //#"Estacao:" ##"nao encontrada no Protheus, verificar o cadastro ou integracao de Estacao."
								Else

									//Armazena Estacao
									cEstacao := cEstac
							
									//Inicializa a Serie
									cSerie	:= SLG->LG_SERIE
														
									//Pdv
									cPdv := SLG->LG_PDV
																								
									If lNfce
										cTipoOrc  := "E"
										cTipoVen  := ""
									
										cChaveNFCe := LjiVldTag(oXmlContent, "_KEYACESSNFE") 	//Chave NFCe
										cProtoNFCe := LjiVldTag(oXmlContent, "_NFCEPROTOCOL") 	//Protocolo NFCe
										cSerie 	   := Padr(LjiVldTag(oXmlContent, "_SERIECODE"), TamSx3("L1_SERIE")[1])
										If Empty(cSerie)
											cSerie	:= SLG->LG_SERIE
										EndIf
									Else
										cTipoOrc  := ""
										cTipoVen  := "V"
										
										If lSat
											cSerieSat  := LjiVldTag(oXmlContent, "_SERIALNUMBERSATEQUIPAMENT") //Serie Sat
											
											//Busca a Serie na SLG com base da Serie do Equipamento SAT
											If !Empty(cSerieSat)
												cSerie := LjiSerSLG(cSerie,cSerieSat)
											Else
												lRet 	 := .F.
												cXmlRet := STR0127 //#"Série SAT não enviada, informacao obrigatória para venda SAT, verifique a tag SERIALNUMBERSATEQUIPAMENT"	
											EndIf
										EndIf
										
									EndIf
								
									//Validacoes
									If Empty(cSerie)
										lRet 	 := .F.
										cXmlRet := STR0077 //"Serie nao cadastrada, verifique o campo Serie do Cadastro de Estacoes no Protheus"
									ElseIf lNfce .And. Empty(cChaveNFCe)
										lRet 	 := .F.
										cXmlRet := STR0094 //#"Chave NFCe nao enviada, informacao obrigatoria para venda NFCe, verifique a tag KeyAcessNfe"	
									ElseIf lNfce .And. Len(cChaveNFCe) < 44
										lRet 	 := .F.
										cXmlRet := STR0128 //#"Chave NFCe menor que o padrão, verifique a tag: KeyAcessNfe"									
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					
					//TRATAMENTO PARA UTILIZACAO DE FORNECEDORES
	     	        If !XmlChildEx(oXmlContent, "_SALETYPE") == NIL .And.;
	     	           !Empty(oXmlContent:_SaleType:Text)
						cTipoVen := UPPER(oXmlContent:_SaleType:Text)
					Endif    
					
					LjGrvLog("LOJI701","VERIFICAÇÃO TIPO DE VENDA: "+Time())
								         		
					If lRet
						cValExt := LjiVldTag(oXmlContent, "_CUSTOMERVENDORINTERNALID")  //carrega o codigo que pode ser do cliente ou fornecedor, depende do tipo de nota, quando devolução esse codigo eh do forncedor
						
						If !cTipoVen $ "B|D" 
				
							If !Empty(cValExt)
								aAux := IntCliInt(cValExt, cMarca)
			          		
			          			//Se encontrou o cliente no de-para
								If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
									cCodCli := PadR(aAux[2][3], TamSX3("A1_COD")[1])
									cLojCli := PadR(aAux[2][4], TamSX3("A1_LOJA")[1])
								Else
									lRet := .F.
									cXmlRet := STR0007 + " " + AllTrim(cValExt) + " " + STR0008 //#"Cliente: " ##"nao integrado ao Protheus, verificar integracao de clientes"
								EndIf
							
							//Utiliza cliente padrao								
							Else
								cCodCli := Padr(SuperGetMv("MV_CLIPAD",, "000001"), TamSX3("A1_COD")[1])
								cLojCli := Padr(SuperGetMv("MV_LOJAPAD",, "01"), TamSX3("A1_LOJA")[1])
							EndIf
						Else
						
							aAux := IntForInt(cValExt, cMarca) //verifica se o código enviado existe no De-Para de Fornecedor

							//Se possuir o De-Para de Fornecedor, verifica se possui o CNPJ do fornecedor na tabela SA1, se não existir inclui para utilizar no registro da F2_CLIENTE
							If aAux[1]
								
								DbSelectArea("SA2")
								SA2->(DbSetOrder(1))
								IF(SA2->(DbSeek(xFilial("SA2")+ PadR(aAux[2][3], TamSX3("A2_COD")[1])+PadR(aAux[2][4], TamSX3("A2_LOJA")[1]) )))

                                    cCodFor := PadR(aAux[2][3], TamSX3("A2_COD")[1]) 
                                    cLojFor := PadR(aAux[2][4], TamSX3("A2_LOJA")[1])

									DbSelectArea("SA1")
									SA1->(DbSetOrder(3))
									If!(SA1->(DbSeek(xFilial("SA1")+SA2->A2_CGC)))
										_aCliente:= STARTJOB("LjGerClif", GetEnvServer(), .T., CEMPANT, CFILANT,SA2->A2_CGC)
										
										If _aCliente[1]
											cCodCli := _aCliente[2]
											cLojCli := _aCliente[3]
										Else
											lRet := .F.
											cXmlRet := STR0007 + " " + AllTrim(cValExt) + " " + STR0008 + "[01] "+_aCliente[4] //#"Cliente: " ##"nao integrado ao Protheus, verificar integracao de clientes" 
										Endif
									Else	
										cCodCli := SA1->A1_COD
										cLojCli := SA1->A1_LOJA									
									Endif
								Else
									lRet := .F.
									cXmlRet := STR0007 + " " + AllTrim(cValExt) + " " + STR0008 //#"Cliente: " ##"nao integrado ao Protheus, verificar integracao de clientes" 
								Endif
							Else
								
								cCpfCli := LjiVldTag(oXmlContent, "_PERSONALIDENTIFICATION")
								If Empty(cCpfCli)
									lRet := .F.
									cXmlRet := "Nota do tipo D/B sem Forncedor Identificado, verificar o CNPJ da entidade." 
								Endif
								
								DbSelectArea("SA2")
								SA2->(DbSetOrder(3))
								If(SA2->(DbSeek(xFilial("SA2")+cCpfCli)))  //quando não encontra o fornecedor na tabela De-Para, verifica se possui fornecedor com o CNPJ informado
									cCodFor := PadR(aAux[2][3], TamSX3("A2_COD")[1]) 
                                    cLojFor := PadR(aAux[2][4], TamSX3("A2_LOJA")[1])
									//Inclui De-Para de Forncedor para não precisar mais pesquisar por CNPJ
									CFGA070Mnt(cMarca,"SA2","A2_COD",cValExt,IntForExt(, , SA2->A2_COD, SA2->A2_LOJA)[2],.F.)
									DbSelectArea("SA1")
									SA1->(DbSetOrder(3))
									If!(SA1->(DbSeek(xFilial("SA1")+SA2->A2_CGC)))
										
										_aCliente:= STARTJOB("LjGerClif", GetEnvServer(), .T., CEMPANT, CFILANT,SA2->A2_CGC)
										
										If _aCliente[1]
											cCodCli := _aCliente[2]
											cLojCli := _aCliente[3]
										Else
											lRet := .F.
											cXmlRet := STR0007 + " " + AllTrim(cValExt) + " " + STR0008 + "[02] "+_aCliente[4] //#"Cliente: " ##"nao integrado ao Protheus, verificar integracao de clientes" 
										Endif
									Else
										cCodCli := SA1->A1_COD
										cLojCli := SA1->A1_LOJA
									Endif
								Else
									lRet := .F.
									cXmlRet := "Nota do tipo D/B sem Forncedor Identificado, verificar o CNPJ da entidade." 
								Endif
							Endif
						EndIf
					Endif
					
					LjGrvLog("LOJI701","POSICIONA CLIENTE: "+Time())
					
					If lRet
		          		//Posiciona no cliente do Protheus
						SA1->(dbSetOrder(1))
		          	
						If !SA1->(dbSeek(xFilial("SA1") + cCodCli + cLojCli))
							lRet := .F.
							cXmlRet := STR0007 + " " + AllTrim(cCodCli) + "/" + STR0017 + " " + cLojCli + " " + STR0019 //#"Cliente:" ##"Loja:"###"nao cadastrado no Protheus, verifique o cadastro de clientes."
						EndIf
					
						If lRet
							//Verifica se Cliente esta bloqueado
							If SA1->A1_MSBLQL == "1"
								lRet := .F.
								cXmlRet := STR0007 + " " + AllTrim(cCodCli) + "/" + STR0017 + " " + cLojCli + " " + STR0075 //#"Cliente:" ##"Loja:"###"bloqueado, verifique o Cadastro de Clientes no Protheus."
							EndIf
						
							If lRet
								//Cpf do Cliente, utilizado caso deseja CPF na Nota			
								cCpfCli := LjiVldTag(oXmlContent, "_PERSONALIDENTIFICATION")

								//Carrega Operador\Caixa
								aAux := LjI701Oper(cMarca, LjiVldTag(oXmlContent, "_OPERATORCODE"), LjiVldTag(oXmlContent, "_OPERATORINTERNALID"))
								
								If aAux[1]
									cOperador := aAux[2]
								Else
									//Tenta novamente trocando as posicoes do internal e external para manter legado
									aAux := LjI701Oper(cMarca,  LjiVldTag(oXmlContent, "_OPERATORINTERNALID") ,   LjiVldTag(oXmlContent, "_OPERATORCODE"))
									If aAux[1]
										cOperador := aAux[2]
									Else	
										lRet	:= .F.
										cXmlRet := aAux[2]
									EndIf	

								EndIf
							EndIf
						EndIf
					EndIf

					If lRet
						//Data de Emissao
						cEmissao := LjiVldTag(oXmlContent, "_ISSUEDATEDOCUMENT", "D")
					
						If Empty(cEmissao)
							lRet 	 := .F.
							cXmlRet := STR0020 //#"Campo obrigatorio nao informado: Data de Emissao, verifique a tag: IssueDateDocument."
						Else
							If cEmissao <= DtoS(cDtUlmes)		
								lRet 	 := .F.
								cXmlRet := STR0129 //"Data de Emissao menor que a data do fechamento do parâmetro: MV_ULMES"
							EndIf
							
							If lRet .And. cEmissao <= DtoS(cDtDblqMov)
								lRet 	 := .F.
								cXmlRet := STR0130 //"Data de Emissao menor que a data do fechamento do parâmetro: MV_DBLQMOV"
							EndIf	
											
						EndIf
					
						If lRet
							cTimeEmis := LjiVldTag(oXmlContent, "_ISSUEDATEDOCUMENT", "T")
																										
							//Validacoes de campos obrigatorios															
							If XmlChildEx(oXmlContent, "_TOTALPRICE") == Nil .Or. Empty(oXmlContent:_TotalPrice:Text)
								lRet 	 := .F.
								cXmlRet := STR0027 //#"Campo obrigatorio nao informado: Valor Total da Venda, verifique a tag: TotalPrice."
							ElseIf XmlChildEx(oXmlContent, "_NETPRICE") == Nil .Or. Empty(oXmlContent:_NetPrice:Text)
								lRet 	 := .F.
								cXmlRet := STR0028 //#"Campo obrigatorio nao informado: Valor Liquido da Venda, verifique a tag: NetPrice."
							ElseIf XmlChildEx(oXmlContent, "_GROSSPRICE") == Nil .Or. Empty(oXmlContent:_GrossPrice:Text)
								lRet 	 := .F.
								cXmlRet := STR0029 //#"Campo obrigatorio nao informado: Valor Bruto da Venda, verifique a tag: GrossPrice."
							EndIf
						
							If lRet
								If lIntegHtl //Hotelaria
									//Grava informações de reserva que serão utilizadas para as descrições de serviços na NFS-e (Integração com hotelaria)
									If XmlChildEx(oXmlContent, "_BOOKINGINFORMATION") <> Nil
										lReserva 	:= .T.
										cReserva 	:= LjiVldTag( oXmlContent:_BookingInformation, "_HOTELACCOUNTCODE", "C" ) //Numero da Reserva
										cDataIn  	:= LjiVldTag( oXmlContent:_BookingInformation, "_CHECKINDATE", "D" ) //Data de checkin da reserva
										cTipoUH  	:= LjiVldTag( oXmlContent:_BookingInformation, "_HABITATIONALUNITTYPE", "C" ) //Tipo de unidade habitacional
										cNumUH   	:= LjiVldTag( oXmlContent:_BookingInformation, "_HABITATIONALUNITNUMBER", "C" ) //Número da unidade habitacional
										cHospede 	:= LjiVldTag( oXmlContent:_BookingInformation, "_MAINGUESTNAME", "C" ) //Nome do hóspede principal
										cOutrosHsp	:= LjiVldTag( oXmlContent:_BookingInformation, "_ADDITIONALGUESTNAME", "C" ) //Nome dos demais hóspedes
										cGrupoRsv 	:= LjiVldTag( oXmlContent:_BookingInformation, "_GROUPNAME", "C" ) //Nome do grupo da reserva
										cEventoRsv	:= LjiVldTag( oXmlContent:_BookingInformation, "_EVENTNAME", "C" ) //Nome do evento da reserva
									EndIf
								EndIf
																									
								//Valor de Comissao do Vendedor
								nPerComis := Val(LjiVldTag(oXmlContent, "_COMMISSIONPERCENT", "N"))
						
								//De-Para Fornecedor
								cValExt := LjiVldTag(oXmlContent, "_SELLERINTERNALID")
										
								If !Empty(cValExt)
									cVendedor := CFGA070INT(cMarca, "SA3", "A3_COD", cValExt)
								
									//Separa o retorno 
									aAux := Separa(cVendedor, "|")
								
									//Verifica se encontrou vendedor no De/Para
									If ValType(aAux) == "A" .And. Len(aAux) >= 3
										cVendedor := PadR(aAux[3], TamSX3("A3_COD")[1])
									Else
										lRet 	 := .F.
										cXmlRet :=  STR0079 + " " + AllTrim(cValExt) + " " + STR0080 //#"Vendedor:" ##"nao integrado no Protheus, verifique a integracao de Vendedores."
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
							
					If lRet
						//Validacao do Vendedor				          		          		          		          		          		          		          		
						If Empty(cVendedor)
							//Se venda possui comissao, deve informar o vendedor          	 
							If nPerComis > 0
								lRet := .F.
								cXmlRet := STR0078 //#"Vendedor nao informado, obrigatorio para venda com comissao, verifique a tag: SellerInternalId."
							Else
								cVendedor := SuperGetMv("MV_VENDPAD",, "000001")
							EndIf
						EndIf
		          	 
						If lRet
							//Armazena Valor Total da Venda
							nVlrTot    := Val(oXmlContent:_TotalPrice:Text)
							nVlrLiq    := Val(oXmlContent:_NetPrice:Text)
							nVlMercTot := Val(LjiVldTag(oXmlContent, "_COMMODITYPRICE", "N"))
						
							//Armazena Desconto no Total da Venda
							nValDesTot := Val(LjiVldTag(oXmlContent, "_DISCOUNTVALUE", "N"))
							nPerDesTot := Val(LjiVldTag(oXmlContent, "_DISCOUNTPERCENT", "N"))
						
							If lIntegHtl //Hotelaria
								//Armazena informacoes de rateio						
								cRateio  := "" //Inicializa variavel de rateio
								nPercent := 0 //Inicializa percentual de rateio
							
								If	XmlChildEx(oXmlContent, "_LISTOFFINANCIALNATUREAPPORTIONMENT") <> Nil .And.;
										XmlChildEx(oXmlContent:_ListOfFinancialNatureApportionment, "_FINANCIALNATUREAPPORTIONMENT") <> Nil
									If lRps
										If lMultiNat
											//Monta Array com Rateio	            					
											If ValType(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment) <> "A"
												XmlNode2Arr(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment, "_FinancialNatureApportionment")
											EndIf
									
											For nI := 1 To Len(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment)
												If	XmlChildEx(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI], "_LISTOFCOSTCENTERAPPORTIONMENT") <> Nil .And.;
														XmlChildEx(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment, "_COSTCENTERAPPORTIONMENT") <> Nil
												
													//Monta array com Entidades de rateio
													If ValType(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment) <> "A"
														XmlNode2Arr(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment, "_CostCenterApportionment")
													EndIf
												
													For nX := 1 To Len(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment)
														If lRet
															//Centro de Custo										 														  																																																														
															If Empty(cCCusto)
																lRet 	 := .F.
																cXmlRet := STR0101 //#"Centro de Custo nao informado, obrigatorio quando utilizado rateio, verifique no Protheus o parametro: MV_HTLCCRT"
																Exit
															EndIf
														
															//Entidade
															cValExt := LjiVldTag(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment[nX], "_GENERICENTITYINTERNALID")
															aAux := IntGerInt(cValExt, cMarca,  "1.000")
														
															cEntidade := "" //Inicializa entidade
														
															If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
																cEntidade := PadR(aAux[2][4], TamSX3("EZ_EC05DB")[1])
															EndIf
														
															If Empty(cEntidade)
																lRet 	 := .F.
																cXmlRet := STR0098 //#"Entidade nao informada ou nao integrada ao Protheus para rateio, verifique a lista: ListOfFinancialNatureApportionment, tag: GenericEntityInternalId."
																Exit
															EndIf
														
															cPercent := LjiVldTag(oXmlContent:_ListOfFinancialNatureApportionment:_FinancialNatureApportionment[nI]:_ListOfCostCenterApportionment:_CostCenterApportionment[nX], "_PERCENTAGE", "N")
													
															//Valida se percentual foi enviado
															If Empty(cPercent)
																lRet 	 := .F.
																cXmlRet := STR0099 //#"Percentual de rateio nao informado no rateio, verifique a lista: ListOfFinancialNatureApportionment, tag: Percentage."
																Exit
															EndIf
													
															cRateio += "#"
															cRateio += "*" + cCCusto //Centro de Custo
															cRateio += "*" + cEntidade //Entidade
															cRateio += "*" + cPercent //Percentual
													
															nPercent += Val(cPercent)
														EndIf
													Next nX
												EndIf
											Next nI
										Else
											lRet 	 := .F.
											cXmlRet := STR0102 + "," + STR0103 //#"Para utilizar informacoes de rateio tag: ListOfFinancialNatureApportionment" ##"é necessário habilitar o parametro MV_MULNATR no Protheus."
										EndIf
									Else
										lRet 	 := .F.
										cXmlRet := STR0104 + "," + STR0105 //#"Esta mensagem possui informacoes de rateio tag: ListOfFinancialNatureApportionment mas nao é uma RPS"##"verifique a tag: KindOfDocument."
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
												
					If lRet
						//Armazena impostos do Cabecalho da Venda
						If	XmlChildEx(oXmlContent, "_LISTOFTAXES") <> Nil .And.;
								XmlChildEx(oXmlContent:_ListOfTaxes, "_TAX") <> Nil
						
							//Monta Array com Impostos	            					
							If ValType(oXmlContent:_ListOfTaxes:_Tax) <> "A"
								XmlNode2Arr(oXmlContent:_ListOfTaxes:_Tax, "_Tax")
							EndIf
						
							For nI := 1 To Len(oXmlContent:_ListOfTaxes:_Tax)
								Do Case
								Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) == "ICM" //Icms
									nSL1Icms += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
								Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) == "ISS" //Iss
									nSL1Iss += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
								Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) == "PIS" //Pis
									nSL1Pis += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
								Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) == "COFINS" //Cofins
									nSL1Cof += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
								Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) == "CSLL" //CSLL
									nSL1CSLL += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
								Case "IRRF" $ AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) //IRRF
									nSL1IRRF += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
								Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) == "FECP" //FECP
									nL1VlFECP += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
									nL1BsFECP += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_CALCULATIONBASIS", "N"))
								Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) == "FECP_ST" //FECP_ST
									nL1VlFCPST += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
									nL1BsFCPST += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_CALCULATIONBASIS", "N"))
								Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) == "IPI" //IPI
									nSL1ValIpi += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
									nSL1BasIpi += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_CALCULATIONBASIS", "N"))
								Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_TAXE"))) == "ICMS_ST" //ICMS-ST
									nSL1ValSol += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_VALUE", "N"))
									nSL1BasSol += Val(LjiVldTag(oXmlContent:_ListOfTaxes:_Tax[nI], "_CALCULATIONBASIS", "N"))
								EndCase
							Next nI
						EndIf
					EndIf
					
					//Pega a Transportadora
					If lRet 
						aAux := Lj701ITran( cMarca, nTypeTrans, LjiVldTag(oXmlContent, "_CARRIERCODE"), LjiVldTag(oXmlContent, "_CARRIERINTERNALID") )
						lRet := aAux[1]
						
						If lRet
							cTransp := aAux[2]
						Else
							cXmlRet := aAux[2]						
						EndIf
					EndIf
															
					If lRet
						nTroco := Val(LjiVldTag(oXmlContent, "_CHANGE", "N")) //Armazena valor de troco
	
						//Lei de Transparencia 
						If	XmlChildEx(oXmlContent, "_STATETAXBURDEN") <> Nil
							nImpEstSL1 := Val(LjiVldTag(oXmlContent,  "_STATETAXBURDEN", "N"))
						EndIf
						If	XmlChildEx(oXmlContent, "_MUNICIPALTAXBURDEN") <> Nil
							nImpMunSL1 := Val(LjiVldTag(oXmlContent,  "_MUNICIPALTAXBURDEN", "N"))
						EndIf
						If	XmlChildEx(oXmlContent, "_FEDERALTAXBURDEN") <> Nil
							nImpFedSL1 := Val(LjiVldTag(oXmlContent,  "_FEDERALTAXBURDEN", "N"))
						EndIf
						If	XmlChildEx(oXmlContent, "_TAXSOURCE") <> Nil
							cTaxSource := LjiVldTag(oXmlContent,  "_TAXSOURCE", "C")
						EndIf
						
						//Chave SAT
						If !Empty(cSerieSat)
							cChaveNFCe := LjiVldTag(oXmlContent, "_KEYACESSNFE")
						EndIf									
						 	          		
						/* Efetua a carga das tabela SLQ */
						LjGrvLog("LOJI701","GRAVAÇÃO ACAB: "+Time())

						//Alimenta array cabeçalho da venda											   				   				   				   		   		           	                 
						aCab := {	{"LQ_VEND"  	, cVendedor														, Nil},;
									{"LQ_COMIS" 	, nPerComis														, Nil},;
									{"LQ_VALCOMI" 	, 0																, Nil},;
									{"LQ_CLIENTE" 	, cCodCli	    												, Nil},;
									{"LQ_LOJA"  	, cLojCli		   												, Nil},;
									{"LQ_TIPOCLI" 	, SA1->A1_TIPO						          					, Nil},;
									{"LQ_VLRTOT"  	, nVlrTot														, Nil},;
									{"LQ_DESCONT" 	, nValDesTot													, Nil},;
									{"LQ_VLRLIQ"  	, nVlrLiq														, Nil},;
									{"LQ_DTLIM"  	, dDatabase 													, Nil},;
									{"LQ_DINHEIR" 	, Val(LjiVldTag(oXmlContent, "_CASHVALUE", "N"))				, Nil},;
									{"LQ_CHEQUES"	, Val(LjiVldTag(oXmlContent, "_CHECKSVALUE", "N"))				, Nil},;
									{"LQ_CARTAO"	, Val(LjiVldTag(oXmlContent, "_CARDSVALUE", "N"))				, Nil},;
									{"LQ_VLRDEBI"	, Val(LjiVldTag(oXmlContent, "_DEBITVALUE", "N"))				, Nil},;
									{"LQ_CONVENI"	, Val(LjiVldTag(oXmlContent, "_COVENANTVALUE", "N"))			, Nil},;
									{"LQ_VALES"		, Val(LjiVldTag(oXmlContent, "_VOUCHERSVALUE", "N"))			, Nil},;
									{"LQ_FINANC"	, Val(LjiVldTag(oXmlContent, "_FINANCEDVALUE", "N"))			, Nil},;
									{"LQ_OUTROS"	, Val(LjiVldTag(oXmlContent, "_OTHERSVALUE", "N"))				, Nil},;
									{"LQ_ENTRADA"	, Val(LjiVldTag(oXmlContent, "_INPUTVALUE", "N"))				, Nil},;
									{"LQ_EMISSAO" 	, SToD(cEmissao)   												, Nil},;
									{"LQ_NUMCFIS" 	, IIF(lRps, "", cDoc)											, Nil},;
									{"LQ_HORA"  	, cTimeEmis														, Nil},;
									{"LQ_DOC"		, cDoc															, Nil},;
									{"LQ_SERIE"		, cSerie  														, Nil},;
									{"LQ_PDV"		, cPdv															, Nil},;
									{"LQ_EMISNF"	, SToD(cEmissao)												, Nil},;
									{"LQ_VALBRUT"	, Val(oXmlContent:_GrossPrice:Text)						  		, Nil},;
									{"LQ_VALMERC"	, IIF(nVlMercTot > 0, nVlMercTot, nVlrTot)						, Nil},;
									{"LQ_TIPO"		, cTipoVen														, Nil},;
									{"LQ_TIPORC"	, cTipoOrc														, Nil},;
									{"LQ_DESCNF"	, nPerDesTot													, Nil},;
									{"LQ_OPERADO"	, cOperador  													, Nil},;
									{"LQ_SITUA"		, cSitua   														, Nil},;
									{"LQ_STORC"		, cSituaOrc  													, Nil},;
									{"LQ_VALICM"	, nSL1Icms          											, Nil},;
									{"LQ_VALISS"	, nSL1Iss														, Nil},;
									{"LQ_TXMOEDA"	, Val(LjiVldTag(oXmlContent, "_CURRENCYRATE", "N"))				, Nil},;
									{"LQ_MOEDA"		, nMoeda								   						, Nil},;
									{"LQ_TROCO1"	, nTroco														, Nil},;
									{"LQ_ESTACAO"	, cEstac   														, Nil},;
									{"LQ_DOCRPS"	, IIF(lRps, cDoc, "")											, Nil},;
									{"LQ_SERRPS"	, IIF(lRps, cSerie, "")											, Nil},;
									{"LQ_DOCPED"	, ""   															, Nil},;
									{"LQ_SERPED"	, ""   															, Nil},;
									{"LQ_CONDPG"	, cCondPg   													, Nil},;
									{"LQ_ESPECIE"	, cTpVenda														, Nil},;
									{"LQ_DESCFIN"	, Val(LjiVldTag(oXmlContent, "_DISCOUNTPAYMENTTERM", "N"))		, Nil},;
									{"LQ_ICMSRET"	, nSL1ValSol+nL1VlFCPST											, Nil},;
									{"LQ_BRICMS"	, nSL1BasSol													, Nil},;
									{"LQ_CREDITO"	, Val(LjiVldTag(oXmlContent, "_CREDITVALUE", "N"))				, Nil},;
									{"LQ_ORIGEM"	, "N"															, Nil},;
									{"LQ_VENDTEF"	, ""															, Nil},;
									{"LQ_DATATEF"	, ""															, Nil},;
									{"LQ_HORATEF"	, ""															, Nil},;
									{"LQ_DOCTEF"	, ""															, Nil},;
									{"LQ_AUTORIZ"	, ""															, Nil},;
									{"LQ_DOCCANC"	, ""									    					, Nil},;
									{"LQ_DATCANC"	, ""															, Nil},;
									{"LQ_HORCANC"	, ""															, Nil},;
									{"LQ_INSTITU"	, ""															, Nil},;
									{"LQ_NSUTEF"	, ""															, Nil},;
									{"LQ_VALPIS"	, nSL1Pis														, Nil},;
									{"LQ_VALCOFI"	, nSL1Cof														, Nil},;
									{"LQ_VALCSLL"	, nSL1CSLL														, Nil},;
									{"LQ_VALIPI"    , nSL1ValIpi                                                    , Nil},;
									{"LQ_CGCCLI"	, cCpfCli														, Nil},;
									{"LQ_DESPESA"	, Val(LjiVldTag(oXmlContent, "_INCREASEVALUE", "N"))			, Nil},;
									{"LQ_FRETE"		, Val(LjiVldTag(oXmlContent, "_FREIGHTVALUE", "N"))				, Nil},;
									{"LQ_TPFRET"	, IIF(Val(LjiVldTag(oXmlContent,"_FREIGHTVALUE","N"))>0,"F","S"), Nil},;								
									{"LQ_KEYNFCE"	, cChaveNFCe													, Nil},;
									{"LQ_RESEHTL"	, cReserva							  							, Nil},;
									{"LQ_TOTFED"	, nImpFedSL1													, Nil},;
									{"LQ_TOTEST"	, nImpEstSL1													, Nil},;
									{"LQ_TOTMUN"	, nImpMunSL1													, Nil},;
									{"LQ_LTRAN"		, cTaxSource													, Nil},;
									{"LQ_VALIRRF"	, nSL1IRRF														, Nil},;
									{"LQ_RECISS"	, IIF(!Empty(SA1->A1_RECISS), SA1->A1_RECISS, "2")				, Nil},;
									{"LQ_PRONFCE"	, cProtoNFCe													, Nil},;
									{"LQ_SERSAT"	, cSerieSat														, Nil},;
									{"LQ_RESERVA"	, ""															, Nil},;
									{"LQ_MENNOTA"	, cMenNota														, Nil},;
									{"LQ_UMOV"		, cUUID															, Nil},;
									{"LQ_DOCCCF"	, cDocCanc														, Nil},;
									{"LQ_TRANSP"	, cTransp														, Nil}}
					
						If lBaseIPI
							Aadd(aCab, {"LQ_BASEIPI"	, nSL1BasIpi	, Nil})
						EndIf
						If lL1FECP
							Aadd(aCab, {"LQ_BASFECP"	, nL1BsFECP	   , Nil})
							Aadd(aCab, {"LQ_VALFECP"	, nL1VlFECP	   , Nil})
						EndIf
						If lL1FECPST
							Aadd(aCab, {"LQ_BSFCPST"	, nL1BsFCPST   , Nil})
							Aadd(aCab, {"LQ_VFECPST"	, nL1VlFCPST   , Nil})
						EndIf
					
					EndIf

					If lRet
						//Valida se produtos foram enviados
						If	XmlChildEx(oXmlContent:_ListOfSaleItem, "_SALEITEM") == Nil
							lRet 	 := .F.
							cXmlRet := STR0030 //#"Lista de produtos vazia, verifique a lista SaleItem."
						EndIf
					
						If lRet
							//Monta Array com Itens da Venda	            					
							If ValType(oXmlContent:_ListOfSaleItem:_SaleItem) <> "A"
								XmlNode2Arr(oXmlContent:_ListOfSaleItem:_SaleItem, "_SaleItem")
							EndIf
		 			
			 				//Valida se lista esta vazia
							If Len(oXmlContent:_ListOfSaleItem:_SaleItem) == 0
								lRet 	 := .F.
								cXmlRet := STR0030 //#"Lista de produtos vazia, verifique a lista SaleItem."
							EndIf
						EndIf
					EndIf
 		
					If lRet
					
		 				//Monta itens da venda
		 				LjGrvLog("LOJI701","INICIO MONTAGEM ITENS DA VENDA: "+Time())

						For nI := 1 To Len(oXmlContent:_ListOfSaleItem:_SaleItem)
							//De-Para Produtos
							cValExt := LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_ITEMINTERNALID")
						
							cCancItem := LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_ISCANCELED") //Trata gravacao de itens cancelados
							lCancItem := Iif(cCancItem == "true",.T.,.F.) //Trata gravacao de itens cancelados
						
							If !Empty(cValExt)
								aAux := IntProInt(cValExt, cMarca)
		          		
			          			//Se encontrou o produto no de/para
									If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1] .And. ValType(aAux[2]) == "A" .And. len(aAux[2]) >= 3
									cProduto := PadR(aAux[2][3], TamSX3("B1_COD")[1])
								Else
									lRet 	 := .F.
									cXmlRet := STR0013 + " " + AllTrim(cValExt) + " " + STR0014 //#"Produto:" ##"nao integrado ao Protheus, verificar integracao de Produto"
									Exit
								EndIf
							Else
								cProduto := Padr(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_ITEMCODE"), TamSx3("B1_COD")[1])
													
								If Empty(cProduto)
									lRet 	 := .F.
									cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0032 //#"Inconsistencia no item" ##"produto nao informado na integracao, verifique a Tag ItemCode."
									Exit
								EndIf
							EndIf
																										
							//Posiciona no produto
							SB1->(dbSetOrder(1))
						
							If !SB1->(dbSeek(xFilial("SB1") + cProduto))
								lRet 	 := .F.
								cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0033 + " " + AllTrim(cProduto) + " " + STR0034 //#"Inconsistencia no item" ##"produto:" ###"nao cadastrado no Protheus, verifique a tag: ItemCode"
								Exit
							EndIf
																																				
							//Validacoes de campos obrigatorios						
							If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_ITEMORDER") == Nil .Or.;
									Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ItemOrder:Text)
								lRet 	 := .F.
								cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0035 //#"Inconsistencia no item" ##"campo obrigatorio nao informado: Item, verifique a tag: ItemOrder."
								Exit
							ElseIf XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_QUANTITY") == Nil .Or.;
									Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_Quantity:Text)
								lRet 	 := .F.
								cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0036 //#"Inconsistencia no item" ##"campo obrigatorio nao informado: Quantidade, verifique a tag: Quantity."
								Exit
							ElseIf XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_UNITPRICE") == Nil .Or.;
									Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_UnitPrice:Text)
								lRet 	 := .F.
								cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0037 //#"Inconsistencia no item" ##"campo obrigatorio nao informado: Preco Unitario, verifique a tag: UnitPrice."
								Exit
							ElseIf XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_OPERATIONCODE") == Nil .Or.;
									Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_OperationCode:Text)
								lRet 	 := .F.
								cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0039 //#"Inconsistencia no item" ##"campo obrigatorio nao informado: CFOP, verifique a tag: OperationCode."
								Exit
							EndIf
						
							If lIntegHtl //Hotelaria
								//Validacao para impedir vendas mistas (produtos e servicos)										
								If lRps .And. !SB1->B1_TIPO $ "GE|GG|MO|SV"
									lRet 	 := .F.
									cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0090 //#"Inconsistencia no item" ##"enviado produto do tipo mercadoria em uma RPS, verifique o campo B1_TIPO no Protheus"
									Exit
								ElseIf !lRps .And. SB1->B1_TIPO $ "GE|GG|MO|SV"
									lRet 	 := .F.
									cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0091 //#"Inconsistencia no item" ##"enviado produto do tipo servico em um Cupom, verifique o campo B1_TIPO no Protheus"
									Exit
								EndIf
							
								If lReserva //Se achou o produto e é pra gravar informações de Reserva (hotelaria), então guarda a descrição dos produtos e valores para gravar o campo de lançamentos (MH3_LANCTOS)
									cLanctos += AllTrim( SB1->B1_DESC ) + " " + AllTrim( oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_UnitPrice:Text ) + "|"
								EndIf
							EndIf
													
							SX5->(dbSetOrder(1))
																		
							//Variaveis dos Itens de Venda
							cItem := StrZero(Val(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ItemOrder:Text), TamSx3("LR_ITEM")[1])
						
							//Armazena valores dos produtos
							nQuant   := Val(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_Quantity:Text)
							nVlrUnit := Val(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_UnitPrice:Text)
						
                            //Preço de Tabela do Item 
                            If !XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_ITEMTABLEPRICE") == Nil .and.;
                            !Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ItemTablePrice:Text)

                                nVlrTab := Val(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ItemTablePrice:Text)
                            Endif 
						
                            //Necessário a inclusão deste tratamento, pois em vendas com valor unitário com mais
                            //de 3 casas decimais o valor total apresentava divergência.
                            If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_ITEMPRICE") == Nil .Or.;
                                        Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ItemPrice:Text)
                                nVlrItem := nVlrUnit * nQuant
                            Else
                                nVlrItem := Val(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ItemPrice:Text) 
                            Endif
													
							//Armazena valor do Desconto Total Proporcionalizado no item
							nDescPro := 0
							
							If !lCancItem //Tratamento para recebimento de itens cancelados
							
								If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_DISCOUNTTOTALPRORATED") <> Nil .AND. !Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_DISCOUNTTOTALPRORATED:Text)
									nDescPro 	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_DISCOUNTTOTALPRORATED", "N"))
									nTotDesPro 	+= nDescPro
								Else
									//Verifica se houve desconto no total da venda e efetua o rateio nos itens
									If nPerDesTot > 0 .Or. nValDesTot > 0
										//Calcula o Percentual do Desconto no Total da venda
										If nPerDesTot == 0
											nPerDesTot := (nValDesTot * 100) / nVlMercTot
										EndIf
									
										nDescPro := (nVlrItem / 100) * 	nPerDesTot
									EndIf
								EndIf
								
							EndIf
												
							//Verifica se item diaria para calcular comissao
							If nPerComis > 0
								If AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_LODGING"))) == "S"
									nValComis += (nVlrItem / 100) * nPerComis
								EndIf
							EndIf
						
							If	XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_LISTOFTAXES") <> Nil .And.;
								XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes, "_TAX") <> Nil
							
								//Monta Array com Impostos	            					
								If ValType(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax) <> "A"
									XmlNode2Arr(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax, "_Tax")
								EndIf
							
								For nX := 1 To Len(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax)

									Do Case
										Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) == "ICM" //ICMS
											nSL2Icms := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
											nBaseIcm := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
											nAliqIcm := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
											nAliqRed := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_REDUCTIONBASEPERCENT", "N")) //Aliquota Reducao de Base ICMS
											
											cCSTIcm	:= LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CODETAXSITUATION") //ICMS
											
											If nAliqRed > 0
												nAliqRed := Round(100 - nAliqRed, TamSx3("L2_PREDIC")[2]) //Base Reducao ICMS
											EndIf
											
											//Gera Codigo de Tributacao, sempre sera enviado quando tributado
											cTribut := "T" + PadL(CValToChar(nAliqIcm * 100), 4, "0")

										Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) == "ISS" //ISS
											nSL2Iss  := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
											nBaseIss := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
											nAliqIss := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
																			
											//Gera Codigo de Tributacao, sempre sera enviado quando tributado
											cTribut := "S" + PadL(CValToChar(nAliqIss * 100), 4, "0")

										Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) == "PIS" //PIS
											If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_WITHHOLDINGTAX") <> Nil .And.;
											   AllTrim(Upper(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX]:_WithHoldingTax:Text)) == "TRUE" //Retencao
												
												nSL2PisRet  	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
												nBasPisRet 	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
												nAlqPisRet 	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
											Else //Apuracao
												nSL2PisApu  	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
												nBasPisApu 	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
												nAlqPisApu 	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
											EndIf

                                            cCSTPis	:= LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CODETAXSITUATION") //CST PIS

										Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) == "COFINS" //COFINS
											If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_WITHHOLDINGTAX") <> Nil .And.;
													AllTrim(Upper(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX]:_WithHoldingTax:Text)) == "TRUE" //Retencao
												
												nSL2CofRet  	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
												nBasCofRet 	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
												nAlqCofRet 	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
											Else //Apuracao
												nSL2CofApu  	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
												nBasCofApu		:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
												nAlqCofApu		:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
											EndIf

                                             cCSTCof	:= LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CODETAXSITUATION") //CST COF //

										Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) == "CSLL" //CSLL
											nSL2CSLL  := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
											nBaseCSLL := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
											nAliqCSLL := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota

										Case "IRRF" $ AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) //IRRF
											nSL2IRRF  := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
											nBaseIRRF := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
											nAliqIRRF := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota

										Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) == "FECP" //FECP
											nValFECP  := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
											nAlqFECP := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
											nBasFECP := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base

										Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) == "FECP_ST" //FECP_ST
											nValFECPST  := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
											nAlqFECPST := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
											nBasFECPST := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base

										Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) == "IPI" //IPI
											nSL2ValIpi := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
											nSL2AlqIpi := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
											nSL2BasIpi := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base

										Case AllTrim(Upper(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_TAXE"))) == "ICMS_ST" //ICMS_ST
											nSL2ValSol := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_VALUE", "N")) //Valor
											nSL2AlqSol := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_PERCENTAGE", "N")) //Aliquota
											nSL2BasSol := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ListOfTaxes:_Tax[nX], "_CALCULATIONBASIS", "N")) //Base
									EndCase

								Next nX
							EndIf
						
							//Descontos no item
							nPerItDesc := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_DISCOUNTPERCENTAGE", "N"))
							nValItDesc := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_DISCOUNTAMOUNT", "N"))
						
							//Se existir desconto no item e nao enviadas as duas tags, efetua o calculo
							If nValItDesc > 0
								nPerItDesc := Round((nValItDesc * 100) / nVlrItem, TamSx3("L2_DESC")[2]) //Calcula o Percentual do Desconto no Item
							ElseIf nPerItDesc > 0
								nValItDesc := (nVlrItem / 100) * nPerItDesc //Calcula o Valor do Desconto no Item
							EndIf
								
							//Valor de acrescimo no item
							nVlAcrsIt := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_INCREASE", "N"))
						
							//Armazem padrao
							cValExt := LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_WAREHOUSEINTERNALID")
																		
							If !Empty(cValExt)
								aAux := IntLocInt(cValExt, cMarca)
		          		
			          			//Se encontrou o cliente no de-para
								If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
									cArmazem := PadR(aAux[2][3], TamSX3("B1_LOCPAD")[1])
								Else
									lRet 	 := .F.
									cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0106 + " " + AllTrim(cValExt) + " " + STR0107 //"Inconsistencia no item" #"Armazem: " ##"nao integrado ao Protheus, verificar integracao de armazens"
									Exit
								EndIf
							Else //Utiliza armazem padrao
							
								//Verifica o Armazem Padrão do Produto, levando em consideração
								//a configuração do Indicador de Produtos (SBZ) - parametro MV_ARQPROD.
								cArmazem	:=	RetFldProd(SB1->B1_COD,"B1_LOCPAD")
							Endif
												
							If lIntegHtl //Hotelaria
								
								//Tratamento Centro de Custo consumo
								cLjCCusto 	:= "" //Centro de Custo
								cLjItemCC 	:= "" //Item Centro de Custo
								cLjClvl 	:= "" //Classe Valor
			          		
								cIdLoja := Padr(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_STOREIDENTIFICATIONCODE"), TamSX3("LJ_CODIGO")[1])
			          			
								  //Se enviado identificacao de loja, valida se existe o cadastro
								If !Empty(cIdLoja)
									SLJ->(dbSetOrder(1)) //LJ_FILIAL+LJ_CODIGO
			          			
									If SLJ->(dbSeek(xFilial("SLJ") + cIdLoja))
										cLjCCusto 	:= SLJ->LJ_CCUSTO  //Centro de Custo
										cLjItemCC 	:= SLJ->LJ_ITEMCC  //Item Centro de Custo
										cLjClvl 	:= SLJ->LJ_CLVL    //Classe Valor
										cArmazem  	:= SLJ->LJ_LOCAL	 //Armazem
									EndIf
								EndIf
							EndIf

							//Tratamento para recebimento de itens cancelados
							If !lCancItem .Or. lCancVen

								//Quando venda ativa, adiciona apenas itens ativos
								//Se venda cancelada, sempre adiciona, itens serao excluidos no processo de
								//exclusao da venda 
								nVlrItTot  += nVlrItem - Round(nDescPro, TamSx3("L2_DESCPRO")[2])
								nVlrMercIt += A410Arred(nVlrItem, "F2_VALMERC")
							
								//Lei de Transparencia
								If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_STATETAXBURDEN") <> Nil
									nImpEst := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_STATETAXBURDEN", "N"))
								EndIf
								If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_MUNICIPALTAXBURDEN") <> Nil
									nImpMun := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_MUNICIPALTAXBURDEN", "N"))
								EndIf
								If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_FEDERALTAXBURDEN") <> Nil
									nImpFed := Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_FEDERALTAXBURDEN", "N"))
								EndIf
							
                                cTesPrd := "" 

								If lIntegHtl //Hotelaria
									//Armazena venda que reteve impostos Pis/Cofins do item - Bloco F100
									If lLjMvBf100
										cIdVendF100 := LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_INTERNALID")
									EndIf
								
									//Informacoes de Pensao - Hotelaria										
									If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_BOARDBASISINFORMATION") <> Nil
										cDtVendF100 := ""
									
										//Se produto referenciado em outra venda, verifica data para Bloco F100
										If lLjMvBf100 .And. !Empty(cIdVendF100)
											cDtVendF100 := LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_BoardBasisInformation, "_DATEOFMOVEMENT", "D")
																			
											If Empty(cDtVendF100)
												lRet 	 := .F.
												cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0114 + "," + STR0115 + "," + STR0116 //"Inconsistencia no item" #"nao informada a data para verificacao do Bloco F100" ##"esta informacao é obrigatoria quando informada a venda origem Bloco F100" ###"verifique a tag: DateOfMovement localizada na lista BoardBasisInformation"
												Exit
											Else
												//Verifica se zera base Pis/Cofins, tratamento Bloco F100										
												If Month(StoD(cDtVendF100)) <> Month(SToD(cEmissao))
													nBasPisApu := 0
													nSL2PisApu := 0
													nBasCofApu := 0
													nSL2CofApu := 0
												
													cTpOpera := SuperGetMV("MV_LJOPTES",, "") //Altera o tipo de operacao para Tes Inteligente
												EndIf
											EndIf
										EndIf
									
										If !Empty(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_BoardBasisInformation, "_BOARDBASISTYPE")) .Or.;
												!Empty(cDtVendF100)
									
											aAdd(aItemMh4, { 	cSerie,;
												cDoc,;
												AllTrim(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ItemOrder:Text),;
												LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_BoardBasisInformation, "_BOARDBASISTYPE"),;
												Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_BoardBasisInformation, "_BOARDBASISVALUE", "N")),;
												Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_BoardBasisInformation, "_BREAKFASTVALUE", "N")),;
												cIdVendF100,;
												StoD(cDtVendF100)})
										EndIf
									Else
										If lLjMvBf100 .And. !Empty(cIdVendF100)
											lRet 	 := .F.
											cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0117 + "," + STR0115 + "," + STR0119 //"Inconsistencia no item" #"nao informada a lista BoardBasisInformation" ##"esta informacao é obrigatoria quando informada a venda origem Bloco F100" ###"verifique a tag InternalId na lista ListOfSaleItem"
											Exit
										EndIf
									EndIf
								ElseIF !lIntegHtl .AND. cTipoVen == "D"
								
									If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_SOURCEDOCUMENT") <> Nil .AND. !Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_SOURCEDOCUMENT)
										
										If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_SOURCEDOCUMENTSERIE") <> Nil .AND. !Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_SOURCEDOCUMENTSERIE)
									
											If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_SOURCEDOCUMENTITEM") <> Nil .AND. !Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_SOURCEDOCUMENTITEM)
											
												aAdd(aItemMh4, {cSerie,;
																cDoc,;
																AllTrim(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ItemOrder:Text) ,;
																Nil,;
																0,;
																0,;
																Nil,;
																StoD(cEmissao),;
																oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_SOURCEDOCUMENT:Text,;
																oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_SOURCEDOCUMENTSERIE:Text,;
																oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_SOURCEDOCUMENTITEM:Text})

                                                If SuperGetMv("MV_LJTESDV", .F. , 0 ) > 0  .And. ExistFunc("LjITesDev") 
                                                    cTesPrd := LjITesDev(  PadR(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_SOURCEDOCUMENT:Text , nTamDocNFD )            ,;
                                                                PadR(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_SOURCEDOCUMENTSERIE:Text , nTamSerNFD )       ,;
                                                                StrZero(Val(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_SOURCEDOCUMENTITEM:Text) , nTamItNFD)       ,;
                                                                cCodFor                                                                         ,;
                                                                cLojFor                                                                         ,;
                                                                cProduto                                                                        )
                                                    LjGrvLog("LOJI701", "MV_LJTESDV Habilitado. Retorno função: ", cTesPrd )            

                                                Else
                                                    LjGrvLog("LOJI701", "Parametro MV_LJTESDV Desabilitado.", SuperGetMv("MV_LJTESDV", .F. , 0 ) )
                                                EndIf
											Else
												lRet 	 := .F.
												cXmlRet := STR0031 + " " + CValToChar(nI) + "," + "nao informada a TAG SOURCEDOCUMENTITEM obrigatária para Notas de Devolução." //"Inconsistencia no item" #"nao informada a TAG SOURCEDOCUMENTITEM obrigatária para Notas de Devolução."
												Exit
											Endif
										Else
											lRet 	 := .F.
											cXmlRet := STR0031 + " " + CValToChar(nI) + "," + "nao informada a TAG SOURCEDOCUMENTSERIE obrigatária para Notas de Devolução." //"Inconsistencia no item" #"nao informada a TAG SOURCEDOCUMENTSERIE obrigatária para Notas de Devolução."
											Exit										
										Endif
									Else
											lRet 	 := .F.
											cXmlRet := STR0031 + " " + CValToChar(nI) + "," + "nao informada a TAG SOURCEDOCUMENT obrigatária para Notas de Devolução." //"Inconsistencia no item" #"nao informada a TAG SOURCEDOCUMENT obrigatária para Notas de Devolução."
											Exit
									Endif
								EndIf
							
                                

								//INICIO TRATAMENTO TES INTELIGENTE 
                                If Empty(cTesPrd)
                                    If !XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_OPERATIONCODE") == NIL .And.;
                                    !Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_OperationCode:Text)
                                        
                                        //CODIGO DE OPERACAO
                                        If Len(Alltrim(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_OperationCode:Text)) <= 2
        
                                            cTpOpera := PADR(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_OperationCode:Text,TamSX3('FM_TIPO')[1] )
                                            cTesPrd  := MaTesInt(2, cTpOpera, cCodCli, cLojCli, "C", cProduto)
                                                                                            
                                            If Empty(cTesPrd)
                                                cTpOpera := "01" //Inicializa tipo de operacao para Tes Inteligente
                                                cTesPrd  := MaTesInt(2, cTpOpera, cCodCli, cLojCli, "C", cProduto)
                                            Endif
                                        //TES	
                                        Elseif 	Len(Alltrim(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_OperationCode:Text)) == 3
                                            cTesPrd := Alltrim(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_OperationCode:Text)
                                        //CFOP	
                                        ElseIf Len(Alltrim(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_OperationCode:Text)) == 4
                                            cCfop 	:= Padr(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_OperationCode:Text, TamSx3("LR_CF")[1])
                                        Else
                                            //BUSCA INFORMACAO DE TES A PARTIR DO DE / PARA												
                                            cCfop 	:= Padr(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_OperationCode:Text, TamSx3("LR_CF")[1])
                                            aCodcfop:= Separa(CFGA070Int(cMarca, "SF4", "F4_CODIGO", cCfop),"|")
                                            cCfop 		:= StrTran(Alltrim(cCfop),".","")
                                            If len(aCodcfop) >= 3 .AND. !Empty(aCodcfop[3])
                                                cTesPrd := aCodcfop[3]
                                            Else
                                                //Permite utilizar TES Inteligente por meio de consulta do tipo de operação do CFOP
                                                cTpOpera := ColConDHJ(cCfop,"S")//Busca operacao "S" de Saida
                                                
                                                If !Empty(cTpOpera)
                                                    cTesPrd  := MaTesInt(2, cTpOpera, cCodCli, cLojCli, "C", cProduto)
                                                Else 	
                                                    lRet 	 := .F.
                                                    cXmlRet := "A CFOP "+cCfop+" não foi encontrada (De/Para e DHJ). verificar se a CFOP esta correto." //incluir include
                                                    Exit
                                                EndIf
                                            Endif
                                        Endif
                                    Else
                                        lRet 	 := .F.
                                        cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0039 //#"Inconsistencia no item" ##"campo obrigatorio nao informado: CFOP, verifique a tag: OperationCode."
                                        Exit								
                                    Endif
                                EndIf
														
								//Se nao encontrou Tes Inteligente continua a busca
								If Empty(cTesPrd)
									SBZ->(dbSetOrder(1))
									If AllTrim(SuperGetMv("MV_ARQPROD",, "SB1")) == "SBZ" .And.;
											SBZ->(dbSeek(xFilial("SBZ") + cProduto)) .And. !Empty(SBZ->BZ_TS) //Busca Tes na SBZ
									
										cTesPrd := SBZ->BZ_TS
									ElseIf !Empty(SB1->B1_TS) //Busca Tes na SB1
										cTesPrd := SB1->B1_TS
									Else //Busca Tes no parametro
										If lRps
											cTesPrd := SuperGetMv("MV_TESSERV") //Tes para Servico
										Else
											cTesPrd := SuperGetMv("MV_TESVEND") //Tes para Venda
										EndIf
									EndIf
								EndIf
							
								//Validacao TES
								If Empty(cTesPrd)
									lRet 	 := .F.
									cXmlRet := STR0031 + " " + CValToChar(nI) + "," + STR0040 //#"Inconsistencia no item" ##"TES nao informada, verifique o Cadastro de Produto no Protheus campo B1_TS e/ou De-Para de TES(XXF) e/ou as configurações para TES Inteligente(DHJ e SFM) e/ou parametros MV_TESSERV e MV_TESVEND."
									Exit
								EndIf
								
								//Grava Status para Geracao do Financeiro
								SF4->(DbSetOrder(1))
								SF4->(DbSeek(xFilial("SF4")+cTesPrd))
								If SF4->F4_DUPLIC == "N"
									lGeraFin := .F.
								Elseif SF4->F4_DUPLIC == "N" .AND. !lGeraFin
									lRet 	 := .F.
									cXmlRet := STR0031 + " " + CValToChar(nI) + "," + "não é possível utilizar itens que gerem financeiro e outros que não no mesmo orçamento." //STR0040 //#"Inconsistencia no item" ##"TES nao informada, verifique o Cadastro de Produto no Protheus, campo B1_TS ou os parametros MV_TESSERV e MV_TESVEND."
									Exit
								Endif
								
								//Não atualizar o CFOP quando recebeu a integração com o código de CFOP
								If Empty(cCfop)
									cCfop:= SF4->F4_CF
								EndIf
								
								//Valida CFOP
								If lIntegHtl //Hotelaria
									cCfop := Padr(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_OperationCode:Text, TamSx3("LR_CF")[1])
									If !SX5->(dbSeek(xFilial("SX5") + "13"  + cCfop))
										lRet 	 := .F.
										cXmlRet := STR0031 +  " " + CValToChar(nI) + "," + STR0063 + AllTrim(cCfop) + "," + STR0064 //#"Inconsistencia no item" ##"CFOP invalida:" ###"verifique o cadastro de CFOP"
										Exit
									EndIf
								Endif
								
								If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_STOREIDENTIFICATIONCODE") <> Nil .And.;
									!Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_StoreIdentificationCode:Text)	
									
									cValExt := oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_StoreIdentificationCode:Text																											
									aAux 	:= Separa(CFGA070Int(cMarca, "SLJ", "LJ_CODIGO", cValExt), "|")
									
									If ValType(aAux) == "A" .And. Len(aAux) > 0																																											
										cIdLoja := Padr(aAux[3], TamSx3("LJ_CODIGO")[1])											
									EndIf
									
									If !Empty(cIdLoja)
										//Valida se existe o cadastro Identificação de Loja									
										SLJ->(dbSetOrder(1)) //LJ_FILIAL+LJ_CODIGO
										If SLJ->(dbSeek(xFilial("SLJ") + cIdLoja))											
											cFilRes  := SLJ->LJ_RPCFIL																					
										EndIf
									EndIf									
								EndIf
								
								//Tipo da Entrega								
								If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_ITEMDELIVERYTYPE") <> Nil
									cTpEntrega := Rtrim(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ItemDeliveryType:Text)									
								EndIf
								
								//Flag reserva
								If AllTrim(cTpEntrega) <> "2"
									lPedVen := .T.
									/*
									//Verifica novamente cadastro de loja pois Entrega Futura pode nao ter reserva
									//Necessario para Solicitacao de Compra								
									If Empty(cIdLoja)
										SLJ->(dbSetOrder(3)) //LJ_FILIAL+LJ_RPCEMP+LJ_RPCFIL
										If SLJ->(dbSeek(xFilial("SLJ") + cEmpAnt + cFilAnt))
											cIdLoja := SLJ->LJ_CODIGO
										
										EndIf
									EndIf
									*/									
								EndIf
								
								//Armazena Data de Entrega do Item 
								cDataEntr := LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_ITEMDELIVERYDATE", "D")
											 //Padr(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_AddressItem:Text,TamSx3("LR_LOCALIZ")[1])
								If !Empty(cDataEntr)
									cDataEntr := SToD(cDataEntr)
								EndIf
								//NÚMERO DO LOTE
								If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_LOTNUMBER") <> Nil .AND. !Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_LotNumber:Text)
									cLoteItem := Padr(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_LotNumber:Text,TamSx3("LR_LOTECTL")[1])
									
									//NÚMERO DO SUBLOTE
									//Caso a TAG do SubLote não seja enviada eu preciso setar a variável como "" pois ela é utilizada
									//para validação de estoques. 
									If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_SUBLOTNUMBER") <> Nil .AND. !Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_SubLotNumber:Text)
										cSubLoteItem := Padr(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_SubLotNumber:Text,TamSx3("LR_NLOTE")[1])
									Else
										cSubLoteItem := ""								
									EndIf							
								EndIf
								
								//ENDEREÇO DO ESTOQUE
								If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_ADDRESSITEM") <> Nil .AND. !Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_AddressItem:Text)
									cAddresItem := Padr(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_AddressItem:Text,TamSx3("LR_LOCALIZ")[1])
									//Verifica se o Endereço Existe
									LjGrvLog("LOJI701","Verifica Endereço do Estoque")
									DbSelectArea("SBE")
									SBE->(DbSetOrder(1))//BE_FILIAL+BE_LOCAL+BE_LOCALIZ+BE_ESTFIS
									If !(SBE->(DbSeek(xFilial("SBE")+cArmazem+cAddresItem)))
										lRet 	 := .F.
										cXmlRet := "Endereço de Estoque:"+cAddresItem+" não existe"
										LjGrvLog("LOJI701","Endereço de Estoque:"+cAddresItem+" não existe")
										Exit	
									Endif
									LjGrvLog("LOJI701","Verifica Número de Série")
									//NÚMERO DE SÉRIE
									If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_SERIESITEM") <> Nil .AND. !Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_SeriesItem:Text)
										cSerieItem := Padr(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_SeriesItem:Text,TamSx3("LR_NSERIE")[1])
										//Verifica se existe o Número de Série
										DbSelectArea("SBF")
										SBF->(DbSetOrder(1))
										If!(SBF->(DbSeek(xFilial("SBF")+cArmazem+cAddresItem+cProduto+cSerieItem)))
											lRet 	 := .F.
											cXmlRet := "Número de Série:"+cSerieItem+" não existe para o produto/endereço"
											LjGrvLog("LOJI701","Número de Série:"+cSerieItem+" não existe para o produto/endereço")
											Exit	
										Endif
									EndIf	
								EndIf
			          					          																									
								//InternalId da Reserva								
								If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_ITEMRESERVEINTERNALID") <> Nil .And.;
								   !Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ItemReserveInternalId:Text)	
									
									cValExt := oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ItemReserveInternalId:Text																		
									aAux := Separa(CFGA070Int(cMarca, "SC0", "C0_DOCRES", cValExt), "|")																														
										
									If ValType(aAux) == "A" .And. Len(aAux) > 0

                                        aReserva  := ReserItEai(/*xFilial("SC0")*/, aAux[3], cProduto, @cLoteItem, @cSubLoteItem, @cAddresItem, @cSerieItem, nQuant)

										If Len(aReserva) > 0
											cCodResIt := Padr(aReserva[1][2], TamSx3("C0_NUM")[1])
											nQtdRes	  := aReserva[1][3]
											cFilRes := aReserva[1][1]
											
											If !nQtdRes == nQuant
												lRet 	:= .F.
												cXmlRet := "Quantidade da venda processada:"+AllTrim(Str(nQuant))+ " é diferente da Reserva:"+Alltrim(Str(nQtdRes))
												LjGrvLog("LOJI701","Quantida da venda processada:"+AllTrim(Str(nQuant))+ "é diferente da Reserva:"+Alltrim(Str(nQtdRes)))
												Exit												
											Endif
											
											//Se nao informado loja, efetua busca no cadastro
											If !Empty(cFilRes)
												SLJ->(dbSetOrder(3)) //LJ_FILIAL+LJ_RPCEMP+LJ_RPCFIL
												If SLJ->(dbSeek(xFilial("SLJ") + cEmpAnt + cFilRes))
													cIdLoja := SLJ->LJ_CODIGO
												Else
													//Chama Função para Gravação da Loja
													LjGrvLog("LOJI701", "Inicio da Gravação da Loja: " + cFilRes)
										 			aIdLoja:= lj701IdLj(cEmpAnt,cFilRes)
													If aIdLoja[1]
														cIdLoja := aIdLoja[2]
													Else
														lRet 	 := .F.
														cXmlRet := aIdLoja[2]
														LjGrvLog("LOJI701", aIdLoja[2])
														Exit
													Endif
												Endif
											EndIf
										Else
											lRet 	:= .F.
											cXmlRet := "Reserva:"+cValExt+" informada não existe para o produto:"+cProduto
											LjGrvLog("LOJI701","Reserva:"+cValExt+" informada não existe para o produto:"+cProduto)
											Exit	
										EndIf
                                     Else
                                        lRet 	:= .F.
                                        cXmlRet := I18n(STR0144, {"ITEMRESERVEINTERNALID", AllTrim(cValExt)})	//"Não foi encontrado de\para, para o #1 #2, verifique se a reserva foi integrada."
                                        LjGrvLog("LOJI701", cXmlRet)
                                        Exit
  									EndIf
								EndIf									
								
								//Codigo da Reserva		
								If Empty(cCodResIt)
									If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_ITEMRESERVECODE") <> Nil .And.; 
										!Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ItemReserveCode:Text)																				
										cCodResIt := Padr(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_ItemReserveCode:Text, TamSx3("C0_NUM")[1])																				
									EndIf
								EndIf

                                //Valida Reserva pelo tipo de entrega para Itens do Tipo 3 e 4 
                                If Empty(cCodResIt) .And. AllTrim(cTpEntrega) $ "3|4"
                                    lRet	:= .F.
                                    cXmlRet := I18n(STR0145, {"ITEMRESERVEINTERNALID\ITEMRESERVECODE", cValToChar(nI), "ITEMDELIVERYTYPE"})	//"Não foi informado o número da reserva (#1), para o item #2. Para #3 3 ou 4 a TAG é obrigatória."
                                    LjGrvLog("LOJI701", cXmlRet)
                                    Exit
                                EndIf                       
								
								//As Tags de frete e Despesa proporcionalizadas passaram a ser enviadas à partir da versão 2.004
								//para adequação à forma de gravação do venda assistida.
								
								//Valor do Frete Proporcionalizado						
								If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_FREIGHTVALUEPRORATED") <> Nil .AND. !Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_FREIGHTVALUEPRORATED:Text)
									nVlrItFrete	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_FREIGHTVALUEPRORATED", "N"))
								Endif

								//Valor das Despesas Acessórias Proporcionalizadas
								If XmlChildEx(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_INCREASEVALUEPRORATED") <> Nil .AND. !Empty(oXmlContent:_ListOfSaleItem:_SaleItem[nI]:_INCREASEVALUEPRORATED:Text)
									nVlrItDesp 	:= Val(LjiVldTag(oXmlContent:_ListOfSaleItem:_SaleItem[nI], "_INCREASEVALUEPRORATED", "N"))
								Endif

								//Caso o Valor não tenha sido enviado no xml atribuímos o valor unitário
								//atualmente apenas a Integração com o GEMCO utiliza a TAG ItemTablePrice
								If nVlrTab == 0
									nVlrTab := nVlrUnit
								Endif
								
								LjGrvLog("LOJI701","GRAVA ARRAY AITEM DA VENDA: "+Time())

								/* Efetua a carga das tabela SLR */
								//Alimenta Array com Itens da Venda
								aAdd(aItem, {	{"LR_PRODUTO"	, cProduto			, Nil},;
												{"LR_ITEM"		, cItem				, Nil},;
												{"LR_QUANT"  	, nQuant			, Nil},;
												{"LR_VRUNIT"	, nVlrUnit			, Nil},;
												{"LR_VLRITEM"	, nVlrItem			, Nil},;
												{"LR_LOCAL"		, cArmazem			, Nil},;
												{"LR_UM"		, SB1->B1_UM		, Nil},;
												{"LR_DESC"		, nPerItDesc		, Nil},;
												{"LR_VALDESC"	, nValItDesc		, Nil},;
												{"LR_DESCPRO"	, nDescPro			, Nil},;
												{"LR_TES"		, cTesPrd			, Nil},;
												{"LR_CF"		, cCfop   			, Nil},;
												{"LR_VENDIDO"	, If(lPedVen,"","V")   , Nil},;
												{"LR_DOC"		, If(lPedVen,"",cDoc)  , Nil},;
												{"LR_SERIE"		, If(lPedVen,"",cSerie), Nil},;
												{"LR_NUMCFIS"	, ""				, Nil},;
												{"LR_PDV"		, cPdv  			, Nil},;
												{"LR_VALICM"	, nSL2Icms      	, Nil},; 
												{"LR_BASEICM"	, nBaseIcm			, Nil},;
												{"LR_PICM"		, nAliqIcm      	, Nil},; 
												{"LR_VALISS"	, nSL2Iss			, Nil},;
												{"LR_BASEISS"	, nBaseIss			, Nil},;
												{"LR_ALIQISS"	, nAliqIss			, Nil},;
												{"LR_ENTREGA"	, cTpEntrega		, Nil},;
												{"LR_RESERVA"	, cCodResIt			, Nil},; 
												{"LR_LOJARES"	, cIdLoja			, Nil},;
												{"LR_FILRES"	, cFilRes  			, Nil},;
												{"LR_EMISSAO"	, SToD(cEmissao)	, Nil},;
												{"LR_VEND"		, cVendedor			, Nil},;
												{"LR_VALACRS"	, nVlAcrsIt			, Nil},;
												{"LR_VALPS2"	, nSL2PisApu		, Nil},;
												{"LR_BASEPS2"	, nBasPisApu		, Nil},;
												{"LR_ALIQPS2"	, nAlqPisApu		, Nil},;
												{"LR_VALCF2"	, nSL2CofApu		, Nil},;
												{"LR_BASECF2"	, nBasCofApu		, Nil},;
												{"LR_ALIQCF2"	, nAlqCofApu		, Nil},;
												{"LR_VALPIS"	, nSL2PisRet		, Nil},;
												{"LR_ALIQPIS"	, nAlqPisRet		, Nil},;
												{"LR_BASEPIS"	, nBasPisRet		, Nil},;
												{"LR_VALCOFI"	, nSL2CofRet		, Nil},;
												{"LR_ALIQCOF"	, nAlqCofRet		, Nil},;
												{"LR_BASECOF"	, nBasCofRet		, Nil},;
												{"LR_BASCSLL"	, nBaseCSLL			, Nil},;
												{"LR_ALQCSLL"	, nAliqCSLL			, Nil},;
												{"LR_VALCSLL"	, nSL2CSLL			, Nil},;
												{"LR_VALIPI"    , nSL2ValIpi        , Nil},;
												{"LR_SITTRIB"	, cTribut			, Nil},;
												{"LR_PRCTAB"	, nVlrTab			, Nil},;
												{"LR_TOTFED"	, nImpFed			, Nil},;
												{"LR_TOTEST"	, nImpEst			, Nil},;
												{"LR_TOTMUN"	, nImpMun			, Nil},;
												{"LR_VALIRRF"	, nSL2IRRF			, Nil},;
												{"LR_BASIRRF" 	, nBaseIRRF			, Nil},;
												{"LR_ALQIRRF" 	, nAliqIRRF			, Nil},;
												{"LR_PREDIC"  	, nAliqRed			, Nil},;
												{"LR_CCUSTO"  	, cLjCCusto			, Nil},;
												{"LR_ITEMCC"  	, cLjItemCC			, Nil},;
												{"LR_CLVL"  	, cLjClvl			, Nil},;
												{"LR_BRICMS"  	, nSL2BasSol		, Nil},;
												{"LR_VALFRE"  	, nVlrItFrete  		, Nil},;
												{"LR_DESPESA"  	, nVlrItDesp   		, Nil},;
												{"LR_ICMSRET"  	, nSL2ValSol	    , Nil}})  
												
								If lCSTPIS
									Aadd(aItem[Len(aItem)], {"LR_CSTPIS"	, cCSTPis			, Nil})
								EndIf
								If lCSTIcm
									Aadd(aItem[Len(aItem)], {"LR_CLASFIS"	, cCSTIcm			, Nil})
								EndIf
								If lCSTCOF 
									Aadd(aItem[Len(aItem)], {"LR_CSTCOF"	, cCSTCof			, Nil})
								EndIf	
								If lL2FECP 
									Aadd(aItem[Len(aItem)], {"LR_VALFECP"	, nValFECP			, Nil})
									Aadd(aItem[Len(aItem)], {"LR_ALQFECP"	, nAlqFECP			, Nil})
									If lL2BASFECPST
										Aadd(aItem[Len(aItem)], {"LR_BASFECP"	, nBasFECP		, Nil})
									EndIf													
								EndIf

								If lL2FECPST
									Aadd(aItem[Len(aItem)], {"LR_VFECPST"	, nValFECPST		, Nil})
									Aadd(aItem[Len(aItem)], {"LR_ALQFCST"	, nAlqFECPST		, Nil})
									If lL2BASFECPST
										Aadd(aItem[Len(aItem)], {"LR_BSFCPST"	, nBasFECPST		, Nil})
									EndIf	
								EndIf
								
								If lBaseIPI 
									Aadd(aItem[Len(aItem)], {"LR_BASEIPI"	, nSL2BasIpi		, Nil})
								EndIf

								If lAliqIPI 
									Aadd(aItem[Len(aItem)], {"LR_IPI"		, nSL2AlqIpi		, Nil})
								EndIf
								
								If lAliqSOL 
									Aadd(aItem[Len(aItem)], {"LR_ALIQSOL"	, nSL2AlqSol	, Nil}) 
								EndIf
				
								If !Empty(cDataEntr)
									Aadd(aItem[len(aItem)], {"LR_FDTENTR"  	, cDataEntr			, Nil})
								Endif

								If !Empty(cLoteItem)
									LjGrvLog("LOJI701","IDENTIFICOU LOTE:"+cLoteItem)
									Aadd(aItem[len(aItem)], {"LR_LOTECTL"	, cLoteItem			, Nil})
									Aadd(aItem[len(aItem)], {"LR_NLOTE"	, cSubLoteItem			, Nil})
									Aadd(aItem[len(aItem)], {"LR_LOCALIZ"	, cAddresItem		, Nil})
									If !Empty(cSerieItem)
										Aadd(aItem[len(aItem)], {"LR_NSERIE"	, cSerieItem		, Nil})
									Endif
								Endif
												
							Else
								//Trata gravacao de itens cancelados																																																
								aAdd(aCancItem, { {"LX_FILIAL"	, xFilial("SL1")},;
									{"LX_OPERADO" , cOperador	},;
									{"LX_DTMOVTO" , dDataBase	},;
									{"LX_CUPOM" 	, cDoc			},;
									{"LX_SERIE"	, cSerie		},;
									{"LX_HORA" 	, Time()		},;
									{"LX_PDV"		, cPdv			},;
									{"LX_ITEM"		, cItem		},;
									{"LX_TPCANC"	, "I"			},;
									{"LX_VALOR"  	, nVlrItem		},;
									{"LX_PRODUTO"	, cProduto		},;
									{"LX_QTDE"		, nQuant		},;
									{"LX_DESCON"	, nValItDesc	},;
									{"LX_ALIQICM"	, nAliqIss		},;
									{"LX_SUPERVI"	, "PDV BEMATECH"},;
									{"LX_SITUACA"	, "00"			}})
							EndIf
					
							//Limpa as informacoes de impostos e tributacao
							nSL2Icms 		:= 0
							nSL2Iss  		:= 0
							nSL2PisApu  	:= 0
							nSL2CofApu		:= 0
							nBaseIcm 		:= 0
							nBaseIss 		:= 0
							nAliqIcm 		:= 0
							nAliqIss 		:= 0
							nSL2PisRet 		:= 0
							nBasPisRet		:= 0
							nAlqPisRet		:= 0
							nSL2PisApu		:= 0
							nBasPisApu		:= 0
							nAlqPisApu		:= 0
							nSL2CofRet 		:= 0
							nBasCofRet		:= 0
							nAlqCofRet		:= 0
							nSL2CofApu		:= 0
							nBasCofApu		:= 0
							nAlqCofApu		:= 0
							nSL2CSLL 		:= 0
							nBaseCSLL		:= 0
							nAliqCSLL		:= 0
							nSL1CSLL		:= 0
							nSL2IRRF		:= 0
							nAliqIRRF		:= 0
							nBaseIRRF		:= 0
							nAliqRed		:= 0
							cTribut  		:= "" //Inicializa codigo da tributacao
							cCodResIt 		:= ""
							cTpEntrega		:= "2"																												
							cFilRes			:= ""							
							nQtdRes			:= 0	
							cLoteItem		:= ""				
							cSubLoteItem	:= ""			
							cAddresItem		:= ""
							cSerieItem		:= ""		
							aReserva		:= {}							
							cDataEntr       := ""
							nSL2ValIpi 		:= 0
							nSL2BasIpi 		:= 0
							nSL2AlqIpi 		:= 0
							nSL2ValSol 		:= 0
							nSL2BasSol 		:= 0
							nSL2AlqSol 		:= 0
							nValFECP		:= 0
							nAlqFECP		:= 0
							nBasFECP 		:= 0	
							nValFECPST  	:= 0
							nAlqFECPST 		:= 0	
							nBasFECPST 		:= 0
							nVlrTab         := 0
							nVlrItFrete     := 0
							nVlrItDesp      := 0
							cCfop			:= ""
						Next nI
					EndIf
							
					//Verifica se continua a gravacao da venda
					If lRet

						//Tratamento para arredondamento dos itens quando existe desconto no total
						If nValDesTot > 0
							
							If nTotDesPro > 0
								//Se estiver enviando o Desconto Total Proporcionalizado no XML (tag DiscountTotalProrated), verifica se o somatorio esta de acordo com o Desconto Total enviado tambem
							 	If nValDesTot <> nTotDesPro
									lRet 	 := .F.
									cXmlRet := STR0124 + " <DiscountTotalProrated> " + STR0125 + " <DiscountValue>." //"A somatoria do Desconto Total Proporcionalizado por item da tag <DiscountTotalProrated> está diferente do Desconto Total da tag <DiscountValue>."
								EndIf
							Else
								nPosDescPro := aScan(aItem[1], {|x| AllTrim(x[1]) == "LR_DESCPRO"})
							
								If nPosDescPro > 0
									//Se Total da Venda maior que acumulado dos itens, cuidando que seja apenas 1 centavo 
									//ajusta desconto devido diferenca de arredondamento no desconto proporcional
									If nVlrTot > nVlrItTot .And. nVlrTot - nVlrItTot == 0.01
										aItem[Len(aItem)][nPosDescPro][2] -= 0.01
									ElseIf nVlrTot < nVlrItTot .And. nVlrItTot - nVlrTot == 0.01
										//Se Total da Venda menor que acumulado dos itens, cuidando que seja apenas 1 centavo 
										//ajusta desconto devido diferenca de arredondamento no desconto proporcional
										aItem[Len(aItem)][nPosDescPro][2] += 0.01
									EndIf
								EndIf
							EndIf
						EndIf
					
						//Valida se forma de pagamentos foram enviados
						If	XmlChildEx(oXmlContent:_ListOfSaleCondition, "_SALECONDITION") == Nil
							lRet 	 := .F.
							cXmlRet := STR0043 //#"Lista de Forma de Pagamentos vazia, verifique a lista SaleCondition."
						EndIf
					
						If lRet
							//Monta Condicoes de Pagamento (aPagtos)
							If ValType(oXmlContent:_ListOfSaleCondition:_SaleCondition) <> "A"
								XmlNode2Arr(oXmlContent:_ListOfSaleCondition:_SaleCondition, "_SaleCondition")
							EndIf
							
							//Valida se lista esta vazia
							If Len(oXmlContent:_ListOfSaleCondition:_SaleCondition) == 0
								lRet 	 := .F.
								cXmlRet := STR0043 //#"Lista de Forma de Pagamentos vazia, verifique a lista SaleCondition."
							EndIf
						EndIf
					
						If lRet
							For nI := 1 To Len(oXmlContent:_ListOfSaleCondition:_SaleCondition)
                                
                                //Armazena Forma de Pagamento
                                cFormaPg := ""
                                cAux     := LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_PAYMENTMETHODINTERNALID")
                                If !Empty(cAux)
                                    cFormaPg := Lji070TiPa(cMarca, cAux, .F.)
                                EndIf

                                cAux := LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_PAYMENTMETHODCODE")
                                If Empty(cFormaPg) .And. !Empty(cAux)
                                    cFormaPg := Lji070TiPa(cMarca, cAux, .T.)
                                EndIf

                                If Empty(cFormaPg)
   									lRet    := .F.
									cXmlRet := STR0044 + " " + cValToChar(nI) + "," + STR0045 + Chr(10) //#"Inconsistencia na forma de pagamento" ##"Forma de Pagamento nao informado na integracao."
									cXmlRet += STR0148 + "PaymentMethodCode/PaymentMethodInternalId"    //"Verifique as TAGs: "
									Exit
                                EndIf
							
								//Armazena Administradora Financeira																				
								cAdmFin := LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_FINANCIALMANAGERCODE")

							    //Busca De/Para da Adm Financeira na Tabela XXF
								cValInt :=  CFGA070INT( cMarca , "SAE", "AE_COD", cAdmFin )				
					 
					 			If !Empty(cValInt)					
									aAux := Separa(cValInt, "|")
								
									If ValType(aAux) == "A" .And. Len(aAux) > 2 
										cAdmFin := aAux[3]
									EndIf																						
								EndIf									

								cAdmFin := Padr(cAdmFin, TamSx3("AE_COD")[1])
										
								//Posiciona na Administradora do Protheus
								SAE->(dbSetOrder(1))
									
								If !Empty(cAdmFin) .And. SAE->(dbSeek(xFilial("SAE") + cAdmFin))
									cAdmFin := SAE->AE_COD + "-" + AllTrim(SAE->AE_DESC)
								Else
									If AllTrim(cFormaPg) $ "CC|CD"
										lRet 	 := .F.
										cXmlRet := STR0044 + " " + CValToChar(nI) + "," + STR0050 + Chr(10) //#"Inconsistencia na forma de pagamento" ##"Administradora Financeira invalida ou nao encontrada no dePara no Protheus." 
										cXmlRet += STR0051 //#"Esta informacao e obrigatoria para pagamentos em cartao, verifique a tag: FinancialManagerCode."
										Exit
									EndIf
								EndIf
									
								//Tratamento para Gravação do Código do Banco
								If AllTrim(cFormaPg) == "CH"
									cBanck  := LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_BANKCHECK")
									cValInt :=  CFGA070INT( cMarca , "SX5", "X5_CHAVE", cBanck )		
									If !Empty(cValInt)					
										aAux := Separa(cValInt, "|")
										If ValType(aAux) == "A" .And. Len(aAux) > 3
											If AllTrim(aAux[3]) == "K6" 
												cAdmFin := Padr(aAux[4], TamSx3("X5_CHAVE")[1])
											Endif
										EndIf	
									EndIf																						
																													
									If Empty(cAdmFin)
										lRet 	:= .F.
										cXmlRet := "Nao existe amarração De/Para para o Banco: "+cBanck 
										Exit
									Endif
								Endif							
								
								//Inicializa InternalId do RA a ser compensado
								cIntIdRA := ""
									
								//Validacoes de campos obrigatorios
								If XmlChildEx(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_PAYMENTVALUE") == Nil .Or.;
										Empty(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI]:_PaymentValue:Text) .Or.;
										Val(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI]:_PaymentValue:Text) <= 0
									lRet 	 := .F.
									cXmlRet := STR0044 + " " + CValToChar(nI) + "," + STR0052 //#"Inconsistencia na forma de pagamento" ##"Valor do Pagamento nao informado na integracao, verifique a tag: PaymentValue."
									Exit
								ElseIf AllTrim(cFormaPg) == "RA" //Informacoes compensacao titulo hotelaria
									cIntIdRA := LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_ACCOUNTRECEIVABLEDOCUMENTINTERNALID")
										
									If Empty(cIntIdRA)
										lRet 	 := .F.
										cXmlRet := STR0044 + " " + CValToChar(nI) + "," + STR0066 + Chr(10) //#"Inconsistencia na forma de pagamento" ##"InternalId do RA nao informado"
										cXmlRet += STR0067 //#"Esta informacao e obrigatoria para pagamentos RA, verifique a tag: AccountReceivableDocumentInternalId"
										Exit
									Else
										aAux := IntTRcInt(cIntIdRA, cMarca) //Resgatando os dados do título pelo InternalId
											
										//Armazena informacoes do adiantamento
										If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
											SE1->(dbSetOrder(1))
												
											//Posiciona no Titulo RA	
											If SE1->(dbSeek(xFilial("SE1") + PadR(aAux[2][3],TamSX3("E1_PREFIXO")[1]) + PadR(aAux[2][4],TamSX3("E1_NUM")[1]) +;
													PadR(aAux[2][5],TamSX3("E1_PARCELA")[1]) + PadR(aAux[2][6],TamSX3("E1_TIPO")[1])))
													
												//Valida se titulo foi compensado manualmente
												If SE1->E1_SALDO > 0
													cRecRa := CValToChar(SE1->(Recno()))
												Else
													lRet 	 := .F.
													cXmlRet := STR0044 + " " + CValToChar(nI) + "," + STR0086 + ":" + AllTrim(cIntIdRA) + " " + STR0092 + Chr(10) ////#"Inconsistencia na forma de pagamento" ##"O titulo de adiantamento" ###"encontra-se baixado"
													cXmlRet += STR0093 //#"Necessário desfazer a compensação no financeiro."
												EndIf
											Else
												lRet 	 := .F.
												cXmlRet := STR0044 + " " + CValToChar(nI) + "," + STR0086 + ":" + AllTrim(cIntIdRA) + " " + STR0089 + Chr(10) //#"Inconsistencia na forma de pagamento" ##"O titulo de adiantamento" ###"nao foi encontrado na base de dados Protheus"
												cXmlRet += STR0087 //#"Verifique a tag: AccountReceivableDocumentInternalId"
											EndIf
										Else
											lRet 	 := .F.
											cXmlRet := STR0044 + " " + CValToChar(nI) + "," + STR0086 + ":" + AllTrim(cIntIdRA) + " " + STR0088 + Chr(10) //#"Inconsistencia na forma de pagamento" ##"O titulo de adiantamento" ###"nao foi integrado ao Protheus"
											cXmlRet += STR0087 //#"Verifique a tag: AccountReceivableDocumentInternalId"
										EndIf
									EndIf
								EndIf
									
								//Armazena Data do Pagamento
								cDataPgto := LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_DATEOFPAYMENT", "D")
									
								If Empty(cDataPgto)
									cDataPgto := cEmissao
								EndIf
									
								//Armazena Data de Pagamento
								dDataPagto	 := SToD(cDataPgto)
									
								//Informacoes TEF	
								cL4HoraTef 	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTDATE", "T")	//Hora Tef SL4
								cL4HoraTef	 	:= AllTrim(StrTran(cL4HoraTef, ":", ""))
									
								cL4HrCanTef	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTCANCELLATIONDATE", "T") //Data de Cancelamento Tef SL4
								cL4HrCanTef	:= AllTrim(StrTran(cL4HrCanTef, ":", ""))
														
								//Verifica utilizacao de Tef
								lTef := !Empty(LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTDATE", "D"))
								
								//Incrementa Item Tef
								If lTef
									nItemTef ++
								EndIf
									
								If lTef
									
									//Esta validacao eh necessaria pois SL1 grava apenas a parcela 1 do Tef
									If	nItemTef == 1
										//Armazena informacoes Tef para SL1
										cL1VendTef	:= "S" //Venda Tef SL1
										cL1DataTef	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTDATE", "D") //Data Tef SL1
										cL1HoraTef	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTDATE", "T") //Hora Tef Sl1
										cL1HoraTef := AllTrim(StrTran(cL1HoraTef, ":", ""))
										cL1DocTef	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTDOCUMENT") //Documento Tef Sl1
										cL1Autoriz	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTAUTORIZATION") //Autorizacao Tef SL1
										cL1DocCanc	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTCANCELLATIONDOCUMENT") //Documento de Cancelamento Tef SL1
										cL1DatCanc	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTCANCELLATIONDATE", "D") //Data de Cancelamento Tef SL1
										cL1HorCanc	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTCANCELLATIONDATE", "T") //Hora Cancelamento Tef SL1
										cL1HorCanc := AllTrim(StrTran(cL1HorCanc, ":", ""))
										cL1Institu	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTINSTITUTE") //Instituro Tef SL1
										cL1NsuTef	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_UNIQUESERIALNUMBER") //Nsu Tef SL1
									EndIf
								EndIf
																							
								cFormaId 	:= ""
								cNsu	  	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_UNIQUESERIALNUMBER")
								cAutoriz	:= LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTAUTORIZATION")
									
								If AllTrim(cFormaPg) $ "CC|CD"
									
									//Tef sempre envia a data de emissao pois o GravaBatch calcula com base na Administradora Financeira - SAE
									//venda com POS essa informação não é enviada.
									If !Empty(cL1DataTef)
										dDataPagto := SToD(cEmissao) 
									Endif
																		
									//Tratamento FormaId para multiplos cartoes
									If Len(aParcela) == 0
										nFormaId ++
									Else
										nPosNsu 	:= aScan(aParcela[1], {|x| AllTrim(x[1]) == "L4_NSUTEF"})
										nPosAutoriz := aScan(aParcela[1], {|x| AllTrim(x[1]) == "L4_AUTORIZ"})
																					
										If aScan(aParcela, {|x| AllTrim(x[nPosNsu][2]) == AllTrim(cNsu)}) == 0 .Or. ;//Se nao encontrou NSU, incrementa ID	 pois é MultiTef
											aScan(aParcela, {|x| AllTrim(x[nPosAutoriz][2]) == AllTrim(cAutoriz)}) == 0 //Ou se nao encontrou cAutoriz, incrementa ID	 pois é MultiTef
											nFormaId ++
										EndIf
									EndIf
										
									cFormaId := CValToChar(nFormaId)
								EndIf
																			
								/* Efetua a carga das tabela SL4 */
								//Alimenta array de Pagamentos								       		   		      		      							
								aAdd(aParcela, {	{"L4_DATA"    , dDataPagto																									  	, Nil},;
									{"L4_VALOR"  	, Val(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI]:_PaymentValue:Text)				, Nil},;
									{"L4_FORMA"  	, cFormaPg																											, Nil},;
									{"L4_ADMINIS"	, cAdmFin	 																										, Nil},;
									{"L4_NUMCART"	, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_CARDNUMBER")							, Nil},;
									{"L4_SERCHQ"  , LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_SERIECHECK") 							, Nil},;
									{"L4_AGENCIA"	, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_AGENCYCHECK")  						, Nil},;
									{"L4_CONTA"	, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_ACCOUNTCHECK")  						, Nil},;
									{"L4_RG"		, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_DOCUMENTOFIDENTIFICATION")			, Nil},;
									{"L4_TELEFON"	, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_PHONENUMBER") 						, Nil},;
									{"L4_TERCEIR"	, "F"      																										, Nil},;
									{"L4_FORMAID" , cFormaId       																									, Nil},;
									{"L4_DATATEF"	, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTDATE", "D")						, Nil},;
									{"L4_HORATEF"	, cL4HoraTef																				 						, Nil},;
									{"L4_DOCTEF" 	, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTDOCUMENT")							, Nil},;
									{"L4_AUTORIZ"	, LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTAUTORIZATION")					, Nil},;
									{"L4_DATCANC" , LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTCANCELLATIONDATE", "D")			, Nil},;
									{"L4_HORCANC"	, cL4HrCanTef																										, Nil},;
									{"L4_DOCCANC" , LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTCANCELLATIONDOCUMENT")			, Nil},;
									{"L4_INSTITU" , LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTINSTITUTE")						, Nil},;
									{"L4_NSUTEF"  , cNsu																												, Nil},;
									{"L4_MOEDA"  	, nMoeda																											, Nil},;
									{"L4_PARCTEF" , LjiVldTag(oXmlContent:_ListOfSaleCondition:_SaleCondition[nI], "_EFTPARCEL")							, Nil},;
									{"L4_VENDTEF" , IIF(lTef, "S", "N")																							, Nil},;
									{"L4_CONHTL" 	, cRecRa																											, Nil}})
							Next nI
						EndIf
					EndIf

					//Verifica se continua a gravacao da venda
					If lRet
						//Informacoes venda com Pedido de Venda
						If lPedVen
							aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_DOC"})][2]     := ""
							aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_SERIE"})][2]   := ""							
							aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_NUMCFIS"})][2] := ""
							aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_DOCPED"})][2]  := cDoc
							aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_SERPED"})][2]  := cSerie
							aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_TIPO"})][2]    := "P"							
							aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_RESERVA"})][2] := "S"
						EndIf
					
						//Comissao do Vendedor
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_VALCOMI"})][2] := nValComis
																	
						//Adiciona informacoes Tef
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_VENDTEF"})][2] := cL1VendTef	 //Venda Tef Sl1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_DATATEF"})][2] := cL1DataTef	 //Data Tef SL1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_HORATEF"})][2] := cL1HoraTef	 //Hora Tef Sl1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_DOCTEF"})][2]  := cL1DocTef	 //Documento Tef Sl1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_AUTORIZ"})][2] := cL1Autoriz	 //Autorizacao Tef SL1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_DOCCANC"})][2] := cL1DocCanc 	 //Documento de Cancelamento Tef SL1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_DATCANC"})][2] := cL1DatCanc	 //Data de Cancelamento Tef SL1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_HORCANC"})][2] := cL1HorCanc	 //Hora Cancelamento Tef SL1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_INSTITU"})][2] := cL1Institu	 //Instituro Tef SL1
						aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_NSUTEF"})][2]  := cL1NsuTef	 //Nsu Tef SL1
																
						//Atualiza Valor Total Mercadoria se necessario
						If nVlMercTot < nVlrMercIt
							aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_VALMERC"})][2] := nVlrMercIt
						EndIf
						
						dDataBkp  := dDataBase //Salva data atual
						dDataBase := StoD(cEmissao) //Altera Database
																																																								
						//Efetua a gravacao da venda
						LjGrvLog("LOJI701","CHAMADA EXECAUTO: "+Time())	
						Begin Transaction
							lMsErroAuto := .F.
							SetFunName("LOJA701")
							MSExecAuto({|a,b,c,d,e,f,g,h| Loja701(a,b,c,d,e,f,g,h)}, .F., nOpcX, "", "", {}, aCab, aItem, aParcela)
																						 		 																								
							//Verifica se encontrou erros na gravacao da venda			
							If lMsErroAuto
								aErroAuto := GetAutoGrLog()
																             	
			             		//Armazena mensagens de erro	             	
								cXMLRet := "<![CDATA["
								For nI := 1 To Len(aErroAuto)
									cXMLRet += aErroAuto[nI] + Chr(10)
								Next nI
								cXMLRet += "]]>"
							
								If Len(aErroAuto) == 0
									cXMLRet := STR0025 + " " + AllTrim(cIdExt) //#"Erro na gravacao da venda: "
								EndIf

								LjGrvLog("LOJI701","ERRO EXECAUTO: "+ cXMLRet ,, .T.)
							
			          			//Monta XML de Erro de execução da rotina automatica
								lRet := .F.
				
			             		//Desfaz a transacao
								DisarmTransaction()
							
								//Libera sequencial 
								RollBackSx8()
								MsUnLockAll()
							Else
							
								//Armazena InternalId do Protheus																	
								aInternal := IntVendExt(cEmpAnt, xFilial("SL1"), cSerie, cDoc, cPdv)
																		
								//Valida se gerou a venda
								If Len(aInternal) > 0
									If aInternal[1]
										cValInt := aInternal[2]
																																																																				
										//Adiciona item no De/Para - XXF								
										If CFGA070Mnt(cMarca, "SL1", "L1_DOC", cIdExt, cValInt, .F.)
					                		//Monta o XML de Retorno
											cXmlRet := "<ListOfInternalId>"
											cXmlRet +=    "<InternalId>"
											cXmlRet +=       "<Name>RetailSalesInternalId</Name>"
											cXmlRet +=       "<Origin>" + cIdExt + "</Origin>"
											cXmlRet +=       "<Destination>" + cValInt + "</Destination>"
											cXmlRet +=    "</InternalId>"
											cXmlRet += "</ListOfInternalId>"
										EndIf
						   			
						   				//Verifica se foi efetuado cancelamento da venda anteriormente
										If ExistFunc("Lj140DelSLX")
											Lj140DelSLX(cMarca)
										Endif
						   			
							   			//Trata gravacao de itens cancelados
										If Len(aCancItem) > 0
											For nS := 1 To Len(aCancItem)
												Lj7GeraSL("SLX", aCancItem[nS], .T.)
											Next nS
										EndIf
									
										If lIntegHtl .OR. (!lIntegHtl .AND. cTipoVen == "D") //Hotelaria ou Beneficiamento
											If lRps .And. (lReserva .Or. !Empty(cRateio)) .OR. cTipoVen == "D"
												MH3->(DbSetOrder(1))
												RecLock( "MH3", .T. )
												MH3->MH3_FILIAL := FWxFilial( "MH3" )
												MH3->MH3_SERRPS := cSerie
												MH3->MH3_DOCRPS := cDoc
												MH3->MH3_DTOUT  := SToD( cEmissao )
												If !cTipoVen == "D"
													MH3->MH3_DTIN   := SToD( cDataIn )
													MH3->MH3_RESERV := cReserva
													MH3->MH3_TIPOUH := cTipoUH
													MH3->MH3_NUMUH  := cNumUH
													MH3->MH3_HOSPRI := cHospede
													MH3->MH3_HOSPED := cOutrosHsp
													MH3->MH3_GRUPO  := cGrupoRsv
													MH3->MH3_EVENTO := cEventoRsv
													MH3->MH3_LANC   := cLanctos
													MH3->MH3_RATEIO := cRateio
												Endif
												MH3->( MsUnlock() )
											EndIf
																																		
											//Gravacao dos itens de pensao
											MH4->(DbSetOrder(1))
											For nI := 1 To Len(aItemMh4)
												RecLock( "MH4", .T. )
												MH4->MH4_FILIAL := FWxFilial( "MH4" )
												MH4->MH4_SERRPS := aItemMh4[nI][1]
												MH4->MH4_DOCRPS := aItemMh4[nI][2]
												MH4->MH4_ITEM   := FR271BPegaIT(Val(aItemMh4[nI][3])) 
												If !cTipoVen == "D"
													MH4->MH4_TIPPEN := aItemMh4[nI][4]
													MH4->MH4_VLRPEN := aItemMh4[nI][5]
													MH4->MH4_VLRCAF := aItemMh4[nI][6]
													MH4->MH4_IDF100 := aItemMh4[nI][7]
													MH4->MH4_DTF100 := aItemMh4[nI][8]
												Else
													MH4->MH4_DOCORI := aItemMh4[nI][9]
													MH4->MH4_SERORI := aItemMh4[nI][10]
													MH4->MH4_ITEORI := aItemMh4[nI][11]
												Endif

												MH4->( MsUnlock() )
											Next nI
										EndIf
									
										ConfirmSx8()
						         	
										RecLock("SL1", .F.)
										SL1->L1_SITUA := "RX"
										SL1->L1_NUMMOV := cNumMov
										SL1->(MsUnLock())
										IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit(), NIL)
									Else
										lRet 	 := .F.
										cXmlRet := STR0025 + " " + AllTrim(cIdExt) //#"Erro na gravacao da venda: "
									EndIf
								Else
									lRet 	 := .F.
									cXmlRet := STR0025 + " " + AllTrim(cIdExt) //#"Erro na gravacao da venda: "
								EndIf
							EndIf
						End Transaction
					
						//Apos efetuar a transação efetuamos um doublecheck para saber se a venda está realmente gravado na base 
						//e se não existir deleta o De\Para(Caso Exista) para evitar inconsistencia de base.
						//Esse ajuste foi necessario pois o execauto do LOJA701 nao trata todos cenarios de erros possiveis. E pode ter vendas não gravadas e o execauto nao retornou erro.						
						DbSelectArea("SL1")
						SL1->(DbSetOrder(2))	//SL1 L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
						If lRet .And. !SL1->(DbSeek(xFilial("SL1")+cSerie+cDoc+cPdv))
							SL1->(DbSetOrder(11))//SL1 L1_FILIAL+L1_SERPED+L1_DOCPED				
							If !SL1->(DbSeek(xFilial("SL1")+cSerie+cDoc))
								CFGA070Mnt(cMarca, "SL1", "L1_DOC", cIdExt, cValInt, .T. /*Delete*/)
								lRet    := .F.
								cXmlRet += " | " + STR0025 + " " + AllTrim(cIdExt) + " | DBCHK." //#"Erro na gravacao da venda: "
								LjGrvLog("LOJI701",STR0025 + " " + AllTrim(cIdExt) + " | DBCHK.")
							EndIf	 
						Endif
						dDataBase := dDataBkp //Restaura Database
					EndIf
				ElseIf nOpcX == 2 //Evento de Atualizacao
					If lIntegHtl //Hotelaria
						//Armazena codigo da reserva que sera alterado
						If XmlChildEx(oXmlContent, "_BOOKINGINFORMATION") <> Nil
							cReserva := LjiVldTag(oXmlContent:_BookingInformation, "_HOTELACCOUNTCODE", "C") //Numero da Reserva
						EndIf
												
						cSerie := Padr(aAux[2][3], TamSx3("L1_SERIE")[1])
						cDoc 	:= Padr(aAux[2][4], TamSx3("LQ_DOC")[1])
						cPdv 	:= Padr(aAux[2][5], TamSx3("LQ_PDV")[1])
						
						SL1->(dbSetOrder(2))
						SL1->(dbSeek(xFilial("SL1") + cSerie + cDoc + cPdv))
													
						SL1->(RecLock("SL1", .F.))
						SL1->L1_RESEHTL := cReserva
						SL1->(MsUnLock())
											
						//Armazena InternalId do Protheus
						cValInt := IntVendExt(cEmpAnt, SL1->L1_FILIAL, SL1->L1_SERIE, SL1->L1_DOC, SL1->L1_PDV)[2]
					
						//Monta o XML de Retorno
						cXmlRet := "<ListOfInternalId>"
						cXmlRet +=    "<InternalId>"
						cXmlRet +=       "<Name>RetailSalesInternalId</Name>"
						cXmlRet +=       "<Origin>" + cIdExt + "</Origin>"
						cXmlRet +=       "<Destination>" + cValInt + "</Destination>"
						cXmlRet +=    "</InternalId>"
						cXmlRet += "</ListOfInternalId>"
					Else
						lRet    := .F.
						cXmlRet := STR0022 + " " + AllTrim(cIdExt) + " " + STR0023 //#"Cupom:" ##" ja integrado no Protheus"
					EndIf
				EndIf
			EndIf
		Else
			lRet    := .F.
			cXmlRet := STR0024 //#"Atualize EAI"
		EndIf
	
		//Tratamento para evitar retorno incorreto
		If Empty(cXMLRet)
			lRet 	 := .F.
			cXmlRet := STR0025 + " " + AllTrim(cIdExt) //#"Erro na gravacao da venda:"
		EndIf
	ElseIf nTypeTrans == TRANS_SEND

		cEvent   := "upsert" //Evento
	
		//Verifica flag de cancelamento da venda
		lCancVen := LjiVendCanc()
	
		//Inclusao de Venda ativa
		If !lCancVen			
			//InternalId da Venda	
			aAux := IntVendExt(/*Empresa*/, /*Filial*/, SL1->L1_SERIE, SL1->L1_DOC, SL1->L1_PDV, /*Versão*/)
		
			If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
				cValInt := aAux[2]
			Else
				cValInt := ""
			EndIf
		
			//InternalId do Cliente
			aAux := IntCliExt(/*Empresa*/, /*Filial*/, SL1->L1_CLIENTE, SL1->L1_LOJA, /*Versão*/)
		
			If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
				cCliInt := aAux[2]
			Else
				cCliInt := ""
			EndIf
		
			//InternalId do Vendedor
			aAux := IntVenExt(/*Empresa*/, /*Filial*/, SL1->L1_VEND, /*Versão*/)
		
			If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
				cVendInt := aAux[2]
			Else
				cVendInt := ""
			EndIf
	
			//InternalId da Estacao de Trabalho
			aAux := IntEstacExt(/*Empresa*/, /*Filial*/, SL1->L1_ESTACAO, /*Versão*/)
		
			If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
				cEstInt := aAux[2]
			Else
				cEstInt := ""
			EndIf
	
			//Data de Emissao
			If !Empty(SL1->L1_EMISSAO)
				cEmissao := SubStr(DToS(SL1->L1_EMISSAO), 1, 4) + '-' + SubStr(DToS(SL1->L1_EMISSAO), 5, 2) + '-' + SubStr(DToS(SL1->L1_EMISSAO), 7, 2)
		
				//Hora de Emissao	
				cEmissao += "T"
				cEmissao += RTrim(SL1->L1_HORA)
			EndIf

			Do Case
			
			Case !Empty(SL1->L1_ESPECIE)
				cKdOfDoc := RTrim(SL1->L1_ESPECIE)
			Case Empty(SL1->L1_SERSAT) .AND. !Empty(SL1->L1_KEYNFCE) 
				cKdOfDoc := "NFCE"
			OtherWise
				cKdOfDoc := "CF"

			EndCase

			cXmlRet := '<BusinessEvent>'
			cXmlRet +=     '<Entity>RETAILSALES</Entity>'
			cXmlRet +=     '<Event>' + cEvent + '</Event>'
			cXmlRet +=     '<Identification>'
			cXmlRet +=         '<key name="InternalId">' + cValInt + '</key>'
			cXmlRet +=     '</Identification>'
			cXmlRet += '</BusinessEvent>'
		
			cXmlRet += '<BusinessContent>'
	
			//Cabecalho da Venda
			cXmlRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
			cXmlRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
			cXmlRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
			cXmlRet +=    '<InternalId>' + cValInt + '</InternalId>'
			cXmlRet +=    '<SellerInternalId>' + cVendInt + '</SellerInternalId>'
			cXmlRet +=    '<ComissionPercent>' + CValToChar(SL1->L1_COMIS) + '</ComissionPercent>'
			cXmlRet +=    '<CustomerVendorInternalId>' + cCliInt + '</CustomerVendorInternalId>'
			cXmlRet +=    '<TotalPrice>' + CValToChar(SL1->L1_VLRTOT) + '</TotalPrice>'
			cXmlRet +=    '<DiscountValue>' + CValToChar(SL1->L1_DESCONT) + '</DiscountValue>'
			cXmlRet +=    '<IncreaseValue>' + CValToChar(SL1->L1_SEGURO + SL1->L1_DESPESA) + '</IncreaseValue>'
			cXmlRet +=    '<FreightValue>'  + CValToChar(SL1->L1_FRETE) + '</FreightValue>'
			cXmlRet +=    '<NetPrice>' + CValToChar(SL1->L1_VLRLIQ) + '</NetPrice>'
			cXmlRet +=    '<CashValue>' + CValToChar(SL1->L1_DINHEIR) + '</CashValue>'
			cXmlRet +=    '<ChecksValue>' + CValToChar(SL1->L1_CHEQUES) + '</ChecksValue>'
			cXmlRet +=    '<CardsValue>' + CValToChar(SL1->L1_CHEQUES) + '</CardsValue>'
			cXmlRet +=    '<DebitValue>' + CValToChar(SL1->L1_VLRDEBI) + '</DebitValue>'
			cXmlRet +=    '<CovenantValue>' + CValToChar(SL1->L1_CONVENI) + '</CovenantValue>'
			cXmlRet +=    '<VouchersValue>' + CValToChar(SL1->L1_VALES) + '</VouchersValue>'
			cXmlRet +=    '<FinancedValue>' + CValToChar(SL1->L1_FINANC) + '</FinancedValue>'
			cXmlRet +=    '<OthersValue>' + CValToChar(SL1->L1_OUTROS) + '</OthersValue>'
			cXmlRet +=    '<InputValue>' + CValToChar(SL1->L1_ENTRADA) + '</InputValue>'
			cXmlRet +=    '<IssueDateDocument>' + cEmissao + '</IssueDateDocument>'
			cXmlRet +=    '<DocumentCode>' + RTrim(SL1->L1_DOC) + '</DocumentCode>'
			cXmlRet +=    '<SerieCode>' + RTrim(SL1->L1_SERIE) + '</SerieCode>'
			cXmlRet +=    '<GrossPrice>' + CValToChar(SL1->L1_VALBRUT) + '</GrossPrice>'
			cXmlRet +=    '<CommodityPrice>' + CValToChar(SL1->L1_VALMERC) + '</CommodityPrice>'
			cXmlRet +=    '<DiscountPercent>' + CValToChar(SL1->L1_DESCNF) + '</DiscountPercent>'
			cXmlRet +=    '<OperatorCode>' + RTrim(SL1->L1_OPERADO) + '</OperatorCode>'
			cXmlRet +=    '<CurrencyRate>' + CValToChar(SL1->L1_TXMOEDA) + '</CurrencyRate>'
			cXmlRet +=    '<Change>' + CValToChar(SL1->L1_TROCO1) + '</Change>'
			cXmlRet +=    '<StationCode>' + RTrim(SL1->L1_PDV) + '</StationCode>'
			cXmlRet +=    '<DiscountPaymentTerm>' + CValToChar(SL1->L1_DESCFIN) + '</DiscountPaymentTerm>'
			cXmlRet +=    '<CreditValue>' + CValToChar(SL1->L1_CREDITO) + '</CreditValue>'
			cXmlRet +=    '<KindOfDocument>' + cKdOfDoc + '</KindOfDocument>'
			cXmlRet +=    '<CarrierCode>' + RTrim(SL1->L1_TRANSP) + '</CarrierCode>'
			cXmlRet +=    '<CarrierInternalId>' + Lj701ITran(/*cMarca*/, nTypeTrans, SL1->L1_TRANSP, /*cInternalId*/)[2] + '</CarrierInternalId>'
			cXmlRet +=    '<Md5>' + RTrim(SL1->L1_PAFMD5) + '</Md5>'
			cXmlRet +=    '<PersonalIdentification>' + RTrim(SL1->L1_CGCCLI) + '</PersonalIdentification>'
			cXmlRet +=    '<IsCanceled>' + IIF(lCupCancel, "true", "false") + '</IsCanceled>'
			cXmlRet +=    '<StationSalePointCode>' + RTrim(SL1->L1_ESTACAO) + '</StationSalePointCode>'
			cXmlRet +=    '<StationSalePointInternalId>' + cEstInt + '</StationSalePointInternalId>'
			cXmlRet +=    '<SerialNumberSATEquipament>' + RTrim(SL1->L1_SERSAT) + '</SerialNumberSATEquipament>'
			cXmlRet +=    '<SaleType>' + IIF(Empty(SL1->L1_SERSAT), "V", "S") + '</SaleType>'
			cXmlRet +=    '<KeyAcessNFe>' + RTrim(SL1->L1_KEYNFCE) + '</KeyAcessNFe>'
	        cXmlRet +=    '<InvoiceMessages>' + CValToChar(SL1->L1_MENNOTA) + '</InvoiceMessages>'
	        
			//Lista de Impostos da venda
			cXmlRet += 	'<ListOfTaxes>'
			cXmlRet += 		'<Tax>'
			cXmlRet +=    		'<Taxe>COFINS</Taxe>'
			cXmlRet +=    		'<Value>' + CValToChar(SL1->L1_VALCOFI) + '</Value>'
			cXmlRet += 		'</Tax>'
			cXmlRet += 		'<Tax>'
			cXmlRet +=    		'<Taxe>CSLL</Taxe>'
			cXmlRet +=    		'<Value>' + CValToChar(SL1->L1_VALCSLL) + '</Value>'
			cXmlRet += 		'</Tax>'
			cXmlRet += 		'<Tax>'
			cXmlRet +=    		'<Taxe>ISS</Taxe>'
			cXmlRet +=    		'<Value>' + CValToChar(SL1->L1_VALISS) + '</Value>'
			cXmlRet += 		'</Tax>'
			cXmlRet += 		'<Tax>'
			cXmlRet +=    		'<Taxe>PIS</Taxe>'
			cXmlRet +=    		'<Value>' + CValToChar(SL1->L1_VALPIS) + '</Value>'
			cXmlRet += 		'</Tax>'
			cXmlRet += 		'<Tax>'
			cXmlRet +=    		'<Taxe>IPI</Taxe>'
			cXmlRet +=    		'<Value>' + CValToChar(SL1->L1_VALIPI) + '</Value>'
			cXmlRet += 		'</Tax>'
			cXmlRet += 		'<Tax>'
			cXmlRet +=    		'<Taxe>ICM</Taxe>'
			cXmlRet +=    		'<Value>' + CValToChar(SL1->L1_VALICM) + '</Value>'
			cXmlRet += 		'</Tax>'
			cXmlRet += 	'</ListOfTaxes>'
	
			//Itens ativados e cancelados da Venda
			cXmlRet += 	'<ListOfSaleItem>'
			
			//Itens cancelados
			SLX->(dbSeek(SL1->L1_FILIAL + SL1->L1_PDV + SL1->L1_DOC + SL1->L1_SERIE))
		
			While SLX->(!EOF()) .And. SLX->LX_FILIAL == SL1->L1_FILIAL .And. SLX->LX_PDV == SL1->L1_PDV .And.;
					SLX->LX_CUPOM == SL1->L1_DOC .And. SLX->LX_SERIE == SL1->L1_SERIE

				//Verifica se cancelamento por item
				If SLX->LX_TPCANC == "I"
					lItCancel := .T. //Flag de item cancelado
				
					//InternalId do Produto				
					aAux := IntProExt(/*Empresa*/, /*Filial*/, SLX->LX_PRODUTO, /*Versão*/)
				
					If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
						cProdInt := aAux[2]
					Else
						cProdInt := ""
					EndIf
			
					//Unidade de Medida
					cUniMed  := RTrim(Posicione("SB1", 1, xFilial("SB1") + SLX->LX_PRODUTO, "B1_UM"))
				
					//InternalId da Unidade de Medida				
					aAux := IntUndExt(/*Empresa*/, /*Filial*/, cUniMed, /*Versão*/)
				
					If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
						cUMInt := aAux[2]
					Else
						cUMInt := ""
					EndIf
																
					cXmlRet += 	'<SaleItem>'
					cXmlRet +=    	'<InternalId>' + cValInt + '</InternalId>'
					cXmlRet +=    	'<ItemInternalId>' + cProdInt + '</ItemInternalId>'
					cXmlRet +=    	'<ItemCode>' + RTrim(SLX->LX_PRODUTO) + '</ItemCode>'
					cXmlRet +=    	'<ItemOrder>' + LjPegaIT(SLX->LX_ITEM,@aItens) + '</ItemOrder>'
					cXmlRet +=    	'<Quantity>' + CValToChar(SLX->LX_QTDE) + '</Quantity>'
					cXmlRet +=    	'<UnitPrice>' + CValToChar(SLX->LX_VRUNIT) + '</UnitPrice>'
					cXmlRet +=    	'<ItemTablePrice>' + Iif(SLX->(FieldPos("LX_PRCTAB")) > 0, CValToChar(SLX->LX_PRCTAB), '') + '</ItemTablePrice>'
					cXmlRet +=    	'<ItemPrice>' + CValToChar(SLX->LX_VALOR) + '</ItemPrice>'
					cXmlRet +=    	'<DiscountPercentage>' + CValToChar((SLX->LX_DESCON / SLX->LX_VALOR) * 100) + '</DiscountPercentage>'
					cXmlRet +=    	'<DiscountAmount>' + CValToChar(SLX->LX_DESCON) + '</DiscountAmount>'
					cXmlRet +=    	'<IsCanceled>' + IIF(lItCancel, "true", "false") + '</IsCanceled>'
					cXmlRet +=    	'<UnitOfMeasureCode>' + cUniMed + '</UnitOfMeasureCode>'
					cXmlRet +=    	'<UnitOfMeasureInternalId>' + cUMInt + '</UnitOfMeasureInternalId>'
					cXmlRet += 	'</SaleItem>'
					
				EndIf
		
				SLX->(dbSkip())
			EndDo


			//Itens ativados
			SL2->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))
			
			While SL2->(!EOF()) .And. SL2->L2_FILIAL == SL1->L1_FILIAL .And. SL2->L2_NUM == SL1->L1_NUM
				lItCancel := .F. //Flag de item ativado
			
				//InternalId do Produto				
				aAux := IntProExt(/*Empresa*/, /*Filial*/, SL2->L2_PRODUTO, /*Versão*/)
			
				If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
					cProdInt := aAux[2]
				Else
					cProdInt := ""
				EndIf
			
				//Unidade de Medida
				cUniMed  := RTrim(Posicione("SB1", 1, xFilial("SB1") + SL2->L2_PRODUTO, "B1_UM"))
			
				//InternalId da Unidade de Medida				
				aAux := IntUndExt(/*Empresa*/, /*Filial*/, cUniMed, /*Versão*/)
			
				If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
					cUMInt := aAux[2]
				Else
					cUMInt := ""
				EndIf
		
				//InternalId do Local de Estoque				
				aAux := IntLocExt(/*Empresa*/, /*Filial*/, SL2->L2_LOCAL, /*Versão*/)
			
				If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
					cLocInt := aAux[2]
				Else
					cLocInt := ""
				EndIf
		
				cXmlRet += 	'<SaleItem>'
				cXmlRet +=    	'<InternalId>' + cValInt + '</InternalId>'
				cXmlRet +=    	'<ItemInternalId>' + cProdInt + '</ItemInternalId>'
				cXmlRet +=    	'<ItemCode>' + RTrim(SL2->L2_PRODUTO) + '</ItemCode>'
				cXmlRet +=    	'<ItemOrder>' + LjPegaIT(SL2->L2_ITEM,@aItens) + '</ItemOrder>'
				cXmlRet +=    	'<Quantity>' + CValToChar(SL2->L2_QUANT) + '</Quantity>'
				cXmlRet +=    	'<UnitPrice>' + CValToChar(SL2->L2_VRUNIT) + '</UnitPrice>'
                cXmlRet +=    	'<ItemTablePrice>' + CValToChar(SL2->L2_PRCTAB) + '</ItemTablePrice>'
				cXmlRet +=    	'<ItemPrice>' + CValToChar(SL2->L2_VLRITEM) + '</ItemPrice>'
				cXmlRet +=    	'<DiscountPercentage>' + CValToChar(SL2->L2_DESC) + '</DiscountPercentage>'
				cXmlRet +=    	'<DiscountAmount>' + CValToChar(SL2->L2_VALDESC) + '</DiscountAmount>'
				cXmlRet +=    	'<OperationCode>' + RTrim(SL2->L2_CF) + '</OperationCode>'
				cXmlRet +=    	'<Increase>0</Increase>'
				cXmlRet +=    	'<IsCanceled>' + IIF(lItCancel, "true", "false") + '</IsCanceled>'
				cXmlRet +=    	'<UnitOfMeasureCode>' + cUniMed + '</UnitOfMeasureCode>'
				cXmlRet +=    	'<UnitOfMeasureInternalId>' + cUMInt + '</UnitOfMeasureInternalId>'
				cXmlRet +=    	'<WarehouseCode>' + RTrim(SL2->L2_LOCAL) + '</WarehouseCode>'
				cXmlRet +=    	'<WarehouseInternalId>' + cLocInt + '</WarehouseInternalId>'
				cXmlRet +=   	'<IncreaseValueProrated>' + CValToChar(SL2->L2_SEGURO + SL2->L2_DESPESA) + '</IncreaseValueProrated>'
				cXmlRet +=    	'<FreightValueProrated>'  + CValToChar(SL2->L2_VALFRE) + '</FreightValueProrated>'
		
				//Lista de Impostos do item
				cXmlRet += 		'<ListOfTaxes>'
				cXmlRet += 			'<Tax>'
				cXmlRet +=    			'<Taxe>COFINS</Taxe>'
				cXmlRet +=    			'<Value>' + CValToChar(SL2->L2_VALCOFI) + '</Value>'
				cXmlRet += 			'</Tax>'
				cXmlRet += 			'<Tax>'
				cXmlRet +=    			'<Taxe>CSLL</Taxe>'
				cXmlRet +=    			'<Value>' + CValToChar(SL2->L2_VALCSLL) + '</Value>'
				cXmlRet += 			'</Tax>'
				cXmlRet += 			'<Tax>'
				cXmlRet +=    			'<Taxe>ISS</Taxe>'
				cXmlRet +=    			'<Value>' + CValToChar(SL2->L2_VALISS) + '</Value>'
				cXmlRet += 			'</Tax>'
				cXmlRet += 			'<Tax>'
				cXmlRet +=    			'<Taxe>PIS</Taxe>'
				cXmlRet +=    			'<Value>' + CValToChar(SL2->L2_VALPIS) + '</Value>'
				cXmlRet += 			'</Tax>'
				cXmlRet += 			'<Tax>'
				cXmlRet +=    			'<Taxe>ICM</Taxe>'
				cXmlRet +=    			'<Value>' + CValToChar(SL2->L2_VALICM) + '</Value>'
				cXmlRet +=    			'<CalculationBasis>' + CValToChar(SL2->L2_BASEICM) + '</CalculationBasis>'
				cXmlRet += 			'</Tax>'
				cXmlRet += 		'</ListOfTaxes>'
				cXmlRet += 	'</SaleItem>'
		
				SL2->(dbSkip())
			EndDo

			
	
			cXmlRet += 	'</ListOfSaleItem>'
	
			//Formas de Pagamento da Venda
			cXmlRet += 	'<ListOfSaleCondition>'
	
			SL4->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))
		
			While SL4->(!EOF()) .And. SL4->L4_FILIAL == SL1->L1_FILIAL .And. SL4->L4_NUM == SL1->L1_NUM
				cFormaPg := SL4->L4_FORMA //Armazena Forma de Pagamento
			
				//Verificacao dos parametros opcionais para as Formas de Pagamento Dinheiro, Cheque e Financiado
				//Necessaio pois RM pode ter mais de um codigo para essas formas
				If AllTrim(cFormaPg) == "R$" .And. !Empty(GetNewPar("MV_LJMUDIN", ""))
					cFormaPg := RTrim(GETMV("MV_LJMUDIN"))
				ElseIf AllTrim(cFormaPg) == "CH" .And. !Empty(GetNewPar("MV_LJMUCH", ""))
					cFormaPg := RTrim(GETMV("MV_LJMUCH"))
				ElseIf AllTrim(cFormaPg) == "FI" .And. !Empty(GetNewPar("MV_LJMUFI", ""))
					cFormaPg := RTrim(GETMV("MV_LJMUFI"))
				EndIf
			
				//InternalId da Forma de Pagamento				
				aAux := IntFmPgtExt(/*Empresa*/, /*Filial*/, cFormaPg, /*Versão*/)
			
				If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
					cPgtoInt := aAux[2]
				Else
					cPgtoInt := ""
				EndIf
		
				//Data de Pagamento
				If !Empty(SL4->L4_DATA)
					cDtPagto := SubStr(DToS(SL4->L4_DATA), 1, 4) + '-' + SubStr(DToS(SL4->L4_DATA), 5, 2) + '-' + SubStr(DToS(SL4->L4_DATA), 7, 2)
			
					//Hora de Pagamento
					cDtPagto += "T"
					cDtPagto += RTrim(SL1->L1_HORA)
				EndIf
				
				//Data Tef
				cL4DataTef := ""
			
				If !Empty(SL4->L4_DATATEF)
					cL4DataTef := SubStr(SL4->L4_DATATEF, 1, 4) + '-' + SubStr(SL4->L4_DATATEF, 5, 2) + '-' + SubStr(SL4->L4_DATATEF, 7, 2)
				
					//Hora Tef
					If !Empty(SL4->L4_HORATEF)
						cL4DataTef += "T"
						cL4DataTef += SubStr(SL4->L4_HORATEF, 1, 2) + ":" + SubStr(SL4->L4_HORATEF, 3, 2) + ":" + SubStr(SL4->L4_HORATEF, 5, 2)
					EndIf
				EndIf
		
				//Data cancelamento Tef	
				cL4DatCanc := ""
			
				If !Empty(SL4->L4_DATCANC)
					cL4DatCanc := SubStr(SL4->L4_DATCANC, 7, 4) + '-' + SubStr(SL4->L4_DATCANC, 4, 2) + '-' + SubStr(SL4->L4_DATCANC, 1, 2)
				
					//Hora Cancelamento Tef
					If !Empty(SL4->L4_HORCANC)
						cL4DatCanc += "T"
						cL4DatCanc += SubStr(SL4->L4_HORCANC, 1, 2) + ":" + SubStr(SL4->L4_HORCANC, 3, 2) + ":" + SubStr(SL4->L4_HORCANC, 5, 2)
					EndIf
				EndIf
	
				cXmlRet += 	'<SaleCondition>'
				cXmlRet +=    	'<DateOfPayment>' + cDtPagto + '</DateOfPayment>'
				cXmlRet +=    	'<PaymentValue>' + CValToChar(SL4->L4_VALOR - SL4->L4_TROCO) + '</PaymentValue>'
				cXmlRet +=    	'<PaymentMethodCode>' + RTrim(cFormaPg) + '</PaymentMethodCode>'
				cXmlRet +=    	'<PaymentMethodInternalId>' + cPgtoInt + '</PaymentMethodInternalId>'
		
				//Busca Administradora Financeira, é enviado o Código Externo que está vinculado a Forma de Pagamento
				cXmlRet +=    	'<FinancialManagerCode>' + IIF(!Empty(SL4->L4_ADMINIS),RTrim(Posicione("SAE", 1, xFilial("SAE") + SL4->L4_ADMINIS, "AE_CODEXT")), "") + '</FinancialManagerCode>'
				cXmlRet +=    	'<CardNumber>' + RTrim(SL4->L4_NUMCART) + '</CardNumber>'
				cXmlRet +=    	'<SerieCheck>' + RTrim(SL4->L4_SERCHQ) + '</SerieCheck>'
				cXmlRet +=    	'<BankCheck>' + IIF(AllTrim(cFormaPg) == "CH" .Or. AllTrim(cFormaPg) == AllTrim(GETMV("MV_LJMUCH")), RTrim(SL4->L4_ADMINIS), "") + '</BankCheck>'
				cXmlRet +=    	'<AgencyCheck>' + RTrim(SL4->L4_AGENCIA) + '</AgencyCheck>'
				cXmlRet +=    	'<AccountCheck>' + RTrim(SL4->L4_CONTA) + '</AccountCheck>'
				cXmlRet +=    	'<DocumentOfIdentification>' + RTrim(SL4->L4_RG) + '</DocumentOfIdentification>'
				cXmlRet +=    	'<PhoneNumber>' + RTrim(SL4->L4_TELEFON) + '</PhoneNumber>'
				cXmlRet +=    	'<EftDate>' + cL4DataTef + '</EftDate>'
				cXmlRet +=    	'<EftDocument>' + RTrim(SL4->L4_DOCTEF) + '</EftDocument>'
				cXmlRet +=    	'<EftAutorization>' + RTrim(SL4->L4_AUTORIZ) + '</EftAutorization>'
				cXmlRet +=    	'<EftCancellationDate>' + cL4DatCanc + '</EftCancellationDate>'
				cXmlRet +=    	'<EftCancellationDocument>' + RTrim(SL4->L4_DOCCANC) + '</EftCancellationDocument>'
				cXmlRet +=    	'<EftInstitute>' + RTrim(SL4->L4_INSTITU) + '</EftInstitute>'
				cXmlRet +=    	'<UniqueSerialNumber>' + RTrim(SL4->L4_NSUTEF) + '</UniqueSerialNumber>'
				cXmlRet +=    	'<EftParcel>' + RTrim(SL4->L4_PARCTEF) + '</EftParcel>'
				cXmlRet += 	'</SaleCondition>'
		
				SL4->(dbSkip())
			EndDo
	
			cXmlRet += 	'</ListOfSaleCondition>'
	
			cXmlRet += '</BusinessContent>'

		//Inclusao de Venda cancelada			
		Else
			//Cancelamento de venda nao integrada, quando cancelada antes da finalizacao.
			//Neste caso sao enviadas as informacoes da venda completa pois nao existe
			//a venda original, ou seja, inclusao do cancelamento.
		
			//Posiciona no primeiro item do cupom cancelado
			//SLX->(dbSetOrder(1))
			//SLX->(dbSeek(SLX->LX_FILIAL + SLX->LX_PDV + SLX->LX_CUPOM + SLX->LX_SERIE ))
		
			If SLX->LX_TPCANC == 'A'
				//InternalId do cancelamento de venda
				aAux := IntCancExt(/*Empresa*/, /*Filial*/, SLX->LX_SERIE, SLX->LX_CUPOM, SLX->LX_PDV, /*Versão*/)
				
				If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
					cValInt := aAux[2]
				Else
					cValInt := ""
				EndIf
			
				//Armazena informacoes do cupom	 cancelado	
				cPdv	:= SLX->LX_PDV 	//Pdv do cupom fiscal cancelado
				cDoc	:= SLX->LX_CUPOM //Numero do cumpo fiscal cancelado
				cSerie	:= SLX->LX_SERIE //Serie do cupom fiscal cancelado
			
				//Condicional para a query		
				cWhere := "%"
				cWhere += " LG_FILIAL = '" + xFilial("SLG") + "'"
				cWhere += " AND LG_PDV = '" + SLX->LX_PDV + "'"
				cWhere += " AND D_E_L_E_T_ = ''"
				cWhere += "%"
			
				//Executa a query
				BeginSql alias cAliasTmp
					SELECT
					LG_CODIGO, LG_SERSAT, LG_NFCE
					FROM %table:SLG%
					WHERE %exp:cWhere%
				EndSql
			
				(cAliasTmp)->(dbGoTop()) //Posiciona no inicio do arquivo temporario
			
				//Busca informacoes da Estacao de Trabalho
				If (cAliasTmp)->(!EOF())
					cEstac  := (cAliasTmp)->LG_CODIGO
					cSerSat := (cAliasTmp)->LG_SERSAT

                    Do Case			
                        Case (cAliasTmp)->LG_NFCE == 'T'
                            cKdOfDoc := "NFCE"
                        Case !Empty((cAliasTmp)->LG_SERSAT) 
                            cKdOfDoc := "SATCE"
                        OtherWise
                            cKdOfDoc := "CF"
                    EndCase

				EndIf
			
				//Fecha arquivo temporario
				If (Select(cAliasTmp) > 0)
					(cAliasTmp)->(dbCloseArea())
				EndIf
			
				//InternalId da Estacao de Trabalho
				aAux := IntEstacExt(/*Empresa*/, /*Filial*/, cEstac, /*Versão*/)
			
				If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
					cEstInt := aAux[2]
				Else
					cEstInt := ""
				EndIf
			
				//Data do cancelamento
				If !Empty(SLX->LX_DTMOVTO)
					cEmissao := SubStr(DToS(SLX->LX_DTMOVTO), 1, 4) + '-' + SubStr(DToS(SLX->LX_DTMOVTO), 5, 2) + '-' + SubStr(DToS(SLX->LX_DTMOVTO), 7, 2)
			
					//Hora de Emissao	
					cEmissao += "T"
					cEmissao += RTrim(SLX->LX_HORA)
				EndIf
			
				cOperador := SLX->LX_OPERADO //Operador
							
				//Loop na SLX para armazenar informacoes da venda
				While SLX->(!Eof()) .And. SLX->LX_FILIAL == xFilial("SLX") .And. SLX->LX_PDV == cPdv .And.;
						SLX->LX_CUPOM == cDoc .And. SLX->LX_SERIE == cSerie
				
					If SLX->LX_TPCANC <> "I"
						//Armazena totalizadores da venda cancelada
						nVlrTot  	+= SLX->LX_VALOR
						nValDesTot	+= SLX->LX_DESCON
					EndIf
					
					//Armazena informacoes dos itens cancelados em array
					aAdd(aItensCanc, {	SLX->LX_PRODUTO,;
						SLX->LX_ITEM,;
						SLX->LX_QTDE,;
						SLX->LX_VRUNIT,;
						SLX->LX_VALOR,;
						SLX->LX_DESCON,;
						SLX->LX_TPCANC})
						
						If SLX->(FieldPos("LX_PRCTAB")) > 0			
							aAdd(aItensCanc[nSlx],SLX->LX_PRCTAB)	
						EndIf

						nSlx++
						
					SLX->(dbSkip())
				EndDo
			
				cXmlRet := '<BusinessEvent>'
				cXmlRet +=     '<Entity>RETAILSALES</Entity>'
				cXmlRet +=     '<Event>' + cEvent + '</Event>'
				cXmlRet +=     '<Identification>'
				cXmlRet +=         '<key name="InternalId">' + cValInt + '</key>'
				cXmlRet +=     '</Identification>'
				cXmlRet += '</BusinessEvent>'
			
				cXmlRet += '<BusinessContent>'
			
				//Cabecalho da Venda
				cXmlRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
				cXmlRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
				cXmlRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
				cXmlRet +=    '<InternalId>' + cValInt + '</InternalId>'
				cXmlRet +=    '<TotalPrice>' + CValToChar(nVlrTot) + '</TotalPrice>'
				cXmlRet +=    '<DiscountValue>0</DiscountValue>'
				cXmlRet +=    '<NetPrice>' + CValToChar(nVlrTot) + '</NetPrice>'
				cXmlRet +=    '<IssueDateDocument>' + cEmissao + '</IssueDateDocument>'
				cXmlRet +=    '<DocumentCode>' + RTrim(cDoc) + '</DocumentCode>'
				cXmlRet +=    '<SerieCode>' + RTrim(cSerie) + '</SerieCode>'
				cXmlRet +=    '<GrossPrice>' + CValToChar(nVlrTot) + '</GrossPrice>'
				cXmlRet +=    '<CommodityPrice>' + CValToChar(nVlrTot) + '</CommodityPrice>'
				cXmlRet +=    '<DiscountPercent>0</DiscountPercent>'
				cXmlRet +=    '<OperatorCode>' + RTrim(cOperador) + '</OperatorCode>'
				cXmlRet +=    '<StationCode>' + RTrim(cPdv) + '</StationCode>'
				cXmlRet +=    '<Increase>0</Increase>'
				cXmlRet +=    '<IsCanceled>true</IsCanceled>'
				cXmlRet +=    '<StationSalePointCode>' + RTrim(cEstac) + '</StationSalePointCode>'
				cXmlRet +=    '<StationSalePointInternalId>' + cEstInt + '</StationSalePointInternalId>'
				cXmlRet +=    '<SaleType>' + IIF(Empty(cSerSat), "V", "S") + '</SaleType>'
                cXmlRet +=    '<KindOfDocument>' + cKdOfDoc + '</KindOfDocument>'
			
				//Itens
				cXmlRet += 	'<ListOfSaleItem>'
				For nI := 1 To Len(aItensCanc)
					If aItensCanc[nI][3] > 0
						//InternalId do Produto				
						aAux := IntProExt(/*Empresa*/, /*Filial*/, aItensCanc[nI][1], /*Versão*/)
				
						If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
							cProdInt := aAux[2]
						Else
							cProdInt := ""
						EndIf
					
						//Unidade de Medida
						cUniMed  := RTrim(Posicione("SB1", 1, xFilial("SB1") + aItensCanc[nI][1], "B1_UM"))
					
						//InternalId da Unidade de Medida				
						aAux := IntUndExt(/*Empresa*/, /*Filial*/, cUniMed, /*Versão*/)
					
						If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
							cUMInt := aAux[2]
						Else
							cUMInt := ""
						EndIf
				
						cXmlRet += 	'<SaleItem>'
						cXmlRet +=    	'<InternalId>' + cValInt + '</InternalId>'
						cXmlRet +=    	'<ItemInternalId>' + cProdInt + '</ItemInternalId>'
						cXmlRet +=    	'<ItemCode>' + RTrim(aItensCanc[nI][1]) + '</ItemCode>'
						cXmlRet +=    	'<ItemOrder>' + RTrim(aItensCanc[nI][2]) + '</ItemOrder>'
						cXmlRet +=    	'<Quantity>' + CValToChar(aItensCanc[nI][3]) + '</Quantity>'
						cXmlRet +=    	'<UnitPrice>' + CValToChar(aItensCanc[nI][4]) + '</UnitPrice>'
						cXmlRet +=    	'<ItemPrice>' + CValToChar(aItensCanc[nI][5]) + '</ItemPrice>'
						cXmlRet +=    	'<ItemTablePrice>' +Iif(SLX->(FieldPos("LX_PRCTAB")) > 0, CValToChar(aItensCanc[nI][8]), '') + '</ItemTablePrice>'
						cXmlRet +=    	'<DiscountAmount>0</DiscountAmount>'
						cXmlRet +=    	'<Increase>0</Increase>'
						cXmlRet +=    	'<IsCanceled>' + IIF(aItensCanc[nI][7] == "I", "true", "false") + '</IsCanceled>'
						cXmlRet +=    	'<UnitOfMeasureCode>' + cUniMed + '</UnitOfMeasureCode>'
						cXmlRet +=    	'<UnitOfMeasureInternalId>' + cUMInt + '</UnitOfMeasureInternalId>'
						cXmlRet += 	'</SaleItem>'
					EndIf
				Next nI
			
				cXmlRet += 	'</ListOfSaleItem>'
				cXmlRet += '</BusinessContent>'
			EndIf
		EndIf
	EndIf

	//Restaura areas
	For nI := 1 To Len(aAreas)
		RestArea(aAreas[nI])
	Next nI

	RestArea(aArea)
	cTimeFim := Time()
    LjGrvLog("LOJI701","FIM DO PROCESSO: "+cTimeFim)
    LjGrvLog("LOJI701","TEMPO DE PROCESSAMENTO: "+ ELAPTIME(cTimeIni,cTimeFim))

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntVendExt
Monta o InternalID da Venda de acordo com código passado

@param cEmpresa, Código da empresa (Default cEmpAnt)
@param cFil, Código da Filial (Default cFilAnt)
@param cSerie, Serie do Documento (Serie Fiscal)
@param cDocumento, Código do Documento (Cupom Fiscal)		
@param cPdv, Código do Pdv
@param cVersao, Versao da Mensagem
@return aResult, Array contendo no primeiro parâmetro uma variável logica
		indicando se o registro foi encontrado.
		No segundo parâmetro uma variável string com o InternalID montado.

@author alessandrosantos
@since 03/07/2016
@version P12.1.17				
/*/	
//-------------------------------------------------------------------------------------------------

Function IntVendExt(cEmpresa, cFil, cSerie, cDocto, cPdv, cVersao)
   
	Local aResult := {}

	Default cEmpresa	:= cEmpAnt
	Default cFil     	:= xFilial("SL1")
	Default cSerie	:= SL1->L1_SERIE
	Default cDocto  	:= SL1->L1_DOC
	Default cPdv		:= ""
	Default cVersao	:= "1.000"

	If cVersao $ "1.000|1.001|1.002"
		aAdd(aResult, .T.)
		aAdd(aResult, cEmpresa + "|" + RTrim(cFil) + "|" + RTrim(cSerie) + "|" +;
			RTrim(cDocto) + "|" + RTrim(cPdv))
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, STR0014 + Chr(10) + STR0015 + "1.000|1.001|1.002") //#"Versao nao suportada." ##"As versoes suportadas sao:"
	EndIf
   
Return aResult

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntVendInt
Recebe um InternalID e retorna o código da Venda.

@param cInternalID, InternalID recebido na mensagem
@param cRefer, Produto que enviou a mensagem	
@param cVersao, Versão da mensagem única (Default 1.000)
@return aResult, Array contendo no primeiro parâmetro uma variável logica
		indicando se o registro foi encontrado no de/para.
		No segundo parâmetro uma variável array com o empresa,
		filial, documento, serie, pdv da venda.

@author alessandrosantos
@since 03/07/2016
@version P12.1.17				
/*/	
//-------------------------------------------------------------------------------------------------

Function IntVendInt(cInternalID, cRefer, cVersao)
   
	Local aResult  := {}
	Local aTemp    := {}
	Local cTemp    := ""
	Local cAlias   := "SL1"
	Local cField   := "L1_DOC"

	Default cVersao := "1.000"

	cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
   
	If Empty(cTemp)
		aAdd(aResult, .F.)
		aAdd(aResult, STR0057 + AllTrim(cInternalID) + " " + STR0058) //#"Venda:" ##"nao encontrado no de/para!"
	Else
		If cVersao $ "1.000|1.001|1.002"
			aAdd(aResult, .T.)
			aTemp := Separa(cTemp, "|")
			aAdd(aResult, aTemp)
		Else
			aAdd(aResult, .F.)
			aAdd(aResult, STR0055 + Chr(10) + STR0056 + "1.000|1.001|1.002") //#"Versao nao suportada." ##"As versoes suportadas sao:"
		EndIf
	EndIf
  
Return aResult

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjiVldTag
Recebe um InternalID e retorna o código da Venda.

@param oObjTag, Objeto XML
@param cCpoTag, Campo da tag para verificacao	
@param cTypeTag, Tipo da tag
@return cRet, Valor inserido na tag caso ela seja enviada e diferente de
		vazio, seano retorna um valor padrao de acordo com o tipo da informacao.
		
@author alessandrosantos
@since 03/07/2016
@version P12.1.17				
/*/	
//-------------------------------------------------------------------------------------------------

Function LjiVldTag(oObjTag, cCpoTag, cTypeTag)

	Local cRet 	:= "" //Valor de retorno da funcao
	Local cMsgTag := "" //Mensagem da Tag

	Default cTypeTag := "C"

//Valida se tag foi enviada 
	If XmlChildEx(oObjTag, cCpoTag) <> Nil
		cMsgTag := &("oObjTag:" + cCpoTag + ":Text")
	EndIf

//Valida se a tag nao esta vazia
	If !Empty(cMsgTag)
		If cTypeTag == "C" //Caracter
			cRet := cMsgTag
		ElseIf cTypeTag == "N" //Numerico
			cRet := AllTrim(StrTran(cMsgTag, ",", "."))
		ElseIf cTypeTag == "D" //Data
		//Verifica se as informacoes de horario foram enviadas
			If At("T", cMsgTag) > 0 //Sepera data e horario
				cRet := Substr(cMsgTag, 1, At("T", cMsgTag) - 1)
				cRet := AllTrim(StrTran(cRet, "-", "")) //Armazena data
			Else
				cRet := AllTrim(StrTran(cMsgTag, "-", "")) //Se horario nao enviado, apenas armazena data
			EndIf
		ElseIf cTypeTag == "T" //Horario
		//Verifica se as informacoes de horario foram enviadas
			If At("T", cMsgTag) > 0
				cRet := Substr(cMsgTag, At("T", cMsgTag) + 1, Len(cMsgTag)) //Sepera data de horario e armazena horario
			EndIf
		EndIf
	Else //Se tag = Nil ou vazio, insere valor padrao conforme com tipo da tag
		If cTypeTag == "N" //Numerico
			cRet := "0"
		EndIf
	EndIf

Return cRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjSendEAI
Job para envio de Mensagem Unica, integracao com o adapter EAI: Cupom Fiscal, RPS, 
Cancelamento de Venda e Reducao Z

@param cEmpTrb, Empresa para consulta
@param cFilTrb, Filial para consulta	
@param cInterval, Intervalo para execucao do job
		
@author alessandrosantos
@since 03/07/2016
@version P12.1.17				
/*/	
//-------------------------------------------------------------------------------------------------
Function LjiSendEAI(cEmpTrb, cFilTrb, cInterval)

	Local cFileName 	:= "" //Nome do arquivo de Semaforo
	Local cPdv			:= "" //Pdv do cupom fiscal cancelado
	Local cDoc			:= "" //Numero do cumpo fiscal cancelado
	Local cSerie		:= "" //Serie do cupom fiscal cancelado
	Local cHoraTmp 		:= ""  //Busca horario de criacao do arquivo semaforo
	Local cAliasSLX 	:= GetNextAlias() 
	Local cWhere		:= ""
	Local nX			:= 0  //Contador
	Local nSleep	  	:= 0  //Tempo de intervalo
	Local nHandle		:= 0  //Indica se arquivo foi criado
	Local nDifTime 		:= 0  //Calculo da diferenca entre hora atual e hora arquivo semaforo
	Local aIntegs		:= {}  //Array com arquivos para integracao
	Local aRet			:= {.F.,""} 	//Retorno da integracao
	Local lIntegRm		:= .F. //Parametro integracao RM
	Local lIntegSL1 	:= .F. //Integracao Cupom Fiscal
	Local lIntegSLX 	:= .F. //Integracao Cancelamento Cupom Fiscal
	Local lIntegSFI 	:= .F. //Integracao Reducao Z
	Local lContinua		:= .T. //Flag controle job
    Local oError    := Nil //Objeto que guarda o erro

	Default cEmpTrb		:= "" //Empresa para processamento
	Default cFilTrb		:= "" //Filial para processamento
	Default cInterval 	:= "30000" //Valor Default de intervalo

	If !Empty(cEmpTrb) .And. !Empty(cFilTrb)
		While !KillApp() .And. lContinua
		//Nao consome licenca
			RPCSetType(3)
			RPCSetEnv(cEmpTrb , cFilTrb,,, "LOJ")

            LjGrvLog(" LjiSendEAI ", "Iniciou ambiente: ", {cEmpTrb,cFilTrb,cModulo})   
										
			lIntegRm := GetNewPar("MV_LJRMBAC", .F.) //Verifica integracao RM ativa

            LjGrvLog(" LjiSendEAI ", "Parametro de integração MV_LJRMBAC: ", lIntegRm)   
		
			If lIntegRm
			//Armazena tempo de intervalo
				nSleep := Val(cInterval)
		
				lIntegSL1 	:= FWHasEAI("LOJA701", .T.,, .T.) //Flag integracao de Cupom Fiscal
				lIntegSLX 	:= FWHasEAI("LOJA140", .T.,, .T.) //Flag integracao de Cancelamento de Cupom Fiscal
				lIntegSFI 	:= FWHasEAI("LOJA160", .T.,, .T.) //Flag integracao de Reducao Z
					
				SL1->(dbSetOrder(1)) //L1_FILIAL+L1_NUM
				SLX->(dbSetOrder(1)) //LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM+LX_HORA
				SFI->(dbSetOrder(1)) //FI_FILIAL+DTOS(FI_DTMOVTO)+FI_PDV+FI_NUMREDZ
								
				//Nome do arquivo de Semaforo						
				cFileName := "ljrm"  + cEmpTrb + cFilTrb + ".wrk"
				cFileName := StrTran(cFileName, " ", "") //Remove todos os espacos
			
				//Valida tempo de existencia do arquivo semaforo
				If File(cFileName)
					cHoraTmp := Directory(cFileName)[1,4] //Busca horario de criacao do arquivo semaforo
					nDifTime := SubHoras(Time(), cHoraTmp) //Calcula diferenca entre hora atual e hora arquivo semaforo
				
					//Se diferenca de horarios for negativa significa que arquivo semaforo antigo
					//ou se diferenca maior que o prazo de execucao de 10 minutos, arquivo sera excluido 
					//Esta protecao evitara que job deixe de ser executado caso servico caia e arquivo fique preso
					If nDifTime < 0 .Or. nDifTime > 0.10
						FErase(cFileName)
					EndIf
				EndIf
			
				//Semaforo do controle de execucao da filial
				If !File(cFileName)
					Conout(STR0084 + " " + cFilTrb) //#"Job LjSendEAI Iniciado para a filial"
				
					lContinua := .T. //Flag para iniciar o job
					
					//Cria o arquivo de Semaforo								
					nHandle := FCreate(cFileName)

					If nHandle <= 0
						LjGrvLog("LjiSendEAI", " Não foi possivel criar o arquivo de controle: " + cFileName )
					EndIf 
								
					//Busca vendas para envio
					LjGrvLog("LjiSendEAI", " Busca vendas que serão integradas com RM - INICIO ")
					aIntegs := LjiFindEAI("SL1")
					LjGrvLog("LjiSendEAI", " Busca vendas que serão integradas com RM - FIM ", aIntegs)
					
					For nX := 1 To Len(aIntegs)
						//Posiciona na venda
						If SL1->(dbSeek(aIntegs[nX][1] + aIntegs[nX][2]))
						//Verifica se integracao cupom fiscal esta ativa
							If lIntegSL1
								__lCancVen := .F. //Flag venda cancelada
							
								// -- Marcamos o registro preventivamente como ER antes de enviar para o EAI, com isso evitamos o envio duplicado das vendas.
								SL1->(RecLock("SL1", .F.))
									SL1->L1_SITUA   := "ER"					
								SL1->(MsUnLock())

								//Envia os registro para integracao	
								LjGrvLog("LjiSendEAI", "Parametro de TimeOut do EAI - MV_EAITOUT: ", SuperGetMV("MV_EAITOUT",,600))  
								LjGrvLog("LjiSendEAI", " FwIntegDef --> Antes de enviar  o registro para a integração, SL1->L1_NUM = " + SL1->L1_NUM)						
								aRet := FwIntegDef("LOJA701",,,, "LOJA701")
								LjGrvLog("LjiSendEAI", " FwIntegDef --> Depois de enviar  o registro para a integração, SL1->L1_NUM = " + SL1->L1_NUM,aRet)	
								
								If aRet <> Nil
							
									If Len(aRet) > 0 .And. aRet[1]
										
										SL1->(RecLock("SL1", .F.))
											SL1->L1_SITUA   := "OK"
											SL1->L1_ERGRVBT := ""
										SL1->(MsUnLock())
									
										//Altera status dos cancelamentos
										SLX->(dbSetOrder(1))
										SLX->(dbSeek(SL1->L1_FILIAL + SL1->L1_PDV + SL1->L1_DOC + SL1->L1_SERIE))
								
										While SLX->(!Eof()) .And. SLX->LX_FILIAL == xFilial("SLX") .And. SLX->LX_PDV == SL1->L1_PDV .And.;
												SLX->LX_CUPOM == SL1->L1_DOC .And. SLX->LX_SERIE == SL1->L1_SERIE
									
											//Altera status dos itens cancelados da venda
											If SLX->LX_TPCANC == "I"
												SLX->(RecLock("SLX", .F.))
									
												If ValType(aRet) == "A" .And. Len(aRet) > 0 .And. aRet[1]
													SLX->LX_SITUA = "OK"
												EndIf
										
												SLX->(MsUnLock())
											EndIf
										
											SLX->(dbSkip())
										EndDo

									Else
										LjGrvLog("LjiSendEAI", " Ocorreu um erro no envio da mensagem, verifique com as configurações do EAI Protheus ", aRet[2])
										SL1->(RecLock("SL1", .F.))				
											If ValType(aRet) == "A" .And. Len(aRet) > 0
												SL1->L1_ERGRVBT := AllTrim(aRet[2])
											EndIf
										SL1->(MsUnLock())
									EndIf
								
									IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit(), NIL)

								Else
									LjGrvLog("LjiSendEAI", " Ocorreu na geração do xml de envio ao executar o FwIntegDef->Loja701, retorno FwIntegDef = Nil  ")
								EndIf 
							EndIf
						EndIf
					Next nX
				
					aIntegs := {}
				
				//Busca cancelamentos de vendas para envio				
					aIntegs := LjiFindEAI("SLX")
				
					For nX := 1 To Len(aIntegs)
					
					//Posiciona na venda
						If SLX->(dbSeek(aIntegs[nX][1] + aIntegs[nX][2] + aIntegs[nX][3] + aIntegs[nX][4]))
							
							//Condicional para a query		
							cWhere := "%"
							cWhere += " LX_FILIAL = '" + xFilial("SLX") + "'"				
							cWhere += " AND LX_PDV = '" + SLX->LX_PDV + "'"
							cWhere += " AND LX_CUPOM = '" + SLX->LX_CUPOM + "'"
							cWhere += " AND LX_SERIE = '" + SLX->LX_SERIE + "'"
							cWhere += " AND LX_TPCANC = 'A'"
							cWhere += " AND D_E_L_E_T_ = ''"
							cWhere += "%"
						
							//Executa a query
							BeginSql alias cAliasSLX
								SELECT *
								FROM %table:SLX%
								WHERE %exp:cWhere%
							EndSql
						
							If (cAliasSLX)->(!EOF())
								SLX->(dbSeek((cAliasSLX)->LX_FILIAL + (cAliasSLX)->LX_PDV + (cAliasSLX)->LX_CUPOM + (cAliasSLX)->LX_SERIE ))
								While SLX->(!EOF()) 
									If SLX->LX_TPCANC == "A"
										Exit
									EndIf
									SLX->(dbSkip())
								EndDo
							Endif

							If SLX->LX_TPCANC == "A"
								__lCancVen := .T. //Flag venda cancelada
							Else
								__lCancVen := .F. //Flag venda ativa
							EndIf
							
						//Verifica se integracao cupom fiscal esta ativa
							If lIntegSL1
					
                                //Envia os registro para integracao								
								aRet := FwIntegDef("LOJA701",,,, "LOJA701")

							EndIf
												
						    //Altera status dos registros
							SLX->(dbSetOrder(1))
							SLX->(dbSeek(SLX->LX_FILIAL + SLX->LX_PDV + SLX->LX_CUPOM + SLX->LX_SERIE))
						
						    //Armazena informacoes do cupom	 cancelado	
							cPdv	:= SLX->LX_PDV 	//Pdv do cupom fiscal cancelado
							cDoc	:= SLX->LX_CUPOM //Numero do cumpo fiscal cancelado
							cSerie	:= SLX->LX_SERIE //Serie do cupom fiscal cancelado
						
							While SLX->(!Eof()) .And. SLX->LX_FILIAL == xFilial("SLX") .And. SLX->LX_PDV == cPdv .And.;
									SLX->LX_CUPOM == cDoc .And. SLX->LX_SERIE == cSerie
							
							    //Altera somente cancelamentos de venda
								If SLX->LX_TPCANC $ "A|C|I"
									SLX->(RecLock("SLX", .F.))
							
									If ValType(aRet) == "A" .And. Len(aRet) > 0 .And. aRet[1]
										SLX->LX_SITUA   := "OK"
										SLX->LX_ERGRVBT := ""
									Else
										SLX->LX_SITUA := "ER"
									
										If ValType(aRet) == "A" .And. Len(aRet) > 0
											SLX->LX_ERGRVBT := AllTrim(aRet[2])
										EndIf
									EndIf
								
									SLX->(MsUnLock())
								EndIf
							
								SLX->(dbSkip())
							EndDo
						EndIf
					Next nX
				
				//Busca Reducoes Z para envio
					aIntegs := LjiFindEAI("SFI")
				
					For nX := 1 To Len(aIntegs)
					//Posiciona na venda
						If SFI->(dbSeek(aIntegs[nX][1] + aIntegs[nX][2] + aIntegs[nX][3] + aIntegs[nX][4]))
						//Verifica se integracao cupom fiscal esta ativa
							If lIntegSFI

                            //Envia os registro para integracao							
                            aRet := FwIntegDef("LOJA160",,,, "LOJA160")

							//Altera status do registro
								SFI->(RecLock("SFI", .F.))
							
								If ValType(aRet) == "A" .And. Len(aRet) > 0 .And. aRet[1]
									SFI->FI_SITUA = "00"
									SFI->FI_ERGRVBT := ""
								Else
									SFI->FI_SITUA = "ER"
								
									If ValType(aRet) == "A" .And. Len(aRet) > 0
										SFI->FI_ERGRVBT := AllTrim(aRet[2])
									EndIf
								EndIf
							
								SFI->(MsUnLock())
							EndIf
						EndIf
					Next nX
				
					Sleep(nSleep)
				
					//Apaga arquivo de controle Semaforo
					If File(cFileName)
						FClose(nHandle)
						If FErase(cFileName) == -1
							LjGrvLog("LjiSendEAI", " Não foi possivel excluir arquivo de controle: " + cFileName + " Codigo do erro:" +  STR(fError()))
						EndIf 	
					EndIf
																
					Conout(STR0085 + " " + cFilTrb) //#"Job LjSendEAI executado para a filial"
				EndIf
			EndIf
		
			lContinua := .F. //Altera flag para finalizar o job
		
		//Fecha o ambiente antes de sair da funcao
			RPCClearEnv()
		EndDo
	EndIf

    LjGrvLog(" LjiSendEAI ", "Fim do serviço LjISendEai " + FwTimeStamp(2))

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjiFindEAI
Busca os arquivos para integracao via Mensagem Unica

@param cTabela, Tabela para busca
@return aIntegs, Array com arquivos para integracao
				
@author alessandrosantos
@since 03/07/2016
@version P12.1.17				
/*/	
//-------------------------------------------------------------------------------------------------

Static Function LjiFindEAI(cTabela)

	Local cWhere		:= "" //Condicional da query
	Local cAliasTmp 	:= GetNextAlias() //Alias temporario
	Local aIntegs 	:= {} //Array com arquivos para integracao

//Verifica tabela para buscar informacoes
	If cTabela == "SL1" //Venda
	//Condicional para a query		
		cWhere := "%"
		cWhere += " L1_FILIAL = '" + xFilial("SL1") + "'"
		cWhere += " AND L1_SITUA = 'RX'"
		cWhere += " AND D_E_L_E_T_ = ''"
		cWhere += "%"
	
	//Executa a query
		BeginSql alias cAliasTmp
			SELECT
			L1_FILIAL, L1_NUM
			FROM %table:SL1%
			WHERE %exp:cWhere%
		EndSql
	ElseIf cTabela == "SLX" //Cancelamento de venda
	//Condicional para a query		
		cWhere := "%"
		cWhere += " LX_FILIAL = '" + xFilial("SLX") + "'"
		cWhere += " AND LX_SITUA IN ('','RX')"
		cWhere += " AND LX_TPCANC IN ('A','C','I')"
		cWhere += " AND D_E_L_E_T_ = ''"
		cWhere += "%"
	
	//Executa a query
		BeginSql alias cAliasTmp
			SELECT
			LX_FILIAL, LX_PDV, LX_CUPOM, LX_SERIE
			FROM %table:SLX%
			WHERE %exp:cWhere%
			GROUP BY LX_FILIAL, LX_PDV, LX_CUPOM, LX_SERIE
		EndSql
	ElseIf cTabela == "SFI" //Reducao Z
	//Condicional para a query		
		cWhere := "%"
		cWhere += " FI_FILIAL = '" + xFilial("SFI") + "'"
		cWhere += " AND FI_SITUA = 'RX'"
		cWhere += " AND D_E_L_E_T_ = ''"
		cWhere += "%"
	
	//Executa a query
		BeginSql alias cAliasTmp
			SELECT
			FI_FILIAL, FI_DTMOVTO, FI_PDV, FI_NUMREDZ
			FROM %table:SFI%
			WHERE %exp:cWhere%
		EndSql
	EndIf

	(cAliasTmp)->(dbGoTop()) //Posiciona no inicio do arquivo temporario

//Armazena informacoes
	While (cAliasTmp)->(!EOF())
		If cTabela == "SL1"
			aAdd(aIntegs, {	(cAliasTmp)->L1_FILIAL,;
				(cAliasTmp)->L1_NUM})
		ElseIf cTabela == "SLX"
			aAdd(aIntegs, {	(cAliasTmp)->LX_FILIAL,;
				(cAliasTmp)->LX_PDV,;
				(cAliasTmp)->LX_CUPOM,;
				(cAliasTmp)->LX_SERIE})
		ElseIf cTabela == "SFI"
			aAdd(aIntegs, {	(cAliasTmp)->FI_FILIAL,;
				(cAliasTmp)->FI_DTMOVTO,;
				(cAliasTmp)->FI_PDV,;
				(cAliasTmp)->FI_NUMREDZ})
		EndIf
	
		(cAliasTmp)->(dbSkip())
	EndDo

//Fecha arquivo temporario
	If (Select(cAliasTmp) > 0)
		(cAliasTmp)->(dbCloseArea())
	EndIf

Return aIntegs

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjiVendCanc
Retorna conteudo da flag que controla se venda foi cancelada

@return __lCancVen, Flag de controle venda cancelada para integracao EAI
				
@author alessandrosantos
@since 03/07/2016
@version P12.1.17				
/*/	
//-------------------------------------------------------------------------------------------------

Function LjiVendCanc()
Return __lCancVen

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjGerClif
Gera o Cliente Baseado nas Informacoes do Forncedor

@return __lCancVen, Flag de controle venda cancelada para integracao EAI
				
@author Alan Oliveira
@since 08/11/2017
@version P12.1.17				
/*/	
//-------------------------------------------------------------------------------------------------
Function LjGerClif(_cEmp,_cFil ,_cCGC)

Local aRet 			:= {}
Local aCab 			:= {}
Local nOpcx			:= 3 
Local nCount		:= 0
Local aErroAuto 	:= {}
Local cLogErro		:= ""
Local lMsErroAuto 	:= .F.
Local cCliente		:= "" 	//Codigo do Cliente
Local cCodLoj		:= ""	//Loja  do Cliente
Local lIniPadCod   	:= .F. 	//Verifica se o campo possui Inicializador Padrao
Local lIniPadLoj   	:= .F. 	//Verifica se o campo possui Inicializador Padrao

//STARTA O JOB PARA GERACAO DE CLIENTE
ConOut( Replicate("-",80) )
ConOut( Padc("Startando Job - LjGerClif",80) )
ConOut( Replicate("-",80) )


RPCSetType(3)

//Inicia Ambiente
PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil Modulo "FAT" 


lIniPadCod := Empty(GetSX3Cache("A1_COD"	, "X3_RELACAO"))
lIniPadLoj := Empty(GetSX3Cache("A1_LOJA"	, "X3_RELACAO"))

//Verifica se possui Cliente com o CNPJ do Forncedor, 
//caso contario efetua o cadastro
SA1->(DbSetOrder(3))
If !SA1->(DbSeek(xFilial("SA1")+_cCGC))

	SA2->(DbSetOrder(3))
	SA2->(DbSeek(xFilial("SA2")+_cCGC))
	//Verifica Inicializador do Codigo
	If lIniPadCod
		Lj901CliCod(@cCliente, @cCodLoj)
		aAdd( aCab, { "A1_COD" 		, cCliente			, Nil })
		aAdd( aCab, { "A1_LOJA"		, cCodLoj			, Nil })
    Endif
	//Verifica Inicializador da Loja
	If lIniPadLoj .AND. Empty(cCodLoj)
		aAdd( aCab, { "A1_LOJA"		, "01"			, Nil })
	Endif

    aAdd( aCab, { "A1_NOME"		, SA2->A2_NOME		, Nil })
    aAdd( aCab, { "A1_NREDUZ"	, SA2->A2_NREDUZ	, Nil })
    aAdd( aCab, { "A1_PESSOA"	, SA2->A2_TIPO		, Nil })
    aAdd( aCab, { "A1_TIPO"  	, 'R'				, Nil })
    Aadd( aCab, { "A1_END"		, SA2->A2_END		, Nil })
	aAdd( aCab, { "A1_COMPLEM"	, SA2->A2_COMPLEM	, Nil })
    aAdd( aCab, { "A1_BAIRRO"	, SA2->A2_BAIRRO	, Nil })
    aAdd( aCab, { "A1_EST"		, SA2->A2_EST		, Nil })
    Aadd( aCab, { "A1_PAIS"		, SA2->A2_PAIS		, Nil })
    aAdd( aCab, { "A1_COD_MUN"	, SA2->A2_COD_MUN	, Nil })
	aAdd( aCab, { "A1_MUN"		, SA2->A2_MUN		, Nil })
    aAdd( aCab, { "A1_CEP"		, SA2->A2_CEP		, Nil })
    Aadd( aCab, { "A1_INSCR"	, SA2->A2_INSCR		, Nil })
	Aadd( aCab, { "A1_INSCRM"	, SA2->A2_INSCRM	, Nil })
	Aadd( aCab, { "A1_CGC"		, SA2->A2_CGC		, Nil })
	Aadd( aCab, { "A1_PFISICA"	, SA2->A2_PFISICA	, Nil })
	aAdd( aCab, { "A1_CXPOSTA"	, SA2->A2_CX_POST	, Nil })
    aAdd( aCab, { "A1_EMAIL"	, SA2->A2_EMAIL		, Nil })
    aAdd( aCab, { "A1_TEL"		, SA2->A2_TEL		, Nil })
	aAdd( aCab, { "A1_DDD"		, SA2->A2_DDD		, Nil })
	aAdd( aCab, { "A1_DDI"		, SA2->A2_DDI		, Nil })
	Aadd( aCab, { "A1_FAX"		, SA2->A2_FAX		, Nil })
    aAdd( aCab, { "A1_HPAGE"	, SA2->A2_HPAGE		, Nil })
    aAdd( aCab, { "A1_CONTATO"	, SA2->A2_CONTATO	, Nil })
    aAdd( aCab, { "A1_MSBLQL"	, '2'				, Nil })
    aAdd( aCab, { "A1_DTNASC"	, SA2->A2_DTNASC 	, Nil })
   
	SetFunName('MATA030')
    MSExecAuto( { |x, y| MATA030( x, y ) }, aCab, nOpcx )
    
    If  lMsErroAuto 
    	aErroAuto := GetAutoGRLog()
         For nCount := 1 To Len(aErroAuto)
            cLogErro += _NoTags(aErroAuto[nCount])
          Next nCount
     
         aRet := {.F.,"","",cLogErro}
     Else
     	If Empty(SA1->A1_COD)
     		cLogErro := STR0123 //"Erro no cadastro do cliente"
     		aRet := {.F.,"","",cLogErro}
     	Else
     		aRet := {.T.,SA1->A1_COD,SA1->A1_LOJA,""}
     	EndIf
     Endif
Else
	aRet := {.T.,SA1->A1_COD,SA1->A1_LOJA,""}
Endif

ConOut( Replicate("-",80) )
ConOut( Padc("Finalizando Job - LjGerClif",80) )
ConOut( Replicate("-",80) )

//Finaliza Ambiente
RESET ENVIRONMENT


Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjiSerSLG
Retorna a Serie na SLG (LG_SERIE).

@return cRet, Serie na SLG (LG_SERIE)
				
@author Alberto Deviciente
@since 25/05/2018
@version P12.1.17				
/*/	
//-------------------------------------------------------------------------------------------------
Function LjiSerSLG(cSerie,cSerieSat)
Local cRet 		:= ""
Local cAliasQry	:= GetNextAlias()
Local cWhere	:= "" 

cWhere	:= "%"
cWhere	+= "LG_SERSAT = '" + cSerieSat + "'"
cWhere	+= "%"

BeginSql alias cAliasQry
	SELECT	 LG_SERIE		
	FROM %table:SLG% SLG
	WHERE	LG_FILIAL = %xfilial:SLG%	AND
			%exp:cWhere% 			    AND				
			SLG.%notDel%
EndSql

If (cAliasQry)->(!EoF()) .And. !Empty((cAliasQry)->LG_SERIE)
	cRet := (cAliasQry)->LG_SERIE
Else
	cRet := cSerie
EndIf

(cAliasQry)->(DbCloseArea())

Return cRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} lj701IdLj
Efetua Gravação da Identificação de Loja
(LOJA080)

@return 
				
@author Alan S. R. Oliveira
@since 15/06/2018
@version P12.1.17				
/*/	
//-------------------------------------------------------------------------------------------------
Function lj701IdLj(cEmpAnt,cFilRes)

Local oModel   := Nil
Local aRet     := {}
	
cIdLoja := GETSX8NUM("SLJ","LJ_CODIGO")                                                                                                    
	
oModel := FWLoadModel("LOJA080")
	
oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()
oModel:SetValue("SLJMASTER","LJ_CODIGO" ,cIdLoja) //Codigo da Identificação de Loja
oModel:SetValue("SLJMASTER","LJ_NOME"	  ,cFilRes)   //Nome de Loja
oModel:SetValue("SLJMASTER","LJ_RPCEMP" ,cEmpAnt)//Código da Empresa
oModel:SetValue("SLJMASTER","LJ_RPCFIL" ,cFilRes)//Código da Filial
oModel:SetValue("SLJMASTER","LJ_RESERVA","1")	   //Reserva 1-Sim ou 2-Nao
oModel:SetValue("SLJMASTER","LJ_DIASRES",1)	   //Dias de validade da Reserva.

If oModel:VldData()
	oModel:CommitData()
	ConfirmSx8()
	aRet:= {.T.,cIdLoja}
Else
	RollBackSx8()
	aRet:= {.F.,VarInfo("Erro ao Incluir a Loja",oModel:GetErrorMessage())}
EndIf

oModel:DeActivate()
oModel:Destroy()

Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Lj701ITran
Retorna o De Para da Transportadora dependendo do Tipo.
Se for envio retorna o InternoId Protheus, no recebimento retorna o código do Protheus

@param cMarca	   	- Marca que enviou a mensagem
@param nTypeTrans  	- Envio ou Recebimento
@param cCodigo	   	- Código do Protheus
@param cValExt		- InternalId do outro Sistema

@return aRet	   - {Logico	,;	- Definindo se encontrou o registro
@return aRet	   	  Caractere}	- Envio retorna o InternoId Protheus, Recebimento retorna o código do Protheus
				
@author  Rafael Tenorio da Costa
@since 	 19/10/2018
@version 1.0				
/*/	
//-------------------------------------------------------------------------------------------------
Function Lj701ITran(cMarca, nTypeTrans, cCodigo, cValExt)

	Local aArea	   := GetArea()
	Local aAreaSA4 := SA4->( GetArea() )
	Local aRet	   := {.T., ""}
	
	Default cMarca	:= "PROTHEUS"
	Default cCodigo	:= ""
	Default cValExt	:= ""

	//Envia
	If nTypeTrans == TRANS_SEND

		If !Empty(cCodigo)	
			aRet[1] := .T.
			aRet[2] := cEmpAnt + "|" + xFilial("SA4") + "|" + RTrim(cCodigo)
		EndIf	
		
	//Recebe		
	Else

		//Retorna o codigo da Transportadora a partir do De Para
		aRet := LjMuDePaCb(cMarca , cCodigo , cValExt, "SA4", "A4_COD",;
						STR0132, .F.		)	//"Transportadora"
	EndIf
	
	RestArea(aAreaSA4)
	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjI701Esta
Retorna o De\Para da Estação.
Fetorna o código do Protheus
Cadastra a estação AUTOMATICO caso seja necessário.

@param cMarca	   	- Marca que enviou a mensagem
@param cCodigo	   	- Código do Protheus
@param cValExt		- InternalId do outro Sistema
@param cCodPdv		- Código do Pdv do outro Sistema

@return aRet	   - {Logico	,;	- Definindo se encontrou o registro
@return aRet	   	  Caractere}	- Envio retorna o InternoId Protheus, Recebimento retorna o código do Protheus
				
@author  Rafael Tenorio da Costa
@since 	 21/11/2018
@version 1.0				
/*/	
//-------------------------------------------------------------------------------------------------
Function LjI701Esta(cMarca, cCodigo, cValExt, cCodPdv)

	Local aArea	   	:= GetArea()
	Local aAreaSLG 	:= SLG->( GetArea() )
	Local aRet	   	:= {.T., ""}
	Local aEstacao	:= {}
	Local aErro		:= {}
	Local cErro		:= ""
	Local nCont		:= 0
	Local cValInt	:= ""

	Private lMsErroAuto	   := .F.	//Cria a variavel do retorno da rotina automatica
	Private lAutoErrNoFile := .T.	//Habilita a gravacao do erro da rotina automatica
	Private lMsHelpAuto    := .T.
	
	Default cMarca	:= "PROTHEUS"
	Default cCodigo	:= ""
	Default cValExt := ""

	If AllTrim( Upper(cValExt) ) == "AUTOMATICO"
		cCodigo := ""							//Força a atulização do internalId
		cCodPdv := ""							//Força a atulização do internalId
		cValExt := AllTrim( Upper(cValExt) )	//Se for automático deixa sempre maiusculo para ajudar no De\Para
	EndIf

	//Retorna o codigo da estação a partir do De Para
	aRet := LjMuDePaCb(cMarca , cCodigo	, cValExt, "SLG", "LG_CODIGO",;
					   STR0133, .T.		)	//"Estação"

	//não encontrou o De\Para
	If !aRet[1]

		//Retorna o codigo da estação a partir do código do PDV
		//Esta regra teve que ser mantida por causa do legado (o codigo da estação estava vindo no campo de pdv)
		aRet := LjMuDePaCb(cMarca , cCodPdv	, cValExt, "SLG", "LG_CODIGO",;
						   STR0133, .T.		)	//"Estação"

		//Não encontrou o De\Para e é para cadastrar a Estação
		If !aRet[1] .And. cValExt == "AUTOMATICO"

			//Limpa as variaveis de controle
			aRet[1] := .T.
			aRet[2] := ""

			Aadd( aEstacao, {"LG_CODIGO", "AUT"	  , Nil} )
			Aadd( aEstacao, {"LG_NOME"	, cValExt , Nil} )
			Aadd( aEstacao, {"LG_SERIE"	, "AUT"	  , Nil} )
			Aadd( aEstacao, {"LG_PDV"	, "AUT"   , Nil} )

			Begin Transaction

				//Cadastra a estação AUTOMATICA
				MSExecAuto({|a,b,c,d| LOJA121(a,b,c,d)}, /*cFolder*/, /*lCallCenter*/, aEstacao, MODEL_OPERATION_INSERT)
				
				If !lMsErroAuto

					cValInt := cEmpAnt + "|" + RTrim( xFilial("SLG") ) + "|AUT"

					//Cadastra o De\Para da estação
					If CfgA070Mnt(cMarca, "SLG", "LG_CODIGO", cEmpAnt + "|" +RTrim( xFilial("SLG") )+"|"+cValExt, cValInt, /*lDelete*/, /*nOrdem*/, /*cTable*/, /*cOwnerMsg*/)
						aRet[1] := .T.
						aRet[2] := "AUT"
					Else
						aRet[1] := .F.
						aRet[2] := I18n(STR0134, {STR0133})	//"Não foi possível efetuar o cadastro do De\Para da(o) #1 AUTOMATICO."		//"Estação"
					EndIf

				//Carrega retorno de erro da execauto
				Else
					aErro := GetAutoGRLog()

					For nCont := 1 To Len(aErro)
						cErro += aErro[nCont] + CRLF
					Next nCont

					aRet[1] := .F.
					aRet[2] := cErro
				EndIf

			End Transaction

		EndIf

	EndIf

	FwFreeObj(aEstacao)
	FwFreeObj(aErro)

	RestArea(aAreaSLG)
	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjI701Oper
Retorna o De Para do Operador\Caixa .
Fetorna o código do Protheus
Cadastra o Operador\Caixa AUTOMATICO caso seja necessário.

@param cMarca	   	- Marca que enviou a mensagem
@param cCodigo	   	- Código do Protheus
@param cValExt		- InternalId do outro Sistema

@return aRet	   - {Logico	,;	- Definindo se encontrou o registro
@return aRet	   	  Caractere}	- Envio retorna o InternoId Protheus, Recebimento retorna o código do Protheus
				
@author  Rafael Tenorio da Costa
@since 	 26/11/2018
@version 1.0				
/*/	
//-------------------------------------------------------------------------------------------------
Function LjI701Oper(cMarca, cCodigo, cValExt)

	Local aArea	   	:= GetArea()
	Local aAreaSLF 	:= SLF->( GetArea() )
	Local aRet	   	:= {.T., ""}
	Local nCont		:= 0
	Local cValInt	:= ""
	Local cOperador	:= "01"		//Inicia com 01 para realizar o soma
	Local cOperName	:= ""
	Local cAcesUser	:= ""
	Local aAcesso	:= {}
	Local nDescPer 	:= 99.99
	Local nDescVal 	:= 9999.99

	Private aInLoja := {}		//Variavel necessaria para manipulacao dos caixas
	
	Default cMarca	:= "PROTHEUS"
	Default cCodigo	:= ""
	Default cValExt := ""

	If AllTrim( Upper(cValExt) ) == "AUTOMATICO"
		cCodigo := ""							//Força a atulização do internalId
		cValExt := AllTrim( Upper(cValExt) )	//Se for automático deixa sempre maiusculo para ajudar no De\Para
	EndIf

	//Retorna o codigo do Operador a partir do De Para
	aRet := LjMuDePaCb(cMarca , cCodigo	, cValExt, "SLF", "LF_COD",;
					   STR0135, .T.		)	//"Operador"

	//Não encontrou o De\Para e é para cadastrar o Operador
	If !aRet[1] .And. cValExt == "AUTOMATICO"

		//Limpa as variaveis de controle
		aRet[1] := .T.
		aRet[2] := ""

		Begin Transaction

			cOperName := cValExt

			//Configuracao do Caixa
			If !LjConfCaixa(cOperName, 1, /*cOldUser*/ , .F., @cOperador)	//1 = Busca nome do caixa
				aRet[1] := .F.
				aRet[2] := I18n(STR0136, {"LjConfCaixa"})	//"Não foi possível configurar o operador AUTOMATICO. (#1)"
			Else

				//Inclui o caixa
				aRet := LjAtuCaixa(cOperName   , /*cModImp*/ , /*cModGav*/ , /*cModCmc7*/, /*cUsaTef*/	,;
								   cOperador   , /*cOldUser*/, /*cAgencia*/, /*cConta*/  , .F.			,;
						   		   /*cNomeRed*/)
				
				If aRet[1]
				
					cAcesUser := SLF->LF_ACESSO
					cValInt   := cEmpAnt + "|" + RTrim( xFilial("SLF") ) + "|" + cOperador

					//Cadastra o De\Para do operador
					If !CfgA070Mnt(cMarca, "SLF", "LF_COD", cEmpAnt + "|" +RTrim( xFilial("SLF") )+"|"+cValExt, cValInt)
						aRet[1] := .F.
						aRet[2] := I18n(STR0134, {STR0135})	//"Não foi possível efetuar o cadastro do De\Para da(o) #1 AUTOMATICO."		//"Operador"
					EndIf
				EndIf
			EndIf

			If aRet[1]
			
				//Realiza alteracao para gravar permissoes especificas										
				aAcesso := Lj120Acesso(aAcesso, cAcesUser ,.F.)
				
				//Libera acesso a todos as permissões
				For nCont:=1 To Len(aAcesso)
					aAcesso[nCont][1] := "S"
				Next nCont

				//Grava o perfil e o acesso do caixa
				If Lj120Ok( aAcesso , .F.			,	.F.		  ,	.F.		 ,;
							.F.	 	, .F.			, cOperador	  ,	nDescPer ,;
							nDescVal, .F.			,	"1"		  ,	""		 ,;
							2		, /*lIntSiac*/	, /*cOpSiac*/ ,	nDescPer ,;
							nDescVal, /*aSang*/	)

					aRet[1] := .T.
					aRet[2] := cOperador
				Else

					aRet[1] := .F.
					aRet[2] := I18n(STR0136, {"Lj120Ok"})	//"Não foi possível configurar o operador AUTOMATICO. (#1)"
				Endif			
			EndIf					
			
		End Transaction
	EndIf

	RestArea(aAreaSLF)
	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjPegaIt
Função responsavel por devolver um numero de item valido, em caso de intens cancelados os demais itens deverão ser reorganizados para o envio

@param cItem, Caracter, codigo atual do item
@param aItens, array, array com os itens que foram processados.

@return Caracter, Numero de item atualizado
				
@author  Lucas Novais (lnovias@)		
@since 	 13/08/2021
@version 1.0				
/*/	
//-------------------------------------------------------------------------------------------------

Static Function LjPegaIt(cItem, aItens)

Local nItem := STBPegaIT(cItem)

If aScan(aItens,nItem) > 0
	nItem++
	While aScan(aItens,nItem) > 0 
		nItem++
	EndDo 
EndIf 

aAdd(aItens,nItem)

Return STBPegaIT(nItem)
