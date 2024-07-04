#Include 'Protheus.ch'  
#Include "Fina855.ch"
#Include "ARGWSLPEG.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TrfDebCred³ Autor ³Danilo Santos           ³ Data ³.09.2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Transmissão do Rechado das facturas de credito e debito     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function TrfDebCred(aRetGrid)

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
Local nGrid		:= 1
Local cCodCmp		:= ""
Local cCuit		:= ""
Local cMsgAfip	:= ""
Local nTamDoc		:= 0
local lTransmis	:= .F.
Local lProRet		:= .T.

Private oWS
Private oWSE
Private oWSC
Private oWsr
Private oRetorno 

Default aRetGrid	:= {}

dbSelectArea('FVT')
DbSetOrder(1)
//FVT_FILIAL + FVT_CODCC + FVT_TIPO + FVT_CODIGO + FVT_LOJA + FVT_ESPECI + FVT_SERIE + FVT_DOC
MsSeek(xFilial('FVT')+ aRetGrid[nGrid][1] + aRetGrid[nGrid][2] + aRetGrid[nGrid][3] + aRetGrid[nGrid][4] + aRetGrid[nGrid][5] + aRetGrid[nGrid][6] + aRetGrid[nGrid][7]) 

If "NF" $ Alltrim(FVT->FVT_ESPECI)
	lREt := .F.
	cMensagem += STR0077 + CRLF //STR0077
	cMensagem += STR0078 + CRLF
	Aviso(STR0079,cMensagem,{"OK"},3)
ElseIf FVT->FVT_STATUS $ "3"
	lREt := .F.
	cMensagem += STR0080 + CRLF //Retorno Afip 
	Aviso(STR0079,cMensagem,{"OK"},3)
	//lREt := .F.
ElseIf FVT->FVT_STATUS $ "5"
	lREt := .F.
	cMensagem += STR0081 + CRLF //Retorno Afip 
	Aviso(STR0079,cMensagem,{"OK"},3)
ElseIf FVT->FVT_STATUS $ "1|2"

	cCodCtaCte := FVT->FVT_CODCC
	
	lcont := MSGYESNO(STR0138 + " " + CRLF + CRLF + aRetGrid[nGrid][5]+ " " + aRetGrid[nGrid][7],STR0139) //"Deseja realmente rechazar o documento na AFIP?"###"Atenção"

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
			
			//Chamar metodo de rechazarnotadc
			oWSC := WSFECRED():New()
			oWSC:cUserToken  := "TOTVS"
			oWSC:cID_ENT     := cIdEnt
			oWSC:_URL        := AllTrim(cURL)+"/FECRED.apw" 
 
			//oWSC:OWSFECTACTE:CCODCTACTE := ""
			cCodCmp := CodTpCmp(FVT->FVT_ESPECI,FVT->FVT_SERIE)
			
			dbSelectArea('SA2')  //A2_FILIAL+A2_COD+A2_LOJA
			DbSetOrder(1)
			MsSeek(xFilial('SA2') + aRetGrid[nGrid][3] + aRetGrid[nGrid][4] ) 
			cCuit := SA2->A2_CGC
			nTamDoc := Len(Alltrim(FVT->FVT_DOC))
			
			oWSC:OWSFECTACTE:OWSIDFACTUR := FECRED_IDFACT():New()
			oWSC:OWSFECTACTE:OWSIDFACTUR:CCODTIPOCMP := cCodCmp
			oWSC:OWSFECTACTE:OWSIDFACTUR:CCUITEMISSOR := cCuit
			oWSC:OWSFECTACTE:OWSIDFACTUR:CNROCOMP := IIf(nTamDoc > 12,SubStr(FVT->FVT_DOC,6,8),SubStr(FVT->FVT_DOC,5,8))
			oWSC:OWSFECTACTE:OWSIDFACTUR:CPTOVTA := IIf(nTamDoc > 12,SubStr(FVT->FVT_DOC,1,5),SubStr(FVT->FVT_DOC,1,4))
			oWSC:CCSERIE := FVT->FVT_SERIE
			oWSC:CCODMOTIVO := cCodRchz
			oWSC:CDESCMOTIVO := cDesvMot
			oWSC:CJUSTIFICACION := cJustRchz
		
			If oWSC:RECHAZARNOTADC() 
				cMonitor := OWSC:OWSRECHAZARNOTADCRESULT:OWSID:CSTRING[1]
			
				oWsr := WSFECRED():New()
				oWSr:cUSERTOKEN := "TOTVS"
				oWSr:cID_ENT := cIdEnt 
				oWSr:_URL := AllTrim(cURL)+"/FECRED.apw"
				sleep(5000)
				oWSr:cIdInicial    := cMonitor
				oWSr:cIdFinal      :=  cMonitor
				lRetOk := oWSR:RETRECHZCRED()
				If !lRetOk
					PrcRechDB(lRetOk) 
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
							PrcRechDB(lRetOk) 
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
					cMensagem += STR0082 + CRLF
					Aviso(STR0079,cMensagem,{"OK"},3)
					lREt := .F.
				ElseIf oRetorno[nA]:CRESULT == " "
					cMensagem += STR0083 + CRLF 
					cMensagem += STR0084 + CRLF 
					cMensagem += STR0085 + CRLF 
					Aviso(STR0079,cMensagem,{"OK"},3)
					lREt := .F.
					lTransmis := .F.
					Return lREt
				ElseIf oRetorno[nA]:CRESULT == "R"
					lTransmis := .T.
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
							cMsgAfip += oRetorno[nA]:OWSRECHAZAERROR:OWSRECHERRORARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRECHAZAERROR:OWSRECHERRORARR[nB]:CDESCR + CRLF
						Next nB
						Aviso(STR0079,cMensagem,{"OK"},3)
						lREt := .F.
					ElseIf Len(oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR) == 1 .And. (oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR[nB]:CDESCR <> "")
						cMensagem += STR0113 + CRLF //Retorno Afip
						cMensagem += STR0114 + oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR[nB]:CCODIGO + CRLF
						cMensagem += STR0115 + oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR[nB]:CDESCR + CRLF 
						Aviso(STR0079,cMensagem,{"OK"},3)
						lREt := .F.
						cMsgAfip := Retorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRECHAZAERRFORM:OWSRECHERRFORMARR[nB]:CDESCR
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
					lTransmis := .T.	
					cMensagem += STR0125 + CRLF //Retorno Afip
					Aviso(STR0079,cMensagem,{"OK"},3)
					lREt := .T.
				Endif
				If lTransmis 
					If lREt
						RecLock("FVT", .F.)
							FVT->FVT_STATUS := "3"
							FVT->FVT_RETAFP := ""
						MsUnlock()			
					Else
						RecLock("FVT", .F.)
							FVT->FVT_STATUS := "2"
							FVT->FVT_RETAFP := Substr(cMsgAfip,1,TAMSX3("FVT_RETAFP")[1] )
						MsUnlock()
					Endif
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
±±³Programa  ³PrcRechDB³ Autor ³Danilo Santos           ³ Data ³.08.2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função que mostra o status de processamento ate o retorno da³±±
±±³          ³ AFIP - Argentina                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrcRechDB(lRetOk)

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
    
While nComp < 15 .And. !lRetOk
	sleep(3000)
	lRetOk := oWSR:RETRECHZCRED() 
	nComp ++
EndDo
 
Return

/*/
CÓDIGO	DESCRIPCIÓN
201	FACTURA DE CRÉDITO ELECTRÓNICA MiPyMEs (FCE) A
202	NOTA DE DÉBITO ELECTRÓNICA MiPyMEs (FCE) A
203	NOTA DE CRÉDITO ELECTRÓNICA MiPyMEs (FCE) A
206	FACTURA DE CRÉDITO ELECTRÓNICA MiPyMEs (FCE) B
207	NOTA DE DÉBITO ELECTRÓNICA MiPyMEs (FCE) B
208	NOTA DE CRÉDITO ELECTRÓNICA MiPyMEs (FCE) B
211	FACTURA DE CRÉDITO ELECTRÓNICA MiPyMEs (FCE) C
212	NOTA DE DÉBITO ELECTRÓNICA MiPyMEs (FCE) C
213	NOTA DE CRÉDITO ELECTRÓNICA MiPyMEs (FCE) C
/*/


Static Function CodTpCmp(cEspeci,cSerie)

Local cCodTpCmp	:= ""
Local nTipo		:= 0

Default cEspeci	:= ""
Default cSerie	:= ""

cSerie := SubStr(cSerie,1,1)

If ALLTRIM(UPPER(cEspeci))$"NDP|NCI"
	nTipo :=1
ElseIf ALLTRIM(UPPER(cEspeci))$"NCP|NDI"
	nTipo :=2
ElseIf ALLTRIM(UPPER(cEspeci))$ "NF"
	nTipo :=3
EndIf

Do Case
Case nTipo == 1 .And. cSerie $ "A"
	cCodTpCmp := "202"
Case nTipo == 1 .And. cSerie $ "B"
	cCodTpCmp := "207"
Case nTipo == 1 .And. cSerie $ "C"
	cCodTpCmp := "212"
Case nTipo == 2 .And. cSerie $ "A"
	cCodTpCmp := "203"
Case nTipo == 2 .And. cSerie $ "B"
	cCodTpCmp := "206"
Case nTipo == 2 .And. cSerie $ "C"
	cCodTpCmp := "211"
EndCase

Return cCodTpCmp