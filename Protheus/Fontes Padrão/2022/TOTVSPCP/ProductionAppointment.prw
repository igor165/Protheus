#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "ProductionAppointment.ch"

Static __lPEGetOP := Nil
Static __lPEPosAP := Nil

WSRESTFUL ProductionAppointment DESCRIPTION "Serviço REST para manipulação do apontamento de produção"

WSDATA ProductionOrderNumber  AS String   
WSDATA appointmentType        AS String
WSDATA ActivityID             AS String
WSDATA ActivityCode           AS String
WSDATA MachineCode            AS String 
WSDATA Split                  AS String
WSDATA formCode               AS STRING  OPTIONAL

WSMETHOD GET ProductionOrder	DESCRIPTION "Valida a ordem de produção e Recupera os dados da ordem de produção"	                     WSSYNTAX "/v1/ProductionOrder/{ProductionOrderNumber}/{appointmentType}/{ActivityCode}/{MachineCode}/{Split}/{ActivityID}/{formCode}" PATH "/v1/ProductionOrder/"
WSMETHOD GET SplitOrder         DESCRIPTION "Recupera os dados dos splits da ordem de produção/máquina"	                                 WSSYNTAX "/v1/SplitOrder/{ProductionOrderNumber}/{MachineCode}" PATH "/v1/SplitOrder/"
WSMETHOD GET MachineValidation  DESCRIPTION "Valida se é possível utilizar a máquina para iniciar um apontamento"	                     WSSYNTAX "/v1/MachineValidation/{MachineCode}" PATH "/v1/MachineValidation/"
WSMETHOD GET SplitValidation    DESCRIPTION "Valida se é possível utilizar o split para iniciar um apontamento"	                         WSSYNTAX "/v1/SplitValidation/{MachineCode}/{ProductionOrderNumber}/{ActivityID}/{Split}" PATH "/v1/SplitValidation/"
WSMETHOD GET OperationTime      DESCRIPTION "Recupera os tempos da operação"	                                                         WSSYNTAX "/v1/OperationTime/{ProductionOrderNumber}/{ActivityID}/{Split}" PATH "/v1/OperationTime/"
WSMETHOD POST mata250      		DESCRIPTION "Inclui novo apontamento na ordem de produção através do apontamento simplificado (mata250)" WSSYNTAX "/v1/mata250/" PATH "/v1/mata250/"
WSMETHOD POST mata681      		DESCRIPTION "Inclui novo apontamento na ordem de produção através do apontamento por operação (mata681)" WSSYNTAX "/v1/mata681/" PATH "/v1/mata681/"
WSMETHOD POST sfca314      		DESCRIPTION "Inclui novo apontamento na ordem de produção através do apontamento SFC (sfca314)"          WSSYNTAX "/v1/sfca314/" PATH "/v1/sfca314/"

END WSRESTFUL

WSMETHOD GET ProductionOrder WSRECEIVE ProductionOrderNumber, ActivityCode, appointmentType, MachineCode, Split, ActivityID, formCode WSSERVICE ProductionAppointment
Local cFormCode     := ""
Local cJson := ""
Local lGet  := .T.
Local oJson := JsonObject():New()

Private l250Auto 	:= .F.
Private l680Auto 	:= .F.
Private l681Auto 	:= .F.
Private l240:=.F.,l250 :=.F.,l241:=.F.,l242:=.F.,l261:=.F.,l185:=.F.,l650:=.F.,l680:=.F.,l681:=.F.,l682:=.F.
Private nOpcAuto    := 3
Private lMSErroAuto := .F.
Private lAutoErrNoFile := .T.
Private aTELA[0][0],aGETS[0]
Private aRotAuto    := Nil
Private lPerdInf    := SuperGetMV("MV_PERDINF",.F.,.F.)
Private nFCICalc    := SuperGetMV("MV_FCICALC",.F.,0)
Private lUsaSegUm

Set(_SET_DATEFORMAT, 'dd/mm/yyyy') // Data com QUATRO digitos para Ano

//Parado no teste da OP localhost:8040/rest/productionappointment/v1/ProductionOrder?ProductionOrderNumber=00436901001&appointmentType=1 e está ocorrendo erro de variavel private

// define o tipo de retorno do método
::SetContentType("application/json")

// verifica se recebeu parametro pela URL
// exemplo: http://localhost:8080/sample/1
If !Empty(::ProductionOrderNumber)
	
	If !Empty(::appointmentType)

		//Verifica a existência de ponto de entrada.
		If __lPEGetOP == Nil 
			__lPEGetOP := ExistBlock("PApGetOP")
		EndIf

        cFormCode := ::formCode

		If ::appointmentType == '1' // Mata250
			l250     := .T.
			l250Auto := .T.

			RegToMemory("SD3",.T.) // Inicializar as variáveis de memória do mata250

			M->D3_OP := ::ProductionOrderNumber
			
			SC2->(dbSetOrder(1))
			If SC2->(dbSeek(xFilial("SC2")+Padr(M->D3_OP,TamSX3("D3_OP")[1])))

				M->D3_COD     := SC2->C2_PRODUTO
				M->D3_EMISSAO := DTOC(DATE())

				If A250IniOP()

					oJson['ProductionOrderNumber'     ] := Trim(M->D3_OP)
					oJson['ItemCode'                  ] := Trim(M->D3_COD)
					oJson['ItemDescription'           ] := Trim(M->D3_DESCRI)
					oJson['ApprovedQuantity'          ] := M->D3_QUANT 
					oJson['WarehouseCode'             ] := Trim(M->D3_LOCAL)
					oJson['UnitOfMeasureCode'         ] := Trim(M->D3_UM)
					oJson['DocumentCode'              ] := Trim(M->D3_DOC)
					oJson['StartReportDateTime'       ] := M->D3_EMISSAO 
					oJson['Part_Total'                ] := Trim(M->D3_PARCTOT) 
					oJson['LotPotency'                ] := M->D3_POTENCI
					oJson['CostCenter'                ] := Trim(M->D3_CC)
					oJson['LedgerAcct'                ] := Trim(M->D3_CONTA)
					oJson['UnitOfMeasureCode2'        ] := Trim(M->D3_SEGUM)
					oJson['UnitOfMeasureCode2Quantity'] := M->D3_QTSEGUM
					oJson['LotCode'                   ] := Trim(M->D3_LOTECTL)
					oJson['LotDueDate'                ] := DTOC(M->D3_DTVALID)
					oJson['Service'                   ] := Trim(M->D3_SERVIC)
					oJson['MovimentType'              ] := Trim(M->D3_TM)
		
					cJson := oJson:ToJson()
					If __lPEGetOP
						cJson := ExecBlock("PApGetOP", .F., .F., {"1", cJson, cFormCode})
					EndIf

					::SetResponse(EncodeUTF8(cJson))
				ElseIf lMSErroAuto
					lGet := .F.
					SetRestFault(400, EncodeUTF8(FormataErro())) 
				EndIf
			Else
				SetRestFault(400, EncodeUTF8(STR0001)) //"Ordem de Produção não cadastrada"	
				lGet := .F.
			EndIf		

			SC2->(dbCloseArea())	
		ElseIf ::appointmentType == '3' // Mata681
			If !Empty(::ActivityCode)
				Private cGetAPI := 'APIREST-GET681'

				l681     := .T.
				l681Auto := .T.

				RegToMemory("SH6",.T.) // Inicializar as variáveis de memória do mata681

				M->H6_OP := ::ProductionOrderNumber
				M->H6_OP := Padr(M->H6_OP,TamSX3("H6_OP")[1])

				SC2->(dbSetOrder(1))
				If SC2->(dbSeek(xFilial("SC2")+M->H6_OP))

					M->H6_PRODUTO := SC2->C2_PRODUTO
					M->H6_DATAINI := DTOC(DATE())
					M->H6_DATAFIN := DTOC(DATE())
					M->H6_DTAPONT := DTOC(DATE())
					M->H6_OPERAC  := ::ActivityCode
					M->H6_OPERAC  := Padr(M->H6_OPERAC,TamSX3("H6_OPERAC")[1])

					Pergunte("MTA680",.F.)

					If A680IniOP() .And. A680InOper() .And. A680Oper(.F.)

						If Rastro(M->H6_PRODUTO) .And. Empty(M->H6_DTVALID)
							M->H6_DTVALID := dDataBase + SB1->B1_PRVALID
						EndIf

						oJson['ProductionOrderNumber'     ] := Trim(M->H6_OP)
						oJson['ItemCode'                  ] := Trim(M->H6_PRODUTO)
						oJson['ItemDescription'           ] := getDescription("P")
						oJson['WarehouseCode'             ] := Trim(M->H6_LOCAL)
						oJson['ActivityCode'              ] := Trim(M->H6_OPERAC)
						oJson['OperationDescription'      ] := getDescription("O")
						oJson['MachineCode'               ] := Trim(M->H6_RECURSO)
						oJson['StartReportDateTime'       ] := M->H6_DATAINI
						oJson['EndReportDateTime'         ] := M->H6_DATAFIN
						oJson['ReportDateTime'            ] := M->H6_DTAPONT
						oJson['LotCode'                   ] := Trim(M->H6_LOTECTL)
						oJson['LotDueDate'                ] := DTOC(M->H6_DTVALID)
						oJson['LotPotency'                ] := M->H6_POTENCI
						oJson['ApprovedQuantity'          ] := M->H6_QTDPROD 
						oJson['UnitOfMeasureCode2Quantity'] := M->H6_QTDPRO2
						oJson['Part_Total'                ] := Trim(M->H6_PT) 
						oJson['Apportionment'             ] := M->H6_RATEIO

						cJson := oJson:ToJson()

						If __lPEGetOP
							cJson := ExecBlock("PApGetOP", .F., .F., {"3", cJson, cFormCode})
						EndIf

						::SetResponse(EncodeUTF8(cJson))
					ElseIf lMSErroAuto
						lGet := .F.
						SetRestFault(400, EncodeUTF8(FormataErro())) 
					EndIf
				Else
					SetRestFault(400, EncodeUTF8(STR0001)) //"Ordem de Produção não cadastrada"	
					lGet := .F.
				EndIf
			Else
				SetRestFault(400, EncodeUTF8(STR0010)) //"Operação não informada."
				lGet := .F.
			EndIf
		ElseIf ::appointmentType == '4' // SFCA314
			If Empty(::MachineCode)
				SetRestFault(400, EncodeUTF8(STR0014)) //"Não foi informada a máquina."
				lGet := .F.
			EndIf
			If lGet
				If Empty(::ProductionOrderNumber)
					SetRestFault(400, EncodeUTF8(STR0003)) //"Ordem de Produção não informada"
					lGet := .F.
				EndIf
			EndIf
			If lGet
				If Empty(::Split)
					SetRestFault(400, EncodeUTF8(STR0027)) //"Não foi informado o split."
					lGet := .F.
				EndIf
			EndIf
			If lGet
				If Empty(::ActivityID)
					SetRestFault(400, EncodeUTF8(STR0024)) //"Não foi informado o ID da operação" 
					lGet := .F.
				EndIf
			EndIf

			If lGet
				cOp 	:= PadR(::ProductionOrderNumber, TamSX3("CYV_NRORPO")[1])
				cIdOper := PadR(::ActivityID           , TamSX3("CYV_CDAT"  )[1])
				cSplit	:= PadR(::Split                , TamSX3("CYV_IDATQO")[1])
				cMaq    := PadR(::MachineCode          , TamSX3("CYV_CDMQ"  )[1])

				DbSelectArea("CYQ")
				CYQ->(DbSetOrder(1))
				If CYQ->(!DbSeek(xFilial("CYQ")+cOp))
					SetRestFault(400, EncodeUTF8(STR0001)) //"Ordem de Produção não cadastrada" 
					lGet := .F.
				EndIf
			EndIf

			If lGet
				DbSelectArea("CYY")
				CYY->(DbSetOrder(1))
				If CYY->(!DbSeek(xFilial("CYY")+cOp+cIdOper+cSplit))
					SetRestFault(400, EncodeUTF8(STR0029)) //"Split não cadastrado."         
					lGet := .F.
				EndIf
			EndIf

			If lGet
				If !Empty(CYY->CYY_CDMQ) .And. CYY->CYY_CDMQ != cMaq
					SetRestFault(400, EncodeUTF8(STR0031)) //"Máquina não pertence ao Id da Operação."         
					lGet := .F.
				EndIf
			EndIf

			If lGet
				DbSelectArea("CY9")
				CY9->(DbSetOrder(1))
				If CY9->(!DbSeek(xFilial("CY9")+cOp+cIdOper))
					SetRestFault(400, EncodeUTF8(STR0030)) //"Operações da Ordem não cadastrada."         
					lGet := .F.
				EndIf
			EndIf
						
			If lGet
				//Quantidade disponivel do Split -- sem considerar as operações anteriores
				cQtdDisp := (CYY->CYY_QTAT - CYY->CYY_QTATAP - CYY->CYY_QTATRF)

				oJson['appointmentType'      ] := '4'              //Tipo do apontamento
				oJson['MachineCode'          ] := cMaq             //Maquina
				oJson['ProductionOrderNumber'] := cOp              //Ordem Produção
				oJson['Split'                ] := cSplit           //Split
				oJson['ActivityID'           ] := cIdOper          //ID Operação
				oJson['ActivityCode'         ] := CY9->CY9_CDAT    //Operação
				oJson['ItemCode'             ] := CYY->CYY_CDAC    //Item
				oJson['StartSetupDateTime'   ] := ' '              //Data Inicio Preparação
				oJson['StartSetupTime'       ] := ' '              //Hora Início Preparação
				oJson['EndSetupDateTime'     ] := ' '              //Data Fim Preparação
				oJson['EndSetupTime'         ] := ' '              //Hora Fim Preparação
				oJson['SetupCode'            ] := ' '              //Código Preparação
				oJson['ToolCode'             ] := ' '              //Código da Ferramenta
				oJson['ApprovedQuantity'     ] := cQtdDisp         //Quantidade aprovada
				oJson['ScrapQuantity'        ] := 0                //Quantidade refugada
				oJson['StartReportDateTime'  ] := DTOC(DATE())     //Data Início
				oJson['StartReportTime'      ] := Time()           //Hora Início
				oJson['EndReportDateTime'    ] := DTOC(DATE())     //Data Fim
				oJson['EndReportTime'        ] := ' '              //Hora Fim
				oJson['ProductionShiftCode'  ] := ' '              //Modelo Turno
				oJson['DocumentCode'         ] := cOp              //Documento
				oJson['DocumentSeries'       ] := ' '              //Série Documento
				oJson['WarehouseCode'        ] := CYQ->CYQ_CDDP    //Depósito
				oJson['LotCode'              ] := ' '              //Lote/Serie
				oJson['LotDueDate'           ] := ' '              //Data Validade Lote
				oJson['OperatorName'         ] := ' '              //Operador
				oJson['ProductionTeamCode'   ] := ' '              //Equipe

				cJson := oJson:ToJson()

				If __lPEGetOP
					cJson := ExecBlock("PApGetOP", .F., .F., {"4", cJson, cFormCode})
				EndIf

				::SetResponse(EncodeUTF8(cJson))
			EndIf
		EndIf
	Else
		SetRestFault(400, EncodeUTF8(STR0002)) 	//"Tipo de apontamento não informado"
		lGet := .F.
	EndIf
Else
	SetRestFault(400, EncodeUTF8(STR0003)) 	//"Ordem de Produção não informada"
	lGet := .F.
EndIf

FreeObj(oJson)

Return lGet

WSMETHOD GET SplitOrder  WSRECEIVE ProductionOrderNumber, MachineCode  WSSERVICE ProductionAppointment
Local aCab  := {}
Local aCYY  := {}
Local lGet  := .T.
Local nI    := 0
Local oJson

Set(_SET_DATEFORMAT, 'dd/mm/yyyy') // Data com QUATRO digitos para Ano

// define o tipo de retorno do método
::SetContentType("application/json")

If Empty(::ProductionOrderNumber)
	SetRestFault(400, EncodeUTF8(STR0003)) 	//"Ordem de Produção não informada"
	lGet := .F.
EndIf

If lGet
	If Empty(::MachineCode)
		SetRestFault(400, EncodeUTF8(STR0014)) //"Não foi informada a máquina."
		lGet := .F.
	EndIf
EndIf

If lGet
	aCab := ConCab(::ProductionOrderNumber, ::MachineCode)
	aCYY := ConSplit(::ProductionOrderNumber, ::MachineCode)

	If Len(aCYY) < 1 .Or. Len(aCab) < 1
		lGet := .F.
		SetRestFault(400, EncodeUTF8(STR0029)) //"Split não cadastrado."    
	EndIf
EndIf

If lGet
	oJson := JsonObject():New() 
	oJson["Splits"] := {}
	Aadd(oJson["Splits"], JsonObject():New())

	::SetResponse('[')
	oJson['ProductionOrderNumber'] := aCab[1,1]
	oJson['ItemCode']              := aCab[1,2]
	oJson['ItemDescription']       := aCab[1,3]
	oJson['UnitOfMeasureCode']     := aCab[1,4]

	oJson["Splits"] := {}
		For nI := 1 To len(aCYY)
			Aadd(oJson["Splits"], JsonObject():New())			
			oJson["Splits"][nI]['split']                 := aCYY[nI,1]
			oJson["Splits"][nI]['ActivityID']            := aCYY[nI,2]
			oJson["Splits"][nI]['ActivityCode']          := aCYY[nI,3]
			oJson["Splits"][nI]['OperationDescription']  := aCYY[nI,4]
		Next nI

	::SetResponse(EncodeUTF8(oJson:toJson()))
	::SetResponse(']') 
EndIf

Return lGet

WSMETHOD GET MachineValidation WSRECEIVE ProductionOrderNumber, MachineCode  WSSERVICE ProductionAppointment
Local lGet  := .T.
Local oJson
Local cMsgErro := ''

Set(_SET_DATEFORMAT, 'dd/mm/yyyy') // Data com QUATRO digitos para Ano

// define o tipo de retorno do método
::SetContentType("application/json")

If Empty(::ProductionOrderNumber)
	SetRestFault(400, EncodeUTF8(STR0003)) 	//"Ordem de Produção não informada"
	lGet := .F.
EndIf

If lGet
	If Empty(::MachineCode)
		SetRestFault(400, EncodeUTF8(STR0014)) //"Não foi informada a máquina."
		lGet := .F.
	EndIf
EndIf

If lGet
	//Verifica se existe apontamento de parada em aberto para a máquina
	If !SFCParAber(::MachineCode,, 1,@cMsgErro)
		lGet := .F.
		SetRestFault(400, EncodeUTF8(cMsgErro))	
	EndIf
EndIf

If lGet
	//Verifica se existe apontamento de produção em aberto para a máquina
	If !SFCApAbeMq(::MachineCode,,1,@cMsgErro, ::ProductionOrderNumber)
		lGet := .F.
		SetRestFault(400, EncodeUTF8(cMsgErro))
	EndIf
EndIf

If lGet
	//Verifica se existe apontamento de parada de preparação iniciado para a máquina
	If SFCSetupIn(::MachineCode,1,@cMsgErro)
		lGet := .F.
		SetRestFault(400, EncodeUTF8(cMsgErro))
	EndIf
EndIf

If lGet
	//Máquina não pode iniciar apontamento
	If !SFCPerIni(::MachineCode,1,@cMsgErro)
		lGet := .F.
		SetRestFault(400, EncodeUTF8(cMsgErro)) 				
	EndIf
EndIf

If lGet
	oJson := JsonObject():New() 
	
	oJson['MachineCode']           := ::MachineCode
	oJson['ProductionOrderNumber'] := ::ProductionOrderNumber
	oJson['Status']                := .T.
	
	::SetResponse(EncodeUTF8(oJson:toJson()))
EndIf

Return lGet

WSMETHOD GET SplitValidation WSRECEIVE MachineCode,ProductionOrderNumber,ActivityID,Split  WSSERVICE ProductionAppointment

Local lGet      := .T.
Local oJson
Local cMsgErro  := ''
Local lStatus   := .T.
Local lExistIni := .F.

Set(_SET_DATEFORMAT, 'dd/mm/yyyy') // Data com QUATRO digitos para Ano

// define o tipo de retorno do método
::SetContentType("application/json")

If Empty(::MachineCode)
	SetRestFault(400, EncodeUTF8(STR0014)) //"Não foi informada a máquina."
	lGet := .F.
EndIf

If lGet
	If Empty(::ProductionOrderNumber)
		SetRestFault(400, EncodeUTF8(STR0003)) 	//"Ordem de Produção não informada"
		lGet := .F.
	EndIf
EndIf

If lGet
	If Empty(::ActivityID)
		SetRestFault(400, EncodeUTF8(STR0024)) //"Não foi informado o ID da operação."
		lGet := .F.	
	EndIf
EndIf

If lGet
	If Empty(::Split)
		SetRestFault(400, EncodeUTF8(STR0027)) //"Não foi informado o split."
		lGet := .F.	
	EndIf
EndIf

If lGet
	cOp 	   := PadR(::ProductionOrderNumber,TamSX3("CYV_NRORPO")[1])
	cIdOper    := PadR(::ActivityID,TamSX3("CYV_CDAT")[1])
	cSplit	   := PadR(::Split,TamSX3("CYV_IDATQO")[1])
	cMaq       := PadR(::MachineCode,TamSX3("CYV_CDMQ")[1])

	DbSelectArea("CYQ")
	CYQ->(DbSetOrder(1))
	If CYQ->(!DbSeek(xFilial("CYQ")+cOp))
		SetRestFault(400, EncodeUTF8(STR0001)) //"Ordem de Produção não cadastrada" 
		lGet := .F.
	EndIf
EndIf

If lGet
	DbSelectArea("CYY")
	CYY->(DbSetOrder(1))
	If CYY->(!DbSeek(xFilial("CYY")+cOp+cIdOper+cSplit))
		SetRestFault(400, EncodeUTF8(STR0029)) //"Split não cadastrado."         
		lGet := .F.
	EndIf
EndIf

If lGet
	If !EMPTY(CYY->CYY_CDMQ) .And. CYY->CYY_CDMQ != cMaq
		SetRestFault(400, EncodeUTF8(STR0031)) //"Máquina não pertence ao Id da Operação."         
		lGet := .F.
	EndIf
EndIf

If lGet
	DbSelectArea("CY9")
	CY9->(DbSetOrder(1))
	If CY9->(!DbSeek(xFilial("CY9")+cOp+cIdOper))
		SetRestFault(400, EncodeUTF8(STR0030)) //"Operações da Ordem não cadastrada."         
		lGet := .F.
	EndIf
EndIf

If lGet
	//Verifica se existe apontamento de produção em aberto para outro split
	If !SFCApAbNSp(cMaq,cSplit,1,@cMsgErro,cOp)
		lGet := .F.
		SetRestFault(400, EncodeUTF8(cMsgErro))
	EndIf
EndIf

If lGet
	//Verifica se existe apontamento de produção em aberto do split
	If !SFCApAbeSp(cOp, cIdOper, cSplit, ,1,@cMsgErro)
		cNRSQRP := ' '
		lGet := ConSeqApo(cOp, cIdOper, cSplit, @cNRSQRP)

		If !lGet 
			SetRestFault(400, EncodeUTF8(STR0034)) //"Não foi possível localizar a sequência do apontamento de inicio para realizar a finalização."
		Else
			lExistIni := .T.
			lStatus   := .F.
		EndIf
	EndIf
EndIf
		
If lGet .And. lExistIni
	DbSelectArea("CYV")
	CYV->(DbSetOrder(1))
	If CYV->(!DbSeek(xFilial("CYV")+cNRSQRP))					
		SetRestFault(400, EncodeUTF8(STR0035)) //"Serial do apontamento de inicio não cadastrado."
		lGet := .F.
	EndIf

	If lGet
		//Se existir apontamento em aberto para o split
		//Verificar se está aberto para a máquina
		If CYV->CYV_CDMQ != cMaq
			SetRestFault(400, EncodeUTF8(STR0044)) //"Máquina que iniciou o apontamento difere da máquina corrente. Para retomar o apontamento deve ser selecionada a máquina que iniciou o apontamento."
			lGet := .F.
		EndIf
	EndIf

	If lGet
		//Se for a mesma máquina retornar a hora de início e fim	
		cDataIniRe := DTOC(CYV->CYV_DTRPBG)
		cTimeIniRe := CYV->CYV_HRRPBG	
	EndIf
Else
	cDataIniRe := ' '
	cTimeIniRe := ' '
EndIf

If lGet
	oJson := JsonObject():New() 
	
	oJson['MachineCode']           := ::MachineCode
	oJson['ProductionOrderNumber'] := ::ProductionOrderNumber
	oJson['ActivityID']            := ::ActivityID
	oJson['Split']                 := ::Split
	oJson['StartReportDateTime']   := cDataIniRe    //Data Início
	oJson['StartReportTime']       := cTimeIniRe    //Hora Início
	oJson['Status']                := lStatus
	
	::SetResponse(EncodeUTF8(oJson:toJson()))
EndIf

Return lGet

WSMETHOD GET OperationTime WSRECEIVE ProductionOrderNumber,ActivityID,Split  WSSERVICE ProductionAppointment

Local lGet     := .T.
Local oJson
Local nTmpPad  := 0
Local nTmpApon := 0
Local nTmpTot  := 0

// define o tipo de retorno do método
::SetContentType("application/json")


If Empty(::ProductionOrderNumber)
	SetRestFault(400, EncodeUTF8(STR0003)) 	//"Ordem de Produção não informada"
	lGet := .F.
EndIf

If lGet
	If Empty(::ActivityID)
		SetRestFault(400, EncodeUTF8(STR0024)) //"Não foi informado o ID da operação."
		lGet := .F.	
	EndIf
EndIf

If lGet
	If Empty(::Split)
		SetRestFault(400, EncodeUTF8(STR0027)) //"Não foi informado o split."
		lGet := .F.	
	EndIf
EndIf

If lGet
	cOp 	   := PadR(::ProductionOrderNumber,TamSX3("CYV_NRORPO")[1])
	cIdOper    := PadR(::ActivityID,TamSX3("CYV_CDAT")[1])
	cSplit	   := PadR(::Split,TamSX3("CYV_IDATQO")[1])

	DbSelectArea("CYY")
	CYY->(DbSetOrder(1))
	If CYY->(DbSeek(xFilial("CYY")+cOp+cIdOper+cSplit))
		//CYY->CYY_QTPAAT - Tempo padrão total para produzir o Split
		//CYY->CYY_QTAT   - Quantidade Prevista no Split

		//Tempo padrão - Tempo que levará para produzir uma unidade do Split.
		nTmpPad  := (CYY->CYY_QTPAAT / CYY->CYY_QTAT)
	
		//Tempo apontado - Tempo já apontado no Split
		nTmpApon := CYY->CYY_QTTEAT

		//Tempo total - Tempo padrão total para produzir o Split
		nTmpTot  := CYY->CYY_QTPAAT

	Else		
		SetRestFault(400, EncodeUTF8(STR0029)) //"Split não cadastrado."
		lGet := .F.	
	EndIf
EndIf

If lGet
	oJson := JsonObject():New() 
		
	oJson['ProductionOrderNumber'] := ::ProductionOrderNumber
	oJson['ActivityID']            := ::ActivityID
	oJson['Split']                 := ::Split
	oJson['OperationUnitTime']     := nTmpPad
	oJson['TimeAppointed']         := nTmpApon
	oJson['OpTimeInt']             := nTmpTot
	
	::SetResponse(EncodeUTF8(oJson:toJson()))
EndIf

Return lGet


WSMETHOD POST mata250 WSSERVICE ProductionAppointment
	Local aArrayRet  := {}
	Local aCampos    := {}
	local aMata250   := {}
	Local cBody      := " "
	Local cMsgPend   := " "
	Local cMsgCC     := " "
	Local cResponse  := " "
	local dDatalote  := Nil
	local dDatemis   := Nil
	Local lApoPend   := SuperGetMV("MV_APPENMO",.F.,1)
	Local lErroCC    := .F.
	Local lGanhoPr   := SuperGetMV("MV_GANHOPR",.F.,.T.)
	Local lPercPrm   := SuperGetMV("MV_PERCPRM",.F., 0)
	Local lPost      := .T.
	Local nDiferenca := 0
	Local nI         := 0
	Local nNumero    := 0
	Local nPerda     := 0
	Local nQtdApon   := 0
	Local oJson      := JsonObject():New()

	Private cProgMt250     := 'APIREST-MATA250'
	Private l250Auto 	   := .T.
	Private l240:=.F.,l250 :=.T.,l241:=.F.,l242:=.F.,l261:=.F.,l185:=.F.,l650:=.F.,l680:=.F.,l681:=.F.
	Private lMSErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private lPerdInf       := SuperGetMV("MV_PERDINF",.F.,.F.)

	cBody := ::GetContent()
	
	LogMsg('POST_MATA250', 0, 0, 1, '', '', cBody)

	If __lPEPosAP == Nil
		__lPEPosAP := ExistBlock("PApPosAp")
	EndIf

	If oJson:fromJson( cBody ) <> Nil
		SetRestFault(400, EncodeUTF8(STR0006)) //"Parâmetros do apontamento não enviados ou inválidos."                                                                                                                                                                                                                                                                                                                                                                                                                                                              
		lPost := .F.

	ElseIf Empty(oJson['ProductionOrderNumber'])
		SetRestFault(400, EncodeUTF8(STR0003)) //"Ordem de Produção não informada."
		lPost := .F.

	ElseIf Empty(oJson['MovimentType']) 
		SetRestFault(400, EncodeUTF8(STR0007)) //"Tipo de movimento não informada."
		lPost := .F.

	ElseIf oJson['appointmentType'] <> "1"
		SetRestFault(400, EncodeUTF8(STR0005)) //"O tipo de apontamento do formulário deve ser do tipo Apontamento simplificado (MATA250)"
		lPost := .F.

	ElseIf Empty(oJson['Part_Total'])
		SetRestFault(400, EncodeUTF8(STR0008)) //"Não foi informado se o apontamento é parcial/total"
		lPost := .F.

	ElseIf Empty(oJson['ApprovedQuantity']) .And. empty(oJson['ScrapQuantity'])
		SetRestFault(400, EncodeUTF8(STR0009)) //"Não foi informado a quantidade a ser apontada"
		lPost := .F.
	EndIf

	If lPost	 	
		AADD(aMata250, {"D3_TM", oJson['MovimentType'         ], Nil})
		AADD(aMata250, {"D3_OP", oJson['ProductionOrderNumber'], Nil})
		
		//Quando a quantidade vier em caracter, será efetuada a conversão .
		If !Empty(oJson['ApprovedQuantity']) 
			If ValType(oJson['ApprovedQuantity']) == "C"
				If AT("," , oJson['ApprovedQuantity']) > 0
					nQtdApon := Val(StrTran(oJson['ApprovedQuantity'],",",".")) 
				Else
					nQtdApon := Val(oJson['ApprovedQuantity'])
				EndIf
			Else
				nQtdApon := oJson['ApprovedQuantity']
			EndIf
		
			AADD(aMata250, {"D3_QUANT", nQtdApon, Nil})
		Endif
		
		If !Empty(oJson['ItemCode'])
			AADD(aMata250, {"D3_COD", oJson['ItemCode'], Nil})
		EndIf

		If !Empty(oJson['WarehouseCode'])
			AADD(aMata250, {"D3_LOCAL", oJson['WarehouseCode'], Nil})
		EndIf

		If !empty(oJson['UnitOfMeasureCode'])
			AADD(aMata250, {"D3_UM", oJson['UnitOfMeasureCode'], Nil})
		EndIf

		If !Empty(oJson['DocumentCode'])
			AADD(aMata250, {"D3_DOC", oJson['DocumentCode'], Nil})
		EndIf

		If !empty(oJson['UnitOfMeasureCode'])
			AADD(aMata250, {"D3_UM", oJson['UnitOfMeasureCode'], Nil})
		EndIf
		
		If !Empty(oJson['StartReportDateTime'])
			dDatemis := CTOD(oJson['StartReportDateTime'])
			AADD(aMata250, {"D3_EMISSAO", dDatemis, Nil})
		EndIf
		
		If !Empty(oJson['LotPotency'])
			If ValType(oJson['LotPotency']) == "C"

				If AT("," , oJson['LotPotency']) > 0
					nNumero := Val(StrTran(oJson['LotPotency'],",",".")) 
				Else
					nNumero := Val(oJson['LotPotency'])
				EndIf
			Else
				nNumero := oJson['LotPotency']
			EndIf
			AADD(aMata250, {"D3_POTENCI",nNumero, Nil})
		EndIf
		
		If !Empty(oJson['CostCenter'])
			AADD(aMata250, {"D3_CC", oJson['CostCenter'], Nil})
		EndIf
		
		If !Empty(oJson['LedgerAcct'])
			AADD(aMata250, {"D3_CONTA", oJson['LedgerAcct'], Nil})
		EndIf 
		
		If !Empty(oJson['UnitOfMeasureCode2'])
			AADD(aMata250, {"D3_SEGUM", oJson['UnitOfMeasureCode2'], Nil})
		EndIf
		
		If !Empty(oJson['LotCode'])
			AADD(aMata250, {"D3_LOTECTL", oJson['LotCode'], Nil})
		EndIf
		
		If !empty(oJson['LotDueDate'])
			dDatalote := CTOD(oJson['LotDueDate'])
			AADD(aMata250, {"D3_DTVALID", dDatalote, Nil})
		EndIf

		//Quando a quantidade vier em caracter, será efetuada a conversão .
		If !Empty(oJson['UnitOfMeasureCode2Quantity'])
			If ValType(oJson['UnitOfMeasureCode2Quantity']) == "C"

				If AT("," , oJson['UnitOfMeasureCode2Quantity']) > 0
					nNumero := Val(StrTran(oJson['UnitOfMeasureCode2Quantity'],",",".")) 
				Else
					nNumero := Val(oJson['UnitOfMeasureCode2Quantity'])
				EndIf
			Else
				nNumero := oJson['UnitOfMeasureCode2Quantity']
			EndIf
			AADD(aMata250, {"D3_QTSEGUM", nNumero, Nil})
		EndIf

		If !Empty(oJson['ScrapQuantity'])
			If ValType(oJson['ScrapQuantity']) == "C"
				If AT("," , oJson['ScrapQuantity']) > 0
					nPerda := Val(StrTran(oJson['ScrapQuantity'],",",".")) 
				Else
					nPerda := Val(oJson['ScrapQuantity'])
				EndIf
			Else
				nPerda := oJson['ScrapQuantity']
			EndIf
		
			AADD(aMata250, {"D3_PERDA", nPerda, Nil})
		EndIf

		If !Empty(oJson['Service'])
			AADD(aMata250, {"D3_SERVIC", oJson['Service'], Nil})
		EndIf
		
		AADD(aMata250, {"D3_PARCTOT", oJson['Part_Total'], Nil})

		//Para gerar a produção a maior quando o percentual está maior que zero
		If lGanhoPr == .F. .And. lPercPrm > 0 
			SC2->(dbSetOrder(1))
			SC2->(dbSeek(xFilial("SC2") + oJson['ProductionOrderNumber']))

			If (SC2->C2_QUANT - SC2->C2_QUJE - If(lPerdInf,0,SC2->C2_PERDA)) < (nQtdApon + If(lPerdInf,0,nPerda) )
				nDiferenca := nQtdApon + If(lPerdInf,0,nPerda) - (SC2->C2_QUANT - SC2->C2_QUJE - If(lPerdInf,0,SC2->C2_PERDA)) 
				AADD(aMata250, {"D3_QTMAIOR", nDiferenca, Nil})  
			EndIf
		EndIf

		AADD(aMata250, {"PENDENTE", lApoPend, Nil})  

		// INICIO CAMPOS CUSTOMIZADOS 250
		BuscaCaCus(oJson, @aCampos, @cMsgCC, @lErroCC, '1')

		If lErroCC
			SetRestFault(400, EncodeUTF8(cMsgCC))
			lPost := .F.
		EndIf

		If lPost
			For nI := 1 TO 25
				If aCampos[nI,4]
					cCampoCC := aCampos[nI,2]
					cValorCC := aCampos[nI,3]

					ValidaCC(nI, cValorCC, @cMsgCC,  @lErroCC, cCampoCC)

					If lErroCC
						SetRestFault(400, EncodeUTF8(cMsgCC))
						lPost := .F.
						Exit
					EndIf

					FormataCC(nI, @cValorCC, cCampoCC)
					
					AADD(aMata250, {cCampoCC, cValorCC, Nil})
				EndIf
			Next nI
		EndIf	
		// FIM CAMPOS CUSTOMIZADOS 250

		If lPost

			If __lPEPosAP
				aMata250 := ExecBlock("PApPosAp", .F., .F., {"1", aMata250, Nil, Nil, oJson['CodeForm']})
			EndIf
			
			//Chamar EXECAUTO
			msExecAuto({|x,y| MATA250(x,y)}, aMata250, 3)

			If lMSErroAuto
				If lApoPend == "3"
					oJson['Status'] := (STR0040) //'Apontamento enviado para pendente com sucesso'
					oJson['idAppointment'] := xFilial("T4K")+T4K->(T4K_COD+T4K_LOCAL+T4K_SEQ)
					oJson['OpClose'] := .F.
				
					//saldo da ordem após o apontamento
					SC2->(dbSetOrder(1))
					SC2->(dbSeek(xFilial("SC2") + oJson['ProductionOrderNumber']))

					oJson['ReportQuantity'] := SC2->C2_QUANT - SC2->C2_QUJE - If(lPerdInf,0,SC2->C2_PERDA) 
					::SetResponse(EncodeUTF8(oJson:toJson()))
				Else
					lPost := .F.
					If lApoPend == "2"
						cMsgPend := STR0012
					Endif
				
					SetRestFault(400, EncodeUTF8(cMsgPend+FormataErro()))
				Endif
			Else
				oJson['Status'] := (STR0041) //'Apontamento efetuado com sucesso'
				oJson['idAppointment'] := xFilial("SD3")+SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ)
				
				//saldo da ordem após o apontamento
				SC2->(dbSetOrder(1))
				SC2->(dbSeek(xFilial("SC2")+ oJson['ProductionOrderNumber']))
			
				If !Empty(SC2->C2_DATRF) 			
					oJson['OpClose'] := .T.
				Else
					oJson['OpClose'] := .F.
				EndIf
			 
		   		oJson['ReportQuantity'] := SC2->C2_QUANT - SC2->C2_QUJE - If(lPerdInf,0,SC2->C2_PERDA) 

				cResponse := oJson:toJson()
				If ExistBlock("PApAposAp")
					aArrayRet := ExecBlock("PApAposAp", .F., .F., {SD3->(Recno()), oJson, cResponse})

					If !aArrayRet[1,1] 
						SetRestFault(400, EncodeUTF8(aArrayRet[1,2]+FormataErro()))
						lPost := .F.
					EndIf
				EndIf
				
				If lPost
					::SetResponse(EncodeUTF8(cResponse))
				EndIf
			EndIf	
		EndIf	
	EndIf

	FreeObj(oJson)
	aSize(aMata250, 0)
	aSize(aCampos , 0)

Return lPost

WSMETHOD POST mata681 WSSERVICE ProductionAppointment
	Local aCampos    := {}
	local aMata681   := {}
	Local cBody      := " "
	Local cMsgCC     := " "
	Local cMsgPend   := " " 
	local dDataApont := Nil
	Local lPost      := .T.
	Local lApoPend   := SuperGetMV("MV_APPENMO",.F.,"1")
	Local lErroCC    := .F.
	Local lGanhoPr   := SuperGetMV("MV_GANHOPR",.F.,.T.)
	Local lPercPrm   := SuperGetMV("MV_PERCPRM",.F., 0)
	Local nI         := 0
	Local nDiferenca := 0
	Local nNumero    := 0
	Local nQtdApon   := 0
	Local nPerda     := 0
	Local oJson      := JsonObject():New()

	Private cProgMt681     := 'APIREST-MATA681'
	Private l681Auto 	   := .T.
	Private l240:=.F.,l250 :=.F.,l241:=.F.,l242:=.F.,l261:=.F.,l185:=.F.,l650:=.F.,l680:=.F.,l681:=.T.
	Private lMSErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private lPerdInf       := SuperGetMV("MV_PERDINF",.F.,.F.)
	
	Pergunte("MTA680",.F.)
	//mv_par04 ( 1 - Permite Apontar Tempo | 2 - Não Permite Apontar Tempo (Obrigar informar QTD))
	lApoTempo := Iif(mv_par04 == 1,.T.,.F.)

	cBody := ::GetContent()
	
	If __lPEPosAP == Nil
		__lPEPosAP := ExistBlock("PApPosAp")
	EndIf

	LogMsg('POST_MATA681', 0, 0, 1, '', '', cBody)

	If oJson:fromJson( cBody ) <> Nil
		SetRestFault(400, EncodeUTF8(STR0006)) //"Parâmetros do apontamento não enviados ou inválidos."                                                                                                                                                                                                                                                                                                                                                                                                                                                              
		lPost := .F.

	ElseIf Empty(oJson['ProductionOrderNumber'])
		SetRestFault(400, EncodeUTF8(STR0003)) //"Ordem de Produção não informada."
		lPost := .F.

	ElseIf Empty(oJson['ActivityCode']) 
		SetRestFault(400, EncodeUTF8(STR0010)) //"Operação não informada."
		lPost := .F.

	ElseIf oJson['appointmentType'] <> "3"
		SetRestFault(400, EncodeUTF8(STR0011)) //"O tipo de apontamento do formulário deve ser do tipo Apontamento por Operação (MATA681)"
		lPost := .F.

	ElseIf Empty(oJson['Part_Total'])
		SetRestFault(400, EncodeUTF8(STR0008)) //"Não foi informado se o apontamento é parcial/total"
		lPost := .F.

	ElseIf Empty(oJson['ApprovedQuantity']) .And. Empty(oJson['ScrapQuantity']) .And. !lApoTempo
		SetRestFault(400, EncodeUTF8(STR0009)) //"Não foi informado a quantidade a ser apontada"
		lPost := .F.
	EndIf

	If lPost
		//Quando a quantidade vier em caracter, será efetuada a conversão .
		nQtdApon := 0
		If !Empty(oJson['ApprovedQuantity']) 
			If ValType(oJson['ApprovedQuantity']) == "C"
				If AT("," , oJson['ApprovedQuantity']) > 0
					nQtdApon := Val(StrTran(oJson['ApprovedQuantity'],",",".")) 
				Else
					nQtdApon := Val(oJson['ApprovedQuantity'])
				EndIf
			Else
				nQtdApon := oJson['ApprovedQuantity']
			EndIf
		EndIf
	EndIf

	If lPost
		nPerda := 0
		If !Empty(oJson['ScrapQuantity'])
			If ValType(oJson['ScrapQuantity']) == "C"
				If AT("," , oJson['ScrapQuantity']) > 0
					nPerda := Val(StrTran(oJson['ScrapQuantity'],",",".")) 
				Else
					nPerda := Val(oJson['ScrapQuantity'])
				EndIf
			Else
				nPerda := oJson['ScrapQuantity']
			EndIf
		EndIf
	EndIf

	If lPost
		If !lApoTempo //Não perite apontar Tempo. Obrigar informar QTD > 0
			If nQtdApon == 0 .And. nPerda == 0
				SetRestFault(400, EncodeUTF8(STR0009)) //"Não foi informado a quantidade a ser apontada"
				lPost := .F.
			EndIF
		EndIf
	EndIf

	If lPost
		AADD(aMata681, {"H6_OP", oJson['ProductionOrderNumber'], Nil})
		
		If !Empty(oJson['ItemCode'])
			AADD(aMata681, {"H6_PRODUTO", oJson['ItemCode'], Nil})
		EndIf
		
		If !Empty(oJson['ActivityCode'])
			AADD(aMata681, {"H6_OPERAC", oJson['ActivityCode'], Nil})
		EndIf
		
		If !Empty(oJson['MachineCode'])
			AADD(aMata681, {"H6_RECURSO", oJson['MachineCode'], Nil})
		EndIf
		
		If !Empty(oJson['ToolCode'])
			AADD(aMata681, {"H6_FERRAM", oJson['ToolCode'], Nil})
		EndIf
		
		If !Empty(oJson['StartReportDateTime'])
			dDataApont := CTOD(oJson['StartReportDateTime'])
			AADD(aMata681, {"H6_DATAINI", dDataApont, Nil})
		EndIf
		
		If !Empty(oJson['StartReportTime'])
			AADD(aMata681, {"H6_HORAINI", oJson['StartReportTime'], Nil})
		EndIf 
		
		If !Empty(oJson['EndReportDateTime'])
			dDataApont := CTOD(oJson['EndReportDateTime'])
			AADD(aMata681, {"H6_DATAFIN", dDataApont, Nil})
		EndIf 
		
		If !Empty(oJson['EndReportTime'])
			AADD(aMata681, {"H6_HORAFIN", oJson['EndReportTime'], Nil})
		EndIf 

		AADD(aMata681, {"H6_QTDPROD", nQtdApon, Nil})
		AADD(aMata681, {"H6_QTDPERD", nPerda,   Nil})
		AADD(aMata681, {"H6_PT", oJson['Part_Total'], Nil})
		
		If !Empty(oJson['ReportDateTime'])
			dDataApont := CTOD(oJson['ReportDateTime'])
			AADD(aMata681, {"H6_DTAPONT", dDataApont, Nil})
		EndIf 

		If !Empty(oJson['Split'])
			AADD(aMata681, {"H6_DESDOBR", oJson['Split'], Nil})
		EndIf

		If !Empty(oJson['RealTime'])
			AADD(aMata681, {"H6_TEMPO", oJson['RealTime'], Nil})
		EndIf
		
		If !Empty(oJson['LotCode'])
			AADD(aMata681, {"H6_LOTECTL",oJson['LotCode'], Nil})
		EndIf 
		
		If !Empty(oJson['SubLotCode'])
			AADD(aMata681, {"H6_NUMLOTE",oJson['SubLotCode'], Nil})
		EndIf 
		
		If !Empty(oJson['LotDueDate'])
			dDataApont := CTOD(oJson['LotDueDate'])
			AADD(aMata681, {"H6_DTVALID",dDataApont, Nil})
		EndIf 

		If !Empty(oJson['Comments'])
			AADD(aMata681, {"H6_OBSERVA", oJson['Comments'], Nil})
		EndIf

		If !Empty(oJson['OperatorCode'])
			AADD(aMata681, {"H6_OPERADO", oJson['OperatorCode'], Nil})
		EndIf

		If !Empty(oJson['AlternativeSequence'])
			AADD(aMata681, {"H6_SEQ", oJson['AlternativeSequence'], Nil})
		EndIf

		//Quando a quantidade vier em caracter, será efetuada a conversão .
		If !Empty(oJson['UnitOfMeasureCode2Quantity'])
			If ValType(oJson['UnitOfMeasureCode2Quantity']) == "C"

				If AT("," , oJson['UnitOfMeasureCode2Quantity']) > 0
					nNumero := Val(StrTran(oJson['UnitOfMeasureCode2Quantity'],",",".")) 
				Else
					nNumero := Val(oJson['UnitOfMeasureCode2Quantity'])
				EndIf
			Else
				nNumero := oJson['UnitOfMeasureCode2Quantity']
			EndIf
			AADD(aMata681, {"H6_QTDPRO2", nNumero, Nil})
		EndIf

		If !Empty(oJson['LotPotency'])
			If ValType(oJson['LotPotency']) == "C"

				If AT("," , oJson['LotPotency']) > 0
					nNumero := Val(StrTran(oJson['LotPotency'],",",".")) 
				Else
					nNumero := Val(oJson['LotPotency'])
				EndIf
			Else
				nNumero := oJson['LotPotency']
			EndIf
			AADD(aMata681, {"H6_POTENCI", nNumero, Nil})
		EndIf

		If !Empty(oJson['Apportionment'])
			If ValType(oJson['Apportionment']) == "C"

				If AT("," , oJson['Apportionment']) > 0
					nNumero := Val(StrTran(oJson['Apportionment'],",",".")) 
				Else
					nNumero := Val(oJson['Apportionment'])
				EndIf
			Else
				nNumero := oJson['Apportionment']
			EndIf
			AADD(aMata681, {"H6_RATEIO", nNumero, Nil})
		EndIf

		If !Empty(oJson['WarehouseCode'])
			AADD(aMata681, {"H6_LOCAL", oJson['WarehouseCode'], Nil})
		EndIf

		//Para gerar a produção a maior quando o percentual está maior que zero
		If lGanhoPr == .F. .And. lPercPrm > 0 
			SC2->(dbSetOrder(1))
			SC2->(dbSeek(xFilial("SC2") + oJson['ProductionOrderNumber']))

			If (SC2->C2_QUANT - SC2->C2_QUJE - If(lPerdInf,0,SC2->C2_PERDA)) < (nQtdApon + If(lPerdInf,0,nPerda) )
				nDiferenca := nQtdApon + If(lPerdInf,0,nPerda) - (SC2->C2_QUANT - SC2->C2_QUJE - If(lPerdInf,0,SC2->C2_PERDA)) 
				AADD(aMata681, {"H6_QTMAIOR", nDiferenca, Nil})  
			EndIf
		EndIf   

		AADD(aMata681, {"PENDENTE", lApoPend, Nil})

		// INICIO CAMPOS CUSTOMIZADOS 681
		BuscaCaCus(oJson, @aCampos, @cMsgCC, @lErroCC, '3')

		If lErroCC
			SetRestFault(400, EncodeUTF8(cMsgCC))
			lPost := .F.
		EndIf

		If lPost
			For nI := 1 TO 25
				If aCampos[nI,4]
					cCampoCC := aCampos[nI,2]
					cValorCC := aCampos[nI,3]

					ValidaCC(nI, cValorCC, @cMsgCC,  @lErroCC, cCampoCC)

					If lErroCC
						SetRestFault(400, EncodeUTF8(cMsgCC))
						lPost := .F.
						Exit
					EndIf

					FormataCC(nI, @cValorCC, cCampoCC)
					
					AADD(aMata681, {cCampoCC, cValorCC, Nil})
				EndIf
			Next nI
		EndIf	
		// FIM CAMPOS CUSTOMIZADOS 681

		If lPost

			If __lPEPosAP
				aMata681 := ExecBlock("PApPosAp", .F., .F., {"3", aMata681, Nil, Nil, oJson['CodeForm']})
			EndIf
			
			//Chamar EXECAUTO
			msExecAuto({|x,y| MATA681(x,y)},aMata681,3)

			If lMSErroAuto
				If lApoPend == "3"
					oJson['Status'] := (STR0040) //'Apontamento enviado para pendente com sucesso'
					oJson['idAppointment'] := xFilial("T4K")+T4K->(T4K_COD+T4K_LOCAL+T4K_SEQ)
					oJson['OpClose'] := .F.
				
					//saldo da ordem após o apontamento
					SC2->(dbSetOrder(1))
					SC2->(dbSeek(xFilial("SC2")+ oJson['ProductionOrderNumber']))

					oJson['ReportQuantity'] := SC2->C2_QUANT - SC2->C2_QUJE - If(lPerdInf,0,SC2->C2_PERDA) 
					::SetResponse(EncodeUTF8(oJson:toJson()))
				Else
					lPost := .F.
					If lApoPend == "2"
						cMsgPend := STR0012
					Endif
				
					SetRestFault(400, EncodeUTF8(cMsgPend+FormataErro()))
				Endif
			Else
				oJson['Status'] := (STR0041) //'Apontamento efetuado com sucesso'
				oJson['idAppointment'] := xFilial("SH6")+SH6->(H6_PRODUTO+H6_LOCAL+H6_IDENT)
				
				//saldo da ordem após o apontamento
				SC2->(dbSetOrder(1))
				SC2->(dbSeek(xFilial("SC2")+ oJson['ProductionOrderNumber']))
			
				If !Empty(SC2->C2_DATRF) 			
					oJson['OpClose'] := .T.
				Else
					oJson['OpClose'] := .F.
				EndIf
			 
		   		oJson['ReportQuantity'] := SC2->C2_QUANT - SC2->C2_QUJE - If(lPerdInf,0,SC2->C2_PERDA) 
				::SetResponse(EncodeUTF8(oJson:toJson()))
			EndIf
		EndIf
	EndIf

	FreeObj(oJson)
	aSize(aCampos , 0)
	aSize(aMata681, 0)

Return lPost

WSMETHOD POST sfca314 WSSERVICE ProductionAppointment

	Local aCYPArea  := {}
	Local aErro     := {}
	Local aCampos   := {}
	Local cMsgCC    := " "
	Local cBody     := " "
	Local cIniFim   := ""
	Local lPost     := .T.
	Local lErroCC   := .F.
	Local nI        := 0
	Local nPropProd := 0
	Local oModel    := Nil
	Local oModelCY0 := Nil
	Local oModelCYW := Nil
	Local oModelCZ0 := Nil
	Local oModelCZP := Nil
	Local oJson     := JsonObject():New()
	
	Private cPROG          := 'APIREST'
	Private cProgMtSFC     := 'APIREST-SFCA314'
	Private cTipApon       := ' '
    Private lPerdInf       := SuperGetMV("MV_PERDINF",.F.,.F.)
	Private lMSErroAuto    := .F.
	Private lAutoErrNoFile := .T.	
	Private _IsSFCA318     := .F.
	Private _IsPost314     := .T.
	Private _MaqSFC310

	cBody := ::GetContent()

	LogMsg('POST_SFCA314', 0, 0, 1, '', '', cBody)

	If oJson:fromJson( cBody ) <> Nil
		SetRestFault(400, EncodeUTF8(STR0006)) //"Parâmetros do apontamento não enviados ou inválidos."                                                                                                                                                                                                                                                                                                                                                                                                                                                              
		lPost := .F.
	EndIf

	If lPost
		If oJson['appointmentType'] <> "4"
			SetRestFault(400, EncodeUTF8(STR0013)) //"O tipo de apontamento do formulário deve ser Produção Chão de Fábrica."
			lPost := .F.
		EndIf
	EndIf

	If __lPEPosAP == Nil
		__lPEPosAP := ExistBlock("PApPosAp")
	EndIf

	If lPost
		cIniFim := oJson['StartEndReport']
		If !Empty(cIniFim)
			If cIniFim != 'I' .And. cIniFim != 'F' .And. cIniFim != 'A'
				SetRestFault(400, EncodeUTF8(STR0033)) //"O indicador de apontamento Início e Fim deve ser I(início), F(fim) ou A(abandonar)."
				lPost := .F.
			Else
				cTipApon := cIniFim
			EndIf
		EndIf
	EndIf

	If lPost
		If Empty(oJson['ProductionOrderNumber'])
			SetRestFault(400, EncodeUTF8(STR0003)) //"Ordem de Produção não informada."
			lPost := .F.		
		ElseIf Empty(oJson['MachineCode']) 
			SetRestFault(400, EncodeUTF8(STR0014)) //"Não foi informada a máquina."
			lPost := .F.
		ElseIf Empty(oJson['Split']) 
			SetRestFault(400, EncodeUTF8(STR0027)) //"Não foi informado o split."
			lPost := .F.		
		ElseIf Empty(oJson['ActivityID']) 
			SetRestFault(400, EncodeUTF8(STR0024)) //"Não foi informado o ID da operação."
			lPost := .F.			
		ElseIf Empty(oJson['StartReportDateTime']) .And. cIniFim != 'F' .And. cIniFim != 'A' 
			SetRestFault(400, EncodeUTF8(STR0015)) //"Não foi informada a data de início da produção."
			lPost := .F.
		ElseIf Empty(oJson['StartReportTime']) .And. cIniFim != 'F' .And. cIniFim != 'A'
			SetRestFault(400, EncodeUTF8(STR0016)) //"Não foi informada a hora de início da produção."
			lPost := .F.
		ElseIf Empty(oJson['EndReportDateTime']) .And. cIniFim != 'I' .And. cIniFim != 'A'
			SetRestFault(400, EncodeUTF8(STR0017)) //"Não foi informada a data fim da produção."
			lPost := .F.
		ElseIf Empty(oJson['EndReportTime']) .And. cIniFim != 'I' .And. cIniFim != 'A'
			SetRestFault(400, EncodeUTF8(STR0018)) //"Não foi informada a hora fim da produção."
			lPost := .F.
		EndIf
	EndIf

	If lPost
		cOp 	   := PadR(oJson['ProductionOrderNumber'], TamSX3("CYV_NRORPO")[1])
		cOper 	   := PadR(oJson['ActivityCode'         ], TamSX3("CYV_CDAT"  )[1])
		cIdOper    := PadR(oJson['ActivityID'           ], TamSX3("CYV_IDAT"  )[1])
		cSplit	   := PadR(oJson['Split'                ], TamSX3("CYV_IDATQO")[1])
		cMaq       := PadR(oJson['MachineCode'          ], TamSX3("CYV_CDMQ"  )[1])
		cItem      := PadR(oJson['ItemCode'             ], TamSX3("CYV_CDACRP")[1])
		cTurno     := PadR(oJson['ProductionShiftCode'  ], TamSX3("CYV_CDTN"  )[1])
		cDoc       := PadR(oJson['DocumentCode'         ], TamSX3("CYV_NRDO"  )[1])
		cSerieDoc  := PadR(oJson['DocumentSeries'       ], TamSX3("CYV_NRSR"  )[1])
		cDeposito  := PadR(oJson['WarehouseCode'        ], TamSX3("CYV_CDDP"  )[1])
		cLoteSerie := PadR(oJson['LotCode'              ], TamSX3("CYV_CDLOSR")[1])
		cValLote   := PadR(oJson['LotDueDate'           ], TamSX3("CYV_DTVDLO")[1])
		cFerram    := PadR(oJson['ToolCode'             ], TamSX3("CYV_CDFEPO")[1])
		cOperador  := PadR(oJson['OperatorName'         ], TamSX3("CYW_CDOE"  )[1])
		cEquipe    := PadR(oJson['ProductionTeamCode'   ], TamSX3("CYW_CDOE"  )[1])
		
		//Quando a quantidade vier em caracter, será efetuada a conversão .
		If !Empty(oJson['ApprovedQuantity'])
			If ValType(oJson['ApprovedQuantity']) == "C"
				If AT("," , oJson['ApprovedQuantity']) > 0
					nQuant := Val(StrTran(oJson['ApprovedQuantity'],",",".")) 
				Else
					nQuant := Val(oJson['ApprovedQuantity'])
				EndIf
			Else
				nQuant := oJson['ApprovedQuantity']
			EndIf
		Else
			nQuant := 0
		EndIf
        
		//DATAS DE PRODUÇÃO
		If !Empty(oJson['StartReportDateTime'])
			cDataIniRe := CTOD(oJson['StartReportDateTime'])
		EndIf
		If !Empty(oJson['EndReportDateTime'])
			cDataFimRe := CTOD(oJson['EndReportDateTime'])
		EndIf
		cTimeIniRe := oJson['StartReportTime']
		cTimeFimRe := oJson['EndReportTime']
		
		//DATAS DE SETUP
		If !Empty(oJson['StartSetupDateTime'])
			cDataIniSe := CTOD(oJson['StartSetupDateTime'])
		Else
			cDataIniSe := ' '
		EndIf
		If !Empty(oJson['EndSetupDateTime'])
			cDataFimSe := CTOD(oJson['EndSetupDateTime'])
		Else
			cDataFimSe := ' '
		EndIf
		cTimeIniSe := oJson['StartSetupTime']
		cTimeFimSe := oJson['EndSetupTime']
		cCodSetup  := PadR(oJson['SetupCode'],TamSX3("CYV_CDSU")[1])

		If !Empty(cDataIniSe) .Or. !Empty(cDataFimSe) .Or. !Empty(cTimeIniSe) .Or. !Empty(cTimeFimSe) .Or. !Empty(cCodSetup)
			If Empty(cDataIniSe) 
				SetRestFault(400, EncodeUTF8(STR0019)) //"Não foi informada a data de início do setup."
				lPost := .F.			
			ElseIf Empty(cDataFimSe) 
				SetRestFault(400, EncodeUTF8(STR0020)) //"Não foi informada a data final do setup."
				lPost := .F.		
			ElseIf Empty(cTimeIniSe)
				SetRestFault(400, EncodeUTF8(STR0021)) //"Não foi informada a hora de início do setup."
				lPost := .F.		
			ElseIf Empty(cTimeFimSe) 
				SetRestFault(400, EncodeUTF8(STR0022)) //"Não foi informada a hora final do setup."
				lPost := .F.					
			ElseIf Empty(cCodSetup)
				SetRestFault(400, EncodeUTF8(STR0023)) //"Não foi informado o código do setup."
				lPost := .F.					
			EndIf
		EndIf
	EndIf

	If lPost
		If (cIniFim != 'I' .And. cIniFim != 'A') .Or. Empty(cIniFim) //Apontamento normal
			
			//Posicionar no split para ativar o model
			DbSelectArea("CYY")
			CYY->(DbSetOrder(1))
			If CYY->(!DbSeek(xFilial("CYY")+cOp+cIdOper+cSplit))
				SetRestFault(400, EncodeUTF8(STR0029)) //"Split não cadastrado."
   				lPost := .F.
			Endif		
			
			If lPost
				If !Empty(CYY->CYY_CDMQ) .And. CYY->CYY_CDMQ != cMaq
					SetRestFault(400, EncodeUTF8(STR0031)) //"Máquina não pertence ao Id da Operação."         
					lPost := .F.
				EndIf
			EndIf

			If lPost
				DbSelectArea("CY9")
				CY9->(DbSetOrder(1))
				If CY9->(!DbSeek(xFilial("CY9")+cOp+cIdOper))
					SetRestFault(400, EncodeUTF8(STR0043)) //"Operação não cadastrada."
   					lPost := .F.
				EndIf
			EndIf

			If lPost .And. Empty(cOper)				
				cOper := CY9->CY9_CDAT
			EndIf

			If lPost .And. !Empty(cOper)				
				If CY9->CY9_CDAT != cOper
					SetRestFault(400, EncodeUTF8(STR0032)) //"Operação não pertence ao Id da Operação."
					lPost := .F.
				EndIf
			EndIf

			If lPost
				DbSelectArea("CYQ")
				CYQ->(DbSetOrder(1))
				If CYQ->(!DbSeek(xFilial("CYQ")+cOp))
					SetRestFault(400, EncodeUTF8(STR0001)) //"Ordem de Produção não cadastrada" 
					lPost := .F.
				EndIf
			EndIf 

			If lPost .And. cIniFim == 'F'
				//Buscar serial
				cNRSQRP := ' '
				lPost := ConSeqApo(cOp, cIdOper, cSplit, @cNRSQRP)

				If !lPost 
					SetRestFault(400, EncodeUTF8(STR0034)) //"Não foi possível localizar a sequência do apontamento de inicio para realizar a finalização."
				EndIf
			EndIf

			If lPost .And. cIniFim == 'F'
				DbSelectArea("CYV")
				CYV->(DbSetOrder(1))
				If CYV->(!DbSeek(xFilial("CYV")+cNRSQRP))					
					SetRestFault(400, EncodeUTF8(STR0035)) //"Serial do apontamento de inicio não cadastrado."
					lPost := .F.
				Else
					cDataIniRe := CYV->CYV_DTRPBG
					cTimeIniRe := CYV->CYV_HRRPBG					
				EndIf
			EndIf

			If lPost				
				// Instancia o modelo
				oModel := FWLoadModel( "SFCA314" )

				//Limpa variável de erro
				aErro := oModel:GetErrorMessage(.T.)
				aErro := {}

				If cIniFim == 'F'
					oModel:SetOperation( 4 ) //Finalizar apontamento
				Else
					oModel:SetOperation( 3 ) //Incluir apontamento
				EndIf

				If !oModel:Activate()   				
   					lPost := .F.
					aErro := oModel:GetErrorMessage()
     				If !Empty(aErro[6])
        				cMsgErro := oModel:GetErrorMessage()[6]
     				Else
						cMsgErro := (STR0026) //"Ocorreram erros ao realizar o apontamento."
     				EndIf     								
					SetRestFault(400, EncodeUTF8(cMsgErro))   
				EndIf
			EndIf

			If lPost
				//MODELOS
				oModelCY0 := oModel:GetModel( "CY0DETAIL" )               //REFUGO
				oModelCYW := oModel:GetModel( "CYWDETAIL" )               //MAO DE OBRA
				oModelCZ0 := oModel:GetModel( "CZ0DETAIL" )               //FERRAMENTA
				oModelCZP := oModel:GetModel( "CZPDETAIL" )               //RESERVAS - COMPONENTES
			
				oModel:SetValue("CYVMASTER","CYV_NRORPO",cOp)             //OP
         		oModel:SetValue("CYVMASTER","CYV_IDAT"  ,cIdOper) 	      //ID OPERAÇÃO
				oModel:SetValue("CYVMASTER","CYV_CDAT"  ,cOper)           //OPERAÇÃO
         		oModel:SetValue("CYVMASTER","CYV_IDATQO",cSplit)  	      //SPLIT
         		oModel:SetValue("CYVMASTER","CYV_CDMQ"  ,cMaq)            //MAQUINA	
				oModel:SetValue("CYVMASTER","CYV_DTRPBG",cDataIniRe)      //DATA INICIO REPORTE         	
				oModel:SetValue("CYVMASTER","CYV_HRRPBG",cTimeIniRe)      //HORA INICIO REPORTE
         	
				//INFORMAÇÕES SETUP
				If !Empty(cCodSetup)
					oModel:SetValue("CYVMASTER","CYV_DTBGSU",cDataIniSe)  //DATA INICIO SETUP
         			oModel:SetValue("CYVMASTER","CYV_DTEDSU",cDataFimSe)  //DATA FIM SETUP
					oModel:SetValue("CYVMASTER","CYV_HRBGSU",cTimeIniSe)  //HORA INICIO SETUP
         			oModel:SetValue("CYVMASTER","CYV_HREDSU",cTimeFimSe)  //HORA FIM SETUP
					oModel:SetValue("CYVMASTER","CYV_CDSU",cCodSetup)     //CODIGO SETUP
				EndIf

				//QUANTIDADES
				lRet := oModel:SetValue("CYVMASTER","CYV_QTATRP",nQuant)  //QUANTIDADE REPORTADA			
				lRet := oModel:SetValue("CYVMASTER","CYV_QTATAP",nQuant)  //QUANTIDADE APROVADA
				oModel:SetValue("CYVMASTER","CYV_QTATRF",0)               //QUANTIDADE REFUGADA 
				oModel:SetValue("CYVMASTER","CYV_QTATRT",0)               //QUANTIDADE RETRABALHADA
				//aError := oModel:GetModel():GetErrorMessage()
						
				If !Empty(cItem)
					oModel:SetValue("CYVMASTER","CYV_CDACRP",cItem)             //ITEM
				EndIf
				If !Empty(cTurno)
					oModel:SetValue("CYVMASTER","CYV_CDTN",cTurno)             //TURNO
				EndIf
				If !Empty(cDoc)
					oModel:SetValue("CYVMASTER","CYV_NRDO",cDoc)               //Documento
				EndIf
				If !Empty(cSerieDoc)			
					oModel:SetValue("CYVMASTER","CYV_NRSR",cSerieDoc)          //Série Documento
				EndIf
				If !Empty(cDeposito)			
					oModel:SetValue("CYVMASTER","CYV_CDDP",cDeposito)          //Depósito
				EndIf
				If !Empty(cLoteSerie)			
					oModel:SetValue("CYVMASTER","CYV_CDLOSR",cLoteSerie)       //Lote/Serie
				EndIf
				If !Empty(cValLote)			
					oModel:SetValue("CYVMASTER","CYV_DTVDLO",cValLote)         //Data Validade Lote
				EndIf

				oModel:SetValue("CYVMASTER","CYV_DTRPED",cDataFimRe)      //DATA FIM REPORTE
				oModel:SetValue("CYVMASTER","CYV_HRRPED",cTimeFimRe)      //HORA FIM REPORTE

				// INICIO CAMPOS CUSTOMIZADOS SFC
				BuscaCaCus(oJson, @aCampos, @cMsgCC, @lErroCC, '4')

				If lErroCC
					SetRestFault(400, EncodeUTF8(cMsgCC))
					lPost := .F.
				EndIf
			EndIf

			If lPost
				For nI := 1 TO 25
					If aCampos[nI,4]
						cCampoCC := aCampos[nI,2]
						cValorCC := aCampos[nI,3]

						ValidaCC(nI, cValorCC, @cMsgCC,  @lErroCC, cCampoCC)

						If lErroCC
							SetRestFault(400, EncodeUTF8(cMsgCC))
							lPost := .F.
							Exit
						EndIf

						FormataCC(nI, @cValorCC, cCampoCC)
					
						oModel:SetValue("CYVMASTER", cCampoCC, cValorCC)     //Campo Customizado
					EndIf
				Next nI
				// FIM CAMPOS CUSTOMIZADOS SFC
			EndIf
						
			If lPost
				//FERRAMENTA
				If !Empty(cFerram)
					oModelCZ0:SetValue("CZ0_CDFE",cFerram)
				EndIf

				//MAO DE OBRA
				If !Empty(cOperador)
      				oModelCYW:SetValue("CYW_CDOE",cOperador)
				EndIf
				If !Empty(cEquipe)   
      				oModelCYW:SetValue("CYW_CDGROE",cEquipe)
				EndIf
				If !Empty(cOperador) .Or. !Empty(cEquipe)    
   					oModelCYW:SetValue("CYW_DTBGRP",cDataIniRe)
   					oModelCYW:SetValue("CYW_HRBGRP",cTimeIniRe)
   					oModelCYW:SetValue("CYW_DTEDRP",cDataFimRe)
   					oModelCYW:SetValue("CYW_HREDRP",cTimeFimRe)
				EndIf

				//RESERVAS - COMPONENTES
				dbSelectArea('CYP')
				CYP->(dbSetOrder(2))
				If CYP->(dbSeek(xFilial('CYP')+cOp+cOper))

					While CYP->(!EOF()) .AND. CYP->CYP_NRORPO == cOp .AND.;
											  CYP->CYP_CDAT   == cOper 

						nPropProd := CYP->CYP_QTMT / CYQ->CYQ_QTOR
						aCYPArea := CYP->(getArea())
						oModelCZP:AddLine()
						CYP->( RestArea(aCYPArea) )

						oModelCZP:SetValue("CZP_NRORPO",CYP->CYP_NRORPO)   //Ord Prod    
						oModelCZP:SetValue("CZP_CDMT",CYP->CYP_CDMT)       //Item Reserva
						oModelCZP:SetValue("CZP_CDRE",CYP->CYP_CDRE)       //Referência  
						oModelCZP:SetValue("CZP_QTRPPO",IF(CYP->CYP_QTRP < CYP->CYP_QTMT, nQuant * nPropProd,0))  //Qtd Utilizad
						oModelCZP:SetValue("CZP_QTRP",CYP->CYP_QTRP)       //Qtd Atendida
						oModelCZP:SetValue("CZP_CDUN",CYP->CYP_CDUN)       //Unid Medida 
						oModelCZP:SetValue("CZP_CDACPI",CYP->CYP_CDACPI)   //Item Pai    
						oModelCZP:SetValue("CZP_CDDP",CYP->CYP_CDDP)       //Depósito    
						oModelCZP:SetValue("CZP_CDLC",CYP->CYP_CDLC)       //Localização 
						oModelCZP:SetValue("CZP_CDLO",CYP->CYP_CDLO)       //Lote/Série  
						oModelCZP:SetValue("CZP_CDAT",CYP->CYP_CDAT)       //Operação    
						oModelCZP:SetValue("CZP_CDRT",CYP->CYP_CDRT)       //Roteiro     
						oModelCZP:SetValue("CZP_CDES",Posicione("CYQ", 1, xFilial("CYQ")+cOp, "CYQ_CDES") )  //Estabel     
						oModelCZP:SetValue("CZP_DTMT",CYP->CYP_DTMT)       //Data Reserva
						oModelCZP:SetValue("CZP_QTMT",CYP->CYP_QTMT)       //Qtde Reserva
						oModelCZP:SetValue("CZP_TPST",CYP->CYP_TPST)       //Estado      
						oModelCZP:SetValue("CZP_NRORRE",CYP->CYP_NRORRE)   //Ordem Refer 
						oModelCZP:SetValue("CZP_CDTBMT",CYP->CYP_CDTBMT)   //Processo Ord
						oModelCZP:SetValue("CZP_IDMTOR",CYP->CYP_IDMTOR)   //ID Reservas 
						
						CYP->(dbSkip())
					End
				EndIf 

				//Antes de validar o modelo executa ponto de entrada 
				If __lPEPosAP
					ExecBlock("PApPosAp", .F., .F., {"4", Nil, oModel, "1", oJson['CodeForm']})
				EndIf

				// Valida o modelo
				If oModel:VldData()   				
   					If !oModel:CommitData()
     					lPost := .F.					
						aErro := oModel:GetErrorMessage()
     					If !Empty(aErro[6])
        					cMsgErro := oModel:GetErrorMessage()[6]
     					Else
							cMsgErro := (STR0026) //"Ocorreram erros ao realizar o apontamento."
     					EndIf     								
						SetRestFault(400, EncodeUTF8(cMsgErro))
   					EndIf
				Else
   					lPost := .F.					
					aErro := oModel:GetErrorMessage()
     				If !Empty(aErro[6])
        				cMsgErro := oModel:GetErrorMessage()[6]
     				Else
						cMsgErro := (STR0026) //"Ocorreram erros ao realizar o apontamento."
     				EndIf     								
					SetRestFault(400, EncodeUTF8(cMsgErro))
				EndIf
			EndIf

			If lPost
				oJson['Status'] := (STR0041)//'Apontamento efetuado com sucesso'
						
				//saldo da ordem após o apontamento
				DbSelectArea("SC2")
				SC2->(dbSetOrder(1))
				SC2->(dbSeek(xFilial("SC2")+cOp))			
				If !Empty(SC2->C2_DATRF) 			
					oJson['OpClose'] := .T.
				Else
					oJson['OpClose'] := .F.
				EndIf
			 
		    	oJson['ApprovedQuantity'] := SC2->C2_QUANT - SC2->C2_QUJE - If(lPerdInf,0,SC2->C2_PERDA) 
				::SetResponse(EncodeUTF8(oJson:toJson()))
			EndIf
		Else
			If cIniFim == 'I'	

				//Posicionar no split para ativar o model
				DbSelectArea("CYY")
				CYY->(DbSetOrder(1))
				If CYY->(!DbSeek(xFilial("CYY")+cOp+cIdOper+cSplit))
					SetRestFault(400, EncodeUTF8(STR0029)) //"Split não cadastrado."
   					lPost := .F.
				Endif	

				If lPost .And. !Empty(cMaq)				
					_MaqSFC310 := cMaq
				EndIf	

				If lPost
					// Instancia o modelo
					oModel := FWLoadModel( "SFCA319" )

					//Limpa variável de erro
					aErro := oModel:GetErrorMessage(.T.)
					aErro := {}

					oModel:SetOperation( 3 ) //iniciar apontamento
					If !oModel:Activate()   				
   						lPost := .F.
						aErro := oModel:GetErrorMessage()
     					If !Empty(aErro[6])
        					cMsgErro := oModel:GetErrorMessage()[6]
     					Else
							cMsgErro := (STR0026) //"Ocorreram erros ao realizar o apontamento."
     					EndIf     								
						SetRestFault(400, EncodeUTF8(cMsgErro))   
					EndIf
				EndIf

				If lPost
					oModel:SetValue("CYVMASTER","CYV_NRORPO",cOp)             //OP
         			oModel:SetValue("CYVMASTER","CYV_IDAT"  ,cIdOper) 	      //ID OPERAÇÃO
         			oModel:SetValue("CYVMASTER","CYV_IDATQO",cSplit)  	      //SPLIT
         			oModel:SetValue("CYVMASTER","CYV_CDMQ"  ,cMaq)            //MAQUINA	
					oModel:SetValue("CYVMASTER","CYV_DTRPBG",cDataIniRe)      //DATA INICIO REPORTE         	
					oModel:SetValue("CYVMASTER","CYV_HRRPBG",cTimeIniRe)      //HORA INICIO REPORTE

					//Antes de validar o modelo executa ponto de entrada 
					If __lPEPosAP
						ExecBlock("PApPosAp", .F., .F., {"4", Nil, oModel, "2", oJson['CodeForm']})
					EndIf

					// Valida o modelo
					If oModel:VldData()   				
   						If !oModel:CommitData()
     						lPost := .F.					
							aErro := oModel:GetErrorMessage()
     						If !Empty(aErro[6])
        						cMsgErro := oModel:GetErrorMessage()[6]
     						Else
								cMsgErro := (STR0026) //"Ocorreram erros ao realizar o apontamento."
     						EndIf     								
							SetRestFault(400, EncodeUTF8(cMsgErro))
   						EndIf
					Else
   						lPost := .F.					
						aErro := oModel:GetErrorMessage()
     					If !Empty(aErro[6])
        					cMsgErro := oModel:GetErrorMessage()[6]
     					Else
							cMsgErro := (STR0026) //"Ocorreram erros ao realizar o apontamento."
     					EndIf     								
						SetRestFault(400, EncodeUTF8(cMsgErro))
					EndIf
				EndIf
	
				If lPost
					oJson['Status'] := (STR0042) //'Inicio do Apontamento efetuado com sucesso'
					::SetResponse(EncodeUTF8(oJson:toJson()))
				EndIf
			Else
				If cIniFim == 'A'
					//Posicionar no split para ativar o model
					DbSelectArea("CYY")
					CYY->(DbSetOrder(1))
					If CYY->(!DbSeek(xFilial("CYY")+cOp+cIdOper+cSplit))
						SetRestFault(400, EncodeUTF8(STR0029)) //"Split não cadastrado."
   						lPost := .F.
					Endif		

					If lPost
						If CYY->CYY_CDMQ != cMaq
							SetRestFault(400, EncodeUTF8(STR0031)) //"Máquina não pertence ao Id da Operação."         
							lPost := .F.
						EndIf
					EndIf
		
					If lPost
						//Buscar serial
						cNRSQRP := ' '
						lPost := ConSeqApo(cOp, cIdOper, cSplit, @cNRSQRP)

						If !lPost 
							SetRestFault(400, EncodeUTF8(STR0036)) //"Não foi possível localizar a sequência do apontamento de inicio para abandonar o apontamento."
						EndIf
					EndIf

					If lPost
						DbSelectArea("CYV")
						CYV->(DbSetOrder(1))
						If CYV->(!DbSeek(xFilial("CYV")+cNRSQRP))					
							SetRestFault(400, EncodeUTF8(STR0035)) //"Serial do apontamento de inicio não cadastrado."
							lPost := .F.
						EndIf
					EndIf

					If lPost
						// Verificar se apontamento selecionado está iniciado
						If !(!CYV->CYV_LGRPEO .AND. CYV->CYV_TPSTRP == '1')
							SetRestFault(400, EncodeUTF8(STR0037)) //"Somente apontamentos iniciados podem ser abandonados."
							lPost := .F.
						EndIf
					EndIf					
					
					If lPost
						// Instancia o modelo
						oModel := FWLoadModel( "SFCA319" )

						//Limpa variável de erro
						aErro := oModel:GetErrorMessage(.T.)
						aErro := {}

						oModel:SetOperation( 4 ) //abandonar apontamento
						If !oModel:Activate()   				
   							lPost := .F.
							aErro := oModel:GetErrorMessage()
     						If !Empty(aErro[6])
        						cMsgErro := oModel:GetErrorMessage()[6]
     						Else
								cMsgErro := (STR0026) //"Ocorreram erros ao realizar o apontamento."
     						EndIf     								
							SetRestFault(400, EncodeUTF8(cMsgErro))   
						EndIf
					EndIf

					If lPost
						oModel:SetValue('CYVMASTER','CYV_CDUSOE', CYV->CYV_CDUSRP)
						oModel:SetValue('CYVMASTER','CYV_DTEO'  , DATE())
						oModel:SetValue('CYVMASTER','CYV_LGRPEO', .T.)

						//Antes de validar o modelo executa ponto de entrada 
						If __lPEPosAP
							ExecBlock("PApPosAp", .F., .F., {"4", Nil, oModel, "3", oJson['CodeForm']})
						EndIf

						// Valida o modelo
						If oModel:VldData()   				
   							If !oModel:CommitData()
     							lPost := .F.					
								aErro := oModel:GetErrorMessage()
     							If !Empty(aErro[6])
        							cMsgErro := oModel:GetErrorMessage()[6]
     							Else
									cMsgErro := (STR0026) //"Ocorreram erros ao realizar o apontamento."
     							EndIf     								
								SetRestFault(400, EncodeUTF8(cMsgErro))
   							EndIf
						Else
   							lPost := .F.					
							aErro := oModel:GetErrorMessage()
     						If !Empty(aErro[6])
        						cMsgErro := oModel:GetErrorMessage()[6]
     						Else
								cMsgErro := (STR0026) //"Ocorreram erros ao realizar o apontamento."
     						EndIf     								
							SetRestFault(400, EncodeUTF8(cMsgErro))
						EndIf
					EndIf					
	
					If lPost
						oJson['Status'] = (STR0039) //"Apontamento abandonado com sucesso."
						::SetResponse(EncodeUTF8(oJson:toJson()))
					EndIf
				EndIf	
			EndIf
		EndIf
	EndIf

	FreeObj(oJson)

Return lPost

/*/{Protheus.doc} FormataErro()
Função para reunir e formatar as mensagens de erro para exibir no APP
@author Parffit Jim Balsanelli
@since 18/09/2018
@version 1.0
@return
/*/
Static Function FormataErro()

	Local nCount    := 0
	Local aErroAuto := {}
	Local cLogErro  := ""

	aErroAuto := GetAutoGRLog()
	For nCount := 1 To Len(aErroAuto)
		//Retorna somente a mensagem de erro (Help) e o valor que está inválido, sem quebras de linha e sem tags '<>'
		cLogErro += StrTran( StrTran( StrTran( StrTran( StrTran( aErroAuto[nCount], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|")
	Next nCount

Return cLogErro

/*/{Protheus.doc} ConSplit()
Função para consultar as informações do Split
@author Michele Lais Girardi
@since 28/05/2020
@version 1.0
@return
/*/
Static Function ConSplit(cOp, cMaq)
Local cQuery      := ""
Local cAlias      := ""
Local aCYY        := {}

    cAlias  := GetNextAlias()

	cQuery := " SELECT CYY.CYY_NRORPO NUM_OP, "
	cQuery += "        CYY.CYY_IDATQO SPLIT,  "
	cQuery += "        CYY.CYY_IDAT ID_OPER,  "
	cQuery += "        CY9.CY9_CDAT COD_OPER, "
	cQuery += "        CY9.CY9_DSAT DESC_OPER "
	cQuery += "   FROM " + RetSqlName("CYY") + " CYY " + "," + RetSqlName("CY9") + " CY9 "  + "," + RetSqlName("CYB") + " CYB "
	cQuery += "  WHERE CY9.CY9_FILIAL  = '" + xFilial( "CY9" ) + "'"
	cQuery += "    AND CYY.CYY_FILIAL  = '" + xFilial( "CYY" ) + "'"
	cQuery += "    AND CYB.CYB_FILIAL  = '" + xFilial( "CYB" ) + "'"
	cQuery += "    AND CYY.CYY_NRORPO  = '" +cOp+ "'"
	cQuery += "    AND (( CYY.CYY_CDMQ    = '" +cMaq+ "' AND CYY.CYY_CDMQ    = CYB.CYB_CDMQ ) "
	cQuery += "         OR CYY.CYY_CDMQ    = ' ' AND  CYB_CDMQ = '" +cMaq+ "' )  "	
	cQuery += "    AND CYY.CYY_NRORPO  = CY9.CY9_NRORPO "
	cQuery += "    AND CYY.CYY_IDAT    = CY9.CY9_IDAT "
	cQuery += "    AND CYY.CYY_CDCETR  = CYB.CYB_CDCETR "
	cQuery += "    AND (CYY.CYY_QTAT - CYY.CYY_QTATAP - CYY.CYY_QTATRF) > 0
	cQuery += "    AND CYY.D_E_L_E_T_  = ' ' "
	cQuery += "    AND CY9.D_E_L_E_T_  = ' ' "
	cQuery += "    AND CYB.D_E_L_E_T_  = ' ' "
	cQuery += "  ORDER BY CYY.CYY_NRORPO, CYY.CYY_IDAT, CYY.CYY_IDATQO "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	While (cAlias)->(!Eof())
		aAdd(aCYY,{(cAlias)->SPLIT, (cAlias)->ID_OPER, (cAlias)->COD_OPER, (cAlias)->DESC_OPER})
		(cAlias)->(dbSkip())    
	End

	(cAlias)->(DBCloseArea())

Return aCYY 

/*/{Protheus.doc} ConCab()
Função para consultar as informações do cabeçalho do spli
@author Michele Lais Girardi
@since 28/05/2020
@version 1.0
@return
/*/
Static Function ConCab(cOp, cMaq)
Local cQuery      := ""
Local cAlias      := ""
Local aCab        := {}

    cAlias  := GetNextAlias()

	cQuery := " SELECT DISTINCT CZ3_CDAC  COD_ITEM,  "
	cQuery += "        CZ3_DSAC           DESC_ITEM,  "
	cQuery += "        CZ3_CDUN           UNID_MED  "
	cQuery += "   FROM " + RetSqlName("CYY") + " CYY " + "," + RetSqlName("CZ3") + " CZ3 "  + "," + RetSqlName("CYB") + " CYB "
	cQuery += "  WHERE CZ3.CZ3_FILIAL  = '" + xFilial( "CZ3" ) + "'"
	cQuery += "    AND CYY.CYY_FILIAL  = '" + xFilial( "CYY" ) + "'"
	cQuery += "    AND CYB.CYB_FILIAL  = '" + xFilial( "CYB" ) + "'"
	cQuery += "    AND CYY.CYY_NRORPO  = '" +cOp+ "'"	
	cQuery += "    AND (( CYY.CYY_CDMQ    = '" +cMaq+ "' AND CYY.CYY_CDMQ    = CYB.CYB_CDMQ ) "
	cQuery += "         OR CYY.CYY_CDMQ    = ' ' AND  CYB_CDMQ = '" +cMaq+ "' )  "	
	cQuery += "    AND CYY.CYY_CDAC    = CZ3.CZ3_CDAC "
	cQuery += "    AND CYY.CYY_CDCETR  = CYB.CYB_CDCETR "
	cQuery += "    AND CYY.D_E_L_E_T_  = ' ' "
	cQuery += "    AND CZ3.D_E_L_E_T_  = ' ' "
	cQuery += "    AND CYB.D_E_L_E_T_  = ' ' "


	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	While (cAlias)->(!Eof())
		aAdd(aCab,{cOp, (cAlias)->COD_ITEM, (cAlias)->DESC_ITEM, (cAlias)->UNID_MED})
		Exit
	End

	(cAlias)->(DBCloseArea())

Return aCab 

/*/{Protheus.doc} ConSeqApo
Consulta a sequencia do apontamento que está em aberto para a máquina

@param  cNRORPO    Ordem de Produção
@param  cIDAT      Identificador Operação
@param  cIDATQO    Identificador Split

@return lRet        Se encontrou para retorna false

@author Michele Girardi
@since 27/07/2020
@version 12
/*/
Function ConSeqApo(cNRORPO, cIDAT, cIDATQO, cNRSQRP)
Local lRet      := .F.
Local cQuery    := ""
Local cAliasCYV := GetNextAlias()

	cQuery := "  SELECT CYV_NRSQRP SEQAPON "
	cQuery += "    FROM " + RetSqlName("CYV") + " CYV " 
	cQuery += "   WHERE CYV.CYV_FILIAL  = '" + xFilial( "CYV" ) + "'"
	cQuery += "     AND CYV.CYV_NRORPO  = '" +cNRORPO+ "'"
	cQuery += "     AND CYV.CYV_IDAT    = '" +cIDAT+ "'"
	cQuery += "     AND CYV.CYV_IDATQO  = '" +cIDATQO+ "'"
	cQuery += "     AND CYV.CYV_TPSTRP  = '1' "
	cQuery += "     AND CYV.CYV_LGRPEO  = 'F' "
	cQuery += "     AND CYV.D_E_L_E_T_  = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCYV,.T.,.T.)
	While (cAliasCYV)->(!Eof())
		cNRSQRP := (cAliasCYV)->SEQAPON
		lRet := .T.
		Exit
	End

	(cAliasCYV)->(DBCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaCaCus
Busca campo customizado

@param  oJson      oJson com as tags enviadas pelo APP
@param  aCampos    Array com as informações dos campos customizados
@param  cMsgCC     Mensagem de erro
@param  lErroCC    Indicador se ocorreu erro
@param  lTipForm   Tipo do Formulário

@return Nil

@author Michele Girardi
@since 26/10/2020
@version 12
/*/
//----------------------------------------------------------------
Function BuscaCaCus(oJson, aCampos, cMsgCC, lErroCC, lTipForm)

Local cCampo := ' '
Local nI     

	For nI := 1 TO 25

		Do Case
			Case nI == 1
				cTipo   := 'CustomFieldCharacter01'
				cValCam := oJson['CustomFieldCharacter01']
			
			Case nI == 2
				cTipo   := 'CustomFieldCharacter02'
				cValCam := oJson['CustomFieldCharacter02']
			
			Case nI == 3
				cTipo   := 'CustomFieldCharacter03'
				cValCam := oJson['CustomFieldCharacter03']
			
			Case nI == 4
				cTipo   := 'CustomFieldCharacter04'
				cValCam := oJson['CustomFieldCharacter04']
			
			Case nI == 5
				cTipo   := 'CustomFieldCharacter05'
				cValCam := oJson['CustomFieldCharacter05']

			Case nI == 6
				cTipo   := 'CustomFieldDecimal01'
				cValCam := oJson['CustomFieldDecimal01']
			
			Case nI == 7
				cTipo   := 'CustomFieldDecimal02'
				cValCam := oJson['CustomFieldDecimal02']
			
			Case nI == 8
				cTipo   := 'CustomFieldDecimal03'
				cValCam := oJson['CustomFieldDecimal03']
			
			Case nI == 9
				cTipo   := 'CustomFieldDecimal04'
				cValCam := oJson['CustomFieldDecimal04']
			
			Case nI == 10
				cTipo   := 'CustomFieldDecimal05'
				cValCam := oJson['CustomFieldDecimal05']
			
			Case nI == 11
				cTipo   := 'CustomFieldDate01'
				cValCam := oJson['CustomFieldDate01']
			
			Case nI == 12
				cTipo   := 'CustomFieldDate02'
				cValCam := oJson['CustomFieldDate02']
			
			Case nI == 13
				cTipo   := 'CustomFieldDate03'
				cValCam := oJson['CustomFieldDate03']
			
			Case nI == 14
				cTipo   := 'CustomFieldDate04'
				cValCam := oJson['CustomFieldDate04']
			
			Case nI == 15
				cTipo   := 'CustomFieldDate05'
				cValCam := oJson['CustomFieldDate05']

			Case nI == 16
				cTipo   := 'CustomFieldLogical01'
				cValCam := oJson['CustomFieldLogical01']

			Case nI == 17
				cTipo   := 'CustomFieldLogical02'
				cValCam := oJson['CustomFieldLogical02']

			Case nI == 18
				cTipo   := 'CustomFieldLogical03'
				cValCam := oJson['CustomFieldLogical03']
			
			Case nI == 19
				cTipo   := 'CustomFieldLogical04'
				cValCam := oJson['CustomFieldLogical04']
			
			Case nI == 20
				cTipo   := 'CustomFieldLogical05'
				cValCam := oJson['CustomFieldLogical05']

			Case nI == 21
				cTipo   := 'CustomFieldList01'
				cValCam := oJson['CustomFieldList01']

			Case nI == 22
				cTipo   := 'CustomFieldList02'
				cValCam := oJson['CustomFieldList02']

			Case nI == 23
				cTipo   := 'CustomFieldList03'
				cValCam := oJson['CustomFieldList03']

			Case nI == 24
				cTipo   := 'CustomFieldList04'
				cValCam := oJson['CustomFieldList04']

			Case nI == 25
				cTipo   := 'CustomFieldList05'
				cValCam := oJson['CustomFieldList05']

		EndCase

		If !Empty(cValCam)
			If Empty(oJson['CodeForm'])
				cMsgCC  := (STR0045) //'Código do Formulário não informado.'
				lErroCC := .T.		
			EndIf

			If !lErroCC
				cCampo := ' '
				cCampo := PCPA121RCC(oJson['CodeForm'], cTipo)

				If !Empty(cCampo)
					If lTipForm == '1'
						dbSelectArea("SD3")
						lExistCC := If (SD3->(ColumnPos(cCampo)) >  0, .T., .F.)
						If !lExistCC
							cMsgCC1 := ' ('+cValToChar( AllTrim(cCampo))+')'
							cMsgCC  := (STR0046+cMsgCC1) //'Campo Customizado informado no PCPA125 (Formulário de Apontamento) não existe na tabela SD3.'
							lErroCC := .T.
						EndIf
					Else
						If lTipForm == '3'
							dbSelectArea("SH6")
							lExistCC := If (SH6->(ColumnPos(cCampo)) >  0, .T., .F.)
							If !lExistCC
								cMsgCC1 := ' ('+cValToChar( AllTrim(cCampo))+')'
								cMsgCC  := (STR0047+cMsgCC1) //'Campo Customizado informado no PCPA125 (Formulário de Apontamento) não existe na tabela SH6.'
								lErroCC := .T.
							EndIf
						Else
							If lTipForm == '4'
								dbSelectArea("CYV")
								lExistCC := If (CYV->(ColumnPos(cCampo)) >  0, .T., .F.)
								If !lExistCC
									cMsgCC1 := ' ('+cValToChar( AllTrim(cCampo))+')'
									cMsgCC  := (STR0048+cMsgCC1) //'Campo Customizado informado no PCPA125 (Formulário de Apontamento) não existe na tabela CYV.'
									lErroCC := .T.
								EndIf
							EndIf
						EndIf
					EndIf 
				Else
					cMsgCC1 := ' ('+cValToChar( AllTrim(cTipo))+')'
					cMsgCC  := (STR0049+cMsgCC1) //'Campo Customizado não encontrado no formulário de parâmetros (PCPA125).'
					lErroCC := .T.
				EndIf
			EndIf

			If !lErroCC
				AAdd(aCampos,{cTipo, cCampo, cValToChar(cValCam) ,.T. } )
			Else
				Exit
			EndIf
		Else
			AAdd(aCampos,{cTipo, ' ', ' ' , .F. } )
		EndIf
	Next nI
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FormataCC
Formata Campo Customizado

@param  nI          Indice o array dos campos customizados
@param  cValorCC    Valor em Caracter do campo customizado

@author Michele Girardi
@since 26/10/2020
@version 12
/*/
//----------------------------------------------------------------
Function FormataCC(nI, cValorCC, cCampoCC)

	Local cTipo := ""

	If nI >= 6 .And. nI <=10 //Tipo númerio - Transformar char para númerico		
		//cDecimal := TamSx3(cCampoCC)[ 2 ]
		cValorCC := Val(cValorCC)										
	Else
		If nI >= 11 .And. nI <=15 //Tipo Data - Transformar char para data
			cValorCC := CTOD(cValorCC)										
		Else
			If nI >= 16 .And. nI <=20 //Tipo Lógico - Transformar char para lógico
				lValLog := .F.
				If cValorCC $ ".F.|F|0"
					lValLog := .F.
				Else
					If cValorCC $ ".T.|T|1"
						lValLog := .T.
					EndIf
				EndIf
				cValorCC := lValLog
			ElseIf nI >= 20 .And. nI <= 25 .And. !Empty(cCampoCC) //Tipo Lista - Transforma de acordo com o tipo do campo.
				cTipo := GetSX3Cache(RTrim(cCampoCC), "X3_TIPO")
				Do Case 
					Case cTipo == "N"
						FormataCC(6, @cValorCC, cCampoCC)
					Case cTipo == "D"
						FormataCC(11, @cValorCC, cCampoCC)
					Case cTipo == "L"
						FormataCC(16, @cValorCC, cCampoCC)
				EndCase
			EndIf
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaCC
Valida Campo Customizado

@param  nI          Indice o array dos campos customizados
@param  cValorCC    Valor em Caracter do campo customizado

@author Michele Girardi
@since 26/10/2020
@version 12
/*/
//----------------------------------------------------------------
Function ValidaCC(nI, cValorCC, cMsgCC, lErroCC, cCampoCC)

	Local cTipo   := ""
	Local lAnt    := .T.
	Local nDecVar := 0
	Local nI1     := 0
	Local nTamVar := 0

	cMsgCC  := ' '
	lErroCC := .F.

	cValorCC := AllTrim(cValorCC)

	If nI >= 6 .And. nI <=10 //Valida Tipo Decimal
		
		//Verifica se existe somente numeros
		For nI1 = 1 to len(cValorCC)
			If !(Substr(cValorCC,nI1,1) $ "0|1|2|3|4|5|6|7|8|9|.|-")
				cMsgCC := (STR0050+cValToChar(cValorCC))//'É permitido informar somente números no Campo Customizado do tipo Decimal. Valor informado: ' + cValToChar(cValorCC)
				lErroCC := .T.
				return Nil
			EndIf
		Next nI1

		lAnt := .T.
		For nI1 = 1 to len(cValorCC)
			If Substr(cValorCC,nI1,1) == '.'
				lAnt := .F.
			Else
				If lAnt == .T.
					nTamVar += 1
				Else
					nDecVar += 1
				EndIf
			EndIf			
		Next nI1
		
		//Verifica qtd de casas antes da virgula
		cTamanho := TamSx3(cCampoCC)[ 1 ]
		cDecimal := TamSx3(cCampoCC)[ 2 ]
		If cDecimal > 0
			cTamanho := cTamanho - cDecimal - 1
		EndIf

		If nTamVar > cTamanho
			cMsgCC := (STR0051)//'Valor inteiro informado para o campo customizado do tipo decimal é maior que o definido no SIGACFG. '
			cMsgCC += (STR0052+cValToChar(cTamanho)+STR0053+cValToChar(cValorCC))//'Tamanho inteiro permitido: ' + cValToChar(cTamanho) + '. Valor informado: ' + cValToChar(cValorCC) + '.'
			lErroCC := .T.
			Return Nil 
		EndIf

		//Verificar qtd de casas depois da virgula
		If nDecVar > cDecimal
			cMsgCC := (STR0054)//'Valor decimal informado para o campo customizado do tipo decimal é maior que o definido no SIGACFG. '
			cMsgCC += (STR0055+cValToChar(cDecimal)+STR0053+cValToChar(cValorCC))//'Decimal permitido: ' + cValToChar(cDecimal) + '. Valor informado: ' + cValToChar(cValorCC) + '.'
			lErroCC := .T.
			Return Nil 
		EndIf			

		cValorCC := Val(cValorCC)										
	Else
		If nI >= 11 .And. nI <=15 //Valida Tipo Data
			cDtAnt := cValorCC
			cValorCC := CTOD(cValorCC)

			If Empty(cValorCC)	
				cMsgCC := (STR0056)///'Valor informado para o campo customizado do tipo data inválido.'
				cMsgCC += (' '+STR0057+cValToChar(cDtAnt))//'Valor informado: ' + cValToChar(cDtAnt) + '.'
				lErroCC := .T.
				Return Nil 
			EndIf
		Else
			If nI >= 16 .And. nI <=20 //Valida Tipo Lógico 
				lValLog := .F.
				If cValorCC $ ".F.|F|0"
					lValLog := .F.
				Else
					If cValorCC $ ".T.|T|1"
						lValLog := .T.
					Else
						cMsgCC := (STR0058) //'Valor informado para o campo customizado do tipo lógico difere do permitido: .T., T, 1, .F. ,F, 0.'
						cMsgCC += (' '+STR0057+cValToChar(cValorCC))//'Valor informado: ' + cValToChar(cValorCC) + '.'
						lErroCC := .T.
						Return Nil 
					EndIf
				EndIf
				cValorCC := lValLog
			Else
				If nI >= 1 .And. nI <= 5 //Valida Tipo Caracter
					cTamanho := TamSx3(cCampoCC)[ 1 ]

					If Len(cValorCC) > cTamanho
						cMsgCC := (STR0059)//'Valor informado para o campo customizado do tipo caracter é maior que o tamanho definido no SIGACFG. '
						cMsgCC += (STR0060+cValToChar(cTamanho)+'. '+STR0057+cValToChar(cValorCC))//'Tamanho permitido: ' + cValToChar(cTamanho) + '. Valor informado: ' + cValToChar(cValorCC) + '.'
						lErroCC := .T.
						Return Nil 
					EndIf
				ElseIf nI >= 20 .And. nI <= 25 .And. !Empty(cCampoCC) //Valida tipo Lista.

					cTipo := GetSX3Cache(RTrim(cCampoCC), "X3_TIPO")
					Do Case
						Case cTipo == "C"
							ValidaCC(1, cValorCC, @cMsgCC, @lErroCC, cCampoCC)
						Case cTipo == "N"
							ValidaCC(6, cValorCC, @cMsgCC, @lErroCC, cCampoCC)
						Case cTipo == "D"
							ValidaCC(11, cValorCC, @cMsgCC, @lErroCC, cCampoCC)
						Case cTipo == "L"
							ValidaCC(16, cValorCC, @cMsgCC, @lErroCC, cCampoCC)
					EndCase

				EndIf
			EndIf
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getDescription
Busca descrição

@param  cOrigem     Indica qual a origem da descrição
                    "P" - Produto
                    "O" - Operação

@author Parffit Jim Balsanelli
@since 13/07/2021
@version 12
/*/
//----------------------------------------------------------------
Static Function getDescription(cOrigem)
	Local aAreaSB1 := {}
	Local cDescr := ""

	If cOrigem == "P"
		aAreaSB1 := SB1->(GetArea())
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+M->H6_PRODUTO)

		cDescr := trim(SB1->B1_DESC)
		RestArea(aAreaSB1)
	ElseIf cOrigem == "O"
		If trim(SHY->HY_DESCRI) <> ""
			cDescr := trim(SHY->HY_DESCRI)
		Else
			cDescr := trim(SG2->G2_DESCRI)
		EndIf
	EndIf

Return cDescr
