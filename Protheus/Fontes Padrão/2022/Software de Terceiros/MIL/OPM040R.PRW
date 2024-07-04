/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OPM040R  º Autor ³ Andre Luis Almeida º Data ³  14/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao dos Itens a serem contados.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Concessionarias -> Contagem de Estoque ( OFIPM040 )        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function OPM040R()     
Local ni   := 0
Local niF  := 0
Local niI  := 0
Local cAlm := "INICIAL"
Local cNroRelI := PARAMIXB[1]
Local cNroRelF := PARAMIXB[2]
Local cImprSeq := ""
Local cImprimir:= ""
Local nImprimir:= 0
Local lAgrupou := .f.
Private cDesc1 := "INVENTARIO"
Private cDesc2 := ""
Private cDesc3 := ""
Private tamanho:= "P"
Private limite := 80
Private cString:= "VPF"
Private titulo := "INVENTARIO"+" ( "+VPE->VPE_CODIGO+" )"
Private cabec1 := ""
Private cabec2 := "Locacao         Item                                                    Qtde. Sq"
Private aReturn := {"Zebrado",1,"Administracao",1,2,1,"",1}
Private nomeprog:= "OFIPM040_"+right(cFase,1)
Private aLinha  := { },nLastKey := 0
Private cPerg   := nil
nomeprog := SetPrint(cString,nomeprog,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cString)
nLin  := 0
m_pag := 1
Set Printer to &nomeprog
Set Printer On
Set Device  to Printer
DbSelectArea("VPE")
cabec1 := left(cTitulo+space(10)+Transform(VPE->VPE_DATINI,"@D")+space(46),56)
cAlm := "INICIAL"
niF := 0
niI := 0
cAgrAx := ""
DbSelectArea("VPF")
DbSetOrder(2)
DbSeek(xFilial("VPF")+cNroRelI+"01")
ProcRegua(RecCount()/800)
DbSelectArea("SB1")
DbSetOrder(7)
DbSeek(xFilial("SB1") + VPF->VPF_GRUITE + VPF->VPF_CODITE )
If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
	cImprimir :=  VPF->VPF_LOCAC+" "+left(SB1->B1_DESC,21)+" "+VPF->VPF_GRUITE+" "+VPF->VPF_CODITE
Else
	cImprimir :=  VPF->VPF_LOCAC+" "+left(SB1->B1_DESC,14)+" "+VPF->VPF_GRUITE+" "+VPF->VPF_CODITE
EndIf
cImprSeq  := right(VPF->VPF_NROREL,2)
nImprimir := IIf(VPE->VPE_QTDCON=="3",VPF->VPF_CONTA3,VPF->VPF_CONTA5) // Maximo 3 ou 5 contagens
cAgrAx := ""
DbSelectArea("VPF")
While !Eof() .and. xFilial("VPF") == VPF->VPF_FILIAL .and. (VPF->VPF_NROREL <= cNroRelF+"25")
	ni++
	If ni == 800
		ni := 0
		IncProc("Imprimindo Itens...")
	EndIf
	If VPF->VPF_OK == "0" .or. ( VPE->VPE_QTDCON == "3" .and. VPF->VPF_OK == "3" ) .or. ( VPE->VPE_QTDCON == "5" .and. VPF->VPF_OK == "5" )
		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek(xFilial("SB1") + VPF->VPF_GRUITE + VPF->VPF_CODITE )
		If cAgrup == "S"
			If cAgrAx <> VPF->VPF_ALMOX+VPF->VPF_LOCAC+VPF->VPF_CODITE
				If !lAgrupou
					If !Empty(cAgrAx)
						If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
							@ nLin++, 00 PSAY cImprimir+"_______ "+cImprSeq
						Else
							@ nLin++, 00 PSAY cImprimir+Transform(nImprimir,"@E 999,999,999.99")+" "+cImprSeq
						EndIf
						nLin++
					EndIf
				EndIf
				If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
					cImprimir :=  VPF->VPF_LOCAC+" "+left(SB1->B1_DESC,21)+" "+VPF->VPF_GRUITE+" "+VPF->VPF_CODITE
				Else
					cImprimir :=  VPF->VPF_LOCAC+" "+left(SB1->B1_DESC,14)+" "+VPF->VPF_GRUITE+" "+VPF->VPF_CODITE
				EndIf
				cImprSeq  := right(VPF->VPF_NROREL,2)
				nImprimir := IIf(VPE->VPE_QTDCON=="3",VPF->VPF_CONTA3,VPF->VPF_CONTA5) // Maximo 3 ou 5 contagens
				lAgrupou := .f.
			Else
				nImprimir := IIf(VPE->VPE_QTDCON=="3",VPF->VPF_CONTA3,VPF->VPF_CONTA5) // Maximo 3 ou 5 contagens
				If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
					@ nLin++, 00 PSAY left(cImprimir,38)+"****"+substr(cImprimir,43)+"_______ "+cImprSeq
				Else
					@ nLin++, 00 PSAY left(cImprimir,31)+"****"+substr(cImprimir,36)+Transform(nImprimir,"@E 999,999,999.99")+" "+cImprSeq
				EndIf
				nLin++
				lAgrupou  := .t.
			EndIf
			cAgrAx := VPF->VPF_ALMOX+VPF->VPF_LOCAC+VPF->VPF_CODITE
			If cAlm <> VPF->VPF_ALMOX+left(VPF->VPF_NROREL,6)
				If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
					If cAlm <> "INICIAL"
						@ nLin++, 00 PSAY "Contado por ________________________       Digitado por ________________________"
					EndIf
				EndIf
				cAlm := VPF->VPF_ALMOX+left(VPF->VPF_NROREL,6)
				m_pag := val(left(VPF->VPF_NROREL,6))
				cabec1 := left(cabec1,55)+" "+"Armazem: "+VPF->VPF_ALMOX+"  "+"Pag.:"+left(VPF->VPF_NROREL,6)
				nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
			EndIf
		Else
			If cAlm <> VPF->VPF_ALMOX+left(VPF->VPF_NROREL,6)
				If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
					If cAlm <> "INICIAL"
						@ nLin++, 00 PSAY "Contado por ________________________       Digitado por ________________________"
					EndIf
				EndIf
				cAlm := VPF->VPF_ALMOX+left(VPF->VPF_NROREL,6)
				m_pag := val(left(VPF->VPF_NROREL,6))
				cabec1 := left(cabec1,55)+" "+"Armazem: "+VPF->VPF_ALMOX+"  "+"Pag.:"+left(VPF->VPF_NROREL,6)
				nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
			EndIf
			If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
				@ nLin++, 00 PSAY VPF->VPF_LOCAC+" "+left(SB1->B1_DESC,21)+" "+VPF->VPF_GRUITE+" "+VPF->VPF_CODITE+"_______ "+right(VPF->VPF_NROREL,2)
			Else
				@ nLin++, 00 PSAY VPF->VPF_LOCAC+" "+left(SB1->B1_DESC,14)+" "+VPF->VPF_GRUITE+" "+VPF->VPF_CODITE+Transform(IIf(VPE->VPE_QTDCON=="3",VPF->VPF_CONTA3,VPF->VPF_CONTA5),"@E 999,999,999.99")+" "+right(VPF->VPF_NROREL,2)
			EndIf
			nLin++
		EndIf
	EndIf
	DbSelectArea("VPF")
	DbSkip()
EndDo
If cAgrup == "S"
	If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
		@ nLin++, 00 PSAY cImprimir+"_______ "+cImprSeq
	Else
		@ nLin++, 00 PSAY cImprimir+Transform(nImprimir,"@E 999,999,999.99")+" "+cImprSeq
	EndIf
	nLin++
EndIf
If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
	If cAlm <> "INICIAL"
		@ nLin++, 00 PSAY "Contado por ________________________       Digitado por ________________________"
	EndIf
EndIf
Set Printer to
Set Device to Screen
If aReturn[5] == 1
	OurSpool( nomeprog )
EndIf
MS_Flush()
Return