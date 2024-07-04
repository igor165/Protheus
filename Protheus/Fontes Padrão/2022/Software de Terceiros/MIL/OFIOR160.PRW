#INCLUDE "ofior160.ch"
#include "protheus.ch"    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR160 ³ Autor ³ Thiago                ³ Data ³ 24/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Demonstrativo de Atendimento Interno                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR160
Local oReport
Local aArea := GetArea()
Private cImp := ""
If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	FS_OFR160R3()
EndIf
RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio usando o TReport                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oCell
oReport := TReport():New("OFIOR160",STR0001,"OFR160",{|oReport| OFR160IMP(oReport)})

oSection1 := TRSection():New(oReport,OemToAnsi(STR0021),{})						//Secao 1 - Atendimento Interno
TRCell():New(oSection1,"",,"","@!",132,,{|| cImp })

oSection2 := TRSection():New(oReport,OemToAnsi(STR0022),{"VO1","VV1"})			//Secao 2  - Ordem de Servico
TRCell():New(oSection2,"",,"","@!",2,,{|| space(2) })
TRCell():New(oSection2,"VO1_NUMOSV","VO1")
TRCell():New(oSection2,"VO1_DATABE","VO1",,"@D",8)
TRCell():New(oSection2,"VO1_HORABE","VO1",,"@R 99:99",5)
TRCell():New(oSection2,"VV1_CODMAR","VV1")
TRCell():New(oSection2,"VV1_MODVEI","VV1") 
TRCell():New(oSection2,"VV1_FABMOD","VV1",,"@R 9999/9999",9)
TRCell():New(oSection2,"VV1_CHAINT","VV1") 
TRCell():New(oSection2,"VV1_CHASSI","VV1") 
TRCell():New(oSection2,"VV1_PLAVEI","VV1") 
TRCell():New(oSection2,"VV1_CODFRO","VV1") 

oSection3 := TRSection():New(oReport,OemToAnsi(STR0023),{})						//Secao 3   - Separacao
TRCell():New(oSection3,"",,"","@!",132,,{|| " "+Repl("-",130) })

oSection4 := TRSection():New(oReport,OemToAnsi(STR0024),{"VOO","SA1","VO1","VO3"}) //Secao 4 - Tipo de Tempo
TRCell():New(oSection4,"",,"","@!",3,,{|| space(3) })
TRCell():New(oSection4,"VOO_TIPTEM","VOO")
TRCell():New(oSection4,"VOO_FATPAR","VOO")
TRCell():New(oSection4,"VOO_LOJA"  ,"VOO")
TRCell():New(oSection4,"A1_NOME"   ,"SA1",,,18)
TRCell():New(oSection4,"VO3_FUNFEC","VO3")
TRCell():New(oSection4,"VO1_STATUS","VO1")
TRCell():New(oSection4,"",,"","@!",108,,{|| cImp })

TRPosition():New(oSection4,"SA1",1,{|| xFilial()+VOO->VOO_FATPAR+VOO->VOO_LOJA })

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFR160IMP³ Autor ³ Andre Luis Almeida    ³ Data ³ 14/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao do relatorio do TReport                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFR160IMP(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local oSection3 := oReport:Section(3)
Local oSection4 := oReport:Section(4)
Local lImpOsv := .f.
Local aCodSer := {}
Local aDepart := {}
Local nPosDep :=0
Local cSrvN1  := "SIM"
Local cSrvN2  := "SIM"
Local dDataLib:= Ctod("  /  /  ")
Local dDataFec:= Ctod("  /  /  ")
Local dDataCan:= Ctod("  /  /  ")
Local aResTPT := {} //Tipos de Tempo
Local aResTPS := {} //Tipos de Servicos
Local aPecVO3 := {}
Local aSerVO4 := {}
Local aPecVEC := {}
Local aSerVSC := {}
Local nValser := nTotSer := nTotPec := nTotPec1:= 0
Local i := 0 
Local y := 0
Local nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := 0
Local nTot3a := nTot4a := nTot5a := nTot6a := nTot7a := nTot8a := 0
PERGUNTE("OFR160",.F.)
DbSelectArea( "VO1" )
DbSetOrder(5)
DbSeek( xFilial("VO1") + Dtos(MV_PAR01) , .t. )
oReport:SetMeter(RecCount())
oSection1:Init()
oSection2:Init()
oSection3:Init()
oSection4:Init()
cImp := "."+STR0005
oSection1:PrintLine()
oSection3:PrintLine()
Do While !Eof() .and. !oReport:Cancel() .and. xfilial("VO1") == VO1->VO1_FILIAL .and. VO1->VO1_DATABE >= MV_PAR01 .and. VO1->VO1_DATABE <= MV_PAR02
	oReport:IncMeter()
	If !Empty(MV_PAR04)
		If ( VO1->VO1_PROVEI + VO1->VO1_LOJPRO ) # ( MV_PAR04 + MV_PAR05 )
			DbSelectArea("VO1")
			DbSkip()
			Loop
		EndIf
	EndIf
	DbSelectArea("VOO")
	DbSetOrder(1)
	If !DbSeek(xfilial("VOO")+VO1->VO1_NUMOSV)
		DbSelectArea("VO1")
		DbSkip()
		Loop
	EndIf
	DbSelectArea("VV1") //Veiculo
	DbSetOrder(1)
	Dbseek(xfilial("VV1")+VO1->VO1_CHAINT)
	If !Empty(MV_PAR06)
		If VV1->VV1_CODMAR # MV_PAR06
			DbSelectArea("VO1")
			DbSkip()
			Loop
		EndIf
	EndIf
	If !Empty(MV_PAR07)
		If VV1->VV1_MODVEI # MV_PAR07
			DbSelectArea("VO1")
			DbSkip()
			Loop
		EndIf
	EndIf
	aPecVO3 := {}
	aSerVO4 := {}
	aPecVEC := {}
	aSerVSC := {}
	dDataLib:= Ctod("  /  /  ")
	dDataFec:= Ctod("  /  /  ")
	dDataCan:= Ctod("  /  /  ")
	lImpOsv := .f.
	nTotPec := nTotPec1:= nTpoPad := nTpoTra := ntpoCob := ntpoven := nTotSer := 0
	DbSelectArea("VEC")
	DbSetOrder(5)
	DbSeek(xfilial("VEC")+VO1->VO1_NUMOSV)
	nTotPec := 0
	Do While !Eof() .and. xfilial("VEC") == VEC->VEC_FILIAL .and. VEC->VEC_NUMOSV == VO1->VO1_NUMOSV
		DbSelectArea("VOI")
		DbSetOrder(1)
		DbSeek(xFilial("VOI")+VEC->VEC_TIPTEM)
		If VOI->VOI_SITTPO # "3"
			DbSelectArea("VEC")
			DbSkip()
			Loop
		EndIf
		lImpOsv := .t.
	   nPosDep:=0   && Departamento interno
		DbSelectArea("VO2")
		DbSetOrder(1)
		DbSeek(xFilial("VO2")+VEC->VEC_NUMOSV+"P")
		Do While !Eof() .and. xFilial("VO2") == VO2->VO2_FILIAL .and. ( VO2->VO2_NUMOSV + VO2->VO2_TIPREQ == VEC->VEC_NUMOSV + "P" )
			DbSelectArea("VO3")
			DbSetOrder(1)
			If DbSeek(xFilial("VO3")+VO2->VO2_NOSNUM+VEC->VEC_TIPTEM)
				dDataLib := VO3->VO3_DATDIS
				dDataFec := VO3->VO3_DATFEC
				dDataCan := VO3->VO3_DATCAN
				If !Empty(VO3->VO3_DEPINT)
					If Len(aDepart)#0 
					   nPosDep := Ascan(aDepart, {|x| x[1]== VO3->VO3_DEPINT} )
					EndIf                               
					If nPosDep == 0
					   Aadd(aDepart,{ VO3->VO3_DEPINT , 0 } )
					   nPosDep:=Len(aDepart)
					EndIf
				EndIf	
				Exit
			EndIf	
			DbSelectArea("VO2")
			DbSkip()
		EndDo
		DbSelectArea("SB1")
		DbSetOrder(7)
		Dbseek(xfilial("SB1")+VEC->VEC_GRUITE+VEC->VEC_CODITE)
		aadd(aPecVEC,{space(4)+VEC->VEC_NUMOSV+" "+VEC->VEC_GRUITE+" "+VEC->VEC_CODITE+" "+SB1->B1_DESC+" "+;
		Transform(VEC->VEC_QTDITE, "@E 99999")+" "+VO3->VO3_PROREQ+" "+VO3->VO3_FORMUL+" "+;
		Transform(VEC->VEC_VALBRU, "@R 999,999,999.99")+" "+Transform((VEC->VEC_VALBRU*VEC->VEC_QTDITE),"@E 999,999,999.99")})
		nTotPec  := VEC->VEC_VALBRU*VEC->VEC_QTDITE
		nTotPec1 += nTotPec
		If nPosDep#0
		   aDepart[nPosDep,2] += nTotPec
		EndIf
		nPos := Ascan(aResTPT,{|x| x[1] == VEC->VEC_TIPTEM})
		If nPos > 0
			aResTPT[nPos,3] := aResTPT[nPos,3]+ nTotPec
		Else
			DbSelectArea("VOI")
			DbSetOrder(1)
			Dbseek(xfilial("VOI")+VEC->VEC_TIPTEM)
			aadd(aResTPT,{VEC->VEC_TIPTEM,VOI->VOI_DESTTE,nTotPec,0,0,0,0,0})
		EndIf
		DbSelectArea("VEC")
		DbSkip()
	Enddo
	DbSelectArea("VSC")
	DbSetOrder(1)
	Dbseek(xfilial("VSC")+VO1->VO1_NUMOSV)
	nTpoPad := 0
	nTpoTra := 0
	nTpoCob := 0
	nTpoVen := 0
	Do While !Eof() .and. xfilial("VSC") == VSC->VSC_FILIAL .and. VSC->VSC_NUMOSV == VO1->VO1_NUMOSV
		DbSelectArea("VOI")
		DbSetOrder(1)
		DbSeek(xFilial("VOI")+VSC->VSC_TIPTEM)
		DbSelectArea("VOK")
		DbSetOrder(1)
		Dbseek(xfilial("VOK")+VSC->VSC_TIPSER)
		If VOI->VOI_SITTPO # "3" // .Or. !(VOK->VOK_TIPHOR $ "2/3")
			DbSelectArea("VSC")
			DbSkip()
			Loop
		EndIf
		lImpOsv := .t.
		DbSelectArea("VO6")
		DbSetOrder(2)
		Dbseek(xfilial("VO6")+ FG_MARSRV(VV1->VV1_CODMAR,VSC->VSC_CODSER) + VSC->VSC_CODSER )
		DbSelectArea("VAI")
		DbSetOrder(1)
		Dbseek(xfilial("VAI")+VSC->VSC_CODPRO)
		DbSelectArea( "VOK" )
		DbSetOrder(1)
		DbSeek( xFilial("VOK") + VSC->VSC_TIPSER )
		nPosDep:=0
		DbSelectArea("VO2")
		DbSetOrder(1)
		DbSeek(xFilial("VO2")+VSC->VSC_NUMOSV+"S")
		Do While !Eof() .and. xFilial("VO2") == VO2->VO2_FILIAL .and. ( VO2->VO2_NUMOSV + VO2->VO2_TIPREQ == VSC->VSC_NUMOSV + "S" )
			DbSelectArea("VO4")
			DbSetOrder(1)
			DbSeek(xFilial("VO4")+VO2->VO2_NOSNUM+VSC->VSC_TIPTEM+VSC->VSC_CODSER)
			Do While !Eof() .and. xFilial("VO4") == VO4->VO4_FILIAL .and. ( VO4->VO4_NOSNUM + VO4->VO4_TIPTEM + VO4->VO4_CODSER == VO2->VO2_NOSNUM + VSC->VSC_TIPTEM + VSC->VSC_CODSER )
				If VO4->VO4_TIPSER == VSC->VSC_TIPSER
					dDataLib := VO4->VO4_DATDIS
					dDataFec := VO4->VO4_DATFEC
					dDataCan := VO4->VO4_DATCAN
					aCodSer := FG_CALVLSER( aCodSer , VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER , NIL ,,,VO2->VO2_DATREQ)
					If !Empty(VO4->VO4_DEPINT)
						If Len(aDepart)#0 
						   nPosDep := Ascan(aDepart, {|x| x[1]== VO4->VO4_DEPINT} )
						EndIf                               
						If nPosDep == 0
						   Aadd(aDepart,{ VO4->VO4_DEPINT , 0 } )
						   nPosDep:=Len(aDepart)
						EndIf
					EndIf	
					Exit
				EndIf
				DbSelectArea("VO4")
				DbSkip()
			EndDo
			DbSelectArea("VO2")
			DbSkip()
		EndDo
		If Len(aCodSer) == 0
			DbSelectArea("VSC")
			DbSkip()
			Loop
		EndIf
		aadd(aSerVSC,{space(4)+VSC->VSC_TIPSER+" "+VSC->VSC_GRUSER+"    "+VSC->VSC_CODSER+" "+Substr(VO6->VO6_DESSER,1,30)+""+VSC->VSC_CODPRO+" "+;
		Substr(VAI->VAI_NOMTEC,1,22)+"  "+Transform(aCodSer[2],"@R 999:99")+" "+Transform(aCodSer[5],"@R 999:99")+" "+;
		Transform(aCodSer[3], "@R 999:99")+" "+Transform(aCodSer[4], "@R 999:99")+""+Transform(aCodSer[1], "@E 999,999.99")})
		nValSer  := aCodSer[1]
		nTpoTra  += aCodSer[5]
		nTpoCob  += aCodSer[3]
		nTotSer  += nValSer
		nTpoTra2 := aCodSer[5]
		nTpoCob2 := aCodSer[3]
		nTotSer2 := nValSer
		If  aCodSer[6]
			nTpoPad  += aCodSer[2]
			nTpoVen  += aCodSer[4]
			nTpoPad2 := aCodSer[2]
			nTpoVen2 := aCodSer[4]
		EndIf
		If nPosDep#0
		   aDepart[nPosDep,2] += nValSer
		EndIf
		nPos := Ascan(aResTPT,{|x| x[1] == VSC->VSC_TIPTEM })
		If nPos > 0
			If  aCodSer[6]
				aResTPT[nPos,4] += nTpoPad2
				aResTPT[nPos,7] += nTpoVen2
			EndIf
			aResTPT[nPos,5] += nTpoTra2
			aResTPT[nPos,6] += nTpoCob2
			aResTPT[nPos,8] += nTotSer2
		Else
			DbSelectArea("VOI")
			DbSetOrder(1)
			Dbseek(xfilial("VOI")+VSC->VSC_TIPTEM)
			aadd(aResTPT,{VSC->VSC_TIPTEM,VOI->VOI_DESTTE,nTotPec,nTpoPad2,nTpoTra2,nTpoCob2,nTpoVen2,nValSer})//nTotSer2})
		EndIf
		nPos := Ascan(aResTPS,{|x| x[1]+x[2] == VSC->VSC_TIPTEM+VSC->VSC_TIPSER })
		If nPos > 0
			If  aCodSer[6]
				aResTPS[nPos,5] += nTpoPad2
				aResTPS[nPos,8] += nTpoVen2
			EndIf
			aResTPS[nPos,6] += nTpoTra2
			aResTPS[nPos,7] += nTpoCob2
			aResTPS[nPos,9] += nTotSer2
		Else
			aadd(aResTPS,{VSC->VSC_TIPTEM,VSC->VSC_TIPSER,VOK->VOK_DESSER,0,nTpoPad2,nTpoTra2,nTpoCob2,nTpoVen2,nValSer}) //nTotSer2})
		EndIf
		DbSelectArea("VSC")
		DbSkip()
	EndDo
	If (MV_PAR03 == 2 .or. MV_PAR03 == 3) .and. lImpOsv
		oSection2:PrintLine()
		oReport:SkipLine()
		cImp := "."+STR0006
		oSection1:PrintLine()
		cImp := DTOC(dDataLib)+" "+DTOC(dDataFec)+" "+DTOC(dDataCan)+" "+VOO->VOO_NUMNFI+"-"+VOO->VOO_SERNFI+Transform(nTotPec1,"@E 9999,999.99")+" "+Transform(nTpoPad,"@R 999:99")+" "
		cImp += Transform(nTpoTra,"@E 999:99")+" "+Transform(nTpoCob,"@E 999:99")+" "+Transform(nTpoVen,"@R 999:99")+" "+Transform(nTotSer,"@E 999,999.99")
		oSection4:PrintLine()
		If MV_PAR03 == 3
			If VO1->VO1_STATUS $ "F"
				If Len(aPecVEC)>0
					oReport:SkipLine()
					cImp := "."+STR0007
					oSection1:PrintLine()
					For i:=1 to Len(aPecVEC)
						cImp := "."+space(3)+aPecVEC[i,1]
						oSection1:PrintLine()
					Next
				EndIf
				If Len(aSerVSC)>0
					oReport:SkipLine()
					cImp := "."+STR0008
					oSection1:PrintLine()
					For i:=1 to Len(aSerVSC)
						cImp := "."+space(3)+aSerVSC[i,1]
						oSection1:PrintLine()
					Next
				EndIf
			EndIf
		EndIf
		oSection3:PrintLine()
	EndIf
	DbSelectArea("VO1")
	Dbskip()
EndDo
oReport:SkipLine()
cImp := "."+STR0009
oSection1:PrintLine()
oReport:SkipLine()
cImp := "."+STR0010
oSection1:PrintLine()
oReport:SkipLine()
cImp := "."+STR0011
oSection1:PrintLine()
For i := 1 to Len(aResTPT)
	DbSelectArea("VOI")
	DbSeek(xFilial("VOI")+aResTPT[i,1])
	If VOI->VOI_SITTPO == "3"
		cImp := "."+aResTPT[i,1]+" "+left(aResTPT[i,2],17)+Transform(aResTPT[i,3],"@E 999999,999.99")+Transform(aResTPT[i,4],"@E 999:99")+Transform(aResTPT[i,5],"@E 999:99")
		cImp += Transform(aResTPT[i,6],"@E 999:99")+Transform(aResTPT[i,7], "@E 999:99")+Transform(aResTPT[i,8],"@E 999,999.99")
		oSection1:PrintLine()
		oReport:SkipLine()
		For y := 1 to Len(aResTPS)
			If aResTPS[y,1] == aResTPT[i,1]
				cImp := "."+space(2)+aResTPS[y,2]+" "+aResTPS[y,3]+Transform(aResTPS[y,5],"@E 999:99")+Transform(aResTPS[y,6],"@E 999:99")
				cImp += Transform(aResTPS[y,7],"@E 999:99")+Transform(aResTPS[y,8],"@E 999:99")+Transform(aResTPS[y,9],"@E 999,999.99")
				oSection1:PrintLine()
			EndIf
		Next
	EndIf
Next
nTot3 := nTot4 := nTot5 := nTot6 := nTot7 := nTot8 := 0
For i := 1 to Len(aResTPT)
	DbSelectArea("VOI")
	DbSetOrder(1)
	DbSeek(xFilial("VOI")+ aResTPT[i,1])
	If VOI->VOI_SITTPO == "3"
		nTot3 += aResTPT[i,3]
		nTot4 += aResTPT[i,4]
		nTot5 += aResTPT[i,5]
		nTot6 += aResTPT[i,6]
		nTot7 += aResTPT[i,7]
		nTot8 += aResTPT[i,8]
	EndIf
Next
oReport:SkipLine()
cImp := "."+STR0012+" "+Transform(nTot3,"@E 999999,999.99")+"  "+Transform(nTot4,"@E 999:99")+" "+Transform(nTot5,"@E 999:99")
cImp += "   "+Transform(nTot6,"@E 999:99")+"  "+Transform(nTot7,"@E 999:99")+" "+Transform(nTot8,"@E 999,999.99")
oSection1:PrintLine()
oReport:SkipLine()
cSrvN1 := "SIM"
For i := 1 to Len(aResTPT)
	DbSelectArea("VOI")
	DbSetOrder(1)
	DbSeek(xFilial("VOI")+aResTPT[i,1])
	If VOI->VOI_SITTPO # "3"
		cSrvN2 := "SIM"
		If cSrvN1 == "SIM" .and. cSrvN2 == "SIM"
			cSrvN1 := "NAO"
			cImp := "."+STR0013
			oSection1:PrintLine()
			oReport:SkipLine()
			cImp := "."+STR0011
			oSection1:PrintLine()
			oReport:SkipLine()
		EndIf
		cImp := "."+aResTPT[i,1]+" "+aResTPT[i,2]+Transform(aResTPT[i,4],"@E 999:99")+Transform(aResTPT[i,5],"@E 999:99")
		cImp += Transform(aResTPT[i,6],"@E 999:99")+Transform(aResTPT[i,7],"@E 999:99")+Transform(aResTPT[i,8],"@E 999,999.99")
		oSection1:PrintLine()
		oReport:SkipLine()
		For y := 1 to Len(aResTPS)
			If aResTPS[y,1] == aResTPT[i,1]
				cImp := "."+space(2)+aResTPS[y,2]+" "+aResTPS[y,3]+Transform(aResTPS[y,5],"@E 999:99")+Transform(aResTPS[y,6],"@E 999:99")
				cImp += Transform(aResTPS[y,7],"@E 999:99")+Transform(aResTPS[y,8],"@E 999:99")+Transform(aResTPS[y,9],"@E 999,999.99")
				oSection1:PrintLine()
			EndIf
		Next
	EndIf
Next
nTot3a := nTot4a := nTot5a := nTot6a := nTot7a := nTot8a := 0
For i := 1 to Len(aResTPT)
	DbSelectArea("VOI")
	DbSetOrder(1)
	DbSeek(xFilial("VOI")+ aResTPT[i,1])
	If VOI->VOI_SITTPO # "3"
		nTot3a += aResTPT[i,3]
		nTot4a += aResTPT[i,4]
		nTot5a += aResTPT[i,5]
		nTot6a += aResTPT[i,6]
		nTot7a += aResTPT[i,7]
		nTot8a += aResTPT[i,8]
	EndIf
Next
If ((nTot3a+nTot4a+nTot5a+nTot6a+nTot7a+nTot8a)>0)
	cImp := "."+STR0014+" "+Transform(nTot3a,"@E 999999,999.99")+"  "+Transform(nTot4a,"@E 999:99")+" "+Transform(nTot5a,"@E 999:99")
	cImp += "   "+Transform(nTot6a,"@E 999:99")+"  "+Transform(nTot7a,"@E 999:99")+" "+Transform(nTot8a,"@E 999,999.99")
	oSection1:PrintLine()
	oReport:SkipLine()
EndIf
oSection3:PrintLine()
cImp := "."+STR0015+Transform(nTot3+nTot3a,"@E 999999,999.99")+"  "+Transform(nTot4+nTot4a,"@E 999:99")+" "+Transform(nTot5+nTot5a,"@E 999:99")
cImp += "   "+Transform(nTot6+nTot6a,"@E 999:99")+"  "+Transform(nTot7+nTot7a,"@E 999:99")+" "+Transform(nTot8+nTot8a,"@E 999,999.99")
oSection1:PrintLine()
oSection3:PrintLine()
nTot3 := 0
oReport:SkipLine()
oReport:SkipLine()
oReport:SkipLine()
cImp := Repl("-",13)+ STR0016 + Repl("-",13)   //Resumido por Departamento
oSection1:PrintLine()
oReport:SkipLine()
cImp := STR0017 //Depto  Descricao                              Valor
oSection1:PrintLine()
cImp := Repl("-",51)
oSection1:PrintLine()
For i := 1 to Len(aDepart)
	DbSelectArea("SX5")
	DbSetOrder(1)
	DbSeek( xFilial("SX5")+ "VD" + aDepart[i,1] )
	cImp := "."+SX5->X5_CHAVE+" "+Substr(SX5->X5_DESCRI,1,29)+Transform(aDepart[i,2],"@E 999,999,999.99")
	oSection1:PrintLine()
	nTot3 += aDepart[i,2]
Next
cImp := Repl("-",51)
oSection1:PrintLine()
cImp := "."+space(29)+ STR0018 +" "+Transform(nTot3,"@E 999,999,999.99")	//Total:
oSection1:PrintLine()
cImp := Repl("-",51)
oSection1:PrintLine()
oSection1:Finish()
oSection2:Finish()
oSection3:Finish()
oSection4:Finish()
Return Nil


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function FS_OFR160R3()
Local cAlias := "VO1"
Local cDesc3 :=""
Private nLin := 1
Private aPag := 1
Private cDesc1 :=STR0001 //Demonstrativo de Atendimento Interno
Private cCabec1:=STR0001 //Demonstrativo de Atendimento Interno
Private cDesc2 :=""
Private cCabec2:=""
Private aReturn  := { STR0002, 1,STR0003, 2, 2, 1, "",1 } //Zebrado###Administracao
Private cTamanho := "M"           // P/M/G
Private Limite   := 132           // 80/132/220
Private cTitulo  := STR0004 //Atendimento interno
Private cNomProg := "OFIOR160"
Private cNomeRel := "OFIOR160"
Private nLastKey := 0
Private nCaracter:= 15
Private cPerg := "OFR160"
cNomeRel := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nlastkey == 27
	return
EndIf
PERGUNTE(cPerg,.f.)
SetDefault(aReturn,cAlias)
RptStatus({|lEnd| ImpOSInt(@lEnd,cNomeRel,cAlias)},cTitulo)
Return
/////////////////////////////////////////////////////////
Static Function ImpOSInt(lEnd,wNRel,cAlias)
Local lImpOsv := .f.
Local aCodSer := {} , aDepartamento:={} , nPosDep:=0
Local cSrvN1, cSrvN2
Local cabec
Local dDataLib:=Ctod("  /  /  ")
Local dDataFec:=Ctod("  /  /  ")
Local dDataCan:=Ctod("  /  /  ")
Local i		  := 0
set print to &cNomeRel
set print on
set device to print
Private M_PAG := 1
Private aResTPT := {}      //Tipos de Tempo
Private aResTPS := {}      //Tipos de Servicos
Private aPecVO3 := {}
Private aSerVO4 := {}
Private aPecVEC := {}
Private aSerVSC := {}
Private nValser := 0
Private nTotSer := 0
nLin := Cabec(cTitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter)+1
@ nLin, 001 pSay STR0005 //" Numer.OS  Dt/Hs Abertura   Marca/Modelo do Veiculo            Fabr/Mod. ChaInt Chassi do Veiculo          Placa        Frota"
nlin++
@ nlin, 001 pSay "-----------------------------------------------------------------------------------------------------------------------------------"
nlin++
DbSelectArea( "VO1" )
DbSetOrder(5)
DbSeek( xFilial("VO1") + Dtos(MV_PAR01) , .t. )
SetRegua( RecCount()-RecNo() )
Do While !Eof() .and. xfilial("VO1") == VO1->VO1_FILIAL .and. VO1->VO1_DATABE >= MV_PAR01 .and. VO1->VO1_DATABE <= MV_PAR02
	aPecVO3 := {}
	aSerVO4 := {}
	aPecVEC := {}
	aSerVSC := {}
	dDataLib:=Ctod("  /  /  ")
	dDataFec:=Ctod("  /  /  ")
	dDataCan:=Ctod("  /  /  ")
	lImpOsv := .f.
	nTotPec1 := 0
	DbSelectArea("VV1") //Veiculo
	DbSetOrder(1)
	Dbseek(xfilial("VV1")+VO1->VO1_CHAINT)
	DbSelectArea("SA1")  //Cliente
	DbSetOrder(1)
	Dbseek(xfilial("SA1")+VO1->VO1_PROVEI+VO1->VO1_LOJPRO)
	If !Empty(MV_PAR04)
		If VO1->VO1_PROVEI # MV_PAR04 .or. VO1->VO1_LOJA # MV_PAR05
			DbSelectArea("VO1")
			DbSkip()
			Loop
		EndIf
	EndIf
	If !Empty(MV_PAR06)
		If VE1->VE1_CODMAR # MV_PAR06
			DbSelectArea("VO1")
			DbSkip()
			Loop
		EndIf
	EndIf
	If !Empty(MV_PAR07)
		If VV2->VV2_MODVEI # MV_PAR07
			DbSelectArea("VO1")
			DbSkip()
			Loop
		EndIf
	EndIf
	DbSelectArea("VOO")
	DbSetOrder(1)
	If !DbSeek(xfilial("VOO")+VO1->VO1_NUMOSV)
		DbSelectArea("VO1")
		DbSkip()
		Loop
	EndIf
	nTpoPad := 0
	nTpoTra := 0
	ntpoCob := 0
	ntpoven := 0
	nTotSer := 0
	nTotPec := 0
	DbSelectArea("VEC")
	DbSetOrder(5)
	DbSeek(xfilial("VEC")+VO1->VO1_NUMOSV)
	nTotPec := 0
	Do While !Eof() .and. xfilial("VEC") == VEC->VEC_FILIAL .and.VEC->VEC_NUMOSV == VO1->VO1_NUMOSV
		DbSelectArea("VOI")
		DbSetOrder(1)
		DbSeek(xFilial("VOI")+VEC->VEC_TIPTEM)
		If VOI->VOI_SITTPO # "3"
			DbSelectArea("VEC")
			DbSkip()
			Loop
		EndIf
		lImpOsv := .t.
	   nPosDep:=0   && Departamento interno
		DbSelectArea("VO2")
		DbSetOrder(1)
		DbSeek(xFilial("VO2")+VEC->VEC_NUMOSV+"P")
		Do While !Eof() .And. VO2->VO2_FILIAL+VO2->VO2_NUMOSV+VO2->VO2_TIPREQ==xFilial("VO2")+VEC->VEC_NUMOSV+"P"
			DbSelectArea("VO3")
			DbSetOrder(1)
			If DbSeek(xFilial("VO3")+VO2->VO2_NOSNUM+VEC->VEC_TIPTEM)
				dDataLib := VO3->VO3_DATDIS
				dDataFec := VO3->VO3_DATFEC
				dDataCan := VO3->VO3_DATCAN
				If !Empty(VO3->VO3_DEPINT)
					If Len(aDepartamento)#0 
					   nPosDep := Ascan(aDepartamento, {|x| x[1]== VO3->VO3_DEPINT} )
					EndIf                               
					If nPosDep == 0
					   Aadd(aDepartamento,{ VO3->VO3_DEPINT , 0 } )
					   nPosDep:=Len(aDepartamento)
					EndIf
				EndIf	
				Exit
			EndIf	
			DbSelectArea("VO2")
			DbSkip()
		EndDo
		DbSelectArea("SB1")
		DbSetOrder(7)
		Dbseek(xfilial("SB1")+VEC->VEC_GRUITE+VEC->VEC_CODITE)
		aadd(aPecVEC,{space(4)+VEC->VEC_NUMOSV+" "+VEC->VEC_GRUITE+" "+VEC->VEC_CODITE+" "+SB1->B1_DESC+" "+;
		Transform(VEC->VEC_QTDITE, "@E 99999")+" "+VO3->VO3_PROREQ+" "+VO3->VO3_FORMUL+" "+;
		Transform(VEC->VEC_VALBRU, "@R 999,999,999.99")+" "+Transform((VEC->VEC_VALBRU*VEC->VEC_QTDITE),"@E 999,999,999.99")})
		nTotPec  := VEC->VEC_VALBRU*VEC->VEC_QTDITE
		nTotPec1 := nTotPec1 + nTotPec
		If nPosDep#0
		   aDepartamento[nPosDep,2] += nTotPec
		EndIf
		nPos := Ascan(aResTPT,{|x| x[1] == VEC->VEC_TIPTEM})
		If nPos > 0
			aResTPT[nPos,3] := aResTPT[nPos,3]+ nTotPec
		Else
			DbSelectArea("VOI")
			DbSetOrder(1)
			Dbseek(xfilial("VOI")+VEC->VEC_TIPTEM)
			aadd(aResTPT,{VEC->VEC_TIPTEM,VOI->VOI_DESTTE,nTotPec,0,0,0,0,0})
		EndIf
		DbSelectArea("VEC")
		DbSkip()
	Enddo
	DbSelectArea("VSC")
	DbSetOrder(1)
	Dbseek(xfilial("VSC")+VO1->VO1_NUMOSV)
	nTpoPad := 0
	nTpoTra := 0
	nTpoCob := 0
	nTpoVen := 0
	Do While !Eof() .and. xfilial("VSC") == VSC->VSC_FILIAL .and.VSC->VSC_NUMOSV == VO1->VO1_NUMOSV
		DbSelectArea("VOI")
		DbSetOrder(1)
		DbSeek(xFilial("VOI")+VSC->VSC_TIPTEM)
		DbSelectArea("VOK")
		DbSetOrder(1)
		Dbseek(xfilial("VOK")+VSC->VSC_TIPSER)
		If VOI->VOI_SITTPO # "3" // .Or. !(VOK->VOK_TIPHOR $ "2/3")
			DbSelectArea("VSC")
			DbSkip()
			Loop
		EndIf
		lImpOsv := .t.
		DbSelectArea("VO6")
		DbSetOrder(2)
		Dbseek(xfilial("VO6")+ FG_MARSRV(VV1->VV1_CODMAR,VSC->VSC_CODSER) + VSC->VSC_CODSER )
		DbSelectArea("VAI")
		DbSetOrder(1)
		Dbseek(xfilial("VAI")+VSC->VSC_CODPRO)
		DbSelectArea( "VOK" )
		DbSetOrder(1)
		DbSeek( xFilial("VOK") + VSC->VSC_TIPSER )
		nPosDep:=0
		DbSelectArea("VO2")
		DbSetOrder(1)
		DbSeek(xFilial("VO2")+VSC->VSC_NUMOSV+"S")
		Do While !Eof() .And. VO2->VO2_FILIAL+VO2->VO2_NUMOSV+VO2->VO2_TIPREQ==xFilial("VO2")+VSC->VSC_NUMOSV+"S"
			DbSelectArea("VO4")
			DbSetOrder(1)
			DbSeek(xFilial("VO4")+VO2->VO2_NOSNUM+VSC->VSC_TIPTEM+VSC->VSC_CODSER)
			Do While !Eof() .And. VO4->VO4_FILIAL+VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER==xFilial("VO4")+VO2->VO2_NOSNUM+VSC->VSC_TIPTEM+VSC->VSC_CODSER
				If VO4->VO4_TIPSER == VSC->VSC_TIPSER
					dDataLib := VO4->VO4_DATDIS
					dDataFec := VO4->VO4_DATFEC
					dDataCan := VO4->VO4_DATCAN
					aCodSer := FG_CALVLSER( aCodSer , VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER , NIL ,,,VO2->VO2_DATREQ)
					If !Empty(VO4->VO4_DEPINT)
						If Len(aDepartamento)#0 
						   nPosDep := Ascan(aDepartamento, {|x| x[1]== VO4->VO4_DEPINT} )
						EndIf                               
						If nPosDep == 0
						   Aadd(aDepartamento,{ VO4->VO4_DEPINT , 0 } )
						   nPosDep:=Len(aDepartamento)
						EndIf
					EndIf	
					Exit
				EndIf
				DbSelectArea("VO4")
				DbSkip()
			EndDo
			DbSelectArea("VO2")
			DbSkip()
		EndDo
		If Len(aCodSer) == 0
			DbSelectArea("VSC")
			DbSkip()
			Loop
		EndIf
		aadd(aSerVSC,{space(4)+VSC->VSC_TIPSER+" "+VSC->VSC_GRUSER+"    "+VSC->VSC_CODSER+" "+Substr(VO6->VO6_DESSER,1,30)+""+VSC->VSC_CODPRO+" "+;
		Substr(VAI->VAI_NOMTEC,1,22)+"  "+Transform(aCodSer[2],"@R 999:99")+" "+Transform(aCodSer[5],"@R 999:99")+" "+;
		Transform(aCodSer[3], "@R 999:99")+" "+Transform(aCodSer[4], "@R 999:99")+""+Transform(aCodSer[1], "@E 999,999.99")})
		nValSer   := aCodSer[1]
		nTpoTra   += aCodSer[5]
		nTpoCob   += aCodSer[3]
		nTotSer   += nValSer
		nTpoTra2 := aCodSer[5]
		nTpoCob2 := aCodSer[3]
		nTotSer2 := nValSer
		If  aCodSer[6]
			nTpoPad  +=  aCodSer[2]
			nTpoVen  +=  aCodSer[4]
			nTpoPad2 :=  aCodSer[2]
			nTpoVen2 :=  aCodSer[4]
		EndIf
		If nPosDep#0
		   aDepartamento[nPosDep,2] += nValSer
		EndIf
		nPos := Ascan(aResTPT,{|x| x[1] == VSC->VSC_TIPTEM })
		If nPos > 0
			If  aCodSer[6]
				aResTPT[nPos,4] += nTpoPad2
				aResTPT[nPos,7] += nTpoVen2
			EndIf
			aResTPT[nPos,5] += nTpoTra2
			aResTPT[nPos,6] += nTpoCob2
			aResTPT[nPos,8] += nTotSer2
		Else
			DbSelectArea("VOI")
			DbSetOrder(1)
			Dbseek(xfilial("VOI")+VSC->VSC_TIPTEM)
			aadd(aResTPT,{VSC->VSC_TIPTEM,VOI->VOI_DESTTE,nTotPec,nTpoPad2,nTpoTra2,nTpoCob2,nTpoVen2,nValSer})//nTotSer2})
		EndIf
		nPos := Ascan(aResTPS,{|x| x[1]+x[2] == VSC->VSC_TIPTEM+VSC->VSC_TIPSER })
		If nPos > 0
			If  aCodSer[6]
				aResTPS[nPos,5] += nTpoPad2
				aResTPS[nPos,8] += nTpoVen2
			EndIf
			aResTPS[nPos,6] += nTpoTra2
			aResTPS[nPos,7] += nTpoCob2
			aResTPS[nPos,9] += nTotSer2
		Else
			aadd(aResTPS,{VSC->VSC_TIPTEM,VSC->VSC_TIPSER,VOK->VOK_DESSER,0,nTpoPad2,nTpoTra2,nTpoCob2,nTpoVen2,nValSer}) //nTotSer2})
		EndIf
		DbSelectArea("VSC")
		DbSkip()
	Enddo
	If (MV_PAR03 == 2 .or. MV_PAR03 == 3) .and. lImpOsv
		DbSelectArea("SA1")  //Cliente
		DbSetOrder(1)
		Dbseek(xfilial("SA1")+VOO->VOO_FATPAR+VOO->VOO_LOJA)
		@ nLin, 001 pSay space(1)+VO1->VO1_NUMOSV+"  "+dtoc(VO1->VO1_DATABE)+" "+Transform(VO1->VO1_HORABE,"@R 99:99")+"   "+;
		VV1->VV1_CODMAR + " " + VV1->VV1_MODVEI + " " + Transform(VV1->VV1_FABMOD,"@R 9999/9999")+" "+VV1->VV1_CHAINT +" "+;
		VV1->VV1_CHASSI+" "+VV1->VV1_PLAVEI+" "+VV1->VV1_CODFRO
		nLin+=2
		//Total pecas e servicos
		@ nlin, 001 pSay STR0006 //"  T Fat. para Cliente            CT Fec   Liberada Fechada  Cancel.  Num NF          Pecas    TpoPad TpoTra TpoCob TpoVen   Servico"
		nlin++
		@ nlin,001 pSay space(2)+VOO->VOO_TIPTEM+" "+VOO->VOO_FATPAR+space(1)+VOO->VOO_LOJA+space(1)+substr(SA1->A1_NOME,1,17)+space(2)+VO3->VO3_FUNFEC+" "+VO1->VO1_STATUS+" "+;
		DTOC(dDataLib)+" "+DTOC(dDataFec)+" "+DTOC(dDataCan)+" "+VOO->VOO_NUMNFI+"-"+VOO->VOO_SERNFI+Transform(nTotPec1,"@E 9999,999.99")+" "+Transform(nTpoPad, "@R 999:99")+" "+;
		Transform(nTpoTra, "@E 999:99")+" "+Transform(nTpoCob, "@E 999:99")+" "+Transform(nTpoVen, "@R 999:99")+""+Transform(nTotSer, "@E 999,999.99")
		nLin+=2
		If MV_PAR03 == 3
			If VO1->VO1_STATUS $ "F"
				If Len(aPecVEC)>0
					@ nlin, 001 pSay STR0007 //"  Pcs  Nro.Req. Grpo Codigo                      Descricao                     Qtdade ProReg Formul       Vlr Unit      Vlr Total"
					nlin++
					For i:=1 to Len(aPecVEC)
						@ nlin, 004 pSay aPecVEC[i,1]
						nLin++
						FS_CABEC160(@nLin)
					Next
				EndIf
				If Len(aSerVSC)>0
					nLin++
					@ nlin, 001 pSay STR0008 //"  Srv  TS. GS Codigo             Descricao                     Produtivo                      TpoPad TpoTra TpoCob TpoVen   Servico"
					nlin++
					For i:=1 to Len(aSerVSC)
						@ nlin, 004 pSay aSerVSC[i,1]
						nLin++
						FS_CABEC160(@nLin)
					Next
				EndIf
			EndIf
		EndIf
		nLin++
		@ nlin, 001 pSay "-----------------------------------------------------------------------------------------------------------------------------------"
		nlin++
	EndIf
	If nlin > 55//63
		nlin := 1
		nLin := Cabec(cTitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter)+1
		@ nLin, 001 pSay STR0005 //" Numer.OS  Dt/Hs Abertura   Marca/Modelo do Veiculo            Fabr/Mod. ChaInt Chassi do Veiculo          Placa        Frota"
		nlin++
		@ nlin, 001 pSay "-----------------------------------------------------------------------------------------------------------------------------------"
		nlin++
	EndIf
   IncRegua()   
	DbSelectArea("VO1")
	Dbskip()
Enddo
Resumo()
Departamento(aDepartamento)
MS_FLUSH()
set device to Screen
set Print to
If aReturn[5] == 1
	ourspool(cNomProg)
EndIf
Return
//////////////////////////////////////////
Static Function Resumo()
Local i := 0
Local y := 0
nLin+=2
@ nlin, 001 pSay STR0009 //"-------------------------------  R E S U M O  -----------------------------------"
nLin+=2
@ nLin, 001 pSay STR0010 //"               T i p o s    d e    T e m p o    I n t e r n o"
nlin+=2
@ nlin, 001 pSay STR0011 //"                                 Pecas  TpoPad  TpoTra  TpoCob  TpoVen   Servicos"
nLin+=2
For i := 1 to Len(aResTPT)
	DbSelectArea("VOI")
	DbSeek(xFilial("VOI")+aResTPT[i,1])
	If VOI->VOI_SITTPO == "3"
		@ nLin, 001 pSay aResTPT[i,1]
		@ nLin, 003 pSay aResTPT[i,2]
		@ nLin, 029 pSay Transform(aResTPT[i,3], "@E 999,999.99")
		@ nLin, 041 pSay Transform(aResTPT[i,4], "@E 999:99")
		@ nLin, 049 pSay Transform(aResTPT[i,5], "@E 999:99")
		@ nLin, 057 pSay Transform(aResTPT[i,6], "@E 999:99")
		@ nLin, 065 pSay Transform(aResTPT[i,7], "@E 999:99")
		@ nLin, 072 pSay Transform(aResTPT[i,8], "@E 999,999.99")
		nLin+=2
		For y := 1 to Len(aResTPS)
			If aResTPS[y,1] == aResTPT[i,1]
				@ nLin, 003 pSay aResTPS[y,2]
				@ nLin, 007 pSay aResTPS[y,3]
				//  @ nLin, 029 pSay Transform(aResTPS[y,4], "@E 999,999.99")
				@ nLin, 041 pSay Transform(aResTPS[y,5], "@E 999:99")
				@ nLin, 049 pSay Transform(aResTPS[y,6], "@E 999:99")
				@ nLin, 057 pSay Transform(aResTPS[y,7], "@E 999:99")
				@ nLin, 065 pSay Transform(aResTPS[y,8], "@E 999:99")
				@ nLin, 072 pSay Transform(aResTPS[y,9], "@E 999,999.99")
				nLin++
			EndIf
		Next
	EndIf
Next
nTot3 := 0
nTot4 := 0
nTot5 := 0
nTot6 := 0
nTot7 := 0
nTot8 := 0
For i := 1 to Len(aResTPT)
	DbSelectArea("VOI")
	DbSetOrder(1)
	DbSeek(xFilial("VOI")+ aResTPT[i,1])
	If VOI->VOI_SITTPO == "3"
		nTot3 += aResTPT[i,3]
		nTot4 += aResTPT[i,4]
		nTot5 += aResTPT[i,5]
		nTot6 += aResTPT[i,6]
		nTot7 += aResTPT[i,7]
		nTot8 += aResTPT[i,8]
	EndIf
Next
nLin+=2
@ nLin, 001 pSay STR0012+space(4)+Transform(nTot3, "@E 999,999.99")+space(2)+Transform(nTot4, "@E 999:99")+space(1)+Transform(nTot5, "@E 999:99")+; //" Total.................."
space(3)+Transform(nTot6, "@E 999:99")+space(2)+Transform(nTot7, "@E 999:99")+space(1)+Transform(nTot8, "@E 999,999.99")
nLin+=2
cSrvN1 := "SIM"
For i := 1 to Len(aResTPT)
	DbSelectArea("VOI")
	DbSetOrder(1)
	DbSeek(xFilial("VOI")+aResTPT[i,1])
	If VOI->VOI_SITTPO # "3"
		cSrvN2 := "SIM"
		If cSrvN1 == "SIM" .and. cSrvN2 == "SIM"
			cSrvN1 := "NAO"
			@ nLin, 001 pSay STR0013 //"    Tipos  de  Servico  Interno  aplicados  em  Tipos  de  Tempo  NAO  Interno"
			nLin+=2
			@ nLin, 001 pSay STR0011 //"                                 Pecas  TpoPad  TpoTra  TpoCob  TpoVen   Servicos"
			nLin+=2
		EndIf
		@ nLin, 001 pSay aResTPT[i,1]
		@ nLin, 003 pSay aResTPT[i,2]
		@ nLin, 040 pSay Transform(aResTPT[i,4], "@E 999:99")
		@ nLin, 047 pSay Transform(aResTPT[i,5], "@E 999:99")
		@ nLin, 056 pSay Transform(aResTPT[i,6], "@E 999:99")
		@ nLin, 064 pSay Transform(aResTPT[i,7], "@E 999:99")
		@ nLin, 071 pSay Transform(aResTPT[i,8], "@E 999,999.99")
		nLin+=2
		For y := 1 to Len(aResTPS)
			If aResTPS[y,1] == aResTPT[i,1]
				@ nLin, 003 pSay aResTPS[y,2]
				@ nLin, 007 pSay aResTPS[y,3]
				@ nLin, 040 pSay Transform(aResTPS[y,5], "@E 999:99")
				@ nLin, 047 pSay Transform(aResTPS[y,6], "@E 999:99")
				@ nLin, 056 pSay Transform(aResTPS[y,7], "@E 999:99")
				@ nLin, 064 pSay Transform(aResTPS[y,8], "@E 999:99")
				@ nLin, 071 pSay Transform(aResTPS[y,9], "@E 999,999.99")
				nLin++
			EndIf
		Next
	EndIf
Next
nTot3a := 0
nTot4a := 0
nTot5a := 0
nTot6a := 0
nTot7a := 0
nTot8a := 0
For i := 1 to Len(aResTPT)
	DbSelectArea("VOI")
	DbSetOrder(1)
	DbSeek(xFilial("VOI")+ aResTPT[i,1])
	If VOI->VOI_SITTPO # "3"
		nTot3a += aResTPT[i,3]
		nTot4a += aResTPT[i,4]
		nTot5a += aResTPT[i,5]
		nTot6a += aResTPT[i,6]
		nTot7a += aResTPT[i,7]
		nTot8a += aResTPT[i,8]
	EndIf
Next
nlin++
If ((nTot3a+nTot4a+nTot5a+nTot6a+nTot7a+nTot8a)>0)
	@ nLin, 001 pSay  STR0014+space(4)+Transform(nTot3a, "@E 999,999.99")+space(2)+Transform(nTot4a, "@E 999:99")+; //"Total.................."
	space(1)+Transform(nTot5a, "@E 999:99")+space(3)+Transform(nTot6a, "@E 999:99")+space(2)+Transform(nTot7a, "@E 999:99")+" "+Transform(nTot8a, "@E 999,999.99")
	nLin+=2
EndIf
@ nLin, 001 pSay           "---------------------------------------------------------------------------------"
@ nLin, 001 pSay  STR0015+space(3)+Transform(nTot3 + nTot3a, "@E 999,999.99")+space(2)+Transform(nTot4 + nTot4a, "@E 999:99")+; //"Total Atendimento Interno"
space(1)+Transform(nTot5 + nTot5a, "@E 999:99")+space(3)+Transform(nTot6 + nTot6a, "@E 999:99")+space(2)+;
Transform(nTot7 + nTot7a, "@E 999:99")+" "+Transform(nTot8 + nTot8a, "@E 999,999.99")
@ nLin, 001 pSay space(1)+"---------------------------------------------------------------------------------"
Return
////////////////////////////////////////
Static Function FS_CABEC160(nLin)
If nlin >= 63
	nlin := 1
	nLin := Cabec(cTitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter)+1
	@ nLin, 001 pSay STR0019 // Numer.OS  Dt/Hs Abertura   Marca/Modelo do Veiculo            Fabr/Mod. ChaInt Chassi do Veiculo           Placa       Frota"
	nlin++
	@ nlin, 001 pSay "-----------------------------------------------------------------------------------------------------------------------------------"
	nlin++
EndIf
Return
////////////////////////////////////////
Static Function Departamento(aDepartamento)
Local nDep:=0 , nTotDep:=0
@ nLin++, 000 pSay ""
@ nLin++, 000 pSay ""
@ nLin++, 000 pSay ""
@ nLin++, 000 pSay Repl("-",13)+ STR0016 + Repl("-",13) //Resumido por Departamento
@ nLin++, 000 pSay ""
@ nLin++, 000 pSay STR0017 //Depto  Descricao                              Valor
@ nLin++, 000 pSay Repl("-",51)
For nDep:=1 to Len(aDepartamento)
	DbSelectArea("SX5")
	DbSetOrder(1)
	DbSeek( xFilial("SX5")+ "VD" + aDepartamento[nDep,1] )
	@ nLin, 000 pSay SX5->X5_CHAVE+Space(1)+Substr(SX5->X5_DESCRI,1,29)+Space(1)+Transform(aDepartamento[nDep,2],"@E 999,999,999.99")
	nTotDep += aDepartamento[nDep,2]
Next
@ nLin++, 000 pSay Repl("-",51)
@ nLin, 30 pSay STR0020+" "+Transform(nTotDep,"@E 999,999,999.99")  //total
@ nLin++, 000 pSay Repl("-",51)
Return
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////