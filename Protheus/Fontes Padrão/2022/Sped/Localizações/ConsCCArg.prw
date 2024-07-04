#Include 'Protheus.ch' 
#Include "Fina855.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ConsCCArg ³ Autor ³Danilo Santos           ³ Data ³.11.2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função que faz a consulta da conta corrente na Afip e       ³±±
±±³          ³ Ordem de pagamento AFIP FINA850 - Argentina                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³estado conta corrente                                       ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function ConsCCArg(cContCor)

Local cURL			:= (PadR(GetNewPar("MV_ARGFEUR","http://"),250))
Local lWsFeCred	:= SuperGetMV( "MV_WSFECRD", .F., .F. )
Local cIdEnt		:= ""
Local nComp		:= 0
Local lExecute	:= .T.
Local cTeste1		:= ""
Local cTeste3		:= ""
Local cMensagem	:= ""
Local cAmbiente	:= ""
Local lConsCC		:= .T.
Local cTpTRansf := ""

Private oWSCC
Private oWSConsCC

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
			oWSCC := WSNFECFGLOC():New()
			oWSCC:cUSERTOKEN := "TOTVS"
			oWSCC:cID_ENT    := cIdEnt
			oWSCC:nAmbiente  := 0	
			oWSCC:cModelo := "6"	
			oWSCC:_URL       := AllTrim(cURL)+"/NFECFGLOC.apw"
			lOk := oWSCC:CFGAMBLOC()
			cAmbiente := oWSCC:CCFGAMBLOCRESULT
		Else
			Aviso("NFFE", STR0132 + CHR(10) + CHR(13) +; // "No se detectó configuración de conexión con TSS."
							STR0133 + CHR(10) + CHR(13) +; // "Por favor, ejecute opción Wizard de Configuración."
							STR0134 + CHR(10) + CHR(13), ; // "Siga atentamente os passos para a configuração da nota fiscal eletrônica."
					{"OK"},3)
			Return		
		EndIf
	Else
		Aviso("NFFE", STR0132 + CHR(10) + CHR(13) +; // "No se detectó configuración de conexión con TSS."
						STR0133 + CHR(10) + CHR(13) +; // "Por favor, ejecute opción Wizard de Configuración."
						STR0134 + CHR(10) + CHR(13), ; // "Siga atentamente os passos para a configuração da nota fiscal eletrônica."
						{"OK"},3)				
		Return
	EndIf
	
	oWSCC:= WSNFESLOC():New()
	
	oWSCC:cUserToken := "TOTVS"
	oWSCC:cID_ENT    := cIdEnt
	oWSCC:_URL       := AllTrim(cURL)+"/NFESLOC.apw"
	cData:=	 FsDateConv(Date(),"YYYYMMDD")
	cData := SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7)
	oWSCC:CDATETIMEGER := cData+"T00:00:00"
	oWSCC:cDATETIMEEXP := cData+"T23:59:59"
	oWSCC:cCWSSERVICE  := "wsfecred"	
	
	oWSCC:GETAUTHREM()	
	
	If GetWscError(1) == "" .Or. "005" $ GetWscError(1) .Or. "005" $ GetWscError(3) .Or. "006" $ GetWscError(3)
		lExecute := .T.
		cTeste1 := GetWscError(1)
		cTeste3 := GetWscError(3)
	
		If cTeste1 == Nil .Or. cTeste3 == Nil 
			lExecute:=.F.
			nComp:=1
			While nComp < 5 .And. !lExecute
				oWSCC:GETAUTHREM()
				cTeste1 := GetWscError(1)
				cTeste3 := GetWscError(3)
				If cTeste1 <> Nil .And. cTeste3 <> Nil 	
					lExecute:=.T.
				EndIf	
				nComp:=nComp+1
			EndDo 
		Endif
		
		//Chamar metodo de consulta conta corrente
		oWSConsCC := WSFECRED():New()
		oWSConsCC:cUserToken  := "TOTVS"
		oWSConsCC:cID_ENT     := cIdEnt
		oWSConsCC:_URL        := AllTrim(cURL)+"/FECRED.apw" 
		cCodCC := Alltrim(cContCor)
		oWSConsCC:OWSIDCTACTE:OWSIDFACTUR := FECRED_IDFACT():New()
		oWSConsCC:OWSIDCTACTE:CCODCTACTE := cCodCC
		
		oWSConsCC:OWSIDCTACTE:OWSIDFACTUR:CCODTIPOCMP :=""
		oWSConsCC:OWSIDCTACTE:OWSIDFACTUR:CCUITEMISSOR := ""
		oWSConsCC:OWSIDCTACTE:OWSIDFACTUR:CNROCOMP := ""
		oWSConsCC:OWSIDCTACTE:OWSIDFACTUR:CPTOVTA := ""

		oWSConsCC:CONSCONTACORRENTE()
		If oWSConsCC:oWSConscontaCorrenteresult:CEVENTO $ "Modificable"
			lConsCC := .T.
		ElseIf oWSConsCC:oWSConscontaCorrenteresult:CEVENTO == ""
			lConsCC := .F.
		ElseIf !(oWSConsCC:oWSConscontaCorrenteresult:CEVENTO $ "Modificable") 
			lConsCC := .F.
			nSaldoCCr := oWSConsCC:oWSConscontaCorrenteresult:CSALDOCC
		Endif
				
		If FVS->(ColumnPos("FVS_OPCTRF"))> 0 .And. ! Empty(oWSConsCC:oWSConscontaCorrenteresult:COPCIONTRANSF)
			cTpTRansf := oWSConsCC:oWSConscontaCorrenteresult:COPCIONTRANSF
		Endif
		
		If Funname() $ "FINA855|FINA847"
			dbSelectArea('FVS')
			DbSetOrder(1)
			//FVS_FILIAL + FVS_CODCC + FVS_TIPO + FVS_CODIGO + FVS_LOJA
			If MsSeek(xFilial('FVS')+ cCodCC )
				If FVS->(ColumnPos("FVS_OPCTRF"))> 0 .And. ! Empty(cTpTRansf)  //.And. !Empty(FVS->FVS_OPCTRF)
					RecLock("FVS", .F.)
						FVS->FVS_OPCTRF := cTpTRansf
					MsUnlock()
				Endif
			Endif
			FVS->(DbCloseArea())	
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

Return {lConsCC,cTpTRansf}
