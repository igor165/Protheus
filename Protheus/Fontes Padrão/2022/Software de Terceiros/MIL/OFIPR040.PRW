#Include "PROTHEUS.Ch"
#Include "OFIPR040.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIPR040 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 16.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ RELACAO DAS BAIXAS - CONTAS A PAGAR                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function OFIPR040()
Local oReport
Local aArea := GetArea()
Private cImp := ""
Private nX   := 0
If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	FS_OPR040R3()
EndIf
RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/07/06 ³±±
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
Local oCell

oReport := TReport():New("OFIPR040",STR0001,"OFP040",{|oReport| OPR040IMP(oReport)})

oSection1 := TRSection():New(oReport,OemToAnsi(STR0001),{})
TRCell():New(oSection1,"",,"","@!",132,,{|| cImp })

oSection2 := TRSection():New(oReport,OemToAnsi(STR0010),{"SE5","SA2","SE2"}) //Titulos
TRCell():New(oSection2,"E5_PREFIXO","SE5")
TRCell():New(oSection2,"E5_NUMERO" ,"SE5")
TRCell():New(oSection2,"E5_PARCELA","SE5")
TRCell():New(oSection2,"E5_TIPO"   ,"SE5")
TRCell():New(oSection2,"A2_NOME"   ,"SA2",,,12)
If SE2->(FieldPos("E2_NOSNUM")) > 0
	TRCell():New(oSection2,"E2_NOSNUM" ,"SE2")
EndIf
TRCell():New(oSection2,"E2_VENCTO" ,"SE2",,"@D")
TRCell():New(oSection2,"E5_DATA"   ,"SE5",,"@D")
TRCell():New(oSection2,"E2_VALOR"  ,,,"@E 99,999,999.99",13,,{|| nX*SE2->E2_VALOR })
TRCell():New(oSection2,"E5_VLMULTA",,,"@E 999,999.99",10,,{|| nX*SE5->E5_VLMULTA })
TRCell():New(oSection2,"E5_VLJUROS",,,"@E 999,999.99",10,,{|| nX*SE5->E5_VLJUROS })
TRCell():New(oSection2,"E5_VLDESCO",,,"@E 999,999.99",10,,{|| nX*SE5->E5_VLDESCO })
TRCell():New(oSection2,"E5_DTDIGIT","SE5",,"@D")
TRCell():New(oSection2,"E5_TIPODOC","SE5")
TRCell():New(oSection2,"E5_MOTBX"  ,"SE5")

TRPosition():New(oSection2,"SA2",1,{|| xFilial()+SE5->E5_CLIFOR+SE5->E5_LOJA })

Return oReport
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OPR040IMP³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao do relatorio do TReport                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                     
Function OPR040IMP(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local dQuebra := CtoD("  /  /  ")
Local dDataAnt:= CtoD("  /  /  ")
Local cQuebra := "INICIAL"
Local cSE2Pos := cSE5Pos := cSE2Whl := cSE5Whl := ""
Local nTotalVOri := nTotalMult := nTotalJuro := nTotalDesc := nTotalVRec := nTotalQtde := 0
Local nDataBVOri := nDataBMult := nDataBJuro := nDataBDesc := nDataBVRec := nDataBQtde := 0
Local nBancoVOri := nBancoMult := nBancoJuro := nBancoDesc := nBancoVRec := nBancoQtde := 0
Local lOK := .f.
Local cStr := cDia := cMes := cAno := cDat := cNomArq1 := cLinha := ""
Local nImp := 0
PERGUNTE("OFP040",.F.)
DbSelectArea("SE5")
DbSetOrder(1)
DbSeek(xFilial("SE5")+Dtos(mv_par01),.T.)
oReport:SetMeter(RecCount())
oSection1:Init()
oSection2:Init()
While !Eof() .and. !oReport:Cancel() .and. SE5->E5_FILIAL == xFilial("SE5") .and. SE5->E5_DATA <= mv_par02
	oReport:IncMeter()
 	If !Empty(MV_PAR10) .and. MV_PAR10 # SE5->E5_MOTBX
		DbSelectArea("SE5") 
		DbSkip()
		Loop
	EndIf
	lOK := .f.
	If ( ( SE5->E5_RECPAG == "P" ) .and. ( SE5->E5_TIPODOC $ "VL/BA" ) )
		lOK := .t.
		nX := 1
	ElseIf ( ( SE5->E5_RECPAG == "R" ) .and. ( SE5->E5_TIPODOC == "ES" ) )
		lOK := .t.
		nX := -1
	EndIf
	If !lOK
		DbSelectArea("SE5") 
		DbSkip()
		Loop
	EndIf
 	If !Empty(MV_PAR03) .or. !Empty(MV_PAR04) 
		If !((SE5->E5_BANCO >= MV_PAR03).and.(SE5->E5_BANCO <= MV_PAR04))
			DbSelectArea("SE5") 
			DbSkip()
			Loop
		EndIf
	EndIf
	If !Empty(MV_PAR05) .or. !Empty(MV_PAR06)
		If !((SE5->E5_DTDIGIT >= MV_PAR05).and.(SE5->E5_DTDIGIT <= MV_PAR06))
			DbSelectArea("SE5") 
			DbSkip()
			Loop
		EndIf
	EndIf
	If MV_PAR07 # 3
		If MV_PAR07 == 1
			If Empty(SE5->E5_ARQCNAB)
				DbSelectArea("SE5") 
				DbSkip()
				Loop
			EndIf
		Else // MV_PAR07 == 2
			If !Empty(SE5->E5_ARQCNAB)
				DbSelectArea("SE5") 
				DbSkip()
				Loop
			EndIf
		EndIf
	EndIf
	DbSelectArea( "SE2")
	DbSetOrder(1)
	DbSeek(xFilial("SE2") + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO )
	cSE2Pos := SE2->E2_NATUREZ + SE2->E2_FORNECE + SE2->E2_LOJA
	cSE5Pos := SE5->E5_NATUREZ + SE5->E5_CLIFOR  + SE5->E5_LOJA
	cSE2Whl := SE2->E2_PREFIXO + SE2->E2_NUM     + SE2->E2_PARCELA + SE2->E2_TIPO
	cSE5Whl := SE5->E5_PREFIXO + SE5->E5_NUMERO  + SE5->E5_PARCELA + SE5->E5_TIPO
	If ( cSE2Pos # cSE5Pos )
   		While !Eof() .and. ( SE2->E2_FILIAL == xFilial("SE2") ) .and. ( cSE2Whl == cSE5Whl )
	   		cSE2Pos := SE2->E2_NATUREZ + SE2->E2_FORNECE+ SE2->E2_LOJA
		   	If ( cSE2Pos == cSE5Pos )
	        	Exit
			EndIf
			DbSelectArea("SE2") 
			DbSkip()
		EndDo
   EndIf
   If dQuebra # SE5->E5_DATA 
  		dQuebra := SE5->E5_DATA 
		cQuebra:= "INICIAL"
		If ( ( nBancoVOri + nBancoMult + nBancoJuro + nBancoDesc + nBancoVRec ) # 0 )
			oReport:SkipLine()
			cImp := "."+space(24)+STR0005+Transform(nBancoQtde,"@E 99,999,999")+STR0006+Transform(nBancoVOri,"@E 99,999,999.99")+Transform(nBancoMult,"@E 999,999.99")
			cImp += Transform(nBancoJuro,"@E 999,999.99")+Transform(nBancoDesc,"@E 999,999.99")+Transform(nBancoVRec,"@E 99,999,999.99")
			oSection1:PrintLine()
			nBancoVOri := nBancoMult := nBancoJuro := nBancoDesc := nBancoVRec := nBancoQtde := 0
			oReport:SkipLine()
			cImp := "."+substr(STR0007,2)+"( "+Transform(dDataAnt,"@D")+" )"+Transform(nDataBQtde,"@E 99,999,999")+STR0006+Transform(nDataBVOri,"@E 99,999,999.99")+Transform(nDataBMult,"@E 999,999.99")
			cImp += Transform(nDataBJuro,"@E 999,999.99")+Transform(nDataBDesc,"@E 999,999.99")+Transform(nDataBVRec,"@E 99,999,999.99")
			oSection1:PrintLine()
			nDataBVOri := nDataBMult := nDataBJuro := nDataBDesc := nDataBVRec := nDataBQtde := 0
		EndIf
		oReport:SkipLine()
		oReport:SkipLine()
		cImp := "*** "+Transform(dQuebra,"@D")+" "+Repl("*",119)
		oSection1:PrintLine()
		oReport:SkipLine()
	   	dDataAnt := dQuebra
	EndIf
	If cQuebra # SE5->E5_BANCO
    	cQuebra := SE5->E5_BANCO 
		DbSelectArea("SA6")
		DbSetOrder(1)
		DbSeek(cFilial + cQuebra )
		If ( ( nBancoVOri + nBancoMult + nBancoJuro + nBancoDesc + nBancoVRec ) # 0 )
			oReport:SkipLine()
			cImp := "."+space(24)+STR0005+Transform(nBancoQtde,"@E 99,999,999")+STR0006+Transform(nBancoVOri,"@E 99,999,999.99")+Transform(nBancoMult,"@E 999,999.99")
			cImp += Transform(nBancoJuro,"@E 999,999.99")+Transform(nBancoDesc,"@E 999,999.99")+Transform(nBancoVRec,"@E 99,999,999.99")
			oSection1:PrintLine()
			nBancoVOri := nBancoMult := nBancoJuro := nBancoDesc := nBancoVRec := nBancoQtde := 0
		EndIf
		oReport:SkipLine()
		cImp := "-- "+Alltrim(cQuebra)+" "+Alltrim(A6_NOME)+" "+Repl("-",(127-len(Alltrim(cQuebra)+Alltrim(A6_NOME))))
		oSection1:PrintLine()
		oReport:SkipLine()
		If nImp # 0
			oSection2:PrintHeader()
			oReport:SkipLine()
		EndIf
		nImp++
	EndIf
	oSection2:PrintLine()
	nBancoVOri += nX * SE2->E2_VALOR
	nBancoMult += nX * SE5->E5_VLMULTA
	nBancoJuro += nX * SE5->E5_VLJUROS
	nBancoDesc += nX * SE5->E5_VLDESCO
	nBancoVRec += nX * SE5->E5_VALOR
	nBancoQtde++
	nDataBVOri += nX * SE2->E2_VALOR
	nDataBMult += nX * SE5->E5_VLMULTA
	nDataBJuro += nX * SE5->E5_VLJUROS
	nDataBDesc += nX * SE5->E5_VLDESCO
	nDataBVRec += nX * SE5->E5_VALOR
	nDataBQtde++
	nTotalVOri += nX * SE2->E2_VALOR
	nTotalMult += nX * SE5->E5_VLMULTA
	nTotalJuro += nX * SE5->E5_VLJUROS
	nTotalDesc += nX * SE5->E5_VLDESCO
	nTotalVRec += nX * SE5->E5_VALOR
	nTotalQtde++
	DbSelectArea("SE5") 
	DbSkip()
EndDo
If ( ( nBancoVOri + nBancoMult + nBancoJuro + nBancoDesc + nBancoVRec ) # 0 )
	oReport:SkipLine()
	cImp := "."+space(24)+STR0005+Transform(nBancoQtde,"@E 99,999,999")+STR0006+Transform(nBancoVOri,"@E 99999,999,999.99")+Transform(nBancoMult,"@E 999999,999.99")
	cImp += Transform(nBancoJuro,"@E 999999,999.99")+Transform(nBancoDesc,"@E 9999999,999.99")+Transform(nBancoVRec,"@E 999999,999,999.99")
	oSection1:PrintLine()
EndIf
oReport:SkipLine()
cImp := "."+STR0007+" ( "+Transform(dDataAnt,"@D")+" )"+Transform(nDataBQtde,"@E 99,999,999")+STR0006+space(15)+Transform(nDataBVOri,"@E 99999,999,999.99")+Transform(nDataBMult,"@E 999999,999.99")
cImp += Transform(nDataBJuro,"@E 999999,999.99")+Transform(nDataBDesc,"@E 9999999,999.99")+Transform(nDataBVRec,"@E 999999,999,999.99")
oSection1:PrintLine()
oReport:SkipLine()
oReport:SkipLine()
cImp := Repl("*",132)
oSection1:PrintLine()
oReport:SkipLine()
cImp := "."+STR0009+Transform(nTotalQtde,"@E 999,999,999")+STR0006+space(15)+Transform(nTotalVOri,"@E 99999,999,999.99")+Transform(nTotalMult,"@E 999999,999.99")
cImp += Transform(nTotalJuro,"@E 999999,999.99")+Transform(nTotalDesc,"@E 9999999,999.99")+Transform(nTotalVRec,"@E 999999,999,999.99")
oSection1:PrintLine()
oReport:SkipLine()
cImp := Repl("*",132)
oSection1:PrintLine()
if mv_par11 == 1
      cStr := FT_FReadLN()
      cDia := substr(dtoc(ddatabase),1,2)
      cMes := substr(dtoc(ddatabase),4,2)
      cAno := substr(dtoc(ddatabase),7,2)
      cDat := cDia+cMes+cAno
      cNomArq1 := "\system\"+cDat+"cp.TXT"
      Outputfile := FCREATE(cNomArq1,0)
      cLinha := "1"+","+transform(ddatabase,"@D")+","+"0"+","+"423"+","+alltrim(transform(nTotalVRec,"99999999.99"))+","+"103"+","+""+Chr(10)
      if !Empty(cLinha)
         fwrite(outputfile,clinha)
         cLinha := ""
      Endif
Endif
oSection1:Finish()
oSection2:Finish()
Return Nil


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function FS_OPR040R3()
Private cDesc1  := OemToAnsi(STR0001)
Private cDesc2  := ""
Private cDesc3  := ""
Private tamanho := "M"
Private limite  := 132
Private cString := "SE5"
Private titulo  := OemToAnsi(STR0002)
Private cabec1  := ""
Private cabec2  := ""
Private cNomeArq
Private aReturn := { OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 1, 2, 1, "",1 }
Private nomeprog:="OFIPR040"
Private aLinha  := { },nLastKey := 0
Private cPerg   :="OFP040"
wnrel := nomeprog
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
If nLastKey == 27
   Return
EndIf     
Pergunte(cPerg,.F.)
SetDefault(aReturn,cString)
RptStatus( { |lEnd| FS_IMPM_RCPBXA(@lEnd,wnrel,cString) } , Titulo )
If aReturn[5] == 1
   OurSpool( wnrel )
EndIf
MS_Flush()
Return
//////////////////////////////////////////////////////////////////////////////
Static Function FS_IMPM_RCPBXA()
cbtxt   := SPACE(10)
cbcont  := 0
li      := 0
m_pag   := 1
cabec1  := ""
cabec2  := ""
dQuebra := CtoD("  /  /  ")
dDataAnt:= CtoD("  /  /  ")
cQuebra := "INICIAL"
cNome   := "INICIAL"
nTotalVOri := 0
nTotalMult := 0
nTotalJuro := 0
nTotalDesc := 0
nTotalVRec := 0
nTotalQtde := 0
nDataBVOri := 0
nDataBMult := 0
nDataBJuro := 0
nDataBDesc := 0
nDataBVRec := 0
nDataBQtde := 0
nBancoVOri := 0
nBancoMult := 0
nBancoJuro := 0
nBancoDesc := 0
nBancoVRec := 0
nBancoQtde := 0
Set Printer to &wnrel
Set Printer On
Set Device  to Printer
li := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
DbSelectArea("SE5")
DbSetOrder(1)
DbSeek(xFilial("SE5")+Dtos(mv_par01),.T.)
SetRegua( RecCount() )       
While !Eof() .and. ( SE5->E5_FILIAL == xFilial("SE5") ) .and. ( SE5->E5_DATA <= mv_par02 )
	IncRegua()
 	If !Empty(MV_PAR10) .and. MV_PAR10 # SE5->E5_MOTBX
		DbSelectArea("SE5") 
		DbSkip()
		Loop
	EndIf
	cOK := "NAO"
	If ( ( SE5->E5_RECPAG == "P" ) .and. ( SE5->E5_TIPODOC $ "VL/BA" ) )
		cOK := "SIM"
		nX := 1
	ElseIf ( ( SE5->E5_RECPAG == "R" ) .and. ( SE5->E5_TIPODOC == "ES" ) )
		cOK := "SIM"
		nX := -1
	EndIf
 	If cOK # "SIM"
		DbSelectArea("SE5") 
		DbSkip()
		Loop
	EndIf
 	If !Empty(MV_PAR03) .or. !Empty(MV_PAR04) 
		If !((SE5->E5_BANCO >= MV_PAR03).and.(SE5->E5_BANCO <= MV_PAR04))
			DbSelectArea("SE5") 
			DbSkip()
			Loop
		EndIf
	EndIf
	If !Empty(MV_PAR05) .or. !Empty(MV_PAR06)
		If !((SE5->E5_DTDIGIT >= MV_PAR05).and.(SE5->E5_DTDIGIT <= MV_PAR06))
			DbSelectArea("SE5") 
			DbSkip()
			Loop
		EndIf
	EndIf
	If MV_PAR07 # 3
		If MV_PAR07 == 1
			If Empty(SE5->E5_ARQCNAB)
				DbSelectArea("SE5") 
				DbSkip()
				Loop
			EndIf
      Else // MV_PAR07 == 2
			If !Empty(SE5->E5_ARQCNAB)
				DbSelectArea("SE5") 
				DbSkip()
				Loop
			EndIf
		EndIf
	EndIf
	If cNome # SE5->E5_CLIFOR + SE5->E5_LOJA
		cNome := SE5->E5_CLIFOR + SE5->E5_LOJA
		DbSelectArea( "SA2")
		DbSetOrder(1)
		DbSeek(xFilial("SA2") + cNome )
	EndIf
	DbSelectArea( "SE2")
	DbSetOrder(1)
	DbSeek(xFilial("SE2") + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO )
   cSE2Pos := SE2->E2_NATUREZ + SE2->E2_FORNECE + SE2->E2_LOJA
   cSE5Pos := SE5->E5_NATUREZ + SE5->E5_CLIFOR  + SE5->E5_LOJA
   cSE2Whl := SE2->E2_PREFIXO + SE2->E2_NUM     + SE2->E2_PARCELA + SE2->E2_TIPO
   cSE5Whl := SE5->E5_PREFIXO + SE5->E5_NUMERO  + SE5->E5_PARCELA + SE5->E5_TIPO
   If ( cSE2Pos # cSE5Pos )
   	While !Eof() .and. ( SE2->E2_FILIAL == xFilial("SE2") ) .and. ( cSE2Whl == cSE5Whl )
	   	cSE2Pos := SE2->E2_NATUREZ + SE2->E2_FORNECE+ SE2->E2_LOJA
		   If ( cSE2Pos == cSE5Pos )
	         Exit
			EndIf
			DbSelectArea("SE2") 
			DbSkip()
		EndDo
   EndIf
   If dQuebra # SE5->E5_DATA 
  		dQuebra := SE5->E5_DATA 
		cQuebra:= "INICIAL"
		If ( ( nBancoVOri + nBancoMult + nBancoJuro + nBancoDesc + nBancoVRec ) # 0 )
			li++
			@li++, 00 PSAY space(25)+STR0005+Transform(nBancoQtde,"@E 99,999,999")+STR0006 ;
						+ Transform(nBancoVOri,"@E 99,999,999.99") ;
						+ Transform(nBancoMult,"@E 999,999.99") ;
						+ Transform(nBancoJuro,"@E 999,999.99") ;
						+ Transform(nBancoDesc,"@E 999,999.99") ;
						+ Transform(nBancoVRec,"@E 99,999,999.99")
			nBancoVOri := 0
			nBancoMult := 0
			nBancoJuro := 0
			nBancoDesc := 0
			nBancoVRec := 0
			nBancoQtde := 0
			li++
			@li++, 00 PSAY STR0007+"( " + Transform(dDataAnt,"@D") + " )" + Transform(nDataBQtde,"@E 99,999,999") + STR0006 ;
						+ Transform(nDataBVOri,"@E 99,999,999.99") ;
						+ Transform(nDataBMult,"@E 999,999.99") ;
						+ Transform(nDataBJuro,"@E 999,999.99") ;
						+ Transform(nDataBDesc,"@E 999,999.99") ;
						+ Transform(nDataBVRec,"@E 99,999,999.99")
			nDataBVOri := 0
			nDataBMult := 0
			nDataBJuro := 0
			nDataBDesc := 0
			nDataBVRec := 0
			nDataBQtde := 0
		EndIf
		If li >= 50
			li := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
		EndIF
		li++
		li++
		@li++, 00 PSAY "*** " + Transform(dQuebra,"@D") + " " + Repl("*",119)
   	dDataAnt := dQuebra
		li++
	EndIf
   If cQuebra # SE5->E5_BANCO
      cQuebra := SE5->E5_BANCO 
		DbSelectArea("SA6")
		DbSetOrder(1)
		DbSeek(cFilial + cQuebra )
		If ( ( nBancoVOri + nBancoMult + nBancoJuro + nBancoDesc + nBancoVRec ) # 0 )
			li++
			@li++, 00 PSAY space(25)+STR0005+Transform(nBancoQtde,"@E 99,999,999")+STR0006 ;
						+ Transform(nBancoVOri,"@E 99,999,999.99") ;
						+ Transform(nBancoMult,"@E 999,999.99") ;
						+ Transform(nBancoJuro,"@E 999,999.99") ;
						+ Transform(nBancoDesc,"@E 999,999.99") ;
						+ Transform(nBancoVRec,"@E 99,999,999.99")
			nBancoVOri := 0
			nBancoMult := 0
			nBancoJuro := 0
			nBancoDesc := 0
			nBancoVRec := 0
			nBancoQtde := 0
		EndIf
		If li >= 55
			li := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
		EndIF
		li++
		@li++, 01 PSAY "- " + Alltrim(cQuebra) + " " + Alltrim(A6_NOME) + " " + Repl("-",(127-len(Alltrim(cQuebra)+Alltrim(A6_NOME))))
		li++
		@li++, 00 PSAY STR0008
		li++
	EndIf
	If li >= 60
		li := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
	EndIF
	@li++ , 00 psay	SE5->E5_PREFIXO +" "+ SE5->E5_NUMERO +" "+ SE5->E5_PARCELA +" "+ SE5->E5_TIPO +" "+ left(SA2->A2_NOME,12) +" "+ SE2->E2_NOSNUM +" "+ ;
							Transform(SE2->E2_VENCTO,"@D") +" "+ Transform(SE5->E5_DATA,"@D") +" "+ ;
							Transform(nX * SE2->E2_VALOR,"@E 99,999,999.99") + ;
							Transform(nX * SE5->E5_VLMULTA,"@E 999,999.99")	+ ;
							Transform(nX * SE5->E5_VLJUROS,"@E 999,999.99")	+ ;
							Transform(nX * SE5->E5_VLDESCO,"@E 999,999.99")	+ ;
							Transform(nX * SE5->E5_VALOR,"@E 99,999,999.99") +" "+ ;
							Transform(SE5->E5_DTDIGIT,"@D") +" "+ SE5->E5_TIPODOC +" "+ SE5->E5_MOTBX
	nBancoVOri += nX * SE2->E2_VALOR
	nBancoMult += nX * SE5->E5_VLMULTA
	nBancoJuro += nX * SE5->E5_VLJUROS
	nBancoDesc += nX * SE5->E5_VLDESCO
	nBancoVRec += nX * SE5->E5_VALOR
	nBancoQtde++
	nDataBVOri += nX * SE2->E2_VALOR
	nDataBMult += nX * SE5->E5_VLMULTA
	nDataBJuro += nX * SE5->E5_VLJUROS
	nDataBDesc += nX * SE5->E5_VLDESCO
	nDataBVRec += nX * SE5->E5_VALOR
	nDataBQtde++
	nTotalVOri += nX * SE2->E2_VALOR
	nTotalMult += nX * SE5->E5_VLMULTA
	nTotalJuro += nX * SE5->E5_VLJUROS
	nTotalDesc += nX * SE5->E5_VLDESCO
	nTotalVRec += nX * SE5->E5_VALOR
	nTotalQtde++
	DbSelectArea("SE5") 
	DbSkip()
EndDo
If ( ( nBancoVOri + nBancoMult + nBancoJuro + nBancoDesc + nBancoVRec ) # 0 )
	li++
	@li++, 00 PSAY space(25)+STR0005+Transform(nBancoQtde,"@E 99,999,999")+STR0006 ;
				+ Transform(nBancoVOri,"@E 99,999,999.99") ;
				+ Transform(nBancoMult,"@E 999,999.99") ;
				+ Transform(nBancoJuro,"@E 999,999.99") ;
				+ Transform(nBancoDesc,"@E 999,999.99") ;
				+ Transform(nBancoVRec,"@E 99,999,999.99")
EndIf
li++
@li++, 00 PSAY STR0007+"( " + Transform(dDataAnt,"@D") + " )" + Transform(nDataBQtde,"@E 99,999,999") + STR0006 ;
			+ Transform(nDataBVOri,"@E 99,999,999.99") ;
			+ Transform(nDataBMult,"@E 999,999.99") ;
			+ Transform(nDataBJuro,"@E 999,999.99") ;
			+ Transform(nDataBDesc,"@E 999,999.99") ;
			+ Transform(nDataBVRec,"@E 99,999,999.99")
li++
li++
@li++, 00 PSAY Repl("*",132)
li++
@li++, 00 PSAY STR0009 + Transform(nTotalQtde,"@E 99,999,999") + STR0006 ;
				+ Transform(nTotalVOri,"@E 99,999,999.99") ;
				+ Transform(nTotalMult,"@E 999,999.99") ;
				+ Transform(nTotalJuro,"@E 999,999.99") ;
				+ Transform(nTotalDesc,"@E 999,999.99") ;
				+ Transform(nTotalVRec,"@E 99,999,999.99")
li++
@li, 00 PSAY Repl("*",132)
if mv_par11 == 1
      cStr := FT_FReadLN()
      cDia := substr(dtoc(ddatabase),1,2) 
      cMes := substr(dtoc(ddatabase),4,2) 
      cAno := substr(dtoc(ddatabase),7,2) 
      cData := cDia+cMes+cAno
      cDirect := "\sigaadv\"+cData+"cp.TXT"
      cNomArq1 := cDirect
      Outputfile := FCREATE(cNomArq1,0)
      cLinha := "1"+","+transform(ddatabase,"@D")+","+"0"+","+"423"+","+alltrim(transform(nTotalVRec,"99999999.99"))+","+"103"+","+""+Chr(10)
      if !Empty(cLinha)
         fwrite(outputfile,clinha)
         lRet := .t.
         cLinha := "" 
      Endif
Endif  

Set Printer to
Set Device  to Screen
Return
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////