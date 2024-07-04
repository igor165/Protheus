#Include 'Protheus.ch'  
#Include "Fina855.ch"
#Include "ARGWSLPEG.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TrfOPArg ³ Autor ³Danilo Santos            ³ Data ³.08.2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função que faz a transferencia do aceite na rotina de       ³±±
±±³          ³ Ordem de pagamento AFIP FINA850 - Argentina                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function TrfOPArg(oRegSFK) 

Local cURL			:= (PadR(GetNewPar("MV_ARGFEUR","http://"),250))
Local lWsFeCred	:= SuperGetMV( "MV_WSFECRD", .F., .F. )    
Local cIdEnt		:= ""
Local nComp		:= 0
Local lExecute	:= .T.
Local cTeste1		:= ""
Local cTeste3		:= ""
Local cMensagem	:= ""
Local nTamDoc		:= 0
Local nTot			:= 0
Local nImpCanc	:= 0
Local n2			:= 0
Local n3,n4		:= 0
Local cAmbiente	:= ""
Local aTitdoc		:= {}
Local cTotCanc	:= ""
Local cMonitor	:= ""
Local nA, nB		:= 0
Local nComp		:= 0
Local nDocNf		:= 0
Local lRetOk		:= .F.
Local lProcess	:= .T.
Local cCodCC		:= ""
Local cCodFor		:= ""
Local cLoja		:= ""
Local cEspecie	:= ""
Local cSerie		:= ""
Local cDoc			:= ""
Local cTPFVS		:= ""
Local cMsgAfip	:= ""
Local nRet			:= 0
Local nGrid		:= 0 
Local nTamDoc		:= 0
Local lProRet		:= .T.

Private oWS
Private oWSE
Private oWSC
Private oWsr
Private oRetorno

Default oRegSFK := Nil

//chamada do metodo wsfecred webservice
If cPaisLoc == 'ARG' .And. lWsFeCred
	//Chamar a função aqui
	If !Empty(cURL)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem o codigo da entidade                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cIdEnt  := StaticCall( Locxnf2, GetIdEnt) // GetIdEnt()
	
		If !Empty(cIdEnt)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtem o ambiente de execucao do Totvs Services ARGN                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oWS := WSNFECFGLOC():New()
			oWS:cUSERTOKEN := "TOTVS"
			oWS:cID_ENT    := cIdEnt
			oWS:nAmbiente  := 0	
			oWS:cModelo := "6"
			oWS:_URL       := AllTrim(cURL)+"/NFECFGLOC.apw"
			lOk := oWS:CFGAMBLOC()
			cAmbiente := oWS:CCFGAMBLOCRESULT
		Else
			lREt := .F.
			Aviso("NFFE", STR0132 + CHR(10) + CHR(13) +; // "No se detectó configuración de conexión con TSS."
							STR0133 + CHR(10) + CHR(13) +; // "Por favor, ejecute opción Wizard de Configuración."
							STR0134 + CHR(10) + CHR(13), ; // "Siga atentamente os passos para a configuração da nota fiscal eletrônica."
					{"OK"},3)
			Return		
		EndIf
	Else
		lREt := .F.
		Aviso("NFFE", STR0132 + CHR(10) + CHR(13) +; // "No se detectó configuración de conexión con TSS."
						STR0133 + CHR(10) + CHR(13) +; // "Por favor, ejecute opción Wizard de Configuración."
						STR0134 + CHR(10) + CHR(13), ; // "Siga atentamente os passos para a configuração da nota fiscal eletrônica."
						{"OK"},3)				
		Return
	EndIf

	oWSE:= WSNFESLOC():New()
	
	oWsE:cUserToken := "TOTVS"
	oWsE:cID_ENT    := cIdEnt
	oWSE:_URL       := AllTrim(cURL)+"/NFESLOC.apw"
	cData:=	 FsDateConv(Date(),"YYYYMMDD")
	cData := SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7)
	oWSE:CDATETIMEGER := cData+"T00:00:00"
	oWSE:cDATETIMEEXP := cData+"T23:59:59"
	oWsE:cCWSSERVICE  := "wsfecred"	
	
	oWSE:GETAUTHREM()	
	
	If GetWscError(1) == "" .Or. "005" $ GetWscError(1) .Or. "005" $ GetWscError(3) .Or. "006" $ GetWscError(3)
		lExecute := .T.
		cTeste1 := GetWscError(1)
		cTeste3 := GetWscError(3)
	
		If cTeste1 == Nil .Or. cTeste3 == Nil 
			lExecute:=.F.
			nComp:=1
			While nComp < 5 .And. !lExecute
				oWSE:GETAUTHREM()
				cTeste1 := GetWscError(1)
				cTeste3 := GetWscError(3)
				If cTeste1 <> Nil .And. cTeste3 <> Nil 	
					lExecute:=.T.
				EndIf	
				nComp:=nComp+1
			EndDo 
		Endif
		
		//Chamar metodo de aceite aqui
		oWSC := WSFECRED():New()
		oWSC:cUserToken  := "TOTVS"
		oWSC:cID_ENT     := cIdEnt
		oWSC:_URL        := AllTrim(cURL)+"/FECRED.apw" 
		cCodCC := Alltrim(MV_Par15)
		oWSC:OWSIDCTACTE:CCODCTACTE := cCodCC
		oWSC:OWSIDCTACTE:OWSIDFACTUR := FECRED_IDFACT():New()
		
		dbSelectArea('FVS')
		DbSetOrder(1)
		//FVS_FILIAL + FVS_CODCC + FVS_TIPO + FVS_CODIGO + FVS_LOJA
		MsSeek(xFilial('FVS')+ cCodCC ) 
		
		aTitdoc := aRECnoSE2
			
		If !Empty(oWSC:OWSIDCTACTE:CCODCTACTE)
			oWSC:OWSIDCTACTE:OWSIDFACTUR:CCODTIPOCMP :=""
			oWSC:OWSIDCTACTE:OWSIDFACTUR:CCUITEMISSOR := ""
			oWSC:OWSIDCTACTE:OWSIDFACTUR:CNROCOMP := ""
			oWSC:OWSIDCTACTE:OWSIDFACTUR:CPTOVTA := ""
		Else
			oWSC:OWSIDCTACTE:OWSIDFACTUR:CCODTIPOCMP :="" // pegar informação do campo verificar de onde vem
			oWSC:OWSIDCTACTE:OWSIDFACTUR:CCUITEMISSOR := "" // pegar informação do campo verificar de onde vem
			oWSC:OWSIDCTACTE:OWSIDFACTUR:CNROCOMP := "" // pegar informação do campo verificar de onde vem
			oWSC:OWSIDCTACTE:OWSIDFACTUR:CPTOVTA := "" // pegar informação do campo verificar de onde vem	
		Endif
		
		oWSC:OWSIMPCANCTOTFE := FECRED_FORMPAGOARR():New() // IMPCANCTOTFE -- FORMPAGOARR
		oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE := FECRED_ARRAYOFFORMPAGOCANC():New() //FORMPAGOFE --  ARRAYOFFORMPAGOCANC
		If nVlrPagar == 0
			//For nDocNf := 1 To Len(aTitdoc)
				AADD(oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC ,FECRED_FORMPAGOCANC ():New()) // FORMPAGOCANC  --   FORMPAGOCANC
				oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC[1]:CCODIGO := "1"
				oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC[1]:CDESCRIC := STR0120
			//Next nDocNf
		ElseIf nVlrPagar > 0 
			For nDocNf := 1 To Len(aTitdoc)	 
				If Alltrim (aTitdoc[nDocNf][7]) <> "NCP" 
					For nGrid := 1 to Len(oRegSFK:aCols)
						If Alltrim(oRegSFK:aCols[nGrid][1]) == "TF" .And. lProcess
							AADD(oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC ,FECRED_FORMPAGOCANC ():New())
							oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC[nGrid]:CCODIGO := "2"
							oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC[nGrid]:CDESCRIC := STR0121
						ElseIf Alltrim(oRegSFK:aCols[nGrid][1]) == "CH" .And. lProcess
							AADD(oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC ,FECRED_FORMPAGOCANC ():New())
							oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC[nGrid]:CCODIGO := "3"
							oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC[nGrid]:CDESCRIC := STR0122
						ElseIf	!(Alltrim(oRegSFK:aCols[nGrid][1]) $ "TF|CH") .And. lProcess
							AADD(oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC ,FECRED_FORMPAGOCANC ():New())
							oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC[nGrid]:CCODIGO := "5" 
							oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC[nGrid]:CDESCRIC := STR0123
						Endif
					Next nGrid
					lProcess := .F. 
				Endif
				If Alltrim (aTitdoc[nDocNf][7]) $ "NCP" 
					nTamDoc := Len(oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC) + 1
					AADD(oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC ,FECRED_FORMPAGOCANC ():New())
					oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC[nTamDoc]:CCODIGO := "1"
					oWSC:OWSIMPCANCTOTFE:OWSFORMPAGOFE:OWSFORMPAGOCANC[nTamDoc]:CDESCRIC := STR0120
				Endif	
			Next nDocNf
		Endif	
		If ! Empty(FVS->FVS_PREOP)
			oWSC:CIMPCANCELACION  := cvaltochar(nVlrPagar)//Valor total a ser pago variavel nVlrPagar
		Else
			oWSC:CIMPCANCELACION  := nSaldoCCr //Valor retornado pela consulta da conta corrente
		Endif
		If oWSC:INFCANCTOTALFECRED()
			cMonitor := OWSC:OWSINFCANCTOTALFECREDRESULT:OWSID:CSTRING[1] 
			
			oWsr := WSFECRED():New()
			oWSr:cUSERTOKEN := "TOTVS"
			oWSr:cID_ENT := cIdEnt 
			oWSr:_URL := AllTrim(cURL)+"/FECRED.apw"
			sleep(5000)
			oWSr:cIdInicial    := cMonitor
			oWSr:cIdFinal      :=  cMonitor 
			lRetOk := oWSR:RETORNAFECRED()
			
			If !lRetOk 
				PrcFeCred(lRetOk)
			Endif
						
			nA := 1
			nB := 1
			oRetorno := oWsr:OWSRETORNAFECREDRESULT:OWSRESPONSEFECRED
			
			If Len(oWsr:OWSRETORNAFECREDRESULT:OWSRESPONSEFECRED) == 0	
				lProRet := MSGYESNO(STR0140,STR0141)
				If lProRet 
					oWsr := WSFECRED():New()
					oWSr:cUSERTOKEN := "TOTVS"
					oWSr:cID_ENT := cIdEnt 
					oWSr:_URL := AllTrim(cURL)+"/FECRED.apw"
					sleep(5000)
					oWSr:cIdInicial    := cMonitor
					oWSr:cIdFinal      :=  cMonitor
					lRetOk := oWSR:RETORNAFECRED()
					If !lRetOk 
						PrcFeCred(lRetOk)
					Endif
					nA := 1
					nB := 1
					oRetorno := oWsr:OWSRETORNAFECREDRESULT:OWSRESPONSEFECRED
				Else
					lREt := .F.
					Return lREt
				Endif
			Endif
			
			If (valtype(oRetorno) == "A" .And. Len(oRetorno) == 0) 
				cMensagem += STR0102 + CRLF
				Aviso(STR0079,cMensagem,{"OK"},3)
				lREt := .F.
				Return lREt
			ElseIf oRetorno[nA]:CRESULTADO == " "
				cMensagem += STR0103 + CRLF 
				cMensagem += STR0084 + CRLF 
				cMensagem += STR0085 + CRLF 
				Aviso(STR0079,cMensagem,{"OK"},3)
				lREt := .F.
				Return lREt
			ElseIf oRetorno[nA]:CRESULTADO == "R"
				If Len(oRetorno[nA]:OWSRESPERROR:OWSERRORARR) == 1 .And. (oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CDESCR <> "")
					cMensagem += STR0118 + CRLF//Retorno Afip
					cMensagem += STR0114 + oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CCODIGO  + CRLF
					cMensagem += STR0115 + oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CDESCR + CRLF
					Aviso(STR0079,cMensagem,{"OK"},3)
					cMsgAfip := oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CDESCR 
					lREt := .F.
				ElseIf Len(oRetorno[nA]:OWSRESPERROR:OWSERRORARR) > 1 .And. (oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CDESCR <> "")
					cMensagem += STR0118 + CRLF
					For nB := 1 To Len(oRetorno[nA]:OWSRESPERROR:OWSERRORARR)
						cMensagem += STR0114 + oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CCODIGO + CRLF
						cMensagem += STR0115 + oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CDESCR + CRLF
						cMsgAfip += oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CDESCR
					Next nB
					Aviso(STR0079,cMensagem,{"OK"},3)
					lREt := .F.
				ElseIf Len(oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR) == 1 .And. (oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CDESCR <> "")
					cMensagem += STR0118 + CRLF //Retorno Afip
					cMensagem += STR0114 + oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CCODIGO + CRLF
					cMensagem += STR0115 + oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CDESCR + CRLF 
					Aviso(STR0079,cMensagem,{"OK"},3)
					cMsgAfip := oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CDESCR
					lREt := .F.
				ElseIf Len(oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR) > 1 .And. (oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CDESCR <> "")
					cMensagem += STR0118 + CRLF
					For nB := 1 To Len(oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR)
						cMensagem += STR0114 + oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CCODIGO + CRLF
						cMensagem += STR0115 + oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CDESCR + CRLF 
						cMsgAfip += oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CDESCR
					Next nB
					Aviso(STR0079,cMensagem,{"OK"},3)
					lREt := .F.
				ElseIf	Len(oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR) == 1 .And. (oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CDESCR <> "" )
					cMensagem += STR0118 + CRLF //Retorno Afip
					cMensagem += STR0114 + oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CCODIGO + CRLF
					cMensagem += STR0115 + oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CDESCR + CRLF
					Aviso(STR0079,cMensagem,{"OK"},3)
					cMsgAfip := oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CDESCR
					lREt := .F.
				ElseIf Len(oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR) > 1 .And. (oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CDESCR <> "" )
					cMensagem += STR0118 + CRLF
					For nB := 1 To Len(oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR)
						cMensagem += STR0114 + oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CCODIGO + CRLF
						cMensagem += STR0115 + oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CDESCR + CRLF 
						cMsgAfip += oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CCODIGO + " - " +  oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CDESCR
					Next nB
					Aviso(STR0079,cMensagem,{"OK"},3)
					lREt := .F.					
				EndiF
				
				cCodCC := FVS->FVS_CODCC
				cTPFVS := FVS->FVS_TIPO
				cCodFor := FVS->FVS_CODIGO
				cLoja := FVS->FVS_LOJA
				RecLock("FVS", .F.)
					FVS->FVS_STATUS := "2"
				MsUnlock()
				
				For nRet := 1 To Len(aTitDoc)
					dbSelectArea('FVT')
					DbSetOrder(1)
					//FVT_FILIAL + FVT_CODCC + FVT_TIPO + FVT_CODIGO + FVT_LOJA + FVT_ESPECI + FVT_SERIE + FVT_DOC					
					MsSeek(xFilial('FVT')+ cCodCC + cTPFVS + cCodFor + cLoja + aTitDoc[nRet][7] + aTitDoc[nRet][4] + aTitDoc[nRet][5])
					RecLock("FVT", .F.)
						FVT->FVT_STATUS := "2"
						FVT->FVT_RETAFP := Substr(cMsgAfip,1,TAMSX3("FVT_RETAFP")[1] )
					MsUnlock() 
				Next nRet
				
			ElseIf oRetorno[nA]:CRESULTADO == "A"	
				cMensagem += STR0119 + CRLF //Retorno Afip
				cMensagem += STR0117 + CRLF //Retorno Afip
				Aviso(STR0079,cMensagem,{"OK"},3)
					
				//Habilitar para mudar os stuatus das tabelas FVS e FVT
				dbSelectArea('FVS')
				DbSetOrder(1)
				//FVS_FILIAL + FVS_CODCC + FVS_TIPO + FVS_CODIGO + FVS_LOJA
				MsSeek(xFilial('FVS')+ cCodCC ) 
				
				cCodCC := FVS->FVS_CODCC
				cTPFVS := FVS->FVS_TIPO
				cCodFor := FVS->FVS_CODIGO
				cLoja := FVS->FVS_LOJA
				
				RecLock("FVS", .F.)
					FVS->FVS_STATUS := "5"
					FVS->FVS_DTOP := dDataBase
					FVS->FVS_VLTOT := 0
				MsUnlock()
				
				For nRet := 1 To Len(aTitDoc)
					dbSelectArea('FVT')
					DbSetOrder(1)
					//FVT_FILIAL + FVT_CODCC + FVT_TIPO + FVT_CODIGO + FVT_LOJA + FVT_ESPECI + FVT_SERIE + FVT_DOC					
					MsSeek(xFilial('FVT')+ cCodCC + cTPFVS + cCodFor + cLoja + aTitDoc[nRet][7] + aTitDoc[nRet][4] + aTitDoc[nRet][5])
					RecLock("FVT", .F.)
						FVT->FVT_STATUS := "5"
						FVT->FVT_RETAFP := ""
					MsUnlock() 
				Next nRet
				
				lREt := .T.
			Endif
		Else
			lREt := .F.
		Endif
		
	Else
		If cTeste1 <> Nil
			MsgInfo(GetWscError(1))
		Else
			Aviso("NFFE", STR0132 + CHR(10) + CHR(13) +; // "No se detectó configuración de conexión con TSS."
							STR0133 + CHR(10) + CHR(13) +; // "Por favor, ejecute opción Wizard de Configuración."
							STR0134 + CHR(10) + CHR(13), ; // "Siga atentamente os passos para a configuração da nota fiscal eletrônica."
					{"OK"},3)
		EndIf 	
	Endif
Else
	lREt := .T.
Endif

Return lREt

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PrcFeCred³ Autor ³Danilo Santos           ³ Data ³.08.2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função que mostra o status de processamento ate o retorno da³±±
±±³          ³ AFIP - Argentina                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrcFeCred(lRetOk)

	MsAguarde({|lRetOk| Processa(@lRetOk)},STR0100,STR0101)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Processa³ Autor ³Danilo Santos          ³ Data ³.08.2019    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função que faz a consulta ate obter o retorno da AFIP       ³±±
±±³          ³Argentina                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Processa(lRetOk)
    
Local ncomp := 0    
    
While nComp < 20 .And. !lRetOk
	sleep(3000)
	lRetOk := oWSR:RETORNAFECRED()
	nComp ++
EndDo
 
Return