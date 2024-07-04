#INCLUDE "LOJA901A.ch"
#Include 'Protheus.ch'
#Include 'TopConn.ch'

#define _PEDIDO_CANCELADO "90#91#95#96"
#define _PEDIDO_CONFIRMADO "10"
#define _PEDIDO_RESERVADO "01"
#define _MET_PAGTO_CIELO "073#071#070#085"
#define _MET_PAGTO_REDE "096#097#098#099#100"
#define _MET_PAGTO_REDECARD "019#020#072"
#define _MET_PAGTO_MOIP "075#076#077#078#079#080#081#082#083#084"
#define _MET_PAGTO_API_MOIP "141#142#143#144#145#146#147#148"
#define _MET_PAGTO_BOLETO "005#008#024#028#054#067#149"
#define _MET_PAGTO_KOMERCI_WS "103#104#105#106#107"
#define _MET_PAGTO_MUNDIPAGG "117#119#120#121#122#123#124#125#126#127#128"
#define _MET_PAGTO_MUNDIPAGG_BOLETO "118"
#define _MET_PAGTO_MARKETPLACE "998"
#define _MET_PAGTO_OFFLINE "017#063#016#015#014#003#102"
#define _MET_PAGTO_HOMOLOGADO _MET_PAGTO_CIELO+"#"+_MET_PAGTO_REDE+"#"+_MET_PAGTO_REDECARD+"#"+_MET_PAGTO_MOIP+"#"+_MET_PAGTO_BOLETO+"#"+_MET_PAGTO_KOMERCI_WS+"#"+_MET_PAGTO_MUNDIPAGG+"#"+_MET_PAGTO_MUNDIPAGG_BOLETO+"#"+_MET_PAGTO_MARKETPLACE+"#"+_MET_PAGTO_OFFLINE+"#"+_MET_PAGTO_API_MOIP

Static cAE_Tipo := ""
Static lLj901Auto := .F. //Enable de ExecAuto
Static lLj901AIPI := .F. //Venda com IPI
Static _MoedaDef := 1 //Moeda padrão
Static lLjx901CEr := ExistFunc("Ljx901CErr")
Static aMetPgHml := StrTokArr (_MET_PAGTO_HOMOLOGADO, "#")
Static _lUdsC6RES := NIL
Static aUF        := {} //array com os códigos das UF
Static aTamEndCli := {}  //array com o tamanho dos campos do endereço do cliente
Static lLjx904ErrE := ExistFunc("Ljx904ErrE")
Static lGrvPedEc  := GetAPOInfo("LOJA701C.PRW")[4] >= Ctod("03/04/2018")

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA901A
Função de teste integracao Protheus e-commerce CiaShop recebimento de Pedidos
@param   	aParam - Array contendo os dados de execução em Schedule onde: [1] - Empresa, [2] - Filial, [4] - Tarefa
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs
@sample LOJA901()
/*/
//-------------------------------------------------------------------
Function LOJA901A(aParam)
local _lJob 		:= .F. //Execução em Job
Local _cEmp 		:= nil //Empresa
Local _cFil 		:= nil //Filial
Local cFunction 	:= "LOJA901A" //Rotina
Local lLock 		:= .F. //Bloqueado
Local oLJCLocker	:= Nil               		// Obj de Controle de Carga de dados
Local lCallStack 	:= .F. 							//Chamada de uma pilha de chamadas (1 job que chama todas as rotinas)
Local nModBckp 		:= 0
Local cName 		:= "" //Chave de travamento
Local cMsg			:= ""
Local cEndChv		:= "" // Url do webservice, adicionamos na chave para não haver duplicidade de informação.
Local lRet			:= .T.
Local cMessage := ""

If Valtype(aParam) != "A"
	_cEmp := cEmpAnt
	_cFil := cFilant

	If Valtype(aParam) = "L"
		lCallStack := aParam
	EndIf

	If ValType(nModulo) <> "U" .AND. nModulo <> 12
		nModBckp := nModulo
		nModulo := 12
	EndIf

Else

	_lJob :=  .T.
	_cEmp := aParam[1]
	_cFil := aParam[2]
EndIf

If _lJob
	RPCSetType(3)
	RpcSetEnv(_cEmp, _cFil,,,"LOJ" ) 	// Seta Ambiente
EndIf

cEndChv := SuperGetMv("MV_LJECOMK", .T., "")

If Empty(cEndChv)
	If _lJob
		Lj900XLg( STR0017 ,"") //"O parâmetro MV_LJECOMK não foi preenchido com o endereço da Url não é possível realizar a integração"
	Else
		MsgAlert( STR0017 ,"") //"O parâmetro MV_LJECOMK não foi preenchido com o endereço da Url não é possível realizar a integração"
	EndIF
	lRet := .F.
EndIf
Lj900XLg("Verificação da filial cEmpAnt/cFilAnt" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil(),"")

If lRet
	//Gera SEMAFORO - para não dar erro de execução simultanea
	oLJCLocker  := LJCGlobalLocker():New()
			cName := cFunction+cEmpAnt+cEndChv // chave modificada para que o job nao execute a integração mais de uma vez.

	lLock := oLJCLocker:GetLock( cName )

	Lj900XLg("Verificação da filial cEmpAnt/cFilAnt - Inicio" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil() + " Job " + cValTochar(IsBlind()),"")

	If lLock
		Lj900XLg(STR0001 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  + IIF(_lJob, STR0002 + aParam[4] ,STR0005) + STR0003 + DTOC(Date()) + " - " + Time() ) //"INICIO DO PROCESSO "###" - SCHEDULE - Tarefa "###" - EM: "
		Lj900XLg("Verificação da filial cEmpAnt/cFilAnt" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil(),"")

		If  ExistFunc("Lj904IntOk") //Verifica os parametros básicos da integração e-commerce CiaShop
			If  !lCallStack .AND. !Lj904IntOk(.T., @cMessage)
				Lj900XLg(cMessage,"")
			EndIf
		EndIf

		If _lUdsC6RES = NIL
			_lUdsC6RES := Lj901UsC6R()
		EndIf
		If !SuperGetMv("MV_RESAUT") .AND. SuperGetMv("MV_LJECOM0",.F., .F.) //Reserva de estoque habilitada, verifica o parâmetro
			If  !_lUdsC6RES
				cMsg := STR0016 //"Habilitada a geração de reserva e-commerce através do parâmetro MV_LJECOM0, porém o campo C6_RESERVA não está em uso, não serão geradas reservas para os pedidos e-commerce até que o campo C6_RESERVA esteja como usado."
				MsgAlert(cMsg)
				Lj900XLg(cMsg,"")

			EndIf
		EndIf

		Lj901APr(_lJob, lCallStack)
		Lj900XLg("Verificação da filial cEmpAnt/cFilAnt" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil(),"")

		Lj900XLg(STR0004 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  + IIF(_lJob, STR0002 + aParam[4] , STR0005) + STR0003 + DTOC(Date()) + " - " + Time()) //"FIM DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "

	Else
		If !IsBlind()
			MsgAlert(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]" )
		EndIf
		Lj900XLg(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  + IIF(_lJob, STR0002 + aParam[4], STR0005) )	 //"JÁ EXISTE EXECUÇÃO DA ROTINA "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "
	EndIf

	If lLock
		Lj900XLg("Verificação da filial cEmpAnt/cFilAnt" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil(),"")

		oLJCLocker:ReleaseLock( cName )
		Lj900XLg("Verificação da filial cEmpAnt/cFilAnt" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil(),"")

	EndIf
EndIf

If _lJob
	RPCClearEnv()
Else
	If nModBckp > 0 .AND. nModBckp <> nModulo
		nModulo := nModBckp
	EndIf
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901APr
Função de teste integracao Protheus e-commerce recebimento de Pedidos
@param   	lAJob - Execução via Schedule - Default .f.
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs
@sample Lj901APr(lAJob)
/*/
//-------------------------------------------------------------------
Function Lj901APr(lAJob, lCallStack, lTeste)
Local cXML     	:= "" //XML de Envio
Local oWS	   	:= NIL //Objeto WS
Local cError   	:= "" //Mensagem de Erro
Local cWarning 	:= "" //Mensagem de Alerta
Local oRetXML	:= nil //Retorno parseado
Local lErro    	:= .F. //Erro
Local cRetorno 	:= "" //Retorno
Local cSeq     	:= "" //Sequencia
Local aPedOk   	:= {} //Array de Pedidos
Local nInd 		:= 0	//Contador
Local dDataIni 	:= Date() //Data Inicial do Job
Local cHoraIni 	:= Time() //Hora Inicial do Job
Local cXMLT 	:= "" //XML de TEste
Local lResEst 	:= !SuperGetMv("MV_RESAUT") .AND. SuperGetMv("MV_LJECOM0",.F., .F.) .AND. _lUdsC6RES//Realiza reserva de estoque?
Local cLocEst 	:= SuperGetMv("MV_LJECOMG", .T., "") //Locais de Estoque
Local aEstoques := StrTokArr ( StrTran(cLocEst, " ", ""), ",") //Locais de Estoque
Local aAreaNNR 	:= {} //WorkArea Locais de Estoque
Local cFilNNR 	:= xFilial("NNR") //Filial do Local de Estoque
Local oNodeRet  := NIL //Node com retorno de Erro
Local oNodeMsg 	:= NIL //Node com mensagem de Erro
Local oNodeRes 	:= NIL //Node com mensagem de Erro
Local oNodePed 	:= NIL //Node com retorno dos Pedidos
Local bOldError := NIL //CodeBlock de Erro
Local lDepIntPd := ExistBlock("LJDepIntPd")
Local cTpSelEst := SuperGetMv("MV_LJECMM1", , "0") // 0 - Padrão, //1 - Ordem Parametro MV_LJECOMG //2 - Maior Saldo diponível //3 - Menor Saldo disponível
Local aPedidos	:= {} //Pedidos de Venda
Local cFilRot		:= cFilAnt //Filial da Rotina
Local cFilEC		:= "" //Filial do Pedido
Local lMultEst	:= .F. //Funcionalidade multiestoque habilitada?
Local lValido		:= .T. //Pedido válido
Local aAreaSM0	:= {} //WorkAreaSM0
Local nRecSM0		:= 0 //Registro SM0
Local cCodErro	:= "" //Codigo do erro de validação
Local cArmzEC		:= "" //Armazém EC
Local aEstEC		:= {} //Estoque e-commerce
Local cXmlConf		:= "" //XML de envio da confirmação do pedido
Local aRet901AVl := {} //Retorno do p.E de  de processamento/confirmação de Pedidos e-commece
Local lLj901AVlEC := ExistBlock("Lj901AVl")//Ponto de entrada de processamento/confirmação de Pedidos e-commece
Local lProcPed := .T. //processamento de Pedidos
Local lConfPed := .T. //Confirmação do Processamento de Pedidos
Local oNodeShopper := NIL
Local cCodCli := ""
Local lTranBD  := .F. //Transacao aberta no banco de dados
Local cPedEcom	:= ""
Local aLog := {} //Log de Erro
Local lConfUni :=  SuperGetMv("MV_LJECMMB",,.F.) //confirmação Unitária de Pedidos
Local cXMLPedUn := "" //XML com Data/Hora de Processamento do pedido
Local lConfPedUn := .F. //Confirmação de Pedido Unitaria
Local nPedConfUn := 0 //Contador de Pedidos confirmados
Local aPedOkC		:= {} //Pedido confirmando enviado ao ponto de entrada
Local cXMLPedGer	:= ""

//mandar com macrosubstituição
oWS := Lj904WS( )

Default lAJob := .F.
Default lCallStack := .F.
Default lTeste := .F.

//Configura a variável da Administradora Financeira
Lj901ASAE("")

Lj901StI(.F.) //Setup de Venda com IPI

bOldError := ErrorBlock( {|x| Lj901AVE(x, .t.) } ) // muda code-block de erro

Begin Sequence
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ //Sincroniza compradores                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LOJA901(.T.)
Recover
	Lj900XLg("Problemas na integração de compradores ")
End Sequence

ErrorBlock( bOldError ) // Restaura rotina de erro anterior


DbSelectArea("SA1")
SA1->(DbSetOrder(1))

DbSelectArea("SAE")
SAE->(DbSetOrder(1))

DbSelectArea("SC5")

DbSelectArea("SC9")

dbSelectArea("MGU")

dbSelectArea("SB1")
SB1->(DbSetOrder(1))

dbSelectArea("SA3")
SA3->(DbSetOrder(1))

dbSelectArea("MGT")
MGT->(dbSetOrder(1))

//Resultado da sincronização
cSeq := GETSXENUM("MGU","MGU_SEQ")
CONFIRMSX8()

If SuperGetMV("TT_WSDLXML",,.F.)
	Lj900XLg("Habilitando o Log WSDLXML")
	WSDLSaveXML(.T.)
EndIf

//Consome método
If !oWs:Pedidos(, , @cXML) .OR. Empty(oWs:cXml)
	lErro := .T.
	cRetorno := STR0007 //"Erro ao consumir o método 'Pedidos' do WebService!"
Else

	IIF(!lAJob, MemoWrit('retornoPedidos.xml', oWs:cXml), )

	//Retorna o XML parseado em um objeto com as tags em variáveis
	If !lTeste
		cRetorno := oWs:cXml
		oRetXML := XmlParser(oWs:cXml, "_", @cError, @cWarning)
	Else
		///Rotina para teste de xml
		cXMLT := ExecBlock("LJ901ATST")
		IIF(!lAJob, MemoWrit('retornoPedidos_teste.xml', cXMLT), )
		If !Empty(cXMLT)
			oRetXML := XmlParser(cXMLT, "_", @cError, @cWarning)
			If Empty(cError)
				If ValType(oRetXML:_RECEIPTLIST:_RECEIPT) == "A"
					oWs:nPedidosResult := Len(oRetXML:_RECEIPTLIST:_RECEIPT)
				Else
					oWs:nPedidosResult := 1
				EndIf
			EndIf
			cRetorno := cXMLT
		Else
			cError := "Empty XML"
		EndIf
	EndIf

	If Empty(cError)

		oNodeRes := XmlChildEx ( oRetXML, "_RESULT" )

		If ValType(oNodeRes) == "O"
			oNodeRet  := XmlChildEx ( oNodeRes, "_RESULTCODE" )  //Node com retorno de Erro
			oNodeMsg := XmlChildEx ( oNodeRes, "_RESULTTEXT" )  //Node com mensagem de Erro
		EndIf

		oNodePed := XmlChildEx ( oRetXML, "_RECEIPTLIST" )

		If ValType(oNodePed) ==  "O"
			oNodePed := XmlChildEx ( oNodePed, "_RESULTCODE" )
		EndIf
	EndIf

	If !Empty(cError)
		cRetorno := STR0008 + Chr(13) + cError //"Erro no método XmlParser: "
		cRetorno += Chr(13) + "XML: " + oWs:cXml
		lErro := .T.
	ElseIf ValType(oNodeRet) == "O" .AND. Val(oNodeRet:TEXT) <> 0
		//Deu erro WebService retornou uma mensagem de erro genérica na tag XML  sem a estrutura do serviço
		lErro := .T.
		If ValType(oNodeMsg) == "O" .AND. !Empty(oNodeMsg:TEXT)
			cRetorno += Chr(13) + "XML: " + oNodeMsg:TEXT
		EndIf
	ElseIf ValType(oNodePed) <>  "O"
		lErro := .T.
		cRetorno += Chr(13) + "XML: " + "Erro na Estrutura do XML de retorno"
	Else
		cRetorno := oWs:cXml
		If Val(oRetXML:_RECEIPTLIST:_RESULTCODE:TEXT) <> 0
			lErro := .T.
		Else
			If oWs:nPedidosResult <> 0

				//Apuração dos locais de Estoque para reserva/desgnação do local conforme parâmetro
				If ( lResEst .OR. Val(cTpSelEst) > 1 ) .AND. Len(aEstoques) = 0
					//Busca todos locais de estoque cadastrados
					aAreaNNR := NNR->(GetArea())
					NNR->(DbSetOrder(1))//NNR_FILIAL+NNR_CODIGO
					NNR->(DbSeek(cFilNNR))
					While NNR->(!Eof() .AND. NNR_FILIAL == cFilNNR)
						aAdd(aEstoques, NNR->NNR_CODIGO)
						NNR->(DbSkip(1))
					EndDo

					RestArea(aAreaNNR)
				EndIf

				If oWs:nPedidosResult == 1
					aAdd(aPedidos, oRetXML:_RECEIPTLIST:_RECEIPT)
				Else
					aPedidos := aClone(oRetXML:_RECEIPTLIST:_RECEIPT)
				EndIf

				For nInd := 1 to Len(aPedidos)

					lProcPed := .T. //processamento de Pedidos
					lConfPed := .T. //Confirmação do Processamento de Pedidos
					lConfPedUn := .F. //Pedido Confirmado no Processamento

					If ExistBlock("Lj91AnEC")
						ExecBlock("Lj91AnEC",.f., .f., { aPedidos[nInd], cSeq, oWS })
					EndIf

					If lLj901AVlEC
						aRet901AVl := {}
						aRet901AVl := ExecBlock("Lj901AVl",.f., .f., { aPedidos[nInd], cSeq, oWS })
						lProcPed := aRet901AVl[1]
						If Len(aRet901AVl) >= 2
							lConfPed := aRet901AVl[2]
						EndIf
						Lj900XLg("Executado p.E. " + "Lj901AVl Processa["+cValToChar(lProcPed)+"] confirma[" +cValToChar(lConfPed) +"]" , aPedidos[nInd]:_ORDER_ID:TEXT, aRet901AVl )
					EndIf

					If lProcPed

						aLog := {}
						cFilRot		:= cFilAnt //Filial da Rotina
						cFilEC		:= cFilAnt //Filial do Pedido
						lMultEst	:= .F. //Funcionalidade multiestoque habilitada?
						lValido		:= .T. //Pedido válido
						aAreaSM0	:= {} //WorkAreaSM0
						cCodErro := "" //Codigo do erro de validação
						aEstEC := {} //Locais de estoque do Pedido

						lTranBD  := .F. //Transacao aberta no banco de dados
						cPedEcom := ""
						lConfPed := .F. //Pedido não confirmado
						bOldError := ErrorBlock( {|x| Lj901AVE(x, .t., cPedEcom , @aLog) } ) // muda code-block de erro

						Begin Sequence
							nRecSM0 := 0
							aLog := {}

							cPedEcom := PadL(aPedidos[nInd]:_ORDER_ID:TEXT, TAMSX3("MGU_PEDECO")[1])
							//Valida se existe mais de um armazém vinculado ao Pedido
							lValido := Lj901AMEst(aPedidos[nInd], @lMultEst, @cFilEC, @cCodErro,;
													 @cArmzEC, @aEstEC)

							//Volta a configuração para a filial do Pedido

							Lj901ASetFil(lMultEst, cFilRot, @cFilEC, 1, ;
											@aAreaSM0, @nRecSM0, @cCodErro)
							//Configura para a filial do Pedido

							//Configura a variável da Administradora Financeira
							Lj901ASAE("")

							Lj901StI(.F.) //Setup de Venda com IPI
							cXMLPedUn := ""

							lConfPed := Lj901APedGrv(aPedidos[nInd], cSeq, oWS, lCallStack, ;
												lResEst,IIF(!lMultEst, aEstoques, aEstEC ), cTpSelEst, lMultEst,;
												cCodErro, cFilRot, cArmzEC, @lTranBD,;
												lConfUni, @lConfPedUn, @cXMLPedUn)




							//Configura a variável da Administradora Financeira
							Lj901ASAE("")

							Lj901StI(.F.) //Setup de Venda com IPI


							If ExistBlock("Lj91DeEC")
								ExecBlock("Lj91DeEC",.f., .f., { aPedidos[nInd], cSeq, oWS })
							EndIf

						Recover
						    If lTranBD
						    	DisarmTransaction()
						  		Lj900XLg("DESFAZENDO CONTROLE TRANSACIONAL NO PROCESSAMENTO DA VENDA E-COMMERCE. VEJA DETALHES DO ERRO NO LOGLOJA E LOG E-COMMERCE ", cPedEcom)
						  		lTranBD := .F.
						  	EndIf
						  	lConfPed := .F.
						  	lConfPedUn := .F.
						  	Ljx904ErrE(aLog,Nil,"PEDI",cPedEcom,Nil,Nil)
						End Sequence
						ErrorBlock( bOldError ) // Restaura rotina de erro anterior

						//Volta a configuração para a filial do Pedido
						Lj901ASetFil(lMultEst, cFilRot, cFilEC, 2, ;
										@aAreaSM0, @nRecSM0)
					Else
						//Grava a linha de leitura do Pedido
						RecLock("MGU", .T.)
						MGU->MGU_FILIAL  := xFilial("MGU")
						MGU->MGU_SEQ     := cSeq
						MGU->MGU_PEDECO := PadL(aPedidos[nInd]:_ORDER_ID:TEXT, TAMSX3("MGU_PEDECO")[1])   //Número do pedido na loja virtual

						oNodeShopper := XmlChildEx ( aPedidos[nInd]:_RECEIPT_SHOPPER, "_SHOPPER_ID" )

						If ValType(oNodeShopper) <> "O"
							cCodCli := StrZero(0, TAMSX3("A1_COD")[1])
						Else
							cCodCli := StrZero(Val(oNodeShopper:TEXT), TAMSX3("A1_COD")[1])
						EndIf

						MGU->MGU_CODCLI  := cCodCli                                            //Código do cliente na loja virtual
						MGU->MGU_TOTAL   := Val(aPedidos[nInd]:_RECEIPT_DETAILS:_TOTAL:TEXT) / 100         //Total do pedido
						MGU->MGU_NOMENT  := RetNum(aPedidos[nInd]:_RECEIPT_SHOPPER:_SHOPPER_CPF:TEXT) +" P.E. Lj901AVl "            //Nome para entrega
						MGU->MGU_METPGT := PadL(aPedidos[nInd]:_RECEIPT_DETAILS:_COD_PG:TEXT,3,"0")                   //Método de pagamento
						MGU->MGU_NUMPAR := Val(aPedidos[nInd]:_RECEIPT_DETAILS:_INSTALLMENT:TEXT)         //Número de parcelas
						MGU->MGU_CONFIR := "0"
						MGU->(MsUnlock())

					EndIf

					If lConfPed
						aAdd(aPedOk, { aPedidos[nInd]:_ORDER_ID:TEXT, !lConfPedUn } )
						aAdd(aPedOkC, aPedidos[nInd]:_ORDER_ID:TEXT)
						If lConfPedUn
							nPedConfUn++
							cXMLPedGer += cXMLPedUn
						EndIf
					Endif


				Next nInd
			Endif
		Endif
	Endif

	If ValType(oNodeRes) == "O"
		FreeObj(oNodeRes)
	EndIf
	If ValType(oNodeRet) == "O"
		FreeObj(oNodeRet)
	EndIf
	If ValType(oNodeMsg) == "O"
		FreeObj(oNodeMsg)
	EndIf
	If ValType(oNodePed) == "O"
		FreeObj(oNodePed)
	EndIf
	If ValType(oRetXML) == "O"
		FreeObj(oRetXML)
	EndIf
	If ValType(oNodeShopper) == "O"
		FreeObj(oNodeShopper)
	EndIf
Endif

// Realiza confirmação dos pedidos lançados com sucesso
if !lErro .AND.  oWs:nPedidosResult > 0

	dbSelectArea("MGM")
	RECLOCK("MGM", .T.)
	MGM->MGM_FILIAL  := xFilial("MGM")
	MGM->MGM_SERVIC := "LOJA901A"
	MGM->MGM_SEQ     := cSeq
	MGM->MGM_DATA    := dDataIni
	MGM->MGM_HORAIN  := cHoraIni

	MGM->MGM_XMLRET  := cRetorno

	MGM->MGM_HORAFI := Time()
	if !lErro
		MGM->MGM_RESULT := "1"
	Else
		MGM->MGM_RESULT  := "2"
	endif
	MGM->(msUnLock())

	lConfPedUn := nPedConfUn = len(aPedOk)


	If !lConfPedUn

		cXML := '<?xml version="1.0" encoding="utf-8" standalone="no" ?>'
		cXML += '<receipt_resultList xmlns="dsReceipt.xsd">'


		for nInd := 1 to len(aPedOk)
			If aPedOk[nInd, 02]
				cXML += '<receipt_result'

				//Reservado
				cXML += ' xmlns=""'

				//Código do cliente na loja virtual
						cXML += ' order_id="' + aPedOk[nInd, 01] + '"'

				//Processado OK
				cXML += ' processed="1"'

				cXML += '/>'
			EndIf
		next nInd

		cXML += '</receipt_resultList>'

		IIF(!lAJob, Memowrit('envioConfPedidos.xml', cXML), )

		cXmlConf := cXML
	EndIf

	If nPedConfUn > 0
		cXmlConf := cXMLPedGer + cXmlConf
	EndIf
	//Consome método
	If  ( Len(aPedOk) > 0 .AND.  !lConfPedUn ) .AND. !oWs:ConfirmaPedidos(, , @cXML)
		lErro := .T.
		cRetorno := STR0009//"Erro ao consumir o método 'ConfirmaPedidos' do WebService!"
		Lj900XLg("LOJA901A  - " + cRetorno)
	Else

		If !lConfPedUn
			IIF(!lAJob, MemoWrit('retornoConfPedidos.xml', oWs:cXml), )
			//Retorna o XML parseado em um objeto com as tags em variáveis
			oRetXML :=	XmlParser(oWs:cXml, "_", @cError, @cWarning )
		EndIf

		If !Empty(cError)
			cRetorno := STR0008 + Chr(13) + cError //"Erro no método XmlParser: "
			cRetorno += Chr(13) + "XML: " + oWs:cXml
			lErro := .T.
		Else
			If !lConfPedUn
				cRetorno := oWs:cXml
				lErro := !oWs:lConfirmaPedidosResult
			Else
				lErro := .F.
			EndIf
			If !lErro
				//Seta como confirmado os pedidos
				MGU->(DbSetOrder(1))
				For nInd := 1 to Len(aPedOk)
					If MGU->(DbSeek(xFilial("MGU") + cSeq + Padl(aPedOk[nInd, 01], TAMSX3("MGU_PEDECO")[1])))
						RecLock("MGU", .F.)
						MGU->MGU_CONFIR := "1"
						MGU->(MsUnLock())
					Endif
				Next nInd

				RecLock("MGM", .F.)
				MGM->MGM_XMLENV := cXmlConf
				MGM->(MsUnLock())

				//Ponto de entrada depois que integrou os pedidos
				If lDepIntPd
					ExecBlock("LJDepIntPd",.F.,.F.,{aPedOkC})
				EndIf

			EndIf
		EndIf
	EndIf
EndIf


If ValType(oWs) == "O"
	FreeObj(oWs)
EndIf

//Desabilitado a gravação do XML
If SuperGetMV("TT_WSDLXML",,.F.)
	Lj900XLg("DeHabilitando o Log WSDLXML")
	WSDLSaveXML(.F.)
EndIf


//Configura a variável da Administradora Financeira
Lj901ASAE("")

Lj901StI(.F.) //Setup de Venda com IPI
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901APedGrv
Insere o Pedido
@param   	oAPed - Objeto Pedido
@param 		cASeq - Sequencia
@param 		oWS - WebService
@param   	lCallStack - Chamada da rotina LOJA901C
@param 		lResEst - Reserva de Estoque
@param 		aEstoques - Locais de Estoque
@param		cTpSelEst - Tipo de Seleção de Local de Estoque
@param   	lMultEst - Trabalha com multEstoque
@param 		cCodErro - Codigo do Erro da rotina
@param 		cFilRot - Filial de Execução da rotina
@param		cArmzEC - Armazém do Pedido
@param		lTranBD  - Transacao aberta no banco de dados
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs
@sample Lj901APedGrv(oAPed, cASeq)
/*/
//-------------------------------------------------------------------
Static function Lj901APedGrv(oAPed, cASeq, oWS, lCallStack, ;
								lResEst, aEstoques, cTpSelEst, lMultEst,;
								cCodErro, cFilRot, cArmzEC, lTranBD,;
								lConfUni, lConfPedUn, cXMLPedUn)

local lRes      	:= .F. //Retorno da Rotina
Local aCabPV    	:= {} //Cabeçalho do Pedido
Local aItemPV   	:= {} //itens do Pedido
local cCodCli   	:= "" //Cliente
local xAux 			:= "" //Variavel Auxiliar
local nInd 			:= 0 //Contador
local nTotalPed 	:= 0 //total do Pedido
local nVlrParc 		:= 0 //Valor da Parcela
local nNumParc 		:= 0 //Numero de Parcelas
local dDataVcto 	:= Ctod("") //Data de Vencimento
local dDataPed 		:= Ctod("") //Data do Pedido
local dVctoIni 		:= Ctod("") //Data de Vencimento Inicial
Local nDiaVcto  	:= 0 //Dia de vencimento
Local cParcela  	:= "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0" //Parcelas
Local oRetExtra 	:= NIL //Campos Extras
Local cOrderID 		:= "" //Numero do Pedido
Local nDesconto 	:= "" //Desconto
Local nSubVlr 		:= 0 //SubTotal
Local i 			:= 0	//Contador
Local cCondPag 		:= ""//Condicao de Pagamento
Local cLojaEnt 		:= "" //Loja da Entrega
Local cStatuCan 	:= "" //status do Pedido cancelado
Local lGerSE1 		:= SuperGetMv("MV_LJECOMS",.T., .F.)
Local lFuncCanc 	:= ExistFunc("LJ907CnO") //Função de cancelamento do orçamento
Local cPedEcom 		:= "" //Pedido e-commerce
Local cVendedor 	:= "" //Vendedor do cliente
Local cStatus 		:= "" //Status do Pedido Gerado
Local aParcela 		:= {} //Array contendo os dados da parcela
Local nVParcela 	:= 0 //Valor da Parcela
Local dData 		:= Ctod("") //Data da parcela
Local aSlQ			:= {} //Array de Orçamento
Local aSLR			:= {} //Array de Itens do Orçamento
Local aSl4			:= {} //Array de Pagamentos
Local nValTaxAdm	:= 0 //Valor da Taxa Administrativa
Local aAdmValTax	:= {} //Array da taxa administrativa
Local lAglutina		:= .F. //Aglutina parcela
Local lAdmProp		:= .F. //Financiamento Proprio?
Local aProdutos		:= {} //Array de Produtos
Local cTES			:=  SuperGetMv("MV_LJECOMR",.T., "") //TES do Produto
Local cTESRET		:= "" //Retorno da TES
Local cCondFi		:= SuperGetMv("MV_LJECOM6",.T., "010") //Condição de Pagamento para forma Financiada
Local cCondCC	    := SuperGetMv("MV_LJECOM7",.T., "020")//Condição de Pagamento para forma Cartão Crédito
Local cCondCD		:= SuperGetMv("MV_LJECOM8",.T., "030")//Condição de Pagamento para forma Cartão Débito
Local cTpFrete		:= SuperGetMv("MV_LJECOM9",.T., "C")    //Tipo de frete do Pedido/Orçamento
Local cRetErro		:= "" //Codigo de Retorno do Erro
Local cTpOper		:= "03" //tipo de Operacao (Venda consumidor final)
Local cTesSai  		:= SuperGetMV("MV_TESSAI",,"501")	// Pega do parametro o TES padrao para saida
Local nTotItem		:= 0  //total do Iten
Local nC			:= 0 //Variavel contador
Local nCents		:= 0 //Centavos
Local nTotCents		:= 0 //Total dos Centavos
Local nPosDes		:= 0  //Posição do desconto do pedido
Local nItem			:= 0 //Contador de Item
Local bOldError		:= NIL //Bloco de Erro
Local lErrorCli		:= .f. //Erro ao Incluir o Cliente de Entrega
Local cCliEnt		:= "" //Cliente de entrega
Local aTpOper 		:= StrTokArr (SuperGetMv("MV_LJECOMV", .F. , "03,01"), ",") //Tipo de Operação e-commerce  1- parametro PF, segundo PJ
Local lLJ901APV 	:= ExistBlock("LJ901APV") //Ponto de Entrada Ativo?
Local aRetPVCab 	:= {} //Dados adicionais do pedido de venda
Local aAreaAnt 		:= {} //WorkArea anterior
Local nR			:= 0 //Contador
Local nValJur		:= 0 //Valor dos Juros
Local nPerJur 		:= 0 //Percentual dos Juros
Local nTotJur		:= 0 //Total dos Juros
Local nValSubJ		:= 0 //Valor do Subtotal sem juros
Local nPosFrete 	:= 0 //Posição de Dados do Frete
Local lCampo 		:= .F. //Campo
Local aReservas 	:= {} //Array de reservas
Local dDtLimite 	:= Date() //Data Limite da Reserva
Local lErroRes		:= .f. //Erro na rotina de reservas?
Local aLojas 		:= {} //Lojas da Reserva
Local nPosItem 		:= 0 //Posição do Item
Local aResCanc 		:= {} //Array de dados da reserva para cancelar
Local aAreaSM0 		:= SM0->(GetArea()) //WorkArea SM)
Local lMvLjIPEn		:= SuperGetMV("MV_LJIPENP",, .F.)  //Calcula IPI embutido
Local lMVRNDIPI		:= SuperGetMV("MV_RNDIPI",,.F.) //Arredonda IPI?
Local nCasasIPI		:= SLR->(TamSX3("LR_VALIPI")[2]) //Tamanho de Casas  no campo IPI
Local lMVLjDtIPI 	:= SuperGetMv("MV_LJDTIPI", , .F.) 			//define se a diferença entre o IPI embutido e o calculado será lançado como desconto no total da NF
Local aItemPed		:= {} //Itens do Pedido
Local lMVLjAtIPI	:= SuperGetMv("MV_LJATIPI", , .F.) //define se a diferença entre o IPI embutido e o calculado será lançado como FRETE no total da NF
Local nAcesIPI		:= 0 //Valor do IPI como Acrescimo (FRETE)
Local nDescAcres	:= 0 //Valor do desconto/Acrescimo
Local lUltItem		:= .f. //ultimo item?
Local nTotItPed		:= 0 //total de itens do pedido
Local nFrete		:= 0 //Valor do Frete
Local nSeguro		:= 0 //Valor do Seguro
Local nDespesa		:= 0 //Valor da Despesa
Local cIPIBrut		:= GetMv( "MV_IPIBRUT" ) //IPI Bruto
Local lIPIBrut		:= .F. //IPI Bruto?
Local nTotDescIt	:= 0 //total do desconto por item (se IPI Líquido)
Local lProdIPI		:= .F. //produto com IPI
Local lNoMetEnt	   	:= .F. //Sem metodo de entrega
Local oNodeEnt		:= NIL //Node de entrega

Local nTamProd 		:= SB2->(TamSx3("B2_COD"))[1] //Tamanho do Código do Produto
Local nTamLocal 	:= SB2->(TamSx3("B2_LOCAL"))[1] //Tamanho do Local de Estoque
Local aTpOperRev 	:= StrTokArr (SuperGetMv("MV_LJECMM2", .F. , "01"), ",") //Tipo de Operação Revenda e-commerce  1- parametro PF, segundo PJ
Local aCamposExtra	:= {} //Array de Campos extras
Local cLjEcPe 		:= SuperGetMV("MV_LJECLPE",.T.,"")    //Armazem Padrao Ecommerce
Local lPedMktPlc	:= .F. //Pedido emitido via MarketPlace
Local oNodeShopper	:= NIL //Node do Cliente
Local oNodeCompl 	:= NIL						//Complemento do endereço
Local oNodeDocId 	:= NIL						//Id do Documento
Local oNodeDocTy 	:= NIL						//Tipo do Documento
Local nT			:= 0 //contador
Local cPedCom		:= ""
Local nP			:= 0 //Contador de Pedido
Local lNoEndEntr	:= .F. //Sem endereço de entrega
Local oNodeCliEnd	:= NIL //No de cliente de entega
Local cFilSA1Rot 	:= xFilial("SA1", cFilRot) //cliente da Filial da Rotina
Local cFilSA1		:= xFilial("SA1") //Cliente da Filial do pedido
Local cTurno        := ""
Local lErroVlIPI	:= .F.
Local cErroIPI		:= "" //Mensagem de Erro do IPI
Local lIPIAjst		:= SuperGetMV("MV_LJECMMA",,.F.)  //REaliza o ajuste no valor do IPI
Local aItemPV2		:= {} //Array do Pedido de Venda com valor do e-commerce
Local aLog      	:= {}
Local cNomeCli      := ""
Local lLJ901CL1		:= ExistBlock("LJ901CL1") 	// p.e. de inclusão de dados adicionais de cliente
Local nVlrBruto		:= 0 //Valor Bruto da Venda
Local lErroProc		:= .F. //Erro de Processamento
Local cErrorCode	:= "" //codigo de Erro
Local aAreaSF4      := {}
Local cMsgTr		:= STR0019 //"CONTROLE TRANSACIONAL HABILITADO. As informações geradas durante processamento deste pedido serão desfeitas."
Local nTamSC6It		:= SC6->(TamSx3("C6_ITEM"))[1]
Local cItemAnt		:= Replicate("0",nTamSC6It)
Local aLJ901DES		:= Nil
Local lLJ901DES 	:= ExistBlock("LJ901DES")
Local cCodPgEc      := ""

Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.

Default lCallStack := .F.

lTranBD := .f.
lConfPedUn := .F.

//Total da Venda
nTotalPed := Val(oAPed:_RECEIPT_DETAILS:_TOTAL:TEXT) / 100

//Se multiestoque estiver habilitada, reprocessa os parametros de reserva de estoque, pois podem estar diferentes
If lMultEst
	lResEst 	:= !SuperGetMv("MV_RESAUT") .AND. SuperGetMv("MV_LJECOM0",.F., .F.) .AND. _lUdsC6RES
	cTpSelEst := SuperGetMv("MV_LJECMM1", , "0")
EndIf


//pega o CPF ou CNPJ
cBusca := RetNum(oAPed:_RECEIPT_SHOPPER:_SHOPPER_CPF:TEXT)

//Validação da informação de entega
oNodeEnt := XmlChildEx ( oAPed:_RECEIPT_DETAILS, "_SHIPPING_METHOD" )

If ValType(oNodeEnt) <>  "O"
	lNoMetEnt := .T. //Sem metodo de entrega
EndIf

//Se estiver sem método de entrega, verifica se está sem endereço de entrega
//Market place vem sem método de entrega
If lNoMetEnt
	oNodeCliEnd := XmlChildEx ( oAPed:_RECEIPT_SHOPPER, "_SHIP_TO_NAME" )
	If ValType(oNodeCliEnd) <> "O"
		lNoEndEntr := .T.
	EndIf
EndIf


//Validação da informação de entega
oNodeShopper := XmlChildEx ( oAPed:_RECEIPT_SHOPPER, "_SHOPPER_ID" )

If ValType(oNodeShopper) <> "O"
	lPedMktPlc := .T. //Pedido com Market Place
	cCodCli := StrZero(0, TAMSX3("A1_COD")[1])
Else
	cCodCli := StrZero(Val(oNodeShopper:TEXT), TAMSX3("A1_COD")[1])
EndIf

RecLock("MGU", .T.)
MGU->MGU_FILIAL  := xFilial("MGU", cFilRot)
MGU->MGU_SEQ     := cASeq
MGU->MGU_PEDECO := PadL(oAPed:_ORDER_ID:TEXT, TAMSX3("MGU_PEDECO")[1])   //Número do pedido na loja virtual
MGU->MGU_CODCLI  := cCodCli                                               //Código do cliente na loja virtual
MGU->MGU_TOTAL   := nTotalPed       //Total do pedido
If !lNoEndEntr //Sem endereço de entrega
	MGU->MGU_NOMENT  := cBusca + " " + RTrim(oAPed:_RECEIPT_SHOPPER:_SHIP_TO_NAME:TEXT)             //Nome para entrega
	MGU->MGU_FRETE   := VAL(oAPed:_RECEIPT_DETAILS:_SHIPPING_COST:TEXT) / 100 //Frete
	If !lNoMetEnt
		MGU->MGU_METENT := oAPed:_RECEIPT_DETAILS:_SHIPPING_METHOD:TEXT          //Método de entrega
	EndIf
Else
	MGU->MGU_NOMENT  := cBusca + " " + "CLIENTE RETIRA"             //Nome para entrega
EndIf
MGU->MGU_METPGT := PadL(oAPed:_RECEIPT_DETAILS:_COD_PG:TEXT,3,"0")                   //Método de pagamento
MGU->MGU_NUMPAR := Val(oAPed:_RECEIPT_DETAILS:_INSTALLMENT:TEXT)         //Número de parcelas
MGU->MGU_CONFIR := "0"
If MGU->(ColumnPos("MGU_FILPED") > 0) .AND. cFilAnt <> cFilRot
	MGU->MGU_FILPED := cFilAnt
EndIf
MGU->(MsUnlock())

//Não passou pela pré-validação do item
If !Empty(cCodErro)
	Lj901ASErr(cCodErro)
	return .F.
EndIf

cPedEcom := PadR(oAPed:_ORDER_ID:TEXT, TAMSX3("C5_PEDECOM")[1])

Lj900XLg("Verificando pedido existente ", MGU->MGU_PEDECO)
//Verifica se o pedido já foi lançado
If Lj901ABPed(cPedEcom,,lGerSE1, @cErrorCode)
    Lj900XLg("Verificando pedido existente ", MGU->MGU_PEDECO)
	//Verifica se o pedido está com o status de cancelado
	//19/02/2015 - CiaShop não envia o cancelamento do pedido
	cStatuCan := Lj901ASCan()
	If PadL(oAPed:_RECEIPT_DETAILS:_PASSO:TEXT, 2, "0") $ cStatuCan .AND.  lFuncCanc
		//Realiza o cancelamento do Pedido
		lRes := LJ907CnO(cPedEcom)
		Lj900XLg("Pedido existente e cancelado " + cValToChar(lRes), MGU->MGU_PEDECO)
		Return lRes
	Else
		Lj900XLg("Pedido existente e confirmado ", MGU->MGU_PEDECO)
		REturn .T.
	EndIf
ElseIf !Empty(cErrorCode)
	Lj901ASErr(cErrorCode) //Gera a mensagem de Erro
	Return .F.
EndIf

If Len(aTpOper) < 2
	If Len(aTpOper) = 0
		aTpOper := {"03", "01"}
	Else
		aAdd(aTpOper, "01")
	Endif
Endif

cTpOper := aTpOper[01]


//Tipo de Operação - Revenda
If Len(aTpOperRev) < 1
	If Len(aTpOperRev) = 0
		aTpOperRev := { "01"}
	Endif
Endif

//Ajuste no tipo do frete, caso venha com 1 ou 2
If cTpFrete = "1"
	cTpFrete := "C"
ElseIf cTpFrete = "2"
	cTpFrete := "F"
EndIf

//Configura a variável da Administradora Financeira
Lj901ASAE("")

Lj901StI(.F.) //Setup de Venda com IPI

//Verifica se o CPF é válido
if Empty(AllTrim(oAPed:_RECEIPT_SHOPPER:_SHOPPER_CPF:TEXT)) .OR.;
	!CGC(AllTrim(oAPed:_RECEIPT_SHOPPER:_SHOPPER_CPF:TEXT))
	If lLjx901CEr
		If !lNoEndEntr //Sem endereço de entrega
	    	cNomeCli  := RTrim(oAPed:_RECEIPT_SHOPPER:_SHIP_TO_NAME:TEXT)
	    EndIf
		Ljx901CErr("03",cPedEcom,AllTrim(oAPed:_RECEIPT_SHOPPER:_SHOPPER_CPF:TEXT),nil,;
					cNomeCli, cMsgTr)

	EndIf
	Lj901ASErr("3")
	return .F.
endif

//busca pelo indice 3 - Filial + CGC
SA1->( dbSetOrder(3) )
SA1->( dbSeek( cFilSA1 + cBusca ) )
//se encontrar é alteração
IF !SA1->( Found() ) .and. !lPedMktPlc .AND.  (  !lMultEst .OR.  cFilSA1 == cFilSA1Rot)
	Lj901ASErr("1")
	If lLjx901CEr
		If !lNoEndEntr //Sem endereço de entrega
	    	cNomeCli  := RTrim(oAPed:_RECEIPT_SHOPPER:_SHIP_TO_NAME:TEXT)
	    EndIf
		Ljx901CErr("01",cPedecom,cBusca,Nil,;
					cNomeCli, cMsgTr)
	EndIf
	return .F.
Endif

Begin Transaction

lTranBD := .T. //Abriu transacao no banco de dados

Lj900XLg("INICIANDO CONTROLE TRANSACIONAL NO PROCESSAMENTO DA VENDA E-COMMERCE " + cCliEnt + "/" + cLojaEnt + " CGC/CPF" + cBusca + "Filial Pedido "+cFilAnt, MGU->MGU_PEDECO)

lErroProc := .F.

Do While .T.
	If !SA1->( Found() ) .AND. (  lPedMktPlc .OR. (lMultEst .AND. cFilSA1 <> cFilSA1Rot))
		//Gera o cliente baseado no endereço de entrega se for marketplace ou pedido para filial diferente
		Lj900XLg("Cliente de Entrega Market Place ou MultiEstoque " + cCliEnt + "/" + cLojaEnt + " CGC/CPF" + cBusca + "Filial Pedido "+cFilAnt, MGU->MGU_PEDECO)
		cLojaEnt := Lj901AEnt("", "", oAPed, @lErrorCli,;
								 @cCliEnt, cBusca, lPedMktPlc, @oNodeCompl,;
								@oNodeDocId, @oNodeDocTy, lMultEst)
		Lj900XLg("Cliente de Entrega Market Place ou MultiEstoque gerado " + cCliEnt + "/" + cLojaEnt + " CGC/CPF" + SA1->A1_CGC, MGU->MGU_PEDECO)

		If lErrorCli
			cErrorCode := "14" //Erro ao inserir cliente de entrega
			Lj901ASErr(cErrorCode, .F., .T.)
			lErroProc := .T.
			Exit
		EndIf
	EndIF

	//Verifica se o CPF é o mesmo
	if AllTrim(SA1->A1_CGC) <> AllTrim(oAPed:_RECEIPT_SHOPPER:_SHOPPER_CPF:TEXT)
		If lLjx901CEr
			If !lNoEndEntr //Sem endereço de entrega
		    	cNomeCli  := RTrim(oAPed:_RECEIPT_SHOPPER:_SHIP_TO_NAME:TEXT)
		    EndIf
			Ljx901CErr("02",cPedecom,cBusca,Nil,;
					  cNomeCli, cMsgTr)
		EndIf
		cErrorCode := "02" //"CPF do pedido diferente do CPF do cadastro do cliente"
		Lj901ASErr(cErrorCode, .F., .T.)
		lErroProc := .T.
		Exit
	endif


	//Verifica o Tipo da Operacao
	If RTrim(SA1->A1_PESSOA) <> "F"
		cTpOper := aTpOper[02]
	EndIf

	//Tratamento do campo extra do Pedido - Motivo de Compra X Tipo de Operação
	cOrderID := oAPed:_ORDER_ID:TEXT

	oRetExtra := Lj901BPr(.F.,cOrderID, oWS, lCallStack)

	//Operação de revenda somente para pessoa jurídica

	If Valtype(oRetExtra) == "O"

		aCamposExtra := XmlChildEx(oRetExtra, "_CAMPOS_EXTRAS_RESULT")

		If aCamposExtra <> NIL

			aCamposExtra := XmlChildEx(aCamposExtra, "_CAMPO_EXTRA")

			If aCamposExtra == NIL
				aCamposExtra := {}
			ElseIf  aCamposExtra <> NIL .AND. Valtype(aCamposExta) <> "A"
				aCamposExtra := {}
				aAdd(aCamposExtra, oRetExtra:_CAMPOS_EXTRAS_RESULT:_CAMPO_EXTRA)
			EndIf
			For nC := 1 to len(aCamposExtra)
				If Upper(AllTrim(aCamposExtra[nC]:_CHAVE:TEXT)) == "MOTIVODECOMPRA" .And. RTrim(SA1->A1_PESSOA) <> "F" //Operação de revenda somente para pessoa jurídica
					If  Upper(AllTrim(aCamposExtra[nC]:_VALOR:TEXT))== "REVENDA"
						cTpOper := aTpOperRev[01]
					EndIf
				ElseIf Upper(AllTrim(aCamposExtra[nC]:_CHAVE:TEXT)) == "PERIODOENTREGA" //Ajuste legal - Lei da entrega de produtos
					cTurno :=  SubStr(aCamposExtra[nC]:_VALOR:TEXT,1,1)
				EndIf
			Next
		EndIf

	EndIf

    //Método de pagamento eh cadastrado com 0 a esquerda mas quando a ciashop envia vem sem o 0 a esquerda
    //Na tela de consulta do ciashop as formas de pagamento são visualizadas com 0 a esquerda
	cCodPgEc := PadL(oAPed:_RECEIPT_DETAILS:_COD_PG:TEXT, TamSx3("AE_ECCODIG")[1], "0")
	If lGerSE1 .And. aScan(aMetPgHml, { |p| p == cCodPgEc}) = 0
	    //Verifica se o método de pagamento está homologado
		Lj901ASErr("23") //"Método de Pagamento não homologado pelo Protheus"
		Lj900XLg("Pedido está vinculado a um método de pagamento não homologado pelo Protheus [" + cCodPgEc + "]. " + STR0018, MGU->MGU_PEDECO) //"O Pedido poderá ser integrado, caso tenha somente esta ocorrênca; mas pode ocorrer inconsistências na geração de informações financeiras do pedido"
	EndIf

	If SAE->( ColumnPos("AE_ECCODIG") ) > 0
        
        //Busca administradora
        xAux := RmiXSql("SELECT AE_COD FROM " + RetSqlName("SAE") + " WHERE AE_FILIAL = '" + xFilial("SAE") + "' AND AE_ECCODIG = '" + cCodPgEc + "' AND D_E_L_E_T_ = ' '", "*", /*lCommit*/, /*aReplace*/)

        If Len(xAux) > 0
            xAux := xAux[1][1]
        Else
            xAux := ""
        EndIf

        SAE->( DbSetOrder(1) )  //AE_FILIAL+AE_COD
		If !Empty(xAux) .And. SAE->( DbSeek(xFilial("SAE") + xAux) )
			nDiaVcto := SAE->AE_VENCTO
			If nDiaVcto < 0 .OR. nDiaVcto > 31
				nDiaVcto := 0
			EndIf
		Else
		 	If lLjx901CEr
				Ljx901CErr("05", cPedEcom, cCodPgEc, NIL, NIL, cMsgTr)
			EndIf
			cErrorCode := "05" //Administradora Financeira
			Lj901ASErr(cErrorCode, .F., .T.)
			lErroProc := .T.
			Exit
		EndIf

		Do Case
			Case RTrim(SAE->AE_TIPO) == "FI"
				cCondPag := cCondFi
			Case RTrim(SAE->AE_TIPO) == "CC"
				cCondPag := cCondCC
			Case RTrim(SAE->AE_TIPO) == "CD"
				cCondPag  := cCondCD
			Otherwise
				If lLjx901CEr
					Ljx901CErr("09",cPedEcom,SAE->AE_TIPO, NIL, NIL, cMsgTr)
				EndIf
				cErrorCode := "9" //Forma de pagamento inválida
				Lj901ASErr(cErrorCode, .F., .T.)
				lErroProc := .T.
				Exit
		EndCase

	Else
		If lLjx901CEr
			Ljx901CErr("50", NIL, NIL, NIL, NIL, cMsgTr)
		EndIf
		cErrorCode := "05" //Administradora Financeira
		Lj901ASErr(cErrorCode, .F., .T.)
		lErroProc := .T.
		Exit
	EndIf

	//Configura o tipo da administrador financeira
	Lj901ASAE(SAE->AE_TIPO)

	//Dados da Entrega -  Cliente
	If !lNoEndEntr //Existe endereço de entrega?
		cCliEnt := SA1->A1_COD
		cLojaEnt := SA1->A1_LOJA
		Lj900XLg("Cliente de Entrega " + cCliEnt + "/" + cLojaEnt + " CGC/CPF" + cBusca, MGU->MGU_PEDECO)
		cLojaEnt := Lj901AEnt(SA1->A1_COD, SA1->A1_LOJA, oAPed, @lErrorCli, ;
								@cCliEnt, cBusca, .F., @oNodeCompl,;
								@oNodeDocId, @oNodeDocTy, .F.)
		Lj900XLg("Cliente de Entrega Localizado " + cCliEnt + "/" + cLojaEnt + " CGC/CPF" + cBusca, MGU->MGU_PEDECO)

		If lErrorCli
			cErrorCode :=  "14" //Erro ao inserir cliente de entrega
			Lj901ASErr(cErrorCode, .F., .T.)
			lErroProc := .T.
			Exit
		EndIf
	EndIf

	If lLJ901CL1
		ExecBlock("LJ901CL1",.f., .f., {SA1->A1_COD, SA1->A1_LOJA,oAPed })
	EndIf
	If ValType(oNodeShopper) ==  "O"
		oNodeShopper := FreeObj(oNodeShopper)
	EndIf

	//Localiza o vendedor
	cVendedor := PadR( SA1->( If(Empty(A1_VEND), GetMV("MV_LJECOMA",,"000001"), A1_VEND) ), SA3->(TamSx3("A3_COD"))[1])

	//Realizar a validação do Vendedor
	SA3->(DbSetorder(1)) //A3_FILIAL+A3_COD
	If !SA3->(DbSeek(xFilial("SA3") + cVendedor))
		If lLjx901CEr
			Ljx901CErr("08",cVendedor, NIL, NIL,;
						NIL, cMsgTr)
		EndIf
		cErrorCode :=  "08" //Vendedor (Promoter) não cadastrado
		Lj901ASErr(cErrorCode, .F., .T.)
		lErroProc := .T.
		Exit
	EndIf

	If ValType(oNodeCliEnd)== "O"
		FreeObj(oNodeCliEnd)
	EndIf

	cStatus := "00"

	//Monta array com o cabeçalho do pedido de venda
	aAdd(aCabPV, {"C5_TIPO"   ,	"N", NIL})
	aAdd(aCabPV, {"C5_CLIENTE", SA1->A1_COD, Nil})
	aAdd(aCabPV, {"C5_LOJACLI"   , SA1->A1_LOJA, Nil})
	If !lNoEndEntr
		aAdd(aCabPV, {"C5_CLIENT" , cCliEnt, Nil})
		aAdd(aCabPV, {"C5_LOJAENT", cLojaEnt, Nil})
	EndIf
	aAdd(aCabPV, {"C5_TIPOCLI",	"F", NIL})
	aAdd(aCabPV, {"C5_CONDPAG", cCondPag, Nil})
	aAdd(aCabPV, {"C5_STATUS" , cStatus, Nil})
	aAdd(aCabPV, {"C5_VEND1"  , cVendedor, Nil})

	dDataPed := Lj901ADtWS(oAPed:_RECEIPT_DETAILS:_DATE_ENTERED:TEXT)
	aAdd(aCabPV, {"C5_EMISSAO", dDataPed, Nil})


	aProdutos := {}

	//Itens do pedido de venda
	If ValType(oAPed:_RECEIPT_ITEM) == "A"
		aProdutos := aClone(oAPed:_RECEIPT_ITEM)
	Else
		aAdd(aProdutos, oAPed:_RECEIPT_ITEM)
	EndIf

		//Soma os valores dos itens do pedido para calcular o SubTotal
	For i:=1 to Len(aProdutos)
		nSubVlr += Val(aProdutos[i]:_ADJUSTED_PRICE:TEXT) / 100
	Next

	//Valor Bruto da Venda = SubTotal + Frete + Seguro + Despesa
	nVlrBruto :=  nSubVlr + If(lNoEndEntr, 0 ,( VAL(oAPed:_RECEIPT_DETAILS:_SHIPPING_COST:TEXT) / 100 + VAL(oAPed:_RECEIPT_DETAILS:_INSURANCE:TEXT)/100+VAL(oAPed:_RECEIPT_DETAILS:_PACKAGES_TOTAL:TEXT) / 100))


	//SubTotal - Bonus - desconto no cupom para calcular o desconto percentual
	nSubVlr := nSubVlr - VAL(oAPed:_RECEIPT_DETAILS:_DISCOUNT_COUPON:TEXT) / 100 - VAL(oAPed:_RECEIPT_DETAILS:_BONUS_USED:TEXT) / 100

	//Desconto = Desconto Total / 10000. Ex: 3% = 0,03 + Valor do Disconto do Cupom / 100 + Valor do Bonus /100
	nDesconto := A410Arred(((VAL(oAPed:_RECEIPT_DETAILS:_DISCOUNT_TOTAL:TEXT) / 10000) * nSubVlr) +  VAL(oAPed:_RECEIPT_DETAILS:_DISCOUNT_COUPON:TEXT) / 100 + VAL(oAPed:_RECEIPT_DETAILS:_BONUS_USED:TEXT) / 100, "C5_DESCONT", _MoedaDef )

	If nTotalPed <>  (nVlrBruto - nDesconto) +  (Val( oAPed:_RECEIPT_DETAILS:_INTEREST:TEXT) / 100) .AND. nVlrBruto > nTotalPed    // Para o Valor adiciono o valor do desconto do cupom e Abato o valor do Frete

		If lLJ901DES
			aLJ901DES := ExecBlock("LJ901DES",.f., .f., { oAPed, oRetExtra, nDesconto, nVlrBruto, nTotalPed})
		EndIf

		If lLJ901DES .AND. Valtype(aLJ901DES) == "A" .AND. Len(aLJ901DES) > 1 .AND. aLJ901DES[1]
			Lj900XLg("Ajuste de desconto realizado via PE: LJ901DES de: " + cValToChar(nVlrBruto - nTotalPed) )
			nDesconto := aLJ901DES[2]
			Lj900XLg("Ajuste de desconto realizado via PE: LJ901DES para: " + cValToChar(aLJ901DES[2]))
		Else
			nDesconto := nVlrBruto - nTotalPed
		EndIf

	EndIf

	aAdd(aCabPV, {"C5_DESCONT"  , nDesconto, Nil})
	nPosDes := Len(aCabPV)
	Lj900XLg("C5_DESCONT " + cValToChar(nDesconto) , MGU->MGU_PEDECO)

	If !lNoEndEntr //com endereço/cliente de entega, então tem dados do frete
		xAux := VAL(oAPed:_RECEIPT_DETAILS:_SHIPPING_COST:TEXT) / 100

		nFrete := xAux
		aAdd(aCabPV, {"C5_FRETE"  , xAux, Nil})
		nPosFrete := Len(aCabPV)

		//Frete
		aAdd(aCabPV, {"C5_TPFRETE", cTpFrete, Nil})

		xAux := VAL(oAPed:_RECEIPT_DETAILS:_INSURANCE:TEXT) / 100

		nSeguro := xAux
		aAdd(aCabPV, {"C5_SEGURO" , xAux, Nil})

		xAux := VAL(oAPed:_RECEIPT_DETAILS:_INTEREST:TEXT) / 100 + VAL(oAPed:_RECEIPT_DETAILS:_PACKAGES_TOTAL:TEXT) / 100
		nDespesa := xAux
		aAdd(aCabPV, {"C5_DESPESA", xAux, Nil})

		If !lNoMetEnt //Com método de entrega, então tem transportadora
			xAux := oAPed:_RECEIPT_DETAILS:_SHIPPING_METHOD:TEXT
			cCodTransp := Lj901ATrB(xAux)
			if Empty(cCodTransp)
				If lLjx901CEr
					Ljx901CErr("04",cPedEcom,xAux, NIL,;
								NIL, cMsgTr)
				EndIf
				cErrorCode :=  "4" //"Transportadora não cadastrada"
				Lj901ASErr(cErrorCode, .F., .T.)
				lErroProc := .T.
				Exit
			endif
			aAdd(aCabPV, {"C5_TRANSP", cCodTransp, Nil})
		EndIf

		If ValType(oNodeEnt) ==  "O"
			FreeObj(oNodeEnt)
		EndIf
	Else //Sem método de entrega, então envia os dados do frete (arredondamento do IPI emmbutido)
		//Pode jogar a diferença de frete no IPI
		xAux := 0
		nFrete := xAux
		aAdd(aCabPV, {"C5_FRETE"  , xAux, Nil})
		xAux := 0
		//Frete
		if xAux > 0
			aAdd(aCabPV, {"C5_TPFRETE", cTpFrete, Nil})
		endif

		nPosFrete := Len(aCabPV)
		nSeguro := 0
		nDespesa := 0
		cCodTransp := ""
	EndIf

	xAux := oAPed:_RECEIPT_DETAILS:_ORDER_ID:TEXT
	cPedCom := IIf(ValType(xAux)=="C",xAux,"")
	aAdd(aCabPV, {"C5_PEDECOM", xAux, Nil})

	//Calculo das parcelas

	nNumParc  := Val(oAPed:_RECEIPT_DETAILS:_INSTALLMENT:TEXT)
	nVlrParc  := Round(nTotalPed / nNumParc, 2)
	xAux      := 0
	nAuxMaior := 0
	dVctoIni  := dDataPed

	//Valor de Juros
	If Val( oAPed:_RECEIPT_DETAILS:_INTEREST:TEXT)  > 0

		//Calculo de Juros simples - Inicio
		nValJur := Val( oAPed:_RECEIPT_DETAILS:_INTEREST:TEXT)/100

		nValSubJ	:= nTotalPed - nValJur //Valor do Subtotal sem juros
		nPerJur :=  A410Arred((nValJur/nValSubJ)*100 , "C5_ACRSFIN")

		nTotJur := A410Arred( nValSubJ * (nPerJur/100), "C5_DESCONT")
		//Calculo de Juros simples - final

		Lj900XLg("Venda com juros de  " + cValToChar(nValJur) + " Percentual " + cValTochar(nPerJur) + " Juros ReCalculado " + cValToChar(nTotJur), MGU->MGU_PEDECO)

		// aAdd(aCabPV, {"C5_ACRSFIN", nPerJur, Nil})
	EndIf

	if nDiaVcto > 0
		dVctoIni := CToD(StrZero(nDiaVcto,2) + "/" + StrZero(Month(dDataPed),2) + "/" + StrZero(Year(dDataPed),4))
		while Empty(dVctoIni)
			nDiaVcto--
			dVctoIni := CToD(StrZero(nDiaVcto,2) + "/" + StrZero(Month(dDataPed),2) + "/" + StrZero(Year(dDataPed),4))
		enddo

		if dVctoIni < dDataPed
			dVctoIni := MonthSum(dVctoIni, 1)
		endif
	endif

	For nInd := 1 to nNumParc
		dDataVcto := MonthSum(dVctoIni , nInd - 1)

		xAux += nVlrParc

		If nVlrParc*nNumParc <> nTotalPed .AND. nInd == 1
			nVParcela := nVlrParc-(nVlrParc*nNumParc-nTotalPed) //Valor da Parcela
		Else
			nVParcela := nVlrParc
		EndIf

		aAdd(aParcela, { dDataVcto, nVParcela} )
	Next nInd

	nVlrParc := 0 //Total da Parcela
	aAdmValTax := LjGrvTpFin( SAE->AE_FINPRO, If( SAE->(ColumnPos("AE_AGLPARC")) > 0, SAE->AE_AGLPARC, 2 ) )
	lAglutina	:= aAdmValTax[1]
	lAdmProp	:= aAdmValTax[2]
	dData := dDataPed
	For nInd := 1 to Len(aParcela)
		Lj900XLg("Antes de atualizar (LJCalcVenc) dDtVencto Pedido -> " + cValToChar(dData), MGU->MGU_PEDECO )//fabiana
		dData:=  LJCalcVenc(.F., dData, .F.) //Diego
		Lj900XLg("Depois de atualizar (LJCalcVenc) dDtVencto lAdmProp -> " + cValToChar(dData), MGU->MGU_PEDECO )//fabiana
		If Trim(SAE->AE_TIPO) == "FI"
			dData += SAE->AE_VENCFIN
		EndIf
		aParcela[nInd,1] := dData
		Lj900XLg("Depois de atualizar data pagamento -> " + cValToChar(aParcela[nInd,1]) + " parcela " + cValtochar(nInd), MGU->MGU_PEDECO )//fabiana

		If lAglutina .OR. ( (nInd == Len(aParcela))  .AND. (nVlrParc +  aParcela[nInd, 2]) <> nTotalPed )
			aParcela[nInd, 2] := nTotalPed - nVlrParc
		EndIf
		nVlrParc += aParcela[nInd, 2]

		If lAglutina //Joga tudo no primeiro vencimento
			aSize(aParcela,1)
			Exit
		EndIf

	Next nInd

	nValTaxAdm := 0
	If AllTrim(SAE->AE_TIPO) $ "CC/CD"
		If ExistFunc("LJ7_TXADM") .AND. (MEN->(ColumnPos("MEN_TAXADM")) > 0)
			aAdmValTax := LJ7_TxAdm( SAE->AE_COD, Len(aParcela), nTotalPed )
			If Len(aAdmValTax) > 0
				nValTaxAdm := aAdmValTax[3]
			EndIf
		EndIf
		If nValTaxAdm == 0
			nValTaxAdm := SAE->AE_TAXA
		EndIf
	ElseIf AllTrim(SAE->AE_TIPO) $ "VA|CO|FI"
		nValTaxAdm := SAE->AE_TAXA
	EndIf

	//Grava no cabeçalho do Pedido
	For nInd := 1 to Len(aParcela)
		lCampo := SC5->(FieldPos("C5_PARC" +Subs(cParcela,nInd,1))) > 0 .AND. SC5->(FieldPos("C5_DATA" +Subs(cParcela,nInd,1))) > 0
		If lCampo
			aAdd(aCabPV, {"C5_PARC" +Subs(cParcela,nInd,1), aParcela[nInd, 2], Nil})
			aAdd(aCabPV, {"C5_DATA" +Subs(cParcela,nInd,1), aParcela[nInd, 1], Nil})
		EndIf
	Next

	If lResEst

		//Realiza a geração da reserva
		If Alltrim(cCondPag) == "FI"
			dDtLimite := dDataPed + SuperGetMV("MV_LJECOM2", .F., 0)
		Else
			dDtLimite := dDataPed + SuperGetMV("MV_LJECOMB", .F., 0)
		EndIf
	EndIf

	//Verifica se IPI é Bruto ou Líquido
	If lMvLjIPEn
		If Empty(cIPIBrut)
			cIPIBrut := "S"
		EndIf

		lIPIBrut := cIPIBrut == "S"
	EndIf

	nTotItPed := Len(aProdutos)
	nTotDescIt := 0
	nTotFreteIt    := 0 //total do frete por item
	nItem := 0

	LjGrvLog(cPedCom,"CIASHOP TOTAL DE ITENS:",nTotItPed)

	For nInd := 1 To nTotItPed

		//Localiza o cadastro do produto
		nCents		:= 0 //Centavos
		If Upper(aProdutos[nInd]:_TYPE:TEXT) <> "KIT" //Produto normal
			cProduto := aProdutos[nInd]:_PF_ID:TEXT
			aKit := {}
			nTotItem		:= 1

		Else
		    aKit := lj901KtIt(aProdutos[nInd], @nCents,cPedCom) //Retorna o Kit dos produtos
		    //Codigo
		    //Quantidade
		    //Valor Unitario
		    //Valor do Item
		    //Preco Unitario
		    //Preço do Item
		    nTotItem := Len(aKit)
		    nTotCents += nCents

		EndIf

		For nC := 1 to nTotItem
			nItem++
			If Len(aKit) > 0
				cProduto := aKit[nC, 01]
			EndIf

			lUltItem := (nC == nTotItem) .AND. (nInd == nTotItPed)

			cProduto := PadR( Alltrim(cProduto), TamSx3("B1_COD")[1] )

			cTESRet := ""
			if SB1->(DbSeek(xFilial("SB1") + cProduto))

				If !Empty(cTES)

					cTESRet :=  cTES
					If Left(cTESRET,1) == "&"
						cTESRet := Substr(cTESRet,2,Len(cTESRet)-1)
						cTESRet := &cTESRet
					EndIf
				EndIf

				If Empty(cTESRet)
					cTESRet :=  MaTESInt(2, cTpOper, SA1->A1_COD , SA1->A1_LOJA, "C", cProduto)

					If Empty(cTESRet)
						cTESRet := RetFldProd(SB1->B1_COD,"B1_TS")
					EndIf

					If Empty(cTESRet)
						cTESRet := 	cTesSai
					EndIf
				EndIf

				aAreaSF4 := SF4->(GetArea())
				SF4->(DbSetOrder(1)) //F4_FILIAL + F4_COD

				If Empty(cTESRet)
					If lLjx901CEr
						Ljx901CErr("07", NIL, NIL, NIL,;
									NIL, cMsgTr)
					EndIf

					cErrorCode :=  "7" // TES não informada no cadastro do produto;
					Lj901ASErr(cErrorCode, .F., .T.)
					lErroProc := .T.
					Exit
				ElseIf !SF4->(DbSeek(xFilial("SF4") + cTESRet))
					cErrorCode :=  "25" // "TES não encontrada. Verifique o cadastro de TES Inteligente ou Produtos ou o parâmetro MV_TESSAI"
					Lj901ASErr(cErrorCode, .F., .T.)
					lErroProc := .T.
					Exit
				EndIf
				RestArea(aAreaSF4)
				aAdd(aItemPV, aClone(Lj901GIt(aProdutos[nInd], nItem, cTESRet, lGerSE1, ;
												If(Len(aKit) > 0, aKit[nC], {}), oRetExtra, lResEst, dDtLimite, ;
												aEstoques, @aReservas, SB1->B1_DESC, SB1->B1_COD,;
												(nTotCents + nDesconto), lMvLjIPEn , @aItemPed,  nSubVlr , ;
												@nTotDescIt, @lProdIPI, lUltItem , cTpSelEst,;
												nTamProd, nTamLocal, cLjEcPe, lMultEst,;
												cArmzEC,cTurno, lIPIAjst, @aItemPV2,;
												nTamSC6It, @cItemAnt)))

			else
				If lLjx901CEr
					Ljx901CErr("06",cPedEcom,cProduto, NIL,;
								NIL, cMsgTr)
				EndIf
				Lj901ASErr("6")

				cErrorCode :=  "6" //"Produto não cadastrado"
				Lj901ASErr(cErrorCode, .F., .T.)
				lErroProc := .T.
				Exit
			endif
		Next nC
		If lErroProc
			Exit
		EndIf
	next nInd
	If lErroProc
		Exit
	EndIf

	//Calculo de IPI do Item
	If lMvLjIPEn .AND. lProdIPI
		Lj901StI(lProdIPI) //Setup de Venda com IPI
		Lj900XLg("Recalculo Preço de Venda de itens com IPI Embutido", MGU->MGU_PEDECO)

		Lj901ApIPI(@aItemPV, @aItemPed, lMvLjIPEn , nCasasIPI,;
			lMVRNDIPI, nFrete, nSeguro,	nDespesa, ;
			cCliEnt, cLojaEnt, nDesconto, @nTotCents, ;
			lIPIBrut, nTotalPed, lMVLjDtIPI, lMVLjAtIPI,;
			@nAcesIPI, lProdIPI,@lErroVlIPI, lIPIAjst,;
			@cErroIPI, nPerJur , nValSubJ)

	EndIf

	If lErroVlIPI // Caso apresente erro no valor do item de ipi nao deve prosseguir a geração do pedido.
		aReservas := {}
		If lLjx901CEr
			Ljx901CErr("22", cPedEcom , cErroIPI, NIL,;
						NIL, cMsgTr)
		EndIf
		cErrorCode := "22"
		Lj901ASErr(cErrorCode, .F., .T.)
		lRes := .F.
		lErroProc := .T.
		Exit
	Endif

	If !lErroVlIPI .AND. !lIPIAjst
		If nTotCents > 0 .AND. nAcesIPI > 0
			If nTotCents > nAcesIPI
			//Lança o desconto
				nDescAcres := nTotCents - nAcesIPI
				nAcesIPI := 0
				nTotCents := nDescAcres
			Else //nTotCents <= nAcesIPI
			//lança o acrescimo
				nDescAcres := nAcesIPI - nTotCents
				nTotCents := 0
				nAcesIPI := nDescAcres
			EndIf
		EndIf

		If nTotCents > 0
			aCabPv[nPosDes, 02] += nTotCents
		EndIf

		//Lança o valor do IPI como FRETE
		If  nAcesIPI > 0
			aCabPv[nPosFrete, 02] += nAcesIPI
		EndIf
	EndIf

	If !lErroVlIPI  .AND. Len(aReservas) > 0

		lErroRes := .F.
		bOldError := ErrorBlock( {|x| Lj901AVE(x) } ) // muda code-block de erro

		Begin Sequence
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera o Pedido de Venda                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd(aLojas, {.T., "XX", "Loja e-commerce CiaShop"})
					aReservas := lj7Reserva( aLojas, aReservas, .T., dDtLimite, xFilial("SB2"))
				RestArea(aAreaSM0)
		Recover
			lErroRes := .T.
			RestArea(aAreaSM0)
		End Sequence

		ErrorBlock( bOldError ) // Restaura rotina de erro anterior
		If lErroRes
			aReservas := {}
			If lLjx901CEr
				Ljx901CErr("15",cPedCom, NIL, NIL,;
							NIL, cMsgTr)
			EndIf


			//Sai do Laço
			lErroProc := .T.
			cErrorCode := "15" ////problemas ao gerar reserva de produto
			Lj901ASErr(cErrorCode, .F., .T.)
			Exit
		EndIf

		//Atualização do codigo da reserva para alimentar o execAuto MATA410 na geração do pedido de venda
		If Len(aReservas) > 0
			For nT := 1 To Len(aReservas)

				If !Empty(aReservas[nT][5])

					For nP := 1 To Len(aItemPV)
					    nPosItem := aScan(aItemPV[nP], { |c| c[1] == "C6_ITEM" })//Linha do item

						If nPosItem > 0 .AND. aReservas[nT][1] == aItemPV[nP][nPosItem][2]  //Conseguiu reservar o item ?

							nPosItem := aScan(aItemPV[nP], { |c| c[1] == "C6_LOCAL" })//Linha do item
							If nPosItem = 0
								aAdd(aItemPV[nP], {"C6_LOCAL",aReservas[nT][6] , Nil } )
							Else
								aItemPV[nP][nPosItem][2] := aReservas[nT][6]
							EndIf

							aAdd(aItemPV[nP], {"C6_RESERVA",aReservas[nT][5] , Nil } )

							Lj900XLg("Gerado Reserva aItemPV  " + " Produto " +  aReservas[nT][2] +  " Reserva " + aReservas[nT][5]+ " item " + aReservas[nT][1] + " Local " + aReservas[nT][6]+ " Qtde " + cValTochar(aReservas[nT][3] ), MGU->MGU_PEDECO)

						EndIf
					Next nP
				EndIf
			Next nT
		EndIf

	EndIf

	//Grava pedido de venda
	lMsErroAuto := .F.
	lAutoErrNoFile := .T.

	//P.E. para dados adicionais do Cabeçalho do pedido de Venda
	If lLJ901APV .and. !lErroVlIPI

		aAreaAnt :=  GetArea() //WorkArea anterior
		aRetPVCab := {} //Dados adicionais do pedido de venda
		//Retorno dos dados adicionais de pedido, onde o retorno deve ser
		//Array contendo a seguinte estrutura
		//aRetPVCab , onde
		//aRetPVCab[nLin, 01] // Nome do campo
		//aRetPVCab[nLin, 02] // Valor do Campo
		//aRetPVCab[nLin, 03] // Nil
		aRetPVCab := ExecBlock("LJ901APV",.f., .f., { oAPed, oRetExtra, aCabPv,  aItemPV})

		For nR := 1 to len(aRetPVCab)
			nC := aScan(aCabPv,{ |c| RTrim(c[01]) == RTrim(aRetPVCab[nR, 01])})
			If nC = 0
				aAdd(aCabPv, aRetPvCab[nR])
			Else
				aCabPv[nC, 02] := aRetPvCab[nR, 02]
			EndIf
		Next nR

		RestArea(aAreaAnt)

	EndIf


	bOldError := ErrorBlock( {|x| Lj901AVE(x) } ) // muda code-block de erro

	LjGrvLog(cPedCom,"CIASHOP ITENS CABECALHO :",aCabPv)
	LjGrvLog(cPedCom,"CIASHOP ITENS PEDIDO :",aItemPV)

	If !lErroVlIPI
		Begin Sequence
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera o Pedido de Venda                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Lj900XLg("Verificação da filial cEmpAnt/cFilAnt" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil(),"")
				MSExecAuto({|x,y,z| Mata410(x,y,z) }, aCabPv, aItemPV, 3)
			Lj900XLg("Verificação da filial cEmpAnt/cFilAnt" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil(),"")
		   Lj900XLg("C5_DESCONT 2 " + cValToChar(SC5->C5_DESCONT) , MGU->MGU_PEDECO)
		Recover
			lMsErroAuto := .T.
			RestArea(aAreaSM0)
		End Sequence

		ErrorBlock( bOldError ) // Restaura rotina de erro anterior
	EndIf


	If lMsErroAuto
		aLog := GetAutoGrLog()
		RollBackSX8()
		Lj900XLg("Problemas na rotina automatica " + "MATA410 " + GeraErro(aLog)  ,  MGU->MGU_PEDECO )

		//Desfaz as reservas
	/*±±º          ³        [1]-Numero da Reserva                               º±±
	±±º          ³        [2]-Codigo da Loja                                  º±±
	±±º          ³        [3]-Codigo do Produto                               º±±
	±±º          ³        [4]-Local (Armazem)                                 º±±
	±±º          ³        [5]-Filial da reserva (Obrigatório se nao informar  º±±
	±±º          ³            o codigo da loja                                º±±
	*/

		lErroRes := .F.
		bOldError := ErrorBlock( {|x| Lj901AVE(x) } ) // muda code-block de erro
		If lLjx904ErrE .And. lAutoErrNoFile
			aadd(aLog, cMsgTr)
			Ljx904ErrE(aLog,Nil,"PEDI",cPedecom,Nil,Nil)
		EndIf
		Begin Sequence
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancela Reservas                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aEval(aReservas, { |r| If(!Empty(r[5]), aAdd(aResCanc, { r[5], r[04], r[02], r[06], If(!Empty(xFilial("SB2")),xFilial("SB2"), cFilAnt)  , r[1]}),  )})
			If Len(aResCanc) > 0
				Lj900XLg("Cancelando reservas realizadas " + "MATA410 ",  MGU->MGU_PEDECO, aResCanc )

				Lj7CancRes( aResCanc ,.t., .f., .t. )
				RestArea(aAreaSM0)
			Endif
		Recover
			lErroRes := .T.
		End Sequence

		ErrorBlock( bOldError ) // Restaura rotina de erro anterior

		If lErroRes
			If lLjx901CEr
				Ljx901CErr("17",cPedecom, NIL, NIL,;
						NIL, cMsgTr)
			EndIf
			lErroProc := .T.
			cErrorCode := "17" //Problemas ao desfazer reserva pois pedido náo foi feito
			Lj901ASErr(cErrorCode, .F., .T.)
			Exit

		Else
			If lLjx901CEr
				Ljx901CErr("10",cPedecom, NIL, NIL,;
							NIL, cMsgTr)
			EndIf
			lErroProc := .T.
			cErrorCode := "10" //problemas na geração do Pedido de Venda
			Lj901ASErr(cErrorCode, .F., .T.)
			Exit

		EndIf

		lRes := .F.
		RestArea(aAreaSM0)
	ElseIf !lErroVlIPI
		lRes := .T.

		Lj901StA(.T.) //Setup de Execauto de Orçamento

		//Ponto de entrada após execução do orçamento
		If ExistBlock("Lj901SC5")
			ExecBlock("Lj901SC5",.f., .f., { SC5->C5_FILIAL, SC5->C5_NUM })
		EndIf


		RestArea(aAreaSM0)
		//Gera os dados do Orçamento - Sl1
		Lj901ACrOr(aCabPV,	aItemPV,	@aSLQ,	@aSLR, ;
		@aSL4, SAE->AE_COD + " - " + SAE->AE_DESC, 	SAE->AE_TIPO, 	aProdutos, ;
		SC5->C5_NUM, 	nSubVlr, 	nTotalPed, 	aParcela,;
		oAPed,			lGerSE1, oRetExtra,lIPIAjst, aItemPV2)

		cRetErro := ""
		RestArea(aAreaSM0)

		//Gera o orçamento e o Título de contas a Receber
		If !Lj901AGOrT(	aSLQ,		aSLR,			aSL4, 		nValTaxAdm, ;
			lAdmProp, 	SAE->AE_COD, 	cCondPag,	@cRetErro,;
			lGerSE1,oRetExtra, oAPed, aReservas, @lErroProc) //realiza o cancelmanto da reservar
			cErrorCode := cRetErro //Erro na geracao do orçamento gerado
			Lj901ASErr(cErrorCode, .F., .T.)
			lErroProc := .T.
			lRes := .F.
			Exit
		EndIf



		RestArea(aAreaSM0)

	Endif


	Exit
EndDo

	Lj901StA(.F.) //Setup de ExecAuto de Orçamento
	Lj901StI(.F.) //Setup de Venda com IPI
	//Apaga a variável statica da Administradora
	Lj901ASAE("")


	If !lErroProc
		lTranBD := .F.
		Lj900XLg("FINALIZANDO CONTROLE TRANSACIONAL NO PROCESSAMENTO DA VENDA E-COMMERCE " + cCliEnt + "/" + cLojaEnt + " CGC/CPF" + cBusca + "Filial Pedido "+cFilAnt, MGU->MGU_PEDECO)
		If lConfUni
			lConfPedUn := Lj901ACnP(cOrderID, oWS, @cXMLPedUn)
		EndIf

	Else
	    DisarmTransaction()
	    lTranBD := .F.
	  	Lj900XLg("DESFAZENDO CONTROLE TRANSACIONAL NO PROCESSAMENTO DA VENDA E-COMMERCE  " + cCliEnt + "/" + cLojaEnt + " CGC/CPF" + cBusca + "Filial Pedido "+cFilAnt, MGU->MGU_PEDECO)
	    Lj901ASErr(cErrorCode, .T., .F.)//ROTINA DE ERRO DO PEDIDO
	    lRes := .F.
		Break //FECHAR CONTROLE DE TRANSAÇÃO(DisarmTransaction()) APÓS GRAVAÇÃO DO LOG DE ERROS.
	EndIf

End Transaction

Return lRes

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901ATrB
Retorna a transportadora dado o método de entrega
@param   	cMetodo - Metodo de Entrega
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs
@sample Lj901ATrB(cMetodo)
/*/
//-------------------------------------------------------------------

Static Function Lj901ATrB(cMetodo)
Local cCodTransp := "" //Codido da Transportadora
Local aArea := SA4->(GetArea()) //WorkArea

SA4->(DbSetOrder(4)) //SA4_FILIAL + SA4_ECSERVI

If SA4->(DbSeek(xFilial("SA4") + PadR(RTrim(cMetodo), TamSx3("A4_ECSERVI")[1])))
	cCodTransp := SA4->A4_COD
ElseIf SA4->(DbSeek(xFilial("SA4") + PadL(RTrim(cMetodo), TamSx3("A4_ECSERVI")[1],"0"))) ////Valida com o código preenchido com zeros
	cCodTransp := SA4->A4_COD
EndIf

RestArea(aArea)

Return cCodTransp

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901ADtWS
Converte a Data recebida do WS
@param   	cAData - Data
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs
@sample Lj901ADtWS(cAData)s)
/*/
//-------------------------------------------------------------------
Static function Lj901ADtWS(cAData)

local cData := "" //Data

cData += SubStr(cAData, 1, 4)
cData += SubStr(cAData, 6, 2)
cData += SubStr(cAData, 9, 2)

return SToD(cData)

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901GIt
Gera os Dados do Item
@param   	oAItem - Objeto do Item
@param   	nCont - Contador
@param   	cATes - TES
@param   	lGerSE1 - Gera SE1
@param   	aKit - Dados do Kit
@param   	oRetExtra - Campos Extra do Produto
@param   	lResEst - Reserva Estoque
@param   	dDtLimite - Data Limite da Reserva
@param   	aEstoques - Locais de Estoque
@param   	aReservas - Reservas
@param   	cDescr - Descrição do Produto
@param   	cB1_COD - Codigo do Produto
@param   	nTotDescont - Total de Desconto
@param   	lMvLjIPEn - Calcula IPI Embutido?
@param   	aItemPed - Itens do Pedido
@param   	nSubVlr - Subtotal do Pedido
@param   	nTotDescIt - Desconto do Item
@param   	lProdIPI - Produto com IPI?
@param   	lUltItem - Ultimo Item?
@param   	cTpSelEst - Tipo de Seleção do Local de Estoque
@param   	nTamProd - Tamanho do Produto
@param   	nTamLocal - Tamanho do Local de Estoque
@Param 		cLjEcPe - Local de Estoque padrão
@param   	lMultEst - Multiestoque habilitado
@Param 		cArmzEC - Local de Estoque
@Param		cTurno - Turno do periodo do pedido de venda
@Param      lIPIAjst - Ajusta o valor do IPI
@Param		aItemPV2 - Itens do Pedido de Venda
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs
@sample Lj901GIt(oAItem, nCont, cATes, lGerSE1, ;
							aKit, oRetExtra, lResEst, dDtLimite,;
							aEstoques, aReservas, cDescr, cB1_COD,;
							nTotDescont, lMvLjIPEn , aItemPed, nSubVlr ,;
							nTotDescIt, lProdIPI, lUltItem, cTpSelEst, ;
							nTamProd, nTamLocal, cLjEcPe,lMultEst,;
							cArmzEC,cTurno, lIPIAjst, aItemPV2,;
							nTamSC6It, cItemAnt, nPerJur)
/*/
//-------------------------------------------------------------------

Static function Lj901GIt(oAItem, nCont, cATes, lGerSE1, ;
							aKit, oRetExtra, lResEst, dDtLimite,;
							aEstoques, aReservas, cDescr, cB1_COD,;
							nTotDescont, lMvLjIPEn , aItemPed, nSubVlr ,;
							nTotDescIt, lProdIPI, lUltItem, cTpSelEst, ;
							nTamProd, nTamLocal, cLjEcPe,lMultEst,;
							cArmzEC,cTurno, lIPIAjst, aItemPV2,;
							nTamSC6It, cItemAnt)

local aItem    := {} //Dados do Item
local cProduto := oAItem:_PF_ID:TEXT //Produto
local nQtdVen  := VAL(oAItem:_QUANTITY:TEXT) //quantidade
local nTotal   := (VAL(oAItem:_ADJUSTED_PRICE:TEXT) / 100) //Total
local nValor   := (VAL(oAItem:_ADJUSTED_PRICE:TEXT) / 100) / nQtdVen //Valor
Local nPrcUni	:= VAL(oAItem:_LIST_PRICE:TEXT)/100
Local lLj901PIt := ExistBlock("Lj901PIt") //Ponto de Entrada Ativo
Local aAreaAnt 	:= {} //WorkArea Anterior
Local aRetItPV 	:= {} //Retorno do Ponto de Entrada
Local nR 		:= 0 //Contador
Local nPosQtde 	:= 0 //Posicao da Quantidade
Local nPosLocal := 0 //Poiscao do Local de Estoque
Local nPosItem 	:= 0 //Posicao do Item
Local aReserva 	:= {} //Array de Reservas
Local aLocal 	:= {} //Local de Estoque
Local nPosReserva := 0 //Posicao da Reserva
Local nPosPRCUni := 0 //Posição do preço untário
Local nProp		:= 0 //Proporcionalidade do desconto
Local nValDescIt	:= 0 //valor do desconto no item
Local lItIPI 	:= .F. //Item com IPI?
Local aSaldosIt	:= {} //Saldos em estoque do item
Local nQtdDisp 	:= 0 //Quantidade disponível
Local cLocalSel := "" //Local de Estoque Selecionado
Local nC 		:= 0 //Contador
Local nTamEst 	:= 0 //Tamanho do Local de Estoque

Default cTurno := ""

If Len(aKit) > 0

	cProduto := aKit[1] //Produto
	nQtdVen  := aKit[2] //quantidade
	nTotal   := aKit[4] //Total
	nValor   := aKit[3] //Valor
	nPrcUni := aKit[5]
EndIf


if nTotal == 0.00
	nValor := 0.01
	nTotal := 0.01*nQtdVen
EndIf


cItemAnt := Soma1(cItemAnt, nTamSC6It)
If lMvLjIPEn

	lItIPI := GetAdvFVal("SF4","F4_IPI",xFilial("SF4")+ cATes, 1, "N")  == "S"

	If lItIPI
		lProdIPI := .T.
	EndIf

	If !lUltItem
		nProp :=  nTotal/nSubVlr
		nValDescIt :=  A410Arred( (nTotDescont * nProp)/nQtdVen , "C6_VALDESC", _MoedaDef )
	Else
		nValDescIt := Max(nTotDescont - nTotDescIt, 0)
		nValDescIt :=  A410Arred( nValDescIt/nQtdVen , "C6_VALDESC", _MoedaDef )
	EndIf

	nTotDescIt += (nValDescIt * nQtdVen)

	Lj900XLg(" Desconto Total rateado no item " +cItemAnt  +  " " + cValToChar(nValDescIt), MGU->MGU_PEDECO)

	aAdd(aItemPed, {nTotal, 0, 0, 0,;
					 0, nValDescIt, (SB1->B1_PESBRU * nQtdVen),GetAdvFVal("SF4","F4_ISS",xFilial("SF4")+ cATes, 1, "N") == "N", ;
					 0, 0 , 0})

EndIf

If !lMultEst .OR. Empty(cArmzEC)
	//Apuração do Local de Estoque
	If cTpSelEst <> "0" .and. Empty(cLjEcPe)
		nTamEst := Len(aEstoques)
		//Apura o saldo em estoque do item
		nQtdDisp := 0 //Quantidade disponível
		cLocalSel := ""
		For nC := 1 to nTamEst
			cLocalSel := aEstoques[nC]
			nQtdDisp := Lj904XEL(cProduto, cLocalSel, nTamProd, nTamLocal )
			If nQtdDisp >= nQtdVen
				aAdd( aSaldosIt, { cLocalSel, nQtdDisp})
				//Primeiro Local de Estoque cadastrado no Parâmetro MV_LJECOMG
				If cTpSelEst == "1"
					Exit
				EndIf
			EndIf
		Next nC

		If cTpSelEst = "2"
			//Ordem decrescente de saldo
			aSort( aSaldosIt, , , { |x, y | x[2] > y[2]})
		ElseIf cTpSelEst = "3"
			//Ordem crescente de saldo
			aSort( aSaldosIt, , , { |x, y | x[2] < y[2]})
		EndIf

		cLocalSel := ""
		If Len(aSaldosIt) > 0
			cLocalSel :=  aSaldosIt[1, 1]
		Else
			//pega o primeiro do Parametro aLocais
			If nTamEst > 0
				cLocalSel := aEstoques[1]
			EndIf
		EndIf
	ElseIf !Empty(cLjEcPe)
		cLocalSel := cLjEcPe
	EndIf
Else
	cLocalSel := cArmzEC
EndIf



aAdd(aItem, {"C6_ITEM"   , cItemAnt, Nil})
nPosItem :=  Len(aItem)
aAdd(aItem, {"C6_PRODUTO", cProduto , Nil})
aAdd(aItem, {"C6_QTDVEN" , nQtdVen, Nil})
nPosQtde := Len(aItem)
aAdd(aItem, {"C6_QTDLIB" , nQtdVen, Nil})
aAdd(aItem, {"C6_PRCVEN" , nValor, Nil})
aAdd(aItem, {"C6_VALOR"  , nTotal, Nil})
aAdd(aItem, {"C6_TES"    , cATes, Nil})
If (cTpSelEst <> "0" .OR. !Empty(cLjEcPe) .OR. lMultEst ) .AND. !Empty(cLocalSel)
	aAdd(aItem, {"C6_LOCAL"    , cLocalSel, Nil})
EndIf

If !Empty(cTurno)
	aAdd(aItem, {"C6_TURNO"    , cTURNO, Nil})
EndIf

aAdd(aItem, {"C6_PRUNIT", nValor		,NIL })		// Preco de tabela
nPosPRCUni := Len(aItem)

//P.E. para dados adicionais dos itens do pedido de Venda
If lLj901PIt

	aAreaAnt :=  GetArea() //WorkArea anterior
	aRetItPV := {} //Dados adicionais do item pedido de venda
	//Retorno dos dados adicionais do item, onde o retorno deve ser
	//Array contendo a seguinte estrutura
	//aRetPVCab , onde
	//aRetPVCab[nLin, 01] // Nome do campo
	//aRetPVCab[nLin, 02] // Valor do Campo
	//aRetPVCab[nLin, 03] // Nil
	aRetItPV := ExecBlock("Lj901PIt",.f., .f., { oAItem, oRetExtra, aItem })

	For nR := 1 to len(aRetItPV)
		aAdd(aItem, aRetItPV[nR])
	Next nR

	RestArea(aAreaAnt)

EndIf

nPosReserva := aScan(aItem, { |it| it[1] == "C6_RESERVA"})

lResEst := lResEst .AND.  GetAdvFVal("SF4","F4_ESTOQUE",xFilial("SF4")+ cATes, 1, "N") == "S"
If lResEst .and. nPosReserva == 0
	//Local pode vir por p.e
	nPosLocal :=  aScan(aItem, { |it| it[1] == "C6_LOCAL"})
	aLocal := aClone(aEstoques)
	If nPosLocal > 0
		aLocal := {aItem[nPosLocal, 02]}

	Else

		aLocal := aClone(aEstoques)
	EndIf

	Lj900XLg("Selecionando produto para a reserva " + " Produto " +  cB1_COD + "Item " +  aItem[nPosItem, 02], MGU->MGU_PEDECO)

	aReserva := {.T., ;
					aItem[nPosItem, 02],;
					cB1_COD,;
					cDescr,;
					aItem[nPosQtde, 02],;
					aLocal}

	If Len(aReserva) > 0
		aAdd(aReservas, aClone(aReserva))
	EndIf
EndIf


If lIPIAjst
	aItTmp := {}
	aAdd(aItTmp, {"C6_ITEM"   , cItemAnt, Nil})
	aAdd(aItTmp, {"_ECVALOR"  , nTotal, Nil})

	aAdd(aItemPV2, aClone(aItTmp))
EndIf

return aItem

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901ASErr
Grava o código do Erro
@param   	cACodErro - Codigo do Erro
@param		lGravaErro - Grava Erro na Tabela
@param		lGeraLog  - Gera Log do erro
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs
@sample Lj901ASErr(cACodErro)
/*/
//-------------------------------------------------------------------
Static Function Lj901ASErr(cACodErro, lGravaErro, lGeraLog)

//Vide Lj903DErr //FONTE LOJR903.PRW

Default lGravaErro := .T.
Default lGeraLog := .T.

If lGravaErro
	RecLock("MGU", .F.)
	MGU->MGU_MOTERR := cACodErro
	MGU->(MsUnLock())
EndIf

If lGeraLog
	Lj900XLg("Detectada ocorrência [" + cACodErro + "] no Pedido . " + CRLF + "Descrição do Erro [ " + Lj903DErr(cACodErro) + " ]" , MGU->MGU_PEDECO)
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901AEnt
Verifica se endereço de entrega é diferente do cliente, caso seja, cria nova loja
@param   	cCliente - Codido do Cliente
@param   	cLoja - Codigo da Loja
@param   	oAPed - Objeto do pedido
@param		lErrorCli - Erro ao inserir cliente de entrega
@param		cCliCod - Codigo do Cliente de Entrega
@param		cBusca -CGC/CPF do Cliente
@param		lPedMktPlc - Pedido inserido via MarketPlace (não valida cnpj em duplicidade, por exemplo)
@param		oNodeCompl  - Objeto que conterá o complemento
@param		oNodeDocId - Objeto que conterá o numero do documento
@param		oNodeDocTy - Objeto que conterá o tipo do documento
@param		lMultEst - Pedido com MultiEstoque
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs
@sample Lj901AEnt( cCliente, cLoja , oAPed)
/*/
//-------------------------------------------------------------------
Static Function Lj901AEnt(  cCliente    , cLoja     , oAPed     , lErrorCli ,;
							cCliCod     , cBusca    , lPedMktPlc, oNodeCompl,;
							oNodeDocId  , oNodeDocTy, lMultEst  )
Local aArea	:= GetArea()      				//WorkArea Atual
Local cCliEnt := ""           				//Loja do Cliente de entrega - retorno da rotina
Local aAreaSA1 := SA1->(GetArea()) 			//WorkArea SA1
Local cLojaUlt := cLoja             		//Loja de Entrega
Local cNomeCid := ""							//Nome da Cidade
Local cEstado := ""							//Estado
Local cAliasCid := GetNextAlias()			//Alias de Consulta da Cidade
Local aCli		:= {}							//Dados do Cliente
Local cFilSA1 := xFilial("SA1")				//Filial do Cliente
Local nC := 0 								//Contador
Local nTamLoja := TamSx3("A1_LOJA")[1] 		//Tamanho do campo loja
Local aDadosEnd := {} 						//Dados de Entrega
Local cSql := "" 							//Consulta SQL
Local bOldError := NIL						//Code-block de erro da rotina
Local cInscr := "ISENTO"					//Inscrição do Cliente
Local lLJ901SA1:= ExistBlock("LJ901SA1") 	// p.e. de inclusão de dados adicionais de cliente
Local aAreaAnt := {}						//WorkArea Anterior
Local aCliPE := {} 							//Dados do Cliente do PE
Local cCompl		:= ""
						//Id do documento
Local cTpDocId	:= ""						//Tipo do documento pessoa física
Local aLog      := {}
Local lCNPJ     := Len(cBusca) > 11
Local oNodeIBGE := Nil
Local lUsaIBGE  := .T.
Local cCodMun   := ""
Local cCodUF    := ""
Local cMsgTr		:= STR0019 //"CONTROLE TRANSACIONAL HABILITADO. As informações geradas durante processamento deste pedido serão desfeitas."

Default lPedMktPlc := .F.
Default lMultEst	:= .F.

cCliEnt := cLoja
Lj900XLg("Localizando endereço de entrega do cliente " + cCliente + "/" + cLoja + " CGC/CPF" + cBusca, MGU->MGU_PEDECO)

If ((GetNewPar("MV_VALCNPJ","1") == "1" .And. lCNPJ)  .Or. (GetNewPar("MV_VALCPF","1") == "1" .And. !lCNPJ) ) .or. lPedMktPlc .or. lMultEst


	oNodeCompl := XmlChildEx ( oAPed:_RECEIPT_SHOPPER, "_SHIP_TO_STREET_COMPL" )

	If ValType(oNodeCompl) == "O"
		cCompl := oNodeCompl:TEXT
	EndIf

	aDadosEnd := {{ "A1_END", Upper(oAPed:_RECEIPT_SHOPPER:_SHIP_TO_ADDRESS1:TEXT + ", " + oAPed:_RECEIPT_SHOPPER:_SHIP_TO_STREET_NUMBER:TEXT)},;
	{ "A1_EST", Upper(oAPed:_RECEIPT_SHOPPER:_SHIP_TO_ADDRESS3:TEXT), ".T."},;
	{ "A1_BAIRRO", Upper(oAPed:_RECEIPT_SHOPPER:_SHIP_TO_DISTRICT:TEXT)},;
	{ "A1_COMPLEM", Upper(cCompl)},;
	{"A1_CEP", Upper(oAPed:_RECEIPT_SHOPPER:_SHIP_TO_ADDRESS4:TEXT) } }

	Lj900XLg("Indentificando cadastro do endereço  " + cCliente + "/" + cLoja +  "endereço " + Upper(oAPed:_RECEIPT_SHOPPER:_SHIP_TO_ADDRESS1:TEXT + ", " + oAPed:_RECEIPT_SHOPPER:_SHIP_TO_STREET_NUMBER:TEXT), MGU->MGU_PEDECO)

	cNomeCid := StrTran(AllTrim(Upper(FwNoAccent(oAPed:_RECEIPT_SHOPPER:_SHIP_TO_ADDRESS2:TEXT))),"'","")
	Lj900XLg("Cidade Pedido EC " + cNomeCid , MGU->MGU_PEDECO )

	cEstado  := AllTrim(NoAcento(Upper(oAPed:_RECEIPT_SHOPPER:_SHIP_TO_ADDRESS3:TEXT)))

	//Validação do campo do IBGE
	oNodeIBGE := XmlChildEx ( oAPed:_RECEIPT_SHOPPER, "_SHIP_TO_IBGE_CODE" )
	If ValType(oNodeIBGE) <> "O"
		lUsaIBGE := .F.
		Lj900XLg("Sem a Tag do Codigo IBGE." , MGU->MGU_PEDECO)
	EndIf

	If lUsaIBGE
		Lj900XLg("Utilização do Codigo IBGE:" + oAPed:_RECEIPT_SHOPPER:_SHIP_TO_IBGE_CODE:TEXT , MGU->MGU_PEDECO)
		cCodMun := oAPed:_RECEIPT_SHOPPER:_SHIP_TO_IBGE_CODE:TEXT
		cCodUF  := Padr(If( !Empty(cCodMun),SubStr(cCodMun,1,2),""),TamSx3("CC2_EST")[1])
		cCodMun := Padr(If( !Empty(cCodMun),SubStr(cCodMun,3,7),""),TamSx3("CC2_CODMUN")[1])

		If cEstado <> Lj901AUF(cCodUF)
			cEstado :=	Lj901AUF(cCodUF)
		EndIf

		CC2->(DbSetOrder(1))
		If !Empty(cCodMun) .And. CC2->(DbSeek(xFilial("CC2") + cEstado +  cCodMun ))
			cNomeCid := AllTrim(CC2->CC2_MUN)
		Else
			cCodMun := ""
		EndIf
	EndIf

	If lUsaIBGE .And. !Empty(cCodMun)
		aAdd(aDadosEnd, {"A1_COD_MUN", cCodMun})
	Else
		cSQL := " SELECT CC2_CODMUN "
		cSQL += " FROM " + RetSqlName("CC2") + " CC2 "
		cSQL += " WHERE CC2_FILIAL = '" + xFilial("CC2") + "' "
		cSQL += " AND CC2_EST = '" + cEstado + "' "
		cSQL += " AND LTRIM(RTRIM(CC2_MUN)) = '" + cNomeCid + "' "
		cSQL += " AND D_E_L_E_T_ <> '*' "

		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cSQL),cAliasCid, .F., .T.)

		(cAliasCid)->(DBGoTop())
		If !(cAliasCid)->(Eof())
			aAdd(aDadosEnd, {"A1_COD_MUN", (cAliasCid)->CC2_CODMUN})
		Else
			aAdd(aDadosEnd, {"A1_MUN", cNomeCid})
		Endif

		(cAliasCid)->(dbCloseArea())
	EndIf

	If !lMultEst .AND. !lPedMktPlc .AND. !Lj901ARtCl(aDadosEnd, cCliente, cLoja, @cLojaUlt, @cCliCod, cBusca )
		cCliEnt := cLojaUlt
		Lj900XLg("Endereço localizado  " + cCliCod + "/" + cCliEnt , MGU->MGU_PEDECO)

	Else //Insere
		If lPedMktPlc .Or. lMultEst
			If !ExistFunc("Lj901CliCod")
				cCliente := GETSXENUM("SA1","A1_COD")
				cLojaUlt := StrZero(1, TAMSX3("A1_LOJA")[1]) //Codigo da Loja
			Else
				Lj901CliCod(@cCliente, @cLojaUlt)
			EndIf
			cCliCod := cCliente
		Else
			cLojaUlt := PadR(cLojaUlt, SA1->(TamSx3("A1_LOJA")[1]))
			cCliCod := cCliente
		EndIf

		If !Empty(cCliente + cLojaUlt)
			If !lPedMktPlc .and. !lMultEst
				//Busca os dados do cliete
				SA1->(DbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
				SA1->( DbSeek( cFilSA1 +  cCliente +  cLoja)) //Muda o ponteiro para o topo
				aAdd(aDadosEnd, {"A1_NOME"   , SA1->A1_NOME, Nil})
				//Se inscrição foi diferente, muda para isento
				If AllTrim(Upper(SA1->A1_EST)) <> cEstado .AND. !Empty(SA1->A1_INSCR)
					cInscr := "ISENTO"
				Else
					cInscr := RTrim(SA1->A1_INSCR)
				EndIf

				aAdd(aDadosEnd, {"A1_INSCR"  , cInscr, ".T."})
				AAdd(aDadosEnd, {"A1_CODPAIS", SA1->A1_CODPAIS, ".T."})
				aAdd(aDadosEnd, {"A1_NREDUZ" , SA1->A1_NREDUZ, Nil})

				aAdd(aDadosEnd, {"A1_TIPO"   , SA1->A1_TIPO, Nil})
				aAdd(aDadosEnd, {"A1_EMAIL"  , SA1->A1_EMAIL, Nil})
				aAdd(aDadosEnd, {"A1_DTNASC" , SA1->A1_DTNASC, Nil})
				aAdd(aDadosEnd, {"A1_PESSOA" , SA1->A1_PESSOA, Nil})
				aAdd(aDadosEnd, {"A1_PFISICA" , SA1->A1_PFISICA, Nil})
				aAdd(aDadosEnd, {"A1_MSBLQL"  , IIF( Empty(SA1->A1_MSBLQL), "2",SA1->A1_MSBLQL), Nil})

				aAdd(aDadosEnd, {"A1_CGC"     , SA1->A1_CGC, Nil})


				SA1->(DbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
				SA1->( DbSeek( cFilSA1)) //Muda o ponteiro para o topo
				cLojaUlt := PadR(AllTrim(cLojaUlt), nTamLoja)

				Do While SA1->( DbSeek( cFilSA1 + cUltiCli + cLojaUlt) )

					cLojaUlt := Soma1(cLojaUlt, nTamLoja)
					cLojaUlt := PadR(AllTrim(cLojaUlt), nTamLoja)
				EndDo
			Else
				aAdd(aDadosEnd, {"A1_NOME"   , Alltrim(Upper(oAPed:_RECEIPT_BILLING:_NAME:TEXT)), Nil})
				aAdd(aDadosEnd, {"A1_NREDUZ" , Alltrim(Upper(oAPed:_RECEIPT_BILLING:_NAME:TEXT)), Nil})
				aAdd(aDadosEnd, {"A1_CODPAIS", "01058", ".T."})
				aAdd(aDadosEnd, {"A1_TIPO"   , "F", Nil})
				aAdd(aDadosEnd, {"A1_EMAIL"  , Upper(oAPed:_RECEIPT_BILLING:_EMAIL:TEXT), Nil})
				aAdd(aDadosEnd, {"A1_CGC"     , cBusca, Nil})
				aAdd(aDadosEnd, {"A1_MSBLQL"  , "2", Nil})

				IF Upper(oAPed:_RECEIPT_BILLING:_CUSTOMER_TYPE:TEXT) == 'PERSON'
					aAdd(aDadosEnd, {"A1_PESSOA" , "F", Nil})

					oNodeDocId := XmlChildEx ( oAPed:_RECEIPT_BILLING, "_REGIONAL_DOCUMENT_ID" )

					If ValType(oNodeDocId) == "O"
						cInscr := oNodeDocId:TEXT
					EndIf

					oNodeDocTy := XmlChildEx ( oAPed:_RECEIPT_BILLING, "_REGIONAL_DOCUMENT_TYPE" )

					If ValType(oNodeDocTy) == "O"
						cTpDocId := oNodeDocTy:TEXT
					EndIf

					If !Empty(cInscr) .AND. Upper(cTpDocId) == "RG"

						aAdd(aDadosEnd, {"A1_PFISICA" , cInscr, Nil})
					EndIf

					aAdd(aDadosEnd, {"A1_INSCR"  , "ISENTO", ".T."})


				Else
					aAdd(aDadosEnd, {"A1_PESSOA" , "J", Nil})
					//regional_document_id

					oNodeDocId := XmlChildEx ( oAPed:_RECEIPT_BILLING, "_REGIONAL_DOCUMENT_ID" )

					If ValType(oNodeDocId) == "O"
						cInscr := oNodeDocId:TEXT
					EndIf

					//Verifica se IE em branco para jogar isento
					If Empty(cInscr) .OR. !IE(cInscr, cEstado, .F.)
						Lj900XLg("Inscrição em branco/invalida para pessoa juridica, considerado ISENTO", cValTochar(MGU->MGU_PEDECO) )
						cInscr := "ISENTO"
					EndIf

					aAdd(aDadosEnd, {"A1_INSCR"  ,  cInscr, ".T."})
				EndIF

			EndIf

			cCliEnt := cLojaUlt
			aAdd(aCli, {"A1_COD"   , cCliente     , ".T." })
			aAdd(aCli, {"A1_LOJA"   ,   cCliEnt, ".T."})

			aAdd(aCli, {"A1_CONTATO" , Upper(oAPed:_RECEIPT_SHOPPER:_SHIP_TO_NAME:TEXT), Nil}) //contato
			aAdd(aCli, {"A1_DDD"    , Upper(oAPed:_RECEIPT_SHOPPER:_SHIP_TO_DDD_PHONE:TEXT), Nil})
			aAdd(aCli, {"A1_TEL"    , Upper(oAPed:_RECEIPT_SHOPPER:_SHIP_TO_PHONE:TEXT), Nil})

			For nC := 1 to Len(aDadosEnd)
				aAdd(aCli, {aDadosEnd[nC, 1], aDadosEnd[nC, 2], nil})
			Next

			If lLJ901SA1 // p.e. de inclusão de dados adicionais de cliente

				Lj900XLg("Executando p.E. " + "LJ901SA1" , MGU->MGU_PEDECO, aCli )
				aAreaAnt := GetArea()
				//Retorno dos dados adicionais de pedido, onde o retorno deve ser
				//Array contendo a seguinte estrutura
				//aCli[n] , onde
				//aCli[n] [nLin, 01] // Nome do campo
				//aCli[n] [nLin, 02] // Valor do Campo
				//aCli[n] [nLin, 03] // Nil
				aCliPE := ExecBlock("LJ901SA1",.f., .f., { 2, aCli,NIL ,oAPed })

				If Len(aCliPE) > 0
					aCli := aClone(aCliPE)
				EndIf

				Lj900XLg("Executado p.E. " + "LJ901SA1",MGU->MGU_PEDECO, aCliPE )

				RestArea(aAreaAnt)
			EndIf

			//Insere o cliente
			lMsErroAuto := .f.
			lAutoErrNoFile := .T.

			bOldError := ErrorBlock( {|x| Lj901AVE(x) } ) // muda code-block de erro

			Begin Sequence
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera o Cliente                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Lj900XLg("Verificação da filial cEmpAnt/cFilAnt" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil(),"")
				Lj900XLg("Gerando cliente " + cCliente +  "/" + cCliEnt,  MGU->MGU_PEDECO )

				MsExecAuto({|x,y| Mata030(x,y)}, aCli, 3)
				Lj900XLg("Verificação da filial cEmpAnt/cFilAnt" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil(),"")

			Recover
				lMsErroAuto := .T.
			End Sequence

			ErrorBlock( bOldError ) // Restaura rotina de erro anterior

			IF lMsErroAuto

				For nC := 1 to len(aCli)
					AutoGrLog( " " + aCli[nC,1] + ": " + cValToChar(aCli[nC,2]) )
				Next nC
				aLog := GetAutoGrLog()

				Lj900XLg("Problemas na rotina automatica " + "MATA030 " + GeraErro(aLog)  ,  MGU->MGU_PEDECO )
				cCliEnt := cLoja
				cCliCod := cCliente

				lErrorCli := .T.

				If lPedMktPlc
					Lj900XLg("Problemas na rotina automatica Cliente MarketPlace" ,  MGU->MGU_PEDECO   )

					RollBackSX8()
				EndIf

				If lLjx904ErrE
					aadd(aLog, cMsgTr)
					Ljx904ErrE(aLog,2,"CLIE",MGU->MGU_PEDECO ,Nil,Nil)
				EndIf
			Else
				cCliCod := SA1->A1_COD
				cCliEnt := SA1->A1_LOJA
				If lPedMktPlc .OR. lMultEst
					ConfirmSX8()
				EndIf
			EndIF

		EndIf
	EndIf


EndIf

If !lPedMktPlc .AND. !lMultEst
	RestArea(aAreaSA1)
	If ValType(oNodeCompl) = "O"
		FreeObj(oNodeCompl)
	EndIf
	If ValType(oNodeDocId) = "O"
		FreeObj(oNodeDocId)
	EndIf
	If ValType(oNodeDocTy)= "O"
		FreeObj(oNodeDocTy)
	EndIf

EndIf
RestArea(aArea)

Return cCliEnt

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901ARtCl
Verifica se os Endereço do Pedido não existe para inserir
@param   	aDadosEnd - Array contendo os campos de endereço onde [1] - Nome do Campo , [2] - Valor
@param   	cCliente - Codido do Cliente
@param   	cLoja - Codigo da Loja
@param   	cLojaUlt - Ultimo Cliente Inserido
@param		cCliCod  - Codigo do Cliente Localizado
@param		cBusca	- CPF/CNPJ do Cliente
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs
@sample Lj901ARtCl(aDadosEnd, cCliente, cLoja, cLojaUlt )
/*/
//-------------------------------------------------------------------
Static Function Lj901ARtCl(aDadosEnd, cCliente, cLoja, cLojaUlt, cCliCod, cBusca)
Local lInsere := .T. //Insere o registro
Local cFilSA1 := xFilial("SA1") //Filial SA1
Local lIgual := .F.   //Registros iguais
Local nA	:= 0 //Contador
Local cDadCli := ""
Local nTDadCli:= 0
Local cDadBco	:= ""

Static cUltiCli := "" // Codigo do ultimo cliente pesquisado de acordo com o CPF/CNPJ

DbSelectArea("SA1")
DbSetOrder(3) //A1_FILIAL + A1_CGC
DbSeek(cFilSA1 + cBusca)
cLojaUlt := cLoja
cCliCod := SA1->A1_COD

If Len(aTamEndCli) == 0 .And. Len(aDadosEnd) > 0
	For nA := 1 to Len(aDadosEnd)
		AAdd(aTamEndCli ,{ aDadosEnd[nA, 01], TamSx3(aDadosEnd[nA, 01])[1]})
	Next nA
EndIf

Do While lInsere .And. (!Eof() .And. A1_FILIAL + RTrim(A1_CGC) == cFilSA1 + RTrim(cBusca))

	Lj900XLg("Localizando endereço do cliente  " + A1_COD + "/" + A1_LOJA +  " CPF/CNPJ " +A1_CGC, MGU->MGU_PEDECO)

	cLojaUlt := A1_LOJA
	cCliCod   := A1_COD

	lIgual := .F.
	nA := 0

	For nA := 1 to Len(aDadosEnd)
		cDadCli := aDadosEnd[nA, 02]

		If (nTDadCli := aScan(aTamEndCli,{ |x| x[01] == aDadosEnd[nA,01]})) > 0
			cDadCli := PadR(cDadCli , aTamEndCli[nTDadCli,02] )
		EndIf

		cDadCli := FwNoAccent(Upper(RTrim(cDadCli)))
		cDadBco := FwNoAccent(RTrim(Upper(&(aDadosEnd[nA, 01]))))

		lIgual := cDadBco  == cDadCli

		If !lIgual
			Exit
		EndIf
	Next

	lInsere := !lIgual

	DbSkip(1)
EndDo

Lj900XLg("Final localização endereço do cliente  " + cCliCod + "/" + cLojaUlt +  " CPF/CNPJ " +cBusca + "Localizado " + cValtoChar(!lInsere), MGU->MGU_PEDECO)

cUltiCli := cCliCod // Recebendo o codigo do ultimo cliente pesquisado

Return lInsere

//-------------------------------------------------------------------
/*/{Protheus.doc} lj901ABPed
Verifica se o pedido já existe
@param   	cPedCom - Codigo do Pedido
@param   	cC5_NUM - Número do Pedido
@param   	lGerSE1 - Gera título
@param 		cErrorCode - Codigo da Mensagem de Erro
@return	lExiste - existe pedido gerado para confirmar
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs
@sample LOJA900A()
/*/
//-------------------------------------------------------------------
Function lj901ABPed(cPedCom, cC5_NUM, lGerSE1, cErrorCode, cC5_PEDECO)
Local cSql := "" //Query
Local cAlias := GetNextAlias() //Alias da Consulta
Local lExiste := .F. //Existe Pedido?
Local cWhere := "" //Clausula da consulta
Local nTamNum		:= SE1->(TamSX3("E1_NUM")[1]) //Tamanho do número do Título
Local cFilSE1		:= xFilial("SE1") //Filial SE1
Local nTamPref   := SE1->(TamSX3("E1_PREFIXO")[1]) //Tamanho do Prefixo do título
Local aAreaSE1	:= {} //WorkArea SE1
Local aAreaSL1	:= {} //WorkArea SL1
Local cAlias2 := GetNextAlias() //Alias da Consulta

Default cPedCom := "" //Pedido e-commerce
Default cC5_NUM := "" //Numero do Pedido
Default lGerSE1 := SuperGetMv("MV_LJECOMS",.T., .F.) //Gera SE1?
Default cErrorCode := ""
Default cC5_PEDECO := ""

//Condicional para a query
cWhere := "%"
cWhere += " C5_FILIAL = '" + xFilial("SC5") + "'"
cWhere += " AND C5_PEDECOM = '" + cPedCom + "'"
cWhere += " AND SC5.D_E_L_E_T_ <> '*'"
cWhere += " AND L1_FILIAL = '" + xFilial("SL1") + "'"
cWhere += " AND L1_ECFLAG = '1'"
cWhere += " AND SL1.D_E_L_E_T_ <> '*'"
cWhere += "%"

//Executa a query
BeginSql alias cAlias
	SELECT
		C5_FILIAL, C5_NUM, C5_PEDECOM, L1_FILIAL, L1_NUM,
		L1_DOCPED, L1_SERPED, C5_NOTA, C5_SERIE
	FROM %table:SC5% SC5
	INNER JOIN %table:SL1% SL1
	ON  ( SC5.C5_NUM = SL1.L1_PEDRES AND SC5.C5_PEDECOM = SL1.L1_ECPEDEC )
	WHERE %exp:cWhere%
EndSql

(cAlias)->(DBGoTop())

If ( !(cAlias)->(Eof())  )

	If Empty((cAlias)->C5_NOTA) .AND. Empty((cAlias)->C5_SERIE) //So localiza se não existir Nota Fiscal emitida
		cC5_NUM :=  (cAlias)->C5_NUM
		cC5_PEDECO := (cAlias)->C5_PEDECOM
	EndIf
	//Verifica se existe orçamento associado ao pedido

	If !lGerSE1
		lExiste := .T.
	Else
		//Verifica se exite o título
		aAreaSE1	:= SE1->(GetArea())
		SE1->(dbSetOrder(1))// E1_FILIAL + E1_PREFIXO + E1_NUM

		lExiste := SE1->(dbSeek(cFilSE1 + Padr((cAlias)->L1_SERPED, nTamPref) + Padr((cAlias)->L1_DOCPED, nTamNum)))

		RestArea(aAreaSE1)
	EndIf

EndIf

If !lExiste
	If !(cAlias)->(Eof())
		//Verifica se já gerou sc5, sl1
		aAreaSL1	:= SL1->(GetArea())
		SL1->(DbSetOrder(1)) //L1_FILIAL + L1_NUM
		If  Empty((cAlias)->C5_NOTA) .AND. Empty((cAlias)->C5_SERIE) .AND. SL1->(DbSeek(xFilial("SL1") + (cAlias)->L1_NUM))
			Lj901OrEx(SL1->L1_PEDRES, SL1->L1_FILRES)
		ElseIf !Empty((cAlias)->C5_NOTA) .AND. !Empty((cAlias)->C5_SERIE)
			cErrorCode := "24"
		EndIf
	Else
		//verficia se o pedido existe
		cSQL := " SELECT C5_NUM, C5_FILIAL, C5_NOTA, C5_SERIE  "
		cSQL += " FROM " + RetSqlName("SC5") + " SC5 "
		cSQL += " WHERE C5_FILIAL = '" + xFilial("SC5") + "' "
		cSQL += " AND ( C5_PEDECOM = '" + cPedCom + "' OR C5_PEDECOM = '"+ AllTrim(cPedCom)+"') "
		cSQL += " AND D_E_L_E_T_ <> '*' "

		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cSQL),cAlias2, .F., .T.)

		If !(cAlias2)->(Eof()) .AND. Empty((cAlias2)->C5_NOTA) .AND. Empty((cAlias2)->C5_SERIE)
			Lj901APedEx((cAlias2)->C5_NUM, (cAlias2)->C5_FILIAL)
			lExiste := .F.
		ElseIf !Empty((cAlias2)->C5_NOTA) .AND. !Empty((cAlias2)->C5_SERIE)
			cErrorCode := "24"
		EndIf

		(cAlias2)->(DBCloseArea()) //Alias da Consulta
	EndIf
EndIf


(cAlias)->(DBCloseArea())

Return lExiste

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901ASCan
Retorna o status do Pedido cancelado
@return cStatus - Status do Pedido cancelado
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs
@sample Lj901ASCan()
/*/
//-------------------------------------------------------------------
Static Function Lj901ASCan()
Local cStatus := _PEDIDO_CANCELADO

If 	ExistBlock("Lj901APS")
	cStatus := ExecBlock("Lj901APS",.F.,.F.)
EndIf

Return cStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901ACrOr
Gera o array dos itens do orçamento
@param aCabPV - Cabeçalho do Pedido SC5
@param aItemPV - Itens do Pedido SC6
@param aSLQ - Cabeçalho do Orçamento
@param aSLR - Itens do Orçamento
@param aSL4 - Parcelas do Orçamento
@param cCodAdm  - Codigo da Adminsitradora
@param cForma - Forma de Pagamento
@param aProdutos   - Dados dos Produtos
@param cNumPed  - Numero do pedido
@param nSubVlr  - SubTotal
@param nTotalPed  - Total do Pedido
@param aParcela  - Parcelas
@param oAPed  - Objeto do XML do Pedido
@param lGerSE1 - Gera Titulo
@param oRetExtra - Dados Extras do Pedido
@param lIPIAjst - Ajusta o valor do IPI
@Param aItemPV2 - Item do Pedido de Venda
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs
@sample Lj901ACrOr(aCabPV,		aItemPV,	aSLQ, 	aSLR,
aSL4, 		cCodAdm, 	cForma,	aProdutos, 	;
cNumPed, 	nSubVlr, 	nTotalPed, 	aParcela,;
oAPed, lGerSE1, oRetExtra, lIPIAjst, ;
aItemPV2)
/*/
//-------------------------------------------------------------------
Static Function Lj901ACrOr(aCabPV,		aItemPV,	aSLQ, 	aSLR, ;
aSL4, 		cCodAdm, 	cForma,	aProdutos, 	;
cNumPed, 	nSubVlr, 	nTotalPed, 	aParcela,;
oAPed, 		lGerSE1, oRetExtra, lIPIAjst,;
aItemPV2)

Local cSerPed 		:= SuperGetMV("MV_LJECOM5", .F., "EC0")  //Serie do Titulo
Local cDocPed		:= ""  		//Numero do Titulo
Local aAreaSC6 		:= SC6->(GetArea())  //WorkArea dos Itens de Pedido
Local aArea 		:= GetArea() 			//WorkArea Ativa
Local cFilSC6 		:= xFilial("SC6")     //Filial dos itens do Pedido
Local aTmp 			:= {}       				//Variavel Temporaria
Local nX 			:= 0 						//Variavel contadora
Local aDadosTran 	:= {} 			//Array contendo os dados da transação, onde
Local nPrcTab		:= 0 //Preço de Venda
Local lNoDescProd := SuperGetMv("MV_LJECNDI",, .F.) //Não gera desconto no item default .f.
Local nTamSC6It		:= SC6->(TamSx3("C6_ITEM")[1]) //Tamanho do campo C6_ITEM
Local nPosPed		:=  0 //Posicao do Pedido
Local nPosFldPed    := 0 //Posicao do campo _ECVALOR
Local nPosFldItem	:= 0 //Posicao do Item
/*   1 - NSU
2 - Autorização
3 - Numero do Cartão */
Local aDPSC5SLQ 	:= { {"C5_CLIENTE", "LQ_CLIENTE"},;
{"C5_LOJACLI"   , "LQ_LOJA"},;
{"C5_TIPOCLI", "LQ_TIPOCLI"},;
{"C5_VEND1"  , "LQ_VEND"},;
{"C5_EMISSAO", "LQ_EMISSAO"},;
{"C5_DESCONT"  , "LQ_DESCONT"},;
{"C5_FRETE"  , "LQ_FRETE"},;
{"C5_SEGURO", "LQ_SEGURO"},;
{"C5_DESPESA", "LQ_DESPESA"},;
{"C5_TRANSP", "LQ_TRANSP"},;
{"C5_ACRSFIN", "LQ_JUROS"},;
{"C5_FILIAL", "LQ_FILRES"},;
{"C5_NUM", "LQ_PEDRES"} }

Local aDPSC6SLR 	:= {	{"C6_NUM", "LR_PEDRES"},;
{"C6_FILIAL", "LR_FILRES"},;
{"C6_PRODUTO", "LR_PRODUTO"},;
{"C6_QTDVEN", "LR_QUANT"},;
{"C6_PRCVEN", "LR_VRUNIT"},;
{"C6_VALOR", "LR_VLRITEM"},;
{"C6_LOCAL", "LR_LOCAL"},;
{"C6_TES", "LR_TES "}}


If lIPIAjst .AND. Len(aItemPV2) > 0
	nPosFldPed := aScan(aItemPV2[1], { |c| c[1] == "_ECVALOR"})
	nPosFldItem := aScan(aItemPV2[1], { |c| c[1] == "C6_ITEM"})
EndIf

aSLQ := {}

Lj900XLg("C5_PEDECOMM  " + SC5->C5_PEDECOM, MGU->MGU_PEDECO )

For nX := 1 to Len(aDPSC5SLQ)
	aAdd(aSLQ, { aDPSC5SLQ[nX,2] , SC5->(&(aDPSC5SLQ[nX,1])), NIL})
Next nX

//Tipo do frete
aAdd(aSLQ, { "LQ_TPFRET" , IIF(SC5->C5_TPFRETE == "C", "1", "2") , NIL})

If SC5->C5_ACRSFIN = 0
	Lj900XLg("Condição sem juros " + SC5->C5_CONDPAG  ,  MGU->MGU_PEDECO )
	aAdd(aSLQ, {"LQ_CONDPG", SC5->C5_CONDPAG , NIL})
Else
	Lj900XLg("Condição com juros - não informada "  ,  MGU->MGU_PEDECO )
EndIf

aAdd(aSLQ, {"LQ_VALBRUT", nTotalPed, NIL})
aAdd(aSLQ, {"LQ_VALMERC", nSubVlr, NIL})

aAdd(aSLQ, {"LQ_VLRLIQ", nTotalPed, NIL})
aAdd(aSLQ, {"LQ_VLRTOT", nTotalPed, NIL})
aAdd(aSLQ, {"LQ_PARCELA",  Len(aParcela), NIL})
aAdd(aSLQ, {"LQ_PDV",  ".", NIL})
aAdd(aSLQ, {"LQ_IMPRIME", "1N", NIL})
aAdd(aSLQ, {"LQ_VLQDEBI" , 0, NIL})
aAdd(aSLQ, {"LQ_HORA", "", NIL})
aAdd(aSLQ, {"LQ_NUMMOV", "1", NIL})
aAdd(aSLQ, {"LQ_ECFLAG", "1", NIL})

If lGerSE1
	cDocPed := NxtSX5Nota(SuperGetMV("MV_LJECOM5",,"EC0"),.T.,"1")
	aAdd(aSLQ,{"LQ_DOCPED", cDocPed, NIL})
	aAdd(aSLQ,{"LQ_SERPED", cSerPed, NIL})
EndIf

aAdd(aSLQ,{"LQ_ADMFIN", Left(cCodAdm,TamSx3("AE_COD")[1])})
If Alltrim(cForma) == "FI"
	aAdd(aSLQ, {"LQ_DTLIM", SC5->C5_EMISSAO + SuperGetMV("MV_LJECOM2", .F., 0), NIL})
Else
	aAdd(aSLQ, {"LQ_DTLIM", SC5->C5_EMISSAO + SuperGetMV("MV_LJECOMB", .F., 0), NIL})
EndIf

aAdd(aSLQ, {"LQ_TABELA" , SuperGetMV("MV_LJECOMQ", , "001") , NIL})
aAdd(aSLQ, {"LQ_OPERADO", xNumCaixa()                       , NIL})
aAdd(aSLQ, {"LQ_ECPEDEC", oAPed:_ORDER_ID:TEXT              , NIL})

//Alimentacao dos campos SLR
SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
SC6->(DbSeek(cFilSC6 + SC5->C5_NUM))
Do While !SC6->(Eof()) .AND. SC6->(C6_FILIAL + C6_NUM) == cFilSC6 + SC5->C5_NUM

	aTmp := {}
	For nX := 1 to Len(aDPSC6SLR)
		aAdd(aTmp, { aDPSC6SLR[nX,2] , SC6->(&(aDPSC6SLR[nX,1])), NIL})
	Next nX

	aAdd(aTmp, {"LR_ITEM", SC6->C6_ITEM, NIL})
	aAdd(aTmp, {"LR_ENTREGA", "3", NIL})
	aAdd(aTmp, {"LR_DESC", 0, NIL})
	aAdd(aTmp, {"LR_VDMOST", "N", NIL})
	nPrcTab := SC6->C6_PRUNIT
	//Solicitação cliente Pirelli - não gera desconto no item
	If !lNoDescProd
		aAdd(aTmp, {"LR_VALDESC", Max((nPrcTab -  SC6->C6_PRCVEN  ) * SC6->C6_QTDVEN ,0), ".T."})
	Else
		nPrcTab  := SC6->C6_PRCVEN
		Lj900XLg("Gerado desconto zerado conforme parametro MV_LJECNDI e preço de venda como preço de tabela", MGU->MGU_PEDECO,  Max((nPrcTab -  SC6->C6_PRCVEN) * SC6->C6_QTDVEN ,0))
		aAdd(aTmp, {"LR_VALDESC", 0, nil})
	EndIf
	aAdd(aTmp, {"LR_PRCTAB", nPrcTab, ".t."})
	aAdd(aTmp, {"LR_TABELA", SuperGetMV("MV_LJECOMQ", , "001"), NIL})
	If lIPIAjst .AND. nPosFldPed > 0  .AND. nPosFldItem > 0

		If PadR(SC6->C6_ITEM, nTamSC6It) <= Replicate("9", nTamSC6It)
			nPosPed := Val(SC6->C6_ITEM)
		Else
			nPosPed := FR271BPegaIT(SC6->C6_ITEM)
		EndIf

		If nPosPed > 0 .AND. aItemPV2[nPosPed, nPosFldItem, 02] == SC6->C6_ITEM
			aAdd(aTmp, {"LR_ECVALOR", aItemPV2[nPosPed, nPosFldPed, 02], NIL})
		EndIf
	EndIf
	aAdd(aSLR, aClone(aTmp))
	SC6->(DbSkip(1))
EndDo

//Alimentação dos Campos SL4
For nX := 1 to Len(aParcela)
	aTmp := {}
	aAdd(aTmp, {"L4_DATA"   , aParcela[nX, 01]  , NIL})
	aAdd(aTmp, {"L4_VALOR"  , aParcela[nX, 02]  , NIL})
	aAdd(aTmp, {"L4_FORMA"  , cForma            , Nil})
	aAdd(aTmp, {"L4_FORMAID", ""                , Nil})
	aAdd(aTmp, {"L4_MOEDA"  , 0                 , Nil})
	aAdd(aTmp, {"L4_ADMINIS", cCodAdm           , Nil})

	aDadosTran := Lj901DTran(oAPed, oRetExtra)

	Lj900XLg("Retorno dados de pagamento TEF " + "Lj901DTran", MGU->MGU_PEDECO, aDadosTran )
	aAdd(aTmp, {"L4_NSUTEF", aDadosTran[1], Nil})
	aAdd(aTmp, {"L4_DOCTEF", aDadosTran[2], Nil})
	aAdd(aTmp, {"L4_NUMCART", aDadosTran[3], Nil})


	aAdd(aSL4, aClone(aTmp))
Next
Return

RestArea(aArea)
RestArea(aAreaSC6)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901DTran
Função de retorno dos dadados da transação para gravação no SL4
@param   oAPed - Dados do Pedido
@param oRetExtra - Dados Extras do Pedido
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@sample Lj901DTran(oAPed)
/*/
//-------------------------------------------------------------------
Static Function Lj901DTran(oAPed, oRetExtra)
Local  aDadosTran := {} //Array contendo os dados da transação, onde
Local cMetPag :=  PADL(oAPed:_RECEIPT_DETAILS:_COD_PG:TEXT, 3, "0")   //Método de Pagamento

If 	ExistBlock("Lj901ADT")
	aDadosTran := ExecBlock("Lj901ADT",.F.,.F., {oAPed, oRetExtra})

Else

	If cMetPag  $ _MET_PAGTO_CIELO// "073#071#070#085"
		aDadosTran := { 	oAPed:_RECEIPT_DETAILS:_DADOSTRANSACAO_1:TEXT,; //NSU
		oAPed:_RECEIPT_DETAILS:_DADOSTRANSACAO_2:TEXT,; //AUTORIZACAO
		""} //NUMERO DO CARTAO

	ElseIf cMetPag $ _MET_PAGTO_REDE //"096#097#098#099#100"
		aDadosTran := { 	oAPed:_RECEIPT_DETAILS:_DADOSTRANSACAO_1:TEXT,; //NSU
		oAPed:_RECEIPT_DETAILS:_DADOSTRANSACAO_2:TEXT,; //AUTORIZACAO
		""} //NUMERO DO CARTAO

	ElseIf cMetPag $ _MET_PAGTO_REDECARD //"019#020#072"
		aDadosTran := { 	oAPed:_RECEIPT_DETAILS:_DADOSTRANSACAO_1:TEXT,; //NSU
		oAPed:_RECEIPT_DETAILS:_DADOSTRANSACAO_2:TEXT,; //AUTORIZACAO
		oAPed:_RECEIPT_DETAILS:_DADOSTRANSACAO_4:TEXT} //NUMERO DO CARTAO

	ElseIf cMetPag $  _MET_PAGTO_MOIP //"075#076#077#078#079#080#081#082#083#084"
		aDadosTran := { 	oAPed:_RECEIPT_DETAILS:_DADOSTRANSACAO_2:TEXT,; //NSU
		oAPed:_RECEIPT_DETAILS:_DADOSTRANSACAO_4:TEXT,; //AUTORIZACAO
		""} //NUMERO DO CARTAO
	ElseIf  cMetPag $ _MET_PAGTO_KOMERCI_WS //"103#104#105#106#107"
		aDadosTran := { 	oAPed:_RECEIPT_DETAILS:_DADOSTRANSACAO_1:TEXT,; //NSU
		oAPed:_RECEIPT_DETAILS:_DADOSTRANSACAO_2:TEXT,; //AUTORIZACAO
		""} //NUMERO DO CARTAO
	ElseIf cMetPag $ _MET_PAGTO_MUNDIPAGG //"117#119#120#121#122#123#124#125#126#127"
		aDadosTran := { 	oAPed:_RECEIPT_DETAILS:_DADOSTRANSACAO_3:TEXT,; //NSU
							oAPed:_RECEIPT_DETAILS:_DADOSTRANSACAO_2:TEXT,; //AUTORIZACAO
							""} //NUMERO DO CARTAO
	ElseIf (cMetPag $  _MET_PAGTO_BOLETO) .OR. ( cMetPag $ _MET_PAGTO_MUNDIPAGG_BOLETO )  //"005#008#024#028#036#054#067" #118
		If ExistBlock("Lj901ANBol")        //Retorna no primeiro
			aDadosTran := ExecBlock("Lj901ANBol",.F.,.F., {oAPed, oRetExtra})
		Else
			aDadosTran := {oAPed:_RECEIPT_DETAILS:_DADOSTRANSACAO_1:TEXT ,; //NSU - retorna nesse
			"",; //AUTORIZACAO
			""} //NUMERO DO CARTAO
		EndIf

	EndIf
EndIf

If Len(aDadosTran) < 3
	aSize(aDadosTran, 3)
EndIf

AEval(aDadosTran, { |l| IIF(ValType(l) <> "C", l:="", )})

Return aDadosTran


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901AGOrT
Função de geração do orçamento
@param  aSLQ - Cabeçalho do orçamento
@param  aSLR - Itens do orçamento
@param	aSL4 - Pagamentos
@param	nValTaxAdm - Taxa Administrativa
@param  lAdmProp - Administradora Propria
@param 	cAdminFin - Codigo da Administradora Financeira
@param  cCondPag - Condição de Pagamento
@param  cRetErro - Mensagem de Erro
@param	lGerSE1 - Gera o Título de Contas a Receber
@param  oRetExtra - Dados Extras do pedido
@param  oAPed - XML do pedido
@param	aReservas - Array de Reservas
@param	lErroProc - Erro no processamento da venda
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@sample  Lj901AGOrT(aSLQ,aSLR,aSL4,  nValTaxAdm, lAdmProp, cAdminFin, cCondPag, cRetErro,;
								lGerSE1,  oRetExtra, oAPed, aReservas)
/*/
//-------------------------------------------------------------------

Static Function Lj901AGOrT(	aSLQ,			aSLR,		aSL4,  		nValTaxAdm, ;
								lAdmProp, 	cAdminFin, 	cCondPag,	cRetErro,;
								lGerSE1,  oRetExtra, oAPed, aReservas,;
								lErroProc)
Local aArea 	:= GetArea() //WorkArea Ativa
Local aAreaSL1 	:= SL1->(GetArea())  //WorkAreaSL1
Local lRet 		:= .F.   	//Retorno da Rotina
Local cRestFun 	:= FunName()	//Noma da Rotina em execução
Local cMensagem := "" 	//Mensagem
Local cFilSL1 	:= "" 	//Filial do Orçamento
Local cNumOrc 	:= ""	//Numero do Orçamento
Local cCliente 	:= "" 	//Codigo do Cliente
Local cLoja	 	:= "" 	//Loja do Cliente
Local nPos 		:= 0 //Posicao de Busca do Array de clientes
Local cDocPed 	:= "" 	//Numero do Pedido
Local cSerPed 	:= ""	//Serie do Pedido
Local cPedRes 	:= "" 	//Pedido de Reserva
Local cFilRes 	:= ""	//Filial do Pedido
Local nPosDocTEF := 0 //Documento TEF
Local nPosNSUTEF := 0 //NSU TEF
Local nPosData 	:= 0 //Posição da Data
Local nPosForma := 0 //Posicao da forma
Local nPosValor	:= 0 //Posicao do Valor
Local nC		:= 0 //Contador
Local cOldUsr	:= __cUserID //Id Usuário Anterior
Local lDelOrc	:= .F. //Sinaliza a exclusão do orçamento
Local nModAnt 	:= 0 //Modulo Anterior
Local lFicBk	:= lFiscal  //lFiscal Anterior
Local cNumCaixa	:= "" //Nome do Caixa
Local aAreaSX5	:= SX5->(GetArea()) //WorkArea SC5
Local aAreaSA6	:= SA6->(GetArea()) //WorkArea SA6
Local aAreaSLF	:= SLF->(GetArea()) //WorkArea SLF
Local aAreaSL2	:= {} //WorkArea SL2
Local nR		:= 0 //Contador
Local bOldError		:= NIL //code-block de erro
Local aAreaSM0		:= SM0->(GetArea()) //WorkArea SM0
Local cPedEc := "" //Codigo do pedido gerado no site
Local aLog      := {}
Local cMsgTr		:= STR0019 //"CONTROLE TRANSACIONAL HABILITADO. As informações geradas durante processamento deste pedido serão desfeitas."
Local dDtLimit  := Ctod("") //Data limite do orçamento
Local nReg		:= 0 //Registro do SL1

Private lFTStartSilenc := .T.        //varivel para nao apresentar mensagem de erro em tela
Private INCLUI := .T.

__cUserID      := SuperGetMV("MV_LJECOMU",,"000001")    //UserID do Usuario do eCommerce.
cUserName      := SuperGetMV("MV_LJECOMN",,"ECOMMERCE") //Nome do Usuario do eCommerce.

lECLJAUTO      := .T.      //Execauto para eCommerce
SetFunName("LOJA701")

//Posiciona no perfil do caixa
cNumCaixa := xNumCaixa() //Posiciona SA6
If SX5->(DbSeek(xFilial("SX5")+'23'+ cNumCaixa ) )
	SLF->(DbSetOrder(1))
	SLF->(DbSeek(xFilial("SLF")+SA6->A6_COD))
EndIf

If (nPos := aScan(aSLQ, { |l| l[1] ==  "LQ_CLIENTE"})) > 0
	cCliente := aSLQ[nPos][2]
	cLoja := "01"
	If (nPos := aScan(aSLQ, { |l| l[1] ==  "LQ_LOJA"})) > 0
		cLoja := aSLQ[nPos][2]
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa o ExecAuto                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SL1->(DbSetorder(0))
If !SL1->(Eof())
	SL1->(DbGoBottom())
	nReg := 	SL1->(Recno())
EndIf

SL1->(DbSetorder(1))

lMsErroAuto := .F.
lAutoErrNoFile := .T.

If ValType(nModulo) = "N"  .AND. nModulo = 5
	nModAnt := nModulo
	nModulo := 12 //Sigaloja
EndIf 

Lj900XLg("lFiscal" + cValTochar(lFiscal), MGU->MGU_PEDECO)

lFicBk := lFiscal
lFiscal := .F.

bOldError := ErrorBlock( {|x| Lj901AVE(x) } ) // muda code-block de erro

Begin Sequence
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera o Orçamento                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj900XLg("Verificação da filial cEmpAnt/cFilAnt" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil(),"")

		MSExecAuto({|a,b,c,d,e,f,g,h| Loja701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},aSLQ,aSLR,aSL4)
	//Restaura SM0
	RestArea(aAreaSM0)

	Lj900XLg("Verificação da filial cEmpAnt/cFilAnt" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil(),"")

Recover
	lMsErroAuto := .T.
End Sequence

ErrorBlock( bOldError ) // Restaura rotina de erro anterior
///Restaura SM0
RestArea(aAreaSM0)

lFiscal := lFicBk


Lj900XLg("LOJA701C Gravando L1_ECPEDEC " + cValToChar(lGrvPedEc), MGU->MGU_PEDECO)

If (nPos := aScan(aSLQ, { |l| l[1] ==  "LQ_ECPEDEC"})) > 0
	cPedEc := aSLQ[nPos][2]
EndIf

If nModAnt > 0
	nModulo := 12
EndIf

If  lMsErroAuto
 	aLog := GetAutoGrLog()
	cMensagem := "LOJA901A - Lj901AGOrT: " + STR0010 + CRLF + GeraErro(aLog)     //"Erro no ExecAuto"
	Lj900XLg(cMensagem, MGU->MGU_PEDECO )
	cRetErro := "11" //"Problemas na geração do Orçamento"
	RollBackSx8()
	If lLjx904ErrE
		aadd(aLog, cMsgTr)
		Ljx904ErrE(aLog,Nil,"ORCA",MGU->MGU_PEDECO,Nil,Nil)
	EndIf
	lErroProc := .T.
Else

	If !SL1->(Eof()) .AND. (   (  lGrvPedEc .AND. !Empty(cPedEc) .AND. AllTrim(cPedEc) == AllTrim(SL1->L1_ECPEDEC) ) .OR. ;
								  ( !lGrvPedEc .AND.  (nReg < SL1->(Recno())) .AND. (Alltrim(SL1->L1_CLIENTE) == Alltrim(cCliente) .And.  Alltrim(SL1->L1_LOJA) == AllTrim(cLoja)  ) )  )
		lRet := .T.
		Lj900XLg("LOJA901A - Lj901AGOrT: "+ STR0012 + STR0013 + SL1->L1_NUM, MGU->MGU_PEDECO)     //"Sucesso na execução do ExecAuto"##"Orçamento: "
		cRetErro := ""
		cFilSL1 := SL1->L1_FILIAL
		cNumOrc := SL1->L1_NUM
		cDocPed := ""
		cSerPed := ""
		cPedRes := ""
		cFilRes := ""

		If (nPos := aScan(aSLQ, { |l| l[1] ==  "LQ_FILRES"})) > 0
			cFilRes := aSLQ[nPos][2]
		EndIf

		If (nPos := aScan(aSLQ, { |l| l[1] ==  "LQ_PEDRES"})) > 0
			cPedRes := aSLQ[nPos][2]
		EndIf

		If (nPos := aScan(aSLQ, { |l| l[1] ==  "LQ_DOCPED"})) > 0
			cDocPed := aSLQ[nPos][2]
		EndIf

		If (nPos := aScan(aSLQ, { |l| l[1] ==  "LQ_SERPED"})) > 0
			cSerPed := aSLQ[nPos][2]
		EndIf

		If (nPos := aScan(aSLQ, { |l| l[1] ==  "LQ_DTLIM"})) > 0
			dDtLimit := aSLQ[nPos][2]
		EndIf

		RecLock("SL1", .F.)
		SL1->L1_FILRES := cFilRes
		SL1->L1_PEDRES := cPedRes
		SL1->L1_DOCPED := cDocPed
		SL1->L1_SERPED := cSerPed
		SL1->L1_OPERADO:= xNumCaixa()
		If !lGrvPedEc
			SL1->L1_ECPEDEC := cPedEc
		EndIf
		If !Empty(dDtLimit)
			SL1->L1_DTLIM   := dDtLimit
		EndIf

		If SL1->L1_ECFLAG <> "1"
			SL1->L1_ECFLAG := "1"
			Lj900XLg("LOJA901A - Campo L1_ECFLAG Atualizado "+ cValtochar(SL1->L1_ECFLAG), MGU->MGU_PEDECO)     //"Sucesso na execução do ExecAuto"##"Orçamento: "
		Else
			Lj900XLg("LOJA901A - Campo L1_ECFLAG Mantido "+ cValtochar(SL1->L1_ECFLAG), MGU->MGU_PEDECO)     //"Sucesso na execução do ExecAuto"##"Orçamento: "

		EndIf

		SL1->(MsUnLock())

		If Len(aReservas) > 0
			aAreaSL2 := SL2->(GetArea())
			SL2->(DbSetOrder(1)) //L2_FILIAL + L2_NUM + L2_ITEM
			For nR := 1 to Len(aReservas)

				If !Empty(aReservas[nR, 05])
					If SL2->(DbSeek( SL1->(L1_FILIAL + L1_NUM) + aReservas[nR, 01]))

						SL2->(RecLock("SL2", .F.))

						SL2->L2_LOCAL :=  aReservas[nR, 06]
						SL2->L2_RESERVA := aReservas[nR, 05]
						SL2->(MsUnLock())

						Lj900XLg("Gerado Reserva SL2  " + " Produto " +  SL2->L2_PRODUTO +  " Reserva " + SL2->L2_RESERVA+ " item " + SL2->L2_ITEM  + " Local " + SL2->L2_LOCAL, MGU->MGU_PEDECO)


					EndIf
				EndIf
			Next nR
			RestArea(aAreaSL2)
		EndIf

		//Autaliza os campos da SL4

		nPosDocTEF := aSCan(aSL4[1], { |l| l[1] == "L4_DOCTEF"})
		nPosNSUTEF := aSCan(aSL4[1], { |l| l[1] == "L4_NSUTEF"})
		nPosData   := aSCan(aSL4[1], { |l| l[1] == "L4_DATA"})
		nPosForma  := aSCan(aSL4[1], { |l| l[1] == "L4_FORMA"})
		nPosValor  := aSCan(aSL4[1], { |l| l[1] == "L4_VALOR"})

		SL4->( DbSetOrder(1) )  //L4_FILIAL+L4_NUM+L4_ORIGEM
		SL4->( DbSeek(SL1->L1_FILIAL + SL1->L1_NUM) )

		Do While lRet .And. !SL4->( Eof() ) .And. SL4->L4_FILIAL == SL1->L1_FILIAL .And. SL4->L4_NUM == SL1->L1_NUM

            //Despresa registros gerados por outro modulos
            If AllTrim(SL4->L4_ORIGEM) $ "SIGATMK|MATA460"
                SL4->( DbSkip() )
                Loop
            EndIf

			nC	:= 0

			nC := aScan(aSL4, { |l4|, l4[nPosData][2] == SL4->L4_DATA .AND.  AllTrim(l4[nPosForma][2] ) == AllTrim(SL4->L4_FORMA) .AND. l4[nPosValor][2] = SL4->L4_VALOR})

			If nC > 0   .AND.  !( AllTrim( aSL4[nC][nPosDocTEF][2]) == AllTrim(SL4->L4_DOCTEF) .AND. AllTrim( aSL4[nC][nPosNSUTEF][2]) == AllTrim(SL4->L4_NSUTEF) )
				RecLock("SL4", .F.)
				SL4->L4_DOCTEF := aSL4[nC][nPosDocTEF][2]
				SL4->L4_NSUTEF := aSL4[nC][nPosNSUTEF][2]
				SL4->(MsUnLock())
			EndIf

			SL4->( DbSkip() )
		EndDo

		//Ponto de entrada após a geração de orçamento
			If ExistBlock("Lj901SL1")
				ExecBlock("Lj901SL1",.f., .f., { SL1->L1_FILIAL, SL1->L1_NUM })
			EndIf
		    
			//Realiza a gravação do numero do orçamento no Pedido de Venda. Vinculo realizado para que ao faturar o pedido finalize o orçamento, gravando o numero da nota e serie gerados.
			DbSelectArea("SC5")
			SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM

			If SC5->(DbSeek(cFilRes+cPedRes))
				RecLock("SC5", .F.)		
				SC5->C5_ORCRES := cNumOrc	
				MsUnLock() //Confirma e finaliza a operação
			EndIf

			///Restaura SM0
			RestArea(aAreaSM0)

		If lGerSE1
			//se chegou até aki gerou o orçamento
			lDelOrc := .T.
			lRet := Lj901AE1G(cFilSL1, cNumOrc, nValTaxAdm, lAdmProp,;
							cAdminFin, cCondPag, @cRetErro, oRetExtra,;
                            oAPed, @lErroProc)

		EndIf
	Else
		cMensagem := "LOJA901A - Lj901AGOrT: " + STR0010 + CRLF + STR0011      //##"Erro no ExecAuto"##" Registro não foi incluido pelo ExecAuto!"
		Lj900XLg(cMensagem, MGU->MGU_PEDECO)
		cRetErro := "11" //"Problemas na geração do Orçamento"
		RollBackSx8()
		lErroProc := .T.

	EndIf

EndIf

If !lErroProc
	If !lRet .and. lDelOrc
		//Cancela o orçamento
		//Já esta posicionado no sl1
		Lj901OrEx(cPedRes, cFilRes)



	ElseIf !lRet

				If (nPos := aScan(aSLQ, { |l| l[1] ==  "LQ_FILRES"})) > 0
					cFilRes := aSLQ[nPos][2]
				EndIf

				If (nPos := aScan(aSLQ, { |l| l[1] ==  "LQ_PEDRES"})) > 0
					cPedRes := aSLQ[nPos][2]
				EndIf

				If !Empty(cPedRes) .AND. !Empty(cFilRes)

					Lj901APedEx(cPedRes, cFilRes)

				EndIf

	EndIf
EndIf

__cUserID      := cOldUsr
cUserName      := cUserName

lECLJAUTO   := .F.      //Execauto para eCommerce

//Restaura WorkAreas Abertas
RestArea(aAreaSLF)
RestArea(aAreaSX5	)
RestArea(aAreaSA6)

SetFunName(cRestFun)
RestArea(aAreaSL1)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901AE1G
Função de geração do título no SE1
@param  cFilSL1 - Filial do Título
@param  cNumOrc - Numero do Orçamento
@param	nValTaxAdm - Valor da Taxa Administrativa
@param	lAdmProp - Administradora Propria
@param 	cAdminFin - Codigo da Administradora Financeira
@param  cCondPag - Condição de Pagamento
@param	cRetErro - Mensagem de erro
@param  oRetExtra - XML Dados Extra do Pedido
@param	oAPed - XML Pedido
@param  lErroProc - Erro de Processamento
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@sample  Lj901AE1G( cFilSL1, cNumOrc,  nValTaxAdm, lAdmProp, cAdminFin, cCondPag, cRetErro, oRetExtra, oAPed )
/*/
//-------------------------------------------------------------------
Static Function Lj901AE1G(  cFilSL1  , cNumOrc  , nValTaxAdm, lAdmProp  ,;
						    cAdminFin, cCondPag , cRetErro  , oRetExtra ,;
                            oAPed    , lErroProc) 
Local lGeraTaxa 	:= .F. //Deabilitado, conforme instruções SuperGetMV("MV_LJGERTX",,.F.)   // Verifica se ira gerar um Contas a Pagar quando existir taxa na admistradora do cartao.
Local nPCC			:= 0 // Controle de numeracao das parcelas de Cartao de Credito (CC) SE1
Local nPCD			:= 0	// Controle de numeracao das parcelas de Cartao de Debito (CD) SE1
Local c1DUP 		:= SuperGetMV("MV_1DUP") // Sequência das parcelas "1" = 1..9;A..Z;a..z    e   "A" = A..Z
Local nPFI			:= 0	// Controle da numeracao das parcelas de Financiamento (FI) SE1
Local cParcela		:= "" //Codigo da Parcela
Local cNatureza 	:= "" //Codigo da natureza
Local lCtaCorren	:= .F.  //Conta-Corrente
Local cNatCCor 		:= ""  // Indica se utiliza a funciolidade de conta corrente. **
Local lNotFinPro	:= .F.  // Verifica se pode incluir informacoes no aRegNomE
Local nParcMEP 		:= 0    //Parcelamento TEF
Local lMEP 			:= AliasInDic("MEP")  //Parcelamento TEF
Local nTamParTEF 	:= 0	//Parcelamento TEF
Local cNumSA2 		:= "" //Codigo do fornecedor
Local cCodCliFin	:= "" //codigo do Cliente SE1
Local cCliFin		:= "" //Descrição do Cliente SE1
Local cLojaFin		:= "" //Loja do Cliente SE1
Local lRet 			:= .T. //Retorno da Rotina
Local aSE1 			:= {}  //Array do Títuçp
Local nValor 		:= 0 //Valor do título
Local dDtVencto 	:= Ctod("") //Data de Vencimento
Local lUsaSPB		:= SpbInUse() .AND. (SE1->(ColumnPos("E1_MODSPB")) > 0)	// Controle para uso do SPB
Local nPerJur 		:= SuperGetMV("MV_TXPER") // Parametros MV_TXPER
Local cMensagem 	:= "" //Mensagem de erro
Local nValAdm 		:= 0  //Valor da Taxa Administrativa
Local cA2_Loja 		:= ""  //Codigo da Loja do Fornecedor
Local bOldError		:= NIL //Bloco de erro
Local aRetSE1		:= {}  //Retorno do PE
Local aAreaAnt		:= NIL //workArea anterior
Local lLJ901SE1		:= ExistBlock("LJ901SE1") //Existe Ponto de Entrada?
Local nR			:= 0 //Contador
Local nAE_VENCFIN	:= 0 //Dias de Vencimento
Local aDadosBanc	:= {} //array com dados de ag e conta CADASTRADOS Na SA6
Local aLog          := {}
Local nTamPref      	:= 0    //Tamanho do Prefixo
Local nPamParc 		:= 0        //Tamanho da Parcela
Local nTamNum		:= 0        //Tamanho do Numero
Local nTamTipo		:= 0        //Tamanho do Tipo
Local cMsgTr		:= STR0019  //"CONTROLE TRANSACIONAL HABILITADO. As informações geradas durante processamento deste pedido serão desfeitas."

If lMEP
	nTamPref      	:= TamSx3("MEP_PREFIX")[1] //Tamanho do Prefixo
	nPamParc 		:= TamSx3("MEP_PARCEL")[1] //Tamanho da Parcela
	nTamNum			:= TamSx3("MEP_NUM")[1] //Tamanho do Numero
	nTamTipo		:= TamSx3("MEP_TIPO")[1] //Tamanho do Tipo
	nTamParTEF := TamSx3("MEP_PARTEF")[1]
EndIf

Default nValTaxAdm := 0

If RTrim(SAE->AE_COD) <> cAdminFin
	//Reposiciona na SAE, pois já havia localizado antes
	SAE->(DbSetOrder(1)) //AE_FILIAL + AE_CODIGO
	SAE->(Dbseek(xFilial("SAE") + cAdminFin)  )

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica a utilizacao da funcionalidade referente a Conta Corrente|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (SE4->(ColumnPos("E4_CCORREN")) > 0)
	If Alltrim(SAE->AE_TIPO) == "FI"
		cNatCCor := SuperGetMv( "MV_NATCCOR" , .F. , "OUTROS" ,  )
		If !Empty(cNatCCor)
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1")+SL1->L1_CLIENTE + SL1->L1_LOJA))
				DbSelectArea("SE4")
				SE4->(DbSetOrder(1))
				If SE4->(MsSeek(xFilial("SE4")+SL1->L1_CONDPG)) .AND. SE4->E4_CCORREN == "1"
					DbSelectArea("SED")
					SED->(DbSetOrder(1))
					If SED->(Msseek(xFilial("SED")+cNatCCor))
						lCtaCorren := .T.
					Endif
				Endif
			Endif
		Endif
	Endif
Endif

SL4->( DbSetOrder(1) )  //L4_FILIAL+L4_NUM+L4_ORIGEM
lRet := SL4->( DbSeek(cFilSL1 + cNumOrc) )

Lj900XLg("L4_FILIAL+L4_NUM+L4_ORIGEM (" + cFilSL1 + cNumOrc + ") Localizado = " + cValToChar(lRet), MGU->MGU_PEDECO)

If !lRet
	cRetErro := "16" //"Não localizados pagamentos(SL4) associados ao orçamento"
EndIf

If lRet
	SL1->( DbSetOrder(1) )  //L1_FILIAL+L1_NUM+L4_ORIGEM
	lRet := SL1->( DbSeek(cFilSL1 + cNumOrc) )
	Lj900XLg("L1_FILIAL+L1_NUM " + cFilSL1 + cNumOrc + " Localizado = " + cValToChar(lRet), MGU->MGU_PEDECO)
	dDtVencto := SL1->L1_EMISSAO
	Lj900XLg("Vencimento (dDtVencto) igual data de emissaao (L1_EMISSAO) -> " + cValToChar(dDtVencto), MGU->MGU_PEDECO )
EndIf

Do While lRet .And. !SL4->( Eof() ) .And. SL4->L4_FILIAL == cFilSL1 .And. SL4->L4_NUM == cNumOrc

    //Despresa registros gerados por outro modulos
    If AllTrim(SL4->L4_ORIGEM) $ "SIGATMK|MATA460"
        SL4->( DbSkip() )
        Loop
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somente altera as informacoes:                        ³
	//³ - Cod. Cliente --> cCodCliFin                         ³
	//³ - Nome Cliente --> cCliFin                            ³
	//³ - Loja Cliente --> cLojaFin                           ³
	//³ - Vencimento   --> dSaeVencto                         ³
	//³ - Natureza     --> cNatureza                          ³
	//³ - Porc. Juros  --> cPorJur                            ³
	//³ quando for criar um novo titulo, pois quando for      ³
	//³ gerado um unico titulo, para juros pela adminis-      ³
	//³ tradora, estas informacoes nao precisam ser alteradas.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lAdmProp
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->( MsSeek( xFilial("SA1") + SL1->L1_CLIENTE+SL1->L1_LOJA) )
		cCodCliFin	:= SA1->A1_COD
		cCliFin		:= SA1->A1_NREDUZ
		Lj900XLg("A1_NREDUZ " + SA1->A1_NREDUZ, MGU->MGU_PEDECO)
		cLojaFin	:= SA1->A1_LOJA
		//dDtVencto := SL1->L1_EMISSAO
		Lj900XLg("Antes de atualizar (LJCalcVenc) dDtVencto lAdmProp -> " + cValToChar(dDtVencto), MGU->MGU_PEDECO )//Diego
		dDtVencto:=  LJCalcVenc(.F., dDtVencto, .F.) //Diego
		Lj900XLg("Depois de atualizar (LJCalcVenc) dDtVencto lAdmProp -> " + cValToChar(dDtVencto), MGU->MGU_PEDECO )//Diego

		Lj900XLg("L4_DATA " + cValtochar(SL4->L4_DATA), MGU->MGU_PEDECO )
		Lj900XLg("dDtVencto " + cValToChar(dDtVencto), MGU->MGU_PEDECO )
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica no parametro se gera um Contas a Pagar ³
		//³ quando existir taxa na admistradora do cartao   ³
		//³ para fazer a gravacao do SA2 do fornecedor      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Lj140AdmSA2(@cNumSA2, @cA2_Loja)

        If SAE->( ColumnPos("AE_LOJCLI") ) > 0 .And. !Empty(SAE->AE_CODCLI) .And. !Empty(SAE->AE_LOJCLI)

            cCodCliFin  := SAE->AE_CODCLI
            cLojaFin    := SAE->AE_LOJCLI
        Else

			//Inclui Administradora como cliente para geração do contas a receber
            L070IncSA1()

            cCodCliFin	:= SAE->AE_COD
            cLojaFin    := "01"          //O cliente eh criado com A1_LOJA = "01" no LOJA070
        EndIf

        cCliFin     := SAE->AE_DESC
		lNotFinPro	:= .T.

		SA1->(DbSetOrder(1))
		SA1->( MsSeek( xFilial("SA1") + cCodCliFin+cLojaFin) )
		Lj900XLg("Antes de atualizar (LJCalcVenc) dDtVencto -> " + cValToChar(dDtVencto), MGU->MGU_PEDECO )//Diego
		dDtVencto:=  LJCalcVenc(.F., dDtVencto, .F.) //Diego
		Lj900XLg("Depois de atualizar (LJCalcVenc) dDtVencto -> " + cValToChar(dDtVencto), MGU->MGU_PEDECO )//Diego
	EndIf

	lMEP := lMEP .AND.  RTrim(SL4->L4_FORMA) $ "CC#CD"

	Lj900XLg("L4_FILIAL+L4_NUM+L4_ORIGEM " + SL4->L4_FILIAL+SL4->L4_NUM+SL4->L4_ORIGEM, MGU->MGU_PEDECO)
	Lj900XLg("L1_NUM 2 "+ SL1->L1_NUM, MGU->MGU_PEDECO)

	Lj900XLg("SL4->L4_FORMA "+ SL4->L4_FORMA, MGU->MGU_PEDECO)

	Lj900XLg("	SL1->L1_DOCPED " +	SL1->L1_DOCPED, MGU->MGU_PEDECO)
	Lj900XLg("	SL1->L1_PEDRES " + 	SL1->L1_PEDRES, MGU->MGU_PEDECO)

	nDiasVenc := 0//TO DO: Alimentar dias de vencimento
	Do Case
		Case AllTrim(SL4->L4_FORMA) == "CC"
			nPCC ++
			cParcela	:= LJParcela(nPCC, c1DUP)
			cNatureza	:= LjMExeParam("MV_NATCART")
		Case AllTrim(SL4->L4_FORMA) == "CD"
			nPCD ++
			cParcela	:= LJParcela(nPCD, c1DUP)
			cNatureza	:= LjMExeParam("MV_NATTEF")
		Case AllTrim(SL4->L4_FORMA) == "FI"
			nPFI ++
			cParcela := LJParcela(nPFI, c1DUP)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Conta Corrente - Natureza       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCtaCorren
				cNatureza := LjMExeParam( "MV_NATCCOR" , .F. , "OUTROS" )
			Else
				cNatureza := LjMExeParam("MV_NATFIN")
			Endif

			nAE_VENCFIN := SAE->AE_VENCFIN

	EndCase
	aSE1 := {}
	aAdd( aSE1,	{ "E1_FILIAL"	, xFilial("SE1")                            , NIL } )
	aAdd( aSE1, { "E1_PREFIXO"  , SL1->L1_SERPED                            , NIL } )
	aAdd( aSE1, { "E1_NUM"      , SL1->L1_DOCPED                            , NIL } )
	aAdd( aSE1, { "E1_PARCELA"  , cParcela                                  , NIL } )
	aAdd( aSE1, { "E1_TIPO"     , SL4->L4_FORMA                             , NIL } )
	aAdd( aSE1, { "E1_NATUREZ"  , cNatureza                                 , NIL } )
	aAdd( aSE1, { "E1_CLIENTE"  , PadR(cCodCliFin,TamSx3("E1_CLIENTE")[1])  , NIL } )
	aAdd( aSE1, { "E1_LOJA"     , cLojaFin                                  , NIL } )
	aAdd( aSE1, { "E1_EMISSAO"  , SL1->L1_EMISSAO                           , NIL } )
	aAdd( aSE1, { "E1_EMIS1"    , SL1->L1_EMISSAO                           , NIL } )
	aAdd( aSE1, { "E1_VENCTO"   , dDtVencto                                 , NIL } )
	aAdd( aSE1, { "E1_VENCREA"  , DataValida(dDtVencto,.T.)                 , NIL } )
	aAdd( aSE1, { "E1_VENCORI"  , dDtVencto                                 , NIL } )
	aAdd( aSE1, { "E1_MOEDA"    , 1                                         , NIL } )
	aAdd( aSE1, { "E1_ORIGEM"   , "LOJA701"                                 , NIL } )
	aAdd( aSE1, { "E1_FLUXO"    , "S"                                       , NIL } )

	If lGeraTaxa .AND. AllTrim(SL4->L4_FORMA) $ "CC/CD"
		nValor := SL4->L4_VALOR
	Else
		nValor :=  SL4->L4_VALOR - ( SL4->L4_VALOR  * (nValTaxAdm / 100))
	EndIf

	aAdd( aSE1, { "E1_VALOR", nValor, NIL })
	aAdd( aSE1, { "E1_VLRREAL",  SL4->L4_VALOR, NIL })
	aAdd( aSE1, { "E1_HIST",  "", NIL })
	aAdd( aSE1,{"E1_BCOCHQ" , ""		,Nil})
	aAdd( aSE1,{"E1_AGECHQ"	, ""	,Nil})
	aAdd( aSE1,{"E1_CTACHQ"	, ""	,Nil})

	aAdd( aSE1, { "E1_NOMCLI",cCliFin, NIL } )
	Lj900XLg("cCliFin " + cCliFin, MGU->MGU_PEDECO)
	aDadosBanc := GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+SL1->L1_OPERADO, 1, { ".", "."} )		//³ Busca AG e conta cadastrados na SA6
	aAdd( aSE1, { "E1_PORCJUR",nPerJur, NIL } )
	aAdd( aSE1, { "E1_PORTADO",SL1->L1_OPERADO, NIL } )
	aAdd( aSE1, { "E1_AGEDEP", aDadosBanc[1], NIL }  )
	aAdd( aSE1, { "E1_CONTA",aDadosBanc[2], NIL } )
	aAdd( aSE1, { "E1_SITUACA","0", NIL } )   //CARTEIRA PADRÃO
	aAdd( aSE1, { "E1_MULTNAT","2", NIL } )
	aAdd( aSE1, { "E1_FILORIG",cFilAnt, NIL})
	aAdd( aSE1, { "E1_STATUS", "A" , NIL } )
	If lUsaSPB
		aAdd( aSE1, { "E1_MODSPB","1", NIL } )
	EndIf
	aAdd( aSE1, { "E1_NUMCART",SL4->L4_NUMCART, nil})

	If  AllTrim(SL4->L4_FORMA) $ "CC/CD"

		If SE1->(ColumnPos("E1_NSUTEF")) > 0

			aAdd( aSE1, { "E1_NSUTEF", SL4->L4_NSUTEF, NIL })
		Endif
		If SE1->(ColumnPos("E1_DOCTEF")) > 0
			aAdd( aSE1, { "E1_DOCTEF", SL4->L4_DOCTEF, NIL })
		Endif
	Else
		aAdd( aSE1, { "E1_IDCNAB", SL4->L4_NSUTEF, NIL })
	EndIf

	If lLJ901SE1 // p.e. de inclusão de dados adicionais do título

		Lj900XLg("Executando p.E. " + "LJ901SE1" , MGU->MGU_PEDECO)
		aAreaAnt :=  GetArea() //WorkArea anterior
		aRetSE1 := {} //Dados adicionais do Título
		//Retorno dos dados adicionais do Título, onde o retorno deve ser
		//Array contendo a seguinte estrutura
		//aRetSE1 , onde
		//aRetSE1[nLin, 01] // Nome do campo
		//aRetSE1[nLin, 02] // Valor do Campo
		//aRetSE1[nLin, 03] // Nil
		aRetSE1 := ExecBlock("LJ901SE1",.f., .f., { aSE1, oAPed, oRetExtra })

		For nR := 1 to len(aRetSE1)
			aAdd(aSE1, aRetSE1[nR])
		Next nR

		RestArea(aAreaAnt)

		Lj900XLg("Executado p.E. " + "LJ901ASE1" ,MGU->MGU_PEDECO)

	EndIf

	lMsErroAuto := .F.
	lAutoErrNoFile := .T.

	bOldError := ErrorBlock( {|x| Lj901AVE(x) } ) // muda code-block de erro

	Begin Sequence
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera o Titulo                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Lj900XLg("Verificação da filial cEmpAnt/cFilAnt" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil(),"")

			MSExecAuto({|x,y| Fina040(x,y)},aSE1,3)
		Lj900XLg("Verificação da filial cEmpAnt/cFilAnt" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil(),"")

	Recover
		lMsErroAuto := .T.
	End Sequence

	ErrorBlock( bOldError ) // Restaura rotina de erro anterior

	If  lMsErroAuto
		aLog := GetAutoGrLog()
		cMensagem := "LOJA901A - Lj901AGOrT: " + STR0010 + CRLF +  GeraErro(aLog)     //"Erro no ExecAuto"
		Lj900XLg(cMensagem, MGU->MGU_PEDECO)
		cRetErro := "12" //"Problemas na geração do Título de Contas a Receber"
		RollBackSx8()
		lRet := .F.
		If lLjx904ErrE
			aadd(aLog, cMsgTr)
			Ljx904ErrE(aLog,Nil,"FINA",MGU->MGU_PEDECO,Nil,Nil)
		EndIf
		lErroProc := .T.
		Exit
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recupera o nome da Administradora para gravar no³
	//³campo E1_NOMCLI. Pois a funcao A40DupRec        ³
	//³Grava com o nome do Cliente da Venda            ³
	//³SE1 ja esta posicionado.                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lNotFinPro
		RecLock( "SE1",.F.)
		SE1->E1_NOMCLI  := SAE->AE_DESC
		MsUnlock( )
	Else
		RecLock( "SE1",.F.)
		SE1->E1_NOMCLI  := cCliFin
		MsUnlock( )
	EndIf

	If lMEP .AND. AllTrim(SL4->L4_FORMA) $ "CC/CD"
		nParcMEP++ //Incrementa o contador TEF
		MEP->(DbSetOrder(1)) ////MEP_FILIAL+MEP_PREFIX+MEP_NUM+MEP_PARCEL+MEP_TIPO+MEP_PARTEF
		If !MEP->(DbSeek(xFilial("MEP") + PadR(SL1->L1_SERPED, nTamPref) + PadR(SL1->L1_DOCPED, nTamNum) + PadR(cParcela, nPamParc)+ PadR(SL4->L4_FORMA, nTamTipo) +  StrZero(nParcMEP, nTamParTEF)))
			RecLock("MEP", .T.)
			REPLACE MEP->MEP_FILIAL WITH xFilial("MEP")
			REPLACE MEP->MEP_PREFIX WITH SL1->L1_SERPED  //SE1->E1_PREFIXO
			REPLACE MEP->MEP_NUM 	WITH SL1->L1_DOCPED //SE1->E1_NUM
			REPLACE MEP->MEP_PARCEL WITH cParcela // SE1->E1_PARCELA
			REPLACE MEP->MEP_TIPO   WITH SL4->L4_FORMA //SE1->E1_TIPO
			REPLACE MEP->MEP_PARTEF WITH StrZero(nParcMEP, nTamParTEF)


			MEP->(MsUnLock())
			MEP->(FkCommit())
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|  Gera contas a pagar para a administradora financeira	|
	//|  caso exista AE_TAXA  > 0 cadastrada e se parametro		|
	//|  MV_LJGERTX = .T. e o fornecedor nao for vazio         	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGeraTaxa .AND. ((SAE->AE_TAXA > 0) .OR. (nValTaxAdm >0)) ;
		.AND. AllTrim(SL4->L4_FORMA) $ "CC/CD" .AND. !Empty(cNumSA2)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso esteja preenchido o valor da Taxa de Administração do      ³
		//³plano da Administradora financeira, da prioridade ao MEN_TAXADM.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IIf( (nValTaxAdm > 0), (nValAdm := SE1->E1_VALOR*nValTaxAdm/100), (nValAdm := SE1->E1_VALOR*SAE->AE_TAXA/100))

		aVetorSE2 :={	{"E2_PREFIXO"	,SE1->E1_PREFIXO                    ,Nil} ,;	// 01
                        {"E2_NUM"	   	,SE1->E1_NUM                        ,Nil} ,; 	// 02
                        {"E2_PARCELA"	,SE1->E1_PARCELA                    ,Nil} ,; 	// 03
                        {"E2_TIPO"		,SE1->E1_TIPO                       ,Nil} ,;	// 04
                        {"E2_NATUREZ"	,SE1->E1_NATUREZ                    ,Nil} ,;	// 05
                        {"E2_FORNECE"	,cNumSA2	 	                    ,Nil} ,;	// 06
                        {"E2_LOJA"		,cA2_Loja                           ,Nil} ,; 	// 07
                        {"E2_EMISSAO"	,dDataBase                          ,NIL} ,;	// 08
                        {"E2_VENCTO"	,SE1->E1_VENCTO                     ,NIL} ,; 	// 09
                        {"E2_VENCREA"	,SE1->E1_VENCREA                    ,NIL} ,; 	// 10
                        {"E2_VALOR"		,A410Arred(nValAdm , "L2_VRUNIT")   ,NIL} ,;    // 11
                        {"E2_HIST"		,AllTrim(SE1->E1_NUM)               ,NIL} } 	// 12

		lMsErroAuto := .F.

		lAutoErrNoFile := .T.

		bOldError := ErrorBlock( {|x| Lj901AVE(x) } ) // muda code-block de erro

		Begin Sequence
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz a inclusao do contas a pagar via ExecAuto ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Lj900XLg("Verificação da filial cEmpAnt/cFilAnt" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil(),"")
				MSExecAuto({|x,y,z| Fina050(x,y,z)}, aVetorSE2, , 3)
			Lj900XLg("Verificação da filial cEmpAnt/cFilAnt" + cEmpAnt + "/" + cFilAnt + " FWFunction " + FWGrpCompany()   +"/" + FWCodFil(),"")

		Recover
			lMsErroAuto := .T.
		End Sequence

		ErrorBlock( bOldError ) // Restaura rotina de erro anterior

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se houveram erros durante a execucao da rotina automatica.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMsErroAuto
			 Lj900XLg("Problemas na rotina automatica " + " FINA050 " + GeraErro(GetAutoGRLog())  ,  MGU->MGU_PEDECO )
			lRet := .F.
			cRetErro := "13" //"Problemas na geração do Título de Contas a Pagar da Taxa Administrativa"
			lErroProc := .T.
			Exit
		Endif
	EndIf

	//geracao do titulo - final
	SL4->( DbSkip() )

EndDo

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901ASAE
Seta o Tipo do Titulo
@param   cTipo - Tipo do Título
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@sample Lj901ASAE(cTipo)
/*/
//-------------------------------------------------------------------
Function Lj901ASAE(cTipo)

cAE_Tipo := cTipo

Return cAE_Tipo

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901AGAE
Retorna o Tipo do Titulo, associado ao Pedido e-commerce
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@sample Lj901AGAE()
/*/
//-------------------------------------------------------------------
Function Lj901AGAE()
Local cRet := "" //Retorno da rotina
Local cWhere := "" //String de consulta
Local cAlias := "" //Alias da Consulta
Local lPedECom := SC5->(ColumnPos("C5_PEDECOM")) > 0 //Campo e-commerce existe
Local cC5PedEcom := "" //Pedido e-commerce
Local lBaixa := .F. //Baixou o título
Local aAreaSE1 := {}
Local aAreaMGT := {}
Local lStatusPed := AliasInDic("MH6")
Local aAreaMH6 := {}

If Empty(cAE_Tipo) .AND. lPedECom
	//Busca o tipo no orçamento e-commerce
	cAlias := GetNextAlias()

	//Condicional para a query
	cWhere := "%"
	cWhere += " C5_FILIAL = '" + xFilial("SC5") + "'"
	cWhere += " AND C5_NUM = '" + SC5->C5_NUM + "'"
	cWhere += " AND SC5.D_E_L_E_T_ <> '*'"
	cWhere += " AND L1_FILIAL = '" + xFilial("SL1") + "'"
	cWhere += " AND L1_ECFLAG = '1'"
	cWhere += " AND SL1.D_E_L_E_T_ <> '*'"
	cWhere += "%"

	//Executa a query
	BeginSql alias cAlias
		SELECT
			C5_FILIAL, C5_NUM, C5_PEDECOM, L1_FILIAL, L1_NUM, L1_FORMPG, L1_SERPED, L1_DOCPED
		FROM %table:SC5% SC5
		INNER JOIN %table:SL1% SL1
		ON (  SC5.C5_NUM = SL1.L1_PEDRES AND SC5.C5_PEDECOM = SL1.L1_ECPEDEC 	 )
		WHERE %exp:cWhere%
	EndSql


	(cAlias)->(DBGoTop())

	If ( !(cAlias)->(Eof())  )

		//Verifica se a forma de pagamento é financiado
		//Se for realiza as seguintes validações adicionais
		If AllTrim((cAlias)->L1_FORMPG) == "FI" .AND. !Empty((cAlias)->C5_PEDECOM)

			//Primeiramente verifica se existe baixa associada ao título e-commerce
			If !Empty((cAlias)->L1_SERPED) .AND. !Empty((cAlias)->L1_DOCPED)
					aAreaSE1 := SE1->(GetArea())
					SE1->(DbSetOrder(1) )	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

					SE1->(DbSeek(xFilial("SE1")+(cAlias)->L1_SERPED+(cAlias)->L1_DOCPED))

					Do While !lBaixa .And. SE1->(!(Eof()) .And. (E1_FILIAL+E1_PREFIXO+E1_NUM == xFilial("SE1")+(cAlias)->L1_SERPED+(cAlias)->L1_DOCPED)  .And. AllTrim(E1_TIPO) ==  AllTrim("FI") )
						lBaixa := SE1->(Round(E1_SALDO,2)) == 0
						SE1->(DbSkip())
					EndDo
					RestArea(aAreaSE1)

					If !lBaixa
						//Verifica se existe confirmação Manual de Pedido Market Place
						aAreaMGT := MGT->(GetArea())
						MGT->(DbSetOrder(2)) //FILIAL + MGT_PEDIDO
						MGT->(DbSeek(xFilial("MGT") + (cAlias)->C5_NUM))

						Do While !lBaixa .AND. MGT->( !Eof()  .AND. MGT_FILIAL = xFilial("MGT") .AND. MGT_PEDIDO = (cAlias)->C5_NUM)
							lBaixa := AllTrim(MGT->MGT_STATUS) == "LB"
							MGT->(DbSkip(1))
						EndDo

						RestArea(aAreaMGT)

						If !lBaixa
							//Verifica se existe a funcionalidade de status do Pedido
							If lStatusPed
								aAreaMH6 := MH6->(GetArea())
								MH6->(dbSetOrder(1))	// MH6_FILIAL+MH6_PDECOM
								cC5PedEcom := PadR(AllTrim(SC5->C5_PEDECOM), (cAlias)->(TamSx3("C5_PEDECOM")[1]))
								If MH6->(DbSeek(xFilial("MH6")+cC5PedEcom))
									lBaixa := AllTrim(MH6->MH6_STATUS) == "10" //Pagamento confirmado
								EndIf

								RestArea(aAreaMH6)
							EndIf
							If !lBaixa
								cRet := (cAlias)->L1_FORMPG
							EndIf
						EndIf
					EndIf
			EndIf
		EndIf
	EndIf
	(cAlias)->(DBCloseArea())
EndIf

If Empty(cRet)
	cRet := cAE_Tipo
EndIf

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} lj901KtIt
Retorno dos dados do Kit
@param  oItPed - Objeto do item
@param	nCents - Centavos não arredondado
@return	aKit - Dados do Kit sendo: [1] Codigo [2]Quantidade  {3]Valor Unitario  {4]Valor do Item  {5]Preço de Tabela Unitario {6]Total da tabela Item
@author  Varejo
@version 	P11.8
@since   	18/02/2015
@sample Lj901KtIt( oItPed, nCents )
/*/
//-------------------------------------------------------------------
Static Function Lj901KtIt(oItPed, nCents,cPedCom )

	Local nC 			:= 0  //Contador
	Local cItemId 		:= AllTrim(oItPed:_RECEIPT_ITEM_ID:TEXT) //id do Item
	Local aKit 			:= {}  //Produtos do Kit, onde
	Local aItemKit 		:= {}  //Itens do produto Kit
	Local nPrcTabIt		:= 0   //Preço de Tabela do item
	Local nProp 		:= 0   //Proporção do Preço de Venda/ Preco de Tabela
	Local nValorKit		:= 0   //Valor de venda do Kit
	Local nVlrKitTab	:= 0   //Valor do Kit na Tabela de Preço
	Local nTotTbItem	:= 0   //Valor de Tabela de Preço do item
	Local nQuantidade	:= 0   //Quantidade do item
	Local nValorUni 	:= 0   //Valor Unitario do Item
	Local nTotPrcKit 	:= 0 	//Total de tabela do Kit
	Local nTotItem 		:= 0    //total do Item
	Local nDiff 		:= 0    //Diferença entre total dos itens X valor do Kit
	Local nDiffQtde 	:= 0  //Diferença entre total dos itens X valor do Kit em cento
	Local nVlrKitUni 	:= 0 //Valor do Kit Unitario
	Local nQuantKit 	:= 0  //Quantidade do Kit
	Local nPos1			:= 0 //posicao anterior
	Local nDecValor 	:= TamSx3("C6_VALOR")[2]
	Local nTabItem		:= 0 //Preço de tabela do item
	default nCents := 0
	default cPedCom	:= ""

	nQuantKit:=  Val(oItPed:_QUANTITY:TEXT)  //Quantidade de produtos
	nValorKit := Val(oItPed:_ADJUSTED_PRICE:TEXT)/100  //Valor do Item Kit
	nVlrKitUni :=  nValorKit / nQuantKit  //Valor Unitario do  Kit
	nVlrKitTab :=  A410Arred( Val(oItPed:_LIST_PRICE:TEXT)/100,, "C6_VALOR", _MoedaDef )  //Preco de Lista do Kit
	nProp := nVlrKitUni/nVlrKitTab
	LjGrvLog(cPedCom,"PRODKIT - ID do item :",cItemId)
	LjGrvLog(cPedCom,"PRODKIT - Valor do Item :",nValorKit)
	LjGrvLog(cPedCom,"PRODKIT - Quantidade :",nQuantKit)
	LjGrvLog(cPedCom,"PRODKIT - Preco de Lista :",nVlrKitTab)

	If ValType( oItPed:_KIT_ITEM) <> "A"
		aAdd(aItemKit, oItPed:_KIT_ITEM )
	Else
		aItemKit := aClone(oItPed:_KIT_ITEM)
	EndIf

	For nC := 1 to Len(aItemKit)
		If Alltrim(aItemKit[nC]:_RECEIPT_ITEM_ID:TEXT)  == cItemId

			nQuantidade := Val(aItemKit[nC]:_QUANTITY:TEXT)
			nValorUni :=   A410Arred( Val(aItemKit[nC]:_ADJUSTED_PRICE:TEXT), "C6_VALOR", _MoedaDef )
			nTabItem := A410Arred( Val(aItemKit[nC]:_PRORATED_PRICE:TEXT), "C6_VALOR", _MoedaDef )

			If nValorUni == 0 //Joga 1 centavo para não vender item zerado - fabiana
				nValorUni := 0.01
			EndIf
			nPrcItem :=  A410Arred(nValorUni *  nQuantidade,"C6_VALOR", _MoedaDef )   //Preço do Item

			//Calcula a proporcionalidade entre preco de venda e o preco do item e multiplica o preco de tabela do kit
			nPrcTabIt :=     ( ( (Val(aItemKit[nC]:_PRORATED_PRICE:TEXT) * nQuantidade ) / nValorKit  ) * nVlrKitTab ) / (nQuantidade / nQuantKit)


			If nPrcTabIt == 0 //joga 1 centavo para não vender item zerado - fabiana
				nPrcTabIt := 0.01
			EndIf


			nPrcTabIt :=  A410Arred(nPrcTabIt,"C6_VALOR", _MoedaDef )   //Preço do Item

			nTotTbItem := nPrcTabIt * nQuantidade //Preço total do Item
			nTotPrcKit +=  nPrcTabIt * (nQuantidade / nQuantKit) //Preco de tabela do componente Kit
			nTotItem += nPrcItem //total do Item

		                       //Codigo             		  //Quantidade                         //Valor Unitario          //Valor do Item  //Preço de Tabela Unitario //Total da tabela Item
			aAdd(aKit , { aItemKit[nC]:_PF_ID:TEXT, nQuantidade, nValorUni, 			nPrcItem	, 	nPrcTabIt			, nTotTbItem })

		EndIf
	Next

	//Preço de Venda do Kit
	If NoRound(nTotItem,nDecValor) <> NoRound(nValorKit,nDecValor) //Preço de Venda do item
		LjGrvLog(cPedCom,"PRODKIT - KIT TOTAL ",aKit)
		LjGrvLog(cPedCom,"Total do Item ",nTotItem)

		nDiff := (nTotItem - nValorKit) //Valor do item superior,lança como desconto
		LjGrvLog(cPedCom,"PRODKIT - TOTAL DOS ITENS DIFERENTE DO KIT ",nDiff)
		nDiffQtde := nDiff * (10**nDecValor)  //Quantidade em centavos diferença
		nC := aSCan ( aKit, { |k| (nDiffQtde % k[2])  == 0 } )
		If nC = 0
			nC := Len(aItemKit)
		EndIf

		nTotItem -= aKit[nC, 04]
		aKit[nC, 03] :=  A410Arred( (aKit[nC, 04] - nDiff) /aKit[nC, 02],  "C6_VALOR", _MoedaDef)  //Valor Unitario
		aKit[nC, 04] := aKit[nC, 03] * aKit[nC, 02]

		nTotItem +=	aKit[nC, 04]

		If aKit[nC, 06] > nDiff .AND.  NoRound((aKit[nC, 06] - nDiff) /aKit[nC, 02],nDecValor) > 0
			nTotPrcKit -=  ( aKit[nC, 05] * (aKit[nC, 02]/ nQuantKit)  )
			aKit[nC, 06] -=  nDiff //Valor Tabela do Item
			aKit[nC, 05] :=  A410Arred(aKit[nC, 06]/aKit[nC, 02], "C6_VALOR", _MoedaDef)   //Valor Unitario de tabela
			nTotPrcKit += ( aKit[nC, 05] * (aKit[nC, 02]/ nQuantKit)  )
		EndIf

		If NoRound(nTotItem,nDecValor) <> NoRound(nValorKit,nDecValor)
			nCents := Max( (nTotItem - nValorKit), 0)
		EndIf

	EndIf

	//Verifica se o preço de tabela NÃO é  o mesmo do somatório do valor do item
	If nProp <> 1 .AND. NoRound(nTotPrcKit,nDecValor) <> NoRound(nVlrKitTab,nDecValor) //Preço de Venda do item
		LjGrvLog(cPedCom,"PRODKIT - KIT TOTAL ",aKit)
		LjGrvLog(cPedCom,"Total do Kit ajustado ",nTotPrcKit)

		nDiff := (nTotPrcKit - nVlrKitTab) //Valor do item superior,lança como desconto
		nDiffQtde := nDiff * (10**nDecValor)  //Quantidade em centavos diferença

		LjGrvLog(cPedCom,"PRODKIT - 2 DIFERENCA ENTRE O KIT E A SOMA  ",nDiff)
		nC := aSCan ( aKit, { |k| (nDiffQtde % k[2])  == 0 } )
		If nC = 0
			nC := Len(aItemKit)
		EndIf

		//Salva Posicao anterior localizada
		nPos1 := nC

		If aKit[nC, 06] > nDiff .AND.  NoRound((aKit[nC, 06] - nDiff) /aKit[nC, 02],nDecValor) > 0
			//Tratamento para não zerar o preço Unitario

			aKit[nC, 06] -=  nDiff //Valor Tabela do Item

			aKit[nC, 05] :=  A410Arred(aKit[nC, 06]/aKit[nC, 02], "C6_VALOR", _MoedaDef)   //Valor Unitario de tabela
		Else
			//Regra 2
			//Lança como acrescimo/desconto
			//Elege um item para lançar
			nC := aSCan ( aKit, { |k| ( (nDiffQtde % k[2])  == 0) .AND. k[6] > nDiff .AND.  NoRound((k[06] - nDiff) /k[02],nDecValor) > 0  } )
			If nC = 0
				nC := Len(aItemKit)
			EndIf

			//Verifica se não é a mesma posicao anterior
			If nC == nPos1
				If nC == Len(aItemKit)
					nC := 1
				Else
					nC := Len(aItemKit)
				EndIf
			EndIf

			aKit[nC, 06] -=  nDiff //Valor Tabela do Item

			aKit[nC, 05] :=  A410Arred(aKit[nC, 06]/aKit[nC, 02], "C6_VALOR", _MoedaDef)   //Valor Unitario de tabela
		EndIf

	EndIf

Return aKit

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901APrc
Retorno da tabela de preço , enquanto a CiaShop não envia a tabela de Preço ERP utilizada
@param   nPrecoTab - Preço de tabela
@author  Varejo
@version 	P11.8
@since   	18/02/2015
@sample Lj901APrc( nPrecoTab)
/*/
//-------------------------------------------------------------------
Function Lj901APrc( nPrecoTab)
Local lRet := .F.        //Retorno
Local nPosPrcTab := 0     //Posicao da Tabela de Preço

DEFAULT nPrecoTab := 0

If nPrecoTab > 0
	lRet := .T.
Else
	If ValType(aPosCpoDet) == "A"
		If (nPosPrcTab	:= 	Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_PRCTAB"})) > 0	// Preço de tabela
			If  ValType(aColsDet) == "A" .AND. ValType(n) == "N"  .AND. n > 0 .AND.  Len(aColsDet[n]) >=  nPosPrcTab
				nPrecoTab := aColsDet[n][nPosPrcTab]
				lRet := !Empty(nPrecoTab)
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901AVE
Retona Analisadora de Erro
@param e - Codigo do Erro
@author  Varejo
@version 	P11.8
@since   	23/07/2015
@sample LOJA901A
/*/
//-------------------------------------------------------------------
Function Lj901AVE(e, lNoMGU, cChave, aLog)
Local lRet := .F.
Local  cTmp := ""

Default cChave := "N/A"

Default lNoMGU :=  MGU->(Eof())
Default aLog := {}

If e:gencode > 0
	If !lNoMGU
		cChave := MGU->MGU_PEDECO
	EndIf


   	Lj900XLg("Pedido e-commerce " , cChave )
	Lj900XLg( Replicate("*", 40), cChave)
	cTmp := e:DESCRIPTION
	Lj900XLg( "DESCRIPTION:" + cTmp, cChave )
	aAdd( aLog, cTmp )
	cTmp := e:ERRORSTACK
	Lj900XLg( "ERRORSTACK:" + cTmp, cChave)
	aAdd(aLog, "ERRORSTACK: " + cTmp)
	Lj900XLg( Replicate("*", 40), cChave )
	lRet:=.T.

	Break
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GeraErro
Converte o Erro de String
@param aErro	Array de Erro
@param cValue		Tabela

@author  Varejo
@version P11.8
@since   05/05/2015
@return  cErro 	Mensagem de Erro
@obs
@sample
/*/
//-------------------------------------------------------------------

Static Function GeraErro(aErro)

Local cErro := ""
Local nX := 1

For nX := 1 to Len(aErro)

	cErro += aErro[nX] + CRLF
Next nx

Return cErro

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901Auto
Retorna se é rotina automatica do EC
@author  Varejo
@version P11.8
@since   05/05/2015
@return  lLj901Auto 	ExecAuto do EC
@obs
@sample
/*/
//-------------------------------------------------------------------
Function Lj901Auto()

Return lLj901Auto

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901StA
Setup de rotina do EC
@param lEnable  - Habilita/Desabilita
@author  Varejo
@version P11.8
@since   05/05/2015
@return  lLj901Auto 	ExecAuto do EC
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function Lj901StA(lEnable)
	lLj901Auto := lEnable

Return lLj901Auto


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901StI
Indica se a venda é EC e tem IPI
@param lEnable  - Habilita/Desabilita
@author  Varejo
@version P11.8
@since   05/05/2015
@return  lLj901Auto 	ExecAuto do EC
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function Lj901StI(lEnable)
	lLj901AIPI := lEnable

Return lLj901AIPI

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ901AIPI
Retorna se a venda tem IPI
@author  Varejo
@version P11.8
@since   05/05/2015
@return  lLj901Auto 	ExecAuto do EC
@obs
@sample
/*/
//-------------------------------------------------------------------
Function LJ901AIPI()

Return lLj901AIPI

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901ACIPI
Calcula do Valor do IPI embutido
@param   nCont - Contador do Item
@param   cProduto - Produto
@param   nQtdVen - Quantidade Vendida
@param   nTotal - Total do Item
@param   nValor - Valor do Item
@param   nPrcUni - Preço Unitário
@param   cATES - TES
@param   lMvLjIPEn - IPI Embutido
@param   nCasasIPI - Numero de Casas do IPI
@param   lMVRNDIPI - Arredondamento do IPI
@param   aItemPed - Item do Pedido calculado
@param   lIPIBrut - IPI Bruto
@param   lRecall - Recalcula IPI
@param   lPrdIPI - Produto com IPI
@param   nTotCents - Centavos arrendondados
@param   lErroVlIPI - Erro no IPI
@param   lIPIAjst - Ajusta o valor do IPI?
@param   cErroIPI - Mensagem de Erro no IPI
@author  Varejo
@version 	P11.8
@since   	22/07/2015
@sample Lj901ACIPI(nCont, cProduto, nQtdVen, nTotal, ;
					nValor, nPrcUni, cATES, 	lMvLjIPEn , ;
					nCasasIPI, lMVRNDIPI, aItemPed, lIPIBrut, ;
					lRecall, lPrdIPI, nTotCents, lErroVlIPI, ;
					lIPIAjst, @cErroIPI)
/*/
//-------------------------------------------------------------------

Static Function Lj901ACIPI(nCont, cProduto, nQtdVen, nTotal, ;
		nValor, nPrcUni, cATES, 	lMvLjIPEn , ;
		nCasasIPI, lMVRNDIPI, aItemPed, lIPIBrut, ;
		lRecall, lPrdIPI, nTotCents,lErroVlIPI, ;
		lIPIAjst, cErroIPI, nPerJur)


	Local nDescUni 		:= 0 //Desconto Unitário
	Local aAreaSF4 		:= {} //WorkArea SF4
	Local lProdIPI		:= .F. //Produto com IPI
	Local nAliqIPI 		:= 0 //Aliquota do IPI
	Local nValIPIFis 	:= 0 //Valor do IPI calculado pela MatxFis
	Local nPrcUniSIP 	:= 0 //Preco Unitario sem IPI
	Local lFreteIPI		:= .F. //Frete com IPI
	Local nBaseIPI		:= 0 //Valor do IPI
	Local lIPIBrutIt	:= .F. //IPI bruto sobre o item?
	Local nValDescUni 	:= 0 //Valor do Desconto Unitário
	Local nFreteUni		:= 0 //Frete Unitario
	Local nDespesaUni 	:= 0 //Despesa Unitaria
	Local nSeguroUni	:= 0 //Seguro Unitarui
	Local nFrSegDspUni 	:= 0 //Frete/Seguro/Despesa Unitario
	Local nFrSegDespIt	:= 0 //Frete/Seguro/Despesa Item
	Local nValIPICal 	:= 0 //Valor IPI Calculado
	Local nValItCalc 	:= 0 //Valor do Item Calculado
	Local nValItVen 	:= 0 //Valor do item da venda
	Local nValorItAnt   := nValor //Valor anterior do item
	Local cMsg			:= "" //mensagem de erro
	Local nVlPrcOri		:= 0 //Preço de tabela original
	Local nIPIPaut		:= 0 //Valor do IPI de Pauta
	Local aItExcecao	:= {} //Exceção Fiscal do Item
	Local nReduzBase	:= 0
	Local lAcresDup     := SuperGetMv("MV_ACRSDUP", .F., .T.)
	Local nValAcrUni	:= 0
	Local nValAcrIt		:= 0
	Local nValAcrUOr	:= 0
	Local nValAcrItOr	:= 0
	Local aItIPI		:= {} //Array com os itens do IPI
	Local nValIpiUni	:= 0  // valor do unitario do ipi com mais de 2 casas decimais
	Local nValIpiTot    := 0 // valor total do IPI por item
	Local lQtdCsIpi		:= GETNEWPAR("MV_LJECCAS", .F.)
	Local lCsIpi		:= IIF(TamSX3("C6_PRCVEN")[2] > 2 .AND. TamSX3("C6_PRUNIT")[2] > 2  .AND. lQtdCsIpi ,.T.,.F.) // Verifica se o cliente vai utilizar mais que 2 casas decimais

	Default lRecall := .f.

	aAreaSF4 := SF4->(GetArea())


	lProdIPI :=  ( Posicione( "SF4", 1,  xFilial("SF4") + cATes , "F4_IPI") ) == "S" //F4_FILIAL + F4_COD

	If lProdIPI

		//Busca os valores de IPI da MatxFis
		nReduzBase := IIF( MaFisRet(nCont,"IT_PREDIPI") > 0, MaFisRet(nCont,"IT_PREDIPI") / 100, 1)
		nAliqIPI := MaFisRet(nCont,"IT_ALIQIPI")
		aItIPI := MaFisRet(nCont,"IT_IPI")
		If Len(aItIPI) >= 5
			nIPIPaut := aItIPI[05]  //IPI de Pauta (não tem referencia na MaFisRet)
		EndIf

		aItExcecao := MaFisRet(nCont,"IT_EXCECAO")
		If Len(aItExcecao) > 0
			If aItExcecao[15] > 0
				nReduzBase := aItExcecao[15] / 100
			EndIf
			If aItExcecao[17] > 0
				nAliqIPI := aItExcecao[17]
			EndIf
			If aItExcecao[09] > 0
				nIPIPaut := aItExcecao[09]
			EndIf
		EndIf

		lProdIPI :=  nAliqIPI > 0 .OR. nIPIPaut > 0

		If lProdIPI

			lIPIBrutIt := IIF(Empty(SF4->F4_TPIPI), lIPIBrut, SF4->F4_TPIPI == "B")
			lPrdIPI := .T.
			lFreteIPI := SF4->F4_IPIFRET == "S"
			lDespesaIPI := SF4->F4_DESPIPI == "S"


			//Valor do Desconto - esse deve se manter fixo
			nDescUni :=  nPrcUni - nValor

			//Preço de venda
			nPrcUniSIP := nPrcUni
			nVlPrcOri := nPrcUni

			nFreteUni	:= A410Arred( aItemPed[02]/nQtdVen, "C6_VALOR", _MoedaDef )
			nDespesaUni := A410Arred(aItemPed[03]/nQtdVen, "C6_VALOR", _MoedaDef )
			nSeguroUni := A410Arred(aItemPed[04]/nQtdVen, "C6_VALOR", _MoedaDef )


			nValDescUni := aItemPed[06]

			If nIPIPaut == 0 //Se não for IPI de Pauta, faz o calculo

				nFrSegDspUni := IIF(lFreteIPI, nFreteUni, 0) + IIF(lDespesaIPI, nDespesaUni+ nSeguroUni, 0)
				nFrSegDespIt := IIF(lFreteIPI, aItemPed[02], 0) + IIF(lDespesaIPI, aItemPed[03]+ aItemPed[04], 0)

				nBaseIPI := nPrcUni //+ nFrSegDspUni

				If !lIPIBrutIt //IPI líquido coloca o desconto
					nBaseIPI -= (nValDescUni + nDescUni)
					If nPerJur > 0 .AND.  ( lAcresDup .OR. SF4->F4_DUPLIC=="S" )
						nValAcrUni := A410Arred(nPrcUni * nPerJur/100 , "C6_VALOR", _MoedaDef )
						nValAcrIt := A410Arred(nValAcrUni * nQtdVen, "C6_VALOR", _MoedaDef )
						nValAcrUOr	:= nValAcrUni
						nValAcrItOr	:= nValAcrIt
						nBaseIPI += nValAcrUni
					EndIf
				EndIf



				//Calcula a base de calculo do IPI embutido
				//Calcula a base de calculo do IPI  - Valor do Frete
				nBaseIPI := (nBaseIPI + nFrSegDspUni) * nReduzBase

				nPrcUniSIP -= LjfnEGetIpi(nBaseIPI, IIF(lQtdCsIpi, 4,nCasasIPI), lMVRNDIPI, nAliqIPI)

			Else
				nPrcUniSIP -= nIPIPaut
			EndIf

			If nPrcUniSIP == 0
				nPrcUniSIP := 0.01
			EndIf

			nValor := (nPrcUniSIP - nDescUni)
			If nValor == 0
				nValor := 0.01
			EndIf

			If nPrcUniSIP <= 0
				nPrcUniSIP := 0.01
			EndIf

			If nPerJur > 0 .AND.  ( lAcresDup .OR. SF4->F4_DUPLIC=="S" )
				nValAcrUni := A410Arred(nPrcUniSIP * nPerJur/100 , "C6_VALOR", _MoedaDef )
				nValAcrIt := A410Arred( nValAcrUni * nQtdVen , "C6_VALOR", _MoedaDef )

				If nValAcrIt > 0
					MaFisAlt("IT_ACRESCI", nValAcrIt ,nCont)
				EndIf
			EndIf

			If nIPIPaut == 0
				MaFisAlt("IT_BASEIPI", ( ( nPrcUniSIP * nQtdVen) + nFrSegDespIt + IIF( lIPIBrutIt, 0 , nValAcrIt -(nValDescUni + nDescUni) )  ) * nReduzBase ,nCont)
			EndIf

			//Retorna o valor do IPI Unitariamente Que já pode conter o frete
			nValIPICal := MaFisRet(nCont,"IT_VALIPI")
			nValIPIFis :=  A410Arred(nValIPICal/nQtdVen, "C6_VALOR", _MoedaDef )

			nValIpiUni := nPrcUni - nPrcUniSIP // valor do unitario do ipi com mais de 2 casas decimais
			nValIpiTot := (nValIpiUni * nQtdVen) // pego o valor total do IPI por item

			If lCsIpi // Se a quantidade de casas decimais for maior de que 2, irá aumentar a precisão do calculo de ipi
				nPrcUni := nPrcUniSIP

			//Apura a diferença da base do IPI calculado + valor do ipi com o preço de tabela
			Elseif	(nPrcUniSIP + nValIPIFis) <> nPrcUni

				Lj900XLg("Recalculando preço do item por conta do IPI  " + "Produto [" + cProduto + "] Preço Anterior " + cValToChar(nPrcUni)    ,  MGU->MGU_PEDECO )


				If  (nPrcUniSIP + nValIPIFis) > nPrcUni
					nPrcUni :=  nPrcUniSIP - ( (nPrcUniSIP + nValIPIFis)  -  nPrcUni )
				Else

					nPrcUni :=   nPrcUniSIP + ( nPrcUni  - (nPrcUniSIP + nValIPIFis) )

				EndIf

				If nPrcUni <= 0 //preço zerado, joga 1 centavo
					nPrcUni := 0.01
				EndIf

				MaFisAlt("IT_BASEIPI", ( (nPrcUni * nQtdVen) + nFrSegDespIt + IIF( lIPIBrutIt, 0 , nValAcrIt - (nValDescUni + nDescUni)) ) * nReduzBase  ,nCont)

				nValIPICal := MaFisRet(nCont,"IT_VALIPI")

				//Retorna o valor do IPI Unitariamente Que já pode conter o frete
				nValIPIFis :=  A410Arred(nValIPICal/nQtdVen, "C6_VALOR", _MoedaDef )

				lRecall := !lIPIAjst

				Lj900XLg("Recalculado preço do item por conta do IPI  " + "Produto [" + cProduto + "] Preço Atual " + cValToChar(nPrcUni)    ,  MGU->MGU_PEDECO )

			Else
				nPrcUni := nPrcUniSIP
			EndIf

			If lCsIpi
				nValItCalc := nValIpiTot  +  ( (nPrcUni + nFrSegDspUni ) *  nQtdVen )
				nValItVen := nTotal + nFrSegDespIt  + (nDescUni *  nQtdVen)
			Else
				nValItCalc := nValIPICal  +  ( (nPrcUni + nFrSegDspUni ) *  nQtdVen )
				nValItVen := nTotal + nFrSegDespIt  + (nDescUni *  nQtdVen)
			Endif

			If !lIPIAjst
				If  nValItCalc   <>  nValItVen
					//Houve diferença no total do Item x Valor do IPI calculado + valor do desconto
					nTotCents :=  nValItCalc - nValItVen
					Lj900XLg("Lançado a diferença entre o item e o valor do IPI calculado  " + "Produto [" + cProduto + "] Desconto " + cValToChar(nTotCents)    ,  MGU->MGU_PEDECO )

				ElseIf lCsIpi
					nTotCents := nValIpiTot // valor total do IPI por item
					nTotCents := ( nTotCents - (nValIpiUni * nQtdVen))
					Lj900XLg("Lançado a diferença entre o item e o valor do IPI calculado (Qtde)  " + "Produto [" + cProduto + "] Desconto " + cValToChar(nTotCents)    ,  MGU->MGU_PEDECO )
				Else
					nTotCents := nValIPICal
					nTotCents := ( nTotCents - (nValIPIFis * nQtdVen))
					Lj900XLg("Lançado a diferença entre o item e o valor do IPI calculado (Qtde)  " + "Produto [" + cProduto + "] Desconto " + cValToChar(nTotCents)    ,  MGU->MGU_PEDECO )

				EndIf
			EndIf

			//Recalcula os Valores
			nValor := nPrcUni - nDescUni //Total Unitário

			If lCsIpi

				nTotal := Round(nValor * nQtdVen,TamSX3("C6_VALOR")[2])	 //Total do item
			Else

				nTotal := nValor * nQtdVen	 //Total do itemVFVF

			Endif

			If nValor <= 0
				cMsg := "PRODUTO: ["+cProduto+ "] Cálculo do Valor Unitário sem o IPI invalido, Valor = " + cValToChar(nValor) + CRLF
				If lIPIBrutIt
				  		cMsg += "Verifique na TES: ["+cATES + "] se campo F4_TPIPI deve ser Bruto (sobre preço de tabela), pois o valor do IPI é superior ao valor do item vendido (com desconto)" + CRLF
			    EndIf

			    cMsg := cMsg + PadC("Valores Originais", 50, "-")+CRLF +;
			       "Preço de Tabela (Unitário) " + cValToChar(nVlPrcOri) + CRLF +;
			       "(-)Valor do Desconto (Unitário) " + cValToChar(nDescUni)+CRLF +;
			        "(+) Valor do Acrescimo (Unitário) " + cValToChar(nValAcrUOr)+CRLF +;
			       "(=)Valor do Item (Unitário)  "+cValToChar(nValorItAnt+nValAcrUOr) + CRLF + CRLF

			      cMsg := cMsg + "Valor do IPI (Unitário) " + cValToChar(nValIPIFis)+CRLF+CRLF+ ;
			      PadC( "Valores Recalculados (já abatido o IPI)",  50, "-")+CRLF +;
				        "Preço de Tabela (Unitário) " + cValToChar(nPrcUni) + CRLF +;
				  		"(-)Valor do Desconto (Unitário) " + cValToChar(nDescUni)+CRLF +;
				  		"(+) Valor do Acrescimo (Unitário) " + cValToChar(nValAcrUni)+CRLF +;
				  		"(=)Valor do Item (Unitário)  "+cValToChar(nValor+nValAcrUni)


				Lj900XLg( cMsg ,  MGU->MGU_PEDECO )
				If Empty(cErroIPI)
					cErroIPI := cMsg
				Else
					cErroIPI += CRLF + cMsg
				EndIf
				lErroVlIPI := .T.
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSF4)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901ApIPI
Recalculo de IPI
@param   	aItemPV - Array do Item do Pedido
@param   	aItemPed - Itens do Pedido
@param   	lMvLjIPEn - IPI Embutido
@param   	nCasasIPI - Casas do Campo valor do IPI
@param   	lMVRNDIPI - Arredonda IPI
@param   	nFrete - Frete
@param   	nSeguro - Seguro
@param   	nDespesa - Despesa
@param   	cCliEnt - Cliente de Entrega
@param   	cLojaEnt - Loja de Entrega
@param   	nDesconto - Desconto
@param   	nTotCents - Totalizador de Centavos de diff no IPI
@param   	lIPIBrut - IPI Bruto
@param   	nTotalPed - Total do Pedido
@param   	lMVLjDtIPI - Joga diff IPI como Desconto
@param   	lMVLjAtIPI - Joga diff IPI como Acrescimo
@param   	nAcesIPI - Total de diff acrescimo no IPI
@param   	lProdIPI - Produto com IPI?
@param		lErroVlIPI - Erro no calculo do IPI
@param		lIPIAjst - Ajusta o valor do IPI?
@param		cErroIPI - Erro no calculo do IPI
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs
@sample Lj901ApIPI (aItemPV, aItemPed, lMvLjIPEn , nCasasIPI,;
		lMVRNDIPI, nFrete, nSeguro,	nDespesa, ;
		cCliEnt, cLojaEnt, nDesconto, nTotCents, ;
		lIPIBrut, nTotalPed, lMVLjDtIPI, lMVLjAtIPI,;
		nAcesIPI, lProdIPI, @lErroVlIPI, lIPIAjst,;
		@cErroIPI, nPerJur, nValSubJ)
/*/
//-------------------------------------------------------------------

Static Function Lj901ApIPI (aItemPV, aItemPed, lMvLjIPEn , nCasasIPI,;
		lMVRNDIPI, nFrete, nSeguro,	nDespesa, ;
		cCliEnt, cLojaEnt, nDesconto, nTotCents, ;
		lIPIBrut, nTotalPed, lMVLjDtIPI, lMVLjAtIPI,;
		nAcesIPI, lProdIPI, lErroVlIPI, lIPIAjst,;
		cErroIPI, nPerJur , nValSubJ)

local cProduto 	:= "" //Produto
local nQtdVen  	:= 0//quantidade
local nTotal   	:= 0 //Total
local nValor   	:= 0 //Valor
Local nPrcUni	:= 0  //Preço Unitario
Local nC 		:= 0 //Contadot
Local nTotIt 	:= Len(aItemPV) //total de Itens do pedido
Local cCodIss 	:= "" //codigo do Serviço
Local cATES		:= "" //TES
Local nPosProd 	:= 0 //Posicao no Array de Pedidos do produto
Local nPosQtde 	:= 0 //Posicao no Array de Pedidos da quantidade
Local nPosPrcUn := 0 //Posicao no Array de Pedidos do preço unitário
Local nPosValor := 0 //Posicao no Array de Pedidos do valor
Local nPosTotal := 0 //Posicao no Array de Pedidos do total do item
Local nPosTES 	:= 0 //Posicao no Array de Pedidos da TES
Local nDescUni	:= 0 //Desconto Unitário
Local lRecall 	:= .F. //Recalcula imposto
Local lRatFrete := .F. //Variavel que indica o rateio do frete
Local nRatFrete := 0 //Rateio do frete
Local nRatSeg 	:= 0 //Rateio do Seguro
Local nRatDesp 	:= 0 //Rateio da Despesa
Local cRatDesp 	:= SuperGetMv("MV_RATDESP") //Rateio de Despesa
Local cTpRtDsp 	:= GetNewPar("MV_TPRTDSP","1") //Tipo de Rateio de Despesa
Local nPeso 	:= 0 //Peso
Local nPesoUni 	:= 0 //Peso Unitário
Local nTotFrtIt := 0 //Frete do Item
Local nTotSegIt := 0 //Seguro do Item
Local nTotDespIt := 0 //Despesa do Item
Local nFreteIt 	:= 0 //Frete do Item
Local nSeguroIt := 0 //Seguro do Item
Local nDespesaIt := 0 //Despesa do item
Local nTotItRat := 0 //total de Itens Rateados
Local nCItFrt 	:= 0 //total de Item do Frete
Local nCentsIPI := 0 //Centavos do IPI do item
Local nTotalNF 	:= 0 //total da Nota
Local nValorAnt := 0 //Valor anterior
Local lReApura 	:= .F. //Reapura?
Local nTotDescIt := 0 //total descontos no item
Local nTotPed		:= 0
Local lReclFrete	:= .F. //Recalcula Frete

//Recalcula os valores de  Rateio de Frete e seguro
nRatDesp := Val(SubStr(SuperGetMv("MV_RATDESP"),AT("DESP=",cRatDesp)+5,1))
nRatFrete:= Val(SubStr(SuperGetMv("MV_RATDESP"),AT("FR=",cRatDesp)+3,1))
nRatSeg  := Val(SubStr(SuperGetMv("MV_RATDESP"),AT("SEG=",cRatDesp)+4,1))

If nTotIt > 0
	nPosProd := aScan(aItemPV[1], { |l| l[1] == "C6_PRODUTO"})
	nPosQtde := aScan(aItemPV[1], { |l| l[1] == "C6_QTDVEN"})
	nPosPrcUn := aScan(aItemPV[1], { |l| l[1] == "C6_PRUNIT"})
	nPosValor := aScan(aItemPV[1], { |l| l[1] == "C6_PRCVEN"})
	nPosTotal := aScan(aItemPV[1], { |l| l[1] == "C6_VALOR"})
	nPosTES := aScan(aItemPV[1], { |l| l[1] == "C6_TES"})
EndIf

For nC := 1 to nTotIt
	nQtdVen :=  aItemPV[nC, nPosQtde][02]
	nPrcUni := aItemPV[nC, nPosValor][02]
	cATES 	:= aItemPV[nC, nPosTES ][02]

	lRatFrete := aItemPed[nC, 08]

	If cTpRtDsp =="1"
		If lRatFrete
			nTotal += nPrcUni *  nQtdVen
			nPeso  += aItemPed[nC, 07]
			nTotItRat++
		EndIf
	Else
		nTotal += nPrcUni *  nQtdVen
		nTotItRat++
	EndIf

Next nC

For nC := 1 to nTotIt
	nQtdVen :=  aItemPV[nC, nPosQtde][02]
	nPrcUni := aItemPV[nC, nPosValor][02]
	lRatFrete := aItemPed[nC, 08]
	nFreteIt := 0
	nDespesaIt := 0
	nTotSegIt := 0

	If !lRatFrete
		nPrcUni := 0
		nPesoUni := 0
	Else
		nPesoUni := aItemPed[nC, 07]
		nCItFrt++
		If nCItFrt < nTotItRat
			If ( nRatFrete == 1 .Or. nPeso == 0)
				nFreteIt := Round(nPrcUni*nFrete/nTotal,2)
			Else
				nFreteIt += Round(nPesoUni*nFrete/nPeso,2)
			EndIf
			If ( nRatDesp == 1 .Or. nPeso == 0)
				nDespesaIt := Round(nPrcUni*nDespesa/nTotal,2)
			Else
				nDespesaIt := Round(nPesoUni*nDespesa/nPeso,2)
			EndIf
			If ( nRatSeg == 1 .Or. nPeso == 0)
				nSeguroIt := Round(nPrcUni*nSeguro/nTotal,2)
			Else
				nSeguroIt := Round(nPesoUni*nSeguro/nPeso,2)
			EndIf
		Else /*nCItFrt == nTotItRat*/
			nFreteIt := Max(nFrete - nTotFrtIt, 0)
			nDespesaIt := Max(nDespesa - nTotDespIt, 0)
			nTotSegIt := Max(nSeguro - nTotSegIt, 0)
		EndIf
	EndIf

	nTotFrtIt += nFreteIt
	nTotSegIt += nSeguroIt
	nTotDespIt += nDespesaIt

	aItemPed[nC, 02] := nFreteIt
	aItemPed[nC, 03] := nTotSegIt
	aItemPed[nC, 04] := nDespesaIt

Next nC

MaFisIni( SA1->A1_COD , SA1->A1_LOJA 	, "C"  		, "S"  ,;
	NIL           , NIL         		, NIL  		, .F. ,;
	"SB1"         , "LOJA701"   		, NIL  		, NIL ,;
	NIL			  , SA1->A1_GRPTRIB		, NIL		, cCliEnt   , ;
	cLojaEnt	  ,	NIL					, NIL		, lMvLjIPEn )

For nC := 1 to nTotIt

	cProduto := aItemPV[nC, nPosProd][02]
	nQtdVen :=  aItemPV[nC, nPosQtde][02]
	nTotal := aItemPV[nC, nPosTotal][02]
	nValor := aItemPV[nC, nPosValor][02]
	nPrcUni := aItemPV[nC, nPosPrcUn][02]
	cATES 	:= aItemPV[nC, nPosTES ][02]
	nDescUni := nPrcUni - nValor


	//Recarrega todos os itens do Pedido
	cCodIss := Alltrim(MaSBCampo("CODISS"))

	//chama a rotina fiscal
	MaFisAdd(	cProduto,;					// Produto
	cATes,;               		// TES
	nQtdVen,;                	// Quantidade
	nPrcUni,;            		// Preco unitario
	(nDescUni + aItemPed[nC, 06]) * nQtdVen ,;// Valor do desconto
	"",;                                     	// Numero da NF original
	"",;                                     	// Serie da NF original
	0,;                                      	// Recno da NF original
	aItemPed[nC, 02],;       			  						// Valor do frete do item
	aItemPed[nC, 04],;      									// Valor da despesa do item
	aItemPed[nC, 03],;       				 					// Valor do seguro do item
	0,;                                     	// Valor do frete autonomo
	nPrcUni * nQtdVen,;  // Valor da mercadoria
	0 ,;                                                       // Valor da embalagem
	0,;	// 15-RecNo do SB1
	0,;	// 16-RecNo do SF4
	nC,;  // 17-Item
	,;	// 18-Despesas nao tributadas - Portugal
	,;	// 19-Tara - Portugal
	,;	// 20-CFO
	,;  // 21-Array para o calculo do IVA Ajustado (opcional)
	,;	// 22-Concepto
	,;	// 23-Base Veiculo
	0,;	// 24-Lote Produto
	0,;	// 25-Sub-Lote Produto
	,;	// 26-Valor do Abatimento ISS
	Iif(cCodIss==Nil , "" ,cCodIss)) // 27-Codigo ISS


Next nC

//Recalcula o valor o preço de tabela

For nC := 1 to nTotIt

	cProduto := aItemPV[nC, nPosProd][02]
	nQtdVen :=  aItemPV[nC, nPosQtde][02]
	nTotal := aItemPV[nC, nPosTotal][02]
	nValor := aItemPV[nC, nPosValor][02]
	nPrcUni := aItemPV[nC, nPosPrcUn][02]
	cATES 	:= aItemPV[nC, nPosTES ][02]
	nCentsIPI := 0
	nValorAnt := nPrcUni

	aItemPed[nC, 9] := nValorAnt
	aItemPed[nC, 10] := nValor
	aItemPed[nC, 11] := nTotal

	Lj901ACIPI(nC, cProduto, nQtdVen, @nTotal, ;
		@nValor, @nPrcUni, cATES, lMvLjIPEn , ;
		nCasasIPI, lMVRNDIPI, @aItemPed[nC], lIPIBrut, ;
		@lRecall, lProdIPI, @nCentsIPI,@lErroVlIPI, ;
		lIPIAjst, @cErroIPI, nPerJur)

	If nPrcUni <> nValorAnt
		If nCentsIPI > 0
			If lMVLjDtIPI
				nTotCents += nCentsIPI
				Lj900XLg(" Diferença de IPI em  Desconto em centavos do Produto [" + cProduto +"]"  + cValToChar(nCentsIPI), MGU->MGU_PEDECO)
			EndIf
		ElseIf nCentsIPI < 0
			If lMVLjAtIPI
				nAcesIPI += Abs(nCentsIPI)
				Lj900XLg(" Diferença de IPI em acrescimo do Produto [" + cProduto +"]"  + cValToChar(nCentsIPI), MGU->MGU_PEDECO)
			EndIf
		EndIf

			aItemPV[nC, nPosTotal][02] := nTotal
			aItemPV[nC, nPosValor][02] := nValor
			aItemPV[nC, nPosPrcUn][02] := nPrcUni
			lReApura := !lIPIAjst
		If !lReclFrete
			lReclFrete :=  ( aItemPed[nC,02] + aItemPed[nC,03] + aItemPed[nC,04] ) > 0
		EndIf
	EndIf


Next nC

MaFisEnd()

//Recalcula a  proporcionalidade do frete
If lReclFrete

	nTotFrtIt := 0
	nTotSegIt := 0
	nTotDespIt := 0
	nTotal := 0
	nPeso := 0
	nTotItRat := 0
	nCItFrt := 0
	For nC := 1 to nTotIt
		nQtdVen :=  aItemPV[nC, nPosQtde][02]
		nPrcUni := aItemPV[nC, nPosValor][02]
		cATES 	:= aItemPV[nC, nPosTES ][02]

		lRatFrete := aItemPed[nC, 08]

		If cTpRtDsp =="1"
			If lRatFrete
				nTotal += nPrcUni *  nQtdVen
				nPeso  += aItemPed[nC, 07]
				nTotItRat++
			EndIf
		Else
			nTotal += nPrcUni *  nQtdVen
			nTotItRat++
		EndIf

	Next nC

	For nC := 1 to nTotIt
		nQtdVen :=  aItemPV[nC, nPosQtde][02]
		nPrcUni := aItemPV[nC, nPosValor][02]

		lRatFrete := aItemPed[nC, 08]
		nFreteIt := 0
		nDespesaIt := 0
		nTotSegIt := 0

		If !lRatFrete
			nPrcUni := 0
			nPesoUni := 0
		Else
			nPesoUni := aItemPed[nC, 07]
			nCItFrt++
			If nCItFrt < nTotItRat
				If ( nRatFrete == 1 .Or. nPeso == 0)
					nFreteIt := Round(nPrcUni*nFrete/nTotal,2)
				Else
					nFreteIt += Round(nPesoUni*nFrete/nPeso,2)
				EndIf
				If ( nRatDesp == 1 .Or. nPeso == 0)
					nDespesaIt := Round(nPrcUni*nDespesa/nTotal,2)
				Else
					nDespesaIt := Round(nPesoUni*nDespesa/nPeso,2)
				EndIf
				If ( nRatSeg == 1 .Or. nPeso == 0)
					nSeguroIt := Round(nPrcUni*nSeguro/nTotal,2)
				Else
					nSeguroIt := Round(nPesoUni*nSeguro/nPeso,2)
				EndIf
			Else /*nCItFrt == nTotItRat*/
				nFreteIt := Max(nFrete - nTotFrtIt, 0)
				nDespesaIt := Max(nDespesa - nTotDespIt, 0)
				nTotSegIt := Max(nSeguro - nTotSegIt, 0)
			EndIf
		EndIf

		nTotFrtIt += nFreteIt
		nTotSegIt += nSeguroIt
		nTotDespIt += nDespesaIt

		aItemPed[nC, 02] := nFreteIt
		aItemPed[nC, 03] := nTotSegIt
		aItemPed[nC, 04] := nDespesaIt

	Next nC

	MaFisIni( SA1->A1_COD , SA1->A1_LOJA 	, "C"  		, "S"  ,;
		NIL           , NIL         		, NIL  		, .F. ,;
		"SB1"         , "LOJA701"   		, NIL  		, NIL ,;
		NIL			  , SA1->A1_GRPTRIB		, NIL		, cCliEnt   , ;
		cLojaEnt	  ,	NIL					, NIL		, lMvLjIPEn )


	For nC := 1 to nTotIt

	//Volta o preco de tabela do item
	aItemPV[nC, nPosPrcUn][02] := aItemPed[nC, 9]
	aItemPV[nC, nPosValor][02] := aItemPed[nC, 10]
	aItemPV[nC, nPosTotal][02] := aItemPed[nC, 11]


		cProduto := aItemPV[nC, nPosProd][02]
		nQtdVen :=  aItemPV[nC, nPosQtde][02]
		nTotal := aItemPV[nC, nPosTotal][02]
		nValor := aItemPV[nC, nPosValor][02]
		nPrcUni := aItemPV[nC, nPosPrcUn][02]
		cATES 	:= aItemPV[nC, nPosTES ][02]
		nDescUni := nPrcUni - nValor

		//Recarrega todos os itens do Pedido
		cCodIss := Alltrim(MaSBCampo("CODISS"))

		//chama a rotina fiscal
		MaFisAdd(	cProduto,;					// Produto
		cATes,;               		// TES
		nQtdVen,;                	// Quantidade
		nPrcUni,;            		// Preco unitario
		(nDescUni + aItemPed[nC, 06]) * nQtdVen ,;// Valor do desconto
		"",;                                     	// Numero da NF original
		"",;                                     	// Serie da NF original
		0,;                                      	// Recno da NF original
		aItemPed[nC, 02],;       			  						// Valor do frete do item
		aItemPed[nC, 04],;      									// Valor da despesa do item
		aItemPed[nC, 03],;       				 					// Valor do seguro do item
		0,;                                     	// Valor do frete autonomo
		nPrcUni * nQtdVen,;  // Valor da mercadoria
		0 ,;                                                       // Valor da embalagem
		0,;	// 15-RecNo do SB1
		0,;	// 16-RecNo do SF4
		nC,;  // 17-Item
		,;	// 18-Despesas nao tributadas - Portugal
		,;	// 19-Tara - Portugal
		,;	// 20-CFO
		,;  // 21-Array para o calculo do IVA Ajustado (opcional)
		,;	// 22-Concepto
		,;	// 23-Base Veiculo
		0,;	// 24-Lote Produto
		0,;	// 25-Sub-Lote Produto
		,;	// 26-Valor do Abatimento ISS
		Iif(cCodIss==Nil , "" ,cCodIss)) // 27-Codigo ISS


	Next nC

	//Recalcula o valor o preço de tabela

	For nC := 1 to nTotIt

		cProduto := aItemPV[nC, nPosProd][02]
		nQtdVen :=  aItemPV[nC, nPosQtde][02]
		nTotal := aItemPV[nC, nPosTotal][02]
		nValor := aItemPV[nC, nPosValor][02]
		nPrcUni := aItemPV[nC, nPosPrcUn][02]
		cATES 	:= aItemPV[nC, nPosTES ][02]
		nCentsIPI := 0
		nValorAnt := nPrcUni

		Lj901ACIPI(nC, cProduto, nQtdVen, @nTotal, ;
			@nValor, @nPrcUni, cATES, lMvLjIPEn , ;
			nCasasIPI, lMVRNDIPI, @aItemPed[nC], lIPIBrut, ;
			@lRecall, lProdIPI, @nCentsIPI,@lErroVlIPI, ;
			lIPIAjst, @cErroIPI, nPerJur)

		If nPrcUni <> nValorAnt
			If nCentsIPI > 0
				If lMVLjDtIPI
					nTotCents += nCentsIPI
					Lj900XLg(" Diferença de IPI em  Desconto em centavos do Produto [" + cProduto +"]"  + cValToChar(nCentsIPI), MGU->MGU_PEDECO)
				EndIf
			ElseIf nCentsIPI < 0
				If lMVLjAtIPI
					nAcesIPI += Abs(nCentsIPI)
					Lj900XLg(" Diferença de IPI em acrescimo do Produto [" + cProduto +"]"  + cValToChar(nCentsIPI), MGU->MGU_PEDECO)
				EndIf
			EndIf

			aItemPV[nC, nPosTotal][02] := nTotal
			aItemPV[nC, nPosValor][02] := nValor
			aItemPV[nC, nPosPrcUn][02] := nPrcUni
			lReApura := !lIPIAjst
		EndIf


	Next nC

	MaFisEnd()
EndIf


If lReApura //Houve alteracao de Preço
	nTotDescIt := 0
	Lj900XLg(" Recalculando total...", MGU->MGU_PEDECO)


	MaFisIni( SA1->A1_COD , SA1->A1_LOJA 	, "C"  		, "S"  ,;
				NIL           , NIL         		, NIL  		, .F. ,;
				"SB1"         , "LOJA701"   		, NIL  		, NIL ,;
				NIL			  , SA1->A1_GRPTRIB		, NIL		, cCliEnt   , ;
				cLojaEnt	  ,	NIL					, NIL		, lMvLjIPEn )


	//Recalcula e apura a diferença
	For nC := 1 to nTotIt

		cProduto := aItemPV[nC, nPosProd][02]
		nQtdVen :=  aItemPV[nC, nPosQtde][02]
		nTotal := aItemPV[nC, nPosTotal][02]
		nValor := aItemPV[nC, nPosValor][02]
		nPrcUni := aItemPV[nC, nPosPrcUn][02]
		cATES 	:= aItemPV[nC, nPosTES ][02]
		nDescUni := nPrcUni - nValor

		nTotDescIt += (nDescUni * nQtdVen)

		//Recarrega todos os itens do Pedido
		cCodIss := Alltrim(MaSBCampo("CODISS"))

		//chama a rotina fiscal
		MaFisAdd(	cProduto,;					// Produto
		cATes,;               		// TES
		nQtdVen,;                	// Quantidade
		nPrcUni,;            		// Preco unitario
		0,;// Valor do desconto
		"",;                                     	// Numero da NF original
		"",;                                     	// Serie da NF original
		0,;                                      	// Recno da NF original
		aItemPed[nC, 02],;       			  						// Valor do frete do item
		aItemPed[nC, 04],;      									// Valor da despesa do item
		aItemPed[nC, 03],;       				 					// Valor do seguro do item
		0,;                                     	// Valor do frete autonomo
		nPrcUni * nQtdVen,;  // Valor da mercadoria
		0 ,;                                                       // Valor da embalagem
		0,;	// 15-RecNo do SB1
		0,;	// 16-RecNo do SF4
		nC,;  // 17-Item
		,;	// 18-Despesas nao tributadas - Portugal
		,;	// 19-Tara - Portugal
		,;	// 20-CFO
		,;  // 21-Array para o calculo do IVA Ajustado (opcional)
		,;	// 22-Concepto
		,;	// 23-Base Veiculo
		0,;	// 24-Lote Produto
		0,;	// 25-Sub-Lote Produto
		,;	// 26-Valor do Abatimento ISS
		Iif(cCodIss==Nil , "" ,cCodIss)) // 27-Codigo ISS

	Next nC

	MaFisAlt("NF_FRETE", nFrete+ nAcesIPI)
	Lj900XLg( "Frete " + cValTochar( nFrete+ nAcesIPI), MGU->MGU_PEDECO)
	MaFisAlt("NF_SEGURO",nSeguro)
	Lj900XLg( "Seguro " + cValTochar( nSeguro), MGU->MGU_PEDECO)
	MaFisAlt("NF_DESPESA",nDespesa)
	Lj900XLg( "Despesa " + cValTochar( nDespesa), MGU->MGU_PEDECO)
	MaFisAlt("NF_DESCONTO", nTotCents +nDesconto+nTotDescIt )
	Lj900XLg( "Desconto " + cValTochar( nTotCents +nDesconto+nTotDescIt ), MGU->MGU_PEDECO)
	nTotalNF := MaFisRet(, "NF_TOTAL")
	Lj900XLg( "Total da Nota " + cValTochar(MaFisRet(, "NF_TOTAL")), MGU->MGU_PEDECO)

	nTotPed := nTotalPed
	If nPerJur > 0
		nTotPed :=  nValSubJ
	EndIf

	If nTotalNF <> nTotPed
		If nTotalNF > nTotPed
			nTotCents += (nTotalNF - nTotPed)
			Lj900XLg( "Total Fiscal " + cValToChar(nTotalNF) + " x Total da venda EC (sem Juros) " + cValToChar(nTotPed)+ " Desconto " + cValtoChar(nTotalNF - nTotPed) , MGU->MGU_PEDECO)
		Else
			nAcesIPI += (nTotPed - nTotalNF)
			Lj900XLg( "Total Fiscal " + cValToChar(nTotalNF) +  " x Total da venda EC (sem Juros) " + cValToChar(nTotPed) + " Acrescimo" + cValtoChar(nTotPed - nTotalNF ) , MGU->MGU_PEDECO)
		EndIf
	EndIf
	MaFisEnd()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901OrEx
Exclui o Orçamento e o pedido
@param cPedRes  - Numero do Pedido
@param cFilRes  - Filial do Pedido
@author  Varejo
@version P12.1.14
@since   15/12/2016
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function Lj901OrEx( cPedRes, cFilRes)
Local aAreaSC5 := {} //WorkArea SC5
Local cMensagem := "" //Mensagem
Local aAreaSM0 := SM0->(GetArea())
Local lRet := .F. //Retorno da rotina


lRet := Lj907OrEx()
///Restaura SM0
RestArea(aAreaSM0)


If lRet
	aAreaSC5 := SC5->(GetArea())
	DbSelectArea("SC5")
	//Ativa o registro para exclusão, para que este orçamento não seja enviado como cancelado
	SET DELETED OFF
	If !Empty(cPedRes) .AND. !Empty(cFilRes)
		If SC5->(DbSeek(xFilial("SC5")+ cPedRes ))
			//Marca cabeçalho como não cancelado para não ir no cancelamento
			RecLock('SC5',.F.)
			SC5->C5_STATUS := "00"
			SC5->(MsUnLock())
		EndIf
	EndIf

	SET DELETED ON
	//Marca o registro como ativo novamente

	RestArea(aAreaSC5)

	cMensagem := "LOJA901A - Lj901AGOrT 2: " + STR0014  +  cFilRes + cPedRes   //"Pedido excluido com sucesso "
	Lj900XLg(cMensagem, MGU->MGU_PEDECO)
Else
	cMensagem := "LOJA901A - Lj901AGOrT 2: " +  STR0015 +  cFilRes + cPedRes   //"Falha na exclusão do pedido "
	Lj900XLg(cMensagem, MGU->MGU_PEDECO)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901APedEx
Exclui o Pedido e a a reserva
@param cPedRes  - Numero do Pedido
@param cFilRes  - Filial do Pedido
@author  Varejo
@version P12.1.14
@since   15/12/2016
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function Lj901APedEx(cPedRes, cFilRes)
Local aAreaSC5 := {} //WorkArea SC5
Local aAreaSC9 := {} //WorkArea SC9
Local aAreaSC6 := {} //WorkArea SC6
Local aAreaSC0 := {} //WorkArea SC0
Local cNumReserva := "" //Numero da Reserva
Local lLiberOk	:= .T. //Liverado ok?
Local lResidOk	:= .T. //Residio ok?
Local lFaturOk	:= .F. //Faturamento ok?

//Exclui cabeçalho(SC5)
aAreaSC5 := SC5->(GetArea())
DbSelectArea("SC5")
SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM
If SC5->(DbSeek(xFilial("SC5")+ cPedRes ))

		//Exclui liberação
	aAreaSC9 := SC9->(GetArea())
	DbSelectArea("SC9")
	SC9->(DbSetOrder(1)) //C9_FILIAL+C9_Pedido
	If SC9->(DbSeek(xFilial("SC9")+ SC5->(C5_NUM) ))
		While !SC9->(Eof()) .AND. SC9->C9_PEDIDO == RTrim(SC5->(C5_NUM))
    		RecLock('SC9',.F.)
			SC9->(DbDelete())
			SC9->(MsUnLock())
			SC9->(dbSkip())
		End
	EndIf
	RestArea(aAreaSC9)

	//Exclui Itens
	aAreaSC6 := SC6->(GetArea())
	aAreaSC0 := SC0->(GetArea())
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM
	If SC6->(DbSeek(xFilial("SC6")+SC5->(C5_NUM)))
		While !SC6->(Eof()) .AND. SC6->C6_NUM == SC5->(C5_NUM)
    		RecLock('SC6',.F.)
    		//Cancela a reserva
    		If !Empty(SC6->C6_RESERVA)

				cNumReserva := SC6->C6_RESERVA

				dbSelectArea("SC0")
				SC0->(dbSetOrder(1))
				SC0->(DbSeek(xFilial("SC0")+cNumReserva))
				// Atenção caso altere este trecho, faça a manutenção tbm na função: A430DelMvc
				While ( !SC0->(Eof()) ) .And. (SC0->(C0_FILIAL+C0_NUM) == xFilial("SC0")+cNumReserva)
					SC0->(RecLock("SC0",.F.))  //Ajuste para estornar o B2_RESERVA

					//Quantidade zerada em Pedido (Liberado, estorna para voltar a reserva)
					If SC0->C0_TIPO  = "LB" .AND. SC0->C0_QTDPED = 0
						SC0->C0_QTDPED := SC0->C0_QTDORIG
					EndIf

					SC0->C0_QUANT  += SC0->C0_QTDPED
					SC0->C0_QTDPED -= SC0->C0_QUANT
					SC0->(MsUnlock())

					a430Reserv({3,C0_TIPO,C0_DOCRES,C0_SOLICIT,C0_FILRES},;
						cNumReserva,;
						SC0->C0_PRODUTO,;
						SC0->C0_LOCAL,;
						SC0->C0_QUANT,;
						{	SC0->C0_NUMLOTE,;
						SC0->C0_LOTECTL,;
						SC0->C0_LOCALIZ,;
						SC0->C0_NUMSERI})
					SC0->(MsUnLock())
					SC0->(dbSkip())
				EndDo

    		Else
    			MaAvalSC6("SC6",2,"SC5",.T.,.F.,@lLiberOk,@lResidOk,@lFaturOk, .f.)
    		EndIf
			SC6->(DbDelete())
			SC6->(MsUnLock())
			SC6->(dbSkip())
		End
	EndIf
	RestArea(aAreaSC6)
	Restarea(aAreaSC0)
	//Exclui cabeçalho(SC5)
	RecLock('SC5',.F.)
	SC5->C5_STATUS := "00"
	SC5->(DbDelete())
	SC5->(MsUnLock())
EndIf

RestArea(aAreaSC5)

cMensagem := "LOJA901A - Lj901AGOrT: " + STR0014  +  cFilRes + cPedRes   //"Pedido excluido com sucesso "
Lj900XLg(cMensagem, MGU->MGU_PEDECO)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901AMEst
Função que retorna a filial do Pedido e o armazém
@param oAPed  - Objeto do Pedido
@param lMultEst  - Trabalha com multiestoque
@param cFilEC2 - Filial e-commerce
@param cCodErro  - Codigo de Retorno do Erro
@param cArmzEC  - Código do Armazém EC
@param aEstEC  - Armazéns retornados pelo Pedido
@return lValido - Pedido válido
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@sample Lj901AMEst(oAPed, lMultEst, cFilEC, cCodErro, ;
					  cArmzEC, aEstEC)
/*/
//-------------------------------------------------------------------
Function Lj901AMEst(oAPed, lMultEst, cFilEC2, cCodErro, ;
					  cArmzEC, aEstEC)
Local nC 			:= 0 //Contador de Itens
Local oNodeEst 		:= NIL //Objeto de Estoque
Local aItens 		:= {} //Array de Itens
Local nTotItens 	:= 0 //total dos itens
Local lValido 		:= .T. //Estoque válido
Local aArmazens 	:= {} //Array de Armazens
Local nC2 			:= 0 //Contador
Local nTotEst 		:= 0 //Total de Estoque
Local cArmzAnter 	:= "" //Armazém anterior
Local cFilAnter 	:= "" //Filial Anterior
Local nTamFil 		:= FWGETTAMFILIAL //Tamanho da Filial
Local aAreaNNR 		:= {} //WorkArea do Armazén
Local aEstoques 	:= {} //Estoques e-commerce
Local cPedEcom 		:= PadR(oAPed:_ORDER_ID:TEXT, TAMSX3("C5_PEDECOM")[1])
Local cMsgTr		:= STR0019 //"CONTROLE TRANSACIONAL HABILITADO. As informações geradas durante processamento deste pedido serão desfeitas."
Local cFilEC		:= "" //Filila e-commerce


//Primeiramente verifica se existe a Funcionalidade de Estoque habilitada
//Itens do pedido de venda
If ValType(oAPed:_RECEIPT_ITEM) == "A"
	aItens := aClone(oAPed:_RECEIPT_ITEM)
Else
	aAdd(aItens, oAPed:_RECEIPT_ITEM)
EndIf


cFilAnter := ""
cArmzAnter := "" //Para o Item zera o Armazém
nTotItens :=  Len(aItens)

For nC := 1 to nTotItens
	//Verifica se existe o objeto do estoque
	aArmazens := {}
	//Validação da informação de entega
	oNodeEst := XmlChildEx ( aItens[nC] , "_RECEIPT_ITEM_WAREHOUSES" )
	//Aqui deverei zerar o armazém qdo puder haver mais de um por pedido

	If (lMultEst := ValType(oNodeEst) = "O")
		If ValType(oNodeEst:_WAREHOUSE_ITEM) = "A"
			aArmazens := aClone(oNodeEst:_WAREHOUSE_ITEM)
		Else
			aAdd(aArmazens, oNodeEst:_WAREHOUSE_ITEM)
		EndIf
		nC2 := 0
		nTotEst := Len(aArmazens)

		For nC2 := 1 to nTotEst
			If Empty(cArmzAnter)
				cArmzEC := aArmazens[nC2]:_ERP_ID:TEXT
				cArmzAnter := aArmazens[nC2]:_ERP_ID:TEXT
				aAdd(aEstoques, cArmzEC)
			ElseIf cArmzAnter <> aArmazens[nC2]:_ERP_ID:TEXT
					lValido := .F.
					cCodErro := "18" //Existe mais de um armazém vinculado a um item
			EndIf

			If Empty(cFilAnter)
				cFilEC := PadR(aArmazens[nC2]:_BRANCH_ERP_ID:TEXT, nTamFil)
				cFilAnter := aArmazens[nC2]:_BRANCH_ERP_ID:TEXT
			ElseIf cFilAnter <> aArmazens[nC2]:_BRANCH_ERP_ID:TEXT
				lValido := .F.
				cCodErro := "19" //Existe mais de uma filial vinculada a um Pedido
			EndIf
			If !lValido
				Exit
			EndIf
		Next nC2
	Else
		Exit
	EndIf

Next nC

If lValido
	nTotItens :=  Len(aEstoques)
	aAreaNNR := NNR->(GetArea())
	NNR->(DbSetOrder(1))//NNR_FILIAL+NNR_CODIGO
	For nC := 	1 to nTotItens
		cArmzEC := aEstoques[nC]

		If ExistFunc("Ljx904Arm")
			cArmzEC := Ljx904Arm(cFilEC, cArmzEC, 2)
		ElseIf Len(AllTrim(cArmzEC)) >= NNR->(Tamsx3("NNR_CODIGO")[1])
			cArmzEC := Right( AllTrim(cArmzEC), NNR->(Tamsx3("NNR_CODIGO")[1]))
		EndIf

		If !NNR->(DbSeek(xFilial("NNR", cFilEC)+ cArmzEC))
			lValido := .F.
			cCodErro := "21" //Armazém não cadastrado ERP
			Exit
		EndIf
		nC2 := aScan(aEstEC, { |e| e == cArmzEC})
		If nC2 = 0
			aAdd(aEstEC, cArmzEC)
		EndIf

	Next nC

	If !Empty(cCodErro) .And. lLjx901CEr
		Ljx901CErr(cCodErro,cPedecom,Nil,cArmzEC,;
					NIL, cMsgTr)
	EndIf
	If lValido
		cFilEC2 := cFilEC
	EndIf
	aEstEC := aClone(aEstoques)
	RestArea(aAreaNNR)
EndIf

Return lValido

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901ASetFil
Função que retorna a filial do Pedido e o armazém
@param lMultEst  - Trabalha com multiestoque
@param cFilRot - Filial de Execução da rotina
@param cFilEC  - Filial do Pedido e-commerce
@param nOpc  - Opção da rotina 1 - Configura Filial, 2- Restaura Filial
@param aAreaSM0  - WorkArea SM0 da rotina
@param nRecSM0  - Registro SM0 da rotina
@param cCodErro  - Código de Erro na validação do Pedido
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@sample Lj901ASetFil(lMultEst, cFilRot, cFilEC, nOpc, ;
						aAreaSM0, nRecSM0, cCodErro)
/*/
//-------------------------------------------------------------------
Function Lj901ASetFil(lMultEst, cFilRot, cFilEC, nOpc, ;
						aAreaSM0, nRecSM0, cCodErro)
Local nTamFil := FWGETTAMFILIAL //Tamanho do campo filial
Local aArea := GetArea() //WokAreaAtual

If lMultEst
	If nOpc = 2 .AND. nRecSM0 > 0
		RestArea(aAreaSM0)
		SM0->(DbGoTo(nRecSM0))
		cFilAnt := cFilRot
	ElseIf nOpc = 1 .AND. cFilRot <> cFilEC .AND. Empty(cCodErro)
		nRecSM0 := SM0->(Recno())
		aAreaSM0 := SM0->(GetArea())
		If !SM0->(DbSeek( SM0->M0_CODIGO + PadR(cFilEC, nTamFil)))
			cCodErro := "20" //Filial não cadastrada
			RestArea(aAreaSM0)
			SM0->(DbGoTo(nRecSM0))
		EndIf
		cFilAnt := cFilEC
	EndIf
EndIf

RestArea(aArea)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj901UsC6R
Função que  verifica se o campo C6_RESERVA está em uso
@return .t. campo usado, .F. campo não em uso
@author  Varejo
@version 	P12116
@since   	12/05/2017
@sample Lj901UsC6R()
/*/
//-------------------------------------------------------------------
Function Lj901UsC6R()
Local lUsado := .F.

	DbSelectArea( "SX3" )
	SX3->(DbSetOrder(2))	// X3_CAMPO

	If SX3->(DbSeek(PadR( "C6_RESERVA", Len(SX3->X3_CAMPO))))
		lUsado :=  X3Uso(SX3->X3_USADO)
	EndIf

Return lUsado

//--------------------------------------------------------
/*/{Protheus.doc} Lj901AUF
Recebe o Codigo do estado e retorna o Sigla do Estado

@param1 cUF		Codigo do Estado para retorno da Sigla
@author  Varejo
@version P11.8
@since   19/04/2017
@return	 Sigla do Estado
/*/
//--------------------------------------------------------
Function Lj901AUF(cUF)

Local cSiglaEst	:= ""	//Sigla do Estado Requisitado
Local nPos		:= 0	//posição de um determinado elemento no array

Default cUF		:= ""


If Len(aUF) == 0
	Aadd( aUF, {"RO","11"} )
	Aadd( aUF, {"AC","12"} )
	Aadd( aUF, {"AM","13"} )
	Aadd( aUF, {"RR","14"} )
	Aadd( aUF, {"PA","15"} )
	Aadd( aUF, {"AP","16"} )
	Aadd( aUF, {"TO","17"} )
	Aadd( aUF, {"MA","21"} )
	Aadd( aUF, {"PI","22"} )
	Aadd( aUF, {"CE","23"} )
	Aadd( aUF, {"RN","24"} )
	Aadd( aUF, {"PB","25"} )
	Aadd( aUF, {"PE","26"} )
	Aadd( aUF, {"AL","27"} )
	Aadd( aUF, {"MG","31"} )
	Aadd( aUF, {"ES","32"} )
	Aadd( aUF, {"RJ","33"} )
	Aadd( aUF, {"SP","35"} )
	Aadd( aUF, {"PR","41"} )
	Aadd( aUF, {"SC","42"} )
	Aadd( aUF, {"RS","43"} )
	Aadd( aUF, {"MS","50"} )
	Aadd( aUF, {"MT","51"} )
	Aadd( aUF, {"GO","52"} )
	Aadd( aUF, {"DF","53"} )
	Aadd( aUF, {"SE","28"} )
	Aadd( aUF, {"BA","29"} )
EndIf
nPos := aScan( aUF, {|x| x[2] == cUF} )
If nPos > 0
	cSiglaEst := aUF[nPos][1]
EndIf

Return(cSiglaEst)

//--------------------------------------------------------
/*/{Protheus.doc} Lj901ACnP
Envia a confirmação Unitária do Pedido de Venda
@param1 cOrderID Pedido CiaShop
@param2 oWS Objeto WS
@param3 cXMLPedUn - Lista do XML de Pedidos Enviados
@author  Varejo
@version P12.1.17
@since   15/08/2018
@return	lPedConf - Confirmação Enviada
/*/
//--------------------------------------------------------
Static Function  Lj901ACnP(cOrderID, oWS, cXMLPedUn)
Local cXML2 := "" //XML do Pedido
Local cXML := "" //XML enviado
Local lPedConf := .F.

cXML2 := '<receipt_result xmlns=""'+;
		 ' order_id="' + cOrderID + '"'+;
		 ' processed="1" />'


cXML := '<?xml version="1.0" encoding="utf-8" standalone="no" ?>'+;
		'<receipt_resultList xmlns="dsReceipt.xsd">'+;
		cXML2+;
		'</receipt_resultList>'



If (lPedConf := oWs:ConfirmaPedidos(, , @cXML))
	cXMLPedUn := DtoC(Date()) + " - " + Time() + "[" + cXML2 + "]" + CRLF
EndIf

Return lPedConf
