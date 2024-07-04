#INCLUDE "HSPAHR38.ch"
#INCLUDE "RWMAKE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR38 บ Autor ณ Equipe G. Hospitalar บ Data ณ 11/08/03  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ LISTAGEM DE PACOTES                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR38()

 cTitulo  := STR0001 //"LISTAGEM DE PACOTES"

 M_Pag    := 1
 cTamanho := "M"           // P/M/G  
 nCaracter:= 15
 Limite   := 132          // 80/132/220
 aOrdem   := {}           // Ordem do Relatorio
 nLastKey := 0
 aReturn  := { STR0002, 1,STR0003,1, 1, 1, "",1 }  //PARAM 4, 1 RETRATO 2 PAISAGEM //"Zebrado"###"Administracao"
 cNomProg := "HSPAHR38"
 cNomeRel := "HSPAHR38"
 aDriver  := LeDriver()
 cCompac  := aDriver[1]
 cNormal  := aDriver[2]
 cDrive   := "Epson.drv"
 cNomeImp := "LPT1"
 cAlias   := "GA1"
 nLin     := 80
 cPerg    := "HSPR38"
 GeraX1()
 If !Pergunte(cPerg,.T.)
  return
 EndIf                    

 cNomeRel := SetPrint(cAlias,cNomeRel,nil ,@cTitulo,"","","",.F.,"",.T.,cTamanho,nil    ,nil    ,nil)

 If nLastKey == 27
  Return(nil)
 Endif

 SetDefault(aReturn,cAlias)

 If nLastKey == 27
  Return
 Endif

 Processa({|| RptProc() } )  //Gera e imprime o relatorio

Return(nil)

////////////////////////////////////////////////////////////////
//   Funcao.:   RptProc                                       //
//   Objetivo.: Enviar o Relatorio para Tela ou Impressora    //
////////////////////////////////////////////////////////////////
Static Function RptProc()
 Local aRetKit := {}, nItemKit := 0, nK_CcoKit := 0, nK_QtdKit := 0, nK_DesCom := 0
 Local nCt := 0, aRValPro := {}
 
 Set Printer to &cNomeRel
 Set Printer On
 Set Device  to Printer
 
 aDados := {} // Vetor 
 //  1o Elemento - GAA_CODCTD			C	2		Categoria da Taxa/Diaria
 //  2o Elemento - GAA	GAA_DESCTD	C	30	Descricao da Categoria - 
 //                Posicione("SX5",1,xFilial("SX5")+"CT"+GAA->GAA_CODCTD,"X5_DESCRI"),"")
 //  3o Elemento - GAB	GAB_CODTXD	C	4	  Codigo da Taxa/Diaria
 //  4o Elemento - GAB	GAB_DESC	  C	40	Descricao da Taxa/Diaria
 //  5o Elemento - GAB	GAB_CODTXC	C	9	  Codigo da Taxa/Diaria no Convenio
 //  6o Elemento - GAB	GAB_VALVTX	N	7,2 Valor da Taxa Diaria no Convenio
 //  7o Elemento - GAB	GAB_DTVIGV	D	8   Data da Vigencia da Taxa/Diaria
 
 DbSelectArea("GA2")
 dbsetorder(1)  // GAA_CODCTD
 nTReg1 := RecCount()
 DBGOTOP()

 DbSelectArea("GA1")
 dbsetorder(1)  // GAA_CODCTD
 nTReg := RecCount()
 DbSeek(xFilial("GA1") + MV_PAR05, .T.)

 ProcRegua(nTReg+nTReg1)

 While xFilial("GA1") == GA1->GA1_FILIAL .And. GA1->GA1_CODPCT <= MV_PAR06 .And. !Eof() 
  M->GA1_CODPCT := GA1->GA1_CODPCT
  cDescCat      := GA1->GA1_DESC
  IncProc(STR0004 + GA1->GA1_CODPCT + "  "+LEFT(cDescCat,20) )	 //"Pacote "

  DbSelectArea("GA2")
  dbsetorder(1) 
  DbSeek(xFilial("GA2")+M->GA1_CODPCT)

  If Found()                                                        
   While !eof() .and. GA2->GA2_FILIAL+GA2->GA2_CODPCT == xFilial("GA2")+GA1->GA1_CODPCT
    cDesc    := space(50)
    Valuni   := 0               
	Valpart  := 0
	ValCust  := 0
	cApres   := STR0005 //"UNIDADE  "
	nQuant   := GA2->GA2_QTDAPL
		    
	If GA2->GA2_ORIPAC # "4" // Kit
	 If GA2->GA2_ORIPAC == '0'
      DbSelectArea("GBI")
	  dbsetorder(1) 
	  DbSeek(xFilial("GBI")+Alltrim(GA2->GA2_CODCPC)+Space(15-len(Alltrim(GA2->GA2_CODCPC))))
	  DbSelectArea("SB1")
	  dbsetorder(1) 
	  DbSeek(xFilial("SB1")+Alltrim(GA2->GA2_CODCPC)+Space(15-len(Alltrim(GA2->GA2_CODCPC))))
	  If Found()
	   cDesc  := SB1->B1_DESC    
	   DbSelectArea("SAH")
	   DbSeek(xFilial("SAH")+SB1->B1_SEGUM)
	   If Found()        
	    cApres := SAH->AH_UMRES
	   Endif
	   DbSelectArea("SB1")                                                   
	   aRValPro := HS_RValPro("0", GBI->GBI_PRODUT, MV_PAR01, MV_PAR02,, "2",,,,,, MV_PAR07)
	   ValUni   := aRValPro[1]
	   ValCust  := aRValPro[2]
	   
	   aRValPro := HS_RValPro("0", GBI->GBI_PRODUT, MV_PAR03, MV_PAR04,, "2",,,,,, MV_PAR07)
	   ValPart  := aRValPro[1]
	  Endif 
	 ElseIf GA2->GA2_ORIPAC == '2'
	  DbSelectArea("GAA")
	  dbsetorder(1) 
	  DbSeek(xFilial("GAA")+Alltrim(GA2->GA2_CODCPC))
	  If Found()
	   cDesc   := GAA->GAA_DESC+SPACE(10)
	   valcust := GAA->GAA_CUSCTD
	   cApres  := Posicione("SX5",1,xFilial("SX5")+"TD"+GAA->GAA_TIPDES,"X5_DESCRI")
	   DbSelectArea("GAB")
	   dbsetorder(1) 
	   DbSeek(xFilial("GAB")+Alltrim(GA2->GA2_CODCPC)+MV_PAR01+'1')
	   If Found()
	    valuni  := GAB->GAB_VALVTX
	   Endif                        
	   DbSelectArea("GAB")
	   dbsetorder(1) 
	   DbSeek(xFilial("GAB")+Alltrim(GA2->GA2_CODCPC)+MV_PAR02+'1')
	   If Found()
	    valPart  := GAB->GAB_VALVTX
	   Endif                        
	  Endif               
	 ElseIf GA2->GA2_ORIPAC == '1'
	  DbSelectArea("GA9")
	  DbSetOrder(1) 
	  DbSeek(xFilial("GA9") + MV_PAR01)
	  If Found()                                                                                                               
	   aRValPro := HS_RValPro("1", GA2->GA2_CODCPC, MV_PAR01, MV_PAR02, HS_RCfgCP(MV_PAR01, MV_PAR02, "_TABPRO"),,,,,,, MV_PAR07)
	   vValUni  := aRValPro[1, 5]
	   cDesc    := aRValPro[7]
	   valcust  := aRValPro[2]
    cApres   := Posicione("SX5", 1, xFilial("SX5") + "TD" + aRValPro[1, 6], "X5_DESCRI")
	  Endif 
 	  
	  DbSelectArea("GA9")
	  DbSetOrder(1) 
	  DbSeek(xFilial("GA9") + MV_PAR03)
	  If Found()                                          
	   aRValPro := HS_RValPro("1", GA2->GA2_CODCPC, MV_PAR03, MV_PAR04, HS_RCfgCP(MV_PAR01, MV_PAR02, "_TABPRO"),,,,,,, MV_PAR07)
	   vValPart := aRValPro[1, 5]
	   cDesc    := aRValPro[7]
	   valcust  := aRValPro[2]
       cApres   := Posicione("SX5", 1, xFilial("SX5") + "TD" + aRValPro[1, 6], "X5_DESCRI")
	  Endif
	 Endif   

	 IncProc(STR0004 + GA2->GA2_CODPCT + "  " + LEFT(cDesc, 15)) //"Pacote "
	 aadd(aDados, {M->GA1_CODPCT, ;
	               cDescCat, ;
	               PadR(GA2->GA2_CODCPC, 15), ;
	               PadR(cDesc, 45), ;
	               PadR(cApres, 9), ;
	               nQuant, ;
	               (ValPart * nQuant), ;
	               (ValUni  * nQuant), ;
	               (ValCust * nQuant)})
	Else 
	 IncProc(STR0004 + GA2->GA2_CODPCT + "  "+LEFT(cDesc,15))	 //"Pacote "
	 aRetKit   := HS_RetKit(GA2->GA2_CODCPC)
     nK_CCOKIT := aScan(aRetKit[2], {|aVet| AllTrim(aVet[2]) == "GAG_CCOKIT"})
     nK_DESCOM := aScan(aRetKit[2], {|aVet| AllTrim(aVet[2]) == "GAG_DESCOM"})
     nK_QTDKIT := aScan(aRetKit[2], {|aVet| AllTrim(aVet[2]) == "GAG_QTDKIT"})
	 For nItemKit := 1 To Len(aRetKit[1])
	  DbSelectArea("GBI")
	  dbsetorder(1) 
	  DbSeek(xFilial("GBI")+PadR(aRetKit[1][nItemKit, nK_CCOKIT], Len(GBI->GBI_PRODUT)))
		      
	  DbSelectArea("SB1")
	  dbsetorder(1) 
	  DbSeek(xFilial("SB1")+PadR(aRetKit[1][nItemKit, nK_CCOKIT], Len(GBI->GBI_PRODUT)))
	  If Found()
	   cDesc  := SB1->B1_DESC    
	   DbSelectArea("SAH")
	   DbSeek(xFilial("SAH")+SB1->B1_SEGUM)
	   If Found()        
	    cApres := SAH->AH_UMRES
	   Endif
	   DbSelectArea("SB1")    
	   aRValPro := HS_RValPro("0", GBI->GBI_PRODUT, MV_PAR01, MV_PAR02,, "2",,,,,, MV_PAR07)
	   ValUni   := aRValPro[1]
	   ValCust  := aRValPro[2]
	   
	   aRValPro := HS_RValPro("0", GBI->GBI_PRODUT, MV_PAR03, MV_PAR04,, "2",,,,,, MV_PAR07)
	   ValPart  := aRValPro[1]
	  Endif 
      aAdd(aDados,{M->GA1_CODPCT, ;
                   cDescCat, ;
                   PadR(aRetKit[1][nItemKit, nK_CCOKIT], 15), ;
                   PadR(aRetKit[1][nItemKit, nK_DESCOM], 45), ;
	               PadR(cApres, 9), ;
	               (nQuant  * aRetKit[1][nItemKit, nK_QTDKIT]), ;
                   (ValPart * (nQuant * aRetKit[1][nItemKit, nK_QTDKIT])), ;
	               (ValUni  * (nQuant * aRetKit[1][nItemKit, nK_QTDKIT])), ;
	               (ValCust * (nQuant * aRetKit[1][nItemKit, nK_QTDKIT]))})
	 Next 
	EndIf 
	DbSelectArea("GA2")
    DbSkip()
   Enddo
  Endif
  DbSelectArea("GA1")
  DbSkip()
 Enddo

 ASort(aDados,,,{|x,y| X[2] < Y[2]})
 setprc(0,0)  
 cCodCat  := ""
 cCabec1  := STR0006 //"LISTAGEM DE PACOTES                                                     QUANTIDADE        VALOR      VALOR      VALOR"
 cCabec2  := STR0007 //"CODIGO          DESCRICAO                                     APRES      UTILIZADA        CUSTO PARTICULAR   CONVENIO"
                     // 123456789012345 123456789012345678901234567890123456789012345 123456789 999.999.99 999.999.9999 999.999.99 999.999.99
 ProcRegua(Len(aDados))

 _primeira := .t.
 
 For nCt := 1 to Len(aDados)
  IncProc(STR0004 + aDados[nCt,1] + " "+ aDados[nCt,2] )	 //"Pacote "
  if nLin > 56
   nLin := cabec(ctitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter)+1
  endif	

  if cCodCat <> aDados[nCt,1]  	                  
   if _primeira == .f.
    @ nLin++,00 PSAY STR0008+SPACE(74)+TRANSFORM(ntotCus,"@E 999,999.9999")+"    "+TRANSFORM(ntotpar,"@E 999,999.99")+"    "+TRANSFORM(ntotUni,"@E 999,999.99") //"T O T A I S --->"
    nLin++
   endif
   nLin++
   @ nLin++,00 PSAY CHR(15)+aDados[nCt,1] +"   "+aDAdos[nCt,2]
   cCodCat := aDados[nCt,1]
   nLin++
   ntotCus := 0
   ntotPar := 0
   ntotUni := 0
  endif

  @ nLin++,00 PSAY CHR(15) + aDados[nCt,3] + " " + aDados[nCt,4] + " " + aDados[nCt,5] + " " + ;
                             TRANSFORM(aDados[nCt,6],"@E 999,999.99") + " " + ;
                             TRANSFORM(aDados[nCt,9],"@E 999,999.9999") + " " + ;
                             TRANSFORM(aDados[nCt,7],"@E 999,999.99") + " " + ;
                             TRANSFORM(aDados[nCt,8],"@E 999,999.99")
  
  ntotCus := ntotCus + aDados[nCt,9]
  ntotPar := ntotPar + aDados[nCt,7]
  ntotUni := ntotUni + aDados[nCt,8]
  _primeira := .f.
 Next

 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(cNomeRel)
 Endif

 Eject 
 Ms_Flush()
Return(nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GeraX1   บ Autor ณ JOSE ORFEU         บ Data ณ  11/08/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ FUNCAO PARA INCLUSAO DE PERGUNTAS EM SX1 CASO NAO EXISTA   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/   
Static Function GeraX1()
 Local i:=0, j:=0
 _sAlias := Alias()
 dbSelectArea("SX1")
 dbSetOrder(1)
 cPerg := PADR(cPerg,6)
 aRegs:={}

 AADD(aRegs,{cPerg,"01",STR0009,"","","mv_ch1","C",3,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","GA9","N",""}) //"Convenio  "
 AADD(aRegs,{cPerg,"02",STR0010,"","","mv_ch2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","GCM","N",""}) //"Plano     "
 AADD(aRegs,{cPerg,"03",STR0011,"","","mv_ch3","C",3,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","GA9","N",""}) //"Particular"
 AADD(aRegs,{cPerg,"04",STR0010,"","","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","GCM","N",""}) //"Plano     "
 AADD(aRegs,{cPerg,"05",STR0012,"","","mv_ch5","C",6,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","Z1R","N",""}) //"Do Pacote "
 AADD(aRegs,{cPerg,"06",STR0013,"","","mv_ch6","C",6,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","Z1R","N",""}) //"Ao Pacote "
 AADD(aRegs,{cPerg,"07","Centro de Custo","","","mv_ch7","C",9,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","CTT","N",""})

 For i:=1 to Len(aRegs)
  If !dbSeek(cPerg+aRegs[i,2])
   RecLock("SX1",.T.)
   For j:=1 to FCount()
    If j <= Len(aRegs[i])
     FieldPut(j,aRegs[i,j])
    Endif
   Next
   MsUnlock()
  Endif
 Next
 dbSelectArea(_sAlias)
Return