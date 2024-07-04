#INCLUDE "HSPAHR36.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR36 บ Autor ณ Equipe G. Hospitalar บ Data ณ 11/08/03  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Movimenta็ใo Por Almoxarifado                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
FUNCTION HSPAHR36
 Local aOrd    := {}
 Local cDesc1  := STR0024 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2  := STR0025 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3  := ""
 Local cPict   := ""
 Local Cabec1  := ""
 Local Cabec2  := ""
 Local imprime := .T.
 ValidPerg()
 if !Pergunte("HSPR36",.t.)
  Return(Nil)
 Endif

 Private CbTxt       := ""
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private nTipo       := 18
 Private cbcont      := 00
 Private CONTFL      := 01
 Private wnrel       := "HSPAHR36"
 Private cString     := ""

 m_pag	   := 1
 Tamanho   := "M"
 nCaracter := 18
 Limite    := 80 
 aOrdem    := {} 
 Titulo    := STR0001  // "Consumo Por Almoxarifado"
 nLastKey  := 0
 aReturn   := { STR0002, 2,STR0003, 1, 4, "LPT1", "",1 }  // "Zebrado", "Administracao"
 NomeProg  := "HSPAHR36"
 cNomeRel  := "HSPAHR36"
 aDriver   := LeDriver()
 cCompac   := aDriver[1]
 cNormal   := aDriver[2]
 cDrive    := "Epson.drv"
 cNomeImp  := "LPT1" 
 cAlias    := "SD3"
 cString   := "SD3"

 wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
 If nLastKey == 27
  Return
 Endif
 SetDefault(aReturn,cString)
 If nLastKey == 27
  Return
 Endif
 Processa({|| RptProc() } )  //Gera e imprime o relatorio

Return(nil)


Static Function RptProc()
 Local i:= 0 
 M->DESALM := space(30)
 
 DbSelectArea("SX5")
 DbSeek(xFilial("SX5")+"AL"+Mv_Par03)
 if Found()
  M->DESALM := SX5->X5_DESCRI
 endif   

 DbSelectArea("SD3")
 dbsetOrder(6) // filial, documento
 DBGoTop() 
 nTReg := 1

 DbSeek(xFilial("SD3")+Dtos(Mv_Par01),.T.)

 while !eof() .and. DTOS(sd3->d3_emissao) <= Dtos(Mv_Par02)
  if SD3->D3_LOCAL <> Mv_Par03 .or. !(Alltrim(SD3->D3_TM) $ "503/506/507/527/600/999/005") 
   DBSkip()
   Loop
  endif  
    
  nTReg := nTReg + 1
    
  DbSelectArea("SD3")
  dbskip()              
	
 enddo

 ProcRegua(nTReg)

 nTotal   :=   nValor := nQuant := 0
 aVetRes  := {}
 aConsumo := {} 
 cTipro    := space(12)

 dbsetOrder(6) // filial, documento
 DBGoTop() 
 DbSeek(xFilial("SD3")+Dtos(Mv_Par01),.T.)

 while !eof() .and. DTOS(sd3->d3_emissao) <= Dtos(Mv_Par02)
  if SD3->D3_LOCAL <> Mv_Par03 .or. !(Alltrim(SD3->D3_TM) $ "503/506/507/527/600/999/005") 
   DBSkip()
   Loop
  endif  
    
  DbSelectArea("SF5")
  DbSeek(xFilial("SF5")+sd3->d3_tm,.t.)

  DbSelectArea("SB1")
  DbSeek(xFilial("SB1")+sd3->d3_cod,.t.)

  DbSelectArea("GBI")
  DbSeek(xFilial("GBI")+sd3->d3_cod,.t.)

  DbSelectArea("SAH")
  DbSeek(xFilial("SAH")+SB1->B1_SEGUM)
    
  cDesc := STR0004 //"CONSUMO"
    
  If GBI->GBI_TIPO == "0" // 0-Materiais
   cTipro := STR0006 //"MATERIAIS   "
  ElseIf GBI->GBI_TIPO == "1" // 1-Medicamentos
   cTipro := STR0005 //"MEDICAMENTOS"
  Else // 2-Outros
   cTipro := STR0007 //"OUTROS      "
  Endif
  
  IncProc(STR0008 + SD3->D3_COD + DTOC(SD3->D3_EMISSAO)) //"Processando o Produto..: "
    
  cCodMov := SD3->D3_TM
  cTipo   := SD3->D3_CF
  nPos    := Ascan(aVetRes,{|x| x[1] + x[9]  == SD3->D3_COD + cDesc})
       
  if nPos > 0                                              
   if Alltrim(SD3->D3_TM) $ "503/506/507/527/600/999"
    aVetRes[nPos,4] := aVetRes[nPos,4] +  SD3->D3_QUANT
    aVetRes[nPos,5] := aVetRes[nPos,5] +  SD3->D3_CUSTO1
   Elseif Alltrim(SD3->D3_TM) $ "005"
    aVetRes[nPos,4] := aVetRes[nPos,4] -  SD3->D3_QUANT
    aVetRes[nPos,5] := aVetRes[nPos,5] -  SD3->D3_CUSTO1
   endif
  else                               
   if Alltrim(SD3->D3_TM) $ "503/506/507/527/600/999"
    nValor := nValor +  SD3->D3_CUSTO1
    nQuant := nQuant +  SD3->D3_QUANT
   Elseif Alltrim(SD3->D3_TM) $ "005"
    nValor := nValor -  SD3->D3_CUSTO1
    nQuant := nQuant -  SD3->D3_QUANT
   endif
   aadd(aVetRes,{SB1->B1_COD,SB1->B1_DESC,SAH->AH_UMRES,nQuant,nValor,sd3->d3_emissao,cCodMov,cTipo,cDesc,cTipro})
  Endif	

  nQuant := nValor := 0
	
  DbSelectArea("SD3")
  dbskip()              
	
 enddo

 Set Printer to &cNomeRel
 Set Printer On
 Set Device  to Printer
 nLin := 1
 SETPRC(0,0)

 nTipo := If(aReturn[4]==1,15,18)
 TotMed := TotMat := TotOut := 0
 
 aSort(aVetRes,,,{|x,y| x[2] < y[2]})

 For i := 1 to len(aVetRes)
  if nlin == 1    
   Titulo := STR0001 //"CONSUMO POR ALMOXARIFADO"
   Cabec1 := STR0009+Dtoc(Mv_Par01)+STR0010+Dtoc(Mv_Par02)+STR0011+Mv_Par03+" - "+M->DESALM //"PERIODO..: "###" Ate "###"      ALMOXARIFADO...: "
   Cabec2 := STR0012 //"CODIGO           DESCRICAO DO PRODUTO                                      APRESENTACAO       QUANT.         VALOR"
   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nlin:=8
   @ nLin,00 PSAY CHR(18)
   nlin:=nlin+1
  endif
  @ nLin,00 PSAY CHR(15)+aVetRes[i,1]+"  "+aVetRes[i,2]+"                  "+aVetRes[i,3]+"             "+TRANSFORM(aVetRes[i,4],"@E 99,999.9999")+" "+TRANSFORM(aVetRes[i,5],"@E 999,999,999.99")
  nlin:=nlin+1
  nTotal := nTotal + aVetRes[i,5]
  If aVetRes[i,10] == STR0013 //'MEDICAMENTOS'
   TotMed := TotMed +aVetRes[i,5]
  ElseIf aVetRes[i,10] == STR0014 //'MATERIAIS   '
   TotMat := TotMat +aVetRes[i,5]
  ElseIf aVetRes[i,10] == STR0015 //'OUTROS      '
   TotOut := TotOut +aVetRes[i,5]
  Endif
  if nLin == 60
   nlin := 1
  endif       
 Next

 if nTotal > 0
  @ nLin,00 PSAY CHR(15)+STR0016+SPACE(74)+TRANSFORM(nTotal,"@E 999,999,999.99") //"TOTAL DE CONSUMO    ---> "
  nlin := nlin + 2
  @ nLin,00 PSAY CHR(15)+STR0017 //">>>            RESUMO           <<<"
  nlin := nlin + 1
  @ nLin,00 PSAY CHR(15)+STR0018+SPACE(05)+TRANSFORM(TotMed,"@E 999,999,999.99") //"MEDICAMENTOS -> "
  nlin := nlin + 1
  @ nLin,00 PSAY CHR(15)+STR0019+SPACE(05)+TRANSFORM(TotMat,"@E 999,999,999.99") //"MATERIAIS    -> "
  nlin := nlin + 1
  @ nLin,00 PSAY CHR(15)+STR0020+SPACE(05)+TRANSFORM(TotOut,"@E 999,999,999.99") //"OUTROS       -> "
 endif

 SET DEVICE TO SCREEN

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()

///////////////////////////////////////////////////////////////////////////////
/*-----------------------------------------------------------------------------
Fun็ใo   VALIDPERG
Descri็ใo Verifica e inclui as perguntas no sx1
------------------------------------------------------------------------------*/
Static Function ValidPerg
 Local i:=0, j:=0
 _sAlias := Alias()
 dbSelectArea("SX1")
 dbSetOrder(1)
 aRegs :={}

 AADD(aRegs,{"HSPR36","01",STR0021,"","","mv_ch1","D",8,0,0,"G",""	,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","N"}) //"Dt Inicial  "
 AADD(aRegs,{"HSPR36","02",STR0022,"","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","N"}) //"Dt Final    "
 AADD(aRegs,{"HSPR36","03",STR0023,"","","mv_ch3","C",2,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","AL","N"}) //"Almoxarifado"
 
 cPerg :=aRegs[1,1]

 For i:=1 to Len(aRegs)
  dbSeek(cPerg+aRegs[i,2])
  if !found()
   RecLock("SX1",.T.)
   For j:=1 to FCount()
    If j <= Len(aRegs[i])
	 FieldPut(j,aRegs[i,j])
	Endif
   Next
   MsUnlock()
  endif
 Next
 dbSelectArea(_sAlias)

Return
