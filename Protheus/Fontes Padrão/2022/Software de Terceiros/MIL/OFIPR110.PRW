#include "Ofipr110.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFIPR110 ºAutor  ³Andre Luis Almeida  º Data ³  17/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao dos Titulos Provisorios                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MIL                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIPR110()

//Local oReport

Private cTotal := ""
Private nTotal := 0
Private nTotalGeral := 0

//If !(FindFunction("TRepInUse") .And. TRepInUse())
OFPR110R3() // Executa versão anterior do fonte
/*Else
	If TRepInUse()
		oReport := ReportDef()
		oReport:PrintDialog()
	Endif
Endif
*/
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef³ Autor ³ ANDRE                 ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio usando o TReport                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Static Function ReportDef()

Local oReport
Local oSection1
Local oCell

oReport := TReport():New("OFIPR110",OemToAnsi(STR0013),,{|oReport| PR110Imp(oReport)})  // Titulos provisorios

oSection1 := TRSection():New(oReport,OemToAnsi(STR0014),{"SE1","SA1","SE4"}) // Secao 1
oSection1:SetHeaderPage(.T.)
oSection1:SetHeaderBreak(.T.)                // FNC 28068 - Antonio(Boby) - 03/12/09
oSection1:SetPageBreak(.T.)                  // Alterar cabecalho e alterar descricao do campo cond. pagto
oSection1:SetHeaderSection(.T.)              // e acrescentar o campo nr titulo.

TRCell():New(oSection1,"E1_CLIENTE","SE1",STR0015,,6)         // Cliente
TRCell():New(oSection1,"E1_LOJA"   ,"SE1",STR0016,,12)        // Loja
TRCell():New(oSection1,"A1_NOME"   ,"SA1",STR0017,,30)        // Nome 
TRCell():New(oSection1,"E4_COND"   ,"SE4",STR0027,,35)        // Cond. Pagto    // boby

TRPosition():New(oSection1,"SA1",1,{|| xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA })
TRPosition():New(oSection1,"SE4",1,{|| xFilial("SE4") + SA1->A1_COND })

oSection2 := TRSection():New(oReport,OemToAnsi(STR0018),{"SE1","SA1"})  // Secao 2
TRCell():New(oSection2,"E1_TIPO"   ,"SE1",STR0019,,5)       // Tipo
TRCell():New(oSection2,"E1_PREFIXO","SE1",STR0020,,5)       // Prefixo
TRCell():New(oSection2,"E1_NUM"    ,"SE1",STR0028,,10)      // No. Titulo       // boby
TRCell():New(oSection2,"E1_PARCELA","SE1",STR0021,,10)      // Parcela
TRCell():New(oSection2,"E1_EMISSAO","SE1",STR0022,,20)      // Emissao
TRCell():New(oSection2,"E1_VALOR"  ,"SE1",STR0023,,35)      // Valor

oSection3 := TRSection():New(oReport,OemToAnsi(STR0024),{}) //Secao 3
TRCell():New(oSection3,"",,"","@!",102,, {|| cTotal } )

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OR130Imp ³ Autor ³ ANDRE                 ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao do relatorio do TReport                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PR110Imp(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local oSection3 := oReport:Section(3)
Local cTipTit := Left(Alltrim(GetNewPar("MV_TIPPER","TP"))+space(3),Len(SE1->E1_TIPO)) // Tipo de Titulo Provisorio

dbSelectArea("SE1")
dbSeek(xFilial("SE1"))

oReport:SetMeter(RecCount())
oSection1:Init(.f.)
oSection2:Init(.f.)
oSection3:Init(.f.)
oReport:SetMeter(SE1->(RecCount()))
oSection1:lInit := .f.
oSection1:lPrintHeader := .f.

oSection2:PrintHeader()
oSection2:lInit := .f.
oSection2:lPrintHeader := .f.

cCliente := ""
While !Eof() // .and. &( cCondicao )
	If SE1->E1_TIPO == cTipTit
		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf
		If cCliente <> SE1->E1_CLIENTE
			oSection1:PrintLine()
			If oReport:PageBreak()
				oSection1:PrintHeader()
				oSection2:PrintHeader()
			EndIf
		EndIf
		oSection2:PrintLine()
		cCliente := SE1->E1_CLIENTE
		nTotal += SE1->E1_VALOR
		
		nTotalGeral := nTotalGeral + SE1->E1_VALOR   
		
		dbSelectArea("SE1")
		dbSkip()
		If cCliente <> SE1->E1_CLIENTE
			cTotal := ">>>"+Space(60)+"-------------------------------------------------------"
			oSection3:PrintLine()
			cTotal := ">>>"+Space(72)+STR0025+transform(nTotal,"@E 999,999,999.99")  //"Total.............
			oSection3:PrintLine()
			oReport:SkipLine(2)
			nTotal := 0
		EndIf
		//	   nTotalGeral := TotalGeral + nTotal
	Else
		dbSelectArea("SE1")
		dbSkip()
	EndIf
EndDo

cTotal := STR0026  //>>>>>>>>>> TOTAL GERAL <<<<<<<<<<
oSection3:PrintLine()
cTotal := ">>>     "+transform(nTotalGeral,"@E 999,999,999.99")
oSection3:PrintLine()

oSection1:Finish()
oSection2:Finish()
oSection3:Finish()

Return Nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFIPR110 ºAutor  ³Andre Luis Almeida  º Data ³  17/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao dos Titulos Provisorios                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MIL                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFPR110R3()

Local   cCliente  := ""
Local   aTitulos  := {}
Local   ni        := 0
Local cTipTit := Left(Alltrim(GetNewPar("MV_TIPPER","TP"))+space(3),Len(SE1->E1_TIPO)) // Tipo de Titulo Provisorio
Private cTitulo   := OemToAnsi(STR0004)
Private Titulo    := OemToansi(STR0004)
Private cDesc1    := OemToAnsi(STR0001)
Private cDesc2    := ""
Private cDesc3    := ""
Private cString   := "SE1"
Private aRegistros:= {}
Private ctamanho  := "P"
Private aReturn   :=  { OemToAnsi(STR0002) , 1 , OemToAnsi(STR0003) , 2 , 2 , 1 , "" , 1 }
Private nLastKey  := 0
Private cDrive    := GetMv("MV_DRVOSN")
Private cNomeImp  := GetMv("MV_POROSN")
Private cAlias    := "SE1"
Private cNomRel   := "OFIPR110"
Private lHabil    := .f.
Private lServer   := ( GetNewPar("MV_LSERVER","S") == "S" )
Private nLin      := 1
Private nTotal    := 0
Private nTotGeral := 0
Private nPag      := 1
Private nCont     := 0

cNomeRel := SetPrint(cString,cNomRel,nil,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cAlias)
aDriver := LeDriver()
cNormal := aDriver[2]
Set Printer to &cNomeRel
Set Printer On
Set Device to Printer

cCliente := "INICIO"
Dbselectarea("SE1")
DbSetOrder(2)
DbSeek( xFilial("SE1") )
Do While !Eof()
	If SE1->E1_TIPO == cTipTit
		If cCliente # SE1->E1_CLIENTE + SE1->E1_LOJA
			cCliente := SE1->E1_CLIENTE + SE1->E1_LOJA
			DbSelectArea( "SA1" )
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA )
			DbSelectArea( "SE4" )
			DbSetOrder(1)
			DbSeek( xFilial("SE4") + SA1->A1_COND )
		EndIf
		aAdd(aTitulos,{SE1->E1_CLIENTE + "-" + SE1->E1_LOJA , SA1->A1_NOME , Left(SE4->E4_COND,34) , left(SA1->A1_TIPPER+space(2),2) , left(SE1->E1_PREFORI+space(3),3)+" "+left(SE1->E1_PREFIXO+space(3),3) , left(SE1->E1_NUM+space(9),9) , Right(space(3)+SE1->E1_PARCELA,3) , SE1->E1_EMISSAO , SE1->E1_VALOR })
		nTotGeral+= SE1->E1_VALOR
	EndIf
	Dbselectarea("SE1")
	DbSkip()
Enddo

nLin := 1
@ nLin++ , 00 psay OemToansi(STR0005)+ str(nPag,3)
aSort(aTitulos,1,,{|x,y| x[2]+x[6]+x[7] < y[2]+y[6]+y[7] })

cCliente := "INICIO"
For ni:=1 to Len(aTitulos)
	If cCliente # aTitulos[ni,1]
		cCliente := aTitulos[ni,1]
		If nLin > 50
			nPag++
			nLin := 1
			@ nLin++ , 00 psay OemToAnsi(STR0006)+ str(nPag,3)
		EndIf
		nLin++
		@ nLin++ , 00 psay Repl("-",65)
		@ nLin++ , 01 psay OemToAnsi(STR0007) + aTitulos[ni,1] + " " + aTitulos[ni,2]
		@ nLin++ , 01 psay OemToAnsi(STR0008) + aTitulos[ni,3] + " " + aTitulos[ni,4]
		@ nLin++ , 00 psay Repl("-",65)
		nLin++
		@ nLin++ , 05 psay OemToAnsi(STR0010)
		nLin++
		nTotal := 0
	EndIf
	If nLin > 60
		nPag++
		nLin := 1
		@ nLin++ , 00 psay OemToAnsi(STR0005)+ str(nPag,3)
		nLin++
		@ nLin++ , 02 psay OemToAnsi(STR0011)
		nLin++
	EndIf
	nTotal += aTitulos[ni,9]
	@ nLin++ , 05 psay aTitulos[ni,5] + "  " + aTitulos[ni,6] + "  " + aTitulos[ni,7] + "   " + Transform(aTitulos[ni,8], "@D" ) + " " + Transform(aTitulos[ni,9], "@E 9,999,999.99" ) + " " + Transform(nTotal, "@E 9,999,999.99" )
Next
nLin++
nLin++
@ nLin++ , 00 psay Repl("-",65)
@ nLin++ , 06 psay OemToAnsi(STR0012) + Transform(nTotGeral, "@E 99,999,999.99" )
@ nLin++ , 00 psay Repl("-",65)
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(cNomeRel)
Endif

Ms_Flush()
Set	Printer to
Set Device  to Screen

Return

