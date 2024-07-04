#INCLUDE "pmsr110.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PMSR110   ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 30.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do cronograma realizado x previsto                ³±±
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

Function PMSR110()
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
Local wnrel    := "PMSR110"

Private nomeprog 	:= "PMSR110"
Private Cabec1 		:= ""
Private Cabec2 		:= ""
Private aVarRel 	:= Array(3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso ultrapasse, utiliza o tamanho grande de Lay-Out                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private Titulo   := STR0004 //"Cronograma fisico - Realizado"
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
    	If !Empty(AF8->AF8_DTATUI)
			mv_par08 := Min(mv_par08,AF8->AF8_DTATUI)
		EndIf
		mv_par09 := Max(mv_par09,AF8->AF8_FINISH)
    	If !Empty(AF8->AF8_DTATUF)
			mv_par09 := Max(mv_par09,AF8->AF8_DTATUF)
		EndIf
		AF8->(dbSkip())		
	End
EndIf

PmrAddPropO("PROPRIEDADESIMPRESSAO",,;
			{ 	{ "CRONOGRAMAFISICO:PREVISTO", 000 },;
				{ "CRONOGRAMAFISICO:REALIZADO", 000 } })
PmrAddPropO("LIMITEPREVISTO",, mv_par09)
PmrAddPropO("ROTINADETALHE",, "PMRPer070")
PmrAddPropO("TODA_MATRIZ_PROJETO",, .T.)
PmrAddPropO("ESTRUTURA_PROJETO",, {})
PmrAddPropO("IMPRIME_RODAPE",, STR0008) //"Projetos impressos"
PmrAddPropO("FILTRO_CLIENTE",,{||AF1->AF1_CLIENTE  >= mv_par10 .and. AF1->AF1_LOJA >= mv_par11 .and. ;
								AF1->AF1_CLIENTE <= mv_par12 .and. AF1->AF1_lOJA <= mv_par13 } )
RptStatus({|lEnd| PMRSelReg(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)

Return(.T.)