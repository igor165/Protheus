#INCLUDE "Acdv220.ch" 
#include "protheus.ch"
#include "apvt100.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ACDV220    ³ Autor ³ Anderson Rodrigues  ³ Data ³ 12/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preparacao do Endereçamento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAACD            	    								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
Template function ACDV220(uPar1,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)
Return ACDV220(uPar1,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)

Function ACDV220()
Local   cEtiqueta
Private aEtiqueta
Private cCodOpe  :=CBRetOpe()
Private nRecnoCB0
Private nX:=0
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
If Empty(cCodOpe)
	VTAlert(STR0001,STR0002,.T.,4000) //"Operador nao cadastrado"###"Aviso"
	Return .F.
EndIf

While .t.
	cEtiqueta := Space(20)
	VtClear
	If lVT100B // GetMv("MV_RF4X20")
		@ 0,0 VTSay STR0010 //'Preparacao do '
		@ 1,0 VTSay STR0011 //'Enderecamento '
		@ 2,0 VTSay STR0012 //'Leitura da Etiqueta'
		@ 3,0 VTGet cEtiqueta Pict "@!" Valid VldEti(cEtiqueta)
	Else
		@ 0,0 VTSay STR0010 //'Preparacao do '
		@ 1,0 VTSay STR0011 //'Enderecamento '
		@ 3,0 VTSay STR0012 //'Leitura da Etiqueta'
		@ 4,0 VTGet cEtiqueta Pict "@!" Valid VldEti(cEtiqueta)
	Endif
	VTRead
	If VtLastKey() == 27
		Return
	Endif
	MostraEndereco()
Enddo
Return .t.


Static Function VldEti(cEtiqueta)

If Empty(cEtiqueta)
	Return .f.
EndIf

aEtiqueta := CBRetEti(cEtiqueta,"01")
nRecnoCB0 := CB0->(Recno())
If Empty(aEtiqueta)
	VTBEEP(2)
	VTALERT(STR0003,STR0002,.T.,3000) //"Etiqueta invalida."###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf

If !Empty(aEtiqueta[9]) .And. !(aEtiqueta[10]+Alltrim(aEtiqueta[9])+";" $ GetMV("MV_CBENDCQ"))
	VTBEEP(2)
	VTALERT(STR0004,STR0002,.T.,3000) //"Produto ja foi enderecado."###"AVISO"
	VTKeyBoard(chr(20))
	Return .f.
EndIf

If Empty(aEtiqueta[4]+aEtiqueta[5]+aEtiqueta[6]+aEtiqueta[7])
	VTBEEP(2)
	VTALERT(STR0005,STR0002,.T.,3000) //"Produto nao conferido"###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf

If Empty(CB0->CB0_PEDCOM)
	VTBEEP(2)
	VTALERT(STR0006,STR0002,.T.,3000) //"Nao existe identificao de pedido nesta etiqueta"###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf
If !Empty(CB0->CB0_ENDSUG)
	VTBEEP(2)
	VTALERT(STR0007,STR0002,.T.,3000) //"Etiqueta ja preparada para enderecamento"###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf

SC7->(DbSetOrder(1))
If ! SC7->(DbSeek(xFilial()+CB0->CB0_PEDCOM))
	VTBEEP(2)
	VTALERT(STR0008,STR0002,.T.,4000) //"Pedido nao encontrado"###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf
Return

Static Function MostraEndereco()
Local   aTela
Local   aCab   := {}
Local   aSize  := {}
Local   lImp   := .t.
Private lRetSD7:= .t.
Private aItens := {}
Private nQtdeInfo:= 0
VTClear()
aCab  := {STR0009,STR0013} //"Endereco" //"Quantidade"
aSize := {15,15}
aItens:= CBProdxEnd(aEtiqueta[1],aEtiqueta[10],aEtiqueta[12])
If !lRetSD7
	VTBEEP(2)
	VTALERT(STR0014,STR0002,.T.,3000) //"Etiqueta inconsistente"###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
Endif
If Empty(aItens)
	VTBEEP(2)
	VTALERT(STR0015,STR0002,.T.,3000) //"Produto x Endereco nao cadastrado"###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
Endif
aTela := VTSAVE()
While .t.
	@ 0,0  VtSay STR0016+CB0->CB0_CODPRO //"Produto: "
	@ 1,0  VtSay STR0017+Str(CB0->CB0_QTDE,6,2) //"Quantidade: "
	VTaBrowse(2,0,7,20,aCab,aItens,aSize,'ACDV220A')
	VtRestore(,,,,aTela)
	If VtLastkey() == 27
		If Empty(nQtdeInfo)
			If VTYesNo(STR0018,STR0002,.t.) //"Registra a etiqueta atual como preparada"###"Aviso"
				Reclock("CB0",.f.)
				If aEtiqueta[10] == AlmoxCQ()
					SD7->(DbSetOrder(3))
					If SD7->(Dbseek(xFilial()+aEtiqueta[1]+aEtiqueta[12]))
						CB0->CB0_ENDSUG:= SD7->D7_LOCDEST+aitens[nX,1]
					Endif
				Else
					CB0->CB0_ENDSUG:= aEtiqueta[10]+aitens[nX,1]
				Endif
				MSUnlock()
				lImp:= .f.
				exit
			EndIf
		EndIf
		If CB0->CB0_QTDE <> nQtdeInfo
			VTBeep(2)
			VTAlert(STR0019,STR0020,.t.,2000) //'Quantidades divergentes'###'Aviso'
			If VTYesNo(STR0021,STR0022,.t.) //"Continua a digitacao"###"Atencao"
				Loop
			Else
				lImp:= .f.
				exit
			EndIf
		Endif
		If lImp .and. VTYesNo(STR0023,STR0024,.t.) //'Imprime as etiquetas preparadas para enderecamento'###'Atencao'
			ImpEti()
			Exit
		EndIf
	EndIf
	Exit
EndDo
Return

Function ACDV220A(modo,nElem,nElemW)
Local aTela
Local nQtde := 0
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If modo == 1
Elseif Modo == 2
Else
	If VTLastkey() == 27
		return 0
	elseIf VTLastkey() == 13
		VtClearBuffer()
		aTela := VTSave()
		VtClear
		If lVT100B // GetMv("MV_RF4X20")
			@ 0,0 VTSay STR0009 + ":" + aItens[nElem,1]//"Endereco"
			@ 1,0 VTSay STR0025 + ": " + cValToChar(CB0->CB0_QTDE-(nQtdeInfo-Val(aItens[nElem,2]))) //"Qtd Disponivel"
			@ 2,0 VTSay STR0026 //"Qtd a Enderecar"
			@ 3,0 VtGet nQtde Pict "@e 999,999,999.99" Valid  nQtde <= (CB0->CB0_QTDE-(nQtdeInfo-Val(aItens[nElem,2])))
		Else
			@ 0,0 VTSay STR0009 //"Endereco"
			@ 1,0 VTSay aItens[nElem,1]
			@ 2,0 VTSay STR0025 //"Qtd Disponivel"
			@ 3,0 VTSay CB0->CB0_QTDE-(nQtdeInfo-Val(aItens[nElem,2]))
			@ 4,0 VTSay STR0026 //"Qtd a Enderecar"
			@ 5,0 VtGet nQtde Pict "@e 999,999,999.99" Valid  nQtde <= (CB0->CB0_QTDE-(nQtdeInfo-Val(aItens[nElem,2])))
		Endif
		VtRead
		If VtLastKey() # 27
			nQtdeInfo -= Val(aItens[nElem,2])
			nQtdeInfo += nQtde
			aItens[nElem,2] := Str(nQtde,6,2)
		EndIf
		VTRestore(,,,,aTela)
	EndIf
	VTaBrwRefresh()
	return 2
EndIf
Return 2

Static Function ImpEti()
Local nX:=0
Local nRecno                                  
Local aNewFields :={}

IF ! CB5SetImp(CBRLocImp("MV_IACD02"),IsTelNet())
	VTBeep(3)
	VTAlert(STR0027,STR0020,.t.,3000) //'Local de impressao nao configurado, MV_IACD02'###'Aviso'
	Return
EndIf
VTMsg(STR0028) //"Imprimindo..."
For nX := 1 to len(aitens)
	If Empty(Val(aitens[nX,2]))
		Loop
	Endif
	CB0->(DbGoto(nRecnoCB0))
	
	aNewFields :={	{"CB0_CODETI"	,CBProxCod("MV_CODCB0")	},;
					{"CB0_QTDE"		,Val(aitens[nX,2])		}}

	
	nRecno:= CB0->(CBCopyRec(aClone(aNewFields)))
	CB0->(DbGoto(nRecno))
	Reclock("CB0",.f.)
	If aEtiqueta[10] == AlmoxCQ()
		SD7->(DbSetOrder(3))
		If SD7->(Dbseek(xFilial()+aEtiqueta[1]+aEtiqueta[12]))
			CB0->CB0_ENDSUG:= SD7->D7_LOCDEST+aitens[nX,1]
		Endif
	Else
		CB0->CB0_ENDSUG:= aEtiqueta[10]+aitens[nX,1]
	Endif
	MSUnlock()
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial()+CB0->CB0_CODPRO))
	If ExistBlock('IMG01')
		ExecBlock("IMG01",,,{,,CB0->CB0_CODETI})
	EndIf
Next
If ExistBlock('IMG00')
	ExecBlock("IMG00",,,{"ACDV220"})
EndIf
CB0->(DbGoto(nRecnoCB0))
Reclock("CB0",.f.)
Dbdelete()
MSUnlock()
MSCBCLOSEPRINTER()
Return
