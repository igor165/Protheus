#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBA104.CH"
#INCLUDE "COLORS.CH"

STATIC nQtdEntid

STATIC _lForcHead := .T.
STATIC _lForcCrTmp := .T.
STATIC _aCampos	:= Nil
STATIC _aAltera	:= Nil
STATIC _aHeadCtb	:= Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA104   บAutor  ณMicrosiga           บ Data ณ  11/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de Lanctos Contabeis II                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBA104()
Local	cAlias		:= "CTC"
Local   oBrowse
Local   nX
Local   aLegenda 

Private cCadastro	:= STR0001 //"Lanctos Contab. II
Private aRotina		:= MenuDef()


Private dDataLanc
Private cLote
Private cLoteSub 	:= GetMv("MV_SUBLOTE")
Private cSubLote 	:= cLoteSub
Private lSubLote 	:= Empty(cSubLote)
Private cDoc

Private __lCusto	:= CtbMovSaldo("CTT")
Private __lItem		:= CtbMovSaldo("CTD")
Private __lCLVL		:= CtbMovSaldo("CTH")

_lForcHead := .T.
_lForcCrTmp := .T.

If nQtdEntid == NIL
	nQtdEntid := If(FindFunction("CtbQtdEntd"),CtbQtdEntd(),4) //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf


dbSelectArea("CT2")
dbSetOrder(1)

dbSelectArea("CTC")
dbSetOrder(1)


oBrowse := FWMBrowse():New()
oBrowse:DisableDetails()

oBrowse:SetAlias(cAlias)
oBrowse:SetDescription(cCadastro)
aLegenda := CtbLegenda(cAlias)
for nX := 1 To Len(aLegenda)
	oBrowse:AddLegend( aLegenda[nX,1],  aLegenda[nX,2] ,  aLegenda[nX,3] )
next
		
oBrowse:Activate()

dbSetOrder(1)    

If Select("TMP")
	dbSelectArea("TMP")
	dbCloseArea()
EndIf

dbSelectArea(cAlias)

// limpa a o cache do fonte ctba105 quando sair da tela.
If Findfunction( "ClearCx105" )
	ClearCx105()
Endif

If ! _lForcCrTmp
	//volta as variaveis static deste fonte ao estado original
	_lForcHead := .T.
	_lForcCrTmp := .T.
	_aCampos	:= Nil
	_aAltera	:= Nil
	_aHeadCtb	:= Nil
	//seta variaveis static ao valor original do fonte ctba105 ref. cria็ใo da tabela e aheader do temporario
	Ct105VOrig()
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณMicrosiga              ณ Data ณ05/09/11  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transacao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ    1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina := { 	{ OemToAnsi(STR0002), "AxPesqui"	, 0 , 1,,.F.},;	//"Pesquisar"
					{ OemToAnsi(STR0003), "CTBA104Cap"	, 0 , 2},;		//"Visualizar"
					{ OemToAnsi(STR0004), "CTBA104Cap"	, 0 , 3},;		//"Incluir"
					{ OemToAnsi(STR0005), "CTBA104Cap"	, 0 , 4},;		//"Alterar"
					{ OemToAnsi(STR0006), "CTBA104Cap"	, 0 , 5}}		//"Excluir"

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA104CapบAutor  ณMicrosiga           บ Data ณ  05/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a tela da capa do lote                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBA104Cap(cAlias, nReg, nOpc)

Local oDlg
Local oDataLanc
Local oLote
Local oSubLote
Local oDoc
Local oLivDia
Local oNroDia
Local oDocHis
Local oMoeda
Local oCritConv
Local oDtTaxConv
Local oTipoSaldo
Local oTotDoc
Local oTotLote

Local oLinha

Local cTitulo		:= STR0008 //"Capa do Lote - Lancamentos Contabeis"
Local lContinua		:= .F.
Local cProg			:= "CTBA104"

Local lDigita		:= .F.
Local l104Inclui	:= .F.
Local l104Visual	:= .F.
Local l104Altera	:= .F.
Local l104Exclui	:= .F.
              
Local cLivDia		:= ""		//Livro Diario
Local cNroDia		:= ""		//Nro. Diario
Local cDocHis		:= ""		//Historico do Documento
Local cMoeda		:= ""		//Moeda
Local cCritConv		:= ""		//Criterio Conv.
Local dDtTaxConv	:= STOD("")	//Dt. Taxa Conv.
Local cTipoSaldo	:= ""		//Tipo de Saldo
Local nTotDoc		:= 0		//Do Documento
Local nTotLote		:= 0		//Do Lote

Local lSeqCorr		:= FindFunction("UsaSeqCor") .AND. UsaSeqCor("CT2/CTK/CT5") // Controle do Correlativo

Local cLinha		:= "" 

Local CTF_LOCK		:= 0		//Declara็ใo para utiliza็ใo da funcao C050Next

Private nSaida 	:= 0

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Do Case
		Case nOpc == 2
			l104Visual	:= .T.
		Case nOpc == 3
			l104Inclui	:= .T.
			lDigita		:= .T.
		Case nOpc ==  4
			l104Altera	:= .T.
		Case nOpc ==  5
			l104Exclui	:= .T.
			l104Visual	:= .T.
	EndCase

	If l104Inclui
		dDataLanc	:= dDataBase											//Data Lancamento
		cLote		:= CriaVar("CTC_LOTE",.F.)								//Lote
		cSubLote	:= If(lSubLote,CriaVar("CTC_SBLOTE",.F.),cLoteSub)		//SubLote
		cDoc		:= CriaVar("CTC_DOC",.F.)								//Documento
		cDocHis		:= CriaVar("CTC_DOCHIS"	,.F.)							//Historico do Documento
		cMoeda		:= CriaVar("CTC_MOEDA"	,.F.)							//Moeda
		cCritConv	:= CriaVar("CTC_CRITDC"	,.F.)							//Criterio Conv.
		dDtTaxConv	:= CriaVar("CTC_DTTXDC"	,.F.)							//Dt. Taxa Conv.
		cTipoSaldo	:= CriaVar("CTC_TPSALD"	,.F.)							//Tipo de Saldo
		cLivDia		:= If(lSeqCorr,CtbRdia(),CriaVar("CTC_DIACTB",.F.))	//Livro Diario
		cNroDia		:= If(lSeqCorr,CTBSQCor("",cLivDia,dDataLanc),;		//Nro. Diario
						CriaVar("CTC_NODIA",.F.))
		nTotDoc		:= 0													//Do Documento
		nTotLote	:= 0													//Do Lote
		
	ElseIf l104Altera .Or. l104Visual .Or. l104Exclui
		dDataLanc	:= CTC->CTC_DATA	//Data Lancamento
		cLote		:= CTC->CTC_LOTE	//Lote
		cSubLote	:= CTC->CTC_SBLOTE	//SubLote
		cDoc		:= CTC->CTC_DOC		//Documento
		cDocHis		:= CTC->CTC_DOCHIS	//Historico do documento contแbil
		cMoeda		:= CTC->CTC_MOEDDC	//Moeda do Documento Contabil
		cCritConv	:= CTC->CTC_CRITDC	//Criterio Conv. do Documento Contabil
		dDtTaxConv	:= CTC->CTC_DTTXDC	//Dt. Taxa Conv. do Documento Contabil
		cTipoSaldo	:= CTC->CTC_TPSADC	//Tipo de Saldo do Documento Contabil
		cLivDia		:= CTC->CTC_DIACTB	//Livro Diario
		cNroDia		:= CTC->CTC_NODIA	//Nro. Diario		

		//Total Lote			
		dbSelectArea("CT6")
		dbSetOrder(1)
		If MsSeek(xFilial()+DTOS(dDataLanc)+cLote+cSubLote+"01")
			nTotLote := CT6->CT6_INF
		Endif

		//Total Documento	
		dbSelectArea("CTC")
		dbSetOrder(1)
		If MsSeek(xFilial()+DTOS(dDataLanc)+cLote+cSubLote+cDoc+"01")
			nTotDoc := CTC->CTC_INF
		Endif

	EndIf

	If (l104Altera .Or. l104Inclui) 
	
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 450,520 PIXEL  //"Capa de Lote - Lancamentos Contabeis"
	
		//Label 1 - Documento
		@ 005,005 TO 070, 258 Label STR0009 OF oDlg PIXEL //"Documento"
		
		@ 015,012 	SAY STR0010						SIZE 055, 007 OF oDlg PIXEL //"Data"
		@ 025,012	MSGET oDataLanc VAR dDataLanc	SIZE 045, 010 OF oDlg PIXEL; 
					HASBUTTON;
					WHEN lDigita ;
					VALID NaoVazio(dDataLanc) .And. CtbValiDt(nOpc,dDataLanc) .And.;
						If(Empty(cLote),C050Next(dDataLanc,@cLote,@cSubLote,@cDoc,oLote,oSubLote,oDoc,@CTF_LOCK,nOpc,1),.T.) .And.;
						CtbMedias(dDataLanc)
			
		@ 015,065 	SAY STR0011						SIZE 055, 007 OF oDlg PIXEL //"Lote"
		@ 025,065	MSGET oLote VAR cLote			SIZE 030, 010 OF oDlg PIXEL;
					PICTURE "@!";
					WHEN lDigita;
					VALID NaoVazio(cLote) .And.;
							C102ProxDoc(dDataLanc,cLote,@cSubLote,@cDoc,@oLote,@oSubLote,@oDoc,@CTF_LOCK) .And.;
							Ctb101Inf(dDataLanc,cLote,cSubLote,cDoc,oTotDoc,@nTotDoc,oTotLote,@nTotLote)
		
		@ 015,099 	SAY STR0012						SIZE 055, 007 OF oDlg PIXEL //"Sublote"
		@ 025,099	MSGET oSubLote VAR cSubLote		SIZE 030, 010 OF oDlg PIXEL;
					PICTURE "!!!";
					F3 "SB";
					HASBUTTON;
					WHEN lDigita .And. lSubLote;
					VALID NaoVazio(cSubLote) .And.;
							C102ProxDoc(dDataLanc,cLote,@cSubLote,@cDoc,@oLote,@oSubLote,@oDoc,@CTF_LOCK) .And.;
							Ctb101Inf(dDataLanc,cLote,cSubLote,cDoc,oTotDoc,@nTotDoc,oTotLote,@nTotLote)
		
		@ 015,133 	SAY STR0009						SIZE 055, 007 OF oDlg PIXEL //"Documento"
		@ 025,133	MSGET oDoc VAR cDoc				SIZE 030, 010 OF oDlg PIXEL;
					PICTURE "999999";
					WHEN lDigita;
					VALID NaoVazio(cDoc) .And.;
							Ctb101Doc(dDataLanc,cLote,cSubLote,@cDoc,oDoc,@CTF_LOCK,nOpc) .And.;
							Ctb101Inf(dDataLanc,cLote,cSubLote,cDoc,oTotDoc,@nTotDoc,oTotLote,@nTotLote)
	
		@ 015,167	SAY STR0013						SIZE 055, 007 OF oDlg PIXEL //"Livro Diario"
		@ 025,167	MSGET oLivDia VAR cLivDia		SIZE 040, 010 OF oDlg PIXEL;
					PICTURE "@!";
					F3 "CVL";
					VALID VldCodSeq(cLivDia) .And. Eval({||cNroDia := CTBSQCor( "" , cLivDia, dDataLanc ),.T.});
					WHEN lSeqCorr .And. CtbWdia();
					HASBUTTON
		
		@ 015,211	SAY STR0014						SIZE 055, 007 OF oDlg PIXEL //"Nro. Diario"
		@ 025,211	MSGET oNroDia VAR cNroDia		SIZE 040, 010 OF oDlg PIXEL;
					WHEN lSeqCorr .And. GetMv("MV_SEGOFI") == "5"
	
		@ 043,012 	SAY STR0015						SIZE 080, 007 OF oDlg PIXEL //"Historico do documento"
		@ 053,012	MSGET oDocHis VAR cDocHis		SIZE 245, 010 OF oDlg PIXEL
	
		//Label 2 - Config. Adicionais
		@ 75,005 TO 155, 258 Label STR0016 OF oDlg PIXEL //"Config. Adicionais"
	
		@ 091,012 	SAY STR0017						SIZE 055, 007 OF oDlg PIXEL  //"Moeda"
		@ 090,055	MSGET oMoeda VAR cMoeda			SIZE 040, 010 OF oDlg PIXEL;
					F3 "CTO";
					HASBUTTON;
					VALID Vazio(cMoeda) .Or. ExistCpo("CTO",cMoeda)
		
		@ 106,012 	SAY STR0018						SIZE 055, 007 OF oDlg PIXEL  //"Criterio Conv."	
		@ 105,055	MSGET oCritConv VAR cCritConv	SIZE 040, 010 OF oDlg PIXEL;
					VALID Vazio(cCritConv) .Or. C104VldCri(cMoeda,cCritConv,dDataLanc,@dDtTaxConv)
		
		@ 121,012 	SAY STR0019						SIZE 055, 007 OF oDlg PIXEL  //"Dt. Taxa Conv."	
		@ 120,055	MSGET oDtTaxConv VAR dDtTaxConv	SIZE 045, 010 OF oDlg PIXEL;
					HASBUTTON;
					VALID  Vazio(dDtTaxConv) .Or. C104VldDtC(nOpc,dDtTaxConv,cCritConv)
		
		@ 136,012 	SAY STR0020						SIZE 055, 007 OF oDlg PIXEL  //"Tipo de Saldo"	         
		@ 135,055	MSGET oTipoSaldo VAR cTipoSaldo	SIZE 040, 010 OF oDlg PIXEL;
					F3 "SLW";
					HASBUTTON;
					VALID Vazio(cTipoSaldo) .Or. ExistCpo("SX5","SL"+cTipoSaldo)
	
		//Label 3 - Totais Informados
		@ 160,005 TO 205, 258 Label STR0021 OF oDlg PIXEL //"Totais Informados"
		@ 174,012 	SAY STR0022					SIZE 055, 007 OF oDlg PIXEL  //"Do Documento"	
		@ 173,055	MSGET oTotDoc VAR nTotDoc	SIZE 080, 010 OF oDlg PIXEL;
					PICTURE "@E 99,999,999,999,999.99";
					WHEN (l104Inclui .Or. l104Altera);
					HASBUTTON
		
		@ 189,012 	SAY STR0023					SIZE 055, 007 OF oDlg PIXEL  //"Do Lote"
		@ 188,055	MSGET oTotLote VAR nTotLote	SIZE 080, 010 OF oDlg PIXEL;
					PICTURE "@E 99,999,999,999,999.99";
					WHEN .F.;
					HASBUTTON


		//Botoes
		DEFINE SBUTTON FROM 210, 05 TYPE 1 ACTION (lContinua := .T.,;  //Botao OK
									Iif(lDigita,Iif(Ct102GrCTF(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK) .And.;
										Ctb101Lote(dDataLanc,cLote,cSubLote,@cDoc,oDoc,CTF_LOCK) .And.;
										Ctb101Doc(dDataLanc,cLote,cSubLote,@cDoc,oDoc,CTF_LOCK,nOpc) .And.;
										c102CapOk(dDataLanc,cLote,cSubLote,cDoc) .And.;
										VldCaplote(dDataLanc,cLote,cSubLote,cDoc,nOpc) .And.;
										CtbProxLin(dDataLanc,cLote,cSubLote,cDoc,@cLinha,@oLinha),;
										oDlg:End(),lContinua := .F.),;
										Iif(VldCaplote(dDataLanc,cLote,cSubLote,cDoc,nOpc) .and. ;
										CtbVldLP(dDataLanc,cLote,cSubLote,cDoc,nOpc) .And.;						
										CtbTmpBloq(dDataLanc,cLote,cSubLote,cDoc,nOpc,cProg) .and.;
										CtbValiDt(nOpc,dDataLanc),;
										oDlg:End(),lContinua := .F.))) ENABLE OF oDlg
										
		DEFINE SBUTTON FROM 210, 37 TYPE 2 ACTION (lContinua := .F.,oDlg:End()) ENABLE OF oDlg //Botao Cancelar
		
		ACTIVATE MSDIALOg oDlg CENTERED                           
	Else
		lContinua := .T. //Visualiza็ใo
	EndIf
		
	//Exibe a tela para os lancamentos
	If lContinua
		CTBA104Lan(nOpc,dDataLanc,cLote,cSubLote,cDoc,cLivDia,cNroDia,cDocHis,cMoeda,cCritConv,;
					dDtTaxConv,cTipoSaldo,nTotDoc,nTotLote)
	EndIf
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA104LanบAutor  ณMicrosiga           บ Data ณ  06/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a tela dos lancamentos contabeis                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBA104Lan(nOpc,dDataLanc,cLote,cSubLote,cDoc,cLivDia,cNroDia,cDocHis,cMoeda,cCritConv,;
					dDtTaxConv,cTipoSaldo,nTotDoc,nTotLote)
Local oPanel1
Local oPanel2
Local oPanel3
Local oFolder1
Local oFolder2
Local oFolder3
Local oFolder4

Local oBtn
Local oMenu
Local aButtons		:= {}
Local nQtBtn		:= 0

Local cTitulo		:= STR0024 //"Movimentos contabeis"
Local cAlias		:= "CT2"

Local aSize			:= MsAdvSize(,.F.,400)
Local aObjects		:= {} 
Local aPosObj		:= {} 
Local aInfo			:= {}

Local cArq1
Local cArq2
Local aAltera		:= {}
Local nOpcGDB		:= nOpc	//Variavel para carregar a GetDB
Local lDel 	  		:= .F.
Local cLinhaAlt		:= "001"
Local nDbRecTMP		:= 0

Local cSeqCorr		:= Space(10)

Local l104Inclui	:= .F.
Local l104Visual	:= .F.
Local l104Altera	:= .F.
Local l104Exclui	:= .F.

Local lContinua		:= .T.
Local lOk			:= .F.

Local aCampos	:= {}

Local aTotais 		:= {{0,0,0,0},{0,0,0,0}}

Local cExpFil		:= ""
Local cTxtfil		:= ""

Local oEnchBar

Private oDlg
Private oGetDB
Private oC104GDEnt
Private oC104GDAtv
Private oC104GDMoe
Private oC104GDInf
Private oC104GDDig
Private aHeader		:= {}
Private aTotRdpe	:= {{0,0,0,0},{0,0,0,0}}
Private cC104Moeda	:= If(Empty(cMoeda),"01",cMoeda)
Private aC104Dados	:= {cCritConv,dDtTaxConv,cTipoSaldo}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Do Case
		Case nOpc == 2
			l104Visual	:= .T.
		Case nOpc == 3
			l104Inclui	:= .T.
			nOpcGDB		:= 4
			lDel		:= .T.
		Case nOpc ==  4
			l104Altera	:= .T.
			lDel		:= .T.
		Case nOpc ==  5
			l104Exclui	:= .T.
			l104Visual	:= .T.
	EndCase

	//Posicionamento na CT2
	If l104Altera .Or. l104Exclui .Or. l104Visual
		dbSelectArea("CT2")
		dbSetOrder(1) //CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC
		dbSeek(xFilial("CT2") + DTOS(dDataLanc) + cLote + cSubLote + cDoc)
	EndIf

	If _lForcCrTmp
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Monta Getdados para Lanamentos Cont beis                    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aCampos := Ctb105Head(@aAltera,/*lSimula*/, _lForcHead )
		_aHeadCtb := aClone( aHeader )  //carrega variavel static com clone de aHeader
		_aAltera  := aClone( aAltera )  //carrega variavel stati com clone a aAltera
		Ctb105Cria(aCampos,@cArq1,@cArq2, _lForcCrTmp )
		_aCampos := aClone( aCampos )   //carrega variavel static com clone de aCampos
		Ctb105STmp()                             //FUNCAO CTBA105 PARA SETAR ALIAS TMP
		_lForcHead := .F.
		_lForcCrTmp := .F.
	Else
		//carrega as variaveis locais/private com conteudo das variaveis static
		aCampos := aClone( _aCampos )  //esta variavel eh retorno da funcao Ctb105Cria
		aAltera := aClone( _aAltera )  //esta variavel ้ utilizada  na MSGETDB 
		aHeader := aClone( _aHeadCtb ) //variavel aHeader ้ utilizada internamente na MSGETDB                              
	EndIf

	C104AltHea(cC104Moeda)					//Ajusta a coluna de valor de acordo com a moeda selecionada

	//Remove do array aAltera os campos que nao poderao ser editados pelo usuario
	C104Remove(@aAltera,cCritConv,dDtTaxConv,cTipoSaldo)

	lContinua := Ctb102Carr(nOpc,@dDataLanc,cLote,cSubLote,cDoc,@cLinhaAlt,FunName(),/*cCodSeq*/)

	//Carrega os valores de acordo com a capa do lote
	If l104Inclui
		C104SetDad()
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Montagem dos botoes da barra de ferramentas                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Aadd( aButtons, {"RECALC"   , { || MsAguarde({|| CtRecRdPe()},"Recalculando totais...") },"Rec.Totais"} )
	Aadd( aButtons, {"SIMULACAO",{ || Ctb102OutM(dDataLanc,cLote,cSubLote,cDoc)}, STR0025,STR0026 } ) //"Totais do lote e documento (outras moedas)"###"Totais"
	Aadd( aButtons, {"PREV"     ,{ || CTB105Flt (oGetDb,.F.                   )}, STR0027,STR0028 } ) //"Inconsistencia Anterior"###"Anterior"
	Aadd( aButtons, {"NEXT"     ,{ || CTB105Flt (oGetDb,.T.                   )}, STR0029,STR0030 } ) //"Proxima Inconsistencia"###"Pr๓xima"
	
	If l104Visual .Or. l104Exclui
		Aadd( aButtons, {"CTBLANC"   ,{ || Ctb102Lcto()}, STR0031,STR0032 } ) //"Detalhes do lan็amento posicionado"###"Detalhes"
	EndIf
	
	If l104Inclui .Or. l104Altera //.Or. l102Copia
		Aadd( aButtons, {"CTBREPLA"   ,{ || Ctb102Repla()}, STR0033 ,STR0034} ) //"Replicar o conteudo do campo posicionado"###"Replicar"
	EndIf
	
	aButtons := AddToExcel(aButtons,{	{"ARRAY",STR0009,{STR0010,STR0011,STR0012,STR0009},{{dDataLanc,cLote,cSubLote,cDoc}}},{"GETDB","Registros",aHeader,"TMP"} } ) //"Documento"###"Data"###"Lote"###"SubLote"###"Documento"
	Aadd( aButtons, {"PESQUISA"   ,{ || CTB105FtBs(oGetDb,@cExpFil,@cTxtFil     )}, STR0036	} ) //"Localizar"

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL
	oDlg:lMaximized := .T.

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณA EnchoiceBar foi inserida neste ponto pois no Release 11.5 ela deve   ณ
	//ณser pocionada no rodape da tela e devido o alinhamento do painel 3 ela ณ
	//ณpermanecia no meio da tela                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	EnchoiceBar(oDlg,{||If(Ct105TOK(ExistBlock("CT105TOK"),ExistBlock("CT105CHK"),oGetDB:lModified,,aTotRdpe,nTotDoc),;	//bOk
					(lOk := .T.,oDlg:End()),;
					lOk := .F.)},;
					{||lOk := .F.,oDlg:End()},;	//bCancel
					,;								//lMsgDel
					aButtons)						//aButtons	

	//Monta os Paineis
	oPanel1 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,200,80,.T.,.T. )
	oPanel1:Align := CONTROL_ALIGN_TOP

	oPanel2 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,200,40,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
                                             
	oPanel3 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,200,(aSize[6] * 0.18),.T.,.T. )
	oPanel3:Align := CONTROL_ALIGN_BOTTOM

	//Monta os Folders do Painel3
	oFolder1 := TFolder():New(000						,000					,{STR0037}			,{""},oPanel3,,,,.T.,,oPanel3:nClientWidth/4,oPanel3:nClientHeight/4) //"Moedas"
	oFolder2 := TFolder():New(000						,oPanel3:nClientWidth/4	,{STR0038,STR0039}	,{""},oPanel3,,,,.T.,,oPanel3:nClientWidth/4,oPanel3:nClientHeight/4) //"Entidades"###"Atividades Complementares"
	oFolder3 := TFolder():New(oPanel3:nClientHeight/4	,000					,{STR0021}			,{""},oPanel3,,,,.T.,,oPanel3:nClientWidth/4,oPanel3:nClientHeight/4) //"Totais Informados"
	oFolder4 := TFolder():New(oPanel3:nClientHeight/4	,oPanel3:nClientWidth/4	,{STR0040}			,{""},oPanel3,,,,.T.,,oPanel3:nClientWidth/4,oPanel3:nClientHeight/4) //"Totais Digitados"

	//Label 1 - Documento
	@ 005,005 TO 075,258 Label STR0009 OF oPanel1 PIXEL //"Documento"
	@ 015,012 	SAY STR0010		SIZE 055, 007 OF oPanel1 PIXEL  //"Data"
	@ 025,012	MSGET dDataLanc SIZE 040, 010 OF oPanel1 PIXEL WHEN .F.
	@ 015,065 	SAY STR0011	   	SIZE 055, 007 OF oPanel1 PIXEL  //"Lote"
	@ 025,065	MSGET cLote		SIZE 030, 010 OF oPanel1 PIXEL WHEN .F.
	@ 015,099 	SAY STR0012		SIZE 055, 007 OF oPanel1 PIXEL  //"Sublote"
	@ 025,099	MSGET cSubLote	SIZE 030, 010 OF oPanel1 PIXEL WHEN .F.
	@ 015,133 	SAY STR0009		SIZE 055, 007 OF oPanel1 PIXEL  //"Documento"
	@ 025,133	MSGET cDoc		SIZE 030, 010 OF oPanel1 PIXEL WHEN .F.
	@ 015,167 	SAY STR0013		SIZE 055, 007 OF oPanel1 PIXEL  //"Livro Diario"
	@ 025,167	MSGET cLivDia	SIZE 040, 010 OF oPanel1 PIXEL WHEN .F.
	@ 015,211 	SAY STR0014		SIZE 055, 007 OF oPanel1 PIXEL  //"Nro. Diario"
	@ 025,211	MSGET cNroDia	SIZE 040, 010 OF oPanel1 PIXEL WHEN .F.
	@ 043,012 	SAY STR0015		SIZE 080, 007 OF oPanel1 PIXEL  //"Historico do documento"
	@ 053,012	MSGET cDocHis	SIZE 245, 010 OF oPanel1 PIXEL WHEN .F.
	  
	//Label 2 - Config. Adicionais
	@ 005,262 TO 075,(oPanel1:nClientWidth/2.02) Label STR0016 OF oPanel1 PIXEL //"Config. Adicionais"
	@ 016,270 	SAY STR0017			SIZE 055, 007 OF oPanel1 PIXEL  //"Moeda"
	@ 015,310	MSGET cMoeda		SIZE 040, 010 OF oPanel1 PIXEL WHEN .F.
	@ 030,270 	SAY STR0018			SIZE 055, 007 OF oPanel1 PIXEL  //"Criterio Conv."	
	@ 029,310	MSGET cCritConv		SIZE 040, 010 OF oPanel1 PIXEL WHEN .F.
	@ 044,270 	SAY STR0019			SIZE 055, 007 OF oPanel1 PIXEL  //"Dt. Taxa Conv."	
	@ 043,310	MSGET dDtTaxConv	SIZE 040, 010 OF oPanel1 PIXEL WHEN .F.
	@ 058,270 	SAY STR0020			SIZE 055, 007 OF oPanel1 PIXEL  //"Tipo de Saldo"	         
	@ 057,310	MSGET cTipoSaldo	SIZE 040, 010 OF oPanel1 PIXEL WHEN .F.
	
	TMP->(dbSetOrder(0))

	nDbRecTMP := TMP->( RECNO() )  // guardo o recno para tratamento da getDB

				//MsGetDB():New(nTop	,nLeft	,nBottom	,nRight	,nOpc		,cLinhaOk		,cTudoOk	,cIniCpos		,lDelete	,aAlter		,nFreeze,lEmpty	,uPar1					,cTRB	,cFieldOk		,lCondicional	,lAppend,oWnd		,lDisparos	,uPar2	,cDelOk		,cSuperDel)
	oGetDB := MSGetDB():New( 034		,005	,226		, 415	,nOpcGDB	,"CT105LINOK"	,"CT105TOk"	,"+CT2_LINHA"	,lDel		,aAltera	,		,.t.	,SuperGetMv("MV_NUMMAN"),"TMP"	,"C104CpoGD1"	,				,		,oPanel2	,			,		,"CT104DEL")
	oGetDB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT                                                                                                                                                    
	oGetDB:oBrowse:bChange := {||C104CpoGD1()}

	// restauro o posicionamento da getDb
	If nDbRecTMP <> TMP->( RECNO() )
		oGetDB:Goto( nDbRecTMP )
	EndIf
	
	//Grid Moedas
	oC104GDMoe := C104GDMoed(oFolder1,nOpc)

	//Grid Entidades
	oC104GDEnt := C104GDEnt(oFolder2,nOpc)

	//Grid Atividades Complementares
	oC104GDAtv := C104GDAtv(oFolder2,nOpc)

	//Grid Totais Informados
	oC104GDInf := C104GDInf(oFolder3,cC104Moeda,nTotDoc,nTotLote)

	//Grid Totais Digitados
	oC104GDDig := C104GDDig(oFolder4,nOpc,cC104Moeda)

	aTotais			:= CtbTotMov()
	aTotRdpe[1][2]	:= aTotais[1][2] //Valor debito
	aTotRdpe[1][3]	:= aTotais[1][3] //Valor credito	
	aTotRdpe[1][1]	:= aTotais[1][1] //Valor digitado	

	ACTIVATE MSDIALOG oDlg CENTERED	ON INIT (oGetDB:oBrowse:Refresh())

	//Executa a gravacao dos lancamentos
	If lOk .And. (l104Inclui .Or. l104Altera .Or. l104Exclui /*.Or. l104Estorno .Or. l104Copia*/)

		If lOk

			CTBGrava(nOpc,dDataLanc,cLote,cSubLote,cDoc,.F.,"",__lCusto,__lItem,__lCLVL,nTotDoc,'CTBA104',,,cEmpAnt,cFilAnt,,,,,,,cNroDia/*cSeqCorr*/,,,,;
					cDocHis,cC104Moeda,cCritConv,dDtTaxConv,cTipoSaldo,cLivDia,cNroDia)

		EndIf

	EndIf

//limpa arquivo temporario para quando voltar para outro documento 
dbSelectArea( "TMP" )
If Alias() == "TMP"
	Ctb_ZapTmp() //Zap
EndIf
TMP->( dbGotop() )

dbSelectArea( "CT2" )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC104CpoGD1บAutor  ณMicrosiga           บ Data ณ  13/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo dos dados digitados na grid de lancamento        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C104CpoGD1()
Local lRet			:= .T.
Local cVar			:= ReadVar()
Local dDtTaxConv	:= STOD("")
Local nX			:= 0



//Caso o lancamento seja em outra moeda valida o preenchimento do campo CT2_CONVER
If (cC104Moeda <> "01") .And. ("CT2_CONVER" $ cVar) .And. Empty(aC104Dados[1])
	For nX := 1 To Len(AllTrim(&cVar))
		If nX == 1
			Loop
		Else
			If !(SubStr(&cVar,nX,1) $ "4|5" )
				MsgAlert(STR0041 + ": " + StrZero(nX,2)) //"Criterio invแlido para a moeda"
			EndIf
		EndIf
	Next
EndIf
               
//Insere os dados definidos na capa do lote
C104SetDad()	

//Atualiza a Grid Moedas
C104AtuMoe()

//Atualiza a Grid Entidades
C104AtuEnt()

//Atualiza a Grid Atividades Complementares
C104AtuAtv()	

//Atualiza a Grid Total Digitado
C104AtuDig()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC104GDMoedบAutor  ณMicrosiga           บ Data ณ  15/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a grid Moedas                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C104GDMoed(oFolder1,nOpc)
Local aSaveArea		:= GetArea()
Local aSaveCTO		:= CTO->(GetArea())
Local oObjGD
Local aHeaderMoe	:= {}
Local aColsMoe		:= {}
Local aAlterGDa		:= {}
Local nX			:= 0
Local cLin			:= ""
Local cDescrMoed	:= ""

	                //cTitulo	, cCampo		, cPicture				, nTamanho				, nDecimais				, cValida็ใo, cReservado, cTipo, xReservado1, xReservado2
	Aadd(aHeaderMoe,{ STR0042	, "MOEDA_ID"	, "!!!"					, 03					, 0						, ""		, "๛"		, "C"  , "   "      , "  " }) //"ID"
	Aadd(aHeaderMoe,{ STR0017	, "MOEDA_MOE"	, "@!"					, 30					, 0						, ""		, "๛"		, "C"  , "   "      , "   "}) //"Moeda"
	Aadd(aHeaderMoe,{ STR0043	, "MOEDA_VAL"	, X3Picture("CT2_VALOR"), TAMSX3("CT2_VALOR")[1], TAMSX3("CT2_VALOR")[2], ""		, "๛"		, "N"  , " "        , ""   }) //"Valor"
	Aadd(aHeaderMoe,{ STR0044	, "MOEDA_TAX"	, X3Picture("M2_MOEDA1"), TAMSX3("M2_MOEDA1")[1], TAMSX3("M2_MOEDA1")[2], ""		, "๛"		, "C"  , " "        , ""   }) //"Taxa"
	Aadd(aHeaderMoe,{ STR0045	, "MOEDA_DAT"	, X3Picture("M2_DATA")	, TAMSX3("M2_DATA")[1]	, TAMSX3("M2_DATA")[2]	, ""		, "๛"		, "C"  , " "        , ""   }) //"Data da taxa"
	Aadd(aHeaderMoe,{ STR0046	, "MOEDA_CRIT"	, "@!"					, 10					, 0						, ""		, "๛"		, "C"  , " "        , ""   }) //"Crit. Conver."

	dbSelectArea("CTO")
	dbSetOrder(1) //CTO_FILIAL+CTO_MOEDA

	For nX := 1 To __nQuantas

		cLin := STRZERO(nX,2)	

		If dbSeek(xFilial("CTO")+cLin)
			cDescrMoed := CTO->CTO_MOEDA + " " + AllTRIM(CTO->CTO_DESC) + " (" + AllTrim(CTO->CTO_SIMB) + ")"
		EndIf

		If nX == 1
							//ID			,Descricao	,Valor						,Taxa						,Data Taxa					,Criterio Conversao
			Aadd(aColsMoe,{TMP->CT2_LINHA	,cDescrMoed	,TMP->CT2_VALOR				,TMP->CT2_TAXA				,TMP->CT2_DATATX			,SubStr(TMP->CT2_CRITER,nX,1)	,.F.})
		Else                                                              
							//ID			,Descricao	,Valor						,Taxa						,Data Taxa					,Criterio Conversao
			Aadd(aColsMoe,{TMP->CT2_LINHA	,cDescrMoed	,&("TMP->CT2_VALR"+cLin)	,&("TMP->CT2_TAXA"+cLin)	,&("TMP->CT2_DTTX"+cLin)	,SubStr(TMP->CT2_CRITER,nX,1)	,.F.})
		EndIf

	Next nX

           //MsNewGetDados():New(nSuperior	,nEsquerda	,nInferior	,nDireita	,nOpc		, cLinOk, cTudoOk, cIniCpos, aAlterGDa	,nFreeze	,nMax, cFieldOk, cSuperDel, cDelOk, oDLG				, aHeader	, aCols)
	oObjGD := MsNewGetDados():New(000		,000		,050		,050		,GD_UPDATE	,       ,        ,         , aAlterGDa	,			,5   ,         ,          ,       , oFolder1:aDialogs[1], aHeaderMoe	, aColsMoe)
	oObjGD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

RestArea(aSaveArea)
RestArea(aSaveCTO)

Return oObjGD

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC104GDEnt บAutor  ณMicrosiga           บ Data ณ  15/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a grid Entidades                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C104GDEnt(oFolder2,nOpc)
Local aSaveArea		:= GetArea()
Local aSaveCT0		:= CT0->(GetArea())
Local aHeaderEnt	:= {}
Local aColsEnt		:= Array(nQtdEntid,4)
Local aAlterGDa		:= {}
Local aDescEnt		:= {}
Local nX			:= 0
Local oObjGD          

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria aHeader e aCols da GetDados Entidades                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					//cTitulo	, cCampo		, cPicture	, nTamanho, nDecimais, cValida็ใo	, cReservado, cTipo, xReservado1, xReservado2
	Aadd(aHeaderEnt,{ STR0047	, "ENTID_ID"	, "@!"		, 40      , 0        , ""			, "๛"       , "C"  , "   "      , "  " }) //"Entidade"
	Aadd(aHeaderEnt,{ STR0048	, "ENTID_DEB"	, "@!"		, 30      , 0        , ""			, "๛"		, "C"  , "   "      , "   "}) //"A Debito"
	Aadd(aHeaderEnt,{ STR0049	, "ENTID_CRED"	, "@!"		, 30      , 0        , ""			, "๛"		, "C"  , " "        , ""   }) //"A Credito"

	dbSelectArea("CT0")
	dbSetOrder(1) //CT0_FILIAL+CT0_ID
	If dbSeek(xFilial("CT0")+"01")

		While CT0->(!EOF()) .And. xFilial("CT0") == CT0->CT0_FILIAL
			Aadd(aDescEnt, CT0->CT0_DESC)
		CT0->(dbSkip())		
		EndDo

	
		If nQtdEntid >= 1 //Conta Contabil
			aColsEnt[1] := {aDescEnt[1],TMP->CT2_DEBITO,TMP->CT2_CREDIT,.F.}
		EndIf
	                                             
		If nQtdEntid >= 2 //Centro de Custo
			aColsEnt[2] := {aDescEnt[2],TMP->CT2_CCD,TMP->CT2_CCC,.F.}
		EndIf
						                      
		If nQtdEntid >= 3 //Item Contabil
			aColsEnt[3] := {aDescEnt[3],TMP->CT2_ITEMD,TMP->CT2_ITEMC,.F.}
		EndIf
						                        
		If nQtdEntid >= 4 //Classe de Valor
			aColsEnt[4] := {aDescEnt[4],TMP->CT2_CLVLDB,TMP->CT2_CLVLCR,.F.}
		EndIf
	   
		If nQtdEntid > 4 //Entidades adicionais
		
			For nX := 5 To nQtdEntid
				aColsEnt[nX] := {aDescEnt[nX],;
								&("TMP->CT2_EC" + STRZERO(nX,2) + "DB"),;
								&("TMP->CT2_EC" + STRZERO(nX,2) + "CR"),;
								.F.}
			Next nX
	
		EndIf

	EndIf

	        //MsNewGetDados():New(nSuperior	,nEsquerda	,nInferior	,nDireita	,nOpc		, cLinOk, cTudoOk, cIniCpos, aAlterGDa	,nFreeze	, nMax		,cFieldOk	,cSuperDel	, cDelOk, oDLG					, aHeader		, aCols)
	oObjGD := MsNewGetDados():New(000		,000		,100		,200		,GD_UPDATE	,       ,        ,         , aAlterGDa	,			, nQtdEntid	,			,			,       , oFolder2:aDialogs[1]	, aHeaderEnt	, aColsEnt)
	oObjGD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT	

RestArea(aSaveCT0)
RestArea(aSaveArea)

Return oObjGD

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC104GDAtv บAutor  ณMicrosiga           บ Data ณ  15/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a grid Atividades Complementares                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C104GDAtv(oFolder2,nOpc)
Local aSaveArea		:= GetArea()
Local aSaveCT0		:= CT0->(GetArea())
Local aHeaderAtv	:= {}
Local aColsAtv		:= {}
Local aAlterGDa		:= {}
Local aDescEnt		:= {}
Local nX			:= 0
Local oObjGD          

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria aHeader e aCols da GetDados Entidades                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					//cTitulo	, cCampo		, cPicture	, nTamanho, nDecimais, cValida็ใo	, cReservado, cTipo, xReservado1, xReservado2
	Aadd(aHeaderAtv,{ STR0055	, "ATIV_ID"		, "@!"		, 40      , 0        , ""			, "๛"       , "C"  , "   "      , "  " }) //"Atividades"
	Aadd(aHeaderAtv,{ STR0048	, "ATIV_DEB"	, "@!"		, 30      , 0        , ""			, "๛"		, "C"  , "   "      , "   "}) //"A Debito"
	Aadd(aHeaderAtv,{ STR0049	, "ATIV_CRED"	, "@!"		, 30      , 0        , ""			, "๛"		, "C"  , " "        , ""   }) //"A Credito"

	If X3USADO("CT2_ATIVDE") .AND. X3USADO("CT2_ATIVCR")
		//Adiciona Outras Atividades
		Aadd(aColsAtv,{STR0056,TMP->CT2_ATIVDE,TMP->CT2_ATIVCR,.F.})//"Outras Atividades"
	EndIf
                                
	//Adiciona Atividades
	For nX := 1 To nQtdEntid
		Aadd(aColsAtv, {STR0055 + " " + STRZERO(nX,2),; //"Atividades"
						&("TMP->CT2_AT" + STRZERO(nX,2) + "DB"),;
						&("TMP->CT2_AT" + STRZERO(nX,2) + "CR"),;
						.F.})
	Next nX

	        //MsNewGetDados():New(nSuperior	,nEsquerda	,nInferior	,nDireita	,nOpc		, cLinOk, cTudoOk, cIniCpos, aAlterGDa	,nFreeze	, nMax		,cFieldOk	,cSuperDel	, cDelOk, oDLG					, aHeader		, aCols)
	oObjGD := MsNewGetDados():New(000		,000		,100		,200		,GD_UPDATE	,       ,        ,         , aAlterGDa	,			, nQtdEntid	,			,			,       , oFolder2:aDialogs[2]	, aHeaderAtv	, aColsAtv)
	oObjGD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT	

RestArea(aSaveCT0)
RestArea(aSaveArea)

Return oObjGD

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC104GDInf บAutor  ณMicrosiga           บ Data ณ  15/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a grid Totais Informados                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C104GDInf(oFolder3,cMoeda,nTotDoc,nTotLote)
Local aSaveArea		:= GetArea()
Local aSaveCTO		:= CTO->(GetArea())
Local cDescrMoed	:= ""
Local aHeaderInf	:= {}
Local aColsInf		:= {}
Local oObjGD
Local aAlterGDa		:= {}

	cMoeda := If(Empty(cMoeda),"01",cMoeda)

	dbSelectArea("CTO")
	dbSetOrder(1) //CTO_FILIAL+CTO_MOEDA
	If dbSeek(xFilial("CTO")+cMoeda)
		cDescrMoed := CTO->CTO_MOEDA + " " + AllTRIM(CTO->CTO_DESC) + " (" + AllTrim(CTO->CTO_SIMB) + ")"
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria aHeader e aCols da GetDados Totais Informados           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					//cTitulo, cCampo		, cPicture					, nTamanho					,nDecimais				,cValida็ใo	, cReservado, cTipo, xReservado1, xReservado2
	Aadd(aHeaderInf,{ STR0050, "TOTINF_TOT"	, "@!"    					, 20      					,0        				,""			, "๛"       , "C"  , "   "      , "  " }) //"Total"
	Aadd(aHeaderInf,{ STR0017, "TOTINF_INF"	, "@!"    					, 30      					,0						,""			, "๛"       , "C"  , "   "      , "   "}) //"Moeda"
	Aadd(aHeaderInf,{ STR0043, "TOTINF_VAL"	, X3Picture("CT2_VALOR")    , TAMSX3("CT2_VALOR")[1]	,TAMSX3("CT2_VALOR")[2]	,""			, "๛"       , "C"  , " "        , ""   }) //"Valor"

	aAdd(aColsInf,{STR0009	,cDescrMoed	,nTotDoc	,.F.}) //"Documento"
	aAdd(aColsInf,{STR0011	,cDescrMoed	,nTotLote	,.F.}) //"Lote"

			//MsNewGetDados():New(nSuperior	,nEsquerda	,nInferior	,nDireita	,nOpc, cLinOk, cTudoOk, cIniCpos, aAlterGDa,nFreeze	, nMax, cFieldOk, cSuperDel, cDelOk, oDLG					,aHeader	,aCols)
	oObjGD := MsNewGetDados():New(000		,000		,100		,200		,2   ,       ,        ,         , aAlterGDa,		, 5   ,         ,          ,       , oFolder3:aDialogs[1]	,aHeaderInf	,aColsInf)
	oObjGD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT	

RestArea(aSaveCTO)
RestArea(aSaveArea)

Return(oObjGD)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC104GDDig บAutor  ณMicrosiga           บ Data ณ  15/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a grid Totais Digitados                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C104GDDig(oFolder4,nOpc,cMoeda)
Local aHeaderDig	:= {}
Local aColsDig		:= {}
Local aAlterGDa		:= {}
Local aSaveArea		:= GetArea()
Local aSaveSX5		:= SX5->(GetArea())
Local aSaveCTO		:= CTO->(GetArea())
Local aSaveTMP		:= TMP->(GetArea())
Local nValCred		:= 0
Local nValDeb		:= 0
Local nPosLin		:= 0
Local aDescrMoed	:= {}
Local aDescTpSld	:= {}
Local oObjGD

Local aLegenda		:= CtbLegenda("CT2")
Local cCor			:= ""
Local nX			:= 0
Local nY			:= 0
     
//Obtem a descricao dos tipos de saldos
dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5")+"SL")
While SX5->(!Eof()) .And. AllTrim(SX5->X5_TABELA) == "SL"
	
	If SX5->X5_CHAVE != "0"
		Aadd(aDescTpSld,AllTrim(SX5->X5_CHAVE) + " " + AllTrim(SX5->X5_DESCRI))
	EndIf
	
SX5->(DbSkip())
EndDo

//Obtem a descricao da moeda do lancamento
cMoeda := If(Empty(cMoeda),"01",cMoeda)

dbSelectArea("CTO")
dbSetOrder(1) //CTO_FILIAL+CTO_MOEDA
dbSeek(xFilial("CTO")+"01")
While CTO->(!EOF()) .And. CTO->CTO_FILIAL == xFilial("CTO")

	Aadd(aDescrMoed,CTO->CTO_MOEDA + " " + AllTRIM(CTO->CTO_DESC) + " (" + AllTrim(CTO->CTO_SIMB) + ")")

CTO->(dbSkip())
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria aHeader e aCols da GetDados Totais Digitados            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				//cTitulo	, cCampo		, cPicture					, nTamanho					, nDecimais					, cValida็ใo	, cReservado, cTipo	, xReservado1	, xReservado2
Aadd(aHeaderDig,{ ""		, "TOTDIG_LEG"	,"@BMP"						, 0							, 0							, ""			, "๛"		, ""	, ""			, "V"	})
Aadd(aHeaderDig,{ STR0020	, "TOTDIG_TIP"	, "@!"						, 15     					, 0							, ""			, "๛"       , "C"	, "   "      	, "   "	}) //"Tipo de Saldo"
Aadd(aHeaderDig,{ STR0017	, "TOTDIG_MOE"	, "@!"						, 25      					, 0							, ""			, "๛"       , "C"	, " "        	, ""	}) //"Moeda"
Aadd(aHeaderDig,{ STR0048	, "TOTDIG_DEB"	, X3Picture("CT2_VALOR")	, TAMSX3("CT2_VALOR")[1]	, TAMSX3("CT2_VALOR")[2]	, ""			, "๛"       , "C"	, " "        	, ""	}) //"A Debito"
Aadd(aHeaderDig,{ STR0049	, "TOTDIG_CRE"	, X3Picture("CT2_VALOR")	, TAMSX3("CT2_VALOR")[1]	, TAMSX3("CT2_VALOR")[2]	, ""			, "๛"       , "C"	, " "        	, ""	}) //"A Credito"

If nOpc != 3
	TMP->(dbGoTop())
	
	While TMP->(!Eof())
	
		For nY := 1 To __nQuantas
	
			nValCred	:= 0
			nValDeb		:= 0
		
			//Verifica o tipo de lancamento e obt้m o valor
			Do Case
				
				Case TMP->CT2_DC == "1" //Debito
					nValDeb		:= If(nY == 1 , TMP->CT2_VALOR , &("TMP->CT2_VALR"+STRZERO(nY,2)))
					nValCred	:= 0
		
				Case TMP->CT2_DC == "2" //Credito
					nValCred	:= If(nY == 1 , TMP->CT2_VALOR , &("TMP->CT2_VALR"+STRZERO(nY,2)))
					nValDeb		:= 0
							
				Case TMP->CT2_DC == "3" //Partida Dobrada
					nValDeb		:= If(nY == 1 , TMP->CT2_VALOR , &("TMP->CT2_VALR"+STRZERO(nY,2)))
					nValCred	:= If(nY == 1 , TMP->CT2_VALOR , &("TMP->CT2_VALR"+STRZERO(nY,2)))
		
				Case TMP->CT2_DC == "4" //Cont. Hist
					nValCred	:= 0
					nValDeb		:= 0
			EndCase
		
			If (nPosLin := Ascan(aColsDig,{|x| (SubStr(x[2],1,1) == TMP->CT2_TPSALD) .And. (SubStr(x[3],1,2) == STRZERO(nY,2)) })) > 0 //Confirma se existe a linha do tipo de saldo para acumular o valor
		
				aColsDig[nPosLin][4] += nValDeb		//Debito
		
				aColsDig[nPosLin][5] += nValCred	//Credito
		
			Else                                                                                    

				For nX := 1 To Len(aLegenda)
					If &("TMP->"+aLegenda[nX][1])
						cCor := aLegenda[nX][2]
						Exit
					EndIf
				Next nX
								//Legenda						,Tipo de Sld						,Moeda						,A Debito	,A Credito	
				Aadd(aColsDig,{LoadBitmap( GetResources(), cCor),aDescTpSld[Val(TMP->CT2_TPSALD)]	,aDescrMoed[nY]	,nValDeb	,nValCred	,.F.})
		
			EndIf

		Next nY
	
	TMP->(dbSkip())
	EndDo
Else
	
	For nX := 1 To Len(aLegenda)
		If &("TMP->"+aLegenda[nX][1])
			cCor := aLegenda[nX][2]
			Exit
		EndIf
	Next nX
					//Legenda						,Tipo de Sld						,Moeda						,A Debito	,A Credito	
	aAdd(aColsDig,{LoadBitmap( GetResources(), cCor),aDescTpSld[aScan(aDescTpSld,TMP->CT2_TPSALD)]	,aDescrMoed[Val(cMoeda)]	,0			,0			,.F.})	

EndIf
             
		//MsNewGetDados():New(nSuperior	,nEsquerda	,nInferior	,nDireita	,nOpc, cLinOk, cTudoOk, cIniCpos, aAlterGDa	,nFreeze, nMax, cFieldOk, cSuperDel, cDelOk, oDLG					,aHeader		,aCols)
oObjGD := MsNewGetDados():New(000		,000		,100		,200		,2   ,       ,        ,         , aAlterGDa	,		, 999 ,         ,          ,       , oFolder4:aDialogs[1]	,aHeaderDig	,aColsDig)
oObjGD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

RestArea(aSaveTMP)
RestArea(aSaveCTO)
RestArea(aSaveSX5)
RestArea(aSaveArea)

Return oObjGD

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC104AltHeaบAutor  ณMicrosiga           บ Data ณ  16/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Altera a posi็ใo do campo valor na grid de lancamentos de  บฑฑ
ฑฑบ          ณ acordo com a moeda selecionada na capa do lote             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C104AltHea(cMoeda)
Local nPosVlrSel	:= 0 //Campo valor da moeda selecionada
Local nPosVlrPad	:= 0 //Campo valor padrao (moeda 01)
Default cMoeda		:= "01"

If cMoeda != "01"

	If (nPosVlrSel := Ascan(aHeader,{|x| AllTrim(x[2]) == "CT2_VALR"+cMoeda})) > 0
		nPosVlrPad := Ascan(aHeader,{|x| AllTrim(x[2]) == "CT2_VALOR"})

			//Array			,nInicio		,nItens						,bOrdem
		ASORT(aHeader	,nPosVlrPad		,(nPosVlrSel-nPosVlrPad)+1	,{|x,y| x > y })
		ASORT(aHeader	,nPosVlrPad	+ 1	,(nPosVlrSel-nPosVlrPad)+1	,{|x,y| x < y })			

	EndIf

EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC104AtuMoeบAutor  ณMicrosiga           บ Data ณ  16/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a grid Moedas                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C104AtuMoe()
Local nPosID		:= Ascan(oC104GDMoe:aHeader,{|x|x[2] == "MOEDA_ID"})
Local nPosValor		:= Ascan(oC104GDMoe:aHeader,{|x|x[2] == "MOEDA_VAL"})
Local nPosTaxa		:= Ascan(oC104GDMoe:aHeader,{|x|x[2] == "MOEDA_TAX"})
Local nPosDtTaxa	:= Ascan(oC104GDMoe:aHeader,{|x|x[2] == "MOEDA_DAT"})
Local nPosCriter	:= Ascan(oC104GDMoe:aHeader,{|x|x[2] == "MOEDA_CRIT"})
Local cVar			:= ReadVar()
Local nX			:= 0
Local aTaxa			:= Array((Len(oC104GDMoe:ACols))-1)
Local aSaveArea   	:= GetArea()
Local aSaveCTP  	:= CTP->(GetArea())

For nX := 1 To Len(oC104GDMoe:ACols)

	cMoeda := STRZERO(nX,2)	

	If nX == 1
		oC104GDMoe:ACols[nX][nPosID]		:= TMP->CT2_LINHA
		oC104GDMoe:ACols[nX][nPosValor]		:= If("CT2_VALOR"	$ cVar, &cVar, TMP->CT2_VALOR)
		oC104GDMoe:ACols[nX][nPosDtTaxa]	:= If("CT2_DATATX"	$ cVar, &cVar, TMP->CT2_DATATX)
		oC104GDMoe:ACols[nX][nPosCriter]	:= If("CT2_CONVER"	$ cVar, &cVar, TMP->CT2_CONVER)
	Else    
	
		If Empty(aTaxa[nX-1])
			aTaxa[nX-1]:= Posicione("CTP",1,xFilial("CT2")+DTOS(&("TMP->CT2_DTTX"+cMoeda))+cMoeda,"CTP->CTP_TAXA")
		EndIf 
			                                                
		oC104GDMoe:ACols[nX][nPosID]		:= TMP->CT2_LINHA
		oC104GDMoe:ACols[nX][nPosValor]		:= If(("CT2_VALR"+cMoeda) $ cVar, &cVar, &("TMP->CT2_VALR"+cMoeda))
		oC104GDMoe:ACols[nX][nPosTaxa]		:= If(Empty(TMP->CT2_VALOR)/* .OR. Empty(TMP->CT2_DC) .AND.  Empty(TMP->CT2_DEBITO) .AND.  Empty(TMP->CT2_CREDITO)*/, ;
			aTaxa[nX-1],(TMP->CT2_VALOR /(&("TMP->CT2_VALR"+cMoeda)))) // No momento que a tela for carregada, a taxa serแ atribuida de acordo com a tabela CTP. Depois pode haver recalculo, dependendo do crit้rio de conversใo
		oC104GDMoe:ACols[nX][nPosDtTaxa]	:= If(("CT2_DTTX"+cMoeda) $ cVar, &cVar, &("TMP->CT2_DTTX"+cMoeda))
		oC104GDMoe:ACols[nX][nPosCriter]	:= If("CT2_CONVER"	$ cVar, &cVar, TMP->CT2_CONVER)
	EndIf

Next nX

oC104GDMoe:oBrowse:Refresh()

RestArea(aSaveCTP)
RestArea(aSaveArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC104AtuEntบAutor  ณMicrosiga           บ Data ณ  16/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a grid Entidades                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C104AtuEnt()
Local nPosEntDeb	:= Ascan(oC104GDEnt:aHeader,{|x|x[2] == "ENTID_DEB"})
Local nPosEntCre	:= Ascan(oC104GDEnt:aHeader,{|x|x[2] == "ENTID_CRED"})
Local nQtdEnt		:= Len(oC104GDEnt:ACols)
Local nX			:= 0
                   
	//Conta Contabil          
	If nQtdEnt >= 1
		oC104GDEnt:ACols[1][nPosEntDeb] := TMP->CT2_DEBITO
		oC104GDEnt:ACols[1][nPosEntCre] := TMP->CT2_CREDIT
	EndIf
	//Centro de Custo
	If nQtdEnt >= 2
		oC104GDEnt:ACols[2][nPosEntDeb] := TMP->CT2_CCD
		oC104GDEnt:ACols[2][nPosEntCre] := TMP->CT2_CCC
	EndIf
	//Item Contabil         
	If nQtdEnt >= 3
		oC104GDEnt:ACols[3][nPosEntDeb] := TMP->CT2_ITEMD
		oC104GDEnt:ACols[3][nPosEntCre] := TMP->CT2_ITEMC
	EndIf
	//Classe de valor
	If nQtdEnt >= 4
		oC104GDEnt:ACols[4][nPosEntDeb] := TMP->CT2_CLVLDB
		oC104GDEnt:ACols[4][nPosEntCre] := TMP->CT2_CLVLCR
	EndIf

	If nQtdEnt > 4 //Entidades adicionais

		For nX := 5 To nQtdEnt                      
			oC104GDEnt:ACols[nX][nPosEntDeb] := &("TMP->CT2_EC" + STRZERO(nX,2) + "DB")
			oC104GDEnt:ACols[nX][nPosEntCre] := &("TMP->CT2_EC" + STRZERO(nX,2) + "CR")
		Next nX
	
	EndIf

oC104GDEnt:oBrowse:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC104AtuAtvบAutor  ณMicrosiga           บ Data ณ  16/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a grid Atividades Complementares                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C104AtuAtv()
Local nPosEntDeb	:= Ascan(oC104GDAtv:aHeader,{|x|x[2] == "ATIV_DEB"})
Local nPosEntCre	:= Ascan(oC104GDAtv:aHeader,{|x|x[2] == "ATIV_CRED"})
Local cVar			:= ReadVar()
Local nX			:= 0
                       
	cVar := AllTrim(SubStr(cVar,At(">",cVar)+1,Len(cVar)))

	If X3USADO("CT2_ATIVDE") .AND. X3USADO("CT2_ATIVCR")
		//Atualiza Outras Atividades
		oC104GDAtv:ACols[1][nPosEntDeb] := If(cVar == "CT2_ATIVDE", M->CT2_ATIVDE,TMP->CT2_ATIVDE)
		oC104GDAtv:ACols[1][nPosEntCre] := If(cVar == "CT2_ATIVCR", M->CT2_ATIVCR,TMP->CT2_ATIVCR)
	
                                
	    //Atualiza Atividades
		For nX := 1 To nQtdEntid
	
			If cVar == "CT2_AT" + STRZERO(nX,2) + "DB"
				oC104GDAtv:ACols[nX+1][nPosEntDeb] := &("M->CT2_AT" + STRZERO(nX,2) + "DB")
			Else
				oC104GDAtv:ACols[nX+1][nPosEntDeb] := &("TMP->CT2_AT" + STRZERO(nX,2) + "DB")
			EndIf
	
			If cVar == "CT2_AT" + STRZERO(nX,2) + "CR"
				oC104GDAtv:ACols[nX+1][nPosEntCre] := &("M->CT2_AT" + STRZERO(nX,2) + "CR")
			Else
				oC104GDAtv:ACols[nX+1][nPosEntCre] := &("TMP->CT2_AT" + STRZERO(nX,2) + "CR")
			EndIf
	
		Next nX
	Else
		//Atualiza Atividades
		For nX := 1 To nQtdEntid
	
			If cVar == "CT2_AT" + STRZERO(nX,2) + "DB"
				oC104GDAtv:ACols[nX][nPosEntDeb] := &("M->CT2_AT" + STRZERO(nX,2) + "DB")
			Else
				oC104GDAtv:ACols[nX][nPosEntDeb] := &("TMP->CT2_AT" + STRZERO(nX,2) + "DB")
			EndIf
	
			If cVar == "CT2_AT" + STRZERO(nX,2) + "CR"
				oC104GDAtv:ACols[nX][nPosEntCre] := &("M->CT2_AT" + STRZERO(nX,2) + "CR")
			Else
				oC104GDAtv:ACols[nX][nPosEntCre] := &("TMP->CT2_AT" + STRZERO(nX,2) + "CR")
			EndIf
	
		Next nX		
	EndIf

oC104GDAtv:oBrowse:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC104AtuDigบAutor  ณMicrosiga           บ Data ณ  19/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a grid Totais Digitados                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C104AtuDig()
Local aSaveArea		:= GetArea()
Local aSaveSX5		:= SX5->(GetArea())
Local aSaveCTO		:= CTO->(GetArea())
Local aSaveTMP		:= TMP->(GetArea())
Local nValCred		:= 0
Local nValDeb		:= 0
Local nPosLin		:= 0
Local aDescrMoed	:= {}
Local aDescTpSld	:= {}
Local aLegenda		:= CtbLegenda("CT2")
Local cCor			:= ""
Local nX,nY			:= 0
Local cVar			:= ReadVar()
Local cLin			:= TMP->CT2_LINHA
Local cTipSaldo		:= ""
Local nValLanc		:= 0
Local cTipDC		:= ""
Local lDel			:= IsInCallStack("CT104DEL")

	oC104GDDig:aCols := {}

	//Obtem a descricao dos tipos de saldos
	dbSelectArea("SX5")
	dbSetOrder(1)
	dbSeek(xFilial("SX5")+"SL")
	While SX5->(!Eof()) .And. AllTrim(SX5->X5_TABELA) == "SL"
		If SX5->X5_CHAVE != "0"
			Aadd(aDescTpSld,AllTrim(SX5->X5_CHAVE) + " " + AllTrim(SX5->X5_DESCRI))
		EndIf
	SX5->(DbSkip())
	EndDo

	dbSelectArea("CTO")
	dbSetOrder(1) //CTO_FILIAL+CTO_MOEDA
	dbSeek(xFilial("CTO")+"01")
	While CTO->(!EOF()) .And. CTO->CTO_FILIAL == xFilial("CTO")

		Aadd(aDescrMoed,CTO->CTO_MOEDA + " " + AllTRIM(CTO->CTO_DESC) + " (" + AllTrim(CTO->CTO_SIMB) + ")")

	CTO->(dbSkip())
	EndDo
	
	TMP->(dbGoTop())
	While TMP->(!Eof())

		If !(lDel .And. TMP->CT2_LINHA == cLin .And. !(TMP->CT2_FLAG))//Nao considera linhas deletadas

			For nY := 1 To __nQuantas
	
				nValCred	:= 0
				nValDeb		:= 0
		
				//Tipo do Saldo
				cTipSaldo	:= If(cLin != TMP->CT2_LINHA, TMP->CT2_TPSALD,If("CT2_TPSALD" $ cVar,&cVar,TMP->CT2_TPSALD))
		
				//Valor do lancamento
				If cLin != TMP->CT2_LINHA
					If nY == 1
						nValLanc := TMP->CT2_VALOR
					Else
						nValLanc := &("TMP->CT2_VALR"+STRZERO(nY,2))
					EndIf
				Else
					If nY == 1      
						If "CT2_VALOR" $ cVar
							nValLanc := &(cVar)
						Else
							nValLanc := TMP->CT2_VALOR
						EndIf
					Else
						If ("CT2_VALR"+STRZERO(nY,2)) $ cVar
							nValLanc := &(cVar)
						Else
							nValLanc := &("TMP->CT2_VALR"+STRZERO(nY,2))
						EndIf
					EndIf				
								
				EndIf
				
				//Tipo do Lancamento
				cTipDC	:= If(cLin != TMP->CT2_LINHA, TMP->CT2_DC,If("CT2_DC" $ cVar,&cVar,TMP->CT2_DC))
		
				//Verifica o tipo de lancamento e obt้m o valor
				Do Case
			
					Case cTipDC == "1" //Debito
						nValDeb		:= nValLanc
						nValCred	:= 0
			
					Case cTipDC == "2" //Credito
						nValDeb		:= 0
						nValCred	:= nValLanc
			
					Case cTipDC == "3" //Partida Dobrada
						nValDeb		:= nValLanc
						nValCred	:= nValLanc
	
					Case cTipDC == "4" //Cont. Hist
						nValCred	:= 0
						nValDeb		:= 0
			
				EndCase
		
				If (nPosLin := Ascan(oC104GDDig:aCols,{|x| AllTrim(SubStr(x[2],1,1)) == cTipSaldo .And. (SubStr(x[3],1,2) == STRZERO(nY,2))})) > 0 //Confirma se existe a linha do tipo de saldo para acumular o valor
		
					oC104GDDig:aCols[nPosLin][4] += nValDeb		//Debito
		
					oC104GDDig:aCols[nPosLin][5] += nValCred	//Credito
		
				Else                                                                                    
	
					For nX := 1 To Len(aLegenda)
			
						cVarAux	:= If(cLin != TMP->CT2_LINHA,"TMP->",If("CT2_TPSALD" $ cVar,"M->","TMP->"))
			
						If &(cVarAux + aLegenda[nX][1])
							cCor := aLegenda[nX][2]
							Exit
						EndIf
			
					Next nX
	
											//Legenda							,Tipo de Sld				,Moeda			,A Debito	,A Credito	
					Aadd(oC104GDDig:aCols,{LoadBitmap( GetResources(), cCor)	,aDescTpSld[aScan(aDescTpSld,cTipSaldo)],aDescrMoed[nY]	,nValDeb	,nValCred	,.F.})
		
				EndIf
		
			Next nY
		
		EndIf

	TMP->(dbSkip())
	EndDo

oC104GDDig:oBrowse:Refresh()

RestArea(aSaveTMP)
RestArea(aSaveCTO)
RestArea(aSaveSX5)
RestArea(aSaveArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC104RemoveบAutor  ณMicrosiga           บ Data ณ  20/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Remove do array aAltera os campos da grid de lancametos    บฑฑ
ฑฑบ          ณ que nao poderao ser editados pelo usuario de acordo com a  บฑฑ
ฑฑบ          ณ capa do lote                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C104Remove(aAltera,cCritConv,dDtTaxConv,cTipoSaldo)
Local nX			:= 0
Local nQtdRemov		:= 0
Local nPosConver	:= 0
Local nPosDataTax	:= 0
Local nPosTpSald	:= 0

	//Verifica a configura็ใo da capa do lote para nใo permitir a edi็ใo dos campos
	//Campo Criterio de Conversao
	If !Empty(cCritConv) .And. (nPosConver := Ascan(aAltera,{|x| AllTrim(x) == "CT2_CONVER"})) > 0
		ADEL(aAltera,nPosConver) 
		nQtdRemov++		
	EndIf
	
	//Campo Data da taxa de conversใo
	If !Empty(dDtTaxConv)

		For nX := 1 To __nQuantas

			If nX == 1 
				If (nPosDataTax := Ascan(aAltera,{|x| AllTrim(x) == "CT2_DATATX"})) > 0
					ADEL(aAltera,nPosDataTax)
					nQtdRemov++
				EndIf
			Else
				If (nPosDataTax := Ascan(aAltera,{|x| AllTrim(x) == "CT2_DTTX"+STRZERO(nX,2)})) > 0
					ADEL(aAltera,nPosDataTax)
					nQtdRemov++
				EndIf
			EndIf

		Next nX

	EndIf

	//Campo Tipo do saldo
	If !Empty(cTipoSaldo)
		ADEL(aAltera,Ascan(aAltera,{|x| AllTrim(x) == "CT2_TPSALD"}))
		nQtdRemov++
	EndIf

	ASIZE(aAltera,Len(aAltera)-nQtdRemov)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC104SetDadบAutor  ณMicrosiga           บ Data ณ  20/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define valores na grid de lan็amento de acordo com a capa  บฑฑ
ฑฑบ          ณ do lote                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C104SetDad()
Local nX := 0

	RecLock("TMP",.F.)
		//Criterio de conversao
		If(!Empty(aC104Dados[1]),TMP->CT2_CONVER := aC104Dados[1],Nil)
	
		//Tipo de Saldo
		If(!Empty(aC104Dados[3]),TMP->CT2_TPSALD := aC104Dados[3],Nil)
	
		//Data da taxa de conversao
		If !Empty(aC104Dados[2])
			For nX := 1 To __nQuantas
	
				If nX == 1 
					TMP->CT2_DATATX := aC104Dados[2]
	
				Else
					&("TMP->"+"CT2_DTTX"+STRZERO(nX,2)) := aC104Dados[2]
				EndIf
	
			Next nX
		EndIf
	TMP->(MsUnlock())

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC104VldCriบAutor  ณMicrosiga           บ Data ณ  21/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o criterio de conversao informado na capa do lote   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C104VldCri(cMoeda,cCriterio,dDataLanc,dDtTaxConv)
Local nCont
Local lRet	:= .T.
Local dData	:= CTOD("  /  /  ")

	For nCont := 1 To Len(AllTrim(cCriterio))
		If nCont == 1
			//Na moeda 01 podera ser digitado somente 1 ou 5=>pois nao utiliza criterio de conversao                             	
			//Na moeda 01, nao sera possivel alterar o criterio de conversao. O criterio so 
			//sera alterado quando alterar o valor. ( na moeda 01)			
			If !(SubStr(cCriterio,nCont,1) $ "1|5")
				lRet := .F.
				Help(" ",1,"ERRO_CRITE")
				Exit
			EndIf		
		Else
			//Verifica se foi digitado valor invalido
			If !(SubStr(cCriterio,nCont,1) $ "123456789A")
				lRet := .F.
				Help(" ",1,"ERRO_CRITE")
				Exit
			EndIf
			
			//Se a moeda do lancamento for diferente de "01" o criterio das moedas devera ser
			//4-Informada ou 5-Nao informada
			If cMoeda <> "01" .And. !(SubStr(cCriterio,nCont,1) $ "4|5")
				lRet := .F.
				MsgAlert(STR0041+": " + cMoeda) //"Criterio invแlido para a moeda"
				Exit
			EndIf
			
			//Verificar se existe amarracao moeda x calendario na moeda que esta alterando a conversao 
			//So sera verificado se o criterio de conversao for diferente de "5" => Nao tem conversao.
			If !(SubStr(cCriterio,nCont,1) $ "5")
				If !Empty(dDtTaxConv)
					dData	:= dDtTaxConv
				ElseIf !Empty(dDataLanc)
					dData	:= dDataLanc
				EndIf
				If !Empty(dData)
					lRet := CtbDtComp(4,dData,StrZero(nCont,2),.T.)		
					If !lRet
						Exit
					EndIf	
				Endif
			EndIf
			
		EndIf
	Next

	//O campo Dt. Taxa Conv (CTC_DTTXDC) somente devera estar preenchido se houver o criterio "9"
	If !Empty(dDtTaxConv) .And. !("9" $ cCriterio)
		MsgAlert(STR0051 + " " + X3Titulo("CTC_DTTXDC") + " " + STR0052 +" '9' " + STR0053) //"Campo"###"invalido nใo hแ crit้rio"###informado
		dDtTaxConv := CriaVar("CTC_DTTXDC",.F.)
	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC104VldDtCบAutor  ณMicrosiga           บ Data ณ  21/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a data da taxa de conversใo da capa do lote         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function C104VldDtC(nOpc,dDtTaxConv,cCriterio)
Local lRet := .T.

lRet := CtbValiDt(nOpc,dDtTaxConv)

If  lRet .And. !("9" $ cCriterio)
	lRet := .F.
	MsgAlert(STR0054  + ' 9, ' + STR0053) //"Nao hแ crit้rio"###"informado"
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCT104DEL  บAutor  ณMicrosiga           บ Data ณ  22/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a dele็ใo de linha na grid de lancamentos           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CT104DEL()
Local lRet := .T.

	lRet := CT102DEL()

	If lRet
		//Atualiza a Grid Total Digitado
		C104AtuDig()
	EndIf

Return(lRet)