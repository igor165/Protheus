#INCLUDE "PROTHEUS.CH"
#INCLUDE "FOLDER.CH"                                                                                             
#INCLUDE "COLORS.CH"                                                                                                    
#INCLUDE "FILEIO.CH"  
#INCLUDE "QIPA216.CH"  

#DEFINE MIN_BUILD_VERSION	"7.00.080806P"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                   
//³ Posicao do aHeader utilizado nas medicoes					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE HEAD_NCS    1                                                                               
#DEFINE HEAD_INST   2
#DEFINE HEAD_ANEXO  3
#DEFINE HEAD_RASTRO 4

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                   
//³ Posicao no aObjGet utilizado nas medicoes					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE _TXT         1  // Carta Texto                                                                              
#DEFINE _TMP         2  // Carta Tempo
#DEFINE _CARP        3  // Carta P
#DEFINE _CARNP       4  // Carta NP
#DEFINE _CARU        5  // Carta U
#DEFINE _CARC        6  // Carta Ind
#DEFINE _IND00       7  // Carta IND -> Tamanho 1 ou 2
#DEFINE _IND03       8  // Carta IND -> Tamanho 3
#DEFINE _IND04       9  // Carta IND -> Tamanho 4
#DEFINE _IND05       10 // Carta IND -> Tamanho 5
#DEFINE _IND06       11 // Carta IND -> Tamanho 6
#DEFINE _IND07       12 // Carta IND -> Tamanho 7
#DEFINE _IND08       13 // Carta IND -> Tamanho 8
#DEFINE _IND09       14 // Carta IND -> Tamanho 9
#DEFINE _IND10       15 // Carta IND -> Tamanho 10
#DEFINE _XBR00       16 // Carta XBR -> Tamanho 1 ou 2
#DEFINE _XBR03       17 // Carta XBR -> Tamanho 3
#DEFINE _XBR04       18 // Carta XBR -> Tamanho 4
#DEFINE _XBR05       19 // Carta XBR -> Tamanho 5
#DEFINE _XBR06       20 // Carta XBR -> Tamanho 6
#DEFINE _XBR07       21 // Carta XBR -> Tamanho 7
#DEFINE _XBR08       22 // Carta XBR -> Tamanho 8
#DEFINE _XBR09       23 // Carta XBR -> Tamanho 9
#DEFINE _XBR10       24 // Carta XBR -> Tamanho 10 
#DEFINE _XBS00       25 // Carta XBS -> Tamanho 1 ou 2
#DEFINE _XBS03       26 // Carta XBS -> Tamanho 3
#DEFINE _XBS04       27 // Carta XBS -> Tamanho 4
#DEFINE _XBS05       28 // Carta XBS -> Tamanho 5
#DEFINE _XBS06       29 // Carta XBS -> Tamanho 6
#DEFINE _XBS07       30 // Carta XBS -> Tamanho 7
#DEFINE _XBS08       31 // Carta XBS -> Tamanho 8
#DEFINE _XBS09       32 // Carta XBS -> Tamanho 9
#DEFINE _XBS10       33 // Carta XBS -> Tamanho 10
#DEFINE _XMR00       34 // Carta XMR -> Tamanho 1 ou 2
#DEFINE _XMR03       35 // Carta XMR -> Tamanho 3
#DEFINE _XMR04       36 // Carta XMR -> Tamanho 4
#DEFINE _XMR05       37 // Carta XMR -> Tamanho 5
#DEFINE _XMR06       38 // Carta XMR -> Tamanho 6
#DEFINE _XMR07       39 // Carta XMR -> Tamanho 7
#DEFINE _XMR08       40 // Carta XMR -> Tamanho 8
#DEFINE _XMR09       41 // Carta XMR -> Tamanho 9
#DEFINE _XMR10       42 // Carta XMR -> Tamanho 10
#DEFINE _HIS00       43 // HISTOGRAMA -> Tamanho 1 ou 2
#DEFINE _HIS03       44 // HISTOGRAMA -> Tamanho 3
#DEFINE _HIS04       45 // HISTOGRAMA -> Tamanho 4
#DEFINE _HIS05       46 // HISTOGRAMA -> Tamanho 5
#DEFINE _HIS06       47 // HISTOGRAMA -> Tamanho 6
#DEFINE _HIS07       48 // HISTOGRAMA -> Tamanho 7
#DEFINE _HIS08       49 // HISTOGRAMA -> Tamanho 8
#DEFINE _HIS09       50 // HISTOGRAMA -> Tamanho 9
#DEFINE _HIS10       51 // HISTOGRAMA -> Tamanho 10

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os niveis por Laboratorio no vetor aResultados		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE _OPE 1  //Operacao
#DEFINE _LAB 2  //Laboratorio
#DEFINE _ENS 3  //Ensaio
#DEFINE _MED 4  //Medicoes
#DEFINE _NCO 5  //Nao-conformidades
#DEFINE _CRO 6  //Cronicas
#DEFINE _INS 7  //Instrumentos
#DEFINE _ANE 8  //Documentos anexos
#DEFINE _LLA 9  //Laudo do laboratorio
#DEFINE _LOP 10 //Laudo da Operacao  
#DEFINE _MOP 11 //Mensagem da Operacao
#DEFINE _RAS 12 //Rastreabilidade  
#DEFINE _PLA 13 //Plano de Amostragem  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicoes das colunas no browse que contem os ensaios associa-³
//³	dos a cada Laboratorio.										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE SEQ     01 //Sequencia do Laboratorio
#DEFINE ENSAIO  02 //Ensaio corrente
#DEFINE DESPOR  03 //Descricao do Ensaio Portugues
#DEFINE CARTA   04 //Carta
#DEFINE LIE     05 //Limite Inferior de Engenharia
#DEFINE VLRNOM  06 //Valor Nominal
#DEFINE LSE     07 //Limite Superior de Engenharia
#DEFINE QTDMED  08 //Quantidade de Medicoes (carta) 
#DEFINE TEXTO   09 //Texto do ensaio tipo TXT 
#DEFINE SKPTST  10 //Situacao do Skip-Teste
#DEFINE METODO  11 //Metodo
#DEFINE REVDOC  12 //Revisao do Documento 
#DEFINE DESING  13 //Descricao do Ensaio Ingles
#DEFINE DESESP  14 //Descricao do Ensaio Espanhol                
#DEFINE ENSOBR  15 //Define se o Ensaio eh Obrigatorio  
#DEFINE PLAMO   16 //Plano de Amostragem
#DEFINE ROTEIRO 17 //Roteiro de Operações
#DEFINE FAMVINC 18 //Define se tem Familia Vinculada
#DEFINE ENSCALC 19 //Identifica se o Ensaio é Calculado
#DEFINE FORMUL  20 //Fórmula do ensaio caso seja Cálculado
#DEFINE MINMAX  21 //Define o tipo de controle aplicado 1 = Min/Max, 2 = Min, 3 = Max
#DEFINE VINCALC 22 //Identifica a quais ensaios calculados o ensaios esta vinculado
#DEFINE ENSALT  23 //Utilizado para identificar a alteração de um ensaio //ENSALT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define parametros para salvar posicao do a Resultados.		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             
#DEFINE SAV_LAUO  1
#DEFINE SAV_MED   2
#DEFINE SAV_NCO   3
#DEFINE SAV_INS   4
#DEFINE SAV_CRO   5
#DEFINE SAV_LAUL  6
#DEFINE SAV_LAUG  7  
#DEFINE SAV_RAS   8

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216ATURESºAutor  ³Cicero Odilio Cruz  º Data ³  10/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Skin alternativo da tela de Resuldados no ambiente Inspeção º±±
±±º          ³ de processos                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A216NResul(cAlias,nReg,nOpc,aGetOPOper,lAltera)

DbSelectArea(cAlias)
DbGoTop()
DbGoTo(nReg)

If lAltera <> Nil
	Altera := lAltera
Endif

QP216ATURES(cAlias, nReg, nOpc, Nil, aGetOPOper)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216ATURESºAutor  ³Cicero Odilio Cruz  º Data ³  10/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Skin alternativo da tela de Resuldados no ambiente Inspeção º±±
±±º          ³ de processos                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP216ATURES(cAlias,nReg,nOpc,cOperAut,aGetOPOper)     // Revisar esta função deixando-a como uma casca
Local cResource := ""
Local oDlgMain
Local oBntCon1                                      // tratar a forma de lidar com a tela neste Layout (II)
Local oBntCon2										// no QIPA215, futuramente extrair o Layout (I)
Local oBntCon3                                      // e coloca-lo em touro fonte
Local oBntCon4
Local oBntL1
Local oBntL2
Local oBntL3
Local aAreaIni 	:= GetArea()	// Guarda a area inicial
Local nAt		:= 0
Local nQtdRej	:= 0
Local lDadosOk	:= .T.
Local aButtons	:= {}
Local cChave	:= Space(TamSX3("C2_CHAVE")[1])
Local lQP216J22	:= ExistBlock("QP216J22")
Local lQIPF3SC2	:= ExistBlock("QIPF3SC2")
Local cF3SC2	:= "QC2"
Local bOk       := {|| A216bOk(oDlgMain, @nOpcA) }
Local bCancel   := {|| nOpcA := 0,Iif(A216QFinal(oDlgMain, nOpc, nOpcA ),oDlgMain:End(),.F.)}
Local lGrava    := .T.     
Local lNaoEntra := .F.
Local bLineEns  := { || Iif(oBrwJJ:nAt <= Len(aListEns),{;
								aListEns[oBrwJJ:nAt,1],; 
								aListEns[oBrwJJ:nAt,2],;
								aListEns[oBrwJJ:nAt,3],;
								aListEns[oBrwJJ:nAt,4],;
								aListEns[oBrwJJ:nAt,5],;
								aListEns[oBrwJJ:nAt,6],;
								aListEns[oBrwJJ:nAt,7],;
								aListEns[oBrwJJ:nAt,8],;
								aListEns[oBrwJJ:nAt,9],;
								aListEns[oBrwJJ:nAt,10],;
								aListEns[oBrwJJ:nAt,11],;
								aListEns[oBrwJJ:nAt,12],;
								"",;
								"",;
								"",;
								"" },)}
Local oBarBmp
Local nButLatX		:= 24
Local nButLatY      := 7
Local lCanLibUrg    := .F.
Local aTextoUrg     := {}
Local cChaveUrg     := ""  
Local cLauNivel		:= GetNewpar("MV_QPLDNIV","000")   
Local nPtNpos		:= 0

Local aStruQPL := FWFormStruct(3, "QPL")[3]
Local aStruQPM := FWFormStruct(3, "QPM")[3]
Local nX  

Private lLayout	    := GetMv("MV_QPTRLAY",.F.,"1") == "1"              
Private lValEns	    := .F.   // Habilito o Modo de Digitação
Private lCarOtm     := .F.
If !lLayout
	lCarOtm 	    := GetMv("MV_QPCAROT",.F.,"1") == "1"   // Carga Otimizada para o Layout simplificado, o valor default é carregar otimizado. - Usado na J&J
Else
	lCarOtm 	    := .F.
EndIf
Private	cLauOri     := ""
Private lQ216ExecVa := .T.
Private lCarAll		:= .F.
Private bGetoGet    := {|| QIPBGetOP() }

Private aObjGet     := {	{},{},{},{},{},;
							{},{},{},{},{},; //10
							{},{},{},{},{},;
							{},{},{},{},{},; //20
							{},{},{},{},{},;
							{},{},{},{},{},; //30
							{},{},{},{},{},;
							{},{},{},{},{},; //40
							{},{},{},{},{},;
							{},{},{},{},{},; //50
							{}}
Private nQtdMed 	:= 0
Private oBtn		:= ARRAY(60) // Array com os botoes da barra Lateral - Considero 20 botoes para cada painel (TMK, TLV e TLC)
Private lExpandiu   := .F. // Indica que a  tela de Ensaios  foi expandida
Private lExecUpDown := .F. // Indica que o botão UP ou Down foi pressionado
Private lModNav     := .F.
Private nL 			:= 0
Private nR 			:= 0   
Private	nPosMExp 	:= 0
Private	nPosEExp 	:= 0
Private cAliasOPQP7 := "QP7"
Private nPriposs	:= 0
Private lNotLaud    := .T.  // Variavel que indica que não é possivel dar laudos devido ao ensaio calculado.
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Foi efetuada  uma  alteração no comportamento default  do  objeto por  orientação do Frame  esta  alteração é  necessaria  para fazer comq ue  a  tela de Resultados Skin 2 se comporte como a  tela  da 7.10³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Inicio*/
Private lChLFoc := .F. // Impede que a função de foco seja  chamada duas ou mais vezes consecutivas
Private lTeLAbr := .T. // Indica se pode abrir a tela
Private lNoAbrT := .F. // Em se podendo abrir uma  tela, indica se houve uma tentativa de abrir e não abriu a tela
Private cIDFoco := ""
// Fim
Private oBrwJJ
Private aOperSel    := {}
Private cAtuNco 	:= "1"
Private	lAtuIns := .T.
Private lModLau := .F.
Private lModLauO := .F.
Private lNoGravRast:= .F.
	
If aGetOPOper <> Nil
	aOperSel    := aClone(aGetOPOper)
EndIf

Private nOpcX       := nOpc 
Private lLiberaUrg  := .F.  
Private aOperaFull  := {}
Private aResulFull  := {}
Private aPosObj		:= {}
Private aObjects	:= {}
Private aSize		:= {}
Private aPosGet		:= {}
Private aInfo		:= {}   
Private	aSize2   	:= {} 
Private	aPosObj2 	:= {}
Private aPodeAlt	:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis com os dados do usuario que esta anexando o documento.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cMatCod    := QA_Usuario()[3] //Retorna a Matricula do Usuario logado
Private cMatFil    := QA_Usuario()[2] //Retorna a Filial do Usuario logado
Private cMatNom    := QA_Usuario()[6] //Retorna o Nome do Usuario logado
Private aHeadAne := {}
Private	aColsAne := {}
Private nPosAne  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para as Getdados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Private oGetMed     
Private oGetLaudo
Private oGetLauOpe
Private oGetLGer
Private oGet
Private aHeader		:= {}
Private aCols		:= {}
Private nUsado		:= 0
Private oSay1
Private oSay2
Private oSay3
Private oSay5

//Private oSay5
Private oIPClient
Private o220OPER 
Private oIPDescOp
Private oIPDescLab
Private oIP210Op
Private oIP210LC
Private oDtInit
Private oDescPro
Private oIP210L1
Private oIP210L2
Private oIP210L3
Private oEnsNew
Private oBrw
Private oListQP1
Private oDlgMed
Private oGetINS
Private oGetNC
Private hOk := LoadBitmap(GetResources(),"PMSTASK4")  //Aprovado
Private hNo := LoadBitmap(GetResources(),"PMSTASK1")  //Reprovado 
Private hPd := LoadBitmap(GetResources(),"PMSTASK2")  //Pendente 
Private hVz := LoadBitMap(GetResources(),"PMSTASK3")  //Nao utilizado

Private cIP210L1	:= CriaVar("QPL_LAUDO")
Private cIP210L2	:= CriaVar("QPL_LAUDO")
Private cIP210L3	:= CriaVar("QPL_LAUDO")
Private dDtInit 	:= Ctod("  /  /  ")
Private nPosOper	:= 1
Private nPosOpDes	:= 1
Private cDescLab	:= ''
Private cEnsAtu		:= ''
Private cDescOper   := ''
Private cOper		:= ''
Private cLab		:= ''
Private cEnsNew		:= ''
Private aOperacoes  := {}            
Private nFldLauGer  := 2 //Conforme layout do aResultados
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso a Operacao Rapida ja seja passada por parametro, ira montar a tela sem intervencao do usuario ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private	c220OPER	:= CriaVar("QPR_OPERAC")

Private aResultados	:= {}
//Private aResultaBkp	:= {}
Private aListEns	:= {}
Private aGetMed		:= {{},{},{}}
Private nPosVet		:= 0
Private nContEns	:= 0
Private nTipo 		:= 3
Private nAcPosDtM	:= 0
Private nAcPosHrM	:= 0
Private nAcPosAmo	:= 0
Private nAcPosMed	:= 0
Private cCartEns	:= ''
Private nAcPosFilM  := 0
Private nAcPosEsr	:= 0
Private nAcPosRes	:= 0
Private nPosResu	:= 0
Private nAcPosCal	:= 0
Private nAcPosENo	:= 0
Private nAcPosPP	:= 0
Private nAcPosNC	:= 0
Private aObj		:= {}
Private aGet		:= {}
Private aOpRap		:= {}
Private lEntRap		:= .T.
Private cMensNConf	:= ''
Private lNConforme	:= .F.
Private nPosOperac	:= 0
Private cTexto		:= ''
Private cFormul1	:= ''      
Private cFormul2	:= ''
Private cTexto3		:= ''
Private lMensTLot	:= .T.		//Flag utilizado para tratar mensagem Tam.Lote somente uma unica vez.
Private nQtdOpe     := 0
Private nFldOpe 	:= 0
//Salva o aHeader e aCols das Nao-conformidades, Instrumentos, Documentos Anexos e Rastreabilidade
Private aSavaHeader := {{},{},{},{}}
Private aSavaCols   := {{},{},{},{}}   
Private aSavTela 	:= {{},{}}   
Private aSavGets    := {}    
Private aSavHeadEns := {}   //Salva o aHeader e aCols definido de acordo com o ensaio selecionado 
Private aSavHeadBkp := {}   //Em alguns lugares do QIPA215 ele zera este array
Private nRegLLA     := 0
Private nRegLLG     := 0
Private nRegLLO     := 0
Private lLauLab 	:= .F. 
Private lLauOp	 	:= .F.
Private lLauGer	 	:= .F.
Private cHrLaud  	:= ""
Private dDtLaud  	:= Ctod("  /  /  ")
Private dDtEnLa  	:= Ctod("  /  /  ")
Private cHrEnLa  	:= ""
Private cLaudo   	:= ""    
Private	cQLotE   	:= ""
Private	cQLotR   	:= ""
Private lExec 		:= .F.
Private lBarLat 	:= .T. 
Private nFatBar 	:= 20
Private lJusLObrG   := .F.             
//Private lECalc	:= .F.  //Indica se existe ensaio calculado, utilizado no Layout 2 somente
//Private lAtuCalc 	:= .F.  //Indica se o ensaio calculado foi atualizado, utilizado no Layout 2 somente
Private lFechaLab   := .T.  //Variavel que permite fechara tela ou não
Private lFechaNC    := .T.  //Variavel que permite fechara tela ou não

//Variaveis para controlar o bchange do ensaio
Private nPosOpAnt   := 1
Private nPosEnsAnt  := 1
Private nPosLabAnt  := 1 
Private lModificou  := .F.
Private lRetLOK     := .T.
Private lZbChan     := .F.
Private bChangeBrw  := {|| Iif( lModificou .AND. !lRetLOK, QP216BrwC(.F.), QP216BrwC(.T.) ) }

Private nOperacao    := 1
Private nOperaAnt    := 1
Private nEnsaio      := 1
Private nFldLab      := 0    //Posicao atual do laboratorio            
Private nFldLabA     := 0    //Posicao do ultimo Folder selecionado
private cRevisao    := ""
Private cMetodo 	:= ""

   
	
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Correção de Defeitos nos  objetos seja  pela  montagem ou defeito não corrigido pela area copetente.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Private cLauAnt     := ""	//Coirrige o defeito do Get do Laudo que chama duas vezes o Valid, é  necessário que  chame  duas  vezes  mas  só é  necessario chamar se o laudo sugerido for trocado
Private lExecJ17	:= .T.
Private lExecuJ4  	:= .T.
Private lLinOKMedi  := .T.
                              
dbSelectArea("QPS")

dbSelectArea("QPS")
dbSelectArea("QPQ")
dbSelectArea("QPT")
dbSelectArea("QM2")
dbSelectArea("QPL")
dbSelectArea("QPM")
dbSelectArea("QPU")
dbSelectArea("SAG")         
DbSelectArea("SAH")

Private cAG_DESCPO	:= CriaVar("AG_DESCPO")

dbSelectArea("QEE")

Private cQEE_DESCPO	:= CriaVar("QEE_DESCPO")

dbSelectArea("QA2")

Private cQA2_TEXTO	:= CriaVar("QA2_TEXTO")

Private  nOpca		:= 0

Private lAviso		:= IIf(GetMv("MV_QIPAVIS" )== "S",.T.,.F.)
Private lAlteravel	:= Iif(GetMv("MV_QMEDLAU") == "S",.T.,.F.)
Private lRastTot	:= Iif(GetMv('MV_QPLRAST') == 'T',.T.,.F.) 
Private lTstDup     := GetMv("MV_QNDUPRO",.T.,.T.)   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³      Inicio Parametros cliente J&J        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private nPosLMPE   := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de integração copm  o Metrologia³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cMV_QIPQMT	:= GetMv("MV_QIPQMT")
Private cMV_QPINAUT	:= GetMv("MV_QPINAUT")			// Define se o Instrumento da primeira  medição será replicado para as medições do ensaio qdo estas forem informadas.
Private cMV_QINTQMT := GetMv("MV_QINTQMT") 			// Define a Integração com o Metrologia
Private cMV_QPINSOB	:= GetMv("MV_QPINSOB") 			// Define a obrigatoriedade da familia do intrumento na rotina de Especificação e em Resultados se o Instrumento para dar o Laudo é obrigatório.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define se quando o instrumento não for obrigatório e familia ³
//³de Instrumento for Informada, na rotina de Resultados        ³
//³1- Bloqueia Laudo e TudoOK                                   ³
//³2- Exibe Alerta                                              ³
//³3- Bloqueia somente Laudo com Regra de Validação Invertida*. ³
//³                                                             ³
//³* Regra de Validação Invertida - No padrão se valida primeiro³
//³o Instrumento e depois a Medição, a opção 3 inverte isso     ³
//³logo será  validado  primeiro a medição e depois o           ³
//³Instrumento.                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cMV_QINOBFM	:= GetMV("MV_QINOBFM",.T.,"2") // Caso o Instrumento não seja  obrigatório e haja uma  familia  vinculada 1 = Valida Instrumento / 2 = Não Valida / 3 = Valida  somente no Laudo do Laboratório
Private cMV_QINVLTX	:= Iif(Valtype(cMV_QINVLTX) == "C", GetMV("MV_QINVLTX",.T.,"2"), GetMV("MV_QINVLTX",.T.,2)) // Define se valida a obrigatoriedade do instrumento para ensaios do tipo Texto 1- Sim ou 2- Não.
Private cMV_QINVTOT := GetMv("MV_QINVTOT",.T.,"2")	// Define se irá atualizar o led do instrumento somente qdo todas as linhas estiverem preenchidas
Private cMV_QPVLIN	:= GetMv("MV_QPVLIN")
// Exclusivo do Layout Simplificado
Private lCPrimOP	:= GetMv("MV_QPCPROP",.F.,"1") == "1" //Indica se o sistema irá carregar a primeira Operação na tela de Resultados ou irá possibilitar ao usuário carregar a Operação desejada, 1 = Sim / 2 = Não 

If !(Alltrim(cMV_QINOBFM) $ "1|2|3")
	MsgAlert("Atualmente o valor do parâmetro MV_QINOBFM é: '"+cMV_QINOBFM+"'."+CHR(13)+CHR(10)+"Este parametro deve estar configurado com 1, 2 ou 3 e seu  tipo deve ser 'C'")
EndIf       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³       Final Parametros cliente J&J        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cMV_QAPCTOL	:= GetMv("MV_QAPCTOL")
Private cMV_QDIREIN	:= GetMv("MV_QDIREIN")
Private cMV_QDIRGRA	:= GetMv("MV_QDIRGRA")
Private cMv_QPMEAUT := GetMv("MV_QPMEAUT")
Private cMV_QINTPC  := GetMv("MV_QINTPC") 
Private lMV_INTRAST := GETMV("MV_INTRAST",,.T.)
Private lMV_QCALLIM := GetMV("MV_QCALLIM")
Private dDataFec    := MVUlmes()
Private lDelOpSC    := GetMV("MV_DELOPSC")== "S"
Private lProdAut    := GetMv("MV_PRODAUT")
Private nObjetos    := 24

Private lQP216Del	:= ExistBlock("QP216DEL")
Private lQIP216J1	:= ExistBlock("QIP216J1")
Private lQIP216J2	:= ExistBlock("QIP216J2")
Private lQIP216J8	:= ExistBlock("QIP216J8")
Private lQP216J15	:= ExistBlock("QP216J15") 

Private lQPR_BOBINA := QPR->(ColumnPos("QPR_BOBINA")) > 0
Private cQPR_BOBINA	:= ""

Private lAltWind	:= .T.		//Validacao das medicoes, ou seja, no momento que eh clicado no botao
								//verifica se poderah continuar ou nao.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O parametro MV_QPNRSER, serah utilizado para que seja controlado a coleta dos resultados³
//³ atraves da O.P. informada e tbem atraves do campo QPR_LOTE (que passarah a ser chamado  ³
//³ de Numero de Serie), desta forma se o parametro existir onde houver chave no QPR na 1a. ³
//³ ordem passarah a assumir nova ordem onde terah a QPR_OP + QPR_LOTE...                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lCtrlNrSer	:= GetMV("MV_QPNRSER",.T.,.F.)
                           
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os Fatores Aprovado, Aprovado Condicional e Reprovado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cFatApr		:= " "
Private cFatRep		:= " "
Private cFatApC		:= " "
Private cFatLU		:= " "
Private lFirst
                  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para gets dos dados da OP ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cIP210Pro	:= CriaVar("QPR_PRODUT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso a OP ja seja passada por parametro, ira montar a tela sem intervencao do usuario ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cIP210OP	:= CriaVar("QPR_OP")
Private cIP210LC	:= CriaVar("QPR_LOTE")
Private cIPCLIENT	:= CriaVar("A7_CLIENTE")
Private cIPLoj		:= Criavar("A7_LOJA")
Private aOper		:= {}
Private lEntrou		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicao das medicoes : utilizado nas telas de Instrumento / NConformidade / Cronica ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nGetMed		:= 0
                    
Private aCpoUsu     := {}  //Armazena os campos ems uso criados pelo usuarios como aliases iguais a QPR,QES,QPQ
Private aCpoQry     := {}  //Armazena os campos a serem utilizados na montagem da Query
Private cRoteiro 	:= "01"
Private aOperAux	:= {}
Private nPsPeAnt    := 1 //Guarda operacao anterior...

If lQPR_BOBINA
	cQPR_BOBINA	:= CriaVar("QPR_BOBINA")
EndIf

aCpoEnc     := {{},{}}
aCpoLOP     := {{},{}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se apresenta tela com o relacionamento entre 		 ³
//³ cliente x Produto.					    					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(QPK->QPK_CLIENT) .And. cMV_QINTPC .And. Empty(QPK->QPK_SITOP)
	QP215Cli()            
	dbSelectArea("QPK")
	RecLock("QPK",.f.)
	QPK->QPK_CLIENT := cIPCLIENT
	QPK->QPK_LOJA   := cIPLoj
	MsUnlock()	
Else
	cIPCLIENT  := QPK->QPK_CLIENT
	cIPLoj     := QPK->QPK_LOJA
EndIf 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o vetor com os campos a serem utilizados na Enchoice LAB³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aStruQPL)
	If cNivel >= GetSx3Cache(aStruQPL[nX,1], "X3_NIVEL") 
		Aadd(aCpoEnc[1],aStruQPL[nX,1])//X3_CAMPO
		Aadd(aCpoEnc[2],GetSx3Cache(aStruQPL[nX,1], "X3_CONTEXT"))
	EndIf
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o vetor com os campos a serem utilizados na Enchoice OPE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aStruQPM)
	If cNivel >= GetSx3Cache(aStruQPM[nX,1], "X3_NIVEL") 
		Aadd(aCpoEnc[1],aStruQPM[nX,1])//X3_CAMPO
		Aadd(aCpoEnc[2],GetSx3Cache(aStruQPM[nX,1], "X3_CONTEXT"))
	EndIf
Next nX

For nX := 1 To Len(aStruQPM)
	If cNivel >= GetSx3Cache(aStruQPM[nX,1], "X3_NIVEL") 
		Aadd(aCpoLOp[1],aStruQPM[nX,1])//X3_CAMPO
		Aadd(aCpoLOp[2],GetSx3Cache(aStruQPM[nX,1], "X3_CONTEXT"))
	EndIf
Next nX

Private nPosJusLau //posicao da Justificativa do Laudo Final da OP
Private nPosLauGer //posicao do Laudo do Laboratorio/Geral da OP

nPosLauGer := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QPL_LAUDO"}) //Posicao do Laudo da OP
nPosJusLau := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QPL_JUSTLA"})//posicao da Justificativa do Laudo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena o aHeader e aCols para os documentos anexos		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := aClone(APBuildHeader("QQJ"))
ADHeadRec("QQJ",aHeader)
aSavaHeader[HEAD_ANEXO] := aClone(aHeader)
aCols   := aClone(QP215aCols("QQJ",Len(aHeader)))
aSavaCols[HEAD_ANEXO]   := aClone(aCols)

nPosAne := Ascan(aHeader,{|x| Upper(Alltrim(x[2])) == "QQJ_ANEXO"}) //Arquivo;Documento Anexo	

aHeader := {}
aCols   := {}

//Private nPosOpe := 1     
Private nPosLab := 1
Private nPosEns := 1

If nOpc == 4
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para permitir prosseguir a exclusao                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QP216J23")	
		lDadosOk := ExecBlock("QP216J23",.F.,.F.,{nOpc,QPK->QPK_OP,QPK->QPK_LOTE,QPK->QPK_NUMSER})
		If !lDadosOk
			If (nOpc == 3 .Or. nOpc == 4)
				QPK->(MsUnlock())		//Libera SoftLock da QPK
			EndIf
			Return(NIL)
		Endif
	Endif
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para permitir prosseguir a atualizacao                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQP216J22
	lDadosOk := ExecBlock("QP216J22",.f.,.f.,{nOpc,QPK->QPK_OP})
Endif
      
dbSelectArea("QPR")
Set Filter To

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os Fatores Aprovado, Aprovado Condicional e Reprovado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QPD->(dbSeek(xFilial("QPD")))
	While !QPD->(Eof())
		If QPD->QPD_CATEG == "1"
			cFatApr := Iif(Empty(cFatApr),QPD->QPD_CODFAT,cFatApr)
		ElseIf QPD->QPD_CATEG == "2"
			cFatApC += QPD->QPD_CODFAT
		ElseIf QPD->QPD_CATEG == "3"
			cFatRep := Iif(Empty(cFatRep),QPD->QPD_CODFAT,cFatRep)
		ElseIf QPD->QPD_CATEG == "4"
			cFatLU := Iif(Empty(cFatLU),QPD->QPD_CODFAT,cFatLU)
		EndIf
		QPD->(dbSkip())
	EndDo
	If Empty(cFatApr) .Or. Empty(cFatApC) .Or. Empty(cFatRep)
		Help(" ",1,"QPH215020")  //Não foram cadastrados os fatores de Indice de Qualidade do Produto (IQP). É necessário existir um Fator para aprovação, Reprovação e Aprovação Condicional. Cadastre para continuar utilizando a rotina resultados.
		lDadosOk	:= .F.
	EndIf
Else
	Help(" ",1,"QPH215020")  //Não foram cadastrados os fatores de Indice de Qualidade do Produto (IQP). É necessário existir um Fator para aprovação, Reprovação e Aprovação Condicional. Cadastre para continuar utilizando a rotina resultados.
	lDadosOk	:= .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao for inclusao verifica se os dados estao coerentes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Inclui .And. lDadosOk
	SC2->(dbSetOrder(1))
	SC2->(dbSeek(xFilial("SC2")+QPK->QPK_OP))
	dDtInit		:= SC2->C2_EMISSAO
	cChave		:= SC2->C2_CHAVE  
	cRoteiro    := SC2->C2_ROTEIRO
	cIP210Pro	:= QPK->QPK_PRODUT
	cIP210OP 	:= QPK->QPK_OP
	cIP210LC	:= QPK->QPK_LOTE 
	cIPCLIENT	:= QPK->QPK_CLIENT
	cIPLoj      := QPK->QPK_LOJA
EndIf

If lDadosOk
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 100, .t., .t. } )
	AAdd( aObjects, { 100, 100, .t., .t. } )
	AAdd( aObjects, { 100, 015, .t., .f. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,265}} ) 
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Divide a tela verticalmente para os botoes da barra lateral  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize2   := aPosObj[1]
	aInfo    := { aSize2[ 2 ]+4, aSize2[ 1 ]+9 , aSize2[ 4 ], aSize2[ 3 ], 0, 0 } //(1,Inicio Linha,3,4,5)
	aPosObj2 := MsObjSize( aInfo, aObjects, .F. , .F. )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³			 Inicio da tela de resultados 			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgMain TITLE STR0001 FROM aSize[7],0 TO aSize[6],aSize[5] OF GetWndDefault() PIXEL  //"Resultados da Producao" 
	
	@ 29,1+Iif(lBarLat,nFatBar,0)		TO	78,(aPosObj[1,4]-239)						   					LABEL STR0002	OF oDlgMain PIXEL 		//"Dados"
	@ 29,(aPosObj[1,4]-236) 			TO	78,aPosObj[1,4]													LABEL STR0003	OF oDlgMain PIXEL 		//"Status"
	@ 79,1+Iif(lBarLat,nFatBar,0)		TO	(aPosObj[2,3]+20),105+Iif(lBarLat,nFatBar,0)					LABEL '' 		OF oDlgMain PIXEL		
	@ 79,108+Iif(lBarLat,nFatBar,0)		TO	(aPosObj[2,3]+20),aPosObj[1,4]									LABEL '' 		OF oDlgMain PIXEL
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Labels da tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 40,004+Iif(lBarLat,nFatBar,0) 		SAY STR0004		OF oDlgMain PIXEL	SIZE 70,8	//"Ordem de Produção: "
	If lCtrlNrSer	//Controle atraves de Nr. Serie
		@ 50,004+Iif(lBarLat,nFatBar,0) 	SAY STR0005		OF oDlgMain PIXEL	SIZE 70,8	//"Nr. Serie:"
	Else
		@ 50,004+Iif(lBarLat,nFatBar,0) 	SAY STR0006		OF oDlgMain PIXEL	SIZE 70,8	//"Lote de Controle:"
	EndIf
	@ 60,004+Iif(lBarLat,nFatBar,0) 		SAY STR0007		OF oDlgMain PIXEL	SIZE 70,8 	//"Produto:"
	@ 68,004+Iif(lBarLat,nFatBar,0) 		SAY STR0008		OF oDlgMain PIXEL	SIZE 70,8	//"Data Inicial:"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Get para Otimizacao das Operacoes                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 38,(aPosObj[1,4]-233)				SAY   STR0009 	OF oDlgMain		PIXEL 			SIZE 33,7 //"Oper.Rápida:"
	@ 38,(aPosObj[1,4]-192)				MSGET o220OPER 	VAR c220OPER	PICTURE "@!" 	VALID A216VLOP(cOper, nOpc, oDlgMain, @cChave, @oBrwJJ) OF oDlgMain		PIXEL SIZE 20,7 //Otimiza a iteração com as Operações
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada para tratamento especifico da consulta padrao do SC2                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQIPF3SC2
		cF3SC2	:= ExecBlock("QIPF3SC2",.f.,.f.)
	EndIf
	  	                         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Status mostrado no canto superior direito ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCtrlNrSer	//Controle atraves de Nr. Serie
		@ 37,55+Iif(lBarLat,nFatBar,0)	MSGET oIP210Op VAR cIP210OP	PICTURE PesqPict("SC2","C2_NUM") ;
		OF oDlgMain		PIXEL SIZE 53.5,7 F3 cF3SC2 	//Ordem de Producao
	
		@ 47,55+Iif(lBarLat,nFatBar,0)	MSGET oIP210LC VAR cIP210LC  VALID Iif(!Empty(cIP210LC),QIP216sOp(cIP210OP,cIP210LC),.T.);
		WHEN INCLUI OF oDlgMain	PIXEL SIZE 53.5,7		//Lote de Controle
	Else
		@ 37,55+Iif(lBarLat,nFatBar,0)	MSGET oIP210Op VAR cIP210OP	PICTURE PesqPict("SC2","C2_NUM") ;
		OF oDlgMain		PIXEL SIZE 53.5,7 F3 cF3SC2 	//Ordem de Producao

		@ 47,55+Iif(lBarLat,nFatBar,0)	MSGET		oIP210LC VAR cIP210LC  WHEN INCLUI OF oDlgMain		PIXEL SIZE 53.5,7		//Lote de Controle
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Movimentacao da Operacao de baixo p/ cima           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 49,(aPosObj[1,4]-192)	BUTTON	oBntCon1 PROMPT '<<'	OF oDlgMain		PIXEL SIZE 10,10 Action Iif(!Empty(cIP210OP).And.lAltWind,Iif(Len(aResultados)>0,(lModNav := .F., A216CResDw(nOpc, oDlgMain,.T.)),.T.),.T.)
	oBntCon1:cToolTip:= OemToAnsi(STR0010)		//"Opera‡„o Anterior..."
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Movimentacao da Operacao de cima p/ baixo		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 49,(aPosObj[1,4]-182)	BUTTON	oBntCon2 PROMPT '>>'	OF oDlgMain		PIXEL SIZE 10,10 Action Iif(!Empty(cIP210OP) .AND. lAltWind ,Iif(Len(aResultados)>0,(lModNav := .F., A216CResUP(nOpc, oDlgMain, .T.)),.T.),.T.)
	oBntCon2:cToolTip:= OemToAnsi(STR0011)		//"Pr¢xima Opera‡„o..."
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Movimentacao do Laboratorio de baixo p/ cima        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 59,(aPosObj[1,4]-192)	BUTTON	oBntCon3 PROMPT '<<'	OF oDlgMain		PIXEL SIZE 10,10 Action Iif(!Empty(cIP210OP).And.lAltWind,Iif(Len(aResultados)>0,(lModNav := .F., a216LabDw()),.t.),.T.)
	oBntCon3:cToolTip:= OemToAnsi(STR0012)		//"Laborat¢rio Anterior..."
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Movimentacao do Laboratorio de cima p/ baixo        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 59,(aPosObj[1,4]-182)	BUTTON	oBntCon4 PROMPT '>>'		OF oDlgMain		PIXEL SIZE 10,10 Action Iif(!Empty(cIP210OP).And.lAltWind,Iif(Len(aResultados)>0,(lModNav := .F., a216LabUp(oDlgMain, Nil, Nil, Nil, .T.)),.t.),.T.)
	oBntCon4:cToolTip:= OemToAnsi(STR0013)		//"Pr¢ximo Laborat¢rio..."
	
	@ 37,(aPosObj[1,4]-40)	MSGET		oIP210L1 VAR cIP210L1 OF oDlgMain		PIXEL SIZE 10,7
	oIP210L1:Disable()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada para verificar se o usuario tera possibilidade de informar o laudo ou visualizar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QIP216J6")
		If Len(aResultados) > 0
			GetPosResu()
			nQtdRej := aResultados[nPosOper,7,1,8]
		Else
			nQtdRej := 0
		EndIf

		@ 36,(aPosObj[1,4]-23)	BUTTON	oBntL1 PROMPT STR0014		OF oDlgMain		PIXEL ACTION Iif(lAltWind .AND. lTeLAbr .AND. lCPrimOP,Iif(ExecBlock("QIP216J6",.f.,.f.,{cIP210OP,SC2->C2_QUANT,nQtdRej,cIP210L1,cOper,cDescLab,nOpc}),QipLaudGer(nOpc),.f.),lTeLAbr := .T.) SIZE 20,10	//"Laudo"
		oBntL1:cToolTip:= STR0015		//"Laudo Geral"
	Else
		If Substr(cLauNivel,3,1) > "0"
			@ 36,(aPosObj[1,4]-23)	BUTTON	oBntL1 PROMPT STR0014 OF oDlgMain PIXEL ACTION Iif(lAltWind .AND. lTeLAbr .AND. lCPrimOP,QPNivGer(cIP210OP,nOpc),lTeLAbr := .T.) SIZE 20,10	//"Laudo"
			oBntL1:cToolTip:= STR0015		//"Laudo Geral" 
		Else
			@ 36,(aPosObj[1,4]-23)	BUTTON	oBntL1 PROMPT STR0014 OF oDlgMain PIXEL ACTION Iif(lAltWind .AND. lTeLAbr .AND. lCPrimOP,QipLaudGer(nOpc),lTeLAbr := .T.) SIZE 20,10	//'Laudo'
	   		oBntL1:cToolTip:= STR0015		//"Laudo Geral"
		EndIf
	Endif
	
	@ 38,(aPosObj[1,4]-115)	SAY	OemToAnsi(STR0014)				OF oDlgMain		PIXEL SIZE 75,8	//"Laudo da Ordem de Produ‡„o"
	
	@ 51,(aPosObj[1,4]-233)	SAY	OemToAnsi(STR0016)			OF oDlgMain		PIXEL SIZE 25,7	//"Opera‡„o"
	@ 51,(aPosObj[1,4]-160)	SAY	oIPDescOp VAR cDescOper 		OF oDlgMain		PIXEL SIZE 101,7
	
	@ 50,(aPosObj[1,4]-40)	MSGET oIP210L2 VAR cIP210L2			OF oDlgMain		PIXEL SIZE 10,7
	oIP210L2:Disable()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada para verificar se o usuario tera possibilidade de informar o laudo ou visualizar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QIP216J5")
		If Len(aResultados) > 0
			GetPosResu()
			nQtdRej := aResultados[nPosOper,6,1,8]
		Else
			nQtdRej := 0
		EndIf
		@ 49,(aPosObj[1,4]-23)	BUTTON	oBntL2	PROMPT STR0014		OF oDlgMain		PIXEL ACTION QPACTBL2( cIP210OP, cOper, SC2->C2_QUANT, nQtdRej, cIP210L2, cDescLab, nOpc, oDlgMain ) SIZE 20,10	//"Laudo"	oBntL2:cToolTip:= STR0017		//"Laudo da Operaçãoo"
	Else
		If Substr(cLauNivel,2,1) > "0"
			@ 49,(aPosObj[1,4]-23)	BUTTON	oBntL2	PROMPT STR0014		OF oDlgMain		PIXEL ACTION QPNivOpe(cIP210OP,cOper,nOpc) SIZE 20,10	//"Laudo"	oBntL2:cToolTip:= STR0017		//"Laudo da Operaçãoo"
			oBntL2:cToolTip:= STR0017		//"Laudo da Operação"		
		Else
			@ 49,(aPosObj[1,4]-23)	BUTTON	oBntL2	PROMPT STR0014		OF oDlgMain		PIXEL ACTION Iif(lAltWind .AND. lTeLAbr .AND. lCPrimOP,QipLauOp(nOpc),lTeLAbr := .T.) SIZE 20,10	//"Laudo"
			oBntL2:cToolTip:= STR0017		//"Laudo da Operação"
		EndIf
	EndIf
	
	If GetMv("MV_Q216ROT",.F.,"2") == "1"
   		@ 40, 170+Iif(lBarLat,nFatBar,0)	SAY	OemToAnsi(STR0100)	OF oDlgMain	PIXEL SIZE 75,8	//"Roteiro de Inspeção: "
		@ 40, 220+Iif(lBarLat,nFatBar,0)   SAY oRoteiro PROMPT cRoteiro  SIZE 40,7 OF oDlgMain PIXEL COLOR CLR_RED
	EndIf                                                            
	
	@ 65, 180+Iif(lBarLat,nFatBar,0) CHECKBOX lValEns PROMPT STR0101 OF oDlgMain PIXEL SIZE 105,8  //"Modo Digitação"
	
	@ 60, 55+Iif(lBarLat,nFatBar,0) 	SAY	oDescPro PROMPT cIP210Pro SIZE 50,8 OF oDlgMain	PIXEL COLOR CLR_BLUE
	
	@ 60,(aPosObj[1,4]-233)	SAY		OemToAnsi(STR0018)			OF oDlgMain		PIXEL SIZE 32,7	//"Laborat¢rio"
	
	@ 61,(aPosObj[1,4]-160)	SAY		oIPDescLab VAR cDescLab		OF oDlgMain 	PIXEL SIZE 80,7
	
	@ 63,(aPosObj[1,4]-40)		MSGET	oIP210L3 VAR cIP210L3		OF oDlgMain		PIXEL SIZE 10,7
	oIP210L3:Disable()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada para verificar se o usuario tera possibilidade de informar o laudo ou visualizar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPtNPos := NposEns  //  	proteção NposEns
	lfirst := .T.   	// controle para execução PE QIP215J12
	If ExistBlock("QIP216J4")
		If Len(aResultados) > 0
			GetPosResu()
			nQtdRej := aResultados[nPosOper,5,1,8]
		Else
			nQtdRej := 0
		EndIf
		@ 62,(aPosObj[1,4]-23) BUTTON oBntL3 PROMPT STR0014 OF oDlgMain PIXEL ACTION (Iif(lValEns ,(Q215PECAL()), Nil ),QPACTBL3(cIP210OP, cDescLab, SC2->C2_QUANT, nQtdRej, cIP210L3, cOper, nOpc, oDlgMain))   SIZE 20,10		//'Laudo' aResultados[nPosOper,_MED,nPosLab,nPosEns] := aClone(aObjGet[Eval(bGetoGet)]:aCols)
//		@ 47,(aPosObj[1,4]-23) BUTTON oBntL3 PROMPT STR0014 OF oDlgMain PIXEL ACTION (QPACTBL3(cIP210OP, cDescLab, SC2->C2_QUANT, nQtdRej, cIP210L3, cOper, nOpc, oDlgMain))   SIZE 20,10		//'Laudo'
			oBntL3:cToolTip:= STR0019		//"Laudo do Laboratório"
	Else
		If Substr(cLauNivel,1,1) > "0"
			@ 62,(aPosObj[1,4]-23) BUTTON oBntL3 PROMPT STR0014 OF oDlgMain PIXEL ACTION QPNivLab(cIP210OP,cDescLab,cOper,nOpc, oDlgMain,lAltWind, lRetLOK,lTeLAbr,lCPrimOP) SIZE 20,10	//"Laudo"
			oBntL3:cToolTip:= STR0019		//"Laudo do Laboratório"
		 Else
			@ 62,(aPosObj[1,4]-23)	BUTTON oBntL3 PROMPT STR0014 OF oDlgMain PIXEL ACTION Iif(lAltWind .AND. lRetLOK .AND. lTeLAbr .AND. lCPrimOP,QipLauLab(nOpc, Nil, oDlgMain), lTeLAbr := .T.) SIZE 20,10		//'Laudo'
				oBntL3:cToolTip:= STR0019		//"Laudo do Laboratório"
		EndIf
	EndIf
    NposEns := nPtNpos   //  proteção NposEns
	oBntL3:BCHANGE := {|| cIDFoco := "ID:Laudo"}	
	
	@ 68,(aPosObj[1,4]-233) SAY STR0020 SIZE 40,7 OF oDlgMain PIXEL //"Ensaio atual:"
	
	@ 68,(aPosObj[1,4]-192) SAY oEnsNew VAR cEnsNew+"-"+QIPXDeEn(cEnsNew) OF oDlgMain PIXEL SIZE 160,7
	
	@ 68, 55+Iif(lBarLat,nFatBar,0)	SAY	oDtInit  PROMPT dDtInit  SIZE 50,8 OF oDlgMain	PIXEL COLOR CLR_HRED
	
	@ (aPosObj[2,3]-3) , 110+Iif(lBarLat,nFatBar,0) 	SAY oSay1 VAR cTexto	SIZE 330,10		OF oDlgMain	PIXEL  
	@ (aPosObj[2,3]+5) , 110+Iif(lBarLat,nFatBar,0) 	SAY oSay2 VAR cFormul1	SIZE 430/2,15	OF oDlgMain	PIXEL
	@ (aPosObj[2,3]+10), 110+Iif(lBarLat,nFatBar,0) 	SAY oSay3 VAR cFormul2	SIZE 430/2,15	OF oDlgMain	PIXEL	
	@ (aPosObj[2,3]+10), (aPosObj[2,4]-40)    			SAY oSay5 VAR cTexto3	SIZE 035,10		OF oDlgMain	PIXEL

    oBrwJJ := TWBrowse():New( 81, 4+Iif(lBarLat,nFatBar,0),98 ,(aPosObj[2,3]-55),{|| { hVz, hVz, hVz, hVz," "," "," "," "," "," "," "," "," "," "," "," " }},;
	{STR0021,STR0022,STR0023,STR0024,STR0025,STR0026,STR0027,STR0028,STR0029,STR0030,STR0031,STR0032,STR0096,STR0097,STR0098,STR0099},{15,15,15,15,15,40,80,30,30,30,30,30,30,30,30,30} ,oDlgMain, , , , , , , , , , , , , , .T., , , , , )	//"Ensaio"###"Descricao"###"Carta"###"Nominal"###"Medicoes"###"Skip-Teste"###"Metodo"###"Oper.Obrig."###"Sequ.Obrig."###"Laud.Obrig."###"Ensa.Obrig."
	     
	If Len(aListEns) == 0
		Aadd(aListEns,{ hVz, hVz, hVz, hVz, " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " " })
	EndIf

	oBrwJJ:lMChange         := .F. // Nao deixar mudar tamanho das colunas.
	oBrwJJ:nClrBackFocus	:= GetSysColor( 13 )
	oBrwJJ:nClrForeFocus	:= GetSysColor( 14 )
	oBrwJJ:SetArray( aListEns )
	oBrwJJ:bLostFocus 	    := {|| QP216RightMe(nPosOper,nPosLab,nPosEns)} 
	oBrwJJ:bLine            := bLineEns                                              
	oBrwJJ:bChange          := {|| cIDFoco := "ID:Ensaios" }
	oBrwJJ:bLDblClick       := {|| QP216VDbl() }
	oBrwJJ:cTitle   		:= "ID:Ensaios"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria botoes utilizados na Enchoicebar        	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lBarLat
		aAdd(aButtons,{"PENDENTE"	,	{|| QP215LegEn()},STR0033,STR0034}) //"Legenda dos Ensaios"###"Leg.Ensa" 
	EndIf

	aAdd(aButtons,{"NCO"		,	{|| Iif(lCPrimOP,QP215ReNCo(),Nil)},STR0035, STR0036 }) //"Não Conformidades..."###"Nao Conf" 
	aAdd(aButtons,{"ENSAIO1"		,	{|| Iif(lCPrimOP,QP215BEnsa(hOK,hNo,hVz),Nil)},"Ensaios...","Ensaio" })	//"Ensaios..."###"Ensaio"

	If !lBarLat
		aAdd(aButtons,{"CARGA"	,	{|| Iif(lCPrimOP,QP215LibU(nOpc, @lCanLibUrg, @aTextoUrg, @cChaveUrg ),Nil)},STR0037,STR0038}) //"Liberacao Urgente"###"Lib.Urg."
	Endif
	
	If lQIP216J1
		Aadd(aButtons,{	"PRODUTO",{||Iif(Len(aResultados)>0,(ExecBlock("QIP216J1",.f.,.f.,{cIP210L2,nOpc,cIP210L1}),;
		aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSALT] := 1 ),;
		MessageDlg(OemToAnsi(STR0039),STR0039,2))},STR0041,STR0042}) //"Nao existe operacao associada a Ordem de Producao."###"Atencao"###"Rastreabilidade..."###"Rastro"
	Else
		Aadd(aButtons,{	"PRODUTO",{||Iif(Len(aResultados)>0,( QP216RAS(),;
		aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSALT] := 1 ),;
		MessageDlg(OemToAnsi(STR0039),STR0039,2))},STR0041,STR0042}) //"Nao existe operacao associada a Ordem de Producao."###"Atencao"###"Rastreabilidade..."###"Rastro"
	EndIf
	
	If lQIP216J2
		Aadd(aButtons,{	"SDUPROP",{||Iif(Len(aResultados)>0,( ExecBlock("QIP216J2",.f.,.f.,{aOperacoes[nPosOper,2],cIP210OP,cIP210L2,nOpc}),; //aOperacoes[nPosOper,2] - cOper
		aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSALT] := 1 ),;
		MessageDlg(OemToAnsi(STR0039),STR0040,2))},STR0043,STR0044}) //"Nao existe operacao associada a Ordem de Producao."###"Atencao"###"Campos informativos","Camp.Inf"
	EndIf
	
	If lQIP216J8
		Aadd(aButtons,{"NOTE",{||Iif(Len(aResultados)>0,( ExecBlock("QIP216J8",.f.,.f.,{cIP210OP}),;
		aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSALT] := 1 ),;
		MessageDlg(OemToAnsi(STR0039),STR0040,2))},STR0045,STR0046}) //"Nao existe operacao associada a Ordem de Producao."###"Assinatura Eletronica..."###"Ass.Elet"
	EndIf
	
	If cLauNivel > "000"
		Aadd(aButtons,{"NOTE",{||Iif(Len(aResultados)>0,( QPAcesso(cIP210OP),aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSALT] := 1 ), MessageDlg(OemToAnsi(STR0039),STR0040,2) )},STR0045,STR0046})  
	EndIf
	If lQP216J15
		Aadd(aButtons,{"PIN",{||Iif(Len(aResultados)>0,( ExecBlock("QP216J15",.f.,.f.,{cIP210OP,nOpc,cIP210L1}),;
		aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSALT] := 1 ),;
		MessageDlg(OemToAnsi(STR0039),STR0040,2))},STR0047,STR0048}) //"Nao existe operacao associada a Ordem de Producao."###"Atencao"###"Observacao"###"Observ"
	EndIf

	Aadd(aButtons,{"LINE"	,{|| Iif(lCPrimOP,QIP215GCT(),Nil)},STR0049,STR0050})	//"Carta de Controle"###"Cart.Con"
	Aadd(aButtons,{"GRAF2D"	,{|| Iif(lCPrimOP,QIP215GDP(),Nil)},STR0051,STR0052})	//"Diagrama de Pareto"###"Diag.Par"

	If lCPrimOP
		If !Empty(AllTrim(cIP210OP))
			If !A216VldOpe( @cIP210Pro, oDescPro, @dDtInit, oDtInit, @cIP210LC, @cChave ) 
				lNaoEntra := .T.
			EndIf
			If !A216GEstru( cIP210Op, nOpc, cIP210LC, Nil, oDlgMain )
				lNaoEntra := .T.
			EndIf
			If lNaoEntra
				dbSelectArea("QPK")
				dbGoTop()
				dbSetOrder(1)
				dbGoto(nReg)
				Return(nOpc) 
			EndIf
			A216VldLt(cIP210OP,@cIP210LC)
			QipLauLab(nOpc, .F. , oDlgMain)
		EndIf
	    If !Empty(AllTrim(aResultados[nPosOper,_LLA,1,3]))
		    cIP210L3 := aResultados[nPosOper,_LLA,1,3]
		    lLauLab  := .T.  
		EndIf
	    If !Empty(AllTrim(aResultados[nPosOper,_LOP,3]))
			cIP210L2 := aResultados[nPosOper,_LOP,3]
			lLauOp   := .T.  
		EndIf
		If !Empty(AllTrim(aResultados[nFldLauGer,1,3]))
			cIP210L1 := aResultados[nFldLauGer,1,3]	  
			lLauLab  := .T.
			lLauOp   := .T. 
		EndIf	              
	Else
		oIP210OP:Disable()
	EndIf
	
	If lBarLat
       
		@aPosObj[1,1]-10,1 	BITMAP oBarBmp RESNAME "PROJETOAP" 		OF oDlgMain 	SIZE aPosObj[1,3]/6.1,aPosObj[1,4] NOBORDER PIXEL
		
		cResource := "PENDENTE"
		@ nButLatX, nButLatY 	BTNBMP oBtn[1] RESOURCE cResource		OF oBarBmp 		SIZE 20,20 									PIXEL MESSAGE STR0102 ;	//"Legenda dos Ensaios"
		ACTION QP215LegEn() 
		
		cResource := "CARGA"
		@ nButLatX*2,nButLatY 	BTNBMP oBtn[2] RESOURCE cResource 		OF oBarBmp 		SIZE 25,25									PIXEL MESSAGE STR0103;		//"Liberacao Urgente"
		ACTION 	Iif(lCPrimOP,( QP215LibU(nOpc, @lCanLibUrg, @aTextoUrg, @cChaveUrg ),;
								aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSALT] := 1 ),;
								Nil)     
		cResource := "CLIPS"
		@ nButLatX*3,nButLatY 	BTNBMP oBtn[4] RESOURCE cResource 		OF oBarBmp 		SIZE 25,25									PIXEL MESSAGE STR0104;		//"Anexar Documentos"
		ACTION 	Iif(lCPrimOP,( 	QipAnexo("QIP",nOpc, IIf(Empty(aResultados[nFldLauGer,1,3]),Iif(Empty(aResultados[nPosOper,_LOP,3]),Iif(!Empty(aResultados[nPosOper,_LLA,nPosLab,3]),lPodeEdt  := .F.,lPodeEdt  := .T.),lPodeEdt  := .F.),lPodeEdt  := .F.)),;
								aListEns[oBrwJJ:nAt,4] := QP215AtuSta(nPosOper,nPosLab,oBrwJJ:nAt,"","E",{4},.T.),;
								aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSALT] := 1,;
								QP216AtuEns(oBrwJJ:oWnd, nPosOper, nPosLab, nPosLab, oBrwJJ:nAt, .F.) ), Nil)  
		
		cResource := "VERNOTA"
		@ nButLatX*4,nButLatY 	BTNBMP oBtn[5] RESOURCE cResource 		OF oBarBmp 		SIZE 25,25									PIXEL MESSAGE STR0105;		//"Visualizar Documento do Ensaio"
		ACTION 	Iif(lCPrimOP,QDOVIEW(,	aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nAT,Ascan(aObjGet[Eval(bGetoGet)]:aHeader,{|x|Alltrim(x[2])=="QPR_METODO"})] , ;
  							aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nAT,Ascan(aObjGet[Eval(bGetoGet)]:aHeader,{|x|Alltrim(x[2])=="QPR_RVDOC"})]), Nil)  
        cResource := "BOTTOM"
		@ nButLatX*5,nButLatY 	BTNBMP oBtn[6] RESOURCE cResource 		OF oBarBmp 		SIZE 25,25									PIXEL MESSAGE STR0106;		//"Expandir Dados do Ensaio"
		ACTION 	Iif(lCPrimOP,QP216EXP(), Nil)  
		
		cResource := "TOP"
		@ nButLatX*5,nButLatY 	BTNBMP oBtn[7] RESOURCE cResource 			OF oBarBmp 		SIZE 25,25									PIXEL MESSAGE STR0107;		//"Recolher Dados do Ensaio"
		ACTION 	Iif(lCPrimOP,QP216EXP(), Nil) 
		oBtn[7]:lVisible := .F. 
		
		cResource := "WATCH"
		@ nButLatX*6,nButLatY 	BTNBMP oBtn[8] RESOURCE cResource 		OF oBarBmp 		SIZE 25,25									PIXEL MESSAGE STR0108;		//"Plano de Amostragem"
		ACTION 	Iif(lCPrimOP,QP216PLM(), Nil) 
	
	EndIf
    
	SetKey(VK_F5,{|| Iif(lValEns ,(aResultados[nPosOper,_MED,nPosLab,nPosEns] := aClone(aObjGet[Eval(bGetoGet)]:aCols), QP215CALMD(), QP216AtuEns(oDlgMain, nPosOper, nPosLab, nPosLab, nPosEns, Nil, Nil, .T.)), Nil ) }) 	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada criado para mudar os botoes da enchoicebar                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QP216BUT")
		aButtons := ExecBlock("QP216BUT",.F.,.F.,{nOpc,aButtons})
	EndIf

	ACTIVATE MSDIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain,bOk,bCancel,,aButtons) VALID A216QFinal(oDlgMain, nOpc, nOpcA)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para permitir prosseguir a gravacao                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca==1 .And. ExistBlock("QP216J24")
	lGrava := ExecBlock("QP216J24",.F.,.F.,{nOpc,cIP210OP})
Endif

If (nOpc==3 .or. nOpc==4) .and. nOpca==1 .and. lGrava
	QP215GrvAll( nOpc, @lCanLibUrg, @aTextoUrg, @cChaveUrg )
EndIf   


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a area anterior ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QPK")
dbGoTop()
dbSetOrder(1)
dbGoto(nReg)

Return(nOpc) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A216bOk   ³ Autor ³Cicero Cruz            ³ Data ³ 20/7/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Tratamento do OK da tela principal.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A216bOk(oDlgMain, nOpcA)

If lModNav  .AND. nPosEnsAnt <> oBrwJJ:nAt .AND. ALTERA
	MsgAlert(STR0109)
	Return Nil
EndIf

If lCPrimOP
	nOpcA := 1
	If QP215TUDOK()
    	QP215SavResu({SAV_MED,SAV_NCO,SAV_INS})
    	oDlgMain:End()
    EndIf
EndIf 
    
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A216VldOpeºAutor  ³Cicero Cruz         º Data ³  23/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação da Ordem de Produção                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A216VldOpe(cIP210Pro,oDescPro,dDtInit,oDtInit,cIP210LC,cChave)
Local lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obs : a Varivel cIP210OP contem Num + Item + Seq. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cIP210OP)
	SC2->(dbSetOrder(1))
	If SC2->(dbSeek(xFilial('SC2')+cIP210OP))
		If lTstDup
			If SG2->(DbSeek(xFilial() + SC2->C2_PRODUTO + SC2->C2_ROTEIRO))
				cIP210Pro	:= SC2->C2_PRODUTO
				dDtInit		:= SC2->C2_EMISSAO
				cChave		:= SC2->C2_CHAVE
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona no QP6 - Historico de Produtos          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QP6->(dbSetOrder(1))
				QP6->(dbSeek(xFilial("QP6")+cIP210Pro))
			Else
				MsgAlert(STR0053,STR0040) //"Roteiro informado na OP incorreto. Favor corrigir !"###"Atenção"
				dDtInit  := Ctod("  /  /  ")
				cIP210Pro := ""
				lRet := .F.
			Endif
		Else
			QQK->(dbSetOrder(1))
			If QQK->(DbSeek(xFilial("QQK") + SC2->C2_PRODUTO + SC2->C2_REVI + SC2->C2_ROTEIRO))
				cIP210Pro	:= SC2->C2_PRODUTO
				dDtInit		:= SC2->C2_EMISSAO
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona no QP6 - Historico de Produtos          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QP6->(dbSetOrder(1))
				QP6->(dbSeek(xFilial("QP6")+cIP210Pro))
			Else
				MsgAlert(STR0053,STR0040) //"Roteiro informado na OP incorreto. Favor corrigir !"
				dDtInit  := Ctod("  /  /  ")
				cIP210Pro := ""
				lRet := .F.
			Endif
		Endif
	Else
		MsgAlert(STR0054+cIP210OP+STR0055,STR0040) //"Não foi possível localizar a Ordem de Produção : "###", por favor verifique-a."###"Atenção"
		dDtInit  := Ctod("  /  /  ")
		cIP210Pro := ""
		lRet := .F.
	Endif
Else
	cIP210Pro := ""
	dDtInit  := Ctod("  /  /  ")
Endif

If Empty(cIP210LC) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Substitui a sugestao do Numero do Lote a partir do empenho do Lote ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QP216LOT")
		cIP210LC := ExecBlock("QP216LOT",.F.,.F.)	
	Else
		dbSelectArea("SD4")
		dbSetOrder(2)
		If dbSeek(xFilial("SD4")+cIP210Op)
			cIP210LC :=  SD4->D4_LOTECTL+SD4->D4_NUMLOTE
		EndIf
		dbSetOrder(1)
	EndIf
EndIf
oIP210LC:Refresh()
oDtInit:Refresh()
oDescPro:Refresh()
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A216GEstruºAutor  ³Cicero Cruz         º Data ³  10/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta a estrutura da tela de Resultados Skin 2             º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A216GEstru(cIP210Op, nOpcA, cIP210LC, aOperac, oDlgMain,;
					cOperCar)
Local lRet		:= .T.
Local cOpera	:= ""
Local cProduto	:= ""
Local cRevi		:= ""

Default cOperCar := "  "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na OP ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC2")
dbSetOrder(1)
dbSeek(xFilial("SC2")+cIP210Op)
cProduto := SC2->C2_PRODUTO
cRoteiro := Iif(Empty(SC2->C2_ROTEIRO),"01",SC2->C2_ROTEIRO) 

dbSelectArea("QPR")
dbSetOrder(9)
If dbSeek(xFilial("QPR")+cIP210OP)
	cRevi 		:= QPR->QPR_REVI
	cIPLoj     	:= QPR->QPR_LOJA
EndIf

If lRet
	If !QP215FLAB(QPK->QPK_PRODUT,QPK->QPK_REVI,@aOper,nOpcA,cOperCar)   
		If (nOpcA == 3 .Or. nOpcA == 4)
			QPK->(MsUnlock())		//Libera SoftLock da QPK		   	
		EndIf
		Return .F.
	Else
		cOpera := aOper[_OPE][1]
	EndIf     
EndIf

If !Empty(cIP210OP)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra a Descricao da Operacao		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aResultados) > 0
		A216CResUP(nOpcA, oDlgMain)
		oIP210OP:Disable()
		
		If lCtrlNrSer	//Controle atraves de Nr. Serie
			oIP210LC:Disable()
		EndIf
		
	    If nOpcA#0
			BuildGd216(,oBrwJJ:nAt,oDlgMain)   
		Else
			cIP210Op := ""	
		EndIF
	EndIf
EndIf

QPR->(dbSetOrder(1))
Return lRet

Static Function A216VldLt(cIP210OP,cIP210LC)
If Empty(cIP210LC)
	dbSelectArea("SD4")
	dbSetOrder(2)
	If dbSeek(xFilial("SD4")+cIP210Op)
		cIP210LC := SD4->D4_LOTECTL+SD4->D4_NUMLOTE
	EndIf
	dbSetOrder(1)
EndIf
Return .T.

Function QIP216sOp(cNumOp,cNumLt,aOperacoes)
Local lRetorno	:= .T.

If INCLUI
	If lCtrlNrSer	//Controle atraves de Nr. Serie
		dbSelectArea("QPR")
		dbSetOrder(8)
		dbSeek(xFilial("QPR")+cNumOp+cNumLt)
	Else
		dbSelectArea("QPR")
		dbSetOrder(1)
		dbSeek(xFilial("QPR")+cNumOp)
	EndIf

	If QPR->(!Eof())
		If cNumOp+cNumLt == QPR->QPR_OP+QPR->QPR_LOTE .and. aOperacoes == Nil

			Help("", 1,"QIP220OP")
			lRetorno := .F.
		EndIf
	EndIf    
EndIf
Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BuildGd216ºAutor  ³Cicero Odilio Cruz  º Data ³  10/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o array de Medições                                   º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BuildGd216(cEnsaio,nPosEns,oDlgMain)
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local aAlter		:= {}

nContEns++
If nContEns > 1 .Or. !lAltWind
	Return(.f.)
EndIf

cEnsAtu	:= aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSAIO]
cEnsNew	:= cEnsAtu
oEnsNew:Refresh()

nQtdMed  := Iif( aResultados[nPosOper,_ENS,nPosLab,nPosEns,CARTA] == 'NP ', 1, aResultados[nPosOper,_ENS,nPosLab,nPosEns,QTDMED] )
cCartEns := aResultados[nPosOper,_ENS,nPosLab,nPosEns,CARTA]  //Define a Carta para o ensaio posicionado

If Empty(cCartEns)
	MsgAlert(STR0056,STR0040) //"O dados deste ensaio n„o est„o completos, poss¡velmente ocorreu uma perda de dados. Verifique e volte a utilizar este registro."###"Atenção"
	Return(.t.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quantidade de Medicoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nQtdMed := Iif( aResultados[nPosOper,_ENS,nPosLab,nPosEns,CARTA] == 'NP ', 1, aResultados[nPosOper,_ENS,nPosLab,nPosEns,QTDMED] )	//Numero de Medicoes

aHeader := aClone(aSavHeadEns[nPosOper,nPosLab,nPosEns])   
aCols 	:= {}               
nUsado	:= 0

//Foi utilizado o comando FOR, no lugar do Ascan pelo fato de nao ter dado o resultado
//esperado. Esta ocorrendo falha com a linha abaixo:
nPosVet := 1
                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui valores as variaveis de Posicao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nAcPosFilM	:= ascan(aHeader, { |x| alltrim(x[2]) == 'QPR_FILMAT' })
nAcPosEsr	:= ascan(aHeader, { |x| alltrim(x[2]) == 'QPR_ENSR'   })
nAcPosENo	:= ascan(aHeader, { |x| alltrim(x[2]) == 'QPR_ENSRNO' })
nAcPosDtM	:= ascan(aHeader, { |x| alltrim(x[2]) == 'QPR_DTMEDI' })
nAcPosHrM	:= ascan(aHeader, { |x| alltrim(x[2]) == 'QPR_HRMEDI' })
nAcPosAmo	:= ascan(aHeader, { |x| alltrim(x[2]) == 'QPR_AMOSTR' })
nAcPosCal	:= ascan(aHeader, { |x| alltrim(x[2]) == 'QPS_CALPOR' })
nAcPosPP	:= ascan(aHeader, { |x| alltrim(x[2]) == 'QPS_MEDIPP' })
nAcPosNC	:= ascan(aHeader, { |x| alltrim(x[2]) == 'QPS_MEDIPN' })
nPosData	:= ascan(aHeader, { |x| alltrim(x[2]) == 'QPR_DTMEDI' })

If cCartEns <> "TXT"
	If cCartEns <> "P  "
		nAcPosMed := ascan(aHeader, { |x| alltrim(x[2]) == 'QPS_MEDICA' })
	Else
		nAcPosMed := ascan(aHeader, { |x| alltrim(x[2]) == 'QPS_MEDIPA' })
	EndIF
	nAcPosRes := ascan(aHeader, { |x| alltrim(x[2]) == 'QPR_RESULT' })
Else
	nAcPosMed := ascan(aHeader, { |x| alltrim(x[2]) == 'QPQ_MEDICA' })
	nAcPosRes := ascan(aHeader, { |x| alltrim(x[2]) == 'QPQ_RESULT' })
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se pode ou nao alterar as medicoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If INCLUI
   nTipo := 3
Elseif ALTERA
   nTipo := 4
Else
   nTipo := 2
EndIf
                    
If QP1->QP1_TIPO == "C"
	nTipoM := 2
Else 
	nTipoM := nTipo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se pode deletar linhas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Altera .Or. Inclui
	lDeleta := .T.
Else
	lDeleta := .F.
EndIf

If lQPR_BOBINA
	Aadd(aAlter,"QPR_BOBINA")
EndIf

For nY:=1 to Len(aCpoUsu)   
	Aadd(aAlter,aCpoUsu[nY,1])
Next nY

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³						 ³
//³ Getdados de Medicoes ³
//³						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If INCLUI .OR. ALTERA

	If Len(aResultados[nPosOper,_MED]) < 0
		aAdd(aResultados[nPosOper,_MED],{})//Laboratorio  
		aAdd(aResultados[nPosOper,_MED,1],aClone(aObjGet[Eval(bGetoGet)]:aCols))
	EndIf               
	QIP216NC(.F.)
	QIP216INS(.F.)    

	aHeader := {}
	aCols   := {}	

	aSavHeadBkp := AClone(aSavHeadEns)
 
EndIf


//Ponto de Entrada apos carregar GetDados da Medicao.
If ExistBlock("QP216MED")
	ExecBlock("QP216MED",.f.,.f.)
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIPA216   ºAutor  ³Cicero Cruz         º Data ³  10/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Posiciona na Operação desejada                             º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GetPosResu(lNoScan)
Local nPosOpe
Local nX := 0
Local aClResult := aClone(aResultados)
Default lNoScan := .F.

If !lNoScan
	If Valtype(aResultados[Len(aResultados),1,1]) == "D" //Indica a posicao de laudo e evite erro de typemismatch - xD
		aDel(aClResult,Len(aClResult))
		aSize(aClResult,Len(aClResult)-1)
		nPosOpe := Ascan(aClResult,{|x|x[_OPE]==cOper})
	Else
		nPosOpe := Ascan(aResultados,{|x|x[_OPE]==cOper})
	Endif
Else 
	nPosOpe := 0
	For nX := 1 To Len(aResultados)-1
		 If aResultados[nX,_OPE] == cOper	
		 	nPosOpe := nX
		 EndIf
	Next
EndIf
Return nPosOpe

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QIPA216  ºAutor  ³Cicero Cruz         º Data ³  10/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o aCols das Medições                                º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qp216Acols(nAtu)
Local lRet		:= .T.
Local cResul	:= ''
Local lQP216J17 :=	ExistBlock("QP216J17")
Local aNc		:= {}
Local nAmo		:= 0
Local nPosRes   := 0
Local nPosChec	:= oBrwJJ:nAt

lAltWind		:= .T.
nContEns		:= 0

If lRet
	nPosRes   := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == 'QPR_RESULT' })
	If nPosRes == 0
		nPosRes   := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == 'QPQ_RESULT' })
	EndIf
EndIf

If !lRet
	lAltWind := .F.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LinOkMedi	³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 11/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Critica se a linha digitada esta' Ok - Getdados Medicoes   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA210													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LinOkMedi(o)
Local lRet	    := .T.
Local cProcura  := ''
Local cMedicao  := '' 
Local cRevi		:= Iif(Empty(QPK->QPK_REVI),QA_UltRvQ(QPK->QPK_PRODUT),QPK->QPK_REVI)
Local aNC		:= {}
Local nAmo		:= 0
Local nDtM		:= 0
Local nPosChec	:= oBrwJJ:nAt
Local nCnt      := 0
Local lQP216J17 := ExistBlock("QP216J17")
Local cResul	:= ''
Local nPosDel   := 0
Local nLMedAtu	:= 0
              
If lModificou
	lRetLOK := .T.
EndIf

nLMedAtu := Eval(bGetoGet)

If Valtype(aObjGet[nLMedAtu]) == "U"
	lRetLOK := .T.
	Return .T.        
EndIf

If !lLinOKMedi .OR. lLiberaUrg .OR. ValType(aObjGet[nLMedAtu]) <> "O"
	Return .T.
EndIf

If !(aObjGet[nLMedAtu]:nAt <= Len(aObjGet[nLMedAtu]:aCols))
	Return .T.
EndIf   

nAcPosFilM	:= aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPR_FILMAT' })
nAcPosEsr	:= aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPR_ENSR'   })
nAcPosENo	:= aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPR_ENSRNO' })
nAcPosDtM	:= aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPR_DTMEDI' })
nAcPosHrM	:= aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPR_HRMEDI' })
nAcPosAmo	:= aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPR_AMOSTR' })
nAcPosCal	:= aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPS_CALPOR' })
nAcPosPP	:= aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPS_MEDIPP' })
nAcPosNC	:= aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPS_MEDIPN' })
nPosData	:= aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPR_DTMEDI' })
nPosDel     := Len(aObjGet[nLMedAtu]:aCols[1]) //Len(aObjGet[nLMedAtu]:aHeader)+1

If aResultados[nPosOper,_ENS,nPosLab,nPosEns,CARTA] <> "TXT"
	If aResultados[nPosOper,_ENS,nPosLab,nPosEns,CARTA] <> "P  "
		nAcPosMed := aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPS_MEDICA' })
	Else
		nAcPosMed := aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPS_MEDIPA' })
	EndIf
	nAcPosRes := aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPR_RESULT' })
Else
	nAcPosMed := aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPQ_MEDICA' })
	nAcPosRes := aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPQ_RESULT' })
EndIf 

If nAcPosRes == 0
	nAcPosRes := aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPQ_RESULT' })
EndIf

If nAcPosRes == 0 .OR. nAcPosMed == 0
	Return .T.
EndIf

If nAcPosMed > 0
	cMedicao  := Iif(Valtype(aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nAcPosMed])=="N",;
					 Str(aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nAcPosMed]),;
					 Iif(Valtype(aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nAcPosMed])=="C",;
					 	 aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nAcPosMed],;
					 	 ''))
Else 
	cMedicao  := ''
EndIf
                  
If nPosChec <> 0

	nAmo	:=	aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPR_AMOSTR' })	
	nDtM	:=	aScan(aObjGet[nLMedAtu]:aHeader, { |x| AllTrim(x[2]) == 'QPR_DTMEDI' })	

	If aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nAmo] == Nil
		aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nAmo] := 1
	EndIf
	
	If Valtype(aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nAmo]) <> "N"
		aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nAmo] := Val(aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nAmo])
	EndIf
	
	If Valtype(aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nDtM]) == "C"
		aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nDtM] := CTOD(aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nDtM])
	EndIf
	
	cProcura := Dtos(aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nDtM])+aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nAcPosHrM]+Str(aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nAmo],1)
EndIf             
If lRet                    

    If ( Empty(Alltrim(cMedicao)) .OR. Alltrim(cMedicao) == ":" ) .AND. !aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nPosDel]
    	If GetMv("MV_QPIESMD",.F.,"2") == "1"
			lRet    := .T.    	
		Else
    		lRet    := .F.
  		EndIf
    EndIf

EndIf

If lRet
    If Empty(Alltrim(aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nAcPosRes])) .AND. !aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nPosDel]
    	lRet := .F.
    EndIf
EndIf

If lRet
	oBrwJJ:cTitle  := "ID:Ensaios"
	
	If Valtype(aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nPosDel]) <> "L"
	   // Por log identificar como cPossErr"Verificar possivel erro 'type mismatch on .NOT.  on LINOKMEDI'"
	EndIf
	
	If lQP216J17 .AND. lModificou .AND. lExecJ17 .AND. !aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt,nPosDel]
		lExecJ17 := .F.
		oBrwJJ:bChange := {|| cIDFoco := "ID:Ensaios" }
		lZbChan := .T.		
		cResul	:=  aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt][nAcPosRes]
		nAmo	:=	aScan(aObjGet[nLMedAtu]:aHeader, { |x| alltrim(x[2]) == 'QPR_AMOSTR' })
		nDtM	:=	aScan(aObjGet[nLMedAtu]:aHeader, { |x| alltrim(x[2]) == 'QPR_DTMEDI' })
		
		If Len(aResultados[nPosOper, _NCO, nPosLab, nPosEns]) >= aObjGet[nLMedAtu]:nAt
			aNc	:= aClone(aResultados[nPosOper,_NCO,nPosLab,nPosEns, aObjGet[nLMedAtu]:nAt])
		EndIf
	
		lRet := ExecBlock("QP216J17",.f.,.f.,{cResul,aResultados[nPosOper, _ENS, nPosLab],cDescLab,cOper,cIP210OP,aNc,aObjGet[nLMedAtu]:aCols[aObjGet[nLMedAtu]:nAt][nAmo]})
		If lRet
			lModificou := .F.
			lNoAbrT    := .T.
		Else 
			lModificou := .T.
			lNoAbrT    := .F.
		EndIf
		lRetLOK  := lRet
		lExecJ17 := .T.
	EndIf
EndIf
If  lModificou
	lRetLOK := lRet // Uso para  controlar  o change  da TWBrowse (Solução para contorno e para atender a JJ)
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QIP216NC º Autor ³ Cicero Odilio Cruz º Data ³  10/22/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Associa a Medicao as Nao Conformidades                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QPR_ENTNC                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qip216NC(lExibe)
Local nBackUsado:= nUsado 	//Guarda nUsado anterior
Local nCnt		:= 0
Local nCntFor	:= 0
Local nOpca		:= 0
Local oDlgNC
Local lDel		:= .F.
Local nOpc		:= 0
Local aTxt		:= {}
Local nC		:= 1
Local nAcols	:= 0
Local axTexto	:= {}
Local nDel		:= 0
Local cChave	:= ''
Local lQP216J16	:= ExistBlock("QP216J16")
Local nPosNConf	:= 0
Local nCount	:= 0
Local cResul	:= ''
Local lRet		:= .T.
Local lDPriElem	:= .F.
Local nPosChvS  := 0  
Local nPosChv   := 0  
Local aAlter    := {}
Local nGetSav	:= aObjGet[Eval(bGetoGet)]:nAT					//Guarda posicao anterior da Getdados Medicoes
Local aHeadSav	:= aClone(aObjGet[Eval(bGetoGet)]:aHeader)	  	//Copia do Vetor aHeader Medicoes
Local aColsSav	:= aClone(aObjGet[Eval(bGetoGet)]:aCols)		//Copia do Vetor aCols Medicoes
Local nSaveSX8  := GetSX8Len() 
Local nPosRes   := 0  
Local aButtNc	:= {}
Local lPodeEdt  := .T.
Local aNCAnt    := {}
Local nPosResul := Ascan(aSavHeadEns[nPosOper,nPosLab,oBrwJJ:nAt,1], { |x| Alltrim(x[2]) == Alltrim("QPR_RESULT") })

If nPosResul == 0
	nPosResul	:= Ascan(aSavHeadEns[nPosOper,nPosLab,oBrwJJ:nAt,1], { |x| Alltrim(x[2]) == Alltrim("QPQ_RESULT") })
EndIf

If Empty(AllTrim(aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nAt, nPosResul])) .OR. aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nAt, Len(aObjGet[Eval(bGetoGet)]:aCols[1])]
	Return .F.
EndIf

Default lExibe  := .T.

aCols			:= {}
aHeader			:= {}
nUsado			:= 0

If Empty(aResultados[nFldLauGer,1,3]) 						// Laudo geral
	If Empty(aResultados[nPosOper,_LOP,3])					// Laudo OP
		If !Empty(aResultados[nPosOper,_LLA,nPosLab,3])	// Laudo Labor.
			lPodeEdt  := .F.
		EndIf
	Else
		lPodeEdt  := .F.
	EndIf
Else
	lPodeEdt  := .F.
EndIf 

aResultados[nPosOper,_MED, nPosLab, oBrwJJ:nAt] :=  aClone(aObjGet[Eval(bGetoGet)]:aCols)
                 
If lPodeEdt
	Aadd(aAlter, "QPU_NAOCON")
	Aadd(aAlter, "QPU_NUMNC")
	Aadd(aAlter, "QPU_NUMNC")
	Aadd(aAlter, "QPU_CLASSE")
	Aadd(aAlter, "QPU_DESCLA")
	Aadd(aAlter, "QPU_DEMIQI")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna a chave de ligacao                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosChvS := aScan(aHeadSav, { |x| AllTrim(x[2]) == "QPR_CHAVE" })
If Empty(AllTrim(aResultados[nPosOper,_MED,nPosLab,oBrwJJ:nAT,aObjGet[Eval(bGetoGet)]:nAT,nPosChvS]))
	cChave := QA_SXESXF("QPR","QPR_CHAVE",,4)
	While ( GetSX8Len() > nSaveSx8 )
		ConfirmSX8()
	EndDo
	aResultados[nPosOper,_MED,nPosLab,oBrwJJ:nAT,aObjGet[Eval(bGetoGet)]:nAT,nPosChvS] := cChave
	aColsSav[aObjGet[Eval(bGetoGet)]:nAT,nPosChvS] := cChave
EndIf

cEnsAtu	:= aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSAIO]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena o aHeader e aCols para as Nao-conformidades         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := aClone(APBuildHeader("QPU"))
ADHeadRec("QPU",aHeader)
aCols   := aClone(Q215FilCol(aHeader,"QPU",1,aResultados[nPosOper,_MED,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAT,nPosChvS],"QPU_CODMED",Len(aHeader)))
If Len(aResultados[nPosOper,_NCO,nPosLab,nPosEns]) >= aObjGet[Eval(bGetoGet)]:nAt .AND. Len(aResultados[nPosOper,_NCO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt]) > 0 .AND. Len(aResultados[nPosOper,_NCO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt,1]) == Len(aHeader)+1
	aCols := aClone(aResultados[nPosOper,_NCO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt])
ElseIf Len(aResultados[nPosOper,_NCO,nPosLab,nPosEns]) < aObjGet[Eval(bGetoGet)]:nAt
    While Len(aResultados[nPosOper,_NCO,nPosLab,nPosEns]) < aObjGet[Eval(bGetoGet)]:nAt
    	If Len(aResultados[nPosOper,_NCO,nPosLab,nPosEns]) == aObjGet[Eval(bGetoGet)]:nAt-1
	    	aAdd(aResultados[nPosOper,_NCO,nPosLab,nPosEns],aClone(Q215FilCol(aHeader,"QPU",1,aResultados[nPosOper,_MED,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAT,nPosChvS],"QPU_CODMED",Len(aHeader))))
	    Else 
			aAdd(aResultados[nPosOper,_NCO,nPosLab,nPosEns],aClone(Q215FilCol(aSavaHeader[HEAD_NCS],"QPU",1,"     ","QPU_CODMED",Len(aSavaHeader[HEAD_NCS]))))	    
	    Endif
	Enddo
Else
	aResultados[nPosOper,_NCO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt] := aClone(aCols)
EndIf
nUsado  := Len(aHeader)+1

If !lExibe
	aSavaHeader[HEAD_NCS] := aClone(aHeader)
	aSavaCols[HEAD_NCS]   := aClone(Q215FilCol(aSavaHeader[HEAD_NCS],"QPU",1,"     ","QPU_CODMED",Len(aSavaHeader[HEAD_NCS])))
EndIf

nOpc := 4

If lExibe
	nPosRes   := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == 'QPR_RESULT' })
	If nPosRes == 0                                            
		nPosRes   := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == 'QPQ_RESULT' })
	EndIf
	If lQP216J16
		If nPosRes > 0
			cResul	:= aResultados[nPosOper,_MED, nPosLab, oBrwJJ:nAt, aObjGet[Eval(bGetoGet)]:nAT, nPosRes]
		Endif	
		lRet := ExecBlock("QP216J16",.f.,.f.,{cResul,aResultados[nPosOper, _ENS, nPosLab]})
    EndIf
EndIf

If lExibe .AND. !lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna aHeader, aCols e variaveis private da getdados 'Medicoes'    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader		:= aClone(aHeadSav)
	aCols		:= aClone(aColsSav)
	nUsado		:= nBackUsado
	n			:= nGetSav

	If ValType(aObjGet[Eval(bGetoGet)]) == "O"
		SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
	EndIf	
	
	Return .F.
EndIf
	
If lExibe
	aNCAnt  := aClone(aResultados[nPosOper,_NCO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt])
	DEFINE MSDIALOG oDlgNC TITLE STR0001+" - "+STR0035 FROM 6.7,0 TO 28,80 OF oMainWnd 	//"Resultados da Produção"
	MontaGets(oDlgNC,'N',oBrwJJ:nAt)
	oGetNC:= MsNewGetDados():New(68,3,134,312,IIF(ALTERA .or. INCLUI,GD_INSERT+GD_UPDATE+GD_DELETE,0),"LinOkNC","TudOkNC","",,,999,,,,oDlgNC,aHeader,aCols)
	oGetNC:oBrowse:aAlter := aAlter
	oGetNC:oBrowse:Refresh()
	
	If lPodeEdt
		oGetNC:lInsert := .T.
		oGetNC:lDelete := .T.
	Else
		oGetNC:lInsert := .F.
		oGetNC:lDelete := .F.     
    EndIf
	
	ACTIVATE MSDIALOG oDlgNC CENTERED ON INIT QP216EncNC(oDlgNC,;
												{|| nOpca:=1,;
												    Iif(TudOkNC(),;
														( oDlgNC:End(),;
														  QP216LACOL(oGetNC:aCols, .T.),;
														  aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSALT] := 1) ,;
														( nOpca:=0 ))},; 
												{|| nOpca:=0,;
												    aResultados[nPosOper,_NCO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt] := aClone(aNCAnt),;
												    oGetNC:aCols := aClone(aResultados[nPosOper,_NCO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt]),;
												    oDlgNC:End()},aHeader,@oDlgNC, lPodeEdt) VALID lFechaNC
	
	If nOpca == 1
	    If Len(oGetNC:aCols) >= 1 .AND. oGetNC:aCols[1] <> Nil
			aResultados[nPosOper,_NCO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt] := aClone(oGetNC:aCols)		
		Else
			oGetNC:aCols :=  aClone(QP215aCols("QPU",Len(oGetNC:aHeader)))
			aResultados[nPosOper,_NCO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt]  :=  aClone(oGetNC:aCols)
		EndIf
	
	EndIf
Else
	aResultados[nPosOper,_NCO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt] := aClone(aCols)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna aHeader, aCols e variaveis private da getdados 'Medicoes'    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader		:= aClone(aHeadSav)
aCols		:= aClone(aColsSav)
nUsado		:= nBackUsado
n			:= nGetSav

If lExibe
	QP216AtuEns(oBrwJJ:oWnd, nPosOper, nPosLab, nPosLab, nPosEns, Nil)
EndIf

If ValType(aObjGet[Eval(bGetoGet)]) == "O"
	SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
EndIf

Return(.f.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIP216CRO ºAutor  ³Cicero Cruz         º Data ³  15/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Associa a Nao Conformidade as Cronicas                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QIPA216 -> Cópia da QIP220CRO da 7.10                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qip216Cro(oDlgNC, lPodeEdt, cAlias, nReg, nOpc)
Local oTextos
Local cTextos	:= ''
Local oSay
Local oIcon
Local oDlgCro    
//Local lPode 	:= .T. 
Local nPosChvNC := 0
Local cResource := ""

If oGetNC:aCols[oGetNC:nAt,Len(oGetNC:aCols[oGetNC:nAt])]
	lPodeEdt := .F. 
EndIf

nPosChvNC := aScan(oGetNC:aHeader, { |x| AllTrim(x[2]) == "QPU_CHAVE" })
If Empty(AllTrim(oGetNC:aCols[oGetNC:nAt,nPosChvNC]))
	cChave := QA_NewChave("QPU",3)
	oGetNC:aCols[oGetNC:nAt,nPosChvNC] := cChave
EndIf

If 	aObjGet[Eval(bGetoGet)]:nAt <= Len(aResultados[nPosOper,_CRO,nPosLab,nPosEns]) .AND.;
	oGetNC:nAt  <= Len(aResultados[nPosOper,_CRO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt]) 
	If !Empty(Alltrim(aResultados[nPosOper,_CRO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt,oGetNC:nAt,1]))
		cTextos := aResultados[nPosOper,_CRO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt,oGetNC:nAt,1]
	Endif
EndIf

DEFINE MSDIALOG oDlgCro TITLE STR0001+" - "+STR0072 FROM 6.7,0 TO 29,42 OF oMainWnd 		//"Resultados da Produção"

cResource := "CLIPS"
@ 001,001 ICON oIcon RESOURCE cResource OF oDlgCro
@ 030,010 SAY oSay PROMPT STR0057 SIZE 140,30 OF oDlgCro PIXEL //"Informe abaixo a Crônica da não conformidade encontrada."
@ 050,010 GET oTextos VAR cTextos MEMO SIZE 140, 100 OF oDlgCro PIXEL
If (!INCLUI .And. !ALTERA) .Or. !lPodeEdt
	oTextos:Disable()
EndIf

ACTIVATE MSDIALOG oDlgCro CENTERED ON INIT EnchoiceBar(oDlgCro,{|| nOpca:=1, oDlgCro:End()},{||oDlgCro:End()})

If nOpca == 1
	While .T.
		If aObjGet[Eval(bGetoGet)]:nAt > Len(aResultados[nPosOper,_CRO,nPosLab,nPosEns])
			Aadd(aResultados[nPosOper,_CRO,nPosLab,nPosEns], {})
		Else 
			Exit
		EndIf
	Enddo
	While .T.
		If  oGetNC:nAt > Len(aResultados[nPosOper,_CRO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt])
			Aadd(aResultados[nPosOper,_CRO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt], {""})
		Else 
			Exit
		EndIf
	Enddo	
	aResultados[nPosOper,_CRO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt,oGetNC:nAt,1] := cTextos
	aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSALT] := 1
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIP216INS ºAutor  ³Marcelo Pimentel    º Data ³  10/22/99   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Associa a Medicao os Instrumentos                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QPR_ENTINS                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qip216INS(lExibe)
Local aAlter		:= {}
Local aHeadSav		:= aClone(aObjGet[Eval(bGetoGet)]:aHeader)	  				//Copia do Vetor aHeader Medicoes
Local aColsSav		:= aClone(aObjGet[Eval(bGetoGet)]:aCols)					//Copia do Vetor aCols Medicoes
Local aInsAnt		:= {}   
Local nBackUsado	:= nUsado 									//Guarda nUsado anterior
Local nGetSav		:= aObjGet[Eval(bGetoGet)]:nAT								//Guarda posicao anterior da Getdados Medicoes
Local nSaveSX8  	:= GetSX8Len()   
Local nPosResul 	:= Ascan(aSavHeadEns[nPosOper,nPosLab,oBrwJJ:nAt,1], { |x| Alltrim(x[2]) == Alltrim("QPR_RESULT") })
Local nY			:= 0
Local nOpca			:= 0
Local lInstru		:= .T.
Local lPodeEdt  	:= .T. 

cEnsAtu	:= aResultados[nPosOper,_ENS,nPosLab,oBrwJJ:nAt,ENSAIO]

If nPosResul == 0
	nPosResul	:= Ascan(aSavHeadEns[nPosOper,nPosLab,oBrwJJ:nAt,1], { |x| Alltrim(x[2]) == Alltrim("QPQ_RESULT") })
EndIf

If Empty(AllTrim(aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nAt, nPosResul])) .OR. aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nAt, Len(aObjGet[Eval(bGetoGet)]:aCols[1])]
	Return .F.
EndIf

aCols			:= {}
aHeader			:= {}
nUsado			:= 0

Default lExibe := .T.

If Empty(aResultados[nFldLauGer,1,3]) //Laudo geral
	If Empty(aResultados[nPosOper,_LOP,3])		// Laudo OP
		If !Empty(aResultados[nPosOper,_LLA,nPosLab,3])	// Laudo Labor.
			lPodeEdt  := .F.
		EndIf
	Else
		lPodeEdt  := .F.
	EndIf
Else
	lPodeEdt  := .F.
EndIf 

If lPodeEdt
	Aadd(aAlter, "QPT_INSTR")
	Aadd(aAlter, "QPT_VALDAF")
EndIf

aResultados[nPosOper,_MED, nPosLab, oBrwJJ:nAt] := aClone(aObjGet[Eval(bGetoGet)]:aCols)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna a chave de ligacao                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosChvS := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == "QPR_CHAVE" })
If Empty(AllTrim(aResultados[nPosOper,_MED,nPosLab,oBrwJJ:nAT,aObjGet[Eval(bGetoGet)]:nAT,nPosChvS]))
	cChave := QA_SXESXF("QPR","QPR_CHAVE",,4)
	While ( GetSX8Len() > nSaveSx8 )
		ConfirmSX8()
	EndDo
	aResultados[nPosOper,_MED,nPosLab,oBrwJJ:nAT,aObjGet[Eval(bGetoGet)]:nAT,nPosChvS] := cChave
	aColsSav[aObjGet[Eval(bGetoGet)]:nAT,nPosChvS] := cChave
EndIf
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena o aHeader e aCols para as Nao-conformidades         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := aClone(APBuildHeader("QPT"))
ADHeadRec("QPT",aHeader)
aCols   := aClone(Q215FilCol(aHeader,"QPT",1,aResultados[nPosOper,_MED,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAT,nPosChvS],"QPT_CODMED",Len(aHeader)))
If Len(aResultados[nPosOper,_INS,nPosLab,nPosEns]) >= aObjGet[Eval(bGetoGet)]:nAt .AND. Len(aResultados[nPosOper,_INS,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt]) > 0 .AND. Len(aResultados[nPosOper,_INS,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt,1]) == Len(aHeader)+1 .AND. len(aCols) == 1
	aCols := aClone(aResultados[nPosOper,_INS,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt])
Else
	If Len(aResultados[nPosOper,_INS,nPosLab,nPosEns]) < aObjGet[Eval(bGetoGet)]:nAt
		aColsVaz  := aClone(Q215FilCol(aSavaHeader[HEAD_INST],"QPT",1,"     ","QPT_CODMED",Len(aSavaHeader[HEAD_INST])))
		For nY := Len(aResultados[nPosOper,_INS,nPosLab,nPosEns]) To aObjGet[Eval(bGetoGet)]:nAt
			If aObjGet[Eval(bGetoGet)]:nAt <> nY
				aAdd(aResultados[nPosOper,_INS,nPosLab,nPosEns],aClone(aColsVaz))
			Else 
				aAdd(aResultados[nPosOper,_INS,nPosLab,nPosEns],aClone(aCols))
			EndIf
		Next
	Else
		aResultados[nPosOper,_INS,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt] := aClone(aCols)
	EndIf
EndIf
nUsado  := Len(aHeader)+1

If !lExibe
	aSavaHeader[HEAD_INST] := aClone(aHeader)
	aSavaCols[HEAD_INST]   := aClone(Q215FilCol(aSavaHeader[HEAD_INST],"QPT",1,"     ","QPT_CODMED",Len(aSavaHeader[HEAD_INST]))) 
EndIf

nOpc := 2

If lExibe
	aInsAnt := aClone(aResultados[nPosOper,_INS,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt])
	DEFINE MSDIALOG oDlgINS TITLE STR0001+" - "+STR0110 FROM 6.7,0 TO 28,80 OF oMainWnd 	//"Resultados da Produção"###"Instrumentos"
	MontaGets(oDlgIns,'I',oBrwJJ:nAt)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Existe um problema na Getdados que quando o 1o. Elemento for excluido nao marca a exclusao, ³
	//³para resolver salvamos o 1o. elemento inicia a Getdados com o 1o. ativo e antes do activate ³
	//³volta a posicao original do 1o. elemento do acols.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGetINS := MsNewGetDados():New(68,3,134,312,IIF(ALTERA .or. INCLUI,GD_INSERT+GD_UPDATE+GD_DELETE,0),"LinOkIN","TudOkIN","",,,999,,,,oDlgINS,aHeader,aCols)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Marca o 1o. Elemento com o original   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGetINS:oBrowse:bDelOk		:= {|| Iif( lPodeEdt, .T., ( oGetINS:aCols[oGetINS:nAt, Len( oGetINS:aCols[nAt] )] := .F., oGetINS:oBrowse:Refresh() ) ) }
	oGetINS:oBrowse:aAlter 		:= aAlter
	oGetINS:oBrowse:Refresh()
	
	ACTIVATE MSDIALOG oDlgINS CENTERED ON INIT EnchoiceBar(oDlgINS,;
															{|| nOpca:=1,;
																Iif(TudOkIN(),;
																	( oDlgINS:End(),;
																	  QP216LACOL(oGetINS:aCols, .F.),;
																	  aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSALT] := 1) ,;
																	( nOpca:=0,;
														  			aResultados[nPosOper,_INS,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt] := aClone(aInsAnt)))},;
															{|| nOpca:=0,;
												    			aResultados[nPosOper,_INS,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt] := aClone(aInsAnt),;
															    oGetINS:aCols := aClone(aResultados[nPosOper,_INS,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt]),;
															    oDlgINS:End()}) VALID Q216FCHINS(aInsAnt, nOpca)
	If nOpca == 1
	    If Len(oGetINS:aCols) >= 1 .AND. oGetINS:aCols[1] <> Nil 
			aResultados[nPosOper,_INS,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt] := aClone(oGetINS:aCols)	
		Else
			oGetINS:aCols :=  aClone(QP215aCols("QPT",Len(oGetINS:aHeader)))
			aResultados[nPosOper,_INS,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt] :=  aClone(oGetINS:aCols)
		EndIf
		If cMV_QINVTOT == "1" 
			For nY := 1 to Len(aResultados[nPosOper,_MED,nPosLab,nPosEns])
				If !aResultados[nPosOper,_MED,nPosLab,nPosEns,nY,Len(aResultados[nPosOper,_MED,nPosLab,nPosEns,1])]
					lInstru := Iif(lInstru,QP215ChkMed(nPosOper,nPosLab,nPosEns,nY,1,,3,.F.,.F.,.F.),.F.) 
				EndIf
			Next
			aListEns[oBrwJJ:nAt,3] := Iif(lInstru,hOk,hPd)
		EndIf
	EndIf
Else
    aResultados[nPosOper, _INS, nPosLab, nPosEns, aObjGet[Eval(bGetoGet)]:nAt] := aClone(aCols)
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna aHeader, aCols e variaveis private da getdados 'Medicoes'    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader		:= aClone(aHeadSav)
aCols		:= aClone(aColsSav)
nUsado		:= nBackUsado
n			:= nGetSav

aObjGet[Eval(bGetoGet)]:oBrowse:lDisablePaint := .F.

If lExibe
	QP216AtuEns(oBrwJJ:oWnd, nPosOper, nPosLab, nPosLab, nPosEns, lExibe)
EndIf

Return(.F.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216LACOLºAutor  ³Cicero Odilio Cruz  º Data ³  04/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Limpa o aCols retirando as linhas deletadas                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QP216LACOL(aColsDel, lNco)
Local nX := 0 

Default lNco := .T.

For nX := Len(aColsDel) To 1 Step -1
	If aColsDel[nX, Len(aColsDel[nX]) ]
		aDel(aColsDel,nX)
		aSize(aColsDel,Len(aColsDel)-1)
		If lNco
			If Len(aResultados[nPosOper,_CRO,nPosLab,nPosEns]) >= aObjGet[Eval(bGetoGet)]:nAt .AND. Len(aResultados[nPosOper,_CRO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt]) >= nX
	   			aDel(aResultados[nPosOper,_CRO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt],nX)
				aSize(aResultados[nPosOper,_CRO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt],Len(aResultados[nPosOper,_CRO,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt])-1)
			EndIf
		EndIf
	EndIf
Next
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaGets ºAutor  ³Cicero Odilio Cruz  º Data ³  23/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta o cabecalho 'Identico para todos'                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Qipa210                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaGets(oNewDlg,cTipo,nPosC)
Local oSayTela
Local oIcon
Local nDtM	:=	aScan(aHeader, { |x| alltrim(x[2]) == 'QPR_DTMEDI' })
Local nHrM	:=	aScan(aHeader, { |x| alltrim(x[2]) == 'QPR_HRMEDI' })
Local cResorce := ""

@ 14,1		TO 062,110	LABEL STR0058	OF oNewDlg PIXEL	//"Dados"
@ 14,113 	TO 062,315	LABEL STR0059	OF oNewDlg PIXEL	//"Status"
@	63.6,1	TO	137,315	LABEL	''			OF oNewDlg PIXEL
@ 140,1 		SAY oSay		PROMPT "" SIZE 315,20 OF oNewDlg PIXEL SHADOW
If cTipo == "I"	//Instrumentos
	cResorce := "INSTRUME"
	@ 010.2, 0.6 ICON oIcon 	RESOURCE cResorce OF oNewDlg
	@ 145, 22 SAY oSayTela 	 	PROMPT STR0060		SIZE 270, 10 OF oNewDlg PIXEL 	//"Informe instrumentos utilizados na medição atual. O Status acima indica qual a medição escolhida no momento."
Else
	cResorce := "NCO"
	@ 010.2, 0.6 ICON oIcon 	RESOURCE cResorce 		OF oNewDlg
	@ 145, 22 SAY oSayTela 		PROMPT STR0061 		SIZE 290, 10 OF oNewDlg PIXEL 	//"Informe as não conformidades encontradas na medição. O Status acima indica qual a medição escolhida no momento."
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Labels da tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 24,004 SAY STR0062	OF oNewDlg PIXEL	SIZE 70,8	//"Ordem de Produção"
@ 34,004 SAY STR0063	OF oNewDlg PIXEL	SIZE 70,8	//"Lote de Controle:"
@ 44,004 SAY STR0064	OF oNewDlg PIXEL	SIZE 70,8	//"Produto:"
@ 53,004 SAY STR0065	OF oNewDlg PIXEL	SIZE 70,8	//"Data Inicial:"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produto / Data ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 44, 35 SAY oDescPro PROMPT cIP210Pro SIZE 50,8 OF oNewDlg PIXEL COLOR CLR_BLUE
@ 53, 35 SAY oDtInit  PROMPT dDtInit   SIZE 50,8 OF oNewDlg PIXEL COLOR CLR_BLUE
@ 24,055 SAY cIP210OP SIZE 40,7 OF oNewDlg PIXEL COLOR CLR_BLUE
@ 34,055 SAY cIP210LC SIZE 50,7 OF oNewDlg PIXEL  COLOR CLR_BLUE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Status mostrado no canto superior direito ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 22,117 SAY STR0066		SIZE 45,7 OF oNewDlg PIXEL		//'Operação Atual:'
@ 32,117 SAY STR0067		SIZE 45,7 OF oNewDlg PIXEL		//"Laboratório Atual:"
@ 42,117 SAY STR0068		SIZE 40,7 OF oNewDlg PIXEL		//"Ensaio atual:"	
@ 52,117 SAY STR0069		SIZE 40,7 OF oNewDlg PIXEL		//"Medição Atual:"

@ 22,165 SAY cDescOper SIZE 70,7 OF oNewDlg PIXEL COLOR CLR_BLUE
@ 32,165 SAY cDescLab  SIZE 70,7 OF oNewDlg PIXEL COLOR CLR_BLUE
@ 42,165 SAY cEnsAtu   SIZE 135,7 OF oNewDlg PIXEL COLOR CLR_BLUE
@ 52,165 SAY Str(aObjGet[Eval(bGetoGet)]:nAT) +STR0070+ Str(Len(aObjGet[Eval(bGetoGet)]:aCols)) SIZE 70,7 OF oNewDlg PIXEL COLOR CLR_BLUE
Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³qp220encNC      ³ Autor ³Marcelo Pimentel   ³ Data ³15/09/98³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Trata a EnchoiceBar na Tela.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Siga Quality - Sigaqip                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QP216EncNC(oDlg,bOk,bCancel,aHeadNC, oDlgNC, lPodeEdt)
Local bSet15
Local bSet24
Local lOk
Local lVolta	:= .F.
Local aCampos	:= {}
Local lInc		:= .T.
Local nPosLau   := QP215GetLau(aSavGets[1,1],"QPM_LAUDO")			
Local nPosLauOP := QP215GetLau(aSavGets[1,2],"QPL_LAUDO")
Local cResource := ""
Local aSize := {25,25}
				
Private oBar,obtn1,obtn2,oBtOk, oBtCan

Aadd(aCampos,	{AllTrim(TitSX3("QP9_NAOCON")[1])	,"AG_NAOCON"}) //"Nao Conformidade"
Aadd(aCampos,	{AllTrim(TitSX3("QP9_DESNCO")[1])	,"AG_DESNCO"}) //"Descricao Nao Conformidade"
Aadd(aCampos,	{STR0071							,"AG_CLASSE"}) //"Classe"

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg
cResource := "S4WB005N"
DEFINE BUTTON RESOURCE cResource OF oBar 		 ACTION NaoDisp()		TOOLTIP "Recortar"
cResource := "S4WB006N"
DEFINE BUTTON RESOURCE cResource OF oBar 		 ACTION NaoDisp()		TOOLTIP "Copiar"
cResource := "S4WB007N"	
DEFINE BUTTON RESOURCE cResource OF oBar 		 ACTION NaoDisp()		TOOLTIP "Colar"
cResource := "S4WB008N"
DEFINE BUTTON RESOURCE cResource OF oBar GROUP  ACTION Calculadora()	TOOLTIP "Calculadora..."
cResource := "S4WB009N"	
DEFINE BUTTON RESOURCE cResource OF oBar 		 ACTION Agenda()		TOOLTIP "Agenda..."
cResource := "S4WB010N"
DEFINE BUTTON RESOURCE cResource OF oBar 		 ACTION OurSpool()		TOOLTIP "Gerenciador de Impress„o..."
cResource := "S4WB016N"
DEFINE BUTTON RESOURCE cResource OF oBar GROUP  ACTION HelProg()		TOOLTIP "Help de Programa..."
cResource := "RELATORIO"                                                              
DEFINE BUTTON oBTN1 RESOURCE cResource	OF oBar GROUP ACTION	Qip216Cro(oDlgNC, lPodeEdt) TOOLTIP STR0072 //"Cronica..."

oBar:nGroups += 2
cResource := "OK"
DEFINE BUTTON oBtOk RESOURCE cResource OF oBar GROUP ACTION (lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP "OK"
SetKEY(15,oBtOk:bAction)

cResource := "CANCEL"
DEFINE BUTTON oBtCan RESOURCE cResource OF oBar ACTION (lLoop:=.f.,Eval(bCancel),ButtonOff(bSet15,bSet24,.T.)) TOOLTIP STR0073	//"Cancelar - <Ctrl-X>"
SetKEY(24,oBtCan:bAction)

oDlg:bSet15 := oBtOk:bAction
oDlg:bSet24 := oBtCan:bAction

oBar:bRClicked := {|| AllwaysTrue()}
Return nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A216CResDw³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 06/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega a Descricao da Operacao - de baixo para cima        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A216CResDw()             					               	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A216CResDw(nOpcA, oDlgMain, lBut)
Local lQip216J7	:= ExistBlock("QIP216J7")
Local lRet		:= .T.
Local nPosOperC := nPosOper
Local cOperAux	:= aResultados[nPosOper,_OPE] //Tentativa de burlar a alteração do aResultados
Local nPosOri   := 0
Local nPosDes   := 0     
Local aResuLGer := {}
Local lExcCarOt := .F. //Indica se a carga otimizada foi executada

Default lBut := .F. 

If !lTeLAbr
	lTeLAbr := .T.
	Return .T.
EndIf

lExecUpDown := .T.

If lBut .AND. lCarOtm .AND. Len(aOperaFull) <> Len(aOperacoes)

	nPosOri := aScan(aOperaFull,{|x| x[2] == aOperacoes[nPosOper,2]})
	
	If nPosOri == 1
		nPosDes := 1
	Else
		nPosDes := aScan(aOperacoes,{|x| x[2] == aOperaFull[nPosOri-1,2]})
	EndIf
	
	If nPosDes == 0

		nPosDes := nPosOri-1
		aResuLGer := aClone(aResultados[Len(aResultados)])
		
    	aDel (aResultados,Len(aResultados))
	    aSize(aResultados,Len(aResultados)-1)
		
		aAdd(aOperacoes , aOperaFull[nPosDes] )
		aAdd(aResultados, aResulFull[nPosDes] )	   

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ordena as arrays de aResultados e aOperacoes				 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSort(aResultados,,,{|x,y|x[1]<y[1]})
		aSort(aOperacoes ,,,{|x,y|x[2]<y[2]})                                 

		aAdd(aResultados, aResuLGer )

		nPosDes   := aScan(aOperacoes,{|x| x[2] == aOperaFull[nPosOri-1,2]})
		nPosOpDes := nPosDes
		nPosOper  := aScan(aOperacoes,{|x| x[2] == aOperaFull[nPosOri  ,2]})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o aResultados com base no aOperaçoes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QP215COPE(QPK->QPK_PRODUT, QPK->QPK_REVI, @aOper, nOpcA, nPosDes)
		
		nFldLauGer := Len(aResultados) 
		
		nPosOperC := aScan(aOperacoes,{|x| x[2] == aOperaFull[nPosOri,2]})  
		
		lExcCarOt := .T.

	EndIf  
	
EndIf

If lQip216J7
	lRet := ExecBlock("QIP216J7",.f.,.f.,{cIP210OP,cOper,cIP210L2})
EndIf

If  lRet .And. Len(aResultados) > 0
	nPosOpAnt := nPosOper
	nPos := Iif(nPosOperC>Len(aResultados),1,nPosOperC)
	nPosOpDes := nPos
	If !Empty(cOperAux)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ No vetor aOperacao devera carregar apenas a 1a. operacao para otimizar a tela de resultados ³
		//³ Posiciona na proxima operacao                                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos--     
		If nPos == 0
			lRet := .F.
		EndIf
		nPos := Iif(nPos<=0,0,nPos)
		If nPos >= 1
			If aResultados[nPos,_OPE] <> cOperAux
				cOper	  := aResultados[nPos,_OPE] 
				nPosOperC := nPos  
				cDescOper := aOperacoes[nPos,2] + " - " + aOperacoes[nPos,3]
			EndIf      
			
			nPosOpDes := nPos 
			a216LabUp( oDlgMain, .T., nPosOperC, lExcCarOt, Nil, .T. )
	
			cDescOper := aOperacoes[nPos,2] + " - " + aOperacoes[nPos,3]

		Else
			nPos++
		EndIf
	EndIf
	oIPDescOp:Refresh()

	cIP210L3 := IIf(!Empty(aResultados[nPosOper,_LLA,nPosLab,3]),aResultados[nPosOper,_LLA,nPosLab,3],"")
	cIP210L2 := IIf(!Empty(aResultados[nPosOper,_LOP,3]),aResultados[nPosOper,_LOP,3],"")
	cIP210L1 := IIf(!Empty(AllTrim(aResultados[nFldLauGer,1,3])),aResultados[nFldLauGer,1,3],"")
    
	If lRet .OR. Empty(cOperAux)
		nPosLab := 1
		nPosEns := 1
	EndIf
EndIf
lExecUpDown := .F.
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³a216CResUp³ Autor ³ Cicero Cruz    	    ³ Data ³ 23/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega a Descricao da Operacao - de cima para baixo        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A210NRes()              					               	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a216CResUp(nOpcA, oDlgMain, lBut)
Local lQip216J7	:= ExistBlock("QIP216J7")
Local lRet		:= .T.
Local lContinua := .T. 
Local lCheckObr := .F.
Local lNaoDelet	:= .T.             
Local lEnsObr	:= .T.
Local lMessag	:= .T.
Local nC		:= 0 
Local lPriOper  := .F.
Local nPosOperC := nPosOper
Local cOperAux	:= aResultados[nPosOper,_OPE] //Tentativa de burlar a alteração do aResultados
Local nCEns     := 0
Local nCount    := 0 
Local nPosOri   := 0
Local nPosDes   := 0     
Local aResuLGer := {}
Local nPosSv		:= 0

Default lBut := .F. 

If !lTeLAbr
	lTeLAbr := .T.
	Return .T.
EndIf

If lQip216J7
	lRet := ExecBlock("QIP216J7",.f.,.f.,{cIP210OP,Subs(cDescOper,1,2),cIP210L2})
EndIf

If lBut .AND. lCarOtm .AND. !lCPrimOP
	Return .T.
EndIf

If lBut .AND. lCarOtm .AND. Len(aOperaFull) <> Len(aOperacoes)
	lExecUpDown := .T.

	nPosOri := aScan(aOperaFull,{|x| x[2] == aOperacoes[nPosOper,2]})

	If nPosOri == Len(aOperaFull) 
		nPosDes := 1 
	Else
		nPosDes := aScan(aOperacoes,{|x| x[2] == aOperaFull[nPosOri+1,2]})
		If nPosDes > 0
			nPosOri := aScan(aOperaFull,{|x| x[2] == aOperacoes[nPosOper,2]})
			nPosDes := aScan(aOperaFull,{|x| x[2] == aOperaFull[nPosOri+1,2] }) 
		EndIf
	EndIf
	
	lVerif  := Iif( nPosDes >= 1 .AND. ( ALTERA .OR. INCLUI ), Q216VNCAR(nPosOri, nPosDes, .T.), .T.)

	If nPosDes <= 0
		nPosOri := aScan(aOperaFull,{|x| x[2] == aOperacoes[nPosOper,2]})
		nPosDes := aScan(aOperaFull,{|x| x[2] == aOperaFull[nPosOri+1,2] })
		lVerif  := Iif(nPosDes >= 1  .AND. ( ALTERA .OR. INCLUI ), Q216VNCAR(nPosOri, nPosDes, .T.), .T.)
		If nPosDes >= 1 .AND. lVerif .AND. aScan(aOperacoes,{|x| x[2] == aOperaFull[nPosDes,2] }) == 0 
	
			aResuLGer := aClone(aResultados[Len(aResultados)])
			
	    	aDel(aResultados,Len(aResultados))
		    aSize(aResultados,Len(aResultados)-1)
			
			aAdd(aOperacoes , aOperaFull[nPosDes] )
			aAdd(aResultados, aResulFull[nPosDes] )	   
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ordena as arrays de aResultados e aOperacoes				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSort(aResultados,,,{|x,y|x[1]<y[1]})
			aSort(aOperacoes,,,{|x,y|x[2]<y[2]})                                 
			
			aAdd(aResultados, aResuLGer )	   		
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o aResultados com base no aOperaçoes ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aOperaFull[nPosDes,2] > aOperaFull[nPosOri,2]
				nPosDes := aScan(aOperacoes,{|x| x[2] == aOperaFull[nPosDes,2]})   
				nPosOpDes := nPosDes
				QP215COPE(QPK->QPK_PRODUT, QPK->QPK_REVI, @aOper, nOpcA, nPosDes, 1) 
			Else
				nPosDes := aScan(aOperacoes,{|x| x[2] == aOperaFull[nPosDes,2]})   
				nPosOpDes := nPosDes
				QP215COPE(QPK->QPK_PRODUT, QPK->QPK_REVI, @aOper, nOpcA, nPosDes, 2) 				
			EndIf
			
			nFldLauGer := Len(aResultados)
		ElseIf !lVerif
			lContinua := .F.
		EndIf  
	EndIf	
	If !lVerif
		lContinua := .F.
	EndIf	
EndIf

If ValType(aObjGet[Eval(bGetoGet)]) == "U"
	lPriOper := .T.
EndIf

If !lPriOper .AND. lContinua .And. lRet .And. Len(aResultados) > 0
	nPos := Iif(nPosOperC>Len(aResultados),1,nPosOperC)
	nPosOpDes := nPos
	If !Empty(cOperAux)
		nPos++
		nPos := Iif(nPos>(Len(aResultados)-1),1,nPos)
		For nC := nPos To Len(aResultados)-1
			If aResultados[nC,_OPE] <> cOperAux
				cOper	  := aResultados[nC,_OPE] 
				nPosOperC := nPos
				nPosOpDes := nPos
				cDescOper := aOperacoes[nPos,2] + " - " + aOperacoes[nPos,3]
				If lRet
					Exit
				EndIf
			EndIf
		Next nC
		nPosOpAnt := aScan(aOperacoes,{|x| x[2] == cOperAux}) 
		nPosSv	:= nPos
		a216LabUp( oDlgMain, .T., nPosOperC, Nil, Nil, .T. )

		cDescOper := aOperacoes[nPosSv,2] + " - " + aOperacoes[nPosSv,3]
	EndIf
	oIPDescOp:Refresh()
Else
	If lPriOper         
		/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³   A variavel aOperSel tem como Objetivo selecionar uma Operação   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		If Len(aOperSel) > 0	
			nPosOpAnt := nPosOper
			nPosOper  := aScan(aOperacoes,{|x| x[2] == aOperSel[2]})
			If nPosOper == 0 
				nPosOper  := 1			
			EndIf
		Else
			nPosOper  := 1			
		EndIf
		
		cOper	  := aResultados[nPosOper,_OPE] 
		cDescOper := aOperacoes[nPosOper,2] + " - " + aOperacoes[nPosOper,3]		
		oIPDescOp:Refresh()  
		nPosOpDes := nPosOper
		
		a216LabUp(oDlgMain, .T., nPosOper)
		
		lRetLOK := .T.
		
	EndIf

EndIf

cIP210L3 := IIf(!Empty(aResultados[nPosOper,_LLA,nPosLab,3]),aResultados[nPosOper,_LLA,nPosLab,3],"")
cIP210L2 := IIf(!Empty(aResultados[nPosOper,_LOP,3]),aResultados[nPosOper,_LOP,3],"")
cIP210L1 := IIf(!Empty(AllTrim(aResultados[nFldLauGer,1,3])),aResultados[nFldLauGer,1,3],"")

If lContinua
	nPosLab := 1
	nPosEns := 1
EndIf

lExecUpDown := .F.
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³a210LabUp ³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 13/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega a Descricao do Laboratorio UP                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A210NRes()              									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a216LabDw(oDlgMain)
Local nC 		:= 0
Local nPos	  	:= 0
Local cNewLab 	:= ''
Local nPosOpLab	:= 0
Local lEntrou 	:= .F.
Local nPosLCar	:= 1 
Local cOperAux	:= aResultados[nPosOper,_OPE]

If !lTeLAbr
	lTeLAbr := .T.
	Return .T.
EndIf

cOper := cOperAux 
lExecUpDown := .T.

If ValType(aObjGet[Eval(bGetoGet)]) <> "U" .AND. Len(aResultados[nPosOper,_MED,nPosLab,oBrwJJ:nAt,1]) == Len(aObjGet[Eval(bGetoGet)]:aCols[1])
	aResultados[nPosOper, _MED, nPosLab, oBrwJJ:nAt] :=  aClone(aObjGet[Eval(bGetoGet)]:aCols)
EndIf

If Len(aResultados) > 0
	
	nPosOper := Iif(nPosOper>(Len(aResultados)-1),1,nPosOper)
	If !Empty(cDescLab) .AND. lExec
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procuro o Laboratório atual               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		For nC := Len(aResultados[nPosOper,_LAB]) To 1 STEP -1
			If Ascan(aResultados, { |x| AllTrim(aResultado[nPosOper,_OPE])+AllTrim(aResultados[nPosOper,_LAB,nC]) == AllTrim(cOper)+AllTrim(cDescLab) } ) > 0
				nPos := nC
				Exit
			EndIf
		Next nC
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso nao encontre o laboratorio correto   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nC := Len(aResultados[nPosOper,_LAB]) To nPos STEP -1
			If aResultados[nPosOper,_OPE] == cOper
				If aResultados[nPosOper,_LAB,nC] <> cDescLab
					cDescLab  := aResultados[nPosOper,_LAB,nC]
					nPosLCar  := nC
					lEntrou   := .T.
					Exit
				EndIf
			EndIf
		Next nC
	Else
		cDescLab := aResultados[nPosOper,_LAB,1]
		lExec := .T.
	EndIf

	If !lEntrou
		nPosOpLab := Ascan(aResultados, { |x|	AllTrim(x[1])==AllTrim(cOper)})
		If nPosOpLab <> 0
			cDescLab := aResultados[nPosOpLab,_LAB,1]
			nPosLCar := 1
		EndIf
	EndIf
	oIPDescLab:Refresh()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega os Ensaios               	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	a216CarEns(nPosLCar, lEntrou, oDlgMain, IIf(!Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLCar,3])) .OR. !Empty(AllTrim(aResultados[nFldLauGer,1,3])),.T.,.F.), 1 )
	SetFocus(oBrwJJ:hWnd)
	cIP210L3 := IIf(!Empty(aResultados[nPosOper,_LLA,nPosLCar,3]),aResultados[nPosOper,_LLA,nPosLCar,3],"")
	cIP210L2 := IIf(!Empty(aResultados[nPosOper,_LOP,3]),aResultados[nPosOper,_LOP,3],"")
	cIP210L1 := IIf(!Empty(AllTrim(aResultados[nFldLauGer,1,3])),aResultados[nFldLauGer,1,3],"")
EndIf
nPosLab := nPosLCar

cIP210L3 := IIf(!Empty(aResultados[nPosOper,_LLA,nPosLCar,3]),aResultados[nPosOper,_LLA,nPosLCar,3],"")
cIP210L2 := IIf(!Empty(aResultados[nPosOper,_LOP,3]),aResultados[nPosOper,_LOP,3],"")
cIP210L1 := IIf(!Empty(AllTrim(aResultados[nFldLauGer,1,3])),aResultados[nFldLauGer,1,3],"")

If ValType(aObjGet[Eval(bGetoGet)]) == "O"
	SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
EndIf

lExecUpDown := .F.
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³a210LabUp ³ Autor ³Cicero Odilio Cruz     ³ Data ³ 12/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega a Descricao do Laboratorio UP                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A210NRes()              									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a216LabUp( oDlgMain, lPriOper, nPosOpCar, lOPRap, lBut, lOPMov)
Local nC 		:= 0
Local nPosLB  	:= 0
Local cNewLab 	:= ''
Local nPosOpLab	:= 0
Local lEntrou 	:= .F.
Local nPosLCar	:= 1 
Local cOper  	:= ''

Default	nPosOpCar 	:= nPosOper  
Default	lOPRap		:= .F.
Default	lBut		:= .F.   
Default	lOPMov		:= .F.   

If !lTeLAbr
	lTeLAbr := .T.
	Return .T.
EndIf

cOper := aResultados[nPosOpCar,_OPE]
lExecUpDown := .T.

Default lPriOper := .F.

If lBut .AND. !lExec
	lExec := .T.
EndIf

If !lPriOper
	If Len(aResultados) > 0
		nPosOpCar := Iif(nPosOpCar>(Len(aResultados)-1),1,nPosOpCar)
		nPosLabAnt := Ascan(aResultados[nPosOpAnt,2],{|x| AllTrim(x)==AllTrim(cDescLab)})
		If !Empty(cDescLab) .AND. lExec
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Procuro o Laboratório atual               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			For nC := 1 To Len(aResultados[nPosOpCar,_LAB])
				If Ascan(aResultados, { |x| AllTrim(aResultado[nPosOpCar,_OPE])+AllTrim(aResultados[nPosOpCar,_LAB,nC]) == AllTrim(cOper)+AllTrim(cDescLab) } ) > 0
					nPosLB := nC
					Exit
				EndIf
			Next nC
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso nao encontre o laboratorio correto   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nC := nPosLB To Len(aResultados[nPosOpCar,_LAB])
				If aResultados[nPosOpCar,_OPE] == cOper
					If aResultados[nPosOpCar,_LAB,nC] <> cDescLab
						cDescLab  := aResultados[nPosOpCar,_LAB,nC]
						nPosLCar  := nC
						lEntrou   := .T.
						Exit
					EndIf
				EndIf
			Next nC
		Else
			cDescLab := aResultados[nPosOpCar,_LAB,1]
			lExec := .T.
		EndIf

		If !lEntrou
			nPosOpLab := Ascan(aResultados, { |x|	AllTrim(x[1])==AllTrim(cOper)})
			If nPosOpLab <> 0
				cDescLab := aResultados[nPosOpLab,_LAB,1]
				nPosLCar := 1
			EndIf
		EndIf
		
		oIPDescLab:Refresh()
		If lExpandiu
			nPosEExp := 1
			nPosMExp := 1
		EndIf
		
		If lModNav
			nPosEnsAnt := 1
			nPosLMPE   := 1
		EndIf		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega os Ensaios               	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		a216CarEns(	nPosLCar,;  // Posicao a carregar do Lab
		            Iif( nPosOpCar<>nPosOper .OR. nPosLab <> nPosLCar , .T., .F.),;  // Indica se zera Objetos
					oDlgMain,;  // Objeto Dlg
					IIf(!Empty(AllTrim(aResultados[nPosOpCar,_LLA,nPosLCar,3])) .OR. !Empty(AllTrim(aResultados[nFldLauGer,1,3])),.T.,.F.),; //Indica se  Bloqueia  a medi'c~ao
					       1,;  // Posicao do Ensaio
					     .F.,;  // Indica Salva Ensaio
					     Nil,;  // Indica se Nao atualiza Medicao
					  lOPRap,;  // Chamado pela Operacao Rapida
					     Nil,;  // Indica se Nao atualiza Ensaio
					     Nil,;  // Indica se Atualiza os Leds
					     Nil)   // Indica a Movimentacao da OP
		
		cIP210L3 := IIf(!Empty(aResultados[nPosOpCar,_LLA,nPosLCar,3]),(lLauLab := .T., aResultados[nPosOpCar,_LLA,nPosLCar,3]),"")
		cIP210L2 := IIf(!Empty(aResultados[nPosOpCar,_LOP,3]),(lLauOp := .T., aResultados[nPosOpCar,_LOP,3]),"")
		cIP210L1 := IIf(!Empty(AllTrim(aResultados[nFldLauGer,1,3])),aResultados[nFldLauGer,1,3],"")
	EndIf
	nPosLab   := nPosLCar 
	nPosOper  := nPosOpCar
Else       
	If lExpandiu
		nPosEExp := 1
		nPosMExp := 1
	EndIf
	If lModNav
		nPosEnsAnt := 1
		nPosLMPE   := 1
	EndIf
	nPosLabAnt := Ascan(aResultados[nPosOpAnt,2],{|x| AllTrim(x)==AllTrim(cDescLab)})
	nPosLCar := 1
	cDescLab := aResultados[nPosOpCar,_LAB,1]
	oIPDescLab:Refresh() 
	nPosOper  := nPosOpCar
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega os Ensaios               	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPriOper
		nPosLab   := 1
		nPosEns   := 1
	EndIf

	a216CarEns(	nPosLCar,;  // Posicao a carregar do Lab
				Iif( nPosOpAnt<>nPosOper .OR. nPosLabAnt <> nPosLCar , .T., .F.),;  // Indica se zera Objetos
				oDlgMain,;  // Objeto Dlg
				Iif(!Empty(AllTrim(aResultados[nPosOpCar,_LLA,nPosLCar,3])) .OR. !Empty(AllTrim(aResultados[nFldLauGer,1,3])),.T.,.F.),; //Indica se  Bloqueia  a medi'c~ao
				       1,;  // Posicao do Ensaio
				     .F.,;  // Indica Salva Ensaio
				     Nil,;  // Indica se Nao atualiza Medicao
				  lOPRap,;  // Chamado pela Operacao Rapida
				     Nil,;  // Indica se Nao atualiza Ensaio
				     Nil,;  // Indica se Atualiza os Leds
				  lOPMov)   // Indica a Movimentacao da OP

EndIf

cIP210L3 := IIf(!Empty(aResultados[nPosOpCar,_LLA,nPosLCar,3]),(lLauLab := .T., aResultados[nPosOpCar,_LLA,nPosLCar,3]),"")
cIP210L2 := IIf(!Empty(aResultados[nPosOpCar,_LOP,3]),(lLauOp := .T., aResultados[nPosOpCar,_LOP,3]),"")
cIP210L1 := IIf(!Empty(AllTrim(aResultados[nFldLauGer,1,3])),aResultados[nFldLauGer,1,3],"")
nPosLab  := nPosLCar 
nPosOper := nPosOpCar    
           	
If ValType(aObjGet[Eval(bGetoGet)]) == "O"
	SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
EndIf

lExecUpDown := .F.
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³a216CarEns³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 23/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega Ensaios                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a216CarEns( nPosLCar,  lZeraObj, oDlgMain,  lBloMed, nPosEnsN,;
					  lSavEns,  lNAtuMed,   lOPRap, lNAtuEns,  lAtuSel,;
					   lOPMov)
Local nX           := 1
Local nPosRevDoc   := 0
Local aHeadMed     := {}
Local aColsMed     := {}
Local cCartaAnt    := ""
Local cCampCal	   := GetMv("MV_QCEDTEC",.F.," ")   // Define quais campos aleM de Insrumento e NC do Ensaio calculado serão editados.
Local cMV_GETDADE  := GetMv("MV_GETDADE",.F.,"3")   // Parametro que define o tipo de edição da Get 1 = Em Linha / 2 = Célula e 3 = Ambos
Local lQP216J28	   := ExistBlock("QP216J28")

Default nPosLCar   := 1   
Default lZeraObj   := .F.
Default lBloMed	   := .F.
Default lSavEns    := .T.
Default lNAtuMed   := .F.
Default lNAtuEns   := .F.
Default lAtuSel    := .F.
Default lOPMov     := .F.

Private oDlgAux := oDlgMain

aSavHeadEns := aClone(aSavHeadEns)

If nPosEnsN <> Nil
	nPosEns    := nPosEnsN  
Else
	nPosEns := 1
EndIf

If  nPosLab <> nPosLCar  .AND. !lOPMov
	nPosLab    := nPosLCar             
EndIf

For nX := 1 To Len(aObjGet)
	If ValType(aObjGet[nX]) == "O"
		aObjGet[nX]:Hide()
	EndIf 
Next
	
//Q216ARESU()

nQtdMed  := Iif( aResultados[nPosOper,_ENS,nPosLab,nPosEns,CARTA] == 'NP ', 1, aResultados[nPosOper,_ENS,nPosLab,nPosEns,QTDMED] )
cCartEns := aResultados[nPosOper,_ENS,nPosLab,nPosEns,CARTA]	//Define a Carta para o ensaio posicionado

If  aResultados[nPosOper,_ENS,nPosLCar,nPosEns,ENSCALC] .AND. !lBloMed
	lBloMed  := .T. 
	lNAtuMed := .F.
EndIf

aAlter := {}

If !lBloMed .AND. (ALTERA .OR. INCLUI)
	If cCartEns == "TMP"
		Aadd(aAlter,"QPR_DTINI")
		Aadd(aAlter,"QPR_HRINI")
		Aadd(aAlter,"QPR_DTFIM")
		Aadd(aAlter,"QPR_HRFIM")
	ElseIf cCartEns == "TXT"
		Aadd(aAlter,"QPQ_MEDICA")
		Aadd(aAlter,"QPQ_RESULT")
	ElseiF cCartEns == "P  "
		Aadd(aAlter,"QPS_MEDIPA")
		Aadd(aAlter,"QPS_MEDIPN")
		Aadd(aAlter,"QPS_MEDIPP")
	Else
		Aadd(aAlter,"QPS_MEDICA")
	EndIf 
	Aadd(aAlter,"QPR_FILMAT")
	Aadd(aAlter,"QPR_ENSR")
	Aadd(aAlter,"QPR_ENSRNO")
	Aadd(aAlter,"QPR_DTMEDI")
	Aadd(aAlter,"QPR_HRMEDI")
	Aadd(aAlter,"QPR_AMOSTR")
EndIf
Aadd(aAlter,"QPR_ENTINS")
Aadd(aAlter,"QPR_ENTNC")

If lQPR_BOBINA
	Aadd(aAlter,"QPR_BOBINA")
EndIf

For nX:=1 to Len(aCpoUsu)   
	Aadd(aAlter,aCpoUsu[nX,1])
Next nX

If !lNAtuEns 	
	QP216AtuEns(oDlgMain, nPosOper, nPosLCar, nPosLab, nPosEns, lAtuSel, lOPMov)
EndIf

If !Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLCar,3]))
    cIP210L3 := aResultados[nPosOper,_LLA,nPosLCar,3]
    lLauLab  := .T.
	lBloMed  := .T.  
EndIf
If !Empty(AllTrim(aResultados[nPosOper,_LOP,3]))
	cIP210L2 := aResultados[nPosOper,_LOP,3]
	lLauOp   := .T.  
	lBloMed  := .T.
EndIf
If !Empty(AllTrim(aResultados[nFldLauGer,1,3]))
	cIP210L1 := aResultados[nFldLauGer,1,3]	  
	lLauLab  := .T.
	lLauOp   := .T.  
	lBloMed  := .T.
EndIf

If !lNAtuMed

	lLinOKMedi := .F.    

	If ValType(aObjGet[Eval(bGetoGet)]) == "O"
		aObjGet[Eval(bGetoGet)]:Hide()
		aObjGet[Eval(bGetoGet)]:oBrowse:lDisablePaint := .T.		
	EndIf 

	If lZeraObj // Zero todos os aCols para impedir que sejam replicados dados errados
		For  nX := 1 To Len(aObjGet)
			If Valtype(aObjGet[nX]) == "O"
				aObjGet[nX]:aCols := aClone(QP215ColsM(aObjGet[nX]:aHeader))
			EndIf
		Next
	EndIf
	
	aHeadMed := aClone(aSavHeadEns[nPosOper,nPosLCar,nPosEns,1])
	aColsMed := aClone(aResultados[nPosOper,_MED,nPosLCar,nPosEns])

	If lQP216J28
		aColsMed := aClone(ExecBlock("QP216J28",.f.,.f.,{aColsMed, nPosLCar}))
	EndIf
	
	aPodeAlt := {}
	aPodeAlt := aClone(aAlter) 
	
	// Blindagem do Sistema situação JJ  - Inicio
	If Valtype(aObjGet[Eval(bGetoGet)]) == "O"
		If Len(aObjGet[Eval(bGetoGet)]:aHeader) <> Len(aHeadMed) 
			FWLogMsg('WARN',, 'SIGAQIP', funName(), '', '01', OemToAnsi("Identificada inconsistencia aHeader já usado! Operação: "+aResultados[nPosOper,_OPE]+" Laboratório: "+aResultados[nPosOper,_LAB,nPosLCar]+" Ensaios: "+aResultados[nPosOper,3,nPosLCar,nPosEnsAnt,2]+"(Ant)/"+aResultados[nPosOper,3,nPosLCar,nPosEns,2]) , 0, 0, {})
		EndIf
	EndIf
	// Fim	
	
	If Valtype(aObjGet[Eval(bGetoGet)]) <> "O"
		aObjGet[Eval(bGetoGet)] := MsNewGetDados():New(81,110+Iif(lBarLat,nFatBar,0),(1.60*aPosObj[1,3]),aPosObj[1,4]-5,IIF(ALTERA .or. INCLUI,GD_INSERT+GD_UPDATE+GD_DELETE,0),"LinOkMedi","TudOkMedi","",,,999,,,,oDlgMain,aHeadMed,aColsMed)
		aObjGet[Eval(bGetoGet)]:oBrowse:bMove 			:= {|x| (aObjGet[Eval(bGetoGet)]:lNewLine := .F.,IIF(ALTERA .or. INCLUI,aObjGet[Eval(bGetoGet)]:lInsert := .T.,aObjGet[Eval(bGetoGet)]:lInsert := .F.),aObjGet[Eval(bGetoGet)]:LinhaOk(x))}  
		aObjGet[Eval(bGetoGet)]:oBrowse:bDrawSelect		:= {|| QP215ChgMed(nPosOper,nPosLCar,nPosEns,aObjGet[Eval(bGetoGet)]:nAT), Iif(ValType(aObjGet[Eval(bGetoGet)]) == "O",SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd),Nil)}
		aObjGet[Eval(bGetoGet)]:bChange 				:= {|| Iif(cIDFoco == "ID:Medicao" .OR. cIDFoco == "ID:Ensaios", ( Qip216Seq(), QP216RightMe(nPosOper,nPosLCar,nPosEns) ), Nil) }
		aObjGet[Eval(bGetoGet)]:oBrowse:bLostFocus 		:= {|| QP216LFoc() }	 //	aResultados[nPosOper,_MED, nPosLab, nPosEns] :=  aClone(aObjGet[Eval(bGetoGet)]:aCols),;
		aObjGet[Eval(bGetoGet)]:oBrowse:bGotFocus 		:= {|| QP216GFoc() }
		aObjGet[Eval(bGetoGet)]:oBrowse:bDelOK			:= {|| QP216DMed() } 
		// Não tirar utilizada para a atualização dos ensaios  calculados on-line
		aObjGet[Eval(bGetoGet)]:oBrowse:bSetGet     	:= {|| Q216ExecVa() } 
	    
	    If  cMV_GETDADE == "2"  
	    	aObjGet[Eval(bGetoGet)]:SetEditLine(.F.)    //Desabilita  a Edição em linha
	    ElseIf cMV_GETDADE == "1" 
			aObjGet[Eval(bGetoGet)]:SetEditLine(.T.)    //Habilita    a Edição em linha	    
		EndIf
	EndIf

	aObjGet[Eval(bGetoGet)]:oBrowse:lDisablePaint 	:= .T.		
	aObjGet[Eval(bGetoGet)]:Hide()                           
	aObjGet[Eval(bGetoGet)]:aAlter	:= aClone(aAlter)
	aObjGet[Eval(bGetoGet)]:aCols	:= aClone(aColsMed)

   	If !lBloMed .AND. (ALTERA .OR. INCLUI) 
		aObjGet[Eval(bGetoGet)]:lInsert := .T.
		aObjGet[Eval(bGetoGet)]:lDelete := .T.
		aObjGet[Eval(bGetoGet)]:lUpdate := .T.
	Else
		aObjGet[Eval(bGetoGet)]:lInsert := .F.
		aObjGet[Eval(bGetoGet)]:lDelete := .F.     
		aObjGet[Eval(bGetoGet)]:lUpdate := .T.
	EndIf
	
	aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
	aObjGet[Eval(bGetoGet)]:ForceRefresh()
	aObjGet[Eval(bGetoGet)]:oBrowse:lDisablePaint := .F.		
	aObjGet[Eval(bGetoGet)]:Show()                   
   	aObjGet[Eval(bGetoGet)]:Refresh()

	If Valtype(aObjGet[Eval(bGetoGet)]) == "O"
		nPosMetodo 					:= Ascan(aObjGet[Eval(bGetoGet)]:aHeader,{|x|AllTrim(x[2])=="QPR_METODO"})
		nPosRevDoc 					:= Ascan(aObjGet[Eval(bGetoGet)]:aHeader,{|x|AllTrim(x[2])=="QPR_RVDOC"}) 
		For nX := 1 To Len(aObjGet[Eval(bGetoGet)]:aCols)
			aObjGet[Eval(bGetoGet)]:aCols[nX,nPosMetodo] := aResultados[nPosOper,_ENS,nPosLCar,nPosEns,METODO]
			aObjGet[Eval(bGetoGet)]:aCols[nX,nPosRevDoc] := aResultados[nPosOper,_ENS,nPosLCar,nPosEns,REVDOC]	
		Next
		SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
		Qip216Seq()
	    If aResultados[nPosOper,_ENS,nPosLCar,nPosEns,ENSCALC]
			aObjGet[Eval(bGetoGet)]:lInsert := .F.
			aObjGet[Eval(bGetoGet)]:lDelete := .F.
		Else
			aObjGet[Eval(bGetoGet)]:lInsert := .T.
			aObjGet[Eval(bGetoGet)]:lDelete := .T.     
	    EndIf
		If aObjGet[Eval(bGetoGet)]:nAt > Len(aObjGet[Eval(bGetoGet)]:aCols)
			aObjGet[Eval(bGetoGet)]:nAt := 1 
			aObjGet[Eval(bGetoGet)]:Refresh()
		EndIf	
		aObjGet[Eval(bGetoGet)]:Show()
		aObjGet[Eval(bGetoGet)]:oBrowse:Show()
		aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()  
		aObjGet[Eval(bGetoGet)]:Show()
	EndIf
EndIf

Qip216Ens(oDlgMain)
oEnsNew:SetText( aResultados[nPosOper,_ENS,nPosLCar,nPosEns,ENSAIO]+"-"+QIPXDeEn(aResultados[nPosOper,_ENS,nPosLCar,nPosEns,ENSAIO]) )
QP216RightMe()
oBrwJJ:cTitle := "ID:Ensaios"

if lFirst  					// forço a primeira entrada para acionar ponto de entrada QP215J12 e impedir alteração no primeiro ensaio
	If Existblock ("QP215J12")
	   QP216VDbl(.T.) 
	EndIf 
	lfirst:= .F.
EndiF

lLinOKMedi := .T.
// Avalia o aCols com os  ensaios
If ExistBlock('QLOGMOV') .AND. !lLayout
	lIncon := .F.
	If hok:CNAME == oBrwJJ:AARRAY[nPosEns][3]:CNAME
	    For nX := 1 To Len(aObjGet[Eval(bGetoGet)]:aCols)
    	   If Empty(aObjGet[Eval(bGetoGet)]:aCols[nX][6]) .OR.;
    	      ( !Empty(aObjGet[Eval(bGetoGet)]:aCols[nX][6]) .AND.;
    	        Empty(aResultados[nPosOper,_INS,nPosLCar,nPosEns][1][1][1]) )
    	   		lIncon := .T.
    	   		Exit
    	   EndIf
	    Next 
	EndIf
	If lIncon
		QGRVLGQIP(1 , Nil) //Grava Log de Inconsistencias e envia.
	EndIf
EndIf  

Return .T. 
                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LinOkNC	³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 27/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Critica se a linha digitada esta' Ok - Getdados NConformid.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LinOkNC( o, y )
Local lRet		:= .T.
Local nPosNc	:= ascan(oGetNc:aHeader, { |x| alltrim(x[2]) == 'QPU_NAOCON'	})
Local nPosNumnc	:= ascan(oGetNc:aHeader, { |x| alltrim(x[2]) == 'QPU_NUMNC'		})
Local nI        := 0
Local cVar      := ""

Default y := oGetNc:nAt

If !(oGetNc:aCols[y,Len(oGetNc:aCols[y])])	// Se nao estiver deletado
	If Empty(oGetNc:aCols[y,nPosNC])
	    MsgAlert(STR0111) //"Informe o código da Não Conformidade!"
		lRet := .F.
	EndIf                           
	If lRet .AND. oGetNc:aCols[y,nPosNumnc] == 0
		MsgAlert(STR0112) //"Informe o numero de não conformidades!" 
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a NC ja' existe ³     
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet                         
		cVar := oGetNc:aCols[y][nPosNC]
		For nI := 1 to Len(oGetNc:aCols)
			If !oGetNc:aCols[nI][Len(oGetNc:aCols[y])] .AND. cVar == oGetNc:aCols[nI][nPosNC] .AND. nI <> y // Se ja' existir este cod. NC
				Help(" ",1,"QPH215056") //Não conformidade já associada a medição.
				lRet := .F.
			EndIf
		Next nI
	EndIf
EndIf            
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³TudOkNC	³ Autor ³ Marcelo Pimentel      ³ Data ³ 27/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Critica se toda a getdados esta' Ok - Getdados N.Conformid.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TudOkNC()
Local nI 		:= 1
Local lRet	  	:= .T.
Local lQP216J18 := ExistBlock("QP216J18")
Local nPosChec	:= oBrwJJ:nAt
Local nDel 		:= 0
Local cResul	:= ''
Local nAmo		:= 0
Local nPosRes   := 0
//cCartEns  := aResultados[nPosOper,_ENS,nPosLab,nPosEns,CARTA]

If cCartEns == "TXT"
   nPosRes := Ascan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| alltrim(x[2]) == Alltrim("QPQ_RESULT") })  
Else
   nPosRes := Ascan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| alltrim(x[2]) == Alltrim("QPR_RESULT") })  
EndIF  

For nI := 1 to Len(oGetNc:aCols)
	If !LinOkNC( Nil, nI )
		lRet := .F.
		Exit
	EndIf
Next nI

If lRet .And. nPosChec <> 0
	nDel			:= Len(aObjGet[Eval(bGetoGet)]:aHeader)+1 // numero de colunas
	If lQP216J18
		cResul	:= aResultados[nPosOper,_MED, nPosLab, oBrwJJ:nAt, aObjGet[Eval(bGetoGet)]:nAT, nPosRes]
		nAmo	:= ascan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| alltrim(x[2]) == 'QPR_AMOSTR' })
		
		lRet := ExecBlock("QP216J18",.f.,.f.,{cResul, aResultados[nPosOper, _ENS, nPosLab],cDescLab,cOper,cIP210OP,oGetNc:aCols,aResultados[nPosOper,_MED, nPosLab, oBrwJJ:nAt, aObjGet[Eval(bGetoGet)]:nAT, nAmo]})
	EndIf
EndIf

oGetNc:oBrowse:Refresh()

Return lRet     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LinOkIn	³ Autor ³ Marcelo Pimentel      ³ Data ³ 27/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Critica se a linha digitada esta' Ok - Getdados Instrumento³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LinOkIN(o, y)
Local lRet	:= .T.
Local nAcPosIns := ascan(oGetINS:aHeader, { |x| alltrim(x[2]) == 'QPT_INSTR' })

Default y := oGetINS:nAT
 
If !(oGetINS:aCols[y,Len(oGetINS:aCols[y])])	// Se nao estiver deletado
	If Empty(oGetINS:aCols[y,nAcPosIns])
		MsgAlert(STR0113) //"Informe o código do Instrumento!"
		lRet := .F.
	EndIf
EndIf

Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³TudOkIN	³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 27/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Critica se toda a getdados esta' Ok - Getdados Instrumentos³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TudOkIN()
Local nI 		:= 1
Local lRet	  := .T.

For nI := 1 to Len(oGetINS:aCols)
	If !LinOkIN( Nil, nI )
		lRet := .F.
		Exit
	EndIf
Next nI

oGetINS:oBrowse:Refresh()

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QipLaudGer³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 25/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Tela de Laudo Laboratorio do Resultados					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QipLaudGer(nOpcX, lCancela)
Local aButtons  := {}
Local lQP216BLG :=	ExistBlock("QP216BLG")
Local aResAnt   := aClone(aResultados[nFldLauGer,1])
Local nOpca		:= 0 
Local cOperRes  := aResultados[nPosOper,_OPE]
//Local oGetLGer
Local oDlgLG    
Local lOKMedBkp := lLinOKMedi  // Salvo a situação da variavel

Default lCancela := .F.

If !lLiberaUrg .AND. !lLauOP .AND. Empty(Alltrim(aResultados[nPosOper,_LOP,3]))
	Help(" ",1,"QPH215012")  //Existem operacoes sem laudo, favor verificar antes do laudo geral.
	Return Nil 
EndIf                   

If !lTeLAbr
	lTeLAbr := .T.
	Return Nil
EndIf

If lModNav .AND. nPosEnsAnt <> oBrwJJ:nAt .AND. ALTERA
	MsgAlert(STR0114) //"O sistema não pode incluir/alterar o Laudo pois o ensaio esta desposicionado! Reposicione o ensaio através do Duplo click, para que seja possivel incluir/alterar o Laudo!"
	Return Nil
EndIf

lLinOKMedi := .F.

If lCarOtm
	// Inicio - Posicionar no primeiro ensaio
	If nPosEns <> 1
		nPosEnsAnt := nPosEns
	    nPosEns := 1
		QP215ChgEns(nPosOper, nPosLab, nPosEnsAnt, nPosEns, .T., .F.)
		If ValType(aObjGet[Eval(bGetoGet)]) == "O"
			SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
		EndIf

		QP216AtuEns(oBrwJJ:oWnd, nPosOper, nPosLab, nPosLab, nPosEns, .F.)
		aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
		aObjGet[Eval(bGetoGet)]:ForceRefresh()
    EndIf
	// Final 	
	Q216CALL()
	nPosOper := Ascan(aResultados,{|x|x[_OPE] == cOperRes})
	nPosLab  := Ascan(aResultados[nPosOper,_LAB], { |x| AllTrim(x) == AllTrim(cDescLab) } )
	nPosEns  := oBrwJJ:nAt
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para adicionar botões na tela do Laudo  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQP216BLG
	aButtons := ExecBlock("QP216BLG",.f.,.f.)
EndIf

Q216LAUDS(3)            

nFldOpe := 3

DEFINE MSDIALOG oDlgLG FROM 7  ,6   TO 285,660 TITLE STR0081 Of oMainWnd PIXEL		//'Laudo - Geral'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os vetores das Enchoices do Laudo Geral       		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel := TPanel():New(0,0,'',oDlgLG,, .T., .T.,, ,130,130,.F.,.F.)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT
RegToMemory("QPL") 
oGetLGer := MsMGet():New("QPL",nRegLLG,nOpcX,,,,,{0,0,108,326},aCpoEnc[1],3,,,,oPanel,,.T.,,,,,,.T.)
Aeval(oGetLGer:aGets,{|x,y| M->&(Left(Substr(oGetLGer:aGets[y],9),10)) := aResultados[nFldLauGer,1,y]})
If lLiberaUrg                                                     
	Iif(Empty(AllTrim(M->QPL_HRLAUD)), M->QPL_HRLAUD := Time(),) 
	Iif(Empty(AllTrim(M->QPL_DTLAUD)), M->QPL_DTLAUD := dDataBase,)
	Iif(Empty(AllTrim(M->QPL_DTENLA)), M->QPL_DTENLA := dDataBase,)
	Iif(Empty(AllTrim(M->QPL_HRENLA)), M->QPL_HRENLA := Time(),)  
	Iif(Empty(AllTrim(M->QPL_TAMLOT)), Padr(Alltrim(Str(QPK->QPK_TAMLOT)),TamSx3("QPL_TAMLOT")[1]),)
	Iif(Empty(AllTrim(M->QPL_DTVAL)) , M->QPL_DTVAL := dDataBase + QAtuShelf(QPK->QPK_PRODUT,QPK->QPK_REVI),)
	Iif(Empty(AllTrim(M->QPL_LAUDO)) , M->QPL_LAUDO := "U",)
	Iif(Empty(AllTrim(M->QPL_DESLAU)), M->QPL_DESLAU := Posicione("QED",1,xFilial("QED")+M->QPL_LAUDO,"QED_DESCPO"),)
Else
	Iif(Empty(AllTrim(M->QPL_DTENLA)), M->QPL_DTENLA := dDataBase,)
	Iif(Empty(AllTrim(M->QPL_HRENLA)), M->QPL_HRENLA := Time(),)  
	Iif(Empty(AllTrim(M->QPL_TAMLOT)), Padr(Alltrim(Str(QPK->QPK_TAMLOT)),TamSx3("QPL_TAMLOT")[1]),)
EndIf
If Len(aSavGets) == 0	
   	aSavGets := {{{},{}}}
   	aSavGets[1,2] := aClone(oGetLGer:aGets)
EndIf
oGetLGer:Refresh()

ACTIVATE MSDIALOG oDlgLG  CENTERED ON INIT EnchoiceBar(oDlgLG, {|| QP216LGOK(@oGetLGer, @aResAnt, @oDlgLG, @nOpca, @lCancela)}, {|| QP216LGCan(@oGetLGer, @aResAnt, @oDlgLG, @nOpca, @lCancela)},,aButtons) VALID Q216FCHGER(aResAnt, nOpca, @lCancela)
If nOpca == 2
	QP215SavResu({SAV_LAUG})
	If !Empty(AllTrim(aResultados[nFldLauGer,1,3]))
		lLauGer := .T.      
	Else
		lLauGer := .F.        
		If Empty(Alltrim(aResultados[nPosOper,_LOP,3]))
			lLauOP	:= .F.      
		EndIf
	   	If Empty(Alltrim(aResultados[nPosOper,_LLA,nPosLab,3]))
	   		lLauLab := .F.
	   	EndIf
	EndIf
Else
	If !Empty(AllTrim(M->QPL_LAUDO))
		lLauGer := .T.      
	Else
		lLauGer := .F.
		If Empty(Alltrim(aResultados[nPosOper,_LOP,3]))
			lLauOP	:= .F.      
		Else
			lLauOP	:= .T.      			
		EndIf
	   	If Empty(Alltrim(aResultados[nPosOper,_LLA,nPosLab,3]))
	   		lLauLab := .F.
	   	Else
		   	lLauLab := .T.
	   	EndIf
	EndIf
EndIf

cIP210L3 := IIf(!Empty(Alltrim(aResultados[nPosOper,_LLA,nPosLab,3])),aResultados[nPosOper,_LLA,nPosLab,3],"")
cIP210L2 := IIf(!Empty(Alltrim(aResultados[nPosOper,_LOP,3])),aResultados[nPosOper,_LOP,3],"")
cIP210L1 := IIf(!Empty(Alltrim(M->QPL_LAUDO)),M->QPL_LAUDO,"")

lTelAbr := .F.

If ValType(aObjGet[Eval(bGetoGet)]) == "O"
	SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
EndIf

lLinOKMedi := lOKMedBkp

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIPA216   ºAutor  ³Cicero Cruz         º Data ³  04/30/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ OK da  Tela do Laudo Geral                                 º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP216LGOK(oGetLGera, aResAnt, oDlg, nOpca, lCancela)

Aeval(oGetLGera:aGets,{|x,y|aResultados[nFldLauGer,1,y] := M->&(Left(Substr(oGetLGera:aGets[y],9),10))})
If Empty(AllTrim(M->QPL_LAUDO))
	M->QPL_JUSTLA := Space(TamSX3("QPL_JUSTLA")[1])
EndIf
If QP215VLDJUS("L")
	nOpca := 2
	oDlg:End()
	aResultados[nFldLauGer,1] := aClone(aResAnt)
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIPA216   ºAutor  ³Cicero Cruz         º Data ³  04/30/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ OK da  Tela do Laudo Geral                                 º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP216LGCan(oGetLGera, aResAnt, oDlg, nOpca, nOpca, lCancela)

aResultados[nFldLauGer,1] := aClone(aResAnt)
aEval(oGetLGera:aGets,{|x,y|M->&(Left(Substr(oGetLGera:aGets[y],9),10)) := aResultados[nFldLauGer,1,y]})
nOpca := 1
lCancela := .T.
oDlg:End()
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QipLauOp  ³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 25/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Tela de Laudo Operação dos Laboratórios					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QipLauOp(nOpcX)
Local aButtons  := {}
Local lQP216BLO :=	ExistBlock("QP216BLO")
Local aResAnt := aClone(aResultados[nPosOper,_LOP])
Local lOKMedBkp := lLinOKMedi  // Salvo a situação da variavel

If !lLauLab .AND. Empty(Alltrim(aResultados[nPosOper,_LOP,3]))
	Help(" ",1,"QPH215062",," "+Alltrim(aResultados[nPosOper,_LAB,nPosLab]),3,1)
	Return Nil
EndIf             

If lModNav .AND. nPosEnsAnt <> oBrwJJ:nAt .AND. ALTERA
	MsgAlert(STR0114) //"O sistema não pode incluir/alterar o Laudo pois o ensaio esta desposicionado! Reposicione o ensaio através do Duplo click, para que seja possivel incluir/alterar o Laudo!"
	Return Nil
EndIf

lLinOKMedi := .F.
lModLauO  := .F.

Q216LAUDS(2)            

nFldOpe := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para adicionar botões na tela do Laudo  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQP216BLO
	aButtons := ExecBlock("QP216BLO",.f.,.f.)
EndIf

DEFINE MSDIALOG oDlg FROM 7  ,6   TO 285,660 TITLE STR0082 Of oMainWnd PIXEL		//'Laudo - Laboratório'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os vetores das Enchoices do Laudo Geral       		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,130,130,.F.,.F.)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT
RegToMemory("QPM") 
oGetLauOpe := MsMGet():New("QPM",nRegLLO,nOpcX,,,,,{0,0,108,326},aCpoEnc[1],3,,,,oPanel,,.T.,,,,,,.T.)
Aeval(oGetLauOpe:aGets,{|x,y| M->&(Left(Substr(oGetLauOpe:aGets[y],9),10)):= aResultados[nPosOper,_LOP,y]})
//P.E. criado para a JNJ com o objetivo de alterar a quantidade da O.P. por Operacao
Iif(Empty(AllTrim(M->QPM_DTENLA)), M->QPM_DTENLA := dDataBase	,)
Iif(Empty(AllTrim(M->QPM_HRENLA)), M->QPM_HRENLA := Time()   	,) 
Iif(Empty(AllTrim(M->QPM_TAMLOT)), M->QPM_TAMLOT := cQLote  	,)
Iif(Empty(AllTrim(M->QPM_QTREJ )), M->QPM_QTREJ  := cQLotR		,)
If ExistBlock("QP216TLO") 
    M->QPM_TAMLOT := ExecBlock("QP216TLO",.F.,.F.,{M->QPM_TAMLOT,QPK->QPK_OP,cOper,aResultados,nOpcX})
EndIf

cLauAnt := M->QPM_LAUDO

If !Empty(AllTrim(aResultados[nFldLauGer,1,3]))
	oGetLauOpe:Disable()
EndIf

If Len(aSavGets) == 0	
	aSavGets := {{{},{}}}
EndIf
aSavGets[1,1] := aClone(oGetLauOpe:aGets)

oGetLauOpe:Refresh()

ACTIVATE MSDIALOG oDlg  CENTERED ON INIT EnchoiceBar(oDlg,{|| (	Aeval(oGetLauOpe:aGets,{|x,y|aResultados[nPosOper,_LOP,y] := M->&(Left(Substr(oGetLauOpe:aGets[y],9),10))}),;
															    Iif(Empty(AllTrim(M->QPM_LAUDO)), M->QPM_JUSTLA := Space(TamSX3("QPM_JUSTLA")[1]) ,),;
															    Iif(QP215VLDJUS("O"),(nOpca := 2, oDlg:End()), aResultados[nPosOper,_LOP] := aClone(aResAnt)))},;
															    {|| aResultados[nPosOper,_LOP] := aClone(aResAnt),;
															     Aeval(oGetLauOpe:aGets,{|x,y| M->&(Left(Substr(oGetLauOpe:aGets[y],9),10)) := aResultados[nPosOper,_LOP,y]}),;
															     nOpca := 1,oDlg:End()},,aButtons)

If nOpca == 2 .AND. Empty(AllTrim(aResultados[nFldLauGer,1,3]))
	Aeval(oGetLauOpe:aGets,{|x,y|aResultados[nPosOper,_LOP,y] := M->&(Left(Substr(oGetLauOpe:aGets[y],9),10))})
EndIf
If !lLauOP .AND. !Empty(AllTrim(M->QPM_LAUDO))
	lLauOp := .T.      
ElseIf Empty(AllTrim(aResultados[nFldLauGer,1,3]))
	lLauOp := .F.
EndIf

cIP210L3 := IIf(!Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLab,3])), aResultados[nPosOper,_LLA,nPosLab,3], "")
cIP210L2 := IIf(!Empty(aResultados[nPosOper,_LOP,3]),aResultados[nPosOper,_LOP,3],"")
cIP210L1 := IIf(!Empty(AllTrim(aResultados[nFldLauGer,1,3])), aResultados[nFldLauGer,1,3], "")

If ValType(aObjGet[Eval(bGetoGet)]) == "O"
	SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
EndIf

lLinOKMedi := lOKMedBkp

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QipLauLab ³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 25/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Tela de Laudo Laboratorio do Resultados					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QipLauLab(nOpcX, lExibe, oDlgAux)
Local aButtons   := {}
Local lQP216BLL  :=	ExistBlock("QP216BLL")
Local nOpca      := 0
//Variaveis utilizadas para iniciar campos no Laudo do Laboratorio
Local nPosLaudo  := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QPL_LAUDO"})
Local nPosDtEnLa := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QPL_DTENLA"})
Local nPosHrEnLa := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QPL_HRENLA"})
Local nPosTamLot := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QPL_TAMLOT"}) 
Local nPosDtaLau := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QPL_DTLAUD"})
Local nPosValLau := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QPL_DTVAL"}) 
Local aResAnt    := aClone(aResultados[nPosOper,_LLA,nPosLab])
Local lOKMedBkp  := lLinOKMedi  // Salvo a situação da variavel
Local cLaudA     := ""

Default lExibe := .T.

Private oDlgJJ := oDlgAux

If ValType(aObjGet[Eval(bGetoGet)]) == "U"  
	lTeLAbr := .T.
	Return Nil
EndIf

If lExibe .AND. lModNav .AND. nPosEnsAnt <> oBrwJJ:nAt .AND. ALTERA
	MsgAlert(STR0114) //"O sistema não pode incluir/alterar o Laudo pois o ensaio esta desposicionado! Reposicione o ensaio através do Duplo click, para que seja possivel incluir/alterar o Laudo!"
	Return Nil
EndIf

lLinOKMedi := .F.  
lModLau    := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para adicionar botões na tela do Laudo  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQP216BLL
	aButtons := ExecBlock("QP216BLL",.f.,.f.)
EndIf

Q216LAUDS(1)            

nFldOpe := 2
  
If lExibe .and. !lValEns                 
	If ValType(aObjGet[Eval(bGetoGet)]) == "O" 
		aResultados[nPosOper,_MED, nPosLab, oBrwJJ:nAt] :=  aClone(aObjGet[Eval(bGetoGet)]:aCols)
			QP215CALMD()
			QP216AtuEns(oBrwJJ:oWnd, nPosOper, nPosLab, nPosLab, nPosEns, Nil, Nil, Nil)
	Endif
EndIf
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para adicionar botões na tela do Laudo  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQP216BLL
	aButtons := ExecBlock("QP216BLL",.f.,.f.)
EndIf

DEFINE MSDIALOG oDlg FROM 7 , 6  TO 285,660 TITLE STR0083 OF oMainWnd PIXEL		//'Laudo - Laboratório'
	
If !lExibe
	oDlg:Hide()
	oDlg:LSHOWHINT	:= .F.
	oDlg:LACTIVE 	:= .F.
	oDlg:NRIGHT		:= 500
	oDlg:NLEFT		:= 500
	oDlg:NTOP		:= 500
	oDlg:NWIDTH		:= 0
	oDlg:NHEIGHT	:= 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os vetores das Enchoices do Laudo Geral       		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,100,100,.F.,.F.)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT
RegToMemory("QPL")
oGetLaudo := MsMGet():New("QPL",nRegLLA,nOpcX,,,,,{0,0,108,326},aCpoEnc[1],3,,,,oPanel,,.T.,,,,,,.T.)
oGetLaudo:Hide()
oDlg:Hide()
Aeval(oGetLaudo:aGets,{|x,y| M->&(Left(Substr(oGetLaudo:aGets[y],9),10)) := aResultados[nPosOper,_LLA,nPosLab,y]})
If Len(aSavGets) == 0	
  	aSavGets := {{{},{}}}
   	aSavGets[1,2] := aClone(oGetLaudo:aGets)
EndIf

If lExibe
	oGetLaudo:Show()
	oGetLaudo:Refresh()
	oDlg:Show()
	If !Empty(aResultados[nPosOper,_LOP,3]) .OR. !Empty(AllTrim(aResultados[nFldLauGer,1,3]))
		oGetLaudo:Disable()
	EndIf  
	cLauAnt := aResultados[nPosOper,_LLA,nPosLab,nPosLaudo]  // Variavel utilizada para verificar o Laudo
	cLaudA  := aResultados[nPosOper,_LLA,nPosLab,nPosLaudo]  // variavel local que  indica a mudança
	ACTIVATE MSDIALOG oDlg  CENTERED ON INIT EnchoiceBar(oDlg,{|| (	Aeval(oGetLaudo:aGets,{|x,y|aResultados[nPosOper,_LLA,nPosLab,y] := M->&(Left(Substr(oGetLaudo:aGets[y],9),10))}),;
 																					   Iif(Empty(AllTrim(M->QPL_LAUDO)),;
																    						M->QPL_JUSTLA := Space(TamSX3("QPL_JUSTLA")[1]) ,),;
						                                                               Iif( QP215VLDJUS("L", cLaudA),;
						                                                                	(nOpca := 2, oDlg:End()),; 
	                                                                						aResultados[nPosOper,_LLA,nPosLab] := aClone(aResAnt)))},;
	                                                                {|| aResultados[nPosOper,_LLA,nPosLab] := aClone(aResAnt),;
	                                                                    Aeval(oGetLaudo:aGets,{|x,y| M->&(Left(Substr(oGetLaudo:aGets[y],9),10)) := aResultados[nPosOper,_LLA,nPosLab,y]}),;
	                                                                    nOpca := 1,;
	                                                                    oDlg:End()},,aButtons) VALID Q216FCHLAB(aResAnt, nOpca)
Else
	oGetLaudo:Refresh()
	ACTIVATE MSDIALOG oDlg NOCENTER ON INIT QP216FECHA(oDlg)
	lLinOKMedi := lOKMedBkp
	Return
EndIf    

If nOpca == 2 .AND. (Empty(AllTrim(aResultados[nFldLauGer,1,3])) .AND. Empty(aResultados[nPosOper,_LOP,3]))
	Aeval(oGetLaudo:aGets,{|x,y|aResultados[nPosOper,_LLA,nPosLab,y] := M->&(Left(Substr(oGetLaudo:aGets[y],9),10))})
	If !Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLab,3]))
		lLauLab := .T.      
	ElseIf Empty(AllTrim(aResultados[nFldLauGer,1,3])) .AND. Empty(aResultados[nPosOper,_LOP,3])
		lLauLab := .F.
	EndIf
	a216CarEns(nPosLab,     .T., oBrwJJ:oWnd, lLauLab, oBrwJJ:nAt,      .F.,      Nil )
	If ValType(aObjGet[Eval(bGetoGet)]) == "O"
		SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
	EndIf

Else
	If !Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLab,3]))
		lLauLab := .T.      
	ElseIf Empty(AllTrim(aResultados[nFldLauGer,1,3])) .AND. Empty(aResultados[nPosOper,_LOP,3])
		lLauLab := .F.
	EndIf 
	a216CarEns(nPosLab,     .T., oBrwJJ:oWnd, lLauLab, oBrwJJ:nAt,      .F.,      Nil )
	If ValType(aObjGet[Eval(bGetoGet)]) == "O"
		SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
	EndIf

EndIf

If lLauLab
	cHrLaud  := M->QPL_HRLAUD 
	dDtLaud  := M->QPL_DTLAUD
	dDtEnLa  := M->QPL_DTENLA
	cHrEnLa  := M->QPL_HRENLA
	cLaudo   := M->QPL_LAUDO 
	cQLote   := M->QPL_TAMLOT
	cQLotR   := M->QPL_QTREJ	
EndIf

cIP210L3 := IIf(!Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLab,3])), aResultados[nPosOper,_LLA,nPosLab,3], "")
cIP210L2 := IIf(!Empty(aResultados[nPosOper,_LOP,3]),aResultados[nPosOper,_LOP,3],"")
cIP210L1 := IIf(!Empty(AllTrim(aResultados[nFldLauGer,1,3])),aResultados[nFldLauGer,1,3],"")

lLinOKMedi := lOKMedBkp
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q216LAUDS ºAutor  ³Microsiga           º Data ³  10/25/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Layout 2                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q216LAUDS(nOptLab)

Local aStruQPL := FWFormStruct(3, "QPL")[3]
Local aStruQPM := FWFormStruct(3, "QPM")[3]
Local nX  

If nOptLab == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o vetor com os campos a serem utilizados na Enchoice LAB³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aStruQPL)
		If cNivel >= GetSx3Cache(aStruQPL[nX,1], "X3_NIVEL") 
			Aadd(aCpoEnc[1],aStruQPL[nX,1])//X3_CAMPO
			Aadd(aCpoEnc[2],GetSx3Cache(aStruQPL[nX,1], "X3_CONTEXT"))
		EndIf
	Next nX
ElseIf nOptLab == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o vetor com os campos a serem utilizados na Enchoice OPE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aStruQPM)
		If cNivel >= GetSx3Cache(aStruQPM[nX,1], "X3_NIVEL") 
			Aadd(aCpoEnc[1],aStruQPM[nX,1])//X3_CAMPO
			Aadd(aCpoEnc[2],GetSx3Cache(aStruQPM[nX,1], "X3_CONTEXT"))
		EndIf
	Next nX
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A210QFinal³ Autor ³Marcelo Pimentel       ³ Data ³ 11/1/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Finaliza o programa com gravacao ou nao dos Dados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 - .T. = Gravar e .F. Nao gravar                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³A210IRes                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A216QFinal(oDlgMain, nOpc, nOpcA)
Local lRet := .T.

If nOpc <> 2 .AND. nOpc <> 4 
	If qp216lDel(cIP210OP, nOpc, nOpcA)    
	
		If !qpAviso('',STR0084,{STR0085,STR0086}) == 1		// "Confirma saida?"###"Sim"###"Não"
	
			lRet := .F.
	
		EndIf
	Else
		lRet := .F.
	EndIf
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³qp216lDel   ³ Autor ³Marcelo Pimentel       ³ Data ³ 10/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Chamada do ponto de entrada no botao cancela                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Cadastro de Resultados								        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function qp216lDel(nOrdOp, nOpc, nOpcA)
Local lRet := .T.

If nOpcA > 0
	If ValType(aObjGet[Eval(bGetoGet)]) == "O"
		aObjGet[Eval(bGetoGet)]:oBrowse:GoUp() 
		lRet := lRetLOK
		If !lRet
			SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
		EndIf		
	EndIf	
EndIf                    

If lQP216Del .AND. lRet .AND. nOpcA == 0 
	lRet := ExecBlock("QP216DEL",.f.,.f.,{nOrdOp,nOpc})
EndIf    

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QP215RightMe³Autor³Cleber Cousa           ³ Data ³23/08/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Posiciona o foco na coluna da medição conforme parametro	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q215EditaMed()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPN1 = Posicao atual da Operacao   					      ³±±
±±³          ³ EXPN2 = Posicao atual do Laboratorio	                      ³±±
±±³          ³ EXPN2 = Posicao atual do Ensaio   	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIPA215													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QP216RightMe(nOpe,nLab,nEns)

Local nRight  := GetMv("MV_QPPOSFO",.F.,5)
Local nPosRes := 0

If ValType(aObjGet[Eval(bGetoGet)]) == "O"
	nPosRes   := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == 'QPR_RESULT' })
	If nPosRes == 0                                            
		nPosRes   := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == 'QPQ_RESULT' })
	EndIf
	// Quando  resultado estiver  preenchido não deve  efetuar o reposicionamento - Regra JJ
	If lLinOKMedi .AND. nPosRes > 0 .AND. Empty(AllTrim(aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nAt][nPosRes]))
		aObjGet[Eval(bGetoGet)]:oBrowse:lDisablePaint := .T. 
		aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
		//Posiciona na primeira coluna
		aObjGet[Eval(bGetoGet)]:oBrowse:nColPos:=nRight+1
		aObjGet[Eval(bGetoGet)]:oBrowse:lDisablePaint := .F.
		aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
	EndIf
EndIf
		
Return() 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Qip220Seq   ³ Autor ³Marcelo Pimentel       ³ Data ³ 18/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica a sequencia das medicoes                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Cadastro de Resultados								        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qip216Seq()
Local nC		:= 0
Local nCount1	:= 0

For nC := 1 To Len(aObjGet[Eval(bGetoGet)]:aCols)
	If !aObjGet[Eval(bGetoGet)]:aCols[nC,Len(aObjGet[Eval(bGetoGet)]:aCols[nC])]
		nCount1++
	EndIf
Next nC
cTexto3 := STR0087+ StrZero(aObjGet[Eval(bGetoGet)]:nAt,3)+ "/" + StrZero(nCount1,3) //"Seq. : "
oSay5:SetText(cTexto3)
oSay5:Refresh()
Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Qip216Ens   ³ Autor ³Cicero Odilio Cruz     ³ Data ³ 18/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os dados dos Ensaios                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Cadastro de Resultados								        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qip216Ens(oDlgMain)
Local cFormula 	:= ''
Local cFormula1	:= ''
Local cFormula2	:= ''
Local cTexto0 := ''
Local cTexto1 := ''
Local cTexto2 := ''
Local cEnsaio	:= aResultados[nPosOper,_ENS,nPosLab,oBrwJJ:nAt,ENSAIO]
Local cOperacao := aResultados[nPosOper,_OPE]
Local cRoteiro  := Iif(Empty(SC2->C2_ROTEIRO),"01",SC2->C2_ROTEIRO)
Local cRevi	    := Iif(Empty(SC2->C2_REVI),QA_UltRvQ(SC2->C2_PRODUTO),SC2->C2_REVI)

//cCartEns	:= aResultados[nPosOper,_ENS,nPosLab,oBrwJJ:nAt,CARTA]

If cCartEns <> "TXT"
	QP7->(dbSetOrder(1))
	If QP7->(dbSeek(xFilial("QP7")+SC2->C2_PRODUTO+cRevi+cRoteiro+cOperacao+cEnsaio))
		If QP7->QP7_MINMAX == "1"  // Controla Min e Max
			cTexto0 := Alltrim(QP7->QP7_LIE) + " / " +Alltrim(QP7->QP7_NOMINA) + " / " + ;
			Alltrim(QP7->QP7_LSE) + "  " +Qa_DesUM(QP7->QP7_UNIMED,.T.,1)
		Elseif QP7->QP7_MINMAX == "2" // Controla Min
			cTexto0 := Alltrim(QP7->QP7_LIE) + " / " + Alltrim(QP7->QP7_NOMINA) + " / >>>" +;
			"  " +Qa_DesUM(QP7->QP7_UNIMED,.T.,1)
		Elseif QP7->QP7_MINMAX == "3" // Controla Max
			cTexto0 := "<<< / " +	Alltrim(QP7->QP7_NOMINA) + " / " + Alltrim(QP7->QP7_LSE)+ ;
			"  " + Qa_DesUM(QP7->QP7_UNIMED,.T.,1)
		EndIf
	Endif
	If aResultados[nPosOper,_ENS,nPosLab,oBrwJJ:nAt,ENSCALC]
		cFormula  := StrTran(aResultados[nPosOper,_ENS,nPosLab,oBrwJJ:nAt,FORMUL],"#","")
		cFormula1 := STR0088+" : "+Subs(cFormula,1,50)	//"Ensaio Calculado : "
		cFormula2 := Subs(cFormula,51,200)
	Else
		cFormula		:= ''
		cFormula1		:= ''
		cFormula2		:= ''
	EndIf

	cTexto1 := ''
	cTexto2 := STR0089+": "+cTexto0 //"L.I.E. / Nominal / L.S.E.: "

Else
	QP8->(dbSetOrder(1))
	If QP8->(dbSeek(xFilial("QP8")+SC2->C2_PRODUTO+cRevi+cRoteiro+cOperacao+cEnsaio))
		cTexto0 := Alltrim(QP8->QP8_TEXTO)
	EndIf
	cFormula	:= ''
	cFormula1	:= ''
	cFormula2	:= ''
	cTexto2		:= ''
	cTexto1		:= STR0090+cTexto0  //"Texto:"
EndIf

oSay2:setText(cFormula1)
oSay3:setText(cFormula2)
If !Empty(Alltrim(cTexto1))
	cTexto := cTexto1
	oSay1:setText(cTexto)
ElseIf !Empty(Alltrim(cTexto2))
	cTexto := cTexto2
	oSay1:setText(cTexto)
EndIf
oSay1:Refresh()
oSay2:Refresh()
oSay3:Refresh()  

If ValType(aObjGet[Eval(bGetoGet)]) == "O"
	aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216FECHAºAutor  ³Microsiga           º Data ³  12/19/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Fecha a janela a ssimq eu ela  inicializa                  º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP216FECHA(oDlg)
	oDlg:Hide()
	oDlg:End()
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q216FCHLABºAutor  ³Microsiga           º Data ³  12/19/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Restaura o aResultados                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q216FCHLAB(aResAnt, nOpca)
	If lFechaLab .AND. nOpca <> 2
		aResultados[nPosOper,_LLA,nPosLab] := aClone(aResAnt)
    	M->QPL_LAUDO := aResultados[nPosOper,_LLA,nPosLab,3]
  	EndIf
Return lFechaLab


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q216FCHGERºAutor  ³Cicero Cruz         º Data ³  12/19/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Restaura o aResultados                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q216FCHGER(aResAnt, nOpca, lCancela)
Local lRet := .T.
Local nPosJus := QP215GetLau(aSavGets[1,2],"QPL_JUSTLA")
Local nPosLau := QP215GetLau(aSavGets[1,2],"QPL_LAUDO")

If  nOpca == 2 .AND. (aResultados[nFldLauGer,1,nPosLau] # cFatApr .or. lJusLObrG) .AND.;
    Empty(aResultados[nFldLauGer,1,nPosJus]) .and. !Empty(aResultados[nFldLauGer,1,nPosLau])
	Help(" ",1,"QPH215016")  //Eh obrigatorio a digitacao da justificativa do laudo Geral da OP.
	lRet  := .F.         
EndIf 	
If lRet
	If nOpca <> 2
		aResultados[nFldLauGer,1] := aClone(aResAnt)
   		M->QPL_LAUDO := aResultados[nFldLauGer,1,3]
   		lCancela := .T.
  	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q216FCHGERºAutor  ³Microsiga           º Data ³  12/19/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Restaura o aResultados                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q216FCHINS(aInsAnt, nOpca)
Local lRet := .T.

If nOpca <> 1
	aResultados[nPosOper,_INS,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt] := aClone(aInsAnt)
	oGetINS:aCols := aClone(aResultados[nPosOper,_INS,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt])
EndIf
															    
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ A216VLOP ³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 17/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Faz a mudanca rapida de operacao                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A216VLOP(cOperac, nOpcA, oDlgMain, cChave, oBrwJJ)

Local nPosLauOP := 0 
Local lContinua := .T.
Local nCount    := 0
Local lEnsObr   := .T.
Local lMessag   := .T.
Local nLab		:= 0  
Local nCEns     := 0
Local nC        := 0
Local nPosOri   := 0
Local nPosDes   := 0     
Local aResuLGer := {} 
Local lVerif 	:= .T.
Local lNoLabUp  := .F.

lLinOKMedi := .F.  

If cOper == c220OPER .OR. Iif(!lCPrimOP,.F.,c220OPER == "  " )
	c220OPER := "  " 
	If ValType(aObjGet[Eval(bGetoGet)]) == "O"
		SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
	EndIf
	
	If !Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLab,3])) .OR. !Empty(AllTrim(aResultados[nFldLauGer,1,3])) .OR. !Empty(AllTrim(aResultados[nPosOper,_LOP,3]))
		lLinOKMedi := .F.  
	Else
		lLinOKMedi := .T.  
	EndIf
	
	Return .T.
EndIf

If !lCPrimOP
	lNoLabUp := .T.
	If !A216VldOpe( @cIP210Pro, oDescPro, @dDtInit, oDtInit, @cIP210LC, @cChave ) 
		lCPrimOP := .F.
		c220OPER := "  " 
		lLinOKMedi := .T.  
		Return .T.
	EndIf
	If 	A216GEstru( cIP210Op, nOpcA, cIP210LC,        Nil, oDlgMain, c220OPER )
		cOper	  := aResultados[1,_OPE]  
		cOperac   := cOper
		c220OPER  := cOper
		cDescOper := aOperacoes[1,2] + " - " + aOperacoes[1,3]
		A216VldLt(cIP210OP,@cIP210LC)
		QipLauLab(nOpcA, .F. , oDlgMain)	    
	    If !Empty(AllTrim(aResultados[nPosOper,_LLA,1,3]))
		    cIP210L3 := aResultados[nPosOper,_LLA,1,3]
		    lLauLab  := .T.  
		EndIf
	    If !Empty(AllTrim(aResultados[nPosOper,_LOP,3]))
			cIP210L2 := aResultados[nPosOper,_LOP,3]
			lLauOp   := .T.  
		EndIf
		If !Empty(AllTrim(aResultados[nFldLauGer,1,3]))
			cIP210L1 := aResultados[nFldLauGer,1,3]	  
			lLauLab  := .T.
			lLauOp   := .T. 
		EndIf                               
		QIP216NC(.F.)
		QIP216INS(.F.)
	EndIf    
	lCPrimOP := .T.
EndIf      

If Len(aResultados) == 0
	lCPrimOP := .F.
	c220OPER := "  " 
	lLinOKMedi := .T.  
	Return .T.
EndIf

nPosLauOP := QP215GetLau(aSavGets[1,2],"QPL_LAUDO")


If lCarOtm .AND. Len(aOperaFull) <> Len(aOperacoes)
	nPosOri := aScan(aOperacoes,{|x| x[2] == aOperacoes[nPosOper,2]})
	nPosDes := aScan(aOperacoes,{|x| x[2] == c220OPER })
	lVerif  := Iif(nPosDes >= 1 .AND. ( ALTERA .OR. INCLUI ), Q216VNCAR(nPosOri, nPosDes, .F.), .T.)
	If nPosDes <= 0
		nPosOri := aScan(aOperaFull,{|x| x[2] == aOperacoes[nPosOper,2]})
		nPosDes := aScan(aOperaFull,{|x| x[2] == c220OPER })
		lVerif  := Iif(nPosDes >= 1 .AND. ( ALTERA .OR. INCLUI ), Q216VNCAR(nPosOri, nPosDes, .F.), .T.)
		If !lVerif
			If nPriposs > 0
				nPosDes  := nPriposs // Seto a Primeira operação possivel
				cOper 	 := aOperaFull[nPriposs,2]
				c220OPER := cOper
				lVerif   := .T.
			EndIf
			nPriposs := 0
		EndIf
		If nPosDes >= 1 .AND. lVerif .AND. aScan(aOperacoes,{|x| x[2] == c220OPER }) == 0 
	
			aResuLGer := aClone(aResultados[Len(aResultados)])
			
	    	aDel(aResultados,Len(aResultados))
		    aSize(aResultados,Len(aResultados)-1)
			
			aAdd(aOperacoes , aOperaFull[nPosDes] )
			aAdd(aResultados, aResulFull[nPosDes] )	   
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ordena as arrays de aResultados e aOperacoes				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSort(aResultados,,,{|x,y|x[1]<y[1]})
			aSort(aOperacoes,,,{|x,y|x[2]<y[2]})                                 
			
			aAdd(aResultados, aResuLGer )	   		
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o aResultados com base no aOperaçoes ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aOperaFull[nPosDes,2] > aOperaFull[nPosOri,2]
				nPosDes := aScan(aOperacoes,{|x| x[2] == aOperaFull[nPosDes,2]})   
				nPosOpDes := nPosDes
				QP215COPE(QPK->QPK_PRODUT, QPK->QPK_REVI, @aOper, nOpcA, nPosDes, 1) 
			Else
				nPosDes := aScan(aOperacoes,{|x| x[2] == aOperaFull[nPosDes,2]})   
				nPosOpDes := nPosDes
				QP215COPE(QPK->QPK_PRODUT, QPK->QPK_REVI, @aOper, nOpcA, nPosDes, 2) 
			EndIf
			
			nFldLauGer := Len(aResultados)   
	    ElseIf !lVerif  
			lContinua := .F.    	
			c220OPER := "  "          
			If ValType(aObjGet[Eval(bGetoGet)]) == "O"
				SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
			EndIf
			
			If !Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLab,3])) .OR. !Empty(AllTrim(aResultados[nFldLauGer,1,3])) .OR. !Empty(AllTrim(aResultados[nPosOper,_LOP,3]))
				lLinOKMedi := .F.  
			Else
				lLinOKMedi := .T.  
			EndIf
			Return .T.
		EndIf  
    ElseIf !lVerif  
		lContinua := .F.    	
		c220OPER := "  "              
		If ValType(aObjGet[Eval(bGetoGet)]) == "O"
			SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
		EndIf
		
		If !Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLab,3])) .OR. !Empty(AllTrim(aResultados[nFldLauGer,1,3])) .OR. !Empty(AllTrim(aResultados[nPosOper,_LOP,3]))
			lLinOKMedi := .F.  
		Else
			lLinOKMedi := .T.  
		EndIf 
		Return .T.
	EndIf 
ElseIf lCarOtm .AND. Len(aOperaFull) == Len(aOperacoes)
	lTeLAbr := .T.
	nPosOri := nPosOper
	nPosDes := aScan(aOperacoes,{|x| x[2] == c220OPER })
	lVerif  := Iif(nPosDes >= 1 .AND. ( ALTERA .OR. INCLUI ), Q216VNCAR(nPosOri, nPosDes, .F.), .T.)	
	If !lVerif  
		lContinua := .F.    	
		c220OPER := "  "              
		If ValType(aObjGet[Eval(bGetoGet)]) == "O"
			SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
		EndIf
		
		If !Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLab,3])) .OR. !Empty(AllTrim(aResultados[nFldLauGer,1,3])) .OR. !Empty(AllTrim(aResultados[nPosOper,_LOP,3]))
			lLinOKMedi := .F.  
		Else
			lLinOKMedi := .T.  
		EndIf
		Return .T.
	EndIf
ElseIf !lCarOtm
	nPosOri := nPosOper
	nPosDes := aScan(aOperacoes,{|x| x[2] == c220OPER })
	lVerif  := Q216VNCAR(nPosOri, nPosDes, .F.)	
	If !lVerif  
		lContinua := .F.    	
		c220OPER := "  "
		If ValType(aObjGet[Eval(bGetoGet)]) == "O"
			SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
		EndIf
		
		If !Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLab,3])) .OR. !Empty(AllTrim(aResultados[nFldLauGer,1,3])) .OR. !Empty(AllTrim(aResultados[nPosOper,_LOP,3]))
			lLinOKMedi := .F.  
		Else
			lLinOKMedi := .T.  
		EndIf
		Return .T.
	EndIf
EndIf

lExecUpDown := .T.
cOper 	 := c220OPER
nPosDes  := aScan(aOperacoes,{|x| x[2] == c220OPER })
nPosOper := 0
If GetPosResu(.T.) == 0
	cOper 	 := cOperac
	nPosOper := GetPosResu()  
	If nPosOper = 0 //Nao retirar, pois se nao achar a operacao digitada pelo usuario, causara erro...
		nPosOper = nPosOri
	Endif
	lContinua := .F.
	Help(" ",1,"QPH215076") //A operação informada não foi relacionada para esse produto.
	c220OPER := "  "
Else
	cOper 	 := cOperac
	nPosOper := GetPosResu()
EndIf

If lContinua
   cOper 	:= c220OPER
   nPosOper := GetPosResu()
   cDescOper := aOperacoes[nPosOper,2] + " - " + aOperacoes[nPosOper,3]		
   oIPDescOp:Refresh()
   nPosOpDes := nPosOper
   lTeLAbr := .T.
   
   If !lNoLabUp
	   a216LabUp(oDlgMain, .T., nPosOper, .T.)
   EndIf
EndIf

c220OPER := "  "

If ValType(aObjGet[Eval(bGetoGet)]) == "O"
	SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
EndIf

If lContinua
	QP215CalMd()
	QP216AtuEns(oDlgMain, nPosOper, nPosLab, nPosLab, nPosEns) 
EndIf

If !Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLab,3])) .OR. !Empty(AllTrim(aResultados[nFldLauGer,1,3])) .OR. !Empty(AllTrim(aResultados[nPosOper,_LOP,3]))
	lLinOKMedi := .F.  
Else
	lLinOKMedi := .T.  
EndIf

Qip216Ens(oDlgMain)
QP216RightMe()
lExecUpDown := .F.
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QP216AtuEns³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 17/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os Ensaios                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP216AtuEns(oDlgMain, nPosOper, nPosLCar, nPosLab, nPosEnsai, lAtuSel, lOPMov, lF5)
Local bLineEns  := { || Iif(oBrwJJ:nAt <= Len(aListEns),{;
								aListEns[oBrwJJ:nAt,1],;
								aListEns[oBrwJJ:nAt,2],;
								aListEns[oBrwJJ:nAt,3],;
								aListEns[oBrwJJ:nAt,4],;
								aListEns[oBrwJJ:nAt,5],;
								aListEns[oBrwJJ:nAt,6],;
								aListEns[oBrwJJ:nAt,7],;
								aListEns[oBrwJJ:nAt,8],;
								aListEns[oBrwJJ:nAt,9],;
								aListEns[oBrwJJ:nAt,10],;
								aListEns[oBrwJJ:nAt,11],;
								aListEns[oBrwJJ:nAt,12],;
								aListEns[oBrwJJ:nAt,13],;
								aListEns[oBrwJJ:nAt,14],;
								aListEns[oBrwJJ:nAt,15],;
								aListEns[oBrwJJ:nAt,16] },)}
Local nX := 1
Local nPosMetodo 	:= 0
Local aListEnsA := aClone(aListEns)                                     

Default lAtuSel   := .F.  
Default nPosEnsai := oBrwJJ:nAt
Default lOPMov	  := .F.
Default lF5		  := .F.

aListEns := {}

aResultados := aClone(aResultados) //Desvinculo o aResultados de qq objeto    

	//Recurso de Atualização de Leds em Massa
	//Entradas: aResultados
	//Saida:	aLedAtu 			
	aLedAtu := aClone(QP215StAll(nPosOper,nPosLCar)) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Preenche os ensaios associados ao Laboratorio 				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aeval(aResultados[nPosOper,_ENS,nPosLCar],{|x,y|Aadd(aListEns,aClone({;
			aLedAtu[y][1],; 
			aLedAtu[y][2],; 
			aLedAtu[y][3],; 
			aLedAtu[y][4],; 
			aResultados[nPosOper,_ENS,nPosLCar,y,1],;
			aResultados[nPosOper,_ENS,nPosLCar,y,2],;
			aResultados[nPosOper,_ENS,nPosLCar,y,3],;
			aResultados[nPosOper,_ENS,nPosLCar,y,4],;
			aResultados[nPosOper,_ENS,nPosLCar,y,6],;
			aResultados[nPosOper,_ENS,nPosLCar,y,8],;
			aResultados[nPosOper,_ENS,nPosLCar,y,10],;
			aResultados[nPosOper,_ENS,nPosLCar,y,11],;
			Iif(aOperacoes [nPosOper][6] == "S", "Sim", "Não"),; // Operacao Obrigatoria
			Iif(aOperacoes [nPosOper][7] == "S", "Sim", "Não"),; // Sequencia Obrigatoria
			Iif(aOperacoes [nPosOper][8] == "S", "Sim", "Não"),; // Laudo Obrigatorio
			Iif(aResultados[nPosOper, _ENS, nPosLCar, y, ENSOBR] == "S", "Sim", "Não") }) )})  //Ensaio Obrigatorio

oBrwJJ:lMChange 		:= .F. // Nao deixar mudar tamanho das colunas.
oBrwJJ:nClrBackFocus	:= GetSysColor( 13 )
oBrwJJ:nClrForeFocus	:= GetSysColor( 14 )
oBrwJJ:SetArray( aListEns )
oBrwJJ:bLostFocus 		:= {|| QP216RightMe(nPosOper,nPosLab,nPosEnsai)} 
oBrwJJ:bLine   			:= bLineEns                                                                                                                     
oBrwJJ:bGotFocus		:= {|| QP216VGot()}
oBrwJJ:bChange 			:= {|| cIDFoco := "ID:Ensaios" } //bChangeBrw   
oBrwJJ:bLDblClick       := {|| QP216VDbl() }
oBrwJJ:nAt 				:= nPosEnsai                                                                                                                                    
oBrwJJ:cTitle   		:= "ID:Ensaios"

oBrwJJ:Refresh()

cAtuNco := "2"
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216AtuInºAutor  ³Cicero Odilio Cruz  º Data ³  30/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualização do Led de Instrumentos                         º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP216AtuIn(oDlgMain, nPosOper, nPosLCar, nPosLab, nPosEnsai, lAtuCel, lOPMov, nArt, aListEnsA)
Local lAtu	:= .T.

If lOPMov 
	 lAtu := .T.
ElseIf lAtuIns
	If lAtuCel	 
		lAtu := ( (nArt == oBrwJJ:nAt .OR. aResultados[nPosOper, _ENS, nPosLCar, nArt, ENSCALC]) .AND. Len(aResultados[nPosOper,_ENS,nPosLCar]) >= Len(aListEnsA) )
	Else            
		lAtu := .F.
	EndIf 
EndIf

If !lAtu
	If lAtuIns	
		lAtu := !( Len(aListEnsA) == Len(aResultados[nPosOper,_ENS,nPosLCar]) .AND. aResultados[nPosOper,_ENS,nPosLCar,nArt,2] == aListEnsA[nArt,6] )
	Else
		lAtu := Len(aResultados[nPosOper,_ENS,nPosLCar]) > Len(aListEnsA) .OR. ! ( Len(aListEnsA)==Len(aResultados[nPosOper,_ENS,nPosLCar]) .AND. aResultados[nPosOper,_ENS,nPosLCar,nArt,2] == aListEnsA[nArt,6] )
	EndIf
EndIf

If lAtu
	cRet := QP215AtuSta(nPosOper,nPosLCar,nArt,"","E",{3},.F.)
Else 
	cRet := aListEnsA[nArt,3]
Endif
				
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216AtuMdºAutor  ³Cicero Odilio Cruz  º Data ³  12/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualização do Led de Medições                             º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP216AtuMd(oDlgMain, nPosOper, nPosLCar, nPosLab, nPosEnsai, lAtuEns, nArt, aListEnsA)
Local lAtu	:= .T.


If lAtuEns
	lAtu := ( ( nArt == oBrwJJ:nAt .OR. aResultados[nPosOper, _ENS, nPosLCar, nArt, ENSCALC] ) .AND. Len(aResultados[nPosOper,_ENS,nPosLCar]) >= Len(aListEnsA) )
Else
	lAtu := .T.
EndIf

If !lAtu 
	lAtu := !( Len(aListEnsA) == Len(aResultados[nPosOper,_ENS,nPosLCar]) .AND. aResultados[nPosOper,_ENS,nPosLCar,nArt,2] == aListEnsA[nArt,6] )
EndIf

If lAtu
	cRet := QP215AtuSta(nPosOper,nPosLCar,nArt,"","E",{1},.F.)
Else
	cRet := aListEnsA[nArt,1]
Endif

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216AtuNcºAutor  ³Cicero Odilio Cruz  º Data ³  30/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualização do Led de Não Conformidades                    º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP216AtuNc(oDlgMain, nPosOper, nPosLCar, nPosLab, nPosEnsai, lAtuNco, cAtuNco, lOPMov, nArt, aListEnsA)
Local lAtu	:= .T.

If lOPMov
	 lAtu := .T.
ElseIf ( cAtuNco == "1" .OR. cAtuNco == "3" )
	If lAtuNco
		lAtu := ( ( nArt == oBrwJJ:nAt .OR. aResultados[nPosOper, _ENS, nPosLCar, nArt, ENSCALC] ) .AND. Len(aResultados[nPosOper,_ENS,nPosLCar]) >= Len(aListEnsA) )
	Else            
		lAtu := .T.
	EndIf
EndIf

If !lAtu
	If lAtuNco
		lAtu := !( Len(aListEnsA) == Len(aResultados[nPosOper,_ENS,nPosLCar]) .AND. aResultados[nPosOper,_ENS,nPosLCar,nArt,2] == aListEnsA[nArt,6] )
	Else
		lAtu := Len(aResultados[nPosOper,_ENS,nPosLCar]) > Len(aListEnsA) .OR. ! ( Len(aListEnsA)==Len(aResultados[nPosOper,_ENS,nPosLCar]) .AND. aResultados[nPosOper,_ENS,nPosLCar,nArt,2] == aListEnsA[nArt,6] )
	EndIf
EndIf

If lAtu
	cRet := QP215AtuSta(nPosOper,nPosLCar,nArt,"","E",{2},.F.)
Else
	cRet := aListEnsA[nArt,2]
Endif

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q216VNCAR ºAutor  ³Cicero Odilio Cruz  º Data ³  09/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se os dados que não estão carregados são obrigató-  º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q216VNCAR(nPosOri, nPosDest, lButUp)

Local nPosLauOP := Ascan(aCpoEnc[1],{|x|AllTrim(x)=="QPL_LAUDO"}) 
Local nCount    := 0   
Local nCEns     := 0  
Local nCLab     := 0       
Local lContinua := .T.              
Local lRet      := .T.
Local aAreaQPM 	:= QPM->(GetArea())
Local aAreaQPL  := QPL->(GetArea())
Local aAreaQPR  := QPR->(GetArea())   
Local lEnsObr   := .T.
Local lMessag   := .T.
Local nLab		:= 0  
Local nC        := 0

Default lButUp  := .F.

If nPosOri ==0 .AND. !lCPrimOP
	nPosOri := 1
EndIf

If  nPosDest > nPosOri .AND. (INCLUI .OR. ALTERA) // Carrego validando a especificação
	For nCount := nPosOri To nPosDest-1 // Valido somente a seqe
        nOriCar := aScan(aOperacoes,{|x| x[2] == aOperaFull[nCount,2] })
		If 	lCarOtm .AND. nOriCar <= 0
			If lRet
				If aOperaFull[nCount,6] == "S" .AND. lContinua //Operacao Obrigatoria
					QPM->(DbSetOrder(3)) 
					If QPM->(DbSeek(xFilial("QPM")+padr(QPK->QPK_OP,TamSX3("QPM_OP")[1])+QPK->QPK_LOTE+QPK->QPK_NUMSER+cRoteiro+aOperaFull[nCount,2])) 
						If Empty(AllTrim(QPM->QPM_LAUDO))	//Laudo Operação
						   	If aOperaFull[nCount,7] == "S"	//Sequencia Obrigatoria - Na  JJ a  sequencia não-obrigatória tem Precedencia sobre as outras.
						   		If lButUp
									MsgAlert(STR0074,STR0040)	//"Atenção" //"O Laudo é obrigatório, para que seja possível mudar de operação, deverá informá-lo."
							   	Else
							   		MsgAlert(STR0115+aOperaFull[nCount,2]+STR0116,STR0040)	//"O Laudo da Operação"###" é obrigatório, para que seja possível mudar de operação, deverá informá-lo."###"Atenção"
							   		nPriposs := nCount
								EndIf
								lRet := .F.
							Else
								If qpAviso(STR0016,STR0117+aResulFull[nCount,_OPE]+STR0118,{STR0079,STR0080}) == 2 //"Operação :"###"A sequência não é obrigatória, mas o Laudo da Operação: "###" é obrigatório. Deseja continuar?"###"Continua"###"Abandona"
									lContinua	:= .F.
							   		nPriposs 	:= nCount 
							   		lRet 		:= .F.
									Exit
								EndIf
							EndIf
						EndIf
					ElseIf lRet
						If aOperaFull[nCount,7] == "S"	//Sequencia Obrigatoria - Na  JJ a  sequencia não-obrigatória tem Precedencia sobre as outras.
							If lButUp
								MsgAlert(STR0074,STR0040)	//"Atenção" //"O Laudo é obrigatório, para que seja possível mudar de operação, deverá informá-lo."
							Else
								MsgAlert(STR0115+aOperaFull[nCount,2]+STR0116,STR0040)	//"O Laudo da Operação"###" é obrigatório, para que seja possível mudar de operação, deverá informá-lo."###"Atenção"
						   		nPriposs := nCount
							EndIf					
							lRet := .F.
						Else
							If qpAviso(STR0016,STR0117+aResulFull[nCount,_OPE]+STR0118,{STR0079,STR0080}) == 2 //"Operação :"###"A sequência não é obrigatória, mas o Laudo da Operação: "###" é obrigatório. Deseja continuar?"###"Continua"###"Abandona"
								lContinua	:= .F.
						   		nPriposs 	:= nCount
						   		lRet 		:= .F.
								Exit
							EndIf
						EndIf
					EndIf
				Else
					For nCLab := 1 To Len(aResulFull[nCount,_LAB])
						If aOperaFull[nCount,8] == "S"		//Laudo Obrigatorio
							If lRet
								QPL->(dbSetOrder(3)) 
								If QPL->(DbSeek(xFilial("QPL")+padr(QPK->QPK_OP,TamSX3("QPL_OP")[1])+QPK->QPK_LOTE+QPK->QPK_NUMSER+cRoteiro+aOperaFull[nCount,2]+aResulFull[nCount,_LAB,nCLab])) 
									If Empty(AllTrim(QPL->QPL_LAUDO)) //cIP210L3
										If aOperaFull[nCount,7] == "S"	//Sequencia Obrigatoria - Na  JJ a  sequencia não-obrigatória tem Precedencia sobre as outras.
											If lButUp
												MsgAlert(STR0075,STR0040)	//"Atenção" //"O Laudo do Laboratório é obrigatório, para que seja possível mudar de operação, deverá informá-lo."
											Else
												MsgAlert(STR0119+aResulFull[nCount,_LAB,nCLab]+STR0120+aOperaFull[nCount,2]+STR0116,STR0040)	//"O Laudo do Laboratório "###" na Operação "###" é obrigatório, para que seja possível mudar de operação, deverá informá-lo."###"Atenção"
										   		nPriposs := nCount
											EndIf
											lRet := .F.
										Else
											If qpAviso(STR0016,STR0121+aResulFull[nCount,_LAB,nCLab]+STR0120+" "+STR0118,{STR0079,STR0080}) == 2 //"Operação :"###"A sequência não é obrigatória, mas o Laudo do Laboratório "###"na Operacao"###" é obrigatório. Deseja continuar?"###"Continua"###"Abandona"
												lContinua	:= .F.
										   		nPriposs 	:= nCount
										   		lRet 		:= .F.
												Exit
											EndIf
										Endif
									EndIf
								Else
									If aOperaFull[nCount,7] == "S"	//Sequencia Obrigatoria - Na  JJ a  sequencia não-obrigatória tem Precedencia sobre as outras.
										If lButUp
											MsgAlert(STR0075,STR0040)	//"Atenção" //"O Laudo do Laboratório é obrigatório, para que seja possível mudar de operação, deverá informá-lo."
										Else
											MsgAlert(STR0119+aResulFull[nCount,_LAB,nCLab]+STR0120+aOperaFull[nCount,2]+STR0116,STR0040)	//"O Laudo do Laboratório "###" na Operação "###" é obrigatório, para que seja possível mudar de operação, deverá informá-lo."###"Atenção"
									   		nPriposs := nCount
										EndIf
										lRet := .F.
									Else 
										If qpAviso(STR0016,STR0121+aResulFull[nCount,_LAB,nCLab]+STR0120+" "+STR0118,{STR0079,STR0080}) == 2 //"Operação :"###"A sequência não é obrigatória, mas o Laudo do Laborat[orio: "###" na operacao  é obrigatório. Deseja continuar?"###"Continua"###"Abandona"
											lContinua	:= .F.
									   		nPriposs 	:= nCount
									   		lRet 		:= .F.
											Exit
										EndIf									
									EndIf
								EndIf
							EndIf
						ElseIf lRet
							For nCEns := 1 To Len(aResulFull[nCount,_ENS,nCLab])
								If aResulFull[nCount, _ENS, nCLab, nCEns, ENSOBR] == "S"	//Resultado Obrigatoria ou Ensaio Obrigatorio
									QPR->(dbSetOrder(9))
									If lContinua .AND. !QPR->(DbSeek(xFilial("QPR")+PADR(QPK->QPK_OP,TamSX3("QPR_OP")[1])+QPK->QPK_LOTE+QPK->QPK_NUMSER+cRoteiro+aOperaFull[nCount,2]+aResulFull[nCount,_LAB,nCLab]+aResulFull[nCount, _ENS, nCLab, nCEns, ENSAIO]))
										If 	qpAviso(STR0026,STR0076+aResulFull[nCount,_OPE]+" / "+STR0077+aResulFull[nCount,_LAB,nCLab]+Chr(13)+Chr(10)+STR0026+" :"+aResulFull[nCount, _ENS,  nCLab, nCEns, ENSAIO]+". "+Chr(13)+Chr(10)+STR0078,{STR0079,STR0080}) == 2 //"Operação :"###" Laboratório :"###" Ensaio :"###"A sequência não é obrigatória, mas existe ensaio que é obrigatório.Deseja continuar ?"###"Continua"###"Abandona"
											lContinua	:= .F.
									   		nPriposs := nCount											
											Exit
										EndIf
									EndIf
								EndIf
							Next nCEns
						EndIf
					Next nCLab
					If !lContinua
						lRet := .F.
					EndIf
				EndIf  
			EndIf
	    ElseIf lRet 
			If  aOperacoes[nOriCar,6] == "S"				//Operacao Obrigatoria
				If Empty(aResultados[nOriCar,_LOP,nPosLauOP])
					If aOperacoes[nOriCar,7] == "S"	//Sequencia Obrigatoria - Na  JJ a  sequencia não-obrigatória tem Precedencia sobre as outras.
						If lButUp
							MsgAlert(STR0074,STR0040)	//"Atenção" //"O Laudo é obrigatório, para que seja possível mudar de operação, deverá informá-lo."
						Else
							MsgAlert(STR0091+AllTrim(aResultados[nOriCar,_OPE])+STR0092) // "O Laudo da Operação : "###" é obrigatório, antes de usar a Operação rápida de o Laudo desta Operação!"
						Endif
						lContinua := .F.
					Else
						If qpAviso(STR0016,STR0117+AllTrim(aResultados[nOriCar,_OPE])+STR0118,{STR0079,STR0080}) == 2 //"Operação :"###"A sequência não é obrigatória, mas o Laudo da Operação: "###" é obrigatório. Deseja continuar?"###"Continua"###"Abandona"
							lContinua	:= .F.
					   		lRet 		:= .F.
							Exit
						EndIf					
					EndIf
				EndIf
			Else
				For nLab := 1 To Len(aResultados[nOriCar,_LAB])	
					If aOperacoes[nOriCar,8] == "S" .AND. lContinua		//Laudo Obrigatorio
						If Empty(AllTrim(aResultados[nOriCar,_LLA,nLab,3]))
							If aOperacoes[nOriCar,7] == "S"	//Sequencia Obrigatoria - Na  JJ a  sequencia não-obrigatória tem Precedencia sobre as outras.
								If lButUp
									MsgAlert(STR0075,STR0040)	//"Atenção" //"O Laudo do Laboratório é obrigatório, para que seja possível mudar de operação, deverá informá-lo."
								Else
									MsgAlert(STR0095) // "Laudo do(s) Laboratório(s) obrigatório(s), antes de usar a Operação Rápida dê o Laudo do Laboratório!"
								EndIf
								lContinua := .F.
							Else 
								If qpAviso(STR0016,STR0121+aResultados[nOriCar,_LAB,nLab]+STR0118+" "+STR0120,{STR0079,STR0080}) == 2 //"Operação :"###"A sequência não é obrigatória, mas o Laudo do Laborat[orio: "###" na operacao  é obrigatório. Deseja continuar?"###"Continua"###"Abandona"
									lContinua	:= .F.
							   		lRet 		:= .F.
									Exit
								EndIf
							EndIf
						EndIf
					ElseIf lContinua
						For nCEns := 1 To Len(aResultado[nOriCar,_ENS, nLab])
							If aResultados[nOriCar,_ENS,nLab,nCEns,ENSOBR] == "S"  .And. lContinua	//Resultado Obrigatoria ou Ensaio Obrigatorio
								nPosResult	:= Ascan(aSavHeadEns[nOriCar,nLab,nCEns,1], { |x| Alltrim(x[2]) == Alltrim("QPR_RESULT") })
								If nPosResult == 0
									nPosResult	:= Ascan(aSavHeadEns[nOriCar,nLab,nCEns,1], { |x| Alltrim(x[2]) == Alltrim("QPQ_RESULT") })
								EndIf									
								nDelMed		:= Len(aResultados[nOriCar, _MED, nLab, nCEns,1])
							   	For nC := 1 To Len(aResultado[nOriCar,_MED, nLab, nCEns])
							   		If lContinua .AND. !aResultados[nOriCar, _MED, nLab, nCEns, nC, nDelMed]
										cMedicao	:= Iif(Valtype(aResultados[nOriCar, _MED, nLab, nCEns, nC, nPosResult]) == "N", Str(aResultados[nOriCar, _MED, nLab, nCEns, nC, nPosResult]),aResultados[nOriCar, _MED, nLab, nCEns, nC, nPosResult])
										If Empty(cMedicao) .And. lMessag
											If 	qpAviso(STR0026,STR0076+AllTrim(aResultados[nOriCar,_OPE])+" / "+STR0077+AllTrim(aResultado[nOriCar,_LAB,1])+Chr(13)+Chr(10)+STR0026+" :"+AllTrim(aResultados[nOriCar,_ENS,nLab,nCEns,ENSAIO])+". "+Chr(13)+Chr(10)+STR0078,{STR0079,STR0080}) == 2 //"Ensaio"###"A sequência não é obrigatória, mas existe ensaio que é obrigatório.Deseja continuar ?"###"Continua"###"Abandona" //"Operação :"###" Laboratório :"###" Ensaio :"
												lContinua	:= .F.
											Else
												lEnsObr		:= .F.
												lMessag		:= .F.	//Para que seja mostrado mensagem somente uma vez
											EndIf
										EndIf
									EndIf 
								Next nC
							EndIf
						Next nCEns
					EndIf						
				Next nLab
			EndIf
			If !lContinua
				lRet := .F.
			EndIf
	    EndIf
	Next nCount
Else //Corforme regra Cliente JJ para tras não valida pois para chegar nesta operação o Up da operação ou operação rápida já validou.
	Return .T.
EndIf	

RestArea(aAreaQPM)
RestArea(aAreaQPL)
RestArea(aAreaQPR)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q216CALL  ºAutor  ³Cicero Odilio Cruz  º Data ³  01/30/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega todas as Operações ao se clicar no Laudo Geral      º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q216CALL()
Local nPosOri   := 0
Local nPosDes   := 0     
Local aResuLGer := {}
Local nY 		:= 1

If Len(aOperaFull) <> Len(aOperacoes)

	lCarAll := .T.  
	
    For nY := 1 To Len(aOperaFull)
	
		If aScan(aOperacoes,{|x| x[2] == aOperaFull[nY,2] }) == 0

			aResuLGer := aClone(aResultados[Len(aResultados)])
			
	    	aDel(aResultados,Len(aResultados))
		    aSize(aResultados,Len(aResultados)-1)
			
			aAdd(aOperacoes , aOperaFull[nY] )
			aAdd(aResultados, aResulFull[nY] )	   
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ordena as arrays de aResultados e aOperacoes				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSort(aResultados,,,{|x,y|x[1]<y[1]})
			aSort(aOperacoes,,,{|x,y|x[2]<y[2]})                                 
			
			aAdd(aResultados, aResuLGer )	   		

			nPosDes := aScan(aOperacoes,{|x| x[2] == aOperaFull[nY,2]})   
			nPosOpDes := nPosDes
			QP215COPE(QPK->QPK_PRODUT, QPK->QPK_REVI, @aOper, nOpcA, nPosDes, 1) 

			nFldLauGer := Len(aResultados)
	
		EndIf  

		lCarAll := .F.		
	Next

EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q216ExecVaºAutor  ³Microsiga           º Data ³  16/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Uso para inicializar o método bEditCol pois na Build Atual  º±±
±±º          ³este metodo é reescrito pelo frame.                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q216ExecVa()
Local nPosCol  := 1
Local cCarta   := ""
Local nPosMed  := 0
Local nPosRes  := 0
Local cVarAux  := "" 
Local uValor   := ""
Local lTemLau := .F.

If ValType(aObjGet[Eval(bGetoGet)]) <> "O"
	Return .T.
EndIf

nPosCol  := aObjGet[Eval(bGetoGet)]:oBrowse:ColPos

If lExecUpDown
	aObjGet[Eval(bGetoGet)]:aCols := aClone(aResultados[nPosOper,_MED,nPosLab,nPosEns]) 
EndIf

If !lLinOKMedi .OR. lLiberaUrg
	Return .T.
EndIf

If !Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLab,3]))
		lTemLau := .T.      
ElseIf !Empty(aResultados[nPosOper,_LOP,3])
		lTemLau := .T.      
ElseIf !Empty(AllTrim(aResultados[nFldLauGer,1,3])) 
		lTemLau := .T.      
EndIf

If !ALTERA .OR. lTemLau
	Return .T.
EndIf

cCarta := aResultados[nPosOper,_ENS,nPosLab,nPosEns,CARTA]
                    
If cCarta <> "TXT"
	If cCarta <> "P  "
		nPosMed := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == 'QPS_MEDICA' })
	Else
		nPosMed := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == 'QPS_MEDIPA' })
	EndIF
	nPosRes := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == 'QPR_RESULT' })
Else
	nPosMed := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == 'QPQ_MEDICA' })
	nPosRes := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == 'QPQ_RESULT' })
EndIf       

If aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSCALC]
	Return .T.
EndIf

If cCarta <> "TMP" .AND. ( Empty(Alltrim(ReadVar())) .OR. ( ( nPosCol < nPosMed .OR. nPosCol > (nPosMed-1+aResultados[nPosOper,_ENS,nPosLab,nPosEns,QTDMED]) )  .AND. nPosCol <> nPosRes ) )
	If Len(aResultados[nPosOper,_MED,nPosLab,nPosEns])  > Len(aObjGet[Eval(bGetoGet)]:aCols) // Indica que houve retirada de linha inconsistente
		aResultados[nPosOper,_MED,nPosLab,nPosEns]  := aClone(aObjGet[Eval(bGetoGet)]:aCols) 
		QP216AtuEns(oBrwJJ:oWnd, nPosOper, nPosLab, nPosLab, nPosEns, .T.)		
	Else                                                                  
		aResultados[nPosOper,_MED,nPosLab,nPosEns]  := aClone(aObjGet[Eval(bGetoGet)]:aCols) 
	EndIf 
	Return .T.
Else
	If nPosCol == nPosMed  
   		If cCarta <> "TXT"
			If cCarta <> "P  "
				cVarAux := "M->QPS_MEDICA" 
			Else
				cVarAux := "M->QPS_MEDIPA"
			EndIF
		Else
			cVarAux := "M->QPQ_MEDICA"
		EndIf
	ElseIf nPosCol == nPosRes
		If cCarta <> "TXT"
			cVarAux := "M->QPR_RESULT"
		Else
			cVarAux := "M->QPQ_RESULT"
		EndIf  
	ElseIf cCarta == "TMP"
		cVarAux := Readvar()
	ElseIf cCarta $ "XBR|XBS|HIS" 
		cVarAux := Readvar()
	ElseIf cCarta == "P  " .AND. ( nPosMed <= nPosCol .AND. nPosCol <= nPosRes )
		cVarAux := Readvar()
	ElseIf cCarta == "U  " .AND. ( nPosMed <= nPosCol .AND. nPosCol <= nPosRes )
		cVarAux := Readvar()  
	EndIf
EndIf

If Empty(AllTrim(cVarAux)) .OR. SubStr(cVarAux,0,2) <> "M-" .OR. !( SubStr(cVarAux,0,2) == "M-" .AND. QP216EDITA(cVarAux, aObjGet[Eval(bGetoGet)]) )
	Return .T.
EndIf

If Readvar() == cVarAux
	uValor := &cVarAux  
EndIf                  

If Iif(Valtype(uValor)=="C",Empty(AllTrim(uValor)),Empty(uValor))// Verificar se solucionou o lance que  zera  o registro do campo que esta s endo editado
	Return .T.
EndIf

If aObjGet[Eval(bGetoGet)]:lModified
	lModificou := .T.
	aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSALT] := 1
	oBrwJJ:bChange := {|| cIDFoco := "ID:Ensaios" } 
	If !lModNav
		nPosLMPE   := aObjGet[Eval(bGetoGet)]:nAt
		nPosMExp   := aObjGet[Eval(bGetoGet)]:nAt
	EndIf
 	lZbChan := .T.
 	lTeLAbr := .T.  
 	If cCarta == "TMP" .AND. Len(aResultados[nPosOper,_MED,nPosLab,nPosEns]) < aObjGet[Eval(bGetoGet)]:nAt 
 		aResultados[nPosOper,_MED,nPosLab,nPosEns] := aClone(aObjGet[Eval(bGetoGet)]:aCols)
 	EndIf
EndIf

If  !lValEns .AND. Len(aResultados[nPosOper,_MED,nPosLab,nPosEns]) >= aObjGet[Eval(bGetoGet)]:nAt  .AND.;
	nPosCol > 0 .AND.; 
	Len(aResultados[nPosOper,_MED,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt]) >= nPosCol .AND.;
    !aResultados[nPosOper,_MED,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt,Len(aResultados[nPosOper,_MED,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt])] .AND.;
	Len(aResultados[nPosOper,_MED,nPosLab,nPosEns,1]) == Len(aResultados[nPosOper,_MED,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt]) .AND.;
	Len(aObjGet[Eval(bGetoGet)]:aCols) >= aObjGet[Eval(bGetoGet)]:nAt
	If 	ValType(aResultados[nPosOper,_MED,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt,nPosCol]) == ValType(aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nat, nPosCol])
		If cCarta == "TMP"
			aResultados[nPosOper,_MED,nPosLab,nPosEns] := aClone(aObjGet[Eval(bGetoGet)]:aCols)
			QP215CALMD()
		ElseIf aResultados[nPosOper,_ENS,nPosLab,nPosEns,CARTA] == "TXT"
			aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nAt,nPosCol] := uValor
			aResultados[nPosOper,_MED,nPosLab,nPosEns]  := aClone(aObjGet[Eval(bGetoGet)]:aCols)
		ElseIf 	Right(Alltrim(ReadVar()),7) $ "_RESULT|_MEDIPA|_MEDICA|_MEDIPN" .AND. aResultados[nPosOper,_ENS,nPosLab,nPosEns,CARTA] $ "XBR/XBS/IND/XMR/HIS/TMP/P  /NP /C  /"
			aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nAt,nPosCol] := uValor
			aResultados[nPosOper,_MED,nPosLab,nPosEns] := aClone(aObjGet[Eval(bGetoGet)]:aCols)
			QP215CALMD()
		EndIf
		cAtuNco := "3" // Caso haja uma alteração
		QP216AtuEns(oBrwJJ:oWnd, nPosOper, nPosLab, nPosLab, nPosEns, .T.)
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216DMed ºAutor  ³Cicero Cruz         º Data ³  05/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a deleção da linha de medição                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP216DMed()
Local nW       := 0
Local nY       := 0
Local nX       := 0
Local lPodeEdt := .T.
Local lInsOK   := .T.
Local cCarta   := aResultados[nPosOper,_ENS,nPosLab,nPosEns,CARTA]
Local nPosRes  := 0
Local nPosDel  := 0
Local nOpcAvi  := 0
Local lAviVal  := .F.  
Local lExistD  := .F.
Local aEnsVin  := {}
Local cForAux  := ""

If cCarta <> "TXT"
	nPosRes := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == 'QPR_RESULT' })
Else
	nPosRes := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == 'QPQ_RESULT' })
EndIf

If Empty(aResultados[nFldLauGer,1,3]) 						// Laudo geral
	If Empty(aResultados[nPosOper,_LOP,3])					// Laudo OP
		If !Empty(aResultados[nPosOper,_LLA,nPosLab,3])	// Laudo Labor.
			lPodeEdt  := .F.
		EndIf
	Else
		lPodeEdt  := .F.
	EndIf
Else
	lPodeEdt  := .F.
EndIf 

If !lPodeEdt  
	aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nAt,Len(aObjGet[Eval(bGetoGet)]:aCols[1])] := !aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nAt,Len(aObjGet[Eval(bGetoGet)]:aCols[1])]
	aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
	Return .T.
EndIf

If Len(aResultados[nPosOper,_MED,nPosLab,nPosEns,1]) == Len(aObjGet[Eval(bGetoGet)]:aCols[1])
	aResultados[nPosOper,_MED,nPosLab,nPosEns] := aClone(aObjGet[Eval(bGetoGet)]:aCols)
EndIf

lAtuIns := .T.
cAtuNco := "3"     
                                      
nPosDel := Len(aResultados[nPosOper,_MED,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt])

If aResultados[nPosOper,_MED,nPosLab,nPosEns,aObjGet[Eval(bGetoGet)]:nAt,nPosDel]
	lExistD := .T.
Else
	// Verifico se ainda existem itens deletados
    For nY := 1 To Len(aResultados[nPosOper,_MED,nPosLab,nPosEns]) 
		If aResultados[nPosOper,_MED,nPosLab,nPosEns,nY,nPosDel]
			lExistD := .T.		
		EndIf
    Next
EndIf
QP215CALMD(Nil, lExistD)

If cMV_QINVTOT == "1" .AND. !lExistD
	nRegDel := 0    
	nRegVal := 0
	nPosDel := Len(aResultados[nPosOper,_MED,nPosLab,nPosEns,1]) 
	For nW := 1 to Len(aResultados[nPosOper,_MED,nPosLab,nPosEns]) 
		nPosDel := Len(aResultados[nPosOper,_MED,nPosLab,nPosEns,1]) 
		If !aResultados[nPosOper,_MED,nPosLab,nPosEns,nW,nPosDel] .AND. Len(aResultados[nPosOper,_INS,nPosLab,nPosEns]) >= nW 
			If nRegVal == 0 
				nRegVal := nW
			EndIf
			For nY := 1 To Len(aResultados[nPosOper,_INS,nPosLab,nPosEns,nW])
				lInsOK := Iif(lInsOK,QP215ChkMed(nPosOper, nPosLab, nPosEns, nW, nY,,3,.F.,.F.,.F.),.F.)
				If cMV_QINOBFM == "2"
					aListEns[nPosEns,3] := If(lInsOK,hOK,hVz)
				EndIf
			Next
		Else
			nRegDel++
		EndIf
	Next
	If nRegVal == 0 
		nRegVal := 1
	EndIf
	aListEns[nPosEns,3] :=	Iif(aResultados[nPosOper,_ENS,nPosLab,nPosEns,FAMVINC],;
								Iif(lInsOK .AND. !aResultados[nPosOper,_MED,nPosLab,nPosEns,nRegVal,nPosDel],;
									hOK,;
									Iif( !aResultados[nPosOper,_MED,nPosLab,nPosEns,nRegVal,nPosDel],;
							    		Iif ( Len(aResultados[nPosOper,_MED,nPosLab,nPosEns]) == 1,;
								    		Iif ( !Empty(Alltrim(aResultados[nPosOper,_MED,nPosLab,nPosEns,1,nPosRes])),hPd,hVz),;
							    			hPd),;
										Iif(Len(aResultados[nPosOper,_MED,nPosLab,nPosEns]) == nRegDel,hVz,hPd))),;
								hVz)
Else
	If lExistD
		aListEns[nPosEns,3] := hVz
	Else
		lInsOK := Iif(lInsOK, QP215ChkMed(nPosOper, nPosLab, nPosEns, aObjGet[Eval(bGetoGet)]:nAt, 1, , 3, .F., .F., .F.),.F.)
		aListEns[nPosEns,3] := If(lInsOK,hOK,hVz)
	EndIf
EndIf         

QP216AtuEns(oBrwJJ:oWnd, nPosOper, nPosLab, nPosLab, nPosEns, lExistD) 

aResultados[nPosOper,_ENS,nPosLab,nPosEns,ENSALT] := 1

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216LFoc ºAutor  | Cicero Cruz        º Data ³  04/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ aObjGet[Eval(bGetoGet)]:oBrowse:bLostFocus                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP216LFoc() 
Local lRet := .T.
Local nX   := 0
Local bAux := {|| }
Local lExecAction := .F.
Local cTipBut := " "  

If ValType(aObjGet[Eval(bGetoGet)]) <> "O"
	Return lRetLOK
EndIf

If !lModNav 

		aObjGet[Eval(bGetoGet)]:oBrowse:GoUp() 
		If  !lRetLOK .AND. Len(aObjGet[Eval(bGetoGet)]:aCols) >= nPosLMPE .AND. !aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nAt,Len(aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nAt])]
			aObjGet[Eval(bGetoGet)]:Hide()
		    aObjGet[Eval(bGetoGet)]:nAt := Iif(nPosLMPE > aObjGet[Eval(bGetoGet)]:nAt, nPosLMPE:=1, nPosLMPE) 
		    SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
			aObjGet[Eval(bGetoGet)]:Show()
			aObjGet[Eval(bGetoGet)]:Refresh() 
		ElseIf lRetLOK
			aResultados[nPosOper,_MED, nPosLab, nPosEns] :=  aClone(aObjGet[Eval(bGetoGet)]:aCols)
		EndIf
		  
EndIf

lLinOKMedi := .T.
If aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nAt,Len(aObjGet[Eval(bGetoGet)]:aCols[aObjGet[Eval(bGetoGet)]:nAt])]
	lRetLOK := .T.
EndIf  

If lRetLOK
	aResultados[nPosOper,_MED,nPosLab,nPosEns] := aClone(aObjGet[Eval(bGetoGet)]:aCols)
EndIf

Return lRetLOK

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216GFoc ºAutor  | Cicero Cruz        º Data ³  17/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ aObjGet[Eval(bGetoGet)]:oBrowse:bGotFocus                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP216GFoc()
Local lTemLau := .F.

If !Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLab,3]))
		lTemLau := .T.      
ElseIf !Empty(aResultados[nPosOper,_LOP,3])
		lTemLau := .T.      
ElseIf !Empty(AllTrim(aResultados[nFldLauGer,1,3])) 
		lTemLau := .T.      
EndIf

If !lRetLOK  
	If oBrwJJ:nAt == nPosEnsAnt
		SetFocus(oBrwJJ:hWnd)   
		oBrwJJ:nAt  := nPosEnsAnt 
		oBrwJJ:Refresh()                          
		SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
	EndIf
ElseIf lModNav .AND. !lExpandiu .AND. ALTERA .AND. oBrwJJ:nAt <> nPosEExp .AND. !lTemLau .AND. !lExecUpDown .AND. oBrwJJ:nAt <> nPosEnsAnt
	MsgAlert(STR0122) 
	SetFocus(oBrwJJ:hWnd)   
	Return .T.
EndIf

If lExpandiu
	oBrwJJ:nRight	:= nR
	oBtn[6]:lVisible := .T.
	oBtn[6]:Refresh()
	oBtn[7]:lVisible := .F.
	oBtn[7]:Refresh()
	lExpandiu := .F.
	SetFocus(oBrwJJ:hWnd)
	oBrwJJ:nAt  := nPosEExp
	oBrwJJ:Refresh()	  
	aObjGet[Eval(bGetoGet)]:nAt := Iif( nPosMExp > Len(aObjGet[Eval(bGetoGet)]:aCols), 1, nPosMExp )
	SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
	aObjGet[Eval(bGetoGet)]:Show()   
Else
	QP216RightMe()
Endif       

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216VDbl ºAutor  | Cicero Cruz        º Data ³  17/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ oBrwJJ:bLDblClick                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP216VDbl(lChgEns) 
Local nPosRes := 0   
Local nPosDel := 0
Local nI := 0

default lChgEns  := .F.
If Valtype(aObjGet[Eval(bGetoGet)]) <> "O"
	Return .F.
EndIf

nPosRes   := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == 'QPR_RESULT' })
If nPosRes == 0                                            
	nPosRes   := aScan(aObjGet[Eval(bGetoGet)]:aHeader, { |x| AllTrim(x[2]) == 'QPQ_RESULT' })
EndIf
nPosDel := Len(aObjGet[Eval(bGetoGet)]:aCols[1])

If lExpandiu
	oBrwJJ:nRight	:= nR
	oBtn[6]:lVisible := .T.
	oBtn[6]:Refresh()
	oBtn[7]:lVisible := .F.
	oBtn[7]:Refresh()
	lExpandiu := .F.
	oBrwJJ:nAt  := nPosEExp
	oBrwJJ:Refresh()	
	aObjGet[Eval(bGetoGet)]:nAt := Iif( nPosMExp > Len(aObjGet[Eval(bGetoGet)]:aCols), 1, nPosMExp )
	aObjGet[Eval(bGetoGet)]:Show()   
	SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
	aObjGet[Eval(bGetoGet)]:Refresh()
	lChLFoc := .F.
Endif
        
If ALTERA // Este  Bloco de Código altare ao comportamento do Componente e suas  iteração para a JJ

	If Valtype(aObjGet[Eval(bGetoGet)]) == "O"
		aObjGet[Eval(bGetoGet)]:oBrowse:GoUp()

		If ( ( lModificou .AND. lRetLOK ) .OR. !lModificou ) 
		    // Passo para o Modo de Edição
			lModNav := .F.
	    	nPosEns := oBrwJJ:nAt
		    aObjGet[Eval(bGetoGet)]:lModified := .F.
		    lModificou := .F.
			oBrwJJ:bChange := {|| cIDFoco := "ID:Ensaios" }
			QP215ChgEns(nPosOper, nPosLab, nPosEnsAnt, nPosEns, .T., .F.,lChgEns)
//			SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
			If Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLab,3])) .AND. Empty(AllTrim(aResultados[nFldLauGer,1,3]))
				QP216AtuEns(oBrwJJ:oWnd, nPosOper, nPosLab, nPosLab, nPosEns, .F.)
			Else // Verifico inconsistencias  causadas  pela orientacao do Frame para  a get não comer linha
				//Coloquei a consistencia abaixo, pois se a operacao anterior tiver mais ensaio que a prox, causara error.log...
				If nPosOper <> nPosOpAnt
					nPosEnsAnt := oBrwJJ:nAt				
				Endif
				For nI := 1  To Len(aResultados[nPosOper,_MED, nPosLab, nPosEnsAnt])
					If Empty(aResultados[nPosOper,_MED, nPosLab, nPosEnsAnt, nI, nPosRes])  
						aResultados[nPosOper,_MED, nPosLab, nPosEnsAnt, nI, nPosDel] := .T.
					EndIf
				Next
			EndIf
			aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
			aObjGet[Eval(bGetoGet)]:ForceRefresh()
			QP216RightMe()
			nPosEnsAnt := oBrwJJ:nAt
			cIDFoco := "ID:Medicao"
			aObjGet[Eval(bGetoGet)]:lModified := .F.
			lModificou := .F. 
			lRetLOK := .T. 
		ElseIf !lRetLOK
			lRetLOK := .F.
			lExecJ17 := .F. 
			aObjGet[Eval(bGetoGet)]:Hide()     
   			aObjGet[Eval(bGetoGet)]:nAt := Iif( nPosMExp > Len(aObjGet[Eval(bGetoGet)]:aCols), 1, nPosMExp )
			aObjGet[Eval(bGetoGet)]:Show()   
			SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
   			aObjGet[Eval(bGetoGet)]:Refresh()   
			lExecJ17 := .T.     
			cIDFoco := "ID:Medicao"			
		EndIf
	EndIf
ElseIf !ALTERA
    nPosEns := oBrwJJ:nAt
	QP215ChgEns(nPosOper, nPosLab, nPosEnsAnt, nPosEns, .T., .F.,lChgEns)
	SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
	If Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLab,3])) .AND. Empty(AllTrim(aResultados[nFldLauGer,1,3]))
		QP216AtuEns(oBrwJJ:oWnd, nPosOper, nPosLab, nPosLab, nPosEns, .F.)
	Else // Verifico inconsistencias  causadas  pela orientacao do Frame para  a get não comer linha
		//Coloquei a consistencia abaixo, pois se a operacao anterior tiver mais ensaio que a prox, causara error.log...
		If nPosOper <> nPosOpAnt
			nPosEnsAnt := oBrwJJ:nAt				
		Endif
		For nI := 1  To Len(aResultados[nPosOper,_MED, nPosLab, nPosEnsAnt])
			If Empty(aResultados[nPosOper,_MED, nPosLab, nPosEnsAnt, nI, nPosRes])  
				aResultados[nPosOper,_MED, nPosLab, nPosEnsAnt, nI, nPosDel] := .T.
			EndIf
		Next
	EndIf	
	aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
	aObjGet[Eval(bGetoGet)]:ForceRefresh()
	nPosEnsAnt := oBrwJJ:nAt
EndIf		

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216BrwC ºAutor  | Cicero Cruz        º Data ³  04/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³oBrwJJ:bChange                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP216BrwC(lCarrega)
//Local nX   := 0
Default lCarrega := .T.

cIDFoco := "ID:Ensaios"
If lCarrega
	QP215ChgEns(nPosOper, nPosLab, nPosEns, oBrwJJ:nAt, .T., .F.)
	If ValType(aObjGet[Eval(bGetoGet)]) == "O"
		SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
	EndIf
	
	aObjGet[Eval(bGetoGet)]:lModified := .F.
	lModificou := .F. 
	lRetLOK := .T.                
	QP216AtuEns(oBrwJJ:oWnd, nPosOper, nPosLab, nPosLab, nPosEns, .F.)
	aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
	aObjGet[Eval(bGetoGet)]:ForceRefresh()
	nPosEnsAnt := oBrwJJ:nAt
Else
	If nPosEns <> nPosEnsAnt
		oBrwJJ:nAt := nPosEnsAnt 
		nPosEns    := nPosEnsAnt
		If Empty(AllTrim(aResultados[nPosOper,_LLA,nPosLab,3])) .AND. Empty(AllTrim(aResultados[nFldLauGer,1,3]))
			QP216AtuEns(oBrwJJ:oWnd, nPosOper, nPosLab, nPosLab, nPosEns, .F.)
		EndIf
		aObjGet[Eval(bGetoGet)]:oBrowse:lDisablePaint := .T.                             
		aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
		aObjGet[Eval(bGetoGet)]:ForceRefresh()
		nPosEnsAnt := oBrwJJ:nAt 
		lExecJ17 := .F.	
		aObjGet[Eval(bGetoGet)]:Hide()     
	    aObjGet[Eval(bGetoGet)]:nAt := nPosLMPE 
		If ValType(aObjGet[Eval(bGetoGet)]) == "O"
			SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
		EndIf
		
		aObjGet[Eval(bGetoGet)]:oBrowse:lDisablePaint := .F.
		aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()
	    aObjGet[Eval(bGetoGet)]:Show() 
		lExecJ17 := .T.
	EndIf
EndIf

Return .T.           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216VGot ºAutor  | Cicero Cruz        º Data ³  04/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³oBrwJJ:bChange                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP216VGot()
Local lRet := .T.
If ( ( lZbChan .AND. lModificou .AND. lRetLOK ) ) 
	cIDFoco := "ID:Ensaios" 
EndIf 
lModNav := .T.                   
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPACTBL2  ºAutor  | Cicero Cruz        º Data ³  24/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ oBntL2:bAction                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPACTBL2(cOP, cOperac, cQtd, nQtd, cLaudo2, cDesc, nOpcA, oDlg)   

If lAltWind .AND. lCPrimOP
	If ExecBlock("QIP216J5",.f.,.f.,{cOP, cOperac, cQtd, nQtd, cLaudo2, cDesc, nOpcA})
		QipLauOp(nOpcA) 
	EndIf
ElseIf lCPrimOP
	SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
	aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()  
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPACTBL3  ºAutor  | Cicero Cruz        º Data ³  24/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ oBntL3:bAction                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPACTBL3(cLaudo, cDesc, cQtd, nQtd, cLaudo3, cOpera, nOpcA, oDlg)   
	local nposensSV
    // Blindagem - Inicio
    If ValType(aObjGet[Eval(bGetoGet)]) <> "O"
		Return Nil    	
	EndIf
	// Blindagem Final
	
	If lExecuJ4 .AND. lAltWind .AND. /*lRetLOK .AND.*/ lTeLAbr .AND. lCPrimOP
		lTeLAbr  := .F.   
		lNoAbrT  := .T.
		lExecuJ4 := .F.
		nposensSV:=Nposens
		If  ExecBlock("QIP216J4",.F.,.F.,{cLaudo, cDesc, cQtd, nQtd, cLaudo3, cOpera, nOpcA})
			QipLauLab(nOpcA, Nil, oDlg)	
			lNoAbrT := .F. 
		Else
			lTeLAbr :=.T.
			SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
			aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()		
		EndIf
		nPosEns:= nposensSV		
		lExecuJ4 := .T.
	ElseIf lCPrimOP
		lTeLAbr:=.T.
        If ValType(aObjGet[Eval(bGetoGet)]) == "O"
			SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
			aObjGet[Eval(bGetoGet)]:oBrowse:Refresh()  
		EndIf
		lNoAbrT := .T.
	EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216EXP  ºAutor  ³Cicero Cruz         º Data ³  06/15/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Expande/Recolhe os ensaios                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QP216PLM()
Local oDlgPLM
Local oBrwPla  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TWBROWSE Plano de Amostragem.                     			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aFields := {STR0123,STR0124,STR0125,STR0126,STR0127,STR0128,STR0129,STR0130,STR0131,STR0132,STR0133} //"Plano ","Amostragem","Nivel Amost.","NQA","Descrição","Amostra 1","Aceite 1","Rejeite 1","Amostra 2","Aceite 2","Rejeite 2" 
Local aSizes  := {30, 35, 35, 20, 150, 30, 25, 25, 30, 25, 25 }
Local bBlock  := {||Afill(Array(Len(aSizes))," ")} 

	DEFINE MSDIALOG oDlgPLM TITLE STR0001+" - "+STR0108 FROM 6.7,0 TO 28,120 OF oMainWnd 	//"Resultados da Produção"

	oBrwPla:= TwBrowse():New(0.10,0.10,382,73,bBlock,aFields,aSizes,oDlgPLM)
	oBrwPla:SetArray(aResultados[nPosOper,_PLA,nPosLab,nPosEns])      
	oBrwPla:lMChange      := .F.      
	oBrwPla:nClrBackFocus := GetSysColor(13)
	oBrwPla:nClrForeFocus := GetSysColor(14) 
	oBrwPla:bLine :=   {||{aResultados[nPosOper,_PLA,nPosLab,nPosEns][oBrwPla:nAt,1],;
					  	   aResultados[nPosOper,_PLA,nPosLab,nPosEns][oBrwPla:nAt,2],;
					  	   aResultados[nPosOper,_PLA,nPosLab,nPosEns][oBrwPla:nAt,3],;
					  	   aResultados[nPosOper,_PLA,nPosLab,nPosEns][oBrwPla:nAt,4],;
					  	   aResultados[nPosOper,_PLA,nPosLab,nPosEns][oBrwPla:nAt,5],;
					  	   aResultados[nPosOper,_PLA,nPosLab,nPosEns][oBrwPla:nAt,6],;
					  	   aResultados[nPosOper,_PLA,nPosLab,nPosEns][oBrwPla:nAt,7],;
					  	   aResultados[nPosOper,_PLA,nPosLab,nPosEns][oBrwPla:nAt,8],;
					  	   aResultados[nPosOper,_PLA,nPosLab,nPosEns][oBrwPla:nAt,9],;
					  	   aResultados[nPosOper,_PLA,nPosLab,nPosEns][oBrwPla:nAt,10],;
					  	   aResultados[nPosOper,_PLA,nPosLab,nPosEns][oBrwPla:nAt,11]}} 
    oBrwPla:Align := CONTROL_ALIGN_ALLCLIENT  

	
	ACTIVATE MSDIALOG oDlgPLM CENTERED ON INIT EnchoiceBar(oDlgPLM, {|| nOpca:=1, oDlgPLM:End()}, {|| nOpca:=0, oDlgPLM:End()} )
Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216EXP  ºAutor  ³Cicero Cruz         º Data ³  06/15/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Expande/Recolhe os ensaios                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP216RAS()
Local oDlgRAS


	DEFINE MSDIALOG oDlgRAS TITLE STR0001+" - "+STR0134 FROM 6.7,0 TO 28,120 OF oMainWnd 	//"Resultados da Produção"###"Rastreabilidade"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao da GetDados da Rastreabilidade				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGetRast := MsNewGetDados():New(1,2,127,382,Iif(Altera .Or. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE, 0),"QP215RLOK","QP215RTOK","",,,,,,,oDlgRAS,aSavaHeader[HEAD_RASTRO],)
	oGetRast:aCols := aResultados[nPosOper,_RAS] 
	oGetRast:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetRast:Refresh()
	
	ACTIVATE MSDIALOG oDlgRAS CENTERED ON INIT EnchoiceBar(oDlgRAS, {|| nOpca:=1, oDlgRAS:End()}, {|| nOpca:=0, oDlgRAS:End()} )

	If nOpca == 1
		QP215SavResu({SAV_RAS})
	EndIf
Return .F.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216EXP  ºAutor  ³Cicero Cruz         º Data ³  06/15/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Expande/Recolhe os ensaios                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QP216EXP()
Local bLineEns  := { || Iif(oBrwJJ:nAt <= Len(aListEns),{;
								aListEns[oBrwJJ:nAt,1],;
								aListEns[oBrwJJ:nAt,2],;
								aListEns[oBrwJJ:nAt,3],;
								aListEns[oBrwJJ:nAt,4],;
								aListEns[oBrwJJ:nAt,5],;
								aListEns[oBrwJJ:nAt,6],;
								aListEns[oBrwJJ:nAt,7],;
								aListEns[oBrwJJ:nAt,8],;
								aListEns[oBrwJJ:nAt,9],;
								aListEns[oBrwJJ:nAt,10],;
								aListEns[oBrwJJ:nAt,11],;
								aListEns[oBrwJJ:nAt,12],;
								aListEns[oBrwJJ:nAt,13],;
								aListEns[oBrwJJ:nAt,14],;
								aListEns[oBrwJJ:nAt,15],;
								aListEns[oBrwJJ:nAt,16] },)}

If Valtype(aObjGet[Eval(bGetoGet)]) == "U"
	Return Nil        
EndIf

If lExpandiu
	oBrwJJ:nRight	:= nR
	oBtn[6]:lVisible := .T.
	oBtn[6]:Refresh()
	oBtn[7]:lVisible := .F.
 	oBtn[7]:Refresh()
	lExpandiu := .F.
	oBrwJJ:nAt  := nPosEExp
	oBrwJJ:Refresh()	
	aObjGet[Eval(bGetoGet)]:nAt := Iif( nPosMExp > Len(aObjGet[Eval(bGetoGet)]:aCols), 1, nPosMExp )
	aObjGet[Eval(bGetoGet)]:Show()   
	SetFocus(aObjGet[Eval(bGetoGet)]:oBrowse:hWnd)
	aObjGet[Eval(bGetoGet)]:Refresh()
	lChLFoc := .F.
Else
	nPosMExp := aObjGet[Eval(bGetoGet)]:nAt
	nPosEExp := oBrwJJ:nAt
	nL := oBrwJJ:nLeft
	nR := oBrwJJ:nRight
	oBrwJJ:nRight := aObjGet[Eval(bGetoGet)]:oBrowse:nRight
	aObjGet[Eval(bGetoGet)]:Hide()
	lExpandiu := .T.  
	oBrwJJ:bLine    := bLineEns                                              
	oBrwJJ:bChange  := {|| ""}
	oBtn[6]:lVisible := .F.
	oBtn[6]:Refresh()
	oBtn[7]:lVisible := .T.
	oBtn[7]:Refresh()  
	oBrwJJ:Refresh()
	aObjGet[Eval(bGetoGet)]:Refresh()
	lChLFoc := .T.
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216EDITAºAutor  ³Cicero Cruz         º Data ³  06/15/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o campo é editavel                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QP216EDITA(cCampo, oGet)                                                    
Local lRet := .F.
Local nX   := 0

If oGet <> Nil 
	nX   := aScan(oGet:aHeader, { |x| AllTrim(x[2]) == SubStr(cCampo,4,Len(cCampo)-2) })
	If nX > 0
		If 	aScan(aPodeAlt, { |x| AllTrim(x) == AllTrim(oGet:aHeader[nX][2]) }) > 0
			lRet := .T.
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP216EDITAºAutor  ³Cicero Cruz         º Data ³  06/15/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o campo é editavel                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q216LnArr(cLinha)
Local aArrExt  := {}     
Local nX       := 0
Local nPosFor  := 0
Local cEnsExtr := ""

If At(";",cLinha) > 0
    For nX := 1 to Len(cLinha)
    	nPosFor    := At(";",cLinha)
    	If nPosFor == 0
			Exit
    	EndIf	
		cEnsExtr :=  SubStr(cLinha,1,8)
	   	cLinha := Alltrim(Stuff(cLinha,1,nPosFor,Space(nPosFor+9)))
		Aadd(aArrExt,{cEnsExtr})
	   	nX      += nPosFor
	Next nX
EndIf
If Len(AllTrim(cLinha)) > 0
	Aadd(aArrExt,{cLinha})
EndIf

Return aArrExt

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIPA215   ºAutor  ³Cicero Odilio Cruz  º Data ³  30/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recurso que limita o numero de Objetos na TelaSimplificada º±±
±±º          ³ o objtivo é reciclar objetos na  tela por ensaio.          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIPBGetOP()
Local nPosArr := 0

If cCartEns == "TXT"
	nPosArr := _TXT
ElseIf cCartEns == "TMP"
	nPosArr := _TMP
ElseIf cCartEns == "P  "
	nPosArr := _CARP
ElseIf cCartEns == "U  "
	nPosArr := _CARU
ElseIf cCartEns == "NP "
	nPosArr := _CARNP
ElseIf cCartEns == "C  "
	nPosArr := _CARC
ElseIf cCartEns == "IND"
	Do Case
		Case nQtdMed == 1
			nPosArr := _IND00
		Case nQtdMed == 2
			nPosArr := _IND00
		Case nQtdMed == 3
			nPosArr := _IND03
		Case nQtdMed == 4
			nPosArr := _IND04
		Case nQtdMed == 5
			nPosArr := _IND05
		Case nQtdMed == 6
			nPosArr := _IND06
		Case nQtdMed == 7
			nPosArr := _IND07
		Case nQtdMed == 8
			nPosArr := _IND08
		Case nQtdMed == 9
			nPosArr := _IND09
	OtherWise 
		nPosArr := _IND10
	EndCase
ElseIf cCartEns == "XBR"
	Do Case
		Case nQtdMed == 1
			nPosArr := _XBR00
		Case nQtdMed == 2
			nPosArr := _XBR00
		Case nQtdMed == 3
			nPosArr := _XBR03
		Case nQtdMed == 4
			nPosArr := _XBR04
		Case nQtdMed == 5
			nPosArr := _XBR05
		Case nQtdMed == 6
			nPosArr := _XBR06
		Case nQtdMed == 7
			nPosArr := _XBR07
		Case nQtdMed == 8
			nPosArr := _XBR08
		Case nQtdMed == 9
			nPosArr := _XBR09
	OtherWise 
		nPosArr := _XBR10
	EndCase
ElseIf cCartEns == "XBS"
	Do Case
		Case nQtdMed == 1
			nPosArr := _XBS00
		Case nQtdMed == 2
			nPosArr := _XBS00
		Case nQtdMed == 3
			nPosArr := _XBS03
		Case nQtdMed == 4
			nPosArr := _XBS04
		Case nQtdMed == 5
			nPosArr := _XBS05
		Case nQtdMed == 6
			nPosArr := _XBS06
		Case nQtdMed == 7
			nPosArr := _XBS07
		Case nQtdMed == 8
			nPosArr := _XBS08
		Case nQtdMed == 9
			nPosArr := _XBS09
	OtherWise 
		nPosArr := _XBS10
	EndCase
ElseIf cCartEns == "XMR"
	Do Case
		Case nQtdMed == 1
			nPosArr := _XMR00
		Case nQtdMed == 2
			nPosArr := _XMR00
		Case nQtdMed == 3
			nPosArr := _XMR03
		Case nQtdMed == 4
			nPosArr := _XMR04
		Case nQtdMed == 5
			nPosArr := _XMR05
		Case nQtdMed == 6
			nPosArr := _XMR06
		Case nQtdMed == 7
			nPosArr := _XMR07
		Case nQtdMed == 8
			nPosArr := _XMR08
		Case nQtdMed == 9
			nPosArr := _XMR09
	OtherWise 
		nPosArr := _XMR10
	EndCase
ElseIf cCartEns == "HIS"
	Do Case
		Case nQtdMed == 1
			nPosArr := _HIS00
		Case nQtdMed == 2
			nPosArr := _HIS00
		Case nQtdMed == 3
			nPosArr := _HIS03
		Case nQtdMed == 4
			nPosArr := _HIS04
		Case nQtdMed == 5
			nPosArr := _HIS05
		Case nQtdMed == 6
			nPosArr := _HIS06
		Case nQtdMed == 7
			nPosArr := _HIS07
		Case nQtdMed == 8
			nPosArr := _HIS08
		Case nQtdMed == 9
			nPosArr := _HIS09
	OtherWise 
		nPosArr := _HIS10
	EndCase
EndIf

Return nPosArr

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³   Estrutura do vetor aResultados ao executar ao função QP215VOMED          //
//ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ Elemento ³                     Descricao                                 	³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ [1,1]    ³ Operacao	     						 			             	³
//³          ³                    	                                         	³
//³ [1,2]    ³ Laboratorio 	    					 			             	³
//³          ³                    	                                         	³
//³ [1,3]    ³ Ensaio															³
//³ [1,3,01] ³ QP7->QP7_SEQLAB ou QP8->QP8_SEQLAB								³
//³ [1,3,02] ³ QP7_ENSAIO ou QP8_ENSAIO											³
//³ [1,3,03] ³ QP1->QP1_DESCPO													³
//³ [1,3,04] ³ IIF(QP1->QP1_TPCART=="T","TMP",QP1->QP1_CARTA)					³
//³ [1,3,05] ³ QP7_LIE 															³
//³ [1,3,06] ³ QP7->QP7_NOMINA													³
//³ [1,3,07] ³ QP7->QP7_LSE														³
//³ [1,3,08] ³ QP215QtdMed(QP7_ENSAIO ou QP8_ENSAIO)							³
//³ [1,3,09] ³ QP8_TEXTO														³
//³ [1,3,10] ³ cSkpTst															³
//³ [1,3,11] ³ QP7_METODO ou QP8_METODO								 			³
//³ [1,3,12] ³ QA_ULTRVDC(QP7_METODO ou QP8_METODO,dDataBase,.F.,.F.)			³
//³ [1,3,13] ³ QP1_DESCIN  														³
//³ [1,3,14] ³ QP1_DESCES			 											³
//³ [1,3,15] ³ QP7_ENSOBR ou QP8_ENSOBR											³
//³ [1,3,16] ³ QP7_PLAMO ou QP8_PLAMO											³
//³ [1,3,17] ³ QP1_DESCES														³
//³ [1,3,18] ³ lFamVinc															³
//³ [1,3,19] ³ QP1_TIPO == "C"													³
//³ [1,3,20] ³ QP7_FORMUL									 					³
//³ [1,3,21] ³ QP7_MINMAX														³
//³ [1,3,22] ³ Ensaios vinculados ao Ensaio Calculado							³
//³ [1,3,23] ³ Indica se o Ensaio foi Alterado									³
//³          ³																	³
//³ [1,4]    ³ Medicoes (Getdados)												³
//³ [1,5]    ³ Nao-Conformidades (GetDados)										³
//³ [1,6]    ³ Cronicas (Memo)													³
//³ [1,7]    ³ Instrumentos (GetDados)											³
//³ [1,8]    ³ Documentos Anexos(GetDados)										³
//³ [1,9]    ³ Laudo do Laboratorio												³
//³ [1,10]   ³ Laudo da Operacao												³
//³          ³																	³
//³ [2,1]    ³ Laudo Geral da OP (Informações como data,hora,etc				³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
