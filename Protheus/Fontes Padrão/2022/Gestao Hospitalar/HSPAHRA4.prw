#INCLUDE "HSPAHRA4.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"
#define ESC          27
#define TRACE        repl("_",131)
#define TRACEDUPLO   repl("=",131)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHRA4  º Autor ³ MARCELO JOSE       º Data ³  03/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ NUMERO DE OBITOS POR CONVENIOS                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHRA4()
 Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := "de acordo com os parametros informados pelo usuario."
 Local cDesc3         := STR0009
 Local cPict          := ""
 Local titulo         := STR0009
 Local nLin           := 80

 Local Cabec1         := STR0014
 Local Cabec2         := ""
 Local imprime        := .T.
 Local aOrd := {}

 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 80
 Private tamanho      := "P"
 Private nomeprog     := "HSPAHRA4" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo        := 18
 Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
 Private nLastKey     := 0
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private CONTFL       := 01
 Private m_pag        := 01
 Private wnrel        := "HSPAHRA4" // Coloque aqui o nome do arquivo usado para impressao em disco
 Private cString      := "GAD"
 Private cPerg        := "HSPRA4"
 
 IniciaX1()

 If !Pergunte(cPerg,.T.)
 	return
 EndIf

 // Monta a interface padrao com o usuario...
 wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .F.)

 If nLastKey == ESC
 	Return
 Endif

 SetDefault(aReturn, cString)

 If nLastKey == ESC
 	Return
 Endif

 nTipo := If(aReturn[4] == 1, 15, 18)

 // Processamento RPTSTATUS monta janela com a regua de processamento.
 RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin)}, Titulo)
Return

//******************************************************************************************************************
//Funcao     RUNREPORT  Autor : AP6 IDE               Data   15/07/04
//Descricao  Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.
//Uso        Programa principal
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
 Local aVetor := {}
 Local cTipoAlta := "", cPar := "", nCtafor := 0, nTotal    := 0, nCtaOb := 0

 // SETREGUA -> Indica quantos registros serao processados para a regua
 SetRegua(RecCount())                                          

 DbSelectArea("GA9") // busca nome do Convenio            
 DbSetOrder(1)                                            
 DbSeek(xFilial("GA9") + MV_PAR03, .T.)
 // Loop central monta matriz de CONVENIOS
 While !Eof() .And. xFilial("GA9") == GA9->GA9_FILIAL .And. GA9->GA9_CODCON <= MV_PAR04  // filtra PARAMETRO
	 aAdd(aVetor,{GA9->GA9_CODCON, GA9->GA9_NOME, 0})
	 DbSkip() // Avanca o ponteiro do registro no arquivo
 EndDo

 cPar := AllTrim(GetMv("MV_TPALTA"))

 DbSelectArea("GAD")
 DbSetOrder(4)
 DbSeek(xFilial("GAD") + DToS(MV_PAR01), .T.)
                                                           
 // Loop central monta matriz de CONVENIOS
 While !Eof() .And. GAD->GAD_FILIAL == xFilial("GAD") .And. GAD->GAD_DATATE <= MV_PAR02
		If GAD->GAD_TPALTA $ cPar
		 nCtaOb++
	  nCtaFor := aScan(aVetor, {| aVetTmp | aVetTmp[1] == GAD->GAD_CODCON})
	  If nCtaFor > 0
	   aVetor[nCtaFor, 3] += 1
	  EndIf 
	 EndIf 

	 DbSkip() // Avanca o ponteiro do registro no arquivo
 End

 For nCtaFor := 1 To Len(aVetor)  // loop  da 1a.Matriz para impressao do relatorio ***********************************
	 If lAbortPrint
		 @ nLin, 00 PSay STR0008
		 Exit
	 Endif     // Verifica o cancelamento pelo usuario...
	
	 If nLin > 55 //Impressao do cabecalho do relatorio. Salto de Página. Neste caso o formulario tem 55 linhas...
   if nCtafor > 1
      nLin++
      @ nLin, 00 Psay STR0015
   endif
	 	Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
	 	nLin := 8
	 Endif
	
	 @ nLin, 00 PSay aVetor[nCtaFor, 1] + Space(2) + aVetor[nCtaFor,2] + Space(2) + Transform(aVetor[nCtaFor, 3], "9999") + CPCento(aVetor[nCtaFor, 3], nCtaOb)
	 nLin++
	 nTotal++
 Next
 
 @ nLin, 00 PSay TRACE
 nLin := nLin+2
 @ nLin, 00 PSay STR0012 + Transform(nTotal, "999")
 nLin := nLin+2
 @ nLin, 00 PSay STR0013 + Transform(nCtaOb, "999")
 nLin++
 @ nLin,00 PSay TRACEDUPLO
 nLin++

 // Finaliza a execucao do relatorio...
 SET DEVICE TO SCREEN

 // Se impressao em disco, chama o gerenciador de impressao...
 If aReturn[5]==1
	 dbCommitAll()
	 SET PRINTER TO
	 OurSpool(wnrel)
 Endif

 MS_FLUSH()
Return 

//******************************************************************************************************************
//  char _ADVPLdecl  CPCento(int, int) ==> calcula o percentual dos itens avaliados
Static function CPCento(nPCalc, nPTotal)
return(IIf(nPCalc > 0, "  =  "+transform(((nPCalc / nPTotal) * 100), "999.99") + " %", ""))

//******************************************************************************************************************
//  Nil  _ADVPLdecl  IniciaX1(Nil)    ===> Inicia arquivo SX1 para receber parametros selecionados pelo usuario.
Static Function IniciaX1()
 Local aHelpPor := {}
 Local aHelpSpa := {}
 Local aHelpEng := {}
 Local aRegs    := {}

 _sAlias := Alias()
 DbSelectArea("SX1")

 If MsSeek(cPerg) // Se encontrar a pergunta , não faz nada, pois ja foi criada.
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
 AADD(aRegs,{STR0006,STR0006,STR0006,"mv_ch1","D",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})
 
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
 AADD(aRegs,{STR0007,STR0007,STR0007,"mv_ch2","D",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})


 // ATENDIMENTO
 aHelpPor := {}
 aHelpSpa := {}
 aHelpEng := {}
 AADD(aHelpPor,"Informe o Codigo do Conveio inicial")
 AADD(aHelpPor,"para pesquisa                    		")
 AADD(aHelpSpa,"                                   ")
 AADD(aHelpSpa,"              																					")
 AADD(aHelpEng,"                                   ")
 AADD(aHelpEng,"                                   ")
 AADD(aRegs,{STR0010,STR0010,STR0010,"mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","GA9","N","","",aHelpPor,aHelpSpa,aHelpEng})

 // do Medico
 aHelpPor := {}
 aHelpSpa := {}
 aHelpEng := {}
 AADD(aHelpPor,"Informe o codigo do Convenio final ")
 AADD(aHelpPor,"para pesquisa...        											")
 AADD(aHelpSpa,"                                   ")
 AADD(aHelpSpa,"              																					")
 AADD(aHelpEng,"                                   ")
 AADD(aHelpEng,"                                   ")
 AADD(aRegs,{STR0011,STR0011,STR0011,"mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","GA9","N","","",aHelpPor,aHelpSpa,aHelpEng})

 AjustaSx1(cPerg, aRegs)
 DbSelectArea(_sAlias)
Return(Nil)
//******************************************************************************************************************
