#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINA280.CH"

//Variáveis para integração via mensagem única
Static __aBaixados := {} 
Static __aNovosTit := {}
Static __cNroFatur := ''
//Variáveis para integração via mensagem única
Static dLastPcc		:= CTOD("22/06/2015")
Static lRmClass		:= GetNewPar("MV_RMCLASS",.F.)
Static lSE1Compart	:= Iif( FWSizeFilial() > 2, FWModeAccess("SE1",1) == "C", FWModeAccess("SE1",3) == "C")
Static _oFina2801
Static __lNewDic     := .f.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Fina280	³ Autor ³ Paulo Boschetti	    ³ Data ³ 27/07/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sele‡„o de titulos para Fatura a RECEBER	    			  ³±±     
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fina280()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fina280(nPosArotina, lAutomato, xAutoCab)

Local lFA280FBW		:= ExistBlock( "FA280FBW" )
Local cFiltro		:= ""

PRIVATE aRotina := MenuDef()
PRIVATE cFatura		:=CRIAVAR("E1_NUM")
PRIVATE cCli		:=Space(6)
PRIVATE cLoja		:=Space(2)
PRIVATE cLojaFat	:=Space(2)
PRIVATE cPrefix		:=Space(3)
PRIVATE cCliFat		:=Space(6)
PRIVATE dVencto		:=Ctod(Space(8))
PRIVATE dDataDe		:=dDataBase
PRIVATE dDataAte	:=dDataBase
PRIVATE cNat		:=Space(10)
PRIVATE nTotAbat	:=0
PRIVATE nValorFat 	:=0
PRIVATE nValorF		:=0
PRIVATE nValor 		:=0
PRIVATE nVLCruz		:=0
PRIVATE nVARURV		:=0
PRIVATE nQtdTit		:=0
PRIVATE nValtot		:=0
PRIVATE aVenc,aGets[0]
PRIVATE nMoedFat	:=1
PRIVATE nVlrAtu 	:=0
PRIVATE aMark := {}
Private cRA := Space(30)
PRIVATE lF280Auto	:= xAutoCab <> NIL
PRIVATE aAutoCab	:= {}
PRIVATE aAuxSe5		:= {}

//-------------------------------------------------
// Define o cabecalho da tela de baixas
//-------------------------------------------------
PRIVATE cCadastro := STR0005 //"Faturas a Receber"
//Variáveis para mensageria única
Private lUsaBolsa	:= .F.
Private lMsgUnq		:= FWHasEai('FINA280',.T.,,.T.) .And. FWHasEai('FINA040',,.T.,.T.) //indica se usa geração de título por mensagem unica. 

Default nPosArotina 	:= 0  
Default lAutomato		:= .F.

__lNewDic := ( TableIndic("FO0") .and. TableIndic("FO1") .and. TableIndic("FO2") .and. TableIndic("FKD") .and. TableIndic("FKC"))


If __lNewDic .and. !lAutomato									//ROTINA DESCONTINUADA
	HELP(" ",1,STR0097,,STR0096,2,0,,,,,,{STR0098}) //A rotina de faturas a receber(FINA280) foi reestruturada e unificada na rotina de Liquidação(FINA460); 
	Return .F.										//a partir do release 12.1.17 expedição de Outubro."
Endif												//Utilizar a rotina de Liquidação(FINA460) atualizada na versão 12.1.17 expedição de Outubro de 2017.

If FindFunction( "GETROTINTEG" ) .AND. FindFunction("FwHasEAI") .and. FWHasEAI("FINA070",.T.,,.T.) .And. !lRmClass //501
	MsgInfo(STR0082) //"Integração ativada, dessa forma os títulos originados pela integração, não poderam ser utilizados por essa rotina."
Endif

Fa280MotBx("FAT","FATURAS   ","ANNS")   

dbSelectArea("SE1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ACIONA A FUNCAO PERGUNTE									           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey (VK_F12,{|a,b| AcessaPerg("AFI280",.T.)})
Pergunte("AFI280",.F.)

If nPosArotina > 0
	aAutoCab := xAutoCab
	dbSelectArea('SE1')
	bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
	Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina,lAutomato)
Else
	If lFA280FBW
		cFiltro := ExecBlock( "FA280FBW" )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a Fun‡„o de BROWSE									        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6, 1,22,75,"SE1",,"!E1_SALDO",,,,Fa040Legenda("SE1"),,,,,,,, IIf( lFA280FBW, cFiltro, NIL ) ) // 19-SQL Filter
Endif

Set Key VK_F12 to

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SE1")
dbSetOrder(1)   

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ fA280Aut ³ Autor ³ Paulo Boschetti		³ Data ³ 27/07/93   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca‡„o dos titulos para emiss„o de fatura				     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fa280Aut()												              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fA280Aut(cAlias,cCampo,nOpcE,lAutomato)

Local lPanelFin := IsPanelFin()
LOCAL cArquivo
LOCAL nTotal	:= 0
LOCAL nHdlPrv	:= 0
LOCAL cPadrao	:= "595"
LOCAL lPadrao  := VerPadrao(cPadrao)
LOCAL nW 		:= 1
LOCAL dDatCont	:= dDatabase
LOCAL cIndex	:= ""
LOCAL nOpca 	:= 0
LOCAL oDlg, oDlg1,oDlg2
LOCAL oValor	:= 0
LOCAL oQtdTit 	:= 0
LOCAL oValorFat := 0
LOCAL cMarca	:= GetMark()
LOCAL aMoedas	:= {}
LOCAL cVar,nO
LOCAL OCbx, nRegE1
LOCAL lUsado	:= .F.
LOCAL aCampos 	:= {}
LOCAL aTam 		:= {}
LOCAL cAliasSE1 := "SE1"
Local lHead 	:= .F.
Local lDigita	:= .F.
Local nValTotal := 0
Local cFatAnt 
Local oTimer
Local nTimeOut  := SuperGetMv("MV_FATOUT",,900)*1000 	// Estabelece 15 minutos para que o usuarios selecione os titulos a faturar
Local nTimeMsg  := SuperGetMv("MV_MSGTIME",,120)*1000 	// Estabelece 02 minutos para exibir a mensagem para o usuário
                                                      	// informando que a tela fechará automaticamente em XX minutos
Local cImpostos := ""
Local aChaveLbn := {}   
Local aSize 	:= {}        
Local oPanel
Local aBut280 := {{"PESQUISA",{||Fa280Pesq(oMark,cAlias,cAliasSe1)}, "Pesquisar","Pesquisar"}}
Local oTipoFat
LOCAL cCond := Space(3)
Local lRet		:=	.T.
Local aFlagCTB := {}
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)  
Local lBlqFat := .T.

Local lFa280Qry := ExistBlock("FA280QRY")
Local cQuery
Local cQueryADD
Local aStru		:= SE1->(DbStruct())
Local nCt := 0

//Rastreamento
Local lRastro		:= FVerRstFin()
Local aRastroOri	:= {}
Local aRastroDes	:= {}
Local nValProces	:= 0

//Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default))
Local lPccBxCr		:= FPccBxCr()
Local aPccBxCr		:= {0,0,0,0}
Local cPccBxCr		:= ""
Local nPropPcc		:= 1
Local nPis			:= 0
Local nCofins		:= 0
Local nCsll			:= 0
Local	nTotPis		:= 0
Local nTotCofins	:= 0
Local nTotCsll		:= 0
Local nTotFatura	:= 0
Local nTotBase		:= 0
Local nBaseImp		:= 0

//Controla IRPJ na baixa
Local lIrPjBxCr		:= FIrPjBxCr()
Local aDadosIr		:= {0,0}//aDadosIR[1] - valor do IRRF  / aDadosIR[2] - Base de calculo do IR
Local cIrBxCr		:= ""
Local nPropIR		:= 1
Local nIrrf			:= 0
Local nTotIr   		:= 0   
Local nBaseIR		:=0
Local nTotBaseIr	:= 0   
Local cTitpai		:= ""
Local nAmbTOP
Local nAmbCLASSIS
Local nX
Local aTitInc := {}
Local cFiltroAbat := ""
Local cChaveSE1	  := ""
Local oFnt
Local aRetF280CON := {}

//639.04 Base Impostos diferenciada
Local lBaseImp	:= F040BSIMP(2)
Local l280nft 	:= ExistBlock("F280NFT")
Local cRetQuery := "" 

Local aSelFil		:= {}
Local aTmpFil		:= {}
Local cTmpSE1Fil 	:= ""
Local cFilSE1		:= ""

//Situacao de cobranca
Local cLstCart	:= FN022LSTCB(1,"0005")	//Lista das situacoes de cobranca - CARTEIRA

//Variáveis para integração via Mensagem Única
Local cPerLet	:= ''
Local cProduto	:= ''
Local iX 		:= 0
Local oFilInt
Local aFilInt	:=  {"1=Sim","2=Não"}
//Variáveis para integração via Mensagem Única

//Variaveis de tela
Local nLinIni := 0
Local nColIni := 0
Local nLinFin := 0
Local nColFin := 0
Local oSize	:= NIL	

Local nVlrISS	:= 0
Local aISSDup	:= {}

//Variaveis de uso Automação

Local nRegAuto	:= 0
Local nI			:= 0
Local lGetAuto 	:= FindFunction("GetParAuto")
Local aRetAuto	:= {}
Local cSE1Fil		:= ""
Local lA280GERF := ExistBlock("A280GERF")
Local lFA280_	:= ExistBlock("FA280")

DEFINE FONT oFnt NAME "Arial" SIZE 10,14 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa array com as moedas existentes.						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aMoedas := FDescMoed()  
dbSelectArea( cAlias )

PRIVATE oGet
PRIVATE aHeader := {}
PRIVATE aCols	:= {}
PRIVATE oValTot
PRIVATE nValTot := 0
PRIVATE nUsado := 0
PRIVATE nValCruz:= 0
PRIVATE nVarURV := 0
PRIVATE lInverte:= .F.
PRIVATE cTipo	:= Criavar ("E1_TIPOFAT")
PRIVATE cOldTipo := ""
PRIVATE cLote
PRIVATE nOrdSE1	:= 0
PRIVATE nVlrAtu :=0
PRIVATE lMsErroAuto := .F.
PRIVATE cCondicao := Space(3)
PRIVATE lCalcPcc := .F.

//variaveis para o ponto de entrada F280SE5
PRIVATE lF280SE5      := Existblock("F280SE5")
PRIVATE aRecSe5       := {}

//Variável para mensageria única
Private cFilMsg	:= "2" //Filtra movimentos de msg unica 

PUBLIC aVlCruz	:= {} // Deve ficar como public por causa do FINA290(GravaDp)

Default lAutomato := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento n„o ‚ menor que data limite de ³
//³ movimentacao no financeiro    										  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !DtMovFin(,,"2")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o campo A1_CLIFAT est  em uso   					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder( 2 )
dbSeek("A1_CLIFAT")
lUsado := x3uso(X3_USADO)

dbGotop()
dbSeek("E1_PREFIXO")
cPictPref := AllTrim(X3_PICTURE)
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero do Lote 											  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LoteCont("FIN")

cPrefix  := SuperGetMv("MV_FATPREF",,Space(3))      

If Len(cPrefix) < 3
	cPrefix := cPrefix + Space(3-Len(cPrefix))
EndIf

cNat     := CRIAVAR("E1_NATUREZ")
dDataDe	 :=dDataBase
dDataAte :=dDataBase
nValorFat:=0

aTam	:=TamSX3("E1_CLIENTE")
cCli	:=Space(aTam[1])
cCliFat	:=Space(aTam[1])

aTam	:=TamSX3("E1_LOJA")
cLoja 	:=Space(aTam[1])
cLojaFat:=Space(aTam[1])

dbSelectArea(cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA F280PRE                                      ³
//³ Este PE serve para inicializar dados para montagem da fatura  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("F280PRE")
	ExecBlock("F280PRE",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebe dados a serem digitados										  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cVar := aMoedas[1]
aMark := {}

If lPanelfin
	oPanelDados := FinWindow:GetVisPanel()
	oPanelDados:FreeChildren()
	aDim := DLGinPANEL(oPanelDados)
	DEFINE MSDIALOG oDlg OF oPanelDados:oWnd FROM 0,0 To 0,0 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )							
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Observacao Importante quanto as coordenadas calculadas abaixo: ³ 
	//³ -------------------------------------------------------------- ³ 		
	//³ a funcao DlgWidthPanel() retorna o dobro do valor da area do	 ³
	//³ painel, sendo assim este deve ser dividido por 2 antes da sub- ³
	//³ tracao e redivisao por 2 para a centralizacao. 					 ³		
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	nEspLarg := (((DlgWidthPanel(oPanelDados)/2) - 218) /2)-4
	nEspLin  := 0			
Else   
  	nEspLarg := 0 
  	nEspLin  := 0  	
	DEFINE MSDIALOG oDlg FROM 22,9 TO 260,550 TITLE STR0009 PIXEL  // "Faturas a Receber"
EndIf

oDlg:lMaximized := .F.
oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT    			

@ 004+nEspLin, 007+nEspLarg TO 036+nEspLin, 235+nEspLarg OF oPanel PIXEL
@ 038+nEspLin, 007+nEspLarg TO 070+nEspLin, 235+nEspLarg OF oPanel PIXEL
if !lUsado
	@ 072+nEspLin, 007+nEspLarg TO 104+nEspLin, 235+nEspLarg OF oPanel PIXEL
Else
	@ 072+nEspLin, 007+nEspLarg TO 116+nEspLin, 235+nEspLarg OF oPanel PIXEL
EndIf


aTam := TamSx3("E1_NUM")
cFatura	:= Soma1( GetMv("MV_NUMFAT"),  aTam[1])
cFatura	+= Space(aTam[1] - Len(cFatura))
cMay    := "SE1"+xFilial("SE1")+cFatura

SE1->(DbSetOrder(1))
While SE1->(MsSeek(xFilial("SE1")+PadR(cPrefix,3)+cFatura)) .Or. !MayIUseCode(cMay)
	// busca o proximo numero disponivel 
	cFatura := Soma1(RTrim(cFatura))
	cMay    := "SE1"+xFilial("SE1")+cFatura
EndDo
cFatAnt := cFatura

IF l280nft
	lBlqFat:= ExecBlock("F280NFT",.F.,.F.,{lBlqFat})
Endif
                   
@ 020+nEspLin, 014+nEspLarg MSGET cPrefix	Picture cPictPref 						SIZE 10, 11 OF oPanel PIXEL
@ 020+nEspLin, 040+nEspLarg MSGET oTipoFat VAR cTipo	F3 "05"	Picture "@!" Valid FA280Tipo(@cTipo);
	SIZE 10, 11 OF oPanel Hasbutton PIXEL 
oTipoFat:cReadVar := "E1_TIPOFAT"			
@ 020+nEspLin, 074+nEspLarg MSGET cFatura	Valid !Empty(cFatura) .and. FA280NUM()	when lBlqFat SIZE 43, 11 OF oPanel PIXEL
@ 020+nEspLin, 120+nEspLarg MSGET cNat		F3 "SED" Valid Fa280Nat()       		SIZE 55, 11 OF oPanel Hasbutton PIXEL
@ 020+nEspLin, 175+nEspLarg MSCOMBOBOX oCbx VAR cVar ITEMS aMoedas 					SIZE 46, 55 OF oPanel PIXEL
oCbx:cReadVar := "E1_MOEDA"
@ 054+nEspLin, 014+nEspLarg MSGET dDataDe	Valid F280VLDDT("DataDe", dDataDe)	SIZE 50, 11 OF oPanel Hasbutton PIXEL
@ 054+nEspLin, 068+nEspLarg MSGET dDataAte Valid F280VLDDT("DataAte", dDataDe, dDataAte) SIZE 50, 11 OF oPanel Hasbutton PIXEL
If cPaisLoc<>"CHI"
	@ 054+nEspLin, 120+nEspLarg MSGET nValorFat Picture "@E 9,999,999,999.99"  SIZE 65, 11 OF oPanel Hasbutton PIXEL
Else
	@ 054+nEspLin, 120+nEspLarg MSGET nValorFat Picture "@E 999,999,999,999"  SIZE 65, 11 OF oPanel Hasbutton PIXEL
Endif

If lUsado                                                            
	@ 101+nEspLin, 014+nEspLarg MSGET cCliFat F3 "SA1" Valid fa280cli(cCliFat)	SIZE 70,11 OF oPanel Hasbutton PIXEL
	@ 101+nEspLin, 082+nEspLarg MSGET cLojaFat	Picture "@!" Valid Fa280Cli(cClifat,cLojaFat) SIZE 10, 11 OF oPanel PIXEL
endIf
@ 010+nEspLin, 014+nEspLarg SAY STR0010  SIZE 21, 7 OF oPanel PIXEL //"Prefixo"
@ 010+nEspLin, 040+nEspLarg SAY STR0054  SIZE 12, 7 OF oPanel PIXEL //"Tipo"
@ 010+nEspLin, 074+nEspLarg SAY STR0055  SIZE 49, 7 OF oPanel PIXEL //"Nr.Fatura"
@ 010+nEspLin, 120+nEspLarg SAY STR0012  SIZE 28, 7 OF oPanel PIXEL //"Natureza"
@ 010+nEspLin, 175+nEspLarg SAY STR0013  SIZE 28, 7 OF oPanel PIXEL //"Moeda"

@ 044+nEspLin, 014+nEspLarg SAY STR0014 SIZE 32, 7 OF oPanel PIXEL //"Emiss„o de"
@ 044+nEspLin, 068+nEspLarg SAY STR0015 SIZE 32, 7 OF oPanel PIXEL //"At‚"
@ 044+nEspLin, 120+nEspLarg SAY STR0016 SIZE 50, 7 OF oPanel PIXEL //"Valor da Fatura"

If lMsgUnq 
	@ 054+nEspLin, 185 +nEspLarg COMBOBOX oFilInt VAR cFilMsg ITEMS aFilInt	SIZE 50, 11 OF oPanel PIXEL
	@ 044+nEspLin, 185 +nEspLarg SAY STR0092 SIZE 50, 7 OF oPanel PIXEL //"Filtra Integração"
EndIf


@ 072+nEspLin, 014+nEspLarg SAY STR0017 SIZE 35, 7 OF oPanel PIXEL //"Cliente"
@ 072+nEspLin, 086+nEspLarg SAY STR0018 SIZE 30, 7 OF oPanel PIXEL //"Loja"
    
@ 080+nEspLin, 014+nEspLarg MSGET cCli	F3 "SA1" Valid Fa280Cli(cCli) .And. Fa280Num() SIZE 65, 11 OF oPanel Hasbutton PIXEL
@ 080+nEspLin, 086+nEspLarg MSGET cLoja	Picture "@!" Valid Fa280Cli(cCli,cLoja) SIZE 21, 11 OF oPanel PIXEL

If lUsado
	@ 093+nEspLin, 014+nEspLarg SAY STR0019  SIZE 40, 7 OF oPanel PIXEL //"Cliente a Faturar"
EndIf

If !lAutomato .And. (Type("lF280Auto")<>"U" .and. !lF280Auto)
	If lPanelFin  //Chamado pelo Painel Financeiro			
		oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])			
		ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,;
		{||nOpca:=1,IF(FA280Tipo(@cTipo) .and. FA280NUM() .and. Fa280Ok(oDlg),oDlg:End(),nOpca:=0)},;
		{||nOpca:=0,oDlg:End()})
			
	Else			
		DEFINE SBUTTON FROM 07, 240 TYPE 1 ACTION (nOpca:=1,IF(FA280Tipo(@cTipo) .and. FA280NAT() .and. FA280NUM() .and. Fa280Ok(oDlg),oDlg:End(),nOpca:=0)) ENABLE OF oPanel
		DEFINE SBUTTON FROM 19, 240 TYPE 2 ACTION oDlg:End() ENABLE OF oPanel	
		ACTIVATE MSDIALOG oDlg CENTERED
	Endif
ElseIf lAutomato

	If lGetAuto
		aRetAuto 	:= GetParAuto("FINA280TESTCASE")
		cPrefix	:= aRetAuto[1] //Prefixo
		cTipo		:= aRetAuto[2] //tipo
		cFatura	:= aRetAuto[3] //Numero da fatura
		cNat		:= aRetAuto[4] //Natureza
		cVar		:= aRetAuto[5] //Moeda
		dDataDe	:= aRetAuto[6] //Data de emissão de
		dDataAte	:= aRetAuto[7] //Data de emissão até
		nValorFat	:= aRetAuto[8] //Valor da Fatura
		cCliFat	:= aRetAuto[9] //Cliente para seleção dos títulos
		cLojaFat	:= aRetAuto[10] //Loja para seleção dos títulos
		cCli		:= aRetAuto[11]//Cliente para geração dos títulos
		cLoja		:= aRetAuto[12]//Loja para geração dos títulos
		nOpca:=1
	EndIf
ElseIf (Type("lF280Auto")<>"U" .and. lF280Auto)
	
	// Rotina Automatica
	aValidGet:= {}
   	IF (nT := ascan(aAutoCab,{|x| x[1]='AUTPREFIXO'})) > 0
		cPrefix := aAutoCab[nT,2]
 	EndIf
 	
   	IF (nT := ascan(aAutoCab,{|x| x[1]='AUTTIPO'})) > 0
		cTipo := aAutoCab[nT,2]
 		Aadd(aValidGet,{'cTipo' ,aAutoCab[nT,2],"FA280Tipo(@cTipo)",.t.})
 	EndIf
 	
 	IF (nT := ascan(aAutoCab,{|x| x[1]='AUTNUMFAT'})) > 0
		cFatura := aAutoCab[nT,2]
 		Aadd(aValidGet,{'cFatura' ,aAutoCab[nT,2],"!Empty(cFatura) .and. FA280NUM()",.t.})
 	EndIf
 	
 	IF (nT := ascan(aAutoCab,{|x| x[1]='AUTNATUR'})) > 0
		cNat := aAutoCab[nT,2]
 		Aadd(aValidGet,{'cNat' ,aAutoCab[nT,2],"Fa280Nat()",.t.})
 	EndIf

 	IF (nT := ascan(aAutoCab,{|x| x[1]='AUTMOEDA'})) > 0
		cVar := aAutoCab[nT,2]
 	EndIf
 	
	IF (nT := ascan(aAutoCab,{|x| x[1]='AUTCLIGER'})) > 0
		cCli := aAutoCab[nT,2]
 		Aadd(aValidGet,{'cCli' ,aAutoCab[nT,2],"Fa280Cli(cCli) .And. Fa280Num()",.t.})
 	EndIf
 	
 	IF (nT := ascan(aAutoCab,{|x| x[1]='AUTLOJGER'})) > 0
		cLoja := aAutoCab[nT,2]
 		Aadd(aValidGet,{'cLoja' ,aAutoCab[nT,2],"Fa280Cli(cCli,cLoja)",.t.})
 	EndIf
 	
	If ! SE1->(MsVldGAuto(aValidGet)) // consiste os gets
		Return .f. /*Function fA280Aut*/
	EndIf
	
	nOpca := 1

EndIf

If nOpca == 0
	FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()
	Return
EndIf

nMoedFat := Val(Substr(cVar,1,2))
cImpostos := Fa280VerImp(cNat)

cPccBxCr	:= Fa280VerImp(cNat,.T.)	//Impostos PCC com calculo para o Cliente/Natureza

If (Type("lF280Auto")<>"U" .and. !lF280Auto)
	//Selecao de filiais
	If mv_par06 == 1
		//SE1 totalmente compartilhado nao habilita tela de selecao de filiais				
		If lSE1Compart
			aSelFil := { cFilAnt }
		ElseIf Len( aSelFil ) <= 0
			aSelFil := AdmGetFil(.F.,.T.,"SE1")
			If Len( aSelFil ) <= 0
				Return
			EndIf
		Endif
	Else
		aSelFil := { cFilAnt }
	EndIf
EndIf

//Tratamento para omitir os títulos de abatimento, cujo o título principal está em bordero.                     
If Select("__SE1") == 0
	ChkFile("SE1",.F.,"__SE1")
Endif

cAliasSE1 := "QRYSE1"


If (Type("lF280Auto")<>"U" .and. !lF280Auto)
	cQuery := ""
	FOR nCt= 1 To Len(aStru)
		If aStru[nCt,2] <> "M"
			cQuery+= ","+Alltrim(aStru[nCt,1])
		Endif
	Next nCt
	cQuery := "SELECT "+SubStr(cQuery,2)
	cQuery +=         ","+"SE1.R_E_C_N_O_ RECNO "
	cQuery	+= "FROM "+RetSqlName("SE1")+ " SE1 "
	cQuery	+= "WHERE "
	
	If Len(aSelFil) > 1
		cQuery += "E1_FILIAL " + GetRngFil( aSelFil, "SE1", .T., @cTmpSE1Fil )
		aAdd(aTmpFil, cTmpSE1Fil)
	Else
		cQuery 	+= "E1_FILIAL='"	+ xFilial("SE1",aSelFil[1]) + "'"
	Endif
	
	cQuery	+= " AND E1_MOEDA=" + Str(nMoedFat,2,0)
	cQuery 	+= " AND E1_CLIENTE='"	+ cCli + "'"
	IF mv_par01==1
		cQuery +=" AND E1_LOJA='"+cLoja+"'"
	EndIf
	cQuery	+= " AND E1_EMISSAO>='"+DTOS(dDataDe) + "'"
	cQuery 	+= " AND E1_EMISSAO<='"+DTOS(dDataAte)+ "'"
	cQuery	+= " AND E1_SITUACA IN "+ FormatIn(cLstCart,"|")			//Carteira, Carteira Protesto e Carteira Acordo
	cQuery	+= " AND E1_SALDO>0"
	cQuery	+= " AND E1_ORIGEM!='FINA677'"
	cQuery	+= " AND E1_TIPO NOT IN "+FormatIN(MVRECANT+MVPROVIS,,3)
	// Filtra para nao exibir os tx's
	cQuery	+= " AND E1_TIPO NOT IN "+FormatIN(cImpostos,,3)
	cQuery	+= " AND E1_FATURA='"+Space(Len(SE1->E1_FATURA)) +"'"
	// Verifica integracao com PMS e nao permite FATURAR titulos que tenham solicitacoes
	// de transferencias em aberto.
	cQuery 	+= " AND E1_NUMSOL= ' '"
	
	If cPaisLoc == "BRA"
		If cFilMsg == "1"
			cQuery	+= " AND E1_IDLAN > 0 "
		Else
			cQuery	+= " AND E1_IDLAN = 0 "
		EndIf
	EndIf
	
	//Condicao para omitir os titulos de abatimento que tenham o titulo principal em bordero
	cQuery += " AND R_E_C_N_O_ NOT IN( "
	cQuery += " SELECT SE1A.R_E_C_N_O_ "
	cQuery += " FROM "+RetSqlName("SE1")+" SE1A " //, "+RetSqlName("SE1")+" SE1B "
	cQuery += " WHERE "
	cQuery += " SE1A.E1_FILIAL = SE1.E1_FILIAL AND "
	cQuery += " SE1A.E1_NUM = SE1.E1_NUM AND "
	cQuery += " SE1A.E1_PREFIXO = SE1.E1_PREFIXO AND "
	cQuery += " SE1A.E1_PARCELA = SE1.E1_PARCELA AND "
	cQuery += " SE1A.E1_TIPO IN "+FormatIN(MVABATIM,"|")+" AND "
	cQuery	+= "SE1A.E1_SITUACA NOT IN "+ FormatIn(cLstCart,"|")+" AND " //Diferente de Carteira, Carteira Protesto e Carteira Acordo
	cQuery += " SE1A.D_E_L_E_T_ = ' ' )"
	
	//Template GEM - nao podem ser faturados os titulos do GEM
	If HasTemplate("LOT")
		cQuery+= " AND E1_NCONTR = ' '"
	EndIf
	cQuery	+= " AND D_E_L_E_T_ = ' '"
	
	If FindFunction( "GETROTINTEG" ) .AND. FindFunction("FwHasEAI") .and. FWHasEAI("FINA070",.T.,,.T.)
		cQuery += " AND LTRIM(RTRIM(E1_ORIGEM)) <> 'FINI055'"
	Endif
	
	// Permite a inclusão de uma condicao adicional para a Query
	// Esta condicao obrigatoriamente devera ser tratada em um AND ()
	// para nao alterar as regras basicas da mesma.
	IF lFa280Qry
		cQueryADD := ExecBlock("FA280QRY",.F.,.F.)
		IF ValType(cQueryADD) == "C"
			cQuery += " AND (" + cQueryADD + ")"
		ENDIF
	ENDIF
	// Exclui o tipo da ordem para que os titulos sejam exibidos por ordem de 
	// prefixo+num+parcela. O tipo sera exibido conforme cadastrado, para que um titulo
	// de abatimento nao seja exibido antes do titulo principal.
	cQuery   += " ORDER BY " + SqlOrder(SubStr(SE1->(IndexKey(1)),1,At("E1_TIPO",SE1->(IndexKey(1)))-2)+"+RECNO")
	
	If ExistBlock("F280CHQRY")
		cRetQuery := ExecBlock("F280CHQRY",.F.,.F.,{cQuery})
		If ValType(cRetQuery) == "C"
			cQuery := cRetQuery
		EndIf
	EndIf
Else
	//Rotina Automática
	IF (nT := ascan(aAutoCab,{|x| x[1]='AUTSELTIT'})) > 0 
		cQuery := F280EXEC(aStru,aAutoCab[nT,2])
	Else
		Return .F. /*Function fA280Aut*/
 	EndIf
EndIf

Aadd(aStru, {"RECNO","N",10,0})
//------------------
//Criação da tabela temporaria 
//------------------
If _oFina2801 <> Nil
	_oFina2801:Delete()
	_oFina2801 := Nil
Endif

_oFina2801 := FWTemporaryTable():New( cAliasSe1 )  
_oFina2801:SetFields(aStru) 	
_oFina2801:AddIndex("1", {"E1_FILIAL","E1_CLIENTE","E1_LOJA","E1_PREFIXO","E1_NUM","E1_PARCELA"}) 	
_oFina2801:Create()	

Processa({||SqlToTrb(cQuery, aStru, cAliasSe1)}) // Cria arquivo temporario
DbSetOrder(0) // Fica na ordem da query

DbSelectArea(cAliasSE1)
Set Filter to &(cFiltroAbat)
DbGoTop()

If BOF() .and. EOF()
	Help(" ",1,"RECNO")
	RetIndex("SE1")
	Set Filter to
	dbSetOrder(1)
	dbGoTop()
	DbSelectArea(cAliasSe1)
	DbCloseArea()

	//Deleta tabela temporária do banco de dados
	If _oFina2801 <> Nil
		_oFina2801:Delete()
		_oFina2801 := Nil
	Endif
	
	For nX := 1 TO Len(aTmpFil)
		CtbTmpErase(aTmpFil[nX])
	Next
		
	FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()
	Return
EndIF

nOpcA := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array com capos a serem mostrados na marcacao de titulos ³
//³ Utiliza os capos em uso do SE1 mais o E1_SALDO que apesar de   ³
//³ nao estar em uso deve ser mostrado na tela.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aCampos,{"E1_OK","","  ",""})
dbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(MsSeek(cAlias))
While SX3->(!EOF()) .And. (SX3->X3_ARQUIVO == cAlias)
	If (X3USO(SX3->X3_USADO) .Or. Alltrim(SX3->X3_CAMPO) $ "E1_SALDO#E1_FILIAL#E1_DESCONT") .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_CONTEXT != "V"
		AADD(aCampos,{SX3->X3_CAMPO,"",X3Titulo(),SX3->X3_PICTURE})
	Endif
	SX3->(dbSkip())
Enddo

dbSelectArea(cAliasSe1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia integracao com Modulo SIGAPCO                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoInilan("000014")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Marca os titulos ate o valor informado para a fatura 		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValor  := 0
nQtDTit := 0
If mv_par03 == 1 .and. !lAutomato .And. (Type("lF280Auto")<>"U" .and. !lF280Auto)
	Fa280Marca(cAliasSe1,cMarca,nValorFat,aChaveLbn)
Endif	

nValorF := nValorFat

oSize := FWDefSize():New(.T.)

oSize:AddObject("MASTER",100,100,.T.,.T.)
oSize:lLateral := .F.				
oSize:lProp := .T.

oSize:Process()

DEFINE MSDIALOG oDlg1 TITLE STR0021 PIXEL FROM oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
oTimer:= TTimer():New((nTimeOut-nTimeMsg),{|| MsgTimer(nTimeMsg,oDlg1) },oDlg1) // Ativa timer
oTimer:Activate()

nLinIni := oSize:GetDimension("MASTER","LININI")
nColIni := oSize:GetDimension("MASTER","COLINI")
nLinFin := oSize:GetDimension("MASTER","LINEND")
nColFin := oSize:GetDimension("MASTER","COLEND")

@ nLinIni + 001, 002  To nLinIni+035,nColFin	  PIXEL OF oDlg1

@ nLinIni + 008 , 005	SAY STR0051	+ cPrefix				FONT oDlg1:oFont PIXEL OF oDlg1					//"Prefixo: "
@ nLinIni + 017 , 005	SAY STR0022	+ cFatura				FONT oDlg1:oFont PIXEL OF oDlg1					//"N£mero: "
@ nLinIni + 008 , 080	SAY STR0023	+ Substr(cNat,1,10) 	FONT oDlg1:oFont PIXEL OF oDlg1					//"Natureza: "
@ nLinIni + 017 , 080	SAY STR0024	+ AllTrim(Str(nMoedFat,2,0))	FONT oDlg1:oFont PIXEL OF oDlg1		//"Moeda: "

@ nLinIni + 008 , 150	Say STR0025 FONT oDlg1:oFont PIXEL OF oDlg1		//"Valor Fatura"
@ nLinIni + 008 , 200	Say STR0026 FONT oDlg1:oFont PIXEL OF oDlg1		//"Valor Selecionado"
@ nLinIni + 008 , 250	Say STR0027 FONT oDlg1:oFont PIXEL OF oDlg1		//"T¡t. Selec."
If cPaisLoc<>"CHI"
	@ nLinIni + 017 , 150	Say oValorFat	VAR nValorF		Picture "@E 999,999,999.99" FONT oDlg1:oFont PIXEL OF oDlg1
	@ nLinIni + 017 , 200	Say oValor		VAR nValor		Picture "@E 999,999,999.99" FONT oDlg1:oFont PIXEL OF oDlg1
else
	@ nLinIni + 017 , 150	Say oValorFat	VAR nValorF		Picture "@E 99,999,999,999" FONT oDlg1:oFont PIXEL OF oDlg1
	@ nLinIni + 017 , 200	Say oValor		VAR nValor		Picture "@E 99,999,999,999" FONT oDlg1:oFont PIXEL OF oDlg1
endif
@ nLinIni + 017 , 250	Say oQtdTit 	VAR nQtdTit 	Picture "@E 999,999,999"  FONT oDlg1:oFont PIXEL OF oDlg1 

oMark :=MsSelect():New(cAliasSe1,"E1_OK","!E1_SALDO",aCampos,@lInverte,@cMarca,{nLinIni + 38, nColIni, nLinFin, nColFin})
oMark:bMark := {||Fa280Exibe(cAliasSe1,cMarca,oValor,oQtdTit,oMark,@nValor)}
oMark:bAval	:= {||Fa280bAval(cAliasSe1,cMarca,oValor,oQtdTit,oMark,@nValor,,,aChaveLbn)}
oMark:oBrowse:lhasMark := .t.
oMark:oBrowse:lCanAllmark := .t.
oMark:oBrowse:bAllMark := { || FA280Inverte(cAliasSe1,cMarca,oValor,oQtdTit,.T.,oMark,@nValor,,,,aChaveLbn)}
  

If ExistBlock("F280REC")
	aBut280 := ExecBlock( "F280REC",.F.,.F., {aBut280})
EndIf      
If !lAutomato .And. (Type("lF280Auto")<>"U" .and. !lF280Auto)
	If lPanelFin  //Chamado pelo Painel Financeiro			
		ACTIVATE MSDIALOG oDlg1 ON INIT FaMyBar(oDlg1,{|| nOpca := 1,;
		IIF(Fa280ValOK(),IF(Fa280Soma(),oDlg1:End(),;
		Iif(Fa280Val(oValorFat),nOpca:=0,nOpca:=0)),nOpca:=0)},;
									{|| nOpca := 2,oDlg1:End()},aBut280);
									VALID (oTimer:End(),.T.) CENTERED
	
	Else	
		ACTIVATE MSDIALOG oDlg1 ON INIT;
		EnchoiceBar(;
			oDlg1,;
			{ ||	nOpca := 1,;
					If(	Fa280ValOK( ) .and. FA280PEVQF( nQtdTit ),;  // Se o valor da fatura eh maior que zero e o PE FA280VQF
							If(	Fa280Soma( ),;  // Verifica se o valor da fatura eh o mesmo dos tit. marcados
									oDlg1:End( ),;
									If(	Fa280Val( oValorFat ),;  // Pede que se digite o valor correto da fatura
											nOpca := 0,;
											nOpca := 0;
									);
							),;
							nOpca := 0;
					);
			},;
			{ ||	nOpca := 2, oDlg1:End( ) };
			,;
			,;
			aBut280;
		);
		VALID ( oTimer:End(), .T. ) CENTERED
	Endif
ElseIf lAutomato
	If lGetAuto
		nRegAuto := (cAliasSe1)->(Recno())
		(cAliasSe1)->(dbGoTop())
		While (cAliasSe1)->(!Eof())
			For nI := 1 to Len (aRetAuto[14])
				If 	(cAliasSe1)->(E1_FILIAL) 	== Padr(aRetAuto[14,nI,1],Len(SE1->E1_FILIAL))	.AND. ;//FILIAL
					(cAliasSe1)->(E1_PREFIXO) 	== Padr(aRetAuto[14,nI,2],Len(SE1->E1_PREFIXO)) 	.AND. ;//Prefixo
   					(cAliasSe1)->(E1_NUM) 		== Padr(aRetAuto[14,nI,3],Len(SE1->E1_NUM)) 		.AND. ;//Numero
   					(cAliasSe1)->(E1_PARCELA) 	== Padr(aRetAuto[14,nI,4],Len(SE1->E1_PARCELA)) 	.AND. ;//Parcela
   					(cAliasSe1)->(E1_TIPO) 		== Padr(aRetAuto[14,nI,5],Len(SE1->E1_TIPO)) 		.AND. ;//Tipo
   					(cAliasSe1)->(E1_CLIENTE) 	== Padr(aRetAuto[14,nI,6],Len(SE1->E1_CLIENTE)) 	.AND. ;//Cliente
   					(cAliasSe1)->(E1_LOJA) 		== Padr(aRetAuto[14,nI,7],Len(SE1->E1_LOJA))				//loja]
  						
  						//efetua a Marcação dos títulos   		
							Fa280bAval(cAliasSe1,cMarca,oValor,oQtdTit,oMark,@nValor,,,aChaveLbn,,,lAutomato)
						nOpca := 1
				EndIf
			next nI
			(cAliasSe1)->(dbSkip())
		End
		
		(cAliasSe1)->(dbGoto(nRegAuto))
	Endif
ElseIf (Type("lF280Auto")<>"U" .and. lF280Auto) 	// Rotina Automática
	nRegAuto := (cAliasSe1)->(Recno())
	(cAliasSe1)->(dbGoTop())
	While (cAliasSe1)->(!Eof())
		//efetua a Marcação de todos títulos   		
		Fa280bAval(cAliasSe1,cMarca,oValor,oQtdTit,oMark,@nValor,,,aChaveLbn,,,lAutomato)
		(cAliasSe1)->(dbSkip())
		nOpca := 1
	EndDo
	(cAliasSe1)->(dbGoto(nRegAuto))
EndIf

dbSelectArea("SE1")

If nOpcA == 1	
	
	nOpcA:=0
	
	If ((ExistBlock("F280CON")))
		aRetF280CON :=	Execblock("F280CON",.f.,.f.,{nValor,cCondicao,cMarca,cAliasSe1,cCond})
		//-- Seleciona o último campo do array retornado para substituir o "cCondicao"
		If(ValType(aRetF280CON[Len(aRetF280CON)]) == Valtype(cCond))
			cCondicao := aRetF280CON[Len(aRetF280CON)]
			//-- Removendo ultimo campo do array.
			ASIZE(aRetF280CON, Len(aRetF280CON)-1)
		EndIf
		aVenc := aRetF280CON
		aSize := MsAdvSize(,.F.,400)          
		lF280CON := .T.
	Else
		lF280CON := .F.
	Endif		
	
	cOldTipo := cTipo
	
	oSize := FWDefSize():New(.T.)
	
	oSize:AddObject("MASTER",100,100,.T.,.T.)
	oSize:lLateral := .F.				
	oSize:lProp := .T.
	
	oSize:Process()
	
	DEFINE MSDIALOG oDlg2 TITLE STR0021 PIXEL FROM oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
	
	nLinIni := oSize:GetDimension("MASTER","LININI")
	nColIni := oSize:GetDimension("MASTER","COLINI")
	nLinFin := oSize:GetDimension("MASTER","LINEND")
	nColFin := oSize:GetDimension("MASTER","COLEND")

	@	nLinIni + 001,nColIni     TO nLinIni + 030,125		Pixel OF oDlg2 
	@	nLinIni + 001,nColIni+127 TO nLinIni + 030,nColFin	Pixel OF oDlg2 

	@	nLinIni + 005,015 	Say STR0050 Of oDlg2  Pixel   //"Condi‡„o: "
	
	If ! lF280CON
		@	nLinIni + 005,045	MSGET cCond F3 "SE4" Picture "!!!" Of oDlg2 Pixel Hasbutton Valid ExistCpo("SE4",cCond) .And. Fa290Cond(cCond)		
	Else			
		@ 	nLinIni + 005,015	Say STR0077 OF oDlg2 Pixel FONT oFnt COLOR CLR_HBLUE // "Pré Configurado"
	Endif																	  
		
	DEFINE SBUTTON FROM nLinIni + 005,085	TYPE 1 ACTION; 
		(If(lF280CON,;
			(nOpca:=F280SelFat(oDlg2,1,@cCond,@nValor,@nValTot,@aVenc,@cPrefix,@cFatura,@cTipo,dDatCont,oSize)),;		
					If(!Empty(cCond) .And. ExistCpo("SE4",cCond) .And. Fa290Cond(cCond),;
  					        nOpca:=F280SelFat(oDlg2,1,@cCond,@nValor,@nValTot,@aVenc,@cPrefix,@cFatura,@cTipo,dDatCont,oSize),;
		nOpca:=0))) ENABLE OF oDlg2
		
	If !lAutomato .And. (Type("lF280Auto")<>"U" .and. !lF280Auto)
		If lPanelFin  //Chamado pelo Painel Financeiro			
			ACTIVATE MSDIALOG oDlg2 ON INIT FaMyBar(oDlg2,;
					{||	nOpca := 0,If(lF280CON,(If(Len(aCols) > 0,nOpca := 1,nOpca := 0),oDlg2:End()),(If(!Empty( cCond ) .And. Len(aCols) > 0 .AND. ExistCpo( "SE4", cCond ) .AND. Fa290Cond( cCond ) .AND.	oGet:TudoOk(),(nOpca := 1, oDlg2:End()), nOpca := 0	)))},;
					{||	nOpca := 2, oDlg2:End()})
																													
		Else	
			ACTIVATE MSDIALOG oDlg2 ON INIT	EnchoiceBar(oDlg2,;
					{||	nOpca := 0,If(lF280CON,(If(Len(aCols) > 0 .And. oGet:TudoOk(),nOpca := 1,nOpca := 0),If(nOpca == 1,oDlg2:End(),.T.)),(If(!Empty( cCond ) .And. Len(aCols) > 0 .AND. ExistCpo( "SE4", cCond ) .AND. Fa290Cond( cCond ) .AND.	oGet:TudoOk(),(nOpca := 1, oDlg2:End()), nOpca := 0	)))},;
					{||	nOpca := 2, oDlg2:End()})
		Endif	
	ElseIf lAutomato
		cCond		:= aRetAuto[13]//Condição de pagamento para geração dos títulos
		F280SelFat(oDlg2,1,@cCond,@nValor,@nValTot,@aVenc,@cPrefix,@cFatura,@cTipo,dDatCont,oSize)
		nOpca := 1
	ElseIf (Type("lF280Auto")<>"U" .and. lF280Auto)	//Rotina Automática
		
		aValidGet := {}
		IF (nT := ascan(aAutoCab,{|x| x[1]='AUTCONDPG'})) > 0 
			cCond := aAutoCab[nT,2]
			Aadd(aValidGet,{'cCond' ,aAutoCab[nT,2],"ExistCpo('SE4',cCond) .And. Fa290Cond(cCond)",.t.})
		EndIf
		
		If ! SE1->(MsVldGAuto(aValidGet)) // consiste os gets
			Return .f. /*Function fA280Aut*/
		EndIf
		
		F280SelFat(oDlg2,1,@cCond,@nValor,@nValTot,@aVenc,@cPrefix,@cFatura,@cTipo,dDatCont,oSize)
		nOpca := 1		
	Endif
	   							  
Else
	nOpca := 2
EndIf
	
If nOpcA == 1
	#IFNDEF TOP
		RetIndex("SE1")
		If !Empty(cIndex)
			fErase(cIndex+OrdBagExt())
		Endif	
	#ENDIF
	If Fa280Num(@cFatAnt) // Se nao existir o mesmo numero de fatura
		Begin Transaction	
			nTotAbat :=0
			dbSelectArea("SE1")
			nRegE1 := Nil
			nFirstE1 := NIL  // Esta variavel será utilizada no PE FA280 (Fortymil)
			
			__aBaixados := {}
			__cNroFatur := cFatura
			For nW := 1 To Len(aMark)
				MsGoto(aMark[nW])
				cSE1Fil	:= SE1->E1_FILIAL
				cNumero		:=	SE1->E1_NUM
				cPrefixo	:=	SE1->E1_PREFIXO
				cParcela	:=	SE1->E1_PARCELA  
				cTitpai		:= SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA
				nRegE1		:=	aMark[nW]
				nFirstE1 := IIF(nFirstE1==Nil,aMark[nW],nFirstE1)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta a Fatura no SE1,                                   ³
				//³ Verifica e efetua a Baixa de Abatimentos,                ³
				//³ Efetua a Baixa do Titulo Principal e                     ³
				//³ Gera Movimentacao no SE5 das Baixa.                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet
					If Empty(SE1->E1_NATUREZ)
						lRet := .F.
						DisarmTransaction()
						Exit
					EndIf
				EndIf
				
				If lRet
					aAdd(__aBaixados, {cPrefixo, cNumero, cParcela, SE1->E1_TIPO })
					            
					dbSelectArea("SE1")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PcoDetLan("000014","02","FINA280")
					
					If Empty(cPerLet)
						cPerLet := SE1->E1_PERLET
					EndIf
					
					If Empty(cProduto)
						cProduto := SE1->E1_PRODUTO
					EndIf
	
					If FWHasEAI('FINA280',.T.,,.T.)
						cBancoCtr	:= SE1->E1_PORTADO
						cAgencia 	:= SE1->E1_AGEDEP
						cConta 		:= SE1->E1_CONTA
						cContrato 	:= SE1->E1_CONTRAT
					EndIf				
				EndIf
			Next

			If lRet
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Confirma a contabilizacao da baixa dos titulos quando nao existe LP de contabilizacao da fatura ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( nTotal > 0 ) .And. ( nHdlPrv > 0 ) .And. !lPadrao .And. ( mv_par04 == 1 )  .And. VerPadrao( "520" )

					//-- Se for rotina automatica força exibir mensagens na tela, pois mesmo quando não exibe os lançametnos, a tela 
					//-- sera exibida caso ocorram erros nos lançamentos padronizados
					If (Type("lF280Auto")<>"U" .and. lF280Auto)
						lSetAuto := _SetAutoMode(.F.)
						lSetHelp := HelpInDark(.F.)
						If Type('lMSHelpAuto') == 'L'
							lMSHelpAuto := !lMSHelpAuto
						EndIf						
					EndIf
				
					lDigita := IIF( mv_par02==1 .And. !lAutomato .And. !lF280Auto,.T.,.F.)			

					RodaProva( nHdlPrv, nTotal )
					CA100Incl( cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, lDigita,;
		           			.F. /*lAglut*/, /*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB,;
		           			/*aDadosProva*/, /*aDiario*/ )
					aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
					nTotal   := 0
					nHdlPrv  := 0
					cArquivo := Nil
					
					If (Type("lF280Auto")<>"U" .and. lF280Auto)
						HelpInDark(lSetHelp)
						_SetAutoMode(lSetAuto)
						If Type('lMSHelpAuto') == 'L'
							lMSHelpAuto := !lMSHelpAuto
						EndIf
					EndIf
					
				EndIf
	
				//Ponto de entrada
				If lF280SE5
					aRecSE5	:= aClone(aAuxSE5)
					ExecBlock("F280SE5",.F.,.F.,{aRecSe5})
					aAuxSE5 := {}
				Endif
	
				nValTotal := 0
	
				//PCC Baixa CR
				//Necessario somar o total da fatura antes da geracao da fatura
				//para proporcionalizar o valor do PCC
				If lPccBxCR .or. lBaseImp .or. lIrPjBxCr
					For nW:=1 To Len(aCols)
						If ! aCols[nW,Len(aHeader)+1] // .F. == Ativo  .T. == Deletado				
							nTotFatura += xMoeda(aCols[nW,6],nMoedFat,1)
						Endif
					Next						
				Endif	
				
				aISSDup := Condicao(nVlrISS,cCondicao,0)
				__aNovosTit := {}
				For nW:=1 To Len(aCols)
					If ! aCols[nW,Len(aHeader)+1] // .F. == Ativo  .T. == Deletado				
						cPrefix		:= aCols[nW][1]
						cParcela	:= aCols[nW][3]
						cTipo		:= aCols[nW][4]
						cVencmto	:= aCols[nW][5]
						nValDup		:= aCols[nW][6]
						nValCruz	:= xMoeda(aCols[nW,6],nMoedFat,1)
						cBanco		:= aCols[nW][7]
				
						//Gera fatura atraves da rotina automatica do Fina040 para que faca o recalculo 
						//e gere os abatimentos referente ao valor total titulos que serao selecionados;
						nLen		:= Len(aCols)            
	
						//PCC Baixa CR
						//Tratamento da proporcionalizacao dos impostos PCC
						//para posterior gravacao na parcela gerada
						If lPccBxCR .or. lBaseImp
							nPropPcc	:= nValCruz / nTotFatura
							nPis		:= Round(NoRound(aPccBxCr[1] * nPropPcc,3),2)
							nCofins		:= Round(NoRound(aPccBxCr[2] * nPropPcc,3),2)						
							nCsll		:= Round(NoRound(aPccBxCr[3] * nPropPcc,3),2)
							nBaseImp	:= Round(NoRound(aPccBxCr[4] * nPropPcc,3),2)
							nTotPis		+= nPis
							nTotCofins	+= nCofins
							nTotCsll	+= nCsll
							nTotBase	+= nBaseImp
							 						
							//Acerto de eventuais problemas de arredondamento
							If aPccBxCr[1] - nTotPis <= 0.01
								nPis		+= aPccBxCr[1] - nTotPis
							Endif
	
							If aPccBxCr[2] - nTotCofins <= 0.01
								nCofins	+= aPccBxCr[2] - nTotCofins
							Endif
	
							If aPccBxCr[3] - nTotCsll <= 0.01
								nCSll		+= aPccBxCr[3] - nTotCsll
							Endif
	
							If aPccBxCr[4] - nTotBase <= 0.01
								nBaseImp	+= aPccBxCr[4] - nTotBase
							Endif
						Endif						
						
						//IR Baixa CR
						//Tratamento da proporcionalizacao dos impostos IR
						//para posterior gravacao na parcela gerada
						If lIrPjBxCr .or. lBaseImp
							nPropIr		:= nValCruz / nTotFatura
							nIrrf		:= Round(NoRound(aDadosIR[1] * nPropIr,3),2)
							nBaseImp	:= Round(NoRound(aDadosIR[2] * nPropIr,3),2)
							nTotIr		+= nIrrf
							nTotBaseIr	+= nBaseImp
							 						
							//Acerto de eventuais problemas de arredondamento
							If aDadosIR[1] - nTotIr <= 0.01
								nIrrf		+= aDadosIR[1] - nTotIr
							Endif      
							If aDadosIR[2] - nTotIr  <= 0.01
								nBaseImp	+= aDadosIR[2] - nTotIr
							Endif
						Endif
	
						dbGoto(aMark[1])
						
						IncProc("Incluindo a fatura...")
						If ! GdDeleted(nW) // .F. == Ativo  .T. == Deletado
							dbSelectArea("SA1")
							If Empty( cCliFat )
								MsSeek(xFilial("SA1")+cCli+cLoja)
							Else
								MsSeek(xFilial("SA1")+cCliFat+cLojaFat)
							Endif
							aTit := {}
							AADD(aTit , {"E1_FILIAL"	, xFilial("SE1")									, NIL})						
							AADD(aTit , {"E1_PREFIXO"	, cPrefix											, NIL})
							AADD(aTit , {"E1_NUM"    	, cFatura											, NIL})
							AADD(aTit , {"E1_PARCELA"	, cParcela											, NIL})
							AADD(aTit , {"E1_TIPO"   	, cTipo												, NIL})
							AADD(aTit , {"E1_NATUREZ"	, cNat												, NIL})
							AADD(aTit , {"E1_SITUACA"	, "0"												, NIL})
							AADD(aTit , {"E1_VENCTO" 	, cVencmto											, NIL})
							AADD(aTit , {"E1_VENCREA"	, DataValida(cVencmto,.T.)							, NIL})
							AADD(aTit , {"E1_VENCORI"	, DataValida(cVencmto,.T.)							, NIL})
							AADD(aTit , {"E1_EMISSAO"	, dDataBase											, NIL})
							AADD(aTit , {"E1_EMIS1"		, dDataBase											, NIL})
							AADD(aTit , {"E1_CLIENTE"	, IIF( Empty( cCliFat ), cCli, cCliFat )			, NIL})
							AADD(aTit , {"E1_LOJA"   	, IIF( Empty(cCliFat),cLoja,cLojaFat )				, NIL})
							AADD(aTit , {"E1_NOMCLI" 	, SA1->A1_NREDUZ									, NIL})
							AADD(aTit , {"E1_MOEDA"  	, nMoedFat											, NIL})
							AADD(aTit , {"E1_VALOR"  	, nValDup											, NIL})
							AADD(aTit , {"E1_SALDO"  	, nValDup											, NIL})
							AADD(aTit , {"E1_VLCRUZ" 	, xMoeda(nValDup,nMoedFat,1)						, NIL})
							AADD(aTit , {"E1_STATUS" 	, "A"												, NIL})
							AADD(aTit , {"E1_OCORREN"	, "01"												, NIL})
							AADD(aTit , {"E1_ORIGEM"	, "FINA280"											, NIL})
							AADD(aTit , {"E1_FATURA"	, "NOTFAT"											, NIL})
							AADD(aTit , {"E1_CREDIT"	,  SE1->E1_CREDIT									, NIL})
							AADD(aTit , {"E1_DEBITO"	,  SE1->E1_DEBITO									, NIL})
							AADD(aTit , {"E1_CCC"		,  SE1->E1_CCC										, NIL})
							AADD(aTit , {"E1_ITEMC"		,  SE1->E1_ITEMC									, NIL}) 
							AADD(aTit , {"E1_CLVLCR"	,  SE1->E1_CLVLCR									, NIL})
							AADD(aTit , {"E1_CCD"		,  SE1->E1_CCD										, NIL})
							AADD(aTit , {"E1_ITEMD"		,  SE1->E1_ITEMD									, NIL}) 
							AADD(aTit , {"E1_CLVLDB"	,  SE1->E1_CLVLDB									, NIL})
	
							If cPaisLoc == "BRA"
								If cFilMsg == "1" 
									AADD(aTit , {"E1_IDLAN"	,  2												, NIL})
								EndIF
							EndIf
								
							// Se o vendedor nao estiver bloqueado, inclui nos titulos de fatura gerados
							If !F280BlqVen().and. !SA3->A3_ALEMISS = 100
								AADD( aTit , {"E1_VEND1", SE1->E1_VEND1									, NIL})
								AADD( aTit , {"E1_VEND2",  SE1->E1_VEND2								, NIL})
								AADD( aTit , {"E1_VEND3",  SE1->E1_VEND3								, NIL})
								AADD( aTit , {"E1_VEND4",  SE1->E1_VEND4								, NIL})
								AADD( aTit , {"E1_VEND5",  SE1->E1_VEND5								, NIL})
								
								AADD( aTit , {"E1_COMIS1", SE1->E1_COMIS1								, NIL})
								AADD( aTit , {"E1_COMIS2", SE1->E1_COMIS2								, NIL})
								AADD( aTit , {"E1_COMIS3", SE1->E1_COMIS3								, NIL})
								AADD( aTit , {"E1_COMIS4", SE1->E1_COMIS4								, NIL})
								AADD( aTit , {"E1_COMIS5", SE1->E1_COMIS5								, NIL})
							EndIf	
	
							If !lSE1Compart .and. mv_par06 == 1
								AADD(aTit , {"E1_ORIGEM" , "FINA280M"											, NIL})
							Else
								AADD(aTit , {"E1_ORIGEM" , "FINA280"											, NIL})    						
							Endif
	
							If lPccBxCr
								If "PIS" $ cPccBxCr .and. nPis > 0
									AADD(aTit , {"E1_PIS"   ,  nPis		, NIL})
								Endif
								If "COF" $ cPccBxCr .and. nCofins > 0							
									AADD(aTit , {"E1_COFINS",  nCofins	, NIL}) 
								Endif
								If "CSL" $ cPccBxCr .and. nCsll > 0
									AADD(aTit , {"E1_CSLL"  ,  nCsll		, NIL})
								Endif
							Endif						
	  						 If lIrPjBxCr
								If "IRRF" $ cIrBxCr .and. nIrrf > 0
									AADD(aTit , {"E1_IRRF"   ,  nIrrf		, NIL})
								Endif
							Endif						
	
							//639.04 Base Impostos diferenciada
							If (lBaseImp .and. nPis+nCofins+nCsll > 0)  .or. lIrPjBxCr
								AADD(aTit , {"E1_BASEIRF"  ,  nBaseImp 	, NIL})
							Endif
	
						
							If lRmClass 
								AADD(aTit , {"E1_NUMRA" , SE1->E1_NUMRA								    	, NIL})
								AADD(aTit , {"E1_TURMA" , SE1->E1_TURMA								    , NIL})
							endif
														
							//Ponto de entrada para adicionar mais campos antes da geração das novas faturas.
							If lA280GERF							
								ExecBlock("A280GERF",.F.,.F.,{cPrefix,cFatura,cParcela,cTipo,DTOC(cVencmto),nW})
							EndIf
	
							// TRATAMENTO PARA NÃO GERAR ISS INCORRETAMENTE 
							If ( Alltrim(SE1->E1_ORIGEM) == "MATA460" )
								If !Empty(aISSDup) .and. ValType(aISSDup) == "A" 
									If (Len(aISSDup) >= nW) .AND. ValType(aISSDup[nW]) == "A" 
										If (Len(aISSDup[nW]) >= 2) .AND. !Empty(aISSDup[nW][2]) .AND. ValType(aISSDup[nW][2]) == "N"
											AADD( aTit , { "E1_ISS" , aISSDup[nW][2] , NIL } )
										EndIf
									EndIf
								EndIf
							Endif
							
							If !Empty(cPerLet) .And. !Empty(cProduto)
								aAdd(aTit, {'E1_PERLET',cPerLet,Nil})
								aAdd(aTit, {'E1_PRODUTO',cProduto,Nil})
							EndIf
	
							If FwHasEai('FINA280',.T.,,.T.)
								aAdd(aTit,{'E1_PORTADO'	,cBancoCtr	, Nil})
								aAdd(aTit,{'E1_AGEDEP'	,cAgencia	, Nil})
								aAdd(aTit,{'E1_CONTA'	,cConta		, Nil})
								aAdd(aTit,{'E1_CONTRAT'	,cContrato	, Nil})						
							EndIf
							
							MSExecAuto({|x, y| FINA040(x, y)}, aTit, 3)
	
	      
							//Verifica se a gravacao ocorreu normalmente, e possibilita o uso do PE FA280
							//para complementar a gravacao.
							If  lMsErroAuto
							    MOSTRAERRO() 
							    DisarmTransaction()
							Else
								If lFA280_
									ExecBlock("FA280",.f.,.f.,nRegE1)
								Endif
								
								IF lPadrao
									If nHdlPrv <= 0
										nHdlPrv:=HeadProva(cLote,"FINA280",Substr(cUsuario,7,6),@cArquivo)
										lHead := .T.
									Endif
	
									If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
										aAdd( aFlagCTB, {"E1_LA", "S", "SE1", SE1->( Recno() ), 0, 0, 0} )
									Else
										RecLock("SE1")
										SE1->E1_LA := "S"
										MsUnlock()
									Endif
									nTotal += DetProva( nHdlPrv, cPadrao, "FINA280", cLote, /*nLinha*/, /*lExecuta*/,;
									                    /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
									                    /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
								Endif
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								PcoDetLan("000014","01","FINA280")
	
								//Rastreamento - Gerados
								If lRastro
									aadd(aRastroDes,{	SE1->E1_FILIAL,;
															SE1->E1_PREFIXO,;
															SE1->E1_NUM,;
															SE1->E1_PARCELA,;
															SE1->E1_TIPO,;
															SE1->E1_CLIENTE,;
															SE1->E1_LOJA,;
															SE1->E1_VALOR } )
								Endif			
	
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Adiciona o titulo na aTitInc - Int. Protheus x Classis³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aAdd(aTitInc,SE1->(Recno()))
								
							EndIf
							dbSelectArea("SE1")
						Endif
	
						nValTotal += xMoeda(nValDup,nMoedFat,1)  // nValCruz
						dbSelectArea("SE1")
					Endif
					
					aAdd( __aNovosTit, {aTit[2][2], aTit[3][2], aTit[4][2], aTit[5][2]} )
				Next nW
				If ( nTotal > 0 ) .and. lPadrao
					FA280ConFa( nValTotal, cPadrao, cArquivo, nHdlPrv, @nTotal, "FINA280", @aFlagCTB )
				Endif
	
				//Gravacao do rastreamento
				If lRastro
					FINRSTGRV(2,"SE1",aRastroOri,aRastroDes,nValProces) 
				Endif
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava no SX6 o numero da ultima fatura gerada. 						  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PutMV("MV_NUMFAT",cFatura)
			EndIf

		End Transaction
		If lRet
			If ExistBlock("FA280GRV")
				ExecBlock("FA280GRV",.F.,.F.)
			Endif
	
			//Integração via Mensagem Única
			__cNroFatur := cFatura
			If cFilMsg == "1" .And. FWHasEAI('FINA280',.T.,,.T.)	
				FWIntegDef('FINA280')
			EndIf
		EndIf
	Endif
Endif


If lRet
	If !Empty(aChaveLbn)
		For iX := 1 to Len(aMark)
			se1->(msRUnlock(aMark[iX]))
		Next
	Endif
	
	cFatura		:= CriaVar("E1_NUM")
	cCli		:= Space(6)
	cNat		:= Space(10)
	cPrefix		:= Space(3)
	cLoja 		:= Space(2)
	dDataDe		:= dDatabase
	dDataAte	:= dDataBase
	nValorF		:= 0
	nValorFat	:= 0
	nValCruz 	:= 0
	nVarURV		:= 0
	nVlrAtu 	:= 0
	aVlCruz		:= {}
	
	DbSelectArea(cAliasSe1)
	DbCloseArea()
	
	//Deleta tabela temporária do banco de dados
	If _oFina2801 <> Nil
		_oFina2801:Delete()
		_oFina2801 := Nil
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recupera a Integridade dos dados							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()
	
	For nX := 1 TO Len(aTmpFil)
		CtbTmpErase(aTmpFil[nX])
	Next
	
	dbSelectArea("SE1")
	Set Filter to
	dbSetOrder( 1 )
	dbSeek(xFilial())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza integracao com Modulo PCO                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoFinLan("000014")
EndIf

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ fa280num ³ Autor ³ Paulo Boschetti		³ Data ³ 27/07/93   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se ja  existe numero do titulo.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa280num()												              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280													              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FuncTion fa280num(cFatAnterior)
Local lRet:=.T.
Local aArea 	:= GetArea()
Local aAreaSe1	:= SE1->(GetArea())
Local lF280VlFat := .F.

dbSelectArea("SE1")
dbSetOrder(1)
If dbSeek(xFilial("SE1")+cPrefix+cFatura)
	While !Eof() .and.SE1->E1_FILIAL == xFilial("SE1") .and. ;
		cPrefix+cFatura == SE1->(E1_PREFIXO+E1_NUM)
		If E1_TIPO == cTipo
			Help(" ",1,"A280EXIST")
			lRet:=.F.
			Exit
		Else
			dbSkip()
		Endif
	Enddo
Else
	If cFatura <> cFatAnterior
		FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()	aqui
	Endif	
	If	!MayIUseCode( "SE1"+xFilial("SE1")+cFatura)
		lRet:=.F.
	Endif	
Endif

If ExistBlock("F280VLFAT")
	lF280VlFat := ExecBlock("F280VLFAT",.F.,.F.,{cFatura})
	If ValType(lF280VlFat) == "L"
		lRet := lF280VlFat
	EndIf
EndIf

SE1->(RestArea(aAreaSe1))
RestArea(aArea)
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ fa280nat ³ Autor ³ Paulo Boschetti		³ Data ³ 27/07/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica validade da natureza.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa280nat()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FA280NAT(cNatAux)   
Local cAlias	 := Alias()
Local lRet		 := .T.    
Local lFIN280NAT := ExistBlock("FIN280NAT")
Local lValidBloq := SED->(FieldPos("ED_MSBLQL")) > 0

Default cNatAux  := ""

If Type("cNat") == "C"
	cNatAux := cNat
EndIf	  

dbSelectArea("SED")
IF !dbSeek(cFilial+cNatAux)
	Help(" ",1,"A280NAT")
	lRet:=.F.
Endif                  

If lRet .And. lValidBloq
	If SED->ED_MSBLQL == "1"
		Help(" ",1,"EDBLOCKED",,STR0076,1,0)	 //"Natureza bloqueada para novas movimentações"
		lRet := .F.
	Endif
EndIf

//294 - Natureza sintetica/Analitica
If lRet .and. !FinVldNat( .F., cNatAux, 1 )
	lRet := .F.
Endif

If lRet .And. lFIN280NAT
	lRet := ExecBlock("FIN280NAT")
Endif

dbSelectArea(cAlias)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o     ³ fa280Cli ³ Autor ³ Paulo Boschetti       ³ Data ³ 27/07/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o  ³ Verifica validade do Cliente                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ fa280Cli()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ FINA280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fa280Cli(cCli280,cLoja280,dVencFat,nMaxFat,nQtdCtrc,lTms)
Local cAlias:=Alias()
Local nOldRec
Local aPerfil
Local aCondPagto := {}

DEFAULT lTms := .F.

cLoja280:=Iif(cLoja280 == Nil,"",cLoja280)

If Empty(cCli280)
	Return .F.                                        	
Endif

dbSelectArea("SA1")
dbSetOrder(1)
nOldRec := Recno()

IF !(MsSeek(xFilial("SA1")+cCli280+cLoja280))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nÆo encontrou o registro, retorna para o registro salvo pois, se a busca ³
	//³ estiver ocorrendo para o cliente a faturar e nÆo for encontrado, o SA1 fi - ³
	//³ car  desposicionado.																												³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbGoTo(nOldRec)
	Help(" ",1,"A280CLI")
	Return .F.
Endif

If lTms
	//-- Verifica se devera ser considerado a loja do cliente
	If ReadVar() == "_CLOJA" .Or. ReadVar() == "CCLI" .Or. l850Auto
		// Calcula a data de vencto da fatura
		If Empty(dVencFat)
			aCondPagto := Condicao(1,SA1->A1_COND,0)
			If Len(aCondPagto) > 0 .And. ValType(aCondPagto[1][1]) == 'D'
				dVencFat := DataValida(aCondPagto[1][1],.T.)
			Else
				dVencFat := CriaVar('E1_VENCTO',.F.)
			EndIf
		EndIf
		If MV_PAR01 == 2
			aPerfil 	:= TmsPerfil(SA1->A1_COD,_cLoja)
		Else
			aPerfil 	:= TmsPerfil(SA1->A1_COD,SA1->A1_LOJA)
		EndIf
		
		If Len(aPerfil) > 0
			nMaxFat	:= If(Empty(nMaxFat), aPerfil[10], nMaxFat) // Valor maximo da fatura
			nQtdCtrc	:= If(Empty(nQtdCtrc), aPerfil[11], nQtdCtrc) // Qtde.CTRC por fatura
		Else
			nMaxFat := If(Empty(nMaxFat), 0, nMaxFat)
			nQtdCtrc := If(Empty(nQtdCtrc), 0, nQtdCtrc)
		Endif	
	EndIf
Endif

dbSelectArea(cAlias)

Return .T.


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ GravaDp	³ Autor ³ Paulo Boschetti		³ Data ³ 12/11/93   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Formata Array com os desdobramentos dos titulos 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fina280										  			              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GravaDp(nDup,cPrefixo,cNumero,nValor,dVencto,aVenc,cTipo,cPrograma)

LOCAL nValorTit := iif(cpaisLoc=="CHI",round((nValor/nDup),0),noround((nValor/nDup)))
LOCAL nValDup	:= nValor
Local nTamParcela := TamSx3("E1_PARCELA")[1]
Local cParcela := Padr(nTamParcela,nTamParcela)
Local cTmpParcela := Padr(nTamParcela,nTamParcela)
Local nPosPrefixo
Local nPosNum
Local nPosParcela
Local nPosTipo
Local nPosValor
Local nPosVenc
Local nPosReserv
Local nI := 0
Local nMaxParc := 1
Local i := 1
Local cParcSE1 := SuperGetMv("MV_1DUP")  
Local lFa280aHead := ExistBlock("FA280AHEAD") .And. FunName() $ "FINA280|FINA740"
Local nIaHead

DEFAULT cPrograma := "FINA280"

aHeader := {}
aCols := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da matriz aHeader																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aHeader,{ STR0032 ,"E1_PREFIXO" ,"@!" 	  ,TamSx3("E1_PREFIXO")[1]+2,0,"","û","C","SE1" } ) //"Prf"
If cPrograma = "FINA280" // No fina281 o numero da fatura nao eh exibido
	AADD(aHeader,{ STR0033 ,"E1_NUM"     ,"@!"     ,TamSx3("E1_NUM")[1],0,"","û","C","SE1" } ) //"N£mero"
Endif	
AADD(aHeader,{ STR0034 ,"E1_PARCELA" ,PesqPict("SE1","E1_PARCELA"),TamSx3("E1_PARCELA")[1],0,"","û","C","SE1" } ) //"Ord"
AADD(aHeader,{ STR0054 ,"E1_TIPO"		,"@!"		  ,TamSx3("E1_TIPO")[1],0,"","û","C","SE1" } ) //"Tipo"
AADD(aHeader,{ STR0035 ,"E1_DTFATUR" ,"99/99/99",8  ,0,"fa280data()","û","D","SE1" } ) //"Vencimento"
if cPaisLoc<>"CHI"
	AADD(aHeader,{ STR0036 ,"E1_VLCRUZ"   ,"@E 9,999,999,999.99",14,2,"Fa280AtuVl(.T.)","û","N","SE1"}) //"Valor Duplicata"
else
	AADD(aHeader,{ STR0036 ,"E1_VLCRUZ"   ,"@E 999,999,999,999",14,0,"Fa280AtuVl(.T.)","û","N","SE1"}) //"Valor Duplicata"
endif
AADD(aHeader,{ STR0037 ,"A6_COD"     ,"@!"      ,15,0,"","û","C","SA6" }) //"Banco"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para Adicionar/Alterar aHeader		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lFa280aHead
	ExecBlock("FA280AHEAD",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava aCols com os valores das duplicatas			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCOLS[nDup][If(cPrograma!="FINA281",Len(aHeader)+1,8)]

// Varifica o tamnho da parcela
If nDup > 1
	//Verifica a validade do parametro
	If Len(GetMV("mv_1dup")) >= 1
		cTmpParcela := Substr(GetMV("mv_1dup"),Len(GetMV("mv_1dup"))+1-nTamParcela,nTamParcela)
	Else
		IW_MSGBOX(STR0072 + Str(nMaxParc,2) + CHR(13)+ ;  //"Número máximo de parcelas permitido "
					 STR0073 + Str(nDup,4) + CHR(13)+; //"Número de parcelas da condição de pagto. "
					 STR0074, STR0044,"STOP") //"Verifique parâmetro MV_1DUP."###"Atenção"		
		Return {}
	EndIf
	// Se parcela tiver apenas um digito, ou o parametro tiver apenas um digito, verifica a quantidade maxima de parcelas
	If nTamParcela == 1 .Or. Len(AllTrim(GetMV("mv_1dup"))) == 1
		// Verifica a quantidade maxima de parcelas
		cParcela := cTmpParcela
		For i := 1 To 63
			cParcela:=Soma1( cParcela,, .T. )
			If AllTrim(cParcela) == "*"
				Exit
			Endif
		   nMaxParc++
		Next
		If nDup > nMaxParc
			IW_MSGBOX(STR0072 + Str(nMaxParc,2) + CHR(13)+ ;  //"Número máximo de parcelas permitido "
						 STR0073 + Str(nDup,4) + CHR(13)+; //"Número de parcelas da condição de pagto. "
						 STR0074, STR0044,"STOP") //"Verifique parâmetro MV_1DUP."###"Atenção"
			Return {}
		Endif
	Endif
EndIf
nPosPrefixo	:= Ascan(aHeader, {|e| Alltrim(e[2]) = "E1_PREFIXO"} )
nPosNum		:= Ascan(aHeader, {|e| Alltrim(e[2]) = "E1_NUM"} )
nPosParcela	:= Ascan(aHeader, {|e| Alltrim(e[2]) = "E1_PARCELA"} )
nPosTipo	:= Ascan(aHeader, {|e| Alltrim(e[2]) = "E1_TIPO"} )
nPosValor	:= Ascan(aHeader, {|e| Alltrim(e[2]) = "E1_VLCRUZ"} )
nPosVenc	:= Ascan(aHeader, {|e| Alltrim(e[2]) = "E1_DTFATUR"} )
nPosReserv	:= Ascan(aHeader, {|e| Alltrim(e[2]) = "A6_COD"} )

FOR nI:=1 TO Len(aCols)
	nValorTit	:= aVenc[ni][2]
	cParcSE1 := Right("000"+cParcSE1,nTamParcela)		
	aCols[ni][nPosPrefixo]	:= cPrefixo
	If nPosNum > 0
		aCols[ni][nPosNum]	:= cNumero
	Endif	

	if lRmClass
		aCols[ni][nPosParcela]	:= alltrim(str(nI))
	else
		aCols[ni][nPosParcela]	:= cParcSE1
	endif
	
	aCols[ni][nPosTipo]		:= cTipo
	aCols[ni][nPosVenc]		:= aVenc[ni][1]
	aCols[ni][nPosValor]		:= IIf(nI<nDup,nValorTit,nValDup)
	aCols[ni][nPosReserv]	:= Space(15)
	
	If lFa280aHead	   
	   For nIaHead := 8 to Len(aCols[ni])-1
	   	   aCols[ni][nIaHead]	:= Space(aHeader[nIaHead][4])
	   Next	
	Endif   		
	
	aCols[ni][Len(aCols[1])]:= .F.
	cParcSE1 := Soma1(cParcSE1,nTamParcela,.F.)
	nValDup-=nValortit
NEXT
Return(aCols)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa280ChecF³ Autor ³ Valter G. Nogueira Jr.³ Data ³ 14/03/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sele‡„o para a cria‡„o do indice condicional 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fina280													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa280ChecF(cPrograma,cImpostos)
LOCAL cFiltro 		:= ""
LOCAL cFiltroAdd	:= ""
Local cFilDeb		:= SuperGetMv("MV_FATFIL",,"")
//Situacao de cobranca
Local cLstCart	:= FN022LSTCB(1,"0005")	//Lista das situacoes de cobranca - CARTEIRA


Default cPrograma := "FINA280"
Default cImpostos := Fa280VerImp(cNat)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ATENCAO !!!!                                               ³
//³ N„o adiconar mais nada a chave do filtro pois a mesma est  ³
//³ com 254 caracteres. Nao trocar os <> por !$ pois no SQL    ³
//³ o processamento fica uma carro‡a.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPrograma = "FINA281"
	If !Empty(cFilDeb)
		cFiltro += 'E1_FILIAL$"'	+ cFilDeb						+ '".And.'
	Else
		cFiltro += 'E1_FILIAL="'	+ xFilial("SE1")         	+ '".And.'	
	Endif	
Else
	cFiltro += 'E1_FILIAL="'	+ xFilial("SE1")         	+ '".And.'
Endif	
cFiltro += 'E1_MOEDA='  + AllTrim(Str(nMoedFat,2,0)) + '.And.'
cFiltro += 'E1_CLIENTE=="'+ cCli                       + '".And.'
IF mv_par01==1
	cFiltro += 'E1_LOJA=="'+cLoja+'".And.'
EndIf
cFiltro += 'DTOS(E1_EMISSAO)>="' +DTOS(dDataDe)        + '".And.'
cFiltro += 'DTOS(E1_EMISSAO)<="' +DTOS(dDataAte)       + '".And.'
cFiltro += 'E1_SITUACA $ "'+cLstCart+'".And.'		//sitcob
cFiltro += 'E1_SALDO>0.And.'
IF cPaisLoc<>"CHI"
	cFiltro += '!(E1_TIPO$"'+MVRECANT+"/"+MVPROVIS+'").And.'
	cFiltro += '!(E1_TIPO$"'+cImpostos+'").And.'
	cFiltro += 'E1_FATURA=="' +Space(Len(E1_FATURA)) +'"'
Else
	cFiltro += 'E1_TIPO$"'+MVRECANT+"/"+MVPROVIS+'")'
Endif
// Verifica integracao com PMS e nao permite FATURAR titulos que tenham solicitacoes
// de transferencias em aberto.
cFiltro += ' .And. Empty(E1_NUMSOL)'
//Template GEM - nao podem ser faturados os titulos do GEM
If HasTemplate("LOT")
	cFiltro += ' .And. Empty(E1_NCONTR)'
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Acrescentado Ponto de Entrada p/ Comollati - Vers„o SQL    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("FA280FIL")
	cFiltroADD := ExecBlock("FA280FIL",.F.,.F.,cFiltro)
	If !Empty(cFiltroAdd)
		cFiltro := cFiltroAdd
	Endif
Endif

Return cFiltro

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FA280CAN   ³ Autor ³ Cesar C S Prado		  ³ Data ³ 27/04/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancelamento de fatura										³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA280CAN()													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 													³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FA280CAN(cAlias,cCampo,nOpcE, lAutomato,lFina460)

Local lPanelFin 	:= IsPanelFin()
LOCAL cArquivo
LOCAL nTotal		:= 0
LOCAL nHdlPrv		:= 0
LOCAL nTitulos		:= 0
LOCAL nFaturas		:= 0
Local lPadrao527 	:= (mv_par05 == 1 .and. VerPadrao("527"))
LOCAL lPadrao
LOCAL cPadrao 		:= "592"
LOCAL oDlg
LOCAL nOpca 		:= 0
LOCAL nValor		:= 0
LOCAL cNewFat		:= " "
LOCAL l280CalCn 	:= .F.
LOCAL cChaveSe1 	:= ""
Local lHead 		:= .F.
Local nValTotal 	:= 0
Local nRecSe1		:= 0
Local aAreaSa1		:= SA1->(GetArea())
Local lRet 			:= .T.
Local lAcreDecre 	:= .F.
Local nAcresc 		:= 0
Local nDecresc 		:= 0
Local dBaixa 		:= CTOD("//")
Local nAbatim 		:= 0  
Local cChave  		:= ""
Local aArea			:= {}
Local aRecDel 		:= {}
Local aFlagCTB 		:= {}
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 
Local lRastro		:= FVerRstFin()
Local lAtuSldNat  	:= .T.
Local cMVJurTipo	:= SuperGetMV("MV_JURTIPO",,"")   //Indicativo do tipo de Calculo de Juros
Local lLojxRMul     := .T.    //Funcao que calcula o Juros e Multas do Loja 
Local lMvLjIntFS	:= SuperGetMv("MV_LJINTFS", , .F.)	
Local cChaveTit		:= ""
Local cChaveFK7		:= ""		
Local aAlt 			:= {} 
Local aAreaATU		:= {}
Local aMultSEV		:= {}
Local lMultNat		:= .F.
Local lDigita		:= .F.

//Controle de abatimento
Local lTitpaiSE1 	:= .T.
Local nOrdTitPai	:= 0
Local bWhile 		:= {||  __SE1->(!Eof()) .and. cTitAnt == __SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)}
Local cTitpai		:= ""
Local nTamTitPai  	:= 0
/*
 * Variáveis Necessárias para Gravação dos Movimentos Bancários
 */
Local aAreaAnt	:= {}
Local oModelMov	:= Nil
Local cLog		:= ""
Local cFilFK1	:= FWxFilial("FK1")
Local oSubFK1	:= Nil
Local aValOrig	:= {} 
Local lExistFJU := FJU->(ColumnPos("FJU_RECPAI")) >0 .and. FindFunction("FinGrvEx")
Local aTitPai 	:= {}
Local nI		:= 0
Local nX        := 0

Local bWhileA	:= {|| SE1->E1_FILIAL == xFilial("SE1") }
Local cAliasQry := cAlias
Local cOrigem	:= Alltrim(SE1->E1_ORIGEM)

Local lF280CAN	:= ExistBlock("F280CAN")    

//verifica se existem os campos de valores de acrescimo e decrescimo no SE5
lAcreDecre := .T.

PRIVATE cIndex	:=""
PRIVATE cPrefCan:= CriaVar("E1_PREFIXO", .F.)
PRIVATE cFatCan	:= CriaVar("E1_NUM")
PRIVATE cTipoCan:= CriaVar("E1_TIPOFAT")
PRIVATE cLote
PRIVATE oValCan
PRIVATE oQtdCan
PRIVATE cFilOriE1

Default lAutomato	:= .F.
Default lFina460 	:= .F.

// Efetua abertura do __SE1 (espelho do SE1) para deletar os abatimentos do titulo
// principal que não foram selecionados no filtro.
SomaAbat("","","","R")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento n„o ‚ menor que data limite de ³
//³ movimentacao no financeiro    										  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !DtMovFin(,,"2")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero do Lote 											  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LoteCont("FIN")

dbSelectArea("SE1")


If (Type("lF280Auto")<>"U" .and. lF280Auto)
	// Rotina Automática
	IF (nT := ascan(aAutoCab,{|x| x[1]='AUTTITCAN'})) > 0 
		SE1->(DbGoTo(Val(aAutoCab[nT,2])))
		If SE1->(EOF())
			Help(" ",1,"RECNO")
			lMSErroAuto := .T.
			Return .F. /*Function fA280Can*/
		EndIf
	Else
		Return .F. /*Function fA280Can*/
 	EndIf
EndIf

cPrefCan	:= SE1->E1_PREFIXO
cFatCan		:= SE1->E1_NUM
cTipoCan	:= SE1->E1_TIPO
cFilOriE1	:= SE1->E1_FILORIG
nValor		:= 0
nTitulos	:= 0
nFaturas	:= 0
VALOR := 0  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o titulo ‚ um titulo de IR                      ³
//³   s¢ ser  deletado quando o titulo que o gerou o for  	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SE1->E1_TIPO $ MVIRABT+"/"+MVINABT+"/"+MVCFABT+"/"+MVCSABT+"/"+MVPIABT
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o titulo de abatimento foi gerado manualmente      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Fa040Pai()
		Help(" ",1,"NAOPRINCIP")
		Return
	Endif
EndIf

FA280CalCn(@nTitulos,@nValor,cAlias,@nFaturas,@l280CalCn,.F.,lSE1Compart,@cAliasQry,cOrigem)

aSize := MSADVSIZE()
If lPanelFin //Chamado pelo Painel Financeiro			
	oPanelDados := FinWindow:GetVisPanel()
	oPanelDados:FreeChildren()
	aDim := DLGinPANEL(oPanelDados)
	DEFINE MSDIALOG oDlg OF oPanelDados:oWnd FROM 0,0 To 0,0 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )							
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Observacao Importante quanto as coordenadas calculadas abaixo: ³ 
	//³ -------------------------------------------------------------- ³ 		
	//³ a funcao DlgWidthPanel() retorna o dobro do valor da area do	 ³
	//³ painel, sendo assim este deve ser dividido por 2 antes da sub- ³
	//³ tracao e redivisao por 2 para a centralizacao. 					 ³		
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	nEspLarg := ((DlgWidthPanel(oPanelDados)/2) - 115) /2		 					
	nEspLin  := 0		
	
Else   
  	nEspLarg := 0 
  	nEspLin  := 0
	DEFINE MSDIALOG oDlg FROM	20,1 TO 181,340 TITLE STR0038 PIXEL //"Cancelamento de Fatura a Receber"
Endif	
oDlg:lMaximized := .F.
oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT    		


@ 006+nEspLin, 011+nEspLarg TO 034+nEspLin, 126+nEspLarg OF oPanel PIXEL
@ 039+nEspLin, 011+nEspLarg TO 070+nEspLin, 126+nEspLarg OF oPanel PIXEL
@ 021+nEspLin, 014+nEspLarg MSGET cPrefCan 						SIZE 21, 08 OF oPanel PIXEL
@ 021+nEspLin, 040+nEspLarg MSGET cTipoCan		F3 "05" Picture "@!" SIZE 12, 08 OF oPanel Hasbutton PIXEL ;
		Valid !Empty (cTipoCan) .and. FA280Tipo(cTipoCan)

@ 021+nEspLin, 073+nEspLarg MSGET cFatCan Valid !Empty(cFatCan) .and. ;
	FA280CalCn(@nTitulos,@nValor,cAlias,@nFaturas,@l280CalCn,.T.,lSE1Compart,@cAliasQry) ;
	SIZE 49, 08 OF oPanel PIXEL

@ 056+nEspLin, 014+nEspLarg MSGET nTitulos When .F. SIZE 28, 08 OF oPanel PIXEL
@ 056+nEspLin, 058+nEspLarg MSGET nValor When .F. Picture "@E 9,999,999,999.99" SIZE 63, 08 OF oPanel PIXEL
@ 011+nEspLin, 014+nEspLarg SAY STR0039 SIZE 21, 07 OF oPanel PIXEL //"Prefixo"
@ 011+nEspLin, 040+nEspLarg SAY STR0054 SIZE 12, 07 OF oPanel PIXEL //"Tipo"
@ 011+nEspLin, 073+nEspLarg SAY STR0040 SIZE 49, 07 OF oPanel PIXEL //"N£mero T¡tulo"
@ 046+nEspLin, 014+nEspLarg SAY STR0041 SIZE 35, 07 OF oPanel PIXEL //"Total Notas"
@ 046+nEspLin, 058+nEspLarg SAY STR0016 SIZE 53, 07 OF oPanel PIXEL //"Valor da Fatura"

IF (!lAutomato .And. (Type("lF280Auto")<>"U" .and. !lF280Auto)) .Or. lFina460
	If lPanelFin //Chamado pelo Painel Financeiro					
		oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])			
		ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,;
		{||nOpca:=1,IF(IF(l280CalCn,.T.,Fa280CalCn(@nTitulos,@nValor,cAlias,@nFaturas,@l280CalCn,.T.,lSE1Compart,@cAliasQry,cOrigem)),oDlg:End(),nOpca:=0)},;
		{||oDlg:End()})
	Else	
		DEFINE SBUTTON FROM 10, 133 TYPE 1 ACTION (nOpca:=1,;
			IF(IF(l280CalCn,.T.,Fa280CalCn(@nTitulos,@nValor,cAlias,@nFaturas,@l280CalCn,.T.,lSE1Compart,@cAliasQry,cOrigem)),;
			oDlg:End(),nOpca:=0)) ENABLE OF oPanel
		DEFINE SBUTTON FROM 23, 133 TYPE 2 ACTION oDlg:End() ENABLE OF oPanel	
		ACTIVATE MSDIALOG oDlg CENTERED
	Endif
Else
	nOpca:=1
Endif
	
If nOpca == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PONTO DE ENTRADA F280PCAN                                     ³
	//³ Este PE serve para permitir ou não o cancelamento da fatura   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("F280PCAN")
		lRet := ExecBlock("F280PCAN",.F.,.F.)
	Endif		

	aRecDel := {}

	If lRet
		// O indice temporario foi montado anteriormente
		dbGoTop()
		nValTotal := 0

		Begin Transaction
		
			If !lSE1Compart
				bWhileA		:= {|| .T. }
			Endif

			While !(cAliasQry)->(Eof()) .And. Eval(bWhileA)

				// Posiciona a tabela original
				dbSelectAreA("SE1")
				SE1->(dbGoto((cAliasQry)->RECNO))
			
				If SE1->E1_FATURA == cFatCan .and. SE1->E1_TIPOFAT == cTipoCan
					cChaveSe1:= SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)

					// Cancelamento do rastreamento(FI7/FI8)
					If lRastro
						FINRSTDEL("SE1",cChaveSe1)
					Endif

					nAcresc := 0
					nDecresc := 0
					dbSelectArea("SE5")
					dbSetOrder(7)
					If dbSeek(xFilial("SE5")+cChaveSE1)
						While !Eof() .and. SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == cChaveSE1
							If SE5->E5_MOTBX== "FAT" .and. SE5->E5_RECPAG == "R"
								// Verifica movimentacao de AVP
								FAVPValTit( "SE1", SE5->( RecNo() ) )

								If lAcreDecre
									nAcresc += SE5->E5_VLACRES
									nDecresc += SE5->E5_VLDECRE
									dBaixa := SE5->E5_DATA
								Endif

								//Gravo dados utilizados pela contabilizacao e estorno da baixa por fatura
								RecLock("SE1")
								If SE5->E5_TIPODOC == "BA"
									If cPaisLoc == "BRA"	
										SE1->E1_VALLIQ  := Round(xMoeda(SE5->E5_VALOR,1,SE1->E1_MOEDA,dBaixa,3,,SE5->E5_TXMOEDA),2)
										SE1->E1_DESCONT := Round(xMoeda(SE5->(E5_VLDESCO-E5_VLDECRE),1,SE1->E1_MOEDA,dBaixa,3,,SE5->E5_TXMOEDA),2)
										SE1->E1_MULTA   := Round(xMoeda(SE5->E5_VLMULTA,1,SE1->E1_MOEDA,dBaixa,3,,SE5->E5_TXMOEDA),2) 
										SE1->E1_JUROS   := Round(xMoeda(SE5->(E5_VLJUROS-E5_VLACRES),1,SE1->E1_MOEDA,dBaixa,3,,SE5->E5_TXMOEDA),2)
										SE1->E1_CORREC  := Round(xMoeda(SE5->E5_VLCORRE,1,SE1->E1_MOEDA,dBaixa,3,,SE5->E5_TXMOEDA),2) 
									Else
										SE1->E1_VALLIQ  := SE5->E5_VALOR 
										SE1->E1_DESCONT := SE5->(E5_VLDESCO-E5_VLDECRE)
										SE1->E1_MULTA   := SE5->E5_VLMULTA
										SE1->E1_JUROS   := SE5->(E5_VLJUROS-E5_VLACRES)
										SE1->E1_CORREC  := SE5->E5_VLCORRE
									EndIf
								EndIf
								MSUnlock()		
								If !(SE5->E5_TIPODOC == "BA")
									RecLock("SE5")
									dbDelete()
									MsUnlock()
								Endif
		

								//Contabiliza cancelamento da baixa dos titulos geradores da fatura
								IF lPadrao527 .and. SE5->E5_LA = "S "
									If nHdlPrv <= 0
									nHdlPrv:=HeadProva(cLote,"FINA280",Substr(cUsuario,7,6),@cArquivo)
									lHead := .T.
									Endif
					
									If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
										aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
									Endif
									nTotal += DetProva( nHdlPrv, "527", "FINA280", cLote, /*nLinha*/, /*lExecuta*/,;
									                    /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
								   	                 /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
								Endif			

								//Posiciona a FK5 para mandar a operação de alteração com base no registro posicionado da SE5
								If AllTrim( SE5->E5_TABORI ) == "FK1" .and. SE5->E5_TIPODOC == "BA"
									oModelMov	:= FWLoadModel("FINM010")
									oModelMov:SetOperation( MODEL_OPERATION_UPDATE ) //Alteração
									oModelMov:Activate()
									oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
									oModelMov:SetValue( "MASTER", "HISTMOV",STR0083+SE5->E5_FATURA ) //"Cancelamento Fatura "
									//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
									//E5_OPERACAO 2 = Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK5
									//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
									oModelMov:SetValue( "MASTER", "E5_OPERACAO", 3 ) //E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
									//Posiciona a FKA com base no IDORIG da SE5 posicionada
		           					oFKA := oModelMov:GetModel( "FKADETAIL" )
									If oFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
										If oModelMov:VldData()
											oModelMov:CommitData()
											
										Else
											lRet := .F.
											cLog := cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
											cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
											cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_MESSAGE])           	
									    		
								    		Help( ,,"M010VALID",,cLog, 1, 0 )
										Endif
									Endif
									oModelMov:DeActivate()
									oModelMov:Destroy()
									oModelMov:= nil
								EndIf
							Endif
							SE5->(dbSkip())
						Enddo
					Endif
				
					// Se a pergunta "Considera lojas" for igual a nao, deve-se atualizar o saldo das 
					// duplicadas das diferentes lojas
					If mv_par01 == 2
						SA1->(MsSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))
						SA1->(AtuSalDup("+",SE1->E1_VALLIQ,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO))
						SA1->(RestArea(aAreaSa1))
					Endif	
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se for um titulo que gerou a fatura, desfaz o processo		³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nAbatim := If( ! SE1->E1_TIPO$MVABATIM+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT+"/"+MVI2ABT,SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA,,,SE1->E1_TIPO),0)
					dbSelectArea("SE1") 
					If !(SE1->E1_TIPO $ MVABATIM)
					
						lMultNat := SE1->E1_MULTNAT == "1"
					
						If lAtuSldNat
							// Multiplas Naturezas
							If lMultNat
								aAreaATU := GetArea()
								DbSelectArea("SEV")
								SEV->( DbSetOrder(1) )
								SEV->( MsSeek( xFilial("SEV") + cChaveSE1 ) )
								While SEV->(!Eof()) .And. xFilial("SEV") + cChaveSE1 == SEV->(EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA)
						
									// Caso Multiplas Naturezas do Contas a Pagar
									If SEV->EV_RECPAG != "R"
										SEV->( DbSkip() )
										Loop
									EndIf
						
									// Volto o saldo da natureza
									AtuSldNat(SEV->EV_NATUREZ, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SEV->EV_VALOR, xMoeda(SEV->EV_VALOR, SE1->E1_MOEDA, 1),"+",,FunName(),"SE1", SE1->(Recno()),0)
									SEV->( DbSkip() )
								EndDo
								RestArea(aAreaATU)
							Else
								// Volto o saldo da natureza
								AtuSldNat(SE1->E1_NATUREZ, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SE1->E1_VALLIQ, xMoeda(SE1->E1_VALLIQ, SE1->E1_MOEDA, 1),"+",,FunName(),"SE1", SE1->(Recno()),0)
							EndIf
						Endif
						cTitpai:=SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)						
						nTamTitPai := Len(cTitpai)
						RecLock("SE1")         // retirado juros para compor corretamente o valor original da nota
						SE1->E1_SALDO	+= SE1->E1_VALLIQ - SE1->E1_JUROS - SE1->E1_ACRESC + SE1->E1_DESCONT + SE1->E1_DECRESC + nAbatim
						SE1->E1_MOVIMEN	:= dDataBase
						//Adiciona o Recno() dos tíulos para depois zerar os campos que fazem parte do filtro,
						//devido a problemas que ocorrem com ambiente AS400 e CTREE/LINUX.
						If Ascan(aRecDel, SE1->(Recno())) == 0
							AAdd(aRecDel, SE1->(Recno()))
						Endif	
						SE1->E1_DTFATUR	:= CtoD("  /  /  ")
						SE1->E1_STATUS 	:= Iif(SE1->E1_SALDO>0.01,"A","B")
						SE1->E1_JUROS		:= 0 
						If (cMVJurTipo == "L" .OR. lMvLjIntFs) .And. lLojxRMul  	//Calculo de Juros e Multas: SIGALOJA x SIGAFIN 
							SE1->E1_MULTA   := 0
						EndIf
						
						SE1->E1_DESCONT	:= 0
						SE1->E1_VALLIQ		:= 0
						SE1->E1_CORREC := 	0
						If SE1->E1_SALDO == SE1->E1_VALOR
							SE1->E1_BAIXA		:= CtoD("  /  /  ")
							SE1->E1_SDACRES	:= SE1->E1_ACRESC
							SE1->E1_SDDECRE	:= SE1->E1_DECRESC
						ElseIf lAcreDecre
							SE1->E1_SDACRES	:= Round(NoRound(xMoeda(SE1->E1_ACRESC,1,SE1->E1_MOEDA,dBaixa,3),3),2)
							SE1->E1_SDDECRE	:= Round(NoRound(xMoeda(SE1->E1_DECRESC,1,SE1->E1_MOEDA,dBaixa,3),3),2)
						Endif
						SE1->E1_FLAGFAT   := Space(Len(SE1->E1_FLAGFAT))
						MsUnlock()    

						//adiciona no array os titulos pai
						If lExistFJU
							aAdd(aTitPai,{SE1->E1_FILIAL,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->(Recno())})
						EndIf

						///numbor			
						aAlt := {}
					    aadd( aAlt,{ STR0090,'','','',STR0091 +  Alltrim(Transform(SE1->E1_VALOR,PesqPict("SE1","E1_VALOR"))) })   
					    ///chamada da Função que cria o Histórico de Cobrança
						FinaCONC(aAlt)
						
						//Volto saldo dos abatimentos do titulo principal.
						If nAbatim > 0
							dbSelectArea("__SE1")
							DbSetOrder(2)  
		   	
							If dbSeek(SE1->(E1_FILIAL + E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA))  
								cTitAnt := __SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)  
						  		If lTitpaiSE1
							 		If (nOrdTitPai:= OrdTitpai()) > 0
   									DbSetOrder(nOrdTitPai)
										If	DbSeek(SE1->E1_FILIAL+cTitpai)    
		  									bWhile  := {|| !Eof() .And. Subst(__SE1->E1_TITPAI,1,Len(cTitpai)) == cTitpai .And. __SE1->E1_FILIAL == SE1->E1_FILIAL } 
			  							Else
			  								DbSetOrder(2)  
			  							EndIf
	 	   							Endif
	  							Endif

								While Eval(bWhile) 
									If !__SE1->E1_TIPO $ MVABATIM
										dbSkip()
										Loop
									Endif  
									If lTitpaiSE1
										If  !Empty(E1_TITPAI).and.(Alltrim(E1_TITPAI)!=Alltrim(cTitpai))
											DbSkip()
											Loop
										EndIf
									EndIf 
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Volta t¡tulo para carteira                                       ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									Reclock("__SE1")
									__SE1->E1_BAIXA   := CtoD("  /  /  ")
									__SE1->E1_SALDO   := __SE1->E1_VALOR
									__SE1->E1_FATURA 	:= " "
									__SE1->E1_FATPREF	:= " "
									__SE1->E1_TIPOFAT	:= " "
									__SE1->E1_DTFATUR	:= CtoD("  /  /  ")
									__SE1->E1_VALLIQ  := 0
									__SE1->E1_STATUS  := "A"
									__SE1->E1_MOVIMEN := Ctod("  /  /  ")
									MsUnlock()
										
									lMultNat := SE1->E1_MULTNAT == "1"
									
									If lAtuSldNat
										// Multiplas Naturezas
										If lMultNat
											aAreaATU := GetArea()
											DbSelectArea("SEV")
											SEV->( DbSetOrder(1) )
											SEV->( MsSeek( xFilial("SEV") + cChaveSE1 ) )
											While SEV->(!Eof()) .And. xFilial("SEV") + cChaveSE1 == SEV->(EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA)
									
												// Caso Multiplas Naturezas do Contas a Pagar
												If SEV->EV_RECPAG != "R"
													SEV->( DbSkip() )
													Loop
												EndIf
									
												// Volto o saldo da natureza
												AtuSldNat(SEV->EV_NATUREZ, __SE1->E1_VENCREA, __SE1->E1_MOEDA, "2", "R", SEV->EV_VALOR, SEV->EV_VALOR,"-",,FunName(),"__SE1", __SE1->(Recno()),0)
												SEV->( DbSkip() )
											EndDo
											RestArea(aAreaATU)
										Else
											// Volto o saldo da natureza
											AtuSldNat(__SE1->E1_NATUREZ, __SE1->E1_VENCREA, __SE1->E1_MOEDA, "2", "R", __SE1->E1_VALOR, __SE1->E1_VLCRUZ,"-",,FunName(),"__SE1", __SE1->(Recno()),0)
										EndIf
									Endif
									dbSkip()
								EndDo
							Endif
					   Endif
					   	/*
						Atualiza o status do titulo no SERASA */
						If cPaisLoc == "BRA"
							cChaveTit := SE1->E1_FILIAL + "|" +;
										SE1->E1_PREFIXO + "|" +;
										SE1->E1_NUM		+ "|" +;
										SE1->E1_PARCELA + "|" +;
										SE1->E1_TIPO	+ "|" +;
										SE1->E1_CLIENTE + "|" +;
										SE1->E1_LOJA
							cChaveFK7 := FINGRVFK7("SE1",cChaveTit)
							F770BxRen("3","",cChaveFK7)
						Endif
					Endif
					dbSelectArea("SE1")
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Integracao Modulo de Transporte (TMS).                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
					If IntTms()
						dbSelectArea("DT6")
						DT6->(dbSetOrder(1))
						If MsSeek(xFilial("DT6")+SE1->E1_MSFIL+SE1->E1_NUM+SE1->E1_SERIE)
							Reclock("DT6",.F.)
							DT6->DT6_FATURA := Space(TamSx3("DT6_FATURA")[1])
							MsUnlock()
						EndIf
					EndIf
				Else
					nReg:=RecNo()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se for uma parcela da fatura contabiliza o canceel. e deleta	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lPadrao:=VerPadrao(cPadrao)
					If lPadrao
						If !lHead
							nHdlPrv:=HeadProva(cLote,"FINA280",Substr(cUsuario,7,6),@cArquivo)
							lHead := .T.
						Endif

						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
							aAdd( aFlagCTB, {"E1_LA", "S", "SE1", SE1->( Recno() ), 0, 0, 0} )
						Endif
						nTotal += DetProva( nHdlPrv, cPadrao, "FINA280", cLote, /*nLinha*/, /*lExecuta*/,;
						                    /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
						                    /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
					Endif
					dbSelectArea("SE1")
					nReg:=IIf(RecNo() != nReg, dbGoTo(nReg), nReg)
					If cPaisloc == "BRA"
						nValTotal += Round( xMoeda(SE1->E1_VLCRUZ,SE1->E1_MOEDA,1,SE1->E1_EMISSAO,3), MsDecimais(1) ) 
					Else
						nValTotal += SE1->E1_VLCRUZ
				    EndIf
					// Se a pergunta "Considera lojas" for igual a nao, deve-se atualizar o saldo das 
					// duplicadas das diferentes lojas
					If mv_par01 == 2
						SA1->(MsSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))
						SA1->(AtuSalDup("-",SE1->E1_SALDO,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO))
						SA1->(RestArea(aAreaSa1))
					Endif	
                       
					// Apaga os registros agregados ao titulo (fatura) principal.
					If !( SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
					    aArea:=GetArea()
						cChave := xFilial("SE1") + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)
						__SE1->(dbSetOrder(1))
						__SE1->(MsSeek(cChave))
						While __SE1->(!EOF()) .And. __SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA) == cChave
							If __SE1->E1_TIPO $ MVPIABT+"/"+MVCFABT+"/"+MVCSABT+"/"+MVABATIM+"/"+MVISABT+"/"+MVI2ABT   // AB-/IR-/IN-/IS-/I2-
								If lAtuSldNat
									// Tira o saldo do vencimento programado do titulo
									AtuSldNat(__SE1->E1_NATUREZ, __SE1->E1_VENCREA, __SE1->E1_MOEDA, "2", "R", __SE1->E1_VALOR, __SE1->E1_VLCRUZ,"+",,FunName(),"__SE1", __SE1->(Recno()),0)
								Endif
								If lExistFJU
									SE1->(DBGoto(__SE1->(Recno())))
									FinGrvEx("R")
								Endif	
								
								RecLock("__SE1" ,.F.)
								dbDelete()
								MsUnlock()
							EndIf
							__SE1->(dbSkip())
						Enddo
						__SE1->(dbSetOrder(1))
						RestArea(aArea)
					Endif
								
					If lAtuSldNat
						// Tira o saldo do vencimento programado do titulo
						AtuSldNat(SE1->E1_NATUREZ, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SE1->E1_VALOR, SE1->E1_VLCRUZ, "-",,FunName(),"SE1", SE1->(Recno()),0)
					Endif

					If lExistFJU
						For ni := 1 to Len(aTitPai)
							FinGrvEx("R",aTitPai[nI][1], aTitPai[nI][2],aTitPai[nI][3],aTitPai[nI][4],aTitPai[nI][5],aTitPai[nI][6],aTitPai[nI][7],aTitPai[nI][8])	
						Next ni
					Endif	

					RecLock("SE1",.F.,.T.)
					dbDelete()
					MsUnlock()
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ PONTO DE ENTRADA F280CAN                                      ³
				//³ Este PE serve para grava‡äes complementares ap¢s cancelamento ³
				//³ do titulo na fatura.                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF lF280CAN
					ExecBlock("F280CAN",.F.,.F.)
				Endif
				dbSelectArea(cAliasQry)
				(cAliasQry)->(dbSkip())
			Enddo
		
			//Apaga registros gerados pela fatura, pois estes campos fazem parte do filtro e ocasionavam EOF no SE1
			//quando se utiliza os ambientes AS400 e CTREE/LINUX.
								
			dbSelectArea("SE1")
			For nX := 1 to Len(aRecDel)
				dbGoto(aRecDel[nX])
				RecLock("SE1",.F.)
					SE1->E1_FATURA 	:= " "
					SE1->E1_FATPREF	:= " "
					SE1->E1_TIPOFAT	:= " "
				MsUnlock()
			Next
				
			If nTotal > 0
				dbSelectArea("SE1")
				nRecSe1 := Recno()
				SE1->(DBGoBottom())
				SE1->(dbSkip())
				VALOR := nValTotal
				// Contabiliza atraves da varavel >>VALOR<<
				nTotal+=DetProva(nHdlPrv,cPadrao,"FINA280",cLote)

				//-- Se for rotina automatica força exibir mensagens na tela, pois mesmo quando não exibe os lançametnos, a tela 
				//-- sera exibida caso ocorram erros nos lançamentos padronizados
				If (Type("lF280Auto")<>"U" .and. lF280Auto)
					lSetAuto := _SetAutoMode(.F.)
					lSetHelp := HelpInDark(.F.)
					If Type('lMSHelpAuto') == 'L'
						lMSHelpAuto := !lMSHelpAuto
					EndIf						
				Else 
					 lF280Auto := .F.						
				EndIf
				
				lDigita := IIF( mv_par02==1 .And. !lAutomato .And. !lF280Auto,.T.,.F.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia para Lan‡amento Cont bil                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RodaProva(nHdlPrv,nTotal)
				cA100Incl( cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, lDigita, .F. /*lAglut*/,;
				           /*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, /*aDiario*/ )
				aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
				VALOR := 0

				If (Type("lF280Auto")<>"U" .and. lF280Auto)
					HelpInDark(lSetHelp)
					_SetAutoMode(lSetAuto)
					If Type('lMSHelpAuto') == 'L'
						lMSHelpAuto := !lMSHelpAuto
					EndIf
				EndIf
								
				dbSelectArea("SE1")
				SE1->(DBGoTo(nRecSe1))
			Endif
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Volta Ultimo Numero do Parametro de Fatura	07/12/95 	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNewFat := GetMV("MV_NUMFAT")
			IF alltrim(cNewFat) == alltrim(cFatCan)					
				PutMV("MV_NUMFAT",Tira1(SUBSTR(cFatCan,1,len(cNewFat))))
			Endif
		
		End Transaction
		__cNroFatur := cFatCan
		//Integração via Mensagem Única
		If cPaisLoc == "BRA"
			If SE1->E1_IDLAN > 0 .And. FWHasEAI('FINA280',.T.,,.T.)
				aValOrig := F280ChgVar() //Altera as variáveis INCLUI, ALTERA			
				FwIntegDef( 'FINA280',,,,'FINA280' )				
				F280RetVar(aValOrig)
			EndIf		
		EndIf
	Endif
	//
	//Função Específica do Modulo Sigapls para atualizar Status de Guias Compradas
	//
	/* "Retirada temporariamente a funcionalidade do módulo PLS para performar a rotina Faturas a Receber;
	    Anterior a esta alteração, o sistema varria todos os registros da tabela SE1 desnecessariamente, ;
	    causando lentidão no cancelamento da fatura."
	
	DBGoTop()
	While .T.
		PL090TITCP(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,"5")
		SE1->(dbSkip())
		If SE1->(EoF())
			Exit
		EndIf
	Enddo		
	*/
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados									  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
Set Filter to
RetIndex(cAlias)
If !Empty(cIndex)
	fErase(cIndex+OrdBagExt())
	cIndex := ""
Endif
dbSetOrder(1)    
MsSeek(xFilial(cAlias))
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa280CAlCn  ³ Autor ³ Cesar C S Prado		  ³ Data ³ 27/04/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria o indice temporario para o cancelamento da fatura		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fa280CalCn()													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 													³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FA280CALCN(nTitulos,nValor,cAlias,nFaturas,l280CalCn,lHelpCan,lSE1Compart,cAliasQry,cOrigem)

Local lBanco		:= .F.
Local lUsaJur		:= GetMV( "MV_JURFAT" ,.T.,.F.) // Determina se a fatura sera composta com os juros do titulo original caso haja.
Local cMVJurTipo	:= SuperGetMV("MV_JURTIPO",,"")         //Tipo de Calculo de Juros e Multas do Loja
Local lLojxRMul	:= .T. //Funcao que calcula os juros e multas do Loja 
Local lMvLjIntFS	:= SuperGetMV("MV_LJINTFS",, .F.) //Habilitada Integracao com o Financial Services?
//Situacao de cobranca
Local cLstCart	:= FN022LSTCB(1,"0005")	//Lista das situacoes de cobranca - CARTEIRA
Local lRet			:= .T.

DEFAULT lHelpCan  	:= .T.
DEFAULT l280CalCn 	:= .F.
DEFAULT lSE1Compart	:= .F.
DEFAULT cAliasQry 	:= "SE1"
DEFAULT cOrigem		:= "FINA280"

If Empty(cFatCan)
	Help(" ",1,"INDVAZIO")
	lRet := .F.
Endif

If lRet
	cAliasQry 	:= "SE1CAN"

	If Select(cAliasQry) > 0 
		dbSelectArea(cAliasQry)
		dbCloseArea()
		dbSelectArea(cAlias)
	Endif

	cQuery := FA280FCAN(lSE1Compart,cOrigem)
	cQuery := ChangeQuery(cQuery)
 	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"SE1CAN",.F.,.T.)
	dbSelectArea(cAliasQry)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Certifica se foram encontrados registros na condi‡„o selecionada 		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BOF() .and. EOF()
		If lHelpCan
			Help(" ",1,"INDVAZIO")
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura os indices do SE1 e deleta o arquivo de trabalho				³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cAliasQry)
		dbCloseArea()
		dbSelectArea("SE1")
		dbSetOrder(1)
		lRet := .F.
	Endif

	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso tenha ocorrido a baixa de alguma parcela da fatura, nao sera pos- ³
		//³ sivel a opera‡„o de cancelamento.													³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValor		:=  0
		nTitulos	:=  0
		lCancelar	:= .T.   
		lBanco		:= .F.

		dbSelectArea(cAliasQry)
		While !Eof()
			// Posiciona a tabela original		
			SE1->(dbGoto((cAliasQry)->RECNO))
		
			If SE1->E1_NUM == cFatCan .And. Day(SE1->E1_BAIXA) > 0 .AND. ;
				SE1->E1_PREFIXO == cPrefCan .and. SE1->E1_TIPO == cTipoCan
				lCancelar:=.F.
			ElseIf !(SE1->E1_SITUACA $ cLstCart)		//Lista das situacoes de cobranca - CARTEIRA
				lBanco := .T.
			Else
				If !SE1->E1_TIPO $ MV_CRNEG+"/"+MVABATIM
					nValor += IIF(SE1->E1_SALDO == 0, SE1->E1_VALLIQ, 0)
				Endif
				If lUsaJur
				   nValor += SE1->E1_JUROS + IIF(( cMVJurTipo=="L" .OR. lMvLjIntFs).And. lLojxRMul, SE1->E1_MULTA, 0) //Calculo de Juros e Multas: SIGALOJA x SIGAFIN 
				Endif
				nTitulos+= IIF(!Empty(SE1->E1_TIPOFAT), 1, 0)
			Endif
			(cAliasQry)->(dbSkip())
		Enddo

		If !lCancelar .or. lBanco
			dbSelectArea(cAliasQry)
			dbCloseArea()
			
			dbSelectArea("SE1")
			dbSetOrder(1)
			
			If lHelpCan
				If !lCancelar
					Help(" ",1,"FATJABX") // Nao aceita se ja houve baixa em fatura
				ElseIf lBanco
					Help(" ",1,"TITBCO",,STR0062,1,0) //"Esta fatura possui parcela transferida para banco. Retorne os titulos para carteira antes de cancelar a fatura"
				Endif
			Endif
			lRet := .F.
		Endif
	EndIf
EndIf
l280CalCn := lRet

Return lRet
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FA280FCan  ³ Autor ³ Cesar C S Prado		  ³ Data ³ 27/04/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sele‡„o para a cria‡„o do indice condicional no CANCELAMENTO ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fina280														³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa280FCan(lSE1Compart,cOrigem)

Local cFiltro := ""

Default lSE1Compart := .F.
Default cOrigem		:= "FINA280"

//-------------------------------------------------------------------------
// Deverá selecionar todos os registros que atendam as seguintes condições
// 1. Prefixo e Número do Título iguais aos selecionados
// 2. Ou títulos que tenham originado a fatura selecionada
//-------------------------------------------------------------------------
cFiltro := " SELECT "
cFiltro += " R_E_C_N_O_ RECNO "
cFiltro += " FROM " + RetSqlName("SE1") + " SE1 "
cFiltro += " WHERE "

If lSE1Compart
	//Efetuo o filtro de filiais com base no campo E5_FILORIG da fatura que está sendo cancelada no processo
	cFiltro += " (SE1.E1_FILORIG = '" + cFilOriE1 + "' OR SE1.E1_FILORIG  IN "
	cFiltro += " (SELECT SE5.E5_FILORIG FROM " + RetSqlName('SE5') + ' SE5 ' 
	cFiltro += " WHERE SE5.E5_FILIAL = '" + xFilial('SE5',cFilAnt) + "' AND "
	cFiltro += "  SE5.E5_FATURA  = '" + Pad(cFatCan,Len(E1_FATURA)) + "' AND  
	cFiltro += "  SE5.E5_FATPREF = '" + cPrefCan + "' AND "
	cFiltro += "  SE5.D_E_L_E_T_ = '' ) ) AND " 
	cFiltro += "  SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM,"|")      + "   AND 
	cFiltro += "  SE1.E1_FATURA <> '"  + Space(Len(SE1->E1_FATURA))  + "'  AND "
	cFiltro += " (SE1.E1_NUM     = '"  + Pad(cFatCan,Len(E1_NUM))    + "'   OR "
	cFiltro += "  SE1.E1_FATURA  = '"  + Pad(cFatCan,Len(E1_NUM))    + "') AND "
	cFiltro += "  SE1.D_E_L_E_T_ = ' ' "
Else
	cFiltro += " SE1.E1_FILIAL  IN ( SELECT SE5.E5_FILORIG FROM " + RetSqlName('SE5') + ' SE5 ' 
	cFiltro += " WHERE SE5.E5_FILIAL = '" + xFilial('SE5',cFilAnt) + "' AND "
	cFiltro += " SE5.E5_FATURA  = '" + Pad(cFatCan,Len(E1_FATURA)) + "' AND "
	cFiltro += " SE5.E5_FATPREF = '" + cPrefCan + "' AND "
	cFiltro += " SE5.D_E_L_E_T_ = '' ) AND " 
	cFiltro += " SE1.E1_FATURA   <> '"  + Space(Len(SE1->E1_FATURA))  +"'  AND "
	cFiltro += " ((SE1.E1_NUM     = '"  + Pad(cFatCan,Len(E1_NUM))    +"'  AND "
	cFiltro += "   SE1.E1_PREFIXO = '"  + cPrefCan                    +"'  AND "
	cFiltro += "   SE1.E1_FATURA  = '"  + Pad("NOTFAT",Len(E1_FATURA))+"'  AND "
	cFiltro += "   SE1.E1_TIPO    = '"  + cTipoCan                    +"'  AND "
	cFiltro += "   SE1.E1_ORIGEM  = '"  + cOrigem                     +"')  OR "
	cFiltro += "  (SE1.E1_FATURA  = '"  + Pad(cFatCan,Len(E1_FATURA)) +"'  AND "
	cFiltro += "   SE1.E1_FATPREF = '"  + cPrefCan                    +"'  AND "
	cFiltro += "   SE1.E1_TIPOFAT = '"  + cTipoCan                    +"'  AND "
	cFiltro += "   SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM,"|")      +")) AND "
	cFiltro	+= " SE1.D_E_L_E_T_ = ' '"	
Endif

Return cFiltro

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ F280VLCRUZ ³ Autor ³ Cesar C S Prado		  ³ Data ³ 26/05/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta Array com o E?_VLCRUZ para o desdobramento de titulos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fina280													    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F280VLCRUZ(nDup,nValor)

LOCAL i
LOCAL nValorTit := iif(cpaisLoc=="CHI",round((nValor/nDup),0),noround((nValor/nDup)))
LOCAL nValDup	:= nValor

For i:=1 TO nDup
	AAdd(aVlCruz,IIf(I<nDup,nValorTit,nValDup))
	nValDup-=nValortit
NEXT i

Return(aVlCruz)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FA280Ok	³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 07/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe mensagem de OK para dados digitados da fatura		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA280OK()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa280Ok(oDlg)
Local lRet := .T.
If ExistBlock("FA280OK")
	lRet := Execblock("FA280OK",.F.,.F.,oDlg)
Endif
Return (lRet .And. MsgYesNo(STR0043,STR0044)) //"Confirma Dados?"###"Aten‡„o"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa280Marca³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 21/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Trata o valor	para marcar e desmarcar item			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa280Marca(ExpN1,ExpD1,ExpD2) 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fa280Marca(cAliasSe1,cMarca,nLimite,aChaveLbn)
LOCAL nRec
LOCAL cAliasAnt := Alias()
Local nValorFat
Local nRecSe1
Local lFa280Show := Existblock("FA280SHOW")
Local cChaveLbn
Local cChaveT
//Local lDescISS := IIF(SA1->A1_RECISS == "1" .And. GetNewPar("MV_DESCISS",.F.) .And. GetNewPar("MV_TPABISS", "1") == "1",.T.,.F.)
Local nJuros := 0
Local lUsaJur	:= GetMV( "MV_JURFAT" ,.T.,.F.) // Determina se a fatura sera composta com os juros do titulo

/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Insere valor de juros e multa, conforme regra de cálculo de juros³
//³do financeiro apontando para o loja                              ³
//³Calculo de Juros e Multas: SIGALOJA x SIGAFIN                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/
Local nMulta		:= 0 //Valor da Multa
Local cMVJurTipo	:= SuperGetMV("MV_JURTIPO", , "") //Indica o tipo de calculo de juros
Local lLojxRMul     := .T.  //Funcao que calcula os juros e multas do loja 
Local lMvLjIntFs	:= SuperGetMV("MV_LJINTFS", , .F.) //Integracao Financial Services Habilitada
Local nDescont		:= 0
Local lFini055		:= IsInCallStack("FINI055")

dbSelectArea(cAliasSe1)
nRec := Recno()
While !Eof()
	cChaveLbn := "FAT" + (cAliasSe1)->(xFilial("SE1")+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
	cChaveT := (cAliasSe1)->(xFilial("SE1")+E1_PREFIXO+E1_NUM+E1_PARCELA)
	SE1->(dbGoto((cAliasSe1)->RECNO))

	//Caso a rotina esteja cadastrada no adapter, so pode ser enviada como 'Sincrona'. Uma baixa enviada como assincrona 
	//sera concretizada mesmo que de erro no sistema integrado.
	If !lFini055 .and. cFilMsg == "1"
		If !(FA070Integ(.F.))
			Exit
		Endif
	Endif
	
	If SE1->(Simplelock())
		nMulta := 0
		If RecLock(cAliasSe1) // Se conseguir travar o registro			
			If lUsaJur
				//Calculo de Juros e Multas: SIGALOJA x SIGAFIN - Inicio
				nJuros := faJuros((cAliasSe1)->E1_VALOR,(cAliasSe1)->E1_SALDO,(cAliasSe1)->E1_VENCTO,(cAliasSe1)->E1_VALJUR,(cAliasSe1)->E1_PORCJUR,(cAliasSe1)->E1_MOEDA,(cAliasSe1)->E1_EMISSAO,dDataBase,If(cPaisLoc=="BRA",(cAliasSe1)->E1_TXMOEDA,0),,(cAliasSe1)->E1_VENCREA, cAliasSe1)
				
				If (cMvJurTipo == "L" .OR. lMvLjIntFs ) .and. lLojxRMul 
					nMulta := LojxRMul( , , ,(cAliasSe1)->E1_SALDO, (cAliasSe1)->E1_ACRESC, (cAliasSe1)->E1_VENCREA, dDataBase, , (cAliasSe1)->E1_MULTA, ,;
			  					 (cAliasSe1)->E1_PREFIXO, (cAliasSe1)->E1_NUM, (cAliasSe1)->E1_PARCELA, (cAliasSe1)->E1_TIPO, (cAliasSe1)->E1_CLIENTE, (cAliasSe1)->E1_LOJA, cAliasSe1 )   	

				
				EndIf
			    //Calculo de Juros e Multas: SIGALOJA x SIGAFIN - Final
			Endif

			//Trato o desconto por bolsa de estudos quando há integração com o RM Classis
			If cFilMsg == "1" .And. FWHasEAI("FINI070A",.T.,,.T.) .And. FWHasEai("FINA070",.T.,,.T.) .And. (AllTrim(SE1->E1_ORIGEM) $ 'L|S|T' .Or. IIF(cPaisLoc == "BRA", SE1->E1_IDLAN > 0,.F.) )
				nDescont := SE1->E1_VLBOLSA+ SE1->E1_DESCONT
				lUsaBolsa := .T.
			EndIf	

			nValorFat := If((cAliasSe1)->E1_TIPO$MVABATIM+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT+"/"+MVI2ABT,(cAliasSe1)->E1_VALOR + nJuros + nMulta - nDescont,(cAliasSe1)->(E1_SALDO+E1_SDACRES-E1_SDDECRE)+ nJuros + nMulta - nDescont)//+If( lDescISS,(cAliasSe1)->E1_ISS,0)		
			
			If cChaveT == (cAliasSe1)->(xFilial("SE1")+E1_PREFIXO+E1_NUM+E1_PARCELA) .And. ((nValor + nValorFat) <= nLimite .Or. Empty(nLimite))
				 
				(cAliasSe1)->E1_OK := cMarca
				(cAliasSe1)->E1_DESCONT := nDescont
				
				// Marcando
				If (cAliasSe1)->(FieldPos("RECNO")) > 0
					nRecSe1 := (cAliasSe1)->RECNO
				Else
					nRecSe1 := (cAliasSe1)->(Recno())
				Endif	
				If Ascan(aMark, nRecSe1) == 0
					Aadd(aMark,nRecSe1)
				Endif
				If Ascan(aChaveLbn, cChaveLbn) == 0
					Aadd(aChaveLbn,cChaveLbn)
				Endif
				If (cAliasSe1)->E1_TIPO $ MVABATIM+"/"+MV_CRNEG+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT+"/"+MVI2ABT
					nValor 	-= nValorFat
					nValCruz -= (cAliasSe1)->E1_VLCRUZ+Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2)
					nVARURV 	-= (cAliasSe1)->E1_VARURV
					nVlrAtu 	-= (cAliasSe1)->E1_VLRREAL
					nQtdTit++
				Else
					nValor 	+= nValorFat
					nValCruz += (cAliasSe1)->E1_VLCRUZ+Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2)
					nVARURV 	+= (cAliasSe1)->E1_VARURV
					nVlrAtu 	+= (cAliasSe1)->E1_VLRREAL
					nQtdTit++
				Endif
			Else
				(cAliasSe1)->E1_OK := "  "
			EndIf
			(cAliasSe1)->(MsUnlock())
			If lFa280Show 
	   	   ExecBlock("FA280SHOW",.f.,.f.,{cAliasSe1,.T.})
	      	Endif
		Else
			RecLock(cAliasSe1)
			(cAliasSe1)->E1_OK := "  "
			(cAliasSe1)->(MsUnlock())
			
		Endif
	Endif	
	(cAliasSe1)->(dbSkip())
EndDo
(cAliasSe1)->(dbGoto(nRec))
dbSelectArea(cAliasAnt)
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FA280Exibe³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 07/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe Totais de titulos selecionados						  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA280Exibe()												  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280													  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa280Exibe(cAliasSe1,cMarca,oValor,oQtdTit,oMark,nValor,nTotExcluido,lExclui,nValorF,oValorFat)
Local nValorFat := If((cAliasSe1)->E1_TIPO$MVABATIM+"/"+MVINABT+"/"+MVIRABT,(cAliasSe1)->E1_VALOR,(cAliasSe1)->(E1_SALDO+E1_SDACRES-E1_SDDECRE))
Local lFa280Show := Existblock("FA280SHOW")

DEFAULT nTotExcluido := 0
DEFAULT lExclui		:= .F.
DEFAULT nValorF := 0 

if lFa280Show
   ExecBlock("FA280SHOW",.f.,.f.,{cAliasSe1,.F.})
Endif

If (cAliasSe1)->E1_OK == cMarca
	If (cAliasSe1)->E1_TIPO $ MVABATIM+"/"+MV_CRNEG+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT+"/"+MVI2ABT
		nValor 	:= If(lExclui,nValor + nValorFat,nValor - nValorFat)
		nValCruz := If(lExclui,	nValCruz + (cAliasSe1)->E1_VLCRUZ+Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2),;
										nValCruz - (cAliasSe1)->E1_VLCRUZ-Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2))
		nVARURV 	:= If(lExclui,nVarUrv + (cAliasSe1)->E1_VARURV,nVarUrv - (cAliasSe1)->E1_VARURV)  
		nVlrAtu 	:= If(lExclui,nVlrAtu + (cAliasSe1)->E1_VLRREAL,nVlrAtu - (cAliasSe1)->E1_VLRREAL)  
		nQtdTit++
		nTotExcluido := nTotExcluido - If(lExclui,nValorFat,0)
	Else
		nValor 	:= If(lExclui,nValor - nValorFat,nValor + nValorFat)
		nValCruz := If(lExclui,	nValCruz - (cAliasSe1)->E1_VLCRUZ-Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2),;
										nValCruz + (cAliasSe1)->E1_VLCRUZ+Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2))
		nVARURV 	:= If(lExclui,nVarUrv - (cAliasSe1)->E1_VARURV,nVarUrv + (cAliasSe1)->E1_VARURV)    
		nVlrAtu 	:= If(lExclui,nVlrAtu - (cAliasSe1)->E1_VLRREAL,nVlrAtu + (cAliasSe1)->E1_VLRREAL)  
		nQtdTit++
		nTotExcluido := nTotExcluido + If(lExclui,nValorFat,0)
	Endif
Else
	If (cAliasSe1)->E1_TIPO $ MVABATIM+"/"+MV_CRNEG+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT+"/"+MVI2ABT
		nValor 	:= If(lExclui,nValor - nValorFat,nValor + nValorFat)
		nValCruz := If(lExclui,	nValCruz - (cAliasSe1)->E1_VLCRUZ-Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2),;
										nValCruz + (cAliasSe1)->E1_VLCRUZ+Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2))
		nVARURV 	:= If(lExclui,nVarUrv - (cAliasSe1)->E1_VARURV,nVarUrv + (cAliasSe1)->E1_VARURV)
		nVlrAtu 	:= If(lExclui,nVlrAtu - (cAliasSe1)->E1_VLRREAL,nVlrAtu + (cAliasSe1)->E1_VLRREAL)  
		nQtdTit--
		nTotExcluido := nTotExcluido + If(lExclui,nValorFat,0)
	Else
		nValor 	:= If(lExclui,nValor + nValorFat,nValor - nValorFat)
		nValCruz := If(lExclui,	nValCruz + (cAliasSe1)->E1_VLCRUZ+Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2),;
										nValCruz - (cAliasSe1)->E1_VLCRUZ-Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2))
		nVARURV 	:= If(lExclui,nVarUrv + (cAliasSe1)->E1_VARURV,nVarUrv - (cAliasSe1)->E1_VARURV)
		nVlrAtu 	:= If(lExclui,nVlrAtu + (cAliasSe1)->E1_VLRREAL,nVlrAtu - (cAliasSe1)->E1_VLRREAL)  
		nQtdTit--
		nTotExcluido := nTotExcluido - If(lExclui,nValorFat,0)
	Endif
Endif

nQtdTit:= Iif(nQtdTit<0,0,nQtdTit)
If oValorFat <> NIL
	oValorFat:Refresh()
EndIf
oValor:Refresh()
oQtdTit:Refresh()

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FA280Invert³ Autor ³ Wagner Xavier		    ³ Data ³ 09/05/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca / Desmarca titulos							  				    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fina280																		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa280Inverte( cAliasSe1,cMarca,oValor,oQtdTit,lTodos,oMark,nValor,;
							  nTotExcluido,lExclui,lRecursiva,aChaveLbn,cChaveLbn,nValCruz,oValorFat)
							  
Local nReg := (cAliasSe1)->(Recno())
Local cAlias := Alias()
Local nOrderSe1 := (cAliasSe1)->(IndexOrd())
Local nAscan
Local nValorFat
Local cTitAnt
Local bWhile 
Local nRecSe1
Local lFa280Show := Existblock("FA280SHOW")
Local lDescISS := IIF(SA1->A1_RECISS == "1" .And. GetNewPar("MV_DESCISS",.F.) .And. GetNewPar("MV_TPABISS", "1") == "1",.T.,.F.)
Local nJuros := 0
Local lMarc := .T.
Local lF280TIT := ExistBlock("F280TIT")
Local lUsaJur	:= GetMV( "MV_JURFAT" ,.T.,.F.) // Determina se a fatura sera composta com os juros do titulo original caso haja.
Local nMulta := 0       //Valor da Multa
Local cMVJurTipo := SuperGetMV("MV_JURTIPO",,"")   //Tipo de calculo dos juros
Local lLojxRMul     := .T.    //Funcao que calcula os juros do loja    
Local lMvLjIntFS	:= SuperGetMV("MV_LJINTFS", , .F.) //Habilita Integracao com o Financial Services?
												 // original caso haja.        
												 
//Controle de abatimento
Local lTitpaiSE1 	:= .T.
Local nOrdTitPai	:= 0
Local bWhTit		:= {||  (cAliasSe1)->(!Eof()) .And. cTitAnt+cParcela == (cAliasSe1)->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)}
Local cTitpai		:= ""     
Local cParcela		:= ""
Local lFini055		:= IsInCallStack("FINI055")
Local nDescont		:= 0

Local cTpcFilMsg	:= Type("cFilMsg") == "U"
												 
DEFAULT lTodos  := .T.
DEFAULT nTotExcluido := 0
DEFAULT lExclui := .F.
DEFAULT lRecursiva := .F. 
DEFAULT nValCruz := 0

If !lRecursiva .And. (cAliasSe1)->E1_TIPO $ MVABATIM+"/"+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT+"/"+MVI2ABT
	IW_MsgBox("Este é um título de abatimento, não pode ser marcado/desmarcado, posicione sobre o titulo principal para esta operação",STR0061,"STOP")
	Return
Endif


lMarc := IIF (lF280TIT,ExecBlock("F280TIT",.F.,.F.,{cAliasSe1}),.T.)
If lMarc

	dbSelectArea(cAliasSe1)
	#IFNDEF TOP
		If lTodos
			dbSeek(xFilial("SE1"))
			bWhile := {|| xFilial("SE1") == (cAliasSe1)->E1_FILIAL}
		Endif	
	#ELSE
		If lTodos
			DbGoTop()
			bWhile := {||.T.}
		Endif	
	#ENDIF	
	While !lTodos .Or.;
			((cAliasSe1)->(!Eof()) .And. Eval(bWhile))
	
		If lFa280Show
	  	  ExecBlock("FA280SHOW",.f.,.f.,{cAliasSe1,.F.})
	   Endif
	
		If (cAliasSe1)->(FieldPos("RECNO")) > 0
			DbSelectArea("SE1")
			MsGoto((cAliasSe1)->RECNO)
			DbSelectArea(cAliasSe1)
		Endif	

		//Caso a rotina esteja cadastrada no adapter, so pode ser enviada como 'Sincrona'. Uma baixa enviada como assincrona 
		//sera concretizada mesmo que de erro no sistema integrado.
		
		If cTpcFilMsg //Verifica se a variável é NIL em casos quando a função é chamada de
		                          //Outros fontes como o FINA281,  e atribui o valor inicial declarado.
			cFilMsg := "2"		
		Endif
		If !lFini055 .and. cFilMsg == "1"
			If !(FA070Integ(.F.))
				Exit
			Endif
		Endif
			
		//Trato o desconto por bolsa de estudos quando há integração com o RM Classis
		If cFilMsg == "1" .and. FWHasEAI("FINI070A",.T.,,.T.) .And. FWHasEai("FINA070",.T.,,.T.) .And. (AllTrim(SE1->E1_ORIGEM) $ 'L|S|T' .Or. IIF(cPaisLoc == "BRA", SE1->E1_IDLAN > 0,.F.) )
			nDescont := SE1->E1_VLBOLSA + SE1->E1_DESCONT
			lUsaBolsa	:= .T.
		Else
			nDescont := SE1->E1_DESCONT
		EndIf	   
		
		//Calculo de Juros e Multas: SIGALOJA x SIGAFIN  - Inicio
		nMulta := 0		
		If (cMvJurTipo == "L" .OR. lMvLjIntFs) .and. lLojxRMul .and. lUsaJur
			nMulta := LojxRMul( , , ,(cAliasSe1)->E1_SALDO, (cAliasSe1)->E1_ACRESC, (cAliasSe1)->E1_VENCREA, dDataBase, , (cAliasSe1)->E1_MULTA, ,;
			  					 (cAliasSe1)->E1_PREFIXO, (cAliasSe1)->E1_NUM, (cAliasSe1)->E1_PARCELA, (cAliasSe1)->E1_TIPO, (cAliasSe1)->E1_CLIENTE, (cAliasSe1)->E1_LOJA, cAliasSe1 )   	

				
		EndIf
		If lUsaJur
			nJuros := faJuros((cAliasSe1)->E1_VALOR,(cAliasSe1)->E1_SALDO,(cAliasSe1)->E1_VENCTO,(cAliasSe1)->E1_VALJUR,(cAliasSe1)->E1_PORCJUR,(cAliasSe1)->E1_MOEDA,(cAliasSe1)->E1_EMISSAO,dDataBase,If(cPaisLoc=="BRA",(cAliasSe1)->E1_TXMOEDA,0),,(cAliasSe1)->E1_VENCREA, cAliasSe1)
		Endif

		nValorFat := If((cAliasSe1)->E1_TIPO$MVABATIM+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT+"/"+MVI2ABT .Or. lExclui,(cAliasSe1)->(E1_VALOR+E1_ACRESC-E1_DECRESC)+nJuros+nMulta,(cAliasSe1)->(E1_SALDO+E1_SDACRES-E1_SDDECRE)+nJuros + nMulta) // + If( lDescISS,(cAliasSe1)->E1_ISS,0)	

		//Calculo de Juros e Multas: SIGALOJA x SIGAFIN  - Final
		
		If lTodos .Or. cChaveLbn == Nil
			cChaveLbn := "FAT" + SE1->(xFilial("SE1")+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
		Endif
		If (lTodos .And. SE1->(SimpleLock())) .Or. !lTodos
			IF (cAliasSe1)->E1_OK == cMarca
				// Desmarcando
				If (cAliasSe1)->(FieldPos("RECNO")) > 0
					nRecSe1 := (cAliasSe1)->RECNO
				Else
					nRecSe1 := (cAliasSe1)->(Recno())
				Endif	
				nAscan := Ascan(aMark, nRecSe1)
				If nAscan > 0
					aDel(aMark,nAscan)
					aSize(aMark,Len(aMark)-1)
				Endif
				nAscan := Ascan(aChaveLbn, cChaveLbn )
				If nAscan > 0
					se1->(msRUnlock(nRecSe1))   //Libera o Simplelock
				Endif
				RecLock(cAliasSe1)
				(cAliasSe1)->E1_OK := "  "
				(cAliasSe1)->(MsUnlock())
				If (cAliasSe1)->E1_TIPO $ MVABATIM+"/"+MV_CRNEG+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT+"/"+MVI2ABT
					nValor 	:= If(lExclui,nValor-nValorFat,nValor + nValorFat)
					nValCruz := If(lExclui,	nValCruz - (cAliasSe1)->E1_VLCRUZ-Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2),;
													nValCruz + (cAliasSe1)->E1_VLCRUZ+Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2))
					nVARURV 	:= If(lExclui,nVarUrv - (cAliasSe1)->E1_VARURV,nVarUrv + (cAliasSe1)->E1_VARURV)
					nVlrAtu 	:= If(lExclui,nVlrAtu - (cAliasSe1)->E1_VLRREAL,nVlrAtu + (cAliasSe1)->E1_VLRREAL)  
					nQtdTit--
					nTotExcluido := nTotExcluido + If(!lExclui,nValorFat,0)
				Else
					nValor 	:= If(lExclui,nValor + nValorFat,nValor - nValorFat)
					nValCruz := If(lExclui,	nValCruz + (cAliasSe1)->E1_VLCRUZ+Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2),;
													nValCruz - (cAliasSe1)->E1_VLCRUZ-Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2))
					nVARURV 	:= If(lExclui,nVarUrv + (cAliasSe1)->E1_VARURV,nVarUrv - (cAliasSe1)->E1_VARURV)
					nVlrAtu 	:= If(lExclui,nVlrAtu + (cAliasSe1)->E1_VLRREAL,nVlrAtu - (cAliasSe1)->E1_VLRREAL)  
					nQtdTit--
					nTotExcluido := nTotExcluido - If(lExclui,nValorFat,0)
				Endif
			Else
				// Marcando
				If (cAliasSe1)->(FieldPos("RECNO")) > 0
					nRecSe1 := (cAliasSe1)->RECNO
				Else
					nRecSe1 := (cAliasSe1)->(Recno())
				Endif	
				If Ascan(aChaveLbn, cChaveLbn) == 0
					Aadd(aChaveLbn,cChaveLbn)
				Endif	
				If Ascan(aMark, nRecSe1) == 0
					Aadd(aMark,nRecSe1)
				Endif
				RecLock(cAliasSe1)
				(cAliasSe1)->E1_OK := cMarca
				(cAliasSe1)->E1_DESCONT := nDescont 				
				(cAliasSe1)->(MsUnlock())
				If (cAliasSe1)->E1_TIPO $ MVABATIM+"/"+MV_CRNEG+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT+"/"+MVI2ABT
					nTotExcluido := nTotExcluido - nValorFat
					nValor 	:= If(lExclui,nValor+nValorFat,nValor - nValorFat)
					nValCruz := If(lExclui,	nValCruz + (cAliasSe1)->E1_VLCRUZ+Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2),;
													nValCruz - (cAliasSe1)->E1_VLCRUZ-Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2))
					nVARURV 	:= If(lExclui,nVarUrv + (cAliasSe1)->E1_VARURV,nVarUrv - (cAliasSe1)->E1_VARURV)
					nVlrAtu 	:= If(lExclui,nVlrAtu + (cAliasSe1)->E1_VLRREAL,nVlrAtu - (cAliasSe1)->E1_VLRREAL)  
					nQtdTit  := If(lExclui,nQtdTit-1,nQtdTit+1)
				Else
					nTotExcluido := nTotExcluido + nValorFat
					nValor 	:= If(lExclui,nValor - nValorFat,nValor + nValorFat)
					nValCruz := If(lExclui,	nValCruz - (cAliasSe1)->E1_VLCRUZ-Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2),;
													nValCruz + (cAliasSe1)->E1_VLCRUZ+Round(NoRound(xMoeda(E1_SDACRES-E1_SDDECRE,E1_MOEDA,1,E1_EMISSAO,3),3),2))
					nVARURV 	:= If(lExclui,nVarUrv - (cAliasSe1)->E1_VARURV,nVarUrv + (cAliasSe1)->E1_VARURV)
					nVlrAtu 	:= If(lExclui,nVlrAtu - (cAliasSe1)->E1_VLRREAL,nVlrAtu + (cAliasSe1)->E1_VLRREAL)  
					nQtdTit  := If(lExclui,nQtdTit-1,nQtdTit+1)
				Endif
			Endif
		Endif	
		If lTodos
			(cAliasSe1)->(dbSkip())
		Else
			// Localiza o titulo de abatimento e inverte a marca dele tambem
			If !(cAliasSe1)->E1_TIPO $ MVABATIM+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT+"/"+MVI2ABT
				cChaveLbn := "FAT" + (cAliasSe1)->(xFilial("SE1")+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
				nReg := (cAliasSe1)->(Recno())
				#IFNDEF TOP
					(cAliasSe1)->(DbSetOrder(2))
					If (cAliasSe1)->(dbSeek(xFilial("SE1")+(cAliasSe1)->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)))
						cTitAnt := (cAliasSe1)->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)
						While (cAliasSe1)->(!Eof()) .And. cTitAnt == (cAliasSe1)->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)
							If !(cAliasSe1)->E1_TIPO $ MVABATIM+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT+"/"+MVI2ABT
								(cAliasSe1)->(dbSkip())
								Loop
							Endif
							(cAliasSe1)->(DbSetOrder(nOrderSe1))
							// Verifica se o registro nao esta sendo utilizado em outro terminal
							If SE1->(SimpleLock())
							   If Ascan(aChaveLbn, cChaveLbn) == 0
									Aadd(aChaveLbn,cChaveLbn)
								Endif	
							   Fa280Inverte(cAliasSe1,cMarca,oValor,oQtdTit,lTodos,oMark,@nValor,@nTotExcluido,lExclui,.T.,aChaveLbn,cChaveLbn,@nValCruz,oValorFat)
							Else
								IW_MsgBox(STR0071,STR0061,"STOP") //"Este titulo está sendo utilizado em outro terminal, não pode ser utilizado na fatura"###"Atenção"
							Endif	
							(cAliasSe1)->(dbSkip())
						End	
					Endif	
				#ELSE
					If Left((cAliasSe1)->(IndexKey()),57) != "E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA"
						(cAliasSe1)->(DbSetOrder(1))
					Endif	
					If (cAliasSe1)->(MsSeek(xFilial("SE1")+(cAliasSe1)->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)))
					   	cTitAnt := (cAliasSe1)->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)   
						cParcela:=(cAliasSe1)->E1_PARCELA
						cTitpai:=SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) 
						
						If lTitpaiSE1
		 					bWhTit  := {||(cAliasSe1)->(!Eof()) .And. cTitAnt == (cAliasSe1)->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)}  
	  					Endif

						While Eval(bWhTit) 
										
							If lTitpaiSE1 .and. !Empty((cAliasSe1)->E1_TITPAI)
								If (cAliasSe1)->E1_TITPAI <> cTitpai
							   		(cAliasSe1)->(dbSkip())
							   		Loop
						   		Endif
						  	Elseif lTitpaiSE1 .and. (cAliasSe1)->E1_PARCELA <> cParcela
						   			(cAliasSe1)->(dbSkip())
							   		Loop
						  	Endif
							If !(cAliasSe1)->E1_TIPO $ MVABATIM+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT+"/"+MVI2ABT
								(cAliasSe1)->(dbSkip())
								Loop
							Endif
							If (cAliasSe1)->(FieldPos("RECNO")) > 0
								DbSelectArea("SE1")
								MsGoto((cAliasSe1)->RECNO)
								DbSelectArea(cAliasSe1)
							Endif	
							// Verifica se o registro nao esta sendo utilizado em outro terminal
  							If SE1->(SimpleLock())
								If Ascan(aChaveLbn, cChaveLbn) == 0
									Aadd(aChaveLbn,cChaveLbn)
								Endif
							   Fa280Inverte(cAliasSe1,cMarca,oValor,oQtdTit,lTodos,oMark,@nValor,@nTotExcluido,lExclui,.T.,aChaveLbn,cChaveLbn,@nValCruz,oValorFat)
							Else
								IW_MsgBox(STR0071,STR0061,"STOP") //"Este titulo está sendo utilizado em outro terminal, não pode ser utilizado na fatura"###"Atenção"
							Endif	
							(cAliasSe1)->(DbSkip())
						End	
					Endif	
				#ENDIF
				(cAliasSe1)->(DbSetOrder(nOrderSe1))
				(cAliasSe1)->(dbGoto(nReg))
			Endif	
			Exit	
		Endif
	Enddo
	If oValorFat <> NIL
		oValorFat:Refresh()
	EndIf
	oValor:Refresh()
	oQtdTit:Refresh()
	If lTodos
		(cAliasSe1)->(dbGoto(nReg))
		oMark:oBrowse:Refresh(.t.)
	Endif	
EndIf
Return Nil


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa280ValOK³ Autor ³ Mauricio Pequim Junior³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o valor da fatura ‚ v lido (maior que zero)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa280ValOK() 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa280ValOK(nValFatura)
Default nValFatura := nValor

IF nValFatura <= 0
	Help(" ",1,"VLFATNEG")
	Return .F.
Endif
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa280Soma ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 27/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o valor da fatura ‚ o mesmo dos tit. marcados  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa280Soma() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa280Soma()

IF Str(nValorF,16,2) != Str(nValor,16,2) .and. nValorF != 0
	Help(" ",1,"VALFAT")
	Return .F.
Endif
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa280Val	³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 27/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pede que se digite o valor correto da fatura 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa280Val(ExpO1)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa280Val(oValorFat)

LOCAL oDlg
LOCAL nOpca := 0

DEFINE MSDIALOG oDlg FROM 10, 5 TO 17, 33 TITLE STR0052 //"Informe valor correto da Fatura"
@	.3,1 TO 2.3,12 OF oDlg
@	1.0,2 	Say STR0047 //"Valor : "
@	1.0,4.5	MSGET nValorF Picture "@E 999,999,999.99"
DEFINE SBUTTON FROM 034,042	TYPE 1 ACTION (nOpca := 1,If(!Empty(nValorF),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
DEFINE SBUTTON FROM 034,069.1 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg
oValorFat:Refresh()

Return .F.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa280PedCd³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 27/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pede que se digite a condicao de pagamento				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fa280PedCd(ExpO1) 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa280PedCd()

LOCAL oDlg
LOCAL nOpca := 0
LOCAL cCond := Space(3)

DEFINE MSDIALOG oDlg FROM 10, 5 TO 17, 33 TITLE STR0049 //"Informe Condi‡„o de Pagamento"
@	1.0,2 	Say STR0050 //"Condi‡„o: "
@	1.0,5.5	MSGET cCond F3 "SE4" Picture "!!!" Valid ExistCpo("SE4",cCond) .And.;
																	  Fa290Cond(cCond)
@	.3,1 TO 2.3,11.9 OF oDlg

DEFINE SBUTTON FROM 034,069.1	TYPE 1 ACTION (nOpca := 1,If(	!Empty(cCond)	.And. ;
															ExistCpo("SE4",cCond) 			.And. ;
															Fa290Cond(cCond),oDlg:End(),nOpca:=0)) ;
												 ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

Return If(nOpca=0,"   ",cCond)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa280LinOk³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 27/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Confere se a linha digitada esta OK 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fa280LinOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FuncTion Fa280LinOk()
Local lRet := .T.
Local nX, lDuplicado := .F.
Local nPosPrefixo	:= Ascan(aHeader, {|e| Alltrim(e[2]) = "E1_PREFIXO"} )
Local nPosNum		:= Ascan(aHeader, {|e| Alltrim(e[2]) = "E1_NUM"} )
Local nPosParcela	:= Ascan(aHeader, {|e| Alltrim(e[2]) = "E1_PARCELA"} )
Local nPosTipo		:= Ascan(aHeader, {|e| Alltrim(e[2]) = "E1_TIPO"} )
Local nPosValor	:= Ascan(aHeader, {|e| Alltrim(e[2]) = "E1_VLCRUZ"} )

// Se a linha nao estiver deletada e o prefixo foi alterado
IF !(GdDeleted( n, aHeader, aCols)) .And. nPosPrefixo > 0 .And. aCols[n][nPosPrefixo] != cPrefix
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permite alterar PREFIXO !                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Help(" ",1,"IGUALPREF")
	lRet := .F.
Endif
// Se a linha nao estiver deletada e o TIPO foi alterado
IF !(GdDeleted( n, aHeader, aCols)) .and. nPosTipo > 0 .And. aCols[n][nPosTipo] != cTipo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permite alterar PREFIXO !                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Help(" ",1,"IGUALTIPO",,STR0057,1,0)	//"Nao e permitida alteracao do tipo do titulo."+CHR(13)+"Deve-se manter o tipo definido no inicio da rotina")
	lRet := .F.
Endif
// Se a linha nao estiver deletada e o NUMERO foi alterado
IF !(GdDeleted( n, aHeader, aCols)) .and. nPosNum > 0 .And. aCols[n][nPosNum] != cFatura
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permite alterar NUMERO !                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Help(" ",1,"IGUALNUM",,STR0058+CHR(13)+STR0059	,1,0)	 //"Nao e permitida alteracao do numero do titulo."###"Deve-se manter o numero definido no inicio da rotina"
	lRet := .F.
Endif
// Se o usuario informa o numero da fatura, valida a sua existencia
If nPosNum > 0
	// Pesquisa por titulos ja cadastrados
	For nX := 1 To Len(aCols)
		// Se encontrou um titulo igual ao ja cadastrado, avisa e nao permite continuar
		If !(GdDeleted( n, aHeader, aCols)) .And.;
			aCols[nX][nPosPrefixo]+aCols[nX][nPosNum]+aCols[nX][nPosParcela]+aCols[nX][nPosTipo] == ;
			aCols[n][nPosPrefixo]+aCols[nX][nPosNum]+aCols[n][nPosParcela]+aCols[n][nPosTipo] .And. nX != n						
			lDuplicado := .T.
			Exit
		Endif	
	Next
Endif	
// Se encontrou um titulo igual ao ja cadastrado, avisa e nao permite continuar
If !(GdDeleted( n, aHeader, aCols)) .And. lDuplicado
	lRet := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permite duplicar o numero !                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Help(" ",1,"A280EXIST")
Endif
// Se passou por todas as validacoes, valida o valor
If lRet .And. !(GdDeleted( n, aHeader, aCols))
	lRet := NaoVazio(aCols[n][nPosValor])
Endif	
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa280TudOK³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 27/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se aCols esta preenchida corretamente			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fa280TudOk(ExpO1) 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa280TudOk()
LOCAL nX, nValTot := 0
LOCAL lFa280Tok := Existblock("FA280TOK")
LOCAL lRet := .T.
Local nPosValor	:= Ascan(aHeader, {|e| Alltrim(e[2]) = "E1_VLCRUZ"} )

For nx:=1 To Len(aCols)
	If !(GdDeleted( nx, aHeader, aCols))
		nValTot += aCols[nx][nPosValor]
	Endif
Next nx

If nModulo == 43 // Modulo de Transporte (TMS)
	IF Str(nValCruz,16,2) != Str(nValTot,16,2)
		Help(" ",1,"VALFAT1",,STR0060 + Transform(nValCruz,"@E 99,999,999,999.99")+chr(13)+; //"Valor das notas "
									  STR0061 + Transform(nValTot,"@E 99,999,999,999.99"),4,0) //"Valor da fatura  "
		lRet := .F.
	Endif                                      
Else	
	IF Str(nValor,16,2) != Str(nValTot,16,2)
		Help(" ",1,"VALFAT1",,STR0060 + Transform(nValor,"@E 99,999,999,999.99")+chr(13)+; //"Valor das notas "
									  STR0061 + Transform(nValTot,"@E 99,999,999,999.99"),4,0) //"Valor da fatura  "
		lRet := .F.
	Endif
EndIf
If lFa280TOk .and. lRet
	If !(Execblock("FA280TOK",.F.,.F.))
		lRet := .F.
	Endif
Endif
oValTot:Refresh()
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa280AtuVl³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 27/11/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza valor da fatura na tela 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fa280AtuVl()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FuncTion Fa280AtuVl(lVldCampo)
LOCAL nx
Local nPosValor	:= Ascan(aHeader, {|e| Alltrim(e[2]) = "E1_VLCRUZ"} )
DEFAULT lVldCampo := .T.
nValTot := 0
For nx:=1 To Len(aCols)
	If !GdDeleted(nx)
		If nx = n .And. lVldCampo
			nValTot+= &(ReadVar())
		Else	
			nValTot+= aCols[nx][nPosValor]
		Endif
	Endif
Next

oValTot:Refresh()
Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FA280Tipo ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 19/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa o Tipo do titulo informado 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA280Tipo() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA280Tipo(cTipoDoc)
LOCAL lRetorna := .T.
Local cArea := Alias()

If !Empty(cTipoDoc)
	dbSelectArea("SX5")
	If !dbSeek(cFilial+"05"+cTipoDoc)
		Help(" ",1,"E1_TIPO")
		lRetorna := .F.
	Elseif !NewTipCart(cTipoDoc,"1")
		Help(" ",1,"TIPOCART")
		lRetorna := .F.
	Else
		If cTipoDoc $ MVPAGANT+"/"+MV_CPNEG
			Help(" ",1,"E1_TIPO")
			lRetorna := .F.
		ElseIf cTipoDoc $ MVRECANT+"/"+MVTAXA+"/"+MV_CRNEG+"/"+MVABATIM+"/"+MVISABT+"/"+MVI2ABT
			Help(" ",1,"TIPOFAT")
			lRetorna := .F.
		Endif
	Endif
Else
	Help(" ",1,"TIPOFAT")
	lRetorna := .F.
Endif

dbSelectArea(cArea)
Return lRetorna

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FA280Baixa³ Autor ³ Deny B. de Mendonca   ³ Data ³ 29/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Baixa o Titulo posicionado       						 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA280Baixa()												 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero da Fatura para Baixa do SE1                 ³±±
±±³          ³ ExpC2 = Prefixo da Fatura para baixa do SE1                ³±±
±±³          ³ ExpC3 = Tipo da Fatura para Baixa do SE1                   ³±±
±±³          ³ ExpD4 = Data da Baixa para SE1                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280													  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA280Baixa( cAliasSe1,cNumFat,cPrefat,cTipoFat,dDtbaixa,nCondLoja,;
                      lElimResid,nJur280,nDesc280,nValCorr,aPccBxCR,lAtuSldNat,nMul280,aDadosIr,cTitpai, lAutomato)
Local nAscan
Local nValorFat
Local aArea			:= GetArea()
Local aAreaSa1		:= SA1->(GetArea())
Local nAbatimentos	:= 0
Local cImpostos		:= Fa280VerImp(cNat)
Local cKeySE1			:= ""
Local cChaveSE1		:= ""
Local aAreaATU		:= {}
Local aMultSEV		:= {}
Local lMultNat		:= .F.
Local aPcc           := {}
Local aAlt	  := {}

//Controle de abatimento
Local lTitpaiSE1 := .T.
Local nOrdTitPai:=0
Local bWhile 		:= {|| !EOF() .And. E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA == cKeySE1}

//Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default))
Local lPccBxCr		:= FPccBxCr()

//639.04 Base Impostos diferenciada
Local lBaseImp		:= F040BSIMP(2)

//Controla IRPJ na baixa
Local lIrPjBxCr		:= FIrPjBxCr()
Local lFunname		:= FunName() == "FINA280"
Local lFINA740		:= FunName() == "FINA740"

Default dDtbaixa	:= dDatabase
Default lElimResid	:= .T.
Default nJur280		:= 0
Default nDesc280	:= 0
Default nValCorr	:= 0
Default aPccBxCR	:= {0,0,0,0}			//pcc aqui
Default lAtuSldNat  := .T.
Default cTitpai		:= ""
Default nMul280		:= 0    //Calculo de Juros e Multas: SIGALOJA x SIGAFIN 
Default aDadosIR    := {0,0} //aDadosIR[1] - valor do IRRF  / aDadosIR[2] - Base de calculo do IR
Default lAutomato		:= .F.

	// Efetua abertura do __SE1 (espelho do SE1) para deletar os abatimentos do titulo
	// principal que não foram selecionados no filtro.
	If Select("__SE1") == 0
		SomaAbat("","","","R")
	Endif	

	//Essa rotina pode ser chamada por outros modulos.
	//Garanto que o grupo de perguntas esta OK
	Pergunte("AFI280",.F.)
	
	// Verifica a matriz que contem os valores a faturar, pois no FINA281 o usuario
	// podera alterar o valor a faturar do titulo, nao sendo necessariamente o saldo total
	If Type("aVlrFat") != "A"
		aVlrFat	:= {{0, 0}} // Valores a faturar
	Endif

	// Se a pergunta "Considera lojas" for igual a nao, deve-se atualizar o saldo das 
	// duplicadas das diferentes lojas
	If nCondLoja == 2
		SA1->(MsSeek(xFilial("SA1")+(cAliasSe1)->(E1_CLIENTE+E1_LOJA)))
		SA1->(AtuSalDup("-",(cAliasSe1)->E1_SALDO,(cAliasSe1)->E1_MOEDA,(cAliasSe1)->E1_TIPO,,(cAliasSe1)->E1_EMISSAO))
		SA1->(RestArea(aAreaSa1))
	Endif	

	If (cAliasSe1)->(FieldPos("RECNO")) > 0
		DbSelectArea("SE1")
		MsGoto((cAliasSe1)->RECNO)
	Endif	

	nAscan := Ascan(aVlrFat,{|e| e[1] == (cAliasSe1)->(Recno())})

	// Soma os abatimentos do titulo principal
	If !(cAliasSe1)->E1_TIPO$MVABATIM+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT+"/"+MVI2ABT
		nAbatimentos := SomaAbat((cAliasSe1)->E1_PREFIXO,(cAliasSe1)->E1_NUM,(cAliasSe1)->E1_PARCELA,"R",1,dDataBase,(cAliasSe1)->E1_CLIENTE,(cAliasSe1)->E1_LOJA,,, (cAliasSe1)->E1_TIPO)
	Endif	

	If nAscan > 0 
		nValorFat := aVlrFat[nAscan][2]
	Else
		nValorFat := If((cAliasSe1)->E1_TIPO$MVABATIM+"/"+MVINABT+"/"+MVIRABT+"/"+MVISABT+"/"+MVI2ABT,(cAliasSe1)->E1_VALOR,(cAliasSe1)->(E1_SALDO+E1_SDACRES-E1_SDDECRE-nAbatimentos-nDesc280))
	EndIf

	//Tratamento PCC na Baixa CR - pcc aqui
	//Proporcionalizo o valor baixado do principal com o valor do tiutlo.
	//Em seguida proporcionaliza os impostos calculados na emissao e 
	//que serao repassados as parcelas geradas da fatura
	If lPccBxCr .or. lBaseImp
		nPropPcc	:= (nValorFat+nAbatimentos)/SE1->E1_VALOR
		If SE1->E1_TIPO # MVRECANT .And. Empty(SE1->E1_NUMBOR)
		  If dDataBase < dLastPcc
			  aPccBxCr[1]	+= SE1->E1_PIS * nPropPcc
			  aPccBxCr[2]	+=	SE1->E1_COFINS * nPropPcc
			  aPccBxCr[3]	+= SE1->E1_CSLL * nPropPcc
		  Else
			  aPcc	:= newMinPcc(dDataBase, nValorFat,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
			  aPccBxCr[1]	+= aPcc[2]
			  aPccBxCr[2]	+= aPcc[3]
			  aPccBxCr[3]	+= aPcc[4]
		  EndIf
		Endif	

		//639.04 Base Impostos diferenciada
		If SE1->(E1_PIS+E1_COFINS+E1_CSLL) > 0
			aPccBxCr[4] += If (	lBaseImp .and. SE1->E1_BASEIRF > 0 ,SE1->E1_BASEIRF, SE1->E1_VALOR) * nPropPcc
		Endif

	Endif         
   	//Tratamento IR na Baixa CR 
	//Proporcionalizo o valor baixado do principal com o valor do tiutlo.
	//Em seguida proporcionaliza os impostos calculados na emissao e 
	//que serao repassados as parcelas geradas da fatura
	If lIrPjBxCr .or. lBaseImp
		nPropIr		:= (nValorFat-nJur280+nDesc280+nAbatimentos)/SE1->E1_VALOR
		aDadosIR[1]	+= SE1->E1_IRRF * nPropIR
	
		//639.04 Base Impostos diferenciada
		If SE1->E1_IRRF > 0
			aDadosIR[2] += If (	lBaseImp .and. SE1->E1_BASEIRF > 0 ,SE1->E1_BASEIRF, SE1->E1_VALOR) * nPropIR
		Endif

   	Endif
	RecLock("SE1",.F.)
	SE1->E1_BAIXA	:= dDtbaixa
	
	If lElimResid .And. !lFunname // Elimina residuos
		SE1->E1_VALLIQ	:= (SE1->E1_SALDO + IIF(lFINA740 .And. SE1->E1_SDACRES > 0 .And. nJur280 > 0, 0, SE1->E1_SDACRES) - SE1->E1_SDDECRE - nAbatimentos + nJur280) - nDesc280
		SE1->E1_SALDO 	:= 0
	Else	
		SE1->E1_VALLIQ	:= nValorFat
		SE1->E1_SALDO		:= If(nAscan > 0, SE1->E1_SALDO - nValorFat, 0)
	Endif	
	
	SE1->E1_MOVIMEN	:= dDtbaixa
	SE1->E1_FATURA 	:= cNumFat
	SE1->E1_FATPREF := cPrefat
	SE1->E1_TIPOFAT := cTipofat
	SE1->E1_DTFATUR := dDtbaixa
	SE1->E1_STATUS 	:= Iif(SE1->E1_SALDO>0.01,"A","B")
	SE1->E1_FLAGFAT	:= "S"
	SE1->E1_SDDECRE	:= 0
	SE1->E1_SDACRES	:= 0
	SE1->E1_JUROS	:= nJur280
	SE1->E1_DESCONT	:= nDesc280 
	SE1->E1_CORREC	:= nValCorr 
	//Valor da Multa, segundo regra de calculo de juros e multas do financeiro 
	//Calculo de Juros e Multas: SIGALOJA x SIGAFIN 
	SE1->E1_MULTA	:= nMul280	

	MsUnlock()
	
	lMultNat :=  SE1->E1_MULTNAT == "1"

	If lAtuSldNat .AND. !(SE1->E1_TIPO $ MVABATIM)
		
		// Multiplas Naturezas
		If lMultNat
			aAreaATU := GetArea()
			cChaveSE1 := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
			DbSelectArea("SEV")
			SEV->( DbSetOrder(1) )
			SEV->( MsSeek( xFilial("SEV") + cChaveSE1 ) )
			While SEV->(!Eof()) .And. xFilial("SEV") + cChaveSE1 == SEV->(EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA)
	
				// Caso Multiplas Naturezas do Contas a Pagar
				If SEV->EV_RECPAG != "R"
					SEV->( DbSkip() )
					Loop
				EndIf
	
				// Tira o saldo do vencimento programado do titulo
				AtuSldNat(SEV->EV_NATUREZ, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SEV->EV_VALOR, xMoeda(SEV->EV_VALOR, SE1->E1_MOEDA, 1),"-",,FunName(),"SE1", SE1->(Recno()),0)
				SEV->( DbSkip() )
			EndDo
			RestArea(aAreaATU)
		Else
			// Tira o saldo do vencimento programado do titulo
			AtuSldNat(SE1->E1_NATUREZ, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SE1->E1_VALOR, xMoeda(SE1->E1_VALOR, SE1->E1_MOEDA, 1),"-",,FunName(),"SE1", SE1->(Recno()),0)
		EndIf
		
	Endif	

	///numbor			
	aAlt := {}
    aadd( aAlt,{ STR0088,'','','',STR0089 +  Alltrim(Transform(SE1->E1_VALOR,PesqPict("SE1","E1_VALOR"))) })   
    ///chamada da Função que cria o Histórico de Cobrança
	FinaCONC(aAlt)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao Especifica do Modulo SIGAPLS para atualizar Status de Guias Compradas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PL090TITCP(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,"1")

	//Baixo todos os abatimentos do titulo independente de terem sido
	//marcados. 
	If nAbatimentos > 0   
		cKeySE1 := xFilial("SE1")+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)
		dbSelectArea("__SE1") 
		__SE1->(dbSetOrder(2))
		__SE1->(dbSeek(cKeySE1)) 
		If lTitpaiSE1
	 		If (nOrdTitPai:= OrdTitpai()) > 0
				__SE1->(DbSetOrder(nOrdTitPai))
				If	DbSeek(xFilial("SE1")+cTitpai)    
					bWhile  := {|| !Eof() .And. Alltrim((cAliasSe1)->E1_TITPAI) == Alltrim(cTitpai)}  
					dbSelectArea("__SE1")
				Else  
		  			__SE1->(dbSetOrder(2))
		 			__SE1->(dbSeek(cKeySE1))  
		 		Endif
		 	Endif
	 	Endif

		While Eval(bWhile) 
			If lTitpaiSE1
				If !Empty(E1_TITPAI) .and. (Alltrim(E1_TITPAI) != Alltrim(cTitpai))
					DbSkip()
					Loop
				EndIf
			EndIf 
			IF E1_TIPO $ cImpostos + MVABATIM
				RecLock("__SE1")
				Replace E1_SALDO		With 0
				Replace E1_BAIXA		With dDataBase
				Replace E1_MOVIMEN	With dDtbaixa
				Replace E1_STATUS		With "B"
				Replace E1_SDACRES	With 0
				Replace E1_SDDECRE	With 0
				Replace E1_FATURA 	With cNumFat
				Replace E1_FATPREF 	With cPrefat
				Replace E1_TIPOFAT 	With cTipofat
				Replace E1_DTFATUR 	With dDtbaixa

				lMultNat :=  SE1->E1_MULTNAT == "1"
				If lAtuSldNat
					// Multiplas Naturezas
					If lMultNat
						aAreaATU := GetArea()
						cChaveSE1 := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
						DbSelectArea("SEV")
						SEV->( DbSetOrder(1) )
						SEV->( MsSeek( xFilial("SEV") + cChaveSE1 ) )
						While SEV->(!Eof()) .And. xFilial("SEV") + cChaveSE1 == SEV->(EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA)
				
							// Caso Multiplas Naturezas do Contas a Pagar
							If SEV->EV_RECPAG != "R"
								SEV->( DbSkip() )
								Loop
							EndIf
				
							// Tira o saldo do vencimento programado do titulo
							AtuSldNat(SEV->EV_NATUREZ, E1_VENCREA, E1_MOEDA, "2", "R", SEV->EV_VALOR, xMoeda(SEV->EV_VALOR, E1_MOEDA, 1),"+",,FunName(),"SE1", SE1->(Recno()),0)
							SEV->( DbSkip() )
						EndDo
						RestArea(aAreaATU)
					Else
						// Tira o saldo do vencimento programado do titulo
						AtuSldNat(E1_NATUREZ, E1_VENCREA, E1_MOEDA, "2", "R", E1_VALOR, xMoeda(E1_VALOR, E1_MOEDA, 1),"+",,FunName(),"SE1", SE1->(Recno()),0)
					EndIf
				Endif	
				MsUnLock()
			EndIF
			dbSkip()
		Enddo
		
		__SE1->(dbSetOrder(1))
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para manipular/gravar dados nos titulos que originaram a fatura.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF ExistBlock("F280ORI")
		ExecBlock("F280ORI",.F.,.F.)
	Endif

	SE1->(RestArea(aArea))
	RestArea(aArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA280Movim³ Autor ³ Deny B. de Mendonca   ³ Data ³ 29/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Baixa o Titulo posicionado                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FA280Movim()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Filial para gravacao do SE5              ³±±
±±³          ³ ExpC2 = Numero da Fatura para gravacao do SE5              ³±±
±±³          ³ ExpD3 = Data do Movimento para gravacao do SE5             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA280Movim( cAliasSe1,cFilSE5,cFatSE5,dDtMovSE5,cRecPag,cTipoDoc,cHistor,cMotBx,cFatura,cFatPref,;
                      nJur280,nDesc280,nValCorr,cArquivo,nTotal,nHdlPrv,lUsaFlag,aFlagCTB,nValProces,aRastroOri, nMul280)
                      
Local aTipoDoc		:= {}
Local nA			:= 0
Local nTamSeq		:= TamSX3("E5_SEQ")[1]
Local cSequencia	:= Replicate("0",nTamSeq)
Local aArea			:= GetArea()
Local bCampo
Local cTpDoc		:= ""
Local lAcreDecre	:= .F.
Local lFa280GrE5	:= ExistBlock("Fa280GrE5")
Local nTxMoeda		:= 0
Local lPadrao520	:= .f.
Local lRastro		:= FVerRstFin()
Local lPccBxCr		:= SuperGetMV( "MV_BR10925" , .T. /*lHelp*/, .F. /*cPadrao*/) == "1" // PCC NA BAIXA 
/*
 * Variáveis Necessárias para Gravação dos Movimentos Bancários
 */ 
Local oModelMov	:= NIL 
Local oSubFK1	:= Nil
Local oSubFK6	:= Nil
Local oSubFKA	:= Nil
Local cLog		:= ""
Local lRet		:= .T.
Local cCamposE5	:= ""
Local cChaveFKA	:= ''
Local cChaveFK7	:= ''
Local nValAcess	:= 0
Local nValMoed2 := 0
Local nAcresc	:= 0 
Local nDecresc	:= 0

Private VALOR5	:= 0
Private VALOR6	:= 0
Private VALOR7	:= 0

Default dDtMovSE5	:= dDatabase
Default cRecPag		:= "R"
Default cTipoDoc	:= "BA"
Default cHistor		:= STR0056+cFatSE5  // "Bx.p/Emiss.Fatura "
Default cMotBx		:= "FAT"
Default nJur280		:= 0
Default nDesc280	:= 0 
Default nValCorr	:= 0 
Default cArquivo	:= ""
Default nTotal		:= 0
Default nHdlPrv		:= 0
DEFAULT aFlagCTB 	:= {}
DEFAULT lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 
Default nMul280 	:= 0 	//Calculo de Juros e Multas: SIGALOJA x SIGAFIN 
Default aRastroOri	:= {}
Default nValProces	:= 0

//verifica se existem os campos de valores de acrescimo e decrescimo no SE5
lAcreDecre := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Localiza a sequencia da baixa ( CP,BA,VL,V2,LJ )  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTipoDoc := {"CP","BA","VL","V2"}

//Essa rotina pode ser chamada por outros modulos.
//Garanto que o grupo de perguntas esta OK
Pergunte("AFI280",.F.)

//Verificacao para contabilizacao on-line. (Apenas Baixas)
lPadrao520 := (mv_par04 == 1 .and. VerPadrao("520"))

SE5->(dbSetOrder(2))
For nA:= 1 to len(aTipoDoc)
	SE5->(dbSeek(cFilSE5 + aTipoDoc[nA] + (cAliasSe1)->E1_PREFIXO + (cAliasSe1)->E1_NUM + ;
	(cAliasSe1)->E1_PARCELA + (cAliasSe1)->E1_TIPO) )
	
	While		!SE5->(Eof())												.And. ;
				SE5->E5_FILIAL		== cFilSE5							.And. ;
				SE5->E5_TIPODOC	== aTipoDoc[nA]					.And. ;
				SE5->E5_PREFIXO	== (cAliasSe1)->E1_PREFIXO		.And. ;
				SE5->E5_NUMERO		== (cAliasSe1)->E1_NUM			.And. ;
				SE5->E5_PARCELA	== (cAliasSe1)->E1_PARCELA		.And. ;
				SE5->E5_TIPO		== (cAliasSe1)->E1_TIPO

		If ( SE5->E5_CLIFOR+SE5->E5_LOJA == (cAliasSE1)->E1_CLIENTE+(cAliasSE1)->E1_LOJA .And. SE5->E5_RECPAG=="R" )
			If PadL(AllTrim(cSequencia),nTamSeq,"0") < PadL(AllTrim(SE5->E5_SEQ),nTamSeq,"0")
				cSequencia := SE5->E5_SEQ
			Endif
		EndIf
		
		SE5->(dbSkip())
	EndDo
	
Next nA
If Len(AllTrim(cSequencia)) < nTamSeq
	cSequencia := PadL(AllTrim(cSequencia),nTamSeq,"0")
Endif
cSequencia := Soma1(cSequencia,nTamSeq)

oModelMov := FWLoadModel("FINM010") //Model de Baixa a Receber
oModelMov:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
oModelMov:Activate()
oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Informa se vai gravar SE5 ou não
oModelMov:SetValue( "MASTER", "NOVOPROC", .T. ) //Informa que a inclusão será feita com um novo número de processo

/*
 * Dados da tabela auxiliar com o código do título a receber (SE1)
 */
cChaveTit := 	(cAliasSe1)->E1_FILIAL + "|" +;
				(cAliasSe1)->E1_PREFIXO + "|" +;
				(cAliasSe1)->E1_NUM + "|" +;
				(cAliasSe1)->E1_PARCELA + "|" + ;
				(cAliasSe1)->E1_TIPO + "|" + ;
				(cAliasSe1)->E1_CLIENTE + "|" + ;
				(cAliasSe1)->E1_LOJA
				
cChaveFK7 := FINGRVFK7("SE1", cChaveTit)

/*
 * Dados da baixa a receber
 */
oSubFK1 := oModelMov:GetModel( "FK1DETAIL" )

/*
 * Dados da baixa a receber
 */
oSubFKA := oModelMov:GetModel( "FKADETAIL" )

/*
 * Dados dos Valores Acessórios (Juros, Multas, Acréscimo e Descréscimo)
 */
oSubFK6 := oModelMov:GetModel( "FK6DETAIL" )

For nA := 1 To 5

	// Atualiza a Movimentacao Bancaria
	If nA==1
		bCampo  := { || (cAliasSe1)->E1_VALLIQ } // Valor recebido total
		cTpDoc  := cTipoDoc
	Elseif nA==2
		bCampo  := { || nJur280 } // Valor dos juros
		cTpDoc  := "JR"
	Elseif nA==3
		bCampo  := { || nDesc280 } // Valor do desconto
		cTpDoc  :="DC"
	Elseif nA==4
		bCampo  := { || nValCorr } // Valor do desconto
		cTpDoc  :="CM"
	//Calculo de Juros e Multas: SIGALOJA x SIGAFIN  - Inicio
	ElseIf nA == 5
		bCampo  := { || nMul280} // Valor da Multa
		cTpDoc  :="MT"
	Endif  
	//Calculo de Juros e Multas: SIGALOJA x SIGAFIN  - Final
	nValAcess := Eval( bCampo )
	
	If (nValAcess != 0 .or. nA == 1) .And. If(nA == 4, (cAliasSe1)->E1_TXMOEDA == 0, .T.)

		If nA == 1
		
			nTxMoeda	:= If((cAliasSE1)->E1_TXMOEDA > 0, (cAliasSE1)->E1_TXMOEDA, RecMoeda(dDtMovSE5,(cAliasSE1)->E1_MOEDA))
		
			/*
			 * Movimento Principal
			 */
			If !EMPTY(cCamposE5)
				cCamposE5 += "|"
			EndIf
			nValMoed2 := If(nA <> 4,nValAcess,0)
			
			cCamposE5 += " { {'E5_DTDIGIT'	,STOD('" + DTOS(dDtMovSE5) + "')}"
			cCamposE5 += ",{'E5_DATA'		,STOD('" + DTOS(dDtMovSE5) + "')}"
			cCamposE5 += ",{'E5_PREFIXO'	,'" + (cAliasSe1)->E1_PREFIXO + "'}"
			cCamposE5 += ",{'E5_NUMERO'		,'" + (cAliasSe1)->E1_NUM + "'}"
			cCamposE5 += ",{'E5_PARCELA'	,'" + (cAliasSe1)->E1_PARCELA + "'}"
			cCamposE5 += ",{'E5_CLIFOR'		,'" + (cAliasSe1)->E1_CLIENTE + "'}"
			cCamposE5 += ",{'E5_CLIENTE'	,'" + (cAliasSe1)->E1_CLIENTE + "'}"
			cCamposE5 += ",{'E5_LOJA'		,'" + (cAliasSe1)->E1_LOJA + "'}"
			cCamposE5 += ",{'E5_BENEF'		,'" + (cAliasSe1)->E1_NOMCLI + "'}"
			cCamposE5 += ",{'E5_TIPO'		,'" + (cAliasSe1)->E1_TIPO + "'}"
			cCamposE5 += ",{'E5_VLMOED2'	,"  + CVALTOCHAR(nValMoed2) + "}"
			cCamposE5 += ",{'E5_DTDISPO'	,STOD('" + DTOS(dDtMovSE5) + "')}"
			cCamposE5 += ",{'E5_FATURA'		,'" + cFatura + "'}"
			cCamposE5 += ",{'E5_FATPREF'	,'" + cFatPref + "'}"

			If lAcredecre
				nAcresc		:= Round(NoRound(xMoeda(nJur280+nMul280,(cAliasSe1)->E1_MOEDA,1,dDtMovSE5,3),3),2)	//Calculo de Juros e Multas: SIGALOJA x SIGAFIN 
				nDecresc	:= Round(NoRound(xMoeda(nDesc280,(cAliasSe1)->E1_MOEDA,1,dDtMovSE5,3),3),2)
			Endif							

			cCamposE5 += ",{'E5_VLJUROS' , "+cValToChar(nJur280)+" }"
			cCamposE5 += ",{'E5_VLMULTA' , "+cValToChar(nMul280)+" }"
			cCamposE5 += ",{'E5_VLDESCO' , "+cValToChar(nDesc280)+" }"
			cCamposE5 += ",{'E5_VLACRES' , "+cValToChar(nAcresc)+" }"
			cCamposE5 += ",{'E5_VLDECRE' , "+cValToChar(nDecresc)+" }"

			cCamposE5 += "}"
			cChaveFKA := FWUUIDV4()
			
			If !oSubFKA:IsEmpty()
				oSubFKA:AddLine()
			EndIf
			oSubFKA:SetValue( "FKA_IDORIG"	, cChaveFKA )
			oSubFKA:SetValue( "FKA_TABORI"	, 'FK1')
			
			If !oSubFK1:IsEmpty()
				oSubFK1:AddLine()
			EndIf
			
			oSubFK1:SetValue( "FK1_FILIAL"	, FWxFilial("FK1") )
			oSubFK1:SetValue( "FK1_RECPAG"	, cRecPag )
			oSubFK1:SetValue( "FK1_HISTOR"	, Iif(nA <> 4,cHistor,STR0075 + cHistor) ) //#DEL Histórico sem STR?                             
			oSubFK1:SetValue( "FK1_DATA"	, dDtMovSE5 )            
			oSubFK1:SetValue( "FK1_VENCTO"	, dDtMovSE5 )
			oSubFK1:SetValue( "FK1_NATURE"	, (cAliasSe1)->E1_NATUREZ )
			oSubFK1:SetValue( "FK1_TPDOC"	, cTpDoc )
			oSubFK1:SetValue( "FK1_SEQ"		, cSequencia )
			oSubFK1:SetValue( "FK1_MOEDA"	, StrZero((cAliasSe1)->E1_MOEDA,2) )                             
			oSubFK1:SetValue( "FK1_VALOR"	, Iif(nA ==4, nValCorr, xMoeda(nValAcess, (cAliasSE1)->E1_MOEDA, 1, dDtMovSE5, 3, nTxMoeda)))
			oSubFK1:SetValue( "FK1_VLMOE2"	, (cAliasSe1)->E1_VALOR )
			oSubFK1:SetValue( "FK1_MOTBX"	, cMotBx )
			If !lUsaFlag
				oSubFK1:SetValue( "FK1_LA"		, "S" )
			EndIf                                                  
			oSubFK1:SetValue( "FK1_ORIGEM"	, FunName() )
			oSubFK1:SetValue( "FK1_IDDOC"	, cChaveFK7 )
			oSubFK1:SetValue( "FK1_FILORI"	, (cAliasSe1)->E1_FILORIG )
			oSubFK1:SetValue( "FK1_CCUSTO"	, (cAliasSe1)->E1_CCUSTO )
			oSubFK1:SetValue( "FK1_TXMOED"	, nTxMoeda )

		Else
			/*
			 * Adicionando valores acessórios (Multa, Desconto, Juros, Acréscimo, Decréscimo)
			 */
			If !oSubFK6:IsEmpty()
				//Inclui a quantidade de linhas necessárias
				oSubFK6:AddLine()		
			
				//Vai para linha criada
				oSubFK6:GoLine( oSubFK6:Length() )	
			Endif	
			oSubFK6:SetValue( 'FK6_TPDOC'	, cTpDoc )
			oSubFK6:SetValue( 'FK6_VALCAL'	, nValAcess )	
			oSubFK6:SetValue( 'FK6_VALMOV'	, nValAcess )
			oSubFK6:SetValue( 'FK6_RECPAG'	, cRecPag )
			oSubFK6:SetValue( "FK6_TABORI"  , "FK1" )
			oSubFK6:SetValue( "FK6_IDORIG"	, cChaveFKA)
			oSubFK6:SetValue( "FK6_HISTOR"	, cHistor)		
		EndIf			

		//Rastreamento - Geradores
		If lRastro
			aadd(aRastroOri,{	SE1->E1_FILIAL,;
									SE1->E1_PREFIXO,;
									SE1->E1_NUM,;
									SE1->E1_PARCELA,;
									SE1->E1_TIPO,;
									SE1->E1_CLIENTE,;
									SE1->E1_LOJA,;
									SE1->E1_VALLIQ } )

			nValProces += SE1->E1_VALLIQ
		Endif
	Endif
Next
/*
 * Valida as informações para efetuar a gravação dos dados do Modelo nas tabelas do banco de dados.
 */
 
 //Lipando o array aRecSe5 para conter somente o RECNO desta baixa.
FIM010CLRE5()

oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK5
If oModelMov:VldData()
	oModelMov:CommitData()
	aRecSE5 := FIM010RSE5()

	If lF280SE5
		aRecSe5 := aClone(aRecSE5)
		aAdd(aAuxSE5,aRecSE5[1])
	Endif 
	
	If lFa280GrE5			
		ExecBlock("Fa280GrE5",.F.,.F.)
	Endif

	If lPadrao520
		If nHdlPrv <= 0
			nHdlPrv := HeadProva(cLote,"FINA280",Substr(cUsuario,7,6),@cArquivo)
		Endif

		dbSelectArea("SE5")
		For nA := 1 to Len(aRecSE5)
			SE5->(dbGoTo(aRecSE5[nA]))
			If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
				aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
			Endif 
			
			If cPaisLoc == "BRA" .and. !lPccBxCr
				VALOR2 := SE1->E1_IRRF      
				VALOR3 := SE1->E1_PIS
				VALOR4 := SE1->E1_COFINS
				VALOR5 := SE1->E1_CSLL
				VALOR6 := SE1->E1_INSS
			Endif
			
			nTotal += DetProva( nHdlPrv, "520", "FINA280", cLote, /*nLinha*/, /*lExecuta*/,;
			                    /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
			                    /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
		Next
	Endif
Else
	lRet := .F.
	cLog := cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
	cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
	cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_MESSAGE])      	
    
    Help( ,,"M030VALID",,cLog, 1, 0 )	            
Endif		
oModelMov:DeActivate()
oModelMov:Destroy()
oModelMov := Nil
oSubFK1	:= Nil
oSubFK6	:= Nil
oSubFKA	:= Nil
RestArea( aArea )

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FA280GrFat³ Autor ³ Deny B. de Mendonca   ³ Data ³ 29/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava a Fatura no SE1            						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA280GrFat()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Cliente para Geracao da Fatura           ³±±
±±³          ³ ExpC2 = Codigo da Loja do Cliente para Geracao da Fatura   ³±±
±±³          ³ ExpC3 = Codigo do Cliente                                  ³±±
±±³          ³ ExpC4 = Loja do Cliente                                    ³±±
±±³          ³ ExpC5 = Numero da Fatura                                   ³±±
±±³          ³ ExpC6 = Prefixo da Fatura                                  ³±±
±±³          ³ ExpC7 = Parcela da Fatura                                  ³±±
±±³          ³ ExpC8 = Tipo da Fatura                                     ³±±
±±³          ³ ExpC9 = Vencimento da Parcela da Fatura                    ³±±
±±³          ³ ExpC10= Natureza da Fatura                                 ³±±
±±³          ³ ExpC11= Banco da Fatura                                    ³±±
±±³          ³ ExpN12= Valor da Duplicata                                 ³±±
±±³          ³ ExpN13= ValCruz                                            ³±±
±±³          ³ ExpN14= ValrURV                                            ³±±
±±³          ³ ExpN15= Moeda da Fatura                                    ³±±
±±³          ³ ExpN16= Registro do SE1                                    ³±±
±±³          ³ ExpC17= Codigo do lancamento Padronizado                   ³±±
±±³          ³ ExpN18= Valor Total da Fatura                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280												 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA280GrFat(cCliFat,cLojaFat,cCli,cLoja,cFatura,cPrefix,cParcela,cTipo,;
							dVencto,cNat,cBanco,nValDup,nValCruz,nVARURV,nMoedFat,nRegE1,;
							cPadrao,nTotal,lHead,cArquivo,nHdlPrv,dDatEmis,cPrograma,;
							cFilDeb, cSitFat, lConsLoja, nAcresc, nDecresc,nRecno,;
							nPisBxCr,nCofBxCr,nCslBxCr,nBaseImp,cIrBxCr)	//Pcc aqui
Local lPadrao
Local aArea	:= GetArea()
Local lPccBxCr		:= FPccBxCr()

//639.04 Base Impostos diferenciada
Local lBaseImp		:= F040BSIMP(2)
//Controla IRPJ na baixa
Local lIrPjBxCr		:= FIrPjBxCr()

Local lFA280_		:= ExistBlock("FA280")

Default dDatEmis 	:= dDataBase
Default cPrograma	:= "FINA280"
Default cFilDeb   	:= cFilAnt
Default cPadrao		:= ""
Default cSitFat 	:= "1"
Default lConsLoja 	:= (mv_par01 == 1)
Default nAcresc   	:= 0
Default nDecresc  	:= 0
Default nRecno		:= 0
Default nPisBxCr	:= 0		//pcc aqui
Default nCofBxCr	:= 0	
Default nCslBxCr	:= 0	
Default cIrBxCr		:= 0
Default nBaseImp	:= 0

dbSelectArea("SA1")
If Empty( cCliFat )
	dbSeek(cFilial+cCli+cLoja)
Else
	dbSeek(cFilial+cCliFat+cLojaFat)
Endif

// Se a pergunta "Considera lojas" for igual a nao, deve-se atualizar o saldo das 
// duplicadas das diferentes lojas
If ! lConsLoja
	SA1->(AtuSalDup("+",nValDup,nMoedFat,cTipo,,dDatEmis))
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Implanta‡„o da Fatura		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("SE1",.T.)
Replace E1_FILIAL	With xFilial("SE1")
Replace E1_NUM 	 	With cFatura
Replace E1_PARCELA	With cParcela
Replace E1_PREFIXO	With cPrefix
Replace E1_NATUREZ	With cNat
Replace E1_SITUACA	With "0"
Replace E1_VENCTO		With dVencto
Replace E1_VENCREA	With DataValida(E1_VENCTO,.T.)
Replace E1_VENCORI	With E1_VENCREA
Replace E1_EMISSAO	With dDatEmis
Replace E1_EMIS1		With dDatEmis
IF cPaisLoc<>"CHI"
	Replace E1_TIPO	 With cTipo
else
	Replace E1_TIPO	 With "LT"
endif
Replace E1_CLIENTE With IIF( Empty( cCliFat ), cCli, cCliFat )
Replace E1_LOJA    With IIF( Empty(cCliFat),cLoja,cLojaFat )
Replace E1_NOMCLI  With SA1->A1_NREDUZ
Replace E1_MOEDA   With nMoedFat
Replace E1_VALOR   With nValDup
Replace E1_SALDO   With nValDup
Replace E1_FATURA  With "NOTFAT"
Replace E1_VLCRUZ  With xMoeda(nValDup,nMoedFat,1)  // nValCruz
Replace E1_VARURV  With nVARURV
Replace E1_STATUS  With Iif(E1_SALDO>0.01,"A","B")
Replace E1_OCORREN With "01"
Replace E1_ORIGEM  With cPrograma
Replace E1_FILDEB  With If(Empty(SA1->A1_FILDEB), cFilAnt, SA1->A1_FILDEB)
Replace E1_FILORIG With cFilAnt
Replace E1_ACRESC  With nAcresc
Replace E1_DECRESC With nDecresc
Replace E1_SDACRES With nAcresc
Replace E1_SDDECRE With nDecresc
Replace E1_CREDIT  With SE1->E1_CREDIT
Replace E1_DEBITO  With SE1->E1_DEBITO
Replace E1_CCC     With SE1->E1_CCC
Replace E1_ITEMC   With SE1->E1_ITEMC
Replace E1_CLVLCR  With SE1->E1_CLVLCR
Replace E1_CCD     With SE1->E1_CCD
Replace E1_ITEMD   With SE1->E1_ITEMD
Replace E1_CLVLDB  With SE1->E1_CLVLDB

If ! Empty(cPadrao)
	lPadrao := VerPadrao(cPadrao)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Flag de Lancamento contabil	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPadrao
	Replace E1_LA With "S"
End

//Pcc Baixa CR
If lPccBxCr .or. lBaseImp
	Replace E1_PIS		With nPisBxCr
	Replace E1_COFINS	With nCofBxCr
	Replace E1_CSLL	With nCslBxCr

	//639.04 Base Impostos diferenciada
	If lBaseImp .and. nBaseImp > 0
		SE1->E1_BASEIRF := nBaseImp
		SE1->E1_BASEINS := nBaseImp
		SE1->E1_BASEISS := nBaseImp
		SE1->E1_BASEPIS := nBaseImp
		SE1->E1_BASECOF := nBaseImp
		SE1->E1_BASECSL := nBaseImp
	Endif

Endif  

//IR Baixa CR
If lIrPjBxCr .or. lBaseImp
	Replace E1_IRRF		With cIrBxCr

		//639.04 Base Impostos diferenciada
	If lBaseImp .and. nBaseImp > 0
		SE1->E1_BASEIRF := nBaseImp
		SE1->E1_BASEINS := nBaseImp
		SE1->E1_BASEISS := nBaseImp
		SE1->E1_BASEPIS := nBaseImp
		SE1->E1_BASECOF := nBaseImp
		SE1->E1_BASECSL := nBaseImp
	Endif

Endif

MsUnlock()

nRecno := SE1->(RECNO())

If lFA280_
	ExecBlock("FA280",.f.,.f.,nRegE1)
Endif

VALOR = 0
IF lPadrao
	If !lHead
		nHdlPrv:=HeadProva(cLote,cPrograma,Substr(cUsuario,7,6),@cArquivo)
		lHead := .T.
	Endif
	nTotal+=DetProva(nHdlPrv,cPadrao,cPrograma,cLote)
Endif
RestArea(aArea)

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³FA280ConFa ³ Autor ³ Deny B. de Mendonca  ³ Data ³ 29/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava a Fatura no SE1                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA280ConFa()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor Total do Lancamento                          ³±±
±±³          ³ ExpC2 = Codigo do lancamento Padronizado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FA280ConFa( nValTotal, cPadrao, cArquivo, nHdlPrv, nTotal, cPrograma, aFlagCTB, lAutomato )
Local nRecnoSE1
Local aArea := GetArea( )
Local lDigita := .F.

Default cPrograma := "FINA280"
Default aFlagCTB := {}
Default lAutomato := .F.


	dbSelectArea( "SE1" )
	nRecnoSE1 := SE1->( Recno( ) )
	SE1->( DBGoBottom( ) )
	SE1->( dbSkip( ) )

	VALOR := nValTotal // Contabiliza pelo acumulador

	nTotal += DetProva( nHdlPrv, cPadrao, cPrograma, cLote, /*nLinha*/, /*lExecuta*/,;
	                    /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
	                    /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )

	//-- Se for rotina automatica força exibir mensagens na tela, pois mesmo quando não exibe os lançametnos, a tela 
	//-- sera exibida caso ocorram erros nos lançamentos padronizados
	If (Type("lF280Auto")<>"U" .and. lF280Auto)
		lSetAuto := _SetAutoMode(.F.)
		lSetHelp := HelpInDark(.F.)
		If Type('lMSHelpAuto') == 'L'
			lMSHelpAuto := !lMSHelpAuto
		EndIf						
	EndIf
	
	lDigita := IIF( mv_par02==1 .And. !lAutomato .And. !lF280Auto,.T.,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para Lancamento Contabil             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RodaProva( nHdlPrv, nTotal )
	CA100Incl( cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, lDigita,;
	           .F. /*lAglut*/, /*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB,;
	           /*aDadosProva*/, /*aDiario*/ )
	aFlagCTB := { }  // Limpa o coteudo apos a efetivacao do lancamento

	If (Type("lF280Auto")<>"U" .and. lF280Auto)
		HelpInDark(lSetHelp)
		_SetAutoMode(lSetAuto)
		If Type('lMSHelpAuto') == 'L'
			lMSHelpAuto := !lMSHelpAuto
		EndIf
	EndIf

	dbSelectArea( "SE1" )
	SE1->( DBGoTo( nRecnoSE1 ) )
	RestArea( aArea )

Return( )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Fa280bAval ³ Autor ³ Mauricio Pequim Jr.  ³ Data ³ 02/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Bloco de marcacoo       			          						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fa280bAval()		  													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA280																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa280bAval(cAliasSe1,cMarca,oValor,oQtdTit,oMark,nValor,nTotExcluido,lExclui,aChaveLbn,nValorF,oValorFat, lAutomato)
Local lRet 		:= .T.
Local cChaveLbn 

DEFAULT nTotExcluido := 0
DEFAULT lExclui		:= .F.  
DEFAULT nValorf := 0
DEFAULT lAutomato	:= .F.

If (cAliasSe1)->(FieldPos("RECNO")) > 0
	DbSelectArea("SE1")
	MsGoto((cAliasSe1)->RECNO)
	DbSelectArea(cAliasSe1)
Endif	
cChaveLbn := "FAT" + (cAliasSe1)->(xFilial("SE1")+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
// Verifica se o registro nao esta sendo utilizado em outro terminal
//-- Funcao LockByName() substituída por SimpleLock() -> performance
If SE1->(SimpleLock())
	Fa280Inverte(cAliasSe1,cMarca,oValor,oQtdTit,.F.,oMark,@nValor,@nTotExcluido,lExclui,,aChaveLbn,cChaveLbn,@nValorF,oValorFat) // Marca o registro e trava
	lRet := .T.
Else
	If !lAutomato .And. (Type("lF280Auto")<>"U" .and. !lF280Auto)
		IW_MsgBox(STR0071,STR0061,"STOP") //"Este titulo está sendo utilizado em outro terminal, não pode ser utilizado na fatura"###"Atenção"
	Endif
	lRet := .F.
Endif	
oMark:oBrowse:Refresh(.t.)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA280DATA ºAutor  ³Mauricio Pequim Jr  º Data ³21.06.2004   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica data de vencimento das parcelas a serem geradas    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA280                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fa280data()
Local lRet := .F.
Local dDataVc := &(ReadVar())

//Nao permite data de vencimento menor que data de inclusão
lRet := dDataVc >= dDataBase   

If ExistBlock("F280DTVC")
	lRet := ExecBlock("F280DTVC",.f.,.f.,{dDataVc})
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa280VerImºAutor  ³Claudio D. de Souza º Data ³08.07.2005   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica os impostos a serem considerados na selecao dos	  º±±
±±º          ³titulos que farao parte da fatura.								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA280                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa280VerImp(cNaturez,lRetPccCr)
Local cRet := ""
Local aAreaSed := SED->(GetArea())

//Controle do PCC na Baixa
//Verificacao para saber se a natureza da fatura a gerar
//Efetua calculo de PCC
DEFAULT lRetPccCr := .F.		//Controle do PCC na Baixa   pcc aqui

SED->(MsSeek(xFilial("SED")+cNaturez))
If SED->ED_CALCPIS$"1S" .and. SA1->A1_RECPIS $ "S#P"
	If lRetPccCr
		cRet += "PIS"
	Else
		cRet += MVPIABT
	Endif
Endif
If SED->ED_CALCCOF$"1S" .and. SA1->A1_RECCOFI $ "S#P"
	If lRetPccCr
		cRet += "COF"
	Else
		cRet += MVCFABT
	Endif
Endif
If SED->ED_CALCCSL$"1S" .And. SA1->A1_RECCSLL $ "S#P"
	If lRetPccCr
		cRet += "CSL"
	Else
		cRet += MVCSABT
	Endif
Endif

If !lRetPccCr
	If SED->ED_CALCIRF$"1S" .And. If(cPaisLoc == "BRA", SA1->A1_RECIRRF $ "1", .T.)
		cRet += MVIRABT
	Endif
	If SED->ED_CALCINS$"1S"
		cRet += MVINABT
	Endif
	If SED->ED_CALCISS$"1S" .AND. SA1->A1_RECISS $ "1"
		cRet += MVISABT+"/"+MVI2ABT
	Endif
Endif

SED->(RestArea(aAreaSed))

Return cRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa280Corre³ Autor ³ Paulo Augusto 		³ Data ³ 21/09/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula a corre‡„o monet ria.								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fa280Correc()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Gen‚rico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fa280Correc(dDtBaixa,cAlias)

Local nCorrecao := 0
Local nValAtual := 0
Local nValEmiss := 0

DEFAULT dDtBaixa  := dDataBase
DEFAULT cAlias :="SE1"

IF (cAlias)->E1_MOEDA > 1
	//Caso seja a primeira apuracao de variacao monetaria
	If Empty((cAlias)->E1_TXMOEDA) .and. Empty((cAlias)->E1_DTVARIA)
		nValEmiss := (cAlias)->E1_VLCRUZ
	Else
		nValEmiss  :=  xMoeda((cAlias)->E1_SALDO,(cAlias)->E1_MOEDA,1,IF(Empty((cAlias)->E1_DTVARIA),(cAlias)->E1_EMISSAO,(cAlias)->E1_DTVARIA),,If(cPaisLoc=="BRA",(cAlias)->E1_TXMOEDA,0))
	Endif

	nValAtual := xMoeda( (cAlias)->E1_SALDO, (cAlias)->E1_MOEDA, 1, dDtBaixa)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica atraves do parametro MV_CALCCM se sera calculada a cor-³
	//³ recao monetaria.                                           	  ³
	//³ Caso o parametro nao exista, sera assumido "S"						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetMv("MV_CALCCM") == "S"
		nCorrecao := nValAtual - nValEmiss
	Else
		nCorrecao := 0
	Endif
Endif
Return nCorrecao

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa280Pesq ³ Autor ³ Claudio D de Souza    ³ Data ³28.09.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ tela de pesquisa - WINDOWS 							      	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Financeiro - FINA280												     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa280Pesq(oMark, cAlias,cAliasSe1)
Local cAliasAnt := Alias()
Local nRecno
Local nOrdInd := IndexOrd()		
Local cCampos
Local nOrderSe1 := (cAliasSe1)->(IndexOrd())

cCampos := (cAliasSe1)->(IndexKey(1))
nRecno := (cAliasSe1)->(Recno())
		
dbSelectArea(cAlias)
AxPesqui()

cCampos := cAlias + "->(" + cCampos + ")"

(cAliasSe1)->(DbSetOrder(1))
If (cAliasSe1)->(MSSeek(&cCampos))
	// Se o que foi digitado para pesquisa nao estiver dentro do filtro
	// Continua no mesmo registro que estava antes de selecionar CTRL-P
	If !&(Fa280ChecF())
		(cAliasSe1)->(dbGoto(nRecNo))
	Endif
Else	
	(cAliasSe1)->(dbGoto(nRecNo))
Endif	

DbSelectArea(cAliasAnt)
dbSetOrder(nOrdInd)

(cAliasSe1)->(dbSetOrder(nOrderSe1))
oMark:oBrowse:Refresh(.T.)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³23/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local lF280AdMenu := ExistBlock( "F280ADMENU" )
Local aRotina :=  {	{ STR0001,"AxPesqui"  , 0 , 1,,.F.},; 	//"Pesquisar"
						{ STR0002,"FA280Visua", 0 , 2 },; 		//"Visualizar"
						{ STR0003,"fA280Aut"  , 0 , 3 },; 		//"Selecionar"
						{ STR0004,"FA280Can"  , 0 , 6 },;  		//"Cancelar"
						{ STR0079,"Fa040Legenda"  , 0 ,2, ,.F.  }}  	//"Legenda"
			
If lF280AdMenu

	aMenus := AClone( aRotina )
	aRotina := 	ExecBlock( "F280ADMENU", .F., .F., aRotina )
	
  	If ValType(aRotina) != "A" .Or. Len(aRotina) < 4
		aRotina := aClone(aMenus)
	Endif 
	
EndIf
							
Return(aRotina)



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FinA280T   ³ Autor ³ Marcelo Celi Marques ³ Data ³ 27.03.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada semi-automatica utilizado pelo gestor financeiro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FinA280T(aParam)

	cRotinaExec := "FINA280"
	ReCreateBrow("SE1",FinWindow)      	
	FinA280(aParam[1])
	dbSelectArea("SE1")
	FinVisual("SE1",FinWindow,SE1->(Recno()),.T.)
	ReCreateBrow("SE1",FinWindow)      	

	dbSelectArea("SE1")
	
	INCLUI := .F.
	ALTERA := .F.
	
Return .T.	



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F280SelFat ³ Autor ³ Marcelo Celi Marques ³ Data ³ 12.05.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Markbrowse da Faturas a Receber					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto onde se encaixara a MarkBrowse				  ³±±
±±³			 ³ ExpC1 = Tratamento aplicado a outras moedas (<>1)			  ³±±
±±³			 ³ ExpN1 = Valor dos titulos selecionados							  ³±±
±±³			 ³ ExpN2 = Quantidade de titulos selecionados					  ³±±
±±³			 ³ ExpC2 = Marca (GetMark())				 							  ³±±
±±³			 ³ ExpO2 = Objeto Valor dos titulos selecionados p/ refresh	  ³±±
±±³			 ³ ExpO3 = Objeto Quantidade de titulos selecionados p/refresh³±±
±±³			 ³ ExpN3 = Moeda da Substituicao             					  ³±±
±±³			 ³ ExpO4 = Objeto Painel superior a ser desabilitado			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA280                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function F280SelFat(oDlg,nOpca,cCond,nValor,nValTot,aVenc,cPrefix,cFatura,cTipo,dDatCont,oSize)
	Local lPanelFin := IsPanelFin()
	Local no := 0
	Local oFnt 
	Local oFnt2
	Local lF280PARC := ExistBlock( "F280PARC" ) 
	Local nLinIni := oSize:GetDimension("MASTER","LININI")
	Local nColIni := oSize:GetDimension("MASTER","COLINI")
	Local nLinFin := oSize:GetDimension("MASTER","LINEND")
	Local nColFin := oSize:GetDimension("MASTER","COLEND")
	Local lRemHTML := GetRemoteType() == REMOTE_HTML
	DEFINE FONT oFnt NAME "Arial" SIZE 12,14 BOLD 
	DEFINE FONT oFnt2 NAME "Arial" SIZE 10,14 BOLD	

	If !((ExistBlock("F280CON")))
		cCondicao := If(nOpca=0,"   ",cCond)
		aVenc := Condicao(nValor,cCondicao,0)												 													 	
	Endif
		
	nDup	:= Len(aVenc)
	cTipo  := cOldTipo 
	
	aCols := GravaDp(nDup,cPrefix,cFatura,nValor,dDatabase,aVenc,cTipo,"FINA280")
	
	If lF280PARC
		ExecBlock( "F280PARC", .F., .F., {aCols, aHeader} )
	EndIf
					
	If !Empty(aCols)
		aVlCruz := {}
		aVlCruz := F280VlCruz(nDup,nValCruz)
		
		// Mostra tela com os diversos titulos
		nValTot:=0
		For no:=1 To Len(aCols)
			nValTot += aCols[no][6]
		Next
		
		nOpca := 0

		@ nLinIni + 005,135	SAY STR0029 OF oDlg SIZE 80,14 Pixel//"Data Contabiliza‡„o : "
		@ nLinIni + 005,190	Say dDatCont OF oDlg SIZE 80,14  Pixel //FONT oDlg2:oFont
		@ nLinIni + 005,248	Say STR0030 OF oDlg SIZE 80,14 Pixel //"Condi‡„o de Pagamento : "
		@ nLinIni + 005,315	Say cCondicao OF oDlg SIZE 80,14  Pixel
		@ nLinIni + 005,375	Say STR0031 OF oDlg Pixel SIZE 80,14 //"Valor Total:"
		
		If !ExistBlock("F280CON")
			If lRemHTML
				@ nLinIni + 015,248	Say SE4->E4_DESCRI OF oDlg Pixel COLOR CLR_HBLUE //FONT oFnt2
			Else
				@ nLinIni + 015,248	Say SE4->E4_DESCRI OF oDlg Pixel COLOR CLR_HBLUE FONT oFnt2
			EndIf 
		Endif	
		
		if cPaisLoc <> "CHI"
			If lRemHTML
				@ nLinIni + 005,405 Say oValTot VAR nValTot Picture "@E 9,999,999,999.99" OF oDlg PIXEL COLOR CLR_HBLUE  //FONT oFnt
			Else
				@ nLinIni + 005,405 Say oValTot VAR nValTot Picture "@E 9,999,999,999.99" OF oDlg PIXEL COLOR CLR_HBLUE  FONT oFnt			
			EndIf	 
		else
			If lRemHTML
				@ nLinIni + 005,405 Say oValTot VAR nValTot Picture "@E 999,999,999,999"  OF oDlg PIXEL COLOR CLR_HBLUE //FONT oFnt
			Else
				@ nLinIni + 005,405 Say oValTot VAR nValTot Picture "@E 999,999,999,999"  OF oDlg PIXEL COLOR CLR_HBLUE FONT oFnt
			EndIf	 
		endif
		
		oGet := MSGetDados():New(nLinIni+33,nColIni,nLinFin,nColFin,3,"Fa280LinOk","Fa280TudOk","",.T.,,,,,,"",,"Fa280AtuVl(.F.)")
					
	
   Endif  

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA280PEVQFºAutor  ³Microsiga           º Data ³  03/21/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa ponto de entrada que verifica e valida a quantidadeº±±
±±º          ³ de titulos associados a fatura                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA280                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA280PEVQF( nQtdTit )
Local lResult := .T.
	If ExistBlock( "FA280VQF" )
		lResult := ExecBlock( "FA280VQF", .F., .F., { nQtdTit } )
   Endif
Return lResult



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FA280MotBXºAutor  ³Marcelo Celi Marquesº Data ³  23/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao criar automaticamente o motivo de baixa FAT na      º±±
±±º          ³ tabela Mot baixas                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA280                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Static Function Fa280MotBx(cMot,cNomMot, cConfMot)
	Local aMotbx := ReadMotBx()
	Local nHdlMot, I, cFile := "SIGAADV.MOT"
	
	If ExistBlock("FILEMOT")
		cFile := ExecBlock("FILEMOT",.F.,.F.,{cFile})
	Endif
	
	If Ascan(aMotbx, {|x| Substr(x,1,3) == Upper(cMot)}) < 1
		nHdlMot := FOPEN(cFile,FO_READWRITE)
		If nHdlMot <0
			HELP(" ",1,"SIGAADV.MOT")
			Final("SIGAADV.MOT")
		Endif
		
		nTamArq:=FSEEK(nHdlMot,0,2)	// VerIfica tamanho do arquivo
		FSEEK(nHdlMot,0,0)			// Volta para inicio do arquivo

		For I:= 0 to  nTamArq step 19 // Processo para ir para o final do arquivo	
			xBuffer:=Space(19)
			FREAD(nHdlMot,@xBuffer,19)
	    Next		
		
		fWrite(nHdlMot,cMot+cNomMot+cConfMot+chr(13)+chr(10))	
		fClose(nHdlMot)		
	EndIf	
Return

                  
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FNatCliPCC ³ Autor ³ Mauricio Pequim Jr   ³ Data ³ 04.12.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para verificar se a combinacao Cliente x Natureza   ³±±
±±³          ³ permitem o calculo de PCC											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA280/FINA460                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FNatCliPCC(cNaturez,cCliente,cLoja)

Local lRet := .F.
Local aAreaFat := GetArea()

DEFAULT cNaturez	:= ""
DEFAULT cCliente	:= ""
DEFAULT cLoja		:= ""

If !Empty(cNaturez) .and. !Empty(cCliente) .and. !Empty(cloja)
	//Posiciono cadastro de Naturezas
	//Posiciono cadastro de Clientes
	//Verifico se ha combinacao para calculo de PCC
	SED->(DbSetOrder(1))
	SA1->(DbSetOrder(1))
	If SED->(MsSeek(xFilial("SED")+cNaturez)) .and. SA1->(xFilial("SA1")+cCliente+cLoja)
		If (SED->ED_CALCCSL == "S" .and. SA1->A1_RECCSLL $ "S#P") .OR. ;
			(SED->ED_CALCCOF == "S" .and. SA1->A1_RECCOFI $ "S#P") .OR. ;
			(SED->ED_CALCPIS == "S" .and. SA1->A1_RECPIS  $ "S#P") 
			lRet := .T.
		Endif
	Endif
Endif

RestArea(aAreaFat)

Return lRet         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ F280BlqVen ºAutor ³ Gustavo Henrique   º Data ³  29/08/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verificar se o vendedor esta bloqueado                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ EXPL1 - .T. - Vendedor bloqueado                           º±±
±±º          ³         .F. - Vendedor liberado                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faturas a Receber                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F280BlqVen()

Local lRet 		:= .F.
Local aAreaSA3	:= {}

SA3->( dbSetOrder( 1 ) )
SA3->( MsSeek( xFilial( "SA3" ) + SE1->E1_VEND1 ) )

If SA3->( FieldPos( "A3_MSBLQL" ) > 0 )
                     
	aAreaSA3 := SA3->( GetArea() )

	lRet := (SA3->A3_MSBLQL == "1")	// Bloqueado

	SA3->( RestArea( aAreaSA3 ) )
	
EndIf

Return lRet

//-------------------------------------------------------...//-------------------------------------------------------------------
/*/{Protheus.doc} F280GetTit
Função que verifica retorna os vetores com os títulos baixados e com 
os novos títulos gerados, para uso na mensagem única FinancialTrading
		
@return aBaixados - Vetor com os títulos baixados
@return aNovos - Vetor com os novos títulos gerados 

@author Pedro Alencar
@version P12
@since	31/03/2014											
/*/
//-------------------------------------------------------------------
Function F280GetTit ()
Local aBaixados	:= {}
Local aNovos	:= {}
Local cFatura	:= ''

aBaixados := aClone(__aBaixados) 
aNovos := aClone(__aNovosTit)
cFatura := __cNroFatur 
	
Return {aBaixados, aNovos, cFatura} 

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Integração via mensagem única

@author Pedro Pereira Lima
@version P12
@since	01/04/2014											
/*/
//-------------------------------------------------------------------
Static Function IntegDef( cXml, nType, cTypeMsg )  
Local aReturn := {}

aReturn := FINI280( cXml, nType, cTypeMsg )

Return aReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} F280ChgVar
Altera o valor das variáveis INCLUI, ALTERA e EXCLUI, retornando um array
contendo os valores originais

@author Pedro Pereira Lima
@version P12
@since	04/01/2015											
/*/
//-------------------------------------------------------------------
Static Function F280ChgVar()
Local aRet := {,}

If Type("INCLUI") <> "U"
	aRet[1] := INCLUI
	If INCLUI
		INCLUI := .F.
	EndIf
EndIf

If Type("ALTERA") <> "U"
	aRet[2] := ALTERA
	If ALTERA
		ALTERA := .F.
	EndIf
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F280RetVar
Retorna os valores originais das variáveis INCLUI, ALTERA e EXCLUI

@author Pedro Pereira Lima
@version P12
@since	04/01/2015											
/*/
//-------------------------------------------------------------------
Static Function F280RetVar(aValOrig)
Default aValOrig := {}

If !Empty(aValOrig)
	
	If ValType(aValOrig[1]) == "L"
		INCLUI := aValOrig[1]
	EndIf

	If ValType(aValOrig[2]) == "L"
		ALTERA := aValOrig[2]
	EndIf

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F280VLDDT
Valida data de/até

@author lucas.oliveira
@version P12
@since	26/02/2015
/*/
//-------------------------------------------------------------------
Function F280VLDDT( cCampo, dDataDe, dDataAte )  
local lRet := .T.

If cCampo == "DataDe"
	If Empty(dDataDe)
		Help(" ",1,"DTVAZIA",,STR0084,1,0)//"O campo Emissão De deve ser preenchido."
		lRet := .F.		
	EndIf
Else
	If !Empty(dDataAte)
		If dDataAte < dDataDe
			Help(" ",1,"DTINVALID",,STR0085,1,0)//"O campo Até deve ser maior ou igual ao campo Emissão De."
			lRet := .F.
		EndIf	
		If lRet .and. dDataAte > dDataBase
			Help(" ",1,"DTINVALID",,STR0086 + DTOC(dDataBase)+".",1,0)//"O campo Até deve ser menor ou igual a " DTOC(dDataBase) "."
			lRet := .F.
		EndIf		
	Else
	Help(" ",1,"DTVAZIA",,STR0087,1,0)//"O campo Até deve ser preenchido."
	lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F280EXEC
Monta Query com base nos dados informados via ExecAuto.

@author leonardo.casilva
@version P12
@since	06/12/2016
/*/
//-------------------------------------------------------------------
Static Function F280EXEC(aStru,aTitulos)

Local cQry := ""
Local nY  := 0
Local nCt := 0

	For nCt := 1 To Len(aStru)
		If aStru[nCt,2] <> "M"
			cQry += "," + Alltrim(aStru[nCt,1])
		Endif
	Next nCt
	cQry := "SELECT " + SubStr(cQry,2)
	cQry += ","+"SE1.R_E_C_N_O_ RECNO "
	cQry += "FROM " + RetSqlName("SE1") + " SE1 "
	cQry += "WHERE SE1.R_E_C_N_O_ IN( "

	For nY := 1 to Len(aTitulos)
		cQry += If(nY > 1," , ","") + aTitulos[nY,2]
	Next
	
	cQry += " ) "
	
	cQry += " AND SE1.D_E_L_E_T_ = ' ' "
	
Return cQry


