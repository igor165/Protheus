#INCLUDE "HSPAHR04.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR04  บ Autor ณEquipe G. Hospitalarบ Data ณ Agosto/2003 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Emissao de Devolucao                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
FUNCTION HSPAHR04(cParam,cCodLocFar) 

Local lImpCupom := .F.

Private aDev    := {}
Private cPort   := ""
Private  aReturn  := { STR0002, 2,STR0003, 2, 4, "LPT1", "",1 } //"Zebrado"###"Administracao"
Private lTamProd := IIf((TamSx3("GAF_CCOKIT")[1])<=15, .T., .F.)

cCodLocFar := IIf(cCodLocFar == Nil, "", cCodLocFar)

 cParam1 := cParam
 If Type("cParam1") == "U"
  if !Pergunte("HSPR04",.t.)
   Return(Nil)
  Else 
  	lImpCupom := IIF(MV_PAR02 == 1,.F.,.T.)
  	If MV_PAR03 == 1
    cPort   := "LPT1"
   ElseIf MV_PAR03 == 2
    cPort   := "LPT2" 
   ElseIf MV_PAR03 == 3
    cPort   := "COM1"  
   ElseIf MV_PAR03 == 4
    cPort   := "COM2"         
   ElseIf MV_PAR03 == 5
    cPort   := "COM3"  
   EndIf
  Endif     
 Else   
  Mv_Par01 := cParam1
 Endif

 m_pag	 := 1
 cTamanho := "M"          // P/M/G
 nCaracter:= 18
 Limite   := 80           // 80/132/220
 aOrdem   := {}           // Ordem do Relatorio
 cTitulo  := STR0001 //"Devolucao de Produtos"
 nLastKey := 0

 cNomProg := "HSPAHR04"
 cNomeRel := "HSPAHR04"
 cDrive   := "Epson.drv"
 cNomeImp := "LPT1"
 cAlias   := "GBD"
 
 DbSelectArea("GBD")
 DBSetOrder(1)
 DbSeek(xFilial("GBD") + Mv_Par01)    
 
 DbSelectArea("GCS")
 DbSetOrder(1)
 DbSeek(xFilial("GCS") + GBD->GBD_CODLOC)
 
       
 If !EMPTY(cCodLocFar) .AND. cParam <> Nil
  
  lImpCupom := IIF( GCS->GCS_IMPCUP == '0', .F., .T.) // 0 = Imp Normal  1= Imp CUpom
  If GCS->GCS_IMPORT == '0'
   cPort   := "LPT1"
  ElseIf GCS->GCS_IMPORT == '1'
   cPort   := "LPT2" 
  ElseIf GCS->GCS_IMPORT == '2'
   cPort   := "COM1"  
  ElseIf GCS->GCS_IMPORT == '3'
   cPort   := "COM2"         
  ElseIf GCS->GCS_IMPORT == '4' 
   cPort   := "COM3"  
  ElseIf GCS->GCS_IMPORT == '5'
   cPort   := "COM4"  
  EndIf
 EndIf
  
 cString1 := ""

 If Type("cParam1") <> "U"
  cCabec2  := STR0004 + cString1 + Space(19) + STR0005 +Subs(GBD->GBD_LOGARQ,1,13) //"DEVOLUCAO       "###"OPERADOR "
 Else   
  cCabec2  := STR0006 + cString1 + Space(07) + STR0005 +Subs(GBD->GBD_LOGARQ,1,13) //"REIMPRESSAO DE DEVOLUCAO    "###"OPERADOR "
 Endif   
 LServer := nil
 cNaoMostra := .f.

 // Parametros da SetPrint
 // 15 cDrive
 // 16 passa .t. p/ nao chamar tela
 // 17 lserver = .t., imprime no servidor
 // 18 LPT1
 
 If !lImpCupom
  cNomeRel := SetPrint(cAlias,cNomeRel,nil ,@cTitulo,"","","",.F.,"",.F.,cTamanho,nil    ,nil    ,nil /*,cDRive,cNaoMostra, LServer,cNomeImp*/)
 
  If nLastKey == 27 
   DbClearFilter()
   Return
  Endif
  
  SetDefault(aReturn,cAlias)

  Set Printer to &cNomeRel
  Set Printer On
  Set Device  to Printer
  nLin := 1
  SETPRC(0,0)
  _passou := .f.
 EndIf
        
 DbSelectArea("GBE")
 DBSetOrder(1)
 If DbSeek(xFilial("GBE") + Mv_Par01)
  DbSelectArea("GCY")
  DbSetOrder(1)
  DbSeek(xFilial("GCY") + GBD->GBD_REGATE)                            
  
		DbSelectArea("GCZ")
		DbSetOrder(2)
		DbSeek(xFilial("GCZ") + GCY->GCY_REGATE)

  DbSelectArea("GBE")
  cCabec1  := STR0007 + Space(22) + GCS->GCS_NOMLOC //"SISTEMA DE GESTAO HOSPITALAR"

  nLin := cabec(ctitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter) + 1

  @ nLin, 000 PSAY STR0015 + GBD->GBD_NUMDEV  //"DEVOLUCAO..: "
  @ nLin, 030 PSAY STR0016 + GCS->GCS_NOMLOC  //"SETOR: "
  @ nLin++, 100 PSAY STR0017 + DTOC(GBD->GBD_DATDEV)  //"DATA: "
//  @ nLin, 120 PSAY "HORA: " + GDB->GDB_HORDEV  
  
  @ nLin,   000 PSAY STR0034 + GCS->GCS_CODCCU  //"COD. C.CUSTO: "
  @ nLin++, 067 PSAY STR0035 + HS_RDescCC(GCS->GCS_CODCCU)  //"DESC. C.CUSTO: "
  
  If GCY->GCY_ATENDI == "0"
   @ nLin, 000 PSAY STR0018 + GBD->GBD_REGATE + "  " + GCY->GCY_NOME //"ATENDIMENTO: "
   @ nLin, 070 PSAY STR0019 + GCY->GCY_REGGER //"PRONTUARIO: "
   @ nLin, 100 PSAY STR0020 + GCY->GCY_QUAINT  //"QUARTO: "
   @ nLin++, 120 PSAY STR0021 + GCY->GCY_LEIINT  //"LEITO: "
  Else   
   @ nLin, 000 PSAY STR0018 + GBD->GBD_REGATE + "  " + GCY->GCY_NOME //"ATENDIMENTO: "
   @ nLin, 070 PSAY STR0019 + GCY->GCY_REGGER //"PRONTUARIO: "
   @ nLin++,100 PSAY STR0021 + GCY->GCY_LEIINT     //"LEITO: "
  Endif   
  
  @ nLin, 000 PSAY STR0022 + POSICIONE("SRA", 11, xFilial("SRA")+GCY->GCY_CODCRM, "RA_NOME")  //"MEDICO RESPONSAVEL: "
  @ nLin, 070 PSAY STR0023 + POSICIONE("GCM",  2, xFilial("GCM")+GCZ->GCZ_CODPLA, "GCM_DESPLA")   //"PLANO: "
 	nLin++
 	@ nLin, 000 PSAY REPLICATE("-", 132)
	 nLin++
 	@ nLin++, 00 PSAY Iif(lTamProd,STR0024,STR0036)  //"PRODUTO                                                            APRESENTACAO    QTD. A DEVOLVER         OBSERVACOES"
  @ nLin++, 00 PSAY REPLICATE("-", 132)
  
  While !Eof() .And. GBE->GBE_FILIAL == xFilial("GBE") .And. GBE->GBE_NUMDEV == Mv_Par01
   DbSelectArea("SB1")
   DBSetOrder(1)
   DbSeek(xFilial("SB1") + GBE->GBE_PRODEV)

/*   DbSelectArea("SAH")     
   DbSetOrder(1)
   DbSeek(xFilial("SAH") + SB1->B1_SEGUM) */
   
        
   cObserv := "_________________________"
   If nLin == 30
    _passou := .t.
   	nLin := nLin + 1 
    @ nLin++,00 PSAY ""
	   nLin := 1
	   SETPRC(0,0)
    @ nLin++, 000 PSAY STR0015 + GBD->GBD_NUMDEV  //"DEVOLUCAO..: "
	   @ nLin++, 000 PSAY REPLICATE("-", 80)
 	  @ nLin++, 000 PSAY Iif(lTamProd,STR0024,STR0036) //"PRODUTO                                          APRESENTACAO    QTD.DEVOLVIDA  QTD.DESCARTADA  QTD.A DEVOLVER  OBSERVACOES"
   	@ nLin++, 000 PSAY REPLICATE("-", 80)
   Endif   
   
   aAdd(aDev, {GBE->GBE_PRODEV, SB1->B1_DESC, SB1->B1_UM,TRANSFORM(GBE->GBE_QTDADV,"@E 999.9999"),;
              	cObserv,GBE->GBE_QTDADV})
   
   @ nLin, 001   PSAY GBE->GBE_PRODEV
   @ nLin, Iif(lTamProd,018,033)   PSAY SB1->B1_DESC 
   @ nLin, Iif(lTamProd,054,069)   PSAY SB1->B1_UM 
   @ nLin, Iif(lTamProd,067,082)   PSAY TRANSFORM(GBE->GBE_QTDDEV, "@E 9999.9999")
   @ nLin, Iif(lTamProd,082,097)   PSAY TRANSFORM(GBE->GBE_QTDESC, "@E 9999.9999")
   @ nLin, Iif(lTamProd,098,113)   PSAY TRANSFORM(GBE->GBE_QTDADV, "@E 9999.9999") 
   @ nLin++, Iif(lTamProd,113,128) PSAY cObserv

   DbSelectArea("GBE")
   DbSkip()
		 
  Enddo
   
  If lImpCupom                                                 
   FS_ImpCup()
   Return(nil)
  EndIf
  
  if _passou == .t.
   while nLin < 30
    nLin := nLin + 1
   Enddo                        
   nLin := nLin + 5
   @ nLin++,00 PSAY ""
  else
   while nLin < 30
    nLin := nLin + 1
   Enddo                        
   nLin := nLin + 3 // +3
   @ nLin++,00 PSAY ""
  endif   
 Else
  HS_MsgInf(STR0025, STR0026, STR0001) //"Nenhum registro foi encontrado"###"Aten็ใo"###"Devolucao de Produtos"
  Return(Nil)
 Endif
 
 If !lImpCupom
  Ms_Flush()              
  Set Printer to
  Set Device  to Screen
  if aReturn[5] == 1
   OurSpool(cNomeRel)
  Endif  
 EndIf  

Return

/****************************************************************************************************************/
Static Function FS_ImpCup()
Local cConteudo := ""
Local nCnt      := 0
Local nTotQtd   := 0

Local nH   // VARIAVEL UTILIZADA PARA ABERTURADA DA PORTA

//																			 1         2         3         4       
//          012345678901234567890123456789012345678901234567
cConteudo += PADR(STR0017 + DTOC(GBD->GBD_DATDEV),24)/* + PADL("Hora: " + GAI->GAI_HORSOL,23)*/ + chr(13)+chr(10) //"Data: "
cConteudo += PADR("==== ",12)+ STR0027	+	PADL(" ====",13) + 	chr(13)+chr(10) //"Relacao de conferencia"
cConteudo += "" + chr(13)+chr(10)
cConteudo += PADC(ALLTRIM(POSICIONE("GCS", 1, xFilial("GCS") + GCY->GCY_LOCATE, "GCS_NOMLOC")),45) + chr(13)+chr(10)
cConteudo += "" + chr(13)+chr(10)
cConteudo += STR0028 + GCY->GCY_REGGER + " " + SUBSTR(GCY->GCY_NOME,1,27) + chr(13)+chr(10) //"PACIENTE...: "
cConteudo += STR0029 + GBD->GBD_NUMDEV + chr(13)+chr(10) //"DEVOL. No..: "
cConteudo += STR0030 + GBD->GBD_CODLOC + " - " + SUBSTR(POSICIONE("GCS", 1, xFilial("GCS") + GBD->GBD_CODLOC, "GCS_NOMLOC"),1,28) + chr(13)+chr(10) //"SETOR DEST.: "
cConteudo += "" + chr(13)+chr(10)
cConteudo += "            COD ITEM               UND     QTDE" + chr(13)+chr(10)
For nCnt := 1  To Len(aDev)    
 cConteudo += PADL(ALLTRIM(aDev[nCnt,1]),15) + " " + SUBSTR(aDev[nCnt,2],1,18)+ " " + aDev[nCnt,3] + "  " + aDev[nCnt,4] + chr(13)+chr(10)
 nTotQtd += aDev[nCnt,6]
Next
cConteudo += "" + chr(13)+chr(10)
cConteudo += REPLICATE("-",47) + chr(13)+chr(10)
cConteudo += STR0031 + chr(13)+chr(10) //"TOTAIS"
cConteudo += "" + chr(13)+chr(10)
cConteudo += STR0032 + TRANSFORM(LEN(aDev),"@E 999,999") + STR0033 + TRANSFORM(nTotQtd,"@E 999.999") + chr(13)+chr(10) //"ITENS: "###"       QUANTIDADE: "
cConteudo += REPLICATE("-",47) + chr(13)+chr(10)
cConteudo += "" + chr(13)+chr(10)
cConteudo += "" + chr(13)+chr(10)
cConteudo += "" + chr(13)+chr(10)
cConteudo += "" + chr(13)+chr(10)
cConteudo += "" + chr(13)+chr(10)
cConteudo += "" + chr(13)+chr(10)
cConteudo += "" + chr(13)+chr(10)
cConteudo += "" + chr(13)+chr(10)
cConteudo += "" + chr(13)+chr(10)
cConteudo += "" + chr(13)+chr(10)
cConteudo += "" + chr(13)+chr(10)
cConteudo += "" + chr(13)+chr(10)

nH := CBOpenPort(cPort)
Fwrite(nH,cConteudo)
Fclose(nH)

Return()
