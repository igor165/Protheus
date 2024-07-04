#INCLUDE "RspG010.CH"
#INCLUDE "Protheus.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RspG010  ³ Autor ³ Emerson Grassi Rocha            ³ Data ³ 18/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grafico comparativo Cargo x Candidatos.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS           ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³06/08/14³TQENRX          ³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³                ³da a limpeza.                             ³±±
±±³Matheus M  .³29/09/16³TWEEDC          ³Ajuste para não gerar error.log ao impri- ³±±
±±³            ³        ³                ³mir o gráfico com múltiplos fatores.      ³±±
±±³Flavio C.   ³03/01/17³MRH-1387        ³Mensagem avisando de falta de fatores     ³±±
±±³Wesley Alves³09/07/19³DRHGCH-10771    ³Melhoria das mensagens de erro no LOG     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function RspG010()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0004) //'Comparativo Cargo x Candidatos'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse(6, 1, 22, 75, 'SQS',,,, "SQS->QS_NRVAGA - SQS->QS_VAGAFEC > 0")

dbSelectArea("SQS")
dbSetOrder(1)

dbSelectArea("SQD")
dbSetOrder(1)

dbSelectArea("SQI")
dbSetOrder(1)

dbSelectArea("SQ1")
dbSetOrder(1)

dbSelectArea("SQ2")
dbSetOrder(1)

dbSelectArea("SQ3")
dbSetOrder(1)

dbSelectArea("SQ4")
dbSetOrder(1)

dbSelectArea("SRJ")
dbSetOrder(1)

dbSelectArea("SQG")
dbSetOrder(1)

dbSelectArea("SQR")
dbSetOrder(1)

dbSelectArea("SQO")
dbSetOrder(1)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RspG010Gra³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 18/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina Principal do Grafico.						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspG010Gra()						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = N£mero do registro                                 ³±±
±±³          ³ ExpN2 = N£mero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RspG010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RspG010Gra(cAlias, nReg, nOpcX)

Local cVaga 	:= SQS->QS_VAGA
Local nCbx 		:= 4 //"#"Barras"

Local cTitulo	:= STR0020	//"Comparativo - Cargo x Candidato"
Local cTituloX	:= STR0021	//"Fatores"
Local cTituloY	:= STR0022	//"Graduacoes"
Local aDados	:= {}
Local aLegenda	:= {}
Local aTabela	:= {}
Local aPosCol	:= { 360, 1300, 2100 }
Local aPosGrh	:= { 360, 2100, 1300 }

Local aSays 	:= {}
Local aButtons	:= {}
Local nOpca		:= 0
Local cTitPtosCSA:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("RSG010",.F. )

AADD(aSays,OemToAnsi(STR0030) )  //"Grafico comparativo de Fatores do Cargo."
AADD(aSays,OemToAnsi(STR0031) )  //"Mostra os Fatores do Cargo e Fatores dos Funcionarios."

AADD(aButtons, { 5,.T.,{|| Pergunte("RSG010",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch()}} )
AADD(aButtons, { 2,.T.,{|o| nOpca := 0,FechaBatch()}} )

FormBatch( cCadastro, aSays, aButtons )

If mv_par08 == 1 //Grau
	cTitPtosCSA := OemToAnsi(STR0035)  //Graduacao
Else
	cTitPtosCSA := OemToAnsi(STR0035)+"/"+OemToAnsi(STR0007)	//Pontos
EndIf

aTabela	:= {{OemToAnsi(STR0033), OemtoAnsi(STR0034), cTitPtosCSA}} //"Cargo/Candidato"###"Fator"###"Graduacao"###"Pontos"###

If nOpca == 1
    //-- Obtem os dados do grafico
	If RspG010Ger(cVaga,@aDados,@aLegenda,@aTabela)
	//-- Monta tela para apresentacao do grafico
	//-- Para efeito comparativo somente geramos grafico do tipo Barras
		TrmGraf(aDados,nCbx,cTitulo,cTituloX,cTituloY,aLegenda,aTabela,aPosCol,aPosGrh)
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RspG010Ger³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 18/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera Dados para Grafico.							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RspG010Ger()						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 							                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RspG010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RspG010Ger(cVaga,aDados,aLegenda,aTabela)

Local aDadCargo := {}	// {Eixo X, Eixo Y, Nome}
Local aGrupo	:= {}
Local aLog		:= {}
Local cTitulo	:= STR0004
Local cCurric	:= ""
Local cDescFator:= ""
Local cNome		:= ""
Local cTeste	:= ""
Local nPontos 	:= 0
Local i 		:= 0
Local n			:= 0
Local cCand		:= ""
Local cFator	:= ""
Local cGradu	:= ""
Local cDCand	:= ""
Local cDFator	:= ""
Local cDGradu	:= ""
Local nPos		:= 0
Local cCor	  	:= ""

// Variaveis de Perguntas
Local cFilDe   	:= ""
Local cFilAte	:= ""
Local cCurrDe 	:= ""
Local cCurrAte	:= ""
Local cFatorDe	:= ""
Local cFatorAte	:= ""
Local lTeste	:= .F.
Local nPtosCSA  := 0 //Variavel para receber o Parametro: Grau ou Pontos
Local nPontosCSA:= 0 //Variavel que recebe o Valor do Fator por Pontos

Local aBmpImp := {}
Local aLegImp := {}
Local j		  := 0
Local k		  := 0
Local lRet 	  := .T.
Local cErro   := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas na pergunte                                 ³
//³ mv_par01				// Filial De                             ³
//³ mv_par02				// Filial Ate                            ³
//³ mv_par03				// Curriculo De                		 	 ³
//³ mv_par04				// Curriculo At‚                  		 ³
//³ mv_par05				// Fator Graduacao De                    ³
//³ mv_par06				// Fator Graduacao Ate                   ³
//³ mv_par07				// Mostrar Teste                    	 ³
//³ mv_par08				// Grau ou Pontos                   	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("RSG010",.F.)

cFilDe   	:= Iif(xFilial("SQ4") == Space(FWGETTAMFILIAL), Space(FWGETTAMFILIAL),mv_par01)
cFilAte		:= mv_par02
cCurrDe 	:= mv_par03
cCurrAte	:= mv_par04
cFatorDe	:= mv_par05
cFatorAte	:= mv_par06
lTeste		:= Iif(mv_par07 == 1, .T., .F.)
nPtosCSA    := mv_par08

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Legenda do Grafico para o Relatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aBmpImp, "BR_AZUL"		)
Aadd( aBmpImp, "BR_VERDE"		)
Aadd( aBmpImp, "BR_VERMELHO"	)
Aadd( aBmpImp, "BR_PINK"		)
Aadd( aBmpImp, "BR_MARRON"		)
Aadd( aBmpImp, "BR_CINZA"		)
Aadd( aBmpImp, "LIGHTBLU"		)
Aadd( aBmpImp, "BR_AMARELO"		)
Aadd( aBmpImp, "br_branco"			)
Aadd( aBmpImp, "BR_PRETO"		)

//---------------------- Cargo
// Cadastro de Funcoes
dbSelectArea("SRJ")
dbSetOrder(1)
If dbSeek(xFilial("SRJ")+SQS->QS_FUNCAO)

	// Cadastro de Cargos
	dbSelectArea("SQ3")
	dbSetOrder(1)
	If dbSeek(xFilial("SQ3")+SRJ->RJ_CARGO)
	
		// Fatores do Cargo
		dbSelectArea("SQ4")
		dbSetOrder(2)
		If dbSeek(xFilial("SQ4")+SQ3->Q3_CARGO+SQ3->Q3_CC,.T.)
			i := 0
			While !Eof() .And. SQ4->Q4_CARGO+SQ4->Q4_CC == SQ3->Q3_CARGO+SQ3->Q3_CC .And.;
					SQ4->Q4_FILIAL >= xFilial("SQ4",cFilDe) .And. SQ4->Q4_FILIAL <=  xFilial("SQ4",cFilAte )
	
				If SQ4->Q4_FATOR < cFatorDe .Or. SQ4->Q4_FATOR > cFatorAte
					cErro := STR0064 //"Fatores do relatório estão fora do range de Fatores (SQ4)!"                                                                                                                                                                                                                                                                                                                                                                                                                                                        
					dbSkip()
					Loop
				EndIf
	
				//Fatores do Cargo
				i++
	
				If nPtosCSA == 1
					Aadd(aDadCargo,{SQ4->Q4_FATOR,Val(SQ4->Q4_GRAU),STR0029+SQ4->Q4_CARGO,SQ4->Q4_GRAU} )//"CARGO:"
				Else
					Aadd(aDadCargo,{SQ4->Q4_FATOR,SQ4->Q4_PONTOS,STR0029+SQ4->Q4_CARGO,SQ4->Q4_GRAU} )
				EndIf
	
				//Dados para Legenda do Grafico
				dbSelectArea("SQ1")
				dbSetOrder(1)
				dbSeek(xFilial("SQ1")+SQ3->Q3_GRUPO+SQ4->Q4_FATOR)
				cDescFator := SQ1->Q1_DESCSUM
	
				nPos	:= Ascan(aLegenda , SQ4->Q4_FATOR+" - "+Left(cDescFator,20) )
				If ( nPos == 0 )
					Aadd(aLegenda,SQ4->Q4_FATOR+" - "+Left(cDescFator,20))
				EndIf
	
				dbSelectArea("SQ4")
				dbSkip()
			EndDo
		Else
			cErro := STR0065 + SQ3->Q3_CARGO+"-"+SQ3->Q3_CC + STR0066 //"Cargo - Centro de Custo: " " Não encontrado na Graduação de Cargos(SQ4)!"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
		EndIf
		If lTeste
			Aadd(aDadCargo,{"00"+" - "+UPPER(STR0036),0,STR0029+SQ3->Q3_CARGO,""} )//"CARGO:"
	
			//Dados para Legenda do Grafico
			Aadd(aLegenda,"00"+" - "+UPPER(STR0036))	//"Teste"
		EndIf
		
	Else
		cErro := STR0067 + SRJ->RJ_CARGO + STR0068 //"Cargo: " " Não encontrado no cadastro de Cargos (SQ3)! "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
	EndIf
Else
	cErro := STR0069 + SQS->QS_FUNCAO + STR0070 //"Função: "  " Não encontrada no cadastro de Funções (SRJ)!"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
EndIf


If !lTeste .and. Len(aDadCargo) == 0
	aAdd(aLog,OemToAnsi(STR0040)) //"Para impressão do Gráfico de Cargos x Candidatos é necessário que os seguintes cadastros estejam configurados: "
	aAdd(aLog,"")
	aAdd(aLog,OemToAnsi(STR0041)) //"1. Cadastro de Grupos:"
	aAdd(aLog,Space(05) + OemToAnsi(STR0042) + " SQ0") //"Tabela:"
	aAdd(aLog,Space(05) + OemToAnsi(STR0043) + " TRMA030 " + OemToAnsi(STR0044) ) //"Rotina:"+"(SIGARSP > Atualizações > Cadastros > Grupos)"
	aAdd(aLog,"")
	aAdd(aLog,OemToAnsi(STR0045)) //"2. Fatores de Avalição Geral:"
	aAdd(aLog,Space(05) + OemToAnsi(STR0042) + " SQV") //"Tabela:"
	aAdd(aLog,Space(05) + OemToAnsi(STR0043) + " CSAA060 " + OemToAnsi(STR0046)) //"Rotina:"+"(SIGARSP > Atualizações > Cadastros > Fatores Avaliação Geral)"
	aAdd(aLog,Space(05) + OemToAnsi(STR0047)) //"Criar um Fator de Avaliação com suas graduações."
	aAdd(aLog,"")
	aAdd(aLog,OemToAnsi(STR0048)) //"3. Fatores de Avalição Grupo:"
	aAdd(aLog,Space(05) + OemToAnsi(STR0042) + " SQ1") //"Tabela:"
	aAdd(aLog,Space(05) + OemToAnsi(STR0043) + " RSPA110 " + OemToAnsi(STR0049)) //"Rotina:"+"(SIGARSP > Atualizações > Cadastros > Fatores Avaliação Grupo)"
	aAdd(aLog,Space(05) + OemToAnsi(STR0050)) //"Vincular a um grupo o Fator de Avaliação."
	aAdd(aLog,"")
	aAdd(aLog,OemToAnsi(STR0051)) //"4. Cadastro de Cargos:"
	aAdd(aLog,Space(05) + OemToAnsi(STR0043) + " TRMA020 " + OemToAnsi(STR0052)) //"Rotina:"+"(SIGARSP > Atualizações > Cadastros > Cargos)"
	aAdd(aLog,Space(05) + OemToAnsi(STR0053)) //"Pasta Descrição do Cargo:"
	aAdd(aLog,Space(10) + OemToAnsi(STR0042) + " SQ3") //"Tabela:"
	aAdd(aLog,Space(10) + OemToAnsi(STR0054)) //"Dados do Cargo e, DEVE possuir GRUPO vinculado (Q3_GRUPO)."
	aAdd(aLog,Space(05) + OemToAnsi(STR0055)) //"Pasta Fatores Avaliação:"
	aAdd(aLog,Space(10) + OemToAnsi(STR0042) + " SQ4") //"Tabela:"
	aAdd(aLog,Space(10) + OemToAnsi(STR0056)) //"Vincule fatores e graus de avaliação ao cargo. Irá carregar como opções de escolha os itens de Fator vinculado ao Grupo configurado no cargo."
	aAdd(aLog,"")
	aAdd(aLog,OemToAnsi(STR0057)) //"5. Cadastro de Funções:"
	aAdd(aLog,Space(05) + OemToAnsi(STR0042) + " SRJ") //"Tabela:"
	aAdd(aLog,Space(05) + OemToAnsi(STR0043) + " GPEA030 " + OemToAnsi(STR0058)) //"Rotina:"+"(SIGARSP > Atualizações > Cadastros > Funções)"
	aAdd(aLog,Space(05) + OemToAnsi(STR0059)) //"Vincular Cargo à Função."
	aAdd(aLog,"")
	aAdd(aLog,OemToAnsi(STR0060)) //"6. Cadastro de Vagas:"
	aAdd(aLog,Space(05) + OemToAnsi(STR0042) + " SQS") //"Tabela:"
	aAdd(aLog,Space(05) + OemToAnsi(STR0043) + " RSPA100 " + OemToAnsi(STR0061)) //"Rotina:"+"(SIGARSP > Atualizações > Cadastros > Vagas)"
	aAdd(aLog,Space(05) + OemToAnsi(STR0062)) //"Vincular Função à Vaga."
	
	aAdd(aLog,"")
	aAdd(aLog,"")
	aAdd(aLog,"")
	
	aAdd(aLog,STR0071) //Atenção
	aAdd(aLog,Space(05) + OemToAnsi(STR0072)) //"Erro Encontrado na exibição do relatório:"
	aAdd(aLog,Space(05) + cErro)		

	MsAguarde( { || fMakeLog( {aLog},{} , FunName() , NIL , FunName() , OemToAnsi(STR0063),,,,.F. ) } ,  OemToAnsi(STR0063) ) //"Log Gráfico Cargo x Candidato"
	lRet := .F.
EndIf


//-----------------
//Candidatos
//-----------------
dbSelectArea("SQD")
dbSetOrder(3)
dbSeek(xFilial("SQD")+cVaga)
If Len(aDadCargo) > 0

	// Fatores do Cargo
	For i := 1 to Len(aDadCargo)
		Aadd(aGrupo,{aDadCargo[i][1],aDadCargo[i][2],Iif(i == 1,aDadCargo[i][3]," "),aDadCargo[i][3],aDadCargo[i][4]})
	Next i

	Aadd(aDados,aGrupo)
	aGrupo := {}

	While !eof() .And. SQD->QD_VAGA == cVaga
		cCurric := SQD->QD_CURRIC
		While !Eof() .And. cCurric == SQD->QD_CURRIC
			dbSkip()
		EndDo
		dbSkip(-1)

		If SQD->QD_CURRIC < cCurrDe .Or. SQD->QD_CURRIC > cCurrAte
			dbSkip()
			Loop
		EndIf

		dbSelectArea("SQI")
		dbSetOrder(1)
		If dbSeek(xFilial("SQI")+SQD->QD_CURRIC)

			// Posiciona no Curriculo para buscar Nome
			dbSelectArea("SQG")
			dbSetOrder(1)
			dbSeek(xFilial("SQG")+SQD->QD_CURRIC)
			n 		:= AT(" ",Ltrim(SQG->QG_NOME))
			cNome 	:= Iif(n > 0, Left(SQG->QG_NOME,n), SQG->QG_NOME)

			//Fatores Candidatos
			For i := 1 to Len(aDadCargo)
				Aadd(aGrupo,{aDadCargo[i][1], 0, Iif(i == 1,cNome," "), SQI->QI_CURRIC,""})
			Next i

			dbSelectArea("SQI")
			dbSetOrder(1)
			While !Eof() .And. SQG->QG_CURRIC == SQI->QI_CURRIC

				n := Ascan(aGrupo,{|x| x[1]+x[4] == SQI->QI_FATOR + SQI->QI_CURRIC })

				If n > 0
					If nPtosCSA == 1
						aGrupo[n][2] 	:= Val(SQI->QI_GRAU)
						aGrupo[n][5] 	:= SQI->QI_GRAU 	//Grau
					Else
					    SQ2->( dbSetOrder(2) )
						If SQ2->( dbSeek(xFilial("SQI")+SQI->QI_FATOR+SQI->QI_GRAU))
							aGrupo[n][2] := SQ2->Q2_PONTOSI
							aGrupo[n][5] := SQI->QI_GRAU
						EndIf
					EndIf
				EndIf

				dbSkip()
			EndDo

			If lTeste
				dbSelectArea("SQR")
				dbSetOrder(1)
				dbSeek(xFilial("SQR")+SQD->QD_CURRIC)
				nPontos := 0
				cTeste	:= SQR->QR_TESTE
				While SQR->QR_CURRIC+SQR->QR_TESTE == SQD->QD_CURRIC+cTeste

					dbSelectArea("SQO")				//SQO - CADASTRO DE QUESTOES
					dbSeek(SQR->QR_FILIAL+SQR->QR_QUESTAO)
					nPontos += SQO->QO_PONTOS * (SQR->QR_RESULTA/100)

					dbSelectArea("SQR")
					dbSkip()
				EndDo

				n := Ascan(aGrupo,{|x| x[1]+x[4] == "00"+" - "+ UPPER(STR0036) + SQD->QD_CURRIC })
				If n > 0
					aGrupo[n][2] 	:= nPontos
				EndIf
			EndIf

			Aadd(aDados,aGrupo)
			aGrupo := {}

		EndIf

		dbSelectArea("SQD")
		dbSkip()
	EndDo

	For i := 1 To Len(aDados)
		For n := 1 To Len(aDados[i])

			cCand	:= aDados[i][n][4]
			cDCand	:= ""
			If Len(Alltrim(cCand)) > 6		//Cargo

			   	dbSelectArea("SQ3")
			   	dbSetOrder(1)
			   	dbSeek(xFilial("SQ3")+Right(cCand,5))
			   	cCand +=" - "+SQ3->Q3_DESCSUM
			Else 							//Funcionario

				// Posiciona no Curriculo para buscar Nome
				dbSelectArea("SQG")
				dbSetOrder(1)
				If dbSeek(xFilial("SQG")+cCand)
					cDCand :=" - "+SQG->QG_NOME
				EndIf
			EndIf

			cFator	:= aDados[i][n][1]
			cDFator	:= ""
			dbSelectArea("SQ1")
			dbSetOrder(3)
			If dbSeek(xFilial("SQ1")+cFator)
				cDFator := " - "+SQ1->Q1_DESCSUM
			EndIf

			//Valor do Grau e Descricao
			If Substr(cFator,1,2) <> "00"
				cGradu	:= aDados[i][n][5]
				cDGradu	:= ""

				dbSelectArea("SQ2")
				dbSetOrder(2)
				If dbSeek(xFilial("SQ2")+Substr(cFator,1,2)+cGradu)
					If nPtosCSA == 1
						cDGradu := " - "+Alltrim(SQ2->Q2_DESC)
					Else
						nPontosCSA	:= SQ2->Q2_PONTOSI
						cDGradu := " - "+Alltrim(SQ2->Q2_DESC)
					EndIf
				EndIf

			Else	//Pontos dos Testes realizados pelo Candidato

				If nPtosCSA == 1 //Grau: 00 - TESTE ### 99 - NOTA

					cGradu	:= Alltrim(Strzero(aDados[i][n][2],2,0))
					cDGradu := " - " + UPPER(STR0037) //Nota

				Else //Pontos: 00 - TESTE ### 99 - NOTA - 99.999

				   	cGradu	:= Substr(cFator,1,2)
					cDGradu := " - " + UPPER(STR0037)+" - " + Alltrim(Str(aDados[i][n][2],7,3))  //Nota

				Endif

			EndIf

			nPos	:=	Ascan(aTabela , { |x| cCand+cDcand  == x[1]})
		   	If( nPos > 0 )

		   		cDcand	:= ""
		   		cCand	:= ""

		   	EndIf

		   	If n <= Len(aBmpImp) .And. ValType(aBmpImp[n]) != NIL
		   		nPos	:= Ascan(aTabela , { |X| aBmpImp[n] $ X[2] } )
		   	EndIf

		   	If ( nPos > 0 )

		   		cFator	:= ""
		   		cDFator := ""
		   	 	cGradu	:= ""
		   	 	cDGradu	:= ""
		   	 	cCor	:= ""

		   	 Else

		   	 	cCor	:= 	aBmpImp[n]+".BMP"

		   	EndIf

			If nPtosCSA == 1 //Grau

			   	Aadd(aTabela,{cCand+cDCand,;
			   		cCor,;
			   		cFator+cDFator,;
			   	 	cGradu+cDGradu})

			Else //Pontos

				If Substr(cFator,1,2) <> "00"

					Aadd(aTabela,{cCand+cDCand,cCor, cFator+cDFator, cGradu+cDGradu+" - "+Alltrim(Str(nPontosCSA,7,3))})

				Else //Pontos dos Testes realizados pelo Candidato

					Aadd(aTabela,{cCand+cDCand,cCor, cFator+cDFator, cGradu+cDGradu})

				EndIf
			EndIf

		Next n
	Next i
EndIf

Return lRet

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³27/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPG010                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()

 Local aRotina := { 	{ STR0001, 'AxPesqui'	, 0, 1,,.F.}, ;	//'Pesquisar'
						{ STR0003, 'Rspg010Gra'	, 0, 3} } 	//'Grafico'

Return aRotina
