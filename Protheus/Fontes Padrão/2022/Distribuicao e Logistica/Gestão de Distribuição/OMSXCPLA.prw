#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "APWEBEX.CH"  
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "OMSXCPLA.CH"

Static cOmsCplRel := "VIAGEM_OMSXCPL"

//---------------------------------------------
/*/{Protheus.doc} OmsDeliveryUnit
	Classe auxiliar para o OMS, incluídos os campos de 
	peso e volume para as informações dos itens do pedido
@author  Jackson Patrick Werka
@since   13/07/2018
@version 1.0
/*/
//---------------------------------------------
CLASS OmsDeliveryUnit FROM DeliveryUnit
	DATA weight AS Float
	DATA volume AS Float
	DATA sequenceOnLoad AS String
	DATA arrivalTime AS String
	DATA departureTime AS String
	DATA startServiceTime AS String
	DATA endServiceTime AS String
	METHOD New() CONSTRUCTOR
ENDCLASS

METHOD New() CLASS OmsDeliveryUnit
	_Super:New()
Return 
//---------------------------------------------
/*/{Protheus.doc} OMSOrderBreakPart
	Classe para tratar as informações referentes a quebra do pedido no Cockpit Logístico
@author  amanda.vieira
@since   20/05/2019
@version 1.0
/*/
//---------------------------------------------
CLASS OMSOrderBreakPart
	DATA regionSourceId AS String
	DATA orderBreakPartId AS String
	DATA orderSourceId AS String
	DATA orderTypeSourceId AS String
	DATA orderItemSourceId AS String
	DATA loadId AS String
	DATA shipmentUnitId AS String
	DATA quantShipmUnits AS Float
	DATA quantProdUnits AS Float
	METHOD New() CONSTRUCTOR
ENDCLASS
//---------------------------------------------
/*/{Protheus.doc} New OMSOrderBreakPart
	Classe constrtura do objeto OMSOrderBreakPart
@author  amanda.vieira
@since   20/05/2019
@version 1.0
/*/
//---------------------------------------------
METHOD New() CLASS OMSOrderBreakPart
Return Self


Class OmsPontoEntrega
	Data nSequenciaEntrega As Numeric
	Data aChaveDK1 As Array
	Data cArrivalTime As Character
	Data cDepartureTime As Character
	Data dDataChegada As Data
	Data dDataSaida As Data
	Data cHoraChegada As String
	Data cHoraSaida As String
	METHOD New() CONSTRUCTOR
End Class

METHOD New() CLASS OmsPontoEntrega
Return Self



//-----------------------------------------------------------------------------
/*/{Protheus.doc} OmsRecTrip
	Função responsável por efetuar a leitura do XML e gerar as viagens com base nas
	filias de entrega de cada pedido de venda. Efetua a abertura do ambiente correto
	com base na empresa e filial recebida na localidade de carregamento do XML
@param   oXml, objeto, Objeto XML que representa o conteúdo da mensagem
@param   cConteudo, caracter, Texto com o conteúdo da mensagem xml recebida
@author  Jackson Patrick Werka
@since   13/07/2018
@version 1.0
/*/
//-----------------------------------------------------------------------------
Function OmsRecTrip(oXml,cConteudo)
// Não pode haver nenhum acesso a banco ou dicionário nas declarações de variáveis
// pois o ambiente ainda não está aberto, portanto não está logado em nenhuma empresa
Local nX         := 0
Local nY         := 0
Local nZ         := 0
Local nI         := 0
Local nMessageId := 0
Local nSbStop    := 0
Local nPosPed    := 0
Local nTamPedido := ""
Local nTamItem   := ""
Local nTamSeqInt := ""
Local oViagem    := Nil
Local oQuebra    := Nil
Local aViagens   := {}
Local aLoads     := {}
Local oStop      := Nil
Local aShipments := {}
Local aPedidos   := {}
Local aObjStops  := {}
Local aObjSbStop := {}
Local aCarSbStop := {}
Local aSubStops  := {}
Local oPedido    := Nil
Local aItensPed  := {}
Local aStops     := {}
Local aQuebras   := {}
Local cRpcEmp    := ""
Local cRpcFil    := ""
Local cRpcEmpAnt := ""
Local cEmpDef    := OsCplEmpDef()
Local aEmpFilAux := {}
Local aObjQuebra := {}
Local aPublTrip  := {}
Local lHasError  := .F.
local lRpcSetEnv := .F.
Local aObjViag   := Nil
Local aObjPeds   := Nil
Local aCarPeds   := Nil
Local oSubStop   := Nil
Local nSeqOrdSrc := 0
Local lDescarga  := .F.
Private XMLREC := oXml

	nMessageId := TMSXGetItens("publishReleasedTrip:messageId","N",,cConteudo)

	OsLogCPL("OMSXCPLA -> OmsRecTrip -> "+Replicate("-", 100),"INFO")
	OsLogCpl("OMSXCPLA -> OmsRecTrip -> EFETUAR A LEITURA DO XML E GERAR AS VIAGENS ","INFO")
	OsLogCPL("OMSXCPLA -> OmsRecTrip -> "+Replicate("-", 100),"INFO")
	OsLogCpl("OMSXCPLA -> OmsRecTrip -> Conteúdo da variável nMessageId:"+ cValtoChar(nMessageId),"INFO" )

	//If !LockByName("OMSXFUNW" + cValToChar(nMessageId) ,.F.,.F.)
	//	Conout("Log 17 - Falha LockByName")
	//	TmsLogMsg("WARN",'[' + cValToChar(ThreadId())  + '-OMSXFUNW] Mensagem ' + cValToChar(nMessageId) + " já está sendo processada.")
	//	Return .F.
	//EndIf

	// Grava o conteúdo do XML na pasta de Log - Caso ativado
	OMSXGRVXML("PublishReleasedTrip",@cConteudo,"DK0",cValToChar(nMessageId))

	OsLogCpl("OMSXCPLA -> OmsRecTrip -> XML Gravado na pasta com o conteúdo:"+ cValtoChar(cConteudo),"INFO" )

	aPublTrip := TMSXGetItens("publishReleasedTrip","A",,cConteudo)
		
	If !Empty(aPublTrip)
		OsLogCpl("OMSXCPLA -> OmsRecTrip -> Array aPublTrip preenchido","INFO")

		XMLREC  := aPublTrip[1]
		
		If ExisteNivel("orderBreakParts")
			OsLogCpl("OMSXCPLA -> OmsRecTrip -> Existe nível orderBreakParts ","INFO")

			aQuebras := TMSXGetItens("orderBreakParts:orderBreakPart","A")
			If !Empty(aQuebras)
				OsLogCpl("OMSXCPLA -> OmsRecTrip -> Array de quebras encontrado ","INFO")

				For nX := 1 To Len(aQuebras)
					oQuebra := OMSOrderBreakPart():New()
					XMLREC  := aQuebras[nX]
					
					oQuebra:regionSourceId := TMSXGetItens("regionSourceId")
					oQuebra:orderBreakPartId := TMSXGetItens("orderBreakPartId")
					oQuebra:orderSourceId := TMSXGetItens("orderSourceId")
					oQuebra:orderTypeSourceId := TMSXGetItens("orderTypeSourceId")
					oQuebra:orderItemSourceId := TMSXGetItens("orderItemSourceId")
					oQuebra:loadId := TMSXGetItens("loadId")
					oQuebra:shipmentUnitId := TMSXGetItens("shipmentUnitId")
					oQuebra:quantShipmUnits := TMSXGetItens("quantShipmUnits")
					oQuebra:quantProdUnits := TMSXGetItens("quantProdUnits")
				
					aAdd(aObjQuebra,oQuebra)
				Next nX
			EndIf
		EndIf

		XMLREC  := aPublTrip[1]

		// Busca as viagens recebidas no documento XML
		aViagens := TMSXGetItens("tripReleaseRequests:tripReleaseRequest","A")
		aObjViag := {} // Cria um array para gravar as viagens

		If Empty(aViagens)
			OsLogCpl("OMSXCPLA -> OmsRecTrip -> Array aViagens vazio ","INFO")
		EndIf

		For nX := 1 To Len(aViagens)
			
			oViagem := TripReleaseRequest():New()
			XMLREC  := aViagens[nX]
			oViagem:regionSourceId             := TMSXGetItens("regionSourceId")
			oViagem:basketSourceId             := TMSXGetItens("basketSourceId")
			oViagem:identifier                 := TMSXGetItens("identifier")
			oViagem:freightValue               := TMSXGetItens("freightValue","N")
			oViagem:carrierId                  := TMSXGetItens("carrierId")
			oViagem:vehicleId                  := TMSXGetItens("vehicleId")
			oViagem:vehicleDescription         := StrTrim(TMSXGetItens("vehicleDescription"),200)
			oViagem:truckLicensePlate          := TMSXGetItens("truckLicensePlate")
			oViagem:truckStateLicensePlate     := TMSXGetItens("truckLicensePlateState")
			oViagem:truckStatusId              := TMSXGetItens("truckStatusId")
			oViagem:truckDescriptionStatus     := StrTrim(TMSXGetItens("truckStatusDescription"),200)
			oViagem:truckAxlesQuantity         := TMSXGetItens("truckAxlesQuantity","N")
			oViagem:tripClassificationSourceId := StrTrim(TMSXGetItens("tripClassificationSourceId"),200)

			OsLogCpl("OMSXCPLA -> OmsRecTrip -> Identificador da viagem: "+ cValtoChar(oViagem:identifier),"INFO")
			
			// Busca todas as cargas da viagem
			aLoads := TMSXGetAll("loads:load")

			If Empty(aLoads)
				OsLogCpl("OMSXCPLA -> OmsRecTrip -> Array aLoads vazio ","INFO")
			EndIf

			For nY := 1 To Len(aLoads)
				XMLREC := aLoads[nY]
				aAdd(oViagem:loads, Load():New())
				oViagem:loads[nY]:ServiceTypeId := TMSXGetItens("serviceTypeId")
				oViagem:loads[nY]:loadid := TMSXGetItens("identifier")

				oViagem:loads[nY]:serviceDescriptionType := TMSXGetItens("serviceTypeDescription")
				oViagem:loads[nY]:loadMode := TMSXGetItens("loadMode")
				oViagem:loads[nY]:modal := TMSXGetItens("modal")
				oViagem:loads[nY]:distance := TMSXGetItens("distance")
				oViagem:loads[nY]:freight := TMSXGetItens("freight")

				// Busca todas as paradas da carga
				aStops := TMSXGetAll("stops:stop")

				If Empty(aStops)
					OsLogCpl("OMSXCPLA -> OmsRecTrip ->  Array aStops vazio ","INFO")
				EndIf

				For nZ := 1 To Len(aStops)
					lDescarga := .F.
					lCarrega  := .F.

					aObjSbStop := {}
					aCarSbStop := {}
					
					XMLREC := aStops[nZ]
					oStop := Stop():New()
					oStop:localitySourceId := TMSXGetItens("localitySourceId")
					oStop:transportZoneId  := TMSXGetItens("transportZoneId")
					oStop:sequenceOnLoad   := TMSXGetItens("sequenceOnLoad")

					oStop:identifier := TMSXGetItens("identifier")
					oStop:transportZoneDescription := TMSXGetItens("transportZoneDescription")

					aSubStops := TMSXGetAll("subStops:subStop")

					If Empty(aSubStops)
						OsLogCpl("OMSXCPLA -> OmsRecTrip -> Array aSubStops vazio ","INFO")
					EndIf
					aObjPeds := {} // Cria um array para gravar os pedidos
					aCarPeds := {}
					
					For nSbStop := 1 To Len(aSubStops)
						XMLREC := aSubStops[nSbStop]
						oSubStop := subStop():New()
						oSubStop:identifier := TMSXGetItens("identifier")
						oSubStop:arrivalTime := TMSXGetItens("arrivalTime")
						oSubStop:startServiceTime := TMSXGetItens("startServiceTime")
						oSubStop:endServiceTime := TMSXGetItens("endServiceTime")
						oSubStop:departureTime := TMSXGetItens("departureTime")
						oSubStop:dockId := TMSXGetItens("dockId")

						aShipments := TMSXGetAll("subStops:subStop:loadedShipmentUnits")
					
						If !Empty(aShipments)
							lCarrega := .T.
						Else
							aShipments := TMSXGetAll("subStops:subStop:unloadedShipmentUnits")
							lDescarga := .T.
						EndIf

						// Somente adiciona, caso tenha encontrado a TAG de carga para a localidade
						If Len(aShipments) > 0
							// Busca os pedidos da filial
							If lCarrega
							aPedidos := TMSXGetAll("subStops:subStop:loadedShipmentUnits:shipmentUnit")
							Else
								aPedidos := TMSXGetAll("subStops:subStop:unloadedShipmentUnits:shipmentUnit")
							EndIf

							If Empty(aPedidos)
								OsLogCpl("OMSXCPLA -> OmsRecTrip -> Array aPedidos vazio ","INFO")
							EndIf

							For nI := 1 To Len(aPedidos)

								oPedido := OmsDeliveryUnit():New()
								XMLREC  := aPedidos[nI]

								oPedido:weight := TMSXGetItens("weight","N")
								oPedido:volume := TMSXGetItens("volume","N")

								aItensPed := TMSXGetAll("deliveryUnitList:deliveryUnit")
								XMLREC    := aItensPed[1]
								oPedido:identifier          := TMSXGetItens("identifier")
								oPedido:viagem              := oViagem:identifier
								oPedido:regionalSourceId    := oViagem:regionSourceId
								oPedido:orderSourceId       := TMSXGetItens("orderSourceId")
								oPedido:orderTypeSourceId   := TMSXGetItens("orderTypeSourceId")
								oPedido:orderItemSourceId   := TMSXGetItens("orderItemSourceId")
								oPedido:productSourceId     := TMSXGetItens("productSourceId")
								oPedido:sequenceComposition := TMSXGetItens("sequenceComposition","N")
								oPedido:quantity            := TMSXGetItens("quantity","N")
								oPedido:price               := TMSXGetItens("price","N")
								oPedido:deliveryDate        := TMSXGetItens("deliveryDate")
								oPedido:integrationSource   := TMSXGetItens("integrationSource")
								
								//oPedido:sequenceOnLoad := oStop:sequenceOnLoad

								oPedido:arrivalTime := oSubStop:arrivalTime
								oPedido:departureTime := oSubStop:departureTime
								oPedido:startServiceTime := oSubStop:startServiceTime
								oPedido:endServiceTime := oSubStop:endServiceTime

								If lDescarga
								aAdd(aObjPeds,oPedido)
								Else
									aAdd(aCarPeds,oPedido)
								EndIf

								OsLogCpl("OMSXCPLA -> OmsRecTrip ->Identificador do pedido["+cValToChar(nI)+"]:"+oPedido:identifier,"INFO")

							Next nI
						EndIf
					Next nSbStop
					If lDescarga
						aAdd(oViagem:loads[nY]:stops, { oStop, aObjPeds } )
						aAdd(aObjSbStop,oSubStop)
						oStop:subStops := aObjSbStop
						aAdd(aObjStops,oStop)
					ElseIf lCarrega
						aAdd(oViagem:loads[nY]:stopsLoads, { oStop, aCarPeds } )
						aAdd(aCarSbStop,oSubStop)
						oStop:subStops := aCarSbStop
					EndIf
				
				Next nZ
			Next nY
			aAdd(aObjViag, oViagem) // Guarda o objeto de viagem para posterior uso
		Next nX
	EndIf

	If !Empty(aObjViag)
		
		OsLogCpl("OMSXCPLA -> OmsRecTrip -> OMSXCPLA- Array aObjViag preenchido ","INFO")
		// Processa as informações com base nos objetos existentes
		For nX := 1 To Len(aObjViag)
			oViagem := aObjViag[nX]
			nSeqOrdSrc := 0
			//Deve apagar DK1 já existentes, porque pode ocorrer de pedidos serem removidos da viagem no CPL
			lHasError := !(ApagarDK1(oViagem:identifier,cEmpDef))

			OsLogCpl("OMSXCPLA -> OmsRecTrip ->Verificar contéudo da lHasError: " +Iif(lHasError, "TRUE","FALSE"),"INFO")

			If !lHasError
				// A partir deste ponto deverá fazer a geração das carga por empresa/filial
				For nY := 1 To Len(oViagem:loads)
					For nZ := 1 To Len(oViagem:loads[nY]:stopsLoads)
						oStop := oViagem:loads[nY]:stopsLoads[nZ,1]
						// Código formado por: 'FIL' + '-' + [EMPRESA] + '-' + [FILIAL] 
						aEmpFilAux := StrTokArr(oStop:localitySourceId,'-')
						// Busca empresa e filial de acordo com a configuração de empresa
						// Faz o processo inverso do envio da localidade Filial
						If !Empty(cEmpDef) .And. aEmpFilAux[1] == "FIL"
							cRpcEmp := cEmpDef
							cRpcFil := aEmpFilAux[2]
						Else
							cRpcEmp := aEmpFilAux[2]
							cRpcFil := aEmpFilAux[3]
						EndIf

						OsLogCpl("OMSXCPLA -> OmsRecTrip ->Conteúdo da variável cRpcEmp " +cValToChar(cRpcEmp),"INFO")
						OsLogCpl("OMSXCPLA -> OmsRecTrip ->Conteúdo da variável cRpcFil " +cValToChar(cRpcFil),"INFO")
						OsLogCpl("OMSXCPLA -> OmsRecTrip ->Conteúdo da variável cRpcEmpAnt " +cValToChar(cRpcEmpAnt),"INFO")

						// Por uma questão de performance, só abre uma vez o ambiente por empresa
						
						If !(cRpcEmpAnt == cRpcEmp)
							// Fecha o ambiente atual
							If lRpcSetEnv
								OsLogCpl("OMSXCPLA -> OmsRecTrip ->iniciando a chamada da função RpcClearEnv","INFO")
								RpcClearEnv()
								lRpcSetEnv := .F.
							EndIf
							RpcSetType(3)
							// Abertura do ambiente em rotinas automáticas
							// RpcSetEnv( [ cRpcEmp ] [ cRpcFil ] [ cEnvUser ] [ cEnvPass ] [ cEnvMod ] [ cFunName ] [ aTables ] [ lShowFinal ] [ lAbend ] [ lOpenSX ] [ lConnect ] ) --> lRet
							OsLogCpl("OMSXCPLA -> OmsRecTrip ->iniciando a chamada da função RpcClearEnv","INFO")
							If !RpcSetEnv( cRpcEmp, cRpcFil, /*cEnvUser*/, /*cEnvPass*/, "OMS", "OmsRecTrip", {"DK0","DK1"}) 
								SetFaultTMS("Falha Ambiente","Não foi possível inicializar o ambiente Protheus para a empresa "+cRpcEmp+" e filial "+cRpcFil+".")
								lHasError := .T.
							
								OsLogCpl("OMSXCPLA -> OmsRecTrip ->Falha na abertura do ambiente ","INFO")
								
								Exit
							Else 
								OsLogCpl("OMSXCPLA -> OmsRecTrip ->Ambiente aberto com sucesso !!","INFO")
							EndIf
							lRpcSetEnv := .T.
							cRpcEmpAnt := cRpcEmp
						EndIf
						cFilAnt := cRpcFil

						//Realiza gravação das quebras na tabela DK3

						OsLogCpl("OMSXCPLA -> OmsRecTrip ->iniciando a chamada da função ProcQuebra","INFO")
						If (DK1->( ColumnPos( "DK1_QUEBID" ) ) > 0) .And. !ProcQuebra(aObjQuebra)
							OsLogCpl("OMSXCPLA -> OmsRecTrip ->Falha no processamento da quebra","INFO")
							lHasError := .T.
							Exit
						EndIf

						OsLogCpl("OMSXCPLA -> OmsRecTrip ->Iniciando a chamanda da função ProcViagem","INFO")
						Begin Transaction
							If !ProcViagem(nMessageId, oViagem, oViagem:loads,aObjStops,aObjSbStop,aObjQuebra,oViagem:loads[nY],cConteudo,@nSeqOrdSrc)
								lHasError := .T.
								DisarmTransaction()
							EndIf
						End Transaction
						If Select( cOmsCplRel ) > 0
							(cOmsCplRel)->(MsUnLock())
						EndIf
					Next nZ
					// Descarta a memória utilizada
					oViagem:loads[nY]:stops := {}
					aViagens   := {} 
					aLoads     := {}
					aShipments := {}
					aPedidos   := {}
					aItensPed  := {}
					aStops     := {}
					// Se houve erro não continua o processamento
					If lHasError
						Exit
					EndIf
				Next nY
			Else
				Exit
			EndIf
			oViagem:loads := {} // Descarta a memória utilizada
			FreeObj(oViagem) // Descarta a memória utilizada
			// Se houve erro não continua o processamento

		Next nX
		aObjViag := {} // Descarta a memória utilizada

	EndIf

	// Fecha o ambiente atual
	If lRpcSetEnv
		RpcClearEnv()
	EndIf

	UnLockByName("OMSXFUNW" + cValToChar(nMessageId) ,.F.,.F.)

Return !lHasError

//-----------------------------------------------------------------------------
/*/{Protheus.doc} ProcViagem
	Função responsável por efetuar a geração da viagem para a empresa/filial recebida no xml.
	Esta função efetua o tratamento para o caso do operador logístico gerando a viagem na 
	filial do operador logístico, quando estiver parametrizado. Para isso as tabelas de 
	carga e de viagem devem ter o mesmo tipo de compartilhamento no protheus.
@author  Jackson Patrick Werka
@since   13/07/2018
@version 1.0
/*/
//-----------------------------------------------------------------------------
Static Function ProcViagem(nMessageId, oViagem, aLoads, aStops, aSubStops, aQuebras, aLoad, cConteudo, nSeqOrdSrc)
Local oPedido    := Nil
Local oStop      := Nil
Local oLoad      := Nil
Local cFilPedVen := ""
Local cProduto   := ""
Local cData      := ""
Local cHora      := ""
Local cPedido    := ""
Local cSeqInt    := ""
Local cItemPed   := ""
Local cQuery     := ""
Local cAliasDK3  := ""
Local cSeqEnt    := ""
Local cQuebra    := ""
Local cQuebraAtu := ""
Local cLoadId    := aLoad:loadId
Local nTamItem   := TamSX3("C6_ITEM")[1]
Local nTamPedido := TamSx3("C6_NUM")[1]
Local nTamSeqInt := TamSx3("DK3_SEQUEN")[1]
Local nTamSeqEnt := Iif(DK1->( ColumnPos( "DK1_SEQENT" ) ) > 0, TamSX3("DK1_SEQENT")[1], 0)
Local nQtdPed    := 0
Local nPesoPrd   := 0
Local nI         := 0
Local nV         := 0
Local nL         := 0
Local nRecnoDK0  := 0
Local nRecnoDK1  := 0
Local nLenGrpCmp := 0
Local nPosQuebId := 0
Local nPosPed    := 0
Local lInclui    := .T.
Local lColPeso   := (DK1->( ColumnPos( "DK1_PESO" ) ) > 0)
Local lColSeqEnt := (DK1->( ColumnPos( "DK1_SEQENT" ) ) > 0)
Local lColQuebId := (DK1->( ColumnPos( "DK1_QUEBID" ) ) > 0)
Local lTimeStamp := (DK1->( ColumnPos( "DK1_CHEGAD" ) ) > 0)
Local lLibViagem := (SuperGetMV("MV_CPLLVA", .F.,"2") == "1")
Local lGeraCarga := (SuperGetMV("MV_CPLAUT", .F.,"2") == "1")
Local lIntPed2UM := (SuperGetMV("MV_CPLUMIT",.F.,"1") == "2") // Indica a UM do produto a ser considerada na integração com o CPL
Local lExistDK3  := TableInDic('DK3')
// Tratamentos para modo de operador logístico
Local lOperador  := (DAI->(ColumnPos("DAI_FILPV")) > 0 .And. IntDL() .And. SuperGetMV('MV_APDLOPE', .F., .F.))
Local cFilOpera  := SuperGetMV("MV_APDLFOP", .F., "")
Local cNS := ""
Local nPosOrdSrc := Len(cEmpAnt) + Len(cFilAnt) + 1 + nTamSeqInt + 1 + nTamPedido
Local nPosSeqInt := Len(cEmpAnt) + Len(cFilAnt) + 1
Local lColQuebOr := DK1->( ColumnPos( "DK1_QUEORI" ) ) > 0
Local lColSequen := DK1->( ColumnPos( "DK1_SEQUEN" ) ) > 0
Local lColDisDAK := DAK->( ColumnPos( "DAK_DISROT" ) ) > 0
Local lColDisDK0 := DK0->( ColumnPos( "DK0_DISROT" ) ) > 0
Local aOrigId    := {}
Local cOrdItemId := ""
Local aChegada   := {}
Local aSaida     := {}
Local cChaveDK1  := ""
Local oOmsPontoEntrega := Nil
Local aChavValor := {}
Local nPosChav := 0
Local nTotDist := 0

	OsLogCPL("OMSXCPLA -> ProcViagem -> "+Replicate("-", 100),"INFO")
	OsLogCpl("OMSXCPLA -> ProcViagem -> GERAÇÃO DA VIAGEM PARA A EMPRESA/FILIAL RECEBIDA NO XML","INFO")
	OsLogCPL("OMSXCPLA -> ProcViagem -> "+Replicate("-", 100),"INFO")
	OsLogCpl("OMSXCPLA -> ProcViagem -> Inicio ProcViagem.","INFO" )
	OsLogCpl("OMSXCPLA -> ProcViagem -> Contéudo do objeto oViagem:regionSourceId : "+cValToChar(oViagem:regionSourceId),"INFO" )
	OsLogCpl("OMSXCPLA -> ProcViagem -> Conteúdo do objeto oViagem:identifier : "+cValToChar(oViagem:identifier),"INFO" )

	If Empty(OsCplEmpDef()) .And. !OsHasEmpFil()
		nLenGrpCmp := Len(FWGrpCompany())
	EndIf
	
	nPosPed := nLenGrpCmp + Len(RTrim(xFilial("SC5"))) + nTamSeqInt + 3//Calcula a posição do pedido na string
	
	If lColQuebId
		nPosQuebId := nPosPed + nTamPedido
	EndIf

	// Tratamentos para modo de operador logístico
	If lOperador
		If !(xFilial("DAK") == xFilial("DK0"))
			SetFaultTMS("Parametrização Incorreta","OMS parametrizado para modo operador logístico (MV_APDLOPE), porém tabela de viagem não está compatilhada com a mesma configuração da tabela de carga.")
			OsLogCpl("OMSXCPLA -> ProcViagem -> Parametrização Incorreta DAK X DK0","ERROR" )
			Return .F.
		EndIf
		If FWModeAccess("DK0",3) == 'E' .And. Empty(cFilOpera)
			SetFaultTMS("Parametrização Incorreta","OMS parametrizado para modo operador logístico (MV_APDLOPE) com tabela de carga exclusiva for filial, porém não foi informado a filial do operador logístico. (MV_APDLFOP)")
			OsLogCpl("OMSXCPLA -> ProcViagem -> Parametrização Incorreta DAK X cFilOpera","ERROR" )
			Return .F.
		EndIf
		// Processa as informações como se fosse na filial do operador logístico
		If !Empty(cFilOpera)
			cFilAnt := cFilOpera
		EndIf
	EndIf

	If lColDisDAK
		For nL := 1 To Len(aLoads)
			nTotDist += Round( Val(aLoads[nL]:distance), TamSX3("DAK_DISROT")[2] )
		Next nL
	EndIf

	If DK0->(dbSeek(xFilial("DK0")+;
				PadR(oViagem:regionSourceId,Len(DK0->DK0_REGID))+;
				PadR(oViagem:identifier,Len(DK0->DK0_VIAGID))))
		Reclock("DK0",.F.)
		lInclui := .F.
		OsLogCpl("OMSXCPLA -> ProcViagem -> Contéudo da variavel lInclui igual a FALSE","INFO" )
	Else
		Reclock("DK0",.T.) 
		lInclui := .T.
		OsLogCpl("OMSXCPLA -> ProcViagem -> Contéudo da variavel lInclui igual a TRUE","INFO" )
	EndIf
	DK0->DK0_FILIAL  := xFilial("DK0")
	DK0->DK0_IDCESTA := oViagem:basketSourceId
	DK0->DK0_REGID   := oViagem:regionSourceId
	DK0->DK0_VIAGID  := oViagem:identifier
	DK0->DK0_TRANSP  := oViagem:carrierId
	DK0->DK0_TIPVEI  := oViagem:vehicleId
	DK0->DK0_PLACA   := oViagem:truckLicensePlate
	DK0->DK0_ESTPLA  := oViagem:truckStateLicensePlate
	DK0->DK0_QTDEIX  := oViagem:truckAxlesQuantity
	DK0->DK0_DATINT  := Date()
	DK0->DK0_HORINT  := Time()
	If lInclui
		DK0->DK0_CARGER  := "2"
		DK0->DK0_SITINT  := "0"
	EndIf
	DK0->DK0_CPLMSG  := nMessageId
	If lColDisDK0
		DK0->DK0_DISROT  := Round( nTotDist, TamSX3("DK0_DISROT")[2] ) 
	EndIf
	DK0->(MsUnLock())
	nRecnoDK0 := DK0->(Recno())

	OsLogCpl("OMSXCPLA -> ProcViagem -> Inserido Recno DK0 :"+cValToChar(nRecnoDK0),"INFO" )

	RelOmsCpl(FWGrpCompany(),xFilial("DK0"),DK0->DK0_CPLMSG,DK0->DK0_VIAGID,nRecnoDK0)
	
	If lExistDK3
		DK3->(DbSetOrder(1)) //DK3_FILIAL+DK3_PEDIDO+DK3_ITEMPE+DK3_PRODUT+DK3_SEQUEN
	EndIf
	
	For nL := 1 To Len(aLoads)
		oLoad := aLoads[nL]

		For nV := 1 To Len(oLoad:stops)
			aPedidos := oLoad:stops[nV,2]

			For nI := 1 To Len(aPedidos)
				oPedido := aPedidos[nI]

				/*If nSeqInc = 0
					OsLogCpl("OMSXCPLA -> ProcViagem -> Parametro MV_OMSENTR nao definido.","INFO" )
				EndIf variavel nao usada */ 

				cFilPedVen := SubStr(oPedido:orderSourceId,nLenGrpCmp+1,Len(RTrim(xFilial("SC5"))))
				cItemPed   := Right(oPedido:orderItemSourceId,nTamItem)
				cSeqEnt    := ""
				cQuebra    := ""
				
				//Busca id da quebra do pedido
				If lColQuebId .And. !Empty(aQuebras)
					aEval(aQuebras,{|oQuebra| cQuebra := Iif(Empty(cQuebra) .And. (oQuebra:orderItemSourceId == oPedido:orderItemSourceId) .And. (oQuebra:loadId == cLoadId),oQuebra:orderBreakPartId,cQuebra)})
				EndIf
				
				
				//Verifica se o pedido já é resultado de uma quebra
				If lColQuebId
					cQuebraAtu := Iif(!Empty(cQuebra),cQuebra,SubStr(oPedido:orderSourceId,nPosQuebId+1))
				EndIf
				
				// Buscando o código do produto conforme gravado no Protheus para identificar a necessidade e,
				// se for o caso, efetuar o cálculo de quantidade conforme UM informada no parâmetro MV_CPLUMIT
				If Empty(OsFilial("SB1",cFilPedVen)) .And. nLenGrpCmp <= 0
					cProduto := oPedido:productSourceId
				Else
					cProduto := SubStr(oPedido:productSourceId,1,Len(oPedido:productSourceId)-(nLenGrpCmp+Len(RTrim(OsFilial("SB1",cFilPedVen)))+1))
				EndIf
				// Realiza cálculo da quantidade de acordo com a unidade de medida enviada
				If lIntPed2UM .And. Posicione("SB1",1,OsFilial("SB1",cFilPedVen)+cProduto,"B1_CONV") > 0
					nQtdPed := ConvUm(cProduto,0,oPedido:quantity,1)
				Else
					nQtdPed := oPedido:quantity
				EndIf
				nPesoPrd := oPedido:weight
				// Verifica se a 1ª UM do produto possui fator de conversão
				// caso possua aplica o meSM0 sobre o peso do produto
				If lColPeso .And. TableInDic("DK2", .F.)
					If DK2->(dbSeek(xFilial("DK2")+Posicione("SB1",1,OsFilial("SB1",cFilPedVen)+cProduto,"B1_UM")))
						nPesoPrd := nPesoPrd / DK2->DK2_PESOKG
					EndIf
				EndIf

				cData := SubStr(oPedido:deliveryDate,9,2)+'/'+;
							SubStr(oPedido:deliveryDate,6,2)+'/'+;
							SubStr(oPedido:deliveryDate,1,4)

				cHora := SubStr(oPedido:deliveryDate,12,8)

				If lExistDK3
					OsLogCpl("OMSXCPLA -> lExistDK3 -> Encontrou Registro na DK3","INFO" )

					cPedido := SubStr(oPedido:orderSourceId,nPosped,nTamPedido)
					If OMSCPLDK3(cPedido)
						cSeqInt  := SubStr(oPedido:orderSourceId,nLenGrpCmp+Len(cFilPedVen)+2,nTamSeqInt)
						cProduto := PadR(cProduto,TamSx3("C6_PRODUTO")[1])
						cPedido  := PadR(cPedido,TamSx3("C6_NUM")[1])
						cQuery := " SELECT DK3.R_E_C_N_O_ RECNODK3"
						cQuery +=   " FROM "+RetSqlName('DK3')+" DK3"
						cQuery +=  " WHERE DK3.DK3_FILIAL = '"+cFilPedVen+"'"
						cQuery +=    " AND DK3.DK3_PEDIDO = '"+cPedido+"'"
						cQuery +=    " AND DK3.DK3_ITEMPE = '"+cItemPed+"'"
						cQuery +=    " AND DK3.DK3_PRODUT = '"+cProduto+"'"
						cQuery +=    " AND DK3.DK3_SEQUEN = '"+cSeqInt+"'"
						If lColQuebId .And. !Empty(cQuebraAtu)
							cQuery +=    " AND DK3.DK3_QUEBID = '"+cQuebraAtu+"'"
						EndIf
						cQuery +=    " AND DK3.DK3_STATUS <> '2'"
						cQuery +=    " AND DK3.D_E_L_E_T_ = ' '"
						cQuery := ChangeQuery(cQuery)
						cAliasDK3 := GetNextAlias()
						dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasDK3, .T., .T. )
						OsLogCPL("OMSXCPLA -> ProcViagem -> Conteudo da query cQuery - DK3: " + cValToChar(cQuery),"INFO")
						If (cAliasDK3)->(!EoF())
							DK3->(dbGoTo((cAliasDK3)->RECNODK3))
							Reclock("DK3",.F.)
							DK3->DK3_VIAGID  := oPedido:viagem
							DK3->( MsUnLock() )
						EndIf
						(cAliasDK3)->(DbCloseArea())
					Else
						cSeqInt := ""
					EndIf
				Else
					cPedido  := SubStr(oPedido:orderSourceId,nLenGrpCmp+Len(cFilPedVen)+2)
				EndIf
				OsLogCPL("OMSXCPLA -> ProcViagem -> Conteudo da variavel cPedido: " + cValToChar(cPedido),"INFO")
				
				If DK1->(dbSeek(xFilial("DK1")+;
							PadR(oPedido:regionalSourceId,Len(DK1->DK1_REGID))+;
							PadR(oPedido:viagem,Len(DK1->DK1_VIAGID))+;
							PadR(oPedido:identifier,Len(DK1->DK1_UNIDID))))
					Reclock("DK1",.F.)
				Else
					Reclock("DK1",.T.)
				EndIf
				DK1->DK1_FILIAL  := xFilial("DK1")
				DK1->DK1_FILPED  := cFilPedVen
				DK1->DK1_PEDIDO  := cPedido
				DK1->DK1_ITEMPE  := cItemPed
				DK1->DK1_UNIDID  := oPedido:identifier
				DK1->DK1_REGID   := oPedido:regionalSourceId
				DK1->DK1_VIAGID  := oPedido:viagem
				DK1->DK1_PEDROT  := oPedido:orderSourceId
				DK1->DK1_PRODUT  := cProduto
				DK1->DK1_QTD     := nQtdPed
				If lColPeso
					DK1->DK1_PESO   := nPesoPrd
					DK1->DK1_VOLUME := oPedido:volume
				EndIf
				DK1->DK1_PRECO   := oPedido:price
				DK1->DK1_DATENT  := cData +' '+ cHora
				DK1->DK1_ORIGEM  := oPedido:integrationSource
				DK1->DK1_ORITID  := oPedido:orderItemSourceId

				/* O atributo do xml sequenceOnLoad é a sequencia da parada para a Neolog.
				No xml, a parada 1 é carregamento dos pedidos na filial. 
				Sendo as próximas paradas os pontos de entregas/clientes.
				Para o OMS, este atributo serve para gerar a sequencia de entrega na DAI e SC9.
				Mas como a DK1 e DAI trabalham diferente é necessário realizar tratamento em fonte.
				A DAI agrupa pedido e cliente como ponto de entrega. A DK1 possui todos os itens separados.
				Com isso é necessário gerar o campo DK1_SEQENT corretamente para gerar a DAI.
				A chave da tabela DAI é DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO+DAI_CLIENT+DAI_LOJA
				O array abaixo mantém o pedido/cliente como chave e o sequencial (gerado em fonte) como valor(DK1_SEQENT).
				Se o pedido não está no array é gerado um sequencial novo, caso contrário o sequencial é recuperado.
				A funcao SubStr - obtem o conteudo que define uma sequencia de ponto de entrega. Mas a sequencia de integracao
				precisa ser removida para não gerar dois sequenciais diferentes para o mesmo ponto de entrega.
				A funcao Stuff - descarta as diferentes sequencias de integracao de um mesmo ponto de entrega
				carlos.augusto 07/06/2022 */

				OsLogCPL("OMSXCPLA -> ProcViagem -> Conteudo das variaveis lColSeqEnt (Existe campo DK1_SEQENT): " + cValToChar(lColSeqEnt)+;
				" - lColQuebId (Existe campo DK1_QUEBID): " + cValToChar(lColQuebId)+;
				" - lColQuebOr (Existe campo DK1_QUEORI): " + cValToChar(lColQuebOr)+;
				" - lColSequen (Existe campo DK1_SEQUEN): " + cValToChar(lColQuebOr),"INFO")

				If lColSeqEnt

					OsLogCpl("OMSXCPLA -> ProcViagem -> Iniciando processo de novos tratamentos TOL x OMS para o pontos de entrega.","INFO" )

					cChaveDK1 	:= DK1->DK1_FILIAL+DK1->DK1_REGID+DK1->DK1_VIAGID+DK1->DK1_UNIDID+DK1->DK1_ITEMPE
					aChegada  	:= FWDateTimeToLocal(oPedido:arrivalTime) //Data de chegada da integracao/xml
					aSaida 	  	:= FWDateTimeToLocal(oPedido:departureTime) //Data de saida da integracao/xml

					//Chave unica do ponto de entrega para o OMS
					//Esta definicao é a mais importante para unificar os pontos de entrega entre TOL e OMS
					cOrdItemId 	:= Stuff(SubStr(oPedido:orderItemSourceId,1,nPosOrdSrc) , nPosSeqInt, nTamSeqInt+1, "")

					If (nPosChav := aScan(aChavValor, {|x| x[1] == cOrdItemId})) <= 0 //O ponto de entrega já existe no array?

						nSeqOrdSrc += 1

						oOmsPontoEntrega := OmsPontoEntrega():New()
						oOmsPontoEntrega:nSequenciaEntrega := nSeqOrdSrc
						oOmsPontoEntrega:aChaveDK1 := {cChaveDK1}
						oOmsPontoEntrega:cArrivalTime := oPedido:arrivalTime
						oOmsPontoEntrega:cDepartureTime := oPedido:departureTime
						oOmsPontoEntrega:dDataChegada := aChegada[1]
						oOmsPontoEntrega:dDataSaida := aSaida[1]
						oOmsPontoEntrega:cHoraChegada := aChegada[2]
						oOmsPontoEntrega:cHoraSaida := aSaida[2]
						Aadd(aChavValor, {cOrdItemId, oOmsPontoEntrega})
					Else
						//Usa a mesma a sequencia e atualiza os dados do ponto de entrega com a primeira chegada e a ultima saida.
						oOmsPontoEntrega :=  OMSPtEntrg(cChaveDK1, @nSeqOrdSrc, aChavValor[nPosChav], aChegada, aSaida, oPedido:arrivalTime, oPedido:departureTime)
						If !Empty(oOmsPontoEntrega)
							aChavValor[nPosChav] := {cOrdItemId, oOmsPontoEntrega}
						Else
							/* Precisamos guardar a chave pq se nas proximas iteracoes trocar o horario, devera trocar desta DK1 tambem */
							oOmsPontoEntrega := aChavValor[nPosChav][2]
							aChvDK1 := oOmsPontoEntrega:aChaveDK1
							Aadd(aChvDK1, cChaveDK1)
							oOmsPontoEntrega:aChaveDK1 := aChvDK1
							aChavValor[nPosChav] := {cOrdItemId, oOmsPontoEntrega}
						EndIf
					EndIf
					DK1->DK1_SEQENT  := PadL(CValToChar(nSeqOrdSrc),nTamSeqEnt,"0")

					OsLogCPL("OMSXCPLA -> ProcViagem -> Sequencia de entrega para o cOrdItemId " + cValToChar(cOrdItemId) +"/<orderItemSourceId>: "+oPedido:orderItemSourceId+;
							" é :" + cValToChar(DK1->DK1_SEQENT),"INFO")
					
					OsLogCpl("OMSXCPLA -> ProcViagem -> Finalizando processo de novos tratamentos TOL x OMS para o pontos de entrega.","INFO" )

				EndIf

				If lColQuebId .And. !Empty(cQuebra)
					DK1->DK1_QUEBID := cQuebra
				EndIf

				/* Agora vamos falar dos novos campos DK1_QUEORI e DK1_SEQUEN
					DK1_QUEORI - mantem o codigo da quebra para relacionamentos posteriores.
					DK1_SEQUEN - mantem o codigo da sequencia de integracao para relacionamentos posteriores. */
				If lColQuebId .And. lColQuebOr .And. lColSequen
					aOrigId := StrTokArr( oPedido:orderItemSourceId, "-" )
					If !Empty(cQuebra) //Se é quebra, salvo a mesma
						DK1->DK1_QUEORI := cQuebra
					Else
						If Len(aOrigId) = 5
							DK1->DK1_QUEORI := aOrigId[4]//Se nao é, preciso guardar para relacionar com DK3 posteriormente
						EndIf
					EndIf
					DK1->DK1_SEQUEN := aOrigId[2]
					OsLogCPL("OMSXCPLA -> ProcViagem -> quebra origem " + cValToChar(DK1->DK1_QUEORI) +;
					" Sequencia de integracao: " + cValToChar(DK1->DK1_SEQUEN),"INFO")
				EndIf

				If lTimeStamp
					DK1->DK1_CHEGAD := oPedido:arrivalTime
					DK1->DK1_TSAIDA := oPedido:departureTime
					DK1->DK1_INIDES := oPedido:startServiceTime
					DK1->DK1_FIMDES := oPedido:endServiceTime
				EndIf
				DK1->(MsUnLock())
				nRecnoDK1 := DK1->(Recno())

				OsLogCpl("OMSXCPLA -> ProcViagem -> Inserido Recno DK1 :"+cValToChar(nRecnoDK1),"INFO" )

				FreeObj(oPedido) // Descarta a memória utilizada

			Next nI
		Next nV
	Next nL

	//Funcao para atualizar a chave DK1 (DK1_CHEGAD e DK1_TSAIDA)
	If lColQuebId .And. lColQuebOr .And. lColSequen
		OMSDK1Ent(aChavValor,nRecnoDK1)
	EndIf

	If ExistBlock('OMSCPLAV')
		OsLogCpl("OMSXCPLA -> ProcViagem -> Executado o ponto de entrada OMSCPLAV","INFO" )
		cNS := TMSXGetChild("publishReleasedTrip", cConteudo, .T.)
		ExecBlock('OMSCPLAV',.F.,.F.,{oViagem,aStops,aSubStops,cConteudo, cNS})
	EndIf

	aPedidos := {} // Descarta a memória utilizada

	dbSelectArea("DK0") // Para forçar esta ser a tabela ativa
	DK0->(dbGoTo(nRecnoDK0))
	If lLibViagem
		//Realiza a liberação da viagem 
		OsLogCpl("OMSXCPLA -> ProcViagem -> Chamada a liberação da viagem","INFO" )
		OMSXCPL7L()
	Else
		If DK0->DK0_SITINT <> "1"
			Reclock("DK0",.F.)
			DK0->DK0_SITINT  := "1"
			DK0->( MsUnLock() )
		EndIf
	EndIf
	//Realiza a montagem de carga
	If lGeraCarga 
		If DK0->DK0_SITINT == "2" .And. DK0->DK0_CARGER <> "1" 
			OsLogCpl("OMSXCPLA -> ProcViagem ->Chamada a geração da carga","INFO" )
			OMSXCPL7G()
		EndIf
	EndIf
Return .T.

//-----------------------------------------------------------------------------
/*/{Protheus.doc} OmsTabRelCria
	Cria a tabela de controle dos relacionamentos e abre a mesma
	Nesta tabela ficarão gravadas as empresas e filiais na qual a viagem foi integrada
@author  Jackson Patrick Werka
@since   23/07/2018
@version 1.0
/*/
//-----------------------------------------------------------------------------
Function OmsTabRelCria()
Local aEstrutura := {}
Local nTamSX3    := {}
	
	OsLogCPL("OMSXCPLA -> OmsTabRelCria ->"+Replicate("-", 100),"INFO")
	OsLogCpl("OMSXCPLA -> OmsTabRelCria ->INICIO DA FUNÇÃO VALIDA TABELA "+cValToChar(Trim(cOmsCplRel))+".","INFO")
	OsLogCPL("OMSXCPLA -> OmsTabRelCria -> "+Replicate("-", 100),"INFO")

	If !TcCanOpen(cOmsCplRel)
		OsLogCpl("OMSXCPLA -> OmsTabRelCria -> Tabela "+cValToChar(Trim(cOmsCplRel))+" não encontrada.","INFO" )
		nTamSX3 := {Len(FWGrpCompany()),0}
		Aadd(aEstrutura,{"EMPRESA", "C", nTamSX3[1], nTamSX3[2]})
		nTamSX3 := {FWSizeFilial(), 0}
		Aadd(aEstrutura,{"FILIAL", "C", nTamSX3[1], nTamSX3[2]})
		nTamSX3 := TamSx3("DK0_CPLMSG")
		Aadd(aEstrutura,{"CPLMSGID", "N", nTamSX3[1], nTamSX3[2]})
		nTamSX3 := TamSx3("DK0_VIAGID")
		Aadd(aEstrutura,{"VIAGEM", "C", nTamSX3[1], nTamSX3[2]})
		Aadd(aEstrutura,{"RECNOVIAG", "N", 10, 0})
		Aadd(aEstrutura,{"DATAINT","C",8,0}) //-- 20140101
		Aadd(aEstrutura,{"HORAINT","C",8,0}) //-- 12:00:00

		DBCreate(cOmsCplRel,aEstrutura,"TOPCONN")
		OsLogCpl("OMSXCPLA -> OmsTabRelCria -> Tabela "+cValToChar(Trim(cOmsCplRel))+" criada.","INFO" )
	Else
		OsLogCpl("OMSXCPLA -> OmsTabRelCria -> Tabela "+cValToChar(Trim(cOmsCplRel))+" ja existente.","INFO" )
	EndIf
	// DBUseArea( [ lNewArea ], [ cDriver ], < cFile >, < cAlias >, [ lShared ], [ lReadOnly ] )
	DbUseArea(.T.,'TOPCONN',cOmsCplRel,cOmsCplRel,.T.,.F.)
	TCSetField(cOmsCplRel,'DATAINT','D',8,0)	
	TCSetField(cOmsCplRel,'CPLMSGID','N',10,0)
	TCSetField(cOmsCplRel,'RECNOVIAG','N',10,0)
	// Cria o arquivo de indice para a tabela
	If !TcCanOpen(cOmsCplRel,cOmsCplRel+"1")
		(cOmsCplRel)->(DBCreateIndex(cOmsCplRel +"1","EMPRESA+FILIAL+VIAGEM",{||EMPRESA+FILIAL+VIAGEM},.F.))
		OsLogCpl("OMSXCPLA -> OmsTabRelCria -> Tabela "+cValToChar(Trim(cOmsCplRel))+" - Índice 1 criado.","INFO" )
	Else
		OsLogCpl("OMSXCPLA -> OmsTabRelCria -> Tabela "+cValToChar(Trim(cOmsCplRel))+" - Índice 1 ja existente.","INFO" )
	EndIf
	If !TcCanOpen(cOmsCplRel,cOmsCplRel+"2")
		(cOmsCplRel)->(DBCreateIndex(cOmsCplRel +"2","VIAGEM",{||VIAGEM},.F.))
		OsLogCpl("OMSXCPLA -> OmsTabRelCria -> Tabela "+cValToChar(Trim(cOmsCplRel))+" - Índice 2 criado.","INFO" )
	Else
		OsLogCpl("OMSXCPLA -> OmsTabRelCria -> Tabela "+cValToChar(Trim(cOmsCplRel))+" - Índice 2 ja existente.","INFO" )
	EndIf
	(cOmsCplRel)->(DbSetIndex(cOmsCplRel +"1"))
	(cOmsCplRel)->(DbSetOrder(1))
	OsLogCpl("OMSXCPLA -> OmsTabRelCria -> Termino da função","INFO" )

Return .T.

//-----------------------------------------------------------------------------
/*/{Protheus.doc} RelOmsCpl
	Grava o relacionamento da empresa e filial com a viagem recebida do CPL
@author  Jackson Patrick Werka
@since   23/07/2018
@version 1.0
/*/
//-----------------------------------------------------------------------------
Static Function RelOmsCpl(cEmpAux,cFilAux,nCplMsg,cViagem,nRecnoDK0)

	If Select( cOmsCplRel ) <= 0
		OsLogCpl("OMSXCPLA -> RelOmsCpl -> Tabela "+cValToChar(Trim(cOmsCplRel))+" não existe. Criação iniciada.","INFO" )
		If !OmsTabRelCria()
			OsLogCpl("OMSXCPLA -> RelOmsCpl -> Tabela "+cValToChar(Trim(cOmsCplRel))+" não foi criada.","INFO" )
			Return .F.
		Else
			OsLogCpl("OMSXCPLA -> RelOmsCpl -> Tabela "+cValToChar(Trim(cOmsCplRel))+" criada.","INFO" )
		EndIf
	EndIf

	If (cOmsCplRel)->( DbSeek(cEmpAux+cFilAux+cViagem,.F.) )
		OsLogCpl("OMSXCPLA -> RelOmsCpl -> Registro existe na tabela "+cValToChar(Trim(cOmsCplRel))+". Update iniciado.","INFO" )
		Reclock(cOmsCplRel,.F.)
		
		(cOmsCplRel)->CPLMSGID  := nCplMsg
		(cOmsCplRel)->RECNOVIAG := nRecnoDK0
		(cOmsCplRel)->DATAINT   := Date()
		(cOmsCplRel)->HORAINT   := Time()

		OsLogCpl("OMSXCPLA -> RelOmsCpl -> Registro existe na tabela "+cValToChar(Trim(cOmsCplRel))+". Update finalizado.","INFO" )
	Else
		OsLogCpl("OMSXCPLA -> RelOmsCpl -> Registro não existe na tabela "+cValToChar(Trim(cOmsCplRel))+". Inclusão iniciada.","INFO" )
		(cOmsCplRel)->( DBAppend( .F. ) )
		(cOmsCplRel)->EMPRESA   := cEmpAux
		(cOmsCplRel)->FILIAL    := cFilAux
		(cOmsCplRel)->VIAGEM    := cViagem
		(cOmsCplRel)->CPLMSGID  := nCplMsg
		(cOmsCplRel)->RECNOVIAG := nRecnoDK0
		(cOmsCplRel)->DATAINT   := Date()
		(cOmsCplRel)->HORAINT   := Time()
		OsLogCpl("OMSXCPLA -> RelOmsCpl -> Registro não existe na tabela "+cValToChar(Trim(cOmsCplRel))+". Inclusão finalizada.","INFO" )
	EndIf
	(cOmsCplRel)->( DBCommit() )
	OsLogCpl("OMSXCPLA -> RelOmsCpl -> Processo finalizado.","INFO" )

Return .T.
/*/{Protheus.doc} ProcQuebra
// Função responsável por processar a quebra da sequência de integração (DK3)
@author amanda.vieira
@since 06/06/2019
@version 1.0
@param aQuebras, array, array contendo os objetos da quebra do Cockpit Logístico
@type function
/*/
Static Function ProcQuebra(aQuebras)
Local lRet       := .T.
Local nX         := 0
Local nLenGrpCmp := 0
Local nPosPed    := 0
Local nPosQuebId := 0
Local cFilPedVen := ""
Local cPedido    := ""
Local cItemPed   := ""
Local cSeqInt    := ""
Local cQuebraId  := ""
Local cEmpresa   := ""
Local cQuebIdAnt := ""
Local nTamPedido := TamSx3("C6_NUM")[1]
Local nTamItem   := TamSX3("C6_ITEM")[1]
Local nTamSeqInt := TamSx3("DK3_SEQUEN")[1]


	If Empty(OsCplEmpDef()) .And. !OsHasEmpFil()
		nLenGrpCmp := Len(FWGrpCompany())
	EndIf

	//Trata quebras recebidas
	For nX := 1 To Len(aQuebras)
		
		//Verifica se a empresa e filial da quebra é a empresa que está sendo processada
		cEmpresa := Substr(aQuebras[nX]:orderSourceId,1,nLenGrpCmp)
		cFilPedVen := SubStr(aQuebras[nX]:orderSourceId,nLenGrpCmp+1,Len(RTrim(xFilial("SC5"))))
		
		If ((cEmpresa == cEmpAnt) .And. (cFilPedVen == cFilAnt))
			nPosPed    := nLenGrpCmp + Len(RTrim(xFilial("SC5"))) + nTamSeqInt + 2 //Calcula a posição do pedido na string
			nPosQuebId := nPosPed + nTamPedido
			cPedido    := SubStr(aQuebras[nX]:orderSourceId,nPosPed+1,nTamPedido)
			cItemPed   := Right(aQuebras[nX]:orderItemSourceId,nTamItem)
			cSeqInt    := SubStr(aQuebras[nX]:orderSourceId,nLenGrpCmp+Len(cFilPedVen)+2,nTamSeqInt)
			cQuebraId  := aQuebras[nX]:orderBreakPartId
			cQuebIdAnt := SubStr(aQuebras[nX]:orderSourceId,nPosQuebId+2)
			nQtdQuebra := Val(aQuebras[nX]:quantProdUnits)
			OmsDivDK3(cFilPedVen,cPedido,cItemPed,cSeqInt,cQuebraId,nQtdQuebra,cQuebIdAnt)
		EndIf
	Next nX

Return lRet
/*/{Protheus.doc} OmsDivDK3
// Função responsável realizar a divisão da sequência de integração (DK3) conforme a quantidade recebida no XML
@author amanda.vieira
@since 06/06/2019
@version 1.0
@param cFilPedVen, caracter, filial do pedido de venda
@param cPedido, caracter, número do pedido de venda
@param cItemPed, caracter, item do pedido de venda
@param cSeqInt, caracter, sequência de integração
@param cQuebraId, caracter, id da quebra
@param nQtdQuebra, numérico, quantidade da quebra
@param cQuebraId, caracter, id da quebra anterior
@type function
/*/
Static Function OmsDivDK3(cFilPedVen,cPedido,cItemPed,cSeqInt,cQuebraId,nQtdQuebra,cQuebIdAnt)
Local lRet       := .T.
Local lProcDiv   := .T.
Local cSpaceQueb := Iif((DK1->( ColumnPos( "DK3_QUEBID" ) ) > 0), Space(TamSx3("DK3_QUEBID")[1])," ")
Local cAliasDK3  := ""
Local cExpQuebId := Iif(!Empty(cQuebIdAnt),cQuebIdAnt,cSpaceQueb)
Local aCopyDK3   := {}
Local nX         := 0

	cAliasDK3 := GetNextAlias()
	BeginSql Alias cAliasDK3
		SELECT R_E_C_N_O_ RECNODK3
		  FROM %Table:DK3% DK3
		 WHERE DK3.DK3_FILIAL = %Exp:cFilPedVen%
		   AND DK3.DK3_PEDIDO = %Exp:cPedido%
		   AND DK3.DK3_ITEMPE = %Exp:cItemPed%
		   AND DK3.DK3_SEQUEN = %Exp:cSeqInt%
		   AND DK3.DK3_QUEBID = %Exp:cQuebraId%
		   AND DK3.%NotDel%
	EndSql
	If (cAliasDK3)->(!EoF())
		lProcDiv := .F. //Se já existir a quebra, não realiza novamente
	EndIf
	(cAliasDK3)->(DbCloseArea())
	
	If lProcDiv
		cAliasDK3 := GetNextAlias()
		BeginSql Alias cAliasDK3
			SELECT DK3.R_E_C_N_O_ RECNODK3,
				   SB5.B5_TIPUNIT
			  FROM %Table:DK3% DK3
			  LEFT JOIN %Table:SB5% SB5
			   ON SB5.B5_FILIAL  = %xFilial:SB5%
			   AND SB5.B5_COD    = DK3.DK3_PRODUT
			   AND SB5.%NotDel%
			 WHERE DK3.DK3_FILIAL = %Exp:cFilPedVen%
			   AND DK3.DK3_PEDIDO = %Exp:cPedido%
			   AND DK3.DK3_ITEMPE = %Exp:cItemPed%
			   AND DK3.DK3_SEQUEN = %Exp:cSeqInt%
			   AND DK3.DK3_QUEBID = %Exp:cExpQuebId%
			   AND DK3.%NotDel%
		EndSql
	
		If (cAliasDK3)->(!EoF())
			DK3->(DbGoTo((cAliasDK3)->RECNODK3))
			If !((cAliasDK3)->B5_TIPUNIT == "0") .And. DK3->DK3_QTDINT > nQtdQuebra
	
				For nX := 1 To DK3->(FCount())
					Aadd(aCopyDK3, DK3->(FieldGet(nX)))
				Next nX
	
				Reclock("DK3",.F.)
				DK3->DK3_QTDINT -= nQtdQuebra
				DK3->(MsUnLock())
	
				RecLock("DK3",.T.)
				For nX := 1 To Len(aCopyDK3)
					FieldPut(nX, aCopyDK3[nX])
				Next nX
				DK3->DK3_QTDINT := nQtdQuebra
				DK3->DK3_QUEBID := cQuebraId
				DK3->(MsUnLock())
			Else
				Reclock("DK3",.F.)
				DK3->DK3_QUEBID := cQuebraId
				DK3->(MsUnLock())
			EndIf 
		EndIf
		(cAliasDK3)->(DbCloseArea())
	EndIf
Return lRet
//-----------------------------------------------------------------------------
/*/{Protheus.doc} ExisteNivel
Vefica se existe o nível no objeto xml
@author  Amanda Rosa Vieira
@since   19/11/2019
@version 1.0
/*/
//-----------------------------------------------------------------------------
Static Function ExisteNivel(cNivel)
Return Type("XMLREC" +  ":_"  + cNivel) == "O"
//-----------------------------------------------------------------------------
/*/{Protheus.doc} ApagarDK1
Apaga registros de DK1 da viagem
@author  Amanda Rosa Vieira
@since   05/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------------------
Static Function ApagarDK1(cViagId,cEmpDef)
Local aEmpViag   := {}
Local lRet       := .T.
Local lRpcSetEnv := .T.
Local cRpcEmp    := ""
Local cRpcFil    := ""
Local cRpcEmpAnt := ""
Local cAliasDK1  := ""
Local cErro      := ""
Local nY         := 0

	OsLogCPL("OMSXCPLA -> ApagarDK1 -> "+Replicate("-", 100),"INFO")
	OsLogCpl("OMSXCPLA -> ApagarDK1 -> APAGA REGISTRO TABELA DK1","INFO")
	OsLogCPL("OMSXCPLA -> ApagarDK1 -> "+Replicate("-", 100),"INFO")
	OsLogCpl("OMSXCPLA -> ApagarDK1 -> Id Viagem :" +cValtoChar(cViagId),"INFO" )
	OsLogCpl("OMSXCPLA -> ApagarDK1 -> Empresa :" +cValtoChar(cEmpDef),"INFO" )

	aEmpViag := OMSGetEmp(cViagId,@cErro)

	OsLogCpl("OMSXCPLA -> ApagarDK1 -> Conteúdo da variável cError :" +cValtoChar(cErro),"INFO" )

	If !Empty(aEmpViag)
		For nY := 1 To Len(aEmpViag)
			If !Empty(cEmpDef)
				cRpcEmp := cEmpDef
				cRpcFil := aEmpViag[nY][2]
			Else
				cRpcEmp := aEmpViag[nY][1]
				cRpcFil := aEmpViag[nY][2]
			EndIf

			OsLogCpl("OMSXCPLA -> ApagarDK1 -> Conteúdo da variável cRpcEmp :" +cValtoChar(cRpcEmp),"INFO" )
			OsLogCpl("OMSXCPLA -> ApagarDK1 -> Conteúdo da variável cRpcFil :" +cValtoChar(cRpcFil),"INFO" )

			// Por uma questão de performance, só abre uma vez o ambiente por empresa
			If !(cRpcEmpAnt == cRpcEmp)
				// Fecha o ambiente atual
				If lRpcSetEnv
					RpcClearEnv()
					lRpcSetEnv := .F.
				EndIf
				RpcSetType(3)
				// Abertura do ambiente em rotinas automáticas
				// RpcSetEnv( [ cRpcEmp ] [ cRpcFil ] [ cEnvUser ] [ cEnvPass ] [ cEnvMod ] [ cFunName ] [ aTables ] [ lShowFinal ] [ lAbend ] [ lOpenSX ] [ lConnect ] ) --> lRet
				If !RpcSetEnv( cRpcEmp, cRpcFil, /*cEnvUser*/, /*cEnvPass*/, "OMS", "OmsRecTrip", {"DK0","DK1"}) 
					SetFaultTMS("Falha Ambiente","Não foi possível inicializar o ambiente Protheus para a empresa "+cRpcEmp+" e filial "+cRpcFil+".")
					lRet := .F.

					OsLogCpl("OMSXCPLA -> ApagarDK1 -> Falha na abertura do ambiente","ERROR" )

					Exit
				EndIf
				lRpcSetEnv := .T.
				cRpcEmpAnt := cRpcEmp
			EndIf

			If lRet
				OsLogCpl("OMSXCPLA -> ApagarDK1 -> Busca pela DK1","INFO" )

				cAliasDK1 := GetNextAlias()
				BeginSql Alias cAliasDK1
					SELECT DK1.R_E_C_N_O_ RECNODK1
					FROM %Table:DK1% DK1
					WHERE DK1.DK1_FILIAL = %xFilial:DK1%
					AND DK1.DK1_VIAGID = %Exp:cViagId%
					AND DK1.%NotDel%
				EndSql
				While (cAliasDK1)->(!EoF())
					DK1->(DbGoTo((cAliasDK1)->RECNODK1))
					Reclock("DK1",.F.)
					DK1->(DbDelete())
					DK1->(MsUnLock())

					OsLogCpl("OMSXCPLA -> ApagarDK1 -> Registro encontrado e deletado","INFO" )

					(cAliasDK1)->(DbSkip())
				EndDo
				(cAliasDK1)->(DbCloseArea())
			EndIf
		Next nY
	ElseIf !Empty(cErro)
		lRet := .F.
	EndIf
Return lRet
/*/{Protheus.doc} OMSGetEnt
// Função responsável carregar as informações da entrega
@author amanda.vieira
@since 13/02/2020
@version 1.0
@param oPedido, objeto, objeto pedido
@param aObjStops, array, paradas (tag stop do xml)
@type function
/*/
Static Function OMSGetEnt(oPedido,aObjStops)
Local aPedidos := {}
Local nI       := 1
Local nX       := 1
Local oSubStop := Nil
Local oStop    := Nil
Local oPedAux  := NIl
	For nI := 1 To Len(aObjStops)
		oStop := aObjStops[nI][1]
		oSubStop := oStop:subStops[1] 
		aPedidos := aObjStops[nI][2]
		For nX := 1 To Len(aPedidos)
			oPedAux := aPedidos[nX]
			If (oPedido:orderSourceId == oPedAux:orderSourceId)
				oPedido:sequenceOnLoad := oStop:sequenceOnLoad
				oPedido:arrivalTime := oSubStop:arrivalTime
				oPedido:departureTime := oSubStop:departureTime
				oPedido:startServiceTime := oSubStop:startServiceTime
				oPedido:endServiceTime := oSubStop:endServiceTime
				Exit
			EndIf
		Next nX
	Next nI
Return .T.

/*/{Protheus.doc} OmsRecFin
	Classe cliente de webService para tratativas no Produto baseado do XML de Finalização do Monitoramento
@author Aluizio/Amanda
@since 13/07/2020
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function OmsRecFin(oXml,cConteudo)
Local lRet       := .T.
Local oXmlFin    := Nil
Local cError     := ""
Local cWarning   := ""

Local cMonSrcId  := ""
Local cMonType   := ""
Local cMonFlag   := ""

Local aString    := {}
Local cEmpFil    := ""
Local cCodCga    := ""
Local cSeqCga    := ""
Local cEmpCga    := ""
Local cFilCga    := ""

Local nTamFil    := 0
Local nTamEmp    := 0

Local cEmpAnt    := ""
local lRpcSetEnv := .F.
Local cAliasSF2  := ""

Local lOperador  := .F.
Local cWhere     := "%"

	oXmlFin := XmlParser(cConteudo, "NS1", @cError,  @cWarning )
	cMonSrcId := oXmlFin:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS2_REQUEST:_NS2_FINISHINGSET:_NS2_MONITORABLESOURCEID:TEXT
	cMonType  := oXmlFin:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS2_REQUEST:_NS2_FINISHINGSET:_NS2_MONITORABLETYPE:TEXT
	cMonFlag  := oXmlFin:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS2_REQUEST:_NS2_FINISHINGSET:_NS2_FINISHED:TEXT

	// Grava o conteúdo do XML na pasta de Log, caso ativado
	OMSXGRVXML("PublishFinishing",@cConteudo,"DK5",cMonSrcId)	

	//Separacao da Empresa+Filial, Código e Sequencia da Carga
	aString   := StrTokArr(cMonSrcId, "-" )
	cEmpFil   := aString[1]
	cCodCga   := aString[2]
	cSeqCga   := aString[3]

	//Separacao da Empresa e Filial
	nTamFil := FwSizeFilial()
	nTamEmp := Len(cEmpFil)- nTamFil
	cEmpCga := SubStr(cEmpFil, 1, nTamEmp)
	cFilCga := SubStr(cEmpFil, nTamEmp+1, nTamFil)

	// Por uma questão de performance, só abre uma vez o ambiente por empresa
	If !(cEmpAnt == cEmpCga)
		// Fecha o ambiente atual
		If lRpcSetEnv
			RpcClearEnv()
			lRpcSetEnv := .F.
		EndIf
		RpcSetType(3)
		// Abertura do ambiente em rotinas automáticas
		// RpcSetEnv( [ cRpcEmp ] [ cRpcFil ] [ cEnvUser ] [ cEnvPass ] [ cEnvMod ] [ cFunName ] [ aTables ] [ lShowFinal ] [ lAbend ] [ lOpenSX ] [ lConnect ] ) --> lRet
		If !RpcSetEnv( cEmpCga, cFilCga, /*cEnvUser*/, /*cEnvPass*/, "OMS", "OmsRecFin", {"DK5","DAK","SF2"}) 
			SetFaultTMS("Falha Ambiente","Não foi possível inicializar o ambiente Protheus para a empresa "+cEmpCga+" e filial "+cFilCga+".")
			lRet := .F.
		EndIf
		lRpcSetEnv := .T.
		cEmpAnt := cEmpCga
	EndIf	
	
	Begin Transaction
		//Indicação de entrega da Carga.
		dbSelectArea("DAK")
		DAK->(dbSetOrder(1))
		If DAK->(MsSeek(xFilial("DAK")+cCodCga+cSeqCga))
			OsAvalDAK("DAK",5)
		EndIf		

		//Atualização da data de entrega das Notas Fiscais relacionadas a Carga.
		lOperador  := (DAI->(ColumnPos("DAI_FILPV")) > 0 .And. IntDL() .And. SuperGetMV('MV_APDLOPE', .F., .F.))
		If lOperador 
			cWhere += " SF2.F2_FILIAL = DAI.DAI_FILPV "
		else
			cWhere += " SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
		EndIf
		cWhere += "%"
			
		cAliasSF2 := GetNextAlias()
		BeginSql Alias cAliasSF2
		  SELECT SF2.R_E_C_N_O_ RECNOSF2
		    FROM %Table:SF2% SF2, %Table:DAI% DAI
		   WHERE DAI.DAI_FILIAL = %xFilial:DAI%
		     AND DAI.DAI_COD    = %Exp:cCodCga%
			 AND DAI.DAI_SEQCAR = %Exp:cSeqCga%
			 AND SF2.F2_CARGA   = %Exp:cCodCga%
			 AND SF2.F2_SEQCAR  = %Exp:cSeqCga%
			 AND DAI.%NotDel%
			 AND SF2.%NotDel%
			 AND %Exp:cWhere%
		EndSql
		While (cAliasSF2)->(!EoF())
			SF2->(dbGoTo((cAliasSF2)->RECNOSF2))
			RecLock("SF2",.F.)
			SF2->F2_DTENTR := Date()
			SF2->(MsUnlock())
			(cAliasSF2)->(DbSkip())		
		EndDo
		(cAliasSF2)->(DbCloseArea())		
		
		//Finalização da Carga no controle do Cockpit Logístico
		dbSelectArea("DK5")
		DK5->(DbSetOrder(1))
		If DK5->(MsSeek(xFilial('DK5')+cCodCga+cSeqCga))
			RecLock("DK5",.F.)
				DK5->DK5_STATUS := "3"
				If (DK5->(ColumnPos("DK5_DTFICA"))) > 0
					DK5->DK5_DTFICA := Date()
					DK5->DK5_HRFICA := Time()
				EndIf
			DK5->(MsUnLock())	
		EndIf
	End Transaction
Return lRet
/*/{Protheus.doc} OMSXDELNF
	Ao excluir a NF, limpa os campos DK1_NFISCA,DK1_SERIE
@author Equipe OMS
@since 03/08/2021
/*/
Function OMSXDELNF()
Local aArea := GetArea()

	dbSelectArea('DK1')
	If !Empty(DK1->(IndexKey(3)))
		DK1->(dbSetOrder(3))
		While DK1->(DbSeek(FwXFilial("DK1")+SF2->F2_FILIAL+SF2->F2_SERIE+SF2->F2_DOC))
			RecLock('DK1',.F.)
				DK1->DK1_NFISCA := ""
				DK1->DK1_SERIE  := ""
			DK1->(MsUnLock())
			DK1->(DbSkip())
		EndDo
	Else
		Help( ,, STR0001,,STR0002, 1, 0,,,,,.T. ) //"Atenção"##""A rotina MATA521 foi atualizada sem o pacote de dicionários correspondente. Favor criar o índice 3 para a tabela DK1 (Módulo OMS)."
	EndIf
	RestArea(aArea)
Return 


/*/{Protheus.doc} OMSPtEntrg
	Funcao para unificar pontos de entrega baseados nos horarios de chegada/saida das pararas e subparadas do TOL.
	O OMS nao separa estes pontos.
@author carlos.augusto
@since 10/06/2022
@param cChaveDK1 chave da DK1 que está sendo criada no momento
@param nSeqOrdSrc variavel de referencia para receber a sequencia DK1_SEQENT do objeto oOmsPontoEntrega
@param aDadosPEnt objeto que podera ser atualizado ou apenas retornar os valores para validacoes
@param aChegada dados da chegada desta parada ou subparada do TOL
@param aSaida  dados da saida desta parada ou subparada do TOL
@param cObjArrival dados da chegada desta parada ou subparada do TOL (como valor real/raiz TOL)
@param cObjDepart dados da saida desta parada ou subparada do TOL (como valor real/raiz TOL)
/*/
Static Function OMSPtEntrg(cChaveDK1, nSeqOrdSrc, aDadosPEnt, aChegada, aSaida, cObjArrival, cObjDepart)
	Local cArrival 	 := ""
	Local cDeparture := ""
	Local cDtChegChv := ""
	Local cDtSaidChv := ""
	Local cDTCheg 	 := ""
	Local cDTSaida   := ""
	Local cHrChegChv := ""
	Local cHrCheg    := ""
	Local cHrSaidChv := ""
	Local cHrSaid    := ""
	Local lAltChvEnt := .F.
	Local aChvDK1    := {}
	Local oOmsPontoEntrega := Nil

	OsLogCpl("OMSXCPLA -> ProcViagem -> OMSPtEntrg -> Possui os campos novos (DK1_SEQUEN e DK1_QUEORI). Validando faixas de horarios chegada e saida (Arrival e Departure).","INFO" )

	nSeqOrdSrc  := aDadosPEnt[2]:nSequenciaEntrega
	aChvDK1  	:= aDadosPEnt[2]:aChaveDK1
	cDtChegChv 	:= aDadosPEnt[2]:dDataChegada
	cDtSaidChv 	:= aDadosPEnt[2]:dDataSaida
	cHrChegChv 	:= aDadosPEnt[2]:cHoraChegada 
	cHrSaidChv 	:= aDadosPEnt[2]:cHoraSaida

	//Data diferente de chegada?
	If cDtChegChv != aChegada[1]
		//Qual eh maior, preciso da data menor
		If cDtChegChv < aChegada[1]
			cDTCheg := cDtChegChv
		Else
			cChegad := aChegada[1]
			cArrival := cObjArrival
			lAltChvEnt := .T.  //Se o novo registro tem data inferior, preciso atualizar a chave do ponto de entrega
		EndIf
	Else //Se nao, assumo a mesma data
		cDTCheg := cDtChegChv
		//Agora eh preciso saber se o horario possui diferencas
		If cHrChegChv != aChegada[2]
			//Qual eh maior, preciso da hora menor
			If cHrChegChv < aChegada[2]
				cHrCheg := cHrChegChv
			Else
				cHrCheg := aChegada[2]
				lAltChvEnt := .T.  //Se o novo registro tem data inferior, preciso atualizar a chave do ponto de entrega
				cArrival := cObjArrival
			EndIf
		Else
			cHrCheg := cHrChegChv
		EndIf
	EndIf

	//Data diferente de saida?
	If cDtSaidChv != aSaida[1]
		//Qual eh maior, preciso da data menor
		If cDtSaidChv < aSaida[1]
			cDTSaida := cDtSaidChv
		Else
			cDTSaida := aSaida[1]
			lAltChvEnt := .T.  //Se o novo registro tem data inferior, preciso atualizar a chave do ponto de entrega
			cDeparture := cObjDepart
		EndIf
	Else //Se nao, assumo a mesma data
		cDTSaida := cDtSaidChv
		//Agora eh preciso saber se o horario possui diferencas
		If cHrSaidChv != aSaida[2]
			//Qual eh maior? preciso da hora maior
			If cHrSaidChv > aSaida[2]
				cHrSaid := cDtSaidChv
			Else
				cHrSaid := aSaida[2]
				lAltChvEnt := .T.  //Se o novo registro tem data inferior, preciso atualizar a chave do ponto de entrega
				cDeparture := cObjDepart
			EndIf
		Else
			cHrSaid := cHrSaidChv
		EndIf
	EndIf

	//Se nao possui alteracao no ponto de entrega, mantemos os objeto com os dados
	If lAltChvEnt
		OsLogCpl("OMSXCPLA -> ProcViagem -> OMSPtEntrg -> Possui os campos novos (DK1_SEQUEN e DK1_QUEORI). Houve diferencas entre faixas de horarios chegada e saida (Arrival e Departure).","INFO" )
		If Empty(cArrival)
			cArrival := aDadosPEnt[2]:cArrivalTime
		EndIf
		If Empty(cDeparture)
			cDeparture := aDadosPEnt[2]:cDepartureTime
		EndIf
		Aadd(aChvDK1, cChaveDK1)
		oOmsPontoEntrega := OmsPontoEntrega():New()
		oOmsPontoEntrega:nSequenciaEntrega := nSeqOrdSrc
		oOmsPontoEntrega:aChaveDK1 := aChvDK1
		oOmsPontoEntrega:cArrivalTime := cArrival
		oOmsPontoEntrega:cDepartureTime := cDeparture
		oOmsPontoEntrega:dDataChegada := cDTCheg
		oOmsPontoEntrega:dDataSaida := cDTSaida
		oOmsPontoEntrega:cHoraChegada := cHrCheg
		oOmsPontoEntrega:cHoraSaida := cHrSaid
	EndIf
	OsLogCpl("OMSXCPLA -> ProcViagem -> OMSPtEntrg -> Possui os campos novos (DK1_SEQUEN e DK1_QUEORI). Final da validacao de horarios chegada e saida da parada ou subparada (Arrival e Departure).","INFO" )

Return oOmsPontoEntrega



/*/{Protheus.doc} OMSDK1Ent
	Funcao para unificar pontos de entrega com horarios diferentes.
	A Neolog trata subparadas com dois horarios diferentes, mas o OMS nao separada.
	Pois isso, precisamos do primeiro horario de chegada com o ultimo de saida.
	Ao chegar nessa funcao, esse tratamento ja foi finalizado e precisamos apenas atualizar o 
	registro da DK1 com estas faixas de horarios.
@author carlos.augusto
@since 10/06/2022
@param aChavValor array com os itens que formar um unico ponto de entrega no OMS
@param nRecnoDK1 recno da DK1 para restArea manual
/*/
Static Function OMSDK1Ent(aChavValor,nRecnoDK1)
	Local nX 		:= 1
	Local nY 		:= 1
	Local aItemDK1  := {}
	Local oOmsPontoEntrega := Nil
	OsLogCpl("OMSXCPLA -> ProcViagem -> OMSDK1Ent -> Possui os campos novos (DK1_SEQUEN e DK1_QUEORI). Validando faixas de ponto de entrega DK1 (DK1_CHEGAD e DK1_TSAIDA).","INFO" )
	If !Empty(aChavValor)
		For nX := 1 To Len(aChavValor)
			oOmsPontoEntrega := aChavValor[nX][2]
			aItemDK1 := oOmsPontoEntrega:aChaveDK1
			For nY := 1 To Len(aItemDK1) //Lista das DK1 desta chave (os horarios estao separando)
				OsLogCpl("OMSXCPLA -> ProcViagem -> OMSDK1Ent -> Possui os campos novos (DK1_SEQUEN e DK1_QUEORI). Unificando faixas de ponto de entrega DK1 (DK1_CHEGAD e DK1_TSAIDA).","INFO" )
				If DK1->(dbSeek(aItemDK1[nY]))
					Reclock("DK1",.F.)
						DK1->DK1_CHEGAD := oOmsPontoEntrega:cArrivalTime
						DK1->DK1_TSAIDA := oOmsPontoEntrega:cDepartureTime
					DK1->(MsUnLock())
				EndIf
			Next nY
		Next nX
	EndIf
	DK1->(dbGoto(nRecnoDK1))
	OsLogCpl("OMSXCPLA -> ProcViagem -> OMSDK1Ent -> Possui os campos novos (DK1_SEQUEN e DK1_QUEORI). Validacao finalizada.","INFO" )
Return
