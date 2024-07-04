#Include 'Protheus.ch'

//-------------------------------------------------------------------
/* {Protheus.doc} PCOXRES
Função de integração entre o módulo de viagens e o PCO

@author alvaro.camillo

@since 29/12/2015
@version 12.1.7 Fev 2016
*/
//-------------------------------------------------------------------

Function PCOXRES(aDados,cEvento,cErro)
Local lRet		:= .T.
Local aArea		:= GetArea()
Local cCodProc	:= "000401"
Local cCodItem	:= ""
Local cCodBloq	:= ""
Local nX		:= 0
Local cCampo	:= ""
Local xValor	:= Nil
Local aStru		:= FO6->(dbStruct())
Local cCodFO6	:= ''

//Seleciona o item através do evento
If cEvento == '1'
	cCodItem := "01"
	cCodBloq := cCodItem
ElseIf cEvento == '2'
	cCodItem := "02"
ElseIf cEvento == '3'
	cCodItem := "03"
	cCodBloq := cCodItem	
ElseIf cEvento == '4'
	cCodItem := "04"
ElseIf cEvento == '5'
	cCodItem := "05"
	cCodBloq := cCodItem
ElseIf cEvento == '6'
	cCodItem := "06"
ElseIf cEvento == '7'
	cCodItem := "07"
EndIf

cCodFO6 := GetSxEnum('FO6','FO6_CODIGO')

PcoIniLan(cCodProc)
//Carrega as variáveis para memória
RegToMemory("FO6",.T.)

For nX := 1 to Len(aDados)
	cCampo := aDados[nX][1]
	xValor := aDados[nX][2]

	If FO6->(FieldPos(cCampo)) > 0
		M->(&cCampo) := xValor
	EndIf
Next nX

If !Empty(cCodBloq)
	lRet := PcoVldLan(cCodProc,cCodBloq,"PCOXRES",/*lUsaLote*/,/*lDeleta*/, /*lVldLinGrade*/, @cErro)
Else
	lRet := .T.
EndIf

If lRet
	RecLock("FO6",.T.)
	For nX := 1 TO Len(aStru)
		cCampo := aStru[nX][1]
		FO6->(&cCampo) := M->&cCampo
	Next nX
	FO6->FO6_FILIAL := xFilial("FO6")
	FO6->FO6_CODIGO := cCodFO6
	MsUnlock()
	ConfirmSX8()
	PcoDetLan(cCodProc,cCodItem,"PCOXRES")
Else
	RollBackSX8()
Endif

PcoFinLan(cCodProc)
PcoFreeBlq(cCodProc)

RestArea(aArea)

Return lRet