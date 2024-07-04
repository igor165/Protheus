#INCLUDE "GPEA1630.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PONCALEN.CH"
#INCLUDE "FWBROWSE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Gpea630  ³ Autor ³ Equipe RH             ³ Data ³ 08/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Lancamentos (Recibo de Pagamento)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Programador  ³ Data   ³chamado³  Motivo da Alteracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Mohanad Odeh ³22/03/13³M12RH01³Unificacao da Folha V12                 ³±±
±±³             ³        ³RQ0118 ³                                        ³±±
±±³Wagner Mobile³28/10/14³TQXLTU ³Alterada a rotina para FwBrowse, pois na³±±
±±³             ³        ³       ³MBrowse se possuir 1 filtro no fonte a  ³±±
±±³             ³        ³       ³opcao filtro nao e apresentada no browse³±±
±±³Renan Borges ³27/11/14³TQXLTU ³Executado filtro dentro da visualização ³±±
±±³             ³        ³       ³dos recibos de pagamento, para filtrar  ³±±
±±³             ³        ³       ³igualmente apenas os registros filtrados³±±
±±³             ³        ³       ³no browse.                              ³±±
±±³Gustavo M.   ³27/01/15³TRHME5 ³Ajuste para n desposicionar registro ao ³±±
±±³             ³        ³       ³visualizar.							  ³±
±±³Henrique V.  ³20/04/15³TRYGJU ³Correção na função que retorna a Função ³±±
±±³             ³        ³       ³dos funcionários quando é utilizado os  ³±±
±±³             ³        ³       ³botões na parte de baixo do browse para ³±±
±±³             ³        ³       ³visualizar os recibos dos funcionários  ³±±
±±³Victor A.    ³26/07/16³TVLAMV ³Adicionado GET para permitir que o      ³±±
±±³             ³        ³       ³usuário informe o processo desejado na  ³±±
±±³             ³        ³       ³filtragem.							  ³±±
±±³Allyson M    ³17/08/16³TVUY47 ³Ajuste na chamada de fBuscaSal() p/     ³±±
±±³             ³        ³       ³indicar o retorno do salario base 	  ³±±
±±³Gabriel A.   ³21/12/16³MRH    ³Ajuste para que caso a string retornada ³±±
±±³             ³        ³-3119  ³pela fValidFil() for maior que 2000     ³±±
±±³             ³        ³       ³bytes seja filtrada as filiais que o    ³±±
±±³             ³        ³       ³usuário não tem acesso.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gpea630(nOpcAuto,nOpAuto)

LOCAL oBrwSRA
LOCAL cFiltraSRA			//Variavel para filtro
LOCAL aIndexSRA	:= {}		//Variavel Para Filtro

Private aRotina 	:= MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Private lGestPubl 	:= IIF(ExistFunc("fUsaGFP"),fUsaGFP(),.F.)

cCadastro := OemToAnsi(STR0003) //"Recibo de Pagamento"

If nOpcAuto <> Nil
	Do Case
		Case nOpcAuto == 3
			INCLUI := .T.
			ALTERA := .F.
		Case nOpcAuto == 4
			INCLUI := .F.
			ALTERA := .T.
		OtherWise
			INCLUI := .F.
			ALTERA := .F.
	EndCase

	dbSelectArea('SRA')
	nPos := Ascan(aRotina,{|x| x[4]== nOpcAuto},nOpAuto)
	If ( nPos <> 0 )
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPos,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nPos)
	EndIf
Else
	// VERIFICA SE O ARQUIVO ESTA VAZIO
	If !ChkVazio("SRA")
		Return
	Endif

	//Monta o Browse
	oBrwSRA:= FwMBrowse():New()
	oBrwSRA:SetAlias( 'SRA' )
	oBrwSRA:SetDescription(cCadastro) 		//"Cadastro de Funcionarios"

	GpLegend(@oBrwSRA,.T.)
	oBrwSRA:SetmenuDef( 'GPEA010' )

	// Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh 	:= CHKRH("GPEA630","SRA","1")
	oBrwSRA:SetFilterDefault(cFiltraRh)
	oBrwSRA:Activate()
EndIf



Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp630Vis  ³ Autor ³ Equipe RH             ³ Data ³ 08/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Consulta de lancamentos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gp630Vis(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPE                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION gp630Vis(cAlias,nReg,nOpcx)
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local nSavRec
Local aPesqIdx 		:= {}
Local aPesqOrd		:= {}
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T. , .F.}) //[1] Acesso; [2]Ofusca
Local aFldRot 		:= {'RA_NOME', 'RA_CODFUNC'}
Local aFldOfusca 	:= {}

Local lSeeAll		:= .T.
Local lOfuscaNom	:= .F.
Local lOfuscaFun	:= .F.
Local cPesqOrd
Local cPesqCampo	:= space(40)
Local cFuncionario
Local cDescFil
Local cFuncao
Local cDescEnd
Local cDescCGC
Local cSalario
Local cCateg
Local cRegime
Local cTpPrev
Local cMat			:= SRA->RA_MAT
Local cSemana 		:= Space(GetSx3Cache("RCH_NUMPAG", "X3_TAMANHO"))
Local cMes			:= ""
Local cAno			:= ""
Local oBrwAux
Local oFilAux

Local oFont
Local oGroup
Local oGet
Local oDlg
Local oBtnPgNext
Local oBtnPgPrev
Local oBntNext
Local oBntPrev
Local oPesqCbx
Local oPesqGet
Local oFuncao
Local oSalario
Local oFunc
Local oPeriodo
Local oRoteiro
Local oTotLiq
Local oTotdesc
Local oTotProv
Local oProcesso
Local lAxPesqui :=.F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Blocos de Codigo                                            ³
//³================                                            ³
//³Serao utilizados na acao do botoes de movimentacao, "Avanca"³
//³"Retrocede", "Avanca Todos" e "Retrocede Todos".            ³
//³O Bloco "bFica" sera utilizado quando forem alterados os    ³
//³campos data de referencia, semana e roteiro.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local bRetrocOne := {|| SRA->( dbskip(-1))	 ,aCols:= {}, a630AtualFunc(@cDescFil,@cDescEnd,@cDescCGC,@cFuncionario,@cFuncao,@cSalario,cSemana,@cCateg,@cRegime,@cTpPrev),oGet:oBrowse:Refresh(),oDLG:Refresh()}
Local bRetrocAll := {|| SRA->( dbGoTop())	 ,aCols:= {},a630AtualFunc(@cDescFil,@cDescEnd,@cDescCGC,@cFuncionario,@cFuncao,@cSalario,cSemana,@cCateg,@cRegime,@cTpPrev),oGet:oBrowse:Refresh(),oDLG:Refresh()}
Local bAvancaOne := {|| SRA->( dbskip())	 ,If( SRA->(! EOF()),aCols:= {},.T.),a630AtualFunc(@cDescFil,@cDescEnd,@cDescCGC,@cFuncionario,@cFuncao,@cSalario,cSemana,@cCateg,@cRegime,@cTpPrev),oGet:oBrowse:Refresh(),oDLG:Refresh()}
Local bAvancaAll := {|| SRA->( dbGoBottom()),aCols:= {},a630AtualFunc(@cDescFil,@cDescEnd,@cDescCGC,@cFuncionario,@cFuncao,@cSalario,cSemana,@cCateg,@cRegime,@cTpPrev),oGet:oBrowse:Refresh(),oDLG:Refresh()}
Local bFica      := {|| a630AtualFunc(@cDescFil,@cDescEnd,@cDescCGC,@cFuncionario,@cFuncao,@cSalario,cSemana,@cCateg,@cRegime,@cTpPrev),If(lDaRefresh,(oGet:oBrowse:Refresh(),oDLG:Refresh()),.t.)}
Local cFilterAux := ""
local nX 		 := 0
Local lHistMed	 := AliasInDic("RJK") .And. AliasInDic("SRP") .And. FindFunction("fVerHistMed") .And. FindFunction("fTemHMed")
Local aButtons	 := {}

Private aInfo		:= {}
Private aCodFol		:= {}
Private nTotLiq 	:= 0
Private nTotdesc 	:= 0
Private	nTotProv 	:= 0
Private aCols   	:= {}
Private cFilAnterior:= ""
Private dDataRef	:= cTod("")
Private cProcesso	:= SRA->RA_PROCES
Private cPerAnt		:= Space(GetSx3Cache("RCH_PER", "X3_TAMANHO"))
Private cSemAnt		:= Space(GetSx3Cache("RCH_NUMPAG", "X3_TAMANHO"))
Private cRotAnt		:= Space(GetSx3Cache("RCH_ROTEIR", "X3_TAMANHO"))
Private lDaRefresh 	:= .F.
Private aPerAberto	:= {}
Private aPerFechado	:= {}
Private cPeriodo	:= Space(GetSx3Cache("RCH_PER", "X3_TAMANHO"))
Private cRoteiro	:= Space(GetSx3Cache("RCH_ROTEIR", "X3_TAMANHO"))
Private oSemana
//SALVA A INTEGRIDADE DOS DADOS
nSavRec         := RecNo()
cAlias          := "SRC"

//MONTA A ENTRADA DE DADOS DO arquivo
Private aTELA[0,0],aGETS[0],aHeader[0],nUsado:=0

oBrwAux    := GetMBrowse()

If oBrwAux != nil
	oFilAux    := oBrwAux:FwFilter()
	If oFilAux != nil
		cFilterAux := oFilAux:GetExprADVPL()

		If Len(fValidFil()) <= 2000
			cFilterAux += If( !( Empty( cFilterAux ) ), ' .And. SRA->RA_FILIAL $ fValidFil() ', ' SRA->RA_FILIAL $ fValidFil() ' )
		Else
			cFilterAux += If( !( Empty( cFilterAux ) ), ' .And. !( SRA->RA_FILIAL $ fValidFil(,.T.) ) ', ' !( SRA->RA_FILIAL $ fValidFil(,.T.) ) ' )
		EndIf

		DbSetFilter({||&cFilterAux},cFilterAux)
	Endif
Endif

// MONTA O CABECALHO
dbSelectArea("Sx2")
dbSeek(cAlias)


If lGestPubl
	If cModulo == "GFP"
		aHeader := Array( 17 , __ELEMENTOS_AHEADER__ )
	Else
		aHeader := Array( 16 , __ELEMENTOS_AHEADER__ )
	EndIf
Else
	aHeader := Array( 6 , __ELEMENTOS_AHEADER__ )
Endif

NX := 1

aHeader[ NX , __AHEADER_TITLE__		]	:= STR0004		// "Codigo"
aHeader[ NX , __AHEADER_FIELD__		]	:= "RC_PD"
aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RC_PD" , "X3_PICTURE" )
aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RC_PD" , "X3_TAMANHO" )
aHeader[ NX , __AHEADER_DEC__		]	:= 0
aHeader[ NX , __AHEADER_VALID__		]	:= ""
aHeader[ NX , __AHEADER_USE__		]	:= "û"
aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RC_PD" , "X3_TIPO" )
aHeader[ NX , __AHEADER_F3__		]	:= GetSx3Cache( "RC_PD" , "X3_F3"	 )
aHeader[ NX , __AHEADER_CONTEXT__	]	:= ""
aHeader[ NX , __AHEADER_CBOX__		]	:= ""
aHeader[ NX , __AHEADER_INITPAD__	]	:= ""
aHeader[ NX , __AHEADER_WHEN__		]	:= ""
aHeader[ NX , __AHEADER_VISUAL__		]	:= "V"
aHeader[ NX , __AHEADER_VLDUSR__		]	:= ""
aHeader[ NX , __AHEADER_RESERV16__	]	:= ""
aHeader[ NX , __AHEADER_RESERV17__	]	:= .F.

NX++

aHeader[ NX , __AHEADER_TITLE__		]	:= STR0005		// "Descricao"
aHeader[ NX , __AHEADER_FIELD__		]	:= "RC_DESCPD"
aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RC_DESCPD" , "X3_PICTURE" )
aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RC_DESCPD" , "X3_TAMANHO" )
aHeader[ NX , __AHEADER_DEC__		]	:= 0
aHeader[ NX , __AHEADER_VALID__		]	:= ""
aHeader[ NX , __AHEADER_USE__		]	:= "û"
aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RC_DESCPD" , "X3_TIPO" )
aHeader[ NX  , __AHEADER_F3__		]	:= ""
aHeader[ NX , __AHEADER_CONTEXT__	]	:= ""
aHeader[ NX , __AHEADER_CBOX__		]	:= ""
aHeader[ NX , __AHEADER_INITPAD__	]	:= ""
aHeader[ NX , __AHEADER_WHEN__		]	:= ""
aHeader[ NX , __AHEADER_VISUAL__		]	:= "V"
aHeader[ NX , __AHEADER_VLDUSR__		]	:= ""
aHeader[ NX , __AHEADER_RESERV16__	]	:= ""
aHeader[ NX , __AHEADER_RESERV17__	]	:= .F.

NX++

aHeader[ NX , __AHEADER_TITLE__		]	:= STR0006		// "Referencia"
aHeader[ NX , __AHEADER_FIELD__		]	:= "RC_HORAS"
aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RC_HORAS" , "X3_PICTURE" )
aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RC_HORAS" , "X3_TAMANHO"  )
aHeader[ NX , __AHEADER_DEC__		]	:= GetSx3Cache( "RC_HORAS" , "X3_DECIMAL"  )
aHeader[ NX , __AHEADER_VALID__		]	:= ""
aHeader[ NX , __AHEADER_USE__		]	:= "û"
aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RC_HORAS" , "X3_TIPO" )
aHeader[ NX  , __AHEADER_F3__		]	:= ""
aHeader[ NX , __AHEADER_CONTEXT__	]	:= ""
aHeader[ NX , __AHEADER_CBOX__		]	:= ""
aHeader[ NX , __AHEADER_INITPAD__	]	:= ""
aHeader[ NX , __AHEADER_WHEN__		]	:= ""
aHeader[ NX , __AHEADER_VISUAL__		]	:= "V"
aHeader[ NX , __AHEADER_VLDUSR__		]	:= ""
aHeader[ NX , __AHEADER_RESERV16__	]	:= ""
aHeader[ NX , __AHEADER_RESERV17__	]	:= .F.

NX++

aHeader[ NX , __AHEADER_TITLE__		]	:= STR0007		// "Provento"
aHeader[ NX , __AHEADER_FIELD__		]	:= "RC_VALOR"
aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RC_VALOR" , "X3_PICTURE" )
aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RC_VALOR" , "X3_TAMANHO"  )
aHeader[ NX , __AHEADER_DEC__		]	:= GetSx3Cache( "RC_VALOR" , "X3_DECIMAL"  )
aHeader[ NX , __AHEADER_VALID__		]	:= ""
aHeader[ NX , __AHEADER_USE__		]	:= "û"
aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RC_VALOR" , "X3_TIPO" )
aHeader[ NX  , __AHEADER_F3__		]	:= ""
aHeader[ NX , __AHEADER_CONTEXT__	]	:= ""
aHeader[ NX , __AHEADER_CBOX__		]	:= ""
aHeader[ NX , __AHEADER_INITPAD__	]	:= ""
aHeader[ NX , __AHEADER_WHEN__		]	:= ""
aHeader[ NX , __AHEADER_VISUAL__		]	:= "V"
aHeader[ NX , __AHEADER_VLDUSR__		]	:= ""
aHeader[ NX , __AHEADER_RESERV16__	]	:= ""
aHeader[ NX , __AHEADER_RESERV17__	]	:= .F.

NX++

aHeader[ NX , __AHEADER_TITLE__		]	:= STR0008		// "Desconto"
aHeader[ NX , __AHEADER_FIELD__		]	:= "RC_VALOR"
aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RC_VALOR" , "X3_PICTURE" )
aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RC_VALOR" , "X3_TAMANHO"  )
aHeader[ NX , __AHEADER_DEC__		]	:= GetSx3Cache( "RC_VALOR" , "X3_DECIMAL"  )
aHeader[ NX , __AHEADER_VALID__		]	:= ""
aHeader[ NX , __AHEADER_USE__		]	:= "û"
aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RC_VALOR" , "X3_TIPO" )
aHeader[ NX  , __AHEADER_F3__		]	:= ""
aHeader[ NX , __AHEADER_CONTEXT__	]	:= ""
aHeader[ NX , __AHEADER_CBOX__		]	:= ""
aHeader[ NX , __AHEADER_INITPAD__	]	:= ""
aHeader[ NX , __AHEADER_WHEN__		]	:= ""
aHeader[ NX , __AHEADER_VISUAL__		]	:= "V"
aHeader[ NX , __AHEADER_VLDUSR__		]	:= ""
aHeader[ NX , __AHEADER_RESERV16__	]	:= ""
aHeader[ NX , __AHEADER_RESERV17__	]	:= .F.

NX++

aHeader[ NX , __AHEADER_TITLE__		]	:= STR0009		// "Bases"
aHeader[ NX , __AHEADER_FIELD__		]	:= "RC_VALOR"
aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RC_VALOR" , "X3_PICTURE" )
aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RC_VALOR" , "X3_TAMANHO"  )
aHeader[ NX , __AHEADER_DEC__		]	:= GetSx3Cache( "RC_VALOR" , "X3_DECIMAL"  )
aHeader[ NX , __AHEADER_VALID__		]	:= ""
aHeader[ NX , __AHEADER_USE__		]	:= "û"
aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RC_VALOR" , "X3_TIPO" )
aHeader[ NX  , __AHEADER_F3__		]	:= ""
aHeader[ NX , __AHEADER_CONTEXT__	]	:= ""
aHeader[ NX , __AHEADER_CBOX__		]	:= ""
aHeader[ NX , __AHEADER_INITPAD__	]	:= ""
aHeader[ NX , __AHEADER_WHEN__		]	:= ""
aHeader[ NX , __AHEADER_VISUAL__		]	:= "V"
aHeader[ NX , __AHEADER_VLDUSR__		]	:= ""
aHeader[ NX , __AHEADER_RESERV16__	]	:= ""
aHeader[ NX , __AHEADER_RESERV17__	]	:= .F.


If lGestPubl

	NX++
	aHeader[ NX , __AHEADER_TITLE__		]	:= "Tipo1"
	aHeader[ NX , __AHEADER_FIELD__		]	:= "RC_TIPO1"
	aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RC_TIPO1" , "X3_PICTURE" )
	aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RC_TIPO1" , "X3_TAMANHO" )
	aHeader[ NX , __AHEADER_DEC__		]	:= GetSx3Cache( "RC_TIPO1" , "X3_DECIMAL" )
	aHeader[ NX , __AHEADER_VALID__		]	:= GetSx3Cache( "RC_TIPO1" , "X3_VALID" )
	aHeader[ NX , __AHEADER_USE__		]	:= GetSx3Cache( "RC_TIPO1" , "X3_USADO"	 )
	aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RC_TIPO1" , "X3_TIPO" )
	aHeader[ NX  , __AHEADER_F3__		]	:= GetSx3Cache( "RC_TIPO1" , "X3_F3" )
	aHeader[ NX , __AHEADER_CONTEXT__	]	:= GetSx3Cache( "RC_TIPO1" , "X3_CONTEXT"	 )
	aHeader[ NX , __AHEADER_CBOX__		]	:= GetSx3Cache( "RC_TIPO1" , "X3_CBOX"	 )
	aHeader[ NX , __AHEADER_INITPAD__	]	:= GetSx3Cache( "RC_TIPO1" , "X3_RELACAO"	 )
	aHeader[ NX , __AHEADER_WHEN__		]	:= GetSx3Cache( "RC_TIPO1" , "X3_WHEN" )
	aHeader[ NX , __AHEADER_VISUAL__	]	:= GetSx3Cache( "RC_TIPO1" , "X3_VISUAL" )
	aHeader[ NX , __AHEADER_VLDUSR__	]	:= GetSx3Cache( "RC_TIPO1" , "X3_VLDUSER" )
	aHeader[ NX , __AHEADER_RESERV16__	]	:= GetSx3Cache( "RC_TIPO1" , "X3_OBRIGAT" )
	aHeader[ NX , __AHEADER_RESERV17__	]	:= If(!Empty(aHeader[ NX , __AHEADER_RESERV16__	]),.T.,.F.)

	NX++
	aHeader[ NX , __AHEADER_TITLE__		]	:= GetSx3Cache( "RC_TIPO2" , "X3_TITULO" ) 		// "Tipo2"
	aHeader[ NX , __AHEADER_FIELD__		]	:= "RC_TIPO2"
	aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RC_TIPO2" , "X3_PICTURE" )
	aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RC_TIPO2" , "X3_TAMANHO" )
	aHeader[ NX , __AHEADER_DEC__		]	:= GetSx3Cache( "RC_TIPO2" , "X3_DECIMAL" )
	aHeader[ NX , __AHEADER_VALID__		]	:= GetSx3Cache( "RC_TIPO2" , "X3_VALID" )
	aHeader[ NX , __AHEADER_USE__		]	:= GetSx3Cache( "RC_TIPO2" , "X3_USADO"	 )
	aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RC_TIPO2" , "X3_TIPO" )
	aHeader[ NX  , __AHEADER_F3__		]	:= GetSx3Cache( "RC_TIPO2" , "X3_F3" )
	aHeader[ NX , __AHEADER_CONTEXT__	]	:= GetSx3Cache( "RC_TIPO2" , "X3_CONTEXT"	 )
	aHeader[ NX , __AHEADER_CBOX__		]	:= GetSx3Cache( "RC_TIPO2" , "X3_CBOX"	 )
	aHeader[ NX , __AHEADER_INITPAD__	]	:= GetSx3Cache( "RC_TIPO2" , "X3_RELACAO"	 )
	aHeader[ NX , __AHEADER_WHEN__		]	:= GetSx3Cache( "RC_TIPO2" , "X3_WHEN" )
	aHeader[ NX , __AHEADER_VISUAL__	]	:= GetSx3Cache( "RC_TIPO2" , "X3_VISUAL" )
	aHeader[ NX , __AHEADER_VLDUSR__	]	:= GetSx3Cache( "RC_TIPO2" , "X3_VLDUSER" )
	aHeader[ NX , __AHEADER_RESERV16__	]	:= GetSx3Cache( "RC_TIPO2" , "X3_OBRIGAT" )
	aHeader[ NX , __AHEADER_RESERV17__	]	:= If(!Empty(aHeader[ NX , __AHEADER_RESERV16__	]),.T.,.F.)

	NX++
	aHeader[ NX , __AHEADER_TITLE__		]	:= GetSx3Cache( "RV_INSS" , "X3_TITULO" ) 		// "INSS"
	aHeader[ NX , __AHEADER_FIELD__		]	:= "RV_INSS"
	aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RV_INSS" , "X3_PICTURE" )
	aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RV_INSS" , "X3_TAMANHO" )
	aHeader[ NX , __AHEADER_DEC__		]	:= GetSx3Cache( "RV_INSS" , "X3_DECIMAL" )
	aHeader[ NX , __AHEADER_VALID__		]	:= GetSx3Cache( "RV_INSS" , "X3_VALID" )
	aHeader[ NX , __AHEADER_USE__		]	:= GetSx3Cache( "RV_INSS" , "X3_USADO"	 )
	aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RV_INSS" , "X3_TIPO" )
	aHeader[ NX  , __AHEADER_F3__		]	:= GetSx3Cache( "RV_INSS" , "X3_F3" )
	aHeader[ NX , __AHEADER_CONTEXT__	]	:= GetSx3Cache( "RV_INSS" , "X3_CONTEXT"	 )
	aHeader[ NX , __AHEADER_CBOX__		]	:= GetSx3Cache( "RV_INSS" , "X3_CBOX"	 )
	aHeader[ NX , __AHEADER_INITPAD__	]	:= GetSx3Cache( "RV_INSS" , "X3_RELACAO"	 )
	aHeader[ NX , __AHEADER_WHEN__		]	:= GetSx3Cache( "RV_INSS" , "X3_WHEN" )
	aHeader[ NX , __AHEADER_VISUAL__	]	:= GetSx3Cache( "RV_INSS" , "X3_VISUAL" )
	aHeader[ NX , __AHEADER_VLDUSR__	]	:= GetSx3Cache( "RV_INSS" , "X3_VLDUSER" )
	aHeader[ NX , __AHEADER_RESERV16__	]	:= GetSx3Cache( "RV_INSS" , "X3_OBRIGAT" )
	aHeader[ NX , __AHEADER_RESERV17__	]	:= If(!Empty(aHeader[ NX , __AHEADER_RESERV16__	]),.T.,.F.)

	NX++
	aHeader[ NX , __AHEADER_TITLE__		]	:= GetSx3Cache( "RV_IR" , "X3_TITULO" ) 		// "IR"
	aHeader[ NX , __AHEADER_FIELD__		]	:= "RV_IR"
	aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RV_IR" , "X3_PICTURE" )
	aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RV_IR" , "X3_TAMANHO" )
	aHeader[ NX , __AHEADER_DEC__		]	:= GetSx3Cache( "RV_IR" , "X3_DECIMAL" )
	aHeader[ NX , __AHEADER_VALID__		]	:= GetSx3Cache( "RV_IR" , "X3_VALID" )
	aHeader[ NX , __AHEADER_USE__		]	:= GetSx3Cache( "RV_IR" , "X3_USADO"	 )
	aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RV_IR" , "X3_TIPO" )
	aHeader[ NX  , __AHEADER_F3__		]	:= GetSx3Cache( "RV_IR" , "X3_F3" )
	aHeader[ NX , __AHEADER_CONTEXT__	]	:= GetSx3Cache( "RV_IR" , "X3_CONTEXT"	 )
	aHeader[ NX , __AHEADER_CBOX__		]	:= GetSx3Cache( "RV_IR" , "X3_CBOX"	 )
	aHeader[ NX , __AHEADER_INITPAD__	]	:= GetSx3Cache( "RV_IR" , "X3_RELACAO"	 )
	aHeader[ NX , __AHEADER_WHEN__		]	:= GetSx3Cache( "RV_IR" , "X3_WHEN" )
	aHeader[ NX , __AHEADER_VISUAL__	]	:= GetSx3Cache( "RV_IR" , "X3_VISUAL" )
	aHeader[ NX , __AHEADER_VLDUSR__	]	:= GetSx3Cache( "RV_IR" , "X3_VLDUSER" )
	aHeader[ NX , __AHEADER_RESERV16__	]	:= GetSx3Cache( "RV_IR" , "X3_OBRIGAT" )
	aHeader[ NX , __AHEADER_RESERV17__	]	:= If(!Empty(aHeader[ NX , __AHEADER_RESERV16__	]),.T.,.F.)

	NX++
	aHeader[ NX , __AHEADER_TITLE__		]	:= GetSx3Cache( "RV_REFFER" , "X3_TITULO" ) 		// "RV_REFFER"
	aHeader[ NX , __AHEADER_FIELD__		]	:= "RV_REFFER"
	aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RV_REFFER" , "X3_PICTURE" )
	aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RV_REFFER" , "X3_TAMANHO" )
	aHeader[ NX , __AHEADER_DEC__		]	:= GetSx3Cache( "RV_REFFER" , "X3_DECIMAL" )
	aHeader[ NX , __AHEADER_VALID__		]	:= GetSx3Cache( "RV_REFFER" , "X3_VALID" )
	aHeader[ NX , __AHEADER_USE__		]	:= GetSx3Cache( "RV_REFFER" , "X3_USADO"	 )
	aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RV_REFFER" , "X3_TIPO" )
	aHeader[ NX  , __AHEADER_F3__		]	:= GetSx3Cache( "RV_REFFER" , "X3_F3" )
	aHeader[ NX , __AHEADER_CONTEXT__	]	:= GetSx3Cache( "RV_REFFER" , "X3_CONTEXT"	 )
	aHeader[ NX , __AHEADER_CBOX__		]	:= GetSx3Cache( "RV_REFFER" , "X3_CBOX"	 )
	aHeader[ NX , __AHEADER_INITPAD__	]	:= GetSx3Cache( "RV_REFFER" , "X3_RELACAO"	 )
	aHeader[ NX , __AHEADER_WHEN__		]	:= GetSx3Cache( "RV_REFFER" , "X3_WHEN" )
	aHeader[ NX , __AHEADER_VISUAL__	]	:= GetSx3Cache( "RV_REFFER" , "X3_VISUAL" )
	aHeader[ NX , __AHEADER_VLDUSR__	]	:= GetSx3Cache( "RV_REFFER" , "X3_VLDUSER" )
	aHeader[ NX , __AHEADER_RESERV16__	]	:= GetSx3Cache( "RV_REFFER" , "X3_OBRIGAT" )
	aHeader[ NX , __AHEADER_RESERV17__	]	:= If(!Empty(aHeader[ NX , __AHEADER_RESERV16__	]),.T.,.F.)

	NX++
	aHeader[ NX , __AHEADER_TITLE__		]	:= GetSx3Cache( "RV_REF13" , "X3_TITULO" ) 		// "RV_REF13"
	aHeader[ NX , __AHEADER_FIELD__		]	:= "RV_REF13"
	aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RV_REF13" , "X3_PICTURE" )
	aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RV_REF13" , "X3_TAMANHO" )
	aHeader[ NX , __AHEADER_DEC__		]	:= GetSx3Cache( "RV_REF13" , "X3_DECIMAL" )
	aHeader[ NX , __AHEADER_VALID__		]	:= GetSx3Cache( "RV_REF13" , "X3_VALID" )
	aHeader[ NX , __AHEADER_USE__		]	:= GetSx3Cache( "RV_REF13" , "X3_USADO"	 )
	aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RV_REF13" , "X3_TIPO" )
	aHeader[ NX  , __AHEADER_F3__		]	:= GetSx3Cache( "RV_REF13" , "X3_F3" )
	aHeader[ NX , __AHEADER_CONTEXT__	]	:= GetSx3Cache( "RV_REF13" , "X3_CONTEXT"	 )
	aHeader[ NX , __AHEADER_CBOX__		]	:= GetSx3Cache( "RV_REF13" , "X3_CBOX"	 )
	aHeader[ NX , __AHEADER_INITPAD__	]	:= GetSx3Cache( "RV_REF13" , "X3_RELACAO"	 )
	aHeader[ NX , __AHEADER_WHEN__		]	:= GetSx3Cache( "RV_REF13" , "X3_WHEN" )
	aHeader[ NX , __AHEADER_VISUAL__	]	:= GetSx3Cache( "RV_REF13" , "X3_VISUAL" )
	aHeader[ NX , __AHEADER_VLDUSR__	]	:= GetSx3Cache( "RV_REF13" , "X3_VLDUSER" )
	aHeader[ NX , __AHEADER_RESERV16__	]	:= GetSx3Cache( "RV_REF13" , "X3_OBRIGAT" )
	aHeader[ NX , __AHEADER_RESERV17__	]	:= If(!Empty(aHeader[ NX , __AHEADER_RESERV16__	]),.T.,.F.)

	NX++
	aHeader[ NX , __AHEADER_TITLE__		]	:= GetSx3Cache( "RV_INCORP" , "X3_TITULO" ) 		// "RV_INCORP"
	aHeader[ NX , __AHEADER_FIELD__		]	:= "RV_INCORP"
	aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RV_INCORP" , "X3_PICTURE" )
	aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RV_INCORP" , "X3_TAMANHO" )
	aHeader[ NX , __AHEADER_DEC__		]	:= GetSx3Cache( "RV_INCORP" , "X3_DECIMAL" )
	aHeader[ NX , __AHEADER_VALID__		]	:= GetSx3Cache( "RV_INCORP" , "X3_VALID" )
	aHeader[ NX , __AHEADER_USE__		]	:= GetSx3Cache( "RV_INCORP" , "X3_USADO"	 )
	aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RV_INCORP" , "X3_TIPO" )
	aHeader[ NX  , __AHEADER_F3__		]	:= GetSx3Cache( "RV_INCORP" , "X3_F3" )
	aHeader[ NX , __AHEADER_CONTEXT__	]	:= GetSx3Cache( "RV_INCORP" , "X3_CONTEXT"	 )
	aHeader[ NX , __AHEADER_CBOX__		]	:= GetSx3Cache( "RV_INCORP" , "X3_CBOX"	 )
	aHeader[ NX , __AHEADER_INITPAD__	]	:= GetSx3Cache( "RV_INCORP" , "X3_RELACAO"	 )
	aHeader[ NX , __AHEADER_WHEN__		]	:= GetSx3Cache( "RV_INCORP" , "X3_WHEN" )
	aHeader[ NX , __AHEADER_VISUAL__	]	:= GetSx3Cache( "RV_INCORP" , "X3_VISUAL" )
	aHeader[ NX , __AHEADER_VLDUSR__	]	:= GetSx3Cache( "RV_INCORP" , "X3_VLDUSER" )
	aHeader[ NX , __AHEADER_RESERV16__	]	:= GetSx3Cache( "RV_INCORP" , "X3_OBRIGAT" )
	aHeader[ NX , __AHEADER_RESERV17__	]	:= If(!Empty(aHeader[ NX , __AHEADER_RESERV16__	]),.T.,.F.)

	NX++
	aHeader[ NX , __AHEADER_TITLE__		]	:= GetSx3Cache( "RV_FGTS" , "X3_TITULO" ) 		// "RV_FGTS"
	aHeader[ NX , __AHEADER_FIELD__		]	:= "RV_FGTS"
	aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RV_FGTS" , "X3_PICTURE" )
	aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RV_FGTS" , "X3_TAMANHO" )
	aHeader[ NX , __AHEADER_DEC__		]	:= GetSx3Cache( "RV_FGTS" , "X3_DECIMAL" )
	aHeader[ NX , __AHEADER_VALID__		]	:= GetSx3Cache( "RV_FGTS" , "X3_VALID" )
	aHeader[ NX , __AHEADER_USE__		]	:= GetSx3Cache( "RV_FGTS" , "X3_USADO"	 )
	aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RV_FGTS" , "X3_TIPO" )
	aHeader[ NX  , __AHEADER_F3__		]	:= GetSx3Cache( "RV_FGTS" , "X3_F3" )
	aHeader[ NX , __AHEADER_CONTEXT__	]	:= GetSx3Cache( "RV_FGTS" , "X3_CONTEXT"	 )
	aHeader[ NX , __AHEADER_CBOX__		]	:= GetSx3Cache( "RV_FGTS" , "X3_CBOX"	 )
	aHeader[ NX , __AHEADER_INITPAD__	]	:= GetSx3Cache( "RV_FGTS" , "X3_RELACAO"	 )
	aHeader[ NX , __AHEADER_WHEN__		]	:= GetSx3Cache( "RV_FGTS" , "X3_WHEN" )
	aHeader[ NX , __AHEADER_VISUAL__	]	:= GetSx3Cache( "RV_FGTS" , "X3_VISUAL" )
	aHeader[ NX , __AHEADER_VLDUSR__	]	:= GetSx3Cache( "RV_FGTS" , "X3_VLDUSER" )
	aHeader[ NX , __AHEADER_RESERV16__	]	:= GetSx3Cache( "RV_FGTS" , "X3_OBRIGAT" )
	aHeader[ NX , __AHEADER_RESERV17__	]	:= If(!Empty(aHeader[ NX , __AHEADER_RESERV16__	]),.T.,.F.)

	NX++
	aHeader[ NX , __AHEADER_TITLE__		]	:= GetSx3Cache( "RV_CODFOL" , "X3_TITULO" ) 		// "RV_CODFOL"
	aHeader[ NX , __AHEADER_FIELD__		]	:= "RV_CODFOL"
	aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RV_CODFOL" , "X3_PICTURE" )
	aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RV_CODFOL" , "X3_TAMANHO" )
	aHeader[ NX , __AHEADER_DEC__		]	:= GetSx3Cache( "RV_CODFOL" , "X3_DECIMAL" )
	aHeader[ NX , __AHEADER_VALID__		]	:= GetSx3Cache( "RV_CODFOL" , "X3_VALID" )
	aHeader[ NX , __AHEADER_USE__		]	:= GetSx3Cache( "RV_CODFOL" , "X3_USADO"	 )
	aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RV_CODFOL" , "X3_TIPO" )
	aHeader[ NX  , __AHEADER_F3__		]	:= GetSx3Cache( "RV_CODFOL" , "X3_F3" )
	aHeader[ NX , __AHEADER_CONTEXT__	]	:= GetSx3Cache( "RV_CODFOL" , "X3_CONTEXT"	 )
	aHeader[ NX , __AHEADER_CBOX__		]	:= GetSx3Cache( "RV_CODFOL" , "X3_CBOX"	 )
	aHeader[ NX , __AHEADER_INITPAD__	]	:= GetSx3Cache( "RV_CODFOL" , "X3_RELACAO"	 )
	aHeader[ NX , __AHEADER_WHEN__		]	:= GetSx3Cache( "RV_CODFOL" , "X3_WHEN" )
	aHeader[ NX , __AHEADER_VISUAL__	]	:= GetSx3Cache( "RV_CODFOL" , "X3_VISUAL" )
	aHeader[ NX , __AHEADER_VLDUSR__	]	:= GetSx3Cache( "RV_CODFOL" , "X3_VLDUSER" )
	aHeader[ NX , __AHEADER_RESERV16__	]	:= GetSx3Cache( "RV_CODFOL" , "X3_OBRIGAT" )
	aHeader[ NX , __AHEADER_RESERV17__	]	:= If(!Empty(aHeader[ NX , __AHEADER_RESERV16__	]),.T.,.F.)

	If cModulo == "GFP" //campo RV_ACUMAUX disponivel apenas para o modulo GFP
		NX++
		aHeader[ NX , __AHEADER_TITLE__		]	:= GetSx3Cache( "RV_ACUMAUX" , "X3_TITULO" ) 		// "RV_ACUMAUX"
		aHeader[ NX , __AHEADER_FIELD__		]	:= "RV_ACUMAUX"
		aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RV_ACUMAUX" , "X3_PICTURE" )
		aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RV_ACUMAUX" , "X3_TAMANHO" )
		aHeader[ NX , __AHEADER_DEC__		]	:= GetSx3Cache( "RV_ACUMAUX" , "X3_DECIMAL" )
		aHeader[ NX , __AHEADER_VALID__		]	:= GetSx3Cache( "RV_ACUMAUX" , "X3_VALID" )
		aHeader[ NX , __AHEADER_USE__		]	:= GetSx3Cache( "RV_ACUMAUX" , "X3_USADO"	 )
		aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RV_ACUMAUX" , "X3_TIPO" )
		aHeader[ NX  , __AHEADER_F3__		]	:= GetSx3Cache( "RV_ACUMAUX" , "X3_F3" )
		aHeader[ NX , __AHEADER_CONTEXT__	]	:= GetSx3Cache( "RV_ACUMAUX" , "X3_CONTEXT"	 )
		aHeader[ NX , __AHEADER_CBOX__		]	:= GetSx3Cache( "RV_ACUMAUX" , "X3_CBOX"	 )
		aHeader[ NX , __AHEADER_INITPAD__	]	:= GetSx3Cache( "RV_ACUMAUX" , "X3_RELACAO"	 )
		aHeader[ NX , __AHEADER_WHEN__		]	:= GetSx3Cache( "RV_ACUMAUX" , "X3_WHEN" )
		aHeader[ NX , __AHEADER_VISUAL__	]	:= GetSx3Cache( "RV_ACUMAUX" , "X3_VISUAL" )
		aHeader[ NX , __AHEADER_VLDUSR__	]	:= GetSx3Cache( "RV_ACUMAUX" , "X3_VLDUSER" )
		aHeader[ NX , __AHEADER_RESERV16__	]	:= GetSx3Cache( "RV_ACUMAUX" , "X3_OBRIGAT" )
		aHeader[ NX , __AHEADER_RESERV17__	]	:= If(!Empty(aHeader[ NX , __AHEADER_RESERV16__	]),.T.,.F.)
	EndIf

	NX++
	aHeader[ NX , __AHEADER_TITLE__		]	:= GetSx3Cache( "RC_SEQ" , "X3_TITULO" ) 		// "RC_SEQ"
	aHeader[ NX , __AHEADER_FIELD__		]	:= "RC_SEQ"
	aHeader[ NX , __AHEADER_PICTURE__	]	:= GetSx3Cache( "RC_SEQ" , "X3_PICTURE" )
	aHeader[ NX , __AHEADER_WIDTH__		]	:= GetSx3Cache( "RC_SEQ" , "X3_TAMANHO" )
	aHeader[ NX , __AHEADER_DEC__		]	:= GetSx3Cache( "RC_SEQ" , "X3_DECIMAL" )
	aHeader[ NX , __AHEADER_VALID__		]	:= GetSx3Cache( "RC_SEQ" , "X3_VALID" )
	aHeader[ NX , __AHEADER_USE__		]	:= GetSx3Cache( "RC_SEQ" , "X3_USADO"	 )
	aHeader[ NX , __AHEADER_TYPE__		]	:= GetSx3Cache( "RC_SEQ" , "X3_TIPO" )
	aHeader[ NX  , __AHEADER_F3__		]	:= GetSx3Cache( "RC_SEQ" , "X3_F3" )
	aHeader[ NX , __AHEADER_CONTEXT__	]	:= GetSx3Cache( "RC_SEQ" , "X3_CONTEXT"	 )
	aHeader[ NX , __AHEADER_CBOX__		]	:= GetSx3Cache( "RC_SEQ" , "X3_CBOX"	 )
	aHeader[ NX , __AHEADER_INITPAD__	]	:= GetSx3Cache( "RC_SEQ" , "X3_RELACAO"	 )
	aHeader[ NX , __AHEADER_WHEN__		]	:= GetSx3Cache( "RC_SEQ" , "X3_WHEN" )
	aHeader[ NX , __AHEADER_VISUAL__	]	:= GetSx3Cache( "RC_SEQ" , "X3_VISUAL" )
	aHeader[ NX , __AHEADER_VLDUSR__	]	:= GetSx3Cache( "RC_SEQ" , "X3_VLDUSER" )
	aHeader[ NX , __AHEADER_RESERV16__	]	:= GetSx3Cache( "RC_SEQ" , "X3_OBRIGAT" )
	aHeader[ NX , __AHEADER_RESERV17__	]	:= If(!Empty(aHeader[ NX , __AHEADER_RESERV16__	]),.T.,.F.)

Endif

//CARREGA O AINFO COM OS DADOS DO SIGAMAT.EMP
If fInfo(@aInfo,SRA->RA_FILIAL)
	cFilAnterior:= SRA->RA_FILIAL
	cDescFil 	:= SUBSTR(SRA->RA_FILIAL+" - "+ aInfo[03],1,40)
	cDescEnd 	:= SUBSTR(aInfo[4],1,40)
	cDescCGC 	:= SUBSTR(aInfo[8],1,40)
EndIf

If ! Fp_CodFol(@aCodFol,SRA->RA_FILIAL)
	Return
Endif

cRoteiro := If(SRA->RA_CATFUNC $ "P*A",fGetCalcRot("9"),fGetRotOrdinar())	// ROTEIRO ORDINARIO PARA O PERIODO DE ADMISSAO E AUMENTO
cRotAnt  := cRoteiro

dbSelectArea( "RCH" )
dbSetOrder(5)
dbSeek(xFilial("RCH")+ cProcesso + cRoteiro + Space(8), .F.)
If Eof()
	cRoteiro := Space( GetSx3Cache( "RCH_ROTEIR", "X3_TAMANHO" ) )
	cRotAnt  := cRoteiro
	dbSeek(xFilial("RCH")+ cProcesso + cRoteiro + Space(8), .F.)
EndIf
While !Eof()
	If Empty(RCH->RCH_DTFECH) .AND. (RCH->RCH_PROCES == cProcesso) .And. RCH->RCH_ROTEIR == cRoteiro
		cPeriodo := RCH->RCH_PER
		cPerAnt	 := cPeriodo
		cSemana	 := RCH->RCH_NUMPAG
		cSemAnt	 := cSemana
		Exit
	EndIf
	dbSkip()
EndDo

// RETORNA O MES E O ANO DO PERIODO SELECIONADO NA PERGUNTE
AnoMesPer(cProcesso, cRoteiro, cPeriodo, @cMes, @cAno, cSemana)
dDataRef := LastDate(CTOD("01/" + cMes + "/" + cAno))

//Protecao de Dados Sensiveis
If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot) // CAMPOS SEM ACESSO

	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0 
		lOfuscaNom	:= FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_CODFUNC" } ) > 0 
		lOfuscaFun := FwProtectedDataUtil():IsFieldInList( "RA_CODFUNC" )
	ENDIF
EndIf

//CARREGA AS INFORMACOES INICIAIS DAS VARIAVEIS E DA GETDADOS
cFuncionario	:= SRA->RA_MAT +" - "+ If(lOfuscaNom,Replicate('*',15),SRA->RA_NOME)
cFuncao			:= If(lOfuscaFun,Replicate('*',5),SRA->RA_CODFUNC)+" - "+ If(lOfuscaFun,Replicate('*',15),fDesc( "SRJ" , SRA->RA_CODFUNC, "RJ_DESC" ))

If lGestPubl .AND. SRA->RA_REGIME == '2'
    cSalario := transform(fBuscaSal1(dDataRef,,,.T.),"@E 999,999,999.99")
Else
	cSalario		:= transform(SRA->RA_SALARIO,"@E 999,999,999.99")
Endif
If lGestPubl
    cCateg := SRA->RA_CATFUNC + " - " + ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"28"+SRA->RA_CATFUNC,"X5_DESCRI"))
    cRegime := If(SRA->RA_REGIME == "2","Estatutario","CLT")
    cTpPrev := If(SRA->RA_TPPREVI == "1","RGPS","RPPS")
EndIf

//Carregar os periodos abertos (aPerAberto) e/ou
// os periodos fechados (aPerFechado), dependendo
// do periodo (ou intervalo de periodos) selecionado
RetPerAbertFech(cProcesso	,; // Processo selecionado na Pergunte.
				cRoteiro	,; // Roteiro selecionado na Pergunte.
				cPeriodo	,; // Periodo selecionado na Pergunte.
				cSemana		,; // Numero de Pagamento selecionado na Pergunte.
				NIL			,; // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
				NIL			,; // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
				@aPerAberto	,; // Retorna array com os Periodos e NrPagtos Abertos
				@aPerFechado ) // Retorna array com os Periodos e NrPagtos Fechados

If Empty( cRoteiro )
	cRoteiro := cRotAnt
EndIf

a630MontaCols(SRA->RA_FILIAL,cMat,dDataRef)

// MONTA AS DIMENSOES DOS OBJETOS
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 10 , 5 }
aAdd( aObjCoords , { 000 , 035 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 025 , .T. , .F. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

// MOSTRA O CORPO DOS VALORES VARIAVEIS
nOpca := 0
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0003) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL	//"Consulta Lancamentos"

	// DEFINE GRUPO DO CABECALHO
	If lGestPubl
		@ aObjSize[1,1] , aObjSize[1,2] GROUP oGroup 		TO aObjSize[1,3],aObjSize[1,4]*0.25 LABEL OemToAnsi(STR0010) OF oDlg PIXEL	 //"Empresa"
		oGroup:oFont:= oFont
		@ aObjSize[1,1] , aObjSize[1,4]*0.255 GROUP oGroup 	TO aObjSize[1,3],aObjSize[1,4]*0.75 LABEL OemToAnsi(STR0043) OF oDlg PIXEL	 //"Servidor"
		@ aObjSize[1,1] , aObjSize[1,4]*0.755 GROUP oGroup 	TO aObjSize[1,3] ,aObjSize[1,4] 	LABEL OemToAnsi(STR0006) OF oDlg PIXEL	 //"Referencia"
	Else
		@ aObjSize[1,1] , aObjSize[1,2] GROUP oGroup 		TO aObjSize[1,3],aObjSize[1,4]*0.33 LABEL OemToAnsi(STR0010) OF oDlg PIXEL	 //"Empresa"
		oGroup:oFont:= oFont
		@ aObjSize[1,1] , aObjSize[1,4]*0.335 GROUP oGroup 	TO aObjSize[1,3],aObjSize[1,4]*0.66 LABEL OemToAnsi(STR0011) OF oDlg PIXEL	 //"Funcionario"
		@ aObjSize[1,1] , aObjSize[1,4]*0.665 GROUP oGroup 	TO aObjSize[1,3] ,aObjSize[1,4] 	LABEL OemToAnsi(STR0006) OF oDlg PIXEL	 //"Referencia"
	EndIf

	//DEFINE GRUPO DO RODAPE
	@ aObjSize[3,1], aObjSize[3,2]+2    	GROUP oGroup TO aObjSize[3,3], aObjSize[3,4]*0.33 LABEL OemToAnsi(STR0012) OF oDlg PIXEL	 //"Total de Proventos"
	@ aObjSize[3,1], aObjSize[3,4]*0.335	GROUP oGroup TO aObjSize[3,3], aObjSize[3,4]*0.66 LABEL OemToAnsi(STR0013) OF oDlg PIXEL	 //"Total de Descontos"
	@ aObjSize[3,1], aObjSize[3,4]*0.665	GROUP oGroup TO aObjSize[3,3], aObjSize[3,4]      LABEL OemToAnsi(STR0014) OF oDlg PIXEL	 //"Liquido"

	if lGestPubl
		@ aObjSize[4,1], aObjSize[4,2]		   	GROUP oGroup TO aObjSize[4,3], aObjSize[4,4]	  LABEL OemToAnsi(STR0044) OF oDlg PIXEL	 //"Pesquisar Servidores"
	Else
		@ aObjSize[4,1], aObjSize[4,2]		   	GROUP oGroup TO aObjSize[4,3], aObjSize[4,4]	  LABEL OemToAnsi(STR0025) OF oDlg PIXEL	 //"Pesquisar Funcionarios"
	endif


	// LISTA GRUPO EMPRESA
	@ aObjSize[1,1]+07.5, aObjSize[1,2]* 1.5	SAY  cDescFil	SIZE 146,10 OF oDlg PIXEL FONT oFont
	@ aObjSize[1,1]+14.5, aObjSize[1,2]* 1.5	SAY  cDescEnd 	SIZE 146,10 OF oDlg PIXEL FONT oFont
	@ aObjSize[1,1]+21.5, aObjSize[1,2]* 1.5	SAY  cDescCGC 	SIZE 146,10 OF oDlg PIXEL FONT oFont

	//LISTA GRUPO FUNCIONARIO
	If lGestPubl
		@ aObjSize[1,1]+07.5, aObjSize[1,4]*0.27 SAY  oFunc    Var cFuncionario							 SIZE 146,10 OF oDlg PIXEL FONT oFont
		@ aObjSize[1,1]+07.5, aObjSize[1,4]*0.55 SAY  oRegime  Var (OemToAnsi(STR0046) + cRegime )		 SIZE 146,10 OF oDlg PIXEL FONT oFont //'Regime: '
		@ aObjSize[1,1]+14.5, aObjSize[1,4]*0.27 SAY  oFuncao  Var (OemtoAnsi(STR0015) + cFuncao )		 SIZE 146,10 OF oDlg PIXEL FONT oFont
		@ aObjSize[1,1]+14.5, aObjSize[1,4]*0.55 SAY  oPrev	   Var (OemToAnsi(STR0047) + cTpPrev )		 SIZE 146,10 OF oDlg PIXEL FONT oFont //'Previd.: '
		@ aObjSize[1,1]+21.5, aObjSize[1,4]*0.27 SAY  oSalario Var (OemToAnsi(STR0016) + "-"+ cSalario ) SIZE 146,10 OF oDlg PIXEL FONT oFont
		@ aObjSize[1,1]+21.5, aObjSize[1,4]*0.55 SAY  oCateg   Var (OemToAnsi(STR0048) + cCateg )		 SIZE 146,50 OF oDlg PIXEL FONT oFont //'Categoria: '
	Else
		@ aObjSize[1,1]+07.5, aObjSize[1,4]*0.35 SAY  oFunc    Var cFuncionario                       SIZE 146,10 OF oDlg PIXEL FONT oFont
		@ aObjSize[1,1]+14.5, aObjSize[1,4]*0.35 SAY  oFuncao  Var (OemtoAnsi(STR0015) + cFuncao )    SIZE 146,10 OF oDlg PIXEL FONT oFont
		@ aObjSize[1,1]+21.5, aObjSize[1,4]*0.35 SAY  oSalario Var (OemToAnsi(STR0016)+ " "+cSalario) SIZE 146,10 OF oDlg PIXEL FONT oFont
	EndIf

	//LISTA GRUPO REFERENCIA
	//--> Adicionado GET para capturar o Processo
	@ aObjSize[1,1]+07.5, (  (aObjSize[1,4]*0.68) )	SAY   STR0042   			 			 SIZE 146,10 OF oDlg PIXEL FONT oFont //"Processo  "
	@ aObjSize[1,1]+14.5, (  (aObjSize[1,4]*0.68) )	MsGet oProcesso  VAR cProcesso F3 "RCJ2" SIZE 40,10  OF oDlg PIXEL FONT oFont HASBUTTON

	@ aObjSize[1,1]+07.5, (  (aObjSize[1,4]*0.76) )	SAY   STR0026   			 			SIZE 146,10 OF oDlg PIXEL FONT oFont //"Periodo  "
	@ aObjSize[1,1]+14.5, (  (aObjSize[1,4]*0.76) )	MsGet oPeriodo  VAR cPeriodo F3 "RCH"	SIZE 40,10  OF oDlg PIXEL FONT oFont valid ExistCpo("RCH", cProcesso + cPeriodo, 1) .and. SetRoteiro() .and. Gp630Movimenta(bFica) HASBUTTON
	@ aObjSize[1,1]+07.5, (  (aObjSize[1,4]*0.855) )	SAY   STR0018    			 			SIZE 146,10 OF oDlg PIXEL FONT oFont //"Semana "
	@ aObjSize[1,1]+14.5, (  (aObjSize[1,4]*0.855) )	MsGet oSemana 	VAR cSemana  F3 "RCH01" SIZE 10,10  OF oDlg PIXEL FONT oFont PICTURE "99" Valid ExistCpo("RCH", cProcesso + cPeriodo + cSemana, 1) .and. Gp630Movimenta(bFica) HASBUTTON
	@ aObjSize[1,1]+07.5, (  (aObjSize[1,4]*0.93) )	SAY   STR0019    			 			SIZE 146,10 OF oDlg PIXEL FONT oFont //"Tipo"
    @ aObjSize[1,1]+14.5, (  (aObjSize[1,4]*0.93) )	MsGet oRoteiro 	VAR cRoteiro 			SIZE 30,10  OF oDlg PIXEL FONT oFont valid f030Roteiro(.T.,,.F.) .and. ExistCpo("SRY", cRoteiro, 1) .and. Gp630Movimenta(bFica)

	//LISTA GRUPO TOTAIS
	@ aObjSize[3,1]+10, aObjSize[3,2]*2.5   SAY  oTotProv VAR nTotProv 	SIZE 146,10 OF oDlg PIXEL FONT oFont Picture "@E 999,999,999.99"
	@ aObjSize[3,1]+10, aObjSize[3,4]*0.35  SAY  oTotDesc VAR nTotDESC 	SIZE 146,10 OF oDlg PIXEL FONT oFont Picture "@E 999,999,999.99"
	@ aObjSize[3,1]+10, aObjSize[3,4]*0.68	SAY  oTotLIq  VAR nTotLiq 	SIZE 146,10 OF oDlg PIXEL FONT oFont Picture "@E 999,999,999.99"

	//LISTA BOTOES DE POSICIONAMENTO DO FUNCIONARIO
	@ aObjSize[4,1]+10, aObjSize[3,2]+08.96	BUTTON oBtnPgPrev 	PROMPT OemToAnsi("<<")	 SIZE 021.5,009 DESIGN ACTION Gp630Movimenta(bRetrocAll) OF oDlg PIXEL
	@ aObjSize[4,1]+10, aObjSize[3,2]+29.96	BUTTON oBtnPrev		PROMPT OemToAnsi("<")	 SIZE 021.5,009 DESIGN ACTION Gp630Movimenta(bRetrocOne) OF oDlg PIXEL
	@ aObjSize[4,1]+10, aObjSize[3,2]+50.96	BUTTON oBntNext 	PROMPT OemToAnsi(">")	 SIZE 021.5,009 DESIGN ACTION Gp630Movimenta(bAvancaOne) OF oDlg PIXEL
	@ aObjSize[4,1]+10, aObjSize[3,2]+71.96	BUTTON oBtnPgNext 	PROMPT OemToAnsi(">>")	 SIZE 021.5,009 DESIGN ACTION Gp630Movimenta(bAvancaALL) OF oDlg PIXEL

    AxPesqOrd("SRA",@aPesqIdx,,lSeeAll,@aPesqOrd)
    cPesqOrd := aPesqOrd[1]

	@ aObjSize[4,1]+10, aObjSize[3,4]*0.32 COMBOBOX oPesqCbx VAR cPesqOrd ITEMS aPesqOrd SIZE 100,36 PIXEL OF oDlg ;
	      ON CHANGE If(lAxPesqui,(DbSelectArea(cAlias),DbSetOrder(aPesqIdx[oPesqCbx:nAt][1]),__oObjBrow:Refresh()),)

  	@ aObjSize[4,1]+10, (aObjSize[3,4]*0.32)+115 MSGET oPesqGet VAR cPesqCampo SIZE 100,09 PIXEL OF oDlg

   @ aObjSize[4,1]+10, (aObjSize[4,4]*0.32)+215 BUTTON "Ok" SIZE 021.5,009 PIXEL OF oDlg ;     //"Pesquisar"
		      ACTION (AxPesqSeek("SRA",.F.,cPesqCampo,,aPesqIdx,oPesqCbx:nAt,lSeeAll,),Gp630Movimenta(bFica,.T.))

	oGet	:= MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpcx,,,"",.F.,,2)

	bSet15	:= {||nopca:=1,oDlg:End()}
	bSet24	:= {||oDlg:End()}
	If lHistMed
		Aadd(aButtons, {"CARGA", {|| fMedHist() }, OemToAnsi( STR0049 ) }) //"Médias"
	EndIf
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ,,aButtons) CENTERED

cAlias := "SRA"
dbSelectArea(cAlias)
dbGoTo( nSavRec )
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³a630MontaColsºAutor  ³Microsiga           º Data ³  12/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta o aCols com base nos dados dos lancamentos mensais       º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a630MontaCols(cFil,cMatricula,dDataRef)

Local cAcessaSRA  	:= &("{ || " + ChkRH("GPER030","SRA","2") + "}")
Local cAcessaSRC  	:= &("{ || " + ChkRH("GPER030","SRC","2") + "}")
Local cAcessaSRD  	:= &("{ || " + ChkRH("GPER030","SRD","2") + "}")
Local cAcessaSRV  	:= &("{ || " + ChkRH("GPER030","SRV","2") + "}")
Local cNroHoras   	:= &("{ || If(aVerbasFunc[nReg,5] > 0, aVerbasFunc[nReg,5], aVerbasFunc[nReg,6]) }")
Local nAteLim 		:= 0
Local nBaseFgts		:= 0
Local nFgts 		:= 0
Local nBaseIr 		:= 0
Local nBaseIrFe 	:= 0
Local nCnt			:= 0
Local nI
Local nReg			:= 0
Local nHoras		:= 0
Private aLanca		:={}         // Zera Lancamentos
Private aProve		:={}         // Zera Lancamentos
Private aDesco		:={}         // Zera Lancamentos
Private aBases		:={}         // Zera Lancamentos

	// Zera as variaveis totalizadoras
	nTotLiq	:= nTotdesc	:= nTotProv	:= 0
	aCols := {}
	// CARREGA ACODFOL
	If cFil # cFilAnterior
		If ! Fp_CodFol(@aCodFol,cFil)
			Return
		Endif
		cFilAnterior:= cFil
	Endif

	//RETORNA AS VERBAS DO FUNCIONARIO, DE ACORDO COM OS PERIODOS SELECIONADOS
	aVerbasFunc	:= RetornaVerbasFunc(cFil, cMatricula, NIL, cRoteiro, NIL, aPerAberto, aPerFechado)

	For nReg := 1 to Len(aVerbasFunc)
		If (Len(aPerAberto) > 0 .AND. !Eval(cAcessaSRC)) .OR. (Len(aPerFechado) > 0 .AND. !Eval(cAcessaSRD))
			dbSkip()
			Loop
		EndIf

		If PosSrv( aVerbasFunc[nReg,3] , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
			nHoras := Eval(cNroHoras)
			fSomaPdRec("P",aVerbasFunc[nReg,3],nHoras,aVerbasFunc[nReg,7])
			nTOTPROV += aVerbasFunc[nReg,7]
		Elseif SRV->RV_TIPOCOD == "2"
			fSomaPdRec("D",aVerbasFunc[nReg,3],Eval(cNroHoras),aVerbasFunc[nReg,7])
			nTOTDESC += aVerbasFunc[nReg,7]
		Elseif SRV->RV_TIPOCOD $ "3/4"
			fSomaPdRec("B",aVerbasFunc[nReg,3],Eval(cNroHoras),aVerbasFunc[nReg,7])
		Endif

		If aVerbasFunc[nReg,3] $ aCodFol[10,1]+'*'+aCodFol[15,1]+'*'+aCodFol[27,1]
			nBaseIr += aVerbasFunc[nReg,7]
		ElseIf aVerbasFunc[nReg,3] $ aCodFol[13,1]+'*'+aCodFol[19,1]
			nAteLim += aVerbasFunc[nReg,7]
		Elseif aVerbasFunc[nReg,3] $ aCodFol[108,1]+'*'+aCodFol[17,1]
			nBaseFgts += aVerbasFunc[nReg,7]
		Elseif aVerbasFunc[nReg,3] $ aCodFol[109,1]+'*'+aCodFol[18,1]
			nFgts += aVerbasFunc[nReg,7]
		Elseif aVerbasFunc[nReg,3] == aCodFol[16,1]
			nBaseIrFe += aVerbasFunc[nReg,7]
		Endif
	Next nReg

// MONTA O ACOLS COM OS VALORES CALCULADOS
nCnt   :=0
If len(aProve) > 0
	For nI :=1 to len(aProve)
		AAdd(aCols,Array(len(aHeader)))
		nCnt++

		aCols[nCnt,1] := substr(aProve[nI,1],1,3)  //verba
		aCols[nCnt,2] := substr(aProve[nI,1],4)    //Descricao
		aCols[nCnt,3] := aProve[nI,2]              //quantidade
		aCols[nCnt,4] := aProve[nI,3]              //valor

		IF lGestPubl
			aCols[nCnt,07] := aVerbasFunc[aScan(aVerbasFunc,{|x| x[3] == aCols[nCnt,1]}),04] //SRC->RC_TIPO1
			aCols[nCnt,08] := aVerbasFunc[aScan(aVerbasFunc,{|x| x[3] == aCols[nCnt,1]}),17] //SRC->RC_TIPO2
			aCols[nCnt,09] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_INSS" )
			aCols[nCnt,10] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_IR" )
			aCols[nCnt,11] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_REFFER" )
			aCols[nCnt,12] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_REF13" )
			aCols[nCnt,13] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_INCORP" )
			aCols[nCnt,14] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_FGTS" )
			aCols[nCnt,15] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_CODFOL" )
			If cModulo == "GFP" //campo RV_ACUMAUX disponivel apenas para o modulo GFP
				aCols[nCnt,16] := ALLTRIM(PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_ACUMAUX" ))
				aCols[nCnt,17] := aVerbasFunc[aScan(aVerbasFunc,{|x| x[3] == aCols[nCnt,1]}),15] //SRC->RC_SEQ
			Else
				aCols[nCnt,16] := aVerbasFunc[aScan(aVerbasFunc,{|x| x[3] == aCols[nCnt,1]}),15]
			EndIf
		EndIf
	Next
EndIf
If len(aDesco) >0
	For nI :=1 to len(aDesco)
		AAdd(aCols,Array(len(aHeader)))
		nCnt++

		aCols[nCnt,1] := substr(aDesco[nI,1],1,3)
		aCols[nCnt,2] := substr(aDesco[nI,1],4)
		aCols[nCnt,3] := aDesco[nI,2]
		aCols[nCnt,5] := aDesco[nI,3]


		IF lGestPubl
			aCols[nCnt,07] := aVerbasFunc[aScan(aVerbasFunc,{|x| x[3] == aCols[nCnt,1]}),04]
			aCols[nCnt,08] := aVerbasFunc[aScan(aVerbasFunc,{|x| x[3] == aCols[nCnt,1]}),17]
			aCols[nCnt,09] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_INSS" )
			aCols[nCnt,10] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_IR" )
			aCols[nCnt,11] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_REFFER" )
			aCols[nCnt,12] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_REF13" )
			aCols[nCnt,13] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_INCORP" )
			aCols[nCnt,14] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_FGTS" )
			aCols[nCnt,15] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_CODFOL" )
			If cModulo == "GFP" //campo RV_ACUMAUX disponivel apenas para o modulo GFP
				aCols[nCnt,16] := ALLTRIM(PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_ACUMAUX" ))
				aCols[nCnt,17] := aVerbasFunc[aScan(aVerbasFunc,{|x| x[3] == aCols[nCnt,1]}),15]
			Else
				aCols[nCnt,16] := aVerbasFunc[aScan(aVerbasFunc,{|x| x[3] == aCols[nCnt,1]}),15]
			EndIf
		EndIf
	Next
EndIf
If len(aBases)>0
	For nI :=1 to len(aBases)
		AAdd(aCols,Array(len(aHeader)))
		nCnt++

		aCols[nCnt,1] := substr(aBases[nI,1],1,3)
		aCols[nCnt,2] := substr(aBases[nI,1],4)
		aCols[nCnt,3] := aBases[nI,2]
		aCols[nCnt,6] := aBases[nI,3]

		IF lGestPubl
			aCols[nCnt,07] := aVerbasFunc[aScan(aVerbasFunc,{|x| x[3] == aCols[nCnt,1]}),04]
			aCols[nCnt,08] := aVerbasFunc[aScan(aVerbasFunc,{|x| x[3] == aCols[nCnt,1]}),17]
			aCols[nCnt,09] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_INSS" )
			aCols[nCnt,10] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_IR" )
			aCols[nCnt,11] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_REFFER" )
			aCols[nCnt,12] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_REF13" )
			aCols[nCnt,13] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_INCORP" )
			aCols[nCnt,14] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_FGTS" )
			aCols[nCnt,15] := PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_CODFOL" )
			If cModulo == "GFP" //campo RV_ACUMAUX disponivel apenas para o modulo GFP
				aCols[nCnt,16] := ALLTRIM(PosSrv( aCols[nCnt,1] , XFILIAL("SRV") , "RV_ACUMAUX" ))
				aCols[nCnt,17] := aVerbasFunc[aScan(aVerbasFunc,{|x| x[3] == aCols[nCnt,1]}),15]
			Else
				aCols[nCnt,16] := aVerbasFunc[aScan(aVerbasFunc,{|x| x[3] == aCols[nCnt,1]}),15]
			EndIf
		EndIf
	Next
EndIf

If len(aCols) == 0
	if lGestPubl
    	Aviso( STR0020,STR0045, { "Ok" },, )   //Atencao##"Nao existe lancamentos para este servidor"
	Else
		Aviso( STR0020,STR0024, { "Ok" },, )   //Atencao##"Nao existe lancamentos para este funcionario"
	endif
	aCols := GdRmkaCols( aHeader )
EndIf

nTotLiq := nTotProv-nTotDesc

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao  ³Gp630MovimentaºAutor  ³Microsiga           º Data ³  12/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³ Executa bloco de codigo a cada movimentacao dos botoes de      º±±
±±º        ³ movimentacao.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso     ³ AP                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp630Movimenta(bFunc,lPesq)
DEFAULT lPesq := .F.
If lPesq .and. cProcesso <> SRA->RA_PROCES //Se utilizou a barra de pesquisa, e o processo é diferente, altera variaveis.
	cProcesso := SRA->RA_PROCES
	cRoteiro := If(SRA->RA_CATFUNC $ "P*A",fGetCalcRot("9"),fGetRotOrdinar())
EndIf
Eval(bFunc)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao  ³a630AtualFuncºAutor  ³Microsiga           º Data ³  12/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³ Atualiza os dados do funcionario na tela e chama a rotina paraº±±
±±º        ³ refazer o aCols.                                              º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso     ³ AP                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function a630AtualFunc(cDescFil,cDescEnd,cDescCGC,cFuncionario,cFuncao,cSalario,cSemana,cCateg,cRegime,cTpPrev)
Local cCodFunc		:= ""		//-- codigo da Funcao do funcionario
Local cDescFunc		:= ""		//-- Descricao da Funcao do Funcionario
Local cMes			:= ""
Local cAno			:= ""
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Local aFldRot 		:= {'RA_NOME', 'RA_CODFUNC'}
Local aFldOfusca 	:= {}

Local lOfuscaNom	:= .F.
Local lOfuscaFun	:= .F.

//Dados da Filial
If SRA->( EOF() )
    Aviso( STR0020,STR0027, { "Ok" },, )
	SRA->( dbSkip(-1))
	return
EndIf

If SRA->RA_FILIAL # cFilAnterior
	If fInfo(@aInfo,SRA->RA_FILIAL)
		cFilAnterior:= SRA->RA_FILIAL
		cDescFil 	:= SUBSTR(SRA->RA_FILIAL+" - "+ aInfo[03],1,40)
		cDescEnd 	:= SUBSTR(aInfo[4],1,40)
		cDescCGC 	:= SUBSTR(aInfo[8],1,40)
	EnDif
EndIf

If Empty(cRoteiro)
	// Recupera o roteiro do periodo/numero de pagamento informado.
	cRoteiro	:= gp240RetCont("RCH", 1, xFilial("RCH") + cProcesso + cPeriodo + cSemana, "RCH_ROTEIR")
	If Empty(cRoteiro)
		cRoteiro := SPACE(3)
	EndIf
EndIf

// Retorna o mes e o ano do periodo selecionado na pergunte.
AnoMesPer(cProcesso, cRoteiro, cPeriodo, @cMes, @cAno, cSemana )
dDataRef := CTOD("01/" + cMes + "/" + cAno)

//SE MUDOU AS INFORMACOES DE DATA, SEMANA OU TIPO DE LANCAMENTO ATUALIZA AS INFORMACOES E DA REFRESH NA JANELA
lDaRefresh := .F.
If !(cPeriodo == cPerAnt) .or. !(cSemana == cSemAnt) .or. !(cRoteiro == cRotAnt)
	lDaRefresh 	:= .T.

	cPerAnt		:=	cPeriodo
	cSemAnt		:= 	cSemana
	cRotAnt		:= 	cRoteiro

	//Carregar os periodos abertos (aPerAberto) e/ou
	// os periodos fechados (aPerFechado), dependendo
	// do periodo (ou intervalo de periodos) selecionado
	RetPerAbertFech(cProcesso	,; // Processo selecionado na Pergunte.
					cRoteiro	,; // Roteiro selecionado na Pergunte.
					cPeriodo	,; // Periodo selecionado na Pergunte.
					cSemana		,; // Numero de Pagamento selecionado na Pergunte.
					NIL			,; // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
					NIL			,; // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
					@aPerAberto	,; // Retorna array com os Periodos e NrPagtos Abertos
					@aPerFechado ) // Retorna array com os Periodos e NrPagtos Fechados
EndIf

// CARREGA FUNCAO DO FUNCION. DE ACORDO COM A DT REFERENCIA
fBuscaFunc(dDataRef,@cCodFunc, @cDescFunc )

//Protecao de Dados Sensiveis
If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot) // CAMPOS SEM ACESSO

	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0 
		lOfuscaNom	:= FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_CODFUNC" } ) > 0 
		lOfuscaFun := FwProtectedDataUtil():IsFieldInList( "RA_CODFUNC" )
	ENDIF
EndIf


// ATUALIZA OS DADOS DO FUNCIONARIO
cFuncionario	:= SRA->RA_MAT +" - " + If(lOfuscaNom,Replicate('*',15),SRA->RA_NOME)
cFuncao 		:= If(lOfuscaFun,Replicate('*',5),cCodFunc) + " - " + If(lOfuscaFun,Replicate('*',15),cDescFunc)

If lGestPubl .AND. SRA->RA_REGIME == '2'
   cSalario := transform(fBuscaSal1(dDataRef,,,.T.),"@E 999,999,999.99")
ElseIf !empty(cAno) .AND. !empty(cMes)
   cSalario := transform(fBuscaSal(dDataRef, Nil, Nil, .F.),"@E 999,999,999.99")
Else
   cSalario := transform(SRA->RA_SALARIO,"@E 999,999,999.99")
Endif
If lGestPubl
   cCateg := SRA->RA_CATFUNC + " - " + ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"28"+SRA->RA_CATFUNC,"X5_DESCRI"))
   cRegime := If(SRA->RA_REGIME == "2","Estatutario","CLT")
   cTpPrev := If(SRA->RA_TPPREVI == "1","RGPS","RPPS")
EndIf

nTotLiq			:= nTotProv-nTotDesc

//CHAMA FUNCAO PARA MONTAGEM DO ACOLS
a630MontaCols( SRA->RA_FILIAL,SRA->RA_MAT,dDataRef)

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³08/01/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA630                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function MenuDef()
Local aRotina :=   {	{ STR0001 , "PesqBrw",	0 , 1 , ,.F.},;	//"Pesquisar"
						{ STR0002 , "gp630Vis",	0 , 2},;			//"Visualiza"
						{ STR0028 , "gpLegend", 0 , 5 , ,.F.} }	//"Legenda"

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA630   ºAutor  ³Microsiga           º Data ³  08/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seta o roteiro para o retorno da consulta padrao RCH        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC FUNCTION SetRoteiro()
	If (!(Type("cRoteiro") == "U") .AND. !(Type("RCH->RCH_ROTEIR") == "U"))
		cRoteiro := RCH->RCH_ROTEIR
	EndIf
Return .T.

Static Function fMedHist()
Local dRef := Stod(cPeriodo+"01" )
If fTemHMed(dRef,,cPeriodo,oSemana:cText,cRoteiro)
	fVerHistMed("",dRef)
Else
	Aviso(STR0020,STR0050) //Atenção##"Sem dados para imprimir!"
EndIf

Return