#INCLUDE "ACDV110.ch" 
#INCLUDE "APVT100.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณACDV110   บAutor  ณRicardo             บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ O objetivo do programa e consultar etiquetas de cod. barrasบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACD                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/                
Function ACDV110()
Local cEtiq := Space(64)
Local aTela := VTSave()
Local nL    := VTRow()
Local nC    := VTCol()
Local aArea    := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSB2 := SB2->(GetArea())
Local aAreaSBE := SBE->(GetArea())
Local aAreaSBF := SBF->(GetArea())
Local aAreaCB2 := CB2->(GetArea())
Local aAreaCB6 := CB6->(GetArea())
Local aAreaCB9 := CB9->(GetArea())
Local lAtvCons := GetNewPar("MV_ATVCONS","1") =="1"
Local cCodOpe  := CBRetOpe()
Local ckey03
Local bkey03
Local lCtrWms := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local aAreaD14 := IIF  (lCtrWms, D14->(GetArea()), NIL )

Private aHist  :={}
If MscbIsPrinter() .or. InTransact() .or. !lAtvCons
	Return
EndIf

If !Empty(cCodOpe) .AND. !(CB1->CB1_ATVCON $ " 1")
	Return
Endif

ckey03 := VTDescKey(03)
bkey03 := VTSetKey(03)

VtClearBuffer()
While .t.
	aHist := {}
	VTClear()
	If VtModelo()== "RF"
		@ 0,0  VTSay STR0010 //"Consulta"
		@ 1,0  VTSay STR0001 //"Etiqueta"
		@ 2,0  VTGet cEtiq pict '@!' VALID InfoEtiq(cEtiq)
	Else
		@ 0,0 VTSay STR0010 //"Consulta"
		@ 1,0 VTGet cEtiq pict '@!' VALID InfoEtiq(cEtiq)
	EndIf
	VTRead
	If VTLastKey() == 27
		Exit
	EndIf
Enddo
VTRestore(,,,,aTela)
@ nL,nC VtSay ""

RestArea(aArea)
RestArea(aAreaSB1)
RestArea(aAreaSB2)
RestArea(aAreaSBE)
RestArea(aAreaSBF)
RestArea(aAreaCB2)
RestArea(aAreaCB6)
RestArea(aAreaCB9)
IF lCtrWms
	RestArea(aAreaD14)
EndIF
VTSetKey(03,bkey03,ckey03)
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณInfoEtiq  บAutor  ณRicardo             บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao retorna as informacoes da etiqueta              บฑฑ
ฑฑบ          ณEtiqueta:                                                   บฑฑ
ฑฑบ          ณ - Produto                                                  บฑฑ
ฑฑบ          ณ - Localizacao                                              บฑฑ
ฑฑบ          ณ - Dispositivo                                              บฑฑ
ฑฑบ          ณ - Volume                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACD                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
*/
Static Function InfoEtiq(cEtiqueta)
Local cTipo
Local aItensPallet

If	Empty(cEtiqueta)
	MenuPrdEnd()
	VTKeyBoard(chr(20))
	aHist := {}  //Limpa array Dados Gerais
 	Return .f.
EndIf
If ! CBLoad128(@cEtiqueta)
	aHist := {}  //Limpa array Dados Gerais
	Return .F.
EndIf

cTipo:=CBRetTipo(cEtiqueta)
If cTipo == "EAN8OU13" .or. cTipo =="EAN14"
	Cons8OU13(cEtiqueta)
ElseIf cTipo =="EAN128"
	Cons128(cEtiqueta)
ElseIf cTipo=="01" //produto
	Cons01(cEtiqueta)
Elseif cTipo=="02" //localizacao
	Cons02(cEtiqueta)
Elseif cTipo=="03" //dispositivo
	Cons03(cEtiqueta)
Elseif cTipo=="05" //volume
	Cons05(cEtiqueta)
ElseIf ! Empty(aItensPallet := CBItPallet(cEtiqueta))
	ConsPallet(aItensPallet,cEtiqueta)
	VTKeyBoard(chr(20)) //Limpa o get
Else
	VtBeep(2)
	VtAlert(STR0008,STR0009,.T.,4000) //"Nao ha consulta para esta etiqueta."###"Aviso"
	VTKeyBoard(chr(20)) //Limpa o get
	aHist := {}  //Limpa array Dados Gerais	
	Return .F.
EndIf

aHist := {}  //Limpa array Dados Gerais
Return .F.


Static Function MenuPrdEnd()
Local aTela := VTSave()
Local nPos	:= 1
Private cProd :=Space(Tamsx3("B1_COD")[1])
private cArm  :=Space(Tamsx3("B1_LOCPAD")[1])
Private cEnd  :=Space(15)
Private M->CBA_LOCAL := cArm  // utilizado na consulta de endereco
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
If GetMv("MV_LOCALIZ") == "S"
	If VTModelo()=="RF" .and. !lVT100B
		@ 4,0 VTSay Repli("-",20)
		nPos:=VTAchoice(5,0,7,VtmaxCol(),{STR0002,STR0011,STR0012}) //"Produto"###"Armazem"###"Endereco"
	Else
		nPos:=VTAchoice(0,0,VtMaxRow(),VtmaxCol(),{STR0002,STR0011,STR0012}) //"Produto"###"Armazem"###"Endereco"		
	EndIf
EndIf
VTRestore(,,,,aTela)
VtClearBuffer()
If nPos ==0
	Return
EndIf
If VTModelo()=="RF" .and. !lVT100B
	If nPos == 1
		@ 5,0  VTSay STR0013 //'Produto'
		@ 6,0  VTGet cProd pict '@!' VALID VldProd(cProd) F3 "SB1"
	ElseIf nPos == 2
		@ 5,0  VTSay STR0014 //'Armazem'
		@ 6,0  VTGet cArm pict "@!" Valid VldArm(cArm,"A") 
	ElseIf nPos == 3
		@ 5,0  VTSay STR0015 //'Endereco'
		@ 6,0  VTGet cArm pict "@!" Valid VldArm(cArm,"E")
		@ 6,4  VTSay "-" VTGet cEnd pict '@!' VALID VldEnd(cArm,cEnd) F3 "CBA"
	EndIf
	VTRead
Else
	IF nPos == 1
		@ 0,0  VTSay STR0037 //'Produto '
		@ 1,0  VTGet cProd pict '@!' VALID VldProd(cProd) F3 "SB1"
	ElseIf nPos == 2
		@ 0,0  VTSay STR0014 //'Armazem'
		@ 1,0  VTGet cArm pict "@!" Valid VldArm(cArm,"A") 
	ElseIf nPos == 3
		@ 0,0  VTSay STR0015 //'Endereco'
		@ 1,0  VTGet cArm pict "@!" Valid VldArm(cArm,"E")
		@ 1,4  VTSay "-" VTGet cEnd pict '@!' VALID VldEnd(cArm,cEnd) F3 "CBA"
	EndIf
	VTRead
EndIf
vtRestore(,,,,aTela)
VTKeyBoard(chr(20)) //Limpa o get
Return .f.

Return .f.

Static Function VldProd(cProd)
If Empty(cProd)
	VtKeyBoard(chr(23))
	Return .f.
EndIf
SB1->(DbSetOrder(1))
If ! SB1->(DbSeek(xFilial("SB1")+cProd))
	VTBEEP(2)
	VTALERT(STR0016,STR0009,.T.,4000)    //"Produto nao encontrado"###"AVISO"
	VTClearGet()
	Return .f.
EndIf
aHist :={	{STR0017,cProd},; //"Codigo"
			{STR0003,SB1->B1_DESC},; //"Descricao"
			{STR0018,SB1->B1_UM}} //"U.M."
MenuProdc(cProd)
Return

Static Function VldArm(cArm,cTipo)
Local aTela
Local aFields
Local aHeader

If Empty(cArm)
	Return .t.
EndIf
SBE->(DbSetOrder(1))
If ! SBE->(DbSeek(xFilial("SBE")+cArm))
	VTBeep(3)
	VTAlert(STR0019,STR0020,.t.,4000) //'Armazem nao existe'###'Aviso'
	VTKeyBoard(chr(20))
	Return .f.
EndIf
M->CBA_LOCAL := cArm  // variavel criada para filtrar a consulta
If cTipo == "A"
	SBE->(DbSetOrder(1))
	If ! SBE->(DbSeek(xFilial("SBE")+cArm))
		VTBeep(3)
		VTAlert(STR0019,STR0020,.t.,4000) //'Armazem nao existe'###'Aviso'
		VTKeyBoard(chr(20))
		Return .f.
	EndIf

	DbSelectArea("SB2")
	SB2->(DbOrderNickName("ACDSB201"))
	SB2->(DbSeek(xFilial("SB2")+cArm+Str(0.01,12,2),.t.))
	If SB2->(Eof()) .Or. cArm # SB2->B2_LOCAL
		VTBeep(3)
		VTAlert(STR0034,STR0009,.t.,4000)  //"Nao existe produto a enderecar neste armazem"###"Aviso"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	cToPCB8 := SB2->(xFilial("SB2")+B2_LOCAL+STR(B2_QACLASS,12,2))
	cBottomCb8 := SB2->(xFilial("SB2")+B2_LOCAL+REPL("9",12))  

	aFields := {	{|| SB2->B2_COD},;
						{|| Posicione("SB1",1,xFilial("SB1")+SB2->B2_COD,"B1_DESC")},;
						{|| Transform(B2_QACLASS,CBPictQtde())} }
	aHeader := {'COD',STR0035,STR0036}        //'Descricao     '###'A Classificar'

	aTela   := VtSave()
	VTClear()
	VtClearBuffer()

	VTDbBrowse(0,0,7,19,"SB2",aHeader,aFields,{15,20,15},,"'"+cToPCB8+"'","'"+cBottomCb8+"'")
	VTRestore(,,,,aTela)
	Return .t.
EndIf
Return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VldEnd   บ Autor ณ     TOTVS	         บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ O objetivo do programa e Validar o Endereco                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACD                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function VldEnd(cArmazem,cEndereco)
VTClearBuffer()
If Empty(cEndereco)
	VtKeyBoard(chr(23))
	Return .f.
EndIf
SBE->(DbSetOrder(1))
If ! SBE->(DbSeek(xFilial("SBE")+cArmazem+cEndereco))
	VTBEEP(2)
	VTALERT(STR0022,STR0009,.T.,4000)    //"Endereco nao encontrado"###"AVISO"
	VTClearGet()
	VTClearGet("cArm")
	VTGetSetFocus("cArm")
	Return .f.
EndIf
Cons02(NIL,cArmazem,cEndereco)
Return


Static Function Cons8OU13(cEtiqueta)
Local aEtiqueta := {}
aEtiqueta := CBRetEtiEan(cEtiqueta)
If Len(aEtiqueta) >= 1
	aadd(aHist,{STR0002,aEtiqueta[1]}) //"Produto"
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+aEtiqueta[1]))
	aadd(aHist,{STR0003,Left(SB1->B1_DESC,20)}) //"Descricao"
	aadd(aHist,{"U.M.",SB1->B1_UM}) 
	aadd(aHist,{"2 U.M.",SB1->B1_SEGUM}) 
	aadd(aHist,{STR0038,SB1->B1_CONV})  //"Fator Conv."
EndIf
If Len(aEtiqueta) >= 2
	aadd(aHist,{STR0004,aEtiqueta[2]}) //"Quantidade"
EndIf
aadd(aHist,{STR0023,cEtiqueta}) //"Codigo Barras"
If empty(aEtiqueta)
	DadosGerais()
Else
	MenuProdc(aEtiqueta[1])
EndIf
Return .F.


Static Function Cons128(cEtiqueta)
Local nX
Local aEtiqueta  := {}
Local aEtiqueta2 := {}

aEtiqueta := CBRetEtiEan(cEtiqueta)

If Len(aEtiqueta) >= 1
	aadd(aHist,{STR0002,aEtiqueta[1]}) //"Produto"
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+aEtiqueta[1]))
	aadd(aHist,{STR0003,Left(SB1->B1_DESC,20)}) //"Descricao"
	aadd(aHist,{STR0018,SB1->B1_UM})  //"U.M."
	aadd(aHist,{STR0039,SB1->B1_SEGUM})  //"2 U.M."
	aadd(aHist,{STR0038,SB1->B1_CONV})  //"Fator Conv."
EndIf
If Len(aEtiqueta) >= 2
	aadd(aHist,{STR0004,Str(aEtiqueta[2],6)}) //"Quantidade"
	aadd(aHist,{"---------------","---------------"})
EndIf

aEtiqueta2 := CBAnalisa128(cEtiqueta)
If len(aEtiqueta2) > 0
	For nX:= 1 to Len(aEtiqueta2)
		aadd(aHist,{aEtiqueta2[nX,1]+'-'+aEtiqueta2[nX,3],aEtiqueta2[nX,2]})
	Next
EndIf
If Empty(aEtiqueta) .And. ! Empty(aEtiqueta2)
	DadosGerais()
ElseIf ! Empty(aEtiqueta)
	MenuProdc(aEtiqueta[1])
EndIf
Return .F.

Static Function ConsPallet(aItens,cEtiqueta)
Local nx
Local aEtiqueta
Local aHist:={}
Local aSize
Local aCab
Local aTela
Local nPos
Local nTot:=0
If UsaCb0("01")
	For nx:= 1 to Len(aItens)
		aEtiqueta:= CBRetEti(aItens[nx])
		aadd(aHist,{CB0->CB0_CODETI,CB0->CB0_CODPRO,Transform(CB0->CB0_QTDE,"@E 999,999,999.999"),CB0->CB0_LOTE,CB0->CB0_SLOTE})
		nTot+=CB0->CB0_QTDE
	Next
	aSize := {15,15,15,15,15}
	aCab  := {STR0001,STR0002,STR0004,STR0025,STR0026} //"Etiqueta"###"Produto"###"Quantidade"###"Lote"###"SubLote" 
	aTela := VTSave()
	While .t.
		VTClear()
		@ 0,0 VTSay STR0040+CB0->CB0_PALLET //"Pallet "
		@ 1,0 VTSay STR0041+Transform(nTot,"@E 9,999,999.999") //"Total:"
		nPos := VTaBrowse(2,0,VTMaxRow(),VtmaxCol(),aCab,aHist,aSize)
	
		If VtLastkey() == 27
			Exit
		EndIf
		Cons01(aHist[nPos,1])
	
	End
	VtRestore(,,,,aTela)
Else

	For nx:= 1 to Len(aItens)
		aEtiqueta:= CBRetEtiEan(aItens[nx])
		aadd(aHist,aClone(aEtiqueta))
	Next
	aSize := {15,15,15,10,15}
	aCab  := {STR0002,STR0004,STR0025,STR0043,STR0044} //"Produto"###"Quantidade"###"Lote"###"SubLote"###"Dt.Valid"###"Serie" 
	aTela := VTSave()
	While .t.
		VTClear()
		@ 0,0 VTSay STR0040+cEtiqueta //"Pallet "
		@ 1,0 VTSay STR0041+Transform(len(aItens),"@E 9,999,999.999") //"Total:"
		nPos := VTaBrowse(2,0,VTMaxRow(),VtmaxCol(),aCab,aHist,aSize)
	
		If VtLastkey() == 27
			Exit
		EndIf
		VldProd(aHist[nPos,1])
	
	End
	VtRestore(,,,,aTela)

EndIf	


Return .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Cons01   บ Autor ณ     TOTVS	         บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ O objetivo do programa e Efetuar a consulta do Produto     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACD                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function Cons01(cEtiqueta)
Local nY,nX
Local aEtiqueta := {}
Local cAlias := "CB0"
Local aStruCB0 := {}

aStruCB0  := FWFormStruct(3, cAlias)[3]

aEtiqueta := CBRetEti(cEtiqueta,"01",.T.,.T.)
For nX := 1 To Len(aStruCB0)
	If X3USO(GetSx3Cache(aStruCB0[nX,1], "X3_USADO")) .And. cNivel >= GetSx3Cache(aStruCB0[nX,1], "X3_NIVEL") .And. GetSx3Cache(aStruCB0[nX,1], "X3_VISUAL") <> 'V'
		nY := &(cAlias)->(FieldPos(GetSx3Cache(aStruCB0[nX,1], "X3_CAMPO")))
		If ! Empty(&(cAlias)->(FieldGet(nY)))
			If Valtype(&(cAlias)->(FieldGet(nY))) == "C"
				If ! Empty(GetSx3Cache(aStruCB0[nX,1], "X3_CBOX"))
					aadd(aHist,{GetSx3Cache(aStruCB0[nX,1], "X3_TITULO"),X3Combo(GetSx3Cache(aStruCB0[nX,1], "X3_CAMPO") ,&(cAlias)->(FieldGet(nY)))})
				Else
					aadd(aHist,{GetSx3Cache(aStruCB0[nX,1], "X3_TITULO"),&(cAlias)->(FieldGet(nY))})
				EndIf		
			ElseIf	Valtype(&(cAlias)->(FieldGet(nY))) == "N"
				aadd(aHist,{GetSx3Cache(aStruCB0[nX,1], "X3_TITULO"),Alltrim(Str(&(cAlias)->(FieldGet(nY))))})
			ElseIf	Valtype(&(cAlias)->(FieldGet(nY))) == "D"
				aadd(aHist,{GetSx3Cache(aStruCB0[nX,1], "X3_TITULO"),Alltrim(Dtoc(&(cAlias)->(FieldGet(nY))))})
			EndIf		
		EndIf
	EndIf
Next nX		

dbSelectArea(cAlias)
If Empty(aEtiqueta)
	DadosGerais()
Else
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+aEtiqueta[1]))
	aadd(aHist,{Repl("-",20),Repl("-",20)})
	aadd(aHist,{STR0003,Left(SB1->B1_DESC,20)}) //"Descricao"
	aadd(aHist,{STR0018,SB1->B1_UM})  //"U.M."
	aadd(aHist,{STR0039,SB1->B1_SEGUM})  //"2 U.M."
	aadd(aHist,{STR0038,SB1->B1_CONV})  //"Fator conv."
	MenuProdc(aEtiqueta[1])
EndIf 
aHist:={}
Return .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Cons02   บ Autor ณ     TOTVS	         บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ O objetivo do programa e Efetuar a consulta do endereco    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACD                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function Cons02(cEtiqueta,cArmazem,cEndereco)
Local aSize     := {}
Local aCab      := {}
Local aEtiqueta := {}
Local aTela
Local cQuery   := ""
Local cWhere   := ""
Local cAlias   := ""
Local lA110FEND := ExistBlock("A110FEND")
Local lCtrWms := SuperGetMv("MV_WMSNEW",.F.,.F.)

If cEtiqueta <>NIL
	aEtiqueta := CBRetEti(cEtiqueta,"02")
	If Empty(aEtiqueta)
		VTBEEP(2)
		VTALERT(STR0024,STR0009,.T.,4000)  //"Etiqueta Invalida"###"Aviso"
		VTKeyBoard(chr(20)) //Limpa o get
		Return .F.
	EndIf
	cArmazem  := aEtiqueta[02]
	cEndereco := aEtiqueta[01]
EndIf

//Saldo por localizacao
	If lCtrWms
		// Verifica se o endere็o controla WMS
		cQuery := " SELECT 1"
		cQuery +=   " FROM "+RetSqlName("SBE")+" SBE"
		cQuery +=  " WHERE SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
		cQuery +=    " AND SBE.BE_LOCAL = '"+cArmazem+"'"
		cQuery +=    " AND SBE.BE_LOCALIZ = '"+cEndereco+"'"
		cQuery +=    " AND SBE.BE_CODZON <> ' '"
		cQuery +=    " AND SBE.BE_ESTFIS <> ' '"
		cQuery +=    " AND SBE.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAlias := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		If (cAlias)->(Eof())
			lCtrWms := .F.
		EndIf
		(cAlias)->(DbCloseArea())
	EndIf
	If !lCtrWms
		cQuery := "SELECT SBF.BF_PRODUTO,SB1.B1_DESC,SBF.BF_QUANT,SBF.BF_LOTECTL,SBF.BF_NUMLOTE,SBF.BF_EMPENHO "
		cQuery += "FROM "+RetSqlName("SBF")+" SBF, "+RetSqlName("SB1")+" SB1"
		cQuery += "WHERE " 
		cQuery += "SBF.BF_FILIAL  ='"+xFilial("SBF")+"' "+"AND "
		cQuery += "SBF.BF_LOCAL   ='"+cArmazem+"' " +"AND " 
		cQuery += "SBF.BF_LOCALIZ ='"+cEndereco+"' "+"AND " 
		cQuery += "SB1.B1_FILIAL  ='"+xFilial("SB1")+"' "
		cQuery += "AND SBF.BF_PRODUTO = SB1.B1_COD "
		cQuery += "AND SBF.D_E_L_E_T_ <> '*' "
		cQuery += "AND SB1.D_E_L_E_T_ <> '*' "
	Else
		cQuery := " SELECT D14.D14_PRODUT BF_PRODUTO,"
		cQuery +=        " SB1.B1_DESC,"
		cQuery +=        " D14.D14_QTDEST BF_QUANT,"
		cQuery +=        " D14.D14_LOTECT BF_LOTECTL,"
		cQuery +=        " D14.D14_NUMLOT BF_NUMLOTE,"
		cQuery +=        " D14.D14_QTDEMP BF_EMPENHO"
		cQuery +=   " FROM "+RetSqlName("D14")+" D14"
		cQuery +=  " INNER JOIN "+RetSqlName("SB1")+" SB1"
		cQuery +=     " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
		cQuery +=    " AND SB1.B1_COD = D14.D14_PRODUT"
		cQuery +=  " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=    " AND D14.D14_LOCAL = '"+cArmazem+"'"
		cQuery +=    " AND D14.D14_ENDER = '"+cEndereco+"'"
		cQuery +=    " AND D14.D_E_L_E_T_ = ' '"
		cQuery +=    " AND SB1.D_E_L_E_T_ = ' '"
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ A110FEND - Ponto de Entrada para filtro da consulta de etiquetas por endere็o ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lA110FEND
		cWhere := ExecBlock("A110FEND",.F.,.F.,{cQuery})
		If ValType(cWhere) == "C" .And. Len(cWhere) > 1
			cQuery += " AND "+ cWhere + " "
		EndIf
	EndIf
	
	cQuery    := ChangeQuery(cQuery)
	cAlias := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	While !(cAlias)->(Eof())
		Aadd(aHist,{;
			(cAlias)->BF_PRODUTO,;
			Left((cAlias)->B1_DESC,20),;
			PadL(Alltrim(Transform((cAlias)->BF_QUANT,PesqPict("SBF","BF_QUANT"))),Tamsx3("BF_QUANT")[1]),;
			(cAlias)->BF_LOTECTL,;
			(cAlias)->BF_NUMLOTE,;
			PadL(Alltrim(Transform((cAlias)->BF_EMPENHO,PesqPict("SBF","BF_EMPENHO"))),Tamsx3("BF_EMPENHO")[1]) })
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

If !Empty(aHist)
	aTela := VTSave()
	VTClear()
	aSize := {15,20,Tamsx3("BF_QUANT")[1],15,15,Tamsx3("BF_EMPENHO")[1]}
	aCab  := {STR0002,STR0003,STR0004,STR0025,STR0026,STR0033} //"Produto"###"Descricao"###"Quantidade" //"Lote"###"SubLote" //"Empenho"
	If VTModelo()=="RF"
		@0,0 VTSay cArmazem+'-'+cEndereco
		VTaBrowse(1,0,VTMaxRow(),VtmaxCol(),aCab,aHist,aSize)
	Else
		VTaBrowse(0,0,VTMaxRow(),VtmaxCol(),aCab,aHist,aSize)
	EndIf
	vtRestore(,,,,aTela)
	VtClearBuffer()
Else
	VTBeep()
	VTAlert(STR0027,STR0020,.t.,4000) //'Endereco Vazio'###'Aviso'
EndIf
VTKeyBoard(chr(20))
Return .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Cons03   บ Autor ณ     TOTVS	         บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ O objetivo do programa e Efetuar a consulta do dispositivoบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACD                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function Cons03(cEtiqueta)
Local aSize     := {}
Local aCab      := {}
Local aTamCpo   := {}
Local aEtiqueta := {}
Local nPos      := 0
Local aTela

aEtiqueta := CBRetEti(cEtiqueta,"03")

dbSelectArea("CB2") //Dispositivo
If CB2->(dbSeek(xFilial("CB2")+aEtiqueta[1]))
	If	CB2->CB2_STATUS == "3" .or. CB2->CB2_STATUS == "7" //Embalagem ou Embarque
		dbSelectArea("CB6") //Volumes de Embalagem
		CB6->(dbSetOrder(3))
		If CB6->(dbSeek(xFilial("CB6")+aEtiqueta[1]))
			While ! CB6->(Eof()) .and. xFilial("CB6") == CB6->CB6_FILIAL .and. CB6->CB6_DISPID == aEtiqueta[1]
				aadd(aHist,{CB6->CB6_VOLUME,CB6->CB6_PEDIDO,X3Combo("CB6_STATUS",CB6->CB6_STATUS)})
				CB6->(dbSkip())
			EndDo
		EndIf
		If !Empty(aHist)
			aTela := VTSave()
			VTClear()
			aSize := {10,06,15}
			aCab  := {STR0005,STR0006,STR0007} //"Volume"###"Pedido"###"Status"
			VTaBrowse(0,0,VTMaxRow(),VtmaxCol(),aCab,aHist,aSize)
			vtRestore(,,,,aTela)
			VtClearBuffer()
		EndIf
	ElseIf CB2->CB2_STATUS == "2" //Em separacao
		dbSelectArea("CB9")  //Produtos separados
		CB9->(dbSetOrder(1))
		If CB9->(dbSeek(xFilial("CB9")+CB2->CB2_ORDSEP))
			aTamCpo := TamSX3("CB9_QTESEP")
			While ! CB9->(Eof()) .and. xFilial("CB9") == CB9->CB9_FILIAL .and. CB9->CB9_ORDSEP == CB2->CB2_ORDSEP
				nPos := aScan(aHist,{|x| x[1] == CB9->CB9_PROD})
				If nPos # 0
					aHist[nPos,3] := Str((Val(aHist[nPos,3]) + CB9->CB9_QTESEP),aTamCpo[1],aTamCpo[2])
				Else
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial("SB1")+CB9->CB9_PROD))
					Aadd(aHist,{CB9->CB9_PROD,Left(SB1->B1_DESC,20),Str(CB9->CB9_QTESEP,aTamCpo[1],aTamCpo[2])})
				EndIf
				CB9->(dbSkip())
			EndDo
		EndIf
		If !Empty(aHist)
			aTela := VTSave()
			VTClear()
			aSize := {15,20,12}
			aCab  := {STR0002,STR0003,STR0004} //"Produto"###"Descricao"###"Quantidade"
			VTaBrowse(0,0,VTMaxRow(),VtmaxCol(),aCab,aHist,aSize)
			vtRestore(,,,,aTela)
			VtClearBuffer()
		EndIf
	EndIf
EndIf
VTKeyBoard(chr(20)) //Limpa o get
Return .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Cons05   บ Autor ณ     TOTVS	         บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ O objetivo do programa e Efetuar a consulta do Volume	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACD                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function Cons05(cEtiqueta)
Local aSize     := {} 
Local aCab      := {}
Local aTamCpo   := {}
Local aEtiqueta := {}
Local aTela

aEtiqueta := CBRetEti(cEtiqueta,"05")

dbSelectArea("CB9")  //Produtos separados
CB9->(dbSetOrder(4))
If CB9->(dbSeek(xFilial("CB9")+aEtiqueta[1]))
	aTamCpo := TamSX3("CB9_QTESEP")
	While ! CB9->(Eof()) .and. xFilial("CB9") == CB9->CB9_FILIAL .and. CB9->CB9_VOLUME == aEtiqueta[1]

		nPos := aScan(aHist,{|x| x[1] == CB9->CB9_PROD})
		If nPos # 0
			aHist[nPos,3] := Str((Val(aHist[nPos,3]) + CB9->CB9_QTESEP),aTamCpo[1],aTamCpo[2])
		Else
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("CB9")+CB9->CB9_PROD))
			Aadd(aHist,{CB9->CB9_PROD,Left(SB1->B1_DESC,20),Str(CB9->CB9_QTESEP,aTamCpo[1],aTamCpo[2])})
		EndIf
		CB9->(dbSkip())
	EndDo
EndIf
If !Empty(aHist)
	aTela := VTSave()
	VTClear()

	aSize := {15,20,12}
	aCab  := {STR0002,STR0003,STR0004} //"Produto"###"Descricao"###"Quantidade"
	VTaBrowse(0,0,VTMaxRow(),VtmaxCol(),aCab,aHist,aSize)
	vtRestore(,,,,aTela)
	VtClearBuffer()
EndIf

VTKeyBoard(chr(20)) //Limpa o get
Return .F.


Static Function MenuProdC(cProduto)
Local aDados :={}
Local nPos
Local aTela
Local nTot:=0
Local nTotEmp:=0
Local nPosPonto:=0
Local nPosAux  :=0
Local 	lACDV110C	:=	ExistBlock('ACDV110C')
Local lLocaliz 	:= GetMv("MV_LOCALIZ") == "S"
Local cCQ			:= GetMvNNR('MV_CQ','98')

aadd(aDados,{STR0028,"",""}) //"Dados Gerais"
SB2->(DbSetorder(1))
SB2->(DbSeek(xFilial("SB2")+cProduto))
While SB2->(! Eof() .and. SB2->B2_FILIAL+SB2->B2_COD == xFilial("SB2")+cProduto)
	aadd(aDados,{STR0029+SB2->B2_LOCAL,	PadL(Alltrim(Transform(SB2->B2_QATU,PesqPict("SB2","B2_QATU"))),14),PadL(Alltrim(Transform(SB2->B2_QEMP,PesqPict("SB2","B2_QEMP"))),14),SB2->B2_QACLASS}) //"Armazem "
	If SB2->B2_LOCAL == cCQ
		aDados[Len(aDados),1] :=aDados[Len(aDados),1]+STR0042 //" (C.Q.)"
	EndIf
	nTot += SB2->B2_QATU
	nTotEmp += SB2->B2_QEMP
	SB2->(DbSkip())
EndDo
If lACDV110C
	nPosAux   := Len(aDados)
	aDados    := aClone(ExecBlock('ACDV110C',,,{1,aDados}))
	nPosPonto := Len(aDados)
EndIf
aadd(aDados,{Replicate("-",18),Replicate("-",15),Replicate("-",15)})
aadd(aDados,{STR0030,PadL(Alltrim(Transform(nTot,PesqPict("SB2","B2_QATU"))),14),PadL(Alltrim(Transform(nTotEmp,PesqPict("SB2","B2_QEMP"))),14)}) //"Total"

aTela := VTSave()
While .T.
	VTClear()
	nPos:=VTaBrowse(0,0,VTMaxRow(),VtmaxCol(),{STR0003,STR0004,STR0033},aDados,{18,15,15}) //"Descricao"###"Quantidade" //"Empenho"
	VtClearBuffer()
	VTKeyBoard(chr(20)) //Limpa o get
	If nPos == 0
		Exit
	ElseIf nPos == 1
		DadosGerais()
	ElseIf lACDV110C .And. nPosPonto == nPos .And. nPosPonto # nPosAux
		ExecBlock('ACDV110C',,,{2,cProduto})
	ElseIf (nPos < (Len(aDados)-1))
		If lLocaliz
			MostraEnd(Substr(aDados[nPos,1],9,Tamsx3("B1_LOCPAD")[1]),aDados[nPos,4],cProduto)
		EndIf
	EndIf
Enddo
vtRestore(,,,,aTela)
Return .f.

Static Function DadosGerais()
Local nPos := 0
Local aTela
Local aHistAux

If Len(aHist) > 0
	If	ExistBlock("ACDV110D")
		aHistAux := aClone(aHist)
		aHist    := ExecBlock('ACDV110D',.F.,.F.,{aHist})
		If ValType(aHist) <> 'A' .OR. Len(aHist) == 0
			aHist := aClone(aHistAux)
		Endif
	Endif
	aTela := VTSave()
	VTClear()
	nPos := VTaBrowse(0,0,VTMaxRow(),VtmaxCol(),{STR0003,STR0031},aHist,{15,15}) //"Descricao"###"Conteudo "
	vtRestore(,,,,aTela)
	VtClearBuffer()
EndIf
VTKeyBoard(chr(20)) //Limpa o get
Return .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMostraEnd บ Autor ณ     TOTVS	         บ Data ณ  01/01/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra Endereco								              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ACD                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function MostraEnd(cArmazem,nQtdeDistr,cProd)
Local cEndereco
Local cLoteCtl
Local cNumLote
Local nPos 
Local nTot     := 0
Local nQtd	   := 0
Local nEmpenho := 0
Local aDados   := {}
Local aDadosAux:= {}
Local aTitulo  := {}
Local aTela    := {}
Local lCtrWms  := IntWMS(cProd) .And. SuperGetMv("MV_WMSNEW",.F.,.F.) // Se for WMS Antigo deve continuar considerando a SBF

If !lCtrWms
	SBF->(DbSetorder(2))
	SBF->(DbSeek(xFilial("SBF")+cProd+cArmazem))
	aadd(aDados,{STR0032,PadL(Alltrim(Transform(nQtdeDistr,PesqPict("SB2","B2_QACLASS"))),14),"","",""}) //"A enderecar"
	nTot += nQtdeDistr
	While SBF->(! Eof() .and. SBF->BF_FILIAL+SBF->BF_PRODUTO+SBF->BF_LOCAL == xFilial("SBF")+cProd+cArmazem)
		nQtd:=0
		nEmpenho:=0
		cEndereco:= SBF->BF_LOCALIZ
		cLoteCtl := SBF->BF_LOTECTL
		cNumLote := SBF->BF_NUMLOTE	
		While SBF->(! Eof() .and. BF_FILIAL+BF_PRODUTO+BF_LOCAL == xFilial("SBF")+cProd+cArmazem) .and. cEndereco+cLoteCtl+cNumLote == SBF->BF_LOCALIZ+SBF->BF_LOTECTL+SBF->BF_NUMLOTE
			nQtd    := nQtd+SBF->BF_QUANT
			nEmpenho:= nEmpenho+SBF->BF_EMPENHO
			SBF->(DbSkip())
		Enddo
		aadd(aDados,{cEndereco,PadL(Alltrim(Transform(nQtd,PesqPict('SBF','BF_QUANT'))),14),cLoteCtl,cNumLote,PadL(Alltrim(Transform(nEmpenho,PesqPict('SBF','BF_EMPENHO'))),14)})
		nTot += nQtd
	EndDo
Else
	D14->(dbSetOrder(2))
	D14->(dbSeek(xFilial("D14")+cArmazem+cProd))
	aadd(aDados,{STR0032,PadL(Alltrim(Transform(nQtdeDistr,PesqPict("SB2","B2_QACLASS"))),14),"","",""}) //"A enderecar"
	nTot += nQtdeDistr
	While D14->(!Eof()) .And. xFilial("D14")+cArmazem+cProd == D14->(D14_FILIAL+D14_LOCAL+D14_PRODUT)
		nQtd := 0
		nEmpenho := 0
		cEndereco:= D14->D14_ENDER
		cLoteCtl := D14->D14_LOTECT
		cNumLote := D14->D14_NUMLOT	
		While D14->(!Eof()) .And. xFilial("D14")+cArmazem+cProd == D14->(D14_FILIAL+D14_LOCAL+D14_PRODUT) .And. cEndereco+cLoteCtl+cNumLote == D14->(D14_ENDER+D14_LOTECT+D14_NUMLOT)
			nQtd    += D14->D14_QTDEST
			nEmpenho+= D14->D14_QTDEMP
			D14->(DbSkip())
		Enddo
		aadd(aDados,{cEndereco,PadL(Alltrim(Transform(nQtd,PesqPict('SBF','BF_QUANT'))),14),cLoteCtl,cNumLote,PadL(Alltrim(Transform(nEmpenho,PesqPict('SBF','BF_EMPENHO'))),14)})
		nTot += nQtd
	EndDo
EndIf
aTitulo:={STR0003,STR0004,STR0025,STR0026,STR0033} //"Descricao"###"Quantidade"###"Lote"###"SubLote" //"Empenho"

aadd(aDados,{Replicate("-",15),Replicate("-",15),Replicate("-",15),Replicate("-",15),Replicate("-",15)})
aadd(aDados,{STR0030,PadL(Alltrim(Transform(nTot,PesqPict('SBF','BF_QUANT'))),14),"","",""}) //"Total"

If ExistBlock("CDV110END")	
	aDadosAux := ExecBlock("CDV110END",.F.,.F.,{aDados})
	If ValType(aDadosAux) == 'A'
		aDados := aClone(aDadosAux)
	Endif
EndIf    

aTela := VTSave()
VTClear()
nPos:=VTaBrowse(0,0,VTMaxRow(),VtmaxCol(),aTitulo,aDados,{15,15,15,15,15})
vtRestore(,,,,aTela)
VtClearBuffer()
Return .F.
