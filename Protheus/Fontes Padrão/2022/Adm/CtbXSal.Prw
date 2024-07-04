#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBXSAL.CH"
#include "tbiconn.ch"

STATIC __aTmpTCFil	:= {}
STATIC lFWCodFil 	:= FindFunction("FWCodFil")

STATIC aCubsCTB
Static lCtbIsCube 	:= FindFunction("CtbIsCube")
Static __cArqEnt

STATIC __lBlind		:= IsBlind()
Static lAutomato	:= IsBlind()

Static nQtdEntid

STATIC _lCtbIsCube  := FindFunction("CtbIsCube")

Static _oTempTable
Static _oTempTbPLRef
Static __oTmpCT1		:= Nil
Static __oTmpCTT		:= Nil

Static _oHashCt1

// NAO REMOVER
Static lHasCVXLP	:= CVX->( FieldPos("CVX_LP") ) > 0
Static lHasCVYLP	:= CVY->( FieldPos("CVY_LP") ) > 0

Static __IsCtbJob	:= IIf( IsCtbJob(), .T., .F. )
Static __lPlGeren

Static cTipoCTS := FWSX3Util():GetFieldType('CTS_COLUNA')
Static __Release  :=  Iif(GetRPORelease() >= "12.1.2210", .T.,.F.)  
Static __lCOLUN2   // indica se a coluna CTS_COLUN2 existe

//AMARRACAO

//-------------------------------------------------------------------
/*/{Protheus.doc} SldAntCTU
Recupera saldo anterior a data inicial

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
/*/
//-------------------------------------------------------------------
Function SLDANTCTU(cIdent,cCodigo,dData,cMoeda,cTpSald,cFilx)

Local aRet := {}
Local nAntDeb		:= 0	//Saldo anterior Debito Conta
Local nAntCrd		:= 0	//Saldo anterior Credito Conta
Local cCCusto := ""
Local cItem 	:= ""
Local cClasse := ""

If cIdent $ 'CT3/CTT'
	cIdent		:= "CTT"
	cCCusto	:= cCodigo
ElseIf cIdent $ 'CT4/CTD'
	cIdent		:= "CTD"
	cItem 		:= cCodigo
ElseIf cIdent $ 'CTI/CTH'
	cIdent		:= "CTH"
	cClasse	:= cCodigo
EndIf

aRet := SaldoCQ("CTU",/*cConta*/,@cCusto,@cItem,@cClasse,@cIdent,@dData,@cMoeda,@cTpSald,/*cRotina*/,/*lImpAntLP*/,/*dDataLP*/,@cFilX,.F.)

nAntDeb		:= aRet[7]	//Saldo anterior Debito Conta
nAntCrd		:= aRet[8]	//Saldo anterior Credito Conta


Return{nAntDeb,nAntCrd}

//-------------------------------------------------------------------
/*{Protheus.doc} SLDANTCTV
Recupera saldo anterior a data inicial

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function SLDANTCTV(cCusto,cItem,dData,cMoeda,cTpSald,cFilx)

Local aRet := {}
Local nAntDeb		:= 0	//Saldo anterior Debito Conta
Local nAntCrd		:= 0	//Saldo anterior Credito Conta


aRet := SaldoCQ("CTD",/*cConta*/,@cCusto,@cItem,/*cClasse*/,/*cIdent*/,@dData,@cMoeda,@cTpSald,/*cRotina*/,/*lImpAntLP*/,/*dDataLP*/,@cFilX,.F.)

nAntDeb		:= aRet[7]	//Saldo anterior Debito Conta
nAntCrd		:= aRet[8]	//Saldo anterior Credito Conta


Return{nAntDeb,nAntCrd}


//-------------------------------------------------------------------
/*{Protheus.doc} SldAntCTW
Recupera saldo anterior a data inicial

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function SLDANTCTW(cClVl,cCusto,dData,cMoeda,cTpSald,cFilx)
Local aRet := {}
Local nAntDeb		:= 0	//Saldo anterior Debito Conta
Local nAntCrd		:= 0	//Saldo anterior Credito Conta


aRet := SaldoCQ("CTH",/*cConta*/,@cCusto,/*cItem*/,@cClVl,/*cIdent*/,@dData,@cMoeda,@cTpSald,/*cRotina*/,/*lImpAntLP*/,/*dDataLP*/,@cFilX,.F.)

nAntDeb		:= aRet[7]	//Saldo anterior Debito Conta
nAntCrd		:= aRet[8]	//Saldo anterior Credito Conta


Return{nAntDeb,nAntCrd}


//-------------------------------------------------------------------
/*{Protheus.doc} SldAntCTX
Recupera saldo anterior a data inicial

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function SLDANTCTX(cClVl,cItem,dData,cMoeda,cTpSald,cFilx)
Local aRet := {}
Local nAntDeb		:= 0	//Saldo anterior Debito Conta
Local nAntCrd		:= 0	//Saldo anterior Credito Conta


aRet := SaldoCQ("CTH",/*cConta*/,/*cCusto*/,@cItem,@cClVl,/*cIdent*/,@dData,@cMoeda,@cTpSald,/*cRotina*/,/*lImpAntLP*/,/*dDataLP*/,@cFilX,.F.)

nAntDeb		:= aRet[7]	//Saldo anterior Debito Conta
nAntCrd		:= aRet[8]	//Saldo anterior Credito Conta


Return{nAntDeb,nAntCrd}



//-------------------------------------------------------------------
/*{Protheus.doc} SLDANTCTY
Recupera saldo anterior a data inicial

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function SLDANTCTY(cClVl,cItem,cCusto,dData,cMoeda,cTpSald,cFilx)

Local aRet := {}
Local nAntDeb		:= 0	//Saldo anterior Debito Conta
Local nAntCrd		:= 0	//Saldo anterior Credito Conta


aRet := SaldoCQ("CTH",/*cConta*/,@cCusto,@cItem,@cClVl,/*cIdent*/,@dData,@cMoeda,@cTpSald,/*cRotina*/,/*lImpAntLP*/,/*dDataLP*/,@cFilX,.F.)

nAntDeb		:= aRet[7]	//Saldo anterior Debito Conta
nAntCrd		:= aRet[8]	//Saldo anterior Credito Conta


Return{nAntDeb,nAntCrd}


//-------------------------------------------------------------------
/*/{Protheus.doc} CtGerPlan
Gerar Arquivo Temporario para Balancetes.

@author Alvaro Camillo Neto

@param oMeter       Controle da regua
@param oText        Controle da regua
@param oDlg         Janela
@param lEnd         Controle da regua @param > finalizar
@param cArqTmp      Arquivo temporario
@param dDataIni     Data Inicial de Processamento
@param dDataFim     Data Final de Processamento
@param cAlias       Alias do Arquivo
@param cIdent       Identificador do arquivo a ser processado
@param cContaIni    Conta Inicial
@param cContaFim	 Conta Final
@param cCCIni       Centro de Custo Inicial
@param cCCFim       Centro de Custo Final
@param cItemIni     Item Inicial
@param cItemFim     Item Final
@param cClvlIni     Classe de Valor Inicial
@param cClvlFim     Classe de Valor Final
@param cMoeda       Moeda
@param cSaldos      Tipos de Saldo a serem processados
@param aSetOfBook   Matriz de configuracao de livros
@param cSegmento    Indica qual o segmento sera filtrado
@param cSegIni      Conteudo Inicial do segmento
@param cSegFim      Conteudo Final do segmento
@param cFiltSegm    Filtra por Segmento
@param lNImpMov     Se Imprime Entidade sem movimento
@param lImpConta    Se Imprime Conta
@param nGrupo       Grupo
@param cHeader      Identifica qual a Entidade Principal
@param lImpAntLP    Se imprime lancamentos Lucros e Perdas
@param dDataLP      Data da ultima Apuracao de Lucros e Perdas
@param nDivide      Divide valores por (100,1000,1000000)
@param lVlrZerado   Grava ou nao valores zerados no arq temporario
@param cFiltroEnt   Entidade Gerencial que servira de filtro dentro
              		 de outra Entidade Gerencial. Ex.: Centro de Custo
              		 sendo filtrado por Item Contabil (CTH)
@param cCodFilEnt   Codigo da Entidade Gerencial utilizada como filtro
@param cSegmentoG   Filtra por Segmento Gerencial (CC/Item ou ClVl)
@param cSegIniG     Segmento Gerencial Inicial
@param cSegFimG     Segmento Gerencial Final
@param cFiltSegmG   Segmento Gerencial Contido em
@param lUsGaap      Se e Balancete de Conversao de moeda
@param cMoedConv    Moeda para a qual buscara o criterio de conversao
              		 no Pl.Contas
@param cConsCrit    Criterio de conversao utilizado: 1@param Diario, 2@param Medio,
              		 3@param Mensal, 4@param Informada, 5@param Plano de Contas
@param dDataConv    Data de Conversao
@param nTaxaConv    Taxa de Conversao
@param aGeren       Matriz que armazena os compositores do Pl. Ger.
			       	 para efetuar o filtro de relatorio.
@param lImpMov      Nao utilizado
@param lImpSint     Se atualiza sinteticas
@param cFilUSU      Filtro informado pelo usuario
@param lRecDesp0    Se imprime saldo anterior do periodo anterior
               		zerado
@param cRecDesp     Grupo de receitas e despesas
@param dDtZeraRD    Data de zeramento de receitas e despesas
@param lImp3Ent     Se e Balancete C.Custo / Conta / Item
@param lImp4Ent     Se e Balancete por CC x Cta x Item x Cl.Valor
@param lImpEntGer   Se e Balancete de Entidade (C.Custo/Item/Cl.Vlr
               		por Entid. Gerencial)
@param lFiltraCC    Se considera o filtro das perguntas para C.Custo
@param lFiltraIt    Se considera o filtro das perguntas para Item
@param lFiltraCV    Se considera o filtro das perguntas para Cl.Valor
@param cMoedaDsc    Codigo da moeda para descricao das entidades
@param lMovPeriodo  Se imprime movimento do periodo anterior
@param aSelFil      Array de filiais
@param dDtCorte     Data de Corte para calculo do saldo anterior
@param lPlGerSint   Imprime visao gerencial sintetica? Padrao .F.
@param lConsSaldo   Consolida saldo ? Padrao .F.
@param lCompEnt     Consolida saldo entre entidades? Padrao .F.
@param cArqAux      Arquivo auxiliar permitindo a recursividade
@param lUsaNmVis    Usa nome da visao gerencial ? Padrao .F.
@param cNomeVis     Nome da visao gerencial (retorno, passar por ref.)
@param lCttSint     Indica se imprime ou n„o C.Custo SintÈticos
@param cQuadroCTB   CODIGO DO QUADRO CONTABIL
@param aEntidades   Array com as entidades de inicio e fim
        				 Ex. {'Cta Ent. 05 Inicio','Cta. Ent. 05 Final'}
@param cCodEntidade Codigo da Entidade


@version P12
@since   20/02/2014
@return  Nil
@obs
/*/
//-------------------------------------------------------------------

Function CTGerPlan(	oMeter,oText,oDlg,lEnd,cArqtmp,dDataIni,dDataFim,cAlias,cIdent,cContaIni,cContaFim,;
					cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,cMoeda,cSaldos,aSetOfBook,cSegmento,;
					cSegIni,cSegFim,cFiltSegm,lNImpMov,lImpConta,nGrupo,cHeader,lImpAntLP,dDataLP,;
					nDivide,lVlrZerado,cFiltroEnt,cCodFilEnt,cSegmentoG,cSegIniG,cSegFimG,cFiltSegmG,;
					lUsGaap,cMoedConv,cConsCrit,dDataConv,nTaxaConv,aGeren,lImpMov,lImpSint,cFilUSU,lRecDesp0,;
					cRecDesp,dDtZeraRD,lImp3Ent,lImp4Ent,lImpEntGer,lFiltraCC,lFiltraIt,lFiltraCV,cMoedaDsc,;
					lMovPeriodo,aSelFil,dDtCorte,lPlGerSint,lConsSaldo,lCompEnt,cArqAux,lUsaNmVis,cNomeVis,lCttSint,;
					lTodasFil,cQuadroCTB,aEntidades,cCodEntidade,lDemDRE , dFinalA)

Local aTamConta		:= TAMSX3("CT1_CONTA")
Local aTamCtaRes	:= TAMSX3("CT1_RES")
Local aTamCC        := TAMSX3("CTT_CUSTO")
Local aTamCCRes 	:= TAMSX3("CTT_RES")
Local aTamItem  	:= TAMSX3("CTD_ITEM")
Local aTamItRes 	:= TAMSX3("CTD_RES")
Local aTamClVl  	:= TAMSX3("CTH_CLVL")
Local aTamCvRes 	:= TAMSX3("CTH_RES")
Local aTamVal		:= TAMSX3("CT2_VALOR")

Local aCtbMoeda		:= {}
Local aSaveArea 	:= GetArea()
Local aCampos
Local cChave
Local nTamCta 		:= Len(CriaVar("CT1->CT1_DESC"+cMoeda))
Local nTamItem		:= Len(CriaVar("CTD->CTD_DESC"+cMoeda))
Local nTamCC  		:= Len(CriaVar("CTT->CTT_DESC"+cMoeda))
Local nTamClVl		:= Len(CriaVar("CTH->CTH_DESC"+cMoeda))
Local nTamGrupo		:= Len(CriaVar("CT1->CT1_GRUPO"))
Local nDecimais		:= 0
Local cCodigo		:= ""
Local cCodGer		:= ""
Local cEntidIni		:= ""
Local cEntidFim		:= ""
Local cEntidIni1	:= ""
Local cEntidFim1	:= ""
Local cEntidIni2	:= ""
Local cEntidFim2	:= ""
Local cArqTmp1		:= ""
Local cMascaraG 	:= ""
Local lCusto		:= CtbMovSaldo("CTT")//Define se utiliza C.Custo
Local lItem 		:= CtbMovSaldo("CTD")//Define se utiliza Item
Local lClVl			:= CtbMovSaldo("CTH")//Define se utiliza Cl.Valor
Local lAtSldBase	:= Iif(GetMV("MV_ATUSAL")== "S",.T.,.F.)
Local lAtSldCmp		:= Iif(GetMV("MV_SLDCOMP")== "S",.T.,.F.)
Local nInicio		:= Val(cMoeda)
Local nFinal		:= Val(cMoeda)
Local nCampoLP		:= 0
Local cFilDe		:= xFilial(cAlias)
Local cFilAte		:= xFilial(cAlias), nOrdem := 1
Local cCodMasc		:= ""
Local cMensagem		:= OemToAnsi(STR0002)// O plano gerencial ainda nao esta disponivel nesse relatorio.
Local nPos			:= 0
Local nCont			:= 0
Local lTemQuery		:= .F.
Local nX
Local lCriaInd		:= .F.
Local nTamFilial 	:= IIf( lFWCodFil, FWGETTAMFILIAL, 2 )
Local lCT1EXDTFIM	:= CtbExDtFim("CT1")
Local lCTTEXDTFIM	:= CtbExDtFim("CTT")
Local lCTDEXDTFIM	:= CtbExDtFim("CTD")
Local lCTHEXDTFIM	:= CtbExDtFim("CTH")

Local nSlAntGap		:= 0	// Saldo Anterior
Local nSlAntGapD	:= 0	// Saldo anterior debito
Local nSlAntGapC	:= 0	// Saldo anterior credito
Local nSlAtuGap		:= 0	// Saldo Atual
Local nSlAtuGapD	:= 0	// Saldo Atual debito
Local nSlAtuGapC	:= 0	// Saldo Atual credito
Local nSlDebGap		:= 0	// Saldo Debito
Local nSlCrdGap		:= 0	// Saldo Credito

Local aEntidIni		:= {}
Local aEntidFim		:= {}

Local aStruTmp		:= {}
Local lTemQry		:= .F.
Local nTrb			:= 0

Local nDigitos		:= 0
Local nMeter		:= 0
Local nPosG			:= 0
Local nDigitosG		:= 0
Local aAreaAnt		:= Nil

Local _lCtbIsCube	:= FindFunction( "CtbIsCube" ) .And. CtbIsCube()
Local aTmpFil		:= {}

Local cMvPar01Ant	:= mv_par01

Local cTableNam1 	:= ""
Local aChave		:= {}
Local nTamCt		:= aTamConta[1]

Local cEntid_de		:= ""
Local cEntid_ate	:= ""
Local lEntSint		:= .F.

Local lCT1DTEXSF 	:= .F.
Local lCTTDTEXSF 	:= .F.
Local lCTDDTEXSF 	:= .F.
Local lCTHDTEXSF 	:= .F.
Local lSLDANTCTDB 	:= .F.
Local lSLDANTCTCR 	:= .F.
Local lSLLPATCTDB 	:= .F.
Local lSLLPATCTCR 	:= .F.

Local lGrvJson		:= CTB_IsJSON()

//VerificaÁ„o se a chamada È do CTBR140 ou teste automatizado do CTBR140
Local lCtbr140		:= IIf(FwIsInCallStack('CTBR140') .or. (FunName() == 'CTBR140'), .T., .F.)

//Variaveis para atualizar a regua desde as rotinas de geracao do arquivo temporario
Private oMeter1 		:= oMeter
Private oText1 		:= oText
Private cPlanoRef	:= aSetOfBook[11]
Private cVersao		:= aSetOfBook[12]

DEFAULT lConsSaldo   := .F.
DEFAULT lPlGerSint   := .F.
DEFAULT cSegmentoG 	:= ""
DEFAULT lUsGaap		:=.F.
DEFAULT cMoedConv	:= ""
DEFAULT	cConsCrit	:= ""
DEFAULT dDataConv	:= CTOD("  /  /  ")
DEFAULT nTaxaConv	:= 0
DEFAULT lImpSint	:= .T.
DEFAULT lImpMov		:= .T.
DEFAULT cSegmento	:= ""
DEFAULT cFilUsu		:= ".T."
DEFAULT lRecDesp0	:= .F.
DEFAULT cRecDesp 	:= ""
DEFAULT dDtZeraRD	:= CTOD("  /  /  ")
DEFAULT lImp3Ent	:= .F.
DEFAULT lImp4Ent	:= .F.
DEFAULT lImpEntGer	:= .F.
DEFAULT lImpConta	:= .T.
DEFAULT lFiltraCC	:= .F.
DEFAULT lFiltraIt	:= .F.
DEFAULT lFiltraCV	:= .F.
DEFAULT cMoedaDsc	:= '01'
DEFAULT lMovPeriodo := .F.
DEFAULT aSelFil 	:= {}
DEFAULT dDtCorte 	:= CTOD("  /  /  ")
DEFAULT lCompEnt	:= .F.
DEFAULT cArqAux		:= "cArqTmp"
DEFAULT cArqTmp 	:= ""
DEFAULT lUsaNmVis	:= .F.
DEFAULT lCttSint	:= .F.
DEFAULT cQuadroCTB:= ""
DEFAULT lTodasFil   := .F.
DEFAULT aEntidades  := {}
DEFAULT cCodEntidade:= ""
DEFAULT lDemDRE:=.F.
DEFAULT dFinalA 	:= CTOD("  /  /  ")
DEFAULT nDivide := 1

If __lCOLUN2 == NIL
	__lCOLUN2 := Iif( CTS->(FieldPos("CTS_COLUN2")) > 0, .T., .F.)
Endif
If FunName() == "CTBR561" .Or. FunName() == "CTBR502"
	nTamCta := 100
Endif

__aTmpTCFil	:=	{}

If lRecDesp0 .And. ( Empty(cRecDesp) .Or. Empty(dDtZeraRD) )
	lRecDesp0 := .F.
EndIf

cIdent		:=	Iif(cIdent == Nil,'',cIdent)
nGrupo		:=	Iif(nGrupo == Nil,2,nGrupo)
cHeader		:= Iif(cHeader == Nil,'',cHeader)
cFiltroEnt	:= Iif(cFiltroEnt == Nil,"",cFiltroEnt)
cCodFilEnt	:= Iif(cCodFilEnt == Nil,"",cCodFilEnt)
Private nMin			:= 0
Private nMax			:= 0

// Retorna Decimais
aCtbMoeda := CTbMoeda(cMoeda)
nDecimais := aCtbMoeda[5]
dMinData := CTOD("")

//Se utiliza o plano referencial, desconsidera os filtros das entidades dos relatÛrios.
If !Empty(cPlanoRef) .And. !Empty(cVersao)
	//Se o relatÛrio n„o possuir conta, o plano referencial e a vers„o ser„o desconsiderados.
	//Ser· considerado cÛd. config. livros em branco.
	If cAlias $ "CTU/CTV/CTW/CTX/CTY/CVY" .Or. FunName() == "CTBR245"
		Help("  ",1,"CTBNOPLREF",,STR0048,1,0) //"Plano referencial n„o disponÌvel nesse relatÛrio. O relatÛrio ser· processado desconsiderando a configuraÁ„o de livros."
		cPlanoRef		:= ""
		cVersao			:= ""
		//aSetOfBook[1]	:= ""
		aSetOfBook		:= CTBSetOf("")
	Else
		cContaIni	:= Space(aTamConta[1])
		cContaFim	:= Replicate("Z",aTamConta[1])

		If FunName() != "CTBR040"
			lRecDesp0	:= .F.
		EndIf
	EndIf
Endif


If ExistBlock("ESPGERPLAN")
	ExecBlock("ESPGERPLAN",.F.,.F.,{oMeter,oText,oDlg,lEnd,cArqtmp,dDataIni,dDataFim,cAlias,cIdent,cContaIni,cContaFim,;
		cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,;
		cSegFim,cFiltSegm,lNImpMov,lImpConta,nGrupo,cHeader,lImpAntLP,dDataLP,nDivide,lVlrZerado,;
		cFiltroEnt,cCodFilEnt,cSegmentoG,cSegIniG,cSegFimG,cFiltSegmG,lUsGaap,cMoedConv,;
		cConsCrit,dDataConv,nTaxaConv,aGeren,lImpMov,lImpSint,cFilUSU,lRecDesp0,;
		cRecDesp,dDtZeraRD,lImp3Ent,lImp4Ent,lImpEntGer,lFiltraCC,lFiltraIt,lFiltraCV,aSelFil,dDtCorte,cQuadroCTB })


		Return(cArqTmp)
EndIf

If cAlias == 'CTY'	//Se for Balancete de 2 Entidades filtrando pela 3a Entidade.
	aCampos := {{ "ENTID1"		, "C", aTamConta[1], 0 },;  			// Codigo da Conta
	{ "ENTRES1"	, "C", aTamCtaRes[1],0 },;  			// Codigo Reduzido da Conta
	{ "DESCENT1"	, "C", nTamCta		, 0 },;  			// Descricao da Conta
	{ "TIPOENT1"  	, "C", 01			, 0 },;				// Centro de Custo Analitico / Sintetico
	{ "ENTSUP1"	, "C", aTamCC[1]	, 0 },;				// Codigo do Centro de Custo Superior
	{ "ENTID2"		, "C", aTamCC[1]	, 0 },; 	 		// Codigo do Centro de Custo
	{ "ENTRES2"	, "C", aTamCCRes[1], 0 },;  			// Codigo Reduzido do Centro de Custo
	{ "DESCENT2"	, "C", nTamCC		, 0 },;  			// Descricao do Centro de Custo
	{ "TIPOENT2"	, "C", 01			, 0 },;				// Item Analitica / Sintetica
	{ "ENTSUP2"	, "C", aTamItem[1]	, 0 },; 			// Codigo do Item Superior
	{ "NORMAL"		, "C", 01			, 0 },;				// Situacao
	{ "SALDOANT"	, "N", aTamVal[1]+2, nDecimais},; 		// Saldo Anterior
	{ "SALDOANTDB"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior Debito
	{ "SALDOANTCR"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior Credito
	{ "SALDODEB"	, "N", aTamVal[1]+2	, nDecimais },;  	// Debito
	{ "SALDOCRD"	, "N", aTamVal[1]+2	, nDecimais },;  	// Credito
	{ "SALDOATU"	, "N", aTamVal[1]+2, nDecimais },;  	// Saldo Atual
	{ "SALDOATUDB"	, "N", aTamVal[1]+2	, nDecimais },;  	// Saldo Atual Debito
	{ "SALDOATUCR"	, "N", aTamVal[1]+2	, nDecimais },;  	// Saldo Atual Credito
	{ "MOVIMENTO"	, "N", aTamVal[1]+2	, nDecimais },;  	// Movimento do Periodo
	{ "ORDEM"		, "C", 10			, 0 },;				// Ordem
	{ "GRUPO"		, "C", nTamGrupo	, 0 },;				// Grupo Contabil
	{ "IDENTIFI"	, "C", 01			, 0 },;
		{ "TOTVIS"		, "C", 01			, 0 },;
		{ "SLDENT"		, "C", 01			, 0 },;
		{ "FATSLD"		, "C", 01			, 0 },;
		{ "VISENT"		, "C", 01			, 0 },;
		{ "NIVEL1"		, "L", 01			, 0 }}				// Logico para identificar se eh de nivel 1 -> usado como totalizador do relatorio

ElseIf cAlias == 'CVY'	//Se for Balancete por cubo contabil

	If cPaisLoc $ "COL|PER" .And. FunName() == "CTBR048"
		aTamCC := TAMSX3("CV0_CODIGO")						// Redefine longitud entidad (05)
	EndIf

	aCampos := { { "ECX"		, "C", aTamConta[1], 0 },;  // Codigo da Conta
	{ "ECXSUP"		, "C", aTamConta[1], 0 },;				// Conta Superior
	{ "ECXNORMAL"	, "C", 01			, 0 },;				// Situacao
	{ "ECXRES"		, "C", aTamCtaRes[1], 0 },;  			// Codigo Reduzido da Conta
	{ "ECXDESC"	, "C", nTamCta		, 0 },;  			// Descricao da Conta
	{ "ECY"		, "C", aTamCC[1]	, 0 },; 	 		// Codigo do Centro de Custo
	{ "ECYSUP"		, "C", aTamConta[1], 0 },;				// Conta Superior
	{ "ECYNORMAL"	, "C", 01			, 0 },;				// Situacao
	{ "ECYRES"		, "C", aTamCCRes[1], 0 },;  			// Codigo Reduzido do Centro de Custo
	{ "ECYDESC" 	, "C", nTamCC		, 0 },;  			// Descricao do Centro de Custo
	{ "SALDOANT"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior
	{ "SALDOANTDB"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior Debito
	{ "SALDOANTCR"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior Credito
	{ "SALDODEB"	, "N", aTamVal[1]+2	, nDecimais },;  	// Debito
	{ "SALDOCRD"	, "N", aTamVal[1]+2	, nDecimais },;  	// Credito
	{ "SALDOATU"	, "N", aTamVal[1]+1	, nDecimais },;  	// Saldo Atual
	{ "SALDOATUDB"	, "N", aTamVal[1]+2	, nDecimais },;  	// Saldo Atual Debito
	{ "SALDOATUCR"	, "N", aTamVal[1]+2	, nDecimais },;  	// Saldo Atual Credito
	{ "MOVIMENTO"	, "N", aTamVal[1]+2	, nDecimais },;  	// Movimento do Periodo
	{ "TIPOECX"	, "C", 01			, 0 },;				// Conta Analitica / Sintetica
	{ "TIPOECY"  	, "C", 01			, 0 },;				// Centro de Custo Analitico / Sintetico
	{ "ORDEM"		, "C", 10			, 0 },;				// Ordem
	{ "GRUPO"		, "C", nTamGrupo	, 0 },;				// Grupo Contabil
	{ "IDENTIFI"	, "C", 01			, 0 },;
		{ "TOTVIS"		, "C", 01			, 0 },;
		{ "SLDENT"		, "C", 01			, 0 },;
		{ "FATSLD"		, "C", 01			, 0 },;
		{ "VISENT"		, "C", 01			, 0 },;
		{ "ESTOUR" 	, "C", 01			, 0 },;			 	//Define se a conta esta estourada ou nao
	{ "NIVEL1"		, "L", 01			, 0 },;
		{ "NATCTA"     , "C", 02           , 0 }}             //NATCTA -campo de natureza da conta para relatorio CTBR047

	// totalizador do relatorio
Else
	If !Empty(cPlanoRef) .And. !Empty(cVersao)
		nTamCt	:= 70
	Else
		nTamCt	:= aTamConta[1]
	Endif
	aCampos := { { "CONTA"		, "C", nTamCt, 0 },;  			// Codigo da Conta
	{ "SUPERIOR"	, "C", nTamCt, 0 },;				// Conta Superior
	{ "NORMAL"		, "C", 01			, 0 },;				// Situacao
	{ "CTARES"		, "C", aTamCtaRes[1], 0 },;  			// Codigo Reduzido da Conta
	{ "DESCCTA"	, "C", nTamCta		, 0 },;  			// Descricao da Conta
	{ "CUSTO"		, "C", aTamCC[1]	, 0 },; 	 		// Codigo do Centro de Custo
	{ "CCRES"		, "C", aTamCCRes[1], 0 },;  			// Codigo Reduzido do Centro de Custo
	{ "DESCCC" 	, "C", nTamCC		, 0 },;  			// Descricao do Centro de Custo
	{ "ITEM"		, "C", aTamItem[1]	, 0 },; 	 		// Codigo do Item
	{ "ITEMRES" 	, "C", aTamItRes[1], 0 },;  			// Codigo Reduzido do Item
	{ "DESCITEM" 	, "C", nTamItem		, 0 },;  			// Descricao do Item
	{ "CLVL"		, "C", aTamClVl[1]	, 0 },; 	 		// Codigo da Classe de Valor
	{ "CLVLRES"	, "C", aTamCVRes[1], 0 },; 		 	// Cod. Red. Classe de Valor
	{ "DESCCLVL"   , "C", nTamClVl		, 0 },;  			// Descricao da Classe de Valor
	{ "SALDOANT"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior
	{ "SALDOANTDB"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior Debito
	{ "SALDOANTCR"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior Credito
	{ "SALDODEB"	, "N", aTamVal[1]+2	, nDecimais },;  	// Debito
	{ "SALDOCRD"	, "N", aTamVal[1]+2	, nDecimais },;  	// Credito
	{ "SALDOATU"	, "N", aTamVal[1]+1	, nDecimais },;  	// Saldo Atual
	{ "SALDOATUDB"	, "N", aTamVal[1]+2	, nDecimais },;  	// Saldo Atual Debito
	{ "SALDOATUCR"	, "N", aTamVal[1]+2	, nDecimais },;  	// Saldo Atual Credito
	{ "MOVIMENTO"	, "N", aTamVal[1]+2	, nDecimais },;  	// Movimento do Periodo
	{ "TIPOCONTA"	, "C", 01			, 0 },;				// Conta Analitica / Sintetica
	{ "TIPOCC"  	, "C", 01			, 0 },;				// Centro de Custo Analitico / Sintetico
	{ "TIPOITEM"	, "C", 01			, 0 },;				// Item Analitica / Sintetica
	{ "TIPOCLVL"	, "C", 01			, 0 },;				// Classe de Valor Analitica / Sintetica
	{ "CCSUP"		, "C", aTamCC[1]	, 0 },;				// Codigo do Centro de Custo Superior
    { "CCNORMAL"  	, "C", 01			, 0 },;				// Situacao
	{ "ITSUP"		, "C", aTamItem[1]	, 0 },;				// Codigo do Item Superior
    { "ITNORMAL"  	, "C", 01			, 0 },;				// Situacao
	{ "CLSUP"	    , "C", aTamClVl[1] , 0 },;				// Codigo da Classe de Valor Superior
    { "CLNORMAL"  	, "C", 01			, 0 },;				// Situacao
	{ "ORDEM"		, "C", 10			, 0 },;				// Ordem
	{ "GRUPO"		, "C", nTamGrupo	, 0 },;				// Grupo Contabil
	{ "IDENTIFI"	, "C", 01			, 0 },;
		{ "TOTVIS"		, "C", 01			, 0 },;
		{ "SLDENT"		, "C", 01			, 0 },;
		{ "FATSLD"		, "C", 01			, 0 },;
		{ "VISENT"		, "C", 01			, 0 },;
		{ "ESTOUR" 	, "C", 01			, 0 },;			 	//Define se a conta esta estourada ou nao
	{ "NIVEL1"		, "L", 01			, 0 },;
		{ "NATCTA"     , "C", 02           , 0 }}             //NATCTA -campo de natureza da conta para relatorio CTBR047
	// Logico para identificar se
	// eh de nivel 1 -> usado como
	// totalizador do relatorio]

	If _lCtbIsCube
		aAreaAnt := GetArea()
		DbSelectArea('CT0')
		DbSetOrder(1)
		If DbSeek( xFilial('CT0') + '05' )
			While CT0->(!Eof()) .And. CT0->CT0_FILIAL == xFilial('CT0')

				AADD( aCampos,{ "CODENT"+CT0->CT0_ID	, "C", TamSx3(CT0->CT0_CPOCHV)[1]	, 0 } )
				AADD( aCampos,{ "DESCENT"+CT0->CT0_ID  	, "C", TamSx3(CT0->CT0_CPODSC)[1]	, 0 } )
				AADD( aCampos,{ "TIPOENT"+CT0->CT0_ID  	, "C", 01	, 0 } )

				CT0->(DbSkip())
			EndDo
		EndIf
		RestArea(aAreaAnt)
	EndIf

	// Usado no mutacoes de patrimonio liquido inclui campo que alem da descricao da entidade
	// Que esta no DESCCTA tem tambem a descricao da conta inicial CTS_CT1INI
	If 	Type("lTRegCts") # "U" .And. ValType(lTRegCts) = "L" .And. lTRegCts
		Aadd(aCampos, { "DESCORIG"	, "C", nTamCta		, 0 } )	// Descricao da Origem do Valor
	Endif
	Aadd( aCampos, { "DESCCONT", "C", 200, 0 } ) //DescriÁ„o da origem do valor
EndIf

Aadd(aCampos, { "FILIAL"	, "C", nTamFilial, 0 } )	// Cria Filial do Sistema

If CTS->(FieldPos("CTS_COLUNA")) > 0
	Aadd(aCampos, { "COLUNA"   	, "N", 01			, 0 })
EndIf

If CTS->(FieldPos("CTS_IMPSAL")) > 0
	Aadd(aCampos, { "IMPSAL"   	, "C", 01			, 0 })
EndIf

If 	Type("dSemestre") # "U" .And. ValType(dSemestre) = "D"
	Aadd(aCampos, { "SALDOSEM"	, "N", 17		, nDecimais }) 	// Saldo semestre
Endif

If Type("dPeriodo0") # "U" .And. ValType(dPeriodo0) = "D"
	Aadd(aCampos, { "SALDOPER"	, "N", 17		, nDecimais }) 	// Saldo Periodo determinado
	Aadd(aCampos, { "MOVIMPER"	, "N", 17		, nDecimais }) 	// Saldo Periodo determinado
Endif

If Type("lComNivel") # "U" .And. ValType(lComNivel) = "L"
	Aadd(aCampos, { "NIVEL"   	, "N", 02			, 0 })		// Nivel hieraquirco - Quanto maior mais analitico
Endif

If ( cAlias = "CT7" .And. SuperGetMv("MV_CTASUP") = "S" ) .Or. ;
		( cAlias = "CT3" .And. SuperGetMv("MV_CTASUP") = "S" ) .Or. ;
		(cAlias == "CTU" .And. cIdent == "CTT" .And. GetNewPar("MV_CCSUP","")  == "S")  .Or. ;
		(cAlias == "CTU" .And. cIdent == "CTD" .And. GetNewPar("MV_ITSUP","") == "S") .Or. ;
		(cAlias == "CTU" .And. cIdent == "CTH" .And. GetNewPar("MV_CLSUP","") == "S")
	Aadd(aCampos, { "ORDEMPRN" 	, "N", 06			, 0 })		// Ordem para impressao
Endif

If cPaisLoc =="RUS"
	Aadd(aCampos, { "INIBALANCE"		, "N" , 17			, nDecimais })
EndIf

If lMovPeriodo
	Aadd(aCampos, { "MOVPERANT"		, "N" , 17			, nDecimais }) 	// Saldo Periodo Anterior
EndIf

If lGrvJson
	Aadd(aCampos, { "NIVJSON"		, "C" , 30			, 0 }) 	// NÌvel para exportacao dos arquivos JSON
EndIf

///// TRATAMENTO PARA ATUALIZA«√O DE SALDO BASE
//Se os saldos basicos nao foram atualizados na dig. lancamentos
If !lAtSldBase .And. !__IsCtbJob
	dIniRep := ctod("")
	If Need2Reproc(dDataFim,cMoeda,cSaldos,@dIniRep)
		//Chama Rotina de Atualizacao de Saldos Basicos.
		oProcess := MsNewProcess():New({|lEnd|	CTBA190(.T.,dIniRep,dDataFim,cFilAnt,cFilAnt,cSaldos,.T.,cMoeda) },"","",.F.)
		oProcess:Activate()
	EndIf
Endif

//// TRATAMENTO PARA ATUALIZA«√O DE SALDOS COMPOSTOS ANTES DE EXECUTAR A QUERY DE FILTRAGEM
Do Case
Case cAlias == 'CTU'
	//Verificar se tem algum saldo a ser atualizado por entidade
	If cIdent == "CTT"
		cOrigem := 	'CT3'
	ElseIf cIdent == "CTD"
		cOrigem := 	'CT4'
	ElseIf cIdent == "CTH"
		cOrigem := 	'CTI'
	Else
		cOrigem := 	'CTI'
	Endif
Case cAlias == 'CTV'
	cOrigem := "CT4"
	//Verificar se tem algum saldo a ser atualizado
Case cAlias == 'CTW'
	cOrigem		:= 'CTI'	/// HEADER POR CLASSE DE VALORES
	//Verificar se tem algum saldo a ser atualizado
Case cAlias == 'CTX'
	cOrigem		:= 'CTI'
EndCase

Do Case
	/************************************
	Consulta saldo pelo cubo contabil
	//************************************/
Case cAlias  == "CVY"
	cEntidIni	:= cContaIni
	cEntidFim	:= cContaFim
	cCodMasc	:= aSetOfBook[2]
	cChave 		:= "ECX+ECY"
	aChave  	:= {"ECX","ECY"}

	//Se nao tiver plano gerencial.
	If Empty(aSetOfBook[5])
		/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
		If cFilUsu == ".T."
			cFilUsu := ""
		EndIf
		CtbRunCube(dDataIni,dDataFim,cAlias,cEntidIni,cEntidFim,cCCIni,cCCFim,cMoeda,;
			cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUsu,cMoedaDsc,aSelFil,dDtCorte,lTodasFil,aTmpFil)

		If Empty(cFilUSU)
			cFILUSU := ".T."
		Endif
		lTemQuery := .T.
	Endif


Case cAlias  == "CT7"
	cEntidIni	:= cContaIni
	cEntidFim	:= cContaFim
	cCodMasc		:= aSetOfBook[2]
	If nGrupo == 1
		cChave 	:= "CONTA+GRUPO"
		aChave	:= {"CONTA","GRUPO"}
	Else									// Indice por Grupo -> Totaliza por grupo
		cChave 	:= "CONTA"
		aChave	:= {"CONTA"}
	EndIf

	//Se nao tiver plano gerencial.
	If Empty(aSetOfBook[5])
		/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
		If cFilUsu == ".T."
			cFilUsu := ""
		EndIf
		CT7BlnQry(dDataIni,dDataFim,cAlias,cEntidIni,cEntidFim,cMoeda,;
			cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUsu,cMoedaDsc,aSelFil,dDtCorte,lTodasFil,aTmpFil)
		If Empty(cFilUSU)
			cFILUSU := ".T."
		Endif
		lTemQuery := .T.
	Endif


Case cAlias == 'CT3'
	cEntidIni	:= cCCIni
	cEntidFim	:= cCCFim

	If lImpConta
		If cHeader == "CT1"
			cChave		:= "CONTA+CUSTO"
			aChave		:=  {"CONTA","CUSTO"}
			cCodMasc	:= aSetOfBook[6]
		Else
			If nGrupo == 2
				cChave   := "CUSTO+CONTA"
				aChave   := {"CUSTO","CONTA"}
			Else									// Indice por Grupo -> Totaliza por grupo
				cChave 	:= "CUSTO+CONTA+GRUPO"
				aChave  := {"CUSTO","CONTA","GRUPO"}
			EndIf
			cCodMasc	:= aSetOfBook[2]
			cMascaraG	:= aSetOfBook[6]
			lEntSint	:= lCttSint
			cEntid_de	:= cEntidIni
			cEntid_ate	:= cEntidFim
		Endif
	Else		//Balancete de Centro de Custo (filtrando por conta)
		cChave		:= "CUSTO"
		aChave   	:= {"CUSTO"}
		cCodMasc:= aSetOfBook[6]
	EndIf


	If  Empty(aSetOfBook[5])
		If cFilUsu == ".T."
			cFilUsu := ""
		EndIf
		If lImpConta
			IF !lCompEnt
				/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
				CT3BlnQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cMoeda,;
					cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)
			Else
				/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
				CT3BlnQryC(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cMoeda,;
					cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,,aTmpFil)
			Endif
		Else
			Ct3Bln1Ent(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cMoeda,;
				cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,;
				lRecDesp0,cRecDesp,dDtZeraRD,aSelFil,lTodasFil,aTmpFil)
		EndIf
		lTemQuery := .T.
		If Empty(cFilUSU)
			cFILUSU := ".T."
		Endif
	EndIf


Case cAlias =='CT4'
	If lImp3Ent	//Balancete CC / Conta / Item
		If cHeader == "CTT"
			If  Empty(aSetOfBook[5])
				If cFilUsu == ".T."
					cFilUsu := ""
				EndIf
				/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
				CT4Bln3Ent(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cMoeda,;
					cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)
				lTemQuery := .T.
				If Empty(cFilUSU)
					cFILUSU := ".T."
				Endif
			EndIf

			cEntidIni	:= cCCIni
			cEntidFim	:= cCCFim
			cChave		:= "CUSTO+CONTA+ITEM"
			//cChave		:= "(cArqTmpAnt)->CUSTO+cContaRef+(cArqTmpAnt)->CUSTO"
			aChave 		:= {"CUSTO","CONTA","ITEM"}
			cCodMasc	:= aSetOfBook[2]
		EndIf
	Else
		cEntidIni	:= cItemIni
		cEntidFim	:= cItemFim
		If lImpConta
			If cHeader == "CT1"	//Se for for Balancete Conta x Item
				cChave			:= "CONTA+ITEM"
				aChave   		:= {"CONTA","ITEM"}
				cCodMasc		:= aSetOfBook[7]
			Else
				cChave   		:= "ITEM+CONTA"
				aChave   		:= {"ITEM","CONTA"}
				cCodMasc		:= aSetOfBook[2]
				cMascaraG		:= aSetOfBook[7]
				lEntSint		:= lCttSint
				cEntid_de		:= cEntidIni
				cEntid_ate		:= cEntidFim
			EndIf
		Else	//Balancete de Item filtrando por conta
			cChave			:= "ITEM"
			aChave  	 	:= {"ITEM"}
			cCodMasc		:= aSetOfBook[7]
		EndIf

		If  Empty(aSetOfBook[5])
			If cFilUsu == ".T."
				cFilUsu := ""
			EndIf
			If lImpConta
				/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
				CT4BlnQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cItemIni,cItemFim,cMoeda,;
					cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)
			Else
				Ct4Bln1Ent(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,;
					cMoeda,cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,;
					lRecDesp0,cRecDesp,dDtZeraRD,aSelFil,lTodasFil,aTmpFil)
			EndIf
			lTemQuery := .T.
			If Empty(cFilUSU)
				cFILUSU := ".T."
			Endif
		EndIf

	EndIf
Case cAlias == 'CTI'
	If lImp4Ent	//Balancete CC x Cta x Item x Cl.Valor
		If cHeader == "CTT"

			If  Empty(aSetOfBook[5]) .and. !lImpAntLP
				If cFilUsu == ".T."
					cFilUsu := ""
				EndIf
				/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
				CTIBln4Ent(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,;
					cClVlIni,cClVlFim,cMoeda,cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,aSelFil,lTodasFil,aTmpFil)
				lTemQuery := .T.
				If Empty(cFilUSU)
					cFILUSU := ".T."
				Endif
			EndIf
			cChave		:= "CUSTO+CONTA+ITEM+CLVL"
			aChave   	:= {"CUSTO","CONTA","ITEM","CLVL"}
			cEntidIni	:= cCCIni
			cEntidFim	:= cCCFim
			cCodMasc	:= aSetOfBook[2]
		EndIf
	Else
		cEntidIni	:= cClVlIni
		cEntidFim	:= cClvlFim

		lEntSint	:= lCttSint
		cEntid_de	:= cEntidIni
		cEntid_ate	:= cEntidFim

		If lImpConta
			If cHeader == "CT1"
				cChave		:= "CONTA+CLVL"
				aChave   	:= {"CONTA","CLVL"}
				cCodMasc	:= aSetOfBook[2]
			Else
				cChave   	:= "CLVL+CONTA"
				aChave   	:= {"CLVL","CONTA"}
				cCodMasc		:= aSetOfBook[2]
				cMascaraG		:= aSetOfBook[8]
			EndIf

			If Empty(aSetOfBook[5])
				If cFilUsu == ".T."
					cFilUsu := ""
				EndIf
				/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
				CTIBlnQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cClVlIni,cClVlFim,cMoeda,;
					cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)
				lTemQuery := .T.
				If Empty(cFilUSU)
					cFILUSU := ".T."
				Endif
			EndIf
		Else	//Balancete de Cl.Valor filtrando por conta
			cChave   := "CLVL"
			aChave   := {"CLVL"}
			cCodMasc := aSetOfBook[8]
			If  Empty(aSetOfBook[5])
				If cFilUsu == ".T."
					cFilUsu := ""
				EndIf
				CtIBln1Ent(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,;
					cClVlIni,cClVlFim,cMoeda,cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,;
					lRecDesp0,cRecDesp,dDtZeraRD,aSelFil,lTodasFil,aTmpFil)
				lTemQuery := .T.
				If Empty(cFilUSU)
					cFILUSU := ".T."
				Endif
			EndIf
		EndIf
	EndIf
Case cAlias == 'CTU'
	If cIdent == 'CTT'
		cEntidIni	:= cCCIni
		cEntidFim	:= cCCFim
		cChave		:= "CUSTO"
		aChave  	:= {"CUSTO"}
		cCodMasc		:= aSetOfBook[6]
	ElseIf cIdent == 'CTD'
		cEntidIni	:= cItemIni
		cEntidFim	:= cItemFim
		cChave   	:= "ITEM"
		aChave   	:= {"ITEM"}
		cCodMasc		:= aSetOfBook[7]
	ElseIf cIdent == 'CTH'
		cEntidIni	:= cClVlIni
		cEntidFim	:= cClvlFim
		cChave  	:= "CLVL"
		aChave   	:= {"CLVL"}
		cCodMasc		:= aSetOfBook[8]
	Endif

	If  Empty(aSetOfBook[5])
		/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
		If cFilUsu == ".T."
			cFilUsu := ""
		EndIf
		CTUBlnQry(dDataIni,dDataFim,cAlias,cIdent,cEntidIni,cEntidFim,cMoeda,cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,aSelFil,lTodasFil,aTmpFil)
		lTEmQuery := .T.
		If Empty(cFilUSU)
			cFILUSU := ".T."
		Endif
	EndIf
Case cAlias == 'CTV'
	If cHeader == 'CTT'
		cChave   	:= "CUSTO+ITEM"
		aChave   	:= {"CUSTO","ITEM"}
		cEntidIni1	:= cCCIni
		cEntidFim1	:= cCCFim
		cEntidIni2	:= cItemIni
		cEntidFim2	:= cItemFim
	ElseIf cHeader == 'CTD'
		cChave   	:= "ITEM+CUSTO"
		aChave   	:= {"ITEM","CUSTO"}
		cEntidIni1	:= cItemIni
		cEntidFim1	:= cItemFim
		cEntidIni2	:= cCCIni
		cEntidFim2	:= cCCFim
	EndIf
Case cAlias == 'CTW'
	If cHeader	== 'CTT'
		cChave   	:= "CUSTO+CLVL"
		aChave   	:= {"CUSTO","CLVL"}
		cEntidIni1	:=	cCCIni
		cEntidFim1	:=	cCCFim
		cEntidIni2	:=	cClVlIni
		cEntidFim2	:=	cClVlFim
	ElseIf cHeader == 'CTH'
		cChave   	:= "CLVL+CUSTO"
		aChave   	:= {"CLVL","CUSTO"}
		cEntidIni1	:=	cClVlIni
		cEntidFim1	:=	cClVlFim
		cEntidIni2	:=	cCCIni
		cEntidFim2	:=	cCCFim
	EndIf
Case cAlias == 'CTX'
	If cHeader == 'CTD'
		cChave  	:= "ITEM+CLVL"
		aChave		:=  {"ITEM","CLVL"}
		cEntidIni1	:= 	cItemIni
		cEntidFim1	:= 	cItemFim
		cEntidIni2	:= 	cClVlIni
		cEntidFim2	:= 	cClVlFim
	ElseIf cHeader == 'CTH'
		cChave  	:= "CLVL+ITEM"
		aChave		:= {"CLVL","ITEM"}
		cEntidIni1	:= 	cClVlIni
		cEntidFim1	:= 	cClVlFim
		cEntidIni2	:= 	cItemIni
		cEntidFim2	:= 	cItemFim
	EndIf
Case cAlias	== 'CTY'
	cChave			:="ENTID1+ENTID2"
	aChave			:= {"ENTID1","ENTID2"}
	If cHeader == 'CTT' .And. cFiltroEnt == 'CTD'
		cEntidIni1	:= cCCIni
		cEntidFim1	:= cCCFim
		cEntidIni2	:= cClVlIni
		cEntidFim2	:= cClvlFim
	ElseIf cHeader == 'CTT' .And. cFiltroEnt == 'CTH'
		cEntidIni1	:= cCCIni
		cEntidFim1	:= cCCFim
		cEntidIni2	:= cItemIni
		cEntidFim2	:= cItemFim
	ElseIf cHeader == 'CTD' .And. cFiltroEnt == 'CTT'
		cEntidIni1	:= cItemIni
		cEntidFim1	:= cItemFim
		cEntidIni2	:= cClVlIni
		cEntidFim2	:= cClVlFim
	ElseIf cHeader == 'CTD' .And. cFiltroEnt == 'CTH'
		cEntidIni1	:= cItemIni
		cEntidFim1	:= cItemFim
		cEntidIni2	:= cCCIni
		cEntidFim2	:= cCCFim
	ElseIf cHeader == 'CTH' .And. cFiltroEnt == 'CTT'
		cEntidIni1	:= cClVlIni
		cEntidFim1	:= cClVlFim
		cEntidIni2	:= cItemIni
		cEntidFim2	:= cItemFim
	ElseIf cHeader == 'CTH' .And. cFiltroEnt == 'CTD'
		cEntidIni1	:= cClVlIni
		cEntidFim1	:= cClVlFim
		cEntidIni2	:= cCCIni
		cEntidFim2	:= cCCFim
	EndIf
EndCase

If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
	If cAlias $ "CT3/CT4/CTI"		//Se for Balancete Entidade/Entidade Gerencial
		Do Case
		Case cAlias == "CT3"
			cChave	:= "CUSTO+CONTA"
			aChave  := {"CUSTO","CONTA"}
		Case cAlias == "CT4"
			cChave	:= "ITEM+CONTA"
			aChave  := {"ITEM","CONTA"}
		Case cAlias == "CTI"
			cChave	:= "CLVL+CONTA"
			aChave  := {"CLVL","CONTA"}
		EndCase
	ElseIf cAlias = 'CTU'
		Do Case
		Case cIdent = 'CTT'
			cChave	:= "CUSTO"
			aChave  := {"CUSTO"}
		Case cIdent = 'CTD'
			cChave	:= "ITEM"
			aChave  := {"ITEM"}
		Case cIdent = 'CTH'
			cChave	:= "CLVL"
			aChave  := {"CLVL"}
		EndCase
	ElseIf cAlias  == "CVY"
		cChave := "ECX+ECY"
		aChave  := {"ECX","ECY"}
	Else
		If _lCtbIsCube
			If !Empty(cCodEntidade)
				cChave	:= "CODENT"+cCodEntidade
				aChave  := {"CODENT",cCodEntidade}
			Else
				cChave	:= "CONTA"
				aChave  := {"CONTA"}
			EndIf
		Else
			cChave	:= "CONTA"
			aChave  := {"CONTA"}
		EndIF
	EndIf
Endif

If Empty( aCampos )
	ConOutR("Erro na criacao da tabela temporaria")
Return .F.
EndIf

//-------------------
//CriaÁ„o do objeto
//-------------------
_oTempTable := FWTemporaryTable():New(cArqAux)
_oTempTable:SetFields( aCampos )

lCriaInd := .T.
_oTempTable:AddIndex("1", aChave)
If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
	_oTempTable:AddIndex("2", {"ORDEM"})
Endif

If Ascan(aCampos,{|x|Upper(Alltrim(x[1])) == "ORDEMPRN"}) > 0
	_oTempTable:AddIndex("3", {"ORDEMPRN"})
	If cAlias == "CT7" .OR. cAlias == "CT3"
		If Alltrim(Upper(FunName())) == "CTBR180"
			_oTempTable:AddIndex("4", {"CUSTO","SUPERIOR","CONTA"})
		Else
			_oTempTable:AddIndex("4", {"SUPERIOR","CONTA"})
		EndIf
	ElseIf cAlias == "CTU"
		If cIdent == "CTT"
			_oTempTable:AddIndex("4", {"CCSUP","CUSTO"})
		ElseIf cIdent == "CTD"
			_oTempTable:AddIndex("4", {"ITSUP","ITEM"})
		ElseIf cIdent == "CTH"
			_oTempTable:AddIndex("4", {"CLSUP","CLVL"})
		EndIf
	EndIf
EndIf
//------------------
//CriaÁ„o da tabela
//------------------
_oTempTable:Create()

cTableNam1 		:= _oTempTable:GetRealName()

DbSelectarea(cArqAux)

If _oHashCt1 == Nil;
	.And. ((cArqAux)->( FieldPos( "NATCTA" ) ) > 0;
	.AND.	(cAlias == "CT3" .AND. cHeader $ "CT1|CTT");
	.OR.	(cAlias == "CT4" .And. cHeader == "CTD");
	.OR.	(cAlias == "CTI" .And. cHeader == "CTH");
	.OR.	cAlias == "CT7")

	CtbLoadHash(cContaIni,cContaFim)
EndIf

If !Empty(cPlanoRef) .Or. !Empty(cVersao)
	If !VldPlRef(aSetOfBook[1],cPlanoRef, cVersao)
		Return(cArqTmp)
	EndIf
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria Indice Temporario do Arquivo de Trabalho 1.             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If lCriaInd
	dbSelectArea(cArqAux)
Endif

If FunName() <> "CTBR195" .or. (FunName() == "CTBR195" .and. !lImpAntLP)

	If lTemQuery .and. Select("TRBTMP") > 0 	/// E O ALIAS TRBTMP ESTIVER ABERTO (INDICANDO QUE A QUERY FOI EXECUTADA)
		If !Empty(cSegmento)
			If Len(aSetOfBook) == 0 .or. Empty(aSetOfBook[1])
				Help("CTN_CODIGO")
				Return(cArqTmp)
			Endif
			dbSelectArea("CTM")
			dbSetOrder(1)
			If MsSeek(xFilial()+cCodMasc)
				While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cCodMasc
					nPos += Val(CTM->CTM_DIGITO)
					If CTM->CTM_SEGMEN == strzero(val(cSegmento),2)
						nPos -= Val(CTM->CTM_DIGITO)
						nPos ++
						nDigitos := Val(CTM->CTM_DIGITO)
						Exit
					EndIf
					dbSkip()
				EndDo
			Else
				Help("CTM_CODIGO")
				Return(cArqTmp)
			EndIf
		EndIf

		If !Empty(cMascaraG) .And. ;
		((cAlias == "CT3" .And. cHeader == "CTT") .Or. (cAlias == "CT4" .And. cHeader == "CTD") .Or.(cAlias == "CTI" .And. cHeader == "CTH"))
			If !Empty(cSegmentoG)
				dbSelectArea("CTM")
				dbSetOrder(1)
				If MsSeek(xFilial()+cMascaraG)
					While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cMascaraG
						nPosG += Val(CTM->CTM_DIGITO)
						If CTM->CTM_SEGMEN == cSegmentoG
							nPosG -= Val(CTM->CTM_DIGITO)
							nPosG ++
							nDigitosG := Val(CTM->CTM_DIGITO)
							Exit
						EndIf
						dbSkip()
					EndDo
				EndIf
			EndIf
		EndIf

		dbSelectArea("TRBTMP")
		aStruTMP := dbStruct()			/// OBTEM A ESTRUTURA DO TMP

		nCampoLP	 := Ascan(aStruTMP,{|x| x[1]=="SLDLPANTDB"})
		dbSelectArea("TRBTMP")
		If ValType(oMeter) == "O"
			oMeter:SetTotal(TRBTMP->(RecCount()))
			oMeter:Set(0)
		EndIf

		lCT1DTEXSF := Type('TRBTMP->CT1DTEXSF') <> 'U'
		lCTTDTEXSF := Type('TRBTMP->CTTDTEXSF') <> 'U'
		lCTDDTEXSF := Type('TRBTMP->CTDDTEXSF') <> 'U'
		lCTHDTEXSF := Type('TRBTMP->CTHDTEXSF') <> 'U'

		lSLDANTCTDB := Type('(cArqAux)->SLDANTCTDB') <> 'U'
		lSLDANTCTCR := Type('(cArqAux)->SLDANTCTCR') <> 'U'
		lSLLPATCTDB := Type('(cArqAux)->SLLPATCTDB') <> 'U'
		lSLLPATCTCR := Type('(cArqAux)->SLLPATCTCR') <> 'U'


		dbGoTop() // POSICIONA NO 1∫ REGISTRO DO TMP
		While TRBTMP->(!Eof())			/// REPLICA OS DADOS DA QUERY (TRBTMP) PARA P/ O TEMPORARIO EM DISCO

			//Se nao considera apuracao de L/P sera verificado na propria query
			dbSelectArea("TRBTMP")
			If !lVlrZerado .And. lImpAntLP
				If TRBTMP->((SALDOANTDB - SLDLPANTDB) - (SALDOANTCR - SLDLPANTCR)) == 0 .And. ;
						TRBTMP->(SALDODEB-MOVLPDEB) == 0 .And. TRBTMP->(SALDOCRD-MOVLPCRD) == 0
					TRBTMP->(dbSkip())
					Loop
				EndIf
			ElseIf !lVlrZerado
				If TRBTMP->(SALDOANTDB - SALDOANTCR) == 0 .And. TRBTMP->SALDODEB == 0 .And. TRBTMP->SALDOCRD == 0
					TRBTMP->(dbSkip())
					Loop
				EndIf
			EndIf

			//Verificacao da  Data Final de Existencia da Entidade somente se imprime saldo zerado
			// e se realemten nao tiver saldo e movimento para a entidade. Caso tenha algum movimento
			//ou saldo devera imprimir.
			If lVlrZerado
				If lImpAntLP
					If ((SALDOANTDB - SLDLPANTDB) == 0 .And. (SALDOANTCR - SLDLPANTCR) == 0 .And. ;
							(SALDODEB-MOVLPDEB) == 0 .And. (SALDOCRD-MOVLPCRD) == 0)
						//Se a data de existencia final  da entidade estiver preenchida e a data inicial do
						//relatorio for maior, nao ira imprimir a entidade.
						If  cAlias $ "CT7/CT3/CT4/CTI"
							If lCT1EXDTFIM .And. lCT1DTEXSF
								IF !Empty(TRBTMP->CT1DTEXSF) .And. (dDataIni > TRBTMP->CT1DTEXSF)
									dbSelectArea("TRBTMP")
									TRBTMP->(dbSkip())
									Loop
								EndIf
							EndIf
						Endif

						If cAlias == "CT3" .Or. ( cAlias == "CTU" .And. cIdent == "CTT")  .Or. ( cAlias == "CTI" .And. lImp4Ent)
							If lCTTEXDTFIM .And. lCTTDTEXSF
								If !Empty(TRBTMP->CTTDTEXSF) .And. (dDataIni > TRBTMP->CTTDTEXSF)
									dbSelectArea("TRBTMP")
									TRBTMP->(dbSkip())
									Loop
								EndIf
							Endif
						EndIf

						If cAlias == "CT4" .Or. ( cAlias == "CTU" .And. cIdent == "CTD") .Or. ( cAlias == "CTI" .And. lImp4Ent)
							If lCTDEXDTFIM .And. lCTDDTEXSF
								IF !Empty(TRBTMP->CTDDTEXSF) .And. (dDataIni > TRBTMP->CTDDTEXSF)
									dbSelectArea("TRBTMP")
									TRBTMP->(dbSkip())
									Loop
								EndIf
							EndIf
						Endif

						If cAlias == "CTI"	.Or. ( cAlias == "CTU" .And. cIdent == "CTH")
							If lCTHEXDTFIM .And. lCTHDTEXSF
								If !Empty(TRBTMP->CTHDTEXSF) .And. (dDataIni > TRBTMP->CTHDTEXSF)
									dbSelectArea("TRBTMP")
									TRBTMP->(dbSkip())
									Loop
								Endif
							EndIf
						EndIf
					EndIf
				Else
					If (SALDOANTDB  == 0 .And. SALDOANTCR  == 0 .And. SALDODEB == 0 .And. SALDOCRD == 0)
						If cAlias $ "CT7/CT3/CT4/CTI" .And. lCT1DTEXSF
							If lCT1EXDTFIM .AND. !Empty(TRBTMP->CT1DTEXSF) .And. (dDataIni > TRBTMP->CT1DTEXSF)
								dbSelectArea("TRBTMP")
								TRBTMP->(dbSkip())
								Loop
							EndIf
						EndIf

						If cAlias == "CT3" .Or. ( cAlias == "CTU" .And. cIdent == "CTT") .Or. ( cAlias == "CTI" .And. lImp4Ent)
							If lCTTEXDTFIM .And. lCTTDTEXSF
								IF !Empty(TRBTMP->CTTDTEXSF) .And. (dDataIni > TRBTMP->CTTDTEXSF)
									dbSelectArea("TRBTMP")
									TRBTMP->(dbSkip())
									Loop
								Endif
							EndIf
						EndIf

						If cAlias == "CT4" .Or. ( cAlias == "CTU" .And. cIdent == "CTD")  .Or. ( cAlias == "CTI" .And. lImp4Ent)
							If lCTDEXDTFIM .And. lCTDDTEXSF
								IF !Empty(TRBTMP->CTDDTEXSF) .And. (dDataIni > TRBTMP->CTDDTEXSF)
									dbSelectArea("TRBTMP")
									TRBTMP->(dbSkip())
									Loop
								EndIf
							Endif
						EndIf

						If cAlias == "CTI"	.Or. ( cAlias == "CTU" .And. cIdent == "CTH")
							If lCTHEXDTFIM .And. lCTHDTEXSF
								IF !Empty(TRBTMP->CTHDTEXSF) .And. (dDataIni > TRBTMP->CTHDTEXSF)
									dbSelectArea("TRBTMP")
									TRBTMP->(dbSkip())
									Loop
								EndIf
							Endif
						EndIf
					EndIf
				EndIf
			EndIf

			If cAlias == "CTU"
				Do Case
				Case cIdent	== "CTT"
					cCodigo	:= TRBTMP->CUSTO
				Case cIdent	== "CTD"
					cCodigo	:= TRBTMP->ITEM
				Case cIdent	== "CTH"
					cCodigo	:= TRBTMP->CLVL
				EndCase
			Else
				If lImpConta .Or. cAlias == "CT7"
					If cHeader == "CT1"
						If cAlias == "CT4"
							cCodigo	:= TRBTMP->ITEM
						ElseIf cAlias == "CT3"
							cCodigo	:= TRBTMP->CUSTO
						EndIf
					Else
						cCodigo	:= TRBTMP->CONTA
					EndIf
				Else
					If cAlias == "CT3"
						cCodigo	:= TRBTMP->CUSTO
					ElseIf cAlias == "CT4"
						cCodigo	:= TRBTMP->ITEM
					ElseIf cAlias == "CTI"
						cCodigo	:= TRBTMP->CLVL
					EndIf
				EndIf
				If cAlias == "CT3" .And. cHeader == "CTT"
					cCodGer	:= TRBTMP->CUSTO
				ElseIf cAlias == "CT4" .And. cHeader == "CTD"
					cCodGer	:= TRBTMP->ITEM
				ElseIf cAlias == "CTI" .And. cHeader == "CTH"
					cCodGer	:= TRBTMP->CLVL
				EndIf
			EndIf

			If Empty(cPlanoRef) .Or. Empty(cVersao)	//Verifica o segmento somente se nao for com plano referencial.
				If !Empty(cSegmento)
					If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
						If  !(Substr(cCodigo,nPos,nDigitos) $ (cFiltSegm) )
							TRBTMP->(dbSkip())
							Loop
						EndIf
					Else
						If Substr(cCodigo,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
								Substr(cCodigo,nPos,nDigitos) > Alltrim(cSegFim)
							TRBTMP->(dbSkip())
							Loop
						EndIf
					Endif
				EndIf


				//Caso faca filtragem por segmento gerencial,verifico se esta dentro
				//da solicitacao feita pelo usuario.
				If ( cAlias == "CT3" .And. cHeader == "CTT" ) .Or. ( cAlias == "CT4" .And. cHeader == "CTD" ) .Or.  ;
						 ( cAlias == "CTI" .And. cHeader == "CTH" )
					If !Empty(cSegmentoG)
						If Empty(cSegIniG) .And. Empty(cSegFimG) .And. !Empty(cFiltSegmG)
							If  !(Substr(cCodGer,nPosG,nDigitosG) $ (cFiltSegmG) )
								TRBTMP->(dbSkip())
								Loop
							EndIf
						Else
							If Substr(cCodGer,nPosG,nDigitosG) < Alltrim(cSegIniG) .Or. ;
								Substr(cCodGer,nPosG,nDigitosG) > Alltrim(cSegFimG)
								TRBTMP->(dbSkip())
								Loop
							EndIf
						Endif
					EndIf
				EndIf
			EndIf

			If &("TRBTMP->("+cFILUSU+")")
				RecLock(cArqAux,.T.)

				For nTRB := 1 to Len(aStruTMP)
					Field->&(aStruTMP[nTRB,1]) := TRBTMP->&(aStruTMP[nTRB,1])
					If Subs(aStruTmp[nTRB][1],1,6) $ "SALDODEB/SALDOCRD/SALDOANTDB/SALDOANTCR/SLDLPANTCR/SLDLPANTDB/MOVLPDEB/MOVLPCRD" .And. nDivide > 1
						Field->&(aStruTMP[nTRB,1])	:=((TRBTMP->&(aStruTMP[nTRB,1])))/ndivide
					EndIf
				Next

				If Alltrim(Upper(FunName())) <> "CTBR210"
					(cArqAux)->FILIAL	:= cFilAnt
				Endif

				If cAlias	== "CTU"
					Do Case
					Case cIdent	== "CTT"
						If Empty(TRBTMP->DESCCC)
							(cArqAux)->DESCCC		:= TRBTMP->DESCCC01
						EndIf
					Case cIdent == "CTD"
						If Empty(TRBTMP->DESCITEM)
							(cArqAux)->DESCITEM	:= TRBTMP->DESCIT01
						EndIf
					Case cIdent == "CTH"
						If Empty(TRBTMP->DESCCLVL)
							(cArqAux)->DESCCLVL	:= TRBTMP->DESCCV01
						EndIf
					EndCase
				Else
					If lCtbr140
						CT1->(dbSetOrder(1))
						If CT1->(dbSeek(xFilial("CT1")+TRBTMP->CONTA))
							(cArqAux)->DESCCTA := CT1->CT1_DESC01
						Else
							(cArqAux)->DESCCTA := " "
						EndIf
					Else
						If lImpConta .or. cAlias == "CT7"
							If Empty(TRBTMP->DESCCTA) .AND. TRBTMP->(FieldPos( "DESCCTA01" )) > 0 .AND. !Empty(TRBTMP->DESCCTA01)
								(cArqAux)->DESCCTA	:= TRBTMP->DESCCTA01
							EndIf
						EndIf
					EndIf

					If cAlias == "CT4"
						If !lImp3Ent
							If lCtbr140
								CTD->(dbSetOrder(1))
								If CTD->(dbSeek(xFilial("CTD")+TRBTMP->ITEM))
									(cArqAux)->DESCITEM	:= CTD->CTD_DESC01
								Else
									(cArqAux)->DESCITEM	:= " "
								EndIf
							Else
								If cMoeda <> '01' .And. Empty(TRBTMP->DESCITEM)
									(cArqAux)->DESCITEM	:= TRBTMP->DESCIT01
								EndIf
							EndIf
						EndIf

						If lImp3Ent	//Balancete CC / Conta / Item
							If Empty(TRBTMP->DESCCC)
								(cArqAux)->DESCCC	:= TRBTMP->DESCCC01
							EndIf

							If TRBTMP->ALIAS == 'CT4'
								If Empty(TRBTMP->DESCITEM)
									(cArqAux)->DESCITEM	:= TRBTMP->DESCIT01
								EndIf
							EndIf
						EndIf
					EndIf

					If cAlias == "CTI" .And. lImp4Ent
						If !Empty(CLVL)
							If Empty(TRBTMP->DESCCLVL)
								(cArqAux)->DESCCLVL	:= TRBTMP->DESCCV01
							EndIf
						EndiF

						If !Empty(ITEM)
							If Empty(TRBTMP->DESCITEM)
								(cArqAux)->DESCITEM	:= TRBTMP->DESCIT01
							EndIf
						Endif

						If !Empty(CUSTO)
							If Empty(TRBTMP->DESCCC)
								(cArqAux)->DESCCC		:= TRBTMP->DESCCC01
							EndIf
						EndIf
					EndIf
				EndIf

				//Se for Relatorio US Gaap
				If lUsGaap

					nSlAntGap	:= TRBTMP->(SALDOANTDB - SALDOANTCR)	// Saldo Anterior
					nSlAntGapD	:= TRBTMP->(SALDOANTDB)					// Saldo anterior debito
					nSlAntGapC	:= TRBTMP->(SALDOANTCR)					// Saldo anterior credito
					nSlAtuGap	:= TRBTMP->((SALDOANTDB+SALDODEB)- (SALDOANTCR+SALDOCRD))	// Saldo Atual
					nSlAtuGapD	:= TRBTMP->(SALDOANTDB+SALDODEB)					// Saldo Atual debito
					nSlAtuGapC	:= TRBTMP->(SALDOANTCR+SALDOCRD)					// Saldo Atual credito

					nSlDebGap	:= TRBTMP->((SALDOANTDB+SALDODEB) - SALDOANTDB)		// Saldo Debito
					nSlCrdGap	:= TRBTMP->((SALDOANTCR+SALDOCRD) - SALDOANTCR)		// Saldo Credito

					If cConsCrit $ "123" .Or. (cConsCrit == "5" .And. cCritPlCta $ "123")
						If cConsCrit == "5"
							(cArqAux)->SALDOANT	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlAntGap)
							(cArqAux)->SALDOANTDB	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlAntGapD)
							(cArqAux)->SALDOANTCR	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlAntGapC)
							(cArqAux)->SALDOATU	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlAtuGap)
							(cArqAux)->SALDOATUDB	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlAtuGapD)
							(cArqAux)->SALDOATUCR	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlAntGapC)
							(cArqAux)->SALDODEB	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlDebGap)
							(cArqAux)->SALDOCRD	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlCrdGap)
						Else
							(cArqAux)->SALDOANT	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlAntGap)
							(cArqAux)->SALDOANTDB	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlAntGapD)
							(cArqAux)->SALDOANTCR	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlAntGapC)
							(cArqAux)->SALDOATU	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlAtuGap)
							(cArqAux)->SALDOATUDB	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlAtuGapD)
							(cArqAux)->SALDOATUCR	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlAntGapC)
							(cArqAux)->SALDODEB	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlDebGap)
							(cArqAux)->SALDOCRD	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlCrdGap)
						EndIf
					ElseIf cConsCrit == "4" .Or. (cConsCrit == "5" .And. cCritPlCta == "4")
						(cArqAux)->SALDOANT	:= nSlAntGap/nTaxaConv
						(cArqAux)->SALDOANTDB	:= nSlAntGapD/nTaxaConv
						(cArqAux)->SALDOANTCR	:= nSlAntGapC/nTaxaConv
						(cArqAux)->SALDOATU	:= nSlAtuGap/nTaxaConv
						(cArqAux)->SALDOATUDB	:= nSlAtuGapD/nTaxaConv
						(cArqAux)->SALDOATUCR	:= nSlAtuGapC/nTaxaConv
						(cArqAux)->SALDODEB	:= nSlDebGap/nTaxaConv
						(cArqAux)->SALDOCRD	:= nSlCrdGap/nTaxaConv
					EndIf
				EndIf

				If Empty( dDtCorte )
					If nCampoLP > 0
						(cArqAux)->SALDOANTDB	-= TRBTMP->SLDLPANTDB
						(cArqAux)->SALDOANTCR	-= TRBTMP->SLDLPANTCR
						(cArqAux)->SALDODEB		-= Iif(nDivide > 1, Round(NoRound(TRBTMP->MOVLPDEB,3)/nDivide, 2), TRBTMP->MOVLPDEB)
						(cArqAux)->SALDOCRD		-= Iif(nDivide > 1, Round(NoRound(TRBTMP->MOVLPCRD,3)/nDivide, 2), TRBTMP->MOVLPCRD)
					EndIf

					(cArqAux)->SALDOANT	 	:= (cArqAux)->(SALDOANTCR - SALDOANTDB)
					(cArqAux)->SALDOATUDB	:= (cArqAux)->(SALDOANTDB + SALDODEB)
					(cArqAux)->SALDOATUCR	:= (cArqAux)->(SALDOANTCR) + (cArqAux)->(SALDOCRD)
					(cArqAux)->SALDOATU		:= (cArqAux)->(SALDOATUCR - SALDOATUDB)
					(cArqAux)->MOVIMENTO	:= (cArqAux)->(SALDOCRD   - SALDODEB)
				Else
					nSaldoCrt := 0

					If lImpAntLP .And. nCampoLP > 0
						If lSLLPATCTDB .And. lSLLPATCTCR
							nSaldoCrt := ((cArqAux)->SLLPATCTDB - (cArqAux)->SLLPATCTCR)
						EndIf

						(cArqAux)->SALDOANTDB	:= (cArqAux)->((SALDOANTDB - SLDLPANTDB) ) + iif( nSaldoCrt > 0 , Abs( nSaldoCrt ) , 0 )
						(cArqAux)->SALDOANTCR	:= (cArqAux)->((SALDOANTCR - SLDLPANTCR) ) + iif( nSaldoCrt < 0 , Abs( nSaldoCrt ) , 0 )
						(cArqAux)->SALDODEB		-= TRBTMP->MOVLPDEB
						(cArqAux)->SALDOCRD		-= TRBTMP->MOVLPCRD
					Else
						If lSLDANTCTDB .And. lSLDANTCTCR
							nSaldoCrt := ((cArqAux)->SLDANTCTDB - (cArqAux)->SLDANTCTCR)
						EndIf

						(cArqAux)->SALDOANTDB	:= (cArqAux)->(SALDOANTDB) + iif( nSaldoCrt > 0 , Abs( nSaldoCrt ) , 0 )
						(cArqAux)->SALDOANTCR	:= (cArqAux)->(SALDOANTCR) + iif( nSaldoCrt < 0 , Abs( nSaldoCrt ) , 0 )
					EndIf

					(cArqAux)->SALDOANT		:= (cArqAux)->(SALDOANTCR - SALDOANTDB)
					(cArqAux)->SALDOATUDB	:= (cArqAux)->(SALDOANTDB + SALDODEB)
					(cArqAux)->SALDOATUCR	:= (cArqAux)->(SALDOANTCR + SALDOCRD)
					(cArqAux)->SALDOATU		:= (cArqAux)->(SALDOATUCR - SALDOATUDB)
					(cArqAux)->MOVIMENTO	:= (cArqAux)->(SALDOCRD   - SALDODEB)

				Endif


				//Se imprime saldo anterior do periodo anterior zerado, verificar o saldo atual da data de zeramento.
				If ( lImpConta .Or. cAlias == "CT7") .And. lRecDesp0 .And. Subs(TRBTMP->CONTA,1,1) $ cRecDesp

					If cAlias == "CT7" .Or. ( cAlias == "CT3" .And. cHeader == "CT1" )
						aSldRecDes	:= SaldoCT7Fil(TRBTMP->CONTA,dDtZeraRD,cMoeda,cSaldos,'CTBXFUN',.F.,nil,aSelFil,nil,lTodasFil)
					ElseIf cAlias == "CT3" .And. cHeader == "CTT"
						aSldRecDes	:= SaldoCT3Fil(TRBTMP->CONTA,TRBTMP->CUSTO,dDtZeraRD,cMoeda,cSaldos,'CTBXFUN',.F.,Nil,aSelFil,lTodasFil)
					ElseIf cAlias == "CT4" .And. cHeader == "CTD"
						cCusIni		:= Space(aTamCC[1])
						cCusFim		:= Repl("Z",aTamCC[1])
						aSldRecDes	:= SaldTotCT4(TRBTMP->ITEM,TRBTMP->ITEM,cCusIni,cCusFim,TRBTMP->CONTA,TRBTMP->CONTA,dDtZeraRD,cMoeda,cSaldos,aSelFil,,,,,,,,lTodasFil)
					Elseif cAlias == "CTI" .And. cHeader == "CTH"
						cCusIni		:= SPace(aTamCC[1])
						cCusFim		:= Repl("Z",aTamCC[1])

						cItIni  	:= Space(aTamItem[1])
						cItFim   	:= Repl("z",aTamItem[1])

						aSldRecDes := SaldTotCTI(TRBTMP->CLVL,TRBTMP->CLVL,cItIni,cItFim,cCusIni,cCusFim,;
							TRBTMP->CONTA,TRBTMP->CONTA,dDtZeraRD,cMoeda,cSaldos,aSelFil,,,,,,,,lTodasFil)
					EndIf

					If nDivide > 1
						For nCont := 1 To Len(aSldRecDes)
							aSldRecDes[nCont] := Round(NoRound((aSldRecDes[nCont]/nDivide),3),2)
						Next nCont
					EndIf

					nSldRDAtuD	:=	aSldRecDes[4]
					nSldRDAtuC	:=	aSldRecDes[5]
					nSldAtuRD	:= nSldRDAtuC - nSldRDAtuD

					(cArqAux)->SALDOANT		-= nSldAtuRD
					(cArqAux)->SALDOANTDB	-= nSldRDAtuD
					(cArqAux)->SALDOANTCR	-= nSldRDAtuC
					(cArqAux)->SALDOATU		-= nSldAtuRD
					(cArqAux)->SALDOATUDB	-= nSldRDAtuD
					(cArqAux)->SALDOATUCR	-= nSldRdAtuC
				EndIf

				IF (cArqAux)->( FieldPos( "NATCTA" ) ) > 0;
				.AND.	(cAlias == "CT3" .AND. cHeader $ "CT1|CTT");
				.OR.	(cAlias == "CT4" .And. cHeader == "CTD");
				.OR.	(cAlias == "CTI" .And. cHeader == "CTH");
				.OR.	cAlias == "CT7"
					(cArqAux)->NATCTA := CtbSXNatCta(TRBTMP->CONTA)   // Faz retorno do campo CT1_NATCTA
				Endif

				(cArqAux)->(MsUnlock())
			EndIf
			TRBTMP->(dbSkip())
			nMeter++
			if nMeter%1000 = 0
				If ValType(oMeter) == "O"
					oMeter:Set(nMeter)
				EndIf
			Endif
		Enddo

		dbSelectArea("TRBTMP")
		dbCloseArea()					/// FECHA O TRBTMP (RETORNADO DA QUERY)
		lTemQry := .T.
	Endif
EndIf

dbSelectArea(cArqAux)
dbSetOrder(1)

If cAlias $ 'CT3/CT4/CTI' //Se imprime CONTA+ ENTIDADE
	If !Empty(aSetOfBook[5])
		If !lImpConta	//Se for balancete de 1 entidade filtrada por conta
			If cAlias == "CT3"
				cIdent	:= "CTT"
			ElseIf cAlias == "CT4"
				cIdent	:= "CTD"
			ElseIf cAlias == "CTI"
				cIdent 	:= "CTH"
			EndIf
			// Monta Arquivo Lendo Plano Gerencial
			// Neste caso a filtragem de entidades contabeis È desprezada!
			CtbPlGeren(	oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"CTU",;
				cIdent,lImpAntLP,dDataLP,lVlrZerado,cEntidIni,cEntidFim,aGeren,lImpSint,lRecDesp0,cRecDesp,dDtZeraRD,,cSaldos,lPlGerSint,lConsSaldo,,lUsaNmVis,@cNomeVis)
			dbSetOrder(2)
		Else
			If lImpEntGer	//Se for balancete de Entidade (C.Custo/Item/Cl.Vlr por Entid. Gerencial)
				CtPlEntGer(	oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,cAlias,cHeader,;
					lImpAntLP,dDataLP,lVlrZerado,cEntidIni,cEntidFim,cContaIni,cContaFim,;
					cCCIni,cCCFim,cItemIni,cItemFim,cClVlIni,cClVlFim,lImpSint,;
					lRecDesp0,cRecDesp,dDtZeraRD,nDivide,lFiltraCC,lFiltraIt,lFiltraCV, cSaldos )
			Else
				MsgAlert(cMensagem)
				Return
			EndIf
		EndIf
	Else
		If cHeader == "CT1"	//Se for Balancete Conta/Entidade
			//Atualizacao de sinteticas
			If lImpSint	//Se atualiza sinteticas
				CtCtEntSup(oMeter,oText,oDlg,cAlias,lNImpMov,cMoeda)
				If AllTrim(funname()) $ "CTBR140/CTBR145"
					CtContaSup(oMeter,oText,oDlg,lNImpMov,cMoeda,cMoedaDsc)
				Endif
			EndIf
		Else
			If !lImp3Ent	.And. !lImp4Ent //Se n„o for Balancete CC / Conta / Item
				If lImpConta


					If lImpSint	//Se atualiza sinteticas
						CtEntCtSup(oMeter,oText,oDlg,cAlias,lNImpMov,cMoeda,,cEntidIni,cEntidFim,lCttSint)
					EndIf

				Else
					If lImpSint
						If cAlias == "CT3"
							cIdent := "CTT"
						ElseIf cAlias == "CT4"
							cIdent := "CTD"
						ElseIf cAlias == "CTI"
							cIdent := "CTH"
						EndIf
						CtbCTUSup(oMeter,oText,oDlg,lNImpMov,cMoeda,cIdent)
					EndIf

				EndIf
			Else	//Se for Balancete CC / Conta / Item
				If lImp3Ent
					If lImpSint
						Ctb3CtaSup(oMeter,oText,oDlg,cAlias,lNImpMov,cMoeda,cHeader)
					Endif
				ElseIf cAlias == "CTI" .And. lImp4Ent .And. cHeader == "CTT"

					If  lImpAntLP
						CtbCta3Ent(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cContaIni,;
							cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,cMoeda,;
							cSaldos,aSetOfBook,nTamCta,cSegmento,cSegIni,cSegFim,cFiltSegm,lNImpMov,cAlias,cHeader,;
							lCusto,lItem,lClvl,lAtSldBase,nInicio,nFinal,cFilDe,cFilAte,lImpAntLP,dDataLP,;
							nDivide,lVlrZerado)
					EndIf
					If lImpSint
						Ctb4CtaSup(oMeter,oText,oDlg,cAlias,lNImpMov,cMoeda,cHeader)
					Endif
				EndIf
			EndIf
		EndIf
	EndIf
Else
	If cAlias $ 'CTU/CT7' .Or. (!Empty(aSetOfBook[5]) .And. Empty(cAlias))		//So Imprime Entidade ou demonstrativos
		If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
			// Monta Arquivo Lendo Plano Gerencial
			// Neste caso a filtragem de entidades contabeis È desprezada!
			CtbPlGeren(	oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,cAlias,;
				cIdent,lImpAntLP,dDataLP,lVlrZerado,cEntidIni,cEntidFim,aGeren,lImpSint,lRecDesp0,cRecDesp,dDtZeraRD,;
				lMovPeriodo,cSaldos,lPlGerSint,lConsSaldo, cArqAux, lUsaNmVis,@cNomeVis,aSelfil,cQuadroCTB,lDemDRE , dFinalA)
			dbSetOrder(2)
		Else
			//Se nao for for Top Connect
			If lImpSint	//Se atualiza sinteticas
				Do Case
				Case cAlias =="CT7"
					//Atualizacao de sinteticas para codebase e topconnect
					CtContaSup(oMeter,oText,oDlg,lNImpMov,cMoeda,cMoedaDsc)
				Case cAlias == "CTU"
					CtbCTUSup(oMeter,oText,oDlg,lNImpMov,cMoeda,cIdent)
				EndCase
			EndIf
		EndIf
	Else    	//Imprime Relatorios com 2 Entidades
		If !Empty(aSetOfBook[5])
			MsgAlert(cMensagem)
			Return
		Else
			If cAlias == 'CTY'		//Se for Relatorio de 2 Entidades filtrado pela 3a Entidade
				Ct2EntFil(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
					cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					lNImpMov,cAlias,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,;
					cFilDe,cFilAte,lImpAntLP,dDataLP,nDivide,lVlrZerado,cFiltroEnt,cCodFilEnt,aSelFil,lTodasFil)
			ElseIf  cAlias <> 'CVY'
				CtEntComp(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
					cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					lNImpMov,cAlias,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,;
					cFilDe,cFilAte,lImpAntLP,dDataLP,nDivide,lVlrZerado,cFiltroEnt,cCodFilEnt,cFilUsu,aSelFil,lTodasFil,aTmpFil)
			EndIf
		EndIf
	Endif
EndIf

dbSelectArea(cArqAux)

If FieldPos("ORDEMPRN") > 0

	dbSelectArea(cArqAux)
	DbSetOrder(1)
	DbGoTop()
	While ! Eof()

		If Alltrim(Upper(FunName())) == "CTBR180"
			If Empty(SUPERIOR)
				CtGerSup(CONTA, @nOrdem, cAlias,,CUSTO)
			EndIf

		ElseIf cAlias == "CT7" .OR. cAlias == "CT3"
			If Empty(SUPERIOR)
				CtGerSup(CONTA, @nOrdem, cAlias)
			EndIf
		ElseIf cAlias == "CTU"
			If cIdent == "CTT"
				If Empty(CCSUP)
					CtGerSup(CUSTO, @nOrdem,"CTU","CTT")
				EndIf
			ElseIf cIdent == "CTD"
				If Empty(ITSUP)
					CtGerSup(ITEM, @nOrdem,"CTU","CTD")
				EndIf
			ElseIf cIdent == "CTH"
				If Empty(CLSUP)
					CtGerSup(CLVL, @nOrdem,"CTU","CTH")
				Endif
			EndIf
		EndIf
		DbSkip()

	Enddo
	DbSetOrder(2)

Endif
//Se utiliza plano referencial
If !Empty(cPlanoRef) .And. !Empty(cVersao)

	If IsBlind()
		mv_par01	:= ""
	Else
		Pergunte("CTBPLREF2",.T.)
		MakeSqlExpr("CTBPLREF2")
	EndIf
	cArqTmp	:= CtGerPlRef(cTableNam1,cArqTmp,cChave,aChave,aCampos,cPlanoRef,cVersao,lImpSint,lNimpMOv,lImp3Ent,lImp4Ent,cArqAux,cAlias,cHeader,cMoeda,,cEntid_de,cEntid_Ate,lEntSint,;
	lImpConta,nPos,nPosG,nDigitos,nDigitosG,cSegmento, cSegmentoG, cSegIni, cSegIniG, cSegFim, cSegFimG,  cFiltSegm, cFiltSegmG, @_oTempTbPLRef)
	mv_par01	:= cMvPar01Ant


EndIf

If lGrvJson // Grava o campo NIVJSON no arquivo tempor·rio
	CTBNivTmp(cTableNam1,"CONTA","SUPERIOR",cArqTmp)
EndIf

CTDelTmpFil()
For nX := 1 TO Len(aTmpFil)
	CtbTmpErase(aTmpFil[nX])
Next

If _oHashCt1 <> Nil;
	.And. ((cArqAux)->( FieldPos( "NATCTA" ) ) > 0;
	.AND.	(cAlias == "CT3" .AND. cHeader $ "CT1|CTT");
	.OR.	(cAlias == "CT4" .And. cHeader == "CTD");
	.OR.	(cAlias == "CTI" .And. cHeader == "CTH");
	.OR.	cAlias == "CT7")
	_oHashCt1:Clean()
	_oHashCt1 := Nil
EndIf



RestArea(aSaveArea)

If Select(cArqTmp)> 0
	cArqTmp->(dbGoTop())
EndIf

Return cArqTmp
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ CtGerSup    ≥ Autor ≥ Wagner Mobile Costa   ≥ Data ≥ 01.11.02 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Varre os niveis superiores a partir da entidade passada       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ CtbXSal                                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Function CtGerSup(cConta, nOrdem,cAlias,cIdent, cCusto)

Local aAreaEnt	:= GetArea(), lNivel := .F.
Local cSuperior	:= ""
Local cCodigo	:= ""

DEFAULT cAlias := "CT7"
DEFAULT cCusto := ""

If cAlias == "CTU"
	If cIdent == "CTT"
		cCodigo		:= "CUSTO"
		cSuperior	:= "CCSUP"
	ElseIf cIdent == "CTD"
		cCodigo		:= "ITEM"
		cSuperior	:= "ITSUP"
	ElseIf cIdent == "CTH"
		cCodigo		:= "CLVL"
		cSuperior	:= "CLSUP"
    EndIf
EndIf


If Alltrim(Upper(FunName())) == "CTBR180"

	DbSetOrder(3)
	If DbSeek(PadR(cCusto,Len(CUSTO))+cConta) .And. ORDEMPRN <= 0

		While !Eof() .And.  CUSTO = cCusto .And. SUPERIOR = cConta
			aAuxArea := GetArea()
			RestArea(aAreaENT)

		    If ! lNivel .And. (If(FunName()=="CTBR180",ORDEMPRN <= 0,.T.))
				Replace ORDEMPRN With nOrdem ++
				lNivel := .T.
			Endif
			RestArea(aAuxArea)
			CtGerSup(CONTA, @nOrdem,cAlias /*"CT7"*/,,CUSTO)

			DbSkip()

		EndDo

	EndIf

ElseIf cAlias == "CT7" .OR. cAlias == "CT3"

	DbSetOrder(3)
	DbSeek(cConta)

	While !Eof() .And. SUPERIOR = cConta

		aAuxArea := GetArea()
		RestArea(aAreaENT)

	    If ! lNivel .And. (If(Alltrim(Upper(FunName()))=="CTBR180",ORDEMPRN <= 0,.T.))
			Replace ORDEMPRN With nOrdem ++
			lNivel := .T.
		Endif
		RestArea(aAuxArea)
		CtGerSup(CONTA, @nOrdem,cAlias /*"CT7"*/)

		DbSkip()

	EndDo

ElseIf cAlias == "CTU"

	DbSetOrder(3)
	DbSeek(cConta)

	While &(cSuperior) = cConta

		aAuxArea := GetArea()
		RestArea(aAreaENT)

	    If ! lNivel
			Replace ORDEMPRN With nOrdem ++
			lNivel := .T.
		Endif
		RestArea(aAuxArea)
		CtGerSup(&(cCodigo), @nOrdem, cAlias,cIdent)
		DbSkip()

	EndDo
EndIf

RestArea(aAreaENT)

If ! lNivel .And. (If(Alltrim(Upper(FunName()))=="CTBR180",ORDEMPRN <= 0,.T.))
	Replace ORDEMPRN With nOrdem ++
Endif

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} SldTop2Ent
Query para retornar o movimento numa determinada data.

Redirecionada para a rotina SaldoCQPer

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function SldTop2Ent(cAlias,cHeader,cEntid1,cEntid2,dDataIni,dDataFim,nMoeda,cTpsald,lImpAntLP,dDataLP,aSelFil,aTmpFil)

Local aRet 		:= {0,0,0,0,0,0,0,0}
Local cArqBase	:= ""
Local cCCusto		:= Nil
Local cItem		:= Nil
Local cClasse		:= Nil
Local cMoeda		:= ""

Default nMoeda := 1

nMoeda := IIF(Empty(nMoeda),1,nMoeda)
cMoeda := StrZero(nMoeda,2)


If cAlias == 'CTV'
	cArqBase := "CTD"
	If cHeader == 'CTT'
		cCCusto := cEntid1
		cItem	 := cEntid2
	ElseIf cHeader == 'CTD'
		cItem	 := cEntid1
		cCCusto := cEntid2
	EndIf
ElseIf cAlias == 'CTW'
	cArqBase := "CTH"
	If cHeader == 'CTT'
		cCCusto := cEntid1
		cClasse := cEntid2
	ElseIf cHeader == 'CTH'
		cClasse := cEntid1
		cCCusto := cEntid2
	EndIf
ElseIf cAlias == 'CTX'
	cArqBase := "CTH"
	If cHeader == 'CTD'
		cItem 		:= cEntid1
		cClasse	:= cEntid2
	ElseIf cHeader == 'CTH'
		cClasse	:= cEntid1
		cItem 		:= cEntid2
	EndIf
EndIf

If !Empty(cArqBase)
	aRet := SaldoCQPer(@cArqBase,/*cConta*/,@cCCusto,@cItem,@cClasse,/*cIdent*/,@dDataIni,@dDataFim,@cMoeda,@cTpSald,@lImpAntLP,@dDataLP,@aSelFil)
EndIf


Return aRet



//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCTU
Saldo Totalizador por Entidade.

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function SaldoCTU(cIdent,cCodigo,dData,cMoeda,cTpSald,cRotina,lImpAntLP,dDataLP,cFilEsp)

Local aRet 	:= {}
Local cCCusto := ""
Local cItem 	:= ""
Local cClasse := ""

If cIdent $ 'CT3/CTT'
	cIdent		:= "CTT"
	cCCusto	:= cCodigo
ElseIf cIdent $ 'CT4/CTD'
	cIdent		:= "CTD"
	cItem 		:= cCodigo
ElseIf cIdent $ 'CTI/CTH'
	cIdent		:= "CTH"
	cClasse	:= cCodigo
EndIf

aRet := SaldoCQ("CTU",/*cConta*/,@cCCusto,@cItem,@cClasse,@cIdent,@dData,@cMoeda,@cTpSald,@cRotina,@lImpAntLP,@dDataLP,@cFilEsp)


Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} CtEntComp
Gerar Arquivo Temporario para Balancetes Entidade1/Entidade2

@author Alvaro Camillo Neto

@param oMeter	   Controle da regua
@param oText 	   Controle da regua
@param oDlg  	   Janela
@param lEnd  	   Controle da regua -> finalizar
@param dDataIni    Data Inicial de processamento
@param dDataFinal  Data Final de processamento
@param cEntidIni   Codigo Entidade Inicial
@param cEndtidFim  Codigo Entidade Final
@param cMoeda      Moeda
@param cSaldos     Tipos de Saldo a serem processados
@param aSetOfBook  Matriz de configuracao de livros
@param cSegmento   Indica qual o segmento ser· filtrado
@param cSegIni     Conteudo inicial do segmento
@param cSegFim     Conteudo Final do segmento
@param cFiltSegm   Indica se filtrara ou nao segmento
@param lNImpMov    Indica se imprime ou nao a coluna movimento
@param cAlias      Alias para regua
@param cIdent      Identificador do arquivo a ser processado
@param lCusto      Considera Centro de Custo?
@param lItem       Considera Item Contabil?
@param lCLVL       Considera Classe de Valor?
@param lAtSldBase  Indica se deve chamar rot atual. saldo basico
@param lAtSldCmp   Indica se deve chamar rot atua. saldo composto
@param nInicio     Moeda Inicial (p/ atualizar saldo)
@param nFinal      Moeda Final (p/ atualizar saldo)
@param cFilde      Filial inicial (p/ atualizar saldo)
@param cFilAte     Filial final (p/atualizar saldo)
@param lImpAntLP   Imprime lancamentos Lucros e Perdas?
@param dDataLP     Data ultimo Lucros e Perdas
@param nDivide     Divide valores (100,1000,1000000)
@param lVlrZerado  Grava ou nao valores zerados no arq temporario
@param cFiltroEnt  Entidade Gerencial que servira de filtro dentro de outra
                   Entidade Gerencial. Ex.: Centro de Custo sendo filtrado por
                   Item Contabil (CTH)
@param cCodFilEnt  Codigo da Entidade Gerencial utilizada como filtro
@param cFilUsu     Filtro informado pelo usuario


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CtEntComp(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
				cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
				lNImpMov,cAlias,lCusto,lItem,lClvl,lAtSldBase,lAtSldCmp,nInicio,nFinal,cFilDe,;
				cFilAte,lImpAntLP,dDataLP,nDivide,lVlrZerado,cFiltroEnt,cCodFilEnt,cFilUsu,aSelFil,lTodasFil,aTmpFil)

Local aSaveArea 	:= GetArea()
Local cMascara1 	:= ""
Local cMascara2		:= ""
Local nPos			:= 0
Local nDigitos		:= 0
Local cEntid1		:= ""	//Codigo da Entidade Principal
Local cEntid2   	:= "" 	//Codigo da Entidade do Corpo do Relatorio
local nSaldoAnt 	:= 0
Local nSaldoDeb 	:= 0
Local nSaldoCrd 	:= 0
Local nSaldoAtu 	:= 0
Local nSaldoAntD	:= 0
Local nSaldoAntC	:= 0
Local nSaldoAtuD	:= 0
Local nSaldoAtuC	:= 0
Local nSldAnt		:= 0
Local nSldAtu		:= 0
Local nRegTmp   	:= 0
Local nMovimento	:= 0
Local nOrder		:= 0
Local cCadAlias1	:= ""	//Alias do Cadastro da Entidade Principal
Local cCadAlias2	:= ""	//Alias do Cadastro da Entidade que sera impressa no corpo.
Local cCodEnt1		:= ""	//Codigo da Entidade Principal
Local cCodEnt2		:= ""	//Codigo da Entidade que sera impressa no corpo do relat.
Local cDesc1		:= ""
Local cDesc2		:= ""
Local cDescEnt		:= ""
Local cDescEnt1		:= ""	//Descricao da Entidade Principal
Local cDescEnt2		:= ""	//Descricao da Entidade que sera impressa no corpo.
Local cCodSup1		:= ""	//Cod.Superior da Entidade Principal
Local cCodSup2		:= ""	//Cod.Superior da Entidade que sera impressa no corpo.
Local nRecno1		:= 0
Local nRecno2		:= 0
Local nCont			:= 0
Local nTamDesc1		:= ""
Local nTamDesc2		:= ""
Local nTotal		:= 0
Local cOrigem		:= ""
Local cMensagem		:= OemToAnsi(STR0016)+ OemToAnsi(STR0017)
Local dMinData		:= Ctod("")
Local nMeter		:= 0
Local cTmpFilAux
Local nMin			:= 0
Local nMax			:= 0
Local lTotExcl      := .F.

Local cCampUSU		:= ""
Local aStrSTRU
Local nStruLen
Local nStr

DEFAULT cFilUsu	:= ""
DEFAULT aSelFil	 := {}
DEFAULT lTodasFil:= .F.
DEFAULT aTmpFil	 := {}

lVlrZerado	:= Iif(lVlrZerado == Nil,.T.,lVlrZerado)
nDivide 	:= Iif(nDivide == Nil,1,nDivide)

Do Case
Case cAlias == 'CTV'
	cOrigem		:= 'CQ5'
	If cHeader == 'CTT'		//Se for C.Custo/Item
		nOrder 		:= 2
		cCadAlias1	:= 'CTT'
		cCadAlias2	:= 'CTD'
		cCodEnt1	:= 'CUSTO'
		cCodEnt2	:=	'ITEM'
		cCodSup1	:= 'CCSUP'
		cCodSup2	:= 'ITSUP'
		cMascara1	:= aSetOfBook[6]	//Mascara do Centro de Custo
		cMascara2	:= aSetOfBook[7]	//Mascara do Item
		nTamDesc1	:=	Len(CriaVar("CTT->CTT_DESC"+cMoeda))
		nTamDesc2	:=	Len(CriaVar("CTD->CTD_DESC"+cMoeda))
		cDescEnt	:= "DESCCC"
		cFilEnt1 	:=	Iif(Empty(xFilial("CTT")),"C","E")
		cFilEnt2 	:=	Iif(Empty(xFilial("CTD")),"C","E")
	ElseIf cHeader == 'CTD' 	//Se for Item/C.Custo
		nOrder 		:= 1
		cCadAlias1	:= 'CTD'
		cCadAlias2	:= 'CTT'
		cCodEnt1	:= 'ITEM'
		cCodEnt2	:= 'CUSTO'
		cCodSup1	:= 'ITSUP'
		cCodSup2	:= 'CCSUP'
		cMascara1	:= aSetOfBook[7]	//Mascara do Item
		cMascara2	:= aSetOfBook[6]	//Mascara do Centro de Custo
		nTamDesc1	:=	Len(CriaVar("CTD->CTD_DESC"+cMoeda))
		nTamDesc2	:=	Len(CriaVar("CTT->CTT_DESC"+cMoeda))
		cDescEnt	:= "DESCITEM"
		cFilEnt1 	:=	Iif(Empty(xFilial("CTD")),"C","E")
		cFilEnt2 	:=	Iif(Empty(xFilial("CTT")),"C","E")
	EndIf


Case cAlias == 'CTW'
	cOrigem		:= 'CQ7'
	If cHeader == 'CTH'//Se for Cl.Valor/C.Custo
		nOrder 		:= 1
		cCadAlias1	:= 'CTH'
		cCadAlias2	:= 'CTT'
		cCodEnt1	:= 'CLVL'
		cCodEnt2	:= 'CUSTO'
		cCodSup1	:= 'CLSUP'
		cCodSup2	:= 'CCSUP'
		cMascara1	:= aSetOfBook[8]	//Mascara da Classe de Valor
		cMascara2	:= aSetOfBook[6]	//Mascara do Centro de Custo
		nTamDesc1	:=	Len(CriaVar("CTH->CTH_DESC"+cMoeda))
		nTamDesc2	:=	Len(CriaVar("CTT->CTT_DESC"+cMoeda))
		cDescEnt	:= "DESCCLVL"
		cFilEnt1 	:=	Iif(Empty(xFilial("CTH")),"C","E")
		cFilEnt2 	:=	Iif(Empty(xFilial("CTT")),"C","E")
	ElseIf cHeader == 'CTT'//Se for C.Custo/Cl.Valor
		nOrder 		:= 2
		cCadAlias1	:= 'CTT'
		cCadAlias2	:= 'CTH'
		cCodEnt1	:= 'CUSTO'
		cCodEnt2	:= 'CLVL'
		cCodSup1  	:= 'CCSUP'
		cCodSup2	:= 'CLSUP'
		cMascara1	:= aSetOfBook[6]	//Mascara do Centro de Custo
		cMascara2	:= aSetOfBook[8]	//Mascara da Classe de Valor
		nTamDesc1	:=	Len(CriaVar("CTT->CTT_DESC"+cMoeda))
		nTamDesc2	:=	Len(CriaVar("CTH->CTH_DESC"+cMoeda))
		cDescEnt	:= "DESCCC"
		cFilEnt1 	:=	Iif(Empty(xFilial("CTT")),"C","E")
		cFilEnt2 	:=	Iif(Empty(xFilial("CTH")),"C","E")
	EndIf

Case cAlias == 'CTX'
	cOrigem		:= 'CQ7'
	If cHeader == 'CTH'//Se for Cl.Valor/Item
		nOrder 		:= 2
		cCadAlias1	:= 'CTH'
		cCadAlias2	:= 'CTD'
		cCodEnt1	:= 'CLVL'
		cCodEnt2	:= 'ITEM'
		cCodSup1	:= 'CLSUP'
		cCodSup2	:= 'ITSUP'
		cMascara1	:= aSetOfBook[8]	//Mascara da Cl.Valor
		cMascara2	:= aSetOfBook[7]	//Mascara do Item Contab.
		nTamDesc1	:=	Len(CriaVar("CTH->CTH_DESC"+cMoeda))
		nTamDesc2	:=	Len(CriaVar("CTD->CTD_DESC"+cMoeda))
		cDescEnt	:= "DESCCLVL"
		cFilEnt1 	:=	Iif(Empty(xFilial("CTH")),"C","E")
		cFilEnt2 	:=	Iif(Empty(xFilial("CTD")),"C","E")
	ElseIf cHeader == 'CTD'//Se for Item/Cl.Valor
		nOrder		:= 1
		cCadAlias1	:= 'CTD'
		cCadAlias2	:= 'CTH'
		cCodEnt1	:=	'ITEM'
		cCodEnt2	:=	'CLVL'
		cCodSup1  	:=	'ITSUP'
		cCodSup2	:=	'CLSUP'
		cMascara1	:= aSetOfBook[7]	//Mascara do Item Contab.
		cMascara2	:= aSetOfBook[8]	//Mascara da Cl.Valor
		nTamDesc1	:=	Len(CriaVar("CTD->CTD_DESC"+cMoeda))
		nTamDesc2	:=	Len(CriaVar("CTH->CTH_DESC"+cMoeda))
		cDescEnt	:= "DESCITEM"
		cFilEnt1 	:=	Iif(Empty(xFilial("CTD")),"C","E")
		cFilEnt2 	:=	Iif(Empty(xFilial("CTH")),"C","E")
	EndIf

EndCase

If ValType(oMeter) == "O"
	oMeter:SetTotal((cOrigem)->(RecCount()))
	oMeter:Set(0)
EndIf

// Verifica Filtragem por Segmento da Entidade
If !Empty(cSegmento)
	dbSelectArea("CTM")
	dbSetOrder(1)
	If MsSeek(xFilial()+cMascara2)
		While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cMascara2
			nPos += Val(CTM->CTM_DIGITO)
			If CTM->CTM_SEGMEN == cSegmento
				nPos -= Val(CTM->CTM_DIGITO)
				nPos ++
				nDigitos := Val(CTM->CTM_DIGITO)
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf
EndIf


////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USU¡RIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USU¡RIO
If !Empty(cFILUSU)									//// SE O FILTRO DE USU¡RIO NAO ESTIVER VAZIO
	aStrSTRU := (cCadAlias2)->(dbStruct())	//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)
	For nStr := 1 to nStruLen						//// LE A ESTRUTURA DA TABELA
		cCampUSU += aStrSTRU[nStr][1]+","		//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
////////////////////////////////////////////////////////////

Do Case
Case cAlias == "CTV"   			//C.Custo x Item
	If cHeader == "CTT"
		cSelect		:= "ARQ.CQ5_CCUSTO ENTID1, ARQ.CQ5_ITEM ENTID2, " + CRLF
		cSelect		+= "CAD1.CTT_RES ENTRES1, CAD1.CTT_BOOK ENTBOOK1, " + CRLF
		cSelect		+= "CAD1.CTT_CCSUP ENTSUP1, CAD1.CTT_CLASSE ENTCLASSE1, " + CRLF
		If CtbExDtFim("CTT")
			cSelect	+= "CAD1.CTT_DTEXSF CTTDTEXSF, " + CRLF
		EndIf
		cSelect		+= "CAD1.CTT_DESC" + cMoeda+ " DESCENT1, " + CRLF
		cSelect		+= "CAD2.CTD_RES ENTRES2, CAD2.CTD_BOOK ENTBOOK2, CAD2.CTD_ITSUP ENTSUP2, " + CRLF

		If cPaisLoc == "RUS"
			cSelect		+= "CAD1.CTT_NORMAL NORENT1, " + CRLF // Situacao da entidade principal
			cSelect		+= "CAD2.CTD_NORMAL NORENT2, " + CRLF // Situacao da entidade que sera impressa no corpo
		EndIf

		If CtbExDtFim("CTD")
			cSelect	+= "CAD2.CTD_DTEXSF CTDDTEXSF, " + CRLF
		EndIf
		cSelect		+= "CAD2.CTD_CLASSE ENTCLASSE2, CAD2.CTD_DESC"+cMoeda+" DESCENT2 " + CRLF
		cCondEnt1	:= " AND ARQ.CQ5_CCUSTO BETWEEN '" + cEntidIni1+ "' AND '" + cEntidFim1+ "' AND " + CRLF
		cCondEnt1	+= " (ARQ.CQ5_CCUSTO = CAD1.CTT_CUSTO  " + CRLF
		cCondEnt2	:= " ARQ.CQ5_ITEM BETWEEN '" + cEntidIni2+ "' AND '" + cEntidFim2+ "' AND " + CRLF
		cCondEnt2	+= " CAD2.CTD_CLASSE = '2' AND " + CRLF
		cCondEnt2	+= " (ARQ.CQ5_ITEM = CAD2.CTD_ITEM " + CRLF
		cOrderBy	:= " ARQ.CQ5_CCUSTO, ARQ.CQ5_ITEM" + CRLF
	ElseIf cHeader == "CTD"
		cSelect		:= "ARQ.CQ5_ITEM ENTID1, ARQ.CQ5_CCUSTO ENTID2, " + CRLF
		cSelect		+= "CAD1.CTD_RES ENTRES1, CAD1.CTD_BOOK ENTBOOK1, CAD1.CTD_ITSUP ENTSUP1, " + CRLF
		If CtbExDtFim("CTD")
			cSelect	+= "CAD1.CTD_DTEXSF CTDDTEXSF, " + CRLF
		EndIf
		cSelect		+= "CAD1.CTD_CLASSE ENTCLASSE1, CAD1.CTD_DESC"+cMoeda+" DESCENT1, " + CRLF
		cSelect		+= "CAD2.CTT_RES ENTRES2, CAD2.CTT_BOOK ENTBOOK2, " + CRLF
		cSelect		+= "CAD2.CTT_CCSUP ENTSUP2, CAD2.CTT_CLASSE ENTCLASSE2, " + CRLF

		If cPaisLoc == "RUS"
			cSelect		+= "CAD1.CTD_NORMAL NORENT1, " + CRLF // Situacao da entidade principal
			cSelect		+= "CAD2.CTT_NORMAL NORENT2, " + CRLF // Situacao da entidade que sera impressa no corpo
		EndIf

		If CtbExDtFim("CTT")
			cSelect	+= "CAD2.CTT_DTEXSF CTTDTEXSF, " + CRLF
		EndIf
		cSelect		+= "CAD2.CTT_DESC" + cMoeda+ " DESCENT2 " + CRLF
		cCondEnt1	:= " AND ARQ.CQ5_ITEM BETWEEN '" + cEntidIni1+ "' AND '" + cEntidFim1+ "' AND " + CRLF
		cCondEnt1	+= " (ARQ.CQ5_ITEM = CAD1.CTD_ITEM " + CRLF
		cCondEnt2	:= " ARQ.CQ5_CCUSTO BETWEEN '" + cEntidIni2+ "' AND '" + cEntidFim2+ "' AND " + CRLF
		cCondEnt2	+= " CAD2.CTT_CLASSE = '2' AND " + CRLF
		cCondEnt2	+= " (ARQ.CQ5_CCUSTO = CAD2.CTT_CUSTO  " + CRLF
		cOrderBy	:= " ARQ.CQ5_ITEM, ARQ.CQ5_CCUSTO" + CRLF
	EndIf
Case cAlias == "CTW"	//Cl.Valor x C.custo
	If cHeader == "CTT"
		cSelect		:= "ARQ.CQ7_CCUSTO ENTID1, ARQ.CQ7_CLVL ENTID2, " + CRLF
		cSelect		+= "CAD1.CTT_RES ENTRES1, CAD1.CTT_BOOK ENTBOOK1, " + CRLF
		cSelect		+= "CAD1.CTT_CCSUP ENTSUP1, CAD1.CTT_CLASSE ENTCLASSE1, " + CRLF
		If CtbExDtFim("CTT")
			cSelect	+= "CAD1.CTT_DTEXSF CTTDTEXSF, " + CRLF
		EndIf
		cSelect		+= "CAD1.CTT_DESC" + cMoeda+ " DESCENT1, " + CRLF
		cSelect		+= "CAD2.CTH_RES ENTRES2, CAD2.CTH_BOOK ENTBOOK2, CAD2.CTH_CLSUP ENTSUP2, " + CRLF

		If cPaisLoc == "RUS"
			cSelect		+= "CAD1.CTT_NORMAL NORENT1, " + CRLF // Situacao da entidade principal
			cSelect		+= "CAD2.CTH_NORMAL NORENT2, " + CRLF // Situacao da entidade que sera impressa no corpo
		EndIf

		If CtbExDtFim("CTH")
			cSelect	+= "CAD2.CTH_DTEXSF CTHDTEXSF, " + CRLF
		EndIf
		cSelect		+= "CAD2.CTH_CLASSE ENTCLASSE2, CAD2.CTH_DESC"+cMoeda+" DESCENT2 " + CRLF
		cCondEnt1	:= " AND ARQ.CQ7_CCUSTO BETWEEN '" + cEntidIni1+ "' AND '" + cEntidFim1+ "' AND " + CRLF
		cCondEnt1	+= " (ARQ.CQ7_CCUSTO = CAD1.CTT_CUSTO  " + CRLF
		cCondEnt2	:= " ARQ.CQ7_CLVL BETWEEN '" + cEntidIni2+ "' AND '" + cEntidFim2+ "' AND " + CRLF
		cCondEnt2	+= " CAD2.CTH_CLASSE = '2' AND " + CRLF
		cCondEnt2	+= " (ARQ.CQ7_CLVL = CAD2.CTH_CLVL " + CRLF
		cOrderBy	:= " ARQ.CQ7_CCUSTO, ARQ.CQ7_CLVL" + CRLF
	ElseIf cHeader == "CTH"
		cSelect		:= "ARQ.CQ7_CLVL ENTID1, ARQ.CQ7_CCUSTO ENTID2, " + CRLF
		cSelect		+= "CAD1.CTH_RES ENTRES1, CAD1.CTH_BOOK ENTBOOK1, CAD1.CTH_CLSUP ENTSUP1, " + CRLF
		If CtbExDtFim("CTH")
			cSelect	+= "CAD1.CTH_DTEXSF CTHDTEXSF, " + CRLF
		EndIf
		cSelect		+= "CAD1.CTH_CLASSE ENTCLASSE1, CAD1.CTH_DESC"+cMoeda+" DESCENT1, " + CRLF
		cSelect		+= "CAD2.CTT_RES ENTRES2, CAD2.CTT_BOOK ENTBOOK2, " + CRLF
		cSelect		+= "CAD2.CTT_CCSUP ENTSUP2, CAD2.CTT_CLASSE ENTCLASSE2, " + CRLF

		If cPaisLoc == "RUS"
			cSelect		+= "CAD1.CTH_NORMAL NORENT1, " + CRLF // Situacao da entidade principal
			cSelect		+= "CAD2.CTT_NORMAL NORENT2, " + CRLF // Situacao da entidade que sera impressa no corpo
		EndIf

		If CtbExDtFim("CTT")
			cSelect	+= "CAD2.CTT_DTEXSF CTTDTEXSF, " + CRLF
		EndIf
		cSelect		+= "CAD2.CTT_DESC" + cMoeda+ " DESCENT2 " + CRLF
		cCondEnt1	:= " AND ARQ.CQ7_CLVL BETWEEN '" + cEntidIni1+ "' AND '" + cEntidFim1+ "' AND " + CRLF
		cCondEnt1	+= " (ARQ.CQ7_CLVL = CAD1.CTH_CLVL  " + CRLF
		cCondEnt2	:= " ARQ.CQ7_CCUSTO BETWEEN '" + cEntidIni2+ "' AND '" + cEntidFim2+ "' AND " + CRLF
		cCondEnt2	+= " CAD2.CTT_CLASSE = '2' AND " + CRLF
		cCondEnt2	+= " (ARQ.CQ7_CCUSTO = CAD2.CTT_CUSTO " + CRLF
		cOrderBy	:= " ARQ.CQ7_CLVL, ARQ.CQ7_CCUSTO" + CRLF
	EndIf
Case cAlias == "CTX"	//Cl.Valor x Item
	If cHeader == "CTD"
		cSelect		:= "ARQ.CQ7_ITEM ENTID1, ARQ.CQ7_CLVL ENTID2, " + CRLF
		cSelect		+= "CAD1.CTD_RES ENTRES1, CAD1.CTD_BOOK ENTBOOK1, " + CRLF
		cSelect		+= "CAD1.CTD_ITSUP ENTSUP1, CAD1.CTD_CLASSE ENTCLASSE1, " + CRLF
		If CtbExDtFim("CTD")
			cSelect	+= "CAD1.CTD_DTEXSF CTDDTEXSF, " + CRLF
		EndIf
		cSelect		+= "CAD1.CTD_DESC" + cMoeda+ " DESCENT1, " + CRLF
		cSelect		+= "CAD2.CTH_RES ENTRES2, CAD2.CTH_BOOK ENTBOOK2, CAD2.CTH_CLSUP ENTSUP2, " + CRLF

		If cPaisLoc == "RUS"
			cSelect		+= "CAD1.CTD_NORMAL NORENT1, " + CRLF // Situacao da entidade principal
			cSelect		+= "CAD2.CTH_NORMAL NORENT2, " + CRLF // Situacao da entidade que sera impressa no corpo
		EndIf

		If CtbExDtFim("CTH")
			cSelect	+= "CAD2.CTH_DTEXSF CTHDTEXSF, " + CRLF
		EndIf
		cSelect		+= "CAD2.CTH_CLASSE ENTCLASSE2, CAD2.CTH_DESC"+cMoeda+" DESCENT2 " + CRLF
		cCondEnt1	:= " AND ARQ.CQ7_ITEM BETWEEN '" + cEntidIni1+ "' AND '" + cEntidFim1+ "' AND " + CRLF
		cCondEnt1	+= " (ARQ.CQ7_ITEM = CAD1.CTD_ITEM " + CRLF
		cCondEnt2	:= " ARQ.CQ7_CLVL BETWEEN '" + cEntidIni2+ "' AND '" + cEntidFim2+ "' AND " + CRLF
		cCondEnt2	+= " CAD2.CTH_CLASSE = '2' AND " + CRLF
		cCondEnt2	+= " (ARQ.CQ7_CLVL = CAD2.CTH_CLVL " + CRLF
		cOrderBy	:= " ARQ.CQ7_ITEM, ARQ.CQ7_CLVL" + CRLF
	ElseIf cHeader == "CTH"
		cSelect		:= "ARQ.CQ7_CLVL ENTID1, ARQ.CQ7_ITEM ENTID2, " + CRLF
		cSelect		+= "CAD1.CTH_RES ENTRES1, CAD1.CTH_BOOK ENTBOOK1, CAD1.CTH_CLSUP ENTSUP1, " + CRLF
		If CtbExDtFim("CTH")
			cSelect	+= "CAD1.CTH_DTEXSF CTHDTEXSF, " + CRLF
		EndIf
		cSelect		+= "CAD1.CTH_CLASSE ENTCLASSE1, CAD1.CTH_DESC"+cMoeda+" DESCENT1, " + CRLF
		cSelect		+= "CAD2.CTD_RES ENTRES2, CAD2.CTD_BOOK ENTBOOK2, " + CRLF
		cSelect		+= "CAD2.CTD_ITSUP ENTSUP2, CAD2.CTD_CLASSE ENTCLASSE2, " + CRLF

		If cPaisLoc == "RUS"
			cSelect		+= "CAD1.CTH_NORMAL NORENT1, " + CRLF // Situacao da entidade principal
			cSelect		+= "CAD2.CTD_NORMAL NORENT2, " + CRLF // Situacao da entidade que sera impressa no corpo
		EndIf

		If CtbExDtFim("CTD")
			cSelect	+= "CAD2.CTD_DTEXSF CTDDTEXSF, " + CRLF
		EndIf
		cSelect		+= "CAD2.CTD_DESC" + cMoeda+ " DESCENT2 " + CRLF
		cCondEnt1	:= " AND ARQ.CQ7_CLVL BETWEEN '" + cEntidIni1+ "' AND '" + cEntidFim1+ "' AND " + CRLF
		cCondEnt1	+= " (ARQ.CQ7_CLVL = CAD1.CTH_CLVL  " + CRLF
		cCondEnt2	:= " ARQ.CQ7_ITEM BETWEEN '" + cEntidIni2+ "' AND '" + cEntidFim2+ "' AND " + CRLF
		cCondEnt2	+= " CAD2.CTD_CLASSE = '2' AND " + CRLF
		cCondEnt2	+= " (ARQ.CQ7_ITEM = CAD2.CTD_ITEM " + CRLF
		cOrderBy	:= " ARQ.CQ7_CLVL, ARQ.CQ7_ITEM" + CRLF
	EndIf
EndCase


If cFilEnt1 == "E"		//Se for Exclusivo
	lTotExcl := FwModeAccess(cCadAlias1,1) == "E"
	lTotExcl := lTotExcl .And. FwModeAccess(cCadAlias1,2) == "E"
	lTotExcl := lTotExcl .And. FwModeAccess(cCadAlias1,3) == "E"
	lTotExcl := lTotExcl .And. FwModeAccess(cOrigem,1) == "E"
	lTotExcl := lTotExcl .And. FwModeAccess(cOrigem,2) == "E"
	lTotExcl := lTotExcl .And. FwModeAccess(cOrigem,3) == "E"

    If lTotExcl    //se for totalmente exclusivo tanto origem como cCadAlias1
		cCondFil1 := " AND CAD1."+cCadAlias1+"_FILIAL = ARQ."+cOrigem+"_FILIAL) AND " + CRLF
	Else
		cCondFil1 := " AND CAD1."+cCadAlias1+"_FILIAL = '"+xFilial(cCadAlias1)+"' AND ARQ."+cOrigem+"_FILIAL = '"+xFilial(cOrigem)+"' ) AND " + CRLF
	EndIf
Else
	cCondFil1 := " ) AND "
EndIf

If cFilEnt2 == "E"		//Se for Exclusivo
	lTotExcl := FwModeAccess(cCadAlias2,1) == "E"
	lTotExcl := lTotExcl .And. FwModeAccess(cCadAlias2,2) == "E"
	lTotExcl := lTotExcl .And. FwModeAccess(cCadAlias2,3) == "E"
	lTotExcl := lTotExcl .And. FwModeAccess(cOrigem,1) == "E"
	lTotExcl := lTotExcl .And. FwModeAccess(cOrigem,2) == "E"
	lTotExcl := lTotExcl .And. FwModeAccess(cOrigem,3) == "E"

    If lTotExcl  //se for totalmente exclusivo tanto origem como cCadAlias2
		cCondFil2 := " AND CAD2."+cCadAlias2+"_FILIAL = ARQ."+cOrigem+"_FILIAL) AND " + CRLF
	Else
		cCondFil2 := " AND CAD2."+cCadAlias2+"_FILIAL = '"+xFilial(cCadAlias2)+"' AND ARQ."+cOrigem+"_FILIAL = '"+xFilial(cOrigem)+"' ) AND " + CRLF
	EndIf
Else
	cCondFil2 := " ) AND " + CRLF
EndIf

cCtEntComp	:= "cCtEntComp"

cQuery := "SELECT DISTINCT ARQ."+cOrigem+"_FILIAL FILIAL, " + CRLF
cQuery += cCampUSU	 + CRLF								//// ADICIONA OS CAMPOS DO FILTRO DE USUARIO NA QUERY
cQuery += cSelect + CRLF
cQuery += "FROM " + RetSqlName(cOrigem)+" ARQ ," + CRLF
cQuery += " " + RetSqlName(cCadAlias1)+" CAD1 ," + CRLF
cQuery += " " + RetSqlName(cCadAlias2)+" CAD2 " + CRLF
If Empty(aSelFil)
	cQuery += "WHERE ARQ."+cOrigem+"_FILIAL = '" + xFilial(cOrigem)+"' " + CRLF
Else
	cQuery += "WHERE ARQ."+cOrigem+"_FILIAL " + GetRngFil( aSelFil, cOrigem, .T., @cTmpFilAux ) + CRLF
	aAdd(aTmpFil, cTmpFilAux)
Endif
cQuery += " AND ARQ."+cOrigem+"_MOEDA ='"+cMoeda+"' " + CRLF
cQuery += " AND ARQ."+cOrigem+"_TPSALD = '"+cSaldos+"' " + CRLF
cQuery += cCondEnt1 + CRLF
cQuery += cCondFil1 + CRLF
cQuery += cCondEnt2 + CRLF
cQuery += cCondFil2 + CRLF
cQuery += "ARQ.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "AND CAD1.D_E_L_E_T_ = ' '" + CRLF
cQuery += "AND CAD2.D_E_L_E_T_ = ' '" + CRLF
cQuery += "ORDER BY " + CRLF
cQuery += cOrderBy + CRLF
cQuery := ChangeQuery(cQuery)

If ( Select ( "cCtEntComp" ) <> 0 )
	dbSelectArea ( "cCtEntComp" )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCtEntComp,.T.,.F.)


If cAlias $ "CTV/CTW"
	If CtbExDtFim("CTT")
		TCSetField(cCtEntComp,"CTTDTEXSF","D",8,0)
	EndIf
EndIf
If cAlias $ "CTV/CTX"
	If CtbExDtFim("CTD")
		TCSetField(cCtEntComp,"CTDDTEXSF","D",8,0)
	EndIf
EndIf
If cAlias $ "CTW/CTX"
	If CtbExDtFim("CTH")
		TCSetField(cCtEntComp,"CTHDTEXSF","D",8,0)
	EndIf
EndIf

aStru := (cOrigem)->(dbStruct())

dbSelectArea(cCtEntComp)
While !Eof()

	If !Empty(aSetOfBook[1])
		If !(aSetOfBook[1] $ cCtEntComp->ENTBOOK2)
			dbSelectArea(cCtEntComp)
			dbSkip()
			Loop
		EndIf
	Endif

	//Caso faca filtragem por segmento de item,verifico se esta dentro
	//da solicitacao feita pelo usuario.
	If !Empty(cSegmento)
		If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
			If  !(Substr(cCtEntComp->ENTID2,nPos,nDigitos) $ (cFiltSegm) )
				dbSelectArea(cCtEntComp)
				dbSkip()
				Loop
			EndIf
		Else
			If Substr(cCtEntComp->ENTID2,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
					Substr(cCtEntComp->ENTID2,nPos,nDigitos) > Alltrim(cSegFim)
				dbSelectArea(cCtEntComp)
				dbSkip()
				Loop
			EndIf
		Endif
	EndIf

	// Tratando Filtro de Usuario
	If ! Empty( cFILUSU )
		If ! ( &("cCtEntComp->("+cFILUSU+")") )	//	Se nao atende o filtro do usuario
			dbSkip()
			Loop
		EndIf
	EndIf


	//Para calculo do saldo anterior em TopConnect, foi criada uma nova funcao
	//devido a criacao das querys.
	aSaldo	:= 	SldTop2Ent(cAlias,cHeader,cCtEntComp->ENTID1,cCtEntComp->ENTID2,;
		dDataIni,dDataFim,Val(cMoeda),cSaldos,lImpAntLP,dDataLP,aSelFil,aTmpFil)

	nSaldoAntD 	:= aSaldo[7]
	nSaldoAntC 	:= aSaldo[8]
	nSldAnt		:= nSaldoAntC - nSaldoAntD

	nSaldoAtuD 	:= aSaldo[4]
	nSaldoAtuC 	:= aSaldo[5]
	nSldAtu		:= nSaldoAtuC - nSaldoAtuD

	nSaldoDeb  	:= nSaldoAtuD - nSaldoAntD
	nSaldoCrd  	:= nSaldoAtuC - nSaldoAntC
	If nDivide > 1
		nSaldoDeb	:= Round(NoRound((nSaldoDeb/nDivide),3),2)
		nSaldoCrd	:= Round(NoRound((nSaldoCrd/nDivide),3),2)
	EndIf

	nMovimento	:= nSaldoCrd-nSaldoDeb

	If !lVlrZerado .And. (nMovimento = 0 .And. nSldAnt = 0 .And. nSldAtu = 0)  .And. ;
			(nSaldoDeb = 0 .And. nSaldoCrd = 0)
		dbSkip()
		Loop
	EndIf

	If lVlrZerado .And. (nMovimento = 0 .And. nSldAnt = 0 .And. nSldAtu = 0)  .And. ;
			(nSaldoDeb = 0 .And. nSaldoCrd = 0)

		If CtbExDtFim(cCadAlias1)
			If !Empty(cCtEntComp->&((cCadAlias1)+"DTEXSF")) .And. (dtos(dDataIni) > DTOS(cCtEntComp->&((cCadAlias1)+"DTEXSF")))
				dbSelectArea(cCtEntComp)
				dbSkip()
				Loop
			EndIf
		EndIf

		If CtbExDtFim(cCadAlias2)
			If !Empty(cCtEntComp->&((cCadAlias2)+"DTEXSF")) .And. (dtos(dDataIni) > DTOS(cCtEntComp->&((cCadAlias2)+"DTEXSF")))
				dbSelectArea(cCtEntComp)
				dbSkip()
				Loop
			EndIf
		EndIf
	EndIf

	dbSelectArea("cArqTmp")
	dbSetOrder(1)
	If !MsSeek(cCtEntComp->ENTID1+cCtEntComp->ENTID2)
		dbAppend()
		Do Case
		Case cAlias == 'CTV'
			If cHeader	== 'CTT'	//Se for Centro de Custo/Item
				Replace CUSTO   	With cCtEntComp->ENTID1
				Replace DESCCC		With cCtEntComp->DESCENT1
				Replace TIPOCC 		With cCtEntComp->ENTCLASSE1
				Replace CCSUP 		With cCtEntComp->ENTSUP1
				Replace CCRES		With cCtEntComp->ENTRES1
				Replace ITEM 		With cCtEntComp->ENTID2
				Replace DESCITEM	With cCtEntComp->DESCENT2
				Replace TIPOITEM 	With cCtEntComp->ENTCLASSE2
				Replace ITSUP  		With cCtEntComp->ENTSUP2
				Replace ITEMRES		With cCtEntComp->ENTRES2
				If cPaisLoc == "RUS"
					Replace CCNORMAL	With cCtEntComp->NORENT1 // Situacao da entidade principal
					Replace ITNORMAL	With cCtEntComp->NORENT2
				EndIf
			ElseIf cHeader == 'CTD'	//Se for Item/C.Custo
				Replace ITEM 		With cCtEntComp->ENTID1
				Replace DESCITEM	With cCtEntComp->DESCENT1
				Replace TIPOITEM 	With cCtEntComp->ENTCLASSE1
				Replace ITSUP  		With cCtEntComp->ENTSUP1
				Replace ITEMRES		With cCtEntComp->ENTRES1
				Replace CUSTO   	With cCtEntComp->ENTID2
				Replace DESCCC		With cCtEntComp->DESCENT2
				Replace TIPOCC 		With cCtEntComp->ENTCLASSE2
				Replace CCSUP 		With cCtEntComp->ENTSUP2
				Replace CCRES		With cCtEntComp->ENTRES2
				If cPaisLoc == "RUS"
					Replace ITNORMAL	With cCtEntComp->NORENT1 // Situacao da entidade principal
					Replace CCNORMAL	With cCtEntComp->NORENT2 // Situacao da entidade que sera impressa no corpo
				EndIf
			EndIf
		Case cAlias == 'CTW'
			If cHeader	== 'CTH'		//Se for Cl.Valor/C.Custo
				Replace CLVL    	With cCtEntComp->ENTID1
				Replace DESCCLVL	With cCtEntComp->DESCENT1
				Replace TIPOCLVL 	With cCtEntComp->ENTCLASSE1
				Replace CLSUP    	With cCtEntComp->ENTSUP1
				Replace CLVLRES		With cCtEntComp->ENTRES1
				Replace CUSTO   	With cCtEntComp->ENTID2
				Replace DESCCC		With cCtEntComp->DESCENT2
				Replace TIPOCC 		With cCtEntComp->ENTCLASSE2
				Replace CCSUP 		With cCtEntComp->ENTSUP2
				Replace CCRES		With cCtEntComp->ENTRES2
				If cPaisLoc == "RUS"
					Replace CLNORMAL	With cCtEntComp->NORENT1 // Situacao da entidade principal
					Replace CCNORMAL	With cCtEntComp->NORENT2 // Situacao da entidade que sera impressa no corpo
				EndIf
			ElseIf cHeader	== 'CTT'	//Se for C.Custo/Cl.Valor
				Replace CUSTO   	With cCtEntComp->ENTID1
				Replace DESCCC		With cCtEntComp->DESCENT1
				Replace TIPOCC 		With cCtEntComp->ENTCLASSE1
				Replace CCSUP 		With cCtEntComp->ENTSUP1
				Replace CCRES		With cCtEntComp->ENTRES1
				Replace CLVL    	With cCtEntComp->ENTID2
				Replace DESCCLVL	With cCtEntComp->DESCENT2
				Replace TIPOCLVL 	With cCtEntComp->ENTCLASSE2
				Replace CLSUP    	With cCtEntComp->ENTSUP2
				Replace CLVLRES		With cCtEntComp->ENTRES2
				If cPaisLoc == "RUS"
					Replace CCNORMAL	With cCtEntComp->NORENT1 // Situacao da entidade principal
					Replace CLNORMAL	With cCtEntComp->NORENT2 // Situacao da entidade que sera impressa no corpo
				EndIf
			EndIf
		Case cAlias == 'CTX'
			If cHeader == 'CTH'	//Se for Cl.Valor/Item
				Replace CLVL    	With cCtEntComp->ENTID1
				Replace DESCCLVL	With cCtEntComp->DESCENT1
				Replace TIPOCLVL 	With cCtEntComp->ENTCLASSE1
				Replace CLSUP    	With cCtEntComp->ENTSUP1
				Replace CLVLRES		With cCtEntComp->ENTRES1
				Replace ITEM		With cCtEntComp->ENTID2
				Replace DESCITEM	With cCtEntComp->DESCENT2
				Replace TIPOITEM 	With cCtEntComp->ENTCLASSE2
				Replace ITSUP  		With cCtEntComp->ENTSUP2
				Replace ITEMRES		With cCtEntComp->ENTRES2
				If cPaisLoc == "RUS"
					Replace CLNORMAL	With cCtEntComp->NORENT1 // Situacao da entidade principal
					Replace ITNORMAL	With cCtEntComp->NORENT2 // Situacao da entidade que sera impressa no corpo
				EndIf
			ElseIf cHeader	== 'CTD'	//Se for Item/Cl.Valor
				Replace ITEM		With cCtEntComp->ENTID1
				Replace DESCITEM	With cCtEntComp->DESCENT1
				Replace TIPOITEM 	With cCtEntComp->ENTCLASSE1
				Replace ITSUP  		With cCtEntComp->ENTSUP1
				Replace ITEMRES		With cCtEntComp->ENTRES1
				Replace CLVL    	With cCtEntComp->ENTID2
				Replace DESCCLVL	With cCtEntComp->DESCENT2
				Replace TIPOCLVL 	With cCtEntComp->ENTCLASSE2
				Replace CLSUP    	With cCtEntComp->ENTSUP2
				Replace CLVLRES		With cCtEntComp->ENTRES2
				If cPaisLoc == "RUS"
					Replace ITNORMAL	With cCtEntComp->NORENT1 // Situacao da entidade principal
					Replace CLNORMAL	With cCtEntComp->NORENT2 // Situacao da entidade que sera impressa no corpo
				EndIf
			Endif
		EndCase
	EndIf

	If nDivide > 1
		For nCont := 1 To Len(aSaldo)
			aSaldo[nCont] := Round(NoRound((aSaldo[nCont]/nDivide),3),2)
		Next nCont
	EndIf

	dbSelectArea("cArqTmp")
	dbSetOrder(1)
	Replace SALDOANT With aSaldo[6]
	Replace SALDOATU With aSaldo[1]
	Replace SALDODEB With nSaldoDeb				// Saldo Debito
	Replace SALDOCRD With nSaldoCrd				// Saldo Credito

	If !lNImpMov
		Replace MOVIMENTO With nSaldoCrd-nSaldoDeb
	Endif

	dbSelectArea(cCtEntComp)
	dbSkip()
	nMeter++
	If nMeter%1000 = 0
		If ValType(oMeter) == "O"
			oMeter:Set(nMeter)
		EndIf
	EndIf
EndDo

If ( Select ( "cCtEntComp" ) <> 0 )
	dbSelectArea ( "cCtEntComp" )
	dbCloseArea ()
Endif

// Grava sinteticas
dbSelectArea("cArqTmp")
dbGoTop()
If ValType(oMeter) == "O"
	oMeter:SetTotal(("cArqTmp")->(RecCount()))
	oMeter:Set(0)
EndIf

While!Eof()

nSaldoAnt	:= SALDOANT
nSaldoAtu	:= SALDOATU
nSaldoDeb	:= SALDODEB
nSaldoCrd	:= SALDOCRD
nMovimento	:= MOVIMENTO
nSaldoAntD	:= SALDOANTDB
nSaldoAntC	:= SALDOANTCR
nSaldoAtuD	:= SALDOATUDB
nsaldoAtuC	:= SALDOATUCR

nRegTmp := Recno()

dbSelectArea(cCadAlias2)
dbSetOrder(1)
If Empty(&(cCadAlias2+"->"+cCadAlias2+"_"+cCodSup2))
	dbSelectArea("cArqTmp")
	Replace NIVEL1 With .T.
	dbSelectArea(cCadAlias2)
EndIf
MsSeek(xFilial(cCadAlias2)+ &("cArqTmp->"+cCodSup2))

While !Eof() .And. &(cCadAlias2+"->"+cCadAlias2+"_FILIAL") == xFilial()

	cEntid1	 := &("cArqTmp->"+cCodEnt1)
	cDesc1	 := &("cArqTmp->"+cDescEnt)
	cEntSup2 := &(cCadAlias2+"->"+cCadAlias2+"_"+cCodEnt2)

	cDescEnt2	:= (cCadAlias2+"->"+cCadAlias2+"_DESC")
	cDesc2		:= &(cDescEnt2+cMoeda)
	If Empty(cDesc2)	// Caso nao preencher descricao da moeda selecionada
		cDesc2	:= &(cDescEnt2+"01")
	Endif

	cSeek 		:= cEntid1+cEntSup2

	dbSelectArea(cCadAlias1)
	dbSetOrder(1)
	MsSeek(xFilial(cCadAlias1)+cEntid1,.F.)

	dbSelectArea("cArqTmp")
	dbSetOrder(1)
	If !MsSeek(cSeek)
		dbAppend()
		Do Case
		Case cAlias == 'CTV'
			If cHeader	== 'CTT'	//Se for Centro de Custo/Item
				Replace CUSTO   	With cEntid1
				Replace DESCCC		With cDesc1
				Replace TIPOCC 		With CTT->CTT_CLASSE
				Replace CCSUP 		With CTT->CTT_CCSUP
				Replace CCRES		With CTT->CTT_RES
				Replace ITEM 		With cEntSup2
				Replace DESCITEM	With cDesc2
				Replace TIPOITEM 	With CTD->CTD_CLASSE
				Replace ITSUP  		With CTD->CTD_ITSUP
				Replace ITEMRES		With CTD->CTD_RES
			ElseIf cHeader == 'CTD'	//Se for Item/C.Custo
				Replace ITEM 		With cEntid1
				Replace DESCITEM	With cDesc1
				Replace TIPOITEM 	With CTD->CTD_CLASSE
				Replace ITSUP  		With CTD->CTD_ITSUP
				Replace ITEMRES		With CTD->CTD_RES
				Replace CUSTO   	With cEntSup2
				Replace DESCCC		With cDesc2
				Replace TIPOCC 		With CTT->CTT_CLASSE
				Replace CCSUP 		With CTT->CTT_CCSUP
				Replace CCRES		With CTT->CTT_RES
			EndIf
		Case cAlias == 'CTW'
			If cHeader	== 'CTH'		//Se for Cl.Valor/C.Custo
				Replace CLVL    	With cEntid1
				Replace DESCCLVL	With cDesc1
				Replace TIPOCLVL 	With CTH->CTH_CLASSE
				Replace CLSUP    	With CTH->CTH_CLSUP
				Replace CLVLRES		With CTH->CTH_RES
				Replace CUSTO   	With cEntSup2
				Replace DESCCC		With cDesc2
				Replace TIPOCC 		With CTT->CTT_CLASSE
				Replace CCSUP 		With CTT->CTT_CCSUP
				Replace CCRES		With CTT->CTT_RES
			ElseIf cHeader	== 'CTT'	//Se for C.Custo/Cl.Valor
				Replace CUSTO   	With cEntid1
				Replace DESCCC		With cDesc1
				Replace TIPOCC 		With CTT->CTT_CLASSE
				Replace CCSUP 		With CTT->CTT_CCSUP
				Replace CCRES		With CTT->CTT_RES
				Replace CLVL    	With cEntSup2
				Replace DESCCLVL	With cDesc2
				Replace TIPOCLVL 	With CTH->CTH_CLASSE
				Replace CLSUP    	With CTH->CTH_CLSUP
				Replace CLVLRES		With CTH->CTH_RES
			EndIf
		Case cAlias == 'CTX'
			If cHeader == 'CTH'	//Se for Cl.Valor/Item
				Replace CLVL    	With cEntid1
				Replace DESCCLVL	With cDesc1
				Replace TIPOCLVL 	With CTH->CTH_CLASSE
				Replace CLSUP    	With CTH->CTH_CLSUP
				Replace CLVLRES		With CTH->CTH_RES
				Replace ITEM		With cEntSup2
				Replace DESCITEM	With cDesc2
				Replace TIPOITEM 	With CTD->CTD_CLASSE
				Replace ITSUP  		With CTD->CTD_ITSUP
				Replace ITEMRES		With CTD->CTD_RES
			ElseIf cHeader	== 'CTD'	//Se for Item/Cl.Valor
				Replace ITEM		With cEntid1
				Replace DESCITEM	With cDesc1
				Replace TIPOITEM 	With CTD->CTD_CLASSE
				Replace ITSUP  		With CTD->CTD_ITSUP
				Replace ITEMRES		With CTD->CTD_RES
				Replace CLVL    	With cEntSup2
				Replace DESCCLVL	With cDesc2
				Replace TIPOCLVL 	With CTH->CTH_CLASSE
				Replace CLSUP    	With CTH->CTH_CLSUP
				Replace CLVLRES		With CTH->CTH_RES
			Endif
		EndCase

	EndIf

	Replace	 SALDOANT With SALDOANT + nSaldoAnt
	Replace  SALDOANTDB With SALDOANTDB + nSaldoAntD
	Replace  SALDOANTCR	With SALDOANTCR + nSaldoAntC
	Replace  SALDOATU With SALDOATU + nSaldoAtu
	Replace  SALDOATUDB	With SALDOATUDB	+ nSaldoAtuD
	Replace  SALDOATUCR	With SALDOATUCR + nsaldoAtuC
	Replace  SALDODEB With SALDODEB + nSaldoDeb
	Replace  SALDOCRD With SALDOCRD + nSaldoCrd
	If !lNImpMov
		Replace MOVIMENTO With MOVIMENTO + nMovimento
	Endif

	dbSelectArea(cCadAlias2)
	If Empty(&(cCadAlias2+"->"+cCadAlias2+"_"+cCodSup2))
		dbSelectArea("cArqTmp")
		Replace NIVEL1 With .T.
		dbSelectArea(cCadAlias2)
		Exit
	EndIf

	dbSelectArea(cCadAlias2)
	MsSeek(xFilial(cCadAlias2)+ &("cArqTmp->"+cCodSup2))
EndDo
dbSelectArea("cArqTmp")
dbGoto(nRegTmp)
dbSkip()
nMeter++
If nMeter%1000 = 0
	If ValType(oMeter) == "O"
		oMeter:Set(nMeter)
	EndIF
EndIf
EndDo
RestArea(aSaveArea)

Return


//-------------------------------------------------------------------
/*{Protheus.doc} CtGerComp
Gerar Arquivo Temporario para Comparativos (6 colunas)

@author Alvaro Camillo Neto

@param oMeter	    Objeto oMeter
@param oText	    Objeto oText
@param oDlg	    Objeto oDlg
@param lEnd	    lEnd
@param dDataIni	     Data Inicial
@param dDataFim	     Data Final
@param cAlias	     Alias do Arquivo
@param cContaIni     Conta Inicial
@param cContaFim     Conta Final
@param cCCIni	     Centro de Custo Inicial
@param cCCFim	     Centro de Custo Final
@param cItemIni	      Item Inicial
@param cItemFim	      Item Final
@param cClvlIni	      Classe de Valor Inicial
@param cClVlFim	      Classe de Valor Final
@param cMoeda	      Moeda
@param cSaldos	      Saldo
@param aSetOfBook     Set Of Book
@param cSegmento      Ate qual segmento sera impresso (nivel)
@param cSegIni	       Segmento Inicial
@param cSegFim	       Segmento Final
@param cFiltSegm       Segmento Contido em
@param lNImpMov	       Se Imprime Entidade sem movimento
@param lImpConta       Se Imprime Conta
@param nGrupo	       Grupo

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function CTGerComp(oMeter,oText,oDlg,lEnd,cArqtmp,;
						dDataIni,dDataFim,cAlias,cIdent,cContaIni,;
				  		cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,	cClVlFim,cMoeda,;
				  		cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
				  		lNImpMov,lImpConta,nGrupo,cHeader,lImpAntLP,dDataLP,nDivide,cTpVlr,;
				  		lFiliais,aFiliais,lMeses,aMeses,lVlrZerado,lEntid,aEntid,lImpSint,cString,;
				  		cFilUSU,lImpTotS,lImp4Ent,c1aEnt,c2aEnt,c3aEnt,c4aEnt,lAtSlBase,lValMed,lSalAcum,aSelFil,lTodasFil,cNomeTab)

Local aTamConta		:= TAMSX3("CT1_CONTA")
Local aTamCtaRes	:= TAMSX3("CT1_RES")
Local aTamCC        := TAMSX3("CTT_CUSTO")
Local aTamCCRes 	:= TAMSX3("CTT_RES")
Local aTamItem  	:= TAMSX3("CTD_ITEM")
Local aTamItRes 	:= TAMSX3("CTD_RES")
Local aTamClVl  	:= TAMSX3("CTH_CLVL")
Local aTamCvRes 	:= TAMSX3("CTH_RES")
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local aCtbMoeda		:= {}
Local aSaveArea 	:= GetArea()
Local aCampos
Local aStruTMP		:= {}
Local cChave
Local cCodMasc		:= ""
Local nTamCta 		:= Len(CriaVar("CT1->CT1_DESC"+cMoeda))
Local nTamItem		:= Len(CriaVar("CTD->CTD_DESC"+cMoeda))
Local nTamCC  		:= Len(CriaVar("CTT->CTT_DESC"+cMoeda))
Local nTamClVl		:= Len(CriaVar("CTH->CTH_DESC"+cMoeda))
Local nTamGrupo		:= Len(CriaVar("CT1->CT1_GRUPO"))
Local nPos			:= 0
Local nDigitos		:= 0
Local nDecimais		:= 0
Local cCodigo		:= ""
Local cEntidIni		:= ""
Local cEntidFim		:= ""
Local cEntidIni1	:= ""
Local cEntidFim1	:= ""
Local cEntidIni2	:= ""
Local cEntidFim2	:= ""
Local cArqTmp1		:= ""
Local lCusto		:= CtbMovSaldo("CTT")//Define se utiliza C.Custo
Local lItem 		:= CtbMovSaldo("CTD")//Define se utiliza Item
Local lClVl			:= CtbMovSaldo("CTH")//Define se utiliza Cl.Valor
Local lAtSldBase	:= Iif(GetMV("MV_ATUSAL")== "S",.T.,.F.)
Local lAtSldCmp		:= Iif(GetMV("MV_SLDCOMP")== "S",.T.,.F.)
Local nInicio		:= Val(cMoeda)
Local nFinal		:= Val(cMoeda)
Local cFilDe		:= xFilial(cAlias)
Local cFilate		:= xFilial(cAlias)
Local cMensagem		:= ""
Local nMeter		:= 0
Local lTemQry		:= .F.							/// SE UTILIZOU AS QUERYS PARA OBTER O SALDO DAS ANALITICAS
Local nTRB			:= 1
Local nCont			:= 0
Local dDataAnt		:= CTOD("  /  /  ")
Local cFilXAnt		:= ""
Local nTamFilial 	:= IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3( "CT2_FILIAL" )[1] )
Local nMin	:= 0
Local nMax	:= 0

Local aChave		:= {}
Local nTamCt	:= aTamConta[1]
Local cTableNam1 	:= ""

Local cMvPar01Ant	:= mv_par01

Private cPlanoRef	:= aSetOfBook[11]
Private cVersao		:= aSetOfBook[12]


cIdent		:=	Iif(cIdent == Nil,'',cIdent)
nGrupo		:=	Iif(nGrupo == Nil,2,nGrupo)
cHeader		:= Iif(cHeader == Nil,'',cHeader)

DEFAULT lImpSint	:= .F.
DEFAULT cMoeda		:= "01"		//// SE NAO FOR INFORMADA A MOEDA ASSUME O PADRAO 01
DEFAULT lEntid		:= .F.
DEFAULT lMeses		:= .F.
DEFAULT lImpTotS	:= .F.
DEFAULT lImp4Ent	:= .F.
DEFAULT c1aEnt		:= ""
DEFAULT c2aEnt		:= ""
DEFAULT c3aEnt		:= ""
DEFAULT c4aEnt		:= ""
DEFAULT lAtSlBase	:= .T.
DEFAULT lValMed		:= .F.
DEFAULT lSalAcum	:= .F.
DEFAULT lTodasFil   := .F.
DEFAULT cArqTmp		:= ""
DEFAULT nDivide     := 1
dMinData := CTOD("")

// Retorna Decimais
aCtbMoeda := CTbMoeda(cMoeda)
nDecimais := aCtbMoeda[5]

//Se utiliza o plano referencial, desconsidera os filtros das entidades dos relatÛrios.
If !Empty(cPlanoRef) .And. !Empty(cVersao)
	//Se o relatÛrio n„o possuir conta, o plano referencial e a vers„o ser„o desconsiderados.
	//Ser· considerado cÛd. config. livros em branco.
	If cAlias $ "CTU/CTV/CTW/CTX/CVY"
		Help("  ",1,"CTBNOPLREF",,STR0048,1,0) //"Plano referencial n„o disponÌvel nesse relatÛrio. O relatÛrio ser· processado desconsiderando a configuraÁ„o de livros."
		cPlanoRef		:= ""
		cVersao			:= ""
		//aSetOfBook[1]	:= ""
		aSetOfBook		:= CTBSetOf("")
	Else
		cContaIni	:= Space(aTamConta[1])
		cContaFim	:= Replicate("Z",aTamConta[1])
		nTamCt	:= 70
	EndIf
Endif

aCampos := {{ "CONTA"		, "C", nTamCt, 0 },;  			// Codigo da Conta
{ "NORMAL"		, "C", 01			, 0 },;			// Situacao
{ "CTARES"		, "C", aTamCtaRes[1], 0 },;  			// Codigo Reduzido da Conta
{ "DESCCTA"	, "C", nTamCta		, 0 },;  			// Descricao da Conta
{ "CUSTO"		, "C", aTamCC[1]	, 0 },; 	 		// Codigo do Centro de Custo
{ "CCRES"		, "C", aTamCCRes[1], 0 },;  			// Codigo Reduzido do Centro de Custo
{ "DESCCC" 	, "C", nTamCC		, 0 },;  			// Descricao do Centro de Custo
{ "ITEM"		, "C", aTamItem[1]	, 0 },; 	 		// Codigo do Item
{ "ITEMRES" 	, "C", aTamItRes[1], 0 },;  			// Codigo Reduzido do Item
{ "DESCITEM" 	, "C", nTamItem		, 0 },;  			// Descricao do Item
{ "CLVL"		, "C", aTamClVl[1]	, 0 },; 	 		// Codigo da Classe de Valor
{ "CLVLRES"	, "C", aTamCVRes[1], 0 },; 		 	// Cod. Red. Classe de Valor
{ "DESCCLVL"   , "C", nTamClVl		, 0 },;  			// Descricao da Classe de Valor
{ "COLUNA1"	, "N", aTamVal[1]+2, nDecimais},; 	// Saldo Anterior
{ "COLUNA2"   	, "N", aTamVal[1]+2	, nDecimais},; 	// Saldo Anterior Debito
{ "COLUNA3"   	, "N", aTamVal[1]+2	, nDecimais},; 	// Saldo Anterior Credito
{ "COLUNA4" 	, "N", aTamVal[1]+2	, nDecimais},;  	// Debito
{ "COLUNA5" 	, "N", aTamVal[1]+2	, nDecimais},;  	// Credito
{ "COLUNA6"  	, "N", aTamVal[1]+2	, nDecimais},;  	// Saldo Atual
{ "COLUNA7"	, "N", aTamVal[1]+2	, nDecimais},; 	// Saldo Anterior
{ "COLUNA8"   	, "N", aTamVal[1]+2	, nDecimais},; 	// Saldo Anterior Debito
{ "COLUNA9"   	, "N", aTamVal[1]+2	, nDecimais},; 	// Saldo Anterior Credito
{ "COLUNA10" 	, "N", aTamVal[1]+2	, nDecimais},;  	// Debito
{ "COLUNA11" 	, "N", aTamVal[1]+2	, nDecimais},;  	// Credito
{ "COLUNA12"  	, "N", aTamVal[1]+2	, nDecimais},;  	// Saldo Atual
{ "TIPOCONTA"	, "C", 01			, 0 },;			// Conta Analitica / Sintetica
{ "TIPOCC"  	, "C", 01			, 0 },;			// Centro de Custo Analitico / Sintetico
{ "TIPOITEM"	, "C", 01			, 0 },;			// Item Analitica / Sintetica
{ "TIPOCLVL"	, "C", 01			, 0 },;			// Classe de Valor Analitica / Sintetica
{ "CTASUP"		, "C", nTamCt, 0 },;			// Codigo do Centro de Custo Superior
{ "CCSUP"		, "C", aTamCC[1]	, 0 },;			// Codigo do Centro de Custo Superior
{ "ITSUP"		, "C", aTamItem[1]	, 0 },;			// Codigo do Item Superior
{ "CLSUP"	    , "C", aTamClVl[1] , 0 },;			// Codigo da Classe de Valor Superior
{ "ORDEM"		, "C", 10			, 0 },;			// Ordem
{ "GRUPO"		, "C", nTamGrupo	, 0 },;			// Grupo Contabil
{ "TOTVIS"		, "C", 01			, 0 },;
	{ "SLDENT"		, "C", 01			, 0 },;
	{ "FATSLD"		, "C", 01			, 0 },;
	{ "VISENT"		, "C", 01			, 0 },;
	{ "IDENTIFI"	, "C", 01			, 0 },;
	{ "ESTOUR"  	, "C", 01			, 0 },;			//Define se eh conta estourada
{ "NIVEL1"		, "L", 01			, 0 },;				// Logico para identificar se
{ "COLVISAO"	, "N", 01			, 0 },;				// Logico para identificar se 																	// eh de nivel 1 -> usado como
{ "FILIAL"		, "C", nTamFilial	, 0 }}				// Filial
// eh de nivel 1 -> usado como
// totalizador do relatorio

///// TRATAMENTO PARA ATUALIZA«√O DE SALDO BASE
//Se os saldos basicos nao foram atualizados na dig. lancamentos
If !lAtSldBase .And. !__IsCtbJob
	dIniRep := ctod("")
	If Need2Reproc(dDataFim,cMoeda,cSaldos,@dIniRep)
		//Chama Rotina de Atualizacao de Saldos Basicos.
		oProcess := MsNewProcess():New({|lEnd|	CTBA190(.T.,dIniRep,dDataFim,cFilAnt,cFilAnt,cSaldos,.T.,cMoeda) },"","",.F.)
		oProcess:Activate()
	EndIf
Endif


/// TRATAMENTO PARA OBTEN«√O DO SALDO DAS CONTAS ANALITICAS
Do Case
Case cAlias  == "CT7"
	//Se for Comparativo de Conta por 6 meses/12 meses
	cEntidIni	:= cContaIni
	cEntidFim	:= cContaFim
	cCodMasc	:= aSetOfBook[2]
	If nGrupo == 2
		cChave 	:= "CONTA"
		aChave	:= {"CONTA"}
	Else									// Indice por Grupo -> Totaliza por grupo
		cChave 	:= "CONTA+GRUPO"
		aChave	:= {"CONTA","GRUPO"}
	EndIf

	If  Empty(aSetOfBook[5])				/// S” H¡ QUERY SEM O PLANO GERENCIAL
		If Empty(cFilUSU)
			cFILUSU := ".T."
		Endif
		If lMeses
			If cTpVlr == "S"			/// COMPARATIVO DE SALDO ACUMULADO
				CT7CompQry(dDataIni,dDataFim,cSaldos,cMoeda,cContaIni,cContaFim,aSetOfBook,lVlrZerado,lMeses,aMeses,cString,cFILUSU,lImpAntLP,dDataLP,.T.)
			Else						/// COMPARATIVO DE MOVIMENTO DO PERIODO
				CT7CompQry(dDataIni,dDataFim,cSaldos,cMoeda,cContaIni,cContaFim,aSetOfBook,lVlrZerado,lMeses,aMeses,cString,cFILUSU,lImpAntLP,dDataLP,.F.)
			Endif
		EndIf
	EndIf
Case cAlias == "CTU"
	If cIdent == "CTT"
		cEntidIni	:= cCCIni
		cEntidFim	:= cCCFim
		cChave		:= "CUSTO"
		aChave		:= {"CUSTO"}
	EndIf
Case cAlias == "CT3"

	If !Empty(aSetOfBook[5])
		cMensagem	:= OemToAnsi(STR0002)// O plano gerencial ainda nao esta disponivel nesse relatorio.
		MsgInfo(cMensagem)
		RestArea(aSaveArea)
		Return
	Endif

	If cHeader == "CTT"
		cChave		:= "CUSTO+CONTA"
		aChave		:= {"CUSTO","CONTA"}
		cEntidIni1	:= cCCIni
		cEntidFim1	:= cCCFim
		cEntidIni2	:= cContaIni
		cEntidFim2	:= cContaFim
		cCodMasc	:= aSetOfBook[2]
	ElseIf cHeader == "CT1"
		cChave		:= "CONTA+CUSTO"
		aChave		:= {"CONTA","CUSTO"}
		cEntidIni1	:= cContaIni
		cEntidFim1	:= cContaFim
		cEntidIni2	:= cCCIni
		cEntidFim2	:= cCCFim
		cCodMasc	:= aSetOfBook[6]
	EndIf


	CT3CompQry(dDataIni,dDataFim,cCCIni,cCCFim,cContaIni,cContaFim,cMoeda,cSaldos,aSetOfBook,lImpAntLP,dDataLP,lMeses,aMeses,lVlrZerado,lEntid,aEntid,cHeader,cString,cFILUSU,cTpVlr=="S")
	If Empty(cFilUSU)
		cFILUSU := ".T."
	Endif


Case cAlias == "CTI"
	If lImp4Ent	//Se for Comparativo de 4 entidades

		CTICmp4Ent(dDataIni,dDataFim,cContaIni,cContafim,cCCIni,cCCFim,cItemIni,cItemFim,cClVlIni,cClVlFim,;
			cMoeda,cSaldos,aSetOfBook,lImpAntLP,dDataLP,cTpVlr,aMeses,cString,cFilUSU)
		If Empty(cFilUSU)
			cFILUSU := ".T."
		Endif

	EndIf
	cChave	:= c1aEnt+"+"+c2aEnt+"+"+c3aEnt+"+"+c4aEnt
Case cAlias == "CTV"

	If !Empty(aSetOfBook[5])
		cMensagem	:= OemToAnsi(STR0002)// O plano gerencial ainda nao esta disponivel nesse relatorio.
		MsgInfo(cMensagem)
		RestArea(aSaveArea)
		Return
	Endif

	If cHeader == "CTT"
		cChave	:=	"CUSTO+ITEM"
		aChave	:= {"CUSTO","ITEM"}
		cEntidIni1	:=	cCCIni
		cEntidFim1	:=	cCCFim
		cEntidIni2	:=	cItemIni
		cEntidFim2	:=	cItemFim
	ElseIf cHeader == "CTD"
		cChave		:=	"ITEM+CUSTO"
		aChave		:= {"ITEM","CUSTO"}
		cEntidIni1	:=	cItemIni
		cEntidFim1	:=	cItemFim
		cEntidIni2	:=	cCCIni
		cEntidFim2	:=	cCCFim
	EndIf

	CTVCompQry(dDataIni,dDataFim,cCCIni,cCCFim,cItemIni,cItemFim,cMoeda,cSaldos,aSetOfBook,lImpAntLP,dDataLP,lMeses,aMeses,lVlrZerado,lEntid,aEntid,cHeader,cString,cFILUSU)
	If Empty(cFilUSU)
		cFILUSU := ".T."
	Endif

Case cAlias == "CTX"
	If cHeader == "CTH"
		cChave		:= "CLVL+ITEM"
		aChave		:= {"CLVL","ITEM"}
		cEntidIni1	:=	cClVlIni
		cEntidFim1	:=	cClVlFim
		cEntidIni2	:=	cItemIni
		cEntidFim2	:= cItemFim
		cCodMasc	:= aSetOfBook[7]
	ElseIf cHeader == "CTD"
		cChave		:= "ITEM+CLVL"
		aChave		:= {"ITEM","CLVL"}
		cEntidIni1	:=	cItemIni
		cEntidFim1	:=	cItemFim
		cEntidIni2	:=	cClVlIni
		cEntidFim2	:= 	cClVlFim
	EndIf

	CTXCompQry(dDataIni,dDataFim,cItemIni,cItemFim,cClVlIni,cClVlFim,cMoeda,cSaldos,aSetOfBook,lImpAntLP,dDataLP,lMeses,aMeses,lVlrZerado,lEntid,aEntid,cHeader,cString,cFILUSU,lImpAntLP,dDataLP)
	If Empty(cFilUSU)
		cFILUSU := ".T."
	Endif

EndCase

If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
	cChave	:= "CONTA"
	aChave	:= {"CONTA"}
Endif


If ( Select ( "cArqTmp" ) <> 0 )
	dbSelectArea ( "cArqTmp" )
	dbCloseArea ()
Endif

If _oTempTable <> Nil
	_oTempTable:Delete()
EndIf

//-------------------
//CriaÁ„o do objeto
//-------------------
_oTempTable := FWTemporaryTable():New("cArqTmp")
_oTempTable:SetFields( aCampos )
lCriaInd := .T.
_oTempTable:AddIndex("1", aChave)
If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
	_oTempTable:AddIndex("2", {"ORDEM"})
Endif

//------------------
//CriaÁ„o da tabela
//------------------
_oTempTable:Create()

cTableNam1	:= _oTempTable:GetRealName()
cNomeTab	:= cTableNam1

dbSelectArea("cArqTmp")

If !Empty(cPlanoRef) .Or. !Empty(cVersao)
	If !VldPlRef(aSetOfBook[1],cPlanoRef, cVersao)
		Return(cArqTmp)
	EndIf
Endif

If !Empty(cSegmento)
	If Len(aSetOfBook) == 0 .or. Empty(aSetOfBook[1])
		Help("CTN_CODIGO")
		Return(cArqTmp)
	Endif
	dbSelectArea("CTM")
	dbSetOrder(1)
	If MsSeek(xFilial()+cCodMasc)
		While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cCodMasc
			nPos += Val(CTM->CTM_DIGITO)
			If CTM->CTM_SEGMEN == strzero(val(cSegmento),2)
				nPos -= Val(CTM->CTM_DIGITO)
				nPos ++
				nDigitos := Val(CTM->CTM_DIGITO)
				Exit
			EndIf
			dbSkip()
		EndDo
	Else
		Help("CTM_CODIGO")
		Return(cArqTmp)
	EndIf
EndIf

If Empty(aSetOfBook[5])				/// S” H¡ QUERY SEM O PLANO GERENCIAL
	//// SE FOR DEFINI«√O TOP
	If Select("TRBTMP") > 0		/// E O ALIAS TRBTMP ESTIVER ABERTO (INDICANDO QUE A QUERY FOI EXECUTADA)
		dbSelectArea("TRBTMP")
		aStruTMP := dbStruct()			/// OBTEM A ESTRUTURA DO TMP

		dbSelectArea("TRBTMP")
		If ValType(oMeter) == "O"
			oMeter:SetTotal((cAlias)->(RecCount()))
			oMeter:Set(0)
		EndIf
		dbGoTop()						/// POSICIONA NO 1∫ REGISTRO DO TMP

		While TRBTMP->(!Eof())			/// REPLICA OS DADOS DA QUERY (TRBTMP) PARA P/ O TEMPORARIO EM DISCO
			nMeter++
			If nMeter%1000 = 0
				If ValType(oMeter) == "O"
					oMeter:Set(nMeter)
				EndIf
			EndIf

			If cAlias == "CT7"
				cCodigo	:= TRBTMP->CONTA
			ElseIf cAlias == "CT3"
				If cHeader == "CTT"
					cCodigo	:= TRBTMP->CONTA
				Endif
			ElseIf cAlias =="CTX"
				If cHeader == "CTH"
					cCodigo	:= TRBTMP->ITEM
				Endif
			EndIf

			If Empty(cPlanoRef) .Or. Empty(cVersao)	//Verifica o segmento somente se nao for com plano referencial.
				If !Empty(cSegmento)
					If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
						If  !(Substr(cCodigo,nPos,nDigitos) $ (cFiltSegm) )
							dbSkip()
							Loop
						EndIf
					Else
						If Substr(cCodigo,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
								Substr(cCodigo,nPos,nDigitos) > Alltrim(cSegFim)
							dbSkip()
							Loop
						EndIf
					Endif
				EndIf
			EndIf

			If &("TRBTMP->("+cFILUSU+")")
				RecLock("cArqTMP",.T.)
				For nTRB := 1 to Len(aStruTMP)
					If Subs(aStruTmp[nTRB][1],1,6) == "COLUNA" .And. nDivide > 1
						Field->&(aStruTMP[nTRB,1])	:=((TRBTMP->&(aStruTMP[nTRB,1])))/ndivide
					Else
						Field->&(aStruTMP[nTRB,1]) := TRBTMP->&(aStruTMP[nTRB,1])
					EndIf
				Next

				If Alltrim(Upper(FunName())) <> "CTBR210"
					cArqTMP->FILIAL	:= cFilAnt
				Endif

				cArqTMP->(MsUnlock())
			Endif
			dbSelectArea("TRBTMP")
			dbSkip()
		Enddo

		dbSelectArea("TRBTMP")
		dbCloseArea()					/// FECHA O TRBTMP (RETORNADO DA QUERY)
		lTemQry := .T.
	Endif
EndIf


dbSelectArea("cArqTmp")
dbSetOrder(1)

If !Empty(aSetOfBook[5])				// Se houve Indicacao de Plano Gerencial Anexado
	// Monta Arquivo Lendo Plano Gerencial
	// Neste caso a filtragem de entidades contabeis È desprezada!
	// Por enquanto a opcao de emitir o relatorio com Plano Gerencial ainda
	// nao esta disponivel para esse relatorio.
	If cAlias $ "CT7"					// Se for Entidade x Conta
		CtbPlGerCm(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,;
			cAlias,cIdent,lImpAntLP,dDataLP,lVlrZerado,lFiliais,aFiliais,lMeses,aMeses,lImpSint,cTpVlr,,,cSaldos,lValMed,lSalAcum)
		dbSetOrder(2)
	Else
		cMensagem	:= OemToAnsi(STR0002)// O plano gerencial ainda nao esta disponivel nesse relatorio.
		MsgInfo(cMensagem)
	EndIf
Else
	If cAlias $ 'CT7/CTU'		//So Imprime Entidade
		If lMeses
			//So ira gravar as contas sinteticas se mandar imprimir as contas sinteticas ou ambas.
			If lImpSint
				//Gravacao das contas superiores.
				SupCompCt7(oMeter,lMeses,aMeses,cMoeda,cTpVlr)
			Endif
		Else
			CtCmpSoEnt(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni,cEntidFim,cMoeda,;
			cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,lNImpMov,cAlias,cIdent,;
			lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,lImpAntLP,dDataLP,nDivide,;
			cTpVlr,lFiliais,aFiliais,lMeses,aMeses,cFilUsu)
		EndIf
	ElseIf cAlias == "CT3"

		If lMeses
			If lImpSint .Or. lImpTotS
				SupCompMes(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
					cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					lNImpMov,cAlias,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,;
					cFilDe,cFilAte,lImpAntLP,dDataLP,nDivide,cTpVlr,lFiliais,aFiliais,lMeses,aMeses,lVlrZerado)
			EndIf

		EndIf
	ElseIf cAlias $ "CTV/CTX"				//// SE FOR ENTIDADE x ITEM CONTABIL
		If lEntid	//Relatorio Comparativo de 1 Entidade por 6 Entidades
			If lImpSint  // SE DEVE IMPRIMIR AS SINTETICAS
				/// Usa cHeader x cAlias invertidas para compor as entidades sintÈticas (neste caso sintetica do CTD ao invÈs do CTT)
				SupCompEnt(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
					cEntidFim2,cAlias,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					lNImpMov,cHeader,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,;
					cFilDe,cFilAte,lImpAntLP,dDataLP,nDivide,cTpVlr,lFiliais,aFiliais,lMeses,aMeses,lVlrZerado,lEntid,aEntid)
			Endif
		Else
			If lImpSint  // SE DEVE IMPRIMIR AS SINTETICAS
				SupCompEnt(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
					cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					lNImpMov,cAlias,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,;
					cFilDe,cFilAte,lImpAntLP,dDataLP,nDivide,cTpVlr,lFiliais,aFiliais,lMeses,aMeses,lVlrZerado)
			Endif

		EndIf
	Endif

	//Se utiliza plano referencial
	If !Empty(cPlanoRef) .And. !Empty(cVersao)
		If IsBlind()
			mv_par01	:= ""
		Else
			Pergunte("CTBPLREF2",.T.)
			MakeSqlExpr("CTBPLREF2")
		EndIf
		cArqTmp	:= CtCompPlRf(cTableNam1,cPlanoRef,cVersao,"cArqTmp",cChave,aChave,aCampos,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
				cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,nPos,nDigitos,;
				lNImpMov,cAlias,lCusto,lItem,lClvl,lAtSldBase,lAtSldCmp,nInicio,nFinal,cFilDe,;
				cFilAte,lImpAntLP,dDataLP,nDivide,cTpVlr,lFiliais,aFiliais,lMeses,aMeses,lVlrZerado,lEntid,aEntid,lImpSint,@_oTempTbPLRef )
		mv_par01	:= cMvPar01Ant
	EndIF

EndIf

RestArea(aSaveArea)

Return cArqTmp
//-------------------------------------------------------------------
/*{Protheus.doc} CTBGerCmp
Comparativo entre 2 Tipos de Saldos

@author Alvaro Camillo Neto

 @param  oMeter	  Objeto oMeter
 @param  oText	  Objeto oText
 @param  oDlg		  Objeto oDlg
 @param  lEnd 	  lEnd
 @param  cArqTmp	  Data Inicial
 @param  dDataIni   Data Final
 @param  dDataFim   Alias do Arquivo
 @param  cArq1	  Arquivo Cadastro 1 (Principal)
 @param  cArq2      Arquivo Cadastro 2 (Auxiliar)
 @param  cContaIni  Conta Inicial
 @param  cContaFim  Conta Final
 @param  cCCIni	  Centro de Custo Inicial
 @param  cCCFim	  Centro de Custo Final
 @param  cItemIni   Item Inicial
 @param  cItemFim   Item Final
 @param  cClVlIni   Classe de Valor Inicial
 @param  cClvlFim   Classe de Valor Final
 @param  cMoeda	  Moeda
 @param  cTpSld1	  Tipo de Saldo 1
 @param  cTpSld2	  Tipo de Saldo 2
 @param  aSetOfBook  Set Of Book
 @param  cSegmento   Filtra por Segmento
 @param  cSegIni	  Segmento Inicial
 @param  cSegFim	  Segmento Final
 @param  cFiltSegm   Segmento Contido em
 @param  lVariacao0   Se Considera Variacao 0
 @param  nDivide 	  Fator de Divisao
 @param  bVariacao   Bloco de codigo para tratamentos especificos


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function CTBGerCmp(oMeter,oText,oDlg,lEnd,cArqtmp,;
					dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,;
					cMoeda,cTpSld1,cTpSld2,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					cSegAte,lVariacao0,nDivide,nGrupo,bVariacao,cIdent,lCt1Sint,cString,cFilUSU,lEntSint,aSelFil,lTodasFil)

Local aTamConta		:= TAMSX3("CT1_CONTA")
Local aTamCtaRes	:= TAMSX3("CT1_RES")
Local aTamCC        := TAMSX3("CTT_CUSTO")
Local aTamCCRes 	:= TAMSX3("CTT_RES")
Local aTamItem  	:= TAMSX3("CTD_ITEM")
Local aTamItRes 	:= TAMSX3("CTD_RES")
Local aTamClVl  	:= TAMSX3("CTH_CLVL")
Local aTamCvRes 	:= TAMSX3("CTH_RES")
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local aCtbMoeda		:= {}
Local aSaveArea 	:= GetArea()
Local aCampos

Local cChave
Local cArqTmp1		:= ""
Local cEntidIni		:= ""
Local cEntidFim		:= ""
Local cFilDe		:=  xFilial(cAlias)
Local cFilAte		:=  xFilial(cAlias)
Local cMensagem		:= ""
Local cCodigo		:= ""
Local nMeter		:= 0
Local nTamCta 		:= Len(CriaVar("CT1_DESC"+cMoeda))
Local nTamItem		:= Len(CriaVar("CTD_DESC"+cMoeda))
Local nTamCC  		:= Len(CriaVar("CTT_DESC"+cMoeda))
Local nTamClVl		:= Len(CriaVar("CTH_DESC"+cMoeda))
Local nTamGrupo		:= Len(CriaVar("CT1_GRUPO"))
Local nDecimais		:= 0
Local nInicio		:= Val(cMoeda)
Local nFinal		:= Val(cMoeda)
Local nTamFilial 	:= IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3( "CT2_FILIAL" )[1] )
Local lCusto		:= CtbMovSaldo("CTT")//Define se utiliza C.Custo
Local lItem 		:= CtbMovSaldo("CTD")//Define se utiliza Item
Local lClVl			:= CtbMovSaldo("CTH")//Define se utiliza Cl.Valor
Local lAtSldBase	:= Iif(GetMV("MV_ATUSAL")== "S",.T.,.F.)
Local lAtSldCmp		:= Iif(GetMV("MV_SLDCOMP")== "S",.T.,.F.)
Local lExistX2		:= .T.
Local aAreaX2		:= {}
Local lTemQry		:= .F.
Local nTRB			:= 1
Local nMin			:= 0
Local nMax			:= 0
Local nPos			:= 0
Local nDigitos		:= 0

Local cCodMasc		:= ""
Local cMvPar01Ant	:= mv_par01

Local aChave		:= {}
Local nTamCt		:= aTamConta[1]
Local cTableNam1 	:= ""

Private cPlanoRef	:= aSetOfBook[11]
Private cVersao		:= aSetOfBook[12]


lVariacao0	:= Iif(lVariacao0 == Nil,.F.,lVariacao0)

dMinData := CTOD("")

Default cIdent		:= ""
Default lCt1Sint 	:= .F.
Default cMoeda		:= "01"					//// SE NAO FOR INFORMADA A MOEDA ASSUME O PADRAO 01
DEFAULT lEntSint	:= .F.					//// SE IRA CALCULAR O SALDO DAS SINTETICAS PARA 2™ ENTIDADE (C.CUSTO). BOPS 91037
DEFAULT aSelFil     := {}
DEFAULT lTodasFil   := .F.
DEFAULT cArqTmp		:= ""
DEFAULT nDivide     := 1
nGrupo		:=	Iif(nGrupo == Nil,2,nGrupo)
// Retorna Decimais
aCtbMoeda := CTbMoeda(cMoeda)
nDecimais := aCtbMoeda[5]

//Se utiliza o plano referencial, desconsidera os filtros das entidades dos relatÛrios.
If !Empty(cPlanoRef) .And. !Empty(cVersao)
	//Se o relatÛrio n„o possuir conta, o plano referencial e a vers„o ser„o desconsiderados.
	//Ser· considerado cÛd. config. livros em branco.
	If cAlias $ "CTU/CTV/CTW/CTX/CVY" .Or. FunName() == "CTBR380"
		Help("  ",1,"CTBNOPLREF",,STR0048,1,0) //"Plano referencial n„o disponÌvel nesse relatÛrio. O relatÛrio ser· processado desconsiderando a configuraÁ„o de livros."
		cPlanoRef		:= ""
		cVersao			:= ""
		aSetOfBook		:= CTBSetOf("")
	Else
		cContaIni	:= Space(aTamConta[1])
		cContaFim	:= Replicate("Z",aTamConta[1])
		nTamCt	:= 70
	EndIf
Endif

aCampos := {{ "CONTA"		, "C", nTamCt, 0 },;  			// Codigo da Conta
{ "NORMAL"		, "C", 01			, 0 },;			// Situacao
{ "CTARES"		, "C", aTamCtaRes[1], 0 },;  			// Codigo Reduzido da Conta
{ "DESCCTA"	, "C", nTamCta		, 0 },;  			// Descricao da Conta
{ "SUPERIOR"	, "C", nTamCt, 0 },;  			// Codigo da Conta
{ "CUSTO"		, "C", aTamCC[1]	, 0 },; 	 		// Codigo do Centro de Custo
{ "CCRES"		, "C", aTamCCRes[1], 0 },;  			// Codigo Reduzido do Centro de Custo
{ "DESCCC" 	, "C", nTamCC		, 0 },;  			// Descricao do Centro de Custo
{ "ITEM"		, "C", aTamItem[1]	, 0 },; 	 		// Codigo do Item
{ "ITEMRES" 	, "C", aTamItRes[1], 0 },;  			// Codigo Reduzido do Item
{ "DESCITEM" 	, "C", nTamItem		, 0 },;  			// Descricao do Item
{ "CLVL"		, "C", aTamClVl[1]	, 0 },; 	 		// Codigo da Classe de Valor
{ "CLVLRES"	, "C", aTamCVRes[1], 0 },; 		 	// Cod. Red. Classe de Valor
{ "DESCCLVL"   , "C", nTamClVl		, 0 },;  			// Descricao da Classe de Valor
{ "MOVIMENTO1"	, "N", aTamVal[1]+2, nDecimais},; 	// Movimento Tipo de Saldo 01
{ "MOVIMENTO2"	, "N", aTamVal[1]+2	, nDecimais},; 	// Movimento Tipo de Saldo 02
{ "VARIACAO" 	, "N", aTamVal[1]+2, nDecimais},; 	// Variacao
{ "TIPOCONTA"	, "C", 01			, 0 },;			// Conta Analitica / Sintetica
{ "TIPOCC"  	, "C", 01			, 0 },;			// Centro de Custo Analitico / Sintetico
{ "TIPOITEM"	, "C", 01			, 0 },;			// Item Analitica / Sintetica
{ "TIPOCLVL"	, "C", 01			, 0 },;			// Classe de Valor Analitica / Sintetica
{ "CCSUP"		, "C", aTamCC[1]	, 0 },;			// Codigo do Centro de Custo Superior
{ "ITSUP"		, "C", aTamItem[1]	, 0 },;			// Codigo do Item Superior
{ "CLSUP"	    , "C", aTamClVl[1] , 0 },;			// Codigo da Classe de Valor Superior
{ "ORDEM"		, "C", 10			, 0 },;			// Ordem
{ "GRUPO"		, "C", nTamGrupo	, 0 },;			// Grupo Contabil
{ "TOTVIS"		, "C", 01			, 0 },;
	{ "SLDENT"		, "C", 01			, 0 },;
	{ "FATSLD"		, "C", 01			, 0 },;
	{ "VISENT"		, "C", 01			, 0 },;
	{ "IDENTIFI"	, "C", 01			, 0 },;
	{ "NIVEL1"		, "L", 01			, 0 },;				// Logico para identificar se
{ "FILIAL"		, "C", nTamFilial		, 0 }}				// eh de nivel 1 -> usado como


If bVariacao <> Nil
	Aadd(aCampos, { "COLUNA_1"	, "N", aTamVal[1]+2, nDecimais})
	Aadd(aCampos, { "COLUNA_2"	, "N", aTamVal[1]+2, nDecimais})
Endif


//// TRATAMENTO PARA ATUALIZA«√O DE SALDOS COMPOSTOS ANTES DE EXECUTAR A QUERY DE FILTRAGEM
Do Case
Case cAlias == 'CTU'
	//Verificar se tem algum saldo a ser atualizado por entidade
	If cIdent == "CTT"
		cOrigem := 	'CT3'
	ElseIf cIdent == "CTD"
		cOrigem := 	'CT4'
	ElseIf cIdent == "CTH"
		cOrigem := 	'CTI'
	Else
		cOrigem := 	'CTI'
	Endif
Case cAlias == 'CTV'
	cOrigem := "CT4"
	//Verificar se tem algum saldo a ser atualizado
Case cAlias == 'CTW'
	cOrigem		:= 'CTI'	/// HEADER POR CLASSE DE VALORES
	//Verificar se tem algum saldo a ser atualizado
Case cAlias == 'CTX'
	cOrigem		:= 'CTI'
EndCase


/// TRATAMENTO PARA OBTEN«√O DO SALDO DAS CONTAS ANALITICAS
Do Case
Case cAlias  == "CT7"
	cEntidIni	:= cContaIni
	cEntidFim	:= cContaFim
	cCodMasc	:= aSetOfBook[2]
	If nGrupo == 2
		cChave 	:= "CONTA"
		aChave	:= {"CONTA"}
	Else									// Indice por Grupo -> Totaliza por grupo
		cChave := "CONTA+GRUPO"
		aChave	:= {"CONTA","GRUPO"}
	Endif

	If FunName() <> "CTBR380" .And. Empty(aSetOfBook[5])
		Ct7CmpQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,;
			cMoeda,cTpSld1,cTpSld2,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
			cSegAte,lVariacao0,nDivide,nGrupo,bVariacao,cIdent,lCt1Sint,cString,cFILUSU)
		If Empty(cFilUSU)
			cFILUSU := ".T."
		Endif
	Endif

Case cAlias == 'CT3'
	cEntidIni	:= cCCIni
	cEntidFim	:= cCCFim
	cChave   := "CUSTO+CONTA"
	aChave		:= {"CUSTO","CONTA"}
	cCodMasc	:= aSetOfBook[2]
	/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
	CT3CmpQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,;
		cMoeda,cTpSld1,cTpSld2,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
		cSegAte,lVariacao0,nDivide,nGrupo,bVariacao,cIdent,lCt1Sint,cString,cFILUSU)
	If Empty(cFilUSU)
		cFILUSU := ".T."
	Endif

Case cAlias =='CT4'
	cEntidIni	:= cItemIni
	cEntidFim	:= cItemFim
	cChave  	:= "ITEM+CONTA"
	aChave		:= {"ITEM","CONTA"}
Case cAlias == 'CTI'
	cEntidIni	:= cClVlIni
	cEntidFim	:= cClvlFim
	cChave   	:= "CLVL+CONTA"
	aChave		:= {"CLVL","CONTA"}
Case cAlias == 'CTU'
	If cIdent == 'CTT'
		cEntidIni	:= cCCIni
		cEntidFim	:= cCCFim
		cChave		:= "CUSTO"
		aChave		:= {"CUSTO"}
	ElseIf cIdent == 'CTD'
		cEntidIni	:= cItemIni
		cEntidFim	:= cItemFim
		cChave   	:= "ITEM"
		aChave		:= {"ITEM"}
	ElseIf cIdent == 'CTH'
		cEntidIni	:= cClVlIni
		cEntidFim	:= cClvlFim
		cChave   	:= "CLVL"
		aChave		:= {"CLVL"}
	Endif

	CTUCmpQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,;
		cMoeda,cTpSld1,cTpSld2,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
		cSegAte,lVariacao0,nDivide,nGrupo,bVariacao,cIdent,lCt1Sint,cString,cFILUSU)
	If Empty(cFilUSU)
		cFILUSU := ".T."
	Endif

Case cAlias == 'CTV'
	If cHeader == 'CTT'
		cChave   	:= "CUSTO+ITEM"
		aChave		:= {"CUSTO","CONTA"}
		cEntidIni1	:= cCCIni
		cEntidFim1	:= cCCFim
		cEntidIni2	:= cItemIni
		cEntidFim2	:= cItemFim
	ElseIf cHeader == 'CTD'
		cChave   	:= "ITEM+CUSTO"
		aChave		:= {"ITEM","CUSTO"}
		cEntidIni1	:= cItemIni
		cEntidFim1	:= cItemFim
		cEntidIni2	:= cCCIni
		cEntidFim2	:= cCCFim
	EndIf
Case cAlias == 'CTW'
	If cHeader	== 'CTT'
		cChave   := "CUSTO+CLVL"
		aChave		:= {"CUSTO","CLVL"}
		cEntidIni1	:=	cCCIni
		cEntidFim1	:=	cCCFim
		cEntidIni2	:=	cClVlIni
		cEntidFim2	:=	cClVlFim
	ElseIf cHeader == 'CTH'
		cChave   	:= "CLVL+CUSTO"
		aChave		:= {"CLVL","CUSTO"}
		cEntidIni1	:=	cClVlIni
		cEntidFim1	:=	cClVlFim
		cEntidIni2	:=	cCCIni
		cEntidFim2	:=	cCCFim
	EndIf
Case cAlias == 'CTX'
	If cHeader == 'CTD'
		cChave  	 := "ITEM+CLVL"
		aChave		:= {"ITEM","CLVL"}
		cEntidIni1	:= 	cItemIni
		cEntidFim1	:= 	cItemFim
		cEntidIni2	:= 	cClVlIni
		cEntidFim2	:= 	cClVlFim
	ElseIf cHeader == 'CTH'
		cChave  	 := "CLVL+ITEM"
		aChave		:= {"CLVL","ITEM"}
		cEntidIni1	:= 	cClVlIni
		cEntidFim1	:= 	cClVlFim
		cEntidIni2	:= 	cItemIni
		cEntidFim2	:= 	cItemFim
	EndIf
EndCase

If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
	cChave		:= "CONTA"
	aChave		:= {"CONTA"}
Endif

If ( Select ( "cArqTmp" ) <> 0 )
	dbSelectArea ( "cArqTmp" )
	dbCloseArea ()
Endif

//-------------------
//CriaÁ„o do objeto
//-------------------
_oTempTable := FWTemporaryTable():New("cArqTmp")
_oTempTable:SetFields( aCampos )
lCriaInd := .T.
_oTempTable:AddIndex("1", aChave)
If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
	_oTempTable:AddIndex("2", {"ORDEM"})
Endif

//------------------
//CriaÁ„o da tabela
//------------------
_oTempTable:Create()

cTableNam1 := _oTempTable:GetRealName()

dbSelectArea("cArqTmp")

If !Empty(cPlanoRef) .Or. !Empty(cVersao)
	If !VldPlRef(aSetOfBook[1],cPlanoRef, cVersao)
		Return(cArqTmp)
	EndIf
Endif

If !Empty(cSegmento)
	If Len(aSetOfBook) == 0 .or. Empty(aSetOfBook[1])
		Help("CTN_CODIGO")
		Return(cArqTmp)
	Endif
	dbSelectArea("CTM")
	dbSetOrder(1)
	If MsSeek(xFilial()+cCodMasc)
		While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cCodMasc
			nPos += Val(CTM->CTM_DIGITO)
			If CTM->CTM_SEGMEN == strzero(val(cSegmento),2)
				nPos -= Val(CTM->CTM_DIGITO)
				nPos ++
				nDigitos := Val(CTM->CTM_DIGITO)
				Exit
			EndIf
			dbSkip()
		EndDo
	Else
		Help("CTM_CODIGO")
		Return(cArqTmp)
	EndIf
EndIf

If FunName() <> "CTBR380"				/// E N√O FOR O RELAT”RIO CTBR380 (VARIACAO MONETARIA)
	If Select("TRBTMP") > 0
		dbSelectArea("TRBTMP")
		aStruTMP := dbStruct()

		dbSelectArea("TRBTMP")
		If ValType(oMeter) == "O"
			oMeter:SetTotal((cAlias)->(RecCount()))
			oMeter:Set(0)
		EndIF
		dbGoTop()

		While TRBTMP->(!Eof())

			If cAlias == "CT7"
				cCodigo	:= TRBTMP->CONTA
			ElseIf cAlias == "CT3"
				cCodigo	:= TRBTMP->CONTA
			Endif

			If Empty(cPlanoRef) .Or. Empty(cVersao)	//Verifica o segmento somente se nao for com plano referencial.
				If !Empty(cSegmento)
					If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
						If  !(Substr(cCodigo,nPos,nDigitos) $ (cFiltSegm) )
							TRBTMP->(dbSkip())
							Loop
						EndIf
					Else
						If Substr(cCodigo,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
								Substr(cCodigo,nPos,nDigitos) > Alltrim(cSegFim)
							TRBTMP->(dbSkip())
							Loop
						EndIf
					Endif
				EndIf
			EndIf


			If &("TRBTMP->("+cFILUSU+")")
				RecLock("cArqTMP",.T.)
				For nTRB := 1 to Len(aStruTMP)
					If Subs(aStruTmp[nTRB][1],1,9) == "MOVIMENTO" .And. nDivide > 1
						Field->&(aStruTMP[nTRB,1])	:=((TRBTMP->&(aStruTMP[nTRB,1])))/ndivide
					Else
						Field->&(aStruTMP[nTRB,1]) := TRBTMP->&(aStruTMP[nTRB,1])
					EndIf
				Next

				If Alltrim(Upper(FunName())) <> "CTBR210"
				 	cArqTMP->FILIAL	:= cFilAnt
				ENDIF

				cArqTMP->(MsUnlock())
			Endif
			nMeter++
			If nMeter%1000 = 0
				If ValType(oMeter) == "O"
					oMeter:Set(nMeter)
				EndIF
			EndIf
			TRBTMP->(dbSkip())
		Enddo

		dbSelectArea("TRBTMP")
		dbCloseArea()
		lTemQry := .T.
	Endif
Endif

dbSelectArea("cArqTmp")
dbSetOrder(1)

If !Empty(aSetOfBook[5]) // Indica qual o Plano Gerencial Anexado
	// Monta Arquivo Lendo Plano Gerencial
	// Neste caso a filtragem de entidades contabeis È desprezada!
	//CtbPlGeren(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,cAlias)
	If cAlias == 'CT7'
		CtPlGerSld(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,cAlias,,,,cTpSld1,cTpSld2,,,1,nDivide)
		dbSetOrder(2)
	Else
		cMensagem	:= OemToAnsi(STR0002)// O plano gerencial ainda nao esta disponivel nesse relatorio.
		If !IsBlind()
			MsgAlert(cMensagem)
		EndIf
	EndIf
Else
	Do Case
	Case cAlias $ 'CT3'	//Comparativo de 2 Tipos de Saldos (Entidade/Conta)

		If lTemQry //// J¡ PASSOU PELA QUERY ENT√O S” GERA O SALDO DAS CONTAS SUPERIORES
			If lEntSint .or. lCt1Sint
				CtEntCtSup(oMeter,oText,oDlg,cAlias,.F.,cMoeda,2,,,lEntSint)
			Endif
		Else
			CTSldCtEnt(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cContaIni,cContaFim,cEntidIni,cEntidFim,cMoeda,cTpSld1,cTpSld2,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,cAlias,lCusto,lItem,lClVl,lAtSldBase,nInicio,nFinal,cFilDe,cFilate,nDivide,lVariacao0)
		Endif

	Case cAlias $ 'CT7/CTU'	//Comparativo de 2 Tipos de Saldos(Somente 1 Entidade)

		If  lTemQry .and. FunName() <> "CTBR380" //// ATUALIZA O SALDO DAS CONTAS SUPERIORES
			If lCt1Sint
				SupCmpEnt(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni,cEntidFim,cMoeda,cTpSld1,cTpSld2,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,cAlias,lCusto,lItem,lClVl,lAtSldBase,nInicio,nFinal,cFilDe,cFilate,nDivide,lVariacao0,nGrupo,bVariacao,cIdent,lCt1Sint,aSelFil,lTodasFil)
			Endif
		Else
			CtSldSoEnt(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni,cEntidFim,cMoeda,cTpSld1,cTpSld2,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,cAlias,lCusto,lItem,lClVl,lAtSldBase,nInicio,nFinal,cFilDe,cFilate,nDivide,lVariacao0,nGrupo,bVariacao,cIdent,aSelFil,lTodasFil)
		Endif
	EndCase

	//Se utiliza plano referencial
	If !Empty(cPlanoRef) .And. !Empty(cVersao)
		If IsBlind()
			mv_par01	:= ""
		Else
			Pergunte("CTBPLREF2",.T.)
			MakeSqlExpr("CTBPLREF2")
		Endif
		cArqTmp	:= CtCmpPlRef(cTableNam1,cAlias,cArqTmp,"cArqTmp",cChave,aChave,aCampos,cPlanoRef,cVersao,lCt1Sint,lVariacao0,bVariacao,cMoeda,lEntSint,@_oTempTbPLRef,;
		cSegmento,cSegIni,cSegFim,cFiltSegM,nPos,nDigitos )
		mv_par01	:= cMvPar01Ant
	EndIF
EndIf


RestArea(aSaveArea)
Return cArqTmp

//-------------------------------------------------------------------
/*{Protheus.doc} Ct2EntFil
Gerar Arq. Temp. p/ Balancete c/ 2 Entidades filt. pela 3a.

@author Alvaro Camillo Neto

@param oMeter	   Controle da regua
@param oText 	   Controle da regua
@param oDlg  	   Janela
@param lEnd  	   Controle da regua -> finalizar
@param dDataIni    Data Inicial de processamento
@param dDataFinal  Data Final de processamento
@param cEntidIni   Codigo Entidade Inicial
@param cEndtidFim  Codigo Entidade Final
@param cMoeda      Moeda
@param cSaldos     Tipos de Saldo a serem processados
@param aSetOfBook  Matriz de configuracao de livros
@param cSegmento   Indica qual o segmento ser· filtrado
@param cSegIni     Conteudo inicial do segmento
@param cSegFim     Conteudo Final do segmento
@param cFiltSegm   Indica se filtrara ou nao segmento
@param lNImpMov    Indica se imprime ou nao a coluna movimento
@param cAlias      Alias para regua
@param cIdent      Identificador do arquivo a ser processado
@param lCusto      Considera Centro de Custo?
@param lItem       Considera Item Contabil?
@param lCLVL       Considera Classe de Valor?
@param lAtSldBase  Indica se deve chamar rot atual. saldo basico
@param lAtSldCmp   Indica se deve chamar rot atua. saldo composto
@param nInicio     Moeda Inicial (p/ atualizar saldo)
@param nFinal      Moeda Final (p/ atualizar saldo)
@param cFilde      Filial inicial (p/ atualizar saldo)
@param cFilAte     Filial final (p/atualizar saldo)
@param lImpAntLP   Imprime lancamentos Lucros e Perdas?
@param dDataLP     Data ultimo Lucros e Perdas
@param nDivide     Divide valores (100,1000,1000000)
@param lVlrZerado  Grava ou nao valores zerados no arq temporario

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function Ct2EntFil(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
				cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
				lNImpMov,cAlias,lCusto,lItem,lClvl,lAtSldBase,lAtSldCmp,nInicio,nFinal,cFilDe,;
				cFilAte,lImpAntLP,dDataLP,nDivide,lVlrZerado,cFiltroEnt,cCodFilEnt,aSelFil,lTodasFil)

Local aSaveArea 	:= GetArea()

Local nPos			:= 0
Local nDigitos	:= 0
local nSaldoAnt 	:= 0
Local nSaldoDeb 	:= 0
Local nSaldoCrd 	:= 0
Local nSaldoAtu 	:= 0
Local nSaldoAntD	:= 0
Local nSaldoAntC	:= 0
Local nSaldoAtuD	:= 0
Local nSaldoAtuC	:= 0
Local nSldAnt		:= 0
Local nSldAtu		:= 0
Local nRegTmp   	:= 0
Local nMovimento	:= 0
Local nOrder		:= 0
Local nRecno1		:= 0
Local nRecno2		:= 0
Local nTamDesc1		:= ""
Local nTamDesc2		:= ""
Local nIndex		:= 0
Local nMeter		:= 0
Local nCont			:= 0
Local nTotal		:= 0

Local cEntid1		:= ""	//Codigo da Entidade Principal
Local cEntid2   	:= "" 	//Codigo da Entidade do Corpo do Relatorio
Local cCadAlias1	:= ""	//Alias do Cadastro da Entidade Principal
Local cCadAlias2	:= ""	//Alias do Cadastro da Entidade que sera impressa no corpo.
Local cCodEnt1		:= ""	//Codigo da Entidade Principal
Local cCodEnt2		:= ""	//Codigo da Entidade que sera impressa no corpo do relat.
Local cDesc1		:= ""
Local cDesc2		:= ""
Local cDescEnt1		:= ""	//Descricao da Entidade Principal
Local cDescEnt2		:= ""	//Descricao da Entidade que sera impressa no corpo.
Local cCodSup1		:= ""	//Cod.Superior da Entidade Principal
Local cCodSup2		:= ""	//Cod.Superior da Entidade que sera impressa no corpo.
Local cMensagem		:= OemToAnsi(STR0016)+ OemToAnsi(STR0017)
Local cEntRes1		:= ""
Local cEntRes2		:= ""
Local cClasse1		:= ""
Local cClasse2		:= ""
Local cEntSup1		:= ""
Local cEntSup2		:= ""

Local bCond1		:= {||.F.}
Local bCond2		:= {||.F.}

Local dMinData

DEFAULT aSelFil     := {}
DEFAULT lTodasFil   := .F.

lVlrZerado	:= Iif(lVlrZerado == Nil,.T.,lVlrZerado)
nDivide 	:= Iif(nDivide == Nil,1,nDivide)

Do Case
Case cHeader == 'CTT' .And. cFiltroEnt	== 'CTD'
	cCadAlias1	:= 'CTT'
	cCadAlias2	:= 'CTH'
	cCodEnt1	:= 'CUSTO'
	cCodEnt2	:=	'CLVL'
	cCodSup1	:= 'CCSUP'
	cCodSup2	:= 'CLSUP'
	nTamDesc1	:=	Len(CriaVar("CTT->CTT_DESC"+cMoeda))
	nTamDesc2	:=	Len(CriaVar("CTH->CTH_DESC"+cMoeda))
	cDescEnt1	:= "DESCENT1"
	cDescEnt2	:= "DESCENT2"
Case cHeader == 'CTT' .And. cFiltroEnt	== 'CTH'
	cCadAlias1	:= 'CTT'
	cCadAlias2	:= 'CTD'
	cCodEnt1	:= 'CUSTO'
	cCodEnt2	:=	'ITEM'
	cCodSup1	:= 'CCSUP'
	cCodSup2	:= 'ITSUP'
	nTamDesc1	:=	Len(CriaVar("CTT->CTT_DESC"+cMoeda))
	nTamDesc2	:=	Len(CriaVar("CTD->CTD_DESC"+cMoeda))
	cDescEnt1	:= "DESCENT1"
	cDescEnt2	:= "DESCENT2"
Case cHeader == 'CTD' .And. cFiltroEnt == 'CTT'
	cCadAlias1	:= 'CTD'
	cCadAlias2	:= 'CTH'
	cCodEnt1	:= 'ITEM'
	cCodEnt2	:=	'CLVL'
	cCodSup1	:= 'ITSUP'
	cCodSup2	:= 'CLSUP'
	nTamDesc1	:=	Len(CriaVar("CTT->CTT_DESC"+cMoeda))
	nTamDesc2	:=	Len(CriaVar("CTH->CTH_DESC"+cMoeda))
	cDescEnt1	:= "DESCENT1"
	cDescEnt2	:= "DESCENT2"
Case cHeader == 'CTD' .And. cFiltroEnt == 'CTH'
	cCadAlias1	:= 'CTD'
	cCadAlias2	:= 'CTT'
	cCodEnt1	:= 'ITEM'
	cCodEnt2	:=	'CUSTO'
	cCodSup1	:= 'ITSUP'
	cCodSup2	:= 'CCSUP'
	nTamDesc1	:=	Len(CriaVar("CTD->CTD_DESC"+cMoeda))
	nTamDesc2	:=	Len(CriaVar("CTT->CTT_DESC"+cMoeda))
	cDescEnt1	:= "DESCENT1"
	cDescEnt2	:= "DESCENT2"
Case cHeader == 'CTH' .And. cFiltroEnt == 'CTT'
	cCadAlias1	:= 'CTH'
	cCadAlias2	:= 'CTD'
	cCodEnt1	:= 'CLVL'
	cCodEnt2	:=	'ITEM'
	cCodSup1	:= 'CLSUP'
	cCodSup2	:= 'ITSUP'
	nTamDesc1	:=	Len(CriaVar("CTH->CTH_DESC"+cMoeda))
	nTamDesc2	:=	Len(CriaVar("CTD->CTD_DESC"+cMoeda))
	cDescEnt1	:= "DESCENT1"
	cDescEnt2	:= "DESCENT2"
Case cHeader == 'CTH' .And. cFiltroEnt == 'CTD'
	cCadAlias1	:= 'CTH'
	cCadAlias2	:= 'CTT'
	cCodEnt1	:= 'CLVL'
	cCodEnt2	:=	'CUSTO'
	cCodSup1	:= 'CLSUP'
	cCodSup2	:= 'CCSUP'
	nTamDesc1	:=	Len(CriaVar("CTH->CTH_DESC"+cMoeda))
	nTamDesc2	:=	Len(CriaVar("CTT->CTT_DESC"+cMoeda))
	cDescEnt1	:= "DESCENT1"
	cDescEnt2	:= "DESCENT2"
EndCase

bCond1		:= {||&(cCadAlias1+"->"+cCadAlias1+"_FILIAL") == xFilial(cCadAlias1) .And. &(cCadAlias1+"->"+cCadAlias1+"_"+cCodEnt1) >= cEntidIni1 .And. &(cCadAlias1+"->"+cCadAlias1+"_"+cCodEnt1) <= cEntidFim1 }
bCond2		:= {||&(cCadAlias2+"->"+cCadAlias2+"_FILIAL") == xFilial(cCadAlias2) .And. &(cCadAlias2+"->"+cCadAlias2+"_"+cCodEnt2) >= cEntidIni2 .And. &(cCadAlias2+"->"+cCadAlias2+"_"+cCodEnt2) <= cEntidFim2 }


// Verifica Filtragem por Segmento da Entidade
If !Empty(cSegmento)
	dbSelectArea("CTM")
	dbSetOrder(1)
	If MsSeek(xFilial()+cMascara2)
		While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cMascara2
			nPos += Val(CTM->CTM_DIGITO)
			If CTM->CTM_SEGMEN == cSegmento
				nPos -= Val(CTM->CTM_DIGITO)
				nPos ++
				nDigitos := Val(CTM->CTM_DIGITO)
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf
EndIf

dbSelectarea(cCadAlias1)
If ValType(oMeter) == "O"
	oMeter:SetTotal((cCadAlias1)->(RecCount()))
	oMeter:Set(0)
EndIf
dbSetOrder(1)
MsSeek(xFilial()+cEntidIni1,.T.)
While !Eof() .And. Eval(bCond1)
	nMeter++
	If nMeter%1000 > 0
		If ValType(oMeter) == "O"
	   		oMeter:Set(nMeter)
		EndIF
	EndIf
	If &(cCadAlias1+"->"+cCadAlias1+"_CLASSE") <> '2'	//Se for sintetico
		dbSkip()
		Loop
	Endif

	//Verifico Set of Book da Entidade Principal
	If !Empty(aSetOfBook[1])
		If !(aSetOfBook[1] $ &(cCadAlias1+"->"+cCadAlias1+"_BOOK"))
			dbSkip()
			Loop
		EndIf
    EndIf
	cEntSup1	:= &(cCadAlias1+"->"+cCadAlias1+"_"+cCodSup1)
    cDescEnt1	:= (cCadAlias1+"->"+cCadAlias1+"_DESC")
	cDesc1 		:= &(cDescEnt1+cMoeda)
	cEntRes1	:= &(cCadAlias1+"->"+cCadAlias1+"_RES")
	cClasse1	:= (cCadAlias1+"->"+cCadAlias1+"_CLASSE")

	If Empty(cDesc1)	// Caso nao preencher descricao da moeda selecionada
		cDesc1 	:= &(cDescEnt1+"01")
	Endif

	cEntid1		:= &(cCadAlias1+"->"+cCadAlias1+"_"+cCodent1)
	nRecno1		:= Recno()

    dbSelectArea(cCadAlias2)
    dbSetOrder(1)
    MsSeek(xFilial()+cEntidIni2,.T.)

	While !Eof() .And. Eval(bCond2)

		If &(cCadAlias2+"->"+cCadAlias2+"_CLASSE") <> '2'	//Se for sintetico
			dbSkip()
			Loop
		Endif

		//Verifico Set of Book da Entidade do Corpo do Relatorio
		If !Empty(aSetOfBook[1])
			If !(aSetOfBook[1] $ &(cCadAlias2+"->"+cCadAlias2+"_BOOK"))
				dbSkip()
				Loop
			EndIf
		EndIf


		//Caso faca filtragem por segmento de item,verifico se esta dentro
		//da solicitacao feita pelo usuario.
		If !Empty(cSegmento)
			If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
				If  !(Substr(&(cCadAlias2+"->"+cCadAlias2+"_"+cCodEnt2),nPos,nDigitos) $ (cFiltSegm) )
					dbSkip()
					Loop
				EndIf
			Else
				If Substr(&(cCadAlias2+"->"+cCadAlias2+"_"+cCodEnt2),nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
					Substr(&(cCadAlias2+"->"+cCadAlias2+"_"+cCodEnt2),nPos,nDigitos) > Alltrim(cSegFim)
					dbSkip()
					Loop
				EndIf
			Endif
		EndIf

		cEntid2		:= &(cCadAlias2+"->"+cCadAlias2+"_"+cCodent2)
		cDescEnt2	:= (cCadAlias2+"->"+cCadAlias2+"_DESC")
		cEntRes2	:= &(cCadAlias2+"->"+cCadAlias2+"_RES")
		cClasse2	:= &(cCadAlias2+"->"+cCadAlias2+"_CLASSE")
		cEntSup2	:= &(cCadAlias2+"->"+cCadAlias2+"_"+cCodSup2)
		cDesc2 		:= &(cDescEnt2+cMoeda)
		If Empty(cDesc2)	// Caso nao preencher descricao da moeda selecionada
			cDesc2 	:= &(cDescEnt2+"01")
		Endif

		nRecno2		:= Recno()

		// Calculo dos saldos
		aSaldoAnt 	:= SldCmpEnt(cEntid1,cEntid2,dDataIni,cMoeda,cSaldos,nOrder,cHeader,cAlias,cFiltroEnt,cCodFilEnt,lImpAntLP,dDataLP)
		aSaldoAtu 	:= SldCmpEnt(cEntid1,cEntid2,dDataFim,cMoeda,cSaldos,nOrder,cHeader,cAlias,cFiltroEnt,cCodFilEnt,lImpAntLP,dDataLP)

		nSaldoAntD 	:= aSaldoAnt[7]
		nSaldoAntC 	:= aSaldoAnt[8]
		nSldAnt		:= nSaldoAntC - nSaldoAntD

		nSaldoAtuD 	:= aSaldoAtu[4]
		nSaldoAtuC 	:= aSaldoAtu[5]
		nSldAtu		:= nSaldoAtuC - nSaldoAtuD

		nSaldoDeb  	:= nSaldoAtuD - nSaldoAntD
		nSaldoCrd  	:= nSaldoAtuC - nSaldoAntC
	    If nDivide > 1
			nSaldoDeb	:= Round(NoRound((nSaldoDeb/nDivide),3),2)
			nSaldoCrd	:= Round(NoRound((nSaldoCrd/nDivide),3),2)
		EndIf

		nMovimento	:= nSaldoCrd-nSaldoDeb

		If !lVlrZerado .And. (nMovimento = 0 .And. nSldAnt = 0 .And. nSldAtu = 0)  .And. ;
			(nSaldoDeb = 0 .And. nSaldoCrd = 0)
			dbSelectArea(cCadAlias2)
			dbSkip()
			Loop
		EndIf


		If lVlrZerado .And.  (nMovimento = 0 .And. nSldAnt = 0 .And. nSldAtu = 0)  .And. ;
			(nSaldoDeb = 0 .And. nSaldoCrd = 0)

			If CtbExDtFim(cCadAlias1)
				If !Empty(&((cCadAlias1)+"->"+(cCadAlias1)+"_DTEXSF")) .And. (dtos(dDataIni) > DTOS(&((cCadAlias1)+"->"+(cCadAlias1)+"_DTEXSF")))
					dbSelectArea(cCadAlias1)
					dbSkip()
					Loop
				EndIf
			EndIf


			If CtbExDtFim(cCadAlias2)
				If !Empty(&((cCadAlias2)+"->"+(cCadAlias2)+"_DTEXSF")) .And. (dtos(dDataIni) > DTOS(&((cCadAlias2)+"->"+(cCadAlias2)+"_DTEXSF")))
					dbSelectArea(cCadAlias2)
					dbSkip()
					Loop
				EndIf
			EndIf
		EndIf

		cSeek	:= cEntid1+cEntid2

		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		If !MsSeek(cSeek)
			dbAppend()
			Replace ENTID1   	With cEntid1
			Replace DESCENT1	With cDesc1
			Replace TIPOENT1	With cClasse1
			Replace ENTSUP1		With cEntSup1
			Replace ENTRES1		With cEntRes1
			Replace ENTID2		With cEntid2
			Replace DESCENT2	With cDesc2
			Replace TIPOENT2 	With cClasse2
			Replace ENTSUP2		With cEntsup2
			Replace ENTRES2		With cEntRes2
		EndIf

	    If nDivide > 1
			For nCont := 1 To Len(aSaldoAnt)
				aSaldoAnt[nCont] := Round(NoRound((aSaldoAnt[nCont]/nDivide),3),2)
			Next nCont

			For nCont := 1 To Len(aSaldoAtu)
				aSaldoAtu[nCont] := Round(NoRound((aSaldoAtu[nCont]/nDivide),3),2)
			Next nCont
		EndIf

		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		Replace SALDOANT 	With aSaldoAnt[6]		// Saldo anterior
		Replace SALDOANTDB	With aSaldoAnt[7]		// Saldo anterior debito
		Replace SALDOANTCR	With aSaldoAnt[8]		// Saldo anterior credito
		Replace SALDOATU 	With aSaldoAtu[1]		// Saldo Atual
		Replace SALDOATUDB	With aSaldoatu[4]		// Saldo Atual debito
		Replace SALDOATUCR	With aSaldoAtu[5]		// saldo atual credito

		Replace  SALDODEB	With nSaldoDeb				// Saldo Debito
		Replace  SALDOCRD	With nSaldoCrd				// Saldo Credito

		If !lNImpMov
			Replace MOVIMENTO With SALDOCRD-SALDODEB
		Endif

		dbSelectArea(cCadAlias2)
		dbGoto(nRecno2)
		dbSkip()
	Enddo
	dbSelectArea(cCadAlias1)
	dbGoto(nRecno1)
	dbSkip()
EndDo

// Grava sinteticas
dbSelectArea("cArqTmp")
If ValType(oMeter) == "O"
	oMeter:SetTotal(cArqTmp->(RecCount()))
	oMeter:Set(0)
EndIf
dbGoTop()

While!Eof()
	nMeter++
	If nMeter%1000 = 0
		If ValType(oMeter) == "O"
	   		oMeter:Set(nMeter)
	  	EndIf
	EndIf
	nSaldoAnt	:= SALDOANT
	nSaldoAtu	:= SALDOATU
	nSaldoDeb	:= SALDODEB
	nSaldoCrd	:= SALDOCRD
	nMovimento	:= MOVIMENTO
	nSaldoAntD	:= SALDOANTDB
	nSaldoAntC	:= SALDOANTCR
	nSaldoAtuD	:= SALDOATUDB
	nsaldoAtuC	:= SALDOATUCR

	nRegTmp := Recno()

	dbSelectArea(cCadAlias2)
	dbSetOrder(1)
	If Empty(&(cCadAlias2+"->"+cCadAlias2+"_"+cCodSup2))
		dbSelectArea("cArqTmp")
		Replace NIVEL1 With .T.
		dbSelectArea(cCadAlias2)
	EndIf
	MsSeek(xFilial(cCadAlias2)+ cArqTmp->ENTSUP2)

	While !Eof() .And. &(cCadAlias2+"->"+cCadAlias2+"_FILIAL") == xFilial()

		cEntid1	 	:= cArqTmp->ENTID1
		cDesc1	 	:= cArqTmp->DESCENT1
		cTipoEnt1   := cArqtmp->TIPOENT1
		cEntSup1	:= cArqtmp->ENTSUP1
		cEntRes1	:= cArqTmp->ENTRES1
		cEntSup2 	:= &(cCadAlias2+"->"+cCadAlias2+"_"+cCodEnt2)
		cTipoEnt2	:= &(cCadAlias2+"->"+cCadAlias2+"_CLASSE")
		cDescEnt2	:= (cCadAlias2+"->"+cCadAlias2+"_DESC")
		cDesc2		:= &(cDescEnt2+cMoeda)
		cEntRes2	:= &(cCadAlias2+"->"+cCadAlias2+"_RES")
		If Empty(cDesc2)	// Caso nao preencher descricao da moeda selecionada
			cDesc2	:= &(cDescEnt2+"01")
		Endif

		cSeek 		:= cEntid1+cEntSup2


		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		If !MsSeek(cSeek)
			dbAppend()
			Replace ENTID1  	With cEntid1
			Replace DESCENT1	With cDesc1
			Replace TIPOENT1	With cTipoEnt1
			Replace ENTSUP1 	With cEntSup1
			Replace ENTRES1		With cEntRes1
			Replace ENTID2 		With cEntSup2
			Replace DESCENT2	With cDesc2
			Replace TIPOENT2 	With cTipoEnt2
			Replace ENTSUP2		With cEntSup2
			Replace ENTRES2		With cEntRes2
		EndIf

		Replace	 SALDOANT 	With SALDOANT + nSaldoAnt
		Replace  SALDOANTDB With SALDOANTDB + nSaldoAntD
		Replace  SALDOANTCR	With SALDOANTCR + nSaldoAntC
		Replace  SALDOATU 	With SALDOATU + nSaldoAtu
		Replace  SALDOATUDB	With SALDOATUDB	+ nSaldoAtuD
		Replace  SALDOATUCR	With SALDOATUCR + nsaldoAtuC
		Replace  SALDODEB	With SALDODEB + nSaldoDeb
		Replace  SALDOCRD 	With SALDOCRD + nSaldoCrd
		If !lNImpMov
			Replace MOVIMENTO With MOVIMENTO + nMovimento
		Endif

		dbSelectArea(cCadAlias2)
		If Empty(&(cCadAlias2+"->"+cCadAlias2+"_"+cCodSup2))
			dbSelectArea("cArqTmp")
			Replace NIVEL1 With .T.
			dbSelectArea(cCadAlias2)
			Exit
		EndIf

		dbSelectArea(cCadAlias2)
		MsSeek(&(cCadAlias2+"->"+cCadAlias2+"_"+cCodSup2))
	EndDo
	dbSelectArea("cArqTmp")
	dbGoto(nRegTmp)
	dbSkip()
EndDo
RestArea(aSaveArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥CtbPlGerCm ≥Autor  ≥ Simone Mie Sato       ≥ Data ≥ 06.11.02 		     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Plano Gerencial para Comparativos                           			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥CTBPlGerCm(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook) ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Nenhum                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                  			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ oMeter	= Objeto oMeter                     	               		 ≥±±
±±≥          ≥ oText 	= Objeto oText                      	                	 ≥±±
±±≥          ≥ oDlg  	= Objeto oDlg                       	                	 ≥±±
±±≥          ≥ lEnd 	 = Acao do CodeBlock                 	                	 ≥±±
±±≥          ≥ dDataIni  = Data Inicial                      	                	 ≥±±
±±≥          ≥ dDataFim = Data Final                     	                 		 ≥±±
±±≥          ≥ cMoeda	= Moeda                              	              		 ≥±±
±±≥          ≥ aSetOfBook	= Array aSetOfBook             	                 		 ≥±±
±±≥          ≥ cAlias    	= Alias a ser utilizado        	                 		 ≥±±
±±≥          ≥ cIdent    	= Identficador                 	                 		 ≥±±
±±≥          ≥ lImpAntLP	= Define se ira considerar apuracao de lucros/perdas	 ≥±±
±±≥          ≥ dDataLP  	= Data de apuracao de lucros/perdas a ser considerado 	 ≥±±
±±≥          ≥ lVlrZerado	= Define se ira imprimir os valores zerados.           	 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CtbPlGerCm(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,;
					cAlias,cIdent,lImpAntLP,dDataLP,lVlrZerado,lFiliais,aFiliais,;
					lMeses,aMeses,lImpSint,cTpVlr,lPainel,aResult,cSldPainel,lValMed,lSalAcum)

Local aSaveArea := GetArea()
Local aSaldoAnt
Local aSaldoAtu
Local nMeter	:= 0

Local cConta
Local cCodNor
Local cNormal
Local cContaSup
Local cDesc
Local cPlanGer := aSetOfBook[5]
Local cContaZZZ	:= Repl("Z",Len(Criavar("CT1_CONTA")))
Local cCustoZZZ := Repl("Z",Len(Criavar("CTT_CUSTO")))
Local cItemZZZ	:= Repl("Z",Len(Criavar("CTD_ITEM")))
Local cClVlZZZ	:= Repl("Z",Len(Criavar("CTH_CLVL")))
Local cContaIni	:= Space(Len(Criavar("CT1_CONTA")))
Local cContaFim	:= cContaZZZ
Local cCustoIni	:= Space(Len(Criavar("CTT_CUSTO")))
Local cCustoFim	:= cCustoZZZ
Local cItemIni	:= Space(Len(Criavar("CTD_ITEM")))
Local cItemFim	:= cItemZZZ
Local cClvlIni	:= Space(Len(Criavar("CTH_CLVL")))
Local cClVlFim	:= cClVlZZZ
Local cTpSaldo

Local lConta 	:= .F.
Local lCusto	:= .F.
Local lItem		:= .F.
Local lClasse	:= .F.

Local nReg
Local nFator	 := 1
Local nVezes	:= 0
Local nSaldoAnt := 0
Local nSaldoDeb := 0
Local nSaldoCrd := 0
Local nSaldoAtu := 0		// Saldo ate a data final
Local nSaldoAntD:= 0
Local nSaldoAntC:= 0
Local nSaldoAtuD:= 0
Local nSaldoAtuC:= 0
Local nPos		:= 0
Local nTotal	:= 0

Local aColunas	:= {}
Local nSomaCols := 0
Local nScanEntid
Local nNaoValor	:= 0
Local nTotVezes	:=0
Local aAreaCTS:={}
Local aFator:={}
Local nA:=1
Local nValAtu:= 0
cAlias		:= Iif(cAlias == Nil,"",cAlias)
cIdent		:= Iif(cIdent == Nil,"",cIdent)
lVlrZerado	:= Iif(lVlrZerado == Nil,.T.,lVlrZerado)

Private	 aSldEnt	:= {}

DEFAULT lImpSint	:= .T.
DEFAULT cTpVlr		:= "M"
DEFAULT lValMed		:=.F.
DEFAULT lSalAcum	:=.F.
DEFAULT lPainel		:= .F.
DEFAULT cSldPainel	:= "1"
DEFAULT aResult		:= {}

If __lCOLUN2 == NIL
	__lCOLUN2 :=  Iif(CTS->(FieldPos("CTS_COLUN2")) > 0, .T., .F.)
Endif

If lFiliais == Nil .or. aFiliais == Nil
	aFiliais := {cFilAnt}
EndIf

If lMeses == Nil .or. aMeses == Nil
	aMeses := { {"01",dDataIni,dDataFim} }
EndIf

If lMeses	//Se for Comparativo por Mes
	nTotVezes 	:= Len(aMeses)
ElseIf lFiliais
	nTotVezes	:= Len(aFiliais)
EndIf

//Alimentar a matriz aColunas
For nVezes	:= 1 to nTotVezes
	Aadd(aColunas, 0)
Next

If lPainel .AND. nTotVezes > 0
	For nVezes := 1 To nTotVezes + 3
		aAdd( aResult, {} )	//	1 elemento para o Codigo da Entidade Gerencial, mais;
			//	1 elemento para a Descricao da Entidade Gerencial, mais;
			//	1 elemento para identificar se e Sintetica(.T.) ou nao(.F.), mais;
			//	um elemento para cada periodo do calendario.
	Next
	nNaoValor := 3	//	Ultimo elemento de aResult antes de comecarem os valores
EndIf

dbSelectArea("CTS")
If ValType(oMeter) == "O"
	oMeter:SetTotal(CTS->(RecCount()))
	oMeter:Set(0)
EndIf
dbSetOrder(1)

MsSeek(xFilial()+cPlanGer,.T.)

While !Eof() .And. 	CTS->CTS_FILIAL == xFilial() .And. CTS->CTS_CODPLA == cPlanGer
	nMeter++
	If nMeter%1000 = 0
		If ValType(oMeter) == "O"
			oMeter:Set(nMeter)
		EndIf
	EndIf

	If CTS->CTS_CLASSE == "1" .And. (!CTS->CTS_IDENT $ "56") .and. !(CTS->CTS_IDENT == "3" .and. LEFT(CTS->CTS_DESCCG,1) == "-")
		dbSkip()
		Loop
	EndIf

	// Recarrega vari·veis
	lConta 	:= .F.
	lCusto	:= .F.
	lItem	:= .F.
	lClasse	:= .F.

	// Grava conta analitica
	cConta 	:= CTS->CTS_CONTAG
	cDesc	:= CTS->CTS_DESCCG
	cOrdem	:= CTS->CTS_ORDEM

	nSaldoAnt 	:= 0	// Zero as variaveis para acumular
	nSaldoDeb 	:= 0
	nSaldoCrd 	:= 0

	nSaldoAtu 	:= 0
	nSaldoAntD	:= 0
	nSaldoAntC	:= 0
	nSaldoAtuD	:= 0
	nSaldoAtuC	:= 0

	dbSelectArea("CTS")
	dbSetOrder(1)

	nSomaCols := 0
	While !Eof() .And. CTS->CTS_FILIAL == xFilial() .And. CTS->CTS_CODPLA == cPlanGer  .And. CTS->CTS_ORDEM	== cOrdem

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Se o tipo de saldo informado no CTS for o caracter *    ≥
		//≥assumir que o tipo de saldo eh o informado no parametro.≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		cTpSaldo := Alltrim( CTS->CTS_TPSALD )

		If ( cTpSaldo == "*" .And. cSldPainel <> "*" )
			cTpSaldo := cSldPainel
		ElseIf ( cTpSaldo <> "*" .And. cSldPainel <> "*" ) .And.  cTpSaldo <> cSldPainel
			nReg := Recno()
			dbSkip()
			Loop
		EndIf

		aSaldoAnt	:= { 0, 0, 0, 0, 0, 0, 0, 0 }
		aSaldoAtu	:= { 0, 0, 0, 0, 0, 0, 0, 0 }

		// Recarrega vari·veis
		lConta 	:= .F.
		lCusto	:= .F.
		lItem	:= .F.
		lClasse	:= .F.
		If !Empty(CTS->CTS_CTHINI)	.Or. !Empty(CTS->CTS_CTHFIM)		// Saldo a partir da classe
			lClasse := .T.
			cClVlIni	:= CTS->CTS_CTHINI
			cClVlFim	:= CTS->CTS_CTHFIM
		Else
			cClVlIni	:= ""
			cClVlFim	:= cClVlZZZ
		EndIf
		If !Empty(CTS->CTS_CTDINI) .Or. !Empty(CTS->CTS_CTDFIM)	// Saldo a partir do Item
			lItem := .T.
			cItemIni	:= CTS->CTS_CTDINI
			cItemFim	:= CTS->CTS_CTDFIM
		Else
			cItemIni	:= ""
			cItemFim	:= cItemZZZ
		EndIf
		If !Empty(CTS->CTS_CTTINI) .Or. !Empty(CTS->CTS_CTTFIM)	// Saldo a partir do C.Custo
			lCusto := .T.
			cCustoIni	:= CTS->CTS_CTTINI
			cCustoFim	:= CTS->CTS_CTTFIM
		Else
			cCustoIni	:= ""
			cCustoFim	:= cCustoZZZ
		EndIf
		If !Empty(CTS->CTS_CT1INI) .Or. !Empty(CTS->CTS_CT1FIM)	// Saldo a partir da Conta
			lConta := .T.
			cContaIni	:= CTS->CTS_CT1INI
			cContaFim	:= CTS->CTS_CT1FIM
		Else
			cContaIni	:= ""
			cContaFim	:= cContaZZZ
		EndIf

		For nVezes := 1 to nTotVezes
			aSaldoAnt	:= { 0, 0, 0, 0, 0, 0, 0, 0 }
			aSaldoAtu	:= { 0, 0, 0, 0, 0, 0, 0, 0 }

			If lClasse
				If lMeses
					aSaldoAnt := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
						cItemFim,cCustoIni,cCustoFim,cContaIni,;
						cContaFim,aMeses[nVezes][2],cMoeda,cTpSaldo,aFiliais,,,,lImpAntLP,dDataLP)

					aSaldoAtu := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
						cItemFim,cCustoIni,cCustoFim,cContaIni,;
						cContaFim,aMeses[nVezes][3],cMoeda,cTpSaldo,aFiliais,,,,lImpAntLP,dDataLP)
				EndIf
				If lFiliais
					aSaldoAnt := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
						cItemFim,cCustoIni,cCustoFim,cContaIni,;
						cContaFim,dDataIni,cMoeda,cTpSaldo,aFiliais[nVezes],,,,lImpAntLP,dDataLP)

					aSaldoAtu := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
						cItemFim,cCustoIni,cCustoFim,cContaIni,;
						cContaFim,dDataFim,cMoeda,cTpSaldo,aFiliais[nVezes],,,,lImpAntLP,dDataLP)
				EndIf
			ElseIf lItem
				If lMeses
					aSaldoAnt := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
						cCustoFim,cContaIni,cContaFim,;
						aMeses[nVezes][2],cMoeda,cTpSaldo,,,,,lImpAntLP,dDataLP)

					aSaldoAtu := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
						cCustoFim,cContaIni,cContaFim,;
						aMeses[nVezes][3],cMoeda,cTpSaldo,,,,,lImpAntLP,dDataLP)
				Endif

				If lFiliais
					aSaldoAnt := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
						cCustoFim,cContaIni,cContaFim,;
						dDataIni,cMoeda,cTpSaldo,aFiliais[nVezes],,,,lImpAntLP,dDataLP)

					aSaldoAtu := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
						cCustoFim,cContaIni,cContaFim,;
						dDataFim,cMoeda,cTpSaldo,aFiliais[nVezes],,,,lImpAntLP,dDataLP)

				EndIf
			ElseIf lCusto
				If lMeses
					aSaldoAnt := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
						cContaFim,aMeses[nVezes][2],cMoeda,cTpSaldo,,,,,lImpAntLP,dDataLP)
					aSaldoAtu := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
						cContaFim,aMeses[nVezes][3],cMoeda,cTpSaldo,,,,,lImpAntLP,dDataLP)
				EndIf

				If lFiliais
					aSaldoAnt := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
						cContaFim,dDataIni,cMoeda,cTpSaldo,aFiliais[nVezes],,,,lImpAntLP,dDataLP)
					aSaldoAtu := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
						cContaFim,dDataFim,cMoeda,cTpSaldo,aFiliais[nVezes],,,,lImpAntLP,dDataLP)

				EndIf
			ElseIf lConta
				If lMeses
					aSaldoAnt := SaldTotCT7(cContaIni,cContaFim,aMeses[nVezes][2],cMoeda,cTpSaldo,lImpAntLP,dDataLP)
					aSaldoAtu := SaldTotCT7(cContaIni,cContaFim,aMeses[nVezes][3],cMoeda,cTpSaldo,lImpAntLP,dDataLP)
				Endif

				If lFiliais
					aSaldoAnt := SaldTotCT7(cContaIni,cContaFim,dDataIni,cMoeda,cTpSaldo,lImpAntLP,dDataLP,aFiliais[nVezes])
					aSaldoAtu := SaldTotCT7(cContaIni,cContaFim,dDataFim,cMoeda,cTpSaldo,lImpAntLP,dDataLP,aFiliais[nVezes])
				EndIf
			EndIf

			If aSetOfBook[9] > 1	// Divisao por fator
				For nPos := 1 To Len(aSaldoAnt)
					aSaldoAnt[nPos] := Round(NoRound((aSaldoAnt[nPos]/aSetOfBook[9]),3),2)
				Next
				For nPos := 1 To Len(aSaldoAtu)
					aSaldoAtu[nPos] := Round(NoRound((aSaldoAtu[nPos]/aSetOfBook[9]),3),2)
				Next
			Endif
			If ! Empty(CTS->CTS_FORMUL) .And. Left(CTS->CTS_FORMUL, 7) = "ROTINA="
				nFator := &(Subs(CTS->CTS_FORMUL, 8))
				For nPos := 1 To Len(aSaldoAnt)
					aSaldoAnt[nPos] *= nFator
				Next
				For nPos := 1 To Len(aSaldoAtu)
					aSaldoAtu[nPos] *= nFator
				Next
			Endif

			// Calculos com os Fatores
			If (CTS->CTS_IDENT = "1" .Or. CTS->CTS_IDENT = "2")	// Soma / Subtrai
				If CTS->CTS_IDENT = "1"				// Somo os saldos
					nSaldoAnt 	+= aSaldoAnt[6]		// Saldo Anterior
					nSaldoAtu 	+= aSaldoAtu[1]		// Saldo Atual

					nSaldoAntD 	+= aSaldoAnt[7]
					nSaldoAntC 	+= aSaldoAnt[8]

					nSaldoAtuD 	+= aSaldoAtu[4]
					nSaldoAtuC 	+= aSaldoAtu[5]

					nSaldoDeb  	:= (nSaldoAtuD - nSaldoAntD)
					nSaldoCrd  	:= (nSaldoAtuC - nSaldoAntC)

				ElseIf CTS->CTS_IDENT = "2"			// Subtraio os saldos
					nSaldoAnt 	-= aSaldoAnt[6]		// Saldo Anterior
					nSaldoAtu 	-= aSaldoAtu[1]		// Saldo Atual

					nSaldoAntD 	-= aSaldoAnt[7]
					nSaldoAntC 	-= aSaldoAnt[8]

					nSaldoAtuD 	-= aSaldoAtu[4]
					nSaldoAtuC 	-= aSaldoAtu[5]

					nSaldoDeb  	:= (nSaldoAtuD - nSaldoAntD)
					nSaldoCrd  	:= (nSaldoAtuC - nSaldoAntC)

				EndIf
			EndIf

			If lValMed
				If cTpVlr == 'M'
					aColunas[nVezes] += (nSaldoCrd+nSaldoDeb) /2
				ElseIf cTpVlr == 'S'
					aColunas[nVezes] += (nSaldoAtuC+nSaldoAtuD)
				ElseIf cTpVlr == 'P'
					aColunas[nVezes] +=  (nSaldoAnt + nSaldoAtu)/2

				EndIf
			Else
				If cTpVlr == 'M'
					aColunas[nVezes] += (nSaldoCrd-nSaldoDeb)
				ElseIf cTpVlr == 'S'
					aColunas[nVezes] += (nSaldoAtuC-nSaldoAtuD)
				ElseIf cTpVlr == 'F'
					aColunas[nVezes] += nSaldoAtu
				ElseIf cTpVlr == 'I'
					aColunas[nVezes] += nSaldoAnt
				ElseIf cTpVlr == 'P'
					aColunas[nVezes] +=  (nSaldoAnt + nSaldoAtu)/2
				EndIf
			EndIf
			nSaldoAtuD	:= 0
			nSaldoAntD	:= 0
			nSaldoAtuC	:= 0
			nSaldoAntC	:= 0
			nSaldoAnt	:= 0
			nSaldoAtu	:= 0
			nSaldoCrd	:= 0
			nSaldoDeb	:= 0
		Next
		dbSelectArea("CTS")
		dbSetOrder(1)
		nReg := Recno()
		dbSkip()
	Enddo

	dbSelectArea("CTS")
	dbSetOrder(2)
	dbGoTo(nReg)
	cCodNor := CTS->CTS_NORMAL

	If !lVlrZerado
		For nVezes	:= 1 to  nTotVezes
			nSomaCols += aColunas[nVezes]			/// SOMA OS PERIODOS PARA VER SE O TOTAL … ZERO
		Next
		If nSomaCols == 0
			dbSelectArea("CTS")						/// RETIRADO DELETE POIS SO GRAVA NO TMP SE TIVER VALOR
			dbSetOrder(1)
			dbGoTo(nReg)
			dbSkip()
			Loop
		EndIf
	EndIf

	If !lPainel
		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		If !MsSeek(cConta)
			dbAppend()
			Replace CONTA 		With cConta
			Replace DESCCTA    	With cDesc
			Replace CTASUP    	With CTS->CTS_CTASUP
			Replace TIPOCONTA 	With CTS->CTS_CLASSE
			Replace NORMAL    	With CTS->CTS_NORMAL
			Replace ORDEM		With CTS->CTS_ORDEM
			Replace IDENTIFI	With CTS->CTS_IDENT
			Replace COLVISAO	With IIf( __Release .and. __lCOLUN2, Val(CTS->CTS_COLUN2), GetCTSCol(CTS->CTS_COLUNA,'N',"cArqTmp"))
			Replace TOTVIS 		With CTS->CTS_TOTVIS
			Replace VISENT 		With CTS->CTS_VISENT
			Replace SLDENT 		With CTS->CTS_SLDENT
			Replace FATSLD 		With CTS->CTS_FATSLD

		EndIf

		dbSelectArea("cArqTmp")
		If lSalAcum
			Replace &("COLUNA"+Alltrim(Str(1,2))) With aColunas[1]
			nValAtu:= aColunas[1]
			For nVezes	:= 2 to  nTotVezes
				Replace &("COLUNA"+Alltrim(Str(nVezes,2))) With nValAtu + aColunas[nVezes]
				nValAtu:= nValAtu + aColunas[nVezes]
				aColunas[nVezes]:= nValAtu
			Next
		Else
			For nVezes	:= 1 to  nTotVezes
				Replace &("COLUNA"+Alltrim(Str(nVezes,2))) With  aColunas[nVezes]
			Next
		EndIf
	Else
		nScanEntid := Ascan( aResult[1],cConta )
		// Se for uma nova Entidade Gerencial
		If nScanEntid == 0
			Aadd( aResult[1], cConta	)
			Aadd( aResult[2], cDesc		)
			Aadd( aResult[3], (CTS->CTS_CLASSE == "1") )
			For nVezes	:= 1 to nTotVezes
				Aadd( aResult[nVezes+nNaoValor],aColunas[nVezes] )
			Next
		Else
			For nVezes	:= 1 to nTotVezes
				aResult[nVezes+nNaoValor,nScanEntid] := aColunas[nVezes]
			Next
		EndIf
	EndIf

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Faz uma copia do array aResult para tratamento na funcao≥
	//≥GetSldEnt                                               ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aSldEnt := aClone( aResult )

	// Tratamentos utilizando formula
	If Left(CTS->CTS_FORMUL, 6) = "TEXTO="		// Adiciona texto a descricao
		Replace ("cArqTmp")->DESCCTA With 	AllTrim(("cArqTmp")->DESCCTA) + Space(1) +;
			&(Subs(CTS->CTS_FORMUL, 7))
	Endif

	If Left(CTS->CTS_FORMUL, 7) = "ROTINA="
		nFator := &(Subs(CTS->CTS_FORMUL, 8))
	Endif

	If !lPainel
		If Left(CTS->CTS_FORMUL, 9) = "ENTIDADE="
			nFator := GetSldEnt( substr( CTS->CTS_FORMUL, 10 ) /* cEntidade */,;
				/* cCodVis */,;
				/* cOrdVis */,;
				0 /* nTpSaldo 0->RETORNA ARRAY */,;
				/* cArqTmp */;
				)
			For nVezes	:= 1 to  nTotVezes
				Replace &("COLUNA"+Alltrim(Str(nVezes,2))) With nFator
			Next
		Endif

		If Left(CTS->CTS_FORMUL, 9) = "VARIACAO="
			nFator := GetSldEnt( substr( CTS->CTS_FORMUL, 10 ),,,9)
			For nVezes	:= 1 to  nTotVezes
				Replace &("COLUNA"+Alltrim(Str(nVezes,2))) With nFator
			Next
		Endif

		If Left(CTS->CTS_FORMUL,6 )= "SALDO="
			nFator := &(Subs(CTS->CTS_FORMUL, 7))
			For nVezes	:= 1 to  nTotVezes
				Replace &("COLUNA"+Alltrim(Str(nVezes,2))) With nFator
			Next
		Endif
	EndIf

	dbSelectArea("CTS")
	If ValType(oMeter) == "O"
		oMeter:SetTotal(CTS->(RecCount()))
		oMeter:Set(0)
	EndIf
	dbSetOrder(2)

	If lImpSint
		// Grava contas sinteticas
		If !Empty(CTS->CTS_CTASUP)
			While !Eof() .And. 	CTS->CTS_FILIAL == xFilial() .And. CTS->CTS_CODPLA == cPlanGer
				nMeter++
				If nMeter%1000 = 0
					If ValType(oMeter) == "O"
						oMeter:Set(nMeter)
					EndIf
				EndIf
				cContaSup 	:= CTS->CTS_CTASUP

				dbSelectArea("CTS")
				dbSetOrder(2)
				If MsSeek(xFilial()+cPlanGer+cContaSup)
					cDesc 	:= CTS->CTS_DESCCG
					cNormal := CTS->CTS_NORMAL
				Else
					cNormal	:= cCodNor
				EndIf

				If !lPainel
					dbSelectArea("cArqTmp")
					dbSetOrder(1)
					If !MsSeek(cContaSup)
						dbAppend()
						Replace CONTA	With cContaSup
						Replace DESCCTA With cDesc
						Replace CTASUP    	With CTS->CTS_CTASUP
						Replace TIPOCONTA	With CTS->CTS_CLASSE
						Replace NORMAL   	With CTS->CTS_NORMAL
						Replace ORDEM		With CTS->CTS_ORDEM
						Replace IDENTIFI	With CTS->CTS_IDENT
						Replace COLVISAO	With IIf( __Release .and. __lCOLUN2, Val(CTS->CTS_COLUN2), GetCTSCol(CTS->CTS_COLUNA,'N',"cArqTmp"))
						Replace TOTVIS 		With CTS->CTS_TOTVIS
						Replace VISENT 		With CTS->CTS_VISENT
						Replace SLDENT 		With CTS->CTS_SLDENT
						Replace FATSLD 		With CTS->CTS_FATSLD


						aAreaCTS:=CTS->(GetArea())
						While CTS->(!EOF()) .AND. xFilial("CTS")+cPlanGer+cContaSup ==  CTS->CTS_FILIAL+CTS->CTS_CODPLA +CTS->CTS_CONTAG

							If Left(CTS->CTS_FORMUL, 7) == "ROTINA="
								nFatorS := &(Subs(CTS->CTS_FORMUL, 8))
								Aadd(aFator,{Recno(),nFatorS," ",.F.,0})
							ElseIf Left(CTS->CTS_FORMUL, 6) = "TEXTO="		// Adiciona texto a descricao
								Aadd(aFator,{Recno(),1,Alltrim(&(Subs(CTS->CTS_FORMUL, 7))),.F.,0 })
							ElseIf Left(CTS->CTS_FORMUL,6 ) == "SALDO="
								nFatorS := &(Subs(CTS->CTS_FORMUL, 7))
								Aadd(aFator,{Recno(),1," ",.T.,nFatorS})

							EndIf

							CTS->(Dbskip())
						EndDo
						CTS->(RestArea(aAreaCTS))
					EndIf


					For nVezes	:= 1 to nTotVezes
						&("COLUNA"+Alltrim(Str(nVezes,2))) += aColunas[nVezes]
					Next
					// Manipulacao da conta sintetica

					If Left(CTS->CTS_FORMUL, 6) = "TEXTO="		// Adiciona texto a descricao
						Replace ("cArqTmp")->DESCCTA With 	AllTrim(("cArqTmp")->DESCCTA) + Space(1) + &(Subs(CTS->CTS_FORMUL, 7))
					Endif

					dbSelectArea("CTS")
					If !Eof() .And. Empty(CTS->CTS_CTASUP)
						dbSelectArea("cArqTmp")
						Replace NIVEL1 With .T.
						dbSelectArea("CTS")
						Exit
					EndIf

				Else
					// Se for uma nova Entidade Gerencial
					nScanEntid := Ascan( aResult[1],cContaSup )
					If nScanEntid == 0
						Aadd( aResult[1], cContaSup	)
						Aadd( aResult[2], cDesc		)
						Aadd( aResult[3], (!CTS->(EOF()) .and. CTS->CTS_CLASSE == "1") )
						For nVezes	:= 1 to nTotVezes
							Aadd( aResult[nVezes+nNaoValor],aColunas[nVezes] )
						Next
					Else
						For nVezes	:= 1 to nTotVezes
							aResult[nVezes+nNaoValor,nScanEntid] += aColunas[nVezes]
						Next
					EndIf

					If !Eof() .And. Empty(CTS->CTS_CTASUP)
						Exit
					EndIf
				EndIf
			EndDo
		EndIf
	EndIf

	aColunas	:= {}

	//Alimentar a matriz aColunas
	For nVezes	:= 1 to nTotVezes
		Aadd(aColunas, 0)
	Next

	dbSelectArea("CTS")
	dbSetOrder(1)
	dbGoTo(nReg)
	dbSkip()

EndDo

If !lPainel
	dbSelectArea("cArqTmp")
	If Len(aFator) >0
		For nA:=1 To Len(aFator)
			Dbgoto(aFator[Na][1])
			RecLock( "cArqTmp", .f. )
			For nVezes	:= 1 to nTotVezes
				&("COLUNA"+Alltrim(Str(nVezes,2))) := &("COLUNA"+Alltrim(Str(nVezes,2))) * aFator[Na][2]
			Next
			If aFator[Na][4]
				&("COLUNA"+Alltrim(Str(nVezes,2))) := aFator[Na][5]
			EndIf
			Replace DESCCTA With Alltrim(DESCCTA)+" "+Alltrim(aFator[Na][3])

			MsUnlock()
		Next
	EndIf
EndIf

RestArea(aSaveArea)




Return

//-------------------------------------------------------------------
/*{Protheus.doc} CT3BlnQry
Retorna alias TRBTMP com a composiÁ„o dos saldos Conta x Centro de Custo

Redirecionada para a rotina CQ2BlnQry()

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function CT3BlnQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,	cMoeda,cTpSald,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)

CQ2BlnQry(@dDataIni,@dDataFim,@cContaIni,@cContaFim,@cCCIni,@cCCFim,	@cMoeda,@cTpSald,@aSetOfBook,@lImpMov,@lVlrZerado,@lImpAntLP,@dDataLP,@cFilUSU,@aSelFil,@lTodasFil,@aTmpFil)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CT3BlnQryC
Retorna alias TRBTMP com a composiÁ„o dos saldos Conta x Centro de Custo com o saldo de conta sem centro de custo

Redirecionada para a rotina CQ2CBlnQry()

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CT3BlnQryC(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCustoIni,cCustoFim,cMoeda,;
					cTpSald,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)

CQ2BlnQryC(@dDataIni,@dDataFim,@cContaIni,@cContaFim,@cCustoIni,@cCustoFim,@cMoeda,@cTpSald,@aSetOfBook,@lImpMov,@lVlrZerado,@lImpAntLP,@dDataLP,@cFilUSU,@aSelFil,@lTodasFil,@aTmpFil)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CT4BlnQry
Retorna alias TRBTMP com a composiÁ„o dos saldos Conta x Item Cont·bil

Redirecionada para a rotina CQ4BlnQry()

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CT4BlnQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cItemIni,cItemFim,cMoeda,cTpSald,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)

CQ4BlnQry(@dDataIni,@dDataFim,@cContaIni,@cContaFim,@cItemIni,@cItemFim,@cMoeda,@cTpSald,@aSetOfBook,@lImpMov,@lVlrZerado,@lImpAntLp,@dDataLP,@cFilUSU,@aSelFil,@lTodasFil,@aTmpFil)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥CtCtEntSup ≥Autor  ≥ Simone Mie Sato       ≥ Data ≥ 06.11.02 		     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Atualizacao de sinteticas de entidade/conta                 			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥CtCtEntSup(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook) ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Nenhum                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                  			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cAlias	= Alias a ser utilizado             	               		 ≥±±
±±≥          ≥ lNImpMov = Se imprime entidades sem movimento		               	 ≥±±
±±≥          ≥ cMoeda	= Moeda                              	              		 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CtCtEntSup(oMeter,oText,oDlg,cAlias,lNImpMov,cMoeda)

Local aSaveArea	:= GetArea()
Local cCadAlias	:= ""
Local cCodSup	:= ""
Local cCodEnt	:= ""
Local cConta	:= ""
Local cDescCta	:= ""
Local cEntSup	:= ""
Local cDescEnt	:= ""
Local cSeek		:= ""
Local nSaldoAnt	:= 0
Local nSaldoAtu	:= 0
Local nSaldoDeb	:= 0
Local nSaldoCrd	:= 0
Local nMovimento:= 0
Local nSaldoAntD:= 0
Local nSaldoAntC:= 0
Local nSaldoAtuD:= 0
Local nsaldoAtuC:= 0
Local nRegTmp	:= 0
Local nMeter	:= 0
Local aRegInc   := {}

Do Case
Case cAlias == "CT3"
	cCadAlias 	:= 'CTT'
	cCodSup		:= "CCSUP"
	cCodEnt		:= "CUSTO"
Case cAlias == "CT4"
	cCadAlias 	:= 'CTD'
	cCodSup		:=	"ITSUP"
	cCodEnt		:= "ITEM"
Case cAlias == "CTI"
	cCadAlias 	:= 'CTH'
	cCodSup		:=	"CLSUP"
	cCodEnt		:= "CLVL"
EndCase

// Grava sinteticas
dbSelectArea("cArqTmp")
dbGoTop()
If ValType(oMeter) == "O"
	oMeter:SetTotal(cArqTmp->(RecCount()))
	oMeter:Set(0)
EndIf
While!Eof()

	nSaldoAnt	:= SALDOANT
	nSaldoAtu	:= SALDOATU
	nSaldoDeb	:= SALDODEB
	nSaldoCrd	:= SALDOCRD
	nMovimento	:= MOVIMENTO
	nSaldoAntD	:= SALDOANTDB
	nSaldoAntC	:= SALDOANTCR
	nSaldoAtuD	:= SALDOATUDB
	nsaldoAtuC	:= SALDOATUCR

	nRegTmp := Recno()

	If aScan(aRegInc, nRegTmp) > 0  //se encontrar recno que foi incluido por esta funcao despreza-o
		dbSkip()                    //pois ja subiu ate o topo na atualizacao das superiores
		Loop
	EndIf

	dbSelectArea(cCadAlias)
	dbSetOrder(1)
	MsSeek(xFilial(cCadAlias)+&("cArqTmp->"+cCodEnt))

	If Empty(&(cCadAlias+"->"+cCadAlias+"_"+cCodSup))
		dbSelectArea("cArqTmp")
		Replace NIVEL1 With .T.
		dbSelectArea(cCadAlias)
	EndIf
	MsSeek(xFilial(cCadAlias)+ &("cArqTmp->"+cCodSup))

	While !Eof() .And. &(cCadAlias+"->"+cCadAlias+"_FILIAL") == xFilial(cCadAlias)

		cConta 	 := cArqTmp->CONTA
		cDescCta := cArqTmp->DESCCTA

		cEntSup 	:= &(cCadAlias+"->"+cCadAlias+"_"+cCodEnt)
		cDescEnt	:= &(cCadAlias+"->"+cCadAlias+"_DESC"+cMoeda)

		If Empty(cDescEnt)	// Caso nao preencher descricao da moeda selecionada
			cDescEnt	:=&(cCadAlias+"->"+cCadAlias+"_DESC01")
		Endif

		cSeek 		:= cConta+cEntSup

		dbSelectArea("CT1")
		dbSetOrder(1)
		MsSeek(xFilial("CT1")+cConta,.F.)

		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		If !MsSeek(cSeek)
			dbAppend()
			aAdd(aRegInc, Recno())
			Do Case
			Case cAlias == 'CT3'
				Replace CUSTO   	With cEntSup
				Replace DESCCC		With cDescEnt
				Replace TIPOCC 		With CTT->CTT_CLASSE
				Replace CCSUP 		With CTT->CTT_CCSUP
				Replace CCRES		With CTT->CTT_RES
			Case cAlias == 'CT4'
				Replace ITEM		With cEntSup
				Replace DESCITEM	With cDescEnt
				Replace TIPOITEM 	With CTD->CTD_CLASSE
				Replace ITSUP  		With CTD->CTD_ITSUP
				Replace ITEMRES		With CTD->CTD_RES
			Case cAlias == 'CTI'
				Replace CLVL    	With cEntSup
				Replace DESCCLVL	With cDescEnt
				Replace TIPOCLVL 	With CTH->CTH_CLASSE
				Replace CLSUP    	With CTH->CTH_CLSUP
				Replace CLVLRES		With CTH->CTH_RES
			EndCase
			Replace CONTA		With cConta
			Replace DESCCTA 	With cDescCta
			Replace TIPOCONTA	With CT1->CT1_CLASSE
			Replace SUPERIOR	With CT1->CT1_CTASUP
			Replace CTARES 		With CT1->CT1_RES
		EndIf

		Replace	 SALDOANT 	With SALDOANT + nSaldoAnt
		Replace  SALDOANTDB With SALDOANTDB + nSaldoAntD
		Replace  SALDOANTCR	With SALDOANTCR + nSaldoAntC
		Replace  SALDOATU 	With SALDOATU + nSaldoAtu
		Replace  SALDOATUDB	With SALDOATUDB	+ nSaldoAtuD
		Replace  SALDOATUCR	With SALDOATUCR + nsaldoAtuC
		Replace  SALDODEB 	With SALDODEB + nSaldoDeb
		Replace  SALDOCRD 	With SALDOCRD + nSaldoCrd
		If !lNImpMov
			Replace MOVIMENTO With MOVIMENTO + nMovimento
		Endif

		dbSelectArea(cCadAlias)
		If Empty(&(cCadAlias+"->"+cCadAlias+"_"+cCodSup))
			dbSelectArea("cArqTmp")
			Replace NIVEL1 With .T.
			dbSelectArea(cCadAlias)
			Exit
		EndIf

		dbSelectArea(cCadAlias)
		MsSeek(xFilial(cCadAlias)+ &("cArqTmp->"+cCodSup))
	EndDo
	dbSelectArea("cArqTmp")
	dbGoto(nRegTmp)
	dbSkip()
	nMeter++
	If nMeter%1000 = 0
		If ValType(oMeter) == "O"
	   		oMeter:Set(nMeter)
	  	EndIf
  	EndIf
EndDo

RestArea(aSaveArea)

Return



//-------------------------------------------------------------------
/*{Protheus.doc} CT7BlnQry
Retorna alias TRBTMP com a composiÁ„o dos saldos Conta

Redirecionada para a rotina CQ0BlnQry()

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CT7BlnQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cMoeda,cTpSald,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,cMoedaDsc,aSelFil,dDtCorte,lTodasFil,aTmpFil)

CQ0BlnQry(@dDataIni,@dDataFim,@cContaIni,@cContaFim,@cMoeda,@cTpSald,@aSetOfBook,@lImpMov,@lVlrZerado,@lImpAntLP,@dDataLP,@cFilUsu,@cMoedaDsc,@aSelFil,@dDtCorte,@lTodasFil,@aTmpFil)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥CtContaSup ≥Autor  ≥ Simone Mie Sato       ≥ Data ≥ 22.08.03 		     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Atualizacao de sinteticas de conta =>relatorios             			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥CtContaSup()															 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Nenhum                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                  			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ lNImpMov = Se imprime entidades sem movimento		               	 ≥±±
±±≥          ≥ cMoeda	= Moeda                              	              		 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CtContaSup(oMeter,oText,oDlg,lNImpMov,cMoeda,cMoedaDsc)

Local aSaveArea	:= GetArea()
Local cContaSup	:= ""
Local cDesc		:= ""
Local nSaldoAnt	:= 0
Local nSaldoAtu	:= 0
Local nSaldoDeb	:= 0
Local nSaldoCrd	:= 0
Local nMovimento:= 0
Local nSaldoAntD:= 0
Local nSaldoAntC:= 0
Local nSaldoAtuD:= 0
Local nsaldoAtuC:= 0
Local nReg   	:= 0
Local nRegTmp	:= 0
Local nMeter	:= 0
Local lSemestre 	:= FieldPos("SALDOSEM") > 0		// Saldo por semestre
Local lPeriodo0		:= FieldPos("SALDOPER") > 0		// Saldo dois periodos anteriores
Local cNatCta	:= ""

DEFAULT cMoedaDsc	:= '01'

nSaldoAnt	:= SALDOANT
nSaldoAtu	:= SALDOATU
nSaldoDeb	:= SALDODEB
nSaldoCrd	:= SALDOCRD
nMovimento	:= MOVIMENTO

nSaldoAtuD	:= SALDOATUDB
nSaldoAtuC	:= SALDOATUCR


// Grava sinteticas
dbSelectArea("cArqTmp")
dbGoTop()
If ValType(oMeter) == "O"
	oMeter:SetTotal(cArqTmp->(RecCount()))
	oMeter:Set(0)
EndIf

While !Eof()

	If cArqTmp->TIPOCONTA == "1"
		dbSkip()
		Loop
	ElseIf funname() == "CTBR140" .and. cArqTmp->TIPOITEM == "1"
		dbSkip()
		Loop
	ElseIf FunName() == "CTBR145" .And. cArqTmp->TIPOCC == "1"
		dbSkip()
		Loop
	Endif

	nRegTmp	:= Recno()
	nSaldoAnt	:= SALDOANT
	nSaldoAtu	:= SALDOATU
	nSaldoDeb	:= SALDODEB
	nSaldoCrd	:= SALDOCRD
	nMovimento	:= MOVIMENTO
	nSaldoAtuD	:= SALDOATUDB
	nSaldoAtuC	:= SALDOATUCR

	dbSelectArea("CT1")
	dbSetOrder(1)

	cContaSup := cArqTmp->SUPERIOR
	If Empty(cContaSup)
		dbSelectArea("cArqTmp")
		Replace NIVEL1 With .T.
		dbSelectArea("CT1")
	EndIf
	MsSeek(xFilial()+cContaSup)

	While !Eof() .And. CT1->CT1_FILIAL == xFilial()

		If Empty(cMoedaDsc)
			cDesc := &("CT1->CT1_DESC"+cMoeda)
		Else
			cDesc := &("CT1->CT1_DESC"+cMoedaDsc)
		EndIf

		If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
			cDesc := CT1->CT1_DESC01
		Endif

   		dbSelectArea("cArqTmp")
		dbSetOrder(1)

		If cArqTmp->( FieldPos( "NATCTA" ) ) > 0
			cNatCta := cArqTmp->NATCTA
		EndIf

		If !MsSeek(cContaSup)
			dbAppend()
			Replace CONTA		With cContaSup
			Replace SUPERIOR	With CT1->CT1_CTASUP
			Replace DESCCTA		With cDesc
			Replace TIPOCONTA	With CT1->CT1_CLASSE
			Replace CTARES    	With CT1->CT1_RES
			Replace NORMAL   	With CT1->CT1_NORMAL
			Replace GRUPO		With CT1->CT1_GRUPO
			If cArqTmp->( FieldPos( "NATCTA" ) ) > 0
				Replace NATCTA		With cNatCta
			EndIf
		EndIf

		Replace	SALDOANT 	With SALDOANT 	+ nSaldoAnt
		Replace SALDOANTDB  With SALDOANTDB + nSaldoAntD
		Replace SALDOANTCR	With SALDOANTCR + nSaldoAntC
		Replace SALDOATU 	With SALDOATU 	+ nSaldoAtu
		Replace SALDOATUDB	With SALDOATUDB	+ nSaldoAtuD
		Replace SALDOATUCR	With SALDOATUCR + nsaldoAtuC
		Replace SALDODEB 	With SALDODEB 	+ nSaldoDeb
		Replace SALDOCRD 	With SALDOCRD 	+ nSaldoCrd

		If !lNImpMov
			Replace MOVIMENTO With MOVIMENTO + nMovimento
		Endif

		If lSemestre		// Saldo por semestre
			Replace SALDOSEM With SALDOSEM 	+ nSaldoSEM
		Endif

   		If lPeriodo0		// Saldo dois periodos anteriores
			Replace SALDOPER With SALDOPER 	+ nSaldoSEM
		Endif

		dbSelectArea("CT1")
		cContaSup := CT1->CT1_CTASUP
		If Empty(CT1->CT1_CTASUP)
			dbSelectArea("cArqTmp")
			Replace NIVEL1 With .T.
			dbSelectArea("CT1")
			Exit
		EndIf
		MsSeek(xFilial()+cContaSup)
	EndDo
	dbSelectArea("cArqTmp")
	dbGoto(nRegTmp)
	dbSkip()
	nMeter++
	If nMeter%1000 = 0
		If ValType(oMeter) == "O"
	   		oMeter:Set(nMeter)
	  	EndIF
  	EndIf
EndDo


RestArea(aSaveArea)

Return


//-------------------------------------------------------------------
/*{Protheus.doc} CTUBlnQry
Retorna alias TRBTMP com a composiÁ„o dos saldos de uma entidade gerencial

@author Alvaro Camillo Neto


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CTUBlnQry(dDataIni,dDataFim,cAlias,cIdent,cEntidIni,cEntidFim,cMoeda,cTpSald,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,aSelFil,lTodasFil,aTmpFil)

CQ8BlnQry(@dDataIni,@dDataFim,@cIdent,@cEntidIni,@cEntidFim,@cMoeda,@cTpSald,@aSetOfBook,@lImpMov,@lVlrZerado,@lImpAntLP,@dDataLP,@cFilUsu,@aSelFil,@lTodasFil,@aTmpFil)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥CtbCTUSup  ≥Autor  ≥ Simone Mie Sato       ≥ Data ≥ 12.09.03 		     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Atualizacao de sinteticas                                   			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥CtbCTUSup() 															 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Nenhum                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                  			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ lNImpMov = Se imprime entidades sem movimento		               	 ≥±±
±±≥          ≥ cMoeda	= Moeda                              	              		 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CtbCTUSup(oMeter,oText,oDlg,lNImpMov,cMoeda,cIdent)

Local aSaveArea	:= GetArea()
Local cDesc		:= ""
Local cCodEnt	:= ""
Local cCodEntSup:= ""
Local cEntidSup	:= ""
Local nSaldoAnt	:= 0
Local nSaldoAtu	:= 0
Local nSaldoDeb	:= 0
Local nSaldoCrd	:= 0
Local nMovimento:= 0
Local nSaldoAntD:= 0
Local nSaldoAntC:= 0
Local nSaldoAtuD:= 0
Local nsaldoAtuC:= 0
Local nReg   	:= 0
Local nRegTmp	:= 0
Local nTamDesc	:= 0
Local nMeter	:= 0
Local cTipoEnt	:= ""

Do Case
Case cIdent == 'CTT'
	cCodEnt		:= 'CUSTO'
	cCodEntSup	:= 'CCSUP'
	nTamDesc	:= Len(CriaVar("CTT->CTT_DESC"+cMoeda))
	cTipoEnt	:= 'TIPOCC'
Case cIdent=='CTD'
	cCodEnt		:= 'ITEM'
	cCodEntSup  := 'ITSUP'
	nTamDesc	:= Len(CriaVar("CTD->CTD_DESC"+cMoeda))
	cTipoEnt	:= 'TIPOITEM'
Case cIdent =='CTH'
	cCodEnt		:= 'CLVL'
	cCodEntSup  := 'CLSUP'
	nTamDesc	:= Len(CriaVar("CTH->CTH_DESC"+cMoeda))
	cTipoEnt	:= 'TIPOCLVL'
EndCase

// Grava sinteticas
dbSelectArea("cArqTmp")
DbSeek(xFilial(cIdent))
If ValType(oMeter) == "O"
	oMeter:SetTotal(("cArqTmp")->(RecCount()))
	oMeter:Set(0)
EndIf

dbGoTop()

While!Eof()
	If  &( "cArqTmp->" + cTipoEnt ) == '2'

		nSaldoAnt:= SALDOANT
		nSaldoAtu:= SALDOATU
		nSaldoDeb:= SALDODEB
		nSaldoCrd:= SALDOCRD
		nMovimento:= MOVIMENTO
		nSaldoAntD := SALDOANTDB
		nSaldoAntC := SALDOANTCR
		nSaldoAtuD := SALDOATUDB
		nsaldoAtuC := SALDOATUCR

		nRegTmp := Recno()

		dbSelectArea(cIdent)
		dbSetOrder(1)
		cEntidSup := &("cArqTmp->"+cCodEntSup)

		If Empty(cEntidSup)
			dbSelectArea("cArqTmp")
			Replace NIVEL1 With .T.
			dbSelectArea(cIdent)
		EndIf

		MsSeek(xFilial()+ &("cArqTmp->"+cCodEntSup))

		While !Eof() .And. &(cIdent+"_FILIAL") == xFilial(cIdent)

			cDesc := &(cIdent+"_DESC"+cMoeda)
			If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
				cDesc := &(cIdent+"_DESC01")
			Endif

			dbSelectArea("cArqTmp")
			dbSetOrder(1)

		If ! MsSeek(cEntidSup)

				dbAppend()
				If cIdent == 'CTT'
					Replace CUSTO   	With cEntidSup
					Replace DESCCC		With cDesc
					Replace TIPOCC 		With CTT->CTT_CLASSE
					Replace CCSUP 		With CTT->CTT_CCSUP
					Replace CCRES		With CTT->CTT_RES
				ElseIf cIdent == 'CTD'
					Replace ITEM 		With cEntidSup
					Replace DESCITEM	With cDesc
					Replace TIPOITEM 	With CTD->CTD_CLASSE
					Replace ITSUP  		With CTD->CTD_ITSUP
					Replace ITEMRES		With CTD->CTD_RES
				ElseIf cIdent == 'CTH'
					Replace CLVL 	 With cEntidSup
					Replace DESCCLVL With cDesc
					Replace TIPOCLVL With CTH->CTH_CLASSE
					Replace CLSUP	 With CTH->CTH_CLSUP
					Replace CLVLRES	 With CTH->CTH_RES
				EndIf
				If Alltrim(Upper(FunName())) <> "CTBR210"
				 	Replace FILIAL	 With    cFilAnt
				ENDIF
	   		EndIf

			Replace	 SALDOANT With SALDOANT + nSaldoAnt
			Replace  SALDOANTDB With SALDOANTDB + nSaldoAntD
			Replace  SALDOANTCR	With SALDOANTCR + nSaldoAntC
			Replace  SALDOATU With SALDOATU + nSaldoAtu
			Replace  SALDOATUDB	With SALDOATUDB	+ nSaldoAtuD
			Replace  SALDOATUCR	With SALDOATUCR + nsaldoAtuC
			Replace  SALDODEB With SALDODEB + nSaldoDeb
			Replace  SALDOCRD With SALDOCRD + nSaldoCrd

			If !lNImpMov
				Replace MOVIMENTO With MOVIMENTO + nMovimento
			Endif

			cEntidSup := &("cArqTmp->"+cCodEntSup)
			If Empty(cEntidSup)
				dbSelectArea("cArqTmp")
				Replace NIVEL1 With .T.
				dbSelectArea(cIdent)
				Exit
			EndIf
			dbSelectArea("cArqTmp")
			dbGoto(nRegTmp)
			dbSelectArea(cIdent)
			MsSeek(xFilial()+ cEntidSup)
		EndDo
		dbSelectArea("cArqTmp")
		dbGoto(nRegTmp)
	Endif
	dbSkip()
	nMeter++
	If nMeter%1000 = 0
		If ValType(oMeter) == "O"
	   		oMeter:Set(nMeter)
  		EndIf
	EndIf
EndDo

RestArea(aSaveArea)
Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CTBXSAL   ∫Autor  ≥Microsiga           ∫ Data ≥  06/12/03   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP6                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function SupCmpEnt(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni,cEntidFim,;
					cMoeda,cTpSld1,cTpSld2,aSetOfBook,;
					cSegmento,cSegIni,cSegFim,cFiltSegm,cAlias,;
					lCusto,lItem,lClVl,lAtSldBase,nInicio,nFinal,cFilDe,cFilate,;
					nDivide,lVariacao0,nGrupo,bVariacao,cIdent,lCt1Sint,aSelFil,lTodasFil)

Local aSaveArea 	:= GetArea()

Local cDesc
Local cMascara		:= ""
Local cSepara		:= ""

Local nPos			:= 0
Local nDigitos		:= 0
Local nRegTmp   	:= 0
Local nTamDesc		:= ""
Local nMovSld1		:= 0
Local nMovSld2		:= 0
Local nColuna1		:= 0
Local nColuna2		:= 0
Local nMeter		:= 0

Local oProcess
Local dMinSld1 := cTod("")
Local dMinSld2 := cTod("")

Local aSldAnt1 := {}
Local	aSldAnt2 := {}

Local lAtSldCmp := Iif(GetMV("MV_SLDCOMP")== "S",.T.,.F.)
Local cMensagem := OemToAnsi(STR0002)// O plano gerencial ainda nao esta disponivel nesse relatorio.

Local nMin			:= 0
Local nMax			:= 0

DEFAULT lCt1Sint := .T.
DEFAULT aSelFil   := {}
DEFAULT lTodasFil := .F.

lVariacao0	:= Iif(lVariacao0 == Nil,.T.,lVariacao0)
nDivide 	:= Iif(nDivide == Nil,1,nDivide)

If cAlias	== 'CT7'
	If !Empty(aSetOfBook[2])
		cMascara	:= aSetOfBook[2]
	EndIf
ElseIf cAlias	== 'CTU'
  		Do Case
  		Case cIdent == 'CTT'
	 		cMascara	:= aSetOfBook[6]
	 		cOrigem		:= 'CT3'
 		Case cIdent	== 'CTD'
	 		cMascara	:= aSetOfBook[7]
	 		cOrigem		:= 'CT4'
		Case cIdent == 'CTH'
	 		cMascara	:= aSetOfBook[8]
	 		cOrigem		:= 'CTI'
 		EndCase
EndIf


//Se os saldos basicos nao foram atualizados na dig. lancamentos
If !lAtSldBase .And. !__IsCtbJob
		dIniRep := ctod("")
  	If Need2Reproc(dDataFim,cMoeda,cTpSld1,@dIniRep)
		//Chama Rotina de Atualizacao de Saldos Basicos.
		oProcess := MsNewProcess():New({|lEnd|	CTBA190(.T.,dIniRep,dDataFim,cFilAnt,cFilAnt,cTpSld1,.T.,cMoeda) },"","",.F.)
		oProcess:Activate()
	EndIf
		dIniRep := ctod("")
  	If Need2Reproc(dDataFim,cMoeda,cTpSld2,@dIniRep)
		//Chama Rotina de Atualizacao de Saldos Basicos.
		oProcess := MsNewProcess():New({|lEnd|	CTBA190(.T.,dIniRep,dDataFim,cFilAnt,cFilAnt,cTpSld2,.T.,cMoeda) },"","",.F.)
		oProcess:Activate()
	EndIf
Endif

If cAlias == 'CT7'

	If !lCt1Sint
		RestArea(aSaveArea)	/// SE N√O DEVE CALCULAR AS SINTETICAS ABORTA
		Return
	Endif

	// Grava contas sinteticas

	dbSelectArea("cArqTmp")
	If ValType(oMeter) == "O"
		oMeter:SetTotal(cArqTmp->(RecCount()))
		oMeter:Set(0)
	EndIf
	dbGoTop()

	While!Eof()
		nMeter++
		If nMeter%1000 = 0
			If ValType(oMeter) == "O"
			  	oMeter:Set(nMeter)
			EndIf
		EndIf

		nMovim01	:= MOVIMENTO1
		nMovim02	:= MOVIMENTO2
		If FieldPos("COLUNA_1") > 0
			nColuna1 := COLUNA_1
			nColuna2 := COLUNA_2
		Else
			nColuna1 := nColuna2 := 0.00
		Endif
		nRegTmp 	:= Recno()

		dbSelectArea("CT1")
		dbSetOrder(1)
		MsSeek(xFilial()+cArqTmp->CONTA)

		If Empty(CT1->CT1_CTASUP)
			dbSelectArea("cArqTmp")
			Replace NIVEL1 With .T.
			dbSelectArea("CT1")
		EndIf

		cContaSup := CT1->CT1_CTASUP
		MsSeek(xFilial()+cContaSup)

		While !Eof() .And. CT1->CT1_FILIAL == xFilial()
			cDesc := &("CT1->CT1_DESC"+cMoeda)
			If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
				cDesc := CT1->CT1_DESC01
			Endif
			dbSelectArea("cArqTmp")
			dbSetOrder(1)
			If !MsSeek(cContaSup)
				RecLock("cArqTMP",.T.)
				Replace CONTA		With cContaSup
				Replace DESCCTA		With cDesc
				Replace TIPOCONTA	With CT1->CT1_CLASSE
				Replace CTARES    	With CT1->CT1_RES
				Replace NORMAL   	With CT1->CT1_NORMAL
				Replace GRUPO		With CT1->CT1_GRUPO
			Else
				RecLock("cArqTMP",.F.)
			EndIf

			Replace	 MOVIMENTO1 With MOVIMENTO1 + nMovim01
			Replace  MOVIMENTO2 With MOVIMENTO2 + nMovim02

			If nColuna1 # 0
				Replace COLUNA_1 With COLUNA_1 + nColuna1
			Endif

			If nColuna2 # 0
				Replace COLUNA_2 With COLUNA_2 + nColuna2
			Endif

			If bVariacao <> Nil
				Eval(bVariacao)
			Endif

			dbSelectArea("CT1")
			cContaSup := CT1->CT1_CTASUP
			If Empty(CT1->CT1_CTASUP)
				dbSelectArea("cArqTmp")
				Replace NIVEL1 With .T.
				dbSelectArea("CT1")
				Exit
			EndIf
			cArqTMP->(MsUnlock())
			MsSeek(xFilial()+cContaSup)
		EndDo

		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		dbGoTo(nRegTmp)
		dbSkip()
	EndDo

ElseIf cAlias == 'CTU'

	Do Case
	Case cIdent == 'CTT'
		cCodEnt		:= 'CUSTO'
		cCodEntSup	:= 'CCSUP'
		nTamDesc	:= Len(CriaVar("CTT->CTT_DESC"+cMoeda))
	Case cIdent=='CTD'
		cCodEnt		:= 'ITEM'
		cCodEntSup  := 'ITSUP'
		nTamDesc	:= Len(CriaVar("CTD->CTD_DESC"+cMoeda))
	Case cIdent =='CTH'
		cCodEnt		:= 'CLVL'
		cCodEntSup  := 'CLSUP'
		nTamDesc	:= Len(CriaVar("CTH->CTH_DESC"+cMoeda))
	EndCase

	dbSelectArea(cIdent)
	dbSetOrder(1)
	MsSeek(xFilial()+cEntidIni,.T.)
	// Grava sinteticas
	dbSelectArea("cArqTmp")
	If ValType(oMeter) == "O"
		oMeter:SetTotal(cArqTmp->(RecCount()))
		oMeter:Set(0)
	EndIf
	dbGoTop()

	While!Eof()
		nMeter++
		If nMeter%1000 = 0
			If ValType(oMeter) == "O"
	    		oMeter:Set(nMeter)
	   		EndIf
   		EndIf

		nMovim01	:= MOVIMENTO1
		nMovim02	:= MOVIMENTO2
		If FieldPos("COLUNA_1") > 0
			nColuna1 := COLUNA_1
			nColuna2 := COLUNA_2
		Else
			nColuna1 := nColuna2 := 0.00
		Endif

		nRegTmp := Recno()

		dbSelectArea(cIdent)
		dbSetOrder(1)
		cEntidSup := &("cArqTmp->"+cCodEntSup)
		If Empty(cEntidSup)
			dbSelectArea("cArqTmp")
			Replace NIVEL1 With .T.
			dbSelectArea(cIdent)
		EndIf
		MsSeek(xFilial()+ &("cArqTmp->"+cCodEntSup))

		While !Eof() .And. &(cIdent+"_FILIAL") == xFilial()

			cDesc := &(cIdent+"_DESC"+cMoeda)
			If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
				cDesc := &(cIdent+"_DESC01")
			Endif

			dbSelectArea("cArqTmp")
			dbSetOrder(1)
			If ! MsSeek(cEntidSup)
				RecLock("cArqTMP",.T.)
				If cIdent == 'CTT'
					Replace CUSTO   	With cEntidSup
					Replace DESCCC		With cDesc
					Replace TIPOCC 		With CTT->CTT_CLASSE
					Replace CCSUP 		With CTT->CTT_CCSUP
					Replace CCRES		With CTT->CTT_RES
				ElseIf cIdent == 'CTD'
					Replace ITEM 		With cEntidSup
					Replace DESCITEM	With cDesc
					Replace TIPOITEM 	With CTD->CTD_CLASSE
					Replace ITSUP  		With CTD->CTD_ITSUP
					Replace ITEMRES		With CTD->CTD_RES
				ElseIf cIdent == 'CTH'
					Replace CLVL 	 With cEntidSup
					Replace DESCCLVL With cDesc
					Replace TIPOCLVL With CTH->CTH_CLASSE
					Replace CLSUP	 With CTH->CTH_CLSUP
					Replace CLVLRES	 With CTH->CTH_RES
				EndIf
			Else
				RecLock("cArqTMP",.F.)
			EndIf
			Replace	 MOVIMENTO1 With MOVIMENTO1 + nMovim01
			Replace  MOVIMENTO2 With MOVIMENTO2 + nMovim02

			If nColuna1 # 0
				Replace COLUNA_1 With COLUNA_1 + nColuna1
			Endif

			If nColuna2 # 0
				Replace COLUNA_2 With COLUNA_2 + nColuna2
			Endif

	   		If bVariacao <> Nil
				Eval(bVariacao)
			Endif

			cEntidSup := &("cArqTmp->"+cCodEntSup)
			If Empty(cEntidSup)
				dbSelectArea("cArqTmp")
				Replace NIVEL1 With .T.
				dbSelectArea(cIdent)
				Exit
			EndIf
			cArqTMP->(MsUnlock())

			dbSelectArea("cArqTmp")
			dbGoto(nRegTmp)
			dbSelectArea(cIdent)
			MsSeek(xFilial()+ cEntidSup)
		EndDo
		dbSelectArea("cArqTmp")
		dbGoto(nRegTmp)
		dbSkip()
	EndDo
EndIf
RestArea(aSaveArea)

Return


//-------------------------------------------------------------------
/*{Protheus.doc} CT7CompQry
Query para comparativo de conta x 6/12 meses

@author Alvaro Camillo Neto

@param oMeter	 Objeto oMeter
@param oText 	 Objeto oText
@param oDlg  	 Objeto oDlg
@param lEnd 	  Acao do CodeBlock
@param dDataIni   Data Inicial
@param dDataFim  Data Final
@param cMoeda	 Moeda
@param aSetOfBook Array aSetOfBook
@param cAlias     Alias a ser utilizado
@param cIdent     Identficador
@param lImpAntLP	Define se ira considerar apuracao de lucros/perdas
@param dDataLP  	Data de apuracao de lucros/perdas a ser considerado
@param lVlrZerado	Define se ira imprimir os valores zerados.

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CT7CompQry(dDataIni,dDataFim,cTpSaldo,cMoeda,cContaIni,cContaFim,aSetOfBook,lVlrZerado,lMeses,aMeses,cString,cFILUSU,lImpAntLP,dDataLP,lAcum)

CQ0CompQry(@dDataIni,@dDataFim,@cTpSaldo,@cMoeda,@cContaIni,@cContaFim,@aSetOfBook,@lVlrZerado,@lMeses,@aMeses,@cString,@cFILUSU,@lImpAntLP,@dDataLP,@lAcum)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥SupCompCt7 ≥Autor  ≥ Simone Mie Sato       ≥ Data ≥ 12.06.03 		     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Gravacao das contas superiores nos comparativos.(TOP CONNECT)			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥SupCompCT7()                                                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Nenhum                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                  			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ oMeter	= Objeto oMeter                     	               		 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function SupCompCt7(oMeter,lMeses,aMeses,cMoeda,cTpVlr)

Local nTotVezes		:= 0
Local nVezes		:= 0
Local nReg			:= 0
Local cContaSup		:= ""
Local cDesc			:= ""
Local aMovimento	:= {}
Local nMeter		:= 0
Local aTamVlr	:= TAMSX3("CT7_DEBITO")

If lMeses	//Se for Comparativo por Mes
	nTotVezes := Len(aMeses)
EndIf

// Grava contas sinteticas
dbSelectArea("cArqTmp")
If ValType(oMeter) == "O"
	oMeter:SetTotal(cArqTmp->(RecCount()))
	oMeter:Set(0)
EndIf
dbGoTop()

While!Eof()
	nMeter++
	If nMeter%1000 = 0
		If ValType(oMeter) == "O"
	   		oMeter:Set(nMeter)
	  	EndIf
	EndIf
	nReg	:= Recno()
	cContaSup := cArqTmp->CTASUP
	// Grava contas sinteticas
	If Empty(cArqTmp->CTASUP)
		dbSelectArea("cArqTmp")
		Replace NIVEL1 With .T.
	EndIf

	For nVezes := 1 to nTotVezes
		AADD(aMovimento,&("COLUNA"+Alltrim(Str(nVezes,2))))
	Next

	dbSelectArea("CT1")
	dbSetOrder(1)
	MsSeek(xFilial()+cContaSup)

	While !Eof() .And. CT1->CT1_FILIAL == xFilial()

		cDesc := &("CT1->CT1_DESC"+cMoeda)
		If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
			cDesc := CT1->CT1_DESC01
		Endif

		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		If !MsSeek(cContaSup)
			dbAppend()
			Replace CONTA		With cContaSup
			Replace DESCCTA		With cDesc
			Replace TIPOCONTA	With CT1->CT1_CLASSE
			Replace CTARES    	With CT1->CT1_RES
			Replace NORMAL   	With CT1->CT1_NORMAL
			Replace GRUPO		With CT1->CT1_GRUPO
			Replace CTASUP		With CT1->CT1_CTASUP
		Else

		EndIf

		For nVezes := 1 to nTotVezes
//			If cTpVlr == 'M'
				Replace &("COLUNA"+	Alltrim(Str(nVezes,2))) With (&("COLUNA"+Alltrim(Str(nVezes,2)))+aMovimento[nVezes])
//			EndIf
	   	Next

		dbSelectArea("CT1")
		cContaSup := CT1->CT1_CTASUP
		If Empty(CT1->CT1_CTASUP)
			dbSelectArea("cArqTmp")
			Replace NIVEL1 With .T.
			dbSelectArea("CT1")
			Exit
		EndIf
		MsSeek(xFilial()+cContaSup)
	EndDo
	aMovimento	:= {}
	dbSelectArea("cArqTmp")
	dbGoTo(nReg)
	dbSkip()
EndDo

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Program   ≥SupCompEnt  Autor ≥ Simone Mie Sato       ≥ Data ≥ 09.04.02 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Gerar Arquivo Temporario para Balancetes Entidade1/Entidade2≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ .T. / .F.                                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpO1 = Objeto oMeter                                      ≥±±
±±≥          ≥ ExpO2 = Objeto oText                                       ≥±±
±±≥          ≥ ExpO3 = Objeto oDlg                                        ≥±±
±±≥          ≥ ExpL1 = lEnd                                               ≥±±
±±≥          ≥ ExpD1 = Data Inicial                                       ≥±±
±±≥          ≥ ExpD2 = Data Final                                         ≥±±
±±≥          ≥ ExpC1 = Conta Inicial                                      ≥±±
±±≥          ≥ ExpC2 = Conta Final                                        ≥±±
±±≥          ≥ ExpC3 = Classe de Valor Inicial                            ≥±±
±±≥          ≥ ExpC4 = Classe de Valor Final                              ≥±±
±±≥          ≥ ExpC5 = Moeda		                                      ≥±±
±±≥          ≥ ExpC6 = Saldo	                                          ≥±±
±±≥          ≥ ExpA1 = Set Of Book	                                      ≥±±
±±≥          ≥ ExpN1 = Tamanho da descricao da conta	                  ≥±±
±±≥          ≥ ExpC7 = Ate qual segmento sera impresso (nivel)			  ≥±±
±±≥          ≥ ExpC8 = Filtra por Segmento		                          ≥±±
±±≥          ≥ ExpC9 = Segmento Inicial		                              ≥±±
±±≥          ≥ ExpC10= Segmento Final  		                              ≥±±
±±≥          ≥ ExpC11= Segmento Contido em  	                          ≥±±
±±≥          ≥ ExpL12= Se imprime total acumulado	                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function SupCompEnt(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
				cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
				lNImpMov,cAlias,lCusto,lItem,lClvl,lAtSldBase,lAtSldCmp,nInicio,nFinal,cFilDe,;
				cFilAte,lImpAntLP,dDataLP,nDivide,cTpVlr,lFiliais,aFiliais,lMeses,aMeses,lVlrZerado,lEntid,aEntid)

Local aSaveArea 	:= GetArea()
Local cMascara1 	:= ""
Local cMascara2		:= ""
Local nPos			:= 0
Local nDigitos		:= 0
Local cEntid1		:= ""	//Codigo da Entidade Principal
Local cEntid2   	:= "" 	//Codigo da Entidade do Corpo do Relatorio
local nSaldoAnt 	:= 0
Local nSaldoDeb 	:= 0
Local nSaldoCrd 	:= 0
Local nSaldoAtu 	:= 0
Local nSaldoAntD	:= 0
Local nSaldoAntC	:= 0
Local nSaldoAtuD	:= 0
Local nSaldoAtuC	:= 0
Local nRegTmp   	:= 0
Local nOrder		:= 0
Local cChave		:= ""
Local bCond1		:= {||.F.}
Local bCond2		:= {||.F.}
Local cCadAlias1	:= ""	//Alias do Cadastro da Entidade Principal
Local cCadAlias2	:= ""	//Alias do Cadastro da Entidade que sera impressa no corpo.
Local cCodEnt1		:= ""	//Codigo da Entidade Principal
Local cCodEnt2		:= ""	//Codigo da Entidade que sera impressa no corpo do relat.
Local cDesc1		:= ""
Local cDesc2		:= ""
Local cDescEnt		:= ""
Local cDescEnt1		:= ""	//Descricao da Entidade Principal
Local cDescEnt2		:= ""	//Descricao da Entidade que sera impressa no corpo.
Local cCodSup1		:= ""	//Cod.Superior da Entidade Principal
Local cCodSup2		:= ""	//Cod.Superior da Entidade que sera impressa no corpo.
Local nRecno1		:= ""
Local nRecno2		:= ""
Local cEntidSup		:= ""
Local nTamDesc1		:= ""
Local nTamDesc2		:= ""
Local cOrigem		:= ""
Local cMensagem		:= OemToAnsi(STR0016)+ OemToAnsi(STR0017)
Local dMinData
Local nTotVezes		:= 0
Local aMovimento	:= {0,0,0,0,0,0}
Local nMeter		:= 0
Local nVezes		:= 1

DEFAULT lEntid 		:= .F.
DEFAULT aEntid		:= {}

lFiliais			:= Iif(lFiliais == Nil,.F.,lFiliais)
aFiliais			:= Iif(aFiliais==Nil,{},aFiliais)
lMeses				:= Iif(lMeses == NIl, .F.,lMeses)
aMeses				:= Iif(aMeses==Nil,{},aMeses)
nDivide 			:= Iif(nDivide == Nil,1,nDivide)
lVlrZerado			:= Iif(lVlrZerado == Nil,.T.,lVlrZerado)

If lFiliais	//Se for Comparativo por Filiais
	nTotVezes := Len(aFiliais)
Else
	If lMeses	//Se for Comparativo por Mes
		nTotVezes := Len(aMeses)
	Else
		If lEntid	//// se for comparativo x 6 entidades (em par‚metro)
			nTotVezes := Len(aEntid)
		Endif
	EndIf
Endif

Do Case
Case cAlias == 'CT3'
	If cHeader == 'CTT'
//nOrder 		:= 2
		cCadAlias1	:= 'CTT'
		cCadAlias2	:= 'CT1'
		cCodEnt1	:= 'CUSTO'
		cCodEnt2	:=	'CONTA'
		cCodSup1	:= 'CCSUP'
		cCodSup2	:= 'CTASUP'
		cMascara1	:= aSetOfBook[6]	//Mascara do Centro de Custo
		cMascara2	:= aSetOfBook[5]	//Mascara do Item
		nTamDesc1	:=	Len(CriaVar("CTT->CTT_DESC"+cMoeda))
		nTamDesc2	:=	Len(CriaVar("CT1->CT1_DESC"+cMoeda))
		cDescEnt	:= "DESCCC"
	EndIf
Case cAlias == 'CTV'
	cOrigem		:= 'CT4'
	If cHeader == 'CTT'		//Se for C.Custo/Item
		nOrder 		:= 2
		cCadAlias1	:= 'CTT'
		cCadAlias2	:= 'CTD'
		cCodEnt1	:= 'CUSTO'
		cCodEnt2	:=	'ITEM'
		cCodSup1	:= 'CCSUP'
		cCodSup2	:= 'ITSUP'
		cMascara1	:= aSetOfBook[6]	//Mascara do Centro de Custo
		cMascara2	:= aSetOfBook[7]	//Mascara do Item
		nTamDesc1	:=	Len(CriaVar("CTT->CTT_DESC"+cMoeda))
		nTamDesc2	:=	Len(CriaVar("CTD->CTD_DESC"+cMoeda))
		cDescEnt	:= "DESCCC"

	ElseIf cHeader == 'CTD' 	//Se for Item/C.Custo
		nOrder 		:= 1
		cCadAlias1	:= 'CTD'
		cCadAlias2	:= 'CTT'
		cCodEnt1	:= 'ITEM'
		cCodEnt2	:= 'CUSTO'
		cCodSup1	:= 'ITSUP'
		cCodSup2	:= 'CCSUP'
		cMascara1	:= aSetOfBook[7]	//Mascara do Item
		cMascara2	:= aSetOfBook[6]	//Mascara do Centro de Custo
		nTamDesc1	:=	Len(CriaVar("CTD->CTD_DESC"+cMoeda))
		nTamDesc2	:=	Len(CriaVar("CTT->CTT_DESC"+cMoeda))
		cDescEnt	:= "DESCITEM"
	EndIf
Case cAlias == 'CTW'
	cOrigem		:= 'CTI'
	If cHeader == 'CTH'//Se for Cl.Valor/C.Custo
		nOrder 		:= 1
		cCadAlias1	:= 'CTH'
		cCadAlias2	:= 'CTT'
		cCodEnt1	:= 'CLVL'
		cCodEnt2	:= 'CUSTO'
		cCodSup1	:= 'CLSUP'
		cCodSup2	:= 'CCSUP'
		cMascara1	:= aSetOfBook[8]	//Mascara da Classe de Valor
		cMascara2	:= aSetOfBook[6]	//Mascara do Centro de Custo
		nTamDesc1	:=	Len(CriaVar("CTH->CTH_DESC"+cMoeda))
		nTamDesc2	:=	Len(CriaVar("CTT->CTT_DESC"+cMoeda))
		cDescEnt	:= "DESCCLVL"
	ElseIf cHeader == 'CTT'//Se for C.Custo/Cl.Valor
		nOrder 		:= 2
		cCadAlias1	:= 'CTT'
		cCadAlias2	:= 'CTH'
		cCodEnt1	:= 'CUSTO'
		cCodEnt2	:= 'CLVL'
		cCodSup1  	:= 'CCSUP'
		cCodSup2	:= 'CLSUP'
		cMascara1	:= aSetOfBook[6]	//Mascara do Centro de Custo
		cMascara2	:= aSetOfBook[8]	//Mascara da Classe de Valor
		nTamDesc1	:=	Len(CriaVar("CTT->CTT_DESC"+cMoeda))
		nTamDesc2	:=	Len(CriaVar("CTH->CTH_DESC"+cMoeda))
		cDescEnt	:= "DESCCC"
	EndIf
Case cAlias == 'CTX'
	cOrigem		:= 'CTI'
	If cHeader == 'CTH'//Se for Cl.Valor/Item
		nOrder 		:= 2
		cCadAlias1	:= 'CTH'
		cCadAlias2	:= 'CTD'
		cCodEnt1	:= 'CLVL'
		cCodEnt2	:= 'ITEM'
		cCodSup1	:= 'CLSUP'
		cCodSup2	:= 'ITSUP'
		cMascara1	:= aSetOfBook[8]	//Mascara da Cl.Valor
		cMascara2	:= aSetOfBook[7]	//Mascara do Item Contab.
		nTamDesc1	:=	Len(CriaVar("CTH->CTH_DESC"+cMoeda))
		nTamDesc2	:=	Len(CriaVar("CTD->CTD_DESC"+cMoeda))
		cDescEnt	:= "DESCCLVL"
	ElseIf cHeader == 'CTD'//Se for Item/Cl.Valor
		nOrder		:= 1
		cCadAlias1	:= 'CTD'
		cCadAlias2	:= 'CTH'
		cCodEnt1	:=	'ITEM'
		cCodEnt2	:=	'CLVL'
		cCodSup1  	:=	'ITSUP'
		cCodSup2	:=	'CLSUP'
		cMascara1	:= aSetOfBook[7]	//Mascara do Item Contab.
		cMascara2	:= aSetOfBook[8]	//Mascara da Cl.Valor
		nTamDesc1	:=	Len(CriaVar("CTD->CTD_DESC"+cMoeda))
		nTamDesc2	:=	Len(CriaVar("CTH->CTH_DESC"+cMoeda))
		cDescEnt	:= "DESCITEM"
	EndIf

Case cAlias == 'CTD'     //// CASO SEJA INVERTIDO O cHeader x cAlias
	cOrigem		:= 'CT4'

	If cHeader == 'CTV'		//Se for C.Custo/Item
		cInd	:= "ITEM+CUSTO"
		cCadAlias1	:= 'CTT'
		cCadAlias2	:= 'CTD'
		cCodEnt1	:= 'CUSTO'
		cCodEnt2	:= 'ITEM'
		cCodSup1	:= 'CCSUP'
		cCodSup2	:= 'ITSUP'
		cMascara1	:= aSetOfBook[6]	//Mascara do Centro de Custo
		cMascara2	:= aSetOfBook[7]	//Mascara do Item
		nTamDesc1	:= Len(CriaVar("CTT->CTT_DESC"+cMoeda))
		nTamDesc2	:= Len(CriaVar("CTD->CTD_DESC"+cMoeda))
		cDescEnt	:= "DESCCC"
	ElseIf cHeader == 'CTX' 	//Se for Item x Classe de Valor
		cInd	:= "ITEM+CLVL"
		cCadAlias1	:= 'CTH'
		cCadAlias2	:= 'CTD'
		cCodEnt1	:= 'CLVL'
		cCodEnt2	:= 'ITEM'
		cCodSup1	:= 'CLSUP'
		cCodSup2	:= 'ITSUP'
		cMascara1	:= aSetOfBook[8]	//Mascara da Cl.Valor
		cMascara2	:= aSetOfBook[7]	//Mascara do Item Contab.
		nTamDesc1	:=	Len(CriaVar("CTH->CTH_DESC"+cMoeda))
		nTamDesc2	:=	Len(CriaVar("CTD->CTD_DESC"+cMoeda))
		cDescEnt	:= "DESCCLVL"
	EndIf

EndCase

cChave 		:= xFilial(cAlias)+cMoeda+cSaldos+cEntidIni1+cEntidIni2+dtos(dDataIni)
//bCond		:= {||&(cAlias+"->"+cAlias+"_FILIAL") == xFilial(cAlias) .And.	&(cAlias+"->"+cAlias+"_"+cCodEnt1) >= cEntidIni1 .And. &(cAlias+"->"+cAlias+"_"+cCodEnt1) <= cEntidFim1 }
bCond1		:= {||&(cCadAlias1+"->"+cCadAlias1+"_FILIAL") == xFilial(cCadAlias1) .And. &(cCadAlias1+"->"+cCadAlias1+"_"+cCodEnt1) >= cEntidIni1 .And. &(cCadAlias1+"->"+cCadAlias1+"_"+cCodEnt1) <= cEntidFim1 }
bCond2		:= {||&(cCadAlias2+"->"+cCadAlias2+"_FILIAL") == xFilial(cCadAlias2) .And. &(cCadAlias2+"->"+cCadAlias2+"_"+cCodEnt2) >= cEntidIni2 .And. &(cCadAlias2+"->"+cCadAlias2+"_"+cCodEnt2) <= cEntidFim2 }


// Grava sinteticas
dbSelectArea("cArqTmp")
If ValType(oMeter) == "O"
	oMeter:SetTotal(cArqTmp->(RecCount()))
	oMeter:Set(0)
EndIf
dbGoTop()

While!Eof()
	nMeter++
	If nMeter%1000 = 0
		If ValType(oMeter) == "O"
   			oMeter:Set(nMeter)
	  	EndIf
	EndIf

	nRegTmp := Recno()
	aMovimento	:= {}
	For nVezes	:= 1 to nTotVezes
		Aadd(aMovimento, 0)
	Next

	For nVezes := 1 to nTotVezes
		aMovimento[nVezes] := &("COLUNA"+Alltrim(Str(nVezes,2)))
	Next

	dbSelectArea(cCadAlias2)
	dbSetOrder(1)
	If Empty(&(cCadAlias2+"->"+cCadAlias2+"_"+cCodSup2))
		dbSelectArea("cArqTmp")
		Replace NIVEL1 With .T.
		dbSelectArea(cCadAlias2)
	EndIf
	MsSeek(xFilial(cCadAlias2)+ &("cArqTmp->"+cCodSup2))

	While !Eof() .And. &(cCadAlias2+"->"+cCadAlias2+"_FILIAL") == xFilial()

		cEntid1	 := &("cArqTmp->"+cCodEnt1)
		cDesc1	 := &("cArqTmp->"+cDescEnt)
		cEntSup2 := &(cCadAlias2+"->"+cCadAlias2+"_"+cCodEnt2)

		cDescEnt2	:= (cCadAlias2+"->"+cCadAlias2+"_DESC")
		cDesc2		:= &(cDescEnt2+cMoeda)
		If Empty(cDesc2)	// Caso nao preencher descricao da moeda selecionada
			cDesc2	:= &(cDescEnt2+"01")
		Endif

		If lEntid									/// SE FOR ENTIDADE X 6 CODIGOS DE ENTIDADE
			cSeek 		:= cEntSup2//cEntid1		/// PROCURA SOMENTE A ENTIDADE SUPERIOR POIS PODE N√O ESTAR AMARRADO A 1™ ENTIDADE
		Else
			cSeek 		:= cEntid1+cEntSup2
		Endif

		dbSelectArea(cCadAlias1)
		dbSetOrder(1)
		MsSeek(xFilial(cCadAlias1)+cEntid1)

		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		If !MsSeek(cSeek)
			RecLock("cArqTmp",.T.)
			Do Case
			Case cAlias == 'CT3'
				If cHeader == 'CTT'
					Replace CUSTO   	With cEntid1
					Replace DESCCC		With cDesc1
					Replace TIPOCC 		With CTT->CTT_CLASSE
					Replace CCSUP 		With CTT->CTT_CCSUP
					Replace CCRES		With CTT->CTT_RES
					Replace CONTA		With cEntSup2
					Replace DESCCTA 	With cDesc2
					Replace TIPOCONTA	With CT1->CT1_CLASSE
					Replace CTASUP 		With CT1->CT1_CTASUP
					Replace CTARES 		With CT1->CT1_RES
					Replace GRUPO 		With CT1->CT1_GRUPO
				EndIf
			Case cAlias == 'CTV'
				If cHeader	== 'CTT'	//Se for Centro de Custo/Item
					Replace CUSTO   	With cEntid1
					Replace DESCCC		With cDesc1
					Replace TIPOCC 		With CTT->CTT_CLASSE
					Replace CCSUP 		With CTT->CTT_CCSUP
					Replace CCRES		With CTT->CTT_RES
					Replace ITEM 		With cEntSup2
					Replace DESCITEM	With cDesc2
					Replace TIPOITEM 	With CTD->CTD_CLASSE
					Replace ITSUP  		With CTD->CTD_ITSUP
					Replace ITEMRES		With CTD->CTD_RES
				ElseIf cHeader == 'CTD'	//Se for Item/C.Custo
					Replace ITEM 		With cEntid1
					Replace DESCITEM	With cDesc1
					Replace TIPOITEM 	With CTD->CTD_CLASSE
					Replace ITSUP  		With CTD->CTD_ITSUP
					Replace ITEMRES		With CTD->CTD_RES
					Replace CUSTO   	With cEntSup2
					Replace DESCCC		With cDesc2
					Replace TIPOCC 		With CTT->CTT_CLASSE
					Replace CCSUP 		With CTT->CTT_CCSUP
					Replace CCRES		With CTT->CTT_RES
				EndIf
			Case cAlias == 'CTW'
				If cHeader	== 'CTH'		//Se for Cl.Valor/C.Custo
					Replace CLVL    	With cEntid1
					Replace DESCCLVL	With cDesc1
					Replace TIPOCLVL 	With CTH->CTH_CLASSE
					Replace CLSUP    	With CTH->CTH_CLSUP
					Replace CLVLRES		With CTH->CTH_RES
					Replace CUSTO   	With cEntSup2
					Replace DESCCC		With cDesc2
					Replace TIPOCC 		With CTT->CTT_CLASSE
					Replace CCSUP 		With CTT->CTT_CCSUP
					Replace CCRES		With CTT->CTT_RES
				ElseIf cHeader	== 'CTT'	//Se for C.Custo/Cl.Valor
					Replace CUSTO   	With cEntid1
					Replace DESCCC		With cDesc1
					Replace TIPOCC 		With CTT->CTT_CLASSE
					Replace CCSUP 		With CTT->CTT_CCSUP
					Replace CCRES		With CTT->CTT_RES
					Replace CLVL    	With cEntSup2
					Replace DESCCLVL	With cDesc2
					Replace TIPOCLVL 	With CTH->CTH_CLASSE
					Replace CLSUP    	With CTH->CTH_CLSUP
					Replace CLVLRES		With CTH->CTH_RES
				EndIf
			Case cAlias == 'CTX'
				If cHeader == 'CTH'	//Se for Cl.Valor/Item
					Replace CLVL    	With cEntid1
					Replace DESCCLVL	With cDesc1
					Replace TIPOCLVL 	With CTH->CTH_CLASSE
					Replace CLSUP    	With CTH->CTH_CLSUP
					Replace CLVLRES		With CTH->CTH_RES
					Replace ITEM		With cEntSup2
					Replace DESCITEM	With cDesc2
					Replace TIPOITEM 	With CTD->CTD_CLASSE
					Replace ITSUP  		With CTD->CTD_ITSUP
					Replace ITEMRES		With CTD->CTD_RES
				ElseIf cHeader	== 'CTD'	//Se for Item/Cl.Valor
					Replace ITEM		With cEntid1
					Replace DESCITEM	With cDesc1
					Replace TIPOITEM 	With CTD->CTD_CLASSE
					Replace ITSUP  		With CTD->CTD_ITSUP
					Replace ITEMRES		With CTD->CTD_RES
					Replace CLVL    	With cEntSup2
					Replace DESCCLVL	With cDesc2
					Replace TIPOCLVL 	With CTH->CTH_CLASSE
					Replace CLSUP    	With CTH->CTH_CLSUP
					Replace CLVLRES		With CTH->CTH_RES
				Endif

			Case cAlias == 'CTD'		/// Se for cHeader x cAlias invertido
				If cHeader	== 'CTV'		//Se for Item x C.Custo
					Replace CUSTO   	With cEntid1
					Replace DESCCC		With cDesc1
					Replace TIPOCC 		With CTT->CTT_CLASSE
					Replace CCSUP 		With CTT->CTT_CCSUP
					Replace CCRES		With CTT->CTT_RES
					Replace ITEM 		With cEntSup2
					Replace DESCITEM	With cDesc2
					Replace TIPOITEM 	With CTD->CTD_CLASSE
					Replace ITSUP  		With CTD->CTD_ITSUP
					Replace ITEMRES		With CTD->CTD_RES
				ElseIf cHeader	== 'CTX'	//Se for ITEM X Cl.Valor
					Replace CLVL    	With cEntid1
					Replace DESCCLVL	With cDesc1
					Replace TIPOCLVL 	With CTH->CTH_CLASSE
					Replace CLSUP    	With CTH->CTH_CLSUP
					Replace CLVLRES		With CTH->CTH_RES
					Replace ITEM		With cEntSup2
					Replace DESCITEM	With cDesc2
					Replace TIPOITEM 	With CTD->CTD_CLASSE
					Replace ITSUP  		With CTD->CTD_ITSUP
					Replace ITEMRES		With CTD->CTD_RES
				EndIf
			EndCase
		Else
			RecLock("cArqTmp",.F.)
		EndIf

		For nVezes := 1 to nTotVezes
			If cTpVlr == 'M'
				Replace &("COLUNA"+	Alltrim(Str(nVezes,2))) With (&("COLUNA"+Alltrim(Str(nVezes,2)))+aMovimento[nVezes])
			EndIf
    	Next

		dbSelectArea(cCadAlias2)
		If Empty(&(cCadAlias2+"->"+cCadAlias2+"_"+cCodSup2))
			dbSelectArea("cArqTmp")
			Replace NIVEL1 With .T.
			dbSelectArea(cCadAlias2)
			Exit
		EndIf

		dbSelectArea(cCadAlias2)
		MsSeek(xFilial(cCadAlias2)+ &("cArqTmp->"+cCodSup2))
	EndDo
	dbSelectArea("cArqTmp")
	dbGoto(nRegTmp)
	dbSkip()
EndDo
RestArea(aSaveArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CT7CmpQry
Retorna o Alias TRBTMP atravÈs de query com a composiÁ„o de saldos por conta

@author Alvaro Camillo Neto


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CT7CmpQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,;
					cMoeda,cTpSld1,cTpSld2,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					cSegAte,lVariacao0,nDivide,nGrupo,bVariacao,cIdent,lCt1Sint,cString,cFILUSU)

CQ0CmpQry(@dDataIni,@dDataFim,@cContaIni,@cContaFim,@cMoeda,@cTpSld1,@cTpSld2,@aSetOfBook,@cSegmento,@cSegIni,@cSegFim,@cFiltSegm,@cSegAte,@lVariacao0,@nDivide,@nGrupo,@bVariacao,@cIdent,@lCt1Sint,@cString,@cFILUSU)

Return



//-------------------------------------------------------------------
/*{Protheus.doc} CT3CmpQry
Retorna alias TRBTMP com a composiÁ„o dos saldos C.Custo x Conta Contabil

@author Alvaro Camillo Neto


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CT3CmpQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,;
					cMoeda,cTpSld1,cTpSld2,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					cSegAte,lVariacao0,nDivide,nGrupo,bVariacao,cIdent,lCt1Sint,cString,cFILUSU)

CQ2CmpQry(@dDataIni,@dDataFim,@cContaIni,@cContaFim,@cCCIni,@cCCFim,@cMoeda,@cTpSld1,@cTpSld2,@aSetOfBook,@lVariacao0,@cString,@cFILUSU)

Return


//-------------------------------------------------------------------
/*{Protheus.doc} CTVCompQry
Obtem o saldo dos C.Custo x Item Contabil retornando um alias TRBTMP executado com a query

@author Alvaro Camillo Neto


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CTVCompQry(dDataIni,dDataFim,cCCIni,cCCFim,cItemIni,cItemFim,cMoeda,cSaldos,aSetOfBook,lImpAntLP,dDataLP,lMeses,aMeses,lVlrZerado,lEntid,aEntid,cHeader,cString,cFILUSU)
Local cQuery		:= ""
Local aAreaQry		:= {}		/// array com a posiÁ„o no arquivo original
Local aTamVlr		:= TAMSX3("CT2_VALOR")
Local nVezes	    := 0
Local nStr			:= 1
Local nMes			:= 1
Local nColunas		:= 1

DEFAULT lMeses		:= .F.
DEFAULT lVlrZerado	:= .F.
DEFAULT lEntid		:= .F.

aAreaQry := GetArea()

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USU¡RIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USU¡RIO
If !Empty(cFILUSU)									//// SE O FILTRO DE USU¡RIO NAO ESTIVER VAZIO
	aStrSTRU := (cString)->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
////////////////////////////////////////////////////////////


If lEntid
	If cHeader == "CTD"
		cQuery += " SELECT * FROM ("
		cQuery += " SELECT CTD_ITEM ITEM, CTD_RES ITEMRES, CTD_DESC"+cMoeda+" DESCITEM, CTD_CLASSE TIPOITEM, CTD_ITSUP ITSUP, "
		cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY

		For nVezes := 1 to Len(aEntid)
			cQuery += "(SELECT ISNULL(SUM(CQ5_CREDIT) - SUM(CQ5_DEBITO),0) "
			cQuery += "	FROM "+ RetSqlName("CQ5") + " CQ5 "
			cQuery += "	WHERE CQ5_FILIAL =  '"+xFilial("CQ5")+"' "
			cQuery += "	AND CQ5_MOEDA = '"+cMoeda+"' "
			cQuery += "	AND CQ5_TPSALD = '"+cSaldos+"' "
			cQuery += "	AND CQ5_ITEM = ARQ.CTD_ITEM "
			cQuery += " AND CQ5_CCUSTO = '"+aEntid[nVezes]+"' "
			cQuery += " AND CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
			If lImpAntLP .and. dDataLP >= dDataINI
				cQuery += "	AND CQ5_LP <> 'Z' "
			Endif
			cQuery += " AND CQ5.D_E_L_E_T_ = '') COLUNA"+ALLTRIM(STR(nVezes))
			If nVezes <  Len(aEntid)
				cQuery += ","
			Endif
		Next
		cQuery += " FROM "+RetSqlName("CTD") + " ARQ "
		cQuery += " WHERE ARQ.CTD_FILIAL = '"+xFilial("CTD")+"' "
		cQuery += "	AND ARQ.CTD_ITEM BETWEEN '" +cItemIni+"' AND '"+cItemFim+"' "
		cQuery += "	AND ARQ.CTD_CLASSE = '2' "

		If !Empty(aSetOfBook[1])
			cQuery += " AND ARQ.CTD_BOOK LIKE '%"+aSetOfBook[1]+"%' "
		Endif
		cQuery += "	AND ARQ.D_E_L_E_T_ = '' "
		cQuery += " 	) SLAARQ"

		If !lVlrZerado
			If Len(aEntid) > 0
				cQuery += " WHERE ( "
				For nVezes := 1 to Len(aEntid)
					cQuery += "	 COLUNA"+ALLTRIM(STR(nVezes))+ " <> 0 "+ CRLF
					If nVezes < Len(aEntid)
						cQuery += " OR "
					Endif
				Next
				cQuery += " ) "
			Endif
		Endif
	EndIf
Else
	If cHeader == "CTT"
		cQuery += " SELECT * FROM ("
		cQuery += " SELECT CTT_CUSTO CUSTO, CTD_ITEM ITEM, CTT_RES CCRES, CTT_DESC"+cMoeda+" DESCCC, CTT_CLASSE TIPOCC, CTT_CCSUP CCSUP, "
		cQuery += " 	CTD_RES ITEMRES, CTD_DESC"+cMoeda+" DESCITEM, CTD_CLASSE TIPOITEM, CTD_ITSUP ITSUP, "

		If CtbExDtFim("CTD")
			cQuery += " CTD_DTEXSF CTDDTEXSF, "
		EndIf


		cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY

		If lMeses .and. Len(aMeses) > 0
			For nMes := 1 to Len(aMeses)
				cQuery += "  	(SELECT ISNULL(SUM(CQ5_CREDIT) - SUM(CQ5_DEBITO),0) "
				cQuery += " 		 	FROM "+RetSqlName("CQ5")+" CQ5 "
				cQuery += "   			WHERE CQ5_FILIAL = '"+xFilial("CQ5")+"' "
				cQuery += "   			AND CQ5_MOEDA = '"+cMoeda+"' "
				cQuery += "   			AND CQ5_TPSALD = '"+cSaldos+"' "
				cQuery += "  			AND CQ5_ITEM = ARQ2.CTD_ITEM "
				cQuery += "   			AND CQ5_CCUSTO = ARQ.CTT_CUSTO	 "
				cQuery += "    			AND CQ5_DATA BETWEEN '"+DTOS(aMeses[nMes,2])+"' AND '"+DTOS(aMeses[nMes,3])+"' "
				If lImpAntLP .and. dDataLP >= aMeses[nMes,2]
					cQuery += "	AND CQ5_LP <> 'Z' "
				Endif
				cQuery += "   			AND CQ5.D_E_L_E_T_ = '') COLUNA"+ALLTRIM(STR(nMes))
				If nMes < Len(aMeses)
					cQuery += ","
				Endif
			Next
		Else
			cQuery += "  	(SELECT ISNULL(SUM(CQ5_CREDIT) - SUM(CQ5_DEBITO),0) "
			cQuery += " 		 	FROM "+RetSqlName("CQ5")+" CQ5 "
			cQuery += "   			WHERE CQ5_FILIAL = '"+xFilial("CQ5")+"' "
			cQuery += "   			AND CQ5_MOEDA = '"+cMoeda+"' "
			cQuery += "   			AND CQ5_TPSALD = '"+cSaldos+"' "
			cQuery += "  			AND CQ5_ITEM = ARQ2.CTD_ITEM "
			cQuery += "   			AND CQ5_CCUSTO = ARQ.CTT_CUSTO	 "
			cQuery += "    			AND CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
			If lImpAntLP .and. dDataLP >= dDataINI
				cQuery += "	AND CQ5_LP <> 'Z' "
			Endif
			cQuery += "   			AND CQ5.D_E_L_E_T_ = '') COLUNA1 "
		Endif

		cQuery += " FROM "+RetSqlName("CTT")+" ARQ, "+RetSqlName("CTD")+" ARQ2 "
		cQuery += " WHERE ARQ.CTT_FILIAL = '"+xFilial("CTT")+"'  	"
		cQuery += " AND ARQ.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"' "
		cQuery += " AND ARQ.CTT_CLASSE = '2'  	"

		If !Empty(aSetOfBook[1])
			cQuery += " AND ARQ.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%' 	"
		Endif

		cQuery += " AND ARQ2.CTD_FILIAL = '"+xFilial("CTD")+"'  	"
		cQuery += " AND ARQ2.CTD_ITEM BETWEEN '"+cItemIni+"' AND '"+cItemFim+"'  	"
		cQuery += " AND ARQ2.CTD_CLASSE = '2'  	"

		If !Empty(aSetOfBook[1])
			cQuery += " AND ARQ2.CTD_BOOK LIKE '%"+aSetOfBook[1]+"%' "
		Endif

		cQuery += " AND ARQ.D_E_L_E_T_ = ''  	"
		cQuery += " AND ARQ2.D_E_L_E_T_ = ''  	"

		cQuery += " 	) SLAARQ"

		If !lVlrZerado
			cQuery += " WHERE ( "
			If lMeses .and. Len(aMeses) > 0
				For nMes := 1 to Len(aMeses)
					cQuery += "	 COLUNA"+ALLTRIM(STR(nMes))+ " <> 0 "+ CRLF
					If nMes < Len(aMeses)
						cQuery += " OR "
					Endif
				Next
			Else
				cQuery += " COLUNA1 <> 0 "+ CRLF
			Endif
			cQuery += " ) "
		Endif
	EndIf

EndIf

cQuery := ChangeQuery(cQuery)

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)
If lMeses
	For nColunas := 1 to Len(aMeses)
		TcSetField("TRBTMP","COLUNA"+Str(nColunas,Iif(nColunas>9,2,1)),"N",aTamVlr[1],aTamVlr[2])
	Next
ElseIf lEntid
	For nColunas := 1 to Len(aEntid)
		TcSetField("TRBTMP","COLUNA"+Str(nColunas,Iif(nColunas>9,2,1)),"N",aTamVlr[1],aTamVlr[2])
	Next
Else
	TcSetField("TRBTMP","COLUNA1","N",aTamVlr[1],aTamVlr[2])
EndIf

RestArea(aAreaQry)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CTXCompQry
Retorna Alias TRBTMP com a composicao de Saldos Cl.Valor x Item Contabil

@author Alvaro Camillo Neto


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CTXCompQry(dDataIni,dDataFim,cItemIni,cItemFim,cClVlIni,cClVlFim,cMoeda,cSaldos,aSetOfBook,lImpAntLP,dDataLP,lMeses,aMeses,lVlrZerado,lEntid,aEntid,cHeader,cString,cFILUSU)

Local cQuery		:= ""
Local aAreaQry		:= {}		/// array com a posiÁ„o no arquivo original
Local aTamVlr		:= TAMSX3("CT2_VALOR")
Local nVezes	    := 0
Local nStr			:= 1
Local nMes 			:= 1
Local nColunas		:= 1

DEFAULT lMeses		:= .F.
DEFAULT lVlrZerado	:= .F.
DEFAULT lEntid		:= .F.

aAreaQry := GetArea()

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USU¡RIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USU¡RIO
If !Empty(cFILUSU)									//// SE O FILTRO DE USU¡RIO NAO ESTIVER VAZIO
	aStrSTRU := (cString)->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
////////////////////////////////////////////////////////////

If lEntid     //Comparativo por 6 Entidades
	If cHeader == "CTD"
		cQuery += " SELECT * FROM ("
		cQuery += " SELECT CTD_ITEM ITEM, CTD_RES ITEMRES, CTD_DESC"+cMoeda+" DESCITEM, CTD_CLASSE TIPOITEM, CTD_ITSUP ITSUP, "
		cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY

		For nVezes := 1 to Len(aEntid)
			cQuery += "(SELECT ISNULL(SUM(CQ7_CREDIT) - SUM(CQ7_DEBITO),0) "
			cQuery += "	FROM "+ RetSqlName("CQ7") + " CQ7 "
			cQuery += "	WHERE CQ7_FILIAL =  '"+xFilial("CQ7")+"' "
			cQuery += "	AND CQ7_MOEDA = '"+cMoeda+"' "
			cQuery += "	AND CQ7_TPSALD = '"+cSaldos+"' "
			cQuery += "	AND CQ7_ITEM = ARQ.CTD_ITEM "
			cQuery += " AND CQ7_CLVL = '"+aEntid[nVezes]+"' "
			cQuery += " AND CQ7_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
			If lImpAntLP .and. dDataLP >= dDataINI
				cQuery += "	AND CQ7_LP <> 'Z' "
			Endif
			cQuery += " AND CQ7.D_E_L_E_T_ = '') COLUNA"+ALLTRIM(STR(nVezes))
			If nVezes <  Len(aEntid)
				cQuery += ","
			Endif
		Next
		cQuery += " FROM "+RetSqlName("CTD") + " ARQ "
		cQuery += " WHERE ARQ.CTD_FILIAL = '"+xFilial("CTD")+"' "
		cQuery += "	AND ARQ.CTD_ITEM BETWEEN '" +cItemIni+"' AND '"+cItemFim+"' "
		cQuery += "	AND ARQ.CTD_CLASSE = '2' "

		If !Empty(aSetOfBook[1])
			cQuery += " AND ARQ.CTD_BOOK LIKE '%"+aSetOfBook[1]+"%' "
		Endif
		cQuery += "	AND ARQ.D_E_L_E_T_ = '' "
		cQuery += " 	) SLAARQ"

		If !lVlrZerado
			If Len(aEntid) > 0
				cQuery += " WHERE ( "
				For nVezes := 1 to Len(aEntid)
					cQuery += "	 COLUNA"+ALLTRIM(STR(nVezes))+ " <> 0 "+ CRLF
					If nVezes < Len(aEntid)
						cQuery += " OR "
					Endif
				Next
				cQuery += " ) "
			Endif
		Endif
	EndIf
Else
	cQuery += " SELECT * FROM ("
	cQuery += " SELECT CTH_CLVL CLVL, CTD_ITEM ITEM, CTH_RES CLVLRES, CTH_DESC"+cMoeda+" DESCCLVL, CTH_CLASSE TIPOCLVL, CTH_CLSUP CLSUP, "
	cQuery += " 	CTD_RES ITEMRES, CTD_DESC"+cMoeda+" DESCITEM, CTD_CLASSE TIPOITEM, CTD_ITSUP ITSUP, "
	cQuery += cCAMPUSU						/// ADICIONA OS CAMPOS DE USUARIO

	If lMeses .and. Len(aMeses) > 0
		For nMes := 1 to Len(aMeses)
			cQuery += "  	(SELECT ISNULL(SUM(CQ7_CREDIT) - SUM(CQ7_DEBITO),0) "
			cQuery += " 		 	FROM "+RetSqlName("CQ7")+" CQ7 "
			cQuery += "   			WHERE CQ7_FILIAL = '"+xFilial("CQ7")+"' "
			cQuery += "   			AND CQ7_MOEDA = '"+cMoeda+"' "
			cQuery += "   			AND CQ7_TPSALD = '"+cSaldos+"' "
			cQuery += "  			AND CQ7_ITEM = ARQ2.CTD_ITEM "
			cQuery += "   			AND CQ7_CLVL = ARQ.CTH_CLVL	 "
			cQuery += "    			AND CQ7_DATA BETWEEN '"+DTOS(aMeses[nMes,2])+"' AND '"+DTOS(aMeses[nMes,3])+"' "
			If lImpAntLP .and. dDataLP >= aMeses[nMes,2]
				cQuery += "	AND CQ7_LP <> 'Z' "
			Endif
			cQuery += "   			AND CQ7.D_E_L_E_T_ = '') COLUNA"+ALLTRIM(STR(nMes))
			If nMes < Len(aMeses)
				cQuery += ","
			Endif
		Next
	Else
		cQuery += "  	(SELECT ISNULL(SUM(CQ7_CREDIT) - SUM(CQ7_DEBITO),0) "
		cQuery += " 		 	FROM "+RetSqlName("CQ7")+" CQ7 "
		cQuery += "   			WHERE CQ7_FILIAL = '"+xFilial("CQ7")+"' "
		cQuery += "   			AND CQ7_MOEDA = '"+cMoeda+"' "
		cQuery += "   			AND CQ7_TPSALD = '"+cSaldos+"' "
		cQuery += "  			AND CQ7_ITEM = ARQ2.CTD_ITEM "
		cQuery += "   			AND CQ7_CLVL = ARQ.CTH_CLVL	 "
		cQuery += "    			AND CQ7_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
		If lImpAntLP .and. dDataLP >= dDataINI
			cQuery += "	AND CQ7_LP <> 'Z' "
		Endif
		cQuery += "   			AND CQ7.D_E_L_E_T_ = '') COLUNA1 "
	Endif

	cQuery += " FROM "+RetSqlName("CTH")+" ARQ, "+RetSqlName("CTD")+" ARQ2 "
	cQuery += " WHERE ARQ.CTH_FILIAL = '"+xFilial("CTH")+"'  	"
	cQuery += " AND ARQ.CTH_CLVL BETWEEN '"+cClvlIni+"' AND '"+cCLVlFim+"' "
	cQuery += " AND ARQ.CTH_CLASSE = '2'  	"

	If !Empty(aSetOfBook[1])
		cQuery += " AND ARQ.CTH_BOOK LIKE '%"+aSetOfBook[1]+"%' 	"
	Endif

	cQuery += " AND ARQ2.CTD_FILIAL = '"+xFilial("CTD")+"'  	"
	cQuery += " AND ARQ2.CTD_ITEM BETWEEN '"+cItemIni+"' AND '"+cItemFim+"'  	"
	cQuery += " AND ARQ2.CTD_CLASSE = '2'  	"

	If !Empty(aSetOfBook[1])
		cQuery += " AND ARQ2.CTD_BOOK LIKE '%"+aSetOfBook[1]+"%' "
	Endif

	cQuery += " AND ARQ.D_E_L_E_T_ = ''  	"
	cQuery += " AND ARQ2.D_E_L_E_T_ = ''  	"
	cQuery += " 	) SLAARQ"

	If !lVlrZerado
		cQuery += " WHERE ( "
		If lMeses .and. Len(aMeses) > 0
			For nMes := 1 to Len(aMeses)
				cQuery += "	 COLUNA"+ALLTRIM(STR(nMes))+ " <> 0 "+ CRLF
				If nMes < Len(aMeses)
					cQuery += " OR "
				Endif
			Next
		Else
			cQuery += " COLUNA1 <> 0 "+ CRLF
		Endif
		cQuery += " ) "
	Endif
EndIf

cQuery := ChangeQuery(cQuery)

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)
If lEntid
	For nColunas := 1 to Len(aEntid)
		TcSetField("TRBTMP","COLUNA"+Str(nColunas,Iif(nColunas>9,2,1)),"N",aTamVlr[1],aTamVlr[2])
	Next
Else
	If lMeses
		For nColunas := 1 to Len(aMeses)
			TcSetField("TRBTMP","COLUNA"+Str(nColunas,Iif(nColunas>9,2,1)),"N",aTamVlr[1],aTamVlr[2])
		Next
	Else
		TcSetField("TRBTMP","COLUNA1","N",aTamVlr[1],aTamVlr[2])
	EndIf
EndIf

RestArea(aAreaQry)


Return

//-------------------------------------------------------------------
/*{Protheus.doc} CTUCmpQry
Retorna alias TRBTMP com a composiÁ„o dos saldos por Entid. C.Custo, Item ou CL.Valor

@author Alvaro Camillo Neto


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CTUCmpQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,;
					cMoeda,cTpSld1,cTpSld2,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					cSegAte,lVariacao0,nDivide,nGrupo,bVariacao,cIdent,lCt1Sint,cString,cFILUSU)

CQ8CmpQry(@dDataIni,@dDataFim,@cCCIni,@cCCFim,@cItemIni,@cItemFim,@cClvlIni,@cClVlFim,@cMoeda,@cTpSld1,@cTpSld2,@aSetOfBook,@lVariacao0,@cIdent,@cString,@cFILUSU)

Return

/*

//-------------------------------------------------------------------
/*{Protheus.doc} CT3CompQry
Obtem o saldo dos C.Custo x Conta retornando um alias TRBTMP executado com a query

@author Alvaro Camillo Neto


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CT3CompQry(dDataIni,dDataFim,cCCIni,cCCFim,cContaIni,cContaFim,cMoeda,cSaldos,aSetOfBook,lImpAntLP,dDataLP,lMeses,aMeses,lVlrZerado,lEntid,aEntid,cHeader,cString,cFILUSU,lAcum)

CQ2CompQry(@dDataIni,@dDataFim,@cCCIni,@cCCFim,@cContaIni,@cContaFim,@cMoeda,@cSaldos,@aSetOfBook,@lImpAntLP,@dDataLP,@lMeses,@aMeses,@lVlrZerado,@lEntid,@aEntid,@cHeader,@cString,@cFILUSU,@lAcum)


Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Program   ≥SupCompMes≥ Autor ≥ Simone Mie Sato       ≥ Data ≥ 24.06.04 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Gerar Arquivo Temporario para Comparativo do CT3.           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ .T. / .F.                                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpO1 = Objeto oMeter                                      ≥±±
±±≥          ≥ ExpO2 = Objeto oText                                       ≥±±
±±≥          ≥ ExpO3 = Objeto oDlg                                        ≥±±
±±≥          ≥ ExpL1 = lEnd                                               ≥±±
±±≥          ≥ ExpD1 = Data Inicial                                       ≥±±
±±≥          ≥ ExpD2 = Data Final                                         ≥±±
±±≥          ≥ ExpC1 = Conta Inicial                                      ≥±±
±±≥          ≥ ExpC2 = Conta Final                                        ≥±±
±±≥          ≥ ExpC3 = Classe de Valor Inicial                            ≥±±
±±≥          ≥ ExpC4 = Classe de Valor Final                              ≥±±
±±≥          ≥ ExpC5 = Moeda		                                      ≥±±
±±≥          ≥ ExpC6 = Saldo	                                          ≥±±
±±≥          ≥ ExpA1 = Set Of Book	                                      ≥±±
±±≥          ≥ ExpN1 = Tamanho da descricao da conta	                  ≥±±
±±≥          ≥ ExpC7 = Ate qual segmento sera impresso (nivel)			  ≥±±
±±≥          ≥ ExpC8 = Filtra por Segmento		                          ≥±±
±±≥          ≥ ExpC9 = Segmento Inicial		                              ≥±±
±±≥          ≥ ExpC10= Segmento Final  		                              ≥±±
±±≥          ≥ ExpC11= Segmento Contido em  	                          ≥±±
±±≥          ≥ ExpL12= Se imprime total acumulado	                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function SupCompMes(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
				cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
				lNImpMov,cAlias,lCusto,lItem,lClvl,lAtSldBase,lAtSldCmp,nInicio,nFinal,cFilDe,;
				cFilAte,lImpAntLP,dDataLP,nDivide,cTpVlr,lFiliais,aFiliais,lMeses,aMeses,lVlrZerado,lEntid,aEntid)

Local aSaveArea 	:= GetArea()
Local lRet			:= .T.
Local cAliasTEMP	:= _oTempTable:GetAlias()
Local cTabTEMP		:= _oTempTable:GetRealName()
Local cProc			:= ""
Local cQuery		:= ""
Local nTamConta		:= TamSX3("CT1_CONTA")[1]
Local nTamCusto		:= TamSX3("CTT_CUSTO")[1]
Local cTabCT1		:= ""
Local cAliasCT1		:= ""
Local cTabCTT		:= ""
Local cAliasCTT		:= ""
Local lDB2			:= Upper(AllTrim(TCGetDb())) == "DB2"

Default lEntid 		:= .F.
Default aEntid		:= {}
Default lFiliais	:= .F.
Default aFiliais	:= {}
Default lMeses		:= .F.
Default aMeses		:= {}


//-----------------------------------------------------------
// Cria tabela temporaria com a estrutura do centro de custo
//-----------------------------------------------------------
If lRet
	lRet := CTSPCTTSup(@cAliasCTT,@cTabCTT,cEntidIni1,cEntidFim1,cMoeda)
EndIf

//----------------------------------------------------------
// Cria tabela temporaria com a estrutura da conta cont·bil
//----------------------------------------------------------
If lRet
	lRet := CTSPCT1Sup(@cAliasCT1,@cTabCT1,cEntidIni2,cEntidFim2,cMoeda)
EndIf

//-------------------------------------------------------------------------------
// Procedure de composiÁ„o dos saldos sintÈticos
//-------------------------------------------------------------------------------
If lRet

	cProc := CriaTrab(,.F.) + "SUPCOMPMES_" + cEmpAnt

	cQuery := "	Create Procedure " + cProc + " ("+CRLF

	cQuery += "		@OUT_RET char(1) OutPut )"+CRLF

	cQuery += "	AS"+CRLF

	//----------------------------------------------
	// Variavel para definir quando È Insert/Update
	//----------------------------------------------
	cQuery += "	declare @iRecno integer"+CRLF

	//------------------------------------------------------------------
	// Variaveis para armazenar o retorno da query da tabela temporaria
	//------------------------------------------------------------------
	cQuery += "	declare @cCUSTO    CHAR( "+StrZero(nTamCusto,3)+" )"+CRLF
	cQuery += "	declare @cCCSUP    CHAR( "+StrZero(nTamCusto,3)+" )"+CRLF
	cQuery += "	declare @cCONTA    CHAR( "+StrZero(nTamConta,3)+" )"+CRLF
	cQuery += "	declare @cCTASUP   CHAR( "+StrZero(nTamConta,3)+" )"+CRLF
	cQuery += "	declare @cNIVEL1   CHAR(1)"+CRLF
	cQuery += "	declare @nCOLUNA1  FLOAT"+CRLF
	cQuery += "	declare @nCOLUNA2  FLOAT"+CRLF
	cQuery += "	declare @nCOLUNA3  FLOAT"+CRLF
	cQuery += "	declare @nCOLUNA4  FLOAT"+CRLF
	cQuery += "	declare @nCOLUNA5  FLOAT"+CRLF
	cQuery += "	declare @nCOLUNA6  FLOAT"+CRLF
	cQuery += "	declare @nCOLUNA7  FLOAT"+CRLF
	cQuery += "	declare @nCOLUNA8  FLOAT"+CRLF
	cQuery += "	declare @nCOLUNA9  FLOAT"+CRLF
	cQuery += "	declare @nCOLUNA10 FLOAT"+CRLF
	cQuery += "	declare @nCOLUNA11 FLOAT"+CRLF
	cQuery += "	declare @nCOLUNA12 FLOAT"+CRLF

	//----------------------------------------------------------------
	// Variaveis para armazenar o retorno da query de centro de custo
	//----------------------------------------------------------------
	cQuery += "	declare @cCTT_ID     CHAR( "+StrZero(nTamCusto              ,3)+" )"+CRLF
	cQuery += "	declare @cCTT_CUSTO  CHAR( "+StrZero(nTamCusto              ,3)+" )"+CRLF
	cQuery += "	declare @cCTT_CCSUP  CHAR( "+StrZero(nTamCusto              ,3)+" )"+CRLF
	cQuery += "	declare @cCTT_DESC   CHAR( "+StrZero(TamSX3("CTT_DESC01")[1],3)+" )"+CRLF
	cQuery += "	declare @cCTT_RES    CHAR( "+StrZero(TamSX3("CTT_RES")[1]   ,3)+" )"+CRLF
	cQuery += "	declare @cCTT_CLASSE CHAR( "+StrZero(TamSX3("CTT_CLASSE")[1],3)+" )"+CRLF

	//---------------------------------------------------------------
	// Variaveis para armazenar o retorno da query de conta contabil
	//---------------------------------------------------------------
	cQuery += "	declare @cCT1_ID     CHAR( "+StrZero(nTamConta              ,3)+" )"+CRLF
	cQuery += "	declare @cCT1_CONTA  CHAR( "+StrZero(nTamConta              ,3)+" )"+CRLF
	cQuery += "	declare @cCT1_DESC   CHAR( "+StrZero(TamSX3("CT1_DESC01")[1],3)+" )"+CRLF
	cQuery += "	declare @cCT1_CLASSE CHAR( "+StrZero(TamSX3("CT1_CLASSE")[1],3)+" )"+CRLF
	cQuery += "	declare @cCT1_CTASUP CHAR( "+StrZero(nTamConta              ,3)+" )"+CRLF
	cQuery += "	declare @cCT1_RES    CHAR( "+StrZero(TamSX3("CT1_RES")[1]   ,3)+" )"+CRLF
	cQuery += "	declare @cCT1_GRUPO  CHAR( "+StrZero(TamSX3("CT1_GRUPO")[1] ,3)+" )"+CRLF

	cQuery += "	begin"+CRLF

	cQuery += "		Select @OUT_RET = '0'"+CRLF

	//-----------------
	// Laco no cArqTMP
	//-----------------
	cQuery += "		Declare CUR_ARQTMP insensitive cursor for"+CRLF
	cQuery += "		Select"+CRLF
	cQuery += "			CUSTO, CCSUP, CONTA, CTASUP, COLUNA1, COLUNA2, COLUNA3, COLUNA4, COLUNA5, COLUNA6, COLUNA7, COLUNA8, COLUNA9, COLUNA10, COLUNA11, COLUNA12"+CRLF
	cQuery += "		From " + cAliasTEMP + CRLF
	cQuery += "		Where"+CRLF
	cQuery += "			D_E_L_E_T_ = ' '"+CRLF
	cQuery += "		For Read Only"+CRLF

	cQuery += "		Open CUR_ARQTMP"+CRLF
	cQuery += "		Fetch CUR_ARQTMP into @cCUSTO, @cCCSUP, @cCONTA, @cCTASUP, @nCOLUNA1, @nCOLUNA2, @nCOLUNA3, @nCOLUNA4, @nCOLUNA5, @nCOLUNA6, @nCOLUNA7, @nCOLUNA8, @nCOLUNA9, @nCOLUNA10, @nCOLUNA11, @nCOLUNA12"+CRLF

	cQuery += "		While @@fetch_status = 0  begin"+CRLF

	cQuery += "			Declare CUR_ARQCTT insensitive cursor for"+CRLF
	cQuery += "			Select"+CRLF
	cQuery += "				CTT_ID, CTT_CUSTO, CTT_CCSUP, CTT_DESC, CTT_RES, CTT_CLASSE"+CRLF
	cQuery += "			From " + cAliasCTT + CRLF
	cQuery += "			Where"+CRLF
	cQuery += "				CTT_ID = @cCUSTO"+CRLF
	cQuery += "				AND D_E_L_E_T_ = ' '"+CRLF
	cQuery += "			For Read Only"+CRLF

	cQuery += "			Open CUR_ARQCTT"+CRLF
	cQuery += "			Fetch CUR_ARQCTT into @cCTT_ID,@cCTT_CUSTO,@cCTT_CCSUP,@cCTT_DESC,@cCTT_RES,@cCTT_CLASSE"+CRLF

	cQuery += "			While @@fetch_status = 0 and @cCTT_ID = @cCUSTO  begin"+CRLF

	cQuery += "				Declare CUR_ARQCT1 insensitive cursor for"+CRLF
	cQuery += "				Select"+CRLF
	cQuery += "					CT1_ID,CT1_CONTA,CT1_CTASUP,CT1_DESC,CT1_RES,CT1_CLASSE,CT1_GRUPO"+CRLF
	cQuery += "				From "+ cAliasCT1 +CRLF
	cQuery += "				Where"+CRLF
	cQuery += "					CT1_ID = @cCONTA"+CRLF
	cQuery += "					AND D_E_L_E_T_ = ' '"+CRLF
	cQuery += "				For Read Only"+CRLF

	cQuery += "				Open CUR_ARQCT1"+CRLF
	cQuery += "				Fetch CUR_ARQCT1 into @cCT1_ID,@cCT1_CONTA,@cCT1_CTASUP,@cCT1_DESC,@cCT1_RES,@cCT1_CLASSE,@cCT1_GRUPO"+CRLF

	cQuery += "				While @@fetch_status = 0 and @cCT1_ID = @cCONTA  begin"+CRLF

	cQuery += "					select @iRecno = null"+CRLF

	//---------------------------------------------------------------------------------------------------
	// O If abaixo evita que seja gravada conta + centro analiticos, umas vez que j· vieram do CTGerComp
	//---------------------------------------------------------------------------------------------------
	cQuery += "					If @cCT1_ID <> @cCT1_CONTA OR @cCTT_ID <> @cCTT_CUSTO begin"+CRLF

	//----------------------------------------
	// Insert or Update no cArqTmp
	// Soma os valores das colunas de periodo
	//----------------------------------------
	cQuery += "						Select	"+CRLF
	cQuery += "							@iRecno = R_E_C_N_O_"+CRLF
	cQuery += "						From " + cAliasTEMP + CRLF
	cQuery += "						Where"+CRLF
	cQuery += "							CUSTO          = @cCTT_CUSTO"+CRLF
	cQuery += "							AND CONTA      = @cCT1_CONTA"+CRLF
	cQuery += "							AND D_E_L_E_T_ = ' '"+CRLF

	cQuery += "						If @iRecno is null begin"+CRLF

	cQuery += "							If @cCT1_CTASUP = '" + Space(nTamConta) + "' begin"+CRLF
	cQuery += "								Select @cNIVEL1 = 'T'"+CRLF
	cQuery += "							end else begin"+CRLF
	cQuery += "								Select @cNIVEL1 = 'F'"+CRLF
	cQuery += "							End"+CRLF

	cQuery += "							    insert into " + cAliasTEMP +CRLF
	cQuery += "								    (CUSTO      ,CCSUP      ,DESCCC    ,CCRES    ,TIPOCC      ,CONTA      ,CTASUP      ,DESCCTA   ,CTARES   ,TIPOCONTA   ,GRUPO      ,NIVEL1 "   + If(cTpVlr == 'M', ",COLUNA1  ,COLUNA2   ,COLUNA3  ,COLUNA4  ,COLUNA5  ,COLUNA6  ,COLUNA7  ,COLUNA8  ,COLUNA9  ,COLUNA10  ,COLUNA11  ,COLUNA12"  ,"") +" )"+CRLF
	cQuery += "							    values"+CRLF
	cQuery += "								    (@cCTT_CUSTO,@cCTT_CCSUP,@cCTT_DESC,@cCTT_RES,@cCTT_CLASSE,@cCT1_CONTA,@cCT1_CTASUP,@cCT1_DESC,@cCT1_RES,@cCT1_CLASSE,@cCT1_GRUPO,@cNIVEL1 " + If(cTpVlr == 'M', ",@nCOLUNA1,@nCOLUNA2,@nCOLUNA3 ,@nCOLUNA4,@nCOLUNA5,@nCOLUNA6,@nCOLUNA7,@nCOLUNA8,@nCOLUNA9,@nCOLUNA10,@nCOLUNA11,@nCOLUNA12","") +" )"+CRLF

	If cTpVlr == 'M'
		cQuery += "					End else begin"+CRLF

		cQuery += "							Update " + cAliasTEMP +CRLF
		cQuery += "								Set COLUNA1  = COLUNA1  + @nCOLUNA1,"+CRLF
		cQuery += "									COLUNA2  = COLUNA2  + @nCOLUNA2,"+CRLF
		cQuery += "									COLUNA3  = COLUNA3  + @nCOLUNA3,"+CRLF
		cQuery += "									COLUNA4  = COLUNA4  + @nCOLUNA4,"+CRLF
		cQuery += "									COLUNA5  = COLUNA5  + @nCOLUNA5,"+CRLF
		cQuery += "									COLUNA6  = COLUNA6  + @nCOLUNA6,"+CRLF
		cQuery += "									COLUNA7  = COLUNA7  + @nCOLUNA7,"+CRLF
		cQuery += "									COLUNA8  = COLUNA8  + @nCOLUNA8,"+CRLF
		cQuery += "									COLUNA9  = COLUNA9  + @nCOLUNA9,"+CRLF
		cQuery += "									COLUNA10 = COLUNA10 + @nCOLUNA10,"+CRLF
		cQuery += "									COLUNA11 = COLUNA11 + @nCOLUNA11,"+CRLF
		cQuery += "									COLUNA12 = COLUNA12 + @nCOLUNA12"+CRLF
		cQuery += "								Where"+CRLF
		cQuery += "									CUSTO          = @cCTT_CUSTO"+CRLF
		cQuery += "									and CONTA      = @cCT1_CONTA"+CRLF
		cQuery += "									and D_E_L_E_T_ = ' '"+CRLF
	EndIf

	cQuery += "						End"+CRLF
	cQuery += "					End"+CRLF

	If lDB2
		cQuery += "             select @fim_CUR = 0"+CRLF
	EndIf

	cQuery += "					Fetch CUR_ARQCT1 into @cCT1_ID,@cCT1_CONTA,@cCT1_CTASUP,@cCT1_DESC,@cCT1_RES,@cCT1_CLASSE,@cCT1_GRUPO"+CRLF

	cQuery += "				End"+CRLF

	cQuery += "				close CUR_ARQCT1"+CRLF
	cQuery += "				deallocate CUR_ARQCT1"+CRLF

	If lDB2
		cQuery += "         select @fim_CUR = 0"+CRLF
	EndIf

	cQuery += "				Fetch CUR_ARQCTT into @cCTT_ID,@cCTT_CUSTO,@cCTT_CCSUP,@cCTT_DESC,@cCTT_RES,@cCTT_CLASSE"+CRLF

	cQuery += "			End"+CRLF

	cQuery += "			close CUR_ARQCTT"+CRLF
	cQuery += "			deallocate CUR_ARQCTT"+CRLF

	If lDB2
		cQuery += "     select @fim_CUR = 0"+CRLF
	EndIf

	cQuery += "			Fetch CUR_ARQTMP into @cCUSTO, @cCCSUP, @cCONTA, @cCTASUP, @nCOLUNA1, @nCOLUNA2, @nCOLUNA3, @nCOLUNA4, @nCOLUNA5, @nCOLUNA6, @nCOLUNA7, @nCOLUNA8, @nCOLUNA9, @nCOLUNA10, @nCOLUNA11, @nCOLUNA12"+CRLF

	cQuery += "		End"+CRLF

	cQuery += "		close CUR_ARQTMP"+CRLF
	cQuery += "		deallocate CUR_ARQTMP"+CRLF

	cQuery += "		Select @OUT_RET = '1'"+CRLF

	cQuery += "	End"+CRLF


	//-------------------
	// Execucao do Parse
	//-------------------
	cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
	cQuery := CtbAjustaP(.f., cQuery, 0)

	If Empty( cQuery )
		lRet := .F.
		Help(" ",1,"SupCompMes",,STR0049 + " " + cProc  + MSParseError(),1,0) //"A procedure nao passou pelo Parse."
	EndIf

	//--------------------------------------------------------------------------
	// Ajusta a procedure para o nome real da tabela temporaria, n„o È inserida
	// antes pois o nome contem # e o MsParse acaba invalidando
	//--------------------------------------------------------------------------
	If lRet
		cQuery := StrTran(cQuery, cAliasTEMP, cTabTEMP)
		cQuery := StrTran(cQuery, cAliasCTT , cTabCTT)
		cQuery := StrTran(cQuery, cAliasCT1 , cTabCT1)
	EndIf

	//------------------------------
	// Instala a procedure no Banco
	//------------------------------
	If lRet .And. !TCSPExist( cProc )

		cRet := TcSqlExec(cQuery)

		If cRet <> 0
			If !__lBlind
				lRet:= .F.
				Help(" ",1,"SupCompMes",,STR0043 + " " + cProc + ": " + TCSqlError() ,1,0) //'Erro na criacao da procedure'
			EndIf
		EndIf

	EndIf

	//---------------------
	// Executa a procedure
	//---------------------
	If lRet

		aResult := TCSPExec(cProc)

		If Empty(aResult) .Or. Empty(aResult[1]) .Or. aResult[1] = "0"
			lRet := .f.
			Help(" ",1,"SupCompMes",,STR0050 + " " + cProc + ": " + TCSqlError(),1,0) //'Erro na execucao da procedure'
		EndIf

	EndIf

	//-----------------------------
	// Exclui a procedure do banco
	//-----------------------------
	If TCSPExist(cProc)
		If TcSqlExec("Drop procedure " + cProc) <> 0
			Help(" ",1,"SupCompMes",,STR0051 + " " + cProc,1,0) //"Erro na exclus„o da procedure"
		Endif
	EndIf

EndIf

//-------------------------------------------------------
// Exclui as tabelas temporarias auxiliares da CTT e CT1
//-------------------------------------------------------
If __oTmpCT1 <> Nil
	__oTmpCT1:Delete()
EndIf

If __oTmpCTT <> Nil
	__oTmpCTT:Delete()
EndIf

RestArea(aSaveArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CT4Bln3Ent
Retorna alias TRBTMP com a composiÁ„o dos saldos CC x Conta x Item.

@author Alvaro Camillo Neto


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CT4Bln3Ent(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cMoeda,;
					cTpSald,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)

CQ2Bln3Ent(dDataIni,dDataFim,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cMoeda,;
					cTpSald,aSetOfBook,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥Ctb3CtaSup ≥Autor  ≥ Simone Mie Sato       ≥ Data ≥ 12.08.04 		     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Atualizacao de sinteticas de c.custo/conta/item             			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥Ctb3CtaSup(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook) ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Nenhum                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                  			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cAlias	= Alias a ser utilizado             	               		 ≥±±
±±≥          ≥ lNImpMov = Se imprime entidades sem movimento		               	 ≥±±
±±≥          ≥ cMoeda	= Moeda                              	              		 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function Ctb3CtaSup(oMeter,oText,oDlg,cAlias,lNImpMov,cMoeda,cHeader)

Local aSaveArea	:= GetArea()
Local cCadAlias	:= ""
Local cCodSup	:= ""
Local cCodEnt	:= ""
Local cConta	:= ""
Local cDescCta	:= ""
Local cOutEnt	:= ""
Local cEntSup	:= ""
Local cDescEnt	:= ""
Local cSeek		:= ""
Local nSaldoAnt	:= 0
Local nSaldoAtu	:= 0
Local nSaldoDeb	:= 0
Local nSaldoCrd	:= 0
Local nMovimento:= 0
Local nSaldoAntD:= 0
Local nSaldoAntC:= 0
Local nSaldoAtuD:= 0
Local nsaldoAtuC:= 0
Local nRegTmp	:= 0
Local nMeter	:= 0
local cCpoSup	:= ""

dbSelectArea("cArqTmp")
dbGoTop()
If ValType(oMeter) == "O"
	nMeter	:= 0
	oMeter:SetTotal(cArqTmp->(RecCount()))
	oMeter:Set(0)
EndIf
While!Eof()
	If cAlias == "CT4"
		If cHeader == "CTT"
			//Somar somente o que for do CT3 => para nao duplicar os valores do CT4 com CT3.
			If !Empty(cArqTmp->ITEM)
				dbSkip()
				Loop
			EndIf
		EndIf
	EndIf

	nSaldoAnt:= SALDOANT
	nSaldoAtu:= SALDOATU
	nSaldoDeb:= SALDODEB
	nSaldoCrd:= SALDOCRD
	nMovimento:= MOVIMENTO

	nRegTmp := Recno()

	If cAlias == 'CT4'
		If cHeader == "CTT"
			cCadastro := "CTT"
			cEntid 	 := cArqTmp->CUSTO
			cCodRes	 := cArqTmp->CCRES
			cTipoEnt := cArqTmp->TIPOCC
			cDescEnt := cArqTmp->DESCCC
			cCpoSup	 := "CTT_CCSUP"
		EndIf
	EndIf



	DbSelectArea(cCadastro)
	cEntidG := cEntid
	dbSetOrder(1)
	MsSeek(xFilial(cCadastro)+cEntidG)

	While !Eof() .And. &(cCadastro + "->" + cCadastro + "_FILIAL") == xFilial()

        nReg := cArqTmp->(Recno())

		dbSelectArea("CT1")
		dbSetOrder(1)
		cContaSup := cArqTmp->CONTA
		MsSeek(xFilial("CT1")+ cContaSup)

		If cEntid = cEntidG
			cContaSup := CT1->CT1_CTASUP
			MsSeek(xFilial("CT1")+ cContaSup)
		Endif

		While !Eof() .And. CT1->CT1_FILIAL == xFilial()

			cDesc := &("CT1->CT1_DESC"+cMoeda)
			If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
				cDesc := CT1->CT1_DESC01
			Endif

			cDescEnt := &(cCadastro + "->" + cCadastro + "_DESC"+cMoeda)
			If Empty(cDescEnt)		// Caso nao preencher descricao da moeda selecionada
				cDescEnt := &(cCadastro + "->" + cCadastro + "_DESC01")
			Endif
			cCodRes  := &(cCadastro + "->" + cCadastro + "_RES")
			cTipoEnt := &(cCadastro + "->" + cCadastro + "_CLASSE")

			dbSelectArea("cArqTmp")
			dbSetOrder(1)
			If ! MsSeek(cEntidG+cContaSup)
				dbAppend()
				Replace CONTA		With cContaSup
				Replace DESCCTA 	With cDesc
				Replace NORMAL   	With CT1->CT1_NORMAL
				Replace TIPOCONTA	With CT1->CT1_CLASSE
				Replace GRUPO		With CT1->CT1_GRUPO
				Replace CTARES		With CT1->CT1_RES
				Replace SUPERIOR	With CT1->CT1_CTASUP
				Replace ESTOUR 		With CT1->CT1_ESTOUR

				If cAlias == 'CT4'
					If cHeader == "CTT"
						Replace CUSTO With cEntidG
						Replace CCRES With cCodRes
						Replace TIPOCC With cTipoEnt
						Replace DESCCC With cDescEnt
				        If !Empty(cArqTmp->ITEM)
							dbSelectArea("CTD")
							dbSetOrder(1)
							If MsSeek(xFilial()+cArqTmp->ITEM)
								Replace ITEM With cArqTmp->ITEM
							    Replace ITEMRES With CTD->CTD_RES
							    If cMoeda == '01'
					    			Replace DESCITEM With CTD->CTD_DESC01
					    		Else
					    			If !Empty(&("CTD->CTD_DESC"+cMoeda))
						    			Replace DESCITEM With &("CTD->CTD_DESC"+cMoeda)
						    		Else
						    			Replace DESCITEM With CTD->CTD_DESC01
					    		    EndIf
					    		EndIf
    	    				EndIf
  						EndIf
					 EndIf
				EndIf
			EndIf
			dbSelectArea("cArqTmp")
			Replace	 SALDOANT With SALDOANT + nSaldoAnt
			Replace  SALDOATU With SALDOATU + nSaldoAtu
			Replace  SALDODEB With SALDODEB + nSaldoDeb
			Replace  SALDOCRD With SALDOCRD + nSaldoCrd
			If !lNImpMov
				Replace MOVIMENTO With MOVIMENTO + nMovimento
			Endif

			dbSelectArea("CT1")
			cContaSup := CT1->CT1_CTASUP
			If Empty(CT1->CT1_CTASUP) //.And. Empty(&(cCadastro + "->" + cCpoSup))
				dbSelectArea("cArqTmp")
				Replace NIVEL1 With .T.
				dbSelectArea("CT1")
				Exit
			EndIf

			dbSelectArea("cArqTmp")
			dbGoto(nRegTmp)
			dbSelectArea("CT1")
			cContaSup := CT1->CT1_CTASUP
			If Empty(cContaSup) .And. Empty(&(cCadastro + "->" + cCpoSup))
				dbSelectArea("cArqTmp")
				Replace NIVEL1 With .T.
				dbSelectArea("CT1")
			EndIf
			MsSeek(xFilial("CT1")+ cContaSup)
		EndDo
		dbSelectArea("cArqTmp")
		dbGoto(nReg)
		DbSelectArea(cCadastro)
		cEntidG := &cCpoSup
		If Empty(cEntidG)		// Ultimo Nivel gerencial
			Exit
		EndIf
		MsSeek(xFilial(cCadastro)+cEntidG)
	EndDo
	dbSelectArea("cArqTmp")
	dbGoto(nRegTmp)
	dbSkip()
	nMeter++
	If nMeter%1000 = 0
		If ValType(oMeter) == "O"
	   		oMeter:Set(nMeter)
	  	EndIf
  	EndIf
EndDo

RestArea(aSaveArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CTIBln4Ent
Retorna alias TRBTMP com a composiÁ„o dos saldos CC x Conta x Item X Cl.Valor

@author Alvaro Camillo Neto


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CTIBln4Ent(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,;
					cClVlIni,cClVlFim,cMoeda,cTpSald,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,aSelFil,lTodasFil,aTmpFil,cTmpArq,nLimTmp)

CQ6Bln4Ent(dDataIni,dDataFim,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cClVlIni,cClVlFim,cMoeda,cTpSald,aSetOfBook,lImpAntLp,dDataLP,aSelFil,lTodasFil,aTmpFil,cTmpArq,nLimTmp)

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥Ctb4CtaSup ≥Autor  ≥ Simone Mie Sato       ≥ Data ≥ 07.10.04 		     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Atualizacao de sinteticas de c.custo/conta/item/Cl.Valor    			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥Ctb4CtaSup(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook) ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Nenhum                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                  			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cAlias	= Alias a ser utilizado             	               		 ≥±±
±±≥          ≥ lNImpMov = Se imprime entidades sem movimento		               	 ≥±±
±±≥          ≥ cMoeda	= Moeda                              	              		 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function Ctb4CtaSup(oMeter,oText,oDlg,cAlias,lNImpMov,cMoeda,cHeader)

Local aSaveArea	:= GetArea()
Local cCadAlias	:= ""
Local cCodSup	:= ""
Local cCodEnt	:= ""
Local cConta	:= ""
Local cDescCta	:= ""
Local cOutEnt	:= ""
Local cEntSup	:= ""
Local cDescEnt	:= ""
Local cSeek		:= ""
Local nSaldoAnt	:= 0
Local nSaldoAtu	:= 0
Local nSaldoDeb	:= 0
Local nSaldoCrd	:= 0
Local nMovimento:= 0
Local nSaldoAntD:= 0
Local nSaldoAntC:= 0
Local nSaldoAtuD:= 0
Local nsaldoAtuC:= 0
Local nRegTmp	:= 0
Local nMeter	:= 0
local cCpoSup	:= ""

dbSelectArea("cArqTmp")
dbGoTop()
If ValType(oMeter) == "O"
	nMeter	:= 0
	oMeter:SetTotal(cArqTmp->(RecCount()))
	oMeter:Set(0)
EndIf

While!Eof()
	If cAlias == "CTI"
		If cHeader == "CTT"
			//Somar somente o que for do CT3 => para nao duplicar os valores do CT4/CTI com CT3.
			If !Empty(cArqTmp->ITEM) .Or. !Empty(cArqTmp->CLVL)
				dbSkip()
				Loop
			EndIf
		EndIf
	EndIf

	nSaldoAnt:= SALDOANT
	nSaldoAtu:= SALDOATU
	nSaldoDeb:= SALDODEB
	nSaldoCrd:= SALDOCRD
	nMovimento:= MOVIMENTO

	nRegTmp := Recno()

	If cAlias == 'CTI'
		If cHeader == "CTT"
			cCadastro := "CTT"
			cEntid 	 := cArqTmp->CUSTO
			cCodRes	 := cArqTmp->CCRES
			cTipoEnt := cArqTmp->TIPOCC
			cDescEnt := cArqTmp->DESCCC
			cCpoSup	 := "CTT_CCSUP"
		EndIf
	EndIf



	DbSelectArea(cCadastro)
	cEntidG := cEntid
	dbSetOrder(1)
	MsSeek(xFilial(cCadastro)+cEntidG)

	While !Eof() .And. &(cCadastro + "->" + cCadastro + "_FILIAL") == xFilial()

        nReg := cArqTmp->(Recno())

		dbSelectArea("CT1")
		dbSetOrder(1)
		cContaSup := cArqTmp->CONTA
		MsSeek(xFilial("CT1")+ cContaSup)

		If cEntid = cEntidG
			cContaSup := CT1->CT1_CTASUP
			MsSeek(xFilial("CT1")+ cContaSup)
		Endif

		While !Eof() .And. CT1->CT1_FILIAL == xFilial()

			cDesc := &("CT1->CT1_DESC"+cMoeda)
			If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
				cDesc := CT1->CT1_DESC01
			Endif

			cDescEnt := &(cCadastro + "->" + cCadastro + "_DESC"+cMoeda)
			If Empty(cDescEnt)		// Caso nao preencher descricao da moeda selecionada
				cDescEnt := &(cCadastro + "->" + cCadastro + "_DESC01")
			Endif
			cCodRes  := &(cCadastro + "->" + cCadastro + "_RES")
			cTipoEnt := &(cCadastro + "->" + cCadastro + "_CLASSE")

			dbSelectArea("cArqTmp")
			dbSetOrder(1)
			If ! MsSeek(cEntidG+cContaSup)
				dbAppend()
				Replace CONTA		With cContaSup
				Replace DESCCTA 	With cDesc
				Replace NORMAL   	With CT1->CT1_NORMAL
				Replace TIPOCONTA	With CT1->CT1_CLASSE
				Replace GRUPO		With CT1->CT1_GRUPO
				Replace CTARES		With CT1->CT1_RES
				Replace SUPERIOR	With CT1->CT1_CTASUP

				If cAlias == 'CTI'
					If cHeader == "CTT"
						Replace CUSTO With cEntidG
						Replace CCRES With cCodRes
						Replace TIPOCC With cTipoEnt
						Replace DESCCC With cDescEnt
				        If !Empty(cArqTmp->ITEM)
							dbSelectArea("CTD")
							dbSetOrder(1)
							If MsSeek(xFilial()+cArqTmp->ITEM)
								Replace ITEM With cArqTmp->ITEM
							    Replace ITEMRES With CTD->CTD_RES
							    If cMoeda == '01'
					    			Replace DESCITEM With CTD->CTD_DESC01
					    		Else
					    			If !Empty(&("CTD->CTD_DESC"+cMoeda))
						    			Replace DESCITEM With &("CTD->CTD_DESC"+cMoeda)
						    		Else
						    			Replace DESCITEM With CTD->CTD_DESC01
					    		    EndIf
					    		EndIf
    	    				EndIf
  						EndIf
				        If !Empty(cArqTmp->CLVL)
							dbSelectArea("CTH")
							dbSetOrder(1)
							If MsSeek(xFilial()+cArqTmp->CLVL)
								Replace CLVL With cArqTmp->CLVL
							    Replace CLVLRES With CTH->CTH_RES
							    If cMoeda == '01'
					    			Replace DESCCLVL With CTH->CTH_DESC01
					    		Else
					    			If !Empty(&("CTH->CTH_DESC"+cMoeda))
						    			Replace DESCCLVL With &("CTH->CTH_DESC"+cMoeda)
						    		Else
						    			Replace DESCCLVL With CTH->CTH_DESC01
					    		    EndIf
					    		EndIf
    	    				EndIf
  						EndIf
					 EndIf
				EndIf
			EndIf
			dbSelectArea("cArqTmp")
			Replace	 SALDOANT With SALDOANT + nSaldoAnt
			Replace  SALDOATU With SALDOATU + nSaldoAtu
			Replace  SALDODEB With SALDODEB + nSaldoDeb
			Replace  SALDOCRD With SALDOCRD + nSaldoCrd
			If !lNImpMov
				Replace MOVIMENTO With MOVIMENTO + nMovimento
			Endif

			dbSelectArea("CT1")
			cContaSup := CT1->CT1_CTASUP
			If Empty(CT1->CT1_CTASUP) //.And. Empty(&(cCadastro + "->" + cCpoSup))
				dbSelectArea("cArqTmp")
				Replace NIVEL1 With .T.
				dbSelectArea("CT1")
				Exit
			EndIf

			dbSelectArea("cArqTmp")
			dbGoto(nRegTmp)
			dbSelectArea("CT1")
			cContaSup := CT1->CT1_CTASUP
			If Empty(cContaSup) .And. Empty(&(cCadastro + "->" + cCpoSup))
				dbSelectArea("cArqTmp")
				Replace NIVEL1 With .T.
				dbSelectArea("CT1")
			EndIf
			MsSeek(xFilial("CT1")+ cContaSup)
		EndDo
		dbSelectArea("cArqTmp")
		dbGoto(nReg)
		DbSelectArea(cCadastro)
		cEntidG := &cCpoSup
		If Empty(cEntidG)		// Ultimo Nivel gerencial
			Exit
		EndIf
		MsSeek(xFilial(cCadastro)+cEntidG)
	EndDo
	dbSelectArea("cArqTmp")
	dbGoto(nRegTmp)
	dbSkip()
	nMeter++
	If nMeter%1000 = 0
		If ValType(oMeter) == "O"
	   		oMeter:Set(nMeter)
	  	EndIf
  	EndIf
EndDo

RestArea(aSaveArea)

Return


//-------------------------------------------------------------------
/*{Protheus.doc} Ct3Bln1Ent
Retorna alias TRBTMP com a composiÁ„o dos saldos de  uma Entidade filtrada pela conta.

@author Alvaro Camillo Neto


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function Ct3Bln1Ent(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,;
			cMoeda,cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,;
			lRecDesp0,cRecDesp,dDtZeraRD,aSelFil,lTodasFil,aTmpFil)

CQ2Bln1Ent(@dDataIni,@dDataFim,@cContaIni,@cContaFim,@cCCIni,@cCCFim,@cMoeda,@cSaldos,@aSetOfBook,@lVlrZerado,@lImpAntLP,@dDataLP,@cFilUsu,@lRecDesp0,@cRecDesp,@dDtZeraRD,@aSelFil,@lTodasFil,@aTmpFil)

Return



//-------------------------------------------------------------------
/*{Protheus.doc} Ct4Bln1Ent
Retorna alias TRBTMP com a composiÁ„o dos saldos de  uma Entidade filtrada pela conta.

@author Alvaro Camillo Neto


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function Ct4Bln1Ent(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,;
			cMoeda,cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,;
			lRecDesp0,cRecDesp,dDtZeraRD,aSelFil,lTodasFil,aTmpFil)

CQ4Bln1Ent(@dDataIni,@dDataFim,@cContaIni,@cContaFim,@cCCIni,@cCCFim,@cItemIni,@cItemFim,@cMoeda,@cSaldos,@aSetOfBook,;
		@lVlrZerado,@lImpAntLP,@dDataLP,@cFilUsu,@lRecDesp0,@cRecDesp,@dDtZeraRD,@aSelFil,@lTodasFil,@aTmpFil)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CTIBln1Ent
Retorna alias TRBTMP com a composiÁ„o dos saldos de  uma Entidade filtrada pela conta.

@author Alvaro Camillo Neto


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CTIBln1Ent(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,;
			cItemFim,cClVlIni,cClVlFim,	cMoeda,cSaldos,aSetOfBook,lImpMov,lVlrZerado,;
			lImpAntLP,dDataLP,cFilUsu,lRecDesp0,cRecDesp,dDtZeraRD,aSelFil,lTodasFil,aTmpFil)

CQ6Bln1Ent(@dDataIni,@dDataFim,@cContaIni,@cContaFim,@cCCIni,@cCCFim,@cItemIni,;
			@cItemFim,@cClVlIni,@cClVlFim,	@cMoeda,@cSaldos,@aSetOfBook,@lVlrZerado,;
			@lImpAntLP,@dDataLP,@cFilUsu,@lRecDesp0,@cRecDesp,@dDtZeraRD,@aSelFil,@lTodasFil,@aTmpFil)

Return


//-------------------------------------------------------------------
/*{Protheus.doc} CTICmp4Ent
Obtem o saldo/movimento das 4 entidades

@author Alvaro Camillo Neto


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function CTICmp4Ent(dDataIni,dDataFim,cContaIni,cContafim,cCCIni,cCCFim,cItemIni,cItemFim,cClVlIni,cClVlFim,;
					cMoeda,cTpSald,aSetOfBook,lImpAntLP,dDataLP,cTpVlr,aMeses,cString,cFilUSU)

CQ6Cmp4Ent(dDataIni,dDataFim,cContaIni,cContafim,cCCIni,cCCFim,cItemIni,cItemFim,cClVlIni,cClVlFim,cMoeda,cTpSald,lImpAntLP,dDataLP,cTpVlr,aMeses,cString,cFilUSU)

Return


//-------------------------------------------------------------------
/*{Protheus.doc} CTIBlnQry
Retorna alias TRBTMP com a composiÁ„o dos saldos Conta X Classe de Valor

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CTIBlnQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cClVlIni,cClVlFim,cMoeda,cTpSald,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)

CQ6BlnQry(dDataIni,dDataFim,cContaIni,cContaFim,cClVlIni,cClVlFim,cMoeda,cTpSald,aSetOfBook,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥CtEntCtSup ≥Autor  ≥ Simone Mie Sato       ≥ Data ≥ 16.05.05 		     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Atualizacao de sinteticas de entidade/conta                 			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥CtEntCtSup(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook) ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Nenhum                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                  			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ oMeter	= Objeto oMeter                     	               		 ≥±±
±±≥          ≥ oText 	= Objeto oText                      	                	 ≥±±
±±≥          ≥ oDlg  	= Objeto oDlg                       	                	 ≥±±
±±≥          ≥ lEnd 	 = Acao do CodeBlock                 	                	 ≥±±
±±≥          ≥ cAlias	= Alias a ser utilizado             	               		 ≥±±
±±≥          ≥ lNImpMov = Se imprime entidades sem movimento		               	 ≥±±
±±≥          ≥ cMoeda	= Moeda                              	              		 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CtEntCtSup(oMeter,oText,oDlg,cAlias,lNImpMov,cMoeda,nComp, cEntid_De, cEntid_Ate,lEntSint)

Local aSaveArea	:= GetArea()

Local cCadastro	:= ""
Local cSuperior	:= ""
Local cCpoSup	:= ""
Local cIndice	:= ""
Local cEntid 	:= ""
Local cEntidG	:= ""
Local cCodRes	:= ""
Local cTipoEnt  := ""
Local cContaSup	:= ""
Local cDesc		:= ""
Local cDescEnt  := ""
Local cEntSup   := ""

Local nIndex	:= 0
Local nSaldoAnt := 0
Local nSaldoAtu := 0
Local nSaldoDeb := 0
Local nSaldoCrd := 0
Local nMovimento:= 0
Local nRegTmp 	:= 0
Local nReg		:= 0
Local nMeter	:= 0
Local nCol		:= 1
Local lEstour	:= .F.
Local lFaixa  	:= .F.
Local aRecAux 	:= {}

DEFAULT nComp		:= 0			///SE FOR COMPARATIVO MES A MES INDICAR A QUANTIDADE DE COLUNAS
DEFAULT cEntid_De	:= ""
DEFAULT cEntid_Ate	:= ""
Default lEntSint	:= .F.

If ! Empty(cEntid_Ate)
	lFaixa := .T.
EndIf

Do Case
Case cAlias == 'CT3'
	cCadastro 	:= "CTT"
	cSuperior	:= 'CTT_FILIAL + CTT_CCSUP'
	cCpoSup		:= 'CTT_CCSUP'
Case cAlias == 'CT4'
	cCadastro 	:= "CTD"
	cSuperior	:= 'CTD_FILIAL + CTD_ITSUP'
	cCpoSup		:= 'CTD_ITSUP'
Case cAlias == 'CTI'
	cCadastro 	:= "CTH"
	cSuperior	:= 'CTH_FILIAL + CTH_CLSUP'
	cCpoSup		:= 'CTH_CLSUP'
EndCase

dbSelectArea("CT1")
lEstour := CT1->(FieldPos("CT1_ESTOUR")) <> 0
DbSelectArea(cCadastro)

If !Empty(cSuperior) .And. Empty(IndexKey(5))
	IndRegua(cCadastro, cIndice := (CriaTrab(, .F. )), cSuperior,,, STR0001)
	nIndex:=RetIndex(cCadastro)+1
	dbSelectArea(cCadastro)
Else
	nIndex := 5
Endif

dbSelectArea("cArqTmp")
If lEstour .and. cArqTmp->(FieldPos("ESTOUR")) <> 0
	lEstour := .T.
Else
	lEstour := .F.
EndIf
dbGoTop()
If ValType(oMeter) == "O"
	nMeter	:= 0
	oMeter:SetTotal(cArqTmp->(RecCount()))
	oMeter:Set(0)
EndIf

While cArqTmp->(!Eof())

	If aScan( aRecAux, StrZero(Recno(),10) ) > 0
		dbSkip()
		Loop
	EndIf
	nRegTmp := Recno()
	If cAlias == 'CT3'
		cEntid 	 := cArqTmp->CUSTO
		cCodRes	 := cArqTmp->CCRES
		cTipoEnt := cArqTmp->TIPOCC
		cDescEnt := cArqTmp->DESCCC
	ElseIf cAlias == 'CT4'
		cEntid 	 := cArqTmp->ITEM
		cCodRes	 := cArqTmp->ITEMRES
		cTipoEnt := cArqTmp->TIPOITEM
		cDescEnt := cArqTmp->DESCITEM
	ElseIf cAlias == 'CTI'
		cEntid 	 := cArqTmp->CLVL
		cCodRes	 := cArqTmp->CLVLRES
		cTipoEnt := cArqTmp->TIPOCLVL
		cDescEnt := cArqTmp->DESCCLVL
	EndIf

	If cTipoEnt == "1"
		dbSkip()
		Loop
	EndIf

	If nComp < 2
		nSaldoAnt:= SALDOANT
		nSaldoAtu:= SALDOATU
		nSaldoDeb:= SALDODEB
		nSaldoCrd:= SALDOCRD
		nMovimento:= MOVIMENTO
	Else
		For nCol := 1 to nComp
			&("nMov"+ALLTRIM(STR(INT(nCol)))) := &("cArqTmp->MOVIMENTO"+ALLTRIM(STR(INT(nCol))))
		Next
	EndIf

	DbSelectArea(cCadastro)
	cEntidG := cEntid

	dbSetOrder(1)

	MsSeek(xFilial(cCadastro)+cEntidG)

	While !Eof() .And. &(cCadastro + "->" + cCadastro + "_FILIAL") == xFilial(cCadastro)

		nReg := cArqTmp->(Recno())
		dbSelectArea("CT1")
		dbSetOrder(1)
		cContaSup := cArqTmp->CONTA
		MsSeek(xFilial("CT1")+ cContaSup)

		If cEntid = cEntidG
			cContaSup := CT1->CT1_CTASUP
			MsSeek(xFilial("CT1")+ cContaSup)
		Endif

		While !Eof() .And. CT1->CT1_FILIAL == xFilial("CT1")

			cDesc := &("CT1->CT1_DESC"+cMoeda)
			If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
				cDesc := CT1->CT1_DESC01
			Endif

			cDescEnt := &(cCadastro + "->" + cCadastro + "_DESC"+cMoeda)
			If Empty(cDescEnt)		// Caso nao preencher descricao da moeda selecionada
				cDescEnt := &(cCadastro + "->" + cCadastro + "_DESC01")
			Endif
			cCodRes  := &(cCadastro + "->" + cCadastro + "_RES")
			cTipoEnt := &(cCadastro + "->" + cCadastro + "_CLASSE")

			If cAlias == 'CT3'
				cEntSup  := &(cCadastro + "->" + cCadastro + "_CCSUP")
			ElseIf cAlias == 'CT4'
				cEntSup  := &(cCadastro + "->" + cCadastro + "_ITSUP")

			ElseIf cAlias == 'CTI'
				cEntSup  := &(cCadastro + "->" + cCadastro + "_CLSUP")
			EndIf

			dbSelectArea("cArqTmp")
			dbSetOrder(1)

			If  lEntSint .OR. cTipoEnt == '2'

				If !MsSeek(cEntidG+cContaSup)

					dbAppend()
					aAdd(aRecAux, StrZero(Recno(),10) )
					Replace CONTA		With cContaSup
					Replace DESCCTA 	With cDesc
					Replace NORMAL   	With CT1->CT1_NORMAL
					Replace TIPOCONTA	With CT1->CT1_CLASSE
					Replace GRUPO		With CT1->CT1_GRUPO
					Replace CTARES		With CT1->CT1_RES
					Replace SUPERIOR	With CT1->CT1_CTASUP
					If lEstour
						Replace ESTOUR With CT1->CT1_ESTOUR
					EndIf
					If cAlias == 'CT3'
						Replace CUSTO With cEntidG
						Replace CCRES With cCodRes
						Replace TIPOCC With cTipoEnt
						Replace DESCCC With cDescEnt
						Replace CCSUP With cEntSup
					ElseIf cAlias == 'CT4'
						Replace ITEM With cEntidG
						Replace ITEMRES With cCodRes
						Replace TIPOITEM With cTipoEnt
						Replace DESCITEM With cDescEnt
						Replace ITSUP With cEntSup
					ElseIf cAlias == 'CTI'
						Replace CLVL With cEntidG
						Replace CLVLRES With cCodRes
						Replace TIPOCLVL With cTipoEnt
						Replace DESCCLVL WITH cDescEnt
						Replace CLSUP With cEntSup
					EndIf
				EndIf

				If nComp < 2
					Replace	 SALDOANT With SALDOANT + nSaldoAnt
					Replace  SALDOATU With SALDOATU + nSaldoAtu
					Replace  SALDODEB With SALDODEB + nSaldoDeb
					Replace  SALDOCRD With SALDOCRD + nSaldoCrd
					If !lNImpMov
						Replace MOVIMENTO With MOVIMENTO + nMovimento
					Endif
				Else
					For nCol := 1 to nComp
						&("cArqTmp->MOVIMENTO"+ALLTRIM(STR(INT(nCol)))) += &("nMov"+ALLTRIM(STR(INT(nCol))))
					Next
				EndIf
			Endif

			dbSelectArea("CT1")
			cContaSup := CT1->CT1_CTASUP
			If Empty(CT1->CT1_CTASUP) //.And. Empty(&(cCadastro + "->" + cCpoSup))
				dbSelectArea("cArqTmp")
				Replace NIVEL1 With .T.
				dbSelectArea("CT1")
				Exit
			EndIf

			dbSelectArea("cArqTmp")
			dbGoto(nRegTmp)
			dbSelectArea("CT1")
			cContaSup := CT1->CT1_CTASUP
			If Empty(cContaSup) .And. Empty(&(cCadastro + "->" + cCpoSup))
				dbSelectArea("cArqTmp")
				Replace NIVEL1 With .T.
				dbSelectArea("CT1")
			EndIf
			MsSeek(xFilial("CT1")+ cContaSup)
		EndDo
		dbSelectArea("cArqTmp")
		dbGoto(nReg)
		DbSelectArea(cCadastro)
		cEntidG := &cCpoSup
		If Empty(cEntidG)		// Ultimo Nivel gerencial
			Exit
		EndIf
		If lFaixa .And. ( cEntidG<cEntid_De .Or. cEntidG>cEntid_Ate )   // se esta fora da faixa da entidade sai do loop tambem
			Exit
		EndIf
		MsSeek(xFilial(cCadastro)+cEntidG)
	EndDo
	dbSelectArea("cArqTmp")
	dbGoto(nRegTmp)
	dbSkip()
	nMeter++
	If nMeter%1000 = 0
		If ValType(oMeter) == "O"
			oMeter:Set(nMeter)
		EndIf
	EndIf
EndDo

If ! Empty(cIndice)
	dbSelectArea(cCadastro)
	dbClearFil()
	RetIndex(cCadastro)
	dbSetOrder(1)
	Ferase(cIndice + OrdBagExt())
Endif



Restarea(aSaveArea)

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CTBXSAL   ∫Autor  ≥microsiga           ∫ Data ≥  01/05/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Verifica a necessidade de executar a atualizacao de saldos  ∫±±
±±∫          ≥Na impress„o dos relatÛrios quando utilizado MV_ATUSAL = N  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function Need2Reproc(dDataFim,cMoeda,cTpSald,dDataIni)
Local lReturn 		:= .F.
DEFAULT dDataIni 	:= CTOD("01/01/80")

dData := GetCv7Date(cTpSald,cMoeda)

If dDataFim > dData
	dDataIni := dData
	If !IsBlind()
	   lReturn := MsgYesNo(STR0018+CRLF+STR0019+CRLF+STR0020,STR0021+" Saldo: "+cTPSald)	///"Saldos Desatualizados"#"Refazer os saldos p/ o relatÛrio ?"#"Sim, efetua nova atualizaÁ„o de saldos"#"N„o, emite relatÛrio sem reprocessar saldos."
		If !lReturn .And. Type('TITULO') # "U" .and. Titulo <> Nil
			If !("Rascunho"$Titulo)
				TITULO := alltrim(TITULO)+" - Rascunho"
			EndIf
		EndIf
	EndIf
EndIf

Return(lReturn)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GetSldEnt ∫Autor  ≥ Totvs              ∫ Data ≥  16/09/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Retorna o saldo de uma entidade gerencial em tempo de      ∫±±
±±∫          ≥ processamento                                              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥ cEntidade = Codigo da Entidade em que se deseja consultar  ∫±±
±±∫          ≥ cCodVis   = Cod da visao gerencial da entidade chamadora.  ∫±±
±±∫          ≥ cOrdVis   = Cod da ordem da visao gerenc da entid chamadora∫±±
±±∫          ≥ nTpSaldo  = tipo de saldo a ser retornado.                 ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function GetSldEnt( cEntidade, cCodVis, cOrdVis, nTpSaldo, cArqTmp)
Local aAreaCTS		:= CTS->( GetArea() )						// Posicao atual da tabela CTS (seguranca)
Local aAreaTMP													// Posicao atual do arquivo temporario (seguranca)
Local aReturn		:= {}										// Array com os saldos

Default cCodVis		:= CTS->CTS_CODPLA
Default cOrdVis		:= CTS->CTS_ORDEM
Default nTpSaldo	:= 1										// Saldo Atual

Default cArqTmp		:= "cArqTmp"

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Protecao para evitar array out of bounds pois esta funcao≥
//≥podera ser chamada a partir de formulas.                 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If nTpSaldo < 0 .OR. nTpSaldo > 8
	nTpSaldo := 1
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Verifica se a entidade que esta consultando eh superior em≥
//≥relacao a  entidade que  se quer o saldo  e verifica se  a≥
//≥entidade  referenciada  no  parametro  faz parte da  visao≥
//≥gerencial da entidade que esta consultando o saldo.       ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If Select( cArqTmp ) > 0
	aAreaTmp := &(cArqTmp)->( GetArea() )

	DbSelectArea( "CTS" )
	CTS->( DbSetOrder( 2 ) )
	If CTS->( DbSeek( xFilial( "CTS" ) + cCodVis + cEntidade ) )
		If Empty( cOrdVis ) .OR. cOrdVis > CTS->CTS_ORDEM
			DbSelectArea( cArqTmp )
			&(cArqTmp)->( DbSetOrder( 1 ) )
			If &(cArqTmp)->( DbSeek( cEntidade ) )
				aAdd( aReturn, &(cArqTmp)->( SALDOATU   ) )			// 01- Saldo Atual
				aAdd( aReturn, &(cArqTmp)->( SALDODEB   ) )			// 02- Debito na Data
				aAdd( aReturn, &(cArqTmp)->( SALDOCRD   ) )			// 03- Credito na Data
				aAdd( aReturn, &(cArqTmp)->( SALDOATUDB ) )			// 04- Saldo Atual Devedor
				aAdd( aReturn, &(cArqTmp)->( SALDOATUCR ) )			// 05- Saldo Atual Credor
				aAdd( aReturn, &(cArqTmp)->( SALDOANT   ) )			// 06- Saldo Anterior
				aAdd( aReturn, &(cArqTmp)->( SALDOANTDB ) )			// 07- Saldo Anterior Devedor
				aAdd( aReturn, &(cArqTmp)->( SALDOANTCR ) )			// 08- Saldo Anterior Credor
				aAdd( aReturn, &(cArqTmp)->( SALDOATU - SALDOANT) )    // 09- Saldo Anterior Credor

			EndIf
		EndIf
	EndIf

	RestArea( aAreaTMP )
	RestArea( aAreaCTS )
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Se o tipo de saldo informado for igual a zero (0), a funcao≥
//≥deve retornar o array com todos os saldos.                 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If nTpSaldo == 0
Return aReturn
EndIf

Return aReturn[ nTpSaldo ]


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GetVarEnt ∫Autor  ≥ Totvs              ∫ Data ≥  14/10/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Retorna o saldo de uma entidade gerencial em tempo de      ∫±±
±±∫          ≥ processamento                                              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥ cEntidade = Codigo da Entidade em que se deseja consultar  ∫±±
±±∫          ≥ cCodVis   = Cod da visao gerencial da entidade chamadora.  ∫±±
±±∫          ≥ cOrdVis   = Cod da ordem da visao gerenc da entid chamadora∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function GetVarEnt( cEntidade, cCodVis, cOrdVis )

Local nSaldo     := 0										// Saldo
Local aAreaCTS   := CTS->( GetArea() )				// Posicao atual da tabela CTS (seguranca)
Local aAreaTMP													// Posicao atual do arquivo temporario (seguranca)
Default cCodVis  := CTS->CTS_CODPLA
Default cOrdVis  := CTS->CTS_ORDEM

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Verifica se a entidade que esta consultando eh superior em≥
//≥relacao a  entidade que  se quer o saldo  e verifica se  a≥
//≥entidade  referenciada  no  parametro  faz parte da  visao≥
//≥gerencial da entidade que esta consultando o saldo.       ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If Select( "cArqTmp" ) > 0
	aAreaTmp := cArqTmp->( GetArea() )

	DbSelectArea( "CTS" )
	CTS->( DbSetOrder( 2 ) )
	If CTS->( DbSeek( xFilial( "CTS" ) + cCodVis + cEntidade ) )
		//If cOrdVis > CTS->CTS_ORDEM //Verificar com Rafael
			DbSelectArea( "cArqTmp" )
			cArqTmp->( DbSetOrder( 1 ) )
			If cArqTmp->( DbSeek( cEntidade ) )
				nSaldo := cArqTmp->(SALDOATU-SALDOANT)
			EndIf
		//EndIf
	EndIf

	RestArea( aAreaTMP )
	RestArea( aAreaCTS )
EndIf

Return nSaldo

//-------------------------------------------------------------------
/*{Protheus.doc} CtbCta3Ent
Gravacao das entidades analiticas no arq. temporario para codebase

@author Alvaro Camillo Neto

@param oMeter	    Controle da regua
@param oText 	    Controle da regua
@param oDlg  	    Janela
@param lEnd  	    Controle da regua -> finalizar
@param dDataIni     Data Inicial de processamento
@param dDataFim     Data Final de processamento
@param cContaIni    Codigo Conta Inicial
@param cContaFim    Codigo Conta Final
@param cCCIni       Codigo C.Custo Inicial
@param cCCFim       Codigo C.Custo Final
@param cItemIni     Codigo Item Inicial
@param cItemFim     Codigo Item Final
@param cClVlIni     Codigo Cl.Valor Inicial
@param cClVlFim     Codigo Cl.Valor Final
@param cMoeda       Moeda
@param cSaldos      Tipos de Saldo a serem processados
@param aSetOfBook   Matriz de configuracao de livros
@param nTamCta      Tamanho da conta
@param cSegmento    Indica qual o segmento ser· filtrado
@param cSegIni      Conteudo inicial do segmento
@param cSegFim      Conteudo Final do segmento
@param cFiltSegm    Indica se filtrara ou nao segmento
@param lNImpMov     Indica se imprime ou nao a coluna movimento
@param cAlias       Alias para regua
@param cHeader      Entidade do cabecalho do relatorio
@param cIdent       Identificador do arquivo a ser processado
@param lCusto       Considera Centro de Custo?
@param lItem        Considera Item Contabil?
@param lCLVL        Considera Classe de Valor?
@param lAtSldBase   Indica se deve chamar rot atual. saldo basico
@param nInicio      Moeda Inicial (p/ atualizar saldo)
@param nFinal       Moeda Final (p/ atualizar saldo)
@param cFilde       Filial inicial (p/ atualizar saldo)
@param cFilAte      Filial final (p/atualizar saldo)
@param lImpAntLP    Imprime lancamentos Lucros e Perdas?
@param dDataLP      Data ultimo Lucros e Perdas
@param nDivide      Divide valores (100,1000,1000000)
@param lVlrZerado   Grava ou nao valores zerados no arq temporario


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CtbCta3Ent(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cContaIni,;
					cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,cMoeda,;
					cSaldos,aSetOfBook,nTamCta,cSegmento,cSegIni,cSegFim,cFiltSegm,lNImpMov,cAlias,cHeader,;
					lCusto,lItem,lClvl,lAtSldBase,nInicio,nFinal,cFilDe,cFilAte,lImpAntLP,dDataLP,;
					nDivide,lVlrZerado)

Local aSaveArea		:= GetArea()
Local aSaldoAnt		:= {}
Local aSaldoAtu		:= {}

Local cConta		:= ""
Local cCusto		:= ""
Local cItem			:= ""
Local cClVl			:= ""
Local cDescCta		:= ""
Local cDescCC		:= ""
Local cDescItem		:= ""
Local cDescClVl		:= ""
Local cMascara		:= ""

Local nSaldoAntD	:= 0
Local nSaldoAntC	:= 0
Local nSldAnt		:= 0
Local nSaldoAtuD	:= 0
Local nSaldoAtuC	:= 0
Local nSldAtu		:= 0
Local nSaldoDeb		:= 0
Local nSaldoCrd		:= 0
Local nMovimento	:= 0
Local nTamItem		:= Len(CriaVar("CTD_ITEM"))
Local nTamClVl		:= Len(CriaVar("CTH_CLVL"))
Local nCont			:= 0
Local nPos			:= 0
Local nDigitos		:= 0

Default nDivide      := 1

If cAlias == "CTI"
	If cHeader == "CTT"
		If !Empty(aSetOfBook[2])
			cMascara	:= aSetOfBook[2]
		EndIf
	EndIf
EndIf

// Verifica Filtragem por Segmento da Entidade
If !Empty(cSegmento)
	dbSelectArea("CTM")
	dbSetOrder(1)
	If MsSeek(xFilial()+cMascara)
		While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cMascara
			nPos += Val(CTM->CTM_DIGITO)
			If CTM->CTM_SEGMEN == cSegmento
				nPos -= Val(CTM->CTM_DIGITO)
				nPos ++
				nDigitos := Val(CTM->CTM_DIGITO)
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf
EndIf



If cAlias == "CTI"		//Se for Balancete C.C x Cta x Item
	If cHeader == "CTT"

		dbSelectArea("CTT")
		dbSetOrder(1)
		MsSeek(xFilial()+cCCIni,.T.)
		While !Eof() .And. CTT->CTT_FILIAL == xFilial() .And. CTT->CTT_CUSTO <= cCCFim

			If CTT->CTT_CLASSE == "1"
				dbSkip()
				Loop
			EndIf

			cCusto	:= CTT->CTT_CUSTO
			cDescCC := &("CTT->CTT_DESC"+cMoeda)

			If Empty(cDescCC)// Caso nao preencher descricao da moeda selecionada
				cDescCC := CTT->CTT_DESC01
			Endif

			dbSelectArea("CT1")
			dbSetOrder(1)
			MsSeek(xFilial()+cContaIni,.T.)

			While !Eof() .And. CT1->CT1_FILIAL == xFilial() .And. CT1->CT1_CONTA <= cContaFim

				If CT1->CT1_CLASSE == "1"
					dbSkip()
					Loop
				EndIf

				cConta	:= CT1->CT1_CONTA

				cDescCta := &("CT1->CT1_DESC"+cMoeda)

				If Empty(cDescCta)// Caso nao preencher descricao da moeda selecionada
					cDescCta := CT1->CT1_DESC01
				Endif

				//Caso faca filtragem por segmento de item,verifico se esta dentro
				//da solicitacao feita pelo usuario.
				If !Empty(cSegmento)
					If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
						If  !(Substr(cConta,nPos,nDigitos) $ (cFiltSegm) )
							dbSkip()
							Loop
						EndIf
					Else
						If 	Substr(cConta,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
							Substr(cConta,nPos,nDigitos) > Alltrim(cSegFim)
							dbSkip()
							Loop
						EndIf
					Endif
				EndIf


				aSaldoAnt := SaldoCT3(	cConta,cCusto,dDataIni,cMoeda,cSaldos,,	lImpAntLP,dDataLP)
				aSaldoAtu := SaldoCT3(	cConta,cCusto,dDataFim,cMoeda,cSaldos,,	lImpAntLP,dDataLP)

				nSaldoAntD 	:= aSaldoAnt[7]
				nSaldoAntC 	:= aSaldoAnt[8]
				nSldAnt		:= nSaldoAntC - nSaldoAntD

				nSaldoAtuD 	:= aSaldoAtu[4]
				nSaldoAtuC 	:= aSaldoAtu[5]
				nSldAtu		:= nSaldoAtuC - nSaldoAtuD

				nSaldoDeb  	:= nSaldoAtuD - nSaldoAntD
				nSaldoCrd  	:= nSaldoAtuC - nSaldoAntC

			    If nDivide > 1
					nSaldoDeb	:= Round(NoRound((nSaldoDeb/nDivide),3),2)
					nSaldoCrd	:= Round(NoRound((nSaldoCrd/nDivide),3),2)
				EndIf

				nMovimento	:= nSaldoCrd-nSaldoDeb

				If (nMovimento = 0 .And. nSldAnt = 0 .And. nSldAtu = 0) .And. ;
					(nSaldoDeb = 0 .And. nSaldoCrd = 0)
					dbSkip()
					Loop
				EndIf

				dbSelectArea("cArqTmp")
				dbSetOrder(1)
				If !MsSeek(cCusto+cConta+Space(nTamItem)+Space(nTamClVl))
					dbAppend()
					Replace CONTA 		With CT1->CT1_CONTA
					Replace DESCCTA		With cDescCta
 					Replace NORMAL    	With CT1->CT1_NORMAL
	 				Replace TIPOCONTA 	With CT1->CT1_CLASSE
					Replace GRUPO		With CT1->CT1_GRUPO
					Replace CTARES      With CT1->CT1_RES
					Replace SUPERIOR    With CT1->CT1_CTASUP
					Replace CUSTO		With cCusto
					Replace CCRES		With CTT->CTT_RES
					Replace TIPOCC  	With CTT->CTT_CLASSE
					Replace DESCCC		With cDescCC
				Endif


				If nDivide > 1
					For nCont := 1 To Len(aSaldoAnt)
						aSaldoAnt[nCont] := Round(NoRound((aSaldoAnt[nCont]/nDivide),3),2)
					Next nCont
					For nCont := 1 To Len(aSaldoAtu)
						aSaldoAtu[nCont] := Round(NoRound((aSaldoAtu[nCont]/nDivide),3),2)
					Next nCont
				EndIf

				dbSelectArea("cArqTmp")
				dbSetOrder(1)
				Replace SALDOANT With aSaldoAnt[6]
				Replace SALDOATU With aSaldoAtu[1]			// Saldo Atual

				Replace  SALDODEB With nSaldoDeb				// Saldo Debito
				Replace  SALDOCRD With nSaldoCrd				// Saldo Credito
				If !lNImpMov
					Replace MOVIMENTO With nSaldoCrd-nSaldoDeb
				Endif

				If lItem
					dbSelectArea("CTD")
					dbSetOrder(1)	//Codigo de Item
					MsSeek(xFilial()+cItemIni,.T.)
					While !Eof() .And. CTD->CTD_FILIAL == xFilial() .And. CTD->CTD_ITEM <= cItemFim

	 					If CTD->CTD_CLASSE == "1"
							dbSkip()
							Loop
						EndIf

						cItem	:= CTD->CTD_ITEM

						cDescItem := &("CTD->CTD_DESC"+cMoeda)

						If Empty(cDescItem)// Caso nao preencher descricao da moeda selecionada
							cDescItem := CTD->CTD_DESC01
						Endif

						//Caso faca filtragem por segmento de item,verifico se esta dentro
						//da solicitacao feita pelo usuario.
						If !Empty(cSegmento)
							If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
								If  !(Substr(cConta,nPos,nDigitos) $ (cFiltSegm) )
									dbSkip()
									Loop
								EndIf
							Else
								If 	Substr(cConta,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
									Substr(cConta,nPos,nDigitos) > Alltrim(cSegFim)
									dbSkip()
									Loop
								EndIf
							Endif
						EndIf

						aSaldoAnt := SaldoCT4(	cConta,cCusto,cItem,dDataIni,cMoeda,cSaldos,,lImpAntLP,dDataLP)
						aSaldoAtu := SaldoCT4(	cConta,cCusto,cItem,dDataFim,cMoeda,cSaldos,,lImpAntLP,dDataLP)

						nSaldoAntD 	:= aSaldoAnt[7]
						nSaldoAntC 	:= aSaldoAnt[8]
						nSldAnt		:= nSaldoAntC - nSaldoAntD

						nSaldoAtuD 	:= aSaldoAtu[4]
						nSaldoAtuC 	:= aSaldoAtu[5]
						nSldAtu		:= nSaldoAtuC - nSaldoAtuD

						nSaldoDeb  	:= nSaldoAtuD - nSaldoAntD
						nSaldoCrd  	:= nSaldoAtuC - nSaldoAntC

					    If nDivide > 1
							nSaldoDeb	:= Round(NoRound((nSaldoDeb/nDivide),3),2)
							nSaldoCrd	:= Round(NoRound((nSaldoCrd/nDivide),3),2)
						EndIf

						nMovimento	:= nSaldoCrd-nSaldoDeb

						If (nMovimento = 0 .And. nSldAnt = 0 .And. nSldAtu = 0) .And. ;
							(nSaldoDeb = 0 .And. nSaldoCrd = 0)
							dbSkip()
							Loop
						EndIf

						dbSelectArea("cArqTmp")
						dbSetOrder(1)
						If !MsSeek(cCusto+cConta+cItem)
							dbAppend()
							Replace CONTA 		With CT1->CT1_CONTA
							Replace DESCCTA		With cDescCta
		 					Replace NORMAL    	With CT1->CT1_NORMAL
			 				Replace TIPOCONTA 	With CT1->CT1_CLASSE
							Replace GRUPO		With CT1->CT1_GRUPO
							Replace CTARES      With CT1->CT1_RES
							Replace SUPERIOR    With CT1->CT1_CTASUP
							Replace CUSTO		With cCusto
							Replace CCRES		With CTT->CTT_RES
							Replace TIPOCC  	With CTT->CTT_CLASSE
							Replace DESCCC		With cDescCC
							Replace ITEM		With cItem
							Replace DESCITEM	With cDescItem
							Replace ITEMRES		With CTD->CTD_RES
						Endif

						If nDivide > 1
							For nCont := 1 To Len(aSaldoAnt)
								aSaldoAnt[nCont] := Round(NoRound((aSaldoAnt[nCont]/nDivide),3),2)
							Next nCont
							For nCont := 1 To Len(aSaldoAtu)
								aSaldoAtu[nCont] := Round(NoRound((aSaldoAtu[nCont]/nDivide),3),2)
							Next nCont
						EndIf

						dbSelectArea("cArqTmp")
						dbSetOrder(1)
						Replace SALDOANT With aSaldoAnt[6]
						Replace SALDOATU With aSaldoAtu[1]			// Saldo Atual

						Replace  SALDODEB With nSaldoDeb				// Saldo Debito
						Replace  SALDOCRD With nSaldoCrd				// Saldo Credito
						If !lNImpMov
							Replace MOVIMENTO With nSaldoCrd-nSaldoDeb
						Endif

						If lClVl
							dbSelectArea("CTH")
							dbSetOrder(1)	//Codigo da Cl.Valor
							MsSeek(xFilial()+cClVlIni,.T.)
							While !Eof() .And. CTH->CTH_FILIAL == xFilial() .And. CTH->CTH_CLVL <= cClVlFim

			 					If CTH->CTH_CLASSE == "1"
									dbSkip()
									Loop
								EndIf

								cClVl	:= CTH->CTH_CLVL

								cDescClVl := &("CTH->CTH_DESC"+cMoeda)

								If Empty(cDescClVl)// Caso nao preencher descricao da moeda selecionada
									cDescClVl := CTH->CTH_DESC01
								Endif

								//Caso faca filtragem por segmento de item,verifico se esta dentro
								//da solicitacao feita pelo usuario.
								If !Empty(cSegmento)
									If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
										If  !(Substr(cConta,nPos,nDigitos) $ (cFiltSegm) )
											dbSkip()
											Loop
										EndIf
									Else
										If 	Substr(cConta,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
											Substr(cConta,nPos,nDigitos) > Alltrim(cSegFim)
											dbSkip()
											Loop
										EndIf
									Endif
								EndIf

								aSaldoAnt := SaldoCTI(	cConta,cCusto,cItem,cClVl,dDataIni,cMoeda,cSaldos,,lImpAntLP,dDataLP)
								aSaldoAtu := SaldoCTI(	cConta,cCusto,cItem,cClVl,dDataFim,cMoeda,cSaldos,,lImpAntLP,dDataLP)

								nSaldoAntD 	:= aSaldoAnt[7]
								nSaldoAntC 	:= aSaldoAnt[8]
								nSldAnt		:= nSaldoAntC - nSaldoAntD

								nSaldoAtuD 	:= aSaldoAtu[4]
								nSaldoAtuC 	:= aSaldoAtu[5]
								nSldAtu		:= nSaldoAtuC - nSaldoAtuD

								nSaldoDeb  	:= nSaldoAtuD - nSaldoAntD
								nSaldoCrd  	:= nSaldoAtuC - nSaldoAntC

							    If nDivide > 1
									nSaldoDeb	:= Round(NoRound((nSaldoDeb/nDivide),3),2)
									nSaldoCrd	:= Round(NoRound((nSaldoCrd/nDivide),3),2)
								EndIf

								nMovimento	:= nSaldoCrd-nSaldoDeb

								If (nMovimento = 0 .And. nSldAnt = 0 .And. nSldAtu = 0) .And. ;
									(nSaldoDeb = 0 .And. nSaldoCrd = 0)
									dbSkip()
									Loop
								EndIf

								dbSelectArea("cArqTmp")
								dbSetOrder(1)
								If !MsSeek(cCusto+cConta+cItem+cClVl)
									dbAppend()
									Replace CONTA 		With CT1->CT1_CONTA
									Replace DESCCTA		With cDescCta
				 					Replace NORMAL    	With CT1->CT1_NORMAL
					 				Replace TIPOCONTA 	With CT1->CT1_CLASSE
									Replace GRUPO		With CT1->CT1_GRUPO
									Replace CTARES      With CT1->CT1_RES
									Replace SUPERIOR    With CT1->CT1_CTASUP
									Replace CUSTO		With cCusto
									Replace CCRES		With CTT->CTT_RES
									Replace TIPOCC  	With CTT->CTT_CLASSE
									Replace DESCCC		With cDescCC
									Replace ITEM		With cItem
									Replace DESCITEM	With cDescItem
									Replace CLVL		With cClVl
									Replace DESCCLVL	With cDescClVl
									Replace CLVLRES		With CTH->CTH_RES
								Endif

								If nDivide > 1
									For nCont := 1 To Len(aSaldoAnt)
										aSaldoAnt[nCont] := Round(NoRound((aSaldoAnt[nCont]/nDivide),3),2)
									Next nCont
									For nCont := 1 To Len(aSaldoAtu)
										aSaldoAtu[nCont] := Round(NoRound((aSaldoAtu[nCont]/nDivide),3),2)
									Next nCont
								EndIf

								dbSelectArea("cArqTmp")
								dbSetOrder(1)
								Replace SALDOANT With aSaldoAnt[6]
								Replace SALDOATU With aSaldoAtu[1]			// Saldo Atual

								Replace  SALDODEB With nSaldoDeb				// Saldo Debito
								Replace  SALDOCRD With nSaldoCrd				// Saldo Credito
								If !lNImpMov
									Replace MOVIMENTO With nSaldoCrd-nSaldoDeb
								Endif
								dbSelectArea("CTH")
								dbSkip()
							End
						EndIf

						dbSelectArea("CTD")
						dbSkip()
					End
				EndIf

				//Classe de Valor / C.Custo / Conta
				If lClVl
					cItem	:= Space(nTamItem)
					dbSelectArea("CTH")
					dbSetOrder(1)	//Codigo da Cl.Valor
					MsSeek(xFilial()+cClVlIni,.T.)
					While !Eof() .And. CTH->CTH_FILIAL == xFilial() .And. CTH->CTH_CLVL <= cClVlFim

	 					If CTH->CTH_CLASSE == "1"
							dbSkip()
							Loop
						EndIf

						cClVl	:= CTH->CTH_CLVL

						cDescClVl := &("CTH->CTH_DESC"+cMoeda)

						If Empty(cDescClVl)// Caso nao preencher descricao da moeda selecionada
							cDescClVl := CTH->CTH_DESC01
						Endif

						//Caso faca filtragem por segmento de item,verifico se esta dentro
						//da solicitacao feita pelo usuario.
						If !Empty(cSegmento)
							If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
								If  !(Substr(cConta,nPos,nDigitos) $ (cFiltSegm) )
									dbSkip()
									Loop
								EndIf
							Else
								If 	Substr(cConta,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
									Substr(cConta,nPos,nDigitos) > Alltrim(cSegFim)
									dbSkip()
									Loop
								EndIf
							Endif
						EndIf

						aSaldoAnt := SaldoCTI(	cConta,cCusto,cItem,cClVl,dDataIni,cMoeda,cSaldos,,lImpAntLP,dDataLP)
						aSaldoAtu := SaldoCTI(	cConta,cCusto,cItem,cClVl,dDataFim,cMoeda,cSaldos,,lImpAntLP,dDataLP)

						nSaldoAntD 	:= aSaldoAnt[7]
						nSaldoAntC 	:= aSaldoAnt[8]
						nSldAnt		:= nSaldoAntC - nSaldoAntD

						nSaldoAtuD 	:= aSaldoAtu[4]
						nSaldoAtuC 	:= aSaldoAtu[5]
						nSldAtu		:= nSaldoAtuC - nSaldoAtuD

						nSaldoDeb  	:= nSaldoAtuD - nSaldoAntD
						nSaldoCrd  	:= nSaldoAtuC - nSaldoAntC

					    If nDivide > 1
							nSaldoDeb	:= Round(NoRound((nSaldoDeb/nDivide),3),2)
							nSaldoCrd	:= Round(NoRound((nSaldoCrd/nDivide),3),2)
						EndIf

						nMovimento	:= nSaldoCrd-nSaldoDeb

						If (nMovimento = 0 .And. nSldAnt = 0 .And. nSldAtu = 0) .And. ;
							(nSaldoDeb = 0 .And. nSaldoCrd = 0)
							dbSkip()
							Loop
						EndIf

						dbSelectArea("cArqTmp")
						dbSetOrder(1)
						If !MsSeek(cCusto+cConta+Space(nTamItem)+cClVl)
							dbAppend()
							Replace CONTA 		With CT1->CT1_CONTA
							Replace DESCCTA		With cDescCta
		 					Replace NORMAL    	With CT1->CT1_NORMAL
			 				Replace TIPOCONTA 	With CT1->CT1_CLASSE
							Replace GRUPO		With CT1->CT1_GRUPO
							Replace CTARES      With CT1->CT1_RES
							Replace SUPERIOR    With CT1->CT1_CTASUP
							Replace CUSTO		With cCusto
							Replace CCRES		With CTT->CTT_RES
							Replace TIPOCC  	With CTT->CTT_CLASSE
							Replace DESCCC		With cDescCC
							Replace CLVL		With cClVl
							Replace DESCCLVL	With cDescClVl
							Replace CLVLRES		With CTH->CTH_RES
						Endif

						If nDivide > 1
							For nCont := 1 To Len(aSaldoAnt)
								aSaldoAnt[nCont] := Round(NoRound((aSaldoAnt[nCont]/nDivide),3),2)
							Next nCont
							For nCont := 1 To Len(aSaldoAtu)
								aSaldoAtu[nCont] := Round(NoRound((aSaldoAtu[nCont]/nDivide),3),2)
							Next nCont
						EndIf

						dbSelectArea("cArqTmp")
						dbSetOrder(1)
						Replace SALDOANT With aSaldoAnt[6]
						Replace SALDOATU With aSaldoAtu[1]			// Saldo Atual

						Replace  SALDODEB With nSaldoDeb				// Saldo Debito
						Replace  SALDOCRD With nSaldoCrd				// Saldo Credito
						If !lNImpMov
							Replace MOVIMENTO With nSaldoCrd-nSaldoDeb
						Endif
						dbSelectArea("CTH")
						dbSkip()
					End
		        EndIf
				dbSelectArea("CT1")
		 		dbSkip()
			End
			dbSelectArea("CTT")
			dbSkip()
		End
    EndIf
EndIf

RestArea(aSaveArea)

Return()

//-------------------------------------------------------------------
/*{Protheus.doc} CVORECS
Retorna o nro de registros pendentes de atualizacao na tabela CVO.

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CVORecs(cFil)

aRet := CQARecs(cFil)

Return aRet


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥CTDelTmpFiles≥ Autor ≥ Bruno Sobieski        ≥ Data ≥ 21.06.08 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Limpa do banco de dados as teabelas temporarias criadas em al-≥±±
±±≥          ≥ guma funcoes de geracao do arquivo temporario da CTGerPlan()  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ CtbXSal                                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CTDelTmpFil()
Local nX

For nX:= 1 To Len( __aTmpTCFil )
	If TcCanOpen( __aTmpTCFil[nX] )
		TCDELFILE( __aTmpTCFil[nX] )
	Endif
Next

//DEVE SER VAZIO E NAO NULO, PARA EVITAR ERROS EM CHAMADAS DESDE OUTRAS ROTINAS
__aTmpTCFil	:=	{}

Return
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GetSldVis ∫Autor  ≥ Totvs              ∫ Data ≥  02/02/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Retorna o saldo de uma visao gerencial                     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥ cCodVis   = Cod da visao gerencial da entidade chamadora.  ∫±±
±±∫          ≥ nTpSaldo  = o saldo que devera ser retornado.              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function GetSldVis( 	cCodVis, nTpSaldo, oMeter, oText, oDlg, ;
						lEnd, dFinalA, dFinal, cSaldos, lVlrZerado, ;
						cMoedaDesc, lMovPeriodo, aSetOfBook, cMoeda, ;
						lImpAntLP, dDataLP, lConsSaldo, cEntidade,aSelFil )

Local aAreaCTS		:= CTS->( GetArea() )						// Posicao atual da tabela CTS (seguranca)
Local aReturn		:= {0,0,0,0,0,0,0,0}						// Array com os saldos
Local aAux   		:= {}										// Array com os saldos
Local nInc			:= 1
Local aCpyBook		:= aClone( aSetOfBook )
Local cArqTmp2		:= NIL // ""

Default nTpSaldo	:= 1										// Saldo Atual
Default cEntidade := ""
Default aSelFil := {}

If Empty(cEntidade) // Caso n„o seja informada a entidade totalizadora
	cEntidade := CTBTotVis(cCodVis)
EndIF
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Protecao para evitar array out of bounds pois esta funcao≥
//≥podera ser chamada a partir de formulas.                 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If nTpSaldo < 0 .OR. nTpSaldo > 8
	nTpSaldo := 1
EndIf

DbSelectArea( "CTS" )
CTS->( DbSetOrder( 2 ) )
If CTS->( DbSeek( xFilial( "CTS" ) + cCodVis ) )
	aCpyBook[5] := cCodVis
	CTGerPlan(		/*01*/,;
		/*02*/,;
		/*03*/,;
		/*04*/,;
		/*05*/@cArqTmp2,;
		/*06*/dFinalA+1,;
		/*07*/dFinal,;
		/*08*/"",;
		/*09*/"",;
		/*10*/"",;
		/*11*/Repl("Z", TamSx3("CT1_CONTA")[1]),;
		/*12*/"",;
		/*13*/Repl("Z", TamSx3("CTT_CUSTO")[1]),;
		/*14*/"",;
		/*15*/Repl("Z", TamSx3("CTD_ITEM")[1]),;
		/*16*/"",;
		/*17*/Repl("Z", TamSx3("CTH_CLVL")[1]),;
		/*18*/cMoeda,;
		/*19*/cSaldos,;
		/*20*/aCpyBook,;
		/*21*/,;
		/*22*/"",;
		/*23*/Repl("Z", 20),;
		/*24*/,;
		/*25*/,;
		/*26*/,;
		/*27*/,;
		/*28*/,;
		/*29*/lImpAntLP,;
		/*30*/dDataLP,;
		/*31*/,;
		/*32*/lVlrZerado,;
		/*33*/,;
		/*34*/,;
		/*35*/,;
		/*36*/,;
		/*37*/,;
		/*38*/,;
		/*39*/,;
		/*40*/,;
		/*41*/,;
		/*42*/,;
		/*43*/,;
		/*44*/,;
		/*45*/,;
		/*46*/,;
		/*47*/,;
		/*48*/,;
		/*49*/,;
		/*50*/,;
		/*51*/,;
		/*52*/,;
		/*53*/,;
		/*54*/,;
		/*55*/,;
		/*56*/,;
		/*57*/cMoedaDesc,;
		/*58*/lMovPeriodo,;
		/*59*/aSelFil,;
		/*60*/,;
		/*61*/.T.,;
		/*62*/lConsSaldo,;
		/*63*/,;
		/*64*/ "cSldVis") // 64-cArqAux     = Arquivo auxiliar permitindo a recursividade

	While CTS->( !Eof() ) .AND. CTS->CTS_FILIAL == xFilial( "CTS" ) .AND. CTS->CTS_CODPLA == cCodVis
		If AllTrim( CTS->CTS_CONTAG ) == Alltrim(cEntidade)
			aAux := GetSldEnt( CTS->CTS_CONTAG /* cEntidade */,;
				CTS->CTS_CODPLA /* cCodVis */,;
				"" /* cOrdVis */,;
				0 /* nTpSaldo 0->RETORNA ARRAY */,;
				"cSldVis" /* cArqTmp */;
				)
			For nInc := 1 To Len( aReturn )
				aReturn[nInc] += aAux[nInc]
			Next
		EndIf

		CTS->( DbSkip() )
	End

	cSldVis->( DbCloseArea() )
EndIf

RestArea( aAreaCTS )

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Se o tipo de saldo informado for igual a zero (0), a funcao≥
//≥deve retornar o array com todos os saldos.                 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If nTpSaldo == 0
Return aReturn
EndIf


Return aReturn[ nTpSaldo ]

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CTBTotVis  ∫Autor  ≥Alvaro Camillo Neto∫ Data ≥  09/08/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Retorna o codigo da entidade totalizadora da vis„o          ∫±±
±±∫          ≥gerencial                                                   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function CTBTotVis(cVisao)
Local aArea 		:= GetArea()
Local cEntidade   := ""
Local cFilCTS		:= xFilial("CTS")
CTS->(dbSetOrder(1)) //CTS_FILIAL+CTS_CODPLA+CTS_ORDEM+CTS_LINHA
CTS->(MsSeek(cFilCTS + cVisao ))

While CTS->(CTS_FILIAL+CTS_CODPLA) == cFilCTS + cVisao .And. CTS->(!EOF())
	If CTS->CTS_TOTVIS == '1'
		cEntidade := CTS->CTS_CONTAG
		Exit
	EndIf
	CTS->(dbSkip())
EndDo

RestArea(aArea)

Return cEntidade

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GetSldMov ∫Autor  ≥ Totvs              ∫ Data ≥  20/08/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Retorna o movimento do periodo de um determinada entidade  ∫±±
±±∫          ≥ gerencial                                                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥ cEntidade = Codigo da Entidade em que se deseja consultar  ∫±±
±±∫          ≥ cCodVis   = Cod da visao gerencial da entidade chamadora.  ∫±±
±±∫          ≥ cOrdVis   = Cod da ordem da visao gerenc da entid chamadora∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function GetSldMov( cConteudo, dDataIni, dDataFim, cMoeda,aSelFil )
Local aSaldo	 	:= { 0, 0 } // Saldo Anterior; Saldo Atual
Local aResult		:= {}
Local aFiltros		:= CTBSplit( cConteudo, ",", 9 )
Local cSPMVT		:= xProcedure( "CTBMVT" )
Local cContaBase	:= ""
Local cCustoBase	:= ""
Local cItemBase		:= ""
Local cClassBase	:= ""
Local cContaPar		:= ""
Local cCustoPar		:= ""
Local cItemPar		:= ""
Local cClassPar		:= ""
Local cOrigem		:= ""

Local aArea 		:= GetArea()
Local cFil			:= ""
Local nX				:= 0

DEFAULT cMoeda		:= "01"
Default aSelFil := {}


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Tratamento Multifilial≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If Len(aSelFil) > 1 .And. !Empty(xFilial("CT2"))
	For nX := 1 to Len(aSelFil)
		cFil += xFilial("CT2",aSelFil[nX]) + "/"
	Next nX
	cFil := Left(cFil,Len(cFil)-1)
	cFil := FormatIn(cFil,"/")
Else
	cFil := xFilial("CT2")
EndIf

//Atribui em variaveis para melhor entendimento
cContaBase	:= PADR(aFiltros[1], TamSX3("CT2_DEBITO")[1]) 	// Este item eh obrigatorio
cCustoBase	:= PADR(IIF( aFiltros[2] == NIL, "", aFiltros[2] ), TamSX3("CT2_CCD")[1])
cItemBase	:= PADR(IIF( aFiltros[3] == NIL, "", aFiltros[3] ), TamSX3("CT2_ITEMD")[1])
cClassBase	:= PADR(IIF( aFiltros[4] == NIL, "", aFiltros[4] ), TamSX3("CT2_CLVLDB")[1])
cContaPar	:= PADR(IIF( aFiltros[5] == NIL, "", aFiltros[5] ), TamSX3("CT2_DEBITO")[1])
cCustoPar	:= PADR(IIF( aFiltros[6] == NIL, "", aFiltros[6] ), TamSX3("CT2_CCD")[1])
cItemPar	:= PADR(IIF( aFiltros[7] == NIL, "", aFiltros[7] ), TamSX3("CT2_ITEMD")[1])
cClassPar	:= PADR(IIF( aFiltros[8] == NIL, "", aFiltros[8] ), TamSX3("CT2_CLVLDB")[1])
cOrigem		:= PADR(IIF( aFiltros[9] == NIL, "", aFiltros[9] ), TamSX3("CT2_ORIGEM")[1])

CriaSPMVT(cFil)
lSPMVT := TCSPExist( cSPMVT )

If Select( "cArqTmp" ) > 0
	If lSPMVT
		// Executar procedure
		aResult	:= TCSPEXEC( 	xProcedures( "CTBMVT" ),;
								DtoS( dDataIni ),;				//Data Inicial
								DtoS( dDataFim ),;				//Data Final
	 							cContaBase,;					//Conta Debito
	 							cCustoBase,;					//C.C Debito
	 							cItemBase,;						//Item Cont. Debito
	 							cClassBase,;					//Classe Vl. Debito
	 							cContaPar,;						//Conta Credito
	 							cCustoPar,;						//C.C Credito
	 							cItemPar,;						//Item Cont. Credito
	 							cClassPar,;						//Classe Vl. Credito
	 							cOrigem,;						//Origem do Lancamento
	 							cMoeda )							//Moeda

		If Empty( aResult )
			If !__lBlind
				MsgAlert( STR0028 + " " + cProc + ": " + TCSqlError() ) // "Erro executando a Stored Procedure"
			EndIf

		ElseIf aResult[1] != 6
			If !__lBlind
				MsgAlert( STR0029 + ": " + TCSqlError() ) // "Erro calculando movimentos"
			EndIf

			 // aResult[1] = 1 -> Erro calculando mvto deb ant
			 // aResult[1] = 2 -> Nao passou nenhum dos prioritarios (conta base, ccusto base, item base ou ClVl base)
			 // aResult[1] = 3 -> Erro calculando mvto cred ant
			 // aResult[1] = 4 -> Erro calculando mvto deb
			 // aResult[1] = 5 -> Erro calculando mvto cred
			 // aResult[1] = 6 -> Ok
			 // aResult[1] < 1 ou > 6 -> ?????????
		Else // Tudo Ok !
			 // aResult[2] = Movimento Ant
			 // aResult[3] = Movimento Atu
		EndIf
	EndIf

	If !Empty( aResult ) .AND. Len( aResult ) >= 3
		aSaldo := { aResult[2], aResult[3] } // Saldo Anterior; Saldo Atual
	EndIf
EndIf

RestArea( aArea )

Return aSaldo

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CTBXSLD   ∫Autor  ≥ Acacio Egas        ∫ Data ≥  11/24/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ AtualizaÁ„o de saldo por cubo.                             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ SIGACTB                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function CtbAtuSld(cAliasCT2,cConfig,cMoeda,cTipoMov,nValor,dData)

Local aArea		:= GetArea()
Local aAreaCVX	:= CTX->(GetArea())
Local cChave	:= ""
Local nPos		:= 1
Local lNotBlind	:= !IsBlind()
Local nX,nY

Default cAliasCT2	 	:= "CT2"

If aCubsCTB == NIL
	aCubsCTB := CTB_ChvCube()
EndIf

dbSelectArea("CVX")
dbSetOrder(1)
dbSelectArea("CVY")
dbSetOrder(1)

 For nX := 1 to Len(aCubsCTB)
		For nY:=1 to Len(aCubsCTB[nX,2])
			If cTipoMov=="D"
				cChave += If(nY>1,"+","") + "CT2->" + aCubsCTB[nX,2,nY,5,1]
			Else
				cChave += If(nY>1,"+","") + "CT2->" + aCubsCTB[nX,2,nY,5,2]
			EndIf
		Next
		cChave := (cAliasCT2)->(Padr(&(StrTran(cChave,'CT2->',cAliasCT2+'->')),Len(CVX->CVX_CHAVE)))
		WriteSld( cAliasCT2 , aCubsCTB[nX,1] , cMoeda , cTipoMov , nValor , dData , cChave )

Next

RestArea(aAreaCVX)
RestArea(aArea)

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CTBXSLD   ∫Autor  ≥ Acacio Egas        ∫ Data ≥  11/24/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ AtualizaÁ„o de saldo por cubo.                             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ SIGACTB                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function WriteSld(cAliasCT2,cConfig,cMoeda,cTipoMov,nValor,dData,cChave)
Local aArea	 := GetArea()
Local dDataFim
Local aAreaSave
Local cChaver	 	:=	""
Local cChavSin	 	:=	""
Local lContinua   := .T. // continua com o processamento
Local nZ, nPosConfig, nPosTpSald, nPosCpo, aCubeAux
Local cTpSald:= ""

Private AUXCHAVE	:= ""
Private aResult  := {}

dbSelectArea("CVX")

//inicia o semaforo
While !LockByName(xFilial("CVX")+cConfig+cMoeda+cChave,.T.,.T.,.T.)
	Sleep(1)
EndDo

//grava a chave quebradas por nivel do cubo gerencial e tipo de saldo
nPosConfig := aScan(aCubsCTB, {|x| Alltrim(x[1]) == Alltrim(cConfig) } )  //procura o cubo

aCubeAux := aCubsCTB[nPosConfig, 2]

nPosTpSald := aScan(aCubeAux, {|x| Alltrim(x[1])=="SX5SL" }) //procura dimensao tipo saldo
If nPosTpSald > 0
	cTpsald := Substr(cChave,aCubeAux[nPosTpSald,3],aCubeAux[nPosTpSald,4])
EndIf

//**************************************
// Atualizacao dos movimentos diarios  *
//**************************************
If dbSeek(xFilial("CVX")+cConfig+cMoeda+cChave+DTOS(dData))

	//*************************
	// Altera saldo da chave  *
	//*************************
	RecLock("CVX",.F.)
	If cTipoMov == "C"
		CVX->CVX_SLDCRD += nValor
	ElseIf cTipoMov == "D"
		CVX->CVX_SLDDEB += nValor
	EndIf
	MsUnlock()
	CVX->( dbCommit() )
Else

	//**************************
	// Inclui chave com saldo  *
	//**************************
	RecLock("CVX",.T.)
	CVX->CVX_FILIAL := xFilial("CVX")
	CVX->CVX_CONFIG := cConfig
	CVX->CVX_DATA	:= dData
	CVX->CVX_MOEDA	:= cMoeda
	CVX->CVX_CHAVE 	:= cChave
	If cTipoMov == "C"
		CVX->CVX_SLDCRD := nValor
	ElseIf cTipoMov == "D"
		CVX->CVX_SLDDEB := nValor
	EndIf

	For nZ := 1 TO Len(aCubeAux)

		//grava a chave quebrada por dimensao do cubo
		If nZ == nPosTpSald
			nPosCpo := CVX->(FieldPos("CVX_TPSALD"))
		Else
			nPosCpo := CVX->(FieldPos("CVX_NIV"+StrZero(nZ, 2)))
		EndIf

		If nPosCpo > 0  //se o campo existe na tabela CVX entao grava
			CVX->(FieldPut(nPosCpo, Substr(cChave, aCubeAux[ nZ, 3], aCubeAux[ nZ, 4])))
		EndIf

	Next //nZ

	MsUnLock()
	CVX->( dbCommit() )
EndIf

//**************************************
// Atualizacao dos movimentos mensais  *
//**************************************
dbSelectArea("CVY")
If dbSeek(xFilial("CVY")+cConfig+cMoeda+cChave+DTOS(LastDay(dData)))
	//**************************
	// Altera saldo da chave   *
	//**************************
	RecLock("CVY",.F.)
	If cTipoMov == "C"
		CVY->CVY_SLDCRD += nValor
	ElseIf cTipoMov == "D"
		CVY->CVY_SLDDEB += nValor
	EndIf
	MsUnLock()
	AKS->( dbCommit() )
Else
	//***********************************
	//Pega o ultimo saldo de referencia *
	//***********************************
	dbSelectArea("CVY")
	dbSeek(xFilial("CVY")+cConfig+cMoeda+cChave+DTOS(LastDay(dData)-10),.T.)
	dbSkip(-1)
	If !Eof() .And. !Bof() .And. xFilial("CVY")+cConfig+cMoeda+cChave==CVY->CVY_FILIAL+CVY->CVY_CONFIG+CVY_MOEDA+CVY->CVY_CHAVE
		aSaldoIni := {{CVY->CVY_SLDCRD},{CVY->CVY_SLDDEB}}
	Else
		aSaldoIni := {{0},{0}}
	EndIf
	//**************************
	// Inclui chave com saldo  *
	//**************************
	RecLock("CVY",.T.)
	CVY->CVY_FILIAL := xFilial("CVY")
	CVY->CVY_CONFIG := cConfig
	CVY->CVY_MOEDA := cMoeda
	CVY->CVY_CHAVE 	:= cChave
	CVY->CVY_DATA	:= LastDay(dData)
	//****************************
	// Tratamento de Ano avaliar *
	//****************************
	/*If FieldPos("AKS_ANO") > 0
		AKS->AKS_ANO 	:= Str(YEAR(AKS->AKS_DATA),4)
		AKS->AKS_MESANO:= Str(MONTH(AKS->AKS_DATA),2)+AKS->AKS_ANO
		AKS->AKS_SEMANO:= If(MONTH(AKS->AKS_DATA)<=6,"1","2")+AKS->AKS_ANO
	EndIf*/

	If cTipoMov == "C"
		CVY->CVY_SLDCRD := aSaldoIni[1,1] + nValor
		CVY->CVY_SLDDEB += aSaldoIni[2,1]
	ElseIf cTipoMov == "D"
		CVY->CVY_SLDDEB += aSaldoIni[2,1] + nValor
		CVY->CVY_SLDCRD := aSaldoIni[1,1]
	EndIf

	For nZ := 1 TO Len(aCubeAux)

		//grava a chave quebrada por dimensao do cubo
		If nZ == nPosTpSald
			nPosCpo := CVY->(FieldPos("CVY_TPSALD"))
		Else
			nPosCpo := CVY->(FieldPos("CVY_NIV"+StrZero(nZ, 2)))
		EndIf

		If nPosCpo > 0  //se o campo existe na tabela CVY entao grava
			CVY->(FieldPut(nPosCpo, Substr(cChave, aCubeAux[ nZ, 3], aCubeAux[ nZ, 4])))
		EndIf

	Next //nZ

	MsUnLock()
	CVY->( dbCommit() )
EndIf

//***************************
// Atualiza saldo acumulado *
//***************************
dbSelectArea("CVY")
dbSeek(xFilial("CVY")+cConfig+cMoeda+cChave+Dtos(LastDay(dData)+1),.T.)
While !Eof() .And. xFilial("CVY")+cConfig+cMoeda+cChave==CVY->(CVY_FILIAL+CVY_MOEDA+CVY_CONFIG+CVY_CHAVE)
	RecLock("CVY",.F.)
	If cTipoMov == "C"
		CVY->CVY_SLDCRD += nValor

	ElseIf cTipoMov == "D"
		CVY->CVY_SLDDEB += nValor
	EndIf
	MsUnlock()
	CVY->( dbCommit() )
	dbSkip()
EndDo

//********************************************************************
// Verifica a existencia da conta superior na configuraÁ„o do saldo  *
//********************************************************************
// Retirado o bloco de contas superiores. avaliar necessidade
UnLockByName(xFilial("CVX")+cConfig+cMoeda+cChave,.T.,.T.,.T.)

RestArea(aArea)
Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FUNCAO    ≥CtbRetSld ≥ AUTOR ≥ Acacio Egas           ≥ DATA ≥ 25/11/09   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DESCRICAO ≥ Funcao de Retoorno dos saldos de uma entidade                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ USO      ≥ SIGAPCO                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function CtbRetSld(cConfig,cMoeda,cChave,dData)
Local aArea	:= GetArea()
Local aAreaCVY	:= CVY->(GetArea())
Local aSaldo 	:= {{0},{0}}
Local cQuery	:=	""
Local lContinua := .T.
Local cBetween  := ""


dbSelectArea("CVX")
dbSetOrder(1)

dbSelectArea("CVY")
dbSetOrder(1)



If aDtMensal == NIL
	aDtMensal := {}
	cQuery	:=	" SELECT  DISTINCT CVY_DATA "
	cQuery	+=	" FROM	"+RetSqlName('CVY')+" CVY "
	cQuery	+=	" WHERE "
	cQuery	+=	" CVY_FILIAL = '"+CVY->(xFilial("CVY"))+"' AND "
	cQuery	+=	" CVY_CONFIG = '"+cConfig  +"' AND "
	cQuery	+=	" CVY_MOEDA = '" + cMoeda  +"' AND "
	cQuery	+=	" D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB3", .F., .F. )
	While QRYTRB3->(!Eof())
		aAdd(aDtMensal, QRYTRB3->CVY_DATA)
		QRYTRB3->(dbSkip())
	EndDo
	dbCloseArea()
EndIf
dbSelectArea("CVX")
dbSetOrder(1)
If lSldChv
	lContinua := .T.
Else
	lContinua := MsSeek(xFilial("CVX")+cConfig+Padr(cChave,Len(CVX->CVX_CHAVE)))
EndIf
If lContinua

	If aScan(aDtMensal, DTOS(dData)) > 0

		cQuery	:=	"SELECT  R_E_C_N_O_ RECNO "
		cQuery	+=	" FROM	"+RetSqlName('CVY')+" CVY "
		cQuery	+=	" WHERE "
		cQuery	+=	" CVY_FILIAL = '"+CVY->(xFilial("CVY"))+"' AND "
		cQuery	+=	" CVY_CONFIG = '"+cConfig  +"' AND "
		cQuery	+=	" CVY_MOEDA = '"+cMoeda  +"' AND "
		cQuery	+=	" CVY_CHAVE  = '"+Padr(cChave,Len(CVY->CVY_CHAVE))+"' AND "
		cQuery	+=	" CVY_DATA = '"+DTOS(dData)+"' AND "
		cQuery	+=	" D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQuery )

		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB2", .F., .F. )
		If QRYTRB2->(!Eof())

			dbSelectArea("CVY")
			dbGoto(QRYTRB2->RECNO)
			aSaldo := {{CVY->CVY_SLDCRD},{CVY->CVY_SLDDEB}}
			lContinua := .F.
		Else
			lContinua := .T.
		EndIf
		QRYTRB2->( dbCloseArea() )

	EndIf

	If lContinua
		//descobre a data imediatamente anterior
		cQuery	:=	"SELECT  MAX(CVY_DATA) CVY_DTANT "
		cQuery	+=	" FROM	"+RetSqlName('CVY')+" CVY "
		cQuery	+=	" WHERE "
		cQuery	+=	" CVY_FILIAL = '"+CVY->(xFilial('CVY'))+"' AND "
		cQuery	+=	" CVY_CONFIG = '"+cConfig  +"' AND "
		cQuery	+=	" CVY_MOEDA = '"+cMoeda  +"' AND "
		cQuery	+=	" CVY_CHAVE  = '"+Padr(cChave,Len(CVY->CVY_CHAVE))+"' AND "
		cQuery	+=	" CVY_DATA < '"+dtos(dData)+"' AND "
		cQuery	+=	" D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQuery )

		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB1", .F., .F. )

		If QRYTRB1->(!Eof() .And. !Empty(QRYTRB1->CVY_DTANT))
			//se achou utiliza data imediata anterior como base de saldo mensal
			cQuery	:=	"SELECT  R_E_C_N_O_ RECNO "
			cQuery	+=	" FROM	"+RetSqlName('CVY')+" CVY "
			cQuery	+=	" WHERE "
			cQuery	+=	" CVY_FILIAL = '"+CVY->(xFilial("CVY"))+"' AND "
			cQuery	+=	" CVY_CONFIG = '"+cConfig  +"' AND "
			cQuery	+=	" CVY_MOEDA = '"+cMoeda  +"' AND "
			cQuery	+=	" CVY_CHAVE  = '"+Padr(cChave,Len(CVY->CVY_CHAVE))+"' AND "
			cQuery	+=	" CVY_DATA = '"+QRYTRB1->CVY_DTANT+"' AND "
			cQuery	+=	" D_E_L_E_T_ = ' '"

			cQuery := ChangeQuery( cQuery )

			dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
			If QRYTRB->(!Eof())
				dbSelectArea("CVY")
				dbGoto(QRYTRB->RECNO)
				dDataIni	:= CVY->CVY_DATA+1
				cBetween := " CVX_DATA BETWEEN '"+dtos(dDataIni)+"' AND '"+dtos(dData)+"' AND "
				aSaldo		:= {{CVY->CVY_SLDCRD},{CVY->CVY_SLDDEB}}
			Else
				cBetween := " CVX_DATA <= '"+dtos(dData)+"' AND "
			EndIf
			QRYTRB->( dbCloseArea() )
		Else
			cBetween := " CVX_DATA <= '"+dtos(dData)+"' AND "
		EndIf
		//fecha as querys
		QRYTRB1->( dbCloseArea() )

		cQuery	:=	"SELECT ISNULL(SUM(CVX_SLDCRD),0) CVX_SLDCRD, "
		cQuery	+=	" ISNULL(SUM(CVX_SLDDEB),0) CVX_SLDDEB "
		cQuery	+=	" FROM	"+RetSqlName('CVX')+" CVX "
		cQuery	+=	" WHERE "
		cQuery	+=	" CVX_FILIAL = '"+CVX->(xFilial("CVX"))+"' AND "
		cQuery	+=	" CVX_CONFIG = '"+cConfig  +"' AND "
		cQuery	+=	" CVX_MOEDA = '"+cMoeda  +"' AND "
		cQuery	+=	" CVX_CHAVE  = '"+Padr(cChave,Len(CVY->CVY_CHAVE))+"' AND "
		If !Empty(cBetween)
			cQuery	+=	cBetween
		EndIf
		cQuery	+=	" D_E_L_E_T_= ' '"

		cQuery := ChangeQuery( cQuery )

		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
		aSaldo[1,1]+= QRYTRB->CVX_SLDCRD
		aSaldo[2,1]+= QRYTRB->CVX_SLDDEB
		QRYTRB->( dbCloseArea() )
	EndIf
EndIf



RestArea(aAreaCVY)
//RestArea(aAreaAL1)

RestArea(aArea)
Return aSaldo

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CTB_ChvCube ∫Autor  ≥ Acacio Egas        ∫ Data ≥ 25/11/09  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Funcao que monta os cubos do CTB de acordo com a tabela    ∫±±
±±∫          ≥ CT0 de Configuracao de Entidades Contabeis.                ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ SIGACTB                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function CTB_ChvCube()

Local aArea		:= GetArea()
Local aAreaCT0	:= CT0->(GetArea())
Local aCube
Local nPosInic,nCpo
Local cId := "00"

//*********************************************
// Utilizada para forÁar o tamanho dos campos *
//--------------------------------------------*
// Quando for utilizado mais campos deve ser  *
// criado um campo no CT0 com o tamanho da    *
// origem.                                    *
//*********************************************
Local aCpos := {{"CT1"	, TAMSX3("CT1_CONTA" )[1],"CT2_DEBITO"	,"CT2_CREDIT", "CT1_CTASUP"	, "POSICIONE('CT1',xFilial('CT1')+CCHAVE,'CT1_CONTA')"	},;
				{"CTT"	, TAMSX3("CTT_CUSTO" )[1],"CT2_CCD"		,"CT2_CCC"	 , "CTT_CCSUP"	, "POSICIONE('CTT',xFilial('CTT')+CCHAVE,'CTT_CUSTO')"	},;
				{"CTD"	, TAMSX3("CTD_ITEM"  )[1],"CT2_ITEMD"	,"CT2_ITEMC" , "CTD_ITSUP"	, "POSICIONE('CTD',xFilial('CTD')+CCHAVE,'CTD_ITEM')"	},;
				{"CTH"	, TAMSX3("CTH_CLVL"  )[1],"CT2_CLVLDB"	,"CT2_CLVLCR", "CTH_CLSUP"	, "POSICIONE('CTH',xFilial('CTH')+CCHAVE,'CTH_CLVL')"	}}

dbSelectArea("CT0")
dbSetOrder(1)
If dbSeek(xFilial("CT0"))
	Do While CT0->CT0_FILIAL==xFilial("CT0") .And. !CT0->(Eof())
		If aScan(aCpos,{|x| x[1]==Alltrim(CT0->CT0_ALIAS) })==0
			AADD(aCpos, {CT0->CT0_ALIAS, TAMSX3(CT0->CT0_CPOCHV)[1], "CT2_EC##DB", "CT2_EC##CR", CT0->CT0_CPOSUP, "POSICIONE('"+CT0->CT0_ALIAS+"',xFilial('"+CT0->CT0_ALIAS+"')+CCHAVE,'"+CT0->CT0_CPOCHV+"')"	} )
		EndIf
		CT0->(dbSkip())
	EndDo
EndIf

AADD(aCpos, {"SX5SL", TAMSX3("CT5_TPSALD")[1], "CT2_TPSALD", "CT2_TPSALD", nil, nil } )

dbSelectArea("CT0")
dbSetOrder(1)
If dbSeek(xFilial("CT0"))

	aCube := {}
	nPosInic := 1
	aAdd(aCube, { "01", {} } )
	While CT0->( ! Eof() .And. CT0_FILIAL==xFilial("CT0") )

	    If CT0->CT0_CONTR=="1"
			If !CT0->CT0_ALIAS$"CT1/CTT/CTD/CTH"
				nCpo	:= aScan(aCpos,{|x| x[1]==Alltrim(CT0->CT0_ALIAS) })
		   		aAdd(aCube[Len(aCube), 2], { CT0->CT0_ALIAS, CT0->CT0_ID, nPosInic, aCpos[nCpo,2] ,  {StrTran(aCpos[nCpo,3],"##",CT0->CT0_ID),StrTran(aCpos[nCpo,4],"##",CT0->CT0_ID)} } )
			Else
				nCpo	:= aScan(aCpos,{|x| x[1]==Alltrim(CT0->CT0_ALIAS) })
		   		aAdd(aCube[Len(aCube), 2], { CT0->CT0_ALIAS, CT0->CT0_ID, nPosInic, aCpos[nCpo,2] , {aCpos[nCpo,3],aCpos[nCpo,4]} })
			EndIf
			nPosInic += aCpos[nCpo,2]
			cId := CT0->CT0_ID
		EndIf
		CT0->(dbSkip())
	EndDo

	nCpo	:= aScan(aCpos,{|x| x[1]==Alltrim("SX5SL") })
   	aAdd(aCube[Len(aCube), 2], { "SX5SL", Soma1(cId), nPosInic, aCpos[nCpo,2], {aCpos[nCpo,3],aCpos[nCpo,4]} } )

EndIf
RestArea(aAreaCT0)
RestArea(aArea)

Return(aCube)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CtbReprCub  ∫Autor  ≥ Acacio Egas        ∫ Data ≥ 25/11/09  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Funcao de reprocessamento do saldo do cubo contabil.       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ SIGACTB                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function CtbReprCub(nMoedIni,nMoedFin,cFilDe,cFilAte,dDataIni,cTpSald)

Local cAlias	:= "CT2"
Local cTipoMov




//*****************************************
// Limpa o saldo a partir da data inicial *
//*****************************************
DbSelectArea("CVX")
DbSetOrder(1)
DbSeek(xFilial("CVX")+"01")
Do While !CVX->(Eof()) .and. CVX->(CVX_FILIAL+CVX_CONFIG)==xFilial("CVX")+"01"

	If CVX->CVX_DATA<dDataIni .or.;
		 (CVX->CVX_MOEDA<StrZero(nMoedIni,2) .and. CVX->CVX_MOEDA>StrZero(nMoedFin,2)) .or.;
		 (CVX->CVX_TPSALD<>cTpSald)
		CVX->(DbSkip())
		Loop
	EndIf

	RecLock("CVX",.F.,.T.)
	DbDelete()
	MsUnLock()
	CVX->(DbSkip())
EndDo

DbSelectArea("CVY")
DbSetOrder(1)
DbSeek(xFilial("CVY")+"01")
Do While !CVY->(Eof()) .and. CVY->(CVY_FILIAL+CVY_CONFIG)==xFilial("CVY")+"01"

	If CVY->CVY_DATA<dDataIni .or.;
		 (CVY->CVY_MOEDA<StrZero(nMoedIni,2) .and. CVY->CVY_MOEDA>StrZero(nMoedFin,2)) .or.;
		 (CVY->CVY_TPSALD<>cTpSald)
		CVY->(DbSkip())
		Loop
	EndIf

	RecLock("CVY",.F.,.T.)
	DbDelete()
	MsUnLock()
	CVY->(DbSkip())
EndDo

//*********************************
// Efetua a atualizaÁ„o do Saldo  *
//*********************************
DbSelectArea("CT2")
DbSetOrder(1)
DbSeek(cFilDe)

Do While !(cAlias)->(Eof()) .and. (cAlias)->CT2_FILIAL>=cFilDe .and. (cAlias)->CT2_FILIAL<=cFilAte .and. DTOS(dDataIni)<=DTOS((cAlias)->CT2_DATA)
	If (cAlias)->(CT2_DC == '1' .Or. CT2_DC == '2')
		//********************
		// Debito ou Credito *
		//********************
		If (cAlias)->CT2_DC=="1"
			cTipoMov	:= "D"
		Else
			cTipoMov	:= "C"
		EndIf
		CtbAtuSld(cAlias,"01",(cAlias)->CT2_MOEDLC,cTipoMov,(cAlias)->CT2_VALOR,(cAlias)->CT2_DATA)
	ElseIf (cAlias)->CT2_DC == '3'
		//******************
		// Partida Dobrada *
		//******************
		CtbAtuSld(cAlias,"01",(cAlias)->CT2_MOEDLC,"D",(cAlias)->CT2_VALOR,(cAlias)->CT2_DATA)
		CtbAtuSld(cAlias,"01",(cAlias)->CT2_MOEDLC,"C",(cAlias)->CT2_VALOR,(cAlias)->CT2_DATA)
	EndIf
	(cAlias)->(DbSkip())
EndDo

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CtbRunCube ∫Autor  ≥Simone Mie Sato     ∫ Data ≥  26/06/03   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Retorna alias TRBTMP com a composiÁ„o dos saldos Conta x    ∫±±
±±∫          ≥Item Cotnabil                                               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP6                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function CtbRunCube(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cEC05Ini,cEC05Fim,cMoeda,cTpSald,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,cMoedaDsc,aSelFil,dDtCorte,lTodasFil,aTmpFil)

Local cQuery		:= ""
Local aAreaQry		:= GetArea()		/// array com a posiÁ„o no arquivo original
Local aTamVlr		:= TAMSX3("CT4_DEBITO")
Local cCampUSU		:= ""
Local aStrSTRU		:= {}
Local nStruLen		:= 0
Local nStr			:= 1
Local lCT1EXDTFIM	:= CtbExDtFim("CT1")
Local cQryFil		:= ""
Local nPosCT1
Local nPosE05
Local cAliasE05
Local cTmpCVXFil
Local cCpoChv
Local cCpoNormal
Local cCpoEntSup
Local cCpoDsc
Local cEntPrf
Local cPlano		:= ""

DEFAULT lImpAntLP := .F.
DEFAULT dDataLP	  := CTOD("  /  /  ")
DEFAULT cMoedaDsc := '01'
DEFAULT aSelFil	:= {}
DEFAULT dDtCorte  := CTOD("  /  /  ")
DEFAULT lTodasFil := .F.
DEFAULT aTmpFil	:= {}

If aCubsCTB == NIL
	aCubsCTB := CTB_ChvCube()
EndIf

DbSelectArea('CT0')
DbSetOrder(1)
If DbSeek( xFilial('CT0') + '05' )
	cAliasE05 := CT0->CT0_ALIAS
	cCpoChv := CT0->CT0_CPOCHV
	cCpoDsc := CT0->CT0_CPODSC
	If !Empty(CT0->CT0_CPOSUP)
		cCpoEntSup := "ECY."+CT0->CT0_CPOSUP
	Else
		cCpoEntSup := "' '"
	EndIf
	cPlano := CT0->CT0_ENTIDA
Else
	cAliasE05 := "CV0"
	cCpoChv := "CV0_CODIGO"
	cCpoDsc := "CV0_DESC"
	cCpoEntSup := "ECY.CV0_ENTSUP"
	cPlano := "05"
EndIf
If cAliasE05 == "CV0"
	cCpoNormal := "ECY.CV0_NORMAL"
Else
	cCpoNormal := "'1'"
EndIf
If left(cAliasE05,1)=='S'
	cEntPrf := substr(cAliaE05,2,2)
Else
	cEntPrf := cAliasE05
EndIf


nPosCT1 := aScan( aCubsCTB[1,2] , {|x| x[1]=="CT1" })
nPosE05 := aScan( aCubsCTB[1,2] , {|x| x[1]==cAliasE05 })

If Empty(nPosCT1) .or. Empty(nPosE05)

	Return

EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Tratativa para o filtro de filiais           ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If !lTodasFil
	cQryFil := " CVX_FILIAL " + GetRngFil( aSelFil, "CVX", .T., @cTmpCVXFil )
	aAdd(aTmpFil, cTmpCVXFil)
Endif

cQuery := " SELECT ECX.CT1_CONTA ECX,ECX.CT1_NORMAL ECXNORMAL, ECX.CT1_RES ECXRES, ECX.CT1_CTASUP ECXSUP,ECX.CT1_DESC01 ECXDESC, "

cQuery += " ECY."+cCpoChv+" ECY,"+cCpoNormal+" ECYNORMAL, "+cCpoEntSup+" ECYSUP,ECY."+cCpoDsc+" ECYDESC, "

// TRATAR DATA DE EXISTENTCIA
//If lCT1EXDTFIM
//	cQuery += "     CT1_DTEXSF CT1DTEXSF, "
//EndIf

//***************************
// Calculo o saldo anterior *
//***************************
cQuery += " 		(SELECT ISNULL(SUM(CVX_SLDDEB),0) "
cQuery += "			 	FROM "+RetSqlName("CVX")+" CVX "
cQuery += " 			WHERE  CVX_FILIAL ='" + xFilial("CVX") + "' "
cQuery += " 			AND ECX.CT1_CONTA	= CVX_NIV" + StrZero(nPosCT1,2) + " AND ECY."+cCpoChv+" = CVX_NIV" + StrZero(nPosE05,2)

If lCtbIsCube .And. CtbIsCube()
	cQuery += " 			AND CVX_CONFIG = '05' "
Else
	cQuery += " 			AND CVX_CONFIG = '01' "
EndIf

cQuery += " 			AND CVX_MOEDA = '"+cMoeda+"' "
cQuery += " 			AND CVX_TPSALD = '"+cTpSald+"' "
cQuery += " 			AND CVX_DATA <  '"+DTOS(dDataIni)+"' "

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥data de corte para calculo do saldo anterior - Usado em Portugal≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If ! Empty( dDtCorte ) .And. Valtype( dDtCorte ) == 'D'
	cQuery += " 			AND CVX_DATA >=  '"+DTOS(dDtCorte)+"' "
Endif
cQuery += " 			AND CVX.D_E_L_E_T_ = '') "
cQuery += "  SALDOANTDB, "

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥data de corte para calculo do saldo anterior - Usado em Portugal≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If ! Empty( dDtCorte ) .And. Valtype( dDtCorte ) == 'D'
	cQuery += " 		(SELECT ISNULL(SUM(CVX_SLDDEB),0) "
	cQuery += "			 	FROM "+RetSqlName("CVX")+" CVX "
	cQuery += " 			WHERE  CVX_FILIAL ='" + xFilial("CVX") + "' "
	cQuery += " 			AND ECX.CT1_CONTA	= CVX_NIV" + StrZero(nPosCT1,2) + " AND ECY."+cCpoChv+" = CVX_NIV" + StrZero(nPosE05,2)

	If lCtbIsCube .And. CtbIsCube()
		cQuery += " 			AND CVX_CONFIG = '05' "
	Else
		cQuery += " 			AND CVX_CONFIG = '01' "
	EndIf

	cQuery += " 			AND CVX_MOEDA = '"+cMoeda+"' "
	cQuery += " 			AND CVX_TPSALD = '"+cTpSald+"' "
	cQuery += " 			AND CVX_DATA <  '"+DTOS(dDtCorte)+"' "
	cQuery += " 			AND CVX.D_E_L_E_T_ = '') "
	cQuery += "  SLDANTCTDB, "
EndIf

If lImpAntLP
	//**********************************************************************
	// Sera tratado pela tabela CVZ/ ainda nao contemplada nesta alteraÁ„o *
	//**********************************************************************
	/*
	cQuery += " 		(SELECT SUM(CVX_SLDDEB) "
	cQuery += "			 	FROM "+RetSqlName("CVY")+" CVY "
	cQuery += " 			WHERE " + cQryFil
	cQuery += " 			AND ECX.CV0_CODIGO	= CVY_NIV" + "01" + " "

	If lCtbIsCube .And. CtbIsCube()
		cQuery += " 			AND CVX_CONFIG = '05' "
	Else
		cQuery += " 			AND CVX_CONFIG = '01' "
	EndIf

	cQuery += " 			AND CVY_MOEDA = '"+cMoeda+"' "
	cQuery += " 			AND CVY_TPSALD = '"+cTpSald+"' "
	cQuery += " 			AND CVY_DATA <  '"+DTOS(dDataIni)+"' AND CVY_DATA >=  '"+DTOS(FirstDay(dDataIni))+"' "

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥data de corte para calculo do saldo anterior - Usado em Portugal≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	//If ! Empty( dDtCorte ) .And. Valtype( dDtCorte ) == 'D'  .And. dDtCorte <> Nil
	//	cQuery += " 			AND CVY_DATA >=  '"+DTOS(dDtCorte)+"' "
	//Endif

	cQuery += "				AND CT7_LP = 'Z' AND ((CT7_DTLP <> ' ' AND CT7_DTLP >= '"+DTOS(dDataLP)+"') OR (CT7_DTLP = '' AND CT7_DATA >= '"+DTOS(dDataLP)+"'))"
	cQuery += " 			AND CT7.D_E_L_E_T_ = '') "
	cQuery += "  SLDLPANTDB, "

	If ! Empty( dDtCorte ) .And. Valtype( dDtCorte ) == 'D'  .And. dDtCorte <> Nil
		cQuery += " 		(SELECT SUM(CT7_DEBITO) "
		cQuery += "			 	FROM "+RetSqlName("CT7")+" CT7 "
		cQuery += " 			WHERE " + cQryFil
		cQuery += " 			AND ARQ.CT1_CONTA	= CT7_CONTA "
		cQuery += " 			AND CT7_MOEDA = '"+cMoeda+"' "
		cQuery += " 			AND CT7_TPSALD = '"+cTpSald+"' "
		cQuery += " 			AND CT7_DATA <  '"+DTOS(dDtCorte)+"' "
		cQuery += "				AND CT7_LP = 'Z' AND ((CT7_DTLP <> ' ' AND CT7_DTLP >= '"+DTOS(dDataLP)+"') OR (CT7_DTLP = '' AND CT7_DATA >= '"+DTOS(dDataLP)+"'))"
		cQuery += " 			AND CT7.D_E_L_E_T_ = '') "
		cQuery += "  SLLPATCTDB, "
	Endif
	*/
EndIf

cQuery += " 	  	(SELECT ISNULL(SUM(CVX_SLDCRD),0) "
cQuery += " 			FROM "+RetSqlName("CVX")+" CVX "
cQuery += " 			WHERE  CVX_FILIAL ='" + xFilial("CVX") + "' "
cQuery += " 			AND ECX.CT1_CONTA	= CVX_NIV" + StrZero(nPosCT1,2) + " AND ECY."+cCpoChv+" = CVX_NIV" + StrZero(nPosE05,2)

If lCtbIsCube .And. CtbIsCube()
	cQuery += " 			AND CVX_CONFIG = '05' "
Else
	cQuery += " 			AND CVX_CONFIG = '01' "
EndIf

cQuery += " 			AND CVX_MOEDA = '"+cMoeda+"' "
cQuery += " 			AND CVX_TPSALD = '"+cTpSald+"' "
cQuery += " 			AND CVX_DATA <  '"+DTOS(dDataIni)+"' "

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥data de corte para calculo do saldo anterior - Usado em Portugal≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If ! Empty( dDtCorte ) .And. Valtype( dDtCorte ) == 'D'  .And. dDtCorte <> Nil
	cQuery += " 			AND CVX_DATA >=  '"+DTOS(dDtCorte)+"' "
Endif

cQuery += " 			AND CVX.D_E_L_E_T_ = '') "
cQuery += "  SALDOANTCR, "

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥data de corte para calculo do saldo anterior - Usado em Portugal≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If ! Empty( dDtCorte ) .And. Valtype( dDtCorte ) == 'D'  .And. dDtCorte <> Nil
	cQuery += " 		(SELECT ISNULL(SUM(CVX_SLDCRD),0) "
	cQuery += "			 	FROM "+RetSqlName("CVX")+" CVX "
	cQuery += " 			WHERE  CVX_FILIAL ='" + xFilial("CVX") + "' "
	cQuery += " 			AND ECX.CT1_CONTA	= CVX_NIV" + StrZero(nPosCT1,2) + " AND ECY."+cCpoChv+" = CVX_NIV" + StrZero(nPosE05,2)

	If lCtbIsCube .And. CtbIsCube()
		cQuery += " 			AND CVX_CONFIG = '05' "
	Else
		cQuery += " 			AND CVX_CONFIG = '01' "
	EndIf

	cQuery += " 			AND CVX_MOEDA = '"+cMoeda+"' "
	cQuery += " 			AND CVX_TPSALD = '"+cTpSald+"' "
	cQuery += " 			AND CVX_DATA <  '"+DTOS(dDtCorte)+"' "
	cQuery += " 			AND CVX.D_E_L_E_T_ = '') "
	cQuery += "  SLDANTCTCR, "
Endif

If lImpAntLP
//**********************************************************************
// Sera tratado pela tabela CVZ/ ainda nao contemplada nesta alteraÁ„o *
//**********************************************************************
/*	cQuery += " 	(SELECT SUM(CT7_CREDIT) "
	cQuery += " 			FROM "+RetSqlName("CT7")+" CT7 "
	cQuery += " 			WHERE " + cQryFil
	cQuery += " 			AND ARQ.CT1_CONTA	= CT7_CONTA "
	cQuery += " 			AND CT7_MOEDA = '"+cMoeda+"' "
	cQuery += " 			AND CT7_TPSALD = '"+cTpSald+"' "
	cQuery += " 			AND CT7_DATA <  '"+DTOS(dDataIni)+"' "

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥data de corte para calculo do saldo anterior - Usado em Portugal≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If ! Empty( dDtCorte ) .And. Valtype( dDtCorte ) == 'D'  .And. dDtCorte <> Nil
		cQuery += " 			AND CT7_DATA >=  '"+DTOS(dDtCorte)+"' "
	Endif

	cQuery += "				AND CT7_LP = 'Z' AND ((CT7_DTLP <> ' ' AND CT7_DTLP >= '"+DTOS(dDataLP)+"') OR (CT7_DTLP = '' AND CT7_DATA >= '"+DTOS(dDataLP)+"'))"
	cQuery += " 			AND CT7.D_E_L_E_T_ = '') "
	cQuery += "  SLDLPANTCR, "

	If ! Empty( dDtCorte ) .And. Valtype( dDtCorte ) == 'D'  .And. dDtCorte <> Nil
		cQuery += " 		(SELECT SUM(CT7_CREDIT) "
		cQuery += "			 	FROM "+RetSqlName("CT7")+" CT7 "
		cQuery += " 			WHERE " + cQryFil
		cQuery += " 			AND ARQ.CT1_CONTA	= CT7_CONTA "
		cQuery += " 			AND CT7_MOEDA = '"+cMoeda+"' "
		cQuery += " 			AND CT7_TPSALD = '"+cTpSald+"' "
		cQuery += " 			AND CT7_DATA <  '"+DTOS(dDtCorte)+"' "
		cQuery += "				AND CT7_LP = 'Z' AND ((CT7_DTLP <> ' ' AND CT7_DTLP >= '"+DTOS(dDataLP)+"') OR (CT7_DTLP = '' AND CT7_DATA >= '"+DTOS(dDataLP)+"'))"
		cQuery += " 			AND CT7.D_E_L_E_T_ = '') "
		cQuery += "  SLLPATCTCR, "
	Endif
*/
EndIf

//************************
// Calculo o saldo Atual *
//************************

cQuery += " 		(SELECT ISNULL(SUM(CVX_SLDDEB),0) "
cQuery += "			 	FROM "+RetSqlName("CVX")+" CVX "
cQuery += " 			WHERE  CVX_FILIAL ='" + xFilial("CVX") + "' "
cQuery += " 			AND ECX.CT1_CONTA	= CVX_NIV" + StrZero(nPosCT1,2) + " AND ECY."+cCpoChv+" = CVX_NIV" + StrZero(nPosE05,2)

If lCtbIsCube .And. CtbIsCube()
	cQuery += " 			AND CVX_CONFIG = '05' "
Else
	cQuery += " 			AND CVX_CONFIG = '01' "
EndIf

cQuery += " 			AND CVX_MOEDA = '"+cMoeda+"' "
cQuery += " 			AND CVX_TPSALD = '"+cTpSald+"' "
cQuery += " 			AND CVX_DATA BETWEEN '" + DTOS(dDataIni) + "' AND '"+ DTOS(dDataFim) + "' "
cQuery += " 			AND CVX.D_E_L_E_T_ = '') "
cQuery += "  SALDODEB, "

If lImpAntLP
/*	cQuery += " 		(SELECT SUM(CVX_SLDDEB) "
	cQuery += "			 	FROM "+RetSqlName("CVY")+" CVY "
	cQuery += " 			WHERE " + cQryFil
	cQuery += " 			AND ECX.CV0_CODIGO	= CVY_NIV" + "01" + " "

	If lCtbIsCube .And. CtbIsCube()
		cQuery += " 			AND CVY_CONFIG = '05' "
	Else
		cQuery += " 			AND CVY_CONFIG = '01' "
	EndIf

	cQuery += " 			AND CVY_MOEDA = '"+cMoeda+"' "
	cQuery += " 			AND CVY_TPSALD = '"+cTpSald+"' "
	cQuery += " 			AND CVY_DATA BETWEEN '" + DTOS(dDataIni) + "' AND '"+ DTOS(dDataFim) + "' "
	cQuery += "				AND CT7_LP = 'Z' AND ((CT7_DTLP <> ' ' AND CT7_DTLP >= '"+DTOS(dDataLP)+"') OR (CT7_DTLP = '' AND CT7_DATA >= '"+DTOS(dDataLP)+"'))"
	cQuery += " 			AND CT7.D_E_L_E_T_ = '') "
	cQuery += "  MOVLPDEB, "
*/
EndIf

cQuery += " 		(SELECT ISNULL(SUM(CVX_SLDCRD),0) "
cQuery += " 			FROM "+RetSqlName("CVX")+" CVX "
cQuery += " 			WHERE  CVX_FILIAL ='" + xFilial("CVX") + "' "
cQuery += " 			AND ECX.CT1_CONTA	= CVX_NIV" + StrZero(nPosCT1,2) + " AND ECY."+cCpoChv+" = CVX_NIV" + StrZero(nPosE05,2)

If lCtbIsCube .And. CtbIsCube()
	cQuery += " 			AND CVX_CONFIG = '05' "
Else
	cQuery += " 			AND CVX_CONFIG = '01' "
EndIf

cQuery += " 			AND CVX_MOEDA = '"+cMoeda+"' "
cQuery += " 			AND CVX_TPSALD = '"+cTpSald+"' "
cQuery += " 			AND CVX_DATA BETWEEN '" + DTOS(dDataIni) + "' AND '"+ DTOS(dDataFim) + "' "
cQuery += " 			AND CVX.D_E_L_E_T_ = '') "
cQuery += "  SALDOCRD "

If lImpAntLP
/*	cQuery += ", 		(SELECT SUM(CT7_CREDIT) "
	cQuery += " 			FROM "+RetSqlName("CT7")+" CT7 "
	cQuery += " 			WHERE " + cQryFil
	cQuery += " 			AND ARQ.CT1_CONTA	= CT7_CONTA "
	cQuery += " 			AND CT7_MOEDA = '"+cMoeda+"' "
	cQuery += " 			AND CT7_TPSALD = '"+cTpSald+"' "
	cQuery += " 			AND CT7_DATA BETWEEN '" + DTOS(dDataIni) + "' AND '"+ DTOS(dDataFim) + "' "
	cQuery += "				AND CT7_LP = 'Z' AND ((CT7_DTLP <> ' ' AND CT7_DTLP >= '"+DTOS(dDataLP)+"') OR (CT7_DTLP = '' AND CT7_DATA >= '"+DTOS(dDataLP)+"'))"
	cQuery += " 			AND CT7.D_E_L_E_T_ = '') "
	cQuery += "  MOVLPCRD "
*/
EndIf

cQuery += " 	FROM "+RetSqlName("CT1")+" ECX," +RetSqlName(cAliasE05)+" ECY "
cQuery += " 	WHERE ECX.CT1_FILIAL = '" + xFilial("CT1") + "' AND ECY."+cEntPrf+"_FILIAL = '" + xFilial(cAliasE05) + "'"
cQuery += " 	AND ECX.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"' "
//cEC05Ini := "      "
//cEC06Fim := "ZZZZZZ"
If cPaisLoc <> "COL" .and. cAliasE05 == "CV0"
	If !(cPaisLoc == "PER")
		cQuery += " 	AND ECY.CV0_PLANO='05' "
	Else
		cQuery += " 	AND ECY.CV0_PLANO='" + cPlano + "' "
	EndIf
EndIf
If !(cPaisLoc $ "COL|PER")
	cQuery += " 	AND ECX.CT1_CONTA BETWEEN '"+cEC05Ini+"' AND '"+cEC05Fim+"' "
Else
	cQuery += " 	AND ECY." + cCpoChv + " BETWEEN '"+cEC05Ini+"' AND '"+cEC05Fim+"' "
EndIf
cQuery += " 	AND ECX.CT1_CLASSE = '2' "
If cAliasE05 == "CV0"
	cQuery += " 	AND ECY.CV0_CLASSE = '2' "
EndIf

If !Empty(aSetOfBook[1])										// SE HOUVER CODIGO DE CONFIGURA«√O DE LIVROS
	cQuery += " 	AND ECX.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%' "  // FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
Endif
cQuery += " 	AND ECX.D_E_L_E_T_ = ' ' AND ECY.D_E_L_E_T_ = ' '"


If !lVlrZerado //.And. !lImpAntLP	//Se considerar posicao anterior LP sera verificado na gravacao do arquivo de trabalho
	cQuery += " 	AND	((SELECT ROUND(ISNULL(SUM(CVX_SLDDEB),0),2)- ROUND(ISNULL(SUM(CVX_SLDCRD),0),2) "
	cQuery += "			 	FROM "+RetSqlName("CVX")+" CVX "
	cQuery += " 			WHERE  CVX_FILIAL ='" + xFilial("CVX") + "' "
	cQuery += " 			AND ECX.CT1_CONTA	= CVX_NIV" + StrZero(nPosCT1,2) + " AND ECY."+cCpoChv+" = CVX_NIV" + StrZero(nPosE05,2)

	If lCtbIsCube .And. CtbIsCube()
		cQuery += " 			AND CVX_CONFIG = '05' "
	Else
		cQuery += " 			AND CVX_CONFIG = '01' "
	EndIf

	cQuery += " 			AND CVX_MOEDA = '"+cMoeda+"' "
	cQuery += " 			AND CVX_TPSALD = '"+cTpSald+"' "
	cQuery += " 			AND CVX_DATA <  '"+DTOS(dDataIni)+"' "
	cQuery += " 			AND CVX.D_E_L_E_T_ = '') <> 0 "
	cQuery += " 	OR "
	cQuery += " 			(SELECT ISNULL(SUM(CVX_SLDDEB),0)  "
	cQuery += "			 	FROM "+RetSqlName("CVX")+" CVX "
	cQuery += " 			WHERE  CVX_FILIAL ='" + xFilial("CVX") + "' "
	cQuery += " 			AND ECX.CT1_CONTA	= CVX_NIV" + StrZero(nPosCT1,2) + " AND ECY."+cCpoChv+" = CVX_NIV" + StrZero(nPosE05,2)

	If lCtbIsCube .And. CtbIsCube()
		cQuery += " 			AND CVX_CONFIG = '05' "
	Else
		cQuery += " 			AND CVX_CONFIG = '01' "
	EndIf

	cQuery += " 			AND CVX_MOEDA = '"+cMoeda+"' "
	cQuery += " 			AND CVX_TPSALD = '"+cTpSald+"' "
	cQuery += " 			AND CVX_DATA BETWEEN '" + DTOS(dDataIni) + "' AND '"+ DTOS(dDataFim) + "' "
	cQuery += " 			AND CVX.D_E_L_E_T_ = '')<> 0 "
	cQuery += " 	OR "
	cQuery += " 			(SELECT ISNULL(SUM(CVX_SLDCRD),0)  "
	cQuery += "			 	FROM "+RetSqlName("CVX")+" CVX "
	cQuery += " 			WHERE  CVX_FILIAL ='" + xFilial("CVX") + "' "
	cQuery += " 			AND ECX.CT1_CONTA	= CVX_NIV" + StrZero(nPosCT1,2) + " AND ECY."+cCpoChv+" = CVX_NIV" + StrZero(nPosE05,2)

	If lCtbIsCube .And. CtbIsCube()
		cQuery += " 			AND CVX_CONFIG = '05' "
	Else
		cQuery += " 			AND CVX_CONFIG = '01' "
	EndIf

	cQuery += " 			AND CVX_MOEDA = '"+cMoeda+"' "
	cQuery += " 			AND CVX_TPSALD = '"+cTpSald+"' "
	cQuery += " 			AND CVX_DATA BETWEEN '" + DTOS(dDataIni) + "' AND '"+ DTOS(dDataFim) + "' "
	cQuery += " 			AND CVX.D_E_L_E_T_ = '')<> 0) "
Endif

cQuery := ChangeQuery(cQuery)

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)

TcSetField("TRBTMP","SALDOANTDB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOANTCR","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDODEB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOCRD","N",aTamVlr[1],aTamVlr[2])

/*
If lCT1EXDTFIM
	TCSetField("TRBTMP","CT1DTEXSF","D",8,0)
	TCSetField("TRBTMP","CT1_DTEXSF","D",8,0)
	TCSetField("TRBTMP","CT1_DTEXIS","D",8,0)
	TCSetField("TRBTMP","CT1_DTBLIN","D",8,0)
	TCSetField("TRBTMP","CT1_DTBLFI","D",8,0)
EndIf
*/
If lImpAntLP
/*
	TcSetField("TRBTMP","SLDLPANTDB","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","SLDLPANTCR","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","MOVLPDEB","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","MOVLPCRD","N",aTamVlr[1],aTamVlr[2])
*/
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥data de corte para calculo do saldo anterior - Usado em Portugal≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If ! Empty( dDtCorte )
	TcSetField("TRBTMP","SLDANTCTDB","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","SLDANTCTCR","N",aTamVlr[1],aTamVlr[2])

	If lImpAntLP
		TcSetField("TRBTMP","SLLPATCTDB","N",aTamVlr[1],aTamVlr[2])
		TcSetField("TRBTMP","SLLPATCTCR","N",aTamVlr[1],aTamVlr[2])
	Endif
Endif
RestArea(aAreaQry)

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥CtbSldCubo≥ Autor ≥ TOTVS                 ≥ Data ≥ 27.05.10 			≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Saldo da Entidade                                        			≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ CtbSldCubo(aEntidades,aDataIni,aDataFim,cMoeda,cTpSald,aSelFil) 		≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥{nSaldoAtu,nDebito,nCredito}                                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                  			≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpA1 = Array Endidades {'Conta Inicial','Conta Final'}     		    ≥±±
±±≥          ≥ ExpA2 = Array data Inicial                                 		    ≥±±
±±≥          ≥ ExpA3 = Array data final                                   		    ≥±±
±±≥          ≥ ExpC4 = Moeda                                            		    ≥±±
±±≥          ≥ ExpC5 = Tipo de Saldo                                       		    ≥±±
±±≥          ≥ ExpA6 = Array de  filiais                                		    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CtbSldCubo(aEntdIni,aEntdFim,dDataIni,dDataFim,cMoeda,cTpSald,aSelFil,lMantemTmp,lBuscaExata, aEntVazio)
Local aAreaAtu	:= GetArea()
Local nSaldoAtu	:= 0
Local nDebito	:= 0
Local nCredito	:= 0
Local nAtuDeb	:= 0
Local nAtuCrd	:= 0
Local nSaldoAnt	:= 0
Local nAntDeb	:= 0
Local nAntCrd	:= 0
Local oCubeSldRng
Local cCodCubo 	:= StrZero(Len(aEntdIni),2)
Local nY		:= 0
Local aDataIni	:= {}
Local aDataFim	:= {}
Local laEntIgual	:= .F.

Local nEntidade	:= Len(aEntdIni)

DEFAULT lMantemTmp	:= .F.
//Parametro utilizado para somar somente oque est· no parametro.
//O array aEntdIni e aEntdFim devem ser iguais.
DEFAULT lBuscaExata	:= .F.
DEFAULT aSelFil		:= {cFilAnt}
DEFAULT dDataIni		:= CtoD("  /  /  ")
DEFAULT aEntVazio := {}

If lBuscaExata
	laEntIgual := .T.
	For nY := 1 to Len(aEntdIni)
		If aEntdIni[nY] != aEntdFim[nY]
			laEntIgual := .F.
			Exit
		EndIf
	Next nY
EndIf

If Empty(dDataIni)
	dDataIni := Ctod("01/01/80")

	AADD(aDataIni,dDataIni)			// Data Atual Inicio

	AADD(aDataFim,dDataFim)			// Data Atual Final

Else

	// Variavel data inicial
	AADD(aDataIni,Ctod("01/01/80"))	// Data Anterior Inicio
	AADD(aDataIni,dDataIni)			// Data Atual Inicio

	AADD(aDataFim,dDataIni-1)		// Data Anterior Final
	AADD(aDataFim,dDataFim)			// Data Atual Final

EndIf


/* Cria Classe Ctb_Exec_Cube Objeto --> oCubeSldRng */
oCubeSldRng := Ctb_Exec_Cube():New(cCodCubo,cMoeda,cTpSald,nEntidade, 2, aEntVazio )

/* Cria arquivo temporario no TOP retornando nome do arquivo */
If !lMantemTmp // chamada N vezes - sem necessidade de recriar o mesmo TMP
	cArquivo	:= oCubeSldRng:CtbCriaTemp()
Else
	If __cArqEnt == NIL // primeira vez que chama a funÁ„o
		cArquivo	:= oCubeSldRng:CtbCriaTemp()
		__cArqEnt	:= cArquivo
	Else
		cArquivo	:= __cArqEnt
		dbSelectArea(__cArqEnt)
		Zap
	Endif
	ConOutR(cArquivo)
Endif

For nY:=1 To nEntidade
	oCubeSldRng:Set_Level_Cube(nY)

	oCubeSldRng:oStructCube:Ctb_Set_IniParam(nY, aEntdIni[nY])          //aqui colocado parametro inicial
	oCubeSldRng:oStructCube:Ctb_Set_FimParam(nY, aEntdFim[nY])			// parametro final
	/* Atualiza a propriedade aQueryDim */
	oCubeSldRng:CtbCriaQueryDim()
Next nY

oCubeSldRng:Set_Level_Cube(nEntidade)

oCubeSldRng:Set_aSelFil(aSelFil)

/* Monta query com a propriedade aQueryDim */
oCubeSldRng:CtbCriaQry(.F./*lMovimento*/, aDataIni/*aDtIni*/, aDataFim/*aDtFim*/, cArquivo, .T./*lAllNiveis*/, .F./* lFechamento*/)

/* Popular tabela temporaria */
oCubeSldRng:CtbPopulaTemp(cArquivo)

dbSelectArea(cArquivo)
dbGoTop()
While (cArquivo)->(!Eof())

	// Saldo na data

	If lBuscaExata .And. laEntIgual
		lRet:= .T.
		For nY:= 1 to Len(aEntdIni)
			If !Empty(aEntdIni[nY])
				If AllTrim((cArquivo)->&("CVX_NIV"+STRZERO(nY,2))) != AllTrim(aEntdIni[nY])
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nY

		If !lRet
			(cArquivo)->(DbSkip())
			Loop
		EndIf
	EndIf

	nDebito		+= (cArquivo)->CVX_SLDB02
	nCredito	+= (cArquivo)->CVX_SLCR02

	//Saldo Atual
	nSaldoAtu	+= (cArquivo)->CVX_SALD02
	nAtuDeb		+= (cArquivo)->CVX_SLDB02
	nAtuCrd		+= (cArquivo)->CVX_SLCR02

	//Saldo Anterior
	nSaldoAnt	+= (cArquivo)->CVX_SALD01
	nAntDeb		+= (cArquivo)->CVX_SLDB01
	nAntCrd 	+= (cArquivo)->CVX_SLCR01

	(cArquivo)->(DbSkip())

EndDo

If !lMantemTmp
	If Select(cArquivo) > 0
		DbSelectArea(cArquivo)
		DbCloseArea()
		MsErase(cArquivo,,"TOPCONN")
	EndIf
	oCubeSldRng:ErasedFiles()
EndIf

RestArea(aAreaAtu)
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1] Saldo Atual (com sinal)                          ≥
//≥ [2] Debito na Data                                   ≥
//≥ [3] Credito na Data                                  ≥
//≥ [4] Saldo Atual Devedor                              ≥
//≥ [5] Saldo Atual Credor                               ≥
//≥ [6] Saldo Anterior (com sinal)                       ≥
//≥ [7] Saldo Anterior Devedor                           ≥
//≥ [8] Saldo Anterior Credor                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//      [1]       [2]     [3]      [4]     [5]     [6]       [7]     [8]
Return {nSaldoAtu,nDebito,nCredito,nAtuDeb,nAtuCrd,nSaldoAnt,nAntDeb,nAntCrd}

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥CtbParCubo  ≥ Autor ≥ TOTVS                ≥ Data ≥ 09/06/2010		≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Carrega o arquivo TXT com os valores do filtro por entidades       	≥±±
±±≥			 ≥Caso o arquivo n„o exista, a funÁ„o o cria.							≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ CtbParCubo(lLeitura)                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SigaCtb                                               	    		≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ lLeitura	   = Leitura / Gravacao                         	        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
FUNCTION CtbParCubo(lLeitura,cArquivo)

Local nBytes := 0
Local nTamArq
Local xBuffer
Local nLinha := 0
Local cNomeArq	:= "" //"CTBPARCUBO.INI"

Default cArquivo := "CTBPARCUBO"

cNomeArq := cArquivo + ".INI"

//Caso a matriz esteja nula, eu leio o CTBGEREN.INI
If lLeitura

	IF !file(cNomeArq)
		nHdlGer := MSFCreate(cNomeArq,0)
		IF nHdlGer == -1
			HELP(" ",1,"CTB_ERROR")
			Final("Erro F_"+str(ferror(),2)+" em " + cNomeArq)
		Endif
		Fclose(nHdlGer)
	EndIf

	nHdlGer := FOPEN(cNomeArq,64)

	If nHdlGer <0
		HELP(" ",1,"CTB_ERROR")
		Final(cNomeArq)
	EndIf

	nTamArq:=FSEEK(nHdlGer,0,2)		// VerIfica tamanho do arquivo
	FSEEK(nHdlGer,0,0)					// Volta para inicio do arquivo

	While nBytes<nTamArq
		xBuffer:=Space(72)
		FREAD(nHdlGer,@xBuffer,72)
		nLinha++
		If nLinha <= Len(aEntidades)
			aEntidades[nLinha]:= PadR(Alltrim(xBuffer), Len(aEntidades[nLinha]) )
		Endif
		nBytes+=70
		Dbskip()
	EndDo
Else
	nHdlGer := MSFCreate(cNomeArq,0)
	IF nHdlGer == -1
		HELP(" ",1,"CTB_ERROR")
		Final("Erro F_"+str(ferror(),2)+" em "+cNomeArq)
	Endif

	For nLinha:=1 To Len(aEntidades)
		fWrite(nHdlGer,Left(aEntidades[nLinha] + Space(70), 70) +chr(13)+chr(10))
	Next

EndIf

fClose(nHdlGer)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥CtbCfCubo   ≥ Autor ≥ TOTVS                ≥ Data ≥ 09.06.2010		≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Monta a tela com as perguntas referentes ao filtro por entidades     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ CtbCfCubo(cCodSel)                                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SigaCtb                                                   			≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cCodSel	   = codigo da entidade selecionada         			   	≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CtbCfCubo(cCodSel,cArquivo,lWhenConta)

Local nOpca 	:= 1
Local nPos		:= 0
Local nReg		:= 0
Local nEntidades:= 0
Local nX,nY		:= 0
Local nEscolha	:= Val(cCodSel)

Local cPerg1	:= STR0030 //"Da Conta ?"
Local cPerg2	:= STR0031 //"Ate a Conta ?"
Local cPerg3	:= STR0032//"Do Centro de Custo ?"
Local cPerg4	:= STR0033//"Ate o Centro de Custo ?"
Local cPerg5	:= STR0034//"Do Item ?"
Local cPerg6	:= STR0035//"Ate o Item ?"
Local cPerg7	:= STR0036//"Da Classe de Valor ?"
Local cPerg8	:= STR0037//"Ate a Classe de Valor ?"

Local cPEnt05A	:= ""
Local cPEnt05B	:= ""

Local cPEnt06A	:= ""
Local cPEnt06B	:= ""

Local cPEnt07A	:= ""
Local cPEnt07B	:= ""

Local cPEnt08A	:= ""
Local cPEnt08B	:= ""

Local cPEnt09A	:= ""
Local cPEnt09B	:= ""

Local cF3Conta	:= "CT1"
Local cF3Custo	:= "CTT"
Local cF3Item	:= "CTD"
Local cF3CLVL	:= "CTH"

Local cF3Ent05	:= ""
Local cF3Ent06	:= ""
Local cF3Ent07	:= ""
Local cF3Ent08	:= ""
Local cF3Ent09	:= ""
Local bBlock
Local bBlock2

Local nPosTela 	:= 0

Local aEntidRet := {}

Local oDlg		:= nil	//Acrescentado por Fernando Radu Muscalu em 30/09/11

Default cArquivo := "CTBPARCUBO"
Default lWhenConta := .t.


If nEscolha >= 5
	For nY:=5 To nEscolha
		bBlock := '{|| cF3Ent'+ aEstrCT0[nY][1] + ':= "' + aEstrCT0[nY][4] + '" }'
		bBlock2 := '{|| cPEnt'+ aEstrCT0[nY][1] + 'A := Alltrim("'+aEstrCT0[nY][3]+'") + " '+STR0038 +' " ,cPEnt'+ aEstrCT0[nY][1] + 'B := Alltrim("'+aEstrCT0[nY][3]+'") + " '+STR0039+' " }' //De ?##"AtÈ"
		Eval(&bBlock)
		Eval(&bBlock2)
	Next nY
EndIf

//nPosTela := 130 + ( nQtdEntid * 50 )
nPosTela := 130 + ( nEscolha * 50 )

If  !FwIsInCallStack("CTBR403TestCase") .AND. !lAutomato //para caso venha da rotina de automaÁ„o + Robo, para n„o afetar rotinas automaticas
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0040) FROM 33,25 TO nPosTela,410 PIXEL //"Config. Parametros"
	//	@ 001,005 TO 130, 190 OF oDlg PIXEL
	nPos := 4
	// Entidade 01
	If nEscolha >= 1
		@ nPos,008 	SAY cPerg1 SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[1] Pict "@!" F3 cF3Conta When lWhenConta Valid CtbVldEntCubo( 1 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON

		nPos += 15
		@ nPos,008 	SAY cPerg2 SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[2] Pict "@!" F3 cF3Conta When lWhenConta Valid CtbVldEntCubo( 1 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON
	EndIf

	// Entidade 02
	If nEscolha >= 2
		nPos += 15
		@ nPos,008 	SAY cPerg3 SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[3] Pict "@!" F3 cF3Custo Valid CtbVldEntCubo( 2 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON

		nPos += 15
		@ nPos,008 	SAY cPerg4 SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[4] Pict "@!" F3 cF3Custo Valid CtbVldEntCubo( 2 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON
	EndIf

	// Entidade 03
	If nEscolha >= 3
		nPos += 15
		@ nPos,008 	SAY cPerg5 SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[5] Pict "@!" F3 cF3Item Valid CtbVldEntCubo( 3 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON

		nPos += 15
		@ nPos,008 	SAY cPerg6 SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[6] Pict "@!" F3 cF3Item Valid CtbVldEntCubo( 3 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON
	EndIf

	// Entidade 04
	If nEscolha >= 4
		nPos += 15
		@ nPos,008 	SAY cPerg7 SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[7] Pict "@!" F3 cF3CLVL Valid CtbVldEntCubo( 4 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON

		nPos += 15
		@ nPos,008 	SAY cPerg8 SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[8] Pict "@!" F3 cF3CLVL Valid CtbVldEntCubo( 4 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON
	EndIf
	// Entidade 05
	If nEscolha >= 5
		nPos += 15
		@ nPos,008 	SAY cPEnt05A SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[9] Pict "@!" F3 cF3Ent05 Valid CtbVldEntCubo( 5 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON
		nPos += 15
		@ nPos,008 	SAY cPEnt05B SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[10] Pict "@!" F3 cF3Ent05 Valid CtbVldEntCubo( 5 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON
	EndIf
	// Entidade 06
	If nEscolha >= 6
		nPos += 15
		@ nPos,008 	SAY cPEnt06A SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[11] Pict "@!" F3 cF3Ent06 Valid CtbVldEntCubo( 6 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON

		nPos += 15
		@ nPos,008 	SAY cPEnt06B SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[12] Pict "@!" F3 cF3Ent06 Valid CtbVldEntCubo( 6 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON
	EndIf
	// Entidade 07
	If nEscolha >= 7
		nPos += 15
		@ nPos,008 	SAY cPEnt07A SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[13] Pict "@!" F3 cF3Ent07 Valid CtbVldEntCubo( 7 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON

		nPos += 15
		@ nPos,008 	SAY cPEnt07B SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[14] Pict "@!" F3 cF3Ent07 Valid CtbVldEntCubo( 7 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON
	EndIf
	// Entidade 08
	If nEscolha >= 8
		nPos += 15
		@ nPos,008 	SAY cPEnt08A SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[15] Pict "@!" F3 cF3Ent08 Valid CtbVldEntCubo( 8 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON

		nPos += 15
		@ nPos,008 	SAY cPEnt08B SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[16] Pict "@!" F3 cF3Ent08 Valid CtbVldEntCubo( 8 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON
	EndIf
	// Entidade 09
	If nEscolha == 9
		nPos += 15
		@ nPos,008 	SAY cPEnt09A SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[17] Pict "@!" F3 cF3Ent09 Valid CtbVldEntCubo( 9 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON

		nPos += 15
		@ nPos,008 	SAY cPEnt09B SIZE 90, 7 OF oDlg PIXEL
		@ nPos,090 	MSGET aEntidades[18] Pict "@!" F3 cF3Ent09 Valid CtbVldEntCubo( 9 ) SIZE 60,10 OF oDlg PIXEL HASBUTTON
	EndIf
	DEFINE SBUTTON FROM 05, 156 TYPE 1 ACTION (nOpca := 1,oDlg:End())ENABLE OF oDlg

	DEFINE SBUTTON FROM 18, 156 TYPE 2 ACTION (nOpca:=0,oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)	// Zero nOpca caso
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Atualizacao do arquivo de parametrizacao de entidades  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If nOpcA = 1
	CtbParCubo(.f.,cArquivo)
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Atualizacao do retorno de entidades para processamento ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
nY := 1
For nX := 1 TO nEscolha
	AADD(aEntidRet,{aEntidades[nY],aEntidades[nY+1]})
	nY:= nY+2
Next nX

Return(aEntidRet)
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥Program   ≥CtbVldEntCubo≥ Autor ≥ Totvs              ≥ Data ≥ 06/01/11  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Valida a entidade na emissao do relatorio.      			   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥CtbVldEntCubo( nEntidade )                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpN1 = Numero da entidade a ser validada                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function CtbVldEntCubo( nEntidade )
Local aArea		:= GetArea()
Local aAreaCT0	:= CT0->( GetArea() )
Local aAreaAl	:= {}
Local cAlias	:= ""
Local cStr		:= &( ReadVar() )
Local lRet		:= .T.
Local aIndexes

aIndexes := CTBEntGtIn()

// Quando os parametros sao carregados do arquivo INI eles vem com chr 10 e 13.
cStr := StrTran( cStr, chr(10), "" )
cStr := StrTran( cStr, chr(13), "" )

If !Empty( cStr ) .AND. cStr < "ZZ"

	DbSelectArea( "CT0" )
	CT0->( DbSetOrder( 1 ) ) //CT0_FILIAL+CT0_ID
	If CT0->( DbSeek( xFilial( "CT0" ) + StrZero( nEntidade, TamSX3( "CT0_ID" )[1] ) ) )
		cAlias 	:= CT0->CT0_ALIAS
		aAreaAl	:= (cAlias)->( GetArea() )

		If cAlias == "CV0"
			lRet := .F.

			cAliasQry:=GetNextAlias()
			BeginSql Alias cAliasQry
			SELECT CV0_CODIGO
			FROM %table:CV0%
			WHERE	CV0_FILIAL = %xfilial:CV0% AND
					CV0_CODIGO = %Exp:cStr% AND
					%notDel%
			EndSql
			(cAliasQry)->(DbGoTop())
			If (cAliasQry)->(!Eof())
				lRet := .T.
			EndIf
			(cAliasQry)->(DbCloseArea())

		Else
			DbSelectArea( cAlias )
			(cAlias)->( DbSetOrder( aIndexes[nEntidade][1] ) )
			If !(cAlias)->( DbSeek( xFilial( cAlias ) + cStr ) )
				lRet := .F.
			EndIf
		EndIf

		If !lRet
			Help( " ", 1, "NOENTID" )
		EndIf

		RestArea( aAreaAl )
	EndIf
EndIf

RestArea( aAreaCT0 )
RestArea( aArea )

Return lRet

Function CtbDelArq(cArquivo)

If Select(__cArqEnt) > 0
	DbSelectArea(__cArqEnt)
	DbCloseArea()
	MsErase(__cArqEnt,,"TOPCONN")
	__cArqEnt := Nil
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} SldCmpEnt
Saldo Totalizador de Duas Entidades.

@author Alvaro Camillo Neto


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function SldCmpEnt(cEntid1,cEntid2,dData,cMoeda,cTpSald,nOrder,cHeader,cAlias,cFiltroEnt,cCodFilEnt,lImpAntLP,dDataLP,cRotina)

Local aRet 		:= {0,0,0,0,0,0,0,0}
Local cArqBase	:= ""
Local cCCusto		:= Nil
Local cItem		:= Nil
Local cClasse		:= Nil

If cAlias == 'CTV'
	cArqBase := "CTD"
	If cHeader == 'CTT'
		cCCusto := cEntid1
		cItem	 := cEntid2
	ElseIf cHeader == 'CTD'
		cItem	 := cEntid1
		cCCusto := cEntid2
	EndIf
ElseIf cAlias == 'CTW'
	cArqBase := "CTH"
	If cHeader == 'CTT'
		cCCusto := cEntid1
		cClasse := cEntid2
	ElseIf cHeader == 'CTH'
		cClasse := cEntid1
		cCCusto := cEntid2
	EndIf
ElseIf cAlias == 'CTX'
	cArqBase := "CTH"
	If cHeader == 'CTD'
		cItem 		:= cEntid1
		cClasse	:= cEntid2
	ElseIf cHeader == 'CTH'
		cClasse	:= cEntid1
		cItem 		:= cEntid2
	EndIf
ElseIf cAlias == 'CTY'
	cArqBase := "CTH"
	If  cHeader == 'CTT' .And. cFiltroEnt == 'CTD'
		cCCusto 	:= cEntid1
		cItem 		:= cCodFilEnt
		cClasse	:= cEntid2
	ElseIf  cHeader == 'CTT' .And. cFiltroEnt == 'CTH'
		cCCusto 	:= cEntid1
		cItem 		:= cEntid2
		cClasse	:= cCodFilEnt
	ElseIf  cHeader == 'CTD' .And. cFiltroEnt == 'CTT'
		cCCusto 	:= cCodFilEnt
		cItem 		:= cEntid1
		cClasse	:= cEntid2
	ElseIf  cHeader == 'CTD' .And. cFiltroEnt == 'CTH'
		cCCusto 	:= cEntid2
		cItem 		:= cEntid1
		cClasse	:= cCodFilEnt
	ElseIf  cHeader == 'CTH' .And. cFiltroEnt == 'CTT'
		cCCusto 	:= cCodFilEnt
		cItem 		:= cEntid2
		cClasse	:= cEntid1
	ElseIf  cHeader == 'CTH' .And. cFiltroEnt == 'CTD'
		cCCusto 	:= cEntid2
		cItem 		:= cCodFilEnt
		cClasse	:= cEntid1
	EndIf
EndIf

If !Empty(cArqBase)
	aRet := SaldoCQ(@cArqBase,/*@cConta*/,@cCCusto,@cItem,@cClasse,/*@cIdent*/,@dData,@cMoeda,@cTpSald,@cRotina,@lImpAntLP,@dDataLP,/*@cFilEsp*/,.T.)
EndIf

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} CtSldCtEnt
Comparativo entre 2 Tipos de Saldos -Entidade / Conta

@author Alvaro Camillo Neto

@param oMeter	  Objeto oMeter
@param oText	  Objeto oText
@param oDlg		  Objeto oDlg
@param lEnd 	  lEnd
@param cArqTmp	  Data Inicial
@param dDataIni   Data Final
@param dDataFim   Alias do Arquivo
@param cArq1	  Arquivo Cadastro 1 (Principal)
@param cArq2      Arquivo Cadastro 2 (Auxiliar)
@param cContaIni  Conta Inicial
@param cContaFim  Conta Final
@param cCCIni	  Centro de Custo Inicial
@param cCCFim	  Centro de Custo Final
@param cItemIni   Item Inicial
@param cItemFim   Item Final
@param cClVlIni   Classe de Valor Inicial
@param cClvlFim   Classe de Valor Final
@param cMoeda	  Moeda
@param cTpSld1	  Tipo de Saldo 1
@param cTpSld2	  Tipo de Saldo 2
@param aSetOfBook   Set Of Book
@param cSegmento   Filtra por Segmento
@param cSegIni	  Segmento Inicial
@param cSegFim	  Segmento Final
@param cFiltSegm   Segmento Contido em
@param lVariacao0   Se Considera Variacao 0
@param nDivide 	  Fator de Divisao




@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function CTSldCtEnt(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cContaIni,;
					cContaFim,cEntidIni,cEntidFim,cMoeda,cTpSld1,cTpSld2,aSetOfBook,;
					cSegmento,cSegIni,cSegFim,cFiltSegm,cAlias,;
					lCusto,lItem,lClVl,lAtSldBase,nInicio,nFinal,cFilDe,cFilate,;
					nDivide,lVariacao0)
Local aSaveArea := GetArea()

Local cEntid
Local cContaSup
Local cDesc
Local cMascara  := aSetOfBook[2] //VERIFICAR
Local cCodEnt	:= ""
Local cCusIni	:= ""
Local cCusFim	:= ""
Local cItemIni	:= ""
Local cItemFim	:= ""
Local cCodRes	:= ""
Local cCodEntRes:= ""
Local CQ7poEnt	:= ""
Local cCodTpEnt := ""
Local cDescEnt	:= ""
Local cCadAlias	:= ""
Local nMeter	:= 0

Local nPos		:= 0
Local nDigitos	:= 0
Local nRegTmp   := 0
Local nOrder1	:= 0
Local nOrder2	:= 0
Local nTamCC	:= Len(CriaVar("CTT_CUSTO"))
Local nTamItem	:= Len(CriaVar("CTD_ITEM"))
Local nMovSld1	:= 0
Local nMovSld2	:= 0
Local nTotal	:= 0

Local bCond1	:= {||.F.}
Local bCond2	:= {||.F.}

Local oProcess
Local cCondCT1	:= ""
Local cCondEnt	:= ""
Local cCondFil	:= ""
Local cContaEnt	:= ""
Local cFilCT1	:= ""
Local cFilEnt	:= ""
Local cOrderBy	:= ""
Local cQuery 	:= ""
Local cSelect	:= ""
Local nMin		:= 0
Local nMax		:= 0


lVariacao0	:= Iif(lVariacao0 == Nil,.T.,lVariacao0)
nDivide 	:= Iif(nDivide == Nil,1,nDivide)


// Verifica Filtragem por Segmento da  Conta
If !Empty(cSegmento)
	dbSelectArea("CTM")
	dbSetOrder(1)
	If MsSeek(xFilial()+cMascara)
		While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cMascara
			nPos += Val(CTM->CTM_DIGITO)
			If CTM->CTM_SEGMEN == cSegmento
				nPos -= Val(CTM->CTM_DIGITO)
				nPos ++
				nDigitos := Val(CTM->CTM_DIGITO)
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf
EndIf

If cAlias == "CT3"
	cOrigem := "CQ3"
	cFilEnt 	:=	Iif(Empty(xFilial("CTT")),"C","E")
	cCadAlias   := "CTT"
	cSelect		:= "ARQ.CQ3_CCUSTO CODENT, CAD.CTT_RES ENTRES, CAD.CTT_BOOK ENTBOOK, "
	cSelect		+= "CAD.CTT_CCSUP ENTSUP, CAD.CTT_CLASSE ENTCLASSE, "
	cSelect		+= "CAD.CTT_DESC" + cMoeda+ " DESCENT "
	cCondEnt	:= " ARQ.CQ3_CCUSTO BETWEEN '" + cEntidIni + "' AND '" + cEntidFim + "' AND "
	cCondEnt   	+= " ( ARQ.CQ3_CCUSTO = CAD.CTT_CUSTO "
	cOrderBy	:= " ARQ.CQ3_CCUSTO, ARQ.CQ3_CONTA"
ElseIf cAlias == "CT4"
	cFilEnt 	:=	Iif(Empty(xFilial("CTD")),"C","E")
	cCadAlias   := "CTD"
	cOrigem := "CQ5"
	cSelect		:= "ARQ.CQ5_ITEM CODENT, CAD.CTD_RES ENTRES, CAD.CTD_BOOK ENTBOOK, "
	cSelect		+= "CAD.CTD_ITSUP ENTSUP, CAD.CTD_CLASSE ENTCLASSE, "
	cSelect		+= "CAD.CTD_DESC" + cMoeda+ " DESCENT "
	cCondEnt	:= " ARQ.CQ5_ITEM BETWEEN '" + cEntidIni + "' AND '" + cEntidFim + "' AND "
	cCondEnt   	+= " ( ARQ.CQ5_ITEM = CAD.CTD_ITEM "
	cOrderBy	:= " ARQ.CQ5_ITEM, ARQ.CQ5_CONTA"
ElseIf cAlias == "CTI"
	cOrigem := "CQ7"
	cFilEnt		:=	Iif(Empty(xFilial("CTH")),"C","E")
	cCadAlias	:= "CTH"
	cSelect		:= "ARQ.CQ7_CLVL CODENT, CAD.CTH_RES ENTRES, CAD.CTH_BOOK ENTBOOK, "
	cSelect		+= "CAD.CTH_CLSUP ENTSUP, CAD.CTH_CLASSE ENTCLASSE, "
	cSelect		+= "CAD.CTH_DESC" + cMoeda+ " DESCENT "
	cCondEnt	:= " ARQ.CQ7_CLVL BETWEEN '" + cEntidIni + "' AND '" + cEntidFim + "' AND "
	cCondEnt   	+= " ( ARQ.CQ7_CLVL = CAD.CTH_CLVL "
	cOrderBy	:= " ARQ.CQ7_CLVL, ARQ.CQ7_CONTA"
EndIf

cFilCT1 :=	Iif(Empty(xFilial("CT1")),"C","E")

If cFilEnt == "E"		//Se for Exclusivo
	cCondFil := " AND ARQ."+cOrigem+"_FILIAL = '" + xFilial(cOrigem) +"' ) AND "
Else
	cCondFil := " ) AND "
EndIf

If cFilCT1 == "E"		//Se for Exclusivo
	cCondCT1 := " AND ARQ."+cOrigem+"_FILIAL = '" + xFilial(cOrigem) +"' ) AND "
Else
	cCondCT1 := " ) AND "
EndIf

cOrder := SqlOrder(indexKey())
cContaEnt := "cContaEnt"

cQuery := "SELECT DISTINCT ARQ."+cOrigem+"_FILIAL FILIAL, ARQ."+cOrigem+"_CONTA CONTA, "
cQuery += "CT1.CT1_RES CTARES, CT1.CT1_BOOK CTBOOK, CT1.CT1_CTASUP CTASUP, CT1.CT1_CLASSE CTACLASSE, CT1.CT1_NORMAL CTANORMAL, CT1.CT1_GRUPO CTAGRUPO, "
cQuery += "CT1.CT1_DESC" + cMoeda+ " DESCCTA, "
cQuery += cSelect
cQuery += "FROM " + RetSqlName(cOrigem)+" ARQ ,"
cQuery += " " + RetSqlName(cCadAlias)+" CAD ,"
cQuery += " " + RetSqlName("CT1")+" CT1 "
cQuery += "WHERE CT1_CLASSE = '2' AND ARQ."+cOrigem+"_FILIAL = '" + xFilial(cOrigem) + "'"
cQuery += " AND ARQ."+cOrigem+"_MOEDA ='"+cMoeda+"' "
cQuery += " AND (ARQ."+cOrigem+"_CONTA = CT1.CT1_CONTA "
cQuery += cCondCT1
cQuery += cCondEnt
cQuery += cCondFil
cQuery += "ARQ."+cOrigem+"_CONTA BETWEEN '" + cContaIni + "' AND '" + cContaFim + "' AND "
cQuery += "(ARQ."+cOrigem+"_TPSALD ='"+cTpSld1+"' OR ARQ."+cOrigem+"_TPSALD ='"+cTpSld2 + "') AND "
cQuery += "ARQ.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY "
cQuery += cOrderBy
cQuery := ChangeQuery(cQuery)

If ( Select ( "cContaEnt" ) <> 0 )
	dbSelectArea ( "cContaEnt" )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cContaEnt,.T.,.F.)
aStru := (cOrigem)->(dbStruct())

dbSelectArea(cContaEnt)
While !Eof()

	If !Empty(aSetOfBook[1])
		If !(aSetOfBook[1] $ cContaEnt->CTBOOK)
			dbSelectArea(cContaEnt)
			dbSkip()
			Loop
		EndIf
	Endif

	//Caso faca filtragem por segmento de item,verifico se esta dentro
	//da solicitacao feita pelo usuario.
	If !Empty(cSegmento)
		If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
			If  !(Substr(cContaEnt->CONTA,nPos,nDigitos) $ (cFiltSegm) )
				dbSelectArea(cContaEnt)
				dbSkip()
				Loop
			EndIf
		Else
			If Substr(cContaEnt->CONTA,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
					Substr(cContaEnt->CONTA,nPos,nDigitos) > Alltrim(cSegFim)
				dbSelectArea(cContaEnt)
				dbSkip()
				Loop
			EndIf
		Endif
	EndIf

	//Calculo dos saldos
	If cAlias == 'CT3'
		nMovSld1	:= MovCusto(cContaEnt->CONTA,cContaEnt->CODENT,dDataIni,dDataFim,cMoeda,cTpSld1,3)
		nMovSld2	:= MovCusto(cContaEnt->CONTA,cContaEnt->CODENT,dDataIni,dDataFim,cMoeda,cTpSld2,3)
	Endif

	If !lVariacao0
		If 	nMovSld1 = 0 .And. nMovSld2 = 0
			dbSkip()
			Loop
		EndIf
	EndIf

	dbSelectArea("cArqTmp")
	dbSetOrder(1)
	If !MsSeek(cContaEnt->CODENT+cContaEnt->CONTA)
		dbAppend()
		Replace CONTA 		With cContaEnt->CONTA
		Replace DESCCTA		With cContaEnt->DESCCTA
		Replace TIPOCONTA 	With cContaEnt->CTACLASSE
		Replace CTARES      With cContaEnt->CTARES
		If cAlias == 'CT3'
			Replace CUSTO	With cContaEnt->CODENT
			Replace CCRES	With cContaEnt->ENTRES
			Replace TIPOCC  With cContaEnt->ENTCLASSE
			Replace DESCCC	With cContaEnt->DESCENT
		ElseIf cAlias == 'CT4'
			Replace ITEM 	 With cContaEnt->CODENT
			Replace ITEMRES  With cContaEnt->ENTRES
			Replace TIPOITEM With cContaEnt->ENTCLASSE
			Replace DESCITEM With cContaEnt->DESCENT
		ElseIf cAlias == 'CTI'
			Replace CLVL 	 With cContaEnt->CODENT
			Replace CLVLRES  With cContaEnt->ENTRES
			Replace TIPOCLVL With cContaEnt->ENTCLASSE
			Replace DESCCLVL With cContaEnt->DESCENT
		Endif
	Endif

	If nDivide > 1
		nMovSld1 := Round(NoRound((nMovSld1/nDivide),3),2)
		nMovSld2 := Round(NoRound((nMovSld2/nDivide),3),2)
	EndIf

	dbSelectArea("cArqTmp")
	dbSetOrder(1)
	Replace MOVIMENTO1 With nMovSld1	//Movimento Tipo de Saldo 1
	Replace MOVIMENTO2 With nMovSld2	//Movimento Tipo de Saldo 2

	If nMovSld1 = 0 .Or. nMovSld2 = 0
		Replace VARIACAO   With 0
	Else
		Replace VARIACAO   With (nMovSld1/nMovSld2) *100
	EndIf

	dbSelectArea(cContaEnt)
	dbSkip()
EndDo

If ( Select ( "cContaEnt" ) <> 0 )
	dbSelectArea ( "cContaEnt" )
	dbCloseArea ()
Endif




// Grava contas sinteticas

dbSelectArea("cArqTmp")
If ValType(oMeter) == "O"
	oMeter:SetTotal(cArqTmp->(RecCount()))
	oMeter:Set(0)
EndIF
dbGoTop()

While !Eof()
	nMeter++
	If nMeter%1000 = 0
		If ValType(oMeter) == "O"
			oMeter:Set(nMeter)
		EndIf
	EndIf
	nMovim01	:= MOVIMENTO1
	nMovim02	:= MOVIMENTO2
	nRegTmp 	:= Recno()

	If cAlias == 'CT3'
		cEntid 	 := cArqTmp->CUSTO
		cCodRes	 := cArqTmp->CCRES
		CQ7poEnt := cArqTmp->TIPOCC
		cDescEnt := cArqTmp->DESCCC
	ElseIf cAlias == 'CT4'
		cEntid 	 := cArqTmp->ITEM
		cCodRes	 := cArqTmp->ITEMRES
		CQ7poEnt := cArqTmp->TIPOITEM
		cDescEnt := cArqTmp->DESCITEM
	ElseIf cAlias == 'CTI'
		cEntid 	 := cArqTmp->CLVL
		cCodRes	 := cArqTmp->CLVLRES
		CQ7poEnt := cArqTmp->TIPOCLVL
		cDescEnt := cArqTmp->DESCCLVL
	EndIf

	dbSelectArea("CT1")
	dbSetOrder(1)
	cContaSup := cArqTmp->CONTA
	MsSeek(xFilial("CT1")+ cContaSup)
	If Empty(CT1->CT1_CTASUP)
		dbSelectArea("cArqTmp")
		Replace NIVEL1 With .T.
		dbSelectArea("CT1")
	EndIf

	cContaSup := CT1->CT1_CTASUP
	MsSeek(xFilial("CT1")+ cContaSup)

	While !Eof() .And. CT1->CT1_FILIAL == xFilial()

		cDesc := &("CT1->CT1_DESC"+cMoeda)
		If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
			cDesc := CT1->CT1_DESC01
		Endif

		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		If ! MsSeek(cEntid+cContaSup)
			dbAppend()
			Replace CONTA		With cContaSup
			Replace DESCCTA 	With cDesc
			Replace TIPOCONTA	With CT1->CT1_CLASSE
			Replace CTARES		With CT1->CT1_RES
			If cAlias == 'CT3'
				Replace CUSTO With cEntid
				Replace CCRES With cCodRes
				Replace TIPOCC With CQ7poEnt
				Replace DESCCC With cDescEnt
			ElseIf cAlias == 'CT4'
				Replace ITEM With cEntid
				Replace ITEMRES With cCodRes
				Replace TIPOITEM With CQ7poEnt
				Replace DESCITEM With cDescEnt
			ElseIf cAlias == 'CTI'
				Replace CLVL With cEntid
				Replace CLVLRES With cCodRes
				Replace TIPOCLVL With CQ7poEnt
				Replace DESCCLVL WITH cDescEnt
			EndIf
		EndIf

		Replace	 MOVIMENTO1 With MOVIMENTO1 + nMovim01
		Replace  MOVIMENTO2 With MOVIMENTO2 + nMovim02

		If MOVIMENTO1 = 0 .Or. MOVIMENTO2 = 0
			Replace VARIACAO   With 0
		Else
			Replace VARIACAO   With (MOVIMENTO1/MOVIMENTO2)*100
		EndIf

		dbSelectArea("CT1")
		cContaSup := CT1->CT1_CTASUP
		If Empty(CT1->CT1_CTASUP)
			dbSelectArea("cArqTmp")
			Replace NIVEL1 With .T.
			dbSelectArea("CT1")
			Exit
		EndIf
		MsSeek(xFilial()+cContaSup)

		dbSelectArea("cArqTmp")
		dbGoto(nRegTmp)
		dbSelectArea("CT1")
	EndDo
	dbSelectArea("cArqTmp")
	dbGoto(nRegTmp)
	dbSkip()
EndDo
RestArea(aSaveArea)

Return


//-------------------------------------------------------------------
/*{Protheus.doc} CtSldSoEnt
Comparativo entre 2 Tipos de Saldos -So Entidade

@author Alvaro Camillo Neto

@param oMeter	  Objeto oMeter
@param oText	  Objeto oText
@param oDlg		  Objeto oDlg
@param lEnd 	  lEnd
@param cArqTmp	  Data Inicial
@param dDataIni   Data Final
@param dDataFim   Alias do Arquivo
@param cArq1	  Arquivo Cadastro 1 (Principal)
@param cArq2      Arquivo Cadastro 2 (Auxiliar)
@param cContaIni  Conta Inicial
@param cContaFim  Conta Final
@param cCCIni	  Centro de Custo Inicial
@param cCCFim	  Centro de Custo Final
@param cItemIni   Item Inicial
@param cItemFim   Item Final
@param cClVlIni   Classe de Valor Inicial
@param cClvlFim   Classe de Valor Final
@param cMoeda	  Moeda
@param cTpSld1	  Tipo de Saldo 1
@param cTpSld2	  Tipo de Saldo 2
@param aSetOfBook  Set Of Book
@param cSegmento   Filtra por Segmento
@param cSegIni	  Segmento Inicial
@param cSegFim	  Segmento Final
@param cFiltSegm  Segmento Contido em
@param lVariacao0   Se Considera Variacao 0
@param nDivide 	  Fator de Divisao
@param bVariacao   Bloco de codigo para tratamentos especificos
@param cIdent   Identificador do arquivo que ser· tratado

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CTSldSoEnt(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni,cEntidFim,;
					cMoeda,cTpSld1,cTpSld2,aSetOfBook,;
					cSegmento,cSegIni,cSegFim,cFiltSegm,cAlias,;
					lCusto,lItem,lClVl,lAtSldBase,nInicio,nFinal,cFilDe,cFilate,;
					nDivide,lVariacao0,nGrupo,bVariacao,cIdent,aSelFil,lTodasFil)

Local aSaveArea 	:= GetArea()

Local cDesc
Local cMascara		:= ""

Local nPos			:= 0
Local nDigitos		:= 0
Local nRegTmp   	:= 0
Local nTamDesc		:= ""
Local nMovSld1		:= 0
Local nMovSld2		:= 0
Local nColuna1		:= 0
Local nColuna2		:= 0
Local nTotal		:= 0
Local nMeter		:= 0

Local oProcess
Local dMinSld1 := cTod("")
Local dMinSld2 := cTod("")

Local lAtSldCmp := Iif(GetMV("MV_SLDCOMP")== "S",.T.,.F.)
Local cMensagem := OemToAnsi(STR0002)// O plano gerencial ainda nao esta disponivel nesse relatorio.
Local nMin			:= 0
Local nMax			:= 0

DEFAULT aSelFil   := {}
DEFAULT lTodasFil := .F.

lVariacao0	:= Iif(lVariacao0 == Nil,.T.,lVariacao0)
nDivide 	:= Iif(nDivide == Nil,1,nDivide)

If cAlias	== 'CT7'
	If !Empty(aSetOfBook[2])
		cMascara	:= aSetOfBook[2]
	EndIf
ElseIf cAlias	== 'CTU'
	Do Case
	Case cIdent == 'CTT'
		cMascara	:= aSetOfBook[6]
		cOrigem		:= 'CT3'
	Case cIdent	== 'CTD'
		cMascara	:= aSetOfBook[7]
		cOrigem		:= 'CT4'
	Case cIdent == 'CTH'
		cMascara	:= aSetOfBook[8]
		cOrigem		:= 'CTI'
	EndCase
EndIf



// Verifica Filtragem por Segmento da Entidade
If !Empty(cSegmento)
	dbSelectArea("CTM")
	dbSetOrder(1)
	If MsSeek(xFilial()+cMascara)
		While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cMascara
			nPos += Val(CTM->CTM_DIGITO)
			If CTM->CTM_SEGMEN == cSegmento
				nPos -= Val(CTM->CTM_DIGITO)
				nPos ++
				nDigitos := Val(CTM->CTM_DIGITO)
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf
EndIf

If cAlias == 'CT7'

	dbSelectArea("CT1")
	If ValType(oMeter) == "O"
		oMeter:SetTotal(CT1->(RecCount()))
		oMeter:Set(0)
	EndIf
	dbSetOrder(3)

	// Posiciona na primeira conta analitica
	MsSeek(xFilial()+"2"+cEntidIni,.T.)

	While !Eof() .And. 	CT1->CT1_FILIAL == xFilial() .And.;
			CT1->CT1_CONTA <= cEntidFim .And. CT1_CLASSE != "1"
		nMeter++
		If nMeter%1000 = 0
			If ValType(oMeter) == "O"
				oMeter:Set(nMeter)
			EndIf
		EndIf
		// Grava conta analitica
		cConta 	:= CT1->CT1_CONTA

		// Conta nao pertencera ao arquivo pois sera filtrado pelo Set Of Book
		// Escolhido
		If !Empty(aSetOfBook[1])
			If !(aSetOfBook[1] $ CT1->CT1_BOOK)
				CT1->(dbSkip())
				Loop
			EndIf
		EndIf

		If !Empty(cSegmento)
			If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
				If  !(Substr(CT1->CT1_CONTA,nPos,nDigitos) $ (cFiltSegm) )
					dbSkip()
					Loop
				EndIf
			Else
				If Substr(CT1->CT1_CONTA,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
						Substr(CT1->CT1_CONTA,nPos,nDigitos) > Alltrim(cSegFim)
					CT1->(dbSkip())
					Loop
				EndIf
			Endif
		EndIf

		//Calculo dos saldos
		If cAlias == 'CT7'
			If cTpSld1 = cTpSld2		// Comparacao de moeda
				nMovSld1 := SaldoCt7(CT1->CT1_CONTA,dDataFim,"01",cTpSld1)[1]
				nMovSld2 := SaldoCt7(CT1->CT1_CONTA,dDataFim,cMoeda,cTpSld2)[1]
			Else
				nMovSld1 := MovConta(CT1->CT1_CONTA,dDataIni,dDataFim,cMoeda,cTpSld1,3)
				nMovSld2 := MovConta(CT1->CT1_CONTA,dDataIni,dDataFim,cMoeda,cTpSld2,3)
			Endif
		Endif

		If !lVariacao0
			If 	nMovSld1 = 0 .And. nMovSld2 = 0
				dbSelectArea("CT1")
				dbSkip()
				Loop
			EndIf
		EndIf

		If lVariacao0 .And. nMovSld1 = 0 .And. nMovSld2 = 0
			If CtbExDtFim("CT1")
				If !CtbVlDtFim("CT1",dDataIni)
					dbSelectArea("CT1")
					dbSkip()
					Loop
				EndIf
			EndIf
		EndIf

		cDesc 		:= &("CT1->CT1_DESC"+cMoeda)
		If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
			cDesc := CT1->CT1_DESC01
		Endif
		nTamDesc    := Len(CriaVar("CT1->CT1_DESC"+cMoeda))
		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		If !MsSeek(xFilial()+cConta)
			dbAppend()
			Replace CONTA 		With cConta
			Replace DESCCTA		With cDesc
			Replace TIPOCONTA 	With CT1->CT1_CLASSE
			Replace CTARES    	With CT1->CT1_RES
			Replace NORMAL    	With CT1->CT1_NORMAL
			Replace GRUPO		With CT1->CT1_GRUPO
		EndIf

		If nDivide > 1
			nMovSld1 := Round(NoRound((nMovSld1/nDivide),3),2)
			nMovSld2 := Round(NoRound((nMovSld2/nDivide),3),2)
		EndIf

		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		Replace MOVIMENTO1 With nMovSld1	//Movimento Tipo de Saldo 1
		Replace MOVIMENTO2 With nMovSld2	//Movimento Tipo de Saldo 2

		If nMovSld1 = 0 .Or. nMovSld2 = 0
			Replace VARIACAO   With 0
		Else
			Replace VARIACAO   With (nMovSld1/nMovSld2) *100
		EndIf

		If bVariacao <> Nil
			Eval(bVariacao)
		Endif

		dbSelectArea("CT1")
		dbSkip()
	End


	// Grava contas sinteticas

	dbSelectArea("cArqTmp")
	If ValType(oMeter) == "O"
		oMeter:SetTotal(cArqTmp->(RecCount()))
		oMeter:Set(0)
	EndIF
	dbGoTop()

	While!Eof()
	nMeter++
	If nMeter%1000 = 0
		If ValType(oMeter) == "O"
			oMeter:Set(nMeter)
		EndIF
	EndIf
	nMovim01	:= MOVIMENTO1
	nMovim02	:= MOVIMENTO2
	If FieldPos("COLUNA_1") > 0
		nColuna1 := COLUNA_1
		nColuna2 := COLUNA_2
	Else
		nColuna1 := nColuna2 := 0.00
	Endif
	nRegTmp 	:= Recno()

	dbSelectArea("CT1")
	dbSetOrder(1)
	MsSeek(xFilial()+cArqTmp->CONTA)

	If Empty(CT1->CT1_CTASUP)
		dbSelectArea("cArqTmp")
		Replace NIVEL1 With .T.
		dbSelectArea("CT1")
	EndIf

	cContaSup := CT1->CT1_CTASUP
	MsSeek(xFilial()+cContaSup)

	While !Eof() .And. CT1->CT1_FILIAL == xFilial()
		cDesc := &("CT1->CT1_DESC"+cMoeda)
		If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
			cDesc := CT1->CT1_DESC01
		Endif
		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		If !MsSeek(cContaSup)
			dbAppend()
			Replace CONTA		With cContaSup
			Replace DESCCTA		With cDesc
			Replace TIPOCONTA	With CT1->CT1_CLASSE
			Replace CTARES    	With CT1->CT1_RES
			Replace NORMAL   	With CT1->CT1_NORMAL
			Replace GRUPO		With CT1->CT1_GRUPO
		EndIf

		Replace	 MOVIMENTO1 With MOVIMENTO1 + nMovim01
		Replace  MOVIMENTO2 With MOVIMENTO2 + nMovim02

		If MOVIMENTO1 = 0 .Or. MOVIMENTO2 = 0
			Replace VARIACAO   With 0
		Else
			Replace VARIACAO   With (MOVIMENTO1/MOVIMENTO2)*100
		EndIf

		If nColuna1 # 0
			Replace COLUNA_1 With COLUNA_1 + nColuna1
		Endif

		If nColuna2 # 0
			Replace COLUNA_2 With COLUNA_2 + nColuna2
		Endif

		If bVariacao <> Nil
			Eval(bVariacao)
		Endif

		dbSelectArea("CT1")
		cContaSup := CT1->CT1_CTASUP
		If Empty(CT1->CT1_CTASUP)
			dbSelectArea("cArqTmp")
			Replace NIVEL1 With .T.
			dbSelectArea("CT1")
			Exit
		EndIf
		MsSeek(xFilial()+cContaSup)
	EndDo

	dbSelectArea("cArqTmp")
	dbSetOrder(1)
	dbGoTo(nRegTmp)
	dbSkip()
EndDo

ElseIf cAlias == 'CTU'

	Do Case
	Case cIdent == 'CTT'
		cCodEnt		:= 'CUSTO'
		cCodEntSup	:= 'CCSUP'
		nTamDesc	:= Len(CriaVar("CTT->CTT_DESC"+cMoeda))
	Case cIdent=='CTD'
		cCodEnt		:= 'ITEM'
		cCodEntSup  := 'ITSUP'
		nTamDesc	:= Len(CriaVar("CTD->CTD_DESC"+cMoeda))
	Case cIdent =='CTH'
		cCodEnt		:= 'CLVL'
		cCodEntSup  := 'CLSUP'
		nTamDesc	:= Len(CriaVar("CTH->CTH_DESC"+cMoeda))
	EndCase

	dbSelectArea(cIdent)
	dbSetOrder(1)
	MsSeek(xFilial()+cEntidIni,.T.)

	While 	!Eof() .And. &(cIdent + "_FILIAL") == xFilial() .And.;
			&(cIdent + "_" + cCodEnt) >= cEntidIni .And.;
			&(cIdent + "_" + cCodEnt) <= cEntidFim

		cCodigo :=  &(cIdent + "_" + cCodEnt)		// Codigo Atual
		If !Empty(aSetOfBook[1]) .And. !(aSetOfBook[1] $ &(cIdent+"_BOOK"))
			dbSkip()
			Loop
		Endif

		//Caso faca filtragem por segmento de item,verifico se esta dentro
		//da solicitacao feita pelo usuario.
		If !Empty(cSegmento)
			If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
				If  !(Substr(cCodigo,nPos,nDigitos) $ (cFiltSegm) )
					dbSkip()
					Loop
				EndIf
			Else
				If 	Substr(cCodigo,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
						Substr(cCodigo,nPos,nDigitos) > Alltrim(cSegFim)
					dbSkip()
					Loop
				EndIf
			Endif
		EndIf

		Do Case
		Case cIdent == 'CTT'
			nMovSld1 :=	MovCusto("",cCodigo,dDataIni,dDataFim,cMoeda,cTpSld1,3)
			nMovSld2 :=	MovCusto("",cCodigo,dDataIni,dDataFim,cMoeda,cTpSld2,3)

		Case cIdent=='CTD'
			nMovSld1 :=	MovItem("","",cCodigo,dDataIni,dDataFim,cMoeda,cTpSld1,3)
			nMovSld2 :=	MovItem("","",cCodigo,dDataIni,dDataFim,cMoeda,cTpSld2,3)

		Case cIdent =='CTH'
			nMovSld1 :=	MovClass("","","",cCodigo,dDataIni,dDataFim,cMoeda,cTpSld1,3)
			nMovSld2 :=	MovClass("","","",cCodigo,dDataIni,dDataFim,cMoeda,cTpSld2,3)
		EndCase


		If !lVariacao0
			If 	nMovSld1 = 0 .And. nMovSld2 = 0
				dbSkip()
				Loop
			EndIf
		EndIf

		If lVariacao0 .And. nMovSld1 = 0 .And. nMovSld2 = 0
			If CtbExDtFim(cIdent)
				If !CtbVlDtFim(cIdent,dDataIni)
					dbSelectArea(cIdent)
					dbSkip()
					Loop
				EndIf
			EndIf
		EndIf

		cDesc := &(cIdent+"->"+cIdent+"_DESC"+cMoeda)
		If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
			cDesc := &(cIdent+"->"+cIdent+"_DESC01")
		Endif

		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		If !MsSeek(cCodigo)
			dbAppend()
			If cIdent == 'CTT'
				Replace CUSTO   	With cCodigo
				Replace DESCCC		With cDesc
				Replace TIPOCC 	With CTT->CTT_CLASSE
				Replace CCSUP 		With CTT->CTT_CCSUP
				Replace CCRES		With CTT->CTT_RES
			ElseIf cIdent == 'CTD'
				Replace ITEM 		With cCodigo
				Replace DESCITEM	With cDesc
				Replace TIPOITEM 	With CTD->CTD_CLASSE
				Replace ITSUP  		With CTD->CTD_ITSUP
				Replace ITEMRES		With CTD->CTD_RES
			ElseIf cIdent == 'CTH'
				Replace CLVL    	 With cCodigo
				Replace DESCCLVL	 With cDesc
				Replace TIPOCLVL 	 With CTH->CTH_CLASSE
				Replace CLSUP    	 With CTH->CTH_CLSUP
				Replace CLVLRES		 With CTH->CTH_RES
			EndIf
		EndIf

		If nDivide > 1
			nMovSld1 := Round(NoRound((nMovSld1/nDivide),3),2)
			nMovSld2 := Round(NoRound((nMovSld2/nDivide),3),2)
		EndIf

		dbSelectArea("cArqTmp")
		dbSetOrder(1)

		Replace MOVIMENTO1 With nMovSld1	//Movimento Tipo de Saldo 1
		Replace MOVIMENTO2 With nMovSld2	//Movimento Tipo de Saldo 2

		If nMovSld1 = 0 .Or. nMovSld2 = 0
			Replace VARIACAO   With 0
		Else
			Replace VARIACAO   With (nMovSld1/nMovSld2) *100
		EndIf

		If bVariacao <> Nil
			Eval(bVariacao)
		Endif


		dbSelectArea(cIdent)
		dbSkip()
	Enddo

	// Grava sinteticas
	dbSelectArea("cArqTmp")
	dbGoTop()

	While!Eof()

	nMovim01	:= MOVIMENTO1
	nMovim02	:= MOVIMENTO2
	If FieldPos("COLUNA_1") > 0
		nColuna1 := COLUNA_1
		nColuna2 := COLUNA_2
	Else
		nColuna1 := nColuna2 := 0.00
	Endif

	nRegTmp := Recno()

	dbSelectArea(cIdent)
	dbSetOrder(1)
	cEntidSup := &("cArqTmp->"+cCodEntSup)
	If Empty(cEntidSup)
		dbSelectArea("cArqTmp")
		Replace NIVEL1 With .T.
		dbSelectArea(cIdent)
	EndIf
	MsSeek(xFilial()+ &("cArqTmp->"+cCodEntSup))

	While !Eof() .And. &(cIdent+"_FILIAL") == xFilial()

		cDesc := &(cIdent+"_DESC"+cMoeda)
		If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
			cDesc := &(cIdent+"_DESC01")
		Endif

		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		If ! MsSeek(xFilial()+cEntidSup)
			dbAppend()
			If cIdent == 'CTT'
				Replace CUSTO   	With cEntidSup
				Replace DESCCC		With cDesc
				Replace TIPOCC 		With CTT->CTT_CLASSE
				Replace CCSUP 		With CTT->CTT_CCSUP
				Replace CCRES		With CTT->CTT_RES
			ElseIf cIdent == 'CTD'
				Replace ITEM 		With cEntidSup
				Replace DESCITEM	With cDesc
				Replace TIPOITEM 	With CTD->CTD_CLASSE
				Replace ITSUP  		With CTD->CTD_ITSUP
				Replace ITEMRES		With CTD->CTD_RES
			ElseIf cIdent == 'CTH'
				Replace CLVL 	 With cEntidSup
				Replace DESCCLVL With cDesc
				Replace TIPOCLVL With CTH->CTH_CLASSE
				Replace CLSUP	 With CTH->CTH_CLSUP
				Replace CLVLRES	 With CTH->CTH_RES
			EndIf
		EndIf

		Replace	 MOVIMENTO1 With MOVIMENTO1 + nMovim01
		Replace  MOVIMENTO2 With MOVIMENTO2 + nMovim02

		If MOVIMENTO1 = 0 .Or. MOVIMENTO2 = 0
			Replace VARIACAO   With 0
		Else
			Replace VARIACAO   With (MOVIMENTO1/MOVIMENTO2)*100
		EndIf

		If nColuna1 # 0
			Replace COLUNA_1 With COLUNA_1 + nColuna1
		Endif

		If nColuna2 # 0
			Replace COLUNA_2 With COLUNA_2 + nColuna2
		Endif

		If bVariacao <> Nil
			Eval(bVariacao)
		Endif

		cEntidSup := &("cArqTmp->"+cCodEntSup)
		If Empty(cEntidSup)
			dbSelectArea("cArqTmp")
			Replace NIVEL1 With .T.
			dbSelectArea(cIdent)
			Exit
		EndIf
		dbSelectArea("cArqTmp")
		dbGoto(nRegTmp)
		dbSelectArea(cIdent)
		MsSeek(xFilial()+ cEntidSup)
	EndDo
	dbSelectArea("cArqTmp")
	dbGoto(nRegTmp)
	dbSkip()
EndDo
EndIf
RestArea(aSaveArea)


Return
//-------------------------------------------------------------------
/*{Protheus.doc} CtbSXNatCta
Retorna a natureza da conta

@author Alvaro Camillo Neto

@param cConta	  Conta contabil


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Static Function CtbSXNatCta(cConta)
Local cNatCTa  := ""
DEFAULT cConta := ""

If _oHashCt1 <> Nil
	_oHashCt1:Get(cConta,@cNatCTa)
EndIf

Return cNatCTa


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Program   ≥CtCmpSoEnt≥ Autor ≥Simone Mie Sato        ≥ Data ≥ 14.03.02 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Gerar Arquivo Temporario para Comparativos                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ .T. / .F.                                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpO1 = Objeto oMeter                                      ≥±±
±±≥          ≥ ExpO2 = Objeto oText                                       ≥±±
±±≥          ≥ ExpO3 = Objeto oDlg                                        ≥±±
±±≥          ≥ ExpL1 = lEnd                                               ≥±±
±±≥          ≥ ExpD1 = Data Inicial                                       ≥±±
±±≥          ≥ ExpD2 = Data Final                                         ≥±±
±±≥          ≥ ExpC3 = Da Entidade		                                  ≥±±
±±≥          ≥ ExpC4 = Ate a Entidade                                     ≥±±
±±≥          ≥ ExpC5 = Moeda		                                      ≥±±
±±≥          ≥ ExpC6 = Saldo	                                          ≥±±
±±≥          ≥ ExpA1 = Set Of Book	                                      ≥±±
±±≥          ≥ ExpN1 = Tamanho da descricao             	              ≥±±
±±≥          ≥ ExpC7 = Ate qual segmento sera impresso 	(nivel)		  	  ≥±±
±±≥          ≥ ExpC8 = Filtra por Segmento		                          ≥±±
±±≥          ≥ ExpC9 = Segmento Inicial		                              ≥±±
±±≥          ≥ ExpC10= Segmento Final  		                              ≥±±
±±≥          ≥ ExpC11= Segmento Contido em  	                          ≥±±
±±≥          ≥ ExpL2 = Se imprime sem movimento  	                      ≥±±
±±≥          ≥ ExpC12= Alias do Arquivo          	                      ≥±±
±±≥          ≥ 34-cFilUsu = Filtro informado pelo usuario                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CtCmpSoEnt(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni,cEntidfim,;
					cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					lNImpMov,cAlias,cIdent,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,;
					nInicio,nFinal,lImpAntLP,dDataLP,nDivide,cTpVlr,lFiliais,aFiliais,;
					lMeses,aMeses,cFilUsu)

Local aSaveArea 	:= GetArea()
Local cMascara 		:= ""
Local nPos			:= 0
Local nDigitos		:= 0
Local cEntid			//Codigo da Entidade(Conta,C.Custo,Item ou Classe de valor)
Local cEntidSup			//Codigo da Entidade Superior(Conta,C.Custo,Item ou Classe de valor)
Local cDesc
Local nSaldoDeb 	:= 0
Local nSaldoCrd 	:= 0
Local nSaldoAntD	:= 0
Local nSaldoAntC	:= 0
Local nSaldoAtuD	:= 0
Local nSaldoAtuC	:= 0
Local nCont			:= 0
Local nVezes		:= 0
Local aMovimento	:= {}
Local cCodEnt		:= ""	//Codigo da entidade (conta, c.custo, item ou classe de valor)
Local nTamDesc		:= ""
Local oProcess
Local cDescEnt		:= ""
Local cEntSup		:= ""
Local nTotVezes		:= 0
Local nMeter		:= 0
Local nTotal		:= 0
Local nOrdem		:= 0
Local cChvAux := ""
Local cFilaux := ""
lFiliais			:= Iif(lFiliais == Nil,.F.,lFiliais)
aFiliais			:= Iif(aFiliais==Nil,{},aFiliais)
lMeses				:= Iif(lMeses == NIl, .F.,lMeses)
aMeses				:= Iif(aMeses==Nil,{},aMeses)
cIdent	  			:= Iif(cIdent	== Nil,'',cIdent)
nDivide 			:= Iif(nDivide == Nil,1,nDivide)

If cAlias == "CT7"
	cMascara	:= aSetOfBook[2]
ElseIf cAlias == "CTU"
	If cIdent == "CTT"
		cMascara	:= aSetOfBook[6]
	EndIf
EndIf


If !Empty(cSegmento)

	dbSelectArea("CTM")
	dbSetOrder(1)
	If MsSeek(xFilial()+cMascara)
		While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cMascara
			nPos += Val(CTM->CTM_DIGITO)
			If CTM->CTM_SEGMEN == cSegmento
				nPos -= Val(CTM->CTM_DIGITO)
				nPos ++
				nDigitos := Val(CTM->CTM_DIGITO)
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf
EndIf


If cAlias == 'CT7'//SE FOR BALANCETE POR CONTA

	dbSelectArea("CT1")
	If ValType(oMeter) == "O"
		oMeter:SetTotal(CT1->(RecCount()))
		oMeter:Set(0)
	EndIf
	dbSetOrder(3)

	// Posiciona na primeira conta analitica
	MsSeek(xFilial()+"2"+cEntidIni,.T.)

	While !Eof() .And. CT1->CT1_FILIAL == xFilial() .And.;
			CT1->CT1_CONTA <= cEntidFim .And. CT1_CLASSE != "1"

		nMeter++
		If nMeter%1000 = 0
			If ValType(oMeter) == "O"
    			oMeter:Set(nMeter)
   			EndIf
   		EndIf

		// Grava conta analitica
		cConta 	:= CT1->CT1_CONTA

		// Conta nao pertencera ao arquivo pois sera filtrado pelo Set Of Book
		// Escolhido
		If !Empty(aSetOfBook[1])  .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12])   										// SE HOUVER CODIGO DE CONFIGURA«√O DE LIVROS
			If !(aSetOfBook[1] $ CT1->CT1_BOOK)
				dbSkip()
				Loop
			EndIf
		EndIf

		If !Empty(cSegmento)
			If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
				If  !(Substr(CT1->CT1_CONTA,nPos,nDigitos) $ (cFiltSegm) )
					dbSkip()
					Loop
				EndIf
			Else
				If Substr(CT1->CT1_CONTA,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
					Substr(CT1->CT1_CONTA,nPos,nDigitos) > Alltrim(cSegFim)
					dbSkip()
					Loop
				EndIf
			Endif
		EndIf

      	If ! Empty(cFilUsu)
			If ! &( "CT1->("+cFilUsu+")" )		//	Se nao atende o filtro do usuario
				dbSkip()
				Loop
			EndIf
		EndIf

		cDesc 		:= &("CT1->CT1_DESC"+cMoeda)
		If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
			cDesc 	:= CT1->CT1_DESC01
		Endif
		nTamDesc    := Len(CriaVar("CT1->CT1_DESC"+cMoeda))
		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		If !MsSeek(xFilial()+cConta)
			dbAppend()
			Replace CONTA 		With cConta
			Replace DESCCTA		With cDesc
			Replace TIPOCONTA 	With CT1->CT1_CLASSE
			Replace CTARES    	With CT1->CT1_RES
			Replace NORMAL    	With CT1->CT1_NORMAL
			Replace GRUPO		With CT1->CT1_GRUPO
			Replace ESTOUR 		With CT1->CT1_ESTOUR
		EndIf

		If lFiliais	//Se for Comparativo por Filiais
			nTotVezes := Len(aFiliais)
		EndIf

		If lMeses	//Se for Comparativo por Mes
			nTotVezes := Len(aMeses)
		EndIf

		For nVezes := 1 to nTotVezes
			If lFiliais
				aSaldoAnt := SaldoCT7(cConta,dDataIni,cMoeda,cSaldos,'CTBXFUN',lImpAntLP,dDataLP,aFiliais[nVezes])
				aSaldoAtu := SaldoCT7(cConta,dDataFim,cMoeda,cSaldos,'CTBXFUN',lImpAntLP,dDataLP,aFiliais[nVezes])
			EndIf

			If lMeses
				aSaldoAnt := SaldoCT7(cConta,aMeses[nVezes][2],cMoeda,cSaldos,'CTBXFUN',lImpAntLP,dDataLP)
				aSaldoAtu := SaldoCT7(cConta,aMeses[nVezes][3],cMoeda,cSaldos,'CTBXFUN',lImpAntLP,dDataLP)
			EndIf

			For nCont := 1 To Len(aSaldoAnt)
				aSaldoAnt[nCont] := Round(NoRound((aSaldoAnt[nCont]/nDivide),3),2)
			Next nCont

			For nCont := 1 To Len(aSaldoAtu)
				aSaldoAtu[nCont] := Round(NoRound((aSaldoAtu[nCont]/nDivide),3),2)
			Next nCont

			nSaldoAntD 	:= aSaldoAnt[7]
			nSaldoAntC 	:= aSaldoAnt[8]

   			nSaldoAtuD 	:= aSaldoAtu[4]
			nSaldoAtuC 	:= aSaldoAtu[5]

			nSaldoDeb  := nSaldoAtuD - nSaldoAntD
			nSaldoCrd  := nSaldoAtuC - nSaldoAntC

			dbSelectArea("cArqTmp")
			dbSetOrder(1)
			If cTpVlr == 'M'
				&("COLUNA"+Alltrim(Str(nVezes,2))) := (nSaldoCrd-nSaldoDeb)
				AADD(aMovimento,(nSaldoCrd-nSaldoDeb))
			ElseIf cTpVlr == 'S'
				&("COLUNA"+Alltrim(Str(nVezes,2))) := (nSaldoAtuC-nSaldoAtuD)
				AADD(aMovimento,(nSaldoAtuC-nSaldoAtuD))
			EndIf
			aSaldoAnt	:= {}
			aSaldoAtu	:= {}
		Next

		// Grava contas sinteticas
		dbSelectArea("CT1")
		If ValType(oMeter) == "O"
			oMeter:SetTotal(CT1->(RecCount()))
			oMeter:Set(0)
		EndIf
		dbSetOrder(1)

		nReg := Recno()
		cContaSup := CT1->CT1_CTASUP
		If Empty(cContaSup)
			dbSelectArea("cArqTmp")
			Replace NIVEL1 With .T.
			dbSelectArea("CT1")
		EndIf
		MsSeek(xFilial()+cContaSup)

		While !Eof() .And. CT1->CT1_FILIAL == xFilial()
			nMeter++
			If nMeter%1000 = 0
				If ValType(oMeter) == "O"
			    	oMeter:Set(nMeter)
			  	EndIf
		  	EndIf
			cDesc := &("CT1->CT1_DESC"+cMoeda)
			If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
				cDesc := CT1->CT1_DESC01
			Endif

			dbSelectArea("cArqTmp")
			dbSetOrder(1)
			If !MsSeek(cContaSup)
				dbAppend()
				Replace CONTA		With cContaSup
				Replace DESCCTA		With cDesc
				Replace TIPOCONTA	With CT1->CT1_CLASSE
				Replace CTARES    	With CT1->CT1_RES
				Replace NORMAL   	With CT1->CT1_NORMAL
				Replace GRUPO		With CT1->CT1_GRUPO
				Replace ESTOUR 		With CT1->CT1_ESTOUR
			EndIf

			For nVezes := 1 to nTotVezes
				If cTpVlr == 'M'
					Replace &("COLUNA"+	Alltrim(Str(nVezes,2))) With (&("COLUNA"+Alltrim(Str(nVezes,2)))+aMovimento[nVezes])
				ElseIf cTpVlr == 'S'
					Replace &("COLUNA"+	Alltrim(Str(nVezes,2))) With (&("COLUNA"+Alltrim(Str(nVezes,2)))+aMovimento[nVezes])
				EndIf
   	    	Next

			dbSelectArea("CT1")
			cContaSup := CT1->CT1_CTASUP
			If Empty(CT1->CT1_CTASUP)
				dbSelectArea("cArqTmp")
				Replace NIVEL1 With .T.
				dbSelectArea("CT1")
				Exit
			EndIf
			MsSeek(xFilial()+cContaSup)
		EndDo
		aMovimento	:= {}
		dbSelectArea("CT1")
		dbSetOrder(3)
		dbGoTo(nReg)
		dbSkip()
	EndDo

ElseIf cAlias == "CTU"
	If cIdent	== "CTT"
		nOrdem	:= 2
		cCodigo	:= "CUSTO"
		cEntSup	:= "CCSUP"
	EndIf

	dbSelectArea(cIdent)
 	If ValType(oMeter) == "O"
 		oMeter:SetTotal((cIdent)->(RecCount()))
		oMeter:Set(0)
	EndIf
	dbSetOrder(nOrdem)

	// Posiciona na primeira conta analitica
	MsSeek(xFilial()+"2"+cEntidIni,.T.)

	While !Eof() .And. CTT->CTT_FILIAL == xFilial() .And.;
		&(cIdent + "_" + cCodigo) <= cEntidFim .And. &(cIdent + "_CLASSE" ) <> "1"

		nMeter++
		If nMeter%1000 = 0
			If ValType(oMeter) == "O"
    			oMeter:Set(nMeter)
   			EndIf
   		EndIf

		// Grava conta analitica
		cCodEnt 	:= &(cIdent + "_" + cCodigo)

		// Conta nao pertencera ao arquivo pois sera filtrado pelo Set Of Book
		// Escolhido
		If !Empty(aSetOfBook[1])
			If !(aSetOfBook[1] $ (cIdent)->&(cIdent + "_BOOK"))
				dbSkip()
				Loop
			EndIf
		EndIf

		If !Empty(cSegmento)
			If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
				If  !(Substr(cCodEnt,nPos,nDigitos) $ (cFiltSegm) )
					dbSkip()
					Loop
				EndIf
			Else
				If Substr(cCodEnt,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
					Substr(cCodEnt,nPos,nDigitos) > Alltrim(cSegFim)
					dbSkip()
					Loop
				EndIf
			Endif
		EndIf

      	If ! Empty(cFilUsu)
			If ! &( "CTT->("+cFilUsu+")" )		//	Se nao atende o filtro do usuario
				dbSkip()
				Loop
			EndIf
		EndIf


		cDescEnt	:= (cIdent)->&(cIdent+"_DESC"+cMoeda)

		If Empty(cDescEnt)	// Caso nao preencher descricao da moeda selecionada
			cDescEnt	:= (cIdent)->&(cIdent+"_DESC01")
		Endif

		nTamDesc    := Len(CriaVar(cIdent+"_DESC"+cMoeda))

		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		cChvAux := If("FILIAL" $ IndexKey(),xFilial()+cCodEnt, cCodEnt )
		If !MsSeek(cChvAux)
			dbAppend()
			If cIdent	== "CTT"
				Replace CUSTO 		With cCodent
				Replace DESCCC		With cDescEnt
				Replace TIPOCC	 	With CTT->CTT_CLASSE
				Replace CCRES     	With CTT->CTT_RES
			EndIf
		EndIf

		If lFiliais	//Se for Comparativo por Filiais
			nTotVezes := Len(aFiliais)
		EndIf

		If lMeses	//Se for Comparativo por Mes
			nTotVezes := Len(aMeses)
		EndIf

		For nVezes := 1 to nTotVezes
			If lFiliais
				cFilaux := cFilant
				cFilant := aFiliais[nVezes]
				aSaldoAnt := SaldoCTU(cIdent,cCodEnt,dDataIni,cMoeda,cSaldos,,lImpAntLP,dDataLP,xFilial("CTU"))
				aSaldoAtu := SaldoCTU(cIdent,cCodEnt,dDataFim,cMoeda,cSaldos,,lImpAntLP,dDataLP,xFilial("CTU"))
				cFilant := cFilaux
			EndIf

			If lMeses
				aSaldoAnt := SaldoCTU(cIdent,cCodEnt,dDataIni,cMoeda,cSaldos,,lImpAntLP,dDataLP)
				aSaldoAtu := SaldoCTU(cIdent,cCodEnt,dDataFim,cMoeda,cSaldos,,lImpAntLP,dDataLP)
			EndIf

			For nCont := 1 To Len(aSaldoAnt)
				aSaldoAnt[nCont] := Round(NoRound((aSaldoAnt[nCont]/nDivide),3),2)
			Next nCont

			For nCont := 1 To Len(aSaldoAtu)
				aSaldoAtu[nCont] := Round(NoRound((aSaldoAtu[nCont]/nDivide),3),2)
			Next nCont

			nSaldoAntD 	:= aSaldoAnt[7]
			nSaldoAntC 	:= aSaldoAnt[8]

   			nSaldoAtuD 	:= aSaldoAtu[4]
			nSaldoAtuC 	:= aSaldoAtu[5]

			nSaldoDeb  := nSaldoAtuD - nSaldoAntD
			nSaldoCrd  := nSaldoAtuC - nSaldoAntC

			dbSelectArea("cArqTmp")
			dbSetOrder(1)
			If cTpVlr == 'M'
				&("COLUNA"+Alltrim(Str(nVezes,2))) := (nSaldoCrd-nSaldoDeb)
				AADD(aMovimento,(nSaldoCrd-nSaldoDeb))
			ElseIf cTpVlr == 'S'
				&("COLUNA"+Alltrim(Str(nVezes,2))) := (nSaldoAtuC-nSaldoAtuD)
				AADD(aMovimento,(nSaldoAtuC-nSaldoAtuD))
			EndIf
			aSaldoAnt	:= {}
			aSaldoAtu	:= {}
		Next

		// Grava contas sinteticas
		dbSelectArea(cIdent)
		If ValType(oMeter) == "O"
			oMeter:SetTotal((cIdent)->(RecCount()))
			oMeter:Set(0)
		EndIf
		dbSetOrder(1)

		nReg := Recno()

		cCodEntSup	:= (cIdent)->&(cIdent+"_"+cEntSup)

		If Empty(cCodEntSup)
			dbSelectArea("cArqTmp")
			Replace NIVEL1 With .T.
			dbSelectArea(cIdent)
		EndIf
		MsSeek(xFilial()+cCodEntSup)

		While !Eof() .And. (cIdent)->&(cIdent+"_FILIAL")== xFilial()

			nMeter++
			If nMeter%1000 = 0
				If ValType(oMeter) == "O"
		    		oMeter:Set(nMeter)
		   		EndIf
	   		EndIf
			cDescEnt	:= (cIdent)->&(cIdent+"_DESC"+cMoeda)

			If Empty(cDescEnt)	// Caso nao preencher descricao da moeda selecionada
				cDescEnt	:= (cIdent)->&(cIdent+"_DESC01")
			Endif

			dbSelectArea("cArqTmp")
			dbSetOrder(1)
			If !MsSeek(cCodEntSup)
				dbAppend()
				If cIdent	== "CTT"
					Replace CUSTO 		With cCodentSup
					Replace DESCCC		With cDescEnt
					Replace TIPOCC	 	With CTT->CTT_CLASSE
					Replace CCRES     	With CTT->CTT_RES
				EndIf
			EndIf

			For nVezes := 1 to nTotVezes
				If cTpVlr == 'M'
					Replace &("COLUNA"+	Alltrim(Str(nVezes,2))) With (&("COLUNA"+Alltrim(Str(nVezes,2)))+aMovimento[nVezes])
				ElseIf cTpVlr == 'S'
					Replace &("COLUNA"+	Alltrim(Str(nVezes,2))) With (&("COLUNA"+Alltrim(Str(nVezes,2)))+aMovimento[nVezes])
				EndIf
   	    	Next

			dbSelectArea(cIdent)
			cCodEntSup	:= (cIdent)->&(cIdent+"_"+cEntSup)

			If Empty((cIdent)->(cIdent+"_"+cCodEntSup))
				dbSelectArea("cArqTmp")
				Replace NIVEL1 With .T.
				dbSelectArea(cIdent)
				Exit
			EndIf
			MsSeek(xFilial()+cCodEntSup)
		EndDo
		aMovimento	:= {}
		dbSelectArea(cIdent)
		dbSetOrder(nOrdem)
		dbGoTo(nReg)
		dbSkip()
	EndDo

EndIf
RestArea(aSaveArea)

Return
/*{Protheus.doc} SldAntCT7
Recupera saldo anterior a data inicial

Redirecionada para a rotina SaldoCQFil

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function SLDANTCT7(cConta,dData,cMoeda,cTpSald,cFilX,lDbSkip1)
Local aRet := {}
Local nAntDeb		:= 0	//Saldo anterior Debito Conta
Local nAntCrd		:= 0	//Saldo anterior Credito Conta

aRet := SaldoCQ("CT1",@cConta,/*cCCusto*/,/*cItem*/,/*cClasse*/,/*cIdent*/,@dData,@cMoeda,@cTpSald,/*cRotina*/,/*lImpAntLP*/,/*dDataLP*/,@cFilX,.F.)

nAntDeb		:= aRet[7]	//Saldo anterior Debito Conta
nAntCrd		:= aRet[8]	//Saldo anterior Credito Conta

Return{nAntDeb,nAntCrd}

//-------------------------------------------------------------------
/*{Protheus.doc} SldAntCT3
Recupera saldo anterior a data inicial

Redirecionada para a rotina SaldoCQFil

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function SLDANTCT3(cConta,cCusto,dData,cMoeda,cTpSald,cFilX,lDbSkip1)

Local aRet := {}
Local nAntDeb		:= 0	//Saldo anterior Debito Conta
Local nAntCrd		:= 0	//Saldo anterior Credito Conta

aRet := SaldoCQ("CTT",@cConta,@cCusto,/*cItem*/,/*cClasse*/,/*cIdent*/,@dData,@cMoeda,@cTpSald,/*cRotina*/,/*lImpAntLP*/,/*dDataLP*/,@cFilX,.F.)

nAntDeb		:= aRet[7]	//Saldo anterior Debito Conta
nAntCrd		:= aRet[8]	//Saldo anterior Credito Conta


Return{nAntDeb,nAntCrd}

//-------------------------------------------------------------------
/*{Protheus.doc} SldAntCT4
Recupera saldo anterior a data inicial

Redirecionada para a rotina SaldoCQFil

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function SLDANTCT4(cConta,cCusto,cItem,dData,cMoeda,cTpSald,cFilx,lDbSkip1)
Local aRet := {}
Local nAntDeb		:= 0	//Saldo anterior Debito Conta
Local nAntCrd		:= 0	//Saldo anterior Credito Conta

aRet := SaldoCQ("CTD",@cConta,@cCusto,@cItem,/*cClasse*/,/*cIdent*/,@dData,@cMoeda,@cTpSald,/*cRotina*/,/*lImpAntLP*/,/*dDataLP*/,@cFilX,.F.)

nAntDeb		:= aRet[7]	//Saldo anterior Debito Conta
nAntCrd		:= aRet[8]	//Saldo anterior Credito Conta

Return{nAntDeb,nAntCrd}

//-------------------------------------------------------------------
/*{Protheus.doc} SldAntCTI
Recupera saldo anterior a data inicial

Redirecionada para a rotina SaldoCQFil

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function SLDANTCTI(cConta,cCusto,cItem,cClasseVlr,dData,cMoeda,cTpSald,cFilx,lDbSkip1)

Local aRet := {}
Local nAntDeb		:= 0	//Saldo anterior Debito Conta
Local nAntCrd		:= 0	//Saldo anterior Credito Conta

aRet := SaldoCQ("CTH",@cConta,@cCusto,@cItem,@cClasseVlr,/*cIdent*/,@dData,@cMoeda,@cTpSald,/*cRotina*/,/*lImpAntLP*/,/*dDataLP*/,@cFilX,.F.)

nAntDeb		:= aRet[7]	//Saldo anterior Debito Conta
nAntCrd		:= aRet[8]	//Saldo anterior Credito Conta


Return{nAntDeb,nAntCrd}
//-------------------------------------------------------------------
/*{Protheus.doc} Ctb050Tot

Retorna totais por lote e por documento

@author Alvaro Camillo Neto

@param  dDataLanc  Data do lanáamento
@param  cLote      Lote Cont†bil
@param  cSubLote   Sub-Lote Cont†bil
@param  cDoc       Numero do Doc



@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function Ctb050Tot(dDataLanc,cLote,cSubLote,cDoc)

Local aTotais := {{0,0,0,0},{0,0,0,0}}
Local aRet    := {}

dbSelectArea("CTC")
dbSetOrder(1)
If MsSeek(xFilial("CTC") + dtos(dDataLanc) + cLote + cSubLote + cDoc)
	aTotais[1] := {CTC->CTC_DIG,CTC->CTC_DEBITO,CTC->CTC_CREDIT,CTC->CTC_INF}
Else
	aTotais[1] := {0,0,0,0}
EndIf

aRet := CtbSaldoLote(@cLote,@cSubLote,@dDataLanc)

aTotais[2] := {aRet[4],aRet[1],aRet[2],aRet[3]}

Return aTotais


//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCT7Fil
Saldo do Plano de Contas por filial

Redirecionada para a rotina SaldoCQFil

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function SaldoCT7Fil(cConta,dData,cMoeda,cTpSald,cRotina,lImpAntLP,dDataLP,aSelFil,cArqCt7,lTodasFil)
Local aRet := {}

aRet := SaldoCQFil("CT1",@cConta,/*cCCusto*/,/*cItem*/,/*cClasse*/,/*cIdent*/,@dData,@cMoeda,@cTpSald,@cRotina,@lImpAntLP,@dDataLP,@aSelFil,@lTodasFil)

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCT7
Saldo do Plano de Contas

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function SaldoCT7(cConta,dData,cMoeda,cTpSald,cRotina,lImpAntLP,dDataLP,cFilEsp,cArqCt7)
Local aRet := {}

aRet := SaldoCQ("CT1",@cConta,/*cCCusto*/,/*cItem*/,/*cClasse*/,/*cIdent*/,@dData,@cMoeda,@cTpSald,@cRotina,@lImpAntLP,@dDataLP,@cFilEsp)

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCT3Fil
Saldo do Centro de custo por filial

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function SaldoCT3Fil(cConta,cCusto,dData,cMoeda,cTpSald,cRotina,lImpAntLP,dDataLP,aSelFil,lTodasFil)

Local aRet := {}

aRet := SaldoCQFil("CTT",@cConta,@cCusto,/*cItem*/,/*cClasse*/,/*cIdent*/,@dData,@cMoeda,@cTpSald,@cRotina,@lImpAntLP,@dDataLP,@aSelFil,@lTodasFil)


Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCT3
Saldo do Centro de custo

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function SaldoCT3(cConta,cCusto,dData,cMoeda,cTpSald,cRotina,lImpAntLP,dDataLP,cFilEsp)

Local aRet := {}

aRet := SaldoCQ("CTT",@cConta,@cCusto,/*cItem*/,/*cClasse*/,/*cIdent*/,@dData,@cMoeda,@cTpSald,@cRotina,@lImpAntLP,@dDataLP,@cFilEsp)


Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCT4
Saldo do Item Contabil

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------


Function SaldoCT4(cConta,cCusto,cItem,dData,cMoeda,cTpSald,cRotina,lImpAntLP,dDataLP,cFilEsp)

Local aRet := {}

aRet := SaldoCQ("CTD",@cConta,@cCusto,@cItem,/*cClasse*/,/*cIdent*/,@dData,@cMoeda,@cTpSald,@cRotina,@lImpAntLP,@dDataLP,@cFilEsp)


Return aRet


//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCTI
Saldo da Classe de Valor

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function SaldoCTI(cConta,cCusto,cItem,cClasseVlr,dData,cMoeda,cTpSald,cRotina,lImpAntLP,dDataLP,cFilEsp)

Local aRet := {}

aRet := SaldoCQ("CTH",@cConta,@cCusto,@cItem,@cClasseVlr,/*cIdent*/,@dData,@cMoeda,@cTpSald,@cRotina,@lImpAntLP,@dDataLP,@cFilEsp)

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCT6

Saldo de Total do Lote

@author Alvaro Camillo Neto

@param cLote 		Lote Cont·bil
@param cSubLote 	Sub Lote
@param dData 		Data de Lote
@param cMoeda 	Moeda
@param cTpSald 	Tipo de Saldo
@param cFilX 		Filial de busca

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function SaldoCT6(cLote,cSubLote,dData,cMoeda,cTpSald,cFilX)
Local aRet := {}
Local nDebito		:= 0					// Valor Debito na Data
Local nCredito 	:= 0					// Valor Credito na Data
Local nSaldoAtu	:= 0					// Saldo Atual (com sinal)

aRet := CtbSaldoLote(@cLote,@cSubLote,@dData,@cMoeda,@cTpSald,@cFilX)

nDebito	:= aRet[1]
nCredito	:= aRet[2]
nSaldoAtu	:= nCredito - nDebito

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1] Saldo Atual (com sinal)                          ≥
//≥ [2] Debito na Data                                   ≥
//≥ [3] Credito na Data                                  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//      [1]       [2]     [3]
Return {nSaldoAtu,nDebito,nCredito}

//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCTC

Saldo de Total do Documento

@author Alvaro Camillo Neto

@param cLote 		Lote Cont·bil
@param cSubLote 	Sub Lote
@param cDoc 		Documento
@param dData 		Data de Lote
@param cMoeda 	Moeda
@param cTpSald 	Tipo de Saldo
@param cFilX 		Filial de busca

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function SaldoCTC(cLote,cSubLote,cDoc,dData,cMoeda,cTpSald,cFilX)


Local aSaveAnt	:= GetArea()
Local cQuery		:= ""
Local nDebito		:= 0					// Valor Debito na Data
Local nCredito 	:= 0					// Valor Credito na Data
Local nSaldoAtu	:= 0					// Saldo Atual (com sinal)
Local cTab			:= GetNextAlias()

Default cFilX := cFilAnt

cQuery		+= " SELECT " +CRLF
cQuery		+= " 	CTC_FILIAL, " +CRLF
cQuery		+= " 	CTC_LOTE, " +CRLF
cQuery		+= " 	CTC_SBLOTE, " +CRLF
cQuery		+= " 	CTC_DOC, " +CRLF
cQuery		+= " 	CTC_DATA, " +CRLF
cQuery		+= " 	CTC_DEBITO , " +CRLF
cQuery		+= " 	CTC_CREDIT " +CRLF
cQuery		+= " FROM " + RetSqlName("CTC") +CRLF

cQuery		+= " WHERE " +CRLF
cQuery		+= " 	D_E_L_E_T_ 		= '' " +CRLF
cQuery		+= " 	AND CTC_FILIAL	= '"+xFilial("CTC",cFilX)+"' " +CRLF
cQuery		+= " 	AND CTC_DATA		= '"+DTOS(dData)+"' " +CRLF
cQuery		+= " 	AND CTC_LOTE		= '"+cLote+"' " +CRLF
cQuery		+= " 	AND CTC_SBLOTE	= '"+cSubLote+"' " +CRLF
cQuery		+= " 	AND CTC_DOC		= '"+cDoc+"' " +CRLF
cQuery		+= " 	AND CTC_MOEDA		= '"+cMoeda+"' " +CRLF
cQuery		+= " 	AND CTC_TPSALD	= '"+cTpSald+"' " +CRLF

cQuery := ChangeQuery(cQuery)

If Select(cTab) > 0
	dbSelectArea(cTab)
	(cTab)->( dbCloseArea() )
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.F.)

If (cTab)->(!EOF())
	nDebito	:= (cTab)->CTC_DEBITO
	nCredito	:= (cTab)->CTC_CREDIT
	nSaldoAtu	:= nCredito - nDebito
EndIf

dbSelectArea(cTab)
(cTab)->( dbCloseArea() )


RestArea(aSaveAnt)
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1] Saldo Atual (com sinal)                          ≥
//≥ [2] Debito na Data                                   ≥
//≥ [3] Credito na Data                                  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//      [1]       [2]     [3]
Return {nSaldoAtu,nDebito,nCredito}


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥CtbPlGeren ≥ Autor ≥ Pilar S Albaladejo    ≥ Data ≥ 15.12.99 		     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Retorna Array com o set of book                             			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥CTBPlGeren(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook) ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Nenhum                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                  			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpO1 = Objeto oMeter                     	                 		 ≥±±
±±≥          ≥ ExpO2 = Objeto oText                      	                 		 ≥±±
±±≥          ≥ ExpO3 = Objeto oDlg                       	                 		 ≥±±
±±≥          ≥ ExpL1 = Acao do CodeBlock                 	                 		 ≥±±
±±≥          ≥ ExpD1 = Data Inicial                      	                 		 ≥±±
±±≥          ≥ ExpD2 = Data Final                        	                 		 ≥±±
±±≥          ≥ ExpC1 = Moeda                              	                 		 ≥±±
±±≥          ≥ ExpA1 = Array Set Of Book                  	                 		 ≥±±
±±≥          ≥ lPlGerSint  = Imprime visao gerencial sintetica? Padrao .F.           ≥±±
±±≥          ≥ lConsSaldo  = Consolida saldo ? Padrao .F.                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista  ≥ Data/Bops/Ver ≥Manutencao Efetuada                         			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Marcelo K ≥26/06/06≥8.11  ≥-Bops 101068: Alteracao do nome da funcao de           ≥±±
±±≥          ≥        ≥      ≥ASCII para MsAscII.                         			 ≥±±
±±≥          ≥        ≥      ≥solicitado pela Tecnologia para             			 ≥±±
±±≥          ≥        ≥      ≥compatibilizar o Kernel do Protheus   			 	 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

Function CtbPlGeren( oMeter,;     // 01
                     oText,;      // 02
                     oDlg,;       // 03
                     lEnd,;       // 04
                     dDataIni,;   // 05
                     dDataFim,;   // 06
                     cMoeda,;     // 07
                     aSetOfBook,; // 08 { 1-Codigo Set, 2-Mascara Conta, 3-Decimais, 4-Picture Valores, 5-Plano Gerencial, 6-Mascara C Custo, 7-Mascara Item, 8-Mascara CLVL} // aSetOfBook := {	CTN->CTN_CODIGO,CTN->CTN_MASC1,CTN->CTN_DECIM,CTN->CTN_PICTV,CTN->CTN_PLAGER,CTN->CTN_MASC2,CTN->CTN_MASC3,CTN->CTN_MASC4,1,AllTrim(CTN_DESC)}
                     cAlias,;     // 09
                     cIdent,;     // 10
                     lImpAntLP,;  // 11
                     dDataLP,;    // 12
                     lVlrZerado,; // 13
                     cEntFil1,;   // 14
                     cEntFil2,;   // 15
                     aGeren,;     // 16
                     lImpSint,;   // 17
                     lRecDesp0,;  // 18
                     cRecDesp,;   // 19
                     dDtZeraRD,;  // 20
                     lMovPeriodo,;// 21
                     cSaldos,;    // 22
                     lPlGerSint,; // 23
                     lConsSaldo,; // 24
                     cCTAlias,;   // 25
                     lUsaNmVis,;  // 26
                     cNomeVis,;   // 27
                     aSelfil,;    // 28
                     cQuadroCTB ; // 29
                    )

*/
Function CtbPlGeren(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,;
					cAlias,cIdent,lImpAntLP,dDataLP,lVlrZerado,cEntFil1,cEntFil2,aGeren,lImpSint,;
					lRecDesp0,cRecDesp,dDtZeraRD,lMovPeriodo,cSaldos,lPlGerSint,lConsSaldo,cCTAlias,lUsaNmVis,cNomeVis,aSelfil,cQuadroCTB,lDemDRE , dFinalA)


Local aSaveArea := GetArea()
Local aSaldoAnt
Local aSaldoAtu
Local aSaldoSEM
Local aSaldoPER

Local cConta
Local cCodNor
Local cNormal
Local cContaSup
Local cDesc
Local cPlanGer := aSetOfBook[5]
Local cZZZCT1	:= Repl("Z",Len(Criavar("CT1_CONTA")))
Local cZZZCTT	:= Repl("Z",Len(Criavar("CTT_CUSTO")))
Local cZZZCTD	:= Repl("Z",Len(Criavar("CTD_ITEM")))
Local cZZZCTH	:= Repl("Z",Len(Criavar("CTH_CLVL")))
Local cContaIni	:= Space(Len(Criavar("CT1_CONTA")))
Local cContaFim	:= cZZZCT1
Local cCustoIni	:= Space(Len(Criavar("CTT_CUSTO")))
Local cCustoFim	:= cZZZCTT
Local cItemIni	:= Space(Len(Criavar("CTD_ITEM")))
Local cItemFim	:= cZZZCTD
Local cClvlIni	:= Space(Len(Criavar("CTH_CLVL")))
Local cClVlFim	:= cZZZCTH

Local cCtaFil1
Local cCtaFil2
Local cCCFil1
Local cCCFil2
Local cItemFil1
Local cItemFil2
Local cCLVLFil1
Local cCLVLFil2
Local lConta 	:= .F.
Local lCusto	:= .F.
Local lItem		:= .F.
Local lClasse	:= .F.

Local nReg
Local nFator	 := 1
Local nPos		:= 0
Local nSaldoAnt := 0
Local nSaldoDeb := 0
Local nSaldoCrd := 0

Local nSaldoAtu := 0		// Saldo ate a data final
Local nSaldoSEM := 0		// Saldo ate a variavel dSemestre
Local nSaldoPER := 0		// Saldo ate a variavel dPeriodo0
Local nMOVIMPER	:= 0
Local nMovPerAnt	:= 0	//	Movimento do periodo anterior
Local nIniBalance := 0

Local nSaldoAntD:= 0
Local nSaldoAntC:= 0
Local nSaldoAtuD:= 0
Local nSaldoAtuC:= 0
Local lSemestre := FieldPos("SALDOSEM") > 0		// Saldo por semestre
Local lPeriodo0 := FieldPos("SALDOPER") > 0		// Saldo dois periodos anteriores

Local lComNivel := FieldPos("NIVEL") > 0		// Nivel hierarquico
Local lColuna	:= FieldPos("COLUNA") > 0
Local lContDesc	:= FieldPos("DESCCONT") > 0
Local lImpSal   := FieldPos("IMPSAL") > 0
Local lTpValor	:= FieldPos("TPVALOR") > 0 .And. cPaisLoc $ "BRA|PAD|RUS"
Local lPicture	:= FieldPos("PICTURE") > 0 .And. cPaisLoc $ "BRA|PAD|RUS"
Local nNivel	:= 0
Local nContador	:= 0
Local cFilCTS	:= xFilial("CTS")
Local lMovCusto := CtbMovSaldo("CTT")
Local lMovItem	:= CtbMovSaldo("CTD")
Local lMovClass := CtbMovSaldo("CTH")
Local nA:=1
Local aFator:={}
Local nFatorS:=1
Local aAreaCTS:={}
Local cTpSaldo		:= ""
Local cMoedaDesc 	:= ""
Local cCodVis		:= ""
Local cEntidade		:= ""
Local nAt			:= 0
Local nAt2			:= 0
Local aSaldoAux		:= {}
Local xFator
Local aParamCVQ:= {}
Local cArqQuadro
Local aArqQuadro:= {}
Local xCVQ		:= ""
Local lT			:= .T.
Local aRegCT0
Local nTamEntAd		:= TamSx3("CV0_CODIGO")[1]

Local cZZZEnt05   := Replicate("Z",nTamEntAd)
Local cEntid05Ini := Space(1)
Local cEntid05Fim := Replicate("Z",nTamEntAd)
Local lMovEnt05	  := .F.
Local cEnt05Fil1
Local cEnt05Fil2

Local cZZZEnt06   := Replicate("Z",nTamEntAd)
Local cEntid06Ini := Space(1)
Local cEntid06Fim := Replicate("Z",nTamEntAd)
Local lMovEnt06   := .F.
Local cEnt06Fil1
Local cEnt06Fil2

Local cZZZEnt07   := Replicate("Z",nTamEntAd)
Local cEntid07Ini := Space(1)
Local cEntid07Fim := Replicate("Z",nTamEntAd)
Local lMovEnt07   := .F.
Local cEnt07Fil1
Local cEnt07Fil2

Local cZZZEnt08   := Replicate("Z",nTamEntAd)
Local cEntid08Ini := Space(1)
Local cEntid08Fim := Replicate("Z",nTamEntAd)
Local lMovEnt08   := .F.
Local cEnt08Fil1
Local cEnt08Fil2

Local cZZZEnt09   := Replicate("Z",nTamEntAd)
Local cEntid09Ini := Space(1)
Local cEntid09Fim := Replicate("Z",nTamEntAd)
Local lMovEnt09   := .F.
Local cEnt09Fil1
Local cEnt09Fil2

Local lEnt05	:= .F.
Local lEnt06	:= .F.
Local lEnt07	:= .F.
Local lEnt08	:= .F.
Local lEnt09	:= .F.

Local cCodigoEnt := ""

Local aEntidIni	:= {}
Local aEntidFim	:= {}
Local dDataFinal
Local dDataBegin
Local aEntVazio 	  	:= {}

DEFAULT lConsSaldo:= .F.
DEFAULT lPlGerSint:= .F.
DEFAULT lImpSint	:= .T.
DEFAULT lRecDesp0	:= .F.
DEFAULT cRecDesp 	:= ""
DEFAULT dDtZeraRD	:= CTOD("  /  /  ")
DEFAULT lMovPeriodo := .F.
DEFAULT cCTAlias	:= "cArqTmp"
DEFAULT lUsaNmVis	:= .F.
DEFAULT cSaldos		:= " "
DEFAULT aSelfil		:= {}
DEFAULT cQuadroCTB:= ""
DEFAULT lDemDRE :=.f.
DEFAULT dFinalA := CTOD("  /  /  ")
DEFAULT dDataFinal := dDataBase

If __lCOLUN2 == NIL
	__lCOLUN2 := Iif( CTS->(FieldPos("CTS_COLUN2")) > 0, .T., .F.)
EndiF

If __lPlGeren == NIL
	__lPlGeren := If(ExistBlock("PLGERARQ"), .T., .F. )
Endif

//Disponibilizacao dos parametros da CtbPlGeren() como PARAMIXB para uso nas funÁıes
//chamadas pelas sintaxes SALDO= e ROTINA=
//IMPORTANTE: N„o incluir chamadas de ponto de entrada na CtbPlGeren(), pois a PARAMIXB ser· sobreposta
Private PARAMIXB := {}
Private PARAMIXC := {}
AADD(PARAMIXB,oMeter)
AADD(PARAMIXB,oText)
AADD(PARAMIXB,oDlg)
AADD(PARAMIXB,lEnd)
AADD(PARAMIXB,dDataIni)
AADD(PARAMIXB,dDataFim)
AADD(PARAMIXB,cMoeda)
AADD(PARAMIXB,aSetOfBook)
AADD(PARAMIXB,cAlias)
AADD(PARAMIXB,cIdent)
AADD(PARAMIXB,lImpAntLP)
AADD(PARAMIXB,dDataLP)
AADD(PARAMIXB,lVlrZerado)
AADD(PARAMIXB,cEntFil1)
AADD(PARAMIXB,cEntFil2)
AADD(PARAMIXB,aGeren)
AADD(PARAMIXB,lImpSint)
AADD(PARAMIXB,lRecDesp0)
AADD(PARAMIXB,cRecDesp)
AADD(PARAMIXB,dDtZeraRD)
AADD(PARAMIXB,lMovPeriodo)
AADD(PARAMIXB,cSaldos)
AADD(PARAMIXB,lPlGerSint)
AADD(PARAMIXB,lConsSaldo)
AADD(PARAMIXB,cCTAlias)
AADD(PARAMIXB,lUsaNmVis)
AADD(PARAMIXB,cNomeVis)
AADD(PARAMIXB,aSelfil)
AADD(PARAMIXB,cQuadroCTB)

If nQtdEntid == NIL
	nQtdEntid:= If(FindFunction("CtbQtdEntd"),CtbQtdEntd(),4) //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Novas entidades≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If _lCtbIsCube .And. CtbIsCube()

	//1-CT0->CT0_ALIAS ,2-CT0->CT0_ENTIDA,3-CT0->CT0_ID,4-CT0->CT0_CPOCHV,5-CT0->CT0_CPODSC,6-CT0->CT0_F3ENTI
	aRegCT0 := CtbRegCt0()	// Registros da tabela CT0

	If nQtdEntid >=	5
		cZZZEnt05	:= Repl("Z",Len(Criavar(aRegCT0[5][4])))
		cEntid05Ini	:= Space(Len(Criavar(aRegCT0[5][4])))
		cEntid05Fim	:= cZZZEnt05
		lMovEnt05 	:= CtbMovSaldo("CT0",,'05')
	EndIf

	If nQtdEntid >=	6
		cZZZEnt06	:= Repl("Z",Len(Criavar(aRegCT0[6][4])))
		cEntid06Ini	:= Space(Len(Criavar(aRegCT0[6][4])))
		cEntid06Fim	:= cZZZEnt06
		lMovEnt06 	:= CtbMovSaldo("CT0",,'06')
	EndIf

	If nQtdEntid >=	7
		cZZZEnt07	:= Repl("Z",Len(Criavar(aRegCT0[7][4])))
		cEntid07Ini	:= Space(Len(Criavar(aRegCT0[7][4])))
		cEntid07Fim	:= cZZZEnt07
		lMovEnt07 	:= CtbMovSaldo("CT0",,'07')
	EndIf

	If nQtdEntid >=	8
		cZZZEnt08	:= Repl("Z",Len(Criavar(aRegCT0[8][4])))
		cEntid08Ini	:= Space(Len(Criavar(aRegCT0[8][4])))
		cEntid08Fim	:= cZZZEnt08
		lMovEnt08 	:= CtbMovSaldo("CT0",,'08')
	EndIf

	If nQtdEntid == 9
		cZZZEnt09	:= Repl("Z",Len(Criavar(aRegCT0[9][4])))
		cEntid09Ini	:= Space(Len(Criavar(aRegCT0[9][4])))
		cEntid09Fim	:= cZZZEnt09
		lMovEnt09 	:= CtbMovSaldo("CT0",,'09')
	EndIf

EndIf

dbSelectArea("CVQ")
dbsetorder(1)
xCVQ		:= xfilial("CVQ")

// tratativa para o tipo de saldo maior que 1, consolida saldo
IF !Empty( cSaldos )
	cSaldos := Alltrim( StrTran( cSaldos,";","','") )
Endif

lTRegCts	:= Type("lTRegCts") # "U" .And. ValType(lTRegCts) = "L" .And. lTRegCts
cAlias		:= Iif(cAlias == Nil,"",cAlias)
cIdent		:= Iif(cIdent == Nil,"",cIdent)
lVlrZerado	:= Iif(lVlrZerado == Nil,.T.,lVlrZerado)

If aGeren != Nil
	cCtaFil1  :=	If(MsAscii(aGeren[1])== 13,"",aGeren[1])
	cCtaFil2  :=	If(MsAscii(aGeren[2])== 13,"",aGeren[2])
	cCCFil1   :=	If(MsAscii(aGeren[3])== 13,"",aGeren[3])
	cCCFil2   :=	If(MsAscii(aGeren[4])== 13,"",aGeren[4])
	cItemFil1 :=	If(MsAscii(aGeren[5])== 13,"",aGeren[5])
	cItemFil2 :=	If(MsAscii(aGeren[6])== 13,"",aGeren[6])
	cCLVLFil1 :=	If(MsAscii(aGeren[7])== 13,"",aGeren[7])
	cCLVLFil2 :=	If(MsAscii(aGeren[8])== 13,"",aGeren[8])
EndIf

lCT1Fil 	:= .F.
lCTTFil 	:= .F.
lCTDFil		:= .F.
lCTHFil		:= .F.
lEnt05Fil	:= .F.
lEnt06Fil	:= .F.
lEnt07Fil	:= .F.
lEnt08Fil	:= .F.
lEnt09Fil	:= .F.

// Filtragem da entidade compositora do Plano Gerencial (Centro de Custo da Getdados)
If !Empty(cCtaFil1) .Or. !Empty(cCtaFil2)
	lCT1Fil := .T.
	If cCtaFil1 > cContaIni
		cContaIni := cCtaFil1
	EndIf
	If cCtaFil2 < cContaFim
		cContaFim := cCtaFil2
	EndIf
EndIf

// Filtragem da entidade compositora do Plano Gerencial (Centro de Custo da Getdados)
If lMovCusto
	If !Empty(cCCFil1) .Or. !Empty(cCCFil2)
		lCTTFil := .T.
		If cCCFil1 > cCustoIni
			cCustoIni := cCCFil1
		EndIf
		If cCCFil2 < cCustoFim
			cCustoFim := cCcFil2
		EndIf
	EndIf
EndIf
/* Observacoes:
C.Custo do Plano Gerencial
001	002	003

C.Custo Informado no Filtro
000	001	002	003	004

O relatorio so podera imprimir: 001 002 003	*/

// Filtragem da entidade compositora do Plano Gerencial (Item Contabil da Getdados)
If lMovItem
	If !Empty(cItemFil1) .Or. !Empty(cItemFil2)
		lCTDFil := .T.
		If cItemFil1 > cItemIni
			cItemIni := cItemFil1
		EndIf
		If cItemFil2 < cItemFim
			cItemFim := cItemFil2
		EndIf
	EndIf
EndIf

// Filtragem da entidade compositora do Plano Gerencial (Classe de Valor da Getdados)
If lMovClass
	If !Empty(cCLVLFil1) .Or. !Empty(cCLVLFil2)
		lCTHFil := .T.
		If cCLVLFil1 > cClVlIni
			cClVlIni := cClVlFil1
		EndIf
		If cCLVLFil2 < cClVlFim
			cClVlFim := cClVlFil2
		EndIf
	EndIf
EndIf

// TRATAMENTOS NECESSARIOS PARA FUNCIONAR O "QUADROCTB=" na "formula" ( CTS->CTS_FORMUL ) da visao gerencial .
// NAO ESQUECER DE ADICIONAR O cQuadroCTB COMO PARAMETRO NA CTGERPLN() E COM DEFAULT cQuadroCTB := ""
// TRATAR NO .INI O PARAMETRO QUADRO CONTABIL E PASSA-LO PARA A CTGERPLN()

IF !EMPTY(cQuadroCTB)
	// copia do PARAMIXB
	PARAMIXC := aclone(PARAMIXB)

	aParamCVQ:= {}
	aadd(aParamCVQ , "")         // [01][C] := CÛdigo do Exercicio Cont·bil
	aadd(aParamCVQ , dDataFim )  // [02][D] := Data de referencia
	aadd(aParamCVQ , .T. )       // [03][L] := Demonstra perÌodo anteriord (S/N)  ?
	aadd(aParamCVQ , lImpAntLP ) // [04][L] := Posicao anterior a LP (S/N)
	aadd(aParamCVQ , dDataLP )   // [05][D] := Data de lucros e perdas
	aadd(aParamCVQ , cMoeda )    // [06][C] := Moeda
	aadd(aParamCVQ , cSaldos)    // [07][C] := Tipo de saldo
	aadd(aParamCVQ , lConsSaldo) // [08][L] := Consolidar Saldo (S/N)
	aadd(aParamCVQ , cSaldos )   // [09][C] := Saldos a Consolidar
	aadd(aParamCVQ , dDataIni )  // [10][D] := dDataIni
	aadd(aParamCVQ , dDataFim )  // [11][D] := dDataFin

	CTBGERQDO(cQuadroCTB,aParamCVQ,@cArqQuadro,oMeter,oText,oDlg,aSetOfBook, @lEnd)
	dbSelectArea(cArqQuadro)
	(cArqQuadro)->(dbgotop())
	IF Select("F101Q") > 0
		DbSelectArea("F101Q")
		dbCloseArea()
	Endif

	IF FILE("F101Q.DBF")
		FErase("F101Q.DBF")
	ENDIF

	/* --- O trecho abaixo ser· disponibilizado em ponto de entrada pois n„o ser· possÌvel ter arquivo do tipo .DBF no system pelo Padr„o do sistema. Com o ponto de entrada
		o usu·rio poder· continuar com o arquivo .Dbf ou criar um arquivo com a extens„o que melhor lhe convier.
		COPY TO F101Q.DBF
	*/
	If __lPlGeren
		ExecBlock("PLGERARQ", .F.,.F. )
	endIf
	PARAMIXB := aclone(PARAMIXC)

ENDIF

dbSelectArea("CTS")
If ValType(oMeter) == "O"
	oMeter:nTotal := CTS->(RecCount())
EndIf
dbSetOrder(1)

MsSeek(cFilCTS+cPlanGer,.T.)

If lUsaNmVis
	cNomeVis := CTS->CTS_NOME
EndIf

If cPaisLoc == "RUS"
	dDataFinal:= dDataFim
	dDataBegin:= dDataIni
EndIf

While !Eof() .And. CTS->CTS_FILIAL == cFilCTS .And. CTS->CTS_CODPLA == cPlanGer

	// SOMENTE PODER√O SER IMPRESSAS ENTIDADES SINTETICAS CUJO OS IDENTIFICADORES SEJAM
	// 5- LINHA SEM VALOR
	// 6- LINHA SEM VALOR EM NEGRITO
	// 7- TRACO / SEPARADOR
	// MOTIVO: ESTAS ENTIDADES SINTETICAS NAO SERAO FORMADAS PELAS ROTINA POIS NENHUMA ENTIDADE
	// A UTILIZARA COMO SUPERIOR.
	If cPaisLoc <> "RUS" .And. CTS->CTS_CLASSE == "1" .And. IIf( lPlGerSint , !(CTS->CTS_IDENT $ "567" ) , .T. )
		dbSkip()
		Loop
	EndIf

	// Recarrega vari·veis
	lConta 	:= .F.
	lCusto	:= .F.
	lItem	:= .F.
	lClasse	:= .F.
	lEnt05	:= .F.
	lEnt06	:= .F.
	lEnt07	:= .F.
	lEnt08	:= .F.
	lEnt09	:= .F.

	// Grava conta analitica
	cConta 	:= CTS->CTS_CONTAG
	cDesc	:= CTS->CTS_DESCCG
	cOrdem	:= CTS->CTS_ORDEM

	nSaldoAnt 	:= 0	// Zero as variaveis para acumular
	nSaldoDeb 	:= 0
	nSaldoCrd 	:= 0

	nSaldoAtu 	:= 0
	nSaldoSEM 	:= 0
	nSaldoPer	:= 0

	nSaldoAntD	:= 0
	nSaldoAntC	:= 0
	nSaldoAtuD	:= 0
	nSaldoAtuC	:= 0
	nMOVIMPER	:= 0
	nMovPerAnt	:= 0
	nIniBalance  := 0
	dbSelectArea("CTS")
	dbSetOrder(1)

	While !Eof() .And. CTS->CTS_FILIAL == cFilCTS .And.;
		CTS->CTS_CODPLA == cPlanGer  .And. CTS->CTS_ORDEM	== cOrdem
		aSaldoAnt	:= { 0, 0, 0, 0, 0, 0, 0, 0 }
		aSaldoAtu	:= { 0, 0, 0, 0, 0, 0, 0, 0 }
		aSaldoSEM	:= { 0, 0, 0, 0, 0, 0, 0, 0 }
		aSaldoPER	:= { 0, 0, 0, 0, 0, 0, 0, 0 }
		If cPaisLoc =="RUS"
			aIniBalance	:= { 0, 0, 0, 0, 0, 0, 0, 0 }
		EndIF

		lClasse := .F.
		lItem	:= .F.
		lCusto	:= .F.
		lConta	:= .F.
		/*
		⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		≥ TRATATIVA DE TIPO DE SALDO NOS RELATORIOS DE DEMONSTRA-≥
		≥ TIVOS (CTBR5XX)                                        ≥
		¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		*/
		// Tipo de saldo configurado na vis„o gerencial
		cTpSaldo := Alltrim( CTS->CTS_TPSALD )

		// Caso o Tipo de saldo estiver configurado na vis„o gerencial com asterisco
		// ou a rotina chamadora consolida os tipos de saldos, considero os parametros da tela (SX1)
		If ( cTpSaldo == "*" .And. cSaldos <> "*" ) .OR. lConsSaldo
			cTpSaldo := cSaldos
		ElseIf ( cTpSaldo <> "*" .And. cSaldos <> "*" ) .And.  cTpSaldo <> cSaldos
			nReg := Recno()
			dbSkip()
			Loop
		EndIf

		//Entidade 09
		If !lEnt09Fil .And. nQtdEntid >= 9
			If ( CTS->( FieldPos( "CTS_E09INI" ) ) > 0  .And. !Empty(CTS->CTS_E09INI) ) .Or. ;
				( CTS->( FieldPos( "CTS_E09FIM" ) ) > 0  .And. !Empty(CTS->CTS_E09FIM)	)	// Saldo a partir da entidade 09
				cEntid09Ini	:= CTS->CTS_E09INI
				cEntid09Fim	:= CTS->CTS_E09FIM
				lEnt09 := .T.
			Else
				cEntid09Ini	:= Space(Len(cZZZEnt09))
				cEntid09Fim	:= cZZZEnt09
			EndIf
		Else
			lEnt09 := .T.
		Endif

		//Entidade 08
		If !lEnt08Fil .And. nQtdEntid >= 8
			If ( CTS->( FieldPos( "CTS_E08INI" ) ) > 0  .And. !Empty(CTS->CTS_E08INI) ) .Or. ;
				( CTS->( FieldPos( "CTS_E08FIM" ) ) > 0  .And. !Empty(CTS->CTS_E08FIM)	)	// Saldo a partir da entidade 08
				cEntid08Ini	:= CTS->CTS_E08INI
				cEntid08Fim	:= CTS->CTS_E08FIM
				lEnt08 := .T.
			Else
				cEntid08Ini	:= Space(Len(cZZZEnt08))
				cEntid08Fim	:= cZZZEnt08
			EndIf
		Else
			lEnt08 := .T.
		Endif

		//Entidade 07
		If !lEnt07Fil .And. nQtdEntid >= 7
			If ( CTS->( FieldPos( "CTS_E07INI" ) ) > 0  .And. !Empty(CTS->CTS_E07INI) ) .Or. ;
				( CTS->( FieldPos( "CTS_E07FIM" ) ) > 0  .And. !Empty(CTS->CTS_E07FIM)	)	// Saldo a partir da entidade 07
				cEntid07Ini	:= CTS->CTS_E07INI
				cEntid07Fim	:= CTS->CTS_E07FIM
				lEnt07 := .T.
			Else
				cEntid07Ini	:= Space(Len(cZZZEnt07))
				cEntid07Fim	:= cZZZEnt07
			EndIf
		Else
			lEnt07 := .T.
		Endif

		//Entidade 06
		If !lEnt06Fil .And. nQtdEntid >= 6
			If ( CTS->( FieldPos( "CTS_E06INI" ) ) > 0  .And. !Empty(CTS->CTS_E06INI) ) .Or. ;
				( CTS->( FieldPos( "CTS_E06FIM" ) ) > 0  .And. !Empty(CTS->CTS_E06FIM)	)	// Saldo a partir da entidade 06
				cEntid06Ini	:= CTS->CTS_E06INI
				cEntid06Fim	:= CTS->CTS_E06FIM
				lEnt06 := .T.
			Else
				cEntid06Ini	:= Space(Len(cZZZEnt06))
				cEntid06Fim	:= cZZZEnt06
			EndIf
		Else
			lEnt06 := .T.
		Endif

		//Entidade 05
		If !lEnt05Fil .And. nQtdEntid >= 5
			If ( CTS->( FieldPos( "CTS_E05INI" ) ) > 0  .And. !Empty(CTS->CTS_E05INI) ) .Or. ;
				( CTS->( FieldPos( "CTS_E05FIM" ) ) > 0  .And. !Empty(CTS->CTS_E05FIM)	)	// Saldo a partir da entidade 05
				cEntid05Ini	:= CTS->CTS_E05INI
				cEntid05Fim	:= CTS->CTS_E05FIM
				lEnt05 := .T.
			Else
				cEntid05Ini	:= Space(Len(cZZZEnt05))
				cEntid05Fim	:= cZZZEnt05
			EndIf
		Else
			lEnt05 := .T.
		Endif

		If !lCTHFil
			If !Empty(CTS->CTS_CTHINI) .Or. !Empty(CTS->CTS_CTHFIM)		// Saldo a partir da classe
				cClVlIni	:= CTS->CTS_CTHINI
				cClVlFim	:= CTS->CTS_CTHFIM
				lClasse := .T.
			Else
				cCLVLIni	:= Space(Len(cZZZCTH))
				cCLVLFim	:= cZZZCTH
			EndIf
		Else
			lClasse := .T.
		Endif

		If !lCTDFil
			If !Empty(CTS->CTS_CTDINI) .Or. !Empty(CTS->CTS_CTDFIM)	// Saldo a partir do Item
				cItemIni	:= CTS->CTS_CTDINI
				cItemFim	:= CTS->CTS_CTDFIM
				lItem := .T.
			Else
				cItemIni	:= Space(Len(cZZZCTD))
				cItemFim	:= cZZZCTD
			EndIf
		Else
			lItem	:= .T.
		Endif

		If !lCTTFil
			If !Empty(CTS->CTS_CTTINI) .Or. !Empty(CTS->CTS_CTTFIM)	// Saldo a partir do C.Custo
				cCustoIni	:= CTS->CTS_CTTINI
				cCustoFim	:= CTS->CTS_CTTFIM
				lCusto := .T.
			Else
				cCustoIni	:= Space(Len(cZZZCTT))
				cCustoFim	:= cZZZCTT
			EndIf
		Else
			lCusto	:= .T.
		Endif

		If !lCT1Fil
			If !Empty(CTS->CTS_CT1INI) .Or. !Empty(CTS->CTS_CT1FIM)	// Saldo a partir da Conta
				cContaIni	:= CTS->CTS_CT1INI
				cContaFim	:= CTS->CTS_CT1FIM
				lConta := .T.
			Else
				cContaIni	:= Space(Len(cZZZCT1))
				cContaFim	:= cZZZCT1
			EndIf
		Else
			lConta	:= .T.
		EndIf

		If lEnt09 .and. lMovEnt09

			cCodigoEnt	:= '09'
			aEntidIni	:= {}
			aEntidFim	:= {}

			AADD( aEntidIni	,cContaIni )
			AADD( aEntidIni	,cCustoIni )
			AADD( aEntidIni	,cItemIni )
			AADD( aEntidIni	,cClVlIni )
			AADD( aEntidIni	,cEntid05Ini)
			AADD( aEntidIni	,cEntid06Ini)
			AADD( aEntidIni	,cEntid07Ini)
			AADD( aEntidIni	,cEntid08Ini)
			AADD( aEntidIni	,cEntid09Ini)

			AADD( aEntidFim	,cContaFim )
			AADD( aEntidFim	,cCustoFim)
			AADD( aEntidFim	,cItemFim)
			AADD( aEntidFim	,cClVlFim)
			AADD( aEntidFim	,cEntid05Fim)
			AADD( aEntidFim	,cEntid06Fim)
			AADD( aEntidFim	,cEntid07Fim)
			AADD( aEntidFim	,cEntid08Fim)
			AADD( aEntidFim	,cEntid09Fim)

			aEntVazio := Ctb_Vazio(aEntidIni)

			aSaldoAnt := CtbSldCubo(aEntidIni,aEntidFim,Ctod("//"),dDataIni-1,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			aSaldoAtu := CtbSldCubo(aEntidIni,aEntidFim,dDataIni,dDataFim,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			If lSemestre
				aSaldoSem := CtbSldCubo(aEntidIni,aEntidFim,StoD(Left(DtoS(dSemestre),4)+"0101"),dSemestre,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			Endif
			If lPeriodo0
				aSaldoPer := CtbSldCubo(aEntidIni,aEntidFim,Ctod("//"),dPeriodo0,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			Endif
			If cPaisLoc =="RUS"
				aIniBalance := CtbSldCubo(aEntidIni,aEntidFim,dDataIni,dDataIni-1,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			EndIf

		ElseIf lEnt08 .and. lMovEnt08

			cCodigoEnt	:= '08'
			aEntidIni	:= {}
			aEntidFim	:= {}

			AADD( aEntidIni	,cContaIni )
			AADD( aEntidIni	,cCustoIni )
			AADD( aEntidIni	,cItemIni )
			AADD( aEntidIni	,cClVlIni )
			AADD( aEntidIni	,cEntid05Ini)
			AADD( aEntidIni	,cEntid06Ini)
			AADD( aEntidIni	,cEntid07Ini)
			AADD( aEntidIni	,cEntid08Ini)

			AADD( aEntidFim	,cContaFim )
			AADD( aEntidFim	,cCustoFim)
			AADD( aEntidFim	,cItemFim)
			AADD( aEntidFim	,cClVlFim)
			AADD( aEntidFim	,cEntid05Fim)
			AADD( aEntidFim	,cEntid06Fim)
			AADD( aEntidFim	,cEntid07Fim)
			AADD( aEntidFim	,cEntid08Fim)

			aEntVazio := Ctb_Vazio(aEntidIni)

			aSaldoAnt := CtbSldCubo(aEntidIni,aEntidFim,Ctod("//"),dDataIni-1,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			aSaldoAtu := CtbSldCubo(aEntidIni,aEntidFim,dDataIni,dDataFim,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			If lSemestre
				aSaldoSem := CtbSldCubo(aEntidIni,aEntidFim,StoD(Left(DtoS(dSemestre),4)+"0101"),dSemestre,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			Endif
			If lPeriodo0
				aSaldoPer := CtbSldCubo(aEntidIni,aEntidFim,Ctod("//"),dPeriodo0,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			Endif
			If cPaisLoc =="RUS"
				aIniBalance := CtbSldCubo(aEntidIni,aEntidFim,dDataIni,dDataIni-1,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			EndIf

		ElseIf lEnt07 .and. lMovEnt07

			cCodigoEnt	:= '07'
			aEntidIni	:= {}
			aEntidFim	:= {}

			AADD( aEntidIni	,cContaIni )
			AADD( aEntidIni	,cCustoIni )
			AADD( aEntidIni	,cItemIni )
			AADD( aEntidIni	,cClVlIni )
			AADD( aEntidIni	,cEntid05Ini)
			AADD( aEntidIni	,cEntid06Ini)
			AADD( aEntidIni	,cEntid07Ini)

			AADD( aEntidFim	,cContaFim )
			AADD( aEntidFim	,cCustoFim)
			AADD( aEntidFim	,cItemFim)
			AADD( aEntidFim	,cClVlFim)
			AADD( aEntidFim	,cEntid05Fim)
			AADD( aEntidFim	,cEntid06Fim)
			AADD( aEntidFim	,cEntid07Fim)

			aEntVazio := Ctb_Vazio(aEntidIni)

			aSaldoAnt := CtbSldCubo(aEntidIni,aEntidFim,Ctod("//"),dDataIni-1,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			aSaldoAtu := CtbSldCubo(aEntidIni,aEntidFim,dDataIni,dDataFim,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			If lSemestre
				aSaldoSem := CtbSldCubo(aEntidIni,aEntidFim,StoD(Left(DtoS(dSemestre),4)+"0101"),dSemestre,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			Endif
			If lPeriodo0
				aSaldoPer := CtbSldCubo(aEntidIni,aEntidFim,Ctod("//"),dPeriodo0,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			Endif
			If cPaisLoc =="RUS"
				aIniBalance := CtbSldCubo(aEntidIni,aEntidFim,dDataIni,dDataIni-1,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			EndIf

		ElseIf lEnt06 .and. lMovEnt06

			cCodigoEnt	:= '06'
			aEntidIni	:= {}
			aEntidFim	:= {}

			AADD( aEntidIni	,cContaIni )
			AADD( aEntidIni	,cCustoIni )
			AADD( aEntidIni	,cItemIni )
			AADD( aEntidIni	,cClVlIni )
			AADD( aEntidIni	,cEntid05Ini)
			AADD( aEntidIni	,cEntid06Ini)

			AADD( aEntidFim	,cContaFim )
			AADD( aEntidFim	,cCustoFim)
			AADD( aEntidFim	,cItemFim)
			AADD( aEntidFim	,cClVlFim)
			AADD( aEntidFim	,cEntid05Fim)
			AADD( aEntidFim	,cEntid06Fim)

			aEntVazio := Ctb_Vazio(aEntidIni)

			aSaldoAnt := CtbSldCubo(aEntidIni,aEntidFim,Ctod("//"),dDataIni-1,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			aSaldoAtu := CtbSldCubo(aEntidIni,aEntidFim,dDataIni,dDataFim,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			If lSemestre
				aSaldoSem := CtbSldCubo(aEntidIni,aEntidFim,StoD(Left(DtoS(dSemestre),4)+"0101"),dSemestre,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			Endif
			If lPeriodo0
				aSaldoPer := CtbSldCubo(aEntidIni,aEntidFim,Ctod("//"),dPeriodo0,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			Endif
			If cPaisLoc =="RUS"
				aIniBalance := CtbSldCubo(aEntidIni,aEntidFim,dDataIni,dDataIni-1,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			EndIf

		ElseIf lEnt05 .and. lMovEnt05

			cCodigoEnt	:= '05'
			aEntidIni	:= {}
			aEntidFim	:= {}

			AADD( aEntidIni	,cContaIni )
			AADD( aEntidIni	,cCustoIni )
			AADD( aEntidIni	,cItemIni )
			AADD( aEntidIni	,cClVlIni )
			AADD( aEntidIni	,cEntid05Ini)

			AADD( aEntidFim	,cContaFim )
			AADD( aEntidFim	,cCustoFim)
			AADD( aEntidFim	,cItemFim)
			AADD( aEntidFim	,cClVlFim)
			AADD( aEntidFim	,cEntid05Fim)

			aEntVazio := Ctb_Vazio(aEntidIni)

			aSaldoAnt := CtbSldCubo(aEntidIni,aEntidFim,Ctod("//"),dDataIni-1,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			aSaldoAtu := CtbSldCubo(aEntidIni,aEntidFim,dDataIni,dDataFim,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			If lSemestre
				aSaldoSem := CtbSldCubo(aEntidIni,aEntidFim,StoD(Left(DtoS(dSemestre),4)+"0101"),dSemestre,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			Endif
			If lPeriodo0
				aSaldoPer := CtbSldCubo(aEntidIni,aEntidFim,Ctod("//"),dPeriodo0,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			Endif
			If cPaisLoc =="RUS"
				aIniBalance := CtbSldCubo(aEntidIni,aEntidFim,dDataIni,dDataIni-1,cMoeda,cTpSaldo,aSelFil,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
			EndIf

		ElseIf lClasse .and. lMovClass

			aSaldoAnt := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
			cItemFim,cCustoIni,cCustoFim,cContaIni,;
			cContaFim,dDataIni,cMoeda,cTpSaldo,aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,iif(lDemDRE,dFinalA,dDataLP),,lConsSaldo)

			aSaldoAtu := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
			cItemFim,cCustoIni,cCustoFim,cContaIni,;
			cContaFim,dDataFim,cMoeda,cTpSaldo,aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,iif(lDemDRE,dFinalA,dDataLP),,lConsSaldo)
			If lSemestre
				aSaldoSem := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
				cItemFim,cCustoIni,cCustoFim,cContaIni,;
				cContaFim,dSemestre,cMoeda,cTpSaldo,aSelFil,,,,lImpAntLP,dDataLP,,lConsSaldo)
			Endif
			If lPeriodo0
				aSaldoPer := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
				cItemFim,cCustoIni,cCustoFim,cContaIni,;
				cContaFim,dPeriodo0,cMoeda,cTpSaldo,aSelFil,,,,lImpAntLP,dDataLP,,lConsSaldo)
			Endif
			If cPaisLoc =="RUS"
				aIniBalance := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cContaIni,;
				cContaFim,dDataIni-1,cMoeda,cTpSaldo,aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,iif(lDemDRE,dFinalA,dDataLP),,lConsSaldo)
			EndIf

		ElseIf lItem .and. lMovItem

			aSaldoAnt := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
			cCustoFim,cContaIni,cContaFim,;
			dDataIni,cMoeda,cTpSaldo,aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,iif(lDemDRE,dFinalA,dDataLP),,lConsSaldo)

			aSaldoAtu := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
			cCustoFim,cContaIni,cContaFim,;
			dDataFim,cMoeda,cTpSaldo,aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,iif(lDemDRE,dFinalA,dDataLP),,lConsSaldo)
			If lSemestre
				aSaldoSem := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
				cCustoFim,cContaIni,cContaFim,;
				dSemestre,cMoeda,cTpSaldo,aSelFil,,,,lImpAntLP,dDataLP,,lConsSaldo)
			Endif
			If lPeriodo0
				aSaldoPEr := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
				cCustoFim,cContaIni,cContaFim,;
				dPeriodo0,cMoeda,cTpSaldo,aSelFil,,,,lImpAntLP,dDataLP,,lConsSaldo)
			Endif
			If cPaisLoc =="RUS"
				aIniBalance := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cContaIni,cContaFim,;
					dDataIni-1,cMoeda,cTpSaldo,aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,iif(lDemDRE,dFinalA,dDataLP),,lConsSaldo,,.F.)
			EndIf

		ElseIf lCusto .and. lMovCusto

			aSaldoAnt := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
			cContaFim,dDataIni,cMoeda,cTpSaldo,aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,iif(lDemDRE,dFinalA,dDataLP),,lConsSaldo)
			aSaldoAtu := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
			cContaFim,dDataFim,cMoeda,cTpSaldo,aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,iif(lDemDRE,dFinalA,dDataLP),,lConsSaldo)

			If lSemestre
				aSaldoSem := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
				cContaFim,dSemestre,cMoeda,cTpSaldo,aSelFil,,,,lImpAntLP,dDataLP,,lConsSaldo)
			Endif
			If lPeriodo0
				aSaldoPer := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
				cContaFim,dPeriodo0,cMoeda,cTpSaldo,aSelFil,,,,lImpAntLP,dDataLP,,lConsSaldo)
			Endif

			If cPaisLoc =="RUS"
				aIniBalance := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
				cContaFim,dDataIni-1,cMoeda,cTpSaldo,aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,iif(lDemDRE,dFinalA,dDataLP),,lConsSaldo)
			EndIf
		ElseIf lConta

			aSaldoAnt := SaldTotCT7(cContaIni,cContaFim,dDataIni,cMoeda,cTpSaldo,lImpAntLP,iif(lDemDRE,dFinalA,dDataLP),aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,,lConsSaldo)
			aSaldoAtu := SaldTotCT7(cContaIni,cContaFim,dDataFim,cMoeda,cTpSaldo,lImpAntLP,iif(lDemDRE,dFinalA,dDataLP),aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,,lConsSaldo)
			If lSemestre
				aSaldoSem := SaldTotCT7(cContaIni,cContaFim,dSemestre,cMoeda,cTpSaldo,lImpAntLP,dDataLP,aSelFil,,,,,lConsSaldo)
			Endif
			If lPeriodo0
				aSaldoPer := SaldTotCT7(cContaIni,cContaFim,dPeriodo0,cMoeda,cTpSaldo,lImpAntLP,dDataLP,aSelFil,,,,,lConsSaldo)
			Endif
			If cPaisLoc =="RUS"
				aIniBalance := SaldTotCT7(cContaIni,cContaFim,dDataFim,cMoeda,cTpSaldo,lImpAntLP,iif(lDemDRE,dFinalA,dDataLP),aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,,lConsSaldo)
			EndIf
		EndIf

		If aSetOfBook[9] > 1	// Divisao por fator
			nLSldAnt := Len(aSaldoAnt)
			nLSldAtu := Len(aSaldoAtu)
			nLSldSem := Len(aSaldoSem)
			nLSldPer := Len(aSaldoPer)
			For nPos := 1 To nLSldAnt
				aSaldoAnt[nPos] := Round(NoRound((aSaldoAnt[nPos]/aSetOfBook[9]),3),2)
			Next
			For nPos := 1 To nLSldAtu
				aSaldoAtu[nPos] := Round(NoRound((aSaldoAtu[nPos]/aSetOfBook[9]),3),2)
			Next
			If lSemestre
				For nPos := 1 To nLSldSem
					aSaldoSem[nPos] := Round(NoRound((aSaldoSem[nPos]/aSetOfBook[9]),3),2)
				Next
			Endif
			If lPeriodo0
				For nPos := 1 To nLSldPer
					aSaldoPer[nPos] := Round(NoRound((aSaldoPer[nPos]/aSetOfBook[9]),3),2)
				Next
			Endif
		Endif

		If Left(CTS->CTS_FORMUL, 7) == "ROTINA="
			nLSldAnt := Len(aSaldoAnt)
			nLSldAtu := Len(aSaldoAtu)
			nLSldSem := Len(aSaldoSem)
			nLSldPer := Len(aSaldoPer)
			nFator := &(Subs(CTS->CTS_FORMUL, 8))
			For nPos := 1 To nLSldAnt
				aSaldoAnt[nPos] *= nFator
			Next
			For nPos := 1 To nLSldAtu
				aSaldoAtu[nPos] *= nFator
			Next
			If lSemestre
				For nPos := 1 To nLSldSem
					aSaldoSem[nPos] *= nFator
				Next
			Endif
			If lPeriodo0
				For nPos := 1 To nLSldPer
					aSaldoPer[nPos] *= nFator
				Next
			Endif
		ElseIf Left(CTS->CTS_FORMUL, 6) == "FATOR="
			nLSldAnt := Len(aSaldoAnt)
			nLSldAtu := Len(aSaldoAtu)
			nLSldSem := Len(aSaldoSem)
			nLSldPer := Len(aSaldoPer)
			nFator := &(Subs(CTS->CTS_FORMUL, 7))
			For nPos := 1 To nLSldAnt
				aSaldoAnt[nPos] *= nFator
			Next
			For nPos := 1 To nLSldAtu
				aSaldoAtu[nPos] *= nFator
			Next
			If lSemestre
				For nPos := 1 To nLSldSem
					aSaldoSem[nPos] *= nFator
				Next
			Endif
			If lPeriodo0
				For nPos := 1 To nLSldPer
					aSaldoPer[nPos] *= nFator
				Next
			Endif
		Elseif Left(CTS->CTS_FORMUL,6 ) == "SALDO="
			nLSldAnt := Len(aSaldoAnt)
			nLSldAtu := Len(aSaldoAtu)
			nLSldSem := Len(aSaldoSem)
			nLSldPer := Len(aSaldoPer)

			xFator := &(Subs(CTS->CTS_FORMUL, 7))

			IF ValType(xFator) == "N"

				For nPos := 1 To nLSldAnt
					aSaldoAnt[nPos] := xFator
				Next
				For nPos := 1 To nLSldAtu
					aSaldoAtu[nPos] := xFator
				Next
				If lSemestre
					For nPos := 1 To nLSldSem
						aSaldoSem[nPos] := xFator
					Next
				Endif
				If lPeriodo0
					For nPos := 1 To nLSldPer
						aSaldoPer[nPos] := xFator
					Next
				Endif

			ELSEIF ValType(xFator) == "A" .AND. Len(xFator) >= 8

				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Conte˙do padrao do array de saldos                   ≥
				//≥ [1] Saldo Atual (com sinal)                          ≥
				//≥ [2] Debito na Data                                   ≥
				//≥ [3] Credito na Data                                  ≥
				//≥ [4] Saldo Atual Devedor                              ≥
				//≥ [5] Saldo Atual Credor                               ≥
				//≥ [6] Saldo Anterior (com sinal)                       ≥
				//≥ [7] Saldo Anterior Devedor                           ≥
				//≥ [8] Saldo Anterior Credor                            ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

				For nPos := 1 To nLSldAnt
					aSaldoAnt[nPos] := xFator[nPos]
				Next
				For nPos := 1 To nLSldAtu
					aSaldoAtu[nPos] := xFator[nPos]
				Next
				If lSemestre
					For nPos := 1 To nLSldSem
						aSaldoSem[nPos] := xFator[nPos]
					Next
				Endif
				If lPeriodo0
					For nPos := 1 To nLSldPer
						aSaldoPer[nPos] := xFator[nPos]
					Next
				Endif
			ENDIF


		ElseIf Left(CTS->CTS_FORMUL,6 ) == "VISAO="
			nLSldAnt 	:= Len(aSaldoAnt)
			nLSldAtu 	:= Len(aSaldoAtu)
			nLSldSem 	:= Len(aSaldoSem)
			nLSldPer 	:= Len(aSaldoPer)
			cMoedaDesc 	:= IIf( Empty(mv_par14),mv_par03,mv_par14)
			nAt			:= At( ",", CTS->CTS_FORMUL )
			nAt2		:= At( "=", CTS->CTS_FORMUL )
			IF nAt > 0
				cCodVis		:= AllTrim( substr( CTS->CTS_FORMUL, 7, nAt - nAt2 - 1 ) )
				cEntidade	:= AllTrim( substr( CTS->CTS_FORMUL, nAt + 1 ) )
			ELSE
				cCodVis		:= AllTrim( substr( CTS->CTS_FORMUL,07) )
				cEntidade	:= ""
			ENDIF

			aSaldos  	:= GetSldVis( 	cCodVis, 0, oMeter, oText, oDlg, ;
			lEnd, dDataIni,dDataFim, cSaldos, lVlrZerado, ;
			cMoedaDesc, lMovPeriodo, aSetOfBook, cMoeda, ;
			lImpAntLP, dDataLP, lConsSaldo, cEntidade,aSelFil )

			If Len( aSaldos ) > 0
				For nPos := 1 To nLSldAnt
					aSaldoAnt[nPos] := aSaldos[nPos]
				Next
				For nPos := 1 To nLSldAtu
					aSaldoAtu[nPos] := aSaldos[nPos]
				Next
				If lSemestre
					For nPos := 1 To nLSldSem
						aSaldoSem[nPos] := aSaldos[nPos]
					Next
				Endif
				If lPeriodo0
					For nPos := 1 To nLSldPer
						aSaldoPer[nPos] := aSaldos[nPos]
					Next
				Endif
			EndIf

		ElseIf Left(CTS->CTS_FORMUL, 9) = "ENTIDADE="
			nLSldAnt 	:= Len(aSaldoAnt)
			nLSldAtu 	:= Len(aSaldoAtu)
			nLSldSem 	:= Len(aSaldoSem)
			nLSldPer 	:= Len(aSaldoPer)
			aSaldos	:= GetSldEnt( substr( CTS->CTS_FORMUL, 10 ) /*cEntidade*/,;
			/* cCodVis */,;
			/*cOrdVis*/,;
			0 /*nTpSaldo 0->RETORNA ARRAY*/ ,;
			cCTAlias /*cArqTmp*/;
			)

			If Len( aSaldos ) > 0
				For nPos := 1 To nLSldAnt
					aSaldoAnt[nPos] := aSaldos[nPos]
				Next
				For nPos := 1 To nLSldAtu
					aSaldoAtu[nPos] := aSaldos[nPos]
				Next
				If lSemestre
					For nPos := 1 To nLSldSem
						aSaldoSem[nPos] := aSaldos[nPos]
					Next
				Endif
				If lPeriodo0
					For nPos := 1 To nLSldPer
						aSaldoPer[nPos] := aSaldos[nPos]
					Next
				Endif
			EndIf

		ElseIf Left(CTS->CTS_FORMUL, 11) = "FTENTIDADE="
			nLSldAnt 	:= Len(aSaldoAnt)
			nLSldAtu 	:= Len(aSaldoAtu)
			nLSldSem 	:= Len(aSaldoSem)
			nLSldPer 	:= Len(aSaldoPer)
			nAt			:= At( ",", CTS->CTS_FORMUL )

			IF nAt > 0
				cEntidade	:= AllTrim( substr( CTS->CTS_FORMUL,12,nAt-12) )
				nFator		:= VAL(AllTrim( substr( CTS->CTS_FORMUL, nAt + 1 ) ) )
			ELSE
				cEntidade	:= AllTrim( substr( CTS->CTS_FORMUL,12) )
				nFator		:= 1
			ENDIF

			aSaldos 	:= GetSldEnt( cEntidade, /* cCodVis */, /*cOrdVis*/, 0 /* nTpSaldo 0->RETORNA ARRAY */, cCTAlias /*cArqTmp*/)

			If Len( aSaldos ) > 0
				For nPos := 1 To nLSldAnt
					aSaldoAnt[nPos] := aSaldos[nPos] * nFator
				Next
				For nPos := 1 To nLSldAtu
					aSaldoAtu[nPos] := aSaldos[nPos] * nFator
				Next
				If lSemestre
					For nPos := 1 To nLSldSem
						aSaldoSem[nPos] := aSaldos[nPos]  * nFator
					Next
				Endif
				If lPeriodo0
					For nPos := 1 To nLSldPer
						aSaldoPer[nPos] := aSaldos[nPos]  * nFator
					Next
				Endif
			EndIf

		ElseIf Left(CTS->CTS_FORMUL, 9) = "VARIACAO="

			nLSldAnt 	:= Len(aSaldoAnt)
			nLSldAtu 	:= Len(aSaldoAtu)
			nLSldSem 	:= Len(aSaldoSem)
			nLSldPer 	:= Len(aSaldoPer)
			aSaldos	:= GetSldEnt( substr( CTS->CTS_FORMUL, 10 ) /*cEntidade*/,;
			/* cCodVis */,;
			/*cOrdVis*/,;
			0 /*nTpSaldo 0->RETORNA ARRAY*/ ,;
			cCTAlias /*cArqTmp*/;
			)

			If Len( aSaldos ) > 0
				For nPos := 1 To nLSldAnt
					aSaldoAnt[nPos] := 0.00 // N„o È realizado tratamento de valor de variaÁ„o anterior
				Next
				For nPos := 1 To nLSldAtu
					aSaldoAtu[nPos] := aSaldos[9] // VariaÁ„o
				Next
				If lSemestre
					For nPos := 1 To nLSldSem
						aSaldoSem[nPos] := aSaldos[nPos]
					Next
				Endif
				If lPeriodo0
					For nPos := 1 To nLSldPer
						aSaldoPer[nPos] := aSaldos[nPos]
					Next
				Endif
			EndIf

		ElseIf Left(CTS->CTS_FORMUL, 10) = "MOVIMENTO="
			nLSldAnt 	:= Len(aSaldoAnt)
			nLSldAtu 	:= Len(aSaldoAtu)
			nLSldSem 	:= Len(aSaldoSem)
			nLSldPer 	:= Len(aSaldoPer)
			aSaldoAux 	:= GetSldMov( substr( CTS->CTS_FORMUL, 11 ), dDataIni, dDataFim, cMoeda ,aSelFil )

			aSaldoAnt[6] += aSaldoAux[1] //Saldo Anterior
			aSaldoAtu[1] += aSaldoAux[2] + aSaldoAux[1] //Saldo Atual

			If aSaldoAux[1] >= 0
				aSaldoAnt[8] 	+= aSaldoAux[1] // Saldo credor
			Else
				aSaldoAnt[7] 	+= ABS(aSaldoAux[1])// Saldo devedor
			Endif

			If aSaldoAux[2] >= 0
				aSaldoAtu[5]	+= aSaldoAux[2] // Saldo credor
			Else
				aSaldoAtu[4] 	+= ABS(aSaldoAux[2]) // Saldo devedor
			Endif

			If lSemestre
				For nPos := 1 To nLSldSem
					aSaldoSem[nPos] += aSaldoAux[2]
				Next
			EndIf

			If lPeriodo0
				For nPos := 1 To nLSldPer
					aSaldoPer[nPos] += aSaldoAux[2]
				Next
			EndIf

		ElseIf Left(CTS->CTS_FORMUL, 10) = "QUADROCTB="
			nLSldAnt 	:= Len(aSaldoAnt)
			nLSldAtu 	:= Len(aSaldoAtu)
			nLSldSem 	:= Len(aSaldoSem)
			nLSldPer 	:= Len(aSaldoPer)
			// cItemQdro	:= SUBS(ALLTRIM(substr( CTS->CTS_FORMUL, 11 )) + SPACE(3), 1 , 3)
			cItemQdro	:= alltrim(substr( CTS->CTS_FORMUL, 11 ))
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Conte˙do padrao do array de saldos                   ≥
			//≥ [1] Saldo Atual (com sinal)                          ≥
			//≥ [2] Debito na Data                                   ≥
			//≥ [3] Credito na Data                                  ≥
			//≥ [4] Saldo Atual Devedor                              ≥
			//≥ [5] Saldo Atual Credor                               ≥
			//≥ [6] Saldo Anterior (com sinal)                       ≥
			//≥ [7] Saldo Anterior Devedor                           ≥
			//≥ [8] Saldo Anterior Credor                            ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			aSaldos 	:= {0,0,0,0,0,0,0,0}
			dbSelectArea(cArqQuadro)
			(cArqQuadro)->(dbgotop())
			Do while ! (cArqQuadro)->(eof())
				if ( (cArqQuadro)->FILIAL == xCVQ ) .and. ( cItemQdro $ (cArqQuadro)->DESCRICAO )
					nPos := 0
					DO WHILE .T. .AND. nPos < 1000
						if Reclock((cArqQuadro), .F.)
							aSaldos[1] += (cArqQuadro)->SALDOATU
							aSaldos[6] += (cArqQuadro)->SALDOANT
							(cArqQuadro)->(msunlock())
							exit
						endif
						nPos++
					EndDo
					if nPos >= 1000
						// ERRO!
						__Quit()
					endif
				endif
				(cArqQuadro)->(dbskip())
			Enddo

			If Len( aSaldos ) > 0
				For nPos := 1 To nLSldAnt
					aSaldoAnt[nPos] := aSaldos[nPos]
				Next
				For nPos := 1 To nLSldAtu
					aSaldoAtu[nPos] := aSaldos[nPos]
				Next
				If lSemestre
					For nPos := 1 To nLSldSem
						aSaldoSem[nPos] := aSaldos[nPos]
					Next
				Endif
				If lPeriodo0
					For nPos := 1 To nLSldPer
						aSaldoPer[nPos] := aSaldos[nPos]
					Next
				Endif
			EndIf
			dbSelectArea("CTS")
		Endif

		// Calculos com os Fatores
		If CTS->CTS_IDENT = "1"				// Somo os saldos
			nSaldoAnt 	+= aSaldoAnt[6]		// Saldo Anterior
			nSaldoAtu 	+= aSaldoAtu[1]		// Saldo Atual
			If lSemestre
				nSaldoSem += aSaldoSEM[1]	// Saldo Semestre
			Endif
			If lPeriodo0
				nSaldoPer += aSaldoPER[1]	// Saldo variavel dPeriodo0
			Endif
			// Calculando o Movimento do periodo anterior
			If lMovPeriodo
				nMovPerAnt += ( (aSaldoAnt[8] - aSaldoAnt[7]) - (aSaldoPer[8] - aSaldoPer[7]) )
			EndIf
			If cPaisLoc =="RUS"
				nIniBalance +=aIniBalance[1]
			EndIf
			nSaldoAntD 	+= aSaldoAnt[7]
			nSaldoAntC 	+= aSaldoAnt[8]

			nSaldoAtuD 	+= aSaldoAtu[4]
			nSaldoAtuC 	+= aSaldoAtu[5]

			If Left(CTS->CTS_FORMUL, 10) = "MOVIMENTO="
				nSaldoDeb  	:= nSaldoAtuD
				nSaldoCrd  	:= nSaldoAtuC
			Else
				nSaldoDeb  	:= (nSaldoAtuD - nSaldoAntD)
				nSaldoCrd  	:= (nSaldoAtuC - nSaldoAntC)
			EndIf

		ElseIf CTS->CTS_IDENT = "2"			// Subtraio os saldos
			nSaldoAnt 	-= aSaldoAnt[6]		// Saldo Anterior
			nSaldoAtu 	-= aSaldoAtu[1]		// Saldo Atual
			If lSemestre
				nSaldoSem -= aSaldoSEM[1]	// Saldo Semestre
			Endif
			If lPeriodo0
				nSaldoPer -= aSaldoPER[1]	// Saldo Periodo determinado
			Endif
			// Calculando o Movimento do periodo anterior
			If lMovPeriodo
				nMovPerAnt -= ( (aSaldoAnt[8] - aSaldoAnt[7]) - (aSaldoPer[8] - aSaldoPer[7]) )
			EndIf

			If cPaisLoc =="RUS"
				nIniBalance -=aIniBalance[1]
			EndIf

			nSaldoAntD 	-= aSaldoAnt[7]
			nSaldoAntC 	-= aSaldoAnt[8]

			nSaldoAtuD 	-= aSaldoAtu[4]
			nSaldoAtuC 	-= aSaldoAtu[5]

			If Left(CTS->CTS_FORMUL, 10) = "MOVIMENTO="
				nSaldoDeb  	:= nSaldoAtuD
				nSaldoCrd  	:= nSaldoAtuC
			Else
				nSaldoDeb  	:= (nSaldoAtuD - nSaldoAntD)
				nSaldoCrd  	:= (nSaldoAtuC - nSaldoAntC)
			EndIf

		EndIf

		nMOVIMPER += (aSaldoAnt[5] - aSaldoPer[8]) - (aSaldoAnt[4] - aSaldoPer[7])

		dbSelectArea("CTS")
		dbSetOrder(1)
		nReg := Recno()
		dbSkip()

 		If lTRegCts .And. IIf( __Release .and. __lCOLUN2, CTS->CTS_COLUN2 > "0", GetCTSCol(CTS_COLUNA,'N') > 0 )	// A coluna 0 nao respeita desmembramento
			Exit
		Endif
	EnddO

	dbSelectArea("CTS")
	dbSetOrder(2)
	dbGoTo(nReg)
	cCodNor := CTS->CTS_NORMAL

	If !lVlrZerado .And. (nSaldoCrd-nSaldoDeb = 0 .And. nSaldoAnt == 0 .And. nSaldoAtu == 0) .And. ;
		(nSaldoDeb = 0 .And. nSaldoCRD = 0)
		///DbDelete()			/// RETIRADO DELETE

		dbSelectArea("CTS")
		dbSetOrder(1)
		dbGoTo(nReg)
		dbSkip()
		Loop					/// S” INCLUI NO TMP SE O SALDO N√O ESTIVER ZERADO (NAO PRECISA ATUALIZAR SUPERIORES)
	EndIf

	dbSelectArea(cCTAlias)
	dbSetOrder(1)
	If !MsSeek(cConta)
		dbAppend()
		If cAlias = 'CTU'
			Do Case
				Case cIdent	= 'CTT'
					Replace CUSTO 	With  cConta
					Replace DESCCC	With cDesc
					Replace TIPOCC 	With CTS->CTS_CLASSE
				Case cIdent = 'CTD'
					Replace ITEM 		With cConta
					Replace DESCITEM    With cDesc
					Replace TIPOITEM	With CTS->CTS_CLASSE
				Case cIdent = 'CTH'
					Replace CLVL		With cConta
					Replace DESCCLVL	With cDesc
					Replace TIPOCLVL	With CTS->CTS_CLASSE
			EndCase
		Else
			Replace CONTA 		With cConta
			Replace DESCCTA    	With cDesc
			If !Empty(cCodigoEnt)
				Replace &("CODENT"+cCodigoEnt) With cConta
				Replace &("DESCENT"+cCodigoEnt)    	With cDesc
			EndIF
		EndIf
		Replace SUPERIOR  	With CTS->CTS_CTASUP
		Replace TIPOCONTA 	With CTS->CTS_CLASSE
		Replace NORMAL    	With CTS->CTS_NORMAL
		Replace ORDEM		With CTS->CTS_ORDEM
		Replace IDENTIFI	With CTS->CTS_IDENT
		Replace FILIAL		With xFilial( cCTAlias )
		Replace TOTVIS 		With CTS->CTS_TOTVIS
		Replace VISENT 		With CTS->CTS_VISENT
		Replace SLDENT 		With CTS->CTS_SLDENT
		Replace FATSLD 		With CTS->CTS_FATSLD


		If lColuna
			Replace COLUNA  With IIf( __Release  .and. __lCOLUN2, Val(CTS->CTS_COLUN2), GetCTSCol(CTS->CTS_COLUNA,'N',cCTAlias))
		EndIf

		If lTpValor
			Replace TPVALOR  With CTS->CTS_TPVALO
		EndIf

		If lPicture
			Replace PICTURE  With CTS->CTS_PICTUR
		EndIf

		If lImpSal
			Replace IMPSAL With CTS->CTS_IMPSAL
		EndIf

		If lTRegCts
			CT1->(DbSeek(xFilial("CT1") + CTS->CTS_CT1INI))
			Replace DESCORIG 	With &("CT1->CT1_DESC" + cMoeda),;
			TIPOCONTA 	With CT1->CT1_CLASSE,;
			NORMAL    	With CT1->CT1_NORMAL
		Endif

		If lContDesc
			Replace DESCCONT 	With CTS->CTS_DETHCG
		EndIf

	EndIf

	If cPaisLoc == "RUS"
		// when this register is group It was awlays empty, now i`m forcing this value
		If lContDesc
			Replace DESCCONT 	With CTS->CTS_DETHCG
		EndIf
	EndIf

	If Left(CTS->CTS_FORMUL, 6) = "TEXTO="		// Adiciona texto a descricao
		Replace (cCTAlias)->DESCCTA With 	AllTrim( (cCTAlias)->DESCCTA) + Space(1) +;
		&(Subs(CTS->CTS_FORMUL, 7))
	Elseif Left(CTS->CTS_FORMUL, 9) = "TEXTOVAR="		// Substitui a descricao pelo retornado pela macro-execucao
		Replace (cCTAlias)->DESCCTA With 	&(Subs(CTS->CTS_FORMUL, 10))

	Endif

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Inverte o saldo se assim a entidade estiver configurada ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If cArqTmp->FATSLD == "2"
		nSaldoAnt	*= -1
		nSaldoAtu	*= -1
		nSaldoAtuD	*= -1
		nSaldoAtuC	*= -1
		nSaldoDeb	*= -1
		nSaldoCrd	*= -1
		nMovPerAnt	*= -1
	EndIf

	dbSelectArea(cCTAlias)
	Replace	SALDOANT With SALDOANT+nSaldoAnt			// Saldo Anterior
	Replace SALDOATU With SALDOATU+nSaldoAtu			// Saldo Atual

	Replace SALDOATUDB With SALDOATUDB+nSaldoAtuD		//Saldo Atual Devedor
	Replace SALDOATUCR With SALDOATUCR+nSaldoAtuC		//Saldo Atual Credor

	If lSemestre
		Replace SALDOSEM With SALDOSEM+nSaldoSEM		// Saldo Semestre
	Endif

	If lPeriodo0	// Saldo periodo determinado
		Replace SALDOPER 	With SALDOPER+nSaldoPER
		Replace MOVIMPER  	With MOVIMPER+nMOVIMPER
	Endif

	If nSaldoDeb < 0 //.And. cCodNor == "1"
		Replace SALDOCRD	With SALDOCRD+nSaldoDeb
	ElseIf nSaldoDeb >= 0 //.And. cCodNor == "1"
		Replace SALDODEB	With SALDODEB+nSaldoDeb
	EndIf

	If nSaldoCrd < 0// .And. cCodNor == "2"
		Replace SALDODEB	With SALDODEB+nSaldoCrd
	ElseIf nSaldoCrd >= 0 //.And. cCodNor == "2"
		Replace SALDOCRD	With SALDOCRD+nSaldoCrd
	EndIf

	Replace MOVIMENTO With MOVIMENTO+(nSaldoCrd-nSaldoDeb)
	If cPaisLoc =="RUS"
		Replace INIBALANCE With INIBALANCE + nIniBalance
	EndIf

	If lMovPeriodo
		Replace MOVPERANT With MOVPERANT+nMovPerAnt
	EndIf
	If lComNivel
		aNivel := {}
		Aadd(aNivel, Recno())
	Endif

	If lImpSint
		dbSelectArea("CTS")
		dbSetOrder(2)
		// Grava contas sinteticas
		If !Empty(CTS->CTS_CTASUP)
			While !Eof() .And. 	CTS->CTS_FILIAL == cFilCTS .And. ;
				CTS->CTS_CODPLA == cPlanGer

				cContaSup 	:= CTS->CTS_CTASUP

				dbSelectArea("CTS")
				dbSetOrder(2)
				If MsSeek(cFilCTS+cPlanGer+cContaSup)
					cDesc 	:= CTS->CTS_DESCCG
					cNormal := CTS->CTS_NORMAL
				Else
					cNormal	:= cCodNor
				EndIf

				dbSelectArea(cCTAlias)
				dbSetOrder(1)
				If !MsSeek(cContaSup)
					dbAppend()
					If cAlias = 'CTU'
						Do Case
							Case cIdent = 'CTT'
								Replace CUSTO 		With cContaSup
								Replace DESCCC		With cDesc
								Replace TIPOCC		With CTS->CTS_CLASSE
							Case cIdent	= 'CTD'
								Replace ITEM 		With cContaSup
								Replace DESCITEM	With cDesc
								Replace TIPOITEM	With CTS->CTS_CLASSE
							Case cIdent = 'CTH'
								Replace CLVL 		With cContaSup
								Replace DESCCLVL	With cDesc
								Replace TIPOCLVL	With CTS->CTS_CLASSE
						EndCase
					Else
						Replace CONTA	With cContaSup
						Replace DESCCTA With cDesc
					EndIf
					Replace SUPERIOR  	With CTS->CTS_CTASUP
					Replace TIPOCONTA	With CTS->CTS_CLASSE
					Replace NORMAL   	With CTS->CTS_NORMAL
					Replace ORDEM		With CTS->CTS_ORDEM
					Replace IDENTIFI	With CTS->CTS_IDENT
					Replace FILIAL		With xFilial( cCTAlias )

					Replace TOTVIS 		With CTS->CTS_TOTVIS
					Replace VISENT 		With CTS->CTS_VISENT
					Replace SLDENT 		With CTS->CTS_SLDENT
					Replace FATSLD 		With CTS->CTS_FATSLD

					If lColuna
						Replace COLUNA  With IIf( __Release .and. __lCOLUN2, Val(CTS->CTS_COLUN2), GetCTSCol(CTS->CTS_COLUNA,'N',Alias()))
					EndIf

					If lTpValor
						Replace TPVALOR  With CTS->CTS_TPVALO
					EndIf

					If lPicture
						Replace PICTURE  With CTS->CTS_PICTUR
					EndIf

					If lTRegCts
						CT1->(DbSeek(xFilial("CT1") + CTS->CTS_CT1INI))
						Replace DESCORIG 	With &("CT1->CT1_DESC" + cMoeda),;
						TIPOCONTA 	With CT1->CT1_CLASSE,;
						NORMAL    	With CT1->CT1_NORMAL
					Endif
					aAreaCTS:=CTS->(GetArea())
					While CTS->(!EOF()) .AND. cFilCTS+cPlanGer+cContaSup ==  xFilial("CTS")+CTS->CTS_CODPLA +CTS->CTS_CONTAG

						If Left(CTS->CTS_FORMUL, 7) == "ROTINA="
							nFatorS := &(Subs(CTS->CTS_FORMUL, 8))
							Aadd(aFator,{Recno(),nFatorS," ",.F.,0,.F.})
						ElseIf Left(CTS->CTS_FORMUL, 6) = "TEXTO="		// Adiciona texto a descricao
							Aadd(aFator,{Recno(),1,Alltrim(&(Subs(CTS->CTS_FORMUL, 7))),.F.,0,.F.})
						ElseIf Left(CTS->CTS_FORMUL, 9) = "TEXTOVAR="		// Adiciona texto a descricao
							Aadd(aFator,{Recno(),1,Alltrim(&(Subs(CTS->CTS_FORMUL, 10))),.F.,0,.T. })
						ElseIf Left(CTS->CTS_FORMUL,6 ) == "SALDO="
							nFatorS := &(Subs(CTS->CTS_FORMUL, 7))
							Aadd(aFator,{Recno(),1," ",.T.,nFatorS,.F.})
						EndIf

						CTS->(Dbskip())
					EndDo
					CTS->(RestArea(aAreaCTS))
				EndIf

				Replace	SALDOANT With SALDOANT + nSaldoAnt			// Saldo Anterior
				Replace SALDOATU With SALDOATU + nSaldoAtu			// Saldo Atual

				Replace SALDOATUDB With SALDOATUDB + nSaldoAtuD		//Saldo Atual Devedor
				Replace SALDOATUCR With SALDOATUCR + nSaldoAtuC		//Saldo Atual Credor

				If nSaldoDeb < 0 //.And. cNormal == "1"
					Replace SALDOCRD	With SALDOCRD + nSaldoDeb
				ElseIf nSaldoDeb >= 0 //.And. cNormal == "1"
					Replace SALDODEB	With SALDODEB + nSaldoDeb
				EndIf
				If nSaldoCrd < 0 //.And. cNormal == "2"
					Replace SALDODEB	With SALDODEB + nSaldoCrd
				ElseIf nSaldoCrd >= 0 //.And. cNormal == "2"
					Replace SALDOCRD	With SALDOCRD + nSaldoCrd
				EndIf

				//				Replace MOVIMENTO With nSaldoCrd-nSaldoDeb
				Replace MOVIMENTO With Iif(FwIsInCallStack('CTBR560P') .OR. FwIsInCallStack('CTBR560'),MOVIMENTO+(nSaldoCrd-nSaldoDeb),SALDOCRD-SALDODEB)

				If lSemestre		// Saldo por semestre
					Replace SALDOSEM With SALDOSEM + nSaldoSEM
				Endif
				If lPeriodo0		// Saldo periodo determinado
					Replace SALDOPER With SALDOPER + nSaldoPER
				Endif

				If lMovPeriodo		// Movimento periodo anterior
					Replace MOVPERANT With MOVPERANT + nMovPerAnt
				EndIf
				If lComNivel
					Aadd(aNivel, Recno())
				Endif

				If lContDesc
					Replace DESCCONT With CTS->CTS_DETHCG
				EndIf

				dbSelectArea("CTS")
				If !Eof() .And. Empty(CTS->CTS_CTASUP)
					dbSelectArea(cCTAlias)
					Replace NIVEL1 With .T.
					dbSelectArea("CTS")
					Exit
				EndIf
			EndDo

			If lComNivel
				dbSelectArea(cCTAlias)
				nContador 	:= 1
				For nNivel 	:= Len(aNivel) To 1 Step -1
					DbGoto(aNivel[nNivel])
					If nContador < 99
						Replace NIVEL With nContador ++
					Else
						Replace NIVEL With 99
					EndIf
				Next
			Endif

		EndIf
	Endif

	dbSelectArea("CTS")
	dbSetOrder(1)
	dbGoTo(nReg)
	dbSkip()

EndDo

dbSelectArea(cCTAlias)

If Len(aFator) >0
	For nA:=1 To Len(aFator)
		Dbgoto(aFator[Na][1])
		RecLock( cCTAlias, .f. )
		Replace	SALDOANT 	With SALDOANT * aFator[Na][2]
		Replace SALDOATU 	With SALDOATU * aFator[Na][2]
		Replace SALDOATUDB 	With SALDOATUDB * aFator[Na][2]
		Replace SALDOATUCR 	With SALDOATUCR * aFator[Na][2]
		Replace SALDOCRD	With SALDOCRD * aFator[Na][2]
		Replace SALDODEB	With SALDODEB * aFator[Na][2]
		Replace SALDOCRD	With SALDOCRD * aFator[Na][2]
		Replace MOVIMENTO 	With MOVIMENTO * aFator[Na][2]
		If lSemestre
			Replace SALDOSEM 	With SALDOSEM * aFator[Na][2]
		EndIf
		If lPeriodo0
			Replace SALDOPER 	With SALDOPER * aFator[Na][2]
			Replace MOVPERANT 	With MOVPERANT * aFator[Na][2]
		EndIf
		If aFator[Na][4]
			Replace	SALDOANT 	With aFator[Na][5]
			Replace SALDOATU 	With aFator[Na][5]
			Replace SALDOATUDB 	With aFator[Na][5]
			Replace SALDOATUCR 	With aFator[Na][5]
			Replace SALDOCRD	With aFator[Na][5]
			Replace SALDODEB	With aFator[Na][5]
			Replace SALDOCRD	With aFator[Na][5]
			Replace MOVIMENTO 	With aFator[Na][5]
			If lSemestre
				Replace SALDOSEM 	With aFator[Na][5]
			EndIf
			If lPeriodo0
				Replace SALDOPER 	With aFator[Na][5]
				Replace MOVPERANT 	With aFator[Na][5]
			EndIf
		EndIf

		If aFator[Na][6]
			Replace DESCCTA With 	Alltrim(aFator[Na][3])
		Else
			Replace DESCCTA With 	Alltrim(DESCCTA)+" "+Alltrim(aFator[Na][3])
		EndIf
		MsUnlock()
	Next
EndIf

RestArea(aSaveArea)

Return



//-------------------------------------------------------------------
/*{Protheus.doc} SaldTotCT7
Retorna os saldos do intervalo da conta ate a conta

Redirecionada para a rotina SaldoTotCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function SaldTotCT7(cContaIni,cContaFim,dData,cMoeda,cTpSald,lImpAntLP,dDataLP,aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,cArqCt7,lConsSaldo)
Local aRet := {}

aRet := SaldoTotCQ("CT1",@cContaIni,@cContaFim,/*cCCustoIni*/,/*cCCustoFim*/,/*cItemIni*/,/*cItemFim*/,/*cClasseIni*/,/*cClasseFim*/,@dData,;
@cMoeda,@cTpSald,@lImpAntLP,@dDataLP,@aSelFil,@lRecDesp0,@cRecDesp,@dDtZeraRD)

Return aRet


//-------------------------------------------------------------------
/*{Protheus.doc} SaldTotCT7
Retorna os saldos do intervalo de contas e centro de custo

Redirecionada para a rotina SaldoTotCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function SaldTotCT3(cCusIni,cCusFim,cContaIni,cContaFim,dData,cMoeda,cTpSald,aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,;
                    lImpAntLP,dDataLP,cArqCt3,lConsSaldo,lTodasFil)

Local aRet := {}

aRet := SaldoTotCQ("CTT",@cContaIni,@cContaFim,@cCusIni,@cCusFim,/*cItemIni*/,/*cItemFim*/,/*cClasseIni*/,/*cClasseFim*/,@dData,;
@cMoeda,@cTpSald,@lImpAntLP,@dDataLP,@aSelFil,@lRecDesp0,@cRecDesp,@dDtZeraRD,@lTodasFil)

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} SaldtotCT4
Retorna os saldos do intervalo de conta,item e centro de custo

Redirecionada para a rotina SaldoTotCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function SaldTotCT4(cItemIni,cItemFim,cCusIni,cCusFim,cContaIni,cContaFim,;
				    dData,cMoeda,cTpSald,aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,dDataLP,cArqCt4,lConsSaldo,lTodasFil)

Local aRet := {}

aRet := SaldoTotCQ("CTD",@cContaIni,@cContaFim,@cCusIni,@cCusFim,@cItemIni,@cItemFim,/*cClasseIni*/,/*cClasseFim*/,@dData,;
@cMoeda,@cTpSald,@lImpAntLP,@dDataLP,@aSelFil,@lRecDesp0,@cRecDesp,@dDtZeraRD,@lTodasFil)

Return aRet


//-------------------------------------------------------------------
/*{Protheus.doc} SaldTotCTI
Retorna os saldos do intervalo de conta,item,c.custo e classe de valor

Redirecionada para a rotina SaldoTotCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function SaldTotCTI(cClasseIni,cClasseFim,cItemIni,cItemFim,cCusIni,cCusFim,;
					cContaIni,cContaFim,dData,cMoeda,cTpSald,aSelFil,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,dDataLP,cArqCti,lConsSaldo,lTodasFil)

Local aRet := {}

aRet := SaldoTotCQ("CTH",@cContaIni,@cContaFim,@cCusIni,@cCusFim,@cItemIni,@cItemFim,@cClasseIni,@cClasseFim,@dData,;
@cMoeda,@cTpSald,@lImpAntLP,@dDataLP,@aSelFil,@lRecDesp0,@cRecDesp,@dDtZeraRD,@lTodasFil)

Return aRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥CTB102Exibe≥ Autor ≥ Simone Mie Sato       ≥ Data ≥ 09.02.01≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Efetua calculos dos totalizadores                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥CTB102Exibe(nvalLcto,nValorAnt,cTipo,cTipAnt,nMvSoma)       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥.T. 				                                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ CTBA102/CTBA105                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpN1 = Valor do lancamento                                ≥±±
±±≥          ≥ ExpN2 = Valor anterior do lancamento                       ≥±±
±±≥          ≥ ExpC1 = Tipo do lancamento                                 ≥±±
±±≥          ≥ ExpC2 = Tipo anterior do lancamento                        ≥±±
±±≥          ≥ ExpN3 = Conteudo do parametro MV_SOMA                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CTB102Exibe(nValLcto,nValorAnt,cTipo,cTipoAnt,nMvSoma)

Local aSaveArea := GetArea()

DEFAULT nMvSoma := GetNewPar("MV_SOMA",1)

If nValLcto == nValorAnt .and. cTipo == cTipoAnt
	Return .T.
EndIf

/// Elimina saldos anteriores
If !Empty(cTipoAnt)
	If cTipoAnt $ "13"				// Tipo Anterior tinha DÈbito
		aTotRdPe[1][2] -= nValorAnt
		aTotRdPe[2][2] -= nValorAnt
	EndIf
	If cTipoAnt $ "23"   		// Tipo Anterior tinha CrÈdito
		aTotRdPe[1][3] -= nValorAnt
		aTotRdPe[2][3] -= nValorAnt
	EndIf

	If cTipoAnt == "3"				// Tipo anterior partida dobrada avalia mv_soma para o total do DOC.
		aTotRdPe[1][1] -= (nValorAnt*nMvSoma)
	ElseIf cTipoAnt $ "12"
		aTotRdPe[1][1] -= nValorAnt
	EndIf
EndIf

/// Elimina saldos anteriores
If !Empty(cTipo)
	If cTipo $ "13"					//Tipo Atual tem DÈbito
		aTotRdPe[1][2]	+= nValLcto
		aTotRdPe[2][2]	+= nValLcto
	EndIf
	If cTipo $ "23"				//Tipo Atual tem CrÈdito
		aTotRdPe[1][3] += nValLcto
		aTotRdPe[2][3] += nValLcto
	Endif

	If cTipo == "3"				// Tipo atual partida dobrada avalia mv_soma para o total do DOC.
		aTotRdPe[1][1] += (nValLcto*nMvSoma)
	ElseIf cTipo $ "12"
		aTotRdPe[1][1] += nValLcto
	EndIf
EndIf

// Refresh da tela de rodape
Ct102ImpT()

RestArea(aSaveArea)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥CT102ImpT  ≥ Autor ≥ Simone Mie Sato       ≥ Data ≥ 09.02.01≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Efetua calculos dos totalizadores                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥CT102ImpT                                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Nenhum                                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ CTBA102/CTBA105                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ Nenhum                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function Ct102ImpT()

If Type("oDig") # "U"
	oDig:Refresh()
Endif
If Type("oDeb") # "U"
	oDeb:Refresh()
Endif
If Type("oCred") # "U"
	oCred:Refresh()
EndIf

Return("")


// **************************************
// * FUNCOES A SEREM USADAS TB NAS PLANILHAS
// **************************************

//-------------------------------------------------------------------
/*{Protheus.doc} SaldoConta
Devolve saldos da conta

@param cConta Codigo da Conta
@param cCusto     = Centro de Custo
@param dData      = Data
@param cMoeda     = Moeda
@param cTpSald    = Tipo de Saldo
@param nQualSaldo = Retorno Desejado
@param nImpAntLP  = Se considera valores anteriores ‡ Apuracao de LP, ou seja, desprezando os lancamentos de LP (0-Nao) ou nao (1-Sim)
@param dDataLP    = Data da Apuracao de LP cujos lancamentos serao desconsiderados

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function SaldoConta(cConta,dData,cMoeda,cTpSald,nQualSaldo,nImpAntLP,dDataLP,cSelFil)

Local aSaveArea	:= GetArea()
Local aSaldos	:= {0,0,0,0,0,0,0,0}
Local lImpAntLP
Local aSelFil	 := {}
Local nTamFilial := IIf( lFWCodFil, FWGETTAMFILIAL, 2 )
Local nTamCta		:= TamSX3("CT1_CONTA")[1]
Local lRet		:= .T.

DEFAULT nImpAntLP := 0 // corresponde a .F.
DEFAULT dDataLP   := CTOD("  /  /  ")
DEFAULT cSelFil	  := cFilAnt

If Len( cSelFil ) == nTamFilial
	Aadd( aSelFil , cSelFil )
Else
	If Len( cSelFil ) >= nTamFilial
		aSelFil := StrToArray( cSelFil , ";" )
	Endif

Endif

IF Len( aSelFil ) <= 0
	Help(" ",1,"SALDOCONTA",,STR0041,1,0)//'Filial n„o informada e/ou informada incorretamente!'
	lRet := .F.
Endif

lImpAntLP := ( nImpAntLP == 1 )

cConta		:= Left(AllTrim(cConta) + Space(nTamCta), nTamCta )
cTpSald 	:= Iif(cTpSald==Nil,"1",cTpSald)
nQualSaldo	:= Iif(nQualSaldo==Nil,1,nQualSaldo)

If lRet
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Retorno:                                             ≥
	//≥ [1] Saldo Atual (com sinal)                          ≥
	//≥ [2] Debito na Data                                   ≥
	//≥ [3] Credito na Data                                  ≥
	//≥ [4] Saldo Atual Devedor                              ≥
	//≥ [5] Saldo Atual Credor                               ≥
	//≥ [6] Saldo Anterior (com sinal)                       ≥
	//≥ [7] Saldo Anterior Devedor                           ≥
	//≥ [8] Saldo Anterior Credor                            ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aSaldos := SaldoCt7Fil(cConta,dData,cMoeda,cTpSald,"CTBXFUN",lImpAntLP,dDataLP,aSelFil)
EndIf
RestArea(aSaveArea)

Return aSaldos[nQualSaldo]


//-------------------------------------------------------------------
/*/{Protheus.doc} SaldoCCus
Devolve saldos do Centro de Custo

@param cConta Codigo da Conta
@param cCusto     = Centro de Custo
@param dData      = Data
@param cMoeda     = Moeda
@param cTpSald    = Tipo de Saldo
@param nQualSaldo = Retorno Desejado
@param nImpAntLP  = Se considera valores anteriores ‡ Apuracao de LP, ou seja, desprezando os lancamentos de LP (0-Nao) ou nao (1-Sim)
@param dDataLP    = Data da Apuracao de LP cujos lancamentos serao desconsiderados

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
/*/
//-------------------------------------------------------------------
Function SaldoCCus(cConta,cCusto,dData,cMoeda,cTpSald,nQualSaldo,nImpAntLP,dDataLP)

Local aSaveArea	:= GetArea()
Local aSaldos	:= {0,0,0,0,0,0,0,0}
Local lTodoCT1	:= .F.
Local lTodoCTT	:= .F.
Local lImpAntLP

Local nTamCta		:= TamSX3("CT1_CONTA")[1]
Local nTamCC		:= TamSX3("CTT_CUSTO")[1]
Local nTamCod		:= TamSX3("CQ8_CODIGO")[1]

DEFAULT cConta    := ""
DEFAULT cCusto    := ""
DEFAULT nImpAntLP := 0 // corresponde a .F.
DEFAULT dDataLP   := CTOD("  /  /  ")

lImpAntLP := ( nImpAntLP == 1 )

nQualSaldo	:= If(nQualSaldo = Nil, 1, nQualSaldo)
cTpSald 	:= Iif(cTpSald==Nil,"1",cTpSald)

// Devolve valor somente do Centro de Custo (Soma todas as contas)
If !Empty(cCusto)
	lTodoCT1	:= !Empty(cConta) .and. UPPER(cConta) == Replicate("Z",Len(cConta))
	lTodoCTT	:= !Empty(cCusto) .and. UPPER(cCusto) == Replicate("Z",Len(cCusto))
	If Empty(cConta)
		cCusto	:= PadR(cCusto,nTamCod)
		aSaldos := SaldoCTU("CTT",cCusto,dData,cMoeda,cTpSald,,lImpAntLP,dDataLP)
	ElseIf lTodoCT1 .or. lTodoCTT
		/// Saldo de uma ou todas entidades de acordo com os par‚metros ZZZZ
		If lTodoCT1
			cContaIni := ""
			cContaFim := Replicate("Z",nTamCta)
		Else
			cContaIni	:= PadR(cConta,nTamCta)
			cContaFim	:= cContaIni
		Endif
		If lTodoCTT
			cCustoIni	:= ""
			cCustoFim	:= Replicate("Z",nTamCC)
		Else
			cCustoIni	:= PadR(cCusto,nTamCC)
			cCustoFim	:= cCustoIni
		Endif
		aSaldos := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,cContaFim,dData,cMoeda,cTpSald,,,,,lImpAntLP,dDataLP)
	Else
	// Devolve valor do Centro de Custo + Conta
		cConta	:= PadR(cConta,nTamCta)
		cCusto	:= PadR(cCusto,nTamCC)
		aSaldos := SaldoCT3(cConta,cCusto,dData,cMoeda,cTpSald,,lImpAntLP,dDataLP)
	EndiF
EndIf
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1] Saldo Atual (com sinal)                          ≥
//≥ [2] Debito na Data                                   ≥
//≥ [3] Credito na Data                                  ≥
//≥ [4] Saldo Atual Devedor                              ≥
//≥ [5] Saldo Atual Credor                               ≥
//≥ [6] Saldo Anterior (com sinal)                       ≥
//≥ [7] Saldo Anterior Devedor                           ≥
//≥ [8] Saldo Anterior Credor                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
RestArea(aSaveArea)

Return aSaldos[nQualSaldo]

//-------------------------------------------------------------------
/*/{Protheus.doc} SaldoItem
Devolve saldos do Item cont·bil

@param cConta Codigo da Conta
@param cCusto     = Centro de Custo
@param cItem      = Item
@param dData      = Data
@param cMoeda     = Moeda
@param cTpSald    = Tipo de Saldo
@param nQualSaldo = Retorno Desejado
@param nImpAntLP  = Se considera valores anteriores ‡ Apuracao de LP, ou seja, desprezando os lancamentos de LP (0-Nao) ou nao (1-Sim)
@param dDataLP    = Data da Apuracao de LP cujos lancamentos serao desconsiderados

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
/*/
//-------------------------------------------------------------------
Function SaldoItem(cConta,cCusto,cItem,dData,cMoeda,cTpSald,nQualSaldo,nImpAntLP,dDataLP)

Local aSaveArea	:= GetArea()
Local aSaldos	:= {0,0,0,0,0,0,0,0}
Local lTodoCT1	:= .F.
Local lTodoCTT	:= .F.
Local lTodoCTD	:= .F.
Local lImpAntLP

Local nTamCta		:= TamSX3("CT1_CONTA")[1]
Local nTamCC		:= TamSX3("CTT_CUSTO")[1]
Local nTamItem	:= TamSX3("CTD_ITEM")[1]
Local nTamCod		:= TamSX3("CQ8_CODIGO")[1]

DEFAULT cConta    := ""
DEFAULT cCusto    := ""
DEFAULT cItem     := ""
DEFAULT nImpAntLP := 0 // corresponde a .F.
DEFAULT dDataLP   := CTOD("  /  /  ")

lImpAntLP := ( nImpAntLP == 1 )

cTpSald 	:= Iif(cTpSald==Nil,"1",cTpSald)
nQualSaldo	:= Iif(nQualSaldo==Nil,1,nQualSaldo)

If !Empty(cItem)
	lTodoCT1	:= !Empty(cConta) .and. UPPER(cConta) == Replicate("Z",Len(cConta))
	lTodoCTT	:= !Empty(cCusto) .and. UPPER(cCusto) == Replicate("Z",Len(cCusto))
	lTodoCTD	:= !Empty(cItem) .and. UPPER(cItem) == Replicate("Z",Len(cItem))
	// Saldo do Item (Soma todas as contas e centros de custo)
	If Empty(cConta) .And. Empty(cCusto)
		cItem	:= PadR(cItem,nTamCod)
		aSaldos := SaldoCTU("CTD",cItem,dData,cMoeda,cTpSald,,lImpAntLP,dDataLP)
	// Saldo do Item+Centro de Custo (soma todas as contas)
	ElseIf Empty(cConta) .And. !Empty(cCusto)
		cCusto	:= PadR(cCusto,nTamCC)
		cItem	:= PadR(cItem,nTamItem)
		aSaldos := SldTop2Ent("CTV","CTD",cItem,cCusto,dData,dData,Val(cMoeda),cTpsald,lImpAntLP,dDataLP)

	ElseIf lTodoCT1 .or. lTodoCTT .or. lTodoCTD
		/// Saldo de uma ou todas entidades de acordo com os par‚metros ZZZZ
		If lTodoCT1
			cContaIni := ""
			cContaFim := Replicate("Z",nTamCta)
		Else
			cContaIni	:= PadR(cConta,nTamCta)
			cContaFim	:= cContaIni
		Endif
		If lTodoCTT
			cCustoIni	:= ""
			cCustoFim	:= Replicate("Z",nTamCC)
		Else
			cCustoIni	:= PadR(cCusto,nTamCC)
			cCustoFim	:= cCustoIni
		Endif
		If lTodoCTD
			cItemIni	:= ""
 			cItemFim	:= Replicate("Z",nTamItem)
		Else
			cItemIni	:= PadR(cItem,nTamItem)
			cItemFim	:= cItemIni
		Endif
		aSaldos := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cContaIni,cContaFim,dData,cMoeda,cTpSald,,,,,lImpAntLP,dDataLP)

	ElseIf !Empty(cConta)
		cConta	:= PadR(cConta,nTamCta)
		cCusto	:= PadR(cCusto,nTamCC)
		cItem	:= PadR(cItem,nTamItem)
		aSaldos := SaldoCt4(cConta,cCusto,cItem,dData,cMoeda,cTpSald,,lImpAntLP,dDataLP)
	EndIf
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1] Saldo Atual (com sinal)                          ≥
//≥ [2] Debito na Data                                   ≥
//≥ [3] Credito na Data                                  ≥
//≥ [4] Saldo Atual Devedor                              ≥
//≥ [5] Saldo Atual Credor                               ≥
//≥ [6] Saldo Anterior (com sinal)                       ≥
//≥ [7] Saldo Anterior Devedor                           ≥
//≥ [8] Saldo Anterior Credor                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

RestArea(aSaveArea)

Return aSaldos[nQualSaldo]

//-------------------------------------------------------------------
/*/{Protheus.doc} SaldoClass
Devolve saldos do CTI - Planilha

@param cConta Codigo da Conta
@param cCusto     = Centro de Custo
@param cItem      = Item
@param cClVl      = Classe de Valor
@param dData      = Data
@param cMoeda     = Moeda
@param cTpSald    = Tipo de Saldo
@param nQualSaldo = Retorno Desejado
@param nImpAntLP  = Se considera valores anteriores ‡ Apuracao de LP, ou seja, desprezando os lancamentos de LP (0-Nao) ou nao (1-Sim)
@param dDataLP    = Data da Apuracao de LP cujos lancamentos serao desconsiderados

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
/*/
//-------------------------------------------------------------------
Function SaldoClass(cConta,cCusto,cItem,cCLVL,dData,cMoeda,cTpSald,nQualSaldo,nImpAntLP,dDataLP)

Local aSaveArea	:= GetArea()
Local aSaldos	:= {}
Local lTodoCT1	:= .F.
Local lTodoCTT	:= .F.
Local lTodoCTD	:= .F.
Local lTodoCTH	:= .F.
Local lImpAntLP

Local nTamCta		:= TamSX3("CT1_CONTA")[1]
Local nTamCC		:= TamSX3("CTT_CUSTO")[1]
Local nTamItem	:= TamSX3("CTD_ITEM")[1]
Local nTamClass	:= TamSX3("CTH_CLVL")[1]
Local nTamCod		:= TamSX3("CQ8_CODIGO")[1]

DEFAULT cConta    := ""
DEFAULT cCusto    := ""
DEFAULT cItem     := ""
DEFAULT cCLVL     := ""
DEFAULT nImpAntLP := 0 // corresponde a .F.
DEFAULT dDataLP   := CTOD("  /  /  ")

lImpAntLP := ( nImpAntLP == 1 )

cTpSald 	:= Iif(cTpSald==Nil,"1",cTpSald)
nQualSaldo	:= Iif(nQualSaldo==Nil,1,nQualSaldo)

If !Empty(cClVl)
	lTodoCT1	:= !Empty(cConta) .and. UPPER(cConta) == Replicate("Z",Len(cConta))
	lTodoCTT	:= !Empty(cCusto) .and. UPPER(cCusto) == Replicate("Z",Len(cCusto))
	lTodoCTD	:= !Empty(cItem) .and. UPPER(cItem) == Replicate("Z",Len(cItem))
	lTodoCTH	:= !Empty(cClVl) .and. UPPER(cCLVL) == Replicate("Z",Len(cCLVL))
	// Saldo da Classe de Valor (Soma todas as contas, centros de custo e item)
	If Empty(cConta) .And. Empty(cCusto) .And. Empty(cItem)
		cClVl	:= PadR(cClVl,nTamCod)
		aSaldos := SaldoCTU("CTH",cCLVL,dData,cMoeda,cTpSald,,lImpAntLP,dDataLP)
	// Saldo da Classe de Valor + Item (soma todas as Contas e Centros de Custo)
	ElseIf Empty(cConta) .And. Empty(cCusto) .And. !Empty(cItem)
		cItem	:= PadR(cItem,nTamItem)
		cClVl	:= PadR(cClVl,nTamClass)
		aSaldos := SldTop2Ent("CTX","CTH",cCLVL,cItem,dData,dData,Val(cMoeda),cTpsald,lImpAntLP,dDataLP)

	// Saldo da Classe de Valor + Centro de Custo (soma todas as contas e itens)
	ElseIf Empty(cConta) .And. !Empty(cCusto) .And. Empty(cItem)
		cCusto	:= PadR(cItem,nTamCC)
		cClVl	:= PadR(cClVl,nTamClass)
		aSaldos := SldTop2Ent("CTW","CTH",cCLVL,cCusto,dData,dData,Val(cMoeda),cTpsald,lImpAntLP,dDataLP)

	ElseIf lTodoCT1 .or. lTodoCTT .or. lTodoCTD .or. lTodoCTH
		/// Saldo de uma ou todas entidades de acordo com os par‚metros ZZZZ
		If lTodoCT1
			cContaIni := ""
			cContaFim := Replicate("Z",nTamCta)
		Else
			cContaIni	:= PadR(cConta,nTamCta)
			cContaFim	:= cContaIni
		Endif
		If lTodoCTT
			cCustoIni	:= ""
			cCustoFim	:= Replicate("Z",nTamCC)
		Else
			cCustoIni	:= PadR(cCusto,nTamCC)
			cCustoFim	:= cCustoIni
		Endif
		If lTodoCTD
			cItemIni	:= ""
 			cItemFim	:= Replicate("Z",nTamItem)
		Else
			cItemIni	:= PadR(cItem,nTamItem)
			cItemFim	:= cItemIni
		Endif
		If lTodoCTH
			cClVlIni	:= ""
			cClVlFim	:= Replicate("Z",nTamClass)
		Else
			cClVlIni	:= PadR(cClVl,nTamClass)
			cClVlFim	:= cClVlIni
		Endif
		aSaldos := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cContaIni,cContaFim,dData,;
		                      cMoeda,cTpSald,,,,,lImpAntLP,dDataLP)

	// Saldo da Classe de Valor+Item+Centro de Custo+Conta
	ElseIf !Empty(cConta) .And. !Empty(cCusto) .And. !Empty(cItem)
		cConta	:= PadR(cConta,nTamCta)
		cCusto	:= PadR(cCusto,nTamCC)
		cItem	:= PadR(cItem,nTamItem)
		cClVl	:= PadR(cClVl,nTamClass)
		aSaldos := SaldoCtI(cConta,cCusto,cItem,cCLVL,dData,cMoeda,cTpSald,,lImpAntLP,dDataLP)
	EndIf
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1] Saldo Atual (com sinal)                          ≥
//≥ [2] Debito na Data                                   ≥
//≥ [3] Credito na Data                                  ≥
//≥ [4] Saldo Atual Devedor                              ≥
//≥ [5] Saldo Atual Credor                               ≥
//≥ [6] Saldo Anterior (com sinal)                       ≥
//≥ [7] Saldo Anterior Devedor                           ≥
//≥ [8] Saldo Anterior Credor                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

RestArea(aSaveArea)

Return aSaldos[nQualSaldo]

//-------------------------------------------------------------------
/*/{Protheus.doc} MovConta
Devolve Movimentos do SIGACTB

Redirecionada para a rotina SaldoCQFil

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
/*/
//-------------------------------------------------------------------
Function MovConta(cConta,dDataIni,dDataFim,cMoeda,cTpSald,nQualSaldo,nSint,nImpAntLP,dDataLP,cSelFil)

Local aMovimento:= {}
Local nDebito
Local nCredito

Local cCodigoDe
Local cCodigoAte
Local cCodAtu
Local lSint
Local aSaldos
Local nSldAntDb
Local nSldAntCr
Local nSldAtlDb
Local nSldAtlCr
Local nCont
Local dData
Local lImpAntLP
Local nSaldoFim	:= 0
Local nIx		:= 0
Local aSelFil	:= {}
Local nTamFilial := IIf( lFWCodFil, FWGETTAMFILIAL, 2 )
Local nCorFil	:= 1
Local nSizFil := 1
Local lRet := .T.
Local nRet	:= 0
Local nTamConta := TamSX3("CT1_CONTA")[1]

DEFAULT nSint	  := 0
DEFAULT nImpAntLP := 0 // corresponde a .F.
DEFAULT dDataLP   := CTOD("  /  /  ")
DEFAULT cSelFil	  := cFilAnt

If Len( cSelFil ) == nTamFilial
	Aadd( aSelFil , cSelFil )
Else
	If Len( cSelFil ) >= nTamFilial
		aSelFil := StrToArray( cSelFil , ";" )
		nSizFil := FWSizeFilial()
		For nCorFil := 1 To Len(aSelFil)
			aSelFil[nCorFil] := PADR(aSelFil[nCorFil],nSizFil," ")
		Next nCorFil
	Endif
Endif

IF Len( aSelFil ) <= 0
	Help(" ",1,"MOVCONTA",,STR0042,1,0)//'Filial n„o informada e/ou informada incorretamente!'
	lRet := .F.
Endif

If lRet
	lSint	:= Iif(nSint == 0 ,.F.,.T.)

	lImpAntLP := ( nImpAntLP == 1 )

	cCodigoDe := cConta
	If !lSint
		cConta := Left(AllTrim(cConta) + Space(nTamConta), nTamConta )
	EndIf
	cCodigoAte := cConta

	cTpSald		:= Iif(cTpSald==Nil,"1",cTpSald)
	nQualSaldo	    := Iif(nQualSaldo==Nil,1,nQualSaldo)

	IF ! Empty( xFilial( 'CT2') )
		aSelFil := StrToArray( cSelFil , ";" )

		nSizFil := FWSizeFilial()
		For nCorFil := 1 To Len(aSelFil)
			aSelFil[nCorFil] := PADR(aSelFil[nCorFil],nSizFil," ")
		Next nCorFil
	Else
		Aadd( aSelFil , cFilAnt )
	Endif

	IF Len( aSelFil ) <= 0
		Help(" ",1,"MOVCONTA1",,STR0041,1,0)//'Filial n„o informada e/ou informada incorretamente!'
		lRet := .F.
	Endif

	If lRet

		// Se nao for sintetica, pegar apenas o movimento da conta
		If !lSint
			aSaldoIni 	:= SaldoCT7Fil(cConta,dDataIni,cMoeda,cTpSald,"CTBXFUN",lImpAntLP,dDataLP,aSelFil)
			aSaldoFim	:= SaldoCT7Fil(cConta,dDataFim,cMoeda,cTpSald,"CTBXFUN",lImpAntLP,dDataLP,aSelFil)

			nDebito		:= aSaldoFim[4] - aSaldoIni[7]
			nCredito		:= aSaldoFim[5] - aSaldoIni[8]

			nSaldoFim		:= aSaldoFim[1]
		Else

			// Se for sintetica, pegar o movimento de todas as contas cujo codigo inicie com o mesmo conteudo de cConta
			// Fazer o processo duas vezes, 1∫ para a Data Inicial e depois para a Data Final.
			nSldAntDb := nSldAntCr := 0
			nSldAtlDb := nSldAtlCr := 0
			nSaldoFim := 0

			For nIx := 1 To Len( aSelFil )

				dbSelectArea("CQ1")
				CQ1->(dbSetOrder(2))//CQ1_FILIAL+CQ1_CONTA+CQ1_MOEDA+CQ1_TPSALD+DTOS(CQ1_DATA)+CQ1_LP
				For nCont := 1 to 2
					If nCont = 1
						dData := dDataIni
					Else
						dData := dDataFim
					Endif

					CQ1->(MsSeek( xFilial("CQ1",aSelFil[nIx]) + cCodigoDe, .T.))
					While CQ1->(!Eof()) .And. CQ1->CQ1_FILIAL = xFilial("CQ1",aSelFil[nIx]) .And. CQ1->CQ1_CONTA <= cCodigoAte

						cCodAtu := CQ1->CQ1_CONTA

						While !CQ1->(Eof()) .And. CQ1->CQ1_FILIAL = aSelFil[nIx] .And. CQ1->CQ1_CONTA == cCodAtu .and. CQ1->CQ1_DATA < dData
							CQ1->(dbSkip())
						Enddo

						If CQ1->CQ1_CONTA <> cCodAtu
							CQ1->(dbSkip(-1))
						Endif

						aSaldos := SaldoCt7(CQ1->CQ1_CONTA,dData,cMoeda,cTpSald,"CTBXFUN",lImpAntLP,dDataLP,aSelFil[nIx])

						If nCont == 1
							nSldAntDb += aSaldos[7]
							nSldAntCr += aSaldos[8]
						Else
							nSldAtlDb += aSaldos[4]
							nSldAtlCr += aSaldos[5]

							nSaldoFim += aSaldos[1]
						Endif

						While !CQ1->(Eof()) .And. CQ1->CQ1_FILIAL = aSelFil[nIx] .And. CQ1->CQ1_CONTA == cCodAtu
							CQ1->(dbSkip())
						Enddo
					EndDo
				Next

			Next

			nDebito	 := nSldAtlDb - nSldAntDb
			nCredito    := nSldAtlCr - nSldAntCr
		EndIf
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Retorno:                                           ≥
		//≥ [1] Movimento Devedor 	                           ≥
		//≥ [2] Movimento Credor		                       ≥
		//≥ [3] Movimento do Mes		                       ≥
		//≥ [4] Saldo Final                                	   ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

		aMovimento := {nDebito,nCredito,nCredito-nDebito,nSaldoFim}
	EndIf
EndIf

If !Empty(aMovimento)
	nRet := aMovimento[nQualSaldo]
EndIf


Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MovCusto
Devolve Movimentos do SIGACTB - Centro de Custo

@param cConta 		Codigo da Conta
@param cCusto			Codigo do Centro de Custo
@param dDataIni		Data Inicial
@param dDataFim		Data Final
@param cMoeda			Moeda
@param cTpSald		Tipo de Saldo
@param nQualSaldo		Retorno Desejado

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
/*/
//-------------------------------------------------------------------
Function MovCusto(cConta,cCusto,dDataIni,dDataFim,cMoeda,cTpSald,nQualSaldo)

Local aMovimento  := {0,0,0,0,0,0}
Local aSaldoIni	:= {0,0,0,0,0,0}
Local aSaldoFim	:= {0,0,0,0,0,0}
Local nDebito
Local nCredito
Local lTodoCT1	:= .F.
Local lTodoCTT	:= .F.

Local nTamCta		:= TamSX3("CT1_CONTA")[1]
Local nTamCC		:= TamSX3("CTT_CUSTO")[1]
Local nTamCod		:= TamSX3("CQ8_CODIGO")[1]

DEFAULT cConta 	:= ""
DEFAULT cCusto 	:= ""

cTpSald			:= Iif(cTpSald==Nil,"1",cTpSald)
nQualSaldo			:= Iif(nQualSaldo==Nil,1,nQualSaldo)

// Devolve valor somente do Centro de Custo (Soma todas as contas)
If !Empty(cCusto)
	lTodoCT1	:= !Empty(cConta) .and. UPPER(cConta) == Replicate("Z",Len(cConta))
	lTodoCTT	:= !Empty(cCusto) .and. UPPER(cCusto) == Replicate("Z",Len(cCusto))
	If Empty(cConta)
		cCusto	  := PadR(cCusto,nTamCod)
		aSaldoIni := SaldoCTU("CTT",cCusto,dDataIni,cMoeda,cTpSald)
		aSaldoFim := SaldoCTU("CTT",cCusto,dDataFim,cMoeda,cTpSald)
	ElseIf lTodoCT1 .or. lTodoCTT
		/// Saldo de uma ou todas entidades de acordo com os par‚metros ZZZZ
		If lTodoCT1
			cContaIni := ""
			cContaFim := Replicate("Z",nTamCta)
		Else
			cContaIni	:= PadR(cConta,nTamCta)
			cContaFim	:= cContaIni
		Endif
		If lTodoCTT
			cCustoIni	:= ""
			cCustoFim	:= Replicate("Z",nTamCC)
		Else
			cCustoIni	:= PadR(cCusto,nTamCC)
			cCustoFim	:= cCustoIni
		Endif
		aSaldoIni := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,cContaFim,dDataIni,cMoeda,cTpSald)
		aSaldoFim := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,cContaFim,dDataFim,cMoeda,cTpSald)
	Else
		cConta	  := PadR(cConta,nTamCta)
		cCusto	  := PadR(cCusto,nTamCC)
		// Devolve valor do Centro de Custo + Conta
		aSaldoIni 	:= SaldoCt3(cConta,cCusto,dDataIni,cMoeda,cTpSald)
		aSaldoFim	:= SaldoCT3(cConta,cCusto,dDataFim,cMoeda,cTpSald)
	EndiF

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Retorno:                                          ≥
	//≥ [1] Movimento Devedor 	                           ≥
	//≥ [2] Movimento Credor		                        ≥
	//≥ [3] Movimento do Mes		                        ≥
	//≥ [4] Saldo Final                                	≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	nDebito		:= aSaldoFim[4] - aSaldoIni[7]
	nCredito	    := aSaldoFim[5] - aSaldoIni[8]

	aMovimento 	:= {nDebito,nCredito,nCredito-nDebito,aSaldoFim[1]}

EndIf



Return aMovimento[nQualSaldo]


//-------------------------------------------------------------------
/*/{Protheus.doc} MovItem
Devolve Movimentos do SIGACTB - Item Cont·bil

@param cConta 		Codigo da Conta
@param cCusto			Codigo do Centro de Custo
@param cItem			Codigo do Item
@param dDataIni		Data Inicial
@param dDataFim		Data Final
@param cMoeda			Moeda
@param cTpSald		Tipo de Saldo
@param nQualSaldo		Retorno Desejado

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
/*/
//-------------------------------------------------------------------
Function MovItem(cConta,cCusto,cItem,dDataIni,dDataFim,cMoeda,cTpSald,nQualSaldo)

Local aMovimento  := {0,0,0,0,0,0}
Local aSaldoIni	:= {0,0,0,0,0,0}
Local aSaldoFim	:= {0,0,0,0,0,0}
Local nDebito
Local nCredito
Local lTodoCT1	:= .F.
Local lTodoCTT	:= .F.
Local lTodoCTD	:= .F.

Local nTamCta		:= TamSX3("CT1_CONTA")[1]
Local nTamCC		:= TamSX3("CTT_CUSTO")[1]
Local nTamItem	:= TamSX3("CTD_ITEM")[1]
Local nTamCod		:= TamSX3("CQ8_CODIGO")[1]

DEFAULT cConta := ""
DEFAULT cCusto := ""
DEFAULT cItem  := ""

cTpSald		:= Iif(cTpSald==Nil,"1",cTpSald)
nQualSaldo	:= Iif(nQualSaldo==Nil,1,nQualSaldo)

If !Empty(cItem)
	lTodoCT1	:= !Empty(cConta) .and. UPPER(cConta) == Replicate("Z",Len(cConta))
	lTodoCTT	:= !Empty(cCusto) .and. UPPER(cCusto) == Replicate("Z",Len(cCusto))
	lTodoCTD	:= !Empty(cItem) .and. UPPER(cItem) == Replicate("Z",Len(cItem))
	// Saldo do Item (Soma todas as contas e centros de custo)
	If Empty(cConta) .And. Empty(cCusto)
		cItem		:= PadR(cItem,nTamCod)
		aSaldoIni := SaldoCTU("CTD",cItem,dDataIni,cMoeda,cTpSald)
		aSaldoFim := SaldoCTU("CTD",cItem,dDataFim,cMoeda,cTpSald)
		// Saldo do Item+Centro de Custo (soma todas as contas)
	ElseIf Empty(cConta) .And. !Empty(cCusto)
		cItem		:= PadR(cItem,nTamItem)
		cCusto		:= PadR(cCusto,nTamCC)
		aSaldoIni := SldTop2Ent("CTV","CTD",cItem,cCusto,dDataIni,dDataIni,Val(cMoeda),cTpsald)
		aSaldoFim := SldTop2Ent("CTV","CTD",cItem,cCusto,dDataFim,dDataFim,Val(cMoeda),cTpsald)
	ElseIf lTodoCT1 .or. lTodoCTT .or. lTodoCTD
		/// Saldo de uma ou todas entidades de acordo com os par‚metros ZZZZ
		If lTodoCT1
			cContaIni := ""
			cContaFim := Replicate("Z",nTamCta)
		Else
			cContaIni	:= PadR(cConta,nTamCta)
			cContaFim	:= cContaIni
		Endif
		If lTodoCTT
			cCustoIni	:= ""
			cCustoFim	:= Replicate("Z",nTamCC)
		Else
			cCustoIni	:= PadR(cCusto,nTamCC)
			cCustoFim	:= cCustoIni
		Endif
		If lTodoCTD
			cItemIni	:= ""
			cItemFim	:= Replicate("Z",nTamItem)
		Else
			cItemIni	:= PadR(cItem,nTamItem)
			cItemFim	:= cItemIni
		Endif
		aSaldoIni := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cContaIni,cContaFim,dDataIni,cMoeda,cTpSald)
		aSaldoFim := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cContaIni,cContaFim,dDataFim,cMoeda,cTpSald)
	ElseIf !Empty(cConta)
		cItem		:= PadR(cItem,nTamItem)
		cCusto		:= PadR(cCusto,nTamCC)
		cConta		:= PadR(cConta,nTamCta)
		aSaldoIni 	:= SaldoCt4(cConta,cCusto,cItem,dDataIni,cMoeda,cTpSald)
		aSaldoFim	:= SaldoCT4(cConta,cCusto,cItem,dDataFim,cMoeda,cTpSald)
	EndIf
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Retorno:                                          ≥
	//≥ [1] Movimento Devedor 	                           ≥
	//≥ [2] Movimento Credor		                        ≥
	//≥ [3] Movimento do Mes		                        ≥
	//≥ [4] Saldo Final                                	≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	nDebito		:= aSaldoFim[4] - aSaldoIni[7]
	nCredito	   := aSaldoFim[5] - aSaldoIni[8]

	aMovimento := {nDebito,nCredito,nCredito-nDebito,aSaldoFim[1]}
EndIf



Return aMovimento[nQualSaldo]


//-------------------------------------------------------------------
/*/{Protheus.doc} MovClass
Devolve Movimentos do SIGACTB - Classe de Valor

@param cConta 		Codigo da Conta
@param cCusto			Codigo do Centro de Custo
@param cItem			Codigo do Item
@param dDataIni		Data Inicial
@param dDataFim		Data Final
@param cMoeda			Moeda
@param cTpSald		Tipo de Saldo
@param nQualSaldo		Retorno Desejado

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
/*/
//-------------------------------------------------------------------
Function MovClass(cConta,cCusto,cItem,cCLVL,dDataIni,dDataFim,cMoeda,cTpSald,nQualSaldo)

Local aMovimento:= {0,0,0,0,0,0}
Local nDebito
Local nCredito
Local nTamCta	:= TamSX3("CT1_CONTA")[1]
Local nTamCC	:= TamSX3("CTT_CUSTO")[1]
Local nTamItem	:= TamSX3("CTD_ITEM")[1]
Local nTamClass	:= TamSX3("CTH_CLVL")[1]
Local nTamCod	:= TamSX3("CQ8_CODIGO")[1]
Local aSaldoIni := {0,0,0,0,0,0}
Local aSaldoFim := {0,0,0,0,0,0}
Local lTodoCT1	:= .F.
Local lTodoCTT	:= .F.
Local lTodoCTD	:= .F.
Local lTodoCTH	:= .F.

DEFAULT cConta := ""
DEFAULT cCusto := ""
DEFAULT cItem  := ""
DEFAULT cCLVL  := ""

cTpSald		:= Iif(cTpSald==Nil,"1",cTpSald)
nQualSaldo		:= Iif(nQualSaldo==Nil,1,nQualSaldo)

If !Empty(cClVl)
	lTodoCT1	:= !Empty(cConta) .and. UPPER(cConta) == Replicate("Z",Len(cConta))
	lTodoCTT	:= !Empty(cCusto) .and. UPPER(cCusto) == Replicate("Z",Len(cCusto))
	lTodoCTD	:= !Empty(cItem) .and. UPPER(cItem) == Replicate("Z",Len(cItem))
	lTodoCTH	:= !Empty(cClVl) .and. UPPER(cCLVL) == Replicate("Z",Len(cCLVL))
	// Saldo da Classe de Valor (Soma todas as contas, centros de custo e item)
	If Empty(cConta) .And. Empty(cCusto) .And. Empty(cItem)
		cClVl		:= PadR(cClVl,nTamCod)
		aSaldoIni := SaldoCTU("CTH",cCLVL,dDataIni,cMoeda,cTpSald)
		aSaldoFim := SaldoCTU("CTH",cCLVL,dDataFim,cMoeda,cTpSald)
	// Saldo da Classe de Valor + Item (soma todas as Contas e Centros de Custo)
	ElseIf Empty(cConta) .And. Empty(cCusto) .And. !Empty(cItem)
		cClVl		:= PadR(cClVl,nTamClass)
		cItem		:= PadR(cItem,nTamItem)
		aSaldoIni := SldTop2Ent("CTX","CTH",cCLVL,cItem,dDataIni,dDataIni,Val(cMoeda),cTpsald)
		aSaldoFim := SldTop2Ent("CTX","CTH",cCLVL,cItem,dDataFim,dDataFim,Val(cMoeda),cTpsald)

	// Saldo da Classe de Valor + Centro de Custo (soma todas as contas e itens)
	ElseIf Empty(cConta) .And. !Empty(cCusto) .And. Empty(cItem)
		cClVl		:= PadR(cClVl,nTamClass)
		cCusto		:= PadR(cCusto,nTamCC )
		aSaldoIni := SldTop2Ent("CTW","CTH",cCLVL,cCusto,dDataIni,dDataIni,Val(cMoeda),cTpsald)
		aSaldoFim := SldTop2Ent("CTW","CTH",cCLVL,cCusto,dDataFim,dDataFim,Val(cMoeda),cTpsald)

	ElseIf lTodoCT1 .or. lTodoCTT .or. lTodoCTD .or. lTodoCTH
		/// Saldo de uma ou todas entidades de acordo com os par‚metros ZZZZ
		If lTodoCT1
			cContaIni := Space(nTamCta)
			cContaFim := Replicate("Z",nTamCta)
		Else
			cContaIni	:= PadR(cConta,nTamCta)
			cContaFim	:= cContaIni
		Endif
		If lTodoCTT
			cCustoIni	:= Space(nTamCC)
			cCustoFim	:= Replicate("Z",nTamCC)
		Else
			cCustoIni	:= PadR(cCusto,nTamCC)
			cCustoFim	:= cCustoIni
		Endif
		If lTodoCTD
			cItemIni	:= Space(nTamItem)
 			cItemFim	:= Replicate("Z",nTamItem)
		Else
			cItemIni	:= PadR(cItem,nTamItem)
			cItemFim	:= cItemIni
		Endif
		If lTodoCTH
			cClVlIni	:= Space(nTamClass)
			cClVlFim	:= Replicate("Z",nTamClass)
		Else
			cClVlIni	:= PadR(cClVl,nTamClass)
			cClVlFim	:= cClVlIni
		Endif
		aSaldoIni := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cContaIni,cContaFim,dDataIni,cMoeda,cTpSald)
		aSaldoFim := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cContaIni,cContaFim,dDataFim,cMoeda,cTpSald)

	// Saldo da Classe de Valor+Item+Centro de Custo+Conta
	ElseIf !Empty(cConta) .And. !Empty(cCusto) .And. !Empty(cItem)
		cClVl		:= PadR(cClVl,nTamClass)
		cItem		:= PadR(cItem,nTamItem)
		cCusto		:= PadR(cCusto,nTamCC)
		cConta		:= PadR(cConta,nTamCta)
		aSaldoIni := SaldoCtI(cConta,cCusto,cItem,cCLVL,dDataIni,cMoeda,cTpSald)
		aSaldoFim := SaldoCtI(cConta,cCusto,cItem,cCLVL,dDataFim,cMoeda,cTpSald)
	ElseIf !Empty(cConta) .And. Empty(cCusto) .And. !Empty(cItem)
		cClVl		:= PadR(cClVl,nTamClass)
		cItem		:= PadR(cItem,nTamItem)
		cConta		:= PadR(cConta,nTamCta)
		If FunName() == "CTBA281"
			cCustoIni	:= Space(nTamCC)
			cCustoFim	:= Space(nTamCC)
		Else
			cCustoIni	:= Space(nTamCC)
			cCustoFim	:= Replicate("Z",Len(CTI->CTI_CUSTO))
		Endif
		aSaldoIni 	:= SaldTotCTI(cClVl,cClVl,cItem,cItem,cCustoIni,cCustoFim,cConta,cConta,dDataIni,cMoeda,cTpSald)
		aSaldoFim 	:= SaldTotCTI(cClVl,cClVl,cItem,cItem,cCustoIni,cCustoFim,cConta,cConta,dDataFim,cMoeda,cTpSald)
	ElseIf !Empty(cConta) .And. !Empty(cCusto) .And. Empty(cItem)
		cClVl		:= PadR(cClVl,nTamClass)
		cCusto		:= PadR(cCusto,nTamCC)
		cConta		:= PadR(cConta,nTamCta)
		If FunName() == "CTBA281"
			cItemIni	:= Space(nTamItem)
 			cItemFim	:= Space(nTamItem)
		Else
			cItemIni	:= Space(nTamItem)
			cItemFim	:= Replicate("Z",Len(CTI->CTI_ITEM))
		Endif

		aSaldoIni 	:= SaldTotCTI(cClVl,cClVl,cItemIni,cItemFim,cCusto,cCusto,cConta,cConta,dDataIni,cMoeda,cTpSald)
		aSaldoFim 	:= SaldTotCTI(cClVl,cClVl,cItemIni,cItemFim,cCusto,cCusto,cConta,cConta,dDataFim,cMoeda,cTpSald)
	ElseIf !Empty(cConta) .And. Empty(cCusto) .And. Empty(cItem)
		cClVl		:= PadR(cClVl,nTamClass)
		cConta		:= PadR(cConta,nTamCta)
		If FunName() == "CTBA281"
			cCustoIni	:= Space(nTamCC)
			cCustoFim	:= Space(nTamCC)
			cItemIni	:= Space(nTamItem)
 			cItemFim	:= Space(nTamItem)
		Else
			cCustoIni	:= Space(nTamCC)
			cCustoFim	:= Replicate("Z",Len(CTI->CTI_CUSTO))
			cItemIni	:= Space(nTamItem)
			cItemFim	:= Replicate("Z",Len(CTI->CTI_ITEM))
		Endif

		aSaldoIni 	:= SaldTotCTI(cClVl,cClVl,cItemIni,cItemFim,cCustoIni,cCustoFim,cConta,cConta,dDataIni,cMoeda,cTpSald)
		aSaldoFim 	:= SaldTotCTI(cClVl,cClVl,cItemIni,cItemFim,cCustoIni,cCustoFim,cConta,cConta,dDataFim,cMoeda,cTpSald)
	ElseIf Empty(cConta) .And. !Empty(cCusto) .And. !Empty(cItem)
		cClVl		:= PadR(cClVl,nTamClass)
		cItem		:= PadR(cItem,nTamItem)
		cCusto		:= PadR(cCusto,nTamCC)

		aSaldoIni 	:= SaldTotCTI(cClVl,cClVl,cItem,cItem,cCusto,cCusto,Space(nTamCta),Repl("Z",nTamCta),dDataIni,cMoeda,cTpSald)
		aSaldoFim 	:= SaldTotCTI(cClVl,cClVl,cItem,cItem,cCusto,cCusto,Space(nTamCta),Repl("Z",nTamCta),dDataFim,cMoeda,cTpSald)
	EndIf

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Retorno:                                          ≥
	//≥ [1] Movimento Devedor 	                           ≥
	//≥ [2] Movimento Credor		                        ≥
	//≥ [3] Movimento do Mes		                        ≥
	//≥ [4] Saldo Final                                	≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	nDebito		:= aSaldoFim[4] - aSaldoIni[7]
	nCredito	  := aSaldoFim[5] - aSaldoIni[8]

	aMovimento := {nDebito,nCredito,nCredito-nDebito,aSaldoFim[1]}
EndIf



Return aMovimento[nQualSaldo]

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥ CtSmConta  ≥ Autor ≥ Wagner Mobile Costa ≥ Data ≥ 07.02.02 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Soma os saldos de um grupo aleatorio de contas			  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cContas    = Codigo das Contas, separado por virgula e :   ≥±±
±±≥          ≥ dData      = Data                                          ≥±±
±±≥          ≥ cMoeda     = Moeda                                         ≥±±
±±≥          ≥ cTpSald    = Tipo de Saldo                                 ≥±±
±±≥          ≥ nQualSaldo = Retorno Desejado                              ≥±±
±±≥          ≥ nSint      = Indica se eh sintetico ou nao (1=Sint/0=Analit)±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso		 ≥ Para uso na planilha. Obs:sem macro e so' com vars locais !≥±±
±±≥ Atencao  ≥ Esta funcao faz chamadas a funcao CtbSmSaldo()			  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CtSmConta( cContas, dData, cMoeda, cTpSald, nQualSaldo, nSint )

// Retorna o Saldo de um grupo de contas informadas em cContas separadas por ":" para
// indicar um intervalo entre contas e separadas por "," para indicar novo intervalo
// para soma.

Local nLop	  := 0	 	// Variavel para uso no laco que varre cContas e arrays
Local aDeAte  := {}	// Armazenara' os grupos de contas "De/Ate'"
Local aContas := {}	// Armazenara' as contas indiviuais
Local cTempor := ""  	// Variavel auxiliar, transitoria e temporaria
Local nVolta  := 0	 	// Variavel auxiliar de retorno da funcao
Local lSint	  := .F.

DEFAULT nSint	:= 0

lSint	:= Iif(nSint == 0 ,.F.,.T.)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica passagem correta de parametros ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If ValType( cContas ) # "C"
	// Avaliar se devemos criar um help para esta consistencia
	Return( 0 )
Endif

If ValType(cMoeda) # "C"
	cMoeda := StrZero(cMoeda, 2)
Endif

cTpSald 	:= Iif(cTpSald==Nil,"1",cTpSald)
If ValType(cTpSald) # "C"
	cTpSald := Str(cTpSald, 1)
Endif
nQualSaldo	:= Iif(nQualSaldo==Nil .Or. ValType(nQualSaldo) = "C",1,nQualSaldo)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Analisa a String que contem as contas   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
cContas := AllTrim( cContas )
cTempor := ""
For nLop := 1 to Len( cContas )
	 cChar := Subst( cContas, nLop , 1)

	 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	 //≥ Verifica a presenca de caracteres invalidos ≥
	 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	 If !UPPER(cChar) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,:"
		 // Avaliar se devemos criar um help para esta consistencia
		 Loop
	 Endif

	 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	 //≥ Se encontrar o separador simples, faz a carga dos arrays	≥
	 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	 If CChar == ","
		 If ":" $ cTempor
			 Aadd( aDeAte , cTempor)
		 Else
			 If !Empty( cTempor )
				 Aadd( aContas , cTempor )
			 Endif
		 Endif
		 cTempor := ""
	 Else
		 cTempor += cChar
	 Endif

Next nLop

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica o fim, pois nao precisa haver "," no final !      ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If !Empty( cTempor )
	If ":" $ cTempor
		 Aadd( aDeAte , cTempor)
	Else
		 Aadd( aContas , cTempor )
	Endif
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica se houve identificacao de contas ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If Len( aDeAte ) == 0 .and. Len( aContas ) == 0
	Return( 0 )
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1] Saldo Atual (com sinal)                          ≥
//≥ [2] Debito na Data                                   ≥
//≥ [3] Credito na Data                                  ≥
//≥ [4] Saldo Atual Devedor                              ≥
//≥ [5] Saldo Atual Credor                               ≥
//≥ [6] Saldo Anterior (com sinal)                       ≥
//≥ [7] Saldo Anterior Devedor                           ≥
//≥ [8] Saldo Anterior Credor                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Laco das contas "De / Ate"       ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
For nLop := 1 to Len( aDeAte )

	// Conta inicial
	cTempor := Subst( aDeAte[nLop], 1, At(":",aDeAte[nLop]) -1 )
	// Conta Final
	cChar   := Subst( aDeAte[nLop], At(":",aDeAte[nLop]) + 1 , Len(aDeAte[nLop] ) )

	nVolta += CtbSmSaldo(cTempor,cChar,dData,cMoeda,cTpSald,nQualSaldo,"CT1",lSint)

Next nLop

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Laco das contas isoladas   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
For nLop := 1 to Len( aContas )
	 nVolta += CtbSmSaldo(aContas[nLop],aContas[nLop],dData,cMoeda,cTpSald,nQualSaldo,"CT1",lSint)
Next Lop

Return nVolta

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥ CtSmCusto  ≥ Autor ≥ Wagner Mobile Costa ≥ Data ≥ 07.02.02 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Soma os saldos de um grupo aleatorio de C.Custos 		  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cCustos    = Codigo dos C.Custo, separado por virgula e :  ≥±±
±±≥          ≥ dData      = Data                                          ≥±±
±±≥          ≥ cMoeda     = Moeda                                         ≥±±
±±≥          ≥ cTpSald    = Tipo de Saldo                                 ≥±±
±±≥          ≥ nQualSaldo = Retorno Desejado                              ≥±±
±±≥          ≥ nSint      = Indica se eh sintetico ou nao (1=Sint/0=Analit)±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso		 ≥ Para uso na planilha. Obs:sem macro e so' com vars locais !≥±±
±±≥ Atencao  ≥ Esta funcao faz chamadas a funcao CtbSmSaldo 			  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CtSmCusto ( cCustos, dData, cMoeda, cTpSald, nQualSaldo, nSint, nImpAntLP, dDataLP)

// Retorna o Saldo de um grupo de C.Custo informados em cCustos separados por ":" para
// indicar um intervalo entre C.Custo e separados por "," para indicar novo intervalo
// para soma.

Local nLop	  := 0	 	// Variavel para uso no laco que varre cCustos e arrays
Local aDeAte  := {}	// Armazenara' os grupos de C.Custo "De/Ate'"
Local aCustos := {}	// Armazenara' os C.Custo indiviuais
Local cTempor := ""  	// Variavel auxiliar, transitoria e temporaria
Local nVolta  := 0	 	// Variavel auxiliar de retorno da funcao
Local lSint	  := .F.
Local lImpAntLP

DEFAULT nSint	:= 0
DEFAULT nImpAntLP := 0 // corresponde a .F.
DEFAULT dDataLP   := CTOD("  /  /  ")

lSint	:= Iif(nSint == 0 ,.F.,.T.)

lImpAntLP := ( nImpAntLP == 1 )

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica passagem correta de parametros ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If ValType( cCustos ) # "C"
	// Avaliar se devemos criar um help para esta consistencia
	Return( 0 )
Endif

If ValType(cMoeda) # "C"
	cMoeda := StrZero(cMoeda, 2)
Endif

cTpSald 	:= Iif(cTpSald==Nil,"1",cTpSald)
If ValType(cTpSald) # "C"
	cTpSald := Str(cTpSald, 1)
Endif
nQualSaldo	:= Iif(nQualSaldo==Nil .Or. ValType(nQualSaldo) = "C",1,nQualSaldo)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Analisa a String que contem os C.Custo  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
cCustos := AllTrim( cCustos )
cTempor := ""
For nLop := 1 to Len( cCustos )
	 cChar := Subst( cCustos, nLop , 1)

	 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	 //≥ Verifica a presenca de caracteres invalidos ≥
	 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	 If !UPPER(cChar) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,:"
		 // Avaliar se devemos criar um help para esta consistencia
		 Loop
	 Endif

	 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	 //≥ Se encontrar o separador simples, faz a carga dos arrays	≥
	 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	 If CChar == ","
		 If ":" $ cTempor
			 Aadd( aDeAte , cTempor)
		 Else
			 If !Empty( cTempor )
				 Aadd( aCustos , cTempor )
			 Endif
		 Endif
		 cTempor := ""
	 Else
		 cTempor += cChar
	 Endif

Next nLop

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica o fim, pois nao precisa haver "," no final !      ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If !Empty( cTempor )
	If ":" $ cTempor
		 Aadd( aDeAte , cTempor)
	Else
		 Aadd( aCustos , cTempor )
	Endif
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica se houve identificacao de custos ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If Len( aDeAte ) == 0 .and. Len( aCustos ) == 0
	Return( 0 )
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1] Saldo Atual (com sinal)                          ≥
//≥ [2] Debito na Data                                   ≥
//≥ [3] Credito na Data                                  ≥
//≥ [4] Saldo Atual Devedor                              ≥
//≥ [5] Saldo Atual Credor                               ≥
//≥ [6] Saldo Anterior (com sinal)                       ≥
//≥ [7] Saldo Anterior Devedor                           ≥
//≥ [8] Saldo Anterior Credor                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Laco dos C.Custo "De / Ate"      ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
For nLop := 1 to Len( aDeAte )

	// C.Custo inicial
	cTempor := Subst( aDeAte[nLop], 1, At(":",aDeAte[nLop]) -1 )
	// C.Custo Final
	cChar   := Subst( aDeAte[nLop], At(":",aDeAte[nLop]) + 1 , Len(aDeAte[nLop] ) )

	nVolta += CtbSmSaldo(cTempor,cChar,dData,cMoeda,cTpSald,nQualSaldo,"CTT",lSint,lImpAntLP,dDataLP)

Next nLop

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Laco dos C.Custo isolados  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
For nLop := 1 to Len( aCustos )
	 nVolta += CtbSmSaldo(aCustos[nLop],aCustos[nLop],dData,cMoeda,cTpSald,nQualSaldo,"CTT",lSint,lImpAntLP,dDataLP)
Next Lop

Return nVolta

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥ CtSmItem   ≥ Autor ≥ Wagner Mobile Costa ≥ Data ≥ 07.02.02 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Soma os saldos de um grupo aleatorio de Itens			  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cItens     = Codigo dos Itens , separado por virgula e :   ≥±±
±±≥          ≥ dData      = Data                                          ≥±±
±±≥          ≥ cMoeda     = Moeda                                         ≥±±
±±≥          ≥ cTpSald    = Tipo de Saldo                                 ≥±±
±±≥          ≥ nQualSaldo = Retorno Desejado                              ≥±±
±±≥          ≥ nSint      = Indica se eh sintetico ou nao (1=Sint/0=Analit)±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso		 ≥ Para uso na planilha. Obs:sem macro e so' com vars locais !≥±±
±±≥ Atencao  ≥ Esta funcao faz chamadas a funcao CtbSmSaldo 			  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CtSmItem ( cItens, dData, cMoeda, cTpSald, nQualSaldo, nSint )

// Retorna o Saldo de um grupo de Itens Contabeis informados em cItens separados
// por ":" para indicar um intervalo entre Itens e separados por "," para indicar
// novo intervalo para soma.

Local nLop	  := 0	 	// Variavel para uso no laco que varre cItens e arrays
Local aDeAte  := {}	// Armazenara' os grupos de Item "De/Ate'"
Local aItens  := {}	// Armazenara' os Itens indiviuais
Local cTempor := ""  	// Variavel auxiliar, transitoria e temporaria
Local nVolta  := 0	 	// Variavel auxiliar de retorno da funcao
Local lSint	  := .F.

DEFAULT nSint	:= 0

lSint	:= Iif(nSint == 0 ,.F.,.T.)


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica passagem correta de parametros ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If ValType( cItens ) # "C"
	// Avaliar se devemos criar um help para esta consistencia
	Return( 0 )
Endif

If ValType(cMoeda) # "C"
	cMoeda := StrZero(cMoeda, 2)
Endif

cTpSald 	:= Iif(cTpSald==Nil,"1",cTpSald)
If ValType(cTpSald) # "C"
	cTpSald := Str(cTpSald, 1)
Endif
nQualSaldo	:= Iif(nQualSaldo==Nil .Or. ValType(nQualSaldo) = "C",1,nQualSaldo)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Analisa a String que contem os Itens    ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
cItens := AllTrim( cItens )
cTempor := ""
For nLop := 1 to Len( cItens )
	 cChar := Subst( cItens, nLop , 1)

	 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	 //≥ Verifica a presenca de caracteres invalidos ≥
	 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	 If !UPPER(cChar) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,:"
		 // Avaliar se devemos criar um help para esta consistencia
		 Loop
	 Endif

	 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	 //≥ Se encontrar o separador simples, faz a carga dos arrays	≥
	 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	 If CChar == ","
		 If ":" $ cTempor
			 Aadd( aDeAte , cTempor)
		 Else
			 If !Empty( cTempor )
				 Aadd( aItens , cTempor )
			 Endif
		 Endif
		 cTempor := ""
	 Else
		 cTempor += cChar
	 Endif

Next nLop

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica o fim, pois nao precisa haver "," no final !      ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If !Empty( cTempor )
	If ":" $ cTempor
		 Aadd( aDeAte , cTempor)
	Else
		 Aadd( aItens , cTempor )
	Endif
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica se houve identificacao de Itens  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If Len( aDeAte ) == 0 .and. Len( aItens ) == 0
	Return( 0 )
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1] Saldo Atual (com sinal)                          ≥
//≥ [2] Debito na Data                                   ≥
//≥ [3] Credito na Data                                  ≥
//≥ [4] Saldo Atual Devedor                              ≥
//≥ [5] Saldo Atual Credor                               ≥
//≥ [6] Saldo Anterior (com sinal)                       ≥
//≥ [7] Saldo Anterior Devedor                           ≥
//≥ [8] Saldo Anterior Credor                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Laco dos Itens   "De / Ate"      ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
For nLop := 1 to Len( aDeAte )

	// Item inicial
	cTempor := Subst( aDeAte[nLop], 1, At(":",aDeAte[nLop]) -1 )
	// Item Final
	cChar   := Subst( aDeAte[nLop], At(":",aDeAte[nLop]) + 1 , Len(aDeAte[nLop] ) )

	nVolta += CtbSmSaldo(cTempor,cChar,dData,cMoeda,cTpSald,nQualSaldo,"CTD",lSint)

Next nLop

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Laco dos itens  isolados   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
For nLop := 1 to Len( aItens )
	 nVolta += CtbSmSaldo(aItens[nLop],aItens[nLop],dData,cMoeda,cTpSald,nQualSaldo,"CTD",lSint)
Next Lop

Return nVolta

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥ CtSmClVl   ≥ Autor ≥ Wagner Mobile Costa ≥ Data ≥ 07.02.02 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Soma os saldos de um grupo aleatorio de Cl. Valor		  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cClVls     = Codigo das Cl.Vlr, separado por virgula e :   ≥±±
±±≥          ≥ dData      = Data                                          ≥±±
±±≥          ≥ cMoeda     = Moeda                                         ≥±±
±±≥          ≥ cTpSald    = Tipo de Saldo                                 ≥±±
±±≥          ≥ nQualSaldo = Retorno Desejado                              ≥±±
±±≥          ≥ nSint      = Indica se eh sintetico ou nao (1=Sint/0=Analit)±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso		 ≥ Para uso na planilha. Obs:sem macro e so' com vars locais !≥±±
±±≥ Atencao  ≥ Esta funcao faz chamadas a funcao CtbSmSaldo 			  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CtSmClVl ( cClVls, dData, cMoeda, cTpSald, nQualSaldo, nSint )

// Retorna o Saldo de um grupo de Classe de Valor informados em cClVl separados
// por ":" para indicar um intervalo entre Cl.Vlrs e separados por "," para indicar
// novo intervalo para soma.

Local nLop	  := 0	 	// Variavel para uso no laco que varre Cl. Vlrs e arrays
Local aDeAte  := {}	// Armazenara' os grupos de Classe Vlr "De/Ate'"
Local aItens  := {}// Armazenara' as Cl. Vlrs indiviuais
Local cTempor := ""  	// Variavel auxiliar, transitoria e temporaria
Local nVolta  := 0	 	// Variavel auxiliar de retorno da funcao
Local lSint	  := .F.

DEFAULT nSint	:= 0

lSint	:= Iif(nSint == 0 ,.F.,.T.)


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica passagem correta de parametros ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If ValType( cClVls ) # "C"
	// Avaliar se devemos criar um help para esta consistencia
	Return( 0 )
Endif

If ValType(cMoeda) # "C"
	cMoeda := StrZero(cMoeda, 2)
Endif

cTpSald 	:= Iif(cTpSald==Nil,"1",cTpSald)
If ValType(cTpSald) # "C"
	cTpSald := Str(cTpSald, 1)
Endif
nQualSaldo	:= Iif(nQualSaldo==Nil .Or. ValType(nQualSaldo) = "C",1,nQualSaldo)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Analisa a String que contem Cl Vlrs     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
cClVls := AllTrim( cClVls )
cTempor := ""
For nLop := 1 to Len( cClVls )
	 cChar := Subst( cClVls, nLop , 1)

	 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	 //≥ Verifica a presenca de caracteres invalidos ≥
	 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	 If !UPPER(cChar) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,:"
		 // Avaliar se devemos criar um help para esta consistencia
		 Loop
	 Endif

	 //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	 //≥ Se encontrar o separador simples, faz a carga dos arrays	≥
	 //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	 If CChar == ","
		 If ":" $ cTempor
			 Aadd( aDeAte , cTempor)
		 Else
			 If !Empty( cTempor )
				 Aadd( aItens , cTempor )
			 Endif
		 Endif
		 cTempor := ""
	 Else
		 cTempor += cChar
	 Endif

Next nLop

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica o fim, pois nao precisa haver "," no final !      ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If !Empty( cTempor )
	If ":" $ cTempor
		 Aadd( aDeAte , cTempor)
	Else
		 Aadd( aItens , cTempor )
	Endif
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica se houve identificacao da ClVl   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If Len( aDeAte ) == 0 .and. Len( aItens ) == 0
	Return( 0 )
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1] Saldo Atual (com sinal)                          ≥
//≥ [2] Debito na Data                                   ≥
//≥ [3] Credito na Data                                  ≥
//≥ [4] Saldo Atual Devedor                              ≥
//≥ [5] Saldo Atual Credor                               ≥
//≥ [6] Saldo Anterior (com sinal)                       ≥
//≥ [7] Saldo Anterior Devedor                           ≥
//≥ [8] Saldo Anterior Credor                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Laco das ClVl's   "De / Ate"     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
For nLop := 1 to Len( aDeAte )

	// ClVl inicial
	cTempor := Subst( aDeAte[nLop], 1, At(":",aDeAte[nLop]) -1 )
	// ClVl Final
	cChar   := Subst( aDeAte[nLop], At(":",aDeAte[nLop]) + 1 , Len(aDeAte[nLop] ) )

	nVolta += CtbSmSaldo(cTempor,cChar,dData,cMoeda,cTpSald,nQualSaldo,"CTH",lSint)

Next nLop

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Laco das ClVl's  isoladas  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
For nLop := 1 to Len( aItens )
	 nVolta += CtbSmSaldo(aItens[nLop],aItens[nLop],dData,cMoeda,cTpSald,nQualSaldo,"CTH",lSint)
Next Lop

Return nVolta



//-------------------------------------------------------------------
/*{Protheus.doc} CtbSmSaldo

Devolve saldos de um periodo de contas

@author Alvaro Camillo Neto

@param cCodigode   Entidade Inicial
@param cCodigoAte  Entidade Final
@param dData       Data
@param cMoeda      Moeda
@param cTpSald     Tipo de Saldo
@param nQualSaldo  Retorno Desejado
@param cAlias      Arquivo a ser tratado


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CtbSmSaldo(cCodigoDe,cCodigoAte,dData,cMoeda,cTpSald,nQualSaldo,cAlias,lSint,lImpAntLP,dDataLP)

Local aSaveArea	:= GetArea()
Local aSaldos	:= {}
Local cQrySld 	:= ""
Local cQryOk 	:= ""

DEFAULT lSint	:= .F.

dDataLp		:= Iif(dDataLP==Nil,CTOD("  /  /  "),dDataLP)
lImpAntLP	:= Iif(lImpAntLP==Nil,.F.,lImpAntLP)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica passagem correta de parametros ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If ValType( cCodigoDe ) # "C" .Or. ValType( cCodigoAte ) # "C"
	// Avaliar se devemos criar um help para esta consistencia
	Return( 0 )
Endif

If ValType(cMoeda) # "C"
	cMoeda := StrZero(cMoeda, 2)
Endif

cTpSald 	:= Iif(cTpSald==Nil,"1",cTpSald)
If ValType(cTpSald) # "C"
	cTpSald := Str(cTpSald, 1)
Endif
If ValType(dData) = "C"
	dData := Ctod(dData)
Endif

nQualSaldo	:= Iif(nQualSaldo==Nil .Or. ValType(nQualSaldo) = "C",1,nQualSaldo)
cAlias 		:= Iif(cAlias==Nil,"CT1",cAlias)

If cAlias == "CT1"			// Plano de Contas

		cQrySld := "SELECT 1  "
		cQrySld += " FROM "+RetSqlName("CQ1")
		cQrySld += " WHERE CQ1_FILIAL = '"+xFilial('CQ1')+"' "
		cQrySld += "AND CQ1_DATA  <= '"+Dtos(dData)+"' "
		cQrySld += "AND CQ1_MOEDA  = '"+cMoeda+"' "
		cQrySld += "AND CQ1_TPSALD = '"+cTpSald+"' "
		cQrySld += "AND D_E_L_E_T_ = '' "
		cQrySld += "AND CQ1_CONTA = '"

		dbSelectArea("CT1")
		dbSetOrder(1)
		MsSeek(xFilial() + cCodigoDe, .T.)
		If !lSint
			cCodigoAte := PADR(cCodigoAte,LEN(CT7->CT7_CONTA))
		EndIf
		While !CT1->(Eof()) .And. CT1->CT1_FILIAL = xFilial("CT1") .And. CT1->CT1_CONTA <= cCodigoAte

			cQryOk := ChangeQuery(cQrySld+CT1->CT1_CONTA+"'")

			If Select("EXISTCT7") > 0
				dbSelectArea("EXISTCT7")
				EXISTCT7->(dbCloseArea())
			Endif
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryOk),"EXISTCT7",.T.,.F.)
			lEof	:=	Eof()
			dbSelectArea("EXISTCT7")
			dbCloseArea()
			If !lEof
				If Len(aSaldos) = 0
					aSaldos := SaldoCt7(CT1->CT1_CONTA,dData,cMoeda,cTpSald,"CTBXFUN",lImpAntLP,dDataLP)
				Else
					aSaldos[nQualSaldo] += SaldoCt7(CT1->CT1_CONTA,dData,cMoeda,cTpSald,"CTBXFUN",lImpAntLP,dDataLP)[nQualSaldo]
				Endif
			Endif
			CT1->(dbSkip())
		EndDo

ElseiF cAlias == "CTT"		// Centro de Custo

		cQrySld := "SELECT 1  "
		cQrySld += " FROM "+RetSqlName("CQ3")
		cQrySld += " WHERE CQ3_FILIAL = '"+xFilial('CQ3')+"' "
		cQrySld += "AND CQ3_DATA  <= '"+Dtos(dData)+"' "
		cQrySld += "AND CQ3_MOEDA  = '"+cMoeda+"' "
		cQrySld += "AND CQ3_TPSALD = '"+cTpSald+"' "
		cQrySld += "AND D_E_L_E_T_ = '' "
		cQrySld += "AND CQ3_CCUSTO = '"
		dbSelectArea("CTT")
		dbSetOrder(1)
		MsSeek(xFilial() + cCodigoDe, .T.)
		If !lSint
			cCodigoAte := PADR(cCodigoAte,LEN(CTT->CTT_CUSTO))
		EndIf
		While !CTT->(Eof()) .And.	CTT->CTT_FILIAL = xFilial("CTT") .And. CTT->CTT_CUSTO <= cCodigoAte

			cQryOk := ChangeQuery(cQrySld+CTT->CTT_CUSTO+"'")

			If Select("EXISTCTT") > 0
				dbSelectArea("EXISTCTT")
				EXISTCTT->(dbCloseArea())
			Endif
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryOk),"EXISTCTT",.T.,.F.)
			lEof	:=	Eof()
			dbSelectArea("EXISTCTT")
			dbCloseArea()
			If !lEof

				If Len(aSaldos) = 0
					aSaldos := SaldoCTU("CTT",CTT->CTT_CUSTO,dData,cMoeda,cTpSald)
				Else
					aSaldos[nQualSaldo] += SaldoCTU("CTT",CTT->CTT_CUSTO,dData,cMoeda,cTpSald)[nQualSaldo]
				Endif
			Endif
			CTT->(dbSkip())
		EndDo

ElseIf cAlias == "CTD"
		cQrySld := "SELECT 1  "
		cQrySld += " FROM "+RetSqlName("CQ5")
		cQrySld += " WHERE CQ5_FILIAL = '"+xFilial('CQ5')+"' "
		cQrySld += "AND CQ5_DATA  <= '"+Dtos(dData)+"' "
		cQrySld += "AND CQ5_MOEDA  = '"+cMoeda+"' "
		cQrySld += "AND CQ5_TPSALD = '"+cTpSald+"' "
		cQrySld += "AND D_E_L_E_T_ = '' "
		cQrySld += "AND CQ5_ITEM  = '"

		dbSelectArea("CTD")
		dbSetOrder(1)
		MsSeek(xFilial() + cCodigoDe, .T.)
		If !lSint
			cCodigoAte := PADR(cCodigoAte,LEN(CT7->CT7_CONTA))
		EndIf
		While !CTD->(Eof()) .And. CTD->CTD_FILIAL = xFilial("CTD") .And. CTD->CTD_ITEM  <= cCodigoAte

			cQryOk := ChangeQuery(cQrySld+CTD->CTD_ITEM +"'")

			If Select("EXISTCT4") > 0
				dbSelectArea("EXISTCT4")
				EXISTCT4->(dbCloseArea())
			Endif
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryOk),"EXISTCT4",.T.,.F.)
			lEof	:=	Eof()
			dbSelectArea("EXISTCT4")
			dbCloseArea()
			If !lEof
				If Len(aSaldos) = 0
					aSaldos := SaldoCTU("CTD",CTD->CTD_ITEM,dData,cMoeda,cTpSald)
				Else
					aSaldos[nQualSaldo] += SaldoCTU("CTD",CTD->CTD_ITEM,dData,cMoeda,cTpSald)[nQualSaldo]
				Endif
			Endif
			CTD->(dbSkip())
		EndDo

ElseIf cAlias == "CTH"

		cQrySld := "SELECT 1  "
		cQrySld += " FROM "+RetSqlName("CQ7")
		cQrySld += " WHERE CQ7_FILIAL = '"+xFilial('CQ7')+"' "
		cQrySld += "AND CQ7_DATA  <= '"+Dtos(dData)+"' "
		cQrySld += "AND CQ7_MOEDA  = '"+cMoeda+"' "
		cQrySld += "AND CQ7_TPSALD = '"+cTpSald+"' "
		cQrySld += "AND D_E_L_E_T_ = '' "
		cQrySld += "AND CQ7_CLVL = '"

		dbSelectArea("CTH")
		dbSetOrder(1)
		MsSeek(xFilial() + cCodigoDe, .T.)
		If !lSint
			cCodigoAte := PADR(cCodigoAte,LEN(CT7->CT7_CONTA))
		EndIf
		While !CTH->(Eof()) .And. CTH->CTH_FILIAL = xFilial("CTH") .And. CTH->CTH_CLVL <= cCodigoAte

			cQryOk := ChangeQuery(cQrySld+CTH->CTH_CLVL+"'")

			If Select("EXISTCTI") > 0
				dbSelectArea("EXISTCTI")
				EXISTCTI->(dbCloseArea())
			Endif
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryOk),"EXISTCTI",.T.,.F.)
			lEof	:=	Eof()
			dbSelectArea("EXISTCTI")
			dbCloseArea()
			If !lEof
				If Len(aSaldos) = 0
					aSaldos := SaldoCTU("CTH",CTH->CTH_CLVL,dData,cMoeda,cTpSald)
				Else
					aSaldos[nQualSaldo] += SaldoCTU("CTH",CTH->CTH_CLVL,dData,cMoeda,cTpSald)[nQualSaldo]
				Endif
			Endif
			CTH->(dbSkip())
		EndDo
EndIf

RestArea(aSaveArea)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1] Saldo Atual (com sinal)                          ≥
//≥ [2] Debito na Data                                   ≥
//≥ [3] Credito na Data                                  ≥
//≥ [4] Saldo Atual Devedor                              ≥
//≥ [5] Saldo Atual Credor                               ≥
//≥ [6] Saldo Anterior (com sinal)                       ≥
//≥ [7] Saldo Anterior Devedor                           ≥
//≥ [8] Saldo Anterior Credor                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

Return If(Len(aSaldos) = 0, 0, aSaldos[nQualSaldo])


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CtSmEntMov∫Autor  ≥Marcos S. Lobo      ∫ Data ≥  14/05/04   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Soma o movimento de um intervalo contas/ccusto/item ou      ∫±±
±±∫          ≥Cl.Valor                                                    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP - Excel                                      			  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥Parametros≥ cCodigoDe  = Codigo da Entidade Inicial					  ≥±±
±±≥          ≥ cCodigoAte = Codigo da Entidade Final	                  ≥±±
±±≥          ≥ dDataIni   = Data inicial dos movimentos                   ≥±±
±±≥          ≥ dDataFim   = Data Final dos movimentos                     ≥±±
±±≥          ≥ cMoeda     = Moeda                                         ≥±±
±±≥          ≥ cTpSald    = Tipo de Saldo                                 ≥±±
±±≥          ≥ nQualSaldo = Retorno Desejado (1=Inicial/2=Final/3=Mov.)   ≥±±
±±≥          ≥ cAlias     = Entidade Desejada (CT1/CTT/CTD/CTH)			  ≥±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function CtSmEntMov(cCodigoDe,cCodigoAte,dDataIni,dDataFim,cMoeda,cTpSald,nQualSaldo,cAlias,nImpAntLP,dDataLP)

Local aMovimento:= {0,0,0}
Local nSldIni	:= 0
Local nSldFim	:= 0
Local lImpAntLP

DEFAULT cCodigoDe	:= ""
DEFAULT cCodigoAte	:= ""
DEFAULT dDataIni	:= dDataBase
DEFAULT dDataFim	:= dDataBase
DEFAULT cMoeda 		:= "01"
DEFAULT cTpSald		:= "1"
DEFAULT nQualSaldo	:= 3
DEFAULT cAlias		:= "CT1"
DEFAULT nImpAntLP := 0 // corresponde a .F.
DEFAULT dDataLP   := CTOD("  /  /  ")

lImpAntLP := ( nImpAntLP == 1 )

If ValType(cCodigoDe) == "N"
	cCodigoDe := ALLTRIM(STR(INT(cCodigoDe)))
Endif

If ValType(cCodigoAte) == "N"
	cCodigoAte := ALLTRIM(STR(INT(cCodigoAte)))
Endif

If ValType(dDataIni) == "C"
	If At("/",dDataIni) > 0
		dDataIni := CTOD(dDataIni)
	Else
		dDataIni := STOD(dDataIni)
	Endif
EndIf

If ValType(dDataFim) == "C"
	If At("/",dDataFim) > 0
		dDataFim := CTOD(dDataFim)
	Else
		dDataFim := STOD(dDataFim)
	Endif
EndIf

If ValType(cMoeda) == "N"
	cMoeda := ALLTRIM(STRZERO(cMoeda,2))
Endif

If ValType(cTpSald) == "N"
	cTpSald := ALLTRIM(STR(INT(cTpSald)))
Endif

If ValType(nQualSaldo) == "C"
	nQualSaldo := Int(Val(nQualSaldo))
Endif

nSldIni := CtbSmSaldo(cCodigoDe,cCodigoAte,dDataIni,cMoeda,cTpSald,6,cAlias,,lImpAntLP,dDataLP)
nSldFim	:= CtbSmSaldo(cCodigoDe,cCodigoAte,dDataFim,cMoeda,cTpSald,1,cAlias,,lImpAntLP,dDataLP)

aMovimento := {nSldIni,nSldFim,nSldFim-nSldIni}

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1] Saldo Inicial                                    ≥
//≥ [2] Saldo Final       		                         ≥
//≥ [3] Movimento do Periodo (com sinal)                 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Return(aMovimento[nQualSaldo])


//-------------------------------------------------------------------
/*{Protheus.doc} CtSmMov

Soma o Movimento/Saldo de um intervalo de entidades ou de um conjunto de entidades (Conta/Custo/Item e/ou Cl.Valor)

@author Alvaro Camillo Neto

@param dDataIni    Data inicial dos movimentos
@param dDataFim    Data Final dos movimentos
@param cMoeda      Moeda
@param cTpSald     Tipo de Saldo
@param nQualSaldo  Retorno Desejado (1=Mov.Deb/2=Mov.Crd/3=Mov./4
@param cContaIni   Codigo da Conta Inicial (opcional)
@param cContaFim   Codigo da Conta Final (opcional)
@param cCustoIni   Codigo do C.Custo Inicial (opcional)
@param cCustoFim   Codigo do C.Custo Final (opcional)
@param cItemIni    Codigo do Item Inicial (opcional)
@param cItemFim    Codigo do Item Final (opcional)
@param cCLVLIni    Codigo da C.Valor Inicial (opcional)
@param cCLVLFim    Codigo da C.Valor Final (opcional)


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Function CtSmMov(dDataIni,dDataFim,cMoeda,cTpSald,nQualSaldo,cContaIni,cContaFim,cCustoIni,cCustoFim,cItemIni,cItemFim,cCLVLIni,cCLVLFim,nImpAntLP,dDataLP)

Local aSaldoIni := {0,0,0,0,0,0,0,0}
Local aSaldoFim := {0,0,0,0,0,0,0,0}
Local aMovimento:= {0,0,0,0}
Local nDebito	:= 0
Local nCredito	:= 0
Local lTemConta	:= .F.
Local lTemCusto	:= .F.
Local lTemItem	:= .F.
Local lTemCLVL	:= .F.
Local lImpAntLP

DEFAULT dDataIni	:= dDataBase
DEFAULT dDataFim	:= dDataBase
DEFAULT cMoeda 		:= "01"
DEFAULT cTpSald		:= "1"
DEFAULT nQualSaldo	:= 3
DEFAULT nImpAntLP := 0 // corresponde a .F.
DEFAULT dDataLP   := CTOD("  /  /  ")

lImpAntLP := ( nImpAntLP == 1 )

If ValType(dDataIni) == "C"
	If At("/",dDataIni) > 0
		dDataIni := CTOD(dDataIni)
	Else
		dDataIni := STOD(dDataIni)
	Endif
EndIf

If ValType(dDataFim) == "C"
	If At("/",dDataFim) > 0
		dDataFim := CTOD(dDataFim)
	Else
		dDataFim := STOD(dDataFim)
	Endif
EndIf

If ValType(cMoeda) == "N"
	cMoeda := ALLTRIM(STRZERO(cMoeda,2))
Endif

If ValType(cTpSald) == "N"
	cTpSald := ALLTRIM(STR(INT(cTpSald)))
Endif

If ValType(nQualSaldo) == "C"
	nQualSaldo := Int(Val(nQualSaldo))
Endif

If !Empty(cCLVLINI) .or. !Empty(cCLVLFIM)
	lTemCLVL := .T.
	If Empty(cCLVLFim)
		cCLVLFim := cCLVLIni
	Endif
Else
	cCLVLIni	:= ""
	cCLVLFim	:= Replicate("Z",Len(CriaVar("CTH_CLVL")))
Endif
If !Empty(cItemIni) .or. !Empty(cItemFIM)
	lTemItem := .T.
	If Empty(cItemFIM)
		cItemFIM := cItemIni
	Endif
Else
	cItemIni	:= ""
	cItemFim	:= Replicate("Z",Len(CriaVar("CTD_ITEM")))
Endif
If !Empty(cCustoIni) .or. !Empty(cCustoFIM)
	lTemCusto := .T.
	If Empty(cCustoFIM)
		cCustoFIM := cCustoIni
	Endif
Else
	cCustoIni	:= ""
	cCustoFim	:= Replicate("Z",Len(CriaVar("CTT_CUSTO")))
Endif
If !Empty(cContaIni) .or. !Empty(cContaFIM)
	lTemConta := .T.
	If Empty(cContaFIM)
		cContaFIM := cContaIni
	Endif
Else
	cContaIni	:= ""
	cContaFim	:= Replicate("Z",Len(CriaVar("CT1_CONTA")))
Endif

If lTemConta
	If lTemCLVL
		aSaldoIni := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cContaIni,cContaFim,dDataIni,cMoeda,cTpSald)
		aSaldoFim := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cContaIni,cContaFim,dDataFim,cMoeda,cTpSald)
	ElseIf lTemItem
		aSaldoIni := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cContaIni,cContaFim,dDataIni,cMoeda,cTpSald)
		aSaldoFim := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cContaIni,cContaFim,dDataFim,cMoeda,cTpSald)
	ElseIf lTemCusto
		aSaldoIni := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,cContaFim,dDataIni,cMoeda,cTpSald)
		aSaldoFim := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,cContaFim,dDataFim,cMoeda,cTpSald)
	Else
		aSaldoIni := SaldTotCT7(cContaIni,cContaFim,dDataIni,cMoeda,cTpSald,lImpAntLP,dDataLP)
		aSaldoFim := SaldTotCT7(cContaIni,cContaFim,dDataFim,cMoeda,cTpSald,lImpAntLP,dDataLP)
	Endif
ElseIf lTemCLVL
	If lTemItem .and. lTemCusto
		// SALDO DA CLASSE DE VALORES + ITEM CONTABIL + C.CUSTO = CTY
		aSaldoIni := SaldoTotCQ("CTH",/*@cContaIni*/,/*@cContaFim*/,@cCustoIni,@cCustoFim,@cItemIni,@cItemFim,@cCLVLIni,@cCLVLFim,@dDataIni,;
			@cMoeda,@cTpSald,@lImpAntLP,@dDataLP)
		aSaldoFim := SaldoTotCQ("CTH",/*@cContaIni*/,/*@cContaFim*/,@cCustoIni,@cCustoFim,@cItemIni,@cItemFim,@cCLVLIni,@cCLVLFim,@dDataFim,;
			@cMoeda,@cTpSald,@lImpAntLP,@dDataLP)

	ElseIf lTemItem
		// SALDO DA CLASSE DE VALORES + ITEM CONTABIL = CTX
		aSaldoIni := SaldoTotCQ("CTH",/*@cContaIni*/,/*@cContaFim*/,/*@cCustoIni*/,/*@cCustoFim*/,@cItemIni,@cItemFim,@cCLVLIni,@cCLVLFim,@dDataIni,;
			@cMoeda,@cTpSald,@lImpAntLP,@dDataLP)
		aSaldoFim := SaldoTotCQ("CTH",/*@cContaIni*/,/*@cContaFim*/,/*@cCustoIni*/,/*@cCustoFim*/,@cItemIni,@cItemFim,@cCLVLIni,@cCLVLFim,@dDataFim,;
			@cMoeda,@cTpSald,@lImpAntLP,@dDataLP)

	ElseIf lTemCusto
		// SALDO DA CLASSE DE VALORES + CENTRO DE CUSTO = CTW
		aSaldoIni := SaldoTotCQ("CTH",/*@cContaIni*/,/*@cContaFim*/,@cCustoIni,@cCustoFim,/*@cItemIni*/,/*@cItemFim*/,@cCLVLIni,@cCLVLFim,@dDataIni,;
			@cMoeda,@cTpSald,@lImpAntLP,@dDataLP)
		aSaldoFim := SaldoTotCQ("CTH",/*@cContaIni*/,/*@cContaFim*/,@cCustoIni,@cCustoFim,/*@cItemIni*/,/*@cItemFim*/,@cCLVLIni,@cCLVLFim,@dDataFim,;
			@cMoeda,@cTpSald,@lImpAntLP,@dDataLP)

	Else
		// SALDO SOMENTE DA CLASSE DE VALORES = CTU
		aSaldoIni := SaldoTotCQ("CTH",/*@cContaIni*/,/*@cContaFim*/,/*@cCustoIni*/,/*@cCustoFim*/,/*@cItemIni*/,/*@cItemFim*/,@cCLVLIni,@cCLVLFim,@dDataIni,;
			@cMoeda,@cTpSald,@lImpAntLP,@dDataLP)
		aSaldoFim := SaldoTotCQ("CTH",/*@cContaIni*/,/*@cContaFim*/,/*@cCustoIni*/,/*@cCustoFim*/,/*@cItemIni*/,/*@cItemFim*/,@cCLVLIni,@cCLVLFim,@dDataFim,;
			@cMoeda,@cTpSald,@lImpAntLP,@dDataLP)
	Endif
ElseIf lTemItem
	If lTemCusto
		// SALDO DO ITEM CONTABIL + CENTRO DE CUSTO = CTV
		aSaldoIni := SaldoTotCQ("CTD",/*@cContaIni*/,/*@cContaFim*/,@cCustoIni,@cCustoFim,@cItemIni,@cItemFim,/*@cCLVLIni*/,/*@cCLVLFim*/,@dDataIni,;
			@cMoeda,@cTpSald,@lImpAntLP,@dDataLP)
		aSaldoFim := SaldoTotCQ("CTD",/*@cContaIni*/,/*@cContaFim*/,@cCustoIni,@cCustoFim,@cItemIni,@cItemFim,/*@cCLVLIni*/,/*@cCLVLFim*/,@dDataFim,;
			@cMoeda,@cTpSald,@lImpAntLP,@dDataLP)

	Else
		aSaldoIni := SaldoTotCQ("CTD",/*@cContaIni*/,/*@cContaFim*/,/*@cCustoIni*/,/*@cCustoFim*/,@cItemIni,@cItemFim,/*@cCLVLIni*/,/*@cCLVLFim*/,@dDataIni,;
			@cMoeda,@cTpSald,@lImpAntLP,@dDataLP)
		aSaldoFim := SaldoTotCQ("CTD",/*@cContaIni*/,/*@cContaFim*/,/*@cCustoIni*/,/*@cCustoFim*/,@cItemIni,@cItemFim,/*@cCLVLIni*/,/*@cCLVLFim*/,@dDataFim,;
			@cMoeda,@cTpSald,@lImpAntLP,@dDataLP)
	Endif
ElseIf lTemCusto
	// SALDO SOMENTE DO CENTRO DE CUSTO = CTU
	aSaldoIni := SaldoTotCQ("CTT",/*@cContaIni*/,/*@cContaFim*/,/*@cCustoIni*/,/*@cCustoFim*/,/*@cItemIni*/,/*@cItemFim*/,/*@cCLVLIni*/,/*@cCLVLFim*/,@dDataIni,;
		@cMoeda,@cTpSald,@lImpAntLP,@dDataLP)
	aSaldoFim := SaldoTotCQ("CTT",/*@cContaIni*/,/*@cContaFim*/,/*@cCustoIni*/,/*@cCustoFim*/,/*@cItemIni*/,/*@cItemFim*/,/*@cCLVLIni*/,/*@cCLVLFim*/,@dDataFim,;
		@cMoeda,@cTpSald,@lImpAntLP,@dDataLP)
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                        ≥
//≥ [1] Movimento Devedor 	                        ≥
//≥ [2] Movimento Credor		                    ≥
//≥ [3] Movimento do Mes		                    ≥
//≥ [4] Saldo Final                                	≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
nDebito		:= aSaldoFim[4] - aSaldoIni[7]
nCredito	:= aSaldoFim[5] - aSaldoIni[8]

aMovimento 	:= {nDebito,nCredito,nCredito-nDebito,aSaldoFim[1]}


Return(aMovimento[nQualSaldo])

//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCTY
Saldo da Classe de Valor + Item + C.Custo

Redirecionada para a rotina SaldoCQ

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function SaldoCTY(cClasseVlr,cItem,cCusto,dData,cMoeda,cTpSald,cRotina)

Local aRet := {}

aRet := SaldoCQ("CTH",/*cConta*/,@cCusto,@cItem,@cClasseVlr,/*cIdent*/,@dData,@cMoeda,@cTpSald,@cRotina,.F.)

Return aRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥CtPlGerSld ≥ Autor ≥ Simone Mie Sato       ≥ Data ≥ 11.07.02 		     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Plano Gerencial para Comparativos de 1 Entidade             			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥CtPlGerSld(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook) ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Nenhum                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                  			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpO1 = Objeto oMeter                     	                 		 ≥±±
±±≥          ≥ ExpO2 = Objeto oText                      	                 		 ≥±±
±±≥          ≥ ExpO3 = Objeto oDlg                       	                 		 ≥±±
±±≥          ≥ ExpL1 = Acao do CodeBlock                 	                 		 ≥±±
±±≥          ≥ ExpD1 = Data Inicial                      	                 		 ≥±±
±±≥          ≥ ExpD2 = Data Final                        	                 		 ≥±±
±±≥          ≥ ExpC1 = Moeda                              	                 		 ≥±±
±±≥          ≥ ExpA1 = Array Set Of Book                  	                 		 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CtPlGerSld(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,;
					cAlias,cIdent,lImpAntLP,dDataLP,cTpSld1,cTpSld2,cMoedCmp,bVariacao,;
					nQualSaldo,nDivide)

Local aSaveArea := GetArea()
Local aSaldoAnt1
Local aSaldoAnt2
Local aSaldoAtu1
Local aSaldoAtu2

Local cConta
Local cCodNor
Local cNormal
Local cContaSup
Local cDesc
Local cPlanGer := aSetOfBook[5]
Local cContaIni	:= Space(Len(Criavar("CT1_CONTA")))
Local cContaFim	:= Repl("Z",Len(Criavar("CT1_CONTA")))
Local cCustoIni	:= Space(Len(Criavar("CTT_CUSTO")))
Local cCustoFim	:= Repl("Z",Len(Criavar("CTT_CUSTO")))
Local cItemIni	:= Space(Len(Criavar("CTD_ITEM")))
Local cItemFim	:= Repl("Z",Len(Criavar("CTD_ITEM")))
Local cClvlIni	:= Space(Len(Criavar("CTH_CLVL")))
Local cClVlFim	:= Repl("Z",Len(Criavar("CTH_CLVL")))

Local lConta 	:= .F.
Local lCusto	:= .F.
Local lItem		:= .F.
Local lClasse	:= .F.
Local lIgual

Local nReg
Local nDebito1	:= 0
Local nDebito2	:= 0
Local nCredito1	:= 0
Local nCredito2	:= 0
Local nMovim1	:= 0
Local nMovim2	:= 0
Local aContas	:= {}
Local nPos		:= 0
Local nFator	:= 0

Default nDivide := 1

cAlias	:= Iif(cAlias == Nil,"",cAlias)
cIdent	:= Iif(cIdent == Nil,"",cIdent)
cMoedCmp := Iif(cMoedCmp == Nil,cMoeda,cMoedCmp)

If ValType(oMeter) == "O"
	oMeter:nTotal := CTS->(RecCount())
Endif

dbSelectArea("CTS")
dbSetOrder(1)

MsSeek(xFilial()+cPlanGer,.T.)

While !Eof() .And. 	CTS->CTS_FILIAL == xFilial() .And.;
					CTS->CTS_CODPLA == cPlanGer

	If CTS->CTS_CLASSE == "1"
		dbSkip()
		Loop
	EndIf

	// Recarrega vari·veis
	lConta 	:= .F.
	lCusto	:= .F.
	lItem	:= .F.
	lClasse	:= .F.

	// Grava conta analitica
	cConta 	:= CTS->CTS_CONTAG
	cDesc	:= CTS->CTS_DESCCG
	cOrdem	:= CTS->CTS_ORDEM

	nDebito1	:= 0
	nCredito1	:= 0
	nMovim1 	:= 0
	nDebito2	:= 0
	nCredito2	:= 0
	nMovim2		:= 0

	dbSelectArea("cArqTmp")
	dbSetOrder(1)
	If !MsSeek(xFilial()+cConta) .Or. (CTS->CTS_IDENT = "5" .Or. CTS->CTS_CLASSE="3")
		dbAppend()
		Replace CONTA 		With cConta
		Replace DESCCTA    	With cDesc
		Replace TIPOCONTA 	With CTS->CTS_CLASSE
		Replace NORMAL    	With CTS->CTS_NORMAL
		Replace ORDEM		With CTS->CTS_ORDEM
		Replace FILIAL		With CTS->CTS_FILIAL
		Replace TOTVIS 		With CTS->CTS_TOTVIS
		Replace VISENT 		With CTS->CTS_VISENT
		Replace SLDENT 		With CTS->CTS_SLDENT
		Replace FATSLD 		With CTS->CTS_FATSLD

		//Se a classe for "Titulo" devera ser impresso somente a descricao da conta,
		//sem os valores. Da mesma forma que o Identificador igual a 5 (Separdor)
		If CTS->CTS_CLASSE = "3"
			Replace IDENTIFI	With "5"
		Else
			Replace IDENTIFI	With CTS->CTS_IDENT
		EndIf
	EndIf

	dbSelectArea("CTS")
	dbSetOrder(1)
	aContas := {}
	While !Eof() .And. CTS->CTS_FILIAL == xFilial() .And.;
						CTS->CTS_CODPLA == cPlanGer  .And. CTS->CTS_ORDEM	== cOrdem

		If (!Empty(CTS->CTS_CTHINI)	.Or. !Empty(CTS->CTS_CTHFIM))		// Saldo a partir da classe
			lClasse := .T.
			cClVlIni	:= CTS->CTS_CTHINI
			cClVlFim	:= CTS->CTS_CTHFIM
		EndIf
		If (!Empty(CTS->CTS_CTDINI) .Or. !Empty(CTS->CTS_CTDFIM))	// Saldo a partir do Item
			lItem := .T.
			cItemIni	:= CTS->CTS_CTDINI
			cItemFim	:= CTS->CTS_CTDFIM
		EndIf
		If (!Empty(CTS->CTS_CTTINI) .Or. !Empty(CTS->CTS_CTTFIM))	// Saldo a partir do C.Custo
			lCusto := .T.
			cCustoIni	:= CTS->CTS_CTTINI
			cCustoFim	:= CTS->CTS_CTTFIM
		EndIf
		If (!Empty(CTS->CTS_CT1INI) .Or. !Empty(CTS->CTS_CT1FIM))	// Saldo a partir da Conta
			lConta := .T.
			cContaIni	:= CTS->CTS_CT1INI
			cContaFim	:= CTS->CTS_CT1FIM
			Aadd(aContas, { cContaIni, cContaFim })
		EndIf

		If lConta
			aSaldoAnt1 := SaldTotCT7(cContaIni,cContaFim,dDataIni,cMoedCmp,cTpSld1,lImpAntLP,dDataLP)
			aSaldoAtu1 := SaldTotCT7(cContaIni,cContaFim,dDataFim,cMoedCmp,cTpSld1,lImpAntLP,dDataLP)
			aSaldoAnt2 := SaldTotCT7(cContaIni,cContaFim,dDataIni,cMoeda,cTpSld2,lImpAntLP,dDataLP)
			aSaldoAtu2 := SaldTotCT7(cContaIni,cContaFim,dDataFim,cMoeda,cTpSld2,lImpAntLP,dDataLP)
		EndIf

		If lCusto
			aSaldoAnt1:= SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
								cContaFim,dDataIni,cMoedCmp,cTpSld1)
			aSaldoAtu1 := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
								cContaFim,dDataFim,cMoedCmp,cTpSld1)
			aSaldoAnt2:= SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
								cContaFim,dDataIni,cMoeda,cTpSld2)
			aSaldoAtu2 := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
								cContaFim,dDataFim,cMoeda,cTpSld2)
		EndIf

		If lItem
			aSaldoAnt1 := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
								cCustoFim,cContaIni,cContaFim,;
								dDataIni,cMoedCmp,cTpSld1)
			aSaldoAtu1 := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
								cCustoFim,cContaIni,cContaFim,;
								dDataFim,cMoedCmp,cTpSld1)
			aSaldoAnt2 := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
								cCustoFim,cContaIni,cContaFim,;
								dDataIni,cMoeda,cTpSld2)
			aSaldoAtu2 := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
								cCustoFim,cContaIni,cContaFim,;
								dDataFim,cMoeda,cTpSld2)

		EndIf

		If lClasse
			aSaldoAnt1 := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
								cItemFim,cCustoIni,cCustoFim,cContaIni,;
								cContaFim,dDataIni,cMoedCmp,cTpSld1)
			aSaldoAtu1 := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
								cItemFim,cCustoIni,cCustoFim,cContaIni,;
								cContaFim,dDataFim,cMoedCmp,cTpSld1)
			aSaldoAnt2 := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
								cItemFim,cCustoIni,cCustoFim,cContaIni,;
								cContaFim,dDataIni,cMoeda,cTpSld2)
			aSaldoAtu2 := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
								cItemFim,cCustoIni,cCustoFim,cContaIni,;
								cContaFim,dDataFim,cMoeda,cTpSld2)
		EndIf

		If aSetOfBook[9] > 1	// Divisao por fator
			For nPos := 1 To Len(aSaldoAnt)
				aSaldoAnt1[nPos] := Round(NoRound((aSaldoAnt1[nPos]/aSetOfBook[9]),3),2)
				aSaldoAnt2[nPos] := Round(NoRound((aSaldoAnt2[nPos]/aSetOfBook[9]),3),2)
			Next
			For nPos := 1 To Len(aSaldoAtu)
				aSaldoAtu1[nPos] := Round(NoRound((aSaldoAtu1[nPos]/aSetOfBook[9]),3),2)
				aSaldoAtu2[nPos] := Round(NoRound((aSaldoAtu2[nPos]/aSetOfBook[9]),3),2)
			Next
		Endif

		If CTS->CTS_IDENT $ "78"	// Somo/Subtraio mostrando sinal
			If CTS->CTS_IDENT = "7" .And. ! Left(("cArqTmp")->DESC, 3) = "(+)"
				Replace ("cArqTmp")->DESC With "(+) " + ("cArqTmp")->DESC
			ElseIf CTS->CTS_IDENT = "8" .And. ! Left(("cArqTmp")->DESC, 3) = "(-)"
				Replace ("cArqTmp")->DESC With "(-) " + ("cArqTmp")->DESC
			Endif
		Endif

		// Calculos com os Fatores
		If (CTS->CTS_IDENT $ "17" .Or. CTS->CTS_IDENT $ "28") .And. (CTS->CTS_CLASSE <> "3")

			nFator := 1
			If ! Empty(CTS->CTS_FORMUL) .And. Left(CTS->CTS_FORMUL, 7) = "ROTINA="
				nFator := &(Subs(CTS->CTS_FORMUL, 8))
			Endif

			If CTS->CTS_IDENT $ "17"			// Somo os saldos
				If nQualSaldo = 1		// Movimento
					nDebito1	+= aSaldoAtu1[4] - aSaldoAnt1[7]
					nCredito1	+= aSaldoAtu1[5] - aSaldoAnt1[8]
					nMovim1		:= (( nCredito1 - nDebito1 ) * nFator )

					nDebito2	+= aSaldoAtu2[4] - aSaldoAnt2[7]
					nCredito2	+= aSaldoAtu2[5] - aSaldoAnt2[8]
					nMovim2		:= (( nCredito2 - nDebito2 ) * nFator )
				Else
					nMovim1 	+= ( aSaldoAtu1[1] * nFator )
					nMovim2  	+= ( aSaldoAtu2[1] * nFator )
				Endif
			ElseIf CTS->CTS_IDENT $ "28"		// Subtraio os saldos
				If nQualSaldo = 1		// Movimento
					nDebito1	-= aSaldoAtu1[4] - aSaldoAnt1[7]
					nCredito1	-= aSaldoAtu1[5] - aSaldoAnt1[8]
					nMovim1		:= (( nCredito1 - nDebito1 ) * nFator )

					nDebito2	-= aSaldoAtu2[4] - aSaldoAnt2[7]
					nCredito2	-= aSaldoAtu2[5] - aSaldoAnt2[8]
					nMovim2		:= (( nCredito2 - nDebito2 ) * nFator )
				Else
					nMovim1 	+= ( aSaldoAtu1[1] * nFator )
					nMovim2  	+= ( aSaldoAtu2[1] * nFator )
				Endif
			EndIf
		EndIf

		dbSelectArea("CTS")
		dbSetOrder(1)
		nReg := Recno()
		dbSkip()
	EnddO

	dbSelectArea("CTS")
	dbSetOrder(2)
	dbGoTo(nReg)
	cCodNor := CTS->CTS_NORMAL

	If nDivide > 1
		nMovim1 := nMovim1 / nDivide
		nMovim2 := nMovim2 / nDivide
	EndIf

	dbSelectArea("cArqTmp")
	Replace MOVIMENTO1	With MOVIMENTO1 + nMovim1
	Replace MOVIMENTO2	With MOVIMENTO2 + nMovim2
	Replace VARIACAO With (MOVIMENTO1/MOVIMENTO2) *100

	If bVariacao <> Nil
		Eval(bVariacao, .T., aContas)
	Endif

	dbSelectArea("CTS")
	dbSetOrder(2)
	// Grava contas sinteticas
	If !Empty(CTS->CTS_CTASUP)
		While !Eof() .And. 	CTS->CTS_FILIAL == xFilial() .And. ;
								CTS->CTS_CODPLA == cPlanGer

			cContaSup 	:= CTS->CTS_CTASUP
			lIgual		:= CTS->CTS_IDENT = "9"

			dbSelectArea("CTS")
			dbSetOrder(2)
			If MsSeek(xFilial()+cPlanGer+cContaSup)
				cDesc 	:= CTS->CTS_DESCCG
				cNormal := CTS->CTS_NORMAL
			Else
				cNormal	:= cCodNor
			EndIf

			dbSelectArea("cArqTmp")

			If lIgual .And. ! Left(DESCCTA, 3) = "(=)"
				Replace DESCCTA With "(=) " + DESCCTA
			Endif

			dbSetOrder(1)
			If !MsSeek(cContaSup)
				dbAppend()
				Replace CONTA	With cContaSup
				Replace DESCCTA With cDesc
				Replace TIPOCONTA	With CTS->CTS_CLASSE
				Replace NORMAL   	With CTS->CTS_NORMAL
				Replace ORDEM		With CTS->CTS_ORDEM
				Replace IDENTIFI	With CTS->CTS_IDENT
				Replace FILIAL		With CTS->CTS_FILIAL

				If CTS->( FieldPos( "CTS_TOTVIS" ) ) > 0
					Replace TOTVIS 		With CTS->CTS_TOTVIS
				EndIf

				If CTS->( FieldPos( "CTS_VISENT" ) ) > 0
					Replace VISENT 		With CTS->CTS_VISENT
				EndIf

				If CTS->( FieldPos( "CTS_SLDENT" ) ) > 0
					Replace SLDENT 		With CTS->CTS_SLDENT
				EndIf

				If CTS->( FieldPos( "CTS_FATSLD" ) ) > 0
					Replace FATSLD 		With CTS->CTS_FATSLD
				EndIf
			EndIf

			Replace	MOVIMENTO1 With MOVIMENTO1 + nMovim1			// Movimento Coluna 1
			Replace MOVIMENTO2 With MOVIMENTO2 + nMovim2			// Movimento Coluna 2
			Replace VARIACAO With (MOVIMENTO1/MOVIMENTO2) *100

			If bVariacao <> Nil
				Eval(bVariacao, .T.)
			Endif

			dbSelectArea("CTS")
			If !Eof() .And. Empty(CTS->CTS_CTASUP)
				dbSelectArea("cArqTmp")
				Replace NIVEL1 With .T.
				dbSelectArea("CTS")
				Exit
			EndIf
		EndDo
	EndIf


	dbSelectArea("CTS")
	dbSetOrder(1)
	dbGoTo(nReg)
	dbSkip()

EndDo

RestArea(aSaveArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥CtPlEntGer ≥ Autor ≥ Simone Mie Sato       ≥ Data ≥ 23.05.05 		     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Retorna Array com o set of book                             			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥CTPlEntGer(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook) ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Nenhum                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                  			 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpO1 = Objeto oMeter                     	                 		 ≥±±
±±≥          ≥ ExpO2 = Objeto oText                      	                 		 ≥±±
±±≥          ≥ ExpO3 = Objeto oDlg                       	                 		 ≥±±
±±≥          ≥ ExpL1 = Acao do CodeBlock                 	                 		 ≥±±
±±≥          ≥ ExpD1 = Data Inicial                      	                 		 ≥±±
±±≥          ≥ ExpD2 = Data Final                        	                 		 ≥±±
±±≥          ≥ ExpC1 = Moeda                              	                 		 ≥±±
±±≥          ≥ ExpA1 = Array Set Of Book                  	                 		 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CtPlEntGer(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,;
					cAlias,cHeader,lImpAntLP,dDataLP,lVlrZerado,cEntidIni,cEntidFim,;
					cEntGerIni,cEntGerFim,cCCIni,cCCFim,cItemIni,cItemFim,cClVlIni,cClVlFim,;
					lImpSint,lRecDesp0,cRecDesp,dDtZeraRD,nDivide,lFiltraCC,lFiltraIt,lFiltraCv,;
					cSaldos )

Local aSaveArea := GetArea()
Local aSaldoAnt	:= {}
Local aSaldoAtu	:= {}

Local cFilCTS	:= xFilial("CTS")
Local cPlanGer	:= aSetOfBook[5]
Local cDescEnt	:= ""

Local cCodNor	:= ""
Local cChave	:= ""
Local cConta 	:= ""
Local cDesc		:= ""
Local cDescS 	:= ""
Local cOrdem	:= ""
Local cCpoCod	:= ""
Local cCodRes	:= ""
Local cContaIni	:= ""
Local cContaFim	:= ""
Local cTpSaldo	:= ""
Local cCCOfiIni	:= cCCIni
Local cCCOfiFim	:= cCCFim
Local cItOfiIni	:= cItemIni
Local cItOfiFim	:= cItemFim
Local cCVOfiIni	:= cClVlIni
Local cCVOfiFim	:= cClVlFim

Local nPos			:= 0
Local nNivel		:= 0
Local nReg			:= 0
Local nRegCTS		:= 0
Local nSaldoAnt 	:= 0
Local nSaldoDeb 	:= 0
Local nSaldoCrd 	:= 0
Local nSaldoAtu 	:= 0
Local nSaldoAntD	:= 0
Local nSaldoAntC	:= 0
Local nSaldoAtuD	:= 0
Local nSaldoAtuC	:= 0
Local nLSldAnt		:= 0
Local nLSldAtu		:= 0

Local lComNivel 	:= FieldPos("NIVEL") > 0		// Nivel hierarquico
Local aRet			:= {.T.,"","","","","",""}
Local lFiltraEnt	:= IIf(ExistBlock("FILTRAENT"),.T.,.F.)

Local aCpos			:= {'CT0_ALIAS','CT0_CPOCHV','CT0_CPODSC','CT0_ENTIDA'}
Local aDados		:= Nil
Local cCpoDesc		:= ""
Local cPlano		:= ""

Local cEnt05Ini		:= ""
Local cEnt06Ini		:= ""
Local cEnt07Ini		:= ""
Local cEnt08Ini		:= ""
Local cEnt09Ini		:= ""

Local cEnt05Fim		:= ""
Local cEnt06Fim		:= ""
Local cEnt07Fim		:= ""
Local cEnt08Fim		:= ""
Local cEnt09Fim		:= ""

Local cCodEntidade	:= ""
Local bBlWhile
Local aEntidIni		:= {}
Local aEntidFim		:= {}
Local aSelFil		:= {cFilAnt}

Local aIndexes
Local nIndex		:= 1

DEFAULT cSaldos		:= " "
DEFAULT nDivide     := 1

If FindFunction("CTBEntGtIn")
	aIndexes := CTBEntGtIn()
Else
	aIndexes := {{1, 5},{1, 5},{1, 5},{1, 5},{1, 3},{1, 3},{1, 3},{1, 3},{1, 3}}
EndIf

If cHeader	== "CTT"
	cCpoCod	:= "CUSTO"
ElseIf cHeader == "CTD"
	cCpoCod	:= "ITEM"
ElseIf cHeader == "CTH"
	cCpoCod	:= "CLVL"
ElseIf "CUBO" $ cHeader
	cCodEntidade := Right(cHeader,2)
	aDados 	 := GetAdvFval('CT0',aCpos,xFilial('CT0') + cCodEntidade ,1 )
	cHeader	 := Alltrim(aDados[1])
	cCpoCod	 := Alltrim(StrTran(aDados[2],cHeader+"_",""))
	cCpoDesc := Alltrim(StrTran(aDados[3],cHeader+"_",""))
	cPlano	 := Alltrim(aDados[4])
	nIndex   := aIndexes[Val(cCodEntidade)][1]
EndIf

dbSelectArea("CTS")
If ValType(oMeter) == "O"
	oMeter:nTotal := CTS->(RecCount())
EndIf
dbSetOrder(1)

MsSeek(cFilCTS+cPlanGer,.T.)

While !Eof() .And. 	CTS->CTS_FILIAL == cFilCTS .And.;
					CTS->CTS_CODPLA == cPlanGer

	If CTS->CTS_CLASSE == "1"
		dbSkip()
		Loop
	EndIf

	//Efetua o filtro dos parametros considerando o plano gerencial.
	If !Empty(cEntGerIni) .Or. !Empty(cEntGerFim)
		If CTS->CTS_CONTAG < cEntGerIni .Or. CTS->CTS_CONTAG > cEntGerFim
			dbSkip()
			Loop
		EndIf
	EndIf

	If lFiltraEnt

		cCCIni		:= cCCOfiIni
		cCCFim		:= cCCOfiFim
		cItemIni	:= cItOfiIni
		cItemFim	:= cItOfiFim
		cClVlIni	:= cCVOfiIni
		cClVlFim	:= cCVOfiFim

		aRet	:= ExecBlock("FILTRAENT",.F.,.F.,{cHeader,lFiltraCC,lFiltraIt,lFiltraCV,cCCIni,cCCFim,cItemIni,cItemFim,cClVlIni,cClVlFim})

		If !aRet[1]
			dbSkip()
			Loop
		Else
			cCCIni		:= aRet[2]
			cCCFim		:= aRet[3]
			cItemIni	:= aRet[4]
			cItemFim	:= aRet[5]
			cClVlIni	:= aRet[6]
			cClVlFim	:= aRet[7]
		EndIf
	EndIf

	// Grava conta analitica
	cConta 	:= CTS->CTS_CONTAG
	cDesc	:= CTS->CTS_DESCCG
	cOrdem	:= CTS->CTS_ORDEM

	nSaldoAnt 	:= 0	// Zero as variaveis para acumular
	nSaldoDeb 	:= 0
	nSaldoCrd 	:= 0

	nSaldoAtu 	:= 0
	nSaldoAntD	:= 0
	nSaldoAntC	:= 0
	nSaldoAtuD	:= 0
	nSaldoAtuC	:= 0

	dbSelectArea(cHeader)
	dbSetOrder(nIndex)
	If cHeader == 'CV0'
		MsSeek(xFilial()+cPlano+cEntidIni,.T.)
		bBlWhile := {|| (cHeader)->&((cHeader)+"_FILIAL") == xFilial(cHeader) .And. ;
							 (cHeader)->&((cHeader)+"_"+cCpoCod) <= cEntidFim .And. (cHeader)->&((cHeader)+"_PLANO") == cPlano }
	Else
		MsSeek(xFilial()+cEntidIni,.T.)
		bBlWhile := {|| (cHeader)->&((cHeader)+"_FILIAL") == xFilial(cHeader) .And. (cHeader)->&((cHeader)+"_"+cCpoCod) <= cEntidFim }
	EndIf

	While !Eof() .And. Eval(bBlWhile)

		If cHeader $ 'CTT.CTD.CTH.CV0'
			If (cHeader)->&((cHeader)+"_CLASSE") == "1"
				dbSkip()
				Loop
			EndIf
		EndIf

		dbSelectArea("CTS")
		dbSetOrder(1)
		MsSeek(xFilial()+cPlanGer+cOrdem)

		While !Eof() .And. CTS->CTS_FILIAL == cFilCTS .And.;
							CTS->CTS_CODPLA == cPlanGer  .And. CTS->CTS_ORDEM	== cOrdem

			aSaldoAnt	:= { 0, 0, 0, 0, 0, 0, 0, 0 }
			aSaldoAtu	:= { 0, 0, 0, 0, 0, 0, 0, 0 }

			/*
			⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			≥ TRATATIVA DE TIPO DE SALDO NOS RELATORIOS DE DEMONSTRA-≥
			≥ TIVOS (CTBR5XX)                                        ≥
			¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			*/

			// Tipo de saldo configurado na vis„o gerencial
			cTpSaldo := Alltrim( CTS->CTS_TPSALD )

			// Caso o Tipo de saldo estiver configurado na vis„o gerencial com asterisco
			// ou a rotina chamadora consolida os tipos de saldos, considero os parametros da tela (SX1)
			If cTpSaldo == "*" .And. cSaldos <> "*"
				cTpSaldo := cSaldos
			EndIf

			If cCodEntidade == "09"
				cEnt09Ini	:= (cHeader)->&(PrefixoCpo(cHeader)+"_"+cCpoCod)
				cEnt09Fim	:= (cHeader)->&(PrefixoCpo(cHeader)+"_"+cCpoCod)

				If CTS->( FieldPos( "CTS_E08INI" ) ) > 0 .And. CTS->( FieldPos( "CTS_E08FIM" ) ) > 0
					cEnt08Ini	:= CTS->CTS_E08INI
					cEnt08Fim	:= CTS->CTS_E08FIM
				EndIf

				If CTS->( FieldPos( "CTS_E07INI" ) ) > 0 .And. CTS->( FieldPos( "CTS_E07FIM" ) ) > 0
					cEnt07Ini	:= CTS->CTS_E07INI
					cEnt07Fim	:= CTS->CTS_E07FIM
				EndIf

				If CTS->( FieldPos( "CTS_E06INI" ) ) > 0 .And. CTS->( FieldPos( "CTS_E06FIM" ) ) > 0
					cEnt06Ini	:= CTS->CTS_E06INI
					cEnt06Fim	:= CTS->CTS_E06FIM
				EndIf

				If CTS->( FieldPos( "CTS_E05INI" ) ) > 0 .And. CTS->( FieldPos( "CTS_E05FIM" ) ) > 0
					cEnt05Ini	:= CTS->CTS_E05INI
					cEnt05Fim	:= CTS->CTS_E05FIM
				EndIf

				cClVlIni	:= CTS->CTS_CTHINI
				cClVlFim	:= CTS->CTS_CTHFIM

				cItemIni	:= CTS->CTS_CTDINI
				cItemFim	:= CTS->CTS_CTDFIM

				cCCIni		:= CTS->CTS_CTTINI
				cCCFim		:= CTS->CTS_CTTFIM

				cContaIni	:= CTS->CTS_CT1INI
				cContaFim	:= CTS->CTS_CT1FIM

				cCodRes		:= ""
				cDescEnt	:= GetAdvFval(cHeader,cCpoDesc,xFilial(cHeader)+cEnt09Ini,1)

				aEntidIni	:= {}
				aEntidFim	:= {}

				AADD( aEntidIni,cContaIni)
				AADD( aEntidIni,cCCIni)
				AADD( aEntidIni,cItemIni)
				AADD( aEntidIni,cClVlIni)
				AADD( aEntidIni,cEnt05Ini)
				AADD( aEntidIni,cEnt06Ini)
				AADD( aEntidIni,cEnt07Ini)
				AADD( aEntidIni,cEnt08Ini)
				AADD( aEntidIni,cEnt09Ini)

				AADD( aEntidFim,cContaFim)
				AADD( aEntidFim,cCCFim)
				AADD( aEntidFim,cItemFim)
				AADD( aEntidFim,cClVlFim)
				AADD( aEntidFim,cEnt05Fim)
				AADD( aEntidFim,cEnt06Fim)
				AADD( aEntidFim,cEnt07Fim)
				AADD( aEntidFim,cEnt08Fim)
				AADD( aEntidFim,cEnt09Fim)

			ElseIf cCodEntidade == "08"
				cEnt08Ini	:= (cHeader)->&(PrefixoCpo(cHeader)+"_"+cCpoCod)
				cEnt08Fim	:= (cHeader)->&(PrefixoCpo(cHeader)+"_"+cCpoCod)

				If CTS->( FieldPos( "CTS_E07INI" ) ) > 0 .And. CTS->( FieldPos( "CTS_E07FIM" ) ) > 0
					cEnt07Ini	:= CTS->CTS_E07INI
					cEnt07Fim	:= CTS->CTS_E07FIM
				EndIf

				If CTS->( FieldPos( "CTS_E06INI" ) ) > 0 .And. CTS->( FieldPos( "CTS_E06FIM" ) ) > 0
					cEnt06Ini	:= CTS->CTS_E06INI
					cEnt06Fim	:= CTS->CTS_E06FIM
				EndIf

				If CTS->( FieldPos( "CTS_E05INI" ) ) > 0 .And. CTS->( FieldPos( "CTS_E05FIM" ) ) > 0
					cEnt05Ini	:= CTS->CTS_E05INI
					cEnt05Fim	:= CTS->CTS_E05FIM
				EndIf

				cItemIni	:= CTS->CTS_CTDINI
				cItemFim	:= CTS->CTS_CTDFIM

				cCCIni		:= CTS->CTS_CTTINI
				cCCFim		:= CTS->CTS_CTTFIM

				cContaIni	:= CTS->CTS_CT1INI
				cContaFim	:= CTS->CTS_CT1FIM

				cCodRes		:= ""
				cDescEnt	:= GetAdvFval(cHeader,cCpoDesc,xFilial(cHeader)+cEnt08Ini,1)

				aEntidIni	:= {}
				aEntidFim	:= {}

				AADD( aEntidIni,cContaIni)
				AADD( aEntidIni,cCCIni)
				AADD( aEntidIni,cItemIni)
				AADD( aEntidIni,cClVlIni)
				AADD( aEntidIni,cEnt05Ini)
				AADD( aEntidIni,cEnt06Ini)
				AADD( aEntidIni,cEnt07Ini)
				AADD( aEntidIni,cEnt08Ini)

				AADD( aEntidFim,cContaFim)
				AADD( aEntidFim,cCCFim)
				AADD( aEntidFim,cItemFim)
				AADD( aEntidFim,cClVlFim)
				AADD( aEntidFim,cEnt05Fim)
				AADD( aEntidFim,cEnt06Fim)
				AADD( aEntidFim,cEnt07Fim)
				AADD( aEntidFim,cEnt08Fim)

			ElseIf cCodEntidade == "07"
				cEnt07Ini	:= (cHeader)->&(PrefixoCpo(cHeader)+"_"+cCpoCod)
				cEnt07Fim	:= (cHeader)->&(PrefixoCpo(cHeader)+"_"+cCpoCod)

				If CTS->( FieldPos( "CTS_E06INI" ) ) > 0 .And. CTS->( FieldPos( "CTS_E06FIM" ) ) > 0
					cEnt06Ini	:= CTS->CTS_E06INI
					cEnt06Fim	:= CTS->CTS_E06FIM
				EndIf

				If CTS->( FieldPos( "CTS_E05INI" ) ) > 0 .And. CTS->( FieldPos( "CTS_E05FIM" ) ) > 0
					cEnt05Ini	:= CTS->CTS_E05INI
					cEnt05Fim	:= CTS->CTS_E05FIM
				EndIf

				cItemIni	:= CTS->CTS_CTDINI
				cItemFim	:= CTS->CTS_CTDFIM

				cCCIni		:= CTS->CTS_CTTINI
				cCCFim		:= CTS->CTS_CTTFIM

				cContaIni	:= CTS->CTS_CT1INI
				cContaFim	:= CTS->CTS_CT1FIM

				cCodRes		:= ""
				cDescEnt	:= GetAdvFval(cHeader,cCpoDesc,xFilial(cHeader)+cEnt07Ini,1)

				aEntidIni	:= {}
				aEntidFim	:= {}

				AADD( aEntidIni,cContaIni)
				AADD( aEntidIni,cCCIni)
				AADD( aEntidIni,cItemIni)
				AADD( aEntidIni,cClVlIni)
				AADD( aEntidIni,cEnt05Ini)
				AADD( aEntidIni,cEnt06Ini)
				AADD( aEntidIni,cEnt07Ini)

				AADD( aEntidFim,cContaFim)
				AADD( aEntidFim,cCCFim)
				AADD( aEntidFim,cItemFim)
				AADD( aEntidFim,cClVlFim)
				AADD( aEntidFim,cEnt05Fim)
				AADD( aEntidFim,cEnt06Fim)
				AADD( aEntidFim,cEnt07Fim)

			ElseIf cCodEntidade == "06"
				cEnt06Ini	:= (cHeader)->&(PrefixoCpo(cHeader)+"_"+cCpoCod)
				cEnt06Fim	:= (cHeader)->&(PrefixoCpo(cHeader)+"_"+cCpoCod)

				If CTS->( FieldPos( "CTS_E05INI" ) ) > 0 .And. CTS->( FieldPos( "CTS_E05FIM" ) ) > 0
					cEnt05Ini	:= CTS->CTS_E05INI
					cEnt05Fim	:= CTS->CTS_E05FIM
				EndIf

				cItemIni	:= CTS->CTS_CTDINI
				cItemFim	:= CTS->CTS_CTDFIM

				cCCIni		:= CTS->CTS_CTTINI
				cCCFim		:= CTS->CTS_CTTFIM

				cContaIni	:= CTS->CTS_CT1INI
				cContaFim	:= CTS->CTS_CT1FIM

				cCodRes		:= ""
				cDescEnt	:= GetAdvFval(cHeader,cCpoDesc,xFilial(cHeader)+cEnt06Ini,1)

				aEntidIni	:= {}
				aEntidFim	:= {}

				AADD( aEntidIni,cContaIni)
				AADD( aEntidIni,cCCIni)
				AADD( aEntidIni,cItemIni)
				AADD( aEntidIni,cClVlIni)
				AADD( aEntidIni,cEnt05Ini)
				AADD( aEntidIni,cEnt06Ini)

				AADD( aEntidFim,cContaFim)
				AADD( aEntidFim,cCCFim)
				AADD( aEntidFim,cItemFim)
				AADD( aEntidFim,cClVlFim)
				AADD( aEntidFim,cEnt05Fim)
				AADD( aEntidFim,cEnt06Fim)

			ElseIf cCodEntidade == "05"
				cEnt05Ini	:= (cHeader)->&(PrefixoCpo(cHeader)+"_"+cCpoCod)
				cEnt05Fim	:= (cHeader)->&(PrefixoCpo(cHeader)+"_"+cCpoCod)

				cItemIni	:= CTS->CTS_CTDINI
				cItemFim	:= CTS->CTS_CTDFIM

				cCCIni		:= CTS->CTS_CTTINI
				cCCFim		:= CTS->CTS_CTTFIM

				cContaIni	:= CTS->CTS_CT1INI
				cContaFim	:= CTS->CTS_CT1FIM

				cCodRes		:= ""
				cDescEnt	:= GetAdvFval(cHeader,cCpoDesc,xFilial(cHeader)+cEnt05Ini,1)

				aEntidIni	:= {}
				aEntidFim	:= {}

				AADD( aEntidIni,cContaIni)
				AADD( aEntidIni,cCCIni)
				AADD( aEntidIni,cItemIni)
				AADD( aEntidIni,cClVlIni)
				AADD( aEntidIni,cEnt05Ini)

				AADD( aEntidFim,cContaFim)
				AADD( aEntidFim,cCCFim)
				AADD( aEntidFim,cItemFim)
				AADD( aEntidFim,cClVlFim)
				AADD( aEntidFim,cEnt05Fim)

			ElseIf cHeader == "CTH"
				cClVlIni	:= (cHeader)->&((cHeader)+"_"+cCpoCod)
				cClVlFim	:= (cHeader)->&((cHeader)+"_"+cCpoCod)
				If !lFiltraIt		//Se nao considera o filtro das perguntas
					cItemIni	:= CTS->CTS_CTDINI
					cItemFim	:= CTS->CTS_CTDFIM
				EndIf
				If !lFiltraCC		//Se nao considera o filtro das perguntas
					cCCIni	:= CTS->CTS_CTTINI
					cCCFim	:= CTS->CTS_CTTFIM
				EndIf
				cContaIni	:= CTS->CTS_CT1INI
				cContaFim	:= CTS->CTS_CT1FIM
				cCodRes		:= CTH->CTH_RES
				cDescEnt	:= &("CTH->CTH_DESC"+cMoeda)
				If Empty(cDescEnt)
					cDescEnt	:= CTH->CTH_DESC01
				EndIf
			ElseIf cHeader == "CTD"
				If !lFiltraCV		//Se nao considera o filtro das perguntas
					cClVlIni	:= CTS->CTS_CTHINI
					cClVlFim	:= CTS->CTS_CTHFIM
				EndIf
				cItemIni	:= (cHeader)->&((cHeader)+"_"+cCpoCod)
				cItemFim	:= (cHeader)->&((cHeader)+"_"+cCpoCod)
				If !lFiltraCC		//Se nao considera o filtro das perguntas
					cCCIni  := CTS->CTS_CTTINI
					cCCFim  := CTS->CTS_CTTFIM
				EndIf
				cContaIni	:= CTS->CTS_CT1INI
				cContaFim	:= CTS->CTS_CT1FIM
				cCodRes		:= CTD->CTD_RES
				cDescEnt	:= &("CTD->CTD_DESC"+cMoeda)
				If Empty(cDescEnt)
					cDescEnt	:= CTD->CTD_DESC01
				EndIf
			ElseIf cHeader == "CTT"
				If !lFiltraCV		//Se nao considera o filtro das perguntas
					cClVlIni	:= CTS->CTS_CTHINI
					cClVlFim	:= CTS->CTS_CTHFIM
				EndIf
				If !lFiltraIt		//Se nao considera o filtro das perguntas
					cItemIni	:= CTS->CTS_CTDINI
					cItemFim	:= CTS->CTS_CTDFIM
				EndIf
				cCCIni  	:= (cHeader)->&((cHeader)+"_"+cCpoCod)
				cCCFim   	:= (cHeader)->&((cHeader)+"_"+cCpoCod)
				cContaIni	:= CTS->CTS_CT1INI
				cContaFim	:= CTS->CTS_CT1FIM
				cCodRes		:= CTT->CTT_RES
				cDescEnt	:= &("CTT->CTT_DESC"+cMoeda)
				If Empty(cDescEnt)
					cDescEnt	:= CTT->CTT_DESC01
				EndIf
			EndIf

			If !Empty(cEnt09Ini) .Or. !Empty(cEnt09Fim)

				aSaldoAnt := CtbSldCubo(aEntidIni,aEntidFim,dDataIni,Ctod("//"),cMoeda,cTpSaldo,aSelFil)

				aSaldoAtu := CtbSldCubo(aEntidIni,aEntidFim,dDataFim,Ctod("//"),cMoeda,cTpSaldo,aSelFil)

			ElseIf !Empty(cEnt08Ini) .Or. !Empty(cEnt08Fim)

				aSaldoAnt := CtbSldCubo(aEntidIni,aEntidFim,dDataIni,Ctod("//"),cMoeda,cTpSaldo,aSelFil)

				aSaldoAtu := CtbSldCubo(aEntidIni,aEntidFim,dDataFim,Ctod("//"),cMoeda,cTpSaldo,aSelFil)

			ElseIf !Empty(cEnt07Ini) .Or. !Empty(cEnt07Fim)

				aSaldoAnt := CtbSldCubo(aEntidIni,aEntidFim,dDataIni,Ctod("//"),cMoeda,cTpSaldo,aSelFil)

				aSaldoAtu := CtbSldCubo(aEntidIni,aEntidFim,dDataFim,Ctod("//"),cMoeda,cTpSaldo,aSelFil)

			ElseIf !Empty(cEnt06Ini) .Or. !Empty(cEnt06Fim)

				aSaldoAnt := CtbSldCubo(aEntidIni,aEntidFim,dDataIni,Ctod("//"),cMoeda,cTpSaldo,aSelFil)

				aSaldoAtu := CtbSldCubo(aEntidIni,aEntidFim,dDataFim,Ctod("//"),cMoeda,cTpSaldo,aSelFil)

			ElseIf !Empty(cEnt05Ini) .Or. !Empty(cEnt05Fim)

				aSaldoAnt := CtbSldCubo(aEntidIni,aEntidFim,dDataIni,Ctod("//"),cMoeda,cTpSaldo,aSelFil)

				aSaldoAtu := CtbSldCubo(aEntidIni,aEntidFim,dDataFim,Ctod("//"),cMoeda,cTpSaldo,aSelFil)

			ElseIf !Empty(cClVlIni) .Or. !Empty(cClVlFim)
				aSaldoAnt := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
										cItemFim,cCCIni,cCCFim,cContaIni,;
										cContaFim,dDataIni,cMoeda,cTpSaldo,,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,dDataLP)

				aSaldoAtu := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
										cItemFim,cCCIni,cCCFim,cContaIni,;
										cContaFim,dDataFim,cMoeda,cTpSaldo,,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,dDataLP)
			ElseIf !Empty(cItemIni) .Or. !Empty(cItemFim)
				aSaldoAnt := SaldTotCT4(cItemIni,cItemFim,cCCIni,;
										cCCFim,cContaIni,cContaFim,;
										dDataIni,cMoeda,cTpSaldo,,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,dDataLP)

				aSaldoAtu := SaldTotCT4(cItemIni,cItemFim,cCCIni,;
										cCCFim,cContaIni,cContaFim,;
										dDataFim,cMoeda,cTpSaldo,,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,dDataLP)
			ElseIf !Empty(cCCIni) .Or. !Empty(cCCFim)
				aSaldoAnt := SaldTotCT3(cCCIni,cCCFim,cContaIni,;
										cContaFim,dDataIni,cMoeda,cTpSaldo,,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,dDataLP)
				aSaldoAtu := SaldTotCT3(cCCIni,cCCFim,cContaIni,;
										cContaFim,dDataFim,cMoeda,cTpSaldo,,lRecDesp0,cRecDesp,dDtZeraRD,lImpAntLP,dDataLP)
			ElseIf !Empty(cContaIni) .Or. !Empty(cContaFim)
				aSaldoAnt := SaldTotCT7(cContaIni,cContaFim,dDataIni,cMoeda,cTpSaldo,lImpAntLP,dDataLP,,lRecDesp0,cRecDesp,dDtZeraRD)
				aSaldoAtu := SaldTotCT7(cContaIni,cContaFim,dDataFim,cMoeda,cTpSaldo,lImpAntLP,dDataLP,,lRecDesp0,cRecDesp,dDtZeraRD)
			EndIf

			If aSetOfBook[9] > 1	// Divisao por fator
				nLSldAnt := Len(aSaldoAnt)
				nLSldAtu := Len(aSaldoAtu)
				For nPos := 1 To nLSldAnt
					aSaldoAnt[nPos] := Round(NoRound((aSaldoAnt[nPos]/aSetOfBook[9]),3),2)
				Next
				For nPos := 1 To nLSldAtu
					aSaldoAtu[nPos] := Round(NoRound((aSaldoAtu[nPos]/aSetOfBook[9]),3),2)
				Next
			Endif

			If Left(CTS->CTS_FORMUL, 7) == "ROTINA="
				nLSldAnt := Len(aSaldoAnt)
				nLSldAtu := Len(aSaldoAtu)
				nFator := &(Subs(CTS->CTS_FORMUL, 8))
				For nPos := 1 To nLSldAnt
					aSaldoAnt[nPos] *= nFator
				Next
				For nPos := 1 To nLSldAtu
					aSaldoAtu[nPos] *= nFator
				Next
			Elseif Left(CTS->CTS_FORMUL,6 ) == "SALDO="
				nLSldAnt := Len(aSaldoAnt)
				nLSldAtu := Len(aSaldoAtu)
				nFator := &(Subs(CTS->CTS_FORMUL, 7))
				For nPos := 1 To nLSldAnt
					aSaldoAnt[nPos] := nFator
				Next
				For nPos := 1 To nLSldAtu
					aSaldoAtu[nPos] := nFator
				Next
			Endif

			// Calculos com os Fatores
			If CTS->CTS_IDENT = "1"				// Somo os saldos
				nSaldoAnt 	+= aSaldoAnt[6]		// Saldo Anterior
				nSaldoAtu 	+= aSaldoAtu[1]		// Saldo Atual

				nSaldoAntD 	+= aSaldoAnt[7]
				nSaldoAntC 	+= aSaldoAnt[8]

				nSaldoAtuD 	+= aSaldoAtu[4]
				nSaldoAtuC 	+= aSaldoAtu[5]

				nSaldoDeb  	:= (nSaldoAtuD - nSaldoAntD)
				nSaldoCrd  	:= (nSaldoAtuC - nSaldoAntC)

			ElseIf CTS->CTS_IDENT = "2"			// Subtraio os saldos
				nSaldoAnt 	-= aSaldoAnt[6]		// Saldo Anterior
				nSaldoAtu 	-= aSaldoAtu[1]		// Saldo Atual

				nSaldoAntD 	-= aSaldoAnt[7]
				nSaldoAntC 	-= aSaldoAnt[8]

				nSaldoAtuD 	-= aSaldoAtu[4]
				nSaldoAtuC 	-= aSaldoAtu[5]

				nSaldoDeb  	:= (nSaldoAtuD - nSaldoAntD)
				nSaldoCrd  	:= (nSaldoAtuC - nSaldoAntC)

			EndIf

			dbSelectArea("CTS")
			dbSetOrder(1)
			nReg := Recno()
			dbSkip()
		Enddo

        nRegCTS	:= CTS->(Recno())

		dbSelectArea("CTS")
		dbSetOrder(2)
		dbGoTo(nReg)
		cCodNor := CTS->CTS_NORMAL

		If !lVlrZerado .And. (nSaldoCrd-nSaldoDeb = 0 .And. nSaldoAnt == 0 .And. nSaldoAtu == 0) .And. ;
			(nSaldoDeb = 0 .And. nSaldoCRD = 0)
			dbSelectArea(cHeader)
			dbSkip()
			Loop
	    EndIf

		dbSelectArea("cArqTmp")
		dbSetOrder(1)
		If cHeader == "CTT"
			cChave	:= cCCIni+cConta
		ElseIf cHeader == "CTD"
			cChave	:= cItemIni+cConta
		ElseIf cHeader == "CTH"
			cChave	:= cClVlIni+cConta
		ElseIf !Empty(cCodEntidade)
			cChave := &("cEnt"+cCodEntidade+"Ini")
		EndIf

		If !MsSeek(cChave)
			dbAppend()
			Do Case
			Case cHeader == 'CTT'
				Replace CUSTO 	With cCCIni
				Replace DESCCC	With cDescEnt
				Replace TIPOCC 	With CTS->CTS_CLASSE
				Replace CCRES	With cCodRes
			Case cHeader == 'CTD'
				Replace ITEM 		With cItemIni
				Replace DESCITEM    With cDescEnt
				Replace TIPOITEM	With CTS->CTS_CLASSE
				Replace ITEMRES		With cCodRes
			Case cHeader == 'CTH'
				Replace CLVL		With cClVlIni
				Replace DESCCLVL	With cDescEnt
				Replace TIPOCLVL	With CTS->CTS_CLASSE
				Replace CLVLRES		With cCodRes
			Case !Empty(cCodEntidade)
				Replace &('CODENT'+cCodEntidade)	With &('cEnt'+cCodEntidade+'Ini')
				Replace &('DESCENT'+cCodEntidade)	With cDescEnt
				If cHeader == 'CV0'
					Replace &('TIPOENT'+cCodEntidade)	With CTS->CTS_CLASSE
//					Replace &('RESENT'+cCodEntidade)	With cCodRes
				EndIf
			EndCase
			Replace CONTA 		With cConta
			Replace DESCCTA    	With cDesc
			Replace SUPERIOR  	With CTS->CTS_CTASUP
			Replace TIPOCONTA 	With CTS->CTS_CLASSE
			Replace NORMAL    	With CTS->CTS_NORMAL
			Replace ORDEM		With CTS->CTS_ORDEM
			Replace IDENTIFI	With CTS->CTS_IDENT
			Replace FILIAL		With CTS->CTS_FILIAL

			If CTS->( FieldPos( "CTS_TOTVIS" ) ) > 0
				Replace TOTVIS 		With CTS->CTS_TOTVIS
			EndIf

			If CTS->( FieldPos( "CTS_VISENT" ) ) > 0
				Replace VISENT 		With CTS->CTS_VISENT
			EndIf

			If CTS->( FieldPos( "CTS_SLDENT" ) ) > 0
				Replace SLDENT 		With CTS->CTS_SLDENT
			EndIf

			If CTS->( FieldPos( "CTS_FATSLD" ) ) > 0
				Replace FATSLD 		With CTS->CTS_FATSLD
			EndIf
		EndIf

		If Left(CTS->CTS_FORMUL, 6) = "TEXTO="		// Adiciona texto a descricao
			Replace DESCCTA With 	AllTrim(DESCCTA) + Space(1) +;
													&(Subs(CTS->CTS_FORMUL, 7))
		Elseif Left(CTS->CTS_FORMUL, 9) = "TEXTOVAR="		// Substitui a descricao pelo retornado pela macro-execucao
			Replace DESCCTA With 	&(Subs(CTS->CTS_FORMUL, 10))

		Endif

		If nDivide > 1
			nSaldoAnt	:= Round(NoRound((nSaldoAnt/nDivide),3),2)
			nSaldoAtu	:= Round(NoRound((nSaldoAtu/nDivide),3),2)
			nSaldoAtuD	:= Round(NoRound((nSaldoAtuD/nDivide),3),2)
			nSaldoAtuC	:= Round(NoRound((nSaldoAtuC/nDivide),3),2)
			nSaldoDeb	:= Round(NoRound((nSaldoDeb/nDivide),3),2)
			nSaldoCrd	:= Round(NoRound((nSaldoCrd/nDivide),3),2)
		EndIf

		dbSelectArea("cArqTmp")
		Replace	SALDOANT With nSaldoAnt			// Saldo Anterior
		Replace SALDOATU With nSaldoAtu			// Saldo Atual

		Replace SALDOATUDB With nSaldoAtuD		//Saldo Atual Devedor
		Replace SALDOATUCR With nSaldoAtuC		//Saldo Atual Credor

		If nSaldoDeb < 0
			Replace SALDOCRD	With nSaldoDeb
		ElseIf nSaldoDeb >= 0
			Replace SALDODEB	With nSaldoDeb
		EndIf
		If nSaldoCrd < 0
			Replace SALDODEB	With nSaldoCrd
		ElseIf nSaldoCrd >= 0
			Replace SALDOCRD	With nSaldoCrd
		EndIf

		Replace MOVIMENTO With nSaldoCrd-nSaldoDeb


		If lComNivel
			aNivel := {}
			Aadd(aNivel, Recno())
		Endif

		If lImpSint
			dbSelectArea("CTS")
			dbSetOrder(2)
			// Grava contas sinteticas
			If !Empty(CTS->CTS_CTASUP)
				While !Eof() .And. 	CTS->CTS_FILIAL == cFilCTS .And. ;
										CTS->CTS_CODPLA == cPlanGer

					cContaSup 	:= CTS->CTS_CTASUP

					dbSelectArea("CTS")
					dbSetOrder(2)
					If MsSeek(cFilCTS+cPlanGer+cContaSup)
						cDescS	:= CTS->CTS_DESCCG
						cNormal := CTS->CTS_NORMAL
					Else
						cNormal	:= cCodNor
					EndIf

					dbSelectArea("cArqTmp")
					dbSetOrder(1)
					If cHeader == "CTT"
						cChave	:= cCCIni+cContaSup
					ElseIf cHeader == "CTD"
						cChave	:= cItemIni+cContaSup
					ElseIf cHeader == "CTH"
						cChave	:= cClVlIni+cContaSup
					ElseIf !Empty(cCodEntidade)
 						cChave := &("cEnt"+cCodEntidade+"Ini")
					EndIf

					If !MsSeek(cChave)
						dbAppend()
						Do Case
						Case cHeader = 'CTT'
							Replace CUSTO 		With cCCIni
							Replace DESCCC		With cDescEnt
							Replace TIPOCC		With CTS->CTS_CLASSE
							Replace CCRES		With cCodRes
						Case cHeader = 'CTD'
							Replace ITEM 		With cItemIni
							Replace DESCITEM	With cDescEnt
							Replace TIPOITEM	With CTS->CTS_CLASSE
							Replace ITEMRES		With cCodRes
						Case cHeader = 'CTH'
							Replace CLVL 		With cClVlIni
							Replace DESCCLVL	With cDescEnt
							Replace TIPOCLVL	With CTS->CTS_CLASSE
							Replace CLVLRES		With cCodRes
						Case !Empty(cCodEntidade)
							Replace &('CODENT'+cCodEntidade)	With &('cEnt'+cCodEntidade+'Ini')
							Replace &('DESCENT'+cCodEntidade)	With cDescEnt
							If cHeader == 'CV0'
								Replace &('TIPOENT'+cCodEntidade)	With CTS->CTS_CLASSE
//								Replace &('RESENT'+cCodEntidade)	With cCodRes
							EndIf
						EndCase
						Replace CONTA	With cContaSup
						Replace DESCCTA With cDescS
						Replace SUPERIOR  	With CTS->CTS_CTASUP
						Replace TIPOCONTA	With CTS->CTS_CLASSE
						Replace NORMAL   	With CTS->CTS_NORMAL
						Replace ORDEM		With CTS->CTS_ORDEM
						Replace IDENTIFI	With CTS->CTS_IDENT
						Replace FILIAL		With CTS->CTS_FILIAL

						If CTS->( FieldPos( "CTS_TOTVIS" ) ) > 0
							Replace TOTVIS 		With CTS->CTS_TOTVIS
						EndIf

						If CTS->( FieldPos( "CTS_VISENT" ) ) > 0
							Replace VISENT 		With CTS->CTS_VISENT
						EndIf

						If CTS->( FieldPos( "CTS_SLDENT" ) ) > 0
							Replace SLDENT 		With CTS->CTS_SLDENT
						EndIf

						If CTS->( FieldPos( "CTS_FATSLD" ) ) > 0
							Replace FATSLD 		With CTS->CTS_FATSLD
						EndIf
					EndIf

					Replace	SALDOANT With SALDOANT + nSaldoAnt			// Saldo Anterior
					Replace SALDOATU With SALDOATU + nSaldoAtu			// Saldo Atual

					Replace SALDOATUDB With SALDOATUDB + nSaldoAtuD		//Saldo Atual Devedor
					Replace SALDOATUCR With SALDOATUCR + nSaldoAtuC		//Saldo Atual Credor

					If nSaldoDeb < 0
						Replace SALDOCRD	With SALDOCRD + nSaldoDeb
					ElseIf nSaldoDeb >= 0
						Replace SALDODEB	With SALDODEB + nSaldoDeb
					EndIf
					If nSaldoCrd < 0
						Replace SALDODEB	With SALDODEB + nSaldoCrd
					ElseIf nSaldoCrd >= 0
						Replace SALDOCRD	With SALDOCRD + nSaldoCrd
					EndIf

					Replace MOVIMENTO With SALDOCRD-SALDODEB

	  	            If lComNivel
						Aadd(aNivel, Recno())
					Endif

					dbSelectArea("CTS")
					If !Eof() .And. Empty(CTS->CTS_CTASUP)
						dbSelectArea("cArqTmp")
						Replace NIVEL1 With .T.
						dbSelectArea("CTS")
						Exit
					EndIf
				EndDo

				If lComNivel
					dbSelectArea("cArqTmp")
					nContador 	:= 1
					For nNivel 	:= Len(aNivel) To 1 Step -1
						DbGoto(aNivel[nNivel])
						If nContador < 99
							Replace NIVEL With nContador ++
						Else
							Replace NIVEL With 99
						EndIf
					Next
				Endif
			EndIf
		Endif
		aSaldoAnt	:= { 0, 0, 0, 0, 0, 0, 0, 0 }
		aSaldoAtu	:= { 0, 0, 0, 0, 0, 0, 0, 0 }
		nSaldoCrd	:= 0
		nSaldoDeb 	:= 0
		nSaldoAnt 	:= 0
		nSaldoAtu 	:= 0
		nSaldoAtuD	:= 0
		nSaldoAtuC	:= 0
		nSaldoAntD	:= 0
		nSaldoAntC	:= 0
		nLSldAnt	:= 0
		nLSldAtu	:= 0

		dbSelectArea(cHeader)
		dbSkip()

	EnddO

	dbSelectArea("CTS")
	dbSetOrder(1)
	dbGoTo(nRegCTS)
//	dbSkip()
EndDo

RestArea(aSaveArea)

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥SaldoNoCC  ≥ Autor ≥ Marcos Lobo           ≥ Data ≥ 20.07.2005         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥Retorna o saldo dos lanÁamentos e contas e centros de custos nao espe- ≥±±
±±≥          ≥cificados.                                                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Saldo  - Numerico                                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥Generico                                                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpC1 = Conta inicial                                                 ≥±±
±±≥          ≥ ExpC2 = Conta final                                                   ≥±±
±±≥          ≥ ExpD3 = Data do saldo                                                 ≥±±
±±≥          ≥ ExpC4 = Moeda                                                         ≥±±
±±≥          ≥ ExpC5 = Tipo de saldo                                                 ≥±±
±±≥          ≥ ExpN6 = Tipo de retorno :                                             ≥±±
±±≥          ≥         [1] - Saldo atual ( com sinal )                               ≥±±
±±≥          ≥         [2] - Debito na Data                                          ≥±±
±±≥          ≥         [3] - Credito na Data                                         ≥±±
±±≥          ≥         [4] - Saldo Atual Devedor                                     ≥±±
±±≥          ≥         [5] - Saldo Atual Credor                                      ≥±±
±±≥          ≥         [6] - Saldo Anterior (Com sinal)                              ≥±±
±±≥          ≥         [7] - Saldo Anterior Devedor                                  ≥±±
±±≥          ≥         [8] - Saldo Anterior Credor                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function SaldoNoCC(cContaIni, cContaFim, dData,cMoeda, cTpSald,nTpRet)
Local nSaldo	:= 0
Default nTpRet	:= 1

dData := DataWindow(dData)

nSaldo := SaldTotCT7(cContaIni,cContaFim,dData,cMoeda,cTpSald) [nTpRet]        // Saldo das Contas no CT7
nSaldo := nSaldo - SaldTotCT3("  ",Replicate("z",Len(CTT->CTT_CUSTO)),cContaIni, cContaFim,dData,cMoeda,cTpSald)[nTpRet] // Saldo dos Centros de Custos

Return(nSaldo)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Program   ≥CSPMVTALimpa≥ Autor ≥ Totvs               ≥ Data ≥ 20/08/09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Limpa a procedure da base.                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CSPMVTLimpa()
	Local cGetDB 		:= TCGetDB()
	Local cTOP400Alias 	:= ""
	Local cSPMVTO		:= xProcedure( "CTBMVT" )

	If cGetDB == "AS400" .or. cGetDB == "DB2/400"  // remover posteriormente "AS400"
		// Identifica nome do Schema ( Alias )
		cTOP400Alias := GetSrvProfString('DBALIAS','')
		If empty(cTOP400Alias)
			cTOP400Alias := GetSrvProfString('TOPALIAS','')
		Endif
		If empty(cTOP400Alias)
			cTOP400Alias := GetPvProfString('TOTVSDBACCESS','ALIAS','',GetAdv97())
		Endif
		If empty(cTOP400Alias)
			cTOP400Alias := GetPvProfString('TOPCONNECT','ALIAS','',GetAdv97())
		Endif

		TCSqlExec("DROP PROCEDURE " + cTOP400Alias + "." + cSPMVTO )
		TCSqlExec("DELETE FROM  " + cTOP400Alias + ".TOP_SP WHERE SP_NOME LIKE 'CTBMVT%'")
	Else
		TCSqlExec("DROP PROCEDURE " + cSPMVTO )
		TCSqlExec("DELETE FROM TOP_SP WHERE SP_NOME LIKE 'CTBMVT%'")
	Endif
Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Program   ≥CtbSPMVTVer ≥ Autor ≥ Totvs               ≥ Data ≥ 20/08/09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Verifica versao da procedure                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ CriaSP169()                                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ .T. / .F.                                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CtbSPMVTVer()
	Local cGetDB 		:= TCGetDB()
	Local cTOP400Alias 	:= ""
	Local cQuery		:= ""
	Local lReturn		:= .F.
	Local cSPCTBMVT		:= xProcedure( "CTBMVT" )

	If cGetDB == "AS400" .or. cGetDB == "DB2/400"  // remover posteriormente "AS400"
		// Identifica nome do Schema ( Alias )
		cTOP400Alias := GetSrvProfString('DBALIAS','')
		If empty(cTOP400Alias)
			cTOP400Alias := GetSrvProfString('TOPALIAS','')
		Endif
		If empty(cTOP400Alias)
			cTOP400Alias := GetPvProfString('TOTVSDBACCESS','ALIAS','',GetAdv97())
		Endif
		If empty(cTOP400Alias)
			cTOP400Alias := GetPvProfString('TOPCONNECT','ALIAS','',GetAdv97())
		Endif
	Endif

	If cGetDB == "ORACLE"
		cQuery := "select SP_DATA from TOP_SP where RTrim( SP_NOME ) = '" + cSPCTBMVT + "' "
	ElseIf cGetDB == "AS400" .or. cGetDB == "DB2/400"  // remover posteriormente "AS400"
		cQuery := "select SP_DATA from " + cTOP400Alias + ".TOP_SP where SP_NOME = '" + cSPCTBMVT + "' "
	Else
		cQuery := "select SP_DATA from TOP_SP where SP_NOME = '" + cSPCTBMVT + "' "
	EndIf
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "TOPSP" )

	If !TOPSP->( Eof() )
		If TOPSP->SP_DATA <> cVerSPMVT
			lReturn := .T.
		EndIf
	Else
		lReturn := .T.
    EndIf

	TOPSP->( DbCloseArea() )

Return lReturn

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Program   ≥CriaSPMVT ≥ Autor ≥ Totvs                 ≥ Data ≥ 20/08/09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Cria a procedure CTB169 dinamicamente                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ CriaSPMVT()                                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ .T. / .F.                                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CriaSPMVT(cFil)
Local lRet 		:= .T.
Local cProc		:= 'CTBMVT_' + cEmpAnt	// +CriaTrab(nil,.F.)
Local cSQL		:= ''
Local cRet		:= 1
Local cCT2		:= RetSQLName("CT2")
Local cTamCont	:= ltrim(str(TamSX3("CT2_DEBITO")[1]))
Local cTamCust	:= ltrim(str(TamSX3("CT2_CCD")[1]))
Local cTamItem	:= ltrim(str(TamSX3("CT2_ITEMD")[1]))
Local cTamClVl	:= ltrim(str(TamSX3("CT2_CLVLDB")[1]))
Local cTamOrig	:= ltrim(str(TamSX3("CT2_ORIGEM")[1]))
Local cTrim		:= "ltrim"
Local cData		:= "20090820"
Local cHora		:= "000000"
Local cVersao	:= "P10"

Default cFil	:= cFilAnt
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥limpa o banco de dados para criacao da procedure≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
CSPMVTLimpa()

If Alltrim(Upper(TcGetDB()))=="INFORMIX"
	cTrim := "trim"
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥cria a procedure≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If !TCSPExist( cProc )
	cSQL:=cSQL+"create procedure "+cProc+" ( @IN_DtIni char(8), @IN_DtFim char(8), @IN_ContB varchar("+cTamCont+"), @IN_CustB varchar("+cTamCust+"), @IN_ItemB varchar("+cTamItem+"), @IN_ClVlB varchar("+cTamClVl+"), @IN_ContP varchar("+cTamCont+"), @IN_CustP varchar("+cTamCust+"), @IN_ItemP varchar("+cTamItem+"), @IN_ClVlP varchar("+cTamClVl+"), @IN_Origem varchar("+cTamOrig+"), @IN_Moeda varchar(2), @OUT_RET int output, @OUT_MovAnt float output, @OUT_MovAtu float output )"+CRLF
	cSQL:=cSQL+"as"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"declare @atudeb	float"+CRLF
	cSQL:=cSQL+"declare @atucrd	float"+CRLF
	cSQL:=cSQL+"declare @antdeb	float"+CRLF
	cSQL:=cSQL+"declare @antcrd	float"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"select @OUT_RET = 1"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"if "+cTrim+"(@IN_ContB)='' and "+cTrim+"(@IN_CustB)='' and "+cTrim+"(@IN_ItemB)='' and "+cTrim+"(@IN_ClVlB)=''"+CRLF
	cSQL:=cSQL+"	select @OUT_RET = 2"+CRLF
	cSQL:=cSQL+"else"+CRLF
	cSQL:=cSQL+"	begin"+CRLF
	cSQL:=cSQL+"		select @antdeb = isnull(sum(CT2_VALOR),0)"+CRLF
	cSQL:=cSQL+"		from "+cCT2+" CT2"+CRLF
	cSQL:=cSQL+"		where D_E_L_E_T_ = ' '"+CRLF

	If "(" $ cFil
		cSQL:=cSQL+"		and CT2_FILIAL IN " + cFil +CRLF
	Else
		cSQL:=cSQL+"		and CT2_FILIAL = '"+xFilial("CT2",cFil)+"'"+CRLF
	End

	cSQL:=cSQL+"		and CT2_DC in ('1','3') "+CRLF
	cSQL:=cSQL+"		and CT2_ORIGEM = @IN_Origem"+CRLF
	cSQL:=cSQL+"		and CT2_DATA < @IN_DtIni"+CRLF
	cSQL:=cSQL+"		and CT2_MOEDLC = @IN_Moeda"+CRLF
	cSQL:=cSQL+"		and ( CT2_DEBITO = @IN_ContB or "+cTrim+"(@IN_ContB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CREDIT = @IN_ContP or "+cTrim+"(@IN_ContP) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CCD    = @IN_CustB or "+cTrim+"(@IN_CustB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CCC    = @IN_CustP or "+cTrim+"(@IN_CustP) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_ITEMD  = @IN_ItemB or "+cTrim+"(@IN_ItemB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_ITEMC  = @IN_ItemP or "+cTrim+"(@IN_ItemP) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CLVLDB = @IN_ClVlB or "+cTrim+"(@IN_ClVlB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CLVLCR = @IN_ClVlP or "+cTrim+"(@IN_ClVlP) = '' )"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"		select @OUT_RET = 3"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"		select @antcrd = isnull(sum(CT2_VALOR),0)"+CRLF
	cSQL:=cSQL+"		from "+cCT2+" CT2"+CRLF
	cSQL:=cSQL+"		where D_E_L_E_T_ = ' '"+CRLF
	If "(" $ cFil
		cSQL:=cSQL+"		and CT2_FILIAL IN " + cFil +CRLF
	Else
		cSQL:=cSQL+"		and CT2_FILIAL = '"+xFilial("CT2",cFil)+"'"+CRLF
	End
	cSQL:=cSQL+"		and CT2_DC in ('2','3')"+CRLF
	cSQL:=cSQL+"		and CT2_ORIGEM = @IN_Origem"+CRLF
	cSQL:=cSQL+"		and CT2_DATA < @IN_DtIni"+CRLF
	cSQL:=cSQL+"		and CT2_MOEDLC = @IN_Moeda"+CRLF
	cSQL:=cSQL+"		and ( CT2_CREDIT = @IN_ContB or "+cTrim+"(@IN_ContB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_DEBITO = @IN_ContP or "+cTrim+"(@IN_ContP) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CCC    = @IN_CustB or "+cTrim+"(@IN_CustB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CCD    = @IN_CustP or "+cTrim+"(@IN_CustP) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_ITEMC  = @IN_ItemB or "+cTrim+"(@IN_ItemB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_ITEMD  = @IN_ItemP or "+cTrim+"(@IN_ItemP) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CLVLCR = @IN_ClVlB or "+cTrim+"(@IN_ClVlB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CLVLDB = @IN_ClVlP or "+cTrim+"(@IN_ClVlP) = '' )"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"		select @OUT_RET = 4"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"		select @atudeb = isnull(sum(CT2_VALOR),0)"+CRLF
	cSQL:=cSQL+"		from "+cCT2+" CT2"+CRLF
	cSQL:=cSQL+"		where D_E_L_E_T_ = ' '"+CRLF
	If "(" $ cFil
		cSQL:=cSQL+"		and CT2_FILIAL IN " + cFil +CRLF
	Else
		cSQL:=cSQL+"		and CT2_FILIAL = '"+xFilial("CT2",cFil)+"'"+CRLF
	End
	cSQL:=cSQL+"		and CT2_DC in ('1','3')"+CRLF
	cSQL:=cSQL+"		and CT2_ORIGEM = @IN_Origem"+CRLF
	cSQL:=cSQL+"		and CT2_DATA between @IN_DtIni and @IN_DtFim"+CRLF
	cSQL:=cSQL+"		and CT2_MOEDLC = @IN_Moeda"+CRLF
	cSQL:=cSQL+"		and ( CT2_DEBITO = @IN_ContB or "+cTrim+"(@IN_ContB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CREDIT = @IN_ContP or "+cTrim+"(@IN_ContP) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CCD    = @IN_CustB or "+cTrim+"(@IN_CustB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CCC    = @IN_CustP or "+cTrim+"(@IN_CustP) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_ITEMD  = @IN_ItemB or "+cTrim+"(@IN_ItemB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_ITEMC  = @IN_ItemP or "+cTrim+"(@IN_ItemP) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CLVLDB = @IN_ClVlB or "+cTrim+"(@IN_ClVlB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CLVLCR = @IN_ClVlP or "+cTrim+"(@IN_ClVlP) = '' )"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"		select @OUT_RET = 5"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"		select @atucrd = isnull(sum(CT2_VALOR),0)"+CRLF
	cSQL:=cSQL+"		from "+cCT2+" CT2"+CRLF
	cSQL:=cSQL+"		where D_E_L_E_T_ = ' '"+CRLF
	If "(" $ cFil
		cSQL:=cSQL+"		and CT2_FILIAL IN " + cFil +CRLF
	Else
		cSQL:=cSQL+"		and CT2_FILIAL = '"+xFilial("CT2",cFil)+"'"+CRLF
	End
	cSQL:=cSQL+"		and CT2_DC in ('2','3')"+CRLF
	cSQL:=cSQL+"		and CT2_ORIGEM = @IN_Origem"+CRLF
	cSQL:=cSQL+"		and CT2_DATA between @IN_DtIni and @IN_DtFim"+CRLF
	cSQL:=cSQL+"		and CT2_MOEDLC = @IN_Moeda"+CRLF
	cSQL:=cSQL+"		and ( CT2_CREDIT = @IN_ContB or "+cTrim+"(@IN_ContB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_DEBITO = @IN_ContP or "+cTrim+"(@IN_ContP) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CCC    = @IN_CustB or "+cTrim+"(@IN_CustB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CCD    = @IN_CustP or "+cTrim+"(@IN_CustP) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_ITEMC  = @IN_ItemB or "+cTrim+"(@IN_ItemB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_ITEMD  = @IN_ItemP or "+cTrim+"(@IN_ItemP) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CLVLCR = @IN_ClVlB or "+cTrim+"(@IN_ClVlB) = '' )"+CRLF
	cSQL:=cSQL+"		and ( CT2_CLVLDB = @IN_ClVlP or "+cTrim+"(@IN_ClVlP) = '' )"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"		select @OUT_RET = 6"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"		select @OUT_MovAnt = @antcrd - @antdeb"+CRLF
	cSQL:=cSQL+"		select @OUT_MovAtu = @atucrd - @atudeb"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"	end"+CRLF

	If ExistBlock( "CTBMOVTOS" )
		cSQL := ExecBlock( "CTBMOVTOS", .F., .F., { cSQL } )
	EndIf

	cSQL:=MsParse(cSQL,Alltrim(TcGetDB()))

	If cSQL=''
		If !__lBlind
			MsgAlert( STR0043 + " " + cProc + ": " + MsParseError() ) // "Erro na criacao da procedure"
		EndIf
	Else

		If Alltrim(Upper(TcGetDB()))=="ORACLE"
			cSQL:=StrTran(cSQL,"= ''","is null")
		EndIf

		cRet:=TcSqlExec(cSQL)
		If cRet <> 0
			If !__lBlind
				MsgAlert( STR0043 + " " + cProc + ": " + TCSqlError() )  // "Erro na criacao da procedure"
			EndIf
			lRet := .f.
		EndIf
	EndIf
EndIf

cStatement := "INSERT INTO TOP_SP ( SP_NOME, SP_VERSAO, SP_DATA, SP_HORA ) "
cStatement += "     VALUES ( 'CTBMVT_" + cEmpAnt + "', '"+cVersao+"', '"+cData+"', '"+cHora+"' )"
TCSqlExec( cStatement )

Return lRet

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Program   ≥ CTBSplit ≥ Autor ≥ Totvs                 ≥ Data ≥ 20/08/09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Divide uma string em array conforme caracter identificador ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CTBSplit( cString, cChar, nItens )
Local aReturn	:= {}
Local cAux		:= cString
Local nAt		:= 0
Local nInc		:= 0

Default nItens	:= 0

If ! Empty( cString )
	While ( nAt	:= at( cChar, cAux ) ) > 0
		aAdd( aReturn, Left( cAux, nAt-1 ) )
		cAux := substr( cAux, nAt+1 )
	End

	If !Empty( cAux )
		aAdd( aReturn, cAux )
	EndIf
EndIf

// Incluir a dimensao informada caso nao exista
For nInc := ( Len( aReturn ) + 1 ) To nItens
	aAdd( aReturn, NIL )
Next

Return aReturn

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥SaldoGrupo ≥ Autor ≥ Jose Lucas            ≥ Data ≥ 16.02.10≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Devolve saldos do CTR - Planilha                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥aSaldos(nQualSaldo)                                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥Planilha                                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cGrupo     = Codigo da Grupo ou Natureza Contabil.         ≥±±
±±≥          ≥ dData      = Data                                          ≥±±
±±≥          ≥ cMoeda     = Moeda                                         ≥±±
±±≥          ≥ cTpSald    = Tipo de Saldo                                 ≥±±
±±≥          ≥ nQualSaldo = Retorno Desejado                              ≥±±
±±≥          ≥ nImpAntLP  = Se considera valores anteriores ‡ Apuracao de ≥±±
±±≥          ≥              LP, ou seja, desprezando os lancamentos de LP ≥±±
±±≥          ≥              (0-Nao) ou nao (1-Sim)                        ≥±±
±±≥          ≥ dDataLP    = Data da Apuracao de LP cujos lancamentos serao≥±±
±±≥          ≥              desconsiderados                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function SaldoGrupo(cGrupo,dData,cMoeda,cTpSald,nQualSaldo,nImpAntLP,dDataLP,cSelFil)

Local aSaveArea	  := GetArea()
Local nSaldoGrupo := 0.00
Local nSaldoConta := 0.00
Local lImpAntLP
Local aSelFil	  := {}
Local nTamFilial  := IIf( lFWCodFil, FWGETTAMFILIAL, 2 )
Local cAliasCTR	  := "CTR"

DEFAULT nImpAntLP := 0 // corresponde a .F.
DEFAULT dDataLP   := CTOD("  /  /  ")
DEFAULT cSelFil	  := xFilial( "CT7" )

If Len( cSelFil ) == nTamFilial
	Aadd( aSelFil , cSelFil )
Else
	If Len( cSelFil ) >= nTamFilial
		aSelFil := StrToArray( cSelFil , ";" )
	Endif
Endif

IF Len( aSelFil ) <= 0
	Help(" ",1,"FILIALCT5",,STR0042,1,0)//'Filial n„o informada e/ou informada incorretamente!'
	Return {}
Endif

lImpAntLP := ( nImpAntLP == 1 )

cGrupo		:= Left(AllTrim(cGrupo) + Space(Len((cAliasCTR)->CTR_GRUPO)), Len((cAliasCTR)->CTR_GRUPO))
cTpSald 	:= Iif(cTpSald==Nil,"1",cTpSald)
nQualSaldo	:= Iif(nQualSaldo==Nil,1,nQualSaldo)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1] Saldo Atual (com sinal)                          ≥
//≥ [2] Debito na Data                                   ≥
//≥ [3] Credito na Data                                  ≥
//≥ [4] Saldo Atual Devedor                              ≥
//≥ [5] Saldo Atual Credor                               ≥
//≥ [6] Saldo Anterior (com sinal)                       ≥
//≥ [7] Saldo Anterior Devedor                           ≥
//≥ [8] Saldo Anterior Credor                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
CT1->(DbSetOrder(4))
CT1->(DbSeek(xFilial("CT1")+cGrupo))
While ! CT1->(Eof()) .and. CT1->CT1_FILIAL == xFilial("CT1") .and. CT1->CT1_GRUPO == cGrupo
	cConta := CT1->CT1_CONTA
   	While ! CT1->(Eof()) .and. CT1->CT1_FILIAL == xFilial("CT1") .and. CT1->CT1_GRUPO == cGrupo .and. CT1->CT1_CONTA == cConta

		nSaldoConta := SaldoConta(cConta,dData,cMoeda,cTpSald,nQualSaldo,nImpAntLP,dDataLP,cSelFil)
       	nSaldoGrupo += nSaldoConta
        CT1->(DbSkip())
    End
End
RestArea(aSaveArea)
Return nSaldoGrupo

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥SaldTotCTR ≥ Autor ≥ Jose Lucas            ≥ Data ≥ 16.02.10≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Retorna o saldo para um intervalo de Grupos ou Natureza     ≥±±
±±≥          ≥Contabil - CTR - Planilha.                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥aSaldos(nQualSaldo)                                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥Planilha                                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cGrupoIni  = Codigo da Grupo ou Natureza Contabil inicial. ≥±±
±±≥          ≥ cGrupoFim  = Codigo da Grupo ou Natureza Contabil final.   ≥±±
±±≥          ≥ dData      = Data                                          ≥±±
±±≥          ≥ cMoeda     = Moeda                                         ≥±±
±±≥          ≥ cTpSald    = Tipo de Saldo                                 ≥±±
±±≥          ≥ nQualSaldo = Retorno Desejado                              ≥±±
±±≥          ≥ nImpAntLP  = Se considera valores anteriores ‡ Apuracao de ≥±±
±±≥          ≥              LP, ou seja, desprezando os lancamentos de LP ≥±±
±±≥          ≥              (0-Nao) ou nao (1-Sim)                        ≥±±
±±≥          ≥ dDataLP    = Data da Apuracao de LP cujos lancamentos serao≥±±
±±≥          ≥              desconsiderados                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function SaldoTotCTR(cGrupoIni,cGrupoFim,dData,cMoeda,cTpSald,nQualSaldo,nImpAntLP,dDataLP,cSelFil)
Local aSaveArea	  := GetArea()
Local nSaldoGrupo := 0.00
Local nSaldoConta := 0.00
Local lImpAntLP
Local aSelFil	  := {}
Local nTamFilial  := IIf( lFWCodFil, FWGETTAMFILIAL, 2 )

DEFAULT nImpAntLP := 0 // corresponde a .F.
DEFAULT dDataLP   := CTOD("  /  /  ")
DEFAULT cSelFil	  := xFilial( "CT7" )

If Len( cSelFil ) == nTamFilial
	Aadd( aSelFil , cSelFil )
Else
	If Len( cSelFil ) >= nTamFilial
		aSelFil := StrToArray( cSelFil , ";" )
	Endif
Endif

IF Len( aSelFil ) <= 0
	Help(" ",1,"FILIALCT5",,STR0042,1,0)//'Filial n„o informada e/ou informada incorretamente!'
	Return {}
Endif

lImpAntLP := ( nImpAntLP == 1 )

cGrupoIni	:= Left(AllTrim(cGrupoIni) + Space(Len((cAliasCTR)->CTR_GRUPO)), Len((cAliasCTR)->CTR_GRUPO))
cGrupoFim	:= Left(AllTrim(cGrupoFim) + Space(Len((cAliasCTR)->CTR_GRUPO)), Len((cAliasCTR)->CTR_GRUPO))
cTpSald 	:= Iif(cTpSald==Nil,"1",cTpSald)
nQualSaldo	:= Iif(nQualSaldo==Nil,1,nQualSaldo)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1] Saldo Atual (com sinal)                          ≥
//≥ [2] Debito na Data                                   ≥
//≥ [3] Credito na Data                                  ≥
//≥ [4] Saldo Atual Devedor                              ≥
//≥ [5] Saldo Atual Credor                               ≥
//≥ [6] Saldo Anterior (com sinal)                       ≥
//≥ [7] Saldo Anterior Devedor                           ≥
//≥ [8] Saldo Anterior Credor                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
CT1->(DbSetOrder(4))
CT1->(DbSeek(xFilial("CT1")+cGrupoIni))
While ! CT1->(Eof()) .and. CT1->CT1_FILIAL == xFilial("CT1") .and. CT1->CT1_GRUPO <= cGrupoFim
	cGrupo := CT1->CT1_GRUPO
	cConta := CT1->CT1_CONTA
   	While ! CT1->(Eof()) .and. CT1->CT1_FILIAL == xFilial("CT1") .and. CT1->CT1_GRUPO == cGrupo .and. CT1->CT1_CONTA == cConta
		nSaldoConta := SaldoConta(cConta,dData,cMoeda,cTpSald,nQualSaldo,nImpAntLP,dDataLP,cSelFil)
       	nSaldoGrupo += nSaldoConta
        CT1->(DbSkip())
    End
End
RestArea(aSaveArea)
Return nSaldoGrupo
/*{Protheus.doc} CTPlanoRef
Redirecionada para a pasta do MI
Master/Adm/LocalizaÁıes

@author TOTVS

@version P12
@since 08/07/2019
*/
Function CTPlanoRef(oMeter,oText,oDlg,lEnd,cPlanoRef,cCtaRefIni,cCtaRefFin,dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,lColunas,nColunas,cEntCont,cCusto,cItem,cCLVL,c5Ent,oTabTmp)
Return _CTPlanoRef(oMeter,oText,oDlg,@lEnd,@cPlanoRef,@cCtaRefIni,@cCtaRefFin,@dDataIni,@dDataFin,@cMoeda,@cTpSaldo,@lImpAntLP,@dDataLP,@lColunas,@nColunas,@cEntCont,@cCusto,@cItem,@cCLVL,@c5Ent,oTabTmp)

/*/
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ CTSaldEnt()	≥ Autor ≥ JosÈ Lucas 				  ≥ Data ≥ 04.03.10 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Devolve saldos diarios e mensais correpondente as tabelas		    ≥±±
±±≥          ≥ CVX e CVY.                                                 			≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ CTSaldEnt(dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,		≥±±
±±≥			 ≥ cEntCont,cConta,cCusto,cItem,cCLVL,c5Ent)							≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ aSaldosRet[nQualSaldo]									  			≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   			≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpD1 = Data Inicial	                                    		    ≥±±
±±≥          ≥ ExpD2 = Data Final                                          			≥±±
±±≥          ≥ ExpC1 = Moeda                                             		    ≥±±
±±≥          ≥ ExpC2 = Tipo de Saldo                                     		    ≥±±
±±≥          ≥ ExpL1 = lImpAntLP	                                     		    ≥±±
±±≥          ≥ ExpD3 = dDataLP		                                     		    ≥±±
±±≥          ≥ ExpC3 = cEntCont		                                     		    ≥±±
±±≥          ≥ ExpC4 = cConta Contabil                                     		    ≥±±
±±≥          ≥ ExpC5 = cCusto		                                     		    ≥±±
±±≥          ≥ ExpC6 = cItem		                                     		    ≥±±
±±≥          ≥ ExpC7 = cCLVL		                                     		    ≥±±
±±≥          ≥ ExpC8 = c5Ent		                                     		    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CTSaldEnt(dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,cEntCont,cConta,cCusto,cItem,cCLVL,c5Ent)

Local aSaveArea	  := GetArea()
Local aSaldos	  := {}
Local nQualSaldo  := 1
//Local nCount	  := 0

DEFAULT cEntCont  := "1"
DEFAULT cConta    := ""
DEFAULT cCusto    := ""
DEFAULT cItem     := ""
DEFAULT cCLVL     := ""
DEFAULT lImpAntLP := .F.
DEFAULT dDataLP   := CTOD("  /  /  ")

cTpSaldo 	:= Iif(cTpSaldo == Nil,"1",cTpSaldo)

If nQualSaldo > 0
	If Month(dDataFin) - Month(dDataIni) > 0
	    //Calcular o Saldo de CVX
		aSaldoCVX := CtSaldoCVX(dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,cEntCont,cConta,cCusto,cItem,cCLVL,c5Ent)
	    aSaldos := aSaldoCVX
	Else
		//Calcular o Saldo de CVX
		aSaldoCVX := CtSaldoCVX(dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,cEntCont,cConta,cCusto,cItem,cCLVL,c5Ent)
	    aSaldos := aSaldoCVX
    EndIf
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1][1] Saldo do PerÌodo (com sinal).                 ≥
//≥ [1][2] Debito no PerÌodo.                            ≥
//≥ [1][3] Credito no PerÌodo.                           ≥
//≥ [1][4] Saldo Atual Devedor.                          ≥
//≥ [1][5] Saldo Atual Credor.                           ≥
//≥ [1][6] Saldo Anterior (com sinal).                   ≥
//≥ [1][7] Saldo Anterior Devedor.                       ≥
//≥ [1][8] Saldo Anterior Credor.                        ≥
//≥ [2]	   Conta Cont·bil.				                 ≥
//≥ [3]	   Centro de Custos.				             ≥
//≥ [4]	   Item Contabil.		            		     ≥
//≥ [5]	   Codigo da Conta Cont·bil.	                 ≥
//≥ [6]	   5 Entidade Contabil (N.I.T.)    				 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//    [1][1]    [1][2]    [1][3]    [1][4]      [1][5]   [1][6]     [1][7]     [1][8]      [2]   [3]   [4]    [5]   [6]    [7]
//{{nSaldoAtu,nSaldoDeb,nSaldoCrd,nSldAtuDeb,nSldAtuCrd,nSaldoAnt,nSldAntDeb,nSldAntCrd},cConta,cCusto,cItem,cCLVL,c5Ent,IdNivel}
RestArea(aSaveArea)
Return aSaldos

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥CTSaldoCVX  ≥ Autor ≥ JosÈ Lucas		              ≥ Data ≥ 05.03.10	≥±±

±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Saldos Di·rios - CVX.	                                   			≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥CTSaldoCVX(dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,cEntCont ≥±±
±±≥			 |,cConta,cCusto,cItem,cCLVL,c5Ent)										≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥{nSaldoAtu,nSaldoDeb,nSaldoCrd,nSldAtuDeb,nSldAtuCrd,nSaldoAnt,       ≥±±
±±≥			 ≥ nSldAntDeb,nSldAntCrd}                                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                  			≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpD1 = Data Inicial	                                    		    ≥±±
±±≥          ≥ ExpD2 = Data Final                                          		    ≥±±
±±≥          ≥ ExpC1 = Moeda                                             		    ≥±±
±±≥          ≥ ExpC2 = Tipo de Saldo                                     		    ≥±±
±±≥          ≥ ExpL1 = lImpAntLP	                                     		    ≥±±
±±≥          ≥ ExpD3 = dDataLP		                                     		    ≥±±
±±≥          ≥ ExpC3 = cEntCont		                                     		    ≥±±
±±≥          ≥ ExpC4 = cConta Contabil                                     		    ≥±±
±±≥          ≥ ExpC5 = cCusto		                                     		    ≥±±
±±≥          ≥ ExpC6 = cItem		                                     		    ≥±±
±±≥          ≥ ExpC7 = cCLVL		                                     		    ≥±±
±±≥          ≥ ExpC8 = c5Ent		                                     		    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function CTSaldoCVX(dDataIni,dDataFin,cMoeda,cTpSaldo,lImpAntLP,dDataLP,cEntCont,cConta,cCusto,cItem,cCLVL,c5Ent)

Local aSaveArea	 := CVX->(GetArea())
Local aSaveAnt	 := GetArea()
Local lNaoAchei	 := .F.
Local nSaldoAtu	 := 0.00
Local nSaldoAnt  := 0.00
Local nSaldoDeb	 := 0.00
Local nSaldoCrd	 := 0.00
Local nSldAntDeb := 0.00
Local nSldAntCrd := 0.00
Local nSldAtuDeb := 0.00
Local nSldAtuCrd := 0.00
Local aSaldoAtu	 := {0,0,0,0,0}
Local aSaldoAnt  := {0,0,0,0,0}
Local aSaldoDeb	 := {0,0,0,0,0}
Local aSaldoCrd	 := {0,0,0,0,0}
Local aSldAntDeb := {0,0,0,0,0}
Local aSldAntCrd := {0,0,0,0,0}
Local aSldAtuDeb := {0,0,0,0,0}
Local aSldAtuCrd := {0,0,0,0,0}
Local bCondicao	 := {||.F.}
Local bCondLP	 := {||.F.}
Local cChaveLP	 := ""
Local aSldLP	 := {0,0}
Local cQrySaldo	 := ""
Local cQryPerAnt := ""
Local aTamSaldo  := TamSX3("CVX_SLDDEB")
Local cFilEsp    := xFilial("CVX")
Local cContaLP   := ""
Local cChave     := ""
Local cCodConta  := ""
Local cCodCusto  := ""
Local cCodItem   := ""
Local cCodCLVL   := ""
Local cCod5Ent   := ""
Local aSaldos    := {}
Local aSaldoCVY := {0,0,0}

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Tratativa para o filtro de filiais           ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
// N„o pode haver filial nula ou diferente de caracter
If cFilEsp == nil .Or. Empty( cFilEsp ) .Or. ValType(cFilEsp) <> "C"
	cFilEsp	:= xFilial( "CVX" )
Else
	cFilEsp := Alltrim( cFilEsp )
Endif

cQryFil := " CVX_FILIAL = '" + cFilEsp + "' "



cTpSaldo	:= Iif( Empty( cTpSaldo),"1",cTpSaldo)
dDataLp		:= Iif( dDataLP ==Nil,CTOD("  /  /  "),dDataLP)
//cRotina		:= Iif( cRotina ==Nil,"",cRotina)
lImpAntLP	:= Iif( lImpAntLP == Nil,.F.,lImpAntLP)
cChave		:= Left(AllTrim(cChave) + Space(Len(CVX->CVX_CHAVE)), Len(CVX->CVX_CHAVE))

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verificar a existencia de CT1_CTALP e processar saldos de deduÁıes.               ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
CT1->(DbSetOrder(1))
If CT1->(DbSeek(xFilial("CT1")+cConta))
   	cContaLP  := CT1->CT1_CTALP
	lImpAntLP := .T.
EndIf

DbSelectArea("CVX")
Dbsetorder(2)



bCondicao	:= { || (CVX->CVX_FILIAL == cFilEsp .And. CVX->CVX_CHAVE == cChave .And. CVX->CVX_MOEDA == cMoeda .And. CVX->CVX_TPSALD == cTpSaldo .And. CVX->CVX_DATA  <= dData) }
cChaveLP	:= ( cFilEsp + "Z" + cConta + cMoeda + cTpSaldo )
If lHasCVXLP
	bCondLP  	:= { || (CVX->CVX_FILIAL == cFilEsp .And. CVX->CVX_CHAVE == cChave .And. CVX->CVX_MOEDA == cMoeda .And. CVX->CVX_TPSALD == cTpSaldo .And.  CVX->CVX_LP == "Z" .And.	dDataLP <= dData) }
Else
	bCondLP  	:= { || (CVX->CVX_FILIAL == cFilEsp .And. CVX->CVX_CHAVE == cChave .And. CVX->CVX_MOEDA == cMoeda .And. CVX->CVX_TPSALD == cTpSaldo .And. dDataLP <= dData) }
EndIf


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Processar Query para obter a data anterior, qdo n„o houver saldo no intervalo.    ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If Select("SLDANT") > 0
	SLDANT->(dbCloseArea())
Endif

cQryPerAnt := "SELECT MIN(CVX_DATA) CVX_DATA "
cQryPerAnt += "FROM "
cQryPerAnt += RetSqlName("CVX") + " CVX "
cQryPerAnt += " WHERE "
cQryPerAnt += "	CVX_FILIAL = '"+xFilial("CVX")+"' "
cQryPerAnt += "  AND CVX_DATA < '"+DTOS(dDataIni)+"' "
cQryPerAnt += " AND CVX_NIV01 = '" + cConta + "' "
If "2" $ cEntCont .and. !Empty(cCusto)
	cQryPerAnt += " AND CVX_NIV02 = '" + cCusto + "' "
EndIf
If "3" $ cEntCont .and. !Empty(cItem)
	cQryPerAnt += " AND CVX_NIV03 = '" + cItem + "' "
EndIf
If "4" $ cEntCont .and. !Empty(cCLVL)
	cQryPerAnt += " AND CVX_NIV04 = '" + cCLVL + "' "
EndIf
If "5" $ cEntCont .and. !Empty(c5Ent)
	cQryPerAnt += " AND CVX_NIV05 = '" + c5Ent + "' "
EndIf

If cPaisLoc == "COL" .and. "5" $ cEntCont
	cQryPerAnt += " AND CVX_NIV05 <> '' "
EndIf

cQryPerAnt += " AND CVX_MOEDA = '" + cMoeda + "' "
cQryPerAnt += " AND CVX_TPSALD = '" + cTpSaldo + "' "
cQryPerAnt += " AND D_E_L_E_T_ = ' ' "

cQryPerAnt := ChangeQuery(cQryPerAnt)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryPerAnt),"SLDANT",.T.,.F.)

TcSetField("SLDANT","CVX_DATA" 	  ,"D",08,0)

DbSelectArea("SLDANT")
SLDANT->(DbGoTop())
dDatIniAnt := SLDANT->CVX_DATA
SLDANT->(DbCloseArea())

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Processar Query para obter os Saldos da tabela CVX.                               ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If Select("SLDCVX") > 0
	SLDCVX->(dbCloseArea())
Endif

cQrySaldo := "SELECT "
cQrySaldo += "CVX_DATA, "
cQrySaldo += "CVX_NIV01, "
cQrySaldo += "CVX_NIV02, "
cQrySaldo += "CVX_NIV03, "
cQrySaldo += "CVX_NIV04, "
cQrySaldo += "CVX_NIV05, "
cQrySaldo += "CVX_SLDDEB, "
cQrySaldo += "CVX_SLDCRD  "
cQrySaldo += "FROM "
cQrySaldo += RetSqlName("CVX") + " CVX "
cQrySaldo += "	WHERE "
cQrySaldo += "	CVX_FILIAL = '"+xFilial("CVX")+"' "

If Empty(dDatIniAnt) .OR. !CARQAUX $ "FMT1008|FMT1009"
	cQrySaldo += " AND CVX_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFin)+"' "
Else
	cQrySaldo += " AND CVX_DATA BETWEEN '"+DTOS(dDatIniAnt)+"' AND '"+DTOS(dDataFin)+"' "
EndIf
cQrySaldo += " AND CVX_NIV01 = '" + cConta + "' "
If !Empty(cCusto)
	cQrySaldo += " AND CVX_NIV02 = '" + cCusto + "' "
EndIf
If !Empty(cItem)
	cQrySaldo += " AND CVX_NIV03 = '" + cItem + "' "
EndIf
If !Empty(cCLVL)
	cQrySaldo += " AND CVX_NIV04 = '" + cCLVL + "' "
EndIf
If !Empty(c5Ent)
	cQrySaldo += " AND CVX_NIV05 = '" + c5Ent + "' "
EndIf

If cPaisLoc == "COL" .and. "5" $ cEntCont
	cQrySaldo += " AND CVX_NIV05 <> '' "
EndIf

cQrySaldo += " AND CVX_MOEDA = '" + cMoeda + "' "
cQrySaldo += " AND CVX_TPSALD = '" + cTpSaldo + "' "
cQrySaldo += " AND D_E_L_E_T_ = ' ' "
cQrySaldo += " ORDER BY CVX_NIV01,CVX_NIV02,CVX_NIV03,CVX_NIV04,CVX_NIV05 "

cQrySaldo := ChangeQuery(cQrySaldo)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySaldo),"SLDCVX",.T.,.F.)

TcSetField("SLDCVX","CVX_DATA" 	  ,"D",08,0)
TcSetField("SLDCVX","CVX_SLDDEB"  ,"N",aTamSaldo[1],aTamSaldo[2])
TcSetField("SLDCVX","CVX_SLDCRD"  ,"N",aTamSaldo[1],aTamSaldo[2])

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Percorrer arquivo resultado da Query e totalizar valores em aSaldo.               ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
DbSelectArea("SLDCVX")
SLDCVX->(dbGoTop())

While SLDCVX->(!Eof())

	aSaldoAtu[1] := 0.00
	aSaldoDeb[1] := 0.00
	aSldAtuDeb[1] := 0.00
	aSldAtuCrd[1] := 0.00
	aSldAntDeb[1] := 0.00
	aSldAntCrd[1] := 0.00

	cCodConta := SLDCVX->CVX_NIV01

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Processar registros e inicializar os saldos para a 1a. Entidade, Conta Cont·bil.  ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	While SLDCVX->(!Eof()) .AND. SLDCVX->CVX_NIV01 == cCodConta

		aSaldoAtu[2] := 0.00
		aSaldoDeb[2] := 0.00
		aSldAtuDeb[2] := 0.00
		aSldAtuCrd[2] := 0.00
		aSldAntDeb[2] := 0.00
		aSldAntCrd[2] := 0.00

		cCodCusto := SLDCVX->CVX_NIV02

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Processar registros e inicializar os saldos para a 2a. Entidade, Centro de Custo. ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		While SLDCVX->(!Eof()) .AND. SLDCVX->CVX_NIV01 == cCodConta .AND. SLDCVX->CVX_NIV02 == cCodCusto

			aSaldoAtu[3] := 0.00
			aSaldoDeb[3] := 0.00
			aSldAtuDeb[3] := 0.00
			aSldAtuCrd[3] := 0.00
			aSldAntDeb[3] := 0.00
			aSldAntCrd[3] := 0.00

			cCodItem := SLDCVX->CVX_NIV03

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Processar registros e inicializar os saldos para a 3a. Entidade, Item Contabil.   ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			While SLDCVX->(!Eof()) .AND. SLDCVX->CVX_NIV01 == cCodConta .AND. SLDCVX->CVX_NIV02 == cCodCusto .AND. SLDCVX->CVX_NIV03 == cCodItem

				aSaldoAtu[4]  := 0.00
				aSaldoDeb[4]  := 0.00
				aSldAtuDeb[4] := 0.00
				aSldAtuCrd[4] := 0.00
				aSldAntDeb[4] := 0.00
				aSldAntCrd[4] := 0.00

				cCodCLVL := SLDCVX->CVX_NIV04

				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Processar registros e inicializar os saldos para a 4a. Entidade, Classe de Valor. ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				While SLDCVX->(!Eof()) .AND. SLDCVX->CVX_NIV01 == cCodConta .AND. SLDCVX->CVX_NIV02 == cCodCusto .AND.;
						SLDCVX->CVX_NIV03 == cCodItem .AND. SLDCVX->CVX_NIV04 == cCodCLVL

					aSaldoAtu[5]  := 0.00
					aSaldoDeb[5]  := 0.00
					aSaldoCrd[5]  := 0.00
					aSldAtuDeb[5] := 0.00
					aSldAtuCrd[5] := 0.00
					aSldAntDeb[5] := 0.00
					aSldAntCrd[5] := 0.00

					cCod5Ent := SLDCVX->CVX_NIV05

					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥ Processar registros e inicializar os saldos para a 5 Entidade Contabil(N.I.T.).   ≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
					While SLDCVX->(!Eof()) .AND. SLDCVX->CVX_NIV01 == cCodConta .AND. SLDCVX->CVX_NIV02 == cCodCusto .AND.;
							SLDCVX->CVX_NIV03 == cCodItem .AND. SLDCVX->CVX_NIV04 == cCodCLVL .AND. SLDCVX->CVX_NIV05 == cCod5Ent
						//Compor o Saldo Nivel 05 -> 5a. Entidade Contabil
						If SLDCVX->CVX_DATA < dDataIni

							aSldAntDeb[5] += SLDCVX->CVX_SLDDEB
							aSldAntCrd[5] += SLDCVX->CVX_SLDCRD

							nSldAntDeb += SLDCVX->CVX_SLDDEB
							nSldAntCrd += SLDCVX->CVX_SLDCRD

						Else
							aSaldoDeb[5] += SLDCVX->CVX_SLDDEB
							aSaldoCrd[5] += SLDCVX->CVX_SLDCRD
							aSldAtuDeb[5] += SLDCVX->CVX_SLDDEB
							aSldAtuCrd[5] += SLDCVX->CVX_SLDCRD

							nSaldoDeb += SLDCVX->CVX_SLDDEB
							nSaldoCrd += SLDCVX->CVX_SLDCRD
							nSldAtuDeb += SLDCVX->CVX_SLDDEB
							nSldAtuCrd += SLDCVX->CVX_SLDCRD

						EndIf
						SLDCVX->(dbSkip())
					End
					If "5" $ cEntCont
						aSaldoAtu[5] := aSaldoDeb[5] - aSaldoCrd[5]
						aSaldoAnt[5] := aSldAntDeb[5] - aSldAntCrd[5]
						If 	aSaldoAnt[5] <> 0 .OR. aSaldoAtu[5] <>0
							AADD(aSaldos,{{aSaldoAtu[5],aSaldoDeb[5],aSaldoCrd[5],aSldAtuDeb[5],aSldAtuCrd[5],aSaldoAnt[5],aSldAntDeb[5],aSldAntCrd[5]},;
										cCodConta,cCodCusto,cCodItem,cCodCLVL,cCod5Ent,"5","DC"})
						EndIf
					EndIf
				End

				//Compor o Saldo do Nivel 04 -> Classe de Valor
				aSaldoDeb[4] += nSaldoDeb
				aSaldoCrd[4] += nSaldoCrd
				aSldAntDeb[4] += nSldAntDeb
				aSldAntCrd[4] += nSldAntCrd
				aSldAtuDeb[4] += nSldAtuDeb
				aSldAtuCrd[4] += nSldAtuCrd

				If "4" $ cEntCont
					aSaldoAtu[4] := aSaldoDeb[4] - aSaldoCrd[4]
					aSaldoAnt[4] := aSldAntDeb[4] - aSldAntCrd[4]
					AADD(aSaldos,{{aSaldoAtu[4],aSaldoDeb[4],aSaldoCrd[4],aSldAtuDeb[4],aSldAtuCrd[4],aSaldoAnt[4],aSldAntDeb[4],aSldAntCrd[4]},;
									cCodConta,cCodCusto,cCodItem,cCodCLVL,"","4","DC"})
				EndIf
			End

			//Compor o Saldo do Nivel 03 -> Item Contabil
			aSaldoDeb[3] += nSaldoDeb
			aSaldoCrd[3] += nSaldoCrd
			aSldAntDeb[3] += nSldAntDeb
			aSldAntCrd[3] += nSldAntCrd
			aSldAtuDeb[3] += nSldAtuDeb
			aSldAtuCrd[3] += nSldAtuCrd

			If "3" $ cEntCont
				aSaldoAtu[3] := aSaldoDeb[3] - aSaldoCrd[3]
				aSaldoAnt[3] := aSldAntDeb[3] - aSldAntCrd[3]
				AADD(aSaldos,{{aSaldoAtu[3],aSaldoDeb[3],aSaldoCrd[3],aSldAtuDeb[3],aSldAtuCrd[3],aSaldoAnt[3],aSldAntDeb[3],aSldAntCrd[3]},;
								cCodConta,cCodCusto,cCodItem,"","","3","DC"})
			EndIf
		End

		//Compor o Saldo do Nivel 02 -> Centro de Custos
		aSaldoDeb[2] += nSaldoDeb
		aSaldoCrd[2] += nSaldoCrd
		aSldAntDeb[2] += nSldAntDeb
		aSldAntCrd[2] += nSldAntCrd
		aSldAtuDeb[2] += nSldAtuDeb
		aSldAtuCrd[2] += nSldAtuCrd

		If "2" $ cEntCont
			aSaldoAtu[2] := aSaldoDeb[2] - aSaldoCrd[2]
			aSaldoAnt[2] := aSldAntDeb[2] - aSldAntCrd[2]
			AADD(aSaldos,{{aSaldoAtu[2],aSaldoDeb[2],aSaldoCrd[2],aSldAtuDeb[2],aSldAtuCrd[2],aSaldoAnt[2],aSldAntDeb[2],aSldAntCrd[2]},;
							cCodConta,cCodCusto,"","","","2","DC"})
		EndIf
	End

	//Compor o Saldo do Nivel 01 -> Conta Cont·bil
	aSaldoDeb[1] += nSaldoDeb
	aSaldoCrd[1] += nSaldoCrd
	aSldAntDeb[1] += nSldAntDeb
	aSldAntCrd[1] += nSldAntCrd
	aSldAtuDeb[1] += nSldAtuDeb
	aSldAtuCrd[1] += nSldAtuCrd

	aSaldoAtu[1] := aSaldoDeb[1] - aSaldoCrd[1]
	aSaldoAnt[1] := aSldAntDeb[1] - aSldAntCrd[1]
	AADD(aSaldos,{{aSaldoAtu[1],aSaldoDeb[1],aSaldoCrd[1],aSldAtuDeb[1],aSldAtuCrd[1],aSaldoAnt[1],aSldAntDeb[1],aSldAntCrd[1]},;
					cCodConta,"","","","","1","DC"})
End
SLDCVX->(dbCloseArea())

If Select( "SLDCVX" ) > 0
	DbSelectArea( "SLDCVX" )
	SLDCVX->( dbCloseArea() )
Endif

CVX->(RestArea(aSaveArea))

RestArea(aSaveAnt)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Retorno:                                             ≥
//≥ [1] Saldo Atual (com sinal)                          ≥
//≥ [2] Debito na Data                                   ≥
//≥ [3] Credito na Data                                  ≥
//≥ [4] Saldo Atual Devedor                              ≥
//≥ [5] Saldo Atual Credor                               ≥
//≥ [6] Saldo Anterior (com sinal)                       ≥
//≥ [7] Saldo Anterior Devedor                           ≥
//≥ [8] Saldo Anterior Credor                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//      [1]       [2]      [3]       [4]         [5]       [6]       [7]         [8]
//{{nSaldoAtu,nSaldoDeb,nSaldoCrd,nSldAtuDeb,nSldAtuCrd,nSaldoAnt,nSldAntDeb,nSldAntCrd},cConta,cCusto,cItem,cCLVL,c5Ent}
Return aSaldos
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GetSldPlGer∫Autor  ≥Renato F. Campos   ∫ Data ≥  06/01/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥ AP                                                         ∫±±
±± 01 - cSetOfBook  : Obrigatorio informar                                ∫±±
±± 02 - dDataIni    : Obrigatorio informar                                ∫±±
±± 03 - dDataFim    : Obrigatorio informar                                ∫±±
±± 04 - cMoeda      : Obrigatorio informar                                ∫±±
±± 05 - nTamArray   : Obrigatorio informar                                ∫±±
±± 06 - lAbs        : Default = .T.                                       ∫±±
±± 07 - lTdsRgs     : Default = .F.                                       ∫±±
±± 08 - cSaldos     : Default = '1'                                       ∫±±
±± 09 - lNImpMov    : Default = .F.                                       ∫±±
±± 10 - cHeader     : Default = 'CT1'                                     ∫±±
±± 11 - lImpAntLP   : Default = .F.                                       ∫±±
±± 12 - dDataLP     : Default = Nil                                       ∫±±
±± 13 - lVlrZerado  : Default = .T.                                       ∫±±
±± 14 - cMoedaDesc  : Default = '01'                                      ∫±±
±± 15 - lMovPeriodo : Default = .F.                                       ∫±±
±± 16 - lPlGerSint  : Default = .F.                                       ∫±±
±± 17 - lConsSaldo  : Default = .F.                                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function GetSldPlGer( cSetOfBook, dDataIni, dDataFim, cMoeda, nTamArray, lAbs, lTdsRgs, cSaldos, lNImpMov,;
                      cHeader, lImpAntLP, dDataLP, lVlrZerado, cMoedaDesc, lMovPeriodo, lPlGerSint, lConsSaldo,cCtaIni,cCtaFin,aSelFil)

Local aPlanGer      := {}
Local aTemp         := {}
Local nIx           := 0
Default aSelFil     := {}
Default nTamArray   := 500
Default lAbs        := .T.
Default lTdsRgs     := .F.
Default cSaldos     := '1'
Default lNImpMov    := .F.
Default cHeader     := 'CT1'
Default lImpAntLP   := .F.
Default dDataLP     := Nil
Default lVlrZerado  := .T.
Default cMoedaDesc  := '01'
Default lMovPeriodo := .F.
Default lPlGerSint  := .F.
Default lConsSaldo  := .F.
Default cCtaIni  := ""
Default cCtaFin  := Repl("Z",Len(CT1->CT1_CONTA))

If ValType( nTamArray ) <> 'N'
	Help(" ",1,"CT5PLGER",,STR0046,1,0)//"Informe um numero de array valido"
	Return {}
Endif

if Funname() != 'CTBR710'
	For nIx := 1 To nTamArray
		If lTdsRgs
			aadd( aPlanGer , {"",0,0,0,"","","","",0,0} )
		Else
			aadd( aPlanGer , {"",0,0,0} )
		EndIf
	Next nIx
EndIf

nIx		:= 0
If VdSetOfBook( cSetOfBook , .T. )
	dbSelectArea("CTN")
	dbSetOrder(1)

	If DbSeek( xFilial( "CTN" ) + cSetOfBook )

		aTemp := {""}
		CTGerPlan(/*01*/,;
		          /*02*/,;
		          /*03*/,;
		          /*04*/.F.,;
		          /*05*/@aTemp[1],;
		          /*06*/dDataIni,;
		          /*07*/dDataFim,;
		          /*08*/"CT7",;
		          /*09*/"",;
		          /*10*/"",;
		          /*11*/Repl("Z",Len(CT1->CT1_CONTA)),;
		          /*12*/"",;
		          /*13*/Repl("Z", Len(CTT->CTT_CUSTO)),;
		          /*14*/"",;
		          /*15*/Repl("Z", Len(CTD->CTD_ITEM)),;
		          /*16*/"",;
		          /*17*/Repl("Z", Len(CTH->CTH_CLVL)),;
		          /*18*/cMoeda,;
		          /*19*/cSaldos,;
		          /*20*/CTBSetOf(cSetOfBook),;
		          /*21*/,;
		          /*22*/"",;
		          /*23*/Repl("Z",20),;
		          /*24*/,;
		          /*25*/lNImpMov,;
		          /*26*/,;
		          /*27*/,;
		          /*28*/cHeader,;
		          /*29*/lImpAntLP,;
		          /*30*/dDataLP,;
		          /*31*/,;
		          /*32*/lVlrZerado,;
		          /*33*/,;
		          /*34*/,;
		          /*35*/,;
		          /*36*/,;
		          /*37*/,;
		          /*38*/,;
		          /*39*/,;
		          /*40*/,;
		          /*41*/,;
		          /*42*/,;
		          /*43*/,;
		          /*44*/,;
		          /*45*/,;
		          /*46*/,;
		          /*47*/,;
		          /*48*/,;
		          /*49*/,;
		          /*50*/,;
		          /*51*/,;
		          /*52*/,;
		          /*53*/,;
		          /*54*/,;
		          /*55*/,;
		          /*56*/,;
		          /*57*/cMoedaDesc,;
		          /*58*/lMovPeriodo,;
		          /*59*/aSelFil,;
		          /*60*/,;
		          /*61*/lPlGerSint,;
		          /*62*/lConsSaldo)

		dbSelectArea("cArqTmp")
		dbGotop()
		nIx := 1
		While !Eof() .and. cArqTmp->CONTA <= cCtaFin
			If lTdsRgs
				if Funname() == 'CTBR710'
					If ( !Empty(nIx) .And. nIx <> Nil .And. nIx <> 0)  .and. cArqTmp->CONTA >= cCtaIni
						aadd( aPlanGer , {"",0,0,0,"","","","",0} )
						aPlanGer[nIx][1] := cArqTmp->CONTA
						aPlanGer[nIx][2] := IIf(lAbs,ABS(cArqTmp->SALDODEB),cArqTmp->SALDODEB)
						aPlanGer[nIx][3] := IIf(lAbs,ABS(cArqTmp->SALDOCRD),cArqTmp->SALDOCRD)
						aPlanGer[nIx][4] := IIf(lAbs,ABS(cArqTmp->SALDOATU),cArqTmp->SALDOATU)
						aPlanGer[nIx][5] := AllTrim(cArqTmp->DESCCTA)
						aPlanGer[nIx][6] := AllTrim(cArqTmp->TIPOCONTA)
						aPlanGer[nIx][7] := AllTrim(cArqTmp->IDENTIFI)
						aPlanGer[nIx][8] := AllTrim(cArqTmp->NORMAL)
						aPlanGer[nIx][9] := cArqTmp->COLUNA
						nIx++
					EndIf
				Else
					If Funname() $ "CTBR700A"
						nIx := aScan(aContasVG,{|x| Alltrim(x) == Alltrim(cArqTmp->CONTA)})
					Else
						nIx := val( cArqTmp->CONTA )
					EndIf
					If ( !Empty(nIx) .And. nIx <> Nil .And. nIx <> 0 .And. nTamArray >= nIx )
						aPlanGer[nIx][1] := cArqTmp->CONTA
						aPlanGer[nIx][2] := IIf(lAbs,ABS(cArqTmp->SALDODEB),cArqTmp->SALDODEB)
						aPlanGer[nIx][3] := IIf(lAbs,ABS(cArqTmp->SALDOCRD),cArqTmp->SALDOCRD)
						aPlanGer[nIx][4] := IIf(lAbs,ABS(cArqTmp->SALDOATU),cArqTmp->SALDOATU)
						aPlanGer[nIx][5] := AllTrim(cArqTmp->DESCCTA)
						aPlanGer[nIx][6] := AllTrim(cArqTmp->TIPOCONTA)
						aPlanGer[nIx][7] := AllTrim(cArqTmp->IDENTIFI)
						aPlanGer[nIx][8] := AllTrim(cArqTmp->NORMAL)
						aPlanGer[nIx][9] := IIf(lAbs,ABS(cArqTmp->SALDOANT),cArqTmp->SALDOANT)
						aPlanGer[nIx][10] := IIf(lAbs,ABS(cArqTmp->MOVIMENTO),cArqTmp->MOVIMENTO)
					EndIf
				EndIf
			Else
				IF cArqTmp->TIPOCONTA == '2'
					nIx := val( cArqTmp->CONTA )
					If ( ! Empty( nIx ) .And. nIx <> Nil .And. nIx <> 0 .and. nTamArray >= nIx )
						aPlanGer[nIx][1] := nIx
						aPlanGer[nIx][2] := IIf(lAbs,ABS(cArqTmp->SALDODEB),cArqTmp->SALDODEB)
						aPlanGer[nIx][3] := IIf(lAbs,ABS(cArqTmp->SALDOCRD),cArqTmp->SALDOCRD)
						aPlanGer[nIx][4] := IIf(lAbs,ABS(cArqTmp->SALDOATU),cArqTmp->SALDOATU)
					Endif
				Endif
			EndIf
			cArqTmp->( dbSkip() )
		EndDo
	Else
		Help( " ",1,"NOCTBLIV",,"Livro n„o encontrado",3,1)
	Endif
Endif

IF  Select("cArqTmp") > 0
	cArqTmp->(dbCloseArea())
Endif

Return aPlanGer
/*{Protheus.doc} GETMOVDIA
Redirecionada para a pasta do MI
Master/Adm/LocalizaÁıes

@author TOTVS

@version P12
@since 08/07/2019
*/
FUNCTION GETMOVDIA(cAlias,dDataini,dDataFim,cCodDiario)
Return _GETMOVDIA(@cAlias,@dDataini,@dDataFim,@cCodDiario)
/*{Protheus.doc} GETMOVLNDIA
Redirecionada para a pasta do MI
Master/Adm/LocalizaÁıes

@author TOTVS

@version P12
@since 08/07/2019
*/
FUNCTION GETMOVLNDIA(cAlias,dData,cNodia)
Return _GETMOVLNDIA(@cAlias,@dData,@cNodia)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GetSldVGerP ∫Autor ≥Felipe AurÈlio de Melo ∫ Data ≥ 23/12/08∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Retorna o saldo das visıes gerenciais de varios perÌodos    ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function GetSldVGerP(lStsPrint, oObjPrint, aPeriodos, lPivotTable, cSetOfBook, cMoeda, cMoedaDesc, lConsSaldo, cSaldos,;
                     cHeader, dDataLP, lVlrZerado, lMovPeriodo, lPlGerSint, lNImpMov, lImpAntLP, aSelFil)

Local x          := 01
Local y          := 01
Local cPer       := ""
Local nPer       := 00
Local cDsc       := ""
Local nDsc       := 00
Local lAbs       := .F.
Local lTdsRgs    := .T.
Local nContar    := 00
Local nTmArray   := 00
Local aRetOrig   := {}
Local aRetorno   := {}
Local aRetFinl   := {}
Local aRetEstr := {}
Local aCTSArea   := {}
Local aSetOfBook := CTBSetOf(cSetOfBook)

Private aContasVG	:= {}

Default aSelFil   	:= {}
Default lStsPrint   := .F.
Default oObjPrint   := Nil
Default cMoeda      := '01'
Default cMoedaDesc  := '01'
Default lConsSaldo  := .F.
Default cSaldos     := '1'
Default cHeader     := ''
Default dDataLP     := Nil
Default lVlrZerado  := .T.
Default lMovPeriodo := .F.
Default lPlGerSint  := .T.
Default lNImpMov    := .T.
Default lImpAntLP   := .F.

If ValType(oObjPrint) != "O"
	lStsPrint := .F.
EndIf

//------------------------------------------------------------//
// Localiza o maior codigo da vis„o gerencial em quest„o      //
//------------------------------------------------------------//
If FunName() $ "CTBR700A"
	QryVisGer(cSetOfBook, aContasVG)
	nTmArray := Len(aContasVG)
Else
	aCTSArea := CTS->(GetArea())
	CTS->(DbSetOrder(2))
	CTS->(DbSeek(xFilial("CTS")+aSetOfBook[5]+Replicate("Z",TamSx3("CTS_CONTAG")[1]),.T.))
	If CTS->CTS_CODPLA != cSetOfBook
		CTS->(DbSkip(-1))
	EndIf
	nTmArray := Val(CTS->CTS_CONTAG)
	CTS->(RestArea(aCTSArea))
EndIf

If nTmArray <= 0
	MsgStop(STR0047)  //"Erro na visao gerencial. As contas gerenciais nao podem conter letras no codigo, somente caracteres numericos."
	Return({{},{}})
EndIf

//------------------------------------------------------------//
// Carrega array conforme parametros e exclui arrays em branco//
//------------------------------------------------------------//
If lStsPrint;oObjPrint:SetMeter(Len(aPeriodos));EndIf
For x:=1 To Len(aPeriodos)
	If lStsPrint;oObjPrint:IncMeter();EndIf
	aRetOrig := GetSldPlGer( cSetOfBook , aPeriodos[x][1] , aPeriodos[x][2] , cMoeda , nTmArray , lAbs, lTdsRgs,;
	cSaldos, lNImpMov, cHeader, lImpAntLP, dDataLP, lVlrZerado, cMoedaDesc, lMovPeriodo, lPlGerSint, lConsSaldo,,,aSelFil)
	For y:=1 To Len(aRetOrig)
		If FunName() == "CTBR700A" .Or. !Empty(aRetOrig[y][5])
			If FunName() $ "CTBR700A|CTBR700" .And. lMovPeriodo
				aAdd(aRetorno,{StrZero(Year(aPeriodos[x][1]),4)+"/"+StrZero(Month(aPeriodos[x][1]),2),aRetOrig[y][5],aRetOrig[y][10],{aRetOrig[y][6],aRetOrig[y][7],aRetOrig[y][8]}})
			Else
				aAdd(aRetorno,{StrZero(Year(aPeriodos[x][1]),4)+"/"+StrZero(Month(aPeriodos[x][1]),2),aRetOrig[y][5],aRetOrig[y][4],{aRetOrig[y][6],aRetOrig[y][7],aRetOrig[y][8]}})
			EndIf
		EndIf
	Next y
Next x

//------------------------------------------------------------//
// Monta array conforme estrutura inicial para impress„o      //
//------------------------------------------------------------//
If !Empty(aPeriodos) .And. !Empty(aRetorno)

	//Cria array em branco conforme retorno da funÁ„o GetSldPlGer
	aRetFinl := Array((Len(aRetorno)+1),Len(aPeriodos)+1)

	//Cria array em branco para guardar informaÁıes da estrutura das linhas
	aRetEstr	:= Array((Len(aRetorno)+1),4)

	//Carrega cabeÁalho
	For x:=1 To Len(aPeriodos)+1
		If x == 1
			aRetFinl[1][x] := "PERIODOS"
			//Carrega estrutura
			aRetEstr[1][1] := "PERIODOS"
			aRetEstr[1][2] := ""
			aRetEstr[1][3] := ""
			aRetEstr[1][4] := ""
		Else
			aRetFinl[1][x] := StrZero(Year(aPeriodos[x-1][1]),4)+"/"+StrZero(Month(aPeriodos[x-1][1]),2)
		EndIf
	Next x

	//Carrega primeira coluna
	For x:=1 To Len(aRetorno)
		//Localiza posiÁ„o da coluna do array conforme cabeÁalho
		cDsc := aRetorno[x][2]
		nDsc := Ascan(aRetFinl,{|x| Upper(Alltrim(x[1])) == Upper(AllTrim(cDsc))})

		//Incluir informaÁ„o caso n„o exista registro no array final
		If nDsc == 0
			aRetFinl[x+1][1] := aRetorno[x][2]
			//Carrega estrutura
			aRetEstr[x+1][1] := aRetorno[x][2]
			aRetEstr[x+1][2] := aRetorno[x][4][1]
			aRetEstr[x+1][3] := aRetorno[x][4][2]
			aRetEstr[x+1][4] := aRetorno[x][4][3]
		EndIf
	Next x

	//Carrega itens
	For x:=1 To Len(aRetorno)
		//Localiza posiÁ„o da coluna do array conforme cabeÁalho
		cPer := aRetorno[x][1]
		nPer := aScan(aRetFinl[1],{|x| Upper(AllTrim(x)) == Upper(AllTrim(cPer)) })

		//Localiza linha no array final da informaÁ„o em quest„o
		cDsc := aRetorno[x][2]
		nDsc := Ascan(aRetFinl,{|x| Upper(Alltrim(x[1])) == Upper(AllTrim(cDsc))})

		For y:=1 To Len(aRetFinl[nDsc])
			Do Case
				Case y == 1
					aRetFinl[nDsc][y] := aRetorno[x][2]

				Case y == nPer
					aRetFinl[nDsc][y] := aRetorno[x][3]

				Case aRetFinl[nDsc][y] = Nil
					aRetFinl[nDsc][y] := 0

				Case Empty(aRetFinl[nDsc][y])
					aRetFinl[nDsc][y] := 0
			EndCase
		Next y
	Next x

	//Marca como deleta linhas do array inv·lidas
	For x:=1 To Len(aRetFinl)
		Do Case
			Case ValType(aRetFinl[x]) = "U"
				//Desconsiderar pois ja foi marcado como deletado
			Case ValType(aRetFinl[x][1]) = "U"
				aDel(aRetFinl,x)
				aDel(aRetEstr,x)
				nContar ++
				x --
			Case Empty(aRetFinl[x][1])
				aDel(aRetFinl,x)
				aDel(aRetEstr,x)
				nContar ++
				x --
		EndCase
	Next x
	//Exclui registro nulo do array deixado pelo comando aDel
	aSize(aRetFinl,Len(aRetFinl)-nContar)
	aSize(aRetEstr,Len(aRetEstr)-nContar)

EndIf

//Transpor: Torna colunas em linhas e linhas em colunas
If lPivotTable .And. Len(aRetFinl) > 0
	aRetFinl := PivotTable(aRetFinl)
EndIf

Return({aRetFinl,aRetEstr})

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±
±±≥FunáÖo	 ≥PivotTable≥ Autor ≥ Felipe AurÈlio de Melo ≥ Data ≥ 17.12.08 ≥±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±
±±≥DescriáÖo ≥                                                             ≥±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±
±±≥Retorno	 ≥ Nenhum                                                      ≥±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±
±±≥Parametros≥ Nenhum                                                      ≥±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function PivotTable(aItens)
Local x := 1
Local y := 1
Local nCol := 0
Local nLin := 0
Local aConvert := {}

If !Empty(aItens)
	nCol := Len(aItens)
	nLin := Len(aItens[1])

	//Cria estrutura
	aConvert := Array(nLin,nCol)

	//Carrega nova estrutura
	For x:=1 To Len(aItens)
		For y:=1 To Len(aItens[x])
			aConvert[y][x] := aItens[x][y]
		Next y
	Next x

EndIf

Return(aConvert)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ QRYDIOPS    ≥ Autor ≥ Davi Torchio            ≥ Data ≥ 25/04/08 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Query para verificar a quantidade de registros do CT1		   ≥±±
±±≥          ≥ o saldo do Registro I150 no manad.                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ QRYDIOPS()                                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ CARACTER                                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cGrupo - Tipo da conta da ANS para filtro                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
FUNCTION QRYDIOPS(cGrupo)

Local cQuery     := ""
Local cTotConta  := 0

Default cGrupo := ""

cQuery := "SELECT COUNT (CT1_CONTA) CONTA"
cQuery += "	FROM " + RetSqlName("CT1")
cQuery += "	WHERE CT1_DIOPS = '"+cGrupo+"'"
cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYCT1",.T.,.F.)

cTotConta := STR(QRYCT1->CONTA)

dbCloseArea()

Return cTotConta

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ TRBDIOPS    ≥ Autor ≥ Davi Torchio            ≥ Data ≥ 25/04/08 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Cria arquivo temporario AT1 somente com as contas do tipo da ANS≥±±
±±≥          ≥ 																   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ TRBDIOPS()                                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ CARACTER                                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cGrupo - Tipo da conta da ANS para filtro                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
FUNCTION TRBDIOPS(cGrupo)

Local aSaveArea 	:= GetArea()
Local cQuery     	:= ""
Local cContaIni 	:= ""
Local cContaFim 	:= ""
Local cSetOfBook 	:= ""
Local cMoeda 		:= "01"

Default cGrupo 		:= ""

cQuery := "SELECT *"
cQuery += "	FROM " + RetSqlName("CT1")
cQuery += "	WHERE CT1_DIOPS = '"+cGrupo+"'"
cQuery += "	AND D_E_L_E_T_ = ' '"
cQuery += "	ORDER BY CT1_CTASUP, CT1_CONTA"

cQuery := ChangeQuery(cQuery)

If Select("AT1") > 0
	dbSelectArea("AT1")
	dbCloseArea()
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"AT1",.T.,.F.)

dbSelectArea("AT1")
dbGoTop()
cContaIni := CT1_CONTA

dbSelectArea("AT1")
WHILE !EOF()
	cContaFim := CT1_CONTA
	DBSKIP()
ENDDO

CTGerPlan(,,,.F.,"AT1",dDataIni,dDataFim,"CT7","",cContaIni,cContaFim,;
			"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
			"",Repl("Z", Len(CTH->CTH_CLVL)),cMoeda,"1",CTBSetOf(cSetOfBook),Space(2),Space(20),Repl("z",20),Space(30),.F.,.T.,2,"CT1",.F./*lImpAntLP*/,,1,.T.,,,,,,,,,,,,,,.T.,,.T.)

dbSelectArea("cArqTmp")

dbGotop()

RestArea(aSaveArea)

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  | SldDiops ∫Autor  ≥  Microsiga         ∫ Data ≥  10/21/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Retorna o saldo das contas para o diops                    ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

FUNCTION SldDiops(cConta,nQualSld)

Local aSaldo := {}

dbSelectArea("cArqTmp")

dbSeek(cConta)

Aadd(aSaldo,ABS(cArqTmp->SALDODEB))//1
Aadd(aSaldo,ABS(cArqTmp->SALDOCRD))//2
Aadd(aSaldo,ABS(cArqTmp->SALDOANT))//3
Aadd(aSaldo,ABS(cArqTmp->SALDOATU))//4

Return aSaldo[nQualSld]

//-------------------------------------------------------------------
/*{Protheus.doc} CTBGerClean
FunÁ„o respons·vel por limpar os arquivos tempor·rio do banco das funÁıes GerPlan de relatÛrio.

@author Alvaro Camillo Neto

@version P12
@since   01/06/2015
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function CTBGerClean()

If _oTempTable <> Nil
	_oTempTable:Delete()
	_oTempTable := Nil
Endif

If _oTempTbPLRef <> Nil
	_oTempTbPLRef:Delete()
	_oTempTbPLRef := Nil
Endif


Return


//-------------------------------------------------------------------
/*{Protheus.doc} CTB_Vazio
FunÁ„o monta array aEntVazio para uso na funcao CtbSldCubo para indicar se deve considerar campos nivXX vazio na query que restaura saldo.

@author Paulo Carnelossi

@version P12
@since   30/06/2017
@return  array com n elementos .T./ .F. para cada nivel do cubo
@obs
*/
//-------------------------------------------------------------------
Function Ctb_Vazio(aEntidIni)
Local nX
Local aRetVazio := {}

For nX := 1 TO Len(aEntidIni)
	aAdd( aRetVazio, Empty( Alltrim( aEntidIni[nX] ) ) )
Next

Return( aRetVazio  )

//--------------------------------------------------
/*/{Protheus.doc} CTSPCTTSup
Procedure para criar tabela com centros de custos
superiores a partir do centro analitico.

@author TOTVS
@since 05/07/2018
@version P12.1.17

@param cAliasTmp ,caracter,Alias da tabela temporaria
@param cTabelaTmp,caracter,ID da tabela temporaria no banco
@param cCustoIni ,caracter,Centro de custo inicial a ser processado
@param cCustoFim ,caracter,Centro de custo final a ser processado
@param cMoeda    ,caracter,Moeda para obtenÁ„o da descriÁ„o do centro de custo

@return lRet     ,lÛgica  ,Indica se o processo concluiu com sucesso
/*/
//--------------------------------------------------
Static Function CTSPCTTSup(cAliasTmp,cTabelaTmp,cCustoIni,cCustoFim,cMoeda)
Local cQuery		:= ""
Local cProc			:= CriaTrab(,.F.)+"SUPCTT_"+cEmpAnt
Local lRet			:= .T.
Local aResult		:= {}
Local nTamCusto		:= TamSX3("CTT_CUSTO")[1]
Local aCamposCTT	:= {}
Local lDB2			:= Upper(AllTrim(TCGetDb())) == "DB2"

If __oTmpCTT <> Nil
	__oTmpCTT:Delete()
EndIf

//------------------------------------------------------
// Cria tabela temporaria para contas superiores da CTT
//------------------------------------------------------
aCamposCTT := {	{"CTT_ID"		,"C",TamSX3("CTT_CUSTO")[1]	, 0 },;
				{"CTT_CUSTO"	,"C",TamSX3("CTT_CUSTO")[1]	, 0 },;
				{"CTT_CCSUP"	,"C",TamSX3("CTT_CCSUP")[1]	, 0 },;
				{"CTT_DESC"		,"C",TamSX3("CTT_DESC01")[1], 0 },;
				{"CTT_RES"		,"C",TamSX3("CTT_RES")[1]	, 0 },;
				{"CTT_CLASSE"	,"C",TamSX3("CTT_CLASSE")[1], 0 }}

__oTmpCTT := FWTemporaryTable():New(GetNextAlias())
__oTmpCTT:SetFields( aCamposCTT )
__oTmpCTT:AddIndex("1",{"CTT_ID"})
__oTmpCTT:Create()

cAliasTmp	:= __oTmpCTT:GetAlias()
cTabelaTmp	:= __oTmpCTT:GetRealName()


cQuery := "Create Procedure "+cProc+" ("+CRLF
cQuery += "   @IN_CUSTOINI Char( "+StrZero(nTamCusto,3)+" ),"+CRLF
cQuery += "   @IN_CUSTOFIM Char( "+StrZero(nTamCusto,3)+" ),"+CRLF
cQuery += "   @OUT_RESULT  Char( 01 ) OutPut"+CRLF
cQuery += ")"+CRLF

cQuery += "as"+CRLF
cQuery += "declare @cCodigo    Char( "+StrZero(nTamCusto              ,3)+" )"+CRLF
cQuery += "declare @cCusto     Char( "+StrZero(nTamCusto              ,3)+" )"+CRLF
cQuery += "declare @cCodAux    Char( "+StrZero(nTamCusto              ,3)+" )"+CRLF
cQuery += "declare @cSup       Char( "+StrZero(nTamCusto              ,3)+" )"+CRLF
cQuery += "declare @cSupAux    Char( "+StrZero(nTamCusto              ,3)+" )"+CRLF
cQuery += "declare @cDesc      Char( "+StrZero(TamSX3("CTT_DESC01")[1],3)+" )"+CRLF
cQuery += "declare @cRes       Char( "+StrZero(TamSX3("CTT_RES")[1]   ,3)+" )"+CRLF
cQuery += "declare @cClasse    Char( "+StrZero(TamSX3("CTT_CLASSE")[1],3)+" )"+CRLF

cQuery += "Declare @iRecnoAux  integer"+CRLF

cQuery += "begin"+CRLF
cQuery += "   Select @OUT_RESULT = '0'"+CRLF
cQuery += "   Select @cCodigo = ''"+CRLF
cQuery += "   Select @cCusto  = ''"+CRLF
cQuery += "   Select @cSup    = ''"+CRLF
cQuery += "   Select @cCodAux = ''"+CRLF
cQuery += "   Select @cSupAux = ''"+CRLF
cQuery += "   Select @cDesc   = ''"+CRLF
cQuery += "   Select @cRes    = ''"+CRLF
cQuery += "   Select @cClasse = ''"+CRLF

cQuery += "   Declare CTTSup cursor for"+CRLF
cQuery += "   Select CTT_CUSTO, CTT_CCSUP, CTT_DESC" + cMoeda + ", CTT_RES, CTT_CLASSE "+CRLF
cQuery += "     From "+RetSQLName("CTT")+CRLF
cQuery += "    where CTT_FILIAL = '" + XFilial("CTT") + "' "+CRLF
cQuery += "      AND CTT_CUSTO BETWEEN @IN_CUSTOINI AND @IN_CUSTOFIM "+CRLF
cQuery += "      AND CTT_CLASSE   = '2'"+CRLF
cQuery += "      AND D_E_L_E_T_ = ' '"+CRLF
cQuery += "   for read only"+CRLF

cQuery += "   Open CTTSup"+CRLF
cQuery += "   Fetch CTTSup into @cCodigo, @cSup, @cDesc, @cRes, @cClasse"+CRLF

cQuery += "   While @@fetch_status = 0  begin"+CRLF

cQuery += "       Insert into "+cAliasTmp+" ( CTT_ID ,CTT_CUSTO,CTT_CCSUP,CTT_DESC,CTT_RES,CTT_CLASSE )"+CRLF
cQuery += "                          Values( @cCodigo,@cCodigo ,@cSup    ,@cDesc  ,@cRes  ,@cClasse )"+CRLF

      /* -------------------------------
          Ir subindo ate o ultimo nivel
         ------------------------------- */
cQuery += "      select @cCodAux = @cSup"+CRLF
cQuery += "      select @cSupAux = @cSup"+CRLF
cQuery += "      While @cCodAux != ' ' begin"+CRLF

cQuery += "         Select @iRecnoAux = null"+CRLF
cQuery += "         Select @iRecnoAux = R_E_C_N_O_"+CRLF
cQuery += "           From "+RetSqlName("CTT")+CRLF
cQuery += "          Where CTT_FILIAL = '" + XFilial("CTT") + "' "+CRLF
cQuery += "            and CTT_CUSTO = @cSupAux"+CRLF
cQuery += "            and D_E_L_E_T_ = ' '"+CRLF

cQuery += "         If @iRecnoAux is not null begin"+CRLF
cQuery += "            Select  @cCusto = CTT_CUSTO, @cCodAux = CTT_CCSUP, @cDesc = CTT_DESC" + cMoeda + ", @cRes = CTT_RES, @cClasse = CTT_CLASSE "+CRLF
cQuery += "              From "+RetSqlName("CTT")+CRLF
cQuery += "             Where CTT_FILIAL = '" + XFilial("CTT") + "' "+CRLF
cQuery += "               and CTT_CUSTO = @cSupAux"+CRLF
cQuery += "               and D_E_L_E_T_ = ' '"+CRLF

cQuery += "               Insert into "+cAliasTmp+" ( CTT_ID, CTT_CUSTO, CTT_CCSUP, CTT_DESC, CTT_RES, CTT_CLASSE )"+CRLF
cQuery += "                              Values( @cCodigo, @cCusto, @cCodAux, @cDesc, @cRes, @cClasse )"+CRLF

cQuery += "            select @cSupAux = @cCodAux"+CRLF
cQuery += "         End else begin"+CRLF
cQuery += "            select @cCodAux = ' '"+CRLF
cQuery += "         End"+CRLF
cQuery += "      End"+CRLF

If lDB2
	cQuery += "  select @fim_CUR = 0"+CRLF
EndIf

cQuery += "      Fetch CTTSup into @cCodigo, @cSup, @cDesc, @cRes, @cClasse"+CRLF
cQuery += "   End"+CRLF
cQuery += "   close CTTSup"+CRLF
cQuery += "   deallocate CTTSup"+CRLF
cQuery += "   Select @OUT_RESULT = '1'"+CRLF
cQuery += "end"+CRLF

cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.f., cQuery, 0)

//--------------------------------------------------------------------------
// Ajusta a procedure para o nome real da tabela temporaria, n„o È inserida
// antes pois o nome contem # e o MsParse acaba invalidando
//--------------------------------------------------------------------------
cQuery := StrTran(cQuery, cAliasTmp, cTabelaTmp)

If Empty( cQuery )
	lRet := .F.
	Help(" ",1,"CTSPCTTSup",,STR0049 + " " + cProc  + MSParseError(),1,0) //"A procedure nao passou pelo Parse."
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				lRet:= .F.
				Help(" ",1,"CTSPCTTSup",,STR0043 + " " + cProc + ": " + TCSqlError() ,1,0) //'Erro na criacao da procedure'
			EndIf
		EndIf
	EndIf
EndIf

If lRet
	aResult := TCSPExec( cProc, cCustoIni, cCustoFim )

	If Empty(aResult) .Or. Empty(aResult[1]) .Or. aResult[1] = "0"
		lRet := .f.
		Help(" ",1,"CTSPCTTSup",,STR0050 + " " + cProc + ": " + TCSqlError(),1,0) //'Erro na execucao da procedure'
	EndIf
EndIf

If TCSPExist(cProc)
	If TcSqlExec("Drop procedure " + cProc) <> 0
		Help(" ",1,"CTSPCTTSup",,STR0051 + " " + cProc,1,0) //"Erro na exclus„o da procedure"
	Endif
EndIf

Return(lRet)

//--------------------------------------------------
/*/{Protheus.doc} CTSPCT1Sup
Procedure para criar tabela com as contas contabeis
superiores a partir da conta analitica.

@author TOTVS
@since 05/07/2018
@version P12.1.17

@param cAliasTmp ,caracter,Alias da tabela temporaria
@param cTabelaTmp,caracter,ID da tabela temporaria no banco
@param cContaIni ,caracter,Conta contabil inicial a ser processada
@param cContaFim ,caracter,Conta cont·bil final a ser processada
@param cMoeda    ,caracter,Moeda para obtenÁ„o da descriÁ„o da conta contabil

@return lRet     ,lÛgica  ,Indica se o processo concluiu com sucesso
/*/
//--------------------------------------------------
Static Function CTSPCT1Sup(cAliasTmp,cTabelaTmp,cContaIni,cContaFim,cMoeda)
Local cQuery		:= ""
Local cProc			:= CriaTrab(,.F.)+"SUPCT1_"+cEmpAnt
Local lRet			:= .T.
Local aResult		:= {}
Local nTamConta		:= TamSX3("CT1_CONTA")[1]
Local aCamposCT1	:= {}
Local lDB2			:= Upper(AllTrim(TCGetDb())) == "DB2"

If __oTmpCT1 <> Nil
	__oTmpCT1:Delete()
EndIf

//------------------------------------------------------
// Cria tabela temporaria para contas superiores da CT1
//------------------------------------------------------
aCamposCT1 := {	{"CT1_ID"		, "C", TamSX3("CT1_CONTA")[1]	, 0 },;
				{"CT1_CONTA"	, "C", TamSX3("CT1_CONTA")[1]	, 0 },;
				{"CT1_CTASUP"	, "C", TamSX3("CT1_CTASUP")[1]	, 0 },;
				{"CT1_DESC"		, "C", TamSX3("CT1_DESC01")[1]	, 0 },;
				{"CT1_RES"		, "C", TamSX3("CT1_RES")[1]		, 0 },;
				{"CT1_CLASSE"	, "C", TamSX3("CT1_CLASSE")[1]	, 0 },;
				{"CT1_GRUPO"	, "C", TamSX3("CT1_GRUPO")[1]	, 0 }}

__oTmpCT1 := FWTemporaryTable():New(GetNextAlias())
__oTmpCT1:SetFields( aCamposCT1 )
__oTmpCT1:AddIndex("1",{"CT1_ID"})
__oTmpCT1:Create()

cAliasTmp	:= __oTmpCT1:GetAlias()
cTabelaTmp	:= __oTmpCT1:GetRealName()


cQuery := "Create Procedure "+cProc+" ("+CRLF
cQuery += "   @IN_CONTAINI  Char( "+StrZero(nTamConta,3)+" ),"+CRLF
cQuery += "   @IN_CONTAFIM  Char( "+StrZero(nTamConta,3)+" ),"+CRLF
cQuery += "   @OUT_RESULT Char( 01 ) OutPut"+CRLF
cQuery += ")"+CRLF

cQuery += "as"+CRLF
cQuery += "declare @cCodigo  Char( "+StrZero(nTamConta              ,3)+" )"+CRLF
cQuery += "declare @cConta   Char( "+StrZero(nTamConta              ,3)+" )"+CRLF
cQuery += "declare @cSup     Char( "+StrZero(nTamConta              ,3)+" )"+CRLF
cQuery += "declare @cCodAux  Char( "+StrZero(nTamConta              ,3)+" )"+CRLF
cQuery += "declare @cSupAux  Char( "+StrZero(nTamConta              ,3)+" )"+CRLF
cQuery += "declare @cDesc    Char( "+StrZero(TamSX3("CT1_DESC01")[1],3)+" )"+CRLF
cQuery += "declare @cRes     Char( "+StrZero(TamSX3("CT1_RES")[1]   ,3)+" )"+CRLF
cQuery += "declare @cClasse  Char( "+StrZero(TamSX3("CT1_CLASSE")[1],3)+" )"+CRLF
cQuery += "declare @cGrupo   Char( "+StrZero(TamSX3("CT1_GRUPO")[1] ,3)+" )"+CRLF

cQuery += "Declare @iRecnoAux  integer"+CRLF

cQuery += "begin"+CRLF
cQuery += "   Select @OUT_RESULT = '0'"+CRLF
cQuery += "   Select @cCodigo = ''"+CRLF
cQuery += "   Select @cConta = ''"+CRLF
cQuery += "   Select @cSup    = ''"+CRLF
cQuery += "   Select @cCodAux = ''"+CRLF
cQuery += "   Select @cSupAux = ''"+CRLF
cQuery += "   Select @cDesc   = ''"+CRLF
cQuery += "   Select @cRes    = ''"+CRLF
cQuery += "   Select @cClasse = ''"+CRLF
cQuery += "   Select @cGrupo  = ''"+CRLF

cQuery += "   Declare CT1Sup cursor for"+CRLF
cQuery += "   Select CT1_CONTA, CT1_CTASUP, CT1_DESC" + cMoeda + ", CT1_RES, CT1_CLASSE, CT1_GRUPO "+CRLF
cQuery += "     From "+RetSqlName("CT1")+CRLF
cQuery += "    where CT1_FILIAL = '" + XFilial("CT1") + "' "+CRLF
cQuery += "      AND CT1_CONTA BETWEEN @IN_CONTAINI AND @IN_CONTAFIM "+CRLF
cQuery += "      AND CT1_CLASSE   = '2'"+CRLF
cQuery += "      AND D_E_L_E_T_ = ' '"+CRLF
cQuery += "   for read only"+CRLF

cQuery += "   Open CT1Sup"+CRLF
cQuery += "   Fetch CT1Sup into @cCodigo, @cSup, @cDesc, @cRes, @cClasse, @cGrupo"+CRLF

cQuery += "   While @@fetch_status = 0  begin"+CRLF

cQuery += "       Insert into "+cAliasTmp+" ( CT1_ID ,CT1_CONTA ,CT1_CTASUP ,CT1_DESC ,CT1_RES ,CT1_CLASSE ,CT1_GRUPO )"+CRLF
cQuery += "                         Values( @cCodigo ,@cCodigo  ,@cSup      ,@cDesc   ,@cRes   ,@cClasse   ,@cGrupo )"+CRLF

      /* -------------------------------
          Ir subindo ate o ultimo nivel
         ------------------------------- */
cQuery += "      select @cCodAux = @cSup"+CRLF
cQuery += "      select @cSupAux = @cSup"+CRLF
cQuery += "      While @cCodAux != ' ' begin"+CRLF

cQuery += "         Select @iRecnoAux = null"+CRLF
cQuery += "         Select @iRecnoAux = R_E_C_N_O_"+CRLF
cQuery += "           From "+RetSqlName("CT1")+CRLF
cQuery += "          Where CT1_FILIAL = '" + XFilial("CT1") + "' "+CRLF
cQuery += "            and CT1_CONTA = @cSupAux"+CRLF
cQuery += "            and D_E_L_E_T_ = ' '"+CRLF

cQuery += "         If @iRecnoAux is not null begin"+CRLF
cQuery += "            Select @cConta = CT1_CONTA, @cCodAux = CT1_CTASUP, @cDesc = CT1_DESC" + cMoeda + ", @cRes = CT1_RES, @cClasse = CT1_CLASSE, @cGrupo = CT1_GRUPO "+CRLF
cQuery += "              From "+RetSqlName("CT1")+CRLF
cQuery += "             Where CT1_FILIAL = '" + XFilial("CT1") + "' "+CRLF
cQuery += "               and CT1_CONTA = @cSupAux"+CRLF
cQuery += "               and D_E_L_E_T_ = ' '"+CRLF

cQuery += "               Insert into "+cAliasTmp+" ( CT1_ID, CT1_CONTA, CT1_CTASUP, CT1_DESC, CT1_RES, CT1_CLASSE, CT1_GRUPO )"+CRLF
cQuery += "                              Values( @cCodigo, @cConta, @cCodAux, @cDesc, @cRes, @cClasse, @cGrupo )"+CRLF

cQuery += "            select @cSupAux = @cCodAux"+CRLF
cQuery += "         End else begin"+CRLF
cQuery += "            select @cCodAux = ' '"+CRLF
cQuery += "         End"+CRLF
cQuery += "      End"+CRLF

If lDB2
	cQuery += "  select @fim_CUR = 0"+CRLF
EndIf

cQuery += "      Fetch CT1Sup into @cCodigo, @cSup, @cDesc, @cRes, @cClasse, @cGrupo"+CRLF
cQuery += "   End"+CRLF
cQuery += "   close CT1Sup"+CRLF
cQuery += "   deallocate CT1Sup"+CRLF
cQuery += "   Select @OUT_RESULT = '1'"+CRLF
cQuery += "end"+CRLF

cQuery := MsParse(cQuery,If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.f., cQuery, 0)

//--------------------------------------------------------------------------
// Ajusta a procedure para o nome real da tabela temporaria, n„o È inserida
// antes pois o nome contem # e o MsParse acaba invalidando
//--------------------------------------------------------------------------
cQuery := StrTran(cQuery, cAliasTmp, cTabelaTmp)

If Empty( cQuery )
	lRet := .F.
	Help(" ",1,"CTSPCT1Sup",,STR0049 + " " + cProc  + MSParseError(),1,0) //"A procedure nao passou pelo Parse."
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				lRet:= .F.
				Help(" ",1,"CTSPCT1Sup",,STR0043 + " " + cProc + ": " + TCSqlError() ,1,0) //'Erro na criacao da procedure'
			EndIf
		EndIf
	EndIf
EndIf

If lRet
	aResult := TCSPExec( cProc, cContaIni,cContaFim )

	If Empty(aResult) .Or. Empty(aResult[1]) .Or. aResult[1] = "0"
		lRet := .f.
		Help(" ",1,"CTSPCT1Sup",,STR0050 + " " + cProc + ": " + TCSqlError(),1,0) //'Erro na execucao da procedure'
	EndIf
EndIf

If TCSPExist(cProc)
	If TcSqlExec("Drop procedure " + cProc) <> 0
		Help(" ",1,"CTSPCT1Sup",,STR0051 + " " + cProc,1,0) //"Erro na exclus„o da procedure"
	Endif
EndIf

ASize(aCamposCT1,0)
ASize := Nil

Return(lRet)
//-------------------------------------------------------------------
/*{Protheus.doc} CtbLoadHash
Carrega as informaÁıes de natureza no objeto hashmap

@author TOTVS

@param cContaIni	  InÌcio do intervalo de contas
@param cContaFim	  Fim do intervalo de contas

@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Static Function CtbLoadHash(cContaIni,cContaFim)
Local aArea 	  := GetArea()
Local aAreaCT1    := CT1->(GetArea())

DEFAULT cContaIni := ""
DEFAULT cContaFim := ""

_oHashCt1 := tHashMap():New()

If cContaFim >= cContaIni

	If Empty(cContaIni)
		cContaIni := "" //Retiro os espaÁos para posicionar no primeiro registro da filial
	EndIf

	CT1->(dbSetOrder(1))
	If CT1->(dbSeek(xFilial("CT1")+cContaIni))
		While !CT1->(Eof()) .And. CT1->(CT1_FILIAL+CT1_CONTA) <= xFilial("CT1")+cContaFim
			_oHashCt1:Set(CT1->CT1_CONTA,CT1->CT1_NATCTA)
			CT1->(dbSkip())
		EndDo

	EndIf

EndIf

RestArea(aAreaCT1)
RestArea(aArea)

Return

/*/{Protheus.doc} QryVisGer
//Query a visiÛn gerencial para extraer lista de cÛdigos de entidad de gestiÛn.

@author arodriguez
@since 28/04/2020
@version 1.0

@param cSetOfBook, characters, cÛdigo de visiÛn gerencial.
@param aContasVG, array, arreglo a llenar con cÛdigos de entidad de gestiÛn.

@return Nil
/*/
Static Function QryVisGer(cSetOfBook, aContasVG)
local aArea	   	:= GetArea()
Local cAliasqry	:= ""

If !Empty(cSetOfBook)

	cAliasqry := GetNextAlias()

	If Select( cAliasqry ) > 0
		dbSelectArea( cAliasqry )
		dbCloseArea()
	EndIf

	BeginSql Alias cAliasqry

		SELECT CVF_CONTAG AS CONTA
		FROM %table:CVF% CVF
		WHERE	CVF_FILIAL = (%exp:xFilial('CVF')%)
		 AND	CVF_CODIGO = (%exp:cSetOfBook%)
		 AND	CVF.%notDel%
		ORDER BY CVF_ORDEM

	EndSql

	dbSelectArea(cAliasqry)
	dbGotop()

	Do While (cAliasqry)->(!Eof())
		aAdd( aContasVG , CONTA )
		dbSkip()
	Enddo

	dbCloseArea()
	RestArea(aArea)

EndIf

Return Nil

/*/{Protheus.doc} GetCTSCol
Retorna dado conforme o tipo esperado
@type function
@version  
@author vitor.pires
@since 05/05/2022
@param xValor, variant, Valor recebdo do campo CTS_COLUNA ou CVF_COLUNA
@param cTipo, character, Tipo do campo esperado
@return variant, Tipo do dado
/*/
Function GetCTSCol(xValor,cTipo, cAlias)

Local xRet 	:= xValor
Local aArea := {}

DEFAULT cAlias := "CTS"

aArea := (cAlias)->(GetArea())

If cTipo == 'C'
	xRet := cValToChar(xValor)
Else
	If !(Valtype(xValor) == cTipo)
		xRet := Val(xValor)
	EndIf
EndIf

RestArea(aArea)

Return( xRet )
