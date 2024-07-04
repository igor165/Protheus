#Include "Protheus.ch"
#Include "ParmType.ch"

/*/{Protheus.doc} IPAGEN05

Rotina respons�vel pelo envio de notifica��o de compras

@type 	 function
@author  Ectore Cecato - Totvs IP Jundia�
@since 	 14/01/2018
@version Protheus 12 - Gen�rico

/*/

User Function IPAGEN05(cFilDoc, cDoc, cTipoDoc, cObs)
	
	ConOut("Inicio do IPAGEN05")
	
	If cTipoDoc == "SC"
		ExecSC(cFilDoc, cDoc, cObs)
	ElseIf cTipoDoc $ "IP|PC|"
		ConOut("IPAGEN05_execPC")
		ExecPC(cFilDoc, cDoc, cObs)
	EndIf
	
Return .T.

Static Function ExecSC(cFilDoc, cDoc, cObs)
	
	Local aArea		:= GetArea()
	Local aAreaSC1	:= SC1->(GetArea())
	Local cMsg		:= ""
	
	DbSelectArea("SC1")
		
	SC1->(DbSetOrder(1))
		
	If SC1->(DbSeek(cFilDoc + cDoc))
		
		If SC1->C1_APROV == "L"
			
			U_COMH001(cDoc, "SC", "Solicita��o Aprovada")

			cMsg := "A Solicita��o de Compras "+ SC1->C1_NUM +" do solicitante "+ AllTrim(SC1->C1_SOLICIT) 
			cMsg += " est� aprovada na empresa "+ AllTrim(SM0->M0_NOMECOM) +"."
			
		ElseIf SC1->C1_APROV == "R"
			
			U_COMH001(cDoc, "SC", "Solicita��o Rejeitada")
			U_COMH001(cDoc, "SC", "Motivo: "+ AllTrim(cObs))					

			cMsg := "A Solicita��o de Compras "+ SC1->C1_NUM +" do solicitante "+ AllTrim(SC1->C1_SOLICIT) +" foi rejeitada na empresa "
			cMsg += AllTrim(SM0->M0_NOMECOM) +", pelo motivo: "+ AllTrim(cObs)
			
		EndIf
		
		If !Empty(cMsg)
			
			u_SCEMail(UsrRetMail(SC1->C1_USER), "Status da Solicita��o de Compras", cMsg, "")
			//StaticCall(SCACOM03, SendSCmail, cMsg, SC1->C1_USER, SC1->C1_GRUPCOM)		
			//SendSCmail(cMsg, SC1->C1_USER, SC1->C1_GRUPCOM)
		EndIf
		
	EndIf
		
	RestArea(aAreaSC1)
	RestArea(aArea)
				
Return Nil

Static Function ExecPC(cFilDoc, cDoc, cObs)
	
	Local aArea		:= GetArea()
	Local aAreaSC7	:= SC7->(GetArea())
	Local cMsg		:= ""
	
	Private oLog := u_WFIPGetLogObj()
	Private LENTCONT := .F.

	
	DbSelectArea("SC7")
	
	SC7->(DbSetOrder(1))
		
	If SC7->(DbSeek(cFilDoc + cDoc))
		
		ConOut("IPAGEN05_PosSC7")
		
		If SC7->C7_CONAPRO == "L"
			
			cMsg := "Documento Liberado"

			//Julio Lisboa - FSW TOTVS IP Campinas - 12/05/2016
			U_PedEnviar(3, cDoc)
			ConOut("Passou pelo ponto de entrada na Libera��o")
			//26/10/2021 - Ajuste da Chamada StaticCall, devido a compila��o bloqueada a partir da vers�o 12.1.33
			//StaticCall(SCACOM03, GrvDataLiber, SC7->C7_NUM)
			U_GrvDataLiber(SC7->C7_NUM)
			//26/10/2021 - Ajuste da Chamada StaticCall, devido a compila��o bloqueada a partir da vers�o 12.1.33
			//StaticCall(WFPC, InformaResp, SC7->C7_NUM, .T.)
			If ExistBlock("WFPC")
				&("StaticCall(WFPC, InformaResp, SC7->C7_NUM, .T.)")
			Endif
			
		
		ElseIf SC7->C7_CONAPRO == "R"
			ConOut("Passou pelo ponto de entrada na Rejei��o")
			//26/10/2021 - Ajuste da Chamada StaticCall, devido a compila��o bloqueada a partir da vers�o 12.1.33
			//StaticCall(WFPC, InformaResp, SC7->C7_NUM, .F.)
			If ExistBlock("WFPC")
				&("StaticCall(WFPC, InformaResp, SC7->C7_NUM, .F.)")
			Endif
		
			cMsg := "Documento Reprovado"
			
		EndIf
		
		If !Empty(cMsg)
			U_COMH001(cDoc, "PC", cMsg)
		EndIf
		
	EndIf
	
	RestArea(aAreaSC7)
	RestArea(aArea)
	
Return Nil
