#Include "OFIPR050.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFIPR050 ºAutor  ³Andre Luis Almeida  º Data ³  16/04/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio de Posicao Contas a Receber por Carteira          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MIL                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIPR050
Local oReport
Local aArea := GetArea()
Private cImp := ""
If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	FS_OPR050R3()
EndIf
RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef³ Autor ³ Andre Luis Almeida    ³ Data ³ 11/07/06 ³±±
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

oReport := TReport():New("OFIPR050",STR0001,"",{|oReport| OPR050IMP(oReport)})

oSection1 := TRSection():New(oReport,OemToAnsi(STR0013),{}) //Secao 1
TRCell():New(oSection1,"",,"","@!",132,,{|| cImp })

Return oReport
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OPR050IMP³ Autor ³ Andre Luis Almeida    ³ Data ³ 11/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao do relatorio do TReport                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                     
Function OPR050IMP(oReport)
Local oSection1 := oReport:Section(1)
Local nDias     := 0
Local nPos      := 0
Local nPos2     := 0
Local ni        := 0
Local nj        := 0
Local aGrpCR    := {}
Local aNumCR    := {}
Local aNumCRT   := {}
Local cTipTit := Left(Alltrim(GetNewPar("MV_TIPPER","TP"))+space(3),Len(SE1->E1_TIPO)) // Tipo de Titulo Provisorio
aAdd(aNumCRT,{ STR0005 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) 
DbSelectArea("SE1")
DbSetOrder(1)
DbSeek( xFilial("SE1") )
oReport:SetMeter(RecCount())
oSection1:Init()
While !Eof() .and. !oReport:Cancel() .and. SE1->E1_FILIAL == xFilial("SE1")
	oReport:IncMeter()
   If !(SE1->E1_SALDO>0)
      DbSelectArea("SE1")
      DbSkip()
      Loop
   EndIf 
   If SE1->E1_TIPO==cTipTit
      DbSelectArea("SE1")
      DbSkip()
      Loop
   EndIf 
   nDias := (SE1->E1_VENCTO-dDataBase)
   nPos2 := 0
   nPos2 := aScan(aGrpCR,{|x| x[1]+ x[22] == SE1->E1_PORTADO + SE1->E1_PREFORI +" "+ SE1->E1_PREFIXO })
   If nPos2 == 0
      aAdd(aGrpCR,{ SE1->E1_PORTADO , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , SE1->E1_PREFORI +" "+ SE1->E1_PREFIXO })
      nPos2 := len(aGrpCR)
   EndIf
   nPos := 0
	nPos := aScan(aNumCR,{|x| x[1] == SE1->E1_PORTADO })
	If nPos == 0 
		aAdd(aNumCR,{ SE1->E1_PORTADO , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) 
		nPos := aScan(aNumCR,{|x| x[1] == SE1->E1_PORTADO })
   EndIf 
   If year(SE1->E1_VENCTO) < year(dDataBase)
	   aGrpCR[nPos2,2]++
   	aGrpCR[nPos2,3]+=SE1->E1_SALDO
   	aNumCR[nPos,2]++
	   aNumCR[nPos,3]+=SE1->E1_SALDO
	   aNumCRT[1,2]++
   	aNumCRT[1,3]+=SE1->E1_SALDO
	EndIf
	Do Case 
		Case (nDias < -60)	//"Vencidos a mais de 60 dias"
		   aGrpCR[nPos2,4]++
		   aGrpCR[nPos2,5]+=SE1->E1_SALDO
		   aGrpCR[nPos2,12]++
		   aGrpCR[nPos2,13]+=SE1->E1_SALDO
		   aNumCR[nPos,4]++
		   aNumCR[nPos,5]+=SE1->E1_SALDO
		   aNumCR[nPos,12]++
		   aNumCR[nPos,13]+=SE1->E1_SALDO
		   aNumCRT[1,4]++
		   aNumCRT[1,5]+=SE1->E1_SALDO
		   aNumCRT[1,12]++
		   aNumCRT[1,13]+=SE1->E1_SALDO
		Case (nDias < -30)	//"Vencidos a mais de 30 dias e menos de 61 dias"
		   aGrpCR[nPos2,6]++
		   aGrpCR[nPos2,7]+=SE1->E1_SALDO
		   aGrpCR[nPos2,12]++
		   aGrpCR[nPos2,13]+=SE1->E1_SALDO
		   aNumCR[nPos,6]++
		   aNumCR[nPos,7]+=SE1->E1_SALDO
		   aNumCR[nPos,12]++
		   aNumCR[nPos,13]+=SE1->E1_SALDO
		   aNumCRT[1,6]++
		   aNumCRT[1,7]+=SE1->E1_SALDO
		   aNumCRT[1,12]++
		   aNumCRT[1,13]+=SE1->E1_SALDO
		Case (nDias < -15)	//"Vencidos a mais de 15 dias e menos de 31 dias"
		   aGrpCR[nPos2,8]++
		   aGrpCR[nPos2,9]+=SE1->E1_SALDO
		   aGrpCR[nPos2,12]++
		   aGrpCR[nPos2,13]+=SE1->E1_SALDO
		   aNumCR[nPos,8]++
		   aNumCR[nPos,9]+=SE1->E1_SALDO                                
		   aNumCR[nPos,12]++
		   aNumCR[nPos,13]+=SE1->E1_SALDO
		   aNumCRT[1,8]++
		   aNumCRT[1,9]+=SE1->E1_SALDO
		   aNumCRT[1,12]++
		   aNumCRT[1,13]+=SE1->E1_SALDO
		Case (nDias < -2)		//"Vencidos a mais de  2 dias e menos de 16 dias"
		   aGrpCR[nPos2,10]++
		   aGrpCR[nPos2,11]+=SE1->E1_SALDO
		   aGrpCR[nPos2,12]++
		   aGrpCR[nPos2,13]+=SE1->E1_SALDO
		   aNumCR[nPos,10]++
		   aNumCR[nPos,11]+=SE1->E1_SALDO                             
		   aNumCR[nPos,12]++
		   aNumCR[nPos,13]+=SE1->E1_SALDO
		   aNumCRT[1,10]++
		   aNumCRT[1,11]+=SE1->E1_SALDO
		   aNumCRT[1,12]++
		   aNumCRT[1,13]+=SE1->E1_SALDO
		Case (nDias < 0)		//"Vencidos a mais de  1 dia e menos de  2 dias"
		   aGrpCR[nPos2,14]++
		   aGrpCR[nPos2,15]+=SE1->E1_SALDO
		   aNumCR[nPos,14]++
		   aNumCR[nPos,15]+=SE1->E1_SALDO
		   aNumCRT[1,14]++
		   aNumCRT[1,15]+=SE1->E1_SALDO
		Case (nDias < 31)		//"A Vencer ate 30 dias "
		   aGrpCR[nPos2,16]++
		   aGrpCR[nPos2,17]+=SE1->E1_SALDO
		   aNumCR[nPos,16]++
		   aNumCR[nPos,17]+=SE1->E1_SALDO
		   aNumCRT[1,16]++
		   aNumCRT[1,17]+=SE1->E1_SALDO
		OtherWise				//"A Vencer a partir de 30 dias"
		   aGrpCR[nPos2,18]++
		   aGrpCR[nPos2,19]+=SE1->E1_SALDO
		   aNumCR[nPos,18]++
		   aNumCR[nPos,19]+=SE1->E1_SALDO
		   aNumCRT[1,18]++
		   aNumCRT[1,19]+=SE1->E1_SALDO
	EndCase                                        
   aGrpCR[nPos2,20]++
   aGrpCR[nPos2,21]+=SE1->E1_SALDO
   aNumCR[nPos,20]++
   aNumCR[nPos,21]+=SE1->E1_SALDO
   aNumCRT[1,20]++
   aNumCRT[1,21]+=SE1->E1_SALDO
   DbSelectArea("SE1")
	DbSkip()
EndDo
oReport:SkipLine()
cImp := Repl("-",132)
oSection1:PrintLine()
oReport:SkipLine()
cImp := "."+space(24)+OemToAnsi(STR0006)
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
cImp := "."+OemToAnsi(substr(STR0009,2))+"   < "+strzero(year(dDataBase),4)+" "+STR0010
oSection1:PrintLine()
cImp := OemToAnsi(STR0007)
oSection1:PrintLine()
oReport:SkipLine()
aSort(aNumCR,1,,{|x,y| x[1] < y[1] })
aSort(aGrpCR,1,,{|x,y| x[1] + x[22] < y[1] + y[22] })
For ni:=1 to len(aNumCR)
	cImp := ".***  "+left(aNumCR[ni,1],3)+"  *** "+Transform(aNumCR[ni,3],"@E 9999999,999")+Transform(aNumCR[ni,5],"@E 9999999,999")+Transform(aNumCR[ni,7],"@E 9999999,999")+Transform(aNumCR[ni,9],"@E 9999999,999")+Transform(aNumCR[ni,11],"@E 9999999,999")
	cImp += Transform(aNumCR[ni,13],"@E 9999999,999.99")+Transform(aNumCR[ni,15],"@E 9999999,999")+Transform(aNumCR[ni,17],"@E 9999999,999")+Transform(aNumCR[ni,19],"@E 9999999,999")+Transform(aNumCR[ni,21],"@E 9999999,999.99")
	oSection1:PrintLine()
	DbSelectArea("SA6")
	DbSetOrder(1)
	DbSeek( xFilial("SA6") + aNumCR[ni,1] )
   cImp := "."+left(SA6->A6_NOME,15)+"("+Transform(aNumCR[ni,2],"@E 9999")+")"+Transform(((aNumCR[ni,3]/aNumCR[ni,13])*100),"@E 999")+"% ("+Transform(aNumCR[ni,4],"@E 9999")+")"+Transform(((aNumCR[ni,5]/aNumCR[ni,13])*100),"@E 999")+"%"
   cImp += " ("+Transform(aNumCR[ni,6],"@E 9999")+")"+Transform(((aNumCR[ni,7]/aNumCR[ni,13])*100),"@E 999")+"% ("+Transform(aNumCR[ni,8],"@E 9999")+")"+Transform(((aNumCR[ni,9]/aNumCR[ni,13])*100),"@E 999")+"%"
   cImp += " ("+Transform(aNumCR[ni,10],"@E 9999")+")"+Transform(((aNumCR[ni,11]/aNumCR[ni,13])*100),"@E 999")+"%      ("+Transform(aNumCR[ni,12],"@E 9999")+")     ("+Transform(aNumCR[ni,14],"@E 9999")+") "
   cImp += "    ("+Transform(aNumCR[ni,16],"@E 99999")+")    ("+Transform(aNumCR[ni,18],"@E 99999")+")      ("+Transform(aNumCR[ni,20],"@E 99999")+")"
	oSection1:PrintLine()
	oReport:SkipLine()
	nPos := 0
	nPos := aScan(aGrpCR,{|x| x[1] == aNumCR[ni,1] })
	If nPos > 0
		For nj:=nPos to len(aGrpCR)
			cImp := ".    - "+left(aGrpCR[nj,22],7)+" "+Transform(aGrpCR[nj,3],"@E 9999999,999")+Transform(aGrpCR[nj,5],"@E 9999999,999")+Transform(aGrpCR[nj,7],"@E 9999999,999")	+Transform(aGrpCR[nj,9],"@E 9999999,999")+Transform(aGrpCR[nj,11],"@E 9999999,999")
			cImp += Transform(aGrpCR[nj,13],"@E 9999999,999.99")+Transform(aGrpCR[nj,15],"@E 9999999,999")+Transform(aGrpCR[nj,17],"@E 9999999,999")+Transform(aGrpCR[nj,19],"@E 9999999,999")+Transform(aGrpCR[nj,21],"@E 9999999,999.99")
			oSection1:PrintLine()
			cImp := ".               ("+Transform(aGrpCR[nj,2],"@E 9999")+")"+Transform(((aGrpCR[nj,3]/aGrpCR[nj,13])*100),"@E 999")+"% ("+Transform(aGrpCR[nj,4],"@E 9999")+")"+Transform(((aGrpCR[nj,5]/aGrpCR[nj,13])*100),"@E 999")+"%"
			cImp += " ("+Transform(aGrpCR[nj,6],"@E 9999")+")"+Transform(((aGrpCR[nj,7]/aGrpCR[nj,13])*100),"@E 999")+"% ("+Transform(aGrpCR[nj,8],"@E 9999")+")"+Transform(((aGrpCR[nj,9]/aGrpCR[nj,13])*100),"@E 999")+"%"
			cImp += " ("+Transform(aGrpCR[nj,10],"@E 9999")+")"+Transform(((aGrpCR[nj,11]/aGrpCR[nj,13])*100),"@E 999")+"%      ("+Transform(aGrpCR[nj,12],"@E 9999")+")     ("+Transform(aGrpCR[nj,14],"@E 9999")+")"
			cImp += "     ("+Transform(aGrpCR[nj,16],"@E 99999")+")    ("+Transform(aGrpCR[nj,18],"@E 99999")+")      ("+Transform(aGrpCR[nj,20],"@E 99999")+")"
			oSection1:PrintLine()
	   	If nj < len(aGrpCR) 
		   	If aGrpCR[nj+1,1] # aNumCR[ni,1] 
		   		nj := len(aGrpCR) + 1	                        
				EndIf
			EndIf
		Next
	EndIf
	oReport:SkipLine()
Next
cImp := OemToAnsi(STR0007)
oSection1:PrintLine()
cImp := "."+OemToAnsi(substr(STR0011,2))+Transform(aNumCRT[1,3],"@E 9999999,999")+Transform(aNumCRT[1,5],"@E 9999999,999")+Transform(aNumCRT[1,7],"@E 9999999,999")+Transform(aNumCRT[1,9],"@E 9999999,999")+Transform(aNumCRT[1,11],"@E 9999999,999")
cImp += Transform(aNumCRT[1,13],"@E 9999999,999.99")+Transform(aNumCRT[1,15],"@E 9999999,999")+Transform(aNumCRT[1,17],"@E 9999999,999")+Transform(aNumCRT[1,19],"@E 9999999,999")+Transform(aNumCRT[1,21],"@E 9999999,999.99")
oSection1:PrintLine()
cImp := "."+OemToAnsi(substr(STR0012,2))+" ("+Transform(aNumCRT[1,2],"@E 9999")+")"+Transform(((aNumCRT[1,3]/aNumCRT[1,13])*100),"@E 999")+"% ("+Transform(aNumCRT[1,4],"@E 9999")+")"+Transform(((aNumCRT[1,5]/aNumCRT[1,13])*100),"@E 999")+"%"
cImp += " ("+Transform(aNumCRT[1,6],"@E 9999")+")"+Transform(((aNumCRT[1,7]/aNumCRT[1,13])*100),"@E 999")+"% ("+Transform(aNumCRT[1,8],"@E 9999")+")"+Transform(((aNumCRT[1,9]/aNumCRT[1,13])*100),"@E 999")+"%"
cImp += " ("+Transform(aNumCRT[1,10],"@E 9999")+")"+Transform(((aNumCRT[1,11]/aNumCRT[1,13])*100),"@E 999")+"%      ("+Transform(aNumCRT[1,12],"@E 9999")+")     ("+Transform(aNumCRT[1,14],"@E 9999")+") "
cImp += "    ("+Transform(aNumCRT[1,16],"@E 99999")+")    ("+Transform(aNumCRT[1,18],"@E 99999")+")      ("+Transform(aNumCRT[1,20],"@E 99999")+")"
oSection1:PrintLine()
cImp := OemToAnsi(STR0007)
oSection1:PrintLine()
oSection1:Finish()
Return Nil


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function FS_OPR050R3()
cDesc1    := OemToAnsi(STR0001)
cDesc2    := ""
cDesc3    := ""
cAlias    := "SE1"
aRegistros:= {}
nLin      := 0
aPag      := 1
nIte      := 1
aReturn   := { OemToAnsi(STR0002), 1,OemtoAnsi(STR0003), 1, 2, 1, "",1 }
cTamanho  := "M"          // P/M/G
Limite    := 132           // 80/132/220
aOrdem    := {}          // Ordem do Relatorio
cTitulo   := OemToAnsi(STR0004)
cNomeProg := "OFIPR050"
cNomeRel  := "OFIPR050"
nLastKey  := 0
nCaracter := 15
cabec1    := ""
cabec2    := ""
cNomeRel:=SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
   Return
EndIf     
SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| FS_RCRCAR(@lEnd,cNomeRel,cAlias) } , cTitulo )
If aReturn[5] == 1
   OurSpool( cNomeRel )
EndIf
MS_Flush()
Return
//////////////////////////////////////////////
Static Function FS_RCRCAR()
Local   ni       := 0
Local   nj       := 0
Local cTipTit := Left(Alltrim(GetNewPar("MV_TIPPER","TP"))+space(3),Len(SE1->E1_TIPO)) // Tipo de Titulo Provisorio
Private cbTxt    := Space(10)
Private cbCont   := 0
Private cString  := "SE1"
Private Li       := 132
Private m_Pag    := 1
Private wnRel    := "OFIPR050"
Private aNumCR   := {}
Private aGrpCR   := {}
Private aNumCRT  := {}
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer
nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      
DbSelectArea("SE1") 
DbSetOrder(1)
DbSeek( xFilial("SE1") )    
SetRegua( RecCount() )       
aAdd(aNumCRT,{ STR0005 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) 
Do While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1")
   IncRegua()
   If !(SE1->E1_SALDO>0)
      DbSelectArea("SE1")
      DbSkip()
      Loop
   EndIf 
   If SE1->E1_TIPO==cTipTit
      DbSelectArea("SE1")
      DbSkip()
      Loop
   EndIf 
   nDias := (SE1->E1_VENCTO-dDataBase)
   nPos2 := 0
   nPos2 := aScan(aGrpCR,{|x| x[1]+ x[22] == SE1->E1_PORTADO + SE1->E1_PREFORI +" "+ SE1->E1_PREFIXO })
   If nPos2 == 0
      aAdd(aGrpCR,{ SE1->E1_PORTADO , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , SE1->E1_PREFORI +" "+ SE1->E1_PREFIXO })
      nPos2 := len(aGrpCR)
   EndIf
   nPos := 0
	nPos := aScan(aNumCR,{|x| x[1] == SE1->E1_PORTADO })
	If nPos == 0 
		aAdd(aNumCR,{ SE1->E1_PORTADO , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 }) 
		nPos := aScan(aNumCR,{|x| x[1] == SE1->E1_PORTADO })
   EndIf 
   If year(SE1->E1_VENCTO) < year(dDataBase)
	   aGrpCR[nPos2,2]++
   	aGrpCR[nPos2,3]+=SE1->E1_SALDO
   	aNumCR[nPos,2]++
	   aNumCR[nPos,3]+=SE1->E1_SALDO
	   aNumCRT[1,2]++
   	aNumCRT[1,3]+=SE1->E1_SALDO
	EndIf
	Do Case 
		Case (nDias < -60)	//"Vencidos a mais de 60 dias"
		   aGrpCR[nPos2,4]++
		   aGrpCR[nPos2,5]+=SE1->E1_SALDO
		   aGrpCR[nPos2,12]++
		   aGrpCR[nPos2,13]+=SE1->E1_SALDO
		   aNumCR[nPos,4]++
		   aNumCR[nPos,5]+=SE1->E1_SALDO
		   aNumCR[nPos,12]++
		   aNumCR[nPos,13]+=SE1->E1_SALDO
		   aNumCRT[1,4]++
		   aNumCRT[1,5]+=SE1->E1_SALDO
		   aNumCRT[1,12]++
		   aNumCRT[1,13]+=SE1->E1_SALDO
		Case (nDias < -30)	//"Vencidos a mais de 30 dias e menos de 61 dias"
		   aGrpCR[nPos2,6]++
		   aGrpCR[nPos2,7]+=SE1->E1_SALDO
		   aGrpCR[nPos2,12]++
		   aGrpCR[nPos2,13]+=SE1->E1_SALDO
		   aNumCR[nPos,6]++
		   aNumCR[nPos,7]+=SE1->E1_SALDO
		   aNumCR[nPos,12]++
		   aNumCR[nPos,13]+=SE1->E1_SALDO
		   aNumCRT[1,6]++
		   aNumCRT[1,7]+=SE1->E1_SALDO
		   aNumCRT[1,12]++
		   aNumCRT[1,13]+=SE1->E1_SALDO
		Case (nDias < -15)	//"Vencidos a mais de 15 dias e menos de 31 dias"
		   aGrpCR[nPos2,8]++
		   aGrpCR[nPos2,9]+=SE1->E1_SALDO
		   aGrpCR[nPos2,12]++
		   aGrpCR[nPos2,13]+=SE1->E1_SALDO
		   aNumCR[nPos,8]++
		   aNumCR[nPos,9]+=SE1->E1_SALDO                                
		   aNumCR[nPos,12]++
		   aNumCR[nPos,13]+=SE1->E1_SALDO
		   aNumCRT[1,8]++
		   aNumCRT[1,9]+=SE1->E1_SALDO
		   aNumCRT[1,12]++
		   aNumCRT[1,13]+=SE1->E1_SALDO
		Case (nDias < -2)		//"Vencidos a mais de  2 dias e menos de 16 dias"
		   aGrpCR[nPos2,10]++
		   aGrpCR[nPos2,11]+=SE1->E1_SALDO
		   aGrpCR[nPos2,12]++
		   aGrpCR[nPos2,13]+=SE1->E1_SALDO
		   aNumCR[nPos,10]++
		   aNumCR[nPos,11]+=SE1->E1_SALDO                             
		   aNumCR[nPos,12]++
		   aNumCR[nPos,13]+=SE1->E1_SALDO
		   aNumCRT[1,10]++
		   aNumCRT[1,11]+=SE1->E1_SALDO
		   aNumCRT[1,12]++
		   aNumCRT[1,13]+=SE1->E1_SALDO
		Case (nDias < 0)		//"Vencidos a mais de  1 dia e menos de  2 dias"
		   aGrpCR[nPos2,14]++
		   aGrpCR[nPos2,15]+=SE1->E1_SALDO
		   aNumCR[nPos,14]++
		   aNumCR[nPos,15]+=SE1->E1_SALDO
		   aNumCRT[1,14]++
		   aNumCRT[1,15]+=SE1->E1_SALDO
		Case (nDias < 31)		//"A Vencer ate 30 dias "
		   aGrpCR[nPos2,16]++
		   aGrpCR[nPos2,17]+=SE1->E1_SALDO
		   aNumCR[nPos,16]++
		   aNumCR[nPos,17]+=SE1->E1_SALDO
		   aNumCRT[1,16]++
		   aNumCRT[1,17]+=SE1->E1_SALDO
		OtherWise				//"A Vencer a partir de 30 dias"
		   aGrpCR[nPos2,18]++
		   aGrpCR[nPos2,19]+=SE1->E1_SALDO
		   aNumCR[nPos,18]++
		   aNumCR[nPos,19]+=SE1->E1_SALDO
		   aNumCRT[1,18]++
		   aNumCRT[1,19]+=SE1->E1_SALDO
	EndCase                                        
   aGrpCR[nPos2,20]++
   aGrpCR[nPos2,21]+=SE1->E1_SALDO
   aNumCR[nPos,20]++
   aNumCR[nPos,21]+=SE1->E1_SALDO
   aNumCRT[1,20]++
   aNumCRT[1,21]+=SE1->E1_SALDO
   DbSelectArea("SE1")  
	DbSkip()     	          
EndDo             
nLin++
@ nLin++ , 00 psay Repl("-",132) 
nLin++
@ nLin++ , 25 psay STR0006
nLin++
@ nLin++ , 00 psay Repl("-",132) 
nLin++
nLin++
@ nLin++ , 00 psay STR0007
@ nLin++ , 00 psay STR0008
@ nLin++ , 00 psay STR0009+"   < "+strzero(year(dDataBase),4)+" "+STR0010
@ nLin++ , 00 psay STR0007
aSort(aNumCR,1,,{|x,y| x[1] < y[1] })
aSort(aGrpCR,1,,{|x,y| x[1] + x[22] < y[1] + y[22] })
nLin++              
For ni:=1 to len(aNumCR)
   If nLin >= 57
      nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1
      nLin++
   EndIf
   @ nLin++ , 00 psay " ***  " + left(aNumCR[ni,1],3) + "  *** " ;
                               + Transform(aNumCR[ni,3] ,"@E 9999999,999") ;
                               + Transform(aNumCR[ni,5] ,"@E 9999999,999") ;
                               + Transform(aNumCR[ni,7] ,"@E 9999999,999") ;
                               + Transform(aNumCR[ni,9] ,"@E 9999999,999") ;
                               + Transform(aNumCR[ni,11],"@E 9999999,999") ;
                               + Transform(aNumCR[ni,13],"@E 9999999,999.99") ;
                               + Transform(aNumCR[ni,15],"@E 9999999,999") ;
                               + Transform(aNumCR[ni,17],"@E 9999999,999") ;
                               + Transform(aNumCR[ni,19],"@E 9999999,999") ;
                               + Transform(aNumCR[ni,21],"@E 9999999,999.99")
   DbSelectArea("SA6")
   DbSetOrder(1)
   DbSeek( xFilial("SA6") + aNumCR[ni,1] )
   @ nLin++ , 00 psay left(SA6->A6_NOME,15) ;
                              + " (" + Transform(aNumCR[ni,2] ,"@E 9999") + ")" + Transform(((aNumCR[ni,3]/aNumCR[ni,13])*100) ,"@E 999") + "%" ;
                              + " (" + Transform(aNumCR[ni,4] ,"@E 9999") + ")" + Transform(((aNumCR[ni,5]/aNumCR[ni,13])*100) ,"@E 999") + "%" ;
                              + " (" + Transform(aNumCR[ni,6] ,"@E 9999") + ")" + Transform(((aNumCR[ni,7]/aNumCR[ni,13])*100) ,"@E 999") + "%" ;
                              + " (" + Transform(aNumCR[ni,8] ,"@E 9999") + ")" + Transform(((aNumCR[ni,9]/aNumCR[ni,13])*100) ,"@E 999") + "%" ;
                              + " (" + Transform(aNumCR[ni,10],"@E 9999") + ")" + Transform(((aNumCR[ni,11]/aNumCR[ni,13])*100),"@E 999") + "%" ;
                              + "      (" + Transform(aNumCR[ni,12],"@E 9999")  + ")  ";
                              + "   (" + Transform(aNumCR[ni,14],"@E 9999")  + ") " ;
                              + "    (" + Transform(aNumCR[ni,16],"@E 99999") + ") " ;
                              + "   (" + Transform(aNumCR[ni,18],"@E 99999") + ") " ;
                              + "     (" + Transform(aNumCR[ni,20],"@E 99999") + ")"
   nLin++
	nPos := 0
	nPos := aScan(aGrpCR,{|x| x[1] == aNumCR[ni,1] })
	If nPos > 0
		For nj:=nPos to len(aGrpCR)
	      If nLin >= 59
				nLin := cabec(ctitulo,cabec1,cabec2,cNomeProg,cTamanho,nCaracter) + 1      
				nLin++
   		EndIf
			@ nLin++ , 00 psay "     - " + left(aGrpCR[nj,22],7) + " " ;
					+ Transform(aGrpCR[nj,3] ,"@E 9999999,999") ;
					+ Transform(aGrpCR[nj,5] ,"@E 9999999,999") ;
					+ Transform(aGrpCR[nj,7] ,"@E 9999999,999") ;
					+ Transform(aGrpCR[nj,9] ,"@E 9999999,999") ;
					+ Transform(aGrpCR[nj,11],"@E 9999999,999") ;
					+ Transform(aGrpCR[nj,13],"@E 9999999,999.99") ;
					+ Transform(aGrpCR[nj,15],"@E 9999999,999") ;
					+ Transform(aGrpCR[nj,17],"@E 9999999,999") ;
					+ Transform(aGrpCR[nj,19],"@E 9999999,999") ;
					+ Transform(aGrpCR[nj,21],"@E 9999999,999.99") 
			@ nLin++ , 00 psay "               " ;
					+ " (" + Transform(aGrpCR[nj,2] ,"@E 9999") + ")" + Transform(((aGrpCR[nj,3]/aGrpCR[nj,13])*100) ,"@E 999") + "%" ;
					+ " (" + Transform(aGrpCR[nj,4] ,"@E 9999") + ")" + Transform(((aGrpCR[nj,5]/aGrpCR[nj,13])*100) ,"@E 999") + "%" ;
					+ " (" + Transform(aGrpCR[nj,6] ,"@E 9999") + ")" + Transform(((aGrpCR[nj,7]/aGrpCR[nj,13])*100) ,"@E 999") + "%" ;
					+ " (" + Transform(aGrpCR[nj,8] ,"@E 9999") + ")" + Transform(((aGrpCR[nj,9]/aGrpCR[nj,13])*100) ,"@E 999") + "%" ;
					+ " (" + Transform(aGrpCR[nj,10],"@E 9999") + ")" + Transform(((aGrpCR[nj,11]/aGrpCR[nj,13])*100),"@E 999") + "%" ;
					+ "      (" + Transform(aGrpCR[nj,12],"@E 9999")  + ")  ";
					+ "   (" + Transform(aGrpCR[nj,14],"@E 9999")  + ") " ;
					+ "    (" + Transform(aGrpCR[nj,16],"@E 99999") + ") " ;
					+ "   (" + Transform(aGrpCR[nj,18],"@E 99999") + ") " ;
					+ "     (" + Transform(aGrpCR[nj,20],"@E 99999") + ")"
	   	If nj<len(aGrpCR) 
		   	If aGrpCR[nj+1,1]#aNumCR[ni,1] 
		   		nj:=len(aGrpCR)+1	                        
				EndIf
			EndIf
		Next
	EndIf
	nLin++
Next
@ nLin++ , 00 psay STR0007
@ nLin++ , 00 psay STR0011 ;
			+ Transform(aNumCRT[1,3] ,"@E 9999999,999") ;
			+ Transform(aNumCRT[1,5] ,"@E 9999999,999") ;
			+ Transform(aNumCRT[1,7] ,"@E 9999999,999") ;
			+ Transform(aNumCRT[1,9] ,"@E 9999999,999") ;
			+ Transform(aNumCRT[1,11],"@E 9999999,999") ;
			+ Transform(aNumCRT[1,13],"@E 9999999,999.99") ;
			+ Transform(aNumCRT[1,15],"@E 9999999,999") ;
			+ Transform(aNumCRT[1,17],"@E 9999999,999") ;
			+ Transform(aNumCRT[1,19],"@E 9999999,999") ;
			+ Transform(aNumCRT[1,21],"@E 9999999,999.99") 
@ nLin++ , 00 psay STR0012 ;
			+ " (" + Transform(aNumCRT[1,2] ,"@E 9999") + ")" + Transform(((aNumCRT[1,3]/aNumCRT[1,13])*100) ,"@E 999") + "%" ;
			+ " (" + Transform(aNumCRT[1,4] ,"@E 9999") + ")" + Transform(((aNumCRT[1,5]/aNumCRT[1,13])*100) ,"@E 999") + "%" ;
			+ " (" + Transform(aNumCRT[1,6] ,"@E 9999") + ")" + Transform(((aNumCRT[1,7]/aNumCRT[1,13])*100) ,"@E 999") + "%" ;
			+ " (" + Transform(aNumCRT[1,8] ,"@E 9999") + ")" + Transform(((aNumCRT[1,9]/aNumCRT[1,13])*100) ,"@E 999") + "%" ;
			+ " (" + Transform(aNumCRT[1,10],"@E 9999") + ")" + Transform(((aNumCRT[1,11]/aNumCRT[1,13])*100),"@E 999") + "%" ;
			+ "      (" + Transform(aNumCRT[1,12],"@E 9999")  + ")  ";
			+ "   (" + Transform(aNumCRT[1,14],"@E 9999")  + ") " ;
			+ "    (" + Transform(aNumCRT[1,16],"@E 99999") + ") " ;
			+ "   (" + Transform(aNumCRT[1,18],"@E 99999") + ") " ;
			+ "     (" + Transform(aNumCRT[1,20],"@E 99999") + ")"
@ nLin++ , 00 psay STR0007
Set Printer to
Set Device  to Screen
Return
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////