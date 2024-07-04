#Include "OFIOR670.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFIOR670 | Autor ³ Thiago             º Data ³  26/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio Ultimo Preco de Compra/Venda da Peca             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MIL                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function OFIOR670

Local cAlias := "SB1"
Local cDesc3 :=""

//Variaveis padrao de relatorio
Private cDesc1   := ""
Private cabec1   := STR0001 //Grp   Codigo do Item     Descrição do Item        Ult Compra   Valor Compra  QdCompra  Ult Venda     Venda  QdVenda  QdAtual CusMe
Private cDesc2   := ""
Private cabec2   := ""
Private aReturn  := { "", 1,"", 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private cTamanho := "M"           // P/M/G
Private Limite   := 132           // 80/132/220
Private cTitulo  := STR0002 //Ultima Movimentacao 
Private cNomProg := "OFIOR670"
Private cNomeRel := "OFIOR670"
Private nLastKey := 0
Private nCaracter:= 15
Private nUltMov  := 0
Private nValTSD1 := 0
Private nQtdTSD1 := 0
Private nValTSD2 := 0
Private nQtdAtu  := 0 
Private nQtdTSD2 := 0
Private nCM1     := 0 
Private dUtCom := ctod("   /   /   ")
Private dUtVend := ctod("   /   /   ")
Private cPerg    := "OFR670"     
  
If SB1->(FieldPos("B1_DTULTVD"))== 0
	MsgInfo(STR0003) //Favor criar o campo B1_DTULTVD do tipo DATA com tamanho 8 na tabela de produtos (SB1).
	return
endif

set printer to &cNomeRel
set printer on
set device to printer       


cNomeRel := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf     

PERGUNTE(cPerg,.f.)

SetDefault(aReturn,cAlias)

RptStatus( { |lEnd| FS_M_RULTCOM(@lEnd,cNomeRel,cAlias) } , cTitulo )

Return

Static Function FS_M_RULTCOM()                           
Local i := 0
M_PAG  := 1  
cDescr := ""   

Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

if MV_PAR04 = 1
   cDescr := STR0004  //de Compra
else 
   cDescr := STR0005  //de Venda   
endif                
cTitulo := cTitulo+cDescr

nLin := cabec(cTitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1

cIndSB2 := CriaTrab(Nil, .F.)
cChave  := "B2_FILIAL+STR(B2_CM1,15,2)"
cCond   := ""
IndRegua("SB2",cIndSB2,cChave,,cCond,OemToAnsi(STR0006) )  //Selecionando Registros
dbSelectArea("SB2")
nIndex := RetIndex("SB2")
#IFNDEF TOP
	dbSetIndex(cIndSB2+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)

dbSelectArea("SB2")
dbSetOrder(nIndex+1)
dbSeek(xFilial("SB2"))

SetRegua( RecCount() )


While !Eof() .and. SB2->B2_FILIAL == xFilial("SB2")
   IncRegua()                  

   if SB2->B2_LOCAL <> "01"
      dbSelectArea("SB2")
      dbSkip()
      Loop
   Endif   
   
   dbSelectArea("SB1")
   dbSetOrder(1)
   dbSeek(xFilial("SB1")+SB2->B2_COD)

   if !Empty(mv_par03)
      if SB1->B1_GRUPO <> mv_par03
         dbSelectArea("SB2")
         dbSkip()
         Loop
      Endif
   Endif      
   
   ///////////////////////dias inicial/////////////////////////////
   nDia := val(substr(dtoc(ddatabase),1,2))
   nMes := val(substr(dtoc(ddatabase),4,2))
   nAno := val(substr(dtoc(ddatabase),7,2))
   
   for i := 1 to mv_par01
       if nDia == 01     
          nDia := nDia - 1  
          nDia := 30
          nMes := nMes - 1
       Else
          nDia := nDia - 1  
       Endif
       if nMes == 01 .and. nDia == 01
          nMes := 12
          nAno := nAno - 1
          nDia := 30
       Endif                                
   Next 
   nDia  := str(nDia)
   nMes  := str(nMes) 
   nAno  := str(nAno)
   dData := cTod(ndia+"/"+nMes+"/"+nAno)


   ////////////////////dias final/////////////////////////////////////
   nDiaFin := val(substr(dtoc(ddatabase),1,2))
   nMesFin := val(substr(dtoc(ddatabase),4,2))
   nAnoFin := val(substr(dtoc(ddatabase),7,2))
   
   for i := 1 to mv_par02
       if nDiaFin == 01     
          nDiaFin := nDiaFin - 1  
          nDiaFin := 30
          nMesFin := nMesFin - 1
       Else
          nDiaFin := nDiaFin - 1  
       Endif
       if nMesFin == 01 .and. nDiaFin == 01
          nMesFin := 12
          nAnoFin := nAnoFin - 1
          nDiaFin := 30
       Endif                                
   Next 
   nDiaFin  := str(nDiaFin)
   nMesFin  := str(nMesFin) 
   nAnoFin  := str(nAnoFin)
   dDataFin := cTod(ndiaFin+"/"+nMesFin+"/"+nAnoFin)
   if mv_par04 == 1
      if Empty(SB1->B1_UCOM)
         if SB2->B2_QATU > 0 
//          if !Empty(SB1->B1_UCOM)     
               if SB1->B1_DTULTVD > dData .or. SB1->B1_DTULTVD < dDataFin
                  dbSelectArea("SB2")
                  dbSkip()
                  Loop
               Endif
//          Endif
         Endif   
      Else
        if SB1->B1_UCOM > dData .or. SB1->B1_UCOM < dDataFin
            dbSelectArea("SB2")
            dbSkip()
            Loop
         Endif
      Endif
   Else
      if Empty(SB1->B1_DTULTVD)
         if SB2->B2_QATU > 0 
//          if !Empty(SB1->B1_UCOM)     
               if SB1->B1_UCOM > dData .or. SB1->B1_UCOM < dDataFin
                  dbSelectArea("SB2")
                  dbSkip()
                  Loop
               Endif
//          Endif
         Endif   
      Else
         if SB1->B1_DTULTVD > dData .or. SB1->B1_DTULTVD < dDataFin
            dbSelectArea("SB2")
            dbSkip()
            Loop
         Endif
      Endif   
   Endif
   if mv_par04 == 1
      if Empty(SB1->B1_UCOM)
         if SB2->B2_QATU == 0 
            dbSelectArea("SB2")
            dbSkip()
            Loop
         Endif
      Endif      
   Endif
   if SB2->B2_QATU == 0 
      dbSelectArea("SB2")
      dbSkip()
      Loop
   Endif


     if (mv_par04 == 1 .and. !Empty(SB1->B1_UCOM)) .or. Empty(SB1->B1_DTULTVD)  /////Data Compra

        ///////////////Peca a data da ultima compra////////////////////////////
        if !Empty(SB1->B1_UCOM)
           dbSelectArea("SD1")
           dbSetOrder(7)
           dbSeek(xFilial("SD1")+SB1->B1_COD)
           dDatCom := SD1->D1_DTDIGIT
           While !Eof() .and. xFilial("SD1") == SD1->D1_FILIAL .and. SB1->B1_COD == SD1->D1_COD
              if SD1->D1_DTDIGIT < dDatCom
                 dbSelectArea("SD1")
                 dbSkip()
                 Loop
              Endif   
              dDatCom := SD1->D1_DTDIGIT 
              dbSelectArea("SD1")
              dbSkip()
           Enddo              
        Endif

        dbSelectArea("SD1")
        dbSetOrder(2)
        if dbSeek(xFilial("SD1")+SB1->B1_COD)
           nValSD1 := 0
           nQtdSD1 := 0 
           nValSD2 := 0 
           nQtdSD2 := 0
           lAchou := .f. 
           dUtCom := ctod("   /   /   ")
           dUtVend := ctod("   /   /   ")
           While !Eof() .and. xFilial("SD1") == SD1->D1_FILIAL .and. SB1->B1_COD == SD1->D1_COD
         

              if dDatCom <> SD1->D1_DTDIGIT
                 dUtCom  := SB1->B1_UCOM
                 dbSelectArea("SD1")
                 dbSkip()
                 Loop
              Endif   
              if !Empty(SB1->B1_DTULTVD)
                 dbSelectArea("SD2")
                 dbSetOrder(1)
                 dbSeek(xFilial("SD2")+SB1->B1_COD)   
                 dDatVend := SD2->D2_EMISSAO
                 While !Eof() .and. xFilial("SD2") == SD2->D2_FILIAL .and. SB2->B2_COD == SD2->D2_COD
                    if SD2->D2_EMISSAO < dDatVend
                       dbSelectArea("SD2")
                       dbSkip()
                       Loop
                    Endif   
                    dDatVend := SD2->D2_EMISSAO
                    nValSD2  := SD2->D2_PRCVEN
                    nQtdSD2  := SD2->D2_QUANT
                  
                    dbSelectArea("SD2")
                    dbSkip()
                 Enddo              
              Endif
  				  DbSelectArea("SF4")
				  DbSetOrder(1)
				  DbSeek( xFilial("SF4") + SD1->D1_TES )
				  
				  if !SF4->F4_OPEMOV $ "01/03"
                 dbSelectArea("SD1")
                 dbSkip()
                 Loop
				  Endif
					
              lAchou := .t.
              nValTSD2 += nValSD2
              nQtdTSD2 += nQtdSD2
              nValSD1  := SD1->D1_VUNIT
              nQtdSD1  := SD1->D1_QUANT
              dUtCom   := SB1->B1_UCOM
              nValTSD1 += SD1->D1_VUNIT
              nQtdTSD1 += SD1->D1_QUANT
               nQtdAtu += SB2->B2_QATU
               nCM1    += SB2->B2_CM1
               If nLin >= 60
                  nLin := 1
                  nLin := cabec(cTitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
               Endif
              @ nLin++, 001 pSay SB1->B1_GRUPO+" "+substr(SB1->B1_CODITE,1,18)+" "+substr(SB1->B1_DESC,1,25)+" "+transform(SB1->B1_UCOM,"@D")+"      "+transform(nValSD1,"@E 999,999.99")+"       "+transform(nQtdSD1,"@E 999")+"   "+transform(SB1->B1_DTULTVD,"@D")+" "+transform(nValSD2,"@E 99,999.99")+"     "+transform(nQtdSD2,"@E 999")+"    "+transform(SB2->B2_QATU, "@E 999")+"  "+transform(SB2->B2_CM1, "@E 99,999.99")
              nUltMov  := 1
              dbSelectArea("SD1")
              dbSkip()
     
           Enddo
        Endif
     Elseif (mv_par04 == 2 .and. !Empty(SB1->B1_DTULTVD)) .or. Empty(SB1->B1_UCOM)      ///////Data Venda
        dUtCom := SB1->B1_UCOM
        if !Empty(SB1->B1_DTULTVD)
           dbSelectArea("SD2")
           dbSetOrder(1)
           dbSeek(xFilial("SD2")+SB1->B1_COD)   
           dDatVend := SD2->D2_EMISSAO
           While !Eof() .and. xFilial("SD2") == SD2->D2_FILIAL .and. SB2->B2_COD == SD2->D2_COD
              if SD2->D2_EMISSAO < dDatVend
                 dbSelectArea("SD2")
                 dbSkip()
                 Loop
              Endif   
              dDatVend := SD2->D2_EMISSAO
              dbSelectArea("SD2")
              dbSkip()
           Enddo              
        Endif


        nValSD2 := 0
        nQtdSD2 := 0
        nValSD1 := 0
        nQtdSD1 := 0

        dbSelectArea("SD2")
        dbSetOrder(1)
        if dbSeek(xFilial("SD2")+SB1->B1_COD)
           lAChou := .f. 
  
           While !Eof() .and. xFilial("SD2") == SD2->D2_FILIAL .and. SB1->B1_COD == SD2->D2_COD
      
                    
              if dDatVend <> SD2->D2_EMISSAO
                 dUtVend := SB1->B1_DTULTVD
                 dbSelectArea("SD2")
                 dbSkip()
                 Loop
              Endif   
              if !Empty(SB1->B1_UCOM)
                 dbSelectArea("SD1")
                 dbSetOrder(7)
                 dbSeek(xFilial("SD1")+SB1->B1_COD)
                 dDatCom := SD1->D1_DTDIGIT
                 While !Eof() .and. xFilial("SD1") == SD1->D1_FILIAL .and. SB1->B1_COD == SD1->D1_COD
                    if SD1->D1_DTDIGIT < dDatCom
                       dbSelectArea("SD1")
                       dbSkip()
                       Loop
                    Endif   
                    dDatCom  := SD1->D1_DTDIGIT 
                    nValSD1  := SD1->D1_VUNIT
                    nQtdSD1  := SD1->D1_QUANT
                 
                    dbSelectArea("SD1")
                    dbSkip()
                 Enddo              
              Endif
  				  DbSelectArea("SF4")
				  DbSetOrder(1)
				  DbSeek( xFilial("SF4") + SD2->D2_TES )
				  
				  if SF4->F4_OPEMOV <> "05"
                 dbSelectArea("SD2")
                 dbSkip()
                 Loop
				  Endif

              lAchou   := .t.
              nValTSD1 += nValSD1
              nQtdTSD1 += nQtdSD1
              nValSD2  := SD2->D2_PRCVEN
              nQtdSD2  := SD2->D2_QUANT
              nValTSD2 += SD2->D2_PRCVEN
              nQtdTSD2 += SD2->D2_QUANT
              dUtVend  := SB1->B1_DTULTVD
              nQtdAtu += SB2->B2_QATU
              nCM1    += SB2->B2_CM1
              If nLin >= 60
                 nLin := 1
                 nLin := cabec(cTitulo,cabec1,cabec2,cNomeRel,ctamanho,nCaracter) + 1
              Endif
              @ nLin++, 001 pSay SB1->B1_GRUPO+" "+substr(SB1->B1_CODITE,1,18)+" "+substr(SB1->B1_DESC,1,25)+" "+transform(dUtCom,"@D")+"      "+transform(nValSD1,"@E 999,999.99")+"       "+transform(nQtdSD1,"@E 999")+"   "+transform(SB1->B1_DTULTVD,"@D")+" "+transform(nValSD2,"@E 99,999.99")+"     "+transform(nQtdSD2,"@E 999")+"    "+transform(SB2->B2_QATU, "@E 999")+"  "+transform(SB2->B2_CM1, "@E 99,999.99")
              nUltMov := 2
              dbSelectArea("SD2")
              dbSkip()
     
           Enddo
        Endif
     Endif                    
        

//   @ nLin++, 001 pSay SB1->B1_GRUPO+" "+substr(SB1->B1_CODITE,1,18)+" "+substr(SB1->B1_DESC,1,25)+" "+transform(SB1->B1_UCOM,"@D")+"      "+transform(nValSD1,"@E 999,999.99")+"       "+transform(nQtdSD1,"@E 999")+"   "+transform(SB1->B1_DTULTVD,"@D")+" "+transform(nValSD2,"@E 99,999.99")+" "+transform(nQtdSD2,"@E 999")+"         "+transform(SB2->B2_QATU, "@E 999")+" "+transform(SB2->B2_CM1, "@E 99,999.99")

  dbSelectArea("SB2")
  dbSkip()

Enddo      
nLin+=2
@ nLin++ , 00 psay Repl("*",132) 
@ nLin++, 001 pSay STR0007 + "             -                       "+transform(nValTSD1,"@E 999,999.99")+"     "+transform(nQtdTSD1,"99999")+"    "+transform(nValTSD2,"@E 99,999,999,999.99")+"    "+transform(nQtdTSD2,"9999")+"   "+transform(nQtdAtu,"9999")+" "+transform(nCM1,"@E 999,999.99") //"Valor Total da Movimentacao
@ nLin++ , 00 psay Repl("*",132) 
nLin+=2
                                                                                                                          
Set Printer to
Set device to Screen

MS_FLUSH()

If aReturn[5] == 1

   OurSpool(cNomeRel)
   
EndIf   
 
Return
