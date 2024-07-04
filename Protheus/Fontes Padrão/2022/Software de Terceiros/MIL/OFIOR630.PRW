#Include "PROTHEUS.Ch"
#Include "OFIOR630.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR630 ³ Autor ³ Luis Delorme          ³ Data ³ 08/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relacao de Pecas por Tipo de Tempo (Almoxarifado)          ³±±
±±³          ³ ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR630()

Private titulo := STR0001 //"Pecas por TTpo"
Private cDesc1 := titulo
Private cDesc2 := ""
Private cDesc3 := ""
Private tamanho:= "M"
Private limite := 132
Private nCaracter := 15
private cString:= ""
Private cabec1 := ""
Private cabec2 := ""
Private aReturn := { STR0002, 1,STR0003, 1, 2, 1, "",1 }//Zebrado # Administracao
Private nomeprog:= "OFIOR630"
Private aLinha  := { },nLastKey := 0
Private cPerg   := "OFR630"

nomeprog := SetPrint(cString,nomeprog,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,.F.)
PERGUNTE(cPerg,.f.)
If nLastKey == 27
	Return
EndIf
titulo += " - "+Transform(MV_PAR01,"@D") + " a " + Transform(MV_PAR02,"@D")

SetDefault(aReturn,cString)
Processa ({ || FS_OFR630()})

If aReturn[5] == 1
	OurSpool( nomeprog )
EndIf

MS_Flush()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_OFR630 ³ Autor ³ Luis Delorme        ³ Data ³ 08/10/03 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OFR630()
Local aTotPec := {}
Local ni := 0
Local cSeek := ""
Local cTES  := ""
Local cAlm  := ""

nLin  := 0
m_pag := 1

If !Empty(MV_PAR06)
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+ MV_PAR06+ MV_PAR07)
EndIf
If !Empty(MV_PAR03)
	DbSelectArea("VOI")
	DbSetOrder(1)
	DbSeek(xFilial("VOI")+Alltrim(MV_PAR03))
	cAlm := VOI->VOI_CODALM
EndIf

DbSelectArea("SF2")
DbSetOrder(1)
DbGoTop()

DbselectArea("SF4")
DbSetOrder(1)
DbGoTop()

DbSelectArea("SB1")
DbSetOrder(1)
DbGoTop()

DbSelectArea("SB2")
DbSetOrder(1)
DbGoTop()

DbSelectArea("SD2")
DbSetOrder(5)
DbSeek(xFilial("SD2")+DTOS(MV_PAR01),.T.)
ProcRegua((RecCount()/100))
Do While !Eof() .and. xFilial("SD2") == SD2->D2_FILIAL .and. SD2->D2_EMISSAO <= MV_PAR02
	ni++
	If ni == 100
		ni := 0
		IncProc(STR0004) //Levantando Pecas por TTpo
	EndIf
	If !Empty(MV_PAR03) .and. ( SD2->D2_LOCAL # cAlm )
		DbSelectArea("SD2")
		DbSkip()
		Loop
	EndIf
	If !Empty(MV_PAR06) .and. ( MV_PAR06 + MV_PAR07 # SD2->D2_CLIENTE + SD2->D2_LOJA )
		DbSelectArea("SD2")
		DbSkip()
		Loop
	EndIf
	If cSeek # ( SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA ) 
		cSeek := ( SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA )
		DbSelectArea("SF2")
		DbSeek(xFilial("SF2") + cSeek )
	EndIf
	If SF2->F2_PREFORI # GetNewPar("MV_PREFOFI","OFI")
		DbSelectArea("SD2")
		DbSkip()
		Loop
	EndIf
	If cTES # SD2->D2_TES
		cTES := SD2->D2_TES
		DbSelectArea("SF4")
		DbSeek(xFilial("SF4") + cTES )
	EndIf
	If SF4->F4_ESTOQUE == "N" .or. !(SF4->F4_OPEMOV $ "04/05")
		DbSelectArea("SD2")
		DbSkip()
		Loop
	EndIf
	DbSelectArea("SB1")
	DbSeek(xFilial("SB1") + SD2->D2_COD )
	If !Empty(MV_PAR04) .AND. AllTrim(SB1->B1_GRUPO) # AllTrim(MV_PAR04)
		DbSelectArea("SD2")
		DbSkip()
		Loop
	EndIf
	numPec := 0
	If !Empty(MV_PAR08)
		DbSelectArea("VEC")
		DbSetOrder(4)
		If DbSeek(xFilial("VEC")+SF2->F2_DOC+SF2->F2_SERIE+SB1->B1_GRUPO+SB1->B1_CODITE)
			While !(VEC->(Eof())).and.xFilial("VEC")+SF2->F2_DOC+SF2->F2_SERIE+SB1->B1_GRUPO+SB1->B1_CODITE==VEC_FILIAL+VEC_NUMNFI+VEC_SERNFI+VEC_GRUITE+VEC_CODITE
				DbSelectArea("VO1")
				DbSetOrder(1)
				If DbSeek(xFilial("VO1")+VEC->VEC_NUMOSV)
					If VO1->VO1_CHASSI == MV_PAR08
						numPec += VEC->VEC_QTDITE
					EndIf
				EndIf
				DbSelectArea("VEC")
				DbSkip()
			EndDo
		EndIf
		If numPec == 0
			DbSelectArea("SD2")
			DbSkip()
			Loop
		EndIf     
	Else	
		numPec := SD2->D2_QUANT		
	EndIf
	DbSelectArea("SB2")
	DbSeek(xFilial("SB2") + SD2->D2_COD + SD2->D2_LOCAL)
	nPos := aScan(aTotPec,{|x| x[1] == SB1->B1_GRUPO .and. x[2] == SB1->B1_CODITE .and. x[4] == SD2->D2_LOCAL })
	If nPos == 0
		aADD(aTotPec,{SB1->B1_GRUPO,SB1->B1_CODITE,numPec,SD2->D2_LOCAL,SB2->B2_CM1,(SB2->B2_CM1*numPec)})
	Else
		aTotPec[npos,3] += numPec
		aTotPec[npos,6] := aTotPec[npos,3] * aTotPec[npos,5]
	EndIf
	DbSelectArea("SD2")
	DbSkip()
EndDo

li := 0
DbSelectArea("SB1")
DbSetOrder(7)

If  MV_PAR05 == 1
	aSort(aTotPec,1,,{|x,y| x[3] > y[3]})
Else
	aSort(aTotPec,1,,{|x,y| x[6] > y[6]})
EndIf

For ni := 1 to len(aTotPec)
	If ni == 1 .or. li > 60
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nCaracter)
		li:=li+2
		//              	 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
		//                    	    1         2         3         4         5         6         7         8         9        10        11        12        13
		//             	 gggg  xxxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 999,999,999.99 999,999,999.99 999,999,999.99   xx
		If !Empty(MV_PAR06)
			@li++, 1 psay STR0006+" " + Alltrim(MV_PAR06) + "-" + AllTrim(SA1->A1_NOME) //Cliente:
		EndIf
		If !Empty(MV_PAR08)
			@li++, 1 psay STR0005+" : " + Alltrim(MV_PAR08)  //Chassi
		EndIf               
		li++
		@li++, 1 psay STR0007		//"Grupo Codigo da Peca              Descricao                            Qtd.Mov.    Custo Unit.    Custo Total  Almox.  "
		@li++, 1 psay Replicate("=",120)
		li++
	EndIf
	DbSelectArea("SB1")
	DbSeek(xFilial("SB1") + aTotPec[ni,1] + aTotPec[ni,2] )
	@li++,1 psay aTotPec[ni,1] +"  "+ aTotPec[ni,2] +" "+ Left(SB1->B1_DESC,30) +" "+ Transform(aTotPec[ni,3],"@E 999,999,999.99") +" "+ Transform(aTotPec[ni,5],"@E 999,999,999.99") +" "+ Transform(aTotPec[ni,6],"@E 999,999,999.99") +"    "+ aTotPec[ni,4]
next

Eject
Set Printer to
Set Device  to Screen

Return
