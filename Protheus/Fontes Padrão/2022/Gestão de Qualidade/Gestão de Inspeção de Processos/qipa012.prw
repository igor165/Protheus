#INCLUDE "PROTHEUS.CH"
#INCLUDE "QIPA012.CH"
#INCLUDE "TOTVS.CH"

Static _ROT := 1 //Roteiro
Static _OPE := 2 //Operacao
Static _RAS := 3 //Rastreabilidade 
Static _TXT := 4 //Observacoes da Operacao                                                                                 
Static _ENS := 5 //Ensaio
Static _INS := 6 //Instrumentos
Static _NCO := 7 //Nao-conformidades
Static _PAE := 8 //Plano de Amostragem por Ensaio

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ QPM010 - Variaveis utilizadas para parametros					³
//³ mv_par01				// Produto Origem    					³
//³ mv_par02				// Revisao Origem 						³
//³ mv_par03				// Produto Destino                		³
//³ mv_par04				// Revisao Destino						³
//³ mv_par05				// Origem da Descricao                  ³
//³ mv_par06				// Descricao do Produto Destino         ³
//³ mv_par07				// Roteiro De       	                ³
//³ mv_par08				// Roteiro Ate		                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ QPA10D - Variaveis utilizadas para parametros					³
//³ mv_par01				// Produto Destino    					³
//³ mv_par02				// Revisao Destino 						³
//³ mv_par03				// Roteiro De                           ³
//³ mv_par04				// Roteiro Ate                          ³
//³ mv_par05				// Origem da Descricao                  ³
//³ mv_par06				// Descricao do Produto Destino         ³
//³ mv_par07				// Roteiro Primario                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static sMvPar05 := Nil
Static sMvPar06 := Nil
Static sMvPar07 := Nil
Static sMvPar08 := Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ QIPA012  ³ Autor ³ Cleber Souza          ³ Data ³11/03/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de atualizacao das Especificacoes de Produtos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIP													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³STR 	     ³ Ultimo utilizado -> STR0000                                ³±±
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

Local aRotAdic  := {} 
Private aRotina := {	{OemtoAnsi(STR0001),"AxPesqui"   ,0, 1,,.F.},;	//"Pesquisar"
						{OemtoAnsi(STR0002),"QPA012Atu"  ,0, 2   },;	//"Visualizar"
						{OemtoAnsi(STR0003),"QPA012Atu"  ,0, 3   },;	//"Incluir"
						{OemtoAnsi(STR0004),"QPA012Atu"  ,0, 4, 2},;	//"Alterar"
						{OemtoAnsi(STR0005),"QPA012Atu"  ,0, 5, 1},;	//"Excluir"
						{OemtoAnsi(STR0006),"QPA012BLOQ" ,0, 5   },;	//"Bloqueio"    
						{OemtoAnsi(STR0008),"QPA012Dup"  ,0, 4   },;	//"Duplicar"   
						{OemtoAnsi(STR0007),"QPA012LegOp",0, 5,,.F.},;	//"Legenda"
						{OemtoAnsi(STR0040),"QPA012Atu"  ,0, 9   }}	    //"Alterar Grupo"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QP010ROT")
	aRotAdic := ExecBlock("QP010ROT", .F., .F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

Function QIPA012()                   

Local   cAlias     := " " 

Private cCadastro  := " "
Private aSitEsp    := {}
Private lAPS        
Private __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      

cCadastro := OemtoAnsi(STR0009)       //"Especificacao de Produtos" 
lAPS      := TipoAps()                //Inicia a variavel lAPS que e utilizada no Roteiro de Operacoes do PCP
cAlias    := "QP6"

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

Aadd(aSitEsp,{"QP6->QP6_SITREV=='0'.OR.QP6->QP6_SITREV==' '","BR_VERDE"})  //Revisão Disponivel
Aadd(aSitEsp,{"QP6->QP6_SITREV=='1'","BR_VERMELHO"})                       //Revisão Bloqueada
Aadd(aSitEsp,{"QP6->QP6_SITREV=='2'","BR_AMARELO"})                        //Revisão Pendente  

mBrowse(06,01,22,75,cAlias,,,,,,aSitEsp)
dbSelectArea(cAlias)

dbClearFilter()

Return(NIL)                                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA012Atu ³ Autor ³Cleber Souza           ³ Data ³11/03/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o status dos Documentos Anexos aos Ensaios     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA012Atu(cAlias,nReg,nOpc)					 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias											  ³±±
±±³			 ³ EXPN1 = Numero do Registro								  ³±±
±±³			 ³ EXPN2 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ 		 = Nulo												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA012													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA012Atu(cAlias,nReg,nOpc)

Local aPagEns    := {}
Local aPagEsp    := {}
Local aTitEns    := {}
Local aTitEsp    := {}
Local bCancel    := Nil
Local bOk        := Nil
Local lPrototipo := IsProdProt(QP6->QP6_PRODUT)
Local nColEnd    := 0
Local nColIni    := 0
Local NFATDIV    := 1
Local nLinEnd    := 0
Local nLinIni    := 0
Local nOpcA      := 0
Local nOpcGD     := If(nOpc==3 .Or. nOpc==4 .Or. nOpc==9,GD_UPDATE+GD_INSERT+GD_DELETE,0) //Opcao utilizada na NewGetDados
Local nOpcRot    := If(!lPrototipo .Or. nOpc==3,nOpcGD,0)
Local oFldEns    := Nil
Local oFldEsp    := Nil
Local oSize      := Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros utilizados na rotina							     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cPrioriR := GetMv("MV_QIPOPEP",.F.,"2") //Prioriza dados do Roteiro/Operacoes de 1 = Materiais / 2 - Quality
Private lDelSG2  := GetMv("MV_QPDELG2",.F.,.F.)
Private lIntQMT  := If(GetMV( 'MV_QIPQMT' )=="S",.T.,.F.) //Define a Integracao com o QMT 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pontos de Entradas utilizados na rotina de Especificacao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private __lQP010GRV    := ExistBlock("QP010GRV")
Private __lQP010OPE    := ExistBlock("QP010OPE")
Private __lQPA010R     := ExistBlock("QPA010R")
Private lQIP010JR      := ExistBlock("QIP010JR")
Private lQP010DEL      := ExistBlock("QP010DEL")
Private lQP010GRV      := ExistBlock("QP010GRV")
Private lQP010J11      := ExistBlock("QP010J11")
Private lQP010OPE      := ExistBlock("QP010OPE")
Private lQPA010R       := ExistBlock("QPA010R")
Private lQPATUGRV      := ExistBlock("QPATUGRV")
Private lQPATUSB1      := ExistBlock("QPATUSB1")

Private aEspecificacao := {} //Armazena os dados referentes a Especificacao do Produto
Private aGets          := {}
Private aRoteiros      := {} //Armazena os Roteiros de Operação relacionados ao Produto           
Private aTela          := {}
Private cEspecie       := "QIPA010 " //Chave que indentifica a gravacao do texto
Private lOrdLab        := .F.
Private lRotMod        := .T.
Private oDlg           := NIL
Private oEncEsp        := NIL //Cabecalho da Especificacao do Produto
Private oGetEns        := NIL //Ensaios associados aos Roteiros de Operacoes
Private oGetIns        := NIL //Familia de Instrumentos
Private oGetNCs        := NIL //Nao-conformidades
Private oGetOper       := NIL //Roteiro de Operacoes Quality
Private oGetRas        := NIL //Rastreabilidade
Private oGetRot        := NIL //Roteiros relacionados a especificação 

//Define as coordenadas da Tela
Private aInfo    := {}
Private aObjects := {}
Private aPosObj  := {}
Private aSize    := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os aHeaders utilizados na Especificacao do Produto (Estrutura)	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aHeaderQP7 := aClone(QPA010HeadEsp(aClone(QP10FillG("QP7", Nil, Nil, Nil, Nil)))) //Prepara o aHeader com os demais campos a serem utilizados na Especificacao
Private aHeaderQP9 := aClone(QP10FillG("QP9", Nil, Nil, Nil, Nil))
Private aHeaderQQ1 := aClone(QP10FillG("QQ1", Nil, Nil, Nil, Nil))
Private aHeaderQQ2 := aClone(QP10FillG("QQ2", Nil, Nil, Nil, Nil))
Private aHeaderQQH := aClone(QP10FillG("QQH", Nil, Nil, Nil, Nil))
Private aHeaderQQK := aClone(QP10FillG("QQK", Nil, Nil, Nil, Nil))
Private aHeaderROT := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados nos Roteiros (QQK)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosChav    := AsCan(aHeaderQQK,{|x|AllTrim(x[2])=="QQK_CHAVE" })
Private nPosDescri  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_DESCRI" })
Private nPosGruRec  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_GRUPRE" })
Private nPosLauObr  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_LAU_OB" })
Private nPosOpeGrp  := Ascan(aHeaderQQK,{|x|AllTrim(x[2])=="QQK_OPERGR" })
Private nPosOpeObr  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_OPE_OB" })
Private nPosOper    := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_OPERAC" })
Private nPosRecurso := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_RECURS" })
Private nPosSeqObr  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_SEQ_OB" })
Private nPosSetUp   := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_SETUP" })
Private nPosTemPad  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TEMPAD" })
Private nPosTpOper  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TPOPER" })
Private nTempDes    := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TEMPDES"})
Private nTempSobre  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TEMPSOB"})
Private nTipoDes    := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TPDESD" })
Private nTipoSobre  := Ascan(aHeaderQQK,{|x|Alltrim(x[2])=="QQK_TPSOBRE"})
                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados Rastreabilidade (QQ2) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosDesc  := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_DESC" })
Private nPosRastr := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_PRODUT"})
Private nPosTipo  := Ascan(aHeaderQQ2,{|x|AllTrim(x[2])=="QQ2_TIPO" })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena o texto do produto por Operacao 					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cTexto    := Space(TamSX3("QA2_TEXTO")[1])
Private oTexto    := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva as posicoes dos campos utilizados nos Ensaios (QP7/QP8) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosAFI   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_AFI" })
Private nPosAFS   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_AFS" })
Private nPosCer   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_CERTIF"})
Private nPosDEn   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_DESENS"})
Private nPosDoc   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_METODO"})
Private nPosDPl   := Ascan(aHeaderQP7,{|x|AllTrim(x[2])=="QP7_DESPLA"})
Private nPosEns   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_ENSAIO"})
Private nPosFor   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_FORMUL"})
Private nPosLab   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_LABOR" })
Private nPosLIC   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_LIC" })
Private nPosLSC   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_LSC" })
Private nPosMet   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_METODO"})
Private nPosMin   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_MINMAX"})
Private nPosNiv   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_NIVEL" })
Private nPosNom   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_NOMINA"})
Private nPosObr   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_ENSOBR"})
Private nPosPlA   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_PLAMO" })
Private nPosRvDoc := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_RVDOC" })
Private nPosSeq   := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_SEQLAB"})
Private nPosTipIn := Ascan(aHeaderQP7,{|x|Alltrim(x[2])=="QP7_TIPO" })
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
Private nEnsaio    := 1 //Indica a posicao do Ensaio corrente 
Private nOperacao  := 1 //Indica a posicao da Operacao corrente
Private nPosAmo    := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_AMOST" })
Private nPosDscPAE := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_DESCRI"})
Private nPosNivel  := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_NIVAMO"})
Private nPosNQA    := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_NQA" })
Private nPosPlano  := Ascan(aHeaderQQH,{|x|AllTrim(x[2])=="QQH_PLANO"})
Private nRoteiro   := 1 //Indica a posicao do Roteiro corrente

bCancel := {|| nOpcA := 0, oDlg:End() }
bOk     := {|| QPA012lOK(nOpc, @nOpcA)}

//Reseta controle de re-exibição de help da QP6
lHlpLinQP6 := .T.
              
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
Private __cGRPPROD := CriaVar("QP6_PRODUT") //Codigo do Produto ou Grupo
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

Aadd(aPagEsp,"ESPECIFICACAO")    
Aadd(aPagEsp,"RASTREABILIDADE")
Aadd(aPagEsp,"OBSERVACAO-DA-OPERACAO")

//Preenche as opcoes do Folder Ensaios
Aadd(aTitEns,OemToAnsi(STR0013)) //"Familia de Instrumentos"
Aadd(aTitEns,OemToAnsi(STR0014)) //"Nao-Conformidades"

Aadd(aPagEns,"FAMILIA DE INSTRUMENTOS") 
Aadd(aPagEns,"NAO-CONFORMIDADES")             
              
//Cria as variaveis para edicao na Enchoice
RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.F.)            

If (nOpc==4 .Or. nOpc==5 .Or. nOpc==6) //Alteracao ou Exclusao
	If !QIPCheckEsp(M->QP6_PRODUT,M->QP6_REVI,,,nOpc)
		HELP(" ",1,"QPCHKESPRV") //A especificacao do Grupo de produtos  nao podera ser alterada ou excluida, pois existem ordens de producoes cadastradas com a revisao vigente de produtos definidos para o Grupo. 
		Return(NIL)
	EndIf	

	//Verifica se a Especificacao possui medicoes cadastradas
	If !QPA010VerMed(M->QP6_PRODUT,M->QP6_REVI)
		Return(NIL)
	EndIf
	
    //Verifica se o Produto esta definido para algum Grupo		 
	QPA->(dbSetOrder(2))
	If QPA->(dbSeek(xFilial("QPA")+M->QP6_PRODUT)) 
		If (nOpc==4) .and. (!Empty(QP6->QP6_GRUPO) .And. !Empty(QP6->QP6_REVIGR))
			//STR0044 - 'Operação não permitida, o produto faz parte de um grupo de produto com especificação por grupo existente.'
			//STR0045 - "Informe um outro produto para prosseguir."
			Help( " ", 1, ProcName(1) + "-" + cValToChar(ProcLine()),,STR0044,1, 1, NIL, NIL, NIL, NIL, NIL, {STR0045})
			Return(NIL)				
		EndIf	
	EndIf 
	//Verifica se o Produto esta definido para algum Grupo		 
	QPA->(dbSetOrder(2))
	If QPA->(dbSeek(xFilial("QPA")+M->QP6_PRODUT))
		While QPA->(!Eof()) .And. nOpc==5
			If M->QP6_PRODUT == QPA->QPA_PRODUT
    			Help(" ",1,"QP010EXGR")  //("Não será possível excluir a especificação,pois pertence a um Grupo de Produtos.")
    			Return (Nil)
    		Endif
    		QPA->(DbSkip())
    	Enddo		
	EndIf
	
	// Verifica se o Produto não está associado a algum Grupo - botão Alterar Grupo
    If (nOpc==6).and. (Empty(QP6->QP6_GRUPO) .And. Empty(QP6->QP6_REVIGR))
	   Help(" ",1,"QP010SGRU")
	   Return(NIL)
	Endif                                                            

EndIf 
    //Verifica se esta alterando grupo de produto (botão alterar grupo) para Produto sem grupo
If (nOpc==9).and. (Empty(QP6->QP6_GRUPO) .And. Empty(QP6->QP6_REVIGR))
   Help(" ",1,"QP010SGRU")
   Return(NIL)
Endif  

//Botão Altera Grupo
If nOpc==9
	DbSelectArea("QQC")
	QQC->(dbSetOrder(1))
	If QQC->(dbSeek(xFilial("QQC")+QP6->QP6_GRUPO+Inverte(QP6->QP6_REVIGR)))
		QPA011Atu('QQC',QQC->(Recno()),4)
	EndIf
	QQC->(dbCloseArea())
	Return(NIL)	
EndIF
 
	//Verifica se o Produto esta definido para algum Grupo		 
	QPA->(dbSetOrder(2))
	If QPA->(dbSeek(xFilial("QPA")+M->QP6_PRODUT)) 
		If (nOpc==4) .and. (!Empty(QP6->QP6_GRUPO) .And. !Empty(QP6->QP6_REVIGR))
			Help(" ",1,"QP010TGRU",,OemToAnsi(STR0015)+" : "+QPA->QPA_GRUPO,1) //"Grupo" ### "O produto a ser editado pertence a um Grupo de Produtos, o mesmo podera ser apenas visualizado." 
			Return(NIL)				
		EndIf	
	EndIf
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta estrutuda da array dos roteiros de operacao             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄvÄÄÄÙ
Aadd(aHeaderRot,{STR0016,"ROT_CODREC","@!",2,0,"QIP010GARO()",,"C","SG2",,,,".T."})   //"Roteiro"		

If IsProdProt(M->QP6_PRODUT)
	Aadd(aHeaderRot,{STR0043,"ROT_CODDES","@!",100,0,,,"C",,,,,".T."})  //"Produto Desenvolvido"
Else
	Aadd(aHeaderRot,{STR0017,"ROT_CODDES","@!",100,0,,,"C",,,,,".T."})  //"Tipo do Roteiro"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicoes da FwDefSize        								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSize := FwDefSize():New(.T.,,,oDlg)
oSize:AddObject( "CABECALHO",		100, 20, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "ROTEIRO",			100, 15, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "OPERACAO",		100, 15, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "ENSAIO",			100, 15, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "INSTRUMENTOS",	100, 15, .T., .T. ) // Totalmente dimensionavel	

oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
oSize:Process() 	   // Dispara os calculos


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela principal da Rotina									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro From oSize:aWindSize[1],oSize:aWindSize[2] to oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cabecalho da Especificacao do Produto		 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinIni:= oSize:GetDimension("CABECALHO","LININI")
nColIni:= oSize:GetDimension("CABECALHO","COLINI")
nLinEnd:= oSize:GetDimension("CABECALHO","LINEND")
nColEnd:= oSize:GetDimension("CABECALHO","COLEND")
@oSize:aWorkArea[2],oSize:aWorkArea[1] MSPANEL oBtnPanel PROMPT "" SIZE oSize:aWorkArea[3],oSize:aWorkArea[4]-20 OF oDlg

RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.T.)
oEncEsp := MsMGet():New(cAlias,nReg,nOpc,,,,,{nLinIni,nColIni,nLinEnd,nColEnd},,,,,"QIP010ENOK",oBtnPanel,,.T.,,,,,,,.T.)
oEncEsp:oBox:Align := CONTROL_ALIGN_TOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara os dados da Especificacao do Produto para Edicao 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QPA010FilEsp(M->QP6_PRODUT,M->QP6_REVI,M->QP6_CODREC)		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Roteiros relacionados a especificação.		 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinIni:= oSize:GetDimension("ROTEIRO","LININI")
nColIni:= oSize:GetDimension("ROTEIRO","COLINI")
nLinEnd:= oSize:GetDimension("ROTEIRO","LINEND")
nColEnd:= oSize:GetDimension("ROTEIRO","COLEND")

oGetRot := MsNewGetDados():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcRot,{||!Empty(oGetRot:aCols[oGetRot:oBrowse:nAT,1])},IIf(nOpc != 5,{|| QP10ROTUOK() }, .T.),"",aAlterRot,,9999,,,,oBtnPanel,aHeaderROT,aRoteiros)
oGetRot:oBrowse:bChange    := {||Iif(lRotMod,FolderChange("7",nOpc), Nil)} 
oGetRot:oBrowse:bDelOk     := {||IF(nOpc!=2,FolderDelete("7"),"")}
oGetRot:oBrowse:bGotFocus  := {||FolderValid("0",lRotMod)} 
oGetRot:oBrowse:bLostFocus := {||FolderSave("7")} 
oGetRot:oBrowse:Align := CONTROL_ALIGN_TOP
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara os dados da Especificacao para edicao 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nLinIni:= oSize:GetDimension("ENSAIO","LININI")
nColIni:= oSize:GetDimension("ENSAIO","COLINI")
nLinEnd:= oSize:GetDimension("ENSAIO","LINEND")
nColEnd:= oSize:GetDimension("ENSAIO","COLEND")
//Definicao do Folder Especificacoes (1)
oFldEsp := TFolder():New(nLinIni,nColIni,aTitEsp,aPagEsp,oBtnPanel,,,,.T.,.F.,nLinEnd,nColEnd)
oFldEsp:Align:= CONTROL_ALIGN_ALLCLIENT


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Roteiro de Operacoes utilizados na Especificacao do Produto  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("QQK",If(nOpc==3,.T.,.F.),.F.)            
nLinIni:= oSize:GetDimension("OPERACAO","LININI")
nColIni:= oSize:GetDimension("OPERACAO","COLINI")
nLinEnd:= oSize:GetDimension("OPERACAO","LINEND")
nColEnd:= oSize:GetDimension("OPERACAO","COLEND")

oGetOper := MsNewGetDados():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcGD,{||QP10OPLIOK()},{||QP10OPTUOK()},"",,,9999,,,,oBtnPanel,aHeaderQQK,aEspecificacao[nRoteiro,_OPE])	
oGetOper:oBrowse:bChange    := {||Iif(lRotMod,FolderChange("1",nOpc),Nil)} 
oGetOper:oBrowse:bDelOk     := {||IF(nOpc!=2,FolderDelete("1"),"")} 
oGetOper:oBrowse:bGotFocus  := {||FolderValid("0",lRotMod),Iif(lRotMod,FolderChange("1",nOpc),Nil)} 
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
oGetEns:oBrowse:bChange    := {||FolderChange("4",nOpc)} 
oGetEns:oBrowse:bDelOk     := {||IF(nOpc!=2,FolderDelete("4"),"")} 
oGetEns:oBrowse:bGotFocus  := {||FolderValid("01")} 
oGetEns:oBrowse:bLostFocus := {||FolderSave("4"), QP012VldEn(.F.,@lRotMod)}
oGetEns:oBrowse:bEditCol   := {||QP010Ordena()}
oGetEns:oBrowse:Align := CONTROL_ALIGN_TOP

//Definicao do Folder (1.1)Instrumentos / (1.2)Nao-conformidades
nLinIni:= oSize:GetDimension("INSTRUMENTOS","LININI")
nColIni:= oSize:GetDimension("INSTRUMENTOS","COLINI")
nLinEnd:= oSize:GetDimension("INSTRUMENTOS","LINEND")
nColEnd:= oSize:GetDimension("INSTRUMENTOS","COLEND")
oFldEns := TFolder():New(nLinIni,nColIni,aTitEns,aPagEns,oFldEsp:aDialogs[1],,,,.T.,.F.,nLinEnd,nColEnd)
oFldEns:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada criado para alterar os valores dos campos de ensaio            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QP010ENS") .AND. nOpc!=3
	ExecBlock("QP010ENS",.F.,.F.,{aEspecificacao[nRoteiro,_ENS,nOperacao]})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ (2) Rastreabilidade					 						 ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinIni:= oSize:GetDimension("ENSAIO","LININI")
nColIni:= oSize:GetDimension("ENSAIO","COLINI")
nLinEnd:= oSize:GetDimension("ENSAIO","LINEND")
nColEnd:= oSize:GetDimension("ENSAIO","COLEND")
oGetRas := MsNewGetDados():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcGD,{||QP10RSLIOK()},{||QP10RSTUOK()},,,,9999,,,,oFldEsp:aDialogs[2],aHeaderQQ2,aEspecificacao[nRoteiro,_RAS,nOperacao])
oGetRas:oBrowse:bGotFocus  := {||FolderValid("01")} 
oGetRas:oBrowse:bLostFocus := {||FolderSave("2")}
oGetRas:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

                                                                                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ (3) Texto do Produto                                         ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 001.5,001.5 GET oTexto VAR cTexto MEMO NO VSCROLL OF oFldEsp:aDialogs[3] SIZE nFatDiv,108 PIXEL COLOR CLR_BLUE  
oTexto:bGotFocus  := {||FolderValid("01")} 
oTexto:bLostFocus := {||FolderSave("3")}  
oTexto:lReadOnly  := If(INCLUI .Or. ALTERA,.F.,.T.)   
oTexto:lActive    := .T.  
oTexto:Align := CONTROL_ALIGN_ALLCLIENT
                                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ (1.1) Familia de Instrumentos utilizada nos Ensaios		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetIns := MsNewGetDados():New(003,002,040,380,nOpcGD,{||QP10INSLIOK()},{||QP10INSTUOK()},,aAlterIns,,9999,,,,oFldEns:aDialogs[1],aHeaderQQ1,aEspecificacao[nRoteiro,_INS,nOperacao,nEnsaio])
oGetIns:oBrowse:bGotFocus  := {||FolderValid("014")} 
oGetIns:oBrowse:bLostFocus := {||FolderSave("5")} 
oGetIns:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ (1.2) Nao-conformidades associadas aos Ensaios				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetNCs := MsNewGetDados():New(003,002,040,380,nOpcGD,{||QP10NCLIOK()},{||QP10NCTUOK()},,,,9999,,,,oFldEns:aDialogs[2],aHeaderQP9,aEspecificacao[nRoteiro,_NCO,nOperacao,nEnsaio])
oGetNCs:oBrowse:bGotFocus  := {||FolderValid("014")} 
oGetNCs:oBrowse:bLostFocus := {||FolderSave("6")} 
oGetNCs:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao para Visualizacao do Documento anexo ao Ensaio		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtons,{"VERNOTA",{||If(oFldEsp:nOption<>1,Help(" ",1,"QPNVIEWDOC"),QDOVIEW(,oGetEns:aCols[oGetEns:oBrowse:nAt,nPosDoc],QA_UltRvDc(oGetEns:aCols[oGetEns:oBrowse:nAt,nPosDoc],dDataBase,.f.,.f.)))},STR0018,STR0019}) //"Visualizar o conteudo do Documento..." ### "Cont.Doc"
                                                               
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada criado para mudar os botoes da enchoicebar                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QP010BUT")
	aButtons := ExecBlock( "QP010BUT",.F.,.F.,{nOpc,aButtons})
EndIf

If ( !QIPCheckEsp(M->QP6_PRODUT,M->QP6_REVI,,,nOpc))
		oEncEsp:Disable()  //Cabecalho da Especificacao do Produto
 		oGetRot:Disable()
EndIf

BEGIN TRANSACTION
	If ( nOpc <> 2 )                                                           
		ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons));
									VALID If(lQIP010JR,ExecBlock("QIP010JR"),.T.)	
	Else                                              
		ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons))
	EndIf	  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a atualizacao da Especificacao do Produto			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If nOpcA == 1               
	      
		QPA012Grv(nOpc) //Atualiza a Especificacao
		
		EvalTrigger() //Processa os gatilhos
		
		//Ponto de Entrada para gravacoes diversas
		If lQPATUGRV
			ExecBlock("QPATUGRV",.F.,.F.,{nOpc})
		EndIf
 	Else 

		DISARMTRANSACTION()
						
	EndIf
END TRANSACTION

SetKey(VK_F4,Nil)

Return nOpcA

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA012Grv ³ Autor ³Cleber Souza           ³ Data ³11/03/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os dados referentes a Especificacao do Produto    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA012Grv(nOpc)			 			             		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ 		 = Nulo												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA012													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA012Grv(nOpc)
Local cRevisao   := " "
Local aStruAlias := FWFormStruct(3, "QP6")[3]
Local nX

Local lTemGrp := .F.
Local cGrupo  := ''
Local cRevGrp := ''

//Verifica se o Produto esta definido para algum Grupo		 
QPA->(dbSetOrder(2))
If QPA->(dbSeek(xFilial("QPA")+M->QP6_PRODUT)) 
	lTemGrp := .T.

	cAliasQry := GetNextAlias()
		
	cQry := " SELECT MAX(QQC_REVI) AS QQC_REVI" 
	cQry += "   FROM " + RetSqlName('QQC')
	cQry += "  WHERE QQC_GRUPO  =  '" + QPA->QPA_GRUPO  + "' "
	cQry += "    AND QQC_FILIAL =  '" + QPA->QPA_FILIAL + "' "
	cQry += "    AND D_E_L_E_T_ =  ' ' "
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	dbSelectArea(cAliasQry)
	dbGoTop()
	If (cAliasQry)->(!Eof())
		cRevGrp := (cAliasQry)->(QQC_REVI)
		cGrupo  := QPA->QPA_GRUPO
	EndIf
	
	(cAliasQry)->(DbCloseArea())
		
EndIf

		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Especificacao por Produto									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If (nOpc == 3 .Or. nOpc == 4 .Or. nOpc ==6) //Inclusao ou Alteracao/Alteração Grupo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o SB1 (Cadastro de Produtos); 						 ³
	//³ o QP6 deve ser posicionado no momento.						 ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	QP010AtuSB1(M->QP6_PRODUT)        
			     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada Final da Alteracao da Especificacao - JNJ   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQPATUSB1
		ExecBlock("QPATUSB1",.F.,.F.,{nOpc})
	EndIf	           
		
EndIf
		                                
//Atualizacao dos dados referentes a Especificacao do Produto 
QPAAtuEsp(M->QP6_PRODUT,M->QP6_REVI,M->QP6_CODREC," "," ",nOpc)
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza os dados referentes a Especificacao do Produto      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("QP6",If(nOpc==3,.T.,.F.))
If (nOpc == 5)	
	QP6->(dbDelete())
EndIf

If (nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6) //Inclusao ou Alteracao/Alterar Grupo

	For nX := 1 To Len(aStruAlias)
		If GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") <> "V"
			FieldPut(FieldPos(AllTrim(aStruAlias[nX,1])),&("M->"+aStruAlias[nX,1]))
		EndIf
	Next nX
EndIf

If (nOpc == 3 .OR. nOpc == 4) //Inclusao ou alteração
	QP6->QP6_FILIAL := xFilial("QP6")
	QP6->QP6_CADR   := cUserName
	QP6->QP6_DTCAD  := dDataBase
	If QP6->QP6_DTINI <= dDatabase
		QP6->QP6_SITREV := "0"
	Else 
		QP6->QP6_SITREV := "2"	
	Endif 

	If lTemGrp
		QP6->QP6_GRUPO  := cGrupo
		QP6->QP6_REVIGR := cRevGrp
	EndIf

EndIf 
    
MsUnlock()               

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Revisao Invertida especificacao por produto			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 3) 
	RecLock("QP6",.F.)
	QP6->QP6_REVINV := Inverte(QP6->QP6_REVI)
	MsUnlock()               
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o Historico da Especificacao do Produto ou Grupo		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 3) .Or. (nOpc == 4 .Or. nOpc == 6 ) //Inclusao/Alteracao/Alterar Grupo
	MsMM(QP6_HISTOR,,,M->QP6_MEMO1,1,,,"QP6","QP6_HISTOR")
ElseIf (nOpc == 5)	//Exclusao
	MSMM(QP6_HISTOR,,,,2)
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada especifico para o cliente JNJ				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If lQP010J11
	ExecBlock('QP010J11',.F.,.F.)
EndIf
	
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPAAtuEsp ³ Autor ³Paulo Emidio de Barros ³ Data ³12/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os dados referentes ao Roteiro de Operacoes		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPAAtuEsp(cProduto,cRevisao,cRoteiro,lGrupo,nOpc)	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Produto								  ³±±
±±³			 ³ EXPC2 = Revisao do Produto								  ³±±
±±³			 ³ EXPC3 = Roteiro da Operacao								  ³±±
±±³			 ³ EXPC4 = Grupo de Produtos 								  ³±±
±±³			 ³ EXPC5 = Revisao do Grupo de Produtos 			  	      ³±±
±±³			 ³ EXPN1 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QPAAtuEsp(cProduto,cRevisao,cRoteiro,cGrupo,cRevGrp,nOpc)
Local aAreaAnt   := GetArea()
Local nRot       := 0
Local nOper      := 0
Local nEns       := 0
Local nIns       := 0
Local nNco       := 0
Local nRas       := 0
Local nPAE       := 0
Local nPosDelOpe := 0
Local nPosDelEns := 0         
Local nPosDelIns := 0
Local nPosDelRas := 0
Local nPosDelPAE := 0
Local cOperacao  := " "
Local cEnsaio    := " "
Local cNorma     := " " 
Local nCpo       := 0
Local cAlias     := " "
Local cConteudo  := " "
Local nDec       := 0
Local nLIE       := 0
Local nLSE       := 0
Local cVlrLIE    := " "
Local cVlrLSE    := " "
Local aTexto     := {}
Local cTxtOpe    := " "
Local cChave     := " "
Local aAreaQQK   := {} 
Local cRvDoc     := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizacao das Operacoes 									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nRot := 1 to Len(aEspecificacao)
	
	//Armazena a Roteiro corrente
	cRoteiro := aEspecificacao[nRot,_ROT]
	
	If !Empty(cRoteiro) //Verifica se existe Roteiro Vazio
		
		For nOper := 1 to Len(aEspecificacao[nRot,_OPE])
			
			If nOper > Len(aEspecificacao[nRot,_ENS])
				Exit
			EndIF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizacao das Operacoes									 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			//Armazena a Operacao corrente
			cOperacao := aEspecificacao[nRot,_OPE,nOper,nPosOper]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto especifico para gravacao da Atualizacao				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(FunName()) == "QIPA010"
				If lQPA010R
					If cRoteiro == "01" .And. cOperacao == "01"
						ExecBlock("QPA010R",.F.,.F.,{ALTERA})
					EndIf
				EndIf
			EndIf
			If !Empty(aEspecificacao[nRot,_OPE,nOper,nPosOper])
				
				nPosDelOpe := Len(aEspecificacao[nRot,_OPE,nOper]) //Indica se esta deletado
				
				QQK->(dbSetOrder(1))
				QQK->(dbSeek(xFilial("QQK")+cProduto+cRevisao+cRoteiro+aEspecificacao[nRot,_OPE,nOper,nPosOper]))
				
				If !aEspecificacao[nRot,_OPE,nOper,nPosDelOpe] .And. nOpc <> 5 //Exclusao
					
					If QQK->(!Eof())
						RecLock("QQK",.F.)
					Else
						RecLock("QQK",.T.)
						QQK->QQK_FILIAL := xFilial("QQK")
						QQK->QQK_CODIGO	:= cRoteiro
						QQK->QQK_OPERAC	:= cOperacao
						QQK->QQK_PRODUT := cProduto
						QQK->QQK_REVIPR	:= cRevisao
						QQK->QQK_GRUPO  := cGrupo
						QQK->QQK_REVIGR := cRevGrp
						
						//Indica que o Produto faz parte de um Grupo
						If !Empty(cGrupo)
							QQK->QQK_OPERGR := "S"
						EndIf
						
					EndIf
					
					For nCpo := 1 to Len(aHeaderQQK)
						If aHeaderQQK[nCpo,10] <> "V" .And.;
							!(AllTrim(aHeaderQQK[nCpo,2]) $ "QQK_OPERACßQQK_OPERGR")  //nao considera o campo Operacao, pois o mesmo faz poarte da chave
							QQK->(FieldPut(FieldPos(AllTrim(aHeaderQQK[nCpo,2])),;
							aEspecificacao[nRot,_OPE,nOper,nCpo]))
						EndIf
					Next nCpo
					MsUnLock() 
					FkCommit()
					
					//Atualiza a Chave de Ligacao da Operacao
					If Empty(QQK->QQK_CHAVE)
						aAreaQQK := QQK->(GetArea())
						dbSelectArea("QQK")
						dbSetOrder(2)
						cChave := QA_SXESXF("QQK","QQK_CHAVE",,2)
						ConfirmSX8()
						RestArea(aAreaQQK)
						
						RecLock("QQK",.F.)
						QQK->QQK_CHAVE := cChave
						MsUnLock()
						FkCommit()
						aEspecificacao[nRot,_OPE,nOper,nPosChav] := cChave
					EndIf
					
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizacao do Texto associado a Operacao                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aEspecificacao[nRot,_OPE,nOper,nPosChav]) //Se a chave nao estiver vazia
				If QQK->(!Deleted())
					cTxtOpe := aEspecificacao[nRot,_TXT,nOper]
					aTexto  := {{1,cTxtOpe}}
					
					//Atualiza o Texto relacionado a Operacao
					QA_GrvTXT(aEspecificacao[nRot,_OPE,nOper,nPosChav],cEspecie,1,aTexto)
					
				Else
					//Exclui o Texto relacionado a Operacao
					QA_DelTXT(aEspecificacao[nRot,_OPE,nOper,nPosChav],cEspecie)
					
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizacao dos Ensaios										 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nEns := 1 to Len(aEspecificacao[nRot,_ENS,nOper])
				
				//Armazena o Ensaio corrente
				cEnsaio := aEspecificacao[nRot,_ENS,nOper,nEns,nPosEns]
				
				//Armazena a Norma de Inspecao utilizada no Plano de Amostragem
				cNorma := aEspecificacao[nRot,_ENS,nOper,nEns,nPosPlA]
				cNorma := If(!Empty(cNorma),QA_Plano(cNorma),cNorma)
				
				//Verifica se o Ensaio esta em branco
				If !Empty(aEspecificacao[nRot,_ENS,nOper,nEns,nPosEns])
					
					nPosDelEns := Len(aEspecificacao[nRot,_ENS,nOper,nEns]) //Indica se esta deletado
					
					QP1->(dbSetOrder(1))
					QP1->(dbSeek(xFilial("QP1")+aEspecificacao[nRot,_ENS,nOper,nEns,nPosEns]))
					If QP1->QP1_TPCART <> "X" //Mensuraveis
						cAlias    := "QP7"
						cConteudo := "QP8_TEXTOßQQK_OPERGR"
					Else //Texto
						cAlias    := "QP8"
						cConteudo := "QP7_UNIMEDßQP7_NOMINAßQP7_AFIßQP7_AFSßQP7_LICßQP7_LSCßQP7_MINMAXßQQK_OPERGR"
					EndIf
					
					(cAlias)->(dbSetOrder(1))
					(cAlias)->(dbSeek(xFilial(cAlias)+cProduto+cRevisao+cRoteiro+cOperacao+aEspecificacao[nRot,_ENS,nOper,nEns,nPosEns]))
					
					//Verifica se o Ensaio nao esta marcado para exclusao
					If !aEspecificacao[nRot,_ENS,nOper,nEns,nPosDelEns] .And. nOpc <> 5 //Exclusao
						
						If !Empty(aEspecificacao[nRot,_ENS,nOper,nEns,nPosDoc])
				    	    cRvDoc := QA_UltRvDc(aEspecificacao[nRot,_ENS,nOper,nEns,nPosDoc],dDataBase,.F.,.F.)
						EndIF
						
						If (cAlias)->(!Eof())
							RecLock(cAlias,.F.)
						Else
							RecLock(cAlias,.T.)
							(cAlias)->&(cAlias+"_FILIAL") := xFilial(cAlias)
							(cAlias)->&(cAlias+"_PRODUT") := cProduto
							(cAlias)->&(cAlias+"_REVI")   := cRevisao
							(cAlias)->&(cAlias+"_CODREC") := cRoteiro
							(cAlias)->&(cAlias+"_OPERAC") := cOperacao
							(cAlias)->&(cAlias+"_GRUPO")  := cGrupo
							(cAlias)->&(cAlias+"_REVIGR") := cRevGrp  
						EndIf
						
						For nCpo := 1 to Len(aHeaderQP7)
							If aHeaderQP7[nCpo,10] <> "V"
								If !(AllTrim(aHeaderQP7[nCpo,2]) $ cConteudo)
									(cAlias)->(FieldPut(FieldPos(cAlias+SubStr(AllTrim(aHeaderQP7[nCpo,2]),4)),;
									aEspecificacao[nRot,_ENS,nOper,nEns,nCpo]))
								EndIf
							EndIf
						Next nCpo  
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Alteração ececutada para  corrigir problemas  na  integridade - FNC 003128  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(aEspecificacao[nRot,_ENS,nOper,nEns,nPosDoc])
				    	    (cAlias)->&(cAlias+"_RVDOC")  := cRvDoc
						EndIF
						  
						MsUnLock()
						FkCommit()
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Calcula e atualiza o LIE e LSE							     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cAlias == "QP7"
							                
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Efetua e Atualiza o Calculo em polegadas					 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cVlrLIE := ""
							cVlrLSE := ""
							nLIE    := 0
							nLSE    := 0
							If At(":",AllTrim(QP7->QP7_NOMINA)) > 0
								If QP7_MINMAX $ "1.2"   //Minimo ou Minimo e Maximo
									cVlrLIE := CalcHora(aEspecificacao[nRot,_ENS,nOper,nEns,nPosNom],aEspecificacao[nRot,_ENS,nOper,nEns,nPosAFI],"I")
								EndIf
								If QP7_MINMAX $ "1.3"   //Maximo ou Minimo e Maximo
									cVlrLSE := CalcHora(aEspecificacao[nRot,_ENS,nOper,nEns,nPosNom],aEspecificacao[nRot,_ENS,nOper,nEns,nPosAFS],"S")
								EndIF
							ElseIf At('i',AllTrim(QP7->QP7_NOMINA)) > 0
								If QP7_MINMAX $ "1.2"   //Minimo ou Minimo e Maximo
									cVlrLIE := qCalPol({aEspecificacao[nRot,_ENS,nOper,nEns,nPosNom],aEspecificacao[nRot,_ENS,nOper,nEns,nPosAFI]},1,QP7->QP7_LIE)
								EndIF
								If QP7_MINMAX $ "1.3"   //Maximo ou Minimo e Maximo
									cVlrLSE := qCalPol({aEspecificacao[nRot,_ENS,nOper,nEns,nPosNom],aEspecificacao[nRot,_ENS,nOper,nEns,nPosAFS]},1,QP7->QP7_LSE)
								EndIf
							Else
								If QP7_MINMAX $ "1.2"   //Minimo ou Minimo e Maximo
									nLIE    := SuperVal(aEspecificacao[nRot,_ENS,nOper,nEns,nPosNom])+SuperVal(aEspecificacao[nRot,_ENS,nOper,nEns,nPosAFI])
								EndIF
								If QP7_MINMAX $ "1.3"   //Maximo ou Minimo e Maximo
									nLSE    := SuperVal(aEspecificacao[nRot,_ENS,nOper,nEns,nPosNom])+SuperVal(aEspecificacao[nRot,_ENS,nOper,nEns,nPosAFS])
								EndIf
								If cPaisLoc <> "MEX"
								    nDec    := If(","$AllTrim(QP7->QP7_NOMINA),Len(AllTrim(QP7->QP7_NOMINA))-At(",",AllTrim(QP7->QP7_NOMINA)),0)
								    cVlrLIE := AllTrim(StrTran(Str(nLIE,TamSX3("QP7_LIE")[1],nDec),".",","))
								    cVlrLSE := AllTrim(StrTran(Str(nLSE,TamSX3("QP7_LSE")[1],nDec),".",","))
								Else
							       nDec     := If("."$AllTrim(QP7->QP7_NOMINA),Len(AllTrim(QP7->QP7_NOMINA))-At(".",AllTrim(QP7->QP7_NOMINA)),0)  	
								   cVlrLIE  := AllTrim(StrTran(Str(nLIE,TamSX3("QP7_LIE")[1],nDec),",","."))
								   cVlrLSE  := AllTrim(StrTran(Str(nLSE,TamSX3("QP7_LSE")[1],nDec),",","."))
							    Endif
							EndIf
							
							RecLock("QP7",.F.)
							QP7->QP7_LIE := cVlrLIE
							QP7->QP7_LSE := cVlrLSE
							MsUnlock()
							
						EndIf
					Else
						If (cAlias)->(!Eof())
							RecLock(cAlias,.F.)
							dbDelete()
							MsUnLock()
						EndIf
						
					EndIf
					
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza a Familia de Instrumentos							 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nIns := 1 to Len(aEspecificacao[nRot,_INS,nOper,nEns])
					
					If !Empty(aEspecificacao[nRot,_INS,nOper,nEns,nIns,nPosInstr])
						
						nPosDelIns := Len(aEspecificacao[nRot,_INS,nOper,nEns,nIns]) //Indica se esta deletado
						
						QQ1->(dbSetOrder(3))
						QQ1->(dbSeek(xFilial("QQ1")+cProduto+cRevisao+cRoteiro+cOperacao+cEnsaio+aEspecificacao[nRot,_INS,nOper,nEns,nIns,nPosInstr]))
						
						If !aEspecificacao[nRot,_INS,nOper,nEns,nIns,nPosDelIns] .And. nOpc <> 5 //Exclusao
							
							If QQ1->(!Eof())
								RecLock("QQ1",.F.)
							Else
								RecLock("QQ1",.T.)
								QQ1->QQ1_FILIAL	:= xFilial("QQ1")
								QQ1->QQ1_PRODUT	:= cProduto
								QQ1->QQ1_REVI	:= cRevisao
								QQ1->QQ1_ROTEIR	:= cRoteiro
								QQ1->QQ1_OPERAC	:= cOperacao
								QQ1->QQ1_ENSAIO	:= cEnsaio
								QQ1->QQ1_INSTR	:= aEspecificacao[nRot,_INS,nOper,nEns,nIns,nPosInstr]
								QQ1->QQ1_GRUPO  := cGrupo
								QQ1->QQ1_REVGRP := cRevGrp
							EndIf
							QQ1->QQ1_DESCR := aEspecificacao[nRot,_INS,nOper,nEns,nIns,nPosDescr]
							MsUnLock()
							
						Else
							If QQ1->(!Eof())
								RecLock("QQ1",.F.)
								dbDelete()
								MsUnLock()
							EndIf
							
						EndIf
						
					EndIf
					
				Next nIns
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza as Nao-Conformidades associadas					 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nNco := 1 to Len(aEspecificacao[nRot,_NCO,nOper,nEns])
					
					If !Empty(aEspecificacao[nRot,_NCO,nOper,nEns,nNco,nPosNc])
						
						nPosDelNco := Len(aEspecificacao[nRot,_NCO,nOper,nEns,nNco]) //Indica se esta deletado
						
						QP9->(dbSetOrder(3))
						QP9->(dbSeek(xFilial("QP9")+cProduto+cRevisao+cRoteiro+cOperacao+cEnsaio+aEspecificacao[nRot,_NCO,nOper,nEns,nNco,nPosNc]))
						
						If !aEspecificacao[nRot,_NCO,nOper,nEns,nNco,nPosDelNco]	 .And. nOpc <> 5 //Exclusao
							If QP9->(!Eof())
								RecLock("QP9",.F.)
							Else
								RecLock("QP9",.T.)
								QP9->QP9_FILIAL	:= xFilial("QP9")
								QP9->QP9_PRODUT	:= cProduto
								QP9->QP9_REVI	:= cRevisao
								QP9->QP9_ROTEIR	:= cRoteiro
								QP9->QP9_OPERAC	:= cOperacao
								QP9->QP9_ENSAIO	:= cEnsaio
								QP9->QP9_NAOCON := aEspecificacao[nRot,_NCO,nOper,nEns,nNco,nPosNc]
								QP9->QP9_GRUPO  := cGrupo
								QP9->QP9_REVIGR := cRevGrp
							EndIf
							QP9->QP9_CLASSE := aEspecificacao[nRot,_NCO,nOper,nEns,nNco,nPosCla]
							MsUnLock()
							
						Else
							If QP9->(!Eof())
								RecLock("QP9",.F.)
								dbDelete()
								MsUnLock()
							EndIf
							
						EndIf
						
					EndIf
					
				Next nNco
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o Plano de Amostragem por Ensaio					 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nPAE := 1 to Len(aEspecificacao[nRot,_PAE,nOper,nEns])
					
					nPosDelPAE := Len(aEspecificacao[nRot,_PAE,nOper,nEns,nPAE]) //Indica se esta deletado
					
					QQH->(dbSetOrder(1))
					QQH->(dbSeek(xFilial("QQH")+cProduto+cRevisao+cRoteiro+cOperacao+cEnsaio))
					
					If !aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosDelPAE] .And. nOpc <> 5 //Exclusao
						
						If !Empty(aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosNQA]) .Or. ;
							( Empty(aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosNQA]) .And. ("TEXTO" $ aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosPlano]) )
							If QQH->(!Eof())
								RecLock("QQH",.F.)
							Else
								RecLock("QQH",.T.)
								QQH->QQH_FILIAL	:= xFilial("QQH")
								QQH->QQH_PRODUT	:= cProduto
								QQH->QQH_REVI	:= cRevisao
								QQH->QQH_CODREC	:= cRoteiro
								QQH->QQH_OPERAC	:= cOperacao
								QQH->QQH_ENSAIO	:= cEnsaio
								QQH->QQH_GRUPO  := cGrupo
								QQH->QQH_REVIGR := cRevGrp
							EndIf
							QQH->QQH_PLANO  := aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosPlano]
							QQH->QQH_NQA    := aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosNQA]
							QQH->QQH_NIVAMO := aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosNivel]
							If QQH->QQH_PLANO == "INTERN"
								QQH->QQH_AMOST := "PI"
							Else
								QQH->QQH_AMOST  := aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosAmo]
							Endif
							If Empty(aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosNQA]) .And. ("TEXTO" $ aEspecificacao[nRot,_PAE,nOper,nEns,nPAE,nPosPlano])
								QP1->(dbSetOrder(1))
								QP1->(dbSeek(xFilial("QP1")+aEspecificacao[nRot,_ENS,nOper,nEns,1]))
								If QP1->QP1_TPCART <> "X" //Mensuraveis
									QQH->QQH_DESCRI := QP7->QP7_DESPLA
								Else //Texto
									QQH->QQH_DESCRI := QP8->QP8_DESPLA
								EndIf
							EndIf	
							
							MsUnLock()
						EndIf
						
					Else
						If QQH->(!Eof())
							RecLock("QQH",.F.)
							dbDelete()
							MsUnLock()
						EndIf
					EndIf
					
				Next nPAE
				
			Next nEns
			
			//Exclusao do roteiro de operações
			If !Empty(aEspecificacao[nRot,_OPE,nOper,nPosOper])
				
				nPosDelOpe := Len(aEspecificacao[nRot,_OPE,nOper]) //Indica se esta deletado
				
				QQK->(dbSetOrder(1))
				QQK->(dbSeek(xFilial("QQK")+cProduto+cRevisao+cRoteiro+aEspecificacao[nRot,_OPE,nOper,nPosOper]))
				
				If aEspecificacao[nRot,_OPE,nOper,nPosDelOpe] .Or. nOpc == 5 //Exclusao
					
					//Verifica se ira excluir tambem a operação da tabela SG2
					If lDelSG2					
						dbSelectArea("SG2")
						dbSetOrder(1)
						If dbSeek(xFilial("SG2")+cProduto+cRoteiro+aEspecificacao[nRot,_OPE,nOper,nPosOper])
							RecLock("SG2",.F.)                                   
							dbDelete()
							MsUnLock()						
						EndIF
					EndIF
		
					If QQK->(!Eof())
						RecLock("QQK",.F.)
						dbDelete()
						MsUnLock()
					EndIf
				EndIF
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizacao da Rastreabilidade								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nRas := 1 to Len(aEspecificacao[nRot,_RAS,nOper])
				
				If !Empty(aEspecificacao[nRot,_RAS,nOper,nRas,nPosRastr])
					
					nPosDelRas := Len(aEspecificacao[nRot,_RAS,nOper,nRas]) //Indica se esta deletado
					
					QQ2->(dbSetorder(1))
					QQ2->(dbSeek(xFilial("QQ2")+cProduto+cRevisao+cRoteiro+cOperacao+aEspecificacao[nRot,_RAS,nOper,nRas,nPosRastr]))
					
					If !aEspecificacao[nRot,_RAS,nOper,nRas,nPosDelRas] .And. nOpc <> 5 //Exclusao
						
						If QQ2->(!Eof())
							RecLock("QQ2",.F.)
						Else
							RecLock("QQ2",.T.)
							QQ2->QQ2_FILIAL := xFilial("QQ2")
							QQ2->QQ2_CODIGO	:= cProduto
							QQ2->QQ2_REVI	:= cRevisao
							QQ2->QQ2_ROTEIR	:= cRoteiro
							QQ2->QQ2_OPERAC	:= cOperacao
							QQ2->QQ2_GRUPO  := cGrupo
							QQ2->QQ2_REVIGR := cRevGrp
						EndIf
						
						For nCpo := 1 to Len(aHeaderQQ2)
							If aHeaderQQ2[nCpo,10] <> "V"
								QQ2->(FieldPut(FieldPos(AllTrim(aHeaderQQ2[nCpo,2])),;
								aEspecificacao[nRot,_RAS,nOper,nRas,nCpo]))
							EndIf
						Next nCpo
						MsUnLock()
						
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ponto de Entrada para exclusao do QQ2 (especifico JNJ)		 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lQP010DEL
							ExecBlock("QP010DEL",.F.,.F.,{cProduto,cRevisao,cRoteiro,.F.})
						Else
							If QQ2->(!Eof())
								RecLock("QQ2",.F.)
								dbDelete()
								MsUnLock()
							EndIf
						EndIf
						
					EndIf
					
				EndIf
				
			Next nRas
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ P.E. para Atualizacao da Especificacao						 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(FunName()) == "QIPA010"
				If lQP010GRV
					ExecBlock("QP010GRV",.F.,.F.,{cProduto,cRevisao,cRoteiro,cOperacao})
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ P.E. para exclusao do QQ2, apos excluir a operacao corrente  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If QQK->(deleted())
				If AllTrim(FunName()) == "QIPA010"
					If lQP010OPE
						ExecBlock("QP010OPE",.F.,.F.,{cProduto,cRoteiro,cOperacao,cRevisao})
					EndIf
				EndIf
			EndIf
			
		Next nOper
		
	EndIf
	
Next nRot
                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao QIP x PCP										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
QAtuMatQIP(cProduto,cRevisao,cRoteiro,"QIP",If(nOpc==5,.T.,.F.),cPrioriR)


RestArea(aAreaAnt)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA012BLOQ ³ Autor ³Cleber L. Souza 		³ Data ³10/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina que bloqueia a especificação evitando o uso.	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA012BLOQ()	    										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA0120													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA012BLOQ()
Local cMsg      := ""
Local nRecQP6   := 0  
Local aArea     := QP6->(GetArea()) 
Local lLib      := .T.
Local cProduto 

If QP6->QP6_SITREV == "1"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vericica se existem especificação vigente.					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRecQP6   := QP6->(Recno())	
	cProduto  := QP6->QP6_PRODUT
	cRev      := QP6->QP6_REVI
	 
    dbSelectArea("QP6")
    dbSetOrder(1)
    If dbSeek(xFilial("QP6")+cProduto+INVERTE(SOMA1(cRev)))
       IF QP6->QP6_DTINI <= dDataBase
       		lLib := .F.
       EndIF
    EndIF
	
	If lLib

		QP6->(dbGoTo(nRecQp6))
		cMsg := STR0023+CHR(13)+CHR(10) //"Esta sendo realizado a Liberação da Especificação do Produto : "
		cMsg += STR0024 + QP6->QP6_PRODUT+CHR(13)+CHR(10) //"Produto : "
		cMsg += STR0025 + QP6->QP6_REVI+CHR(13)+CHR(10) //"Revisao : "
		cMsg += STR0026 + QP6->QP6_DESCPO+CHR(13)+CHR(10) //"Descrição : "
		cMsg += STR0027 //"Deseja confirmar a liberação dessa especificação ?" 
		
		If MsgYesNo(OemToAnsi(cMsg),OemToAnsi(STR0028)) //"Atencao"
			dbSelectArea("QP6")
			RecLock("QP6",.f.)
			QP6->QP6_SITREV := "0"
			MsUnlock()
		EndIF
	Else   
		QP6->(dbGoTo(nRecQp6))
		HELP(" ",1,"A010BLOQ")
    EndIF

Else
	
	cMsg := STR0029+CHR(13)+CHR(10) //"Esta sendo realizado o Bloqueio da Especificação do Produto : "
	cMsg += STR0024 + QP6->QP6_PRODUT+CHR(13)+CHR(10) //"Produto : "
	cMsg += STR0025 + QP6->QP6_REVI+CHR(13)+CHR(10) //"Revisao : "
	cMsg += STR0026 + QP6->QP6_DESCPO+CHR(13)+CHR(10) //"Descrição : "
	cMsg += STR0030 //"Deseja confirmar o bloqueio dessa especificação ?"
	
	If MsgYesNo(OemToAnsi(cMsg),OemToAnsi(STR0028)) //"Atencao"
		dbSelectArea("QP6")
		RecLock("QP6",.f.)
		QP6->QP6_SITREV := "1"
		MsUnlock()
	EndIf
	
EndIF 

RestArea(aArea)
          
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QPA012Dup ³ Autor ³Paulo Emidio de Barros³ Data ³28/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a Duplicacao da Especificacao do Produto.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA010Dup()											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ 														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA012Dup(cAlias,nReg,nOpc)

	Local aArea    := GetArea()
	Local aAreaQP6 := QP6->(GetArea())
	Local nOpcA    := Nil

	BEGIN TRANSACTION
		If QPA012Dupl(cAlias,nReg,nOpc)
			Pergunte("QPA10D", .F.)
			PergQPA10D()
			QP6->(DbSetOrder(2))
			If QP6->(DbSeek(xFilial("QP6") + MV_PAR01 + MV_PAR02))
				nOpcA := QPA012Atu("QP6",QP6->(Recno()),4)
				If nOpcA == NIL .OR. nOpcA != 1
					DisarmTransaction()
				EndIf
			Else
				DisarmTransaction()
			Endif
		Endif
	END TRANSACTION

	RestArea(aAreaQP6)
	RestArea(aArea)

Return(NIL)      

/*/{Protheus.doc} QPA012Dupl 
Realiza a Duplicação da Especificação de Produtos
@author brunno.costa
@since 03/03/2022
@version 1.0
@param 01 - cAlias , caracter, alias do browser
@param 02 - nReg   , número  , recno do registro posicionado no browser
@param 03 - nOpc   , número  , opção escolhida no browser conforme MenuDef()
/*/
Static Function QPA012Dupl(cAlias,nReg,nOpc)
	Local aAreaAnt := GetArea()
	Local cPerg    := "QPA10D"
	Local cPerg2   := "QPA10E"
	Local cProdOri := " "
	Local cRevOri  := " "
	Local lRetorno := .T.

	Private dVigRev   := dDataBase                   
	Private cDescIn   := ""
	Private cDescEs   := ""
	Private lPrimeira := .F.
	Private cProdPosi := QP6->QP6_PRODUT

	If QPA012TDup()
		//Salva a Revisao da Especificacao do Produto a ser duplicado
		cProdOri := QP6->QP6_PRODUT
		cRevOri  := QP6->QP6_REVI
		cDescIn  := QP6->QP6_DESCIN
		cDescEs  := QP6->QP6_DESCES   
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ QPA10D - Variaveis utilizadas para parametros					³
		//³ mv_par01				// Produto Destino    					³
		//³ mv_par02				// Revisao Destino 						³
		//³ mv_par03				// Roteiro De                           ³
		//³ mv_par04				// Roteiro Ate                          ³
		//³ mv_par05				// Origem da Descricao                  ³
		//³ mv_par06				// Descricao do Produto Destino         ³
		//³ mv_par07				// Roteiro Primario                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( Pergunte(cPerg,.T.) )
			PergQPA10D()
					
			If Empty(sMvPar07)
				cRotPrim := mv_par03
			Else
				cRotPrim := sMvPar07		
			EndIf
				
			If !SB1PrBlq(QP6->QP6_PRODUT) // Verifica se o produto esta bloqueado
				lRetorno := .F.
				//MSGALERT("O produto se encontra bloqueado, nao podera ser feita a duplicacao")
				Return
			Endif
			
			//Realiza a Duplicacao da Especificacao do Produto
			lRetorno := QIPDupEsp(cProdOri,cRevOri,mv_par03,mv_par01,mv_par02,mv_par04,QP012Verif(sMvPar05)," "," ",.T., cRotPrim, cPrioriR,,,cDescIn,cDescEs) 	
			
		Else
			lRetorno := .F.
		EndIf
	Else 
		//Salva a Revisao da Especificacao do Produto a ser duplicado
		cProdOri := QP6->QP6_PRODUT
		cRevOri  := QP6->QP6_REVI   

		If ( Pergunte(cPerg2,.T.) )
			QIPDupEns(cProdOri,; // Produto
			          cRevOri,;  // Revisao
			          mv_par01,; // Roteiro Base
			          mv_par02,; // Operacao Base
			          mv_par03,; // Ensaio Base de 
			          mv_par04,; // Ensaio Base ate
			          nil)	     //  Exibe  msg de Inconsistencia
		Else
			lRetorno := .F.
		EndIf
	EndIf	
	RestArea(aAreaAnt)
Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A010VPro   ³ Autor ³ Cicero Cruz     	  ³ Data ³ 04/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza descricao do Produto de acordo com a opcao escolhida³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID                               						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP010VPro()  
Local aAreas := {QP6->(GetArea()), SB1->(GetArea())}
Local cDes   := Space(TamSX3("B1_DESC")[1])  
Local lRet   := .T.
DEFAULT lPrimeira := .F.
DEFAULT cProdPosi := QP6->QP6_PRODUT

PergQPM010()

If lPrimeira
	if MV_PAR01 <> QP6->QP6_PRODUT
		MV_PAR03 := QP6->QP6_CODREC
		MV_PAR04 := QP6->QP6_CODREC
	endif
	lPrimeira := .F.
EndIf

If (sMvPar05 == 1)     //Informado pelo Operador
	sMvPar06 := cDes
ElseIf (sMvPar05 == 2) //Produto Origem
	DbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+cProdPosi))
		sMvPar06 := SB1->B1_DESC
	EndIf
ElseIf (sMvPar05 == 3) //Produto Destino
	DbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+MV_PAR01))
		sMvPar06 := SB1->B1_DESC
	Else
		sMvPar06 := cDes
		sMvPar05 := 1
	EndIf
EndIf       

aEval(aAreas, {|x| RestArea(x)})
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A010VPro   ³ Autor ³ Cicero Cruz     	  ³ Data ³ 05/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o roteiro origem e valido                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID                               						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP012VROT(cProd, cRev, cRot, cOper) 
Local lRet   := .T. 
Local aArea  := GetArea() 

Default cProd := QP6->QP6_PRODUT
Default cRev  := QP6->QP6_REVI
Default cRot  := MV_PAR01
Default cOper := MV_PAR02

dbSelectArea("QP7")
dbSetOrder(1)
If !dbSeek(xFilial("QP7")+cProd+cRev+cRot+cOper)
	dbSelectArea("QP8")
	dbSetOrder(1)
	If !dbSeek(xFilial("QP8")+cProd+cRev+cRot+cOper)
		MsgAlert(STR0036)
		lRet:=.F.
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A010VPro   ³ Autor ³ Cicero Cruz     	  ³ Data ³ 04/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza descricao do Produto de acordo com a opcao escolhida³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID                               						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP010VROT()  
Local lRet   := .T.

PergQPM010()

If !Empty(Alltrim(sMvPar07))
	// Formata o codigo do Roteiro
	sMvPar07 := Strzero(val(sMvPar07),2)
	// Consiste se o Roteiro faz parte dos roteiros a serem copiados
	If !(sMvPar07 >= MV_PAR03 .AND. sMvPar07 <= MV_PAR04)
	    sMvPar07 := "  "
	    lRet := .F.  
	    MsgAlert(STR0035)
	EndIf       
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA012LegOp ³ Autor ³Cleber L. Souza 		³ Data ³10/05/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas nas OPs				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QP012Legend()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA012													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA012LegOp() 
Local aLegenda := {}

Aadd(aLegenda,{"BR_VERDE",   OemToAnsi(STR0031)}) //"Revisão Disponivel"  
Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0032)}) //"Revisão Bloqueada"  
Aadd(aLegenda,{"BR_AMARELO", OemToAnsi(STR0033)}) //"Revisão Pendente" 

BrwLegenda(OemtoAnsi(STR0009) ,OemToAnsi(STR0034),aLegenda) //"Status das Operações"
Return(NIL) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ QP012Verif ³ Autor ³ Cleber Souza          ³ Data ³ 25/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica de onde vira a descricao do produto                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA012                                 					    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QP012Verif(nEscolha)  
Local cDes   := Space(TamSX3("B1_DESC")[1])  
DEFAULT cProdPosi := QP6->QP6_PRODUT

If (nEscolha == 1) //Informado pelo Operador
	cDes := sMvPar06

ElseIf (nEscolha == 2) //Produto Origem
	SB1->(dbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+cProdPosi))
		cDes := SB1->B1_DESC
	EndIf
	
ElseIf (nEscolha == 3) //Produto Destino
	SB1->(dbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+MV_PAR01))
		cDes := SB1->B1_DESC
	EndIf

EndIf  

Return(cDes)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPA012TDup³ Autor ³Cicero Odilio Cruz     ³ Data ³02/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Seleciona o Tipo de Duplicacao (Especificacao/Ensaios)	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPA012TDup()												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA012TDup()
Local lOk       := .F.
Local nOpc		:= 0
Local nRadio	:= 1
Local oDlg      := NIL
Local oRadio    := NIL

DEFAULT lPrimeira := .F.

DEFINE MSDIALOG oDlg FROM	35,37 TO 140,300 TITLE OemToAnsi(STR0037) PIXEL	//" Tipo de Duplicacao "

@ 005,005 TO 040,080 OF oDlg PIXEL
@ 013,011 RADIO oRadio VAR nRadio 3D SIZE 050,011 PROMPT OemToAnsi(STR0038), OemToAnsi(STR0039) OF oDlg PIXEL //"Especificacao" ### "Ensaios"

DEFINE SBUTTON FROM 024, 090 TYPE 1 ENABLE OF oDlg Action Eval({||nOpc:=1,oDlg:End()})

ACTIVATE MSDIALOG oDlg Centered         

lOk := If(nRadio==1,.T.,.F.)

If nOpc == 1
	lPrimeira := .T.
EndIf

Return(lOk)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QP012VldEn ³ Autor ³Adalberto mendes Neto ³ Data ³04/09/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida o aCols, campo Formula, quando o ensaio for Mensu-  ³±±
±±³          ³ ravel e Calculado e o campo Nominal, quando o enasio for do³±±
±±³          ³ tipo Mensuravel. Executada no botao OK                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QP012VldEn()	  										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ lRet       									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA012													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP012VldEn(lMsg,lRotMod)

Local lRet 		:= .T.
Local lHelp		:= .F.
Local nForEns 	:= 0 
Local cEnsaio 	:= ""
Local cFormula	:= ""                               
Local nNominal	:= 0
Local lTipo 	:= .F.

Default lMsg := .T. 

For nForEns := 1 to Len(oGetEns:aCols)    
	If !oGetEns:aCols[nForEns,Len(oGetEns:aCols[nForEns])]
		cEnsaio := oGetEns:aCols[nForEns,nPosEns]  
		cFormula:= oGetEns:aCols[nForEns,nPosFor]
		nNominal:= oGetEns:aCols[nForEns,nPosNom]  
		QP1->(dbSetOrder(1))
		QP1->(dbSeek(xFilial("QP1")+cEnsaio)) 
		If QP1->QP1_TIPO == "C"
			lTipo := .T.
		EndIf
		If (lTipo .AND. Empty(cFormula)) .Or. (QP1->QP1_TPCART == "D" .AND. Empty(nNominal))
			lHelp := .T.
		    lRet  := .F.
		    Exit
		Endif
	Endif 
	
	If lRet
		QP1->(dbSetOrder(1))
		QP1->(dbSeek(xFilial("QP1")+oGetEns:aCols[oGetEns:oBrowse:nAt,nPosEns]))
		cCarta 	 := QP1->QP1_CARTA
		cTpCarta := QP1->QP1_TPCART
		nQtdEns  := QP1->QP1_QTDE
		lTipo := .F.
	EndIf   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao dos Ensaios calculados							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QP1->QP1_TIPO == "C"
		lTipo := .T.
	EndIf 
	
	If !oGetEns:aCols[nForEns,Len(oGetEns:aCols[nForEns])] .AND. lTipo
		lRet := QP010ValCalc(lRet, cFormula, lTipo, cTpCarta, nPosEns, cCarta, nQtdEns, lMsg)
	EndIf
	
	lTipo := .F.
Next  

If ValType(lRotMod) == "L"
	lRotMod := lRet
EndIf

If lHelp
	Help(" ",1,"QA_CPOOBR")
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcaao	 ³QPA012ROT  ³ Autor ³ Sergio S. Fuzinaka   ³ Data ³ 27.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se existe o Roteiro de Operacoes para determinada  ³±±
±±³          ³Especificacao do Produto.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPA012Rot()

Local lRet		:= .F.
Local lFound	:= .F.
Local aArea		:= GetArea()
Local aAreaQQK	:= QQK->(GetArea())
Local aAreaSG2

If IntQIP()
	aAreaSG2 := SG2->(GetArea()	)
	dbSelectArea("SG2")
	dbSetOrder(1)
	If dbSeek(xFilial("SG2")+mv_par01+mv_par02)
		lRet	:= .T.
		lFound	:= .T.
	Endif
Endif

If !lFound
	dbSelectArea("QQK")
	dbSetOrder(1)
	If dbSeek(xFilial("QQK")+mv_par01)
		While !Eof() .And. QQK->(QQK_FILIAL+QQK_PRODUT) == xFilial("QQK")+mv_par01
			If QQK->QQK_CODIGO == mv_par02
				lRet	:= .T.
				lFound	:= .T.
				Exit
			Endif
			dbSkip()
		Enddo
	Endif
Endif

If !lFound
	MsgAlert(OemToAnsi(STR0041),Upper(OemToAnsi(STR0028)))		//Produto / Roteiro nao cadastrado
Endif

If IntQIP()
	RestArea( aAreaSG2 )
Endif

RestArea( aAreaQQK )
RestArea( aArea )

Return( lRet )          

/*/{Protheus.doc} PergQPM010 
Proteção Error.log Chamadas Pergunte QPM010 com dicionário imcompatível
@author brunno.costa
@since 28/02/2022
@version 1.0
/*/
Static Function PergQPM010()
	If ValType(mv_par05) == "N"
		sMvPar05 := mv_par05
		sMvPar06 := mv_par06
		sMvPar07 := mv_par07
		sMvPar08 := mv_par08
	Else
		If ValType(mv_par08) == "N"
			sMvPar05 := mv_par08
		Else
			sMvPar05 := 1
		EndIf
		sMvPar06 := mv_par05
		sMvPar07 := mv_par06
		sMvPar08 := mv_par07
	EndIf
Return

/*/{Protheus.doc} PergQPM010 
Proteção Error.log Chamadas Pergunte QPA10D com dicionário imcompatível
@author brunno.costa
@since 28/02/2022
@version 1.0
/*/
Static Function PergQPA10D()
	If ValType(mv_par05) == "N"
		sMvPar05 := mv_par05
		sMvPar06 := mv_par06
		sMvPar07 := mv_par07
	Else
		If ValType(mv_par06) == "N"
			sMvPar05 := mv_par06
		Else
			sMvPar05 := 1
		EndIf
		sMvPar06 := mv_par05
		sMvPar07 := mv_par07
	EndIf
Return

/*/{Protheus.doc} QPA012lOK 
Validação bOk QPA012Atu
@author brunno.costa
@since 03/03/2022
@version 1.0
@param 01 - nOpc , número, valor da opção escolhida no browse da tela, conforme Static Function MenuDef()
@param 02 - nOpcA, número, retorna por referência nOpcA, sendo:
                          1 -> Realiza a atualizacao da Especificacao do Produto;
						  0 -> Cancela a operação
/*/

Static Function QPA012lOK(nOpc, nOpcA)
	
	Local lReturn := .T.

	If nOpc == 2 			
		nOpcA := 0
		oDlg:End()

	ElseIf nOpc == 5

		FolderSave("1234567")
		
		lReturn := .T.

		nOpcA := 1
		oDlg:End()

	Else
		FolderSave("1234567")
		
		If !Obrigatorio(aGets, aTela)
			lReturn := .F.
		EndIf

		If lReturn .AND. (nOpc != 5 .and. (!Empty(oGetRot:aCols[oGetRot:nAT,1]) .or. Len(oGetRot:aCols)!=1))
			lReturn := QP10ROTUOK() .AND. QP012VldEn() .And. QP10ValIns()
		EndIf

		If lReturn					
			nOpcA := 1
			oDlg:End()

		Else
			nOpcA := 0

		EndIf

	EndIf

Return lReturn
