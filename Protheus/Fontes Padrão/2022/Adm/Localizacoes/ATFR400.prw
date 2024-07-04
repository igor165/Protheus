#INCLUDE "ATFR400.ch"
#INCLUDE "PROTHEUS.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFR400   ºAutor  ³Microsiga           ºFecha ³  06/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Menu para a selecao dos mapas fiscais do ativo fixo         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portugal                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFR400()
Local cPerg		:= "ATR401"
Local nCombo	:= 0
Local aMapas	:= {}
Local aItens	:= {}
Local lContinua	:= .T.
Local oDlg0
Local oCombo

//+------------------------------------------------------------------------------
//| Disponibiliza para usuario digitar os  parametros
//+------------------------------------------------------------------------------
Aadd(aMapas,{"Mapa das mais-valias e menos-valias fiscais" + " (" + "Modelo" + " 31)","ATFR401"}) //"Mapa das mais-valias e menos-valias fiscais"###"Modelo"
Aadd(aMapas,{"Mapa de reintegrações e amortizações" + " (" + "Modelo" + " 32)","ATFR404"}) //"Mapa de reintegrações e amortizações"
Aadd(aMapas,{"Mapa de reintegrações e amortizações" + " (" + "Modelo" + " 32.1)","ATFR402"}) //"Mapa de reintegrações e amortizações"
Aadd(aMapas,{"Mapa de reintegrações" + " (" + "Modelo" + " 32.2)","ATFR403"}) //"Mapa de reintegrações"

If cPaisLoc == "PTG"
	Aadd(aMapas,{"Mapa de Reintegrações (Dec. Lei n.º 118-B/86 33.7)","ATFR337"}) //"Mapa de reintegrações"
	Aadd(aMapas,{"Mapa de Reintegrações (Dec. Lei n.º 118-B/86 33.8)","ATFR338"}) //"Mapa de nao totalmente reintegrados"
	Aadd(aMapas,{"Mapa de Reintegrações (Dec. Lei n.º 111/88 33.9)","ATFR339"}) //"Mapa de reintegrações"
	Aadd(aMapas,{"Mapa de Reintegrações (Dec. Lei n.º 111/88 33.10)","ATFR3310"}) //"Mapa de nao totalmente reintegrados"
	Aadd(aMapas,{"Mapa de Reintegrações (Dec. Lei n.º 49/91 33.11)","ATFR3311"}) //"Mapa de reintegrações" 
	Aadd(aMapas,{"Mapa de Reintegrações (Dec. Lei n.º 49/91 33.12)","ATFR3312"}) //"Mapa de nao totalmente reintegrados"
	Aadd(aMapas,{"Mapa de Reintegrações (Dec. Lei n.º 264/92 33.14)","ATFR3314"}) //"Mapa de reintegrações"
	Aadd(aMapas,{"Mapa de Reintegrações (Dec. Lei n.º 264/92 33.15)","ATFR3315"}) //"Mapa de nao totalmente reintegrados"
	Aadd(aMapas,{"Mapa de Reintegrações (Dec. Lei n.º 31/98 33.17)","ATFR3317"}) //"Mapa de reintegrações"
	Aadd(aMapas,{"Mapa de Reintegrações (Dec. Lei n.º 31/98 33.18)","ATFR3318"}) //"Mapa de nao totalmente reintegrados"
EndIf
/*
Aadd(aMapas,{" ",""})
Aadd(aMapas,{"Layout dos mapas",""})
Aadd(aMapas,{"---------------------------------------------------",""})               
Aadd(aMapas,{"Mapa 31","U_ATFR31"})
Aadd(aMapas,{"Mapa 32.1","U_ATFR321"})
Aadd(aMapas,{"Mapa 32.2","U_ATFR322"})
Aadd(aMapas,{"---------------------------------------------------",""})
*/

nOpca := 0
aItens := {}
For nCombo := 1 To Len(aMapas)
	Aadd(aItens,aMapas[nCombo,1])
Next
nCombo := 1
While lContinua
	nOpca := 0
	DEFINE MSDIALOG oDlg0 TITLE STR0005 FROM 000,000 TO 250,450 PIXEL //"Mapas fiscais"
		@20,10 LISTBOX oCombo VAR nCombo ITEMS aItens PIXEL OF oDlg0 SIZE 200, 90 ON DBLCLICK {||nOpca := oCombo:nAt,oDlg0:End()}
		oCombo:nAt := nCombo
		DEFINE SBUTTON FROM 115, 185 TYPE 1 ENABLE OF oDlg0 PIXEL ACTION ( (nOpca := oCombo:nAt, nCombo := nOpca) , oDlg0:END() )
	ACTIVATE DIALOG oDlg0 CENTER ON INIT {|| oCombo:SetFocus()}
	If nOpca > 0
		If !Empty(aMapas[nOpca,2])
			cProg := "{||," + aMapas[nOpca,2] + "()" + "}"
			Eval(&cProg)
		Endif
	Else
		lContinua := .F.
	Endif
Enddo
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFBrkStr ºAutor  ³Microsiga           ºFecha ³  09/24/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFBrkStr(cStr,nTam,nLin)
Local cTexto	:= ""
Local nPos		:= 0
Local nX		:= 0
Local aRet		:= {}
Local aPalavras	:= {}

Default cStr	:= ""
Default nTam	:= 0
Default nLin	:= 0

If !Empty(cStr)
	cTexto := Alltrim(cStr)
	nPos := AT(" ",cTexto)
	While nPos > 0
		Aadd(aPalavras,Substr(cTexto,1,nPos-1))
		cTexto := Substr(cTexto,nPos + 1)
		nPos := AT(" ",cTexto)
	Enddo
	Aadd(aPalavras,Alltrim(cTexto))
Endif
If nTam > 0
	nX := 1
	cTexto := ""
	While nX <= Len(aPalavras)
		If (Len(cTexto) + Len(aPalavras[nX])) <= nTam
			cTexto += aPalavras[nX]
			cTexto += " "
			nX++
		Else
			If !Empty(cTexto)
				Aadd(aRet,Alltrim(cTexto))
				cTexto := ""
			Else
				Aadd(aRet,aPalavras[nX])
				nX++
			Endif
		Endif
	Enddo
	If !Empty(cTexto)
		Aadd(aRet,cTexto)
	Endif
Else
	aRet := AClone(aPalavras)
Endif
If nLin > 0
	If Len(aRet) < nLin
		For nX := 1 To (nLin - Len(aRet))
			Aadd(aRet," ")
		Next
	Else
		If Len(aRet) > nLin
			aRet := Asize(aRet,nLin)
		Endif
	Endif
Endif
Return(aRet)