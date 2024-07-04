#INCLUDE "HSPAHRA5.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"
#define ESC          27
#define TRACE        repl("_",79)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHRA4  º Autor ³ MARCELO JOSE       º Data ³  12/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ TAXA   DE OBITOS POR CONVENIOS                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHRA5()
 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := STR0003 //"TAXA DE OBITOS GLOBAL POR CLINICA"
 Local cPict          := ""
 Local titulo         := STR0003 //"TAXA DE OBITOS GLOBAL POR CLINICA"
 Local nLin           := 80

 Local Cabec1         := SPACE(27)+STR0004 //"INDICADORES DE QUALIDADE"
 Local Cabec2         := SPACE(29)+STR0005 //"Taxa de Mortalidade"
 Local imprime        := .T.
 Local aOrd := {}

 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 80
 Private tamanho      := "P"
 Private nomeprog     := "HSPAHRA5" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo        := 18
 Private aReturn      := { STR0006, 1, STR0007, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private CONTFL       := 01
 Private m_pag        := 01
 Private wnrel        := "HSPAHRA5" // Coloque aqui o nome do arquivo usado para impressao em disco
 Private cString      := "GAD"
 Private cPerg        := "HSPRA5"

 Private aMatriz      := {}
 Private nTotAlta     := 0
 
 FS_IniX1()

 If !Pergunte(cPerg,.T.)
 	return
 EndIf

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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ FS_MontaM() º Autor ³ MARCELO JOSE    º Data ³  12/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta matriz para impressao                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_MontaM()

 Local cPar  := "" , nHorAte := "", nCtaFor := 1
 
 cPar := AllTrim(GetMv("MV_TPALTA"))

 aAdd(aMatriz,{0,0,0}) // clinica medica
 aAdd(aMatriz,{0,0,0}) // clinica cirurgica
 aAdd(aMatriz,{0,0,0}) // clinica obstetrica
 aAdd(aMatriz,{0,0,0}) // clinica pediatrica
 aAdd(aMatriz,{0,0,0}) // totais

 DbSelectArea("GAD")
 DbSetOrder(4)
 nTotGAD := RecCount()
 
 ProcRegua(nTotGAD) // SETREGUA -> Indica quantos registros serao processados para a regua 

 DbSeek(xFilial("GAD") + DTOS(MV_PAR01), .T.)
                                                 
 // Loop central 
 While !Eof() .And. GAD->GAD_FILIAL == xFilial("GAD") .And. GAD->GAD_DATATE <= MV_PAR02
  
  IncProc(STR0008) //"Aguarde, processando dados"
  
  If !Empty(GAD->GAD_TPALTA)
   nTotAlta++
  EndIf

		If GAD->GAD_TPALTA $ cPar

   nHorAte := SubtHoras(GAD->GAD_DATATE, GAD->GAD_HORATE, GAD->GAD_DATALT, GAD->GAD_HORALT)
   
		 If nHorAte > 48 // numero de obtos apos 48 horas de internacao...

    If     GAD->GAD_CODCLI == "0"
     aMatriz[1,1]++
    ElseIf GAD->GAD_CODCLI == "1"
     aMatriz[2,1]++
    ElseIf GAD->GAD_CODCLI == "2"
     aMatriz[3,1]++
    ElseIf GAD->GAD_CODCLI == "3"
     aMatriz[4,1]++
    EndIf

   EndIf

	 EndIf 

	 DbSkip() // Avanca o ponteiro do registro no arquivo
 End

 aMatriz[1,2] := ( aMatriz[1,1] / nTotAlta ) * 100
 aMatriz[2,2] := ( aMatriz[2,1] / nTotAlta ) * 100
 aMatriz[3,2] := ( aMatriz[3,1] / nTotAlta ) * 100
 aMatriz[4,2] := ( aMatriz[4,1] / nTotAlta ) * 100

 For nCtaFor := 1 To 4
  If     aMatriz[nCtaFor,2] # 0   .And. aMatriz[nCtaFor,2] <= 2; aMatriz[nCtaFor,3] := 3
  ElseIf aMatriz[nCtaFor,2] > 2.1 .And. aMatriz[nCtaFor,2] <= 4; aMatriz[nCtaFor,3] := 2
  ElseIf aMatriz[nCtaFor,2] > 4.1 .And. aMatriz[nCtaFor,2] <= 6; aMatriz[nCtaFor,3] := 1
  EndIf
 Next

 aMatriz[5,1] := aMatriz[1,1] + aMatriz[2,1] + aMatriz[3,1] + aMatriz[4,1] 
 aMatriz[5,2] := aMatriz[1,2] + aMatriz[2,2] + aMatriz[3,2] + aMatriz[4,2] 
 aMatriz[5,3] := aMatriz[1,3] + aMatriz[2,3] + aMatriz[3,3] + aMatriz[4,3] 

Return(Nil)
//******************************************************************************************************************
//Funcao    RUNREPORT  Autor : AP6 IDE               Data   12/08/04                                               *
//Descricao Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.*
//Uso       Programa principal                                                                                     *
//******************************************************************************************************************
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

 If lAbortPrint
	 @ nLin, 00 Psay STR0009
	EndIf     // Verifica o cancelamento pelo usuario...
	
 //Impressao do cabecalho do relatorio. Salto de Página. Neste caso o formulario tem 55 linhas...
 	Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 
 @ 10, 10 Psay STR0010
 @ 11, 10 Psay STR0011
 @ 13, 10 Psay STR0012 + Str(aMatriz[1,2],5,2) + STR0026 + Str(aMatriz[1,3],1,0) + Space(13) + Str(aMatriz[1,1],3,0)
 @ 15, 10 Psay STR0013 + Str(aMatriz[2,2],5,2) + STR0026 + Str(aMatriz[2,3],1,0) + Space(13) + Str(aMatriz[2,1],3,0)
 @ 17, 10 Psay STR0014 + Str(aMatriz[3,2],5,2) + STR0026 + Str(aMatriz[3,3],1,0) + Space(13) + Str(aMatriz[3,1],3,0)
 @ 19, 10 Psay STR0015 + Str(aMatriz[4,2],5,2) + STR0026 + Str(aMatriz[4,3],1,0) + Space(13) + Str(aMatriz[4,1],3,0)
 @ 21, 10 Psay STR0016
 @ 23, 10 Psay STR0017 + Str(aMatriz[5,2],6,2) + STR0027 + Str(aMatriz[5,3],2,0) + Space(13) + Str(aMatriz[5,1],3,0)
 @ 26, 10 Psay STR0018 + Str(nTotAlta,5,0)
 @ 27, 10 Psay STR0019
 @ 29, 10 Psay STR0020 + DTOC(MV_PAR01) + STR0021 + DTOC(MV_PAR02)
 @ 37, 10 Psay STR0022
 @ 38, 10 Psay STR0023
 @ 39, 10 Psay STR0024
 @ 40, 10 Psay STR0025

 @ 42, 00 Psay TRACE


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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ FS_IniX1()   º Autor ³ MARCELO JOSE   º Data ³  12/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Inicia SX1 p/receber parametros selecionados pelo usuario  º±±
±±º          ³ Nil FS_IniX1(Nil)                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_IniX1()

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
 AADD(aRegs,{STR0028,STR0028,STR0028,"mv_ch1","D",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})
 
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
 AADD(aRegs,{STR0029,STR0029,STR0029,"mv_ch2","D",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})

 AjustaSx1(cPerg, aRegs)
 DbSelectArea(_sAlias)
Return(Nil)
//******************************************************************************************************************
