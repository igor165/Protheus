#INCLUDE 'protheus.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³M500AR    ³ Autor ³ Jesus Peñaloza          ³Data  ³11/07/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion para el calculo del impuesto 500 Arancel sim impo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M500AR                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Base, Aliquota y Valor del impuesto                          ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M500AR(cCalculo,nItem,aInfo,cXFisRap)
Local xRet
Local lXfis
Local nBase
lXfis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")
If !lXfis
	Return
Else
	SFB->(DbSetOrder(1))
	SFB->(MsSeek(xFilial()+aInfo[1]))
	SB1->(DbSetOrder(1))
	SB1->(MsSeek(xFilial()+MaFisRet(nItem,"IT_PRODUTO")))
	SFF->(DbSetOrder(7))
	If SFF->(DbSeek(xFilial()+ SB1->B1_POSIPI+SB1->B1_EX_NCM+SB1->B1_EX_NBM + aInfo[1] ))
		_nAliquota	:= SFF->FF_ALIQ
	Else
		_nAliquota	:= SFB->FB_ALIQ
	Endif
	xRet:=0
	
	If !Empty(cXFisRap)
		xRet := {0,_nAliquota,0}
		If "V" $ cXFisRap
			dbSelectArea("SFF")
			SFF->(dbSetOrder(1))
			If SFF->(dbSeek(xFilial("SFF")+"FFFFFF"))
				nBase := SFF->FF_IMPORTE
			Else
				nBase := 0
			EndIf
		Endif
	Else
		Do Case
			Case cCalculo=="A"
				xRet := _nAliquota
			Case cCalculo=="B"
				xRet := 0
			Case cCalculo=="V"
				dbSelectArea("SFF")
				SFF->(dbSetOrder(1))
				If SFF->(dbSeek(xFilial("SFF")+"FFFFFF"))
					xRet := SFF->FF_IMPORTE
				Else
					xRet := 0
				EndIf
		Endcase
	EndIf
EndIf
Return xRet