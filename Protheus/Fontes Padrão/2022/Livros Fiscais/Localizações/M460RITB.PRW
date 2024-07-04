#Include "Protheus.ch"
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M460RITB ³ Autor ³ Ivan Haponczuk        ³ Data ³ 13.04.11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo da Retencao ITBIS - Saida                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Republica Dominicana                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460RITB(clCalculo,nlItem,alInfo)

Local xlRet
Local nlI       := 0
Local nlPos     := 0
Local nlAliq    := 0
Local nlBase    := 0
Local clImp     := ""
Local clTes     := ""
Local alRefImp  := ""
Local clFil     := ""
Local clCliFor  := ""
Local llXFis    := .T.
Local lpRetIVA  := .T.
Local alImposto := {}
Local alArea    := GetArea()

llXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")

If cModulo$"FAT|LOJA|TMK|FRT"
	lpRetIVA := SA1->A1_AGENRET == "1"
	clCliFor := SA1->A1_TIPO
Else
	lpRetIVA := SubStr(GetMV("MV_AGENTE"),1,1) == "S"
	clCliFor := SA2->A2_TIPO
Endif

If !llXFis
	alImposto := ParamIxb[2]
	xlRet     := alImposto
	clImp      := xlRet[1]
Else
	xlRet := 0
	clImp  := aInfo[X_IMPOSTO]
EndIf

If lpRetIVA
	If !llXFis .or. clCalculo == "A"
		dbSelectArea("SFB")
		SFB->(dbSetOrder(1))
		If SFB->(dbSeek(xFilial("SFB")+clImp))
			nlAliq := SFB->FB_ALIQ
		Endif
		
		dbSelectArea("CCR")
		CCR->(dbSetOrder(2))
		If CCR->(dbSeek(xFilial("CCR")+clImp+clCliFor))
			nlAliq := CCR->CCR_ALIQ
		EndIf
	EndIf
	
	If llXFis
		Do Case
			Case clCalculo == "A"
				xlRet := nlAliq
			Case clCalculo == "B"
				dbSelectArea("SFC")
				SFC->(dbSetOrder(2))
				clTes    := MaFisRet(nlItem,"IT_TES")
				alRefImp := MaFisRelImp("MT100",{"SD2"})
				clFil    := xFilial("SFC")
				SFC->(dbSeek(clFil+clTes+"IT"))
				While SFC->FC_FILIAL == clFil .and. SFC->FC_TES == clTes .and. SubStr(SFC->FC_IMPOSTO,1,2) == "IT"
					If SFC->FC_IMPOSTO <> alInfo[X_IMPOSTO]
						If SFB->(dbSeek(xFilial("SFB")+SFC->FC_IMPOSTO))
							nlPos := aScan(alRefImp,{|x| x[2] == "D2_VALIMP"+SFB->FB_CPOLVRO})
							If nlPos > 0
								nlBase += MaFisRet(nlItem,alRefImp[nlPos,3])
							EndIf
						EndIf
					EndIf
					SFC->(dbSkip())
				EndDo
				xlRet := nlBase
			Case clCalculo == "V"
				nlAliq := MaFisRet(nlItem,"IT_ALIQIV" + alInfo[X_NUMIMP])
				nlBase := MaFisRet(nlItem,"IT_BASEIV" + alInfo[X_NUMIMP])
				xlRet  := Round(nlBase*(nlAliq/100),2)
		EndCase
	Else
		For nlI:=1 to Len(aImpVarSD2[6])
			If SubStr(aImpVarSD2[6][nlI][1],1,2) == "IT"
				nlBase += aImpVarSD2[6][nlI][4]
			EndIf
		Next nlI
		alImposto[_ALIQUOTA] := nlAliq
		alImposto[_BASECALC] := nlBase
		nValImp:=Round(alImposto[_BASECALC]*alImposto[_ALIQUOTA]/100,2)
		alImposto[4] := nValImp
		xlRet := alImposto
	EndIf
EndIf

RestArea(alArea)
Return xlRet