#INCLUDE "PROTHEUS.CH"
#INCLUDE "QIPA011.CH"
#INCLUDE "TOTVS.CH"

#Define _ROT 1 //Roteiro
#Define _OPE 2 //Operacao
#Define _RAS 3 //Rastreabilidade
#Define _TXT 4 //Observacoes da Operacao
#Define _ENS 5 //Ensaio
#Define _INS 6 //Instrumentos
#Define _NCO 7 //Nao-conformidades
#Define _PAE 8 //Plano de Amostragem por Ensaio
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ QIPA011  ³ Autor ³ Cleber Souza          ³ Data ³14/03/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de atualizacao das Especificacoes de Produtos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIP													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³STR 	     ³ Ultimo utilizado -> STR0029                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			   ³        ³	   ³										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

Local aRotina := { 	{OemtoAnsi(STR0001),"AxPesqui"   ,0, 1,,.F.},; //"Pesquisar"
					{OemtoAnsi(STR0002),"QPA011Atu"  ,0, 2   },; //"Visualizar"
					{OemtoAnsi(STR0003),"QPA011Atu"  ,0, 3   },; //"Incluir"
					{OemtoAnsi(STR0004),"QPA011Atu"  ,0, 4, 2},; //"Alterar"
					{OemtoAnsi(STR0005),"QPA011Atu"  ,0, 5, 1},; //"Excluir"
					{OemtoAnsi(STR0006),"QPA011BLOQ" ,0, 5   },; //"Bloqueio / Desbloqueio"
					{OemToAnsi(STR0008),"QPA011Dup"  ,0, 4   },; //"Duplicar"
					{OemtoAnsi(STR0007),"QPA011LegOp",0, 5,,.F.}}  //"Legenda"


Return aRotina

Function QIPA011()

Local   cAlias    := " "
Private cCadastro := " "
Private aSitEsp   := {}
Private lAPS
Private __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de Especificacoes				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCadastro := OemtoAnsi(STR0009) //"Especificacao por Grupo"
lAPS      := TipoAps()           //Inicia a variavel lAPS que e utilizada no Roteiro de Operacoes do PCP
cAlias    := "QQC"

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
//³    6 - Altera determinados campos sem incluir novos Regs     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()

Aadd(aSitEsp,{"QQC->QQC_SITREV=='0'.OR.QQC->QQC_SITREV==' '","BR_VERDE"}) //Revisão Disponivel
Aadd(aSitEsp,{"QQC->QQC_SITREV=='1'","BR_VERMELHO"})                      //Revisão Bloqueada
Aadd(aSitEsp,{"QQC->QQC_SITREV=='2'","BR_AMARELO"})                       //Revisão Pendente

mBrowse(06,01,22,75,cAlias,,,,,,aSitEsp)
dbSelectArea(cAlias)

dbClearFilter()

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA011Atu ³ Autor ³Cleber Souza           ³ Data ³14/03/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o status dos Documentos Anexos aos Ensaios     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA011Atu(cAlias,nReg,nOpc)					 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias											  ³±±
±±³			 ³ EXPN1 = Numero do Registro								  ³±±
±±³			 ³ EXPN2 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ 		 = Nulo												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPA011Atu(cAlias,nReg,nOpc)
Local oDlg    := NIL
Local nOpcA   := 0
Local bOk     := {||nOpcA := QPA011bOk(nOpc),IIF(nOpcA == 1,oDlg:End(),"")}
Local bCancel := {||nOpcA := 0,oDlg:End()}
Local oFldEsp := NIL
Local aPagEsp := {}
Local aTitEsp := {}
Local oFldEns := NIL
Local aPagEns := {}
Local aTitEns := {}
Local nOpcGD  := If(nOpc==3 .Or. nOpc==4,GD_UPDATE+GD_INSERT+GD_DELETE,0) //Opcao utilizada na NewGetDados
Local nFatDiv := 1
Local nCkDel  := 0

Private cEspecie := "QIPA010 " //Chave que indentifica a gravacao do texto dos produtos definidos no Grupo
Private lOrdLab  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros utilizados na rotina							     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lDelSG2 := GetMv("MV_QPDELG2",.F.,.F.)
Private lIntQMT := If(GetMV('MV_QIPQMT')=="S",.T.,.F.) //Define a Integracao com o QMT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pontos de Entradas utilizados na rotina de Especificacao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private __lQP010DEL    := ExistBlock("QP010DEL")
Private __lQP010GRV    := ExistBlock("QP010GRV")
Private __lQP010OPE    := ExistBlock("QP010OPE")
Private __lQPA010R     := ExistBlock("QPA010R")
Private aEspecificacao := {} //Armazena os dados referentes a Especificacao do Produto
Private aGets          := {}
Private aRoteiros	   := {} //Armazena os Roteiros de Operação relacionados ao Produto
Private aTela          := {}
Private lQIP011JR      := ExistBlock("QIP011JR")
Private lQP011J11      := ExistBlock("QP011J11")
Private lQPATUGRV      := ExistBlock("QPATUGRV")
Private oEncEsp        := NIL//Cabecalho da Especificacao do Produto
Private oGetEns        := NIL//Ensaios associados aos Roteiros de Operacoes
Private oGetIns        := NIL//Familia de Instrumentos
Private oGetNCs        := NIL//Nao-conformidades
Private oGetOper       := NIL//Roteiro de Operacoes Quality
Private oGetRas        := NIL//Rastreabilidade
Private oGetRot        := NIL//Roteiros relacionados a especificação

//Define as coordenadas da Tela
Private aInfo	 := {}
Private aObjects := {}
Private aSize	 := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os aHeaders utilizados na Especificacao do Produto (Estrutura)	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aHeaderROT := {}
Private aHeaderQQK := aClone(QP10FillG("QQK", Nil, Nil, Nil, Nil))
Private aHeaderQP7 := aClone(QPA010HeadEsp(aClone(QP10FillG("QP7", Nil, Nil, Nil, Nil)))) //Prepara o aHeader com os demais campos a serem utilizados na Especificacao
Private aHeaderQQ1 := aClone(QP10FillG("QQ1", Nil, Nil, Nil, Nil))
Private aHeaderQP9 := aClone(QP10FillG("QP9", Nil, Nil, Nil, Nil))
Private aHeaderQQ2 := aClone(QP10FillG("QQ2", Nil, Nil, Nil, Nil))
Private aHeaderQQH := aClone(QP10FillG("QQH", Nil, Nil, Nil, Nil))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados nos Roteiros (QQK)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosChav    := AsCan(aHeaderQQK,{|x|AllTrim(x[2])=="QQK_CHAVE"  })
Private nPosDescri  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_DESCRI" })
Private nPosGruRec  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_GRUPRE" })
Private nPosLauObr  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_LAU_OB" })
Private nPosOpeGrp  := Ascan(aHeaderQQK,{|x|AllTrim(x[2])=="QQK_OPERGR" })
Private nPosOpeObr  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_OPE_OB" })
Private nPosOper    := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_OPERAC" })
Private nPosRecurso := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_RECURS" })
Private nPosSeqObr  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_SEQ_OB" })
Private nPosSetUp   := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_SETUP"  })
Private nPosTemPad  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TEMPAD" })
Private nPosTpOper  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TPOPER" })
Private nTempDes    := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TEMPDES"})
Private nTempSobre  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TEMPSOB"})
Private nTipoDes    := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TPDESD" })
Private nTipoSobre  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TPSOBRE"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados Rastreabilidade (QQ2) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosDesc  := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_DESC"  })
Private nPosRastr := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_PRODUT"})
Private nPosTipo  := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_TIPO"  })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena o texto do produto por Operacao 					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cTexto := Space(TamSX3("QA2_TEXTO")[1])
Private oTexto := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados nos Ensaios (QP7/QP8) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosAFI   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_AFI"   })
Private nPosAFS   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_AFS"   })
Private nPosCer   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_CERTIF"})
Private nPosDEn   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_DESENS"})
Private nPosDoc	  := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_METODO"})
Private nPosDPl   := Ascan(aHeaderQP7,{|x|AllTrim(x[2])=="QP7_DESPLA"})
Private nPosEns   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_ENSAIO"})
Private nPosFor   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_FORMUL"})
Private nPosLab   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_LABOR" })
Private nPosLIC   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_LIC"   })
Private nPosLSC   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_LSC"   })
Private nPosMet   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_METODO"})
Private nPosMin   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_MINMAX"})
Private nPosNiv   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_NIVEL" })
Private nPosNom   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_NOMINA"})
Private nPosObr   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_ENSOBR"})
Private nPosPlA   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_PLAMO" })
Private nPosRvDoc := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_RVDOC" })
Private nPosSeq   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_SEQLAB"})
Private nPosTipIn := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_TIPO"  })
Private nPosTxt   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP8_TEXTO" })
Private nPosUM    := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_UNIMED"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados nos Instrumentos (QQ1)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aAlterIns := {}
Private aAlterRot := {}
Private nPosDescr := Ascan(aHeaderQQ1,{|x|AllTrim(x[2])=="QQ1_DESCR"})
Private nPosInstr := Ascan(aHeaderQQ1,{|x|AllTrim(x[2])=="QQ1_INSTR"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos referentes ao Plano de Amostrag. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nEnsaio    := 1   //Indica a posicao do Ensaio corrente
Private nOperacao  := 1   //Indica a posicao da Operacao corrente
Private nPosAmo    := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_AMOST" })
Private nPosDscPAE := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_DESCRI"})
Private nPosNivel  := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_NIVAMO"})
Private nPosNQA    := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_NQA"   })
Private nPosPlano  := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_PLANO"})
Private nRoteiro   := 1   //Indica a posicao do Roteiro corrente

//Define os campos para alteracao na Getdados
Aadd(aAlterIns,"QQ1_INSTR")
If lIntQMT
	Aadd(aAlterIns,"QQ1_DESCR")
EndIf

//Define os campos para alteracao na Getdados (Roteiro)
Aadd(aAlterRot,"ROT_CODREC")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados nas NC's (QP9)		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo
Private __cREVISAO := CriaVar("QP6_REVI")   //Revisao do Produto ou Grupo
Private __cROTEIRO := CriaVar("QP6_CODREC") //Roteiro de Operacoes do Produto ou Grupo
Private __dREVISAO := CriaVar("QP6_DTINI")  //Vigencia do Produto ou Grupo
Private aButtons   := {} //Rotinas especificas na barra de ferramentas
Private nPosCla    := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_CLASSE"})
Private nPosDCl    := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_DESCLA"})
Private nPosDNC    := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_DESNCO"})
Private nPosNC     := Ascan(aHeaderQP9,{|x|Alltrim(x[2])=="QP9_NAOCON"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina de inclusao do roteiro de outros produtos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F4,{ || QPATUROTF4() })

//Preenche as opcoes do Folder Especificacoes


Aadd(aTitEsp,OemToAnsi(STR0010)) //"Especificacoes"
Aadd(aTitEsp,OemToAnsi(STR0011)) //"Rastreabilidade"
Aadd(aTitEsp,OemToAnsi(STR0012)) //"Observacao da Operacao"
//Cria as variaveis para edicao na Enchoice
RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.F.)

If (nOpc <> 3)
	QPA->(dbSetOrder(1))
	If QPA->(!dbSeek( xFilial("QPA")+M->QQC_GRUPO))
		Help(" ",1,"QP010NGRUP",,M->QQC_GRUPO,1) //O Grupo nao esta definido na Amarracao   Grupo x Produtos.
		Return(NIL)
	EndIf
EndIf

If (nOpc==4 .Or. nOpc==5) //Alteracao ou Exclusao
	If ( QIPCheckEsp(M->QQC_GRUPO,M->QQC_REVI,.T.,,nOpc) )
		// Se houver OP associada na especificação não permite alterar a especificação
		If ( !QIPChkEspOP(M->QQC_GRUPO,M->QQC_REVI,.T.,,nOpc) )
			Return(NIL)
		EndIf
	Else
		Return(NIL)
	EndIf 
EndIf

If (nOpc==5)    	// inserido para evitar a exclusão do grupo quando existem laudos, antes
	nCkDel := 0     // era validado em QP011AtuGru, porem excluia o grupo
	dbselectarea("QP6")
	QP6->(dbSetOrder(4)) //Grupo+Revisao Grupo
	QP6->(dbSeek(xFilial("QP6")+M->QQC_GRUPO+M->QQC_REVI))
	While QP6->(!Eof()) .And. QP6->(QP6_FILIAL+QP6_GRUPO+QP6_REVIGR)==(xFilial("QP6")+M->QQC_GRUPO+M->QQC_REVI)
		If QP6->QP6_RESULT == "S"
			nCkDel := 1
		EndiF
		QP6->(dbSkip())
	EndDo
	if nCkDel > 0
		HELP(" ",1,"QIP011LAUD")
		Return (NIL)
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta estrutuda da array dos roteiros de operacao             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄvÄÄÄÙ
Aadd(aHeaderRot,{STR0015,"ROT_CODREC","@!",2,0,"QIP010GARO()",,"C","SG2",,,,".T."})   //"Roteiro"
Aadd(aHeaderRot,{STR0016,"ROT_CODDES","@!",100,0,,,"C",,,,,".T."})  //"Tipo do Roteiro"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New(.T.,,,oDlg)
oSize:AddObject( "CABECALHO",		100, 20, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "ROTEIRO",			100, 20, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "OPERACAO",		100, 20, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "ENSAIO",			100, 20, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "INSTRUMENTOS",	100, 20, .T., .T. ) // Totalmente dimensionavel

oSize:lProp 	:= .T. // Proporcional
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

oSize:Process() 	   // Dispara os calculos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela principal da Rotina									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro From oSize:aWindSize[1],oSize:aWindSize[2] to oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
@oSize:aWorkArea[2],oSize:aWorkArea[1] MSPANEL oBtnPanel PROMPT "" SIZE oSize:aWorkArea[3],oSize:aWorkArea[4]-20 OF oDlg

Aadd(aPagEsp,"ESPECIFICACAO")
Aadd(aPagEsp,"RASTREABILIDADE")
Aadd(aPagEsp,"OBSERVACAO-DA-OPERACAO")

//Preenche as opcoes do Folder Ensaios
Aadd(aTitEns,OemToAnsi(STR0013)) //"Familia de Instrumentos"
Aadd(aTitEns,OemToAnsi(STR0014)) //"Nao-Conformidades"

Aadd(aPagEns,"FAMILIA DE INSTRUMENTOS")
Aadd(aPagEns,"NAO-CONFORMIDADES")



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cabecalho da Especificacao do Produto		 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.F.)

nLinIni:= oSize:GetDimension("CABECALHO","LININI")
nColIni:= oSize:GetDimension("CABECALHO","COLINI")
nLinEnd:= oSize:GetDimension("CABECALHO","LINEND")
nColEnd:= oSize:GetDimension("CABECALHO","COLEND")

//	oEnch := MsMGet():New(cAlias,nRecNo,nOpcx,,,,, {nLinIni,nColIni,nLinEnd,nColEnd},aGetCpo,3,,,,oDlg)
oEncEsp := MsMGet():New(cAlias,nReg,nOpc,,,,,{nLinIni,nColIni,nLinEnd,nColEnd},,3,,,,oBtnPanel,,.F.,,,,,,,.T.)
oEncEsp:oBox:Align := CONTROL_ALIGN_TOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara os dados da Especificacao por Grupo para Edicao 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(QPA011FilGrp(M->QQC_GRUPO,M->QQC_REVI))
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Roteiros relacionados a especificação.		 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinIni:= oSize:GetDimension("ROTEIRO","LININI")
nColIni:= oSize:GetDimension("ROTEIRO","COLINI")
nLinEnd:= oSize:GetDimension("ROTEIRO","LINEND")
nColEnd:= oSize:GetDimension("ROTEIRO","COLEND")

oGetRot := MsNewGetDados():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcGD,{||!Empty(oGetRot:aCols[oGetRot:oBrowse:nAT,1])}, {|| IIf(nOpc != 5,QP10ROTUOK(), .T.) } ,"",aAlterRot,,9999,,,,oBtnPanel,aHeaderROT,aRoteiros)
oGetRot:oBrowse:bChange    := {||FolderChange("7",nOpc)}
oGetRot:oBrowse:bDelOk     := {||FolderDelete("7")}
oGetRot:oBrowse:bGotFocus  := {||FolderValid("0")}
oGetRot:oBrowse:bLostFocus := {||FolderSave("7")}
oGetRot:oBrowse:Align := CONTROL_ALIGN_TOP

//Definicao do Folder Especificacoes (1)
nLinIni:= oSize:GetDimension("ENSAIO","LININI")
nColIni:= oSize:GetDimension("ENSAIO","COLINI")
nLinEnd:= oSize:GetDimension("ENSAIO","LINEND")
nColEnd:= oSize:GetDimension("ENSAIO","COLEND")

oFldEsp := TFolder():New(nLinIni,nColIni,aTitEsp,aPagEsp,oBtnPanel,,,,.T.,.F.,nLinEnd,nColEnd)
oFldEsp:Align := CONTROL_ALIGN_ALLCLIENT

//Definicao do Folder (1.1)Instrumentos / (1.2)Nao-conformidades
nLinIni:= oSize:GetDimension("INSTRUMENTOS","LININI")
nColIni:= oSize:GetDimension("INSTRUMENTOS","COLINI")
nLinEnd:= oSize:GetDimension("INSTRUMENTOS","LINEND")
nColEnd:= oSize:GetDimension("INSTRUMENTOS","COLEND")

oFldEns := TFolder():New(nLinIni,nColIni,aTitEns,aPagEns,oFldEsp:aDialogs[1],,,,.T.,.F.,nLinEnd,nColEnd)
oFldEns:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Roteiro de Operacoes utilizados na Especificacao do Produto  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinIni:= oSize:GetDimension("OPERACAO","LININI")
nColIni:= oSize:GetDimension("OPERACAO","COLINI")
nLinEnd:= oSize:GetDimension("OPERACAO","LINEND")
nColEnd:= oSize:GetDimension("OPERACAO","COLEND")

RegToMemory("QQK",If(nOpc==3,.T.,.F.),.F.)

oGetOper := MsNewGetDados():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcGD,{||QP10OPLIOK()},{||QP10OPTUOK()},"",,,9999,,,,oBtnPanel,aHeaderQQK,aEspecificacao[nRoteiro,_OPE])
oGetOper:oBrowse:bChange    := {||FolderChange("1",nOpc)}
oGetOper:oBrowse:bDelOk     := {||FolderDelete("14")}
oGetOper:oBrowse:bGotFocus  := {||FolderValid("0")}
oGetOper:oBrowse:bLostFocus := {||FolderSave("1")}
oGetOper:oBrowse:Align := CONTROL_ALIGN_TOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ (1) Ensaios associados aos Roteiros das Operacoes            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinIni:= oSize:GetDimension("ENSAIO","LININI")
nColIni:= oSize:GetDimension("ENSAIO","COLINI")
nLinEnd:= oSize:GetDimension("ENSAIO","LINEND")
nColEnd:= oSize:GetDimension("ENSAIO","COLEND")

oGetEns := MsNewGetDados():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcGD,{||QP10ENLIOK()},{||QP10ENTUOK()},,,,9999,,,,oFldEsp:aDialogs[1],aHeaderQP7,aEspecificacao[nRoteiro,_ENS,nOperacao])
oGetEns:oBrowse:Align      := CONTROL_ALIGN_TOP
oGetEns:oBrowse:bChange    := {||FolderChange("4",nOpc)}
oGetEns:oBrowse:bDelOk     := {||FolderDelete("4")}
oGetEns:oBrowse:bGotFocus  := {||FolderValid("01")}
oGetEns:oBrowse:bLostFocus := {||FolderSave("4")}
oGetEns:oBrowse:bEditCol   := {||QP010Ordena()}
oGetEns:oBrowse:Align := CONTROL_ALIGN_TOP

//Definicao do Folder (1.1)Instrumentos / (1.2)Nao-conformidades

nLinIni:= oSize:GetDimension("INSTRUMENTOS","LININI")
nColIni:= oSize:GetDimension("INSTRUMENTOS","COLINI")
nLinEnd:= oSize:GetDimension("INSTRUMENTOS","LINEND")
nColEnd:= oSize:GetDimension("INSTRUMENTOS","COLEND")

oFldEns := TFolder():New(nLinIni,nColIni,aTitEns,aPagEns,oFldEsp:aDialogs[1],,,,.T.,.F.,nLinEnd,nColEnd)
oFldEns:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ (2) Rastreabilidade					 						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinIni:= oSize:GetDimension("ENSAIO","LININI")
nColIni:= oSize:GetDimension("ENSAIO","COLINI")
nLinEnd:= oSize:GetDimension("ENSAIO","LINEND")
nColEnd:= oSize:GetDimension("ENSAIO","COLEND")

oGetRas := MsNewGetDados():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcGD,{||QP10RSLIOK(Nil,.T.)},{||QP10RSTUOK(Nil,.T.)},,,,9999,,,,oFldEsp:aDialogs[2],aHeaderQQ2,aEspecificacao[nRoteiro,_RAS,nOperacao])
oGetRas:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT
oGetRas:oBrowse:bGotFocus  := {||FolderValid("01")}
oGetRas:oBrowse:bLostFocus := {||FolderSave("2")}
oGetRas:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ (3) Texto do Produto                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 001.5,001.5 GET oTexto VAR cTexto MEMO NO VSCROLL OF oFldEsp:aDialogs[3] SIZE nFatDiv,108 PIXEL COLOR CLR_BLUE
oTexto:bGotFocus  := {||FolderValid("01")}
oTexto:bLostFocus := {||FolderSave("3")}
oTexto:lReadOnly  := If(Inclui .Or. Altera,.F.,.T.)
oTexto:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ (1.1) Familia de Instrumentos utilizada nos Ensaios		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetIns := MsNewGetDados():New(003,002,047,380,nOpcGD,{||QP10INSLIOK()},{||QP10INSTUOK()},,aAlterIns,,9999,,,,oFldEns:aDialogs[1],aHeaderQQ1,aEspecificacao[nRoteiro,_INS,nOperacao,nEnsaio])
oGetIns:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT
oGetIns:oBrowse:bGotFocus  := {||FolderValid("014")}
oGetIns:oBrowse:bLostFocus := {||FolderSave("5")}
oGetIns:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ (1.2) Nao-conformidades associadas aos Ensaios				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetNCs := MsNewGetDados():New(003,002,047,380,nOpcGD,{||QP10NCLIOK()},{||QP10NCTUOK()},,,,9999,,,,oFldEns:aDialogs[2],aHeaderQP9,aEspecificacao[nRoteiro,_NCO,nOperacao,nEnsaio])
oGetNCs:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT
oGetNCs:oBrowse:bGotFocus  := {||FolderValid("014")}
oGetNCs:oBrowse:bLostFocus := {||FolderSave("6")}
oGetNCs:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao para Visualizacao do Documento anexo ao Ensaio		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtons,{"VERNOTA",{||If(oFldEsp:nOption<>1,Help(" ",1,"QPNVIEWDOC"),QDOVIEW(,oGetEns:aCols[oGetEns:oBrowse:nAt,nPosDoc],QA_UltRvDc(oGetEns:aCols[oGetEns:oBrowse:nAt,nPosDoc],dDataBase,.f.,.f.)))},STR0017,STR0018}) //"Visualizar o conteudo do Documento..." ### "Cont.Doc"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada criado para mudar os botoes da enchoicebar                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QP010BUT")
	aButtons := ExecBlock( "QP010BUT",.F.,.F.,{nOpc,aButtons})
EndIf

BEGIN TRANSACTION
	If ( nOpc <> 2 )
		ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,bOk,bCancel,,aButtons));
			VALID If(lQIP011JR,ExecBlock("QIP011JR"),.T.)
	Else
		ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,bOk,bCancel,,aButtons))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a atualizacao da Especificacao do Produto			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcA == 1

		QPA011Grv(nOpc) //Atualiza a Especificacao

		EvalTrigger() //Processa os gatilhos

		//Ponto de Entrada para gravacoes diversas
		If lQPATUGRV
			ExecBlock("QPATUGRV",.F.,.F.,{nOpc})
		EndIf
	Else 

		DISARMTRANSACTION()
						
	EndIf
END TRANSACTION

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA011Grv ³ Autor ³Paulo Emidio de Barros ³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os dados referentes a Especificacao do Produto    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA011Grv(nOpc)					 			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ 		 = Nulo												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA011Grv(nOpc)
Local aStruAlias := FWFormStruct(3, "QQC")[3]
Local nX

Begin Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Especificacao por Grupo de Produtos							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QP011AtuGru(M->QQC_GRUPO,M->QQC_REVI,M->QQC_CODREC,M->QQC_SITREV,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza os dados referentes a Especificacao do Produto      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("QQC",If(nOpc==3,.T.,.F.))
If (nOpc == 5)
	QQC->(dbDelete())
EndIf

If (nOpc == 3 .Or. nOpc == 4) //Inclusao ou Alteracao
	For nX := 1 To Len(aStruAlias)
		If GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") <> "V"
			If !(AllTrim(aStruAlias[nX,1]) $ "QQC_GRUPOßQQC_REVIßQQC_DTINIßQQC_CODREVßQQC_REVINV")
				FieldPut(FieldPos(AllTrim(aStruAlias[nX,1])),&("M->"+aStruAlias[nX,1]))
			EndIf	
		EndIf
	Next nX
EndIf

If (nOpc == 3) //Inclusao
	QQC->QQC_FILIAL := xFilial("QQC")
	QQC->QQC_GRUPO  := M->QQC_GRUPO
	QQC->QQC_REVI   := M->QQC_REVI
	QQC->QQC_DTINI  := M->QQC_DTINI
	QQC->QQC_CODREC := M->QQC_CODREC
	QQC->QQC_SITREV := M->QQC_SITREV
EndIf

MsUnLock()

//Realiza limpeza do grupo na QP6
If (nOpc == 5) .AND. Findfunction("QIPA010LGR")
	QIPA010LGR() //Limpa o relacionamento com especificações de grupos inexistentes.()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Revisao Invertida especificacao por produto			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 3)
	RecLock("QQC",.F.)
	QQC->QQC_REVINV := Inverte(QQC->QQC_REVI)
	MsUnlock()
EndIf

End Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada especifico para o cliente JNJ				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQP011J11
	ExecBlock('QP011J11',.F.,.F.)
EndIf

Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPA011FilGrp³ Autor³Paulo Emidio de Barros³ Data ³20/02/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche os dados referentes as Operacoes vinculadas ao Gru³±±
±±³			 ³ po de Produtos.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA011FilGrp(EXPC1,EXPC2)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPA011FilGrp(cGrupo,cRevGrp)
Local lRetorno := .T.
Local aAreaAnt := GetArea()
Local cProduto := CriaVar("QP6_PRODUT")
Local cRevisao := CriaVar("QP6_REVI"  )
Local cRoteiro := CriaVar("QP6_CODREC")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem o primeiro Produto associado ao Grupo, para carregar   ³
//³ as Operacoes e suas amarracoes.								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cGrupo) .And. !Empty(cRevGrp)
	QP6->(dbSetOrder(4)) //Grupo+Revisao
	QP6->(dbSeek(xFilial("QP6")+cGrupo+cRevGrp))
	If QP6->(!Eof())
		cProduto := QP6->QP6_PRODUT
		cRevisao := QP6->QP6_REVI
		cRoteiro := QP6->QP6_CODREC
	EndIf
EndIf

//Preenche os dados referentes a Especificacao do Grupo
QPA010FilEsp(cProduto,cRevisao,cRoteiro)

RestArea(aAreaAnt)

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QP011AtuGru ³ Autor³Paulo Emidio de Barros³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche os dados referentes as Operacoes vinculadas ao Gru³±±
±±³			 ³ po de Produtos.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QP011AtuGru(EXPC1,EXPC2,EXPC3,EXPC4,nOpc)   			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QP011AtuGru(cGrupo,cRevGrp,cRotGrp,cStatus,nOpc)
Local aAreaAnt   := GetArea()
Local aAreaQP6   := QP6->(GetArea()) //Salva a Area do QP6
Local cFilQP6    := xFilial("QP6")
Local cProduto   := " "
Local cQP6SQLNam := RetSqlName("QP6")
Local cUltRev    := " "
Local nMenorRecn := 0
Local nNxtRec    := 0
Local nx         := 0

If (nOpc == 3) //Inclusao

	QPA->(dbSetorder(1))
	QPA->(dbSeek(xFilial("QPA")+cGrupo))
	While QPA->(!Eof()) .And. QPA->(QPA_FILIAL+QPA_GRUPO)==(xFilial("QPA")+cGrupo)

	    //Obtem a ultima Revisao do Produto
	    cProduto := QPA->QPA_PRODUT
		cUltRev  := QA_UltRevEsp(cProduto,,,.T.,"QIP")

	   	SC2->(dbSetOrder(8))
		IF SC2->(dbSeek(xFilial("SC2")+QPA->(QPA_PRODUT+cUltRev)))
			DbSelectArea("QP6")
			QP6->(dbSetorder(1))
			If QP6->(dbSeek(cFilQP6+cProduto+Inverte(cUltRev)))
				aRegist := {}
				For nX := 1 to QP6->(fCount())
					cNomCpo :=  QP6->(FieldName(nX))
					Aadd(aRegist,{cNomCpo,QP6->(&cNomCpo)})
				Next nX
				cNextRev := Soma1(cUltRev)
				RecLock("QP6",.T.)

				For nX := 1 To Len(aRegist)
					QP6->(FieldPut(FieldPos(aRegist[nX,1]),aRegist[nX,2]))
				Next

				QP6->QP6_REVI  := cNextRev
				QP6->QP6_REVINV	:= Inverte(cNextRev)
				QP6->QP6_GRUPO  := cGrupo
				QP6->QP6_REVIGR := cRevGrp
				QP6->QP6_CODREC := cRotGrp
				QP6->QP6_SITREV := cStatus
				QP6->QP6_DTINI	:= M->QQC_DTINI
				MsUnLock()
				QPAAtuEsp(QP6->QP6_PRODUT,QP6->QP6_REVI,.T.,nOpc)
			Endif

		Else
			QP6->(dbSetorder(1))
			QP6->(dbSeek(cFilQP6+cProduto+Inverte(cUltRev)))
			If QP6->(!Eof())

		        //Atualiza os dados referentes a Especificacao dos Produtos
				QPAAtuEsp(QP6->QP6_PRODUT,QP6->QP6_REVI,.T.,nOpc)

				//Atualiza os dados referentes ao Grupo
				RecLock("QP6",.F.)
				QP6->QP6_GRUPO  := cGrupo
				QP6->QP6_REVIGR := cRevGrp
				QP6->QP6_CODREC := cRotGrp
				QP6->QP6_SITREV := cStatus
				MsUnLock()

		    EndIf
		Endif
		QPA->(dbSkip())

	EndDo

ElseIf (nOpc == 4) .Or. (nOpc == 5) //Alteracao ou Exclusao

	QP6->(dbSetOrder(4)) //Grupo+Revisao Grupo
	QP6->(dbSeek(cFilQP6+cGrupo+cRevGrp))
	While QP6->(!Eof()) .And. QP6->(QP6_FILIAL+QP6_GRUPO+QP6_REVIGR)==(cFilQP6+cGrupo+cRevGrp)

		//Posiciona no Proximo registro, para manter a sequencia na exclusao
     	QP6->(dbSkip())
     	nNxtRec := QP6->(Recno())
     	QP6->(dbSkip(-1))

   		RecLock("QP6",.F.)
			QP6->QP6_SITREV := cStatus
		QP6->(MsUnLock())

		//Retorna o menor/primeiro R_E_C_N_O_ da QP6 (para o produto) para que valide e não permita a exclusão deste registro
		nMenorRecn := fRetMinRec(cQP6SQLNam, cFilQP6, QP6->QP6_PRODUT)

		If nOpc == 5 .And. QP6->(Recno()) <> nMenorRecn //Deleção e não primeira especificação

			//Atualiza os dados referentes a Especificacao dos Produtos
			QPAAtuEsp(QP6->QP6_PRODUT,QP6->QP6_REVI,.T.,nOpc)

			RecLock("QP6",.F.)
				QP6->(DbDelete())
			QP6->(MsUnLock())
		
		Else
			//Atualiza os dados referentes a Especificacao dos Produtos
			QPAAtuEsp(QP6->QP6_PRODUT,QP6->QP6_REVI,.T.,nOpc)
		EndIf

	 	If (nOpc==5) .And. QP6->QP6_RESULT == "S"
   	    	HELP(" ",1,"QIP011LAUD")
   	    	Return .F.
   		Endif

   		QP6->(dbGoTo(nNxtRec))
	EndDo

EndIf

RestArea(aAreaQP6) //Restaura a Area do QP6
RestArea(aAreaAnt)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QIP011VLGR³ Autor ³Paulo Emidio de Barros ³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do Campo Grupo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QIP011VLGR()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIP011VLGR()
Local lRetorno :=.T.

M->QQC_REVI := QA_NxtRevGrp(M->QQC_GRUPO)

If !Empty(M->QQC_REVI)

	//Verifica a existencia do Produto/Grupo+Revisao
	dbSelectArea("QQC")
	dbSetOrder(1)
	If dbSeek(xFilial("QQC")+M->QQC_GRUPO+M->QQC_REVI)
		Help(" ",1,"QP010EXIGP")
		lRetorno := .F.
	Else
		//Verifica se existe produto associado ao grupo informado
		dbSelectArea("QPA")
		dbSetOrder(1)
		If !dbSeek(xFilial("QPA")+M->QQC_GRUPO)
			Help(" ",1,"QP010NPRGP") //Grupo nao tem produto associado, devera incluir produto ao grupo de produto
			lRetorno := .F.
		EndIf

		//Verifica a existencia do Grupo de Produtos
		If lRetorno
			QP3->(dbSetorder(1))
			If QP3->(!dbSeek(xfilial("QP3")+M->QQC_GRUPO))
				Help(" ",1,"QP010NOGRP") //Nao existe o Grupo de Produtos informado
				lRetorno := .F.
			Else
				M->QQC_DESCRI := QP3->QP3_DESCRI //Descricao do Grupo
			EndIf
		EndIf
    EndIf
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QIP011VINI³ Autor ³Paulo Emidio de Barros ³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o campo Data de Inicio de Vigencia 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QIP011VINI()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_VALID do campo QQC_DTINI e B1_DTINI 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIP011VINI(cGrupo,cRevi,dVigencia)
Local lRetorno := .T.
Local aAreaAnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a Data Inicio Vigencia da revisao anterior			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Val(cRevi) > 0
	dbSelectArea("QQC")
	dbSetOrder(1)
	aAreaAnt := GetArea()

	If !dbSeek(xFilial("QQC")+cGrupo+Inverte(cRevi))
		dbSeek(xFilial("QQC")+cGrupo)
		While !Eof() .And. (QQC_FILIAL+QQC_GRUPO) == (xFilial("QQC")+cGrupo)
			If QQC_REVI < cRevi
				Exit
			EndIf
			dbSkip()
		Enddo
	Else
		dbskip()
	EndIf

	If !Eof() .And. (QQC_FILIAL+QQC_GRUPO) == (xFilial("QQC")+cGrupo)
		If QQC_DTINI > dVigencia
			HELP(" ",1,"A010REVANT",,DTOC(M->QQC_DTINI),2,1) //Rev. anterior e' valida a partir de
			lRetorno := .F.
		EndIf
	EndIf
	RestArea(aAreaAnt)

EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QIP011WHRV³ Autor ³Paulo Emidio de Barros ³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define a clausula When para a Revisao					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QIP011WHRV()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIP011WHRV()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao exista Revisao disponivel, a mesma sera sugerida co ³
//³ mo "00".													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(M->QQC_REVI)
	M->QQC_REVI := "00"
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QP011VldRot ³ Autor³Paulo Emidio de Barros³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do Roteiro de Operacoes						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QP011VldRot()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Naum esta sendo utilizado na rotina de Especif. por Grupo  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QP011VldRot()
Local ny
Local cRot:= &(ReadVar())

For nY:=1 to Len(oGetRot:aCols)
	If oGetRot:aCols[nY,1]== cRot
		oGetRot:aCols[nY,2] := STR0030 //"Roteiro Primario"
		oGetRot:Refresh()
	Else
	  	oGetRot:aCols[nY,2] := STR0031 //"Roteiro Secundario"
		oGetRot:Refresh()
	Endif

Next nY
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA011LegOp³ Autor ³Cleber L. Souza 		³ Data ³10/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas nas OPs				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA011LegOp()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA011LegOp()
Local aLegenda := {}

Aadd(aLegenda,{"BR_VERDE",   OemToAnsi(STR0019)}) //"Revisão Disponivel"
Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0020)}) //"Revisão Bloqueada"
Aadd(aLegenda,{"BR_AMARELO", OemToAnsi(STR0021)}) //"Revisão Pendente"

BrwLegenda(cCadastro,OemToAnsi(STR0022),aLegenda) //"Status das Operações"
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA011BLOQ ³ Autor ³Cleber L. Souza 		³ Data ³10/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina que bloqueia / desbloqueia a especificação          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA011BLOQ()	    										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA011BLOQ()

Local cMsg
Local nNxtRec
Local nRecQQC   := 0
Local lLib      := .T.
Local cGrupo
Local cRev

If QQC->QQC_SITREV == "1"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vericica se existem especificação vigente.					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRecQQC   := QQC->(Recno())
	cGrupo    := QQC->QQC_GRUPO
	cRev      := QQC->QQC_REVI

    dbSelectArea("QQC")
    dbSetOrder(1)
    If dbSeek(xFilial("QQC")+cGrupo+INVERTE(SOMA1(cRev)))
       IF QQC->QQC_DTINI <= dDataBase
       		lLib := .F.
       EndIF
    EndIF

	If lLib

		QQC->(dbGoTo(nRecQQC))
		cMsg := STR0023+CHR(13)+CHR(10) //"Esta sendo realizado a Liberação da Especificação do Grupo : "
		cMsg += STR0024 + QQC->QQC_GRUPO+CHR(13)+CHR(10) //"Grupo : "
		cMsg += STR0025 + QQC->QQC_REVI+CHR(13)+CHR(10) //"Revisao : "
		cMsg += STR0026 //"Deseja confirmar a liberação dessa especificação ?"

		If MsgYesNo(OemToAnsi(cMsg),OemToAnsi(STR0024))  //"Atencao"
			dbSelectArea("QQC")
			RecLock("QQC",.f.)
			QQC->QQC_SITREV := "0"
			MsUnlock()
		EndIf

		QP6->(dbSetOrder(4)) //Grupo+Revisao Grupo
		QP6->(dbSeek(xFilial("QP6")+QQC->QQC_GRUPO+QQC->QQC_REVI))
		While QP6->(!Eof()) .And. QP6->(QP6_FILIAL+QP6_GRUPO+QP6_REVIGR)==(xFilial("QP6")+QQC->QQC_GRUPO+QQC->QQC_REVI)

			//Posiciona no Proximo registro, para manter a sequencia na exclusao
			QP6->(dbSkip())
			nNxtRec := QP6->(Recno())
			QP6->(dbSkip(-1))

			RecLock("QP6",.F.)
			QP6->QP6_SITREV := "0"
			MsUnLock()

			QP6->(dbGoTo(nNxtRec))
		EndDo
	Else

		HELP(" ",1,"A010BLOQ")
		Return

	EndIF
Else

	cMsg := STR0027+CHR(13)+CHR(10) //"Esta sendo realizado o Bloqueio da Especificação do Grupo : "
	cMsg += STR0024 + QQC->QQC_GRUPO+CHR(13)+CHR(10) //"Grupo : "
	cMsg += STR0025 + QQC->QQC_REVI+CHR(13)+CHR(10) //"Revisao : "
	cMsg += STR0028 //"Deseja confirmar o bloqueio dessa especificação ?"

	If MsgYesNo(OemToAnsi(cMsg),OemToAnsi(STR0029))  //"Atencao"
		dbSelectArea("QQC")
		RecLock("QQC",.f.)
		QQC->QQC_SITREV := "1"
		MsUnlock()
	EndIf

	QP6->(dbSetOrder(4)) //Grupo+Revisao Grupo
	QP6->(dbSeek(xFilial("QP6")+QQC->QQC_GRUPO+QQC->QQC_REVI))
	While QP6->(!Eof()) .And. QP6->(QP6_FILIAL+QP6_GRUPO+QP6_REVIGR)==(xFilial("QP6")+QQC->QQC_GRUPO+QQC->QQC_REVI)

		//Posiciona no Proximo registro, para manter a sequencia na exclusao
		QP6->(dbSkip())
		nNxtRec := QP6->(Recno())
		QP6->(dbSkip(-1))

		RecLock("QP6",.F.)
		QP6->QP6_SITREV := "1"
		MsUnLock()

		QP6->(dbGoTo(nNxtRec))
	EndDo

EndIF

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QPA011Dup ³ Autor ³Paulo Emidio de Barros³ Data ³28/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a Duplicacao da Especificacao de um Grupo de Produ ³±±
±±³			 ³ tos.                                                    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA011Dup()											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ 														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA011Dup(cAlias,nReg,nOpc)
Local aAreaAnt := GetArea()
Local cPerg    := "QPA011A"
Local cGrpOri  := " "
Local cRevOri  := " "

//Armazena os Dados referente ao Grupo a ser duplicado.
cGrpOri := QQC->QQC_GRUPO
cRevOri := QQC->QQC_REVI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MV_PAR01 = Grupo destino                ?					 ³
//³ MV_PAR02 = Revisao Destino              ?					 ³
//³ MV_PAR03 = Roteiro de Operacoes Destino ?					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( Pergunte(cPerg,.T.) )
	//Realiza a duplicacao do Grupo de Produtos
	IF QIPDupGrp(cGrpOri,cRevOri,mv_par01,mv_par02,.T.)
		QP6->(dbSetOrder(4)) //Grupo+Revisao Grupo
		QP6->(dbSeek(xFilial("QP6")+cGrpOri+mv_par01))   // Busco grupo duplicado e mudo resultado = N por não ter resultado ainda
		While QP6->(!Eof()) .And. QP6->(QP6_FILIAL+QP6_GRUPO+QP6_REVIGR)==(xFilial("QP6")+cGrpOri+mv_par01)
			If QP6->QP6_RESULT == "S"
				RecLock("QP6",.F.)
				QP6->QP6_RESULT := "N"
				MsUnLock()
			EndiF
			QP6->(dbSkip())
		EndDo
	EndIF
EndIf

RestArea(aAreaAnt)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QPA011VDup³ Autor ³Paulo Emidio de Barros³ Data ³28/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao do Grupo de Produto e Revisao a ser criada na du ³±±
±±³			 ³ plicacao.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA011VDup()											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ 														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA011													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPA011VDup()
Local lRetorno := .T.
Local aAreaQQC := QQC->(GetArea())

If Empty(mv_par01)
	Help(" ",1,"QIPNGRPREV") //Nao sera possivel a duplicacao do Grupo de Produtos.
	lRetorno := .F.
Else
	QQC->(dbSetOrder(1))
	If QQC->(dbSeek(xFilial("QQC")+QQC->QQC_GRUPO+Inverte(mv_par01)))
		//Verifica se a especificação possui Operação e ensaio
		If QIPExisEsp(QQC->QQC_GRUPO, QQC->QQC_REVI)
			Help(" ",1,"QIPGRPEXIS") //Ja existe Grupo de Produtos com a Revisao informada.
			lRetorno := .F.
		EndIf
	EndIf
EndIf

RestArea(aAreaQQC)
Return(lRetorno)

/*/{Protheus.doc} QPA011PREV
Validação Campo Grupo de Produtos da Especificação e Preenche Variáveis Private do Processo
@author Microsiga
@since  12/26/07
@return lReturn, lógico, valida o preenchimento do grupo de produtos para a especificação
*/
Function QPA011PREV()

	Local aArea   := GetArea()
	Local cGrupo  := M->QQC_GRUPO
	Local cRev    := If(M->QQC_REVI<>"00",Strzero((VAL(M->QQC_REVI)-1),2),M->QQC_REVI)
	Local lReturn := .T.

	Default cProduto := CriaVar("QP6_PRODUT")
	Default cRevisao := CriaVar("QP6_REVI")
	Default cRoteiro := CriaVar("QP6_CODREC")

	If M->QQC_REVI <> "00"
		lReturn := VldEspcPrd(cGrupo, cRev)
		If lReturn
			QP6->(dbSetOrder(4)) //Grupo+Revisao
			If QP6->(dbSeek(xFilial("QP6")+cGrupo+cREv))
				cProduto := QP6->QP6_PRODUT
				cRevisao := QP6->QP6_REVI
				cRoteiro := QP6->QP6_CODREC
				QP010FilRot(cProduto,QA_UltRevEsp(cProduto,,,.T.,"QIP"),M->QQC_ROTSIM)
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lReturn

/*/{Protheus.doc} VldEspcPrd
Indica se existem especificações de produtos válidas para a operação
@author brunno.costa
@since  12/01/2021
@param 01 - cGrupo  , caracter, código do grupo de especificação relacionado
@param 02 - cRevisao, caracter, código da revisão da especificação por grupo relacionada
@return lEspecProd, lógico, indica se existem especificações de produtos válidas para a operação
/*/
Static Function VldEspcPrd(cGrupo, cRevisao)
	Local cAlias     := GetNextAlias()
	Local lEspecProd := .F.

    BeginSql Alias cAlias
        SELECT COUNT(*) AS QTD

		FROM (SELECT QP6_PRODUT, QP6_REVI, QP6_GRUPO, QP6_REVIGR, QP6_SITREV
			  FROM %Table:QP6%
			  WHERE (%NotDel%)
			        AND (QP6_FILIAL = %xfilial:QP6%)
			        AND (QP6_SITREV = 0)) 
			      AS ESPECIFICACOES_PRODUTOS 
			
		INNER JOIN
			(SELECT QPA_GRUPO, QPA_PRODUT
			 FROM %Table:QPA%
			 WHERE (%NotDel%)
			       AND (QPA_FILIAL = %xfilial:QPA%)
			       AND (QPA_GRUPO  = %Exp:cGrupo%)) 
			 	AS GRUPOS_PRODUTOS
			 	ON ESPECIFICACOES_PRODUTOS.QP6_PRODUT = GRUPOS_PRODUTOS.QPA_PRODUT 
				
		INNER JOIN
			(SELECT QQC_GRUPO, QQC_REVI
			 FROM %Table:QQC%
			 WHERE (%NotDel%)
			    AND (QQC_FILIAL = %xfilial:QQC%)
			 	AND (QQC_GRUPO  = %Exp:cGrupo%)
			 	AND (QQC_REVI   = %Exp:cRevisao%))
			 	AS ESPECIFICACOES_GRUPOS
				ON    (ESPECIFICACOES_PRODUTOS.QP6_GRUPO  = ESPECIFICACOES_GRUPOS.QQC_GRUPO OR (ESPECIFICACOES_PRODUTOS.QP6_GRUPO   = ' '))
				  AND (ESPECIFICACOES_PRODUTOS.QP6_REVIGR = ESPECIFICACOES_GRUPOS.QQC_REVI  OR (ESPECIFICACOES_PRODUTOS.QP6_REVIGR  = ' '))
				  AND  GRUPOS_PRODUTOS.QPA_GRUPO          = ESPECIFICACOES_GRUPOS.QQC_GRUPO
    EndSql

    If !(cAlias)->(Eof()) .AND. (cAlias)->QTD > 0
        lEspecProd := .T.
	Else
		//STR0032 - "Operação não permitida, não existem especificações de produtos válidas para continuidade na operação."
		//STR0033 - "Cancele esta inclusão (ESC + Cancelar), selecione a especificação por grupo origem na tela e gere uma nova revisão através da opção"
		//STR0008 - "Gera Rev."
		//STR0034 - "no menu Outras Ações."
		Help( " ", 1, ProcName(1) + "-" + cValToChar(ProcLine()),,STR0032,1, 1, NIL, NIL, NIL, NIL, NIL, {STR0033 + " '" + STR0008 + "' " + STR0034})
    EndIf 

    (cAlias)->(DbCloseArea())

Return lEspecProd

/*/{Protheus.doc} fRetMinRec
Retorna o menor/primeiro R_E_C_N_O_ da QP6 (para o produto) para que valide e não permita a exclusão deste registro
@type  Static Function
@author rafael.kleestadt
@since 29/03/2022
@version 1.0
@param cQP6SQLNam, caractere, nome da tabela QP6 na base de dados
@param cFilQP6, caractere, código da filial corrente da QP6
@param cProd, caractere, código do produto para consulta do menor/primeiro R_E_C_N_O_ da QP6
@return nMenorRecn, numeric, numero do menor/primeiro R_E_C_N_O_ da QP6
@example
(examples)
@see (links_or_references)
/*/
Static Function fRetMinRec(cQP6SQLNam, cFilQP6, cProd)
Local cAlias     := GetNextAlias()
Local cQuery     := ""
Local nMenorRecn := 0
DEFAULT cQP6SQLNam := RetSqlName("QP6")
DEFAULT cFilQP6    := xFilial("QP6")

//Somente na exclusão
cQuery := " SELECT MIN(QP6.R_E_C_N_O_) AS MENORREC "
cQuery +=   " FROM "+cQP6SQLNam+" QP6 "
cQuery +=  " WHERE QP6.QP6_PRODUT = '"+cProd+"' "
cQuery +=    " AND QP6.D_E_L_E_T_ = ' ' "   
cQuery +=    " AND QP6.QP6_FILIAL = '"+cFilQP6+"' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),cAlias,.F.,.T.)

If (cAlias)->(!EOF())
	nMenorRecn := (cAlias)->MENORREC
Endif
(cAlias)->(DbCloseArea())
	
Return nMenorRecn


/*/{Protheus.doc} QPA011bOk 
Validação bOk QPA011Atu
@author rafael.hesse
@since 22/04/2022
@version 1.0
@param 01 - nOpc , número, valor da opção escolhida no browse da tela, conforme Static Function MenuDef()
/*/
Static Function QPA011bOk(nOpc)
Local nRet	:= 0

	FolderSave("1234567")

    If nOpc != 5
		If Obrigatorio(aGets,aTela) .and. QP10ValIns() .and. QP10ROTUOK() 
			nRet := 1
		else
			nRet := 0
		EndIf	
	else
		nRet := 1
	EndIf

Return nRet
