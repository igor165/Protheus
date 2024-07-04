#INCLUDE "COLORS.CH"              
#INCLUDE "FOLDER.CH"        
#INCLUDE "FONT.CH"                                                                                                 
#INCLUDE "QIEA215.CH "
#INCLUDE "TOTVS.CH" 

#DEFINE MAXGETDAD  999

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicoes do Vetor aOBJETOS                 					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#define OBJ_ENS     1  //Ensaios associados ao Laboratorio
#define OBJ_MED     2  //Medicoes associadas ao Ensaio
#define OBJ_NCO     3  //Mao-Conformidades associadas a Medicao
#define OBJ_CRO     4  //Cronica associada a Nao-Conformidade
#define OBJ_INS     5  //Instrumentos associados a Medicao
#define OBJ_PAE     6  //Plano de Amostragem associao ao Ensaio
#define OBJ_LAULAB  7  //Laudo do Laboratorio
#define OBJ_LAUGER  8  //Laudo Geral da Entrada
#define OBJ_SEQ     9  //Sequencia da Medição 
#define OBJ_ESTOQUE 10 //Baixas do CQ 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicoes das colunas no browse que contem os ensaios associa-³
//³	dos a cada Laboratorio.										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#define SEQ    01 //Sequencia do Laboratorio
#define ENSAIO 02 //Ensaio corrente              
#define DESPOR 03 //Descricao do Ensaio Portugues
#define CARTA  04 //Carta
#define LIE    05 //Limite Inferior de Engenharia
#define VLRNOM 06 //Valor Nominal
#define LSE    07 //Limite Superior de Engenharia
#define QTDMED 08 //Quantidade de Medicoes (carta)
#define SKPTST 09 //Situacao do Skip-Teste
#define METODO 11 //Metodo
#define REVDOC 12 //Revisao do Documento 
#define FORMUL 13 //Formula
#define TEXTO  15 //Texto do Ensaio

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os niveis por Laboratorio no vetor aResultados		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#define _LAB 1 //Laboratorio
#define _ENS 2 //Ensaio
#define _PAE 3 //Plano de Amostragem por Ensaio
#define _MED 4 //Medicoes
#define _NCO 5 //Nao-conformidades
#define _CRO 6 //Cronicas
#define _INS 7 //Instrumentos
#define _ANE 8 //Documentos anexos
#define _LAU 9 //Laudo do laboratorio

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os niveis por Laboratorio no vetor aResultados		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#define _LAUGER 1 //Laudo geral da Entrada 
#define _OBSERV 2 //Observacoes da Entrada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o nivel utilizado na Baixas CQ no vetor aResultados   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#define _CQ 1 //Baixas do CQ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicao do aHeader utilizado nas medicoes					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#define HEAD_NCS   1 
#define HEAD_INS   2
#define HEAD_EST   3
#define HEAD_ANEXO 4

Static nLabAtuMem := 1

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QIEA215   ³ Autor ³ Paulo Emidio de Barros³ data ³25/06/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de atualizacao de Resultados					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAQIE													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³STR 	     ³ Ultimo utilizado -> 00149                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paulo Emidio³13/03/02³------³Criacao da funcao Q215MovEst, que realiza ³±±
±±³			   ³        ³------³a Liberacao/Rejeicao do material no CQ.   ³±±
±±³Paulo Emidio³09/04/02³------³Implementacao do MV_QINTQNC que indica a  ³±±
±±³			   ³        ³------³Integracao com o QNC.					  ³±±
±±³Paulo Emidio³06/05/02³META  ³Implementacao do Plano de Amostragem In-  ³±±
±±³			   ³        ³------³terno.									  ³±±
±±³Paulo Emidio³21/08/02³META  ³Implementacao do tratamento para Ensaios  ³±±
±±³			   ³        ³------³destrutivos.							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
Local   aRotAdic := {}
Private aRotina  := {{OemToAnsi(STR0001), "AxPesqui",   0, 1,,.F.},; //"Pesquisar" 
                     {OemToAnsi(STR0002), "Q215AtuRes", 0, 2},; //"Visualizar"
                     {OemToAnsi(STR0003), "Q215AtuRes", 0, 4},; //"Resultados" 
                     {OemToAnsi(STR0004), "Q215AtuRes", 0, 5},; //"Exclui"
                     {OemToAnsi(STR0241), "Q215AtuRes", 0, 5},; //"Estorno C.Q."
                     {OemToAnsi(STR0005), "Q215Legend", 0, 5,,.F.}}  //"Legenda"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QE215ROT")
	aRotAdic := ExecBlock("QE215ROT", .F., .F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

Function QIEA215()
Local   cFiltro    := ""
Local	aCoresPE	:= {}

Private lIntQMT     := (GetMv("MV_QINTQMT")=="S")  //Indica se o modulo esta integrado com o Metrologia
Private lInsObr     := (GetMv("MV_QEINSOB")=="S")  //Indica se os instrumentos deverao ser Informados obrigatoriamente
Private lLauDig     := (GetMv("MV_QELAUEN")=="S")  //Define se o Laudo Final da Entrada sera digitado pelo Usuario
Private lMedForEsp  := (GetMv("MV_QERESNC")=="S")  //Define se as Medicoes fora serao consideradas como NC,s
Private lAprConTol  := (GetMv("MV_QAPCTOL")=="S")  //Sugere Laudo com aprovacao condicional se as medicoes estiverem fora dos limites, mas com Tolerancia
Private lAltMed     := (GetMv("MV_QMEDLAU")=="S")  //Indica se as medicoes poderao ser alteradas, quando as mesmas possuirem Laudo cadastrado 
Private lIntQNC     := (GetMv("MV_QINTQNC")=="S")  //Indica se as nao-conformidades serao enviadas para tratamento no SIGAQNC
Private lSugLau     := (GetMv("MV_QSUGLAU")=="S")  //Indica se o Laudo Final e dos Laboratorios serao sugeridos, mesmos quando informados manualmente
Private lInsAmoIni  := GetMV("MV_QAMOINI")          //Indica se os Ensaios com Amostra Inicial serao considerados somente na primeira Entrada a Inspecionar
Private lFilEnt     := GetMv("MV_QFILENT")          //Indica se o filtro das Entradas sera realizado antes da exibicao do browse
Private lEnsMed     := GetMv("MV_QENSMED")          //Indica se os Ensaios sem medicoes informadas serao visualizados
Private lAtuLauGer  := GetMv("MV_QATULGE")          //Indica se o Laudo Geral da Entrada sera realizado a partir das Baixas do CQ
Private nDtaValLot  := GetMv("MV_QVALLOT")          //Indica qual tratamento sera realizado com a Data de Validade do Lote

Private cMatCod     := QA_Usuario()[3]             //Retorna a Matricula do Usuario logado
Private cMatFil     := QA_Usuario()[2]             //Retorna a Filial do Usuario logado
Private cMatNom     := QA_Usuario()[6]             //Retorna o Nome do Usuario logado
Private lAglutinaPA := GetMV("MV_QACUPAM")         //Indica se os Planos de Amostragens serao aglutinados

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pontos de Entrada criados para o cliente Laboris Farmaceutica³
//³ Tratamento do Plano de Amostragem Interno					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lQ215PL1 := ExistBlock('Q215PL1')
Private lQ215PL2 := ExistBlock('Q215PL2') 
Private lQ215PINT := ExistBlock('Q215PINT') 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi(STR0006) //"Cadastro de Resultados"
Private aSitEnt   := {}      
Private lBloqFld  := .F.          
Private aAlter := {}
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

Private l200Auto := .F. // Nao prevista rotina automatica neste ponto 
Private nPosDtVld   := 0  // Variável utilizada pela função A175GRAVA - MATA175

Private lQEPESM := (SuperGetMV('MV_QEPESM', .F., 2) == 1)//Define se PERMITE ensaios sem medições nos Laudos do módulo de Inspeção de Entradas.

Aadd(aSitEnt,{"Q215LdoPen()","BR_CINZA"})    //Entrada sem medicoes cadastradas 
Aadd(aSitEnt,{"Q215EntSMC()","BR_MARROM"})    //Laudo Geral Pedente
Aadd(aSitEnt,{"Q215LdoApr()","BR_VERDE"})    //Laudo Aprovado 
Aadd(aSitEnt,{"Q215LdoRep()","BR_VERMELHO"}) //Laudo Reprovado	
Aadd(aSitEnt,{"Q215LdoUrg()","BR_AMARELO"})  //Liberacao Urgente
Aadd(aSitEnt,{"Q215LdoCon()","BR_LARANJA"})  //Laudo Condicional
Aadd(aSitEnt,{"Q215LdoSME()","BR_AZUL"})     //Laudo sem Movimentacao de Estoque   
Aadd(aSitEnt,{"Q215EntSLL()","BR_BRANCO"})   //Laudo Laboratorio Pendente   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para incluir/alterar itens na legenda do browse	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QE215COR")
	aCoresPE := ExecBlock( "QE215COR",.F.,.F.,{aClone(aSitEnt)})
	
	If ValType(aCoresPE) == "A" .And. !Empty(aCoresPE)
		aSitEnt := aClone(aCoresPE)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 = Considera Entradas    1)-Pendentes 				 ³
//³							         2)-Inspecionadas			 ³
//³                   			     3)-Ambas					 ³
//³ mv_par02 = Laudo Aprovado	     1)-Sim  2)-Nao		     	 ³
//³ mv_par03 = Laudo Reprovado       1)-Sim  2)-Nao		     	 ³
//³ mv_par04 = Liberacao Urgente     1)-Sim  2)-Nao		      	 ³
//³ mv_par05 = Aprovacao condicional 1)-Sim  2)-Nao		    	 ³
//³ mv_par06 = Laudo s? Mov Estoque  1)-Sim  2)-Nao		    	 ³
//³ mv_par07 = Laudo Pendente		 1)-Sim  2)-Nao		    	 ³
//³ mv_par08 = Desliga o Filtro      1)-Sim  2)-Nao		    	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lFilEnt
	Pergunte("QEA215",.F.)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica se as Entradas serao filtradas antes da exibicao do   ³
//³ browse.														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Set Key VK_F12 To Q215Filtro() 
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para ser utilizado antes do Browse          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("Q215BROW")
	cFiltro := ExecBlock( "Q215BROW",.F.,.F.)
	Dbselectarea("QEK")
	Set Filter to  &(cFiltro)   
EndIf

mBrowse(6,1,22,75,"QEK",,"QEK_SITENT",,,, aSitEnt,,, ,, , ,, iif(lFilEnt,Q215Filtro(.F.),"" ), , , ,  )


Set Key VK_F12 To

dbSelectArea("QEK") //desliga o Filtro Ativo
Set Filter to

Return(NIL)                                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³q215AtuRes³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de Atualizacao dos Resultados da Entrada.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ q215AtuRes(EXPC1,EXPN1,EXPN2)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias do arquivo									  ³±±
±±³			 ³ EXPN1 = Numero do registro 								  ³±±
±±³			 ³ EXPN2 = Opcao selecionada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                 
Function Q215AtuRes(cAlias,nReg,nOpc)
Local nOpcA      := 0                         	
Local oDlg       := ""
Local lTudOk       := .T.
Local bOk        := {||nOpcA := 1, Q215SetLab(nFldLab,nFldLab,nFldEns,nFldEns,nMedAtu,nMedAtu,nNcoAtu,nNcoAtu),lTudOk := if(if(!EMPTY(M->QEL_LAUDO),Obrigatorio(aGets, aTela),.T.) .and. If(nFldLab<>nFldLabGer .And. nFldLab<>nFldLibCQ0,IIF(aOBJETOS[OBJ_MED,nFldLab,nFldEns]:TudoOk(),oDlg:End(),.F.), oDlg:End()),.T.,.F.),if(lTudOk,odlg:end(),)}
Local bCancel    := {||nOpcA := 0,oDlg:End()}
Local bLibCQ     := {||If(lIntEst,(Q215SetLab(nFldLibCQ0,),n:=aOBJETOS[OBJ_ESTOQUE]:oBrowse:nAt,If(aOBJETOS[OBJ_ESTOQUE]:TudoOk() .And. Q215EstCQO(nOpc),.T.,.F.)),.T.)}
Local bBlock 
Local bValOk
Local nOpcEnc    := 2      //Visualiza (apenas para a Enchoice das Entradas(QEK))
Local aRetLab    := {}    //Laboratorios utilizados na medicao
Local nX		 := 0        
Local nY         := 0
Local nZ		 := 0
Local aRetAtuRes := {} 
//Variaveis utilizadas na montagem do Folder (Laboratorios)    
Local aTitLab := {}
Local aPagLab := {}    
Local lFatIQP    := .F. //indica se existem fatores do IQP cadastrados
Local lShwPrxTxt := .F. //Exibe o texto da proxima Entrada a inspecionar                   
Local bSitMed    		 //CodeBlock que avalia a situacao das medicoes no ensaio corrente
Local bSitAnexo          //CodeBlock que avalia os documentos anexos 
Local lImpNNC    := .F. //Indica se sera exibida a opcao para Impressao das NNCs
Local lRetNco    := .F. //Retorno da verificacao das nao-conformidades
Local lFilEns    := .T.
Local lQ215Mar   := ExistBlock("QE215MAR") 
//Variaveis utilizadas no Texto da proxima Entrada
Local aTexto   := {}
Local cTitulo  := ""
Local cTitulo2 := ""
Local cEspecie := "" 
Local cCabLib  := ""
Local nTamLin  := 70
Local lConf    := .F.                   
Local cPerg    := " "
Local cTitCQ   := ''
Local nLib 
Local nRej      
Local aAreaQEK 
Local nRecQEK    := QEK->(Recno())
Local aPagLabEns := {}
Local aFolderEns := {}
Local nOpcGD     := If(nOpc==3 .Or. nOpc==4,GD_UPDATE+GD_INSERT+GD_DELETE,0) //Opcao utilizada na NewGetDados
Local aCpos	     := {}
Local nI         := 0 
Local lQe215Res  := Existblock("QE215RES") //P.E. executado no botao Resultados
Local lQe215CPO  := ExistBlock("QE215QEK")
Local nTamEns		:= 0
Local nX
Local aStruQEL
Local lQE215PRM  := ExistBlock("QE215PRM")
Local lPermite
Local nOpcAnt    := nOpc

Private oFolder

//Define a Integracao com Materiais
Private lIntEst := QieIntEst(QEK->QEK_PRODUT,QEK->QEK_TES,QEK->QEK_TIPDOC)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas no MATA175.PRX							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private __IntegraQIE := .T. //Define a Integracao com Materiais no MATA175.PRX

Private lQE215LL    := ExistBlock("QE215LL") //P.E. para alterar o Resultado do Laboratorio
Private lQE215LE    := ExistBlock("QE215LE") //P.E. para alterar o Resultado do Ensaio  
Private lQE215QNC   := ExistBlock("QE215QNC") //P.E. para validar a integração com o QNC
Private lAltObs     := If(GetMv("MV_QEALTOB") <> "1",.F.,.T.) // Altera Observacao de Entrada
Private cChaveD1    := ''
Private cArqCQ      := ''
Private lEstorno    := .F.
Private nAColsIni   := 0
Private lEstNeg     := (GetMV('MV_ESTNEG')=='S')
Private cDirCQ      := AllTrim(GetMV('MV_DIRCQ'))                     
Private aQtd        := {}                                                

Private aHeaderPro  := {}
Private nPosTipo    := 0
Private nPosDesc    := 0
Private nCQPosQtde  := 0
Private nCQPosLDes  := 0
Private nCQPosData  := 0
Private nCQPosEsto  := 0
Private nCQPosMRej  := 0
Private nCQPosObs   := 0
Private nCQPosQtd2  := 0
Private nCQPosNSeq  := 0
Private nPosLocLz   := 0
Private nPosNumSer  := 0
Private nPosService := 0
Private nPosEstrut  := 0
Private nPosDtVld	:= 0

Private cA175Num   := ''
Private cA175Prod  := ''  
Private cA175Loc   := ''
Private cA175OrigL := ''
Private cA175Chave := ''
Private cA175UM    := ''
Private cA175LoteC := ''
Private cA175LotCt := '' 
Private cTexSeq    := ''
Private oGetPot
Private oEncQEK
Private oSay1
Private nPotenc175 := 0
Private nPotencOri := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os Fatores Aprovado, Aprovado Condicional e Reprovado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cFatApr	:= " " //Aprovado
Private cFatRep	:= " " //Reprovado 
Private cFatApC	:= " " //Condicional
Private cFatLU	:= " " //Liberacao urgente

//Variaveis globais	 										 
Private aResultados := {}         	 //armazena os resultados das medicoes
Private aEnsaios    := {}    		 //Ensaios utilizados nas medicoes
Private aOBJETOS   
Private aEnsamoini  := {}  			// Ensaios de Amostra Inicial
Private cOrigent		:= ALLTRIM(QEK->QEK_ORIGEM)

If lIntEst
	aOBJETOS := {{},{},{},{},{},{},{},{},{},{}}  //armazena os objetos utilizados na rotina
Else
	aOBJETOS := {{},{},{},{},{},{},{},{},{}}     //armazena os objetos utilizados na rotina
EndIf	

//variaveis utilizadas na edicao da getdados
Private aHeader[0]
Private aCols
Private nUsado                              
Private N   
Private nOpcX    := nOpc                                             

//variaveis utilizadas na edicao dos dados do Laboratorio
Private aTela    := {}
Private aGets    := {}                                           
Private aSavTela := {}
Private aSavGets := {}
Private aCpoEnc  := {{},{}}
Private aButtons := {}

Private aDesLab    //Nome dos folders dos laboratorios
Private nPosAne    //Nome do Documento/Arquivo anexado ao Ensaio

Private aSavaHeader := {{},{},{},{}} //Salva o aHeader das Nao-conformidades, Instrumentos, Baixas do CQ, Documentos Anexos
Private aSavaCols   := {{},{},{},{}} //Salva o aCols das Nao-conformidades, Instrumentos, Baixas do CQ, Documentos Anexos
Private aSavHeadEns := {}             //Salva o aHeader e aCols definido de acordo com o ensaio selecionado 

Private nFldLab     := 1   //Posicao atual do laboratorio            
Private nFldLabAnt  := 1   //Posicao do ultimo Folder selecionado
Private nFldEns     := 1   //Posicao atual do Ensaio no Laboratorio
Private nFldEnsAnt  := 1   //Posicao anterior do Ensaio no Laboratorio 
Private nMedAtu     := 1   //Posicao da medicao atual
Private nMedAnt     := 1   //Posicao da medicao anterior
Private nNcoAtu     := 1   //Posicao da Nao-Conformidade Atual
Private nNcoAnt     := 1   //Posicao da Nao-Conformidade anterior
Private nFldLabGer  := 0   //Posicao do Laudo Geral da Entrada
Private nFldLibCQ0  := 0   //Posicao da Liberacao/Rejeicao do Materail no CQ
Private lLiberaUrg  := .F. //Define se o Laudo e referente a liberacao urgente
Private aLauAnt     := {}  //Armazena o Laudo e justificativas
Private nQtdLab     := 0   //Numero de laboratorios

Private aCpoUsu     := {}  //Armazena os campos ems uso criados pelo usuarios como aliases iguais a QER,QES,QEQ
Private aCpoQry     := {}  //Armazena os campos a serem utilizados na montagem da Query
Private lQ215CEns		:= ExistBlock('Q215CENS')

Private hOk := LoadBitmap(GetResources(),"PMSTASK4")  //Aprovado
Private hNo := LoadBitmap(GetResources(),"PMSTASK1")  //Reprovado 
Private hPd := LoadBitmap(GetResources(),"PMSTASK2")  //Pendente 
Private hVz := LoadBitMap(GetResources(),"PMSTASK3")  //Nao utilizado

//Define as coordenadas da Tela
Private aPosObj	 := {}
Private aObjects := {}
Private aSize	 := {}
Private aInfo	 := {}

Private cCronica := Space(300)

If  (TamSx3("QEK_NTFISC")[1]+TamSx3("QEK_SERINF")[1]+TamSx3("QEK_ITEMNF")[1] > TamSx3("QEL_NISERI")[1] .OR.;
	TamSx3("QEK_NTFISC")[1]+TamSx3("QEK_SERINF")[1]+TamSx3("QEK_ITEMNF")[1] > TamSx3("QER_NISERI")[1] ) .AND. nOpc <> 2
	Help(" ",1,"QIENISERI")
	Return Nil
EndIf

Aadd(aObjects,{380,049,.T.,.T.})                 
Aadd(aObjects,{420,167,.T.,.T.})

aSize	:= MsAdvSize()
aInfo	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
aPosObj := MsObjSize(aInfo,aObjects,.T.)

If (nOpc == 3 .Or. nOpc == 4) .And. lQe215Res
	Execblock("QE215RES",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Entrada ja se encontra inspecionada			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QEK->(Eof())
	Help(" ",1,"Q215NAOPEN")  
	Return(NIL)
EndIf        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica na exclusao, se existem medicoes cadastradas, para  ³
//³ Entradas sem Laudos Informados.								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4
	If QEK->QEK_SITENT == "1"
		Help(" ",1,"Q215ENTSME")
		Return(NIL)  
	EndIf  
Else    
	If lIntQNC .and. !QNCMSGERA(STR0240) //"Verificar parametros referentes a integracäo com o QNC (Controle de Nao Conformidades"                                                                                                                                                                         
		Return(NIL)  
	EndIF     
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena os fatores de Aprovacao IQP						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lFatIQP := Q215FatApr()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe Mensagem para a Entrada a ser Inspecionada			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QEK->QEK_SITENT == "1" .And. nOpc == 3
	Q215MsgPrxEnt()
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas no Getdados do QER (Medicoes)			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosDtaMed := 0   //Data da Medicao
Private nPosHorMed := 0   //Hora da Medicao
Private nPosNomEns := 0   //Nome do Ensaiador
Private nPosAmo    := 0   //Amostra
Private nPosCal    := 0 
Private nPosEnsR   := 0   //Codigo do Ensaiador
Private nPosFilMat := 0   //Filial do Usuario   
Private nPosMetodo := 0   //Posicao do Metodo
Private nPosRvDoc  := 0   //Revisao do Documento
Private	nPosRes    := 0   //Resultado da Medicao
Private	nPosMed    := 0   //Medicao
Private cCarta     := " " //Carta do Ensaio         
Private cEnsaio    := " " //Ensaio corrente
Private cFamIns    := " " //Familia de Instrumentos		
Private cTipEns    := " " //Tipo do Ensaio

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena o aHeader e aCols para as Nao-conformidades         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := aClone(QP215FillG("QEU", Nil, Nil, Nil, @aCols))
aSavaHeader[HEAD_NCS] := aClone(aHeader)
aSavaCols[HEAD_NCS]   := aClone(aCols)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as posicoes dos campos utilizados nas nao-conformidades³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosNc  := Ascan(aHeader,{|x|Alltrim(x[2])=="QEU_NAOCON"}) //codigo da nao-conformidade
Private nPosCla := Ascan(aHeader,{|x|Alltrim(x[2])=="QEU_CLASSE"}) //codigo da classe da nao-conformidade
Private nPosNum := Ascan(aHeader,{|x|Alltrim(x[2])=="QEU_NUMNC" }) //numero da NNC
Private nPosDNC := Ascan(aHeader,{|x|Alltrim(x[2])=="QEU_DESNCO"}) //descricao da Nao-conformidades
Private nPosDCl := Ascan(aHeader,{|x|Alltrim(x[2])=="QEU_DESCLA"}) //descricao da classe da nao-conformidade

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zero aCols e AHeader										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := {}
aCols   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena o aHeader e aCols para os Instrumentos				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader :=  aClone(QP215FillG("QET", Nil, Nil, Nil, @aCols)) //aClone(APBuildHeader("QET"))
aSavaHeader[HEAD_INS] := aClone(aHeader)
aSavaCols[HEAD_INS]   := aClone(aCols)

Private nPosIns   := Ascan(aHeader,{|x|Alltrim(x[2])=="QET_INSTR" }) //codigo do instrumento 
Private nPosDVA   := Ascan(aHeader,{|x|Alltrim(x[2])=="QET_VALDAF"}) //data de validade do instrumento
Private nPosTip   := Ascan(aHeader,{|x|Alltrim(x[2])=="QET_TIPO"  }) //tipo do instrumento
Private nPosRvIns := Ascan(aHeader,{|x|Alltrim(x[2])=="QET_REVINS"}) //Revisao da Familia
Private nPosRvTip := Ascan(aHeader,{|x|Alltrim(x[2])=="QET_REVTIP"})  //Revisao do Instrumento


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena o aHeader utilizado na Movimentacao do CQ SD7       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIntEst //Somente se houver integracao com Materiais
	aHeader := {}
	aCols   := {}
	
	aHeader := aClone(QP215FillG("SD7", Nil, Nil, Nil, @aCols)) //aClone(APBuildHeader("SD7"))
	aSavaHeader[HEAD_EST] := aClone(aHeader)
EndIf	

aHeader := {}
aCols   := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena o aHeader e aCols para os documentos anexos		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader :=  aClone(QP215FillG("QF7", Nil, Nil, Nil, @aCols)) //aClone(APBuildHeader("QF7"))
aSavaHeader[HEAD_ANEXO] := aClone(aHeader) 
aSavaCols[HEAD_ANEXO]   := aClone(aCols)   

nPosAne := Ascan(aHeader,{|x| Upper(Alltrim(x[2])) == "QF7_ANEXO"}) //Arquivo;Documento Anexo	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zero aCols e AHeader										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := {}
aCols   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o vetor com os campos a serem utilizados na Enchoice LAB³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStruQEL := FWFormStruct(3,'QEL')[3] // Busca os campos usados (X3_USADO) da tabela
For nX := 1 to Len(aStruQEL)
	If cNivel >= GetSx3Cache(aStruQEL[nX,1],'X3_NIVEL')
		Aadd(aCpoEnc[1],AllTrim(aStruQEL[nX,1]))
		Aadd(aCpoEnc[2],GetSx3Cache(aStruQEL[nX,1],'X3_CONTEXT'))
	EndIf 
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as posicoes das variaveis no aCpoEnc                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nPosLauGer := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_LAUDO"})  //posicao do Laudo do Laboratorio/Geral da Entrada
Private nPosQtdLib := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_TAMLOT"}) //posicao da Quantidade Liberada
Private nPosQtdRej := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_QTREJ"})  //posicao da Quantidade Rejeitada
Private nPosDesLau := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_DESLAU"}) //posicao da Descricao do Laudo da Entrada
Private nPosJusLau := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_JUSTLA"}) //posicao da Justificativa do Laudo Final da Entrada
Private nPosDtaLau := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_DTLAUD"}) //posicao da data do Laudo
Private nPosQtdDes := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_QTDEST"}) //posicao da quantidade do Ensaio destrutivo
Private nPosValLot := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_DTVAL"})  //posicao da Validade do Lote

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os vetores com as opcoes no Folder (Laboratorio)		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lFilEns := Q215FilLab(QEK->QEK_PRODUT,QEK->QEK_REVI,@aRetLab,nOpc)

If lQE215PRM
	lPermite := Execblock("QE215PRM",.F.,.F.)
	If !lPermite
		Help(,, "QE215PRM", , STR0274,1,0,,,,,,)
		Return
	EndIF
EndIf

//Se nao existem laboratorios nao monta a Tela de Resultados
If (Len(aRetLab) == 0) .Or. !lFilEns
	Help(" ",1,"Q215NAOLAB") 
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica no estorno se existem Liberacoes-Rejeite no CQ	 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 5
	If !lIntEst
		Help(" ",1,"Q215NAOMOV",,,1) //"Nao existe movimentacao de estoque para esta Entrada."
		Return(NIL)  
	Else	         

		//Impede Estorno caso nao exista quantidade Liberada ou Rejeitada a estornar
		If QtdComp(aQtd[6]) == QtdComp(aQtd[1])
			Help(" ",1,"Q215NSLDCQ",,,1) //"Nao existe saldo de movimentacoes a ser estornado, utilize a opcao no menu: Resultados"
			Return(NIL)
		EndIf        
		
	EndIf
EndIF

Aeval(aRetLab,{|x|Aadd(aTitLab,OemToAnsi(x[1])),Aadd(aPagLab,x[2])})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela principal da Rotina									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],000 To aSize[6],aSize[5] OF GetWndDefault() PIXEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata o registro da Entrada selecionada						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> 2
	RecLock("QEK",.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados da  Entrada a inspecionar								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("QEK")

If lQe215CPO
	aCpos:=Execblock("QE215QEK",.F.,.F.)
	If nOpc == 4
		nOpc :=3
	Endif
	For nI := 1 To Len(aCpos)
		If ValType(aCpos[nI]) == "A"
			If Len(aCpos[nI]) > 1
				aCpos := {}
				Exit
			EndIf
		Endif
	Next
EndIf	

nHeight := oDlg:nHeight

oPnlMain := TPanel():New(0,0,'',oDlg,,,,,,0,nHeight)
oPnlMain:Align := CONTROL_ALIGN_ALLCLIENT

nHeight1 := nHeight * 0.10
oPnlTop := TPanel():New(0,0,'',oPnlMain,,,,,,0,nHeight1)
oPnlTop:Align := CONTROL_ALIGN_TOP

nHeight2 := nHeight * 0.21
oPnlBottom := TPanel():New(0,102,'',oPnlMain,,,,,,0,nHeight2)
oPnlBottom:Align := CONTROL_ALIGN_ALLCLIENT

nHeight3 := nHeight * 0.01
oPnlTotal := TPanel():New(0,101,'',oPnlMain,,,,,,0,nHeight3)
oPnlTotal:Align := CONTROL_ALIGN_BOTTOM

//      1º    2º    3º   4º   5º      6º     7º    8º   9º    10º     11º      12º        13º     14º 15º   16º     17º     18º    19º       20º       21º     22º    23º     24º
 //New(cAlias,nReg,nOpc,aCRA,cLetras,cTexto,aACho,aPos,aCpos,nModelo,nColMens,cMensagem, cTudoOk,oWnd,lF3,lMemoria,lColumn,caTela,lNoFolder,lProperty,aField,aFolder,lCreate,lNoMDIStretch)
oEncQEK:=MsMGet():New("QEK",nReg,Iif(lQe215CPO, nOpc,If(nOpc == 3,4,nOpc)),,,,,{1,1,nHeight1,aSize[6]*0.75},aCpos,3,,,,oPnlTop,,.T.,,,,,,,.T.)
oEncQEK:oBox:Align := CONTROL_ALIGN_TOP

//Define o conteudo das variaveis Inclui e Altera
Private Inclui := .T. 
Private Altera := .T.

//Laudo Geral da Entrada
Aadd(aTitLab,OemToAnsi(STR0009)) //"Laudo Geral"
Aadd(aPagLab,"LAUDO GERAL")                                 

If lIntEst
	//Liberacao/Rejeicao CQ   
	If nOpc==2 //Visualizar
		cTitCQ := OemToAnsi(STR0195) //"Baixas do CQ - Visualizar"	
	Else
		If lEstorno 
			cTitCQ := OemToAnsi(STR0166) //"Baixas do CQ - Estornar"
		Else                                
			cTitCQ := OemToAnsi(STR0167) //"Baixas do CQ - Liberar/Rejeitar"
		EndIf       
	EndIf
	Aadd(aTitLab,cTitCQ)
	Aadd(aPagLab,"LIBERACAO/REJEICAO CQ")          
EndIf	
	
aDesLab := aClone(aPagLab)            		

oFolder := TFolder():New(077,002,aTitLab,aPagLab,oPnlBottom,,,,.T.,.F.,503,219)			
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

For nX := 1 to Len(oFolder:aDialogs)
   DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nX]
Next nX	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria os objetos a serem utilizados nos Ensaios e Laudos 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aeval(Array(nQtdLab),{|x|Aadd(aOBJETOS[OBJ_ENS],NIL),;   //objeto dos Ensaios associados ao Laboratorio
						 Aadd(aOBJETOS[OBJ_MED],NIL),;    //objeto das Medicoes associadas ao Ensaio
						 Aadd(aOBJETOS[OBJ_NCO],NIL),;    //objeto das Mao-Conformidades associadas a Medicao
						 Aadd(aOBJETOS[OBJ_CRO],NIL),;    //objeto da Cronica associada a Nao-Conformidade
						 Aadd(aOBJETOS[OBJ_INS],NIL),;    //objeto dos Instrumentos associados a Medicao
						 Aadd(aOBJETOS[OBJ_PAE],NIL),;    //objeto do Plano de Amostragem associado ao ensaio
						 Aadd(aOBJETOS[OBJ_LAULAB],NIL),; //objeto dos Laudos dos Laboratorios
 						 Aadd(aOBJETOS[OBJ_SEQ],NIL)})    //objeto sequencia das medições
  
//Cria os objetos das getdados para as medicoes para cada ensaio associado ao Laboratorio
Aeval(aOBJETOS[OBJ_MED],{|x,y|aOBJETOS[OBJ_MED,y]:=Afill(Array(Len(aResultados[y,_ENS])),NIL)})

//Laudo Geral da Entrada, cria os objetos utilizados nas variaveis
aOBJETOS[OBJ_LAUGER]:=Afill(Array(2),NIL)

//Definicao dos Folders utilizados nos Laboratorios
aPagLabEns := {}
aFolderEns := {}         

Aadd(aPagLabEns,"MEDICOES")    
Aadd(aPagLabEns,"NAO-CONFORMIDADES")  
Aadd(aPagLabEns,"INSTRUMENTOS")           
Aadd(aPagLabEns,"PLANO DE AMOSTRAGEM")
Aadd(aPagLabEns,"LAUDO DO LABORATORIO")                     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria os Laboratorios e seus respectivos ensaios              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nQtdLab

    //Cria as dimensoes para salvar os vetores aTela e aGets, utilizados na enchoice
	Aadd(aSavTela,{})
	Aadd(aSavGets,{})

	//Cria os elementos de acordo com o Laboratorio selecionado
	Aadd(aEnsaios,{})

	//Associa os ensaios ao Laboratorio corrente na Folder
	Eval({||Q215LabEns(oFolder:aDialogs[nX],nX)})				

    //Associa as Medicoes ao Ensaio corrente
	Aeval(aResultados[nX,_ENS],{|x,y|Q215EnsMed(oFolder:aDialogs[nX],nX,y,nOpcGD)})

	//Cria o Folder para Exibicao dos Planos de Amostragens por Ensaios e dos Laudos referentes aos Laboratorios
	Aadd(aFolderEns,TFolder():New(097,002.5,{OemToAnsi(STR0045), OemToAnsi(STR0047),OemToAnsi(STR0246), OemToAnsi(STR0247) },aPagLabEns,oFolder:aDialogs[nX],,,,.T.,.F.,494.5,155))
    aFolderEns[nX]:Align := CONTROL_ALIGN_ALLCLIENT
    
    For nY := 1 to Len(aFolderEns[nX]:aDialogs)
	   DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF aFolderEns[nX]:aDialogs[nY]
	Next nY	

  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sequencia das medições.			              				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPnlBot3 := TPanel():New(0,0,'',aFolderEns[nX]:aDialogs[1],,,,,,0,010)
	oPnlBot3:Align := CONTROL_ALIGN_ALLCLIENT

	oScrollBox := TScrollBox():New(oPnlBot3, 0, 0, 1, 1, .T.,.T.,.T. )
	oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

	IF SetMDIChild()
    	@ 88,392 SAY oSay1 PROMPT cTexSeq	SIZE 60,10	OF oPnlTotal PIXEL COLOR CLR_BLUE  
    	//@ aSize[7]+71,aSize[5]-570 SAY oSay1 PROMPT cTexSeq  	SIZE 52,10	OF aFolderEns[nX]:aDialogs[ny] PIXEL COLOR CLR_BLUE  
 	Else
 		@ 120,392 SAY oSay1 PROMPT cTexSeq	SIZE 60,10	OF oPnlTotal PIXEL COLOR CLR_BLUE
 		//@ aSize[7]+71,aSize[5]-570 SAY oSay1 PROMPT cTexSeq  	SIZE 52,10	OF aFolderEns[nX]:aDialogs[ny] PIXEL COLOR CLR_BLUE  
 	Endif 
 	aOBJETOS[OBJ_SEQ,nX]:=oSay1 
 	oSay1:Align:= CONTROL_ALIGN_RIGHT 
 	aOBJETOS[OBJ_SEQ,nX]:REFRESH()
 

    //Associa as Nao-conformidades com suas respectivas Cronicas a Medicao corrente
  	Q215MedNco(oScrollBox,nX,1,1,nOpcGD)  

    //Associa as Nao-conformidades com suas respectivas Cronicas a Medicao corrente
	Q215MedIns(aFolderEns[nX]:aDialogs[2],nX,1,1,nOpcGD)
	
	//Associa os Planos de Amostragens aos ensaios selecionados no browse
	Q215PaeEns(aFolderEns[nX]:aDialogs[3],nX,1) 

Next nX             

//Cria as dimensoes para salvar os vetores aTela e aGets, utilizados na enchoice
//do Laudo Geral
Aadd(aSavTela,{})
Aadd(aSavGets,{})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do Laudo Geral da Entrada							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Armazena as variavieis de memoria com o conteudo do Laudo armazenado no
//vetor aResultados
RegToMemory("QEL",.T.)                          
Aeval(aCpoEnc[1],{|x,y|M->&(aCpoEnc[1,y]):=aResultados[nFldLabGer,_LAUGER,y]})

//Edicao do Laudo Geral
Q215LauGer(oFolder:aDialogs[nFldLabGer],nFldLabGer,nReg,nOpc)                              

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Movimentacao do Material no CQ							 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIntEst
	aOBJETOS[OBJ_ESTOQUE] := NIL
	Q215AtuCQ0(oFolder:aDialogs[nFldLibCQ0],nOpc)
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do Laudo do Laboratorios							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := nQtdLab to 1 Step -1    
	//Armazena as variavieis de memoria com o conteudo do Laudo armazenado no
	//vetor aResultados
	RegToMemory("QEL",.T.)
	Aeval(aCpoEnc[1],{|x,y|M->	&(aCpoEnc[1,y]):=aResultados[nX,_LAU,y]})
	
	If lEstorno
		nOpc := 3
	Endif
	
	aTela := {}
	aGets := {}
	aOBJETOS[OBJ_LAULAB,nX] := MsMGet():New("QEL",nReg,nOpc,,,,,{002,002,089,491.5},aCpoEnc[1],3,,,,aFolderEns[nX]:aDialogs[4],,.T.,,,,,,.T.)
	aOBJETOS[OBJ_LAULAB,nX]:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	aSavTela[nX] := aTela
	aSavGets[nX] := aGets         
Next
	
nOpc := nOpcAnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizacao do status dos Ensaios nos Laboratorios			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aEnsaios)

	//Medicoes por ensaios
	For nY := 1 to Len(aEnsaios[nX])   
		If lQe215Le 
			aEnsaios[nX,nY,1] := ExecBlock("QE215LE",.F.,.F.,{nX,nY}) 
    	Else                        	
			aEnsaios[nX,nY,1] := Q215CalLab(.F.,nX,nY)          
		EndIf	
	Next nY                                                    

    //Nao-conformidades associadas as medicoes
	Aeval(aEnsaios[nX],	{|x,y|aEnsaios[nX,y,2] := Q215StaNco(nX,y,aEnsaios[nX,y,1])})

	//Instrumentos associados as medicoes	
	Aeval(aEnsaios[nX],{|x,y|aEnsaios[nX,y,3] := Q215StaIns(nX,y)})
	
	//Documentos anexados aos ensaios	
	Aeval(aEnsaios[nX],{|x,y|aEnsaios[nX,y,4] := Q215StaAne(nX,y)})
	
Next nX

//Realiza a validacao na mudanca de Laboratorios
bBlock := {||If(nOpc<>2,(Help(" ",1,"Q215NAOCQ"),; //"Informe o Laudo Geral para Libera/Rejeitar o material no CQ"
	oFolder:SetOption(nFldLabAnt),oFolder:Refresh()),NIL)}

bValOk := {||If(ExistBlock("Q215ValOk"),ExecBlock("Q215ValOk",.F.,.F.),.t.)}
	
//Navegacao dos Folders referentes aos Laboratorios, Laudo Geral e Baixas do CQ
oFolder:bSetOption:={|nPos|Q215SetLab(nFldLab:=nPos,nFldLabAnt:=oFolder:nOption,;
	nFldEns:=If(nPos<>nFldLabGer.And.nPos<>nFldLibCQ0,aOBJETOS[OBJ_ENS,nPos]:nAt,NIL),;
	nFldEnsAnt:=If(oFolder:nOption<>nFldLabGer.And.oFolder:nOption<>nFldLibCQ0,aOBJETOS[OBJ_ENS,oFolder:nOption]:nAt,NIL),;
	nMedAtu:=If(nPos<>nFldLabGer.And.nPos<>nFldLibCQ0,aOBJETOS[OBJ_MED,nPos,aOBJETOS[OBJ_ENS,nPos]:nAt]:nAt,NIL),;
	nMedAnt:=If(oFolder:nOption<>nFldLabGer.And.oFolder:nOption<>nFldLibCQ0,aOBJETOS[OBJ_MED,oFolder:nOption,aOBJETOS[OBJ_ENS,oFolder:nOption]:nAt]:nAt,NIL),;
	nNcoAtu:=If(nPos<>nFldLabGer.And.nPos<>nFldLibCQ0,aOBJETOS[OBJ_NCO,nPos]:nAt,NIL),;
	nNcoAnt:=If(oFolder:nOption<>nFldLabGer.And.oFolder:nOption<>nFldLibCQ0,aOBJETOS[OBJ_NCO,oFolder:nOption]:nAt,NIL),;
	IIF(nFldLab<>nFldLabGer.And.nFldLab<>nFldLibCQ0,aOBJETOS[OBJ_ENS,nFldLab]:SetFocus(),.T.))}

oFolder:bChange := {||IIf(Empty(aResultados[nFldLabGer,_LAUGER,nPosLauGer]).And.nFldLibCq0==nFldLab.And.lIntEst,Eval(bBlock),.T.)}

//Atualiza o status dos Ensaios vinculados ao Laboratorio
bSitMed := {||If(aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,1]=="A",hOK,;
	If(aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,1]=="R",hNo,hPd))}

//Atualiza o status dos arquivos/documentos anexos ao Ensaio
bSitAnexo := {||If(aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,4]=="S",hOk,hVz)}

nTamEns := Len(aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt])	

//Atualiza o status referentes aos Ensaios no Laboratorio

If lQ215CEns .And. nTamEns >= 25

	Aeval(aOBJETOS[OBJ_ENS],{|x|x:bLine:={||{Eval(bSitMed),;
    aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,2],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,3],;
	Eval(bSitAnexo),;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,5],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,6],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,7],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,8],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,9],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,10],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,11],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,12],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,13],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,14],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,15],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,16],;  
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,17],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,18],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,19],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,20],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,21],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,22],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,23],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,24],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,25]}}})

Elseif lQ215CEns .And. nTamEns >= 24
		Aeval(aOBJETOS[OBJ_ENS],{|x|x:bLine:={||{Eval(bSitMed),;
    aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,2],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,3],;
	Eval(bSitAnexo),;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,5],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,6],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,7],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,8],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,9],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,10],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,11],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,12],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,13],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,14],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,15],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,16],;  
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,17],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,18],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,19],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,20],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,21],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,22],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,23],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,24]}}})

Elseif lQ215CEns .And. nTamEns >= 23
		Aeval(aOBJETOS[OBJ_ENS],{|x|x:bLine:={||{Eval(bSitMed),;
    aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,2],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,3],;
	Eval(bSitAnexo),;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,5],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,6],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,7],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,8],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,9],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,10],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,11],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,12],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,13],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,14],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,15],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,16],;  
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,17],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,18],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,19],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,20],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,21],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,22],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,23]}}})
	
Elseif lQ215CEns .And. nTamEns >= 22
	Aeval(aOBJETOS[OBJ_ENS],{|x|x:bLine:={||{Eval(bSitMed),;
    aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,2],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,3],;
	Eval(bSitAnexo),;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,5],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,6],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,7],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,8],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,9],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,10],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,11],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,12],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,13],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,14],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,15],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,16],;  
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,17],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,18],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,19],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,20],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,21],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,22]}}})

Elseif lQ215CEns .And. nTamEns >= 21

	Aeval(aOBJETOS[OBJ_ENS],{|x|x:bLine:={||{Eval(bSitMed),;
    aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,2],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,3],;
	Eval(bSitAnexo),;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,5],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,6],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,7],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,8],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,9],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,10],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,11],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,12],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,13],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,14],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,15],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,16],;  
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,17],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,18],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,19],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,20],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,21]}}})

Elseif lQ215CEns .And. nTamEns >= 20

	Aeval(aOBJETOS[OBJ_ENS],{|x|x:bLine:={||{Eval(bSitMed),;
    aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,2],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,3],;
	Eval(bSitAnexo),;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,5],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,6],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,7],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,8],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,9],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,10],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,11],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,12],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,13],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,14],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,15],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,16],;  
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,17],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,18],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,19],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,20]}}})

Else

	Aeval(aOBJETOS[OBJ_ENS],{|x|x:bLine:={||{Eval(bSitMed),;
    aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,2],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,3],;
	Eval(bSitAnexo),;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,5],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,6],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,7],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,8],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,9],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,10],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,11],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,12],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,13],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,14],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,15],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,16],;  
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,17],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,18],;
	aEnsaios[nFldLab,aOBJETOS[OBJ_ENS,nFldLab]:nAt,19]}}})
	
Endif	

//Edicao dos dados vinculados ao Ensaio
Aeval(aOBJETOS[OBJ_ENS],{|x|x:bChange := {||Q215EditaEns()}})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os botoes para as rotinas especificas 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If ExistBlock("QE215LUR") // Substitui o Conceito de Liberação Urgente por Outro conceito de acordo com as normas a serem atendidas pelos diversos segmentos que a inspeção de entrada atende.
   aButAux := ExecBlock("QE215LUR",.F.,.F.,{nOpc,aButtons})
   If ValType( aButAux ) == "A"
 	  Aadd(aButtons,aButAux)      
   EndIf
Else
   Aadd(aButtons,{"CARGA",{||(Q215LibUrg(nOpc),IIF(lLiberaUrg,nFldLab:=nFldLabGer,.F.))},STR0073,STR0228}) //"Liberacao Urgente"###"Lib.Urge"
EndIf
Aadd(aButtons,{"NOTE",      {||Q215NaoCon()},STR0074,STR0229})     //"Nao-conformidades reincidentes"###"NCC Rein"
Aadd(aButtons,{"PENDENTE",  {||Q215LegEns()},STR0075,STR0230})     //"Legenda dos Ensaios"###"Leg.Ensa"
Aadd(aButtons,{"PEDIDO",    {||Q215TxtPro()},STR0076,STR0231})     //"Texto do Produto"###"Text.Pro"   
Aadd(aButtons,{"RELATORIO", {||Q215TxtEns()},STR0257,STR0258})     //"Texto do Ensaio"###"Text.Ens"   
Aadd(aButtons,{"HISTORIC",  {||aAreaQEK := QEK->(GetArea()),Q215IFIC(),RestArea(aAreaQEK)},STR0196,STR0232}) //"Imprime a Ficha do Produto Uso"###"Fich.Pro"	 
Aadd(aButtons,{"SDUPROP",{||If(nFldLab==nFldLabGer .Or. nFldLab==nFldLibCQ0,Help(" ",1,"Q215NANEXO"),Q215BotDA(nOpc,nFldEns:=aOBJETOS[OBJ_ENS,nFldLab]:nAt))},OemToAnsi(STR0213),STR0234}) //"Anexar Documento."  ###"Anex.Doc"
Aadd(aButtons,{"BMPVISUAL",   {||If(nFldLab==nFldLabGer .Or. nFldLab==nFldLibCQ0,Help(" ",1,"Q215NAODOC"),QDOView(,aOBJETOS[OBJ_ENS,nFldLab]:aArray[aOBJETOS[OBJ_ENS,nFldLab]:nAT,15],aOBJETOS[OBJ_ENS,nFldLab]:aArray[aOBJETOS[OBJ_ENS,nFldLab]:nAT,16]))},STR0052,STR0233}) //"Visualizar Documento"###"Vis.Doct"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita botao para alterar potencia do lote         		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIntEst .And. PotencLote(QEK->QEK_PRODUT)
	nLib := (aQtd[2]-aQtd[4])
	nRej := (aQtd[3]-aQtd[5])
	If QtdComp(nLib)==QtdComp(0) .And. QtdComp(nRej)==QtdComp(0) 
		Aadd(aButtons,{'DBG12',{||If(nFldLab==nFldLibCQ0,A175Potenc(oGetPot),;
			Help(" ",1,"Q215POTEN"))},; //"Altere a Potencia do Lote na Selecao da Pasta Baixas do CQ"
			OemToAnsi(STR0170),STR0235}) //"Altera Potencia de Lote"###"Alt.Pote"
	EndIf     
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Cronica na inicialização da tela.					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCronica := aResultados[nFldLab,_CRO,nFldEns,nMedAtu,nNcoAtu]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criado Ponto de Entrada para Inclusao de Novo Botao para Marba ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQ215Mar
	Aadd(aButtons,{"BMPINCLUIR",{||ExecBlock("QE215MAR")},"...","..."})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada criado para mudar os botoes da enchoicebar                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QE215BUT")
	aButtons := ExecBlock("QE215BUT",.F.,.F.,{nOpc,aButtons})
EndIf

IF Select("QAA") > 0
	QAA->(DbCloseArea())
EndIf
DbSelectArea("QAA")
QAA->(DbGoTop())

If (nOpc <> 2)             
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons),QE215FLIBU());
		VALID If(nOpcA==0,If(MsgYesNo(STR0010,STR0011),.T.,.F.),Q215LauFin() .And. Eval(bLibCQ) .And. Eval(bValOk) ) //"Confirma Saida" ### "Atencao"###
Else
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons),QE215FLIBU()) 
EndIf	  


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a atualizacao dos dados referentes ao Resultados	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If nOpcA == 1 

	//Verifica se o Texto da proxima Entrada sera exibido para edicao
	If !Empty(aResultados[nFldLabGer,_LAUGER,nPosLauGer]) 
		If !(aResultados[nFldLabGer,_LAUGER,nPosLauGer] $ cFatApr) //Laudo Geral da Entrada
			lShwPrxTxt := .T.
		EndIf                                   
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se as Medicoes, Nao-conformidades e Instrumentos fo-³
	//³ ram digitados corretamente.								     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	For nX := 1 to (nQtdLab)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica as medicoes										 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		For nY := 1 to Len(aResultados[nX,_MED])
			//Carta utilizada no Ensaio corrente		
			cCarta := QA_CartEns(aResultados[nX,_ENS,nY,ENSAIO])
			Aeval(aResultados[nX,_MED,nY],{|x,y|Q215ChkMed(nX,nY,,y,cCarta,1,.T.)})			
		Next nY

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica as nao-conformidades associadas as medicoes	     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		For nY := 1 to Len(aResultados[nX,_NCO])                   
			For nZ := 1 to Len(aResultados[nX,_NCO,nY])
				Aeval(aResultados[nX,_NCO,nY,nZ],{|x,y|lRetNco:=Q215ChkMed(nX,nY,nZ,y,,2,.T.,.T.)})
				
				//Se Houver alguma nao-conformidades nao associada exibe a Tela de Impressao da NNC			    
			    If lRetNco 
			    	lImpNNC := .T.
			    EndIf
			Next nZ
		Next nY

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica os instrumentos utilizados nas Medicoes			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		For nY := 1 to Len(aResultados[nX,_INS])                    
			For nZ := 1 to Len(aResultados[nX,_INS,nY])       
				Aeval(aResultados[nX,_INS,nY,nZ],{|x,y|Q215ChkMed(nX,nY,nZ,y,,3,.T.)})
			Next nZ
		Next nY

	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizacao dos Resultados									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If nOpc == 3 .Or. nOpc == 4 .or. nOpc == 5

		Begin Transaction
		Processa({||Q215GrvAll(nOpc,aCpos)},cCadastro)
	    End Transaction                                 

	    If ExistBlock("Q215FIM")
			ExecBlock("Q215FIM",.F.,.F.,{QEK->QEK_PRODUT,QEK->QEK_REVI,QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_DTENTR,QEK->QEK_LOTE,QEK->QEK_NTFISC,QEK->QEK_SERINF,QEK->QEK_ITEMNF,QEK->QEK_TIPONF,nOpc})
		EndIf                             
		If nOpc == 3	//Atualizacao

		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Seleciona as opcoes a serem executadas na Atualizacao do Re- ³
			//³ sultado:													 ³
			//³ 1) Notificacao de Nao-conformidades							 ³
			//³ 2) Texto da proxima Entrada									 ³
			//³ 3) Etiquetas do Laudo da Entrada							 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			If !Empty(aResultados[nFldLabGer,_LAUGER,nPosLauGer]) //Somente quando o Laudo Final for informado

				//Exibe as opcoes, somente no preenchimento do Laudo Geral	
				aRetAtuRes := Q215SelGrv(lShwPrxTxt,lImpNNC)                   

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³	Realiza a impressao da Notificacao das Nao-Conformidades³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				//Cancela o Filtro para Impressao dos Relatorios
				If aRetAtuRes[1] .Or. aRetAtuRes[2] .Or. aRetAtuRes[3]
					dbSelectArea("QEK")
					Set Filter To      
					dbGoto(nRecQEK)             
				EndIf

				If aRetAtuRes[1]
					If (GetMv("MV_QIMPNNC"))
						If !Existblock("QE215NNC")
							QIER030({QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,DTOC(QEK->QEK_DTENTR),QEK->QEK_LOTE,QEK->QEK_NTFISC,QEK->QEK_SERINF,QEK->QEK_ITEMNF,QEK->QEK_NUMSEQ,QEK->QEK_NNC},"QIEA215")
							//                1      -    2          -    3          -         4           -    5        -     6      -    7          -    8          -     9
						Else
							ExecBlock("QE215NNC",.F.,.F., {QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,DTOC(QEK->QEK_DTENTR),QEK->QEK_LOTE,QEK->QEK_NNC,QEK->QEK_NTFISC,QEK->QEK_SERINF})
						EndIf
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Realiza a edicao do Texto para a proxima Entrada             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aRetAtuRes[2]
					If !(aResultados[nFldLabGer,_LAUGER,nPosLauGer] $ cFatApr)
						aTexto   := {}
						cTitulo  := STR0095 //"Lote"
						cTitulo2 := QEK->QEK_LOTE
						cEspecie := "QIEA210M" 
						cCabLib  := STR0096 //"Texto para a proxima Entrada"
						nTamLin  := 70
						lConf    := .F.

						//Edita o Texto da proxima Entrada
						If (lConf := QA_TEXTO(QEK->QEK_CHAVE,cEspecie,nTamLin,cTitulo,cTitulo2,@aTexto,1,cCabLib))
							QA_GrvTxt(QEK->QEK_CHAVE,cEspecie,1,@aTexto)    
						EndIf
					EndIf           
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Realiza a Impressao das Etiquetas do Laudo					 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aRetAtuRes[3]                                                 
					cPerg := "QIE210"   
					If Pergunte(cPerg,.T.)
						If ExistBlock("QIER270R")
							ExecBlock("QIER270R",.F.,.F.,{"QIEA200",MV_PAR01,MV_PAR02})
						Else
							QIER270("QIEA200",MV_PAR01, MV_PAR02,,,,MV_PAR03,MV_PAR04,MV_PAR05)
						EndIf
					EndIf	
				EndIf     

				Pergunte("QEA215",.F.)

				//Ativa o Filtro novamente, para retorno ao Browse
				If (aRetAtuRes[1] .Or. aRetAtuRes[2] .Or. aRetAtuRes[3]) .AND. mv_par08 == 2
					Q215Filtro(.F.)
				EndIf

			EndIf	
		EndIf

		//Processa os gatilhos	 
		EvalTrigger()                             
	EndIf
	
	// Executa o filtro
	If nOpc <> 2 .AND. mv_par08 == 2
		Q215Filtro(.F.)
	EndIf

Endif

QAA->(DbCloseArea())

//destrava o registro da Entrada 
If nOpc <> 2
	dbSelectArea("QEK") 
	MsUnLock()
EndIf

Return(nOpcA)                           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³q215StaNco³ Autor ³Paulo Emidio de Barros ³ Data ³01/09/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o status das nao-conformidades no ensaio          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215StaNco(EXPN1,EXPN2,EXPC1)				 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Laboratorio corrente					  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio corrente						  ³±±
±±³			 ³ EXPC1 = Resultado da Medicao corrente					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPO1 = Handle com a Legenda da situacao					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215StaNco(nPosLab,nPosEns,cResMed)
Local cStaNco := ""
Local lNaoCon  := .F.                    
Local nX
Local nY 

For nX := 1 to Len(aResultados[nPosLab,_NCO,nPosEns])
	For nY := 1 to Len(aResultados[nPosLab,_NCO,nPosEns,nX])
	    If (lRetNco := Q215ChkMed(nPosLab,nPosEns,nX,nY,,2,.F.,.T.))              
			lNaoCon := If(lNaoCon,lNaoCon,.T.)
		EndIf                                               
	Next nY
Next nX

If cResMed == "R"  //Medicao reprovada
	cStaNco := If(lNaoCon,hOK,hPd)
Else
	cStaNco := If(lNaoCon,hOK,hVz)
EndIf

Return(cStaNco)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³q215StaIns³ Autor ³Paulo Emidio de Barros ³ Data ³01/09/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o status dos Instrumentos no ensaio          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215StaIns(EXPN1,EXPN2)						 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Laboratorio corrente					  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio corrente						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPO1 = Handle com a Legenda da situacao					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215StaIns(nPosLab,nPosEns)
Local lInstru := .F.
Local lRetIns 
Local cStaIns := " " 
Local nX
Local nY

For nX := 1 to Len(aResultados[nPosLab,_INS,nPosEns])
	For nY := 1 to Len(aResultados[nPosLab,_INS,nPosEns,nX])	
	    If (lRetIns := Q215ChkMed(nPosLab,nPosEns,nX,nY,,3,.F.,.T.))              
	    	lInstru := If(lInstru,lInstru,.T.)
	    EndIf                                                   
    Next nY
Next nX

If lIntQMT //Se houver Integracao com o Metrologia
	If lInsObr //Indica se os Instrumentos sao obrigatorios
		cStaIns := If(lInstru,hOK,hPd)
	Else
		cStaIns := If(lInstru,hOK,hVz)
	EndIf
Else
	cStaIns := If(lInstru,hOK,hVz)
EndIf

Return(cStaIns)          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215StaAne³ Autor ³Paulo Emidio de Barros ³ Data ³14/07/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o status dos Documentos Anexos aos Ensaios     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215StaAne(EXPN1,EXPN2)						 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Laboratorio corrente					  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio corrente						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPO1 = Handle com a Legenda da situacao					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215StaAne(nPosLab,nPosEns)
Local cStaAne := " "                
Local nX      := 0

For nX := 1 to Len(aResultados[nPosLab,_ANE,nPosEns])
	If !Empty(aResultados[nPosLab,_ANE,nPosEns,nX,nPosAne]) .And.;
		!aResultados[nPosLab,_ANE,nPosEns,nX,Len(aResultados[nPosLab,_ANE,nPosEns,nX])]
		cStaAne	:= "S"                
		Exit	
	EndIf
Next nX               

Return(cStaAne)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³q215SelGrv³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Seleciona as opcoes na atualizacao dos Resultados		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ q215SelGrv(EXPL1)			 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPL1 = Indica se o Texto da proxima Entrada sera exibido  ³±±
±±³			 ³ EXPL2 = Indica se a Opcao para Impressao das NNCs sera exi-³±±
±±³			 ³ 		   bida para selecao do Usuario						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA1[1] = Notificacao das nao-conformidades				  ³±±
±±³			 ³ EXPA1[2]	= Texto da proxima Entrada						  ³±±
±±³			 ³ EXPA1[3]	= Etiquetas do Laudo							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215SelGrv(lShwPrxTxt,lImpNNC)                   
Local nLin    := 0                                      
Local nTamChk := 029
Local lCheck1 := .F.
Local lCheck2 := .F.
Local lCheck3 := .F.                   
Local oDlg
Local oPanel
Local oBox1
Local oBox2
Local oBox3
Local oSay1
Local oSay2
Local oSay3                                     

DEFINE MSDIALOG oDlg FROM 000,000 TO 150,300 TITLE OemToAnsi(STR0012) Pixel //"Atualizacao dos Resultados"
@ 001,002 to 055,150  PIXEL                                    

If !lShwPrxTxt 
	nTamChk -= 09.7
EndIf 

If !lImpNNC
	nTamChk -= 09.7
EndIf

@ 013,010 MSPANEL oPanel PROMPT "" SIZE 008,nTamChk OF oDlg

If lImpNNC
	@ nLin,001 CHECKBOX oBox1 VAR lCheck1 OF oPanel SIZE 150,11 PIXEL      
	nLin+=10
EndIf                                                                             

If lShwPrxTxt     
	@ nLin,001 CHECKBOX oBox2 VAR lCheck2 OF oPanel SIZE 150,11 PIXEL 
	nLin+=10
EndIf

@ nLin,001 CHECKBOX oBox3 VAR lCheck3 OF oPanel SIZE 150,11 PIXEL 

nLin := 13
If lImpNNC
	@ nLin,027 SAY oSay1 PROMPT OemToAnsi(STR0013) OF oDlg; //"Notificacao de nao-conformidades"
		 SIZE 150,11 PIXEL COLOR CLR_BLUE                                 
	nLin+=10
EndIf	 

If lShwPrxTxt	 
	@ nLin,027 SAY oSay2 PROMPT OemToAnsi(STR0014) OF oDlg; //"Texto da proxima Entrada"
		 SIZE 150,11 PIXEL COLOR CLR_BLUE                                  
	nLin+=10
EndIf  

@ nLin,027 SAY oSay3 PROMPT OemToAnsi(STR0015) OF oDlg; //"Etiqueta do Laudo"
	 SIZE 150,11 PIXEL COLOR CLR_BLUE                

@ 058, 113 BUTTON OemToAnsi(STR0016) SIZE 035,015 OF oDlg PIXEL ACTION oDlg:End() //"Continua"

ACTIVATE DIALOG oDlg CENTER
Return({lCheck1,lCheck2,lCheck3})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215FilLab³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega o vetor aResultados com os dados das medicoes cadas-³±±
±±³			 ³tradas.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215FilLab(EXPC1,EXPC2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Produto								  ³±±
±±³			 ³ EXPC2 = Revisao do Produto								  ³±±
±±³			 ³ EXPA1 = Titulo dos Folders dos Laboratorios			      ³±±
±±³			 ³ EXPN1 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. Ensaios a Inspecionar						  ³±±
±±³			 ³ 		   .F. Nao existem Ensaios a Inspecionar			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA215() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215FilLab(cProduto,cRevisao,aTitPag,nOpc)
Local aAreaAnt   := GetArea()
Local aAreaQE7   := QE7->(GetArea())
Local aAreaQE8   := QE8->(GetArea())
Local aAreaQA2
Local aColsEns   := {} 
Local aColsNCs   := {}
Local aColsIns   := {}
Local aColsAne   := {}
Local aColsAux   := {}
Local aLauGer    := {}
Local nPosChvQER
Local nPosChvNco      
Local nMed       := 0
Local nNco       := 0
Local nIns       := 0
Local aNco       := {}
Local cTitLab    := ""
Local nPosLet    := 0          
Local cTeclas    
Local lInspeciona 
Local cSkpTst 
Local cMetodo    := ''
Local cRevDoc    := ''
Local lFilLab    := .T.
Local nX         :=0     
Local nY         :=0     
Local nExcluidos :=0  
Local aApag      :={}

//Variaveis utilizadas na observacao da Entrada
Local cChave   := ""						
Local nTamLin  := TamSX3("QA2_TEXTO")[1] 
Local cEspecie := "QIEA200 "                
Local aTextos  := {} 					    
Local cObsEnt  := " "

//Variaveis utilizadas para iniciar campos no Laudo do Laboratorio
Local nPosLaudo  := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_LAUDO"})
Local nPosDtEnLa := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_DTENLA"})
Local nPosHrEnLa := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_HRENLA"})
Local nPosTamLot := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_TAMLOT"})
Local nPosDtaLau := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_DTLAUD"})
Local nPosValLau := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_DTVAL"})

Local nPosLab //Posicao do Laboratorio corrente
Local nPosEns //Posicao do Ensaio corrente                           
Local aPAE

Local cFormula
Local xRetorno 
Local cNiseri   := ""         
Local lamoini 	:= .F.

Local aRetEnsAdc := {} 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as teclas de atalhos para:							 ³
//³ Laudo Geral, Baixas do CQ, Nao-Conformidades, Instrumentos,  ³
//³ Plano de Amostragem e Laudo do Laboratorio.					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTeclas := "BLNIPU" 
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³              Nova estrutura do vetor aResultados             ³
//ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ Elemento ³                     Descricao                     ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ [1,1]    ³ Laboratorio							 			 ³
//³          ³                    	                             ³
//³ [1,2]    ³ Ensaio 								 			 ³
//³ [1,2,01] ³ Status Medicoes 						 			 ³
//³ [1,2,02] ³ Status Nao-conformidades				 			 ³
//³ [1,2,03] ³ Status Instrumentos      				 		 ³
//³ [1,2,04] ³ Status dos Documentos Anexos				 		 ³
//³ [1,2,05] ³ QE7_SEQLAB/QE8_SEQLAB					 		 ³
//³ [1,2,06] ³ QE7_ENSAIO/QE8_ENSAIO 				 			 ³
//³ [1,2,07] ³ QE1_DESCPO	 						 			 ³
//³ [1,2,08] ³ QE1_CARTA								 		 ³
//³ [1,2,09] ³ QE7_LIE/" "			 				 			 ³
//³ [1,2,10] ³ QE7_NOMINA/" "						 			 ³
//³ [1,2,11] ³ QE7_LSE/" "							 			 ³
//³ [1,2,12] ³ Quantidade de Medicoes				 			 ³
//³ [1,2,13] ³ Situacao do Skip-Teste 							 ³
//³ [1,2,14] ³ QE1_METODO							 			 ³
//³ [1,2,15] ³ QE7_REVDOC 							 			 ³
//³ [1,2,16] ³ QE1_DESCIN							 			 ³
//³ [1,2,17] ³ QE1_DESCES						     			 ³
//³ [1,2,18] ³ QE8_TEXTO						     			 ³
//³          ³                    	                             ³
//³ [1,3]    ³ Plano de Amostragem associado ao Ensaio			 ³
//³          ³                    	                             ³
//³ [1,4]    ³ Medicoes (Getdados)					 			 ³
//³ [1,5]    ³ Nao-Conformidades (GetDados)			 			 ³
//³ [1,6]    ³ Cronicas 								 		 ³
//³ [1,7]    ³ Instrumentos (GetDados) 				 			 ³ 
//³ [1,8]    ³ Documentos Anexos								 ³
//³ [1,9]    ³ Laudo do laboratorio					 			 ³
//³          ³                    	                             ³
//³ [2,1]    ³ Laudo Geral da Entrada				 			 ³
//³ [2,2]    ³ Observacoes da Entrada				 			 ³
//³          ³                    	                             ³
//³ [3,1]    ³ Liberacao/Rejeicao Material no CQ      			 ³
//³          ³                    	                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o registro na Especificacao do Produto			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QE6")
dbSetOrder(1)                               
MsSeek(xFilial("QE6")+cProduto+Inverte(cRevisao))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ensaios Mensuraveis											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE7->(dbSetOrder(4))
If QE7->(MsSeek(xFilial("QE7")+cProduto+cRevisao))
	While QE7->(!Eof()) .And. (QE7->QE7_FILIAL+QE7->QE7_PRODUT+QE7->QE7_REVI) ==;
		(xFilial("QE7")+cProduto+cRevisao)
		
		If Ascan(aTitPag,{|x| x[2]==Upper(QE7->QE7_LABOR)}) == 0
		
			//Captura as teclas de atalho no Folder
			cTitLab := AllTrim(QE7->QE7_LABOR)
			For nPosLet := 1 to Len(cTitLab)                  
				If At("&",cTitLab) == 0
					If At(SubStr(cTitLab,nPosLet,1),cTeclas) == 0
						cTeclas += SubStr(cTitLab,nPosLet,1)
						cTitLab := Stuff(cTitLab,nPosLet,0,"&")				
					EndIf
				EndIf	
			Next                                   
			Aadd(aTitPag,{cTitLab,Upper(QE7->QE7_LABOR)})
			
		EndIf		                                  

		//Preenche o aResultados com o Laboratorio
		If Ascan(aResultados,{|x|x[_LAB]==QE7->QE7_LABOR}) == 0
			Aadd(aResultados,{QE7->QE7_LABOR,{},{},{},{},{},{},{}})
			
			//Cria as posicoes no vetor que armazena o aHeader de acordo
			//com a carta utilizada no ensaio de cada laboratorio.
			Aadd(aSavHeadEns,{})
		EndIf	

		//Preenche o aResultados com os Ensaios Vinculados ao Laboratorio
		nPosLab := Ascan(aResultados,{|x|x[_LAB]==QE7->QE7_LABOR})
		If (nPosLab > 0)
			lInspeciona := .T.                        
			cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF			
			//Verifica o Skip-Teste definido para o Ensaio
			cSkpTst := QieSkpTst(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QE7->QE7_ENSAIO,QEK->QEK_DTENTR,QEK->QEK_LOTE,,cNiseri,QEK->QEK_TIPONF)

		    //Verifica se o Ensaio possui Amostra Inicial
			If lInsAmoIni
				If QE7->QE7_AM_INS == "1" //Amostra Inicial
					lamoini := QieAmoIni(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QEK->QEK_IDEINV)
					If !lamoini 
						aadd(aensamoini,QE7->QE7_ENSAIO)
					Endif 
					If cSkpTst <> OemToAnsi(STR0162)//"N/A"
						lInspeciona := .F.
					EndIf					
				EndIf     
			EndIf

            If lInspeciona
    			QE1->(dbSetOrder(1))
				If QE1->(MsSeek(xFilial("QE1")+QE7->QE7_ENSAIO))		

					//Verifica se o Metodo associado a especificacao esta preenchido
					If !Empty(QE7->QE7_METODO)
						cMetodo := QE7->QE7_METODO
						cRevDoc := QE7->QE7_REVDOC
					Else 
						cMetodo := QE1->QE1_METODO					
						cRevDoc := ' '	
					EndIf

				    //Formata a Formula do Ensaio, caso a mesma esteja definida para o Ensaio 
					cFormula := StrTran(QE7->QE7_FORMUL,"#","")
					If Empty(cFormula) .And. QE1->QE1_TIPO == "1"
						cFormula := OemToAnsi(STR0150) //"O Ensaio e do Tipo Calculado, mas nao possui formula associada"
					EndIf

					//Armazena os Ensaios por Laboratorio no vetor aResultados                                       
					Aadd(aResultados[nPosLab,_ENS],{QE7->QE7_SEQLAB,QE7->QE7_ENSAIO,QE1->QE1_DESCPO,QE1->QE1_CARTA,If(QE7->QE7_MINMAX=="3","<<<",QE7->QE7_LIE),;
						QE7->QE7_NOMINA,If(QE7->QE7_MINMAX=="2",">>>",QE7->QE7_LSE),'',Q215QtdMed(QE7->QE7_ENSAIO),cSkpTst,cMetodo,QA_ULTRVDC(cMetodo,dDataBase,.f.,.f.),cFormula,QE1->QE1_DESCIN,QE1->QE1_DESCES})

					If lQ215CEns // Conteudo dos campos adicionais
						aRetEnsAdc := Execblock('Q215CENS',.F.,.F.)
						If Valtype(aRetEnsAdc[1]) == 'A'
							For nX:= 1 To Len(aRetEnsAdc[1]) 
								Aadd(aResultados[nPosLab,_ENS,Len(aResultados[nPosLab,_ENS])],aRetEnsAdc[1,nX])
							Next nX
						Endif
					Endif

            		//Cria a dimensao para os anexos associados aos ensaios
					Aadd(aResultados[nPosLab,_ANE],{})

				EndIf	
				
            EndIf     
            
		EndIf

		QE7->(dbSkip())	
		
	EndDo   
	
EndIf	   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ensaios Textos												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE8->(dbSetOrder(4))
If QE8->(MsSeek(xFilial("QE8")+cProduto+cRevisao))
	While QE8->(!Eof()) .And. (QE8->QE8_FILIAL+QE8->QE8_PRODUT+QE8->QE8_REVI) ==;
		(xFilial("QE8")+cProduto+cRevisao)

		If Ascan(aTitPag,{|x| x[2]==Upper(QE8->QE8_LABOR)})==0
		    
		    //Captura as teclas de atalho no Folder
			cTitLab := AllTrim(QE8->QE8_LABOR)
			For nPosLet := 1 to Len(cTitLab)                  
				If At("&",cTitLab) == 0
					If At(SubStr(cTitLab,nPosLet,1),cTeclas) == 0
						cTeclas += SubStr(cTitLab,nPosLet,1)
						cTitLab := Stuff(cTitLab,nPosLet,0,"&")				
					EndIf
				EndIf	
	  		Next        
			Aadd(aTitPag,{cTitLab,Upper(QE8->QE8_LABOR)})
			
		EndIf	       

		//Preenche o aResultados com o Laboratorio
		If Ascan(aResultados,{|x|x[_LAB]==QE8->QE8_LABOR}) == 0
			Aadd(aResultados,{QE8->QE8_LABOR,{},{},{},{},{},{},{}})
			
			//Cria as posicoes no vetor que armazena o aHeader de acordo
			//com a carta utilizada no ensaio de cada laboratorio.
			Aadd(aSavHeadEns,{})    
		EndIf	
		
		//Preenche o aResultados com os Ensaios Vinculados ao Laboratorio
		nPosLab := Ascan(aResultados,{|x|x[_LAB]==QE8->QE8_LABOR})
		If (nPosLab > 0)
			lInspeciona := .T.                        
			cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
			//Verifica o Skip-Teste definido para o Ensaio
			cSkpTst := QieSkpTst(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QE8->QE8_ENSAIO,QEK->QEK_DTENTR,QEK->QEK_LOTE,,cNiseri,QEK->QEK_TIPONF)
		    
		    //Verifica se o Ensaio possui Amostra Inicial
		    If lInsAmoIni
				If QE8->QE8_AM_INS == "1" //Amostra Inicial
					lamoini := QieAmoIni(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QEK->QEK_IDEINV)
					If !lamoini 
						aadd(aensamoini,QE8->QE8_ENSAIO)
					Endif 
					
					If cSkpTst <> OemToAnsi(STR0162)//"N/A"
						lInspeciona := .F.
					EndIf					
				EndIf     
			EndIf
			
            If lInspeciona 
				QE1->(dbSetOrder(1))
				If QE1->(MsSeek(xFilial("QE1")+QE8->QE8_ENSAIO))		
				
					//Verifica se o Metodo associado a especificacao esta preenchido
					If !Empty(QE8->QE8_METODO)
						cMetodo := QE8->QE8_METODO
						cRevDoc := QE8->QE8_REVDOC
					Else 
						cMetodo := QE1->QE1_METODO					
						cRevDoc := ' '	
					EndIf

				    //Armazena os Ensaios por Laboratorio no vetor aResultados                                       
					Aadd(aResultados[nPosLab,_ENS],{QE8->QE8_SEQLAB,QE8->QE8_ENSAIO,QE1->QE1_DESCPO,QE1->QE1_CARTA,;
						OemToAnsi(STR0162),OemToAnsi(STR0162),OemToAnsi(STR0162),QE8->QE8_TEXTO,Q215QtdMed(QE8->QE8_ENSAIO),;
						cSkpTst,cMetodo,QA_ULTRVDC(cMetodo,dDataBase,.f.,.f.),OemToAnsi(STR0250),QE1->QE1_DESCIN,QE1->QE1_DESCES}) //"Nao ha Formula definida"
						
					If lQ215CEns // Conteudo dos campos adicionais
						aRetEnsAdc := Execblock('Q215CENS',.F.,.F.)
						If Valtype(aRetEnsAdc[1]) == 'A'
							For nX:= 1 To Len(aRetEnsAdc[1]) 
								Aadd(aResultados[nPosLab,_ENS,Len(aResultados[nPosLab,_ENS])],aRetEnsAdc[1,nX])
							Next nX
						Endif
					Endif

            		//Cria a dimensao para os anexos associados aos ensaios
					Aadd(aResultados[nPosLab,_ANE],{})

            	EndIf
            	
            EndIf	

		EndIf    
		
		QE8->(dbSkip())
		
    EndDo
    
EndIf  

//Elimina Laboratorios sem ensaios.
For nX:=1 to Len(aResultados)
	If Len(aResultados[nX,_ENS])==0 
		AADD(aApag,nX)	   
	End
Next nX

For nY:=1 to Len(aAPag)
	aDel ( aTitPag, aAPag[nY] ) 
	aDel ( aResultados, aAPag[nY] ) 
	nExcluidos ++
Next nY

aSize ( aResultados, Len ( aResultados ) - nExcluidos )
aSize ( aTitPag    , Len ( aTitPag ) - nExcluidos )  

//Ordena a descricao dos Laboratorios nos Folders
aSort(aTitPag,,,{|x,y|x[2]<y[2]})

//Ordena os Laboratorios 
aSort(aResultados,,,{|x,y|x[1]<y[1]})

//Ordena a Sequencia dos Ensaios por Laboratorio
Aeval(aResultados,{|x,y|aSort(aResultados[y,_ENS],,,{|z,w|z[1]<w[1]})})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Associacao das Medicoes, Nao-conformidades, Cronicas e Ins-  ³
//³ trumentos ao Vetor aResultados, para edicao dos mesmos.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nPosLab := 1 to Len(aResultados)
		
	For nPosEns := 1 to Len(aResultados[nPosLab,_ENS])

		//Cria a posicao para as medicoes referentes ao ensaio		
		Aadd(aResultados[nPosLab,_MED],{})
		
		//Armazena uma copia vazia do aCols no aResultados                 
		aColsEns := Q215aHeadMed(nPosLab,aResultados[nPosLab,_ENS,nPosEns,ENSAIO],aResultados[nPosLab,_ENS,nPosEns,CARTA],aResultados[nPosLab,_ENS,nPosEns,FORMUL])
		aColsAux := aClone(aColsEns)
		
		//Preenche o aCols com as medicoes ja cadastradas
		cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF			
		aColsEns := Q215FilMed(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,cProduto,cRevisao,;
			QEK->QEK_LOTE,QEK->QEK_DTENTR,aResultados[nPosLab,_LAB],aResultados[nPosLab,_ENS,nPosEns,ENSAIO],aResultados[nPosLab,_ENS,nPosEns,CARTA],cNiseri,QEK->QEK_TIPONF,QEK->QEK_NUMSEQ)
		If Len(aColsEns) == 0
			aColsEns  := aClone(aColsAux)
		EndIf				                     
		aResultados[nPosLab,_MED,Len(aResultados[nPosLab,_MED])] := aClone(aColsEns)

	    //Pesquisa a Posicao do campo QER_CHAVE no aHeader vinculado ao Laboratorio+Ensaio
		nPosChvQER := Ascan(aSavHeadEns[nPosLab,Len(aSavHeadEns[nPosLab])],{|x|AllTrim(x[2])=="QER_CHAVE"})                

		//Pesquisa a chave de ligacao do Texto da Nao-conformidade (Cronica)
		nPosChvNco := Ascan(aSavaHeader[HEAD_NCS],{|x|AllTrim(x[2])=="QEU_CHAVE"})                
		
		//Cria a posicao para as nao-conformidades
		Aadd(aResultados[nPosLab,_NCO],Array(Len(aColsEns)))                                                

		//Cria a posicao para as cronicas
		Aadd(aResultados[nPosLab,_CRO],Array(Len(aColsEns)))                                                

		For nMed := 1 to Len(aColsEns)

			//Preenche o aCols com as NC,s vinculadas ao Ensaio
		    aColsNCs := Q215FilCol(aSavaHeader[HEAD_NCS],"QEU",1,aColsEns[nMed,nPosChvQER],"QEU_CODMED",Len(aSavaHeader[HEAD_NCS]))
			If Len(aColsNCs) == 0 
				//Armazena uma copia vazia do aCols no aResultados
				aColsNCs := aClone(aSavaCols[HEAD_NCS])
				aResultados[nPosLab,_NCO,Len(aResultados[nPosLab,_NCO]),nMed] := aClone(aColsNCs)
			Else            
				//Armazena as NCs vinculadas ao Ensaio
				aResultados[nPosLab,_NCO,Len(aResultados[nPosLab,_NCO]),nMed] := aClone(aColsNCs)
			EndIf									
		
			//Armazena o texto da nao-conformidade
			aNco := {}					                          
			For nNco := 1 to Len(aColsNCs)         
				Aadd(aNco,Q215FilTxt(aColsNcs[nNco,nPosChvNco]))
	        Next nNco
			aResultados[nPosLab,_CRO,Len(aResultados[nPosLab,_NCO]),nMed] := aClone(aNco)

		Next nMed  
		
		//Armazena o Plano de Amostragem associado ao Ensaio corrente
		Aadd(aResultados[nPosLab,_PAE],{})
		aResultados[nPosLab,_PAE,Len(aResultados[nPosLab,_PAE])] := Q215FilPAE(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QEK->QEK_REVI,aResultados[nPosLab,_ENS,nPosEns,ENSAIO],QEK->QEK_CHAVE)
		
		//Cria a posicao para os instrumentos 
		Aadd(aResultados[nPosLab,_INS],Array(Len(aColsEns)))                                                
		For nIns := 1 to Len(aColsEns)
			//Preenche o aCols com as NC,s vinculadas ao Ensaio
	        aColsIns := Q215FilCol(aSavaHeader[HEAD_INS],"QET",1,aColsEns[nIns,nPosChvQER],"QET_CODMED",Len(aSavaHeader[HEAD_INS]))
			If Len(aColsIns) == 0 
				//Armazena uma copia vazia do aCols no aResultados
				aResultados[nPosLab,_INS,Len(aResultados[nPosLab,_INS]),nIns] := aClone(aSavaCols[HEAD_INS])
			Else            
				//Armazena as NCs vinculadas ao Ensaio
				aResultados[nPosLab,_INS,Len(aResultados[nPosLab,_INS]),nIns] := aClone(aColsIns)
			EndIf					                      

		Next nIns
		
		//Adiciona os documentos anexos aos ensaios
		if QF7->(FieldPos("QF7_PRODUT")) > 0
			aColsAne := Q215FilCol(aSavaHeader[HEAD_ANEXO],"QF7",2,aResultados[nPosLab,_LAB]+aResultados[nPosLab,_ENS,nPosEns,ENSAIO]+QEK->QEK_PRODUT+QEK->QEK_LOTE,"(QF7_LABOR+QF7_ENSAIO+QF7_PRODUT+QF7_LOTE)",Len(aSavaHeader[HEAD_ANEXO]))			
		Else
			aColsAne := Q215FilCol(aSavaHeader[HEAD_ANEXO],"QF7",1,aResultados[nPosLab,_LAB]+aResultados[nPosLab,_ENS,nPosEns,ENSAIO]+QEK->QEK_LOTE,"(QF7_LABOR+QF7_ENSAIO+QF7_LOTE)",Len(aSavaHeader[HEAD_ANEXO]))
		EndIF	
		aResultados[nPosLab,_ANE,nPosEns] := If(Len(aColsAne)==0,aClone(aSavaCols[HEAD_ANEXO]),aResultados[nPosLab,_ANE,nPosEns] := aClone(aColsAne))

	Next nPosEns
	
Next nPosLab

nQtdLab := Len(aResultados) //Quantidade de Laboratorios

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche os Laudos referentes aos Laboratorios				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aTitPag) 

	//Cria a posicao para os laudos
	Aadd(aResultados[nX],{})
	cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
	aLauLab := Q215FilLau(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,cProduto,QEK->QEK_DTENTR,QEK->QEK_LOTE,aTitPag[nX,2],cNiseri,QEK->QEK_TIPONF,QEK->QEK_NUMSEQ)
	If Len(aLauLab)	== 0         
		//Preenche a posicao do Laudo com as variaveis default, caso nao haja laudo
		aLauLab := Q215FilEnc("QEL",.F.)
                                               
		//Sugere os campos no Laudo do Laboratorio a partir da Entrada
		aLauLab[nPosDtEnLa] := QEK->QEK_DTENTR
		aLauLab[nPosHrEnLa] := QEK->QEK_HRENTR
		aLauLab[nPosTamLot] := QEK->QEK_TAMLOT
		aLauLab[nPosDtaLau] := QEK->QEK_DTENTR
		aLauLab[nPosValLau] := QEK->QEK_DTENTR + QAtuShelf(QEK->QEK_PRODUT,QEK->QEK_REVI) 		
	EndIf
	
	//Cria a posicao para o laudo 
	aResultados[nX,Len(aResultados[nX])] := aClone(aLauLab)
	
	//Armazena o Laudo e a Justificativa anteriores
	Aadd(aLauAnt,{aLauLab[nPosLauGer],aLauLab[nPosJusLau]})

Next nX                       

//Verifica se existem Ensaios a serem inspecionados
Aeval(aResultados,{|x,y|lFilLab:=If(Len(aResultados[y,_ENS])==0,.F.,lFilLab)})

If lFilLab

	//Cria a posicao para o Laudo Geral
	Aadd(aResultados,{})
	cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
	//Caso o Laudo Geral da Entrada esteja preenchido carrega o mesmo para edicao
  	aLauGer := Q215FilLau(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,cProduto,QEK->QEK_DTENTR,QEK->QEK_LOTE,Space(TamSX3("QEL_LABOR")[1]),cNiseri,QEK->QEK_TIPONF,QEK->QEK_NUMSEQ)
	If Len(aLauGer)	== 0         
		
		//Preenche a posicao do Laudo com as variaveis default, caso nao haja laudo
		aLauGer := Q215FilEnc("QEL",.F.)
		
		//Sugere os campos no Laudo Geral da Entrada
		aLauGer[nPosDtEnLa] := QEK->QEK_DTENTR
		aLauGer[nPosHrEnLa] := QEK->QEK_HRENTR
		aLauGer[nPosTamLot] := QEK->QEK_TAMLOT
		aLauGer[nPosDtaLau] :=	QEK->QEK_DTENTR
		aLauGer[nPosValLau] :=	QEK->QEK_DTENTR + QAtuShelf(QEK->QEK_PRODUT,QEK->QEK_REVI) 
	Else                     
		//Verifica se eh liberação Urgente.
		If aLauGer[nPosLaudo] == cFatLU  
			lLiberaUrg := .T.
		EndIF		
	EndIf
	
	//Armazena o Laudo e a Justificativa anteriores
	Aadd(aLauAnt,{aLauGer[nPosLauGer],aLauGer[nPosJusLau]})
	
	//Salva a posicao do Laudo Geral da Entrada
	nFldLabGer := Len(aResultados)
		
	//Armazena o Laudo Geral da Entrada
	Aadd(aResultados[Len(aResultados)],aClone(aLauGer))
	
	//Gera a chave de Ligacao para a Observacao da Entrada
	If Empty(QEK->QEK_CHAVE)
	
	  	aAreaQA2 := GetArea()
   		cChave   := QA_NewChave("QEK",7)
		RestArea(aAreaQA2)
		
		// Grava a chave gerada
		dbSelectArea("QEK")
		RecLock("QEK",.F.)
		QEK->QEK_CHAVE := cChave
		MsUnLock()
	Else
		cChave := QEK->QEK_CHAVE
		//Caso o texto exista, o mesmo e recuperado				    
		cObsEnt := QA_RecTxt(cChave,cEspecie,00,nTamLin,"QA2",aTextos)
		
	EndIf
	
	//Armazena a Observacao da Entrada 
	Aadd(aResultados[Len(aResultados)],cObsEnt)

	If lIntEst
		//Cria a Posicao para a movimentacao de Estoque
		xRetorno := Q215FilCQ0(QEK->QEK_PRODUT,QEK->QEK_CERFOR,nOpc)
		
		If Valtype(xRetorno)=='A'
			Aadd(aResultados,aClone(xRetorno))
		Else
			lFilLab := .F.
		EndIf	
		
		//Salva a posicao da Liberacao/Rejeicado do Material no CQ
		nFldLibCQ0 := Len(aResultados)
	EndIf	

EndIf   

RestArea(aAreaQE7)   
RestArea(aAreaQE8)   
RestArea(aAreaAnt)   

Return(lFilLab)                                       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ Q215FilPAE  ³ Autor ³ Paulo Emidio de Barros ³ Data ³30/06/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o Plano de Amostragem associado a um Ensaio		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215FilPAE(cFornece,cLoja,cProduto,cRevi,cEnsaio,cChave)	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Fornecedor											  ³±±
±±³			 ³ EXPC2 = Loja do Fornecedor									  ³±±
±±³			 ³ EXPC3 = Produto				      							  ³±±
±±³			 ³ EXPC4 = Revisao da Especificacao do Produto					  ³±±
±±³			 ³ EXPC5 = Ensaio 												  ³±±
±±³			 ³ EXPC6 = Chave de Ligacao da Entrada a Inspecionar/Inspecionada ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA1 = Especificacao do Plano de Amostragem 			  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											         	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                              
Static Function Q215FilPAE(cFornece,cLoja,cProduto,cRevi,cEnsaio,cChave)
Local aAreaAnt  := GetArea()
Local aDadosPAE := {}
Local cTab      := If(QEK->QEK_TIPONF $ "BßD","QF6","QF4")
Local cCam      := If(QEK->QEK_TIPONF $ "BßD","QF6->QF6_","QF4->QF4_")    
Local aAmostra  := {}
Local nY        := 0
Local cDescPl	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Estrutura do vetor aDadosPAE								 ³
//³  															 ³
//³  aDadosPAE[01] = QF4_TIPAMO									 ³
//³   		  [02] = QF4_NIVEL									 ³
//³  		  [03] = QF4_PLAMO									 ³
//³ 		  [04] = QF4_NQA									 ³
//³ 		  [05] = QF5_TAMA1									 ³
//³ 		  [06] = QF5_ACEI1									 ³
//³ 		  [07] = QF5_REJEI1									 ³
//³  	      [08] = QF5_TAMA2									 ³
//³ 		  [09] = QF5_ACEI2									 ³
//³ 		  [10] = QF5_REJEI2									 ³
//³ 		  [11] = QF4_DESCRI									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   
//Pesquisa a Revisao do Plano de Amostragem
(cTab)->(dbSetorder(1))
(cTab)->(MsSeek(xFilial(cTab)+cFornece+cLoja+cProduto+cRevi+cEnsaio))
If (cTab)->(!Eof())

	//Verifica se existe o Historico do Plano de Amostragem por Ensaio
	QF5->(dbSetOrder(2)) 
	QF5->(dbSeek(xFilial("QF5")+cEnsaio+cChave))

	aAmostra := Qep_RetAmostra(&(cCam+"TIPAMO"),&(cCam+"PLAMO"),&(cCam+"NIVEL") ,&(cCam+"NQA"),QEK->QEK_TAMAMO,"QEK_TAMAMO",.F.)

	If &(cCam+"TIPAMO") == "3" //Plano Interno
		For nY:=1 to Len(aAmostra)
 			If aAmostra[nY][7] == '0'
				cDescPl := STR0269
			Elseif aAmostra[nY][7] == '1'  
            	cDescPl := STR0270
            Elseif aAmostra[nY][7] == '2'	
            	cDescPl := STR0271
            Elseif aAmostra[nY][7] == '3'
            	cDescPl := STR0272
            Elseif aAmostra[nY][7] == '4'
            	cDescPl := STR0273
            Else
            	cDescPl := STR0269
            Endif
 			AADD(aDadosPAE,{(cTab)->&(cCam+"TIPAMO"),(cTab)->&(cCam+"NIVEL"),(cTab)->&(cCam+"PLAMO"),(cTab)->&(cCam+"NQA"),aAmostra[nY,3],aAmostra[nY,1],;
				aAmostra[nY,2],aAmostra[nY,6],aAmostra[nY,4],aAmostra[nY,5],(cTab)->&(cCam+"DESCRI")})
		Next nY
	Else 
		AADD(aDadosPAE,{(cTab)->&(cCam+"TIPAMO"),(cTab)->&(cCam+"NIVEL"),(cTab)->&(cCam+"PLAMO"),(cTab)->&(cCam+"NQA"),aAmostra[1],aAmostra[2],;
			aAmostra[3],aAmostra[4],aAmostra[5],aAmostra[6],(cTab)->&(cCam+"DESCRI")}) 
	EndIf			
Else    

	//Vetor contendo as espeficicacoes sobre o Plano de Amostragem
	AADD(aDadosPAE,{CriaVar("QF4_TIPAMO"),CriaVar("QF4_NIVEL"),CriaVar("QF4_PLAMO"),CriaVar("QF4_NQA"),;
		CriaVar("QF5_TAMA1"),CriaVar("QF5_ACEI1"),CriaVar("QF5_REJEI1"),CriaVar("QF5_TAMA2"),CriaVar("QF5_ACEI2"),;
		CriaVar("QF5_REJEI2"),CriaVar("QF4_DESCRI")})
EndIf

RestArea(aAreaAnt)
Return(aClone(aDadosPAE))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215FilMed³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche o vetor aResultados com as Medicoes cadastradas   ³±±
±±³			 ³ por Laboratorio.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215FilMed(EXPC1,EXPC2,EXPC3,EXPC4,EXPC5,EXPD1,EXPC6,EXPC7,³±±
±±³			 ³			  EXPC8)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Fornecedor							  	  ³±±
±±³			 ³ EXPC2 = Loja do Fornecedor 								  ³±±
±±³			 ³ EXPC3 = Codigo do Produto								  ³±±
±±³			 ³ EXPC4 = Revisao do Produto								  ³±±
±±³			 ³ EXPC5 = Numero do Lote									  ³±±
±±³			 ³ EXPD1 = Data de entrada									  ³±±
±±³			 ³ EXPC6 = Laboratorio 										  ³±±
±±³			 ³ EXPC7 = Ensaio											  ³±±
±±³			 ³ EXPC8 = Carta											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA1 = Estrutura contendo as medicoes referente ao ensaio ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA215() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215FilMed(cFornec,cLoja,cProduto,cRevi,cLote,dEntrada,cLabor,cEnsaio,cCarta,cNiseri,cTiNF,cNumSeq)
Local aAreaAnt	:= GetArea()                      
Local aAreaQES  := QES->(GetArea())
Local aAreaQEQ  := QEQ->(GetArea())
Local aAreaQER  := QER->(GetArea())
Local nQtdMed   := 0
Local cSeek     := ""
Local cChvMed	:= ""
Local aMed		:= {}
Local aMedicao  := {}
Local cSeekQER  := "" 
Local lQReinsp	:= QieReinsp()

Local cAliasQER := "QER"
Local lQuery    := .F.          
Local cQuery    := ""
Local aStruQER  := {}
Local nPosCpo   := 0


nQtdMed	:= Q215QtdMed(cEnsaio) //Define o numero de medicoes cadastradas
QER->(dbSetOrder(5)) //Criar ordem de pesquisar, possivel ordem nova - DENIS
cSeek   :=   (cProduto+cRevi+cFornec+cLoja+cNiseri+cTiNF+cLote+cLabor+cEnsaio)
cSeekQER := "(QER_FILIAL+QER_PRODUT+QER_REVI+QER_FORNEC+QER_LOJFOR+QER_NISERI+QER_TIPONF+QER_LOTE+QER_LABOR+QER_ENSAIO)"

dbSelectArea("QER")

If MsSeek(xFilial("QER")+cSeek)


	cAliasQER := "QRYQER"           
	aStruQER  := QER->(dbStruct())
	lQuery    := .T.
	cQuery    := "SELECT "
	cQuery    += "QER.QER_FILIAL QER_FILIAL, " 
	cQuery    += "QER.QER_PRODUT QER_PRODUT, "
	cQuery    += "QER.QER_REVI   QER_REVI  , "
	cQuery    += "QER.QER_FORNEC QER_FORNEC, "
	cQuery    += "QER.QER_LOJFOR QER_LOJFOR, "
	cQuery    += "QER.QER_DTENTR QER_DTENTR, " 
	cQuery    += "QER.QER_LOTE   QER_LOTE  , "
	cQuery    += "QER.QER_RASTRE QER_RASTRE, "
	cQuery    += "QER.QER_LABOR  QER_LABOR , "
	cQuery    += "QER.QER_ENSAIO QER_ENSAIO, "
	cQuery    += "QER.QER_DTMEDI QER_DTMEDI, "
	cQuery    += "QER.QER_HRMEDI QER_HRMEDI, "
	cQuery    += "QER.QER_AMOSTR QER_AMOSTR, " 
	cQuery    += "QER.QER_ENSR   QER_ENSR  , "
	cQuery    += "QER.QER_RESULT QER_RESULT, "
	cQuery    += "QER.QER_CHAVE  QER_CHAVE , "
	cQuery    += "QER.QER_NISERI  QER_NISERI, "    
	cQuery    += "QER.QER_TIPONF  QER_TIPONF, "    
	cQuery    += "QER.QER_FILMAT QER_FILMAT, "                                         
  	cQuery    += "QER.QER_METODO QER_METODO, "
	cQuery    += "QER.QER_RVDOC  QER_RVDOC , "      
	cQuery    += "QER.QER_DTINI  QER_DTINI , "      
	cQuery    += "QER.QER_HRINI  QER_HRINI , "      
	cQuery    += "QER.QER_DTFIM  QER_DTFIM , "      
	cQuery    += "QER.QER_HRFIM  QER_HRFIM , "      
	cQuery    += "QER.R_E_C_N_O_ QERRECNO    "                                                                           
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as colunas dos campos criados pelo usuario			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aeval(aCpoQry,{|x|If(SubStr(x,1,3)=="QER",cQuery+=", QER."+x+" "+x+" ",NIL)})		
	
	cQuery    += "FROM "+RetSqlName("QER")+" QER "
	If lQReinsp
		cQuery    += ","+RetSqlName("QEK")+" QEK "
	Endif
	cQuery    += "WHERE QER.QER_FILIAL = '"+xFilial("QER")+"' AND "
	cQuery    += "QER.QER_PRODUT = '"+QER->QER_PRODUT+"' AND "
	cQuery    += "QER.QER_REVI = '"+QER->QER_REVI+"' AND "
	cQuery    += "QER.QER_FORNEC = '"+QER->QER_FORNEC+"' AND "
	cQuery    += "QER.QER_LOJFOR = '"+QER->QER_LOJFOR+"' AND "
	cQuery    += "QER.QER_DTENTR = '"+DTOS(dEntrada)+"' AND "
	cQuery    += "QER.QER_LOTE = '"+QER->QER_LOTE+"' AND "
	cQuery    += "QER.QER_LABOR = '"+QER->QER_LABOR+"' AND "
	cQuery    += "QER.QER_NISERI = '"+QER->QER_NISERI+"' AND "
	cQuery    += "QER.QER_TIPONF = '"+QER->QER_TIPONF+"' AND "
	cQuery    += "QER.QER_ENSAIO = "+FwQtToChr(QER->QER_ENSAIO)

	If lQReinsp
		cQuery    += " AND "
		cQuery    += " QER.QER_FORNEC  = QEK.QEK_FORNEC AND "
		cQuery    += " QER.QER_LOJFOR  = QEK.QEK_LOJFOR AND "
		cQuery    += " QER.QER_PRODUT  = QEK.QEK_PRODUT AND "
		cQuery    += " QER.QER_REVI  = QEK.QEK_REVI AND "
		cQuery    += " QER.QER_DTENTR  = QEK.QEK_DTENTR AND "
		cQuery    += " QER.QER_LOTE    = QEK.QEK_LOTE AND "
		cQuery    += " QER.QER_PRODUT  = QEK.QEK_PRODUT AND "
		cQuery    += " QEK.QEK_NUMSEQ = '"+cNumSeq+"' AND "
		cQuery    += " QEK.D_E_L_E_T_ <> '*' "
	Endif

	cQuery    += " AND "
	cQuery    += " QER.D_E_L_E_T_ <> '*' "
	cQuery    += " ORDER BY "+SqlOrder(QER->(IndexKey()))
	cQuery    := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQER,.F.,.T.)
	For nPosCpo := 1 To Len(aStruQER)
		If aStruQER[nPosCpo,2]<>"C"
			TcSetField(cAliasQER,aStruQER[nPosCpo,1],aStruQER[nPosCpo,2],;
				aStruQER[nPosCpo,3],aStruQER[nPosCpo,4])
		EndIf
	Next nPosCpo
	DbSelectArea(cAliasQER)    

	
	While !Eof() .And. (xFilial("QER")+cSeek) == &cSeekQER .AND. QER_DTENTR == dEntrada

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valores das medicoes 									 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cChvMed := QER_CHAVE
		aMed    := {}			 
		
		If cCarta <> "TXT"
			If cCarta == "P  "
				aMed := Afill(Array(4),0)     
				aMed[4] := " " //somente na quarta posicao
			EndIf
			QES->(dbSetOrder(1))
			QES->(MsSeek(xFilial("QES")+cChvMed))
			While QES->(!Eof()) .And.	(QES->QES_FILIAL+QES->QES_CODMED) ==;
				(xFilial("QES")+cChvMed)
				
				If cCarta <> "P  "
					Aadd(aMed,QES->QES_MEDICA)
				Else
					If QES->QES_INDMED == "A"
						aMed[1] := SuperVal(QES->QES_MEDICA)
					ElseIf QES->QES_INDMED == "N"
						aMed[2] := SuperVal(QES->QES_MEDICA)
						aMed[4] := "S"
					ElseIf QES->QES_INDMED == "P"
						aMed[3] := SuperVal(QES->QES_MEDICA)
					EndIf
				EndIf                    

				QES->(dbSkip())
			EndDo                                 
			If cCarta == "P  "
				If Empty(aMed[4])
					aMed[4] := "N"
					aMed[2] := 0
				Endif
			EndIf
		Else
			QEQ->(dbSetOrder(1))
			If QEQ->(MsSeek(xFilial("QEQ")+cChvMed))
				Aadd(aMed, QEQ->QEQ_MEDICA)
			EndIf				
		EndIf

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o array das medicoes 								 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aMedicao,{})
		Aadd(aMedicao[Len(aMedicao)],QER_DTMEDI)                                 //Data medicao
		Aadd(aMedicao[Len(aMedicao)],QER_HRMEDI)                                 //Hora medicao
		Aadd(aMedicao[Len(aMedicao)],QER_AMOSTR)                                 //Amostra
		Aadd(aMedicao[Len(aMedicao)],QER_FILMAT)                                 //Filial da matricula
		Aadd(aMedicao[Len(aMedicao)],QER_ENSR)                                   //Codigo do ensaiador
		Aadd(aMedicao[Len(aMedicao)],QA_NUSR(QER_FILMAT,QER_ENSR,.F.,"A"))      //Nome do Ensaiador
		
		If cCarta == "TMP" //Campos para tratamento de ensaios do tipo: TEMPO
			Aadd(aMedicao[Len(aMedicao)],QER_DTINI)
			Aadd(aMedicao[Len(aMedicao)],QER_HRINI)
			Aadd(aMedicao[Len(aMedicao)],QER_DTFIM)
			Aadd(aMedicao[Len(aMedicao)],QER_HRFIM)
		EndIf

		Aeval(aMed,{|x|Aadd(aMedicao[Len(aMedicao)],x)})                        //Medicoes
		
		Aadd(aMedicao[Len(aMedicao)],QER_RESULT)                                 //Resultado
		Aadd(aMedicao[Len(aMedicao)],QER_RASTRE)                                 //Rastreamento
		
		Aeval(aCpoUsu,{|x|Aadd(aMedicao[Len(aMedicao)],FieldGet(FieldPos(x)))}) //Campos Criados pelo usuario
		
			Aadd(aMedicao[Len(aMedicao)],QER_METODO)	                              //Metodo
			Aadd(aMedicao[Len(aMedicao)],QER_RVDOC)                                  //Revisao do Documento
	    
		Aadd(aMedicao[Len(aMedicao)],QER_CHAVE)	                                  //Chave de ligacao 

		Aadd(aMedicao[Len(aMedicao)],"QER")
		Aadd(aMedicao[Len(aMedicao)],IIf(lQuery,QERRECNO,QER->(RecNo())))
		Aadd(aMedicao[Len(aMedicao)],.F.)	                                	  //Marca de delecao
		
		dbSkip()
	EndDo
	
	If lQuery
		dbSelectArea(cAliasQER)
		dbCloseArea()
	EndIf
	
EndIf     

RestArea(aAreaQES)
RestArea(aAreaQEQ)
RestArea(aAreaQER)
RestArea(aAreaAnt)

Return(aMedicao)                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q215FilCol ³ Autor ³Paulo Emidio de Barros³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza o preenchimento dos dados no aCols, para as Nao-con³±±
±±³			 ³ formidades e Instrumentos associados ao Ensaio corrente    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215FilCol(EXPA1,EXPC1,EXPN1,EXPC2,EXPC3,EXPN2)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±admin
±±³Parametros³ EXPA1 = aHeader do arquivo a ser criado o aCOLS        	  ³±±
±±³          ³ EXPC1 = Alias corrente        							  ³±±
±±³          ³ EXPN1 = Ordem para pesquisa dos dados         			  ³±±
±±³          ³ EXPC2 = Chave de pesquisa  								  ³±±
±±³          ³ EXPC3 = Campo a ser comparado        					  ³±±
±±³          ³ EXPN2 = nUsado          									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA1 = Estrutura do aCols 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA215                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215FilCol(aHeader,cAlias,nOrder,cSeek,cCampo,nUsado)
Local aColsAux   := {}             
Local nX                 
Local nPosNaoCon := Ascan(aHeader,{|x|AllTrim(x[2])=="QEU_NAOCON"})
Local nPosDesNco := Ascan(aHeader,{|x|AllTrim(x[2])=="QEU_DESNCO"})
Local nPosClasse := Ascan(aHeader,{|x|AllTrim(x[2])=="QEU_CLASSE"}) 
Local nPosDesCla := Ascan(aHeader,{|x|AllTrim(x[2])=="QEU_DESCLA"})
Local nPosValid  := Ascan(aHeader,{|x|Alltrim(x[2])=="QET_VALDAF"}) //data de validade do instrumento
Local nPosTipo   := Ascan(aHeader,{|x|Alltrim(x[2])=="QET_TIPO"  }) //tipo do instrumento
Local nPosInst   := Ascan(aHeader,{|x|Alltrim(x[2])=="QET_INSTR" }) //codigo do instrumento 

Default cSeek := ''

dbSelectArea(cAlias)      
dbSetOrder(nOrder)
dbgotop()
MsSeek(xFilial(cAlias)+cSeek)
While !Eof() .And. xFilial(cAlias) == &(cAlias+"_FILIAL") .And. cSeek == &(cAlias+"->"+cCampo)
    Aadd(aColsAux,Array(nUsado+1))
	For nX := 1 To Len(aHeader)                
  		If (aHeader[nX,10] <> "V")
		    aColsAux[Len(aColsAux),nX] := &(FieldName(FieldPos(AllTrim(aHeader[nX,2]))))
  		ElseIf IsHeadRec(aHeader[nX,2])
			aColsAux[Len(aColsAux),nX] := &(cAlias)->(RecNo())
		ElseIf AllTrim(aHeader[nX,2]) == cAlias+"_ALI_WT"
		   	aColsAux[Len(aColsAux),nX] := cAlias	
		Else    	
  		    aColsAux[Len(aColsAux),nX] := CriaVar(AllTrim(aHeader[nX,2]))
  		EndIf
    Next
    aColsAux[Len(aColsAux),nUsado+1] := .F.
 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenche a descricao dos campos: nao-conformidade e classe³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If cAlias == "QEU"
    	If Upper(__Language) == "SPANISH"
    		aColsAux[Len(aColsAux),nPosDesNco] := Posicione("SAG",1,xFilial("SAG")+aColsAux[Len(aColsAux),nPosNaoCon],"AG_DESCES")
    		aColsAux[Len(aColsAux),nPosDesCla] := Posicione("QEE",1,xFilial("QEE")+aColsAux[Len(aColsAux),nPosClasse],"QEE_DESCES")
    	ElseIf Upper( __LANGUAGE) == "ENGLISH"
 			aColsAux[Len(aColsAux),nPosDesNco] := Posicione("SAG",1,xFilial("SAG")+aColsAux[Len(aColsAux),nPosNaoCon],"AG_DESCIN")
    		aColsAux[Len(aColsAux),nPosDesCla] := Posicione("QEE",1,xFilial("QEE")+aColsAux[Len(aColsAux),nPosClasse],"QEE_DESCIN")		
 		ElseIf Upper(__LANGUAGE) == "PORTUGUESE" 
    		aColsAux[Len(aColsAux),nPosDesNco] := Posicione("SAG",1,xFilial("SAG")+aColsAux[Len(aColsAux),nPosNaoCon],"AG_DESCPO")
    		aColsAux[Len(aColsAux),nPosDesCla] := Posicione("QEE",1,xFilial("QEE")+aColsAux[Len(aColsAux),nPosClasse],"QEE_DESCPO")
    	Endif	
    Elseif cAlias=="QET"
    	aColsAux[Len(aColsAux),nPosValid] := Posicione("QM2",1,xFilial("QM2")+aColsAux[Len(aColsAux),nPosInst],"QM2_VALDAF")
    	aColsAux[Len(aColsAux),nPosTipo]  := Posicione("QM2",1,xFilial("QM2")+aColsAux[Len(aColsAux),nPosInst],"QM2_TIPO")	
    EndIf        
    dbSkip()               
EndDo                    

Return(aClone(aColsAux))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Q215FilTxt ³ Autor ³Paulo Emidio de Barros³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a recuperacao do texto da nao-conformidade associa-³±±
±±³			 ³ da as medicoes para que a mesma seja editada.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215FilTxt(EXPC1)							 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Chave de ligacao do texto da nao-conformidade      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPC2 = Texto da Cronica utilizada nas medicoes			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA215                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215FilTxt(cChvNco)
Local cEspecie := "QIEA210C" // Cronicas das NCs
Local nTamLin  := 70
Local aTextos  := {}
Local cTxtNco  := Space(10)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a recuperacao do texto da nao-conformidade    		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
cTxtNco := QA_RecTxt(cChvNco,cEspecie,00,nTamLin,"QA2",aTextos)

Return(cTxtNco)          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215FilLau³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Devolve o Laudo do Laboratorio corrente.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215FilLau(EXPC1,EXPC2,EXPC3,EXPD1,EXPC4,EXPC5)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Fornecedor								  ³±±
±±³			 ³ EXPC2 = Loja do Fornecedor								  ³±±
±±³			 ³ EXPC3 = Codigo do Produto								  ³±±
±±³			 ³ EXPD1 = Data de Entrada do Laudo							  ³±±
±±³			 ³ EXPC4 = Numero do Lote									  ³±±
±±³			 ³ EXPC5 = Laboratorio corrente			  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA1 = Estrutura contendo os dados do Laudo				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA215() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215FilLau(cFornece,cLoja,cProduto,dEntrada,cLote,cLabor,cNiseri,cTiNF,cNumSeq)
Local aLaudo	:= {}
Local cSeek		:= xFilial("QEL")+cFornece+cLoja+cProduto+cNiseri+cTiNF+Dtos(dEntrada)+cLote+cLabor
Local lQReinsp	:= QieReinsp()

If lQReinsp
	cSeek += cNumSeq
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa o Laudo do laboratorio							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QEL")
QEL->(dbClearFilter())
QEL->(dbGoTop())
QEL->(dbSetOrder(3))      
If QEL->(DbSeek(cSeek))
	aLaudo := Q215FilEnc("QEL",.T.)
EndIf

Return(aLaudo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215LabEns³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta o browse contendo os ensaios vinculados ao Laboratorio³±±
±±³			 ³da Entrada a ser inspecionada.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215LabEns(EXPO1,EXPN1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto da folder corrente 						  ³±±
±±³			 ³ EXPN1 = Posicao do Laboratorio Corrente					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA215() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215LabEns(oFldLabEns,nPosLab)
Local aFields := {}
Local aSizes  := {} 
Local bBlock
Local nX, nW	:= 0
Local nTamEns := 0 
Local aRetEnsAdc := {} 

//Preenche os titulos dos campos			
aFields := {OemToAnsi(STR0031),OemToAnsi(STR0032),OemToAnsi(STR0033),OemToAnsi(STR0248),; //"Med" ### "Ncs" ### "Ins" ### "Anexo"
	STR0035,STR0017,STR0018,STR0019,STR0020,; //"Ensaio" ### "Descricao" ### "Carta" ### "LIE"
	STR0021,STR0022,STR0041,STR0023,STR0024,STR0025,STR0161,STR0171,STR0026,STR0027} //"Nominal" ### "LSE" ### "TEXTO" ### "Medicoes" ### "Skip-Teste" ### "Metodo" ### "Rev DOC" ### "Formula" ### "Desc Ingles " ### "Desc Espanhol" 

If lQ215CEns // Titulo dos campos adicionais
	aRetEnsAdc := Execblock('Q215CENS',.F.,.F.)
	If Valtype(aRetEnsAdc[2]) == 'A'
		For nX:= 1 To Len(aRetEnsAdc[2])
			Aadd(aFields,aRetEnsAdc[2,nX])
		Next nX
	Endif
Endif 

//Preenche o tamanho dos campos								 
aSizes := {10, 10, 10, 20, 15, 30, 100, 25, 30, 30, 30, 100, 30, 30, 45, 30, 150,95, 95}

If lQ215CEns // Tamanho dos campos adicionais
	aRetEnsAdc := Execblock('Q215CENS',.F.,.F.)
	If Valtype(aRetEnsAdc[3]) == 'A'
		For nX:= 1 To Len(aRetEnsAdc[3])
			Aadd(aSizes,aRetEnsAdc[3,nX])
		Next nX
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche os ensaios associados ao Laboratorio 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aeval(aResultados[nPosLab,_ENS],{|x,y|Aadd(aEnsaios[nPosLab],{" "," "," "," ",;
	aResultados[nPosLab,_ENS,y,1], aResultados[nPosLab,_ENS,y,2],;
	aResultados[nPosLab,_ENS,y,3], aResultados[nPosLab,_ENS,y,4],;
	aResultados[nPosLab,_ENS,y,5], aResultados[nPosLab,_ENS,y,6],;
	aResultados[nPosLab,_ENS,y,7], aResultados[nPosLab,_ENS,y,8],;
	aResultados[nPosLab,_ENS,y,9], aResultados[nPosLab,_ENS,y,10],;
	aResultados[nPosLab,_ENS,y,11], aResultados[nPosLab,_ENS,y,12],;
	aResultados[nPosLab,_ENS,y,13], aResultados[nPosLab,_ENS,y,14],;
	aResultados[nPosLab,_ENS,y,15], nTamEns := Len(aResultados[nPosLab,_ENS,y])})})
 

//	ADel(aEnsaios[nPosLab,Len(aEnsaios[nPosLab])],Len(aEnsaios[nPosLab,Len(aEnsaios[nPosLab])]))
//	ASize(aEnsaios[nPosLab,Len(aEnsaios[nPosLab])],Len(aEnsaios[nPosLab,Len(aEnsaios[nPosLab])])-1)
	
	If Existblock('Q215CENS') .And. nTamEns > 15
		For nW:= 1 to Len(aEnsaios[nPosLab])
			ADel(aEnsaios[nPosLab,nW],Len(aEnsaios[nPosLab,nW]))
			ASize(aEnsaios[nPosLab,nW],Len(aEnsaios[nPosLab,nW])-1)
			For nX:= 16 To nTamEns
				Aadd(aEnsaios[nPosLab,nW],aResultados[nPosLab,_ENS,nW,nX])			
//  			Aeval(aResultados[nPosLab,_ENS],{|x,y|Aadd(aEnsaios[nPosLab,Len(aEnsaios[nPosLab])],aResultados[nPosLab,_ENS,y,nX])})			
			Next nX
		Next nW
	Endif

bBlock:= {||Afill(Array(Len(aSizes))," ")}

//Monta o browse com os ensaios
aOBJETOS[OBJ_ENS,nPosLab]:=TwBrowse():New(0.2,0.2,498.5,058,bBlock,aFields,aSizes,oFldLabEns)
aOBJETOS[OBJ_ENS,nPosLab]:SetArray(aEnsaios[nPosLab])  
aOBJETOS[OBJ_ENS,nPosLab]:Align := CONTROL_ALIGN_TOP  
aOBJETOS[OBJ_ENS,nPosLab]:bLostFocus := {||Q215RightMed(nFldLab,nFldEns)}  

Return(NIL)

//----------------------------------------------------------------------
/*/{Protheus.doc} Q215GetSX3 
Busca dados da SX3 
@author Gustavo Della Giustina
@since 16/03/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q215GetSX3(cCampo, cTitulo, cWhen)
Local aHeaderTmp := {}
aHeaderTmp:= {IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo),;
              GetSx3Cache(cCampo,'X3_CAMPO'),;
              GetSx3Cache(cCampo,'X3_PICTURE'),;
              GetSx3Cache(cCampo,'X3_TAMANHO'),;
              GetSx3Cache(cCampo,'X3_DECIMAL'),;
              GetSx3Cache(cCampo,'X3_VALID'),;              
              GetSx3Cache(cCampo,'X3_USADO'),;
              GetSx3Cache(cCampo,'X3_TIPO'),;
              GetSx3Cache(cCampo,'X3_F3'),;
              GetSx3Cache(cCampo,'X3_CONTEXT'),;
              QAGetX3Cmb(cCampo),;
              GetSx3Cache(cCampo,'X3_RELACAO'),;
              IIf(Empty(cWhen), GetSx3Cache(cCampo, 'X3_WHEN'), cWhen) }
Return aHeaderTmp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215aHeadM³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria os aHeaders utilizados na getdados das Medicoes.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215aHeadMed(EXPN1,EXPC1,EXPC2)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao atual do Laboratorio 					  ³±±
±±³			 ³ EXPC1 = Ensaio atual										  ³±±
±±³			 ³ EXPC2 = Carta do Ensaio Atual 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA1 = aCols contendo as medicoes						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA215() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function	Q215aHeadMed(nPosLab,cEnsaio,cCarta,cFormul)
Local aHeaderTmp := {}
Local aColsTmp   := {}
Local bHeadMed                    
Local nQtdMed    := 0     
Local nX         := 0
Local lMedicao	:= Iif(cCarta $ "IND" .AND. !Empty(cFormul) , ".F." , ".T." )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Numero de medicoes de acordo com a Carta do Ensaio			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
nQtdMed	:= Q215QtdMed(cEnsaio)

//Campo Data da Medicao
Aadd(aHeaderTmp, Q215GetSX3("QER_DTMEDI","",""))

//Campo Hora da Medicao
Aadd(aHeaderTmp, Q215GetSX3("QER_HRMEDI","",""))

//Campo Amostragem
Aadd(aHeaderTmp, Q215GetSX3("QER_AMOSTR","",""))

//Campo Filial do Usuario
Aadd(aHeaderTmp, Q215GetSX3("QER_FILMAT","",""))

//Campo Ensaiador
Aadd(aHeaderTmp, Q215GetSX3("QER_ENSR","",""))

//Campo Nome do Ensaiador
Aadd(aHeaderTmp, Q215GetSX3("QER_ENSRNO","",""))

If cCarta <> "TXT"
	If cCarta <> "P  "
		//Campos das Medicoes Mensuraveis 
		If cCarta $ "XBR/XBS/XMR/IND/HIS"
			For nX := 1 to nQtdMed 
				Aadd(aHeaderTmp, Q215GetSX3("QES_MEDICA",STR0036+StrZero(nX,2),lMedicao))
			Next nX

		ElseIf cCarta == "U  "
			Aadd(aHeaderTmp, Q215GetSX3("QES_MEDICA",STR0037,".T.")) //"Amostra"
			Aadd(aHeaderTmp, Q215GetSX3("QES_MEDICA",STR0038,".T.")) //"Nao Conf. p/ Unid."

		ElseIf cCarta == "NP "
			Aadd(aHeaderTmp, Q215GetSX3("QES_MEDICA",STR0039,".T.")) //"Nao Conformes"

		ElseIf cCarta == "C  "
			Aadd(aHeaderTmp, Q215GetSX3("QES_MEDICA","",".T.")) //"Nao Conformidades"

		ElseIf cCarta == "TMP"  
			Aadd(aHeaderTmp, Q215GetSX3("QER_DTINI",STR0242,".T.")) //"Data Inicial"
			Aadd(aHeaderTmp, Q215GetSX3("QER_HRINI",STR0243,".T.")) //"Hora Inicial"			
			Aadd(aHeaderTmp, Q215GetSX3("QER_DTFIM",STR0244,".T.")) //"Data Final"
			Aadd(aHeaderTmp, Q215GetSX3("QER_HRFIM",STR0245,".T.")) //"Hora Final"
			Aadd(aHeaderTmp, Q215GetSX3("QES_MEDICA",STR0036+"01",".T.")) //"Medicao"

		EndIf
	Else
		//Campo Amostra
		Aadd(aHeaderTmp, Q215GetSX3("QES_MEDIPA","",""))

		//Campo Unidades Nao Conforme
		Aadd(aHeaderTmp, Q215GetSX3("QES_MEDIPN","",""))

		//Campo Porcentagem Nao Conforme
		Aadd(aHeaderTmp, Q215GetSX3("QES_MEDIPP","",""))

		//Campo de Calculo da Porcentagem Automaticamente
		Aadd(aHeaderTmp, Q215GetSX3("QES_CALPOR","",""))

	EndIf
Else
	//Campo Medicao 
	Aadd(aHeaderTmp, Q215GetSX3("QEQ_MEDICA",STR0041,".T.")) //"Texto"

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Insere o campo do Resultado da Medicao						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If cCarta <> "TXT"
	Aadd(aHeaderTmp, Q215GetSX3("QER_RESULT","",""))
	
Else
	Aadd(aHeaderTmp, Q215GetSX3("QEQ_RESULT","",""))

EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona Campo da Rastreabilidade.   						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
Aadd(aHeaderTmp, Q215GetSX3("QER_RASTRE","",""))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos criados pelo Usuario						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
Q215FilCpo("QER",bHeadMed,@aHeaderTmp,@aCpoUsu,@aCpoQry)  

//Campo Metodo
Aadd(aHeaderTmp, Q215GetSX3("QER_METODO","",""))

//Campo Revisao do Documento
Aadd(aHeaderTmp, Q215GetSX3("QER_RVDOC","",""))

//Campo Chave da medicao
Aadd(aHeaderTmp, Q215GetSX3("QER_CHAVE","","")) 

// Inclui coluna de registro atraves de funcao generica
ADHeadRec("QER",aHeaderTmp)

//Cria o aCols de acordo com a Carta do Ensaio                                     
aColsTmp := aClone(Q215aColsMed(aHeaderTmp))

//Armazena o aHeader de acordo com a Carta do Ensaio
Aadd(aSavHeadEns[nPosLab],aClone(aHeaderTmp))

Return(aColsTmp)                         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215aColsM³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria a estrutura o aCols de acordo com o aHeader utilizado ³±±
±±³			 ³ na Medicoes.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215aColsMed(EXPA1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPA1 = aHeader utilizado na medicao						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA2 = aCols contendo a estrutura das medicoes			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA215() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215aColsMed(aHeader)
Local aColsTmp := {}
Local nUsadTmp := 0
Local nX

nUsadTmp := Len(aHeader)+1          

//Monta o aCols em um array auxiliar						
aColsTmp := Array(1,nUsadTmp)    
nUsadTmp := 0
For nX := 1 To Len(aHeader)
	nUsadTmp++          
    If aHeader[nX,08] == "C"
        aColsTmp[1,nUsadTmp] := Space( aHeader[nX,04])
   	ElseIf  aHeader[nX,08] == "N"
       	aColsTmp[1,nUsadTmp] := 0
    ElseIf  aHeader[nX,08] == "D"
        aColsTmp[1,nUsadTmp] := dDataBase
   	ElseIf  aHeader[nX,08] == "M"
        aColsTmp[1,nUsadTmp] := " "
    Else
  	    aColsTmp[1,nUsadTmp] := .F.
    EndIf         
    
	If IsHeadRec(aHeader[nX,2])
		aColsTmp[1,nUsadTmp] := 0
	ElseIf AllTrim(aHeader[nX,2]) == "QER_ALI_WT"
	   	aColsTmp[1,nUsadTmp] := "QER"	 
	ElseIf !Empty(aHeader[nX,12]) 
		aColsTmp[1,nUsadTmp] := InitPad(aHeader[nX,12])
	ElseIf aHeader[nX,10] == "V" 
		aColsTmp[1,nUsadTmp] := CriaVar(AllTrim(aHeader[nX,2]))
	EndIf 
	
Next nX
aColsTmp[1,nUsadTmp+1] := .F. 

Return(aColsTmp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215FilEnc³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna um vetor contendo os dados de Um arquivo a ser edi-³±±
±±³			 ³ tado na Enchoice (Rotina de Resultados)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215FilEnc(EXPC1,EXPL1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias para montagem dos campos					  ³±±
±±³			 ³ EXPL1 = .T. preenche com o valor do campo				  ³±±
±±³			 ³ 		   .F. preenche com variavel de memoria				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA1 = Vetor contendo os valores de cada campo			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA215() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215FilEnc(cAlias,lAchou)
Local aDados  := {}
Local aStruct := {}                                                      
Local nX	   := 0

//Pesquisa os campos em uso para edicao
aStruct := FWFormStruct(3,cAlias)[3]
For nX := 1 to Len(aStruct)
	If cNivel >= GetSx3Cache(aStruct[nX,1],"X3_NIVEL")
		If lAchou
			If AllTrim(aStruct[nX,1]) == "QEL_DESLAU" //Preenche a descricao do Laudo
				Aadd(aDados,QE215RDL("QED",1,xFilial("QED")+QEL_LAUDO))
			Elseif AllTrim(aStruct[nX,1]) == "QEL_TAMLOT"
			 	Aadd(aDados,If(Empty(QEL_TAMLOT),QEK->QEK_TAMLOT,QEL_TAMLOT))
			Else
				If GetSx3Cache(aStruct[nX,1],"X3_CONTEXT") == "V"
			    	Aadd(aDados,CriaVar(AllTrim(aStruct[nX,1])))
				Else                 
			    	Aadd(aDados,&(aStruct[nX,1]))                     
			    EndIf
			EndIf
		Else
			Aadd(aDados,CriaVar(AllTrim(aStruct[nX,1])))
		EndIf
	EndIf
Next nX

Return(aDados)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215LauGer³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a selecao na mudanca de Folder dos Ensaios vincula-³±±
±±³			 ³ dos ao Laboratorio selecionado							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215LauGer(EXPO1,EXPN1,EXPN2,EXPN3)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto do Folder corrente        				  ³±±
±±³			 ³ EXPN1 = Posicao do Laudo corrente						  ³±±
±±³			 ³ EXPN2 = Posicao do Registro corrente						  ³±±
±±³			 ³ EXPN3 = Opca do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA215() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215LauGer(oDlgLauGer,nPosLau,nReg,nOpc)
local nOpcAnt := nOpc
aTela := {}
aGets := {}

If lEstorno 
   nOpc := 3 
Endif

//Laudo Geral da Entrada 										  
aOBJETOS[OBJ_LAUGER,1] := MsMGet():New("QEL",nReg,nOpc,,,,,{002,002,135,599.5},aCpoEnc[1],3,,,,oDlgLauGer,,.T.,,,,,,.T.)
aOBJETOS[OBJ_LAUGER,1]:oBox:Align := CONTROL_ALIGN_TOP

@ 105,002 GET aOBJETOS[OBJ_LAUGER,2] VAR aResultados[nPosLau,_ENS] NO VSCROLL MEMO SIZE 498,099 OF oDlgLauGer Pixel      
If !lAltObs .And. nOpc == 5 .And. !lEstorno
	aOBJETOS[OBJ_LAUGER,2]:lReadOnly := .T.
EndIf 
aOBJETOS[OBJ_LAUGER,2]:Align := CONTROL_ALIGN_ALLCLIENT
aSavTela[nPosLau] := aTela
aSavGets[nPosLau] := aGets

nOpc := nOpcAnt

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215Legend³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas nas Entradas				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215Legend()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215Legend() 
	Local aLegenda := {}
	Local aLegenPE := {}
	
	Aadd(aLegenda,{"BR_CINZA",	  OemToAnsi(STR0034)}) //"Entrada sem medicoes cadastradas"
	Aadd(aLegenda,{"BR_MARROM",	  OemToAnsi(STR0079)}) //"Laudo c/ Med Laudo Geral Pendente"
	Aadd(aLegenda,{"BR_BRANCO",	  OemToAnsi(STR0254)}) //"Laudo c/ Med Laudo Laboratorio Pendente " 
	Aadd(aLegenda,{"BR_VERDE",    OemToAnsi(STR0080)}) //"Laudo Aprovado"
	Aadd(aLegenda,{"BR_VERMELHO", OemToAnsi(STR0081)}) //"Laudo Reprovado"
	Aadd(aLegenda,{"BR_AMARELO",  OemToAnsi(STR0082)}) //"Laudo com Liberacao Urgente"
	Aadd(aLegenda,{"BR_LARANJA",  OemToAnsi(STR0083)}) //"Laudo Aprovado Condicionalmente"
	Aadd(aLegenda,{"BR_AZUL",	  OemToAnsi(STR0151)}) //"Laudo c/ Mov de Estoque Pendente" 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para incluir/alterar itens na lista de legendas	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QE215LEG")
		aLegenPE := ExecBlock( "QE215LEG",.F.,.F.,{aClone(aLegenda)})
		
		If ValType(aLegenPE) == "A" .And. !Empty(aLegenPE)
			aLegenda := aClone(aLegenPE)
		EndIf
	EndIf
	
	BrwLegenda(cCadastro,STR0085,aLegenda) //"Entradas"

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215LdoPen³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status dos Laudos Pendentes					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215LdoPen()								                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.	ou .F.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215LdoPen()       
Local lRetorno := .F.

If QEK->QEK_SITENT == "1"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)                                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215LdoApr³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status dos Laudos Aprovados					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215LdoApr()								                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.	ou .F.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215LdoApr()
Local lRetorno := .F.

If QEK->QEK_SITENT == "2"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215LdoRep³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status dos Laudos Reprovados					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215LdoRep()								                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.	ou .F.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215LdoRep()
Local lRetorno := .F.

If QEK->QEK_SITENT == "3"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215LdoUrg³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status dos Laudos com Liberacao Urgente		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215LdoUrg()								                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.	ou .F.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215LdoUrg()
Local lRetorno := .F.

If QEK->QEK_SITENT == "4"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215LdoCon³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status dos Laudos com Liberacao Condicional	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215LdoCon()								                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.	ou .F.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215LdoCon()
Local lRetorno := .F.

If QEK->QEK_SITENT == "5"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215LdoSME³ Autor ³Paulo Emidio de Barros ³ Data ³30/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status dos Laudos sem movimentacao de Estoque    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215LdoSME()								                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.	ou .F.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215LdoSME()
Local lRetorno := .F.

If QEK->QEK_SITENT == "6"
	lRetorno := .T.
EndIf
Return(lRetorno)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215EntSMC³ Autor ³Paulo Emidio de Barros ³ Data ³02/05/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status das Entradas sem Medicoes				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215EntSMC()								                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.	ou .F.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215EntSMC()       
Local lRetorno := .F.

If QEK->QEK_SITENT == "7"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)                                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215EntSLL³ Autor ³Cleber Souza           ³ Data ³06/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o status das Entradas sem Laudo do Laboratorio	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215EntSLL()								                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T.	ou .F.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215EntSLL()       
Local lRetorno := .F.

If QEK->QEK_SITENT == "8"                
	lRetorno := .T.                    
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215LegEns³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exibe a legenda utilizada nos Ensaios					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215LegEns()								                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215LegEns()
Local aLegenda := {}

Aadd(aLegenda,{"PMSTASK4",OemToAnsi(STR0086)}) //"Aprovado"
Aadd(aLegenda,{"PMSTASK1",OemToAnsi(STR0087)}) //"Reprovado"
Aadd(aLegenda,{"PMSTASK2",OemToAnsi(STR0088)}) //"Pendente"
Aadd(aLegenda,{"PMSTASK3",OemToAnsi(STR0084)}) //"Nao obrigatorio"

BrwLegenda(cCadastro,OemToAnsi(STR0089),aLegenda) //"Ensaios"

Return(NIL)

 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215GrvAll³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava os dados referentes ao Resultado					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215GrvAll(EXPN1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215GrvAll(nOpc,aCpos)                                     
Local aAreaQEK   := QEK->(GetArea())
Local aCodMed    := {}                          
Local aHeadTmp   := {} 	//aHeader formatado de acordo com o ensaio 
Local axtextos   := {}
Local cCarEns    := ""  //carta utilizada no ensaio corrente
Local cChave     := ""
Local cCodMed    := "" 	//chave de ligacao da medicao
Local cEnsaio    := "" 	//ensaio corrente  
Local cEspecie   := "QIEA200 "
Local cLabor     := "" 	//laboratorio corrente
Local cLdoAnt    := ""	//Armazena o Laudo Anterior da Entrada, caso o mesmo esteja cadastrado
Local cLdoEnt    := aResultados[nFldLabGer,_LAUGER,nPosLauGer] //Laudo da Entrada
Local cMemo1     := ""	//descricao da NC 1			  
Local cMemo2     := ""  //descricao da NC 2
Local cSeek      := ""
Local l215ExcQNC := ExistBlock("Q215QNCE")    
Local l215IncQNC := ExistBlock("Q215QNCI")
Local lDelMed    := .F.	//indica se a medicao esta excluida no aCols
Local lGrava     := .F.
Local lMedCad    := .F.	//Indica de existe medicoes cadastradas
Local lNaoGrvNNC := .F. //indica que o numero da NNC dever ser igual a espacos
Local lQReinsp	 := QieReinsp()
Local lRet       := .F.
Local lRetLib    := .F.
Local lRetPE     := .F.
Local lTrava     := .T.	//Indica se o registro do QES sera travado                 
Local lVerMens   := .T. //flag que indica se as medicoes mensuraveis serao verificadas
Local nCpoMed    := 0
Local nFilMat    := 0
Local nI         := 0
Local nOrdQER    := 0
Local nPosCalPor := 0	//posicao do calculo do percentual
Local nPosCpoMed := 0         
Local nPosEnsR   := 0   //posicao do ensaiador
Local nPOSEST    := 0
Local nPosMed    := 0  	//posicao do campo corrente no aheader         
Local nPOSMemo   := 0
Local nPosMetod  := 0   //posicao do campor de metodo
Local nPosRast   := 0   //posicao do campor de rastreabilidade
Local nPosResMed := 0 	//posicao do Resultado da medicao
Local nPosRvDoc  := 0   //posicao do campor de revisao do documento
Local nPOSSeq    := 0
Local nPOSTipo   := 0
Local nPosTxtMed := 0 	//posicao do texto da medicao
Local nQtdCpo    := 0    
Local nQtdMed    := 0 	//Numero de Medicoes
Local nRegua     := 0                         
Local nSaveSX8   := GetSX8Len()
Local nUltAba    := 1
Local nX         := 0
Local nY         := 0   
Local nZ         := 0    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto Entrada ANTES da Gravacao (Pode-se alterar a lIntEst)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("QIEA215L") .And. nOpc==3 
	ExecBlock("QIEA215L",.F.,.F.)
EndIf                                       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Liberacao/Rejeicao do Material no CQ                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If lIntEst .And. !Empty(cLdoEnt) //Laudo Geral da Entrada
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizacao da Liberacao/Rejeicao do Material no CQ			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If ExistBlock('MT175ATU')
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Compatibiliza o ponto de entrada MT175ATU apos confirmacao   ³
		//³ da Liberacao e/ou Rejeicao do material no CQ com MATA175.PRX ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		lRet := If(ValType(lRetPE:=ExecBlock('MT175ATU',.F.,.F.))=='L',lRetPE,.T.)
		If lRet
			lGrava := lRet
		EndIf	
	Else
		lGrava := .T.	
	EndIf           

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Libera/Rejeita o Material no CQ								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGrava
		lRetLib := A175Grava()	
        If lRetLib     
    		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto Entrada APOS a Liberacao/Rejeicao no CQ				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock('QIEA215G')
				ExecBlock('QIEA215G',.F.,.F.)
			EndIf
		EndIf	

       	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Compatibiliza a chamada do Execblock: MT390VLV para Validar  ³
		//³ a Validade, acionado no MATA390 (Validade do Lote).			 ³
		//³ (O Retorno podera ser L¢gico)								 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		lRet := .T.
		If ExistBlock('MT390VLV')
			lRet := If(ValType(lRetPE:=ExecBlock('MT390VLV',.F.,.F.,{M->QEL_DTVAL}))=='L',lRetPE,.T.)
		EndIf
		
		If lRet
			//Realiza a Alteracao na Data de Validade do Lote
			If cOrigent == "MATA103"
				If Rastro(QEK->QEK_PRODUT)
					Q215ValLote()
				EndIf	                  
			EndIf	
        EndIf
  	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a exclusao do Resultado das Medicoes				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 4)                                                    
	ProcRegua(2)

	//Verifica se o Saldo no CQ foi totalmente Liberado
	//Retorna ao Status da Entrada para Pendente
	lRet := Q215AtuSit(,,lIntEst,nOpc)
	If !lRet
		Help(" ",1,"Q215ESTCQ") //"O Material Liberado/Rejeitado nao foi estornado totalmente"
		Return(NIL)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa o ponto de Entrada Q215QNCE, para exclusao das NCs en³
	//³ viadas ao QNC.												 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l215ExcQNC 
		ExecBlock("Q215QNCE",.F.,.F.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa P.E. Generico, antes da Exclusao dos Resultados	     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("Q215EXCA")
		ExecBlock("Q215EXCA",.F.,.F.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui as medicoes dos Resultados 							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QieDelMed(QEK->QEK_PRODUT,QEK->QEK_REVI,QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_DTENTR,QEK->QEK_LOTE,QEK->QEK_NTFISC,QEK->QEK_SERINF,QEK->QEK_ITEMNF,QEK->QEK_TIPONF,QEK->QEK_NUMSEQ)
	IncProc()                                                  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui os Documentos Anexos							    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to nQtdLab
		Aeval(aResultados[nX,_ENS],{|x,y|Q215AtuAnexos(nX,y,QEK->QEK_LOTE,nOpc,QEK->QEK_PRODUT)})
    NExt nX
	IncProc()
    
	Return(NIL) 
	
EndIf	
//Final do bloco de Exclusao da Entrada Inspecionada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a chave do QEK esta vazia					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(QEK->QEK_CHAVE) 

	aAreaQA2 := GetArea()
	cChave   := QA_NewChave("QEK",7)
    RestArea(aAreaQA2)

	dbSelectArea("QEK")
	RecLock("QEK",.F.)
	QEK->QEK_CHAVE := cChave
	MsUnLock()
EndIf
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a Observacao da Entrega.             			 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAltObs
	Aadd(axtextos,{1,aResultados[nFldLabGer,_OBSERV]})
	QA_GrvTxt(QEK->QEK_CHAVE,cEspecie,1,@axtextos)
EndIf

//adiciona a regua de processamento              
Aeval(aResultados,{|x,y|If(y<nFldLabGer,nRegua+=Len(aResultados[y,_ENS]),NIL)})
ProcRegua(nRegua+2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o Laudo Geral da Entrada inspecionada			 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLabor := Space(TamSX3("QEL_LABOR")[1])      
	cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
	cSeek  := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)+cNiseri+QEK->(QEK_TIPONF+DtOS(QEK_DTENTR)+QEK_LOTE)
	
dbSelectArea("QEL")
dbSetOrder(1)
If MsSeek(xFilial("QEL")+cSeek+cLabor,.F.)
	cLdoAnt    := QEL->QEL_LAUDO
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o Laudo Final da Entrada Inspecionada					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Q215AtuLab(cLabor,nFldLabGer)
IncProc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa somente se o Laudo Final estiver preenchido			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cLdoEnt) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Laudo da Entrada tinha categoria Liberado Urgente³
	//³ e Laudo atual nao e Aprovado Total							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cLdoAnt)
    	If QiexLdLU(cLdoAnt) .And. !(cLdoEnt $ cFatApr)
			//Avisa o usuario que o produto teve Liberacao Urgente
			Help(" ",1,"Q215002") 
		EndIf             
	EndIf	
		
	//Grava o numero do certificado, caso haja Laudo da Entrada
	If Empty(QEK->QEK_CERQUA)
		RecLock("QEK",.F.)
		QEK->QEK_CERQUA := QA_SEQUSX6("QIE_CEQU",TamSX3("QEK_CERQUA")[1],"S",STR0090) //"Certificado Qualidade"
		MsUnlock()
	EndIf
	
	//Grava os dados referentes a Liberacao urgente no QEK		 
	If QIEXLdLU(QEL->QEL_LAUDO) //Verifica se possui Liberacao Urgente
		RecLock("QEK",.F.)   
		QEK->QEK_DATALU	:= QEL->QEL_DTLAUD
		QEK->QEK_HORALU	:= QEL->QEL_HRLAUD
		QEK->QEK_RESPLU	:= cMatCod	
		MsUnLock()                                              
	Else     
		//Caso a situacao anterior seja Liberacao Urgente, exclui o texto da mesma 
		If QEK->QEK_SITENT $ "14678" 
			QA_DelTxt(QEK->QEK_CHAVE1,"QIEA210U") 
		EndIf			
	EndIf

EndIf

RecLock("QEK",.F.)
For nI := 1 To Len(aCpos)  //Grava campos de usuarios da tabela QEK
	&("QEK->"+Alltrim(aCpos[nI])) := &("M->"+Alltrim(aCpos[nI]))
Next 
MsUnLock()

	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza os Laudos referentes aos Laboratorios	 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aeval(aResultados,{|x,y|If(y<=nQtdLab,Q215AtuLab(aResultados[y,_LAB],y),NIL)})
IncProc()   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Grava o campo memo da SD7 - D7_OBS      				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙs
If lIntEst //Somente se houver integracao com Materiais - Ajuste da DMANQUALI-930
	cTexto   := ''
	nUltAba  := Len(aResultados)
	nPOSSeq  := Ascan(aHeader,{|x|Alltrim(x[2])=="D7_SEQ"})
	nPOSTipo := Ascan(aHeader,{|x|Alltrim(x[2])=="D7_TIPO"})
	nPOSMemo := Ascan(aHeader,{|x|Alltrim(x[2])=="D7_OBS"})
	nPOSEST  := Ascan(aHeader,{|x|Alltrim(x[2])=="D7_ESTORNO"})  

	If nOpc == 3 //Botão - "Resultados"
		For nI := 2 to Len(aResultados[nUltAba])
			cSeq   := aResultados[nUltAba][nI][nPOSSeq]
			cTexto += '[TIPO:' + AllTrim(Str(aResultados[nUltAba][nI][nPOSTipo])) + '/SEQ:' + cSeq + '/A]' + CHR(13) + CHR(10)
			cTexto += aResultados[nUltAba][nI][nPOSMemo] + CHR(13) + CHR(10)
			cTexto += '[TIPO:' + AllTrim(Str(aResultados[nUltAba][nI][nPOSTipo])) + '/SEQ:' + cSeq + '/Z]' + CHR(13) + CHR(10)
		Next nI
	ElseIf nOpc == 5 //Botão - "Estorno"
		cTexto := ''
		If File(cDirCQ+(cArqCQ:='CQ'+SD7->D7_NUMERO+'.TXT')) .And. (nHdl:=fOpen(cDirCQ+cArqCQ,0+64))>0
			If fClose(nHdl)
				cTexto := MemoRead(cDirCQ+cArqCQ)
			EndIf			
		EndIf

		For nI := 2 to Len(aResultados[nUltAba])
			If Upper(aResultados[nUltAba][nI][nPOSEST]) == "X"
				cSeq   := Soma1(aResultados[nUltAba][nI][nPOSSeq])
				cTexto += '[TIPO:' + '6' + '/SEQ:' + cSeq + '/A]' + CHR(13) + CHR(10)
				cTexto += aResultados[nUltAba][nI][nPOSMemo] + CHR(13) + CHR(10)
				cTexto += '[TIPO:' + '6' + '/SEQ:' + cSeq + '/Z]' + CHR(13) + CHR(10)
			EndIf
		Next
	EndIf

	cArqCQ:='CQ'+SD7->D7_NUMERO+'.TXT'
	If Len(cTexto)>0
		If !MemoWrit(cDirCQ+cArqCQ, cTexto)
			Help(' ',1,'MEMOERRO')
		EndIf
	ElseIf File(cDirCQ+cArqCQ) //Determina se existe arquivo no diretório ou path AdvPL padrão.
		If fErase(cDirCQ+cArqCQ) == -1 //Exclui um arquivo do disco.
			Help(' ',1,'MEMOERRO')
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Grava os dados referentes a medicoes					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nQtdLab
    cLabor := aResultados[nX,_LAB] //Laboratorio corrente
    
	For nY := 1 to Len(aResultados[nX,_MED])
		cEnsaio  := aResultados[nX,_ENS,nY,ENSAIO] //Ensaio corrente		
		cCarEns  := QA_CartEns(cEnsaio)            //Carta utilizada no Ensaio
		aHeadTmp := aClone(aSavHeadEns[nX,nY])	    //aHeader formatado para o ensaio corrente			
		nQtdMed  := Q215QtdMed(cEnsaio)		        //Quantidade de medicoes

		//Salva a posicao do Resultado da Medicao
		If cCarEns == "TXT"
			nPosResMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QEQ_RESULT"})
		Else
			nPosResMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_RESULT"})
		EndIf	
		nFilMat   := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_FILMAT"})
		nPosRast  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_RASTRE"})
      	nPosMetod := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_METODO"})
  	   	nPosRvDoc := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_RVDOC"})
      	nPosEnsR  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_ENSR"})

      	If cCarEns == "TMP" //Ensaio do Tipo: TEMPO
      		nPosDtIni := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_DTINI"})
      		nPosHrIni := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_HRINI"}) 		
      		nPosDtFim := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_DTFIM"})
      		nPosHrFim := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_HRFIM"}) 		
      	EndIf 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³	Grava as medicoes										³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nZ := 1 to Len(aResultados[nX,_MED,nY])                      
			cCodMed := 	"ZZZZZZZZ" 		
			lDelMed := 	aResultados[nX,_MED,nY,nZ,Len(aResultados[nX,_MED,nY,nZ])]
			cNiseri := 	QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
			cSeek 	:= 	QEK->(QEK_PRODUT+QEK_REVI+QEK_FORNEC+QEK_LOJFOR)+cNiseri+QEK->(QEK_TIPONF+;
					   	QEK_LOTE)+cLabor+cEnsaio+dTos(aResultados[nX,_MED,nY,nZ,1])+;
						aResultados[nX,_MED,nY,nZ,2]
			nOrdQER :=	5

			If lQReinsp
				cSeek += QEK->QEK_NUMSEQ
			Endif				

			dbSelectArea("QER") 
			dbSetOrder(nOrdQER)
			If QER->(MsSeek(xFilial("QER")+cSeek))
				RecLock("QER",.F.)
			 	cCodMed := QER->QER_CHAVE                          

			    //Se existir o registro e estiver deletado no aCols
				If lDelMed
					dbDelete()
				EndIf
				lVerMens := .T. //as medicoes mensuraveis serao verificadas

			Else
				//Se nao existir o registro e nao estiver deletado no aCols          
				If !lDelMed

					dbSelectArea("QER")
					dbSetOrder(4)
			        cCodMed := QA_SXESXF("QER","QER_CHAVE",,4)
               		While ( GetSX8Len() > nSaveSx8 )
						ConfirmSX8()
					EndDo

					RecLock("QER",.T.)
					QER->QER_FILIAL := xFilial("QER")
					QER->QER_PRODUT := QEK->QEK_PRODUT
					QER->QER_REVI   := QEK->QEK_REVI
					QER->QER_FORNEC := QEK->QEK_FORNEC
					QER->QER_LOJFOR := QEK->QEK_LOJFOR
					QER->QER_DTENTR := QEK->QEK_DTENTR
					QER->QER_LOTE   := QEK->QEK_LOTE
					QER->QER_LABOR  := cLabor
					QER->QER_ENSAIO := cEnsaio
					QER->QER_CHAVE  := cCodMed
					QER->QER_NISERI := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
					QER->QER_NTFISC := QEK->QEK_NTFISC 
					QER->QER_ITEMNF := QEK->QEK_ITEMNF 
					QER->QER_SERINF := QEK->QEK_SERINF 					
					QER->QER_TIPONF := QEK->QEK_TIPONF 
					
					If lQReinsp
						QER->QER_NUMSEQ := QEK->QEK_NUMSEQ
					Endif


					lVerMens := .T. //as medicoes mensuraveis serao verificadas
				Else	
					lVerMens := .F. //as medicoes mensuraveis nao serao verificadas
				EndIf

			EndIf

			If !lDelMed         
				QER->QER_DTMEDI := aResultados[nX,_MED,nY,nZ,1] //posicao fixa
				QER->QER_HRMEDI := aResultados[nX,_MED,nY,nZ,2] //posicao fixa
				QER->QER_AMOSTR := aResultados[nX,_MED,nY,nZ,3] //posicao fixa
				QER->QER_ENSR   := aResultados[nX,_MED,nY,nZ,nPosEnsR]  
				QER->QER_RESULT := aResultados[nX,_MED,nY,nZ,nPosResMed]
				QER->QER_FILMAT := aResultados[nX,_MED,nY,nZ,nFilMat]
				QER->QER_RASTRE := aResultados[nX,_MED,nY,nZ,nPosRast] 
				QER->QER_METODO := aResultados[nX,_MED,nY,nZ,nPosMetod] 
				QER->QER_RVDOC  := aResultados[nX,_MED,nY,nZ,nPosRvDoc] 

				If cCarEns == "TMP"  //Ensaio do Tipo: TEMPO
					QER->QER_DTINI := aResultados[nX,_MED,nY,nZ,nPosDtIni] 
					QER->QER_HRINI := aResultados[nX,_MED,nY,nZ,nPosHrIni] 
					QER->QER_DTFIM := aResultados[nX,_MED,nY,nZ,nPosDtFim] 
					QER->QER_HRFIM := aResultados[nX,_MED,nY,nZ,nPosHrFim] 
      			EndIf 

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³	Realiza a gravacao dos campos criados pelo usuario 		³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nCpoMed := 1 to Len(aCpoUsu)
					If SubStr(aCpoUsu[nCpoMed],1,3) == "QER"         
					 	nPosCpoMed := Ascan(aHeadTmp,{|x|AllTrim(x[2])==AllTrim(aCpoUsu[nCpoMed])})
					 	If nPosCpoMed > 0
							If GetSx3Cache(aCpoUsu[nCpoMed],"X3_PROPRI") == "U"
								If aCpoUsu[nCpoMed] <> "QER_NUMSEQ"
									QER->(FieldPut(FieldPos(AllTrim(aCpoUsu[nCpoMed])),aResultados[nX,_MED,nY,nZ,nPosCpoMed]))
								Endif
	                        EndIf										 
						EndIf		
					EndIf
				Next nCpoMed

				If !lMedCad 
					lMedCad := .T.
				EndIf
			EndIf
			QER->(MsUnLock())
			QER->(FKCOMMIT())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³	Grava as medicoes dos ensaios com carta # TXT			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cCarEns <> "TXT" .And. lVerMens       
				If cCarEns == "P  "
					nPosMed  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDIPA"})
				Else
					nPosMed  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDICA"})
				EndIf
				
				dbSelectArea("QES")
				dbSetOrder(1)
				If MsSeek(xFilial("QES")+cCodMed)
					lTrava := .F.
				Else
					lTrava := .T.
				EndIf						

				//Grava as medicoes mensuraveis	
				nQtdCpo := (nPosMed+nQtdMed-1)
				For nPosMed := nPosMed to nQtdCpo

				    //Verifica se a medicao mensuravel possui a mesma chave
				    If !lTrava .And. (QES->QES_CODMED <> cCodMed)
				    	Exit
				    EndIf               

					//Considera somente os campos que serao gravados no QES				    
					If AllTrim(aHeadTmp[nPosMed,2]) $ "QES_MEDICA/QES_MEDIPA/QES_MEDIPN/QES_MEDIPP"	

						RecLock("QES",lTrava)            
						If lTrava
							QES->QES_FILIAL := xFilial("QES")
							QES->QES_CODMED := cCodMed   
						EndIf					         
					
						//Se existir o registro e estiver deletado no aCols		
						If (!lTrava .And. lDelMed)
							//Exclui a medicao mensuravel
							dbDelete()
						Else    

							//Se nao existir e estiver deletado no aCols
							If !lDelMed	
								If cCarEns <> "P  "                    
									If AllTrim(aHeadTmp[nPosMed,2]) == "QES_MEDICA"	 
										If cCarEns == "TMP"                    
											QES->QES_MEDICA := If(Valtype(aResultados[nX,_MED,nY,nZ,nPosMed])=='N',;
												AllTrim(Str(aResultados[nX,_MED,nY,nZ,nPosMed])),;
												AllTrim(aResultados[nX,_MED,nY,nZ,nPosMed]))
     	                                Else
											QES->QES_MEDICA := aResultados[nX,_MED,nY,nZ,nPosMed]
										EndIf	
									EndIf	
								Else               
									If 	AllTrim(aHeadTmp[nPosMed,2]) == "QES_MEDIPA"	 						                                                                                             
										QES->QES_INDMED := "A"                             
										QES->QES_MEDICA := Str(aResultados[nX,_MED,nY,nZ,nPosMed],TamSx3("QES_MEDICA")[1])

									ElseIf AllTrim(aHeadTmp[nPosMed,2]) == "QES_MEDIPN"	 			 
										QES->QES_MEDICA := StrTran(Str(aResultados[nX,_MED,nY,nZ,nPosMed],TamSx3("QES_MEDICA")[1],2),".",",")
										
										nPosCalPor := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_CALPOR"})
										If aResultados[nX,_MED,nY,nZ,nPosCalPor] == "S"								
											QES->QES_INDMED := "N"
										EndIf
									ElseIf AllTrim(aHeadTmp[nPosMed,2]) == "QES_MEDIPP"	 						                                                                                             
										QES->QES_INDMED := "P"
										QES->QES_MEDICA := Str(aResultados[nX,_MED,nY,nZ,nPosMed],TamSx3("QES_MEDICA")[1],TamSx3("QES_MEDIPP")[2])

									EndIf

								EndIf
								
							EndIf
						EndIf
				        MsUnLock()
				        QES->(FKCOMMIT())
				        //Se o registro existe, pula o mesmo
						If !lTrava
							QES->(dbSkip())
						EndIf
					EndIf	

				Next nPosMed

			ElseIf cCarEns == "TXT" .And. lVerMens                             
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³	Grava as medicoes dos ensaios com carta = TXT			³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				//Grava os resultados com carta do tipo texto
				nPosTxtMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QEQ_MEDICA"})

				dbSelectArea("QEQ")
				dbSetOrder(1)
				If MsSeek(xFilial("QEQ")+cCodMed)
					RecLock("QEQ",.F.)                                   
					//Se existir o registro e estiver marcado para exclusao
					If lDelMed    
						dbDelete()
					EndIf
				Else
					If !lDelMed
						RecLock("QEQ",.T.)
						QEQ->QEQ_FILIAL := xFilial("QEQ")
						QEQ->QEQ_CODMED := cCodMed
					EndIf	
				EndIf
				//Se nao estiver marcado para exclusao                             
				If !lDelMed
					QEQ->QEQ_MEDICA := aResultados[nX,_MED,nY,nZ,nPosTxtMed] 

				EndIf	
				MsUnLock()

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza as nao-conformidades e cronicas associadas as  ³
			//³ Medicoes    											³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Q215AtuNco(nX,nY,nZ,lDelMed,cCodMed,@lNaoGrvNNC)      

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza as cronicas associadas as nao-conformidades    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Q215AtuIns(nX,nY,nZ,lDelMed,cCodMed)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Salva as chaves para Integracao com o QNC				³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Aadd(aCodMed,cCodMed)

	    Next nZ    			
		IncProc()	

	Next nY    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza os Documentos Anexos							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aeval(aResultados[nX,_ENS],{|x,y|Q215AtuAnexos(nX,y,QEK->QEK_LOTE,nOpc,QEK->QEK_PRODUT)})

Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se existir o mumero da NNC, grava o mesmo em branco		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lNaoGrvNNC 
	If !Empty(QEK->QEK_NNC)    
		//Exclusao da NNC 
		QieAtuNNC(2)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o Status de Laudo Pendente						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Q215AtuSit(cLdoEnt,lMedCad,lIntEst,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Realiza a Integracao com o QNC							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cLdoEnt) //Somente quando o Laudo Final for informado

	For nX := 1 to Len(aCodMed)
		QEU->(dbSetOrder(1))
		If QEU->(MsSeek(xFilial("QEU")+aCodMed[nX]))
			While QEU->(!Eof()) .And. QEU->QEU_FILIAL == xFilial("QEU") .And. QEU->QEU_CODMED == aCodMed[nX] 
				cMemo1 := Q215FilTxt(QEU->QEU_CHAVE)
				cMemo2 := STR0092+QEU->QEU_NAOCON+STR0093 //"NC: " ### " - Ensaio: " ### " - Laboratorio: "

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³	Envia as Nao-conformidades para o QNC de o MV_QINTQNC   ³
				//³	estiver igual a "S".									³	
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lIntQNC
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³	Caso exista o ponto de entrada Q215QNCI, nao sera execu-³
					//³	tada a integracao convencional.							³	
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !l215IncQNC 
						Q215GerQNC(QEU->QEU_CODNC,QEU->QEU_REVNC,cMemo1,cMemo2,aCodMed[nX])
					Else
						ExecBlock("Q215QNCI",.F.,.F.)
					EndIf	
				EndIf	
				
				QEU->(dbSkip())	
			EndDo	
		EndIf
	Next nX		

EndIf	

//Ponto de Entrada executado, quando nao ha integracao com Materiais
If !lIntEst .And. !Empty(cLdoEnt) //Laudo Geral da Entrada
	If ExistBlock("QE210NMO") 
		ExecBlock("QE210NMO",.F.,.F.)
	EndIf
EndIf	     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa P.E. Generico, Apos a Atualizacao dos Resultados	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("Q215GRVA")
	ExecBlock("Q215GRVA",.F.,.F.,{QEK->QEK_PRODUT,QEK->QEK_REVI,QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_DTENTR,QEK->QEK_LOTE,QEK->QEK_NTFISC,QEK->QEK_SERINF,QEK->QEK_ITEMNF,QEK->QEK_TIPONF,nOpc})
EndIf


RestArea(aAreaQEK)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215AtuLab³ Autor ³ Paulo Emidio de Barros³ Data ³ 18/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os Laudos referentes aos Laboratorios			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215AtuLab(EXPC1,EXPN1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Laboratorio								 	      ³±±
±±³			 ³ EXPN1 = Posicao do Laudo									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAQIE													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215AtuLab(cLabor,nPosLdo)
Local nPosEnc
Local cHistorico := " "
Local nCpo 
Local cSeek      := ""        
Local lQReinsp	 := QieReinsp()

If nPosLdo==nFldLabGer 
	nPosEnc := 1 //posicao do Laudo Geral da Entrada 
Else	
	nPosEnc := _LAU //posicao do Laudo do Laboratorio
EndIf

dbSelectArea("QEL")
cNiseri	:= QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
dbSetOrder(3)
cSeek	:= QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)+cNiseri+(QEK->(QEK_TIPONF+DtOS(QEK_DTENTR)+QEK_LOTE))+cLabor

If lQReinsp
	cSeek += QEK->QEK_NUMSEQ
Endif	

If !MsSeek(xFilial("QEL")+cSeek,.F.)
	RecLock("QEL",.T.)   
	QEL->QEL_FILIAL	:= xFilial("QEL")
	QEL->QEL_FORNEC	:= QEK->QEK_FORNEC
	QEL->QEL_LOJFOR	:= QEK->QEK_LOJFOR
	QEL->QEL_PRODUT	:= QEK->QEK_PRODUT
	QEL->QEL_DTENTR	:= QEK->QEK_DTENTR
	QEL->QEL_LOTE	:= QEK->QEK_LOTE
	QEL->QEL_LABOR	:= cLabor
	QEL->QEL_REVI	:= QEK->QEK_REVI
	QEL->QEL_NISERI	:= QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
	QEL->QEL_TIPONF	:= QEK->QEK_TIPONF

	If lQReinsp
		QEL->QEL_NUMSEQ := QEK->QEK_NUMSEQ
	Endif	
Else
	RecLock("QEL",.F.)   
EndIf

//Realiza a gravacao dos demais campos habilitados na enchoice
For nCpo:= 1 to Len(aCpoEnc[1]) 
	If  AllTrim(aCpoEnc[1,nCpo]) == "QEL_HISTOR"                                                 
		cHistorico := aResultados[nPosLdo,nPosEnc,nCpo]
	ElseIf aCpoEnc[2,nCpo] <> "V"      
		//evita que o Numero do Lote seja gravado em branco, caso o campo esteja em uso.		
		If AllTrim(aCpoEnc[1,nCpo]) <> "QEL_LOTE" .And. AllTrim(aCpoEnc[1,nCpo]) <> "QEL_NISERI" .And. ;
				AllTrim(aCpoEnc[1,nCpo]) <> "QEL_TIPONF" .And. AllTrim(aCpoEnc[1,nCpo]) <> "QEL_NUMSEQ"
				If AllTrim(aCpoEnc[1,nCpo]) == ALLTrim("QEL_NOMRES") .And. aResultados[nPosLdo,nPosEnc,nCpo] == NIL
					aResultados[nPosLdo,nPosEnc,nCpo]:= " "
				EndIf
			QEL->(FieldPut(FieldPos(AllTrim(aCpoEnc[1,nCpo])),aResultados[nPosLdo,nPosEnc,nCpo]))			
		EndIf			      
	EndIf			
Next nCpo

QEL->QEL_QTDAPR := Str(SuperVal(QEL->QEL_TAMLOT)-(SuperVal(QEL->QEL_QTREJ)+SuperVal(QEL->QEL_QTDEST)),TamSx3("QEL_TAMLOT")[1])

MsUnLock()        
    
//Realiza a Gravacao do HIstorico do Laudo                          
MsMM(QEL_CHAVEH,,,cHistorico,1,,,"QEL","QEL_CHAVEH")

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215AtuNco³ Autor ³Paulo Emidio de Barros ³ Data ³16/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza as nao-conformidades associadas as medicoes		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215AtuNco(EXPN1,EXPN2,EXPN3,EXPL1,EXPC1,EXPL2)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Laboratorio							  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio							  	  ³±±
±±³			 ³ EXPN3 = Posicao Linha Medicao associada a Nao-conformidade ³±±
±±³			 ³ EXPL1 = Indica se a Medicao foi excluida					  ³±±
±±³			 ³ EXPC1 = Codigo da Medicao							      ³±±
±±³			 ³ EXPL2 = Indica se o numero da NNC sera excluido	  	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215AtuNco(nPosLab,nPosEns,nPosLinMed,lDelMed,cCodMed,lNaoGrvNNC)
Local aHeadTmp := {}
Local nPosNco  := 0 
Local lDelNco  := .F.
Local nItem    := 0
Local aTxtNco  := {}
Local nX 	   := 0	
Local aCpoQNC  := {}
Local cKeyNco  := " "                                   
Local cCodNco  := " "
Local cRevNco  := " "
Local aAreaQEU            

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Grava as nao-conformidades associadas as medicoes   	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeadTmp := aClone(aSavaHeader[HEAD_NCS])
nPosNco  := Ascan(aHeadTmp,{|x|AllTrim(x[2])=="QEU_NAOCON"})

For nItem := 1 to Len(aResultados[nPosLab,_NCO,nPosEns,nPosLinMed])

	//verifica se a nao-conformidade esta excluida
	lDelNco := aResultados[nPosLab,_NCO,nPosEns,nPosLinMed,nItem,Len(aResultados[nPosLab,_NCO,nPosEns,nPosLinMed,nItem])]
	lDelNco := If(lDelMed,lDelMed,lDelNco)

	cKeyNco := " "                                   
	cCodNco := " "
	cRevNco := " "

	//pesquisa pela ultima chave de ligacao da medicao
	dbSelectArea("QEU") 
	dbSetOrder(1)
	If MsSeek(xFilial("QEU")+cCodMed+aResultados[nPosLab,_NCO,nPosEns,nPosLinMed,nItem,nPosNco])

		cKeyNco := QEU->QEU_CHAVE //Chave de ligacao
		cCodNco := QEU->QEU_CODNC //Codigo da Nao-Conformidade
		cRevNco := QEU->QEU_REVNC //Revisao da Nao-Conformidade

   		RecLock("QEU",.F.)                              
		If lDelNco //Se estiver deletado no acols, exclui o registro   		
			dbDelete()    
		EndIf

	Else
		//Inclui o registro se o mesmo nao estiver marcado para exclusao   
		If !lDelNco
			RecLock("QEU",.T.)
			QEU->QEU_FILIAL := xFilial("QEU")
			QEU->QEU_CODMED := cCodMed
		EndIf	
	EndIf

	//Se nao houver marca para exclusao, grava os dados
	If !lDelNco
		lNaoGrvNNC := If(!lNaoGrvNNC,.T.,lNaoGrvNNC)
		For nX := 1 to Len(aHeadTmp) 
			If (aHeadTmp[nX,10] # "V")
				QEU->(FieldPut(FieldPos(AllTrim(aHeadTmp[nX,2])),aResultados[nPosLab,_NCO,nPosEns,nPosLinMed,nItem,nX]))
			EndIf                         
		Next nX         
	EndIf
	MsUnLock()
	QEU->(FKCOMMIT())

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Grava a chave de ligacao gerada para a cronica da NC    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lDelNco
		If Empty(cKeyNco)	        
		    aAreaQEU := GetArea()
			cKeyNco  := QA_NewChave("QEU",3)
	        RestArea(aAreaQEU)
	        
			RecLock("QEU",.F.)
			QEU->QEU_CHAVE  := cKeyNco
			MsUnLock()
			
		EndIf

	EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Exclui as Fichas de nao-conformidade, caso haja integra	³
	//³	cao com o SIGAQNC.										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lIntQNC .And. lDelNco 
	  	aCpoQNC := {}
	    Aadd(aCpoQNC,xFilial("QI2"))
		Aadd(aCpoQNC,cCodNco) 
		Aadd(aCpoQNC,cRevNco)
	
		If !lQE215QNC
			QNCGERA(2,aCpoQNC)
		Else 
			ExecBlock("QE215QNC",.f.,.f.,{aCpoQNC,QEU->QEU_CHAVE,"E"})
		EndIF
	EndIf
            
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Grava as cronicas referentes as nao-conformidades    	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lDelNco
		QA_DelTxt(cKeyNco,"QIEA210C") 
	Else
		aTxtNco := {}
		Aadd(aTxtNco,{1,aResultados[nPosLab,_CRO,nPosEns,nPosLinMed,nItem]}) 
		QA_GrvTxt(cKeyNco,"QIEA210C",1,aTxtNco,"QA2",68)
    EndIf

Next nItem

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215AtuIns³ Autor ³Paulo Emidio de Barros ³ Data ³16/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os Instrumentos associados as medicoes		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215AtuIns(EXPN1,EXPN2,EXPN3,EXPL1,EXPC1)				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Laboratorio							  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio							  	  ³±±
±±³			 ³ EXPN3 = Posicao Linha Medicao associada a Nao-conformidade ³±±
±±³			 ³ EXPL1 = Indica se a Medicao foi excluida					  ³±±
±±³			 ³ EXPC1 = Codigo da Medicao							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215AtuIns(nPosLab,nPosEns,nPosLinMed,lDelMed,cCodMed)
Local aHeadTmp := {}
Local nPosIns  := 0            
Local lDelIns  := .F.    
Local nItem    := 0
Local nX       := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Grava os Instrumentos utilizados nos ensaios		 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeadTmp := aClone(aSavaHeader[HEAD_INS])
nPosIns  := Ascan(aHeadTmp,{|x|AllTrim(x[2])=="QET_INSTR"})

For nItem := 1 to Len(aResultados[nPosLab,_INS,nPosEns,nPosLinMed])

	 //verifica se a nao-conformidade esta excluida
	lDelIns := 	aResultados[nPosLab,_INS,nPosEns,nPosLinMed,nItem,Len(aResultados[nPosLab,_INS,nPosEns,nPosLinMed,nItem])]
		
	If lDelMed
		lDelIns := lDelMed
	EndIf			      

	dbSelectArea("QET")
	dbSetOrder(1)
	If MsSeek(xFilial("QET")+cCodMed+aResultados[nPosLab,_INS,nPosEns,nPosLinMed,nItem,nPosIns])
		RecLock("QET",.F.)
		If lDelIns
		    dbDelete()
		EndIf
	Else
		If !lDelIns
			RecLock("QET",.T.)
			QET->QET_FILIAL := xFilial("QET")
			QET->QET_CODMED := cCodMed        
		EndIf
	EndIf	
	If !lDelIns			
		For nX := 1 to Len(aHeadTmp) 
			If (aHeadTmp[nX,10] <> "V")
				QET->(FieldPut(FieldPos(AllTrim(aHeadTmp[nX,2])),;
					aResultados[nPosLab,_INS,nPosEns,nPosLinMed,nItem,nX]))
			EndIf                         
		Next nX   
	EndIf      
	QET->(MsUnLock())
	QET->(FKCOMMIT())

Next nItem	

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215FatApr³ Autor ³ Paulo Emidio de Barros³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Define os Fatores Aprovacao, Apr. Condicional e Reprovacao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³EXPL1 = .T. ou .F. 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA215													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observ	 ³Estao declaradas como Private as seguintes variaveis:       ³±±
±±³			 ³cFatApr, cFatApc, cFatRep	cFatLU.						   	  ³±±
±±³			 ³												   	  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215FatApr()
	Local lRetorno := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define os Fatores do IQP									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QED->(dbSetOrder(1))
	QED->(MsSeek(xFilial("QED")))
	If QED->(Eof())
		Help(" ",1,"Q215003") 
		lRetorno := .F.
	Else
		While QED->(!Eof())
			If QED->QED_CATEG == "1"
				cFatApr += QED->QED_CODFAT
			ElseIf QED->QED_CATEG == "2"
				cFatApC += QED->QED_CODFAT
			ElseIf QED->QED_CATEG == "3"
				cFatRep := If(Empty(cFatRep),QED->QED_CODFAT,cFatRep)
			ElseIf QED->QED_CATEG == "4"
				cFatLU := If(Empty(cFatLU),QED->QED_CODFAT,cFatLU)
			EndIf
			QED->(dbSkip())
		EndDo
	EndIf                                  
	
	If !Empty(cFatApr)
		cFatApr := AllTrim(cFatApr)
	EndIf
	If !Empty(cFatApC)
		cFatApC := AllTrim(cFatApC)
	EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215LibUrg³ Autor ³ Paulo Emidio de Barros³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Digitacao do Texto da LIberacao Urgente					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215LibUrg()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215LibUrg(nOpc)
Local aTexto   := {}
Local cTexto   := " "
Local cTitulo  := STR0097 //"Liberacao Urgente"
Local cTitulo2 := ""
Local cEspecie := "QIEA210U" 
Local cCabLib  := STR0098 //"Observacoes da Liberacao urgente"
Local cChave1  := ""
Local nTamLin  := 70
Local lLibUrg  := .F.
Local lEdita

lEdita := If(nOpc==3,.T.,.F.)     

If nFldLab == nFldLabGer //Atualiza o folder corrente
	Q215SetLab(,nFldLabGer)
EndIf

//Caso nao seja Liberacao Urgente, o texto nao sera utilizado
If !Empty(aResultados[nFldLabGer,_LAUGER,nPosLauGer])
	If aResultados[nFldLabGer,_LAUGER,nPosLauGer] <> cFatLU 
		Help(" ",1,"Q215NAOURG") 
		Return(NIL) 
	Else
		//Recupera o Texto da Liberacao Urgente, caso exista
		If !Empty(QEK->QEK_CHAVE1) .And. (QEK->QEK_SITENT $ '14678') 
			cTexto := QA_RecTxt(QEK->QEK_CHAVE1,"QIEA210U",00,70,"QA2",{})
			aTexto     := {{1,cTexto}}
	    EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera a  chave de Ligacao para o Texto da Liberacao Urgente   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(QEK->QEK_CHAVE1)

	aAreaQA2 := GetArea()
	cChave1  := QA_NewChave("QEK",9)
    RestArea(aAreaQA2)
	
	dbSelectArea("QEK")
	RecLock("QEK",.F.)
	QEK->QEK_CHAVE1 := cChave1
	MsUnlock()
Else
	cChave1 := QEK->QEK_CHAVE1
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Texto da Liberacao Urgente									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo2 := Posicione("QE6",3,xFilial("QE6")+QEK->(QEK_PRODUT+QEK_REVI),"QE6_DESCPO")+STR0099+QEK->QEK_LOTE //" - Lote "
lLibUrg  := QA_TEXTO(cChave1,cEspecie,nTamLin,cTitulo,cTitulo2,@aTexto,1,cCabLib,lEdita)

//Grava o texto da Liberacao Urgente	
If lLibUrg .And. lEdita
	QA_GrvTxt(QEK->QEK_CHAVE1,cEspecie,1,@aTexto)    
	
	Help(" ",1,"Q215062") //"A Entrada foi definida como Liberacao Urgente, acesse a pasta 'Laudo Geral', e posicione sobre o campo 'Laudo', para que o mesmo seja definido como 'Liberacao Urgente'"
    
	oFolder:nOption := nFldLabGer 
	oFolder:Refresh()
	
	lLiberaUrg := If(!lLiberaUrg,.T.,lLiberaUrg)

EndIf

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215NaoCon³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe a reincidencia das nao-conformidades, baseadas nas ul-³±±
±±³			 ³timas Entradas do Fornecedor								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215NaoCon()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA215() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215NaoCon()
Local oDlgNco                
Local aAreaQEK := QEK->(GetArea())
Local aAreaQER := QER->(GetArea())
Local aNaoCon  := {}
Local aFields  := {}
Local aSizes   := {} 
Local bBlock  
Local oBrwNco
Local cDesClaNco
Local cDesNaoCon
Local aNCsAux := {}
Local nX
Local nY    
Local nZ    
Local nW
Local nPos
Local cFornece := QEK->QEK_FORNEC
Local cLoja    := QEK->QEK_LOJFOR
Local cProduto := QEK->QEK_PRODUT 
Local nDias	    := SuperGetMV("MV_QDIREIN") 
Local dLimite
Local cChvMed
Local cChvQER    := ""
Local cSeekQER   := ""
Local nSetQER    := 0

//Dados do twbrowse
aFields := {STR0100,STR0101,STR0102,STR0103,STR0104} //"NC" ### "Descricao" ### "Quant" ### "Classe" ### "Descricao"
aSizes  := {40,100,30,30,90}
bBlock  := {||Afill(Array(Len(aSizes))," ")}

//Armazena as NC,s, exceto a posicao do Laudo Geral da Entrada
For nX := 1 to nQtdLab       
	For nY := 1 to Len(	aResultados[nX,_NCO])
		For nZ := 1 to Len(	aResultados[nX,_NCO,nY])         
			For nW := 1 to Len(aResultados[nX,_NCO,nY,nZ])
				If !Empty(aResultados[nX,_NCO,nY,nZ,nW,nPosNc])
					nPos := Ascan(aNaoCon,{|x|x[1]==aResultados[nX,_NCO,nY,nZ,nW,nPosNc]})
					If nPos > 0
						aNaoCon[nPos,3]++
					Else
						If Upper(__Language) == "SPANISH"
    						cDesNaoCon := Posicione("SAG",1,xFilial("SAG")+aResultados[nX,_NCO,nY,nZ,nW,nPosNc],"AG_DESCES")
    						cDesClaNco := Posicione("QEE",1,xFilial("QEE")+aResultados[nX,_NCO,nY,nZ,nW,nPosCla],"QEE_DESCES")
 						ElseIf Upper( __LANGUAGE) == "ENGLISH"
 							cDesNaoCon := Posicione("SAG",1,xFilial("SAG")+aResultados[nX,_NCO,nY,nZ,nW,nPosNc],"AG_DESCIN")
    						cDesClaNco := Posicione("QEE",1,xFilial("QEE")+aResultados[nX,_NCO,nY,nZ,nW,nPosCla],"QEE_DESCIN")		
 						ElseIf Upper(__LANGUAGE) == "PORTUGUESE"
							cDesNaoCon := Posicione("SAG",1,xFilial("SAG")+aResultados[nX,_NCO,nY,nZ,nW,nPosNc],"AG_DESCPO")
							cDesClaNco := Posicione("QEE",1,xFilial("QEE")+aResultados[nX,_NCO,nY,nZ,nW,nPosCla],"QEE_DESCPO")	
			             Endif
						Aadd(aNaoCon,{aResultados[nX,_NCO,nY,nZ,nW,nPosNc],;
								   	   cDesNaoCon,;
								   	   1,;
								   	   aResultados[nX,_NCO,nY,nZ,nW,nPosCla],;
								   	   cDesClaNco})             
					EndIf                                     
				EndIf	
			Next nW
		Next nZ					   
	Next nY		
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona as reincidencias  das NC,s nas Entradas anteriores ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Salta o registro da Entrada atual, pois a mesma ja esta com as NC,s reincidentes
// carregadas no vetor
QEK->(dbSkip())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula data limite para selecionar as Entradas    	  	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dLimite	:= (QEK->QEK_DTENTR-nDias)

While QEK->(!Eof()) .And. (xFilial("QEK")+cFornece+cLoja+cProduto) ==;
	(QEK->QEK_FILIAL+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT)

	If QEK->QEK_DTENTR < dLimite
		Exit
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona os resultados da Entrada  					     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
		cChvQER    := xFilial("QER")+QEK->QEK_PRODUT+QEK->QEK_REVI+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+cNiseri+QEK->QEK_TIPONF+QEK->QEK_LOTE 
		cSeekQER   := "QER->(QER_FILIAL+QER_PRODUT+QER_REVI+QER_FORNEC+QER_LOJFOR+QER_NISERI+QER_TIPONF+QER_LOTE)"
		QER->(dbSetOrder(5))

	If QER->(MsSeek(cChvQER))
		While QER->(!Eof()) .And.;
			&cSeekQER == cChvQER

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Armazena a chave de ligacao da medicao						 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cChvMed := QER->QER_CHAVE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ verifica as NC,s vinculadas as medicoes						 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QEU->(dbSetOrder(1))
			QEU->(MsSeek(xFilial("QEU")+cChvMed))
			While QEU->(!Eof()) .And. (QEU->QEU_FILIAL+QEU->QEU_CODMED) ==;
			    (xFilial("QEU")+cChvMed)

				nPos := Ascan(aNaoCon,{|x|x[1]==QEU->QEU_NAOCON})
				If nPos > 0
					aNaoCon[nPos,3]++
				Else
				   	If Upper(__Language) == "SPANISH"
				   			cDesNaoCon := Posicione("SAG",1,xFilial("SAG")+QEU->QEU_NAOCON,"AG_DESCES")
							cDesClaNco := Posicione("QEE",1,xFilial("QEE")+QEU->QEU_CLASSE,"QEE_DESCES")
					ElseIf Upper( __LANGUAGE) == "ENGLISH" 
							cDesNaoCon := Posicione("SAG",1,xFilial("SAG")+QEU->QEU_NAOCON,"AG_DESCIN")
							cDesClaNco := Posicione("QEE",1,xFilial("QEE")+QEU->QEU_CLASSE,"QEE_DESCIN")
					ElseIf Upper(__LANGUAGE) == "PORTUGUESE"
							cDesNaoCon := Posicione("SAG",1,xFilial("SAG")+QEU->QEU_NAOCON,"AG_DESCPO")
							cDesClaNco := Posicione("QEE",1,xFilial("QEE")+QEU->QEU_CLASSE,"QEE_DESCPO")
					Endif	
					Aadd(aNaoCon,{QEU->QEU_NAOCON,cDesNaoCon,1,QEU->QEU_CLASSE,cDesClaNco})             
					
				EndIf                                     

				QEU->(dbSkip())
			EndDo
			QER->(dbSkip())
		EndDo
	EndIf
	QEK->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Ordena pela maior reincidencia						         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
aNaoCon := Asort(aNaoCon,,,{| x,y |x[4]<y[4]})

//Filtra as reincidencias das entradas retroativas
For nX := 1 to Len(aNaoCon)
	If (aNaoCon[nX,3] > 1)
		Aadd(aNcsAux,{})
		aNcsAux[Len(aNcsAux)]:= aClone(aNaoCon[nX])
	EndIf
Next nX
aNaoCon := aClone(aNcsAux)

RestArea(aAreaQEK)
RestArea(aAreaQER)

If Len(aNaoCon) == 0
	Help(" ",1,"Q215004")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe o browse com as nao-conformidades reincidentes         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	DEFINE MSDIALOG oDlgNco TITLE OemToAnsi(STR0105) From 188,050 TO 416,555 OF oMainWnd Pixel	//"Nao-Conformidades Reincidentes"  	

	//Monta o browse com os ensaios
	oBrwNco:= TwBrowse():New( 0.5,0.5,246.3,090,bBlock,aFields,aSizes,oDlgNco)
	oBrwNco:SetArray(aNaoCon)      
	oBrwNco:lMChange := .F.      
	oBrwNco:bLine := {||{aNaoCon[oBrwNco:nAt,1],aNaoCon[oBrwNco:nAt,2],;
 		aNaoCon[oBrwNco:nAt,3],aNaoCon[oBrwNco:nAt,4],aNaoCon[oBrwNco:nAt,5]}}

	@ 101, 200 BUTTON OemToAnsi(STR0106) SIZE 044,011 OF oDlgNco PIXEL ACTION oDlgNco:End() //"Retorna"
	ACTIVATE MSDIALOG oDlgNco CENTERED

EndIf

Return(NIL)     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215TxtPro³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe o texto da Especificacao do Produto				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215TxtPro()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA215() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215TxtPro()
Local cChave
Local cCabec   := OemToAnsi(STR0107) //"Texto do Produto"
Local cTitulo  := OemToAnsi(STR0108) //"Produto"
Local nTamLin  := TamSX3("QA2_TEXTO")[1]
Local cEspecie := "QIEA010 "         //Para gravacao de textos
Local aAmbSave := GetArea()
Local aTextos  := {} 
Local aAreaQA2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera/obtem a chave de ligacao com o texto do Produto/Rv  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE6->(dbSetOrder(1))
If Empty(QE6->QE6_CHAVE)   

	aAreaQA2 := GetArea()
	cChave   := QA_NewChave("QE6",2)
    RestArea(aAreaQA2)

	dbSelectArea("QE6")
	RecLock("QE6",.F.)
	QE6->QE6_CHAVE := cChave
	MsUnLock()
Else
	cChave := QE6->QE6_CHAVE
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Digitacao do Texto do Produto   						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QA_TEXTO(cChave,cEspecie,nTamlin,cTitulo,AllTrim(QE6->QE6_PRODUT)+'-'+QE6->QE6_REVI,;
	 @aTextos,1,cCabec,.F.)

RestArea(aAmbSave)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215VldEns³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida campo Ensaidor no cadastro das medicoes			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldEns(EXPC1)				 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Ensaiador 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID QER_ENSR 										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldEns(cCodEns,lQipFil)
Local lRetorno   := .T.               
Local lQE215Ens	 := ExistBlock("QE215ENS") 
Local cFilUs     := xFilial("QAA")  
Local nX		 := 0
Default lQipFil  := .F.

If lQipFil
	cFilUs := aCols[N,nPosFilMat]
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o ensaiador esta cadastrado					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QAA->(dbSetOrder(1))
If QAA->(MsSeek(cFilUs+cCodEns))
	//Verifica se o Ensaiador possui o nivel exigido no Ensaio
	QE1->(dbSetOrder(1))
	If QE1->(MsSeek(xFilial("QE1")+cEnsaio))
		If Val(QAA->QAA_NIVEL) < Val(QE1->QE1_NIENSR)
			Help(" ",1,"Q215005") 
			lRetorno := .F.
		EndIf
	EndIf
Else	
	Help(" ",1,"Q215NAOENS") 
	lRetorno := .F.
EndIf

If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Ensaiador possui status demitido			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !QA_CHKMAT(aCols[N,nPosFilMat],cCodEns,.F.)
		If MsgYesNo(OemToAnsi(STR0261),OemtoAnsi(STR0011)) // "Existem ensaiadores com situacao de Inativo no Cadastro. Deseja alterar o ensaiador responsavel por estas medicoes para o usuario logado no sistema."###"Atencao"
			For nX := 1 To Len(aCols)
				If AllTrim(cCodEns) == AllTrim(aCols[nX,nPosEnsR])
					aCols[nX,nPosEnsR] := QAXUser(__cUserId,5) 
					aCols[nX,nPosNomEns] := QAA->QAA_APELID
				EndIf
			Next
			M->QER_ENSRNO       := aCols[N,nPosNomEns]
			M->QER_FILMAT       := aCols[N,nPosFilMat] 
			lRetorno := .F.
		Else
			lRetorno := .F.
		EndIf
	EndIf
EndIf

If lQE215Ens
	lRetorno := ExecBlock("QE215ENS",.F.,.F.,{cCodEns,acols[N,nPosEnsR]}) 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o nome do Ensaiador							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	aCols[N,nPosNomEns] := QAA->QAA_APELID
	M->QER_ENSRNO       := aCols[N,nPosNomEns]
	If aCols[N,nPosFilMat] <> xFilial('QAA')
		If !lQipFil
			aCols[N,nPosFilMat] := xFilial('QAA')
			M->QER_FILMAT       := aCols[N,nPosFilMat] 
		Endif	
	EndIf	
EndIf

aOBJETOS[OBJ_MED,nFldLab,nFldEns]:Refresh()

Return(lRetorno)        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215VldDtM³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a validacao do campo data de Medicao				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldDtM(EXPD1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPD1 = Data da Medicao									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID do QER_DTMEDI  									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldDtM(dMedicao)
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Data Medicao/Laudo ‚ >= Data Entrada em Laboratorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(dMedicao) .And. dMedicao < aResultados[nFldLab,_LAU,1] //posicao da data de entrada
	Help(" ",1,"Q215006") 
	lRetorno := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Data Medicao  ‚ >= Data Sistema ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .And.dMedicao > dDataBase
	Help(" ",1,"Q215007") 
	lRetorno := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Data Medicao  ‚ >= Data Entrada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .And. dMedicao < QEK->QEK_DTENTR
	Help(" ",1,"Q215008") 
	lRetorno := .F.
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215VldHrM³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a validacao do campo Hora da Medicao				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldHrM(EXPC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPD1 = Hora da Medicao									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID do QER_HRMEDI  									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldHrM(cHora)
Local lRetorno	  := .T.

cHora := Left(cHora,5)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Hora Medicao ‚ >= Hora Entrada em Laboratorio	   ³
//³ se as datas forem as mesmas									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[N,nPosHorMed] == aResultados[nFldLab,_LAU,2] .And. !Empty(Left(cHora,2)) .And.;
	!Empty(Right(cHora,2)) .And. cHora < aResultados[nFldLab,_LAU,2] //posicao Hora Medicao
	Help(" ",1,"Q215009") 
	lRetorno := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Hora Medicao ‚ >= Hora Entrada, se as datas	   ³
//³ forem as mesmas												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[N,nPosDtaMed] == QEK->QEK_DTENTR .And. !Empty(QEK->QEK_DTENTR) .And.; 
 	cHora < QEK->QEK_HRENTR
	Help(" ",1,"Q215010") 
	lRetorno := .F.
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215HorMed³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a HoRa informada na Medicao se repete		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215HorMed(EXPA1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPA1 = Estrutura do aCols						 	  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPC1 = Hora da Medicao									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_RELACAO do QER_HRMEDI                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215HorMed(aColsMed)
Local cHora := Left(Time(),TamSx3("QER_HRMEDI")[1])
Local nX

If !(AllTrim(ProcName(2)) == "Q215ACOLSMED") //Verifica se a chamada esta sendo efetuada a partir da criacao do aCols
	If aColsMed == NIL
		For nX := 1 to Len(aCols)
			If aCols[nX,nPosDtaMed] == dDataBase
				If Alltrim(aCols[nX,nPosHorMed]) == Alltrim(cHora)
					If TamSx3("QER_HRMEDI")[1] == 8 
						cHora := Left(Q_SomaHora(aCols[nX,nPosHorMed],"00:00:01"),TamSx3("QER_HRMEDI")[1])
					Else
						cHora := Left(Q_SomaHora(aCols[nX,nPosHorMed]+":00","00:01:00"),TamSx3("QER_HRMEDI")[1])
					EndIF			
				EndIf
			EndIf
		Next nX           
	Else
		For nX := 1 to Len(aColsMed)
			If aColsMed[nX,nPosDtaMed] == dDataBase
				If Alltrim(aColsMed[nX,nPosHorMed]) == Alltrim(cHora)  
					If TamSx3("QER_HRMEDI")[1] == 8 
						cHora := Left(Q_SomaHora(aColsMed[nX,nPosHorMed],"00:00:01"),TamSx3("QER_HRMEDI")[1])
					Else
						cHora := Left(Q_SomaHora(aColsMed[nX,nPosHorMed]+":00","00:01:00"),TamSx3("QER_HRMEDI")[1])
					EndIF
				EndIf
			EndIf
		Next nX           
	EndIf
EndIf   

Return(cHora)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215VldAmo³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a validacao do campo Amostragem					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldAmo(EXPN1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Numero de Amostras						 	  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 =  .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID do QER_AMOSTR              						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldAmo(nAmostra)
Local lRetorno := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite somente Amostra SimPles ou Dupla					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(nAmostra == 1 .Or. nAmostra == 2)
	lRetorno := .F.
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215WhnAmo³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define a clausula When para a Amostragem					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215WhnAmo()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_WHEN = QER_AMOSTR					 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215WhnAmo()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Plano de Amostragem Simples assume Amostra 1 def. no Inic. Padrao	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Upper(Left(aResultados[nFldLab,_PAE,nFldEns,1,3],1)) <> "D"
	If aResultados[nFldLab,_PAE,nFldEns,1,3] <> "PI" //Plano de Amostragem Interno
		lRetorno := .F.
	EndIf	
EndIf          

Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215VldPNC³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a validacao do campo Numero Nao Conforme (Carta P) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldPNC(EXPN1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Numero de Unidades nao-conformes					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID do QES_MEDIPN 									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldPNC(nPerNco)
Local lRetorno := .T.
Local nLIETol  := 0
Local nLSETol  := 0
Local aLim	   := {}
Local lMaior   := .F.
Local lAprCon  := .F.
Local nMed	   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza o calculo do Limite Inferior e Superior com tolerancia	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aLim	:= Q215CalLim(cEnsaio)
nLIETol	:= aLim[1]
nLSETol	:= aLim[2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o tamanho e maior que a Amostra							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPerNco > aCols[N,nPosMed]
	Help(" ",1,"Q215011") 
	lRetorno := .F.
EndIf

If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula a Porcentagem Nao Conforme 									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[N,nPosMed+2] := (nPerNco*100)/aCols[N,nPosMed] 
	nMed := aCols[N,nPosMed+2]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza Marca de calculo autom. Porcentagem Nao Conforme 			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[N,nPosCal] := "S"
	M->QES_CALPOR    := "S"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a Porcentagem est  dentro dos limites c/ tolerancia		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nMed > nLSETol .or. nMed < nLIETol
		lMaior := .T.

	Else
		// Verifica se est  fora dos limites, mas dentro da tolerancia
		If nMed < SuperVal(QE7->QE7_LIE) .Or. nMed > SuperVal(QE7->QE7_LSE)
			If nMed >= nLIETol .And. nMed <= nLSETol
				lAprCon := .T.
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Considera "A" - Aprovado 											 ³
	//³ 		 "T" - Aprovado pela tolerancia								 ³
	//³ 		 "R" - Reprovado											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[N,nPosRes] := If(lMaior,"R",If(lAprCon,"T","A"))
	M->QER_RESULT := aCols[N,nPosRes]                       
	
EndIf

Return(lRetorno)            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215WhnPNC³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define a clausula When do campo Num Nao Conforme (Carta P) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215WhnPNC()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_WHEN = QES_MEDIPN 									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215WhnPNC()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao for automatico nao digita unidades das nao-conformidades      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[N,nPosCal] == "N"
	lRetorno := .F.
EndIf
Return(lRetorno)                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215VldPPC³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o Campo Proc. Nao-conforme (Carta P)				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldPPC(EXPN1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Porcentual nao-conforme							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID = QES_MEDIPP (virtual)    						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldPPC(nPerNco)
Local lRetorno	:= .T.
Local nLIETol	:= 0
Local nLSETol	:= 0
Local lMaior	:= .F.
Local lAprCon	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula os limites inferior e superior com a tolerancia 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aLim	:= Q215CalLim(cEnsaio)
nLIETol	:= aLim[1]
nLSETol	:= aLim[2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se e' valida 	 											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPerNco > 100.00
	Help(" ",1,"Q215012") 
	lRetorno := .F.
EndIf

If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza Marca de calculo autom. Porcentagem Nao Conforme 			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[N,nPosCal] := "N"
	M->QES_CALPOR    := "N"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Verifica se a Porcentagem est  dentro dos limites c/ tolerancia		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPerNco > nLSETol .or. nPerNco < nLIETol
		lMaior := .T.
	Else
		// Verifica se est  fora dos limites, mas dentro da tolerancia
		If nPerNco < SuperVal(QE7->QE7_LIE) .Or. nPerNco > SuperVal(QE7->QE7_LSE)
			If nPerNco >= nLIETol .And. nPerNco <= nLSETol
				lAprCon := .T.
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Considera "A" - Aprovado 											 ³
	//³			  "T" - Aprovado pela tolerancia 							 ³
	//³			  "R" - Reprovado 											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[N,nPosRes] := If(lMaior,"R",If(lAprCon,"T","A"))
	M->QER_RESULT    := aCols[N,nPosRes]
	
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215WhnPPC³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define a clausula When do campo Porc Nao-conforme (Carta P)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215WhnPPC()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_WHEN = QES_MEDIPP (virtual)    						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215WhnPPC()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Se for automatico a porcentagem sera calculada 						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[N,nPosCal] == "S"
	lRetorno := .F.
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215CalLim³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o calculo dos Limites de Engenharia				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215CalLim(EXPC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Ensaio									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA1[1] = LIE											  ³±±
±±³			 ³ EXPA1[2] = LSE											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215CalLim(cEnsaio)
Local nPTol	   := 0
Local aRetorno := {}

// Porcentagem de Tolerancia
nPTol := (QE6->QE6_PTOLER/100)

//Pesquisa a especificacao do Ensaio corrente
QE7->(dbSetOrder(1))
QE7->(MsSeek(xFilial("QE7")+QEK->QEK_PRODUT+QEK->QEK_REVI+cEnsaio))

//Formata o numero de casas decimais a ser utilizada
nDecimais := QA_NumDec(QE7->QE7_NOMINA)

If At('i',Lower(QE7->QE7_NOMINA)) > 0
	nLIETol := QA_CalLiPol(QE7->QE7_LIE)
	nLSETol := QA_CalLiPol(QE7->QE7_LSE)
Else
	nLIETol := SuperVal(QE7->QE7_LIE)
	nLSETol := SuperVal(QE7->QE7_LSE)
EndIf

// Limites com tolerancia
Aadd(aRetorno,nLIETol-(nLIETol*nPTol))
Aadd(aRetorno,nLSETol+(nLSETol*nPTol))

Return(aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ Q215PM   ³ Autor ³ Paulo Emidio de Barros³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta a picture para as medicoes, de acordo com o Nominal. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215PM(cCampo) 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do Campo que tera' a picture a ser definida   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215PM(cCampo)
Local cPict := " "
Local cCartEns

If (Alltrim(FunName()) <> "LERDA" .AND. Alltrim(FunName()) <> "EDAPP" )//Nao montar picture quando a chamada for da Consulta Generica (LERDA e EDAPP).
	cCartEns := QA_CartEns(cEnsaio)
	QE7->(dbSetOrder(1))
	QE7->(MsSeek(xFilial("QE7")+QEK->QEK_PRODUT+QEK->QEK_REVI+cEnsaio))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Monta a picture utilizando O valor nominal como referencia 			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCartEns == "P  " //Picture para a Carta do Tipo "P"
		cPict := aHeader[o:ColPos,3]
	ElseIf cCartEns == "TMP" //Picture para a Carta do Tipo "TMP"
		cPict := "@R 999:99"
	Else
		cPict := If(At('i',QE7->QE7_NOMINA)==0,QA_PICT(cCampo,QE7->QE7_NOMINA),"%C")
	EndIf
Endif

Return(cPict)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215VerCal³ Autor ³ Paulo Emidio de Barros³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Consiste as medicoes digitadas							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215VerCal(EXPC1,EXPL1,EXPN1,EXPN2,EXPN3,EXPC2)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Valor da Medicao digitada						  ³±±
±±³			 ³ EXPL1 = Indica se a chamada e proveniente do aCols		  ³±±
±±³			 ³ EXPN1 = Posicao do Laboratorio							  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio								  ³±±
±±³			 ³ EXPN3 = Posicao da linha da Medicao						  ³±±
±±³			 ³ EXPC2 = Ensaio Informado									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VerCal(cMedica,laCols,nPosLab,nPosEns,nPosLin,cEnsInf)
Local nLIETol  := 0
Local nLSETol  := 0
Local nLIE     := 0
Local nLSE     := 0
Local aLim	   := {}
Local nX       := 0
Local nMed	   := 0
Local lErr1    := .F. // Medicao fora do intervalo
Local lErr2    := .F. // Existencia de Nao Conformidades
Local lRetorno := .T.
Local aMediana := {}  // Ser  utilizada no calculo da mediana
Local lAprCond := .F. // Existencia de medicao fora limites mas dentro toler.
Local nTamAmo  := 0
Local nQtdMed  := 0    
Local nPosAtu  := 0     
Local aHeadTmp := {}

DEFAULT laCols := .T.

If laCols
	DEFAULT cMedica := If(ValType(cMedica)=="N",Str(cMedica),cMedica)
	nPosAtu  := aOBJETOS[OBJ_MED,nFldLab,nFldEns]:oBrowse:nColPos
	nPosLab  := nFldLab
	nPosEns  := nFldEns
EndIf	

//Salva a posicao do campo Resultados no aCols
cCarta := aResultados[nPosLab,_ENS,nPosEns,CARTA]
aHeadTmp := aClone(aSavHeadEns[nPosLab,nPosEns])
If cCarta == "TXT"     	
	nPosRes := Ascan(aHeadTmp,{|x|AllTrim(x[2])=="QEQ_RESULT"})
Else
	nPosRes := Ascan(aHeadTmp,{|x|AllTrim(x[2])=="QER_RESULT"})
EndIf

//Define os limites: Inferior e Superior
If At('i',QE7->QE7_NOMINA) > 0
	nLIE := QA_CalLiPol(QE7->QE7_LIE)
	nLSE := QA_CalLiPol(QE7->QE7_LSE)
Else
	nLIE := SuperVal(QE7->QE7_LIE)
	nLSE := SuperVal(QE7->QE7_LSE)
EndIf	

//Calcula os limites: Inferior e Superior com a Tolerancia
aLim	:= Q215CalLim(If(cEnsInf==NIL,cEnsaio,cEnsInf))
nLIETol	:= aLim[1]
nLSETol	:= aLim[2]

//Define o numero de medicoes cadastradas	
nQtdMed	:= Q215QtdMed(If(cEnsInf==NIL,cEnsaio,cEnsInf))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Verifica o Ensaio corrente com carta diferente de "P"				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCarta <> "P  " 

	If !Empty(cMedica)
	
		For nX := nPosMed to (nPosMed+nQtdMed-1)//Quantidade de Medicoes definida na Carta 
			If nQtdMed == 1 
				nMed := If(At('i',cMedica)==0,SuperVal(cMedica),QA_CalLiPol(cMedica))
			Else  
				If laCols                                    
					If nPosAtu == nX
						nMed := If(At('i',cMedica)==0,SuperVal(cMedica),QA_CalLiPol(cMedica))
					Else
						nMed := If(At('i',cMedica)==0,SuperVal(aCols[N,nX]),QA_CalLiPol(aCols[N,nX]))  
					EndIf
				Else
					nMed := SuperVal(aResultados[nPosLab,_MED,nPosEns,nPosLin,nX])	
				EndIf
			EndIf
	
			If cCarta $ "XBRßXBSßINDßHISßTMP&C  "
				If QE7->QE7_MINMAX == "1" //Controla Minimo e Maximo 
					//Verifica os limites da medicao com a Tolerancia
					If nMed > nLSETol .Or. nMed < nLIETol
						lErr1 := .T.
					Else           
						//Verifica se a medicao esta fora do limite, mas dentro da Tolerancia
						If (nMed < nLIE) .Or. (nMed > nLSE)
							If nMed >= nLIETol .And. nMed <= nLSETol
								lAprCond := .T.
							EndIf
						EndIf
					EndIf
	
				ElseIf QE7->QE7_MINMAX == "2" //Controla Minimo e Maximo
					//Verifica se a medicao esta dentro dos limites com a Tolerancia
					If nMed < nLIETol
						lErr1 := .T.
					Else
						//Verifica se esta fora dos limites, mas dentro da Tolerancia
						If nMed < nLIE .And. nMed >= nLIETol
							lAprCond := .T.
						EndIf
					EndIf
	
				ElseIf QE7->QE7_MINMAX == "3" //Controla Maximo
					//Verifica se a medicao esta dentro dos limites com a Tolerancia
					If nMed > nLSETol
						lErr1 := .T.
					Else                    
						//Verifica se a medicao esta fora dos limites, mas dentro da Tolerancia
						If nMed > nLSE .And. nMed <= nLSETol
							lAprCond := .T.
						EndIf
					EndIf
	
				EndIf
	
			ElseIf cCarta == "NP "                                                          
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o Plano de Amostragem definido para o Ensaio					³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(aResultados[nPosLab,_PAE,nPosEns,1,1]) //Tipo do Plano de Amostragem
					nTamAmo := QE1->QE1_QTDE	                                                                               

					//Posiciona na definicao do Plano de Amostragem
					If SubStr(aResultados[nPosLab,_PAE,nPosEns,1,3],1,1) <> "D" //Plano de Amostragem
						nTamAmo := aResultados[nPosLab,_PAE,nPosEns,1,5] //Tamanho da Amostra 1
					Else
						//Verifica o tipo da Amostragem
						If aCols[n,nPosAmo] == 1
							nTamAmo := aResultados[nPosLab,_PAE,nPosEns,1,5] //Tamanho da Amostra 1
						Else
							nTamAmo := aResultados[nPosLab,_PAE,nPosEns,1,8] //Tamanho da Amostra 2
						EndIf
					EndIf
				Else
					nTamAmo := QE1->QE1_QTDE
				EndIf

				//Verifica se as medicoes nao-conformes sao maiores que a Amostra
				If nMed > nTamAmo
					lRetorno := .F.
				Else
					//Verifica se a medicao esta dentro dos limites com a Tolerancia
					If nMed > nLSETol .Or. nMed < nLIETol
						lErr1 := .T.
					Else
						//Verifica se a medicao esta fora dos limites , mas dentro da Tolerancia
						If nMed < nLIE .Or. nMed > nLSE
							If nMed >= nLIETol .And. nMed <= nLSETol
								lAprCond := .T.
							EndIf
						EndIf
					EndIf
				EndIf

			ElseIf cCarta == "U  "                  

				If nX == (nPosMed+1) 
					//Verifica se a medicao esta dentro dos limites com a Tolerancia
					If nMed > nLSETol .Or. nMed < nLIETol
						lErr1 := .T.
					Else
						//Verifica se a medicao esta fora dos limites , mas dentro da Tolerancia
						If nMed < nLIE .Or. nMed > nLSE
							If nMed >= nLIETol .And. nMed <= nLSETol
								lAprCond := .T.
							EndIf
						EndIf
					EndIf
					
				EndIf

			ElseIf cCarta == "XMR"
				Aadd(aMediana,nMed)
	
			EndIf
			
        Next nX

		If cCarta == "XMR"                        
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³	Realiza o calculo da Medidana										 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMed := QA_CALXM(aMediana) 
			If QE7->QE7_MINMAX == "1"  //Controla Minimo e Maximo
				//Verifica se a Mediana esta dentro dos limites com a Tolerancia
				If nMed > nLSETol .Or. nMed < nLIETol
					lErr1 := .T.
				Else
					//Verifica se a Mediana esta fora dos limites, mas dentro da Tolerancia
					If nMed < nLIE .Or. nMed > nLSE
						If nMed >= nLIETol .And. nMed <= nLSETol
							lAprCond := .T.
						EndIf
					EndIf
				EndIf

			ElseIf QE7->QE7_MINMAX == "2" //Controla Minimo
				//Verifica se a Medicana esta dentro dos limites com a Tolerancia
				If nMed < nLIETol
					lErr1 := .T.
				Else
					//Verifica se a Mediana esta fora dos limites, mas dentro da Tolerancia
					If nMed < nLIE .And. nMed >= nLIETol
						lAprCond := .T.
					EndIf
				EndIf

			ElseIf QE7->QE7_MINMAX == "3" //Controla Maximo
				//Verifica se a Mediana esta dentro dos limites com a Tolerancia
				If nMed > nLSETol
					lErr1 := .T.
				Else
					//Verifica se a Mediana esta fora dos limites, amas dentro da Tolerancia
					If nMed > nLSE .And. nMed <= nLSETol
						lAprCond := .T.
					EndIf
				EndIf
			EndIf
		EndIf

		If lRetorno
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³	Atualiza o campo Resultados, sendo: "A" - Aprovado			 	 	 ³
			//³			  						    "T" - Aprovado pela tolerancia	 ³
			//³			  						    "R" - Reprovado					 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If laCols
				aCols[N,nPosRes] := If(lErr1 .Or. lErr2,"R",If(lAprCond,"T","A"))
				M->QER_RESULT    := aCols[N,nPosRes]
			Else
				aResultados[nPosLab,_MED,nPosEns,nPosLin,nPosRes] := If(lErr1 .Or. lErr2,"R",If(lAprCond,"T","A"))
			EndIf
		EndIf
	EndIf                   
	
EndIf

Return(lRetorno)           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215MedLOk³ Autor ³ Paulo Emidio de Barros³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a validacao da linha de digitacao das Medicoes     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ q215MedLOk   											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215MedLOk()
Local lRetorno := .T.                                                
Local cProcura := " "
Local nAchou
Local nPosRes:= 0

If cCarta == "TXT"     	
	nPosRes := Ascan(aHeader,{|x|AllTrim(x[2])=="QEQ_RESULT"})
Else
	nPosRes := Ascan(aHeader,{|x|AllTrim(x[2])=="QER_RESULT"})
EndIf
     
//Nao realiza validação na exclusão                  
If nOpcX == 4
	Return(.T.)
EndIF	

cProcura := dTos(aCols[N,nPosDtaMed])+aCols[N,nPosHorMed]+Str(aCols[N,nPosAmo],1)

//verifica se o item esta deletado
If !aCols[N,Len(aCols[N])]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Verifica se a medicao corrente ja existe							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAchou := Ascan(aCols,{|x|Dtos(x[nPosDtaMed])+x[nPosHorMed ]+Str(x[nPosAmo],1)==;
		cProcura .And. !x[Len(aCols[N])]})
		
	If nAchou > 0 .And. nAchou <> N .And. !Empty(aCols[N,nPosMed])
		Help(" ",1,"Q215013") 
		lRetorno := .F.
	EndIf

	If lRetorno 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³	Verifica se o ensaiador foi digitado								 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aCols[N,nPosEnsR])
			Help(" ",1,"Q215NAOENS")
			lRetorno := .F. 
		Else
			lRetorno := Q215VldEns(aCols[N,nPosEnsR],.t.)	
		EndIf                   

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³	Verifica se a medicao foi digitada									 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aCols[N,nPosMed]) .or. !Q215ChkMed(nFldLab,nFldEns,n,nMedAtu,cCarta,1,.F.,,.T.)                                              
			Help(" ",1,"Q215014")
			lRetorno := .F.
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³	Verifica se o Resultado foi digitado								 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aCols[N,nPosRes])                                              
			Help(" ",1,"Q215015")
			lRetorno := .F.
		EndIf
	EndIf               
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Verifica se as Medicoes em polegadas foram digitadas corretamente	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		If cCarta <> "TXT"          
			If At("i",Lower(QE7->QE7_NOMINA)) <> 0 .And. !Empty(aCols[N,nPosMed])
				If At('i',Lower(aCols[N,nPosMed])) == 0 .And. At('/',Lower(aCols[N,nPosMed])) == 0
					Help(" ",1,"Q215NAOPOL") ///CRIAR HELP
					lRetorno := .F.			
				EndIf	
		    EndIf
		EndIf
	EndIf
	
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215MedTOk³ Autor ³ Paulo Emidio de Barros³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a validacao das linhas de digitacao das Medicoes   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ q215MedTOk   											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215MedTOk()
Local lRetorno := .T.
Local lQE215OK := ExistBlock("QE215OK")
Local cProcura 
Local nAchou
Local nX,ny

//Nao realiza validação na exclusão                  
If nOpcX == 4
	Return(.T.)
EndIF	 

For nX := 1 To Len(aResultados[nFldLab,_ENS])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Identifica a carta utilizada no Ensaio									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCarta   := QA_CartEns(aResultados[nFldLab,_ENS,nX,ENSAIO])
	cEnsaio  := aResultados[nFldLab,_ENS,nX,ENSAIO]	
	aHeadTmp := aClone(aSavHeadEns[nFldLab,nX])	 
			
	If cCarta == "P  "
		nPosMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDIPA"})
	ElseIf cCarta == "TXT"
		nPosMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QEQ_MEDICA"})
	Else
		nPosMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDICA"})
	EndIf                                                         

//			nPosAmo := Ascan(aSavHeadEns,{|x|Alltrim(x[2])=="QER_AMOSTR"})

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o numero de Medicoes cadastradas								³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nY := 1 to Len(aResultados[nFldLab,_MED,nX])
		nDelMed := Len(aResultados[nFldLab,_MED,nX,nY])
		If !aResultados[nFldLab,_MED,nX,nY,nDelMed]    
			If !Empty(aResultados[nFldLab,_MED,nX,nY,nPosMed])                      
				If ( !empty(aResultados[nFldLab,_ENS,nx,FORMUL]) .and. superval(aResultados[nFldLab,_MED,nX,nY,nPosMed]) <> 0) .or. empty(aResultados[nFldLab,_ENS,nx,FORMUL])
				If !(Q215ChkMed(nFldLab,nx,,ny,cCarta,1,.F.,,.T.))
//						Help(" ",1,"Q215014")
						MessageDlg(STR0265+cEnsaio,,3)
					lRetorno:= .F.    
					exit
				Endif
				If Empty(aResultados[nFldLab,_MED,nx,ny,nPosEnsR])
					Help(" ",1,"Q215NAOENS")
					lRetorno := .F.
					Exit
				Endif
			EndIf  
		EndIf
		EndIf
	Next nY 
	If !lRetorno
		exit
	Endif
Next nx

If lQE215OK
	lRetorno := ExecBlock("QE215OK",.F.,.F.)
EndIf

/*
For nX := 1 to Len(aCols)

	If !aCols[nX,Len(aCols[nX])]
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³	Verifica se a medicao corrente ja existe							 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cProcura := dTos(aCols[nX,nPosDtaMed])+aCols[nX,nPosHorMed]+Str(aCols[nX,nPosAmo],1)
		nAchou   := Ascan(aCols,{|x|Dtos(x[nPosDtaMed])+x[nPosHorMed ]+Str(x[nPosAmo],1)==;
			cProcura .And. !x[Len(aCols[nX])]})
			
		If nAchou > 0 .And. nAchou <> nX .And. !Empty(aCols[nX,nPosMed])
			Help(" ",1,"Q215013") 
			lRetorno := .F.
			Exit
		EndIf
	
		If lRetorno 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³	Verifica se o ensaiador foi digitado								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(aCols[nX,nPosEnsR])
				Help(" ",1,"Q215NAOENS")
				lRetorno := .F.
				Exit
			Else
				lRetorno := Q215VldEns(aCols[N,nPosEnsR],.t.)	
				If !lRetorno
					Exit
				EndIF	
			EndIf                   
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³	Verifica se a medicao foi digitada									 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(aCols[nX,nPosMed])                                              
				Help(" ",1,"Q215014")
				lRetorno := .F.
				Exit
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³	Verifica se o Resultado foi digitado								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(aCols[nX,nPosRes])                                              
				Help(" ",1,"Q215015")
				lRetorno := .F.
				Exit
			EndIf
		EndIf
	EndIf
	
Next nX
*/
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215VldEnt³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida campo Data de entrada no Laboratorio.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldEnt(EXPD1,EXPD2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPD1 = data de Entrada no Laboratorio					  ³±±
±±³			 ³ EXPD2 = data do Laudo no Laboratorio						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID = QEL_DTENLA								  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldEnt(dEntLab,dLauLab)
Local lRetorno := .T.
Local nLab           
Local nEns               
Local nMed

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a data de entrada esta vazia					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(dEntLab)
	lRetorno := .T.
Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a data do Laudo e posterior a data de Entrada    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(dLauLab)
		If dEntLab > dDataBase
			Help(" ",1,"Q215016") 
			lRetorno := .F.
		EndIf		
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a data de entrada e maior que a data do sistema  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno 
		If dEntLab > dDataBase
			Help(" ",1,"Q215017") 
			lRetorno := .F.
		EndIf		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a data de entrada e menor que a data da entrada  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		If dEntLab < QEK->QEK_DTENTR
			Help(" ",1,"Q215018") 
			lRetorno := .F.
		EndIf  
	EndIf          
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem medicoes com data anterior a Entrada     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno      
	    If (nFldLab <> nFldLabGer) .And. (nFldLab <> nFldLibCQ0)  
			For nEns := 1 to Len(aResultados[nFldLab,_MED])
				For nMed := 1 to Len(aResultados[nFldLab,_MED,nEns])
					//Posicao data da medicao
					If aResultados[nFldLab,_MED,nEns,nMed,1] < dEntLab
						Help(" ",1,"Q215019") 
						lRetorno := .F.
						Exit
					EndIf		
				Next nMed	
				If !lRetorno
					Exit
				EndIf	                               
			Next nEns 
		Else   
			For nLab := 1 to nQtdLab
				For nEns := 1 to Len(aResultados[nLab,_MED])
					For nMed := 1 to Len(aResultados[nLab,_MED,nEns])
						//Posicao data da medicao
						If aResultados[nLab,_MED,nEns,nMed,1] < dEntLab
							Help(" ",1,"Q215019") 
							lRetorno := .F.
							Exit
						EndIf		
					Next nMed	
					If !lRetorno
						Exit
					EndIf	                               
				Next nEns 
				If !lRetorno
					Exit
				EndIf	                               
			Next nLab              
		EndIf
		
	EndIf
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215VldHor³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a Hora da Entrada no Laboratorio					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldHor(EXPD1,EXPD2)			 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPD1 = Data de Entrada no Laboratorio					  ³±±
±±³			 ³ EXPC1 = Hora de Entrada no Laboratorio					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID = QEL_HRENLA									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldHor(dEntLab,cHorEnt)
Local lRetorno := .T.
Local nLab               
Local nEns
Local nMed

If Empty(dEntLab) .Or. Empty(cHorEnt)
	lRetorno := .T.
Else
	//Realiza a consistencia da Hora digitada
	If !QA_VlHr(cHorEnt,.T.)
		Return(.F.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a data da entrada e igual a entrada no Laborato- ³
	//³ rio para validacao da Hora.									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dEntLab == QEK->QEK_DTENTR               
		If cHorEnt <= QEK->QEK_HRENTR
			Help(" ",1,"Q215020") 
			lRetorno := .F.		
		EndIf		
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem medicoes com data anterior a Entrada     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno                    
		If (nFldLab <> nFldLabGer) .And. (nFldLab <> nFldLibCQ0)  
			For nEns := 1 to Len(aResultados[nFldLab,_MED])
				For nMed := 1 to Len(aResultados[nFldLab,_MED,nEns])
					//Posicao data da medicao
					If aResultados[nFldLab,_MED,nEns,nMed,1] == dEntLab
						//Posicao hora da medicao
						If aResultados[nFldLab,_MED,nEns,nMed,2] < cHorEnt
							Help(" ",1,"Q215021") 
							lRetorno := .F.
							Exit
						EndIf	
					EndIf	
				Next nMed	
				If !lRetorno
					Exit
				EndIf	                               
			Next nEns    
		Else
			For nLab := 1 to nQtdLab
				For nEns := 1 to Len(aResultados[nLab,_MED])
					For nMed := 1 to Len(aResultados[nLab,_MED,nEns])
						//Posicao data da medicao
						If aResultados[nLab,_MED,nEns,nMed,1] == dEntLab
							//Posicao hora da medicao
							If aResultados[nLab,_MED,nEns,nMed,2] < cHorEnt
								Help(" ",1,"Q215021") 
								lRetorno := .F.
								Exit
							EndIf	
						EndIf	
					Next nMed	
					If !lRetorno
						Exit
					EndIf	                               
				Next nEns    
				If !lRetorno
					Exit
				EndIf	                               
			Next nLab
		EndIf
	EndIf

EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215VldLau³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a digitacao do laudo 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldLau(EXPC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 - Laudo do Laboratorio							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 - .T. ou .F. 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID = QEL_LAUDO										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldLau(cLaudo,lChgFld)
Local lRetorno    := .T.
Local nPosLLa     := 0
Local nLauNaoInf  := 0
Local nPosLau     := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_LAUDO"}) 
Local lLauDef     := .F. //Indica que a Entrada nao possui Laudo definido para os Laboratorios
Local lLabSemLau  := .F. //Indica se existe Laboratorio sem Laudo definido   
Local lBloqSemLau := GetMv("MV_QBLQSLA",.F.,.T.)
Local nx, ny, nPosCpo
Local lSemMedic   := .F.
Local lErro       := .F.

Default lChgFld   := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a Validacao apenas para o Laudo Final da Entrada			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nFldLabGer == nFldLab)
	//Verifica se Existe Laudo definido para os laboratorios
	Aeval(Array(nQtdLab),{|x,y|lLauDef:=If(!Empty(aResultados[y,_LAU,nPosLau]),.T.,lLauDef),;
		lLabSemLau:=If(Empty(aResultados[y,_LAU,nPosLau]),.T.,lLabSemLau)})
   
	//Caso nao haja Laudo Definido para os laboratorios, exibe o Help
	If (!Empty(M->QEL_LAUDO) .And. (M->QEL_LAUDO <> cFatLU)) .Or. lChgFld //Nao considera a Liberacao Urgente
	
		If !lLauDef .And. QEK->QEK_VERIFI <> 2 .and. lBloqSemLau
			Help(" ",1,"Q215045")
			lRetorno := .F.
		EndIf
		
		If lLabSemLau 
			If Empty(aResultados[nFldLabGer,_LAUGER,nPosLauGer]) .and. lBloqSemLau
				Help(" ",1,"Q215046") 
				lRetorno := .F.	
			EndIf
		EndIf

    EndIf
Else
	If nFldLab <> nFldLibCQ0
		If !empty(M->QEL_LAUDO)
			For nX := 1 To Len(aResultados[nFldLab,_ENS])
			    lRetorno:=.T.                   
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Identifica a carta utilizada no Ensaio									³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCarta   := QA_CartEns(aResultados[nFldLab,_ENS,nX,ENSAIO])
				cEnsaio  := aResultados[nFldLab,_ENS,nX,ENSAIO]	
				aHeadTmp := aClone(aSavHeadEns[nFldLab,nX])	 
				nQtdMed  := Q215QtdMed(cEnsaio)
				
				If cCarta == "P  "
					nPosMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDIPA"})
				ElseIf cCarta == "TXT"
					nPosMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QEQ_MEDICA"})
				Else
					nPosMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDICA"})
				EndIf                                                         
			
	//			nPosAmo := Ascan(aSavHeadEns,{|x|Alltrim(x[2])=="QER_AMOSTR"})
			
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica o numero de Medicoes cadastradas								³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nY := 1 to Len(aResultados[nFldLab,_MED,nX])
							nDelMed := Len(aResultados[nFldLab,_MED,nX,nY])
							lRetorno:=.T.
							If !aResultados[nFldLab,_MED,nX,nY,nDelMed]    
								nQtdCpo := (nPosMed+nQtdMed-1)
								For nPosCpo:=nposMed To nQtdCpo
									If !Empty(aResultados[nFldLab,_MED,nX,nY,nPosMed])                      
										If (!empty(aResultados[nFldLab,_ENS,nx,FORMUL]) .and. superval(aResultados[nFldLab,_MED,nX,nY,nPosMed]) <> 0) .or. empty(aResultados[nFldLab,_ENS,nx,FORMUL]) .OR. aResultados[nFldLab,_ENS,nx,FORMUL] == STR0250
											If !empty(M->QEL_LAUDO) .and. !(Q215ChkMed(nFldLab,nx,,ny,cCarta,1,.F.,,.T.))
												lRetorno:= .F.
												lErro := .T.    
												//exit
											Endif                 
											If !lRetorno
												//Help(" ",1,"Q215014")
												MessageDlg(STR0265+cEnsaio,,3)//###Existem medições não informadas no ensaio 
												M->QEL_LAUDO:= " "  
												lErro := .T.  
												exit
											Endif
											If Empty(aResultados[nFldLab,_MED,nx,ny,nPosEnsR])
												Help(" ",1,"Q215NAOENS")//Problema: Não existe ensaiador cadastrado com o código informado.
												M-> QEL_LAUDO:= " "     //Solução: Realize a consulta pressionando a tecla F2 sobre o campo "Ensaiador".
												lRetorno := .F.
												lErro := .T.
												Exit
											Endif
										Endif
									/*Else
										lRetorno:= .F.
										M->QEL_LAUDO:= " "
										lSemMedic := .T.*/
									EndIf  
								Next nposcpo//EndIf  
							EndIf
							if !lretorno
								exit
							Endif
						Next nY 
				If !lRetorno
					exit
				Endif
			Next nx
		Endif  
	Endif
	
	//Se Ñ ocorreram erros de negócio, tem linhas sem medição informada e permite linhas sem medição, então continua.
	If !lErro .And. lSemMedic .And. lQEPESM
		lRetorno := .T.
		M->QEL_LAUDO := cLaudo
	EndIf

EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ verifica se o Laudo com Liberacao Urgente foi Alterado				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno	.And.!Empty(cLaudo)
	//Verifica se o Laudo ja estava cadastrado como Liberacao Urgente
	If QEK->QEK_SITENT == "4" 
		If aResultados[nFldLabGer,_LAUGER,nPosLauGer] == cFatLU
			If cLaudo <> cFatLU 
			    nLauNaoInf := 0 
				For nPosLLa := 1 to nQtdLab	
					If Empty(aResultados[nPosLLa,_LAU,nPosLauGer])
						nLauNaoInf++
					EndIf
				Next nPosLLa
				If nLauNaoInf == nQtdLab	
					Help(" ",1,"Q215LIBURG")  
					lRetorno := .F.
			    EndIf
			EndIf
		EndIf	                     
	EndIf
EndIf	

If lRetorno 
	If !Empty(cLaudo)
		If !Empty(M->QEL_DTENLA) .And. !Empty(Left(M->QEL_HRENLA,2)) .And.;
			!Empty(Right(M->QEL_HRENLA,2)) 
			If !ExistCpo("QED",cLaudo)		
				Help(" ",1,"Q215022") 
				lRetorno := .F.	
		    EndIf
		EndIf
	
		//Verifica se o Laudo Informado possui categoria c/ Liberacao Urgente	                   
		If (nFldLab <> nFldLabGer) .And. (nFldLab <> nFldLibCQ0) 
			If lRetorno .And. QIEXLdLU(cLaudo)	
				Help(" ",1,"Q215023") 
				lRetorno := .F.
			EndIf                  
		Else    

			//Definido como Categoria c/ Liberacao Urgente
			If cLaudo ==  cFatLU
				M->QEL_DTLAUD := dDataBase
				M->QEL_HRLAUD := Left(Time(),5)
				M->QEL_LAUDO  := cFatLU
				M->QEL_DTDILA := dDataBase
				M->QEL_HRDILA := Left(Time(),5)
				IF cOrigent == "MATA103"
				   Q215ValLote(.F.)
				Else
					M->QEL_DTVAL := M->QEL_DTLAUD + QAtuShelf(QEK->QEK_PRODUT,QEK->QEK_REVI) 
				Endif
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Sugere a Justificativa do Laudo na Liberacao Urgente	       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				M->QEL_JUSTLA := STR0109 //"Entrada aprovada em regime de Liberacao Urgente"
			EndIf
		
		EndIf
		
		//Descricao do Laudo do Laboratorio       
	    If lRetorno              
			M->QEL_DESLAU := QE215RDL("QED",1,xFilial("QED")+cLaudo)
	    EndIf
	
		If Empty(M->QEL_DTENLA)
			Help(" ",1,"Q215024") 
	      	lRetorno := .F.
	
		Elseif Empty(Left(M->QEL_HRENLA,2)) .And. Empty(Right(M->QEL_HRENLA,2))
			Help(" ",1,"Q215025") 
	      	lRetorno := .F.
	
		Endif
	
		//Verifica as excecoes para edicao da quantidade rejeitada
		If M->QEL_LAUDO $ cFatApr
			M->QEL_QTREJ := Left("0",TamSx3("QEL_QTREJ")[1])
		ElseIf M->QEL_LAUDO == cFatRep
		    M->QEL_QTREJ := M->QEL_TAMLOT
		Else
		    M->QEL_QTREJ := Space(TamSx3("QEL_QTREJ")[1])
	    EndIf
	    
    EndIf
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215VldDlD³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a validacao da data do Laudo						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SIntaxe   ³ Q215VldDlD(EXPD1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPD1 - Data do Laudo								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 - .T. ou .F.								          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID = QEL_DTLAUD									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                      	
Function Q215VldDLd(dLaudo)
Local lRetorno := .T.
Local nLab
Local nEns
Local nMed

If !Empty(dLaudo)

	If Empty(M->QEL_LAUDO)
		Help(" ",1,"Q215026")
		lRetorno := .F.
	Else
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a Data Laudo ‚ >= Data Entrada em Laboratorio ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(M->QEL_DTENLA) .And. dLaudo < M->QEL_DTENLA
			Help(" ",1,"Q215027") 
			lRetorno := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a Data Laudo ‚ >= data do sistema  			  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetorno  .And. dLaudo > dDataBase
			Help(" ",1,"Q215028")
			lRetorno := .F.
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a data do Laudo e maior e/ou igual a data da medicao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetorno
		
		    //Se nao for o Laudo Final da Entrada, verifica o Laboratorio corrente
			If (nFldLab <> nFldLabGer) .And. (nFldLab <> nFldLibCQ0)  
				For nEns := 1 to Len(aResultados[nFldLab,_MED]) //posicao da medicao
					For nMed := 1 to Len(aResultados[nFldLab,_MED,nEns])
						If aResultados[nFldLab,_MED,nEns,nMed,1] > dLaudo
							Help(" ",1,"Q215029") 
							lRetorno := .F.
							Exit
						EndIf			                               
					Next nMed
					If !lRetorno
						Exit
					EndIf	                               
				Next nEns			
			Else     
				//Verifica a data das medicoes em todos os Laboratorios
				For nLab := 1 to (nFldLabGer-1)
					For nEns := 1 to Len(aResultados[nLab,_MED]) //posicao da medicao
						For nMed := 1 to Len(aResultados[nLab,_MED,nEns])
							If aResultados[nLab,_MED,nEns,nMed,1] > dLaudo
								Help(" ",1,"Q215029")
								lRetorno := .F.
								Exit
							EndIf			                               
						Next nMed
						If !lRetorno
							Exit
						EndIf	                               
					Next nEns			
					If !lRetorno
						Exit
					EndIf	                               
				Next nLab
			EndIf
		EndIf
	EndIf
EndIf          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza o calculo do Shelf-Life								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFldLab == nFldLabGer
	If cOrigent == "MATA103"
		Q215ValLote(.F.)
	Else
	M->QEL_DTVAL := M->QEL_DTLAUD + QAtuShelf(QEK->QEK_PRODUT,QEK->QEK_REVI) 
	Endif
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215VldHld³ Autor ³ Paulo Emidio de Barros³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a Validacao da Hora do Laudo						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215VldHld(EXPC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Hora do Laudo									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID = HRLAUD										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldHld(cHora)
Local lRetorno := .T.
Local nEns
Local nMed
Local nLab                                             

If Empty(M->QEL_DTLAUD)
	Help(" ",1,"Q215030")
	lRetorno := .F.
EndIf                   

//Realiza a consistencia da Hora digitada
If !QA_VlHr(cHora,.T.)
	Return(.F.)
EndIf

If lRetorno .And. !Empty(Left(cHora,2)) .And. !Empty(Right(cHora,2))
	cHora := StrZero(Val(Left(cHora,2)),2)+":"+StrZero(Val(Right(cHora,2)),2)
   
	If (M->QEL_DTLAUD == M->QEL_DTENLA) .And.; 
		!Empty(M->QEL_DTENLA) .And. cHora < M->QEL_HRENLA	
		Help(" ",1,"Q215031") 
		lRetorno := .F.                                                       
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe medicoes na data do Laudo com Hora superior³
		//³ a informada no Laudo										  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Laboratorio corrente
		If (nFldLab <> nFldLabGer) .And. (nFldLab <> nFldLibCQ0)  
			For nEns := 1 to Len(aResultados[nFldLab,_MED]) 
				For nMed := 1 to Len(aResultados[nFldLab,_MED,nEns])
					If aResultados[nFldLab,_MED,nEns,nMed,1] == M->QEL_DTLAUD .And.;
						aResultados[nFldLab,_MED,nEns,nMed,2] > cHora
						Help(" ",1,"Q215032") 
						lRetorno := .F.
						Exit
					EndIf		   
				Next nMed
				If !lRetorno
					Exit
				EndIf	                               
			Next nEns                
		Else	              
			//Considera todos os Laboratorios
			For nLab := 1 to(nFldLabGer-1)
				For nEns := 1 to Len(aResultados[nLab,_MED]) 
					For nMed := 1 to Len(aResultados[nLab,_MED,nEns])
						If aResultados[nLab,_MED,nEns,nMed,1] == M->QEL_DTLAUD .And.;
							aResultados[nLab,_MED,nEns,nMed,2] > cHora
							Help(" ",1,"Q215032") 
							lRetorno := .F.
							Exit
						EndIf		   
					Next nMed
					If !lRetorno
						Exit
					EndIf	                               
				Next nEns                
				If !lRetorno
					Exit
				EndIf	                               
			Next nLab
		EndIf
	EndIf 
	     
	//Devolve a hora formatada
	If lRetorno
		M->QEL_HRLAUD := cHora
	EndIf	
	
EndIf              

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215VldRej³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a validacao da Quantidade Rejeitada				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SIntaxe   ³ Q215VldRej(EXPC1)									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Quantidade rejeitada								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID = QEL_QTREJ										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldRej(cQtdRej)
Local lRetorno := .T.

If !Empty(cQtdRej)  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o valor digitado e um numero valido				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !QA_VerNum(@cQtdRej)
		Help(" ",1,"Q215033") 
		lRetorno := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a quantidade rejeitada ‚ <= Tamanho do Lote		    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		If SuperVal(cQtdRej) > (SuperVal(M->QEL_TAMLOT)-SuperVal(M->QEL_QTDEST))
			Help(" ",1,"Q215034") 
			lRetorno := .F.
		Else
			//Retorna a quantidade formatada
			M->QEL_QTREJ := cQtdRej
		EndIf
	EndIf
Endif

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215VldDvl³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a validacao da Data de validade do Laudo			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215VldDvl(EXPD1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPD1 = Data de Validade do Laudo 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID = QEL_DTVAL										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldDvL(dValLau)
Local lRetorno  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se os campos referentes ao Laudo foram preenchidos		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(dValLau)
	If !Empty(M->QEL_DTLAUD) .And. !Empty(Left(M->QEL_HRLAUD,2)) .And.;
		!Empty(Right(M->QEL_HRLAUD,2)) .And. 	!Empty(M->QEL_DTENLA) .And.;
		!Empty(Left(M->QEL_HRENLA,2)) .And. !Empty(Right(M->QEL_HRENLA,2)) .And.;
		!Empty(M->QEL_LAUDO)
		
		If  dValLau < M->QEL_DTLAUD
			Help(" ",1,"Q215035") 
			M->QEL_DTVAL := CTOD(" / / ")
			lRetorno := .F.
		EndIf
	Else
		Help(" ",1,"Q215036") 
		M->QEL_DTVAL := CTOD(" / / ")
		lRetorno := .F.
	Endif
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215VldTLo³ Autor ³Paulo Emidio de Barros	³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a validacao do tamanho do Lote					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SIntaxe   ³ Q215VldTlo(EXPC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Tamanho do Lote									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID = QEL_TAMLOT 									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldTLo(cTamLot)
Local lRetorno := .T.

If !Empty(cTamLot)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Tamanho do Lote e um numero valido				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !QA_VerNum(@cTamLot)
		Help(" ",1,"Q215033") 
		lRetorno := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Tam. Lote Laborat. <= Tam. Lote Entrada 			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. SuperVal(cTamLot) > SuperVal(QEK->QEK_TAMLOT)
		Help(" ",1,"Q215037") 
		lRetorno := .F.
	EndIf               
Endif

Return(lRetorno)                         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215VldDiL³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a validacao da Data de disponibilidade do Laudo	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldDiL(EXPD1)							  		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPD1 = Data de disponibilidade do Laudo					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 .T. Ou .F.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID = QEL_DTDILA									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldDiL(dDisLau)
Local lRetorno := .T.

If !Empty(dDisLau)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Data Validade/Disponibilidade do Laudo ‚ >= Data Laudo   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
	If !Empty(M->QEL_DTLAUD) .And. !Empty(Left(M->QEL_HRLAUD,2)) .And.;
		!Empty(Right(M->QEL_HRLAUD,2)) .And. !Empty(M->QEL_DTENLA) .And.;
		!Empty(Left(M->QEL_HRENLA,2)) .And. !Empty(Right(M->QEL_HRENLA,2)) .And.;
		!Empty(M->QEL_LAUDO)
		
		If dDisLau < M->QEL_DTLAUD
			Help(" ",1,"Q215038") 
			lRetorno := .F.
		EndIf
	Else                         
		Help(" ",1,"Q215039") 
		lRetorno := .F.
	Endif
Endif
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215VldHiL³ Autor ³Paulo Emidio de Barros	³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a validacao da Hora de disponibilidade do Laudo     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldHiL(EXPC1)									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Hora de disponibilidade do Laudo					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.				 						  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID = QEL_HRDILA								      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldHiL(cHorDisLau)
Local lRetorno := .T.

//Realiza a consistencia da Hora digitada
If !QA_VlHr(cHorDisLau,.T.)
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Hora Disponibilidade ‚ >= Hora Laudo quando as datas     ³
//³ forem iguais.														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
If !Empty(Left(cHorDisLau,2)) .And. !Empty(Right(cHorDisLau,2))
	If !Empty(M->QEL_DTLAUD) .And. !Empty(Left(M->QEL_HRLAUD,2)) .And. !Empty(Right(M->QEL_HRLAUD,2)) .And.;
		!Empty(M->QEL_DTENLA) .And. !Empty(Left(M->QEL_HRENLA,2)) .And. !Empty(Right(M->QEL_HRENLA,2)) .And.;
		!Empty(M->QEL_LAUDO) .And. !Empty(M->QEL_DTDILA)
		If M->QEL_DTDILA == M->QEL_DTLAUD .And. cHorDisLau < M->QEL_HRLAUD
			Help(" ",1,"Q215040") 
			lRetorno := .F.
		EndIf
	Else 
		Help(" ",1,"Q215041")
		lRetorno := .F.
	Endif
Endif

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215VldJLL³ Autor ³Paulo Emidio de Barros	³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a validacao da Justificativa do Laudo 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldJLL(EXPC1)							  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Justificativa do Laudo (Laboratorio/Entrada)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.				 						  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID = QEL_JUSTLA									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldJLL(cJusLau)
Local lRetorno := .T.

If Empty(cJusLau)
	Help(" ",1,"Q215042")  
	lRetorno := .F.
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215WhnLau³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define a clausula When para os dados do Laudo			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215WhnLau(EXPO1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto do campo editado						  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_WHEN = QEL_DTLAUD/QEL_HRLAUD/QEL_DTDILA/QEL_HRDILA      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215WhnLau(oGet)
Local lRetorno := .T.  

//Verifica os campos validos para a consistencia
If !(ReadVar() $ "M->QEL_DTLAUD/M->QEL_HRLAUD/M->QEL_DTDILA/M->QEL_HRDILA")
    Return(lRetorno)
EndIf                    

//Verifica se a Pasta corrente esta focada
If !oGet:lVisible 
	Return(lRetorno)
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Laudo da Entrada sera calculado autolmaticamente		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
If nFldLabGer == nFldLab                                                  
	If !lLauDig //Verifica se o Laudo sera digitado pelo usuario
		lRetorno := .F.                                                   
	EndIf
EndIf                  

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215WhnQRe³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define a clausula When a Quantidade rejeitada		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215WhnQRe(EXPO1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto do campo editado						  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_WHEN = QEL_QTREJ										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215WhnQRe(oGet)
Local lRetorno := .T.  

If ReadVar() <> "M->QEL_QTREJ"
	Return(lRetorno)
EndIf	

//Verifica se a Pasta corrente esta focada
If !oGet:lVisible 
	Return(lRetorno)
EndIf

//Verifica se o Laudo da Entrada sera calculado automaticamente		   ³
If nFldLabGer == nFldLab                                                  
	If !lLauDig //Verifica se o Laudo sera digitado pelo usuario
		lRetorno := .F.                                                   
	EndIf
EndIf                                     

If lRetorno
	If !Empty(M->QEL_LAUDO)
   		//Verifica se o Laudo esta aprovado
	   If M->QEL_LAUDO $ cFatApr .Or. M->QEL_LAUDO == cFatRep .Or.;
		  M->QEL_LAUDO == cFatLU	   	
	      lRetorno := .F.
    	EndIf
	EndIf      
EndIf

Return(lRetorno)        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215WhnDvL³ Autor ³ Paulo Emidio de Barros³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define o When da Data de Validade do Laudo				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215WhnDvl(EXPO1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto do campo editado                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_WHEN = QEL_DTVAL										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215WhnDvl(oGet)
Local lRetorno     

If ReadVar() <> "M->QEL_DTVAL"
	Return(.T.)
EndIf	

//Verifica se a Pasta corrente esta focada
If !oGet:lVisible 
	Return(.T.)
EndIf

//Somente disponivel para o Laudo Final da Entrada	
If (nFldLab == nFldLabGer)
	lRetorno := .T.
Else	
	lRetorno := .F.
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215WhnLdo³ Autor ³ Paulo Emidio de Barros³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define o When do Laudo do Laboratorio/Entrada			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215WhnLdo(EXPO1)	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto do campo editado                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_WHEN = QEL_LAUDO										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215WhnLdo(oGet)
Local lRetorno := .T.
Local nLab 	   := 0
Local nEns 	   := 0
Local nMed 	   := 0 
Local aRetIns  := {}
                      
If ReadVar() <> "M->QEL_LAUDO"
	Return(lRetorno)
EndIf	

//Controla a inibição da digitação da aprovação do laudo de laboratorio
If ExistBlock("QE215BL") 
	if !ExecBlock("QE215BL",.F.,.F.) 
		return(.F.)
	EndIf	
EndIf
//Verifica se a Pasta corrente esta focada	
If !oGet:lVisible 		
	If !lLauDig 
		lRetorno := .F.
	EndIf
	Return(lRetorno)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ verifica se o Laudo sera sugerido, caso seja informado manualmente  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lSugLau          
	If !Empty(M->QEL_LAUDO)
		Return(lRetorno)
    EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Laudo do Laboratorio											    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nFldLabGer <> nFldLab) .And. (nFldLab <> nFldLibCQ0)    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Laudo Final da Entrada foi informado, se sim o Laudo  ³
	//³ do Laboratorio nao podera ser alterado.							    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aResultados[nFldLabGer,_LAUGER,nPosLauGer])
		Help(" ",1,"Q215043") 
		Return(.F.)
	EndIf
	
	aRetIns := Q215VerIns("L") 
   
    If aRetIns[1]  
	
		//Compara as medicoes do Laboratorio com o Plano de Amostragem         
		IF !Q215PlaAmo(.T.)          
			Return(.F.)
		Endif

  		//Realiza a sugestao do calculo do Laudo do Laboratorio							 
		If ExistBlock("QE215LL") 
			ExecBlock("QE215LL",.F.,.F.) 
	   	Else
			Q215CalLab()
    	EndIf
    Else 
   		MsgAlert(aRetIns[2])
		Return(.F.)
    EndIF	

Else               
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Laudo Final da Entrada												³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetIns := Q215VerIns("T") 
   If aRetIns[1]  
    
		//Verifica se o usuario possui nivel de acesso permitido
		If lLauDig 
			lRetorno := QA_NivAces(100,STR0110) //"O Usuario nao possui nivel de acesso para definir o Laudo Final da Entrada"
			IIF (!lRetorno .And. !empty (M->QEL_LAUDO), M->QEL_LAUDO:= " ",Nil)
		EndIf                                      

   		If lRetorno 
			//Calcula o Laudo Final da Entrada
			If aResultados[nFldLabGer,_LAUGER,nPosLauGer] <> cFatLU .Or. Empty(cFatLu)
			    lRetorno := Q215LauEnt()
			EndIf    
		EndIf     

		//Verifica se o Laudo Final sera digitado pelo usuario
		If !lLauDig 
			lRetorno := .F.	
		EndIf	

		//Sugere a data do Laudo Final, de acordo com a ultima medicao no ultimo ensaio
		//Informado pelo usuario
		nLab := nQtdLab	
		nEns := Len(aResultados[nLab,_MED]	)
		nMed := Len(aResultados[nLab,_MED,nEns])	
	
		If aResultados[nLab,_MED,nEns,nMed,1] < dDataBase //Data da Medicao	
			M->QEL_DTLAUD := dDataBase                                   
		Else
		    M->QEL_DTLAUD := aResultados[nLab,_MED,nEns,nMed,1]
		EndIf                                                           
	
		If cOrigEnt == "MATA103"
			Q215ValLote(.F.)
		Else
			If M->QEL_DTVAL < M->QEL_DTLAUD                                 
				M->QEL_DTVAL := dDataBase + QAtuShelf(QEK->QEK_PRODUT,QEK->QEK_REVI)                                    
			EndIf	    
		Endif 
		M->QEL_NISERI := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF 
		M->QEL_TIPONF := QEK->QEK_TIPONF
	Else
   		MsgAlert(aRetIns[2])
		Return(.F.)
	EndIf	

EndIf                   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a sugestao dos Laudos foram alteradas 					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aLauAnt[nFldLab,1])     
	If (M->QEL_LAUDO <> aLauAnt[nFldLab,1]) 
		aLauAnt[nFldLab,1] := M->QEL_LAUDO
		aLauAnt[nFldLab,2] := M->QEL_JUSTLA
	EndIf                        
EndIf                

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe os Ensaios que nao possuem medicoes informadas				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lEnsMed .And. !lQEPESM//Define se PERMITE ensaios sem medições nos Laudos do módulo de Inspeção de Entradas.	                                          
	Q215VerEns()
EndIf	

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215WhnQDe³ Autor ³ Paulo Emidio de Barros³ Data ³20/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define o When da Quantidade a ser destruida			  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215WhnQDes(EXPO1)	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto do campo editado                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X3_WHEN = QEL_QTDEST										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215WhnQDes(oGet)
Local lRetorno := .T.
  
If ReadVar() <> "M->QEL_QTDEST"
	Return(lRetorno) 
EndIf	

//Verifica se a Pasta corrente esta focada
If !oGet:lVisible 
	Return(lRetorno)
EndIf                      

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215LauEnt³ Autor ³ Paulo Emidio de Barros³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza o Calculo do Laudo da Entrada					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215LauEnt()	                    		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum							 						  ³±±                        
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215LauEnt()
Local nX 
Local nPosLau    := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_LAUDO"}) 
Local cLabora    := " "
Local cMsgLau    := " "
Local lRepLau    := .F.
Local lAprCon    := .F.
Local lRetorno   := .T.    
Local lInspecna  := .T.
Local cLaudoCond := " "
Local cLaudoApr  := " "
Local cQeJusla   := SuperGetMv("MV_QEJUSLA")

IIF(EMPTY(cFatApc),cFatApc := " ",nil)

For nX := 1 to nQtdLab //Menos a posicao do Laudo Geral da Entrada
	cLabora := aResultados[nX,_LAB]     //Laboratorio corrente

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica os Laudos informados nos Laboratorios						   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
	If !Empty(aResultados[nX,_LAU,nPosLau]) //Posicao do campo QEL_LAUDO	
		If aResultados[nX,_LAU,nPosLau] == cFatRep
			lRepLau := .T.
			cMsgLau := STR0111+cLabora //"O Laudo da Entrada devera ser Reprovado em funcao do Laudo do Laboratorio: "
	    	Exit
		ElseIf !(aResultados[nX,_LAU,nPosLau] $ cFatApr)	
			lAprCon := .T.
			If cLaudoCond <> SubStr(cFatApc,Len(cFatApc),1) // Verificar laudos condicionais de laboratorio para calcular laudo geral correto
				If aResultados[nX,_LAU,nPosLau] $ cFatApc
					If Empty(cLaudoCond)
						cLaudoCond := aResultados[nX,_LAU,nPosLau]
						cMsgLau := STR0112+cLabora //"O Laudo da Entrada devera ser Aprovado Condicional em funcao do Laudo do laboratorio: "
					Else
						//Utilizar menor fator de aprovacao de laboratorio para o Laudo Geral, porem manter fator caso nao encontre nenhum menor
						If Val(Alltrim(StrTran(Posicione("QED",1,xFilial("QED")+aResultados[nX,_LAU,nPosLau],"QED_FATOR"),',','.'))) <; 
						Val(Alltrim(StrTran(Posicione("QED",1,xFilial("QED")+cLaudoCond,"QED_FATOR"),',','.'))) 
							cLaudoCond := aResultados[nX,_LAU,nPosLau]
							cMsgLau := STR0112+cLabora //"O Laudo da Entrada devera ser Aprovado Condicional em funcao do Laudo do laboratorio: "
						Endif
					Endif					
				Else
					cLaudoCond := SubStr(cFatApc,Len(cFatApc),1)
					cMsgLau := STR0112+cLabora //"O Laudo da Entrada devera ser Aprovado Condicional em funcao do Laudo do laboratorio: "
				Endif
			Endif
		Else
			cLaudoApr := aResultados[nX,_LAU,nPosLau]
		EndIf	      
	EndIf             
	
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o Laudo for sugerido como Liberacao Urgente, devera ser digitado a  ³
//³ justificativa do mesmo 												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
If lLiberaUrg                
	Help(" ",1,"Q215044") 
EndIf                                                                       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sugere o Laudo da Entrada 											   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
If lRetorno
	If !Empty(cMsgLau)
		MessageDlg(cMsgLau,,3)
	EndIf                                
	
	//Caso seja sugerido a Liberacao Urgente	
	If lLiberaUrg 
		M->QEL_LAUDO := cFatLU
	Else
		M->QEL_LAUDO := Iif(lRepLau,cFatRep,Iif(lAprCon,cLaudoCond,cLaudoApr))
	EndIf
	M->QEL_DESLAU := QE215RDL("QED",1,xFilial("QED")+M->QEL_LAUDO)
	M->QEL_HRLAUD := Left(Time(),5)
	M->QEL_DTDILA := dDataBase
	M->QEL_HRDILA := Left(Time(),5)
	M->QEL_NOMRES := QA_NUSR(,,.F.,"N")
	
	If M->QEL_LAUDO == cFatRep
		M->QEL_QTREJ := M->QEL_TAMLOT
	ElseIf M->QEL_LAUDO $ cFatApr
		M->QEL_QTREJ := Left("0",TamSx3("QEL_QTREJ")[1])
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o Fornecedor for certificado em regime de Skip-Lote, sugere a justi-³
	//³ ficativa do Laudo da Entrada.										   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(M->QEL_LAUDO) .And. (M->QEL_LAUDO $ cFatApr)     
		If QEK->QEK_VERIFI == 2  
			If lInsAmoIni
				QE7->(dbSetOrder(4))
				If QE7->(MsSeek(xFilial("QE7")+QEK->QEK_PRODUT+QEK->QEK_REVI))
					While QE7->(!Eof()) .And. (QE7->QE7_FILIAL+QE7->QE7_PRODUT+QE7->QE7_REVI) ==;
						(xFilial("QE7")+QEK->QEK_PRODUT+QEK->QEK_REVI)
						If QE7->QE7_AM_INS == "1" //Amostra Inicial
							lInspecna := QieAmoIni(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QEK->QEK_IDEINV)
							If !lInspecna
								M->QEL_JUSTLA := STR0260 //"Laudo aprovado em funcao de outra Amostra inicial"
							Else
								M->QEL_JUSTLA := cQeJusla									
							Endif	
						Else
							M->QEL_JUSTLA := cQeJusla				
						Endif	
						QE7->(dbSkip())
					Enddo	
				Endif	
				QE8->(dbSetOrder(4))
				If QE8->(MsSeek(xFilial("QE8")+QEK->QEK_PRODUT+QEK->QEK_REVI))
					While QE8->(!Eof()) .And. (QE8->QE8_FILIAL+QE8->QE8_PRODUT+QE8->QE8_REVI) ==;
						(xFilial("QE8")+QEK->QEK_PRODUT+QEK->QEK_REVI)
						If QE8->QE8_AM_INS == "1" //Amostra Inicial
							lInspecna := QieAmoIni(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QEK->QEK_IDEINV)
							If !lInspecna
								M->QEL_JUSTLA := STR0260 //"Laudo aprovado em funcao de outra Amostra inicial"
							Else
								M->QEL_JUSTLA := cQeJusla									
							Endif	
						Else
							M->QEL_JUSTLA := cQeJusla				
						Endif	
						QE8->(dbSkip())
					Enddo				
				Endif	
			Else
			   M->QEL_JUSTLA := cQeJusla
		    Endif	   
		EndIf                      
	EndIf
	
EndIf                                                          

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Q215PlaAmo³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se todas as medicoes necessarias foram digitadas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215PlaAmo(EXPL1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPL1 = Indica se o Laudo e o da Entrada					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL2 = .T.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA215                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215PlaAmo(lVerifica)
Local cLabora  := " " 
Local nX 	   := 0
Local nY 	   := 0
Local nZ 	   := 0
Local nMedAmo1 := 0
Local nMedAmo2 := 0
Local cCarta   := " "
Local cEnsaio  := " "
Local aHeadTmp := {}
Local aAmos    := {}
Local nPosMed  := 0
Local nPosAmo  := 0
Local nDelMed  := 0
Local aMedObr  := {}
Local aMedSup  := {}
Local aTitulos := {}
Local aBlock   := {}
Local oBrwPln  := {}          
Local oDlg	
Local oSay 
Local oBotao                
Local aAreaQE7 := QE7->(GetArea())
Local aAreaQE8 := QE8->(GetArea())
Local aAreaAnt := GetArea()
Local nQtdMed  := 0  
Local lBloqPl  := If(GetMv("MV_QBLQPLA",.F.,"2") == "2",.F.,.T.)
Local lRet     := .T.
Local nTamAmo  := 0      
Local lVldDlg	 := .F.                  



If lVerifica
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Laudo corrente e o Final									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nFldLabGer == nFldLab                                                  
		Return(.T.)
	EndIf       
	
EndIf

cLabora := aResultados[nFldLab,_LAB] //Laboratorio corrente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica todos os ensaios associados ao Laboratorio						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aResultados[nFldLab,_ENS])

	nMedAmo1 := 0                             
	nMedAmo2 := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Identifica a carta utilizada no Ensaio									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCarta   := QA_CartEns(aResultados[nFldLab,_ENS,nX,ENSAIO])
	cEnsaio  := aResultados[nFldLab,_ENS,nX,ENSAIO]	
	aHeadTmp := aClone(aSavHeadEns[nFldLab,nX])	 
	nQtdMed  := Q215QtdMed(cEnsaio)
	
	If cCarta == "P  "
		nPosMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDIPA"})
	ElseIf cCarta == "TXT"
		nPosMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QEQ_MEDICA"})
	Else
		nPosMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDICA"})
	EndIf                                                         

	nPosAmo := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_AMOSTR"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna os dados do Plano de Amostragem									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAmos := {}
	If !Empty(aResultados[nFldLab,_PAE,nX,1,1]) //Tipo do Plano de Amostragem
	
		Aadd(aAmos,aResultados[nFldLab,_PAE,nX,1,03]) //Plano de Amostragem
		Aadd(aAmos,aResultados[nFldLab,_PAE,nX,1,05]) //Tamanho da primeira amostra 
		Aadd(aAmos,aResultados[nFldLab,_PAE,nX,1,06]) //Aceite da primeira amostra
		Aadd(aAmos,aResultados[nFldLab,_PAE,nX,1,07]) //Rejeite da primeira amostra
		Aadd(aAmos,aResultados[nFldLab,_PAE,nX,1,08]) //Tamanho da segunda amostra
		Aadd(aAmos,aResultados[nFldLab,_PAE,nX,1,09]) //Aceite da segunda amostra
		Aadd(aAmos,aResultados[nFldLab,_PAE,nX,1,10]) //Rejeite da segunda amostra
		Aadd(aAmos,cEnsaio)							   //Ensaio
	
		If Alltrim(cCarta) $ "NP/P/C/U/TXT"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o numero de Medicoes cadastradas								³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nY := 1 to Len(aResultados[nFldLab,_MED,nX])
				nDelMed := Len(aResultados[nFldLab,_MED,nX,nY])
				If !aResultados[nFldLab,_MED,nX,nY,nDelMed]    
					If !Empty(aResultados[nFldLab,_MED,nX,nY,nPosMed])    
						If aResultados[nFldLab,_MED,nX,nY,nPosAmo]==1 //Amostra 1   						     
							nMedAmo1++
						Else
							nMedAmo2++
						EndIf
					EndIf
				EndIf
			Next nY
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o numero de Medicoes cadastradas								³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nY := 1 to Len(aResultados[nFldLab,_MED,nX])
				nDelMed := Len(aResultados[nFldLab,_MED,nX,nY])
				If !aResultados[nFldLab,_MED,nX,nY,nDelMed]    
				
					If !Empty(aResultados[nFldLab,_MED,nX,nY,nPosMed])    
						If aResultados[nFldLab,_MED,nX,nY,nPosAmo]==1 //Amostra 1   						     
							nMedAmo1++
						Else
							nMedAmo2++
						EndIf
					EndIf  
						
				EndIf
			Next nY
		EndIf
    EndIf
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Compara O Numero de Resultados com a Amostragem							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aAmos) > 0  
		If !Empty(aAmos[1])        
		
			//Plano de Amostragem Simples, QS9000 ou Texto
			If Left(aAmos[1],1) <> "D"	
				//Verifica o Tamanho da Amostra Simples
				If (nMedAmo1 < aAmos[2]) //.Or. (nMedAmo1 > aAmos[2]) 
					Aadd(aMedObr,{cLabora,cEnsaio,Str(aAmos[2],4),Str(nMedAmo1,3),"1"}) 
					nTamAmo:= aAmos[2]
				Elseif (nMedAmo1 > aAmos[2])
					Aadd(aMedSup,{cLabora,cEnsaio,Str(aAmos[2],4),Str(nMedAmo1,3),"1"}) 
				EndIf   
				
			Else		
			    //Verifica o Tamanho da Amostra Dupla
				If (nMedAmo1+nMedAmo2) < aAmos[5] //.Or. (nMedAmo1+nMedAmo2) > aAmos[5]	
					Aadd(aMedObr,{cLabora,cEnsaio,Str(aAmos[5],4),Str(nMedAmo1+nMedAmo2,3),"2"})
					nTamAmo:= aAmos[5]    
				Elseif (nMedAmo1+nMedAmo2) > aAmos[5]
					Aadd(aMedSup,{cLabora,cEnsaio,Str(aAmos[5],4),Str(nMedAmo1+nMedAmo2,3),"2"}) 
				
				EndIf
			EndIf
			
		EndIf
	EndIf

Next 
	
If Len(aMedObr) <> 0        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a Tela com as informacoes sobre o numero das medicoes				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg FROM 10,10 TO 24,50
	@ 003, 005 SAY oSay PROMPT STR0113 OF oDlg PIXEL SIZE 150,030  //"Ensaios com no. de medicoes inferior ao previsto no Plano de Amostragem" 

	aTitulos := {STR0114,STR0115,STR0116,STR0117,STR0118} //"Laboratorio" ### "Ensaio" ### "Necessario" ### "Digitado" ### "Amostragem"
	aBlock   := {||{ " "," "," "," "," " }}
	oBrwPln  := TWBrowse():New(026,005,150,057,aBlock,aTitulos,{60,60,57,57,45},;
		oDlg,,,,,,,,,,,,,,.T.,,,,,)
	oBrwPln:SetArray(aMedObr)
	oBrwPln:bLine := {||{aMedObr[oBrwPln:nAt,1],aMedObr[oBrwPln:nAt,2],aMedObr[oBrwPln:nAt,3],aMedObr[oBrwPln:nAt,4],aMedObr[oBrwPln:nAt,5]}}

	@ 090, 115 BUTTON oBotao PROMPT STR0119 OF oDlg PIXEL ACTION (lVldDlg:=.T.,Iif(lBloqPl,(messagedlg(STR0268,,3),lRet:= .F.),lRet:= .T.),oDlg:End()) SIZE 035,011 //"Retorna" # "O laudo não poderá ser informado devido a configuração do parâmetro MV_QBLQPLA e haver Ensaios com no. de medicoes inferior ao previsto no Plano de Amostragem"
	ACTIVATE MSDIALOG oDlg CENTERED VALID lVldDlg
Endif
If Len(aMedSup) <> 0        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a Tela com as informacoes sobre o numero das medicoes				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg FROM 10,10 TO 24,50
	@ 003, 005 SAY oSay PROMPT STR0263 OF oDlg PIXEL SIZE 150,030  //"Ensaios com no. de medicoes superior ao previsto no Plano de Amostragem" 

	aTitulos := {STR0114,STR0115,STR0116,STR0117,STR0118} //"Laboratorio" ### "Ensaio" ### "Necessario" ### "Digitado" ### "Amostragem"
	aBlock   := {||{ " "," "," "," "," " }}
	oBrwPln  := TWBrowse():New(026,005,150,057,aBlock,aTitulos,{60,60,57,57,45},;
		oDlg,,,,,,,,,,,,,,.T.,,,,,)
	oBrwPln:SetArray(aMedSup)
	oBrwPln:bLine := {||{aMedSup[oBrwPln:nAt,1],aMedSup[oBrwPln:nAt,2],aMedSup[oBrwPln:nAt,3],aMedSup[oBrwPln:nAt,4],aMedSup[oBrwPln:nAt,5]}}    

	@ 090, 115 BUTTON oBotao PROMPT STR0119 OF oDlg PIXEL ACTION (Iif(lBloqPl,lRet:= .F.,lRet:= .T.),oDlg:End()) SIZE 035,011 //"Retorna"
	ACTIVATE MSDIALOG oDlg CENTERED 
EndIf

RestArea(aAreaQE7)
RestArea(aAreaQE8)         
RestArea(aAreaAnt)

Return(lRet)                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215CalLab³ Autor ³ Paulo Emidio de Barros³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Calcula o Laudo do Laboratorio							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215CalLab(EXPL1,EXPC1,EXPN1)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPL1 = Indica se o Laudo do Laboratorio sera atualizado   ³±±
±±³			 ³ EXPC1 = Posicao do Laboratorio corrente 					  ³±±
±±³			 ³ EXPN1 = Posicao do Ensaio do Laboratorio corrente 		  ³±±
±±³			 ³ EXPL2 = Identifica a exibicao da mensagem do Plano de Amos-³±±
±±³			 ³         tragem somente na coleta das medicoes			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPC2 = Fator sugerido para o Ensaio, quando EXPL1 = Falso ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215CalLab(lAtualiza,nPosLab,nPosEns,lRotCalEns)          
Local nTipAmo    := 0
Local aHeadTmp   := aClone(aSavaHeader[HEAD_NCS])
Local nPosNNC    := Ascan(aHeadTmp,{|x|AllTrim(x[2])=="QEU_NUMNC"})
Local lAprova    := .F.
Local lReprova   := .F.
Local lAprCond   := .F.
Local lQ215MED   := ExistBlock('Q215MED')
Local nDel	     := 0
Local cMensLau   := " "
Local cCarta     := " "
Local cPlAmEns	 := " "
Local aCtNC		 := {}
Local aCtMed     := {} 
Local lPriMed    := .T. 
Local lSegMed    := .F.
Local aLim		 := {}
Local nLIETol	 := 0
Local nLSETol	 := 0
Local lTemMed	 := .F.
Local lTemMedSeg := .F.
Local nX 		 := 0
Local nY 		 := 0
Local nZ         := 0
Local cEnsaio    := " "      
Local cEnsAux    := " "
Local nPosRes    := 0                   
Local nPosAmost  := 0 
Local lAllEns  
Local cFator     := " "
Local aPlaInt1   := {}
Local aPlaInt2   := {}
Local nPlaInt    := 0
Local nNcoPlaInt := 0
Local nPosGen    := 0     
Local aPlnIntEsp := {}
Local aMed5429   := {}   
Local aAcuPla    := {}
Local cChavePla  := "" 
Local nPosAcuPla := 0
Local nDelMed    := 0
Local dDataValid
Local cTpPlano	 := ""  

Default lAtualiza :=.T.     //Apos a realizacao do calculo, atualiza o Laudo do Laboratorio, se verdadeiro
Default nPosLab   := nFldLab //Posicao do Laboratorio no Folder
Default lRotCalEns := If(lRotCalEns==NIL,.F.,lRotCalEns) 

If nPosEns == NIL
	lAllEns := .T.
	nPosEns := 1
Else
	lAllEns := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Considera todos os Ensaios do Laboratorio corrente						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := nPosEns to If(lAllEns,Len(aResultados[nPosLab,_MED]),nPosEns) //Ensaios

	//Armazena o Ensaio corrente
	cEnsaio := aResultados[nPosLab,_ENS,nX,ENSAIO]
	cEnsAux := cEnsaio

	//Identifica a Carta utilizada no Ensaio
	cCarta := QA_CartEns(cEnsaio)

	//Salva a posicao do campo Resultados no aCols
	aHeadTmp := aClone(aSavHeadEns[nPosLab,nX])
	If cCarta == "TXT"     
		nPosRes := Ascan(aHeadTmp,{|x|AllTrim(x[2])=="QEQ_RESULT"})
	Else
		nPosRes := Ascan(aHeadTmp,{|x|AllTrim(x[2])=="QER_RESULT"})
	EndIf
	nPosAmost := Ascan(aHeadTmp,{|x|AllTrim(x[2])=="QER_AMOSTR"})

	lSegMed := .F. //Indica se devera ser utilizada a segunda amnostragem no ensaio
    lTemMed := .F. //Indica se existem medicoes cadastradas para o ensaio
    	
	//Vetor com o numero de Medicoes em cada amostragem por ensaio
	aCtMed := Afill(Array(2),0)
    
	//Vetor com o numero de NCs em cada amostragem por ensaio
	aCtNC := Afill(Array(2),0)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o array que armazena as medicoes utilizadas no calculo para a³
	//³ Norma NBR-5429.                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMed5429 := {}         
	
	cPlAmEns := aResultados[nPosLab,_PAE,nX,1,1] //Descricao do Plano de Amostragem
	cTpPlano := aResultados[nPosLab,_PAE,nX,1,3] //Tipo do Plano de Amostragem  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula os Limites: inferior e supeiror com a Tolerancia				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Alltrim(cCarta) <> "TXT"
		aLim	:= Q215CalLim(cEnsaio)
		nLIETol	:= aLim[1]
		nLSETol	:= aLim[2]
	Else
		nLIETol	:= 0
		nLSETol	:= 0
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona as Classes das nao-conformidades para utilizacao no Plano de   ³
	//³ Amostragem Interno.														³
	//³ 1 = Classe da nao-conformidade											³
	//³ 2 = Sequencia da Amostragem												³
	//³ 3 = Aceite da Amostragem												³
	//³ 4 = Rejeite da Amostragem 												³
	//³ 5 = Tamanho da Amostragem 												³
	//³ 6 = Quantidade de nao-conformidades por Classe							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aPlaInt1 := {}
	Aadd(aPlaInt1,{"A","1",0,0,0,0})
	Aadd(aPlaInt1,{"B","2",0,0,0,0})
	Aadd(aPlaInt1,{"C","3",0,0,0,0})
	Aadd(aPlaInt1,{"D","4",0,0,0,0})
	Aadd(aPlaInt1,{"G","0",0,0,0,0})
	
	aPlaInt2 := aClone(aPlaInt1) //Realiza uma copia com a mesma estrutura
	nPosGen  := Len(aPlaInt1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Considera todas as medicoes do Ensaio corrente							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nY := 1 to Len(aResultados[nPosLab,_MED,nX]) //Medicoes
               
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Indica o Tipo de Amostragem a ser contabilizada: 1 = Simples			³
		//³ 		                                         2 = Dupla				³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTipAmo := aResultados[nPosLab,_MED,nX,nY,nPosAmost] 
		nDel    := Len(aResultados[nPosLab,_MED,nX,nY])
		    
		If !aResultados[nPosLab,_MED,nX,nY,nDel] .And.;
			(Q215ChkMed(nPosLab,nX,,nY,cCarta,1,.F.,,) .Or.Upper(aEnsaios[nPosLab,nX,SKPTST+5]) == Upper(STR0200))//"Certificar"
		      
			lTemMed := If(!lTemMed,.T.,lTemMed) //Indica que o Ensaio possui medicoes

		    If nTipAmo == 2
			    lTemMedSeg := If(!lTemMedSeg,.T.,lTemMedSeg) //Indica que o Ensaio possui medicoes
			EndIf    

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica o Plano de Amostragem (NBR546, QS9000 e Texto)					³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cPlAmEns) 

	    		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se o Plano definido para o Ensaio e a NBR5429, armazena as     ³
				//³ medicoes para o calculo.												³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPlamEns == "5" //NBR5429 
					Q215RetMed(nPosLab,nX,nY,cEnsaio,cCarta,@aMed5429)
				
				ElseIf cTpPlano == "PI" //Plano Interno		
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Contabiliza nao-conformidades do Plano de Amostragem Interno (especifico)³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    	If lQ215PL1 
			    		ExecBlock('Q215PL1',.F.,.F.)
			    	Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Contabiliza as nao-conformidades por classe, para aplicacao do Plano de ³
						//³ Amostragem Interno.														³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aCtMed[nTipAmo]++ //Soma o numero de medicoes no ensaio corrente
		
						For nZ := 1 to Len(aResultados[nPosLab,_NCO,nX,nY])	
							nDel := Len(aResultados[nPosLab,_NCO,nX,nY,nZ])
							If !aResultados[nPosLab,_NCO,nX,nY,nZ,nDel] .And.;
								Q215ChkMed(nPosLab,nX,nY,nZ,,2,.F.)        
		
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³	Realiza a soma das nao-conformidades por classe			³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					    		If nTipAmo == 1	
									//Verifica a posicao da Classe da nao-conformidade                   
								 	nNcoPlaInt := Ascan(aPlaInt1,{|x|x[1]==aResultados[nPosLab,_NCO,nX,nY,nZ,nPosCla]})
				
							    	If nNcoPlaInt > 0
							    	    //Soma as nao-conformidades por classe
										aPlaInt1[nNcoPlaInt,6] += aResultados[nPosLab,_NCO,nX,nY,nZ,nPosNum]
									EndIf
									
									//Soma as nao-conformidades genericas
									 aPlaInt1[nPosGen,6] += aResultados[nPosLab,_NCO,nX,nY,nZ,nPosNum]								    

						    	Else           
									//Verifica a posicao da Classe da nao-conformidade                   
								 	nNcoPlaInt := Ascan(aPlaInt2,{|x|x[1]==aResultados[nPosLab,_NCO,nX,nY,nZ,nPosCla]})
				
							    	If nNcoPlaInt > 0		
									    //Soma as nao-conformidades por classe
										aPlaInt2[nNcoPlaInt,6] += aResultados[nPosLab,_NCO,nX,nY,nZ,nPosNum]
									    
									    //Soma as nao-conformidades genericas
									    aPlaInt2[nPosGen,6] += aResultados[nPosLab,_NCO,nX,nY,nZ,nPosNum]
									EndIf								    
						    	EndIf 
						    EndIf                                            
						Next nZ    
			    	EndIf
			    	
				Else
	            
   					//Indica a Existencia da Segunda Amostragem
					If nTipAmo == 2
						lSegMed := If(!lSegMed,.T.,lSegMed)
					EndIf

					//Indica se considera as medicoes fora das especificacoes como NC's
		  			If lMedForEsp 
						//Contabiliza o numero de medicoes fora da Especificacao
						aCtNC[nTipAmo] += Q215SumMFE(nPosLab,nX,nY,nLIETol,nLSETol,cCarta)
					EndIf
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Contabiliza  o numero de Nao-conformidades								³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nZ := 1 to Len(aResultados[nPosLab,_NCO,nX,nY])	
						nDel := Len(aResultados[nPosLab,_NCO,nX,nY,nZ])
						If !aResultados[nPosLab,_NCO,nX,nY,nZ,nDel] .And.;
							Q215ChkMed(nPosLab,nX,nY,nZ,,2,.F.)        

							//Soma Ocorrencia da NC
							aCtNC[nTipAmo] += aResultados[nPosLab,_NCO,nX,nY,nZ,nPosNNc] 
					    EndIf            
					Next nZ    

				EndIf

			Else     
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tratamento das medicoes atraves da Inspecao Normal						³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aResultados[nPosLab,_MED,nX,nY,nPosRes] == "R"    
					lReprova := .T.
					cMensLau := Q215FormatMsg(,1) //"Existem Medicoes Reprovadas, o Laudo devera ser Rejeitado"
					Exit
				ElseIf aResultados[nPosLab,_MED,nX,nY,nPosRes] == "T"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se as medicoes estiverem fora dos limites, mas dentro da tolerancia, o  ³
					//³ Laudo ser aprovado condicionalmente										³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lAprConTol 
						lAprCond := .T.
						cMensLau := Q215FormatMsg(,2) //"Existem Medicoes Aprovadas com Tolerancia, o Laudo devera ser Aprovado Condicionalmente"
					Else
						lReprova := .T.
						cMensLau := Q215FormatMsg(,3) //"Existem Medicoes Aprovadas com Tolerancia, o Laudo devera ser Rejeitado"                 //"Existe Medicao Aprovada com Tolerancia. O Laudo devera ser Rejeitado"
						Exit
					EndIf
				ElseIf (aResultados[nPosLab,_MED,nX,nY,nPosRes] == "A" .Or. Upper(aEnsaios[nPosLab,nX,SKPTST+5]) == Upper(STR0200)) //"Certificar"
					lAprova	:= .T.
					If !lAprCond
						cMensLau := Q215FormatMsg(,4) //"Todas Medicoes encontram-se Aprovadas, O Laudo devera ser Aprovado"                    
					EndIf
				EndIf
			EndIf
		EndIf

    Next nY      
    
  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada utilizado  para alteração da contagem do Plano Interno.	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	If lQ215PINT
	   	aRet := ExecBlock("Q215PINT",.F.,.F.,{aPlaInt1,aPlaInt2,nPosLab,nX}) 
	   	aPlaInt1 := aRet[1]
	   	aPlaInt2 := aRet[2]						    	
	EndIf   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aplica o tratamento do Plano de Amostragem da NBR-5429						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPlAmEns == "5" //Tipo do Plano de Amostragem 
		//Calcula o Indice de Defeitos com base na Norma NBR-5429
		aCtNC[nTipAmo] += QA_Def5429(aMed5429,nLIETol,nLSETol,QA_Plano(cPlAmEns),aResultados[nPosLab,_PAE,nX,1,5])[5]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a aglutinacao dos Planos de Amostragens que possuem a mesmas ca ³
	//³ racteristicas, sendo: Tipo de Plano, Nivel, Amostragem e NQA. Sendo a   ³
	//³ aglutinacao aplicada apenas para a NBR5426.								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAglutinaPA .And. cPlAmEns == "1" //NBR5426 
		cChavePla  := (aResultados[nPosLab,_PAE,nX,1,1]+aResultados[nPosLab,_PAE,nX,1,2]+aResultados[nPosLab,_PAE,nX,1,3]+aResultados[nPosLab,_PAE,nX,1,4])
		nPosAcuPla := Ascan(aAcuPla,{|x|x[1]==cChavePla})
		If nPosAcuPla == 0 
			Aadd(aAcuPla,{cChavePla,{aCtNC[1],aCtNC[2]," "}})
			nPosAcuPla := Len(aAcuPla)
		Else 
			aAcuPla[nPosAcuPla,2,nTipAmo] += aCtNC[nTipAmo]
			aCtNC[nTipAmo]                := aAcuPla[nPosAcuPla,2,nTipAmo]	
		EndIf	
		aAcuPla[nPosAcuPla,2,3] += AllTrim(cEnsaio) + ", "  			
		
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Compara o numero de NCs com o Aceite e Rejeite do Plano de Amostragem   ³
	//³ definidos para o Ensaio											 	    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTemMed .And. !Empty(cPlAmEns) .And. cPlAmEns <> "3" .And. cTpPlano <> "PI"                       
        
		//Formata o conteudo da variavel armazenando os ensaios        
		If lAglutinaPA .And. cPlAmEns == "1" //NBR5426 
			cEnsaio := AllTrim(aAcuPla[nPosAcuPla,2,3])
			cEnsaio := SubStr(cEnsaio,1,Len(cEnsaio)-1) //retira a ultima virgula
        EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Plano de Amostragem (NBR5426,QS9000 e Texto)							³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SubStr(aResultados[nPosLab,_PAE,nX,1,3],1,1) <> "D") .Or. (aResultados[nPosLab,_PAE,nX,1,3] == "QS") .Or. (aResultados[nPosLab,_PAE,nX,1,3] == "TX")			     
			//Amostragem Simples
			If aCtNC[1] <= aResultados[nPosLab,_PAE,nX,1,6] .And. aCtNC[1] <> 0  //Aceite 1   
				lAprova := .T.
				If !lAprCond
					cMensLau := Q215FormatMsg({Alltrim(Str(aCtNc[1])),AllTrim(Str(aResultados[nPosLab,_PAE,nX,1,6]))},5) //"Foram encontradas (##########) nao-conformidades, sendo inferior ou igual ao Aceite de (##########), em seu respectivo Plano de Amostragem, O Laudo devera ser Aprovado"				    
				EndIf
			ElseIf aCtNC[1] >= aResultados[nPosLab,_PAE,nX,1,7] .Or. aCtNC[1] == 0//Rejeite 1		
				//So nao ira rejeitar caso nao houver NC e se as medicoes forem todas aprovadas
				If aCtNC[1] == 0
					For nY := 1 to Len(aResultados[nPosLab,_MED,nX]) //Medicoes
						nDelMed := Len(aResultados[nPosLab,_MED,nX,nY])
						If aResultados[nPosLab,_MED,nX,nY,nposRes] == "A" .AND. !(aResultados[nPosLab,_MED,nX,nY,nDelMed])//Registro excluido
							lAprova  := .T.
							lReprova := .F.
						Else
							If aResultados[nPosLab,_MED,nX,nY,nPosRes] == "R" .AND. !(aResultados[nPosLab,_MED,nX,nY,nDelMed])//Registro excluido
								lAprova  := .F.
								lReprova := .T.
								Exit
							Endif
						Endif
					Next
				Else // Se houver NC Verifico se ha Medidas Reprovadas
				    For nY := 1 to Len(aResultados[nPosLab,_MED,nX])
						nDelMed := Len(aResultados[nPosLab,_MED,nX,nY])
						If aResultados[nPosLab,_MED,nX,nY,nposRes] == "A" .AND. !(aResultados[nPosLab,_MED,nX,nY,nDelMed])//Registro excluido
							lAprova  := .T.
							lReprova := .F.
						Else
						
							If aResultados[nPosLab,_MED,nX,nY,nPosRes] == "R" .AND. !(aResultados[nPosLab,_MED,nX,nY,nDelMed])   
								lReprova := .T.	
								lAprova  := .F.
								Exit						
							EndIf 
						Endif
					Next				    
				Endif    
				If lReprova .and. aCtNC[1] > 0
					cMensLau := Q215FormatMsg({Alltrim(Str(aCtNC[1])),AllTrim(cEnsaio),Alltrim(Str(aResultados[nPosLab,_PAE,nX,1,7]))},6) //"Foram encontradas (##########) nao-conformidades, no Ensaio (##########), sendo Superior ou igual ao Rejeite de (##########), em seu respectivo Plano de Amostragem, o Laudo devera ser Rejeitado"
					Exit
				Elseif lReprova
					cMensLau := STR0267 //"Existem medições reprovadas, o Laudo deverá ser Rejeitado"
				Endif	
			Else
				lAprCond := .T.
				//cMensLau := Q215FormatMsg({Alltrim(Str(aCtNC[1])),AllTrim(cEnsaio),Alltrim(Str(QF5->QF5_ACEI1)),Alltrim(Str(QF5->QF5_REJEI1))},7)	//"Foram encontradas (##########) nao-conformidades, no Ensaio (##########), sendo entre o Aceite de (##########) e rejeite de (##########), em seu respectivo Plano de Amostragem, o Laudo devera ser Aprovado Condicionalmente"				
				cMensLau := Q215FormatMsg({Alltrim(Str(aCtNC[1])),AllTrim(cEnsaio),Alltrim(Str(aResultados[nPosLab,_PAE,nX,1,6])),Alltrim(Str(aResultados[nPosLab,_PAE,nX,1,7]))},7)	//"Foram encontradas (##########) nao-conformidades, no Ensaio (##########), sendo entre o Aceite de (##########) e rejeite de (##########), em seu respectivo Plano de Amostragem, o Laudo devera ser Aprovado Condicionalmente"							
			EndIf

		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Plano com Amostragem Dupla												³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aCtNC[1] <= aResultados[nPosLab,_PAE,nX,1,6] //Aceite 1
				lAprova := .T.
				If !lAprCond
					cMensLau := Q215FormatMsg({Alltrim(Str(aCtNc[1])),AllTrim(Str(aResultados[nPosLab,_PAE,nX,1,6]))},5) //"Foram encontradas (##########) nao-conformidades, sendo inferior ou igual ao Aceite de (##########), em seu respectivo Plano de Amostragem, O Laudo devera ser Aprovado"
				EndIf
			ElseIf aCtNC[1] >= aResultados[nPosLab,_PAE,nX,1,7] //Rejeite 1
				lReprova := .T.
				cMensLau := Q215FormatMsg({Alltrim(Str(aCtNC[1])),AllTrim(cEnsaio),Alltrim(Str(aResultados[nPosLab,_PAE,nX,1,7]))},6) //"Foram encontradas (##########) nao-conformidades, no Ensaio (##########), sendo Superior ou igual ao Rejeite de (##########), em seu respectivo Plano de Amostragem, o Laudo devera ser Rejeitado"				
				Exit
			Else
				If !lSegMed
					If (aCtNC[1] > aResultados[nPosLab,_PAE,nX,1,6] .And.; //Aceite 1
						aCtNC[1] < aResultados[nPosLab,_PAE,nX,1,7])		 //Rejeite 1			
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se nenhum ensaio teve motivo para Aprovacao, Aprovacao Condicional ou Re³
						//³ provacao, indica que ha necessidade de uma segunda amostragem			³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !lAprova .And. !lAprCond .And. !lReprova
							cMensLau := Q215FormatMsg(,8)+AllTrim(cEnsaio) //"Ha necessidade de realizar uma Segunda Amostragem no Ensaio :"
						EndIf                                      

						If !lAtualiza
							MessageDlg(cMensLau,,2)              
						EndIf	

					EndIf
				Else 
					If aCtNC[1]+aCtNC[2] <= aResultados[nPosLab,_PAE,nX,1,9] //Aceite 2
						lAprova := .T.
						If !lAprCond
							cMensLau := Q215FormatMsg({Alltrim(Str(aCtNc[1]+aCtNC[2])),AllTrim(Str(aResultados[nPosLab,_PAE,nX,1,9]))},5) //"Foram encontradas (##########) nao-conformidades, sendo inferior ou igual ao Aceite de (##########), em seu respectivo Plano de Amostragem, O Laudo devera ser Aprovado" 											
						EndIf
						
					ElseIf aCtNC[1]+aCtNC[2] >= aResultados[nPosLab,_PAE,nX,1,10] //Rejeite 2
						lReprova := .T.
						cMensLau := Q215FormatMsg({Alltrim(Str(aCtNC[1]+aCtNC[2])),AllTrim(cEnsaio),Alltrim(Str(aResultados[nPosLab,_PAE,nX,1,10]))},6) //"Foram encontradas (##########) nao-conformidades, no Ensaio (##########), sendo Superior ou igual ao Rejeite de (##########), em seu respectivo Plano de Amostragem, o Laudo devera ser Rejeitado" 
						Exit
					Else
						lAprCond := .T.
						cMensLau :=	Q215FormatMsg({Alltrim(Str(aCtNC[1]+aCtNC[2])),AllTrim(cEnsaio),Alltrim(Str(aResultados[nPosLab,_PAE,nX,1,9])),Alltrim(Str(aResultados[nPosLab,_PAE,nX,1,10]))},7)//"Foram encontradas (##########) nao-conformidades, no Ensaio (##########), sendo entre o Aceite de (##########) e rejeite de (##########), em seu respectivo Plano de Amostragem, o Laudo devera ser Aprovado Condicionalmente"
					EndIf
				EndIf
			EndIf
		EndIf                        

		//Recupera o conteudo da variavel do ensaio        
		If lAglutinaPA .And. cPlAmEns == "1" //NBR5426 
			cEnsaio := cEnsAux 
        EndIf

	ElseIf lTemMed .And. cTpPlano == "PI"                                          
	    nQtdNco:=0
	    nQtdPla:=0         
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Plano de Amostragem Interno (especifico)								³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If lQ215PL2 
    		aPlnIntEsp := ExecBlock('Q215PL2',.F.,.F.)
			lAprova  := aPlnIntEsp[1]
			lAprCond := aPlnIntEsp[2]
			lReprova := aPlnIntEsp[3]
			cMensLau := aPlnIntEsp[4]
    	Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Plano de Amostragem Interno												³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	      	Q215PlAmIn(@aPlaInt1,@aPlaInt2,cPlAmEns,aResultados[nPosLab,_PAE,nX,1,2],aResultados[nPosLab,_PAE,nX,1,4],QEK->QEK_TAMLOT,QEK->QEK_TAMAMO)

	      	//Analise das Amostragens simples
	      	For nPlaInt := 1 to Len(aPlaInt1)
	      		If lPriMed
	      			If aPlaInt1[nPlaInt,6] > 0 .And. aPlaInt1[nPlaInt,4] > 0
						If aCtMed[1] > 0
							If aCtMed[1] <> aPlaInt1[nPlaInt,5] 
								cMensLau := Q215FormatMsg({AllTrim(Str(aCtMed[1])),AllTrim(Str(aPlaInt1[nPlaInt,5])),AllTrim(cEnsaio)},9) //"A quantidade de medicoes igual a (##########), esta divergente do Tamanho da Amostra igual a (##########), definida na primeira amostragem do Plano, referente ao Ensaio (##########)"   
								If lRotCalEns 
									MessageDlg(cMensLau,,2)              
									lRotCalEns := .F.
								EndIf	       
								 
							EndIf              
						EndIf

						If aPlaInt1[nPlaInt,6] >= aPlaInt1[nPlaInt,4]
					        nQtdNco  := aPlaInt1[nPlaInt,6]
					        nQtdPla  := aPlaInt1[nPlaInt,4]
							lReprova := .T.
							Exit
						EndIf

						//verifica a necessidade da segunda amostragem
						If (aPlaInt1[nPlaInt,6] > aPlaInt1[nPlaInt,3]) .And.;
							(aPlaInt1[nPlaInt,6] < aPlaInt1[nPlaInt,4])
							lSegMed := .T.
						EndIf

					EndIf
				EndIf
			Next nPlaInt

			//Analise das Amostragens duplas
			For nPlaInt := 1 to Len(aPlaInt2)
				If lSegMed
					If aPlaInt2[nPlaInt,6] > 0 .And. aPlaInt2[nPlaInt,4] > 0
						If aCtMed[2] > 0
							If aCtMed[2] <> aPlaInt2[nPlaInt,5] 
								cMensLau := Q215FormatMsg({AllTrim(Str(aCtMed[2])),AllTrim(Str(aPlaInt2[nPlaInt,5])),AllTrim(cEnsaio)},10) //"A quantidade de medicoes igual a (##########), esta divergente do Tamanho da Amostra igual a (##########), definida na segunda amostragem do Plano referente ao Ensaio (##########)"   
								If lRotCalEns 
									MessageDlg(cMensLau,,2)              
									lRotCalEns := .F.
								EndIf	       
	
							EndIf
						EndIf              

						If aPlaInt2[nPlaInt,6] >= aPlaInt2[nPlaInt,4] 
					        nQtdNco  := aPlaInt2[nPlaInt,6]
					        nQtdPla  := aPlaInt2[nPlaInt,4]
							lReprova := .T.
							lPriMed  := .F.
							Exit
						EndIf

					EndIf			
			    EndIf
			Next nPlaInt 
			If lQ215MED  	
				For nY := 1 to Len(aResultados[nPosLab,_MED,nX]) //Medicoes   
					nDelMed := Len(aResultados[nPosLab,_MED,nX,nY])
					If aResultados[nPosLab,_MED,nX,nY,nposRes] == "A" .AND. !(aResultados[nPosLab,_MED,nX,nY,nDelMed])//Registro excluido
						lAprova  := .T.
						lReprova := .F.
						If (nQtdNco>0) .And. (nQtdPla>0) .Or. nQtdNco > aPlaInt1[nPosGen,4]					
							lAprova  := .F.
							lReprova := .T.						
						Endif
					Else
						If aResultados[nPosLab,_MED,nX,nY,nPosRes] == "R" .AND. !(aResultados[nPosLab,_MED,nX,nY,nDelMed])//Registro excluido
							cMensLau := STR0267 //"Existem medições reprovadas, o Laudo deverá ser Rejeitado"
							lAprova  := .F.
							lReprova := .T.
							Exit
						Endif
					Endif
				Next
			EndIf
			If lReprova .And. (nQtdNco>0 .And. nQtdPla>0 .Or. nQtdNco > aPlaInt1[nPosGen,4])
				If nQtdPla = 0
					nQtdPla := aPlaInt1[nPosGen,4]+1
				Endif  
				cMensLau := Q215FormatMsg({AllTrim(Str(nQtdNco)),AllTrim(cEnsaio),AllTrim(Str(nQtdPla))},6) //"Foram encontradas (##########) nao-conformidades, no Ensaio (##########), sendo Superior ou igual ao Rejeite de (##########), em seu respectivo Plano de Amostragem, o Laudo devera ser Rejeitado" 
			Else
				If !lReprova  
					If !lTemMedSeg .and. lSegMed
						cMensLau := Q215FormatMsg(,12) //"Numero de nao conformidades de cada ensaio esta entre os valores de aceite e rejeite, o laudo deverá ser Aprovado. Conforme parametrização do Plano de Amostragem é sugerido uma Segunda Amostragem."
					Else
						cMensLau := Q215FormatMsg(,11) //"O Numero de nao-conformidades encontradas nos ensaios, sao inferiores ou iguais aos Aceites definidos nos respectivos Planos de Amostragens, O Laudo devera ser Aprovado" 
						lAprova := .T.
					EndIf
				EndIf
			EndIf
			
		EndIf
		
	EndIf 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sugere o Laudo do Laboratorio como Reprovado, caso haja rejeicao		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lReprova
		Exit
	EndIf
	
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o Laudo do Laboratorio											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAtualiza .and. lTemMed

	//Se houver algum sub-grupo reprovado, assume o Laudo como Reprovado
	M->QEL_LAUDO := If(lReprova,cFatRep,If(lAprCond,;
		SubStr(cFatApC,Len(cFatApC),1),If(lAprova,SubStr(cFatApr,1,1),Space(TamSX3("QEL_LAUDO")[1]))))
	
	//Retorno o Laudo sugerido pela Rotina
	M->QEL_DESLAU := QE215RDL("QED",1,xFilial("QED")+M->QEL_LAUDO)
	
	//Exibra a descricao efetuada pelos calculos
	If !Empty(cMensLau)
		QPAviso("",cMensLau,{"OK"},Nil,Nil)
	Endif
	
	//Sugere as informacoes sobre o Laudo Final da Entrada
	If (M->QEL_LAUDO $ cFatApr) .Or. (M->QEL_LAUDO $ cFatApC) .Or. (M->QEL_LAUDO == cFatRep)
		M->QEL_DTLAUD := dDataBase
		If cOrigEnt == "MATA103"
			Q215ValLote(.F.)
		Else
			M->QEL_DTVAL  := dDataBase + QAtuShelf(QEK->QEK_PRODUT,QEK->QEK_REVI) 
		Endif 
		M->QEL_HRLAUD := Left(Time(),5)

		If M->QEL_LAUDO == cFatRep
			M->QEL_QTREJ := M->QEL_TAMLOT
		ElseIf M->QEL_LAUDO $ cFatApr
			M->QEL_QTREJ := Left("0",TamSx3("QEL_QTREJ")[1])
		EndIf
		M->QEL_NOMRES := QA_NUSR(,,.F.,"N")
	EndIf                                         

Else
	//Retorna somente o Resultado do Calculo das Medicoes						
	If lReprova  
		cFator := "R" //Reprovado
	ElseIf lAprCond .Or. lAprova 
		cFator := "A" //Aprovado
	Else                                
		cFator := "P" //Pendente
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a Sequencia das Medicoes             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE215Seq(aOBJETOS[OBJ_MED,nFldLab,nFldEns])

Return(cFator) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215FormatMsg³Autor³Paulo Emidio de Barros ³ Data ³28/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Formata o texto das Mensagens dos Laudos					   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SIntaxe   ³ Q215FormatMsg(EXPA1,EXPN1)								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPA1 = Vetor com as mascaras a serem utilizadas na mensagem³±±
±±³			 ³ EXPN1 = Posicao da Mensagem								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPC1 = Mensagem formatada								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215													   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215FormatMsg(aMascara,nPosMsg)
Local aMsgPad  := {}
Local cRetorno := " "
Local nPosIni  := 0         
Local nPosSub  := 0
Local nPosMas  := 0

aMascara := If(aMascara==NIL,{},aMascara)
aEval(aMascara,{|x|x:= PadC(x,Len(x))})

Aadd(aMsgPad,STR0217) //"Existem Medicoes Reprovadas, o Laudo devera ser Rejeitado"
Aadd(aMsgPad,STR0218) //"Existem Medicoes Aprovadas com Tolerancia, o Laudo devera ser Aprovado Condicionalmente"
Aadd(aMsgPad,STR0219) //"Existem Medicoes Aprovadas com Tolerancia, o Laudo devera ser Rejeitado"
Aadd(aMsgPad,STR0220) //"Todas Medicoes encontram-se Aprovadas, O Laudo devera ser Aprovado"
Aadd(aMsgPad,STR0221) //"Foram encontradas (##########) nao-conformidades, sendo inferior ou igual ao Aceite de (##########), em seu respectivo Plano de Amostragem, O Laudo devera ser Aprovado"
Aadd(aMsgPad,STR0222) //"Foram encontradas (##########) nao-conformidades, no(s) Ensaio(s): (##########), sendo Superior ou igual ao Rejeite de (##########), em seu respectivo Plano de Amostragem, o Laudo devera ser Rejeitado"
Aadd(aMsgPad,STR0223) //"Foram encontradas (##########) nao-conformidades, no(s) Ensaio(s): (##########), sendo entre o Aceite de (##########) e rejeite de (##########), em seu respectivo Plano de Amostragem, o Laudo devera ser Aprovado Condicionalmente"
Aadd(aMsgPad,STR0224) //"Ha necessidade de realizar uma Segunda Amostragem no(s) Ensaio(s):"
Aadd(aMsgPad,STR0225) //"A quantidade de medicoes igual a (##########), esta divergente do Tamanho da Amostra igual a (##########), definida na primeira amostragem do Plano referente ao(s) Ensaio(s) (##########)"
Aadd(aMsgPad,STR0226) //"A quantidade de medicoes igual a (##########), esta divergente do Tamanho da Amostra igual a (##########), definida na segunda amostragem do Plano referente ao(s) Ensaio(s) (##########)"
Aadd(aMsgPad,STR0227) //"O Numero de nao-conformidades encontradas nos ensaios, sao inferiores ou iguais aos Aceites definidos nos respectivos Planos de Amostragens, O Laudo devera ser Aprovado"
Aadd(aMsgPad,STR0251) //"Numero de nao conformidades de cada ensaio esta entre os valores de aceite e rejeite, o laudo deverá ser Aprovado. Conforme parametrização do Plano de Amostragem é sugerido uma Segunda Amostragem."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formata a Mensagem de acordo com o Tamanho da Mascara					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aMascara) > 0
	For nPosIni := 1 to Len(aMsgPad[nPosMsg])                             
		nPosSub := At("##########",aMsgPad[nPosMsg])
		If nPosSub > 0
			nPosMas ++
			If nPosMas <= Len(aMascara)
				aMsgPad[nPosMsg] := Stuff(aMsgPad[nPosMsg],nPosSub,10,Repl("#",Len(aMascara[nPosMas])))
			EndIf	
		EndIf
	Next nPosIni    
EndIf

cRetorno := FmtLin(aMascara,aMsgPad[nPosMsg],,"@!",,.F.,,512)

Return(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215ChkMed³ Autor ³Paulo Emidio de Barros	 ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se todos os dados necessario foram digitados na	   ³±±
±±³			 ³ Getdados de Medicoes, Nao Conformidades e Instrumentos      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SIntaxe   ³ Q215ChkMed(EXPN1,EXPN2,EXPN3,EXPN4,EXPC1,EXPN5,EXPL1,EXPL2) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Laboratorio							   ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio							       ³±±
±±³			 ³ EXPN3 = Posicao da Linha da Medicao						   ³±±
±±³			 ³ EXPN4 = Posicao da Medicao								   ³±±
±±³			 ³ EXPC1 = Carta do Ensaio corrente					    	   ³±±
±±³			 ³ EXPN5 = Tipo, onde 1) Medicoes							   ³±±
±±³			 ³		    		  2) Nao-conformidades				  	   ³±±
±±³			 ³		  		  	  3) Instrumentos					   	   ³±±
±±³			 ³ EXPL1 = Indica se o registro sera marcado como deletado	   ³±±
±±³			 ³ EXPL2 = Indica se o registro deletado sera considerado      ³±±
±±³			 ³ EXPL3 = Indica se as consistencias serao realizadas no aCols³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL2 = .T. ou .F.										   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215													   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215ChkMed(nPosLab,nPosEns,nPosLinMed,nPosMed,cCarta,nTipo,lDeleta,lConDel,laCols)
Local lRetorno := .T.                          
Local lCpoVazio:= .F.
Local aHeadTmp := {}
Local nDel     := 0 //posicao da marca de exclusao no aCols 
Local nPosCpo  := 0 //posicao do campo medicao
Local nPosResMed  := 0 //posicao do campo Resultado
Local nPosNco  := 0 //posicao do campo Nao-conformidade                                             
Local nPosInst := 0 //posicao do campo codigo do Instrumento
Local nQtdCpo  := 0
Local cEnsaio  := aResultados[nPosLab,_ENS,nPosEns,ENSAIO] 
Local nQtdMed  := Q215QtdMed(cEnsaio)

Default lDeleta := .T.
Default lConDel := .F. //Indica se o registro deletado no aCols sera considerado
Default laCols  := .F. //Indica se as consistencias serao realizadas no aCols

If nTipo == 1 //Medicoes              

	aHeadTmp := aClone(aSavHeadEns[nPosLab,nPosEns])
	If cCarta == "P  "
		nPosCpo  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDIPA"})
	ElseIf cCarta == "TXT"
		nPosCpo  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QEQ_MEDICA"})
	Else
		nPosCpo  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDICA"})
	EndIf                                           
	If cCarta == "TXT"	                                                
		nPosResMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QEQ_RESULT"})
	Else
		nPosResMed := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_RESULT"})
	EndIf
	          
	If lAcols //Realiza a validacao no aCols
		nDel := Len(aOBJETOS[OBJ_MED,nFldLab,nPosEns]:aCols[nPosMed])
		If !aOBJETOS[OBJ_MED,nFldLab,nPosEns]:aCols[nPosMed,nDel]
			If Empty(aOBJETOS[OBJ_MED,nFldLab,nPosEns]:aCols[nPosMed,nPosResMed]) .AND. Empty(aResultados[nFldLab,_ENS,nPosEns,FORMUL])
				If lDeleta
					aOBJETOS[OBJ_MED,nFldLab,nPosEns]:aCols[nPosMed,nDel] := .T.
				EndIf
				lRetorno := .F.
			Else
				nQtdCpo := (nPosCpo+nQtdMed-1)
				For nPosCpo := nPosCpo to nQtdCpo
					If AllTrim(aHeadTmp[nPosCpo,2]) $ "QEQ_MEDICA/QES_MEDICA/QES_MEDIPA/QES_MEDIPN/QES_MEDIPP/QER_RESULT/QER_ENSR"	
						If cCarta != "P  "
							lCpoVazio := Empty(aOBJETOS[OBJ_MED,nFldLab,nPosEns]:aCols[nPosMed,nPosCpo]) .AND. Empty(aResultados[nFldLab,_ENS,nPosEns,FORMUL])
						Else
							lCpoVazio := aOBJETOS[OBJ_MED,nFldLab,nPosEns]:aCols[nPosMed,nPosCpo] == Nil
						EndIf
						If lCpoVazio
							If lDeleta
								aOBJETOS[OBJ_MED,nFldLab,nPosEns]:aCols[nPosMed,nDel]:= .T.
							EndIf
							lRetorno := .F.
							Exit
					    EndIf
				    EndIf
				Next nPosCpo
			EndIf
		Else 
			If lConDel
				lRetorno := .F.
			EndIf	    
	    EndIf
	
	Else
		nDel := Len(aResultados[nPosLab,_MED,nPosEns,nPosMed])  
		If !aResultados[nPosLab,_MED,nPosEns,nPosMed,nDel]
			If Empty(aResultados[nPosLab,_MED,nPosEns,nPosMed,nPosResMed])
				If lDeleta
					aResultados[nPosLab,_MED,nPosEns,nPosMed,nDel] := .T.
				EndIf
				lRetorno := .F.
			Else
				nQtdCpo := (nPosCpo+nQtdMed-1)
				For nPosCpo := nPosCpo to nQtdCpo
					If AllTrim(aHeadTmp[nPosCpo,2]) $ "QEQ_MEDICA/QES_MEDICA/QES_MEDIPA/QES_MEDIPN/QES_MEDIPP/QER_RESULT/QER_ENSR"	
						If cCarta != "P  "
							lCpoVazio := Empty(aResultados[nPosLab,_MED,nPosEns,nPosMed,nPosCpo])
						Else
							lCpoVazio := aResultados[nPosLab,_MED,nPosEns,nPosMed,nPosCpo] == Nil
						EndIf
						If lCpoVazio
							If lDeleta
								aResultados[nPosLab,_MED,nPosEns,nPosMed,nDel] := .T.
							EndIf
							lRetorno := .F.
							Exit
					    EndIf
				    EndIf
				Next nPosCpo
			EndIf
		Else
			If lConDel
				lRetorno := .F.
			EndIf	    
	    EndIf
    
    EndIf
    
ElseIf nTipo == 2 //Nao-conformidades            
	aHeadTmp := aClone(aSavaHeader[HEAD_NCS])
	nPosNco  := Ascan(aHeadTmp,{|x|AllTrim(x[2])=="QEU_NAOCON"})
    If laCols //Realiza a validacao no aCols
	    nDel := Len(aOBJETOS[OBJ_NCO,nFldLab]:aCols[nPosMed]) 
		If !aOBJETOS[OBJ_NCO,nFldLab]:aCols[nPosMed,nDel]                              
			If Empty(aOBJETOS[OBJ_NCO,nFldLab]:aCols[nPosMed,nPosNco])
				If lDeleta 
					aOBJETOS[OBJ_NCO,nFldLab]:aCols[nPosMed,nDel] := .T.
				EndIf	
				lRetorno := .F.        
		    EndIf
		Else
			If lConDel
				lRetorno := .F.
			EndIf	    
		EndIf

    Else	
        nDel := Len(aResultados[nPosLab,_NCO,nPosEns,nPosLinMed,nPosMed]) 
		If !aResultados[nPosLab,_NCO,nPosEns,nPosLinMed,nPosMed,nDel]        
			If Empty(aResultados[nPosLab,_NCO,nPosEns,nPosLinMed,nPosMed,nPosNco])
				If lDeleta 
					aResultados[nPosLab,_NCO,nPosEns,nPosLinMed,nPosMed,nDel] := .T.       
				EndIf	
				lRetorno := .F.        
		    EndIf
		Else
			If lConDel
				lRetorno := .F.
			EndIf	    
		EndIf
	
	EndIf	
	
ElseIf nTipo == 3 //Instrumentos
	aHeadTmp := aClone(aSavaHeader[HEAD_INS])
	nPosInst := Ascan(aHeadTmp,{|x|AllTrim(x[2])=="QET_INSTR"})
    
    If laCols //Realiza a validacao no aCols
	    nDel := Len(aOBJETOS[OBJ_INS,nFldLab]:aCols[nPosMed])         
    	If !aOBJETOS[OBJ_INS,nFldLab]:aCols[nPosMed,nDel]                              
    		If Empty(aOBJETOS[OBJ_INS,nFldLab]:aCols[nPosMed,nPosInst])
				If lDeleta
					aOBJETOS[OBJ_INS,nFldLab]:aCols[nPosMed,nDel] := .T.
				Else
					If !Empty(cFamIns) .And. Empty(aOBJETOS[OBJ_INS,nFldLab]:aCols[nPosMed,nPosTip])
						aOBJETOS[OBJ_INS,nFldLab]:aCols[nPosMed,nPosTip] := cFamIns
					Endif
				EndIf	
				lRetorno := .F.        
		    EndIf
		Else
			If lConDel
				lRetorno := .F.
			EndIf	    
		EndIf                            

    Else
	    nDel := Len(aResultados[nPosLab,_INS,nPosEns,nPosLinMed,nPosMed])         
		If !aResultados[nPosLab,_INS,nPosEns,nPosLinMed,nPosMed,nDel]        
			If Empty(aResultados[nPosLab,_INS,nPosEns,nPosLinMed,nPosMed,nPosInst])
				If lDeleta
					aResultados[nPosLab,_INS,nPosEns,nPosLinMed,nPosMed,nDel] := .T.       
				Else
					If !Empty(cFamIns) .And. Empty(aResultados[nPosLab,_INS,nPosEns,nPosLinMed,nPosMed,nPosTip])
						aResultados[nPosLab,_INS,nPosEns,nPosLinMed,nPosMed,nPosTip] := cFamIns
					Endif
				EndIf	
				lRetorno := .F.        
		    EndIf
		Else
			If lConDel
				lRetorno := .F.
			EndIf	    
		EndIf                            
		
	EndIf
   
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215SumMFE³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Contabiliza medicoes fora de especificacao (tolerancia)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215SumMFE(EXPN1,EXPN2,EXPN3,EXPN4,EXPN5,EXPC1)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Laboratorio							  ³±±
±±³          ³ EXPN2 = Posicao do Ensaio								  ³±±
±±³          ³ EXPN3 = Posicao da Medicao								  ³±±
±±³          ³ EXPN4 = LIE com a porcentagem de tolerancia                ³±±
±±³          ³ EXPN5 = LSE com a porcentagem de tolerancia                ³±±
±±³          ³ EXPC1 = Carta do Ensaio                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPN6 =  Quantidade de Medicoes					 	  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215SumMFE(nPosLab,nPosEns,nPosMed,nLIETol,nLSETol,cCarEns)
Local nQtd	   := 0
Local aMediana := {}
Local nPosCpo  := 0
Local nMed     := 0                                                         
Local aHeadTmp := {}
Local cEnsaio  := " "                              
Local nQtdmed  := 0
Local nQtdCpo  := 0

aHeadTmp := aClone(aSavHeadEns[nPosLab,nPosEns])
cEnsaio  := aResultados[nPosLab,_ENS,nPosEns,ENSAIO]
nQtdMed  := Q215QtdMed(cEnsaio)

If cCarEns <> "TXT" 
	If cCarEns <> "P  "
		nPosCpo  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDICA"})
		nQtdCpo  := (nPosCpo+nQtdMed-1)
		For nPosCpo := nPosCpo to nQtdCpo 
			If AllTrim(aHeadTmp[nPosCpo,2]) == "QES_MEDICA"	
			
				nMed := SuperVal(aResultados[nPosLab,_MED,nPosEns,nPosMed,nPosCpo])			
	
				If cCarEns $ "XBR/XBS/IND/HIS"
					If QE7->QE7_MINMAX == "1"  //Controla Minimo e Maximo
						If nMed > nLSETol .or. nMed < nLIETol
							nQtd++
						EndIf
					ElseIf QE7->QE7_MINMAX == "2" //Controla Minimo
						If nMed < nLIETol
							nQtd++
						EndIf
					ElseIf QE7->QE7_MINMAX == "3" //Controla Maximo
						If nMed > nLSETol
							nQtd++
						EndIf
					EndIf
		
				ElseIf cCarEns $ "NP /C  "
					If nMed > nLSETol .Or. nMed < nLIETol
						nQtd++
					EndIf

				ElseIf cCarEns == "XMR"
					aAdd(aMediana,nMed)

				EndIf
			
			EndIf
			
		Next nPosCpo

	EndIf

	If cCarEns == "P  "
		nPosCpo  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDIPA"})
		
		//Percentual nao-conforme	
		If aResultados[nPosLab,_MED,nPosEns,nPosMed,nPosCpo] < nLIETol .Or.;
			aResultados[nPosLab,_MED,nPosEns,nPosMed,nPosCpo] > nLSETol 
			nQtd++
		EndIf

	ElseIf cCarEns == "U  "                 
		nPosCpo  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDICA"})
		
		//segunda medicao
		If aResultados[nPosLab,_MED,nPosEns,nPosMed,nPosCpo+1] < nLIETol 
			nQtd++
        EndIf
		
	ElseIf cCarEns == "XMR"
		nMed := QA_CALXM(aMediana) 	//Calcula mediana

		If QE7->QE7_MINMAX == "1"  //Controla Minimo e Maximo
		
			// Verifica se a Mediana est  dentro dos limites c/ tolerancia
			If nMed > nLSETol .or. nMed < nLIETol
				nQtd++
			EndIf

		ElseIf QE7->QE7_MINMAX == "2" // Controla Minimo
			If nMed < nLIETol
				nQtd++
			EndIf

		ElseIf QE7->QE7_MINMAX == "3" // Controla Maximo
			If nMed > nLSETol
				nQtd++
			EndIf
		EndIf
	EndIf
		
Else	
	nPosCpo  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QEQ_RESULT"})
	If aResultados[nPosLab,_MED,nPosEns,nPosMed,nPosCpo] == "R"
		nQtd++
	EndIf

EndIf
	
Return(nQtd)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215VldNco³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a validacao da nao-conformidade informada.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldNco(EXPC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo da nao-conformidade 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID QEU_NAOCON										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldNco(cCodNco)
Local lRetorno  := .T.
Local cSeek
Local nX
Local nPosDel   := Len(aCols[N])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se mudou a NC (Alterou o campo ja' digitado) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aCols[N,nPosNC]) .And. !Empty(cCodNco) .And. aCols[N,nPosNC] <> cCodNco
	Help(" ",1,"Q215047") 
	lRetorno := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a nao-conformidade ja existe				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	For nX := 1 to Len(aCols)          
		If !aCols[nX,nPosDel]
			If cCodNco == aCols[nX,nPosNC] .And. !aCols[N,nPosDel]
				Help(" ",1,"Q215048") 
				lRetorno := .F.
			EndIf
		EndIf
	Next nI
EndIf

If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Nao-conformidade esta cadastrada no SAG		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SAG->(dbSetOrder(1))
	If SAG->(MsSeek(xFilial("SAG")+cCodNco))
		aCols[N,nPosCla] := SAG->AG_CLASSE
	Else
		Help(" ",1,"Q215049") 
		lRetorno := .F.	
	EndIf
	
EndIf

If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se as nao-conformidades estao associadas ao ensaio  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSeek := (QEK->QEK_PRODUT+QEK->QEK_REVI+cEnsaio)
	
	QE9->(dbSetOrder(1))
	If QE9->(MsSeek(xFilial("QE9")+cSeek))
	
		If QE9->(MsSeek(xFilial("QE9")+cSeek+cCodNco))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Sugere a classe da nao-conformidade								   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCols[N,nPosCla] := QE9->QE9_CLASSE

		Else
			Help(" ",1,"Q215050")  
			lRetorno := .F.	
		EndIf
	
	Else          

		QE2->(dbSetOrder(1))
		If QE2->(MsSeek(xFilial("QE2")+cEnsaio))
		
			If QE2->(MsSeek(xFilial("QE2")+cEnsaio+cCodNco))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Sugere a classe da nao-conformidade								   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCols[N,nPosCla] := QE2->QE2_CLASSE
			Else        
				Help(" ",1,"Q215050") 
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
	
	If lRetorno
		aCols[N,nPosNum] := 1 
	EndIf
	
EndIf

If lRetorno
	//Preenche a Descricao da NC
	aCols[N,nPosDNC] := A020DNCo(cCodNco)

	//Preenche a Descricao da Classe
	aCols[N,nPosDCl] := A040DCla(aCols[N,nPosCla])
EndIf                                              

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215VldNNC³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida o campo Numero de Nao conformidades 			  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldNNC(EXPN1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Quantidade de nao-conformidades informadas		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID QEU_NUMNC										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldNNC(nNumNco)
Local lRetorno := .T.

If nNumNco <= 0      
	Help(" ",1,"Q215051") 
	lRetorno := .F.
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215VldCla³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida campo Classe da Nao Conformidade					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldCla(EXPC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo da Classe da nao-conformidade				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID QEU_CLASSE										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldCla(cClasse)
Local lRetorno := .T.

QEE->(dbSetorder(1))
If QEE->(!MsSeek(xFilial("QEE")+cClasse))
	Help(" ",1,"Q215052") 
	lRetorno := .F.
EndIf

If lRetorno
	aCols[N,nPosDCl] := A040DCla(cClasse)
	M->QEU_DESCLA	  := aCols[N,nPosDCl]
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215F3Nco ³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta a consulta especifica  no SXB, para as nao-conformida³±±
±±³			 ³ des.														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215F3Nco()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo da Classe da nao-conformidade				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_F3 QEU_NAOCON											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215F3Nco()
Local lOkQE9   := .F.
Local lOkQE2   := .F.
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe NC associada no QE9 							   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE9->(dbSetorder(1))
If QE9->(MsSeek( xFilial("QE9")+QEK->QEK_PRODUT+QEK->QEK_REVI+cEnsaio))
	lOkQE9 := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao exista NC no QE9 verifica no QE2 						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lOkQE9
	QE2->(dbSetOrder(1))
	If QE2->(MsSeek(xFilial("QE2")+cEnsaio))
		lOkQE2 := .T.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ De acordo com os dados encontrados dispara uma consulta F3		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOkQE9
	lRetorno := ConPad1(,,,"NC1",,,.F.)
Elseif lOkQE2
	lRetorno := ConPad1(,,,"NC2",,,.F.)
Else
	lRetorno := ConPad1(,,,"SAG",,,.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso a consulta F3 tenha sido executada fora do SAG, posiciona  no ³
//³ SAG , pois o retorno da consulta e o proprio campo.   			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOkQE9
	SAG->(dbSetOrder(1))
	SAG->(MsSeek( xFilial("SAG")+QE9->QE9_NAOCON))

ElseIf lOkQE2
	SAG->(dbSetOrder(1))
	SAG->(MsSeek(xFilial("SAG")+QE2->QE2_NAOCON))

EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215NcoLOk³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a validacao dos dados das nao-conformidades		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215NcoLOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215NcoLOk()
Local lRetorno := .T.

If !aCols[N,Len(aCols[N])] 
	If Empty(aCols[N,nPosNc]) 
		lRetorno := .F.
	Else            
		If Empty(aCols[N,nPosNum]) .Or. Empty(aCols[N,nPosCla])
			lRetorno := .F.		
		EndIf	
	EndIf
EndIf

If !lRetorno
    Help(" ",1,"Q215060")  
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215NcoTOk³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a validacao dos dados das nao-conformidades		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215NcoTOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215NcoTOk()
Local lRetorno := .T.
Local nNco

For nNco := 1 to Len(aCols)
	If !aCols[nNco,Len(aCols[nNco])] 
		If Empty(aCols[nNco,nPosNc]) 
			lRetorno := .F.
			Exit
		Else            
			If Empty(aCols[nNco,nPosNum]) .Or. Empty(aCols[nNco,nPosCla])
				lRetorno := .F.		
				Exit
			EndIf	
		EndIf
	EndIf   
Next nNco

If !lRetorno
    Help(" ",1,"Q215060")  
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215VldIns³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a validacao do campo codigo do Instrumento		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldIns(EXPC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Instrumento 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID QET_INSTR										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldIns(cCodIns, cRevIns)
Local lRetorno := .T.
Local nQtdMed  := 0
Local nPosDel  := 0
Local nPos	   := 0

Default cRevIns := ""

If lIntQMT //Se estiver integrado com o SIGAQMT
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe o instrumento cadastrado						   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QM2->(dbSetOrder(1))
	If QM2->(MsSeek(xFilial("QM2")+cCodIns+Iif(Empty(AllTrim(cRevIns)),"",INVERTE(cRevIns))))

		lRetorno := .F.
		QM6->(dbSetOrder(1))
		While QM2->(!Eof()) .And. QM2->(QM2_FILIAL+QM2_INSTR) == xFilial("QM2")+cCodIns
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona na Calibracao do Instrumento         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If QM6->(dbSeek(xFilial("QM6")+QM2->QM2_INSTR+QM2->QM2_REVINS))
				lRetorno := .T.
				Exit
			Endif
			QM2->(dbSkip())
		Enddo

		If !lRetorno
			Help(" ",1,"Q215068") 
			lRetorno := .F.
		Endif

		If lRetorno
		
			If cCarta <> "TXT"
				If !Empty(QE7->QE7_TIPO) .And. QE7->QE7_TIPO <> QM2->QM2_TIPO
					Help(" ",1,"Q215053") 
					lRetorno := .F.
				EndIf
			Else
				If !Empty(QE8->QE8_TIPO) .And. QE8->QE8_TIPO <> QM2->QM2_TIPO
					Help(" ",1,"Q215053")
					lRetorno := .F.
				EndIf
			EndIf
	
			If lRetorno
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Compara a Validade Afericao do Instrumento com a Data Medicao  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				//Verifica o Numero de medicoes cadastradas			
				nQtdMed := Len(aOBJETOS[OBJ_MED,nFldLab,nFldEns]:aCols) 
				If QM2->QM2_VALDAF < aOBJETOS[OBJ_MED,nFldLab,nFldEns]:aCols[nQtdMed,nPosDtaMed]
					Help(" ",1,"Q215054") 
					lRetorno := .F.
				EndIf      

				If lRetorno
					If Empty(QM2->QM2_LAUDO)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se o Instrumento possui Laudo							   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Help(" ",1,"Q215055")  
						lRetorno := .F.
						
					ElseIf QM2->QM2_LAUDO == "1"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se o Laudo do Instrumento ‚ Reprovado 				       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Help(" ",1,"Q215056") 
						lRetorno := .F.
					ElseIf Upper(QM2->QM2_STATUS) == "I"
						MsgInfo(SubStr(OemToAnsi(STR0259),1,54);
							 + CHR(13)+CHR(10) + SubStr(OemToAnsi(STR0259),56))
						lRetorno := .F.
					EndIf
				EndIf
			EndIf

		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os campos Familia e Validade Afericao 					   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetorno
			aCols[N,nPosDVA]   := QM2->QM2_VALDAF
			aCols[N,nPosTip]   := QM6->QM6_TIPO  
			M->QET_VALDAF      := QM2->QM2_VALDAF
			M->QET_TIPO        := QM6->QM6_TIPO
			aCols[N,nPosRvTip] := QM6->QM6_REVTIP
			aCols[N,nPosRvIns] := QM2->QM2_REVINS
			M->QET_REVINS      := QM2->QM2_REVINS
			M->QET_REVTIP      := QM6->QM6_REVTIP
		EndIf
	Else
		Help(" ",1,"Q215057") 
		lRetorno := .F.
	EndIf
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza os campos Familia e Validade Afericao 					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	nPosDel := Len(aCols[N])
	If !aCols[N,nPosDel] .And. !Empty(cCodIns) 	
	
		//Verifica se o Instrumento informado se repete
		nPos := Ascan(aCols,{|x|x[nPosIns]==cCodIns .And. !x[nPosDel]})
		If nPos > 0 .And. nPos <> N                                       
			Help(" ",1,"Q215058")                   
			lRetorno := .F.
		EndIf
	EndIf
EndIf

Return(lRetorno)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215VldQDe³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da Quantidade destruida						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VldQDes(cQtdDes)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Quantidade a ser destruida						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_VALID = QEL_QTDEST									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldQDes(cQtdDes)
Local lRetorno := .T.
Local nQtdDes  := 0

If !Empty(cQtdDes)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o valor digitado e um numero valido				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !QA_VerNum(@cQtdDes)
		Help(" ",1,"Q215033") 
		lRetorno := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a quantidade rejeitada ‚ <= Tamanho do Lote		    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno
		nQtdDes := (SuperVal(M->QEL_TAMLOT)-SuperVal(M->QEL_QTREJ))		
		If SuperVal(cQtdDes) > nQtdDes
			Help(" ",1,"Q215061") 
			lRetorno := .F.
		Else
			//Retorna a quantidade formatada
			M->QEL_QTDEST := cQtdDes
		EndIf
	EndIf
	
Endif

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215IniDes³ Autor ³Paulo Emidio de Barros ³ Data ³26/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Inicia a Quantidade sugerida a ser destruida				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215IniDes()											 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPC1 = Quantidade a ser destruida						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_RELACAO = QEL_QTDEST									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215IniDes()  
Local cQtdDes := '' 

QE6->(dbSetorder(3))
If QE6->(MsSeek(xFilial('QE6')+QEK->(QEK_PRODUT+QEK_REVI)))
	cQtdDes := Str((SuperVal(QEK->QEK_TAMLOT)*QE6->QE6_PEDEST)/100,TamSX3("QEL_TAMLOT")[1])
	QA_VerNum(@cQtdDes)
EndIf	

Return(cQtdDes)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215F3Inst³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta a consulta especifica no SXB para os Instrumentos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215F3Inst()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_F3 QET_INSTR									          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215F3Inst()
Local lRetorno := .T.

If Empty(cFamIns)
	lRetorno := ConPad1(,,,"ICAL",,,.F.)
Else
	lRetorno := ConPad1(,,,"INE",,,.F.)
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215FilIns³ Autor ³Wagner Mobile Costa    ³ Data ³03/02/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Filtra instrumentos filtro para SXB = QIN                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215FilIns()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ X3_F3 QET_INSTR											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215FilIns()

Local lRetorno := .F.

If Empty(cFamIns)
	lRetorno := QM2->QM2_STATUS <> "0"
Else
	lRetorno := QM2->QM2_TIPO == cFamIns
EndIf

If QM2->QM2_VALDAF < aResultados[nLabAtu,_MED,1,nMedAtu,nPosDtaMed]
	lRetorno := .F.
Endif

If lRetorno .And. SuperGetMv("MV_QPVLIN") == "S"	//Validar instrumento ?
	lRetorno := QM2->QM2_LAUDO $ FormatIn(SuperGetMv("MV_QLINS"), "/")
EndIf

Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215InsLOk³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a Linha dos Instrumentos							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215InsLOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215InsLOk()
Local lRetorno := .T.
Local nPosDel  := Len(aCols[N])

If Empty(aCols[N,nPosIns]) .And. !aCols[N,nPosDel] 
	Help(" ",1,"Q215INSNIN")                   
	lRetorno := .F.
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215InsTOk³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a validacao dos dados dos Instrumentos		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215InsTOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215InsTOk()
Local lRetorno := .T.
Local nPosDel  := Len(aCols[Len(aCols)])
Local nIns

For nIns := 1 to Len(aCols)
	If Empty(aCols[nIns,nPosIns]) .And. !aCols[nIns,nPosDel] 
		lRetorno := .F.
	EndIf    
Next nIns

If !lRetorno
	Help(" ",1,"Q215INSNIN")                   
EndIf                

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215QtdMed³ Autor ³Paulo Emidio de Barros ³ Data ³11/09/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Retorna o numero de Medicoes de acordo com a Carta do Ensaio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215QtdMed(EXPC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Ensaio											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPN1 = Numero de Medicoes								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215QtdMed(cEnsaio)
Local nQtdMed := 1  //Valor default

QE1->(dbSetOrder(1))
QE1->(MsSeek(xFilial("QE1")+cEnsaio))
If QE1->QE1_CARTA $ "XBR/XBS/XMR/HIS"
	nQtdMed	:= QE1->QE1_QTDE
ElseIf QE1->QE1_CARTA == "IND"
	nQtdMed	:= 1
ElseIf QE1->QE1_CARTA == "NP "
	nQtdMed	:= 1
ElseIf QE1->QE1_CARTA == "C  "
	nQtdMed	:= 1
ElseIf QE1->QE1_CARTA == "U  "
	nQtdMed	:= 2
ElseIf QE1->QE1_CARTA == "P  "
	nQtdMed	:= 3         
ElseIf QE1->QE1_CARTA == "TMP"	
	nQtdMEd := 1	
EndIf
Return(nQtdMed)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215GerQNC³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a validacao dos dados dos Instrumentos		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215GerQNC(EXPC1,EXPC2,EXPC4,EXPC5)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo da Nao-conformidade						  ³±±
±±³			 ³ EXPC2 = Revisao da Nao-Conformidade						  ³±±
±±³			 ³ EXPC3 = Descricao 1										  ³±±
±±³			 ³ EXPC4 = Descricao 2										  ³±±
±±³			 ³ EXPC5 = Chave da Medicao									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215GerQNC(cCodNco,cRevNco,cMemo1,cMemo2,cChave)
Local aCpoQNC  := {}                                                          
Local cChr     := ""              
Local cTxtNco  := ""
Local aRetQNC  := {}
Local lIntegra := .T.
Local cDescr   := ""
Local nOrdQER  := QER->(IndexOrd())
Local aArea    := GetArea()

QER->(DbSetOrder(4))
QER->(DbSeek(xFilial("QER")+QEU->QEU_CODMED))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso haja alteracao no Resultado, apaga a NC corrente    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(QEU->QEU_CODNC) .And. !Empty(QEU->QEU_REVNC)
	QI2->(dbSetOrder(2))
	If QI2->(MsSeek(xFilial("QI2")+QEU->QEU_CODNC+QEU->QEU_REVNC))
		If QI2->QI2_STATUS == "1"
			aCpoQNC := {}
			Aadd(aCpoQNC,xFilial("QI2"))
			Aadd(aCpoQNC,QEU->QEU_CODNC)
			Aadd(aCpoQNC,QEU->QEU_REVNC)
			If !lQE215QNC
				aRetQNC := QNCGERA(2,aCpoQNC)
			Else 
				ExecBlock("QE215QNC",.f.,.f.,{aCpoQNC,QEU->QEU_CHAVE,"E"})
			EndIF
		Else
			lIntegra:= .F.
		EndIf
	EndIf
EndIf

If lIntegra	

	aCpoQNC := {}
	cChr    := Chr(13)+Chr(10)
	
	//Posiciona nos da Medicao
	QER->(dbSetOrder(4))
	QER->(dbSeek(xFilial("QER")+cChave))

	Aadd(aCpoQNC,{"QI2_MEMO1" ,cMemo1}) 
	Aadd(aCpoQNC,{"QI2_ORIGEM","QIE"})
	Aadd(aCpoQNC,{"QI2_TPFIC" ,"2"})
	Aadd(aCpoQNC,{"QI2_CODPRO",QEK->QEK_PRODUT})
	Aadd(aCpoQNC,{"QI2_LOTE",  QEK->QEK_LOTE})
	Aadd(aCpoQNC,{"QI2_QTDPRO",QEK->QEK_TAMLOT})                                                     
	Aadd(aCpoQNC,{"QI2_DESCR", STR0146+AllTrim(QEK->QEK_PRODUT)+" "+STR0147+QER->QER_REVI}) //" Produto: " ### "Revisao: "
	   					
	If QEK->QEK_TIPONF $ "BD"
		Aadd(aCpoQNC,{"QI2_CODCLI",QEK->QEK_FORNEC})
		Aadd(aCpoQNC,{"QI2_LOJCLI",QEK->QEK_LOJFOR})
		cDescr  := Posicione("SA1",1,xFilial("SA1")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR,"A1_NOME")
		cTxtNco := STR0148+AllTrim(QEK->QEK_FORNEC)+"-"+QEK->QEK_LOJFOR+" - "+cDescr+cChr //"Cliente :"
	Else
		Aadd(aCpoQNC,{"QI2_CODFOR",QEK->QEK_FORNEC})
		Aadd(aCpoQNC,{"QI2_LOJFOR",QEK->QEK_LOJFOR})
		cDescr  := Posicione("SA2",1,xFilial("SA2")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR,"A2_NOME")
		cTxtNco := STR0149+AllTrim(QEK->QEK_FORNEC)+"-"+QEK->QEK_LOJFOR+" - "+cDescr+cChr //"Fornecedor :"
	EndIf
	
	Aadd(aCpoQNC,{"QI2_MEMO2" ,cTxtNco+cMemo2+QER->QER_ENSAIO+STR0094+QER->QER_LABOR+Chr(13)+Chr(10)})  //"  Laboratorio: "
	Aadd(aCpoQNC,{"QI2_FILMAT",QER->QER_FILMAT})
	Aadd(aCpoQNC,{"QI2_MAT"   ,QER->QER_ENSR})
	Aadd(aCpoQNC,{"QI2_OCORRE",QER->QER_DTMEDI})
	Aadd(aCpoQNC,{"QI2_UNIMED",QEK->QEK_UNIMED})
	Aadd(aCpoQNC,{"QI2_ANO"   ,Year(QER->QER_DTMEDI)})
	
	QAA->(dbSetOrder(1))
	If QAA->(dbSeek(QER->QER_FILMAT+QER->QER_ENSR))
		Aadd(aCpoQNC,{"QI2_MATDEP"	,QAA->QAA_CC})
		Aadd(aCpoQNC,{"QI2_FILDEP"	,QER->QER_FILMAT})
		Aadd(aCpoQNC,{"QI2_ORIDEP"	,QAA->QAA_CC})
		Aadd(aCpoQNC,{"QI2_FILORI"	,QER->QER_FILMAT})
	EndIf

	//realiza a Integracao com o QNC
	If !lQE215QNC
		aRetQNC := QNCGERA(1,aCpoQNC)
		RecLock("QEU",.F.)
		QEU->QEU_CODNC := aRetQNC[2] //Codigo da Nao-conformidade
		QEU->QEU_REVNC := aRetQNC[3] //Revisao da Nao-conformidade
		MsUnLock()    
	Else 
		ExecBlock("QE215QNC",.f.,.f.,{aCpoQNC,QEU->QEU_CHAVE,"I"})
	EndIF

	QER->(DbSetOrder(nOrdQER))

EndIf	

RestArea(aArea)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215CalFor³ Autor ³Paulo Emidio de Barros ³ Data ³18/09/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza o tratamento dos ensaios calculados				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215CalFor(EXPN1) 								          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Laboratorio corrente					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215CalFor(nPosLab)          
Local aEnsCal    := {}
Local cCarta     := "" 
Local cEnsCal    := "" 
Local cForAux    := "" 
Local cFormul    := "" 
Local lEnsCal    := .F.  
Local nPosAvg    := 0
Local nPosDes    := 0
Local nPosEns    := 0
Local nPosEnsCal := 0
Local nPosFor    := 0 
Local nX         := 0

For nPosEns := 1 to Len(aResultados[nPosLab,_ENS])
	cCarta  := aResultados[nPosLab,_ENS,nPosEns,CARTA]
	cEnsCal := aResultados[nPosLab,_ENS,nPosEns,ENSAIO]
	lEnsCal := .F. 
	
	If cCarta $ "XBR/XBS/IND/XMR/HIS"
		QE1->(dbSetOrder(1))
		If QE1->(MsSeek(xFilial("QE1")+cEnsCal))
			If QE1->QE1_TIPO == "1"
				QE7->(dbSetOrder(1))
				If QE7->(MsSeek(xFilial("QE7")+QEK->(QEK_PRODUTO+QEK_REVI)+cEnsCal))
		 			cFormul := AllTrim(QE7->QE7_FORMUL)
		 			If !Empty(cFormul)
						lEnsCal := .T.	
		 			EndIf
				EndIf
			EndIf                   
	    EndIf
	EndIf 
	
	If lEnsCal                         
		nPosDes := At("DESVPAD",cFormul) //Posicao do calculo do Desvio Padrao
		nPosAvg := At("AVG",cFormul)     //Posicao do calculo da Media
		
		If nPosDes > 0                                           
		    cForAux := cFormul
 		   	cForAux := Stuff(cForAux,1,nPosDes+7,Space(nPosDes+7))
		  	nPosFor := At("#",cForAux)  
		  	cEnsCal := SubStr(cForAux,nPosFor+1,8)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza o calculo do Desvio Padrao						 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		  	Q215DesPad(nPosLab,nPosEns,cEnsCal)   

	    ElseIf nPosAvg > 0
		    cForAux := cFormul
	    	cForAux := Stuff(cForAux,1,nPosAvg+3,Space(nPosAvg+3))
	    	nPosFor := At("#",cForAux)
	    	cEnsCal := SubStr(cForAux,nPosFor+1,8)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza o calculo da Media								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Q215Media(nPosLab,nPosEns,cEnsCal)	    	

		Else                  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza o calculo Normal da formula						 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    aEnsCal := {}
		    cForAux := cFormul

		    For nX := 1 to Len(cForAux)
		    	nPosFor    := At("#",cForAux)
		       	If nPosFor==0
		    		Exit
		    	EndIF	
		    	nPosEnsCal := Ascan(aResultados[nPosLab,_ENS],{|x|x[ENSAIO]==SubStr(cForAux,nPosFor+1,8)})
		    	Aadd(aEnsCal,{SubStr(cForAux,nPosFor+1,8),nPosEnsCal})
		    	
		    	cForAux := Stuff(cForAux,1,nPosFor+10,Space(nPosFor+10))
		    	nX      := (nPosFor+10)
		    Next nX
		    
			If Len(aEnsCal) > 0
				Q215CalEns(nPosLab,nPosEns,aEnsCal,cFormul)	    
			EndIf    
		
		EndIf    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria as dimensoes referentes a: Nao-Conformidades,Cronicas³
		//³e Instrumentos para o Ensaio Calculado.					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aResultados[nPosLab,_MED,nPosEns])
			If Len(aResultados[nPosLab,_NCO,nPosEns]) < Len(aResultados[nPosLab,_MED,nPosEns]) //nao-conformidades
				Aadd(aResultados[nPosLab,_NCO,nPosEns],aClone(aSavaCols[HEAD_NCS])) 
    		EndIf                          
    		
			If Len(aResultados[nPosLab,_CRO,nPosEns]) < Len(aResultados[nPosLab,_MED,nPosEns]) //Cronicas	                                                  
				Aadd(aResultados[nPosLab,_CRO,nPosEns],aClone({' '})) 
			EndIf                                                   
			
			If Len(aResultados[nPosLab,_INS,nPosEns]) < Len(aResultados[nPosLab,_MED,nPosEns]) //Instrumentos
				Aadd(aResultados[nPosLab,_INS,nPosEns],aClone(aSavaCols[HEAD_INS]))
			EndIf				
		Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a atualizacao do status do ensaio calculado		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lQe215Le 
			aEnsaios[nPosLab,nPosEns,1] := ExecBlock("QE215LE",.F.,.F.,{nPosLab,nPosEns})
		Else
			aEnsaios[nPosLab,nPosEns,1] := q215CalLab(.F.,nPosLab,nPosEns)
		EndIf 
		aEnsaios[nPosLab,nPosEns,2] := Q215StaNco(nPosLab,nPosEns,aEnsaios[nPosLab,nPosEns,1])
		aEnsaios[nPosLab,nPosEns,3] := Q215StaIns(nPosLab,nPosEns)

	EndIf
	
Next nPosEns

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215DesPad³ Autor ³Paulo Emidio de Barros ³ Data ³18/09/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Calcula o Desvio Padrao do Ensaio calculado				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215DesPad(EXPN1,EXPN2,EXPC1)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Laboratorio corrente					  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio calculado						  ³±±
±±³			 ³ EXPC2 = Ensaio a ser calculado o desvio padrao			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215DesPad(nPosLab,nPosEnsCal,cEnsaio)
Local nPosEns  := Ascan(aResultados[nPosLab,_ENS],{|x|x[ENSAIO]==cEnsaio})
Local aHeadTmp := aClone(aSavHeadEns[nPosLab,nPosEns])             
Local nPosMed  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDICA"})
Local nPosKey  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_CHAVE"})
Local nX       := 0
Local nY       := 0
Local nQtdMed  := Q215QtdMed(cEnsaio) 						       
Local nDecimal := QA_NumDec(QE7->QE7_NOMINA) 					   
Local nMedia   := 0
Local nDel	   := 0	 
Local aQtdMed  := {}
Local nTotDes  := 0
Local nDivMed  := 0
Local nIteDel  := 0
Local aResMed  := {}
Local aTotRes  := {}

//Monta Array com as medias
For nX:=1 to nQtdMed
	AADD(aQtdMed,{})
	AADD(aResMed,Space(TamSx3("QES_MEDICA")[1]))  
	AADD(aTotRes,0)
Next nX

For nX := 1 to Len(aResultados[nPosLab,_MED,nPosEns])
	nDel := Len(aResultados[nPosLab,_MED,nPosEns,nX])
	If !aResultados[nPosLab,_MED,nPosEns,nX,nDel]            
		For nY:=1 to nQtdMed
			aTotRes[nY] += Round(Val(StrTran(aResultados[nPosLab,_MED,nPosEns,nX,nPosMed+(nY-1)],",",".")),nDecimal)								
			Aadd(aQtdMed[nY],Round(Val(StrTran(aResultados[nPosLab,_MED,nPosEns,nX,nPosMed+(nY-1)],",",".")),nDecimal))	
		Next nY
	Else
		nIteDel++	
    EndIf
Next nX         

For nX:=1 to nQtdMed
	nDivMed := Len(aQtdMed[nX])              
	nDivMed := If(nDivMed==0,1,nDivMed)
	nMedia  := aTotRes[nX]/nDivMed
    nTotDes := 0

	Aeval(aQtdMed[nX],{|x|nTotDes+=((x-nMedia)**2)})

	nTotDes := nTotDes/If(nDivMed>1,(nDivMed-1),1)
	nTotDes := Round(Sqrt(nTotDes),nDecimal)             
	aResMed[nX] := StrTran(Str(nTotDes,TamSx3("QES_MEDICA")[1],nDecimal),".",",")
Next nX
If Empty(aResultados[nPosLab,_MED,nPosEnsCal,1,nPoskey])
	aResultados[nPosLab,_MED,nPosEnsCal,1] := aClone(aResultados[nPosLab,_MED,nPosEns,Len(aResultados[nPosLab,_MED,nPosEns])])
EndIf                   

nDel := Len(aResultados[nPosLab,_MED,nPosEnsCal,1])

If nIteDel == Len(aResultados[nPosLab,_MED,nPosEns])
	aResultados[nPosLab,_MED,nPosEnsCal,1,nDel] := .T.
Else	
	If aResultados[nPosLab,_MED,nPosEnsCal,1,nDel] 
		aResultados[nPosLab,_MED,nPosEnsCal,1,nDel] := .F.
	EndIf	
EndIf

For nX:=1 to nQtdMed
	aResultados[nPosLab,_MED,nPosEnsCal,1,nPosMed+(nX-1)] := aResMed[nX]
	Q215VerCal(aResMed[nX],.F.,nPosLab,nPosEnsCal,1,aResultados[nPosLab,_ENS,nPosEnsCal,1])
Next nX

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215Media ³ Autor ³Paulo Emidio de Barros ³ Data ³18/09/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Calcula a Media do Ensaio calculado				  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215Media(EXPN1,EXPN2,EXPC1)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Laboratorio corrente					  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio calculado						  ³±±
±±³			 ³ EXPC2 = Ensaio a ser calculado a Media					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215Media(nPosLab,nPosEnsCal,cEnsaio)
Local nPosEns  := Ascan(aResultados[nPosLab,_ENS],{|x|x[ENSAIO]==cEnsaio})
Local aHeadTmp := aClone(aSavHeadEns[nPosLab,nPosEns])             
Local nPosMed  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDICA"})
local nPosKey  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_CHAVE"})
Local nX       := 0
Local nY       := 0
Local nQtdMed  := Q215QtdMed(cEnsaio) 						                                          
Local nDecimal := QA_NumDec(QE7->QE7_NOMINA) 					   
Local nDel	   := 0	
Local nIteDel  := 0
Local nQtdDiv  := 0    
Local aQtdRes  := {} 
Local aMedia   := {}
Local aResMed  := {}

//Monta Array com as medias
For nX:=1 to nQtdMed
	AADD(aMedia,0) 	
	AADD(aQtdRes,0)
	AADD(aResMed,Space(TamSx3("QES_MEDICA")[1])) 	
Next nX

If (nPosMed > 0 .And. nPosEns > 0)

	For nX := 1 to Len(aResultados[nPosLab,_MED,nPosEns])   
		nDel := Len(aResultados[nPosLab,_MED,nPosEns,nX])
		If !aResultados[nPosLab,_MED,nPosEns,nX,nDel]
			For nY:=1 to nQtdMed  
				aQtdRes[nY] += Round(Val(StrTran(aResultados[nPosLab,_MED,nPosEns,nX,nPosMed+(nY-1)],",",".")),nDecimal)				
	        Next nY
			nQtdDiv ++                                                                                                 
		Else
			nIteDel++			
		EndIf
	Next nX         
	If nQtdDiv == 0
		nQtdDiv := 1
	EndIf
	For nY:=1 to nQtdMed  
	   	aMedia[nY]  := Round(aQtdRes[nY]/nQtdDiv,nDecimal)
   		aResMed[nY] := StrTran(Str(aMedia[nY],TamSx3("QES_MEDICA")[1],nDecimal),".",",")
   	Next
EndIf    

If Empty(aResultados[nPosLab,_MED,nPosEnsCal,1,nPosKey])
	aResultados[nPosLab,_MED,nPosEnsCal,1] := aClone(aResultados[nPosLab,_MED,nPosEns,Len(aResultados[nPosLab,_MED,nPosEns])])
EndIf

nDel := Len(aResultados[nPosLab,_MED,nPosEnsCal,1])

If nIteDel == Len(aResultados[nPosLab,_MED,nPosEns])
    aResultados[nPosLab,_MED,nPosEnsCal,1,nDel] := .T.
Else
	If aResultados[nPosLab,_MED,nPosEnsCal,1,nDel]
		aResultados[nPosLab,_MED,nPosEnsCal,1,nDel] := .F.
	EndIf	
EndIf

For nY:=1 to nQtdMed  
	aResultados[nPosLab,_MED,nPosEnsCal,1,nPosMed+(nY-1)] := aResMed[nY]
	Q215VerCal(aResMed[nY],.F.,nPosLab,nPosEnsCal,1,aResultados[nPosLab,_ENS,nPosEnsCal,ENSAIO])
Next nY                                           

Return(aResMed)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215CalEns³ Autor ³Paulo Emidio de Barros ³ Data ³18/09/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza o calculo aritmetico das formulas				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215CalEns(EXPN1,EXPN2,EXPA1,EXPC1)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Laboratorio Corrente					  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio Calculado				  		  ³±±
±±³			 ³ EXPA1 = Vetor com os ensaios a serem calculados			  ³±±
±±³			 ³ EXPC1 = Formula a ser aplicada							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215CalEns(nPosLab,nPosEnsCal,aEnsaio,cFormul)
Local aHeadTmp  := aClone(aSavHeadEns[nPosLab,nPosEnsCal])             
Local nMedCal   := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDICA"})
Local nPosKey   := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_CHAVE"})
Local nPosEnsr  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_ENSR"})  
Local nPosNomEns:= Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_ENSRNO"})
Local nEnsCal   := 0
Local nDel      := 0                   
Local aEnsCal   := {}
Local nMaior    := 0  
Local nQtdEns   := 0   
Local nPosCer   := 0
Local cForAux   := ""
Local cResMed   := ""
Local nQtdMed   := Q215QtdMed(aEnsaio[1,1]) 						                                          
Local nDecimal  := QA_NumDec(QE7->QE7_NOMINA) 					   
Local nX 		:= 0
Local nY   		:= 0
Local nW   		:= 0
Local aMedAtu   := {}         
Local aMedCal   := {}
Local lAtualiza 
Local nComma  
Local cHora     := ""

nDel := Len(aResultados[nPosLab,_MED,nPosEnsCal,1]) //Posicao de item deletado

For nX := 1 to Len(aEnsaio) 
	nEnsCal := aEnsaio[nX,2]
	If nMaior < Len(aResultados[nPosLab,_MED,nEnsCal])  
		nMaior := Len(aResultados[nPosLab,_MED,nEnsCal])  
	EndIf		
Next nX

nQtdEns := Len(aEnsaio) 
aEnsCal := Array(nMaior,nQtdMed,nQtdEns)

For nY:=1 to nMaior
	For nX:=1 to nQtdMed
		For nW:=1 to nQtdEns
			aEnsCal[nY,nX,nW]:= "(0)"
		Next nW
	Next nX
Next nY	

For nX := 1 to Len(aEnsaio) 

	nEnsCal := aEnsaio[nX,2]                                      

 	For nY := 1 to Len(aResultados[nPosLab,_MED,nEnsCal])  
 		
 		If Len(aResultados[nPosLab,_MED,nEnsCal,nY]) > nDel .Or. Len(aResultados[nPosLab,_MED,nEnsCal,nY]) = nDel
	 		If !Empty(aResultados[nPosLab,_MED,nEnsCal,nY,nPosMed])  
		 		If !aResultados[nPosLab,_MED,nEnsCal,nY,nDel]    
					For nW:=1 to nQtdMed
						If !Empty(aResultados[nPosLab,_MED,nEnsCal,nY,nMedCal+(nW-1)])   		
				 		    aEnsCal[nY,nW,nX] := aResultados[nPosLab,_MED,nEnsCal,nY,nMedCal+(nW-1)]  
					    Else
				 		    aEnsCal[nY,nW,nX] := "(0)"
					    EndIf
					Next nW 
				Else
					For nW:=1 to nQtdMed
						aEnsCal[nY,nW,nX] := "DEL"    	
					Next nW
			    EndIf
			Endif    
		Endif	
 	Next nY
 	
Next nX

For nX := 1 to Len(aEnsCal)
	aMedAtu := {}
	For nW := 1 to nQtdMed
		cForAux := cFormul     
		For nY := 1 to Len(aEnsCal[nX,nW])
			nPosCer := At("#",cForAux)
			If nPosCer > 0
				cForAux := Stuff(cForAux,nPosCer,10,aEnsCal[nX,nW,nY])
			EndIf			                             
	    Next nY        

	    If !(At("#",cForAux) > 0) .And. !(At("(0)",cForAux) > 0)
			If nW==1
				aMedAtu := aClone(aResultados[nPosLab,_MED,nEnsCal,Len(aResultados[nPosLab,_MED,nEnsCal])])    
   	 		EndIf       
    
    		If (At("DEL",cForAux) > 0)    
				cResMed        := Space(TamSx3("QES_MEDICA")[1])
				aMedAtu[nDel] := .T.
	    	Else          
    			nComma := At(",",cForAux)
    			If nComma > 0           
	    			cForAux := StrTran(cForAux,",",".")
		    	EndIf	
	    		cResMed := Str((&cForAux),TamSx3("QES_MEDICA")[1],nDecimal)               
    			If nComma > 0	
	    			cResMed := StrTran(cResMed,".",",")
	    		EndIf	
	   			aMedAtu[nDel] := .F.	
    		EndIf
   		    aMedAtu[nMedCal+(nW-1)] := cResMed
   		    aMedAtu[nPosEnsr] := aResultados[nPosLab,_MED,aEnsaio[1,2],nX,nPosEnsr]   	 		
	    EndIf              
    Next nW          
    If Len(aMedAtu) > 0
        Aadd(aMedCal,aClone(aMedAtu))
    EndIf              
Next nX

If Len(aMedCal) > 0 

	lAtualiza := .T.
	
	For nX := 1 to Len(aResultados[nPosLab,_MED,nPosEnsCal])                         
		If !Empty(aResultados[nPosLab,_MED,nPosEnsCal,nX,nPosKey])
			lAtualiza := If(lAtualiza,.F.,lAtualiza)
		EndIf
	Next nX

	If lAtualiza
	   	aResultados[nPosLab,_MED,nPosEnsCal] := aClone(aMedCal)
	   	
	   	For nX := 1 to Len(aResultados[nPosLab,_MED,nPosEnsCal])           
	 		aResultados[nPosLab,_MED,nPosEnsCal,nX,nPosDtaMed] := dDataBase   	
			If Empty(cHora)
				cHora := aResultados[nPosLab,_MED,nPosEnsCal,nX,nPosHorMed]
			Else
				aResultados[nPosLab,_MED,nPosEnsCal,nX,nPosHorMed] := Left(Q_SomaHora(cHora+":00","00:01:00"),5)
				cHora := aResultados[nPosLab,_MED,nPosEnsCal,nX,nPosHorMed]
			EndIf

			For nW:=1 to nQtdMed
				cResMed := aResultados[nPosLab,_MED,nPosEnsCal,nX,nMedCal+(nW-1)]
		    	Q215VerCal(cResMed,.F.,nPosLab,nPosEnsCal,nX,aResultados[nPosLab,_ENS,nPosEnsCal,ENSAIO]) 
	    	Next nW
	    	
		Next nX	     
		
	Else        
		For nX := 1 to Len(aMedCal)
			If nX <= Len(aResultados[nPosLab,_MED,nPosEnsCal])
				For nW:=1 to nQtdMed
					cResMed := aMedCal[nX,nMedCal+(nW-1)]
					aResultados[nPosLab,_MED,nPosEnsCal,nX,nMedCal+(nW-1)] := cResMed
					aResultados[nPosLab,_MED,nPosEnsCal,nX,nDel] := aMedCal[nX,nDel]
					aResultados[nPosLab,_MED,nPosEnsCal,nX,nPosEnsr] 			:= aMedCal[nX,nPosEnsr]
					aResultados[nPosLab,_MED,nPosEnsCal,nX,nPosNomEns]			:= Posicione("QAA",1,xFilial("QAA")+aMedCal[nX,nPosEnsr],"QAA_APELID")  
					
					Q215VerCal(cResMed,.F.,nPosLab,nPosEnsCal,nX,aResultados[nPosLab,_ENS,nPosEnsCal,ENSAIO]) 
				Next nW
			Else                               
				cResMed := aMedCal[nX,nMedCal]                             
				aMedAtu := aClone(aResultados[nPosLab,_MED,nPosEnsCal,Len(aResultados[nPosLab,_MED,nPosEnsCal])])
				Aadd(aResultados[nPosLab,_MED,nPosEnsCal],aClone(aMedAtu))	
				aResultados[nPosLab,_MED,nPosEnsCal,nX,nPosDtaMed] := dDataBase   	
				aResultados[nPosLab,_MED,nPosEnsCal,nX,nPosHorMed] := Q215HorMed(aResultados[nPosLab,_MED,nPosEnsCal])
				aResultados[nPosLab,_MED,nPosEnsCal,nX,nPosKey]    := " "
				aResultados[nPosLab,_MED,nPosEnsCal,nX,nDel]       := aMedCal[nX,nDel]
				aResultados[nPosLab,_MED,nPosEnsCal,nX,nPosEnsr] 	:= aMedCal[nX,nPosEnsr]
				aResultados[nPosLab,_MED,nPosEnsCal,nX,nPosNomEns]	:= Posicione("QAA",1,xFilial("QAA")+aMedCal[nX,nPosEnsr],"QAA_APELIDO")  
				
				Q215VerCal(cResMed,.F.,nPosLab,nPosEnsCal,nX,aResultados[nPosLab,_ENS,nPosEnsCal,ENSAIO]) 
			EndIf           
		Next

	EndIf	
EndIf        

Return(NIL)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215Filtro³ Autor ³Paulo Emidio de Barros ³ Data ³27/09/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza o filtro das Entradas Inspecionadas/a Inspecionar  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215Filtro(EXPL1)				 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPL1 = Indica se as perguntas serao exibidas ao usuario   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215Filtro(lPergunte,lEntrada)
	Local lPerFil
	Local cFiltro	:= ""
	Local oBrw		:= GetObjBrow()
	
	Default lPergunte := .T.
	Default lEntrada  := .F.
	
	lPerFil := Pergunte("QEA215",lPergunte)               
	lPerFil := If(!lPergunte,.T.,lPerfil)
	
	If lPerFil .And. mv_par08 == 2 //nao desliga o Filtro
		cFiltro := "QEK_FILIAL = '"+xFilial("QEK")+"' And "
		If (mv_par01 == 1) .Or. (mv_par01 == 3)  //Pendentes e/ou Ambas
			cFiltro += "("+"QEK_SITENT = '1'" //Entradas sem Medicoes cadastradas
			If mv_par07 == 1 
				cFiltro += " Or QEK_SITENT = '7' Or QEK_SITENT = '8' " //Entrada com Laudos Pendentes
			EndIf
		ElseIf mv_par01 == 2 //Entradas Inspecionadas
			cFiltro += "("+"QEK_SITENT <> '1'"
		EndIf 
		If mv_par01 == 2 .Or. mv_par01 == 3 //Inspecionadas e/ou Ambas
			If mv_par01 # 3
				If mv_par02 == 1 .Or. mv_par03 == 1.Or. mv_par04 == 1 .Or.;
					mv_par05 == 1 .Or. mv_par06 == 1 
					cFiltro += ')'+' And '+'(' 	
				EndIf			         
			EndIf
			If mv_par02 == 1 //Laudo Aprovado 
				cFiltro += If(SubStr(cFiltro,Len(cFiltro),1)=="(",'',' Or ')+;
					"QEK_SITENT = '2'"
			EndIf
			If mv_par03 == 1 //Laudo Reprovado
				cFiltro += If(SubStr(cFiltro,Len(cFiltro),1)=="(",'',' Or ')+;
					"QEK_SITENT = '3'"
			EndIf
			If mv_par04 == 1 //Laudo c/ Liberacao Urgente
				cFiltro += If(SubStr(cFiltro,Len(cFiltro),1)=="(",'',' Or ')+;
					"QEK_SITENT = '4'"
			EndIf
			If mv_par05 == 1 //Laudo c/ Liberacao Condicional                 
				cFiltro += If(SubStr(cFiltro,Len(cFiltro),1)=="(",'',' Or ')+;
					"QEK_SITENT = '5'"
			EndIf
			If mv_par06 == 1 //Laudo com movimentacao de Estoque pendente
				cFiltro += If(SubStr(cFiltro,Len(cFiltro),1)=="(",'',' Or ')+;
					"QEK_SITENT = '6'"
			EndIf
		EndIf          
		cFiltro +=')'
		If ValType(oBrw) != "U"  
			SetMBTopFilter("QEK", cFiltro, .T.)
		EndIf
	Else
		 If ValType(oBrw) != "U"
		     If Type('oBrw:lFilter') != 'U' .and. !oBrw:lFilter
			   cFiltro := "QEK_FILIAL = '"+xFilial("QEK")+"'"
		   	   SetMBTopFilter("QEK", cFiltro, .T.)	
			 EndiF
	    EndIf 
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para ser utilizado antes do Browse          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("Q215BROW")
			cFiltro := ExecBlock( "Q215BROW",.F.,.F.)
			Dbselectarea("QEK")
			Set Filter to  &(cFiltro)   
		EndIf
	EndIf
	
	If !Empty(cFiltro)
		If ValType(oBrw) != "U"  
			oBrw:Refresh(.T.)
		EndIf
		
		If QEK->(Eof())
			Help(" ",1,"Q215001") 
		EndIf
	EndIf        

Return cFiltro

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215LauFin³ Autor ³Paulo Emidio de Barros ³ Data ³04/02/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se o Laudo Final foi alterado para " " (espacos ) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215LauFin()						 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = .T. ou .F.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215LauFin()
Local lRetorno := .T.
Local nLauAnt  := 0
Local cMsgHlp  := ""   
Local nPosLau  

For nLauAnt := 1 to Len(aLauAnt)
	lHelp   := .F.            
	nPosLau := If(nLauAnt == nFldLabGer,1,_LAU)

	If !Empty(aResultados[nLauAnt,nPosLau,nPosLauGer]) 
		If (aResultados[nLauAnt,nPosLau,nPosLauGer] <> aLauAnt[nLauAnt,1]) .And. !Empty(aLauAnt[nLauAnt,1])
			If (AllTrim(aResultados[nLauAnt,nPosLau,nPosJusLau]) == AllTrim(aLauAnt[nLauAnt,2])) .And. Empty(aResultados[nLauAnt,nPosLau,nPosJusLau])
				lRetorno := .F.     
	    	EndIf
		EndIf                          
	Endif
	
	If nFldLAb <> nFldLabGer 
		If M->QEL_LAUDO == cFatRep /* .And. (Empty(M->QEL_JUSTLA) */
			If !EMPTY(aLauAnt[nLauAnt, 1] )
				If (Empty(M->QEL_JUSTLA) .AND. aLauAnt[nLauAnt, 1] <> M->QEL_LAUDO) //alterou o laudo
					lRetorno := .F.
				EndIf 
			EndIf  
		Endif
	Else
		If M->QEL_LAUDO == cFatRep .And. (AllTrim(aResultados[nLauAnt,nPosLau,nPosJusLau]) == AllTrim(aLauAnt[nLauAnt,2])) .And. Empty(aResultados[nLauAnt,nPosLau,nPosJusLau])
			If (Empty(M->QEL_JUSTLA) .AND. aLauAnt[nLauAnt, 1] <> M->QEL_LAUDO) //alterou o laudo
				lRetorno := .F.
			EndIf                 
		EndIf
	Endif

Next nLauAnt

If !lRetorno 
	Help("",1,"HELP",,STR0028,1,0,,,,,,{STR0276})//Não foi informada a justificativa após a alteração do Laudo final da Entrada. ### Verifique e informe as justificativas nas abas de Laudo Geral e Laudo Laboratoriais.
EndIf

Return(lRetorno)		

//Compatibiliza a chamada da nova rotina de Resultados
Function QIEA210()
QIEA215()	
Return(NIL) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215PlAmIn³ Autor ³Paulo Emidio de Barros ³ Data ³06/05/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Analise do Plano de Amostragem Interno					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215PlAmIn(EXPA1,EXPA2,EXPC1,EXPC2,EXPC3,EXPC4,EXPC5)	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPA1 = Array com as Amostragens Simples					  ³±±
±±³			 ³ EXPA2 = Array com as Amostragens Duplas					  ³±±
±±³			 ³ EXPC1 = Tipo do Plano de Amostragem					      ³±±
±±³			 ³ EXPC2 = Nivel do Plano de Amostragem					      ³±±
±±³			 ³ EXPC3 = NQA										  		  ³±±
±±³			 ³ EXPC4 = Tamanho do Lote								      ³±±
±±³			 ³ EXPC5 = Tamanho da Amostra								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nulo														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215PlAmIn(aPlaInt1,aPlaInt2,cTipAmo,cNivPla,cNQA,cTamLot,cTamAmo)
Local nClaNco   := 0               
Local cSeekQA6  
Local cNorma    := QA_Plano(cTipAmo)

If aResultados[1,_PAE,1,1,3] == "PI"
	cNorma := QA_Plano("I")
Endif


//Posiciona no codigo das Amostras
cSeekQA6 := cNorma+cNivPla+Str(SuperVal(cTamLot),TamSX3("QEK_TAMAMO")[1])		

QA6->(dbSetOrder(2)) //QA6_FILIAL+QA6_PLANO+QA6_NIVEL+STR(QA6_LOTSUP,8)
QA6->(MsSeek(xFilial("QA6")+cSeekQA6,.T.))

//Armazena o aceite e rejeite das Amostragens Simples
For nClaNco := 1 to Len(aPlaInt1)           

	//Pesquisa o tamanho da Amostra baseado na classe da nao-conformidade   
	QA7->(dbSetOrder(3)) //QA7_FILIAL+QA7_PLANO+QA7_NQA+QA7_CODAMO+QA7_SEQUE
	If QA7->(MsSeek(xFilial("QA7")+cNorma+cNQA+QA6->QA6_CODAMO+aPlaInt1[nClaNco,2]))
		aPlaInt1[nClaNco,3] := QA7->QA7_NO_ACE //Aceite p/ Plano Normal
		aPlaInt1[nClaNco,4] := QA7->QA7_NO_REJ //Rejeite p/ Plano Normal
		aPlaInt1[nClaNco,5] := If(QA7->QA7_NO_AMO>SuperVal(cTamAmo),SuperVal(cTamAmo),QA7->QA7_NO_AMO) //Tamanho Lote Amostra Normal	
	EndIf

Next nClaNco 

//Armazena o aceite e rejeite das Amostragens Duplas
For nClaNco := 1 to Len(aPlaInt2)           

	//Pesquisa o tamanho da Amostra baseado na classe da nao-conformidade   
	QA7->(dbSetOrder(3))
	If QA7->(MsSeek(xFilial("QA7")+cNorma+cNQA+QA6->QA6_CODAMO+aPlaInt2[nClaNco,2]))
		aPlaInt2[nClaNco,3] := QA7->QA7_SE_ACE
		aPlaInt2[nClaNco,4] := QA7->QA7_SE_REJ
		aPlaInt2[nClaNco,5] := If(QA7->QA7_SE_AMO>SuperVal(cTamAmo),SuperVal(cTamAmo),QA7->QA7_SE_AMO)	
	EndIf

Next nClaNco 

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215FilCQ0³ Autor ³Paulo Emidio de Barros ³ Data ³19/11/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Preenche a Estrutura do aResultados com a Lib/Rej do CQ    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215FilCQ0(EXPC1,EXPC2,EXPN1)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Produto								  ³±±
±±³			 ³ EXPC2 = Numero do Certificado do Fornecedor                ³±±
±±³			 ³ EXPN1 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Falso ou Verdadeiro										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215FilCQ0(cProduto,cCerFor,nOpc)         
Local aAreaAnt := GetArea()
Local aAreaSD7 := {}
Local aColsAux := {}
Local cAcha    := '' 
Local cLocCQ   := GetMV('MV_CQ')
Local cNumCQ   := '' 
Local cSeek    := '' 
Local cTexto   := ''
Local dDataFec := MVUlmes()
Local nAt      := 0
Local nAt1     := 0
Local nHdl     := 0
Local nX       := 0

//Salva o aColsAux do SD7
aHeader := aClone(aSavaHeader[HEAD_EST])
nUsado  := Len(aHeader)

//Define o Numero da Movimentacao no CQ, a partir do QEK_CERFOR
cNumCQ := Left(AllTrim(cCerFor),TamSX3('D7_NUMERO')[1])
cLocCQ := PADR(cLocCQ,TAMSX3("D7_LOCAL")[1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificar data do ultimo fechamento em SX6.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dDatabase <= dDataFec .and. nOpc <> 2
	Help ( ' ', 1, 'FECHTO')
	Return(.F.)
EndIf

dbSelectArea('SD7')
dbSetOrder(1)
If RecCount() == 0
	Return(.F.)
EndIf

//Posiciona-se no Registro de Sequencia 001
If !MsSeek(xFilial('SD7')+cNumCQ+cProduto+cLocCQ+'001',.F.)
	Help('', 1, 'SEMSEQ001')
	Return(.F.)
EndIf	

aAreaSD7 := GetArea()

//Consiste Filial
IF SD7->D7_FILIAL <> xFilial('SD7')
	Help(' ',1,'A000FI')
	Return(.F.)
EndIf

//Verifica o Saldo Atual a ser liberado/estornado
aQtd := A175CalcQt(SD7->D7_NUMERO, SD7->D7_PRODUTO, SD7->D7_LOCAL)
If aQtd[7] == 0
	Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Consiste se existe Quantidade a ser Movimentada              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc==2 //Visualizar
	lEstorno := .F.
ElseIf nOpc==4  .or. nOpc==5//Exclusao ou Estorno do CQ
	lEstorno := .T.
Else
	//Impede Estorno caso nao exista quantidade Liberada ou Rejeitada
	If QtdComp((aQtd[2]-aQtd[4])+(aQtd[3]-aQtd[5])) == QtdComp(0)
	
		//Verifica se o saldo do armazem esta bloqueado
		If !SldBlqSB2(SD7->D7_PRODUTO,SD7->D7_LOCAL)
			Return .F.
		Else	
			lEstorno := .F.                                           
		EndIf	

	//Impede Liberacao/Rejeicao caso nao exista Saldo a Movimentar	
	ElseIf QtdComp(aQtd[6])==QtdComp(0) .Or. !Empty(SD7->D7_LIBERA) 
		lEstorno := .T.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega o conte£do do arquivo MV_DIRCQ+CQ99999.TXT           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTexto := ''
If File(cDirCQ+(cArqCQ:='CQ'+SD7->D7_NUMERO+'.TXT')) .And. (nHdl:=fOpen(cDirCQ+cArqCQ,0+64))>0
	If fClose(nHdl)
		cTexto := MemoRead(cDirCQ+cArqCQ)
	EndIf			
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona ponteiro do arquivo cabeca e inicializa variaveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SD7')
dbSetOrder(1)
MsSeek(cSeek:=xFilial('SD7')+cNumCQ+cProduto+cLocCQ,.F.)
While !Eof() .And. (D7_FILIAL+D7_NUMERO+D7_PRODUTO+D7_LOCAL)==cSeek
	
    Aadd(aColsAux,Array(nUsado+1))          
	For nX := 1 To Len(aHeader) 
		If aHeader[nx,10] <> 'V'
			aColsAux[Len(aColsAux),nX] := &('SD7->'+aHeader[nX,2])
		ElseIf aHeader[nx,10] == 'V'
			If IsHeadRec(aHeader[nX,2])
				aColsAux[Len(aColsAux),nX] := SD7->(RecNo())
			ElseIf AllTrim(aHeader[nX,2]) == "D7_ALI_WT"
			   	aColsAux[Len(aColsAux),nX] := 'SD7'	
			Else    	
				aColsAux[Len(aColsAux),nX] := CriaVar(AllTrim(aHeader[nX,2]))
  			EndIf


			//Adiciona a Descricao do Tipo de Movimenta‡„o no CQ
			If AllTrim(aHeader[nX,2]) == 'D7_DESCRT'					
				If SD7->D7_TIPO  == 0
					aColsAux[Len(aColsAux),nX] := OemToAnsi(STR0173) //'Qtd Original        '
				ElseIf SD7->D7_TIPO == 1		
					aColsAux[Len(aColsAux),nX] := OemToAnsi(STR0174) //'Liberado            '
				ElseIf SD7->D7_TIPO == 2
					aColsAux[Len(aColsAux),nX] := OemToAnsi(STR0175) //'Rejeitado           '
				ElseIf SD7->D7_TIPO == 3
					aColsAux[Len(aColsAux),nX] := OemToAnsi(STR0176) //'Devolucao Liberacao '
				ElseIf SD7->D7_TIPO == 4
					aColsAux[Len(aColsAux),nX] := OemToAnsi(STR0177) //'Devolucao Rejeicao  '
				ElseIf SD7->D7_TIPO == 6
					aColsAux[Len(aColsAux),nX] := OemToAnsi(STR0178) //'Estorno Liberacao   '
				ElseIf SD7->D7_TIPO == 7
					aColsAux[Len(aColsAux),nX] := OemToAnsi(STR0179) //'Estorno Rejeicao    '
				ElseIf SD7->D7_TIPO == 8
					aColsAux[Len(aColsAux),nX] := OemToAnsi(STR0180) //'Despesas Agregadas  '
				ElseIf SD7->D7_TIPO == 9
					aColsAux[Len(aColsAux),nX] := OemToAnsi(STR0181) //'Estorno Despesas    '
				EndIf

			//Adiciona a Descricao do Motivo da Rejeicao ao aColsAux
			ElseIf Upper(AllTrim(aHeader[nX,2])) == 'D7_DESCREJ'
				If SX5->(dbSeek(xFilial('SX5')+'43'+SD7->D7_MOTREJE,.F.))
					aColsAux[Len(aColsAux),nX] := Left(X5Descri(),35)
				ElseIf CYO->(dbSeek(xFilial("CYO")+SD7->D7_MOTREJE,.F.))
					aColsAux[Len(aColsAux),nX] := AllTRim(CYO->CYO_DSRF)
				EndIf	                    

			//Adiciona a Observacao ao aColsAux
			ElseIf AllTrim(aHeader[nX,2]) == 'D7_OBS'
				cAcha := OemToAnsi(STR0182)+Str(SD7->D7_TIPO,1)+OemToAnsi(STR0183)+SD7->D7_SEQ+OemToAnsi(STR0184)  //'[TIPO:' ### '/SEQ:' ### '/A]'
				nAt   := At(cAcha,cTexto)
				cAcha := OemToAnsi(STR0185)+Str(SD7->D7_TIPO,1)+OemToAnsi(STR0186)+SD7->D7_SEQ+OemtoAnsi(STR0187) //'[TIPO:' ### '/SEQ:' ### '/Z]'
				nAt1  := At(cAcha,cTexto)
				aColsAux[Len(aColsAux),nX] := If(nAt>0.And.nAt1>0,SubStr(cTexto,nAt+20,nAt1-nAt-21),' ')
			EndIf

		EndIf
	
		If !Empty(GetSx3Cache(aHeader[nX,2],"X3_CAMPO"))
			Aadd(aHeaderPro,{GetSx3Cache(aHeader[nX,2],"X3_CAMPO"),GetSx3Cache(aHeader[nX,2],"X3_PROPRI")})
		EndIf	

    Next
	aColsAux[Len(aColsAux),nUsado+1] := .F.
	
	dbSelectArea('SD7')
	dbSkip()
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forca o campo D7_ESTORNO na 2a. posicao do aColsAux          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
A175Acerta(@aHeader,@aColsAux)

aSavaHeader[HEAD_EST] := aClone(aHeader)

For nX := 1 to Len(aHeader)
	If Upper(AllTrim(aHeader[nX, 2])) == 'D7_TIPO'
		nPosTipo := nX
	ElseIf Upper(AllTrim(aHeader[nX, 2])) == 'D7_DESCREJ'
		nPosDesc := nX
	ElseIf Upper(AllTrim(aHeader[nX, 2])) == 'D7_QTDE'
		nCQPosQtde := nX
	ElseIf Upper(AllTrim(aHeader[nX, 2])) == 'D7_LOCDEST'
		nCQPosLDes := nX
	ElseIf Upper(AllTrim(aHeader[nX, 2])) == 'D7_DATA'
		nCQPosData := nX
	ElseIf Upper(AllTrim(aHeader[nX, 2])) == 'D7_ESTORNO'
		nCQPosEsto := nX
	ElseIf Upper(AllTrim(aHeader[nX, 2])) == 'D7_MOTREJE'
		nCQPosMRej := nX
	ElseIf Upper(AllTrim(aHeader[nX, 2])) == 'D7_OBS'
		nCQPosObs := nX
	ElseIf Upper(AllTrim(aHeader[nX, 2])) == 'D7_QTSEGUM'
		nCQPosQtd2 := nX
	ElseIf Upper(AllTrim(aHeader[nX, 2])) == 'D7_NUMSEQ'
		nCQPosNSeq := nX
	ElseIf Upper(AllTrim(aHeader[nX, 2])) == 'D7_LOCALIZ'
		nPosLocLz  := nx
	ElseIf Upper(AllTrim(aHeader[nX, 2])) == 'D7_NUMSERI'
		nPosNumSer := nX
	ElseIf Upper(AllTrim(aHeader[nX, 2])) == 'D7_SERVIC'
		nPosService:= nX
	ElseIf Upper(AllTrim(aHeader[nX, 2])) == 'D7_TPESTR'
		nPosEstrut:= nX
	ElseIf Upper(AllTrim(aHeader[nX, 2])) == 'D7_DTVALID'
		nPosDtVld := nX
	EndIf
Next nX	

RestArea(aAreaSD7)
RestArea(aAreaAnt)

Return(aColsAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215AtuCQ0³ Autor ³Paulo Emidio de Barros ³ Data ³19/11/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Liberacao/Rejeicao do Material no CQ						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215AtuCQ0(EXPO1,EXPN1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Objeto do Folder Movimentacao no CQ                ³±±
±±³			 ³ EXPN1 = Opcao do aRotina								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Falso ou Verdadeiro										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215AtuCQ0(oDlg,nOpc)

Local nSavRot := aRotina[nOpc,4]  
Local nLib 
Local nRej 
Local oGetLot
Local oGetNLot 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis.                						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado     := 0 
aHeader    := {}

cA175Num   := SD7->D7_NUMERO
cA175Prod  := SD7->D7_PRODUTO
cA175Loc   := SD7->D7_LOCAL
cA175OrigL := SD7->D7_ORIGLAN
cA175Chave := SD7->D7_PRODUTO+SD7->D7_DOC+SD7->D7_SERIE+SD7->D7_FORNECE+SD7->D7_LOJA 
cA175UM    := SB1->B1_UM
cA175LoteC := SD7->D7_NUMLOTE
cA175LotCt := SD7->D7_LOTECTL
nPotenc175 := SD7->D7_POTENCI
nPotencOri := SD7->D7_POTENCI

If !lEstorno
	Aadd(aAlter,'D7_DATA')
	Aadd(aAlter,'D7_TIPO')
	Aadd(aAlter,'D7_QTDE')
	Aadd(aAlter,'D7_OBS')
	Aadd(aAlter,'D7_QTSEGUM')
	Aadd(aAlter,'D7_MOTREJE')
	Aadd(aAlter,'D7_LOCDEST')
	If Localiza(SD7->D7_PRODUTO,.T.)
		Aadd(aAlter,'D7_LOCALIZ')
		Aadd(aAlter,'D7_NUMSERI')
		If IntWms(SD7->D7_PRODUTO)
			aAdd(aAlter, 'D7_SERVIC')
		EndIf
	EndIf
Else
	Aadd(aAlter,'D7_DATA')
	Aadd(aAlter,'D7_ESTORNO')
	Aadd(aAlter,'D7_OBS')
EndIf

aHeader := aClone(aSavaHeader[HEAD_EST])     
nUsado  := Len(aHeader)    
aCols   := aClone(aResultados[nFldLibCQ0])
N 	   	:= 1

nAColsIni := Len(aCols)

nLib := (aQtd[2]-aQtd[4])
nRej := (aQtd[3]-aQtd[5])

//Posiciona o codigo do Produto para exibir a Descricao
SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial('SB1')+SD7->D7_PRODUTO,.F.))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis.                						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 001.5,002 To 034,386.2 Of oDlg Pixel

@ 08,05 Say OemToAnsi(STR0188) Of oDlg Pixel //'Lote:'
@ 08,27 MsGet oGetLot VAR SD7->D7_LOTECTL Of oDlg Pixel COLOR CLR_BLUE                                 
oGetLot:lReadOnly := .t.
	
@ 08,100 Say OemToAnsi(STR0189) Of oDlg Pixel //'Sub-Lote:'
@ 08,127 MsGet oGetNLot VAR  SD7->D7_NUMLOTE Of oDlg Pixel COLOR CLR_BLUE                                 
oGetNLot:lReadOnly := .t.

@ 08,200 Say OemToAnsi(STR0190) Of oDlg Pixel //'Potencia:'
@ 08,227 MsGet oGetPot VAR nPotenc175 Of oDlg Pixel COLOR CLR_BLUE                                 
oGetPot:lReadOnly := .t.
	
@ 23,05 Say OemToAnsi(STR0191) Of oDlg Pixel //'Qtd.Original:'
@ 23,27 Say aQtd[1] Picture PesqPictQt("B2_QATU",14) Of oDlg Pixel COLOR CLR_BLUE                                 

@ 23,100 Say OemToAnsi(STR0192) Of oDlg Pixel //'Qtd.Liberada:'
@ 23,127 Say nLib Picture PesqPictQt("B2_QATU",14) Of oDlg Pixel COLOR CLR_BLUE                                 

@ 23,200 Say OemToAnsi(STR0193) Of oDlg Pixel //'Qtd.Rejeitada:'
@ 23,227 Say nRej Picture PesqPictQt("B2_QATU",14) Of oDlg Pixel COLOR CLR_BLUE                                 

@ 23,300 Say OemToAnsi(STR0194) Of oDlg Pixel //'Saldo:'
@ 23,327 Say aQtd[6] Picture PesqPictQt("B2_QATU",14) Of oDlg Pixel COLOR CLR_BLUE                                 

If nOpc <> 2           
	If lEstorno             
		aRotina[nOpc,4] := 6
	Else
		aRotina[nOpc,4] := 4
	EndIf	   
EndIf

aOBJETOS[OBJ_ESTOQUE] := MSGetDados():New(048,002,203.5,499.5,nOpc,'A175LinOk','A175TudOk','+D7_SEQ',.T.,aAlter,1,.F.,MAXGETDAD,'A175GetDad()',,,'A175GetDad(.T.)',oDlg)
aOBJETOS[OBJ_ESTOQUE]:oBrowse:Hide()  
aOBJETOS[OBJ_ESTOQUE]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

If nOpc <> 2
	aRotina[nOpc,4] := nSavRot
EndIf	

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215AtuSit³ Autor ³Paulo Emidio de Barros ³ Data ³26/11/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza a Situacao da Entrada Inspecionada/a Inspecionar  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215AtuSit(EXPC1,EXPL1,EXPL2,EXPN1)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Laudo da Entrada Inspecionada/a Inspecionar        ³±±
±±³			 ³ EXPL1 = Indica se ha Medicoes cadastradas				  ³±±
±±³			 ³ EXPL2 = Indica se ha Integracao com Estoque			      ³±±
±±³			 ³ EXPN1 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215AtuSit(cLaudo,lMedicao,lMovEst,nOpc)
Local lSaldo     := .T.  
Local nPosLau    := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_LAUDO"}) 
Local lLauDef    := .F. //Indica que a Entrada nao possui Laudo definido para os Laboratorios
Local lLabSemLau := .F. //Indica se existe Laboratorio sem Laudo definido   

cLaudo   := If(cLaudo==NIL," ",cLaudo)
lMedicao := If(lMedicao==NIL,.F.,lMedicao)
lMovEst  := If(lMovEst==NIL,.F.,lMovEst)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os Fatores do IQP									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QED->(DbSetOrder(1))
QED->(MsSeek(xFilial("QED")+cLaudo))

RecLock("QEK",.F.)                 
If cLaudo == " " //Entrada Excluida
	QEK->QEK_SITENT := "1" 
ElseIf cLaudo $ cFatApr  //Laudo Aprovado              
	QEK->QEK_SITENT := "2"
ElseIf cLaudo == cFatRep  //Laudo Reprovado
	QEK->QEK_SITENT := "3"
ElseIf cLaudo == cFatLU   //Laudo com Liberacao Urgente
	QEK->QEK_SITENT := "4"
ElseIf cLaudo $ cFatApC   //Laudo Aprovado condicionalmente    
	QEK->QEK_SITENT := "5"   
Else // Para casos que fojem do padrao verifico diretamente o Codigo da Categoria
	If QED->(!EOF())
		If QED->QED_CATEG == "1"		// Aprovacao Total
			QEK->QEK_SITENT := "2"		// Laudo Aprovado  
		ElseIf QED->QED_CATEG == "2"	// Aprovado Parcial
			QEK->QEK_SITENT := "5"		// Laudo Aprovado Condicionalmente
		ElseIf QED->QED_CATEG == "3"	// Reprovado Total
			QEK->QEK_SITENT := "3"		// Laudo Reprovado
		ElseIf QED->QED_CATEG == "4"	// Liberado Urgente
			QEK->QEK_SITENT := "4"		// Laudo com Liberacao Urgente
		EndIf   
	EndIf
EndIf      

If lMedicao
	If QEK->QEK_SITENT == "1" 
		//Verifica se Existe Laudo definido para os laboratorios
		Aeval(Array(nQtdLab),{|x,y|lLauDef:=If(!Empty(aResultados[y,_LAU,nPosLau]),.T.,lLauDef),;
			lLabSemLau:=If(Empty(aResultados[y,_LAU,nPosLau]),.T.,lLabSemLau)})

        If lLabSemLau
        	QEK->QEK_SITENT := "8"
        Else
        	QEK->QEK_SITENT := "7"
		EndIf
	EndIf		
Else
	//Caso nao exista medicoes cadastradas e apresente laudo diferente dos laudos ABCDEU, gravar leds de acordo com o QED.
	If !Empty(cLaudo) .and. !(cLaudo $ "A|B|C|D|E|U")
		QED->(dbSetOrder(1))
		If QED->(dbSeek(xFilial("QED")+cLaudo))
			If QED->QED_CATEG == "1"
				QEK->QEK_SITENT := "2"			
			ElseIf QED->QED_CATEG == "2"
				QEK->QEK_SITENT := "5"	
			ElseIf QED->QED_CATEG == "3" 
				QEK->QEK_SITENT := "3"			
			ElseIf QED->QED_CATEG == "4"			
				QEK->QEK_SITENT := "4"			
			Endif
		Endif
	Endif 
EndIf      
MsUnLock()                      

If lMovEst .And. !Empty(cLaudo) 

	//Verifica se o Material no CQ foi totalmente Liberado/Rejeitado
	lSaldo := Q215SldCQ(QEK->QEK_PRODUT,QEK->QEK_CERFOR,If(nOpc==4,.T.,.F.))			

	RecLock("QEK",.F.)                 
	If cLaudo == ''           
		If nOpc == 4 .And. !lSaldo
			QEK->QEK_SITENT := "6" //Laudo com movimentacao de Estoque pendente
		Else
			QEK->QEK_MOVEST := " "
		EndIf	
	Else	
		If QEK_SITENT <> "1"
			QEK->QEK_MOVEST := "S"
			If nOpc <> 5 .and. !lSaldo     // quando reversão mantem a ultima situação.
				QEK->QEK_SITENT := "6" //Laudo com movimentacao de Estoque pendente
			EndIf
			If nOpc == 5 				// quando Estorno CQ 
				QEK->QEK_SITENT := "6" //Laudo com movimentacao de Estoque pendente
			EndIf
		EndIf	
	EndIf	
	MsUnLock()                      
EndIf


Return(lSaldo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215SldCQ ³ Autor ³Paulo Emidio de Barros ³ Data ³26/11/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se o Saldo no CQ foi totalmente Liberado/Rejeitado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215SldCQ(EXPC1,EXPC2,EXPL1)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Codigo do Produto                                  ³±±
±±³			 ³ EXPC2 = Numero do Certificado do Fornecedor D7_NUMERO      ³±±
±±³			 ³ EXPL1 = Indica se o Total Liberado sera verificado         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215SldCQ(cProduto,cCerFor,lTotal)
Local aAreaAnt := GetArea()
Local aAreaSD7 := SD7->(GetArea())
Local cLocCQ   := GetMV('MV_CQ')
Local cNumCQ   := Left(AllTrim(cCerFor),TamSX3('D7_NUMERO')[1])
Local aQtd     := {}
Local nLib     := 0
Local nRej     := 0
Local lRetorno := .F.               

lTotal := If(lTotal==NIL,.F.,lTotal) 
cLocCQ := PADR(cLocCQ,TAMSX3("D7_LOCAL")[1])

//Posiciona-se no Registro de Sequencia 001                 
dbSelectArea('SD7')
dbSetOrder(1)
If MsSeek(xFilial('SD7')+cNumCQ+cProduto+cLocCQ+'001',.F.)
    //Verifica o Saldo Liberado/rejeitado	       
	aQtd := A175CalcQt(SD7->D7_NUMERO,SD7->D7_PRODUTO,SD7->D7_LOCAL)

	If aQtd[7] > 0 
		nLib := (aQtd[2]-aQtd[4])
		nRej := (aQtd[3]-aQtd[5])
		
		If lTotal		  
		    //Quantidade Original = Saldo 
			If QtdComp(aQtd[1]) == QtdComp(aQtd[6])
				lRetorno := .T.
			EndIf                        
		Else	
			//Quantidade Original = Quantidade Liberada e Rejeitada
			If QtdComp(nLib+nRej) == QtdComp(aQtd[1])
				lRetorno := .T.
			EndIf
		EndIf
	EndIf
	
EndIf

RestArea(aAreaAnt)
RestArea(aAreaSD7)
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215AtuLauGer³ Autor ³ Paulo Emidio de Barros ³ Data ³26/11/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o Laudo Geral da Entrada a partir das Baixas no CQ    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215AtuLauGer()											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											         	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215AtuLauGer()
Local aAreaAnt := GetArea()
Local aAreaSD7 := SD7->(GetArea())   
Local aAreaQED := QED->(GetArea())
Local nQtdLib  := 0
Local nQtdRej  := 0
Local nQtdTot  := 0 
Local cNumCQ   := Left(AllTrim(QEK->QEK_CERFOR),TamSX3('D7_NUMERO')[1])
Local cLocCQ   := GetMV('MV_CQ')
Local cProduto := QEK->QEK_PRODUT
Local aQtd     := {}

cLocCQ := PADR(cLocCQ,TAMSX3("D7_LOCAL")[1])

//Verifica se se a Liberacao/Rejeicao do CQ foi alterada
If !aOBJETOS[OBJ_ESTOQUE]:lModified
	Return(NIL)
EndIf

//Retorna a Quantidade Liberada e Rejeitada
dbSelectArea('SD7')
dbSetOrder(1)
If MsSeek(xFilial('SD7')+cNumCQ+cProduto+cLocCQ+'001',.F.)
	aQtd := A175ACols(Len(aCols), .T.)
	If aQtd[7] > 0 
		nQtdLib := (aQtd[2]-aQtd[4])
		nQtdRej := (aQtd[3]-aQtd[5])
		nQtdTot := (nQtdLib+nQtdRej)		
	EndIf
EndIf      

aResultados[nFldLabGer,_LAUGER,nPosQtdLib] := Str(SuperVal(nQtdTot),TamSx3("QEL_TAMLOT")[1],TamSx3("D7_QTDE")[2]) //Quantidade Liberada
aResultados[nFldLabGer,_LAUGER,nPosQtdRej] := Str(SuperVal(nQtdRej),TamSx3("QEL_QTREJ")[1],TamSx3("D7_QTDE")[2]) //Quantidade Rejeitada 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sugere o Laudo Final da Entrada de acordo com a Liberacao e/ou³
//³Rejeicao do Material no CQ.									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aResultados[nFldLabGer,_LAUGER,nPosLauGer]<>cFatLU //Liberacao Urgente

	//Laudo Aprovado sem Restricoes
	If SuperVal(aResultados[nFldLabGer,_LAUGER,nPosQtdLib])==SuperVal(QEK->QEK_TAMLOT) .And.;
		SuperVal(aResultados[nFldLabGer,_LAUGER,nPosQtdRej])==SuperVal("0")
		//Altera o Laudo somente se não houver justificativa, pois o usuário pode liberar 100% com um laudo diferente de Aprovado.
		If !(aResultados[nFldLabGer,_LAUGER,nPosLauGer] $ cFatApr) .And. empty(M->QEL_JUSTLA) 
			aResultados[nFldLabGer,_LAUGER,nPosLauGer] := SubStr(cFatApr,1,1)	 //Aprovado
		EndIf
	
	//Laudo Aprovado Parcialmente
	ElseIf SuperVal(aResultados[nFldLabGer,_LAUGER,nPosQtdLib])==SuperVal(QEK->QEK_TAMLOT) .And.;
		SuperVal(aResultados[nFldLabGer,_LAUGER,nPosQtdRej])<SuperVal(QEK->QEK_TAMLOT) .And.;
		SuperVal(aResultados[nFldLabGer,_LAUGER,nPosQtdRej])>SuperVal("0") 
		aResultados[nFldLabGer,_LAUGER,nPosLauGer] := SubStr(cFatApC,1,1) //Condicional
		
	//Laudo Rejeitado Totalmente
	ElseIf SuperVal(aResultados[nFldLabGer,_LAUGER,nPosQtdRej])==SuperVal(QEK->QEK_TAMLOT)
		aResultados[nFldLabGer,_LAUGER,nPosLauGer] := cFatRep	 //Reprovado 
	EndIf       

	//Descricao do Laudo Geral da Entrada Inspecionada                                                  
	aResultados[nFldLabGer,_LAUGER,nPosDesLau] := QE215RDL("QED",1,xFilial("QED")+M->QEL_LAUDO)

EndIf

RestArea(aAreaSD7)
RestArea(aAreaQED)
RestArea(aAreaAnt)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215MsgPrxEnt³ Autor ³ Paulo Emidio de Barros ³ Data ³05/12/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exibe a mensagem para a Entrada a ser Inspecionada			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215MsgPrxEnt()											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											         	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215MsgPrxEnt()
Local aAreaAnt := GetArea()
Local nOrdQEK  := QEK->(IndexOrd())
Local nRecQEK  := QEK->(Recno())
Local cSeek    := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF)
Local cSeekQEL := ''
Local cChave   := ''

Local cEspecie := "QIEA210M" // Mensagem para Proxima Entrada
Local lEdita   := .F.
Local cTitulo  := OemToAnsi(STR0197) //"Entrada"
Local cCabec   := OemToAnsi(STR0198) //"Mensagem para esta Entrada"
Local aTexto   := {}                 
Local cTexto   := ''
Local nTamLin  := TamSX3("QA2_TEXTO")[1]

//Desliga o Filtro acionado na Rotina
Set Filter To 

//Posiciona no Registro da Entrada Atual 
QEK->(dbSetorder(2))    
QEK->(dbGoTo(nRecQEK))

//Pula para o proximo Registro da Entrada
QEK->(dbSkip())       

If QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT) == cSeek
	cNiseri := QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
	cSeek := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)+cNiseri+QEK->(QEK_TIPONF)
    cSeekQEL := cSeek+dTos(QEK->QEK_DTENTR)+QEK->QEK_LOTE+Space(TamSX3('QEL_LABOR')[1])	
	QEL->(dbSetOrder(3))
	If QEL->(dbSeek(xFilial("QEL")+cSeekQEL))
		If !(QEL->QEL_LAUDO $ cFatApr)
			cChave := QEK->QEK_CHAVE      
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Visualiza o Texto da proxima Entrada a Inspecionar           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTexto := QA_RecTxt(cChave,cEspecie,00,nTamLin,"QA2",aTexto)

			If !Empty(cTexto)
				QA_TEXTO(cChave,cEspecie,nTamLin,cTitulo,QEK->QEK_FORNEC+"-"+;
					QEK->QEK_LOJFOR+" - "+QEK->QEK_PRODUT+" - "+dToc(QEK->QEK_DTENTR)+;
					" - "+QEK->QEK_LOTE,@aTexto,1,cCabec,lEdita,"QA2")
			EndIf		
	    EndIf
	EndIf
EndIf

//Restaura a Area do QEK
dbSelectArea("QEK") 
dbSetOrder(nOrdQEK)
dbGoTo(nRecQEK)

RestArea(aAreaAnt)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215VerEns   ³ Autor ³ Paulo Emidio de Barros ³ Data ³20/12/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exibe os Ensaios que nao possuem medicoes informadas			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215VerEns()													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											         	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VerEns()
Local oDlgEns        
Local aFields  := {}
Local aSizes   := {}
Local bBlock
Local oBrwEsm
Local aEnsMed := {}
Local nLab 
Local oBotao

If (nFldLab == nFldLabGer) 
	If !Empty(M->QEL_LAUDO) .And. M->QEL_LAUDO<>cFatLU
		Aadd(aFields,STR0199) //"Laboratorio"
		Aadd(aSizes,35)
		For nLab := 1 to Len(aEnsaios)
			Aeval(aEnsaios[nLab],{|x,y|If(aEnsaios[nLab,y,1]=='P' .And. Upper(aEnsaios[nLab,y,SKPTST+5])<>Upper(STR0200) .and. empty(aresultados[nLab,4,y,1,7]) .And. ascan(aensamoini,aensaios[nLab,y,6]) ==0,; //"Certificar"
				Aadd(aEnsMed,{aResultados[nLab,_LAB],aEnsaios[nLab,y,SEQ+4],	aEnsaios[nLab,y,ENSAIO+4],aEnsaios[nLab,y,CARTA+4],;
				aEnsaios[nLab,y,QTDMED+4],aEnsaios[nLab,y,SKPTST+5],aEnsaios[nLab,y,DESPOR+4]}),NIL)})	
		Next nLab	
	EndIf
	
Else
	If aResultados[nFldLabGer,_LAUGER,nPosLauGer]<>cFatLU
		Aeval(aEnsaios[nFldLab],{|x,y|If(aEnsaios[nFldLab,y,1]=='P' .And. Upper(aEnsaios[nFldLab,y,SKPTST+5])<>Upper(STR0200) .and. empty(aresultados[nFldLAb,4,y,1,7]) .And. ascan(aensamoini,aensaios[nFldlab,y,6]) ==0,; //"Certificar"
			Aadd(aEnsMed,{aEnsaios[nFldLab,y,SEQ+4],aEnsaios[nFldLab,y,ENSAIO+4],aEnsaios[nFldLab,y,CARTA+4],aEnsaios[nFldLab,y,QTDMED+4],;
			aEnsaios[nFldLab,y,SKPTST+5],aEnsaios[nFldLab,y,DESPOR+4]}),NIL)})	
	EndIf
	
EndIf		

If Len(aEnsMed) == 0
	Return(NIL)
EndIf

Aadd(aFields,STR0201) //"Sequencia"
Aadd(aFields,STR0202) //"Ensaio"
Aadd(aFields,STR0203) //"Carta"
Aadd(aFields,STR0204) //"Medicoes"
Aadd(aFields,STR0205) //"Skip-Teste"
Aadd(aFields,STR0206) //"Descricao"

Aadd(aSizes,30)
Aadd(aSizes,30)
Aadd(aSizes,30)
Aadd(aSizes,30)
Aadd(aSizes,30)
Aadd(aSizes,100)

bBlock := {||Afill(Array(Len(aSizes)),' ')}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe os Ensaios que nao possuem medicoes informadas         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
DEFINE MSDIALOG oDlgEns TITLE OemToAnsi(STR0207) From 188,050 TO 416,555 OF oMainWnd Pixel	 //" Ensaios que nao possuem medicoes informadas"

//Monta o browse com os ensaios
oBrwEsm:= TwBrowse():New(0.2,0.35,249.5,095,bBlock,aFields,aSizes,oDlgEns)
oBrwEsm:SetArray(aEnsMed)      
oBrwEsm:lMChange      := .F.      
If (nFldLab == nFldLabGer) 
	oBrwEsm:bLine := {||{aEnsMed[oBrwEsm:nAt,1],aEnsMed[oBrwEsm:nAt,2],aEnsMed[oBrwEsm:nAt,3],;
		aEnsMed[oBrwEsm:nAt,4],	aEnsMed[oBrwEsm:nAt,5],	aEnsMed[oBrwEsm:nAt,6],	aEnsMed[oBrwEsm:nAt,7]}}
Else
	oBrwEsm:bLine := {||{aEnsMed[oBrwEsm:nAt,1],aEnsMed[oBrwEsm:nAt,2],aEnsMed[oBrwEsm:nAt,3],;
		aEnsMed[oBrwEsm:nAt,4],	aEnsMed[oBrwEsm:nAt,5],	aEnsMed[oBrwEsm:nAt,6]}}
EndIf	
//

@ 101, 205 BUTTON oBotao PROMPT OemToAnsi(STR0208) OF oDlgEns PIXEL ACTION oDlgEns:End() SIZE 035,011  //"Retorna"
ACTIVATE MSDIALOG oDlgEns CENTERED

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215IniIns   ³ Autor ³ Eduardo de Souza       ³ Data ³25/02/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Inicializa a validade da calibracao e a familia do instrumento.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215IniIns(ExpC1)                							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Campo que devera ser atualizado   					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											         	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q215IniIns(cCpo)
Local cRet := " "

Default cCpo := " "

DbSelectArea("QM2")
DbSetOrder(1)
If QM2->(DbSeek(xFilial("QM2")+QET->QET_INSTR))
	If cCpo == "QET_VALDAF"
		cRet := QM2->QM2_VALDAF
	ElseIf cCpo == "QET_TIPO"
		cRet := QM2->QM2_TIPO
	EndIf
EndIf

If Empty(cRet)
	If cCpo == "QET_VALDAF"
		cRet := CtoD("  /  /  ")
	ElseIf cCpo == "QET_TIPO"
		cRet := Space(Len(QM2->QM2_TIPO))
	EndIf	
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ Q215ValLote ³ Autor ³ Paulo Emidio de Barros ³ Data ³03/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Altera a data de  Validade do Lote 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215ValLote()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											         	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                              
Function Q215ValLote(lGrava)
Local aAreaAnt    := GetArea()
Local aAreaSB8    := SB8->(GetArea())
Local aAreaSD7    := SD7->(GetArea())
Local cLocCQ      := GetMV('MV_CQ')
Local cNumCQ      := ''
Local cSeek       := ''
Local bBlock      
Local cSeekDD     := ''
Local bBlockDD    
Local cLoteAntX   := ''
Local nSaldoB8    := 0
Local nTotSaldoDD := 0
Local cChaveSDC   := ''
Local bCompSDC 
Local bCompSDC2      
Local cChaveSBF   := ''
Local bComparaSBF
Local lDestrava   := .F.
Local nInd        := 0       
Local dDataValid
Local dDtValdB8

//Compatibiliza as Variaveis utilizadas no MATA390
Private aLotes    := {}
Private aRecno    := {}
Private aRecnoSDD := {}
Private aRecnoSDC := {}
Private aRecnoSBF := {}
Private aHeader   := {}
Private aCols     := {}
Private CurLen    := 0
Private nPosAtu   := 0
Private nPosAnt   := 9999
Private nColAnt   := 9999                    
           
Default lgrava	  := .T.


//Define o Numero da Movimentacao no CQ, a partir do QEK_CERFOR
cNumCQ := Left(AllTrim(QEK->QEK_CERFOR),TamSX3('D7_NUMERO')[1])
cLocCQ := PADR(cLocCQ,TAMSX3("D7_LOCAL")[1])

//Posiciona-se no Registro de Sequencia 001                   
dbSelectArea('SD7')
dbSetOrder(1)
If !MsSeek(xFilial('SD7')+cNumCQ+QEK->QEK_PRODUT+cLocCQ+'001',.F.)
	Help('', 1,'SEMSEQ001')
	Return(NIL)
EndIf	

//Recupera a Rastreabilidade por Lote ou Sublote
If Rastro(QEK->QEK_PRODUT,"S")
	cSeek    := xFilial( "SB8" )+SD7->D7_PRODUTO+SD7->D7_LOTECTL+SD7->D7_NUMLOTE
	bBlock   := {||B8_FILIAL+B8_PRODUTO+B8_LOTECTL+B8_NUMLOTE==cSeek}               
	
	cSeekDD  := xFilial( "SDD" )+SD7->D7_PRODUTO+SD7->D7_LOTECTL+SD7->D7_NUMLOTE
	bBlockDD := {||DD_FILIAL+DD_PRODUTO+DD_LOTECTL+DD_NUMLOTE==cSeekDD}

ElseIf Rastro(QEK->QEK_PRODUT,"L")
	cSeek    := xFilial( "SB8" )+SD7->D7_PRODUTO+SD7->D7_LOTECTL
	bBlock   := {||B8_FILIAL+B8_PRODUTO+B8_LOTECTL==cSeek} 
	
	cSeekDD  := xFilial( "SDD" )+SD7->D7_PRODUTO+SD7->D7_LOTECTL
	bBlockDD := {||DD_FILIAL+DD_PRODUTO+DD_LOTECTL==cSeekDD}

EndIf

//Armazena o Recno dos Lotes a serem avaliados
If bblock <> NIL
	dbSelectArea("SB8")
	dbSetOrder(5)
	If dbSeek(cSeek)
		lDestrava  := If(!lDestrava,.T.,lDestrava)
		cLoteAntX  := "&&"  
		dDtValdB8  := SB8->B8_DTVALID
		
		While !Eof() .And. Eval(bBlock)
			cLoteAntX := If(Rastro(B8_PRODUTO,"S"),B8_NUMLOTE,B8_LOTECTL)
			RecLock("SB8",.F.)
			Aadd(aRecno,Recno())
			nSaldoB8 += SB8->B8_SALDO
			dbSelectArea("SB8")
			dbSkip()
		EndDo
	EndIf
	
	If nSaldoB8 == 0
		RestArea(aAreaAnt)
		Return(NIL)
	EndIf
	
	dbSelectArea("SDD")
	dbSetOrder(3)
	dbSeek(cSeekDD)
	nTotSaldoDD := 0
	While !Eof() .And. Eval(bBlockDD)
	
		If DD_MOTIVO = "VV"
			nTotSaldoDD += DD_SALDO
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Realiza o travamento do SDC									 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			dbSelectArea("SDC")
			dbSetOrder(1)
			cChaveSDC := xFilial("SDC")+SDD->DD_PRODUTO+SDD->DD_LOCAL+"SDD"+SDD->DD_DOC+CriaVar("DC_ITEM")
			bCompSDC  := {||cChaveSDC==DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM}

			If Rastro( SDD->DD_PRODUTO, "S" )
				bCompSDC2 := {||SDD->DD_NUMLOTE==DC_NUMLOTE}
			ElseIf Rastro(SDD->DD_PRODUTO,"L")
				bCompSDC2 := {||SDD->DD_LOTECTL==DC_LOTECTL}
			EndIf

			dbSeek(cChaveSDC)
			While !Eof() .And. Eval(bCompSDC )
				If Eval( bCompSDC2 )
					RecLock( "SDC",.F.)
					Aadd(aRecnoSDC,Recno())
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se mudou o lote faz a trava de registros no SBF 			 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				cChaveSBF   := xFilial("SBF")+DC_PRODUTO+DC_LOCAL+DC_LOTECTL+If(Rastro(DC_PRODUTO,"S"),DC_NUMLOTE,"")
				bComparaSBF := {||cChaveSBF==BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+IF(Rastro(SDC->DC_PRODUTO,"S"),BF_NUMLOTE,"")}
	
				dbSelectArea("SBF")
				dbSetOrder(2)
				dbSeek(cChaveSBF)
				While !Eof() .And. Eval(bComparaSBF)
					 RecLock("SBF",.F.)
					 Aadd(aRecnoSBF,Recno())
					 dbSkip()
				EndDo
				dbSelectArea("SDC")
				dbSkip()
			EndDo
			dbSelectArea("SDD")
		EndIf
		Aadd(aRecnoSDD,Recno())
		
		dbSelectArea("SDD")
		dbSkip()
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Indica o tratamento do MV_QVALLOT para definicao da Data da                 ³ 
	//³ Validade do Lote:                                                           ³ 
	//³ 1 = MANTEM A VALIDADE DO LOTE CADASTRADO NA NOTA FISCAL                     ³
	//³ 2 = ASSUME A VALIDAE INFORMADA NO RESULTADO, ALTERANDO O CAMPO B8_DTVALID   ³
	//³ 3 = ASSUME A MAIOR VALIDADE ENTRE A B8_DTVALID E A QEL_DTVAL                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	dDataValid:= QEK->QEK_DTENTR + QAtuShelf(QEK->QEK_PRODUT,QEK->QEK_REVI)     
	

	If nDtaValLot <> 1
		If nDtaValLot == 2 //"Conteúdo = 2" o sistema irá considerar a data de validade informada no ambiente "Inspeção de Entradas" alterando a data de validade do ambiente "Estoque”                                               
	  		If lGrava
				A390PrcVal(aResultados[nFldLabGer,_LAUGER,nPosValLot],nTotSaldoDD) 
			Endif	
		Else //"Conteúdo = 3"  o sistema assumirá a maior validade informada para o lote.	
			If !Empty(dDtValdB8)
				If dDtValdB8 >= aResultados[nFldLabGer,_LAUGER,nPosValLot]
					M->QEL_DTVAL := dDtValdB8           
					aResultados[nFldLabGer,_LAUGER,nPosValLot]:=dDtValdB8
				Else
					M->QEL_DTVAL := aResultados[nFldLabGer,_LAUGER,nPosValLot]
					If lGrava                                        
						A390PrcVal(aResultados[nFldLabGer,_LAUGER,nPosValLot],nTotSaldoDD) 
					Endif	                                                                     
				Endif				
			Endif	
	    EndIf
	Else //"Conteúdo = 1" o sistema irá considerar a data de validade informada no ambiente "Estoque", alterando a data de validade informada no ambiente Inspeção de entradas;
		M->QEL_DTVAL := IIf(!Empty(dDtValdB8),(dDtValdB8,aResultados[nFldLabGer,_LAUGER,nPosValLot]:=dDtValdB8),aResultados[nFldLabGer,_LAUGER,nPosValLot]) 
	EndIf
	
	If lDestrava
		nInd := 1
		While nInd <= Len(aRecno)
			dbSelectArea("SB8")
			dbGoTo(aRecno[nInd])
			MsUnLock()
			nInd++
		EndDo
	EndIf  
Endif
	
RestArea(aAreaSB8)
RestArea(aAreaSD7)
RestArea(aAreaAnt)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ Q215FilCpo  ³ Autor ³ Paulo Emidio de Barros ³ Data ³12/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define os campos criados no dicionario de dados pelo usuario   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215FilCpo(cAlias,bCampos,aHeaderTmp,aCpoUsu,aCpoQry)		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias												  ³±±
±±³			 ³ EXPB1 = Code Block para avaliacao do aHeader					  ³±±
±±³			 ³ EXPA1 = aHeader a ser inseridos os novos campos				  ³±±
±±³			 ³ EXPA2 = Vetor com os campos criados pelo usuario				  ³±±
±±³			 ³ EXPA3 = Vetor com os campos criados pelo usuario				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											         	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                              
Function Q215FilCpo(cAlias,bCampos,aHeaderTmp,aCpoUsu,aCpoQry)
Local nPosCpo  := 0
Local aStruct  := 0
Local nX       := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos criados pelo usuario						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStruct := FWFormStruct(3,cAlias)[3] 
For nX := 1 to Len(aStruct)
	If cNivel >= GetSx3Cache(aStruct[nX,1],'X3_NIVEL') .And. GetSx3Cache(aStruct[nX,1],"X3_PROPRI") == "U"
		nPosCpo := Ascan(aCpoUsu,{|x|AllTrim(x)==AllTrim(aStruct[nX,1])})
		If nPosCpo == 0		
			Aadd(aCpoUsu,aStruct[nX,1])
			If GetSx3Cache(aStruct[nX,1],"X3_CONTEXT") <> "V"
				Aadd(aCpoQry,aStruct[nX,1])
			EndIf
		EndIf
		Aadd(aHeaderTmp, Q215GetSX3(aStruct[nX,1],"",""))
	EndIf
Next nX

Return(NIL)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ Q215BotDA   ³ Autor ³ Cleber L. Souza        ³ Data ³06/04/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza chamada da rotina de inclusao de anexos.	    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215BotDA(nOpc,nFldEns)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do Browse										  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio corrente							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											         	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215BotDA(nOpc,nFldEns)
Local aAreaAnt := GetArea()
Local oDlg
Local oGet   
Local lAlter   := .F.         
Local aAlterQF7:= {}
Local cAlias   := "QF7"
Local aButtons := {}
Local nOpcA    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esta variavel salva a marca de exclusao da primeira linha no ³
//³ aCols se a mesma estiver como verdadeiro, este tratamento e  ³
//³ realizado, pois se o primeiro item do aCols estiver excluido ³
//³ a Getdados falha na pintura do item marcado para exclusao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lSavDel    := .F.	

Private aHeader := aClone(aSavaHeader[HEAD_ANEXO])
Private aCols   := aClone(aResultados[nFldLab,_ANE,nFldEns])
Private N       := 1
Private nUsado  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define campos que podem ser altertados     					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aAlterQF7,"QF7_DESCRI")

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0214) FROM 000,000 TO 315,645 OF oMainWnd PIXEL  //"Documento Anexo"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se pode ser Alterado / Deletado 					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3 
	lAlter:= .T.
EndIf                   

If aCols[1,Len(aHeader)+1]
   lSavDel := .t.
   aCols[1,Len(aHeader)+1] := .f.
else
   lSavDel := .f.
EndIf

oGet := MSGetDados():New(030,002,155,325,nOpc,"Q215AneLinOk('"+cAlias+"')","Q215AneTudoOk('"+cAlias+"')",,lAlter,aAlterQF7,,,,,,,)
oGet:Refresh()
aCols[1,Len(aHeader)+1] := lSavDel

Aadd(aButtons,{"SDUPROP",{||aCols[N,nPosAne] := QVRFANEXO(nOpc,aCols[N,nPosAne],"QIE"),oGet:Refresh()},OemToAnsi(STR0215),STR0236}) //"Incluir / Visualizar Documento Anexo"###"Doc Anex"

If (nOpc == 3 .Or. nOpc == 4 )              
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(oGet:TudoOk(),(nOpcA:=1,oDlg:End()),.F.)},{||nOpcA:=2,oDlg:End()},,aButtons) CENTERED
Else
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aButtons)
EndIf	  

If nOpcA == 1
	//Salva os arquivos/documentos anexos no vetor aResultados
	aResultados[nFldLab,_ANE,nFldEns] := aClone(aCols) 

	//Atualiza o status do documento anexo
	aEnsaios[nFldLab,nFldEns,4] := Q215StaAne(nFldLab,nFldEns)

EndIf

RestArea(aAreaAnt)
QF7->(DbCloseArea())

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Q215AneLinOk³ Autor ³ Cleber de Souza     ³ Data ³ 06/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas nos Anexos	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215AneLinOk                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q215AneLinOk(cAlias)
Local lRet   := .T.
Local nPosD  := Ascan(aHeader,{|x| Upper(Alltrim(x[2])) == "QF7_DESCRI"})
Local nPosA  := Ascan(aHeader,{|x| Upper(Alltrim(x[2])) == "QF7_ANEXO"})     

If aCols[n,Len(aHeader)+1] == .F.
	If Empty(aCols[N,nPosD]) .Or. Empty(aCols[N,nPosA])
		Help(" ",1,"QDOBRIG") // "Existem campos obrigatorios nao preenchidos"
	   	lRet:= .F.
	EndIf
EndIf

Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Q215AneTudoOk³ Autor ³ Cleber de Souza    ³ Data ³ 06/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia Ok da GetDados nos Anexos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215AneTudoOk                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q215AneTudoOk(cAlias)
Local lRet   := .T.    
Local nY     := 0    
Local nPosD  := Ascan(aHeader,{|x| Upper(Alltrim(x[2])) == "QF7_DESCRI"})
Local nPosA  := Ascan(aHeader,{|x| Upper(Alltrim(x[2])) == "QF7_ANEXO"})

For nY:=1 to Len(aCols)
	If !aCols[nY,Len(aHeader)+1]
		If Empty(aCols[nY,nPosD]) .Or. Empty(aCols[nY,nPosA])
			Help(" ",1,"QDOBRIG") // "Existem campos obrigatorios nao preenchidos"
		   	lRet:= .F.
		EndIf
	EndIf
Next nY 

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215AtuAnexos³ Autor ³ Cleber Souza       ³ Data ³ 07/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava os Anexos associados aos Ensaios					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215AtuAnexos(EXPN1,EXPN2,EXPC1,EXPN2)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Laboratorio			  				  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio  								  ³±±
±±³			 ³ EXPC1 = Numero do Lote									  ³±±
±±³			 ³ EXPC2 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAQIE													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215AtuAnexos(nPosLab,nPosEns,cLote,nOpc,cProd)
Local lDel 
Local cLabor   := aResultados[nPosLab,_LAB]                //Laboratorio corrente
Local cEnsaio  := aResultados[nPosLab,_ENS,nPosEns,ENSAIO] //Ensaio corrente		
Local aAreaAnt := GetArea()
Local aHeadTmp := aClone(aSavaHeader[HEAD_ANEXO]) 
Local nDocAne  := 0
Local nCpoQF7  := 0   

For nDocAne := 1 to Len(aResultados[nPosLab,_ANE,nPosEns])

	lDel   :=  aResultados[nPosLab,_ANE,nPosEns,nDocAne,Len(aResultados[nPosLab,_ANE,nPosEns,nDocAne])]
	
	If nOpc == 4 //Exclusao
		lDel := If(!lDel,.T.,lDel)
	EndIf

	If !Empty(aResultados[nPosLab,_ANE,nPosEns,nDocAne,nPosAne])                          

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Renomeia o Arquivo e sobe o mesmo para o Servidor		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SubStr(aResultados[nPosLab,_ANE,nPosEns,nDocAne,nPosAne],1,2) == "IE"
			cNewAne := aResultados[nPosLab,_ANE,nPosEns,nDocAne,nPosAne]
		Else
			cNewAne := QepAdmAne(aResultados[nPosLab,_ANE,nPosEns,nDocAne,nPosAne],1,"QIE")
		EndIf
		
		dbSelectArea("QF7") 
		dbSetOrder(2)
		If 	MsSeek(xFilial("QF7")+cLabor+cEnsaio+cProd+cLote+cNewAne)
			RecLock("QF7",.F.)					    
			If lDel 
			    dbDelete()
			EndIf   
		Else
			If !lDel
				RecLock("QF7",.T.)					    
				QF7->QF7_FILIAL := xFilial("QF7")
		       QF7->QF7_LABOR  := clabor
	    	  	QF7->QF7_ENSAIO	:= cEnsaio
	        	QF7->QF7_LOTE   := cLote
		       QF7->QF7_ANEXO  := cNewAne
		       QF7->QF7_PRODUT := CProd
		       lGrava := .T.
	        EndIf
	    EndIf
		    
	    If !lDel
		    For nCpoQF7 := 1 to Len(aHeadTmp)   
				If (AllTrim(aHeadTmp[nCpoQF7,2]) <> "QF7_ANEXO")
					If (aHeadTmp[nCpoQF7,10] <> "V") 
						QF7->(FieldPut(FieldPos(AllTrim(aHeadTmp[nCpoQF7,2])),aResultados[nPosLab,_ANE,nPosEns,nDocAne,nCpoQF7]))
					EndIf                                       
				EndIf
			Next nCpoQF7
		EndIf
		MsUnLock()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Remove o arquivo do diretorio							³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lDel
			QepAdmAne(aResultados[nPosLab,_ANE,nPosEns,nDocAne,nPosAne],2,"QIE")
		EndIf	
	    
	EndIf

Next nDocAne

RestArea(aAreaAnt)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ Q215RetMed  ³ Autor ³ Paulo Emidio de Barros ³ Data ³12/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna as medicoes validas de um Ensaio						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215RetMed(nPosLab,nPosEns,nPosMed,cEnsaio,cCarta,aMedicoes)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Laboratorio								  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio									  ³±±
±±³			 ³ EXPN3 = Linha da Medicao corrente no Ensaio				      ³±±
±±³			 ³ EXPC1 = Codigo do Ensaio									      ³±±
±±³			 ³ EXPC2 = Carta do Ensaio									      ³±±
±±³			 ³ EXPA1 = Vetor a ser retornado com as Medicoes				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											         	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                              
Function Q215RetMed(nPosLab,nPosEns,nPosMed,cEnsaio,cCarta,aMedicoes)
Local aHeadTmp := {}
Local nDel     := 0 //posicao da marca de exclusao no aCols 
Local nPosCpo  := 0 //posicao do campo medicao
Local nPosRes  := 0 //posicao do campo Resultado
Local nQtdCpo  := 0
Local nQtdMed  := Q215QtdMed(cEnsaio)           

aHeadTmp := aClone(aSavHeadEns[nPosLab,nPosEns])
nPosRes  := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QER_RESULT"})

nDel := Len(aResultados[nPosLab,_MED,nPosEns,nPosMed]) 
If !aResultados[nPosLab,_MED,nPosEns,nPosMed,nDel]
	If !Empty(aResultados[nPosLab,_MED,nPosEns,nPosMed,nPosRes]) //Resultado da Medicao
		If AllTrim(cCarta) == "U" 
			If !Empty(aResultados[nPosLab,_MED,nPosEns,nPosMed,(nPosRes-1)])
				Aadd(aMedicoes,aResultados[nPosLab,_MED,nPosEns,nPosMed,(nPosRes-1)])			     	
		    EndIf     
		ElseIf AllTrim(cCarta) == "P"                 
			If !Empty(aResultados[nPosLab,_MED,nPosEns,nPosMed,(nPosRes-2)])
				Aadd(aMedicoes,aResultados[nPosLab,_MED,nPosEns,nPosMed,(nPosRes-2)])			     	
		    EndIf     
	    Else
		    nPosCpo := Ascan(aHeadTmp,{|x|Alltrim(x[2])=="QES_MEDICA"})
			nQtdCpo := (nPosCpo+nQtdMed-1)
			For nPosCpo := nPosCpo to nQtdCpo
				If AllTrim(aHeadTmp[nPosCpo,2]) == "QES_MEDICA"	
					If !Empty(aResultados[nPosLab,_MED,nPosEns,nPosMed,nPosCpo])
						Aadd(aMedicoes,aResultados[nPosLab,_MED,nPosEns,nPosMed,nPosCpo])
				    EndIf                                                             
			    EndIf
			Next nPosCpo
		EndIf	
	EndIf   
EndIf
Return(NIL)        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q215Metod ºAutor  ³Microsiga           º Data ³  20/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesquisa a ultima revisao do documento e preenche os camposº±±
±±º          ³ da aCols.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIEA215                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215Metod(nPosLab,nPosEns) 

Local aHeadTmp  := aSavHeadEns[nPosLab,nPosEns]
Local nPosMetod := Ascan(aHeadTmp,{|x|AllTrim(x[2])=="QER_METODO"})
Local nPosRvDoc := Ascan(aHeadTmp,{|x|AllTrim(x[2])=="QER_RVDOC"})

aCols[N,nPosMetod] := aResultados[nPosLab,_ENS,nPosEns,METODO]
aCols[N,nPosRvDoc] := aResultados[nPosLab,_ENS,nPosEns,REVDOC]

Return(.t.)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215F3I	³ Autor ³ Cleber Souza      	³ Data ³ 20/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consulta F3 para os instrumentos filtrando pela familia.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum 			    									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³.T. 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Consulta SXB - QIN										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215F3I()
Local lRet    := .T.
Local cTitulo := OemToAnsi(STR0239) //"Cadastro de Instrumentos"
Local aCampos := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ De acordo com os dados encontrados dispara uma consulta F3 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCampos,{AllTrim(TitSX3("QM2_INSTR")[1]) ,"QM2_INSTR" }) //Instrumento
Aadd(aCampos,{AllTrim(TitSX3("QM2_REVINS")[1]),"QM2_REVINS"}) //Instrumento
Aadd(aCampos,{AllTrim(TitSX3("QM2_VALDAF")[1]),"QM2_VALDAF"}) //Validade Calibracao
Aadd(aCampos,{AllTrim(TitSX3("QM2_TIPO")[1])  ,"QM2_TIPO"  }) //Familia
Aadd(aCampos,{AllTrim(TitSX3("QM6_REVTIP")[1]),"QM6_REVTIP"}) //Revisao da Familia

lRet := Q215ConPIn(cTitulo,"QM2",aCampos)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215ConPIn ³ Autor ³ Cleber Souza         ³ Data ³20/02/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consulta Padrao Especifica - Instrumentos	    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215ConPIn( cTitulo, cAlias, aCampos )
Local oDlg
Local oBtn1
Local oBtn2
Local aListAux	:= {}
Local aHeaderEsp	:= {}
Local nOpc			:= 0
Local cConteudo	:= ''
Local nPos			:= 0
Local cRevi		:= Iif(Empty(QEK->QEK_REVI),QA_UltRevEsp(QEK->QEK_PRODUT,,,,"QIE"),QEK->QEK_REVI) 
Local cQuery		:= " "
Local cProduto	:= QEK->QEK_PRODUT

Local nDtM			:=	Ascan(aSavHeadEns[nFldLab,nFldEns],{|x|Alltrim(x[2])=="QER_DTMEDI"})
Local cDatVal		:= Dtos(aResultados[nFldLab,_MED,nFldEns,nMedAtu,nDtM])
Local nPosInstEsp   := 0
Local nI            := 0      
Local cInstr
Local cRevIns

Private aListPad	:= {}
Private nReg		:= 0
Private oLBrowse

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta aHeader especifico									     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aeval(aCampos,{|aElem|Aadd(aHeaderEsp,aElem[1])})

aArea := GetArea()
cQuery := "SELECT QM2.QM2_FILIAL, QM2.QM2_TIPO, QM2.QM2_INSTR, QM2.QM2_REVINS,QM2.QM2_LAUDO,"
cQuery += "QM2.QM2_VALDAF,QM6.QM6_REVTIP, QM2.R_E_C_N_O_ QM2RECNO"
cQuery += " FROM " + RetSqlName("QM2")+" QM2 ,"
cQuery += RetSqlName("QM6")+" QM6 "
cQuery += "WHERE QM2.QM2_FILIAL='"+xFilial("QM2")+"' AND "

If !Empty(cFamIns)
	cQuery += "QM2.QM2_TIPO = '"+cFamIns+"' AND "
Else 
	cQuery += "QM2.QM2_STATUS <> '0' AND "
EndIf
	
cQuery += "QM6.QM6_INSTR = QM2.QM2_INSTR AND "
cQuery += "QM6.QM6_REVINS = QM2.QM2_REVINS AND "	  
cQuery += "QM2.QM2_LAUDO IN " + FormatIn(SuperGetMv("MV_QLINS"), "/") + " AND "
cQuery += "QM2.QM2_VALDAF >= '"+cDatVal+"' AND "  
cQuery += "QM2.QM2_FLAG = '1' AND "
cQuery += "QM2.D_E_L_E_T_<>'*'"
cQuery += " ORDER BY " + SqlOrder(QM2->(IndexKey()))

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QM2TMP", .F., .T.)

TcSetField( "QM2TMP", "QM2_VALDAF", "D")

dbSelectArea("QM2TMP")
While !Eof()
	aListAux := {}
	For nI := 1 To Len(aCampos)
		cConteudo := QM2TMP->(FieldGet(FieldPos(aCampos[nI,2])))
		Aadd(aListAux,cConteudo)
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Jah estah posicionado no indice e irah atualizar somente o Instrumento na ultima revisao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cInstr <> QM2TMP->QM2_INSTR
		cInstr := QM2TMP->QM2_INSTR
		Aadd(aListAux, QM2RECNO)
		Aadd(aListPad,aListAux)
	EndIf

	dbSkip()
EndDo
dbSelectArea("QM2TMP")
dbCloseArea()
RestArea(aArea)

QM2->(dbSetOrder(1))

If Len(aListPad) == 0
	MsgAlert(STR0237) //"Nao ha  dados conforme selecao !"
	Return .F.
EndIf

DEFINE MSDIALOG oDlg TITLE STR0238+cTitulo From 9,0 To 21,60 OF oMainWnd  //"Consulta - "

oLBrowse:= TWBrowse():New( 0.4, 1, 182, 60,,aHeaderEsp,, oDlg,,,,,,,,,,,,.T.)

oLBrowse:SetArray(aListPad)
oLBrowse:bLine	:=	{ || {aListPad[oLBrowse:nAt,1],aListPad[oLBrowse:nAt,2],Dtoc(aListPad[oLBrowse:nAt,3]),aListPad[oLBrowse:nAt,4],aListPad[oLBrowse:nAt,5]}}
oLBrowse:bLDblClick := {||(nOpc := 1,nReg:=aListPad[oLbrowse:nAt,Len(aListPad[1] ) ],oDlg:End())}
If !Empty(M->QET_INSTR)
	nPosInstEsp := Ascan(aListPad,{|x| Left(x[1],Len(AllTrim(M->QET_INSTR))) == AllTrim(M->QET_INSTR) } )
	If nPosInstEsp > 0
		oLBrowse:nAt:=nPosInstEsp
		oLBrowse:Refresh()
	Endif
Endif

DEFINE SBUTTON oBtn1 FROM	4.0,200 TYPE	1	ACTION (nOpc := 1,cInstr:=aListPad[oLBrowse:nAt,1],cRevIns:=aListPad[oLBrowse:nAt,2],oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON oBtn2 FROM  18.5,200 TYPE	2	ACTION (nOpc := 0,oDlg:End())	ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona registro											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 1
	QM2->(DbSetOrder(1))
	QM2->(dbSeek(xFilial("QM2")+cInstr+Inverte(cRevIns)))
	
	QM6->(DbSetOrder(1))
	QM6->(dbSeek(xFilial("QM6")+cInstr+cRevIns))
EndIf
Return(nOpc == 1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215PaeEns³ Autor ³Paulo Emidio de Barros ³ Data ³05/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de Atualizacao dos Resultados da Entrada.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215PaeEns(EXPO1,EXPN1,EXPN2)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto do Folder a ser exibido o Plano Amostragem  ³±±
±±³			 ³ EXPN1 = Posicao do Laboratorio selecionado				  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio selecionado					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215PaeEns(oFldPAE,nPosLab,nPosEns)
Local aFields := {}
Local aSizes  := {} 
Local bBlock            	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  x[01] = QF4_TIPAMO											 ³
//³  x[02] = QF4_NIVEL											 ³
//³  x[03] = QF4_PLAMO											 ³
//³  x[04] = QF4_NQA											 ³
//³  x[05] = QF5_TAMA1											 ³
//³  x[06] = QF5_ACEI1											 ³
//³  x[07] = QF5_REJEI1											 ³
//³  x[08] = QF5_TAMA2											 ³
//³  x[09] = QF5_ACEI2											 ³
//³  x[10] = QF5_REJEI2											 ³
//³  x[11] = QF4_DESCRI											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Titulos das colunas
Aadd(aFields,AllTrim(TitSX3("QF4_TIPAMO")[1]))
Aadd(aFields,AllTrim(TitSX3("QF4_NIVEL")[1]))
Aadd(aFields,AllTrim(TitSX3("QF4_PLAMO")[1]))
Aadd(aFields,AllTrim(TitSX3("QF4_NQA")[1]))
Aadd(aFields,AllTrim(TitSX3("QF5_TAMA1")[1]))
Aadd(aFields,AllTrim(TitSX3("QF5_ACEI1")[1]))
Aadd(aFields,AllTrim(TitSX3("QF5_REJEI1")[1]))
Aadd(aFields,AllTrim(TitSX3("QF5_TAMA2")[1]))
Aadd(aFields,AllTrim(TitSX3("QF5_ACEI2")[1]))
Aadd(aFields,AllTrim(TitSX3("QF5_REJEI2")[1]))   	                  	
Aadd(aFields,AllTrim(TitSX3("QF4_DESCRI")[1]))

aSizes  := {22,17,20,18,19,12,12,19,12,12,100}
bBlock  := {||Afill(Array(Len(aSizes))," ")}

//Monta o browse com os ensaios                                 
aOBJETOS[OBJ_PAE,nPosLab] := TwBrowse():New(0.2,0.2,490,088,bBlock,aFields,aSizes,oFldPAE)
aOBJETOS[OBJ_PAE,nPosLab]:SetArray(aResultados[nPosLab,_PAE,nPosEns])
aOBJETOS[OBJ_PAE,nPosLab]:bLine:={||{;
	aResultados[nPosLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nPosLab]:nAt,01],;
	aResultados[nPosLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nPosLab]:nAt,02],;
	aResultados[nPosLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nPosLab]:nAt,03],;
	aResultados[nPosLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nPosLab]:nAt,04],;
	aResultados[nPosLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nPosLab]:nAt,05],;
	aResultados[nPosLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nPosLab]:nAt,06],;
	aResultados[nPosLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nPosLab]:nAt,07],;
	aResultados[nPosLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nPosLab]:nAt,08],;
	aResultados[nPosLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nPosLab]:nAt,09],;
	aResultados[nPosLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nPosLab]:nAt,10],;
	aResultados[nPosLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nPosLab]:nAt,11]}}   

aOBJETOS[OBJ_PAE,nPosLab]:Align := CONTROL_ALIGN_ALLCLIENT

Return(NIL)                                                   	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215EnsMed³ Autor ³Paulo Emidio de Barros ³ Data ³27/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Edicao das Medicoes associadas ao Ensaio corrente	  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215EnsMed(EXPO1,EXPN1,EXPN2,EXPN3)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto do Folder para as Medicoes				  ³±±
±±³			 ³ EXPN1 = Posicao do Laboratorio selecionado				  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio selecionado					  ³±±
±±³			 ³ EXPN3 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215EnsMed(oFldLab,nPosLab,nPosEns,nOpc)
//Medicoes associadas ao Ensaio 
aOBJETOS[OBJ_MED,nPosLab,nPosEns] := MsNewGetDados():New(052,002,109,500,nOpc,{||Q215MedLOk()},{||Q215EditaMed(),Q215MedTOk()},,,,9999,,,,oFldLab,aSavHeadEns[nPosLab,nPosEns],aResultados[nPosLab,_MED,nPosEns])
aOBJETOS[OBJ_MED,nPosLab,nPosEns]:bChange              := {||Q215EditaMed(),Q215RightMed(nPosLab,nPosEns),QE215Seq(aOBJETOS[OBJ_MED,nFldLab,nFldEns])}
aOBJETOS[OBJ_MED,nPosLab,nPosEns]:oBrowse:bLostFocus   := {||Q215EditaMed()}
aOBJETOS[OBJ_MED,nPosLab,nPosEns]:oBrowse:bGotFocus    := {||IIF(nFldLab<nFldLabGer,nFldEns:=aOBJETOS[OBJ_ENS,nFldLab]:nAt,.F.),Q215GotMNCI("M",,,nPosLab,nPosEns)}//, QE215Seq(aOBJETOS[OBJ_MED,nFldLab,nFldEns])}
//aOBJETOS[OBJ_MED,nPosLab,nPosEns]:oBrowse:bDelOk       := {||Q215DelMed()}
aOBJETOS[OBJ_MED,nPosLab,nPosEns]:bDelOk       := {||Q215DelMed(nposlab,nposlauger,_LAU)}
aOBJETOS[OBJ_MED,nPosLab,nPosEns]:oBrowse:Hide()
aOBJETOS[OBJ_MED,nPosLab,nPosEns]:oBrowse:Align        := CONTROL_ALIGN_TOP

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ     
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215MedNco³ Autor ³Paulo Emidio de Barros ³ Data ³27/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Edicao das Nao-Conformidades associadas as Medicoes		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215MedNco(EXPO1,EXPN1,EXPN2,EXPN3,EXPN4)				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto do Folder para as Medicoes				  ³±±
±±³			 ³ EXPN1 = Posicao do Laboratorio selecionado				  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio selecionado					  ³±±
±±³			 ³ EXPN3 = Posicao da Medicao selecionada					  ³±±
±±³			 ³ EXPN4 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215MedNco(oFldEns,nPosLab,nPosEns,nPosMed,nOpc)
//Nao-Conformidades associadas as medicoes

oPnlGrid := TPanel():New(0,0,'',oFldEns,,,,,,0,060)
oPnlGrid:Align := CONTROL_ALIGN_ALLCLIENT

oPnlMemo := TPanel():New(0,0,'',oFldEns,,,,,,0,020)
oPnlMemo:Align := CONTROL_ALIGN_BOTTOM

aOBJETOS[OBJ_NCO,nPosLab] := MsNewGetDados():New(002,002,040,460,nOpc,{||Q215NcoLOk()},{||Q215NcoTOk()},,,,9999,,,,oPnlGrid,aSavaHeader[HEAD_NCS],aResultados[nPosLab,_NCO,nPosEns,nPosMed])
aOBJETOS[OBJ_NCO,nPosLab]:oBrowse:bChange    := {||Q215EditaNco()}
aOBJETOS[OBJ_NCO,nPosLab]:oBrowse:bLostFocus := {||Q215EditaNco()}
aOBJETOS[OBJ_NCO,nPosLab]:oBrowse:bGotFocus  := {||Q215GotMNCI("N",.T.,.F.,nPosLab,nPosEns)}
aOBJETOS[OBJ_NCO,nPosLab]:oBrowse:Hide()
aOBJETOS[OBJ_NCO,nPosLab]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//Cronicas associadas as Nao-Conformidades
If (Inclui .Or. Altera)  
	If SetMDIChild()
	 	@ 049,003.5 GET aOBJETOS[OBJ_CRO,nPosLab] VAR cCronica MEMO NO VSCROLL MEMO VALID .T. Size 459,028.5 Of oPnlMemo Pixel 
	Else           
		@ 052,003.5 GET aOBJETOS[OBJ_CRO,nPosLab] VAR cCronica MEMO NO VSCROLL MEMO VALID .T. Size 459,038.5 Of oPnlMemo Pixel 
	Endif 
    aOBJETOS[OBJ_CRO,nPosLab]:lReadOnly := .F.
Else
	If SetMDIChild()
		@ 049,003.5 GET aOBJETOS[OBJ_CRO,nPosLab] VAR cCronica MEMO READONLY NO VSCROLL VALID .T. Size 459,028.5 Of oPnlMemo Pixel 
	Else                                                                                                                          
		@ 052,003.5 GET aOBJETOS[OBJ_CRO,nPosLab] VAR cCronica MEMO READONLY NO VSCROLL VALID .T. Size 459,038.5 Of oPnlMemo Pixel 
	Endif
	aOBJETOS[OBJ_CRO,nPosLab]:lReadOnly := .T.
EndIf                                    

aOBJETOS[OBJ_CRO,nPosLab]:bGotFocus := {||Q215GotMNCI("C",.T.,.T.,nPosLab,nPosEns)}
aOBJETOS[OBJ_CRO,nPosLab]:Hide()          
aOBJETOS[OBJ_CRO,nPosLab]:Align := CONTROL_ALIGN_TOP

If nPosLab > 1 //Apenas para não duplicar o contador na abertura da tela
	aOBJETOS[OBJ_SEQ,nPosLab]:Hide()
EndIf

Return(NIL)                                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215MedIns³ Autor ³Paulo Emidio de Barros ³ Data ³27/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Edicao dos Instrumentos associados as Medicoes		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215Medins(EXPO1,EXPN1,EXPN2,EXPN3,EXPN4)				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPO1 = Objeto do Folder para as Medicoes				  ³±±
±±³			 ³ EXPN1 = Posicao do Laboratorio selecionado				  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio selecionado					  ³±±
±±³			 ³ EXPN3 = Posicao da Medicao selecionada					  ³±±
±±³			 ³ EXPN4 = Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215MedIns(oFldEns,nPosLab,nPosEns,nPosMed,nOpc)
//Instrumentos associados a Medicao
aOBJETOS[OBJ_INS,nPosLab] := MsNewGetDados():New(002,002,088.5,490.5,nOpc,{||Q215InsLOk()},{||Q215InsTOk()},,,,9999,,,{||Q215InsDOk()},oFldEns,aSavaHeader[HEAD_INS],aResultados[nPosLab,_INS,nPosEns,nPosMed])
aOBJETOS[OBJ_INS,nPosLab]:oBrowse:bChange    := {||Q215EditaIns()}
aOBJETOS[OBJ_INS,nPosLab]:oBrowse:bLostFocus := {||Q215EditaIns()}
aOBJETOS[OBJ_INS,nPosLab]:oBrowse:bGotFocus  := {||Q215GotMNCI("I",.T.,.F.,nPosLab,nPosEns)}
aOBJETOS[OBJ_INS,nPosLab]:oBrowse:Hide() 
aOBJETOS[OBJ_INS,nPosLab]:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ Q215IniVar ³Autor³Paulo Emidio de Barros ³ Data ³27/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Inicia os valores das variaveis utilizadas no Ensaio	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215IniVar(EXPN1,EXPN2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Laboratorio							  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215IniVar(nPosLab,nPosEns)

//Inicia as variaveis utilizadas na edicao das Medicoes
nPosDtaMed := Ascan(aSavHeadEns[nPosLab,nPosEns],{|x|Alltrim(x[2])=="QER_DTMEDI"})
nPosHorMed := Ascan(aSavHeadEns[nPosLab,nPosEns],{|x|Alltrim(x[2])=="QER_HRMEDI"})
nPosNomEns := Ascan(aSavHeadEns[nPosLab,nPosEns],{|x|Alltrim(x[2])=="QER_ENSRNO"})
nPosAmo    := Ascan(aSavHeadEns[nPosLab,nPosEns],{|x|Alltrim(x[2])=="QER_AMOSTR"})
nPosCal    := Ascan(aSavHeadEns[nPosLab,nPosEns],{|x|Alltrim(x[2])=="QES_CALPOR"})
nPosEnsR   := Ascan(aSavHeadEns[nPosLab,nPosEns],{|x|Alltrim(x[2])=="QER_ENSR"  })
nPosFilMat := Ascan(aSavHeadEns[nPosLab,nPosEns],{|x|Alltrim(x[2])=="QER_FILMAT"}) 
nPosMetodo := Ascan(aSavHeadEns[nPosLab,nPosEns],{|x|Alltrim(x[2])=="QER_METODO"}) 
nPosRvDoc  := Ascan(aSavHeadEns[nPosLab,nPosEns],{|x|Alltrim(x[2])=="QER_RVDOC" }) 
cEnsaio    := aResultados[nPosLab,_ENS,nPosEns,ENSAIO] //Ensaio corrente    

//pesquisa a carta utilizada na medicao
QE1->(dbSetOrder(1))
If QE1->(MsSeek(xFilial("QE1")+aResultados[nPosLab,_ENS,nPosEns,ENSAIO]))
	cCarta  := QE1->QE1_CARTA
	cTipEns := QE1->QE1_TIPO 
EndIf                                                                         

//Retorna a Familia dos Instrumentos 
If cCarta <> "TXT"                            
	QE7->(dbSetOrder(1))
	QE7->(MsSeek(xFilial("QE7")+QEK->QEK_PRODUT+QEK->QEK_REVI+cEnsaio))
	cFamIns := QE7->QE7_TIPO                            
Else 
	//Carta do Tipo Texto
	QE8->(dbSetorder(1))
	QE8->(MsSeek(xFilial("QE8")+QEK->QEK_PRODUT+QEK->QEK_REVI+cEnsaio))
	cFamIns := QE8->QE8_TIPO
EndIf	

If cCarta <> "TXT"
	nPosRes := Ascan(aSavHeadEns[nPosLab,nPosEns],{|x|Alltrim(x[2])=="QER_RESULT"})
	If cCarta == "P  "
		nPosMed := Ascan(aSavHeadEns[nPosLab,nPosEns],{|x|Alltrim(x[2])=="QES_MEDIPA"})
	Else
		nPosMed := Ascan(aSavHeadEns[nPosLab,nPosEns],{|x|Alltrim(x[2])=="QES_MEDICA"})
	EndIF
Else                         	
	nPosRes := Ascan(aSavHeadEns[nPosLab,nPosEns],{|x|Alltrim(x[2])=="QEQ_RESULT"})
	nPosMed := Ascan(aSavHeadEns[nPosLab,nPosEns],{|x|Alltrim(x[2])=="QEQ_MEDICA"})
EndIf

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ Q215SitEns ³Autor³Paulo Emidio de Barros ³ Data ³27/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o Status do Ensaio no Laboratorio corrente        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215SitEns(EXPN1,EXPN2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao do Laboratorio							  ³±±
±±³			 ³ EXPN2 = Posicao do Ensaio								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215SitEns(nPosLab,nPosEns)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'ÄÄÄÄÄÄ¿
//³ Atualiza o status do Ensaio corrente no Laboratorio			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEnsaios[nPosLab,nPosEns,1] := If(lQE215LE,ExecBlock("QE215LE",.F.,.F.,{nPosLab,nPosEns}),q215CalLab(.F.,nPosLab,nPosEns))
aEnsaios[nPosLab,nPosEns,2] := Q215StaNco(nPosLab,nPosEns,aEnsaios[nPosLab,nPosEns,1])
aEnsaios[nPosLab,nPosEns,3] := Q215StaIns(nPosLab,nPosEns)
 	
//Realiza o calculo/recalculo dos ensaios calculados
If cCarta $ "INDßXBRßXBSßXMRßHIS"
	Q215CalFor(nPosLab)          
EndIf	

aOBJETOS[OBJ_ENS,nPosLab]:Refresh() //Atualiza o browse 

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ Q215DelMed ³Autor³Paulo Emidio de Barros ³ Data ³27/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exclui os itens relacionados a Medicao.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215DelMed()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215DelMed(nposlab,nposlauger,npLab)
Local lDeleta 
Local nPosDel
Local lret := .T.

if len(aresultado) >= nposlab
	if len(aresultado[nposlab]) >= npLab 
		If len(aResultado[nposlab,npLab]) >= nPosLauGer
			if valtype(aResultado[nposlab,npLab,NposLauger]) = 'C' 
				If Empty(aResultado[nposlab,npLab,NposLauger])	   
					lDeleta := aOBJETOS[OBJ_MED,nFldLab,nFldEns]:aCols[nMedAtu,Len(aOBJETOS[OBJ_MED,nFldLab,nFldEns]:aCols[nMedAtu])] //Marca para exclusao da linha de Medicao

					//Atualiza a marca de exclusao para as Nao-Conformidades
					nPosDel := Len(aOBJETOS[OBJ_NCO,nFldLab]:aCols[Len(aOBJETOS[OBJ_NCO,nFldLab]:aCols)])
					Aeval(aOBJETOS[OBJ_NCO,nFldLab]:aCols,{|x|x[nPosDel]:=lDeleta})
					aOBJETOS[OBJ_NCO,nFldLab]:Refresh()

					//Atualiza a marca de exclusao para os Instrumentos
					nPosDel := Len(aOBJETOS[OBJ_INS,nFldLab]:aCols[Len(aOBJETOS[OBJ_INS,nFldLab]:aCols)])
					Aeval(aOBJETOS[OBJ_INS,nFldLab]:aCols,{|x|x[nPosDel]:=lDeleta})
					aOBJETOS[OBJ_INS,nFldLab]:Refresh()
					lret := .T.
				Else
					lRet:= .F.
				EndIf 
			EndIf				
		EndIF
	EndIf		
EndiF
Return(lret)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ Q215GotMNCI³Autor³Paulo Emidio de Barros ³ Data ³27/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se as Medicoes e/ou as Nao-Conformidades poderao  ³±±
±±³			 ³ ser informadas. 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215GotMNCI(EXPC1,EXPL1,EXPL2)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = Indica se a Medicao foi informada				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215GotMNCI(cOrigem,lMed,lNco,nPosLab,nPosEns)
Local lInfMed := .T.
Local lInfNco := .T.

If !(nFldLab==nFldLabGer .Or. nFldLab==nFldLibCQ0) //Nao executa o refresh no Laudo Geral e CQ

	lMed := If(lMed==NIL,.F.,lMed)
	lNco := If(lNco==NIL,.F.,lNco)
	
	If lMed //Verifica se a Medicao corrente esta preenchida   
		lInfMed := Q215ChkMed(nFldLab,nFldEns,,nMedAtu,aResultados[nFldLab,_ENS,nFldEns,CARTA],1,.F.,.T.,.T.)                  
	EndIf
	
	If lNco	//Verifica se a Nao_conformidade corrente esta preenchida              
		lInfNco := Q215ChkMed(nFldLab,nFldEns,nMedAtu,nNcoAtu,,2,.F.,.T.,.T.)
	EndIf   
	If len(aEnsamoini) > 0
		If ascan(aEnsamoini,aResultados[nPosLab,_ENS,nFldens,2])> 0
			messagedlg(STR0262,,2) //"O ensaio seleciona do é do tipo amostra inicial e foi certificado devido a já ter entrada inspecionada anterior, de acordo com o parâmetro MV_QAMOINI"
			aOBJETOS[OBJ_ENS,nFldLab]:SetFocus()
			aOBJETOS[OBJ_ENS,nFldLab]:Refresh()
		Endif 
	Endif
	
	If !lInfMed 
		aOBJETOS[OBJ_MED,nFldLab,nFldEnsAnt]:oBrowse:SetFocus()
		aOBJETOS[OBJ_MED,nFldLab,nFldEnsAnt]:Refresh()
	EndIf
	
	If lInfMed .And. !lInfNco
		aOBJETOS[OBJ_NCO,nFldLab]:oBrowse:SetFocus()
		aOBJETOS[OBJ_NCO,nFldLab]:Refresh()
	EndIf
	
    If cOrigem == "M" //Medicoes
		nMedAnt := aOBJETOS[OBJ_MED,nFldLab,nFldEns]:nAt
		nNcoAnt := 1
	EnDif	     
	
	If cOrigem == "N" //Nao-Conformidade
		nNcoAnt := aOBJETOS[OBJ_NCO,nFldLab]:oBrowse:nAt		
	EndIf          
	
EndIf

If !lInfMed .Or. !lInfNco
	Help(" ",1,"Q215059")   
EndIf	 

Return(lInfMed)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ Q215VerIns ³Autor³Paulo Emidio de Barros ³ Data ³27/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica a obrigatoriedade dos Instrumentos para as medicoes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215VerIns(EXPN1,EXPN2,EXPN3)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = Indica se os Instrunmentos foram informados		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VerIns(cTipo)
Local lRet       := .T.
Local cMens      := "" 
Local nPosMed    := 0
Local nPosEns    := 0
Local nLab		 := 0                  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica se os instrumentos deverao ser Informados obrigatoria ³
//³ mente.														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	  
If lIntQMT .And. lInsObr .And. !lLiberaUrg		//Indica se os Instrumentos sao obrigatorios
	If cTipo == "L"   
		For nPosMed:=1 to Len(aResultados[nFldLab,_MED,nFldEns])
			If (Empty(aResultados[nFldLab,_INS,nFldEns,nPosMed,1,1]) .And. ;
				!aResultados[nFldLab,_INS,nFldEns,nPosMed,1,Len(aResultados[nFldLab,_INS,nFldEns,nPosMed,1])] );
				.Or. aResultados[nFldLab,_INS,nFldEns,nPosMed,1,Len(aResultados[nFldLab,_INS,nFldEns,nPosMed,1])]
		    	cMens := "Instrumento obrigatorio para a Medicäo " + Alltrim(StrZero(nPosMed,2)) + ;                      
			   		   	  " referente ao Ensaio " + aResultados[nFldLab,_ENS,nFldEns,DESPOR]     
			    lRet  := .F.
			    Exit
			EndIF                                                    
		Next nPosMed		
	ElseIf cTipo == "T"
		For nLab:=1 to Len(aResultados)-1
			For nPosEns:=1 to Len(aResultados[nLab,_ENS])
				For nPosMed:=1 to Len(aResultados[nLab,_MED,nPosEns])
					If (Empty(aResultados[nLab,_INS,nPosEns,nPosMed,1,1]) .And. ;
						!aResultados[nLab,_INS,nPosEns,nPosMed,1,Len(aResultados[nLab,_INS,nPosEns,nPosMed,1])] );
						.Or. aResultados[nLab,_INS,nPosEns,nPosMed,1,Len(aResultados[nLab,_INS,nPosEns,nPosMed,1])]
				    	cMens := "Instrumento obrigatorio para a Medicäo " + Alltrim(StrZero(nPosMed,2)) + ;			
					   		   	 " referente ao Ensaio " + aResultados[nLab,_ENS,nPosEns,DESPOR]	 
					    lRet  := .F.
					    Exit
					EndIF                                                    
				Next nPosMed		
			Next nPosEns
		Next nLab
	EndIF
EndIf

Return({lRet,cMens})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  																	  ³±±
±±³         ROTINAS UTILIZADAS NA NAVEGACAO DA TELA DE RESULTADOS         ³±±
±±³																		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215SetLab³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a selecao na mudanca de Folder dos Laboratorios uti³±±
±±³			 ³ lizados na rotina de Resultados.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215SetLab(EXPN1,EXPN2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao atual do Laboratorio						  ³±±
±±³			 ³ EXPN2 = Ultima posicao selecionada do Laboratorio		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA215() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215SetLab(nLabGot,nLabLost,nEnsGot,nEnsLost,nMedGot,nMedLost,nNcoGot,nNcoLost,lChgFol)                 
Local aAreaAnt := GetArea()          
Local aSavResu := {}
Local nX  
Local nW
Local lBloq     := .F.
local cVlrLaudo := M->QEL_LAUDO

//Verifica Bloqueio na Pasta de Laudo Geral
If nLabGot == nFldLabGer .AND. !lLiberaUrg
	
	If (nLabLost <> nFldLibCQ0)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Salva o Laudo do Laboratorio selecionado.					³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		For nW := 1 To Len(aGets)
	   		aTela[Val(Subs(aGets[nW],1,2))][Val(Subs(aGets[nW],3,1))*2] := &("M->" + aCpoEnc[1,nW])
		Next nW
		aSavTela[nLabLost] := aClone(aTela)
		aSavGets[nLabLost] := aClone(aGets)
		For nX := 1 to Len(aCpoEnc[1])
			Aadd(aSavResu,M->&(aCpoEnc[1,nX])) 
		Next	
		If (nLabLost == nFldLabGer)
			aResultados[nLabLost,_LAUGER] := aClone(aSavResu)
		Else
			aResultados[nLabLost,_LAU]	:= aClone(aSavResu)
		EndIf	
	EndIf	

	If !Q215VldLau(" ",.T.) 
		nFldLab  :=  nLabLost 
		nFldAnt  :=  nLabLost   
		nFldEns  :=  nEnsLost
		nMedAtu  :=  nMedLost
		nNcoAtu  :=  nNcoLost    
		lBloqFld :=  .T.
		Return(.F.)
	Else
		lBloqFld :=  .F.
	EndIF
EndIF   

If nLabLost <> NIL                   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva os Resultados dos Ensaios referentes ao Laboratorio 	³
	//³ selecionado.												³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(nLabLost == nFldLabGer .Or. nLabLost == nFldLibCQ0)                                       

		//Ensaios associados ao Laboratorio
		aOBJETOS[OBJ_ENS,nLabLost]:Hide()  
		
		If nEnsLost <> NIL
	        //Salva as medicoes informadas
			aResultados[nLabLost,_MED,nEnsLost] := aClone(aOBJETOS[OBJ_MED,nLabLost,nEnsLost]:aCols)
			aOBJETOS[OBJ_MED,nLabLost,nEnsLost]:oBrowse:Hide()
			
			If nMedLost <> NIL
				//Salva as Nao-conformidades associadas a medicao
				aResultados[nLabLost,_NCO,nEnsLost,aOBJETOS[OBJ_MED,nLabLost,nEnsLost]:nAT] := aClone(aOBJETOS[OBJ_NCO,nLabLost]:aCols)
				aOBJETOS[OBJ_NCO,nLabLost]:oBrowse:Hide()       

				If nNcoLost <> NIL
					//Cronica associada a Nao-Conformidade
					aResultados[nLabLost,_CRO,nEnsLost,aOBJETOS[OBJ_MED,nLabLost,nEnsLost]:nAT,nNcoLost] := cCronica
					aOBJETOS[OBJ_CRO,nLabLost]:Hide()
				EndIf	

				//Salva os Instrumentos associados a medicao
				aResultados[nLabLost,_INS,nEnsLost,aOBJETOS[OBJ_MED,nLabLost,nEnsLost]:nAT] := aClone(aOBJETOS[OBJ_INS,nLabLost]:aCols)
				aOBJETOS[OBJ_INS,nLabLost]:oBrowse:Hide()

			EndIf
		EndIf
	
		//Planos de Amostragens associados ao Ensaio
		aOBJETOS[OBJ_PAE,nLabLost]:Hide()

		//Ensaios associados ao Laboratorio
		aOBJETOS[OBJ_SEQ,nLabLost]:Hide()  

	EndIf	                            	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a Libercao/Rejeicao do Material no CQ					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nLabLost == nFldLibCQ0)
		aResultados[Len(aResultados)] := aClone(aCols)
		aOBJETOS[OBJ_ESTOQUE]:oBrowse:Hide() 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza a Quantidade Aprovada e/ou Rejeitada no Laudo Geral³ 	
		//³ da Entrada, a partir das Baixas no CQ (quando houver integra³ 
		//³ cao com materiais).											³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAtuLauGer 
			Q215AtuLauGer()
		EndIf	
		Set Key VK_F4 To
	ElseIf (nLabAtuMem == nLabLost) .Or. !(Empty(cVlrLaudo) .and. cVlrLaudo == "U") 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Salva o Laudo do Laboratorio selecionado.					³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		For nW := 1 To Len(aGets)
	   		aTela[Val(Subs(aGets[nW],1,2))][Val(Subs(aGets[nW],3,1))*2] := &("M->" + aCpoEnc[1,nW])
		Next nW
		aSavTela[nLabLost] := aClone(aTela)
		aSavGets[nLabLost] := aClone(aGets)
		For nX := 1 to Len(aCpoEnc[1])
			Aadd(aSavResu,M->&(aCpoEnc[1,nX])) 
		Next	
		If (nLabLost == nFldLabGer)
			aResultados[nLabLost,_LAUGER] := aClone(aSavResu)
		Else
			aResultados[nLabLost,_LAU]	:= aClone(aSavResu)
		EndIf	
	EndIf	

EndIf

If nLabGot <> NIL     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza os Resultados dos Ensaios referentes ao Laboratorio³
	//³ selecionado.												³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(nLabGot == nFldLabGer .Or. nLabGot == nFldLibCQ0)      	                                 

		//Ensaios associados ao Laboratorio
		aOBJETOS[OBJ_ENS,nLabGot]:Show()
		aOBJETOS[OBJ_ENS,nLabGot]:Refresh() 

		If nEnsGot <> NIL

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se as Medicoes poderao ser editadas				³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Inclui .Or. Altera
				Q215UpMeasures(nLabGot,nEnsGot)
	    	EndIf

			//Inicia as variaveis utilizadas nas medicoes
			Q215IniVar(nLabGot,nEnsGot)

			If cTipEns == "1" //Ensaio Calculado, Inibe a edicao do browse
				aOBJETOS[OBJ_MED,nLabGot,nEnsGot]:lUpDate := .F.
				aOBJETOS[OBJ_MED,nLabGot,nEnsGot]:lInsert := .F.
			EndIf

			//Medicoes associadas ao Ensaio	corrente	        
			aOBJETOS[OBJ_MED,nLabGot,nEnsGot]:oBrowse:Show()
			aOBJETOS[OBJ_MED,nLabGot,nEnsGot]:oBrowse:Refresh()
			
			If nMedGot <> NIL
				//Salva as Nao-conformidades associadas a medicao
				aOBJETOS[OBJ_NCO,nLabGot]:aCols := aClone(aResultados[nLabGot,_NCO,nEnsGot,nMedGot]) 
			
				//Nao-Conformidades associadas a ultima medicao
				aOBJETOS[OBJ_NCO,nLabGot]:oBrowse:Show()
				aOBJETOS[OBJ_NCO,nLabGot]:oBrowse:Refresh()
			
				If nNcoGot <> NIL
					//Salva a Cronica associada a Nao-Conformidade
					cCronica := aResultados[nLabGot,_CRO,nEnsGot,nMedGot,nNcoGot]

					aOBJETOS[OBJ_CRO,nLabGot]:Show()
					aOBJETOS[OBJ_CRO,nLabGot]:Refresh()    
				EndIf	
				  
				//Salva os Instrumentos associados a medicao
				aOBJETOS[OBJ_INS,nLabGot]:aCols := aClone(aResultados[nLabGot,_INS,nEnsGot,nMedGot]) 

				//Instrumentos associados a ultima medicao
				aOBJETOS[OBJ_INS,nLabGot]:oBrowse:Show()
				aOBJETOS[OBJ_INS,nLabGot]:oBrowse:Refresh()

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o Status do Ensaio para: Medicoes, Nao-Conformidades³
			//³ e Instrumentos.												 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Q215SitEns(nLabGot,nEnsGot)

	    EndIf

		//Planos de Amostragens associados ao Ensaio		
		aOBJETOS[OBJ_PAE,nLabGot]:Show()
		aOBJETOS[OBJ_PAE,nLabGot]:SetArray(aResultados[nLabGot,_PAE,nEnsGot])
		aOBJETOS[OBJ_PAE,nLabGot]:bLine:={||{;
			aResultados[nLabGot,_PAE,nEnsGot][aOBJETOS[OBJ_PAE,nLabGot]:nAt,01],;
			aResultados[nLabGot,_PAE,nEnsGot][aOBJETOS[OBJ_PAE,nLabGot]:nAt,02],;
			aResultados[nLabGot,_PAE,nEnsGot][aOBJETOS[OBJ_PAE,nLabGot]:nAt,03],;
			aResultados[nLabGot,_PAE,nEnsGot][aOBJETOS[OBJ_PAE,nLabGot]:nAt,04],;
			aResultados[nLabGot,_PAE,nEnsGot][aOBJETOS[OBJ_PAE,nLabGot]:nAt,05],;
			aResultados[nLabGot,_PAE,nEnsGot][aOBJETOS[OBJ_PAE,nLabGot]:nAt,06],;
			aResultados[nLabGot,_PAE,nEnsGot][aOBJETOS[OBJ_PAE,nLabGot]:nAt,07],;
			aResultados[nLabGot,_PAE,nEnsGot][aOBJETOS[OBJ_PAE,nLabGot]:nAt,08],;
			aResultados[nLabGot,_PAE,nEnsGot][aOBJETOS[OBJ_PAE,nLabGot]:nAt,09],;
			aResultados[nLabGot,_PAE,nEnsGot][aOBJETOS[OBJ_PAE,nLabGot]:nAt,10],;
			aResultados[nLabGot,_PAE,nEnsGot][aOBJETOS[OBJ_PAE,nLabGot]:nAt,11]}}   
		aOBJETOS[OBJ_PAE,nLabGot]:Refresh() 
	
		//Ensaios associados ao Laboratorio
		aOBJETOS[OBJ_SEQ,nLabGot]:Show()  
		QE215Seq(aOBJETOS[OBJ_MED,nLabGot,nEnsGot])

	EndIf	        

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recupera o Liberacao/rejeicao do Material no CQ				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nLabGot == nFldLibCQ0)              
		Set Key VK_F4 TO A175ShowF4()
		dbSelectArea("SD7")                          
		aHeader := aClone(aSavaHeader[HEAD_EST])     
		nUsado  := Len(aHeader)    
	    aCols   := aClone(aResultados[Len(aResultados)])
		N 		:= 1                                  
		aOBJETOS[OBJ_ESTOQUE]:oBrowse:Show()
		aOBJETOS[OBJ_ESTOQUE]:oBrowse:Refresh(.T.)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Recupera o Laudo do Laboratorio selecionado.				³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aTela := aClone(aSavTela[nLabGot])
		aGets := aClone(aSavGets[nLabGot])

		For nX := 1 to Len(aCpoEnc[1])
			If nLabGot == nFldLabGer
				M->&(aCpoEnc[1,nX]) := aResultados[nLabGot,_LAUGER,nX]
			Else
				M->&(aCpoEnc[1,nX]) := aResultados[nLabGot,_LAU,nX]
			EndIf	
		Next
		nLabAtuMem := nLabGot
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os Laudos referentes a Entrada e Laboratorios  	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nLabGot == nFldLabGer
			aOBJETOS[OBJ_LAUGER,1]:EnchRefreshAll()
		Else                                      
			aOBJETOS[OBJ_LAULAB,nLabGot]:EnchRefreshAll()
		EndIf	
		
	EndIf                                   
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Altera o conteudo das variaveis de controle dos Folders na  ³
//³ mudanca de Laboratorio.										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nLabGot <> nFldLibCQ0
	If nLabLost <> nLabGot  
		nFldLabAnt := nLabGot
		nFldEnsAnt := nEnsGot //Ensaio anterior
		nMedAnt    := nMedGot //Medicao anterior
		nNcoAnt    := nNcoGot //Nao-Conformidade anterior     
	EndIf
Endif	
RestArea(aAreaAnt)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215EditaEns³Autor³Paulo Emidio de Barros ³ Data ³27/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Edicao da Navegacao dos Resultados a partir dos Ensaios	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215EditaEns()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215EditaEns()
nFldEns := aOBJETOS[OBJ_ENS,nFldLab]:nAt                 //Ensaio Atual
nMedAtu := aOBJETOS[OBJ_MED,nFldLab,nFldEns]:oBrowse:nAt //Medicao Atual                           

//Salva as Medicoes anteriores no vetor aResultados
aResultados[nFldLab,_MED,nFldEnsAnt] := aClone(aOBJETOS[OBJ_MED,nFldLab,nFldEnsAnt]:aCols)
	
nMedAnt := aOBJETOS[OBJ_MED,nFldLab,nFldEnsAnt]:nAt	 //Medicao Anterior
nNcoAnt := aOBJETOS[OBJ_NCO,nFldLab]:nAt
	
//Salva as Nao-Conformidades Anteriores no vetor aResultados
aResultados[nFldLab,_NCO,nFldEnsAnt,nMedAnt] := aClone(aOBJETOS[OBJ_NCO,nFldLab]:aCols)

//Salva a Cronica Anterior no Vetor aResultados
aResultados[nFldLab,_CRO,nFldEnsAnt,nMedAnt,nNcoAnt] := cCronica

//Salva os Instrumentos Anteriores no vetor aResultados
aResultados[nFldLab,_INS,nFldEnsAnt,nMedAnt] := aClone(aOBJETOS[OBJ_INS,nFldLab]:aCols)
	    
//Inibe a edicao das Medicoes Anteriores
aOBJETOS[OBJ_MED,nFldLab,nFldEnsAnt]:oBrowse:Hide()

//Inibe a edicao das Nao-Conformidades Anteriores
aOBJETOS[OBJ_NCO,nFldLab]:oBrowse:Hide()
    
//Inibe a edicao da Cronica Anterior
aOBJETOS[OBJ_CRO,nFLdLab]:Hide()

//inibe a edicao dos Instrumentos Anteriores
aOBJETOS[OBJ_INS,nFldLab]:oBrowse:Hide()
	
//Inibe a edicao do Plano de Amostragem associado ao Ensaio 
aOBJETOS[OBJ_PAE,nFldLab]:Hide()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o Status do Ensaio para: Medicoes, Nao-Conformidades³
//³ e Instrumentos.												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Q215SitEns(nFldLab,nFldEnsAnt)

nFldEnsAnt := nFldEns //Ensaio Anterior
nMedAnt    := nMedAtu //Medicao Anterior
//

Q215IniVar(nFldLab,nFldEns) //Inicia as variaveis utilizadas nas Medicoes Atuais

If cTipEns == "1" //Ensaio Calculado, Inibe a edicao do browse
	aOBJETOS[OBJ_MED,nFldLab,nFldEns]:lUpDate := .F.
	aOBJETOS[OBJ_MED,nFldLab,nFldEns]:lInsert := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se as Medicoes poderao ser editadas				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Inclui .Or. Altera
	Q215UpMeasures(nFldLab,nFldEns)
EndIf

//Salva as Medicoes Atuais no aCols
aOBJETOS[OBJ_MED,nFldLab,nFldEns]:aCols := aClone(aResultados[nFldLab,_MED,nFldEns])
aOBJETOS[OBJ_MED,nFldLab,nFldEns]:oBrowse:Show()
aOBJETOS[OBJ_MED,nFldLab,nFldEns]:Refresh()

//Salva as Nao-Conformidades Atuais no aCols
aOBJETOS[OBJ_NCO,nFldLab]:aCols := aClone(aResultados[nFldLab,_NCO,nFldEns,nMedAtu])
aOBJETOS[OBJ_NCO,nFldLab]:oBrowse:Show()
aOBJETOS[OBJ_NCO,nFldLab]:Refresh()

nNcoAtu := aOBJETOS[OBJ_NCO,nFldLab]:oBrowse:nAt //Nao-Conformidade Atual
nNcoAnt := nNcoAtu                                //Nao-Conformidade Anterior

//Salva a Cronica Atual para edicao
cCronica := aResultados[nFldLab,_CRO,nFldEns,nMedAtu,nNcoAtu]
aOBJETOS[OBJ_CRO,nFLdLab]:Show()
aOBJETOS[OBJ_CRO,nFLdLab]:Refresh()

//Salva os Instrumentos Atuais no aCols
aOBJETOS[OBJ_INS,nFldLab]:aCols := aClone(aResultados[nFldLab,_INS,nFldEns,nMedAtu])
aOBJETOS[OBJ_INS,nFldLab]:oBrowse:Show()
aOBJETOS[OBJ_INS,nFldLab]:Refresh()

//Atualiza o Plano de Amostragem associado ao Ensaio
aOBJETOS[OBJ_PAE,nFldLab]:Show()
aOBJETOS[OBJ_PAE,nFldLab]:SetArray(aResultados[nFldLab,_PAE,nFldEns])
aOBJETOS[OBJ_PAE,nFldLab]:bLine:={||{;
	aResultados[nFldLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nFldLab]:nAt,01],;
	aResultados[nFldLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nFldLab]:nAt,02],;
	aResultados[nFldLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nFldLab]:nAt,03],;
	aResultados[nFldLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nFldLab]:nAt,04],;
	aResultados[nFldLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nFldLab]:nAt,05],;
	aResultados[nFldLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nFldLab]:nAt,06],;
	aResultados[nFldLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nFldLab]:nAt,07],;
	aResultados[nFldLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nFldLab]:nAt,08],;
	aResultados[nFldLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nFldLab]:nAt,09],;
	aResultados[nFldLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nFldLab]:nAt,10],;
	aResultados[nFldLab,_PAE,nFldEns][aOBJETOS[OBJ_PAE,nFldLab]:nAt,11]}}   
aOBJETOS[OBJ_PAE,nFldLab]:Refresh()

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215EditaMed³Autor³Paulo Emidio de Barros ³ Data ³27/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Edicao da Navegacao dos Resultados a partir das Medicoes	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215EditaMed()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215EditaMed()         

If nFldLab < nFldLabGer
	
	nMedAtu := aOBJETOS[OBJ_MED,nFldLab,nFldEns]:oBrowse:nAt //Medicao Atual
	
	//Salva as Medicoes informadas no Ensaio Atual
	aResultados[nFldLab,_MED,nFldEns] := aClone(aOBJETOS[OBJ_MED,nFldLab,nFldEns]:aCols)
	
	If nMedAtu <> nMedAnt
		
		//Salva as Nao-Conformidades Anteriores no vetor aResultados
		aResultados[nFldLabAnt,_NCO,nFldEnsAnt,nMedAnt] := aClone(aOBJETOS[OBJ_NCO,nFldLabAnt]:aCols)
		
		//Salva a Cronica Anterior no Vetor aResultados
		aResultados[nFldLabAnt,_CRO,nFldEnsAnt,nMedAnt,nNcoAnt] := cCronica
		
		//Salva os Instrumento Anteriores no vetor aResultados
		aResultados[nFldLabAnt,_INS,nFldEnsAnt,nMedAnt] := aClone(aOBJETOS[OBJ_INS,nFldLabAnt]:aCols)
		
		//Inibe a edicao das Nao-Conformidades Anteriores
		aOBJETOS[OBJ_NCO,nFldLabAnt]:oBrowse:Hide()
		
		//Inibe a edicao da Cronica Anterior
		aOBJETOS[OBJ_CRO,nFldLabAnt]:Hide()
		
		//Inibe a edicao dos Instrumentos Anteriores
		aOBJETOS[OBJ_INS,nFldLabAnt]:oBrowse:Hide()
		
		nMedAnt := nMedAtu //Medicao Anterior
	EndIf
	
	If (Len(aOBJETOS[OBJ_MED,nFldLab,nFldEns]:aCols) > Len(aResultados[nFldLab,_NCO,nFldEns])) .Or.;
		(Len(aOBJETOS[OBJ_MED,nFldLab,nFldEns]:aCols) > Len(aResultados[nFldLab,_INS,nFldEns]))
		
		//Insere um elemento no vetor aResultados para as Nao-Conformidades
		Aadd(aResultados[nFldLab,_NCO,nFldEns],aClone(aSavaCols[HEAD_NCS]))
		
		//Insere um elemento no vetor aResultados para a Cronica
		Aadd(aResultados[nFldLab,_CRO,nFldEns],Afill(Array(1),""))
		
		//Insere um elemento no vetor aResultados para os Instrumentos
		Aadd(aResultados[nFldLab,_INS,nFldEns],aClone(aSavaCols[HEAD_INS]))
		
	ElseIf (Len(aOBJETOS[OBJ_MED,nFldLab,nFldEns]:aCols) < Len(aResultados[nFldLab,_NCO,nFldEns])) .Or.;
		(Len(aOBJETOS[OBJ_MED,nFldLab,nFldEns]:aCols) > Len(aResultados[nFldLab,_INS,nFldEns]))
		
		//Exclui um elemento no vetor aResultados para as Nao-Conformidades
		aDel(aResultados[nFldLab,_NCO,nFldEns],Len(aResultados[nFldLab,_NCO,nFldEns]))
		aSize(aResultados[nFldLab,_NCO,nFldEns],Len(aResultados[nFldLab,_NCO,nFldEns])-1)
		
		//Exclui um elemento no vetor aResultados para a Cronica Anterior
		aDel(aResultados[nFldLab,_CRO,nFldEns],Len(aResultados[nFldLab,_CRO,nFldEns]))
		aSize(aResultados[nFldLab,_CRO,nFldEns],Len(aResultados[nFldLab,_CRO,nFldEns])-1)
		
		//Exclui um elemento no vetor aResultados para os Instrumentos
		aDel(aResultados[nFldLab,_INS,nFldEns],Len(aResultados[nFldLab,_INS,nFldEns]))
		aSize(aResultados[nFldLab,_INS,nFldEns],Len(aResultados[nFldLab,_INS,nFldEns])-1)
		
	EndIf
	
	//Salva as Nao-Conformidades Atuais no aCols
	aOBJETOS[OBJ_NCO,nFldLab]:aCols := aClone(aResultados[nFldLab,_NCO,nFldEns,nMedAtu])
	aOBJETOS[OBJ_NCO,nFldLab]:oBrowse:Show()
	aOBJETOS[OBJ_NCO,nFldLab]:Refresh()
	
	nNcoAtu := aOBJETOS[OBJ_NCO,nFldLab]:oBrowse:nAt //Nao-Conformidade Atual
	nNcoAnt := nNcoAtu                                //Nao-Conformidade Anterior
	
	//Salva a Cronica Atual para edicao
	cCronica := aResultados[nFldLab,_CRO,nFldEns,nMedAtu,nNcoAtu]
	aOBJETOS[OBJ_CRO,nFLdLab]:Show()
	aOBJETOS[OBJ_CRO,nFLdLab]:Refresh()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza uma nova copia do Instrumento, caso a posicao atual  ³
	//³ nao possua instrumento informado.							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Q215ChkMed(nFldLab,nFldEns,nMedAtu,1,,3,.F.,.F.,.F.)
		//Copia o Instrumento para a nova medicao
		aResultados[nFldLab,_INS,nFldEns,nMedAtu] := aClone(aResultados[nFldLab,_INS,nFldEns,1])
		
	EndIf
	
	//Salva as Nao-Conformidades Atuais no aCols
	aOBJETOS[OBJ_INS,nFldLab]:aCols := aClone(aResultados[nFldLab,_INS,nFldEns,nMedAtu])
	aOBJETOS[OBJ_INS,nFldLab]:oBrowse:Show()
	aOBJETOS[OBJ_INS,nFldLab]:Refresh()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o Status do Ensaio para: Medicoes, Nao-Conformidades³
	//³ e Instrumentos.												 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Q215SitEns(nFldLab,nFldEns)
	
EndIf

Return(NIL)                             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215EditaNco³Autor³Paulo Emidio de Barros ³ Data ³27/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Edicao na Navegacao das Nao-Conformidades				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215EditaNco()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215EditaNco()

If nFldLab < nFldLabGer

	nNcoAtu := aOBJETOS[OBJ_NCO,nFldLab]:oBrowse:nAt //Nao-conformidade Atual

	//Salva as Nao-Conformidades informadas a Medicao Atual
	aResultados[nFldLab,_NCO,nFldEns,nMedAtu] := aClone(aOBJETOS[OBJ_NCO,nFldLab]:aCols)

	If nNcoAtu <> nNcoAnt            
		If Len(aResultados[nFldLab,_CRO,nFldEns,nMedAtu]) >= nNcoAnt 
			//Salva a Cronica Anterior no Vetor aResultados
			aResultados[nFldLab,_CRO,nFldEns,nMedAtu,nNcoAnt] := cCronica 
		EndIf
	
		//Inibe a edicao da Cronica Anterior
		aOBJETOS[OBJ_CRO,nFLdLab]:Hide()

   		nNcoAnt := nNcoAtu //Nao-Conformidade Anterior
	EndIf                                  

	If Len(aOBJETOS[OBJ_NCO,nFldLab]:aCols) > Len(aResultados[nFldLab,_CRO,nFldEns,nMedAtu]) 
		//Insere um elemento no vetor aResultados para as Nao-Conformidades Atuais
		Aadd(aResultados[nFldLab,_CRO,nFldEns,nMedAtu]," ")

	ElseIf Len(aOBJETOS[OBJ_NCO,nFldLab]:aCols) < Len(aResultados[nFldLab,_CRO,nFldEns,nMedAtu]) 
		//Exclui um elemento no vetor aResultados para as Nao-Conformidades Anteriores
		aDel(aResultados[nFldLab,_CRO,nFldEns,nMedAtu],Len(aResultados[nFldLab,_CRO,nFldEns,nMedAtu]))
		aSize(aResultados[nFldLab,_CRO,nFldEns,nMedAtu],Len(aResultados[nFldLab,_CRO,nFldEns,nMedAtu])-1)

	EndIf

	//Salva a Cronica Atual para edicao
	cCronica := aResultados[nFldLab,_CRO,nFldEns,nMedAtu,nNcoAtu]
	aOBJETOS[OBJ_CRO,nFLdLab]:Show()
	aOBJETOS[OBJ_CRO,nFLdLab]:Refresh()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o Status do Ensaio para: Medicoes, Nao-Conformidades³
	//³ e Instrumentos.												 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Q215SitEns(nFldLab,nFldEns)
    
EndIF

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215EditaIns³Autor³Paulo Emidio de Barros ³ Data ³27/07/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Edicao na Navegacao dos Instrumentos						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215EditaIns()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215EditaIns()                   

If nFldLab < nFldLabGer

	//Salva os Instrumentos informadas para a Medicao Atual
	aResultados[nFldLab,_INS,nFldEns,nMedAtu] := aClone(aOBJETOS[OBJ_INS,nFldLab]:aCols)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o Status do Ensaio para: Medicoes, Nao-Conformidades³
	//³ e Instrumentos.												 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Q215SitEns(nFldLab,nFldEns)

EndIF

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	³ Q215UpMeasures ³Autor³Paulo Emidio de Barros³ Data ³18/08/04³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao³ Verifica se as Medicoes poderao ser editadas.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	³ Q215UpMeasures(EXPN1,EXPN2)							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215UpMeasures(nPosLab,nPosEns)
Local lEdita := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se as Medicoes podem ser alteradas quando o Laudo do³
//³ Laboratorio e/ou Laudo Geral estiverem preenchidos.			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAltMed 
	If !Empty(aResultados[nFldLabGer,_LAUGER,nPosLauGer]) .Or. !Empty(aResultados[nPosLab,_LAU,nPosLauGer])
		lEdita := .F.
	EndIf	
EndIf	
	
//Medicoes associadas aos Ensaios
aOBJETOS[OBJ_MED,nPosLab,nPosEns]:lUpDate := lEdita
aOBJETOS[OBJ_MED,nPosLab,nPosEns]:lInsert := lEdita

//Nao-COnformidades associadas as Medicoes
aOBJETOS[OBJ_NCO,nPosLab]:lUpDate := lEdita
aOBJETOS[OBJ_NCO,nPosLab]:lInsert := lEdita

//Cronicas associadas as Nao-Conformidades
aOBJETOS[OBJ_CRO,nPosLab]:lReadOnly := !lEdita

//Instrumentos associadaso as Medicoes
aOBJETOS[OBJ_INS,nPosLab]:lUpDate := lEdita
aOBJETOS[OBJ_INS,nPosLab]:lInsert := lEdita

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	³ Q215VldTMP ³Autor³ Cleber Souza		      ³ Data ³14/07/04³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao³ Validacao dos campos relacionados ao ensaio do tipo: TEMPO  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	³ Q215VldTMP()											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	³ EXPL1 = T ou F											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VldTMP()
Local cValor
Local nPosDti   := Ascan(aHeader,{|x|Alltrim(x[2])=="QER_DTINI"})   
Local nPosHri   := Ascan(aHeader,{|x|Alltrim(x[2])=="QER_HRINI"})   
Local nPosDtf   := Ascan(aHeader,{|x|Alltrim(x[2])=="QER_DTFIM"})   
Local nPosHrf   := Ascan(aHeader,{|x|Alltrim(x[2])=="QER_HRFIM"}) 
Local nPosRDat	:= Ascan(aHeader,{|x|Alltrim(x[2])=="QES_MEDICA"})  
Local lRet      := .T.
Local nDia      := 0

cValor := &(ReadVar())

If !Empty(cValor)

	If Alltrim(ReadVar()) == "M->QER_DTINI"
		If !Empty(aCols[N,nPosDtf])
			If cValor > aCols[N,nPosDtf] .Or. cValor > dDataBase .Or. !Empty(aCols[N,nPosHri]) .And. !Empty(aCols[N,nPosHrf]) .And. aCols[N,nPosDtf] == cValor .And. Superval(aCols[N,nPosHrf]) <= SuperVal(cValor)
				Help(" ",1,"Q215063") //Data incicial da medicao invalida!
				lRet := .F.
			Else
				aCols[N,nPosDti] := M->QER_DTINI
			EndIf                  
		EndIf                                 
		
	ElseIf Alltrim(ReadVar()) =="M->QER_DTFIM"
	
		If !Empty(aCols[n,nPosDti])
			If cValor < aCols[n,nPosDti] .Or. cValor > dDataBase .Or. !Empty(aCols[n,nPosHri]) .And. !Empty(aCols[n,nPosHrf])	 .And. cValor == aCols[n,nPosDti] .And. Superval(aCols[n,nPosHrf]) <= SuperVal(aCols[n,nPosHri])
		   		Help(" ",1,"Q215064") //Data final da medicao invalida!
				lRet := .F.
			Else
				aCols[n,nPosDtf] := M->QER_DTFIM
			EndIf
		EndIf
	   	
	ElseIf Alltrim(ReadVar()) =="M->QER_HRINI"
		If Substr(cValor,1,2) > "23" .Or. Substr(cValor,4,2) > "59" .Or. Len(AllTrim(cValor)) < 5 .Or. (!Empty(cValor) .And. !Empty(aCols[n,nPosHrf]) .And. aCols[n,nPosDtf] == aCols[n,nPosDti] .And. Superval(aCols[n,nPosHrf]) <= SuperVal(cValor)	)
			Help(" ",1,"Q215065") 	//Hora Inicial da medicao invalida!
			lRet := .F.
		Else
			aCols[n,nPosHri] := M->QER_HRINI
		EndIf
	   	
	ElseIf Alltrim(ReadVar()) =="M->QER_HRFIM"
		If	!Empty(aCols[n,nPosHri])
			If	aCols[n,nPosDtf] == aCols[n,nPosDti] .And. Superval(cValor) <= SuperVal(aCols[n,nPosHri]) .Or. Substr(cValor,1,2) > "23" .Or. Substr(cValor,4,2) > "59" .Or. Len(AllTrim(cValor)) < 5
				Help(" ",1,"Q215066") 	//Hora Final da medicao invalida!
				lRet := .F.
			Else
				aCols[n,nPosHrf] := M->QER_HRFIM
			EndIf
		EndIf        
		
	EndIf

	If lRet

		If !Empty(aCols[n,nPosDti]) .And. !Empty(aCols[n,nPosHri]) .And. !Empty(aCols[n,nPosDtf]) .And. !Empty(aCols[n,nPosHrf])
			
			nDia := DiaUtil(aCols[n,nPosDti],aCols[n,nPosDtf])
			
			aCols[n,nPosRDat] := QA_CalHor(nDia,aCols[n,nPosHrf],aCols[n,nPosHri]) 
			
			Q215VerCal(aCols[n,nPosRDat],.T.)
			
			If SuperVal(aCols[n,nPosRDat]) <= 0
				Help(" ",1,"Q215067") // "Resultado invalido!"
				aCols[n,nPosRDat] := " " 
			EndIf
		Else
			aCols[n,nPosRDat] := " " 
		EndIf
	EndIf

EndIf

Return(lRet)         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ Q215EstCQO  ³ Autor ³ Paulo Emidio de Barros ³ Data ³15/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se a quantidade liberada/rejeitada no CQ foi estornada³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  Q215EstCQO(EXPN1)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Opcao do aRotina										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = T ou F											  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215											         	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                              
Static Function Q215EstCQO(nOpc)
Local lRetorno := .T.  
Local nX       := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso a opcao seja igual a Exclusao e houver Liberacao e/ou Re³
//³ jeicao de material no CQ, o estorno sera consistido.		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIntEst .And. lEstorno .And. nOpc == 4
	For nX := 1 to Len(aResultados[Len(aResultados)])
		If aResultados[Len(aResultados),nX,nPosTipo] == 1  .Or.; //liberacao 
			aResultados[Len(aResultados),nX,nPosTipo] == 2       //Rejeicao			
			If Upper(aResultados[Len(aResultados),nX,nCQPosEsto]) <> "X"  .AND. Upper(aResultados[Len(aResultados),nX,nCQPosEsto])<> "S"
				lRetorno := .F.
			EndIf
	    EndIf
    Next nX
EndIf

If !lRetorno		
	Help(' ',1,'A175EST')
EndIf
	
Return(lRetorno)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215Ens   ³ Autor ³ Cleber Souza          ³ Data ³ 01/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Inicializa Codigo e o apelido do ensaiador				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL  													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPC1 = Matricula do Ensaiador						  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215									                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215Ens()

Local nOrdQAA	:= QAA->(IndexOrd())
Local cApelid	:= TRIM(UPPER(cUserName))
Local cCod		:= Space(10)

dbSelectArea("QAA")
dbSetOrder(6)
If dbSeek(cApelid)
	cCod := QAA->QAA_MAT
EndIf
dbSetOrder(nOrdQAA)

Return(cCod) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215VPOL   ³ Autor ³ Cleber Souza        ³ Data ³ 22/09/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se eh um campo que utiliza valores em polegadas.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL  													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPL1 = True se for polegada.						  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215									                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215VPOL()

Local lRet  := .F.

If At('i',aResultados[nFldLab,_ENS,nFldEns,VLRNOM]) > 0
	lRet := .T.
EndIF

Return(lRet)     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q215FilUsu³ Autor ³Cleber Souza           ³ Data ³09/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtra as Filiais para selecao do Usuario responsavel      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA215 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215FilUsu()
Local cFiltro := If(Empty(aCols[N,nPosFilMat]),xFilial("QAA"),aCols[N,nPosFilMat])  
Return(cFiltro) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215RightMed³Autor³Cleber Cousa           ³ Data ³23/08/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Posiciona o foco na coluna da medição conforme parametro	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215RightMed(nLab,nEns)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao atual da Laboratorio  				      ³±±
±±³          ³ EXPN2 = Posicao atual do Ensaio  	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q215RightMed(nLab,nEns)

Local nRight := GetMv("MV_QPOSFOC",.F.,6)
Local nY     := 0

//Verifica se esta acessando a pasta de Laudo Geral ou Baixa do CQ.
If nLab==nFldLabGer.or.nLab==nFldLibCQ0
	Return()
EndIf
	
//Posiciona na primeira coluna
aOBJETOS[OBJ_MED,nLab,nEns]:oBrowse:GoColumn(nRight+1)

Return() 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QE215Seq    ³ Autor ³Cleber Souza           ³ Data ³ 12/09/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica a sequencia das medicoes                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Cadastro de Resultados								        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QE215Seq(oGet)
Local nC		:= 0
Local nCount1	:= 0

For nC := 1 To Len(oGet:aCols)
	If !oGet:aCols[nC,Len(oGet:aCols[nC])]
		nCount1++
	EndIf
Next nC
cTexSeq := STR0252+ StrZero(oGet:nAT,3)+ STR0253 + StrZero(nCount1,3) //"Medicao : "### " de "
aOBJETOS[OBJ_SEQ,nFldLab]:Refresh()
Return(.t.)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QE215FLIBUºAutor  ³Cleber Souza 		 º Data ³  29/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Seta foco na ultima pasta do folder para Liberacao Urg.    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIEA215			                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QE215FLIBU()

//Seta no Folder do Laudo Geral.
If lLiberaUrg 

	//Posiciona os dados do Folder
	Q215SetLab(nFldLabGer,nFldLab)

	oFolder:nOption :=  nFldLabGer
	nFldLab := nFldLabGer
	oFolder:Refresh()
EndIF

Return .T.  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Q215TxtEns³ Autor ³Cleber Souza           ³ Data ³10/08/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe o texto do Metodo do Ensaio						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q215TxtEns()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QIEA215() 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215TxtEns()
Local cChave
Local cCabec   := OemToAnsi(STR0255) //"Texto do Ensaio"
Local cTitulo  := OemToAnsi(STR0256) //"Ensaio"
Local nTamLin  := TamSX3("QA2_TEXTO")[1]
Local cEspecie := "QIEA020 "         //Para gravacao de textos
Local aAmbSave := GetArea()
Local aTextos  := {} 
Local aAreaQA2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera/obtem a chave de ligacao com o texto do emsaio		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
iF nFldLab <> nFldlabGer .and. nFldLab < 3
	QE1->(dbSetOrder(1))
	If QE1->(dbSeek(xFilial("QE1")+aResultados[nFldLab,_ENS,nFldEns,ENSAIO]))
		If Empty(QE1->QE1_CHAVE)   
	
			aAreaQA2 := GetArea()
			cChave   := QA_NewChave("QE1",2)
	   		RestArea(aAreaQA2)
	
			dbSelectArea("QE1")
			RecLock("QE1",.F.)
			QE1->QE1_CHAVE := cChave
			MsUnLock()
		Else
			cChave := QE1->QE1_CHAVE
		EndIf
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Digitacao do Texto do Ensaio	  						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QA_TEXTO(cChave,cEspecie,nTamlin,cTitulo,AllTrim(QE1->QE1_ENSAIO),@aTextos,1,cCabec,.F.)
Else
	MessageDlg(STR0264,,3) //"Para visualização do texto do ensaio, deverá estar posicionado na pasta do laboratório e ensaio desejado"
Endif 
	

RestArea(aAmbSave)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QP215FillG³ Autor ³Cicero Odilio Cruz            ³09/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Montagem generica do aHeader com fillget					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIP														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³ 										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP215FillG(cAlias, nOpcx, cWhile, cSeek, aCols)
Default nOpcx   := 3
Default cWhile  := ''
Default cSeek 	:= ''
Default aCols   := {}

FillGetDados(	nOpcx,; 								// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
               	cAlias,;       							// area a ser utilizada;
               	1,;      								// nOrdem - ordem correspondente a chave de índice para preencher o  acols;
               	Iif((nOpcx == 3),'',&cSeek),;  			// chave utilizada no posicionamento da área para preencher o acols; 
               	{|| &cWhile},; 							// bloco contendo a expressão a ser comparada com cSeekKey na condição  do While. 
               	{|| .T.},;  							// uSeekFor
               	,;  						 			// aNoFields - array contendo os campos que não estarao no aHeader;
               	,;  									// aYesFields - array contendo somente os campos que estarao no aHeader;
               	.F.,;      								// se verdadeiro, exibe apenas os campos de usuário;
                '',;      								// cQuery - query a ser executada para preencher o acols;
               	,;    				   					// bloco contendo funcao especifica para preencher o aCols; 
               	Iif((nOpcx == 3),.T.,.F.),;  			// lEmpty 
               	,; 										// aHeaderAux
               	,; 		   								// aColsAux
               	,; 										// bAfterCols
               	,; 										// bBeforeCols
               	,; 										// bAfterHeader
               	'') 									// cAliasQry

Return aHeader

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QE215VldMedºAutor  ³Adalberto M.Neto   º Data ³  20/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que realiza validacao entre os campos QAA_NIVEL do   º±±
±±º   da     ³ cadastro de usuarios e o campo QE1_NIENSR do cadastro de    º±±
±±º  Funcao  ³ Ensaio.  O nivel do Usuario nao pode ser menor que o Ensaio º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ NIL  													   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ EXPL01 = Resultado da Validacao                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIEA215                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE215VldMed()

Local lRet			:= .T.   
Local aColsEns  	:= aOBJETOS[OBJ_MED,nFldLab,nFldEns]:aCols   
Local cEns			:= aResultados[nFldLab,_ENS,nFldEns,ENSAIO]
Local cVar			:= 0
Local nPosEns		:= Ascan(aSavHeadEns[nFldLab,nFldEns],{|x|Alltrim(x[2])=="QER_ENSR"  })

If nPosEns == 0
	nPosEns := 5
Endif

cVar := aColsEns[N,nPosEns]

QE1->(dbSeek(xFilial("QE1")+cEns))
QAA->(dbsetorder(1))
QAA->(dbSeek(aCols[N,nPosFilMat]+cVar))
If Val(QAA->QAA_NIVEL) < Val(QE1->QE1_NIENSR)
	Help(" ",1,"Q215005") //"Ensaiador não tem o nível exigido para o Ensaio
	lRet := .F.
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q215IFIC  ºAutor  ³Denis Martins       º Data ³  07/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclusao de ponto de entrada para impressao do relatorio    º±±
±±º          ³Ficha de Uso (QIER200)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIEA215                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215IFIC()
If ExistBlock("Q215IFIC")       
	ExecBlock("Q215IFIC",.F., .F.)
Else	
	QIER200("QIEA200")
Endif
Return Nil	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QE215RDL  ³ Autor ³ Sergio S. Fuzinaka           ³ 24.01.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a Descricao do Laudo conforme o Pais.               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE215RDL(cAlias,nOrdem,cChave)

Local aArea		:= GetArea()
Local aAreaQED	:= (cAlias)->(GetArea())

Local cDescPo 	:= ""		//Descricao em Portugues
Local cDescIn 	:= ""		//Descricao em Ingles
Local cDescEs 	:= ""		//Descricao em Espanhol
Local cRet		:= ""

//Tratamento generico de tabelas
If cAlias == "QED"
	cDescPo := "QED->QED_DESCPO"
	cDescIn := "QED->QED_DESCIN"
	cDescEs := "QED->QED_DESCES"
Endif

dbSelectArea(cAlias)
dbSetOrder(nOrdem)
If dbSeek(cChave)
	cRet := QaxIdioma(cDescPo,cDescIn,cDescEs)
Endif

RestArea( aAreaQED )
RestArea( aArea )

Return( cRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A200DePr ³ Autor ³ Quality				³ Data ³22/10/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra a descricao do Produto do QE6                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA215 - Cham. via gatilho e X3_RELACAO - QEK_PRODUT      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A215DePr(cCodfil, cProduto,lGatilho,cRevi)
Local cRetorno := Space(TamSX3("QE6_DESCPO")[1])
Local aAreaAnt := GetArea()
Local aAreaQE6 := QE6->(GetArea())

Default cRevi    := ""

lGatilho := If(lGatilho==NIL,.T.,lGatilho)  
Inclui := IIf(Type('Inclui') == "U" , .F. , Inclui) 

If FWMODEACCESS ('QE6') == 'C'
	cCodFil := xfilial("QE6")
Endif	
IF !Inclui .Or. lGatilho	
	If ! Empty(cProduto)   
		dbSelectArea("QE6")
		dbSetOrder(3)
		dbSeek(ccodfil+cProduto+cRevi,.T.)
		If !Eof()
			If cRevi <> ""
				cRevi    := QE6->QE6_REVI
				cRetorno := QE6->QE6_DESCPO
		    Else
				While !Eof() .And. cProduto == QE6->QE6_PRODUT
					If QE6->QE6_REVI > cRevi
						cRetorno := QE6->QE6_DESCPO
					EndIf
					dbSkip()
				EndDo
				Endif
			EndIf
	EndIf
EndIf
RestArea(aAreaQE6)
RestArea(aAreaAnt)

Return(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q215InsDOk³ Autor ³ Rafael Duram Santos ³ Data ³ 21/02/2013   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a exclusão de linhas dos Instrumentos	           	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEA215																 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q215InsDOk()

Local lRet := .T.

If !Empty(aResultados[1,_LAU,3])
	lRet := .F.
Endif

Return lRet


/*/{Protheus.doc} Q215DESLAU
Apura a Descrição do Laudo conforme o Idioma do Sistema
@author    Marcelo Cardoso Barbosa
@version   1.00
@since     14/02/2017
/*/
Function Q215DesLau(cLaudo)

	Local cDesLau 	:= ""
	Local cOldArea 	:= Alias()
	Local aOldArea 	:= GetArea()
	
	Do Case
	
		Case AllTrim(Upper(__LANGUAGE)) == "PORTUGUESE"
			
			cDesLau := 	Posicione("QED", 1, xFilial("QED") + cLaudo, "QED_DESCPO")
			
		Case AllTrim(Upper(__LANGUAGE)) == "SPANISH"
			
			cDesLau := 	Posicione("QED", 1, xFilial("QED") + cLaudo, "QED_DESCES")
			
		Case AllTrim(Upper(__LANGUAGE)) == "ENGLISH"
			
			cDesLau := 	Posicione("QED", 1, xFilial("QED") + cLaudo, "QED_DESCIN")
			
	EndCase
	
	DBSelectArea(cOldArea)
	RestArea(aOldArea)

Return(cDesLau)
