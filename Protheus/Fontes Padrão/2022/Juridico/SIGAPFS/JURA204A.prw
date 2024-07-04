#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURA204A.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TJurEMail
CLASS TJurEMail

@author Felipe Bonvicini Conti
@since 10/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function __JurEMail() // Function Dummy
ApMsgInfo( 'JurEMail -> Utilizar Classe ao inves da funcao' )
Return NIL 

CLASS JurEMail
	
	Data cCliente
	Data cLoja
	Data cEMail
	Data aCods
	Data cBodyPadrao
	Data cBody
	Data aLines
	Data lPronto
	Data alRelats
	Data lEnviar
	Data lAchouC
	Data lAchouR
	Data cCodEsc
	Data cCodFat
	Data cConfig
	
	Method New(pcCliente, pcLoja, pcEMail, pcEscri, pcCodFat, pcBody, palRelats, pcConfig, paCodFat)  CONSTRUCTOR
	Method Igual(pcEMail)
	Method GetEMail()
	Method SetEMail(pcEMail)
	Method GetCods(cTipo)
	Method AddCods(pcCodEscri, pcCodFat)
	Method GetBody()
	Method SetBody(pcBody)
	Method GetMacroLines()
	Method Substituir()
	Method GetRelatorio()
	Method addRelat(pcEscri, pcCodFat)
	Method GetRelat()  
	Method GetCliente()
	Method SetCliente(pcCliente)  
	Method GetLoja()  
	Method SetLoja(pcLoja)
	Method GetConfig()  
	Method SetConfig(pcConfig)
	Method ProcTag(cBody)


ENDCLASS

METHOD New(pcCliente, pcLoja, pcEMail, pcEscri, pcCodFat, pcBody, palRelats, pcConfig, paCodFat) Class JurEMail
Local nC		  := 0
Default pcCliente := ""
Default pcLoja    := ""
Default pcEMail   := ""
Default pcEscri   := ""
Default pcCodFat  := ""
Default pcBody    := ""
Default palRelats := {.F., .F.} //{Rel_Fat, Rel_Carta}
Default pcConfig  := ""
Default paCodFat  := {}

	::cCliente    := pcCliente
	::cLoja       := pcLoja
	::cEMail      := pcEMail
	::aCods       := {}
	::cBodyPadrao := pcBody
	::cBody       := pcBody
    ::aLines      := ::GetMacroLines()
	::lPronto     := .F.
	::alRelats    := palRelats
	::lEnviar     := .T.
	::lAchouC     := .F.
	::lAchouR     := .F.

	If Len(paCodFat)= 0
		cCodFat 	  := pcCodFat
		cEscri		  := pcEscri
		::cCodEsc     := cEscri
		::cCodFat     := cCodFat
		aAdd(::aCods, {pcEscri, pcCodFat, ::addRelat(pcEscri, pcCodFat)})	
	Else
		For nC := 1 to Len(paCodFat)
			pcCodFat 	  := paCodFat[nC, 02]
			pcEscri		  := paCodFat[nC, 01]		
			::cCodEsc     := pcEscri
			::cCodFat     := pcCodFat	
			aAdd(::aCods, {pcEscri, pcCodFat, ::addRelat(pcEscri, pcCodFat)})		
		Next nC
    EndIf
	::cConfig     := pcConfig
Return Self

Method Igual(pcCliente, pcLoja, pcEMail) Class JurEMail
Return ::cCliente == pcCliente .And. ::cLoja == pcLoja .And. ::cEMail == pcEMail

Method GetCliente() Class JurEMail
Return Trim(::cCliente)

Method SetCliente(pcCliente) Class JurEMail
Return ::cCliente := pcCliente

Method GetLoja() Class JurEMail
Return Trim(::cCliente)

Method SetLoja(pcLoja) Class JurEMail
Return ::cLoja := pcLoja

Method GetConfig() Class JurEMail
Return Trim(::cConfig)

Method SetConfig(pcConfig) Class JurEMail
Return ::cConfig := pcConfig

Method GetEMail() Class JurEMail
Return Trim(::cEMail)

Method SetEMail(pcEMail) Class JurEMail
Return ::cEMail := pcEMail

Method GetCods(cTipo) Class JurEMail
Local xRet
Local nI
Default cTipo := 'S'

	Do Case
	Case Upper(cTipo) == 'A'
		xRet := ::aCods
	Case Upper(cTipo) == 'S'
		xRet := ""
		For nI := 1 To Len(::aCods)
			xRet += ::aCods[nI][1] + " / " + ::aCods[nI][2] + CRLF
		Next
	End Case

Return xRet

Method AddCods(pcCodEscri, pcCodFat) Class JurEMail
Return aAdd(::aCods, {pcCodEscri, pcCodFat, ::addRelat(pcCodEscri, pcCodFat)})

Method GetBody() Class JurEMail
Return ::cBody

Method SetBody(pcBody) Class JurEMail
Return ::cBody := pcBody

Method GetMacroLines() Class JurEMail
Local aRet   := {}
Local cCorpo := ::cBody
Local nIni, nFim

	While At(CHR(171), cCorpo) >0 
		nIni := At(CHR(171), cCorpo) + 1
		nFim := At(CHR(187), cCorpo)

		aAdd(aRet, SubString(cCorpo, nIni, nFim - nIni) )
		cCorpo := StrTran( cCorpo, CHR(171) + aRet[Len(aRet)] + CHR(187), "" )
	End
	
Return aRet

Method Substituir() Class JurEMail
Local aArea     := GetArea()
Local aAreaNXA  := NXA->(GetArea())
Local nQtd      := Len(::aCods)
Local nQtdLines := Len(::aLines)
Local nI        := 0
Local nIni      := 0
Local nFim      := 0
Local cHeader	:= ""
Local cFooter   := ""
Local cBody		:= ""
Local cTmpBody  := ""
Local cIniLista := CHR(165)
Local cFimLista := CHR(166)


	If nQtdLines > 0
		nIni   := At(cIniLista, ::cBody)
		nFim   := At(cFimLista, ::cBody)
		If nIni > 0 .And. nFim > 0
			cBody := SubString(::cBody, nIni+1, nFim - nIni-1)
			cHeader := Left(::cBody, nIni-1)
			cFooter := Substr(::cBody, nFim+1)
		Else
			cBody := ::cBody+CRLF
		EndIf

		NXA->(DBSetOrder(1))
		For nI := 1 To nQtd
			If NXA->(DBSeek(xFILIAL('NXA') + ::aCods[nI][1] + ::aCods[nI][2]))
				
				If nI == 1				
					cHeader := ::ProcTag(cHeader)
					::cBody  := cHeader
				EndIf
				cTmpBody := ::ProcTag(cBody)
				::cBody  := ::cBody + cTmpBody
				If nI == nQtd
					cFooter := ::ProcTag(cFooter)
					::cBody  := ::cBody + cFooter
				EndIf
							
			EndIf
		Next
	EndIf

	::lPronto := .T.

	RestArea(aAreaNXA)
	RestArea(aArea)

Return ::lPronto

Method addRelat(pcEscri, pcCodFat) Class JurEMail
Local aRet       := {}
Local cPastaFat  := JurImgFat(pcEscri, pcCodFat, .T.)
Local cRel_Fat   := STR0005 + "_(" + Trim(pcEscri) + "-" + Trim(pcCodFat) + ").pdf"  // Relatorio_
Local cRel_Carta := STR0006 + "_(" + Trim(pcEscri) + "-" + Trim(pcCodFat) + ").pdf"  // Carta_

If ::alRelats[1]
	If File(cPastaFat + cRel_Fat)
		aAdd(aRet, cPastaFat + cRel_Fat)
		::lAchouR := .T.
	EndIf
EndIf

If ::alRelats[2]
	If File(cPastaFat + cRel_Carta)
		aAdd(aRet, cPastaFat + cRel_Carta)
		::lAchouC := .T.
	EndIf
EndIf

If !::lAchouR .And. ::lAchouC .And. ::alRelats[1] .And. ::alRelats[2]
	If !ApMsgYesNo(STR0001 + pcEscri + "/" + pcCodFat + STR0003) //"O Relatório de Faturamento não existe para: Deseja enviar assim mesmo? "
		::lEnviar := .F.
	EndIf
	
ElseIf ::lAchouR .And. !::lAchouC .And. ::alRelats[2] .And. ::alRelats[2]
	If !ApMsgYesNo(STR0002+pcEscri+"/"+pcCodFat+STR0003) //"O Relatório de Carta de Cobrança não existe para: Deseja enviar assim mesmo? "
		::lEnviar := .F.
	EndIf
	
ElseIf !::lAchouR .And. ::alRelats[1] .And. !(::alRelats[2])
	MsgStop(STR0001+pcEscri+"/"+pcCodFat) //"O Relatório de Faturamento não existe para: "
	::lEnviar := .F.
	
ElseIf !::lAchouC .And. !(::alRelats[1]) .And. ::alRelats[2]
	MsgStop(STR0002+pcEscri+"/"+pcCodFat) //"O Relatório de carta de cobrança não existe para: "
	::lEnviar := .F.
	
ElseIf !::lAchouC .And. !::lAchouR .And. ::alRelats[1] .And. ::alRelats[2]
	MsgStop(STR0004+pcEscri+"/"+pcCodFat) //"O Relatório de carta de cobrança não existe para: "
	::lEnviar := .F.
EndIf

Return aRet

Method GetRelat() Class JurEMail
Local cRet := ""
Local nI

If ::alRelats[1] .And. ::lAchouR // Faturamento
	For nI := 1 To Len(::aCods)
		cRet += ::aCods[nI][3][1] + "; "
	Next
EndIf

If ::alRelats[2] .And. ::lAchouC // Carta
	For nI := 1 To Len(::aCods)
		If Len(::aCods[nI][3]) > 1
			cRet += ::aCods[nI][3][2] + "; "
		Else
			cRet += ::aCods[nI][3][1] + "; "
		EndIf
	Next
EndIf

Return cRet

Method ProcTag(cTmpBody) Class JurEMail 
Local nIni		:= 0
Local nFim		:= 0
Local cCampo 	:= ""
Local cValor 	:= ""
Local cFormat	:= ""
Local xValor	:= NIL

Default cTmpBody := ""

While At(CHR(171), cTmpBody) > 0
	nIni   := At(CHR(171), cTmpBody) + 1
	nFim   := At(CHR(187), cTmpBody)
	cCampo := SubString(cTmpBody, nIni, nFim - nIni)
	
	If JURX3INFO( cCampo, "X3_CONTEXT" ) != "V"
		If ValType(NXA->(&cCampo)) == 'N'
			cValor := AllTrim(Transform(NXA->(&cCampo), PesqPict("NXA", cCampo)))
		ElseIf ValType(NXA->(&cCampo)) == 'D'
			If !Empty(::cConfig) .And. NRU->(ColumnPos("NRU_DTFORM")) > 0 // Formato dos campos de data na configuração de envio de e-mail
				If !Empty(NXA->(&cCampo))
					cFormat := JurGetDados("NRU", 1, xFilial("NRU") + ::cConfig, "NRU_DTFORM")
					If cFormat == "1"     // 1=DD/MM/YYYY
						cValor := DToC(NXA->(&cCampo))
					ElseIf cFormat == "2" // 2=MM/DD/YYYY
						cValor := StrZero(Month(NXA->(&cCampo)), 2) + "/" + StrZero(Day(NXA->(&cCampo)), 2) + "/" + Alltrim(Str(Year(NXA->(&cCampo))))
					ElseIf cFormat == "3" // 3=YYYY/MM/DD
						cValor := Str(Year(NXA->(&cCampo))) + "/" + StrZero(Month(NXA->(&cCampo)), 2) + "/" + StrZero(Day(NXA->(&cCampo)), 2)
					EndIf
				Else 
					cValor := ""
				EndIf
			Else
				cValor := DToC(NXA->(&cCampo))
			EndIf
		Else
			cValor := NXA->(&cCampo)
		EndIf
	Else
		xValor := &(JURX3INFO( cCampo, "X3_INIBRW" ))
		
		If ValType(xValor) == 'N'
			cValor := AllTrim(Transform(xValor, '@E 99,999,999,999.99'))
		ElseIf ValType(xValor) == 'D'
			If !Empty(::cConfig) .And. NRU->(ColumnPos("NRU_DTFORM")) > 0 // Formato dos campos de data na configuração de envio de e-mail
				If !Empty(xValor)
					cFormat := JurGetDados("NRU", 1, xFilial("NRU") + ::cConfig, "NRU_DTFORM")
					If cFormat == "1"     // 1=DD/MM/YYYY
						cValor := DToC(xValor)
					ElseIf cFormat == "2" // 2=MM/DD/YYYY
						cValor := StrZero(Month(xValor), 2) + "/" + StrZero(Day(xValor), 2) + "/" + Alltrim(Str(Year(xValor)))
					ElseIf cFormat == "3" // 3=YYYY/MM/DD
						cValor := Str(Year(xValor)) + "/" + StrZero(Month(xValor), 2) + "/" + StrZero(Day(xValor), 2)
					EndIf
				Else
					cValor := ""
				EndIf
			Else
				cValor := DToC(xValor)
			EndIf
		Else
			cValor := xValor
		EndIf
	EndIf
	cTmpBody := StrTran(cTmpBody, CHR(171) + cCampo + CHR(187), cValor  )
EndDo

Return cTmpBody