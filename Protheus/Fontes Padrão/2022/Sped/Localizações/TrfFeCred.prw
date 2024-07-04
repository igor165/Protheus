#Include 'Protheus.ch' 
#Include "Fina855.ch"
#Include "ARGWSLPEG.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TrfFeCred³ Autor ³Danilo Santos            ³ Data ³.08.2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função que faz a transferencia do aceite na rotina de pre   ³±±
±±³          ³ Ordem de pagamento AFIP - Argentina                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function TrfFeCred(nAltCBU)

Local cURL			:= (PadR(GetNewPar("MV_ARGFEUR","http://"),250))
Local lWsFeCred	:= SuperGetMV( "MV_WSFECRD", .F., .F. ) 
Local cCBUCom	:= SuperGetMV( "MV_CBUCOM", .F., "" )   
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
Local n3,n4		:= 0
Local cAmbiente	:= ""
Local aInfRet		:= {}
Local aTitdoc		:= {}
Local cTotRet		:= ""
Local cMonitor	:= ""
Local nA, nB		:= 0
Local nComp		:= 0
Local nRet			:= 0
Local nDocNf		:= 0
Local cSerie		:= ""
Local lRetOk		:= .F.
Local lProRet		:= .T.
Local nDocNDNC	:= 0
Local nSld			:= 0
Local nSldAcpto	:= 0
Local cSldAcpto	:= ""
Local lCriou		:= .F.
Local cMsgAfip	:= ""
Local cCODCC		:= ""
Local aAreaSE2	:= {}
Local cMoeda		:= ""
Local nRetAux		:= 0 
Local aAreaFVS	 	:= {}
Local aAreaFVT	 	:= {}

Private oWS
Private oWSE
Private oWSC
Private oWsr
Private oRetorno
Private lAutAfip :=  GetNewPar("MV_AUTAFIP",.F.)

Default nAltCBU := 2

//chamada do metodo wsfecred webservice
If cPaisLoc == 'ARG' .And. lWsFeCred

	if lAutAfip
		cURL := "http://"
	endif

	//Chamar a função aqui
	If !Empty(cURL)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem o codigo da entidade                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		if !lAutAfip
			cIdEnt  := StaticCall( Locxnf2, GetIdEnt) // GetIdEnt()
		else
			cIdEnt := "000001"
		endif
		If !Empty(cIdEnt)
			if !lAutAfip
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
			else
				lOk := .T.
			endif
				
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
	if !lAutAfip
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
	ENDIF

	If (GetWscError(1) == "" .Or. "005" $ GetWscError(1) .Or. "005" $ GetWscError(3) .Or.  "006" $ GetWscError(3)) .OR. !lAutAfip
		lExecute := .T.
		cTeste1 := GetWscError(1)
		cTeste3 := GetWscError(3)
	
		if !lAutAfip
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
		endif
		
		cCODCC := Alltrim(MV_Par10)
		
		//Concultar a conta correntepar atualizar o campo de opção de transferencia
		if !lAutAfip
			aConsTRF := ConsCCArg(cCODCC)
		else
			aConsTRF := {.T., "SCA"}
		endif
			
		//Chamar metodo de aceite aqui
		if !lAutAfip
			oWSC := WSFECRED():New()
			oWSC:cUserToken  := "TOTVS"
			oWSC:cID_ENT     := cIdEnt
			oWSC:_URL        := AllTrim(cURL)+"/FECRED.apw" 
			oWSC:OWSIDCTACTE:CCODCTACTE := cCODCC
			oWSC:OWSIDCTACTE:OWSIDFACTUR := FECRED_IDFACT():New()
			
			aTitdoc := aSE2[1][1]
			
			oWSC:OWSIDCTACTE:OWSIDFACTUR:CCODTIPOCMP :=""
			oWSC:OWSIDCTACTE:OWSIDFACTUR:CCUITEMISSOR := ""
			oWSC:OWSIDCTACTE:OWSIDFACTUR:CNROCOMP := ""
			oWSC:OWSIDCTACTE:OWSIDFACTUR:CPTOVTA := ""
					
			oWSC:CCSERIE := Alltrim(cSerie) //Informar o campo da serie para gravação do id nas tabelas do TSS
			
			//oWSC:OWSCONFNOTASDC:OWSNTCREDDC  := FECRED_NOTASDCARR():New() 
			//oWSC:OWSCONFNOTASDC:OWSNTCREDDC := FECRED_ARRAYOFNOTASDC():New()
			
			If Len(aTitdoc) == 1
			
				n4 := n4 + 1
				oWSC:OWSCONFNOTASDC:OWSNTCREDDC  := FECRED_NOTASDCARR():New() 
				oWSC:OWSCONFNOTASDC:OWSNTCREDDC := FECRED_ARRAYOFNOTASDC():New()
				AADD(oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC,FECRED_NOTASDC():New())
				oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:OWSIDNOTA := FECRED_IDCOMP():New()
				oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:CACEPTA := "" 

				oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:OWSIDNOTA:CCODTIPOCMP := "" //StaticCall( TrfDebCred, CodTpCmp,SF1->F1_ESPECIE,SF1->F1_SERIE)
				oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:OWSIDNOTA:CCUITEMISSOR := ""  //cCuit 
				oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:OWSIDNOTA:CNROCMP := "" //IIf(nTamDoc > 12,SubStr(SF1->F1_DOC,6,8),SubStr(SF1->F1_DOC,5,8))
				oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:OWSIDNOTA:CPTOVTA := "" //IIf(nTamDoc > 12,SubStr(SF1->F1_DOC,1,5),SubStr(SF1->F1_DOC,1,4))
			
			ElseIf Len(aTitdoc) > 1
				
				oWSC:OWSCONFNOTASDC:OWSNTCREDDC  := FECRED_NOTASDCARR():New() 
				oWSC:OWSCONFNOTASDC:OWSNTCREDDC := FECRED_ARRAYOFNOTASDC():New()
				
				For nDocNDNC := 1 To Len(aTitdoc)
				
					//AADD(oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC,FECRED_NOTASDC():New())
					//oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[1]:OWSIDNOTA := FECRED_IDCOMP():New()
				
					If alltrim(aTitdoc[nDocNDNC][12]) $ "NDP"
						n4 := n4 + 1
						AADD(oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC,FECRED_NOTASDC():New())
						oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:OWSIDNOTA := FECRED_IDCOMP():New()
						oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:CACEPTA := "S"
						dbSelectArea('SF1')
						DbSetOrder(1)
						//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
						MsSeek(xFilial('SF1')+ aTitdoc[nDocNDNC][10] + aTitdoc[nDocNDNC][9] + aTitdoc[nDocNDNC][1] + aTitdoc[nDocNDNC][2]) 
					
						dbSelectArea('SA2')  //A2_FILIAL+A2_COD+A2_LOJA
						DbSetOrder(1)
						MsSeek(xFilial('SA2')+ aTitdoc[nDocNDNC][1] + aTitdoc[nDocNDNC][2] ) 
					
						cCuit := Alltrim(SA2->A2_CGC)
						nTamDoc := Len(SF1->F1_DOC)
					
						oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:OWSIDNOTA:CCODTIPOCMP := StaticCall( TrfDebCred, CodTpCmp,SF1->F1_ESPECIE,SF1->F1_SERIE)
						oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:OWSIDNOTA:CCUITEMISSOR := cCuit 
						oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:OWSIDNOTA:CNROCMP := IIf(nTamDoc > 12,SubStr(SF1->F1_DOC,6,8),SubStr(SF1->F1_DOC,5,8))
						oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:OWSIDNOTA:CPTOVTA := IIf(nTamDoc > 12,SubStr(SF1->F1_DOC,1,5),SubStr(SF1->F1_DOC,1,4))
				
					ElseIf alltrim(aTitdoc[nDocNDNC][12]) $ "NCP"
						n4 := n4 + 1
						AADD(oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC,FECRED_NOTASDC():New())
						oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:OWSIDNOTA := FECRED_IDCOMP():New()
						oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:CACEPTA := "S"
					
						dbSelectArea('SF2')
						DbSetOrder(1)
						//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
						MsSeek(xFilial('SF2')+ aTitdoc[nDocNDNC][10] + aTitdoc[nDocNDNC][9] + aTitdoc[nDocNDNC][1] + aTitdoc[nDocNDNC][2]) 
					
						dbSelectArea('SA2')  //A2_FILIAL+A2_COD+A2_LOJA
						DbSetOrder(1)
						MsSeek(xFilial('SA2')+ aTitdoc[nDocNDNC][1] + aTitdoc[nDocNDNC][2] ) 
					
						cCuit := Alltrim(SA2->A2_CGC)
						nTamDoc := Len(SF2->F2_DOC)
					
						oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:OWSIDNOTA:CCODTIPOCMP := StaticCall( TrfDebCred, CodTpCmp,SF2->F2_ESPECIE,SF2->F2_SERIE)
						oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:OWSIDNOTA:CCUITEMISSOR := cCuit 
						oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:OWSIDNOTA:CNROCMP := IIf(nTamDoc > 12,SubStr(SF2->F2_DOC,6,8),SubStr(SF2->F2_DOC,5,8))
						oWSC:OWSCONFNOTASDC:OWSNTCREDDC:oWSNOTASDC[n4]:OWSIDNOTA:CPTOVTA := IIf(nTamDoc > 12,SubStr(SF2->F2_DOC,1,5),SubStr(SF2->F2_DOC,1,4))
					Endif	
				Next nDocNDNC		
			Endif	
			oWSC:OWSFORMACANCFE:OWSNTCREDPAGO := FECRED_FORMCANCARR():New()
			oWSC:OWSFORMACANCFE:OWSNTCREDPAGO := FECRED_ARRAYOFFORMCANC():New()   
			aadd(oWSC:OWSFORMACANCFE:OWSNTCREDPAGO:oWSFORMCANC,FECRED_FORMCANC():New())
			oWSC:OWSFORMACANCFE:OWSNTCREDPAGO:OWSFORMCANC[1]:CCODIGO := ""
			oWSC:OWSFORMACANCFE:OWSNTCREDPAGO:OWSFORMCANC[1]:CDESCRICAO := ""   
			
			oWSC:OWSRETENCION:oWSNTRETENC := FECRED_RETENCARR():New()
			oWSC:OWSRETENCION:OWSNTRETENC := FECRED_ARRAYOFCREDRETENC():New()

			dbSelectArea("SYF") 
			dbSetOrder(1)
			
			cMoeda:='GetMV("MV_SIMB'+Alltrim(str(SE2->E2_MOEDA))+'")'
			SYF->(MsSeek(xFilial("SYF")+&cMoeda))
			oWSC:CCODMONEDA := SYF->YF_COD_GI
			
			dbSelectArea('FVS')
			DbSetOrder(1)
			//FVS_FILIAL + FVS_CODCC + FVS_TIPO + FVS_CODIGO + FVS_LOJA
			MsSeek(xFilial('FVS')+ cCodCC )	
			
			aInfRet :=  StaticCall( FeCredAmb, TpRetFECrd,oGridRet) 
			
			For n2 := 1 to Len(oGridRet:aCols)
				If (oGridRet:aCols[n2][7] > 0 .And. oGridRet:aCols[n2][6] > 0) .Or. (oGridRet:aCols[n2][7] < 0 .And. oGridRet:aCols[n2][6] < 0) 
					AADD(oWSC:OWSRETENCION:OWSNTRETENC:OWSCREDRETENC, FECRED_CREDRETENC():New())
					For n3 := 1 To Len(oWSC:OWSRETENCION:OWSNTRETENC:OWSCREDRETENC)
						If Empty(oWSC:OWSRETENCION:OWSNTRETENC:OWSCREDRETENC[n3]:CCODTIPO)
							oWSC:OWSRETENCION:OWSNTRETENC:OWSCREDRETENC[n3]:CCODTIPO := aInfRet[n2][1]
							oWSC:OWSRETENCION:OWSNTRETENC:OWSCREDRETENC[n3]:CDESCMOTIVO := aInfRet[n2][2]
							oWSC:OWSRETENCION:OWSNTRETENC:OWSCREDRETENC[n3]:CIMPORTE := cvaltochar (oGridRet:aCols[n2][7])
							oWSC:OWSRETENCION:OWSNTRETENC:OWSCREDRETENC[n3]:CPORCENTAGE := cvaltochar (oGridRet:aCols[n2][6])
							lCriou := .T.
						Endif	
					Next n3 
				Endif
			Next n2
			
			If !lcriou
				AADD(oWSC:OWSRETENCION:OWSNTRETENC:OWSCREDRETENC, FECRED_CREDRETENC():New())
				oWSC:OWSRETENCION:OWSNTRETENC:OWSCREDRETENC[1]:CCODTIPO := ""
				oWSC:OWSRETENCION:OWSNTRETENC:OWSCREDRETENC[1]:CDESCMOTIVO := ""
				oWSC:OWSRETENCION:OWSNTRETENC:OWSCREDRETENC[1]:CIMPORTE := ""
				oWSC:OWSRETENCION:OWSNTRETENC:OWSCREDRETENC[1]:CPORCENTAGE := ""
			Endif
			
			//Informações de do grupo de ajuste, precisa verificar de onde virão as informações
			oWSC:OWSAJUSTESOPERACION:OWSAJOPARRAY := FECRED_AJUSTOPARR():New() 
			oWSC:oWSAJUSTESOPERACION:OWSAJOPARRAY := FECRED_ARRAYOFAJUSTE():New()
			AADD(oWSC:oWSAJUSTESOPERACION:OWSAJOPARRAY:oWSAJUSTE,FECRED_AJUSTE():New())
			oWSC:oWSAJUSTESOPERACION:OWSAJOPARRAY:oWSAJUSTE[1]:CCODIGO  := ""
			oWSC:oWSAJUSTESOPERACION:OWSAJOPARRAY:oWSAJUSTE[1]:CIMPORTE := "" 
			
			oWSC:CTPCANCELACION := ""
			oWSC:CIMPCANCEL := ""
			
			For nTot := 1 To Len(oGridRet:aCols)
				nTotRet += oGridRet:aCols[nTot][7]
			Next nTot
			
			nRetAux := Round(xMoeda(nTotRet ,1 ,Val(FVS->FVS_MOEDA),,5,,SE2->E2_TXMOEDA),MsDecimais(1))
			
			For nSld := 1 To Len(aTitdoc)
				If Len(aTitdoc) == 1
					nSldAcpto += aTitdoc[nSld][3]
				Else
					nSldAcpto += IIf(Alltrim(aTitdoc[nSld][12]) $ "NF|NDP",(aTitdoc[nSld][3]),-(aTitdoc[nSld][3]))
				Endif		
			Next nTot
			
			nSldAcpto := Round(xMoeda(nSldAcpto ,aTitdoc[1][4] ,Val(FVS->FVS_MOEDA),,5,aTxMoedas[Max(SE2->E2_MOEDA ,1)][2]),MsDecimais(1))
			
			nSldAcpto:= nSldAcpto-nRetAux
			cTotRet := cvaltochar(nTotRet)
			cSldAcpto := cvaltochar((nSldAcpto))
			
			oWSC:CIMPTOTALRET := cTotRet
			oWSC:CIMPEMBARG := "0"
			oWSC:cSLDACEPTO := cSldAcpto
			
			aAreaSE2 := SE2->(GetArea())
			
			SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA 
			SE2->(MsSeek(xFilial("SE2")+ aTitdoc[1][9] + aTitdoc[1][10] + aTitdoc[1][11] + aTitdoc[1][12] + aTitdoc[1][1] + aTitdoc[1][2] ))
			
			If "NF" $ SE2->E2_TIPO  .AND. SE2->E2_MOEDA == 1 
				oWSC:CCOTIZMONEDA := "1"
			Else
				oWSC:CCOTIZMONEDA := cvaltochar(SE2->E2_TXMOEDA)
			Endif
			SE2->(RestArea(aAreaSE2))
		endif
		If aConsTRF[2] == "SCA" .and. nAltCBU == 1
			If !lAutAfip
				If !Empty(cCBUCom) 
					oWSC:CINFORMCBU :=	cCBUCom
				Else
					oWSC:CINFORMCBU := "" 
				Endif
			endif
		Endif
		if !lAutAfip
			If SA2->(ColumnPos("A2_CBUCOM"))> 0 .And. !Empty(SA2->A2_CBUCOM) 
				oWSC:CCBUCOMPR  := SA2->A2_CBUCOM 
				If aConsTRF[2] == "SCA"					
					IF nAltCBU == 1
						cperg1 := mv_par01
						dbSelectArea("SX1")
						dbSetOrder(1)
						IF SX1->(MsSeek('SCA855    '+ '01'))
							Pergunte("SCA855", .T.)
							IF !Empty(mv_par01)
								oWSC:CCBUCOMPR  := mv_par01	
							Endif
							mv_par01 := cperg1
						ENDIF
						SX1->(dbCloseArea())
					Endif
				ENDIF
			Else
				oWSC:CCBUCOMPR  := ""
			Endif
		else
			If SA2->(ColumnPos("A2_CBUCOM"))> 0 .And. !Empty(SA2->A2_CBUCOM)
				cCBUCom := SA2->A2_CBUCOM
				If aConsTRF[2] == "SCA" .AND. nAltCBU == 1
					cperg1 := mv_par01
					dbSelectArea("SX1")
					dbSetOrder(1)
					IF SX1->(MsSeek('SCA855    '+ '01'))
						Pergunte("SCA855", .T.)
						IF !Empty(mv_par01)
							cCBUCom  := mv_par01	
						Endif
						mv_par01 := cperg1
					ENDIF
					SX1->(dbCloseArea())
				ENDIf
			Else
				cCBUCom  := ""
			Endif
		ENDIF

		if !lAutAfip
			
			oWSC:CCWSSERVICE := "6"
			
			If oWSC:FECREDACEPTAR() 
				cMonitor := OWSC:OWSFECREDACEPTARRESULT:OWSID:CSTRING[1]
				
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
				ElseIf oRetorno[nA]:CRESULTADO == "R" .And. oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CCODIGO <> "12004"
					If Len(oRetorno[nA]:OWSRESPERROR:OWSERRORARR) == 1 .And. (oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CDESCR <> "")
						cMensagem += STR0113 + CRLF//Retorno Afip
						cMensagem += STR0114 + oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CCODIGO  + CRLF
						cMensagem += STR0115   + oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CDESCR + CRLF
						Aviso(STR0079,cMensagem,{"OK"},3)
						cMsgAfip := oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CDESCR
						lREt := .F.
					ElseIf Len(oRetorno[nA]:OWSRESPERROR:OWSERRORARR) > 1 .And. (oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CDESCR <> "")
						cMensagem += STR0113 + CRLF
						For nB := 1 To Len(oRetorno[nA]:OWSRESPERROR:OWSERRORARR)
							cMensagem += STR0114 + oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CCODIGO + CRLF
							cMensagem += STR0115 + oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CDESCR + CRLF 
							cMsgAfip += oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CCODIGO  + " - " + oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CDESCR
						Next nB
						Aviso(STR0079,cMensagem,{"OK"},3)
						lREt := .F.
					ElseIf Len(oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR) == 1 .And. (oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CDESCR <> "")
						cMensagem += STR0113 + CRLF //Retorno Afip
						cMensagem += STR0114 + oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CCODIGO + CRLF
						cMensagem += STR0115 + oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CDESCR + CRLF 
						Aviso(STR0079,cMensagem,{"OK"},3)
						cMsgAfip := oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CCODIGO + " - "  + oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CDESCR
						lREt := .F.
					ElseIf Len(oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR) > 1 .And. (oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CDESCR <> "")
						cMensagem += STR0113 + CRLF
						For nB := 1 To Len(oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR)
							cMensagem += STR0114 + oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CCODIGO + CRLF
							cMensagem += STR0115 + oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CDESCR + CRLF
							cMsgAfip += oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CCODIGO + " - "  + oRetorno[nA]:OWSRESPERRORFORM:OWSERRORFORMARR[nB]:CDESCR
						Next nB
						Aviso(STR0079,cMensagem,{"OK"},3)
						lREt := .F.
					ElseIf	Len(oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR) == 1 .And. (oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CDESCR <> "" )
						cMensagem += STR0113 + CRLF //Retorno Afip
						cMensagem += STR0114 + oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CCODIGO + CRLF
						cMensagem += STR0115 + oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CDESCR + CRLF
						Aviso(STR0079,cMensagem,{"OK"},3)
						cMsgAfip := oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CDESCR 
						lREt := .F.
					ElseIf Len(oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR) > 1 .And. (oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CCODIGO <> "" .And. oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CDESCR <> "" )
						cMensagem += STR0113 + CRLF
						For nB := 1 To Len(oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR)
							cMensagem += STR0114 + oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CCODIGO + CRLF
							cMensagem += STR0115 + oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CDESCR + CRLF 
							cMsgAfip += oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CCODIGO + " - " + oRetorno[nA]:OWSRESPOBSERVA:OWSROBSARR[nB]:CDESCR
						Next nB
						Aviso(STR0079,cMensagem,{"OK"},3)
						lREt := .F.					
					EndiF
					
					//Habilitar para mudar os stuatus das tabelas FVS e FVT 
					aAreaFVS := FVS->(GetArea())
					dbSelectArea('FVS')
					DbSetOrder(1)
					//FVS_FILIAL + FVS_CODCC + FVS_TIPO + FVS_CODIGO + FVS_LOJA
					MsSeek(xFilial('FVS')+ cCodCC ) 
					
					cCodCC := FVS->FVS_CODCC
					cTPFVS := FVS->FVS_TIPO
					cCodFor := FVS->FVS_CODIGO
					cLoja := FVS->FVS_LOJA
					RecLock("FVS", .F.)
						FVS->FVS_STATUS := "2"
					MsUnlock()
					FVS->(RestArea(aAreaFVS))
					
					aAreaFVT := FVT->(GetArea())
					For nRet := 1 To Len(aTitDoc)
						dbSelectArea('FVT')
						DbSetOrder(1)
						//FVT_FILIAL + FVT_CODCC + FVT_TIPO + FVT_CODIGO + FVT_LOJA + FVT_ESPECI + FVT_SERIE + FVT_DOC					
						MsSeek(xFilial('FVT')+ cCodCC + cTPFVS + cCodFor + cLoja + aTitDoc[nRet][12] + aTitDoc[nRet][9] + aTitDoc[nRet][10])
						RecLock("FVT", .F.)
							FVT->FVT_STATUS := "2"
							FVT->FVT_RETAFP := Substr(cMsgAfip,1,TAMSX3("FVT_RETAFP")[1] )
						MsUnlock() 
					Next nRet
					FVT->(RestArea(aAreaFVT))
				
				ElseIf oRetorno[nA]:CRESULTADO == "A" .Or. (oRetorno[nA]:CRESULTADO == "R" .And. oRetorno[nA]:OWSRESPERROR:OWSERRORARR[nB]:CCODIGO == "12004")	
					cMensagem += STR0116 + CRLF //Retorno Afip
					cMensagem += STR0117 + CRLF //Retorno Afip
					Aviso(STR0079,cMensagem,{"OK"},3)
						
					//Habilitar para mudar os stuatus ndas tabelas FVS e FVT
					dbSelectArea('FVS')
					DbSetOrder(1)
					//FVS_FILIAL + FVS_CODCC + FVS_TIPO + FVS_CODIGO + FVS_LOJA
					MsSeek(xFilial('FVS')+ cCodCC ) 
					
					cCodCC := FVS->FVS_CODCC
					cTPFVS := FVS->FVS_TIPO
					cCodFor := FVS->FVS_CODIGO
					cLoja := FVS->FVS_LOJA
					
					RecLock("FVS", .F.)
						FVS->FVS_STATUS := "4"
						FVS->FVS_DTACRC := dDatabase
					MsUnlock()
					
					For nRet := 1 To Len(aTitDoc)
						dbSelectArea('FVT')
						DbSetOrder(1)
						//FVT_FILIAL + FVT_CODCC + FVT_TIPO + FVT_CODIGO + FVT_LOJA + FVT_ESPECI + FVT_SERIE + FVT_DOC					
						MsSeek(xFilial('FVT')+ cCodCC + cTPFVS + cCodFor + cLoja + aTitDoc[nRet][12] + aTitDoc[nRet][9] + aTitDoc[nRet][10])
						RecLock("FVT", .F.)
							FVT->FVT_STATUS := "4"
							FVT->FVT_RETAFP := ""
						MsUnlock() 
					Next nRet
					
					lREt := .T.
				Endif
			Else
				lREt := .F.
			Endif
		else
			cMensagem += STR0116 + CRLF //Retorno Afip
			cMensagem += STR0117 + CRLF //Retorno Afip
			Aviso(STR0079,cMensagem,{"OK"},3)

			dbSelectArea('FVS')
			DbSetOrder(1)
			//FVS_FILIAL + FVS_CODCC + FVS_TIPO + FVS_CODIGO + FVS_LOJA
			MsSeek(xFilial('FVS')+ cCodCC ) 
			
			cCodCC := FVS->FVS_CODCC
			cTPFVS := FVS->FVS_TIPO
			cCodFor := FVS->FVS_CODIGO
			cLoja := FVS->FVS_LOJA
			RecLock("FVS", .F.)
				FVS->FVS_STATUS := "4"
			MsUnlock()
			
			For nRet := 1 To Len(aTitDoc)
				dbSelectArea('FVT')
				DbSetOrder(1)
				//FVT_FILIAL + FVT_CODCC + FVT_TIPO + FVT_CODIGO + FVT_LOJA + FVT_ESPECI + FVT_SERIE + FVT_DOC					
				MsSeek(xFilial('FVT')+ cCodCC + cTPFVS + cCodFor + cLoja + aTitDoc[nRet][12] + aTitDoc[nRet][9] + aTitDoc[nRet][10])
				RecLock("FVT", .F.)
					FVT->FVT_STATUS := "4"
					FVT->FVT_RETAFP := Substr(cMsgAfip,1,TAMSX3("FVT_RETAFP")[1] )
				MsUnlock() 
			Next nRet	
			lREt := .T.
		endif
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
