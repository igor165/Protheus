#Include 'Protheus.ch'
#Include 'fwAdapterEAI.ch'
#Include 'FWMVCDEF.CH'
#Include 'MATI682.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MATI682
Funcao de integracao com o adapter EAI para envio e recebimento do
apontamento de parada (SH6) utilizando o conceito de mensagem unica.

@param   oXMLEnv       Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Ezequiel Marques Ramos
@version P12
@since   05/10/2015
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execu��o da fun��o
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O m�todo ir� retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a fun��o EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Function MATI682(oXMLEnv, nTypeTrans, cTypeMessage)
	Local cVersao     := ""
	Local lRet        := .T.
	Local cXmlRet     := ""

	Private oXML      := oXMLEnv
	Private lIntegPPI := .F.

	//Verifica se est� sendo executado para realizar a integra��o com o PPI.
	//Se a vari�vel lRunPPI estiver definida, e for .T., assume que � para o PPI.
	If Type("lRunPPI") == "L" .And. lRunPPI
		lIntegPPI := .T.
	EndIf
	
	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			
			// Vers�o da mensagem
			If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
				cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
			Else
				If Type("oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text)
					cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text, ".")[1]
				Else
					lRet    := .F.
					cXmlRet := STR0001 //"Vers�o da mensagem n�o informada!"
					Return {lRet, cXmlRet}
				Endif
			EndIf

			If cVersao == "1"

				Begin Transaction
					aRet := v1000(oXML, nTypeTrans, cTypeMessage)
					If !aRet[1]
						DisarmTransaction()
					EndIf
				End Transaction

			Else
				lRet    := .F.
				cXmlRet := STR0002 //"A vers�o da mensagem informada n�o foi implementada!"
				Return {lRet, cXmlRet}
			EndIf
		Endif
	ElseIf nTypeTrans == TRANS_SEND
		
	EndIf

	lRet    := aRet[1]
	cXmlRet := aRet[2]
Return {lRet, cXmlRet}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v1000

Funcao de integracao com o adapter EAI para recebimento do apontamento de parada (SH6) 
utilizando o conceito de mensagem unica.

@param   oXMLEnv      Vari�vel com conte�do XML para envio/recebimento.
@param   nTypeTrans   Tipo de transa��o. (Envio/Recebimento)
@param   cTypeMessage Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Ezequiel Marques Ramos
@version P12
@since   05/10/2015
@return  aRet  - (array)   Cont�m o resultado da execu��o e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execu��o da fun��o
       aRet[2] - (caracter) Mensagem XML para envio

@obs    O m�todo ir� retornar um objeto do tipo TOTVSBusinessEvent caso
       o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
       TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
       O tipo da classe pode ser definido com a fun��o EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------------------------------------
Static Function v1000(oXMLEnv, nTypeTrans, cTypeMessage)
	Local lRet        := .T.
	Local cXmlRet     := ""
	Local cEvent      := ""
	Local cProduct    := ""
	Local cQuery      := ""
	Local cAlias      := ""
	Local nOperation  := 0
	Local lEstorno    := .F.
	Local aSH6        := {}
	Local aErroAuto   := {}
	Local aValues     := {}
	Local aRet        := {}
	Local cLogErro    := ""
	Local nCount      := 0

	//Local cMaquina    := "" //Definida no WSPCP.prw
	Local cMaqDesc    := ""
	Local cMotPar     := ""
	Local cMotParDesc := ""
	//Local dDateIni    := Nil //Definida no WSPCP.prw
	//Local cHoraIni    := "" //Definida no WSPCP.prw
	//Local dDateFim    := Nil //Definida no WSPCP.prw
	//Local cHoraFim    := "" //Definida no WSPCP.prw
	Local cFerr       := ""
	Local cFerrDesc   := ""
	Local cEqui       := ""
	Local cEquiNome   := ""
	Local cOper       := ""
	Local cOperNome   := ""
	Local cTurn       := ""
	Local cTurnDesc   := ""
	Local nTurn       := 0
	Local cTipoParada := ""
	Local dDtRep      := Nil
	Local cHrRep      := ""
	Local cParaGeral  := ""
	Local cSeqReporte := 0
	Local oModel
	Local lIntSFC     := IntegraSFC()
	Local lAtuCYN  := .F.

	CYN->(dbSelectArea("CYN"))
	If CYN->(FieldPos("CYN_LGMOD")) > 0
		lAtuCYN := .T.
	EndIf

	Private oXml        := oXMLEnv
	Private lMSErroAuto := .F.
	Private lAutoErrNoFile := .T.
	Private nRegSH6     := 0
	//Private lMsHelpAuto := .F.

	If !lIntegPPI
		AdpLogEAI(1, "MATI682", nTypeTrans, cTypeMessage)
	EndIf

	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
				cEvent := Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
			Else
				lRet   := .F.
				cXmlRet := "Event " + STR0004 // � obrigat�rio."
				Return {lRet, cXmlRet}
			EndIf
		EndIf

		If Type("oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
			cProduct := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		Else
			lRet   := .F.
			cXmlRet := "Product:Name " + STR0004 // � obrigat�rio."
			Return {lRet, cXmlRet}
		EndIf

		If AllTrim(UPPER(cProduct)) == "PPI"
			//Verifica se a integra��o com o PPI est� ativa. Se n�o estiver, n�o permite prosseguir com a integra��o.
			If !PCPIntgPPI()
				lRet := .F.
				cXmlRet := STR0003 //"Integra��o com o PC-Factory desativada. Processamento n�o permitido."
				Return {lRet, cXmlRet}
			EndIf
		EndIf


		If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReversedReport:Text") != "U" .And. ;
			!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReversedReport:Text)
			lEstorno := Iif(Upper(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReversedReport:Text)=="TRUE",.T.,.F.)

			If lEstorno
				lOnlyEstrn := .T.
				nOperation := 5
			
				//RECNO apontamento SH6
				If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IntegrationReport:Text") != "U" .And. ;
					!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IntegrationReport:Text)
					nRegSH6 := Val(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_IntegrationReport:Text)
				Else
					lRet := .F.
					cXmlRet := "IntegrationReport " + STR0004 // � obrigat�rio."
					Return {lRet, cXMLRet}
				EndIf
			
				if lIntSFC
					dbSelectArea('CYX')
					CYX->(dbGoTo(nRegSH6))
					if CYX->(Recno()) != nRegSH6
						lRet := .F.
						cXmlRet := "IntegrationReport " + STR0006 // n�o cadastrado no protheus."
						
						Return {lRet, cXmlRet}
					Endif
					
					aValues := {CYX->CYX_CDMQ,;
								  CYX->CYX_DTBGSP,;
								  CYX->CYX_HRBGSP,;
								  CYX->CYX_DTEDSP,;
								  CYX->CYX_HREDSP}
					
					oModel := FwLoadModel('SFCA311')
					oModel:SetOperation(nOperation)
					oModel:Activate()
					
					if oModel:VldData()
						oModel:CommitData()
					Else
						aErroAuto := oModel:GetErrorMessage()
						
						lRet    := .F.
						cXMLRet := aErroAuto[6]
						
						Return {lRet,cXmlRet}
					Endif
					
					oModel:DeActivate()
			
					PCPCriaSOG("MATI682",aValues[1],,,0,aValues[2],aValues[3],aValues[4],aValues[5],oXml,"1","1",,"OK",/*15*/,/*16*/,/*17*/,/*18*/,/*19*/,/*20*/,Iif(Type('cMesIDIntg')=="C",cMesIDIntg,""))
				Else
		
					cAlias := GetNextAlias()
		
					cQuery := " SELECT COUNT(*) TOTAL "
					cQuery +=   " FROM " + RetSqlName("SH6") + " SH6 "
					cQuery +=  " WHERE SH6.D_E_L_E_T_ = ' '"
					cQuery +=    " AND SH6.R_E_C_N_O_ = " + cValToChar(nRegSH6)
					cQuery := ChangeQuery(cQuery)
		
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		
					If (cAlias)->(TOTAL) < 1
						lRet := .F.
						cXmlRet := "IntegrationReport " + STR0006 // n�o cadastrado no protheus."
						(cAlias)->(dbCloseArea())
						Return {lRet, cXmlRet}
					EndIf
					(cAlias)->(dbCloseArea())
					//Informa��es do estorno v�lidas. Efetua o estorno.
		
					//Posiciona na SH6
					dbSelectArea("SH6")
					SH6->(dbGoTo(nRegSH6))
		
					//Carrega array com todos os campos da SH6
					aSH6 := {}
					aStruH6 := SH6->(DBStruct())
		            For nCount := 1 To Len(aStruH6)
		                If AllTrim(aStruH6[nCount,1]) == "H6_TIPO" .Or. X3USO(GetSx3Cache(aStruH6[nCount,1],'X3_USADO'))
		                   aAdd(aSH6,{AllTrim(aStruH6[nCount,1]),;
		                              &("SH6->"+AllTrim(aStruH6[nCount,1])),;
		                                Nil})
		                EndIf
		            Next nCount
		
					// PE MATI681EXC
					If (ExistBlock('MATI681EXC'))
						aSH6Aux := aClone(aSH6)
						aAdd(aSH6Aux,{"IDESTORNO",nRegSH6,Nil})
						aRet := ExecBlock('MATI681EXC',.F.,.F.,aSH6Aux)
						If !aRet[1]
							Return {.F., Iif(Empty(aRet[2]), STR0011, aRet[2] ) } //"N�o processado devido ao Ponto de Entrada MATI681EXC."
						EndIf
						aSH6Aux := {}
					EndIf
		
					MSExecAuto({|x,y| mata682(x,y)},aSH6,nOperation)
					If lMsErroAuto
						aErroAuto := GetAutoGRLog()
						cLogErro := getMsgErro(aErroAuto)
						lRet    := .F.
						cXMLRet := cLogErro
						Return {lRet,cXmlRet}
					EndIf
		
					If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_RECURSO"}) > 0
						aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_RECURSO"})][2])
					Else
						aAdd(aValues,Nil)
					EndIf
		
					If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_OP"}) > 0
						aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_OP"})][2])
					Else
						aAdd(aValues,Nil)
					EndIf
		
					If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_PRODUTO"}) > 0
						aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_PRODUTO"})][2])
					Else
						aAdd(aValues,Nil)
					EndIf
		
					If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_DATAINI"}) > 0
						aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_DATAINI"})][2])
					Else
						aAdd(aValues,Nil)
					EndIf
		
					If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_HORAINI"}) > 0
						aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_HORAINI"})][2])
					Else
						aAdd(aValues,Nil)
					EndIf
		
					If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_DATAFIN"}) > 0
						aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_DATAFIN"})][2])
					Else
						aAdd(aValues,Nil)
					EndIf
		
					If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_HORAFIN"}) > 0
						aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_HORAFIN"})][2])
					Else
						aAdd(aValues,Nil)
					EndIf
		
					If aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_OPERAC"}) > 0
						aAdd(aValues,aSH6[aScan(aSH6,{|aX| AllTrim(aX[1]) == "H6_OPERAC"})][2])
					Else
						aAdd(aValues,Nil)
					EndIf
					
					PCPCriaSOG("MATI682",aValues[1],aValues[2],aValues[3],0,aValues[4],aValues[5],aValues[6],aValues[7],oXml,"1","1",aValues[8],"OK",/*15*/,/*16*/,/*17*/,/*18*/,/*19*/,/*20*/,Iif(Type('cMesIDIntg')=="C",cMesIDIntg,""))
				Endif
			EndIf
		EndIf

		If !lEstorno
			//C�digo M�quina
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_MachineCode:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_MachineCode:Text)
				cMaquina := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_MachineCode:Text
			Else
				lRet := .F.
				cXmlRet := "MachineCode " + STR0004 // � obrigat�rio."
				Return {lRet, cXmlRet}
			EndIf
			
			//Descri��o M�quina
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_MachineDescription:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_MachineDescription:Text)
				cMaqDesc := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_MachineDescription:Text
			EndIf
			
			//C�digo Motivo Parada
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StopReasonCode:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StopReasonCode:Text)
				cMotPar := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StopReasonCode:Text
			Else
				lRet := .F.
				cXmlRet := "StopReasonCode " + STR0004 // � obrigat�rio."
				Return {lRet, cXmlRet}
			EndIf
			
			//Descri��o Motivo Parada
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StopReasonDescription:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StopReasonDescription:Text)
				cMotParDesc := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StopReasonDescription:Text
			EndIf
			
			//Data/Hora in�cio
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StartDateTime:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StartDateTime:Text)
				dDateIni := StoD(getDate(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StartDateTime:Text))
				If Empty(dDateIni)
					lRet := .F.
					cXMLRet := "StartDateTime"+STR0009 // informado em formato incorreto. Utilize AAAA-MM-DDTHH:MM:SS."
					Return {lRet, cXMLRet}
				EndIf
				cHoraIni := getTime(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StartDateTime:Text, lIntSFC)
			Else
				lRet := .F.
				cXmlRet := "StartDateTime " + STR0004 // � obrigat�rio."
				Return {lRet, cXmlRet}
			EndIf
			
			//Data/Hora fim 
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_EndDateTime:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_EndDateTime:Text)
				dDateFim := StoD(getDate(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_EndDateTime:Text))
				If Empty(dDateFim)
					lRet := .F.
					cXMLRet := "EndDateTime"+STR0009 // informado em formato incorreto. Utilize AAAA-MM-DDTHH:MM:SS."
					Return {lRet, cXMLRet}
				EndIf
				cHoraFim := getTime(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_EndDateTime:Text, lIntSFC)
			Else
				lRet := .F.
				cXmlRet := "EndDateTime " + STR0004 // � obrigat�rio."
				Return {lRet, cXmlRet}
			EndIf
			
			//C�digo Ferramenta
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ToolCode:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ToolCode:Text)
				cFerr := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ToolCode:Text
			EndIf
			
			//Descri��o Ferramenta
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ToolDescription:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ToolDescription:Text)
				cFerrDesc := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ToolDescription:Text
			EndIf
			
			//C�digo Equipe
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionTeamCode:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionTeamCode:Text)
				cEqui := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionTeamCode:Text
			EndIf
			
			//Nome Equipe
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionTeamName:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionTeamName:Text)
				cEquiNome := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionTeamName:Text
			EndIf
			
			//C�digo Operador
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_OperatorCode:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_OperatorCode:Text)
				cOper := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_OperatorCode:Text
			EndIf
			
			//Nome Operador
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_OperatorName:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_OperatorName:Text)
				cOperNome := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_OperatorName:Text
			EndIf
			
			//C�digo Modelo Turno
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionShiftCode:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionShiftCode:Text)
				cTurn := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionShiftCode:Text
			EndIf
			
			//Descri��o Turno
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionShiftDescription:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionShiftDescription:Text)
				cTurnDesc := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionShiftDescription:Text
			EndIf
			
			//N�mero Turno 
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionShiftNumber:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionShiftNumber:Text)
				nTurn := Val(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionShiftNumber:Text)
			Else
				nTurn := 0
			EndIf

			//Tipo Parada 
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StopType:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StopType:Text)
				cTipoParada := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_StopType:Text
			
				If AllTrim(cTipoParada) != "1" .And. AllTrim(cTipoParada) != "2"
					lRet := .F.
					cXmlRet := "_StopType" + STR0012 //" informado � inv�lido."
					Return {lRet, cXmlRet}
				EndIf
			EndIf

			//Data/Hora Reporte 
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReportDateTime:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReportDateTime:Text)
				dDtRep := StoD(getDate(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReportDateTime:Text))
				If Empty(dDtRep)
					lRet := .F.
					cXMLRet := "ReportDateTime"+STR0009 // informado em formato incorreto. Utilize AAAA-MM-DDTHH:MM:SS."
					Return {lRet, cXMLRet}
				EndIf
				cHrRep := getTime(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReportDateTime:Text, lIntSFC)
			EndIf

			//C�digo Parada Geral
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_GeneralStopCode:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_GeneralStopCode:Text)
				cParaGeral := oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_GeneralStopCode:Text
			EndIf

			//Sequ�ncia Reporte 
			If Type("oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReportSequence:Text") != "U" .And. ;
				!Empty(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReportSequence:Text)
				cSeqReporte := Val(oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReportSequence:Text)
			Else
				cSeqReporte := 0
			EndIf

			//Valida os campos obrigat�rios.
			If !Empty(cMaquina) .And. !Empty(cMotPar) .And. !Empty(cHoraIni) .And. !Empty(cHoraFim) .And. dDateIni != Nil .And. dDateFim != Nil .And. dDtRep != Nil
				If Len(AllTrim(cMotPar)) > TamSX3("H6_MOTIVO")[1]
					lRet := .F.
					cXmlRet := STR0010 //"StopReasonCode informado incorretamente. Tamanho maior do que o campo H6_MOTIVO."
					Return {lRet, cXmlRet}
				EndIf

				//Recurso
				dbSelectArea("SH1")
				SH1->(dbSetOrder(1))
				If !SH1->(dbSeek(xFilial("SH1")+AllTrim(cMaquina)))
					lRet := .F.
					cXmlRet := "MachineCode " + STR0006 //"n�o cadastrado no protheus."
					Return {lRet, cXmlRet}
				EndIf

				//Opera��o de inclus�o de apontamento
				nOperation := 3

				If Empty(dDtRep) .Or. dDtRep < dDataBase
					dDtRep := dDataBase
				EndIf
						
				If lAtuCYN .Or. lIntSFC
					// Criar motivo de parada no SFC
					dbSelectArea('CYN')
					CYN->(dbSetOrder(1))
					If !CYN->(dbSeek(xFilial('CYN')+cMotPar))

						If Empty(cMotParDesc)
							lRet := .F.
							cXmlRet := STR0007 //"StopReasonDescription n�o informado. N�o � poss�vel cadastrar o motivo de parada."
							Return {lRet, cXmlRet}
						Endif

						oModel := FwLoadModel('SFCA004')
						oModel:SetOperation(3)
						oModel:Activate()
						
						oModel:SetValue('CYNMASTER','CYN_CDSP', cMotPar)
						oModel:SetValue('CYNMASTER','CYN_DSSP', cMotParDesc)

						If oModel:VldData()
							oModel:CommitData()
						Endif

						oModel:DeActivate()
					Endif
					
				EndIf

				If lIntSFC

					IF cTipoParada == '2'
						lRet := .F.
						cXmlRet := STR0013 //"Integra��o com SIGASFC n�o aceita apontamento de parada programada"
						Return {lRet, cXmlRet}
					Endif

					aCYX := {{"CYX_CDMQ"  , cMaquina , NIL },;
							{"CYX_CDSP"  , cMotPar  , NIL },;
							{"CYX_CDFEPO", cFerr    , NIL },;
							{"CYX_CDOE"  , cOper    , NIL },;
							{"CYX_CDGROE", cEqui    , NIL },;
							{"CYX_DTBGSP", dDateIni , NIL },;
							{"CYX_HRBGSP", cHoraIni , NIL },;
							{"CYX_DTEDSP", dDateFim , NIL },;
							{"CYX_HREDSP", cHoraFim , NIL },;
							{"CYX_DTRP"  , dDtRep   , NIL },;
							{"CYX_HRRP"  , cHrRep   , NIL }}	

					MSExecAuto({|x,y| SFCA311(x,y)},aCYX,nOperation)

					If lMsErroAuto
						aErroAuto := GetAutoGRLog()
						cLogErro := getMsgErro(aErroAuto)
						lRet    := .F.
						cXmlRet := cLogErro
						Return {lRet,cXmlRet}
					Else
						lRet    := .T.
						cXmlRet := cValToChar(CYX->(Recno()))
					EndIf
				Else
		            
					//Carrega o array com os valores necess�rios para o apontamento.
					aSH6 := {{"H6_RECURSO"    ,cMaquina , NIL },;
							{"H6_MOTIVO"     ,cMotPar  , NIL },;
							{"H6_FERRAM"     ,cFerr    , NIL },;
							{"H6_DATAINI"    ,dDateIni , NIL },;
							{"H6_HORAINI"    ,cHoraIni , NIL },;
							{"H6_DATAFIN"    ,dDateFim , NIL },;
							{"H6_HORAFIN"    ,cHoraFim , NIL },;
							{"H6_DTAPONT"    ,dDtRep   , NIL },;
							{"H6_OPERADO"    ,cOper    , NIL },;
							{"H6_OBSERVA"    ,"TOTVSMES", NIL },;
							{"H6_TIPO"       ,"I"      , NIL },;
							{"REPORTSEQUENCE",cSeqReporte,NIL}} //cont�m o ID da parada no PPI.

					// PE MATI681CRG
					If (ExistBlock('MATI681CRG'))
						aSH6Aux := ExecBlock('MATI681CRG',.F.,.F.,aSH6)
						For nCount := 1 To Len(aSH6Aux)
							//Adiciona no array da SH6 somente os campos que n�o recebem informa��es do XML recebido.
							If aScan(aSH6,{|x| Upper(AllTrim(x[1])) == Upper(AllTrim(aSH6Aux[nCount,1])) }) == 0
								aAdd(aSH6, {aSH6Aux[nCount,1],aSH6Aux[nCount,2], Nil})
							EndIf
						Next nCount
					EndIf

					// PE MATI681EXC
					If (ExistBlock('MATI681EXC'))
						aRet := ExecBlock('MATI681EXC',.F.,.F.,aSH6)
						If !aRet[1]
							Return {.F., Iif(Empty(aRet[2]), STR0011, aRet[2] ) } //"N�o processado devido ao Ponto de Entrada MATI681EXC."
						EndIf
					EndIf

					MSExecAuto({|x,y| mata682(x,y)},aSH6,nOperation)

					If lMsErroAuto
						aErroAuto := GetAutoGRLog()
						cLogErro := getMsgErro(aErroAuto)
						lRet    := .F.
						cXmlRet := cLogErro
						Return {lRet,cXmlRet}
					Else
						lRet    := .T.
						cXmlRet := cValToChar(SH6->(Recno()))
					EndIf
				Endif
			Else
				lRet    := .F.
				cXmlRet := STR0008 //"Verifique os campos obrigat�rios: MachineCode, StopReasonCode, StartDateTime, EndDateTime e ReportDateTime."
				Return {lRet,cXmlRet}
			EndIf
		EndIf
	EndIf
	
	If !lIntegPPI
		AdpLogEAI(5, "MATI682", cXmlRet, lRet)
	EndIf

Return {lRet, cXmlRet}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getDate

Retorna somente a data de uma vari�vel datetime

@param dDateTime - Vari�vel DateTime
 
@return dDate - Retorna a data.

@author  Lucas Konrad Fran�a
@version P12
@since   24/09/2015
/*/
//-------------------------------------------------------------------------------------------------
Static Function getDate(dDateTime)
	Local dDate := Nil
	If AT("T",dDateTime) > 0
		dDate := StrTokArr(dDateTime,"T")[1]
	Else
		dDate := StrTokArr(AllTrim(dDateTime)," ")[1]
	EndIf
	dDate := SubStr(dDate,1,4)+SubStr(dDate,6,2)+SubStr(dDate,9,2)
Return dDate
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTime

Retorna somente a hora de uma vari�vel datetime

@param dDateTime - Vari�vel DateTime
 
@return cTime - Retorna a hora

@author  Lucas Konrad Fran�a
@version P12
@since   29/09/2015
/*/
//-------------------------------------------------------------------------------------------------
Static Function getTime(dDateTime, lIntSFC)
	Local cHora := Nil

	Default lIntSFC := .F.

	If AT("T",dDateTime) > 0
		IF lIntSFC
			cHora := SubStr(StrTokArr(dDateTime,"T")[2],1,8)
		Else
			cHora := SubStr(StrTokArr(dDateTime,"T")[2],1,5)
		Endif
	Else
		if lIntSFC
			cHora := SubStr(StrTokArr(dDateTime," ")[2],1,8)
		Else
			cHora := SubStr(StrTokArr(dDateTime," ")[2],1,5)
		Endif
	EndIf
Return cHora

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getMsgErro

Transforma o array com as informa��es de um erro em uma string para ser retornada.

@param aErro - Array com a mensagem de erro, obtido atrav�s da fun��o GetAutoGRLog

@return cMsg - Mensagem no formato String

@author  Lucas Konrad Fran�a
@version P12
@since   07/03/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function getMsgErro(aErro)
	Local cMsg   := ""
	Local nCount := 0
	
	For nCount := 1 To Len(aErro)
		If AT(':=',aErro[nCount]) > 0 .And. AT('< --',aErro[nCount]) < 1
			Loop
		EndIf
		If AT("------", aErro[nCount]) > 0
			Loop
		EndIf
		//Retorna somente a mensagem de erro (Help) e o valor que est� inv�lido, sem quebras de linha e sem tags '<>'
		If !Empty(cMsg)
			cMsg += " "
		EndIf
		cMsg += AllTrim(StrTran( StrTran( StrTran( StrTran( StrTran( aErro[nCount], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|"))
	Next nCount
	
	If Empty(cMsg) .And. Len(aErro) > 0
		For nCount := 1 To Len(aErro)
			If !Empty(cMsg)
				cMsg += " "
			EndIf
			cMsg += AllTrim(StrTran( StrTran( StrTran( StrTran( StrTran( aErro[nCount], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|"))
		Next nCount
	EndIf

Return cMsg
