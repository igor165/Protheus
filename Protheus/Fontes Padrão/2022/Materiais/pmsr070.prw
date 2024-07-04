#INCLUDE "pmsr070.ch"
#DEFINE CHRCOMP	If(aReturn[4]==1,15,18)

// Definida tambem na PMSXREL

#DEFINE 	DATA_ATUAL				1
#DEFINE 	TAM_MES    				2
#DEFINE 	POSICOES_IMPRESSAO		3

#DEFINE 	SEPARADORES           	2
#DEFINE 	PERIODOS_RELATORIOS   	3

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PMSR070   ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 25.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do cronograma fisico do projeto                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PMSR070()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define Variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1   := STR0001 //"Este relatorio ira imprimir o cronograma "
Local cDesc2   := STR0002 //"dos projeto(s)  conforme  os  parametros "
Local cDesc3   := STR0003 //"solicitados."
Local cString  := "AF8"
Local lDic     := .F.
Local lComp    := .T.
Local lFiltro  := .T.
Local wnrel    := "PMSR070"

Private nomeprog 	:= "PMSR070"
Private Cabec1 		:= ""
Private Cabec2 		:= ""
Private aVarRel 	:= Array(3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso ultrapasse, utiliza o tamanho grande de Lay-Out                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private Titulo   := STR0004 //"Cronograma fisico"
Private Tamanho := "G"   // P/M/G
Private Limite  := 220 // 80/132/220
Private nli     := 100 // Contador de Linhas
Private aOrdem  := {}  // Ordem do Relatorio
Private cPerg   := "PMR070"  // Pergunta do Relatorio
Private aReturn := { STR0005, 1,STR0006, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
						//[1] Reservado para Formulario
						//[2] Reservado para N§ de Vias
						//[3] Destinatario
						//[4] Formato => 1-Comprimido 2-Normal
						//[5] Midia   => 1-Disco 2-Impressora
						//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
						//[7] Expressao do Filtro
						//[8] Ordem a ser selecionada
						//[9]..[10]..[n] Campos a Processar (se houver)

Private lEnd    	:= .F.// Controle de cancelamento do relatorio
Private m_pag   	:= 1  // Contador de Paginas
Private nLastKey	:= 0  // Controla o cancelamento da SetPrint e SetDefault

If PMSBLKINT()
	Return Nil
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica as Perguntas Seleciondas                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETROS                                                             ³
//³ MV_PAR01 : Projeto   de ?                                              ³
//³ MV_PAR02 : Ate?                                                        ³
//³ MV_PAR03 : Data projeto de                                    		   ³
//³ MV_PAR04 : Data projeto ate                                   		   ³
//³ MV_PAR05 : Versao ?		Branco = Todas, 1-2;3-3;5-5                    ³
//³ MV_PAR06 : Nivel ?                                                     ³
//³ MV_PAR07 : Fase ?                                                      ³
//³ MV_PAR08 : Data PREVISTO de                                            ³
//³ MV_PAR09 : Data PREVISTO ate                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia para a SetPrint                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)

If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter() //Set Filter to
	Return
Endif
SetDefault(aReturn,cString)

If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter() //Set Filter to
	Return
Endif

If Empty(mv_par08) .And. Empty(mv_par09)
	dbSelectArea("AF8")
	dbSeek(xFilial()+mv_par01,.T.)
	mv_par08 := AF8->AF8_START
	mv_par09 := AF8->AF8_FINISH
	While !Eof() .And. AF8->AF8_PROJET <= mv_par02
		If AF8->AF8_DATA > mv_par04 .Or. AF8->AF8_DATA < mv_par03 .Or.;
			AF8->AF8_CLIENT > mv_par12 .Or. AF8->AF8_CLIENT < mv_par10 .Or.;
			AF8->AF8_LOJA > mv_par13 .or. AF8->AF8_LOJA < mv_par11 .Or.;
			!PmrPertence(AF8->AF8_FASE,mv_par07)
			AF8->(dbSkip())
			Loop
		EndIf
		mv_par08 := Min(mv_par08,AF8->AF8_START)
		mv_par09 := Max(mv_par09,AF8->AF8_FINISH)
		AF8->(dbSkip())		
	End
EndIf


PmrAddPropO("PROPRIEDADESIMPRESSAO",,;
			{ { "CRONOGRAMAFISICO", 000 } })
PmrAddPropO("LIMITEPREVISTO",, mv_par09)
PmrAddPropO("ROTINADETALHE",, "PMRPer070")
PmrAddPropO("TODA_MATRIZ_PROJETO",, .T.)
PmrAddPropO("ESTRUTURA_PROJETO",, {})
PmrAddPropO("IMPRIME_RODAPE",, STR0008) //"Projetos impressos"
PmrAddPropO("INDREGUA","COMPLEMENTO" ,"AF8_CLIENTE  >= '" + mv_par10 + "' .and. AF8_LOJA >= '" + mv_par11 +"'.and. " +;
									  "AF8_CLIENTE <= '" + mv_par12 + "' .and. AF8_lOJA <=  '" + mv_par13 + "'")
RptStatus({|lEnd| PMRSelReg(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ PMRPer070   ³ Autor ³ Wagner Mobile Costa ³ Data ³27.06.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona os periodos e envia para funcao de detalhe        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PmrPer070(cPar1, nPar1, aPar1, lPar1)                    	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPar1 = Nome do programa chamador                            ³±±
±±³          ³nPar1 = Linha para impressao                                 ³±±
±±³          ³aPar1 = Matriz com a linha atual com informacoes para busca  ³±±
±±³          ³ { { { CODIGO DA EDT/TAREFA, DESCRICAO, RECNO, TABELA } }    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PMRPer070(NomeProg, nLi, aEstrutura)

Local nIndice, nPeriodo

Cabec1 := STR0007 //"PROJETO / EDT / TAREFA        |"

/*
EDT / TAREFA                  |           JULHO/2001         |           AGOSTO/2001        |          SETEMBRO/2001      |           OUTUBRO/2001       |         NOVEMBRO/2001       |          DEZEMBRO/2001       |

123456789012345678901234567890|123456789012345678901234567890|123456789012345678901234567890|12345678901234567890123456789|123456789012345678901234567890|12345678901234567890123456789|123456789012345678901234567890|
                               12345678901234567890123456789011234567890123456789012345678901123456789012345678901234567890

Matriz com posicoes

1 - Inicio da impressao 30
2 - |                              |                              |                             |                              |                             |                              |
3 - { { 20010731, 31 } }, { 20010831, 62 } }

*/                               


aVarRel[DATA_ATUAL] 			:= LastDay(mv_par08)
aVarRel[POSICOES_IMPRESSAO] 	:= { Len(Cabec1) - 1,;
						    	Space(Len(Cabec1) - 1) + "|", { }, "" }

For nPeriodo := 1 To 6
	aVarRel[TAM_MES] := Day(aVarRel[DATA_ATUAL])

	aVarRel[POSICOES_IMPRESSAO][SEPARADORES] += Repl(Space(1), aVarRel[TAM_MES] - 1) + "|"
	Aadd(aVarRel[POSICOES_IMPRESSAO][PERIODOS_RELATORIOS],;
				 { Dtos(aVarRel[DATA_ATUAL]), Len(Cabec1) + 1 } )

	Cabec1 += Padc(AllTrim(MesExtenso(Month(aVarRel[DATA_ATUAL]))) + "/" +;
  					                Str(Year(aVarRel[DATA_ATUAL]), 4), aVarRel[TAM_MES] - 1) + "|" 
	If Month(aVarRel[DATA_ATUAL]) = 12
		aVarRel[DATA_ATUAL] := Ctod("01/01/" + Str(Year(aVarRel[DATA_ATUAL]) + 1, 4))
	Else
		aVarRel[DATA_ATUAL] := Ctod("01/" + StrZero(Month(aVarRel[DATA_ATUAL]) + 1, 2) + "/" +;
											      Str(Year(aVarRel[DATA_ATUAL]), 4))
	Endif
	aVarRel[DATA_ATUAL] := LastDay(aVarRel[DATA_ATUAL])
	If 	nPeriodo = 6 
		PMRAddPropO("POSICOESCRONOGRAMA",, aVarRel[POSICOES_IMPRESSAO])
	
		For nIndice := 1 To Len(aEstrutura)
	 		PMRDet070(NomeProg, @nLi, aEstrutura, nIndice)
		Next
		nLi := 70
		Cabec1 := STR0007 //"PROJETO / EDT / TAREFA        |"
		aVarRel[POSICOES_IMPRESSAO] := {  	    Len(Cabec1) - 1,;
										  Space(Len(Cabec1) - 1) + "|", { }, "" }
	Endif

	If 	Left(Dtos(aVarRel[DATA_ATUAL]), 6) > Left(Dtos(mv_par09), 6) .And.;
		nPeriodo = 6 		// Forco a impressao de todas as colunas
 		Exit				// Mesmo com a data sendo maior, imprime as 6 Colunas
	Endif
	
	If nPeriodo = 6
		nPeriodo := 0		// Indico zero pois soma um ao inicialzar o laco
	Endif
Next

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ PMRDet070   ³ Autor ³ Wagner Mobile Costa ³ Data ³21.06.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a impressao do detalhe da estrutura                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PmrDet070(cPar1, nPar1, aPar1, lPar1)                    	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPar1 = Nome do programa chamador                            ³±±
±±³          ³nPar1 = Linha para impressao                                 ³±±
±±³          ³aPar1 = Matriz com a linha atual com informacoes para busca  ³±±
±±³          ³ { { { CODIGO DA EDT/TAREFA, DESCRICAO, RECNO, TABELA } }    ³±±
±±³          ³nPar2 = Indice atual da matriz do projeto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PMRDet070(NomeProg, nLi, aProjeto, nIndice)

Local aEstrutura := aProjeto[nIndice]

/*
EDT / TAREFA                  |           JULHO/2001         |           AGOSTO/2001        |          SETEMBRO/2001      |           OUTUBRO/2001       |         NOVEMBRO/2001       |          DEZEMBRO/2001       |
123456789012345678901234567890|123456789012345678901234567890|123456789012345678901234567890|12345678901234567890123456789|123456789012345678901234567890|12345678901234567890123456789|123456789012345678901234567890|

EDT / TAREFA                  |            MAIO/2001         |           JUNHO/2001        |           JULHO/2001         |           AGOSTO/2001        |          SETEMBRO/2001      |           OUTUBRO/2001       |
123456789012345678901234567890|123456789012345678901234567890|12345678901234567890123456789|123456789012345678901234567890|123456789012345678901234567890|12345678901234567890123456789|123456789012345678901234567890|
					           
ASSINATURA DO CONTRATO	      |           >19/07< = >19/07<					                                                                                                                  						  |

*/

DbSelectArea(aEstrutura[4])
DbGoto(aEstrutura[3])

If ( nli > 60 )
	nli := cabec(Titulo,Cabec1,Cabec2,nomeprog,Tamanho,CHRCOMP)
	nli++
	@ nLi,000 PSAY aVarRel[POSICOES_IMPRESSAO][SEPARADORES]
	nli++
Endif

If aEstrutura[4] = "AFC" .And. nIndice > 1 .And. aProjeto[nIndice - 1][4] # "AFC"
	@ nLi,000 PSAY aVarRel[POSICOES_IMPRESSAO][SEPARADORES]	
	nli++
Endif

PMRCalcObjI(NomeProg, @nLi, aEstrutura)

If aEstrutura[4] = "AFC"
	@ nLi,000 PSAY aVarRel[POSICOES_IMPRESSAO][SEPARADORES]	
	nli++
Endif

Return .T.