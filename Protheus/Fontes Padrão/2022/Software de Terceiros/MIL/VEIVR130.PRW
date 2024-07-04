#include "Veivr130.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVR130 | Autor ³ Andre Luis Almeida    ³ Data ³ 27/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao das VENDAS de VEICULOS por Clientes              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVR130

Private cStr1   := ""
Private cStr2   := ""
Private aNumVdas:= {}
Private aTotCli := {}

If !(FindFunction("TRepInUse") .And. TRepInUse())
   Return VR130R3() // Executa versão anterior do fonte
Else
	If TRepInUse()
	   oReport := ReportDef()
	   oReport:PrintDialog()
	Endif
Endif

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
*/
Static Function ReportDef()

Local oReport 
Local oSection1 
Local oCell

oReport   := TReport():New("VEIVR130",OemToAnsi(STR0017),"VER130",{|oReport| VR130Imp(oReport)})	//Vendas por clientes

oSection1 := TRSection():New(oReport,OemToAnsi(STR0018),{"SF2","SA1"})	//Secao 1
TRCell():New(oSection1,"",,""   ,"@!" ,220,, {|| substr(cStr1,1,220) } )
//TRCell():New(oSection1,"",,""   ,"@!" ,100,, {|| substr(cStr1,101,100) } )

/*
TRCell():New(oSection1,"A1_COD" ,"SA1","Cliente",,6)
TRCell():New(oSection1,"A1_LOJA","SA1","Loja",,2)
TRCell():New(oSection1,"A1_NOME","SA1","Nome",,30)
TRCell():New(oSection1,"",,"Qtdade"   ,"@!" ,10,, {|| cQtd } )
TRCell():New(oSection1,"",,"Total"    ,"@!" ,20,, {|| cTotal } )
*/

oSection2 := TRSection():New(oReport,OemToAnsi(STR0019),{"SF2","SD2","SA1","VV1"}) //Secao 2
TRCell():New(oSection2,"",,""   ,"@!" ,200,, {|| cStr2 } )
/*
TRCell():New(oSection1,"F2_DOC"    ,"SF2","Doc",,6)
TRCell():New(oSection1,"F2_SERIE"  ,"SF2",,,3)
TRCell():New(oSection1,"F2_EMISSAO","SF2")
TRCell():New(oSection1,"F2_VALBRUT","SF2","Valor")
TRCell():New(oSection1,"VV1_CHASSI","VV1","Chassi")
TRCell():New(oSection1,"VV1_CODMAR","VV1","Marca")
TRCell():New(oSection1,"VV2_DESMOD","VV2","Modelo")
TRCell():New(oSection1,"VV1_FABMOD","VV1","Fab/Mod")
TRCell():New(oSection1,"VVC_DESCRI","VVC","Cor")
TRCell():New(oSection1,"E4_DESCRI" ,"SE4","Pagto")
TRCell():New(oSection1,"",,"Categoria","@!" ,10,, {|| cCatVen } )

TRPosition():New(oSection1,"SA1",3,{|| xFilial("SA1")+SF2->F2_CLIENTE + SF2->F2_LOJA })

TRPosition():New(oSection2,"SD2",1,{|| xFilial("SD2")+SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA })
TRPosition():New(oSection2,"VV1",1,{|| xFilial("VV1")+SD2->D2_COD })
TRPosition():New(oSection2,"VV2",1,{|| xFilial("VV2")+VV1->VV1_CODMAR + VV1->VV1_MODVEI })
TRPosition():New(oSection2,"SF4",1,{|| xFilial("SF4")+SD2->D2_TES })
TRPosition():New(oSection2,"VVC",1,{|| xFilial("SF4")+VV1->VV1_CODMAR + VV1->VV1_CORVEI })
*/

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VR130Imp ³ Autor ³ ANDRE                 ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao do relatorio do TReport                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VR130Imp(oReport)
              
Local nwnk, ni, nj
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)

cCliente:= "INICIAL"
cCor    := "INICIAL"
cCond   := "INICIAL"
cModel  := "INICIAL"
cTipocli:= "INICIAL"

oReport:SetMeter(SF2->(RecCount()))
oSection1:Init(.t.)
oSection2:Init(.t.)

Pergunte("VER130",.f.)

dbSelectArea("SF2")
dbSetOrder(2)
If !Empty(MV_PAR01)
   dbSeek( xFilial("SF2") + MV_PAR01 + MV_PAR02 )
Else
   dbSeek( xFilial("SF2") )
EndIf

Do While !Eof() .and. ( SF2->F2_FILIAL == xFilial("SF2") .and. ( Empty(MV_PAR01) .or. SF2->F2_CLIENTE == MV_PAR01 ) .and. ( Empty(MV_PAR02) .or. SF2->F2_LOJA == MV_PAR02 ))
	If SF2->F2_PREFORI # GetNewPar("MV_PREFVEI","VEI") .or. SF2->F2_TIPO # "N"
	   DbSelectArea("SF2")  
		DbSkip()     	          
		Loop
	EndIf

	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA )
                                                  
	DbSelectArea( "SF4" )	
	DbSetOrder(1)
	DbSeek( xFilial("SF4") + SD2->D2_TES )

   If SF4->F4_DUPLIC # "S" .and. SF4->F4_ESTOQUE # "S"
	   DbSelectArea("SF2")  
		DbSkip()     	          
		Loop
   EndIf

	nPos := aScan(aTotCli,{|x| x[1] == SF2->F2_CLIENTE + "-" + SF2->F2_LOJA })
	If nPos == 0
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA )
		If cTipocli # SA1->A1_TIPOCLI
			cTipocli := SA1->A1_TIPOCLI
			DbSelectArea("SX5")
			DbSetOrder(1)
			DbSeek(xFilial("SX5") + "TC" + SA1->A1_TIPOCLI )
		EndIf
		aAdd(aTotCli,{ SF2->F2_CLIENTE + "-" + SF2->F2_LOJA , SA1->A1_NOME , left(SX5->X5_DESCRI,28) , 1 , SF2->F2_VALBRUT , 999 , 100000000000-SF2->F2_VALBRUT })
   Else
   	aTotCli[nPos,4]++
		aTotCli[nPos,5]+= SF2->F2_VALBRUT
   	aTotCli[nPos,6]--
		aTotCli[nPos,7]-= SF2->F2_VALBRUT
   EndIf

	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1") + SD2->D2_COD )

	If cCor # VV1->VV1_CORVEI
		cCor := VV1->VV1_CORVEI
		DbSelectArea("VVC") 
		DbSetOrder(1)
		DbSeek(xFilial("VVC") + VV1->VV1_CODMAR + VV1->VV1_CORVEI )
	EndIf

 	DbSelectArea( "VV0" )
	DbSetOrder(4)
	DbSeek( xFilial("VV0") + SF2->F2_DOC + SF2->F2_SERIE )    
   
   If cModel # VV1->VV1_MODVEI
		cModel := VV1->VV1_MODVEI
  		DbSelectArea("VV2") 
		DbSetOrder(1)
		DbSeek(xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
	EndIf

	If cCond # SF2->F2_COND
		cCond := SF2->F2_COND
		DbSelectArea("SE4") 
		DbSetOrder(1)
		DbSeek(xFilial("SE4") + SF2->F2_COND )
	EndIf

	If VV0->VV0_CATVEN == "0"
		cCatVen := "A Prazo  "
	ElseIf VV0->VV0_CATVEN == "1"
      cCatVen := OemToAnsi(STR0005)
	ElseIf VV0->VV0_CATVEN == "2"
      cCatVen := OemToAnsi(STR0006)
	ElseIf VV0->VV0_CATVEN == "3"
      cCatVen := OemToAnsi(STR0007)
	ElseIf VV0->VV0_CATVEN == "4"
      cCatVen := OemToAnsi(STR0008)
	ElseIf VV0->VV0_CATVEN == "5"
      cCatVen := OemToAnsi(STR0009)
	ElseIf VV0->VV0_CATVEN == "6"
      cCatVen := OemToAnsi(STR0010)
	ElseIf VV0->VV0_CATVEN == "7"
      cCatVen := OemToAnsi(STR0011)
	ElseIf VV0->VV0_CATVEN == "8"
      cCatVen := OemToAnsi(STR0012)
	ElseIf VV0->VV0_CATVEN == "9"
      cCatVen := OemToAnsi(STR0013)
	Else
      cCatVen := OemToAnsi(STR0014)
	EndIf
	  	
	aAdd(aNumVdas,{ SF2->F2_CLIENTE + "-" + SF2->F2_LOJA , SF2->F2_DOC + "-" + SF2->F2_SERIE , Transform(SF2->F2_EMISSAO,"@D") , Transform(SF2->F2_VALBRUT,"@E 9999,999.99") , VV1->VV1_CHASSI , VV1->VV1_CODMAR + " " + left(VV2->VV2_DESMOD,20) , Transform(VV1->VV1_FABMOD,"@R 9999/9999") , left(VVC->VVC_DESCRI,12) , left(SE4->E4_DESCRI,15) , cCatVen })

   DbSelectArea("SF2")  
	DbSkip()     	          
EndDo             

If MV_PAR03 == 1
	aSort(aTotCli,1,,{|x,y| x[2] < y[2] })
ElseIf MV_PAR03 == 2
	aSort(aTotCli,1,,{|x,y| str(x[6],3) + x[2] < str(y[6],3) + y[2] })
Else
	aSort(aTotCli,1,,{|x,y| str(x[7],12) + x[2] < str(y[7],12) + y[2] })
EndIf             

aSort(aNumVdas,1,,{|x,y| x[1] + x[2] < y[1] + y[2]})

cCliente := "INICIAR"

cStr1 := ""
oSection1:PrintLine()
oReport:SkipLine()

cStr2 := ""
oSection2:PrintLine()
 
For ni:=1 to len(aTotCli)

	If ( cCliente # ( aTotCli[ni,1] ))
		cCliente := ( aTotCli[ni,1] )
		
		cStr1 := aTotCli[ni,1] + "   " + left(aTotCli[ni,2],40) + "   "  + aTotCli[ni,3] + OemToAnsi(STR0016)  + Transform(aTotCli[ni,4],"@E 999") + "   "  + Transform(aTotCli[ni,5],"@E 9999,999.99")
		oSection1:PrintLine()
		oReport:SkipLine()

	EndIf

	nPos := aScan(aNumVdas,{|x| x[1] == cCliente })
	nPos--
	For nj:=1 to aTotCli[ni,4]

		cStr2 := ".    "+aNumVdas[nPos+nj,2] + " " + aNumVdas[nPos+nj,3] + " " + aNumVdas[nPos+nj,4] + " " + aNumVdas[nPos+nj,5] + " " + aNumVdas[nPos+nj,6] + " " + aNumVdas[nPos+nj,7] + " " + aNumVdas[nPos+nj,8] + " " + aNumVdas[nPos+nj,9] + " " + aNumVdas[nPos+nj,10]
		oSection2:PrintLine()
		oReport:SkipLine()
   Next
Next                                                  

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VR130R3  | Autor ³ Andre Luis Almeida    ³ Data ³ 27/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao das VENDAS de VEICULOS por Clientes              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VR130R3()

cDesc1    := OemToAnsi(STR0001)
cDesc2    := ""
cDesc3    := ""
cAlias    := "SF2"
aRegistros:= {}
nLin      := 0
aPag      := 1
nIte      := 1
aReturn   := { OemToAnsi(STR0002), 1,OemToAnsi(STR0003), 2, 2, 1, "",1 }
cTamanho  := "M"           // P/M/G
Limite    := 132           // 80/132/220
aOrdem    := {}           // Ordem do Relatorio
cTitulo   := OemToAnsi(STR0004)
cNomeProg := "VEIVR130"
cNomeRel  := "VEIVR130"
nLastKey  := 0
nCaracter := 15
cabec1    := ""
cabec2    := ""
cPerg     := "VER130"

cNomeRel:=SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,,cTamanho)
If nLastKey == 27
   Return
EndIf     
PERGUNTE("VER130",.f.)
                        
SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| FS_IMPVDACLI(@lEnd,cNomeRel,cAlias) } , cTitulo )

If aReturn[5] == 1
   OurSpool( cNomeRel )
EndIf

MS_Flush()
Return
           
Static Function FS_IMPVDACLI()

Local nj, ni
                  
Private cbTxt    := Space(10)
Private cbCont   := 0
Private cString  := "SB2"
Private Li       := 80
Private m_Pag    := 1
Private wnRel    := "VEIVR130"
Private aNumVdas := {}
Private aTotCli  := {}
Private cCatVen  := ""

Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      

cCliente:= "INICIAL"
cCor    := "INICIAL"
cCond   := "INICIAL"
cModel  := "INICIAL"
cTipocli:= "INICIAL"
nCont   := 0
ni      := 0
nTitcli := 0

DbSelectArea("SF2")
DbSetOrder(2)
If !Empty(MV_PAR01)
   DbSeek( xFilial("SF2") + MV_PAR01 + MV_PAR02 )
   SetRegua( 1000 )
Else
   DbSeek( xFilial("SF2") )
   SetRegua( RecCount() )
EndIf

Do While !Eof() .and. ( SF2->F2_FILIAL == xFilial("SF2") .and. ( Empty(MV_PAR01) .or. SF2->F2_CLIENTE == MV_PAR01 ) .and. ( Empty(MV_PAR02) .or. SF2->F2_LOJA == MV_PAR02 ))
	IncRegua()
	nCont++
	If SF2->F2_PREFORI # GetNewPar("MV_PREFVEI","VEI") .or. SF2->F2_TIPO # "N"
	   DbSelectArea("SF2")  
		DbSkip()     	          
		Loop
	EndIf

	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA )
                                                  
	DbSelectArea( "SF4" )	
	DbSetOrder(1)
	DbSeek( xFilial("SF4") + SD2->D2_TES )

   If SF4->F4_DUPLIC # "S" .and. SF4->F4_ESTOQUE # "S"
	   DbSelectArea("SF2")  
		DbSkip()     	          
		Loop
   EndIf

	nPos := aScan(aTotCli,{|x| x[1] == SF2->F2_CLIENTE + "-" + SF2->F2_LOJA })
	If nPos == 0
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA )
		If cTipocli # SA1->A1_TIPOCLI
			cTipocli := SA1->A1_TIPOCLI
			DbSelectArea("SX5")
			DbSetOrder(1)
			DbSeek(xFilial("SX5") + "TC" + SA1->A1_TIPOCLI )
		EndIf
		aAdd(aTotCli,{ SF2->F2_CLIENTE + "-" + SF2->F2_LOJA , SA1->A1_NOME , left(SX5->X5_DESCRI,28) , 1 , SF2->F2_VALBRUT , 999 , 100000000000-SF2->F2_VALBRUT })
   Else
   	aTotCli[nPos,4]++
		aTotCli[nPos,5]+= SF2->F2_VALBRUT
   	aTotCli[nPos,6]--
		aTotCli[nPos,7]-= SF2->F2_VALBRUT
   EndIf

	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1") + SD2->D2_COD )

	If cCor # VV1->VV1_CORVEI
		cCor := VV1->VV1_CORVEI
		DbSelectArea("VVC") 
		DbSetOrder(1)
		DbSeek(xFilial("VVC") + VV1->VV1_CODMAR + VV1->VV1_CORVEI )
	EndIf

 	DbSelectArea( "VV0" )
	DbSetOrder(4)
	DbSeek( xFilial("VV0") + SF2->F2_DOC + SF2->F2_SERIE )    
   
   If cModel # VV1->VV1_MODVEI
		cModel := VV1->VV1_MODVEI
  		DbSelectArea("VV2") 
		DbSetOrder(1)
		DbSeek(xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
	EndIf

	If cCond # SF2->F2_COND
		cCond := SF2->F2_COND
		DbSelectArea("SE4") 
		DbSetOrder(1)
		DbSeek(xFilial("SE4") + SF2->F2_COND )
	EndIf

	If VV0->VV0_CATVEN == "0"
		cCatVen := "A Prazo  "
	ElseIf VV0->VV0_CATVEN == "1"
                cCatVen := OemToAnsi(STR0005)
	ElseIf VV0->VV0_CATVEN == "2"
                cCatVen := OemToAnsi(STR0006)
	ElseIf VV0->VV0_CATVEN == "3"
                cCatVen := OemToAnsi(STR0007)
	ElseIf VV0->VV0_CATVEN == "4"
                cCatVen := OemToAnsi(STR0008)
	ElseIf VV0->VV0_CATVEN == "5"
                cCatVen := OemToAnsi(STR0009)
	ElseIf VV0->VV0_CATVEN == "6"
                cCatVen := OemToAnsi(STR0010)
	ElseIf VV0->VV0_CATVEN == "7"
                cCatVen := OemToAnsi(STR0011)
	ElseIf VV0->VV0_CATVEN == "8"
                cCatVen := OemToAnsi(STR0012)
	ElseIf VV0->VV0_CATVEN == "9"
                cCatVen := OemToAnsi(STR0013)
	Else
                cCatVen := OemToAnsi(STR0014)
	EndIf
	  	
	aAdd(aNumVdas,{ SF2->F2_CLIENTE + "-" + SF2->F2_LOJA , SF2->F2_DOC + "-" + SF2->F2_SERIE , Transform(SF2->F2_EMISSAO,"@D") , Transform(SF2->F2_VALBRUT,"@E 9999,999.99") , VV1->VV1_CHASSI , VV1->VV1_CODMAR + " " + left(VV2->VV2_DESMOD,20) , Transform(VV1->VV1_FABMOD,"@R 9999/9999") , left(VVC->VVC_DESCRI,12) , left(SE4->E4_DESCRI,15) , cCatVen })

   DbSelectArea("SF2")  
	DbSkip()     	          
EndDo             

If MV_PAR03 == 1
	aSort(aTotCli,1,,{|x,y| x[2] < y[2] })
ElseIf MV_PAR03 == 2
	aSort(aTotCli,1,,{|x,y| str(x[6],3) + x[2] < str(y[6],3) + y[2] })
Else
	aSort(aTotCli,1,,{|x,y| str(x[7],12) + x[2] < str(y[7],12) + y[2] })
EndIf             

aSort(aNumVdas,1,,{|x,y| x[1] + x[2] < y[1] + y[2]})

cCliente := "INICIAR"
 
For ni:=1 to len(aTotCli)

	If ( cCliente # ( aTotCli[ni,1] ))
		cCliente := ( aTotCli[ni,1] )
	  	nLin++
	  	nLin++
	  	If nLin > 55
			nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      
	   EndIf
	  	@ nLin++ , 00 psay repl("-",132)
      @ nLin++ , 01 psay OemToAnsi(STR0015) + aTotCli[ni,1] + "   " + left(aTotCli[ni,2],40) + "   "  + aTotCli[ni,3] + OemToAnsi(STR0016)  + Transform(aTotCli[ni,4],"@E 999") + "   "  + Transform(aTotCli[ni,5],"@E 9999,999.99")
	  	@ nLin++ , 00 psay repl("-",132)
	EndIf

	If nLin > 63
		nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      
   EndIf

	nPos := aScan(aNumVdas,{|x| x[1] == cCliente })
	nPos--
	For nj:=1 to aTotCli[ni,4]
		@ nLin++ , 00 psay aNumVdas[nPos+nj,2] + aNumVdas[nPos+nj,3] + " " + aNumVdas[nPos+nj,4] + " " + aNumVdas[nPos+nj,5] + " " + aNumVdas[nPos+nj,6] + " " + aNumVdas[nPos+nj,7] + " " + aNumVdas[nPos+nj,8] + " " + aNumVdas[nPos+nj,9] + " " + aNumVdas[nPos+nj,10]
   Next
Next                                                  

For ni := nCont to 1000
	IncRegua()
Next

Set Printer to
Set Device  to Screen

Return
