#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJI701.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TBICONN.CH" 
#INCLUDE "TBICODE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJI701O
Funcao de integracao com o adapter EAI para recebimento e
envio de informações de Vendas/Pedido Varejo (retailSales)
utilizando o conceito de mensagem unica com Objeto EAI. 
@type function
@param Caracter, cMsgRet, Variavel com conteudo para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)

@author rafael.pessoa
@version P12
@since 01/10/2018
@return Array, Array contendo o resultado da execucao e a mensagem  de retorno.
		aRet[1] - (boolean) Indica o resultado da execução da função
		aRet[2] - (caracter) Mensagem para envio
/*/
//-------------------------------------------------------------------
Function LOJI701O(oEAIObEt, nTypeTrans, cTypeMessage)
	Local lRet 		:= .T.				//Indica o resultado da execução da função
	Local cRet		:= ''				//Retorno que será enviado pela função
	Local aRet		:= {.T.,""} 		//Array de retorno da execucao da versao
         
	Default nTypeTrans		:= 3
	Default cTypeMessage	:= ""

	LjGrvLog("LOJI701O","ID_INICIO - InternalId: " + IIF(oEAIObEt:getPropValue("InternalId") != Nil,oEAIObEt:getPropValue("InternalId"),""))
	LjGrvLog("LOJI701O","Objeto oEAIObEt",oEAIObEt)

	If ( nTypeTrans == TRANS_RECEIVE )

		If ( cTypeMessage == EAI_MESSAGE_BUSINESS ) .Or. ( cTypeMessage == EAI_MESSAGE_RESPONSE )

			If !Empty(oEAIObEt:getHeaderValue("Version"))

				cVersao := StrTokArr(oEAIObEt:getHeaderValue("Version"), ".")[1]
				  
				If cVersao == "2"
					LjGrvLog("LOJI701O","Antes de entrar na funcao v2000 - InternalId: " + IIF(oEAIObEt:getPropValue("InternalId") != Nil,oEAIObEt:getPropValue("InternalId"),""))
					aRet := v2000(oEAIObEt, nTypeTrans, cTypeMessage )
					LjGrvLog("LOJI701O","Depois de sair da funcao v2000 - InternalId: " + IIF(oEAIObEt:getPropValue("InternalId") != Nil,oEAIObEt:getPropValue("InternalId"),""))
				Else
					lRet    := .F.					
					cRet := STR0001 //#"A versao da mensagem informada nao foi implementada!"
					aRet := { lRet , cRet }
				EndIf
			Else
				lRet := .F.
				cRet := STR0002 //#"Versao da mensagem nao informada!"
				aRet := { lRet , cRet }
			EndIf			
	 
		ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )		
			cRet := "2.000|2.001|2.002|2.003|2.004|2.005|2.006|2.007|2.008"
			aRet := { lRet , cRet }
			Return {aRet[1], aRet[2],"RETAILSALES","JSON"}
		EndIf								
                                    	
	ElseIf ( nTypeTrans == TRANS_SEND )

		cVersao := StrTokArr(RTrim(PmsMsgUVer('RETAILSALES','LOJA701')), ".")[1]

		//Faz chamada da versão especifica   
		If cVersao == "2"
			aRet := v2000(oEAIObEt, nTypeTrans, cTypeMessage)
		Else
			cRet := STR0001 //#"A versao da mensagem informada nao foi implementada!"
			aRet := { lRet , cRet }
		EndIf
	EndIf

	LjGrvLog("LOJI701O","ID_FIM - InternalId: " + IIF(oEAIObEt:getPropValue("InternalId") != Nil,oEAIObEt:getPropValue("InternalId"),""))
	
Return {aRet[1], aRet[2], "RETAILSALES"}

//-------------------------------------------------------------------
/*/{Protheus.doc} v2000
 Funcao de integracao com o adapter EAI para recebimento e envio de informações
  de Vendas/Pedido Varejo (retailSales) utilizando o conceito de mensagem unica para Versão 2.000
@type function
@param Objeto, oEAIObEt, Objeto EAI para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)

@author rafael.pessoa
@version P12
@since 01/10/2018
@return Array, Array contendo o resultado da execucao e a mensagem de retorno.
		aRet[1] - (boolean) Indica o resultado da execução da função
		aRet[2] - (Objeto) Indica o Obejto com os retornos da função
		aRet[3] - (caracter) Mensagem para envio
/*/
//-------------------------------------------------------------------
Static Function v2000( oEAIObEt, nTypeTrans, cTypeMessage )

Local cSerie		:= "" //Serie do cupom fiscal
Local cDoc			:= "" //Numero do cumpo fiscal ajustado
Local cTimeEmis		:= "" //Hora de emissao do cupom fiscal
Local cMarca		:= "" //Armazena a Marca 
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
Local cItem			:= "  " //Item de Venda
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
Local nFrete        := 0 //Valor Total de Frete   
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
Local lRps 			:= .F. //Flag RPS
Local lNfce			:= .F. //Flag NFCe
Local lTef			:= .F. //Flag Tef
Local lCupCancel 	:= .F. //Flag de Venda cancelada
Local lItCancel 	:= .F. //Flag de Item cancelado
Local lCancVen   	:= .F. //Flag cancelamento de venda
Local dDataPagto	:= dDataBase //Data de Pagamento
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
Local nVlMercTot	:= 0	//Valor Total das Mercadorias
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
Local nFormaId 		:= 0 //Numero Forma de Pagamento
Local cChaveNFCe 	:= "" //Chave NFCe
Local cProtoNFCe 	:= "" //Protocolo NFCe
Local cRateio 		:= "" //Rateio de servicos
Local cCCusto		:= SuperGetMv("MV_HTLCCRT",, "") //Centro de Custo
Local cEntidade 	:= "" //Entidade
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
Local cDtUlmes		:= SuperGetMV("MV_ULMES")
Local cDtDblqMov	:= SuperGetMV("MV_DBLQMOV")
Local ofwEAIObj     := FWEAIobj():NEW()	// Objeto EAI
Local lRet			:= .T.
Local cMsgRet		:= "" 	//Mensagem de Retorno
Local oListFinNat 	:= Nil
Local oListCost   	:= Nil
Local oCabImp   	:= Nil
Local oItens		:= Nil
Local oItImp   		:= Nil
Local oPgtos   		:= Nil
Local cCondpg		:= "" 		//Condição de Pagamento
Local cTransp		:= ""		//Código da transportadora
Local cTranspItem   := ""       //Código da transportadora item
Local lCalcImp		:= .F. 		//Varíavel que verifica se os impostos serão calculados pelo protheus
Local cAuxOpeCod	:= ""		//Conteudo da TAG "OperationCode"		
Local nPosNsu	 	:= 0 		//Posicao campo NSU
Local nPosAutoriz 	:= 0 		//Posicao campo Autoriz
Local nPosDescon	:= 0 		//Posição do campo Desconto Total Cabeçalho
Local nPosItem		:= 0		//Posicao do item
Local nPosDescPro	:= 0 		//Posicao do campo Desconto Proporcional
Local nPosQuant		:= 0  		//Posição do campo Quantidade
Local nPosVlrUni	:= 0  		//Posição do campo Valor Unitário
Local nPosVlrIte	:= 0  		//Posição do campo Valor do Item
Local nPosBasIcm	:= 0  		//Posição do campo Base de icms do item
Local cAux          := ""
Local aTamNsu       := { TamSx3("L1_NSUTEF")[1], TamSx3("L4_NSUTEF")[1], TamSx3("LQ_NSUTEF")[1], TamSx3("E1_NSUTEF")[1] }
Local nVlrPag       := 0
Local nVlrPagTot    := 0
Local aValidacoes	:= {} //Array para receber o retorno das validações
Local cMV_LJTPFRE	:= SuperGetMV("MV_LJTPFRE", NIL, "F")			// TES utilizado para a geracao do Pedido de Venda
Local lExecParFRE   := Substr(cMV_LJTPFRE,1, 1) == "&"             	// Controla se pode macro-executar o parametro cMV_LJTPFRE
Local cTpFrete      := "S"
Local xRet  
Local cNumRes		:= "" //Guarda o numero de reserva ja utilizado
Local lLjI701O1		:= ExistBlock("LJI701O1") //Verifica se existe o PE LJI701O1 que faz a manipulação no objeto de produtos oItens
Local nEcFlag		:= 0 //Pocisao do campo L1_ECFLAG no array aCab
Local nPosValFre    := 0 //Pocisao do campo LR_VALFRE no array aItem
Local nValDifPed    := 0 //Guarda o valor de diferença entre o recebido no json para o calculado
Local nPosVlrMer    := 0 //Pocisao do campo L1_VALMERC no array aCab
Local nPosValIpi    := 0 //Pocisao do campo L1_VALIPI no array aCab
Local nPosFrete     := 0 //Pocisao do campo L1_FRETE no array aCab
Local nPosPrcTab    := 0 //Pocisao do campo LR_PRCTAB no array aItem
Local nValDesp      := 0 //Valor da despesa no Cabeçalho 
Local nQtdeParc		:= 0 //Qtde de parcelas de determinada forma de pagto
Local cPresen       := "" //Codigo para atender a Nota Técnica 2020.006 - tag indpres
Local cInterm       := "" //Codigo do intermediario da compra Nota Técnica 2020.006
Local lLjI701O3		:= ExistBlock("LJI701O3") //Verifica se existe o PE LJI701O3 que faz a manipulação no objeto EAI
Local aLj7CalcPgt	:= {}
Local cJsonRet		:= "" // -- String Json de retorno em caso de ERRO.
Local aDoc			:= {.F.,Array(5)} // -- Em caso de alteração guardo os dados do De/Para existente
Local cC0FilRes		:= "" // -- Filial da C0 de uma reserva

Private lMsHelpAuto 	:= .T. //Variavel de controle interno do ExecAuto
Private lMsErroAuto 	:= .F. //Variavel que informa a ocorrência de erros no ExecAuto
Private lAutoErrNoFile 	:= .T. //força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário
Private Inclui 			:= .T. //Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
Private Altera 			:= .F. //Variavel necessária para o ExecAuto identificar que se trata de uma inclusão


Default oEAIObEt	 := Nil 
Default nTypeTrans 	 := 0 
Default cTypeMessage := "" 

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
If nTypeTrans == TRANS_RECEIVE .And. cTypeMessage == EAI_MESSAGE_BUSINESS .And. ValType( oEAIObEt ) == 'O'

	//Ponto de entrada para manipular os valores do objeto Eai
	If lLjI701O3
		LjGrvLog("LOJI701","Antes de executar o PE LJI701O3",oEAIObEt)
		oEAIObEt := ExecBlock( "LJI701O3", .F., .F., {oEAIObEt} )
		LjGrvLog("LOJI701","Depois que executou o PE LJI701O3",oEAIObEt)
		If ValType(oEAIObEt) <> "O"
			lRet 	:= .F.
			cMsgRet := "Erro no retorno do ponto de entrada LJI701O3, o retorno não foi do tipo objeto."
			LjGrvLog("LOJI701", cMsgRet)
		EndIf
	EndIf

    cUUID := AllTrim( oEAIObEt:getHeaderValue("UUID") )
    cUUID := Padr(cUUID, TamSx3("L1_UMOV")[1])

	LjGrvLog("LOJI701", "INICIO RECEBIMENTO: " + Time())
	LjGrvLog("LOJI701", "UUID: " + cUUID)

	If Empty(SM0->M0_ESTCOB)	//Valida Estado de Cobranca da filial
		lRet    := .F.
		cMsgRet := STR0059 + Chr(10) + STR0060 //#"Foi detectado que o campo referente ao estado de cobranca(M0_ESTCOB) nao esta configurado." ##"Efetue a inclusao no cadastro de filiais no Protheus."
        LjGrvLog("LOJI701", cMsgRet)
	EndIf

	If lRet		
		If oEAIObEt:getHeaderValue("ProductName") != Nil //Marca
			cMarca := oEAIObEt:getHeaderValue("ProductName")
		EndIf
	
		If Empty(cMarca)
			lRet    := .F.
			cMsgRet := STR0004 //#"Marca nao integrada ao Protheus, verificar a marca da integracao"
            LjGrvLog("LOJI701", cMsgRet)
		EndIf
	EndIf
	
	If lRet
		If AllTrim(Upper( LjiOVldTag(oEAIObEt, "Event") )) == "DELETE" 
			lRet    := .F.
			cMsgRet := STR0081 //#"Evento incorreto, para exclusao utilize a integracao de Cancelamento de Venda."
            LjGrvLog("LOJI701", cMsgRet)
		ElseIf Empty(LjiOVldTag(oEAIObEt, "Event"))
			lRet    := .F.
			cMsgRet := STR0082 //#"Evento nao informado!"
            LjGrvLog("LOJI701", cMsgRet)
		EndIf
	EndIf
	
	If lRet

		cIdExt := LjiOVldTag(oEAIObEt, "InternalId") //Armazena chave externa. InternalId
		
		If Empty(cIdExt)
			lRet	 := .F.
			cMsgRet := STR0021 //#"Campo obrigatorio nao informado: Id Interno, verifique a tag: InternalId."
            LjGrvLog("LOJI701", cMsgRet)
		EndIf
	EndIf

	If lRet
		//Verifica evento inclusao ou alteracao
		aAux := IntVendInt(cIdExt, cMarca)
		
		//Se encontrou o cupom no de-para
		If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
			nOpcX := 2 //Alteracao
			aDoc := AClone(aAux)
		Else
			nOpcX := 3 //Inclusao
		EndIf
							
		//Evento Inclusao
		If 	nOpcX == 3

			lCancVen := LjiOVldTag(oEAIObEt, "IsCanceled", "L")
					
			//Para venda cancelada, altera controle de orcamento para que venda seja cancelada apos ser processada
			If lCancVen
				cSituaOrc := "E"
			EndIf
			
            //Numero do movimento
			cNumMov := AllTrim( LjiOVldTag(oEAIObEt, "MovementNumber") )
            If !Empty(cNumMov)
                cNumMov := StrZero( Val(cNumMov), TamSx3("L1_NUMMOV")[1] )
            EndIf

            //Tipo do documento
			cTpVenda := AllTrim( Upper( LjiOVldTag(oEAIObEt, "KindOfDocument") ) ) 

            Do Case

                Case Empty(cTpVenda)
                    lCalcImp := .T.

                Case cTpVenda == "NFCE"
                    lNfce := .T.

                Case cTpVenda == "NFM"
                    lNfm := .T.

                Case cTpVenda == "NFE"
                    lNfe     := .T.
                    cTpVenda := "SPED"  //Quando venda tem como origem a integração a rotina LjGrvSF2() considera a especie do campo L1_ESPECIE, no Protheus a especie para para NF-e é "SPED"

                Case cTpVenda == "RPS"
                    lRps := .T.
                
                Case cTpVenda == "SATCE"
                    lSat := .T.

            End Case
        
            //Nota Fiscal Manual, NFe ou RPS, obrigatorio informar Serie
            If lNfm .Or. lNfe .Or. lRps

                //Armazena a Serie informada na integracao
                cSerie := Padr( LjiOVldTag(oEAIObEt, "SerieCode"), TamSx3("L1_SERIE")[1] )
            
                //Validacao da Serie
                If Empty(cSerie)
                    lRet    := .F.
                    cMsgRet := STR0076  //"Serie nao informada na integracao, informacao obrigatoria para Nota Manual ou NFE, verifique a tag: SerieCode"
                    LjGrvLog("LOJI701", cMsgRet)
                EndIf
            EndIf
	
			If lRet 
				If lNfe .And.  Empty( LjiOVldTag(oEAIObEt, "KeyAcessNFe") ) //Gera Numeracao quando nao existir Chave
					If AllTrim(cTipoNF) == "3"
						cDoc := MA461NumNf(.T., cSerie)
					Else
						cDoc := NxtSX5Nota(cSerie, .T., cTipoNF)
					EndIf
				Else
					cDoc := Padr(  LjiOVldTag(oEAIObEt, "DocumentCode")  , TamSx3("L1_DOC")[1])
				EndIf
			
				//Validacao da Doc							
				If Empty(cDoc)
					lRet 	 := .F.
					cMsgRet := STR0006 //#"Cupom nao informado, verificar a tag: DocumentCode"
                    LjGrvLog("LOJI701", cMsgRet)
				Else
					If Val(cDoc) == 0
						lRet	:= .F.
						cMsgRet := STR0126 //#"Número do cupom inválido, , verificar a tag: DocumentCode" 
                        LjGrvLog("LOJI701", cMsgRet)
					ElseIf Len(LjiOVldTag(oEAIObEt, "DocumentCode")) > TamSx3("L1_DOCPED")[1]
						lRet	:= .F.
						cMsgRet := STR0165 //"A informação contida na TAG DocumentCode esta maior que o tamanho do campo L1_DOCPED da tabela SL1."
						If Len(LjiOVldTag(oEAIObEt, "DocumentCode")) > TamSx3("E1_NUM")[1]
							cMsgRet := STR0166 //"A informação contida na TAG DocumentCode esta maior que o tamanho dos campos L1_DOCPED (Tabela SL1) e E1_NUM (Tabela SE1)."
                            LjGrvLog("LOJI701", cMsgRet)
						EndIf
					Else
						//Tratamento tamanho Doc
						cDoc := Padr(cDoc, TamSx3("LQ_DOC")[1])
					EndIf
				EndIf

				If lRet .AND. TamSx3("L1_DOCPED")[1] <> TamSx3("E1_NUM")[1]
					lRet := .F.
					cMsgRet := STR0167 //"O tamanho dos campos L1_DOCPED (Tabela SL1) e E1_NUM (Tabela SE1) estão com tamanhos diferentes, por favor, esses campos devem conter o mesmo tamanho."
                    LjGrvLog("LOJI701", cMsgRet)
				EndIf

			EndIf
	
			If lRet
				If lRps .Or. lNfe .Or. lNfm	//Rps/Nfe/Nota Manual
					cTipoOrc  	:= ""
					cTipoVen  	:= "V"
					cPdv 		:= "001"
					
					If !Empty(AllTrim(Upper(LjiOVldTag(oEAIObEt, "KeyAcessNFe"))))
						cChaveNFCe := LjiOVldTag(oEAIObEt, "KeyAcessNFe") //Chave NFCe
						cProtoNFCe := LjiOVldTag(oEAIObEt, "NfceProtocol") //Protocolo NFCe
					Endif
				Else //Cupom/NFCe/Sat

					//Carrega a estação
					aAux := LjI701Esta(cMarca, LjiOVldTag(oEAIObEt, "StationSalePointCode"), LjiOVldTag(oEAIObEt, "StationSalePointInternalId"), LjiOVldTag(oEAIObEt, "StationCode") )

					If !aAux[1]

						lRet	:= .F.
						cMsgRet := aAux[2]
					Else

						cEstac := aAux[2]

						//Posiciona na Estacao do Protheus
						SLG->(dbSetOrder(1))
			
						If !SLG->(dbSeek(xFilial("SLG") + cEstac))
							lRet 	 := .F.
							cMsgRet := STR0011 + " " + cEstac + " " + STR0026 //#"Estacao:" ##"nao encontrada no Protheus, verificar o cadastro ou integracao de Estacao."
                            LjGrvLog("LOJI701", cMsgRet)
						Else
					
							//Inicializa a Serie
							cSerie	:= SLG->LG_SERIE
												
							//Pdv
							cPdv := SLG->LG_PDV
																						
							If lNfce
								cTipoOrc  := "E"
								cTipoVen  := ""
							
								cChaveNFCe := LjiOVldTag(oEAIObEt, "KeyAcessNFe") //Chave NFCe
								cProtoNFCe := LjiOVldTag(oEAIObEt, "NfceProtocol") //Protocolo NFCe
								cSerie 	   := Padr(LjiOVldTag(oEAIObEt, "SerieCode"), TamSx3("L1_SERIE")[1])
								If Empty(cSerie)
									cSerie	:= SLG->LG_SERIE
								EndIf
							Else
								cTipoOrc  := ""
								cTipoVen  := "V"
								
								If lSat
									cSerieSat  := LjiOVldTag(oEAIObEt, "SerialNumberSATEquipament") //Serie Sat
									
									//Busca a Serie na SLG com base da Serie do Equipamento SAT
									If !Empty(cSerieSat)
										cSerie := LjiSerSLG(cSerie,cSerieSat)
									Else
										lRet 	 := .F.
										cMsgRet := STR0127 //#"Série SAT não enviada, informacao obrigatória para venda SAT, verifique a tag SERIALNUMBERSATEQUIPAMENT"	
                                        LjGrvLog("LOJI701", cMsgRet)
									EndIf
								EndIf
								
							EndIf
						
							//Validacoes
							If Empty(cSerie)
								lRet 	 := .F.
								cMsgRet := STR0077 //"Serie nao cadastrada, verifique o campo Serie do Cadastro de Estacoes no Protheus"
                                LjGrvLog("LOJI701", cMsgRet)
							ElseIf lNfce .And. Empty(cChaveNFCe)
								lRet 	 := .F.
								cMsgRet := STR0094 //#"Chave NFCe nao enviada, informacao obrigatoria para venda NFCe, verifique a tag KeyAcessNFe"	
                                LjGrvLog("LOJI701", cMsgRet)
							ElseIf lNfce .And. Len(cChaveNFCe) < 44
								lRet 	 := .F.
								cMsgRet := STR0128 //#"Chave NFCe menor que o padrão, verifique a tag: KeyAcessNFe"									
                                LjGrvLog("LOJI701", cMsgRet)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			
			//TRATAMENTO PARA UTILIZACAO DE FORNECEDORES
			If !Empty(LjiOVldTag(oEAIObEt, "SaleType"))
				cTipoVen := UPPER(LjiOVldTag(oEAIObEt, "SaleType"))
			EndIf

            //Inclusão de tags para contemplar a NT2020-006
            If !Empty(LjiOVldTag(oEAIObEt, "PresencialIndicator"))
                cPresen := LjiOVldTag(oEAIObEt, "PresencialIndicator")
                IF !(cPresen $ '123459')            
                    lRet := .F.
                    cMsgRet := I18n(STR0173, {cPresen}) //"A tag PresencialIndicator recebeu um valor não valido #1. Favor verificar a informação recebida e ajuste na VTEX."
                    LjGrvLog("LOJI701", cMsgRet)
                EndIF                
            EndIF

            If !Empty(LjiOVldTag(oEAIObEt, "IntermediaryCode"))
                cInterm := LjiOVldTag(oEAIObEt, "IntermediaryCode")
            EndIF
			
			LjGrvLog("LOJI701","VERIFICAÇÃO TIPO DE VENDA: "+Time())
										
			If lRet
				cValExt := LjiOVldTag(oEAIObEt, "CustomerVendorInternalId")  //carrega o codigo que pode ser do cliente ou fornecedor, depende do tipo de nota, quando devolução esse codigo eh do forncedor
				
				If !cTipoVen $ "B|D" 

					cCodCli := PadR(LjiOVldTag(oEAIObEt, "CustomerCode"),TamSX3("A1_COD")[1])
					cLojCli := PadR(LjiOVldTag(oEAIObEt, "StoreCode"),TamSX3("A1_LOJA")[1])				
		
					If !Empty(cCodCli) .And. !Empty(cLojCli) 
						LjGrvLog("LOJI701","Cliente "+cCodCli+"-"+cLojCli+" selecionado das tags CustomerCode e StoreCode")
					ElseIf !Empty(cValExt)
						aAux := IntCliInt(cValExt, cMarca)
					
						//Se encontrou o cliente no de-para
						If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
							cCodCli := PadR(aAux[2][3], TamSX3("A1_COD")[1])
							cLojCli := PadR(aAux[2][4], TamSX3("A1_LOJA")[1])
							LjGrvLog("LOJI701","Cliente "+cCodCli+"-"+cLojCli+" selecionado da tag CustomerVendorInternalId. Valor externo: "+cValExt)																							
						Else
							lRet := .F.
							cMsgRet := STR0007 + " " + AllTrim(cValExt) + " " + STR0008 //#"Cliente: " ##"nao integrado ao Protheus, verificar integracao de clientes"
                            LjGrvLog("LOJI701", cMsgRet)
						EndIf
					Else //Utiliza cliente padrao
						cCodCli := Padr(SuperGetMv("MV_CLIPAD",, "000001"), TamSX3("A1_COD")[1])
						cLojCli := Padr(SuperGetMv("MV_LOJAPAD",, "01"), TamSX3("A1_LOJA")[1])
					EndIf
				Else
				
					aAux := IntForInt(cValExt, cMarca) //verifica se o código enviado existe no De-Para de Fornecedor

					If aAux[1]	//se possuir o De-Para de Fornecedor, verifica se possui o CNPJ do fornecedor na tabela SA1, se não existir inclui para utilizar no registro da F2_CLIENTE
						
						
						DbSelectArea("SA2")
						SA2->(DbSetOrder(1))
						IF(SA2->(DbSeek(xFilial("SA2")+ PadR(aAux[2][3], TamSX3("A2_COD")[1])+PadR(aAux[2][4], TamSX3("A2_LOJA")[1]) )))

							DbSelectArea("SA1")
							SA1->(DbSetOrder(3))
							If!(SA1->(DbSeek(xFilial("SA1")+SA2->A2_CGC)))
								_aCliente:= STARTJOB("LjGerClif", GetEnvServer(), .T., CEMPANT, CFILANT,SA2->A2_CGC)
								
								If _aCliente[1]
									cCodCli := _aCliente[2]
									cLojCli := _aCliente[3]
								Else
									lRet := .F.
									cMsgRet := STR0007 + " " + AllTrim(cValExt) + " " + STR0008 + "[01] "+_aCliente[4] //#"Cliente: " ##"nao integrado ao Protheus, verificar integracao de clientes" 
								Endif
							Else	
								cCodCli := SA1->A1_COD
								cLojCli := SA1->A1_LOJA									
							Endif
						Else
							lRet := .F.
							cMsgRet := STR0007 + " " + AllTrim(cValExt) + " " + STR0008 //#"Cliente: " ##"nao integrado ao Protheus, verificar integracao de clientes" 
                            LjGrvLog("LOJI701", cMsgRet)
						Endif
					Else
						
						cCpfCli := LjiOVldTag(oEAIObEt, "PersonalIdentification")
						If Empty(cCpfCli)
							lRet := .F.
							cMsgRet := I18n(STR0137, {"D\B", "PersonalIdentification"})	//"Nota do tipo #1 sem fornecedor identificado, verifique o CNPJ. #2"
                            LjGrvLog("LOJI701", cMsgRet)
						Endif
						
						DbSelectArea("SA2")
						SA2->(DbSetOrder(3))
						If SA2->( DbSeek(xFilial("SA2") + cCpfCli) )	//Quando não encontra o fornecedor na tabela De-Para, verifica se possui fornecedor com o CNPJ informado
							
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
									cMsgRet := STR0007 + " " + AllTrim(cValExt) + " " + STR0008 + "[02] "+_aCliente[4] //#"Cliente: " ##"nao integrado ao Protheus, verificar integracao de clientes" 
								Endif
							Else
								cCodCli := SA1->A1_COD
								cLojCli := SA1->A1_LOJA
							Endif
						Else
							lRet := .F.
							cMsgRet := I18n(STR0137, {"D\B", cCpfCli})	//"Nota do tipo #1 sem fornecedor identificado, verifique o CNPJ. #2"
                            LjGrvLog("LOJI701", cMsgRet)
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
					cMsgRet := STR0007 + " " + AllTrim(cCodCli) + "/" + STR0017 + " " + cLojCli + " " + STR0019 //#"Cliente:" ##"Loja:"###"nao cadastrado no Protheus, verifique o cadastro de clientes."
                    LjGrvLog("LOJI701", cMsgRet)
				EndIf
			
				If lRet
					//Verifica se Cliente esta bloqueado
					If SA1->A1_MSBLQL == "1"
						lRet := .F.
						cMsgRet := STR0007 + " " + AllTrim(cCodCli) + "/" + STR0017 + " " + cLojCli + " " + STR0075 //#"Cliente:" ##"Loja:"###"bloqueado, verifique o Cadastro de Clientes no Protheus."
                        LjGrvLog("LOJI701", cMsgRet)
					EndIf
				
					If lRet
						//Cpf do Cliente, utilizado caso deseja CPF na Nota			
						cCpfCli := LjiOVldTag(oEAIObEt, "PersonalIdentification")

						//Carrega Operador\Caixa
						aAux := LjI701Oper(cMarca, LjiOVldTag(oEAIObEt, "OperatorCode"), LjiOVldTag(oEAIObEt, "OperatorInternalId"))

						If aAux[1]
							cOperador := aAux[2]
						Else
							//Tenta novamente trocando as posicoes do internal e external para manter legado
							aAux := LjI701Oper(cMarca, LjiOVldTag(oEAIObEt, "OperatorInternalId") ,  LjiOVldTag(oEAIObEt, "OperatorCode"))
							If aAux[1]
								cOperador := aAux[2]
							Else	
								lRet	:= .F.
								cMsgRet := aAux[2]
                                LjGrvLog("LOJI701", cMsgRet)
							EndIf	
						EndIf
					EndIf
				EndIf
			EndIf

			If lRet
				//Data de Emissao
				cEmissao := LjiOVldTag(oEAIObEt, "IssueDateDocument", "D")
			
				If Empty(cEmissao)
					lRet 	 := .F.
					cMsgRet := STR0020 //#"Campo obrigatorio nao informado: Data de Emissao, verifique a tag: IssueDateDocument."
                    LjGrvLog("LOJI701", cMsgRet)
				Else
					If cEmissao <= DtoS(cDtUlmes)		
						lRet 	 := .F.
						cMsgRet := STR0129 //"Data de Emissao menor que a data do fechamento do parâmetro: MV_ULMES"
                        LjGrvLog("LOJI701", cMsgRet)
					EndIf
					
					If lRet .And. cEmissao <= DtoS(cDtDblqMov)
						lRet 	 := .F.
						cMsgRet := STR0130 //"Data de Emissao menor que a data do fechamento do parâmetro: MV_DBLQMOV"
                        LjGrvLog("LOJI701", cMsgRet)
					EndIf	
									
				EndIf
			
				If lRet
					cTimeEmis := LjiOVldTag(oEAIObEt, "IssueDateDocument", "T")
																								
					//Validacoes de campos obrigatorios															
					If LjiOVldTag(oEAIObEt, "TotalPrice","N") <= 0
						lRet 	 := .F.
						cMsgRet := STR0027 //#"Campo obrigatorio nao informado: Valor Total da Venda, verifique a tag: TotalPrice."
                        LjGrvLog("LOJI701", cMsgRet)
					ElseIf LjiOVldTag(oEAIObEt, "NetPrice","N") <= 0 
						lRet 	 := .F.
						cMsgRet := STR0028 //#"Campo obrigatorio nao informado: Valor Liquido da Venda, verifique a tag: NetPrice."
                        LjGrvLog("LOJI701", cMsgRet)
					ElseIf LjiOVldTag(oEAIObEt, "GrossPrice","N") <= 0
						lRet 	 := .F.
						cMsgRet := STR0029 //#"Campo obrigatorio nao informado: Valor Bruto da Venda, verifique a tag: GrossPrice."
                        LjGrvLog("LOJI701", cMsgRet)
					EndIf				

					If lRet
						If lIntegHtl //Hotelaria
							//Grava informações de reserva que serão utilizadas para as descrições de serviços na NFS-e (Integração com hotelaria)
							
							If oEAIObEt:getPropValue("BookInginformation") != Nil	.And. oEAIObEt:getPropValue("ReserveItemType"):getPropValue("Item") <> NIL
								lReserva 	:= .T.
								cReserva 	:= LjiOVldTag( oEAIObEt:BookInginformation, "HotelAccountCode", "C" ) //Numero da Reserva
								cDataIn  	:= LjiOVldTag( oEAIObEt:BookInginformation, "CheckinDate", "D" ) //Data de checkin da reserva
								cTipoUH  	:= LjiOVldTag( oEAIObEt:BookInginformation, "HabitationalUnitType", "C" ) //Tipo de unidade habitacional
								cNumUH   	:= LjiOVldTag( oEAIObEt:BookInginformation, "HabitationalUnitNumber", "C" ) //Número da unidade habitacional
								cHospede 	:= LjiOVldTag( oEAIObEt:BookInginformation, "MainGuestName", "C" ) //Nome do hóspede principal
								cOutrosHsp	:= LjiOVldTag( oEAIObEt:BookInginformation, "AdditionalGuestName", "C" ) //Nome dos demais hóspedes
								cGrupoRsv 	:= LjiOVldTag( oEAIObEt:BookInginformation, "GroupName", "C" ) //Nome do grupo da reserva
								cEventoRsv	:= LjiOVldTag( oEAIObEt:BookInginformation, "EventName", "C" ) //Nome do evento da reserva
							EndIf
						EndIf
																							
						//Valor de Comissao do Vendedor
						nPerComis := LjiOVldTag(oEAIObEt, "CommissionPercent", "N")
				
						//De-Para Fornecedor
						cValExt := LjiOVldTag(oEAIObEt, "SellerInternalid")
								
						If !Empty(cValExt)
							cVendedor := CFGA070INT(cMarca, "SA3", "A3_COD", cValExt)
						
							//Separa o retorno 
							aAux := Separa(cVendedor, "|")
						
							//Verifica se encontrou vendedor no De/Para
							If ValType(aAux) == "A" .And. Len(aAux) >= 3
								cVendedor := PadR(aAux[3], TamSX3("A3_COD")[1])
							Else
								lRet 	 := .F.
								cMsgRet :=  STR0079 + " " + AllTrim(cValExt) + " " + STR0080 //#"Vendedor:" ##"nao integrado no Protheus, verifique a integracao de Vendedores."
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
						cMsgRet := STR0078 //#"Vendedor nao informado, obrigatorio para venda com comissao, verifique a tag: SellerInternalId."
					Else
						cVendedor := SuperGetMv("MV_VENDPAD",, "000001")
					EndIf
				EndIf
				
				If lRet
					//Armazena Valor Total da Venda
					nVlrTot    := LjiOVldTag(oEAIObEt, "TotalPrice"     , "N")
					nVlrLiq    := LjiOVldTag(oEAIObEt, "NetPrice"       , "N")
					nVlMercTot := LjiOVldTag(oEAIObEt, "CommodityPrice" , "N")
				
					//Armazena Desconto no Total da Venda
					nValDesTot := LjiOVldTag(oEAIObEt, "DiscountValue"  , "N")
					nPerDesTot := LjiOVldTag(oEAIObEt, "DiscountPercent", "N")

                    nValDesp   := LjiOVldTag(oEAIObEt, "IncreaseValue", "N")

                    //Caso vir com valor negativo no desconto na venda (cabeçalho) alteramos para positvo para soma
                    If nValDesTot < 0
                        cMsgRet := I18n(STR0175, {cValtoChar(nValDesTot)}) //"O desconto recebido na tag DiscountValue com o valor #1. Será alterado para composição de valor total."
                        LjGrvLog("LOJI701", cMsgRet)
                        nValDesTot := Abs(nValDesTot)
                    EndIF

                    //Armazena o Frete
                    nFrete     := LjiOVldTag(oEAIObEt, "FreightValue"   , "N")
                                        
                    //Realiza a soma do valor total com o desconto na venda (cabeçalho) necessario por conta da proporcionalização no desconto no item e devido o padrão de gravação da SC5 e SC6.
                    nVlrTot    := nVlrTot + nValDesTot 

                    If lExecParFRE
                        //Eleger Tipo Frete utilizada atraves do parametro MV_LJTPFRE (macro-executa)
                        xRet  := &(SubStr(cMV_LJTPFRE,2,Len(cMV_LJTPFRE)))
                        If ValType(xRet) == "C"
                            cTpFrete  := xRet
                        EndIf
                    Else
                        cTpFrete := cMV_LJTPFRE
                    EndIf                    
                    
                    If !Alltrim(cTpFrete) $ "CFTRDS"
                        lRet 	:= .F.
                        cMsgRet := STR0164 //#"Tipo de frete informado no parâmetro MV_LJTPFRE não é valido, informe um tipo de frete valido. Após a alteração do parâmetro, é necessario reiniciar os serviços do Protheus."
                        LjGrvLog("LOJI701", cMsgRet)
                    EndIF

					If lIntegHtl //Hotelaria
						//Armazena informacoes de rateio						
						cRateio  := "" //Inicializa variavel de rateio
						nPercent := 0 //Inicializa percentual de rateio
					
						If oEAIObEt:getPropValue("ListofFinancialNatureApportionment") != Nil	.And. oEAIObEt:getPropValue("ListofFinancialNatureApportionment"):getPropValue("FinancialNatureApportionment") <> NIL
				
							oListFinNat := oEAIObEt:getPropValue("ListofFinancialNatureApportionment"):getPropValue("FinancialNatureApportionment")
					
							If lRps
								If lMultiNat

									For nI := 1 To Len(oListFinNat)

										If oListFinNat[nI]:getPropValue("ListOfCostCenterApportionment") != Nil

											oListCost := oListFinNat[nI]:getPropValue("ListOfCostCenterApportionment")
										
											For nX := 1 To Len(oListCost)
												If lRet
													//Centro de Custo										 														  																																																														
													If Empty(cCCusto)
														lRet 	 := .F.
														cMsgRet := STR0101 //#"Centro de Custo nao informado, obrigatorio quando utilizado rateio, verifique no Protheus o parametro: MV_HTLCCRT"
														Exit
													EndIf
												
													//Entidade
													cValExt := LjiOVldTag(oListCost, "GenericEntityInternalid")
													aAux := IntGerInt(cValExt, cMarca,  "1.000")
												
													cEntidade := "" //Inicializa entidade
												
													If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
														cEntidade := PadR(aAux[2][4], TamSX3("EZ_EC05DB")[1])
													EndIf
												
													If Empty(cEntidade)
														lRet 	 := .F.
														cMsgRet := STR0098 //#"Entidade nao informada ou nao integrada ao Protheus para rateio, verifique a lista: ListOfFinancialNatureApportionment, tag: GenericEntityInternalId."
														Exit
													EndIf
												
													nPercent += LjiOVldTag(oListCost, "Percentage", "N")
											
													//Valida se percentual foi enviado
													If nPercent <= 0
														lRet 	 := .F.
														cMsgRet := STR0099 //#"Percentual de rateio nao informado no rateio, verifique a lista: ListOfFinancialNatureApportionment, tag: Percentage."
														Exit
													EndIf
											
													cRateio += "#"
													cRateio += "*" + cCCusto //Centro de Custo
													cRateio += "*" + cEntidade //Entidade
													cRateio += "*" + AllTrim(STR(nPercent)) //Percentual
									
												EndIf
											Next nX
										EndIf
									Next nI
								Else
									lRet 	:= .F.
									cMsgRet := STR0102 + "," + STR0103 //#"Para utilizar informacoes de rateio tag: ListOfFinancialNatureApportionment" ##"é necessário habilitar o parametro MV_MULNATR no Protheus."
								EndIf
							Else
								lRet 	:= .F.
								cMsgRet := STR0104 + "," + STR0105 //#"Esta mensagem possui informacoes de rateio tag: ListOfFinancialNatureApportionment mas nao é uma RPS"##"verifique a tag: KindOfDocument."
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			If lRet
                
                //Armazena impostos do Cabecalho da Venda
				If oEAIObEt:getPropValue("ListOfTaxes") != Nil	.And. oEAIObEt:getPropValue("ListOfTaxes"):getPropValue("Tax") <> NIL

                    //Valida calculo de impostos pelo Protheus
                    If lCalcImp
                        lRet    := .F.
                        cMsgRet := I18n(STR0150, {"TAG ListOfTaxes", "TAG KindOfDocument"})     //"Esta mensagem possui informações de impostos na #1, mas seu tipo de documento não foi informado na #2."
                        LjGrvLog("LOJI701", cMsgRet)
                    EndIf
				
                    If lRet
                        oCabImp := oEAIObEt:getPropValue("ListOfTaxes"):getPropValue("Tax")
                    
                        For nI := 1 To Len(oCabImp)
                            Do Case
                            Case AllTrim(Upper(LjiOVldTag(oCabImp[nI], "Taxe"))) == "ICM" //Icms
                                nSL1Icms += LjiOVldTag(oCabImp[nI], "Value", "N")
                            Case AllTrim(Upper(LjiOVldTag(oCabImp[nI], "Taxe"))) == "ISS" //Iss
                                nSL1Iss += LjiOVldTag(oCabImp[nI], "Value", "N")
                            Case AllTrim(Upper(LjiOVldTag(oCabImp[nI], "Taxe"))) == "PIS" //Pis
                                nSL1Pis += LjiOVldTag(oCabImp[nI], "Value", "N")
                            Case AllTrim(Upper(LjiOVldTag(oCabImp[nI], "Taxe"))) == "COFINS" //Cofins
                                nSL1Cof += LjiOVldTag(oCabImp[nI], "Value", "N")
                            Case AllTrim(Upper(LjiOVldTag(oCabImp[nI], "Taxe"))) == "CSLL" //CSLL
                                nSL1CSLL += LjiOVldTag(oCabImp[nI], "Value", "N")
                            Case "IRRF" $ AllTrim(Upper(LjiOVldTag(oCabImp[nI], "_Taxe"))) //IRRF
                                nSL1IRRF += LjiOVldTag(oCabImp[nI], "Value", "N")
                            Case AllTrim(Upper(LjiOVldTag(oCabImp[nI], "Taxe"))) == "FECP" //FECP
                                nL1VlFECP += LjiOVldTag(oCabImp[nI], "Value", "N")
                                nL1BsFECP += LjiOVldTag(oCabImp[nI], "CalculationBasis", "N")
                            Case AllTrim(Upper(LjiOVldTag(oCabImp[nI], "Taxe"))) == "FECP_ST" //FECP_ST
                                nL1VlFCPST += LjiOVldTag(oCabImp[nI], "Value", "N")
                                nL1BsFCPST += LjiOVldTag(oCabImp[nI], "CalculationBasis", "N")
                            Case AllTrim(Upper(LjiOVldTag(oCabImp[nI], "Taxe"))) == "IPI" //IPI
                                nSL1ValIpi += LjiOVldTag(oCabImp[nI], "Value", "N")
                                nSL1BasIpi += LjiOVldTag(oCabImp[nI], "CalculationBasis", "N")
                            Case AllTrim(Upper(LjiOVldTag(oCabImp[nI], "Taxe"))) == "ICMS_ST" //ICMS-ST
                                nSL1ValSol += LjiOVldTag(oCabImp[nI], "Value", "N")
                                nSL1BasSol += LjiOVldTag(oCabImp[nI], "CalculationBasis", "N")
                            EndCase
                        Next nI
                    EndIf

				EndIf

			EndIf
			
			//Pega a Transportadora
			If lRet 
				aAux := Lj701ITran( cMarca, nTypeTrans, LjiOVldTag(oEAIObEt, "CarrierCode"), LjiOVldTag(oEAIObEt, "CarrierInternalId") )
				lRet := aAux[1]
				
				If lRet
					cTransp := aAux[2]
				Else
					cMsgRet := aAux[2]
                    LjGrvLog("LOJI701", cMsgRet)
				EndIf
			EndIf

            If Len(LjiOVldTag(oEAIObEt, "ECommerceOrder")) > TamSx3("LQ_ECPEDEC")[1]
                lRet := .F.
                cMsgRet := STR0169 //"A informação contida na TAG ECommerceOrder esta maior que o tamanho do campo L1_ECPEDEC (Tabela SL1)."
                LjGrvLog("LOJI701", cMsgRet)
            EndIf

			If lRet
				nTroco := LjiOVldTag(oEAIObEt, "Change", "N") //Armazena valor de troco

				//Lei de Transparencia 

				nImpEstSL1 := LjiOVldTag(oEAIObEt,  "StateTaxBurden", "N")

				nImpMunSL1 := LjiOVldTag(oEAIObEt,  "MunicipalTaxBurden", "N")
	
				nImpFedSL1 := LjiOVldTag(oEAIObEt,  "FederalTaxBurden", "N")
				
				cTaxSource := LjiOVldTag(oEAIObEt,  "TaxSource", "C")
				
				If !Empty(cSerieSat)
					cChaveNFCe := LjiOVldTag(oEAIObEt, "KeyAcessNFe") //Chave SAT
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
							{"LQ_DTLIM"  	, dDataBase 													, Nil},;
							{"LQ_DINHEIR" 	, LjiOVldTag(oEAIObEt, "CashValue", "N")						, Nil},;
							{"LQ_CHEQUES"	, LjiOVldTag(oEAIObEt, "ChecksValue", "N")						, Nil},;
							{"LQ_CARTAO"	, LjiOVldTag(oEAIObEt, "CardsValue", "N")						, Nil},;
							{"LQ_VLRDEBI"	, LjiOVldTag(oEAIObEt, "DebitValue", "N")						, Nil},;
							{"LQ_CONVENI"	, LjiOVldTag(oEAIObEt, "CovenantValue", "N")					, Nil},;
							{"LQ_VALES"		, LjiOVldTag(oEAIObEt, "VouchersValue", "N")					, Nil},;
							{"LQ_FINANC"	, LjiOVldTag(oEAIObEt, "FinancedValue", "N")					, Nil},;
							{"LQ_OUTROS"	, LjiOVldTag(oEAIObEt, "OthersValue", "N")						, Nil},;
							{"LQ_ENTRADA"	, LjiOVldTag(oEAIObEt, "InputValue", "N")						, Nil},;
							{"LQ_EMISSAO" 	, SToD(cEmissao)   												, Nil},;
							{"LQ_NUMCFIS" 	, IIF(lRps, "", cDoc)											, Nil},;
							{"LQ_HORA"  	, cTimeEmis														, Nil},;
							{"LQ_DOC"		, cDoc															, Nil},;
							{"LQ_SERIE"		, cSerie  														, Nil},;
							{"LQ_PDV"		, cPdv															, Nil},;
							{"LQ_EMISNF"	, SToD(cEmissao)												, Nil},;
							{"LQ_VALBRUT"	, LjiOVldTag(oEAIObEt, "GrossPrice", "N")				  		, Nil},;
							{"LQ_VALMERC"	, IIF(nVlMercTot > 0, nVlMercTot, nVlrTot)						, Nil},;
							{"LQ_TIPO"		, cTipoVen														, Nil},;
							{"LQ_TIPORC"	, cTipoOrc														, Nil},;
							{"LQ_DESCNF"	, nPerDesTot													, Nil},;
							{"LQ_OPERADO"	, cOperador  													, Nil},;
							{"LQ_SITUA"		, cSitua   														, Nil},;
							{"LQ_STORC"		, cSituaOrc  													, Nil},;
							{"LQ_VALICM"	, nSL1Icms											            , Nil},;
							{"LQ_VALISS"	, nSL1Iss														, Nil},;
							{"LQ_TXMOEDA"	, LjiOVldTag(oEAIObEt, "CurrencyRate", "N")						, Nil},;
							{"LQ_MOEDA"		, nMoeda								   						, Nil},;
							{"LQ_TROCO1"	, nTroco														, Nil},;
							{"LQ_ESTACAO"	, cEstac   														, Nil},;
							{"LQ_DOCRPS"	, IIF(lRps, cDoc, "")											, Nil},;
							{"LQ_SERRPS"	, IIF(lRps, cSerie, "")											, Nil},;
							{"LQ_DOCPED"	, ""   															, Nil},;
							{"LQ_SERPED"	, ""   															, Nil},;
							{"LQ_CONDPG"	, cCondpg   													, Nil},;
							{"LQ_ESPECIE"	, cTpVenda														, Nil},;
							{"LQ_DESCFIN"	, LjiOVldTag(oEAIObEt, "DiscountPaymentTerm", "N")				, Nil},;
							{"LQ_ICMSRET"	, nSL1ValSol+nL1VlFCPST											, Nil},;
							{"LQ_BRICMS"	, nSL1BasSol													, Nil},;
							{"LQ_CREDITO"	, LjiOVldTag(oEAIObEt, "CreditValue", "N")						, Nil},;
							{"LQ_ORIGEM"	, "N"															, Nil},;
							{"LQ_VENDTEF"	, ""															, Nil},;
							{"LQ_DATATEF"	, ""															, Nil},;
							{"LQ_HORATEF"	, ""															, Nil},;
							{"LQ_DOCTEF"	, ""															, Nil},;
							{"LQ_AUTORIZ"	, ""															, Nil},;
							{"LQ_DOCCANC"	, ""															, Nil},;
							{"LQ_DATCANC"	, ""															, Nil},;
							{"LQ_HORCANC"	, ""															, Nil},;
							{"LQ_INSTITU"	, ""															, Nil},;
							{"LQ_NSUTEF"	, ""															, Nil},;
							{"LQ_VALPIS"	, nSL1Pis														, Nil},;
							{"LQ_VALCOFI"	, nSL1Cof														, Nil},;
							{"LQ_VALCSLL"	, nSL1CSLL														, Nil},;
							{"LQ_VALIPI"    , nSL1ValIpi                                                    , Nil},;
							{"LQ_CGCCLI"	, cCpfCli														, Nil},;
							{"LQ_DESPESA"	, nValDesp                                  					, Nil},;
							{"LQ_FRETE"		, nFrete                                    					, Nil},;
                            {"LQ_TPFRET"	, cTpFrete                                                      , Nil},;
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
							{"LQ_UMOV"		, cUUID															, Nil},;
                            {"LQ_ECPEDEC"   , LjiOVldTag(oEAIObEt, "ECommerceOrder", "C")                   , Nil},;
							{"LQ_TRANSP"	, cTransp														, Nil},;
                            {"LQ_INTERMD"	, cInterm														, Nil},;
                            {"LQ_INDPRES"	, cPresen														, Nil},;
							{"LQ_ECFLAG"	, ""    														, Nil}}

				nEcFlag := aScan(aCab,{|x| AllTrim(x[1]) == "LQ_ECFLAG"})

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

			// -------------------------------------------------------------------------------------------------------------------------------------------------------------------
			// BLOCO DOS ITENS
			// -------------------------------------------------------------------------------------------------------------------------------------------------------------------
			If lRet
				//Valida se produtos foram enviados
				If oEAIObEt:getPropValue("ListOfSaleItem") == Nil	.Or. oEAIObEt:getPropValue("ListOfSaleItem"):getPropValue("SaleItem") == Nil
					lRet 	 := .F.
					cMsgRet := STR0030 //#"Lista de produtos vazia, verifique a lista SaleItem."
                    LjGrvLog("LOJI701", cMsgRet)
				EndIf
			
				If lRet
						
					oItens := oEAIObEt:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")                  
					
					//Ponto de entrada para manipular os valores dos itens
					If lLjI701O1
						LjGrvLog("LOJI701","Antes de executar o PE LJI701O1",oItens)
						oItens := ExecBlock( "LJI701O1", .F., .F., {oItens} )
						LjGrvLog("LOJI701","Depois que executou o PE LJI701O1",oItens)
						If ValType(oItens) <> "A"
							lRet 	:= .F.
							cMsgRet := STR0168 //"Erro no retorno do ponto de entrada LJI701O1, o retorno não foi do tipo array."
                            LjGrvLog("LOJI701", cMsgRet)
						EndIf
					EndIf

					//Valida se lista esta vazia
					If Len(oItens) == 0
						lRet 	 := .F.
						cMsgRet := STR0030 //#"Lista de produtos vazia, verifique a lista SaleItem."
                        LjGrvLog("LOJI701", cMsgRet)
					EndIf
				EndIf
			EndIf

			//Realiza a validação do frente antes de entrar no laço dos itens
			aValidacoes := VldFrete(oItens, nFrete)
			If !aValidacoes[1]
				lRet	:= .F.
				cMsgRet := aValidacoes[2]
                LjGrvLog("LOJI701", cMsgRet)
			EndIf


			If lRet
			
				//Monta itens da venda
				LjGrvLog("LOJI701","INICIO MONTAGEM ITENS DA VENDA: "+Time())
				For nI := 1 To Len(oItens)
					
					//De-Para Produtos
					cValExt	 := LjiOVldTag(oItens[nI], "ItemInternalId")
					
					//Trata gravacao de itens cancelados
					lCancItem := LjiOVldTag(oItens[nI], "IsCanceled", "L")

					//Variaveis dos Itens de Venda
                    cItem       := Soma1(cItem,TamSX3("LR_ITEM")[1])
					nQuant     	:= LjiOVldTag(oItens[nI], "Quantity" 	  , "N")
					nVlrUnit   	:= LjiOVldTag(oItens[nI], "UnitPrice"	  , "N")								//Preço unitário
					nVlrTab 	:= LjiOVldTag(oItens[nI], "ItemTablePrice", "N")								//Preço de tabela do item 
					nVlrItem 	:= LjiOVldTag(oItens[nI], "ItemPrice"	  , "N") 								//Preço do item
					cAuxOpeCod 	:= LjiOVldTag(oItens[nI], "OperationCode")
                    
					If !Empty(cValExt)
						aAux := IntProInt(cValExt, cMarca)
				
						//Se encontrou o produto no de/para
						If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1] .And. ValType(aAux[2]) == "A" .And. len(aAux[2]) >= 3
							cProduto := PadR(aAux[2][3], TamSX3("B1_COD")[1])
						Else
							lRet 	 := .F.
							cMsgRet := STR0013 + " " + AllTrim(cValExt) + " " + STR0014 //#"Produto:" ##"nao integrado ao Protheus, verificar integracao de Produto"
                            LjGrvLog("LOJI701", cMsgRet)
							Exit
						EndIf
					Else
						cProduto := Padr(LjiOVldTag(oItens[nI], "ItemCode"), TamSx3("B1_COD")[1])
											
						If Empty(cProduto)
							lRet 	 := .F.
							cMsgRet := STR0031 + " " + CValToChar(nI) + "," + STR0032 //#"Inconsistencia no item" ##"produto nao informado na integracao, verifique a Tag ItemCode."
                            LjGrvLog("LOJI701", cMsgRet)
							Exit
						EndIf
					EndIf
																								
					//Posiciona no produto
					SB1->(dbSetOrder(1))
				
					If !SB1->(dbSeek(xFilial("SB1") + cProduto))
						lRet 	 := .F.
						cMsgRet := STR0031 + " " + CValToChar(nI) + "," + STR0033 + " " + AllTrim(cProduto) + " " + STR0034 //#"Inconsistencia no item" ##"produto:" ###"nao cadastrado no Protheus, verifique a tag: ItemCode"
                        LjGrvLog("LOJI701", cMsgRet)
						Exit
					EndIf

					//Validacoes de campos obrigatorios						
					If Empty(cItem) 
						lRet	:= .F.
						cMsgRet := STR0031 + " " + CValToChar(nI) + "," + STR0035 //#"Inconsistencia no item" ##"campo obrigatorio nao informado: Item, verifique a tag: ItemOrder."
                        LjGrvLog("LOJI701", cMsgRet)
						Exit
					ElseIf nQuant <= 0
						lRet 	:= .F.
						cMsgRet := STR0031 + " " + CValToChar(nI) + "," + STR0036 //#"Inconsistencia no item" ##"campo obrigatorio nao informado: Quantidade, verifique a tag: Quantity."
                        LjGrvLog("LOJI701", cMsgRet)
						Exit
					ElseIf nVlrUnit <= 0
						lRet 	:= .F.
						cMsgRet := STR0031 + " " + CValToChar(nI) + "," + STR0037 //#"Inconsistencia no item" ##"campo obrigatorio nao informado: Preco Unitario, verifique a tag: UnitPrice."
                        LjGrvLog("LOJI701", cMsgRet)
						Exit
					ElseIf Empty(cAuxOpeCod)
						lRet 	:= .F.
						cMsgRet := STR0031 + " " + CValToChar(nI) + "," + STR0039 //#"Inconsistencia no item" ##"campo obrigatorio nao informado: CFOP, verifique a tag: OperationCode."
                        LjGrvLog("LOJI701", cMsgRet)
						Exit
					ElseIf nVlrItem <= 0
						lRet 	:= .F.
						cMsgRet := STR0031 + " " + CValToChar(nI) + "," + STR0162 //#"Inconsistencia no item" ##"campo obrigatório não informado: Preço do produto, verifique a tag: ItemPrice."
                        LjGrvLog("LOJI701", cMsgRet)
						Exit
					EndIf
				
					If lIntegHtl //Hotelaria
						//Validacao para impedir vendas mistas (produtos e servicos)										
						If lRps .And. !SB1->B1_TIPO $ "GE|GG|MO|SV"
							lRet    := .F.
							cMsgRet := STR0031 + " " + CValToChar(nI) + "," + STR0090 //#"Inconsistencia no item" ##"enviado produto do tipo mercadoria em uma RPS, verifique o campo B1_TIPO no Protheus"
                            LjGrvLog("LOJI701", cMsgRet)
							Exit
						ElseIf !lRps .And. SB1->B1_TIPO $ "GE|GG|MO|SV"
							lRet 	:= .F.
							cMsgRet := STR0031 + " " + CValToChar(nI) + "," + STR0091 //#"Inconsistencia no item" ##"enviado produto do tipo servico em um Cupom, verifique o campo B1_TIPO no Protheus"
                            LjGrvLog("LOJI701", cMsgRet)
							Exit
						EndIf
					
						If lReserva //Se achou o produto e é pra gravar informações de Reserva (hotelaria), então guarda a descrição dos produtos e valores para gravar o campo de lançamentos (MH3_LANCTOS)
							cLanctos += AllTrim( SB1->B1_DESC ) + " " + AllTrim( LjiOVldTag(oItens[nI], "UnitPrice") ) + "|"
						EndIf
					EndIf
											
					//Caso o Valor não tenha sido enviado atribuímos o valor unitário atualmente apenas a Integração com o GEMCO utiliza a TAG ItemTablePrice
					If nVlrTab == 0
						nVlrTab := nVlrUnit
					EndIf					

					//Necessário a inclusão deste tratamento, pois em vendas com valor unitário com mais de 3 casas decimais o valor total apresentava divergência
					If nVlrItem <= 0
						nVlrItem := nVlrUnit * nQuant
					EndIf
											
					//Tratamento para proporcionalizar desconto no item, quando o item não for brinde
					nDescPro := 0                    
					If !lCancItem
					
						If LjiOVldTag(oItens[nI], "DiscountTotalProrated", "N") > 0
							nDescPro 	:= LjiOVldTag(oItens[nI], "DiscountTotalProrated", "N")
							nTotDesPro 	+= nDescPro
						Else
							//Verifica se houve desconto no total da venda e efetua o rateio nos itens
							If nPerDesTot > 0 .Or. nValDesTot > 0
								//Calcula o Percentual do Desconto no Total da venda
								If nPerDesTot == 0
									nPerDesTot := (nValDesTot * 100) / nVlMercTot
								EndIf
											
                                IF SuperGetMv("MV_LJTDESI", , 0) == 0 //Parametro para controlar o tipo de desconto na integração 0 = desligado padrao, 1 = desconto no valor bruto IPI(cabeçalho) 
                                    nDescPro := (nVlrItem / 100) * 	nPerDesTot 
                                EndIf
							EndIf
						EndIf
					EndIf
										
					//Verifica se item diaria para calcular comissao
					If nPerComis > 0
						If AllTrim(Upper(LjiOVldTag(oItens[nI], "Lodging"))) == "S"
							nValComis += (nVlrItem / 100) * nPerComis
						EndIf
					EndIf

                    //Armazena impostos dos Itens da Venda
					If oItens[nI]:getPropValue("ListOfTaxes") <> Nil .And. oItens[nI]:getPropValue("ListOfTaxes"):getPropValue("Tax") <> Nil

                        //Valida calculo de impostos pelo Protheus
                        If lCalcImp
                            lRet    := .F.
                            cMsgRet := I18n(STR0150, {"TAG ListOfTaxes", "TAG KindOfDocument"})     //"Esta mensagem possui informações de impostos na #1, mas seu tipo de documento não foi informado na #2."
                            LjGrvLog("LOJI701", cMsgRet)
                            Exit
                        EndIf
				
						oItImp := oItens[nI]:getPropValue("ListOfTaxes"):getPropValue("Tax")
					
						For nX := 1 To Len(oItImp)
							Do Case
								Case AllTrim(Upper(LjiOVldTag(oItImp[nX], "Taxe"))) == "ICM" //ICMS
									nSL2Icms := LjiOVldTag(oItImp[nX], "Value", "N") //Valor
									nBaseIcm := LjiOVldTag(oItImp[nX], "CalculationBasis", "N") //Base
									nAliqIcm := LjiOVldTag(oItImp[nX], "Percentage", "N") //Aliquota
									nAliqRed := LjiOVldTag(oItImp[nX], "ReductionBasePercent", "N") //Aliquota Reducao de Base ICMS
									
									If nAliqRed > 0
										nAliqRed := Round(100 - nAliqRed, TamSx3("L2_PREDIC")[2]) //Base Reducao ICMS
									EndIf
									
									//Gera Codigo de Tributacao, sempre sera enviado quando tributado
									cTribut := "T" + PadL(CValToChar(nAliqIcm * 100), 4, "0")

								Case AllTrim(Upper(LjiOVldTag(oItImp[nX], "Taxe"))) == "ISS" //ISS
									nSL2Iss  := LjiOVldTag(oItImp[nX], "Value", "N") //Valor
									nBaseIss := LjiOVldTag(oItImp[nX], "CalculationBasis", "N") //Base
									nAliqIss := LjiOVldTag(oItImp[nX], "Percentage", "N") //Aliquota
																	
									//Gera Codigo de Tributacao, sempre sera enviado quando tributado
									cTribut := "S" + PadL(CValToChar(nAliqIss * 100), 4, "0")

								Case AllTrim(Upper(LjiOVldTag(oItImp[nX], "Taxe"))) == "PIS" //PIS
									If AllTrim(Upper( LjiOVldTag(oItImp[nX], "WithHoldingTax") )) == "TRUE" //Retencao
										
										nSL2PisRet  := LjiOVldTag(oItImp[nX], "Value", "N") //Valor
										nBasPisRet 	:= LjiOVldTag(oItImp[nX], "CalculationBasis", "N") //Base
										nAlqPisRet 	:= LjiOVldTag(oItImp[nX], "Percentage", "N") //Aliquota
									Else //Apuracao
										nSL2PisApu  := LjiOVldTag(oItImp[nX], "Value", "N") //Valor
										nBasPisApu 	:= LjiOVldTag(oItImp[nX], "CalculationBasis", "N") //Base
										nAlqPisApu 	:= LjiOVldTag(oItImp[nX], "Percentage", "N") //Aliquota
									EndIf

								Case AllTrim(Upper(LjiOVldTag(oItImp[nX], "Taxe"))) == "COFINS" //COFINS
									If AllTrim(Upper( LjiOVldTag(oItImp[nX], "WithHoldingTax") )) == "TRUE" //Retencao
										
										nSL2CofRet  := LjiOVldTag(oItImp[nX], "Value", "N") //Valor
										nBasCofRet 	:= LjiOVldTag(oItImp[nX], "CalculationBasis", "N") //Base
										nAlqCofRet 	:= LjiOVldTag(oItImp[nX], "Percentage", "N") //Aliquota
									Else //Apuracao
										nSL2CofApu  := LjiOVldTag(oItImp[nX], "Value", "N") //Valor
										nBasCofApu	:= LjiOVldTag(oItImp[nX], "CalculationBasis", "N") //Base
										nAlqCofApu	:= LjiOVldTag(oItImp[nX], "Percentage", "N") //Aliquota
									EndIf
									
								Case AllTrim(Upper(LjiOVldTag(oItImp[nX], "Taxe"))) == "CSLL" //CSLL
									nSL2CSLL  := LjiOVldTag(oItImp[nX], "Value", "N") //Valor
									nBaseCSLL := LjiOVldTag(oItImp[nX], "CalculationBasis", "N") //Base
									nAliqCSLL := LjiOVldTag(oItImp[nX], "Percentage", "N") //Aliquota

								Case "IRRF" $ AllTrim(Upper(LjiOVldTag(oItImp[nX], "_TAXE"))) //IRRF
									nSL2IRRF  := LjiOVldTag(oItImp[nX], "Value", "N") //Valor
									nBaseIRRF := LjiOVldTag(oItImp[nX], "CalculationBasis", "N") //Base
									nAliqIRRF := LjiOVldTag(oItImp[nX], "Percentage", "N") //Aliquota

								Case AllTrim(Upper(LjiOVldTag(oItImp[nX], "Taxe"))) == "FECP" //FECP
									nValFECP  := LjiOVldTag(oItImp[nX], "Value", "N") //Valor
									nAlqFECP := LjiOVldTag(oItImp[nX], "Percentage", "N") //Aliquota
									nBasFECP := LjiOVldTag(oItImp[nX], "CalculationBasis", "N") //Base

								Case AllTrim(Upper(LjiOVldTag(oItImp[nX], "Taxe"))) == "FECP_ST" //FECP_ST
									nValFECPST  := LjiOVldTag(oItImp[nX], "Value", "N") //Valor
									nAlqFECPST := LjiOVldTag(oItImp[nX], "Percentage", "N") //Aliquota
									nBasFECPST := LjiOVldTag(oItImp[nX], "CalculationBasis", "N") //Base

								Case AllTrim(Upper(LjiOVldTag(oItImp[nX], "Taxe"))) == "IPI" //IPI
									nSL2ValIpi := LjiOVldTag(oItImp[nX], "Value", "N") //Valor
									nSL2AlqIpi := LjiOVldTag(oItImp[nX], "Percentage", "N") //Aliquota
									nSL2BasIpi := LjiOVldTag(oItImp[nX], "CalculationBasis", "N") //Base

								Case AllTrim(Upper(LjiOVldTag(oItImp[nX], "Taxe"))) == "ICMS_ST" //ICMS_ST
									nSL2ValSol := LjiOVldTag(oItImp[nX], "Value", "N") //Valor
									nSL2AlqSol := LjiOVldTag(oItImp[nX], "Percentage", "N") //Aliquota
									nSL2BasSol := LjiOVldTag(oItImp[nX], "CalculationBasis", "N") //Base

							EndCase
						Next nX
					EndIf
				
					//Descontos no item
					nPerItDesc	:= LjiOVldTag(oItens[nI], "DiscountPercentage", "N")
					nValItDesc := LjiOVldTag(oItens[nI], "DiscountAmount", "N")
				
					//Se existir desconto no item e nao enviadas as duas tags, efetua o calculo
					If nValItDesc > 0
						nPerItDesc := Round((nValItDesc * 100) / nVlrItem, TamSx3("L2_DESC")[2]) //Calcula o Percentual do Desconto no Item
					ElseIf nPerItDesc > 0
						nValItDesc := (nVlrItem / 100) * nPerItDesc //Calcula o Valor do Desconto no Item
					EndIf
						
					//Valor de acrescimo no item
					nVlAcrsIt := LjiOVldTag(oItens[nI], "Increase", "N")
				
					//Armazem padrao
					cValExt := LjiOVldTag(oItens[nI], "WarehouseInternalid")
																
					If !Empty(cValExt)
						aAux := IntLocInt(cValExt, cMarca)
				
						//Se encontrou o cliente no de-para
						If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
							cArmazem := PadR(aAux[2][3], TamSX3("B1_LOCPAD")[1])
						Else
							lRet 	 := .F.
							cMsgRet := STR0031 + " " + CValToChar(nI) + "," + STR0106 + " " + AllTrim(cValExt) + " " + STR0107 //"Inconsistencia no item" #"Armazem: " ##"nao integrado ao Protheus, verificar integracao de armazens"
                            LjGrvLog("LOJI701", cMsgRet)
							Exit
						EndIf
					Endif
										
					If lIntegHtl //Hotelaria
						//Tratamento Centro de Custo consumo
						cLjCCusto 	:= "" //Centro de Custo
						cLjItemCC 	:= "" //Item Centro de Custo
						cLjClvl 	:= "" //Classe Valor
					
						cIdLoja := Padr(LjiOVldTag(oItens[nI], "StoreIdentificationCode"), TamSX3("LJ_CODIGO")[1])
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
                    //Quando venda ativa, adiciona apenas itens ativos
                    //Se venda cancelada, sempre adiciona, itens serao excluidos no processo de exclusao da venda 
					If !lCancItem .Or. lCancVen

                        //Soma valor de todos os itens
						nVlrItTot += nVlrItem
					
						//Lei de Transparencia
						nImpEst := LjiOVldTag(oItens[nI], "StateTaxBurden", "N")
						
						nImpMun := LjiOVldTag(oItens[nI], "MunicipalTaxBurden", "N")
						
						nImpFed := LjiOVldTag(oItens[nI], "FederalTaxBurden", "N")
					
						If lIntegHtl //Hotelaria
							//Armazena venda que reteve impostos Pis/Cofins do item - Bloco F100
							If lLjMvBf100
								cIdVendF100 := LjiOVldTag(oItens[nI], "Internalid")
							EndIf
						
							//Informacoes de Pensao - Hotelaria								   
							If !Empty(LjiOVldTag(oItens[nI], "BoardBasisInformation") )
								cDtVendF100 := ""							
								//Se produto referenciado em outra venda, verifica data para Bloco F100
								If lLjMvBf100 .And. !Empty(cIdVendF100)
									cDtVendF100 := LjiOVldTag(oItens[nI]:getPropValue("BoardBasisInformation"), "DateOfMovement", "D") 
																	
									If Empty(cDtVendF100)
										lRet 	 := .F.
										cMsgRet := STR0031 + " " + CValToChar(nI) + "," + STR0114 + "," + STR0115 + "," + STR0116 //"Inconsistencia no item" #"nao informada a data para verificacao do Bloco F100" ##"esta informacao é obrigatoria quando informada a venda origem Bloco F100" ###"verifique a tag: DateOfMovement localizada na lista BoardBasisInformation"
                                        LjGrvLog("LOJI701", cMsgRet)
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
							
								If !Empty(LjiOVldTag(oItens[nI]:getPropValue("BoardBasisInformation"), "BoardBasisType")) .Or.;
										!Empty(cDtVendF100)
							
									aAdd(aItemMh4, { 	cSerie,;
										cDoc,;
										AllTrim(LjiOVldTag(oItens[nI]:getPropValue("BoardBasisInformation"), "ItemOrder")),;
										LjiOVldTag(oItens[nI]:getPropValue("BoardBasisInformation"), "BoardBasistype"),;
										LjiOVldTag(oItens[nI]:getPropValue("BoardBasisInformation"), "BoardBasisvalue", "N"),;
										LjiOVldTag(oItens[nI]:getPropValue("BoardBasisInformation"), "BreakFastValue", "N"),;
										cIdVendF100,;
										StoD(cDtVendF100)})
								EndIf
							Else
								If lLjMvBf100 .And. !Empty(cIdVendF100)
									lRet 	 := .F.
									cMsgRet := STR0031 + " " + CValToChar(nI) + "," + STR0117 + "," + STR0115 + "," + STR0119 //"Inconsistencia no item" #"nao informada a lista BoardBasisInformation" ##"esta informacao é obrigatoria quando informada a venda origem Bloco F100" ###"verifique a tag InternalId na lista ListOfSaleItem"
                                    LjGrvLog("LOJI701", cMsgRet)
									Exit
								EndIf
							EndIf
						ElseIF !lIntegHtl .AND. cTipoVen == "D"
						
							If !Empty(LjiOVldTag(oItens[nI], "SourceDocument"))
								
								If !Empty(LjiOVldTag(oItens[nI], "SourceDocumentSerie"))  
							
									If LjiOVldTag(oItens[nI], "SourceDocumentItem","N") > 0 
									
										aAdd(aItemMh4, {cSerie,;
														cDoc,;
														cItem,;
														Nil,;
														0,;
														0,;
														Nil,;
														StoD(cEmissao),;
														LjiOVldTag(oItens[nI], "SourceDocument") ,;
														LjiOVldTag(oItens[nI], "SourceDocumentSerie") ,;
														LjiOVldTag(oItens[nI], "SourceDocumentItem","N") })
									Else
										lRet	:= .F.
										cMsgRet := I18n(STR0138, {cValToChar(nI), "SOURCEDOCUMENTITEM"})	//"Inconsistência no item #1, não informada a TAG #2, obrigatária para Notas de Devolução."
                                        LjGrvLog("LOJI701", cMsgRet)
										Exit
									Endif
								Else
									lRet	:= .F.
									cMsgRet := I18n(STR0138, {cValToChar(nI), "SOURCEDOCUMENTITEM"})	//"Inconsistência no item #1, não informada a TAG #2, obrigatária para Notas de Devolução."
                                    LjGrvLog("LOJI701", cMsgRet)
									Exit
								Endif
							Else
								lRet	:= .F.
								cMsgRet := I18n(STR0138, {cValToChar(nI), "SOURCEDOCUMENTITEM"})	//"Inconsistência no item #1, não informada a TAG #2, obrigatária para Notas de Devolução."
                                LjGrvLog("LOJI701", cMsgRet)
								Exit
							Endif
						EndIf					
					
						//Tratamento para pegar a TES
						//CODIGO DE OPERACAO
                        cCfop := ""
						If Len(Alltrim(cAuxOpeCod)) <= 2

							cTpOpera := PADR(cAuxOpeCod,TamSX3('FM_TIPO')[1] )
							cTesPrd  := MaTesInt(2, cTpOpera, cCodCli, cLojCli, "C", cProduto)

                            LjGrvLog("LOJI701O","TES Inteligente 1- Codigo da Operacao  : " + cTpOpera + " ,Codigo do Cliente: " + AllTrim(cCodCli) + "/" + "Loja:" + " " + cLojCli + " , Produto: " + cProduto + ". Retorno TES: " + cTesPrd )
																			
							If Empty(cTesPrd)
								cTpOpera := "01" //Inicializa tipo de operacao para Tes Inteligente
								cTesPrd  := MaTesInt(2, cTpOpera, cCodCli, cLojCli, "C", cProduto)
							Endif

                            LjGrvLog("LOJI701O","TES Inteligente 2- Codigo da Operacao  : " + cTpOpera + " ,Codigo do Cliente: " + AllTrim(cCodCli) + "/" + "Loja:" + " " + cLojCli + " , Produto: " + cProduto + ". Retorno TES: " + cTesPrd )

						//TES
						Elseif 	Len(Alltrim(cAuxOpeCod)) == 3
							cTesPrd := Alltrim(cAuxOpeCod)
						
						//CFOP
						ElseIf Len(Alltrim(cAuxOpeCod)) == 4
							cCfop 	:= Padr(cAuxOpeCod, TamSx3("LR_CF")[1])
						
						//BUSCA INFORMACAO DE TES A PARTIR DO DE / PARA
						Else
							cCfop 	 := Padr(cAuxOpeCod, TamSx3("LR_CF")[1])
							aCodcfop := Separa(CFGA070Int(cMarca, "SF4", "F4_CODIGO", cCfop),"|")
							cCfop	 := StrTran(Alltrim(cCfop),".","")

							If len(aCodcfop) >= 3 .AND. !Empty(aCodcfop[3])
								cTesPrd := aCodcfop[3]
							Else
								//Permite utilizar TES Inteligente por meio de consulta do tipo de operação do CFOP
								cTpOpera := ColConDHJ(cCfop,"S")//Busca operacao "S" de Saida
								
								If !Empty(cTpOpera)
									cTesPrd  := MaTesInt(2, cTpOpera, cCodCli, cLojCli, "C", cProduto)
								Else 	
									lRet	:= .F.
									cMsgRet := I18n(STR0139, {cCfop})	//"O CFOP #1 não foi encontrado no de\pare ou na tabela DHJ, verifique."
                                    LjGrvLog("LOJI701", cMsgRet)
									Exit
								EndIf
							Endif
						Endif

                        LjGrvLog("LOJI701O","TES Inteligente 3- Codigo da Operacao  : " + cTpOpera + " ,Codigo do Cliente: " + AllTrim(cCodCli) + "/" + "Loja:" + " " + cLojCli + " , Produto: " + cProduto + ". Retorno TES: " + cTesPrd )

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
							lRet	:= .F.
							cMsgRet := STR0031 + " " + CValToChar(nI) + "," + STR0040 //#"Inconsistencia no item" ##"TES nao informada, verifique o Cadastro de Produto no Protheus campo B1_TS e/ou De-Para de TES(XXF) e/ou as configurações para TES Inteligente(DHJ e SFM) e/ou parametros MV_TESSERV e MV_TESVEND."
                            LjGrvLog("LOJI701", cMsgRet)
							Exit                           
						EndIf
						
						//Não atualizar o CFOP quando recebeu a integração com o código de CFOP
						If Empty(cCfop)
							cCfop:= SF4->F4_CF
						EndIf
						
						//Valida CFOP
						If lIntegHtl //Hotelaria
							cCfop := Padr(cAuxOpeCod, TamSx3("LR_CF")[1])
							SX5->( dbSetOrder(1) )
							If !SX5->(dbSeek(xFilial("SX5") + "13" + cCfop))
								lRet 	:= .F.
								cMsgRet := STR0031 +  " " + CValToChar(nI) + "," + STR0063 + AllTrim(cCfop) + "," + STR0064 //#"Inconsistencia no item" ##"CFOP invalida:" ###"verifique o cadastro de CFOP"
                                LjGrvLog("LOJI701", cMsgRet)
								Exit
							EndIf
						Endif
						
						If !Empty(LjiOVldTag(oItens[nI], "StoreIdentificationCode"))

							cValExt := LjiOVldTag(oItens[nI], "StoreIdentificationCode") 
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
						If !Empty(LjiOVldTag(oItens[nI], "ItemDeliveryType"))							
							cTpEntrega := Rtrim(LjiOVldTag(oItens[nI], "ItemDeliveryType"))									
						EndIf	
	
						//Se não for 2=Retira
						If AllTrim(cTpEntrega) <> "2"
							lPedVen := .T.										

							//Faz uma verificação nos principais parametros para geração do pedido,
							//caso algum desses parametros esteja configurado incorretamente, retorna uma mensagem de erro
							//e não inclui o orçamento
							aValidacoes := VldParamPd()
							If !aValidacoes[1]
								lRet 	:= .F.
								cMsgRet := aValidacoes[2]
                                LjGrvLog("LOJI701", cMsgRet)
								Exit
							EndIf
						EndIf				
						
						If cTpEntrega == "1" .AND. nEcFlag > 0 .AND. Empty(aCab[nEcFlag][2])
							aCab[nEcFlag][2] := "P"
						EndIf

						//Armazena Data de Entrega do Item 
						cDataEntr := LjiOVldTag(oItens[nI], "ItemDeliveryDate", "D")

						If !Empty(cDataEntr)
							cDataEntr := SToD(cDataEntr)
						EndIf

						//NÚMERO DO LOTE
						If !Empty(LjiOVldTag(oItens[nI], "LotNumber"))
						
							cLoteItem := Padr(LjiOVldTag(oItens[nI], "LotNumber"),TamSx3("LR_LOTECTL")[1])
							
							//NÚMERO DO SUBLOTE
							//Caso a TAG do SubLote não seja enviada eu preciso setar a variável como "" pois ela é utilizada
							//para validação de estoques. 
							If !Empty(LjiOVldTag(oItens[nI], "SubLotNumber"))							
								cSubLoteItem := Padr(LjiOVldTag(oItens[nI], "SubLotNumber"),TamSx3("LR_NLOTE")[1])
							Else
								cSubLoteItem := ""								
							EndIf							
						EndIf
						
						//ENDEREÇO DO ESTOQUE
						If !Empty(LjiOVldTag(oItens[nI], "AddressItem"))	
							cAddresItem := Padr(LjiOVldTag(oItens[nI], "AddressItem"),TamSx3("LR_LOCALIZ")[1])
							//Verifica se o Endereço Existe
							LjGrvLog("LOJI701","Verifica Endereço do Estoque")
							DbSelectArea("SBE")
							SBE->(DbSetOrder(1))//BE_FILIAL+BE_LOCAL+BE_LOCALIZ+BE_ESTFIS
							If !(SBE->(DbSeek(xFilial("SBE")+cArmazem+cAddresItem)))
								lRet	:= .F.
								cMsgRet := I18n(STR0140, {cAddresItem, "AddressItem"})	//"Endereço de estoque: #1 não existe. (#2)"
								LjGrvLog("LOJI701", cMsgRet)
								Exit	
							Endif
							LjGrvLog("LOJI701","Verifica Número de Série")
							//NÚMERO DE SÉRIE
							If !Empty(LjiOVldTag(oItens[nI], "SeriesItem"))
							
								cSerieItem := Padr(LjiOVldTag(oItens[nI], "SeriesItem"),TamSx3("LR_NSERIE")[1])
								//Verifica se existe o Número de Série
								DbSelectArea("SBF")
								SBF->(DbSetOrder(1))
								If!(SBF->(DbSeek(xFilial("SBF")+cArmazem+cAddresItem+cProduto+cSerieItem)))
									lRet	:= .F.
									cMsgRet := I18n(STR0141, {cSerieItem, "SeriesItem"})	//"Número de série: #1 não existe, para o produto\endereço, (#2)"
									LjGrvLog("LOJI701", cMsgRet)
									Exit	
								Endif
							EndIf	
						EndIf
																																			
						//InternalId da Reserva								
						If !Empty(LjiOVldTag(oItens[nI], "ItemReserveInternalId"))
							
							cValExt := LjiOVldTag(oItens[nI], "ItemReserveInternalId")																	
							aAux := Separa(CFGA070Int(cMarca, "SC0", "C0_DOCRES", cValExt), "|")																														
								
							If ValType(aAux) == "A" .And. Len(aAux) > 0

                                aReserva  := ReserItEai(/*xFilial("SC0")*/, aAux[3], cProduto, @cLoteItem, @cSubLoteItem, @cAddresItem, @cSerieItem, nQuant, cNumRes, .F.)
                                nQtdRes := 0
								If Len(aReserva) > 0
									
                                    For nX := 1 to Len(aReserva)
                                        cC0FilRes := Padr(aReserva[nX][1], TamSx3("C0_FILIAL")[1])
                                        cCodResIt := Padr(aReserva[nX][2], TamSx3("C0_NUM")[1])
                                        nQtdRes	  += aReserva[nX][3]
                                        cFilRes   := aReserva[nX][5]
										If Empty(cLoteItem) .OR. Empty(cSubLoteItem) .OR. Empty(cAddresItem)
											cLoteItem 	 := Alltrim(aReserva[nX][6])
											cSubLoteItem := Alltrim(aReserva[nX][7])
											cAddresItem := Alltrim(aReserva[nX][8])			
										EndIf
                                        
                                        //Caso o WarehouseInternalid não for informado utilizar C0_LOCAL.
                                        If Empty(cArmazem)

                                            If Len(aReserva[nX]) >= 4		
                                                cArmazem := aReserva[nX][4] 	
                                            EndIf
                                        Else
                                        
                                            If Len(aReserva[nX]) >= 4		
                                                If cArmazem <> aReserva[nX][4]
                                                    lRet 	:= .F.
                                                    cMsgRet := I18n(STR0170, {AllTrim(cArmazem), cValToChar(aReserva[nX][4]),cValToChar(cCodResIt)})	//Armazém #1 retornado no de/para da tag (WarehouseInternalid) não é o mesmo armazém (C0_LOCAL) #2 da reserva numero: #3.
                                                    LjGrvLog("LOJI701", cMsgRet)	
                                                EndIf 	
                                            EndIf
                                        EndIf                                                                                

                                        // -- Armazena C0_FILIAL  + | + C0_NUM da reserva ja utilizada
                                        cNumRes += "'" + cC0FilRes + "|"+ cCodResIt + "',"
                                        
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
                                                    cMsgRet := aIdLoja[2]
                                                    LjGrvLog("LOJI701", aIdLoja[2])
                                                    Exit
                                                Endif
                                            Endif
                                        EndIf
                                    Next nX

                                    If !nQtdRes == nQuant
                                        lRet 	:= .F.
                                        cMsgRet := I18n(STR0142, {AllTrim(cValExt), cValToChar(nQtdRes),  cValToChar(nQuant)})	//"Reserva #1 - Já foi usada ou difere com a quantidade reservada #2 com a quantidade #3 recebida na TAG Quantity."
                                        LjGrvLog("LOJI701", cMsgRet)
                                        Exit												
                                    Endif
								Else
									lRet 	:= .F.
									cMsgRet := I18n(STR0143, {cValExt, cProduto})	//"Reserva #1 não existe para o produto #2"
									LjGrvLog("LOJI701", cMsgRet)
									Exit	
								EndIf																																																																																																																																											
							Else
								lRet 	:= .F.
								cMsgRet := I18n(STR0144, {"ITEMRESERVEINTERNALID", AllTrim(cValExt)})	//"Não foi encontrado de\para, para o #1 #2, verifique se a reserva foi integrada."
								LjGrvLog("LOJI701", cMsgRet)
								Exit
							EndIf
						EndIf									
						
						//Codigo da Reserva		
						If Empty(cCodResIt)
							If LjiOVldTag(oItens[nI], "ItemReserveCode","N") > 0
								cCodResIt := Padr(LjiOVldTag(oItens[nI], "ItemReserveCode"), TamSx3("C0_NUM")[1])																				
							EndIf
						EndIf
						
						//Valida Reserva pelo tipo de entrega para Itens do Tipo 3 e 4 
						If Empty(cCodResIt) .And. AllTrim(cTpEntrega) $ "3|4"
							lRet	:= .F.
							cMsgRet := I18n(STR0145, {"ITEMRESERVEINTERNALID\ITEMRESERVECODE", cValToChar(nI), "ITEMDELIVERYTYPE"})	//"Não foi informado o número da reserva (#1), para o item #2. Para #3 3 ou 4 a TAG é obrigatória."
							LjGrvLog("LOJI701", cMsgRet)
                            Exit
						EndIf

                        //Valor das Despesas Acessórias Proporcionalizadas
						If LjiOVldTag(oItens[nI], "IncreaseValueProrated","N")	> 0
							nVlrItDesp 	:= LjiOVldTag(oItens[nI], "IncreaseValueProrated", "N")
						Endif
						
						//As Tags de frete e Despesa proporcionalizadas passaram a ser enviadas à partir da versão 2.004
						//para adequação à forma de gravação do venda assistida.
						
						//Valor do Frete Proporcionalizado						
						If LjiOVldTag(oItens[nI], "FreightValueProrated","N") > 0
							nVlrItFrete	:= LjiOVldTag(oItens[nI], "FreightValueProrated", "N")		                                                        
						Endif

                        //Transportadora no item para o Projeto Omni                         
                        If lRet .And. Empty(cTransp)
                          
                            aAux := Lj701ITran( cMarca, nTypeTrans, LjiOVldTag(oItens[nI], "ItemCarrierCode"), LjiOVldTag(oItens[nI], "ItemCarrierInternalId") )
                            lRet := aAux[1]                       

                            If lRet
                                
                                If cFilres == oEAIObEt:getHeaderValue("BranchId")
                                    cTransp     := aAux[2]
                                    aCab[aScan(aCab,{|x| AllTrim(x[1]) == "LQ_TRANSP"})][2]  :=  cTransp
                                EndIf
                                cTranspItem := aAux[2]                                                           
                                cTransp := ""
                            Else
                                cMsgRet := aAux[2]
                                LjGrvLog("LOJI701", cMsgRet)
                            EndIf                            
                        
                        ElseIF !Empty(cTransp) .and. ( !Empty(LjiOVldTag(oItens[nI], "ItemCarrierCode")) .or. !Empty(LjiOVldTag(oItens[nI], "ItemCarrierInternalId")) )
                                                
                            cMsgRet := I18n(STR0174, {cDoc}) //"No documento #1 foi recebido mais de uma transportadora, onde apenas é permitido o recebimento no cabeçalho ou no item. Favor solicitar o ajuste do Json!"
                            LjGrvLog("LOJI701", cMsgRet)
                            lRet := .F.
                        EndIF
                      	
						LjGrvLog("LOJI701","GRAVA ARRAY AITEM DA VENDA: "+Time())																							
						/* Efetua a carga das tabela SLR */
						//Alimenta Array com Itens da Venda																							 						 									
						aAdd(aItem, {	{"LR_PRODUTO"	, cProduto			, Nil},;
                                        {"LR_DESCRI"	, SB1->B1_DESC		, Nil},;
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
										{"LR_VALICM"	, nSL2Icms			, Nil},; 
										{"LR_BASEICM"	, nBaseIcm			, Nil},;
										{"LR_PICM"		, nAliqIcm			, Nil},; 
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
										{"LR_POSIPI"  	, SB1->B1_POSIPI	, Nil},;
										{"LR_ICMSRET"  	, nSL2ValSol		, Nil}})    //O Valor de FECP-ST é somado no Valor de ICMS-ST pois o módulo Fiscal trata de forma Majorada
										
						If lL2FECP 
							Aadd(aItem[Len(aItem)], {"LR_VALFECP"	    , nValFECP	, Nil})
							Aadd(aItem[Len(aItem)], {"LR_ALQFECP"	    , nAlqFECP	, Nil})
							If lL2BASFECPST
								Aadd(aItem[Len(aItem)], {"LR_BASFECP"	, nBasFECP  , Nil})
							EndIf													
						EndIf
						
						If lL2FECPST
							Aadd(aItem[Len(aItem)], {"LR_VFECPST"	    , nValFECPST, Nil})
							Aadd(aItem[Len(aItem)], {"LR_ALQFCST"	    , nAlqFECPST, Nil})
							If lL2BASFECPST
								Aadd(aItem[Len(aItem)], {"LR_BSFCPST"	, nBasFECPST, Nil})
							EndIf	
						EndIf
						
						If lBaseIPI 
							Aadd(aItem[Len(aItem)], {"LR_BASEIPI"	, nSL2BasIpi    , Nil})
						EndIf

						If lAliqIPI 
							Aadd(aItem[Len(aItem)], {"LR_IPI"		, nSL2AlqIpi	, Nil})
						EndIf
						
						If lAliqSOL 
							Aadd(aItem[Len(aItem)], {"LR_ALIQSOL"	, nSL2AlqSol	, Nil}) 
						EndIf
		
						If !Empty(cDataEntr)
							Aadd(aItem[len(aItem)], {"LR_FDTENTR"  	, cDataEntr		, Nil})
						Endif

						If !Empty(cLoteItem)
							LjGrvLog("LOJI701","IDENTIFICOU LOTE:"+cLoteItem)
							Aadd(aItem[len(aItem)], {"LR_LOTECTL"	, cLoteItem		, Nil})
							Aadd(aItem[len(aItem)], {"LR_NLOTE"	    , cSubLoteItem  , Nil})
							If !Empty(cSerieItem)
								Aadd(aItem[len(aItem)], {"LR_NSERIE", cSerieItem    , Nil})
							Endif													
						Endif

						If !Empty(cAddresItem)
							Aadd(aItem[len(aItem)], {"LR_LOCALIZ"	, cAddresItem	, Nil})
						EndIf

                        If !Empty(cTranspItem) .and. SLR->(FieldPos("LR_TRANSP") > 0) //Inclusão de transportadora no item
							Aadd(aItem[len(aItem)], {"LR_TRANSP"	, cTranspItem	, Nil})
						EndIf
										
					Else
						//Trata gravacao de itens cancelados																																																
						aAdd(aCancItem, { {"LX_FILIAL"	, xFilial("SL1")},;
							{"LX_OPERADO" 	, cOperador		},;
							{"LX_DTMOVTO" 	, dDataBase		},;
							{"LX_CUPOM" 	, cDoc			},;
							{"LX_SERIE"		, cSerie		},;
							{"LX_HORA" 		, Time()		},;
							{"LX_PDV"		, cPdv			},;
							{"LX_ITEM"		, cItem			},;
							{"LX_TPCANC"	, "I"			},;
							{"LX_VALOR"  	, nVlrItem		},;
							{"LX_PRODUTO"	, cProduto		},;
							{"LX_QTDE"		, nQuant		},;
							{"LX_DESCON"	, nValItDesc	},;
							{"LX_ALIQICM"	, nAliqIss		},;
							{"LX_SUPERVI"	, "PDV BEMATECH"},;
							{"LX_SITUACA"	, "00"			}})
					EndIf

                    If Len(aReserva) > 1 .and. ExistFunc("Loji701OItens")                
                        aItem := Loji701OItens(aItem, aReserva, nVlMercTot, nFrete, nValDesTot)
                    EndIF

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
					cArmazem		:= "" // -- Limpeza da variavel que garda o armazem do item, variavel especifica por item.							
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
				Next nI
				cNumRes := ""
			EndIf

            //Chama função para cálculo reverso de impostos que possam alterar o valor final da venda
            If lCalcImp
                If ExistFunc("LjTaxEAI")
                    LjTaxEAI(@aCab, @aItem)
                Else
                    lRet    := .F.
                    cMsgRet := I18n(STR0151, {"LjTaxEAI", "RPO"})   //"Função #1 não existe, atualize o #2 para que o cálculo de impostos seja efetuado."
                    LjGrvLog("LOJI701", cMsgRet)
                EndIf
            EndIf

			//Verifica se continua a gravacao da venda
			If lRet

				//Pega posição dos campos que podem sofrer atualização
				nPosDescon	:= Ascan(aCab	 , {|x| AllTrim(x[1]) == "LQ_DESCONT"}	)
                nPosVlrMer  := Ascan(aCab	 , {|x| AllTrim(x[1]) == "LQ_VALMERC"}	)
                nPosValIpi  := Ascan(aCab	 , {|x| AllTrim(x[1]) == "LQ_VALIPI" }	)
                nPosFrete   := Ascan(aCab	 , {|x| AllTrim(x[1]) == "LQ_FRETE"  }	)
				nPosItem 	:= Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_ITEM"   }  )
				nPosQuant 	:= Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_QUANT"  }	)
				nPosVlrUni 	:= Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_VRUNIT" }	)
				nPosVlrIte 	:= Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_VLRITEM"}	)
				nPosDescPro := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_DESCPRO"}	)
				nPosBasIcm  := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_BASEICM"}	)
                nPosValFre  := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_VALFRE"}	)
                nPosPrcTab  := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_PRCTAB"}	)
                nPosVlrTot  := aScan(aCab    , {|x| AllTrim(x[1]) == "LQ_VLRTOT"}   )
                nPosValDes  := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_DESPESA"}	)
				
				//Tratamento para arredondamento dos itens quando existe desconto no total
				If nValDesTot > 0
					
					If nTotDesPro > 0

						//Se estiver enviando o Desconto Total Proporcionalizado (tag DiscountTotalProrated), verifica se o somatorio esta de acordo com o Desconto Total enviado tambem
						If nValDesTot <> nTotDesPro
							lRet 	 := .F.
							cMsgRet := STR0124 + " DiscountTotalProrated " + STR0125 //"A somatoria do Desconto Total Proporcionalizado por item da tag <DiscountTotalProrated> está diferente do Desconto Total da tag <DiscountValue>."
                            LjGrvLog("LOJI701", cMsgRet)
						EndIf
					Else

						//Se Total da Venda maior que acumulado dos itens, cuidando que seja apenas 1 centavo 
						//ajusta desconto devido diferenca de arredondamento no desconto proporcional
						If nVlrTot > nVlrItTot .And. nVlrTot - nVlrItTot == 0.01
							aItem[Len(aItem)][nPosDescPro][2] -= 0.01

						//Se Total da Venda menor que acumulado dos itens, cuidando que seja apenas 1 centavo 
						//ajusta desconto devido diferenca de arredondamento no desconto proporcional
						ElseIf nVlrTot < nVlrItTot .And. nVlrItTot - nVlrTot == 0.01
							aItem[Len(aItem)][nPosDescPro][2] += 0.01
						EndIf
					EndIf
				EndIf
			
				// -------------------------------------------------------------------------------------------------------------------------------------------------------------------
				// BLOCO DOS PAGAMENTOS
				// -------------------------------------------------------------------------------------------------------------------------------------------------------------------

				//PROCESSOS SÓ DEVEM ACONTECER CASO GEREM FINANCEIRO
				//Valida se forma de pagamentos foram enviados
				If oEAIObEt:getPropValue("ListOfSaleCondition") != Nil	.And. oEAIObEt:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition") <> NIL
					oPgtos := oEAIObEt:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")
				Else
					lRet 	 := .F.
					cMsgRet := STR0043 //#"Lista de Forma de Pagamentos vazia, verifique a lista SaleCondition."
                    LjGrvLog("LOJI701", cMsgRet)
				EndIf
			
				If lRet
					//Valida se lista esta vazia
					If oPgtos <> Nil .And. Len(oPgtos) == 0
						lRet 	 := .F.
						cMsgRet := STR0043 //#"Lista de Forma de Pagamentos vazia, verifique a lista SaleCondition."
                        LjGrvLog("LOJI701", cMsgRet)
					EndIf
				EndIf
			
				If lRet

					For nI := 1 To Len(oPgtos)

                        //Carrega informações dos pagamentos
   						cFormaId := ""
                        nVlrPag  := LjiOVldTag(oPgtos[nI], "PaymentValue", "N")
						cNsu     := LjiOVldTag(oPgtos[nI], "UniqueSerialNumber")
						cAutoriz := LjiOVldTag(oPgtos[nI], "EftAutorization")

                        //Acumula valor total de pagamentos
                        nVlrPagTot += nVlrPag

                        //Armazena Forma de Pagamento
                        cFormaPg := ""
                        cAux     := LjiOVldTag(oPgtos[nI], "PaymentMethodInternalId", "C")
                        If !Empty(cAux)
                            cFormaPg := Lji070TiPa(cMarca, cAux, .F.,@cMsgRet)
                        EndIf

                        cAux := LjiOVldTag(oPgtos[nI], "PaymentMethodCode", "C")
                        If Empty(cFormaPg) .And. !Empty(cAux)
                            cFormaPg := Lji070TiPa(cMarca, cAux, .T.,@cMsgRet)
                        EndIf

                        //Armazena a Condição de Pagamento quando não tem a forma de pagamento
						If Empty(cFormaPg)

							cCondpg := LjiOVldTag(oPgtos[nI], "PaymentTermCodeInternalID","C")							
							If Empty(AllTrim(cCondpg))
								//Busca De/Para da Adm Financeira na Tabela XXF
								cValInt :=  CFGA070INT(cMarca , "SE4", "E4_CODIGO", cCondpg)
							
								If !Empty(cValInt)					
									aAux := Separa(cValInt, "|")
										
									If ValType(aAux) == "A" .And. Len(aAux) > 2 
										cCondpg := aAux[3]
									EndIf
								Else
									cCondpg := LjiOVldTag(oPgtos[nI], "PaymentTermCode", "C")
								EndIf									
		
								cCondpg := Padr(cCondpg, TamSx3("E4_CODIGO")[1])
										
								//Posiciona na Cond. de Pagamento para pegar à forma de Pagamento
								SE4->(DbSetOrder(1))
								If !Empty(cCondpg) .And. SE4->( DbSeek(xFilial("SE4") + cCondpg) )
									If !Empty(Alltrim(SE4->E4_FORMA))
										cFormaPg := Alltrim(SE4->E4_FORMA) 
									Endif								
																				
									aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_CONDPG"})][2]  :=  cCondpg
									aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_ENTRADA"})][2] :=  0		

								Else
								
									lRet    := .F.
									cMsgRet += STR0044 +  " " + CValToChar(nI) + "," + STR0047 + AllTrim(cFormaPg) + " " + STR0048 + Chr(10)    //#"Inconsistencia na forma de pagamento" ##"Forma de Pagamento:" ###"nao encontrado no Protheus."
									cMsgRet += STR0049                                                                                          //#"Verifique o cadastro de Forma de Pagamento."
                                    LjGrvLog("LOJI701", cMsgRet)
									Exit
								EndIf
							EndIf
						EndIf
							
						//Posiciona na Forma de Pagamento do Protheus
						SX5->(dbSetOrder(1))
							
						If Empty(cFormaPg) .Or. !SX5->(dbSeek(xFilial("SX5") + "24"  + cFormaPg))
							lRet    := .F.
							cMsgRet += STR0044 +  " " + CValToChar(nI) + "," + STR0047 + AllTrim(cFormaPg) + " " + STR0048 + Chr(10) //#"Inconsistencia na forma de pagamento" ##"Forma de Pagamento:" ###"nao encontrado no Protheus."
							cMsgRet += STR0049 //#"Verifique o cadastro de Forma de Pagamento."
                            LjGrvLog("LOJI701", cMsgRet)
							Exit
						EndIf
					
						//Armazena Administradora Financeira																				
						cAdmFin := LjiOVldTag(oPgtos[nI], "FinancialManagerCode","C")

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
							
						If !Empty(cAdmFin) 	
							If SAE->(dbSeek(xFilial("SAE") + cAdmFin))
								cAdmFin := SAE->AE_COD + "-" + AllTrim(SAE->AE_DESC)
							Else
								lRet	:= .F.
								cMsgRet := STR0044 + " " + CValToChar(nI) + "," + STR0050 + " FinancialManagerCode "  //#"Inconsistencia na forma de pagamento" ##"Administradora Financeira invalida ou nao encontrada no dePara no Protheus."
                                LjGrvLog("LOJI701", cMsgRet)
								Exit
							EndIf
						EndIf
							
						//Tratamento para Gravação do Código do Banco
						If AllTrim(cFormaPg) == "CH"
							cBanck  := LjiOVldTag(oPgtos[nI], "BankCheck")
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
								cMsgRet := "Nao existe amarração De/Para para o Banco: "+cBanck 
                                LjGrvLog("LOJI701", cMsgRet)
								Exit
							Endif
						Endif							
						//Inicializa InternalId do RA a ser compensado
						cIntIdRA := ""
							
						//Validacoes de campos obrigatorios
                        If nVlrPag <= 0
							lRet 	:= .F.
							cMsgRet := STR0044 + " " + CValToChar(nI) + "," + STR0052 //#"Inconsistencia na forma de pagamento" ##"Valor do Pagamento nao informado na integracao, verifique a tag: PaymentValue."
                            LjGrvLog("LOJI701", cMsgRet)
							Exit

                        //Informacoes compensacao titulo hotelaria                            
						ElseIf AllTrim(cFormaPg) == "RA"
							cIntIdRA := LjiOVldTag(oPgtos[nI], "AccountReceivableDocumentInternalid")
								
							If Empty(cIntIdRA)
								lRet 	 := .F.
								cMsgRet := STR0044 + " " + CValToChar(nI) + "," + STR0066 + Chr(10) //#"Inconsistencia na forma de pagamento" ##"InternalId do RA nao informado"
								cMsgRet += STR0067 //#"Esta informacao e obrigatoria para pagamentos RA, verifique a tag: AccountReceivableDocumentInternalId"
                                LjGrvLog("LOJI701", cMsgRet)
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
											cMsgRet := STR0044 + " " + CValToChar(nI) + "," + STR0086 + ":" + AllTrim(cIntIdRA) + " " + STR0092 + Chr(10) ////#"Inconsistencia na forma de pagamento" ##"O titulo de adiantamento" ###"encontra-se baixado"
											cMsgRet += STR0093 //#"Necessário desfazer a compensação no financeiro."
                                            LjGrvLog("LOJI701", cMsgRet)
										EndIf
									Else
										lRet 	 := .F.
										cMsgRet := STR0044 + " " + CValToChar(nI) + "," + STR0086 + ":" + AllTrim(cIntIdRA) + " " + STR0089 + Chr(10) //#"Inconsistencia na forma de pagamento" ##"O titulo de adiantamento" ###"nao foi encontrado na base de dados Protheus"
										cMsgRet += STR0087 //#"Verifique a tag: AccountReceivableDocumentInternalId"
                                        LjGrvLog("LOJI701", cMsgRet)
									EndIf
								Else
									lRet 	 := .F.
									cMsgRet := STR0044 + " " + CValToChar(nI) + "," + STR0086 + ":" + AllTrim(cIntIdRA) + " " + STR0088 + Chr(10) //#"Inconsistencia na forma de pagamento" ##"O titulo de adiantamento" ###"nao foi integrado ao Protheus"
									cMsgRet += STR0087 //#"Verifique a tag: AccountReceivableDocumentInternalId"
                                    LjGrvLog("LOJI701", cMsgRet)
								EndIf
							EndIf
						EndIf

                        //Valida tamanho da TAG UniqueSerialNumber
                        If Ascan(aTamNsu, {|x| Len(cNsu) > x }) > 0
                            lRet    := .F.
                            cMsgRet += CRLF + I18n(STR0149, {"L1_NSUTEF, L4_NSUTEF, LQ_NSUTEF e E1_NSUTEF"})    //"O conteúdo da TAG UniqueSerialNumber é maior que o suportado pelos campos #1, verifique!"
                            LjGrvLog("LOJI701", cMsgRet)
                        EndIf

                        If !lRet
                            Exit
                        EndIf
							
						//Armazena Data do Pagamento
						cDataPgto := LjiOVldTag(oPgtos[nI], "DateOfPayment", "D")
							
						If Empty(cDataPgto)
							cDataPgto := cEmissao
						EndIf
							
						//Armazena Data de Pagamento
						dDataPagto	 := SToD(cDataPgto)
							
						//Informacoes TEF	
						cL4HoraTef 	:= LjiOVldTag(oPgtos[nI], "EftDate", "T")             //Hora Tef SL4
						cL4HoraTef  := AllTrim(StrTran(cL4HoraTef, ":", ""))
							
						cL4HrCanTef	:= LjiOVldTag(oPgtos[nI], "EftCancellationDate", "T") //Data de Cancelamento Tef SL4
						cL4HrCanTef	:= AllTrim(StrTran(cL4HrCanTef, ":", ""))
												
						//Verifica utilizacao de Tef
						lTef := !Empty( LjiOVldTag(oPgtos[nI], "EftDate", "D") )
							
						//Incrementa Item Tef
						If lTef
							nItemTef ++

                            //Esta validacao eh necessaria pois SL1 grava apenas a parcela 1 do TEF
							If nItemTef == 1
								
                                //Armazena informacoes TEF para SL1
								cL1VendTef	:= "S"                                                  //Venda Tef SL1
								cL1DataTef	:= LjiOVldTag(oPgtos[nI], "EftDate", "D")               //Data Tef SL1
								cL1HoraTef	:= LjiOVldTag(oPgtos[nI], "EftDate", "T")               //Hora Tef SL1
								cL1HoraTef  := AllTrim(StrTran(cL1HoraTef, ":", ""))
								cL1DocTef	:= LjiOVldTag(oPgtos[nI], "EftDocument")                //Documento Tef Sl1
								cL1Autoriz	:= LjiOVldTag(oPgtos[nI], "EftAutorization")            //Autorizacao Tef SL1
								cL1DocCanc	:= LjiOVldTag(oPgtos[nI], "EftCancellationDocument")    //Documento de Cancelamento Tef SL1
								cL1DatCanc	:= LjiOVldTag(oPgtos[nI], "EftCancellationDate", "D")   //Data de Cancelamento Tef SL1
								cL1HorCanc	:= LjiOVldTag(oPgtos[nI], "EftCancellationDate", "T")   //Hora Cancelamento Tef SL1
								cL1HorCanc  := AllTrim(StrTran(cL1HorCanc, ":", ""))
								cL1Institu	:= LjiOVldTag(oPgtos[nI], "EftInstitute")               //Instituro Tef SL1
							EndIf
						EndIf

                        //Carrega o primeiro NSU dos pagamentos
                        //Pode ser utilizado por formas de pagamento que não tenham TEF, atualmente caso do MarketPlace e-Commerce
                        If Empty(cL1NsuTef)
                            cL1NsuTef := cNsu
                        EndIf
                        
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
						//Tag que define a qtde de parcelas de uma forma de pagamento
						nQtdeParc := LjiOVldTag(oPgtos[nI], "Installments", "N")
						aLj7CalcPgt := {}
						If nQtdeParc > 1 .And. !(IsMoney(AllTrim(cFormaPg)) .Or. (AllTrim(cFormaPg) == "RA"))
							Aadd(aCab, {"LQ_PARCELA",  nQtdeParc, Nil})
							LjGrvLog( "LOJI701", " Adição do campo  LQ_PARCELA no cabeçalho da venda " )

							LjGrvLog( "LOJI701", " Antes da chamada da função Lj7CalcPgt " )
							aLj7CalcPgt := Lj7CalcPgt( nVlrPag , "CN" , {"1- Simples",SToD(cEmissao),0,0,nQtdeParc,30/*Num Dias*/,.F.,.F.},,;
														,,,,,,,,cFormaPg,,,,,,, .T. )
							LjGrvLog( "LOJI701", " Depois da chamada da função Lj7CalcPgt ", aLj7CalcPgt )
						Else
							nQtdeParc := 1
						EndIf

						For nX := 1 to nQtdeParc

							If Len(aLj7CalcPgt) > 0
								dDataPagto := aLj7CalcPgt[nX][1]
								nVlrPag := aLj7CalcPgt[nX][2]
							EndIf

							//Alimenta array de Pagamentos						       		   		      		      							
							aAdd(aParcela, {    {"L4_DATA"      , dDataPagto									  	        , Nil},;
												{"L4_VALOR"  	, nVlrPag                                      				, Nil},;
												{"L4_FORMA"  	, cFormaPg													, Nil},;
												{"L4_ADMINIS"	, cAdmFin	 												, Nil},;
												{"L4_NUMCART"	, LjiOVldTag(oPgtos[nI], "CardNumber")						, Nil},;
												{"L4_SERCHQ"    , LjiOVldTag(oPgtos[nI], "SerieCheck") 						, Nil},;
												{"L4_AGENCIA"	, LjiOVldTag(oPgtos[nI], "AgencyCheck")  					, Nil},;
												{"L4_CONTA"	    , LjiOVldTag(oPgtos[nI], "AccountCheck")  					, Nil},;
												{"L4_RG"		, LjiOVldTag(oPgtos[nI], "DocumentOfIdentification")		, Nil},;
												{"L4_TELEFON"	, LjiOVldTag(oPgtos[nI], "PhoneNumber") 					, Nil},;
												{"L4_TERCEIR"	, "F"      													, Nil},;
												{"L4_FORMAID"   , cFormaId       											, Nil},;
												{"L4_DATATEF"	, LjiOVldTag(oPgtos[nI], "EftDate", "D")					, Nil},;
												{"L4_HORATEF"	, cL4HoraTef												, Nil},;
												{"L4_DOCTEF" 	, LjiOVldTag(oPgtos[nI], "EftDocument")						, Nil},;
												{"L4_AUTORIZ"	, LjiOVldTag(oPgtos[nI], "EftAutorization")					, Nil},;
												{"L4_DATCANC"   , LjiOVldTag(oPgtos[nI], "EftCancellationDate", "D")		, Nil},;
												{"L4_HORCANC"	, cL4HrCanTef												, Nil},;
												{"L4_DOCCANC"   , LjiOVldTag(oPgtos[nI], "EftCancellationDocument")			, Nil},;
												{"L4_INSTITU"   , LjiOVldTag(oPgtos[nI], "EftInstitute")					, Nil},;
												{"L4_NSUTEF"    , cNsu														, Nil},;
												{"L4_MOEDA"     , nMoeda													, Nil},;
												{"L4_PARCTEF"   , LjiOVldTag(oPgtos[nI], "EftParcel")						, Nil},;
												{"L4_VENDTEF"   , IIF(lTef, "S", "N")										, Nil},;
												{"L4_CONHTL" 	, cRecRa													, Nil},;
												{"L4_IDCNAB"    , LjiOVldTag(oPgtos[nI], "FinancialDocumentCode")           , Nil}  }   )
						Next nX
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
				aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_DOCCANC"})][2] := cL1DocCanc	 //Documento de Cancelamento Tef SL1
				aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_DATCANC"})][2] := cL1DatCanc	 //Data de Cancelamento Tef SL1
				aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_HORCANC"})][2] := cL1HorCanc	 //Hora Cancelamento Tef SL1
				aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_INSTITU"})][2] := cL1Institu	 //Instituro Tef SL1
				aCab[aScan(aCab, {|x| AllTrim(x[1]) == "LQ_NSUTEF"})][2]  := cL1NsuTef	 //Nsu Tef SL1

                LjGrvLog( "LOJI701", "Documento: " + cDoc + " - Valor do Calculo Reverso. Valor Mercado: " + cValtoChar(aCab[nPosVlrMer][2]) + " Valor IPI: " + cValtoChar(aCab[nPosValIpi][2]) + "Valor Frete: " + cValtoChar(aCab[nPosFrete][2]) + " Valor Desconto: " + cValtoChar(aCab[nPosDescon][2]) + "Valor Recebido Json: " + cValtoChar(nVlrLiq) ) 

                //Somente irá realizar toda essa tratativa de Calculo reverso de IPI se o parametro MV_LJTDESI estiver ligado
                //Validando se existe diferença de total recebido pelo Json Vtex para a soma de Valor de Mercado + IPI + Frete
                If SuperGetMv("MV_LJTDESI", , 0) == 1 .and. ((aCab[nPosVlrMer][2] + aCab[nPosValIpi][2] + aCab[nPosFrete][2]) - aCab[nPosDescon][2]) <> nVlrLiq                
                    LjGrvLog( "LOJI701", " Valor Liquido do Orçamento - Produto com IPI" ) 
                    
                    IF (SuperGetMv("MV_LJATIPI", , .F.) == .T.) .and. (SuperGetMv("MV_LJDTIPI", , .F.) == .T.)
                        If aCab[nPosValIpi][2] > 0
                            nValDifPed := (((aCab[nPosVlrMer][2] + aCab[nPosValIpi][2] + aCab[nPosFrete][2]) - aCab[nPosDescon][2])- nVlrLiq)

                            LjGrvLog( "LOJI701", " Valor da Diferença do Orçamento - Calculo Reverso do IPI", nValDifPed ) 
                                    
                            If (nValDifPed < 0.50) .and. (nValDifPed > -0.50)
                                If nValDifPed > 0 
                                    If aCab[nPosFrete][2] > 0 
                                        aCab[nPosFrete][2] := (aCab[nPosFrete][2] - nValDifPed)
                                        aItem[Len(aItem)][nPosValFre][2] := (aItem[Len(aItem)][nPosValFre][2] - nValDifPed)
                                    Else
                                        aCab[nPosDescon][2] := (aCab[nPosDescon][2] + Abs(nValDifPed))
                                    EndIf
                                Else
                                    aCab[nPosFrete][2] := (aCab[nPosFrete][2] + Abs(nValDifPed))
                                    aItem[Len(aItem)][nPosValFre][2] := (aItem[Len(aItem)][nPosValFre][2] + Abs(nValDifPed))   
                                EndIf
                                LjGrvLog( "LOJI701", "Documento: " + cDoc + " Valores Ajustados - Calculo Reverso IPI. Valor Frete: " + cValtoChar(aCab[nPosFrete][2]) + " Valor Desconto: " + cValtoChar(aCab[nPosDescon][2]) ) 
                            Else
                                cMsgRet := STR0171 //O calculo reverso de IPI gerou uma diferença maior que 0.50 entre o total pago e o valor de pedido. Os ajustes de arredondamentos de calculo reverso são limitados em R$ 0.50 centavos. Será necessario a abertura de chamado com os dados desse pedido para analise.
                                LjGrvLog( "LOJI701", STR0171,  nValDifPed )
                                ofwEAIObj:Activate()
	                            ofwEAIObj:setProp("ReturnContent")
                                ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cMsgRet) 
                                Return { .F., ofwEAIObj ,"RETAILSALES"}
                            EndIF
                        EndIf
                    Else
                        cMsgRet := STR0172
                        LjGrvLog( "LOJI701", STR0172 )
                        ofwEAIObj:Activate()
                        ofwEAIObj:setProp("ReturnContent")
                        ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cMsgRet) 
                        Return { .F., ofwEAIObj ,"RETAILSALES"}
                    EndIf
                EndIF

				dDataBkp  := dDataBase      //Salva data atual
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
						For nI := 1 To Len(aErroAuto)
							cMsgRet += aErroAuto[nI] + Chr(10)
                            LjGrvLog("LOJI701", cMsgRet)
						Next nI
											
						If Len(aErroAuto) == 0
							cMsgRet := STR0025 + " " + AllTrim(cIdExt) //#"Erro na gravacao da venda: "
                            LjGrvLog("LOJI701", cMsgRet)
						EndIf
					
						LjGrvLog("LOJI701","ERRO EXECAUTO: "+ cMsgRet ,, .T.)
							
						//Monta Erro de execução da rotina automatica
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
									LjGrvLog("LOJI701","Gerou DE/PARA corretamente.")
								Else
									LjGrvLog("LOJI701","ID_ERRO ")
									LjGrvLog("LOJI701","Não gerou DE/PARA. ")	
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
										MH4->MH4_ITEM   := FR271BPegaIT(aItemMh4[nI][3])
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
								cMsgRet := STR0025 + " " + AllTrim(cIdExt) //#"Erro na gravacao da venda: "
                                LjGrvLog("LOJI701", cMsgRet)
							EndIf
						Else
							lRet 	 := .F.
							cMsgRet := STR0025 + " " + AllTrim(cIdExt) //#"Erro na gravacao da venda: "
                            LjGrvLog("LOJI701", cMsgRet)
						EndIf
					EndIf
				End Transaction
			
				//Apos efetuar a transação efetuamos um doublecheck para saber se a venda está realmente gravado na base 
				//e se não existir deleta o De\Para(Caso Exista) para evitar inconsistencia de base.
				//Esse ajuste foi necessario pois o execauto do LOJA701 nao trata todos cenarios de erros possiveis. E pode ter vendas não gravadas e o execauto nao retornou erro.						
				SL1->(DbSetOrder(2))	//SL1 L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
				If lRet .And. !SL1->(DbSeek(xFilial("SL1")+cSerie+cDoc+cPdv))
					SL1->(DbSetOrder(11))//SL1 L1_FILIAL+L1_SERPED+L1_DOCPED				
					If !SL1->(DbSeek(xFilial("SL1")+cSerie+cDoc))
						CFGA070Mnt(cMarca, "SL1", "L1_DOC", cIdExt, cValInt, .T. /*Delete*/)
						lRet    := .F.
						cMsgRet += " | " + STR0025 + " " + AllTrim(cIdExt) + " | DBCHK." //#"Erro na gravacao da venda: "
						LjGrvLog("LOJI701",STR0025 + " " + AllTrim(cIdExt) + " | DBCHK.")
					EndIf	 
				Endif 
			
				dDataBase := dDataBkp //Restaura Database
			EndIf
		
        //Evento de Atualizacao
        ElseIf nOpcX == 2
            
            //Hotelaria 
			If lIntegHtl

				//Armazena codigo da reserva que sera alterado
				cReserva := LjiOVldTag( oEAIObEt:getPropValue("BookingInformation") , "HotelAccountCode", "C") //Numero da Reserva
				cSerie   := Padr(aAux[2][3], TamSx3("L1_SERIE")[1])
				cDoc 	 := Padr(aAux[2][4], TamSx3("LQ_DOC")[1])
				cPdv 	 := Padr(aAux[2][5], TamSx3("LQ_PDV")[1])
				
				SL1->(dbSetOrder(2))
				SL1->(dbSeek(xFilial("SL1") + cSerie + cDoc + cPdv))
											
				SL1->(RecLock("SL1", .F.))
				SL1->L1_RESEHTL := cReserva
				SL1->(MsUnLock())
									
				//Armazena InternalId do Protheus
				cValInt := IntVendExt(cEmpAnt, SL1->L1_FILIAL, SL1->L1_SERIE, SL1->L1_DOC, SL1->L1_PDV)[2]
			Else

				lRet    := .F.
				cMsgRet := STR0022 + " " + AllTrim(cIdExt) + " " + STR0023  //#"Cupom:" ##" ja integrado no Protheus"
                LjGrvLog("LOJI701", cMsgRet)
			EndIf
		EndIf
	EndIf

	//Tratamento para evitar retorno incorreto
	If Empty(cIdExt) .Or. Empty(cValInt)
		lRet	:= .F.
		cMsgRet := IIF( Empty(cMsgRet), STR0025 + " " + AllTrim(cIdExt), cMsgRet)	//#"Erro na gravacao da venda:"
        LjGrvLog("LOJI701", cMsgRet)
	EndIf

	ofwEAIObj:Activate()
	ofwEAIObj:setProp("ReturnContent")
	If lRet

		ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)      
		ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:setProp("Name","RETAILSALES")
		ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:setProp("Origin",      	cIdExt)
		ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:setProp("Destination",  cValInt)

	Else
		// -- Tratamento para evitar erros de comparação
		IIf(Empty(cValInt),IIf(Valtype(aDoc[1]) == "L" .AND. aDoc[1],cValInt := IntVendExt(aDoc[2][1],aDoc[2][2],aDoc[2][3],aDoc[2][4],aDoc[2][5])[2],Nil),Nil)

		cJsonRet := '{' + '"InternalId":"' 	+ cValInt + '",' + '"ExternalId":"' 	+ cIdExt  + '",' + '"Message":"' 		+ cMsgRet + '"' + '}'

		
		ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cJsonRet)        
	EndIf

ElseIf nTypeTrans == TRANS_RECEIVE .And. cTypeMessage == EAI_MESSAGE_RESPONSE .And. ValType( oEAIObEt ) == 'O'

	//Altera informacoes para cancelamento		   	
	lCancVen := LjiVendCanc()

	//Inclusao de Venda ativa
	If !lCancVen
		cAlias	:= "SL1" //Tabela De-Para
		cCampo	:= "L1_DOC" //Campo De-Para
	Else //Inclusao Venda cancelada
		cAlias := "SLX" //Tabela De-Para
		cCampo := "LX_CUPOM" //Campo De-Para
	EndIf

	// Se não houve erros na resposta
	If Upper(oEAIObEt:getPropValue("ProcessingInformation"):getPropValue("Status")) == "OK"  
		// Verifica se a marca foi informada
		cMarca := oEAIObEt:getHeaderValue("ProductName")
		If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )  .AND. ValType(cMarca) = "C" 
			cMarca := oEAIObEt:getHeaderValue("ProductName")
		Else
			lRet 	:= .F.
			cMsgRet += I18n(STR0146, {"PRODUCTNAME"}) + CRLF	//"Erro no retorno, a TAG #1 é obrigatória."
            LjGrvLog("LOJI701", cMsgRet)
		EndIf

		If lRet .and. oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID") !=  nil 

			// Verifica se o código interno foi informado
			If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin") != nil 
				cValInt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin")
			Else
				lRet	:= .F.
				cMsgRet += I18n(STR0146, {"RETURNCONTENT:LISTOFINTERNALID:ORIGIN"}) + CRLF	//"Erro no retorno, a TAG #1 é obrigatória."
                LjGrvLog("LOJI701", cMsgRet)
			EndIf

			// Verifica se o código externo foi informado
			If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination") != nil
				cValExt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination")
			Else
				lRet := .F.
				ofwEAIObj:Activate()
				cMsgRet += STR0023 + CRLF // "Erro no retorno. O DestinationInternalId é obrigatório"
                LjGrvLog("LOJI701", cMsgRet)
			EndIf
			
			cEvent := oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event")
			
			If cEvent != NIL
				cEvent := AllTrim(Upper(cEvent))
			EndIf

			If !Empty(cValExt) .And. !Empty(cValInt)
				If CFGA070Mnt(cMarca, cAlias, cCampo, cValExt, cValInt, (cEvent = "DELETE"))
					lRet := .T.
				EndIf
			Else
				lRet := .F.
				cMsgRet += STR0147 + CRLF	//"Evento do retorno inválido."
                LjGrvLog("LOJI701", cMsgRet)
			EndIf
		Endif
	Else
		cMsgRet := ""
		If oEAIObEt:getpropvalue('ProcessingInformation') != nil
			oMsgError := oEAIObEt:getpropvalue('ProcessingInformation'):getpropvalue("Details")
			For nX := 1 To Len( oMsgError )
				cMessage := oMsgError[nX]:getpropvalue('Message')
				If cMessage != NiL .AND. ValType(cMessage) == "C"
					cMsgRet += cMessage + CRLF
                    LjGrvLog("LOJI701", cMsgRet)
				EndIf
			Next nX
		Endif

		lRet := .F.
	EndIf

	If !lRet
		ofwEAIObj:Activate()
		ofwEAIObj:setProp("ReturnContent")
		ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cMsgRet)
        LjGrvLog("LOJI701", cMsgRet)
	EndIf
	
ElseIf nTypeTrans == TRANS_SEND .And. ValType( oEAIObEt ) == 'O'

	cEvent   := "upsert" //Evento

	ofwEAIObj:Activate()
	ofwEAIObj:setEvent(cEvent)

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

		//Cabecalho da Venda
		ofwEAIObj:setProp("Event"            			,cEvent)		
		ofwEAIObj:setProp("CompanyId"        			,cEmpAnt)
		ofwEAIObj:setProp("BranchId"         			,cFilAnt)
		ofwEAIObj:setProp("CompanyinternalId"			,cEmpAnt + '|' + cFilAnt )
		ofwEAIObj:setProp("InternalId"       			,cValInt )
		ofwEAIObj:setProp("SellerInternalId"       		,cVendInt 										)
		ofwEAIObj:setProp("ComissionPercent"       		,CValToChar(SL1->L1_COMIS) 						)
		ofwEAIObj:setProp("CustomerVendorInternalId"	,cCliInt 										)
		ofwEAIObj:setProp("TotalPrice"   	    		,CValToChar(SL1->L1_VLRTOT) 					)
		ofwEAIObj:setProp("DiscountValue"       		,CValToChar(SL1->L1_DESCONT) 					)
		ofwEAIObj:setProp("IncreaseValue"       		,CValToChar(SL1->L1_SEGURO + SL1->L1_DESPESA) 	)
		ofwEAIObj:setProp("FreightValue"       			,CValToChar(SL1->L1_FRETE) 						)
		ofwEAIObj:setProp("NetPrice"       				,CValToChar(SL1->L1_VLRLIQ) 					)
		ofwEAIObj:setProp("CashValue"       			,CValToChar(SL1->L1_DINHEIR) 					)
		ofwEAIObj:setProp("ChecksValue"       			,CValToChar(SL1->L1_CHEQUES) 					)
		ofwEAIObj:setProp("CardsValue"       			,CValToChar(SL1->L1_CHEQUES) 					)
		ofwEAIObj:setProp("DebitValue"       			,CValToChar(SL1->L1_VLRDEBI) 					)
		ofwEAIObj:setProp("CovenantValue"       		,CValToChar(SL1->L1_CONVENI) 					)
		ofwEAIObj:setProp("VouchersValue"       		,CValToChar(SL1->L1_VALES) 						)
		ofwEAIObj:setProp("FinancedValue"       		,CValToChar(SL1->L1_FINANC) 					)
		ofwEAIObj:setProp("OthersValue"       			,CValToChar(SL1->L1_OUTROS) 					)
		ofwEAIObj:setProp("InputValue"       			,CValToChar(SL1->L1_ENTRADA) 					)
		ofwEAIObj:setProp("IssueDateDocument"       	,cEmissao 										)
		ofwEAIObj:setProp("DocumentCode"       			,RTrim(SL1->L1_DOC) 							)
		ofwEAIObj:setProp("SerieCode"       			,RTrim(SL1->L1_SERIE) 							)
		ofwEAIObj:setProp("GrossPrice"       			,CValToChar(SL1->L1_VALBRUT) 					)
		ofwEAIObj:setProp("CommodityPrice"       		,CValToChar(SL1->L1_VALMERC) 					)
		ofwEAIObj:setProp("DiscountPercent"       		,CValToChar(SL1->L1_DESCNF) 					)
		ofwEAIObj:setProp("OperatorCode"       			,RTrim(SL1->L1_OPERADO) 						)
		ofwEAIObj:setProp("CurrencyRate"       			,CValToChar(SL1->L1_TXMOEDA) 					)
		ofwEAIObj:setProp("Change"       				,CValToChar(SL1->L1_TROCO1) 					)
		ofwEAIObj:setProp("StationCode"       			,RTrim(SL1->L1_PDV) 							)
		ofwEAIObj:setProp("DiscountPaymentTerm"       	,CValToChar(SL1->L1_DESCFIN) 					)
		ofwEAIObj:setProp("CreditValue"       			,CValToChar(SL1->L1_CREDITO) 					)
		ofwEAIObj:setProp("KindOfDocument"       		,RTrim(SL1->L1_ESPECIE) 						)
		ofwEAIObj:setProp("CarrierCode"  				,RTrim(SL1->L1_TRANSP) 							)
		ofwEAIObj:setProp("CarrierInternalId"       	,Lj701ITran(/*cMarca*/, nTypeTrans, SL1->L1_TRANSP, /*cInternalId*/)[2] )
		ofwEAIObj:setProp("Md5"       					,RTrim(SL1->L1_PAFMD5) 							)
		ofwEAIObj:setProp("PersonalIdentification"      ,RTrim(SL1->L1_CGCCLI) 							)
		ofwEAIObj:setProp("IsCanceled"       			,lCupCancel										)
		ofwEAIObj:setProp("StationSalePointCode"       	,RTrim(SL1->L1_ESTACAO) 						)
		ofwEAIObj:setProp("StationSalePointInternalId"  ,cEstInt 										)
		ofwEAIObj:setProp("SerialNumberSATEquipament"   ,RTrim(SL1->L1_SERSAT) 							)
		ofwEAIObj:setProp("SaleType"       				,IIF(Empty(SL1->L1_SERSAT), "V", "S") 			)
		ofwEAIObj:setProp("KeyAcessNFe"       			,RTrim(SL1->L1_KEYNFCE) 						)

		//Lista de Impostos da venda
		ofwEAIObj:setprop('ListOfTaxes',{},'Tax',,.T.)
		ofwEAIObj:get("ListOfTaxes")[1]:setprop("Taxe"   	, "COFINS",,.T.)
		ofwEAIObj:get("ListOfTaxes")[1]:setprop("Value"     , CValToChar(SL1->L1_VALCOFI),,.T.)
	
		ofwEAIObj:setprop('ListOfTaxes',{},'Tax',,.T.)
		ofwEAIObj:get("ListOfTaxes")[2]:setprop("Taxe"   	, "CSLL",,.T.)
		ofwEAIObj:get("ListOfTaxes")[2]:setprop("Value"     , CValToChar(SL1->L1_VALCSLL),,.T.)

		ofwEAIObj:setprop('ListOfTaxes',{},'Tax',,.T.)
		ofwEAIObj:get("ListOfTaxes")[3]:setprop("Taxe"   	, "ISS",,.T.)
		ofwEAIObj:get("ListOfTaxes")[3]:setprop("Value"     , CValToChar(SL1->L1_VALISS),,.T.)

		ofwEAIObj:setprop('ListOfTaxes',{},'Tax',,.T.)
		ofwEAIObj:get("ListOfTaxes")[4]:setprop("Taxe"   	, "PIS",,.T.)
		ofwEAIObj:get("ListOfTaxes")[4]:setprop("Value"     , CValToChar(SL1->L1_VALPIS),,.T.)

		ofwEAIObj:setprop('ListOfTaxes',{},'Tax',,.T.)
		ofwEAIObj:get("ListOfTaxes")[5]:setprop("Taxe"   	, "IPI",,.T.)
		ofwEAIObj:get("ListOfTaxes")[5]:setprop("Value"     , CValToChar(SL1->L1_VALIPI),,.T.)

		ofwEAIObj:setprop('ListOfTaxes',{},'Tax',,.T.)
		ofwEAIObj:get("ListOfTaxes")[6]:setprop("Taxe"   	, "ICM",,.T.)
		ofwEAIObj:get("ListOfTaxes")[6]:setprop("Value"     , CValToChar(SL1->L1_VALICM),,.T.)

		//Itens ativados
		ofwEAIObj:setProp("ListOfSaleItem")

		SL2->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))
		
		nI := 1

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
	
			ofwEAIObj:getPropValue("ListOfSaleItem"):setProp("SaleItem",{})
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("InternalId"				, cValInt                                     	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("ItemInternalId"			, cProdInt                                    	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("ItemCode"				, RTrim(SL2->L2_PRODUTO)                      	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("ItemOrder"				, RTrim(SL2->L2_ITEM)                         	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("Quantity"				, CValToChar(SL2->L2_QUANT)                   	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("UnitPrice"				, CValToChar(SL2->L2_VRUNIT)                  	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("ItemTablePrice"			, CValToChar(SL2->L2_PRCTAB)                  	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("ItemPrice"				, CValToChar(SL2->L2_VLRITEM)                 	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("DiscountPercentage"		, CValToChar(SL2->L2_DESC)                    	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("DiscountAmount"			, CValToChar(SL2->L2_VALDESC)                 	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("OperationCode"			, RTrim(SL2->L2_CF)                           	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("Increase"				, 0       										)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("IsCanceled"				, lItCancel						             	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("UnitOfMeasureCode"		, cUniMed                                     	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("UnitOfMeasureInternalId"	, cUMInt                                      	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("WarehouseCode"			, RTrim(SL2->L2_LOCAL)                        	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("WarehouseInternalId"		, cLocInt                                     	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("IncreaseValueProrated"	, CValToChar(SL2->L2_SEGURO + SL2->L2_DESPESA)	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("FreightValueProrated"	, CValToChar(SL2->L2_VALFRE)                  	)
	
			//Lista de Impostos do item
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp('ListOfTaxes',{},'Tax',,.T.)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:get("ListOfTaxes")[1]:setprop("Taxe"   	, "COFINS",,.T.)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:get("ListOfTaxes")[1]:setprop("Value"   	, CValToChar(SL2->L2_VALCOFI),,.T.)

			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp('ListOfTaxes',{},'Tax',,.T.)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:get("ListOfTaxes")[2]:setprop("Taxe"   	, "CSLL",,.T.)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:get("ListOfTaxes")[2]:setprop("Value"   	, CValToChar(SL2->L2_VALCSLL),,.T.)

			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp('ListOfTaxes',{},'Tax',,.T.)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:get("ListOfTaxes")[3]:setprop("Taxe"   	, "ISS",,.T.)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:get("ListOfTaxes")[3]:setprop("Value"   	, CValToChar(SL2->L2_VALISS),,.T.)

			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp('ListOfTaxes',{},'Tax',,.T.)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:get("ListOfTaxes")[4]:setprop("Taxe"   	, "PIS",,.T.)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:get("ListOfTaxes")[4]:setprop("Value"   	, CValToChar(SL2->L2_VALPIS),,.T.)

			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp('ListOfTaxes',{},'Tax',,.T.)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:get("ListOfTaxes")[5]:setprop("Taxe"   	, "ICM",,.T.)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:get("ListOfTaxes")[5]:setprop("Value"   	, CValToChar(SL2->L2_VALICM),,.T.)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:get("ListOfTaxes")[5]:setprop("CalculationBasis"   	, CValToChar(SL2->L2_BASEICM),,.T.)
	
			nI++
			SL2->(dbSkip())
		EndDo

		//Itens cancelados
		SLX->(dbSeek(SL1->L1_FILIAL + SL1->L1_PDV + SL1->L1_DOC + SL1->L1_SERIE))
		nI := 1
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

				ofwEAIObj:getPropValue("ListOfSaleItem"):setProp("SaleItem",{})
				ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("InternalId"				, cValInt                                     	)
				ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("ItemInternalId"			, cProdInt                                    	)
				ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("ItemCode"				, RTrim(SLX->LX_PRODUTO)                      	)
				ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("ItemOrder"				, RTrim(SLX->LX_ITEM)                         	)
				ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("Quantity"				, CValToChar(SLX->LX_QTDE)                   	)
				ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("UnitPrice"				, CValToChar(SLX->LX_VRUNIT)                  	)
				ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("ItemPrice"				, CValToChar(SLX->LX_VALOR)                 	)
				ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("DiscountPercentage"		, CValToChar((SLX->LX_DESCON / SLX->LX_VALOR) * 100)                    	)
				ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("DiscountAmount"			, CValToChar(SLX->LX_DESCON)                 	)
				ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("IsCanceled"				, lItCancel						             	)
				ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("UnitOfMeasureCode"		, cUniMed                                     	)
				ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("UnitOfMeasureInternalId"	, cUMInt                                      	)
				nI++

			EndIf
	
			SLX->(dbSkip())
		EndDo


		//Formas de Pagamento da Venda
		SL4->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))
	
		ofwEAIObj:setProp("ListOfSaleCondition")
		nI := 1
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

			ofwEAIObj:getPropValue("ListOfSaleCondition"):setProp("SaleCondition",{})
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("DateOfPayment"				, cDtPagto                                     	)
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("PaymentValue"				,  CValToChar(SL4->L4_VALOR - SL4->L4_TROCO)   	)
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("PaymentMethodCode"			, RTrim(cFormaPg)                              	)
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("PaymentMethodInternalId"	, cPgtoInt                                    	)			
			
	
			//Busca Administradora Financeira, é enviado o Código Externo que está vinculado a Forma de Pagamento
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("FinancialManagerCode"		, IIF(!Empty(SL4->L4_ADMINIS),RTrim(Posicione("SAE", 1, xFilial("SAE") + SL4->L4_ADMINIS, "AE_CODEXT")), ""))
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("CardNumber"				, RTrim(SL4->L4_NUMCART))
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("SerieCheck"				, RTrim(SL4->L4_SERCHQ) )
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("BankCheck"					, IIF(AllTrim(cFormaPg) == "CH" .Or. AllTrim(cFormaPg) == AllTrim(GETMV("MV_LJMUCH")), RTrim(SL4->L4_ADMINIS), "")   )
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("AgencyCheck"				, RTrim(SL4->L4_AGENCIA))
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("AccountCheck"				, RTrim(SL4->L4_CONTA)  )
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("DocumentOfIdentification"	, RTrim(SL4->L4_RG)     )
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("PhoneNumber"				, RTrim(SL4->L4_TELEFON))
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("EftDate"					, cL4DataTef            )
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("EftDocument"				, RTrim(SL4->L4_DOCTEF) )
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("EftAutorization"			, RTrim(SL4->L4_AUTORIZ))
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("EftCancellationDate"		, cL4DatCanc            )
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("EftCancellationDocument"	, RTrim(SL4->L4_DOCCANC))
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("EftInstitute"				, RTrim(SL4->L4_INSTITU))
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("UniqueSerialNumber"		, RTrim(SL4->L4_NSUTEF) )
			ofwEAIObj:getPropValue("ListOfSaleCondition"):getPropValue("SaleCondition")[nI]:setProp("EftParcel"					, RTrim(SL4->L4_PARCTEF))	
		
	
			SL4->(dbSkip())
			nI++
		EndDo

	Else //Inclusao de Venda cancelada
		//Cancelamento de venda nao integrada, quando cancelada antes da finalizacao.
		//Neste caso sao enviadas as informacoes da venda completa pois nao existe
		//a venda original, ou seja, inclusao do cancelamento.
	
		//Posiciona no primeiro item do cupom cancelado
		SLX->(dbSetOrder(1))
		SLX->(dbSeek(SLX->LX_FILIAL + SLX->LX_PDV + SLX->LX_CUPOM + SLX->LX_SERIE))
	
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
	
		//Cabecalho da Venda
		ofwEAIObj:setProp("Event"            			,cEvent)		
		ofwEAIObj:setProp("CompanyId"        			,cEmpAnt)
		ofwEAIObj:setProp("BranchId"         			,cFilAnt)
		ofwEAIObj:setProp("CompanyinternalId"			,cEmpAnt + '|' + cFilAnt )
		ofwEAIObj:setProp("InternalId"       			,cValInt )	
		ofwEAIObj:setProp("TotalPrice"            		,CValToChar(nVlrTot) )		
		ofwEAIObj:setProp("DiscountValue"         		,0)		
		ofwEAIObj:setProp("NetPrice"            		,CValToChar(nVlrTot) )		
		ofwEAIObj:setProp("IssueDateDocument"      		,cEmissao )		
		ofwEAIObj:setProp("DocumentCode"           		,RTrim(cDoc) )		
		ofwEAIObj:setProp("SerieCode"            		,RTrim(cSerie) )		
		ofwEAIObj:setProp("GrossPrice"            		,CValToChar(nVlrTot) )		
		ofwEAIObj:setProp("CommodityPrice"            	,CValToChar(nVlrTot) )		
		ofwEAIObj:setProp("DiscountPercent"            	,0)		
		ofwEAIObj:setProp("OperatorCode"            	,RTrim(cOperador) )		
		ofwEAIObj:setProp("StationCode"            		,RTrim(cPdv) )		
		ofwEAIObj:setProp("Increase"            		,0)		
		ofwEAIObj:setProp("IsCanceled"            		,.T.)
		ofwEAIObj:setProp("StationSalePointCode"        ,RTrim(cEstac) )		
		ofwEAIObj:setProp("StationSalePointInternalId"	,cEstInt )		
		ofwEAIObj:setProp("SaleType"            		,IIF(Empty(cSerSat), "V", "S") )	
	
		//Itens		
		ofwEAIObj:setProp("ListOfSaleItem")
	
		For nI := 1 To Len(aItensCanc)
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
	
			ofwEAIObj:getPropValue("ListOfSaleItem"):setProp("SaleItem",{})
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("InternalId"				, cValInt                                     	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("ItemInternalId"			, cProdInt                                    	)

			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("ItemCode"				, RTrim(aItensCanc[nI][1])                    	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("ItemOrder"				, RTrim(aItensCanc[nI][2])                     	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("Quantity"				, CValToChar(aItensCanc[nI][3])                	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("UnitPrice"				, CValToChar(aItensCanc[nI][4])                	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("ItemPrice"				, CValToChar(aItensCanc[nI][5])               	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("DiscountAmount"			, 0							                	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("Increase"				, 0       										)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("IsCanceled"				, IIF(aItensCanc[nI][7] == "I", .T., .F.)		)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("UnitOfMeasureCode"		, cUniMed                                     	)
			ofwEAIObj:getPropValue("ListOfSaleItem"):getPropValue("SaleItem")[nI]:setProp("UnitOfMeasureInternalId"	, cUMInt                                      	)
			
		Next nI
	
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

Return { lRet, ofwEAIObj ,"RETAILSALES"}

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJI701O
Funcao para retornar valores das Tags do Obejto EAI 
@type function
@param oEAIObEt - Objeto EAI
@param cCpoTag  - Campo da tag para verificacao
@param cTypeTag - Tipo da tag
@param lDeCode  - Define se ira efetuar o DeCodeUtf8 em campos do tipo Caracter ou Memo

@author rafael.pessoa
@version P12
@since 01/10/2018
@return xRet, Valor Da Tag com a tipagem requerida

/*/
//-------------------------------------------------------------------
Function LjiOVldTag(oEAIObEt, cCpoTag, cTypeTag, lDeCode)

    Local xRet := ""    //Valor de retorno da funcao
    Local xTag := ""    //Conteúdo da TAG

    Default oEAIObEt := Nil
    Default cCpoTag  := ""
    Default cTypeTag := "C"
    Default lDeCode  := .F.

    //Verifica se encontra a TAG no objeto
    If oEAIObEt:getPropValue(cCpoTag) <> Nil 
        xTag := oEAIObEt:getPropValue(cCpoTag)
    EndIf

    Do Case
        //Tipo do conteúdo Numérico ou Logico
        Case ValType(xTag) == "N" .Or. ValType(xTag) == "L"
            xRet := xTag

        //Tipo do conteúdo Caractere Preenchido
        Case ValType(xTag) == "C" .And. !Empty(xTag)

            Do Case
            
                //Caracter
                Case cTypeTag $ "C|M"
                    xRet := xTag

                    //Se for necessario decodifica informação
                    If lDeCode
                        xRet := DeCodeUtf8(xRet)
                    EndIf
                
                //Numérico        
                Case cTypeTag == "N"
                    xRet := Val(AllTrim(StrTran(xTag, ",", ".")))

                //Data
                Case cTypeTag == "D" .Or. cTypeTag == "DF"
                    //Verifica se as informacoes de horario foram enviadas
                    If At("T", xTag) > 0 //Sepera data e horario 
                        xRet := Substr(xTag, 1, At("T", xTag) - 1)
                        xRet := AllTrim(StrTran(xRet, "-", "")) //Armazena data
                    Else
                        xRet := AllTrim(StrTran(xTag, "-", "")) //Se horario nao enviado, apenas armazena data
                    EndIf

                    //Data formatada, converte para tipo Date
                    If cTypeTag == "DF"
                        xRet := StoD(xRet)
                    EndIf

                //Horario
                Case cTypeTag == "T"
                    //Verifica se as informacoes de horario foram enviadas
                    If At("T", xTag) > 0
                        xRet := Substr(xTag, At("T", xTag) + 1, Len(xTag)) //Sepera data de horario e armazena horario
                    EndIf
            End Case

        //Tipo do conteúdo Nulo ou Vazio, coloca valor default
        OTherWise

            Do Case
                //Numérico        
                Case cTypeTag == "N"
                    xRet := 0

                //Logico
                Case cTypeTag == "L"
                    xRet := .F.

                //Data formatada
                Case cTypeTag == "DF"
                    xRet := CtoD("")
            End Case
    End Case

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldValores
Função que efetua a validação dos valores entre Cabeçalho, Itens e Pagamentos

@param nVlrTot      - Valor total do cabeçalho
@param nVlrItTot    - Soma de todos os itens
@param nVlrPagTot   - Soma de todos os pagamentos

@since 	 05/06/19
@version 2.0
/*/
//------------------------------------------------------------------
Static Function VldValores(nVlrTot, nVlrItTot, nVlrPagTot)

    Local lRet    := .T.
    Local cMsgRet := ""

    //Valida valores totais
    If ( nVlrTot <> nVlrItTot .Or. nVlrPagTot <> nVlrTot )
        lRet    := .F.
        cMsgRet := I18n(STR0152, {  "TAGs"                                      ,;
                                    "TotalPrice="   + cValToChar(nVlrTot)       ,;
                                    "ItemPrice="    + cValToChar(nVlrItTot)     ,;
                                    "PaymentValue=" + cValToChar(nVlrPagTot)}   )   //"Divergência de valores entre Cabeçalho, Itens e Pagamentos, verifique as #1: #2, #3 e #4."
    EndIf

Return {lRet, cMsgRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} VldFrete
Função responsavel em validar os valores de frete do cabeçalho e itens do pedido

@param 		oItens      - Objeto contendo todos os produtos do orçamento
@param 		nFreteCab   - Valor do frete informado no cabeçalho da venda
@since 	 	05/06/2020
@version 	1.0
@Return		lRet		- Retorna .F. caso encontre alguma inconsistencia nas validações
@Return		cMsgRet		- Retorna a mensagem referente a inconsistencia encontrada
/*/
//------------------------------------------------------------------
Static Function VldFrete(oItens, nFreteCab)

Local lRet 			:= .T. //Retorno logico da função
Local cMsgRet 		:= "" //Retorna uma mensagem de erro
Local nX 			:= 0 //Variavel de loop
Local nTotFreteItem := 0 //Valor total do frete dos itens

Default oItens 		:= Nil
Default nFreteCab 	:= 0

If oItens <> Nil
	For nX := 1 To Len(oItens)
		nTotFreteItem += LjiOVldTag(oItens[nX], "FreightValueProrated" 	  , "N")
	Next nX

	If nFreteCab > 0 .AND. nTotFreteItem == 0
		lRet 	:= .F.
		cMsgRet := STR0153 //"Foi informado o valor do frete na TAG FreightValue, porém, não foi informado o valor do frete na TAG FreightValueProrated nos produtos. Nesta TAG devera conter o valor do frete rateado por produto."
	ElseIf nFreteCab == 0 .AND. nTotFreteItem > 0
		lRet 	:= .F.
		cMsgRet := STR0154 //"Foi informado o valor do frete na TAG FreightValueProrated, porém, não foi informado o valor do frete no cabeçalho da venda na TAG FreightValue."
	ElseIf nFreteCab <> nTotFreteItem
		lRet 	:= .F.
		cMsgRet := STR0155 //"O valor do frete esta divergente entre o valor informado no cabeçalho da venda (TAG FreightValue) com o valor informado nos itens (TAG FreightValueProrated)."
	EndIf
EndIf

Return {lRet, cMsgRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} VldParamPd
Função responsavel em validar os valores de frete do cabeçalho e itens do pedido

@since 	 	05/06/2020
@version 	1.0
@Return		lRet		- Retorna .F. caso encontre alguma inconsistencia nas validações
@Return		cMsgRet		- Retorna a mensagem referente a inconsistencia encontrada
/*/
//------------------------------------------------------------------
Static Function VldParamPd()

Local lRet		:= .T. //Retorno logico da função
Local cMsgRet	:= "" //Retorna uma mensagem de erro
Local lLjPedVe	:= SuperGetMv("MV_LJPEDVE",,.F.) //Retorna o que foi configurado no parametro MV_LJPEDVE
Local cLjCondP	:= SuperGetMv("MV_LJCONDP",,"") //Retorna o que foi configurado no parametro MV_LJCONDP
Local lLjEcomo	:= SuperGetMv("MV_LJECOMO",,.F.) //Retorna o que foi configurado no parametro MV_LJECOMO
Local lLjEcomm	:= SuperGetMv("MV_LJECOMM",,.F.) //Retorna o que foi configurado no parametro MV_LJECOMM
Local aArea		:= GetArea() //Salva a area atual

If !lLjPedVe
	cMsgRet := STR0156 + Chr(13) + Chr(13) //"Para a geração do pedido de venda, o parâmetro MV_LJPEDVE deve ter o conteúdo .T. "
EndIf

If Empty(cLjCondP)
	cMsgRet += STR0157 + Chr(13) + Chr(13) //"O conteúdo do parâmetro MV_LJCONDP deve ser informado com o código de uma condição de pagamento para a geração do pedido de venda "
EndIf

cMsgRet := LojiVldTes()[2]

If lLjEcomo .OR. lLjEcomm
	cMsgRet += STR0159 + Chr(13) + Chr(13) //"Os parâmetros MV_LJECOMO e MV_LJECOMM devem obrigatoriamente estar com o conteúdo .F. quando for uma integração CiaShop / VTex "
EndIf

If !Empty(cMsgRet)
	cMsgRet += STR0160 + Chr(13) + Chr(13) //"Após a alteração do(s) parâmetro(s), é necessario reiniciar o(s) serviço(s) do Protheus. "
	lRet := .F.
EndIf

RestArea(aArea)

Return {lRet, cMsgRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} LojiVldTes
Realiza validações na TES informada  

@param   cTES, String, TES a ser validada 
@author  Lucas Novais (lnovais@)
@since   13/04/2022
@version P12.1.2210
@return  Array, {retorno logico, caso encontrado .T. senao .F., Mensagem de erro caso exista}
/*/
//-------------------------------------------------------------------

Function LojiVldTes(cTES)
Local cMsgRet := "" // -- Mensagem de retorno 

default cTES	:= SuperGetMv("MV_LJTESPE",,"") //Retorna o que foi configurado no parametro MV_LJTESPE

If !Empty(cTES) .AND. !(SubStr(AllTrim(cTES),1,1) == '&')

	cTES := PadR(cTES,TamSx3('F4_CODIGO')[1])

	dbSelectArea('SF4')
	SF4->(dbSetOrder(1)) //F4_FILIAL+F4_CODIGO

	If SF4->(dbSeek(xFilial('SF4')+cTES))
		If SF4->F4_DUPLIC == 'S'
			cMsgRet += STR0158 + Chr(13) + Chr(13) //"O conteúdo do parâmetro MV_LJTESPE Ou da TES Inteligente deve estar preenchido com o código de uma TES que não gera financeiro, por favor, verifique o cadastro da TES configurada no parâmetro "
		EndIf
	Else
		cMsgRet += STR0163 + Chr(13) + Chr(13) //"Não foi encontrada a TES configurada no parâmetro MV_LJTESPE ou  retornada pela TES Inteligente, por favor, confirme se realmente a TES esta cadastrada "
	EndIf

EndIf 

return {Empty(cMsgRet),cMsgRet}

