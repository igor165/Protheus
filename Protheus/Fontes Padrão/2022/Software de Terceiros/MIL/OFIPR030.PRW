#Include "OFIPR030.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFIPR030 ºAutor  ³Andre Luis Almeida  º Data ³  22/04/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Posicao Contas a Pagar por Carteira           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MIL                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIPR030
Local oReport
Local aArea := GetArea()
Private cImp := ""
If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	FS_OPR030R3()
EndIf
RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef³ Autor ³ Andre Luis Almeida    ³ Data ³ 07/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio usando o TReport                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oCell

oReport := TReport():New("OFIPR030",STR0001,"",{|oReport| OPR030IMP(oReport)})

oSection1 := TRSection():New(oReport,OemToAnsi(STR0013),{}) //Secao 1
TRCell():New(oSection1,"",,"","@!",132,,{|| cImp })

Return oReport
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OPR030IMP³ Autor ³ Andre Luis Almeida    ³ Data ³ 07/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao do relatorio do TReport                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                     
Function OPR030IMP(oReport)
Local oSection1 := oReport:Section(1)
Local nDias     := 0
Local nPos      := 0
Local ni        := 0
Local aNumCP    := {}
Local aNumCPT   := {}
aAdd(aNumCPT,{ OemToAnsi(STR0005) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
DbSelectArea("SE2")
DbSetOrder(1)
DbSeek( xFilial("SE2") )
oReport:SetMeter(RecCount())
oSection1:Init()
While !Eof() .and. !oReport:Cancel() .and. SE2->E2_FILIAL == xFilial("SE2")
	oReport:IncMeter()
	If !(SE2->E2_SALDO>0)
		DbSelectArea("SE2")
		DbSkip()
		Loop
	EndIf
	nDias := (SE2->E2_VENCTO-dDataBase)
	nPos := 0
	nPos := aScan(aNumCP,{|x| x[1] == SE2->E2_PORTADO })
	If nPos == 0
		aAdd(aNumCP,{ SE2->E2_PORTADO , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
		nPos := aScan(aNumCP,{|x| x[1] == SE2->E2_PORTADO })
	EndIf
	Do Case
		Case (nDias < -60)		//"Vencidos a mais de 60 dias"
		   aNumCP[nPos,2]++
		   aNumCP[nPos,3]+=SE2->E2_SALDO
		   aNumCP[nPos,12]++
		   aNumCP[nPos,13]+=SE2->E2_SALDO
		   aNumCPT[1,2]++
		   aNumCPT[1,3]+=SE2->E2_SALDO
		   aNumCPT[1,12]++
		   aNumCPT[1,13]+=SE2->E2_SALDO
		Case (nDias < -30)		//"Vencidos a mais de 30 dias e menos de 61 dias "
		   aNumCP[nPos,4]++
		   aNumCP[nPos,5]+=SE2->E2_SALDO
		   aNumCP[nPos,12]++
		   aNumCP[nPos,13]+=SE2->E2_SALDO
		   aNumCPT[1,4]++
		   aNumCPT[1,5]+=SE2->E2_SALDO
		   aNumCPT[1,12]++
		   aNumCPT[1,13]+=SE2->E2_SALDO
		Case (nDias < -20)		//"Vencidos a mais de 20 dias e menos de 31 dias "
		   aNumCP[nPos,6]++
		   aNumCP[nPos,7]+=SE2->E2_SALDO
		   aNumCP[nPos,12]++
		   aNumCP[nPos,13]+=SE2->E2_SALDO
		   aNumCPT[1,6]++
		   aNumCPT[1,7]+=SE2->E2_SALDO
		   aNumCPT[1,12]++
		   aNumCPT[1,13]+=SE2->E2_SALDO
		Case (nDias < -10)		//"Vencidos a mais de 10 dias e menos de 21 dias "
		   aNumCP[nPos,8]++
		   aNumCP[nPos,9]+=SE2->E2_SALDO
		   aNumCP[nPos,12]++
		   aNumCP[nPos,13]+=SE2->E2_SALDO
		   aNumCPT[1,8]++
		   aNumCPT[1,9]+=SE2->E2_SALDO
		   aNumCPT[1,12]++
		   aNumCPT[1,13]+=SE2->E2_SALDO
		Case (nDias < -2)		//"Vencidos a mais de  2 dias e menos de 11 dias "
		   aNumCP[nPos,10]++
		   aNumCP[nPos,11]+=SE2->E2_SALDO
		   aNumCP[nPos,12]++
		   aNumCP[nPos,13]+=SE2->E2_SALDO
		   aNumCPT[1,10]++
		   aNumCPT[1,11]+=SE2->E2_SALDO
		   aNumCPT[1,12]++
		   aNumCPT[1,13]+=SE2->E2_SALDO
		Case (nDias < 0)			//"Vencidos a mais de  1 dia e menos de   2 dias "
		   aNumCP[nPos,14]++
		   aNumCP[nPos,15]+=SE2->E2_SALDO
		   aNumCPT[1,14]++
		   aNumCPT[1,15]+=SE2->E2_SALDO
		Case (nDias < 31)			//"A Vencer ate 30 dias "
		   aNumCP[nPos,16]++
		   aNumCP[nPos,17]+=SE2->E2_SALDO
		   aNumCPT[1,16]++
		   aNumCPT[1,17]+=SE2->E2_SALDO
		OtherWise					//"A Vencer a partir de 30 dias "
		   aNumCP[nPos,18]++
		   aNumCP[nPos,19]+=SE2->E2_SALDO
		   aNumCPT[1,18]++
		   aNumCPT[1,19]+=SE2->E2_SALDO
	EndCase
	aNumCP[nPos,20]++
	aNumCP[nPos,21]+=SE2->E2_SALDO
	aNumCPT[1,20]++
	aNumCPT[1,21]+=SE2->E2_SALDO
	DbSelectArea("SE2")
	DbSkip()
EndDo
oReport:SkipLine()
cImp := Repl("-",132)
oSection1:PrintLine()
oReport:SkipLine()
cImp := "."+space(26)+OemToAnsi(STR0006)
oSection1:PrintLine()
oReport:SkipLine()
cImp := Repl("-",132)
oSection1:PrintLine()
oReport:SkipLine()
oReport:SkipLine()
cImp := OemToAnsi(STR0007)
oSection1:PrintLine()
cImp := "."+OemToAnsi(substr(STR0008,2))
oSection1:PrintLine()
cImp := "."+OemToAnsi(substr(STR0009,2))
oSection1:PrintLine()
cImp := OemToAnsi(STR0007)
oSection1:PrintLine()
oReport:SkipLine()
aSort(aNumCP,1,,{|x,y| x[1] < y[1]})
For ni:=1 to len(aNumCP)
	cImp := ".***  "+left(aNumCP[ni,1],3)+"  *** "+Transform(aNumCP[ni,3] ,"@E 9999999,999")+Transform(aNumCP[ni,5] ,"@E 9999999,999")+Transform(aNumCP[ni,7] ,"@E 9999999,999")
	cImp += Transform(aNumCP[ni,9] ,"@E 9999999,999")+Transform(aNumCP[ni,11],"@E 9999999,999")+Transform(aNumCP[ni,13],"@E 9999999,999.99")+Transform(aNumCP[ni,15],"@E 9999999,999")
	cImp += Transform(aNumCP[ni,17],"@E 9999999,999")+Transform(aNumCP[ni,19],"@E 9999999,999")+Transform(aNumCP[ni,21],"@E 9999999,999.99")
	oSection1:PrintLine()
	DbSelectArea("SA6")
	DbSetOrder(1)
	DbSeek( xFilial("SA6") + aNumCP[ni,1] )
	cImp := "."+left(SA6->A6_NOME,15)+"("+Transform(aNumCP[ni,2],"@E 9999")+")"+Transform(((aNumCP[ni,3]/aNumCP[ni,13])*100),"@E 999")+"% ("+Transform(aNumCP[ni,4],"@E 9999")+")"+Transform(((aNumCP[ni,5]/aNumCP[ni,13])*100),"@E 999")+"%"
	cImp += " ("+Transform(aNumCP[ni,6],"@E 9999")+")"+Transform(((aNumCP[ni,7]/aNumCP[ni,13])*100),"@E 999")+"% ("+Transform(aNumCP[ni,8],"@E 9999")+")"+Transform(((aNumCP[ni,9]/aNumCP[ni,13])*100),"@E 999")+"%"
	cImp += " ("+Transform(aNumCP[ni,10],"@E 9999")+")"+Transform(((aNumCP[ni,11]/aNumCP[ni,13])*100),"@E 999")+"%      ("+Transform(aNumCP[ni,12],"@E 9999")+")     ("+Transform(aNumCP[ni,14],"@E 9999")+") "
	cImp += "    ("+Transform(aNumCP[ni,16],"@E 99999")+")    ("+Transform(aNumCP[ni,18],"@E 99999")+")      ("+Transform(aNumCP[ni,20],"@E 99999")+")"
	oSection1:PrintLine()
	oReport:SkipLine()
Next
cImp := OemToAnsi(STR0010)
oSection1:PrintLine()
cImp := "."+OemToAnsi(substr(STR0011,2))+Transform(aNumCPT[1,3],"@E 9999999,999")+Transform(aNumCPT[1,5],"@E 9999999,999")+Transform(aNumCPT[1,7],"@E 9999999,999")+Transform(aNumCPT[1,9],"@E 9999999,999")+Transform(aNumCPT[1,11],"@E 9999999,999")
cImp += Transform(aNumCPT[1,13],"@E 9999999,999.99")+Transform(aNumCPT[1,15],"@E 9999999,999")+Transform(aNumCPT[1,17],"@E 9999999,999")+Transform(aNumCPT[1,19],"@E 9999999,999")+Transform(aNumCPT[1,21],"@E 9999999,999.99")
oSection1:PrintLine()
cImp := "."+OemToAnsi(substr(STR0012,2))+" ("+Transform(aNumCPT[1,2],"@E 9999")+")"+Transform(((aNumCPT[1,3]/aNumCPT[1,13])*100),"@E 999")+"% ("+Transform(aNumCPT[1,4],"@E 9999")+")"+Transform(((aNumCPT[1,5]/aNumCPT[1,13])*100),"@E 999")+"% ("+Transform(aNumCPT[1,6],"@E 9999")+")"
cImp += Transform(((aNumCPT[1,7]/aNumCPT[1,13])*100),"@E 999")+"% ("+Transform(aNumCPT[1,8],"@E 9999")+")"+Transform(((aNumCPT[1,9]/aNumCPT[1,13])*100),"@E 999")+"% ("+Transform(aNumCPT[1,10],"@E 9999")+")"+Transform(((aNumCPT[1,11]/aNumCPT[1,13])*100),"@E 999")+"%"
cImp += "      ("+Transform(aNumCPT[1,12],"@E 9999")+")     ("+Transform(aNumCPT[1,14],"@E 9999")+")     ("+Transform(aNumCPT[1,16],"@E 99999")+")    ("+Transform(aNumCPT[1,18],"@E 99999")+")      ("+Transform(aNumCPT[1,20],"@E 99999")+")"
oSection1:PrintLine()
cImp := OemToAnsi(STR0010)
oSection1:PrintLine()
oSection1:Finish()
Return Nil


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function FS_OPR030R3()
cDesc1    := OemToAnsi(STR0001)  // "Relatorio de Posicao Contas a Pagar por Carteira"
cDesc2    := ""
cDesc3    := ""
cAlias    := "SE2"
aRegistros:= {}
nLin      := 0
aPag      := 1
nIte      := 1
aReturn   := { OemToAnsi(STR0002), 1,OemToAnsi(STR0003), 1, 2, 1, "",1 }
cTamanho  := "M"          // P/M/G
Limite    := 132           // 80/132/220
aOrdem    := {}          // Ordem do Relatorio
cTitulo   := OemToAnsi(STR0004)
cNomeProg := "OFIPR030"
cNomeRel  := "OFIPR030"
nLastKey  := 0
nCaracter := 15
cabec1    := ""
cabec2    := ""
cNomeRel:=SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
   Return
EndIf     
SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| FS_IMPM_RCPCAR(@lEnd,cNomeRel,cAlias) } , cTitulo )
If aReturn[5] == 1
   OurSpool( cNomeRel )
EndIf
MS_Flush()
Return
//////////////////////////////////////////////////////           
Static Function FS_IMPM_RCPCAR()
Local   ni       := 0           
Private cbTxt    := Space(10)
Private cbCont   := 0
Private cString  := "SE2"
Private Li       := 132
Private m_Pag    := 1
Private wnRel    := "OFIPR030"
Private aNumCP   := {}
Private aNumCPT  := {}
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer
nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      
DbSelectArea("SE2") 
DbSetOrder(1)
DbSeek( xFilial("SE2") )    
SetRegua( RecCount() )       
aAdd(aNumCPT,{ OemToAnsi(STR0005) , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 })
Do While !Eof() .and. SE2->E2_FILIAL == xFilial("SE2")
	IncRegua()
	If !(SE2->E2_SALDO>0)
	   DbSelectArea("SE2") 
		DbSkip()     	          
      Loop
   EndIf 
   nDias := (SE2->E2_VENCTO-dDataBase)
   nPos := 0
	nPos := aScan(aNumCP,{|x| x[1] == SE2->E2_PORTADO })
	If nPos == 0 
		aAdd(aNumCP,{ SE2->E2_PORTADO , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) 
		nPos := aScan(aNumCP,{|x| x[1] == SE2->E2_PORTADO })
   EndIf
	Do Case 
		Case (nDias < -60	)		//"Vencidos a mais de 60 dias"
		   aNumCP[nPos,2]++
		   aNumCP[nPos,3]+=SE2->E2_SALDO
		   aNumCP[nPos,12]++
		   aNumCP[nPos,13]+=SE2->E2_SALDO
		   aNumCPT[1,2]++
		   aNumCPT[1,3]+=SE2->E2_SALDO
		   aNumCPT[1,12]++
		   aNumCPT[1,13]+=SE2->E2_SALDO
		Case (nDias < -30)		//"Vencidos a mais de 30 dias e menos de 61 dias "
		   aNumCP[nPos,4]++
		   aNumCP[nPos,5]+=SE2->E2_SALDO
		   aNumCP[nPos,12]++
		   aNumCP[nPos,13]+=SE2->E2_SALDO
		   aNumCPT[1,4]++
		   aNumCPT[1,5]+=SE2->E2_SALDO
		   aNumCPT[1,12]++
		   aNumCPT[1,13]+=SE2->E2_SALDO
		Case (nDias < -20)		//"Vencidos a mais de 20 dias e menos de 31 dias "
		   aNumCP[nPos,6]++
		   aNumCP[nPos,7]+=SE2->E2_SALDO
		   aNumCP[nPos,12]++
		   aNumCP[nPos,13]+=SE2->E2_SALDO
		   aNumCPT[1,6]++
		   aNumCPT[1,7]+=SE2->E2_SALDO
		   aNumCPT[1,12]++
		   aNumCPT[1,13]+=SE2->E2_SALDO
		Case (nDias < -10)		//"Vencidos a mais de 10 dias e menos de 21 dias "
		   aNumCP[nPos,8]++
		   aNumCP[nPos,9]+=SE2->E2_SALDO                                
		   aNumCP[nPos,12]++
		   aNumCP[nPos,13]+=SE2->E2_SALDO
		   aNumCPT[1,8]++
		   aNumCPT[1,9]+=SE2->E2_SALDO
		   aNumCPT[1,12]++
		   aNumCPT[1,13]+=SE2->E2_SALDO
		Case (nDias < -2)		//"Vencidos a mais de  2 dias e menos de 11 dias "
		   aNumCP[nPos,10]++
		   aNumCP[nPos,11]+=SE2->E2_SALDO                             
		   aNumCP[nPos,12]++
		   aNumCP[nPos,13]+=SE2->E2_SALDO
		   aNumCPT[1,10]++
		   aNumCPT[1,11]+=SE2->E2_SALDO
		   aNumCPT[1,12]++
		   aNumCPT[1,13]+=SE2->E2_SALDO
		Case (nDias < 0)			//"Vencidos a mais de  1 dia e menos de   2 dias "
		   aNumCP[nPos,14]++
		   aNumCP[nPos,15]+=SE2->E2_SALDO
		   aNumCPT[1,14]++
		   aNumCPT[1,15]+=SE2->E2_SALDO
		Case (nDias < 31)			//"A Vencer ate 30 dias "
		   aNumCP[nPos,16]++
		   aNumCP[nPos,17]+=SE2->E2_SALDO
		   aNumCPT[1,16]++
		   aNumCPT[1,17]+=SE2->E2_SALDO
		OtherWise					//"A Vencer a partir de 30 dias "
		   aNumCP[nPos,18]++
		   aNumCP[nPos,19]+=SE2->E2_SALDO
		   aNumCPT[1,18]++
		   aNumCPT[1,19]+=SE2->E2_SALDO
	EndCase                                        
   aNumCP[nPos,20]++
   aNumCP[nPos,21]+=SE2->E2_SALDO
   aNumCPT[1,20]++
   aNumCPT[1,21]+=SE2->E2_SALDO
   DbSelectArea("SE2") 
	DbSkip()     	          
EndDo             
nLin++
@ nLin++ , 00 psay Repl("-",132) 
nLin++
@ nLin++ , 27 psay OemToAnsi(STR0006)
nLin++
@ nLin++ , 00 psay Repl("-",132) 
nLin++
nLin++
@ nLin++ , 00 psay OemToAnsi(STR0007)
@ nLin++ , 00 psay OemToAnsi(STR0008)
@ nLin++ , 00 psay OemToAnsi(STR0009)
@ nLin++ , 00 psay OemToAnsi(STR0007)
aSort(aNumCP,1,,{|x,y| x[1] < y[1]})
nLin++              
For ni:=1 to len(aNumCP)
		@ nLin++ , 00 psay " ***  " + left(aNumCP[ni,1],3) + "  *** " ;
					+ Transform(aNumCP[ni,3] ,"@E 9999999,999") ;
					+ Transform(aNumCP[ni,5] ,"@E 9999999,999") ;
					+ Transform(aNumCP[ni,7] ,"@E 9999999,999") ;
					+ Transform(aNumCP[ni,9] ,"@E 9999999,999") ;
					+ Transform(aNumCP[ni,11],"@E 9999999,999") ;
					+ Transform(aNumCP[ni,13],"@E 9999999,999.99") ;
					+ Transform(aNumCP[ni,15],"@E 9999999,999") ;
					+ Transform(aNumCP[ni,17],"@E 9999999,999") ;
					+ Transform(aNumCP[ni,19],"@E 9999999,999") ;
					+ Transform(aNumCP[ni,21],"@E 9999999,999.99") 
		DbSelectArea("SA6")  
		DbSetOrder(1)
		DbSeek( xFilial("SA6") + aNumCP[ni,1] )
		@ nLin++ , 00 psay left(SA6->A6_NOME,15) ;
					+ " (" + Transform(aNumCP[ni,2] ,"@E 9999") + ")" + Transform(((aNumCP[ni,3]/aNumCP[ni,13])*100) ,"@E 999") + "%" ;
					+ " (" + Transform(aNumCP[ni,4] ,"@E 9999") + ")" + Transform(((aNumCP[ni,5]/aNumCP[ni,13])*100) ,"@E 999") + "%" ;
					+ " (" + Transform(aNumCP[ni,6] ,"@E 9999") + ")" + Transform(((aNumCP[ni,7]/aNumCP[ni,13])*100) ,"@E 999") + "%" ;
					+ " (" + Transform(aNumCP[ni,8] ,"@E 9999") + ")" + Transform(((aNumCP[ni,9]/aNumCP[ni,13])*100) ,"@E 999") + "%" ;
					+ " (" + Transform(aNumCP[ni,10],"@E 9999") + ")" + Transform(((aNumCP[ni,11]/aNumCP[ni,13])*100),"@E 999") + "%" ;
					+ "      (" + Transform(aNumCP[ni,12],"@E 9999")  + ")  ";
					+ "   (" + Transform(aNumCP[ni,14],"@E 9999")  + ") " ;
					+ "    (" + Transform(aNumCP[ni,16],"@E 99999") + ") " ;
					+ "   (" + Transform(aNumCP[ni,18],"@E 99999") + ") " ;
					+ "     (" + Transform(aNumCP[ni,20],"@E 99999") + ")"
		nLin++
Next
@ nLin++ , 00 psay OemToAnsi(STR0010)
@ nLin++ , 00 psay OemToAnsi(STR0011) ;
			+ Transform(aNumCPT[1,3] ,"@E 9999999,999") ;
			+ Transform(aNumCPT[1,5] ,"@E 9999999,999") ;
			+ Transform(aNumCPT[1,7] ,"@E 9999999,999") ;
			+ Transform(aNumCPT[1,9] ,"@E 9999999,999") ;
			+ Transform(aNumCPT[1,11],"@E 9999999,999") ;
			+ Transform(aNumCPT[1,13],"@E 9999999,999.99") ;
			+ Transform(aNumCPT[1,15],"@E 9999999,999") ;
			+ Transform(aNumCPT[1,17],"@E 9999999,999") ;
			+ Transform(aNumCPT[1,19],"@E 9999999,999") ;
			+ Transform(aNumCPT[1,21],"@E 9999999,999.99") 
@ nLin++ , 00 psay OemToAnsi(STR0012) ;
			+ " (" + Transform(aNumCPT[1,2] ,"@E 9999") + ")" + Transform(((aNumCPT[1,3]/aNumCPT[1,13])*100) ,"@E 999") + "%" ;
			+ " (" + Transform(aNumCPT[1,4] ,"@E 9999") + ")" + Transform(((aNumCPT[1,5]/aNumCPT[1,13])*100) ,"@E 999") + "%" ;
			+ " (" + Transform(aNumCPT[1,6] ,"@E 9999") + ")" + Transform(((aNumCPT[1,7]/aNumCPT[1,13])*100) ,"@E 999") + "%" ;
			+ " (" + Transform(aNumCPT[1,8] ,"@E 9999") + ")" + Transform(((aNumCPT[1,9]/aNumCPT[1,13])*100) ,"@E 999") + "%" ;
			+ " (" + Transform(aNumCPT[1,10],"@E 9999") + ")" + Transform(((aNumCPT[1,11]/aNumCPT[1,13])*100),"@E 999") + "%" ;
			+ "      (" + Transform(aNumCPT[1,12],"@E 9999")  + ")  ";
			+ "   (" + Transform(aNumCPT[1,14],"@E 9999")  + ") " ;
			+ "    (" + Transform(aNumCPT[1,16],"@E 99999") + ") " ;
			+ "   (" + Transform(aNumCPT[1,18],"@E 99999") + ") " ;
			+ "     (" + Transform(aNumCPT[1,20],"@E 99999") + ")"
@ nLin++ , 00 psay OemToAnsi(STR0010)
Set Printer to
Set Device  to Screen
Return             
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////