#INCLUDE "HSPAHRB2.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"
#define ESC          27
#define TRACE        repl("_",132)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRB2  บ Autor ณ MARCELO JOSE       บ Data ณ  23/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ PLANILHA DE ENTREGA DOS CONVENIOS                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRB2()
 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := STR0003 //"PLANILHA DE ENTREGA DOS CONVENIOS"
 Local cPict          := ""
 Local titulo         := STR0003 //"PLANILHA DE ENTREGA DOS CONVENIOS"
 Local nLin           := 80

 Local Cabec1         := STR0004 //"Lote  -----Convenios -----  ----  N.F. ----  --No.Processo--  Urg.  ----VlrR$---  Int.  ---VlrR$----  ---TotalR$--  -Emis-  -Prev-"
 Local Cabec2         := ""
 Local imprime        := .T.
 Local aOrd           := {}

 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 132
 Private tamanho      := "p"
 Private nomeprog     := "HSPAHRB2" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo        := 15
 Private aReturn      := {STR0005 , 1,STR0006, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private CONTFL       := 01
 Private m_pag        := 01
 Private wnrel        := "HSPAHRB2" // Coloque aqui o nome do arquivo usado para impressao em disco
 Private cString      := "GAT"
 Private cPerg        := "HSPRB2"

 Private aConvenio    := {}
 
 FS_IniX1()

 If !Pergunte(cPerg,.T.)
 	return
 EndIf
 
 titulo := STR0007+STR0008 + DTOC(MV_PAR01) + STR0009 + DTOC(MV_PAR02) //"PLANILHA DE ENTREGA DOS CONVENIOS  "###"de "###" ate "
 
 // Monta a interface padrao com o usuario...
 wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .F.)

 Processa({|| FS_MontaM()})

 If nLastKey == ESC
 	Return(Nil)
 Endif

 SetDefault(aReturn, cString)

 If nLastKey == ESC
 	Return(Nil)
 Endif

 nTipo := If(aReturn[4] == 1, 15, 18)

 // Processamento RPTSTATUS monta janela com a regua de processamento.
 RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin)}, Titulo)
Return(Nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณ FS_MontaM() บ Autor ณ MARCELO JOSE    บ Data ณ  23/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta matriz para impressao                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MontaM()

 Local cDesCon := "", cCodCon := "", cNumLot := "", nUrg := 0, nInt := 0, cNf := "", nVlrUrg := 0, nVlrInt := 0
 Local nDiaInt := 0
 DbSelectArea("GAT")
 DbSetOrder(1)
 ProcRegua(RecCount()) // SETREGUA -> Indica quantos registros serao processados para a regua 
 DbGoTop()                                 
 While !Eof() .And. GAD->GAD_FILIAL == xFilial("GAD") 
  
  IncProc(STR0006)  //"Aguarde, processando dados"
  
  If GAT->GAT_DTCRI  < mv_par01 .Or. GAT->GAT_DTCRI  > mv_par02 .Or.;  // filtra DATA
     GAT->GAT_CODCON < mv_par03 .Or. GAT->GAT_CODCON > mv_par04        // filtra CONVENIO
 	 DbSkip() // Avanca o ponteiro do registro no arquivo
 	 Loop
  Endif
  
  cCodCon := GAT->GAT_CODCON
  cNumLot := GAT->GAT_NUMLOT
  cDesCon := Posicione("GA9", 1, xFilial("GA9") + GAT->GAT_CODCON, "GA9_NREDUZ")
  nDiaInt := Posicione("GA9", 1, xFilial("GA9") + GAT->GAT_CODCON, "GA9_DFTINT")

  _Area1  :=  Alias()
    
  DbSelectArea("GAD")
  DbSetOrder(12)
  DbSeek(xFilial("GAD") + cCodCon+cNumLot, .T.)
  If Found()
  While !Eof() .And. cCodCon == GAD->GAD_CODCON .And. cNumLot == GAD->GAD_NUMLOT
   If GAD->GAD_ATEURG == "1"
    nVlrUrg := HS_ValAte(GAD->GAD_REGATE, "F", .F.)[4]
    nUrg++
   Else
    nVlrInt := HS_ValAte(GAD->GAD_REGATE, "F", .F.)[4]
    nInt++
   EndIf
   If !Empty(GAD->GAD_NRNOTA)
    cNf := GAD->GAD_NRNOTA
   Else
    cNf := space(15)
   EndIf
   DbSkip()
  End
  Endif
  
  DbSelectArea(_Area1)
  cEntrega := Str(nDiaInt,2,0)+"/"+HS_MesExt(VAL(SUBS(DTOC(MV_PAR01),4,2)))
  cPrevis  := Str(nDiaInt,2,0)+"/"+HS_MesExt(VAL(SUBS(DTOC(MV_PAR01),4,2))+1)
  // nPosVet := aScan(aConvenio, {| aVetTmp | aVetTmp[2] == GAD->GAD_CCUINT})
	 aAdd(aConvenio,{cNumLot, cDesCon, cNf, GAT->GAT_NUMPRO, nUrg, nVlrUrg, nInt, nVlrInt, nVlrUrg+nVlrInt, cEntrega  , cPrevis })
	 nUrg    := 0
	 nInt    := 0
	 nVlrUrg := 0
	 nVlrInt := 0
	 nDiaInt := 0
	 cEntrega := "      "
	 cPrevis  := "      "
	 DbSkip() 
 End
 aSort(aConvenio,,,{|x,y| x[2] < y[2]}) 
Return(Nil)
//******************************************************************************************************************
//Funcao    RUNREPORT  Autor : AP6 IDE               Data   23/09/04                                               *
//Descricao Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.*
//Uso       Programa principal                                                                                     *
//******************************************************************************************************************
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
 
 Local nCtaFor := 1, nTotUrg := 0; nTotInt := 0; nTotGer := 0 
 
 If lAbortPrint
	 @ nLin, 00 Psay STR0007
  Return(Nil)
	EndIf     // Verifica o cancelamento pelo usuario...
	
 //Impressao do cabecalho do relatorio. Salto de Pแgina. Neste caso o formulario tem 55 linhas...
 	Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)

 nLin := 08

 If Len(aConvenio) > 0
  For nCtaFor := 1 to Len(aConvenio)
  
   If nLin > 55 //Impressao do cabecalho do relatorio. Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		 	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		 	nLin := 08
		 EndIf

   @ nLin, 00 Psay aConvenio[nCtaFor,1] + Space(2)  + aConvenio[nCtaFor,2] + ;
                                           Space(2)  + aConvenio[nCtaFor,3] + ;
                                           Space(2)  + aConvenio[nCtaFor,4] + ;
                                           Space(2)  + Transform(aConvenio[nCtaFor, 5],        "9999") + ;
                                           Space(2)  + Transform(aConvenio[nCtaFor, 6],"9,999,999.99") + ;
                                           Space(2)  + Transform(aConvenio[nCtaFor, 7],        "9999") + ;
                                           Space(2)  + Transform(aConvenio[nCtaFor, 8],"9,999,999.99") + ;
                                           Space(2)  + Transform(aConvenio[nCtaFor, 9],"9,999,999.99") + ;
                                           Space(2)  + aConvenio[nCtaFor,10] +; 
                                           Space(2)  + aConvenio[nCtaFor,11] 
   nLin++
   @ nLin,00 Psay TRACE
   nLin++
   nTotUrg := nTotUrg + aConvenio[nCtaFor, 6]
   nTotInt := nTotInt + aConvenio[nCtaFor, 8]
   nTotGer := nTotGer + aConvenio[nCtaFor, 6] + aConvenio[nCtaFor, 8]
  Next   
 endif 
 @ nLin, 40 Psay STR0010
 @ nLin, 68 Psay Transform(nTotUrg,"9,999,999.99")
 @ nLin, 88 Psay Transform(nTotInt,"9,999,999.99")
 @ nlin,102 Psay Transform(nTotGer,"9,999,999.99")

 // Finaliza a execucao do relatorio...
 SET DEVICE TO SCREEN

 // Se impressao em disco, chama o gerenciador de impressao...
 If aReturn[5]==1
	 dbCommitAll()
	 SET PRINTER TO
	 OurSpool(wnrel)
 Endif

 MS_FLUSH()
Return(Nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณ FS_IniX1()   บ Autor ณ MARCELO JOSE   บ Data ณ  23/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Inicia SX1 p/receber parametros selecionados pelo usuario  บฑฑ
ฑฑบ          ณ Nil FS_IniX1(Nil)                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_IniX1()

 Local aHelpPor := {}
 Local aHelpSpa := {}
 Local aHelpEng := {}
 Local aRegs    := {}

 _sAlias := Alias()
 DbSelectArea("SX1")

 If MsSeek(cPerg) // Se encontrar a pergunta , nใo faz nada, pois ja foi criada.
 	DbSelectArea(_sAlias)
 	Return
 Endif

 // Da Data
 AADD(aHelpPor,"Informe a data INICIAL para a      ")
 AADD(aHelpPor,"pesquisa...             											")
 AADD(aHelpSpa,"                                   ")
 AADD(aHelpSpa,"              																					")
 AADD(aHelpEng,"                                   ")
 AADD(aHelpEng,"                                   ")
 AADD(aRegs,{STR0011,STR0011,STR0011,"mv_ch1","D",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})
 
 // Ate Data
 aHelpPor := {}
 aHelpSpa := {}
 aHelpEng := {}
 AADD(aHelpPor,"Informe a data FINAL para a        ")
 AADD(aHelpPor,"pesquisa...             											")
 AADD(aHelpSpa,"                                   ")
 AADD(aHelpSpa,"              																					")
 AADD(aHelpEng,"                                   ")
 AADD(aHelpEng,"                                   ")
 AADD(aRegs,{STR0012,STR0012,STR0012,"mv_ch2","D",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})

 // do convenio 
 aHelpPor := {}
 aHelpSpa := {}
 aHelpEng := {}
 AADD(aHelpPor,"Informar o codigo do convenio      ")
 AADD(aHelpPor,"inicial. 																					    	")
 AADD(aHelpSpa,"Informar o codigo do convenio      ")
 AADD(aHelpSpa,"inicial. 																					    	")
 AADD(aHelpEng,"Informar o codigo do convenio      ")
 AADD(aHelpEng,"inicial. 																					    	")
 AADD(aRegs,{STR0013,STR0013,STR0013,"mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","GA9","N","","",aHelpPor,aHelpEng,aHelpSpa})

 // ate o convenio
 aHelpPor := {}
 aHelpSpa := {}
 aHelpEng := {}
 AADD(aHelpPor,"Informar o codigo do convenio      ")
 AADD(aHelpPor,"Final. 																					    	  ")
 AADD(aHelpSpa,"Informar o codigo do convenio      ")
 AADD(aHelpSpa,"Final. 																					    	  ")
 AADD(aHelpEng,"Informar o codigo do convenio      ")
 AADD(aHelpEng,"Final. 																					    	  ")
 AADD(aRegs,{STR0014,STR0014,STR0014,"mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","GA9","N","","",aHelpPor,aHelpEng,aHelpSpa})

 AjustaSx1(cPerg, aRegs)
 DbSelectArea(_sAlias)
Return(Nil)
//******************************************************************************************************************
Static Function HS_MesExt(nVemMes)

 Local cVaiMes := ""
 
 If nVemMes == 13
    nVemMes := 1
 EndIf
  
 If nVemMes == 1
  cVaiMes := "Jan"
 ElseIf nVemMes ==2
  cVaiMes := "Fev" 
 ElseIf nVemMes ==3
  cVaiMes := "Mar"
 ElseIf nVemMes ==4
  cVaiMes := "Abr"
 ElseIf nVemMes ==5
  cVaiMes := "Mai"
 ElseIf nVemMes ==6
  cVaiMes := "Jun"
 ElseIf nVemMes ==7
  cVaiMes := "Jul"
 ElseIf nVemMes ==8
  cVaiMes := "Ago"
 ElseIf nVemMes ==9
  cVaiMes := "Set"
 ElseIf nVemMes ==10
  cVaiMes := "Out"
 ElseIf nVemMes ==11
  cVaiMes := "Nov"
 ElseIf nVemMes ==12
  cVaiMes := "Dez"
 Else
  cVaiMes := "xxx"
 EndIf 
  
Return(cVaiMes)
//******************************************************************************************************************
