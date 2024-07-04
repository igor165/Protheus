#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER511.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER511  ³ Autor ³ Microsiga             ³ Data ³ 20/05/05      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Historico de Movimentos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GpeR511(void)                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS      ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Mauricio T. ³25/10/06³-----------|Validacao por Periodo e nao por Competenc.³±± 
±±³Ronan       ³27/03/07³           |Varios acertos em quebras do relatorio.   ³±±
±±³Erika K     ³02/06/08³-----------³Alteracao do nome do pergunte para integra³±±
±±³            ³        ³           ³cao de dicionarios Mexico e R1.2.         ³±±
±±³Marcelo     ³13/06/08³146260     ³Ajuste na picture p/ imprimir corretamente|±±
±±³            ³        ³           ³os totais de cada funcionario.            ³±± 
±±³Kelly       ³30/06/08³148950     ³Ajuste no grupo de perguntas.             |±±
±±³Marcelo     ³29/07/08³146260     ³Varios acertos para imprimir corretamente |±±
±±³            ³        ³           ³no formato horizontal/sintetico para      ³±± 
±±³            ³        ³           ³multiplas filiais, e ajuste de picture.   ³±± 
±±³Marcelo     ³30/09/08³146260     ³Ajustes para imprimir os totais no formato|±±
±±³            ³        ³           ³horizontal (analitico/sintetico) quando o ³±± 
±±³            ³        ³           ³processamento for para multiplas filiais. ³±± 
±±³Mauricio T. ³06/04/09³008093/2009³Ajustes das condicoes com o operador =para³±±
±±³            ³        ³           ³strings. Alterado para ==.                ³±± 
±±³Adilson S.  ³08/09/09³022559/2009³Ajuste no Tamanho da Pergunte Categoria   ³±±
±±³            ³        ³           ³de 15 para 18.                            ³±±
±±³Alex        ³04/01/10³031140/2009³Adaptação para a Gestão Corporativa,      ³±±
±±³            ³        ³           ³respeitar o grupo de campos de filiais.   ³±±
±±³Tiago Malta ³25/07/11³018259/2011³Alterado posicionamento da coluna data.   ³±±
±±³Glaucia M.  ³31/05/12³00013628/12³Ajuste de cabeçalhos na horizontal e ver- ³±±
±±³            ³        ³     TFBHNL³cal.									   ³±±
±±³Jonathan Glz³25/11/16³   MMI-4227³modificacion para Colombia.               ³±±
±±³            ³        ³           ³Se cambia el picture de impresion, pues   ³±±
±±³            ³        ³           ³para valores grandes ponia "*"            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER511()

LOCAL cDesc1 		:= STR0001					//"Relatorio por Codigo"
LOCAL cDesc2 		:= STR0002					//"Ser  impresso de acordo com os parametros solicitados pelo"
LOCAL cDesc3 		:= STR0003					//"usu rio."
LOCAL cString		:="SRA"       				// alias do arquivo principal (Base)
LOCAL aOrd			:={STR0004,STR0005,STR0006}	//"Matricula"###"Centro de Custo"###"Nome"
Local nLin         	:= 80
Local nColRel		:= 38						// Variavel que determina a posicao da coluna da Verba
Local nCont			:= 0
Local lAllVerbas	:= .t.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis PRIVATE(Basicas)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aReturn 	:= {STR0007, 1,STR0008, 1, 2, 1, "", 1}	//"Zebrado"###"Administra‡„o"
PRIVATE nomeprog	:= "GPER511"
PRIVATE aLinha  	:= { },nLastKey := 0
PRIVATE cPerg   	:= "GPR511"
PRIVATE aAC 		:= {STR0009,STR0010}		//"Abandona"###"Confirma"
PRIVATE COLUNAS  	:= 132
PRIVATE nTamanho 	:= "M"
Private nTipo       := 15
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private aSomaTotal	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis PRIVATE(Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nOrdem
PRIVATE aTotais		:=	{}
Private lAbortPrint := .F.
Private lAglutPd    := ( GetMv("MV_AGLUTPD",,"1") == "1" ) // 1-Aglutina verbas   2-Nao Aglutina
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Utilizadas na funcao IMPR                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE titulo
PRIVATE Cabec0		:= ""
PRIVATE Cabec1		:= ""
PRIVATE Cabec2		:= ""
Private cPict1		:=	If(MsDecimais(1)==2,"@E 99,999,999,999.99",TM(99999999999,17,MsDecimais(1)))
Private aRegs		:= {}
Private aVerbas		:= {}	
Private	nTotalGeral	:= 0
Private aTodasVerbas:= {}
PRIVATE	nFilTotalGeral    := 0 
PRIVATE nContFil          := 1
PRIVATE	aFilAtuTotalGeral := {}

Private nProvento	:= 0
Private nDesconto	:= 0
Private nLiquido	:= 0
Private nHorasTotal	:= 0
Private nDiasTotal	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|GPR510  ¦01  ¦Filial De ? 				|
//|GPR510  ¦02  ¦Filial AtT ?               |
//|GPR510  ¦03  ¦Centro de Custo De ?       |
//|GPR510  ¦04  ¦Centro de Custo AtT ?      |
//|GPR510  ¦05  ¦Matricula De ?             |
//|GPR510  ¦06  ¦Matricula AtT ?            |
//|GPR510  ¦07  ¦Nome De ?                  |
//|GPR510  ¦08  ¦Nome AtT ?                 |
//|GPR510  ¦09  ¦Sintetico/Analitico ?		|
//|GPR510  ¦10  ¦Formato ?					|
//|GPR510  ¦11  ¦Salario do Cadastro ?      |
//|GPR510  ¦12  ¦Situat)es a Imp. ?         |
//|GPR510  ¦13  ¦Categorias a Imp. ?        |
//|GPR510  ¦14  ¦Codigos a  Listar ?        |
//|GPR510  ¦15  ¦Cont.Cod. a Listar ?       |
//|GPR510  ¦16  ¦Imprimir Todas as Verbas ? |
//|GPR510  ¦17  ¦Imprimir Totais ?          |
//|GPR510  ¦18  ¦Processo  ?                |
//|GPR510  ¦19  ¦Periodo de ?               |
//|GPR510  ¦20  ¦Pagamento de ?             |
//|GPR510  ¦21  ¦Periodo ate ?              |
//|GPR510  ¦22  ¦Pagamento ate ?            |
//|GPR510  ¦23  ¦Roteiro ?                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte(cPerg,.f.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTit   	:= 	STR0011				//"VALORES POR CODIGO "
wnrel	:=	"GPER511"           //Nome Default do relatorio em Disco

wnrel := SetPrint(cString,wnrel,"GPR511",@cTit,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,nTamanho,,.T.)
If	nLastKey = 27
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FilialDe  	:= mv_par01
FilialAte 	:= mv_par02
CcDe      	:= mv_par03						// Centro de Custo DE
CcAte     	:= mv_par04						// Centro de Custo ATE
MatDe     	:= mv_par05						// Matricula DE
MatAte    	:= mv_par06						// Matricula ATE
NomDe     	:= mv_par07						// Nome DE
NomAte    	:= mv_par08						// Nome ATE
nVerHor   	:= mv_par09						// 1-Vertical ou 2-Horizontal
nSinAna   	:= mv_par10						// Analitico ou Sintetico
lSalario  	:= If(mv_par11==1,.T.,.F.)		// Salario Cadastro
cSituacao 	:= mv_par12						// Situação
cCategoria	:= mv_par13						// Categoria
cCodigos  	:= ALLTRIM(mv_par14)			// Codigos ( Verbas )
cCodigos  	+= ALLTRIM(mv_par15)			// Codigos ( Verbas )
lAllVerbas	:= If(mv_par16==1,.T.,.F.)		// Impressão Todas as Verbas
lImpEmpr   	:= If(mv_par17==1,.T.,.F.)		// Impressão Totais
cProcesso	:= 	mv_par18        			// Processo				C 5
cPerDe		:=	mv_par19        			// Periodo             	C 6
cNPagtoDe	:= 	mv_par20					// numero de pagamento de
cPerAte		:=  mv_par21					// periodo ate 		C 6
cNPagtoAte	:= 	mv_par22					// numero de pagamento de
cRoteiro	:=	mv_par23        			// Imprimir roteiro    	C 3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina para varrer as verbas escolhidas no parametro e atribuir a sua coluna.³
//³Vertical e Horizontal														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCont:= 1 to Len(Alltrim(cCodigos)) Step 3
	Aadd(aVerbas,{Substr(cCodigos,nCont,3),nColRel})
	nColRel:= nColRel + 14
	Aadd(aTodasVerbas,{Substr(cCodigos,nCont,3),0,0})
Next

If nVerHor == 1
	If lAllVerbas
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A finalidade desta rotina é devido a funcao que retorna as verbas em aberto e fechado  ³
		//³que esta sendo usado neste programa, recebe um array com as verbas a serem pesquisadas.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aVerbas	:= {}
		DbSelectArea("SRV")
		DbSetOrder(1)
		DbSeek(xFilial("SRV"))
		While !Eof() .And. SRV->RV_FILIAL == xFilial("SRV")
			Aadd(aVerbas,{SRV->RV_COD,0})
			dbSkip()	
		EndDo
	Endif
Endif

If Empty(aVerbas)
   MsgAlert(STR0037,STR0036)	// "Favor, selecione as verbas ou habilite o parametro de todas as verbas."###"Falta parametro"
   Return
Endif

Aadd(aVerbas,{STR0013,nColRel})		//"Total Liquido"
TITULO := 	STR0012					//"VALORES ACUMULADO POR CODIGO "

If nVerHor == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³nVerHor = 2  relatorio horizontal   ³
	//³Define o máximo de Verbas a listar. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aVerbas) > 13
		Help(" ",1,"VERBA+13")
		Return
	Endif

	cSize   	:= "G"
	nTamanho	:= "G"
	COLUNAS    	:= 220
	nChar		:= 15
	aReturn[4]	:= 1
	Cabec1 		:= Space(20)+STR0014+cProcesso+Space(15)+STR0015+cPerDe+STR0016+cPerAte+Space(15)+STR0017+cNPagtoDe+STR0016+cNPagtoAte+Space(15)+STR0018+cRoteiro
				// "Processo: " +  "Periodo de: " + " Ate: " + "Pagamento de:" + " Ate: " + " Roteiro:"
	Cabec2 		:=	STR0043+space(9 -len(STR0043))+;		//Fil.
					STR0045+space(7 -len(STR0045))+;		//Matr.
					STR0006+space(14-len(STR0006))			//Nome

Elseif nVerHor <> 2  //VERTICAL
	Cabec1 		:= Space(10)+STR0014+cProcesso+Space(05)+STR0015+cPerDe+STR0016+cPerAte+Space(05)+STR0017+cNPagtoDe+STR0016+cNPagtoAte+Space(05)+STR0018+cRoteiro
				// "Processo: " +  "Periodo de: " + " Ate: " + "Pagamento de:" + " Ate: " + " Roteiro:"
	Cabec2 		:=	STR0043+space(9 -len(STR0043))+;		//Fil.
					STR0044+space(16-len(STR0044))+;		//C.C.
					STR0045+space(11-len(STR0045))+;		//Matr.
					STR0006+space(9 -len(STR0006))+;		//Nome
					STR0048+space(10-len(STR0048))+;		//Periodo
					STR0049+space(12-len(STR0049))+;		//Mes/Ano Ref
					STR0050+space(7 -len(STR0050))+;		//Cod.
					STR0051+space(20-len(STR0051))+;		//Descr.
					STR0052+space(14-len(STR0052))+;		//Referencia
					STR0053+space(12-len(STR0053))+;		//Valor
					STR0047									//Dt. Pagto.
	Aadd(aSomaTotal ,{0,0,0})
Endif

If nLastKey = 27
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Passa parametros de controle da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,cString,,,nTamanho)
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER511   ºAutor  ³Microsiga           º Data ³  15/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis de Acesso do Usuario                               ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local lPass			:= .t.
Local cVerbaStatus  := ""
Local cDescrVerbas	:= ""
Local _cTpVerba		:= ""
Local cDescVerba	:= ""
Local cDescCentro	:= ""
Local nCont			:= 0
Local nContX		:= 0
Local dDataAnt
Local nExist		:= 0
Local nSalFunc		:= 0
Local aSubFunc		:= {}	
Local _dDataComp	:= cTod("01/01/1900")
Local _cPerAnt		:= ""
Local nSVProv		:= 0 	
Local nSVDesc		:= 0 
Local nSVHoras		:= 0	
Local nSVDias		:= 0
Local cDtRef		:= ""
Local cSvPer 		:= ""
Local cMatPer		:= ""
Local nNumFils 		:= ""  
Local cDescFil   	:= ""   

Private _cFilialAnt		:= ""
Private cCCusto 		:= ""
Private nVlrHoras		:= 0
Private nVlrTotal		:= 0
Private	nHorasTipo		:= 0
Private nDiasTipo		:= 0
Private nVlTotEmp		:= 0
Private nOrd 			:= 1
Private nSBHoras		:= 0
Private nSBSalario 		:= 0
Private nPosVerba		:= 0 
Private nPos			:= 0 
Private nSubLinha		:= 0
Private nVlCCHr			:= 0 
Private nVlCCVl 		:= 0
Private nPosVA 			:= 0
Private nRefVertSint	:= 0
Private nVlrVertSint	:= 0
Private nValorProvento	:= 0
Private nValorDesconto	:= 0  
Private nNextReg        := 0  
Private aVerbasRet		:= {}
Private aFilHorAnalSint	:= {}
Private aPerFechado		:= {}
Private aPerAberto		:= {}
Private aVerbasVAnalit	:= {}
Private aVertSintCC		:= {}
Private aVerVertSint	:= {}
Private aInfo           := {}
Private aAuxFilHorAnalSint	:= {}
Private lRegAux             := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³--Salvar Ordem Selecionada SETPRINT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOrdem    := aReturn[8]
dbSelectArea("SRA")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a ordem do Index que será usada pelo o SRA.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOrdem == 1
	SRA->( DbSetOrder( Retorder( "SRA" , "RA_FILIAL+RA_MAT" ) ) )
	dbSeek(FilialDe + MatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_MAT"
	cFim     := FilialAte + MatAte
ElseIf nOrdem == 2
	SRA->( DbSetOrder( Retorder( "SRA" , "RA_FILIAL+RA_CC+RA_MAT" ) ) )
	dbSeek(FilialDe + CcDe + MatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
	cFim     := FilialAte + CcAte + MatAte
ElseIf nOrdem == 3
	SRA->( DbSetOrder( Retorder( "SRA" , "RA_FILIAL+RA_NOME+RA_MAT" ) ) )
	dbSeek(FilialDe + NomDe + MatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
	cFim     := FilialAte + NomAte + MatAte
Endif

cFilAnterior := Replicate("!", FwGetTamFilial)
cCcAnt  := "!!!!!!!!!"

Cabec2	:= IIF(nVerHor == 2, Cabec2 + STR0046+Space(11-len(STR0046)),Cabec2)

If nVerHor == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o cabeçalho(descricao) do relatorio Horizontal.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDescrVerbas 	:= 	""
	For nCont:= 1 to Len(aVerbas)
		If nCont < Len(aVerbas)
			cDescrVerbas  := aVerbas[nCont][1] + "-"+DescPd(aVerbas[nCont][1],SRA->RA_FILIAL,10)+Space(01)
		Else
			cDescrVerbas  := aVerbas[nCont][1]
		Endif
		Cabec2	:= Cabec2 + cDescrVerbas
	Next
Endif

dbSelectArea("SRA")
SetRegua(SRA->(RecCount()))
_cFilialAnt	:= SRA->RA_FILIAL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Esta função busca todos os periodos em aberto e fechado dos funcionarios.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetPerAbertFech(cProcesso,cRoteiro,cPerDe,cNPagtoDe,cPerAte,cNPagtoAte,@aPerAberto,@aPerFechado)

If Empty(aPerAberto) .And. Empty(aPerFechado)
   MsgAlert(STR0038,STR0039)	//"Periodo informado no existe!"###"Atencao!"
   Return
Endif

While !Eof() .And. &cInicio <= cFim
	IncRegua()
	
	If lAbortPrint
		@nLin,00 PSAY STR0022		// "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If SRA->RA_FILIAL < FilialDe .Or. SRA->RA_FILIAL > FilialAte
		dbSkip()
		Loop
	Endif
	
	If (SRA->RA_NOME < NomDe)  .Or. (SRA->RA_NOME > NomAte) .Or. ;
		(SRA->RA_MAT < MatDe)  .Or. (SRA->RA_MAT > MatAte)  .Or. ;
		(SRA->RA_CC < CcDe)    .Or. (SRA->RA_CC > CcAte)
		dbSkip()
		Loop
	EndIf
	
	If !( SRA->RA_SITFOLH $ cSituacao ) .OR.  !( SRA->RA_CATFUNC $ cCategoria )
		dbSkip()
		Loop
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin >= 70
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,nTamanho,nTipo)
		nLin := 8
	Endif

	aVerbasRet:= RetornaVerbasFunc(SRA->RA_FILIAL,SRA->RA_MAT,,cRoteiro,aVerbas,aPerAberto,aPerFechado)

	If Len(aVerbasRet) == 0
		dbSelectArea("SRA")
		dbSkip()
		loop
	EndIf

	If nVerHor == 2 .And. nSinAna == 2
		aVerbasRet := aSort( aVerbasRet ,,, { |x,y| + x[ 10 ] + x[ 3 ] + x[ 15 ] > y[ 10 ] + y[ 3 ] + y[ 15 ] } )
	Else
		//Ordena por Filial/Matricula/Verba/Periodo/Num.Pago
	    aVerbasRet := aSort( aVerbasRet ,,, { |x,y| x[1] + x[2] + x[3]+ x[10] + x[8] < y[1] + y[2] + y[3]+y[10]+ y[8] } )	
	EndIf

	nSubLinha	:=	0
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Relatorio Horizontal nVerHor = 2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nVerHor == 2
		dDataAnt	:= aVerbasRet[1][13]
		nSalFunc	:= fBuscaSal(dDataAnt,,,.f.)

		If nSinAna == 2 // Horizontal - Analitico
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³nSinAna = 2  relatorio  Analitico³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			nLin++
			ExecCab(@nLin)

			//verificar se eh de outra filial, fazer a quebra
			If _cFilialAnt<>SRA->RA_FILIAL

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega Informacoes da Empresa que esta sendo impressa       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				fInfo(@aInfo,_cFilialAnt)
				cDescFil	:= PadR(aInfo[2],20)			
			
				@ ++nLIn,00 Psay _cFilialAnt + " - " + Alltrim( cDescFil )
				ExecCab(@nLin)

				For nCont:= 1 to len(aFilHorAnalSint)
					@nLin,aFilHorAnalSint[nCont][4] Psay aFilHorAnalSint[nCont][3]  Picture cPict1
				Next					

				If !Empty( aFilAtuTotalGeral ) .And. nContFil <= Len( aFilAtuTotalGeral )
					nFilTotalGeral := aFilAtuTotalGeral[ nContFil ][2]
					nContFil ++
				EndIf

				//-->Nao imprimir valores negativos
				If nFilTotalGeral <= 0
					nFilTotalGeral := 0
				EndIf
				
				@nLin,aVerbas[Len(aVerbas)][2] Psay nFilTotalGeral  Picture cPict1

				@ ++nLin,00 Psay Replicate("=",Iif(nVerHor==1,132,220))
				ExecCab(@nLin)
				nLin++        
				ExecCab(@nLin)
				
				aFilHorAnalSint	   := {}		//-->Limpa o array principal
				
			Endif
		Endif
        // ordenar o aVerbasret
		aSubFunc	:= {}
		lIgual		:= .F.
		cVrbAnt		:= Space(03)
		ImpFunc		:= .T.
		lIgualData  := .F.      
		cDatAnt		:= "" 
		cVerbas     := ""
		
		For nCont:= 1 to len(aVerbasRet)
			
			lIgual     := (cVrbAnt==aVerbasRet[nCont,3]) .And. (nCont>1)
			lIgualData := (cDatAnt==aVerbasRet[nCont,10]) .And. (nCont>1)
			cVrbAnt    := Iif(!lIgual,aVerbasRet[nCont,3], cVrbAnt)	
			cDatAnt    := IIf(!lIgualData,aVerbasRet[nCont,10], cDatAnt)
				
			nPosVerba	:= Ascan(aVerbas,{ |x| x[1] == aVerbasRet[nCont,3] } )
			If nPosVerba == 0
				Loop
			Endif							

		  	If nSinAna == 2 // Analitico
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Horizontal e Analitico, Impressao dos valores das   ³
				//³  verbas em coluna pre estabelecida no aVerbas.      ³				
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Dtos(aVerbasRet[nCont,13]) <> Dtos(_dDataComp) .Or. ImpFunc
					dDataAnt	:= aVerbasRet[nCont,13]

				 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Imprimir numa unica linha os valores de cada verba  ³
					//³ que houver no mes. Quebra se a verba for igual.     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lIgualData 
						If Alltrim( aVerbasRet[nCont,3] ) $ cVerbas
							nLin++ 
							cVerbas := ""
							cVerbas += aVerbasRet[nCont,3] + "#"
						Else
							cVerbas += aVerbasRet[nCont,3] + "#"
						EndIf
					Else
						If nCont > 1
							nLin++ 
							cVerbas := ""
							cVerbas += aVerbasRet[nCont,3] + "#"
						Else
							cVerbas += aVerbasRet[nCont,3] + "#"
						EndIf
					EndIf
						
					ExecCab(@nLin)

					@nLin,00 Psay SRA->RA_FILIAL+" "+SRA->RA_MAT+"-"+Substr(SRA->RA_NOME,1,13) //22 
				   	@nLin,30 Psay Substr(MesAno(dDataAnt),5,2)+"/"+Substr(MesAno(dDataAnt),1,4)
				Endif
                
				// valor da verba
			   	@nLin,aVerbas[nPosVerba,2] Psay aVerbasRet[nCont,7]  Picture cPict1

				nPos	:= Ascan(aSubFunc,{ |x| x[1] == aVerbasRet[nCont,3] } )
				IF nPos == 0
					// quebra por funcionario // verba, coluna , valor 
					Aadd(aSubFunc,{aVerbas[nPosVerba,1],aVerbas[nPosVerba,2],aVerbasRet[nCont,7]})	
				Else
					aSubFunc[nPos,3] := aSubFunc[nPos,3] + aVerbasRet[nCont,7]
				Endif
				_dDataComp	:= aVerbasRet[nCont,13]
			Endif
            
			_cTpVerba 	:= PosSrv( aVerbasRet[nCont,3],SRA->RA_FILIAL,"RV_TIPOCOD" )
			
			If _cTpVerba == "1"
				nSubLinha  += aVerbasRet[nCont,7]
				nTotalGeral+= aVerbasRet[nCont,7]
			ElseIf _cTpVerba == "2"
				nSubLinha  -= aVerbasRet[nCont,7]
				nTotalGeral-= aVerbasRet[nCont,7]
			Endif
			
			//-->Guarda o total da filial que esta sendo processada      
			If Len( aFilAtuTotalGeral ) > 0
				nFilExist := Ascan( aFilAtuTotalGeral, { |x| x[1] == SRA->RA_FILIAL } )			
				If nFilExist > 0 .And. _cTpVerba == "1"
					aFilAtuTotalGeral[nFilExist,2] := aFilAtuTotalGeral[nFilExist,2] + aVerbasRet[nCont,7]
				ElseIf nFilExist > 0 .And. _cTpVerba == "2"					
					aFilAtuTotalGeral[nFilExist,2] := aFilAtuTotalGeral[nFilExist,2] - aVerbasRet[nCont,7]
				ElseIf _cTpVerba == "1"
					aAdd( aFilAtuTotalGeral, { SRA->RA_FILIAL, aVerbasRet[nCont,7] } )
				EndIf
			Else   
				If _cTpVerba == "1" .Or. _cTpVerba == "2"
					aAdd( aFilAtuTotalGeral, { SRA->RA_FILIAL, aVerbasRet[nCont,7] } )
				EndIf
			EndIf

			nExist   := Ascan(aSomaTotal,{ |x| x[1] == aVerbasRet[nCont,3] } )			 
			
			//-->Se o array auxiliar tiver sido adicionado, procurar a verba neste array
			If lRegAux
				nPosVerb := Ascan(aAuxFilHorAnalSint,{ |x| x[1]+x[2] == aVerbasRet[nCont,1] + aVerbasRet[nCont,3] } )
			Else                                                                                                  
				nPosVerb := Ascan(aFilHorAnalSint,{ |x| x[1]+x[2] == aVerbasRet[nCont,1] + aVerbasRet[nCont,3] } )				
			EndIf
					
			IF nExist == 0 .And. nPosVerb == 0
				// numero da verba, valor da verba, posicao da coluna a ser impressa

				Aadd(aSomaTotal,{aVerbasRet[nCont,3],aVerbasRet[nCont,7],aVerbas[nPosVerba,2]})

				If _cFilialAnt == SRA->RA_FILIAL
					Aadd(aFilHorAnalSint,{SRA->RA_FILIAL,aVerbasRet[nCont,3],aVerbasRet[nCont,7],aVerbas[nPosVerba,2]})
				Endif
			
			Else
			
				aSomaTotal[nExist,2]:= aSomaTotal[nExist,2] + aVerbasRet[nCont,7]
				 
				If _cFilialAnt == SRA->RA_FILIAL 

					//-->Se o registro existente no array for da mesma filial o valor eh somado, caso contrario adiciona
					If nExist > 0 .And. nPosVerb > 0 .And. !lRegAux
						aFilHorAnalSint[nPosVerb,3]:= aFilHorAnalSint[nPosVerb,3] + aVerbasRet[nCont,7]
					Else
						Aadd(aFilHorAnalSint,{SRA->RA_FILIAL,aVerbasRet[nCont,3],aVerbasRet[nCont,7],aVerbas[nPosVerba,2]})
					EndIf    
					
				Else 								   
						//-->Se o array auxiliar tiver a verba pesquisada o valor eh somado ao registro existente
						If lRegAux .And. nPosVerb > 0     
							aAuxFilHorAnalSint[nPosVerb,3]:= aAuxFilHorAnalSint[nPosVerb,3] + aVerbasRet[nCont,7]
						Else					                                                                      
						//-->Se a verba pesquisada nao pertence a filial atual, adiciona no array auxiliar
						Aadd(aAuxFilHorAnalSint,{SRA->RA_FILIAL,aVerbasRet[nCont,3],aVerbasRet[nCont,7],aVerbas[nPosVerba,2]})
						nNextReg := nNextReg + 1
						lRegAux := .T.
						EndIf
					
				Endif
				
			Endif
		
		Next
		
		lRegAux := .F.

			If nSinAna == 1 // Sintetico
				If _cFilialAnt<>SRA->RA_FILIAL
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega Informacoes da Empresa que esta sendo impressa       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				fInfo(@aInfo,_cFilialAnt)
				cDescFil	:= PadR(aInfo[2],20)
			
				@ ++nLIn,00 Psay _cFilialAnt + " - " + Alltrim( cDescFil )
				ExecCab(@nLin)
				
				For nContX:= 1 to len(aFilHorAnalSint)
					If aFilHorAnalSint[nContX][1] == _cFilialAnt
						@nLin,aFilHorAnalSint[nContX][4] Psay aFilHorAnalSint[nContX][3]  Picture cPict1
					Endif
				Next
				          
				If !Empty( aFilAtuTotalGeral ) .And. nContFil <= Len( aFilAtuTotalGeral )
					nFilTotalGeral := aFilAtuTotalGeral[nContFil][2]
					nContFil ++                                  
				EndIf

				//-->Nao imprimir valores negativos
				If nFilTotalGeral <= 0
					nFilTotalGeral := 0
				EndIf
				
				@nLin,aVerbas[Len(aVerbas)][2] Psay nFilTotalGeral Picture cPict1 //"@E 9,999,999.99"
				          
				aFilHorAnalSint	:= {}		//-->Limpa o array principal
				aFilHorAnalSint := aClone(aAuxFilHorAnalSint)		//-->Adiciona os itens do array auxiliar
				aAuxFilHorAnalSint := {}		//-->Limpa o array auxiliar
					
			Endif
		Endif
			
		If nSinAna == 2  // Horizontal e Analitico
			
			nLin++
			ExecCab(@nLin)
			If lSalario
				@nLin,00 Psay STR0023		//"Salario Base:"
				@nLin,13 Psay nSalFunc Picture cPict1
				nLin++
				ExecCab(@nLin)
			Endif

			aSubFunc 	:= ASort(aSubFunc,,,{|x,y| x[1] < y[1] })

			@nLin,00 Psay STR0024 		//"Total do Funcionário "
			For nCont:= 1 to len(aSubFunc)	
				@nLin,aSubFunc[nCont][2] Psay aSubFunc[nCont][3]  Picture cPict1
			Next

			@++nLin,00 Psay Replicate("-",Iif(nVerHor==1,132,220))
			ExecCab(@nLin)
			nLin++
		Endif

	ElseIf nVerHor == 1  // Vertical
			
			nSBHoras	:= nSBHoras 	+ SRA->RA_HRSMES
			nSBSalario	:= nSBSalario 	+ SRA->RA_SALARIO

			If lPass
				cCCusto	:= SRA->RA_CC
			Endif
			
			If nSinAna == 2  // Vertical e Analitico
				If !lPass
					If (nValorProvento-nValorDesconto) <> 0
						@nLin,00 Psay STR0025			//"Valores Totais  - "
					Endif
					If nHorasTipo > 0
						@nLin,21 Psay STR0026    	// "Horas:"
						@nLin,27 Psay nHorasTipo Picture "@E 9999.99"
					Endif
					If nDiasTipo > 0
						@nLin,34 Psay STR0027		//"Dias:"
						@nLin,39 Psay nDiasTipo Picture "@E 99999"
					Endif
					If nValorProvento>0
						@nLin,45 Psay Substr(STR0028,1,10)		// "Provento:"
						@nLin,55 Psay nValorProvento Picture "@E 999,999,999.99"
					Endif
					If nValorDesconto>0
						@nLin,76 Psay STR0029		//"Desconto:"
						@nLin,86 Psay nValorDesconto Picture "@E 999,999,999.99"
					EndIf
					If (nValorProvento-nValorDesconto) <> 0
						@nLin,105 Psay STR0030		//"Liquido:"
						@nLin,113 Psay (nValorProvento-nValorDesconto) Picture "@E 999,999,999.99"
					Endif

					// Variaveis Totais do SubTotal					
					// Total Geral
					nSVProv			:= 	nSVProv + nValorProvento
		            nSVDesc			:= 	nSVDesc + nValorDesconto
		            nSVHoras		:=	nSVHoras + nHorasTipo
		            nSVDias			:= 	nSVDias + nDiasTipo

					// Zerando as variaveis dos valores totais
					nValorProvento	:= 	nValorDesconto	:= 	nHorasTipo	:= 	nDiasTipo	:= 0
					
					If (Alltrim(cCCusto) <> Alltrim(SRA->RA_CC)) .Or. (_cFilialAnt <> SRA->RA_FILIAL) 
						@++nLin,00 Psay Replicate("-",Iif(nVerHor==1,132,220))
						ExecCab(@nLin)
						@++nLin,00 Psay STR0031+Alltrim(cCCusto)		//"Total C.Custo:"
						ExecCab(@nLin)
			
						If nSVHoras > 0
							@nLin,027 Psay STR0026		//"Horas:"
							@nLin,033 Psay nSVHoras Picture "@E 9999.99"
						Endif
						If nSVDias > 0
							@nLin,041 Psay STR0027		//"Dias:"
							@nLin,046 Psay nSVDias Picture "@E 99999"
						Endif
			
						If nSVProv>0
							@nLin,051 Psay Substr(STR0028,1,9)		//"Provento:"
							@nLin,060 Psay nSVProv Picture "@E 999,999,999.99"
						Endif
						If nSVDesc>0
							@nLin,078 Psay STR0029		//"Desconto:"
							@nLin,088 Psay nSVDesc Picture "@E 999,999,999.99"
						EndIf
						
						If (nSVProv - nSVDesc) <> 0
							@nLin,105 Psay STR0030		//"Liquido:"
							@nLin,113 Psay (nSVProv - nSVDesc)  Picture "@E 999,999,999.99"
						Endif			

						nSVProv:= nSVDesc:=	nSVHoras:= nSVDias:=  0

						@++nLin,00 Psay Replicate("=",Iif(nVerHor==1,132,220))
						ExecCab(@nLin)
						cCCusto	:= SRA->RA_CC
					Endif
				Endif

				nLin++                
				ExecCab(@nLin)
				dbSelectArea("SRA")
				// Impressao da linha de detalhe do relatorio
				@nLin,00 Psay SRA->RA_FILIAL+" "+cCCusto
				@nLin,25 Psay aVerbasRet[1][2]+" - "		// matricula
				@nLin,36 Psay Substr(SRA->RA_NOME,1,30)	// nome

				If lSalario // Parametro 15 - impressao Salario Base
					@nLin,070 Psay STR0023		//"Salario Base"
					@nLin,093 Psay SRA->RA_HRSMES	Picture "@E 999,999.99"
					@nLin,107 Psay SRA->RA_SALARIO 	Picture "@E 999,999.99"
				Endif
				nLin++        
				ExecCab(@nLin)
			Else // Vertical e Sintetico

				If aReturn[8] == 2 	// Vertical / Sintetico / Ordem de C.Custo          

					If Alltrim(cCCusto) <> Alltrim(SRA->RA_CC) .Or. _cFilialAnt <> SRA->RA_FILIAL 
						aVertSintCC:= ASort(aVertSintCC,,,{ |a,b| a[1]+a[2] < b[1]+b[2] })
						
						For nCont:= 1 to Len(aVertSintCC)
							If nCont > 1       
								nLin+=2      
								ExecCab(@nLin)
								@ nLIn++,00 Psay Replicate("-",Iif(nVerHor==1,132,220))
								ExecCab(@nLin)
							Endif

							cCentroCusto	:= aVertSintCC[nCont][1]
							cDescCentro		:= DescCC(cCentroCusto,xFilial("SRA"),25)

							@ nLIn,00 Psay _cFilialAnt+" "+aVertSintCC[nCont][1]
							@ nLIn,25 Psay  "- "+cDescCentro

							While !nCont>Len(aVertSintCC) .And. aVertSintCC[nCont][1] == cCentroCusto
								cDescVerba	:= PosSrv( aVertSintCC[nCont][2] , SRA->RA_FILIAL , "RV_DESC" )
								@ nLIn,67 Psay aVertSintCC[nCont][2]+"-"
								@ nLIn,73 Psay Substr(cDescVerba,1,17)
								
								@ nLIn,093 Psay aVertSintCC[nCont][3] 	Picture "@E 999,999.99"
								@ nLIn,107 Psay aVertSintCC[nCont][4] 	Picture "@E 999,999.99"
								
								nVlCCHr		:= nVlCCHr + aVertSintCC[nCont][3]
								nVlCCVl		:= nVlCCVl + aVertSintCC[nCont][4]
						
								// Totalizador de empresa
								If lImpEmpr
									nRefVertSint	:= nRefVertSint + aVertSintCC[nCont][3]
									nVlrVertSint	:= nVlrVertSint + aVertSintCC[nCont][4]
								Endif	
		
								nLIn++
								ExecCab(@nLin)
								nCont++
							EndDo
							nLIn+= 2
							ExecCab(@nLin)
							
							@ nLIn,00 Psay STR0032+cCentroCusto   //"Total do Centro de Custo "
							@ nLIn,093 Psay nVlCCHr Picture "@E 9999.99"
							@ nLIn,107 Psay nVlCCVl Picture "@E 999,999.99"
							
							nVlCCHr		:= 0
							nVlCCVl		:= 0
							
							nLIn++
							ExecCab(@nLin)
							nCont--

						Next
						@ nLIn++,00 Psay Replicate("=",Iif(nVerHor==1,132,220))
						ExecCab(@nLin)
                        aVertSintCC	:= {}
                    Endif

					For nCont:= 1 to Len(aVerbasRet)
						nPosVerba	:= Ascan(aVertSintCC,{ |x| x[1] == SRA->RA_CC .And. x[2] == aVerbasRet[nCont][3] } )
						IF nPosVerba == 0
												//centro de custo,verba,valor em referencia,valor da horas
							Aadd(aVertSintCC,{SRA->RA_CC,aVerbasRet[nCont][3],aVerbasRet[nCont][6],aVerbasRet[nCont][7]})
						Else
							aVertSintCC[nPosVerba][3]:= aVertSintCC[nPosVerba][3] + aVerbasRet[nCont][6]
							aVertSintCC[nPosVerba][4]:= aVertSintCC[nPosVerba][4] + aVerbasRet[nCont][7]
						Endif
					Next

				Else
					If _cFilialAnt <> SRA->RA_FILIAL
						nLIn++                                                       
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Carrega Informacoes da Empresa que esta sendo impressa       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						fInfo(@aInfo,_cFilialAnt)
						cDescFil	:= PadR(aInfo[2],20)						
						
						@ nLIn,00 Psay _cFilialAnt + " - " + Alltrim( cDescFil )
						If lSalario
							@ nLIn,070 Psay STR0023		//"Salário Base"
							@ nLIn,093 Psay nSBHoras Picture   "@E 9999,999.99"
							@ nLIn,107 Psay nSBSalario Picture "@E 9999,999.99"
							nLIn++
							ExecCab(@nLin)
						Endif
					
						ASort(aVerVertSint,,,{ |a,b| a[1] < b[1] })
						nVlrHoras := nVlrTotal := 0
						For nCont:= 1 to Len(aVerVertSint)
							If Empty(aVerVertSint[nCont][1] )
								loop
							Endif
							@ nLIn,67 Psay aVerVertSint[nCont][1] + "-"
							@ nLIn,73 Psay Alltrim(aVerVertSint[nCont][2])
							@ nLIn,093 Psay aVerVertSint[nCont][3] Picture "@E 9999,999.99"
							@ nLIn,107 Psay aVerVertSint[nCont][4] Picture "@E 9999,999.99"
							nLIn++
							ExecCab(@nLin)
							nVlrHoras	:= nVlrHoras + aVerVertSint[nCont][3]
				
							_cTpVerba 	:= PosSrv( aVerVertSint[nCont][1] , SRA->RA_FILIAL , "RV_TIPOCOD" )
							If _cTpVerba	== "1" // provento
								nVlrTotal	:= nVlrTotal + aVerVertSint[nCont][4]
							ElseIf _cTpVerba	== "2" // desconto
								nVlrTotal	:= nVlrTotal - aVerVertSint[nCont][4]			
							Endif
						Next
						
						@ nLIn++,00 Psay Replicate("-",Iif(nVerHor==1,132,220))
						ExecCab(@nLin)
						@ nLin,00 Psay STR0033	+ _cFilialAnt		//"Total da Filial "
						@ nLIn,093 Psay nVlrHoras Picture "@E 9999,999.99"
						@ nLIn++,107 Psay nVlrTotal Picture "@E 9999,999.99"
						ExecCab(@nLin)
						@ nLIn,00 Psay Replicate("=",Iif(nVerHor==1,132,220))
						aVerVertSint	:= {}
					Endif
		
					For nCont:= 1 to Len(aVerbasRet)// somatorio do Vertica Sintetico ordem normal
						nExist := Ascan(aVerVertSint,{ |x| Alltrim(x[1]) == Alltrim(aVerbasRet[nCont][3]) } )
						IF nExist == 0 .Or. !lAglutPd
							cDescrVerbas :=	PosSrv(aVerbasRet[nCont][3],aVerbasRet[nCont][1], "RV_DESC" )
							// numero da verba     , descricao,qtde referencia,valor verba
							Aadd(aVerVertSint,{aVerbasRet[nCont][3],Substr(cDescrVerbas,1,20),aVerbasRet[nCont][6],aVerbasRet[nCont][7]})
						Else
							aVerVertSint[nExist][3]:= aVerVertSint[nExist][3] + aVerbasRet[nCont][6]
							aVerVertSint[nExist][4]:= aVerVertSint[nExist][4] + aVerbasRet[nCont][7]
						Endif
						// Totalizador de empresa
						If lImpEmpr
							nRefVertSint	:= nRefVertSint + aVerbasRet[nCont][6]
							nVlrVertSint	:= nVlrVertSint + aVerbasRet[nCont][7]
						Endif	
					Next				
				Endif			
			Endif

			If nSinAna == 2 	// Analitico
				For nCont:=1 to Len(aVerbasRet)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Impressao do cabecalho do relatorio. . .                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ExecCab(@nLin)
					If cSvPer <> aVerbasRet[nCont][10] + aVerbasRet[nCont][08] .Or. cMatPer <> aVerbasRet[nCont][2] 
						@nLin,45 Psay aVerbasRet[nCont][10]
						@nLin,52 Psay aVerbasRet[nCont][08]
						@nLin,56 Psay Substr(MesAno(aVerbasRet[nCont][13]),5,2)+"/"+Substr(MesAno(aVerbasRet[nCont][13]),1,4)
                    Endif
                    cSvPer := aVerbasRet[nCont][10] + aVerbasRet[nCont][08]
                    cDtRef	:= aVerbasRet[nCont][13]
                    cMatPer	:= aVerbasRet[nCont][2]
                    // impressao do detalhe do analitico
					@nLin,067 Psay aVerbasRet[nCont][3]+" - " + DescPd(aVerbasRet[nCont][3],aVerbasRet[nCont][1],20)
					@nLin,093 Psay aVerbasRet[nCont][6]  	Picture "@E 999,999.99"
					@nLin,105 Psay aVerbasRet[nCont][7]		Picture "@E 9,999,999.99"

					@nLin,120 Psay aVerbasRet[nCont][13]

					nPosVA := Ascan(aVerbasVAnalit,{ |x| x[1] == aVerbasRet[nCont][3] } )
					If nPosVA == 0
						//Array usado para mostrar a quebra por Verbas. Vertical Analitico S/C.C.	
											// codigo da verba,descricao da verba,valor da referencia,valor 
						Aadd(aVerbasVAnalit,{aVerbasRet[nCont][3],DescPd(aVerbasRet[nCont][3],aVerbasRet[nCont][1],20),aVerbasRet[nCont][6],aVerbasRet[nCont][7]})
					Else					
						aVerbasVAnalit[nPosVA][3]	:= aVerbasVAnalit[nPosVA][3] + aVerbasRet[nCont][6]
						aVerbasVAnalit[nPosVA][4]	:= aVerbasVAnalit[nPosVA][4] + aVerbasRet[nCont][7]
					Endif
					
					cVerbaStatus:= 	PosSrv(aVerbasRet[nCont][3],aVerbasRet[nCont][1], "RV_TIPO" ) 	//== "H" - Horas  D - Dias

					_cTpVerba 	:= PosSrv( aVerbasRet[nCont][3],SRA->RA_FILIAL,"RV_TIPOCOD" )
					If _cTpVerba	== "2" // desconto
						nValorDesconto	:= nValorDesconto + aVerbasRet[nCont][7]
					ElseIf _cTpVerba	== "1" // provento
						nValorProvento	:= nValorProvento + aVerbasRet[nCont][7]
					Endif

					If cVerbaStatus == "H"
						nHorasTipo	:= 	nHorasTipo + aVerbasRet[nCont][6]
					ElseIf cVerbaStatus == "D"
						nDiasTipo	:= 	nDiasTipo + aVerbasRet[nCont][6]
					Endif


					If lImpEmpr .And. _cPerAnt<>MesAno(aVerbasRet[nCont][10]) .And. nCont > 1	//  .And. nCont > 1
						If (nValorProvento-nValorDesconto) <> 0
							@++nLin,00 Psay STR0025		//"Valores Totais  - "
							ExecCab(@nLin)
                        Endif

						If nHorasTipo > 0
							@nLin,21 Psay STR0026		//"Horas:"
							@nLin,27 Psay nHorasTipo Picture "@R 9999.99"
							nHorasTotal	:= nHorasTotal + nHorasTipo
						Endif
						If nDiasTipo > 0
							@nLin,34 Psay STR0027	//"Dias:"
							@nLin,39 Psay nDiasTipo Picture "@E 99999"
							nDiasTotal	:= nDiasTotal + nDiasTipo
						Endif
			
						If nValorProvento>0
							@nLin,45 Psay Substr(STR0028,1,10)	//"Provento:"
							@nLin,55 Psay nValorProvento Picture "@E 999,999,999.99"
							nProvento	:= nProvento + nValorProvento
						Endif
						If nValorDesconto>0
							@nLin,76 Psay STR0029	//"Desconto:"
							@nLin,86 Psay nValorDesconto Picture "@E 999,999,999.99"
							nDesconto	:= nDesconto + nValorDesconto
						EndIf
						If (nValorProvento-nValorDesconto) <> 0
							@nLin,105 Psay 	STR0030	//"Liquido:"
							@nLin,113 Psay ( nValorProvento-nValorDesconto) Picture "@E 999,999,999.99"
							nLiquido	:= 	(nValorProvento-nValorDesconto)
						Endif
						nHorasTipo :=nDiasTipo:=nValorProvento:=nValorDesconto	:= 0					
						@++nLin,00 Psay Replicate("-",Iif(nVerHor==1,132,220))
						ExecCab(@nLin)
					EndIf

					nLin++            
					ExecCab(@nLin)
					_cPerAnt := MesAno(aVerbasRet[nCont][10])				
				Next

				nSVProv			:=  nSVProv + nProvento
			    nSVDesc			:=  nSVDesc + nDesconto
			    nSVHoras		:=	nSVHoras + nHorasTotal
			    nSVDias			:= 	nSVDias + nDiasTotal			
			Endif			
			lPass	:= .f.
	Endif
	
	If Len(aVerbasRet) > 0
		cCCusto := SRA->RA_CC
	Endif

	_cFilialAnt	:= SRA->RA_FILIAL	
	dbSelectArea("SRA")
	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do SubTotal  e o Total de Empresa. quando o flag estiver para imprimir    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nVerHor == 2
	// horizontal e Analitico
		If nSinAna == 2
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega Informacoes da Empresa que esta sendo impressa       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fInfo(@aInfo,_cFilialAnt)
			cDescFil	:= PadR(aInfo[2],20)		
		
			@++nLIn,00 Psay _cFilialAnt + " - " + Alltrim( cDescFil )
			ExecCab(@nLin)
			If !Empty( aAuxFilHorAnalSint )
				For nCont:= 1 to Len(aAuxFilHorAnalSint)
					@nLin,aAuxFilHorAnalSint[nCont,4] Psay aAuxFilHorAnalSint[nCont,3]  Picture cPict1
				Next
			Else    
				For nCont:= 1 to Len(aFilHorAnalSint)
					@nLin,aFilHorAnalSint[nCont,4] Psay aFilHorAnalSint[nCont,3]  Picture cPict1
				Next
			EndIf			
			
			If !Empty( aFilAtuTotalGeral ) .And. nContFil <= Len( aFilAtuTotalGeral )
				nFilTotalGeral := aFilAtuTotalGeral[nContFil][2]
				nContFil ++                                  				
			EndIf                                   
			
			//-->Nao imprimir valores negativos
			If nFilTotalGeral <= 0
				nFilTotalGeral := 0
			EndIf

			@nLin,aVerbas[Len(aVerbas),2] Psay nFilTotalGeral Picture cPict1
			
			@++nLin,00 Psay Replicate("=",Iif(nVerHor==1,132,220))
			ExecCab(@nLin)

			If lImpEmpr
				@++nLIn,00 Psay STR0034		//"Valor total Empresa:"
				ExecCab(@nLin)
				For nCont:= 1 to len(aSomaTotal)
					@nLin,aSomaTotal[nCont,3] Psay aSomaTotal[nCont,2]  Picture cPict1
				Next
				@nLin,aVerbas[Len(aVerbas),2] Psay nTotalGeral  Picture cPict1
				@++nLin,00 Psay Replicate("=",Iif(nVerHor==1,132,220))
				ExecCab(@nLin)
			Endif

		ElseIf nSinAna == 1 // Sintetico
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega Informacoes da Empresa que esta sendo impressa       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fInfo(@aInfo,_cFilialAnt)
			cDescFil	:= PadR(aInfo[2],20)		
	
			@ ++nLIn,00 Psay _cFilialAnt + " - " + Alltrim( cDescFil )
			ExecCab(@nLin)
			
			nNumFils := Ascan( aFilHorAnalSint, { |x| x[1] <> _cFilialAnt } )
			
			If nNumFils > 0				
				_cFilialAnt := SRA->RA_FILIAL     
			EndIf				
			
			For nCont:= 1 to len(aFilHorAnalSint)
				If aFilHorAnalSint[nCont][1] == _cFilialAnt
					@nLin,aFilHorAnalSint[nCont][4] Psay aFilHorAnalSint[nCont][3]  Picture cPict1
				EndIf				
			Next					
			
			If !Empty( aFilAtuTotalGeral ) .And. nContFil <= Len( aFilAtuTotalGeral )
				nFilTotalGeral := aFilAtuTotalGeral[nContFil][2]
				nContFil ++                                  
			EndIf
             
			//-->Nao imprimir valores negativos
			If nFilTotalGeral <= 0
				nFilTotalGeral := 0
			EndIf
			
			@nLin,aVerbas[Len(aVerbas)][2] Psay nFilTotalGeral Picture cPict1

			If lImpEmpr
				@ ++nLin,00 Psay Replicate("-",Iif(nVerHor==1,132,220))
				ExecCab(@nLin)
				@ ++nLIn,00 Psay STR0034		//"Valor total Empresa:"
				ExecCab(@nLin)
				
				//--> Total de cada verba por coluna 
				For nCont:= 1 to len(aSomaTotal)
					@nLin,aSomaTotal[nCont][3] Psay aSomaTotal[nCont][2]  Picture cPict1
				Next
				
				//-->Nao imprimir valores negativos
				If nTotalGeral <= 0
					nTotalGeral := 0
				EndIf
				
				@nLin,aVerbas[Len(aVerbas)][2] Psay nTotalGeral  Picture cPict1
				@++nLin,00 Psay Replicate("=",Iif(nVerHor==1,132,220))
				ExecCab(@nLin)
			Endif
		Endif

ElseIf nVerHor == 1  // Vertical
	   	nLin++
	   	ExecCab(@nLin)
		If nSinAna == 2  // Vertical e Analitico
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Rotina para a impressao do SubTotal do centro de custo e do           ³
			//³totalizador da empresa, de acordo com o parametro de total de empresa.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (nValorProvento-nValorDesconto) <> 0
				@nLin,00 Psay STR0025	//"Valores Totais  - "
			Endif
			If nHorasTipo > 0
				@nLin,21 Psay STR0026	//"Horas:"
				@nLin,27 Psay nHorasTipo Picture "@R 9999.99"
				nHorasTotal	:= nHorasTotal + nHorasTipo
			Endif
			If nDiasTipo > 0
				@nLin,34 Psay STR0027	//"Dias:"
				@nLin,39 Psay nDiasTipo Picture "@E 99999"
				nDiasTotal	:= nDiasTotal + nDiasTipo
			Endif

			If nValorProvento>0
				@nLin,45 Psay Substr(STR0028,1,10) 	//"Provento:"
				@nLin,55 Psay nValorProvento Picture "@E 999,999,999.99"
				nProvento	:= nProvento + nValorProvento
			Endif
			If nValorDesconto>0
				@nLin,75 Psay STR0029	//"Desconto:"
				@nLin,85 Psay nValorDesconto Picture "@E 999,999,999.99"
				nDesconto	:= nDesconto + nValorDesconto
			EndIf
			If (nValorProvento-nValorDesconto) <> 0
				@nLin,105 Psay STR0030	//"Liquido:"
				@nLin,113 Psay ( nValorProvento-nValorDesconto) Picture "@E 999,999,999.99"
				nLiquido	:= 	(nValorProvento-nValorDesconto)
			Endif
		
			nSVProv			:= 	nSVProv + nValorProvento
            nSVDesc			:= 	nSVDesc + nValorDesconto
            nSVHoras		:=	nSVHoras + nHorasTipo
            nSVDias			:= 	nSVDias + nDiasTipo

			nValorProvento	:= 	nValorDesconto	:= 	nHorasTipo	:= 	nDiasTipo	:= 0

			@++nLin,00 Psay Replicate("-",Iif(nVerHor==1,132,220))
			ExecCab(@nLin)
			@++nLin,00 Psay STR0031+Alltrim(cCCusto)	//"Total C.Custo:"
			ExecCab(@nLin)

			If nSVHoras > 0
				@nLin,027 Psay STR0026		//"Horas:"
				@nLin,033 Psay nSVHoras Picture "@E 9999.99"
			Endif
			If nSVDias > 0
				@nLin,041 Psay STR0027		//"Dias:"
				@nLin,046 Psay nSVDias Picture "@E 99999"
			Endif

			If nSVProv>0
				@nLin,051 Psay Substr(STR0028,1,9)		//"Provento:"
				@nLin,060 Psay nSVProv Picture "@E 999,999,999.99"
			Endif
			If nSVDesc>0
				@nLin,078 Psay STR0029		//"Desconto:"
				@nLin,088 Psay nSVDesc Picture "@E 999,999,999.99"
			EndIf
			
			If (nSVProv - nSVDesc) <> 0	
				@nLin,105 Psay STR0030		//"Liquido:"
				@nLin,113 Psay (nSVProv - nSVDesc)  Picture "@E 999,999,999.99"
			Endif							

			nSVProv:= nSVDesc:=	nSVHoras:= nSVDias:= 0

			@++nLin,00 Psay Replicate("=",Iif(nVerHor==1,132,220))
			ExecCab(@nLin)
			nLin++        
			ExecCab(@nLin)
			If lImpEmpr
				@ nLIn,00 Psay STR0034		//"Valor total Empresa:"
				// codigo da verba,descricao da verba,valor da referencia,valor 
				aVerbasVAnalit 	:= ASort(aVerbasVAnalit,,,{|x,y| x[1] < y[1] })
				For nCont:= 1 To Len(aVerbasVAnalit)
					@ nLin,067  Psay aVerbasVAnalit[nCont][1]+" - "+Substr(aVerbasVAnalit[nCont][2],1,18)
					@ nLin,091	Psay aVerbasVAnalit[nCont][3] Picture "@E 999,999,999.99"
					@ nLin,105	Psay aVerbasVAnalit[nCont][4] Picture "@E 999,999,999.99"
					nLin++
					ExecCab(@nLin)
				Next
				@ nLIn++,00 Psay Replicate("-",Iif(nVerHor==1,132,220))
				ExecCab(@nLin)
			Endif
		
		ElseIf nSinAna == 1  // Vertical e Sintetico
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega Informacoes da Empresa que esta sendo impressa       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				fInfo(@aInfo,_cFilialAnt)
				cDescFil	:= PadR(aInfo[2],20)			
			
				@ nLIn,00 Psay _cFilialAnt + " - " + Alltrim( cDescFil )
						
			If lSalario
				@ nLIn,070 Psay STR0023		//"Salário Base"
				@ nLIn,093 Psay nSBHoras Picture   "@E 9999,999.99"
				@ nLIn,107 Psay nSBSalario Picture "@E 9999,999.99"
				nLIn++
				ExecCab(@nLin)
			Endif
					
			ASort(aVerVertSint,,,{ |a,b| a[1] < b[1] })
			nVlrHoras := nVlrTotal := 0
			For nCont:= 1 to Len(aVerVertSint)
				If Empty(aVerVertSint[nCont][1] )
					loop
				Endif
				@ nLIn,67 Psay aVerVertSint[nCont][1] + "-"
				@ nLIn,73 Psay Alltrim(aVerVertSint[nCont][2])
				@ nLIn,093 Psay aVerVertSint[nCont][3] Picture "@E 9999,999.99"
				@ nLIn,107 Psay aVerVertSint[nCont][4] Picture "@E 9999,999.99"
				nLIn++
				ExecCab(@nLin)
				nVlrHoras	:= nVlrHoras + aVerVertSint[nCont][3]
				
				_cTpVerba 	:= PosSrv( aVerVertSint[nCont][1] , SRA->RA_FILIAL , "RV_TIPOCOD" )
				If _cTpVerba	== "1" // provento
					nVlrTotal	:= nVlrTotal + aVerVertSint[nCont][4]
				ElseIf _cTpVerba	== "2" // desconto
					nVlrTotal	:= nVlrTotal - aVerVertSint[nCont][4]			
				Endif
			Next
						
			@ nLIn++,00 Psay Replicate("-",Iif(nVerHor==1,132,220))
			ExecCab(@nLin)
			@ nLin,00 Psay STR0033	+ _cFilialAnt		//"Total da Filial "
			@ nLIn,093 Psay nVlrHoras Picture "@E 999,999.99"
			@ nLIn++,107 Psay nVlrTotal Picture "@E 9999,999.99"
			ExecCab(@nLin)
			@ nLIn,00 Psay Replicate("=",Iif(nVerHor==1,132,220))
			aVerVertSint	:= {}
			ExecCab(@nLin)
			cDescCentro		:= DescCC(cCCusto,_cFilialAnt,25)

			If aReturn[8] == 1 
				For nCont:= 1 to Len(aVerbasRet)
					nPosVerba	:= Ascan(aVertSintCC,{ |x| x[1] == SRA->RA_CC .And. x[2] == aVerbasRet[nCont][3] } ) // centro de custo
					IF nPosVerba == 0
						Aadd(aVertSintCC,{SRA->RA_CC,aVerbasRet[nCont][3],aVerbasRet[nCont][6],aVerbasRet[nCont][7]})
					Else
						aVertSintCC[nPosVerba][3]:= aVertSintCC[nPosVerba][3] + aVerbasRet[nCont][6]
						aVertSintCC[nPosVerba][4]:= aVertSintCC[nPosVerba][4] + aVerbasRet[nCont][7]
					Endif						
				Next
			ElseIf aReturn[8] == 2 	// Vertical / Sintetico / Ordem de C.Custo 
				@ nLIn,00 Psay _cFilialAnt+" "+cCCusto 
				@ nLIn,25 Psay "- "+cDescCentro				
			Endif					
			
			aVerVertSint:= ASort(aVerVertSint,,,{ |a,b| a[1] < b[1] })
			nVlrHoras := nVlrTotal := 0
			For nCont:= 1 to Len(aVerVertSint)  // loop para listar as verbas - Vertical Sintetico
				If Empty(aVerVertSint[nCont][1] )
					loop
				Endif
				@ nLIn,67 Psay aVerVertSint[nCont][1] + " -"
				@ nLIn,73 Psay aVerVertSint[nCont][2] 
				@ nLIn,093 Psay aVerVertSint[nCont][3] Picture "@E 9999,999.99"
				@ nLIn++,107 Psay aVerVertSint[nCont][4] Picture "@E 9999,999.99"
				ExecCab(@nLin)
				nVlrHoras	:= nVlrHoras + aVerVertSint[nCont][3]	
				_cTpVerba 	:= PosSrv( aVerVertSint[nCont][1] , SRA->RA_FILIAL , "RV_TIPOCOD" )
				If _cTpVerba	== "1" // provento
					nVlrTotal	:= nVlrTotal + aVerVertSint[nCont][4]
				ElseIf _cTpVerba	== "2" // desconto
					nVlrTotal	:= nVlrTotal - aVerVertSint[nCont][4]			
				Endif
			Next

			If aReturn[8] == 2 
				@ ++nLIn,00 Psay Replicate("-",Iif(nVerHor==1,132,220))
				ExecCab(@nLin)
				@ ++nLin,00 Psay STR0032 + cCCusto	//"Total do Centro de Custo "
				ExecCab(@nLin)
				@ nLIn,093 Psay nVlrHoras Picture "@E 9999,999.99"
				@ nLIn,107 Psay nVlrTotal Picture "@E 9999,999.99"
			Endif

			@ ++nLIn,00 Psay Replicate("=",Iif(nVerHor==1,132,220))
			ExecCab(@nLin)
			nLIn++        
			ExecCab(@nLin)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Rotina para somar o total da empresa³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lImpEmpr .And. nRefVertSint > 0 .And. nVlrVertSint > 0
				@ nLIn,00 Psay STR0034		//"Valor total Empresa:"
				@ nLIn,093 Psay nRefVertSint Picture "@E 999,999,999.99"
				@ nLIn++,107 Psay nVlrVertSint Picture "@E 999,999,999.99"
				ExecCab(@nLin)
				@ nLIn,00 Psay Replicate("=",Iif(nVerHor==1,132,220))
			Endif
		Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termino do relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SRA")
Set Filter to
dbSetOrder(1)

Set Device To Screen
If aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel)
Endif
MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ExecCab   ºAutor  ³Ronan               º Data ³  03/27/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ter controle maior da quebra de pagina                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ somente neste programa                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ExecCab(nLin)
If nLin >= 64
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,nTamanho,nTipo)
	nLin := 9
Endif
Return nLin