#include "SIGAWIN.CH"

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    1 //Nome do imposto
#DEFINE X_NUMIMP     2 //Sufixo do imposto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M100ICB   ¦ Autor ¦ Veronica Flores        ¦ Data ¦ 06.09.19  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Programa que Calcula ICB   (PERU)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA467/MATA468                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100ICB(cCalculo,nItem,aInfo)

Local nDecs := 0
Local nI	:= 0
Local lXFis
Local nBase := 0
Local cAliasROT, cOrdemROT
Local aImpRef,aImpVal
Local aArea	   		:= GetArea()

SetPrvt("AITEMINFO,xRet,CIMPINCID,_ALIQICB")
SetPrvt("NI,NEE")

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")
cAliasROT:= Alias()
cOrdemROT:= IndexOrd()

//+---------------------------------------------------------------+
//¦ Caso seja pedido de Compra		         					  ¦
//+---------------------------------------------------------------+	
If !lXFis
	aItemINFO:=ParamIxb[1]
	xRet:=ParamIxb[2]
	cImpIncid:=xRet[10]
Endif

nMoedaCor := IIf(Type("nMoedaCor")	=="U",1,nMoedaCor)
nDecs := MsDecimais(nMoedaCor)
_AliqICB:=0

//+---------------------------------------------------------------+
//¦ Caso seja pedido de Compra		         					  ¦
//+---------------------------------------------------------------+
If !lXFis

	DbSelectArea("SFB")
	SFB->(DbSetOrder(1))	//FB_FILIAL+FB_CODIGO
	If SFB->(MsSeek(xFilial("SFB") + xRet[1] ))
		_AliqICB := SFB->FB_VALIMPU
	Endif
	
	xRet[2]  := _aliqICB                     		// Alíquota
	xRet[11] := 0									// Rateio do Frete
	xRet[13] := 0     								// Rateio de Despesas
	xRet[3]  := aItemINFO[1]          				// Base de Cálculo
	//+----------------------------------------------------------+
	//¦ Efetua o Cálculo do Imposto                              ¦
	//+----------------------------------------------------------+
	xRet[4] := Round((xRet[2] * xRet[3]),nDecs)
	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Valor da Base aplicada a Aliquota    ³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  
	Do Case
		Case cCalculo == "B"                                                                                                          
			xRet   := MaFisRet(nItem,"IT_QUANT")	
		Case cCalculo == "A"
			If SFB->(MsSeek(xFilial("SFB") + aInfo[X_IMPOSTO]))
				_AliqICB := SFB->FB_VALIMPU
			Endif
			xRet:=_AliqICB
		Case cCalculo == "V"
			nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
			_AliqICB:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
			xRet := Round((_AliqICB * nBase), nDecs)
	EndCase

Endif

RestArea(aArea)
Return( xRet )