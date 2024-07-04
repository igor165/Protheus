#Include "PROTHEUS.CH"

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReadPix

CNAB Modelo 2.

@param nHandle - Handle do Arquivo a ser lido
@param cLayaout - Nome do arquivo de configuracao
@param nMaxLn - Tamanho maximo da linha
@param aLayout - Atributos do arquivo de configuracao
@param nLinRead

@Author	Adriano Sato
@since 25/10/2020
/*/
//-----------------------------------------------------------------------------------------------------
Function ReadPix(nHandle as character, cLayOut as character, nMaxLn as numeric, aLayOut as array, nLinRead as numeric)

Local lPosChave  as logical
Local lPosCMov   as logical
Local lPosDtMov  as logical
Local lPosIDTran as logical
Local lPosDtVc   as logical
Local lPosJuros  as logical
Local lPosMulta  as logical
Local lPosDescAb as logical
Local lPosValPag as logical
Local lPosValTar as logical
Local lPosOcor   as logical
Local lPosLink   as logical
Local lPosPay    as logical
Local lPosQRcod  as logical

Local cPosChave  as character
Local cPosCMov   as character
Local cPosDtMov  as character
Local cPosIDTran as character
Local cPosDtVc   as character
Local cPosJuros  as character
Local cPosMulta  as character
Local cPosDescAb as character
Local cPosValPag as character
Local cPosValTar as character
Local cPosOcor   as character
Local cPosLink   as character
Local cPosPay    as character
Local cPosQRcod  as character
Local cTITULO	 as character
Local cTIPO		 as character
Local cOCORRENCI as character
Local cDATA      as character
Local cNOSSONUM  as character
Local cDATACRED  as character
Local cMOTIVO    as character
Local cRESERVADO as character
Local cBuffer    as character
Local cAUTENTICA as character
Local cCGC		 as character
Local cBANCO	 as character
Local cAGENCIA	 as character
Local cCONTA	 as character
Local cChavePix  as character
Local cCodMovim  as character
Local cIDTran    as character
Local cDtVc      as character
Local cCodOcor   as character
Local cLinkPix   as character
Local cQrCode    as character
Local cArqConf   as character
Local xBuffer    as character
Local cDtMov     as character

Local nLenChave  as numeric
Local nLenCMov   as numeric
Local nLenDtMov  as numeric
Local nLenIDTran as numeric
Local nLenDtVc   as numeric
Local nLenJuros  as numeric
Local nLenMulta  as numeric
Local nLenDescAb as numeric
Local nLenValPag as numeric
Local nLenValTar as numeric
Local nLenOcor   as numeric
Local nLenLink   as numeric
Local nLenPay    as numeric
Local nLenQRcod  as numeric
Local nVALOR     as numeric
Local nDESPESA   as numeric
Local nDESCONTO  as numeric
Local nABATIMENT as numeric
Local nJUROS     as numeric
Local nMULTA     as numeric
Local nValIof    as numeric
Local nValCC     as numeric
Local nDescAbat  as numeric
Local nValPagto  as numeric
Local nValTarifa as numeric
Local nLastLn	 as numeric
Local nLidos     as numeric
Local nTamArq    as numeric
Local nTamDet    as numeric

Local aBuffer	 as array
Local aAreaPix   as array
Local aRetorno   as array

Local dDtMov     as date
Local dDtVenc    as date

Default nHandle  := ""
Default cLayOut  := ""
Default nMaxLn   := 1000
Default aLayOut  := {}
Default nLinRead := 0

nHdlConf := Iif(nHdlConf==Nil,"",nHdlConf)
nHdlBco := Iif(nHdlBco==Nil,"",nHdlBco)

aAreaPix  := GetArea()

lPosChave  := .F.
lPosCMov   := .F.
lPosDtMov  := .F.
lPosIDTran := .F.
lPosDtVc   := .F.
lPosJuros  := .F.
lPosMulta  := .F.
lPosDescAb := .F.
lPosValPag := .F.
lPosValTar := .F.
lPosOcor   := .F.
lPosLink   := .F.
lPosPay    := .F.
lPosQRcod  := .F.

cPosChave  := ""
cPosCMov   := ""
cPosDtMov  := ""
cPosIDTran := ""
cPosDtVc   := ""
cPosJuros  := ""
cPosMulta  := ""
cPosDescAb := ""
cPosValPag := ""
cPosValTar := ""
cPosOcor   := ""
cPosLink   := ""
cPosPay    := ""
cPosQRcod  := ""

nLenChave  := 0
nLenCMov   := 0
nLenDtMov  := 0
nLenIDTran := 0
nLenDtVc   := 0
nLenJuros  := 0
nLenMulta  := 0
nLenDescAb := 0
nLenValPag := 0
nLenValTar := 0
nLenOcor   := 0
nLenLink   := 0
nLenPay    := 0
nLenQRcod  := 0

cTITULO	   := ""
cTIPO      := ""
cOCORRENCI := ""
cDATA      := "000000"
nVALOR     := 0.00
nDESPESA   := 0.00
nDESCONTO  := 0.00
nABATIMENT := 0.00
nJUROS     := 0.00
nMULTA     := 0.00
cNOSSONUM  := ""
nValIof    := 0.00
nValCC     := 0.00
cDATACRED  := "000000"
cMOTIVO    := ""
cRESERVADO := ""
cBuffer    := ""
cAUTENTICA := ""
aBuffer	   := {}
cCGC       := ""
cBANCO     := ""
cAGENCIA   := ""
cCONTA     := ""
cChavePix  := ""
cCodMovim  := ""
cDtMov     := ""
dDtMov     := CTOD("//")
cIDTran    := ""
cDtVc      := ""
dDtVenc    := CTOD("//")
nDescAbat  := 0
nValPagto  := 0
nValTarifa := 0
cCodErro   := ""
cCodOcor   := ""
cLinkPix   := ""
cQrCode    := ""
nLastLn	   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo de configuracao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqConf:=cLayOut
IF FILE(cArqConf)
	nHdlConf:=FOPEN(cArqConf,0+64)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lˆ arquivo de configuracao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLidos:=0
FSEEK(nHdlConf,0,0)
nTamArq:=FSEEK(nHdlConf,0,2)
FSEEK(nHdlConf,0,0)

While nLidos <= nTamArq

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o tipo de qual registro foi lido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xBuffer:=Space(85)
	FREAD(nHdlConf,@xBuffer,85)
	IF SubStr(xBuffer,1,1) == CHR(1)
		nLidos+=85
		Loop
	EndIF
	IF SubStr(xBuffer,1,1) == CHR(3)
		nLidos+=85
		Exit
	EndIF

	IF !lPosChave
		cPosChave := Substr(xBuffer,17,10)
		nLenChave := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosChave := .T.
		nLidos+=85
		Loop
	EndIF
	IF !lPosCMov
		cPosCMov := Substr(xBuffer,17,10)
		nLenCMov := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosCMov := .T.
		nLidos+=85
		Loop
	EndIF
	If !lPosDtMov
		cPosDtMov := Substr(xBuffer,17,10)
		nLenDtMov := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosDtMov := .T.
		nLidos+=85
		Loop
	Endif
	IF !lPosIDTran
		cPosIDTran := Substr(xBuffer,17,10)
		nLenIDTran := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosIDTran := .T.
		nLidos+=85
		Loop
	EndIF
	If !lPosDtVc
		cPosDtVc := Substr(xBuffer,17,10)
		nLenDtVc := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosDtVc := .T.
		nLidos+=85
		Loop
	Endif
	IF !lPosJuros
		cPosJuros := Substr(xBuffer,17,10)
		nLenJuros := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosJuros := .T.
		nLidos+=85
		Loop
	EndIF
	IF !lPosMulta
		cPosMulta := Substr(xBuffer,17,10)
		nLenMulta := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosMulta := .T.
		nLidos+=85
		Loop
	EndIF
	IF !lPosDescAb
		cPosDescAb := Substr(xBuffer,17,10)
		nLenDescAb := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosDescAb := .T.
		nLidos+=85
		Loop
	EndIF
	IF !lPosValPag
		cPosValPag := Substr(xBuffer,17,10)
		nLenValPag := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosValPag := .T.
		nLidos+=85
		Loop
	EndIF
	IF !lPosValTar
		cPosValTar := Substr(xBuffer,17,10)
		nLenValTar := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosValTar := .T.
		nLidos+=85
		Loop
	EndIF
	IF !lPosOcor
		cPosOcor  := Substr(xBuffer,17,10)
		nLenOcor  := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosOcor  := .T.
		nLidos+=85
		Loop
	EndIF
	IF !lPosLink
		cPosLink := Substr(xBuffer,17,10)
		nLenLink := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosLink := .T.
		nLidos+=85
		Loop
	EndIF
	IF !lPosPay
		cPosPay  := Substr(xBuffer,17,10)
		nLenPay  := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosPay  := .T.
		nLidos+=85
		Loop
	EndIF
	IF !lPosQRcod
		cPosQRcod := Substr(xBuffer,17,10)
		nLenQRcod := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosQRcod := .T.
		nLidos+=85
		Loop
	EndIF
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lˆ arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLidos:=0
FSEEK(nHdlBco,0,0)
nTamArq:=FSEEK(nHdlBco,0,2)
FSEEK(nHdlBco,0,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenha o cursor e o salva para poder moviment -lo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua( nTamArq/nTamDet , 24 )

While nLidos <= nTamArq
	IncProc()

	nLastLn ++

	xBuffer:=Space(nTamDet)
	FREAD(nHdlBco,@xBuffer,nTamDet)

	IF SubStr(xBuffer,1,1) $ "1"

		cChavePix := Substr(xBuffer,Int(Val(Substr(cPosChave, 1,3))),nLenChave )
		cCodMovim := Substr(xBuffer,Int(Val(Substr(cPosCMov, 1,3))),nLenCMov )
		
		IF !Empty(cPosDtMov)
			cDtMov := Substr(xBuffer,Int(Val(Substr(cPosDtMov,1,3))),nLenDtMov)
			cDtMov := Substr(cDtMov,7,2)+"/"+Substr(cDtMov,5,2)+"/"+Substr(cDtMov,1,4)
			dDtMov := Ctod(cDtMov,"ddmmyy")
		EndIf
		IF !Empty(cPosIDTran)
			cIDTran	  := ALLTRIM(Substr(xBuffer,Int(Val(Substr(cPosIDTran, 1,3))),nLenIDTran ))
		EndIF
		IF !Empty(cPosDtVc)
			cDtVc := Substr(xBuffer,Int(Val(Substr(cPosDtVc,1,3))),nLenDtVc)
			cDtVc := Substr(cDtVc,7,2)+"/"+Substr(cDtVc,5,2)+"/"+Substr(cDtVc,1,4)
			dDtVenc := Ctod(cDtVc,"ddmmyy")
		EndIf
		IF !Empty(cPosJuros)
			nJuros := Round(Val(Substr(xBuffer,Int(Val(Substr(cPosJuros,1,3))),nLenJuros))/100,2)
		EndIF
		IF !Empty(cPosMulta)
			nMulta := Round(Val(Substr(xBuffer,Int(Val(Substr(cPosMulta,1,3))),nLenMulta))/100,2)
		EndIF
		IF !Empty(cPosDescAb)
			nDescAbat := Round(Val(Substr(xBuffer,Int(Val(Substr(cPosDescAb,1,3))),nLenDescAb))/100,2)
		EndIF
		IF !Empty(cPosValPag)
			nValPagto := Round(Val(Substr(xBuffer,Int(Val(Substr(cPosValPag,1,3))),nLenValPag))/100,2)
		EndIF
		IF !Empty(cPosValTar)
			nValTarifa := Round(Val(Substr(xBuffer,Int(Val(Substr(cPosValTar,1,3))),nLenValTar))/100,2)
		EndIF
		IF !Empty(cPosOcor)
			cCodOcor := ALLTRIM(Substr(xBuffer,Int(Val(Substr(cPosOcor,1,3))),nLenOcor))
		EndIF
	ElseIf SubStr(xBuffer,1,1) $ "3"
		cLinkPix  := Substr(xBuffer,Int(Val(Substr(cPosLink, 1,3))),nLenLink )
	ElseIf SubStr(xBuffer,1,1) $ "4"
		cQrCode   := Substr(xBuffer,Int(Val(Substr(cPosQRcod, 1,3))),nLenQRcod )
	ElseIf SubStr(xBuffer,1,1) $ "9"
		nLidos += nTamArq
	EndIF
	nLidos += nTamDet
	Loop
EndDo

nLinRead   := nLastLn
cTITULO    := ""
cTIPO      := ""     
cOCORRENCI := cCodMovim
cDATA      := cDtMov
nVALOR     := nValPagto
nDESPESA   := nValTarifa
nDESCONTO  := nDescAbat
cNOSSONUM  := ""
nValIof    := 0
nValCC     := 0
cDATACRED  := cDtMov
cMOTIVO    := cCodOcor
cRESERVADO := ""
cBuffer    := ""
cAUTENTICA := ""
aBuffer    := {}
cCGC       := ""
cBANCO     := ""
cAGENCIA   := ""
cCONTA     := ""

dbSelectArea("F71")
F71->( dbSetOrder(2) ) 		// IDTRAN
F71->( dbGoTop() )
If F71->( dbSeek(cIDTran) )
	/* 
	F71->F71_PREFIX
	F71->F71_PARCEL
	F71->F71_CODCLI
	F71->F71_LOJCLI
	F71->F71_FILBCO
	 */
	cTITULO  := F71->F71_NUM
	cTIPO    := F71->F71_TIPO
	cBANCO   := F71->F71_CODBAN
	cAGENCIA := F71->F71_AGENCI
	cCONTA   := F71->F71_NUMCON
Endif

aRetorno := {	cTITULO,cTIPO,cOCORRENCI,cDATA,nVALOR,;
			nDESPESA,nDESCONTO,nABATIMENT,nJUROS,nMULTA,;
			cNOSSONUM,nValIof,nValCC,cDATACRED,cMOTIVO,;
			cRESERVADO,cBuffer,cAUTENTICA,aBuffer,cCGC,;
			cBANCO,cAGENCIA,cCONTA,cChavePix,cCodMovim,;
			cLinkPix,cQrCode}

RestArea(aAreaPix)

Return(aRetorno)
