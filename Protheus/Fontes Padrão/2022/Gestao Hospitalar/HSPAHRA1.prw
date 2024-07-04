#INCLUDE "HSPAHRA1.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"
#define ESC          27
#define TRACE        repl("_",131)
#define TRACEDUPLO   repl("=",131)
#define INTERNACAO   "0"
#define CONSULTA     "1"
#define EXAME        "2"
#define RETORNO      "3"
#define PROCEDIMENTO "4"
#define CURATIVO     "5"
#define RN           "6"
#define AMBOS       3
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRA1  บ Autor ณ MARCELO JOSE       บ Data ณ  15/07/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ATENDIMENTO / MEDICO                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRA1()

 // Declaracao de Variaveis
 Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := "de acordo com os parametros informados pelo usuario."
 Local cDesc3         := "ATENDIMENTO x MEDICO - no Periodo"
 Local cPict          := ""
 Local titulo         := "ATENDIMENTO x MEDICO - no periodo"
 Local nLin           := 80

 Local Cabec1         := STR0023
 Local Cabec2         := ""
 Local imprime        := .T.
 Local aOrd           := {}

 Private aMedicos     := {}

 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 132
 Private tamanho      := "M"
 Private nomeprog     := "HSPAHRA1" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo        := 15
 Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
 Private nLastKey     := 0
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private CONTFL       := 01
 Private m_pag        := 01
 Private wnrel        := "HSPAHRA1" // Coloque aqui o nome do arquivo usado para impressao em disco
 Private cString      := "GAD"
 Private cPerg        := "HSPRA1"

 FS_IniX1()  // inicia SX1

 If !Pergunte(cPerg,.T.)
	 return
 EndIf

 // Monta a interface padrao com o usuario...
 wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

 If nLastKey == ESC
 	Return
 EndIf

 SetDefault(aReturn,cString)

 If nLastKey == ESC
 	Return
 EndIf

 nTipo := If(aReturn[4]==1,15,18)

 // Processamento RPTSTATUS monta janela com a regua de processamento.
 RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

//******************************************************************************************************************
//Funcao     RUNREPORT  Autor : AP6 IDE               Data   15/07/04
//Descricao  Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.
//Uso        Programa principal


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

 Local cCodMed  := "", cNomMed := "", cNomAten  := "", cCodCon := "", cNomCon := ""
 Local nTotMat  := 0 , nCtaFor := 1 , nTotAtend := 0

 Processa({|| FS_MontaG()})

 nTotMat := LEN(aMedicos)
 cCodMed := "inicio"

 DbSelectArea("GAD")
 DbSetOrder(1) // muda indice para seek no _REGATE
 for nCtaFor := 1 to nTotMat // loop  da 1a.Matriz para impressao do relatorio ***********************************
	
 	If cCodMed # aMedicos[nCtaFor,1]

   If nCtaFor > 1
 	 	@ nLin,00 Psay STR0026+Transform(nTotAtend, "999")+FS_CPCento(nTotAtend,nTotMat)
   	nLin++
	   @ nLin,00 Psay TRACE
   	nLin++
 	 EndIf

		 cCodMed := aMedicos[nCtaFor,1]
		 cNomMed := Posicione("SRA", 11, xFilial("SRA") + cCodMed, "RA_NOME")
		
		 If nLin > 55 //Impressao do cabecalho do relatorio. Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		 	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		 	nLin := 10
		 EndIf
		 @ nLin,00 Psay STR0025+cNomMed+" - "+cCodMed
		 nLin += 2
		 nTotAtend := 0
	 EndIf
	
	 DbSeek(xFilial("GAD") + aMedicos[nCtaFor,2] , .T.) // SEEK NO _REGATE
	
	 If Found()
		 cCodCon := GAD->GAD_CODCON
 	 cNomCon := Posicione("GA9", 1, xFilial("GA9") + cCodCon, "GA9_NOME")
		 If GAD->GAD_ATENDI     == INTERNACAO  ; cNomAten := STR0015
		 ElseIf GAD->GAD_ATENDI == CONSULTA    ; cNomAten := STR0016
		 ElseIf GAD->GAD_ATENDI == EXAME       ; cNomAten := STR0017
		 ElseIf GAD->GAD_ATENDI == RETORNO     ; cNomAten := STR0018
		 ElseIf GAD->GAD_ATENDI == PROCEDIMENTO; cNomAten := STR0019
		 ElseIf GAD->GAD_ATENDI == CURATIVO    ; cNomAten := STR0020
		 ElseIf GAD->GAD_ATENDI == RN          ; cNomAten := STR0021
		 Else
		 	cNomAten := STR0022
		 EndIf
		
		 If lAbortPrint
		 	@nLin,00 PSAY STR0010
		 	Exit
		 EndIf     // Verifica o cancelamento pelo usuario...
		
		 If nLin > 55 //Impressao do cabecalho do relatorio. Salto de Pแgina. Neste caso o formulario tem 55 linhas...
    nLin++
		 	@ nLin,00 Psay "continua..."
			 Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			 nLin := 10
			 @ nLin,00 Psay "...continuacao do Medico Dr(a) "+cNomMed
			 nLin += 2
		 EndIf
		
		 @ nLin,00 Psay GAD->GAD_DATATE
		 @ nLin,10 Psay GAD->GAD_HORATE
		 @ nLin,17 Psay cNomAten
		 @ nLin,36 Psay cNomCon
		 @ nLin,80 Psay GAD->GAD_REGATE+" - "+GAD->GAD_NOME
		 nLin++ 
		 nTotAtend++
	 EndIf

 next
 @ nLin,00 Psay STR0026+Transform(nTotAtend, "999")+FS_CPCento(nTotAtend,nTotMat)
 nLin += 2
 @ nLin,00 Psay TRACE
 nLin += 2
 @ nLin,00 Psay STR0024+Transform(nTotMat,"9999")
 nLin += 2
 @ nLin,00 Psay TRACEDUPLO

 
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
ฑฑบ Funcao   ณ FS_MontaG()  บ Autor ณ MARCELO JOSE   บ Data ณ  15/07/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta a matriz de dados                                    บฑฑ
ฑฑบ          ณ Nil  FS_MontaG(Nil)                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_MontaG()

 DbSelectArea("GAD")
 DbSetOrder(4) 

 // SETREGUA -> Indica quantos registros serao processados para a regua
 ProcRegua(RecCount())


 DbSeek(xFilial("GAD") + DTOS(MV_PAR01), .T.)
 While !Eof() .And. GAD->GAD_FILIAL == xFilial("GAD") ;    // Loop central monta matriz de Medicos e excessoes
	 .And.  GAD->GAD_DATATE <= mv_par02
	
	 IncProc("Aguarde, processando dados")
	
	 If MV_PAR03 != AMBOS  // filtro de tipo de atendimento
	 	If MV_PAR03 == 1   // internacao
	 		If GAD->GAD_ATENDI != INTERNACAO
		 		DbSkip() // Avanca o ponteiro do registro no arquivo
			 	Loop
			 EndIf
	 	EndIf
	 	If MV_PAR03 == 2   // outros atendimentos...
	 		If GAD->GAD_ATENDI == INTERNACAO
		 		DbSkip() // Avanca o ponteiro do registro no arquivo
			 	Loop
		 	EndIf
		 EndIf
	 EndIf
	 If !Empty(MV_PAR04) .Or. !Empty(MV_PAR05)
 	 If GAD->GAD_CODCRM < MV_PAR04 .or. GAD->GAD_CODCRM > MV_PAR05  // filtra Medico
	  	DbSkip() // Avanca o ponteiro do registro no arquivo
	  	Loop
	  EndIf
	 EndIf
  
  IF GAD->GAD_TPALTA == "99"
   DbSkip() // Avanca o ponteiro do registro no arquivo
  	Loop
  ENDIF

	 aAdd(aMedicos,{PadR(GAD->GAD_CODCRM,6),GAD->GAD_REGATE})
	
	 DbSkip() // Avanca o ponteiro do registro no arquivo
	
 EndDo
 // O R D E N A   M A T R I Z   D O  C O D I G O  D O  M E D I C O
 //aSort(aMedicos,,,{|x,y| x[2] < y[2]})  ordena somete segundo campo da matriz (regAte)
 aSort(aMedicos,,,{|x,y| x[1]+x[2] < y[1]+y[2]}) // ordena primeiro campo segundo campo 
 Return(Nil)
 /*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณ FS_CPCento() บ Autor ณ MARCELO JOSE   บ Data ณ  15/07/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Calcula % do valor informado em nPCalc sendo nPTotal=100%  บฑฑ
ฑฑบ          ณ char FS_CPCento(int nPCalc, int nPTotal)                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static function FS_CPCento(nPCalc, nPTotal)
return(IIf(nPCalc > 0, " = "+transform(((nPCalc / nPTotal) * 100), "999.99") + "%", ""))
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Funcao   ณ FS_IniX1()   บ Autor ณ MARCELO JOSE   บ Data ณ  15/07/04   บฑฑ
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
 EndIf

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
 AADD(aHelpPor,"Informe o tipo de atendimento, se: ")
 AADD(aHelpPor,"Internacao, ambulatorio ou ambos.		")
 AADD(aHelpSpa,"                                   ")
 AADD(aHelpSpa,"              																					")
 AADD(aHelpEng,"                                   ")
 AADD(aHelpEng,"                                   ")
 AADD(aRegs,{STR0011,STR0011,STR0011,"mv_ch3","C",01,0,0,"C","","mv_par03",STR0012,STR0012,STR0012,"",STR0013,STR0013,STR0013,"",STR0014,STR0014,STR0014,"","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})

 // do Medico
 aHelpPor := {}
 aHelpSpa := {}
 aHelpEng := {}
 AADD(aHelpPor,"Informe o codigo do Medico para a  ")
 AADD(aHelpPor,"pesquisa...             											")
 AADD(aHelpSpa,"                                   ")
 AADD(aHelpSpa,"              																					")
 AADD(aHelpEng,"                                   ")
 AADD(aHelpEng,"                                   ")
 AADD(aRegs,{STR0008,STR0008,STR0008,"mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","MED","N","","",aHelpPor,aHelpSpa,aHelpEng})

 // ate o Medico
 aHelpPor := {}
 aHelpSpa := {}
 aHelpEng := {}
 AADD(aHelpPor,"Informe o codigo do Medico para a  ")
 AADD(aHelpPor,"pesquisa...             											")
 AADD(aHelpSpa,"                                   ")
 AADD(aHelpSpa,"              																					")
 AADD(aHelpEng,"                                   ")
 AADD(aHelpEng,"                                   ")
 AADD(aRegs,{STR0009,STR0009,STR0009,"mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","MED","N","","",aHelpPor,aHelpSpa,aHelpEng})

 AjustaSx1(cPerg, aRegs)
 DbSelectArea(_sAlias)
Return(Nil)
//******************************************************************************************************************
