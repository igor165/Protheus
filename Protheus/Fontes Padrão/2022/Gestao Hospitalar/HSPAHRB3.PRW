#INCLUDE "HSPAHRB3.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"
#define ESC    27
#define TRACE  repl("_",80)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRB3  บ Autor ณ MARCELO JOSE       บ Data ณ  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RECIBO DE PAGAMENTO DE HONORARIOS MEDICOS                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRB3()
 Local cDesc1        := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2        := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3        := STR0003 //"RECIBO DE PAGAMENTO"
 Local cPict         := ""
 Local titulo        := STR0003 //"RECIBO DE PAGAMENTO"
 Local nLin          := 80

 Local Cabec1        := ""
 Local Cabec2        := ""
 Local imprime       := .T.
 Local aOrd          := {}

 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 80
 Private tamanho     := "P"
 Private nomeprog    := "HSPAHRB3" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := {STR0004 , 1,STR0005, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := "HSPAHRB3" // Coloque aqui o nome do arquivo usado para impressao em disco
 Private cString     := "SE2"
 Private cPerg       := "HSPRB3"
 Private cCpoChave   := "E2_PREFIXO + E2_NUM + E2_PARCELA"
 Private aItensMar   := {}
 Private oDlg , oVemObj

 If !Pergunte(cPerg,.T.)
 	return
 EndIf     
 
 Processa({|| FS_MontaM()})
 IF Len(aItensMar) <= 0
  Return(Nil)
 Endif       

 wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho,, .F.)
 If nLastKey == ESC
 	Return(Nil)
 Endif
 SetDefault(aReturn, cString)
 If nLastKey == ESC
 	Return(Nil)
 Endif
 nTipo := If(aReturn[4] == 1, 15, 18)
 RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin)}, Titulo)
Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao  ณFS_MontaM()   Autor MARCELO JOSE       บ Data ณ  23/09/04   บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricaoณ Monta matriz para impressao                                บฑฑ
ฑฑบ         ณ                                                            บฑฑ
ฑฑฬอออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ AP7 IDE                                                    บฑฑ
ฑฑศอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MontaM()
 Local cCodTdFor:= "", cNomTdFor := "" , oSay1, oBtn1
	Local cCodFor  := "", nCont    := 1
 
 cCodTdFor := HS_RPreMed(MV_PAR01, ,.T.,"F")
 While nCont <= LEN(cCodTdFor)
  If (SUBSTR(cCodTdFor,nCont,1) == '/') .OR. nCont == LEN(cCodTdFor)
   cNomTdFor += IIf(!Empty(cNomTdFor), "/", "") + ALLTRIM( Posicione("SA2",1,xFilial("SA2") + cCodFor ,"A2_NREDUZ" ) )
   cCodFor := ""
  Else
   cCodFor += SUBSTR(cCodTdFor,nCont,1)
  EndIf
  nCont ++
 EndDo 
  
 DbSelectArea("SE2")
 DbSetOrder(9)
 HS_AtvFilt("SE2", "SE2->E2_FORNECE $ '" + cCodTdFor + "'")  
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) From 09, 14 to 38, 94 of oMainWnd //"Guias Pendentes" //"Selecione Recibo"
 oSay1   := tSay():New(15,10,{|| STR0040 + cNomTdFor  },oDlg,,,,,,.T.,,,400,10) //"Fornecedor(s): "
 oVemObj := HS_MBrow(oDlg, "SE2", {25, 25, 280, 150},,,/*cCpoLeg*/, /*aResLeg*/, "E2_OK", /*aResMar*/, @aItensMar, cCpoChave, /*bViewReg*/, .T.)
 ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnChoiceBar(oDlg, {|| oDlg:End()}, {|| oDlg:End()}))
 HS_DtvFilt("SE2") 
Return(Nil)
/*******************************************************************************************************************/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
  
 Local nCtaFor1 := 1 , nCol    := 0 , nPensao := 0 , nTxPen  := 0 , nINSS    := 0 , nISS   := 0, nIRRF := 0
 Local nCofin   :=  0, nLiqui  := 0 , cNome   := "", cNumCta := "", cDia     := "", nTamao := 0
 Local cCid     := "", cRaz    := "", nBruto  := 0 , nMes    := "", nCtaFor2 := 1 , nCfor  := 0, nClin := 0
 Local aData    := {}
 
 If lAbortPrint
	 @ nLin, 00 Psay STR0008 //"CANCELADO PELO OPERADOR"
  Return(Nil)
	EndIf     // Verifica o cancelamento pelo usuario...

 If Len(aItensMar) <= 0
    Return(Nil)
 Endif

	DbSelectArea("GAZ")
 dbGotop()
	cCid := Alltrim(GAZ->GAZ_CIDPRE)+"-"+Alltrim(GAZ->GAZ_ESTPRE)
 cRaz := GAZ->GAZ_RAZPRE
 cCCM := GAZ->GAZ_CCM
 
 DbSelectArea("SRA")
 DbSetOrder(11)
 DbSeek(xFilial("SRA") + MV_PAR01, .T.) 
 If Found()
  cNome   := RA_NOME
  nTxPen  := RA_PENSALI
  cNumCta := ALLTRIM(RA_BCDEPSA) + " " + ALLTRIM(RA_CTDEPSA) 
 Endif

 DbSelectArea("SE2")
 DbSetOrder(1)
 For nCtaFor1 := 1 to Len(aItensMar)
  DbSeek(xFilial("SE2") + SUBS(aItensMar[nCtaFor1,1],1,3) + SUBS(aItensMar[nCtaFor1,1],4,6) + SUBS(aItensMar[nCtaFor1,1],10,1), .T.) 
  If Found()
   aAdd(aData,DTOC(E2_EMISSAO))
   nBruto  := nBruto + E2_VALOR
   nMes    := HS_MesExt(VAL(SUBS(DTOC(E2_VENCTO),4,2))) + STR0009 +SUBS(DTOC(E2_VENCTO),7,2)// ultima data apurada //" de 20"
   cDia    := SUBS(DTOC(E2_VENCTO),1,2) + " "+ nMes // ultimo dia apurado
   nINSS   := nINSS + E2_INSS
   nISS    := nISS  + E2_ISS
   nIRRF   := nIRRF + E2_IRRF  
  Endif
 Next

 nCofin  := (   4.65 * nBruto ) / 100
 nPensao := ( nTxPen * nBruto ) / 100
 nLiqui  := nBruto - (nPensao + nINSS + nISS + nIRRF + nCofin )
 nCol    := 80 - Len(STR0010 + Alltrim(Transform(nBruto,"999,999,999.99")) ) //"R$ "
 nLin    := 4
 nTaman  := Len(STR0010 + Alltrim(Transform(nLiqui,"999,999,999.99"))+ "(" + Extenso(nLiqui,.F.,1 ) + ")") //"R$ "
 nTamao  := STR0011 + cRaz + STR0012  //"Recebi do "###" a importancia de"

 For nCtaFor1 := 1 to 2
     
  @ nLin   ,34   Psay STR0013 //"R E C I B O"
  @ nLin+1 ,34   Psay STR0014 //"- - - - - -"
  @ nLin+3 ,nCol Psay STR0010 + Alltrim(Transform(nLiqui,"999,999,999.99")) //"R$ "
  @ nLin+5 ,03   Psay nTamao
  @ nLin+6 ,00   Psay STR0010 + Alltrim(Transform(nLiqui,"999,999,999.99"))+"(" + Extenso(nLiqui,.F.,1 ) + ")" + 	Replicate("#",(80-nTaman)) //"R$ "
  @ nLin+7 ,00   Psay STR0015 //"Como repasse de Honorario Medico referente ao(s)Titulo(s)-Parcela(s)-Dt.Emissao:"
  nCfor := 0
  nClin := 8
  For nCtafor2 := 1 to Len(aItensMar)
   @ nLin+nClin,nCfor Psay SUBS(aItensMar[nCtaFor2,1],4,6) +"-" + SUBS(aItensMar[nCtaFor2,1],10,1)+"-"+aData[nCtaFor2]
   nCfor := nCfor + 20
   If nCfor > 80
    nCfor := 0
    nClin++
   Endif
  Next 
  If nCfor < 80
   @ nLin+nClin,nCfor Psay Replicate("#",80-nCfor)
  Endif
  @ nLin+nClin+1,00   Psay Replicate("_",80)
  @ nLin+nClin+2,00   Psay cCid + " " + cDia
  @ nLin+nClin+2,49   Psay STR0016 + Transform(nBruto ,"999,999,999.99") //"Valor Bruto....: "
  @ nLin+nClin+3,49   Psay STR0041 + Transform(nPensao,"999,999,999.99") //"Pensao ........: "
  @ nLin+nClin+4,49   Psay STR0017 + Transform(nINSS  ,"999,999,999.99") //"INSS ..........: "
  @ nLin+nClin+5,03   Psay "_______________________________________"
  @ nLin+nClin+5,49   Psay STR0018 + Transform(nIRRF  ,"999,999,999.99") //"IRRF ..........: "
  @ nLin+nClin+6,03   Psay STR0019+cNome //"Dr(a)."
  @ nLin+nClin+6,49   Psay STR0020 + Transform(nCofin ,"999,999,999.99") //"PIS/COFINS/CSLL: "
  @ nLin+nClin+7,17   Psay STR0021+MV_PAR01 //"CRM "
  @ nLin+nClin+7,49   Psay STR0022 + Transform(nISS   ,"999,999,999.99") //"ISS  ..........: "
  If !EMPTY(cNumCta)
   @ nLin+nClin+8,17   Psay STR0023 + cNumCta //"C/C "
  Endif
  @ nLin+nClin+8,49   Psay STR0024 + Transform(nLiqui ,"999,999,999.99") //"Valor liquido .: "
  @ nLin+nClin+9,00   Psay Replicate("_",80)
  If nCtaFor1 == 1
   @ nLin+nClin+11,00   Psay Replicate(".",80)
  Endif
  nLin := nLin+nClin+14
 
 Next

 SET DEVICE TO SCREEN
 If aReturn[5]==1
	 dbCommitAll()
	 SET PRINTER TO
	 OurSpool(wnrel)
 Endif
 MS_FLUSH()
Return(Nil)

/******************************************************************************************************************/
Static Function HS_MesExt(nVemMes)

 Local cVaiMes := ""
 
 If nVemMes == 13
    nVemMes := 1
 EndIf
  
 If nVemMes == 1
  cVaiMes := STR0028 //"Janeiro  "
 ElseIf nVemMes ==2
  cVaiMes := STR0029  //"Fevereiro"
 ElseIf nVemMes ==3
  cVaiMes := STR0030 //"Marco    "
 ElseIf nVemMes ==4
  cVaiMes := STR0031 //"Abril    "
 ElseIf nVemMes ==5
  cVaiMes := STR0032 //"Maio     "
 ElseIf nVemMes ==6
  cVaiMes := STR0033 //"Junho    "
 ElseIf nVemMes ==7
  cVaiMes := STR0034 //"Julho    "
 ElseIf nVemMes ==8
  cVaiMes := STR0035 //"Agosto   "
 ElseIf nVemMes ==9
  cVaiMes := STR0036 //"Setembro "
 ElseIf nVemMes ==10
  cVaiMes := STR0037 //"Outubro  "
 ElseIf nVemMes ==11
  cVaiMes := STR0038 //"Novembro "
 ElseIf nVemMes ==12
  cVaiMes := STR0039 //"Dezembro "
 Else
  cVaiMes := "xxx"
 EndIf 
  
Return(cVaiMes)
/*****************************************************************************************************************/