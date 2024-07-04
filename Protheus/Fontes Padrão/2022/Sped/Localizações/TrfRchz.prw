#Include 'Protheus.ch'  
#Include "Fina855.ch"
#Include "ARGWSLPEG.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TrfRchz³ Autor ³Danilo Santos           ³ Data ³.08.2019    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Transmissão do Rechazo das facturas de credito              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function TrfRchz() 

Local cURL			:= (PadR(GetNewPar("MV_ARGFEUR","http://"),250))   
Local cIdEnt		:= ""
Local nComp		:= 0
Local lExecute	:= .T.
Local cTeste1		:= ""
Local cTeste3		:= ""
Local cMensagem	:= ""
Local nTamDoc		:= 0
Local nTot			:= 0
Local nTotRet		:= 0
Local n2			:= 0
Local cAmbiente	:= ""
Local cCodCtaCte	:= ""
Local aInfRet		:= {}
Local cTotRet		:= ""
Local cMonitor	:= ""
Local nA, nB		:= 0
Local nComp		:= 0
Local lRetOk		:= .F.
Local lcont		:= .F.
Local cQuery		:= ""
Local cAliasTrb	:= ""
Local nRegFVT		:= 0
Local cPerg		:= "TRFRCHZ"
Local cCodRchz	:= ""
Local cDesvMot	:= ""
Local cJustRchz	:= ""
Local cMsgAfip	:= ""
Local lRet			:= .F.
Local lProRet		:= .T.

Private oWS
Private oWSE
Private oWSC
Private oWsr
Private oRetorno

If FVS->FVS_STATUS $ "3"
	MSGALERT(STR0104)
	lREt := .F.
ElseIf FVS->FVS_STATUS $ "4"
	MSGALERT(STR0105)
	lREt := .F.
ElseIf FVS->FVS_STATUS $ "5"
	MSGALERT(STR0106)
	lREt := .F.	
ElseIf FVS->FVS_STATUS $ "1|2"

	cCodCtaCte := FVS->FVS_CODCC

	lcont := MSGYESNO(STR0136,STR0137) //"Deseja realmente rechazar a conta corrente na AFIP?"###"Atenção"

	If !lcont
		lREt := .F.
		Return
	Endif
	
	If Pergunte(cPerg,.T.,STR0124)  

		If !Empty(cURL) 
	
			//³Obtem o codigo da entidade³
			cIdEnt  := StaticCall( Locxnf2, GetIdEnt) 
	
			If !Empty(cIdEnt)
				//³Obtem o ambiente de execucao do Totvs Services ARGN³
				oWS := WSNFECFGLOC():New()
				oWS:cUSERTOKEN := "TOTVS"
				oWS:cID_ENT    := cIdEnt
				oWS:nAmbiente  := 0	
				oWS:cModelo := "6"	
				oWS:_URL       := AllTrim(cURL)+"/NFECFGLOC.apw"
				oWS:CFGAMBLOC()
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
			
			cCodRchz	:= Mv_par01
			cDesvMot	:= Alltrim(Mv_par02)
			cJustRchz	:= Alltrim(Mv_par03)
			
			//Chamar metodo de rechazarfe
			oWSC := WSFECRED():New()
			oWSC:cUserToken  := "TOTVS"
			oWSC:cID_ENT     := cIdEnt
			oWSC:_URL        := AllTrim(cURL)+"/FECRED.apw" 
			oWSC:OWSFECTACTE:CCODCTACTE := Alltrim(cCodCtaCte)
		
			oWSC:OWSFECTACTE:OWSIDFACTUR := FECRED_IDFACT():New()
			oWSC:OWSFECTACTE:OWSIDFACTUR:CCODTIPOCMP :=""
			oWSC:OWSFECTACTE:OWSIDFACTUR:CCUITEMISSOR := ""
			oWSC:OWSFECTACTE:OWSIDFACTUR:CNROCOMP := ""
			oWSC:OWSFECTACTE:OWSIDFACTUR:CPTOVTA := ""
			oWSC:CCSERIE := ""
			oWSC:CCODMOTIVO := cCodRchz
			oWSC:CDESCMOTIVO := cDesvMot
			oWSC:CJUSTIFICACION := cJustRchz
		
			If oWSC:FECREDRECHAZAR()
				cMonitor := OWSC:OWSFECREDRECHAZARRESULT:OWSID:CSTRING[1]
			
				oWsr := WSFECRED():New()
				oWSr:cUSERTOKEN := "TOTVS"
				oWSr:cID_ENT := cIdEnt 
				oWSr:_URL := AllTrim(cURL)+"/FECRED.apw"
				sleep(5000)
				oWSr:cIdInicial    := cMonitor
				oWSr:cIdFinal      :=  cMonitor
				lRetOk := oWSR:RETRECHZCRED()
				If !lRetOk
					PrcRechazo(lRetOk)
				Endif			
				nA := 1
				nB := 1 
				oRetorno := oWsr:OWSRETRECHZCREDRESULT:OWSRECHAZAFECRED 
			
				If Len(oWsr:OWSRETRECHZCREDRESULT:OWSRECHAZAFECRED) == 0	
					lProRet := MSGYESNO(STR0140,STR0141)
					If lProRet 
						oWsr := WSFECRED():New()
						oWSr:cUSERTOKEN := "TOTVS"
						oWSr:cID_ENT := cIdEnt 
						oWSr:_URL := AllTrim(cURL)+"/FECRED.apw"
						sleep(5000)
						oWSr:cIdInicial    := cMonitor
						oWSr:cIdFinal      :=  cMonitor
						lRetOk := oWSR:RETRECHZCRED()
						If !lRetOk
							PrcRechazo(lRetOk)
						Endif
						nA := 1 
						nB := 1 
						oRetorno := oWsr:OWSRETRECHZCREDRESULT:OWSRECHAZAFECRED
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
				ElseIf oRetorno[nA]:CRESULT == " "
					cMensagem += STR0103 + CRLF 
					cMensagem += STR0084 + CRLF 
					cMensagem += STR0085 + CRLF 
					Aviso(STR0079,cMensagem,{"OK"},3)
					lREt := .F.
					Return lREt
				ElseIf oRetorno[nA]:CRESULT == "R"
					If Len(oRetorno[nA]:OWSRECHAZAERROR:OWSRECHERRORARR) == 1 .And. (oRetorno[nA]:OWSRECHAZAERROR:OWSRECHERRORARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRECHAZAERROR:OWSRECHERRORARR[nB]:CDESCR <> "")
						cMensagem += STR0113 + CRLF//Retorno Afip
						cMensagem += STR0114 + oRetorno[nA]:OWSRECHAZAERROR:OWSRECHERRORARR[nB]:CCODIGO  + CRLF
						cMensagem += STR0115 + oRetorno[nA]:OWSRECHAZAERROR:OWSRECHERRORARR[nB]:CDESCR + CRLF
						Aviso(STR0079,cMensagem,{"OK"},3)
						lREt := .F.
						cMsgAfip := oRetorno[nA]:OWSRECHAZAERROR:OWSRECHERRORARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRECHAZAERROR:OWSRECHERRORARR[nB]:CDESCR
					ElseIf Len(oRetorno[nA]:OWSRECHAZAERROR:OWSRECHERRORARR) > 1 .And. (oRetorno[nA]:OWSRECHAZAERROR:OWSRECHERRORARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRECHAZAERROR:OWSRECHERRORARR[nB]:CDESCR <> "")
						cMensagem += STR0113 + CRLF
						For nB := 1 To Len(oRetorno[nA]:OWSRESPERROR:OWSERRORARR)
							cMensagem += STR0114 + oRetorno[nA]:OWSRECHAZAERROR:OWSRECHERRORARR[nB]:CCODIGO + CRLF
							cMensagem += STR0115 + oRetorno[nA]:OWSRECHAZAERROR:OWSRECHERRORARR[nB]:CDESCR + CRLF 
							cMsgAfip += oRetorno[nA]:OSRECHAZAERROR:OWSRECHERRORARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRECHAZAERROR:OWSRECHERRORARR[nB]:CDESCR + CRLF
						Next nB
						Aviso(STR0079,cMensagem,{"OK"},3)
						lREt := .F.
					ElseIf Len(oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR) == 1 .And. (oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR[nB]:CDESCR <> "")
						cMensagem += STR0113 + CRLF //Retorno Afip
						cMensagem += STR0114 + oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR[nB]:CCODIGO + CRLF
						cMensagem += STR0115 + oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR[nB]:CDESCR + CRLF 
						Aviso(STR0079,cMensagem,{"OK"},3)
						lREt := .F.
						cMsgAfip := oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR[nB]:CDESCR
					ElseIf Len(oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR) > 1 .And. (oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR[nB]:CDESCR <> "")
						cMensagem += STR0113 + CRLF
						For nB := 1 To Len(oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR)
							cMensagem += STR0114 + oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CCODIGO + CRLF
							cMensagem += STR0115 + oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CDESCR + CRLF 
							cMsgAfip += oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CDESCR + CRLF
						Next nB
						Aviso(STR0079,cMensagem,{"OK"},3)
						lREt := .F.	
					ElseIf	Len(oRetorno[nA]:OWSRECHPOBSERVA:OWSROCHSARR) == 1 .And. (oRetorno[nA]:OWSRECHPOBSERVA:OWSROCHSARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRECHPOBSERVA:OWSROCHSARR[nB]:CDESCR <> "" )
						cMensagem += STR0113 + CRLF //Retorno Afip
						cMensagem += STR0114 + oRetorno[nA]:OWSRECHPOBSERVA:OWSROCHSARR[nB]:CCODIGO + CRLF
						cMensagem += STR0115 + oRetorno[nA]:OWSRECHPOBSERVA:OWSROCHSARR[nB]:CDESCR + CRLF 
						Aviso(STR0079,cMensagem,{"OK"},3)
						lREt := .F.
						cMsgAfip := oRetorno[nA]:OWSRECHPOBSERVA:OWSROCHSARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRECHPOBSERVA:OWSROCHSARR[nB]:CDESCR
					ElseIf Len(oRetorno[nA]:OWSRECHPOBSERVA:OWSROCHSARR) > 1 .And. (oRetorno[nA]:OWSRECHPOBSERVA:OWSROCHSARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRECHPOBSERVA:OWSROCHSARR[nB]:CDESCR <> "" )
						cMensagem += STR0113 + CRLF
						For nB := 1 To Len(oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR)
							cMensagem += STR0114 + oRetorno[nA]:OWSRECHPOBSERVA:OWSROCHSARR[nB]:CCODIGO + CRLF
							cMensagem += STR0115 + oRetorno[nA]:OWSRECHPOBSERVA:OWSROCHSARR[nB]:CDESCR + CRLF 
							cMsgAfip += oRetorno[nA]:OWSRECHPOBSERVA:OWSROCHSARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRECHPOBSERVA:OWSROCHSARR[nB]:CDESCR + CRLF 
						Next nB
						Aviso(STR0079,cMensagem,{"OK"},3)
						lREt := .F.					
					EndiF
				ElseIf oRetorno[nA]:CRESULT == "A"	
					cMensagem += STR0107 + CRLF //Retorno Afip
					Aviso(STR0079,cMensagem,{"OK"},3)
					lREt := .T.
				Endif
				
				cquery += "SELECT * FROM " + RetSQLTab('FVT')  + "WHERE FVT_CODCC = '" + alltrim(cCodCtaCte) + "'" 
				cquery += "ORDER BY R_E_C_N_O_ "	
				cAliasTrb := GetNextAlias()
				cQuery    := ChangeQuery( cQuery )
				DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasTrb, .T., .F. )
				cIndice := CriaTrab( NIL, .F. ) 
				
				If lREt
	
					While !(cAliasTrb)->(Eof()) //FVT_FILIAL+FVT_CODCC+FVT_TIPO+FVT_CODIGO+FVT_LOJA+FVT_ESPECI+FVT_SERIE +FVT_DOC
		
						nRegFVT := (cAliasTrb)->R_E_C_N_O_
						
						dbSelectArea('FVT')
						dbSetorder(1)
		
						FVT->(dbGoto(nRegFVT))
						// Atualizando o status da conta corrente apos retorno da AFIP
						RecLock("FVT", .F.)
							FVT->FVT_STATUS := "3"
						MsUnlock()
						(cAliasTrb)->(DbSkip())
					Enddo

					//Atualizando o status da conta corrente apos retorno da AFIP
					dbSelectArea('FVS')
					dbSetorder(1)
					MsSeek(xFilial('FVS')+cCodCtaCte)
	
					RecLock("FVS", .F.)
						FVS->FVS_STATUS := "3"
						FVS->FVS_DTACRC := dDatabase
						FVT->FVT_RETAFP := ""
					MsUnlock()
							
				Else

					While !(cAliasTrb)->(Eof()) //FVT_FILIAL+FVT_CODCC+FVT_TIPO+FVT_CODIGO+FVT_LOJA+FVT_ESPECI+FVT_SERIE +FVT_DOC
		
						nRegFVT := (cAliasTrb)->R_E_C_N_O_
		
						dbSelectArea('FVT')
						dbSetorder(1)
		
						FVT->(dbGoto(nRegFVT))
						//Atualizando o status da conta corrente apos retorno da AFIP
						RecLock("FVT", .F.)
							FVT->FVT_STATUS := "2"
							FVT->FVT_RETAFP := Substr(cMsgAfip,1,TAMSX3("FVT_RETAFP")[1] )
						MsUnlock()
						(cAliasTrb)->(DbSkip())
		
					Enddo

					//Atualizando o status da conta corrente apos retorno da AFIP
					dbSelectArea('FVS')
					dbSetorder(1)
					MsSeek(xFilial('FVS')+cCodCtaCte)
	
					RecLock("FVS", .F.)
						FVS->FVS_STATUS := "2"
					MsUnlock()
	
				Endif

				(cAliasTrb)->(dbCloseArea())
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
		cMensagem += STR0126 + CRLF  
		Aviso(STR0079,cMensagem,{"OK"},3)
		lREt := .F.		
	Endif

Endif

Return lREt

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PrcRechazo³ Autor ³Danilo Santos           ³ Data ³.08.2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função que mostra o status de processamento ate o retorno da³±±
±±³          ³ AFIP - Argentina                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrcRechazo(lRetOk)

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
	lRetOk := oWSR:RETRECHZCRED() 
	nComp ++
EndDo
 
Return